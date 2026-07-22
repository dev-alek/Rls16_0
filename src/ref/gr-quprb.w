&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Корректировка состава количественныъх групп

Автор: Чернова Светлана Александровна
Дата создания: 11/10/05
Author: Svetlana Chernova
Creation date: 11/10/05

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parparentproc as handle no-undo .
define input  parameter p-mode as character no-undo .
define input  parameter p-db-num  as integer   no-undo .
define input  parameter p-id     as integer   no-undo .
define input  parameter p-name as character no-undo .
define input-output parameter p-recid as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Корректировка состава количественныъх групп".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i      }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ ref/qiq-ad.i }
/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.qnty-in-qnty-group

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH ub.qnty-in-qnty-group SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH ub.qnty-in-qnty-group SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame ub.qnty-in-qnty-group
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame ub.qnty-in-qnty-group


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-save B-Cancel B-Help v-ggr-qnty ~
v-discnt-pc v-name
&Scoped-Define DISPLAYED-OBJECTS v-ggr-qnty v-discnt-pc v-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-save AUTO-GO
     LABEL "Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE v-discnt-pc LIKE ub.qnty-in-qnty-group.discnt-pc
     LABEL "Процент скидки"
     VIEW-AS FILL-IN
     SIZE 7 BY 1 NO-UNDO.

DEFINE VARIABLE v-ggr-qnty LIKE ub.qnty-in-qnty-group.ggr-qnty
     LABEL "Количество"
     VIEW-AS FILL-IN
     SIZE 26.5 BY 1 NO-UNDO.

DEFINE VARIABLE V-method-round LIKE ub.qnty-in-qnty-group.method-round
     LABEL "Метод округления по скидке"
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.

DEFINE VARIABLE v-name LIKE ub.qnty-group.name
     LABEL "Группа"
      VIEW-AS TEXT
     SIZE 71.5 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE v-use-d AS LOGICAL INITIAL no
     LABEL "Использовать скидку"
     VIEW-AS TOGGLE-BOX
     SIZE 28 BY .83 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      ub.qnty-in-qnty-group SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-save AT ROW 1 COL 1
     B-Cancel AT ROW 1 COL 11
     B-Help AT ROW 1 COL 77
     v-ggr-qnty AT ROW 4.75 COL 33.5 COLON-ALIGNED HELP
          ""
          LABEL "Количество" FORMAT ">>>,>>>,>>>,>>9.99"
     v-use-d AT ROW 5.75 COL 35.5
     v-discnt-pc AT ROW 6.75 COL 33.5 COLON-ALIGNED HELP
          ""
          LABEL "Процент скидки" FORMAT ">>9.99"
     V-method-round AT ROW 7.92 COL 33.5 COLON-ALIGNED HELP
          ""
          LABEL "Метод округления по скидке" FORMAT "X(28)"
     v-name AT ROW 2.67 COL 12 COLON-ALIGNED HELP
          ""
          LABEL "Группа" FORMAT "X(80)"
          FGCOLOR 1
     SPACE(1.99) SKIP(7.69)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Добавление количества в группу"
         DEFAULT-BUTTON B-save CANCEL-BUTTON B-Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN v-discnt-pc IN FRAME Dialog-Frame
   LIKE = ub.qnty-in-qnty-group.discnt-pc EXP-LABEL EXP-FORMAT EXP-HELP EXP-SIZE */
/* SETTINGS FOR FILL-IN v-ggr-qnty IN FRAME Dialog-Frame
   LIKE = ub.qnty-in-qnty-group.ggr-qnty EXP-LABEL EXP-FORMAT EXP-HELP EXP-SIZE */
/* SETTINGS FOR FILL-IN V-method-round IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE LIKE = ub.qnty-in-qnty-group.method-round EXP-LABEL EXP-FORMAT EXP-HELP EXP-SIZE */
ASSIGN
       V-method-round:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN v-name IN FRAME Dialog-Frame
   LIKE = ub.qnty-group.name EXP-LABEL EXP-FORMAT EXP-HELP EXP-SIZE     */
/* SETTINGS FOR TOGGLE-BOX v-use-d IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       v-use-d:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "ub.qnty-in-qnty-group"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Добавление количества в группу */
DO:
  RUN save-proc in this-procedure no-error .
  if error-status :error then return no-apply .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Добавление количества в группу */
DO:
  APPLY "END-ERROR":U TO SELF.
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

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  run init-proc in this-procedure .
  run  enable_UI in this-procedure  .
  if p-mode = {&update} then do:
     disable  v-ggr-qnty with frame {&frame-name} .
    WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS v-discnt-pc .
  end.
  else do:
     WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS v-ggr-qnty .
  end.

END.
run disable_ui in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY v-ggr-qnty v-discnt-pc v-name
      WITH FRAME Dialog-Frame.
  ENABLE B-save B-Cancel B-Help v-ggr-qnty v-discnt-pc v-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame
PROCEDURE init-proc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer buf_qnty-in-qnty-group for ub.qnty-in-qnty-group  .

v-name = p-name .
if p-mode = {&update} then do:

find first buf_qnty-in-qnty-group no-lock where recid ( buf_qnty-in-qnty-group) = p-recid no-error .
      assign
          v-method-round = buf_qnty-in-qnty-group.method-round
          v-discnt-pc    = buf_qnty-in-qnty-group.discnt-pc
          v-ggr-qnty     = buf_qnty-in-qnty-group.ggr-qnty
          v-use-d        = buf_qnty-in-qnty-group.use-discnt
      .

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-proc Dialog-Frame
PROCEDURE save-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

ASSIGN frame {&frame-name}
    v-method-round
    v-discnt-pc
    v-ggr-qnty
    v-use-d
     .
if v-discnt-pc >= 100 then do:
   message "Процент не может быть 100 и выше !"  view-as alert-box error .
   return error return-value .
end.

if p-mode = {&update} then
  run qiq-update in this-procedure (
      input  p-recid ,
      input  p-db-num      ,
      input  p-id          ,
      input  v-ggr-qnty   ,
      input  v-use-d  ,
      input  v-discnt-pc   ,
      input  v-method-round,
      input  0        ,
      input  v-cntxt-db-num  ,
      input  v-cntxt-userid
      ) .
 else
  run qiq-add in this-procedure (
        input  p-db-num      ,
        input  p-id          ,
        input  v-ggr-qnty    ,
        input  v-use-d       ,
        input  v-discnt-pc   ,
        input  v-method-round,
        input  0             ,
        input  v-cntxt-db-num ,
        input  v-cntxt-userid ,
        output p-recid
        ).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
