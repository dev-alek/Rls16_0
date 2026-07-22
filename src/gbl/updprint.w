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

Создание и редактирование шаблона печати

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/08/03
Author: Bakhtadze Natalya
Creation date: 07/08/03

*/

/* ***************************  Definitions  ************************** */


/* Parameters Definitions ---                                           */
define input parameter  c-point     as character no-undo .
define input parameter  list-tabls  as character no-undo .
define input parameter  list-buf    as character no-undo .
define input parameter  list-fields as character no-undo .
define input parameter  list-labels as character no-undo .
define input parameter  list-spr    as character no-undo .
define input parameter  list-size    as character no-undo .
define input parameter  list-format    as character no-undo .
define input parameter  list-dim    as character no-undo .
define input parameter  kl          as integer   no-undo .
define output parameter ident       as recid     no-undo .
define output parameter P-LENGTH       as INTEGER     no-undo .
define output parameter P-NUM-CLMN       as INTEGER     no-undo .

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Создание и редактирование шаблона печати".
{ cmp/vssrevis.i substitute('&1|&2|&3|&4|&5|&6|&7|&8':u,c-point,list-tabls,list-buf,list-fields,list-labels,list-spr,list-dim,kl)"}
{ cmp/trg-def.i  }
{ cmp/showinf.i }
{ trg/factord.i }
{ cmp/yearofst.i }

def new shared var undo_ as logical initial no.

DEF VAR select3 AS CHARACTER INITIAL "" no-undo.
def var select3-size as character no-undo .
def var select3-format as character no-undo .
def var select3-type as character no-undo .
def var select3-label as character no-undo .

/* Local Variable Definitions ---                                       */

{ gbl/prtmpldt.i }

define buffer sel_t-f for t-f.
def var v-rb as character no-undo.
DEF VAR ii AS INTEGER no-undo.
DEF VAR jj AS INTEGER no-undo.
DEF VAR kk AS INTEGER no-undo.
DEF VAR ll AS INTEGER no-undo.
DEF VAR id AS RECID no-undo.
DEF VAR file-name LIKE _FILE-NAME no-undo.
define variable v-new as logical no-undo .
define variable v-length as integer no-undo.
define variable v-num-clmn as integer no-undo.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME DIALOG-1
&Scoped-define BROWSE-NAME BR-fields

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES t-f sel_t-f ubflt.filter

/* Definitions for BROWSE BR-fields                                     */
&Scoped-define FIELDS-IN-QUERY-BR-fields t-f.field-label t-f.field-size
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-fields
&Scoped-define FIELD-PAIRS-IN-QUERY-BR-fields
&Scoped-define SELF-NAME BR-fields
&Scoped-define OPEN-QUERY-BR-fields OPEN QUERY {&SELF-NAME} FOR EACH t-f no-lock where t-f.table-name = RS-tabs and t-f.field-order = 0 use-index itorder.
&Scoped-define TABLES-IN-QUERY-BR-fields t-f
&Scoped-define FIRST-TABLE-IN-QUERY-BR-fields t-f


/* Definitions for BROWSE BR-sel-fields                                 */
&Scoped-define FIELDS-IN-QUERY-BR-sel-fields sel_t-f.field-label sel_t-f.field-size
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-sel-fields
&Scoped-define FIELD-PAIRS-IN-QUERY-BR-sel-fields
&Scoped-define SELF-NAME BR-sel-fields
&Scoped-define OPEN-QUERY-BR-sel-fields OPEN QUERY {&SELF-NAME} FOR EACH sel_t-f no-lock where sel_t-f.field-order > 0 use-index iorder.
&Scoped-define TABLES-IN-QUERY-BR-sel-fields sel_t-f
&Scoped-define FIRST-TABLE-IN-QUERY-BR-sel-fields sel_t-f


/* Definitions for DIALOG-BOX DIALOG-1                                  */
&Scoped-define FIELDS-IN-QUERY-DIALOG-1 ubflt.filter.Naim
&Scoped-define ENABLED-FIELDS-IN-QUERY-DIALOG-1 ubflt.filter.Naim
&Scoped-define ENABLED-TABLES-IN-QUERY-DIALOG-1 ubflt.filter
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-DIALOG-1 ubflt.filter
&Scoped-define OPEN-BROWSERS-IN-QUERY-DIALOG-1 ~
    ~{&OPEN-QUERY-BR-sel-fields}
&Scoped-define OPEN-QUERY-DIALOG-1 OPEN QUERY DIALOG-1 FOR EACH ubflt.filter SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-DIALOG-1 ubflt.filter
&Scoped-define FIRST-TABLE-IN-QUERY-DIALOG-1 ubflt.filter


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS ubflt.filter.Naim
&Scoped-define FIELD-PAIRS~
 ~{&FP1}Naim ~{&FP2}Naim ~{&FP3}
&Scoped-define ENABLED-TABLES ubflt.filter
&Scoped-define FIRST-ENABLED-TABLE ubflt.filter
&Scoped-Define ENABLED-OBJECTS Btn_OK RECT-1 Btn_Cancel b-help RS-tabs ~
BR-sel-fields BR-fields
&Scoped-Define DISPLAYED-FIELDS ubflt.filter.Naim
&Scoped-Define DISPLAYED-OBJECTS RS-tabs f-num-clmn f-length FILL-IN-4 ~
FILL-IN-3

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-down
     LABEL "Вни&з":L
     SIZE 8.5 BY 1.17 TOOLTIP "Понизить порядок выбранного поля".

DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь":L
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-up
     LABEL "Ввер&х":L
     SIZE 8.5 BY 1.17 TOOLTIP "Повысить порядок выбранного поля".

DEFINE BUTTON btn-add
     LABEL "&Добавить":L
     SIZE 8.5 BY 1.25 TOOLTIP "Добавить поле в список сортируемых полей".

DEFINE BUTTON btn-remove
     LABEL "У&брать":L
     SIZE 8.5 BY 1.17 TOOLTIP "Убрать поле из списка сортируемых полей".

DEFINE BUTTON Btn_Cancel AUTO-END-KEY DEFAULT
     LABEL "&Отмена ":L
     SIZE 10 BY 1 TOOLTIP "Выход без изменений"
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO DEFAULT
     LABEL "&Сохранить":L
     SIZE 10 BY 1 TOOLTIP "Сохранить сформированный фильтр"
     BGCOLOR 8 .

DEFINE VARIABLE f-length AS CHARACTER FORMAT "X(5)":U
     VIEW-AS FILL-IN
     SIZE 9.13 BY 1 NO-UNDO.

DEFINE VARIABLE f-num-clmn AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 6.13 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-3 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 40 BY 1
     BGCOLOR 1 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-4 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 40 BY 1
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
t-f.field-size format "X(3)":U column-label "Длина!поля"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 40 BY 13.17
         BGCOLOR 15 .

DEFINE BROWSE BR-sel-fields
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-sel-fields DIALOG-1 _FREEFORM
  QUERY BR-sel-fields DISPLAY
      sel_t-f.field-label format "X(30)" column-label "Название поля"
sel_t-f.field-size format "X(3)":U column-label "Длина!поля"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 40 BY 13.25
         BGCOLOR 15 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DIALOG-1
     Btn_OK AT ROW 1 COL 1
     Btn_Cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     ubflt.filter.Naim AT ROW 2.67 COL 1.88 HELP
          ""
          LABEL "Имя шаблона печати" FORMAT "X(255)"
          VIEW-AS FILL-IN
          SIZE 77.38 BY 1 TOOLTIP "Введите имя создаваемого шаблона печати"
          BGCOLOR 15
     RS-tabs AT ROW 4.5 COL 2 NO-LABEL
     f-num-clmn AT ROW 5.42 COL 89.63 COLON-ALIGNED NO-LABEL
     f-length AT ROW 5.46 COL 66.88 COLON-ALIGNED NO-LABEL
     FILL-IN-4 AT ROW 7.08 COL 56.13 COLON-ALIGNED NO-LABEL
     FILL-IN-3 AT ROW 7.25 COL 2 NO-LABEL
     BR-sel-fields AT ROW 8.08 COL 58
     BR-fields AT ROW 8.25 COL 2
     btn-add AT ROW 9.58 COL 46
     btn-remove AT ROW 10.83 COL 46
     b-up AT ROW 13.08 COL 46
     b-down AT ROW 14.33 COL 46
     RECT-1 AT ROW 2.25 COL 1
     "Кол-во полей" VIEW-AS TEXT
          SIZE 12.5 BY .67 AT ROW 5.54 COL 78.88
          BGCOLOR 1 FGCOLOR 15
     "Длина шаблона" VIEW-AS TEXT
          SIZE 14.5 BY .67 AT ROW 5.63 COL 53.5
          BGCOLOR 1 FGCOLOR 15
     SPACE(31.87) SKIP(15.36)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         BGCOLOR 8 FGCOLOR 0
         TITLE BGCOLOR 8 FGCOLOR 0 "":L
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX DIALOG-1
                                                                        */
/* BROWSE-TAB BR-sel-fields FILL-IN-3 DIALOG-1 */
/* BROWSE-TAB BR-fields BR-sel-fields DIALOG-1 */
ASSIGN
       FRAME DIALOG-1:SCROLLABLE       = FALSE.

/* SETTINGS FOR BUTTON b-down IN FRAME DIALOG-1
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-up IN FRAME DIALOG-1
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON btn-add IN FRAME DIALOG-1
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
/* SETTINGS FOR FILL-IN ubflt.filter.Naim IN FRAME DIALOG-1
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
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


&Scoped-define SELF-NAME btn-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-add DIALOG-1
ON CHOOSE OF btn-add IN FRAME DIALOG-1 /* Добавить */
DO:
define variable v-max-order as integer no-undo.
define buffer buf_t-f for t-f.
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
browse br-sel-fields:set-repositioned-row(5, "CONDITIONAL").

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
v-length = v-length - INTEGER(buf_t-f.field-SIZE)
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
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK DIALOG-1
ON CHOOSE OF Btn_OK IN FRAME DIALOG-1 /* Сохранить */
DO:
define variable v-file-name as character no-undo.
define buffer buf_sel-t-f for t-f.
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
select3-format = "":U
select3-type = "":U
select3-label = "":U
.

for each buf_sel-t-f no-lock where
         buf_sel-t-f.field-order > 0 :
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
select3-format = select3-format + {&delim-par} + buf_sel-t-f.field-format
select3-type = select3-type + {&comma-char} + buf_sel-t-f.field-type
select3-label = select3-label + {&comma-char} + buf_sel-t-f.field-label
.

end.

assign
Filter.naim = input frame {&frame-name} ubflt.filter.naim
Filter.call-point = c-point
Filter.Tbl = List-Tabls
Filter.Flds = List-Fields
Filter.Fields-sort = left-trim(SELECT3, {&comma-char})
Filter.Fields-sort-rus = left-trim(SELECT3-label, {&comma-char})
Filter.Where-ysl = left-trim(select3-size, {&comma-char})
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
  assign
  rs-tabs.
OPEN QUERY br-fields FOR EACH t-f no-lock where t-f.table-name = RS-tabs
and t-f.field-order = 0 use-index itorder.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK DIALOG-1


/* ***************************  Main Block  *************************** */
/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
  fill-in-3 = 'Доступные поля'.
  fill-in-4 = 'Выбранные поля'.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
IF Kl <> 0 THEN DO:
   FIND FIRST ubflt.filter WHERE Num-flt = Kl.
   assign
   select3 = ubflt.filter.Fields-sort
   select3-label = ubflt.filter.Fields-sort-rus
   select3-size = ubflt.filter.Where-ysl
   select3-format = ubflt.filter.Where-ysl-rus
   select3-type = ubflt.filter.lst-cend
   /*
   List-Tabls = ubflt.filter.Tbl
  ubflt.filter.Flds = List-Fields
  ubflt.filter.Fields-sort = left-trim(SELECT3, {&comma-char})
  ubflt.filter.Fields-sort-rus = left-trim(SELECT3-label, {&comma-char})
  ubflt.filter.Where-ysl = left-trim(select3-size, {&comma-char})
  ubflt.filter.Where-ysl-rus = left-trim(select3-format, {&delim-par})
  ubflt.filter.lst-cend = left-trim(select3-type, {&comma-char})

     */


   .
END.
ELSE DO:
   CREATE ubflt.filter.
   assign
   ubflt.filter.call-point = c-point
   Kl = Num-flt
   .
   v-new = yes.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI DIALOG-1 _DEFAULT-DISABLE
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI DIALOG-1 _DEFAULT-ENABLE
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
  DISPLAY RS-tabs f-num-clmn f-length FILL-IN-4 FILL-IN-3
      WITH FRAME DIALOG-1.
  IF AVAILABLE ubflt.filter THEN
    DISPLAY ubflt.filter.Naim
      WITH FRAME DIALOG-1.
  ENABLE Btn_OK RECT-1 Btn_Cancel b-help ubflt.filter.Naim RS-tabs BR-sel-fields
         BR-fields
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
      v-num-clmn = v-num-clmn +  (if   t-f.field-order > 0 then 1 else 0)
      v-length = v-length + (if   t-f.field-order > 0 then integer(entry(t-f.field-order, ubflt.filter.where-ysl)) else 0)
      .
      assign
      t-f.field-clabel = entry(kk,Select3-Label)
      no-error .
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
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do ii = 1 to num-entries(list-tabls):
assign
v-rb = v-rb +
           (if v-rb = "":U then "":U else {&comma-char}) +
            entry(ii, list-buf) + {&comma-char} + entry(ii, list-tabls) .
.
end.
assign rs-tabs:radio-buttons in frame {&frame-name}= v-rb.

 DISPLAY RS-tabs FILL-IN-3 FILL-IN-4
      WITH FRAME DIALOG-1.
  IF AVAILABLE ubflt.filter THEN
    DISPLAY ubflt.filter.Naim
      WITH FRAME DIALOG-1.
  ENABLE Btn_OK RECT-1 Btn_Cancel b-help ubflt.filter.Naim RS-tabs BR-fields
         BR-sel-fields
      WITH FRAME DIALOG-1.
  {&OPEN-BROWSERS-IN-QUERY-DIALOG-1}
  APPLY "Value-changed" to rs-tabs.
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
WITH FRAME {&FRAME-NAME}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME