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

Экран просмотра платежей по удаленному складскому документу

Автор: Чернова Светлана Александровна
Дата создания: 11/20/06
Author: Svetlana Chernova
Creation date: 11/20/06

create: Суслов Алексей Юрьевич
Дата создания: 03/24/06


*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER pardoc-code LIKE ub.c-trn-doc.doc-code NO-UNDO.
define input parameter parchip-num like ub.c-trn-doc.chip-num no-undo.

/* Local Variable Definitions ---      */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Экран просмотра платежей по складскому документу".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }

DEFINE TEMP-TABLE tt-fo NO-UNDO LIKE ub.fin-ob
FIELD sum-base-trn LIKE ub.fin-ob.sum-base
FIELD sum-rubl-trn LIKE ub.fin-ob.sum-rubl.
DEFINE TEMP-TABLE tt-fd NO-UNDO LIKE ub.fin-doc
FIELD sum-base-fo LIKE ub.fin-doc.sum-base
FIELD sum-rubl-fo LIKE ub.fin-doc.sum-rubl.

define buffer bf_c-trn-doc    for ub.c-trn-doc.
define buffer bf_fin-connect  for ub.fin-connect.
define buffer bf_c-parts      for ub.c-parts.
define buffer bf_fin-gds-part for ub.fin-gds-part.
define buffer bf_goods        for ub.goods.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME b-fin-doc

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-fd tt-fo bf_fin-connect bf_fin-gds-part ~
bf_goods bf_c-parts

/* Definitions for BROWSE b-fin-doc                                     */
&Scoped-define FIELDS-IN-QUERY-b-fin-doc tt-fd.prn-doc-code tt-fd.contract-code tt-fd.sum-base tt-fd.sum-base-fo tt-fd.sum-rubl tt-fd.sum-rubl-fo tt-fd.fin-doc-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-fin-doc
&Scoped-define SELF-NAME b-fin-doc
&Scoped-define QUERY-STRING-b-fin-doc FOR EACH tt-fd
&Scoped-define OPEN-QUERY-b-fin-doc OPEN QUERY {&SELF-NAME} FOR EACH tt-fd.
&Scoped-define TABLES-IN-QUERY-b-fin-doc tt-fd
&Scoped-define FIRST-TABLE-IN-QUERY-b-fin-doc tt-fd


/* Definitions for BROWSE b-fin-ob                                      */
&Scoped-define FIELDS-IN-QUERY-b-fin-ob tt-fo.prn-doc-code tt-fo.sum-base bf_fin-connect.sum-base tt-fo.sum-base-trn tt-fo.sum-rubl bf_fin-connect.sum-rubl tt-fo.sum-rubl-trn tt-fo.doc-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-fin-ob
&Scoped-define SELF-NAME b-fin-ob
&Scoped-define QUERY-STRING-b-fin-ob FOR EACH tt-fo, ~
       FIRST bf_fin-connect
&Scoped-define OPEN-QUERY-b-fin-ob OPEN QUERY {&SELF-NAME} FOR EACH tt-fo, ~
       FIRST bf_fin-connect.
&Scoped-define TABLES-IN-QUERY-b-fin-ob tt-fo bf_fin-connect
&Scoped-define FIRST-TABLE-IN-QUERY-b-fin-ob tt-fo
&Scoped-define SECOND-TABLE-IN-QUERY-b-fin-ob bf_fin-connect


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

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-help b-fin-doc b-fin-ob b-parts

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
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY b-fin-doc FOR
      tt-fd SCROLLING.

DEFINE QUERY b-fin-ob FOR
      tt-fo,
      bf_fin-connect SCROLLING.

DEFINE QUERY b-parts FOR
      bf_fin-gds-part,
      bf_goods,
      bf_c-parts SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE b-fin-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-fin-doc Dialog-Frame _FREEFORM
  QUERY b-fin-doc DISPLAY
      tt-fd.prn-doc-code  COLUMN-LABEL "Платеж"
 tt-fd.contract-code COLUMN-LABEL "Договор"
 tt-fd.sum-base FORMAT "->>>,>>>,>>>,>>9.99" COLUMN-LABEL "Сумма платежа (вал)"
 tt-fd.sum-base-fo FORMAT "->>>,>>>,>>>,>>9.99" COLUMN-LABEL "Сумма связей c ФО (вал)"
 tt-fd.sum-rubl FORMAT "->>>,>>>,>>>,>>9.99" COLUMN-LABEL "Сумма платежа (вал)"
 tt-fd.sum-rubl-fo FORMAT "->>>,>>>,>>>,>>9.99" COLUMN-LABEL "Сумма связей С ФО (abbr_rub)"
 tt-fd.fin-doc-code COLUMN-LABEL "Вн. код платежа"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.5 BY 6
         TITLE "Платежи".

DEFINE BROWSE b-fin-ob
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-fin-ob Dialog-Frame _FREEFORM
  QUERY b-fin-ob DISPLAY
      tt-fo.prn-doc-code COLUMN-LABEL "Фин. обяз."
 tt-fo.sum-base FORMAT "->>>,>>>,>>>,>>9.99" COLUMN-LABEL "Общая сумма (вал)"
 bf_fin-connect.sum-base FORMAT "->>>,>>>,>>>,>>9.99" COLUMN-LABEL "Сумма связи (вал)"
 tt-fo.sum-base-trn FORMAT "->>>,>>>,>>>,>>9.99" COLUMN-LABEL "Сумма по док. (вал)"
 tt-fo.sum-rubl FORMAT "->>>,>>>,>>>,>>9.99" COLUMN-LABEL "Общая сумма (abbr_rub)"
 bf_fin-connect.sum-rubl FORMAT "->>>,>>>,>>>,>>9.99" COLUMN-LABEL "Сумма связи (abbr_rub)"
 tt-fo.sum-rubl-trn FORMAT "->>>,>>>,>>>,>>9.99" COLUMN-LABEL "Сумма по док. (abbr_rub)"
 tt-fo.doc-code COLUMN-LABEL "Вн. код. фин. обяз."
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.5 BY 6
         TITLE "Финансовые обязательства, связанные с платежом".

DEFINE BROWSE b-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-parts Dialog-Frame _FREEFORM
  QUERY b-parts DISPLAY
      bf_c-parts.in-code COLUMN-LABEL "Прих. накл."
 bf_c-parts.part-code  FORMAT "x(13)" COLUMN-LABEL "Код партии"
 bf_c-parts.fact-qnty  COLUMN-LABEL "Факт кол-во"
 bf_c-parts.price-base COLUMN-LABEL "Цена (вал)"
 bf_c-parts.price-rubl COLUMN-LABEL "Цена (abbr_rub)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.5 BY 6
         TITLE "Партии по финансовому обязательству".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-help AT ROW 1 COL 11
     b-fin-doc AT ROW 2.25 COL 1
     b-fin-ob AT ROW 8.54 COL 1
     b-parts AT ROW 14.83 COL 1
     SPACE(0.00) SKIP(0.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Платежи, связанные со складским документом"
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
/* BROWSE-TAB b-fin-doc b-help Dialog-Frame */
/* BROWSE-TAB b-fin-ob b-fin-doc Dialog-Frame */
/* BROWSE-TAB b-parts b-fin-ob Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-fin-doc
/* Query rebuild information for BROWSE b-fin-doc
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-fd.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE b-fin-doc */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-fin-ob
/* Query rebuild information for BROWSE b-fin-ob
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-fo, FIRST bf_fin-connect.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE b-fin-ob */
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
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Платежи, связанные со складским документом */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b-fin-doc
&Scoped-define SELF-NAME b-fin-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-fin-doc Dialog-Frame
ON VALUE-CHANGED OF b-fin-doc IN FRAME Dialog-Frame /* Платежи */
DO:
  RUN open-query-fo IN THIS-PROCEDURE.
  RUN open-parts-query IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b-fin-ob
&Scoped-define SELF-NAME b-fin-ob
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-fin-ob Dialog-Frame
ON VALUE-CHANGED OF b-fin-ob IN FRAME Dialog-Frame /* Финансовые обязательства, связанные с платежом */
DO:
  RUN open-parts-query IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b-fin-doc
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
  ASSIGN FRAME
    {&FRAME-NAME}:TITLE = "Платежи по удаленному складскому документу " + pardoc-code.
  FIND FIRST bf_c-trn-doc WHERE bf_c-trn-doc.doc-code = pardoc-code and
                                bf_c-trn-doc.chip-num = parchip-num NO-LOCK.
  RUN cr-tt-fd IN THIS-PROCEDURE.
  assign
  tt-fd.sum-rubl-fo:label       in browse b-fin-doc = "Сумма связей С ФО ({&abbr_rub})"
  tt-fo.sum-rubl:label          in browse b-fin-ob  = "Общая сумма ({&abbr_rub})"
  bf_fin-connect.sum-rubl:label in browse b-fin-ob  = "Сумма связи ({&abbr_rub})"
  tt-fo.sum-rubl-trn:label      in browse b-fin-ob  = "Сумма по док. ({&abbr_rub})"
  bf_c-parts.price-rubl:label   in browse b-parts   = "Цена ({&abbr_rub})"
  .
  RUN enable_UI.
  OPEN QUERY b-fin-doc FOR EACH tt-fd.
  RUN open-query-fo IN THIS-PROCEDURE.
  RUN open-parts-query IN THIS-PROCEDURE.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cr-tt-fd Dialog-Frame
PROCEDURE cr-tt-fd :
DEFINE BUFFER bf_fin-gds-part FOR ub.fin-gds-part.
DEFINE BUFFER bf_fin-ob       FOR ub.fin-ob.
DEFINE BUFFER bf_fin-connect  FOR ub.fin-connect.
DEFINE BUFFER bf_fin-doc      FOR ub.fin-doc.
do on error undo, return error return-value :
FOR EACH bf_fin-gds-part WHERE bf_fin-gds-part.obj-type = bf_c-trn-doc.obj-type AND
                               bf_fin-gds-part.obj-code = bf_c-trn-doc.obj-code AND
                               bf_fin-gds-part.out-code = bf_c-trn-doc.doc-code NO-LOCK ON ERROR UNDO, RETURN ERROR RETURN-VALUE :
  FIND FIRST bf_fin-ob WHERE bf_fin-ob.host-code = bf_fin-gds-part.host-code AND
                             bf_fin-ob.doc-code  = bf_fin-gds-part.fin-ob-code NO-LOCK no-error.
  if available bf_fin-ob then do:
    FIND FIRST tt-fo WHERE tt-fo.host-code = bf_fin-ob.host-code AND
                           tt-fo.doc-code  = bf_fin-ob.doc-code NO-ERROR.
    IF NOT AVAILABLE tt-fo THEN DO:
      CREATE tt-fo.
      BUFFER-COPY bf_fin-ob TO tt-fo.
    END.
    ASSIGN
      tt-fo.sum-base-trn = tt-fo.sum-base-trn + bf_fin-gds-part.sum-base
      tt-fo.sum-rubl-trn = tt-fo.sum-rubl-trn + bf_fin-gds-part.sum-rubl.
  end.
END.
FOR EACH tt-fo ON ERROR UNDO, RETURN ERROR RETURN-VALUE :
  FOR EACH bf_fin-connect WHERE bf_fin-connect.host-code   = tt-fo.host-code AND
                                bf_fin-connect.fin-ob-code = tt-fo.doc-code  NO-LOCK ON ERROR UNDO, RETURN ERROR RETURN-VALUE :
    FIND FIRST bf_fin-doc WHERE bf_fin-doc.host-code    = bf_fin-connect.host-code    AND
                                bf_fin-doc.fin-doc-code = bf_fin-connect.fin-doc-code NO-LOCK.
    FIND FIRST tt-fd WHERE tt-fd.host-code    = bf_fin-connect.host-code     AND
                           tt-fd.fin-doc-code = bf_fin-connect.fin-doc-code NO-ERROR.
    IF NOT AVAILABLE tt-fd THEN DO:
      CREATE tt-fd.
      BUFFER-COPY bf_fin-doc TO tt-fd.
    END.
    ASSIGN
      tt-fd.sum-base-fo = tt-fd.sum-base-fo + bf_fin-connect.sum-base
      tt-fd.sum-rubl-fo = tt-fd.sum-rubl-fo + bf_fin-connect.sum-rubl .
  END.
END.

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
  ENABLE b-exit b-help b-fin-doc b-fin-ob b-parts
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE open-parts-query Dialog-Frame
PROCEDURE open-parts-query :
IF AVAILABLE tt-fo THEN DO:
    OPEN QUERY b-parts
        FOR EACH bf_fin-gds-part WHERE bf_fin-gds-part.host-code = tt-fo.host-code AND
                                       bf_fin-gds-part.fin-ob-code = tt-fo.doc-code AND
                                        bf_fin-gds-part.out-code = pardoc-code NO-LOCK,
        first bf_goods where bf_goods.gds-code     = bf_fin-gds-part.gds-code no-lock,
        FIRST bf_c-parts WHERE bf_c-parts.obj-type = bf_fin-gds-part.obj-type AND
                               bf_c-parts.obj-code   = bf_fin-gds-part.obj-code AND
                               bf_c-parts.artic      = bf_goods.artic AND
                               bf_c-parts.prod-type  = bf_goods.prod-type AND
                               bf_c-parts.prod-code  = bf_goods.prod-code AND
                               bf_c-parts.in-code    = bf_fin-gds-part.in-code   AND
                               bf_c-parts.out-code   = bf_fin-gds-part.out-code  AND
                               bf_c-parts.chip-num   = parchip-num               and
                               bf_c-parts.part-code  = bf_fin-gds-part.part-code NO-LOCK.

    DISPLAY b-parts WITH FRAME {&FRAME-NAME}.
END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE open-query-fo Dialog-Frame
PROCEDURE open-query-fo :
IF AVAILABLE tt-fd THEN DO:
  OPEN QUERY b-fin-ob FOR EACH tt-fo,
      FIRST bf_fin-connect WHERE bf_fin-connect.host-code    = tt-fo.host-code AND
                                 bf_fin-connect.fin-ob-code = tt-fo.doc-code  AND
                                 bf_fin-connect.fin-doc-code = tt-fd.fin-doc-code NO-LOCK.
  DISPLAY b-fin-ob WITH FRAME {&FRAME-NAME}.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
