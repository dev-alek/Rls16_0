&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-add-tax-rate


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-tax-rate NO-UNDO LIKE ub.tax-rate.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-add-tax-rate
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка ставки налога

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/05/06
Author: Bakhtadze Natalya
Creation date: 04/05/06

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
def input parameter ref-mode as char no-undo.
def input-output param rid as recid no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Карточка ставки налога" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }

define variable taxcode like ub.tax.tax-code no-undo.
define buffer buf_tax-rate-attr for ub.tax-rate-attr .
define VARIABLE v-envd-old as LOGICAL NO-UNDO .
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-add-tax-rate

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-tax-rate

/* Definitions for DIALOG-BOX d-add-tax-rate                            */
&Scoped-define QUERY-STRING-d-add-tax-rate FOR EACH tt-tax-rate SHARE-LOCK
&Scoped-define OPEN-QUERY-d-add-tax-rate OPEN QUERY d-add-tax-rate FOR EACH tt-tax-rate SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-d-add-tax-rate tt-tax-rate
&Scoped-define FIRST-TABLE-IN-QUERY-d-add-tax-rate tt-tax-rate


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-tax-rate.rate-code tt-tax-rate.rate-name
&Scoped-define ENABLED-TABLES tt-tax-rate
&Scoped-define FIRST-ENABLED-TABLE tt-tax-rate
&Scoped-Define ENABLED-OBJECTS b-exit b-quit B-help T-envd 
&Scoped-Define DISPLAYED-FIELDS tt-tax-rate.tax-code tt-tax-rate.rate-code ~
tt-tax-rate.rate-name
&Scoped-define DISPLAYED-TABLES tt-tax-rate
&Scoped-define FIRST-DISPLAYED-TABLE tt-tax-rate


/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод "
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-help 
     LABEL "Помо&щь" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE T-envd AS LOGICAL INITIAL no 
     LABEL "без НДС" 
     VIEW-AS TOGGLE-BOX
     SIZE 11.13 BY .83 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY d-add-tax-rate FOR
      tt-tax-rate SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-add-tax-rate
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-help AT ROW 1 COL 40
     T-envd AT ROW 3.08 COL 42 WIDGET-ID 2
     tt-tax-rate.tax-code AT ROW 3.13 COL 21.88 COLON-ALIGNED
          LABEL "Код вида налога"
          VIEW-AS FILL-IN
          SIZE 7 BY 1
     tt-tax-rate.rate-code AT ROW 4.42 COL 21.88 COLON-ALIGNED
          LABEL "Код ставки налога" FORMAT ">>>>>9"
          VIEW-AS FILL-IN 
          SIZE 9.88 BY 1
     tt-tax-rate.rate-name AT ROW 5.71 COL 21.88 COLON-ALIGNED
          LABEL "Название ставки"
          VIEW-AS FILL-IN
          SIZE 30.5 BY 1
     SPACE(0.99) SKIP(1.36)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Ставка налога"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt-tax-rate T "?" NO-UNDO ub tax-rate
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-add-tax-rate
   FRAME-NAME                                                           */
ASSIGN
       FRAME d-add-tax-rate:SCROLLABLE       = FALSE
       FRAME d-add-tax-rate:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tt-tax-rate.rate-code IN FRAME d-add-tax-rate
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-tax-rate.rate-name IN FRAME d-add-tax-rate
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-tax-rate.tax-code IN FRAME d-add-tax-rate
   NO-ENABLE EXP-LABEL                                                  */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-add-tax-rate
/* Query rebuild information for DIALOG-BOX d-add-tax-rate
     _TblList          = "tt-tax-rate"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX d-add-tax-rate */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-add-tax-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-add-tax-rate d-add-tax-rate
ON GO OF FRAME d-add-tax-rate /* Ставка налога */
DO:
  find first tt-tax-rate No-ERROR.
 if not avail tt-tax-rate then create tt-tax-rate.
 assign
 tt-tax-rate.rate-code
 tt-tax-rate.rate-name
 tt-tax-rate.tax-code
 .
 if v-envd-old <> t-envd then do:
     find first buf_tax-rate-attr where buf_tax-rate-attr.tax-code = tt-tax-rate.tax-code
                                    and buf_tax-rate-attr.attr-code = "envd" no-error .
        if AVAILABLE buf_tax-rate-attr then do:
                 if t-envd then do:
                     MESSAGE SUBSTITUTE ("У кода ставки налога &1, уже есть атрибут без НДС", buf_tax-rate-attr.rate-code)
                     VIEW-AS ALERT-BOX.
                 end.
                 else do:
                    delete buf_tax-rate-attr.
                 end. 
        end.  
        else do:

                     create buf_tax-rate-attr .
                     assign
                        buf_tax-rate-attr.tax-code = tt-tax-rate.tax-code
                        buf_tax-rate-attr.attr-code = "envd"
                        buf_tax-rate-attr.rate-code = tt-tax-rate.rate-code
                     .
        end.                                 
 
  end.       
 run ref/taxrati1.p
 ( input-output rid
 , input ref-mode
 , input no /* p-silent */
 , input taxcode
 , input tt-tax-rate.rate-code
 , input tt-tax-rate.rate-name
 , input tt-tax-rate.status_
 ) no-error.
  if error-status:error then do:
        if return-value = "":U then return no-apply.
    case return-value:
            when "rate-name":U then do:
                APPLY "ENTRY" to tt-tax-rate.rate-name.
            end.
            when "rate-code":U then do:
                 APPLY "ENTRY" to tt-tax-rate.rate-code.
            end.
        end.
    return no-apply.
  end.

 END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-add-tax-rate d-add-tax-rate
ON WINDOW-CLOSE OF FRAME d-add-tax-rate /* Ставка налога */
DO:
  rid = ?.
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit d-add-tax-rate
ON CHOOSE OF b-quit IN FRAME d-add-tax-rate /* Отмена */
DO:
  rid = ?.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-envd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-envd d-add-tax-rate
ON VALUE-CHANGED OF T-envd IN FRAME d-add-tax-rate /* ЕНВД */
DO:
    IF T-envd:checked then do:
            assign T-envd 
            .
     end.        
     else t-envd = no.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-add-tax-rate


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
if ref-mode <> {&update} and ref-mode <> {&add-def} then do:
        message vss-workfile vss-revision vss-description skip
                    "Неверный параметр вызова ref-mode"
        view-as alert-box ERROR.
        return error.
    end.
  IF ref-mode = {&add-def} then do:
    FIND FIRST ub.tax Exclusive-LOCK WHERE recid(ub.tax) = rid No-WAIT no-error.
    if locked tax then do:
      message vss-workfile vss-revision vss-description skip
              "Запись налога занята"
      view-as alert-box error .
      return error.
    end.
    IF NOT AVAIL tax then do:
      message vss-workfile vss-revision vss-description skip
              "Запись налога не найдена"
      view-as alert-box error .
      return error.
    end.
    assign
    taxcode =  tax.tax-code.
  end.
  else do:
    FIND FIRST ub.tax-rate EXclusive-lock WHERE recid(ub.tax-rate) = rid no-wait no-error .
    if locked ub.tax-rate then do:
      message vss-workfile vss-revision vss-description skip
              "Запись ставки налога занята"
      view-as alert-box error .
      return error.
    end.
    IF NOT AVAIL tax-rate then do:
      message vss-workfile vss-revision vss-description skip
              "Запись ставки налога не найдена"
      view-as alert-box error .
      return error.
    end.
    if tax-rate.status_ = {&deleted-status} then do:
      message "Ставка удалена - изменение невозможно"
      view-as alert-box ERROR.
      return error.
    end.
    for each tt-tax-rate:
            delete tt-tax-rate.
        end.
        create tt-tax-rate.
        buffer-copy tax-rate to tt-tax-rate.
  end.
  RUN MyEnable.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-add-tax-rate  _DEFAULT-DISABLE
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
  HIDE FRAME d-add-tax-rate.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-add-tax-rate  _DEFAULT-ENABLE
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

  {&OPEN-QUERY-d-add-tax-rate}
  GET FIRST d-add-tax-rate.
  DISPLAY T-envd 
      WITH FRAME d-add-tax-rate.
  IF AVAILABLE tt-tax-rate THEN 
    DISPLAY tt-tax-rate.tax-code tt-tax-rate.rate-code tt-tax-rate.rate-name 
      WITH FRAME d-add-tax-rate.
  ENABLE b-exit b-quit B-help T-envd tt-tax-rate.rate-code 
         tt-tax-rate.rate-name 
      WITH FRAME d-add-tax-rate.
  VIEW FRAME d-add-tax-rate.
  {&OPEN-BROWSERS-IN-QUERY-d-add-tax-rate}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable d-add-tax-rate
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  IF AVAILABLE tt-tax-rate THEN
    DISPLAY
    tt-tax-rate.tax-code
    tt-tax-rate.rate-code
    tt-tax-rate.rate-name
    WITH FRAME D-add-tax-rate.
  find first buf_tax-rate-attr where buf_tax-rate-attr.tax-code = tt-tax-rate.tax-code
                                    and buf_tax-rate-attr.rate-code = tt-tax-rate.rate-code
                                    and buf_tax-rate-attr.attr-code = "envd" no-error .
    if AVAILABLE buf_tax-rate-attr then do:
     T-envd = yes.
     v-envd-old = yes.
    end.    
    
  ENABLE
  B-exit
  B-quit
  B-Help
  tt-tax-rate.rate-name
  T-envd
  WITH FRAME D-add-tax-rate.
  VIEW FRAME D-add-tax-rate.
  display t-envd with frame {&FRAME-NAME}.
  ENABLE
  tt-tax-rate.rate-code when ref-mode = {&add-def}
  WITH FRAME {&frame-name}.
  IF ref-mode = {&update} then do:
      FRAME {&frame-name}:title = "Изменение ставки налога".
      DISPLAY
      tt-tax-rate.tax-code
      tt-tax-rate.rate-code
      tt-tax-rate.rate-name
      WITH frame {&frame-name}.
  END.
  ELSE do:
    DISPLAY
    taxcode @ tt-tax-rate.tax-code
    WITH frame {&frame-name}.
  END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
