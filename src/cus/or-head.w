&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER Post-clients FOR ub.clients.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Шапка заказа (автоматическое создание)

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 03/26/02 4:26

*/
define input  parameter parParentProc  as widget-handle no-undo.
def input param x-doc-code like ub.ord-doc.doc-code no-undo.
def input param x-new as logical no-undo .
define output parameter doc-mode as character no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init " Шапка заказа (автоматическое создание) ".
{ cmp/vssrevis.i     }
{ cmp/trg-def.i      }
{ cmp/showinf.i      }
{ str/lib-trn.i      }
{ cus/df-zakaz.i new }
{ cus/ord-lib.i def  }

define shared variable x-make-avto as integer  no-undo .

define variable  type-pr  as widget-handle.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.ord-doc ub.clients

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame ub.ord-doc.cli-type ~
ub.ord-doc.cli-code ub.ord-doc.doc-date ub.ord-doc.doc-code ~
ub.ord-doc.doc-type ub.ord-doc.obj-type ub.ord-doc.obj-code ~
ub.clients.obj-name ub.ord-doc.cli-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame ub.ord-doc.cli-type ~
ub.ord-doc.cli-code ub.ord-doc.doc-date ub.ord-doc.doc-code ~
ub.ord-doc.doc-type ub.ord-doc.obj-type ub.ord-doc.obj-code ~
ub.clients.obj-name ub.ord-doc.cli-name
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame ub.ord-doc ub.clients
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame ub.ord-doc
&Scoped-define SECOND-ENABLED-TABLE-IN-QUERY-Dialog-Frame ub.clients
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH ub.ord-doc ~
      WHERE ord-doc.doc-code = x-doc-code SHARE-LOCK, ~
      EACH ub.clients WHERE ub.clients.obj-code = ord-doc.obj-code ~
  AND ub.clients.obj-type = ord-doc.obj-type SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH ub.ord-doc ~
      WHERE ord-doc.doc-code = x-doc-code SHARE-LOCK, ~
      EACH ub.clients WHERE ub.clients.obj-code = ord-doc.obj-code ~
  AND ub.clients.obj-type = ord-doc.obj-type SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame ub.ord-doc ub.clients
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame ub.ord-doc
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame ub.clients


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS ub.ord-doc.cli-type ub.ord-doc.cli-code ~
ub.ord-doc.doc-date ub.ord-doc.doc-code ub.ord-doc.doc-type ~
ub.ord-doc.obj-type ub.ord-doc.obj-code ub.clients.obj-name ~
ub.ord-doc.cli-name
&Scoped-define ENABLED-TABLES ub.ord-doc ub.clients
&Scoped-define FIRST-ENABLED-TABLE ub.ord-doc
&Scoped-define SECOND-ENABLED-TABLE ub.clients
&Scoped-Define ENABLED-OBJECTS B-OK RECT-3 RECT-2 B-exit B-Help r-obj
&Scoped-Define DISPLAYED-FIELDS ub.ord-doc.cli-type ub.ord-doc.cli-code ~
ub.ord-doc.doc-date ub.ord-doc.doc-code ub.ord-doc.doc-type ~
ub.ord-doc.obj-type ub.ord-doc.obj-code ub.clients.obj-name ~
ub.ord-doc.cli-name
&Scoped-define DISPLAYED-TABLES ub.ord-doc ub.clients
&Scoped-define FIRST-DISPLAYED-TABLE ub.ord-doc
&Scoped-define SECOND-DISPLAYED-TABLE ub.clients


/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Отмена"
     SIZE 12 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "&Помощь"
     SIZE 10.25 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-OK AUTO-GO
     LABEL "Со&хранить"
     SIZE 12 BY 1
     BGCOLOR 8 .

DEFINE BUTTON r-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-obj"
     SIZE 3 BY .88 TOOLTIP "Выбор из списка".

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 100.13 BY 1.04.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 100 BY 9.04.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      ub.ord-doc,
      ub.clients SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-OK AT ROW 1 COL 1
     B-exit AT ROW 1 COL 13
     B-Help AT ROW 1 COL 90.88
     ub.ord-doc.cli-type AT ROW 4.75 COL 14.25 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 4.75 BY 1
     ub.ord-doc.cli-code AT ROW 4.79 COL 19.25 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     r-obj AT ROW 4.83 COL 31.88
     ub.ord-doc.doc-date AT ROW 2.38 COL 87.13 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 11 BY .67
          FGCOLOR 1
     ub.ord-doc.doc-code AT ROW 2.58 COL 14.25 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 15 BY .67
          FGCOLOR 1
     ub.ord-doc.doc-type AT ROW 3.33 COL 87.25 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 9 BY .67
          FGCOLOR 1
     ub.ord-doc.obj-type AT ROW 3.67 COL 14.25 COLON-ALIGNED
          LABEL "Объект"
           VIEW-AS TEXT
          SIZE 4.75 BY .67
     ub.ord-doc.obj-code AT ROW 3.67 COL 19.38 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 10 BY .67
     ub.clients.obj-name AT ROW 3.67 COL 33.5 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 41 BY .67
     ub.ord-doc.cli-name AT ROW 4.79 COL 33.38 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 41 BY 1
     RECT-3 AT ROW 2.04 COL 1
     RECT-2 AT ROW 1 COL 1
     SPACE(0.00) SKIP(9.08)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Заказ".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: Post-clients B "?" ? ub clients
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN ub.ord-doc.obj-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.ord-doc.obj-type IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "ub.ord-doc,ub.clients WHERE ub.ord-doc ..."
     _Options          = "SHARE-LOCK"
     _Where[1]         = "ord-doc.doc-code = x-doc-code"
     _JoinCode[2]      = "ub.clients.obj-code = ord-doc.obj-code
  AND ub.clients.obj-type = ord-doc.obj-type"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Заказ */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Отмена */
DO:
x-make-avto = 2 .
doc-mode = "cancel":U.
find current ub.ord-doc .
if x-new = true then
   delete ub.ord-doc.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-OK Dialog-Frame
ON CHOOSE OF B-OK IN FRAME Dialog-Frame /* Сохранить */
DO:
 x-make-avto = 2 .
   if type-pr <> ? then do:
     x-make-avto = integer( logical(type-pr:screen-value) ) .
  end .

 assign
 ub.ord-doc.cli-code
 ub.ord-doc.cli-name
 ub.ord-doc.cli-type
 ub.ord-doc.doc-code
 ub.ord-doc.doc-date
 ub.ord-doc.doc-type
 ub.ord-doc.obj-code
 ub.ord-doc.obj-type
 .
if not can-find ( first ub.clients where ub.clients.obj-code = ub.ord-doc.cli-code and  ub.clients.obj-type = ub.ord-doc.cli-type ) then do:
     message "Неправильно задан КОНТРАГЕНТ !" view-as alert-box.
     return no-apply.
end.
if ub.ord-doc.cli-type = {&shop} or ub.ord-doc.cli-type = {&stock} then do:
    message "Неправильно задан КОНТРАГЕНТ !" ub.ord-doc.cli-type view-as alert-box.
    return no-apply.
end.

doc-mode = {&update} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-obj Dialog-Frame
ON CHOOSE OF r-obj IN FRAME Dialog-Frame /* r-obj */
DO:
define variable bttns    as  char no-undo. /* список включенных батонов */
define variable rid-list as  char no-undo . /* список recid'ов выбранных клиентов */


  run ref/cli-all.w ( input parParentProc, input "b-sel", {&cmp}, ?, ?, ?, ?, ?, output  rid-list) no-error .
  find first post-clients where recid(post-clients) = integer(rid-list) no-lock no-error.
  if available post-clients then
  Assign
    ub.ord-doc.cli-code = Post-clients.obj-code
    ub.ord-doc.cli-type = Post-clients.obj-type
    ub.ord-doc.cli-name = post-clients.obj-name
  .

  Display ub.ord-doc.cli-code ub.ord-doc.cli-type ub.ord-doc.cli-name with frame {&frame-name}.
  if ub.ord-doc.obj-code = ub.ord-doc.cli-code and
     ub.ord-doc.obj-type = ub.ord-doc.cli-type
     then do:
     message "Поставщик и Контрагент должны быть разные ! " view-as alert-box error .
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


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run enable_ui in this-procedure .
  if ord-doc.doc-type  = {&f-p}  then do:
     hide ord-doc.obj-code ord-doc.obj-type clients.obj-name in frame {&frame-name}.
  end.
  run mm in this-procedure .
  frame {&frame-name}:title = frame {&frame-name}:title   .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
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
  IF AVAILABLE ub.clients THEN
    DISPLAY ub.clients.obj-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.ord-doc THEN
    DISPLAY ub.ord-doc.cli-type ub.ord-doc.cli-code ub.ord-doc.doc-date
          ub.ord-doc.doc-code ub.ord-doc.doc-type ub.ord-doc.obj-type
          ub.ord-doc.obj-code ub.ord-doc.cli-name
      WITH FRAME Dialog-Frame.
  ENABLE B-OK RECT-3 RECT-2 B-exit B-Help ub.ord-doc.cli-type
         ub.ord-doc.cli-code r-obj ub.ord-doc.doc-date ub.ord-doc.doc-code
         ub.ord-doc.doc-type ub.ord-doc.obj-type ub.ord-doc.obj-code
         ub.clients.obj-name ub.ord-doc.cli-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mm Dialog-Frame
PROCEDURE mm :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
   create TOGGLE-BOX type-pr
   assign
    row    = 7
    column = 2
    screen-value = "no"
    label = "формировать строки автоматически без подтверждения"
    frame  = frame {&frame-name}:handle
 .

if valid-handle(type-pr) = false then do:
    message "не могу создать чек-бокс !!!" skip
    view-as alert-box information .
    return error.
 end.
  type-pr:sensitive = yes  .
  type-pr:visible   = yes  .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME