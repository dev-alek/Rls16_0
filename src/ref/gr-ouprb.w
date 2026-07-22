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

Добавление и корректировка состава группы оборотов

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
define variable vss-description as character no-undo init "Добавление и корректировка состава группы оборотов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i      }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ ref/oio-ad.i }
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
&Scoped-define INTERNAL-TABLES ub.tnv-in-turnover-group

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH ub.tnv-in-turnover-group SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH ub.tnv-in-turnover-group SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame ub.tnv-in-turnover-group
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame ub.tnv-in-turnover-group


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-save B-Cancel B-Help v-ttg-summa ~
v-discnt-pc v-name rubl
&Scoped-Define DISPLAYED-OBJECTS v-ttg-summa v-discnt-pc v-name rubl

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

DEFINE VARIABLE rubl AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 19.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE V-discnt-method-round LIKE ub.tnv-in-turnover-group.discnt-method-round
     LABEL "Метод округления по скидке"
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.

DEFINE VARIABLE v-discnt-pc LIKE ub.tnv-in-turnover-group.discnt-pc
     LABEL "Процент скидки"
     VIEW-AS FILL-IN
     SIZE 7 BY 1 NO-UNDO.

DEFINE VARIABLE v-name LIKE ub.turnover-group.name
     LABEL "Группа"
      VIEW-AS TEXT
     SIZE 76.5 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE v-ttg-summa LIKE ub.tnv-in-turnover-group.ttg-summa
     LABEL "Оборот покупателей"
     VIEW-AS FILL-IN
     SIZE 26.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-use-d AS LOGICAL INITIAL no
     LABEL "Использовать скидку"
     VIEW-AS TOGGLE-BOX
     SIZE 28 BY .83 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      ub.tnv-in-turnover-group SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-save AT ROW 1 COL 1
     B-Cancel AT ROW 1 COL 11
     B-Help AT ROW 1 COL 77
     v-ttg-summa AT ROW 4.75 COL 33.5 COLON-ALIGNED HELP
          ""
          LABEL "Оборот покупателей" FORMAT ">>>,>>>,>>>,>>9.99"
     v-use-d AT ROW 5.75 COL 35.5
     v-discnt-pc AT ROW 6.75 COL 33.5 COLON-ALIGNED HELP
          ""
          LABEL "Процент скидки" FORMAT ">>9.99"
     V-discnt-method-round AT ROW 7.92 COL 33.5 COLON-ALIGNED HELP
          ""
          LABEL "Метод округления по скидке" FORMAT "X(28)"
     v-name AT ROW 3 COL 7.5 COLON-ALIGNED HELP
          ""
          LABEL "Группа" FORMAT "X(80)"
          FGCOLOR 1
     rubl AT ROW 4.92 COL 61 COLON-ALIGNED NO-LABEL
     "%" VIEW-AS TEXT
          SIZE 1.75 BY 1 AT ROW 6.75 COL 43.25
          FGCOLOR 4
     SPACE(42.49) SKIP(3.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Добавление Оборота покупателей "
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

/* SETTINGS FOR FILL-IN V-discnt-method-round IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE LIKE = ub.tnv-in-turnover-group.discnt-method-round EXP-LABEL EXP-FORMAT EXP-HELP EXP-SIZE */
ASSIGN
       V-discnt-method-round:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN v-discnt-pc IN FRAME Dialog-Frame
   LIKE = ub.tnv-in-turnover-group.discnt-pc EXP-LABEL EXP-FORMAT EXP-HELP EXP-SIZE */
/* SETTINGS FOR FILL-IN v-name IN FRAME Dialog-Frame
   LIKE = ub.turnover-group.name EXP-LABEL EXP-FORMAT EXP-HELP EXP-SIZE */
/* SETTINGS FOR FILL-IN v-ttg-summa IN FRAME Dialog-Frame
   LIKE = ub.tnv-in-turnover-group.ttg-summa EXP-LABEL EXP-FORMAT EXP-HELP EXP-SIZE */
/* SETTINGS FOR TOGGLE-BOX v-use-d IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       v-use-d:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "ub.tnv-in-turnover-group"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Добавление Оборота покупателей  */
DO:
  run save-proc in this-procedure no-error .
  if error-status :error then do:
     return no-apply .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Добавление Оборота покупателей  */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-use-d
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-use-d Dialog-Frame
ON VALUE-CHANGED OF v-use-d IN FRAME Dialog-Frame /* Использовать скидку */
DO:
  ASSIGN v-use-d .
  IF v-use-d  THEN DO:
     ENABLE v-discnt-pc WITH FRAME {&FRAME-NAME}.
  END.
  ELSE DO:
      v-discnt-pc = 0 .
      DISABLE v-discnt-pc WITH FRAME {&FRAME-NAME}.
  END.
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
  run enable_ui in this-procedure .
  if p-mode = {&update} then do:
     disable v-ttg-summa with frame {&frame-name}.
     WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS v-discnt-pc .
  end.
  else do:
     WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS v-ttg-summa .
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
  DISPLAY v-ttg-summa v-discnt-pc v-name rubl
      WITH FRAME Dialog-Frame.
  ENABLE B-save B-Cancel B-Help v-ttg-summa v-discnt-pc v-name rubl
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame
PROCEDURE init-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  v-name = p-name .
  rubl = "{&abbr_rub_allshift}" .
define buffer buf_tnv-in-turnover-group for ub.tnv-in-turnover-group  .

  if p-mode = {&update}  then do:
  find first buf_tnv-in-turnover-group no-lock where recid(buf_tnv-in-turnover-group) = p-recid no-error .
  if not available buf_tnv-in-turnover-group then
  message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    "Ошибка "
    view-as alert-box error
  .
  assign
   v-ttg-summa  =  buf_tnv-in-turnover-group.ttg-summa
   v-use-d      =  buf_tnv-in-turnover-group.use-discnt
   v-discnt-pc  =  buf_tnv-in-turnover-group.discnt-pc
   V-discnt-method-round =  buf_tnv-in-turnover-group.discnt-method-round
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
    V-discnt-method-round
    v-discnt-pc
    v-ttg-summa
    v-use-d
     .
if v-discnt-pc >= 100 then do:
   message "Процент не может быть 100 и выше !"  view-as alert-box error .
   return error return-value .
end.

if p-mode = {&add-def} then do:
    run oio-ADD in this-procedure (
        input  p-db-num      ,
        input  p-id          ,
        input  v-ttg-summa   ,
        input  v-use-d  ,
        input  v-discnt-pc   ,
        input  v-discnt-method-round,
        input  0        ,
        input  v-cntxt-db-num  ,
        input  v-cntxt-userid  ,
        output p-recid
        ).
 end.
 else do:
    run oio-update in this-procedure (
        input  p-recid       ,
        input  p-db-num      ,
        input  p-id          ,
        input  v-ttg-summa   ,
        input  v-use-d       ,
        input  v-discnt-pc   ,
        input  v-discnt-method-round,
        input  0               ,
        input  v-cntxt-db-num  ,
        input  v-cntxt-userid
        ).
 end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
