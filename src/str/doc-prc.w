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

Просмотр сумм по документу, разделенных по поставщикам (партии)

Автор: Чернова Светлана Александровна
Дата создания: 09/20/05
Author: Svetlana Chernova
Creation date: 09/20/05

Author: Андрей Исаков
Creation date: 09/10/04 11:14


*/
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Просмотр сумм по документу, разделенных по поставщикам (партии)" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ trg/prdoclib.i }
{ str/prl-vat.i  }
{ str/d-supp.i   NEW }
{ str/clcprtsl.i }

define variable v-ov-qnty     like ub.parts.fact-qnty no-undo .
define variable v-ov-base     like ub.doc-line.price-base no-undo.
define variable v-ov-VAT-base like ub.doc-line.price-base no-undo.
define variable v-ov-SLT-base like ub.doc-line.price-base no-undo.

def shared buffer p-doc for price-doc.

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
&Scoped-define INTERNAL-TABLES tt-title

/* Definitions for BROWSE BROWSE-3                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-3 tt-title.purch-name tt-title.fact-qnty tt-title.ov-base tt-title.no-VAT-base tt-title.VAT-base tt-title.SLT-base
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-3
&Scoped-define SELF-NAME BROWSE-3
&Scoped-define QUERY-STRING-BROWSE-3 FOR EACH tt-title
&Scoped-define OPEN-QUERY-BROWSE-3 OPEN QUERY {&SELF-NAME} FOR EACH tt-title.
&Scoped-define TABLES-IN-QUERY-BROWSE-3 tt-title
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-3 tt-title


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-3}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b_exit B-Help BROWSE-3 ov ov-no-SLT-VAT SLT ~
VAT
&Scoped-Define DISPLAYED-OBJECTS ov ov-no-SLT-VAT SLT VAT

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b_exit AUTO-END-KEY
     LABEL "Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE ov AS DECIMAL FORMAT "->>,>>>,>>9.99":U INITIAL 0
     LABEL "Переоценка"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE ov-no-SLT-VAT AS DECIMAL FORMAT "->>,>>>,>>9.99":U INITIAL 0
     LABEL "Без НДС и НсП"
      VIEW-AS TEXT
     SIZE 14 BY .67 TOOLTIP "Переоцека без НДС и налога с продаж"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE SLT AS DECIMAL FORMAT "->>,>>>,>>9.99":U INITIAL 0
     LABEL "НсП"
      VIEW-AS TEXT
     SIZE 14 BY .67 TOOLTIP "Налог с продаж"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE VAT AS DECIMAL FORMAT "->>,>>>,>>9.99":U INITIAL 0
     LABEL "НДС"
      VIEW-AS TEXT
     SIZE 14 BY .67 TOOLTIP "НДС"
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-3 FOR
      tt-title SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-3 Dialog-Frame _FREEFORM
  QUERY BROWSE-3 DISPLAY
      tt-title.purch-name format "x(11)" column-label "Тип приобретения"
tt-title.fact-qnty column-label "Кол-во"
tt-title.ov-base   column-label "Сумма(б.в.)"
tt-title.no-VAT-base column-label "Без НДС и НсП(б.в.)"
tt-title.VAT-base  column-label "НДС(б.в.)"
tt-title.SLT-base  column-label "НсП(б.в.)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 78.75 BY 8.38.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b_exit AT ROW 1 COL 1
     B-Help AT ROW 1 COL 11
     BROWSE-3 AT ROW 5.38 COL 1.63
     ov AT ROW 1.46 COL 37.38 COLON-ALIGNED
     ov-no-SLT-VAT AT ROW 2.38 COL 37.38 COLON-ALIGNED
     SLT AT ROW 3.29 COL 37.38 COLON-ALIGNED
     VAT AT ROW 4.13 COL 37.38 COLON-ALIGNED
     SPACE(27.99) SKIP(9.15)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>"
         CANCEL-BUTTON b_exit.


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
                                                                        */
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
OPEN QUERY {&SELF-NAME} FOR EACH tt-title.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-3 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* <insert dialog title> */
DO:
  APPLY "END-ERROR":U TO SELF.
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
     run prdoclib-calc-prc-loc in this-procedure
    (recid(p-doc)          /* p-price-doc-recid */
    ,output v-ov-qnty
    ,output v-ov-base
    ,output v-ov-VAT-base
    ,output v-ov-SLT-base
    ) no-error.
  if error-status :error then do:
    if error-status :get-message(1) <> "" then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове программы prdoclib-calc-prc" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    undo, return error .
  end.
  assign
  ov = v-ov-base
  SLT = v-ov-SLT-base
  VAT = v-ov-VAT-base
  ov-no-SLT-VAT = ov - slt - vat
  .






    frame {&frame-name}:title = p-doc.doc-num  + "  : ПЕРЕОЦЕНКА".
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
  DISPLAY ov ov-no-SLT-VAT SLT VAT
      WITH FRAME Dialog-Frame.
  ENABLE b_exit B-Help BROWSE-3 ov ov-no-SLT-VAT SLT VAT
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE prdoclib-calc-prc-loc Dialog-Frame
PROCEDURE prdoclib-calc-prc-loc :
define input  parameter p-price-doc-recid as   recid                  no-undo.
  define output parameter  tv-ov-qnty     as decimal   no-undo .
  define output parameter  tv-ov-base     as decimal   no-undo .
  define output parameter  tv-ov-VAT-base as decimal   no-undo .
  define output parameter  tv-ov-SLT-base as decimal   no-undo .

 define variable  v-ov-qnty     as decimal   no-undo .
 define variable  v-ov-base     as decimal   no-undo .
 define variable  v-ov-VAT-base as decimal   no-undo .
 define variable  v-ov-SLT-base as decimal   no-undo .


  do
  on error undo, return error
  :
    define buffer buf_price-doc       for ub.price-doc .
    define buffer buf_price-list      for ub.price-list .
    define buffer buf_parts           for ub.parts .

    for each tt-title:
      delete tt-title.
    end.
    assign
        tv-ov-qnty       = 0
        tv-ov-base       = 0
        tv-ov-VAT-base   = 0
        tv-ov-SLT-base   = 0
    .

    find first buf_price-doc no-lock
      where recid(buf_price-doc) = p-price-doc-recid
      no-error .
    if not available buf_price-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        skip
        "Ошибка задания входных параметров" skip
        "Не найден документ переоценки" skip
        "Код записи (recid)" p-price-doc-recid skip
        view-as alert-box error .
      undo, return error .
    end.

/* общее колво по переоценке */
    for each buf_price-list no-lock
      where buf_price-list.doc-num    = buf_price-doc.doc-num
        and buf_price-list.main-price = true
    on error undo, return error
    :

      run prdoclib-calc-ov
        (input recid(buf_price-list)
        ,output v-ov-qnty
        ,output v-ov-base
        ,output v-ov-VAT-base
        ,output v-ov-SLT-base
        ) no-error .
      if error-status :error then do:
        if error-status :get-message(1) <> "" then do:
          message
            vss-workfile vss-revision vss-description skip
           skip
            "Ошибка при вызове процедуры prdoclib-calc-ov" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        end.
        undo, return error .
      end.

      assign
          tv-ov-qnty       = tv-ov-qnty     +   v-ov-qnty
          tv-ov-base       = tv-ov-base     +   v-ov-base
          tv-ov-VAT-base   = tv-ov-VAT-base +   v-ov-VAT-base
          tv-ov-SLT-base   = tv-ov-SLT-base +   v-ov-SLT-base
      .
      end.

    for each buf_price-list no-lock
      where buf_price-list.doc-num    = buf_price-doc.doc-num
        and buf_price-list.main-price = true
    on error undo, return error
    :

      for each buf_parts no-lock
        where buf_parts.out-code  = buf_price-list.doc-num
          and buf_parts.obj-type  = buf_price-list.obj-type
          and buf_parts.obj-code  = buf_price-list.obj-code
          and buf_parts.artic     = buf_price-list.artic
          and buf_parts.prod-type = buf_price-list.prod-type
          and buf_parts.prod-code = buf_price-list.prod-code
      on error undo, return error
      :
      find first tt-title where tt-title.purch-code = buf_parts.purch-code no-error .
      if not available tt-title  then do:
                create tt-title.
                assign
                tt-title.fact-qnty  = buf_parts.fact-qnty
                tt-title.purch-code = buf_parts.purch-code .
         end.
         else do:
                assign
                tt-title.fact-qnty  = tt-title.fact-qnty + buf_parts.fact-qnty
                tt-title.purch-code = buf_parts.purch-code .
         end.
          &scop purchase-code string(tt-title.purch-code)
          assign
                tt-title.purch-name = {&purchase-codes-name}
                .
            end.
  end.

  for each tt-title :
      assign
        tt-title.VAT-base    = tv-ov-VAT-base * (tt-title.fact-qnty / tv-ov-qnty )
        tt-title.SLT-base    = tv-ov-SLT-base * (tt-title.fact-qnty / tv-ov-qnty )
        tt-title.ov-base     = tv-ov-base     * (tt-title.fact-qnty / tv-ov-qnty )
        tt-title.no-VAT-base = tt-title.ov-base - tt-title.VAT-base - tt-title.SLT-base
      .
  end.

  end.
end procedure. /* prdoclib-calc-prc-loc */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
