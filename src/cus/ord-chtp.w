&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выбор типа схемы создания заявок под заказ покупател

Автор: Чернова Светлана Александровна
Дата создания: 08/23/06
Author: Svetlana Chernova
Creation date: 08/23/06

Выбор типа схемы создания заявок под заказ покупателя (когда нет в наличии товара)
и создание заявки

*/

define input parameter  parParentProc  as widget-handle no-undo.
define input parameter  p-recid        as recid no-undo . /* заказа  покупателя */
define output parameter p-rez          as logical  no-undo .
define output parameter p-ord-doc      as character no-undo . /* заявка  ОО/ОР/ОФ  */


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор типа схемы создания заявок под заказ покупател ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/waitfram.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ cus/ord-code.i def }
define buffer buf_clients for ub.clients  .
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-Cancel B-save B-help scr-doc-type
&Scoped-Define DISPLAYED-OBJECTS scr-doc-type FILL-IN-1

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

DEFINE BUTTON B-help
     LABEL "Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-save AUTO-GO
     LABEL "Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Типы заявок:"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE scr-doc-type AS INTEGER INITIAL 4
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Объект-Фирма", 1,
"Объект-Объект", 2,
"Объект-РЦ", 3,
"Не создавать", 4
     SIZE 18 BY 4.25 TOOLTIP "Типы заявок" NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-save AT ROW 1 COL 1
     B-Cancel AT ROW 1 COL 11
     B-help AT ROW 1 COL 55
     scr-doc-type AT ROW 3.25 COL 3 NO-LABEL
     FILL-IN-1 AT ROW 2.5 COL 3 NO-LABEL
     SPACE(48.13) SKIP(9.11)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Заявки под покупателя"
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
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN-1 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
ASSIGN
       FILL-IN-1:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Заявки под покупателя */
DO:
    ASSIGN scr-doc-type.
    IF scr-doc-type <> 4 THEN DO:
       RUN create-ord-doc in this-procedure .
    END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Заявки под покупателя */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-Cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-Cancel Dialog-Frame
ON CHOOSE OF B-Cancel IN FRAME Dialog-Frame /* Отмена */
DO:
  /**/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-save Dialog-Frame
ON CHOOSE OF B-save IN FRAME Dialog-Frame /* Сохранить */
DO:
  /**/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
{ gbl/app_help.i }
/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN init-proc in this-procedure .
  RUN enable_UI in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-ord-doc Dialog-Frame
PROCEDURE create-ord-doc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
/* Создание заявки */
define variable v-doc-type as character no-undo .
define variable v-cli-type as character no-undo .
define variable v-cli-code as integer   no-undo .
define variable v-cli-name as character no-undo .

define buffer buf_ord-doc for ub.ord-doc  .
find first buf_ord-doc no-lock  where
      recid ( buf_ord-doc ) = p-recid no-error .

  case scr-doc-type :
      when 1 then do:
      find first buf_clients no-lock where buf_clients.obj-type = {&cmp}  and buf_clients.obj-code = buf_ord-doc.host-code no-error .
        v-doc-type = {&o-f} .
        v-cli-type = {&cmp} .
        v-cli-code = buf_ord-doc.host-code .
        v-cli-name = buf_clients.obj-name .
      end.
      when 2 then do:
        v-doc-type = {&o-o} .
        v-cli-type = "" .
        v-cli-code = 0 .

      end.
      when 3 then do:
        v-doc-type = {&o-r} .
        v-cli-type = "" .
        v-cli-code = 0 .

      end.
      otherwise do:
        return .
      end.
  end case.



define variable v-i-doc as character no-undo .
{ cus/ord-code.i
    'main'
    v-cntxt-db-num
    v-cntxt-obj-type
    v-cntxt-obj-code
    v-i-doc
    p-ord-doc
    }
define buffer buf_gds-obj   for ub.gds-obj  .
define buffer buf_ord-line  for ub.ord-line.
define buffer buf_ord-dtl   for ub.ord-dtl.

create ub.ord-doc.
buffer-copy buf_ord-doc to ub.ord-doc
   assign
      ub.ord-doc.doc-code  = p-ord-doc
      ub.ord-doc.doc-type  = v-doc-type
      ub.ord-doc.doc-date  = today
      ub.ord-doc.date-sale-1   = buf_ord-doc.ship-date
      ub.ord-doc.date-sale-2   = buf_ord-doc.ship-date
      ub.ord-doc.cli-code  = v-cli-code
      ub.ord-doc.cli-type  = v-cli-type
      ub.ord-doc.cli-name  = v-cli-name
      ub.ord-doc.buyer-out-code  = buf_ord-doc.doc-code
      ub.ord-doc.flag_     = false
      ub.ord-doc.status_   = {&g___new}
   .

for each buf_ord-line no-lock where
         buf_ord-line.doc-code = buf_ord-doc.doc-code
         :
         find first buf_gds-obj no-lock where
                    buf_gds-obj.obj-type = buf_ord-doc.obj-type and
                    buf_gds-obj.obj-code = buf_ord-doc.obj-code and
                    buf_gds-obj.gds-code = buf_ord-line.gds-code no-error .
         if not available buf_gds-obj then do:
            create ub.ord-line.
                buffer-copy buf_ord-line to ub.ord-line
                assign
                  ub.ord-line.doc-code  = p-ord-doc
                  .
         end.
         else do:
            if buf_ord-line.qnty > buf_gds-obj.free-qnty  then do:
                create ub.ord-line.
                    buffer-copy buf_ord-line to ub.ord-line
                    assign
                      ub.ord-line.doc-code   = p-ord-doc
                      ub.ord-line.qnty       = buf_ord-line.qnty - buf_gds-obj.free-qnty
                      ub.ord-line.fact-qnty  = ub.ord-line.qnty
                      ub.ord-line.cli-qnty   = ub.ord-line.qnty  * buf_ord-line.cli-base-rate
                      ub.ord-line.price-rubl = buf_gds-obj.last-rubl
                      ub.ord-line.price-base = buf_gds-obj.last-base
                      .
            end.
         end.
end.

for each buf_ord-dtl no-lock where
         buf_ord-dtl.doc-code = buf_ord-doc.doc-code
         :
         create ub.ord-dtl.
         buffer-copy buf_ord-dtl to ub.ord-dtl
         assign
           ub.ord-dtl.doc-code  = p-ord-doc
           .
end.

p-rez = true .

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
  DISPLAY scr-doc-type FILL-IN-1
      WITH FRAME Dialog-Frame.
  ENABLE B-Cancel B-save B-help scr-doc-type
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
p-rez = false .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME