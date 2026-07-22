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

Акты проработки для рецептов производства

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc    as widget-handle no-undo .
define input parameter p-recipe-code    as character        no-undo.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Акты проработки для рецептов производства".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/showinf.i }
{ cmp/library.i  }
{ cmp/gds-list.i scn-list def "new shared" }
{ gbl/getcntxt.i def }
define new shared variable lns-cnt    as integer      no-undo.
define new shared variable line-rec   as recid        no-undo.

define temp-table temp_recipe-develop   no-undo
    field doc-code as character
    field doc-date as date

    index pi is primary unique doc-code
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp_recipe-develop recipe-develop

/* Definitions for BROWSE BROWSE-1                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1 temp_recipe-develop.doc-code temp_recipe-develop.doc-date
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&Scoped-define QUERY-STRING-BROWSE-1 FOR EACH temp_recipe-develop NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-1 OPEN QUERY {&SELF-NAME} FOR EACH temp_recipe-develop NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-1 temp_recipe-develop
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1 temp_recipe-develop


/* Definitions for BROWSE BROWSE-2                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 ~
get-column-value( input 1, input recipe-develop.gds-code ) ~
get-column-value( input 2, input recipe-develop.gds-code ) ~
recipe-develop.qnty recipe-develop.brutto-qnty
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2
&Scoped-define QUERY-STRING-BROWSE-2 FOR EACH recipe-develop ~
      WHERE recipe-develop.recipe-code = p-recipe-code ~
 AND recipe-develop.doc-code = temp_recipe-develop.doc-code NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-2 OPEN QUERY BROWSE-2 FOR EACH recipe-develop ~
      WHERE recipe-develop.recipe-code = p-recipe-code ~
 AND recipe-develop.doc-code = temp_recipe-develop.doc-code NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-2 recipe-develop
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2 recipe-develop


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-1}~
    ~{&OPEN-QUERY-BROWSE-2}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-add b-chg b-del b-help BROWSE-1 ~
b-chg-line b-gds BROWSE-2

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-column-value Dialog-Frame
FUNCTION get-column-value RETURNS CHARACTER
  ( input p-column-num as integer, input p-gds-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-chg
     LABEL "Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-chg-line
     LABEL "Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "В&ыход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-gds
     LABEL "&Товары"
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "Помощ&ь"
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-1 FOR
      temp_recipe-develop SCROLLING.

DEFINE QUERY BROWSE-2 FOR
      recipe-develop SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1 Dialog-Frame _FREEFORM
  QUERY BROWSE-1 NO-LOCK DISPLAY
      temp_recipe-develop.doc-code format "X(25)" column-label "Номер"
      temp_recipe-develop.doc-date format "99.99.9999" column-label "Дата"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 84.5 BY 7.25 ROW-HEIGHT-CHARS .58 EXPANDABLE.

DEFINE BROWSE BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2 Dialog-Frame _STRUCTURED
  QUERY BROWSE-2 NO-LOCK DISPLAY
      get-column-value( input 1, input recipe-develop.gds-code ) COLUMN-LABEL "Артикул" FORMAT "X(17)":U
            WIDTH 18
      get-column-value( input 2, input recipe-develop.gds-code ) COLUMN-LABEL "Наименование товара" FORMAT "X(30)":U
      recipe-develop.qnty COLUMN-LABEL "Нетто" FORMAT "->>,>>>,>>9.<<<":U
            WIDTH 16
      recipe-develop.brutto-qnty FORMAT "->>,>>>,>>9.<<<":U WIDTH 16
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 84.5 BY 10.25 EXPANDABLE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.25 COL 2
     b-add AT ROW 1.25 COL 26.5
     b-chg AT ROW 1.25 COL 36.5
     b-del AT ROW 1.25 COL 46.5
     b-help AT ROW 1.25 COL 76
     BROWSE-1 AT ROW 2.5 COL 2
     b-chg-line AT ROW 10 COL 26.5
     b-gds AT ROW 10 COL 36.5
     BROWSE-2 AT ROW 11.25 COL 2
     SPACE(1.24) SKIP(0.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Акты проработки"
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
/* BROWSE-TAB BROWSE-1 b-help Dialog-Frame */
/* BROWSE-TAB BROWSE-2 b-gds Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1
/* Query rebuild information for BROWSE BROWSE-1
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp_recipe-develop NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BROWSE-1 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-2
/* Query rebuild information for BROWSE BROWSE-2
     _TblList          = "ub.recipe-develop"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "recipe-develop.recipe-code = p-recipe-code
 AND recipe-develop.doc-code = temp_recipe-develop.doc-code"
     _FldNameList[1]   > "_<CALC>"
"get-column-value( input 1, input recipe-develop.gds-code )" "Артикул" "X(17)" ? ? ? ? ? ? ? no ? no no "18" yes no no "U" "" ""
     _FldNameList[2]   > "_<CALC>"
"get-column-value( input 2, input recipe-develop.gds-code )" "Наименование товара" "X(30)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[3]   > ub.recipe-develop.qnty
"recipe-develop.qnty" "Нетто" ? "decimal" ? ? ? ? ? ? no ? no no "16" yes no no "U" "" ""
     _FldNameList[4]   > ub.recipe-develop.brutto-qnty
"recipe-develop.brutto-qnty" ? ? "decimal" ? ? ? ? ? ? no ? no no "16" yes no no "U" "" ""
     _Query            is OPENED
*/  /* BROWSE BROWSE-2 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Акты проработки */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
{ gbl/stdbtn.i }
    define variable v-ok    as logical      no-undo.
    run add-akt in this-procedure (
          input p-recipe-code
        , output v-ok
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка добавления акта проработки."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if v-ok = yes
    then do:
        run init-fields in this-procedure.
        {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
{ gbl/stdbtn.i }
    define variable v-ok    as logical      no-undo.

    run change-akt in this-procedure (
          input p-recipe-code
        , input browse browse-1 temp_recipe-develop.doc-code
        , input browse browse-1 temp_recipe-develop.doc-date
        , output v-ok
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка изменения акта проработки."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if v-ok = yes
    then do:
        run init-fields in this-procedure.
        {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg-line
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg-line Dialog-Frame
ON CHOOSE OF b-chg-line IN FRAME Dialog-Frame /* Изменить */
DO:
{ gbl/stdbtn.i }
    define variable v-ok    as logical      no-undo.
    run change-line in this-procedure (
          input p-recipe-code
        , input browse browse-1 temp_recipe-develop.doc-code
        , input recipe-develop.gds-code
        , input recipe-develop.qnty
        , input recipe-develop.brutto-qnty
        , output v-ok
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка изменения строки акта."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if v-ok = yes
    then do:
        {&OPEN-QUERY-BROWSE-2}
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
{ gbl/stdbtn.i }
    define variable v-yesno    as logical      no-undo.
    message
        "Удаление акта проработки."
        skip (1)
        skip "Номер рецепта:  " p-recipe-code
        skip "Номер документа:" browse browse-1 temp_recipe-develop.doc-code
        skip "Дата документа: " browse browse-1 temp_recipe-develop.doc-date
        skip (1)
        skip "Удалить акт?"
    view-as alert-box question
    buttons yes-no
    title "Удаление акта"
    update v-yesno.
    if v-yesno = yes
    then do:
        run delete-akt in this-procedure (
              input p-recipe-code
            , input browse browse-1 temp_recipe-develop.doc-code
        ) no-error.
        if error-status :error
        then do:
            message
                    vss-workfile vss-revision vss-description
                skip "Ошибка удаления акта проработки."
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return no-apply .
        end.
        run init-fields in this-procedure.
        {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
    end.        /* if v-yesno = yes */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-gds Dialog-Frame
ON CHOOSE OF b-gds IN FRAME Dialog-Frame /* Товары */
DO:
{ gbl/stdbtn.i }

    if available temp_recipe-develop
    then do:
        { gbl/working.i }
        run form-gds-list in this-procedure (
              input p-recipe-code
            , input temp_recipe-develop.doc-code
            , input temp_recipe-develop.doc-date
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip "Ошибка изменения товаров по списку."
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return no-apply .
        end.
        { gbl/stopwork.i }
        {&OPEN-QUERY-BROWSE-2}
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1 Dialog-Frame
ON VALUE-CHANGED OF BROWSE-1 IN FRAME Dialog-Frame
DO:
    {&OPEN-QUERY-BROWSE-2}
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
       frame {&frame-name} :title = "Акты проработки для рецепта " + p-recipe-code
   .
   run init-fields in this-procedure.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-akt Dialog-Frame
PROCEDURE add-akt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-recipe-code    as character        no-undo.
define output parameter p-ok            as logical          no-undo.

    define variable v-doc-code       as character    no-undo.
    define variable v-doc-date       as date         no-undo.
    define variable v-gds-code      as integer      no-undo.

    define buffer buf_recipe-gds            for recipe-gds.
    define buffer buf_recipe-develop        for recipe-develop.
do
for buf_recipe-gds
  , buf_recipe-develop
on error undo, return error
:
    run ref/rcpaktd.w (
          input {&add-def}
        , input p-recipe-code
        , input ""
        , input ""
        , output v-doc-code
        , output v-doc-date
        , output p-ok
    ).
    if p-ok = yes
    and v-doc-code <> ""
    then do:
        for each buf_recipe-gds no-lock
           where buf_recipe-gds.recipe-code = p-recipe-code
        on error undo, return error
        :
            { gbl/gds-code.i
                buf_recipe-gds.artic
                buf_recipe-gds.prod-type
                buf_recipe-gds.prod-code
                v-gds-code
            }
            create buf_recipe-develop.
            assign
                buf_recipe-develop.recipe-code = p-recipe-code
                buf_recipe-develop.doc-code    = v-doc-code
                buf_recipe-develop.doc-date    = v-doc-date
                buf_recipe-develop.gds-code    = v-gds-code
                buf_recipe-develop.qnty        = buf_recipe-gds.qnty
                buf_recipe-develop.brutto-qnty = buf_recipe-gds.brutto-qnty
            .
        end.        /* for each buf_recipe-gds */
    end.
    if v-doc-code = ""
    then do:
        assign
            p-ok = no
        .
    end.
end.
END PROCEDURE. /* add-akt */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE change-akt Dialog-Frame
PROCEDURE change-akt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-recipe-code    as character        no-undo.
define input parameter p-doc-code       as character        no-undo.
define input parameter p-doc-date       as date             no-undo.
define output parameter p-ok            as logical          no-undo.

    define variable v-doc-code      as character    no-undo.
    define variable v-doc-date      as date         no-undo.
    define variable v-gds-code      as integer      no-undo.

    define buffer buf_recipe-gds            for recipe-gds.
    define buffer buf_recipe-develop        for recipe-develop.
do
for buf_recipe-gds
  , buf_recipe-develop
on error undo, return error
:
    run ref/rcpaktd.w (
          input {&update}
        , input p-recipe-code
        , input p-doc-code
        , input p-doc-date
        , output v-doc-code
        , output v-doc-date
        , output p-ok
    ).
    if p-ok = yes
    and ( v-doc-code <> p-doc-code
        or v-doc-date <> p-doc-date )
    then do:
        for each buf_recipe-develop exclusive-lock
           where buf_recipe-develop.recipe-code = p-recipe-code
             and buf_recipe-develop.doc-code    = p-doc-code
        on error undo, return error
        :
            assign
                buf_recipe-develop.doc-code    = v-doc-code
                buf_recipe-develop.doc-date    = v-doc-date
            .
        end.        /* for each buf_recipe-gds */
    end.
    if v-doc-code = p-doc-code
    and v-doc-date = p-doc-date
    then do:
        assign
            p-ok = no
        .
    end.
end.
END PROCEDURE. /* change-akt */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE change-line Dialog-Frame
PROCEDURE change-line :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-recipe-code    as character        no-undo.
define input parameter p-doc-code       as character        no-undo.
define input parameter p-gds-code       as integer          no-undo.
define input parameter p-qnty           as decimal          no-undo.
define input parameter p-brutto-qnty    as decimal          no-undo.
define output parameter p-ok            as logical          no-undo.

    define variable v-brutto-qnty    as decimal      no-undo.
    define variable v-qnty    as decimal      no-undo.

    define buffer buf_recipe-develop        for recipe-develop.
do
for buf_recipe-develop
on error undo, return error
:
    run ref/rcpaktdl.w (
          input p-qnty
        , input p-brutto-qnty
        , output v-qnty
        , output v-brutto-qnty
        , output p-ok
    ).
    if p-ok = yes
    and p-qnty <> v-qnty
    or p-brutto-qnty <> v-brutto-qnty
    then do:
        find first buf_recipe-develop exclusive-lock
             where buf_recipe-develop.recipe-code = p-recipe-code
               and buf_recipe-develop.doc-code    = p-doc-code
               and buf_recipe-develop.gds-code    = p-gds-code
        .
        assign
            buf_recipe-develop.qnty         = v-qnty
            buf_recipe-develop.brutto-qnty  = v-brutto-qnty
        .
    end.
    if p-qnty = v-qnty
    and p-brutto-qnty = v-brutto-qnty
    then do:
        assign
            p-ok = no
        .
    end.
end.
END PROCEDURE. /* change-line */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-or-update-recipe-develop Dialog-Frame
PROCEDURE create-or-update-recipe-develop :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-recipe-code    as character        no-undo.
define input parameter p-doc-code       as character        no-undo.
define input parameter p-doc-date       as date             no-undo.
define input parameter p-gds-code       as integer          no-undo.
define input parameter p-new-qnty       as decimal          no-undo.

    define buffer buf_recipe-develop        for recipe-develop.
do
for buf_recipe-develop
on error undo, return error
:
    find first buf_recipe-develop no-lock
         where buf_recipe-develop.recipe-code = p-recipe-code
           and buf_recipe-develop.doc-code    = p-doc-code
           and buf_recipe-develop.gds-code    = p-gds-code
    no-error.
    if not available buf_recipe-develop
    or buf_recipe-develop.qnty <> p-new-qnty
    then do:
        find first buf_recipe-develop exclusive-lock
             where buf_recipe-develop.recipe-code = p-recipe-code
               and buf_recipe-develop.doc-code    = p-doc-code
               and buf_recipe-develop.gds-code    = p-gds-code
        no-error.
        if not available buf_recipe-develop
        then do:
            create buf_recipe-develop.
            assign
                buf_recipe-develop.recipe-code = p-recipe-code
                buf_recipe-develop.doc-code    = p-doc-code
                buf_recipe-develop.gds-code    = p-gds-code
            .
        end.
        assign
            buf_recipe-develop.doc-date     = p-doc-date
            buf_recipe-develop.qnty         = p-new-qnty
            buf_recipe-develop.brutto-qnty  = p-new-qnty
        .
    end.
end.
END PROCEDURE. /* create-or-update-recipe-develop */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE delete-akt Dialog-Frame
PROCEDURE delete-akt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-recipe-code    as character        no-undo.
define input parameter p-doc-code       as character        no-undo.

    define buffer buf_recipe-develop        for recipe-develop.
do
for buf_recipe-develop
on error undo, return error
:
    for each buf_recipe-develop exclusive-lock
       where buf_recipe-develop.recipe-code = p-recipe-code
         and buf_recipe-develop.doc-code    = p-doc-code
    on error undo, return error
    :
        delete buf_recipe-develop.
    end.        /* for each buf_recipe-develop */
end.
END PROCEDURE. /* delete-akt */

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
  ENABLE b-exit b-add b-chg b-del b-help BROWSE-1 b-chg-line b-gds BROWSE-2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE form-gds-list Dialog-Frame
PROCEDURE form-gds-list :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-recipe-code    as character        no-undo.
define input parameter p-doc-code       as character        no-undo.
define input parameter p-doc-date       as character        no-undo.

    define buffer buf_recipe-develop    for recipe-develop.
    define buffer buf_recipe            for recipe.
    define buffer buf_goods             for goods.
do
for buf_recipe-develop
  , buf_recipe
  , buf_goods
on error undo, return error
:
    find first buf_recipe no-lock
         where buf_recipe.recipe-code = p-recipe-code
    .
    for each buf_recipe-develop
       where buf_recipe-develop.recipe-code = p-recipe-code
         and buf_recipe-develop.doc-code    = p-doc-code
      , each goods no-lock
       where goods.gds-code     = buf_recipe-develop.gds-code
    :
        { cmp/gds-list.i scn-list assign }
        assign
            scn-list.qnty = buf_recipe-develop.qnty
        .
    end.
    for each scn-list
       where scn-list.to-del = yes
    :
        delete scn-list.
    end.
    { gbl/getcntxt.i get }
    run str/scn-list.w (input parparentproc, input v-cntxt-host-code-obj, input v-cntxt-obj-type, input v-cntxt-obj-code) .

    new-list-create:
    for each scn-list
    :
        find first buf_goods no-lock
             where buf_goods.gds-code = scn-list.gds-code
        .
        assign      /* пометка - потенциально лишняя запись */
            scn-list.to-del = yes
        .
        if buf_goods.gds-type       = {&gds-office}
        and buf_recipe.recipe-type  <> {&manufacturing}
        and buf_recipe.recipe-type  <> {&petrolium-manufacturing}
        then do:
            next new-list-create.
        end.
        run create-or-update-recipe-develop in this-procedure (
              input p-recipe-code
            , input p-doc-code
            , input p-doc-date
            , input scn-list.gds-code
            , input scn-list.qnty
        ).
    end.
    deleted-records:
    for each buf_recipe-develop
       where buf_recipe-develop.recipe-code = p-recipe-code
         and buf_recipe-develop.doc-code    = p-doc-code
    :
        find first scn-list
             where scn-list.gds-code = buf_recipe-develop.gds-code
        no-error.
        if not available scn-list
        then do:
            delete buf_recipe-develop.
        end.
    end.
end.
END PROCEDURE. /* form-gds-list */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-gds-field Dialog-Frame
PROCEDURE get-gds-field :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-par-num        as integer          no-undo.
define input parameter p-gds-code       as integer          no-undo.
define output parameter p-out-string    as character        no-undo.

    define buffer buf_goods     for goods.
do
for buf_goods
on error undo, return error
:
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    no-error.
    if available buf_goods
    then do:
        case p-par-num
        :
            when 1
            then do:
                assign
                    p-out-string = buf_goods.artic
                .
            end.        /* when 1 */
            when 2
            then do:
                assign
                    p-out-string = buf_goods.gds-name
                .
            end.        /* when 2 */
        end case.       /* case p-par-num */
    end.
    else do:
        assign
            p-out-string = ""
        .
    end.

end.
END PROCEDURE. /* get-gds-field */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-fields Dialog-Frame
PROCEDURE init-fields :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define buffer buf_recipe-develop        for recipe-develop.
    define buffer buf_temp_recipe-develop   for temp_recipe-develop.
do
for buf_recipe-develop
  , buf_temp_recipe-develop
on error undo, return error
:
    for each buf_temp_recipe-develop
    on error undo, return error
    :
        delete buf_temp_recipe-develop.
    end.        /* for each buf_temp_recipe-develop */
    for each buf_recipe-develop no-lock
       where buf_recipe-develop.recipe-code = p-recipe-code
    on error undo, return error
    :
        find first buf_temp_recipe-develop
             where buf_temp_recipe-develop.doc-code = buf_recipe-develop.doc-code
        no-error.
        if not available buf_temp_recipe-develop
        then do:
            create buf_temp_recipe-develop.
            assign
                buf_temp_recipe-develop.doc-code = buf_recipe-develop.doc-code
                buf_temp_recipe-develop.doc-date = buf_recipe-develop.doc-date
            .
        end.
    end.        /* for each buf_recipe-develop */
end.
END PROCEDURE. /* init-fields */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-column-value Dialog-Frame
FUNCTION get-column-value RETURNS CHARACTER
  ( input p-column-num as integer, input p-gds-code as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
    define variable v-out-string    as character    no-undo.

    run get-gds-field in this-procedure (
          input p-column-num
        , input p-gds-code
        , output v-out-string
    ).
    return v-out-string.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME