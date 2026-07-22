&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dlg-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dlg-grp
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Управление деревом групп клиентов

Автор: Белоусов Илья Александрович
Дата создания: 04/11/06
Author: Ilia Belousov
Creation date: 04/11/06

Input:

Output:

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input parameter parparentproc as widget-handle no-undo .
define input parameter        p-button-list as character no-undo. /* список включенных кнопок */
define input-output parameter p-recid-list  as character no-undo.

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Управление деревом групп клиентов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ ref/cgrplib.i }
{ cmp/library.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/waitfram.i }
{ gbl/usr-flt.i  }
{ gbl/prn-lib.i }
{ gbl/getcntxt.i def }

if p-button-list <> {&cbuttons-for-move}
then do:
    define new shared temp-table tt-goods no-undo like ub.goods.
    define new shared temp-table tt-clients no-undo like ub.clients.
end.

define variable v-root-code                 as integer          no-undo.
define variable v-found-grp-num             as integer  init 0  no-undo.
define variable v-full-search-string        as character        no-undo.
define variable v-full-search-next          as logical  init no no-undo.
define variable v-full-search-start-code    as integer          no-undo.
define variable print-option as character no-undo.
define variable cli-grp-row as integer init 1 no-undo.
define variable v-from-b-cli as logical no-undo .
define variable v-old-recid-list as character no-undo .
define variable v-old-recid as recid no-undo .
define variable v-is-deploy as logical no-undo .
DEFINE VARIABLE rum-option   AS CHARACTER NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dlg-grp
&Scoped-define BROWSE-NAME br-list

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp_cgrplib_grp

/* Definitions for BROWSE br-list                                       */
&Scoped-define FIELDS-IN-QUERY-br-list temp_cgrplib_grp.sel no-label temp_cgrplib_grp.name temp_cgrplib_grp.d-pcnt temp_cgrplib_grp.node-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-list
&Scoped-define SELF-NAME br-list
&Scoped-define QUERY-STRING-br-list FOR EACH temp_cgrplib_grp NO-LOCK by temp_cgrplib_grp.sort-name
&Scoped-define OPEN-QUERY-br-list OPEN QUERY {&SELF-NAME} FOR EACH temp_cgrplib_grp NO-LOCK by temp_cgrplib_grp.sort-name.
&Scoped-define TABLES-IN-QUERY-br-list temp_cgrplib_grp
&Scoped-define FIRST-TABLE-IN-QUERY-br-list temp_cgrplib_grp


/* Definitions for DIALOG-BOX Dlg-grp                                   */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dlg-grp ~
    ~{&OPEN-QUERY-br-list}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-mark b-sel b-add b-chg b-del b-move ~
B-cli b-disc b-print B-history b-help B-rum b-expand b-expand-all fi-search ~
b-find-by-full-name b-find-by-substring b-search br-list
&Scoped-Define DISPLAYED-OBJECTS fi-search

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-print
       MENU-ITEM m_classificator LABEL "Классификатор"
       MENU-ITEM m_browse       LABEL "Справочник"
       MENU-ITEM m_term         LABEL "Содержимое терминальных групп".

DEFINE MENU MENU-B-rum
       MENU-ITEM m_current      LABEL "Текущая"
       MENU-ITEM m_current_plus_childs LABEL "Текущая (с группами нижних уровней)"
       MENU-ITEM m_selected     LABEL "Выбранные"
       MENU-ITEM m_selected_plus_childs LABEL "Выбранные (с группами нижних уровней)"
       MENU-ITEM m_all          LABEL "Все"
       RULE
       MENU-ITEM m_xml-file-import LABEL "Импорт из XML-файла".


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1 TOOLTIP "Добавить группу"
     BGCOLOR 8 .

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1 TOOLTIP "Изменить название и характеристики группы"
     BGCOLOR 8 .

DEFINE BUTTON B-cli
     LABEL "&Клиенты"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1 TOOLTIP "Удалить группу"
     BGCOLOR 8 .

DEFINE BUTTON b-disc
     LABEL "Скидка"
     SIZE 10 BY 1.

DEFINE BUTTON b-exit
     LABEL "&Выход"
     SIZE 10 BY 1 TOOLTIP "Выход"
     BGCOLOR 8 .

DEFINE BUTTON b-expand
     LABEL ">>"
     SIZE 3.5 BY 1.13.

DEFINE BUTTON b-expand-all
     LABEL ">>-->>"
     SIZE 7.5 BY 1.13.

DEFINE BUTTON b-find-by-full-name
     LABEL "+"
     SIZE 3 BY 1 TOOLTIP "Продолжить до полного имени (CTRL-D)"
     BGCOLOR 8 .

DEFINE BUTTON b-find-by-substring
     LABEL "?"
     SIZE 3 BY 1 TOOLTIP "Найти подстроку во всех группах (CTRL-S)"
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 3 BY 1 TOOLTIP "Помощь"
     BGCOLOR 8 .

DEFINE BUTTON B-history
     LABEL "Ис&тория"
     SIZE 3 BY 1.

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-move
     LABEL "П&еренести"
     SIZE 10 BY 1 TOOLTIP "Переместить группу"
     BGCOLOR 8 .

DEFINE BUTTON b-print
     LABEL "Пе&чать"
     SIZE 3 BY 1 TOOLTIP "Печать списка групп".

DEFINE BUTTON B-rum
     LABEL "&Операции над группами"
     SIZE 30 BY 1.

DEFINE BUTTON b-search
     LABEL "Поиск"
     SIZE 10 BY 1.03
     BGCOLOR 8 .

DEFINE BUTTON b-sel
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE fi-search AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 69.8 BY 1
     FGCOLOR 1  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-list FOR
      temp_cgrplib_grp SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-list Dlg-grp _FREEFORM
  QUERY br-list DISPLAY
      temp_cgrplib_grp.sel           format  "X(1)" no-label
      temp_cgrplib_grp.name          format "X(71)"      label " Наименование группы"
      temp_cgrplib_grp.d-pcnt        format  ">9.99"      label " Скидка"
      temp_cgrplib_grp.node-code     FORMAT ">>>,>>>,>>9" LABEL "Вн №"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 93.1 BY 18.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dlg-grp
     b-exit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 18
     b-add AT ROW 1 COL 28
     b-chg AT ROW 1 COL 38
     b-del AT ROW 1 COL 48
     b-move AT ROW 1 COL 58
     B-cli AT ROW 1 COL 68
     b-disc AT ROW 1 COL 78 WIDGET-ID 2
     b-print AT ROW 1 COL 89
     B-history AT ROW 1 COL 92
     b-help AT ROW 1 COL 95
     B-rum AT ROW 2 COL 68 WIDGET-ID 4
     b-expand AT ROW 3 COL 1
     b-expand-all AT ROW 3 COL 4.5
     fi-search AT ROW 3 COL 12.5 NO-LABEL
     b-find-by-full-name AT ROW 3 COL 82.5
     b-find-by-substring AT ROW 3 COL 85.5
     b-search AT ROW 3 COL 88.5
     br-list AT ROW 4 COL 1
     SPACE(4.79) SKIP(0.34)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Группы клиентов".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dlg-grp
   FRAME-NAME                                                           */
/* BROWSE-TAB br-list b-search Dlg-grp */
ASSIGN
       FRAME Dlg-grp:SCROLLABLE       = FALSE
       FRAME Dlg-grp:HIDDEN           = TRUE.

ASSIGN
       b-print:POPUP-MENU IN FRAME Dlg-grp       = MENU MENU-b-print:HANDLE.

ASSIGN
       B-rum:POPUP-MENU IN FRAME Dlg-grp       = MENU MENU-B-rum:HANDLE.

/* SETTINGS FOR FILL-IN fi-search IN FRAME Dlg-grp
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-list
/* Query rebuild information for BROWSE br-list
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp_cgrplib_grp NO-LOCK by temp_cgrplib_grp.sort-name.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-list */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dlg-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dlg-grp Dlg-grp
ON ENDKEY OF FRAME Dlg-grp /* Группы клиентов */
DO:
      run gbl/markqwa.p (
                           input b-mark:visible
                          , input p-recid-list) no-error.
    if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dlg-grp Dlg-grp
ON WINDOW-CLOSE OF FRAME Dlg-grp /* Группы клиентов */
DO:
  apply "end-error":U to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dlg-grp
ON CHOOSE OF b-add IN FRAME Dlg-grp /* Добавить */
DO:
    run add-grp in this-procedure (
        input temp_cgrplib_grp.node-code
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка добавления группы клиентов."
        skip return-value
        skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        trim(error-status :get-message(4))
        trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dlg-grp
ON CHOOSE OF b-chg IN FRAME Dlg-grp /* Изменить */
DO:
    run change-grp in this-procedure (
        input temp_cgrplib_grp.node-code
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка изменения группы клиентов."
        skip return-value
        skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        trim(error-status :get-message(4))
        trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-cli Dlg-grp
ON CHOOSE OF B-cli IN FRAME Dlg-grp /* Клиенты */
DO:
 DEFINE VARIABLE cli-list AS CHARACTER NO-UNDO.
 DEFINE VARIABLE v-grp-list AS CHARACTER NO-UNDO.
 define buffer buf_cli-grp for ub.cli-grp.
IF AVAILABLE temp_cgrplib_grp THEN DO:
    RUN cli-grplib-get-full-name in this-procedure (input temp_cgrplib_grp.node-code, output v-grp-list) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Не найдена группа для показа"
          skip "справочника клиентов."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
  find first buf_cli-grp no-lock where
            buf_cli-grp.node-code = temp_cgrplib_grp.node-code no-error.
  assign
  v-old-recid-list = p-recid-list
  v-from-b-cli = yes
  v-old-recid = (if available buf_cli-grp then recid(buf_cli-grp) else ?)
  .
  run ref/cli-all.w (  parparentproc
                      ,input ""         /*bttns*/
                      ,input ""         /*c-types*/
                      ,input ({&group} + {&delim-key} + v-grp-list) /*c-group*/
                      ,input ?         /*c-status*/
                      ,input ?         /*c-recid*/
                      ,input ?        /*c-added*/
                      ,input ?        /* c-other*/
                      ,output cli-list ) .

  run UI-on in this-procedure no-error .

END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dlg-grp
ON CHOOSE OF b-del IN FRAME Dlg-grp /* Удалить */
DO:
    run delete-grp in this-procedure (
          input temp_cgrplib_grp.node-code
        , input yes
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка удаления группы клиентов."
        skip return-value
        skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        trim(error-status :get-message(4))
        trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-disc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-disc Dlg-grp
ON CHOOSE OF b-disc IN FRAME Dlg-grp /* Скидка */
DO:
  IF NOT AVAILABLE temp_cgrplib_grp THEN RETURN NO-APPLY.
  run proc-b-disc IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dlg-grp
ON CHOOSE OF b-exit IN FRAME Dlg-grp /* Выход */
DO:
    define variable v-cli-grp-recid     as recid             no-undo.
    run get-current-recid in this-procedure (
          input temp_cgrplib_grp.node-code
        , output v-cli-grp-recid
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Не найдена группа для восстановления"
          skip "предыдущего состояния справочника групп."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
        run gbl/markqwa.p (
                           input b-mark:visible
                          , input p-recid-list) no-error.
    if error-status:error then return no-apply.

    assign
        cli-grp-row  = v-cli-grp-recid
        p-recid-list = ""
    .
    assign
    v-uf-List_ = (if cli-grp-row = ? then {&question-mark} else string(cli-grp-row))
    .
    run uf-set in this-procedure(
        input  {&uf-cli-grp-p}
        ,input  v-cntxt-userid
        ,input v-uf-List_
        ,input v-uf-Naim
        ,input v-uf-print-graft
        ,input v-uf-sort-gr
        ,input v-uf-type-price
        ,input v-uf-type-val
    )  no-error .
    apply "WINDOW-CLOSE" TO FRAME {&FRAME-NAME} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-expand
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-expand Dlg-grp
ON CHOOSE OF b-expand IN FRAME Dlg-grp /* >> */
DO:
    if temp_cgrplib_grp.node-code = v-root-code
    then do:
        run collapse-all-on-first-level in this-procedure no-error .
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка операции с деревом групп."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
                trim(error-status :get-message(4))
                trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return no-apply .
        end.
    end.
    if temp_cgrplib_grp.mark <> {&closed-noterminal-cgrp-mark}
    and temp_cgrplib_grp.mark <> {&opened-noterminal-cgrp-mark}
    then do:
        return no-apply.
    end.

    run expand-or-collapse-item in this-procedure no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка операции с деревом групп."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-expand-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-expand-all Dlg-grp
ON CHOOSE OF b-expand-all IN FRAME Dlg-grp /* >>-->> */
DO:
    run expand-all-from-current in this-procedure (
            input temp_cgrplib_grp.node-code
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка при раскрытии дерева групп."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-find-by-full-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-find-by-full-name Dlg-grp
ON CHOOSE OF b-find-by-full-name IN FRAME Dlg-grp /* + */
DO:
    define variable v-new-name as character no-undo.
    run cgrplib-expand-name in this-procedure (
        input fi-search :screen-value
        , output v-new-name
    ) no-error.
    if error-status :error
    then do:
        message return-value.
        undo, return no-apply.
    end.
    if v-new-name = ""
    then do:
        message
            "Не найдена группа с полным именем, начинающимся на"
            skip "'" + fi-search :screen-value + "'"
        view-as alert-box information.
        assign
            v-new-name = fi-search :screen-value
        .
    end.
    assign
        fi-search :screen-value  = right-trim( v-new-name, {&delim-grp} )
        fi-search :cursor-offset = length( v-new-name ) + 1
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-find-by-full-name Dlg-grp
ON LEAVE OF b-find-by-full-name IN FRAME Dlg-grp /* + */
DO:
    assign
        v-found-grp-num  = 0
        b-search :label = "Поиск"
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-find-by-substring
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-find-by-substring Dlg-grp
ON CHOOSE OF b-find-by-substring IN FRAME Dlg-grp /* ? */
DO:
    define variable v-new-name as character no-undo.
    define variable v-new-code as integer   no-undo.

    if v-full-search-next = no
    then do:
        assign
            v-full-search-string     = fi-search :screen-value
            v-full-search-next       = yes
            v-full-search-start-code = 0
        .
    end.
    { gbl/working.i }
    run cgrplib-find-by-substring in this-procedure (
                          input v-full-search-start-code
                        , input v-full-search-string
                        , output v-new-code
                        , output v-new-name
    ) no-error.
    if error-status :error
    then do:
        { gbl/stopwork.i }
        message return-value.
        undo, return no-apply.
    end.
    { gbl/stopwork.i }
    if v-new-code = 0
    then do:
        message
            skip "Не найдена строка '" v-full-search-string "' в имени группы."
        view-as alert-box information
        title "Поиск завершен".
        assign
            v-new-name               = fi-search :screen-value
            v-full-search-string     = ""
            v-full-search-next       = no
            v-full-search-start-code = 0
        .
    end.
    else do:
        assign
            v-full-search-start-code = v-new-code
        .
    end.
    assign
        fi-search :screen-value  = right-trim( v-new-name, {&delim-grp} )
        fi-search :cursor-offset = length( v-new-name ) + 1
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-find-by-substring Dlg-grp
ON LEAVE OF b-find-by-substring IN FRAME Dlg-grp /* ? */
DO:
    assign
        v-found-grp-num  = 0
        b-search :label = "Поиск"
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-history
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-history Dlg-grp
ON CHOOSE OF B-history IN FRAME Dlg-grp /* История */
DO:
   define variable rid-list as character no-undo .
    if available temp_cgrplib_grp THEN
   run ref/ccgrphis.w (
                     input parparentproc
                    ,INPUT "":U /* bttns */
                    ,INPUT "cli-grp":U /*parref-mode */
                    ,INPUT temp_cgrplib_grp.node-code
                    ,INPUT NO /*p-is-del*/
                    ,OUTPUT rid-list
       ) .
    apply "entry" to br-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dlg-grp
ON CHOOSE OF b-mark IN FRAME Dlg-grp /* * */
DO:
    run b-mark-press ( input temp_cgrplib_grp.node-code ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка выбора в списке групп"
        skip return-value
        skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        trim(error-status :get-message(4))
        trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-move
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-move Dlg-grp
ON CHOOSE OF b-move IN FRAME Dlg-grp /* Перенести */
DO:
    run select-and-move-item in this-procedure (
            input temp_cgrplib_grp.node-code
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка перемещения группы."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dlg-grp
ON CHOOSE OF b-print IN FRAME Dlg-grp /* Печать */
DO:
    run print-grp in this-procedure ( input temp_cgrplib_grp.node-code ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка печати."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-rum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-rum Dlg-grp
ON CHOOSE OF B-rum IN FRAME Dlg-grp /* Операции над группами */
DO:
  if rum-option = "":U then do:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if rum-option = "":U then do:
      return no-apply.
  end.
  RUN proc-b-rum IN THIS-PROCEDURE ( INPUT rum-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      rum-option = "".
      RETURN NO-APPLY.
  END.
  rum-option = "".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-search
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-search Dlg-grp
ON CHOOSE OF b-search IN FRAME Dlg-grp /* Поиск */
DO:
    run find-grp-in-browse in this-procedure (
        input fi-search :screen-value
    ) no-error.
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка поиска группы в списке."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-search Dlg-grp
ON LEAVE OF b-search IN FRAME Dlg-grp /* Поиск */
DO:
    assign
        v-found-grp-num  = 0
        b-search :label = "Поиск"
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dlg-grp
ON CHOOSE OF b-sel IN FRAME Dlg-grp /* Выбор */
DO:
    define variable v-yesno     as logical     init no      no-undo.
    run fill-output-parameters-on-exit in this-procedure ( input temp_cgrplib_grp.node-code ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка передачи параметров списка групп."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
          skip (1) "Закрыть список групп?"
        view-as alert-box error buttons yes-no update v-yesno.
        if v-yesno = no
        then do:
            undo, return no-apply .
        end.
    end.
    if return-value = "no-term" then return no-apply.
    apply "WINDOW-CLOSE" TO FRAME {&FRAME-NAME} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-list
&Scoped-define SELF-NAME br-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-list Dlg-grp
ON + OF br-list IN FRAME Dlg-grp
DO:
    if temp_cgrplib_grp.mark = {&closed-noterminal-cgrp-mark}
    then do:
        run expand-item in this-procedure ( input temp_cgrplib_grp.node-code, input yes ) no-error .
        if error-status :error
        then do:
            message
              vss-workfile vss-revision vss-description
              skip "Не удалось раскрыть подуровни группы."
              skip return-value
              skip trim(error-status :get-message(1))
                   trim(error-status :get-message(2))
                   trim(error-status :get-message(3))
                   trim(error-status :get-message(4))
                   trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return no-apply .
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-list Dlg-grp
ON - OF br-list IN FRAME Dlg-grp
DO:
    if temp_cgrplib_grp.mark = {&opened-noterminal-cgrp-mark}
    then do:
        run collapse-item in this-procedure ( input temp_cgrplib_grp.node-code, input yes ) no-error .
        if error-status :error
        then do:
            message
              vss-workfile vss-revision vss-description
              skip "Не удалось закрыть подуровни группы."
              skip return-value
              skip trim(error-status :get-message(1))
                   trim(error-status :get-message(2))
                   trim(error-status :get-message(3))
                   trim(error-status :get-message(4))
                   trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return no-apply .
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-list Dlg-grp
ON DELETE-CHARACTER OF br-list IN FRAME Dlg-grp
DO:
    if b-del :sensitive = yes
    and b-del :visible = yes
    then do:
        run delete-grp in this-procedure (
            input temp_cgrplib_grp.node-code
            , input yes
        ) no-error .
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка удаления группы клиентов."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            trim(error-status :get-message(4))
            trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return no-apply .
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-list Dlg-grp
ON END OF br-list IN FRAME Dlg-grp
DO:
    define variable v-row-amount     as integer           no-undo.
    run get-row-amount in this-procedure ( output v-row-amount ) no-error.
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка при подсчете строк списка групп."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    reposition br-list to row v-row-amount.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-list Dlg-grp
ON HOME OF br-list IN FRAME Dlg-grp
DO:
    reposition br-list to row 1.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-list Dlg-grp
ON INSERT-MODE OF br-list IN FRAME Dlg-grp
DO:
    if b-add :sensitive = yes
    and b-add :visible = yes
    then do:
        run add-grp in this-procedure (
            input temp_cgrplib_grp.node-code
        ) no-error .
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка добавления группы клиентов."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            trim(error-status :get-message(4))
            trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return no-apply.
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-list Dlg-grp
ON MOUSE-SELECT-DBLCLICK OF br-list IN FRAME Dlg-grp
DO:
    if temp_cgrplib_grp.mark <> {&closed-noterminal-cgrp-mark}
    and temp_cgrplib_grp.mark <> {&opened-noterminal-cgrp-mark}
    then do:
        return no-apply.
    end.

    run expand-or-collapse-item in this-procedure no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка операции с деревом групп."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-list Dlg-grp
ON RETURN OF br-list IN FRAME Dlg-grp
DO:
    if temp_cgrplib_grp.mark <> {&closed-noterminal-cgrp-mark}
    and temp_cgrplib_grp.mark <> {&opened-noterminal-cgrp-mark}
    then do:
        return no-apply.
    end.

    run expand-or-collapse-item in this-procedure no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка операции с деревом групп."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-list Dlg-grp
ON VALUE-CHANGED OF br-list IN FRAME Dlg-grp
DO:
    if temp_cgrplib_grp.level <> 0
    then do:
        assign
            fi-search :screen-value = right-trim( temp_cgrplib_grp.full-name, {&delim-grp} )
        .
    end.
    IF (temp_cgrplib_grp.mark = {&terminal-with-clients-cgrp-mark}
    or temp_cgrplib_grp.mark = {&terminal-no-clients-cgrp-mark} )
    and b-chg:sensitive in frame {&frame-name} = yes
    then do:
       ENABLE b-disc
       WITH FRAME {&FRAME-NAME}.
    END.
    ELSE DO:
        disable b-disc
        WITH FRAME {&FRAME-NAME}.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-search
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-search Dlg-grp
ON CTRL-D OF fi-search IN FRAME Dlg-grp
DO:
    define variable v-new-name as character no-undo.

    run cgrplib-expand-name in this-procedure (
        input fi-search :screen-value
        , output v-new-name
    ) no-error.
    if error-status :error
    then do:
        message return-value.
        undo, return no-apply.
    end.
    if v-new-name = ""
    then do:
        message
            "Не найдена группа с полным именем, начинающимся на"
            skip "'" + fi-search :screen-value + "'"
        view-as alert-box information.
        assign
            v-new-name = fi-search :screen-value
        .
    end.
    assign
        fi-search :screen-value  = right-trim( v-new-name, {&delim-grp} )
        fi-search :cursor-offset = length( v-new-name ) + 1
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-search Dlg-grp
ON CTRL-S OF fi-search IN FRAME Dlg-grp
DO:
    define variable v-new-name as character no-undo.
    define variable v-new-code as integer   no-undo.

    if v-full-search-next = no
    then do:
        assign
            v-full-search-string     = fi-search :screen-value
            v-full-search-next       = yes
            v-full-search-start-code = 0
        .
    end.
    { gbl/working.i }
    run cgrplib-find-by-substring in this-procedure (
                          input v-full-search-start-code
                        , input v-full-search-string
                        , output v-new-code
                        , output v-new-name
    ) no-error.
    if error-status :error
    then do:
        { gbl/stopwork.i }
        message return-value.
        undo, return no-apply.
    end.
    { gbl/stopwork.i }
    if v-new-code = 0
    then do:
        message
            skip "Не найдена строка '" v-full-search-string "' в имени группы."
        view-as alert-box information
        title "Поиск завершен".
        assign
            v-new-name               = fi-search :screen-value
            v-full-search-string     = ""
            v-full-search-next       = no
            v-full-search-start-code = 0
        .
    end.
    else do:
        assign
            v-full-search-start-code = v-new-code
        .
    end.
    assign
        fi-search :screen-value  = right-trim( v-new-name, {&delim-grp} )
        fi-search :cursor-offset = length( v-new-name ) + 1
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-search Dlg-grp
ON LEAVE OF fi-search IN FRAME Dlg-grp
DO:
    if fi-search :screen-value <> v-full-search-string
    then do:
        assign
            v-full-search-string     = ""
            v-full-search-next       = no
            v-full-search-start-code = 0
        .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-search Dlg-grp
ON RETURN OF fi-search IN FRAME Dlg-grp
DO:
    if fi-search :screen-value = ""
    or fi-search :screen-value = ?
    then do:        /* Ничего не делать, если строка поиска пуста. */
        return no-apply.
    end.
    run find-grp-in-browse in this-procedure (
        input fi-search :screen-value
    ) no-error.
    if error-status :error
    then do:
        message
          skip "Группа не найдена."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box warning.
        undo, return no-apply.
    end.
    apply "ENTRY" to b-search in frame {&frame-name}.
    return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_all Dlg-grp
ON CHOOSE OF MENU-ITEM m_all /* Все */
DO:
  rum-option = "all".
  RUN proc-b-rum IN THIS-PROCEDURE ( INPUT rum-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      rum-option = "".
      RETURN NO-APPLY.
  END.
  rum-option = "".

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_browse
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_browse Dlg-grp
ON CHOOSE OF MENU-ITEM m_browse /* Справочник */
DO:
    assign print-option = "browse":U.
  run print-grp in this-procedure(input temp_cgrplib_grp.node-code)  no-error.
  if error-status:error then do:
    assign
    print-option = "":U.
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_classificator
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_classificator Dlg-grp
ON CHOOSE OF MENU-ITEM m_classificator /* Классификатор */
DO:
      assign print-option = "classificator":U.
  run print-grp in this-procedure(input temp_cgrplib_grp.node-code) no-error.
  if error-status:error then do:
    assign
    print-option = "":U.
    return no-apply.
  end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_current
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_current Dlg-grp
ON CHOOSE OF MENU-ITEM m_current /* Текущая */
DO:
  rum-option = "current".
  RUN proc-b-rum IN THIS-PROCEDURE ( INPUT rum-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      rum-option = "".
      RETURN NO-APPLY.
  END.
  rum-option = "".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_current_plus_childs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_current_plus_childs Dlg-grp
ON CHOOSE OF MENU-ITEM m_current_plus_childs /* Текущая (с группами нижних уровней) */
DO:
  rum-option = "current+childs".
  RUN proc-b-rum IN THIS-PROCEDURE ( INPUT rum-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      rum-option = "".
      RETURN NO-APPLY.
  END.
  rum-option = "".

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_selected
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_selected Dlg-grp
ON CHOOSE OF MENU-ITEM m_selected /* Выбранные */
DO:
  rum-option = "selected".
  RUN proc-b-rum IN THIS-PROCEDURE ( INPUT rum-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      rum-option = "".
      RETURN NO-APPLY.
  END.
  rum-option = "".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_selected_plus_childs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_selected_plus_childs Dlg-grp
ON CHOOSE OF MENU-ITEM m_selected_plus_childs /* Выбранные (с группами нижних уровней) */
DO:
  rum-option = "selected+childs".
  RUN proc-b-rum IN THIS-PROCEDURE ( INPUT rum-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      rum-option = "".
      RETURN NO-APPLY.
  END.
  rum-option = "".

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_term
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_term Dlg-grp
ON CHOOSE OF MENU-ITEM m_term /* Содержимое терминальных групп */
DO:
  assign print-option = "terminal":U.
  run print-grp in this-procedure(input temp_cgrplib_grp.node-code) no-error.
  if error-status:error then do:
    assign
    print-option = "":U.
    return no-apply.
  end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_xml-file-import
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_xml-file-import Dlg-grp
ON CHOOSE OF MENU-ITEM m_xml-file-import /* Импорт из XML-файла */
DO:
  rum-option = {&cli-grp-proc_xml-file-import}.
  RUN proc-b-rum IN THIS-PROCEDURE ( INPUT rum-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      rum-option = "".
      RETURN NO-APPLY.
  END.
  rum-option = "".

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dlg-grp


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
  { gbl/getcntxt.i get }
/*  RUN enable_UI. */
  run UI-on in this-procedure no-error .
  if error-status :error
  then do:
      message
        vss-workfile vss-revision vss-description
        skip "Ошибка при загрузке дерева групп."
        skip return-value
        skip trim(error-status :get-message(1))
             trim(error-status :get-message(2))
             trim(error-status :get-message(3))
             trim(error-status :get-message(4))
             trim(error-status :get-message(5))
      view-as alert-box error.
      undo, return error .
  end.
  apply "entry" to br-list.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-grp Dlg-grp
PROCEDURE add-grp :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  input p-node-code - код группы для добавления подгруппы.
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.

    define variable v-cli-grp-recid     as recid    no-undo.
    define variable v-focused-row       as integer  no-undo.
    define variable v-repositioned-row  as integer  no-undo.
    define variable v-have-clients        as logical  no-undo.
    define variable v-have-rights       as logical       no-undo.

    define buffer buf_cli-grp           for ub.cli-grp.
    define buffer buf_temp_cgrplib_grp   for temp_cgrplib_grp.

    run check-rights-for-change-grp in this-procedure (
         input p-node-code
        ,output v-have-rights
    ) no-error.
    if error-status :error
    or v-have-rights = no
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Нет прав на изменение справочника групп клиентов."
          skip "Удаление группы невозможно."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    assign
        v-focused-row      = br-list :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-list" )
    .
    run cgrplib-have-clients in this-procedure ( input p-node-code, output v-have-clients ) no-error .
    if error-status :error
    then do:
        undo, return error "add-grp: Ошибка определения наличия клиентов в группе." + {&new-line} + return-value.
    end.
    if v-have-clients = yes
    then do:
        message "В данной группе есть клиенты. Добавить в нее подгруппу,"
                "включающую этих клиентов ?"
        view-as alert-box question
        buttons OK-Cancel
        update v-yesno as logical.
        if v-yesno = no
        then do:
            apply "entry" to br-list in frame {&frame-name}.
            return no-apply.
        end.
    end.
    find first buf_temp_cgrplib_grp
         where buf_temp_cgrplib_grp.node-code = p-node-code
    no-error .
    if not available buf_temp_cgrplib_grp
    then do:
        undo, return error "add-grp: Не найдена группа в browse.".
    end.
    if buf_temp_cgrplib_grp.mark = {&closed-noterminal-cgrp-mark}
    then do:
        run expand-item in this-procedure ( input p-node-code, input no ) no-error.
        if error-status :error
        then do:
            undo, return error "add-grp: Не удается раскрыть группу.".
        end.
    end.
    run ref/c-grp-f.w (   input parparentproc
                    , input {&add-def}
                    , input p-node-code
                    , input-output v-cli-grp-recid
                  ) no-error .
    if v-cli-grp-recid = ?
    then do:
        apply "entry" to br-list in frame {&frame-name}.
        return no-apply.
    end.
    find first buf_cli-grp
         where recid ( buf_cli-grp ) =  v-cli-grp-recid
    no-error.
    if not available buf_cli-grp
    then do:
        undo, return error "add-grp: Ошибка добавления группы.".
    end.
    run create-new-line in this-procedure (
                          input buf_cli-grp.node-code
                        , input buf_cli-grp.upper-code
                        , input buf_temp_cgrplib_grp.level + 1
                        , input buf_cli-grp.node-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "add-grp: Ошибка добавления строки в список групп.".
    end.
    if buf_temp_cgrplib_grp.level > 0
    then do:
        assign
        buf_temp_cgrplib_grp.mark = {&opened-noterminal-cgrp-mark}
        buf_temp_cgrplib_grp.name = substring( buf_temp_cgrplib_grp.name, 1, buf_temp_cgrplib_grp.level * {&ctab-size} )
                            + {&opened-noterminal-cgrp-mark}
                            + substring( buf_temp_cgrplib_grp.name, buf_temp_cgrplib_grp.level * {&ctab-size} + 2 )
        buf_temp_cgrplib_grp.d-pcnt = 0
        .
    end.
    {&OPEN-BROWSERS-IN-QUERY-Dlg-grp}
    br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
    reposition br-list to row v-repositioned-row.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE b-mark-press Dlg-grp
PROCEDURE b-mark-press :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.

    define variable v-focused-row       as integer              no-undo.
    define variable v-repositioned-row  as integer              no-undo.

    define buffer buf_temp_cgrplib_grp       for temp_cgrplib_grp.
    define buffer buf_upper_temp_cgrplib_grp for temp_cgrplib_grp.

    find first buf_temp_cgrplib_grp
         where buf_temp_cgrplib_grp.node-code = p-node-code
    no-error .
    if not available buf_temp_cgrplib_grp
    then do:
        undo, return error "b-mark-press: Ошибка поиска группы".
    end.
    assign
        v-focused-row      = br-list :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-list" )
    .
    if buf_temp_cgrplib_grp.sel = {&cselection-char}
    or p-node-code = v-root-code
    then do:
        /* снимаем отметку */
        assign
            buf_temp_cgrplib_grp.sel = ""
        .
    end.
    else do:
        /* ставим отметку */
        assign
            buf_temp_cgrplib_grp.sel = {&cselection-char}
        .
        /* снимаем все отметки выше по дереву */
        for each buf_upper_temp_cgrplib_grp
            where buf_upper_temp_cgrplib_grp.level < buf_temp_cgrplib_grp.level
              and buf_upper_temp_cgrplib_grp.full-name = substring( buf_temp_cgrplib_grp.full-name, 1
                                                        , length( buf_upper_temp_cgrplib_grp.full-name ) )
        :
            assign
                buf_upper_temp_cgrplib_grp.sel = ""
            .
        end.
        /* снимаем все отметки ниже по дереву */
        for each buf_upper_temp_cgrplib_grp
           where buf_upper_temp_cgrplib_grp.node-code <> buf_temp_cgrplib_grp.node-code
             and buf_upper_temp_cgrplib_grp.full-name begins buf_temp_cgrplib_grp.full-name
        :
            assign
                buf_upper_temp_cgrplib_grp.sel = ""
            .
        end.
    end.
    {&OPEN-BROWSERS-IN-QUERY-Dlg-grp}
    if v-focused-row > br-list :height - 2
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
    br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
    reposition br-list to row v-repositioned-row no-error.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE change-grp Dlg-grp
PROCEDURE change-grp :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.

    define variable v-cli-grp-recid     as recid    no-undo.
    define variable v-focused-row       as integer  no-undo.
    define variable v-repositioned-row  as integer  no-undo.
    define variable v-have-rights       as logical       no-undo.
    define variable v-d-pcnt            as decimal           no-undo.
    define variable v-old-full-name     as character     no-undo.

    define buffer buf_cli-grp                   for ub.cli-grp.
    define buffer buf_temp_cgrplib_grp          for temp_cgrplib_grp.
    define buffer buf_child_temp_cgrplib_grp    for temp_cgrplib_grp.

    run check-rights-for-change-grp in this-procedure (
         input p-node-code
        ,output v-have-rights
    ) no-error.
    if error-status :error
    or v-have-rights = no
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Нет прав на изменение справочника групп клиентов."
          skip "Удаление группы невозможно."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    assign
        v-focused-row      = br-list :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-list" )
    .
    find first buf_cli-grp no-lock
         where buf_cli-grp.node-code = p-node-code
    no-error.
    if error-status :error
    then do:
        undo, return error "change-grp: Неверный выбор группы.".
    end.
    assign
        v-cli-grp-recid = recid( buf_cli-grp )
    .
    run ref/c-grp-f.w ( input parparentproc, input {&update}, input p-node-code, input-output v-cli-grp-recid ).
    if v-cli-grp-recid = ?
    then do:
        find first buf_temp_cgrplib_grp
            where buf_temp_cgrplib_grp.node-code = p-node-code
        no-error.
        if not available buf_temp_cgrplib_grp
        then do:
            undo, return error "change-grp: Ошибка поиска группы в списке.".
        end.
        browse br-list:refresh().
        apply "entry" to br-list in frame {&frame-name}.
        return no-apply.
    end.
    find first buf_temp_cgrplib_grp
         where buf_temp_cgrplib_grp.node-code = p-node-code
    no-error.
    if not available buf_temp_cgrplib_grp
    then do:
        undo, return error "change-grp: Ошибка поиска группы в списке.".
    end.
    find first buf_cli-grp no-lock
         where buf_cli-grp.node-code = p-node-code
    no-error.
    if error-status :error
    then do:
        undo, return error "change-grp: Неверный выбор группы.".
    end.
    if buf_temp_cgrplib_grp.level > 0
    then do:
        assign
            buf_temp_cgrplib_grp.name    = substring( buf_temp_cgrplib_grp.name
                                                    , 1
                                                    , buf_temp_cgrplib_grp.level * {&ctab-size} + 2 )
                                            + buf_cli-grp.node-name
        .
    end.
    else do:
        assign
            buf_temp_cgrplib_grp.name    = buf_cli-grp.node-name
        .
    end.
    assign
        v-old-full-name             = buf_temp_cgrplib_grp.full-name
    .
    run cli-grplib-get-full-name in this-procedure (
          input p-node-code
        , output buf_temp_cgrplib_grp.full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "Ошибка вычисления полного имени группы в списке".
    end.
    run cli-grplib-get-sort-name in this-procedure (
          input p-node-code
        , output buf_temp_cgrplib_grp.sort-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "Ошибка вычисления полного имени группы в списке".
    end.
    if buf_temp_cgrplib_grp.level <> 0
    then do:
        assign
            fi-search :screen-value = right-trim( buf_temp_cgrplib_grp.full-name, {&delim-grp} )
        .
    end.
    for each buf_child_temp_cgrplib_grp
       where buf_child_temp_cgrplib_grp.full-name begins v-old-full-name
         and buf_child_temp_cgrplib_grp.full-name <> v-old-full-name
         and buf_child_temp_cgrplib_grp.level <> buf_temp_cgrplib_grp.level
    :
        run cli-grplib-get-full-name in this-procedure (
              input buf_child_temp_cgrplib_grp.node-code
            , output buf_child_temp_cgrplib_grp.full-name
        ) no-error .
        if error-status :error
        then do:
            undo, return error "Ошибка вычисления полного имени группы в списке".
        end.
        run cli-grplib-get-sort-name in this-procedure (
              input buf_child_temp_cgrplib_grp.node-code
            , output buf_child_temp_cgrplib_grp.sort-name
        ) no-error .
        if error-status :error
        then do:
            undo, return error "Ошибка вычисления полного имени группы в списке".
        end.
    end.
    {&OPEN-BROWSERS-IN-QUERY-Dlg-grp}
    br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
    reposition br-list to row v-repositioned-row.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-rights-for-change-grp Dlg-grp
PROCEDURE check-rights-for-change-grp :
/*------------------------------------------------------------------------------
  Purpose:     Проверка прав
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code as integer no-undo.
define output parameter p-have-rights   as logical      no-undo.

    define variable v-enable-change-grp as logical       no-undo.

    if v-cntxt-db-num <> 0
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Операция определена только в ГБД."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        assign
            p-have-rights = no
        .
    end.
    else do:
        { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_reference_groups-edit':U
        {&cntxt-firm}
        v-cntxt-host-code-obj
        '':U
        0
        0
        p-node-code
        0
        no
        p-have-rights
        }
    end.
end.
END PROCEDURE. /* check-rights-for-change-grp */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cli-grps_rum-fill_cb Dlg-grp
PROCEDURE cli-grps_rum-fill_cb :
DEFINE INPUT PARAMETER p-target-bh AS handle NO-UNDO.
define input parameter p-processed-bh as handle no-undo .
define variable v-start-node-code as integer no-undo .
define variable v-full-name as character no-undo .
define buffer buf_temp_cgrplib_grp for temp_cgrplib_grp.
define buffer buf_cli-grp for ub.cli-grp.
define buffer child_cli-grp for ub.cli-grp.
CASE rum-option:
  WHEN "all" THEN DO:
     FOR EACH buf_cli-grp:
        p-target-bh:BUFFER-CREATE.
        p-target-bh:BUFFER-COPY(BUFFER buf_cli-grp:HANDLE).
        run cli-grplib-get-full-name in this-procedure ( input buf_cli-grp.node-code, output v-full-name) no-error.
        p-target-bh::full-name = v-full-name.
        p-target-bh:BUFFER-RELEASE.

     END.
  END.
  WHEN "current" THEN DO:
    if available temp_cgrplib_grp then do:
      find first buf_cli-grp no-lock
            where buf_cli-grp.node-code = temp_cgrplib_grp.node-code
      no-error .
      if error-status :error
      then do:
          undo, return error "cli-grps_rum-fill_cb: Не найдена запись выбранной группы '"
                              + "'" + temp_cgrplib_grp.full-name + "'".
      end.
      p-target-bh:find-first ( substitute("where node-code = &1", buf_cli-grp.node-code)) no-error .
      if not p-target-bh:available then do:
        p-target-bh:BUFFER-CREATE.
        p-target-bh:BUFFER-COPY(BUFFER buf_cli-grp:HANDLE).
        run cli-grplib-get-full-name in this-procedure ( input buf_cli-grp.node-code, output v-full-name) no-error.
        p-target-bh::full-name = v-full-name.
        p-target-bh:BUFFER-RELEASE.
      end.
    END. /*    if available temp_cgrp-lib_grp then do:*/
  END.
  WHEN "current+childs" THEN DO:
    if available temp_cgrplib_grp then do:
      find first buf_cli-grp no-lock
            where buf_cli-grp.node-code = temp_cgrplib_grp.node-code
      no-error .
      if error-status :error
      then do:
          undo, return error "cli-grps_rum-fill_cb: Не найдена запись выбранной группы '"
                              + "'" + temp_cgrplib_grp.full-name + "'".
      end.
      v-start-node-code = buf_cli-grp.node-code.
      p-target-bh:find-first ( substitute("where node-code = &1", buf_cli-grp.node-code)) no-error .
      if not p-target-bh:available then do:
        p-target-bh:BUFFER-CREATE.
        p-target-bh:BUFFER-COPY(BUFFER buf_cli-grp:HANDLE).
        run cli-grplib-get-full-name in this-procedure ( input buf_cli-grp.node-code, output v-full-name) no-error.
        p-target-bh::full-name = v-full-name.
        p-target-bh:BUFFER-RELEASE.
        p-processed-bh:BUFFER-CREATE.
        p-processed-bh::node-code = buf_cli-grp.node-code.
        p-processed-bh:BUFFER-COPY(BUFFER buf_cli-grp:HANDLE).
        p-processed-bh::processed = no.
        p-processed-bh:BUFFER-RELEASE.
      end.
      process-nodes:
      do while yes
      :
          p-processed-bh:find-first( substitute(" where node-code = &1", v-start-node-code)).
          p-processed-bh::processed = yes.
          for each child_cli-grp no-lock
            where child_cli-grp.upper-code = v-start-node-code
          on error undo, return error
          :
            p-target-bh:find-first ( substitute("where node-code = &1", child_cli-grp.node-code)) no-error .
            if not p-target-bh:available then do:
              p-target-bh:BUFFER-CREATE.
              p-target-bh:BUFFER-COPY(BUFFER child_cli-grp:HANDLE).
              run cli-grplib-get-full-name in this-procedure ( input child_cli-grp.node-code, output v-full-name) no-error.
              p-target-bh::full-name = v-full-name.
              p-target-bh:BUFFER-RELEASE.
            end.
            p-processed-bh:BUFFER-CREATE.
            p-processed-bh::node-code = child_cli-grp.node-code.
            p-processed-bh::processed = no.
            p-processed-bh:BUFFER-RELEASE.

          end.
          p-processed-bh:find-first( "where processed = no") no-error.
          if not p-processed-bh:available
          then do:
            leave process-nodes.
          end.
          else do:
            assign
            v-start-node-code = p-processed-bh::node-code
            .
          end.
      end.
    END. /*if available temp_cgrp-lib_grp*/
  END.
  WHEN "selected" THEN DO:
    FOR EACH buf_temp_cgrplib_grp
       where buf_temp_cgrplib_grp.sel = {&cselection-char}
    :
        find first buf_cli-grp no-lock
             where buf_cli-grp.node-code = buf_temp_cgrplib_grp.node-code
        no-error .
        if error-status :error
        then do:
            undo, return error "cli-grps_rum-fill_cb: Не найдена запись выбранной группы '"
                                + "'" + buf_temp_cgrplib_grp.full-name + "'".
        end.
      p-target-bh:find-first ( substitute("where node-code = &1", buf_cli-grp.node-code)) no-error .
      if not p-target-bh:available then do:
         p-target-bh:BUFFER-CREATE.
         p-target-bh:BUFFER-COPY(BUFFER buf_cli-grp:HANDLE).
         run cli-grplib-get-full-name in this-procedure ( input buf_cli-grp.node-code, output v-full-name) no-error.
         p-target-bh::full-name = v-full-name.
         p-target-bh:BUFFER-RELEASE.
      end.
    END.
  END.
  WHEN "selected+child" THEN DO:
    FOR EACH buf_temp_cgrplib_grp
       where buf_temp_cgrplib_grp.sel = {&cselection-char}
    :
      find first buf_cli-grp no-lock
            where buf_cli-grp.node-code = buf_temp_cgrplib_grp.node-code
      no-error .
      if error-status :error
      then do:
          undo, return error "cli-grps_rum-fill_cb: Не найдена запись выбранной группы '"
                              + "'" + buf_temp_cgrplib_grp.full-name + "'".
      end.
      p-target-bh:find-first ( substitute("where node-code = &1", buf_cli-grp.node-code)) no-error .
      if not p-target-bh:available then do:
        p-target-bh:BUFFER-CREATE.
        p-target-bh:BUFFER-COPY(BUFFER buf_cli-grp:HANDLE).
        run cli-grplib-get-full-name in this-procedure ( input buf_cli-grp.node-code, output v-full-name) no-error.
        p-target-bh::full-name = v-full-name.
        p-target-bh:BUFFER-RELEASE.
        p-processed-bh:BUFFER-CREATE.
        p-processed-bh::node-code = buf_cli-grp.node-code.
        p-processed-bh::processed = no.
        p-processed-bh:BUFFER-RELEASE.
      end.
      process-nodes:
      do while yes
      :
          p-processed-bh:find-first( substitute(" where node-code = &1", v-start-node-code)).
          p-processed-bh::processed = yes.
          for each child_cli-grp no-lock
            where child_cli-grp.upper-code = v-start-node-code
          on error undo, return error
          :
            p-target-bh:find-first ( substitute("where node-code = &1", child_cli-grp.node-code)) no-error .
            if not p-target-bh:available then do:
              p-target-bh:BUFFER-CREATE.
              p-target-bh:BUFFER-COPY(BUFFER child_cli-grp:HANDLE).
              run cli-grplib-get-full-name in this-procedure ( input child_cli-grp.node-code, output v-full-name) no-error.
              p-target-bh::full-name = v-full-name.
              p-target-bh:BUFFER-RELEASE.
            end.
            p-processed-bh:BUFFER-CREATE.
            p-processed-bh::node-code = child_cli-grp.node-code.
            p-processed-bh::processed = no.
            p-processed-bh:BUFFER-RELEASE.

          end.
          p-processed-bh:find-first( "where processed = no") no-error.
          if not p-processed-bh:available
          then do:
            leave process-nodes.
          end.
          else do:
            assign
            v-start-node-code = p-processed-bh::node-code
            .
          end.
      end.
    END. /*FOR EACH buf_temp_cgrp-lib_grp*/
  END. /*WHEN "selected+child" THEN DO:*/

END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE collapse-all-on-first-level Dlg-grp
PROCEDURE collapse-all-on-first-level :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    define buffer buf_cli-grp       for ub.cli-grp.
    define buffer buf_temp_cgrplib_grp       for temp_cgrplib_grp.
    for each buf_temp_cgrplib_grp no-lock
       where buf_temp_cgrplib_grp.upper-code = v-root-code
    :
        run collapse-item in this-procedure (
              input buf_temp_cgrplib_grp.node-code
            , input no
        ) no-error .
        if error-status :error
        then do:
            undo, return error "Не удалось закрыть подуровни группы "
                                + {&new-line} + "'" + buf_temp_cgrplib_grp.full-name + "'"
                                + {&new-line} + return-value.
        end.
    end.
    {&OPEN-BROWSERS-IN-QUERY-Dlg-grp}
end.
END PROCEDURE. /* collapse-all-on-first-level */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE collapse-item Dlg-grp
PROCEDURE collapse-item :
/*------------------------------------------------------------------------------
  Purpose:     Свернуть поддерево выбранной группы
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
define input parameter p-refresh    as logical      no-undo.

    define variable v-focused-row       as integer              no-undo.
    define variable v-repositioned-row  as integer              no-undo.

    define buffer buf_del_temp_cgrplib_grp   for temp_cgrplib_grp.
    define buffer buf_temp_cgrplib_grp       for temp_cgrplib_grp.

    find first buf_temp_cgrplib_grp
         where buf_temp_cgrplib_grp.node-code = p-node-code
    no-error.
    if error-status :error
    then do:
        undo, return error "collapse-item: Неверно передан код группы. Нет группы с кодом " + string( p-node-code ).
    end.

    assign
        v-focused-row      = br-list :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-list" )
    .

    for each buf_del_temp_cgrplib_grp
       where buf_del_temp_cgrplib_grp.full-name begins buf_temp_cgrplib_grp.full-name
         and buf_del_temp_cgrplib_grp.full-name <> buf_temp_cgrplib_grp.full-name
         and buf_del_temp_cgrplib_grp.level     <> buf_temp_cgrplib_grp.level
    :
        delete buf_del_temp_cgrplib_grp.
    end.
    assign
        buf_temp_cgrplib_grp.mark = {&closed-noterminal-cgrp-mark}
        buf_temp_cgrplib_grp.name = replace( buf_temp_cgrplib_grp.name
                                        , {&opened-noterminal-cgrp-mark}
                                        , {&closed-noterminal-cgrp-mark}
                                        )
    .
    if p-refresh = yes
    then do:
        {&OPEN-BROWSERS-IN-QUERY-Dlg-grp}
        br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
        reposition br-list to row v-repositioned-row.
    end.
end.
END PROCEDURE. /* collapse-item */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-new-line Dlg-grp
PROCEDURE create-new-line :
/*------------------------------------------------------------------------------
  Purpose:     Создание линии в строке browse без перерисовки
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code      as integer      no-undo.
define input parameter p-upper-code     as integer      no-undo.
define input parameter p-level          as integer      no-undo.
define input parameter p-node-name      as character    no-undo.


define variable v-full-name         as character         no-undo.
define variable v-sort-name         as character         no-undo.

define buffer buf_temp_cgrplib_grp       for temp_cgrplib_grp.

    run cli-grplib-get-full-name in this-procedure (
              input p-node-code
            , output v-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "create-new-line: Ошибка вычисления полного имени группы." .
    end.
    run cli-grplib-get-sort-name in this-procedure (
              input p-node-code
            , output v-sort-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "create-new-line: Ошибка вычисления полного имени группы." .
    end.
    create buf_temp_cgrplib_grp.
    assign
        buf_temp_cgrplib_grp.node-code   = p-node-code
        buf_temp_cgrplib_grp.upper-code  = p-upper-code
        buf_temp_cgrplib_grp.level       = p-level
        buf_temp_cgrplib_grp.full-name   = v-full-name
        buf_temp_cgrplib_grp.sort-name   = v-sort-name
    .
    run get-first-char in this-procedure (
                                              input p-node-code
                                            , output buf_temp_cgrplib_grp.mark
                                         ) no-error.
    if error-status :error
    then do:
        undo, return error "create-new-line: Ошибка вычисления первого символа для отображения группы." .
    end.
    assign
        buf_temp_cgrplib_grp.name = fill( " ", {&ctab-size} * p-level )
                                        + buf_temp_cgrplib_grp.mark
                                        + " "
                                        + p-node-name
    .
    run cgrplib-get-pcnt-value in this-procedure ( input p-node-code, output buf_temp_cgrplib_grp.d-pcnt) no-error.
    if error-status :error
    then do:
        undo, return error "create-new-line: Ошибка вычисления скидки для группы." .
    end.

end.
END PROCEDURE. /* create-new-line */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE delete-grp Dlg-grp
PROCEDURE delete-grp :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.
define input parameter p-refresh    as logical      no-undo.

    define variable v-cli-grp-recid     as recid    no-undo.
    define variable v-focused-row       as integer  no-undo.
    define variable v-repositioned-row  as integer  no-undo.
    define variable v-upper-code        as integer  no-undo.
    define variable v-answer            as logical  no-undo.
    define variable v-is-terminal       as logical  no-undo.
    define variable v-have-clients      as logical  no-undo.
    define variable v-counter           as integer  no-undo.
    define variable v-have-rights       as logical  no-undo.

    define buffer buf_cli-grp           for ub.cli-grp.
    define buffer buf_same_cli-grp      for ub.cli-grp.                      /* для проверки совпадения имен */
    define buffer buf_temp_cgrplib_grp   for temp_cgrplib_grp.

    run check-rights-for-change-grp in this-procedure (
         input p-node-code
        ,output v-have-rights
    ) no-error.
    if error-status :error
    or v-have-rights = no
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Нет прав на изменение справочника групп клиентов."
          skip "Удаление группы невозможно."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    assign
        v-focused-row      = br-list :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-list" )
    .
    /*---START--------- Нельзя удалить корневую группу ---------------------*/
    if p-node-code = v-root-code
    then do:
        message
            "Нельзя удалить корневую группу."
        view-as alert-box.
        undo, return.
    end.
    /*---END----------- Нельзя удалить корневую группу ---------------------*/
    find first buf_temp_cgrplib_grp
         where buf_temp_cgrplib_grp.node-code = p-node-code
    no-error .
    if error-status :error
    then do:
        undo, return error "Неверно выбрана группа." .
    end.
    /*---START--------- Нельзя удалить последнюю группу первого уровня ---------------------*/
    if buf_temp_cgrplib_grp.upper-code = v-root-code
    then do:
        assign
            v-counter = v-counter + 1
        .
        count-first-level-grp:
        for each buf_cli-grp no-lock
           where buf_cli-grp.upper-code = v-root-code
        :
            assign
                v-counter = v-counter + 1
            .
            if v-counter > 1
            then do:
                leave count-first-level-grp.
            end.
            else do:
                message
                    "Нельзя удалить последнюю группу первого уровня."
                view-as alert-box.
                return error.
            end.
        end.
    end.
    /*---END----------- Нельзя удалить последнюю группу первого уровня ---------------------*/
    find first buf_cli-grp no-lock
         where buf_cli-grp.node-code = p-node-code
    no-error.
    if error-status :error
    then do:
        undo, return error "change-grp: Нет группы БД, соответствующей значению в списке.".
    end.
    assign
        v-upper-code    = buf_cli-grp.upper-code
        v-answer        = no
    .
    run cgrplib-is-terminal in this-procedure ( input p-node-code, output v-is-terminal ) no-error.
    if error-status :error
    then do:
        undo, return error return-value.
    end.

    if v-is-terminal = no
    then do:
    /* проверяем, не имеет ли одна из подгрупп такое же название, как и соседняя к удаляемой */
        for each buf_cli-grp
        where buf_cli-grp.upper-code = v-upper-code
          and buf_cli-grp.node-code <> p-node-code
        :
            find first buf_same_cli-grp no-lock
                where buf_same_cli-grp.upper-code  = p-node-code
                and buf_same_cli-grp.node-name   = buf_cli-grp.node-name
            no-error.
            if available buf_same_cli-grp
            then do:
                message
                    "Одна из подгрупп удаляемой группы имеет название:" buf_cli-grp.node-name "-" skip
                    "такое же, как одна из соседних к удаляемой групп." skip
                    "После удаления получились бы 2 группы на одном уровне, имеющие одинаковые названия, что запрещено."
                view-as alert-box error.
                return no-apply.
            end.
        end.
        message "Текущая группа будет удалена."
            skip "Ее подгруппы будут перенесены в вышестоящую группу."
            skip (1) "Слить группу с вышестоящей?"
        view-as alert-box question buttons yes-no update v-answer.
    end.
    if v-is-terminal = yes
    then do:
        run cgrplib-have-clients in this-procedure ( input p-node-code, output v-have-clients ) no-error .
        if error-status :error
        then do:
            undo, return error "delete-grp: Ошибка определения наличия клиентов в группе." + {&new-line} + return-value.
        end.
        if v-have-clients = yes
        then do:
            find first buf_cli-grp no-lock
                 where buf_cli-grp.upper-code = v-upper-code
                   and buf_cli-grp.node-code <> p-node-code
            no-error .
            if available buf_cli-grp
            then do:
                message "В одной группе не могут быть одновременно подгруппы и клиенты."
                    skip "Эта группа не может быть слита с вышестоящей."
                view-as alert-box error.
                apply "entry" to br-list in frame {&frame-name}.
                return no-apply.
            end.
            message "Текущая группа будет удалена."
                skip "Товары будут перенесены в вышестоящую группу."
                skip (1) "Слить группу с вышестоящей?"
            view-as alert-box question buttons yes-no update v-answer.
        end.
        else do:
            message "Удалить группу ? Вы уверены ?"
            view-as alert-box question buttons yes-no update v-answer.
        end.
    end.
    if not v-answer
    then do:
        apply "entry" to br-list in frame {&frame-name}.
        return no-apply.
    end.
    delete-from-base:
    do
    ON ERROR UNDO delete-from-base, return no-apply
    ON stop UNDO delete-from-base, return no-apply:
        find first buf_cli-grp exclusive-lock
             where buf_cli-grp.node-code = p-node-code
        no-error.
        if error-status :error
        then do:
            undo, return error "change-grp: Нет группы БД, соответствующей значению в списке.".
        end.
        delete buf_cli-grp.
    end.
    if p-refresh = yes
    then do:
        find first buf_cli-grp no-lock
             where buf_cli-grp.node-code = v-upper-code
        no-error.
        if not available buf_cli-grp
        then do:
            undo, return error "delete-grp: Не найдена группа в БД".
        end.
        assign
            p-recid-list = string( recid( buf_cli-grp ) )
            cli-grp-row  = recid( buf_cli-grp )
        .
/*        run expand-item in this-procedure ( input buf_cli-grp.node-code, input yes ) no-error.*/
/*        if error-status :error*/
/*        then do:*/
/*            undo, return error "delete-grp: Не удается раскрыть группу.".*/
/*        end.*/
        run UI-on in this-procedure no-error .
        if error-status :error
        then do:
            undo, return error "delete-grp: Ошибка при загрузке дерева групп.".
        end.
    end.
end.
END PROCEDURE. /* delete-grp */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dlg-grp  _DEFAULT-DISABLE
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
  HIDE FRAME Dlg-grp.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dlg-grp  _DEFAULT-ENABLE
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
  DISPLAY fi-search
      WITH FRAME Dlg-grp.
  ENABLE b-exit b-mark b-sel b-add b-chg b-del b-move B-cli b-disc b-print
         B-history b-help B-rum b-expand b-expand-all fi-search
         b-find-by-full-name b-find-by-substring b-search br-list
      WITH FRAME Dlg-grp.
  VIEW FRAME Dlg-grp.
  {&OPEN-BROWSERS-IN-QUERY-Dlg-grp}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE expand-all-from-current Dlg-grp
PROCEDURE expand-all-from-current :
/*------------------------------------------------------------------------------
  Purpose:     Раскрыть всю ветку дерева, начиная с текущей группы
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.

    define variable v-full-name     as character         no-undo.
    define variable v-focused-row       as integer              no-undo.
    define variable v-repositioned-row  as integer              no-undo.

    define buffer buf_temp_cgrplib_grp       for temp_cgrplib_grp.

    assign
        v-focused-row      = br-list :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-list" )
    .
    run cli-grplib-get-full-name in this-procedure (
              input p-node-code
            , output v-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "expand-all-from-current: Ошибка вычисления полного имени группы".
    end.

    for each buf_temp_cgrplib_grp
       where buf_temp_cgrplib_grp.full-name begins v-full-name
    :
        run expand-item in this-procedure ( input buf_temp_cgrplib_grp.node-code, input no ) no-error .
        if error-status :error
        then do:
            undo, return error "expand-all-from-current: Не удалось раскрыть подуровни группы.".
        end.
    end.
    {&OPEN-BROWSERS-IN-QUERY-Dlg-grp}
    br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
    reposition br-list to row v-repositioned-row.

end.
END PROCEDURE. /* expand-all-from-current */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE expand-item Dlg-grp
PROCEDURE expand-item :
/*------------------------------------------------------------------------------
  Purpose:     Раскрыть подуровни выбранной группы (должна быть не терминальной!)
  Parameters:   p-node-code - код узла для раскрытия.
                p-refresh   - надо ли обновлять browse после раскрытия узла
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.
define input parameter p-refresh    as logical      no-undo.

    define variable v-focused-row       as integer              no-undo.
    define variable v-repositioned-row  as integer              no-undo.

    define buffer buf_cli-grp           for ub.cli-grp.
    define buffer buf_temp_cgrplib_grp   for temp_cgrplib_grp.

    assign
        v-focused-row      = br-list :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-list" )
    .
    find first buf_temp_cgrplib_grp
         where buf_temp_cgrplib_grp.node-code = p-node-code
    no-error .
    if not available buf_temp_cgrplib_grp
    then do:
        undo, return error "expand-item: Неверно задан код группы.".
    end.
    if buf_temp_cgrplib_grp.mark <> {&closed-noterminal-cgrp-mark}
    then do:
        /* Не закрытая группа, открыть невозможно. */
    end.
    else do:
        for each buf_cli-grp no-lock
           where buf_cli-grp.upper-code = p-node-code
        on error undo, return error
        :
            run create-new-line in this-procedure (
                                  input buf_cli-grp.node-code
                                , input buf_cli-grp.upper-code
                                , input buf_temp_cgrplib_grp.level + 1
                                , input buf_cli-grp.node-name
            ) no-error .
            if error-status :error
            then do:
                message
                vss-workfile vss-revision vss-description
                skip "expand-item: Ошибка добавления строки в список групп."
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
                    trim(error-status :get-message(4))
                    trim(error-status :get-message(5))
                view-as alert-box error.
                undo, return error .
            end.
        end.        /* for each buf_cli-grp */
        assign
            buf_temp_cgrplib_grp.mark = {&opened-noterminal-cgrp-mark}
            buf_temp_cgrplib_grp.name = replace( buf_temp_cgrplib_grp.name
                                            , {&closed-noterminal-cgrp-mark}
                                            , {&opened-noterminal-cgrp-mark}
                                            )
        .
        if p-refresh = yes
        then do:
            {&OPEN-BROWSERS-IN-QUERY-Dlg-grp}
            if v-focused-row > br-list :height - 2
            then do:
                assign
                    v-focused-row       = br-list :height - 2
                .
            end.
            br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
            reposition br-list to row v-repositioned-row.
        end.
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE expand-or-collapse-item Dlg-grp
PROCEDURE expand-or-collapse-item :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    case temp_cgrplib_grp.mark
    :
    when {&closed-noterminal-cgrp-mark}
    then do:
        run expand-item in this-procedure ( input temp_cgrplib_grp.node-code, input yes ) no-error .
        if error-status :error
        then do:
            undo, return error "Не удалось раскрыть подуровни группы.".
        end.
    end.
    when {&opened-noterminal-cgrp-mark}
    then do:
        run collapse-item in this-procedure ( input temp_cgrplib_grp.node-code, input yes ) no-error .
        if error-status :error
        then do:
            undo, return error "Не удалось закрыть подуровни группы.".
        end.
    end.
    end case.
end.
END PROCEDURE. /* expand-or-collapse-item */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE expand-tree-for-grp Dlg-grp
PROCEDURE expand-tree-for-grp :
/*------------------------------------------------------------------------------
  Purpose:     Раскрыть дерево групп для заданного узла
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code              as integer          no-undo.
define output parameter p-focused-row           as integer          no-undo.
define output parameter p-reposition-row        as integer          no-undo.
define output parameter p-reposition-to-recid   as logical init no  no-undo.

define variable v-full-name             as character        no-undo.

define buffer buf_temp_cgrplib_grp       for temp_cgrplib_grp.

    run cli-grplib-get-full-name in this-procedure ( input p-node-code, output v-full-name ) no-error .
    if error-status :error
    then do:
        /* Не нашли полного имени - встаем на первую группу. */
    end.
    else do:
        run cgrplib-find-grp-by-full-name in this-procedure ( input right-trim( v-full-name, {&delim-grp} ), input yes ) no-error .
        if error-status :error
        then do:
            /* Не нашли по полному имени - встаем на первую группу. */
        end.
        else do:
            process-initial-grp:
            for each temp_cgrplib_found-grp
            break by temp_cgrplib_found-grp.level
            on error undo, leave process-initial-grp :
                if last ( temp_cgrplib_found-grp.level )
                then do:
                    assign
                        p-focused-row       = integer( br-list :height in frame {&frame-name} / 2 ) + 1
                    .
                    find first buf_temp_cgrplib_grp
                         where buf_temp_cgrplib_grp.node-code = temp_cgrplib_found-grp.node-code
                    no-error .
                    if error-status :error
                    then do:
                        leave process-initial-grp.
                    end.
                    assign
                        p-reposition-row = recid( buf_temp_cgrplib_grp )
                        p-reposition-to-recid = yes
                    .
                    leave process-initial-grp.
                end.
                else do:
                    run expand-item in this-procedure ( input temp_cgrplib_found-grp.node-code, input no ) no-error .
                    if error-status :error
                    then do:
                        leave process-initial-grp.
                    end.
                    find first buf_temp_cgrplib_grp
                            where buf_temp_cgrplib_grp.node-code = temp_cgrplib_found-grp.node-code
                    no-error .
                    if error-status :error
                    then do:
                        leave process-initial-grp.
                    end.
                    assign
                        p-reposition-row = recid( buf_temp_cgrplib_grp )
                        p-reposition-to-recid = yes
                    .
                end.
            end.
        end.
    end.
end.
END PROCEDURE. /* expand-tree-for-grp */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-output-parameters-on-exit Dlg-grp
PROCEDURE fill-output-parameters-on-exit :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.

    define variable v-selected      as logical  init no  no-undo.
    define variable v-is-terminal    as logical           no-undo.

    define buffer buf_cli-grp           for ub.cli-grp.
    define buffer buf_temp_cgrplib_grp   for temp_cgrplib_grp.

    run cgrplib-is-terminal in this-procedure ( input p-node-code, output v-is-terminal ) no-error.
    if error-status :error
    then do:
        undo, return error "fill-output-parameters-on-exit: Не удается определить, корневая группа или терминальная." + {&new-line} + return-value.
    end.
    if lookup ( {&g#term}, p-button-list ) <> 0 and v-is-terminal = no
    then do:
            message "Требуется выбрать группу клиентов, в которой нет других групп.".
            apply "entry" to br-list in frame {&frame-name}.
            undo, return "no-term".
    end.
    assign
        p-recid-list = ""
    .
    for each buf_temp_cgrplib_grp
       where buf_temp_cgrplib_grp.sel = {&cselection-char}
    :
        find first buf_cli-grp no-lock
             where buf_cli-grp.node-code = buf_temp_cgrplib_grp.node-code
        no-error .
        if error-status :error
        then do:
            undo, return error "fill-output-parameters-on-exit: Не найдена запись выбранной группы '"
                                + "'" + buf_temp_cgrplib_grp.full-name + "'".
        end.
        assign
            p-recid-list = p-recid-list + ( if p-recid-list = "" then "" else "," ) + string( recid( buf_cli-grp ) )
            v-selected = yes
        .
    end.
    if v-selected = no
    then do:
        find first buf_cli-grp no-lock
             where buf_cli-grp.node-code = p-node-code
        no-error .
        if not available buf_cli-grp
        then do:
            find first buf_temp_cgrplib_grp
                 where buf_temp_cgrplib_grp.node-code = p-node-code
            no-error .
            if not available buf_temp_cgrplib_grp
            then do:
                undo, return error "fill-output-parameters-on-exit: Неверно выбрана группа с кодом "
                                    + string( p-node-code ).
            end.
            undo, return error "fill-output-parameters-on-exit: Не найдена запись выбранной группы '"
                            + buf_temp_cgrplib_grp.full-name + "'".
        end.
        assign
            p-recid-list = string( recid( buf_cli-grp ) )
        .
    end.
    assign
        cli-grp-row  = integer( entry( 1, p-recid-list ) )
    .
    assign
    v-uf-List_ = (if cli-grp-row = ? then {&question-mark} else string(cli-grp-row))
    .
    run uf-set in this-procedure(
        input  {&uf-cli-grp-p}
        ,input  v-cntxt-userid
        ,input v-uf-List_
        ,input v-uf-Naim
        ,input v-uf-print-graft
        ,input v-uf-sort-gr
        ,input v-uf-type-price
        ,input v-uf-type-val
    )  no-error .

end.
END PROCEDURE. /* fill-output-parameters-on-exit */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tt Dlg-grp
PROCEDURE fill-tt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter parnode-code like ub.cli-grp.node-code no-undo .
define input parameter parupper-code like ub.cli-grp.node-code no-undo .

end.
END PROCEDURE. /* fill-tt */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE find-grp-in-browse Dlg-grp
PROCEDURE find-grp-in-browse :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-search-grp-full-name as character    no-undo.

    define variable v-focused-row       as integer              no-undo.
    define variable v-repositioned-row  as integer              no-undo.
    define variable v-counter           as integer              no-undo.
    define variable v-level             as integer              no-undo.

    define buffer buf_temp_cgrplib_grp       for temp_cgrplib_grp.
    assign
        v-focused-row      = br-list :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-list" )
    .
    assign
    v-level = num-entries( right-trim(p-search-grp-full-name, {&delim-grp} ) , {&delim-grp})
    .
    if v-found-grp-num  <> 0       /* группу уже нашли, temp-table уже заполнен. Берем следующую из темр-table.*/
    then do:
        assign
            v-counter = 0
        .
        find first temp_cgrplib_found-grp
             where temp_cgrplib_found-grp.level = v-level
        no-error .
        if not available temp_cgrplib_found-grp
        then do:
            undo, return error "Не найдено ни одной группы уровня " + string( v-level ).
        end.
        do v-counter = 1 to v-found-grp-num
        :
            find next temp_cgrplib_found-grp
                where temp_cgrplib_found-grp.level = v-level
            no-error .
            if not available temp_cgrplib_found-grp
            then do:
                undo, return error "Не найдена следующая группа уровня " + string( v-level ).
            end.
        end.
        find first buf_temp_cgrplib_grp
                where buf_temp_cgrplib_grp.node-code = temp_cgrplib_found-grp.node-code
        no-error .
        if not available buf_temp_cgrplib_grp
        then do:
            undo, return error "Найденной группы нет в списке групп".
        end.
        {&OPEN-BROWSERS-IN-QUERY-Dlg-grp}
        br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
        reposition br-list to recid recid( buf_temp_cgrplib_grp ).
    end.        /* v-found-grp-num  <> 0 */
    else do:        /* Первый поиск */
        run cgrplib-find-grp-by-full-name (
            input fi-search :screen-value in frame {&frame-name}
            , input yes
        ) no-error.
        if error-status :error
        then do:
            undo, return error "Не удалось найти группу '" + fi-search :screen-value in frame {&frame-name} + "'".
        end.
        found-group:
        for each temp_cgrplib_found-grp no-lock
        by temp_cgrplib_found-grp.level
    /*       where temp_cgrplib_found-grp. =*/
        :
            if temp_cgrplib_found-grp.level = v-level
            then do:
                leave.
            end.
            run expand-item in this-procedure ( input temp_cgrplib_found-grp.node-code, input no ).
        end.
        find first temp_cgrplib_found-grp
            where temp_cgrplib_found-grp.level = v-level
        no-error .
        if not available temp_cgrplib_found-grp
        then do:
            undo, return error "Нет последней найденной группы для уровня " + string( v-level ).
        end.
        find first buf_temp_cgrplib_grp
            where buf_temp_cgrplib_grp.node-code = temp_cgrplib_found-grp.node-code
        no-error .
        if not available buf_temp_cgrplib_grp
        then do:
            undo, return error "Найденной группы нет в списке групп".
        end.
        {&OPEN-BROWSERS-IN-QUERY-Dlg-grp}
        br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
        reposition br-list to recid recid( buf_temp_cgrplib_grp ).
    end.        /* v-found-grp-num  = 0, т.е. первый поиск */
    find next temp_cgrplib_found-grp     /* Можно ли искать дальше? Если можно, увеличиваем счетчик поиска */
        where temp_cgrplib_found-grp.level = v-level
    no-error .
    if available temp_cgrplib_found-grp
    then do:
        assign
            v-found-grp-num  = v-found-grp-num + 1
            b-search :label = "Далее"
        .
    end.
    else do:
        assign
            v-found-grp-num  = 0
            b-search :label = "Поиск"
        .
    end.
end.
END PROCEDURE. /* find-grp-in-browse */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-current-recid Dlg-grp
PROCEDURE get-current-recid :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
define output parameter p-cli-grp-recid as recid   no-undo.

    define buffer buf_cli-grp       for ub.cli-grp.

    find first buf_cli-grp no-lock
         where buf_cli-grp.node-code = p-node-code
    no-error .
    if not available buf_cli-grp
    then do:
        undo, return error "get-current-recid: Не найдена группа." .
    end.
    assign
        p-cli-grp-recid = recid( buf_cli-grp )
    .
end.
END PROCEDURE. /* get-current-recid */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-first-char Dlg-grp
PROCEDURE get-first-char :
/*------------------------------------------------------------------------------
  Purpose:     Определение первого символа в названии: '+', '-', ' '.
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.
define output parameter p-prefix    as character    no-undo.

define variable v-name          as character    no-undo.
define variable v-is-terminal   as logical      no-undo.
define variable v-have-clients  as logical      no-undo.

define buffer buf_cli-grp               for ub.cli-grp.
define buffer buf_temp_cgrplib_grp       for temp_cgrplib_grp.


run cgrplib-is-terminal in this-procedure (
              input p-node-code
            , output v-is-terminal
) no-error .
if error-status :error
then do:
    undo, return error "get-first-char: Ошибка при определении типа группы (терм/корн).".
end.
if v-is-terminal = yes
then do:                    /* Терминальная группа */
    run cgrplib-have-clients in this-procedure ( input p-node-code, output v-have-clients ) no-error .
    if error-status :error
    then do:
        undo, return error "get-first-char: Ошибка определения наличия клиентов в группе." + {&new-line} + return-value.
    end.
    if v-have-clients = yes
    then do:
        assign
            p-prefix = {&terminal-with-clients-cgrp-mark}
        .
    end.
    else do:
        assign
            p-prefix = {&terminal-no-clients-cgrp-mark}
        .
    end.
end.        /* not available buf_cli-grp */
else do:
    find first buf_temp_cgrplib_grp no-lock
         where buf_temp_cgrplib_grp.upper-code = p-node-code
    no-error.
    if available buf_temp_cgrplib_grp
    then do:                /* группа в списке раскрыта */
        assign
            p-prefix = {&opened-noterminal-cgrp-mark}
        .
    end.
    else do:
        assign
            p-prefix = {&closed-noterminal-cgrp-mark}
        .
    end.
end.        /* available buf_cli-grp */
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-row-amount Dlg-grp
PROCEDURE get-row-amount :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define output parameter p-row-amount as integer      no-undo.

    define buffer buf_temp_cgrplib_grp       for temp_cgrplib_grp.

    for each buf_temp_cgrplib_grp
    :
        assign
            p-row-amount = p-row-amount + 1
        .
    end.
end.
END PROCEDURE. /* get-row-amount */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE move-item Dlg-grp
PROCEDURE move-item :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.   /* Группа, которую перемещаем */
define input parameter p-upper-code as integer      no-undo.   /* Группа, к которой присоединяем */

    define variable v-node-full-name    as character    no-undo.
    define variable v-upper-full-name   as character    no-undo.
    define variable v-focused-row       as integer      no-undo.
    define variable v-repositioned-row  as integer      no-undo.
    define variable v-have-clients      as logical      no-undo.

    define buffer buf_cli-grp           for ub.cli-grp.
    define buffer buf_upper_cli-grp     for ub.cli-grp.
    define buffer buf_temp_cgrplib_grp   for temp_cgrplib_grp.

    { gbl/working.i }

    run cgrplib-have-clients in this-procedure ( input p-upper-code, output v-have-clients ) no-error .
    if error-status :error
    then do:
        undo, return error "move-item: Ошибка определения наличия клиентов в группе." + {&new-line} + return-value.
    end.
    if v-have-clients = yes
    then do:
            message
                "В эту группу переместить нельзя, т.к. в одной группе"
                skip "не могут быть одновременно подгруппы и клиенты.".
            apply "entry" to br-list in frame {&frame-name}.
            return no-apply.
    end.
    run cli-grplib-get-full-name in this-procedure (
            input p-node-code
            , output v-node-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "move-item: Ошибка вычисления полного имени перемещаемой группы".
    end.
    run cli-grplib-get-full-name in this-procedure (
            input p-upper-code
            , output v-upper-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "move-item: Ошибка вычисления полного имени группы".
    end.
    if v-upper-full-name begins v-node-full-name
    then do:
        message
        "Группу нельзя переместить в ее собственную подгруппу."
        view-as alert-box.
        undo, return.
    end.

    /*find first buf_upper_cli-grp no-lock*/
    /*     where buf_upper_cli-grp.node-code = p-upper-code*/
    /*no-error .*/
    /*if not available buf_upper_cli-grp*/
    /*then do:*/
    /*    undo, return error "move-item: Не найдена родительская группа для перемещения.". */
    /*end.*/
    do transaction
    on error undo, return error "move-item: Ошибка перемещения группы.".
        find first buf_cli-grp exclusive-lock
            where buf_cli-grp.node-code = p-node-code
        no-error .
        if not available buf_cli-grp
        then do:
            undo, return error "move-item: Не найдена группа для перемещения.".
        end.
        assign
            buf_cli-grp.upper-code = p-upper-code
        .
    end.
    assign
        p-recid-list = string( recid( buf_cli-grp ) )
        cli-grp-row  = recid( buf_cli-grp )
    .
    run UI-on in this-procedure no-error .
    if error-status :error
    then do:
        undo, return error "move-item: Ошибка при загрузке дерева групп." + {&new-line} + return-value.
    end.
end.
END PROCEDURE. /* move-item */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE print-browse Dlg-grp
PROCEDURE print-browse :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable Line as character no-undo.
define variable date_string as character no-undo.
define buffer buf_temp_cgrplib_grp for temp_cgrplib_grp.

DEFINE FRAME brFrame
buf_temp_cgrplib_grp.name          format "X(71)"      column-label " Наименование группы"
buf_temp_cgrplib_grp.d-pcnt        format ">9.99"      column-label " Скидка"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 55 PAGE-NUMBER(PrnLibStream) AT 75 FORMAT ">>9" SKIP
Line format "X(79)" AT 1
with width {&A4_CW0} down stream-io use-text    .

Line = fill("-", 79).
date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&CS_PS}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).
PUT  STREAM PrnLibStream
SPACE(25) ( frame {&frame-name}:title )
format "x(90)" SKIP(1) .
FORM HEADER
Line format "X(79)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME BrFrame  .
run waitfram-show in this-procedure ("Ждите...").

FOR EACH buf_temp_cgrplib_grp :
    DISPLAY stream PrnLibStream
    buf_temp_cgrplib_grp.name
    buf_temp_cgrplib_grp.d-pcnt
    with frame BrFrame.
    DOwn stream PrnLibStream
    with frame BrFrame.
END. /*for each*/
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME BrFrame.
output  STREAM PrnLibStream CLOSE.
run waitfram-hide in this-procedure .

run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE print-grp Dlg-grp
PROCEDURE print-grp :
/*------------------------------------------------------------------------------
  Purpose:     Печать групп клиентов
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
define buffer buf_cli-grp       for ub.cli-grp.

if print-option = "":U then do:
    run gbl/pop-up.p (b-print:handle in frame {&frame-name}, no) no-error.
    if error-status:error then do:
        assign print-option = "":U.
        return no-apply.
     end.
end.
    find first buf_cli-grp no-lock
        where buf_cli-grp.node-code = p-node-code
    no-error.
    if not available buf_cli-grp
    then do:
        undo, return error "Неверно выбрана группа.".
    end.
    if print-option = "browse":U then do:
            run print-browse in this-procedure no-error.
    end.
        else do:
    run rep/r-cligrp.p ( input parparentproc, input recid( buf_cli-grp ), input print-option ) no-error .
    end.
    if error-status :error
    then do:
        assign
                print-option = "":U
                .
        undo, return error "Ошибка печати групп клиентов.".
    end.
    apply "entry" to br-list in frame {&frame-name}.
end.
END PROCEDURE. /* print-grp */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-disc Dlg-grp
PROCEDURE proc-b-disc :
define variable glog as logical no-undo .
IF not (temp_cgrplib_grp.mark = {&terminal-with-clients-cgrp-mark}
or temp_cgrplib_grp.mark = {&terminal-no-clients-cgrp-mark} ) then do:
  message
  "Скидка может быть только для терминальной группы"
  view-as alert-box error .
  undo, return error .
end.
run ref/disgrpui.w ( input parparentproc
                ,input {&update}
                ,input {&TABLE_cli-grp}
                ,input v-cntxt-host-code-obj
                ,input v-cntxt-obj-type
                ,input v-cntxt-obj-code
                ,input temp_cgrplib_grp.node-code
               ) NO-ERROR.
run cgrplib-get-pcnt-value  in this-procedure ( input temp_cgrplib_grp.node-code, output temp_cgrplib_grp.d-pcnt) no-error .
glog = br-list:refresh() in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-rum Dlg-grp
PROCEDURE proc-b-rum :
define input parameter p-rum-option as character no-undo .
define variable v-radio-button-parameter as character no-undo .
define variable v-node-code as integer no-undo .
define buffer buf_cli-grp for ub.cli-grp.
if available temp_cgrplib_grp then do:
  v-node-code = temp_cgrplib_grp.node-code.
end.
if p-rum-option = {&cli-grp-proc_xml-file-import} then do:
  v-radio-button-parameter = {&cli-grp-proc_xml-file-import}.
end.
else do:
  v-radio-button-parameter = ({&cli-grp-proc_batchwork-export} + {&comma-char} + {&cli-grp-proc_batchwork-routing}) .
end.
run str/diallog.w (
      input parParentProc
    , input this-procedure
    , input "utl/thbjrumr.w":U
    , input {&table_cli-grp} + {&delim-par} + v-radio-button-parameter /*parameter - второй элемент списка - это radio-buttons rs-ruleset d thbjrumr*/
    , input no /*p-auto-go*/
    , input "&Стоп"
    , input substitute("Операции над группами клиентов") ) no-error .
if p-rum-option = {&cli-grp-proc_xml-file-import} then do:
  if v-node-code > 0 then do:
    find first buf_cli-grp no-lock
          where buf_cli-grp.node-code = v-node-code
    no-error.
  end.
  else do:
    find first buf_cli-grp no-lock.
  end.
  if not available buf_cli-grp
  then do:
      undo, return error "proc-b-rum: Не найдена группа в БД".
  end.
  assign
  p-recid-list = string( recid( buf_cli-grp ) )
  cli-grp-row  = recid( buf_cli-grp )
  .
  run UI-on in this-procedure no-error .
  if error-status :error
  then do:
      undo, return error "proc-b-rum: Ошибка при загрузке дерева групп.".
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-and-move-item Dlg-grp
PROCEDURE select-and-move-item :
/*------------------------------------------------------------------------------
  Purpose:     Перемещение группы
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.

    define variable v-upper-code        as integer           no-undo.
    define variable v-upper-recid-list  as character         no-undo.
    define variable v-yesno             as logical           no-undo.
    define variable v-node-full-name    as character         no-undo.
    define variable v-upper-full-name   as character         no-undo.

    define buffer buf_cli-grp       for ub.cli-grp.

    if p-node-code = v-root-code
    then do:
        message
        "Корневую группу переместить невозможно."
        view-as alert-box warning.
        undo, return .
    end.
    find first buf_cli-grp no-lock
         where buf_cli-grp.node-code = p-node-code
    no-error .
    if error-status :error
    then do:
        undo, return error "select-and-move-item: Группа не найдена в базе данных.".
    end.
    assign
        v-upper-recid-list = string( recid( buf_cli-grp ) )
    .
    run ref/cli-grps.w (
        input parparentproc
      , input {&cbuttons-for-move}
      , input-output v-upper-recid-list
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка выбора группы для перемещения."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    find first buf_cli-grp no-lock
         where recid( buf_cli-grp ) = integer( entry( 1, v-upper-recid-list ) )
    no-error .
    if error-status :error
    then do:
        undo, return error "Группа не найдена.".
    end.
    run cli-grplib-get-full-name in this-procedure (  input p-node-code
                                                , output v-node-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "Ошибка вычисления полного имени перемещаемой группы.".
    end.
    run cli-grplib-get-full-name in this-procedure (  input buf_cli-grp.node-code
                                                , output v-upper-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "Ошибка вычисления полного имени новой группы".
    end.

    message
        "Переместить группу"
        skip "    '" + v-node-full-name + "'"
        skip "в группу"
        skip "    '" + v-upper-full-name + "'"
    view-as alert-box question
    buttons yes-no
    title "Перемещение группы"
    update v-yesno.
    if v-yesno = no
    then do:
        /* Отказ от перемещения группы */
    end.
    else do:
        run move-item in this-procedure ( input p-node-code
                                        , input buf_cli-grp.node-code
        ) no-error.
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка перемещения группы."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
                trim(error-status :get-message(4))
                trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return no-apply .
        end.
    end.
end.
END PROCEDURE. /* select-and-move-item */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE UI-on Dlg-grp
PROCEDURE UI-on :
/*------------------------------------------------------------------------------
  Purpose:     Заполнение temp_cgrplib_grp и инициализация при старте программы
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define variable v-reposition-row        as integer          no-undo.
define variable v-focused-row           as integer          no-undo.
define variable v-reposition-to-recid   as logical init no  no-undo.
define variable v-enable-change-grp     as logical          no-undo.
define variable v-have-clients          as logical          no-undo.
define variable v-dop                   as character        no-undo .

define buffer buf_cli-grp           for ub.cli-grp.
define buffer buf_temp_cgrplib_grp   for temp_cgrplib_grp.

{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_reference_groups-edit-cli':U
{&cntxt-firm}
v-cntxt-host-code-obj
'':U
0
0
0
0
no
v-enable-change-grp
}
run cgrplib-get-root-code in this-procedure ( output v-root-code ) no-error.
if error-status :error
then do:
    undo, return error "Не найден корневой узел." + {&new-line} + return-value.
end.
if v-from-b-cli then do:
/*ВНИМАНИЕ!!!!*/
/*здесь обработана ситуация когда пользователь зашел по кнопке КЛИЕНТЫ в справочник клиентов*/
/*если он там переключался в другие группы клиентов, то это происходило через справочник ггрупп клиентов и все настройки уже сменились*/
/*мы их получим через uf-get и на выходе из справочника КЛИЕНТОВ постараемся встать в ту группу клиентов, в которой он там стоял*/
  run uf-get in this-procedure(
      input  {&uf-cli-grp-p}
      ,input  v-cntxt-userid
      ,output v-uf-List_
      ,output v-uf-Naim
      ,output v-uf-print-graft
      ,output v-uf-sort-gr
      ,output v-uf-type-price
      ,output v-uf-type-val
  )  no-error .
  if not error-status:error then
  assign
  v-dop = string((if v-uf-List_ =  {&question-mark} then ? else integer(v-uf-LIst_)))
  .
  /*если пользователь никуда не переключался по группам клиентов в справочнике клиентов нам не надо переоткрывать броуз - стоим на месте*/
  if v-dop = v-old-recid-list then do:
    assign
    cli-grp-row = v-old-recid
    .
  end.
  else do:
    assign
    cli-grp-row = (if v-uf-List_ =  {&question-mark} then ? else integer(v-uf-LIst_))
    .
  end.
  assign
      p-recid-list = string( cli-grp-row )
  .
  assign
  v-from-b-cli = no
  v-old-recid-list = "":U.

end.
else do:
  if p-recid-list = '' then do:
  run uf-get in this-procedure(
      input  {&uf-cli-grp-p}
      ,input  v-cntxt-userid
      ,output v-uf-List_
      ,output v-uf-Naim
      ,output v-uf-print-graft
      ,output v-uf-sort-gr
      ,output v-uf-type-price
      ,output v-uf-type-val
  )  no-error .
  if not error-status:error then
  assign
  cli-grp-row = (if v-uf-List_ =  {&question-mark} then ? else integer(v-uf-LIst_))
  .
  assign
      p-recid-list = string( cli-grp-row )
  .
end.
end.

find first buf_cli-grp no-lock
   where buf_cli-grp.node-code = v-root-code
no-error .
if error-status :error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Не найдена запись корневого узла."
      skip return-value
      skip trim(error-status :get-message(1))
           trim(error-status :get-message(2))
           trim(error-status :get-message(3))
           trim(error-status :get-message(4))
           trim(error-status :get-message(5))
    view-as alert-box error.
    undo, return error .
end.
run cgrplib-have-clients in this-procedure ( input buf_cli-grp.node-code, output v-have-clients ) no-error .
if error-status :error
then do:
    undo, return error "move-item: Ошибка определения наличия клиентов в группе." + {&new-line} + return-value.
end.
for each buf_temp_cgrplib_grp
:
    delete buf_temp_cgrplib_grp.
end.
create buf_temp_cgrplib_grp.
assign
    buf_temp_cgrplib_grp.node-code   = buf_cli-grp.node-code
    buf_temp_cgrplib_grp.upper-code  = buf_cli-grp.upper-code
    buf_temp_cgrplib_grp.level       = 0
    buf_temp_cgrplib_grp.mark        = ( if v-have-clients = yes then {&terminal-with-clients-cgrp-mark} else {&terminal-no-clients-cgrp-mark} )
    buf_temp_cgrplib_grp.full-name   = {&delim-par}            /* Символ chr(1) - первый для сортировки */
    buf_temp_cgrplib_grp.sort-name   = {&delim-par}            /* Символ chr(1) - первый для сортировки */
    buf_temp_cgrplib_grp.name        = buf_cli-grp.node-name
.
for each buf_cli-grp no-lock
   where buf_cli-grp.upper-code = v-root-code
:
    run create-new-line in this-procedure (
                            input buf_cli-grp.node-code
                          , input buf_cli-grp.upper-code
                          , input 1
                          , input buf_cli-grp.node-name
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "UI-on: Ошибка добавления строки в список групп."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
end.
if p-recid-list <> "" and p-recid-list <> ?
then do:        /* Раскрыть ветку группы с recid-ом из списка */
  if lookup("b-mark", p-button-list) > 0 then do:
    define variable v-ii as integer no-undo .
    assign
        v-reposition-row = 1
        v-focused-row    = 1
    .
    do v-ii = 1 to num-entries(p-recid-list):
    find first buf_cli-grp no-lock
          where recid( buf_cli-grp ) = integer( entry( v-ii, p-recid-list ) )
    no-error .
    if not available buf_cli-grp
    then do:
        /* Не найдена группа, выбранная в прошлый раз. */
    end.
    else do:
        run expand-tree-for-grp in this-procedure (
            input buf_cli-grp.node-code
            , output v-focused-row
            , output v-reposition-row
            , output v-reposition-to-recid
        ) no-error .
        if error-status :error
        then do:
            undo, return error "UI-on: Не удалось раскрыть дерево групп." + {&new-line} + return-value.
        end.
        run b-mark-press ( input buf_cli-grp.node-code ) no-error .
    end.
end.
  end. /*if lookup("b-mark", p-button-list) > 0 then do:*/
  else do:
    assign
        v-reposition-row = 1
        v-focused-row    = 1
.
    find first buf_cli-grp no-lock
         where recid( buf_cli-grp ) = integer( entry( num-entries( p-recid-list ), p-recid-list ) )
    no-error .
    if not available buf_cli-grp
    then do:
        /* Не найдена группа, выбранная в прошлый раз. */
    end.
    else do:
        run expand-tree-for-grp in this-procedure (
            input buf_cli-grp.node-code
            , output v-focused-row
            , output v-reposition-row
            , output v-reposition-to-recid
        ) no-error .
        if error-status :error
        then do:
            undo, return error "UI-on: Не удалось раскрыть дерево групп." + {&new-line} + return-value.
        end.
    end.
  end. /*else if lookup("b-mark", p-button-list) > 0 then do:*/
end. /*if p-recid-list <> "" and p-recid-list <> ?*/
ASSIGN
b-print:MENU-MOUSE in frame {&frame-name} =  1.
run enable_UI.
if not valid-handle (parparentproc)
or v-is-deploy
then
disable b-print with frame {&frame-name} .
hide    b-sel       in frame {&frame-name}
        b-mark      in frame {&frame-name}
        b-add       in frame {&frame-name}
        b-chg       in frame {&frame-name}
        b-disc      in frame {&frame-name}
        b-del       in frame {&frame-name}
        b-move      in frame {&frame-name}
.

if lookup({&cbuttons-for-s-deploy}, p-button-list) > 0 then do:
  assign
  v-is-deploy  = yes
  p-button-list = trim(replace(p-button-list, {&cbuttons-for-s-deploy}, '':U), {&comma-char}).
end.
case p-button-list
:
when {&cbuttons-for-move}
then do:
    disable
        b-exit    with frame {&frame-name}
    .
    view
        b-sel    in frame {&frame-name}
    .
end.
when {&cbuttons-for-admin}
then do:
    view
        b-add    in frame {&frame-name}
        b-chg in frame {&frame-name}
        b-disc in frame {&frame-name}
        b-del in frame {&frame-name}
        b-move   in frame {&frame-name}
    .
    if v-enable-change-grp = no
    then do:
        disable
            b-add
            b-chg
            b-disc
            b-del
            b-move
        with frame {&frame-name}.
    end.
end.
when {&cbuttons-sel-term} or when {&cbutton-sel-only}
then do:
    view
        b-sel    in frame {&frame-name}
    .
end.
when {&cbuttons-sel-mark}
then do:
    view
        b-sel    in frame {&frame-name}
        b-mark in frame {&frame-name}
    .
end.
end case.
assign
menu-item m_selected:sensitive  in menu menu-b-rum = (b-mark:sensitive in frame {&frame-name} and b-mark:visible in frame {&frame-name})
menu-item m_selected_plus_childs:sensitive  in menu menu-b-rum = (b-mark:sensitive in frame {&frame-name} and b-mark:visible in frame {&frame-name})
.

br-list :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame {&FRAME-NAME}.
if v-reposition-to-recid = no
then do:
    reposition br-list to row v-reposition-row.
end.
else do:
    reposition br-list to recid v-reposition-row.
end.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
