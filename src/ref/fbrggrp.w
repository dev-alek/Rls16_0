&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
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

Управление деревом групп блюд

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc        as widget-handle    no-undo.
define input parameter p-store-type         as character    no-undo.
define input parameter p-store-code         as integer      no-undo.
define input parameter p-button-list        as character    no-undo. /* список включенных кнопок */
define input-output parameter p-recid-list  as character    no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Управление деревом групп блюд".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/library.i     }
{ ref/fbrglib.i     }
{ cmp/library.i     }
{ gbl/cur-time.i    }
{ cmp/r-pril.i new  }
{ gbl/prn-lib.i     }
{ gbl/waitfram.i    }
{ gbl/usr-flt.i     }
{ gbl/chkleave.i    }
{ cmp/showinf.i     }
{ gbl/getcntxt.i def }

define variable v-fbrggrp-root-code         as integer          no-undo.
define variable v-found-grp-num             as integer  init 0  no-undo.
define variable v-full-search-string        as character        no-undo.
define variable v-full-search-next          as logical  init no no-undo.
define variable v-full-search-start-code    as integer          no-undo.
define variable v-found-grp-num-0             as integer  init 0  no-undo.
define variable v-full-search-string-0        as character        no-undo.
define variable v-full-search-next-0          as logical  init no no-undo.
define variable v-full-search-start-code-0    as integer          no-undo.
/*виден ли рубрикатор*/
define variable v-rubr                        as logical  init no no-undo.

define variable print-option as character no-undo.
define variable fbr-gds-grp-row as integer init 1 no-undo.  /* текущая запись fbr-gds-grp для перерисовки дерева */
define variable v-b-expand-col             as decimal no-undo .
define variable v-b-expand-all-col         as decimal no-undo .
define variable v-b-find-by-full-name-col  as decimal no-undo .
define variable v-b-find-by-substring-col  as decimal no-undo .
define variable v-b-search-col             as decimal no-undo .
define variable v-fi-search-col            as decimal no-undo .
define variable v-rubr-mode                as integer no-undo . /*0 нет 1 да*/

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

DEFINE BUFFER buf0_temp_fbrglib_grp FOR temp_fbrglib_grp.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dlg-grp
&Scoped-define BROWSE-NAME br-global

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf0_temp_fbrglib_grp temp_fbrglib_grp

/* Definitions for BROWSE br-global                                     */
&Scoped-define FIELDS-IN-QUERY-br-global buf0_temp_fbrglib_grp.sel no-label buf0_temp_fbrglib_grp.global-code buf0_temp_fbrglib_grp.name buf0_temp_fbrglib_grp.out-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-global
&Scoped-define SELF-NAME br-global
&Scoped-define QUERY-STRING-br-global FOR EACH buf0_temp_fbrglib_grp NO-LOCK  WHERE   buf0_temp_fbrglib_grp.obj-type = "":U AND buf0_temp_fbrglib_grp.obj-code = 0 by buf0_temp_fbrglib_grp.sort-name
&Scoped-define OPEN-QUERY-br-global OPEN QUERY {&SELF-NAME} FOR EACH buf0_temp_fbrglib_grp NO-LOCK  WHERE   buf0_temp_fbrglib_grp.obj-type = "":U AND buf0_temp_fbrglib_grp.obj-code = 0 by buf0_temp_fbrglib_grp.sort-name.
&Scoped-define TABLES-IN-QUERY-br-global buf0_temp_fbrglib_grp
&Scoped-define FIRST-TABLE-IN-QUERY-br-global buf0_temp_fbrglib_grp


/* Definitions for BROWSE br-list                                       */
&Scoped-define FIELDS-IN-QUERY-br-list temp_fbrglib_grp.sel no-label temp_fbrglib_grp.global-code temp_fbrglib_grp.name temp_fbrglib_grp.out-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-list
&Scoped-define SELF-NAME br-list
&Scoped-define QUERY-STRING-br-list FOR EACH temp_fbrglib_grp NO-LOCK where     temp_fbrglib_grp.obj-type = p-store-type  AND temp_fbrglib_grp.obj-code = p-store-code     by temp_fbrglib_grp.sort-name
&Scoped-define OPEN-QUERY-br-list OPEN QUERY {&SELF-NAME} FOR EACH temp_fbrglib_grp NO-LOCK where     temp_fbrglib_grp.obj-type = p-store-type  AND temp_fbrglib_grp.obj-code = p-store-code     by temp_fbrglib_grp.sort-name.
&Scoped-define TABLES-IN-QUERY-br-list temp_fbrglib_grp
&Scoped-define FIRST-TABLE-IN-QUERY-br-list temp_fbrglib_grp


/* Definitions for DIALOG-BOX Dlg-grp                                   */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dlg-grp ~
    ~{&OPEN-QUERY-br-global}~
    ~{&OPEN-QUERY-br-list}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit RECT-rubr b-mark b-sel b-add b-chg ~
b-del b-move b-goods b-print b-help B-global b-copy fi-kitchen-code ~
bt-sel-kitchen B-hist b-expand-0 b-expand-all-0 fi-search-0 ~
b-find-by-full-name-0 b-find-by-substring-0 b-search-0 b-expand ~
b-expand-all fi-search b-find-by-full-name b-find-by-substring b-search ~
B-copy0 B-link br-global br-list
&Scoped-Define DISPLAYED-OBJECTS fi-kitchen-type fi-kitchen-code ~
fi-search-0 fi-search

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-print
       MENU-ITEM m_classificator LABEL "Классификатор по объекту"
       MENU-ITEM m_browse       LABEL "Справочник"
       MENU-ITEM m_browse-global LABEL "Рубрикатор"
       MENU-ITEM m_term         LABEL "Содержимое терминальных групп".


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1 TOOLTIP "Добавить группу"
     BGCOLOR 8 .

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1 TOOLTIP "Изменить название и характеристики группы"
     BGCOLOR 8 .

DEFINE BUTTON b-copy
     LABEL "&Копировать"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-copy0
     LABEL "Копи&я->"
     SIZE 9 BY 1 TOOLTIP "Скопировать ~"ветку~" рубрикатора на объект".

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1 TOOLTIP "Удалить группу"
     BGCOLOR 8 .

DEFINE BUTTON b-exit
     LABEL "&Выход"
     SIZE 10 BY 1 TOOLTIP "Выход"
     BGCOLOR 8 .

DEFINE BUTTON b-expand
     LABEL ">>"
     SIZE 3.5 BY 1.13.

DEFINE BUTTON b-expand-0
     LABEL ">>"
     SIZE 3.5 BY 1.13.

DEFINE BUTTON b-expand-all
     LABEL ">>-->>"
     SIZE 7.5 BY 1.13.

DEFINE BUTTON b-expand-all-0
     LABEL ">>-->>"
     SIZE 7.5 BY 1.13.

DEFINE BUTTON b-find-by-full-name
     LABEL "+"
     SIZE 3 BY 1 TOOLTIP "Продолжить до полного имени (CTRL-D)"
     BGCOLOR 8 .

DEFINE BUTTON b-find-by-full-name-0
     LABEL "+"
     SIZE 3 BY 1 TOOLTIP "Продолжить до полного имени (CTRL-D)"
     BGCOLOR 8 .

DEFINE BUTTON b-find-by-substring
     LABEL "?"
     SIZE 3 BY 1 TOOLTIP "Найти подстроку во всех группах (CTRL-S)"
     BGCOLOR 8 .

DEFINE BUTTON b-find-by-substring-0
     LABEL "?"
     SIZE 3 BY 1 TOOLTIP "Найти подстроку во всех группах (CTRL-S)"
     BGCOLOR 8 .

DEFINE BUTTON B-global
     LABEL "&Рубр-тор"
     SIZE 10 BY 1.

DEFINE BUTTON b-goods
     LABEL "&Товары"
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1 TOOLTIP "Помощь"
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.

DEFINE BUTTON B-link
     LABEL "&Связь<-"
     SIZE 9 BY 1 TOOLTIP "Проставить рубрику группе блюд на объекте".

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-move
     LABEL "П&еренести"
     SIZE 10 BY 1 TOOLTIP "Переместить группу"
     BGCOLOR 8 .

DEFINE BUTTON b-print
     LABEL "Пе&чать"
     SIZE 10 BY 1 TOOLTIP "Печать списка групп".

DEFINE BUTTON b-search
     LABEL "Поиск"
     SIZE 10 BY 1.04
     BGCOLOR 8 .

DEFINE BUTTON b-search-0
     LABEL "Поиск"
     SIZE 10 BY 1.04
     BGCOLOR 8 .

DEFINE BUTTON b-sel
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON bt-sel-kitchen
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.63 BY 1.04.

DEFINE VARIABLE fi-kitchen-code AS INTEGER FORMAT ">>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 7.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-kitchen-type AS CHARACTER FORMAT "X(3)":U
     LABEL "Объект"
     VIEW-AS FILL-IN
     SIZE 5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-search AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 22.13 BY 1
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE fi-search-0 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 22.13 BY 1
     FGCOLOR 1  NO-UNDO.

DEFINE RECTANGLE RECT-rubr
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 12 BY 1
     BGCOLOR 9 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-global FOR
      buf0_temp_fbrglib_grp SCROLLING.

DEFINE QUERY br-list FOR
      temp_fbrglib_grp SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-global
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-global Dlg-grp _FREEFORM
  QUERY br-global DISPLAY
      buf0_temp_fbrglib_grp.sel           format "X(1)" no-label
      buf0_temp_fbrglib_grp.global-code   format ">>>>9"      COLUMN-LABEL "Код"
      buf0_temp_fbrglib_grp.name          format "X(71)"      COLUMN-LABEL "Наименование группы"
      buf0_temp_fbrglib_grp.out-code      format ">>>>9"      COLUMN-LABEL "Код на!кассе"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 42 BY 16.67
         FGCOLOR 1
         TITLE FGCOLOR 1 "Группы блюд (Рубрикатор)".

DEFINE BROWSE br-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-list Dlg-grp _FREEFORM
  QUERY br-list DISPLAY
      temp_fbrglib_grp.sel           format "X(1)" no-label
      temp_fbrglib_grp.global-code   format ">>>>9"      COLUMN-LABEL "Руб-р"
      temp_fbrglib_grp.name          format "X(71)"      COLUMN-LABEL "Наименование группы"
      temp_fbrglib_grp.out-code      format ">>>>9"      COLUMN-LABEL "Код на!кассе"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 56 BY 16.67
         TITLE "Группы блюд для объекта".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dlg-grp
     b-exit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 14
     b-add AT ROW 1 COL 24
     b-chg AT ROW 1 COL 34
     b-del AT ROW 1 COL 44
     b-move AT ROW 1 COL 54
     b-goods AT ROW 1 COL 64
     b-print AT ROW 1 COL 79.38
     b-help AT ROW 1 COL 89.38
     B-global AT ROW 2 COL 12
     b-copy AT ROW 2 COL 24
     fi-kitchen-type AT ROW 2 COL 35.38 COLON-ALIGNED
     fi-kitchen-code AT ROW 2 COL 40.75 COLON-ALIGNED NO-LABEL
     bt-sel-kitchen AT ROW 2 COL 50.13
     B-hist AT ROW 2 COL 79.38
     b-expand-0 AT ROW 3 COL 1
     b-expand-all-0 AT ROW 3 COL 4.5
     fi-search-0 AT ROW 3 COL 12 NO-LABEL
     b-find-by-full-name-0 AT ROW 3 COL 34.38
     b-find-by-substring-0 AT ROW 3 COL 37.38
     b-search-0 AT ROW 3 COL 40.38
     b-expand AT ROW 3 COL 51
     b-expand-all AT ROW 3 COL 54.5
     fi-search AT ROW 3 COL 62 NO-LABEL
     b-find-by-full-name AT ROW 3 COL 84
     b-find-by-substring AT ROW 3 COL 87
     b-search AT ROW 3 COL 90
     B-copy0 AT ROW 4.25 COL 33.5
     B-link AT ROW 4.25 COL 44
     br-global AT ROW 5.25 COL 1
     br-list AT ROW 5.25 COL 44
     RECT-rubr AT ROW 2 COL 11
     SPACE(77.00) SKIP(19.12)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Группы блюд".


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
                                                                        */
/* BROWSE-TAB br-global B-link Dlg-grp */
/* BROWSE-TAB br-list br-global Dlg-grp */
ASSIGN
       FRAME Dlg-grp:SCROLLABLE       = FALSE
       FRAME Dlg-grp:HIDDEN           = TRUE.

ASSIGN
       B-copy0:HIDDEN IN FRAME Dlg-grp           = TRUE.

ASSIGN
       b-expand-0:HIDDEN IN FRAME Dlg-grp           = TRUE.

ASSIGN
       b-expand-all-0:HIDDEN IN FRAME Dlg-grp           = TRUE.

ASSIGN
       b-find-by-full-name-0:HIDDEN IN FRAME Dlg-grp           = TRUE.

ASSIGN
       b-find-by-substring-0:HIDDEN IN FRAME Dlg-grp           = TRUE.

ASSIGN
       B-link:HIDDEN IN FRAME Dlg-grp           = TRUE.

ASSIGN
       b-print:POPUP-MENU IN FRAME Dlg-grp       = MENU MENU-b-print:HANDLE.

ASSIGN
       b-search-0:HIDDEN IN FRAME Dlg-grp           = TRUE.

ASSIGN
       br-global:SEPARATOR-FGCOLOR IN FRAME Dlg-grp      = 1.

/* SETTINGS FOR FILL-IN fi-kitchen-type IN FRAME Dlg-grp
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-search IN FRAME Dlg-grp
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-search-0 IN FRAME Dlg-grp
   ALIGN-L                                                              */
ASSIGN
       fi-search-0:HIDDEN IN FRAME Dlg-grp           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-global
/* Query rebuild information for BROWSE br-global
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf0_temp_fbrglib_grp NO-LOCK
 WHERE   buf0_temp_fbrglib_grp.obj-type = "":U
AND buf0_temp_fbrglib_grp.obj-code = 0
by buf0_temp_fbrglib_grp.sort-name.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-global */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-list
/* Query rebuild information for BROWSE br-list
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp_fbrglib_grp NO-LOCK where
    temp_fbrglib_grp.obj-type = p-store-type
 AND temp_fbrglib_grp.obj-code = p-store-code
    by temp_fbrglib_grp.sort-name.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-list */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dlg-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dlg-grp Dlg-grp
ON ENDKEY OF FRAME Dlg-grp /* Группы блюд */
DO:
    run gbl/markqwa.p (
          input b-mark:visible
        , input p-recid-list
    ) no-error.
    if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dlg-grp Dlg-grp
ON WINDOW-CLOSE OF FRAME Dlg-grp /* Группы блюд */
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
        input temp_fbrglib_grp.node-code
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка добавления группы блюд."
        skip return-value
        skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
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
        input temp_fbrglib_grp.node-code
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка изменения группы блюд."
        skip return-value
        skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-copy Dlg-grp
ON CHOOSE OF b-copy IN FRAME Dlg-grp /* Копировать */
DO:
    define variable v-recid-list    as character      no-undo.
    define variable v-is-invalid    as logical        no-undo.
    define variable v-from-obj-type as character      no-undo.
    define variable v-from-obj-code as integer        no-undo.
    define variable v-yesno         as logical        no-undo.

    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.

    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.obj-type = p-store-type
           and buf_fbr-gds-grp.obj-code = p-store-code
    no-error.
    if available buf_fbr-gds-grp
    then do:
        message
            "Список групп блюд не пуст."
            skip(1)
            skip "Копировать группы с другого объекта"
            skip "можно только полностью."
            skip "Для этого список групп блюд текущего объекта"
            skip "должен быть очищен."
        view-as alert-box error
        title "Копирование групп блюд".
        undo, return no-apply.
    end.
    assign
        v-recid-list = ""
    .
    run ref/fbrggrp.w (
          input parparentproc
        , input p-store-type
        , input p-store-code
        , input {&buttons-for-objcopy}
        , input-output v-recid-list
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка выбора объекта для копирования групп блюд."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply.
    end.
    if num-entries( v-recid-list ) = 2
    then do:
        assign
            v-from-obj-type = entry( 1, v-recid-list )
            v-from-obj-code = integer( entry( 2, v-recid-list ) )
        .
        if  v-from-obj-type = p-store-type
        and v-from-obj-code = p-store-code
        then do:
            message
                "Для копирования выбран текущий объект."
                skip(1)
                skip "Копирование групп блюд невозможно."
            view-as alert-box error.
            undo, return no-apply.
        end.
        run check-object in this-procedure (
              input v-from-obj-type
            , input v-from-obj-code
            , output v-is-invalid
        ).
        if v-is-invalid = yes
        or ( v-from-obj-type = p-store-type
         and v-from-obj-code = p-store-code )
        then do:
            message
                "Неверно выбран объект для копирования групп блюд."
            view-as alert-box error.
            undo, return no-apply.
        end.
        message
            "Выбран объект для копирования групп блюд."
            skip "Структура групп блюд и привязки"
            skip "товаров к группам блюд будут"
            skip "скопированы с выбранного объекта."
            skip(1)
            skip "Выбранный объект:" v-from-obj-type v-from-obj-code
            skip "Текущий объект:" p-store-type p-store-code
            skip(1)
            skip "Копировать группы блюд?"
        view-as alert-box question
        buttons yes-no
        title "Копирование групп блюд"
        update v-yesno
        .
        if v-yesno = no
        then do:
            message
                "Копирование групп блюд прервано."
            view-as alert-box information.
            undo, return no-apply.
        end.
        run copy-group-list-from-obj in this-procedure (
              input v-from-obj-type
            , input v-from-obj-code
            , input p-store-type
            , input p-store-code
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip "Ошибка копирования групп блюд с другого объекта."
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return no-apply .
        end.
        run UI-on in this-procedure no-error .
    end.        /* if num-entries( v-recid-list ) = 2 */
    else do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка передачи параметров для копирования групп."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-copy0
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-copy0 Dlg-grp
ON CHOOSE OF B-copy0 IN FRAME Dlg-grp /* Копия-> */
DO:
  run copy-from-global-grp in this-procedure (
        input temp_fbrglib_grp.node-code
        ,input buf0_temp_fbrglib_grp.node-code
        ,input buf0_temp_fbrglib_grp.global-code
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка добавления группы блюд."
        skip return-value
        skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply.
    end.
    run UI-on in this-procedure no-error .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dlg-grp
ON CHOOSE OF b-del IN FRAME Dlg-grp /* Удалить */
DO:
    run delete-grp in this-procedure (
          input temp_fbrglib_grp.node-code
        , input yes
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка удаления группы блюд."
        skip return-value
        skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
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
    define variable v-fbr-gds-grp-recid     as recid             no-undo.
    if p-button-list = {&buttons-for-objcopy}
    then do:
        assign
            fi-kitchen-type
            fi-kitchen-code
        .
        assign
            p-recid-list = fi-kitchen-type + ",":U + string( fi-kitchen-code )
        .
    end.        /* if p-button-list = {&buttons-for-objcopy} */
    else do:
        run get-current-recid in this-procedure (
            input (if v-rubr-mode = 1 then buf0_temp_fbrglib_grp.node-code else temp_fbrglib_grp.node-code)
            , output v-fbr-gds-grp-recid
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
            view-as alert-box error.
            undo, return no-apply .
        end.
        run gbl/markqwa.p (
            input b-mark:visible
            , input p-recid-list
        ) no-error.
        if error-status:error then return no-apply.
        assign
            fbr-gds-grp-row  = v-fbr-gds-grp-recid
            p-recid-list = ""
        .
        assign
        v-uf-list_ = (if v-uf-list_ = "":U then ({&delim-par}) else v-uf-list_)
        entry((v-rubr-mode + 1), v-uf-List_,  {&delim-par}) = (if fbr-gds-grp-row = ?
                                                            then {&question-mark}
                                                            else string(fbr-gds-grp-row))
        .
        run uf-set in this-procedure(
            input  {&uf-fbr-gds-grp-p}
            ,input v-cntxt-userid
            ,input v-uf-List_
            ,input v-uf-Naim
            ,input v-uf-print-graft
            ,input v-uf-sort-gr
            ,input v-uf-type-price
            ,input v-uf-type-val
        )  no-error .
    end.        /* NOT ( if p-button-list = {&buttons-for-objcopy} ) */
    apply "GO" TO FRAME {&FRAME-NAME} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-expand
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-expand Dlg-grp
ON CHOOSE OF b-expand IN FRAME Dlg-grp /* >> */
DO:
    if temp_fbrglib_grp.node-code = v-fbrggrp-root-code
    then do:
        run collapse-all-on-first-level in THIS-PROCEDURE (INPUT p-store-type, INPUT p-store-code) no-error .
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
    if temp_fbrglib_grp.mark <> {&closed-noterminal-grp-mark}
    and temp_fbrglib_grp.mark <> {&opened-noterminal-grp-mark}
    then do:
        return no-apply.
    end.

    run expand-or-collapse-item in this-procedure ( INPUT p-store-type
                                                  , INPUT p-store-code
                                                  , INPUT temp_fbrglib_grp.mark
                                                  , INPUT temp_fbrglib_grp.node-code) no-error .
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


&Scoped-define SELF-NAME b-expand-0
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-expand-0 Dlg-grp
ON CHOOSE OF b-expand-0 IN FRAME Dlg-grp /* >> */
DO:
    if buf0_temp_fbrglib_grp.node-code = v-fbrggrp-root-code
    then do:
        run collapse-all-on-first-level in THIS-PROCEDURE (INPUT "":U, INPUT 0) no-error .
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
    if buf0_temp_fbrglib_grp.mark <> {&closed-noterminal-grp-mark}
    and buf0_temp_fbrglib_grp.mark <> {&opened-noterminal-grp-mark}
    then do:
        return no-apply.
    end.

    run expand-or-collapse-item in this-procedure ( INPUT "":U
                                                  , INPUT 0
                                                  , INPUT buf0_temp_fbrglib_grp.mark
                                                  , INPUT buf0_temp_fbrglib_grp.node-code) no-error .
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
    if available temp_fbrglib_grp
    then do:
        run expand-all-from-current in this-procedure (INPUT p-store-type, INPUT p-store-code,
            input temp_fbrglib_grp.node-code
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
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-expand-all-0
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-expand-all-0 Dlg-grp
ON CHOOSE OF b-expand-all-0 IN FRAME Dlg-grp /* >>-->> */
DO:
    if available buf0_temp_fbrglib_grp
    then do:
        run expand-all-from-current in this-procedure (INPUT "":U, INPUT 0,
            input buf0_temp_fbrglib_grp.node-code
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
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-find-by-full-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-find-by-full-name Dlg-grp
ON CHOOSE OF b-find-by-full-name IN FRAME Dlg-grp /* + */
DO:
    define variable v-new-name as character no-undo.
    run fbrglib-expand-name in this-procedure (
          input p-store-type
        , input p-store-code
        , input fi-search :screen-value
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


&Scoped-define SELF-NAME b-find-by-full-name-0
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-find-by-full-name-0 Dlg-grp
ON CHOOSE OF b-find-by-full-name-0 IN FRAME Dlg-grp /* + */
DO:
    define variable v-new-name as character no-undo.
    run fbrglib-expand-name in this-procedure (
          input "":U
        , input 0
        , input fi-search-0 :screen-value
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
            v-new-name = fi-search-0 :screen-value
        .
    end.
    assign
        fi-search-0 :screen-value  = right-trim( v-new-name, {&delim-grp} )
        fi-search-0 :cursor-offset = length( v-new-name ) + 1
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-find-by-full-name-0 Dlg-grp
ON LEAVE OF b-find-by-full-name-0 IN FRAME Dlg-grp /* + */
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
    run fbrglib-find-by-substring in this-procedure (
          input p-store-type
        , input p-store-code
        , input v-full-search-start-code
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


&Scoped-define SELF-NAME b-find-by-substring-0
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-find-by-substring-0 Dlg-grp
ON CHOOSE OF b-find-by-substring-0 IN FRAME Dlg-grp /* ? */
DO:
    define variable v-new-name as character no-undo.
    define variable v-new-code as integer   no-undo.

    if v-full-search-next-0 = no
    then do:
        assign
            v-full-search-string-0     = fi-search-0 :screen-value
            v-full-search-next-0       = yes
            v-full-search-start-code-0 = 0
        .
    end.
    { gbl/working.i }
    run fbrglib-find-by-substring in this-procedure (
          input "":U
        , input 0
        , input v-full-search-start-code-0
        , input v-full-search-string-0
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
            skip "Не найдена строка '" v-full-search-string-0 "' в имени группы."
        view-as alert-box information
        title "Поиск завершен".
        assign
            v-new-name               = fi-search-0 :screen-value
            v-full-search-string-0     = ""
            v-full-search-next-0       = no
            v-full-search-start-code-0 = 0
        .
    end.
    else do:
        assign
            v-full-search-start-code-0 = v-new-code
        .
    end.
    assign
        fi-search-0 :screen-value  = right-trim( v-new-name, {&delim-grp} )
        fi-search-0 :cursor-offset = length( v-new-name ) + 1
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-find-by-substring-0 Dlg-grp
ON LEAVE OF b-find-by-substring-0 IN FRAME Dlg-grp /* ? */
DO:
    assign
        v-found-grp-num  = 0
        b-search :label = "Поиск"
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-global
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-global Dlg-grp
ON CHOOSE OF B-global IN FRAME Dlg-grp /* Рубр-тор */
DO:
  assign
  v-rubr = NOT v-rubr.
  RUN proc-b-rubr IN THIS-PROCEDURE(v-rubr).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-goods Dlg-grp
ON CHOOSE OF b-goods IN FRAME Dlg-grp /* Товары */
DO:

    define variable v-cancel    as logical        no-undo.

    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.

    if available temp_fbrglib_grp
    then do:
        run ref/fbrggrpg.w (
              input parparentproc
            , input p-store-type
            , input p-store-code
            , input temp_fbrglib_grp.node-code
            , output v-cancel
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip "Ошибка привязки товаров к группе блюд."
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return no-apply .
        end.
        if v-cancel = yes
        then do:
            undo, return no-apply .
        end.
        run get-first-char in this-procedure (
              input p-store-type
            , input p-store-code
            , input temp_fbrglib_grp.node-code
            , output temp_fbrglib_grp.mark
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip "Ошибка вычисления первого символа для отображения группы"
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return no-apply .
        end.
        find first buf_fbr-gds-grp no-lock
             where buf_fbr-gds-grp.obj-type     = p-store-type
               and buf_fbr-gds-grp.obj-code     = p-store-code
               and buf_fbr-gds-grp.node-code    = temp_fbrglib_grp.node-code
        .
        assign
            temp_fbrglib_grp.name = fill( " ", {&tab-size} * temp_fbrglib_grp.level )
                                            + temp_fbrglib_grp.mark
                                            + " "
                                            + buf_fbr-gds-grp.node-name
        .
        br-list :refresh().
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dlg-grp
ON CHOOSE OF B-hist IN FRAME Dlg-grp /* История */
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  IF AVAILABLE temp_fbrglib_grp THEN DO:
      run ref/cfggrphi.w (
                  input parparentproc
                 ,INPUT '':U /*bttns*/
                 ,INPUT 'one'
                 ,INPUT temp_fbrglib_grp.obj-type
                 ,INPUT temp_fbrglib_grp.obj-code
                 ,INPUT temp_fbrglib_grp.node-code
                 ,INPUT '':U /*p-attr-code*/
                 ,INPUT NO /*p-is-del*/
                 ,INPUT '':U /*p-subject*/
                 ,OUTPUT v-rid-list) NO-ERROR.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-link
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-link Dlg-grp
ON CHOOSE OF B-link IN FRAME Dlg-grp /* Связь<- */
DO:
   run link-grp in this-procedure (
        input temp_fbrglib_grp.node-code
        ,input buf0_temp_fbrglib_grp.node-code
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка изменения группы блюд."
        skip return-value
        skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dlg-grp
ON CHOOSE OF b-mark IN FRAME Dlg-grp /* * */
DO:
    run b-mark-press (INPUT p-store-type, INPUT p-store-code,  input temp_fbrglib_grp.node-code ) no-error .
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
        input temp_fbrglib_grp.node-code
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
    run print-grp in this-procedure (
          input p-store-type
        , input p-store-code
        , input temp_fbrglib_grp.node-code
    ) no-error .
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


&Scoped-define SELF-NAME b-search
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-search Dlg-grp
ON CHOOSE OF b-search IN FRAME Dlg-grp /* Поиск */
DO:
    if fi-search :screen-value = ""
    or fi-search :screen-value = ?
    then do:        /* Ничего не делать, если строка поиска пуста. */
        return no-apply.
    end.
    run find-grp-in-browse in this-procedure ( INPUT p-store-type
                                             , INPUT p-store-code
                                            , input fi-search :screen-value
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


&Scoped-define SELF-NAME b-search-0
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-search-0 Dlg-grp
ON CHOOSE OF b-search-0 IN FRAME Dlg-grp /* Поиск */
DO:
    if fi-search-0 :screen-value = ""
    or fi-search-0 :screen-value = ?
    then do:        /* Ничего не делать, если строка поиска пуста. */
        return no-apply.
    end.
    run find-grp-in-browse in this-procedure ( INPUT "":U
                                             , INPUT 0
                                             , input fi-search-0 :screen-value
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-search-0 Dlg-grp
ON LEAVE OF b-search-0 IN FRAME Dlg-grp /* Поиск */
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
    run fill-output-parameters-on-exit in this-procedure (
         input (IF v-rubr-mode = 1 then "":U else p-store-type)
        ,input (IF v-rubr-mode = 1 then 0    else p-store-code)
        ,input (IF v-rubr-mode = 1
               THEN BUF0_temp_fbrglib_grp.node-code
               ELSE temp_fbrglib_grp.node-code)

    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка передачи параметров списка групп."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
          skip (1) "Закрыть список групп?"
        view-as alert-box error buttons yes-no update v-yesno.
        if v-yesno = no
        then do:
            undo, return no-apply .
        end.
    end.
    apply "WINDOW-CLOSE" TO FRAME {&FRAME-NAME} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-global
&Scoped-define SELF-NAME br-global
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-global Dlg-grp
ON + OF br-global IN FRAME Dlg-grp /* Группы блюд (Рубрикатор) */
DO:
    if buf0_temp_fbrglib_grp.mark = {&closed-noterminal-grp-mark}
    then do:
        run expand-item in this-procedure ( INPUT "":U, INPUT 0, input buf0_temp_fbrglib_grp.node-code, input yes ) no-error .
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-global Dlg-grp
ON - OF br-global IN FRAME Dlg-grp /* Группы блюд (Рубрикатор) */
DO:
    if buf0_temp_fbrglib_grp.mark = {&opened-noterminal-grp-mark}
    then do:
        run collapse-item in this-procedure ( INPUT "":U, INPUT 0, input temp_fbrglib_grp.node-code, input yes ) no-error .
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-global Dlg-grp
ON END OF br-global IN FRAME Dlg-grp /* Группы блюд (Рубрикатор) */
DO:
    define variable v-row-amount     as integer           no-undo.
    run get-row-amount in this-procedure (INPUT "":U, INPUT 0,  output v-row-amount ) no-error.
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
    reposition br-global to row v-row-amount.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-global Dlg-grp
ON HOME OF br-global IN FRAME Dlg-grp /* Группы блюд (Рубрикатор) */
DO:
    reposition br-global to row 1.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-global Dlg-grp
ON MOUSE-SELECT-DBLCLICK OF br-global IN FRAME Dlg-grp /* Группы блюд (Рубрикатор) */
DO:
    if buf0_temp_fbrglib_grp.mark <> {&closed-noterminal-grp-mark}
    and buf0_temp_fbrglib_grp.mark <> {&opened-noterminal-grp-mark}
    then do:
        return no-apply.
    end.

    run expand-or-collapse-item in this-procedure ( input "":U
                                                   ,input 0
                                                   ,input buf0_temp_fbrglib_grp.mark
                                                   ,input buf0_temp_fbrglib_grp.node-code) no-error .
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-global Dlg-grp
ON RETURN OF br-global IN FRAME Dlg-grp /* Группы блюд (Рубрикатор) */
DO:
    if buf0_temp_fbrglib_grp.mark <> {&closed-noterminal-grp-mark}
    and buf0_temp_fbrglib_grp.mark <> {&opened-noterminal-grp-mark}
    then do:
        return no-apply.
    end.

    run expand-or-collapse-item in this-procedure ( input "":U
                                                   ,input 0
                                                   ,input  buf0_temp_fbrglib_grp.mark
                                                   ,input  buf0_temp_fbrglib_grp.node-code
                                                   ) no-error .
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-global Dlg-grp
ON VALUE-CHANGED OF br-global IN FRAME Dlg-grp /* Группы блюд (Рубрикатор) */
DO:
    if buf0_temp_fbrglib_grp.level <> 0
    then do:
        assign
            fi-search-0 :screen-value = right-trim( buf0_temp_fbrglib_grp.full-name, {&delim-grp} )
        .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-list
&Scoped-define SELF-NAME br-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-list Dlg-grp
ON + OF br-list IN FRAME Dlg-grp /* Группы блюд для объекта */
DO:
    if temp_fbrglib_grp.mark = {&closed-noterminal-grp-mark}
    then do:
        run expand-item in this-procedure (INPUT p-store-type, INPUT p-store-code, input temp_fbrglib_grp.node-code, input yes ) no-error .
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
ON - OF br-list IN FRAME Dlg-grp /* Группы блюд для объекта */
DO:
    if temp_fbrglib_grp.mark = {&opened-noterminal-grp-mark}
    then do:
        run collapse-item in this-procedure (INPUT p-store-type, INPUT p-store-code,  input temp_fbrglib_grp.node-code, input yes ) no-error .
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
ON DELETE-CHARACTER OF br-list IN FRAME Dlg-grp /* Группы блюд для объекта */
DO:
    if b-del :sensitive = yes
    and b-del :visible = yes
    then do:
        run delete-grp in this-procedure (
            input temp_fbrglib_grp.node-code
            , input yes
        ) no-error .
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка удаления группы блюд."
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
ON END OF br-list IN FRAME Dlg-grp /* Группы блюд для объекта */
DO:
    define variable v-row-amount     as integer           no-undo.
    run get-row-amount in this-procedure ( INPUT p-store-type, INPUT p-store-code, output v-row-amount ) no-error.
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
ON HOME OF br-list IN FRAME Dlg-grp /* Группы блюд для объекта */
DO:
    reposition br-list to row 1.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-list Dlg-grp
ON INSERT-MODE OF br-list IN FRAME Dlg-grp /* Группы блюд для объекта */
DO:
    if b-add :sensitive = yes
    and b-add :visible = yes
    then do:
        run add-grp in this-procedure (
             input temp_fbrglib_grp.node-code
        ) no-error .
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка добавления группы блюд."
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
ON MOUSE-SELECT-DBLCLICK OF br-list IN FRAME Dlg-grp /* Группы блюд для объекта */
DO:
    if temp_fbrglib_grp.mark <> {&closed-noterminal-grp-mark}
    and temp_fbrglib_grp.mark <> {&opened-noterminal-grp-mark}
    then do:
        return no-apply.
    end.

    run expand-or-collapse-item in this-procedure ( INPUT p-store-type
                                                  , INPUT p-store-code
                                                  , INPUT temp_fbrglib_grp.mark
                                                  , INPUT temp_fbrglib_grp.node-code)  no-error .
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
ON RETURN OF br-list IN FRAME Dlg-grp /* Группы блюд для объекта */
DO:
    if temp_fbrglib_grp.mark <> {&closed-noterminal-grp-mark}
    and temp_fbrglib_grp.mark <> {&opened-noterminal-grp-mark}
    then do:
        return no-apply.
    end.

    run expand-or-collapse-item in this-procedure ( INPUT p-store-type
                                                  , INPUT p-store-code
                                                  , INPUT temp_fbrglib_grp.mark
                                                  , INPUT temp_fbrglib_grp.node-code
                                                   ) no-error .
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-global Dlg-grp
ON VALUE-CHANGED OF br-global IN FRAME Dlg-grp /* Группы блюд (Рубрикатор) */
DO:
    if buf0_temp_fbrglib_grp.level <> 0
    then do:
        assign
            fi-search-0 :screen-value = right-trim( buf0_temp_fbrglib_grp.full-name, {&delim-grp} )
        .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-list
&Scoped-define SELF-NAME br-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-list Dlg-grp
ON + OF br-list IN FRAME Dlg-grp /* Группы блюд для объекта */
DO:
    if temp_fbrglib_grp.mark = {&closed-noterminal-grp-mark}
    then do:
        run expand-item in this-procedure (INPUT p-store-type, INPUT p-store-code, input temp_fbrglib_grp.node-code, input yes ) no-error .
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
ON - OF br-list IN FRAME Dlg-grp /* Группы блюд для объекта */
DO:
    if temp_fbrglib_grp.mark = {&opened-noterminal-grp-mark}
    then do:
        run collapse-item in this-procedure (INPUT p-store-type, INPUT p-store-code,  input temp_fbrglib_grp.node-code, input yes ) no-error .
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
ON DELETE-CHARACTER OF br-list IN FRAME Dlg-grp /* Группы блюд для объекта */
DO:
    if b-del :sensitive = yes
    and b-del :visible = yes
    then do:
        run delete-grp in this-procedure (
            input temp_fbrglib_grp.node-code
            , input yes
        ) no-error .
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка удаления группы блюд."
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
ON END OF br-list IN FRAME Dlg-grp /* Группы блюд для объекта */
DO:
    define variable v-row-amount     as integer           no-undo.
    run get-row-amount in this-procedure ( INPUT p-store-type, INPUT p-store-code, output v-row-amount ) no-error.
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
ON HOME OF br-list IN FRAME Dlg-grp /* Группы блюд для объекта */
DO:
    reposition br-list to row 1.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-list Dlg-grp
ON INSERT-MODE OF br-list IN FRAME Dlg-grp /* Группы блюд для объекта */
DO:
    if b-add :sensitive = yes
    and b-add :visible = yes
    then do:
        run add-grp in this-procedure (
             input temp_fbrglib_grp.node-code
        ) no-error .
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка добавления группы блюд."
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
ON MOUSE-SELECT-DBLCLICK OF br-list IN FRAME Dlg-grp /* Группы блюд для объекта */
DO:
    if temp_fbrglib_grp.mark <> {&closed-noterminal-grp-mark}
    and temp_fbrglib_grp.mark <> {&opened-noterminal-grp-mark}
    then do:
        return no-apply.
    end.

    run expand-or-collapse-item in this-procedure ( INPUT p-store-type
                                                  , INPUT p-store-code
                                                  , INPUT temp_fbrglib_grp.mark
                                                  , INPUT temp_fbrglib_grp.node-code)  no-error .
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
ON RETURN OF br-list IN FRAME Dlg-grp /* Группы блюд для объекта */
DO:
    if temp_fbrglib_grp.mark <> {&closed-noterminal-grp-mark}
    and temp_fbrglib_grp.mark <> {&opened-noterminal-grp-mark}
    then do:
        return no-apply.
    end.

    run expand-or-collapse-item in this-procedure ( INPUT p-store-type
                                                  , INPUT p-store-code
                                                  , INPUT temp_fbrglib_grp.mark
                                                  , INPUT temp_fbrglib_grp.node-code

                                                  ) no-error .
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
ON VALUE-CHANGED OF br-list IN FRAME Dlg-grp /* Группы блюд для объекта */
DO:
    if temp_fbrglib_grp.level <> 0
    then do:
        assign
            fi-search :screen-value = right-trim( temp_fbrglib_grp.full-name, {&delim-grp} )
        .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-kitchen
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-kitchen Dlg-grp
ON CHOOSE OF bt-sel-kitchen IN FRAME Dlg-grp /* ... */
DO:
    run select-kitchen in this-procedure (
          input fi-kitchen-type
        , input fi-kitchen-code
        , output fi-kitchen-type
        , output fi-kitchen-code
    ).
    display
        fi-kitchen-type
        fi-kitchen-code
    with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-kitchen-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-kitchen-code Dlg-grp
ON LEAVE OF fi-kitchen-code IN FRAME Dlg-grp
DO:
    define variable v-is-invalid    as logical        no-undo.

    if chkleave (
         input last-event :widget-enter /* p-widget-enter */
       , input "b-cancel,b-help,b-stop-cycle":u /* p-button-list  */
        )
    then do:
        run check-object in this-procedure (
              input fi-kitchen-type :screen-value
            , input integer( fi-kitchen-code :screen-value )
            , output v-is-invalid
        ).
        if v-is-invalid = yes
        then do:
            message
                "Неверно выбран объект."
            view-as alert-box error.
            undo, return no-apply.
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-kitchen-code Dlg-grp
ON RETURN OF fi-kitchen-code IN FRAME Dlg-grp
DO:
    run get-obj-type in this-procedure (
          input integer( fi-kitchen-code :screen-value )
        , output fi-kitchen-type
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка при определении типа объекта."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if fi-kitchen-type = ?
    then do:
        message
            "Объект не найден"
            skip "или не определен тип объекта"
        view-as alert-box error.
        undo, return no-apply.
    end.
    else do:
        display
            fi-kitchen-type
        with frame {&frame-name} .
    end.
    assign
        fi-kitchen-code
    .
    assign
        p-store-type = fi-kitchen-type
        p-store-code = fi-kitchen-code
    .
    run ui-on in this-procedure.
    apply "entry":U to br-list in frame {&frame-name} .
    return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-search
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-search Dlg-grp
ON CTRL-D OF fi-search IN FRAME Dlg-grp
DO:
    define variable v-new-name as character no-undo.

    run fbrglib-expand-name in this-procedure (
          input p-store-type
        , input p-store-code
        , input fi-search :screen-value
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
    run fbrglib-find-by-substring in this-procedure (
          input p-store-type
        , input p-store-code
        , input v-full-search-start-code
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
    run find-grp-in-browse in this-procedure ( INPUT p-store-type
                                              ,INPUT p-store-code
                                              ,input fi-search :screen-value
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


&Scoped-define SELF-NAME fi-search-0
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-search-0 Dlg-grp
ON CTRL-D OF fi-search-0 IN FRAME Dlg-grp
DO:
    define variable v-new-name as character no-undo.

    run fbrglib-expand-name in this-procedure (
          input "":U
        , input 0
        , input fi-search-0 :screen-value
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
            skip "'" + fi-search-0 :screen-value + "'"
        view-as alert-box information.
        assign
            v-new-name = fi-search-0 :screen-value
        .
    end.
    assign
        fi-search-0 :screen-value  = right-trim( v-new-name, {&delim-grp} )
        fi-search-0 :cursor-offset = length( v-new-name ) + 1
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-search-0 Dlg-grp
ON CTRL-S OF fi-search-0 IN FRAME Dlg-grp
DO:
    define variable v-new-name as character no-undo.
    define variable v-new-code as integer   no-undo.

    if v-full-search-next-0 = no
    then do:
        assign
            v-full-search-string-0     = fi-search-0 :screen-value
            v-full-search-next-0       = yes
            v-full-search-start-code-0 = 0
        .
    end.
    { gbl/working.i }
    run fbrglib-find-by-substring in this-procedure (
          input "":U
        , input 0
        , input v-full-search-start-code-0
        , input v-full-search-string-0
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
            skip "Не найдена строка '" v-full-search-string-0 "' в имени группы."
        view-as alert-box information
        title "Поиск завершен".
        assign
            v-new-name               = fi-search-0 :screen-value
            v-full-search-string-0     = ""
            v-full-search-next-0       = no
            v-full-search-start-code-0 = 0
        .
    end.
    else do:
        assign
            v-full-search-start-code-0 = v-new-code
        .
    end.
    assign
        fi-search-0 :screen-value  = right-trim( v-new-name, {&delim-grp} )
        fi-search-0 :cursor-offset = length( v-new-name ) + 1
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-search-0 Dlg-grp
ON LEAVE OF fi-search-0 IN FRAME Dlg-grp
DO:
    if fi-search-0 :screen-value <> v-full-search-string-0
    then do:
        assign
            v-full-search-string-0     = ""
            v-full-search-next-0       = no
            v-full-search-start-code-0 = 0
        .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-search-0 Dlg-grp
ON RETURN OF fi-search-0 IN FRAME Dlg-grp
DO:
    if fi-search-0 :screen-value = ""
    or fi-search-0 :screen-value = ?
    then do:        /* Ничего не делать, если строка поиска пуста. */
        return no-apply.
    end.
    run find-grp-in-browse in this-procedure (
                                               INPUT "":U
                                              ,INPUT 0
                                              ,input fi-search :screen-value
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
    apply "ENTRY" to b-search-0 in frame {&frame-name}.
    return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_browse
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_browse Dlg-grp
ON CHOOSE OF MENU-ITEM m_browse /* Справочник */
DO:
    assign
        print-option = "browse":U
    .
    run print-grp in this-procedure(
          input p-store-type
        , input p-store-code
        , input temp_fbrglib_grp.node-code
    ) no-error.
    if error-status:error
    then do:
        assign
            print-option = "":U
        .
        return no-apply.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_browse-global
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_browse-global Dlg-grp
ON CHOOSE OF MENU-ITEM m_browse-global /* Рубрикатор */
DO:
    assign
        print-option = "browse-global":U
    .
    run print-grp in this-procedure(
          input p-store-type
        , input p-store-code
        , input temp_fbrglib_grp.node-code
    ) no-error.
    if error-status:error
    then do:
        assign
            print-option = "":U
        .
        return no-apply.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_classificator
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_classificator Dlg-grp
ON CHOOSE OF MENU-ITEM m_classificator /* Классификатор по объекту */
DO:
    assign
        print-option = "classificator":U
    .
    run print-grp in this-procedure (
          input p-store-type
        , input p-store-code
        , input temp_fbrglib_grp.node-code
    ) no-error.
    if error-status:error
    then do:
        assign
            print-option = "":U
        .
        return no-apply.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_term
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_term Dlg-grp
ON CHOOSE OF MENU-ITEM m_term /* Содержимое терминальных групп */
DO:
    assign
        print-option = "terminal":U
    .
    run print-grp in this-procedure (
          input p-store-type
        , input p-store-code
        , input temp_fbrglib_grp.node-code
    ) no-error.
    if error-status:error
    then do:
        assign
            print-option = "":U
        .
        return no-apply.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-global
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

/*  RUN enable_UI. */
  { gbl/getcntxt.i get }
  assign
  v-b-expand-col            =  b-expand:COL IN FRAME {&FRAME-NAME}             - 50
  v-b-expand-all-col        =  b-expand-all:COL IN FRAME {&FRAME-NAME}         - 50
  v-b-find-by-full-name-col =  b-find-by-full-name:COL IN FRAME {&FRAME-NAME}  - 50
  v-b-find-by-substring-col =  b-find-by-substring:COL IN FRAME {&FRAME-NAME}  - 50
  v-b-search-col            =  b-search:COL IN FRAME {&FRAME-NAME}             - 50
  v-fi-search-col           =  fi-search:COL IN FRAME {&FRAME-NAME}            - 50
  .
    run get-report-num in parparentproc (
        output g#report-num
    ).
    run get-quest-print in parparentproc (
        output g#quest-print
    ).
  IF lookup({&buttons-for-rubr-only}, P-BUTTON-LIST) > 0  THEN do:
    assign
    v-rubr-mode = 1.
    run RUBR-on in this-procedure no-error .
  end.
  ELSE
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

    define variable v-focused-row       as integer  no-undo.
    define variable v-repositioned-row  as integer  no-undo.
    define variable v-node-code    as integer        no-undo.
    define variable v-have-rights       as logical       no-undo.
    define variable v-have-goods        as logical  no-undo.
    define variable v-cancel            as logical        no-undo.

    define buffer buf_fbr-gds-grp           for ub.fbr-gds-grp.
    define buffer buf_temp_fbrglib_grp   for temp_fbrglib_grp.

    run check-rights-for-change-grp in this-procedure (
        output v-have-rights
    ) no-error.
    if error-status :error
    or v-have-rights = no
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Нет прав на изменение справочника групп блюд."
          skip "Добавление группы невозможно."
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
    run fbrglib-have-goods in this-procedure (
          input p-store-type
        , input p-store-code
        , input p-node-code
        , output v-have-goods
    ) no-error .
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка определения наличия товаров в группе."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
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
            return.
        end.
    end.
    find first buf_temp_fbrglib_grp
         where buf_temp_fbrglib_grp.node-code = p-node-code
            AND buf_temp_fbrglib_grp.obj-type = p-store-type
            AND buf_temp_fbrglib_grp.obj-code = p-store-code
    .
    if buf_temp_fbrglib_grp.mark = {&closed-noterminal-grp-mark}
    then do:
        run expand-item in this-procedure ( INPUT p-store-type, p-store-code, input p-node-code, input no ) no-error.
        if error-status :error
        then do:
            undo, return error "add-grp: Не удается раскрыть группу.".
        end.
    end.
    run fbrglib-add-grp in this-procedure (
          input p-store-type
        , input p-store-code
        , input p-node-code
        , INPUT YES /*p-interface*/
        , INPUT "":U /*p-node-name*/
        , INPUT 0 /*p-out-code*/
        , INPUT 0 /*p-global-code*/
        , output v-node-code
        , output v-cancel
    ).
    if v-cancel = yes
    then do:
        undo, return.
    end.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.obj-type  = p-store-type
           and buf_fbr-gds-grp.obj-code  = p-store-code
           and buf_fbr-gds-grp.node-code = v-node-code
    .
    run create-new-line in this-procedure (
          input p-store-type
        , input p-store-code
        , input buf_fbr-gds-grp.node-code
        , input buf_fbr-gds-grp.upper-code
        , input buf_temp_fbrglib_grp.level + 1
        , input buf_fbr-gds-grp.node-name
        , input buf_fbr-gds-grp.out-code
        , input buf_fbr-gds-grp.global-code
    ) no-error .
    if error-status :error
    then do:
        undo, return error "add-grp: Ошибка добавления строки в список групп.".
    end.
    if buf_temp_fbrglib_grp.level > 0
    then do:
        assign
            buf_temp_fbrglib_grp.mark = {&opened-noterminal-grp-mark}
            buf_temp_fbrglib_grp.name = substring( buf_temp_fbrglib_grp.name, 1, buf_temp_fbrglib_grp.level * {&tab-size} )
                                + {&opened-noterminal-grp-mark}
                                + substring( buf_temp_fbrglib_grp.name, buf_temp_fbrglib_grp.level * {&tab-size} + 2 )
        .
    end.
    {&OPEN-QUERY-br-list}
    br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
    reposition br-list to row v-repositioned-row.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-grp-branch-cycle Dlg-grp
PROCEDURE add-grp-branch-cycle :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-node-code         as integer      no-undo.
define input parameter p-global-node-code  as integer      no-undo.
define input parameter p-node-name         as character    no-undo.
define input parameter p-out-code          as INTEGER      no-undo.
define input parameter p-global-code       as INTEGER      no-undo.
define input parameter p-level             as INTEGER      no-undo.

DEFINE VARIABLE v-node-code AS INTEGER NO-UNDO.
DEFINE VARIABLE v-cancel    AS logical NO-UNDO.
DEFINE BUFFER bf0_fbr-gds-grp for ub.fbr-gds-grp.
DEFINE BUFFER buf_fbr-gds-grp for ub.fbr-gds-grp.

run fbrglib-add-grp in this-procedure (
          input p-store-type
        , input p-store-code
        , input p-node-code
        , INPUT no /*p-interface*/
        , INPUT p-node-name
        , INPUT p-out-code
        , INPUT p-global-code
        , output v-node-code
        , output v-cancel
    ).

    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.obj-type  = p-store-type
           and buf_fbr-gds-grp.obj-code  = p-store-code
           and buf_fbr-gds-grp.node-code = v-node-code
    .

    run create-new-line in this-procedure (
      input p-store-type
    , input p-store-code
    , input v-node-code
    , input buf_fbr-gds-grp.upper-code
    , input p-level
    , input buf_fbr-gds-grp.node-name
    , input buf_fbr-gds-grp.out-code
    , input buf_fbr-gds-grp.global-code
    ) no-error .
    if error-status :error
    then do:
        undo, return error "add-grpbrach-cycle: Ошибка добавления строки в список групп.".
    end.




FOR EACH bf0_fbr-gds-grp NO-LOCK WHERE
        bf0_fbr-gds-grp.obj-type = "":U
    AND bf0_fbr-gds-grp.obj-code = 0
    AND bf0_fbr-gds-grp.upper-code = p-global-node-code:
  RUN add-grp-branch-cycle IN THIS-PROCEDURE(
                                             INPUT v-node-code
                                            ,INPUT bf0_fbr-gds-grp.node-code
                                            ,INPUT bf0_fbr-gds-grp.node-name
                                            ,INPUT bf0_fbr-gds-grp.out-code
                                            ,INPUT bf0_fbr-gds-grp.global-code
                                            ,INPUT p-level + 1
                                            ).

END.


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
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.

define input parameter p-node-code as integer      no-undo.

    define variable v-focused-row       as integer              no-undo.
    define variable v-repositioned-row  as integer              no-undo.

    define buffer buf_temp_fbrglib_grp       for temp_fbrglib_grp.
    define buffer buf_upper_temp_fbrglib_grp for temp_fbrglib_grp.

    find first buf_temp_fbrglib_grp
         where buf_temp_fbrglib_grp.node-code = p-node-code
           AND buf_temp_fbrglib_grp.obj-type = p-obj-type
        AND buf_temp_fbrglib_grp.obj-code = p-obj-code
    no-error .
    if not available buf_temp_fbrglib_grp
    then do:
        undo, return error "b-mark-press: Ошибка поиска группы".
    end.
    assign
        v-focused-row      = br-list :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-list" )
    .
    if buf_temp_fbrglib_grp.sel = {&selection-char}
    or p-node-code = v-fbrggrp-root-code
    then do:
        /* снимаем отметку */
        assign
            buf_temp_fbrglib_grp.sel = ""
        .
    end.
    else do:
        /* ставим отметку */
        assign
            buf_temp_fbrglib_grp.sel = {&selection-char}
        .
        /* снимаем все отметки выше по дереву */
        for each buf_upper_temp_fbrglib_grp
            where buf_upper_temp_fbrglib_grp.level < buf_temp_fbrglib_grp.level
                AND buf_temp_fbrglib_grp.obj-type = p-obj-type
                AND buf_temp_fbrglib_grp.obj-code = p-obj-code
              and buf_upper_temp_fbrglib_grp.full-name = substring( buf_temp_fbrglib_grp.full-name, 1
                                                        , length( buf_upper_temp_fbrglib_grp.full-name ) )
        :
            assign
                buf_upper_temp_fbrglib_grp.sel = ""
            .
        end.
        /* снимаем все отметки ниже по дереву */
        for each buf_upper_temp_fbrglib_grp
            where buf_upper_temp_fbrglib_grp.node-code <> buf_temp_fbrglib_grp.node-code
                AND buf_temp_fbrglib_grp.obj-type = p-obj-type
                AND buf_temp_fbrglib_grp.obj-code = p-obj-code
              and buf_upper_temp_fbrglib_grp.full-name begins buf_temp_fbrglib_grp.full-name + {&slash-char}
        :
            assign
                buf_upper_temp_fbrglib_grp.sel = ""
            .
        end.
    end.
    {&OPEN-QUERY-BR-list}
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
    reposition br-list to row v-repositioned-row.

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

    define variable v-fbr-gds-grp-recid     as recid        no-undo.
    define variable v-focused-row           as integer      no-undo.
    define variable v-repositioned-row      as integer      no-undo.
    define variable v-have-rights           as logical      no-undo.
    define variable v-old-full-name         as character    no-undo.
    define variable v-base                  as decimal      no-undo.
    define variable v-node-name             as character    no-undo.
    define variable v-out-code              as integer        no-undo.
    define variable v-cancel                as logical      no-undo.


    define buffer buf_fbr-gds-grp               for ub.fbr-gds-grp.
    define buffer buf_temp_fbrglib_grp       for temp_fbrglib_grp.
    define buffer buf_child_temp_fbrglib_grp for temp_fbrglib_grp.

    if p-node-code = v-fbrggrp-root-code
    then do:
        message
        "Корневую группу изменить невозможно."
        view-as alert-box warning.
        undo, return .
    end.
    run check-rights-for-change-grp in this-procedure (
        output v-have-rights
    ) no-error.
    if error-status :error
    or v-have-rights = no
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Нет прав на изменение справочника групп блюд."
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
    do transaction
    on error undo, return error
    :
        find first buf_fbr-gds-grp exclusive-lock
             where buf_fbr-gds-grp.obj-type  = p-store-type
               and buf_fbr-gds-grp.obj-code  = p-store-code
               and buf_fbr-gds-grp.node-code = p-node-code
        .
        run ref/fbrggrpd.w (
              input parparentproc
            , input {&update}
            , input p-store-type
            , input p-store-code
            , input buf_fbr-gds-grp.node-code
            , input buf_fbr-gds-grp.upper-code
            , input buf_fbr-gds-grp.node-name
            , input buf_fbr-gds-grp.out-code
            , output v-node-name
            , output v-out-code
            , output v-cancel
        ).
        if v-cancel = yes
        then do:
            undo, return.
        end.
        assign
            buf_fbr-gds-grp.node-name   = v-node-name
            buf_fbr-gds-grp.out-code    = v-out-code
        .
    end.        /* do transaction */
    find first buf_temp_fbrglib_grp
         where buf_temp_fbrglib_grp.node-code = p-node-code
          AND buf_temp_fbrglib_grp.obj-type  = p-store-type
          AND buf_temp_fbrglib_grp.obj-code  = p-store-code
    no-error.
    if not available buf_temp_fbrglib_grp
    then do:
        undo, return error "change-grp: Ошибка поиска группы в списке.".
    end.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.obj-type  = p-store-type
           and buf_fbr-gds-grp.obj-code  = p-store-code
           and buf_fbr-gds-grp.node-code = p-node-code
    no-error.
    if error-status :error
    then do:
        undo, return error "change-grp: Неверный выбор группы.".
    end.
    if buf_temp_fbrglib_grp.level > 0
    then do:
        assign
            buf_temp_fbrglib_grp.name    = substring( buf_temp_fbrglib_grp.name
                                                    , 1
                                                    , buf_temp_fbrglib_grp.level * {&tab-size} + 2 )
                                            + buf_fbr-gds-grp.node-name
        .
    end.
    else do:
        assign
            buf_temp_fbrglib_grp.name       = buf_fbr-gds-grp.node-name
        .
    end.
    assign
        v-old-full-name                 = buf_temp_fbrglib_grp.full-name
        buf_temp_fbrglib_grp.out-code   = buf_fbr-gds-grp.out-code
    .
    run fbrglib-get-full-name in this-procedure (
          input p-store-type
        , input p-store-code
        , input p-node-code
        , output buf_temp_fbrglib_grp.full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "Ошибка вычисления полного имени группы в списке".
    end.
    run fbrglib-get-sort-name in this-procedure (
          input p-store-type
        , input p-store-code
        , input p-node-code
        , output buf_temp_fbrglib_grp.sort-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "Ошибка вычисления полного имени группы в списке".
    end.
    if buf_temp_fbrglib_grp.level <> 0
    then do:
        assign
            fi-search :screen-value = right-trim( buf_temp_fbrglib_grp.full-name, {&delim-grp} )
        .
    end.
    for each buf_child_temp_fbrglib_grp
       where buf_child_temp_fbrglib_grp.full-name begins v-old-full-name
         and buf_child_temp_fbrglib_grp.full-name <> v-old-full-name
         and buf_child_temp_fbrglib_grp.level <> buf_temp_fbrglib_grp.level
    :
        run fbrglib-get-full-name in this-procedure (
              input p-store-type
            , input p-store-code
            , input buf_child_temp_fbrglib_grp.node-code
            , output buf_child_temp_fbrglib_grp.full-name
        ) no-error .
        if error-status :error
        then do:
            undo, return error "Ошибка вычисления полного имени группы в списке".
        end.
        run fbrglib-get-sort-name in this-procedure (
              input p-store-type
            , input p-store-code
            , input buf_child_temp_fbrglib_grp.node-code
            , output buf_child_temp_fbrglib_grp.sort-name
        ) no-error .
        if error-status :error
        then do:
            undo, return error "Ошибка вычисления полного имени группы в списке".
        end.
    end.
    {&OPEN-QUERY-br-list}
    br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
    reposition br-list to row v-repositioned-row.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-object Dlg-grp
PROCEDURE check-object :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
define output parameter p-is-invalid    as logical      no-undo.

    define buffer buf_clients       for ub.clients.

    find first buf_clients no-lock
         where buf_clients.obj-type = p-obj-type
           and buf_clients.obj-code = p-obj-code
    no-error.
    if not available buf_clients
    then do:
        assign
            p-is-invalid = yes
        .
    end.
    else do:
        assign
            p-is-invalid = no
        .
    end.
end.
END PROCEDURE. /* check-object */

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
define output parameter p-have-rights   as logical      no-undo.

    { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_res-reference_update':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    no
    p-have-rights
    }
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
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.

do
on error undo, return error
:
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    define buffer buf_temp_fbrglib_grp       for temp_fbrglib_grp.
    for each buf_temp_fbrglib_grp no-lock
       where buf_temp_fbrglib_grp.obj-type = p-obj-type
        AND buf_temp_fbrglib_grp.obj-code = p-obj-code
        AND buf_temp_fbrglib_grp.upper-code = v-fbrggrp-root-code

    :
        run collapse-item in this-procedure (
              INPUT p-obj-type
            , INPUT p-obj-code
            , input buf_temp_fbrglib_grp.node-code
            , input no
        ) no-error .
        if error-status :error
        then do:
            undo, return error "Не удалось закрыть подуровни группы "
                                + {&new-line} + "'" + buf_temp_fbrglib_grp.full-name + "'"
                                + {&new-line} + return-value.
        end.
    end.
    IF p-obj-type = "":U  AND p-obj-code = 0 THEN DO:
        {&OPEN-QUERY-br-global}
    END.
    ELSE DO:
        {&OPEN-QUERY-br-list}
    END.

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
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-node-code as integer      no-undo.
define input parameter p-refresh    as logical      no-undo.

    define variable v-focused-row       as integer              no-undo.
    define variable v-repositioned-row  as integer              no-undo.

    define buffer buf_del_temp_fbrglib_grp   for temp_fbrglib_grp.
    define buffer buf_temp_fbrglib_grp       for temp_fbrglib_grp.

    find first buf_temp_fbrglib_grp
         where buf_temp_fbrglib_grp.obj-type   = p-obj-type
           and buf_temp_fbrglib_grp.obj-code   = p-obj-code
           AND buf_temp_fbrglib_grp.node-code = p-node-code
    no-error.
    if error-status :error
    then do:
        undo, return error substitute("collapse-item: Неверно передан код группы. Нет группы с кодом &1, объект &2&3"
                                     ,p-node-code
                                     ,p-obj-type
                                     ,p-obj-code
                                     ).
    end.
    IF p-obj-type = "":U AND p-obj-code = 0 THEN DO:
        assign
            v-focused-row      = br-global :focused-row in frame {&FRAME-NAME}.
            v-repositioned-row = current-result-row( "br-global" )
        .

    END.
    ELSE DO:
        assign
            v-focused-row      = br-list :focused-row in frame {&FRAME-NAME}.
            v-repositioned-row = current-result-row( "br-list" )
        .

    END.

    for each buf_del_temp_fbrglib_grp
       where buf_del_temp_fbrglib_grp.full-name begins buf_temp_fbrglib_grp.full-name
         and buf_del_temp_fbrglib_grp.full-name <> buf_temp_fbrglib_grp.full-name
         and buf_del_temp_fbrglib_grp.level     <> buf_temp_fbrglib_grp.level
         and buf_del_temp_fbrglib_grp.obj-type   = p-obj-type
          and buf_del_temp_fbrglib_grp.obj-code   = p-obj-code

    :
        delete buf_del_temp_fbrglib_grp.
    end.
    assign
        buf_temp_fbrglib_grp.mark = {&closed-noterminal-grp-mark}
        buf_temp_fbrglib_grp.name = replace( buf_temp_fbrglib_grp.name
                                        , {&opened-noterminal-grp-mark}
                                        , {&closed-noterminal-grp-mark}
                                        )
    .
    if p-refresh = yes
    then do:
      IF p-obj-type = "":U and p-obj-code = 0 THEN DO:
           {&OPEN-QUERY-BR-global}
          br-global :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
          reposition br-global to row v-repositioned-row.

      END.
      ELSE DO:
           {&OPEN-QUERY-BR-list}
          br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
          reposition br-list to row v-repositioned-row.
     END.
    end.
end.
END PROCEDURE. /* collapse-item */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE copy-from-global-grp Dlg-grp
PROCEDURE copy-from-global-grp :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  input p-node-code - код группы для добавления ветки из рубрикатора
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.
define input parameter p-global-node-code  as integer      no-undo.
define input parameter p-global-code  as integer      no-undo.

    define variable v-focused-row       as integer  no-undo.
    define variable v-repositioned-row  as integer  no-undo.
    define variable v-node-code    as integer        no-undo.
    define variable v-have-rights       as logical       no-undo.
    define variable v-have-goods        as logical  no-undo.
    define variable v-cancel            as logical        no-undo.

    define buffer buf_fbr-gds-grp           for ub.fbr-gds-grp.
    define buffer bf0_fbr-gds-grp           for ub.fbr-gds-grp.
    define buffer buf_temp_fbrglib_grp   for temp_fbrglib_grp.

    run check-rights-for-change-grp in this-procedure (
        output v-have-rights
    ) no-error.
    if error-status :error
    or v-have-rights = no
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Нет прав на изменение справочника групп блюд."
          skip "Добавление групп(ы) невозможно."
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
    run fbrglib-have-goods in this-procedure (
          input p-store-type
        , input p-store-code
        , input p-node-code
        , output v-have-goods
    ) no-error .
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка определения наличия товаров в группе."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
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
            return.
        end.
    end.
    find first bf0_fbr-gds-grp
         where bf0_fbr-gds-grp.node-code = p-global-node-code
            AND bf0_fbr-gds-grp.obj-type = "":U
            AND bf0_fbr-gds-grp.obj-code = 0
    .

    find first buf_temp_fbrglib_grp
         where buf_temp_fbrglib_grp.node-code = p-node-code
            AND buf_temp_fbrglib_grp.obj-type = p-store-type
            AND buf_temp_fbrglib_grp.obj-code = p-store-code
    .
    if buf_temp_fbrglib_grp.mark = {&closed-noterminal-grp-mark}
    then do:
        run expand-item in this-procedure ( INPUT p-store-type, p-store-code, input p-node-code, input no ) no-error.
        if error-status :error
        then do:
            undo, return error "copy-from-global-grp: Не удается раскрыть группу.".
        end.
    end.

    RUN add-grp-branch-cycle in this-procedure (
          input p-node-code
        , INPUT p-global-node-code
        , INPUT bf0_fbr-gds-grp.node-name
        , INPUT bf0_fbr-gds-grp.out-code
        , INPUT p-global-code
        , INPUT (buf_temp_fbrglib_grp.level + 1) /*p-level*/
    ).

   if buf_temp_fbrglib_grp.level > 0
    then do:
        assign
            buf_temp_fbrglib_grp.mark = {&opened-noterminal-grp-mark}
            buf_temp_fbrglib_grp.name = substring( buf_temp_fbrglib_grp.name, 1, buf_temp_fbrglib_grp.level * {&tab-size} )
                                + {&opened-noterminal-grp-mark}
                                + substring( buf_temp_fbrglib_grp.name, buf_temp_fbrglib_grp.level * {&tab-size} + 2 )
        .
    end.
    {&OPEN-QUERY-br-list}
    br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
    reposition br-list to row v-repositioned-row.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE copy-group-list-from-obj Dlg-grp
PROCEDURE copy-group-list-from-obj :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-from-obj-type  as character    no-undo.
define input parameter p-from-obj-code  as integer      no-undo.
define input parameter p-to-obj-type    as character    no-undo.
define input parameter p-to-obj-code    as integer      no-undo.

    define variable v-fbr-gds-obj-recid     as recid        no-undo.
    define variable v-grp-counter    as integer        no-undo.

    define buffer buf_from_fbr-gds-grp  for ub.fbr-gds-grp.
    define buffer buf_to_fbr-gds-grp    for ub.fbr-gds-grp.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    define buffer buf_from_fbr-gds-obj  for ub.fbr-gds-obj.
    define buffer buf_to_fbr-gds-obj    for ub.fbr-gds-obj.

do
for buf_from_fbr-gds-grp
  , buf_to_fbr-gds-grp
  , buf_fbr-gds-grp
  , buf_from_fbr-gds-obj
  , buf_to_fbr-gds-obj
on error undo, return error
:
    find first buf_to_fbr-gds-grp no-lock
         where buf_to_fbr-gds-grp.obj-type = p-to-obj-type
           and buf_to_fbr-gds-grp.obj-code = p-to-obj-code
    no-error.
    if available buf_to_fbr-gds-grp
    then do:
        message
                 "На объекте, куда надо копировать группы,"
            skip "уже есть группы блюд."
            skip(1)
            skip "Копирование невозможно."
        view-as alert-box error.
        undo, return error .
    end.
    for each buf_from_fbr-gds-grp no-lock
       where buf_from_fbr-gds-grp.obj-type = p-from-obj-type
         and buf_from_fbr-gds-grp.obj-code = p-from-obj-code
    on error undo, return error
    :
        create buf_to_fbr-gds-grp.
        buffer-copy
            buf_from_fbr-gds-grp
            except
                buf_from_fbr-gds-grp.obj-type
                buf_from_fbr-gds-grp.obj-code
                buf_from_fbr-gds-grp.node-code
            to buf_to_fbr-gds-grp
        .
        assign
            buf_to_fbr-gds-grp.obj-type     = p-to-obj-type
            buf_to_fbr-gds-grp.obj-code     = p-to-obj-code
            buf_to_fbr-gds-grp.node-code    = buf_from_fbr-gds-grp.node-code
        .
        for each buf_from_fbr-gds-obj no-lock
           where buf_from_fbr-gds-obj.obj-type      = p-from-obj-type
             and buf_from_fbr-gds-obj.obj-code      = p-from-obj-code
             and buf_from_fbr-gds-obj.fbr-grp-code  = buf_from_fbr-gds-grp.node-code
        on error undo, return error
        :
            find first buf_to_fbr-gds-obj exclusive-lock
                 where buf_to_fbr-gds-obj.obj-type = p-to-obj-type
                   and buf_to_fbr-gds-obj.obj-code = p-to-obj-code
                   and buf_to_fbr-gds-obj.gds-code = buf_from_fbr-gds-obj.gds-code
            no-error.
            if not available buf_to_fbr-gds-obj
            then do:        /* Создать buf_to_fbr-gds-obj */
                run ref/fgdsobj1.p (
                      input-output v-fbr-gds-obj-recid
                    , input {&add-def}                      /* par-mode          */
                    , input no                              /* p-silent          */
                    , input buf_from_fbr-gds-obj.gds-code   /* p-gds-code        */
                    , input p-to-obj-type                   /* p-obj-type        */
                    , input p-to-obj-code                   /* p-obj-code        */
                    , input buf_to_fbr-gds-grp.node-code    /* p-fbr-grp-code    */
                    , input ""                              /* p-fbr-obj-type    */
                    , input 0                               /* p-fbr-obj-code    */
                    , input no                              /* p-is-cd           */
                    , input no                              /* p-is-menu         */
                    , input no                              /* p-is-modificator  */
                    , input no                              /* p-is-null-price   */
                    , input no                              /* p-is-season       */
                    , input no                              /* p-is-semi-finished*/
               ) no-error.
               if error-status :error
               then do:
                   message
                         vss-workfile vss-revision vss-description
                    skip "Ошибка при создании записи товара производства на объекте."
                    skip return-value
                    skip trim(error-status :get-message(1))
                         trim(error-status :get-message(2))
                         trim(error-status :get-message(3))
                   view-as alert-box error.
                   undo, return error .
               end.
            end.        /* if not available buf_to_fbr-gds-obj  */
            else do:
                assign
                    v-fbr-gds-obj-recid = recid( buf_to_fbr-gds-obj )
                .
                run ref/fgdsobj1.p (
                      input-output v-fbr-gds-obj-recid
                    , input {&update}                               /* par-mode          */
                    , input no                                      /*  p-silent         */
                    , input buf_to_fbr-gds-obj.gds-code             /* p-gds-code        */
                    , input buf_to_fbr-gds-obj.obj-type             /* p-obj-type        */
                    , input buf_to_fbr-gds-obj.obj-code             /* p-obj-code        */
                    , input buf_from_fbr-gds-grp.node-code          /* p-fbr-grp-code    */
                    , input buf_to_fbr-gds-obj.obj-type             /* p-fbr-obj-type    */
                    , input buf_to_fbr-gds-obj.obj-code             /* p-fbr-obj-code    */
                    , input buf_to_fbr-gds-obj.is-cd                /* p-is-cd           */
                    , input buf_to_fbr-gds-obj.is-menu              /* p-is-menu         */
                    , input buf_to_fbr-gds-obj.is-modificator       /* p-is-modificator  */
                    , input buf_to_fbr-gds-obj.is-null-price        /* p-is-null-price   */
                    , input buf_to_fbr-gds-obj.is-season            /* p-is-season       */
                    , input buf_to_fbr-gds-obj.is-semi-finished     /* p-is-semi-finished*/
               ) no-error.
               if error-status :error
               then do:
                   message
                         vss-workfile vss-revision vss-description
                    skip "Ошибка при изменении записи товара производства на объекте."
                    skip return-value
                    skip trim(error-status :get-message(1))
                         trim(error-status :get-message(2))
                         trim(error-status :get-message(3))
                   view-as alert-box error.
                   undo, return error .
               end.
            end.        /* NOT ( if not available buf_fbr-gds-obj  ) */
        end.        /* for each buf_from_fbr-gds-obj */
    end.        /* for each buf_from_fbr-gds-grp */
end.
END PROCEDURE. /* copy-group-list-from-obj */

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
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
define input parameter p-node-code      as integer      no-undo.
define input parameter p-upper-code     as integer      no-undo.
define input parameter p-level          as integer      no-undo.
define input parameter p-node-name      as character    no-undo.
define input parameter p-out-code       as integer      no-undo.
define input parameter p-global-code    as integer      no-undo.

define variable v-full-name         as character         no-undo.
define variable v-sort-name         as character         no-undo.
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

define buffer buf_temp_fbrglib_grp       for temp_fbrglib_grp.

    run fbrglib-get-full-name in this-procedure (
              input p-obj-type
            , input p-obj-code
            , input p-node-code
            , output v-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "create-new-line: Ошибка вычисления полного имени группы." .
    end.
    run fbrglib-get-sort-name in this-procedure (
              input p-obj-type
            , input p-obj-code
            , input p-node-code
            , output v-sort-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "create-new-line: Ошибка вычисления полного имени группы." .
    end.
    create buf_temp_fbrglib_grp.
    assign
        buf_temp_fbrglib_grp.node-code   = p-node-code
        buf_temp_fbrglib_grp.upper-code  = p-upper-code
        buf_temp_fbrglib_grp.level       = p-level
        buf_temp_fbrglib_grp.out-code    = p-out-code
        buf_temp_fbrglib_grp.full-name   = v-full-name
        buf_temp_fbrglib_grp.sort-name   = v-sort-name
        buf_temp_fbrglib_grp.obj-type    = p-obj-type
        buf_temp_fbrglib_grp.obj-code    = p-obj-code
        buf_temp_fbrglib_grp.global-code = p-global-code
    .
    run get-first-char in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-node-code
        , output buf_temp_fbrglib_grp.mark
    ) no-error.
    if error-status :error
    then do:
        undo, return error "create-new-line: Ошибка вычисления первого символа для отображения группы." .
    end.
    assign
        buf_temp_fbrglib_grp.name = fill( " ", {&tab-size} * p-level )
                                        + buf_temp_fbrglib_grp.mark
                                        + " "
                                        + p-node-name
    .
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

    define variable v-focused-row       as integer  no-undo.
    define variable v-repositioned-row  as integer  no-undo.
    define variable v-upper-code        as integer  no-undo.
    define variable v-have-rights       as logical  no-undo.
    define variable v-deleted           as logical        no-undo.

    define buffer buf_fbr-gds-grp           for ub.fbr-gds-grp.
    define buffer buf_temp_fbrglib_grp      for temp_fbrglib_grp.

    if p-node-code = v-fbrggrp-root-code
    then do:
        message
        "Корневую группу удалить невозможно."
        view-as alert-box warning.
        undo, return .
    end.
    run check-rights-for-change-grp in this-procedure (
        output v-have-rights
    ) no-error.
    if error-status :error
    or v-have-rights = no
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Нет прав на изменение справочника групп блюд."
          skip "Удаление группы невозможно."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return .
    end.
    assign
        v-focused-row      = br-list :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-list" )
    .
    find first buf_temp_fbrglib_grp
         where buf_temp_fbrglib_grp.node-code = p-node-code
        AND buf_temp_fbrglib_grp.obj-type = p-store-type
        AND buf_temp_fbrglib_grp.obj-code = p-store-code
    no-error .
    if error-status :error
    then do:
        undo, return error "Неверно выбрана группа." .
    end.
    assign
        v-upper-code = buf_temp_fbrglib_grp.upper-code
    .
    run fbrglib-delete-grp in this-procedure (
          input p-store-type
        , input p-store-code
        , input p-node-code
        , output v-deleted
    ) no-error .
    if error-status:error then do:
      message
      "Ошибка при удалении группы блюд"
      error-status:get-message(1) skip
      return-value
      view-as alert-box error .
      undo, return error .
    end.
    if p-refresh = yes
    then do:
        if v-upper-code = 1
        then do:    /* Удаление группы первого уровня. */
            find first buf_fbr-gds-grp no-lock
                 where buf_fbr-gds-grp.node-code = 1
            no-error.
            if not available buf_fbr-gds-grp
            then do:
                undo, return error "delete-grp: Не найдена корневая группа в БД".
            end.
        end.        /* v-upper-code = 1 */
        else do:
            find first buf_fbr-gds-grp no-lock
                 where buf_fbr-gds-grp.obj-type  = p-store-type
                   and buf_fbr-gds-grp.obj-code  = p-store-code
                   and buf_fbr-gds-grp.node-code = v-upper-code
            no-error.
            if not available buf_fbr-gds-grp
            then do:
                undo, return error "delete-grp: Не найдена группа в БД".
            end.
        end.        /* v-upper-code <> 1 */
        assign
            p-recid-list     = string( recid( buf_fbr-gds-grp ) )
            fbr-gds-grp-row  = recid( buf_fbr-gds-grp )
        .
/*        run expand-item in this-procedure ( input buf_fbr-gds-grp.node-code, input yes ) no-error.*/
/*        if error-status :error*/
/*        then do:*/
/*            undo, return error "delete-grp: Не удается раскрыть группу.".*/
/*        end.*/
        assign
        entry(v-rubr-mode + 1, v-uf-List_,  {&delim-par}) = if fbr-gds-grp-row = ?
                                                            then {&question-mark}
                                                            else string(fbr-gds-grp-row)
        .
        run uf-set in this-procedure (
             input  {&uf-fbr-gds-grp-p}
            ,input  v-cntxt-userid
            ,input v-uf-List_
            ,input v-uf-Naim
            ,input v-uf-print-graft
            ,input v-uf-sort-gr
            ,input v-uf-type-price
            ,input v-uf-type-val
        )  no-error .
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
  DISPLAY fi-kitchen-type fi-kitchen-code fi-search-0 fi-search
      WITH FRAME Dlg-grp.
  ENABLE b-exit RECT-rubr b-mark b-sel b-add b-chg b-del b-move b-goods b-print
         b-help B-global b-copy fi-kitchen-code bt-sel-kitchen B-hist
         b-expand-0 b-expand-all-0 fi-search-0 b-find-by-full-name-0
         b-find-by-substring-0 b-search-0 b-expand b-expand-all fi-search
         b-find-by-full-name b-find-by-substring b-search B-copy0 B-link
         br-global br-list
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
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-node-code as integer      no-undo.

    define variable v-full-name     as character         no-undo.
    define variable v-focused-row       as integer              no-undo.
    define variable v-repositioned-row  as integer              no-undo.

    define buffer buf_temp_fbrglib_grp       for temp_fbrglib_grp.

    assign
        v-focused-row      = br-list :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-list" )
    .
    run fbrglib-get-full-name in this-procedure (
              input p-obj-type
            , input p-obj-code
            , input p-node-code
            , output v-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "expand-all-from-current: Ошибка вычисления полного имени группы".
    end.

    for each buf_temp_fbrglib_grp
       where buf_temp_fbrglib_grp.full-name begins v-full-name
        AND buf_temp_fbrglib_grp.obj-type = p-obj-type
        AND buf_temp_fbrglib_grp.obj-code = p-obj-code
    :
        run expand-item in this-procedure (INPUT p-obj-type, INPUT p-obj-code,  input buf_temp_fbrglib_grp.node-code, input no ) no-error .
        if error-status :error
        then do:
            undo, return error "expand-all-from-current: Не удалось раскрыть подуровни группы.".
        end.
    end.
    IF p-obj-type = "":U AND p-obj-code = 0 THEN DO:
        {&OPEN-QUERY-BR-global}
        br-global :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME} .
        reposition br-global to row v-repositioned-row no-error .
    END.
    ELSE DO:
      {&OPEN-QUERY-BR-list}
      br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
     reposition br-list to row v-repositioned-row no-error .
    END.


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
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-node-code  as integer      no-undo.
define input parameter p-refresh    as logical      no-undo.

    define variable v-focused-row       as integer              no-undo.
    define variable v-repositioned-row  as integer              no-undo.

    define buffer buf_fbr-gds-grp           for ub.fbr-gds-grp.
    define buffer buf_temp_fbrglib_grp   for temp_fbrglib_grp.
    IF p-obj-type = "":U AND p-obj-code = 0 THEN DO:
        assign
            v-focused-row      = br-global :focused-row in frame {&FRAME-NAME}.
            v-repositioned-row = current-result-row( "br-global" )
        .
    END.
    ELSE DO:
        assign
            v-focused-row      = br-list :focused-row in frame {&FRAME-NAME}.
            v-repositioned-row = current-result-row( "br-list" )
        .

    END.
    find first buf_temp_fbrglib_grp
         where buf_temp_fbrglib_grp.obj-type = p-obj-type
        AND buf_temp_fbrglib_grp.obj-code = p-obj-code
        AND buf_temp_fbrglib_grp.node-code = p-node-code
    no-error .
    if not available buf_temp_fbrglib_grp
    then do:
        undo, return error "expand-item: Неверно задан код группы.".
    end.
    if buf_temp_fbrglib_grp.mark <> {&closed-noterminal-grp-mark}
    then do:
        /* Не закрытая группа, открыть невозможно. */
    end.
    else do:
        for each buf_fbr-gds-grp no-lock
           where buf_fbr-gds-grp.obj-type   = p-obj-type
             and buf_fbr-gds-grp.obj-code   = p-obj-code
             and buf_fbr-gds-grp.upper-code = p-node-code
        on error undo, return error
        :
            run create-new-line in this-procedure (
                  input p-obj-type
                , input p-obj-code
                , input buf_fbr-gds-grp.node-code
                , input buf_fbr-gds-grp.upper-code
                , input buf_temp_fbrglib_grp.level + 1
                , input buf_fbr-gds-grp.node-name
                , input buf_fbr-gds-grp.out-code
                , input buf_fbr-gds-grp.global-code
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
        end.        /* for each buf_fbr-gds-grp */
        assign
            buf_temp_fbrglib_grp.mark = {&opened-noterminal-grp-mark}
            buf_temp_fbrglib_grp.name = replace( buf_temp_fbrglib_grp.name
                                            , {&closed-noterminal-grp-mark}
                                            , {&opened-noterminal-grp-mark}
                                            )
        .
        if p-refresh = yes
        then do:
           IF p-obj-type = "":U AND p-obj-code = 0 THEN DO:
            {&OPEN-QUERY-BR-global}
            if v-focused-row > br-global :height - 2
            then do:
                assign
                    v-focused-row       = br-global :height - 2
                .
            end.
            br-global :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
            reposition br-global to row v-repositioned-row.
           END.
           ELSE DO:
            {&OPEN-QUERY-BR-list}
            if v-focused-row > br-list :height - 2
            then do:
                assign
                    v-focused-row       = br-list :height - 2
                .
            end.
            br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
            reposition br-list to row v-repositioned-row.
           END.

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
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
DEFINE INPUT PARAMETER p-grp-mark LIKE temp_fbrglib_grp.mark NO-UNDO.
DEFINE INPUT PARAMETER p-node-code LIKE temp_fbrglib_grp.node-code NO-UNDO.

do
on error undo, return error
:
    case p-grp-mark
    :
    when {&closed-noterminal-grp-mark}
    then do:
        run expand-item in this-procedure ( INPUT p-obj-type, INPUT p-obj-code, input p-node-code, input yes ) no-error .
        if error-status :error
        then do:
            undo, return error "Не удалось раскрыть подуровни группы.".
        end.
    end.
    when {&opened-noterminal-grp-mark}
    then do:
        run collapse-item in this-procedure (INPUT p-obj-type, INPUT p-obj-code, input p-node-code, input yes ) no-error .
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
define input parameter p-obj-type               as character        no-undo.
define input parameter p-obj-code               as integer          no-undo.
define input parameter p-node-code              as integer          no-undo.
define output parameter p-focused-row           as integer          no-undo.
define output parameter p-reposition-row        as integer          no-undo.
define output parameter p-reposition-to-recid   as logical init no  no-undo.

define variable v-full-name             as character        no-undo.

define buffer buf_temp_fbrglib_grp       for temp_fbrglib_grp.

    run fbrglib-get-full-name in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-node-code
        , output v-full-name ) no-error .
    if error-status :error
    then do:
        /* Не нашли полного имени - встаем на первую группу. */
    end.
    else do:
        run fbrglib-find-grp-by-full-name in this-procedure (
              input p-obj-type
            , input p-obj-code
            , input right-trim( v-full-name, {&delim-grp} )
            , input yes
        ) no-error .
        if error-status :error
        then do:
            /* Не нашли по полному имени - встаем на первую группу. */
        end.
        else do:
            process-initial-grp:
            for each temp_fbrglib_found-grp
            where temp_fbrglib_found-grp.obj-type = p-obj-type
            AND temp_fbrglib_found-grp.obj-code = p-obj-code
            break
            by temp_fbrglib_found-grp.obj-type
            by temp_fbrglib_found-grp.obj-code
            by temp_fbrglib_found-grp.level
            on error undo, leave process-initial-grp :
                if last ( temp_fbrglib_found-grp.level )
                then do:
                    assign
                        p-focused-row       = integer( if v-rubr-mode = 0
                                                       then ((br-list :height in frame {&frame-name} / 2 ) + 1)
                                                       else ((br-global :height in frame {&frame-name} / 2 ) + 1))
                    .
                    find first buf_temp_fbrglib_grp
                         where buf_temp_fbrglib_grp.node-code = temp_fbrglib_found-grp.node-code
                          AND buf_temp_fbrglib_grp.obj-type  = temp_fbrglib_found-grp.obj-type
                          AND buf_temp_fbrglib_grp.obj-code  = temp_fbrglib_found-grp.obj-code
                    no-error .
                    if error-status :error
                    then do:
                        leave process-initial-grp.
                    end.
                    assign
                        p-reposition-row = recid( buf_temp_fbrglib_grp )
                        p-reposition-to-recid = yes
                    .
                    leave process-initial-grp.
                end.
                else do:
                    run expand-item in this-procedure ( input temp_fbrglib_found-grp.obj-type, input temp_fbrglib_found-grp.obj-code,  input temp_fbrglib_found-grp.node-code, input no ) no-error .
                    if error-status :error
                    then do:
                        leave process-initial-grp.
                    end.
                    find first buf_temp_fbrglib_grp
                            where buf_temp_fbrglib_grp.node-code = temp_fbrglib_found-grp.node-code
                              AND buf_temp_fbrglib_grp.obj-type  = temp_fbrglib_found-grp.obj-type
                              AND buf_temp_fbrglib_grp.obj-code  = temp_fbrglib_found-grp.obj-code

                    no-error .
                    if error-status :error
                    then do:
                        leave process-initial-grp.
                    end.
                    assign
                        p-reposition-row = recid( buf_temp_fbrglib_grp )
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


    define buffer buf_fbr-gds-grp           for ub.fbr-gds-grp.
    define buffer buf_temp_fbrglib_grp   for temp_fbrglib_grp.

    assign
        v-focused-row      = br-list :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-list" )
    .
    run ref/pr-marg.w (
          input parparentproc
        , input p-node-code
    ) no-error.
    if error-status :error
    then do:
        undo, return error "fill-marg: Ошибка при установке диапазона торговых наценок." + {&new-line} + return-value.
    end.
    find first buf_temp_fbrglib_grp
         where buf_temp_fbrglib_grp.node-code = p-node-code
         AND buf_temp_fbrglib_grp.obj-type  = p-store-type
         AND buf_temp_fbrglib_grp.obj-code  = p-store-code
    no-error .
    if error-status :error
    then do:
        undo, return error "fill-marg: Неверно задан код группы.".
    end.
    {&OPEN-QUERY-br-list}
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
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-node-code as integer      no-undo.

    define variable v-selected      as logical  init no  no-undo.
    define variable v-is-terminal   as logical           no-undo.

    define buffer buf_fbr-gds-grp           for ub.fbr-gds-grp.
    define buffer buf_temp_fbrglib_grp   for temp_fbrglib_grp.

    run fbrglib-is-terminal in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-node-code
        , output v-is-terminal
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "fill-output-parameters-on-exit: Не удается определить, корневая группа или терминальная."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if lookup ( {&g#term}, p-button-list ) <> 0
    and v-is-terminal = no
    then do:
        message "Требуется выбрать группу блюд, в которой нет других групп.".
        apply "entry" to br-list in frame {&frame-name}.
        return no-apply.
    end.
    assign
        p-recid-list = ""
    .
    for each buf_temp_fbrglib_grp
       where buf_temp_fbrglib_grp.sel = {&selection-char}
          AND buf_temp_fbrglib_grp.obj-type =  p-obj-type
          AND buf_temp_fbrglib_grp.obj-code = p-obj-code
    :
        if buf_temp_fbrglib_grp.node-code = v-fbrggrp-root-code
        then do:        /* Терминальная группа */
            find first buf_fbr-gds-grp no-lock
                 where buf_fbr-gds-grp.obj-type  = ""
                   and buf_fbr-gds-grp.obj-code  = 0
                   and buf_fbr-gds-grp.node-code = v-fbrggrp-root-code
            no-error .
            if error-status :error
            then do:
                undo, return error "fill-output-parameters-on-exit: Не найдена корневая запись групп блюд'".
            end.
        end.        /* if buf_temp_fbrglib_grp.node-code = 1 */
        else do:
            find first buf_fbr-gds-grp no-lock
                 where buf_fbr-gds-grp.obj-type  = p-obj-type
                   and buf_fbr-gds-grp.obj-code  = p-obj-code
                   and buf_fbr-gds-grp.node-code = buf_temp_fbrglib_grp.node-code
            no-error .
            if error-status :error
            then do:
                undo, return error "fill-output-parameters-on-exit: Не найдена запись выбранной группы '"
                                    + "'" + buf_temp_fbrglib_grp.full-name + "'".
            end.
        end.        /* NOT ( if buf_temp_fbrglib_grp.node-code = 1 ) */
        assign
            p-recid-list = p-recid-list + ( if p-recid-list = "" then "" else "," ) + string( recid( buf_fbr-gds-grp ) )
            v-selected   = yes
        .
    end.
    if v-selected = no
    then do:
        if p-node-code = v-fbrggrp-root-code
        then do:
            find first buf_fbr-gds-grp no-lock
                 where buf_fbr-gds-grp.obj-type  = ""
                   and buf_fbr-gds-grp.obj-code  = 0
                   and buf_fbr-gds-grp.node-code = v-fbrggrp-root-code
            no-error .
        end.        /* if p-node-code = v-fbrggrp-root-code */
        else do:
            find first buf_fbr-gds-grp no-lock
                 where buf_fbr-gds-grp.obj-type  = p-obj-type
                   and buf_fbr-gds-grp.obj-code  = p-obj-code
                   and buf_fbr-gds-grp.node-code = p-node-code
            no-error .
        end.        /* NOT ( if p-node-code = v-fbrggrp-root-code ) */
        if not available buf_fbr-gds-grp
        then do:
            find first buf_temp_fbrglib_grp
                 where buf_temp_fbrglib_grp.node-code = p-node-code
                  AND buf_temp_fbrglib_grp.obj-type  = p-obj-type
                  AND buf_temp_fbrglib_grp.obj-code  = p-obj-code
            no-error .
            if not available buf_temp_fbrglib_grp
            then do:
                undo, return error "fill-output-parameters-on-exit: Неверно выбрана группа с кодом "
                                    + string( p-node-code ).
            end.
            undo, return error "fill-output-parameters-on-exit: Не найдена запись выбранной группы '"
                            + buf_temp_fbrglib_grp.full-name + "'".
        end.
        assign
            p-recid-list = string( recid( buf_fbr-gds-grp ) )
        .
    end.
    assign
        fbr-gds-grp-row      = integer( entry( 1, p-recid-list ) )
    .
assign
entry(v-rubr-mode + 1, v-uf-List_,  {&delim-par}) =  if fbr-gds-grp-row = ?
                                                     then {&question-mark}
                                                     else string( fbr-gds-grp-row )

.
run uf-set in this-procedure(
      input {&uf-fbr-gds-grp-p}
    , input v-cntxt-userid
    , input v-uf-List_
    , input v-uf-Naim
    , input v-uf-print-graft
    , input v-uf-sort-gr
    , input v-uf-type-price
    , input v-uf-type-val
)  no-error .
end.
END PROCEDURE. /* fill-output-parameters-on-exit */

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
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-search-grp-full-name   as character    no-undo.

    define variable v-focused-row       as integer              no-undo.
    define variable v-repositioned-row  as integer              no-undo.
    define variable v-counter           as integer              no-undo.
    define variable v-level             as integer              no-undo.

    define buffer buf_temp_fbrglib_grp       for temp_fbrglib_grp.
    define buffer bf_temp_fbrglib_grp       for temp_fbrglib_grp.
    DEFINE BUFFER bf_temp_fbrglib_found-grp FOR temp_fbrglib_found-grp.
    IF p-obj-type = "":U AND p-obj-code = 0 THEN DO:
        assign
        v-focused-row      = br-global :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-global" )
    .
    END.
    ELSE DO:
        assign
        v-focused-row      = br-list :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-list" )
    .
    END.

    assign
    v-level = num-entries( right-trim(p-search-grp-full-name, {&delim-grp} ) , {&delim-grp})
    .
    if v-found-grp-num  <> 0       /* группу уже нашли, temp-table уже заполнен. Берем следующую из темр-table.*/
    then do:
        assign
            v-counter = 0
        .
        find first bf_temp_fbrglib_found-grp
            where  bf_temp_fbrglib_found-grp.obj-type = p-obj-type
            AND bf_temp_fbrglib_found-grp.obj-code = p-obj-code
            AND bf_temp_fbrglib_found-grp.level = v-level
        no-error .
        if not available bf_temp_fbrglib_found-grp
        then do:
            undo, return error "Не найдено ни одной группы уровня " + string( v-level ).
        end.
        do v-counter = 1 to v-found-grp-num
        :
            find next bf_temp_fbrglib_found-grp
                where bf_temp_fbrglib_found-grp.obj-type = p-obj-type
            AND bf_temp_fbrglib_found-grp.obj-code = p-obj-code
            AND bf_temp_fbrglib_found-grp.level = v-level
            no-error .
            if not available bf_temp_fbrglib_found-grp
            then do:
                undo, return error "Не найдена следующая группа уровня " + string( v-level ).
            end.
        end.
        find first buf_temp_fbrglib_grp
                where buf_temp_fbrglib_grp.node-code = bf_temp_fbrglib_found-grp.node-code
                  AND buf_temp_fbrglib_grp.obj-type  = p-obj-type
                  AND buf_temp_fbrglib_grp.obj-code  = p-obj-code
        no-error .
        if not available buf_temp_fbrglib_grp
        then do:
            undo, return error "Найденной группы нет в списке групп".
        end.
        IF p-obj-type = "":U AND p-obj-code = 0 THEN DO:
            {&OPEN-QUERY-br-global}
            br-global :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
        reposition br-global to recid recid( buf_temp_fbrglib_grp ).
        END.
        ELSE DO:
            {&OPEN-QUERY-BR-LIST}
           br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
           reposition br-list to recid recid( buf_temp_fbrglib_grp ).
        END.

    end.        /* v-found-grp-num  <> 0 */
    else do:        /* Первый поиск */
        run fbrglib-find-grp-by-full-name (
              input p-obj-type
            , input p-obj-code
            , input (IF p-obj-type = "":U AND p-obj-code = 0
                     THEN fi-search-0 :screen-value in frame {&frame-name}
                      ELSE fi-search :screen-value in frame {&frame-name})
            , input yes
        ) no-error.
        if error-status :error
        then do:
            undo, return error "Не удалось найти группу '" +
                (IF p-obj-type = "":U AND p-obj-code = 0
                 THEN fi-search-0 :screen-value in frame {&frame-name}
                    ELSE fi-search :screen-value in frame {&frame-name}) + "'".
        end.
        found-group:
        for each bf_temp_fbrglib_found-grp no-lock
            WHEre bf_temp_fbrglib_found-grp.obj-type = p-obj-type
            AND bf_temp_fbrglib_found-grp.obj-code = p-obj-code
        by bf_temp_fbrglib_found-grp.level
    /*       where temp_fbrglib_found-grp. =*/
        :
            if bf_temp_fbrglib_found-grp.level = v-level
            then do:
                leave.
            end.
            run expand-item in this-procedure ( INPUT p-obj-type, INPUT p-obj-code, input bf_temp_fbrglib_found-grp.node-code, input no ).
        end.
        find first bf_temp_fbrglib_found-grp
            WHEre bf_temp_fbrglib_found-grp.obj-type = p-obj-type
            AND bf_temp_fbrglib_found-grp.obj-code = p-obj-code
           AND bf_temp_fbrglib_found-grp.level = v-level
        no-error .
        if not available bf_temp_fbrglib_found-grp
        then do:
            undo, return error "Нет последней найденной группы для уровня " + string( v-level ).
        end.
        find first buf_temp_fbrglib_grp
            WHEre buf_temp_fbrglib_grp.obj-type = p-obj-type
            AND buf_temp_fbrglib_grp.obj-code = p-obj-code
             AND buf_temp_fbrglib_grp.node-code = bf_temp_fbrglib_found-grp.node-code
        no-error .
        if not available buf_temp_fbrglib_grp
        then do:
            undo, return error "Найденной группы нет в списке групп".
        end.
        IF p-obj-type = "":U AND p-obj-code = 0  THEN DO:
            {&OPEN-query-br-global}
            br-global :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
            reposition br-global to recid recid( buf_temp_fbrglib_grp ).

        END.
        ELSE DO:
            {&OPEN-query-br-list}
            br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
            reposition br-list to recid recid( buf_temp_fbrglib_grp ).

        END.
    end.        /* v-found-grp-num  = 0, т.е. первый поиск */
    find next bf_temp_fbrglib_found-grp     /* Можно ли искать дальше? Если можно, увеличиваем счетчик поиска */
        WHEre bf_temp_fbrglib_found-grp.obj-type = p-obj-type
         AND bf_temp_fbrglib_found-grp.obj-code = p-obj-code
         AND bf_temp_fbrglib_found-grp.level = v-level
    no-error .
    IF p-obj-type = "":U AND p-obj-code = 0  THEN DO:
        if available bf_temp_fbrglib_found-grp
        then do:
               assign
                v-found-grp-num-0  = v-found-grp-num + 1
                b-search-0 :label = "Далее"
            .
        end.
        else do:
            assign
                v-found-grp-num-0  = 0
                b-search-0 :label = "Поиск"
            .
        end.

    END.
    ELSE DO:
        if available bf_temp_fbrglib_found-grp
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
    END.

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
define output parameter p-fbr-gds-grp-recid as recid   no-undo.

    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.

    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.node-code = p-node-code
    no-error .
    if not available buf_fbr-gds-grp
    then do:
        undo, return error "get-current-recid: Не найдена группа." .
    end.
    assign
        p-fbr-gds-grp-recid = recid( buf_fbr-gds-grp )
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
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-node-code  as integer      no-undo.
define output parameter p-prefix    as character    no-undo.

define variable v-name          as character    no-undo.
define variable v-is-terminal   as logical      no-undo.
define variable v-have-goods    as logical      no-undo.

define buffer buf_fbr-gds-grp               for ub.fbr-gds-grp.
define buffer buf_temp_fbrglib_grp       for temp_fbrglib_grp.

run fbrglib-is-terminal in this-procedure (
      input p-obj-type
    , input p-obj-code
    , input p-node-code
    , output v-is-terminal
) no-error .
if error-status :error
then do:
    undo, return error "get-first-char: Ошибка при определении типа группы (терм/корн).".
end.
if v-is-terminal = yes
then do:                    /* Терминальная группа */
    run fbrglib-have-goods in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-node-code
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
end.        /* not available buf_fbr-gds-grp */
else do:
    find first buf_temp_fbrglib_grp no-lock
         where buf_temp_fbrglib_grp.upper-code = p-node-code
         AND buf_temp_fbrglib_grp.obj-type  = p-obj-type
         AND buf_temp_fbrglib_grp.obj-code  = p-obj-code
    no-error.
    if available buf_temp_fbrglib_grp
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
end.        /* available buf_fbr-gds-grp */
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-obj-type Dlg-grp
PROCEDURE get-obj-type :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-obj-code   as integer      no-undo.
define output parameter p-obj-type  as character    no-undo.

    define buffer buf_shop_clients      for ub.clients.
    define buffer buf_stock_clients     for ub.clients.

    find first buf_shop_clients no-lock
         where buf_shop_clients.obj-type = {&shop}
           and buf_shop_clients.obj-code = p-obj-code
    no-error.
    find first buf_stock_clients no-lock
         where buf_stock_clients.obj-type = {&stock}
           and buf_stock_clients.obj-code = p-obj-code
    no-error.
    if available buf_shop_clients
    then do:
        if available buf_stock_clients
        then do:
            run str/fbrplnds.w (
                  input "Выберите тип объекта:"
                , output p-obj-type
            ) no-error.
            if error-status :error
            then do:
                message
                         vss-workfile vss-revision vss-description
                    skip "Ошибка определения типа объекта."
                    skip return-value
                    skip trim(error-status :get-message(1))
                         trim(error-status :get-message(2))
                         trim(error-status :get-message(3))
                view-as alert-box error.
                assign
                    p-obj-type = ?
                .
                undo, return error .
            end.
        end.        /* if available buf_stock_clients */
        else do:
            assign
                p-obj-type = buf_shop_clients.obj-type
            .
        end.        /* if not available buf_stock_clients */
    end.        /* if available buf_shop_clients */
    else do:
        if available buf_stock_clients
        then do:
            assign
                p-obj-type = buf_stock_clients.obj-type
            .
        end.        /* if available buf_stock_clients */
        else do:
            assign
                p-obj-type = ?
            .
        end.        /* if not available buf_stock_clients */
    end.        /* if not available buf_shop_clients */
end.
END PROCEDURE. /* get-obj-type */

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
define INPUT  parameter p-obj-type as character      no-undo.
define INPUT  parameter p-obj-code as integer      no-undo.
define output parameter p-row-amount as integer      no-undo.

    define buffer buf_temp_fbrglib_grp       for temp_fbrglib_grp.

    for each buf_temp_fbrglib_grp WHERE
           buf_temp_fbrglib_grp.obj-type = p-obj-type
       AND buf_temp_fbrglib_grp.obj-code = p-obj-code
    :
        assign
            p-row-amount = p-row-amount + 1
        .
    end.
end.
END PROCEDURE. /* get-row-amount */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE link-grp Dlg-grp
PROCEDURE link-grp :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.
define input parameter p-global-node-code  as integer      no-undo.
    define variable v-fbr-gds-grp-recid     as recid        no-undo.
    define variable v-focused-row           as integer      no-undo.
    define variable v-repositioned-row      as integer      no-undo.
    define variable v-have-rights           as logical      no-undo.

    define variable v-base                  as decimal      no-undo.
    define variable v-node-name             as character    no-undo.
    define variable v-out-code              as integer        no-undo.
    define variable v-cancel                as logical      no-undo.


    define buffer buf_fbr-gds-grp               for ub.fbr-gds-grp.
    define buffer bf0_fbr-gds-grp               for ub.fbr-gds-grp.
    define buffer buf_temp_fbrglib_grp       for temp_fbrglib_grp.
    define buffer buf_child_temp_fbrglib_grp for temp_fbrglib_grp.
    define buffer bf_fbr-gds-grp        for ub.fbr-gds-grp.

    if p-node-code = v-fbrggrp-root-code
    then do:
        message
        "Корневую группу изменить невозможно."
        view-as alert-box warning.
        undo, return .
    end.
    run check-rights-for-change-grp in this-procedure (
        output v-have-rights
    ) no-error.
    if error-status :error
    or v-have-rights = no
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Нет прав на изменение справочника групп блюд."
          skip "Изменение группы невозможно."
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
    do transaction
    on error undo, return error
    :
        find first buf_fbr-gds-grp exclusive-lock
             where buf_fbr-gds-grp.obj-type  = p-store-type
               and buf_fbr-gds-grp.obj-code  = p-store-code
               and buf_fbr-gds-grp.node-code = p-node-code
        .
        find first bf0_fbr-gds-grp NO-LOCK
             where bf0_fbr-gds-grp.obj-type  = "":U
               and bf0_fbr-gds-grp.obj-code  = 0
               and bf0_fbr-gds-grp.node-code = p-global-node-code
        .
        find first bf_fbr-gds-grp no-lock
            where bf_fbr-gds-grp.obj-type   = p-store-type
              and bf_fbr-gds-grp.obj-code   = p-store-code
              and bf_fbr-gds-grp.out-code   = bf0_fbr-gds-grp.out-code
        no-error.

        assign
        buf_fbr-gds-grp.global-code   = bf0_fbr-gds-grp.global-code
        buf_fbr-gds-grp.out-code      = (if available bf_fbr-gds-grp then 0 else bf0_fbr-gds-grp.out-code)
.
    end.        /* do transaction */
    find first buf_temp_fbrglib_grp
         where buf_temp_fbrglib_grp.node-code = p-node-code
    no-error.
    if not available buf_temp_fbrglib_grp
    then do:
        undo, return error "change-grp: Ошибка поиска группы в списке.".
    end.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.obj-type  = p-store-type
           and buf_fbr-gds-grp.obj-code  = p-store-code
           and buf_fbr-gds-grp.node-code = p-node-code
    no-error.
    if error-status :error
    then do:
        undo, return error "change-grp: Неверный выбор группы.".
    end.
    assign
    buf_temp_fbrglib_grp.global-code   = buf_fbr-gds-grp.global-code
    buf_temp_fbrglib_grp.out-code   = buf_fbr-gds-grp.out-code
    .
    {&OPEN-query-br-list}
    br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
    reposition br-list to row v-repositioned-row.
end.



END PROCEDURE.

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
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-node-code  as integer      no-undo.   /* Группа, которую перемещаем */
define input parameter p-upper-code as integer      no-undo.   /* Группа, к которой присоединяем */

    define variable v-node-full-name    as character    no-undo.
    define variable v-upper-full-name   as character    no-undo.
    define variable v-focused-row       as integer      no-undo.
    define variable v-repositioned-row  as integer      no-undo.
    define variable v-have-goods        as logical      no-undo.

    define buffer buf_fbr-gds-grp           for ub.fbr-gds-grp.
    define buffer buf_upper_fbr-gds-grp     for ub.fbr-gds-grp.
    define buffer buf_temp_fbrglib_grp   for temp_fbrglib_grp.

    { gbl/working.i }

    run fbrglib-have-goods in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-upper-code
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
    run fbrglib-get-full-name in this-procedure (
              input p-obj-type
            , input p-obj-code
            , input p-node-code
            , output v-node-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "move-item: Ошибка вычисления полного имени перемещаемой группы".
    end.
    run fbrglib-get-full-name in this-procedure (
              input p-obj-type
            , input p-obj-code
            , input p-upper-code
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
    /*find first buf_upper_fbr-gds-grp no-lock*/
    /*     where buf_upper_fbr-gds-grp.node-code = p-upper-code*/
    /*no-error .*/
    /*if not available buf_upper_fbr-gds-grp*/
    /*then do:*/
    /*    undo, return error "move-item: Не найдена родительская группа для перемещения.". */
    /*end.*/
    do transaction
    on error undo, return error "move-item: Ошибка перемещения группы.".
        find first buf_fbr-gds-grp exclusive-lock
             where buf_fbr-gds-grp.obj-type     = p-obj-type
               and buf_fbr-gds-grp.obj-code     = p-obj-code
               and buf_fbr-gds-grp.node-code    = p-node-code
        no-error .
        if not available buf_fbr-gds-grp
        then do:
            undo, return error "move-item: Не найдена группа для перемещения.".
        end.
        assign
            buf_fbr-gds-grp.upper-code = p-upper-code
        .
    end.
    assign
        p-recid-list = string( recid( buf_fbr-gds-grp ) )
        fbr-gds-grp-row  = recid( buf_fbr-gds-grp )
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
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define variable Line as character no-undo.
define variable date_string as character no-undo.
define buffer buf_temp_fbrglib_grp for temp_fbrglib_grp.

DEFINE FRAME brFrame
buf_temp_fbrglib_grp.global-code   format ">>>>9"      COLUMN-LABEL "Руб-р"
buf_temp_fbrglib_grp.name          format "X(71)"      column-label "Наименование группы"
buf_temp_fbrglib_grp.out-code      format ">>>>9"      COLUMN-LABEL "Код на!кассе"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 85 PAGE-NUMBER(PrnLibStream) AT 95 FORMAT ">>9" SKIP
Line format "X(150)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 150).
date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).
PUT  STREAM PrnLibStream
SPACE(25) ( if p-obj-type = "":U and p-obj-code = 0
            then br-global:title in frame {&frame-name}
            else br-list:title  )
format "x(90)" SKIP(1) .
FORM HEADER
Line format "X(150)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME BrFrame  .
run waitfram-show in this-procedure ("Ждите...").
FOR EACH buf_temp_fbrglib_grp where
        buf_temp_fbrglib_grp.obj-type = p-obj-type
    and buf_temp_fbrglib_grp.obj-code = p-obj-code :
  DISPLAY stream PrnLibStream
  buf_temp_fbrglib_grp.global-code
  buf_temp_fbrglib_grp.name
  buf_temp_fbrglib_grp.out-code
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
                                          ,input 8
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
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-node-code  as integer      no-undo.

    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.

    if print-option = "":U
    then do:
        run gbl/pop-up.p (
            input b-print:handle in frame {&frame-name}
            , input no
        ) no-error.
        if error-status:error
        then do:
            assign
                print-option = "":U
            .
            return no-apply.
        end.
    end.
    if p-node-code = 1
    then do:
        find first buf_fbr-gds-grp no-lock
             where buf_fbr-gds-grp.obj-type  = ""
               and buf_fbr-gds-grp.obj-code  = 0
               and buf_fbr-gds-grp.node-code = p-node-code
        no-error.
        if not available buf_fbr-gds-grp
        then do:
            undo, return error "Ошибка определения корневой группы.".
        end.
    end.        /* if p-node-code = 1 */
    else do:
        find first buf_fbr-gds-grp no-lock
             where buf_fbr-gds-grp.obj-type  = p-obj-type
               and buf_fbr-gds-grp.obj-code  = p-obj-code
               and buf_fbr-gds-grp.node-code = p-node-code
        no-error.
        if not available buf_fbr-gds-grp
        then do:
            undo, return error "Неверно выбрана группа.".
        end.
    end.        /* NOT ( if p-node-code = 1 ) */
    CASE print-option:
      when "browse":U then do:
        run print-browse in this-procedure (p-store-type, p-store-code)
        no-error.
      end.
      when "browse-global":U then do:
        run print-browse in this-procedure ("":U, 0)
        no-error.
      end.
      otherwise do:
        run rep/r-gdsggr.p (
              input parparentproc
            , input p-obj-type
            , input p-obj-code
            , input recid( buf_fbr-gds-grp )
            , input print-option
        ) no-error .
      end.
    END CASE.
    if error-status :error
    then do:
        assign
            print-option = "":U
        .
        undo, return error "Ошибка печати групп блюд.".
    end.
    apply "entry" to br-list in frame {&frame-name}.
end.
END PROCEDURE. /* print-grp */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-rubr Dlg-grp
PROCEDURE proc-b-rubr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER p-rubr AS LOGICAL NO-UNDO.
define buffer buf_clients for ub.clients.
find first buf_clients no-lock
     where buf_clients.obj-type = p-store-type
       and buf_clients.obj-code = p-store-code
.

CASE p-rubr:
    WHEN YES THEN DO:
        ASSIGN
       br-list:WIDTH IN FRAME {&FRAME-NAME} = 56
       b-expand:COL IN FRAME {&FRAME-NAME}            = v-b-expand-COL + 50
       b-expand-all:COL IN FRAME {&FRAME-NAME}        = v-b-expand-all-COL + 50
       b-find-by-full-name:COL IN FRAME {&FRAME-NAME} = v-b-find-by-full-name-COL + 50
       b-find-by-substring:COL IN FRAME {&FRAME-NAME} = v-b-find-by-substring-COL + 50
       br-list:COL IN FRAME {&FRAME-NAME}             = 44
       b-search:COL IN FRAME {&FRAME-NAME}            = v-b-search-COL + 50
       fi-search:COL IN FRAME {&FRAME-NAME}           = v-fi-search-COL + 50
       .

       DISPLAY
       b-copy0
       b-link
       b-expand-0
       b-expand-all-0
       b-find-by-full-name-0
       b-find-by-substring-0
       br-global
       b-search-0
       fi-search-0
       RECT-rubr
       WITH FRAME {&FRAME-NAME}.
       if v-cntxt-db-num <> buf_clients.db-num then do:
        DISABLE
        b-copy0
        b-link
        with frame {&frame-name} .
       end.
       else do:
        ENABLE
        b-copy0
        b-link
        with frame {&frame-name} .

       end.
       APPLY "ENTRY" to br-global.
    END.
    WHEN NO THEN DO:
        HIDE
        b-copy0
        b-link
        b-expand-0
        b-expand-all-0
        b-find-by-full-name-0
        b-find-by-substring-0
        br-global
        b-search-0
        fi-search-0
        RECT-rubr
        IN  FRAME {&FRAME-NAME}.
        ASSIGN
       b-expand:COL IN FRAME {&FRAME-NAME}            = v-b-expand-COL
       b-expand-all:COL IN FRAME {&FRAME-NAME}        = v-b-expand-all-COL
       b-find-by-full-name:COL IN FRAME {&FRAME-NAME} = v-b-find-by-full-name-COL
       b-find-by-substring:COL IN FRAME {&FRAME-NAME} = v-b-find-by-substring-COL
       br-list:COL IN FRAME {&FRAME-NAME} = 1
       b-search:COL IN FRAME {&FRAME-NAME} = v-b-search-COL
       fi-search:COL IN FRAME {&FRAME-NAME} = v-fi-search-COL
       br-list:WIDTH = 98
       .
       APPLY "ENTRY" to br-list.
    END.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE rubr-on Dlg-grp
PROCEDURE rubr-on :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------
  Purpose:     Заполнение temp_fbrglib_grp и инициализация при старте программы
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


define buffer buf_fbr-gds-grp           for ub.fbr-gds-grp.
define buffer buf_temp_fbrglib_grp   for temp_fbrglib_grp.

run fbrglib-get-root-code in this-procedure ( output v-fbrggrp-root-code ) no-error.
if error-status :error
then do:
    undo, return error "Не найден корневой узел." + {&new-line} + return-value.
end.
run uf-get in this-procedure(
     input  {&uf-fbr-gds-grp-p}
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
v-uf-List_ = if num-entries(v-uf-list_, {&delim-par}) = 1
              then (v-uf-list_ + {&delim-par} + {&question-mark})
              else v-uf-list_
fbr-gds-grp-row =  if (num-entries(v-uf-List_, {&delim-par}) < 2) or (entry(2, v-uf-List_, {&delim-par}) =  {&question-mark})
                   then ?
                   else integer(entry(2, v-uf-LIst_, {&delim-par}))
.
else do:
  assign
  v-uf-List_ = if num-entries(v-uf-list_, {&delim-par}) = 1
                then (v-uf-list_ + {&delim-par} + {&question-mark})
                else v-uf-list_
  fbr-gds-grp-row =  if (num-entries(v-uf-List_, {&delim-par}) < 2) or (entry(2, v-uf-List_, {&delim-par}) =  {&question-mark})
                    then ?
                    else integer(entry(2, v-uf-LIst_, {&delim-par}))
  .
end.
assign
    p-recid-list = (if p-recid-list = "":U then string( fbr-gds-grp-row ) else p-recid-list)
.
find first buf_fbr-gds-grp no-lock
     where buf_fbr-gds-grp.node-code = v-fbrggrp-root-code
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
for each buf_temp_fbrglib_grp
:
    delete buf_temp_fbrglib_grp.
end.
create buf_temp_fbrglib_grp.
assign
    buf_temp_fbrglib_grp.node-code   = buf_fbr-gds-grp.node-code
    buf_temp_fbrglib_grp.upper-code  = buf_fbr-gds-grp.upper-code
    buf_temp_fbrglib_grp.level       = 0
    buf_temp_fbrglib_grp.mark        = ( if v-have-goods = yes then {&terminal-with-goods-grp-mark} else {&terminal-no-goods-grp-mark} )
    buf_temp_fbrglib_grp.full-name   = {&delim-par}            /* Символ chr(1) - первый для сортировки */
    buf_temp_fbrglib_grp.sort-name   = {&delim-par}            /* Символ chr(1) - первый для сортировки */
    buf_temp_fbrglib_grp.name        = buf_fbr-gds-grp.node-name
    buf_temp_fbrglib_grp.out-code    = buf_fbr-gds-grp.out-code
.

for each buf_fbr-gds-grp no-lock
    where buf_fbr-gds-grp.obj-type   = "":U
      and buf_fbr-gds-grp.obj-code   = 0
      and buf_fbr-gds-grp.upper-code = v-fbrggrp-root-code
 :
     run create-new-line in this-procedure (
           input buf_fbr-gds-grp.obj-type
         , input buf_fbr-gds-grp.obj-code
         , input buf_fbr-gds-grp.node-code
         , input buf_fbr-gds-grp.upper-code
         , input 1
         , input buf_fbr-gds-grp.node-name
         , input buf_fbr-gds-grp.out-code
         , input buf_fbr-gds-grp.global-code
     ) no-error .
     if error-status :error
     then do:
         message
           vss-workfile vss-revision vss-description
           skip "rubr-on: Ошибка добавления строки в список групп."
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
    assign
        v-reposition-row = 1
        v-focused-row    = 1
    .
    find first buf_fbr-gds-grp no-lock
         where recid( buf_fbr-gds-grp ) = integer( entry( num-entries( p-recid-list ), p-recid-list ) )
    no-error .
    if not available buf_fbr-gds-grp
    then do:
        /* Не найдена группа, выбранная в прошлый раз. */
    end.
    else do:
        run expand-tree-for-grp in this-procedure (
              input buf_fbr-gds-grp.obj-type
            , input buf_fbr-gds-grp.obj-code
            , input buf_fbr-gds-grp.node-code
            , output v-focused-row
            , output v-reposition-row
            , output v-reposition-to-recid
        ) no-error .
        if error-status :error
        then do:
            undo, return error "rubr-on: Не удалось раскрыть дерево групп." + {&new-line} + return-value.
        end.
    end.
end.
ASSIGN
b-print:MENU-MOUSE in frame {&frame-name} =  1
br-global:width = 98
.
DISPLAY fi-search-0
WITH FRAME {&frame-name} .
ENABLE
b-exit
b-sel WHEN LOOKUP({&button-sel-only}, p-button-list) > 0
b-help
b-expand-0
b-expand-all-0
fi-search-0
b-find-by-full-name-0
b-find-by-substring-0
b-search-0
br-global
WITH FRAME {&frame-name} .
VIEW FRAME {&frame-name} .
hide
fi-kitchen-type
fi-kitchen-code
b-mark
b-add b-chg b-del b-move b-goods b-print
B-global b-copy fi-kitchen-code bt-sel-kitchen
b-expand b-expand-all fi-search b-find-by-full-name
b-find-by-substring b-search B-copy0 B-link
br-list RECT-rubr
in FRAME {&frame-name} .
{&OPEN-QUERY-br-global}
br-global :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame {&FRAME-NAME}.
if v-reposition-to-recid = no
then do:
    reposition br-global to row v-reposition-row no-error .
end.
else do:
    reposition br-global to recid v-reposition-row no-error .
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

    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.

    if p-node-code = v-fbrggrp-root-code
    then do:
        message
        "Корневую группу переместить невозможно."
        view-as alert-box warning.
        undo, return .
    end.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.obj-type  = p-store-type
           and buf_fbr-gds-grp.obj-code  = p-store-code
           and buf_fbr-gds-grp.node-code = p-node-code
    no-error .
    if error-status :error
    then do:
        undo, return error "select-and-move-item: Группа не найдена в базе данных.".
    end.
    assign
        v-upper-recid-list = string( recid( buf_fbr-gds-grp ) )
    .
    run ref/fbrggrp.w (
          input parparentproc
        , input p-store-type
        , input p-store-code
        , input {&buttons-for-move}
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
        view-as alert-box error.
        undo, return no-apply .
    end.
    find first buf_fbr-gds-grp no-lock
         where recid( buf_fbr-gds-grp ) = integer( entry( 1, v-upper-recid-list ) )
    no-error .
    if error-status :error
    then do:
        undo, return error "Группа не найдена.".
    end.
    run fbrglib-get-full-name in this-procedure (
          input p-store-type
        , input p-store-code
        , input p-node-code
        , output v-node-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "Ошибка вычисления полного имени перемещаемой группы.".
    end.
    run fbrglib-get-full-name in this-procedure (
          input buf_fbr-gds-grp.obj-type
        , input buf_fbr-gds-grp.obj-code
        , input buf_fbr-gds-grp.node-code
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
        skip "    '" + ( if buf_fbr-gds-grp.node-code = v-fbrggrp-root-code then "Блюда" else v-upper-full-name ) + "'"
    view-as alert-box question
    buttons yes-no
    title "Перемещение группы"
    update v-yesno.
    if v-yesno = no
    then do:
        /* Отказ от перемещения группы */
    end.
    else do:
        run move-item in this-procedure (
              input p-store-type
            , input p-store-code
            , input p-node-code
            , input buf_fbr-gds-grp.node-code
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-kitchen Dlg-grp
PROCEDURE select-kitchen :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-old-obj-type   as character    no-undo.
define input parameter p-old-obj-code   as integer      no-undo.
define output parameter p-new-obj-type   as character    no-undo.
define output parameter p-new-obj-code   as integer      no-undo.

    define variable v-types as character no-undo .
    define variable v-old-cli-recid    as recid      no-undo.
    define variable v-new-cli-recid    as recid      no-undo.

    define buffer buf_clients       for ub.clients.
do
on error undo, return error
:
    assign
        v-types = {&shop}
    .
    find first buf_clients no-lock
         where buf_clients.obj-type = p-old-obj-type
           and buf_clients.obj-code = p-old-obj-code
    no-error.
    if available buf_clients
    then do:
        assign
            v-old-cli-recid = recid( buf_clients )
        .
    end.
    else do:
        assign
            v-old-cli-recid = ?
        .
    end.
    run ref/cli-all.w (
          input parparentproc
        , input "b-sel"
        , input v-types
        , input ?
        , input ?
        , input v-old-cli-recid
        , input ?
        , input ?
        , output v-new-cli-recid
    ) .
    find first buf_clients no-lock
         where recid( buf_clients ) = v-new-cli-recid
    no-error.
    if available buf_clients
    then do:
        assign
            p-new-obj-type = buf_clients.obj-type
            p-new-obj-code = buf_clients.obj-code
        .
    end.
    else do:
        assign
            p-new-obj-type = ""
            p-new-obj-code = 0
        .
    end.
end.
END PROCEDURE. /* select-kitchen */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE UI-on Dlg-grp
PROCEDURE UI-on :
/*------------------------------------------------------------------------------
  Purpose:     Заполнение temp_fbrglib_grp и инициализация при старте программы
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


define buffer buf_fbr-gds-grp           for ub.fbr-gds-grp.
define buffer buf_temp_fbrglib_grp   for temp_fbrglib_grp.

    { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_res-reference_update':U
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
run fbrglib-get-root-code in this-procedure ( output v-fbrggrp-root-code ) no-error.
if error-status :error
then do:
    undo, return error "Не найден корневой узел." + {&new-line} + return-value.
end.
run uf-get in this-procedure(
     input  {&uf-fbr-gds-grp-p}
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
fbr-gds-grp-row =  if entry(1, v-uf-List_, {&delim-par}) =  {&question-mark}
                   then ?
                   else integer(entry(1, v-uf-LIst_, {&delim-par}))
.
assign
    p-recid-list = (if p-recid-list = "":U then string( fbr-gds-grp-row ) else p-recid-list)
.
find first buf_fbr-gds-grp no-lock
     where buf_fbr-gds-grp.node-code = v-fbrggrp-root-code
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
run fbrglib-have-goods in this-procedure (
      input buf_fbr-gds-grp.obj-type
    , input buf_fbr-gds-grp.obj-code
    , input buf_fbr-gds-grp.node-code
    , output v-have-goods
) no-error .
if error-status :error
then do:
    undo, return error "UI-on: Ошибка определения наличия товаров в группе." + {&new-line} + return-value.
end.
for each buf_temp_fbrglib_grp
:
    delete buf_temp_fbrglib_grp.
end.
create buf_temp_fbrglib_grp.
assign
    buf_temp_fbrglib_grp.node-code   = buf_fbr-gds-grp.node-code
    buf_temp_fbrglib_grp.upper-code  = buf_fbr-gds-grp.upper-code
    buf_temp_fbrglib_grp.level       = 0
    buf_temp_fbrglib_grp.mark        = ( if v-have-goods = yes then {&terminal-with-goods-grp-mark} else {&terminal-no-goods-grp-mark} )
    buf_temp_fbrglib_grp.full-name   = {&delim-par}            /* Символ chr(1) - первый для сортировки */
    buf_temp_fbrglib_grp.sort-name   = {&delim-par}            /* Символ chr(1) - первый для сортировки */
    buf_temp_fbrglib_grp.name        = buf_fbr-gds-grp.node-name
    buf_temp_fbrglib_grp.out-code    = buf_fbr-gds-grp.out-code
.

create buf_temp_fbrglib_grp.
assign
    buf_temp_fbrglib_grp.node-code   = buf_fbr-gds-grp.node-code
    buf_temp_fbrglib_grp.upper-code  = buf_fbr-gds-grp.upper-code
    buf_temp_fbrglib_grp.level       = 0
    buf_temp_fbrglib_grp.mark        = ( if v-have-goods = yes then {&terminal-with-goods-grp-mark} else {&terminal-no-goods-grp-mark} )
    buf_temp_fbrglib_grp.full-name   = {&delim-par}            /* Символ chr(1) - первый для сортировки */
    buf_temp_fbrglib_grp.sort-name   = {&delim-par}            /* Символ chr(1) - первый для сортировки */
    buf_temp_fbrglib_grp.name        = buf_fbr-gds-grp.node-name
    buf_temp_fbrglib_grp.out-code    = buf_fbr-gds-grp.out-code
    buf_temp_fbrglib_grp.obj-type    = p-store-type
    buf_temp_fbrglib_grp.obj-code    = p-store-code
.

for each buf_fbr-gds-grp no-lock
    where buf_fbr-gds-grp.obj-type   = "":U
      and buf_fbr-gds-grp.obj-code   = 0
      and buf_fbr-gds-grp.upper-code = v-fbrggrp-root-code
 :
     run create-new-line in this-procedure (
           input buf_fbr-gds-grp.obj-type
         , input buf_fbr-gds-grp.obj-code
         , input buf_fbr-gds-grp.node-code
         , input buf_fbr-gds-grp.upper-code
         , input 1
         , input buf_fbr-gds-grp.node-name
         , input buf_fbr-gds-grp.out-code
         , input buf_fbr-gds-grp.global-code
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

for each buf_fbr-gds-grp no-lock
   where buf_fbr-gds-grp.obj-type   = p-store-type
     and buf_fbr-gds-grp.obj-code   = p-store-code
     and buf_fbr-gds-grp.upper-code = v-fbrggrp-root-code
:
    run create-new-line in this-procedure (
          input buf_fbr-gds-grp.obj-type
        , input buf_fbr-gds-grp.obj-code
        , input buf_fbr-gds-grp.node-code
        , input buf_fbr-gds-grp.upper-code
        , input 1
        , input buf_fbr-gds-grp.node-name
        , input buf_fbr-gds-grp.out-code
        , input buf_fbr-gds-grp.global-code
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
    assign
        v-reposition-row = 1
        v-focused-row    = 1
    .
    find first buf_fbr-gds-grp no-lock
         where recid( buf_fbr-gds-grp ) = integer( entry( num-entries( p-recid-list ), p-recid-list ) )
    no-error .
    if not available buf_fbr-gds-grp
    then do:
        /* Не найдена группа, выбранная в прошлый раз. */
    end.
    else do:
        run expand-tree-for-grp in this-procedure (
              input buf_fbr-gds-grp.obj-type
            , input buf_fbr-gds-grp.obj-code
            , input buf_fbr-gds-grp.node-code
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
ASSIGN
b-print:MENU-MOUSE in frame {&frame-name} =  1.
run enable_UI.
define variable v-current-db-num    as integer        no-undo.
define buffer buf_clients       for ub.clients.
{ gbl/curdbnum.i
    v-current-db-num
}
find first buf_clients no-lock
     where buf_clients.obj-type = p-store-type
       and buf_clients.obj-code = p-store-code
.
assign
    fi-kitchen-type :label = ""
.
hide
        b-sel
        b-mark
        b-add
        b-chg
        b-del
        b-move
        b-goods
        b-copy
        fi-kitchen-type
        fi-kitchen-code
        bt-sel-kitchen
in frame {&frame-name} .
if v-current-db-num = buf_clients.db-num
then do:
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
        when {&buttons-for-objcopy}
        then do:
            assign
                fi-kitchen-type :label = "Объект"
            .
            view
                fi-kitchen-type
                fi-kitchen-code
                bt-sel-kitchen
            in frame {&frame-name} .
            hide
                b-expand
                b-expand-all
                fi-search
                b-find-by-full-name
                b-find-by-substring
                b-search
            in frame {&frame-name} .
            if fi-kitchen-type <> ""
            and fi-kitchen-code <> 0
            then do:
                assign
                    frame {&frame-name} :title = substitute( "Группы блюд объекта &1 &2", fi-kitchen-type, fi-kitchen-code )
                .
            end.
        end.        /* when {&buttons-for-objcopy} */
        when {&buttons-for-admin}
        then do:
            view
                b-add
                b-chg
                b-del
                b-move
                b-goods
                b-copy
            in frame {&frame-name}.
            if v-enable-change-grp = no
            then do:
                disable
                    b-add
                    b-chg
                    b-del
                    b-move
                    b-goods
                    b-copy
                with frame {&frame-name}.
            end.
        end.
        when {&buttons-sel-term}
        or when {&button-sel-only}
        then do:
            view
                b-sel    in frame {&frame-name}
            .
        end.
        when {&buttons-sel-mark}
        then do:
            view
                b-sel    in frame {&frame-name}
                b-mark in frame {&frame-name}
            .
        end.
    end case.
end.        /* if v-current-db-num = buf_clients.db-num */
else do:
    view
        b-goods
    in frame {&frame-name}.
end.        /* if NOT( v-current-db-num = buf_clients.db-num ) */
RUN proc-b-rubr IN THIS-PROCEDURE (v-rubr).
br-global :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame {&FRAME-NAME}.
br-list :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame {&FRAME-NAME}.
if v-reposition-to-recid = no
then do:
    reposition br-list to row v-reposition-row no-error .
end.
else do:
    reposition br-list to recid v-reposition-row no-error .
end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME