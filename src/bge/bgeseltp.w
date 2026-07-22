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

Список типов документов - диалог настройки

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Input:

Output:

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter p-what-doc           as character            no-undo.
/*какие типы документов заправшивать trn-doc fin-doc contract  */
define input parameter p-init-doc-type-list as character            no-undo.
define output parameter p-doc-type-list     as character            no-undo.
define output parameter p-cancel            as logical              no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список типов документов - диалог настройки.".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ bge/doctype.i  }
{ bge/fdoctype.i }
{ bge/fbdctype.i }
{ bge/conttype.i }
{ cmp/showinf.i  }

define temp-table temp_doc-type no-undo
    field dtp-key           as integer
    field mark              as character
    field doc-type          as character
    field doc-type-label    as character

    index pi is primary unique
        dtp-key
.
define variable v-types-amount as integer no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp_doc-type

/* Definitions for BROWSE BROWSE-1                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1 temp_doc-type.mark temp_doc-type.doc-type-label
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&Scoped-define QUERY-STRING-BROWSE-1 FOR EACH temp_doc-type SHARE-LOCK     BY temp_doc-type.dtp-key
&Scoped-define OPEN-QUERY-BROWSE-1 OPEN QUERY {&SELF-NAME} FOR EACH temp_doc-type SHARE-LOCK     BY temp_doc-type.dtp-key .
&Scoped-define TABLES-IN-QUERY-BROWSE-1 temp_doc-type
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1 temp_doc-type


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-sel b-mark b-exit b-help BROWSE-1

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU POPUP-MENU-b-mark
       MENU-ITEM m_mark_all     LABEL "Выбрать все"
       MENU-ITEM m_mark_no_one  LABEL "Снять выбор у всех"
       MENU-ITEM m_mark_invert  LABEL "Инвертировать выбор".


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помощ&ь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-sel
     LABEL "В&ыбор"
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-1 FOR
      temp_doc-type SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1 Dialog-Frame _FREEFORM
  QUERY BROWSE-1 SHARE-LOCK NO-WAIT DISPLAY
      temp_doc-type.mark  format "X(1)" column-label "*"
    temp_doc-type.doc-type-label format "X(40)" column-label "Тип операции"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 45.5 BY 20.5.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-sel AT ROW 1.17 COL 2
     b-mark AT ROW 1.17 COL 12
     b-exit AT ROW 1.17 COL 15
     b-help AT ROW 1.17 COL 37.38
     BROWSE-1 AT ROW 2.5 COL 2
     SPACE(0.99) SKIP(0.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список типов документов"
         DEFAULT-BUTTON b-exit.


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
/* BROWSE-TAB BROWSE-1 b-help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-mark:POPUP-MENU IN FRAME Dialog-Frame       = MENU POPUP-MENU-b-mark:HANDLE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1
/* Query rebuild information for BROWSE BROWSE-1
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp_doc-type SHARE-LOCK
    BY temp_doc-type.dtp-key .
     _END_FREEFORM
     _Options          = "SHARE-LOCK"
     _OrdList          = "ub.rcs-destn.name|yes"
     _Query            is OPENED
*/  /* BROWSE BROWSE-1 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Список типов документов */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
DO:
    assign
        p-cancel = yes
    .
    apply "WINDOW-CLOSE" TO FRAME {&FRAME-NAME} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
or insert-mode of browse-1 IN FRAME Dialog-Frame
or mouse-select-click of browse-1 IN FRAME Dialog-Frame
DO:
    run b-mark-press in this-procedure (
        input "b-mark-one":U
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка выбора типа документа."
        skip return-value
        skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        trim(error-status :get-message(4))
        trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    display
        temp_doc-type.mark
    with browse browse-1.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    run assign-for-exit in this-procedure no-error.
    if error-status :error
    then do:
        message vss-workfile vss-revision vss-description
        skip "Не удается присвоить значение списку операций."
        skip return-value
        skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        trim(error-status :get-message(4))
        trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    assign
        p-cancel = no
    .
    apply "WINDOW-CLOSE" TO FRAME {&FRAME-NAME} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_mark_all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_mark_all Dialog-Frame
ON CHOOSE OF MENU-ITEM m_mark_all /* Выбрать все */
or + of browse-1 IN FRAME Dialog-Frame
DO:
    run b-mark-press in this-procedure (
        input "b-mark-all":U
    ) no-error .
    if error-status :error
    then do:
        message
            vss-workfile vss-revision vss-description
            skip "Ошибка выбора типа документа."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    display
        temp_doc-type.mark
    with browse browse-1.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_mark_invert
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_mark_invert Dialog-Frame
ON CHOOSE OF MENU-ITEM m_mark_invert /* Инвертировать выбор */
or * of browse-1 IN FRAME Dialog-Frame
DO:
    run b-mark-press in this-procedure (
        input "b-mark-inverse":U
    )no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка выбора типа документа."
        skip return-value
        skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        trim(error-status :get-message(4))
        trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    display
        temp_doc-type.mark
    with browse browse-1.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_mark_no_one
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_mark_no_one Dialog-Frame
ON CHOOSE OF MENU-ITEM m_mark_no_one /* Снять выбор у всех */
or - of browse-1 IN FRAME Dialog-Frame
DO:
    run b-mark-press in this-procedure (
        input "b-mark-no-one":U
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка выбора типа документа."
        skip return-value
        skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        trim(error-status :get-message(4))
        trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    display
        temp_doc-type.mark
    with browse browse-1.
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
       
/*           run gbl/inidebug.p.*/
       
       
   run init-fields in this-procedure no-error.
   if error-status :error
   then do:
       message
         vss-workfile vss-revision vss-description
         skip "Ошибка заполнения полей формы начальными значениями."
         skip return-value
         skip trim(error-status :get-message(1))
              trim(error-status :get-message(2))
              trim(error-status :get-message(3))
              trim(error-status :get-message(4))
              trim(error-status :get-message(5))
       view-as alert-box error.
       undo, return error .
   end.
  RUN enable_UI.
  apply "entry" to browse-1.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE assign-for-exit Dialog-Frame
PROCEDURE assign-for-exit :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
    p-doc-type-list = ''
.
find first temp_doc-type
     where temp_doc-type.mark <> '{&delim-flt}'
no-error.
if available temp_doc-type
then do:
    for each temp_doc-type
       where temp_doc-type.mark = '{&delim-flt}'
    :

        assign
            p-doc-type-list = p-doc-type-list + ( if p-doc-type-list <> '' then "," else '' ) + temp_doc-type.doc-type
        .
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE b-mark-press Dialog-Frame
PROCEDURE b-mark-press :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-mode as character  no-undo.
define buffer buf_temp_doc-type for temp_doc-type.

do
for buf_temp_doc-type
with frame {&frame-name}
on error undo, return error
:
    define variable v-focused-row       as integer              no-undo.
    define variable v-repositioned-row  as integer              no-undo.

    assign
        v-focused-row      = browse-1 :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "browse-1" )
    .
    case p-mode
    :
        when "b-mark-one":U
        then do:
            if temp_doc-type.mark = '{&delim-flt}'
            then do:        /* снимаем отметку */
                assign
                    temp_doc-type.mark = "":U
                .
            end.
            else do:        /* ставим отметку */
                assign
                    temp_doc-type.mark = '{&delim-flt}'
                .
            end.
        end.
        when "b-mark-all":U
        then do:
            for each buf_temp_doc-type
            :
                assign
                    buf_temp_doc-type.mark = '{&delim-flt}'
                .
            end.
        end.
        when "b-mark-no-one":U
        then do:
            for each buf_temp_doc-type
            :
                assign
                    buf_temp_doc-type.mark = "":U
                .
            end.
        end.
        when "b-mark-inverse":U
        then do:
            for each buf_temp_doc-type
            :
                if buf_temp_doc-type.mark = '{&delim-flt}'
                then do:        /* снимаем отметку */
                    assign
                        buf_temp_doc-type.mark = "":U
                    .
                end.
                else do:        /* ставим отметку */
                    assign
                        buf_temp_doc-type.mark = '{&delim-flt}'
                    .
                end.
            end.
        end.
    end case.
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
    if v-focused-row < v-types-amount
    and last-event :event-type <> "MOUSE":U
    and p-mode = "b-mark-one":U
    then do:
        if v-focused-row > browse-1 :height - 2
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
    end.        /* if v-focused-row < v-types-amount */
    browse-1 :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
    reposition browse-1 to row v-repositioned-row.
end.
END PROCEDURE. /* b-mark-press */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE delete-objects Dialog-Frame
PROCEDURE delete-objects :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-destination_rowid  as character    no-undo.

    define buffer buf_rcs-destn       for ub.rcs-destn.

    find first buf_rcs-destn exclusive-lock
         where buf_rcs-destn.destination_rowid    = p-destination_rowid
    no-error.
    if not available buf_rcs-destn
    then do:
        undo, return error "delete-objects: Не удалось удалить запись." + {&new-line} + return-value.
    end.
    else do:
        delete buf_rcs-destn.
    end.
end.
END PROCEDURE. /* delete-objects */

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
  ENABLE b-sel b-mark b-exit b-help BROWSE-1
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
    define variable v-counter           as integer           no-undo.
    define variable v-oper-num          as integer           no-undo.
    define variable v-what-doc-counter  as integer no-undo .
    define variable v-what-doc-amount   as integer no-undo .

    define buffer buf_temp_doc-type     for temp_doc-type.
        

do
for buf_temp_doc-type
on error undo, return error
:
    assign
        v-oper-num = 0
        v-what-doc-amount = num-entries( p-what-doc )
    .
    do v-what-doc-counter = 1 to v-what-doc-amount
    :
        case entry( v-what-doc-counter, p-what-doc )
        :
            when "trn-doc":U
            then do:
                do
                v-counter = 1 to num-entries( {&TDEDT_List} )
                :
                    create buf_temp_doc-type.
                    assign
                        buf_temp_doc-type.dtp-key           = ( v-what-doc-counter - 1) * v-what-doc-amount + v-counter
                        buf_temp_doc-type.doc-type          = entry( v-counter, {&TDEDT_List} )
                        buf_temp_doc-type.doc-type-label    = entry( v-counter, {&TDEDT_List-full} )
                    .
                    if p-init-doc-type-list = "":U
                    or lookup( buf_temp_doc-type.doc-type, p-init-doc-type-list ) <> 0
                    then do:
                        assign
                            buf_temp_doc-type.mark              = '{&delim-flt}'
                        .
                    end.
                    else do:
                        assign
                            buf_temp_doc-type.mark              = "":U
                        .
                    end.
                end.
                assign
                    p-doc-type-list = p-init-doc-type-list
                    v-oper-num      = v-oper-num + v-counter
                .
            end.
            when "fin-doc":U
            then do:
                create-doc-type-list:
                do
                v-counter = 1 to num-entries( {&fin-ext-doc-types} )
                :
                    if entry( v-counter, {&fin-ext-doc-types} ) = "":U
                    then do:
                        next create-doc-type-list.
                    end.
                    create buf_temp_doc-type.
                    assign
                        buf_temp_doc-type.dtp-key           = 100 *  ( v-what-doc-counter - 1) * v-what-doc-amount + v-counter
                        buf_temp_doc-type.doc-type          = entry( v-counter, {&fin-ext-doc-types} )
                        buf_temp_doc-type.doc-type-label    = entry( v-counter, {&fin-ext-doc-types-full} )
                    .
                    if p-init-doc-type-list = "":U
                    or lookup( buf_temp_doc-type.doc-type, p-init-doc-type-list ) <> 0
                    then do:
                        assign
                            buf_temp_doc-type.mark              = '{&delim-flt}'
                        .
                    end.
                    else do:
                        assign
                            buf_temp_doc-type.mark              = "":U
                        .
                    end.
                end.
                assign
                    p-doc-type-list = p-init-doc-type-list
                    v-oper-num      = v-oper-num + v-counter - 1
                .
            end.
            when "fin-doc-bank":U
            then do:
                do
                v-counter = 1 to {&fdoctype-bank-types-amount}
                :
                    create buf_temp_doc-type.
                    assign
                        buf_temp_doc-type.dtp-key           = 200 * ( v-what-doc-counter - 1) * v-what-doc-amount + v-counter
                        buf_temp_doc-type.doc-type-label    = v-fdoctype-bank-type-list[ v-counter * 3 - 2 ]
                        buf_temp_doc-type.doc-type          = v-fdoctype-bank-type-list[ v-counter * 3 - 1 ]
                    .
                    if p-init-doc-type-list = "":U
                    or lookup( v-fdoctype-bank-type-list[ v-counter * 3 - 1 ], p-init-doc-type-list ) <> 0
                    then do:
                        assign
                            buf_temp_doc-type.mark              = '{&delim-flt}'
                        .
                    end.
                    else do:
                        assign
                            buf_temp_doc-type.mark              = "":U
                        .
                    end.
                end.
                assign
                    p-doc-type-list = p-init-doc-type-list
                    v-oper-num      = v-oper-num + v-counter
                .
            end.
            when "contract":U
            then do:
                do
                v-counter = 1 to {&conttype-types-amount}
                :
                create buf_temp_doc-type.
                assign
                    buf_temp_doc-type.dtp-key           = 300 * ( v-what-doc-counter - 1) * v-what-doc-amount + v-counter
                    buf_temp_doc-type.doc-type-label    = v-conttype-type-list[ v-counter * 2 - 1 ]
                    buf_temp_doc-type.doc-type          = v-conttype-type-list[ v-counter * 2 ]
                .
                if p-init-doc-type-list = "":U
                or lookup( v-conttype-type-list[ v-counter * 2 ], p-init-doc-type-list ) <> 0
                then do:
                    assign
                        buf_temp_doc-type.mark = '{&delim-flt}'
                    .
                end.
                else do:
                    assign
                        buf_temp_doc-type.mark = "":U
                    .
                end.
                end.
                assign
                    p-doc-type-list = p-init-doc-type-list
                    v-oper-num      = v-oper-num + v-counter
                .
            end.
        end case.
    end. /*do v-what-doc-counter */
    assign
        v-types-amount = v-oper-num
    .
end.
END PROCEDURE. /* init-fields */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME