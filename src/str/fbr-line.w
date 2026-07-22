&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-fbr-line
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-fbr-line 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Работа со строкой составного товара в производстве

Автор: Хныкин Павел Андреевич
Дата создания: 02/17/09
Author: Pavel Khnykin
Creation date: 02/17/09

*/
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter p-fbrhist-handle     as widget-handle    no-undo.
define input parameter p-line-mode          as character        no-undo.
define input parameter p-fbr-doc-doc-code   as character        no-undo.
define input parameter p-fbr-line-recid     as recid            no-undo.
define input parameter p-mark-qnty          as decimal          no-undo.
define output parameter p-cancel            as logical          no-undo.
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Работа со строкой составного товара в производстве".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/showinf.i }
define buffer f-doc for fbr-doc.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-fbr-line

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS ub.fbr-line.price-sale 
&Scoped-define ENABLED-TABLES ub.fbr-line
&Scoped-define FIRST-ENABLED-TABLE ub.fbr-line
&Scoped-Define ENABLED-OBJECTS b-help b-exit RECT-2 RECT-1 b-quit 
&Scoped-Define DISPLAYED-FIELDS ub.fbr-line.artic ub.goods.gds-name ~
ub.fbr-line.prod-code ub.fbr-line.prod-type ub.clients.obj-name ~
ub.fbr-line.recipe-code ub.recipe.recipe-name ub.fbr-line.fact-qnty ~
ub.goods.unit-base ub.fbr-line.price-sale ub.fbr-line.price-base ~
ub.fbr-line.price-rubl 
&Scoped-define DISPLAYED-TABLES ub.fbr-line ub.goods ub.clients ub.recipe
&Scoped-define FIRST-DISPLAYED-TABLE ub.fbr-line
&Scoped-define SECOND-DISPLAYED-TABLE ub.goods
&Scoped-define THIRD-DISPLAYED-TABLE ub.clients
&Scoped-define FOURTH-DISPLAYED-TABLE ub.recipe
&Scoped-Define DISPLAYED-OBJECTS avail-qnty 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Ввод " 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE avail-qnty AS DECIMAL FORMAT "->>>,>>9.999":U INITIAL 0 
     LABEL "Допустимо" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1.08
     FGCOLOR 4  NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 75 BY 3.13.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 75 BY 2.04.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-fbr-line
     b-help AT ROW 1 COL 73.5
     b-exit AT ROW 1.13 COL 1.63
     b-quit AT ROW 1.13 COL 11.88
     ub.fbr-line.artic AT ROW 3.54 COL 16.25 COLON-ALIGNED
          LABEL "Артикул"
          VIEW-AS FILL-IN 
          SIZE 15 BY 1.08
     ub.goods.gds-name AT ROW 3.58 COL 31.13 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 42.5 BY 1.08
          FGCOLOR 4 
     ub.fbr-line.prod-code AT ROW 4.71 COL 16.25 COLON-ALIGNED
          LABEL "Производитель"
          VIEW-AS FILL-IN 
          SIZE 8.38 BY 1.08
     ub.fbr-line.prod-type AT ROW 4.71 COL 24.75 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 6.25 BY 1.08
     ub.clients.obj-name AT ROW 4.75 COL 31.13 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 42.63 BY 1.08
          FGCOLOR 4 
     ub.fbr-line.recipe-code AT ROW 6.96 COL 16.38 COLON-ALIGNED
          LABEL "Рецепт"
          VIEW-AS FILL-IN 
          SIZE 11 BY 1.08
     ub.recipe.recipe-name AT ROW 6.96 COL 27.25 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 46.63 BY 1.08
          FGCOLOR 4 
     ub.fbr-line.fact-qnty AT ROW 9.58 COL 16.63 COLON-ALIGNED
          LABEL "&Количество" FORMAT ">>,>>>,>>9.999"
          VIEW-AS FILL-IN 
          SIZE 11 BY 1.08
     ub.goods.unit-base AT ROW 9.58 COL 27.5 COLON-ALIGNED HELP
          "" NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 6 BY 1.08
          FGCOLOR 4 
     avail-qnty AT ROW 9.58 COL 45 COLON-ALIGNED
     ub.fbr-line.price-sale AT ROW 11.13 COL 45.25 COLON-ALIGNED HELP
          ""
          LABEL "&Цена продажи" FORMAT ">>>,>>>,>>9.99"
          VIEW-AS FILL-IN 
          SIZE 19.25 BY 1.08
     ub.fbr-line.price-base AT ROW 13.08 COL 45.25 COLON-ALIGNED HELP
          ""
          LABEL "Учет. цена (&баз.вал)" FORMAT ">>>,>>>,>>9.9999999999"
          VIEW-AS FILL-IN 
          SIZE 19.25 BY 1.08
     ub.fbr-line.price-rubl AT ROW 14.29 COL 45.25 COLON-ALIGNED HELP
          ""
          LABEL "Учет. цена " FORMAT ">>>,>>>,>>9.9999999999"
          VIEW-AS FILL-IN 
          SIZE 19.25 BY 1.08
     RECT-2 AT ROW 6.58 COL 2
     RECT-1 AT ROW 3.13 COL 2
     SPACE(0.74) SKIP(10.15)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE ""
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-fbr-line
   FRAME-NAME                                                           */
ASSIGN 
       FRAME d-fbr-line:SCROLLABLE       = FALSE
       FRAME d-fbr-line:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN ub.fbr-line.artic IN FRAME d-fbr-line
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN avail-qnty IN FRAME d-fbr-line
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN ub.fbr-line.fact-qnty IN FRAME d-fbr-line
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
/* SETTINGS FOR FILL-IN ub.goods.gds-name IN FRAME d-fbr-line
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN ub.clients.obj-name IN FRAME d-fbr-line
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN ub.fbr-line.price-base IN FRAME d-fbr-line
   NO-ENABLE EXP-LABEL EXP-FORMAT EXP-HELP                              */
/* SETTINGS FOR FILL-IN ub.fbr-line.price-rubl IN FRAME d-fbr-line
   NO-ENABLE EXP-LABEL EXP-FORMAT EXP-HELP                              */
/* SETTINGS FOR FILL-IN ub.fbr-line.price-sale IN FRAME d-fbr-line
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ub.fbr-line.prod-code IN FRAME d-fbr-line
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN ub.fbr-line.prod-type IN FRAME d-fbr-line
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN ub.fbr-line.recipe-code IN FRAME d-fbr-line
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN ub.recipe.recipe-name IN FRAME d-fbr-line
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN ub.goods.unit-base IN FRAME d-fbr-line
   NO-ENABLE EXP-LABEL EXP-HELP                                         */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-fbr-line
/* Query rebuild information for DIALOG-BOX d-fbr-line
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-fbr-line */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-fbr-line
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-fbr-line d-fbr-line
ON WINDOW-CLOSE OF FRAME d-fbr-line
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit d-fbr-line
ON CHOOSE OF b-exit IN FRAME d-fbr-line /* Ввод  */
DO:
def buffer b-fbr-line for fbr-line.                      /* для всех строк этого товара */
/*  exit-assign:*/
/*  do*/
/*  on error undo exit-assign, return no-apply*/
/*  :*/
    if input frame {&frame-name} fbr-line.fact-qnty <= 0
    then do:
        message
            "Количество товара введено неверно."
            skip(1) "Введите количество или отмените добавление товара."
        view-as alert-box information
        title "Неверное количество".
        undo, return no-apply.
    end.
    else do:
        assign
            fbr-line.fact-qnty
        .
        if input frame {&frame-name} fbr-line.price-sale <> fbr-line.price-sale
        and f-doc.status_ = {&g___new}
        then do:        /* проставляем новую цену во все строчки с этим товаром */
            for each b-fbr-line
               where b-fbr-line.doc-code  = f-doc.doc-code
                 and b-fbr-line.artic     = fbr-line.artic
                 and b-fbr-line.prod-type = fbr-line.prod-type
                 and b-fbr-line.prod-code = fbr-line.prod-code
            on error undo, return no-apply
            :
                    assign
                        b-fbr-line.price-sale = input frame {&frame-name} fbr-line.price-sale
                        b-fbr-line.is-calc = yes
                    .
            end.
        end.
    end.
    /* расчет по рецепту выполняется только при добавлении, потом только по кнопке
    */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit d-fbr-line
ON CHOOSE OF b-quit IN FRAME d-fbr-line /* Отмена */
DO:
    assign
        p-cancel = yes
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ub.fbr-line.fact-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ub.fbr-line.fact-qnty d-fbr-line
ON RETURN OF ub.fbr-line.fact-qnty IN FRAME d-fbr-line /* Количество */
DO:
  apply "choose" to b-exit in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ub.fbr-line.price-base
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ub.fbr-line.price-base d-fbr-line
ON RETURN OF ub.fbr-line.price-base IN FRAME d-fbr-line /* Учет. цена (баз.вал) */
DO:
  apply "entry" to fbr-line.price-rubl in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ub.fbr-line.price-rubl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ub.fbr-line.price-rubl d-fbr-line
ON RETURN OF ub.fbr-line.price-rubl IN FRAME d-fbr-line /* Учет. цена  */
DO:
  apply "entry" to b-exit in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ub.fbr-line.price-sale
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ub.fbr-line.price-sale d-fbr-line
ON RETURN OF ub.fbr-line.price-sale IN FRAME d-fbr-line /* Цена продажи */
DO:
  apply "entry" to b-exit in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-fbr-line 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

MAIN-BLOCK:
DO
ON ERROR UNDO MAIN-BLOCK, return error
:
     fbr-line.price-rubl:label = "Учет. цена ({&abbr_rub})" .
    VIEW FRAME {&frame-name}.
    find first f-doc no-lock
         where f-doc.doc-code = p-fbr-doc-doc-code
    .
    frame {&frame-name} :title = "Производство № " + f-doc.doc-code + "       "
                                    + f-doc.status_ + "      - " + p-line-mode .
    enable
        b-quit
        b-help
    with frame {&frame-name}.
    if p-line-mode = {&lookup}
    then do:
        find first fbr-line no-lock
            where recid( fbr-line ) = p-fbr-line-recid
        .
    end.
    else do:
        find first fbr-line exclusive-lock
            where recid( fbr-line ) = p-fbr-line-recid
        .
    end.
    if fbr-line.recipe-code <> ""
    then do:
        find first recipe no-lock
            where recipe.recipe-code = fbr-line.recipe-code
        .
    end.
    find first goods no-lock
         where goods.artic     = fbr-line.artic
           and goods.prod-type = fbr-line.prod-type
           and goods.prod-code = fbr-line.prod-code
    .
    find first clients no-lock
         where clients.obj-code = goods.prod-code
           and clients.obj-type = goods.prod-type
    .
    if available recipe
    then do:
        display
            recipe.recipe-code @ fbr-line.recipe-code
            recipe.recipe-name
        with frame {&frame-name}.
    end.
    display
        goods.artic     @ fbr-line.artic
        goods.prod-code @ fbr-line.prod-code
        goods.prod-type @ fbr-line.prod-type
        fbr-line.fact-qnty
        fbr-line.price-sale
        goods.gds-name
        clients.obj-name
        goods.unit-base
    with frame {&frame-name}.
    if f-doc.status_ = {&g___new}
    then do:
        hide
            fbr-line.price-base
            fbr-line.price-rubl
        in frame {&frame-name}.
    end.
    else do:
        display
            fbr-line.price-base
            fbr-line.price-rubl
        with frame {&frame-name}.
    end.
    if f-doc.status_ = {&fact}
    or not available recipe
    then do:
        hide avail-qnty in frame {&frame-name}.
    end.
    else do:
        run str/fbr-avl.p (
              input f-doc.doc-code
            , input recipe.recipe-code
            , input fbr-line.trn-type
            , output avail-qnty
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip "Ошибка при вычислении необходимого количества."
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
        display avail-qnty with frame {&frame-name}.
    end.
    if p-line-mode = {&lookup}
    then do:
        wait-for go of frame {&frame-name} focus b-quit.
    end.
    else do:
        enable
            b-exit
            fbr-line.fact-qnty
            fbr-line.price-sale
        with frame {&frame-name}.
        if p-mark-qnty <> ?
        then do :
          assign fbr-line.fact-qnty = p-mark-qnty .
          display fbr-line.fact-qnty with frame {&frame-name}.
          disable fbr-line.fact-qnty with frame {&frame-name}.
        end .
        wait-for go of frame {&frame-name} focus fbr-line.fact-qnty.
    end.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-fbr-line  _DEFAULT-DISABLE
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
  HIDE FRAME d-fbr-line.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-fbr-line  _DEFAULT-ENABLE
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
  DISPLAY avail-qnty 
      WITH FRAME d-fbr-line.
  IF AVAILABLE ub.clients THEN 
    DISPLAY ub.clients.obj-name 
      WITH FRAME d-fbr-line.
  IF AVAILABLE ub.fbr-line THEN 
    DISPLAY ub.fbr-line.artic ub.fbr-line.prod-code ub.fbr-line.prod-type 
          ub.fbr-line.recipe-code ub.fbr-line.fact-qnty ub.fbr-line.price-sale 
          ub.fbr-line.price-base ub.fbr-line.price-rubl 
      WITH FRAME d-fbr-line.
  IF AVAILABLE ub.goods THEN 
    DISPLAY ub.goods.gds-name ub.goods.unit-base 
      WITH FRAME d-fbr-line.
  IF AVAILABLE ub.recipe THEN 
    DISPLAY ub.recipe.recipe-name 
      WITH FRAME d-fbr-line.
  ENABLE b-help b-exit RECT-2 RECT-1 b-quit ub.fbr-line.price-sale 
      WITH FRAME d-fbr-line.
  VIEW FRAME d-fbr-line.
  {&OPEN-BROWSERS-IN-QUERY-d-fbr-line}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

