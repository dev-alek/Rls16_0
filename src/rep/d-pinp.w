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

Окно ввода месяца и года, и списка товаров для топливных отчетов

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/30/09
Author: Dmitry Ukhanov
Creation date: 01/30/09

Автор1: Перваков Михаил Сергеевич
Дата создания1: 04/11/06

*/

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input        parameter p-title as character no-undo .
define input-output parameter p-month as integer no-undo .
define input-output parameter p-year  as integer no-undo .
define output       parameter p-ok    as logical no-undo .

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Окно ввода месяца и года, и списка товаров для топливных отчетов".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i }
{ cmp/gds-list.i gds-list def shared }
{ gbl/getcntxt.i def }
define variable lns-cnt as integer no-undo .

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
&Scoped-Define ENABLED-OBJECTS RECT-1 CB-Month b-prev-month b-next-month ~
FI-Year b-prev-year b-next-year RECT-2 b-all-petrol b-select-goods b-print ~
b-help b-quit fi-month-name fi-goods-count
&Scoped-Define DISPLAYED-OBJECTS CB-Month FI-Year fi-goods-count

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-all-petrol
     LABEL "&Все топливо"
     SIZE 14.25 BY 1.

DEFINE BUTTON b-help
     LABEL "&Помощь"
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

DEFINE BUTTON b-print AUTO-GO
     LABEL "&Печать"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-select-goods
     LABEL "&Выбор"
     SIZE 10 BY 1.

DEFINE VARIABLE CB-Month AS INTEGER FORMAT "99":U INITIAL 0
     LABEL "Месяц"
     VIEW-AS COMBO-BOX INNER-LINES 12
     LIST-ITEMS "         1","         2","         3","         4","         5","         6","         7","         8","         9","        10","        11","        12"
     SIZE 7 BY 1 NO-UNDO.

DEFINE VARIABLE fi-goods-count AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     LABEL "Выбор товара"
      VIEW-AS TEXT
     SIZE 9.75 BY .67 NO-UNDO.

DEFINE VARIABLE fi-month-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 28.5 BY .67 NO-UNDO.

DEFINE VARIABLE FI-Year AS INTEGER FORMAT "9999":U INITIAL 0
     LABEL "Год"
     VIEW-AS FILL-IN
     SIZE 7 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 56.75 BY 4.08.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 56.5 BY 2.42.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME D-Dialog
     CB-Month AT ROW 2.83 COL 10.5 COLON-ALIGNED
     b-prev-month AT ROW 2.83 COL 20.75
     b-next-month AT ROW 2.83 COL 24.75
     FI-Year AT ROW 4.08 COL 10.5 COLON-ALIGNED
     b-prev-year AT ROW 4.17 COL 20.75
     b-next-year AT ROW 4.17 COL 24.75
     b-all-petrol AT ROW 7 COL 35
     b-select-goods AT ROW 7 COL 49.25
     b-print AT ROW 8.67 COL 18.5
     b-help AT ROW 8.67 COL 28.5
     b-quit AT ROW 8.67 COL 38.5
     fi-month-name AT ROW 3 COL 28 COLON-ALIGNED NO-LABEL
     fi-goods-count AT ROW 7.17 COL 21.75 COLON-ALIGNED
     RECT-1 AT ROW 1.42 COL 3.25
     "Период:" VIEW-AS TEXT
          SIZE 8 BY .67 AT ROW 1.83 COL 5.5
          FGCOLOR 4
     RECT-2 AT ROW 5.83 COL 3.5
     "Товары:" VIEW-AS TEXT
          SIZE 8 BY .67 AT ROW 6.17 COL 5
          FGCOLOR 4
     SPACE(52.12) SKIP(3.32)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Отчет по топливу"
         DEFAULT-BUTTON b-print CANCEL-BUTTON b-quit.


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
ON GO OF FRAME D-Dialog /* Отчет по топливу */
DO:
  assign
    p-month = integer (cb-month :screen-value )
    p-year  = integer (fi-year  :screen-value )
    p-ok = true
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL D-Dialog D-Dialog
ON WINDOW-CLOSE OF FRAME D-Dialog /* Отчет по топливу */
DO:
  /* Add Trigger to equate WINDOW-CLOSE to END-ERROR. */
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-all-petrol
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-all-petrol D-Dialog
ON CHOOSE OF b-all-petrol IN FRAME D-Dialog /* All petrol */
DO:
  { gbl/stdbtn.i }

  run add-all-petrol .

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


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print D-Dialog
ON CHOOSE OF b-print IN FRAME D-Dialog /* Print */
DO:
  { gbl/stdbtn.i }

  find first gds-list no-lock no-error .
  if not available gds-list then do:
    message
      "Не выбрано ни одного товара" skip
      "Используйте кнопки:" skip
      "  " b-all-petrol :label skip
      "  " b-select-goods :label skip
      view-as alert-box information .
    return no-apply .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit D-Dialog
ON CHOOSE OF b-quit IN FRAME D-Dialog /* Cancel */
DO:
  { gbl/stdbtn.i }

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-select-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-select-goods D-Dialog
ON CHOOSE OF b-select-goods IN FRAME D-Dialog /* Select */
DO:
  { gbl/stdbtn.i }

  run str/gds-list.w (
                  input parparentproc
                , input v-cntxt-host-code-obj
                , input v-cntxt-obj-type
                , input v-cntxt-obj-code).

  def var v-new-lns-cnt  as integer no-undo init 0 .
  def var v-remove-count as integer no-undo init 0 .

  define buffer buf_goods for ub.goods .
  define buffer buf_units for ub.units .

  for each gds-list no-lock
  :
    find first buf_goods no-lock
      where buf_goods.artic     = gds-list.artic
        and buf_goods.prod-type = gds-list.prod-type
        and buf_goods.prod-code = gds-list.prod-code
      no-error .
    if not available buf_goods then do:
      delete gds-list .
      assign
        v-remove-count = v-remove-count + 1
      .
      next . /* --->>>--- */
    end.
    find first buf_units no-lock
      where buf_units.unit-name = buf_goods.unit-base
      no-error .
    if not available buf_units then do:
      assign
        v-remove-count = v-remove-count + 1
      .
      delete gds-list .
      next . /* --->>>--- */
    end.
    if not can-do(buf_units.type, {&petrolium}) then do:
      assign
        v-remove-count = v-remove-count + 1
      .
      delete gds-list .
      next . /* --->>>--- */
    end.

    assign
      v-new-lns-cnt = v-new-lns-cnt + 1
    .
  end.

  if v-remove-count <> 0 then do:
    message
      "Товар не является топливом и удален из списка." skip
      view-as alert-box information .
  end.

  do with frame {&frame-name}:
    assign
      lns-cnt = v-new-lns-cnt
      fi-goods-count :screen-value = string(lns-cnt)
    .
  end. /* do with frame */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME CB-Month
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CB-Month D-Dialog
ON VALUE-CHANGED OF CB-Month IN FRAME D-Dialog /* Month */
DO:
  run display-month-name in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK D-Dialog


/* ***************************  Main Block  *************************** */
{ gbl/getcntxt.i get }

if p-title <> "" then do:
  assign
    frame {&frame-name} :title = p-title
  .
end.

assign
  CB-Month               = p-month
  CB-Month :screen-value = string(p-month)
  FI-Year                = p-year
.

assign
  p-ok = false
.

run display-month-name in this-procedure .

run init-gds-list .

do with frame {&frame-name}:
  assign
    fi-goods-count               = lns-cnt
    fi-goods-count :screen-value = string(lns-cnt)
  .
end. /* do with frame */

{ gbl/app_help.i }
{src/adm/template/dialogmn.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-all-petrol D-Dialog
PROCEDURE add-all-petrol :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  def var v-old-lns-cnt as integer no-undo .
  define variable v-added as integer no-undo .

  assign
    v-old-lns-cnt = lns-cnt
  .

  run str/gdsunitt.p
    (
     input parparentproc
    ,input {&petrolium}
    ,input {&gds-goods}
    ,output v-added
    ).

  do with frame {&frame-name}:
    assign
      fi-goods-count :screen-value = string(lns-cnt)
    .
  end. /* do with frame */

  message
  v-added "товаров было добавлено"
  view-as alert-box information .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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
  DISPLAY CB-Month FI-Year fi-goods-count
      WITH FRAME D-Dialog.
  ENABLE RECT-1 CB-Month b-prev-month b-next-month FI-Year b-prev-year
         b-next-year RECT-2 b-all-petrol b-select-goods b-print b-help b-quit
         fi-month-name fi-goods-count
      WITH FRAME D-Dialog.
  VIEW FRAME D-Dialog.
  {&OPEN-BROWSERS-IN-QUERY-D-Dialog}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-gds-list D-Dialog
PROCEDURE init-gds-list :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  assign
    lns-cnt = 0
  .

  for each gds-list
  :
    assign
      lns-cnt = lns-cnt + 1
    .
  end.

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
        v-current-month = 1
      .
    end.
    if v-current-month > 12 then do:
      assign
        v-current-month = 12
      .
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