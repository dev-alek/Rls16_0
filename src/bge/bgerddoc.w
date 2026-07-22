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

Просмотр документов, экспортированных в каталог

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Input:
    p-format-type - формат:
        'tree' - дерево, 'flat' или любое другое значение - плоский.
    p-export-type - тип экспорта:
        'DOC' - документы.
Output:

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-format-type        as character        no-undo.
define input parameter p-export-type        as character        no-undo.
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр документов, экспортированных в каталог".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/xmlparse.i }
{ bge/xmlview.i  }
{ bge/xmlvdoc.i  }
{ gbl/filelist.i }
{ cmp/showinf.i  }

define variable v-bgerddoc-last-record-id    as integer      no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-table

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp_xmlview

/* Definitions for BROWSE br-table                                      */
&Scoped-define FIELDS-IN-QUERY-br-table temp_xmlview.record-id temp_xmlview.filename temp_xmlview.doc-code temp_xmlview.ext-doc-type temp_xmlview.doc-date temp_xmlview.fact-date temp_xmlview.doc-sum temp_xmlview.ps
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-table
&Scoped-define FIELD-PAIRS-IN-QUERY-br-table
&Scoped-define SELF-NAME br-table
&Scoped-define OPEN-QUERY-br-table OPEN QUERY {&SELF-NAME} FOR EACH temp_xmlview NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-table temp_xmlview
&Scoped-define FIRST-TABLE-IN-QUERY-br-table temp_xmlview


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-table}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit bt-read b-help bt-change-cat ~
fi-search-string b-search br-table
&Scoped-Define DISPLAYED-OBJECTS fi-catalog fi-search-string

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

DEFINE BUTTON b-search
     LABEL "Найти"
     SIZE 10 BY 1.

DEFINE BUTTON bt-change-cat
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON bt-read
     LABEL "&Чтение"
     SIZE 10 BY 1.

DEFINE VARIABLE fi-catalog AS CHARACTER FORMAT "X(256)":U
     LABEL "Каталог с файлами XML"
     VIEW-AS FILL-IN
     SIZE 63.75 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-search-string AS CHARACTER FORMAT "X(256)":U
     LABEL "Пои&ск по номеру"
     VIEW-AS FILL-IN
     SIZE 15.75 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-table FOR
      temp_xmlview SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-table Dialog-Frame _FREEFORM
  QUERY br-table DISPLAY
      temp_xmlview.record-id column-label "N п/п" format ">>>>9"
    temp_xmlview.filename column-label "Файл"  format "X(8)"
    temp_xmlview.doc-code  column-label "Номер док-та"  format "X(14)"
    temp_xmlview.ext-doc-type  column-label "Тип" format "X(3)"
    temp_xmlview.doc-date  column-label "Дата" format "99/99/9999"
    temp_xmlview.fact-date  column-label "Дата факт" format "99/99/9999"
    temp_xmlview.doc-sum  column-label "Сумма " format "->>>,>>>,>>>,>>9.99 "
    temp_xmlview.ps  column-label "Примечание" format "X(60)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.75 BY 18.75.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 2
     bt-read AT ROW 1 COL 12
     b-help AT ROW 1 COL 89.38
     fi-catalog AT ROW 2.17 COL 23 COLON-ALIGNED
     bt-change-cat AT ROW 2.25 COL 89.38
     fi-search-string AT ROW 3.42 COL 16.75 COLON-ALIGNED
     b-search AT ROW 3.42 COL 34.75
     br-table AT ROW 4.67 COL 1.63
     SPACE(0.49) SKIP(0.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Просмотр выгрузки XML".


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
/* BROWSE-TAB br-table b-search Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN fi-catalog IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-table
/* Query rebuild information for BROWSE br-table
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp_xmlview NO-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-table */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Просмотр выгрузки XML */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
DO:
    apply "WINDOW-CLOSE" TO FRAME {&FRAME-NAME} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-search
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-search Dialog-Frame
ON CHOOSE OF b-search IN FRAME Dialog-Frame /* Найти */
DO:
    define variable v-found             as logical      no-undo.
    define variable v-founded-recid     as recid        no-undo.
    define variable v-focused-row       as integer      no-undo.

    assign
        fi-search-string
    .
    assign
        v-focused-row      = br-table :focused-row in frame {&FRAME-NAME}.
    .
    run search-doc-num in this-procedure (
          input fi-search-string
        , output v-founded-recid
        , output v-found
    ).
    if v-found = yes
    then do:
        br-table :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame {&FRAME-NAME} no-error.
        reposition br-table to recid v-founded-recid.
    end.
    else do:
        message
            "Запись не найдена."
        view-as alert-box information.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-change-cat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-change-cat Dialog-Frame
ON CHOOSE OF bt-change-cat IN FRAME Dialog-Frame /* Изменить */
DO:
    define variable v-full-dir-name     as character    no-undo.
    define variable v-dir-type          as character    no-undo.
    define variable v-can-write         as logical      no-undo.
    run gbl/dir-sel.p (
          output fi-catalog
        , output v-dir-type
        , output v-can-write
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка выбора каталога."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    display
        fi-catalog
    with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-read
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-read Dialog-Frame
ON CHOOSE OF bt-read IN FRAME Dialog-Frame /* Чтение */
DO:
    define variable v-yesno    as logical      no-undo.
    message
        "Процедура чтения файлов из каталога"
        skip "может занять много времени."
        skip(1)
        skip "Прочитать файлы?"
    view-as alert-box question
    buttons ok-cancel
    update v-yesno.
    if v-yesno = no
    then do:
        undo, return no-apply.
    end.
    { gbl/working.i }
    if fi-catalog :screen-value <> "":U
    then do:
        run read-files in this-procedure (
            input fi-catalog :screen-value
        ).
    end.
    message
        "Чтение файлов каталога завершено."
    view-as alert-box information.
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
    { gbl/stopwork.i }
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-search-string
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-search-string Dialog-Frame
ON LEAVE OF fi-search-string IN FRAME Dialog-Frame /* Поиск по номеру */
DO:
    assign
        v-bgerddoc-last-record-id = 0
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-table
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

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-file-type Dialog-Frame
PROCEDURE check-file-type :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-filename       as character        no-undo.
define input parameter p-full-filename  as character        no-undo.
define output parameter p-is-this-type  as logical          no-undo.

do
on error undo, return error
:
    case p-export-type
    :
        when "DOC":U
        then do:
            if substring( p-filename, 1, 1 ) = "d":U
            then do:
                assign
                    p-is-this-type = yes
                .
            end.
            else do:
                assign
                    p-is-this-type = no
                .
            end.
        end.        /* when "DOC":U */
        otherwise do:
            assign
                p-is-this-type = no
            .
        end.        /* otherwise */
    end case.       /* case p-export-type */
end.
END PROCEDURE. /* check-file-type */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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
  DISPLAY fi-catalog fi-search-string
      WITH FRAME Dialog-Frame.
  ENABLE b-exit bt-read b-help bt-change-cat fi-search-string b-search br-table
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-init-catalog Dialog-Frame
PROCEDURE get-init-catalog :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-catalog   as character        no-undo.

do
on error undo, return error
:
    case p-format-type
    :
        when 'tree':U
        then do:
            case p-export-type
            :
                when 'DOC':U
                then do:
                    get-key-value section "BGE" key "Dirfrg-acc" value p-catalog.
                    if p-catalog = ?
                    then do:            /* нет ключа */
                        message
                        skip "Не найден параметр ini-файла, определяющий каталог экспорта."
                        skip(1)
                        skip "Обратитесь к администратору."
                        view-as alert-box error.
                        undo, return error .
                    end.
                    else do:
                        assign
                            p-catalog = p-catalog + "\":U + "exp-acc":U
                        .
                    end.
                end.        /* when 'DOC':U */
                otherwise do:
                    message
                             vss-workfile vss-revision vss-description
                        skip(1)
                        skip "Не определено чтение файлов выгрузки"
                        skip "с типом экспорта" p-export-type
                        skip return-value
                        skip trim(error-status :get-message(1))
                             trim(error-status :get-message(2))
                             trim(error-status :get-message(3))
                    view-as alert-box error.
                    undo, return error .
                end.        /* otherwise */
            end case.       /* case p-export-type */
        end.        /* when 'tree':U */
        when 'flat':U
        then do:
            case p-export-type
            :
                when 'DOC':U
                then do:
                    get-key-value section "BGE" key "outdir" value p-catalog.
                    if p-catalog = ?
                    then do:            /* нет ключа */
                        message
                        skip "Не найден параметр ini-файла, определяющий каталог экспорта."
                        skip(1)
                        skip "Обратитесь к администратору."
                        view-as alert-box error.
                        undo, return error .
                    end.
                end.        /* when 'DOC':U */
                otherwise do:
                    message
                             vss-workfile vss-revision vss-description
                        skip(1)
                        skip "Не определено чтение файлов выгрузки"
                        skip "с типом экспорта" p-export-type
                        skip return-value
                        skip trim(error-status :get-message(1))
                             trim(error-status :get-message(2))
                             trim(error-status :get-message(3))
                    view-as alert-box error.
                    undo, return error .
                end.        /* otherwise */
            end case.       /* case p-export-type */
        end.        /* when 'flat':U */
        otherwise do:
            message
                     vss-workfile vss-revision vss-description
                skip(1)
                skip "Неправильно указан формат экспорта."
                skip "Невозможно определить каталог выгрузки."
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.        /* otherwise */
    end case.       /* case p-format-type */
end.
END PROCEDURE. /* get-init-catalog */

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
        frame {&frame-name} :title = substitute( "&1. Формат выгрузки: &2. Тип документов: &3"
                                                , frame {&frame-name} :title
                                                , ( if p-format-type = 'flat':U then "плоский" else "дерево" )
                                                , "складские документы"
                                     )
    .
    assign
        v-xmlview-format-type = p-format-type
        v-xmlview-export-type = p-export-type
    .
    run get-init-catalog in this-procedure (
        output fi-catalog
    ) no-error.
    if error-status :error
    then do:
        message
                 "Не удалось определить каталог выгрузки."
            skip "Выберите каталог для чтения файлов."
        view-as alert-box warning.
        assign
            fi-catalog = "":U
        .
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE read-files Dialog-Frame
PROCEDURE read-files :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-full-path  as character        no-undo.

    define variable v-is-this-type  as logical      no-undo.
    define variable v-short-name    as character    no-undo.

    define buffer buf_temp-filelist     for temp-filelist.
do
for buf_temp-filelist
on error undo, return error
:
    assign
        v-short-name = entry( num-entries( p-full-path, "\":U ), p-full-path, "\":U )
    .
    run filelist-clear in this-procedure .
    run filelist-init in this-procedure (
          input p-full-path
        , input yes
        , input "xml":U
        , input v-short-name
    ).
    filelist-parse:
    for each buf_temp-filelist
    :
        run check-file-type in this-procedure (
              input buf_temp-filelist.file-name
            , input buf_temp-filelist.full-name
            , output v-is-this-type
        ).
        if v-is-this-type = yes
        then do:
            assign
                v-xmlvdoc-current-tag-path = p-full-path
            .
            run xmlvdoc-parse-file in this-procedure (
                  input buf_temp-filelist.file-name-no-ext
                , input buf_temp-filelist.full-name
            ) no-error.
            if error-status :error
            then do:
                message
                        vss-workfile vss-revision vss-description
                    skip(1)
                    skip "Ошибка чтения файла" buf_temp-filelist.full-name
                    skip return-value
                    skip trim(error-status :get-message(1))
                         trim(error-status :get-message(2))
                         trim(error-status :get-message(3))
                view-as alert-box error.
                undo filelist-parse, next filelist-parse.
            end.
        end.        /* if v-is-this-type = yes */
    end.        /* for each buf_temp-filelist */
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE search-doc-num Dialog-Frame
PROCEDURE search-doc-num :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-search-string      as character        no-undo.
define output parameter p-founded-recid     as recid            no-undo.
define output parameter p-found             as logical          no-undo.

    define buffer buf_temp_xmlview      for temp_xmlview.
do
on error undo, return error
:
    find first buf_temp_xmlview
         where buf_temp_xmlview.record-id > v-bgerddoc-last-record-id
           and buf_temp_xmlview.doc-code begins p-search-string
    no-error.
    if available buf_temp_xmlview
    then do:
        assign
            p-found                     = yes
            v-bgerddoc-last-record-id   = buf_temp_xmlview.record-id
            p-founded-recid             = recid( buf_temp_xmlview )
        .
    end.
    else do:
        assign
            p-found                     = no
            p-founded-recid             = 0
        .
    end.
end.
END PROCEDURE. /* search-doc-num */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cb-xmlparse-error {&FRAME-NAME}
PROCEDURE cb-xmlparse-error :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-error-string   as character        no-undo.

do
on error undo, return error
:
    message
        "Ошибка чтения xml-файла."
        skip p-error-string
    view-as alert-box error.
end.
END PROCEDURE. /* cb-xmlparse-error */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME