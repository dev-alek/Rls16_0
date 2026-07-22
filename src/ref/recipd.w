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

Дополнительные данные рецепта

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter p-mode                   as character        no-undo.
define input parameter p-recipe-code            as character        no-undo.
define input parameter p-store-type             as character        no-undo.
define input parameter p-store-code             as integer          no-undo.
define input parameter p-in-recipe-quality      as character        no-undo.
define input parameter p-in-recipe-design       as character        no-undo.
define output parameter p-out-recipe-quality    as character        no-undo.
define output parameter p-out-recipe-design     as character        no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Дополнительные данные рецепта".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ ref/gdsoattr.i }
{ cmp/showinf.i  }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-ingr-cost

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES recipe-gds

/* Definitions for BROWSE br-ingr-cost                                  */
&Scoped-define FIELDS-IN-QUERY-br-ingr-cost recipe-gds.artic ~
func-get-cost-price-rubl( gds-code )
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-ingr-cost
&Scoped-define QUERY-STRING-br-ingr-cost FOR EACH recipe-gds ~
      WHERE recipe-gds.recipe-code = p-recipe-code NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-ingr-cost OPEN QUERY br-ingr-cost FOR EACH recipe-gds ~
      WHERE recipe-gds.recipe-code = p-recipe-code NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-ingr-cost recipe-gds
&Scoped-define FIRST-TABLE-IN-QUERY-br-ingr-cost recipe-gds


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-ingr-cost}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-help ed-recipe-quality ~
ed-recipe-design b-change br-ingr-cost
&Scoped-Define DISPLAYED-OBJECTS fi-d ed-recipe-quality fi-d-2 ~
ed-recipe-design FILL-IN-1

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-get-cost-price-rubl Dialog-Frame
FUNCTION func-get-cost-price-rubl RETURNS CHARACTER
  ( p-gds-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-get-goods-artic Dialog-Frame
FUNCTION func-get-goods-artic RETURNS CHARACTER
  ( p-gds-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-change
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-exit
     LABEL "В&ыход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помощ&ь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE ed-recipe-design AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 60.25 BY 2.04 NO-UNDO.

DEFINE VARIABLE ed-recipe-quality AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 60.25 BY 2.04 NO-UNDO.

DEFINE VARIABLE fi-d AS CHARACTER FORMAT "X(256)":U INITIAL "Показатели качества готовой продукции"
     VIEW-AS FILL-IN
     SIZE 49 BY 1 NO-UNDO.

DEFINE VARIABLE fi-d-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Способ оформления блюда"
     VIEW-AS FILL-IN
     SIZE 49 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Учетные цены ингредиентов для оценочной калькуляции"
     VIEW-AS FILL-IN
     SIZE 60.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-ingr-cost FOR
      recipe-gds SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-ingr-cost
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-ingr-cost Dialog-Frame _STRUCTURED
  QUERY br-ingr-cost NO-LOCK DISPLAY
      recipe-gds.artic FORMAT "X(16)":U
      func-get-cost-price-rubl( gds-code ) COLUMN-LABEL "Цена" FORMAT "X(17)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 60.5 BY 11.5 EXPANDABLE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.17 COL 2
     b-help AT ROW 1.17 COL 52.5
     fi-d AT ROW 2.63 COL 2.25 NO-LABEL
     ed-recipe-quality AT ROW 3.71 COL 2.25 NO-LABEL
     fi-d-2 AT ROW 5.92 COL 2.38 NO-LABEL
     ed-recipe-design AT ROW 7.04 COL 2.25 NO-LABEL
     FILL-IN-1 AT ROW 9.25 COL 2 NO-LABEL
     b-change AT ROW 10.5 COL 2
     br-ingr-cost AT ROW 11.75 COL 2
     SPACE(0.49) SKIP(0.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Дополнительные данные рецепта".


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
/* BROWSE-TAB br-ingr-cost b-change Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN fi-d IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fi-d-2 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN FILL-IN-1 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
ASSIGN
       FILL-IN-1:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-ingr-cost
/* Query rebuild information for BROWSE br-ingr-cost
     _TblList          = "ub.recipe-gds"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "recipe-gds.recipe-code = p-recipe-code"
     _FldNameList[1]   = ub.recipe-gds.artic
     _FldNameList[2]   > "_<CALC>"
"func-get-cost-price-rubl( gds-code )" "Цена" "X(17)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _Query            is OPENED
*/  /* BROWSE br-ingr-cost */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Дополнительные данные рецепта */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-change
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-change Dialog-Frame
ON CHOOSE OF b-change IN FRAME Dialog-Frame /* Изменить */
DO:
    define variable v-attr-value        as character    no-undo.
    define variable v-new-attr-value    as character    no-undo.
    define variable v-new-cost-price    as decimal      no-undo.

    if available recipe-gds
    then do:
        assign
            v-attr-value        = func-get-cost-price-rubl( recipe-gds.gds-code )
            v-new-attr-value    = v-attr-value
        .

        define variable v-attr-type           as character no-undo .
        define variable v-attr-format         as character no-undo .
        define variable v-attr-label          as character no-undo .
        define variable v-attr-user-can-edit  as logical   no-undo .
        define variable v-attr-output-display as logical   no-undo .
        define variable v-attr-other          as character no-undo .

        run gdsoattr-name in this-procedure
          (input  {&attr-fbr-cost-rubl}
          ,output v-attr-type
          ,output v-attr-format
          ,output v-attr-label
          ,output v-attr-user-can-edit
          ,output v-attr-output-display
          ,output v-attr-other
          ) .

        run gbl/d-prompt.w (
            input 'title=':u + "Изменение атрибута товара на объекте" + '\':u
                + 'text1=':u + v-attr-label + '\':u
                + 'format=' + v-attr-format + '\':u
                + 'type=' + v-attr-type + '\':u
                + 'fillin_row=2\':u
                + 'fillin_col=4\':u
                + 'fillin_width=20\':u
                + 'fillin_height=1\':u
                + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
                + 'readonly=' + 'no':u + '\':u
            , input-output v-new-attr-value
        ).
        if return-value = 'false':u
        then do:

        end.
        else do:
            if v-new-attr-value <> v-attr-value
            then do:
                assign
                    v-new-cost-price = decimal( v-new-attr-value )
                no-error.
                if error-status :error
                then do:
                    assign
                        v-new-cost-price = 0.0
                        v-new-attr-value = v-attr-value
                    .
                end.
                else do:
                    run gdsoattr-write in this-procedure (
                          input recipe-gds.gds-code
                        , input p-store-type
                        , input p-store-code
                        , input {&attr-fbr-cost-rubl}
                        , input v-new-attr-value
                    ).
                    {&OPEN-BROWSERS-IN-QUERY-{&FRAME-NAME}}
                end.
            end.
        end.
    end.        /* if available recipe-gds */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
DO:
    assign
        p-out-recipe-quality = ed-recipe-quality :screen-value
        p-out-recipe-design  = ed-recipe-design  :screen-value
    .
    apply "GO" TO FRAME {&FRAME-NAME} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-ingr-cost
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
  run init-fields in this-procedure.
  RUN enable_UI.
  case p-mode
  :
    when {&lookup}
    then do:
        assign
            ed-recipe-quality :fgcolor = 4
            ed-recipe-design  :fgcolor = 4
        .
        assign
            ed-recipe-quality :read-only in frame {&frame-name} = yes
            ed-recipe-design  :read-only in frame {&frame-name} = yes
        .
    end.        /* when {&lookup} */
  end case.     /* case p-mode */
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
  DISPLAY fi-d ed-recipe-quality fi-d-2 ed-recipe-design FILL-IN-1
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-help ed-recipe-quality ed-recipe-design b-change br-ingr-cost
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-goods-artic Dialog-Frame
PROCEDURE get-goods-artic :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-gds-code   as integer    no-undo.
define output parameter p-artic     as character  no-undo.

define buffer buf_goods for goods.

do
for buf_goods
on error undo, return error
:
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    assign
        p-artic = buf_goods.artic
    .
end.
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
    assign
        ed-recipe-quality   = p-in-recipe-quality
        ed-recipe-design    = p-in-recipe-design
    .
end.
END PROCEDURE. /* init-fields */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-get-cost-price-rubl Dialog-Frame
FUNCTION func-get-cost-price-rubl RETURNS CHARACTER
  ( p-gds-code as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define variable v-attr-value as character no-undo.
define variable v-attr-type  as character no-undo.

    run gdsoattr-value in this-procedure (
          input {&attr-fbr-cost-rubl}
        , input p-gds-code
        , input p-store-type
        , input p-store-code
        , output v-attr-value
        , output v-attr-type
    ).

  RETURN v-attr-value.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-get-goods-artic Dialog-Frame
FUNCTION func-get-goods-artic RETURNS CHARACTER
  ( p-gds-code as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define variable v-artic as character no-undo.

    run get-goods-artic in this-procedure (
          input p-gds-code
        , output v-artic
    ).
    return v-artic.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME