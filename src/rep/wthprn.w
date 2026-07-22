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

Список печатных форм для печати документов материальных ценностей

Автор: Демин Алексей Сергеевич
Дата создания: 03/20/06
Author: Alexey Demin
Creation date: 03/20/06

Input:

Output:

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

define temp-table temp_wth-doc-code no-undo
    field doc-code as character
    index pi is primary unique doc-code
.
/* Parameters Definitions ---                                           */

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter table for temp_wth-doc-code .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список печатных форм для печати документов материальных ценностей".
{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/library.i      }
{ cmp/r-pril.i new   }
{ gbl/color.i        }
{ rep/menu-doc.i def }
{ gbl/getcntxt.i def }

define new shared variable print-graft as logical no-undo .
define new shared variable sort-gr     as logical no-undo .
define new shared variable sort-name   as logical no-undo .
define new shared variable CostPrice   as logical no-undo .
define new shared variable PrintScale  as logical no-undo .

define variable in-docprvalue       as character    no-undo.

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-table

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES Tmp#List

/* Definitions for BROWSE br-table                                      */
&Scoped-define FIELDS-IN-QUERY-br-table Tmp#List.last-use Tmp#List.blank-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-table
&Scoped-define SELF-NAME br-table
&Scoped-define OPEN-QUERY-br-table /* OPEN QUERY {&SELF-NAME} FOR EACH Tmp#List no-lock . */ run local-open-query in this-procedure .
&Scoped-define TABLES-IN-QUERY-br-table Tmp#List
&Scoped-define FIRST-TABLE-IN-QUERY-br-table Tmp#List


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-table}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-chg b-print b-help br-table ~
fi-default-printer
&Scoped-Define DISPLAYED-OBJECTS fi-default-printer

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-deselect
     LABEL "&Снять *"
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помощ&ь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-print
     LABEL "Пе&чать":L
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sel
     LABEL "*"
     SIZE 3 BY 1.

DEFINE VARIABLE fi-default-printer AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 97 BY .67
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-table FOR
      Tmp#List SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-table Dialog-Frame _FREEFORM
  QUERY br-table NO-LOCK DISPLAY
      Tmp#List.last-use COLUMN-LABEL "*" FORMAT "*/"
    Tmp#List.blank-name COLUMN-LABEL "Название печатной формы":C57 FORMAT "X(57)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.88 BY 20.25 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1.63
     b-sel AT ROW 1 COL 11.63
     b-deselect AT ROW 1 COL 14.63
     b-chg AT ROW 1 COL 43
     b-print AT ROW 1 COL 79.5
     b-help AT ROW 1 COL 89.5
     br-table AT ROW 2.25 COL 1.63
     fi-default-printer AT ROW 22.75 COL 1.5 NO-LABEL
     SPACE(1.37) SKIP(0.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список печатных форм".


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
/* BROWSE-TAB br-table b-help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON b-deselect IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-sel IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-default-printer IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN
       fi-default-printer:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-table
/* Query rebuild information for BROWSE br-table
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH Tmp#List no-lock . */
run local-open-query in this-procedure .
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* BROWSE br-table */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Список печатных форм */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
    if available tmp#list
    then do:
        define variable v-options-string            as character    no-undo.
        define variable v-options-string-new        as character    no-undo.
        define variable v-options-enabled-string    as character    no-undo.
        run menu-doc-create-options-string in this-procedure (
              input tmp#list.id
            , output v-options-string
        ).
        run menu-doc-create-options-enabled-string in this-procedure (
              input tmp#list.id
            , output v-options-enabled-string
        ).
        run rep/wthprnd.w (
              input tmp#list.blank-name
            , input v-options-string
            , input v-options-enabled-string
            , output v-options-string-new
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка изменения параметров печати."
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return no-apply .
        end.
        if v-options-string-new <> v-options-string
        then do:
            run menu-doc-set-options-string in this-procedure (
                    input tmp#list.id
                  , input v-options-string-new
            ).
            browse {&browse-name} :refresh().
            apply "entry" to {&browse-name} in frame {&frame-name}.
        end.
    end.        /* available tmp#list */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-deselect
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-deselect Dialog-Frame
ON CHOOSE OF b-deselect IN FRAME Dialog-Frame /* Снять * */
DO:
    for each tmp#list no-lock
    :
        assign
            tmp#list.last-use = no
        .
    end.        /* for each tmp#list */
    browse {&browse-name} :refresh().
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
DO:
    run save-form-parameters in this-procedure no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка при сохранении параметров"
            skip "списка печатных форм."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:
    define variable v-is-selected   as logical      no-undo.
    define buffer buf_temp_tmp#list      for tmp#list.
    assign
        v-is-selected = no
    .
    test-selecting:
    for each buf_temp_tmp#list
    :
        if buf_temp_tmp#list.last-use <> no
        then do:
            assign
                v-is-selected = yes
            .
            leave test-selecting.
        end.
    end.
    if v-is-selected = no
    then do:
        message
            "Не выбрано ни одной формы"
            skip "для печати."
        view-as alert-box information
        title "Печать невозможна"
        .
        undo, return no-apply.
    end.
    else do:
        run print-docs in this-procedure no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка печати документов."
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return no-apply .
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* * */
DO:
    if available tmp#list
    then do:
        assign
            tmp#list.last-use = ( if tmp#list.last-use = yes then no else yes )
        .
        run reposition-browse in this-procedure .
        browse {&browse-name} :refresh().
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-table
&Scoped-define SELF-NAME br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table Dialog-Frame
ON 1 OF br-table IN FRAME Dialog-Frame
DO:
    if available tmp#list
    then do:
        if tmp#list.type-price = "  +":U
        or tmp#list.type-price = "  -":U
        then do:
            assign
                tmp#list.type-price = ( if tmp#list.type-price = "  +":U then "  -":U else "  +":U )
            .
        end.
        {&browse-name} :refresh().
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table Dialog-Frame
ON 2 OF br-table IN FRAME Dialog-Frame
DO:
    if available tmp#list
    then do:
        if tmp#list.type-scale = "  +":U
        or tmp#list.type-scale = "  -":U
        then do:
            assign
                tmp#list.type-scale = ( if tmp#list.type-scale = "  +":U then "  -":U else "  +":U )
            .
        end.
        {&browse-name} :refresh().
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table Dialog-Frame
ON 3 OF br-table IN FRAME Dialog-Frame
DO:
    if available tmp#list
    then do:
        if tmp#list.type-val = "  +":U
        or tmp#list.type-val = "  -":U
        then do:
            assign
                tmp#list.type-val = ( if tmp#list.type-val = "  +":U then "  -":U else "  +":U )
            .
        end.
        {&browse-name} :refresh().
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table Dialog-Frame
ON 4 OF br-table IN FRAME Dialog-Frame
DO:
    if available tmp#list
    then do:
        if tmp#list.sort-name = "  +":U
        or tmp#list.sort-name = "  -":U
        then do:
            assign
                tmp#list.sort-name = ( if tmp#list.sort-name = "  +":U then "  -":U else "  +":U )
            .
        end.
        {&browse-name} :refresh().
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table Dialog-Frame
ON 5 OF br-table IN FRAME Dialog-Frame
DO:
    if available tmp#list
    then do:
        if tmp#list.sort-gr = "  +":U
        or tmp#list.sort-gr = "  -":U
        then do:
            assign
                tmp#list.sort-gr = ( if tmp#list.sort-gr = "  +":U then "  -":U else "  +":U )
            .
        end.
        {&browse-name} :refresh().
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table Dialog-Frame
ON 6 OF br-table IN FRAME Dialog-Frame
DO:
    if available tmp#list
    then do:
        if tmp#list.print-graft = "  +":U
        or tmp#list.print-graft = "  -":U
        then do:
            assign
                tmp#list.print-graft = ( if tmp#list.print-graft = "  +":U then "  -":U else "  +":U )
            .
        end.
        {&browse-name} :refresh().
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF br-table IN FRAME Dialog-Frame
DO:
    if available Tmp#List
    then do:
        run select-or-deselect-item in this-procedure (
            input Tmp#List.id
        ) no-error.
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description
                skip "Ошибка выбора или отмены выбора."
                skip return-value
                skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return no-apply .
        end.
        br-table :refresh().
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table Dialog-Frame
ON ROW-DISPLAY OF br-table IN FRAME Dialog-Frame
DO:
    if Tmp#List.orient-font-num <> 7
    then do:
        assign
            Tmp#List.last-use          :fgcolor in browse {&browse-name} = DARK_GREEN_COLOR
            Tmp#List.blank-name        :fgcolor in browse {&browse-name} = DARK_GREEN_COLOR
        .
    end.        /* if Tmp#List.orient-font-number <> 7 */
    else do:
        if Tmp#List.orient-orientation = 'A4port':U
        or Tmp#List.orient-orientation = 'A3port':U
        then do:
            Tmp#List.last-use          :fgcolor in browse {&browse-name} = BLUE_COLOR.
            Tmp#List.blank-name        :fgcolor in browse {&browse-name} = BLUE_COLOR.
        end.
        else do:
            if Tmp#List.orient-orientation = 'EXCEL':U
            or Tmp#List.orient-orientation = 'self':U
            then do:
                Tmp#List.last-use   :fgcolor in browse {&browse-name} = CYAN_COLOR.
                Tmp#List.blank-name :fgcolor in browse {&browse-name} = CYAN_COLOR.
            end.
            else do:
                Tmp#List.last-use   :fgcolor in browse {&browse-name} = BLACK_COLOR.
                Tmp#List.blank-name :fgcolor in browse {&browse-name} = BLACK_COLOR.
            end.
        end.
    end.        /* NOT ( if Tmp#List.orient-font-number <> 7 ) */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


{ gbl/hot-key.i b-help }
{ gbl/hot-key.i b-exit }
{ gbl/hot-key.i b-print}
/* ***************************  Main Block  *************************** */

{ gbl/app_help.i }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/*on ctrl-alt-f3 anywhere*/
/*do:*/
/*    define variable v-str    as character    no-undo.*/
/*    for each tmp#list*/
/*    where tmp#list.last-use = yes*/
/*    :*/
/*        assign*/
/*            v-str = v-str + {&new-line} + tmp#list.blank-name*/
/*        .*/
/*    end.*/
/*    message*/
/*        "X"*/
/*        skip v-str*/
/*    view-as alert-box information.*/
/*end.*/

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    { gbl/getcntxt.i get " " p-mainmenu-handle }
    run get-quest-print in p-mainmenu-handle (
        output g#quest-print
    ).
    run get-report-num in p-mainmenu-handle (
        output g#report-num
    ).
    run get-quest-print in p-mainmenu-handle (
        output g#quest-print
    ).
    run init-fields in this-procedure.
    RUN enable_UI.
    run ui-disable-all in this-procedure.
    run ui-enable in this-procedure.
    apply "value-changed" to br-table.
    apply "entry" to br-table.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-menu-items Dialog-Frame
PROCEDURE create-menu-items :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-doc-code       as character        no-undo.
define input parameter p-doc-type       as character        no-undo.
define input parameter p-ext-doc-type   as character        no-undo.
define input parameter p-status_        as character        no-undo.
define input parameter p-Internal       as character        no-undo.
define input parameter p-flag_          as character        no-undo.

    define variable xtype        as character    no-undo.
    define variable xstatus      as character    no-undo.
    define variable xInternal    as character    no-undo.
    define variable xflag        as character    no-undo.
do
on error undo, return error
:
    assign
        xtype               = p-doc-type
        xstatus             = string( p-status_  )
        xInternal           = string( p-Internal )
        xflag               = string( p-flag_    )
    .
    assign
        v-menu-doc-doc-code = p-doc-code
        v-menu-doc-doc-type = xtype
        v-menu-doc-status_  = xstatus
        v-menu-doc-internal = xInternal
        v-menu-doc-flag     = xflag
    .
    { rep/wthprn.i }
end.
END PROCEDURE. /* create-menu-items */

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
  DISPLAY fi-default-printer
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-chg b-print b-help br-table fi-default-printer
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-call-point Dialog-Frame
PROCEDURE get-call-point :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-tmp#list-id as integer          no-undo.
define output parameter p-call-point as character        no-undo.

    define variable v-doc-type        as character    no-undo.
    define variable v-doc-status      as character    no-undo.
    define variable v-doc-internal    as character    no-undo.
    define variable v-doc-flag        as character    no-undo.

    define buffer buf_temp_form-list        for temp_form-list.
do
for buf_temp_form-list
on error undo, return error
:
    assign
        v-doc-type     = "":U
        v-doc-status   = "":U
        v-doc-internal = "":U
        v-doc-flag     = "":U
    .
    for each buf_temp_form-list
       where buf_temp_form-list.id = Tmp#List.id
    :
        if lookup( buf_temp_form-list.doc-type, v-doc-type ) = 0
        then do:
            assign
                v-doc-type = ( if v-doc-type = "":U then "":U else "_":U ) + buf_temp_form-list.doc-type
            .
        end.
        if lookup( buf_temp_form-list.status_, v-doc-status ) = 0
        then do:
            assign
                v-doc-status = ( if v-doc-status = "":U then "":U else "_":U ) + buf_temp_form-list.status_
            .
        end.
        if lookup( buf_temp_form-list.internal, v-doc-internal ) = 0
        then do:
            assign
                v-doc-internal = ( if v-doc-internal = "":U then "":U else "_":U ) + buf_temp_form-list.internal
            .
        end.
        if lookup( buf_temp_form-list.flag, v-doc-flag ) = 0
        then do:
            assign
                v-doc-flag = ( if v-doc-flag = "":U then "":U else "_":U ) + buf_temp_form-list.flag
            .
        end.
    end.
    assign
        p-call-point = substitute( "&1,&2,&3,&4", v-doc-type, v-doc-status, v-doc-internal, v-doc-flag )
    .
end.
END PROCEDURE. /* get-call-point */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-saved-character Dialog-Frame
PROCEDURE get-saved-character :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-list           as character        no-undo.
define input parameter p-name           as character        no-undo.
define output parameter p-character     as character        no-undo.

    define variable v-position    as integer      no-undo.
do
on error undo, return error
:
    assign
        v-position = lookup( p-name, p-list )
    .
    if v-position = 0
    then do:
        assign
            p-character = "":U
        .
    end.
    else do:
        if num-entries( p-list ) > v-position
        then do:
            assign
                p-character = entry( v-position + 1, p-list )
            .
        end.
        else do:
            assign
                p-character = "":U
            .
        end.
    end.

end.
END PROCEDURE. /* get-saved-character */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-saved-logical Dialog-Frame
PROCEDURE get-saved-logical :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-list       as character        no-undo.
define input parameter p-name       as character        no-undo.
define output parameter p-logical   as character        no-undo.

    define variable v-position    as integer      no-undo.
do
on error undo, return error
:
    assign
        v-position = lookup( p-name, p-list )
    .
    if v-position = 0
    then do:
        assign
            p-logical = "  -":U
        .
    end.
    else do:
        if num-entries( p-list ) > v-position
        then do:
            assign
                p-logical = "  ":U + entry( v-position + 1, p-list )
            .
            if trim( p-logical ) = "":U
            then do:
                assign
                    p-logical = "  -":U
                .
            end.
        end.
        else do:
            assign
                p-logical = "  -":U
            .
        end.
    end.
end.
END PROCEDURE. /* get-saved-logical */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-fields Dialog-Frame
PROCEDURE init-fields :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

define variable xtype        as character    no-undo.
define variable xstatus      as character    no-undo.
define variable xInternal    as character    no-undo.
define variable xflag        as character    no-undo.

    define variable v-temp-char     as character    no-undo.
    define variable v-call-point    as character    no-undo.
    define variable v-doc-counter   as integer      no-undo.
    define variable v-form-title    as character    no-undo.

    define buffer buf_wth-doc           for ub.wth-doc.
    define buffer buf_usr-flt           for ubflt.usr-flt.
do
for buf_wth-doc
  , buf_usr-flt
with frame {&frame-name}
on error undo, return error
:
    assign
        fi-default-printer = session :printer-name
    .
    { gbl/currsysk.i
      v-menu-doc-sys-key
      no-error
    }

    for each temp_wth-doc-code
    on error undo, return error
    :
        assign
            v-doc-counter = v-doc-counter + 1
        .
        find first buf_wth-doc no-lock
             where buf_wth-doc.doc-code = temp_wth-doc-code.doc-code
        .
        run create-menu-items in this-procedure (
              input buf_wth-doc.doc-code
            , input buf_wth-doc.doc-type
            , input buf_wth-doc.ext-doc-type
            , input buf_wth-doc.status_
            , input substitute( "&1,&2", buf_wth-doc.exter_, buf_wth-doc.inter_ )
            , input buf_wth-doc.ext-doc-type
        ).
    end.        /* for each temp_wth-doc-code */
    if v-doc-counter = 1
    then do:
        assign
            v-form-title = substitute( "Печать документа   Тип: &1 Статус: &2&3 &4   № &5"
                , v-menu-doc-doc-type
                , v-menu-doc-status_
                , string( v-menu-doc-flag, "+/-" )
                , string( v-menu-doc-internal,"внутренний/внешний")
                , v-menu-doc-doc-code )
        .
    end.
    else do:
        assign
            v-form-title = substitute( "Печать выбранных документов по списку" )
        .
    end.
    assign
        frame {&frame-name} :title = v-form-title
    .
/*    run test-temp-tables in this-procedure .*/
    /* загрузить значения из ubflt.usr-flt       */
    for each Tmp#List
    :
        run get-call-point in this-procedure (
              input Tmp#List.id
            , output v-call-point
        ).
        find first buf_usr-flt no-lock
             where buf_usr-flt.user-name  = v-cntxt-userid
               and buf_usr-flt.call-point = substitute( "&1,&2,&3,&4"
                                            , Tmp#List.blank-name
                                            , Tmp#List.sys-key
                                            , Tmp#List.sys-key-black
                                            , v-call-point )
        no-error.
        if available buf_usr-flt
        then do:
            run get-saved-logical in this-procedure (
                  input buf_usr-flt.list_
                , input "type-price":U
                , output Tmp#List.type-price
            ).
            run get-saved-logical in this-procedure (
                  input buf_usr-flt.list_
                , input "type-val":U
                , output Tmp#List.type-val
            ).
            run get-saved-logical in this-procedure (
                  input buf_usr-flt.list_
                , input "sort-gr":U
                , output Tmp#List.sort-gr
            ).
            run get-saved-logical in this-procedure (
                  input buf_usr-flt.list_
                , input "print-graft":U
                , output Tmp#List.print-graft
            ).
            run get-saved-logical in this-procedure (
                  input buf_usr-flt.list_
                , input "type-scale":U
                , output Tmp#List.type-scale
            ).
            run get-saved-logical in this-procedure (
                  input buf_usr-flt.list_
                , input "sort-name":U
                , output Tmp#List.sort-name
            ).
            assign
                v-temp-char = "":U
            .
            run get-saved-logical in this-procedure (
                  input buf_usr-flt.list_
                , input "selection":U
                , output v-temp-char
            ).
            if v-temp-char = "  +":U
            then do:
                assign
                    Tmp#List.last-use = yes
                .
            end.
        end.
        else do:
            assign
                Tmp#List.type-price   = "  -":U
                Tmp#List.type-val     = "  -":U
                Tmp#List.sort-gr      = "  -":U
                Tmp#List.sort-name    = "  -":U
                Tmp#List.print-graft  = "  -":U
                Tmp#List.type-scale   = "  -":U
            .
        end.
        if Tmp#List.type-price-enabled = no
        then do:
            assign
                Tmp#List.type-price   = " ":U
            .
        end.
        if Tmp#List.type-val-enabled = no
        then do:
            assign
                Tmp#List.type-val     = " ":U
            .
        end.
        if Tmp#List.sort-gr-enabled = no
        then do:
            assign
                Tmp#List.sort-gr      = " ":U
            .
        end.
        if Tmp#List.sort-name-enabled = no
        then do:
            assign
                Tmp#List.sort-name    = " ":U
            .
        end.
        if Tmp#List.print-graft-enabled = no
        then do:
            assign
                Tmp#List.print-graft  = " ":U
            .
        end.
        if Tmp#List.type-scale-enabled = no
        then do:
            assign
                Tmp#List.type-scale   = " ":U
            .
        end.
    end.        /* for each Tmp#List */
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-open-query Dialog-Frame
PROCEDURE local-open-query :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/
        open query {&browse-name}
        for each Tmp#List no-lock
           where Tmp#List.view_ <> 0
        by Tmp#List.id
        .
 END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE print-docs Dialog-Frame
PROCEDURE print-docs :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define variable v-doc-type          as character    no-undo.
    define variable v-status            as character    no-undo.
    define variable v-internal          as character    no-undo.
    define variable v-flag              as character    no-undo.
    define variable v-form-amount       as integer      no-undo.
    define variable v-user-action       as character    no-undo.
    define variable v-printed           as logical      no-undo.

    define buffer buf_wth-doc       for ub.wth-doc.
    define buffer buf_t_tmp#list    for tmp#list.
    define buffer buf_tmp#list      for tmp#list.
do
for buf_wth-doc
  , buf_t_tmp#list
  , buf_tmp#list
with frame {&frame-name}
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
:
/*    run test-temp-tables in this-procedure .*/
    if g#quest-print = yes
    then do:
        output  to value( string( session:temp-directory + "$" + string( g#report-num ) ) ) .
        output close.
    End.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) .
    output close.
    output to value( string( session:temp-directory + {&DF_Name} + string( g#report-num ) ) + ".txl" ) .
    output close.
    for each temp_form-list
    by temp_form-list.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    :
        for each buf_tmp#list
           where buf_tmp#list.id = temp_form-list.id
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        :
            if buf_tmp#list.last-use <> no
            then do:
                find first buf_t_tmp#list no-lock
                     where buf_t_tmp#list.id = temp_form-list.id
                .
                assign
                    v-form-amount = v-form-amount + 1
                .
                find first buf_wth-doc
                     where buf_wth-doc.doc-code = temp_form-list.doc-code
                no-lock.
                assign
                    v-doc-type = buf_wth-doc.doc-type
                    v-status   = string( buf_wth-doc.status_  )
                    v-internal = substitute( "&1,&2", buf_wth-doc.exter_, buf_wth-doc.inter_ )
                    v-flag     = string( buf_wth-doc.ext-doc-type    )
                .
                assign
                    print-graft = ( trim( buf_tmp#list.print-graft ) = "+":U )
                    sort-gr     = ( trim( buf_tmp#list.sort-gr     ) = "+":U )
                    sort-name   = ( trim( buf_tmp#list.sort-name   ) = "+":U )
                    CostPrice   = ( trim( buf_tmp#list.type-price  ) <> "+":U )
                    PrintScale  = ( trim( buf_tmp#list.type-scale  ) = "+":U )
                    PrintRubl   = ( trim( buf_tmp#list.type-val    ) = "+":U )
                .
                case num-entries( buf_tmp#list.proc-param )
                :
                    when 0
                    then do:
                        run value ( buf_tmp#list.proc-name )  (
                              input p-mainmenu-handle
                            , input buf_wth-doc.doc-code
                        ).
                    end.
                    when 1
                    then do:
                        run value ( buf_tmp#list.proc-name ) (
                              input p-mainmenu-handle
                            , input buf_wth-doc.doc-code
                            , input buf_tmp#list.proc-param
                        ).
                    end.
                    when 2
                    then do:
                        run value ( buf_tmp#list.proc-name )  (
                              input p-mainmenu-handle
                            , input buf_wth-doc.doc-code
                            , input entry( 1, buf_tmp#list.proc-param )
                            , input entry( 2, buf_tmp#list.proc-param )
                        ).
                    end.
                    when 3
                    then do:
                        run value ( buf_tmp#list.proc-name )  (
                              input p-mainmenu-handle
                            , input buf_wth-doc.doc-code
                            , input entry( 1, buf_tmp#list.proc-param )
                            , input entry( 2, buf_tmp#list.proc-param )
                            , input entry( 3, buf_tmp#list.proc-param )
                        ).
                    end.
                    when 4
                    then do:
                        run value ( buf_tmp#list.proc-name )  (
                              input p-mainmenu-handle
                            , input buf_wth-doc.doc-code
                            , input entry( 1, buf_tmp#list.proc-param )
                            , input entry( 2, buf_tmp#list.proc-param )
                            , input entry( 3, buf_tmp#list.proc-param )
                            , input entry( 4, buf_tmp#list.proc-param )
                        ).
                    end.
                    when 5
                    then do:
                        run value ( buf_tmp#list.proc-name )  (
                              input p-mainmenu-handle
                            , input buf_wth-doc.doc-code
                            , input entry( 1, buf_tmp#list.proc-param )
                            , input entry( 2, buf_tmp#list.proc-param )
                            , input entry( 3, buf_tmp#list.proc-param )
                            , input entry( 4, buf_tmp#list.proc-param )
                            , input entry( 5, buf_tmp#list.proc-param )
                        ).
                    end.
                    when 6
                    then do:
                        run value ( buf_tmp#list.proc-name )  (
                              input p-mainmenu-handle
                            , input buf_wth-doc.doc-code
                            , input entry( 1, buf_tmp#list.proc-param )
                            , input entry( 2, buf_tmp#list.proc-param )
                            , input entry( 3, buf_tmp#list.proc-param )
                            , input entry( 4, buf_tmp#list.proc-param )
                            , input entry( 5, buf_tmp#list.proc-param )
                            , input entry( 6, buf_tmp#list.proc-param )
                        ).
                    end.
                end case.
            end.
        end.
    end.        /* for each temp_form-list */
    if g#quest-print = yes
    Then do:
        os-delete
            value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) )
        .
        os-rename
            value(  string( session:temp-directory ) + "$" + string( g#report-num ) )
            value(  string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) )
        .
        os-delete
            value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
        .
        os-rename
            value(  string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
            value(  string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
        .
        /* Если протокол цен Excel Или tick-doc  у них своя печать */
        if v-form-amount = 1
        and ((can-find (first buf_tmp#list where CAPS(buf_tmp#list.proc-name) = "XL-PRTCL.P":U and buf_tmp#list.last-use = yes) = yes  )
        or (can-find (first buf_tmp#list where CAPS(buf_tmp#list.proc-name) = "TICK-DOC.P":U and buf_tmp#list.last-use = yes) = yes  ))
        then do:
            { gbl/stopwork.i }
        end.
        else do
        :
            find first buf_tmp#list
                 where buf_tmp#list.last-use = yes
            no-error.
            if available buf_tmp#list
            then do:
                case buf_tmp#list.orient-orientation
                :
                    when "A4port":U
                    then do:
                        run gbl/prnfilen.w (
                              input "":U
                            , input 0
                            , input string( session :temp-directory )
                                        + {&DF_Name}
                                        + string( g#report-num )
                            , input buf_tmp#list.orient-font-num
                            , output v-user-action
                            , output v-printed
                        ) .
                    end.
                    when "A4lans":U
                    or when ""
                    then do:
                        run gbl/prnfilen.w (
                              input "":U
                            , input 8
                            , input string( session :temp-directory )
                                        + {&DF_Name}
                                        + string( g#report-num )
                            , input buf_tmp#list.orient-font-num
                            , output v-user-action
                            , output v-printed
                        ) .
                    end.
                end case.
            end.
        end.
    end.
    else do:
        Message 'Задание распечатано'.
    end.
end.
END PROCEDURE. /* print-docs */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-browse Dialog-Frame
PROCEDURE reposition-browse :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
with frame {&frame-name}
on error undo, return error
:
    define variable v-focused-row    as integer      no-undo.
    assign
        v-focused-row     = {&browse-name} :focused-row in frame {&FRAME-NAME}.
    .
    get next {&browse-name}.
    if available tmp#list
    then do:
        if v-focused-row >= {&browse-name} :height-chars - 4
        then do:
            {&browse-name} :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame {&FRAME-NAME}.
        end.
        else do:
            {&browse-name} :set-repositioned-row( v-focused-row + 1, "ALWAYS" ) in frame {&FRAME-NAME}.
        end.
        reposition {&browse-name} to rowid rowid( tmp#list ) no-error.
    end.
    else do:
        get last {&browse-name}.
    end.
end.
END PROCEDURE. /* reposition-browse */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-to-recid Dialog-Frame
PROCEDURE reposition-to-recid :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-ext-system-recid  as recid        no-undo.
do
on error undo, return error
:
    if p-ext-system-recid <> ?
    then do:
        reposition br-table to recid p-ext-system-recid no-error .
    end.
    do with frame {&frame-name}
    :
        apply "entry":u to browse {&browse-name} .
    end. /* do with frame */

end.
END PROCEDURE. /* reposition-to-recid */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-form-parameters Dialog-Frame
PROCEDURE save-form-parameters :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define variable v-call-point    as character    no-undo.

    define buffer buf_tmp#list          for tmp#list.
    define buffer buf_usr-flt           for ubflt.usr-flt.
    define buffer buf_temp_form-list    for temp_form-list.
do
for buf_tmp#list
  , buf_usr-flt
  , buf_temp_form-list
on error undo, return error
:
    for each buf_tmp#list
    :
        run get-call-point in this-procedure (
              input buf_tmp#list.id
            , output v-call-point
        ).
        find first buf_usr-flt exclusive-lock
             where buf_usr-flt.user-name  = v-cntxt-userid
               and buf_usr-flt.call-point = substitute( "&1,&2,&3,&4"
                                            , buf_tmp#list.blank-name
                                            , buf_tmp#list.sys-key
                                            , buf_tmp#list.sys-key-black
                                            , v-call-point )
        no-error.
        if not available buf_usr-flt
        then do:
            create buf_usr-flt.
            assign
                buf_usr-flt.user-name  = v-cntxt-userid
                buf_usr-flt.call-point = substitute( "&1,&2,&3,&4"
                                            , buf_tmp#list.blank-name
                                            , buf_tmp#list.sys-key
                                            , buf_tmp#list.sys-key-black
                                            , v-call-point )
            .
        end.
        assign
            buf_usr-flt.list_ = substitute( "selection,&1,type-price,&2,type-scale,&3,type-val,&4,sort-name,&5,sort-gr,&6,print-graft,&7":U
                                    , ( if buf_tmp#list.last-use = yes then "+":U else "-":U )
                                    , ( if index( buf_tmp#list.type-price , "+":U ) <> 0 then "+":U else "-":U )
                                    , ( if index( buf_tmp#list.type-scale , "+":U ) <> 0 then "+":U else "-":U )
                                    , ( if index( buf_tmp#list.type-val   , "+":U ) <> 0 then "+":U else "-":U )
                                    , ( if index( buf_tmp#list.sort-name  , "+":U ) <> 0 then "+":U else "-":U )
                                    , ( if index( buf_tmp#list.sort-gr    , "+":U ) <> 0 then "+":U else "-":U )
                                    , ( if index( buf_tmp#list.print-graft, "+":U ) <> 0 then "+":U else "-":U )
                                    )
        .
    end.
end.
END PROCEDURE. /* save-form-parameters */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-or-deselect-item Dialog-Frame
PROCEDURE select-or-deselect-item :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input  parameter p-id as integer    no-undo.

    define buffer buf_tmp#list for tmp#list.
do
for buf_tmp#list
on error undo, return error
:
    find first buf_tmp#list
         where buf_tmp#list.id = p-id
    .
    if buf_tmp#list.last-use = yes
    then do:
        assign
            buf_tmp#list.last-use = no
        .
    end.
    else do:
        assign
            buf_tmp#list.last-use = yes
        .
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE test-temp-tables Dialog-Frame
PROCEDURE test-temp-tables :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define buffer buf_t_tmp#list      for tmp#list.
do
for buf_t_tmp#list
on error undo, return error
:
/*    output to "D:\111.txt".*/
/*    for each temp_wth-doc-code no-lock*/
/*    :*/
/*        put unformatted*/
/*            skip substitute( "&1", temp_wth-doc-code.doc-code )*/
/*        .*/
/*    end.*/
/*    put unformatted*/
/*        skip "================================================================================"*/
/*    .*/
    for each temp_form-list no-lock
    on error undo, return error
    :
        find first buf_t_tmp#list no-lock
             where buf_t_tmp#list.id = temp_form-list.id
        .
        put unformatted
            skip substitute( "&1 &2 &3 &4 &5 &6 &7 &8", temp_form-list.doc-code, temp_form-list.doc-type, temp_form-list.status_, temp_form-list.internal, temp_form-list.flag, temp_form-list.id, buf_t_tmp#list.blank-name, buf_t_tmp#list.last-use )
        .
    end.        /* for each temp_form-list */
/*    put unformatted*/
/*        skip "================================================================================"*/
/*    .*/
    for each temp_menu-doc_disabled-doc-list no-lock
    on error undo, return error
    :
        put unformatted
            skip substitute( "&1 &2 &3", temp_menu-doc_disabled-doc-list.doc-code, temp_menu-doc_disabled-doc-list.blank-name, temp_menu-doc_disabled-doc-list.reason )
        .
    end.        /* for each temp_menu-doc_disabled-doc-list */
/*    output close.*/
end.
END PROCEDURE. /* test-temp-tables */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ui-disable-all Dialog-Frame
PROCEDURE ui-disable-all :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
/*
    disable
        b-add
        b-del
        b-chg
    with frame {&frame-name} .
*/
end.
END PROCEDURE. /* ui-disable-all */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ui-enable Dialog-Frame
PROCEDURE ui-enable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define buffer buf_clients       for ub.clients.
do
for buf_clients
on error undo, return error
:
    enable
        b-sel
        b-deselect
    with frame {&frame-name} .
end.
END PROCEDURE. /* ui-enable */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME