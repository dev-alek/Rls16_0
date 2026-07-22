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

Типы данных для экспорта внешних подсистем OpenXML.

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Input:
    p-mainmenu-handle   - handle главного окна
    p-mode              - режим вызова:
                            0 - доступна только кнопка Выход
                            1 - возможно редактирование
    p-impexp-type       - {&openxml-import} или {&openxml-export}, для чего вызывается форма
    p-esys-id           - код внешней системы
    p-db-num            - БД внешней системы

Output:

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter p-mainmenu-handle    as widget-handle    no-undo.
define input parameter p-mode               as integer          no-undo.
define input parameter p-impexp-type        as character        no-undo.
define input parameter p-esys-id            as integer          no-undo.
define input parameter p-db-num             as integer          no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Типы данных для внешних подсистем OpenXML.".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ gbl/cur-time.i    }
{ cmp/library.i     }
{ bge/oxmltd.i      }
{ cmp/showinf.i     }

    define buffer buf_init_temp_oxmltd_sel       for temp_oxmltd_sel.
    define buffer buf_init_temp_oxmltd_not_sel   for temp_oxmltd_not_sel.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-table-not-sel

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_init_temp_oxmltd_not_sel ~
buf_init_temp_oxmltd_sel

/* Definitions for BROWSE br-table-not-sel                              */
&Scoped-define FIELDS-IN-QUERY-br-table-not-sel buf_init_temp_oxmltd_not_sel.sel get-type-name( input buf_init_temp_oxmltd_not_sel.id )
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-table-not-sel
&Scoped-define SELF-NAME br-table-not-sel
&Scoped-define OPEN-QUERY-br-table-not-sel /* OPEN QUERY {&SELF-NAME} FOR EACH buf_init_temp_oxmltd_not_sel no-lock . */ run local-open-query-not-sel in this-procedure .
&Scoped-define TABLES-IN-QUERY-br-table-not-sel ~
buf_init_temp_oxmltd_not_sel
&Scoped-define FIRST-TABLE-IN-QUERY-br-table-not-sel buf_init_temp_oxmltd_not_sel


/* Definitions for BROWSE br-table-sel                                  */
&Scoped-define FIELDS-IN-QUERY-br-table-sel buf_init_temp_oxmltd_sel.sel get-type-name( input buf_init_temp_oxmltd_sel.id )
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-table-sel
&Scoped-define SELF-NAME br-table-sel
&Scoped-define OPEN-QUERY-br-table-sel /* OPEN QUERY {&SELF-NAME} FOR EACH buf_init_temp_oxmltd_sel no-lock . */ run local-open-query-sel in this-procedure .
&Scoped-define TABLES-IN-QUERY-br-table-sel buf_init_temp_oxmltd_sel
&Scoped-define FIRST-TABLE-IN-QUERY-br-table-sel buf_init_temp_oxmltd_sel


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-table-not-sel}~
    ~{&OPEN-QUERY-br-table-sel}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-cancel b-help bt-sel-properties ~
br-table-sel br-table-not-sel bt-select-type bt-deselect-type ed-desc-sel ~
ed-desc-not-sel
&Scoped-Define DISPLAYED-OBJECTS ed-desc-sel ed-desc-not-sel

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-type-name Dialog-Frame
FUNCTION get-type-name RETURNS CHARACTER
  ( input p-id as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel AUTO-END-KEY DEFAULT
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помощ&ь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON bt-deselect-type
     LABEL "--->"
     SIZE 7 BY 1.

DEFINE BUTTON bt-not-sel-all
     LABEL "+"
     SIZE 3 BY 1 TOOLTIP "Выбрать все".

DEFINE BUTTON bt-not-sel-desel-all
     LABEL "-"
     SIZE 3 BY 1 TOOLTIP "Отменить выбор".

DEFINE BUTTON bt-not-sel-reverse
     LABEL "/"
     SIZE 3 BY 1 TOOLTIP "Инвертировать выбор".

DEFINE BUTTON bt-not-sel-sel
     LABEL "*"
     SIZE 3 BY 1.

DEFINE BUTTON bt-sel-desel-all
     LABEL "-"
     SIZE 3 BY 1 TOOLTIP "Отменить выбор".

DEFINE BUTTON bt-sel-properties
     LABEL "&Свойства"
     SIZE 10 BY 1 TOOLTIP "Инвертировать выбор".

DEFINE BUTTON bt-sel-reverse
     LABEL "/"
     SIZE 3 BY 1 TOOLTIP "Инвертировать выбор".

DEFINE BUTTON bt-sel-sel
     LABEL "*"
     SIZE 3 BY 1.

DEFINE BUTTON bt-sel-sel-all
     LABEL "+"
     SIZE 3 BY 1 TOOLTIP "Выбрать все".

DEFINE BUTTON bt-select-type
     LABEL "<---"
     SIZE 7 BY 1.

DEFINE VARIABLE ed-desc-not-sel AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 43.5 BY 1.63
     FGCOLOR 2  NO-UNDO.

DEFINE VARIABLE ed-desc-sel AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 43.5 BY 1.63
     FGCOLOR 2  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-table-not-sel FOR
      buf_init_temp_oxmltd_not_sel SCROLLING.

DEFINE QUERY br-table-sel FOR
      buf_init_temp_oxmltd_sel SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-table-not-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-table-not-sel Dialog-Frame _FREEFORM
  QUERY br-table-not-sel NO-LOCK DISPLAY
      buf_init_temp_oxmltd_not_sel.sel format " */  "
    get-type-name( input buf_init_temp_oxmltd_not_sel.id ) format "X(40)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 43.5 BY 17.79 ROW-HEIGHT-CHARS .67 EXPANDABLE.

DEFINE BROWSE br-table-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-table-sel Dialog-Frame _FREEFORM
  QUERY br-table-sel NO-LOCK DISPLAY
      buf_init_temp_oxmltd_sel.sel format " */  "
      get-type-name( input buf_init_temp_oxmltd_sel.id ) format "X(40)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 43.5 BY 17.79 ROW-HEIGHT-CHARS .67 EXPANDABLE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 2.5
     b-cancel AT ROW 1 COL 12.5
     b-help AT ROW 1 COL 88
     bt-sel-sel AT ROW 2.5 COL 2.5
     bt-sel-sel-all AT ROW 2.5 COL 5.5
     bt-sel-desel-all AT ROW 2.5 COL 8.5
     bt-sel-reverse AT ROW 2.5 COL 11.5
     bt-sel-properties AT ROW 2.5 COL 36
     bt-not-sel-sel AT ROW 2.5 COL 54.5
     bt-not-sel-all AT ROW 2.5 COL 57.5
     bt-not-sel-desel-all AT ROW 2.5 COL 60.5
     bt-not-sel-reverse AT ROW 2.5 COL 63.5
     br-table-sel AT ROW 3.75 COL 2.5
     br-table-not-sel AT ROW 3.75 COL 54.5
     bt-select-type AT ROW 10.5 COL 46.5
     bt-deselect-type AT ROW 11.5 COL 46.5
     ed-desc-sel AT ROW 21.75 COL 2.5 NO-LABEL
     ed-desc-not-sel AT ROW 21.75 COL 54.5 NO-LABEL
     "Остальные типы данных" VIEW-AS TEXT
          SIZE 26 BY 1 AT ROW 2.5 COL 72
     "Выбранные" VIEW-AS TEXT
          SIZE 10.5 BY 1 AT ROW 2.5 COL 16
     SPACE(72.47) SKIP(20.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список типов данных OpenXML"
         CANCEL-BUTTON b-cancel.


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
/* BROWSE-TAB br-table-sel bt-not-sel-reverse Dialog-Frame */
/* BROWSE-TAB br-table-not-sel br-table-sel Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON bt-not-sel-all IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON bt-not-sel-desel-all IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON bt-not-sel-reverse IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON bt-not-sel-sel IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON bt-sel-desel-all IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON bt-sel-reverse IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON bt-sel-sel IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON bt-sel-sel-all IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       ed-desc-not-sel:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       ed-desc-sel:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-table-not-sel
/* Query rebuild information for BROWSE br-table-not-sel
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH buf_init_temp_oxmltd_not_sel no-lock . */
run local-open-query-not-sel in this-procedure .
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* BROWSE br-table-not-sel */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-table-sel
/* Query rebuild information for BROWSE br-table-sel
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH buf_init_temp_oxmltd_sel no-lock . */
run local-open-query-sel in this-procedure .
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* BROWSE br-table-sel */
&ANALYZE-RESUME



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Список типов данных OpenXML */
DO:
    run check-data in this-procedure.
    case p-impexp-type
    :
        when {&openxml-import}
        then do:
            run assign-import-table in this-procedure.
        end.        /* when {&openxml-import} */
        when {&openxml-export}
        then do:
            run assign-export-table in this-procedure.
        end.        /* when {&openxml-export} */
    end case.       /* case p-impexp-type */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Список типов данных OpenXML */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
    { gbl/stdbtn.i }

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-table-not-sel
&Scoped-define SELF-NAME br-table-not-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table-not-sel Dialog-Frame
ON MOUSE-SELECT-CLICK OF br-table-not-sel IN FRAME Dialog-Frame
DO:
    if p-mode = 1
    then do:
        if available buf_init_temp_oxmltd_not_sel
        then do:
            assign
                buf_init_temp_oxmltd_not_sel.sel = not( buf_init_temp_oxmltd_not_sel.sel )
            .
            display
                sel
            with browse br-table-not-sel .
            apply "entry" to br-table-not-sel.
        end.
    end.        /* if p-mode = 1 */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table-not-sel Dialog-Frame
ON VALUE-CHANGED OF br-table-not-sel IN FRAME Dialog-Frame
or entry of br-table-not-sel IN FRAME Dialog-Frame
DO:
    if available buf_init_temp_oxmltd_sel
    then do:
        run disp-desc-sel in this-procedure (
            input buf_init_temp_oxmltd_sel.id
        ).
    end.
    else do:
        assign
            ed-desc-sel :screen-value = "":U
        .
    end.
    if available buf_init_temp_oxmltd_not_sel
    then do:
        run disp-desc-not-sel in this-procedure (
            input buf_init_temp_oxmltd_not_sel.id
        ).
    end.
    else do:
        assign
            ed-desc-not-sel :screen-value = "":U
        .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-table-sel
&Scoped-define SELF-NAME br-table-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table-sel Dialog-Frame
ON MOUSE-SELECT-CLICK OF br-table-sel IN FRAME Dialog-Frame
DO:
    if p-mode = 1
    then do:
        if available buf_init_temp_oxmltd_sel
        then do:
            assign
                buf_init_temp_oxmltd_sel.sel = not( buf_init_temp_oxmltd_sel.sel )
            .
            display
                sel
            with browse br-table-sel .
            apply "entry" to br-table-sel.
        end.
    end.        /* if p-mode = 1 */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table-sel Dialog-Frame
ON VALUE-CHANGED OF br-table-sel IN FRAME Dialog-Frame
or entry of br-table-sel IN FRAME Dialog-Frame
DO:
    if available buf_init_temp_oxmltd_sel
    then do:
        run disp-desc-sel in this-procedure (
            input buf_init_temp_oxmltd_sel.id
        ).
    end.
    else do:
        assign
            ed-desc-sel :screen-value = "":U
        .
    end.
    if available buf_init_temp_oxmltd_not_sel
    then do:
        run disp-desc-not-sel in this-procedure (
            input buf_init_temp_oxmltd_not_sel.id
        ).
    end.
    else do:
        assign
            ed-desc-not-sel :screen-value = "":U
        .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-deselect-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-deselect-type Dialog-Frame
ON CHOOSE OF bt-deselect-type IN FRAME Dialog-Frame /* ---> */
or mouse-select-dblclick of br-table-sel in frame dialog-frame
DO:
    if p-mode = 1
    then do:
        run oxmltd-deselect in this-procedure (
            input ( if available buf_init_temp_oxmltd_sel then buf_init_temp_oxmltd_sel.id else 0 )
        ) no-error.
        if error-status :error
        then do:
            message
                        vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка отмены типа данных для экспорта."
                skip return-value
                skip trim(error-status :get-message(1))
                        trim(error-status :get-message(2))
                        trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return no-apply .
        end.
        {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
        apply "entry" to br-table-not-sel.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-not-sel-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-not-sel-all Dialog-Frame
ON CHOOSE OF bt-not-sel-all IN FRAME Dialog-Frame /* + */
DO:
    for each buf_init_temp_oxmltd_not_sel
    :
        assign
            buf_init_temp_oxmltd_not_sel.sel = yes
        .
    end.
    br-table-not-sel :refresh().
    apply "entry" to br-table-not-sel.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-not-sel-desel-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-not-sel-desel-all Dialog-Frame
ON CHOOSE OF bt-not-sel-desel-all IN FRAME Dialog-Frame /* - */
DO:
    for each buf_init_temp_oxmltd_not_sel
    :
        assign
            buf_init_temp_oxmltd_not_sel.sel = no
        .
    end.
    br-table-not-sel :refresh().
    apply "entry" to br-table-not-sel.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-not-sel-reverse
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-not-sel-reverse Dialog-Frame
ON CHOOSE OF bt-not-sel-reverse IN FRAME Dialog-Frame /* / */
DO:
    for each buf_init_temp_oxmltd_not_sel
    :
        assign
            buf_init_temp_oxmltd_not_sel.sel = not( buf_init_temp_oxmltd_not_sel.sel )
        .
    end.
    br-table-not-sel :refresh().
    apply "entry" to br-table-not-sel.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-not-sel-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-not-sel-sel Dialog-Frame
ON CHOOSE OF bt-not-sel-sel IN FRAME Dialog-Frame /* * */
DO:
    if available buf_init_temp_oxmltd_not_sel
    then do:
        assign
            buf_init_temp_oxmltd_not_sel.sel = not( buf_init_temp_oxmltd_not_sel.sel )
        .
        display
            sel
        with browse br-table-not-sel .
        run select-and-move-down in this-procedure (
              input browse br-table-not-sel :handle
            , input query br-table-not-sel :handle
        ).
        apply "entry" to br-table-not-sel.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-desel-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-desel-all Dialog-Frame
ON CHOOSE OF bt-sel-desel-all IN FRAME Dialog-Frame /* - */
DO:
    for each buf_init_temp_oxmltd_sel
    :
        assign
            buf_init_temp_oxmltd_sel.sel = no
        .
    end.
    br-table-sel :refresh().
    apply "entry" to br-table-sel.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-properties
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-properties Dialog-Frame
ON CHOOSE OF bt-sel-properties IN FRAME Dialog-Frame /* Свойства */
DO:
    if available buf_init_temp_oxmltd_sel
    then do:
        run bge/oxmlextp.w (
              input p-mainmenu-handle
            , input p-mode
            , input p-impexp-type
            , input p-esys-id
            , input p-db-num
            , input buf_init_temp_oxmltd_sel.id
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка изменения свойств типов"
                skip "данных внешней подсистемы."
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return no-apply .
        end.
    end.
    br-table-sel :refresh().
    apply "entry" to br-table-sel.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-reverse
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-reverse Dialog-Frame
ON CHOOSE OF bt-sel-reverse IN FRAME Dialog-Frame /* / */
DO:
    for each buf_init_temp_oxmltd_sel
    :
        assign
            buf_init_temp_oxmltd_sel.sel = not( buf_init_temp_oxmltd_sel.sel )
        .
    end.
    br-table-sel :refresh().
    apply "entry" to br-table-sel.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-sel Dialog-Frame
ON CHOOSE OF bt-sel-sel IN FRAME Dialog-Frame /* * */
DO:
    if available buf_init_temp_oxmltd_sel
    then do:
        assign
            buf_init_temp_oxmltd_sel.sel = not( buf_init_temp_oxmltd_sel.sel )
        .
        display
            sel
        with browse br-table-sel .
        run select-and-move-down in this-procedure (
              input browse br-table-sel :handle
            , input query br-table-sel :handle
        ).
        apply "entry" to br-table-sel.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-sel-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-sel-all Dialog-Frame
ON CHOOSE OF bt-sel-sel-all IN FRAME Dialog-Frame /* + */
DO:
    for each buf_init_temp_oxmltd_sel
    :
        assign
            buf_init_temp_oxmltd_sel.sel = yes
        .
    end.
    br-table-sel :refresh().
    apply "entry" to br-table-sel.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-select-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-select-type Dialog-Frame
ON CHOOSE OF bt-select-type IN FRAME Dialog-Frame /* <--- */
or mouse-select-dblclick of br-table-not-sel in frame dialog-frame
DO:
    if p-mode = 1
    then do:
        run oxmltd-select in this-procedure (
            input ( if available buf_init_temp_oxmltd_not_sel then buf_init_temp_oxmltd_not_sel.id else 0 )
        ) no-error.
        if error-status :error
        then do:
            message
                        vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка выбора типа данных для экспорта."
                skip return-value
                skip trim(error-status :get-message(1))
                        trim(error-status :get-message(2))
                        trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return no-apply .
        end.
        {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
        apply "entry" to br-table-sel.
    end.        /* if p-mode = 1 */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-table-not-sel
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
    run ui-disable-all in this-procedure.
    run ui-enable in this-procedure.
    apply "value-changed" to br-table-sel.
    apply "entry" to br-table-sel.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE assign-export-table Dialog-Frame
PROCEDURE assign-export-table :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define buffer buf_esys-datatype-exp     for ub.esys-datatype-exp.
    define buffer buf_temp_oxmltd_sel      for temp_oxmltd_sel.
do
for buf_esys-datatype-exp
  , buf_temp_oxmltd_sel
on error undo, return error
:
    for each buf_esys-datatype-exp exclusive-lock
       where buf_esys-datatype-exp.esys-id = p-esys-id
         and buf_esys-datatype-exp.db-num  = p-db-num
    :
        find first buf_temp_oxmltd_sel
             where buf_temp_oxmltd_sel.id = buf_esys-datatype-exp.dte-id
        no-error.
        if not available buf_temp_oxmltd_sel
        then do:
            delete buf_esys-datatype-exp.
        end.
    end.
    for each buf_temp_oxmltd_sel
    :
        find first buf_esys-datatype-exp exclusive-lock
             where buf_esys-datatype-exp.esys-id = p-esys-id
               and buf_esys-datatype-exp.db-num  = p-db-num
               and buf_esys-datatype-exp.dte-id  = buf_temp_oxmltd_sel.id
        no-error.
        if not available buf_esys-datatype-exp
        then do:
            create buf_esys-datatype-exp.
            assign
                buf_esys-datatype-exp.esys-id = p-esys-id
                buf_esys-datatype-exp.db-num  = p-db-num
                buf_esys-datatype-exp.dte-id  = buf_temp_oxmltd_sel.id
            .
        end.
    end.
end.
END PROCEDURE. /* assign-export-table */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE assign-import-table Dialog-Frame
PROCEDURE assign-import-table :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define buffer buf_esys-datatype-imp     for ub.esys-datatype-imp.
    define buffer buf_temp_oxmltd_sel      for temp_oxmltd_sel.
do
for buf_esys-datatype-imp
  , buf_temp_oxmltd_sel
on error undo, return error
:
    for each buf_esys-datatype-imp exclusive-lock
       where buf_esys-datatype-imp.esys-id = p-esys-id
         and buf_esys-datatype-imp.db-num  = p-db-num
    :
        find first buf_temp_oxmltd_sel
             where buf_temp_oxmltd_sel.id = buf_esys-datatype-imp.tdi-id
        no-error.
        if not available buf_temp_oxmltd_sel
        then do:
            delete buf_esys-datatype-imp.
        end.
    end.
    for each buf_temp_oxmltd_sel
    :
        find first buf_esys-datatype-imp exclusive-lock
             where buf_esys-datatype-imp.esys-id = p-esys-id
               and buf_esys-datatype-imp.db-num  = p-db-num
               and buf_esys-datatype-imp.tdi-id  = buf_temp_oxmltd_sel.id
        no-error.
        if not available buf_esys-datatype-imp
        then do:
            create buf_esys-datatype-imp.
            assign
                buf_esys-datatype-imp.esys-id = p-esys-id
                buf_esys-datatype-imp.db-num  = p-db-num
                buf_esys-datatype-imp.tdi-id  = buf_temp_oxmltd_sel.id
            .
        end.
    end.
end.
END PROCEDURE. /* assign-import-table */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE change-properties Dialog-Frame
PROCEDURE change-properties :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-id     as integer          no-undo.

do
on error undo, return error
:

end.
END PROCEDURE. /* change-properties */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-data Dialog-Frame
PROCEDURE check-data :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:

end.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disp-desc-not-sel Dialog-Frame
PROCEDURE disp-desc-not-sel :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-id     as integer          no-undo.

    define buffer buf_datatype-exp     for ub.datatype-exp.
    define buffer buf_datatype-imp     for ub.datatype-imp.
do
for buf_datatype-exp
  , buf_datatype-imp
with frame {&frame-name}
on error undo, return error
:
    case p-impexp-type
    :
        when {&openxml-import}
        then do:
            find first buf_datatype-imp no-lock
                 where buf_datatype-imp.dti-id = p-id
            no-error.
            if available buf_datatype-imp
            then do:
                assign
                    ed-desc-not-sel :screen-value = buf_datatype-imp.dti-des
                .
            end.
        end.        /* when {&openxml-import} */
        when {&openxml-export}
        then do:
            find first buf_datatype-exp no-lock
                 where buf_datatype-exp.dte-id = p-id
            no-error.
            if available buf_datatype-exp
            then do:
                assign
                    ed-desc-not-sel :screen-value = buf_datatype-exp.dte-des
                .
            end.
        end.        /* when {&openxml-export} */
    end case.       /* case p-impexp-type */
end.
END PROCEDURE. /* disp-desc-not-sel */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disp-desc-sel Dialog-Frame
PROCEDURE disp-desc-sel :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-id     as integer          no-undo.

    define buffer buf_datatype-exp     for ub.datatype-exp.
    define buffer buf_datatype-imp     for ub.datatype-imp.
do
for buf_datatype-exp
  , buf_datatype-imp
with frame {&frame-name}
on error undo, return error
:
    case p-impexp-type
    :
        when {&openxml-import}
        then do:
            find first buf_datatype-imp no-lock
                 where buf_datatype-imp.dti-id = p-id
            no-error.
            if available buf_datatype-imp
            then do:
                assign
                    ed-desc-sel :screen-value = buf_datatype-imp.dti-des
                .
            end.
        end.        /* when {&openxml-import} */
        when {&openxml-export}
        then do:
            find first buf_datatype-exp no-lock
                 where buf_datatype-exp.dte-id = p-id
            no-error.
            if available buf_datatype-exp
            then do:
                assign
                    ed-desc-sel :screen-value = buf_datatype-exp.dte-des
                .
            end.
        end.        /* when {&openxml-export} */
    end case.       /* case p-impexp-type */
end.
END PROCEDURE. /* disp-desc-sel */

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
  DISPLAY ed-desc-sel ed-desc-not-sel
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-cancel b-help bt-sel-properties br-table-sel br-table-not-sel
         bt-select-type bt-deselect-type ed-desc-sel ed-desc-not-sel
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
    run oxmltd-fill in this-procedure (
          input p-impexp-type
        , input p-esys-id
        , input p-db-num
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка заполнения таблиц данных."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-open-query-not-sel Dialog-Frame
PROCEDURE local-open-query-not-sel :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    open query br-table-not-sel
        for each buf_init_temp_oxmltd_not_sel no-lock
    .
end.
END PROCEDURE. /* local-open-query-not-sel */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-open-query-sel Dialog-Frame
PROCEDURE local-open-query-sel :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

    open query br-table-sel
        for each buf_init_temp_oxmltd_sel no-lock
    .

 END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-get-type-name Dialog-Frame
PROCEDURE proc-get-type-name :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-id     as integer          no-undo.
define output parameter p-name  as character        no-undo.

    define buffer buf_datatype-exp     for ub.datatype-exp.
    define buffer buf_datatype-imp     for ub.datatype-imp.
do
for buf_datatype-exp
  , buf_datatype-imp
on error undo, return error
:
    case p-impexp-type
    :
        when {&openxml-import}
        then do:
            find first buf_datatype-imp no-lock
                 where buf_datatype-imp.dti-id = p-id
            no-error.
            if available buf_datatype-imp
            then do:
                assign
                    p-name = buf_datatype-imp.dti-name
                .
            end.
        end.        /* when {&openxml-import} */
        when {&openxml-export}
        then do:
            find first buf_datatype-exp no-lock
                 where buf_datatype-exp.dte-id = p-id
            no-error.
            if available buf_datatype-exp
            then do:
                assign
                    p-name = buf_datatype-exp.dte-name
                .
            end.
        end.        /* when {&openxml-export} */
    end case.       /* case p-impexp-type */
end.
END PROCEDURE. /* proc-get-type-name */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-and-move-down Dialog-Frame
PROCEDURE select-and-move-down :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-browse-handle  as handle           no-undo.
define input parameter p-query-handle   as handle           no-undo.

    define variable v-focused-row       as integer  no-undo.
    define variable v-repositioned-row  as integer  no-undo.
do
with frame {&frame-name}
on error undo, return error
:
        assign
            v-focused-row      = p-browse-handle :focused-row
            v-repositioned-row = p-query-handle  :current-result-row
        .
        p-query-handle :get-next ().
        if p-query-handle :query-off-end = no
        then do:
            if v-focused-row > p-browse-handle :height - 2
            then do:
                assign
                    v-repositioned-row  = v-repositioned-row + 1
                .
            end.
            else do:
                assign
                    v-focused-row       = v-focused-row + 1
                    v-repositioned-row  = v-repositioned-row + 1
                .
            end.
            p-browse-handle :set-repositioned-row( v-focused-row, "ALWAYS").
            p-query-handle  :reposition-to-row( v-repositioned-row ).
        end.
end.
END PROCEDURE. /* select-and-move-down */

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
with frame {&frame-name}
on error undo, return error
:
    disable
        all
        except
            b-exit
            b-help
            br-table-sel
            br-table-not-sel
            bt-sel-properties
    .
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
with frame {&frame-name}
on error undo, return error
:
    if p-mode = 1
    then do:
        enable
            b-cancel
            b-help
            bt-sel-sel
            bt-sel-sel-all
            bt-sel-desel-all
            bt-sel-reverse
            bt-not-sel-sel
            bt-not-sel-desel-all
            bt-not-sel-all
            bt-not-sel-reverse
            ed-desc-not-sel
            ed-desc-sel
            bt-select-type
            bt-deselect-type
        .
    end.
    if p-mode = 0
    then do:
        hide
            b-cancel
        .
        assign
            b-exit :label = "В&ыход"
        .

    end.
end.
END PROCEDURE. /* ui-enable */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-type-name Dialog-Frame
FUNCTION get-type-name RETURNS CHARACTER
  ( input p-id as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
    define variable v-name    as character    no-undo.

  run proc-get-type-name in this-procedure (
      input p-id
    , output v-name
  ).
  RETURN v-name.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
