&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME D-Dialog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS D-Dialog
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Универсальное окно для ввода месяца и года

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

Пример использовани

run gbl/d-inpmnt.w
  (input ""
  ,input ?
  ,input-output v-month
  ,input-output v-year
  ,output lok
  ).
if lok then do:

end.

*/

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input        parameter p-title    as character no-undo .
define input        parameter h-callback as handle    no-undo .
define input-output parameter p-month    as integer   no-undo .
define input-output parameter p-year     as integer   no-undo .
define output       parameter p-ok       as logical   no-undo .

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Универсальное окно для ввода месяца и года".
{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ gbl/cur-time.i }

define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartDialog

&Scoped-define ADM-CONTAINER DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME D-Dialog

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS CB-Month b-prev-month b-next-month FI-Year ~
b-prev-year b-next-year b-exit b-quit b-help fi-month-name
&Scoped-Define DISPLAYED-OBJECTS CB-Month FI-Year

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-next-month
     LABEL "&>>"
     SIZE 4 BY 1.

DEFINE BUTTON b-next-year
     LABEL "&>>"
     SIZE 4 BY 1.

DEFINE BUTTON b-prev-month
     LABEL "&<<"
     SIZE 4 BY 1.

DEFINE BUTTON b-prev-year
     LABEL "&<<"
     SIZE 4 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE CB-Month AS INTEGER FORMAT "99":U INITIAL 0
     LABEL "Месяц"
     VIEW-AS COMBO-BOX INNER-LINES 12
     LIST-ITEMS "         1","         2","         3","         4","         5","         6","         7","         8","         9","        10","        11","        12"
     SIZE 7 BY 1 NO-UNDO.

DEFINE VARIABLE fi-month-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 28.5 BY .67 NO-UNDO.

DEFINE VARIABLE FI-Year AS INTEGER FORMAT "9999":U INITIAL 0
     LABEL "Год"
     VIEW-AS FILL-IN
     SIZE 7 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME D-Dialog
     CB-Month AT ROW 1.33 COL 10.75 COLON-ALIGNED
     b-prev-month AT ROW 1.33 COL 21
     b-next-month AT ROW 1.33 COL 25
     FI-Year AT ROW 2.58 COL 10.75 COLON-ALIGNED
     b-prev-year AT ROW 2.67 COL 21
     b-next-year AT ROW 2.67 COL 25
     b-exit AT ROW 4.33 COL 14.75
     b-quit AT ROW 4.33 COL 24.75
     b-help AT ROW 4.33 COL 34.75
     fi-month-name AT ROW 1.5 COL 28.25 COLON-ALIGNED NO-LABEL
     SPACE(2.12) SKIP(3.74)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Введите месяц и год"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartDialog
   Allow: Basic,Browse,DB-Fields,Query,Smart
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX D-Dialog
                                                                        */
ASSIGN
       FRAME D-Dialog:SCROLLABLE       = FALSE
       FRAME D-Dialog:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN fi-month-name IN FRAME D-Dialog
   NO-DISPLAY                                                           */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX D-Dialog
/* Query rebuild information for DIALOG-BOX D-Dialog
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX D-Dialog */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB D-Dialog
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME D-Dialog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL D-Dialog D-Dialog
ON GO OF FRAME D-Dialog /* Введите месяц и год */
DO:
  def var v-date as date no-undo .
  def var v-new-month as integer no-undo .
  def var v-new-year  as integer no-undo .

  assign
    v-new-month = integer (cb-month :screen-value)
    v-new-year  = integer (fi-year  :screen-value)
  .

  assign
    v-date = date(v-new-month, 1, v-new-year)
  .

  if v-date = ? then do:
    message
      "Недопустимый диапазон" skip
      "месяц" v-new-month skip
      "год"   v-new-year  skip
      view-as alert-box .
    return no-apply . /* --->>>--- */
  end.

  if  h-callback <> ?
  and valid-handle(h-callback)
  then do:
    if can-do(h-callback :internal-entries, "validate-month-year") then do:
      def var lok as logical no-undo .
      run validate-month-year in h-callback
        (input v-new-month
        ,input v-new-year
        ,output lok
        ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры проверки допустимости месяца и года" skip
          "файл" h-callback :file-name skip
          "процедура" "validate-month-year" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        return no-apply .
      end.
      if lok <> true then do:
        return no-apply . /* --->>>--- */
      end.
    end.
    else do:
      message
        vss-workfile vss-revision vss-description skip
        "Программе был передан указатель на процедуру для проверки диапазона дат" skip
        "В указанной процедуре отсутствует внутренняя процедура validate-month-year " skip
        "файл" h-callback :file-name skip
        view-as alert-box error .
      return no-apply .
    end.
  end.

  assign
    p-month = v-new-month
    p-year  = v-new-year
    p-ok = true
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL D-Dialog D-Dialog
ON WINDOW-CLOSE OF FRAME D-Dialog /* Введите месяц и год */
DO:
  /* Add Trigger to equate WINDOW-CLOSE to END-ERROR. */
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit D-Dialog
ON CHOOSE OF b-exit IN FRAME D-Dialog /* Ввод */
DO:
  { gbl/stdbtn.i }

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-next-month
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-next-month D-Dialog
ON CHOOSE OF b-next-month IN FRAME D-Dialog /* >> */
DO:
  { gbl/stdbtn.i }

  run select-month in this-procedure
    (input 1
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-next-year
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-next-year D-Dialog
ON CHOOSE OF b-next-year IN FRAME D-Dialog /* >> */
DO:
  { gbl/stdbtn.i }

  run select-year in this-procedure
    (input 1
    ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prev-month
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prev-month D-Dialog
ON CHOOSE OF b-prev-month IN FRAME D-Dialog /* << */
DO:
  { gbl/stdbtn.i }

  run select-month in this-procedure
    (input -1
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prev-year
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prev-year D-Dialog
ON CHOOSE OF b-prev-year IN FRAME D-Dialog /* << */
DO:
  { gbl/stdbtn.i }

  run select-year in this-procedure
    (input -1
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit D-Dialog
ON CHOOSE OF b-quit IN FRAME D-Dialog /* Отказ */
DO:
  { gbl/stdbtn.i }

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME CB-Month
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CB-Month D-Dialog
ON VALUE-CHANGED OF CB-Month IN FRAME D-Dialog /* Месяц */
DO:
  run display-month-name in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK D-Dialog


/* ***************************  Main Block  *************************** */

if p-title <> "" then do:
  assign
    frame {&frame-name} :title = p-title
  .
end.

if p-month = ?
or p-month < 1
or p-month > 12 then do:
  run cur-time in this-procedure ( output v-today
                                  , output v-time
                                 ).
  assign
    CB-Month                = month( v-today )
    CB-Month :screen-value  = string( month( v-today ) )
  .
end.
else do:
  assign
    CB-Month                = p-month
    CB-Month :screen-value  = string(p-month)
  .
end.

if p-year = ?
or p-year < 1
or p-year > 9999 then do:
  run cur-time in this-procedure ( output v-today
                                  , output v-time
                                 ).
  assign
    FI-Year                = year( v-today )
  .
end.
else do:
  assign
    FI-Year                = p-year
  .
end.

assign
  p-ok = false
.

run display-month-name in this-procedure .

{ gbl/app_help.i }
{src/adm/template/dialogmn.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects D-Dialog _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available D-Dialog _ADM-ROW-AVAILABLE
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI D-Dialog _DEFAULT-DISABLE
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
  HIDE FRAME D-Dialog.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-month-name D-Dialog
PROCEDURE display-month-name :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  def var v-month-name as character no-undo .

  do with frame {&frame-name}:
    run gbl/monthnam.p
      (input integer(cb-month :screen-value)
      ,output v-month-name
      ).

    assign
      fi-month-name :screen-value = v-month-name
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI D-Dialog _DEFAULT-ENABLE
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
  DISPLAY CB-Month FI-Year
      WITH FRAME D-Dialog.
  ENABLE CB-Month b-prev-month b-next-month FI-Year b-prev-year b-next-year
         b-exit b-quit b-help fi-month-name
      WITH FRAME D-Dialog.
  VIEW FRAME D-Dialog.
  {&OPEN-BROWSERS-IN-QUERY-D-Dialog}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-month D-Dialog
PROCEDURE select-month :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input parameter p-shift-value as integer no-undo .

  def var v-current-month as integer no-undo .

  do with frame {&frame-name}:
    assign
      v-current-month = integer (cb-month :screen-value)
    .

    assign
      v-current-month = v-current-month + p-shift-value
    .
    if v-current-month < 1 then do:
      assign
        v-current-month = 12
      .
      run select-year in this-procedure
        (input -1
        ) .
    end.
    if v-current-month > 12 then do:
      assign
        v-current-month = 1
      .
      run select-year in this-procedure
        (input 1
        ) .
    end.

    assign
      cb-month :screen-value = string(v-current-month)
    .
  end.

  run display-month-name .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-year D-Dialog
PROCEDURE select-year :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input parameter p-shift-value as integer no-undo .

  def var v-current-year as integer no-undo .

  do with frame {&frame-name}:
    assign
      v-current-year = integer (fi-year :screen-value)
    .

    assign
      v-current-year = v-current-year + p-shift-value
    .
    if v-current-year < 0 then do:
      assign
        v-current-year = 0
      .
    end.
    if v-current-year > 9999 then do:
      assign
        v-current-year = 9999
      .
    end.

    assign
      fi-year :screen-value = string(v-current-year)
    .
  end.

  run display-month-name .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records D-Dialog _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* SEND-RECORDS does nothing because there are no External
     Tables specified for this SmartDialog, and there are no
     tables specified in any contained Browse, Query, or Frame. */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed D-Dialog
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