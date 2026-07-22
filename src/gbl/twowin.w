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

Двухоконный интерфейс для выбора из небольшого количества записей

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:
    p-mainmenu-handle as widget-handle  - handle главного окна
    p-mode            as integer        - режим вызова:
                                            0 - доступна только кнопка Выход
                                            1 - возможно редактирование
    p-title              as character   - заголовок окна
    p-runfilename        as character   - процедура для вызова по кнопке свойств (если "":U, то кнопка не видна)
                                          при выборе этой процедуре будут переданы:
                                            1. handle mainmenu.
                                            2. Код записи, определённый первым параметром процедуры twowin_add-item.
    p-runfilelabel       as character   - label для кнопки свойств
    table for temp_twowin_items         - заполненная таблица параметров для выбора (поле Selected - для правого окна)

Output:
    table for temp_twowin_itemsSelected        - таблица с кодами выбранных параметров
    p-accepted   as logical             - yes, если изменения приняты и были изменения в выборе


Пример:

    { gbl/twowin.i      }
    run twowin_clear in this-procedure.
    run twowin_add-item in this-procedure ( input "first-key",  input "Первая строка", input "Коммент1", input no ).
    run twowin_add-item in this-procedure ( input "second-key", input "Вторая строка", input "Коммент2", input no ).
    run twowin_add-item in this-procedure ( input "third-key",  input "Третья строка", input "Коммент3", input yes ).
    define variable v-accepted as logical    no-undo.
    run gbl/twowin.w (
          input p-mainmenu-handle
        , input 1
        , input "Пробный выбор":U
        , input "test.p":U
        , input "&Тест"
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected
        , output v-accepted
    ).
    define variable v-str as character  no-undo.
    for each temp_twowin_itemsSelected
    :
        assign
            v-str = substitute( "&1&2&3 (&4)"
                                , v-str
                                , ( if v-str = "":U then "":U else ",":U )
                                , temp_twowin_itemsSelected.itm-key
                                , temp_twowin_itemsSelected.itmExtKey
                                )
        .
    end.
    message
        v-accepted
        skip v-str
    view-as alert-box.

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

{ gbl/twowin.i      }

/* Parameters Definitions ---                                           */
define input parameter p-mainmenu-handle    as widget-handle    no-undo.
define input parameter p-mode               as integer          no-undo.
define input parameter p-title              as character        no-undo.
define input parameter p-runfilename        as character        no-undo.
define input parameter p-runfilelabel       as character        no-undo.
define input parameter table for temp_twowin_items .
define output parameter table for temp_twowin_itemsSelected .
define output parameter p-changed           as logical          no-undo.
define output parameter p-accepted          as logical          no-undo.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Двухоконный интерфейс для выбора из небольшого количества записей".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ gbl/color.i       }
{ cmp/showinf.i     }

    define variable v-twowin-close-enabled    as logical      no-undo.

    define buffer buf_right_temp_twowin_items             for temp_twowin_items.
    define buffer buf_left_temp_twowin_items              for temp_twowin_items.
    define buffer buf_temp_twowin_itemsSelected           for temp_twowin_itemsSelected.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-table-left

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_left_temp_twowin_items ~
buf_right_temp_twowin_items

/* Definitions for BROWSE br-table-left                                 */
&Scoped-define FIELDS-IN-QUERY-br-table-left buf_left_temp_twowin_items.selLeft buf_left_temp_twowin_items.itmName
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-table-left
&Scoped-define SELF-NAME br-table-left
&Scoped-define OPEN-QUERY-br-table-left /* OPEN QUERY {&SELF-NAME} FOR EACH buf_left_temp_twowin_items no-lock . */ run local-open-query-left in this-procedure .
&Scoped-define TABLES-IN-QUERY-br-table-left buf_left_temp_twowin_items
&Scoped-define FIRST-TABLE-IN-QUERY-br-table-left buf_left_temp_twowin_items


/* Definitions for BROWSE br-table-right                                */
&Scoped-define FIELDS-IN-QUERY-br-table-right buf_right_temp_twowin_items.selRight buf_right_temp_twowin_items.itmName
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-table-right
&Scoped-define SELF-NAME br-table-right
&Scoped-define OPEN-QUERY-br-table-right /* OPEN QUERY {&SELF-NAME} FOR EACH buf_right_temp_twowin_items no-lock. */ run local-open-query-right in this-procedure .
&Scoped-define TABLES-IN-QUERY-br-table-right buf_right_temp_twowin_items
&Scoped-define FIRST-TABLE-IN-QUERY-br-table-right buf_right_temp_twowin_items


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-table-left}~
    ~{&OPEN-QUERY-br-table-right}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-cancel bt-filter tb-filter b-help ~
bt-properties br-table-right br-table-left bt-select-type bt-deselect-type ~
ed-desc-not-sel ed-desc-sel
&Scoped-Define DISPLAYED-OBJECTS fi-filter tb-filter ed-desc-not-sel ~
ed-desc-sel

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
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помощ&ь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON bt-deselect-type
     LABEL "<--"
     SIZE 4.13 BY 1.

DEFINE BUTTON bt-filter DEFAULT
     LABEL "&ФПоиск"
     SIZE 10 BY 1 TOOLTIP "Поиск с фильтром строки во всех текстовых полях"
     BGCOLOR 8 .

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
     SIZE 3 BY 1 TOOLTIP "Выбрать".

DEFINE BUTTON bt-properties DEFAULT
     LABEL "&Свойства"
     SIZE 15 BY 1
     BGCOLOR 8 .

DEFINE BUTTON bt-sel-desel-all
     LABEL "-"
     SIZE 3 BY 1 TOOLTIP "Отменить выбор".

DEFINE BUTTON bt-sel-reverse
     LABEL "/"
     SIZE 3 BY 1 TOOLTIP "Инвертировать выбор".

DEFINE BUTTON bt-sel-sel
     LABEL "*"
     SIZE 3 BY 1 TOOLTIP "Выбрать".

DEFINE BUTTON bt-sel-sel-all
     LABEL "+"
     SIZE 3 BY 1 TOOLTIP "Выбрать все".

DEFINE BUTTON bt-select-type
     LABEL "-->"
     SIZE 4.13 BY 1.

DEFINE VARIABLE ed-desc-not-sel AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 45.5 BY 1.63
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE ed-desc-sel AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 45.63 BY 1.63
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-filter AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 20.75 BY 1 NO-UNDO.

DEFINE VARIABLE tb-filter AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.63 BY .79 TOOLTIP "Снятие поиска с фильтром" NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-table-left FOR
      buf_left_temp_twowin_items SCROLLING.

DEFINE QUERY br-table-right FOR
      buf_right_temp_twowin_items SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-table-left
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-table-left Dialog-Frame _FREEFORM
  QUERY br-table-left NO-LOCK DISPLAY
      buf_left_temp_twowin_items.selLeft  column-label " *" format " */  "
      buf_left_temp_twowin_items.itmName column-label " Выбрано" format "X(40)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 45.5 BY 18.5 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.

DEFINE BROWSE br-table-right
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-table-right Dialog-Frame _FREEFORM
  QUERY br-table-right NO-LOCK DISPLAY
      buf_right_temp_twowin_items.selRight column-label " *" format " */  "
      buf_right_temp_twowin_items.itmName column-label " Доступно" format "X(40)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 45.5 BY 18.5 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 2 NO-TAB-STOP
     b-cancel AT ROW 1 COL 12 NO-TAB-STOP
     bt-filter AT ROW 1 COL 22 NO-TAB-STOP
     fi-filter AT ROW 1 COL 30.25 COLON-ALIGNED NO-LABEL
     tb-filter AT ROW 1 COL 54
     b-help AT ROW 1 COL 89 NO-TAB-STOP
     bt-not-sel-sel AT ROW 2.25 COL 2 NO-TAB-STOP
     bt-not-sel-all AT ROW 2.25 COL 5 NO-TAB-STOP
     bt-not-sel-desel-all AT ROW 2.25 COL 8 NO-TAB-STOP
     bt-not-sel-reverse AT ROW 2.25 COL 11 NO-TAB-STOP
     bt-properties AT ROW 2.25 COL 32.5 NO-TAB-STOP
     bt-sel-sel AT ROW 2.25 COL 53 NO-TAB-STOP
     bt-sel-sel-all AT ROW 2.25 COL 56 NO-TAB-STOP
     bt-sel-desel-all AT ROW 2.25 COL 59 NO-TAB-STOP
     bt-sel-reverse AT ROW 2.25 COL 62 NO-TAB-STOP
     br-table-right AT ROW 3.25 COL 2
     br-table-left AT ROW 3.25 COL 53
     bt-select-type AT ROW 10.5 COL 48 NO-TAB-STOP
     bt-deselect-type AT ROW 11.5 COL 48 NO-TAB-STOP
     ed-desc-not-sel AT ROW 22 COL 2 NO-LABEL NO-TAB-STOP
     ed-desc-sel AT ROW 22 COL 53 NO-LABEL NO-TAB-STOP
     SPACE(0.99) SKIP(0.11)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выбор из списка"
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
   FRAME-NAME                                                           */
/* BROWSE-TAB br-table-right bt-sel-reverse Dialog-Frame */
/* BROWSE-TAB br-table-left br-table-right Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       bt-filter:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON bt-not-sel-all IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON bt-not-sel-desel-all IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON bt-not-sel-reverse IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON bt-not-sel-sel IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       bt-properties:HIDDEN IN FRAME Dialog-Frame           = TRUE.

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

/* SETTINGS FOR FILL-IN fi-filter IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       fi-filter:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-table-left
/* Query rebuild information for BROWSE br-table-left
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH buf_left_temp_twowin_items no-lock . */
run local-open-query-left in this-procedure .
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* BROWSE br-table-left */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-table-right
/* Query rebuild information for BROWSE br-table-right
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH buf_right_temp_twowin_items no-lock. */
run local-open-query-right in this-procedure .
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* BROWSE br-table-right */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Выбор из списка */
DO:
    if v-twowin-close-enabled = no
    then do:
        undo, return no-apply.
    end.
    else do:
        run check-data in this-procedure.
        run assign-export-table in this-procedure (
              output p-changed
        ).
        assign
            p-accepted = yes
        .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Выбор из списка */
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
        v-twowin-close-enabled  = yes
        p-accepted              = no
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
or F2 of frame {&frame-name} anywhere
DO:
    { gbl/stdbtn.i }
    assign
        v-twowin-close-enabled = yes
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-table-left
&Scoped-define SELF-NAME br-table-left
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table-left Dialog-Frame
ON MOUSE-SELECT-CLICK OF br-table-left IN FRAME Dialog-Frame
or insert-mode of br-table-left in frame dialog-frame
or " " of br-table-left in frame dialog-frame
DO:
    if p-mode = 1
    then do:
        if available buf_left_temp_twowin_items
        and buf_left_temp_twowin_items.itmSelected = yes
        then do:
            assign
                buf_left_temp_twowin_items.selLeft = not( buf_left_temp_twowin_items.selLeft )
            .
            display
                selLeft
            with browse br-table-left .
            apply "entry" to br-table-left.
        end.
    end.        /* if p-mode = 1 */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table-left Dialog-Frame
ON VALUE-CHANGED OF br-table-left IN FRAME Dialog-Frame
or entry of br-table-left IN FRAME Dialog-Frame
or entry of br-table-right IN FRAME Dialog-Frame
or value-changed of br-table-right IN FRAME Dialog-Frame
DO:
    if available buf_left_temp_twowin_items
    then do:
        assign
            ed-desc-sel = buf_left_temp_twowin_items.itmDesc
        .
    end.
    else do:
        assign
            ed-desc-sel = "":U
        .
    end.
    if available buf_right_temp_twowin_items
    then do:
        assign
            ed-desc-not-sel = buf_right_temp_twowin_items.itmDesc
        .
    end.
    else do:
        assign
            ed-desc-not-sel = "":U
        .
    end.
    display
        ed-desc-sel
        ed-desc-not-sel
    with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-table-right
&Scoped-define SELF-NAME br-table-right
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table-right Dialog-Frame
ON MOUSE-SELECT-CLICK OF br-table-right IN FRAME Dialog-Frame
or insert-mode of br-table-right in frame dialog-frame
or " " of br-table-right in frame dialog-frame
DO:
    if p-mode = 1
    then do:
        if available buf_right_temp_twowin_items
        and buf_right_temp_twowin_items.itmSelected = no
        then do:
            assign
                buf_right_temp_twowin_items.selRight = not( buf_right_temp_twowin_items.selRight )
            .
            display
                selRight
            with browse br-table-right .
            apply "entry" to br-table-right.
        end.
    end.        /* if p-mode = 1 */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table-right Dialog-Frame
ON ROW-DISPLAY OF br-table-right IN FRAME Dialog-Frame
DO:
    if buf_right_temp_twowin_items.itmSelected = yes
    then do:
        assign
            buf_right_temp_twowin_items.itmName :bgcolor in browse br-table-right = GRAY_COLOR
            buf_right_temp_twowin_items.selRight :bgcolor in browse br-table-right = GRAY_COLOR
        .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-deselect-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-deselect-type Dialog-Frame
ON CHOOSE OF bt-deselect-type IN FRAME Dialog-Frame /* <-- */
/*or mouse-select-dblclick of br-table-left in frame dialog-frame*/
or return of br-table-left in frame dialog-frame
DO:
    if p-mode = 1
    then do:
        for each buf_left_temp_twowin_items
           where buf_left_temp_twowin_items.selLeft = yes
        :
            assign
                buf_left_temp_twowin_items.itmSelected = no
                buf_left_temp_twowin_items.selLeft     = no
            .
        end.
        {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
        if available buf_left_temp_twowin_items
        then do:
            apply "entry" to br-table-left.
        end.
        else do:
            apply "entry" to br-table-right.
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-filter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-filter Dialog-Frame
ON CHOOSE OF bt-filter IN FRAME Dialog-Frame /* ФПоиск */
DO:
    define variable v-new-filter    as character    no-undo.
    define variable v-accepted      as logical      no-undo.
    run gbl/twowinf.w (
          input fi-filter
        , output v-new-filter
        , output v-accepted
    ).
    if v-accepted = yes
    then do:
        assign
            fi-filter = v-new-filter
        .
        if fi-filter = "":U
        then do:
            assign
                tb-filter               = no
                tb-filter :sensitive    = no
            .
        end.
        else do:
            assign
                tb-filter               = yes
                tb-filter :sensitive    = yes
            .
        end.
        display
            fi-filter
            tb-filter
        with frame {&frame-name}.
        {&OPEN-QUERY-br-table-right}
        apply "entry":U to br-table-right.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-not-sel-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-not-sel-all Dialog-Frame
ON CHOOSE OF bt-not-sel-all IN FRAME Dialog-Frame /* + */
DO:
    define variable v-changed    as integer      no-undo.
    if fi-filter = "":U
    or tb-filter = no
    then do:
        for each buf_right_temp_twowin_items
           where buf_right_temp_twowin_items.itmSelected = no
        :
            assign
                buf_right_temp_twowin_items.selRight    = yes
                v-changed                               = v-changed + 1
            .
        end.
    end.
    else do:
        for each buf_right_temp_twowin_items
           where buf_right_temp_twowin_items.itmSelected = no
             and index( buf_right_temp_twowin_items.itmName, fi-filter ) <> 0
        :
            assign
                buf_right_temp_twowin_items.selRight    = yes
                v-changed                               = v-changed + 1
            .
        end.
    end.
    if v-changed > 0
    then do:
        br-table-right :refresh().
    end.
    apply "entry" to br-table-right.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-not-sel-desel-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-not-sel-desel-all Dialog-Frame
ON CHOOSE OF bt-not-sel-desel-all IN FRAME Dialog-Frame /* - */
DO:
    define variable v-changed    as integer      no-undo.
    for each buf_right_temp_twowin_items
    :
        assign
            buf_right_temp_twowin_items.selRight    = no
            v-changed                               = v-changed + 1
        .
    end.
    if v-changed > 0
    then do:
        br-table-right :refresh().
    end.
    apply "entry" to br-table-right.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-not-sel-reverse
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-not-sel-reverse Dialog-Frame
ON CHOOSE OF bt-not-sel-reverse IN FRAME Dialog-Frame /* / */
DO:
    define variable v-changed    as integer      no-undo.
    for each buf_right_temp_twowin_items
       where buf_right_temp_twowin_items.itmSelected = no
    :
        assign
            buf_right_temp_twowin_items.selRight    = not( buf_right_temp_twowin_items.selRight )
            v-changed                               = v-changed + 1
        .
    end.
    if v-changed > 0
    then do:
        br-table-right :refresh().
    end.
    apply "entry" to br-table-right.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-not-sel-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-not-sel-sel Dialog-Frame
ON CHOOSE OF bt-not-sel-sel IN FRAME Dialog-Frame /* * */
DO:
    if available buf_right_temp_twowin_items
    and buf_right_temp_twowin_items.itmSelected = no
    then do:
        assign
            buf_right_temp_twowin_items.selRight    = not( buf_right_temp_twowin_items.selRight )
        .
        display
            selRight
        with browse br-table-right .
        run select-and-move-down in this-procedure (
              input browse br-table-right :handle
            , input query br-table-right :handle
        ).
        apply "entry" to br-table-right.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-properties
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-properties Dialog-Frame
ON CHOOSE OF bt-properties IN FRAME Dialog-Frame /* Свойства */
DO:
    if available buf_right_temp_twowin_items
    then do:
        run value( p-runfilename ) (
              input p-mainmenu-handle
            , input buf_right_temp_twowin_items.itmExtKey
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка выполнения процедуры" p-runfilename
                skip return-value
                skip trim( error-status :get-message( 1 ) )
                     trim( error-status :get-message( 2 ) )
                     trim( error-status :get-message( 3 ) )
            view-as alert-box error.
            undo, return no-apply.
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-desel-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-desel-all Dialog-Frame
ON CHOOSE OF bt-sel-desel-all IN FRAME Dialog-Frame /* - */
DO:
    define variable v-changed    as integer      no-undo.
    for each buf_left_temp_twowin_items
       where buf_left_temp_twowin_items.itmSelected = yes
    :
        assign
            buf_left_temp_twowin_items.selLeft  = no
            v-changed                           = v-changed + 1
        .
    end.
    if v-changed > 0
    then do:
        br-table-left :refresh().
    end.
    apply "entry" to br-table-left.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-reverse
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-reverse Dialog-Frame
ON CHOOSE OF bt-sel-reverse IN FRAME Dialog-Frame /* / */
DO:
    define variable v-changed    as integer      no-undo.
    for each buf_left_temp_twowin_items
       where buf_left_temp_twowin_items.itmSelected = yes
    :
        assign
            buf_left_temp_twowin_items.selLeft  = not( buf_left_temp_twowin_items.selLeft )
            v-changed                           = v-changed + 1
        .
    end.
    if v-changed > 0
    then do:
        br-table-left :refresh().
    end.
    apply "entry" to br-table-left.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-sel Dialog-Frame
ON CHOOSE OF bt-sel-sel IN FRAME Dialog-Frame /* * */
DO:
    if available buf_left_temp_twowin_items
    and buf_left_temp_twowin_items.itmSelected = yes
    then do:
        assign
            buf_left_temp_twowin_items.selLeft = not( buf_left_temp_twowin_items.selLeft )
        .
        display
            selLeft
        with browse br-table-left .
        run select-and-move-down in this-procedure (
              input browse br-table-left :handle
            , input query br-table-left :handle
        ).
        apply "entry" to br-table-left.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-sel-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-sel-all Dialog-Frame
ON CHOOSE OF bt-sel-sel-all IN FRAME Dialog-Frame /* + */
DO:
    define variable v-changed    as integer      no-undo.
    for each buf_left_temp_twowin_items
       where buf_left_temp_twowin_items.itmSelected = yes
    :
        assign
            buf_left_temp_twowin_items.selLeft  = yes
            v-changed                           = v-changed + 1
        .
    end.
    if v-changed > 0
    then do:
        br-table-left :refresh().
    end.
    apply "entry" to br-table-left.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-select-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-select-type Dialog-Frame
ON CHOOSE OF bt-select-type IN FRAME Dialog-Frame /* --> */
/*or mouse-select-dblclick of br-table-right in frame dialog-frame*/
or return of br-table-right in frame dialog-frame
DO:
    define variable v-changed    as integer      no-undo.
    define buffer buf_temp_twowin_items for temp_twowin_items.
    if p-mode = 1
    then do:
        for each buf_right_temp_twowin_items
           where buf_right_temp_twowin_items.selRight = yes
        :
            assign
                buf_right_temp_twowin_items.itmSelected = yes
                buf_right_temp_twowin_items.selRight    = no
                v-changed                               = v-changed + 1
            .
        end.
        if v-changed > 0
        then do:
            br-table-right :refresh().
        end.
        {&OPEN-query-br-table-left}
        find first buf_temp_twowin_items
             where buf_temp_twowin_items.itmSelected = no
        no-error.
        if available buf_temp_twowin_items
        then do:
            apply "entry" to br-table-right.
        end.
        else do:
            apply "entry" to br-table-left.
        end.
    end.        /* if p-mode = 1 */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tb-filter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tb-filter Dialog-Frame
ON VALUE-CHANGED OF tb-filter IN FRAME Dialog-Frame
DO:
    assign
        tb-filter
    .
    {&OPEN-QUERY-br-table-right}
    apply "entry":U to br-table-right.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-table-left
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

{ gbl/app_help.i
    &disable_diasize="yes"
}

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
    apply "value-changed" to br-table-left.
    apply "entry" to br-table-left.

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
define output parameter p-changed   as logical          no-undo.

    define variable v-counter    as integer      no-undo.

    define buffer buf_temp_twowin_itemsSelected    for temp_twowin_itemsSelected.
    define buffer buf_temp_twowin_items            for temp_twowin_items.
do
for buf_temp_twowin_items
  , buf_temp_twowin_itemsSelected
on error undo, return error
:
    assign
        p-changed = no
    .
    check-selected-table:
    for each buf_temp_twowin_itemsSelected no-lock
    on error undo, return error
    :
        find first buf_temp_twowin_items
             where buf_temp_twowin_items.itm-key = buf_temp_twowin_itemsSelected.itm-key
        .
        if buf_temp_twowin_items.itmSelected = no
        then do:
            assign
                p-changed = yes
            .
            undo check-selected-table, leave check-selected-table.
        end.
    end.        /* for each buf_temp_twowin_itemsSelected */
    if p-changed = no
    then do:
        check-items-table:
        for each buf_temp_twowin_items
           where buf_temp_twowin_items.itmSelected = yes
        on error undo, return error
        :
            find first buf_temp_twowin_itemsSelected
                 where buf_temp_twowin_itemsSelected.itm-key = buf_temp_twowin_items.itm-key
            no-error.
            if not available buf_temp_twowin_itemsSelected
            then do:
                assign
                    p-changed = yes
                .
                undo check-items-table, leave check-items-table.
            end.
        end.
    end.
    if p-changed = yes
    then do:
        empty temp-table
            buf_temp_twowin_itemsSelected
        .
        for each buf_temp_twowin_items
           where buf_temp_twowin_items.itmSelected = yes
        on error undo, return error
        :
            assign
                v-counter = v-counter + 1
            .
            create buf_temp_twowin_itemsSelected.
            assign
                buf_temp_twowin_itemsSelected.its-key   = v-counter
                buf_temp_twowin_itemsSelected.itm-key   = buf_temp_twowin_items.itm-key
                buf_temp_twowin_itemsSelected.itmExtKey = buf_temp_twowin_items.itmExtKey
            .
        end.        /* for each buf_temp_twowin_items */
    end.
end.
END PROCEDURE. /* assign-export-table */

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
  DISPLAY fi-filter tb-filter ed-desc-not-sel ed-desc-sel
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-cancel bt-filter tb-filter b-help bt-properties
         br-table-right br-table-left bt-select-type bt-deselect-type
         ed-desc-not-sel ed-desc-sel
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
    define variable v-counter    as integer      no-undo.

    define buffer buf_temp_twowin_items     for temp_twowin_items.
    define buffer buf_temp_twowin_itemsSelected     for temp_twowin_itemsSelected.
do
for buf_temp_twowin_items
  , buf_temp_twowin_itemsSelected
on error undo, return error
:
    if p-title <> "":U
    then do:
        assign
            frame {&frame-name} :title = p-title
        .
    end.
    for each buf_temp_twowin_items
       where buf_temp_twowin_items.itmSelected = yes
    :
        assign
            v-counter = v-counter + 1
        .
        create buf_temp_twowin_itemsSelected.
        assign
            buf_temp_twowin_itemsSelected.its-key   = v-counter
            buf_temp_twowin_itemsSelected.itm-key   = buf_temp_twowin_items.itm-key
            buf_temp_twowin_itemsSelected.itmExtKey = buf_temp_twowin_items.itmExtKey
        .
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-open-query-left Dialog-Frame
PROCEDURE local-open-query-left :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

    open query br-table-left
        for each buf_left_temp_twowin_items no-lock
           where buf_left_temp_twowin_items.itmSelected = yes
    by buf_left_temp_twowin_items.itmName
    .

 END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-open-query-right Dialog-Frame
PROCEDURE local-open-query-right :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
with frame {&frame-name}
on error undo, return error
:
    if fi-filter = "":U
    or tb-filter = no
    then do:
        open query br-table-right
            for each buf_right_temp_twowin_items no-lock
            by buf_right_temp_twowin_items.itmName
        .
        assign
            fi-filter :bgcolor = GREY_COLOR
            bt-filter :bgcolor = GREY_COLOR
        .
    end.
    else do:
        open query br-table-right
            for each buf_right_temp_twowin_items no-lock
               where index( buf_right_temp_twowin_items.itmName, fi-filter ) <> 0
            by buf_right_temp_twowin_items.itmName
        .
        assign
            fi-filter :bgcolor = RED_COLOR
            bt-filter :bgcolor = RED_COLOR
        .
    end.
end.
END PROCEDURE. /* local-open-query-right */

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
            br-table-left
            br-table-right
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
do
with frame {&frame-name}
on error undo, return error
:
    enable
        bt-filter
        fi-filter
/*        tb-filter */
    .
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
    if p-runfilename <> "":U
    then do:
        assign
            bt-properties :visible      = yes
            bt-properties :sensitive    = yes
        .
        if p-runfilelabel <> "":U
        then do:
            assign
                bt-properties :label = p-runfilelabel
            .
        end.
    end.
    else do:
        assign
            bt-properties :visible      = no
        .
    end.
end.
END PROCEDURE. /* ui-enable */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
