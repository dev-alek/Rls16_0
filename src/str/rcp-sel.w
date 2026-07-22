&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
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

Выбор рецепта для производства товара.

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:
    p-input-gds-code - код товара
    p-input-trn-type - тип строки, допустимо:
                        {&income}       - нужен рецепт, по которому товар можно получить
                        {&write-off}    - нужен рецепт, по которому товар можно списать

Output:
    p-recipe-code       - код выбранного рецепта
    p-is-integration    - если рецепт - комплектация: yes - комплектация, no - разукомплектация.
    p-cancel            - если yes, то выбор отменен
*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc        as handle           no-undo.
define input parameter p-input-gds-code     as integer          no-undo.
define input parameter p-input-trn-type     as character        no-undo.
define output parameter p-recipe-code       as character        no-undo.
define output parameter p-is-integration    as logical          no-undo.
define output parameter p-cancel            as logical          no-undo.
/*define variable p-input-gds-code    as integer       no-undo.*/
/*define variable p-input-trn-type    as character     no-undo.*/
/*define variable p-is-integration    as logical      no-undo. */
/*define variable p-cancel            as logical       no-undo.*/

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор рецепта для производства товара.".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }

define temp-table temp_recipe no-undo like recipe
/*    field gds-code as integer*/
.

define variable v-exit-enabled    as logical      no-undo.

/*assign*/
/*    p-input-gds-code = 1512919*/
/*    p-input-trn-type = {&income}*/
/*.*/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp_recipe

/* Definitions for BROWSE BROWSE-1                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1 temp_recipe.recipe-code temp_recipe.recipe-name temp_recipe.recipe-type
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1
&Scoped-define FIELD-PAIRS-IN-QUERY-BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&Scoped-define OPEN-QUERY-BROWSE-1 OPEN QUERY {&SELF-NAME} FOR EACH temp_recipe.
&Scoped-define TABLES-IN-QUERY-BROWSE-1 temp_recipe
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1 temp_recipe


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-sel b-view b-help BROWSE-1

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помощ&ь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sel
     LABEL "&Выбор"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-view
     LABEL "&Просмотр"
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-1 FOR
      temp_recipe SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1 Dialog-Frame _FREEFORM
  QUERY BROWSE-1 SHARE-LOCK NO-WAIT DISPLAY
      temp_recipe.recipe-code format "X(10)" label "Номер"
      temp_recipe.recipe-name format "X(40)" label "Наименование рецепта"
      temp_recipe.recipe-type format "X(15)" label "Тип рецепта"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 70 BY 17.71.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.17 COL 2
     b-sel AT ROW 1.17 COL 12
     b-view AT ROW 1.17 COL 22
     b-help AT ROW 1.17 COL 62.13
     BROWSE-1 AT ROW 2.38 COL 2.13
     SPACE(0.99) SKIP(0.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выбор рецепта для товара"
         DEFAULT-BUTTON b-sel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BROWSE-1 b-help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1
/* Query rebuild information for BROWSE BROWSE-1
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp_recipe.
     _END_FREEFORM
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* BROWSE BROWSE-1 */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Выбор рецепта для товара */
DO:
    if v-exit-enabled = yes
    then do:
        APPLY "END-ERROR":U TO SELF.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
DO:
    assign
        p-cancel = yes
        v-exit-enabled = yes
    .
    apply "WINDOW-CLOSE" TO FRAME {&FRAME-NAME} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    assign
        v-exit-enabled  = yes
        p-recipe-code   = temp_recipe.recipe-code
    .
    apply "WINDOW-CLOSE" TO FRAME {&FRAME-NAME} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-view
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-view Dialog-Frame
ON CHOOSE OF b-view IN FRAME Dialog-Frame /* Просмотр */
DO:
    run view-recipe in this-procedure (
        input temp_recipe.recipe-code
    ).
    apply "entry" to browse-1.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1
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
    run init-fields in this-procedure .
    RUN enable_UI.
    apply "entry" to browse-1.
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame _DEFAULT-DISABLE
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame _DEFAULT-ENABLE
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
  ENABLE b-exit b-sel b-view b-help BROWSE-1
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-fields Dialog-Frame
PROCEDURE init-fields :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    define buffer buf_recipe        for recipe.
    define buffer buf_recipe-gds    for recipe-gds.
    define buffer buf_goods         for goods.
    define buffer buf_comp_goods    for goods.

    { gbl/getcntxt.i get }
    find first buf_goods no-lock
         where buf_goods.gds-code = p-input-gds-code
    .
    assign
        frame {&frame-name} :title =
            "Выбор рецепта для товара. Код: " + string( buf_goods.gds-code )
            + " Арт: " + string( buf_goods.artic )
            + " Имя: " + string( buf_goods.gds-name )
    .
    for each buf_recipe no-lock
       where buf_recipe.artic       = buf_goods.artic
         and buf_recipe.prod-type   = buf_goods.prod-type
         and buf_recipe.prod-code   = buf_goods.prod-code
    :
        case p-input-trn-type
        :
            when {&income}
            then do:
                if buf_recipe.recipe-type = {&manufacturing}
                or buf_recipe.recipe-type = {&gathering}
                or buf_recipe.recipe-type = {&alternative}
                or buf_recipe.recipe-type = {&petrolium-manufacturing}
                then do:
                    assign
                        p-is-integration = yes
                    .
                    find first temp_recipe
                         where temp_recipe.artic     = buf_recipe.artic
                           and temp_recipe.prod-type = buf_recipe.prod-type
                           and temp_recipe.prod-code = buf_recipe.prod-code
                    no-error.
                    if not available temp_recipe
                    then do:
                        create temp_recipe.
                        assign
                            temp_recipe.recipe-code = buf_recipe.recipe-code
                            temp_recipe.recipe-name = buf_recipe.recipe-name
                            temp_recipe.recipe-type = buf_recipe.recipe-type
                            temp_recipe.artic       = buf_recipe.artic
                            temp_recipe.prod-type   = buf_recipe.prod-type
                            temp_recipe.prod-code   = buf_recipe.prod-code
                            temp_recipe.gds-code    = buf_goods.gds-code
                        .
                    end.
                end.
            end.        /* when {&income} */
            when {&write-off}
            then do:
                if buf_recipe.recipe-type = {&dressing}
                or buf_recipe.recipe-type = {&gathering}
                then do:
                    assign
                        p-is-integration = no
                    .
                    find first temp_recipe
                         where temp_recipe.artic     = buf_recipe.artic
                           and temp_recipe.prod-type = buf_recipe.prod-type
                           and temp_recipe.prod-code = buf_recipe.prod-code
                    no-error.
                    if not available temp_recipe
                    then do:
                        create temp_recipe.
                        assign
                            temp_recipe.recipe-code = buf_recipe.recipe-code
                            temp_recipe.recipe-name = buf_recipe.recipe-name
                            temp_recipe.recipe-type = buf_recipe.recipe-type
                            temp_recipe.artic       = buf_recipe.artic
                            temp_recipe.prod-type   = buf_recipe.prod-type
                            temp_recipe.prod-code   = buf_recipe.prod-code
                            temp_recipe.gds-code    = buf_goods.gds-code
                        .
                    end.
                end.
            end.        /* when {&write-off} */
        end case.       /* case p-input-trn-type */
    end.        /* for each buf_recipe no-lock */
    for each buf_recipe-gds no-lock
       where buf_recipe-gds.artic       = buf_goods.artic
         and buf_recipe-gds.prod-type   = buf_goods.prod-type
         and buf_recipe-gds.prod-code   = buf_goods.prod-code
    :
        find first buf_recipe no-lock
             where buf_recipe.recipe-code = buf_recipe-gds.recipe-code
        .
        case p-input-trn-type
        :
            when {&income}
            then do:
                if buf_recipe.recipe-type = {&dressing}
                or buf_recipe.recipe-type = {&gathering}
                then do:
                    assign
                        p-is-integration = no
                    .
                    find first temp_recipe
                         where temp_recipe.artic     = buf_recipe.artic
                           and temp_recipe.prod-type = buf_recipe.prod-type
                           and temp_recipe.prod-code = buf_recipe.prod-code
                    no-error.
                    if not available temp_recipe
                    then do:
                        find first buf_comp_goods no-lock
                             where buf_comp_goods.artic     = buf_recipe.artic
                               and buf_comp_goods.prod-type = buf_recipe.prod-type
                               and buf_comp_goods.prod-code = buf_recipe.prod-code
                        .
                        create temp_recipe.
                        assign
                            temp_recipe.recipe-code = buf_recipe.recipe-code
                            temp_recipe.recipe-name = buf_recipe.recipe-name
                            temp_recipe.recipe-type = buf_recipe.recipe-type
                            temp_recipe.artic       = buf_recipe.artic
                            temp_recipe.prod-type   = buf_recipe.prod-type
                            temp_recipe.prod-code   = buf_recipe.prod-code
                            temp_recipe.gds-code    = buf_comp_goods.gds-code
                        .
                    end.
                end.
            end.        /* when {&income} */
            when {&write-off}
            then do:
                if buf_recipe.recipe-type = {&manufacturing}
                or buf_recipe.recipe-type = {&gathering}
                or buf_recipe.recipe-type = {&alternative}
                or buf_recipe.recipe-type = {&petrolium-manufacturing}
                then do:
                    assign
                        p-is-integration = yes
                    .
                    find first temp_recipe
                         where temp_recipe.artic     = buf_recipe.artic
                           and temp_recipe.prod-type = buf_recipe.prod-type
                           and temp_recipe.prod-code = buf_recipe.prod-code
                    no-error.
                    if not available temp_recipe
                    then do:
                        find first buf_comp_goods no-lock
                             where buf_comp_goods.artic     = buf_recipe.artic
                               and buf_comp_goods.prod-type = buf_recipe.prod-type
                               and buf_comp_goods.prod-code = buf_recipe.prod-code
                        .
                        create temp_recipe.
                        assign
                            temp_recipe.recipe-code = buf_recipe.recipe-code
                            temp_recipe.recipe-name = buf_recipe.recipe-name
                            temp_recipe.recipe-type = buf_recipe.recipe-type
                            temp_recipe.artic       = buf_recipe.artic
                            temp_recipe.prod-type   = buf_recipe.prod-type
                            temp_recipe.prod-code   = buf_recipe.prod-code
                            temp_recipe.gds-code    = buf_comp_goods.gds-code
                        .
                    end.
                end.
            end.        /* when {&write-off} */
        end case.       /* case p-input-trn-type */
    end.        /* for each buf_recipe-gds no-lock */
end.
END PROCEDURE. /* init-fields */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE view-recipe Dialog-Frame
PROCEDURE view-recipe :
/*------------------------------------------------------------------------------
  Purpose:     Просмотр рецепта
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-recipe-code   as character     no-undo.

    define variable v-recipe-recid      as recid     no-undo.
    define variable v-new-recipe-code   as character    no-undo.

    define buffer buf_goods     for goods.
    define buffer buf_recipe    for recipe.

    find first buf_recipe no-lock
         where buf_recipe.recipe-code = p-recipe-code
    no-error.
    if available buf_recipe
    then do:
        find first buf_goods no-lock
             where buf_goods.artic      = buf_recipe.artic
               and buf_goods.prod-type  = buf_recipe.prod-type
               and buf_goods.prod-code  = buf_recipe.prod-code
        .
        assign
            v-recipe-recid = recid( buf_recipe )
        .
        run ref/recipe.w (
              input parparentproc
            , input {&lookup}
            , input recid( buf_goods )
            , input "":U
            , input buf_recipe.recipe-code
            , input v-cntxt-host-code-obj
            , input v-cntxt-obj-type
            , input v-cntxt-obj-code
            , input no
            , input no
            , output v-new-recipe-code
        ).
    end.
end.
END PROCEDURE. /* view-recipe */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME