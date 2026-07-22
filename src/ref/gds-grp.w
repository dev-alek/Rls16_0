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

Управление деревом групп

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */


define input parameter parparentproc        as handle           no-undo.
define input parameter p-button-list        as character        no-undo. /* список включенных кнопок */
define input parameter p-current-obj-type   as character        no-undo.
define input parameter p-current-obj-code   as integer          no-undo.
define input-output parameter p-recid-list  as character        no-undo.

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Управление деревом групп".
{ cmp/vssrevis.i                        }
{ cmp/trg-def.i                         }
{ cmp/showinf.i                         }
{ ref/grplib.i                          }
{ ref/grpobj.i                          }
{ cmp/library.i                         }
{ gbl/cur-time.i                        }
{ str/tt-tax.i "NEW SHARED" tt-tax full }
{ str/tt-tax.i new output-tax full      }
{ cmp/r-pril.i new                      }
{ gbl/waitfram.i                        }
{ gbl/usr-flt.i                         }
{ ref/grp-attr.i                        }
{ gbl/prn-lib.i                         }
{ gbl/getcntxt.i def                    }

{ gbl/ggoattr.i  }

if p-button-list <> {&buttons-for-move}
then do:
    define new shared temp-table tt-goods no-undo like ub.goods.
    define new shared temp-table tt-clients no-undo like ub.clients.
end.

define variable v-root-code                 as integer          no-undo.
define variable v-found-grp-num             as integer  init 0  no-undo.
define variable v-full-search-string        as character        no-undo.
define variable v-full-search-next          as logical  init no no-undo.
define variable v-full-search-start-code    as integer          no-undo.
define variable v-cli-name                  as character        no-undo.
define variable print-option as character no-undo.
define variable gds-grp-row as integer init 1 no-undo.  /* текущая запись gds-grp для перерисовки дерева */
define variable v-from-b-gds as logical no-undo .
define variable v-old-recid-list as character no-undo .
define variable v-old-recid as recid no-undo .

define variable v-current-arm-code          as character    no-undo.
define variable v-current-store-type        as character    no-undo.
define variable v-current-store-code        as integer      no-undo.
define variable v-current-host-code         as integer      no-undo.

define variable is-flora     as character no-undo .   /* для чтения параметра конфигурации */
define variable par-type     as character no-undo.    /* тип параметра конфигурации */
define variable v-obj-host-code as integer   no-undo . /* для чтения параметра конфигурации */
DEFINE VARIABLE rum-option   AS CHARACTER NO-UNDO.
define variable v-before-dop as character no-undo .
define variable v-button-sel-clicked as logical no-undo init false. /* устанавливается в true, когда нажата кнопка Выбор */

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
&Scoped-define INTERNAL-TABLES temp_grplib_grp

/* Definitions for BROWSE br-list                                       */
&Scoped-define FIELDS-IN-QUERY-br-list temp_grplib_grp.sel no-label temp_grplib_grp.nabor temp_grplib_grp.name temp_grplib_grp.print-code temp_grplib_grp.calc-method temp_grplib_grp.increase-pc temp_grplib_grp.min-marg temp_grplib_grp.max-marg temp_grplib_grp.round-method if temp_grplib_grp.notcorr = 'yes' then "да" else "" string(temp_grplib_grp.cli-type + ' ' + string(temp_grplib_grp.cli-code,">>>>>")) @ v-cli-name temp_grplib_grp.node-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-list
&Scoped-define SELF-NAME br-list
&Scoped-define QUERY-STRING-br-list FOR EACH temp_grplib_grp NO-LOCK by temp_grplib_grp.sort-name
&Scoped-define OPEN-QUERY-br-list OPEN QUERY {&SELF-NAME} FOR EACH temp_grplib_grp NO-LOCK by temp_grplib_grp.sort-name.
&Scoped-define TABLES-IN-QUERY-br-list temp_grplib_grp
&Scoped-define FIRST-TABLE-IN-QUERY-br-list temp_grplib_grp


/* Definitions for DIALOG-BOX Dlg-grp                                   */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dlg-grp ~
    ~{&OPEN-QUERY-br-list}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-mark b-scales b-sel b-marg b-print ~
B-history b-help b-add b-chg b-del b-move b-arch b-tax B-gds B-nabor B-rum ~
b-expand b-expand-all fi-search b-find-by-full-name b-find-by-substring ~
b-search br-list
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

DEFINE BUTTON b-arch
     LABEL "&Архив"
     SIZE 10 BY 1 TOOLTIP "Информация по товарам группы"
     BGCOLOR 8 .

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1 TOOLTIP "Изменить название и характеристики группы"
     BGCOLOR 8 .

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 11 BY 1 TOOLTIP "Удалить группу"
     BGCOLOR 8 .

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

DEFINE BUTTON B-gds
     LABEL "&Товары"
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1 TOOLTIP "Помощь"
     BGCOLOR 8 .

DEFINE BUTTON B-history
     LABEL "Ис&тория"
     SIZE 10 BY 1.

DEFINE BUTTON b-marg
     LABEL "Па&раметры на объектах"
     SIZE 32 BY 1 TOOLTIP "Диапазон наценок и наценка по умолчанию на группу товаров"
     BGCOLOR 8 .

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-move
     LABEL "П&еренести"
     SIZE 11 BY 1 TOOLTIP "Переместить группу"
     BGCOLOR 8 .

DEFINE BUTTON B-nabor
     LABEL "Н"
     SIZE 3.8 BY 1 TOOLTIP "Отметить группу как набор или снять пометку".

DEFINE BUTTON b-print
     LABEL "Пе&чать"
     SIZE 10 BY 1 TOOLTIP "Печать списка групп".

DEFINE BUTTON B-rum
     LABEL "&Операции над группами"
     SIZE 30 BY 1.

DEFINE BUTTON b-scales
     LABEL "В&есы"
     SIZE 10 BY 1 TOOLTIP "Привязка группы к весам"
     BGCOLOR 8 .

DEFINE BUTTON b-search
     LABEL "Поиск"
     SIZE 10 BY 1.03
     BGCOLOR 8 .

DEFINE BUTTON b-sel
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-tax
     LABEL "&Налоги"
     SIZE 10 BY 1 TOOLTIP "Налоги для группы товаров"
     BGCOLOR 8 .

DEFINE VARIABLE fi-search AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 69.8 BY 1
     FGCOLOR 1  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-list FOR
      temp_grplib_grp SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-list Dlg-grp _FREEFORM
  QUERY br-list DISPLAY
      temp_grplib_grp.sel           format "X(1)" no-label
      temp_grplib_grp.nabor         format "X(1)" label "Н"
      temp_grplib_grp.name          format "X(71)"      label " Наименование группы"
      temp_grplib_grp.print-code    format "X(20)"      label " Код"
      temp_grplib_grp.calc-method   format "X(11)"      label " Исходная"
      temp_grplib_grp.increase-pc   format "->>>>9.99"  label " Наценка"
      temp_grplib_grp.min-marg      format "X(10)"  label " Мин.Нац."
      temp_grplib_grp.max-marg      format "X(10)"  label " Макс.Нац."
      temp_grplib_grp.round-method  format "X(22)"  label " Метод округления"
      if temp_grplib_grp.notcorr = 'yes'  then "да" else ""  format "X(17)"  label "Запрет кор.заказ"
      string(temp_grplib_grp.cli-type + ' ' + string(temp_grplib_grp.cli-code,">>>>>")) @ v-cli-name format "X(12)" label "Вн.Поставщик"
      temp_grplib_grp.node-code     FORMAT ">>>>>>>>>>9" LABEL "Вн №"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.5 BY 16.63.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dlg-grp
     b-exit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 11
     b-scales AT ROW 1 COL 14
     b-sel AT ROW 1 COL 24
     b-marg AT ROW 1 COL 34
     b-print AT ROW 1 COL 66
     B-history AT ROW 1 COL 76
     b-help AT ROW 1 COL 86
     b-add AT ROW 2 COL 24
     b-chg AT ROW 2 COL 34
     b-del AT ROW 2 COL 44
     b-move AT ROW 2 COL 55
     b-arch AT ROW 2 COL 66
     b-tax AT ROW 2 COL 76
     B-gds AT ROW 2 COL 86
     B-nabor AT ROW 2 COL 96.1
     B-rum AT ROW 3 COL 66 WIDGET-ID 2
     b-expand AT ROW 4.07 COL 1.6
     b-expand-all AT ROW 4.07 COL 5.1
     fi-search AT ROW 4.07 COL 13.4 NO-LABEL
     b-find-by-full-name AT ROW 4.07 COL 83.4
     b-find-by-substring AT ROW 4.07 COL 86.4
     b-search AT ROW 4.07 COL 89.4
     br-list AT ROW 5.37 COL 1.9
     SPACE(0.59) SKIP(0.12)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Группы товаров".


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
OPEN QUERY {&SELF-NAME} FOR EACH temp_grplib_grp NO-LOCK by temp_grplib_grp.sort-name.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-list */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dlg-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dlg-grp Dlg-grp
ON ENDKEY OF FRAME Dlg-grp /* Группы товаров */
DO:
    run gbl/markqwa.p (
                           input b-mark:visible
                          , input p-recid-list) no-error.
    if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dlg-grp Dlg-grp
ON WINDOW-CLOSE OF FRAME Dlg-grp /* Группы товаров */
DO:
  if not v-button-sel-clicked then
    p-recid-list = "".
  apply "end-error":U to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dlg-grp
ON CHOOSE OF b-add IN FRAME Dlg-grp /* Добавить */
DO:
    run add-grp in this-procedure (
        input temp_grplib_grp.node-code
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка добавления группы товаров."
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


&Scoped-define SELF-NAME b-arch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-arch Dlg-grp
ON CHOOSE OF b-arch IN FRAME Dlg-grp /* Архив */
DO:
    run press-arch ( input temp_grplib_grp.node-code ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка получения архивной информации по группе."
        skip return-value
        skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        trim(error-status :get-message(4))
        trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    apply "entry" to br-list in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dlg-grp
ON CHOOSE OF b-chg IN FRAME Dlg-grp /* Изменить */
DO:
    run change-grp in this-procedure (
        input temp_grplib_grp.node-code
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка изменения группы товаров."
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


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dlg-grp
ON CHOOSE OF b-del IN FRAME Dlg-grp /* Удалить */
DO:
    run delete-grp in this-procedure (
          input temp_grplib_grp.node-code
        , input yes
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка удаления группы товаров."
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


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dlg-grp
ON CHOOSE OF b-exit IN FRAME Dlg-grp /* Выход */
DO:
    define variable v-gds-grp-recid     as recid             no-undo.
    run get-current-recid in this-procedure (
          input temp_grplib_grp.node-code
        , output v-gds-grp-recid
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
        gds-grp-row  = v-gds-grp-recid
        p-recid-list = ""
    .
    assign
    v-uf-List_ = (if gds-grp-row = ? then {&question-mark} else string(gds-grp-row))
    .
    run uf-set in this-procedure(
        input  {&uf-gds-grp-p}
        ,input  g#userid
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
    if temp_grplib_grp.node-code = v-root-code
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
    if temp_grplib_grp.mark <> {&closed-noterminal-grp-mark}
    and temp_grplib_grp.mark <> {&opened-noterminal-grp-mark}
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
    { gbl/working.i }
    run expand-all-from-current in this-procedure (
        input temp_grplib_grp.node-code
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
        { gbl/stopwork.i }
        undo, return no-apply .
    end.
    { gbl/stopwork.i }
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-find-by-full-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-find-by-full-name Dlg-grp
ON CHOOSE OF b-find-by-full-name IN FRAME Dlg-grp /* + */
DO:
    define variable v-new-name as character no-undo.

    run grplib-expand-name in this-procedure (
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
    define variable v-new-name      as character    no-undo.
    define variable v-new-code      as integer      no-undo.
    define variable v-err-message   as character    no-undo.

    if v-full-search-next = no
    then do:
        assign
            v-full-search-string     = fi-search :screen-value
            v-full-search-next       = yes
            v-full-search-start-code = 0
        .
    end.
    run grplib-analyze-grp-name in this-procedure (
          input v-full-search-string
        , input -1
        , output v-err-message
    ).
    if v-err-message = "":U
    then do:
        { gbl/working.i }
        run grplib-find-by-substring in this-procedure (
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
    end.        /* if v-err-message = "":U */
    else do:
        message
            v-err-message
            skip(1)
            "Поиск в названиях групп производится по подстроке,"
            skip "введённой в поле названия группы."
        view-as alert-box information.
    end.        /* if v-err-message <> "":U */
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


&Scoped-define SELF-NAME B-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-gds Dlg-grp
ON CHOOSE OF B-gds IN FRAME Dlg-grp /* Товары */
DO:
  define variable rec-list          as character    no-undo.
  define variable v-grp-list        as character    no-undo.
  define variable v-gds-grp-recid   as recid        no-undo.

  define buffer buf_gds-grp for ub.gds-grp.

  IF AVAILABLE temp_grplib_grp THEN DO:
    RUN grplib-get-full-name in this-procedure ( input temp_grplib_grp.node-code, output v-grp-list) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Не найдена группа для показа"
          skip "справочника товаров."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
  find first buf_gds-grp no-lock where
            buf_gds-grp.node-code = temp_grplib_grp.node-code no-error.
  assign
  v-old-recid = (if available buf_gds-grp then recid(buf_gds-grp) else ?)
  v-old-recid-list = p-recid-list
  v-from-b-gds = yes.
  .
  run uf-get in this-procedure(
      input  {&uf-gds-grp-p}
      ,input  g#userid
      ,output v-uf-List_
      ,output v-uf-Naim
      ,output v-uf-print-graft
      ,output v-uf-sort-gr
      ,output v-uf-type-price
      ,output v-uf-type-val
  )  no-error .
  if not error-status:error then
  assign
  v-before-dop = string((if v-uf-List_ =  {&question-mark} then ? else integer(v-uf-LIst_)))
  .
  run ref/gds-ref.p (
                  input parparentproc
                 ,input "":U
                 ,input ?               /*p-stat */
                 ,input {&group}        /*p-list  */
                 ,input ?               /*p-cond  */
                 ,input ?               /*p-rec   */
                 ,input v-grp-list       /*p-grp   */
                 ,input ?               /*p-cli-type */
                 ,input ?               /*p-cli-code  */
                 ,input v-current-store-type      /*p-obj-type  */
                 ,input v-current-store-code       /*p-obj-code  */
                 ,input ?               /*p-other     */
                 ,output rec-list).
  v-old-recid = ?.
 END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-history
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-history Dlg-grp
ON CHOOSE OF B-history IN FRAME Dlg-grp /* История */
DO:
  define variable rid-list as character no-undo .
    if available temp_grplib_grp THEN
   run ref/cggrphis.w (
                     input parparentproc
                    ,INPUT "":U /* bttns */
                    ,INPUT "gds-grp":U /*parref-mode */
                    ,INPUT temp_grplib_grp.node-code
                     , "":U /*p-attr-code*/
                     , INPUT 0
                     , INPUT "":U /*p-obj-type*/
                     , INPUT 0 /*p-obj-code*/
                     , INPUT 0 /*p-tax-code*/
                     , INPUT NO
                     ,input "":U /*p-subject*/
                      ,OUTPUT rid-list
       ) .
    apply "entry" to br-list.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-marg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-marg Dlg-grp
ON CHOOSE OF b-marg IN FRAME Dlg-grp /* Параметры на объектах */
DO:
    run fill-marg in this-procedure ( input temp_grplib_grp.node-code ) no-error.
    if error-status:error
    then do:
        return no-apply.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dlg-grp
ON CHOOSE OF b-mark IN FRAME Dlg-grp /* * */
DO:
    run b-mark-press ( input temp_grplib_grp.node-code ) no-error .
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
            input temp_grplib_grp.node-code
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


&Scoped-define SELF-NAME B-nabor
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-nabor Dlg-grp
ON CHOOSE OF B-nabor IN FRAME Dlg-grp /* Н */
DO:

    define buffer buf_gds-grp for ub.gds-grp.

    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = temp_grplib_grp.node-code
    no-error.
    if not available buf_gds-grp
    then do:

        message
          vss-workfile vss-revision vss-description
          skip "Неверно выбрана группа."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.

define variable v-value       as character  no-undo.      /* значение атрибута */
define variable v-type        as character  no-undo.      /* тип атрибута      */
define variable v-del as logical   no-undo .


  run grp-attr-value (
     input   temp_grplib_grp.node-code       /* код группы   */
    ,input   {&attr-gds-grp-nabor-h}         /* код атрибута */
    ,input   0                               /* код фирмы    */
    ,input   ""
    ,input   0
    ,output  v-value
    ,output  v-type       ) .


  if v-value = "yes" then  do:
      message "Снять с группы: "  temp_grplib_grp.full-name skip "признак НАБОР ? "
      view-as alert-box question buttons yes-no update v-ok as log.
      if v-ok = false then do:
         return .
         end.
      run waitfram-show ("Ждите...") .
      temp_grplib_grp.nabor = "" .
       run grp-attr-delete (
       input   temp_grplib_grp.node-code       /* код группы   */
      ,input   {&attr-gds-grp-nabor-h}         /* код атрибута */
      ,input   0                               /* код фирмы    */
      ,input   ""
      ,input   0
      ,output  v-del ) .
  end.
  else do:
      message "Проставить на группу: "  temp_grplib_grp.full-name skip "признак НАБОР ? "
      view-as alert-box question buttons yes-no update v-ok1 as log.
      if v-ok1 = false then do:
        return .
        end.
      run waitfram-show ("Ждите...") .
      temp_grplib_grp.nabor = "+".
       run grp-attr-write (
       input   temp_grplib_grp.node-code       /* код группы   */
      ,input   {&attr-gds-grp-nabor-h}         /* код атрибута */
      ,input   0                               /* код фирмы    */
      ,input   ""
      ,input   0
      ,input   "yes"   ) .
  end.
  browse br-list:refresh().
  run waitfram-hide.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dlg-grp
ON CHOOSE OF b-print IN FRAME Dlg-grp /* Печать */
DO:
    run print-grp in this-procedure ( input temp_grplib_grp.node-code ) no-error .
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


&Scoped-define SELF-NAME b-scales
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-scales Dlg-grp
ON CHOOSE OF b-scales IN FRAME Dlg-grp /* Весы */
DO:
    run bind-to-scales in this-procedure (
        input temp_grplib_grp.node-code
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка привязки группы товаров к весам."
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


&Scoped-define SELF-NAME b-search
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-search Dlg-grp
ON CHOOSE OF b-search IN FRAME Dlg-grp /* Поиск */
DO:
    define variable v-found    as logical      no-undo.

    run find-grp-in-browse in this-procedure (
          input fi-search :screen-value
        , output v-found
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
    if v-found = no
    then do:
        message
          skip "Группа не найдена."
        view-as alert-box information.
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
    
    v-button-sel-clicked = true.
    run fill-output-parameters-on-exit in this-procedure ( input temp_grplib_grp.node-code ) no-error .
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


&Scoped-define SELF-NAME b-tax
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-tax Dlg-grp
ON CHOOSE OF b-tax IN FRAME Dlg-grp /* Налоги */
DO:
    define buffer buf_gds-grp for ub.gds-grp.

    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = temp_grplib_grp.node-code
    no-error.
    if not available buf_gds-grp
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Неверно выбрана группа."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    run fill-tt in this-procedure ( input buf_gds-grp.node-code, input buf_gds-grp.upper-code ) no-error.
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка заполнения временной таблицы для налогов"
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        return no-apply.
    end.
    run proc-b-tax in this-procedure (
          input parparentproc
        , input v-current-host-code
        , input v-current-store-type
        , input v-current-store-code
        , buffer buf_gds-grp
        , input {&lookup}
    ) no-error.
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка вычисления налогов."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        return no-apply.
    end.
    run fill-db in this-procedure ( input buf_gds-grp.node-code, input buf_gds-grp.upper-code ) no-error.
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка изменения налогов."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        return no-apply.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-list
&Scoped-define SELF-NAME br-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-list Dlg-grp
ON + OF br-list IN FRAME Dlg-grp
DO:
    if temp_grplib_grp.mark = {&closed-noterminal-grp-mark}
    then do:
        run expand-item in this-procedure ( input temp_grplib_grp.node-code, input yes ) no-error .
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
    if temp_grplib_grp.mark = {&opened-noterminal-grp-mark}
    then do:
        run collapse-item in this-procedure ( input temp_grplib_grp.node-code, input yes ) no-error .
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
            input temp_grplib_grp.node-code
            , input yes
        ) no-error .
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка удаления группы товаров."
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
            input temp_grplib_grp.node-code
        ) no-error .
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка добавления группы товаров."
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
    if temp_grplib_grp.mark <> {&closed-noterminal-grp-mark}
    and temp_grplib_grp.mark <> {&opened-noterminal-grp-mark}
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
    if temp_grplib_grp.mark <> {&closed-noterminal-grp-mark}
    and temp_grplib_grp.mark <> {&opened-noterminal-grp-mark}
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
    if temp_grplib_grp.level <> 0
    then do:
        assign
            fi-search :screen-value = right-trim( temp_grplib_grp.full-name, {&delim-grp} )
        .
    end.
    run enable-button-marg in this-procedure ( input temp_grplib_grp.node-code ) no-error.
    if error-status :error
    then do:
        DISABLE b-marg   with FRAME {&frame-name}.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-search
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-search Dlg-grp
ON CTRL-D OF fi-search IN FRAME Dlg-grp
DO:
    define variable v-new-name as character no-undo.

    run grplib-expand-name in this-procedure (
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
    run grplib-find-by-substring in this-procedure (
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
    define variable v-found    as logical      no-undo.

    if fi-search :screen-value = ""
    or fi-search :screen-value = ?
    then do:        /* Ничего не делать, если строка поиска пуста. */
        return no-apply.
    end.
    run find-grp-in-browse in this-procedure (
          input fi-search :screen-value
        , output v-found
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка поиска группы."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if v-found = no
    then do:
        message
          skip "Группа не найдена."
        view-as alert-box information.
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
  run print-grp in this-procedure(input temp_grplib_grp.node-code)  no-error.
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
  run print-grp in this-procedure(input temp_grplib_grp.node-code) no-error.
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
  run print-grp in this-procedure(input temp_grplib_grp.node-code) no-error.
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
  rum-option = {&gds-grp-proc_xml-file-import}.
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
{ ref/dtaxgrpr.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

    { gbl/getcntxt.i get }
/*  RUN enable_UI. */
    if p-current-obj-code = 0
    then do:
       assign
       v-current-store-type = v-cntxt-obj-type
       v-current-store-code = v-cntxt-obj-code
       v-current-host-code = v-cntxt-host-code-obj
       .
    end.
    else do:
        assign
            v-current-store-type = p-current-obj-type
            v-current-store-code = p-current-obj-code
        .
        { gbl/hostcode.i
            v-current-store-type
            v-current-store-code
            v-current-host-code
        }
    end.
    run grplib-get-parameters in this-procedure (
          input v-current-store-type
        , input v-current-store-code
    ) no-error.
    if error-status :error
    then do:
        message
            "Ошибка чтения параметров для списка групп товаров."
            skip (1)
            "Для параметров списка будут приняты значения по умолчанию."
        view-as alert-box warning.
    end.
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

    { gbl/conf-rd.i "'is-flora'" v-current-host-code v-current-store-type v-current-store-code "''" "''" "''" no is-flora par-type no-error} .
    if is-flora = 'no' then do:
       hide b-nabor in frame {&frame-name}.
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

    define variable v-gds-grp-recid     as recid    no-undo.
    define variable v-focused-row       as integer  no-undo.
    define variable v-repositioned-row  as integer  no-undo.
    define variable v-have-goods        as logical  no-undo.
    define variable v-have-rights       as logical       no-undo.

    define buffer buf_gds-grp           for ub.gds-grp.
    define buffer buf_temp_grplib_grp   for temp_grplib_grp.

    run check-rights-for-change-grp in this-procedure (  p-node-code
        , output v-have-rights
    ) no-error.
    if error-status :error
    or v-have-rights = no
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Нет прав на изменение справочника групп товаров."
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
    run grplib-have-goods in this-procedure (
          input p-node-code
        , output v-have-goods
    ) no-error .
    if error-status :error
    then do:
        undo, return error "add-grp: Ошибка определения наличия товаров в группе." + {&new-line} + return-value.
    end.
    if v-have-goods = yes
    then do:
        message "В данной группе есть товары. Добавить в нее подгруппу,"
                "включающую эти товары ?"
        view-as alert-box question
        buttons OK-Cancel
        update v-yesno as logical.
        if v-yesno = no
        then do:
            apply "entry" to br-list in frame {&frame-name}.
            return no-apply.
        end.
    end.
    find first buf_temp_grplib_grp
         where buf_temp_grplib_grp.node-code = p-node-code
    no-error .
    if not available buf_temp_grplib_grp
    then do:
        undo, return error "add-grp: Не найдена группа в browse.".
    end.
    if buf_temp_grplib_grp.mark = {&closed-noterminal-grp-mark}
    then do:
        run expand-item in this-procedure ( input p-node-code, input no ) no-error.
        if error-status :error
        then do:
            undo, return error "add-grp: Не удается раскрыть группу.".
        end.
    end.
    run ref/g-grp-f.w (
          input parparentproc
        , input v-current-store-type
        , input v-current-store-code
        , input {&add-def}
        , input p-node-code
        , input-output v-gds-grp-recid
    ) no-error .
    if v-gds-grp-recid = ?
    then do:
        apply "entry" to br-list in frame {&frame-name}.
        return no-apply.
    end.
    find first buf_gds-grp
         where recid ( buf_gds-grp ) =  v-gds-grp-recid
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "add-grp: Ошибка добавления группы.".
    end.
    assign
            p-recid-list = string( recid( buf_gds-grp ) )
            gds-grp-row  = recid( buf_gds-grp )
        .
    run ui-on in this-procedure no-error.
    if error-status :error
    then do:
        undo, return error "add-grp: Ошибка при загрузке дерева групп.".
    end.
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

    define buffer buf_temp_grplib_grp       for temp_grplib_grp.
    define buffer buf_upper_temp_grplib_grp for temp_grplib_grp.

    find first buf_temp_grplib_grp
         where buf_temp_grplib_grp.node-code = p-node-code
    no-error .
    if not available buf_temp_grplib_grp
    then do:
        undo, return error "b-mark-press: Ошибка поиска группы".
    end.
    assign
        v-focused-row      = br-list :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-list" )
    .
    if buf_temp_grplib_grp.sel = {&selection-char}
    or (p-button-list <> {&buttons-actn-sel-mark} and p-node-code = v-root-code)
    then do:
        /* снимаем отметку */
        assign
            buf_temp_grplib_grp.sel = ""
        .
    end.
    else do:
        /* ставим отметку */
        assign
            buf_temp_grplib_grp.sel = {&selection-char}
        .
        /* снимаем все отметки выше по дереву */
        for each buf_upper_temp_grplib_grp
            where buf_upper_temp_grplib_grp.level < buf_temp_grplib_grp.level
              and buf_upper_temp_grplib_grp.full-name = substring( buf_temp_grplib_grp.full-name, 1
                                                        , length( buf_upper_temp_grplib_grp.full-name ) )
        :
            assign
                buf_upper_temp_grplib_grp.sel = ""
            .
        end.
        /* снимаем все отметки ниже по дереву */
        for each buf_upper_temp_grplib_grp
            where buf_upper_temp_grplib_grp.node-code <> buf_temp_grplib_grp.node-code
              and buf_upper_temp_grplib_grp.full-name begins buf_temp_grplib_grp.full-name + {&slash-char}
        :
            assign
                buf_upper_temp_grplib_grp.sel = ""
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE bind-to-scales Dlg-grp
PROCEDURE bind-to-scales :
/*------------------------------------------------------------------------------
  Purpose:     Привязать группу товаров к весам
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.

    define variable v-is-terminal   as logical           no-undo.

    run grplib-is-terminal (  input p-node-code
                            , output v-is-terminal
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка при определении типа группы (терм/корн)"
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            trim(error-status :get-message(4))
            trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.

    if v-is-terminal = no
    then do:
        message
            "Требуется выбрать самую подробную группу товаров,"
            skip "в которой НЕТ других групп."
        view-as alert-box information .
        apply "entry" to br-list in frame {&frame-name}.
        return no-apply.
    end.
    run ref/scal-grp.w (
          input parparentproc
        , input 'b-add'
        , input v-current-store-type
        , input v-current-store-code
        , input ({&table_db} + {&comma-char} + {&table_gds-grp})
        , input g#db-num
        , input 0
        , input p-node-code
    ) no-error .
    if error-status :error
    then do:
        undo, return error return-value.
    end.
end.
END PROCEDURE. /* bind-to-scales */

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

    define variable v-gds-grp-recid     as recid        no-undo.
    define variable v-focused-row       as integer      no-undo.
    define variable v-repositioned-row  as integer      no-undo.
    define variable v-have-rights       as logical      no-undo.
    define variable v-margins-range     as integer      no-undo.
    define variable v-margins-exists    as logical      no-undo.
    define variable v-increase-range     as integer     no-undo.
    define variable v-increase-exists    as logical     no-undo.
    define variable v-min-marg          as decimal      no-undo.
    define variable v-max-marg          as decimal      no-undo.
    define variable v-increase-pc       as decimal      no-undo.
    define variable v-old-full-name     as character    no-undo.
    define variable v-round-method      as character   no-undo .
    define variable v-base              as decimal     no-undo .
    define variable v-rmethod-range     as integer     no-undo.
    define variable v-rmethod-exists    as logical     no-undo.

    define variable  v-cli-type         as character no-undo .
    define variable  v-notcorr         as character no-undo .
    define variable  v-notcorr-range  as integer no-undo .
    define variable  v-notcorr-exists as logical no-undo .

    define variable  v-cli-code         as integer no-undo .
    define variable  v-income-cli-range  as integer no-undo .
    define variable  v-income-cli-exists as logical no-undo .


    define buffer buf_gds-grp               for ub.gds-grp.
    define buffer buf_temp_grplib_grp       for temp_grplib_grp.
    define buffer buf_child_temp_grplib_grp for temp_grplib_grp.

    run check-rights-for-change-grp in this-procedure (p-node-code,
        output v-have-rights
    ) no-error.
    if error-status :error
    or v-have-rights = no
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Нет прав на изменение справочника групп товаров."
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
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if error-status :error
    then do:
        undo, return error "change-grp: Неверный выбор группы.".
    end.
    assign
        v-gds-grp-recid = recid( buf_gds-grp )
    .
    run ref/g-grp-f.w (
          input parparentproc
        , input v-current-store-type
        , input v-current-store-code
        , input {&update}
        , input p-node-code
        , input-output v-gds-grp-recid
    ).
    if v-gds-grp-recid = ?
    then do:
        find first buf_temp_grplib_grp
            where buf_temp_grplib_grp.node-code = p-node-code
        no-error.
        if not available buf_temp_grplib_grp
        then do:
            undo, return error "change-grp: Ошибка поиска группы в списке.".
        end.
        if v-grplib-not-fill-extra-info = yes
        then do:
            assign
                v-margins-exists    = no
                v-increase-exists   = no
                v-rmethod-exists    = no
            .
        end.
        else do:
            run grp-obj-margin-value in this-procedure (
                                  input p-node-code
                                , input v-current-store-type
                                , input v-current-store-code
                                , output v-min-marg
                                , output v-max-marg
                                , output v-increase-pc
                                , output v-round-method
                                , output v-base
                                , output v-margins-range
                                , output v-margins-exists
                                , output v-increase-range
                                , output v-increase-exists
                                , output v-rmethod-range
                                , output v-rmethod-exists

            ) no-error .
            if error-status :error
            then do:
                undo, return error "create-new-line: Ошибка определения границ наценок и/или наценки по умолчанию для группы." + {&new-line} + return-value.
            end.
            assign
                buf_temp_grplib_grp.min-marg = ( if v-margins-exists = yes then string( v-min-marg, "->>>>9.99" ) else "" )
                buf_temp_grplib_grp.max-marg = ( if v-margins-exists = yes then string( v-max-marg, "->>>>9.99" ) else "" )
                buf_temp_grplib_grp.increase-pc = ( if v-increase-exists = yes then  v-increase-pc else buf_temp_grplib_grp.increase-pc)
                buf_temp_grplib_grp.round-method = (if v-rmethod-exists = yes
                                                    then (v-round-method  + {&space-char} +
                                                    (if lookup(v-round-method, {&pr-rounds-need-coef}) > 0
                                                    then string(v-base, "->>>>9.99")
                                                    else "":U
                                                    )
                                                    )
                                                    else  "":U)
            .
            run grp-obj-income-cli-value in this-procedure (
                              input p-node-code
                            , input v-current-store-type
                            , input v-current-store-code
                            , output v-cli-type
                            , output v-cli-code
                            , output v-income-cli-range
                            , output v-income-cli-exists
            ) no-error  .
            if error-status :error
            then do:
                undo, return error "change-grp: Ошибка определения внутреннего поставщика для корневой группы." + {&new-line} + return-value.
            end.
            assign
                buf_temp_grplib_grp.cli-type = ( if v-income-cli-exists = yes then  v-cli-type else "" )
                buf_temp_grplib_grp.cli-code = ( if v-income-cli-exists = yes then  v-cli-code else 0 )
            .
            run grp-obj-notcorr-value in this-procedure (
                              input p-node-code
                            , input v-current-store-type
                            , input v-current-store-code
                            , output v-notcorr
                            , output v-notcorr-range
                            , output v-notcorr-exists
            ) no-error  .
            if error-status :error
            then do:
                undo, return error "change-grp: Ошибка определения ЗАПРЕТ КОР ОП." + {&new-line} + return-value.
            end.
            assign
                buf_temp_grplib_grp.notcorr = ( if v-notcorr-exists = yes then  v-notcorr else "" )
            .

        end.
        browse br-list:refresh().
        apply "entry" to br-list in frame {&frame-name}.
        return no-apply.
    end.
    find first buf_temp_grplib_grp
         where buf_temp_grplib_grp.node-code = p-node-code
    no-error.
    if not available buf_temp_grplib_grp
    then do:
        undo, return error "change-grp: Ошибка поиска группы в списке.".
    end.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if error-status :error
    then do:
        undo, return error "change-grp: Неверный выбор группы.".
    end.
    assign
        p-recid-list = string( recid( buf_gds-grp ) )
        gds-grp-row  = recid( buf_gds-grp )
    .
    if buf_temp_grplib_grp.level > 0
    then do:
        assign
            buf_temp_grplib_grp.name    = substring( buf_temp_grplib_grp.name
                                                    , 1
                                                    , buf_temp_grplib_grp.level * {&tab-size} + 2 )
                                            + buf_gds-grp.node-name
        .
    end.
    else do:
        assign
            buf_temp_grplib_grp.name    = buf_gds-grp.node-name
        .
    end.
    assign
        buf_temp_grplib_grp.print-code  = buf_gds-grp.print-code
        buf_temp_grplib_grp.increase-pc = buf_gds-grp.increase-pc
        buf_temp_grplib_grp.calc-method = buf_gds-grp.calc-method
        v-old-full-name                 = buf_temp_grplib_grp.full-name
    .
    run grplib-get-full-name in this-procedure (  input p-node-code
                                                , output buf_temp_grplib_grp.full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "Ошибка вычисления полного имени группы в списке".
    end.
    buf_temp_grplib_grp.full-name = buf_temp_grplib_grp.full-name.
    run grplib-get-sort-name in this-procedure (  input p-node-code
                                                , output buf_temp_grplib_grp.sort-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "Ошибка вычисления полного имени группы в списке".
    end.
    buf_temp_grplib_grp.sort-name = buf_temp_grplib_grp.sort-name.
    if buf_temp_grplib_grp.level <> 0
    then do:
        assign
            fi-search :screen-value = right-trim( buf_temp_grplib_grp.full-name, {&delim-grp} )
        .
    end.
    if v-grplib-not-fill-extra-info = yes
    then do:
        assign
            v-margins-exists    = no
            v-increase-exists   = no
            v-rmethod-exists    = no
        .
    end.        /* if v-grplib-not-fill-extra-info = yes */
    else do:
        run grp-obj-margin-value in this-procedure (
                                  input p-node-code
                                , input v-current-store-type
                                , input v-current-store-code
                                , output v-min-marg
                                , output v-max-marg
                                , output v-increase-pc
                                , output v-round-method
                                , output v-base
                                , output v-margins-range
                                , output v-margins-exists
                                , output v-increase-range
                                , output v-increase-exists
                                , output v-rmethod-range
                                , output v-rmethod-exists


        ) no-error .
        if error-status :error
        then do:
            undo, return error "create-new-line: Ошибка определения границ наценок и/или наценки по умолчанию для группы." + {&new-line} + return-value.
        end.
        assign
            buf_temp_grplib_grp.min-marg = ( if v-margins-exists = yes then string( v-min-marg, "->>>>9.99" ) else "" )
            buf_temp_grplib_grp.max-marg = ( if v-margins-exists = yes then string( v-max-marg, "->>>>9.99" ) else "" )
            buf_temp_grplib_grp.increase-pc = ( if v-increase-exists = yes then  v-increase-pc else buf_temp_grplib_grp.increase-pc)
            buf_temp_grplib_grp.round-method = (if v-rmethod-exists = yes
                                                then (v-round-method  + {&space-char} +
                                                (if lookup(v-round-method, {&pr-rounds-need-coef}) > 0
                                                    then string(v-base, "->>>>9.99")
                                                    else "":U
                                                    )
                                                )
                                                else  "":U)
        .
                run grp-obj-income-cli-value in this-procedure (
                                    input p-node-code
                                    , input v-current-store-type
                                    , input v-current-store-code
                                    , output v-cli-type
                                    , output v-cli-code
                                    , output v-income-cli-range
                                    , output v-income-cli-exists
            ) no-error  .
            if error-status :error
            then do:
                undo, return error "change-grp: Ошибка определения внутреннего поставщика для корневой группы." + {&new-line} + return-value.
            end.
            assign
                buf_temp_grplib_grp.cli-type = ( if v-income-cli-exists = yes then  v-cli-type else "" )
                buf_temp_grplib_grp.cli-code = ( if v-income-cli-exists = yes then  v-cli-code else 0 )
            .
            run grp-obj-notcorr-value in this-procedure (
                              input p-node-code
                            , input v-current-store-type
                            , input v-current-store-code
                            , output v-notcorr
                            , output v-notcorr-range
                            , output v-notcorr-exists
            ) no-error  .
            if error-status :error
            then do:
                undo, return error "change-grp: Ошибка определения ЗАПРЕТ КОР ОП." + {&new-line} + return-value.
            end.
            assign
                buf_temp_grplib_grp.notcorr = ( if v-notcorr-exists = yes then  v-notcorr else "" )
            .


    end.        /* NOT ( if v-grplib-not-fill-extra-info = yes ) */
    for each buf_child_temp_grplib_grp
       where buf_child_temp_grplib_grp.full-name begins v-old-full-name
         and buf_child_temp_grplib_grp.full-name <> v-old-full-name
         and buf_child_temp_grplib_grp.level <> buf_temp_grplib_grp.level
    :
        run grplib-get-full-name in this-procedure (  input buf_child_temp_grplib_grp.node-code
                                                    , output buf_child_temp_grplib_grp.full-name
        ) no-error .
        if error-status :error
        then do:
            undo, return error "Ошибка вычисления полного имени группы в списке".
        end.
        run grplib-get-sort-name in this-procedure (  input buf_child_temp_grplib_grp.node-code
                                                    , output buf_child_temp_grplib_grp.sort-name
        ) no-error .
        if error-status :error
        then do:
            undo, return error "Ошибка вычисления полного имени группы в списке".
        end.
    end.

    run UI-on in this-procedure no-error .
    if error-status :error
    then do:
        undo, return error "chg-grp: Ошибка при загрузке дерева групп.".
    end.
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
define input  parameter p-node-code like ub.gds-grp.node-code no-undo.
define output parameter p-have-rights   as logical      no-undo.

    define variable v-enable-change-grp as logical       no-undo.

    if g#db-num <> 0
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
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_temp_grplib_grp       for temp_grplib_grp.
    for each buf_temp_grplib_grp no-lock
       where buf_temp_grplib_grp.upper-code = v-root-code
    :
        run collapse-item in this-procedure (
              input buf_temp_grplib_grp.node-code
            , input no
        ) no-error .
        if error-status :error
        then do:
            undo, return error "Не удалось закрыть подуровни группы "
                                + {&new-line} + "'" + buf_temp_grplib_grp.full-name + "'"
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

    define buffer buf_del_temp_grplib_grp   for temp_grplib_grp.
    define buffer buf_temp_grplib_grp       for temp_grplib_grp.

    find first buf_temp_grplib_grp
         where buf_temp_grplib_grp.node-code = p-node-code
    no-error.
    if error-status :error
    then do:
        undo, return error "collapse-item: Неверно передан код группы. Нет группы с кодом " + string( p-node-code ).
    end.

    assign
        v-focused-row      = br-list :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-list" )
    .

    for each buf_del_temp_grplib_grp
       where buf_del_temp_grplib_grp.full-name begins buf_temp_grplib_grp.full-name
         and buf_del_temp_grplib_grp.full-name <> buf_temp_grplib_grp.full-name
         and buf_del_temp_grplib_grp.level     <> buf_temp_grplib_grp.level
    :
        delete buf_del_temp_grplib_grp.
    end.
    assign
        buf_temp_grplib_grp.mark = {&closed-noterminal-grp-mark}
        buf_temp_grplib_grp.name = replace( buf_temp_grplib_grp.name
                                        , {&opened-noterminal-grp-mark}
                                        , {&closed-noterminal-grp-mark}
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
define input parameter p-is-terminal    as logical      no-undo.
define input parameter p-node-name      as character    no-undo.
define input parameter p-print-code     as character    no-undo .
define input parameter p-increase-pc    as decimal      no-undo.
define input parameter p-calc-method    as character    no-undo.
define input parameter p-full-name      as character    no-undo.
define input parameter p-sort-name      as character    no-undo.

define variable v-margins-range     as integer           no-undo.
define variable v-margins-exists    as logical           no-undo.
define variable v-increase-range    as integer          no-undo.
define variable v-increase-exists   as logical          no-undo.
define variable v-min-marg          as decimal           no-undo.
define variable v-max-marg          as decimal           no-undo.
define variable v-increase-pc       as decimal           no-undo.
define variable v-round-method      as character         no-undo .
define variable v-base              as decimal           no-undo .
define variable v-rmethod-range     as integer           no-undo.
define variable v-rmethod-exists    as logical           no-undo.

define variable  v-cli-type         as character no-undo .
define variable  v-cli-code         as integer no-undo .
define variable  v-income-cli-range  as integer no-undo .
define variable  v-income-cli-exists as logical no-undo .

define variable  v-notcorr         as character no-undo .
define variable  v-notcorr-range  as integer no-undo .
define variable  v-notcorr-exists as logical no-undo .


define buffer buf_temp_grplib_grp       for temp_grplib_grp.

    create buf_temp_grplib_grp.
    assign
        buf_temp_grplib_grp.node-code   = p-node-code
        buf_temp_grplib_grp.upper-code  = p-upper-code
        buf_temp_grplib_grp.level       = p-level
        buf_temp_grplib_grp.full-name   = p-full-name + (if p-full-name <> "" then {&delim-grp}         else "") + p-node-name
        buf_temp_grplib_grp.sort-name   = p-sort-name + (if p-full-name <> "" then {&grplib-separator}  else "") + p-node-name
        buf_temp_grplib_grp.calc-method = p-calc-method
        buf_temp_grplib_grp.increase-pc = p-increase-pc
        buf_temp_grplib_grp.print-code  = p-print-code
        
    .
    run get-first-char in this-procedure (
          input p-node-code
        , input p-is-terminal
        , input no
        , output buf_temp_grplib_grp.mark
    ) no-error.
    if error-status :error
    then do:
        undo, return error "create-new-line: Ошибка вычисления первого символа для отображения группы." .
    end.
    assign
        buf_temp_grplib_grp.name = fill( " ", {&tab-size} * p-level )
                                        + buf_temp_grplib_grp.mark
                                        + " "
                                        + p-node-name
    .
    if v-grplib-not-fill-extra-info = yes
    then do:
        assign
            v-margins-exists    = no
            v-increase-exists   = no
            v-rmethod-exists    = no
        .
    end.        /* if v-grplib-not-fill-extra-info = yes */
    else do:
        run grp-obj-margin-value in this-procedure (
                                  input p-node-code
                                , input v-current-store-type
                                , input v-current-store-code
                                , output v-min-marg
                                , output v-max-marg
                                , output v-increase-pc
                                , output v-round-method
                                , output v-base
                                , output v-margins-range
                                , output v-margins-exists
                                , output v-increase-range
                                , output v-increase-exists
                                , output v-rmethod-range
                                , output v-rmethod-exists


        ) no-error .
        if error-status :error
        then do:
            undo, return error "create-new-line: Ошибка определения границ наценок и/или наценки по умолчанию для группы." + {&new-line} + return-value.
        end.
        assign
            buf_temp_grplib_grp.min-marg = ( if v-margins-exists = yes then string( v-min-marg, "->>>>9.99" ) else "" )
            buf_temp_grplib_grp.max-marg = ( if v-margins-exists = yes then string( v-max-marg, "->>>>9.99" ) else "" )
            buf_temp_grplib_grp.increase-pc = ( if v-increase-exists = yes then  v-increase-pc else buf_temp_grplib_grp.increase-pc)
            buf_temp_grplib_grp.round-method = (if v-rmethod-exists = yes
                                                then (v-round-method  + {&space-char} +
                                                    (if lookup(v-round-method, {&pr-rounds-need-coef}) > 0
                                                    then string(v-base, "->>>>9.99")
                                                    else "":U
                                                    )
                                                    )
                                                else  buf_temp_grplib_grp.round-method)
        .
        run grp-obj-income-cli-value in this-procedure (
                                    input p-node-code
                                    , input v-current-store-type
                                    , input v-current-store-code
                                    , output v-cli-type
                                    , output v-cli-code
                                    , output v-income-cli-range
                                    , output v-income-cli-exists
            ) no-error  .
            if error-status :error
            then do:
                undo, return error "create-new-line: Ошибка определения внутреннего поставщика для корневой группы." + {&new-line} + return-value.
            end.
            assign
                buf_temp_grplib_grp.cli-type = ( if v-income-cli-exists = yes then  v-cli-type else "" )
                buf_temp_grplib_grp.cli-code = ( if v-income-cli-exists = yes then  v-cli-code else 0 )
            .
            run grp-obj-notcorr-value in this-procedure (
                              input p-node-code
                            , input v-current-store-type
                            , input v-current-store-code
                            , output v-notcorr
                            , output v-notcorr-range
                            , output v-notcorr-exists
            ) no-error  .
            if error-status :error
            then do:
                undo, return error "change-grp: Ошибка определения ЗАПРЕТ КОР ОП." + {&new-line} + return-value.
            end.
            assign
                buf_temp_grplib_grp.notcorr = ( if v-notcorr-exists = yes then  v-notcorr else "" )
            .

        /* flora */
        define variable v-value       as character  no-undo init "" .      /* значение атрибута */
        define variable v-type        as character  no-undo.               /* тип атрибута      */
        run grp-attr-value (
            input   buf_temp_grplib_grp.node-code       /* код группы   */
            ,input   {&attr-gds-grp-nabor-h}         /* код атрибута */
            ,input   0                               /* код фирмы    */
            ,input   ""
            ,input   0
            ,output  v-value
            ,output  v-type       ) no-error .
        if v-value = "yes" then  buf_temp_grplib_grp.nabor = "+".
                            else  buf_temp_grplib_grp.nabor = "".
    end.        /* NOT ( if v-grplib-not-fill-extra-info = yes ) */
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

    define variable v-gds-grp-recid     as recid    no-undo.
    define variable v-focused-row       as integer  no-undo.
    define variable v-repositioned-row  as integer  no-undo.
    define variable v-upper-code        as integer  no-undo.
    define variable v-answer            as logical  no-undo.
    define variable v-is-terminal       as logical  no-undo.
    define variable v-have-goods        as logical  no-undo.
    define variable v-counter           as integer  no-undo.
    define variable v-have-rights       as logical  no-undo.

    define buffer buf_gds-grp           for ub.gds-grp.
    define buffer buf_same_gds-grp      for ub.gds-grp.                      /* для проверки совпадения имен */
    define buffer buf_temp_grplib_grp   for temp_grplib_grp.

    run check-rights-for-change-grp in this-procedure ( p-node-code
        ,output v-have-rights
    ) no-error.
    if error-status :error
    or v-have-rights = no
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Нет прав на изменение справочника групп товаров."
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
    find first buf_temp_grplib_grp
         where buf_temp_grplib_grp.node-code = p-node-code
    no-error .
    if error-status :error
    then do:
        undo, return error "Неверно выбрана группа." .
    end.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if error-status :error
    then do:
        undo, return error "change-grp: Нет группы БД, соответствующей значению в списке.".
    end.
    v-upper-code = buf_gds-grp.upper-code.
    run waitfram-show in this-procedure ( input "Ждите..." ).
    run ref/gdsgrp03.p ( input no
                        ,input recid(buf_gds-grp)
                        ,input "up" /*p-child-grp-behavior*/
                        ,input "up" /*p-child-gds-behavior*/
                        ) no-error.
    if error-status :error
    then do:
       run waitfram-hide in this-procedure .
        undo, return error return-value.
    end.
    run waitfram-hide in this-procedure .
    if return-value = "no-apply"  then do:
        apply "entry" to br-list in frame {&frame-name}.
        return no-apply.
    end.
    if p-refresh = yes
    then do:
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "delete-grp: Не найдена группа в БД".
        end.
        assign
            p-recid-list = string( recid( buf_gds-grp ) )
            gds-grp-row  = recid( buf_gds-grp )
        .
/*        run expand-item in this-procedure ( input buf_gds-grp.node-code, input yes ) no-error.*/
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable-button-marg Dlg-grp
PROCEDURE enable-button-marg :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.

    define variable v-is-terminal     as logical           no-undo.

    define buffer buf_upper_gds-grp for ub.gds-grp.
    define buffer buf_node_gds-grp  for ub.gds-grp.

    if not b-marg :visible in FRAME {&frame-name}
    then do:
        /* Кнопка не видна, не надо анализировать */
    end.
    else do:
        run grplib-is-terminal in this-procedure ( input p-node-code, output v-is-terminal ) no-error.
        if error-status :error
        then do:
            undo, return error "enable-button-marg: Не удается определить, корневая группа или терминальная." + {&new-line} + return-value.
        end.
        if v-is-terminal = no
        then do:
            enable b-marg    with FRAME {&frame-name}.
        end.
        else do:
            enable b-marg   with FRAME {&frame-name}.
        end.
    end.
end.

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
  ENABLE b-exit b-mark b-scales b-sel b-marg b-print B-history b-help b-add
         b-chg b-del b-move b-arch b-tax B-gds B-nabor B-rum b-expand
         b-expand-all fi-search b-find-by-full-name b-find-by-substring
         b-search br-list
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

    define variable v-full-name         as character    no-undo.
    define variable v-focused-row       as integer      no-undo.
    define variable v-repositioned-row  as integer      no-undo.
    define variable v-grp-counter       as integer      no-undo.

    define buffer buf_temp_grplib_grp       for temp_grplib_grp.
    assign
        v-grplib-no-warning-grp-amount = no
    .
    run expand-item in this-procedure (
          input p-node-code
        , input no
    ) no-error .
    if error-status :error
    then do:
        undo, return error "expand-all-from-current: Не удалось раскрыть подуровни группы.".
    end.
    assign
        v-focused-row      = br-list :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-list" )
    .
    run grplib-get-full-name in this-procedure (
          input p-node-code
        , output v-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "expand-all-from-current: Ошибка вычисления полного имени группы".
    end.
    assign      /* Загрузить первую порцию групп ( {&grplib-grp-amount-for-warning} ) */
        v-grplib-grp-amount-for-load = 1
    .
    load-grp-list:
    for each buf_temp_grplib_grp
       where buf_temp_grplib_grp.full-name begins v-full-name
    :
        assign
            v-grp-counter = v-grp-counter + 1
        .
        run expand-item in this-procedure (
              input buf_temp_grplib_grp.node-code
            , input no
        ) no-error .
        if error-status :error
        then do:
            undo, return error "expand-all-from-current: Не удалось раскрыть подуровни группы.".
        end.
        if v-grp-counter > {&grplib-grp-amount-for-warning}
        and v-grplib-grp-amount-for-load <> 0
        then do:
            define variable v-choice    as integer      no-undo.
            run gbl/d-askw.w (
                  input "Большой список групп"
                , input substitute( "В список добавлено более &2 групп&1&1Вы можете добавить следующие &2 групп,&1заполнить весь список&1или остановить создание списка.", {&new-line}, {&grplib-grp-amount-for-warning} )
                , input "|^":U
                , input substitute( "Следующие &1|Заполнить все|Прервать", {&grplib-grp-amount-for-warning} )
                , input substitute( "Загрузить список следующих &1 групп|Загрузить список всех групп|Не загружать список полностью", {&grplib-grp-amount-for-warning} )
                , input 1
                , input 3
                , output v-choice
            ).
            case v-choice
            :
                when 1
                then do:
                    assign
                        v-grplib-grp-amount-for-load    = 1
                        v-grp-counter                   = 0

                    .
                end.        /* when 1 */
                when 2
                then do:
                    assign
                        v-grplib-grp-amount-for-load    = 0
                    .
                end.        /* when 2 */
                otherwise do:
                    leave load-grp-list.
                end.        /* otherwise */
            end case.       /* case v-choice */
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

    define buffer buf_gds-grp           for ub.gds-grp.
    define buffer buf_temp_grplib_grp   for temp_grplib_grp.
    { gbl/working.i }
    assign
        v-focused-row      = br-list :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-list" )
    .
    find first buf_temp_grplib_grp
         where buf_temp_grplib_grp.node-code = p-node-code
    no-error .
    if not available buf_temp_grplib_grp
    then do:
        undo, return error "expand-item: Неверно задан код группы.".
    end.
    if buf_temp_grplib_grp.mark <> {&closed-noterminal-grp-mark}
    then do:
        /* Не закрытая группа, открыть невозможно. */
    end.
    else do:
        for each buf_gds-grp no-lock
           where buf_gds-grp.upper-code = p-node-code
        on error undo, return error
        :
            run create-new-line in this-procedure (
                  input buf_gds-grp.node-code
                , input buf_gds-grp.upper-code
                , input buf_temp_grplib_grp.level + 1
                , input buf_gds-grp.is-term
                , input buf_gds-grp.node-name
                , input buf_gds-grp.print-code
                , input buf_gds-grp.increase-pc
                , input buf_gds-grp.calc-method
                , input buf_temp_grplib_grp.full-name
                , input buf_temp_grplib_grp.sort-name
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
                { gbl/stopwork.i }
                undo, return error .
            end.
        end.        /* for each buf_gds-grp */
        assign
            buf_temp_grplib_grp.mark = {&opened-noterminal-grp-mark}
            buf_temp_grplib_grp.name = replace( buf_temp_grplib_grp.name
                                            , {&closed-noterminal-grp-mark}
                                            , {&opened-noterminal-grp-mark}
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
    { gbl/stopwork.i }
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
    case temp_grplib_grp.mark
    :
    when {&closed-noterminal-grp-mark}
    then do:
        run expand-item in this-procedure ( input temp_grplib_grp.node-code, input yes ) no-error .
        if error-status :error
        then do:
            undo, return error "Не удалось раскрыть подуровни группы.".
        end.
    end.
    when {&opened-noterminal-grp-mark}
    then do:
        run collapse-item in this-procedure ( input temp_grplib_grp.node-code, input yes ) no-error .
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

define variable v-full-name     as character    no-undo.
define variable v-found         as logical      no-undo.

define buffer buf_temp_grplib_grp       for temp_grplib_grp.

    run grplib-get-full-name in this-procedure ( input p-node-code, output v-full-name ) no-error .
    if error-status :error
    then do:
        /* Не нашли полного имени - встаем на первую группу. */
    end.
    else do:
        run grplib-find-grp-by-full-name in this-procedure (
              input right-trim( v-full-name, {&delim-grp} )
            , input yes
            , output v-found
        ) no-error .
        if v-found = no
        then do:
            /* Не нашли по полному имени - встаем на первую группу. */
        end.
        else do:
            process-initial-grp:
            for each temp_grplib_found-grp
            break by temp_grplib_found-grp.level
            on error undo, leave process-initial-grp :
                if last ( temp_grplib_found-grp.level )
                then do:
                    assign
                        p-focused-row       = integer( br-list :height in frame {&frame-name} / 2 ) + 1
                    .
                    find first buf_temp_grplib_grp
                         where buf_temp_grplib_grp.node-code = temp_grplib_found-grp.node-code
                    no-error .
                    if error-status :error
                    then do:
                        leave process-initial-grp.
                    end.
                    assign
                        p-reposition-row = recid( buf_temp_grplib_grp )
                        p-reposition-to-recid = yes
                    .
                    leave process-initial-grp.
                end.
                else do:
                    run expand-item in this-procedure ( input temp_grplib_found-grp.node-code, input no ) no-error .
                    if error-status :error
                    then do:
                        leave process-initial-grp.
                    end.
                    find first buf_temp_grplib_grp
                            where buf_temp_grplib_grp.node-code = temp_grplib_found-grp.node-code
                    no-error .
                    if error-status :error
                    then do:
                        leave process-initial-grp.
                    end.
                    assign
                        p-reposition-row = recid( buf_temp_grplib_grp )
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-db Dlg-grp
PROCEDURE fill-db :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter parnode-code like ub.gds-grp.node-code no-undo .
define input parameter parupper-code like ub.gds-grp.node-code no-undo .
  run ref/dtaxgrpu.p (input parnode-code,
                 input parupper-code,
                 input yes,
                 input v-current-host-code,
                 v-current-store-type,
                 v-current-store-code) no-error.
end.
END PROCEDURE. /* fill-db */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-marg Dlg-grp
PROCEDURE fill-marg :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.

define variable v-focused-row       as integer  no-undo.
define variable v-repositioned-row  as integer  no-undo.
define variable v-margins-range     as integer  no-undo.
define variable v-margins-exists    as logical  no-undo.
define variable v-increase-range     as integer  no-undo.
define variable v-increase-exists    as logical  no-undo.
define variable v-min-marg          as decimal  no-undo.
define variable v-max-marg          as decimal  no-undo.
define variable v-increase-pc          as decimal  no-undo.
define variable v-round-method      as character   no-undo .
define variable v-base              as decimal     no-undo .
define variable v-rmethod-range     as integer     no-undo.
define variable v-rmethod-exists    as logical     no-undo.
define variable v-cli-type           as character no-undo .
define variable v-cli-code           as integer no-undo .
define variable v-income-cli-range   as integer no-undo .
define variable v-income-cli-exists  as logical no-undo .

define variable  v-notcorr         as character no-undo .
define variable  v-notcorr-range  as integer no-undo .
define variable  v-notcorr-exists as logical no-undo .
define variable  v-have-rights    as logical no-undo .



    define buffer buf_gds-grp           for ub.gds-grp.
    define buffer buf_temp_grplib_grp   for temp_grplib_grp.

    assign
        v-focused-row      = br-list :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-list" )
    .
/*    { gbl/chk-actg.i                  */
/*        v-cntxt-db-num                */
/*        v-cntxt-userid                */
/*        {&action-head-code-main}      */
/*        'actn_reference_groups-edit':U*/
/*        {&cntxt-firm}                 */
/*        v-cntxt-host-code-obj         */
/*        '':U                          */
/*        0                             */
/*        0                             */
/*        p-node-code                   */
/*        0                             */
/*        yes                           */
/*        v-have-rights                 */
/*    }                                 */
/*    if not v-have-rights then return. */

    run ref/pr-marg.w (
          input parparentproc
        , input p-node-code
    ) no-error.
    if error-status :error
    then do:
        undo, return error "fill-marg: Ошибка при установке диапазона торговых наценок." + {&new-line} + return-value.
    end.
    find first buf_temp_grplib_grp
         where buf_temp_grplib_grp.node-code = p-node-code
    no-error .
    if error-status :error
    then do:
        undo, return error "fill-marg: Неверно задан код группы.".
    end.
    if v-grplib-not-fill-extra-info = yes
    then do:
        assign
            v-margins-exists    = no
            v-increase-exists   = no
            v-rmethod-exists    = no
        .
    end.        /* if v-grplib-not-fill-extra-info = yes */
    else do:
        run grp-obj-margin-value in this-procedure (
                                input p-node-code
                                , input v-current-store-type
                                , input v-current-store-code
                                , output v-min-marg
                                , output v-max-marg
                                , output v-increase-pc
                                , output v-round-method
                                , output v-base
                                , output v-margins-range
                                , output v-margins-exists
                                , output v-increase-range
                                , output v-increase-exists
                                , output v-rmethod-range
                                , output v-rmethod-exists


        ) no-error .
        if error-status :error
        then do:
            undo, return error "fill-marg: Ошибка определения границ наценок для группы." + {&new-line} + return-value.
        end.
        assign
            buf_temp_grplib_grp.min-marg = ( if v-margins-exists = yes then string( v-min-marg, "->>>>9.99" ) else "" )
            buf_temp_grplib_grp.max-marg = ( if v-margins-exists = yes then string( v-max-marg, "->>>>9.99" ) else "" )
            buf_temp_grplib_grp.increase-pc = ( if v-increase-exists = yes then v-increase-pc else buf_temp_grplib_grp.increase-pc)
            buf_temp_grplib_grp.round-method = if v-rmethod-exists
                                            then (v-round-method + {&space-char} +
                                                    (if lookup(v-round-method, {&pr-rounds-need-coef}) > 0
                                                    then string(v-base, "->>>,>9.99":U)
                                                    else "":U))
                                            else buf_temp_grplib_grp.round-method

        .
        run grp-obj-income-cli-value in this-procedure (
                                input p-node-code
                                , input v-current-store-type
                                , input v-current-store-code
                                , output v-cli-type
                                , output v-cli-code
                                , output v-income-cli-range
                                , output v-income-cli-exists

        ) no-error .
        if error-status :error
        then do:
            undo, return error "fill-marg: Ошибка определения внутр поставщика для группы." + {&new-line} + return-value.
        end.
        assign
            buf_temp_grplib_grp.cli-type = ( if v-income-cli-exists = yes then  v-cli-type  else "" )
            buf_temp_grplib_grp.cli-code = ( if v-income-cli-exists = yes then  v-cli-code  else 0 )

        .
            run grp-obj-notcorr-value in this-procedure (
                              input p-node-code
                            , input v-current-store-type
                            , input v-current-store-code
                            , output v-notcorr
                            , output v-notcorr-range
                            , output v-notcorr-exists
            ) no-error  .
            if error-status :error
            then do:
                undo, return error "change-grp: Ошибка определения ЗАПРЕТ КОР ОП." + {&new-line} + return-value.
            end.
            assign
                buf_temp_grplib_grp.notcorr = ( if v-notcorr-exists = yes then  v-notcorr else "" )
            .

    end.        /* NOT ( if v-grplib-not-fill-extra-info = yes ) */
    {&OPEN-BROWSERS-IN-QUERY-Dlg-grp}
    br-list :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame {&FRAME-NAME}.
    reposition br-list to row v-repositioned-row.
end.

END PROCEDURE.

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

    define buffer buf_gds-grp           for ub.gds-grp.
    define buffer buf_temp_grplib_grp   for temp_grplib_grp.

    run grplib-is-terminal in this-procedure ( input p-node-code, output v-is-terminal ) no-error.
    if error-status :error
    then do:
        undo, return error "fill-output-parameters-on-exit: Не удается определить, корневая группа или терминальная." + {&new-line} + return-value.
    end.
    if lookup ( {&g#term}, p-button-list ) <> 0 and v-is-terminal = no
    then do:
            message "Требуется выбрать группу товаров, в которой нет других групп.".
            apply "entry" to br-list in frame {&frame-name}.
            undo, return "no-term".
    end.
    assign
        p-recid-list = ""
    .
    for each buf_temp_grplib_grp
       where buf_temp_grplib_grp.sel = {&selection-char}
    :
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = buf_temp_grplib_grp.node-code
        no-error .
        if error-status :error
        then do:
            undo, return error "fill-output-parameters-on-exit: Не найдена запись выбранной группы '"
                                + "'" + buf_temp_grplib_grp.full-name + "'".
        end.
        assign
            p-recid-list = p-recid-list + ( if p-recid-list = "" then "" else "," ) + string( recid( buf_gds-grp ) )
            v-selected = yes
        .
    end.
    if v-selected = no
    then do:
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = p-node-code
        no-error .
        if not available buf_gds-grp
        then do:
            find first buf_temp_grplib_grp
                 where buf_temp_grplib_grp.node-code = p-node-code
            no-error .
            if not available buf_temp_grplib_grp
            then do:
                undo, return error "fill-output-parameters-on-exit: Неверно выбрана группа с кодом "
                                    + string( p-node-code ).
            end.
            undo, return error "fill-output-parameters-on-exit: Не найдена запись выбранной группы '"
                            + buf_temp_grplib_grp.full-name + "'".
        end.
        assign
            p-recid-list = string( recid( buf_gds-grp ) )
        .
    end.
    assign
        gds-grp-row  = integer( entry( 1, p-recid-list ) )
    .
assign
v-uf-List_ = (if gds-grp-row = ? then {&question-mark} else string(gds-grp-row))
.
run uf-set in this-procedure(
    input  {&uf-gds-grp-p}
    ,input  g#userid
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
define input parameter parnode-code like ub.gds-grp.node-code no-undo .
define input parameter parupper-code like ub.gds-grp.node-code no-undo .

run ref/dtaxgrps.p (parnode-code,
               parupper-code,
               v-current-host-code,
               v-current-store-type,
               v-current-store-code) no-error.
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
define input parameter p-search-grp-full-name   as character        no-undo.
define output parameter p-found                 as logical          no-undo.

    define variable v-focused-row       as integer      no-undo.
    define variable v-repositioned-row  as integer      no-undo.
    define variable v-counter           as integer      no-undo.
    define variable v-level             as integer      no-undo.

    define buffer buf_temp_grplib_grp       for temp_grplib_grp.
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
        find first temp_grplib_found-grp
             where temp_grplib_found-grp.level = v-level
        no-error .
        if not available temp_grplib_found-grp
        then do:
            undo, return error "Не найдено ни одной группы уровня " + string( v-level ).
        end.
        do v-counter = 1 to v-found-grp-num
        :
            find next temp_grplib_found-grp
                where temp_grplib_found-grp.level = v-level
            no-error .
            if not available temp_grplib_found-grp
            then do:
                undo, return error "Не найдена следующая группа уровня " + string( v-level ).
            end.
        end.
        find first buf_temp_grplib_grp
                where buf_temp_grplib_grp.node-code = temp_grplib_found-grp.node-code
        no-error .
        if not available buf_temp_grplib_grp
        then do:
            undo, return error "Найденной группы нет в списке групп".
        end.
        {&OPEN-BROWSERS-IN-QUERY-Dlg-grp}
        br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
        reposition br-list to recid recid( buf_temp_grplib_grp ).
    end.        /* v-found-grp-num  <> 0 */
    else do:        /* Первый поиск */
        run grplib-find-grp-by-full-name (
              input fi-search :screen-value in frame {&frame-name}
            , input yes
            , output p-found
        ).
        if p-found = yes
        then do:
            found-group:
            for each temp_grplib_found-grp no-lock
            by temp_grplib_found-grp.level
        /*       where temp_grplib_found-grp. =*/
            :
                if temp_grplib_found-grp.level = v-level
                then do:
                    leave.
                end.
                run expand-item in this-procedure (
                      input temp_grplib_found-grp.node-code
                    , input no
                ).
            end.
            find first temp_grplib_found-grp
                 where temp_grplib_found-grp.level = v-level
            no-error .
            if not available temp_grplib_found-grp
            then do:
                undo, return error "Нет последней найденной группы для уровня " + string( v-level ).
            end.
            find first buf_temp_grplib_grp
                 where buf_temp_grplib_grp.node-code = temp_grplib_found-grp.node-code
            no-error .
            if not available buf_temp_grplib_grp
            then do:
                undo, return error "Найденной группы нет в списке групп".
            end.
            {&OPEN-BROWSERS-IN-QUERY-Dlg-grp}
            br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
            reposition br-list to recid recid( buf_temp_grplib_grp ).
        end.        /* p-found = yes */
    end.        /* v-found-grp-num  = 0, т.е. первый поиск */
    find next temp_grplib_found-grp     /* Можно ли искать дальше? Если можно, увеличиваем счетчик поиска */
        where temp_grplib_found-grp.level = v-level
    no-error .
    if available temp_grplib_found-grp
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE gds-grp_rum-fill_cb Dlg-grp
PROCEDURE gds-grp_rum-fill_cb :
DEFINE INPUT PARAMETER p-target-bh AS handle NO-UNDO.
define input parameter p-processed-bh as handle no-undo .
define variable v-start-node-code as integer no-undo .
define variable v-full-name as character no-undo .
define buffer buf_temp_grplib_grp for temp_grplib_grp.
define buffer buf_gds-grp for ub.gds-grp.
define buffer child_gds-grp for ub.gds-grp.
CASE rum-option:
  WHEN "all" THEN DO:
     FOR EACH buf_gds-grp:
        p-target-bh:BUFFER-CREATE.
        p-target-bh:BUFFER-COPY(BUFFER buf_gds-grp:HANDLE).
        run grplib-get-full-name in this-procedure ( input buf_gds-grp.node-code, output v-full-name) no-error.
        p-target-bh::full-name = v-full-name.
        p-target-bh:BUFFER-RELEASE.

     END.
  END.
  WHEN "current" THEN DO:
    if available temp_grplib_grp then do:
      find first buf_gds-grp no-lock
            where buf_gds-grp.node-code = temp_grplib_grp.node-code
      no-error .
      if error-status :error
      then do:
          undo, return error "gds-grp_rum-fill_cb: Не найдена запись выбранной группы '"
                              + "'" + temp_grplib_grp.full-name + "'".
      end.
      p-target-bh:find-first ( substitute("where node-code = &1", buf_gds-grp.node-code)) no-error .
      if not p-target-bh:available then do:
        p-target-bh:BUFFER-CREATE.
        p-target-bh:BUFFER-COPY(BUFFER buf_gds-grp:HANDLE).
        run grplib-get-full-name in this-procedure ( input buf_gds-grp.node-code, output v-full-name) no-error.
        p-target-bh::full-name = v-full-name.
        p-target-bh:BUFFER-RELEASE.
      end.
    END. /*    if available temp_grplib_grp then do:*/
  END.
  WHEN "current+childs" THEN DO:
    if available temp_grplib_grp then do:
      find first buf_gds-grp no-lock
            where buf_gds-grp.node-code = temp_grplib_grp.node-code
      no-error .
      if error-status :error
      then do:
          undo, return error "gds-grp_rum-fill_cb: Не найдена запись выбранной группы '"
                              + "'" + temp_grplib_grp.full-name + "'".
      end.
      v-start-node-code = buf_gds-grp.node-code.
      p-target-bh:find-first ( substitute("where node-code = &1", buf_gds-grp.node-code)) no-error .
      if not p-target-bh:available then do:
        p-target-bh:BUFFER-CREATE.
        p-target-bh:BUFFER-COPY(BUFFER buf_gds-grp:HANDLE).
        run grplib-get-full-name in this-procedure ( input buf_gds-grp.node-code, output v-full-name) no-error.
        p-target-bh::full-name = v-full-name.
        p-target-bh:BUFFER-RELEASE.
        p-processed-bh:BUFFER-CREATE.
        p-processed-bh::node-code = buf_gds-grp.node-code.
        p-processed-bh:BUFFER-COPY(BUFFER buf_gds-grp:HANDLE).
        p-processed-bh::processed = no.
        p-processed-bh:BUFFER-RELEASE.
      end.
      process-nodes:
      do while yes
      :
          p-processed-bh:find-first( substitute(" where node-code = &1", v-start-node-code)).
          p-processed-bh::processed = yes.
          for each child_gds-grp no-lock
            where child_gds-grp.upper-code = v-start-node-code
          on error undo, return error
          :
            p-target-bh:find-first ( substitute("where node-code = &1", child_gds-grp.node-code)) no-error .
            if not p-target-bh:available then do:
              p-target-bh:BUFFER-CREATE.
              p-target-bh:BUFFER-COPY(BUFFER child_gds-grp:HANDLE).
              run grplib-get-full-name in this-procedure ( input child_gds-grp.node-code, output v-full-name) no-error.
              p-target-bh::full-name = v-full-name.
              p-target-bh:BUFFER-RELEASE.
            end.
            p-processed-bh:BUFFER-CREATE.
            p-processed-bh::node-code = child_gds-grp.node-code.
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
    END. /*if available temp_grplib_grp*/
  END.
  WHEN "selected" THEN DO:
    FOR EACH buf_temp_grplib_grp
       where buf_temp_grplib_grp.sel = {&selection-char}
    :
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = buf_temp_grplib_grp.node-code
        no-error .
        if error-status :error
        then do:
            undo, return error "gds-grp_rum-fill_cb: Не найдена запись выбранной группы '"
                                + "'" + buf_temp_grplib_grp.full-name + "'".
        end.
      p-target-bh:find-first ( substitute("where node-code = &1", buf_gds-grp.node-code)) no-error .
      if not p-target-bh:available then do:
         p-target-bh:BUFFER-CREATE.
         p-target-bh:BUFFER-COPY(BUFFER buf_gds-grp:HANDLE).
         run grplib-get-full-name in this-procedure ( input buf_gds-grp.node-code, output v-full-name) no-error.
         p-target-bh::full-name = v-full-name.
         p-target-bh:BUFFER-RELEASE.
      end.
    END.
  END.
  WHEN "selected+child" THEN DO:
    FOR EACH buf_temp_grplib_grp
       where buf_temp_grplib_grp.sel = {&selection-char}
    :
      find first buf_gds-grp no-lock
            where buf_gds-grp.node-code = buf_temp_grplib_grp.node-code
      no-error .
      if error-status :error
      then do:
          undo, return error "gds-grp_rum-fill_cb: Не найдена запись выбранной группы '"
                              + "'" + buf_temp_grplib_grp.full-name + "'".
      end.
      p-target-bh:find-first ( substitute("where node-code = &1", buf_gds-grp.node-code)) no-error .
      if not p-target-bh:available then do:
        p-target-bh:BUFFER-CREATE.
        p-target-bh:BUFFER-COPY(BUFFER buf_gds-grp:HANDLE).
        run grplib-get-full-name in this-procedure ( input buf_gds-grp.node-code, output v-full-name) no-error.
        p-target-bh::full-name = v-full-name.
        p-target-bh:BUFFER-RELEASE.
        p-processed-bh:BUFFER-CREATE.
        p-processed-bh::node-code = buf_gds-grp.node-code.
        p-processed-bh::processed = no.
        p-processed-bh:BUFFER-RELEASE.
      end.
      process-nodes:
      do while yes
      :
          p-processed-bh:find-first( substitute(" where node-code = &1", v-start-node-code)).
          p-processed-bh::processed = yes.
          for each child_gds-grp no-lock
            where child_gds-grp.upper-code = v-start-node-code
          on error undo, return error
          :
            p-target-bh:find-first ( substitute("where node-code = &1", child_gds-grp.node-code)) no-error .
            if not p-target-bh:available then do:
              p-target-bh:BUFFER-CREATE.
              p-target-bh:BUFFER-COPY(BUFFER child_gds-grp:HANDLE).
              run grplib-get-full-name in this-procedure ( input child_gds-grp.node-code, output v-full-name) no-error.
              p-target-bh::full-name = v-full-name.
              p-target-bh:BUFFER-RELEASE.
            end.
            p-processed-bh:BUFFER-CREATE.
            p-processed-bh::node-code = child_gds-grp.node-code.
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
    END. /*FOR EACH buf_temp_grplib_grp*/
  END. /*WHEN "selected+child" THEN DO:*/

END CASE.

END PROCEDURE.

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
define output parameter p-gds-grp-recid as recid   no-undo.

    define buffer buf_gds-grp       for ub.gds-grp.

    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error .
    if not available buf_gds-grp
    then do:
        undo, return error "get-current-recid: Не найдена группа." .
    end.
    assign
        p-gds-grp-recid = recid( buf_gds-grp )
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
define input parameter p-node-code      as integer      no-undo.
define input parameter p-terminal       as logical      no-undo.
define input parameter p-calc-terminal  as logical      no-undo.
define output parameter p-prefix        as character    no-undo.

define variable v-name          as character    no-undo.
define variable v-is-terminal   as logical      no-undo.
define variable v-have-goods    as logical      no-undo.

define buffer buf_gds-grp               for ub.gds-grp.
define buffer buf_temp_grplib_grp       for temp_grplib_grp.

if p-calc-terminal = yes
then do:
    run grplib-is-terminal in this-procedure (
          input p-node-code
        , output v-is-terminal
    ) no-error .
    if error-status :error
    then do:
        undo, return error "get-first-char: Ошибка при определении типа группы (терм/корн).".
    end.
end.        /* if p-calc-terminal = yes */
else do:
    assign
        v-is-terminal = p-terminal
    .
end.        /* NOT ( if p-calc-terminal = yes ) */
if v-is-terminal = yes
then do:                    /* Терминальная группа */
    run grplib-have-goods in this-procedure (
          input p-node-code
        , output v-have-goods
    ) no-error .
    if error-status :error
    then do:
        undo, return error "get-first-char: Ошибка определения наличия товаров в группе." + {&new-line} + return-value.
    end.
    if v-have-goods = yes
    then do:
        assign
            p-prefix = {&terminal-with-goods-grp-mark}
        .
    end.
    else do:
        assign
            p-prefix = {&terminal-no-goods-grp-mark}
        .
    end.
end.        /* not available buf_gds-grp */
else do:
    find first buf_temp_grplib_grp no-lock
         where buf_temp_grplib_grp.upper-code = p-node-code
    no-error.
    if available buf_temp_grplib_grp
    then do:                /* группа в списке раскрыта */
        assign
            p-prefix = {&opened-noterminal-grp-mark}
        .
    end.
    else do:
        assign
            p-prefix = {&closed-noterminal-grp-mark}
        .
    end.
end.        /* available buf_gds-grp */
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

    define buffer buf_temp_grplib_grp       for temp_grplib_grp.

    for each buf_temp_grplib_grp
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
    define variable v-have-goods        as logical      no-undo.

    define buffer buf_gds-grp           for ub.gds-grp.
    define buffer buf_upper_gds-grp     for ub.gds-grp.
    define buffer buf_temp_grplib_grp   for temp_grplib_grp.

    { gbl/working.i }

    run grplib-have-goods in this-procedure (
          input p-upper-code
        , output v-have-goods
    ) no-error .
    if error-status :error
    then do:
        undo, return error "move-item: Ошибка определения наличия товаров в группе." + {&new-line} + return-value.
    end.
    if v-have-goods = yes
    then do:
            message
                "В эту группу переместить нельзя, т.к. в одной группе"
                skip "не могут быть одновременно подгруппы и товары.".
            apply "entry" to br-list in frame {&frame-name}.
            return no-apply.
    end.
    run grplib-get-full-name in this-procedure (
            input p-node-code
            , output v-node-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "move-item: Ошибка вычисления полного имени перемещаемой группы".
    end.
    run grplib-get-full-name in this-procedure (
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

    /*find first buf_upper_gds-grp no-lock*/
    /*     where buf_upper_gds-grp.node-code = p-upper-code*/
    /*no-error .*/
    /*if not available buf_upper_gds-grp*/
    /*then do:*/
    /*    undo, return error "move-item: Не найдена родительская группа для перемещения.". */
    /*end.*/
    do transaction
    on error undo, return error "move-item: Ошибка перемещения группы.".
        find first buf_gds-grp exclusive-lock
            where buf_gds-grp.node-code = p-node-code
        no-error .
        if not available buf_gds-grp
        then do:
            undo, return error "move-item: Не найдена группа для перемещения.".
        end.
        assign
            buf_gds-grp.upper-code = p-upper-code
        .
    end.
    assign
        p-recid-list = string( recid( buf_gds-grp ) )
        gds-grp-row  = recid( buf_gds-grp )
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE press-arch Dlg-grp
PROCEDURE press-arch :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.

define variable v-allow-arch     as logical           no-undo.

define buffer buf_temp_grplib_grp   for temp_grplib_grp.
define buffer buf_gds-grp           for ub.gds-grp.
define buffer buf_goods             for ub.goods.


    for each tt-goods:
        delete tt-goods.
    end.
    for each tt-clients:
        delete tt-clients.
    end.
    for each buf_goods
       where buf_goods.grp-code = p-node-code
    :
        create tt-goods.
        buffer-copy buf_goods to tt-goods.
    end.
    create tt-clients.
    assign
        tt-clients.obj-type = v-current-store-type
        tt-clients.obj-code = v-current-store-code
    .
    {&net-proc}
    { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_reference_archive':U
        {&cntxt-firm}
        v-cntxt-host-code-obj
        '':U
        0
        0
        0
        0
        yes
        v-allow-arch
    }
    if v-allow-arch = yes
    then do:
        run arc/gds_inf.w (input parparentproc, v-current-store-type, v-current-store-code) no-error .
        if error-status :error
        then do:
            undo, return error "Ошибка при выводе архивной информации по товарам группы." + {&new-line} + return-value.
        end.
    end.

end.
END PROCEDURE. /* press-arch */

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
define variable v-vat-pc as decimal no-undo .
define variable v-slt-pc as decimal no-undo .
define variable date_string as character no-undo.
define buffer buf_temp_grplib_grp for temp_grplib_grp.
define buffer buf_tax-rate-gds-grp for ub.tax-rate-gds-grp.

DEFINE FRAME brFrame
buf_temp_grplib_grp.name          format "X(121)"     column-label " Наименование группы"
buf_temp_grplib_grp.calc-method   format "X(11)"      column-label " Исходная"
buf_temp_grplib_grp.increase-pc   format "->>>>9.99"  column-label " Наценка"
buf_temp_grplib_grp.min-marg      format "X(10)"  column-label " Мин.Нац."
buf_temp_grplib_grp.max-marg      format "X(10)"  column-label " Макс.Нац."
buf_temp_grplib_grp.round-method  format "X(22)"  column-label "Метод округл"
v-vat-pc                          format "99.99"  column-label "НДС"
v-slt-pc                          format "99.99"  column-label "НП"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 85 PAGE-NUMBER(PrnLibStream) AT 95 FORMAT ">>9" SKIP
Line format "X(198)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 198).
date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
      input parparentproc
    , input {&LS_PS_A4}
    , input yes /*p-is-stream*/
    , input no /*p-append*/
).
PUT  STREAM PrnLibStream
    SPACE(25) ( frame {&frame-name}:title )
    format "x(90)" SKIP(1)
.
FORM HEADER
Line format "X(198)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .


FORM with FRAME BrFrame  .
run waitfram-show in this-procedure ("Ждите...").

FOR EACH buf_temp_grplib_grp :
  FIND LAST buf_tax-rate-gds-grp No-LOCK WHERE
            buf_tax-rate-gds-grp.node-code = buf_temp_grplib_grp.node-code AND
            buf_tax-rate-gds-grp.tax-code = integer({&vat-tax-code}) AND
            /*
            freeze
            ub.tax-rate-gds-grp.host-code = parhopst-code AND
            ub.tax-rate-gds-grp.obj-type = parobj-type AND
            ub.tax-rate-gds-grp.obj-code = parobj-code AND

            */
            buf_tax-rate-gds-grp.host-code = 0 AND
            buf_tax-rate-gds-grp.obj-type = "" AND
            buf_tax-rate-gds-grp.obj-code = 0 NO-ERROR.
  if avail buf_tax-rate-gds-grp then do:
     { gbl/pftaxval.i ? buf_tax-rate-gds-grp.tax-code buf_tax-rate-gds-grp.rate-code ? v-current-host-code v-current-store-type v-current-store-code v-vat-pc no-error }
  end.
  FIND LAST buf_tax-rate-gds-grp No-LOCK WHERE
            buf_tax-rate-gds-grp.node-code = buf_temp_grplib_grp.node-code AND
            buf_tax-rate-gds-grp.tax-code = integer({&slt-tax-code}) AND
            /*
            freeze
            ub.tax-rate-gds-grp.host-code = parhopst-code AND
            ub.tax-rate-gds-grp.obj-type = parobj-type AND
            ub.tax-rate-gds-grp.obj-code = parobj-code AND

            */
            buf_tax-rate-gds-grp.host-code = 0 AND
            buf_tax-rate-gds-grp.obj-type = "" AND
            buf_tax-rate-gds-grp.obj-code = 0 NO-ERROR.
  if avail buf_tax-rate-gds-grp then do:
     { gbl/pftaxval.i ? buf_tax-rate-gds-grp.tax-code buf_tax-rate-gds-grp.rate-code ? v-current-host-code v-current-store-type v-current-store-code v-slt-pc no-error }
  end.
  DISPLAY stream PrnLibStream
  buf_temp_grplib_grp.name
  buf_temp_grplib_grp.calc-method
  buf_temp_grplib_grp.increase-pc
  buf_temp_grplib_grp.min-marg
  buf_temp_grplib_grp.max-marg
  buf_temp_grplib_grp.round-method
  v-vat-pc
  v-slt-pc
  with frame BrFrame.
  down stream PrnLibStream
  with frame BrFrame.
END. /*for each*/
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME BrFrame.
output  STREAM PrnLibStream CLOSE.
run waitfram-hide in this-procedure .

run prn-lib-prn-file in this-procedure (
      input parparentproc
    , input 8
).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE print-grp Dlg-grp
PROCEDURE print-grp :
/*------------------------------------------------------------------------------
  Purpose:     Печать групп товаров
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
define buffer buf_gds-grp       for ub.gds-grp.

if print-option = "":U then do:
    run gbl/pop-up.p (b-print:handle in frame {&frame-name}, no) no-error.
    if error-status:error then do:
        assign print-option = "":U.
        return no-apply.
     end.
end.
    find first buf_gds-grp no-lock
        where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "Неверно выбрана группа.".
    end.
    if print-option = "browse":U then do:
            run print-browse in this-procedure no-error.
    end.
        else do:
    run rep/r-gdsgrp.p ( input parparentproc, input recid( buf_gds-grp ), input print-option ) no-error .
    end.
    if error-status :error
    then do:
        assign
                print-option = "":U
                .
        undo, return error "Ошибка печати групп товаров.".
    end.
    apply "entry" to br-list in frame {&frame-name}.
end.
END PROCEDURE. /* print-grp */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-rum Dlg-grp
PROCEDURE proc-b-rum :
define input parameter p-rum-option as character no-undo .
define variable v-radio-button-parameter as character no-undo .
define variable v-node-code as integer no-undo .
define buffer buf_gds-grp for ub.gds-grp.
if available temp_grplib_grp then do:
  v-node-code = temp_grplib_grp.node-code.
end.
if p-rum-option = {&gds-grp-proc_xml-file-import} then do:
  v-radio-button-parameter = {&gds-grp-proc_xml-file-import}.
end.
else do:
  v-radio-button-parameter = ({&gds-grp-proc_batchwork-export} + {&comma-char} + {&gds-grp-proc_batchwork-routing}) .
end.
run str/diallog.w (
      input parParentProc
    , input this-procedure
    , input "utl/thbjrumr.w":U
    , input {&table_gds-grp} + {&delim-par} + v-radio-button-parameter /*parameter - второй элемент списка - это radio-buttons rs-ruleset d thbjrumr*/
    , input no /*p-auto-go*/
    , input "&Стоп"
    , input substitute("Операции над группами товаров") )  no-error .
if p-rum-option = {&gds-grp-proc_xml-file-import} then do:
  if v-node-code > 0 then do:
    find first buf_gds-grp no-lock
          where buf_gds-grp.node-code = v-node-code
    no-error.
  end.
  else do:
    find first buf_gds-grp no-lock.
  end.
  if not available buf_gds-grp
  then do:
      undo, return error "proc-b-rum: Не найдена группа в БД".
  end.
  assign
  p-recid-list = string( recid( buf_gds-grp ) )
  gds-grp-row  = recid( buf_gds-grp )
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
    define variable  v-have-rights    as logical no-undo .

    define buffer buf_gds-grp       for ub.gds-grp.

    run check-rights-for-change-grp in this-procedure (p-node-code,
        output v-have-rights
    ) no-error.
    if error-status :error
    or v-have-rights = no
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Нет прав на изменение справочника групп товаров."
          skip "Удаление группы невозможно."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if p-node-code = v-root-code
    then do:
        message
        "Корневую группу переместить невозможно."
        view-as alert-box warning.
        undo, return .
    end.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error .
    if error-status :error
    then do:
        undo, return error "select-and-move-item: Группа не найдена в базе данных.".
    end.
    assign
        v-upper-recid-list = string( recid( buf_gds-grp ) )
    .
    run ref/gds-grp.w (
          input parparentproc
        , input {&buttons-for-move}
        , input p-current-obj-type
        , input p-current-obj-code
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
    find first buf_gds-grp no-lock
         where recid( buf_gds-grp ) = integer( entry( 1, v-upper-recid-list ) )
    no-error .
    if error-status :error
    then do:
        undo, return error "Группа не найдена.".
    end.
    run grplib-get-full-name in this-procedure (  input p-node-code
                                                , output v-node-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "Ошибка вычисления полного имени перемещаемой группы.".
    end.
    run grplib-get-full-name in this-procedure (  input buf_gds-grp.node-code
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
                                        , input buf_gds-grp.node-code
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
  Purpose:     Заполнение temp_grplib_grp и инициализация при старте программы
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
define variable v-margins-range         as integer          no-undo.
define variable v-margins-exists        as logical          no-undo.
define variable v-increase-range         as integer          no-undo.
define variable v-increase-exists        as logical          no-undo.
define variable v-min-marg              as decimal          no-undo.
define variable v-max-marg              as decimal          no-undo.
define variable v-increase-pc              as decimal          no-undo.
define variable v-have-goods            as logical          no-undo.
define variable v-round-method      as character   no-undo .
define variable v-base                  as decimal no-undo .
define variable v-rmethod-range     as integer     no-undo.
define variable v-rmethod-exists    as logical     no-undo.
define variable v-cli-type          as character no-undo .
define variable v-cli-code          as integer     no-undo.
define variable v-income-cli-range    as integer  no-undo.
define variable v-income-cli-exists   as logical  no-undo.
define variable v-dop                   as character no-undo .
define variable v-full-name             as character    no-undo.
define variable v-sort-name             as character    no-undo.
define variable  v-notcorr         as character no-undo .
define variable  v-notcorr-range  as integer no-undo .
define variable  v-notcorr-exists as logical no-undo .



define buffer buf_gds-grp           for ub.gds-grp.
define buffer buf_temp_grplib_grp   for temp_grplib_grp.

  { adm/actn-grp.i
    v-enable-change-grp
  }
IF NOT v-enable-change-grp then do:

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
      0
      0
      no
      v-enable-change-grp
  }
end.
run grplib-get-root-code in this-procedure ( output v-root-code ) no-error.
if error-status :error
then do:
    undo, return error "Не найден корневой узел." + {&new-line} + return-value.
end.
if v-from-b-gds then do:
/*ВНИМАНИЕ!!!!*/
/*здесб обрабаотна ситуация когда пользователь зашел по кнопке ТОВАРЫ в справочник товаров*/
/*если он там переключался в другие группы товаров, то это происходило через справочник групп товаров и все настройки уже сменились*/
/*мы их получим через uf-get и на выходе из справочника ТОВАРОВ постараемся встать в ту группу товаров, в которой он там стоял*/
  run uf-get in this-procedure(
      input  {&uf-gds-grp-p}
      ,input  g#userid
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
  /*если пользователь никуда не переключался по группам товаров в справочнике товаров нам не надо переоткрывать броуз - стоим на месте*/
  if v-dop = v-before-dop then do:
    assign
    gds-grp-row = v-old-recid
    .
  end.
  else do:
    assign
    gds-grp-row = (if v-uf-List_ =  {&question-mark} then ? else integer(v-uf-LIst_))
    .
  end.
 /* 
  assign
      p-recid-list = string( gds-grp-row )
  .
  */
  assign
  v-from-b-gds = no
  v-old-recid-list = "":U.


end.
else do:
  if p-recid-list = '' then do:
  run uf-get in this-procedure(
      input  {&uf-gds-grp-p}
      ,input  g#userid
      ,output v-uf-List_
      ,output v-uf-Naim
      ,output v-uf-print-graft
      ,output v-uf-sort-gr
      ,output v-uf-type-price
      ,output v-uf-type-val
  )  no-error .
  if not error-status:error then
  assign
  gds-grp-row = (if v-uf-List_ =  {&question-mark} then ? else integer(v-uf-LIst_))
  .
  /*
  assign
      p-recid-list = string( gds-grp-row )
  .
  */
end.
end.
find first buf_gds-grp no-lock
     where buf_gds-grp.node-code = v-root-code
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
if buf_gds-grp.is-term = yes
then do:
    run grplib-have-goods in this-procedure (
          input buf_gds-grp.node-code
        , output v-have-goods
    ) no-error .
    if error-status :error
    then do:
        undo, return error "move-item: Ошибка определения наличия товаров в группе." + {&new-line} + return-value.
    end.
end.
for each buf_temp_grplib_grp
:
    delete buf_temp_grplib_grp.
end.
create buf_temp_grplib_grp.
assign
    buf_temp_grplib_grp.node-code   = buf_gds-grp.node-code
    buf_temp_grplib_grp.upper-code  = buf_gds-grp.upper-code
    buf_temp_grplib_grp.level       = 0
    buf_temp_grplib_grp.mark        = ( if v-have-goods = yes then {&terminal-with-goods-grp-mark} else {&terminal-no-goods-grp-mark} )
    buf_temp_grplib_grp.full-name   = {&delim-par}            /* Символ chr(1) - первый для сортировки */
    buf_temp_grplib_grp.sort-name   = {&delim-par}            /* Символ chr(1) - первый для сортировки */
    buf_temp_grplib_grp.name        = buf_gds-grp.node-name
    buf_temp_grplib_grp.increase-pc = buf_gds-grp.increase-pc
    buf_temp_grplib_grp.calc-method = buf_gds-grp.calc-method
    buf_temp_grplib_grp.print-code  = buf_gds-grp.print-code
.
if v-grplib-not-fill-extra-info = yes
then do:
    assign
        v-margins-exists    = no
        v-increase-exists   = no
        v-rmethod-exists    = no
    .
end.        /* if v-grplib-not-fill-extra-info = yes */
else do:
    run grp-obj-margin-value in this-procedure (
                              input 0
                            , input v-current-store-type
                            , input v-current-store-code
                            , output v-min-marg
                            , output v-max-marg
                            , output v-increase-pc
                            , output v-round-method
                            , output v-base
                            , output v-margins-range
                            , output v-margins-exists
                            , output v-increase-range
                            , output v-increase-exists
                            , output v-rmethod-range
                            , output v-rmethod-exists
    ) no-error  .
    if error-status :error
    then do:
        undo, return error "UI-on: Ошибка определения наценок и/или границ наценок для корневой группы." + {&new-line} + return-value.
    end.
    assign
        buf_temp_grplib_grp.min-marg = ( if v-margins-exists = yes then string( v-min-marg, "->>>>9.99" ) else "" )
        buf_temp_grplib_grp.max-marg = ( if v-margins-exists = yes then string( v-max-marg, "->>>>9.99" ) else "" )
        buf_temp_grplib_grp.increase-pc = ( if v-increase-exists = yes then v-increase-pc else buf_temp_grplib_grp.increase-pc )

    .
    run grp-obj-income-cli-value in this-procedure (
                            input 0
                            , input v-current-store-type
                            , input v-current-store-code
                            , output v-cli-type
                            , output v-cli-code
                            , output v-income-cli-range
                            , output v-income-cli-exists
    ) no-error  .
    if error-status :error
    then do:
        undo, return error "UI-on: Ошибка определения внутреннего поставщика для корневой группы." + {&new-line} + return-value.
    end.
    assign
        buf_temp_grplib_grp.cli-type = ( if v-income-cli-exists = yes then  v-cli-type else "" )
        buf_temp_grplib_grp.cli-code = ( if v-income-cli-exists = yes then  v-cli-code else 0 )
    .
            run grp-obj-notcorr-value in this-procedure (
                              input 0
                            , input v-current-store-type
                            , input v-current-store-code
                            , output v-notcorr
                            , output v-notcorr-range
                            , output v-notcorr-exists
            ) no-error  .
            if error-status :error
            then do:
                undo, return error "change-grp: Ошибка определения ЗАПРЕТ КОР ОП." + {&new-line} + return-value.
            end.
            assign
                buf_temp_grplib_grp.notcorr = ( if v-notcorr-exists = yes then  v-notcorr else "" )
            .

end.        /* NOT ( if v-grplib-not-fill-extra-info = yes ) */
for each buf_gds-grp no-lock
   where buf_gds-grp.upper-code = v-root-code
:
    run grplib-get-full-name in this-procedure (
          input buf_gds-grp.node-code
        , output v-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "create-new-line: Ошибка вычисления полного имени группы." .
    end.
    run grplib-get-sort-name in this-procedure (
          input buf_gds-grp.node-code
        , output v-sort-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "create-new-line: Ошибка вычисления полного имени группы." .
    end.
    run create-new-line in this-procedure (
          input buf_gds-grp.node-code
        , input buf_gds-grp.upper-code
        , input 1
        , input buf_gds-grp.is-term
        , input buf_gds-grp.node-name
        , input buf_gds-grp.print-code
        , input buf_gds-grp.increase-pc
        , input buf_gds-grp.calc-method
        , input "":U
        , input "":U
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
      find first buf_gds-grp no-lock
          where recid( buf_gds-grp ) = integer( entry( v-ii, p-recid-list ) )
      no-error .
      if not available buf_gds-grp
      then do:
          /* Не найдена группа, выбранная в прошлый раз. */
      end.
      else do:
        run expand-tree-for-grp in this-procedure (
            input buf_gds-grp.node-code
            , output v-focused-row
            , output v-reposition-row
            , output v-reposition-to-recid
        ) no-error .
        if error-status :error
        then do:
            undo, return error "UI-on: Не удалось раскрыть дерево групп." + {&new-line} + return-value.
        end.
        run b-mark-press ( input buf_gds-grp.node-code ) no-error .
      end.
    end.
  end.
  else do:
    assign
        v-reposition-row = 1
        v-focused-row    = 1
    .
    find first buf_gds-grp no-lock
         where recid( buf_gds-grp ) = integer( entry( num-entries( p-recid-list ), p-recid-list ) )
    no-error .
    if not available buf_gds-grp
    then do:
        /* Не найдена группа, выбранная в прошлый раз. */
    end.
    else do:
        run expand-tree-for-grp in this-procedure (
            input buf_gds-grp.node-code
            , output v-focused-row
            , output v-reposition-row
            , output v-reposition-to-recid
        ) no-error .
        if error-status :error
        then do:
            undo, return error "UI-on: Не удалось раскрыть дерево групп." + {&new-line} + return-value.
        end.
    end.
end.
end.
ASSIGN
b-print:MENU-MOUSE in frame {&frame-name} =  1
b-rum:MENU-MOUSE in frame {&frame-name} =  1
.
run enable_UI.
if not valid-handle(parparentproc) then do:
  disable
  b-print
  with frame {&frame-name} .
end.
hide    b-sel       in frame {&frame-name}
        b-mark      in frame {&frame-name}
        b-add       in frame {&frame-name}
        b-chg       in frame {&frame-name}
        b-del       in frame {&frame-name}
        b-move      in frame {&frame-name}
        b-scales    in frame {&frame-name}
        b-marg      in frame {&frame-name}
        b-nabor     in frame {&frame-name}
     .
if v-grplib-not-fill-extra-info = yes
then do:
    assign
        temp_grplib_grp.min-marg       :visible in browse br-list = no
        temp_grplib_grp.max-marg       :visible in browse br-list = no
        v-cli-name                     :visible in browse br-list = no
        temp_grplib_grp.increase-pc    :visible in browse br-list = no
        temp_grplib_grp.round-method   :visible in browse br-list = no
    .
end.
case p-button-list
:
when {&buttons-for-move}
then do:
    disable
        b-exit    with frame {&frame-name}
    .
    view
        b-sel    in frame {&frame-name}
    .
end.
when {&buttons-for-admin}
then do:
    view
        b-add    in frame {&frame-name}
        b-chg in frame {&frame-name}
        b-del in frame {&frame-name}
        b-move   in frame {&frame-name}
        b-arch   in frame {&frame-name}
        b-tax    in frame {&frame-name}
        b-marg   in frame {&frame-name}
        b-nabor  in frame {&frame-name}
    .
    if v-enable-change-grp = no
    then do:
        disable
            b-add
            b-chg
            b-del
            b-move
            b-nabor
        with frame {&frame-name}.
    end.
end.
when {&buttons-sel-scales}
then do:
    view
        b-scales
    .
    hide
        b-arch
        b-tax    in frame {&frame-name}
        b-marg   in frame {&frame-name}


    .
end.
when {&buttons-sel-term} or when {&button-sel-only}
then do:
    view
        b-sel    in frame {&frame-name}
    .
end.
when {&buttons-sel-mark} or when {&buttons-actn-sel-mark}
then do:
    view
        b-sel    in frame {&frame-name}
        b-mark in frame {&frame-name}
    .
end.
end case.
/*Параметры на объектах видны с УБД */
if (g#db-num <> 0) then do:
    view
        b-marg   in frame {&frame-name}
    .    
end.    
if v-current-store-code = 0
or transaction
then do:
  disable
  b-tax
  b-add
  b-chg
  b-del
  b-move
  with frame {&frame-name} .
end.
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
if b-marg :visible = yes
then do:
    run enable-button-marg in this-procedure ( input temp_grplib_grp.node-code ) no-error.
    if error-status :error
    then do:
        disable b-marg    with frame {&frame-name}.
    end.
end.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME