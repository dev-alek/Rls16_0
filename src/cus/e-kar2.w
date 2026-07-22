&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS F-Frame-Win
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

утилита по запросу Каравана - 2
выкидывает все чеки в которых содержится товар из списка в количестве >= заданному

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/18/05
Author: Bakhtadze Natalya
Creation date: 10/18/05

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "утилита по запросу Каравана - 2" .
{ cmp/vssrevis.i }

/* Local Variable Definitions ---                                       */
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/r-page1.i }
{ cmp/r-pril.i new }
{ cmp/operlist.i }
{ gbl/waitfram.i }


DEFINE STREAm PrnLibStream.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER FRAME

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 my-qnty choice RS-method text-5
&Scoped-Define DISPLAYED-OBJECTS my-qnty choice RS-method text-5

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE my-qnty AS DECIMAL FORMAT "->>,>>9.999":U INITIAL 0
     LABEL "Кол-во товара в строке чека >="
     VIEW-AS FILL-IN
     SIZE 11.75 BY 1 NO-UNDO.

DEFINE VARIABLE text-5 AS CHARACTER FORMAT "X(256)":U INITIAL "Потоварный вывод"
      VIEW-AS TEXT
     SIZE 18.38 BY 1 NO-UNDO.

DEFINE VARIABLE RS-method AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Включенные в отчет о продаже", 1,
"Не включенные в отчет о продаже", 2,
"Все чеки", 3
     SIZE 34.5 BY 2.79 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 38.25 BY 5.04.

DEFINE VARIABLE choice AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     my-qnty AT ROW 1.79 COL 32.5 COLON-ALIGNED
     choice AT ROW 3.42 COL 34
     RS-method AT ROW 7.58 COL 3.38 NO-LABEL
     text-5 AT ROW 3.54 COL 12.38 COLON-ALIGNED NO-LABEL
     "Чеки" VIEW-AS TEXT
          SIZE 16.38 BY .88 AT ROW 6.58 COL 3.88
          FGCOLOR 4
     "а не только  чеки" VIEW-AS TEXT
          SIZE 18.38 BY 1 AT ROW 4.5 COL 14.38
     RECT-1 AT ROW 5.96 COL 2.25
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 54.5 BY 11.83.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,Browse,DB-Fields,Smart,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW F-Frame-Win ASSIGN
         HEIGHT             = 11.83
         WIDTH              = 54.5.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB F-Frame-Win
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW F-Frame-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE                                                          */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = ""
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK F-Frame-Win


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
   /* Now enable the interface  if in test mode - otherwise this happens when
      the object is explicitly initialized from its container. */
   RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects F-Frame-Win  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available F-Frame-Win  _ADM-ROW-AVAILABLE
PROCEDURE adm-row-available :
/*------------------------------------------------------------------------------
  Purpose:     Dispatched to this procedure when the Record-
               Source has a new row available.  This procedure
               tries to get the new row (or foriegn keys) from
               the Record-Source and process it.
  Parameters:  <none>
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.             */
  {src/adm/template/row-head.i}

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI F-Frame-Win  _DEFAULT-DISABLE
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
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI F-Frame-Win  _DEFAULT-ENABLE
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
  DISPLAY my-qnty choice RS-method text-5
      WITH FRAME F-Main.
  ENABLE RECT-1 my-qnty choice RS-method text-5
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-report F-Frame-Win
PROCEDURE My-report :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable g#log as logical no-undo .
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_goods for ub.goods.
define buffer buf_bar-code for ub.bar-code.

run My-var.
if X-selectGood = {&g-choice} and not can-find(first gds-list no-lock) then do:
    g#log = no.
    message "Не выбрано ни одного товара" view-as alert-box ERROR.
    return no-apply.
end.

{ cmp/open-exp.i stream PrnLibStream}

put stream PrnLibStream unformatted
ReportName skip
str1 skip
str4 skip
ReportHeader skip
str2
skip.
if choice then
put stream PrnLibStream unformatted
    "N чека" {&tabulation}
    "Дата чека" {&tabulation}
    "N кассы" {&tabulation}
    "Кассир" {&tabulation}
    "Бар-код" {&tabulation} {&tabulation}
    "Кол-во" {&tabulation}
    {&Article} format "X(16)" {&tabulation}
    "Цена(брутто)" {&tabulation}
    "Скидка" {&tabulation}
    "Сумма_нетто" {&tabulation}
    "Произ-ль" {&tabulation}
    {&name}
    skip.

else
put stream PrnLibStream unformatted
    "N чека" {&tabulation}
    "Дата чека" {&tabulation}
    "N кассы" {&tabulation}
    "Кассир" {&tabulation}
    skip.

run waitfram-show in this-procedure ("Обработано чеков 0").
FOR EACH obj-list No-LOCK:
_chk-gds:
for each buf_chk-doc where buf_chk-doc.chk-date >= X-date-start and
          buf_chk-doc.chk-date <= X-date-end and
          buf_chk-doc.obj-code = obj-list.obj-code AND
          buf_chk-doc.obj-type = obj-list.obj-type no-lock:
    if lookup(string(buf_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-gds.
    accumulate buf_chk-doc.doc-code (COUNT).
    if  (accum COUNT buf_chk-doc.doc-code ) modulo 10  = 0 then do:
      run waitfram-show in this-procedure ("Обработано чеков " + string(accum count buf_chk-doc.doc-code)).
    end.
    IF RS-method = 1 and buf_chk-doc.out-code = ? then NEXT _chk-gds.
    IF RS-method = 2 and buf_chk-doc.out-code <> ? then NEXT _chk-gds.


    FOR EACH buf_chk-gds No-LOCK WHERE
             buf_chk-gds.doc-code = buf_chk-doc.doc-code AND
             buf_chk-gds.doc-qnty >= my-qnty,
        FIRST buf_bar-code No-LOCK WHERE
              buf_bar-code.b-code = buf_chk-gds.b-code,
        FIRST buf_goods NO-LOCK WHERE buf_goods.gds-code = buf_bar-code.gds-code:
        if X-SelectGood = {&g-choice} AND
        NOT can-FIND (FIRST gds-list where
                            gds-list.artic = buf_goods.artic AND
                            gds-list.Prod-type = buf_goods.prod-type AND
                            gds-list.Prod-code = buf_goods.prod-code) then NEXT.


        if choice = yes then do:
            put stream PrnLibStream unformatted
            buf_chk-doc.doc-code {&tabulation}
            buf_chk-doc.chk-date FORMAT "99/99/9999" {&tabulation}
            buf_chk-doc.pay-desk {&tabulation}
            buf_chk-doc.cashier {&tabulation}
            string(buf_chk-gds.b-code) FORMAT "X(10)" {&tabulation}
            buf_chk-gds.doc-qnty {&tabulation}
            (if X-selectgood = {&g-all} then buf_goods.artic else gds-list.artic ) format "x(16)" {&tabulation}
            buf_chk-gds.price-base {&tabulation}
            buf_chk-gds.discnt {&tabulation}
            (buf_chk-gds.price-base - buf_chk-gds.discnt) * buf_chk-gds.doc-qnty {&tabulation}
            (if X-selectgood = {&g-all}
             then string(buf_goods.prod-type + " " + string(buf_goods.prod-code, "999999999"))
             else string(gds-list.prod-type + " " + string(gds-list.prod-code, "999999999"))
            ) {&tabulation}
           (if X-selectgood = {&g-all}
            then buf_goods.gds-name
            else gds-list.gds-name)
            skip.
        end.
        else do:
            put stream PrnLibStream unformatted
            buf_chk-doc.doc-code {&tabulation}
            buf_chk-doc.chk-date FORMAT "99/99/9999" {&tabulation}
            buf_chk-doc.pay-desk {&tabulation}
            buf_chk-doc.cashier
            skip.
            LEAVE.
        end.
    END.
end.
END.
run waitfram-hide in this-procedure .

{ cmp/cls-exp.i stream PrnLibStream}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-var F-Frame-Win
PROCEDURE My-var :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
ASSIGN
frame {&frame-name} choice
frame {&frame-name} my-qnty
frame {&frame-name} RS-method
.

ASSIGN
ReportName = "Чеки с товаром, количество которого превышает заданное"
ReportHeader = my-qnty:label +  string(my-qnty) + {&new-line} +
               radio-label(string(RS-method), RS-method:radio-buttons) + {&new-line} +
               if choice then Text-5 else "".



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records F-Frame-Win  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* SEND-RECORDS does nothing because there are no External
     Tables specified for this SmartObject, and there are no
     tables specified in any contained Browse, Query, or Frame. */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed F-Frame-Win
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME