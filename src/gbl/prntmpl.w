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

Выбор шаблона печати

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/08/03
Author: Bakhtadze Natalya
Creation date: 07/08/03

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter  bttn        as character no-undo .
define input parameter c-point as character no-undo .
define input parameter tbl     as character no-undo .
define input parameter buf     as character no-undo .
define input parameter fld     as character no-undo .
define input parameter lab     as character no-undo .
define input parameter spr     as character no-undo .
define input parameter p-size  as character no-undo .
define input parameter p-format as character no-undo .
define input parameter dim     as character no-undo .
define input-output parameter p-rec as recid no-undo .
define output parameter P-LENGTH as integer no-undo .
define output parameter P-NUM-CLMN as integer no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Выбор шаблона печати".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/showinf.i }
{ gbl/prtmpldt.i }
{ gbl/getcntxt.i def }

DEFINE VARIABLE kl AS INTEGER INITIAL 0.
define variable MethodReturn AS LOGICAL.

define variable ID AS RECID.
define variable IDENT AS RECID.
define variable c-title as character no-undo .

define variable ii as integer no-undo.
define variable rec as recid no-undo.
define variable v-length as integer no-undo.
define variable v-num-clmn as integer no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME DIALOG-1
&Scoped-define BROWSE-NAME BR-sel-fields

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES t-f ubflt.filter

/* Definitions for BROWSE BR-sel-fields                                 */
&Scoped-define FIELDS-IN-QUERY-BR-sel-fields t-f.field-label t-f.field-size
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-sel-fields
&Scoped-define FIELD-PAIRS-IN-QUERY-BR-sel-fields
&Scoped-define SELF-NAME BR-sel-fields
&Scoped-define OPEN-QUERY-BR-sel-fields OPEN QUERY {&SELF-NAME} FOR EACH t-f no-lock.
&Scoped-define TABLES-IN-QUERY-BR-sel-fields t-f
&Scoped-define FIRST-TABLE-IN-QUERY-BR-sel-fields t-f


/* Definitions for BROWSE BROWSER-1                                     */
&Scoped-define FIELDS-IN-QUERY-BROWSER-1 ubflt.filter.Naim
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSER-1
&Scoped-define FIELD-PAIRS-IN-QUERY-BROWSER-1
&Scoped-define OPEN-QUERY-BROWSER-1 OPEN QUERY BROWSER-1 FOR EACH ubflt.filter ~
      WHERE ubflt.filter.call-point = c-point NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BROWSER-1 ubflt.filter
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSER-1 ubflt.filter


/* Definitions for DIALOG-BOX DIALOG-1                                  */
&Scoped-define OPEN-BROWSERS-IN-QUERY-DIALOG-1 ~
    ~{&OPEN-QUERY-BROWSER-1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_Cancel Btn_OK btn-exit b-help BROWSER-1 ~
BR-sel-fields btn-add btn-del btn-update
&Scoped-Define DISPLAYED-OBJECTS flt-name f-num-clmn f-length

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь":L
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON btn-add
     LABEL "&Добавить":L
     SIZE 8.75 BY 1.17 TOOLTIP "Добавить новый шаблон".

DEFINE BUTTON btn-del
     LABEL "&Удалить":L
     SIZE 8.75 BY 1.17 TOOLTIP "Удалить ранее существующий шаблон".

DEFINE BUTTON btn-exit AUTO-GO
     LABEL "&Отменить":L
     SIZE 10 BY 1 TOOLTIP "Отменить действие установок шаблона".

DEFINE BUTTON btn-update
     LABEL "&Изменить":L
     SIZE 9 BY 1.17 TOOLTIP "Изменить установки выбранного шаблона".

DEFINE BUTTON Btn_Cancel AUTO-END-KEY DEFAULT
     LABEL "&Выход "
     SIZE 10 BY 1 TOOLTIP "Выход без изменений"
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO DEFAULT
     LABEL "&Применить":L
     SIZE 10 BY 1 TOOLTIP "Применить установки выбранного шаблона"
     BGCOLOR 8 .

DEFINE VARIABLE f-length AS CHARACTER FORMAT "X(5)":U
     VIEW-AS FILL-IN
     SIZE 9.13 BY 1 NO-UNDO.

DEFINE VARIABLE f-num-clmn AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 6.13 BY 1 NO-UNDO.

DEFINE VARIABLE flt-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 97.88 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-sel-fields FOR
      t-f SCROLLING.

DEFINE QUERY BROWSER-1 FOR
      ubflt.filter SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-sel-fields
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-sel-fields DIALOG-1 _FREEFORM
  QUERY BR-sel-fields DISPLAY
      t-f.field-label format "X(30)" column-label "Название поля"
t-f.field-size format "X(5)" column-label "Длина"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 38.88 BY 13.71.

DEFINE BROWSE BROWSER-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSER-1 DIALOG-1 _STRUCTURED
  QUERY BROWSER-1 NO-LOCK DISPLAY
      ubflt.filter.Naim COLUMN-LABEL "Имя шаблона"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 48.5 BY 13.75.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DIALOG-1
     Btn_Cancel AT ROW 1 COL 1
     Btn_OK AT ROW 1 COL 11
     btn-exit AT ROW 1 COL 21
     b-help AT ROW 1 COL 61
     flt-name AT ROW 2.54 COL 1 NO-LABEL
     f-num-clmn AT ROW 3.63 COL 90.63 COLON-ALIGNED NO-LABEL
     f-length AT ROW 3.75 COL 67.88 COLON-ALIGNED NO-LABEL
     BROWSER-1 AT ROW 6.08 COL 1
     BR-sel-fields AT ROW 6.08 COL 60.13
     btn-add AT ROW 6.17 COL 50.13
     btn-del AT ROW 7.67 COL 50.13
     btn-update AT ROW 9.17 COL 50.13
     "Кол-во полей" VIEW-AS TEXT
          SIZE 12.5 BY .67 AT ROW 3.83 COL 79.88
          BGCOLOR 1 FGCOLOR 15
     "Длина шаблона" VIEW-AS TEXT
          SIZE 14.5 BY .67 AT ROW 3.92 COL 54.5
          BGCOLOR 1 FGCOLOR 15
     "Список шаблонов" VIEW-AS TEXT
          SIZE 48.63 BY .67 AT ROW 5.04 COL 1
          BGCOLOR 1 FGCOLOR 15
     "Список полей" VIEW-AS TEXT
          SIZE 39.25 BY .67 AT ROW 5.04 COL 59.75
          BGCOLOR 1 FGCOLOR 15
     SPACE(0.74) SKIP(14.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Шаблоны печати":L
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
/* BROWSE-TAB BROWSER-1 f-length DIALOG-1 */
/* BROWSE-TAB BR-sel-fields BROWSER-1 DIALOG-1 */
ASSIGN
       FRAME DIALOG-1:SCROLLABLE       = FALSE.

/* SETTINGS FOR BUTTON btn-add IN FRAME DIALOG-1
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON btn-del IN FRAME DIALOG-1
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON btn-exit IN FRAME DIALOG-1
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON btn-update IN FRAME DIALOG-1
   NO-DISPLAY                                                           */
/* SETTINGS FOR FILL-IN f-length IN FRAME DIALOG-1
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-num-clmn IN FRAME DIALOG-1
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN flt-name IN FRAME DIALOG-1
   NO-ENABLE ALIGN-L                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-sel-fields
/* Query rebuild information for BROWSE BR-sel-fields
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH t-f no-lock.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-sel-fields */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSER-1
/* Query rebuild information for BROWSE BROWSER-1
     _TblList          = "ubflt.filter"
     _Options          = "NO-LOCK"
     _Where[1]         = "ubflt.filter.call-point = c-point"
     _FldNameList[1]   > ubflt.filter.Naim
"ubflt.filter.Naim" "Имя шаблона" ? "character" ? ? ? ? ? ? no ?
     _Query            is OPENED
*/  /* BROWSE BROWSER-1 */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define BROWSE-NAME BROWSER-1
&Scoped-define SELF-NAME BROWSER-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSER-1 DIALOG-1
ON MOUSE-SELECT-DBLCLICK OF BROWSER-1 IN FRAME DIALOG-1
DO:
apply "choose" to  btn_ok.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSER-1 DIALOG-1
ON RETURN OF BROWSER-1 IN FRAME DIALOG-1
DO:
apply "choose" to  btn_ok.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSER-1 DIALOG-1
ON VALUE-CHANGED OF BROWSER-1 IN FRAME DIALOG-1
DO:
 IF AVAILABLE(ubflt.filter) THEN DO:
    flt-name = ubflt.filter.naim.
    Kl = ubflt.filter.Num-flt.

    assign
        v-num-clmn = num-entries(ubflt.filter.fields-sort)
        v-length = 0
        .
    run fill-table in this-procedure.
    IDENT = RECID(ubflt.filter).
    DISPLAY
    flt-name
      string(v-length, ">>>>9") @ f-length
    string(v-num-clmn, ">>9") @ f-num-clmn
    with frame {&frame-name}.

  END.
  ELSE do:
    run fill-table in this-procedure.
    display
    "":U @ f-length
    "":U @ f-num-clmn
    with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-add DIALOG-1
ON CHOOSE OF btn-add IN FRAME DIALOG-1 /* Добавить */
DO:
  Kl = 0.
  run gbl/updprint.w (c-point,Tbl,Buf,Fld,Lab,Spr,p-size,p-format,Dim,Kl,OUTPUT ID, OUTPUT P-LENGTH, OUTPUT P-NUM-CLMN).
  IF ID = ? THEN ID = IDENT.
  RUN enable_UI.
  REPOSITION BROWSER-1 TO RECID id no-error.
  APPLY "ITERATION-CHANGED" TO BROWSER-1.
  apply "entry" to browser-1.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-del DIALOG-1
ON CHOOSE OF btn-del IN FRAME DIALOG-1 /* Удалить */
do:
define variable v-flt-rec as recid no-undo .
do on stop  undo, return:
  if available ubflt.filter then do:
     flt-name = "".
       get prev browser-1.
     if not available ubflt.filter then do:
        get first browser-1.
        get next browser-1.
        end.
     v-flt-rec = recid(ubflt.filter).
     FIND FIRST ubflt.filter WHERE ubflt.filter.Num-flt = Kl EXCLUSIVE-LOCK NO-ERROR.
     DELETE ubflt.filter.
     find ubflt.filter where recid(ubflt.filter) = v-flt-rec no-lock no-error.
     RUN enable_UI.
     REPOSITION BROWSER-1 TO RECID v-flt-rec no-error.
     APPLY "VALUE-CHANGED" TO BROWSER-1.
     apply "entry" to browser-1.
     END.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-exit DIALOG-1
ON CHOOSE OF btn-exit IN FRAME DIALOG-1 /* Отменить */
DO:
   p-rec = ?.
   find ubflt.usr-flt where ubflt.usr-flt.user-name = v-cntxt-userid
                        and ubflt.usr-flt.call-point = ubflt.filter.call-point
                        no-error.
   if available ubflt.usr-flt then delete ubflt.usr-flt.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn-update
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-update DIALOG-1
ON CHOOSE OF btn-update IN FRAME DIALOG-1 /* Изменить */
DO:
  FIND FIRST ubflt.filter WHERE ubflt.filter.Num-flt = Kl EXCLUSIVE-LOCK NO-ERROR no-wait.
  IF AVAILABLE(ubflt.filter) THEN DO:
     Kl = ubflt.filter.Num-flt.
     run gbl/updprint.w  (c-point,Tbl,Buf,Fld,Lab,Spr,p-size,p-format,Dim,Kl,output ID, OUTPUT P-LENGTH, OUTPUT P-NUM-CLMN).
     IF ID = ? THEN ID = IDENT.
     RUN enable_UI.
     REPOSITION BROWSER-1 TO RECID id no-error.
     APPLY "ITERATION-CHANGED" TO BROWSER-1.
     apply "entry" to browser-1.
     END.
   else
     if locked ubflt.filter then
        message 'Шаблон в данный момент корректируется другим пользователем'.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_Cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_Cancel DIALOG-1
ON CHOOSE OF Btn_Cancel IN FRAME DIALOG-1 /* Выход  */
DO:
     p-rec = ?.
     return  "undo".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK DIALOG-1
ON CHOOSE OF Btn_OK IN FRAME DIALOG-1 /* Применить */
DO:
if available ubflt.filter  then do:
   p-rec = recid(ubflt.filter).
   find ubflt.usr-flt where ubflt.usr-flt.user-name = v-cntxt-userid
                        and ubflt.usr-flt.call-point = ubflt.filter.call-point
                        no-error.
   if not available ubflt.usr-flt then create ubflt.usr-flt.
   assign
   ubflt.usr-flt.user-name = v-cntxt-userid
   ubflt.usr-flt.call-point    = ubflt.filter.call-point
   ubflt.usr-flt.naim = ubflt.filter.naim.
   end.
else p-rec = ?.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-sel-fields
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
on end-error, stop of frame {&frame-name} do:
     p-rec = ?.
     return "undo":u.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  if num-entries(c-point, {&delim-par}) > 2 then do:
    c-title = entry(3, c-point, {&delim-par} ).
    c-point = entry(1, c-point, {&delim-par} ) + {&delim-par} +  entry(2, c-point, {&delim-par} ).
  end.
  else do:
    c-title = entry(1, c-point, {&delim-par} ).
  end.
  assign frame {&frame-name}:title = substitute("Ш А Б Л О Н Ы   П Е Ч А Т И    (&1)", c-title).
  RUN enable_UI in this-procedure .
  if lookup(bttn, "btn-exit":U) = 0 then do:
    hide
    btn-exit
    in frame {&frame-name}.
  end.
  reposition browser-1 to recid p-rec no-error.
  apply "value-changed" to browser-1 in frame {&frame-name}.
  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus browser-1.
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
  DISPLAY flt-name f-num-clmn f-length
      WITH FRAME DIALOG-1.
  ENABLE Btn_Cancel Btn_OK btn-exit b-help BROWSER-1 BR-sel-fields btn-add
         btn-del btn-update
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
define variable ii as integer no-undo.
for each t-f :
    delete t-f.
end.
if available ubflt.filter then do:
  assign
        v-num-clmn = num-entries(ubflt.filter.fields-sort)
        v-length = 0
        .
    do ii = 1 to v-num-clmn:
        create t-f.
        assign
        t-f.field-name = string(ii)
        t-f.field-label = entry(ii,ubflt.filter.fields-sort-rus)
        t-f.field-size = entry(ii,ubflt.filter.where-ysl)
       v-length = v-length + integer(entry(ii, ubflt.filter.Where-ysl))
        .
    end.
end.
OPEN QUERY br-sel-fields FOR EACH t-f no-lock.
APPLY "ENTRY" to BROWSER-1 in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME