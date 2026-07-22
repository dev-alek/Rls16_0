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

Экран ПФО по удаленному документу

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/

/* ***************************  Definitions  ************************** */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Экран финансовых обязательств по удаленному документу".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER pardoc-code LIKE ub.c-trn-doc.doc-code NO-UNDO.
define input parameter parchip-num like ub.c-trn-doc.chip-num no-undo.

/* Local Variable Definitions ---                                       */
DEFINE TEMP-TABLE tt-fo-before NO-UNDO LIKE ub.fin-ob-before
FIELD sum-base-trn LIKE ub.fin-ob.sum-base
FIELD sum-rubl-trn LIKE ub.fin-ob.sum-rubl.

DEFINE BUFFER bf_fin-ob-before   FOR ub.fin-ob-before.
DEFINE BUFFER bf_fin-gds-part  FOR ub.fin-gds-part.
DEFINE BUFFER bf_c-parts         FOR ub.c-parts.
DEFINE BUFFER bf_c-trn-doc       FOR ub.c-trn-doc.
define buffer bf_goods           for ub.goods.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME b-ob

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-fo-before bf_fin-gds-part bf_goods ~
bf_c-parts

/* Definitions for BROWSE b-ob                                          */
&Scoped-define FIELDS-IN-QUERY-b-ob tt-fo-before.prn-doc-code tt-fo-before.sum-base tt-fo-before.sum-base-trn tt-fo-before.sum-rubl tt-fo-before.sum-rubl-trn tt-fo-before.contract-code tt-fo-before.doc-code tt-fo-before.before-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-ob
&Scoped-define SELF-NAME b-ob
&Scoped-define QUERY-STRING-b-ob FOR EACH tt-fo-before
&Scoped-define OPEN-QUERY-b-ob OPEN QUERY {&SELF-NAME} FOR EACH tt-fo-before.
&Scoped-define TABLES-IN-QUERY-b-ob tt-fo-before
&Scoped-define FIRST-TABLE-IN-QUERY-b-ob tt-fo-before


/* Definitions for BROWSE b-parts                                       */
&Scoped-define FIELDS-IN-QUERY-b-parts bf_c-parts.in-code bf_c-parts.part-code bf_c-parts.fact-qnty bf_c-parts.price-base bf_c-parts.price-rubl
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-parts
&Scoped-define SELF-NAME b-parts
&Scoped-define QUERY-STRING-b-parts FOR EACH bf_fin-gds-part no-lock, ~
       FIRST bf_goods no-lock, ~
       FIRST bf_c-parts NO-LOCK
&Scoped-define OPEN-QUERY-b-parts OPEN QUERY {&SELF-NAME} FOR EACH bf_fin-gds-part no-lock, ~
       FIRST bf_goods no-lock, ~
       FIRST bf_c-parts NO-LOCK.
&Scoped-define TABLES-IN-QUERY-b-parts bf_fin-gds-part bf_goods bf_c-parts
&Scoped-define FIRST-TABLE-IN-QUERY-b-parts bf_fin-gds-part
&Scoped-define SECOND-TABLE-IN-QUERY-b-parts bf_goods
&Scoped-define THIRD-TABLE-IN-QUERY-b-parts bf_c-parts


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-b-ob}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-help b-ob b-parts

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
DEFINE QUERY b-ob FOR
      tt-fo-before SCROLLING.

DEFINE QUERY b-parts FOR
      bf_fin-gds-part,
      bf_goods,
      bf_c-parts SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE b-ob
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-ob Dialog-Frame _FREEFORM
  QUERY b-ob DISPLAY
      tt-fo-before.prn-doc-code  COLUMN-LABEL "Предфиноб."
  tt-fo-before.sum-base      FORMAT "->>>,>>>,>>>,>>9.99" COLUMN-LABEL "Общая сумма (вал)"
  tt-fo-before.sum-base-trn  FORMAT "->>>,>>>,>>>,>>9.99" COLUMN-LABEL "Сумма по док. (вал)"
  tt-fo-before.sum-rubl      FORMAT "->>>,>>>,>>>,>>9.99" COLUMN-LABEL "Общая сумма (abbr_rub)"
  tt-fo-before.sum-rubl-trn  FORMAT "->>>,>>>,>>>,>>9.99" COLUMN-LABEL "Сумма по док. (abbr_rub)"
  tt-fo-before.contract-code COLUMN-LABEL "Договор"
  tt-fo-before.doc-code      COLUMN-LABEL "Вн. код. фин. обяз."
  tt-fo-before.before-code   COLUMN-LABEL "Вн. код. предфин. обяз."
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.5 BY 9
         TITLE "Предфинобязательства" ROW-HEIGHT-CHARS .67.

DEFINE BROWSE b-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-parts Dialog-Frame _FREEFORM
  QUERY b-parts DISPLAY
      bf_c-parts.in-code COLUMN-LABEL "Прих. накл."
 bf_c-parts.part-code COLUMN-LABEL "Код партии"
 bf_c-parts.fact-qnty COLUMN-LABEL "Факт кол-во"
 bf_c-parts.price-base COLUMN-LABEL "Цена (вал)"
 bf_c-parts.price-rubl COLUMN-LABEL "Цена (abbr_rub)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.5 BY 9
         TITLE "Партии по предфинобязательству" ROW-HEIGHT-CHARS .67.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-help AT ROW 1 COL 11
     b-ob AT ROW 2.25 COL 1
     b-parts AT ROW 11.5 COL 1
     SPACE(0.00) SKIP(0.50)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Предфинобязательства на которые повлиял данный удаленный складской документ"
         DEFAULT-BUTTON b-exit.


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
/* BROWSE-TAB b-ob b-help Dialog-Frame */
/* BROWSE-TAB b-parts b-ob Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-ob
/* Query rebuild information for BROWSE b-ob
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-fo-before.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE b-ob */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-parts
/* Query rebuild information for BROWSE b-parts
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH bf_fin-gds-part no-lock, FIRST bf_goods no-lock, FIRST bf_c-parts NO-LOCK.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE b-parts */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Предфинобязательства на которые повлиял данный удаленный складской документ */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b-ob
&Scoped-define SELF-NAME b-ob
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-ob Dialog-Frame
ON VALUE-CHANGED OF b-ob IN FRAME Dialog-Frame /* Предфинобязательства */
DO:
  RUN open-parts-query IN THIS-PROCEDURE.
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
  FIND FIRST bf_c-trn-doc WHERE bf_c-trn-doc.doc-code = pardoc-code and
                                bf_c-trn-doc.chip-num = parchip-num NO-LOCK.
  RUN cr-tt-fo-before IN THIS-PROCEDURE.
  ASSIGN FRAME
  {&frame-name}:TITLE = "Предфинобязательства по удаленному складскому документу " + pardoc-code.
  assign
  tt-fo-before.sum-rubl:label in browse b-ob       = "Общая сумма ({&abbr_rub})"
  tt-fo-before.sum-rubl-trn:label in browse b-ob   = "Сумма по док. ({&abbr_rub})"
  bf_c-parts.price-rubl:label in browse b-parts    = "Цена ({&abbr_rub})"
  .

  RUN enable_UI.
  RUN open-parts-query IN THIS-PROCEDURE.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cr-tt-fo-before Dialog-Frame
PROCEDURE cr-tt-fo-before :
FOR EACH bf_fin-gds-part WHERE bf_fin-gds-part.obj-type = bf_c-trn-doc.obj-type AND
                                 bf_fin-gds-part.obj-code = bf_c-trn-doc.obj-code AND
                                 bf_fin-gds-part.out-code = bf_c-trn-doc.doc-code NO-LOCK ON ERROR UNDO, RETURN ERROR RETURN-VALUE :
    FIND FIRST bf_fin-ob-before WHERE bf_fin-ob-before.host-code = bf_fin-gds-part.host-code   AND
                                      bf_fin-ob-before.before-code  = bf_fin-gds-part.fin-ob-code NO-LOCK no-error.
    if available bf_fin-ob-before then do:
      FIND FIRST tt-fo-before WHERE tt-fo-before.host-code = bf_fin-ob-before.host-code AND
                                    tt-fo-before.doc-code  = bf_fin-ob-before.doc-code  NO-ERROR.
      if not available tt-fo-before then do:
        create tt-fo-before.
        buffer-copy bf_fin-ob-before to tt-fo-before.
      end.
      ASSIGN
        tt-fo-before.sum-base-trn = tt-fo-before.sum-base-trn + bf_fin-gds-part.sum-base
        tt-fo-before.sum-rubl-trn = tt-fo-before.sum-rubl-trn + bf_fin-gds-part.sum-rubl
      .
   end.
END.
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
  ENABLE b-exit b-help b-ob b-parts
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE open-parts-query Dialog-Frame
PROCEDURE open-parts-query :
IF AVAILABLE tt-fo-before THEN DO:
    OPEN QUERY b-parts
        FOR EACH bf_fin-gds-part WHERE bf_fin-gds-part.host-code   = tt-fo-before.host-code   and
                                         bf_fin-gds-part.fin-ob-code = tt-fo-before.before-code  and
                                         bf_fin-gds-part.out-code    = pardoc-code            no-lock,
        first bf_goods where bf_goods.gds-code = bf_fin-gds-part.gds-code no-lock,
        FIRST bf_c-parts WHERE bf_c-parts.obj-type  = bf_fin-gds-part.obj-type AND
                               bf_c-parts.obj-code  = bf_fin-gds-part.obj-code AND
                               bf_c-parts.artic     = bf_goods.artic AND
                               bf_c-parts.prod-type = bf_goods.prod-type AND
                               bf_c-parts.prod-code = bf_goods.prod-code AND
                               bf_c-parts.in-code   = bf_fin-gds-part.in-code AND
                               bf_c-parts.out-code  = bf_fin-gds-part.out-code AND
                               bf_c-parts.chip-num  = parchip-num  and
                               bf_c-parts.part-code = bf_fin-gds-part.part-code NO-LOCK.
    DISPLAY b-parts WITH FRAME {&FRAME-NAME}.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME