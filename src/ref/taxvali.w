&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_tax-rate FOR ub.tax-rate.
DEFINE TEMP-TABLE tt-tax-rate-value NO-UNDO LIKE ub.tax-rate-value.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка значения ставки налога

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/05/06
Author: Bakhtadze Natalya
Creation date: 04/05/06

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
def input parameter ref-mode as char no-undo.
define input parameter parhost-code like ub.sysconf.host-code no-undo.
define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.clients.obj-code no-undo.
def input-output param rid as recid init ? no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Карточка значения ставки налога" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }

define variable taxcode like ub.tax.tax-code no-undo.
define variable ratecode like ub.tax-rate.rate-code no-undo.
/*работа с региональными налогами*/

define buffer b-objects for ub.clients.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-tax-rate-value

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-tax-rate-value SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-tax-rate-value
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-tax-rate-value


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-tax-rate-value.rate-value ~
tt-tax-rate-value.fact-date tt-tax-rate-value.host-code ~
tt-tax-rate-value.obj-type tt-tax-rate-value.obj-code
&Scoped-define FIELD-PAIRS~
 ~{&FP1}rate-value ~{&FP2}rate-value ~{&FP3}~
 ~{&FP1}fact-date ~{&FP2}fact-date ~{&FP3}~
 ~{&FP1}host-code ~{&FP2}host-code ~{&FP3}~
 ~{&FP1}obj-type ~{&FP2}obj-type ~{&FP3}~
 ~{&FP1}obj-code ~{&FP2}obj-code ~{&FP3}
&Scoped-define ENABLED-TABLES tt-tax-rate-value
&Scoped-define FIRST-ENABLED-TABLE tt-tax-rate-value
&Scoped-Define ENABLED-OBJECTS B-exit RECT-region B-quit B-help var-region ~
host-name for-obj-name
&Scoped-Define DISPLAYED-FIELDS tt-tax-rate-value.rate-value ~
tt-tax-rate-value.fact-date tt-tax-rate-value.host-code ~
tt-tax-rate-value.obj-type tt-tax-rate-value.obj-code
&Scoped-Define DISPLAYED-OBJECTS var-region host-name for-obj-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод "
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE for-obj-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 37.88 BY 1 NO-UNDO.

DEFINE VARIABLE host-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 51.5 BY 1 NO-UNDO.

DEFINE VARIABLE var-region AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 24 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-region
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 72 BY 6.46.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-tax-rate-value SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-help AT ROW 1 COL 41
     tt-tax-rate-value.rate-value AT ROW 3.04 COL 10.75 COLON-ALIGNED
          LABEL "Значение"
          VIEW-AS FILL-IN
          SIZE 14.25 BY 1
     tt-tax-rate-value.fact-date AT ROW 4.92 COL 22.88 COLON-ALIGNED
          LABEL "Дата начала действия"
          VIEW-AS FILL-IN
          SIZE 10.75 BY 1
     var-region AT ROW 7 COL 19.25 COLON-ALIGNED NO-LABEL
     host-name AT ROW 8.58 COL 18.88 COLON-ALIGNED NO-LABEL
     tt-tax-rate-value.host-code AT ROW 8.63 COL 1.75 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 9 BY 1
     tt-tax-rate-value.obj-type AT ROW 11.04 COL 1.5 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 6.13 BY 1
     tt-tax-rate-value.obj-code AT ROW 11.04 COL 8.63 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 10.63 BY 1
     for-obj-name AT ROW 11.08 COL 20.63 COLON-ALIGNED NO-LABEL
     "Область действия:" VIEW-AS TEXT
          SIZE 16.63 BY 1 AT ROW 7 COL 3.25
          FGCOLOR 4
     RECT-region AT ROW 6.33 COL 2
     SPACE(1.99) SKIP(0.95)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Ввод значения ставки налога"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_tax-rate B "?" ? ub tax-rate
      TABLE: tt-tax-rate-value T "?" NO-UNDO ub tax-rate-value
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tt-tax-rate-value.fact-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-tax-rate-value.host-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-tax-rate-value.obj-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-tax-rate-value.obj-type IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-tax-rate-value.rate-value IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "tt-tax-rate-value"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Ввод значения ставки налога */
DO:

 find first tt-tax-rate-value No-ERROR.
 if not avail tt-tax-rate-value then create tt-tax-rate-value.

 assign
 tt-tax-rate-value.rate-value
 tt-tax-rate-value.host-code
 tt-tax-rate-value.obj-type
 tt-tax-rate-value.obj-code
 tt-tax-rate-value.fact-date
 .
 run ref/taxvali1.p ( input-output rid
                    , input ref-mode
                    , input no /* p-silent */
                    , input taxcode
                    , input ratecode
                    , input tt-tax-rate-value.rate-value
                    , input tt-tax-rate-value.fact-date
                    , input tt-tax-rate-value.host-code
                    , input tt-tax-rate-value.obj-type
                    , input tt-tax-rate-value.obj-code
                    , input (if tt-tax-rate-value.status_ = "":U then {&current-status} else tt-tax-rate-value.status_ )
                    ) no-error.
  if error-status:error then do:
        if return-value = "":U then return no-apply.
    case return-value:
            when "rate-value":U then do:
                APPLY "ENTRY" to tt-tax-rate-value.rate-value.
            end.
            when "fact-date":U then do:
                 APPLY "ENTRY" to tt-tax-rate-value.fact-date.
            end.
             when "host-code":U then do:
                 APPLY "ENTRY" to tt-tax-rate-value.host-code.
            end.
             when "obj-type":U then do:
                 APPLY "ENTRY" to tt-tax-rate-value.obj-type.
            end.
             when "obj-code":U then do:
                 APPLY "ENTRY" to tt-tax-rate-value.obj-code.
            end.
        end.
  end.



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Ввод значения ставки налога */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-quit Dialog-Frame
ON CHOOSE OF B-quit IN FRAME Dialog-Frame /* Отказ */
DO:
  rid = ?.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-tax-rate-value.fact-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-tax-rate-value.fact-date Dialog-Frame
ON LEAVE OF tt-tax-rate-value.fact-date IN FRAME Dialog-Frame /* Дата начала действия */
DO:
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
run cur-time in this-procedure(output v-today, output v-time).
  if date(tt-tax-rate-value.fact-date:screen-value) < v-today then do:
    Bell.
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }
{ gbl/ed_date.i tt-tax-rate-value.fact-date }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    if ref-mode <> {&add-def} then do:
        message vss-workfile vss-revision vss-description skip
                    "Неверный параметр вызова ref-mode"
        view-as alert-box ERROR.
        return error.
    end.
    if (parhost-code = 0 and
           (parobj-type <> "":U or parobj-code <> 0)) OR
           (parobj-type = "":U and parobj-code <> 0) or
           (parobj-type <> "" and  parobj-code = 0)
            then do:
            message vss-workfile vss-revision vss-description skip
                        "Неверный параметр вызова parhost-code и/или parobj-type и/или parobj-code"
            view-as alert-box ERROR.
            return error.

    end.
    for each tt-tax-rate-value:
      delete tt-tax-rate-value.
    end.
    FIND FIRST locked_tax-rate EXCLUSIVE-LOCK WHERE
          recid(locked_tax-rate) = rid No-WAIT No-ERROR.
    if locked locked_tax-rate then do:
      message vss-workfile vss-revision vss-description skip
              "Запись ставки налога занята"
              view-as alert-box error .
     return error .
    end.
    if not avail locked_tax-rate then do:
      message vss-workfile vss-revision vss-description skip
              "Запись ставки не найдена"
              view-as alert-box error .
      return error .
    end.
    assign
    taxcode =  locked_tax-rate.tax-code
    ratecode = locked_tax-rate.rate-code
    .
    var-region = "Глобально".
    if parhost-code <> 0 then do:
        find first ub.clients No-LOCK WHERE
                ub.clients.obj-type = {&cmp} and
                ub.clients.obj-code = parhost-code No-ERROR.
        var-region = "Фирма: ".
    end.
    if parobj-code <> 0 then do:
        find first b-objects No-LOCK WHERE
                b-objects.obj-type = parobj-type and
                b-objects.obj-code = parobj-code No-ERROR.
            var-region = "Объект: ".

    end.

  RUN Myenable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame _DEFAULT-DISABLE
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame _DEFAULT-ENABLE
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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY var-region host-name for-obj-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-tax-rate-value THEN
    DISPLAY tt-tax-rate-value.rate-value tt-tax-rate-value.fact-date
          tt-tax-rate-value.host-code tt-tax-rate-value.obj-type
          tt-tax-rate-value.obj-code
      WITH FRAME Dialog-Frame.
  ENABLE B-exit RECT-region B-quit B-help tt-tax-rate-value.rate-value
         tt-tax-rate-value.fact-date var-region host-name
         tt-tax-rate-value.host-code tt-tax-rate-value.obj-type
         tt-tax-rate-value.obj-code for-obj-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-lock-fact-date as logical no-undo .
define buffer first_tax-rate-value for ub.tax-rate-value.
/*проверим не первое ли это значение ставки по данному коду*/

find first first_tax-rate-value no-lock where
          first_tax-rate-value.tax-code = locked_tax-rate.tax-code
      AND first_tax-rate-value.rate-code = locked_tax-rate.rate-code no-error .
if not available first_tax-rate-value then do:
  assign
  v-lock-fact-date = yes.
end.

  ENABLE
  B-exit
  B-quit
  B-help
  tt-tax-rate-value.rate-value
  tt-tax-rate-value.fact-date when not v-lock-fact-date
  WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  FRAME {&frame-name}:title = frame {&frame-name}:title + " с кодом " +
                                string(ratecode) + " по налогу " + string(taxcode).
  if v-lock-fact-date then do:
    assign
    v-today = 01/01/1990
    .
  end.
  else do:
    run cur-time in this-procedure(output v-today, output v-time).
  end.
  DISPLAY
  var-region
     0 @ tt-tax-rate-value.rate-value
  v-today @ tt-tax-rate-value.fact-date
  WITH FRAME Dialog-Frame.
  if parhost-code > 0 then
     DISPLAY
     parhost-code FORMAT "999999999" @ tt-tax-rate-value.host-code

     (if avail ub.clients then ub.clients.obj-name else "":U) @ host-name

    WITH FRAME Dialog-Frame.

    if parobj-code <> 0 then do:
      DISPLAY
      parobj-type @ tt-tax-rate-value.obj-type
      parobj-code @ tt-tax-rate-value.obj-code
      (if avail b-objects then b-objects.obj-name else "":U) @ for-obj-name
       WITH FRAME Dialog-Frame.
 end.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME