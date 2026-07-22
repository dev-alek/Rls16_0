&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
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

Обмен данными с РКС. Конфигурация.

Автор: Гюнтнер Виктор Арнольдович
Дата создания: 04/12/06
Author: Victor Guntner
Creation date: 04/12/06

Input:

Output:

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter p-mainmenu-handle    as handle           no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Обмен данными с РКС. Конфигурация.".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ rcs/rcsimp.i   }
{ ref/grplib.i   }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-help bt-objects bt-mag bt-bind ~
bt-dir-imp bt-dir-exp bt-gds-grp bt-cli-grp bt-sel-integer ~
bt-sel-trn-doc-wrkr bt-sel-divisional bt-sel-trn-doc-agnt bt-sel-weight ~
bt-sel-trn-doc-boss
&Scoped-Define DISPLAYED-OBJECTS fi-dir-imp fi-dir-exp fi-gds-grp ~
fi-cli-grp fi-unit-integer fi-trn-doc-wrkr fi-unit-divisional ~
fi-trn-doc-agnt fi-unit-weight fi-trn-doc-boss

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

DEFINE BUTTON bt-bind
     LABEL "Выгрузка"
     SIZE 10 BY 1 TOOLTIP "Начальная выгрузка данных по товарам, приходным и продажным ценам".

DEFINE BUTTON bt-cli-grp
     LABEL "Группа для поставщи&ков"
     SIZE 30.63 BY 1.

DEFINE BUTTON bt-dir-exp
     LABEL "Каталог &экспорта"
     SIZE 38.25 BY 1.

DEFINE BUTTON bt-dir-imp
     LABEL "&Каталог &импорта"
     SIZE 38.25 BY 1.

DEFINE BUTTON bt-gds-grp
     LABEL "Группа для &товаров"
     SIZE 30.63 BY 1.

DEFINE BUTTON bt-mag
     LABEL "&Магазины"
     SIZE 10 BY 1.

DEFINE BUTTON bt-objects
     LABEL "&Таблицы"
     SIZE 10 BY 1.

DEFINE BUTTON bt-sel-divisional
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.63 BY 1.04.

DEFINE BUTTON bt-sel-integer
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.63 BY 1.04.

DEFINE BUTTON bt-sel-trn-doc-agnt
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.63 BY 1.04.

DEFINE BUTTON bt-sel-trn-doc-boss
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.63 BY 1.04.

DEFINE BUTTON bt-sel-trn-doc-wrkr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.63 BY 1.04.

DEFINE BUTTON bt-sel-weight
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.63 BY 1.04.

DEFINE VARIABLE fi-cli-grp AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 30.5 BY 1
     FGCOLOR 9  NO-UNDO.

DEFINE VARIABLE fi-count AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 61.63 BY 1 NO-UNDO.

DEFINE VARIABLE fi-dir-exp AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 61.63 BY 1
     FGCOLOR 9  NO-UNDO.

DEFINE VARIABLE fi-dir-imp AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 61.5 BY 1
     FGCOLOR 9  NO-UNDO.

DEFINE VARIABLE fi-gds-grp AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 30.5 BY 1
     FGCOLOR 9  NO-UNDO.

DEFINE VARIABLE fi-trn-doc-agnt AS CHARACTER FORMAT "X(17)":U
     VIEW-AS FILL-IN
     SIZE 17.13 BY 1
     FGCOLOR 9  NO-UNDO.

DEFINE VARIABLE fi-trn-doc-boss AS CHARACTER FORMAT "X(17)":U
     VIEW-AS FILL-IN
     SIZE 17.13 BY 1
     FGCOLOR 9  NO-UNDO.

DEFINE VARIABLE fi-trn-doc-wrkr AS CHARACTER FORMAT "X(17)":U
     VIEW-AS FILL-IN
     SIZE 17.13 BY 1
     FGCOLOR 9  NO-UNDO.

DEFINE VARIABLE fi-unit-divisional AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 5.5 BY 1
     FGCOLOR 9  NO-UNDO.

DEFINE VARIABLE fi-unit-integer AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 5.5 BY 1
     FGCOLOR 9  NO-UNDO.

DEFINE VARIABLE fi-unit-weight AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 5.5 BY 1
     FGCOLOR 9  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.17 COL 2.5
     b-help AT ROW 1.17 COL 53.13
     bt-objects AT ROW 3 COL 2.5
     bt-mag AT ROW 3 COL 13.38
     bt-bind AT ROW 3 COL 53.13
     fi-count AT ROW 4.42 COL 2.5 NO-LABEL
     bt-dir-imp AT ROW 4.5 COL 2.5
     fi-dir-imp AT ROW 5.5 COL 2.5 NO-LABEL
     bt-dir-exp AT ROW 7 COL 2.5
     fi-dir-exp AT ROW 8 COL 2.5 NO-LABEL
     bt-gds-grp AT ROW 9.54 COL 2.5
     bt-cli-grp AT ROW 9.54 COL 33.5
     fi-gds-grp AT ROW 10.54 COL 2.5 NO-LABEL
     fi-cli-grp AT ROW 10.54 COL 33.5 NO-LABEL
     fi-unit-integer AT ROW 13.17 COL 11.5 COLON-ALIGNED NO-LABEL
     bt-sel-integer AT ROW 13.21 COL 20
     fi-trn-doc-wrkr AT ROW 13.21 COL 40 COLON-ALIGNED NO-LABEL
     bt-sel-trn-doc-wrkr AT ROW 13.25 COL 60.13
     bt-sel-divisional AT ROW 14.13 COL 20
     fi-unit-divisional AT ROW 14.17 COL 11.5 COLON-ALIGNED NO-LABEL
     bt-sel-trn-doc-agnt AT ROW 14.17 COL 60.13
     fi-trn-doc-agnt AT ROW 14.21 COL 40 COLON-ALIGNED NO-LABEL
     fi-unit-weight AT ROW 15.17 COL 11.5 COLON-ALIGNED NO-LABEL
     bt-sel-weight AT ROW 15.17 COL 20
     fi-trn-doc-boss AT ROW 15.21 COL 40 COLON-ALIGNED NO-LABEL
     bt-sel-trn-doc-boss AT ROW 15.21 COL 60.13
     "Исполнитель" VIEW-AS TEXT
          SIZE 14.25 BY .96 AT ROW 14.21 COL 27.13
     "Кладовщик" VIEW-AS TEXT
          SIZE 14 BY .96 AT ROW 13.21 COL 27.13
     "Штучный" VIEW-AS TEXT
          SIZE 8.5 BY .96 AT ROW 13.21 COL 2.63
     "Дробный" VIEW-AS TEXT
          SIZE 8.5 BY .96 AT ROW 14.21 COL 2.63
     "Весовой" VIEW-AS TEXT
          SIZE 8.5 BY .96 AT ROW 15.21 COL 2.63
     "Менеджер" VIEW-AS TEXT
          SIZE 14.38 BY .96 AT ROW 15.21 COL 27.13
     "Приходные накладные" VIEW-AS TEXT
          SIZE 30.63 BY 1.08 AT ROW 11.92 COL 27
     "Единицы измерения" VIEW-AS TEXT
          SIZE 21.75 BY 1.08 AT ROW 11.92 COL 2.63
     SPACE(40.11) SKIP(3.78)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Настройки обмена данными с РКС".


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
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN fi-cli-grp IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fi-count IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE ALIGN-L                                         */
/* SETTINGS FOR FILL-IN fi-dir-exp IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fi-dir-imp IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fi-gds-grp IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fi-trn-doc-agnt IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-trn-doc-boss IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-trn-doc-wrkr IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-unit-divisional IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-unit-integer IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-unit-weight IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Обмен данными с РКС */
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


&Scoped-define SELF-NAME bt-bind
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-bind Dialog-Frame
ON CHOOSE OF bt-bind IN FRAME Dialog-Frame /* Выгрузка */
DO:
    message
            "Операция может занять много времени."
            skip "Запустить выгрузку?"
        view-as alert-box question
        buttons yes-no
        title "Начальная выгрузка данных"
        update v-yesno as logical
    .
    if v-yesno = yes
    then do:
        hide bt-dir-imp fi-dir-imp bt-objects bt-mag.
        view
            fi-count
        .
        run rcs/exp-ini.p ( input fi-count :handle ) no-error.
        if error-status :error
        then do:
            message
              vss-workfile vss-revision vss-description
              skip "Ошибка начальной выгрузки данных по товарам."
              skip return-value
              skip trim(error-status :get-message(1))
                   trim(error-status :get-message(2))
                   trim(error-status :get-message(3))
            view-as alert-box error.
            hide fi-count.
            view bt-dir-imp fi-dir-imp bt-objects bt-mag.
            undo, return no-apply .
        end.
        hide fi-count.
        view bt-dir-imp fi-dir-imp bt-objects bt-mag.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-cli-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-cli-grp Dialog-Frame
ON CHOOSE OF bt-cli-grp IN FRAME Dialog-Frame /* Группа для поставщиков */
DO:
    define variable v-grp-name   as character         no-undo.
    define variable v-cancel    as logical           no-undo.
    run select-default-cli-grp in this-procedure (
        output v-grp-name
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка выбора группы по умолчанию для новых поставщиков."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if v-cancel = no
    then do:
        assign
            fi-cli-grp = v-grp-name
        .
        display
            fi-cli-grp
        with frame {&frame-name}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-dir-exp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-dir-exp Dialog-Frame
ON CHOOSE OF bt-dir-exp IN FRAME Dialog-Frame /* Каталог экспорта */
DO:
    define variable v-dir-exp   as character         no-undo.
    define variable v-cancel    as logical           no-undo.

    run select-dir in this-procedure (
            input {&rcsimp-export-directory}
          , output v-dir-exp
          , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка выбора каталога."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if v-cancel = no
    then do:
        assign
            fi-dir-exp = v-dir-exp
        .
        display
            fi-dir-exp
        with frame {&frame-name}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-dir-imp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-dir-imp Dialog-Frame
ON CHOOSE OF bt-dir-imp IN FRAME Dialog-Frame /* Каталог импорта */
DO:
    define variable v-dir-imp   as character         no-undo.
    define variable v-cancel    as logical           no-undo.

    run select-dir in this-procedure (
            input {&rcsimp-import-directory}
          , output v-dir-imp
          , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка выбора каталога."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if v-cancel = no
    then do:
        assign
            fi-dir-imp = v-dir-imp
        .
        display
            fi-dir-imp
        with frame {&frame-name}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-gds-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-gds-grp Dialog-Frame
ON CHOOSE OF bt-gds-grp IN FRAME Dialog-Frame /* Группа для товаров */
DO:
    define variable v-grp-name   as character         no-undo.
    define variable v-cancel    as logical           no-undo.
    run select-default-gds-grp in this-procedure (
        output v-grp-name
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка выбора группы по умолчанию для новых товаров."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if v-cancel = no
    then do:
        assign
            fi-gds-grp = v-grp-name
        .
        display
            fi-gds-grp
        with frame {&frame-name}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-mag
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-mag Dialog-Frame
ON CHOOSE OF bt-mag IN FRAME Dialog-Frame /* Магазины */
DO:
    run mag-tuning in this-procedure no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка выбора файлов для импорта."
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


&Scoped-define SELF-NAME bt-objects
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-objects Dialog-Frame
ON CHOOSE OF bt-objects IN FRAME Dialog-Frame /* Таблицы */
DO:
    run objects-tuning in this-procedure no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка выбора таблиц обмена."
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


&Scoped-define SELF-NAME bt-sel-divisional
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-divisional Dialog-Frame
ON CHOOSE OF bt-sel-divisional IN FRAME Dialog-Frame /* ... */
DO:
define variable v-unit-name     as character no-undo.
define variable v-cancel        as logical no-undo.
    run select-units in this-procedure (
          input {&divisional}
        , output v-unit-name
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка выбора единицы измерения."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    else do:
        if v-cancel = no
        then do:
            assign
                fi-unit-divisional :screen-value = v-unit-name
            .
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-integer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-integer Dialog-Frame
ON CHOOSE OF bt-sel-integer IN FRAME Dialog-Frame /* ... */
DO:
define variable v-unit-name     as character no-undo.
define variable v-cancel        as logical no-undo.
    run select-units in this-procedure (
          input {&pieces}
        , output v-unit-name
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка выбора единицы измерения."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    else do:
        if v-cancel = no
        then do:
            assign
                fi-unit-integer :screen-value = v-unit-name
            .
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-trn-doc-agnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-trn-doc-agnt Dialog-Frame
ON CHOOSE OF bt-sel-trn-doc-agnt IN FRAME Dialog-Frame /* ... */
DO:
define variable v-agnt-name     as character no-undo.
define variable v-cancel        as logical no-undo.
    run select-wrkr-agnt-boss in this-procedure (
          input {&permission}
        , output v-agnt-name
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка выбора исполнителя."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    else do:
        if v-cancel = no
        then do:
            assign
                fi-trn-doc-agnt :screen-value = v-agnt-name
            .
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-trn-doc-boss
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-trn-doc-boss Dialog-Frame
ON CHOOSE OF bt-sel-trn-doc-boss IN FRAME Dialog-Frame /* ... */
DO:
define variable v-boss-name     as character no-undo.
define variable v-cancel        as logical no-undo.
    run select-wrkr-agnt-boss in this-procedure (
          input {&shipping}
        , output v-boss-name
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка выбора менеджера."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    else do:
        if v-cancel = no
        then do:
            assign
                fi-trn-doc-boss :screen-value = v-boss-name
            .
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-trn-doc-wrkr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-trn-doc-wrkr Dialog-Frame
ON CHOOSE OF bt-sel-trn-doc-wrkr IN FRAME Dialog-Frame /* ... */
DO:
define variable v-wrkr-name     as character no-undo.
define variable v-cancel        as logical no-undo.
    run select-wrkr-agnt-boss in this-procedure (
          input {&preparation}
        , output v-wrkr-name
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка выбора кладовщика."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    else do:
        if v-cancel = no
        then do:
            assign
                fi-trn-doc-wrkr :screen-value = v-wrkr-name
            .
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-weight
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-weight Dialog-Frame
ON CHOOSE OF bt-sel-weight IN FRAME Dialog-Frame /* ... */
DO:
define variable v-unit-name     as character no-undo.
define variable v-cancel        as logical no-undo.
    run select-units in this-procedure (
          input {&weight}
        , output v-unit-name
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка выбора единицы измерения."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    else do:
        if v-cancel = no
        then do:
            assign
                fi-unit-weight :screen-value = v-unit-name
            .
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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
  RUN enable_UI.
    run init-fields in this-procedure no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка инициализации полей формы."
        skip return-value
        skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        trim(error-status :get-message(4))
        trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

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
  DISPLAY fi-dir-imp fi-dir-exp fi-gds-grp fi-cli-grp fi-unit-integer
          fi-trn-doc-wrkr fi-unit-divisional fi-trn-doc-agnt fi-unit-weight
          fi-trn-doc-boss
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-help bt-objects bt-mag bt-bind bt-dir-imp bt-dir-exp
         bt-gds-grp bt-cli-grp bt-sel-integer bt-sel-trn-doc-wrkr
         bt-sel-divisional bt-sel-trn-doc-agnt bt-sel-weight
         bt-sel-trn-doc-boss
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
    define variable v-dir           as character         no-undo.
    define variable v-grp-name      as character         no-undo.
    define variable v-unit-name     as character         no-undo.
    define variable v-person-name   as character         no-undo.
    define variable v-cancel        as logical           no-undo.

    define buffer buf_usr-flt       for ubflt.usr-flt.
    define buffer buf_gds-grp       for gds-grp.
    define buffer buf_cli-grp       for cli-grp.
    define buffer buf_clients       for clients.

    find first buf_usr-flt no-lock
         where buf_usr-flt.user-name    = {&all}
           and buf_usr-flt.call-point   = {&rcsimp-import-directory}
    no-error .
    if not available buf_usr-flt
    then do:
        run select-dir in this-procedure (
              input {&rcsimp-import-directory}
            , output v-dir
            , output v-cancel
        ) no-error .
        if error-status :error
        then do:
            undo, return error "init-fields: Ошибка выбора каталога." + {&new-line} + return-value.
        end.
        if v-cancel = no
        then do:
            assign
                fi-dir-imp :screen-value in frame {&frame-name} = v-dir
            .
        end.
    end.
    else do:
        assign
            fi-dir-imp :screen-value in frame {&frame-name} = buf_usr-flt.Naim
        .
    end.
    find first buf_usr-flt no-lock
         where buf_usr-flt.user-name    = {&all}
           and buf_usr-flt.call-point   = {&rcsimp-export-directory}
    no-error .
    if not available buf_usr-flt
    then do:
        run select-dir in this-procedure (
              input {&rcsimp-export-directory}
            , output v-dir
            , output v-cancel
        ) no-error .
        if error-status :error
        then do:
            undo, return error "init-fields: Ошибка выбора каталога." + {&new-line} + return-value.
        end.
        if v-cancel = no
        then do:
            assign
                fi-dir-exp :screen-value in frame {&frame-name} = v-dir
            .
        end.
    end.
    else do:
        assign
            fi-dir-exp :screen-value in frame {&frame-name} = buf_usr-flt.Naim
        .
    end.
    find first buf_usr-flt no-lock
         where buf_usr-flt.user-name    = {&all}
           and buf_usr-flt.call-point   = {&group}
    no-error .
    if not available buf_usr-flt
    then do:
        run select-default-gds-grp in this-procedure (
              output v-grp-name
            , output v-cancel
        ) no-error .
        if error-status :error
        then do:
            undo, return error "init-fields: Ошибка выбора группы товара по умолчанию." + {&new-line} + return-value.
        end.
        if v-cancel = no
        then do:
            assign
                fi-gds-grp :screen-value in frame {&frame-name} = v-grp-name
            .
        end.
    end.
    else do:
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = integer( buf_usr-flt.Naim )
        no-error .
        if not available buf_gds-grp
        then do:
            assign
               v-grp-name = ""
            .
        end.
        else do:
            run grplib-get-full-name in this-procedure (
                  input buf_gds-grp.node-code
                , output v-grp-name
            ) no-error .
            if error-status :error
            then do:
                assign
                    v-grp-name = ""
                .
            end.
        end.
        assign
            fi-gds-grp :screen-value in frame {&frame-name} = v-grp-name
        .
    end.
    find first buf_usr-flt no-lock
         where buf_usr-flt.user-name    = {&all}
           and buf_usr-flt.call-point   = {&clients-group}
    no-error .
    if not available buf_usr-flt
    then do:
        run select-default-cli-grp in this-procedure (
              output v-grp-name
            , output v-cancel
        ) no-error .
        if error-status :error
        then do:
            undo, return error "init-fields: Ошибка выбора группы для поставщика по умолчанию." + {&new-line} + return-value.
        end.
        if v-cancel = no
        then do:
            assign
                fi-cli-grp :screen-value in frame {&frame-name} = v-grp-name
            .
        end.
    end.
    else do:
        find first buf_cli-grp no-lock
             where buf_cli-grp.node-code = integer( buf_usr-flt.Naim )
        no-error .
        if not available buf_cli-grp
        then do:
            assign
               v-grp-name = ""
            .
        end.
        else do:
            assign
                v-grp-name = buf_cli-grp.node-name
            .
        end.
        assign
            fi-cli-grp :screen-value in frame {&frame-name} = v-grp-name
        .
    end.
    find first buf_usr-flt no-lock
         where buf_usr-flt.user-name    = {&all}
           and buf_usr-flt.call-point   = {&pieces}
    no-error .
    if not available buf_usr-flt
    then do:
        run select-units in this-procedure (
              input {&pieces}
            , output v-unit-name
            , output v-cancel
        ) no-error .
        if error-status :error
        then do:
            undo, return error "init-fields: Ошибка выбора штучной единицы измерения товара." + {&new-line} + return-value.
        end.
        if v-cancel = no
        then do:
            assign
                fi-unit-integer :screen-value in frame {&frame-name} = v-unit-name
            .
        end.
    end.
    else do:
        assign
            fi-unit-integer :screen-value in frame {&frame-name} = buf_usr-flt.Naim
        .
    end.

    find first buf_usr-flt no-lock
         where buf_usr-flt.user-name    = {&all}
           and buf_usr-flt.call-point   = {&divisional}
    no-error .
    if not available buf_usr-flt
    then do:
        run select-units in this-procedure (
              input {&divisional}
            , output v-unit-name
            , output v-cancel
        ) no-error .
        if error-status :error
        then do:
            undo, return error "init-fields: Ошибка выбора дробной единицы измерения товара." + {&new-line} + return-value.
        end.
        if v-cancel = no
        then do:
            assign
                fi-unit-divisional :screen-value in frame {&frame-name} = v-unit-name
            .
        end.
    end.
    else do:
        assign
            fi-unit-divisional :screen-value in frame {&frame-name} = buf_usr-flt.Naim
        .
    end.

    find first buf_usr-flt no-lock
         where buf_usr-flt.user-name    = {&all}
           and buf_usr-flt.call-point   = {&weight}
    no-error .
    if not available buf_usr-flt
    then do:
        run select-units in this-procedure (
              input {&weight}
            , output v-unit-name
            , output v-cancel
        ) no-error .
        if error-status :error
        then do:
            undo, return error "init-fields: Ошибка выбора весовой единицы измерения товара." + {&new-line} + return-value.
        end.
        if v-cancel = no
        then do:
            assign
                fi-unit-weight :screen-value in frame {&frame-name} = v-unit-name
            .
        end.
    end.
    else do:
        assign
            fi-unit-weight :screen-value in frame {&frame-name} = buf_usr-flt.Naim
        .
    end.
    find first buf_usr-flt no-lock
         where buf_usr-flt.user-name    = {&all}
           and buf_usr-flt.call-point   = {&preparation}
    no-error .
    if not available buf_usr-flt
    then do:
        run select-wrkr-agnt-boss in this-procedure (
              input {&preparation}
            , output v-person-name
            , output v-cancel
        ) no-error .
        if error-status :error
        then do:
            undo, return error "init-fields: Ошибка выбора кладовщика." + {&new-line} + return-value.
        end.
        if v-cancel = no
        then do:
            assign
                fi-trn-doc-wrkr :screen-value in frame {&frame-name} = v-person-name
            .
        end.
    end.
    else do:
        find first buf_clients no-lock
             where buf_clients.obj-type = {&prs}
               and buf_clients.obj-code = integer( buf_usr-flt.Naim )
        no-error .
        if not available buf_clients
        then do:
            assign
                fi-trn-doc-wrkr :screen-value in frame {&frame-name} = ""
            .
        end.
        else do:
            assign
                fi-trn-doc-wrkr :screen-value in frame {&frame-name} = buf_clients.obj-name
            .
        end.
    end.
    find first buf_usr-flt no-lock
         where buf_usr-flt.user-name    = {&all}
           and buf_usr-flt.call-point   = {&permission}
    no-error .
    if not available buf_usr-flt
    then do:
        run select-wrkr-agnt-boss in this-procedure (
              input {&permission}
            , output v-person-name
            , output v-cancel
        ) no-error .
        if error-status :error
        then do:
            undo, return error "init-fields: Ошибка выбора исполнителя." + {&new-line} + return-value.
        end.
        if v-cancel = no
        then do:
            assign
                fi-trn-doc-agnt :screen-value in frame {&frame-name} = v-person-name
            .
        end.
    end.
    else do:
        find first buf_clients no-lock
             where buf_clients.obj-type = {&prs}
               and buf_clients.obj-code = integer( buf_usr-flt.Naim )
        no-error .
        if not available buf_clients
        then do:
            assign
                fi-trn-doc-agnt :screen-value in frame {&frame-name} = ""
            .
        end.
        else do:
            assign
                fi-trn-doc-agnt :screen-value in frame {&frame-name} = buf_clients.obj-name
            .
        end.
    end.
    find first buf_usr-flt no-lock
         where buf_usr-flt.user-name    = {&all}
           and buf_usr-flt.call-point   = {&shipping}
    no-error .
    if not available buf_usr-flt
    then do:
        run select-wrkr-agnt-boss in this-procedure (
              input {&shipping}
            , output v-person-name
            , output v-cancel
        ) no-error .
        if error-status :error
        then do:
            undo, return error "init-fields: Ошибка выбора менеджера." + {&new-line} + return-value.
        end.
        if v-cancel = no
        then do:
            assign
                fi-trn-doc-boss :screen-value in frame {&frame-name} = v-person-name
            .
        end.
    end.
    else do:
        find first buf_clients no-lock
             where buf_clients.obj-type = {&prs}
               and buf_clients.obj-code = integer( buf_usr-flt.Naim )
        no-error .
        if not available buf_clients
        then do:
            assign
                fi-trn-doc-boss :screen-value in frame {&frame-name} = ""
            .
        end.
        else do:
            assign
                fi-trn-doc-boss :screen-value in frame {&frame-name} = buf_clients.obj-name
            .
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mag-tuning Dialog-Frame
PROCEDURE mag-tuning :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    run rcs/rcscnfm.w (
        input p-mainmenu-handle
    ) no-error.
    if error-status :error
    then do:
        undo, return error "objects-tuning: Ошибка настройки объектов rcs." + {&new-line} + return-value.
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE objects-tuning Dialog-Frame
PROCEDURE objects-tuning :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    run rcs/rcsimpd.w no-error .
    if error-status :error
    then do:
        undo, return error "objects-tuning: Ошибка настройки объектов rcs." + {&new-line} + return-value.
    end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-default-cli-grp Dialog-Frame
PROCEDURE select-default-cli-grp :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define output parameter p-grp-name       as character    no-undo.
define output parameter p-cancel        as logical      no-undo.

    define variable v-can-write as logical      no-undo.
    define variable v-grp-recid-string      as character no-undo.

    define buffer buf_usr-flt       for ubflt.usr-flt.
    define buffer buf_cli-grp          for cli-grp.

    find first buf_usr-flt exclusive-lock
         where buf_usr-flt.user-name    = {&all}
           and buf_usr-flt.call-point   = {&clients-group}
    no-error .
    if not available buf_usr-flt
    then do:
        create buf_usr-flt.
        assign
            buf_usr-flt.user-name    = {&all}
            buf_usr-flt.call-point   = {&clients-group}
            v-grp-recid-string = ""
        .
    end.
    else do:
        find first buf_cli-grp no-lock
             where buf_cli-grp.node-code = integer( buf_usr-flt.Naim )
        no-error .
        if not available buf_cli-grp
        then do:
            assign
                v-grp-recid-string = ""
            .
        end.
        else do:
            assign
                v-grp-recid-string = string( recid( buf_cli-grp ) )
            .
        end.
    end.
    run ref/cli-grps.w ( input p-mainmenu-handle, input {&g#term} + ',b-sel', input-output v-grp-recid-string ).
    if v-grp-recid-string = ""
    then do:
        assign
            p-cancel = yes
        .
    end.
    else do:
        find first buf_cli-grp no-lock
             where recid ( buf_cli-grp ) = integer ( v-grp-recid-string )
        no-error .
        if not available buf_cli-grp
        then do:
            assign
                buf_usr-flt.Naim = "0"
                p-grp-name       = ""
            .
        end.
        else do:
            assign
                buf_usr-flt.Naim    = string( buf_cli-grp.node-code )
                p-cancel            = no
            .
            assign
                p-grp-name = buf_cli-grp.node-name
            .
        end.
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-default-gds-grp Dialog-Frame
PROCEDURE select-default-gds-grp :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define output parameter p-grp-name       as character    no-undo.
define output parameter p-cancel        as logical      no-undo.

    define variable v-can-write as logical      no-undo.
    define variable v-grp-recid-string      as character no-undo.

    define buffer buf_usr-flt       for ubflt.usr-flt.
    define buffer buf_gds-grp       for gds-grp.

    find first buf_usr-flt exclusive-lock
         where buf_usr-flt.user-name    = {&all}
           and buf_usr-flt.call-point   = {&group}
    no-error .
    if not available buf_usr-flt
    then do:
        create buf_usr-flt.
        assign
            buf_usr-flt.user-name    = {&all}
            buf_usr-flt.call-point   = {&group}
            v-grp-recid-string = ""
        .
    end.
    else do:
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = integer( buf_usr-flt.Naim )
        no-error .
        if not available buf_gds-grp
        then do:
            assign
                v-grp-recid-string = ""
            .
        end.
        else do:
            assign
                v-grp-recid-string = string( recid( buf_gds-grp ) )
            .
        end.
    end.
    { gbl/getcntxt.i get " " p-mainmenu-handle }
    run ref/gds-grp.w (
          input p-mainmenu-handle
        , input {&g#term} + ',b-sel'
        , input v-cntxt-obj-type
        , input v-cntxt-obj-code
        , input-output v-grp-recid-string
    ).
    if v-grp-recid-string = ""
    then do:
        assign
            p-cancel = yes
        .
    end.
    else do:
        find first buf_gds-grp no-lock
             where recid ( buf_gds-grp ) = integer ( v-grp-recid-string )
        no-error .
        if not available buf_gds-grp
        then do:
            assign
                buf_usr-flt.Naim = "0"
                p-grp-name       = ""
            .
        end.
        else do:
            assign
                buf_usr-flt.Naim    = string( buf_gds-grp.node-code )
                p-cancel            = no
            .
            run grplib-get-full-name in this-procedure (
                  input buf_gds-grp.node-code
                , output p-grp-name
            ) no-error .
            if error-status :error
            then do:
                assign
                    p-grp-name = ""
                .
            end.
        end.
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-dir Dialog-Frame
PROCEDURE select-dir :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-impexp-type    as character    no-undo.
define output parameter p-dir           as character    no-undo.
define output parameter p-cancel        as logical      no-undo.

    define variable v-dir-type  as character    no-undo.
    define variable v-can-write as logical      no-undo.

    define buffer buf_usr-flt       for ubflt.usr-flt.

    run gbl/dir-sel.p (
          output p-dir
        , output v-dir-type
        , output v-can-write
    ) no-error .
    if error-status :error
    then do:
        assign
            p-cancel = yes
        .
        undo, return error "Ошибка выбора каталога импортируемых файлов." .
    end.
    else do:
        if v-can-write = no
        then do:
            assign
                p-cancel = yes
            .
            /* Отказ от выбора или выбран read-only каталог */
        end.
        else do:
            find first buf_usr-flt exclusive-lock
                 where buf_usr-flt.user-name    = {&all}
                   and buf_usr-flt.call-point   = p-impexp-type
            no-error .
            if not available buf_usr-flt
            then do:
                create buf_usr-flt.
                assign
                    buf_usr-flt.user-name    = {&all}
                    buf_usr-flt.call-point   = p-impexp-type
                .
            end.
            assign
                buf_usr-flt.Naim = p-dir
                p-cancel = no
            .
        end.
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-units Dialog-Frame
PROCEDURE select-units :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-unit-type  as character    no-undo.
define output parameter p-unit-name as character    no-undo.
define output parameter p-cancel    as logical      no-undo.

    define variable v-unit-recid     as recid             no-undo.

    define buffer buf_usr-flt       for ubflt.usr-flt.
    define buffer buf_units         for units.

    find first buf_usr-flt exclusive-lock
         where buf_usr-flt.user-name    = {&all}
           and buf_usr-flt.call-point   = p-unit-type
    no-error .
    if not available buf_usr-flt
    then do:
        create buf_usr-flt.
        assign
            buf_usr-flt.user-name    = {&all}
            buf_usr-flt.call-point   = p-unit-type
        .
    end.
    run ref/units.w (
          input p-mainmenu-handle
        , input yes
        , output v-unit-recid
    ) no-error .
    if error-status :error
    then do:
        undo, return error "select-units: Невозможно выбрать единицы измерения." + {&new-line} + return-value.
    end.
    if v-unit-recid = ?
    then do:
        assign
            p-cancel    = yes
        .
    end.
    else do:
        find first buf_units no-lock
             where recid ( buf_units ) = v-unit-recid
        no-error .
        if not available buf_units
        then do:
            assign
                p-unit-name = ""
                p-cancel    = no
            .
        end.
        else do:
            assign
                buf_usr-flt.Naim = buf_units.unit-name
                p-unit-name      = buf_units.unit-name
                p-cancel         = no
            .
        end.
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-wrkr-agnt-boss Dialog-Frame
PROCEDURE select-wrkr-agnt-boss :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-person  as character    no-undo.
define output parameter p-person-name as character    no-undo.
define output parameter p-cancel    as logical      no-undo.

    define variable v-person-recid-str     as character             no-undo.

    define buffer buf_usr-flt       for ubflt.usr-flt.

    define buffer buf_clients       for clients.
    define buffer buf_person        for person.

    find first buf_usr-flt exclusive-lock
         where buf_usr-flt.user-name    = {&all}
           and buf_usr-flt.call-point   = p-person
    no-error .
    if not available buf_usr-flt
    then do:
        create buf_usr-flt.
        assign
            buf_usr-flt.user-name    = {&all}
            buf_usr-flt.call-point   = p-person
        .
    end.
    run ref/cli-all.w (
          input p-mainmenu-handle
        , input "b-sel"
        , input {&all}
        , input {&all}
        , input {&all}
        , input ?
        , input ",,,,,,NO,,":u
        , input "":U
        , output v-person-recid-str
    ) no-error .
    if error-status :error
    then do:
        undo, return error "select-wrkr-agnt-boss: Невозможно выбрать клиента." + {&new-line} + return-value + ". " + trim(error-status :get-message(1)).
    end.
    if v-person-recid-str = ?
    or v-person-recid-str = ""
    then do:
        assign
            p-cancel    = yes
        .
    end.
    else do:
        find first buf_clients no-lock
             where recid( buf_clients ) = integer( v-person-recid-str )
        no-error .
        if not available buf_clients
        then do:
            assign
                p-person-name = ""
                p-cancel    = no
            .
        end.
        else do:
            find first buf_person no-lock
                 where buf_person.psn-code = buf_clients.obj-code
            no-error .
            if not available buf_person
            then do:
                undo, return error "select-wrkr-agnt-boss: Не найдена запись таблицы person." .
            end.
            assign
                buf_usr-flt.Naim = string( buf_person.psn-code )
                p-person-name    = buf_clients.obj-name
                p-cancel         = no
            .
        end.
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME