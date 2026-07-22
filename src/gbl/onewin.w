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

Однооконный интерфейс для выбора из небольшого количества записей

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:
    parparentproc as widget-handle  - handle главного окна
    p-mode            as integer        - режим вызова:
                                            0 - выбор только одной строки
                                            1 - множественный выбор
                                            2 - единичный выбор
    p-title              as character   - заголовок окна
    p-runfilename        as character   - процедура для вызова по кнопке свойств (если "":U, то кнопка не видна)
                                          при выборе этой процедуре будут переданы:
                                            1. handle mainmenu.
                                            2. Код записи, определённый первым параметром процедуры onewin_add-item.
    p-runfilelabel       as character   - label для кнопки свойств
    table for temp_onewin_items         - заполненная таблица параметров для выбора (поле Selected - для правого окна)

Output:
    table for temp_onewin_itemsSelected        - таблица с кодами выбранных параметров
    p-cur-ext-key                       - код выбранной записи ( удобно для режима p-mode = 0 )
    p-accepted   as logical             - yes, если изменения приняты и были изменения в выборе

Пример:

    { gbl/onewin.i      }
    run onewin_clear in this-procedure.
    run onewin_add-item in this-procedure ( input "first-key",  input "Первая строка", input "Коммент1", input no ).
    run onewin_add-item in this-procedure ( input "second-key", input "Вторая строка", input "Коммент2", input no ).
    run onewin_add-item in this-procedure ( input "third-key",  input "Третья строка", input "Коммент3", input yes ).
    define variable v-accepted      as logical      no-undo.
    define variable v-cur-ext-key   as character    no-undo.
    run gbl/onewin.w (
          input parparentproc
        , input 1
        , input "Выбор записи"
        , input "test.p":U
        , input "&Тест"
        , input table temp_onewin_items
        , output table temp_onewin_itemsSelected
        , output v-cur-ext-key
        , output v-accepted
    ).
    define variable v-str as character  no-undo.
    for each temp_onewin_itemsSelected
    :
        assign
            v-str = substitute( "&1&2&3 (&4)"
                                , v-str
                                , ( if v-str = "" then "" else ", " )
                                , temp_onewin_itemsSelected.itm-key
                                , temp_onewin_itemsSelected.itmExtKey
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

{ gbl/onewin.i self }

/* Parameters Definitions ---                                           */
define input parameter parparentproc    as widget-handle    no-undo.
define input parameter p-mode               as integer          no-undo.
define input parameter p-title              as character        no-undo.
define input parameter p-runfilename        as character        no-undo.
define input parameter p-runfilelabel       as character        no-undo.
define input parameter table for temp_onewin_items .
define output parameter table for temp_onewin_itemsSelected .
define output parameter p-cur-ext-key       as character        no-undo.
define output parameter p-accepted          as logical          no-undo.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Однооконный интерфейс для выбора из небольшого количества записей".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ gbl/color.i       }
{ cmp/showinf.i     }

define variable v-onewin-close-enabled      as logical      no-undo.
define variable v-onewin-selected-rowid     as rowid        no-undo.
DEFINE VARIABLE v-parent-handle AS HANDLE NO-UNDO.


define buffer buf_right_temp_onewin_items             for temp_onewin_items.
define buffer buf_left_temp_onewin_items              for temp_onewin_items.
define buffer buf_temp_onewin_itemsSelected           for temp_onewin_itemsSelected.

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
&Scoped-define INTERNAL-TABLES buf_right_temp_onewin_items

/* Definitions for BROWSE br-table                                      */
&Scoped-define FIELDS-IN-QUERY-br-table buf_right_temp_onewin_items.itmSelected buf_right_temp_onewin_items.itmName
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-table
&Scoped-define SELF-NAME br-table
&Scoped-define OPEN-QUERY-br-table /* OPEN QUERY {&SELF-NAME} FOR EACH buf_right_temp_onewin_items no-lock. */ run local-open-query in this-procedure .
&Scoped-define TABLES-IN-QUERY-br-table buf_right_temp_onewin_items
&Scoped-define FIRST-TABLE-IN-QUERY-br-table buf_right_temp_onewin_items


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-table}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-close bt-filter tb-filter B-add ~
B-del b-help bt-properties br-table b-up b-down ed-desc-not-sel
&Scoped-Define DISPLAYED-OBJECTS fi-filter tb-filter ed-desc-not-sel

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-close AUTO-END-KEY DEFAULT
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON b-down
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 4.1 BY 1.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помощ&ь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-up
     IMAGE-UP FILE "btn-up-arrow":U
     IMAGE-DOWN FILE "btn-up-arrow":U
     IMAGE-INSENSITIVE FILE "btn-up-arrow":U
     LABEL ""
     SIZE 4.1 BY 1.

DEFINE BUTTON bt-filter DEFAULT
     LABEL "&ФПоиск"
     SIZE 10 BY 1 TOOLTIP "Поиск с фильтром строки во всех текстовых полях"
     BGCOLOR 8 .

DEFINE BUTTON bt-not-sel-all
     LABEL "&+"
     SIZE 3 BY 1 TOOLTIP "Выбрать все".

DEFINE BUTTON bt-not-sel-desel-all
     LABEL "-"
     SIZE 3 BY 1 TOOLTIP "Отменить выбор".

DEFINE BUTTON bt-not-sel-reverse
     LABEL "/"
     SIZE 3 BY 1 TOOLTIP "Инвертировать выбор".

DEFINE BUTTON bt-not-sel-sel
     LABEL "&*"
     SIZE 3 BY 1 TOOLTIP "Выбрать".

DEFINE BUTTON bt-properties DEFAULT
     LABEL "&Свойства"
     SIZE 15 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE ed-desc-not-sel AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 62 BY 2.5
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-filter AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 18 BY 1 NO-UNDO.

DEFINE VARIABLE tb-filter AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.6 BY .8 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-table FOR
      buf_right_temp_onewin_items SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-table Dialog-Frame _FREEFORM
  QUERY br-table NO-LOCK DISPLAY
      buf_right_temp_onewin_items.itmSelected column-label " *" format " */  "
      buf_right_temp_onewin_items.itmName column-label " Список" format "X(40)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-LABELS NO-ROW-MARKERS SEPARATORS SIZE 62 BY 17.07 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 2 NO-TAB-STOP
     b-close AT ROW 1 COL 12 NO-TAB-STOP
     bt-filter AT ROW 1 COL 22 NO-TAB-STOP
     fi-filter AT ROW 1 COL 30.3 COLON-ALIGNED NO-LABEL
     tb-filter AT ROW 1 COL 51.3
     B-add AT ROW 1 COL 54 WIDGET-ID 6
     B-del AT ROW 1 COL 64 WIDGET-ID 8
     b-help AT ROW 1 COL 74 NO-TAB-STOP
     bt-not-sel-sel AT ROW 2.43 COL 2 NO-TAB-STOP
     bt-not-sel-all AT ROW 2.43 COL 5 NO-TAB-STOP
     bt-not-sel-desel-all AT ROW 2.43 COL 8 NO-TAB-STOP
     bt-not-sel-reverse AT ROW 2.43 COL 11 NO-TAB-STOP
     bt-properties AT ROW 2.5 COL 49 NO-TAB-STOP
     br-table AT ROW 3.67 COL 2
     b-up AT ROW 7.4 COL 71 WIDGET-ID 2 NO-TAB-STOP
     b-down AT ROW 8.47 COL 71 WIDGET-ID 4 NO-TAB-STOP
     ed-desc-not-sel AT ROW 21 COL 2 NO-LABEL NO-TAB-STOP
     SPACE(13.69) SKIP(0.26)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выбор из списка"
         CANCEL-BUTTON b-close.


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
/* BROWSE-TAB br-table bt-properties Dialog-Frame */
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

ASSIGN
       ed-desc-not-sel:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN fi-filter IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       fi-filter:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-table
/* Query rebuild information for BROWSE br-table
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH buf_right_temp_onewin_items no-lock. */
run local-open-query in this-procedure .
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* BROWSE br-table */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Выбор из списка */
DO:
    if v-onewin-close-enabled = no
    then do:
        undo, return no-apply.
    end.
    else do:
        assign
            p-accepted = yes
        .
        run check-data in this-procedure.
        run assign-export-table in this-procedure .
        assign
            p-cur-ext-key = ( if available buf_right_temp_onewin_items then buf_right_temp_onewin_items.itmExtKey else "":U )
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


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  RUN onewin_custom-add-item IN v-parent-handle ( input this-procedure:handle  ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     RETURN NO-APPLY.
  END.
  run local-open-query in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-close
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-close Dialog-Frame
ON CHOOSE OF b-close IN FRAME Dialog-Frame /* Отмена */
DO:
    assign
        v-onewin-close-enabled  = yes
        p-accepted              = no
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
DEFINE buffer dEL_temp_onewin_items FOR temp_onewin_items.
  IF NOT AVAILABLE buf_right_temp_onewin_items THEN DO:
     RETURN NO-APPLY.
  END.
  find first dEL_temp_onewin_items where recid(dEL_temp_onewin_items) = recid(buf_right_temp_onewin_items).
  DELETE del_temp_onewin_items.
  run local-open-query in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-down
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-down Dialog-Frame
ON CHOOSE OF b-down IN FRAME Dialog-Frame
DO:
{ gbl/stdbtn.i }
DEFINE VARIABLE v-new AS INTEGER NO-UNDO.
DEFINE VARIABLE v-old AS INTEGER NO-UNDO.
define variable v-rec as recid no-undo .
DEFINE BUFFER down_right_temp_onewin_items FOR temp_onewin_items.
IF NOT AVAILABLE buf_right_temp_onewin_items THEN RETURN NO-APPLY.
FIND last down_right_temp_onewin_items WHERE
            USE-INDEX pi .
 IF buf_right_temp_onewin_items.itm-key = down_right_temp_onewin_items.itm-key THEN DO:
     BELL.
     RETURN NO-APPLY.
 END.
 ASSIGN
 v-rec = recid(buf_right_temp_onewin_items)
 v-old = buf_right_temp_onewin_items.itm-key
 .
 FIND FIRST down_right_temp_onewin_items WHERE
            down_right_temp_onewin_items.itm-key > v-old use-index pi NO-ERROR.
 if available down_right_temp_onewin_items then do:
   v-new = down_right_temp_onewin_items.itm-key.
 end.
 else do:
   bell.
   return no-apply.
 end.
 ASSIGN
 buf_right_temp_onewin_items.itm-key = 0.
 RELEASE buf_right_temp_onewin_items.
 down_right_temp_onewin_items.itm-key = v-old.
 RELEASE down_right_temp_onewin_items.
 FIND FIRST down_right_temp_onewin_items WHERE
            down_right_temp_onewin_items.itm-key = 0.
 ASSIGN
 down_right_temp_onewin_items.itm-key = v-new.
 RELEASE down_right_temp_onewin_items.
 run local-open-query in this-procedure .
 reposition br-table to recid v-rec.
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
        v-onewin-close-enabled = yes
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-up
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-up Dialog-Frame
ON CHOOSE OF b-up IN FRAME Dialog-Frame
DO:
{ gbl/stdbtn.i }
DEFINE VARIABLE v-new AS INTEGER NO-UNDO.
DEFINE VARIABLE v-old AS INTEGER NO-UNDO.
define variable v-rec as recid no-undo .
DEFINE BUFFER up_right_temp_onewin_items FOR temp_onewin_items.
IF NOT AVAILABLE buf_right_temp_onewin_items THEN RETURN NO-APPLY.
IF buf_right_temp_onewin_items.itm-key = 1 THEN DO:
  BELL.
  RETURN NO-APPLY.
END.
ASSIGN
v-rec = recid(buf_right_temp_onewin_items)
v-old = buf_right_temp_onewin_items.itm-key
.
FIND last up_right_temp_onewin_items WHERE
          up_right_temp_onewin_items.itm-key < v-old use-index pi NO-ERROR.
if available up_right_temp_onewin_items then do:
  v-new = up_right_temp_onewin_items.itm-key.
end.
else do:
  bell.
  return no-apply.
end.
ASSIGN
buf_right_temp_onewin_items.itm-key = 0.
RELEASE buf_right_temp_onewin_items.
up_right_temp_onewin_items.itm-key = v-old.
RELEASE up_right_temp_onewin_items.
FIND FIRST up_right_temp_onewin_items WHERE
          up_right_temp_onewin_items.itm-key = 0.
ASSIGN
up_right_temp_onewin_items.itm-key = v-new.
RELEASE up_right_temp_onewin_items.
run local-open-query in this-procedure .
reposition br-table to recid v-rec.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-table
&Scoped-define SELF-NAME br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table Dialog-Frame
ON insert-mode OF br-table IN FRAME Dialog-Frame
or " " of br-table in frame dialog-frame
DO:
    if p-mode = 1
    then do:
      apply "choose":u to bt-not-sel-sel.
    end.        /* if p-mode = 1 */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table Dialog-Frame
ON MOUSE-SELECT-CLICK OF br-table IN FRAME Dialog-Frame
DO:
    if p-mode = 1
    and buf_right_temp_onewin_items.itmselected:visible in browse br-table
    then do:
        if available buf_right_temp_onewin_items
        then do:
            assign
                buf_right_temp_onewin_items.itmSelected = not( buf_right_temp_onewin_items.itmSelected )
            .
            display
                itmSelected
            with browse br-table .
            apply "entry" to br-table.
        end.
    end.        /* if p-mode = 1 */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table Dialog-Frame
ON ROW-DISPLAY OF br-table IN FRAME Dialog-Frame
DO:
    define buffer buf_temp_onewin_itemsSelected    for temp_onewin_itemsSelected.

    if available buf_right_temp_onewin_items
    then do:
        find first buf_temp_onewin_itemsSelected
             where buf_temp_onewin_itemsSelected.itm-key = buf_right_temp_onewin_items.itm-key
        no-error.
        if available buf_temp_onewin_itemsSelected
        then do:
            assign
                buf_right_temp_onewin_items.itmName :bgcolor in browse br-table = GRAY_COLOR
                buf_right_temp_onewin_items.itmSelected :bgcolor in browse br-table = GRAY_COLOR
            .
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table Dialog-Frame
ON VALUE-CHANGED OF br-table IN FRAME Dialog-Frame
or entry of br-table IN FRAME Dialog-Frame
DO:
    if available buf_right_temp_onewin_items
    then do:
        assign
            ed-desc-not-sel = buf_right_temp_onewin_items.itmDesc
        .
    end.
    else do:
        assign
            ed-desc-not-sel = "":U
        .
    end.
    display
        ed-desc-not-sel
    with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-filter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-filter Dialog-Frame
ON CHOOSE OF bt-filter IN FRAME Dialog-Frame /* ФПоиск */
DO:
    define variable v-new-filter    as character    no-undo.
    define variable v-accepted      as logical      no-undo.
    run gbl/onewinf.w (
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
                tb-filter = no
            .
        end.
        else do:
            assign
                tb-filter = yes
            .
        end.
        display
            fi-filter
            tb-filter
        with frame {&frame-name}.
        {&OPEN-QUERY-br-table}
        apply "entry":U to br-table.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-not-sel-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-not-sel-all Dialog-Frame
ON CHOOSE OF bt-not-sel-all IN FRAME Dialog-Frame /* + */
DO:
    if fi-filter = "":U
    or tb-filter = no
    then do:
        for each buf_right_temp_onewin_items
           where buf_right_temp_onewin_items.itmSelected = no
        :
            assign
                buf_right_temp_onewin_items.itmSelected = yes
            .
        end.
    end.
    else do:
        for each buf_right_temp_onewin_items
           where buf_right_temp_onewin_items.itmSelected = no
             and index( buf_right_temp_onewin_items.itmName, fi-filter ) <> 0
        :
            assign
                buf_right_temp_onewin_items.itmSelected = yes
            .
        end.
    end.
    br-table :refresh().
    apply "entry" to br-table.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-not-sel-desel-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-not-sel-desel-all Dialog-Frame
ON CHOOSE OF bt-not-sel-desel-all IN FRAME Dialog-Frame /* - */
DO:
    for each buf_right_temp_onewin_items
    :
        assign
            buf_right_temp_onewin_items.itmSelected = no
        .
    end.
    br-table :refresh().
    apply "entry" to br-table.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-not-sel-reverse
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-not-sel-reverse Dialog-Frame
ON CHOOSE OF bt-not-sel-reverse IN FRAME Dialog-Frame /* / */
DO:
    for each buf_right_temp_onewin_items
    :
        assign
            buf_right_temp_onewin_items.itmSelected = not( buf_right_temp_onewin_items.itmSelected )
        .
    end.
    br-table :refresh().
    apply "entry" to br-table.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-not-sel-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-not-sel-sel Dialog-Frame
ON CHOOSE OF bt-not-sel-sel IN FRAME Dialog-Frame /* * */
DO:
    if available buf_right_temp_onewin_items
    then do:
        assign
            buf_right_temp_onewin_items.itmSelected = not( buf_right_temp_onewin_items.itmSelected )
        .
        display
            itmSelected
        with browse br-table .
        run select-and-move-down in this-procedure (
              input browse br-table :handle
            , input query br-table :handle
        ).
        apply "entry" to br-table.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-properties
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-properties Dialog-Frame
ON CHOOSE OF bt-properties IN FRAME Dialog-Frame /* Свойства */
DO:
    if available buf_right_temp_onewin_items
    then do:
        run value( p-runfilename ) (
              input parparentproc
            , input buf_right_temp_onewin_items.itmExtKey
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


&Scoped-define SELF-NAME tb-filter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tb-filter Dialog-Frame
ON VALUE-CHANGED OF tb-filter IN FRAME Dialog-Frame
DO:
    assign
        tb-filter
    .
    {&OPEN-QUERY-br-table}
    apply "entry":U to br-table.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

{ gbl/app_help.i
    &disable_diasize="yes"
}
{ gbl/hot-key.i b-close }
/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  ASSIGN
  v-parent-handle = THIS-PROCEDURE:INSTANTIATING-PROCEDURE.
  run init-fields in this-procedure.
  RUN enable_UI.
  run ui-disable-all in this-procedure.
  run ui-enable in this-procedure.
  apply "entry" to br-table.
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
    define variable v-counter    as integer      no-undo.

    define buffer buf_temp_onewin_itemsSelected    for temp_onewin_itemsSelected.
    define buffer buf_temp_onewin_items            for temp_onewin_items.
do
for buf_temp_onewin_items
  , buf_temp_onewin_itemsSelected
on error undo, return error
:
    empty temp-table
        buf_temp_onewin_itemsSelected
    .
    for each buf_temp_onewin_items
        where buf_temp_onewin_items.itmSelected = yes
    on error undo, return error
    :
        run onewin_create-selection in this-procedure ( input buf_temp_onewin_items.itm-key
                                                       ,input buf_temp_onewin_items.itmExtKey
                                                       ).
    end.        /* for each buf_temp_onewin_items */
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
  DISPLAY fi-filter tb-filter ed-desc-not-sel
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-close bt-filter tb-filter B-add B-del b-help bt-properties
         br-table b-up b-down ed-desc-not-sel
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

    define buffer buf_temp_onewin_items         for temp_onewin_items.
    define buffer buf_temp_onewin_itemsSelected for temp_onewin_itemsSelected.
do
for buf_temp_onewin_items
  , buf_temp_onewin_itemsSelected
on error undo, return error
:
    if p-title <> "":U
    then do:
        assign
            frame {&frame-name} :title = p-title
        .
    end.
    for each buf_temp_onewin_items
       where buf_temp_onewin_items.itmSelected = yes
    on error undo, return error
    :
        assign
            v-counter = v-counter + 1
        .
        create buf_temp_onewin_itemsSelected.
        assign
            buf_temp_onewin_itemsSelected.its-key   = v-counter
            buf_temp_onewin_itemsSelected.itm-key   = buf_temp_onewin_items.itm-key
            buf_temp_onewin_itemsSelected.itmExtKey = buf_temp_onewin_items.itmExtKey
        .
        assign
            v-onewin-selected-rowid = rowid( buf_temp_onewin_items )
        .
        if p-mode = 0
        or p-mode = 2
        then do:
            assign
                buf_temp_onewin_items.itmSelected = no
            .
        end.
    end.        /* for each buf_temp_onewin_items */
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-open-query Dialog-Frame
PROCEDURE local-open-query :
do
with frame {&frame-name}
on error undo, return error
:
if b-up:visible in frame {&frame-name} then do:
  if fi-filter = "":U
  or tb-filter = no
  then do:
    open query br-table
        for each buf_right_temp_onewin_items no-lock
        by buf_right_temp_onewin_items.itm-key
    .
    assign
    fi-filter :bgcolor = GREY_COLOR
    bt-filter :bgcolor = GREY_COLOR
    .
  end.
  else do:
    open query br-table
        for each buf_right_temp_onewin_items no-lock
            where index( buf_right_temp_onewin_items.itmName, fi-filter ) <> 0
        by buf_right_temp_onewin_items.itm-key
    .
    assign
    fi-filter :bgcolor = RED_COLOR
    bt-filter :bgcolor = RED_COLOR
    .
  end.
end.
else do:
    if fi-filter = "":U
    or tb-filter = no
    then do:
        open query br-table
            for each buf_right_temp_onewin_items no-lock
            by buf_right_temp_onewin_items.itmName
        .
        assign
            fi-filter :bgcolor = GREY_COLOR
            bt-filter :bgcolor = GREY_COLOR
        .
    end.
    else do:
        open query br-table
            for each buf_right_temp_onewin_items no-lock
               where index( buf_right_temp_onewin_items.itmName, fi-filter ) <> 0
            by buf_right_temp_onewin_items.itmName
        .
        assign
            fi-filter :bgcolor = RED_COLOR
            bt-filter :bgcolor = RED_COLOR
        .
    end.
end.
end.
END PROCEDURE. /* local-open-query */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-and-move-down Dialog-Frame
PROCEDURE select-and-move-down :
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
            br-table
    .
end.
END PROCEDURE. /* ui-disable-all */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ui-enable Dialog-Frame
PROCEDURE ui-enable :
define variable v-bttns as character no-undo .
do
with frame {&frame-name}
on error undo, return error
:
    enable
        bt-filter
        fi-filter
        tb-filter
        ed-desc-not-sel
    .
  case p-mode:
    when 1 then do:
            enable
                b-close
                bt-not-sel-sel
                bt-not-sel-desel-all
                bt-not-sel-all
                bt-not-sel-reverse
            .
        end.        /* when 1 */
      when 2 then do:
            enable
                b-close
            .
            reposition br-table to rowid( v-onewin-selected-rowid ) no-error.
        end.        /* when 2 */
      when 0 then do:
            assign
                b-exit :label = "В&ыход"
            .
        end.        /* when 0 */
    end case.       /* case p-mode */
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
  IF LOOKUP("onewin_get-bttns", v-parent-handle:INTERNAL-ENTRIES) > 0 THEN DO:
    run onewin_get-bttns in v-parent-handle ( output v-bttns).
    if lookup("bt-not-sel-sel", v-bttns) = 0 then do:
      disable
      bt-not-sel-sel
      with frame {&frame-name} .
      hide
      bt-not-sel-sel
      in frame {&frame-name} .
    end.
    if lookup("bt-not-sel-desel-all", v-bttns) = 0 then do:
      disable
      bt-not-sel-desel-all
      with frame {&frame-name} .
      hide
      bt-not-sel-desel-all
      in frame {&frame-name} .
    end.
    if lookup("bt-not-sel-all", v-bttns) = 0 then do:
      disable
      bt-not-sel-all
      with frame {&frame-name} .
      hide
      bt-not-sel-all
      in frame {&frame-name} .
    end.
    if lookup("bt-not-sel-reverse", v-bttns) = 0 then do:
      disable
      bt-not-sel-reverse
      with frame {&frame-name} .
      hide
      bt-not-sel-reverse
      in frame {&frame-name} .
    end.
    IF LOOKUP("b-exit", v-bttns) > 0 THEN DO:
      enable
      b-exit
      with frame {&frame-name} .
    end.
    else do:
      hide
      b-exit
      in frame {&frame-name} .
    end.
    IF LOOKUP("onewin_custom-add-item", v-parent-handle:INTERNAL-ENTRIES) > 0
    and lookup("b-add", v-bttns) > 0
    THEN DO:
      enable
      b-add
      with frame {&frame-name} .
    end.
    else do:
      hide
      b-add
      in frame {&frame-name} .
    end.
    IF LOOKUP("b-del", v-bttns) > 0 THEN DO:
      enable
      b-del
      with frame {&frame-name} .
    end.
    else do:
      hide
      b-del
      in frame {&frame-name} .
    end.
    IF LOOKUP("b-up", v-bttns) > 0 THEN DO:
      enable
      b-up
      with frame {&frame-name} .
    end.
    else do:
      hide
      b-up
      in frame {&frame-name} .
    end.
    IF LOOKUP("b-down", v-bttns) > 0 THEN DO:
      enable
      b-down
      with frame {&frame-name} .
    end.
    else do:
      hide
      b-down
      in frame {&frame-name} .
    end.
  end.
  if bt-not-sel-sel:visible in frame {&frame-name} = no
  and bt-not-sel-desel-all:visible in frame {&frame-name} = no
  and bt-not-sel-all:visible in frame {&frame-name} = no
  and bt-not-sel-reverse:visible in frame {&frame-name} = no then do:
    assign
    buf_right_temp_onewin_items.itmselected:visible in browse br-table = no.
  end.
end.
END PROCEDURE. /* ui-enable */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME