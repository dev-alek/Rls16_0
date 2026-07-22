&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases
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

Список накладных одного товара по заказу

Автор: Чернова Светлана Александровна
Дата создания: 07/04/07
Author: Svetlana Chernova
Creation date: 07/04/07


This .W file was created with the Progress AppBuilder.

*/
define temp-table tt_doc-line no-undo like ub.doc-line.

define input parameter parparentproc  as widget-handle no-undo.
define input parameter p-mode         as character no-undo.
define input parameter p-doc-code as character no-undo .
define input parameter p-gds-code as int no-undo .
define input  parameter table for tt_doc-line .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-Workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список накладных одного товара по заказу" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ cmp/showinf.i  }

define buffer buf_goods for ub.goods.
define buffer buf_trn-doc for ub.trn-doc  .
define buffer buf_clients for ub.clients  .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-3

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt_doc-line buf_trn-doc buf_clients

/* Definitions for BROWSE BROWSE-3                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-3 tt_doc-line.doc-code buf_trn-doc.status_ + string(buf_trn-doc.flag_,"+/-") tt_doc-line.fact-qnty buf_clients.obj-type + string (buf_clients.obj-code) buf_clients.obj-name buf_trn-doc.ship-date buf_trn-doc.fact-date string(buf_trn-doc.fact-time,"hh:mm")
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-3
&Scoped-define SELF-NAME BROWSE-3
&Scoped-define QUERY-STRING-BROWSE-3 FOR EACH tt_doc-line NO-LOCK where tt_doc-line.artic     = buf_goods.artic and tt_doc-line.prod-type = buf_goods.prod-type and tt_doc-line.prod-code = buf_goods.prod-code  , ~
       first buf_trn-doc no-lock where       buf_trn-doc.doc-code = tt_doc-line.doc-code , ~
       first buf_clients no-lock where       buf_clients.obj-code = buf_trn-doc.cli-code and       buf_clients.obj-type = buf_trn-doc.cli-type  INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-3 OPEN QUERY {&SELF-NAME} FOR EACH tt_doc-line NO-LOCK where tt_doc-line.artic     = buf_goods.artic and tt_doc-line.prod-type = buf_goods.prod-type and tt_doc-line.prod-code = buf_goods.prod-code  , ~
       first buf_trn-doc no-lock where       buf_trn-doc.doc-code = tt_doc-line.doc-code , ~
       first buf_clients no-lock where       buf_clients.obj-code = buf_trn-doc.cli-code and       buf_clients.obj-type = buf_trn-doc.cli-type  INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-3 tt_doc-line buf_trn-doc buf_clients
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-3 tt_doc-line
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-3 buf_trn-doc
&Scoped-define THIRD-TABLE-IN-QUERY-BROWSE-3 buf_clients


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-3}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit B-quit B-trn B-print B-Help BROWSE-3 ~
v-goods
&Scoped-Define DISPLAYED-OBJECTS v-goods

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "&Help"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-print
     LABEL "&Печать"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-trn
     LABEL "&Накладная"
     SIZE 12 BY 1 TOOLTIP "Просмотр Накладной"
     BGCOLOR 8 .

DEFINE VARIABLE v-goods AS CHARACTER FORMAT "X(256)":U
     LABEL "Товар"
      VIEW-AS TEXT
     SIZE 90.5 BY .67
     FGCOLOR 1  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-3 FOR
      tt_doc-line,
      buf_trn-doc,
      buf_clients SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-3 Dialog-Frame _FREEFORM
  QUERY BROWSE-3 NO-LOCK DISPLAY
      tt_doc-line.doc-code COLUMN-LABEL "N накладной" FORMAT "X(16)":U
      buf_trn-doc.status_ + string(buf_trn-doc.flag_,"+/-") COLUMN-LABEL "Статус" FORMAT "X(7)":U
      tt_doc-line.fact-qnty  COLUMN-LABEL "По накладным" FORMAT "->>>,>>>,>>>,>>9.999":U
      buf_clients.obj-type + string (buf_clients.obj-code) COLUMN-LABEL "Код" FORMAT "X(10)":U
      buf_clients.obj-name  COLUMN-LABEL "Поставщик" FORMAT "X(10)":U
      buf_trn-doc.ship-date COLUMN-LABEL "Доставка" FORMAT "99/99/99":U
      buf_trn-doc.fact-date COLUMN-LABEL "Факт" FORMAT "99/99/99":U
      string(buf_trn-doc.fact-time,"hh:mm") COLUMN-LABEL "Время-факт" FORMAT "X(5)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 99.25 BY 10.75 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-trn AT ROW 1 COL 21 WIDGET-ID 52
     B-print AT ROW 1 COL 80 WIDGET-ID 56
     B-Help AT ROW 1 COL 90
     BROWSE-3 AT ROW 3 COL 1 WIDGET-ID 200
     v-goods AT ROW 2.25 COL 7.5 COLON-ALIGNED WIDGET-ID 58
     SPACE(0.25) SKIP(12.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список накладных товара по заказу"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit WIDGET-ID 100.


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
/* BROWSE-TAB BROWSE-3 B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-3
/* Query rebuild information for BROWSE BROWSE-3
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt_doc-line NO-LOCK where
tt_doc-line.artic     = buf_goods.artic and
tt_doc-line.prod-type = buf_goods.prod-type and
tt_doc-line.prod-code = buf_goods.prod-code
 ,
first buf_trn-doc no-lock where
      buf_trn-doc.doc-code = tt_doc-line.doc-code ,
first buf_clients no-lock where
      buf_clients.obj-code = buf_trn-doc.cli-code and
      buf_clients.obj-type = buf_trn-doc.cli-type

INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BROWSE-3 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Список поставок товара по заказу */
DO:
  run save-proc in this-procedure no-error.
  if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Список поставок товара по заказу */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  if not available tt_doc-line then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-trn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-trn Dialog-Frame
ON CHOOSE OF B-trn IN FRAME Dialog-Frame /* Накладная */
DO:
  /* */
  define buffer buf_doc-line for ub.doc-line  .
  if not available tt_doc-line then return no-apply.
  find first buf_trn-doc no-lock where
             buf_trn-doc.doc-code  = tt_doc-line.doc-code
              no-error .
  find first buf_doc-line no-lock where
             buf_doc-line.doc-code  = tt_doc-line.doc-code  and
             buf_doc-line.artic  = tt_doc-line.artic        and
             buf_doc-line.prod-type = tt_doc-line.prod-type        and
             buf_doc-line.prod-code = tt_doc-line.prod-code
             no-error .

  if not available buf_trn-doc then return no-apply.
  run str/trn-lkp.p (input parParentProc, input recid(buf_trn-doc) , input  recid(buf_doc-line) ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-3
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

define variable loc#log as logical   no-undo .
/* Проверка прав на просмотр заказа */
  /*{ gbl/chk-actg.i
    g#db-num
    g#userid
    {&action-head-code-main}
    'actn_global-trn_lookup':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    loc#log
  }
  if loc#log <> yes then do: return error. end.
  */
    RUN init-tt.
    RUN enable_UI.
    RUN init-proc.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE bg-col Dialog-Frame
PROCEDURE bg-col :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter p-color as integer   no-undo .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  DISPLAY v-goods
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit B-trn B-print B-Help BROWSE-3 v-goods
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-widgets Dialog-Frame
PROCEDURE fill-widgets :
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame
PROCEDURE init-proc :
if p-mode <> {&update} then do:
     B-exit:label in frame {&frame-name}  = "Вы&ход"  .
     hide B-quit in frame {&frame-name} .
  END.
  hide b-print  in frame {&frame-name} .
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-tt Dialog-Frame
PROCEDURE init-tt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
v-goods =   buf_goods.artic + "  код:" + string ( buf_goods.gds-code ) + " "  +  buf_goods.gds-name .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-proc Dialog-Frame
PROCEDURE save-proc :
IF p-mode = {&LOOKUP} THEN RETURN .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME