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

Просмотр, изменение и добавление акта проработки для рецептов производства

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
define input parameter p-mode           as character        no-undo.
define input parameter p-recipe-code    as character        no-undo.
define input parameter p-in-doc-code    as character        no-undo.
define input parameter p-in-doc-date    as date             no-undo.
define output parameter p-out-doc-code  as character        no-undo.
define output parameter p-out-doc-date  as date             no-undo.
define output parameter p-ok            as logical          no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр, изменение и добавление акта проработки для рецептов производства".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-cancel b-help fi-doc-code ~
fi-doc-date
&Scoped-Define DISPLAYED-OBJECTS fi-doc-code fi-doc-date

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel AUTO-END-KEY DEFAULT
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-exit AUTO-GO
     LABEL "В&вод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помощ&ь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE fi-doc-code AS CHARACTER FORMAT "X(256)":U
     LABEL "Номер акта"
     VIEW-AS FILL-IN
     SIZE 21 BY 1 NO-UNDO.

DEFINE VARIABLE fi-doc-date AS DATE FORMAT "99.99.9999":U INITIAL ?
     LABEL "Дата"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.25 COL 2
     b-cancel AT ROW 1.25 COL 12
     b-help AT ROW 1.25 COL 28
     fi-doc-code AT ROW 3.5 COL 3.5
     fi-doc-date AT ROW 5 COL 13.5 COLON-ALIGNED
     SPACE(10.37) SKIP(0.87)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Акт проработки"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-cancel.


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

/* SETTINGS FOR FILL-IN fi-doc-code IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
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


&Scoped-define SELF-NAME b-cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cancel Dialog-Frame
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame /* Отмена */
DO:
    assign
        p-ok = no
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
    define variable v-is-available     as logical      no-undo.
    define variable v-reason           as character    no-undo.
    define variable v-focus-handle     as handle       no-undo.
    assign
        fi-doc-code
        fi-doc-date
    .
    run check-output in this-procedure (
          input p-recipe-code
        , input fi-doc-code
        , input fi-doc-date
        , output v-is-available
        , output v-reason
        , output v-focus-handle
    ).
    if v-is-available = no
    then do:
        message
                 v-reason
            skip (1)
            skip "Исправьте данные или отмените ввод."
        view-as alert-box warning.
        apply "entry" to v-focus-handle.
        undo, return no-apply.
    end.
    else do:
        assign
            p-ok            = yes
            p-out-doc-code  = fi-doc-code
            p-out-doc-date  = fi-doc-date
        .
    end.
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
{ gbl/ed_date.i fi-doc-date }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   run init-fields in this-procedure.
  RUN enable_UI.
  apply "entry" to fi-doc-code .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-output Dialog-Frame
PROCEDURE check-output :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input parameter p-recipe-code    as character        no-undo.
    define input parameter p-doc-code       as character        no-undo.
    define input parameter p-doc-date       as date             no-undo.
    define output parameter p-ok            as logical          no-undo.
    define output parameter p-reason        as character        no-undo.
    define output parameter p-focus-handle  as handle           no-undo.

    define buffer buf_recipe-develop        for recipe-develop.
do
for buf_recipe-develop
on error undo, return error
:
    assign
        p-ok = yes
    .
    if p-mode = {&add-def}
    then do:        /* При добавлении акта - проверка на то, что такого номера документа еще не было */
        find first buf_recipe-develop no-lock
             where buf_recipe-develop.recipe-code = p-recipe-code
               and buf_recipe-develop.doc-code    = p-doc-code
        no-error.
        if available buf_recipe-develop
        then do:
            assign
                p-ok            = no
                p-reason        = "Акт проработки с таким номером уже есть."
                p-focus-handle  = fi-doc-code :handle in frame {&frame-name}
            .
        end.
    end.
    if p-mode = {&update}
    then do:
        if p-doc-code <> p-in-doc-code
        then do:        /* При изменении номера документа проверка на ввод существующего номера */
            find first buf_recipe-develop no-lock
                 where buf_recipe-develop.recipe-code = p-recipe-code
                   and buf_recipe-develop.doc-code    = p-doc-code
            no-error.
            if available buf_recipe-develop
            then do:
                assign
                    p-ok            = no
                    p-reason        = "Акт проработки с таким номером уже есть."
                    p-focus-handle  = fi-doc-code :handle in frame {&frame-name}
                .
            end.
        end.
    end.
end.
END PROCEDURE. /* check-output */

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
  DISPLAY fi-doc-code fi-doc-date
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-cancel b-help fi-doc-code fi-doc-date
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
    assign
        fi-doc-code = p-in-doc-code
        fi-doc-date = p-in-doc-date
    .
end.
END PROCEDURE. /* init-fields */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME