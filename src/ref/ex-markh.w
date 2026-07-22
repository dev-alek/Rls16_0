&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_ex-mark FOR ub.ex-mark.
DEFINE BUFFER x_c-ex-mark FOR ub.c-ex-mark.
DEFINE BUFFER x_ex-mark FOR ub.ex-mark.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История акцизных и спец марок

Автор: Хныкин Павел Андреевич
Дата создания: 12/21/07
Author: Pavel Khnykin
Creation date: 12/21/07
*/
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parParentProc   as widget-handle  no-undo .
define input  parameter p-ex-mark-rowid as rowid          no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "История акцизных и спец марок".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ gbl/waitfram.i }
{ cmp/library.i  }
{ gbl/usrfulnf.i }
{ ref/exmrklib.i }
{ ref/tmpchgs.i  }

define variable v-curr-rowid  as rowid     no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-c-ex-mark

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES x_c-ex-mark temp-changes

/* Definitions for BROWSE br-c-ex-mark                                  */
&Scoped-define FIELDS-IN-QUERY-br-c-ex-mark ~
usrfulnf(x_c-ex-mark.corr-user-name) x_c-ex-mark.corr-date ~
string( x_c-ex-mark.corr-time, "hh:mm:ss" ) x_c-ex-mark.corr-user-db-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-c-ex-mark
&Scoped-define QUERY-STRING-br-c-ex-mark FOR EACH x_c-ex-mark NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-c-ex-mark OPEN QUERY br-c-ex-mark FOR EACH x_c-ex-mark NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-c-ex-mark x_c-ex-mark
&Scoped-define FIRST-TABLE-IN-QUERY-br-c-ex-mark x_c-ex-mark


/* Definitions for BROWSE br-changes                                    */
&Scoped-define FIELDS-IN-QUERY-br-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-changes
&Scoped-define SELF-NAME br-changes
&Scoped-define QUERY-STRING-br-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-br-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-br-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-br-changes temp-changes


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-c-ex-mark}~
    ~{&OPEN-QUERY-br-changes}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-help br-c-ex-mark br-changes

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-c-ex-mark FOR
      x_c-ex-mark SCROLLING.

DEFINE QUERY br-changes FOR
      temp-changes SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-c-ex-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-c-ex-mark Dialog-Frame _STRUCTURED
  QUERY br-c-ex-mark NO-LOCK DISPLAY
      usrfulnf(x_c-ex-mark.corr-user-name) COLUMN-LABEL "Изменил" FORMAT "X(25)":U
            WIDTH 25
      x_c-ex-mark.corr-date FORMAT "99/99/9999":U
      string( x_c-ex-mark.corr-time, "hh:mm:ss" ) COLUMN-LABEL "Время" FORMAT "X(8)":U
      x_c-ex-mark.corr-user-db-num FORMAT ">>>>9":U WIDTH 10
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 12 FIT-LAST-COLUMN.

DEFINE BROWSE br-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-changes Dialog-Frame _FREEFORM
  QUERY br-changes DISPLAY
      temp-changes.l_name   COLUMN-LABEL "Изменилось" format "X(20)"
      temp-changes.v_old    COLUMN-LABEL "Было"       format "X(30)"
      temp-changes.v_new    COLUMN-LABEL "Стало"      format "X(30)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 6 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-help AT ROW 1 COL 86
     br-c-ex-mark AT ROW 3 COL 1 WIDGET-ID 200
     br-changes AT ROW 16 COL 1 WIDGET-ID 300
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "История"
         DEFAULT-BUTTON b-exit WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_ex-mark B "?" ? ub ex-mark
      TABLE: x_c-ex-mark B "?" ? ub c-ex-mark
      TABLE: x_ex-mark B "?" ? ub ex-mark
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-c-ex-mark b-help Dialog-Frame */
/* BROWSE-TAB br-changes br-c-ex-mark Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-c-ex-mark
/* Query rebuild information for BROWSE br-c-ex-mark
     _TblList          = "x_c-ex-mark"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > "_<CALC>"
"usrfulnf(x_c-ex-mark.corr-user-name)" "Изменил" "X(25)" ? ? ? ? ? ? ? no ? no no "25" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   = Temp-Tables.x_c-ex-mark.corr-date
     _FldNameList[3]   > "_<CALC>"
"string( x_c-ex-mark.corr-time, ""hh:mm:ss"" )" "Время" "X(8)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > Temp-Tables.x_c-ex-mark.corr-user-db-num
"corr-user-db-num" ? ? "integer" ? ? ? ? ? ? no ? no no "10" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE br-c-ex-mark */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-changes
/* Query rebuild information for BROWSE br-changes
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-changes */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* История */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-help
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-help Dialog-Frame
ON CHOOSE OF b-help IN FRAME Dialog-Frame /* Помощь */
OR HELP OF FRAME {&FRAME-NAME}
DO: /* Call Help Function (or a simple message). */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-c-ex-mark
&Scoped-define SELF-NAME br-c-ex-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-c-ex-mark Dialog-Frame
ON VALUE-CHANGED OF br-c-ex-mark IN FRAME Dialog-Frame
DO:
  RUN proc-view-changes IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i &browse-name="br-c-ex-mark" }
{ gbl/brwrepos.i &browse-name="br-c-ex-mark" &line-num=5 }

{ gbl/brwrefre.i  "if available x_c-ex-mark then do: ~
  assign ~
    v-curr-rowid = rowid(x_c-ex-mark) ~
  . ~
  end. ~
  run open-br in this-procedure . ~
  reposition br-c-ex-mark to rowid v-curr-rowid no-error . ~
  apply 'entry' to {&browse-name} in frame {&frame-name}. ~
" }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run my-enable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

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
  ENABLE b-exit b-help br-c-ex-mark br-changes
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-enable Dialog-Frame
PROCEDURE my-enable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  find first buf_ex-mark no-lock
    where rowid(buf_ex-mark) = p-ex-mark-rowid
  no-error .
  if not available buf_ex-mark then do:
    message
      "Не определена запись для показа истории."
    view-as alert-box error.
    return error.
  end.
  assign
    frame {&frame-name}:title = substitute( "История марки БД: &1 внутренний код: &2" , buf_ex-mark.db-num , buf_ex-mark.mark-code )
  .
  enable
    b-exit
    b-help
    br-c-ex-mark
    br-changes
  with frame {&frame-name}.
  view frame {&frame-name}.

  run open-br in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE open-br Dialog-Frame
PROCEDURE open-br :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  run waitfram-show in this-procedure ( "Подождите..." ) .

  open query br-c-ex-mark
    for each x_c-ex-mark no-lock
      where x_c-ex-mark.db-num    = buf_ex-mark.db-num
        and x_c-ex-mark.mark-code = buf_ex-mark.mark-code
    by x_c-ex-mark.corr-date descending
    by x_c-ex-mark.corr-time descending
  indexed-reposition.

  apply "value-changed" to br-c-ex-mark in frame {&frame-name}.
  apply "entry" to br-c-ex-mark in frame {&frame-name}.
  run waitfram-hide in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-view-changes Dialog-Frame
PROCEDURE proc-view-changes :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  for each temp-changes:
      delete temp-changes.
  end.
  if not available X_c-ex-mark then do:
    open query br-changes for each temp-changes.
    return.
  end.

  &scop fields-name-list "mark-name,mark-type,stts":U

  define variable v-label-param as character no-undo .

  v-label-param =
    "mark-name" + {&delim-par} + "Код марки" + {&delim-par} + "" + {&delim-flf}
  + "mark-type" + {&delim-par} + "Тип марки" + {&delim-par} + "exmrklib_get-type-name" + {&delim-flf}
  + "stts"      + {&delim-par} + "Статус"    + {&delim-par} + "exmrklib_get-status-name"  .

  run proc-full-temp-changes in this-procedure ( input  buffer X_c-ex-mark:handle
                                               , input  {&table_ex-mark}
                                               , input  {&fields-name-list}
                                               , input  v-label-param
                                               ) .


  open query br-changes for each temp-changes.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME