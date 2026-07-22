&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tmp-ord NO-UNDO LIKE ub.ord-doc
       field mm as log.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Удаление неисполненных заказов

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 08/15/05
*/
define input parameter parParentProc  as widget-handle no-undo.
define input parameter date1 as date no-undo .
define input parameter date2 as date no-undo .
define input parameter g#type as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Удаление неисполненных заказов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/color.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }

define new shared buffer SHAR-BUF_ORD-DOC for ub.ORD-DOC  .
define variable g#log      as logical   no-undo .
define variable br-handle    as handle   no-undo .
define variable bf-handle    as handle   no-undo .
define variable next-prev    as logical  no-undo .


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-3

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tmp-ord

/* Definitions for BROWSE BROWSE-3                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-3 tmp-ord.mm tmp-ord.doc-code tmp-ord.flag_ tmp-ord.status_ tmp-ord.doc-date tmp-ord.host-code tmp-ord.cli-type + " " + String(tmp-ord.cli-code) @ tmp-ord.cli-type tmp-ord.cli-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-3
&Scoped-define SELF-NAME BROWSE-3
&Scoped-define QUERY-STRING-BROWSE-3 FOR EACH tmp-ord NO-LOCK
&Scoped-define OPEN-QUERY-BROWSE-3 OPEN QUERY {&SELF-NAME} FOR EACH tmp-ord NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BROWSE-3 tmp-ord
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-3 tmp-ord


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-3}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-mark b-erase b-lkp b-del b-help ~
BROWSE-3

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 12 BY 1 TOOLTIP "Удалить заказ".

DEFINE BUTTON b-erase
     LABEL "&Снять все *":L
     SIZE 13 BY 1 TOOLTIP "Снять все отметки"
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 12 BY 1.

DEFINE BUTTON b-lkp
     LABEL "&Просмотр":L
     SIZE 12 BY 1 TOOLTIP "Просмотр заказа без корректировки".

DEFINE BUTTON b-mark
     LABEL "&*":L
     SIZE 4 BY 1.

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход ":L
     SIZE 12 BY 1 TOOLTIP "Выход из режима".

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-3 FOR
      tmp-ord SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-3 Dialog-Frame _FREEFORM
  QUERY BROWSE-3 DISPLAY
      tmp-ord.mm         COLUMN-LABEL "*" FORMAT "*/"
      tmp-ord.doc-code
      tmp-ord.flag_      COLUMN-LABEL "ОК"   FORMAT "+/-"
      tmp-ord.status_    COLUMN-LABEL "Статус"  FORMAT "x(6)"
      tmp-ord.doc-date
      tmp-ord.host-code  COLUMN-LABEL "Фирма"
      tmp-ord.cli-type + " " + String(tmp-ord.cli-code) @ tmp-ord.cli-type COLUMN-LABEL "Код" FORMAT "x(9)"
      tmp-ord.cli-name
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 80.63 BY 15.5.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 2.13
     b-mark AT ROW 1 COL 14.13
     b-erase AT ROW 1 COL 18.13
     b-lkp AT ROW 1 COL 31.13
     b-del AT ROW 1 COL 43.13
     b-help AT ROW 1 COL 69.88
     BROWSE-3 AT ROW 2.21 COL 1.38
     SPACE(0.11) SKIP(0.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Неисполненные заказы".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tmp-ord T "?" NO-UNDO ub ub.ord-doc
      ADDITIONAL-FIELDS:
          field mm as log
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BROWSE-3 b-help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-3
/* Query rebuild information for BROWSE BROWSE-3
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tmp-ord NO-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-3 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Неисполненные заказы */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
  run procdel in this-procedure .
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-erase
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-erase Dialog-Frame
ON CHOOSE OF b-erase IN FRAME Dialog-Frame /* Снять все * */
DO:
  For each Tmp-ord share-lock :
      Tmp-ord.mm = false.
  End.
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
define variable v-doc-rec as recid no-undo .

  find first SHAR-BUF_ORD-DOC no-lock where SHAR-BUF_ORD-DOC.doc-code = tmp-ord.doc-code no-error .
  if error-status :error then return .
  run cus/ord-zakz.p
    ( input parParentProc ,
      input {&lookup} ,
      input shar-buf_ord-doc.doc-type ,
      output v-doc-rec ,
      input-output br-handle  ,
      input-output bf-handle ,
      input-output next-prev
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
OR MOUSE-SELECT-DBLCLICK OF {&BROWSE-name} IN FRAME {&frame-name}
DO:
  if not available tmp-ord then do:
     message "Неправильный выбор строки.".
     return no-apply.
     end.
   IF     tmp-ord.mm = true THEN DO:
           tmp-ord.mm = false.
           disp "" @ Tmp-ord.mm with browse {&browse-name}.
    End.
    Else DO:
           tmp-ord.mm = true.
           disp "*" @ tmp-ord.mm with browse {&browse-name}.
    End.
     apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.
     apply "ROW-DISPLAY" to {&browse-name} in frame {&frame-name}.

     g#log = {&browse-name}:select-next-row ().
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-3
&Scoped-define SELF-NAME BROWSE-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-3 Dialog-Frame
ON ROW-DISPLAY OF BROWSE-3 IN FRAME Dialog-Frame
DO:

if tmp-ord.mm = true then DO:
      tmp-ord.mm          :fgcolor in browse {&browse-name} = brown_color.
      tmp-ord.doc-code    :fgcolor in browse {&browse-name} = brown_color.
      tmp-ord.flag_       :fgcolor in browse {&browse-name} = brown_color.
      tmp-ord.status_     :fgcolor in browse {&browse-name} = brown_color.
      tmp-ord.doc-date    :fgcolor in browse {&browse-name} = brown_color.
      tmp-ord.host-code   :fgcolor in browse {&browse-name} = brown_color.
      tmp-ord.cli-type    :fgcolor in browse {&browse-name} = brown_color.
      tmp-ord.cli-name    :fgcolor in browse {&browse-name} = brown_color.


  End.
  Else DO:
      tmp-ord.mm          :fgcolor in browse {&browse-name} = black_color.
      tmp-ord.doc-code    :fgcolor in browse {&browse-name} = black_color.
      tmp-ord.flag_       :fgcolor in browse {&browse-name} = black_color.
      tmp-ord.status_     :fgcolor in browse {&browse-name} = black_color.
      tmp-ord.doc-date    :fgcolor in browse {&browse-name} = black_color.
      tmp-ord.host-code   :fgcolor in browse {&browse-name} = black_color.
      tmp-ord.cli-type    :fgcolor in browse {&browse-name} = black_color.
      tmp-ord.cli-name    :fgcolor in browse {&browse-name} = black_color.
  End.
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
run maketmp in this-procedure .
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
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
  ENABLE b-quit b-mark b-erase b-lkp b-del b-help BROWSE-3
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE maketmp Dialog-Frame
PROCEDURE maketmp :
define variable  t-ret as logical no-undo .
t-ret =  session:SET-WAIT-STATE("GENERAL") .
For each ub.ord-doc where
             ub.ord-doc.host-code = v-cntxt-host-code-obj and
             ub.ord-doc.doc-date >= date1 and
             ub.ord-doc.doc-date <= date2 and
             ub.ord-doc.doc-type  = g#type   and
             /* ub.ord-doc.flag_     = true     and
                ub.ord-doc.status_   = {&fact}  and  */
          Not can-find
             (first  ub.trn-doc where
                      ub.trn-doc.host-code =  ub.ord-doc.host-code and
                      ub.trn-doc.ord-num   =  ub.ord-doc.doc-code  no-lock )  no-lock :
            Create tmp-ord.
            Buffer-copy ub.ord-doc to tmp-ord.

    End.
    t-ret =  session:SET-WAIT-STATE("") .
END PROCEDURE.

procedure procdel:
define variable v-ii as integer no-undo .
define variable v-ss like Tmp-ord.doc-code no-undo .
define variable  t-ret as logical no-undo .
g#log = false .
message "Удалять отмеченные заказы ?" view-as alert-box question Buttons Yes-No Title "Вопрос" update g#log .
IF g#log = true then do:
t-ret =  session:SET-WAIT-STATE("GENERAL") .
  FOR EACH  Tmp-ord WHERE Tmp-ord.mm = true share-LOCK :
     find ub.ord-doc where  Tmp-ord.doc-code = ub.ord-doc.doc-code and  Tmp-ord.doc-date = ub.ord-doc.doc-date share-lock.
     v-ii =  v-ii + 1.
     v-ss = "Закааз № "  + Tmp-ord.doc-code.
     delete ub.ord-doc .
     delete Tmp-ord .
  END.
  t-ret =  session:SET-WAIT-STATE("") .
 End.
 End procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME