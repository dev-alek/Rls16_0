&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
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

Товары в пути для заказов

Автор: Чернова Светлана Александровна
Дата создания: 03/09/02
Author: Svetlana Chernova
Creation date: 03/09/02

*/
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Товары в пути для заказов".
{ cmp/vssrevis.i  }
{ cmp/str-glbl.i   }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }


DEFINE INPUT  PARAMETER PARPARENTPROC  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-artic   like ub.goods.artic no-undo .
define input parameter p-prod-type like ub.goods.prod-type no-undo .
define input parameter p-prod-code like ub.goods.prod-code no-undo .
define input parameter p-type      as integer no-undo  .
define input parameter p-LOC-DATE-SHIP as date no-undo .
define input parameter p-DATE-sale-1 as date no-undo .
define input parameter p-DATE-sale-2 as date no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-doc-type   like ub.ord-doc.doc-type no-undo .

define variable v-log as logical   no-undo .
define variable br-handle as handle no-undo .
define variable bf-handle  as handle no-undo .
define variable next-prev  as logical   no-undo .
define new shared buffer shar-buf_ord-doc for ub.ord-doc  .

{ gbl/getcntxt.i get }

define variable v-cntxt-host-name-obj as character no-undo .
{ gbl/hostname.i p-obj-type p-obj-code v-cntxt-host-code-obj v-cntxt-host-name-obj }


define variable doc-rec as recid no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-docs

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.ord-line ub.ord-doc ub.goods

/* Definitions for BROWSE br-docs                                       */
&Scoped-define FIELDS-IN-QUERY-br-docs ub.ord-line.doc-code ub.ord-doc.doc-type ub.ord-doc.status_ ub.ord-doc.doc-date ub.ord-line.qnty ub.ord-doc.obj-type + " " + string (ub.ord-doc.obj-code) ub.ord-doc.cli-type + " " + string (ub.ord-doc.cli-code) ub.ord-doc.ship-date ub.ord-doc.date-sale-1 ub.ord-doc.date-sale-2
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-docs
&Scoped-define SELF-NAME br-docs
&Scoped-define OPEN-QUERY-br-docs v-log =  session:SET-WAIT-STATE("GENERAL") . OPEN QUERY {&SELF-NAME} FOR EACH ub.ord-line NO-LOCK where ub.ord-line.artic     = p-artic and ub.ord-line.prod-type = p-prod-type and ub.ord-line.prod-code = p-prod-code   , ~
             EACH ub.ord-doc OF ub.ord-line NO-LOCK       WHERE ub.ord-doc.doc-type <> ~{&P-O} AND           ( ub.ord-doc.status_ = ~{&ord-close}              OR              ub.ord-doc.status_ = ~{&ord-rcv} )              and              (            if p-type = 1 then                ( ub.ord-doc.ship-date <=  p-LOC-DATE-SHIP )                else                ( ub.ord-doc.DATE-sale-1 <= p-date-sale-2 and                  ub.ord-doc.DATE-sale-2 >= p-date-sale-1)                  )                  and      ( if p-doc-type = ~{&f-p} then        (ub.ord-doc.host-code = v-cntxt-host-code-obj)        else        (ub.ord-doc.obj-code = p-obj-code  and         ub.ord-doc.obj-type = p-obj-type        )        ). v-log =  session:SET-WAIT-STATE("") .
&Scoped-define TABLES-IN-QUERY-br-docs ub.ord-line ub.ord-doc
&Scoped-define FIRST-TABLE-IN-QUERY-br-docs ub.ord-line
&Scoped-define SECOND-TABLE-IN-QUERY-br-docs ub.ord-doc


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame ub.goods.gds-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame ub.goods.gds-name
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame ub.goods
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame ub.goods
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-docs}
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH ub.goods ~
      WHERE ub.goods.artic = v-artic ~
 AND ub.goods.prod-code = v-prod-code ~
 AND ub.goods.prod-type = v-prod-type NO-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH ub.goods ~
      WHERE ub.goods.artic = v-artic ~
 AND ub.goods.prod-code = v-prod-code ~
 AND ub.goods.prod-type = v-prod-type NO-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame ub.goods
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame ub.goods


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS ub.goods.gds-name
&Scoped-define ENABLED-TABLES ub.goods
&Scoped-define FIRST-ENABLED-TABLE ub.goods
&Scoped-Define ENABLED-OBJECTS B-exit B-lkp B-Help br-docs v-artic ~
v-prod-type v-prod-code v-user-name
&Scoped-Define DISPLAYED-FIELDS ub.goods.gds-name
&Scoped-define DISPLAYED-TABLES ub.goods
&Scoped-define FIRST-DISPLAYED-TABLE ub.goods
&Scoped-Define DISPLAYED-OBJECTS v-artic v-prod-type v-prod-code ~
v-user-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-END-KEY
     LABEL "Вы&ход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-lkp AUTO-END-KEY
     LABEL "Просмотр"
     SIZE 10 BY 1 TOOLTIP "Просмотр документа"
     BGCOLOR 8 .

DEFINE VARIABLE v-artic AS CHARACTER FORMAT "X(256)":U
     LABEL "Товар"
      VIEW-AS TEXT
     SIZE 15.25 BY .67 NO-UNDO.

DEFINE VARIABLE v-prod-code AS INTEGER FORMAT "->>>>>>>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 9.88 BY .67 NO-UNDO.

DEFINE VARIABLE v-prod-type AS CHARACTER FORMAT "XXX":U
     LABEL "Пр-ль"
      VIEW-AS TEXT
     SIZE 4.25 BY .67 NO-UNDO.

DEFINE VARIABLE v-user-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Опер"
      VIEW-AS TEXT
     SIZE 15 BY .67
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-docs FOR
      ub.ord-line,
      ub.ord-doc SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      ub.goods SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-docs Dialog-Frame _FREEFORM
  QUERY br-docs NO-LOCK DISPLAY
      ub.ord-line.doc-code
  ub.ord-doc.doc-type FORMAT "X(2)"
  ub.ord-doc.status_
  ub.ord-doc.doc-date FORMAT "99/99/99"
  ub.ord-line.qnty COLUMN-LABEL "Заказано" FORMAT "->>>>>>>9.<<<"
  ub.ord-doc.obj-type  + " " + string (ub.ord-doc.obj-code) COLUMN-LABEL "Объект"      FORMAT "X(10)"
  ub.ord-doc.cli-type  + " " + string (ub.ord-doc.cli-code) COLUMN-LABEL "Поставщик"   FORMAT "X(10)"
  ub.ord-doc.ship-date COLUMN-LABEL "Поставка"
  ub.ord-doc.date-sale-1 COLUMN-LABEL "Продажа с" FORMAT "99/99/99"
  ub.ord-doc.date-sale-2 FORMAT "99/99/99"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.88 BY 11.88.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-lkp AT ROW 1 COL 11
     B-Help AT ROW 1.04 COL 89.38
     br-docs AT ROW 4.46 COL 1
     v-artic AT ROW 2.21 COL 9.25 COLON-ALIGNED
     ub.goods.gds-name AT ROW 2.21 COL 25.75 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 67.88 BY .67
          FGCOLOR 4
     v-prod-type AT ROW 3.13 COL 9.38 COLON-ALIGNED
     v-prod-code AT ROW 3.17 COL 14.25 COLON-ALIGNED NO-LABEL
     v-user-name AT ROW 16.54 COL 5.5 COLON-ALIGNED WIDGET-ID 2
     SPACE(77.49) SKIP(0.25)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Товары в пути".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-docs B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN ub.goods.gds-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-docs
/* Query rebuild information for BROWSE br-docs
     _START_FREEFORM
v-log =  session:SET-WAIT-STATE("GENERAL") .
OPEN QUERY {&SELF-NAME} FOR EACH ub.ord-line NO-LOCK where
ord-line.artic     = p-artic and
ord-line.prod-type = p-prod-type and
ord-line.prod-code = p-prod-code   ,
      EACH ub.ord-doc OF ub.ord-line NO-LOCK
      WHERE ub.ord-doc.doc-type <> ~{&P-O} AND
          ( ub.ord-doc.status_ = ~{&ord-close}
             OR
             ub.ord-doc.status_ = ~{&ord-rcv} )
             and
             (
           if p-type = 1 then
               ( ub.ord-doc.ship-date <=  p-LOC-DATE-SHIP )
               else
               ( ub.ord-doc.DATE-sale-1 <= p-date-sale-2 and
                 ub.ord-doc.DATE-sale-2 >= p-date-sale-1)
                 )
                 and
     ( if p-doc-type = ~{&f-p} then
       (ub.ord-doc.host-code = v-cntxt-host-code-obj)
       else
       (ub.ord-doc.obj-code = p-obj-code  and
        ub.ord-doc.obj-type = p-obj-type
       )
       ).
v-log =  session:SET-WAIT-STATE("") .
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Where[2]         = "ord-doc.status_ = ~{&ord-close}
 OR ub.ord-doc.status_ = ~{&ord-rcv}"
     _Query            is OPENED
*/  /* BROWSE br-docs */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "ub.goods"
     _Options          = "NO-LOCK"
     _Where[1]         = "goods.artic = v-artic
 AND ub.goods.prod-code = v-prod-code
 AND ub.goods.prod-type = v-prod-type"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Товары в пути */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lkp Dialog-Frame
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
   define variable ri-list as char no-undo .
    define variable old-rep-rec as recid no-undo.
    define variable old-doc-rec as recid no-undo.
    define variable old-list-mode as character no-undo.

next-prev = no.
br-handle = br-docs:handle.
do while next-prev <> ?:
  if not available ub.ord-doc then do:
    message "Неправильный выбор документа.".
    return no-apply.
  end.
    find first shar-buf_ord-doc no-lock
        where shar-buf_ord-doc.doc-code = ub.ord-doc.doc-code
        no-error .
       bf-handle = buffer shar-buf_ord-doc:handle in frame {&frame-name} .
   run cus/lkp-zakz.w
     ( input parparentproc ,
       input-output br-handle ,
       input-output bf-handle ,
       input-output next-prev
     )
      no-error.
end.
if br-handle = ? then reposition br-docs to recid doc-rec no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-docs
&Scoped-define SELF-NAME br-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-docs Dialog-Frame
ON VALUE-CHANGED OF br-docs IN FRAME Dialog-Frame
DO:
  if available ub.ord-doc then do:
    { gbl/usrfulnm.i
      ub.ord-doc.creid
      v-user-name }
  end.
  display v-user-name  with fram {&frame-name} .

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
   assign
   v-artic     = p-artic
   v-prod-type = p-prod-type
   v-prod-code = p-prod-code
   .
   if p-type = 1 then do:
      frame {&frame-name}:title = "Заказаные товары в пути до даты поставки " + string (p-LOC-DATE-SHIP , "99/99/9999" ) +
      if p-doc-type = {&f-p} then
      ( " По фирме " + v-cntxt-host-name-obj )
      else
      ( " По объекту " + p-obj-type + " ("+ string(p-obj-code) +   ")")
      .
   end.
   if p-type = 2 then do:
      frame {&frame-name}:title = "Заказаные товары в пути на период продаж с " + string (p-DATE-sale-1 , "99/99/9999" )  +
                                  " по "  + string (p-DATE-sale-2 , "99/99/9999" )   .
   end.

  run enable_ui in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI in this-procedure .

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
  DISPLAY v-artic v-prod-type v-prod-code v-user-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.goods THEN
    DISPLAY ub.goods.gds-name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-lkp B-Help br-docs v-artic ub.goods.gds-name v-prod-type
         v-prod-code v-user-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
