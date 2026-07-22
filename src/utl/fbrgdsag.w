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

Установка атрибутов товара (ресторан)

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc  as widget-handle no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Установка атрибутов товара (ресторан)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ cmp/gds-list.i gds-list def "new shared" }
{ gbl/temphost.i }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }

define temp-table temp_goods no-undo
    field gds-code          as integer
    field artic             as character
    field prod-type         as character
    field prod-code         as integer
    field gds-name          as character
    field unit-base         as character
    field is-cd             as character
    field is-menu           as character
    field is-modificator    as character
    field is-null-price     as character
    field is-season         as character
    field is-semi-finished  as character
    field fbr-obj-type      as character
    field fbr-obj-code      as integer

    index pi is primary unique
        gds-code
    index ar
        artic
        prod-type
        prod-code
    index nm
        gds-name
    index unit
        unit-base
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-table

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp_goods

/* Definitions for BROWSE br-table                                      */
&Scoped-define FIELDS-IN-QUERY-br-table temp_goods.artic temp_goods.gds-name temp_goods.unit-base temp_goods.is-cd temp_goods.is-menu temp_goods.is-modificator temp_goods.is-null-price temp_goods.is-season temp_goods.is-semi-finished temp_goods.fbr-obj-type temp_goods.fbr-obj-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-table
&Scoped-define SELF-NAME br-table
&Scoped-define QUERY-STRING-br-table FOR EACH temp_goods NO-LOCK
&Scoped-define OPEN-QUERY-br-table OPEN QUERY {&SELF-NAME} FOR EACH temp_goods NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-table temp_goods
&Scoped-define FIRST-TABLE-IN-QUERY-br-table temp_goods


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-table}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-goods bt-attr rs-range b-help ~
bt-set1 bt-set2 bt-set3 bt-set4 bt-set5 bt-set6 bt-set-obj br-table
&Scoped-Define DISPLAYED-OBJECTS rs-range

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

DEFINE BUTTON b-goods
     LABEL "&Товары"
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "Помощ&ь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON bt-attr
     LABEL "&Атрибуты"
     SIZE 10 BY 1.

DEFINE BUTTON bt-set-obj
     LABEL "..."
     SIZE 4.63 BY .79.

DEFINE BUTTON bt-set1
     LABEL "+-"
     SIZE 3.5 BY .79.

DEFINE BUTTON bt-set2
     LABEL "+-"
     SIZE 3.5 BY .79.

DEFINE BUTTON bt-set3
     LABEL "+-"
     SIZE 3.5 BY .79.

DEFINE BUTTON bt-set4
     LABEL "+-"
     SIZE 3.5 BY .79.

DEFINE BUTTON bt-set5
     LABEL "+-"
     SIZE 3.5 BY .79.

DEFINE BUTTON bt-set6
     LABEL "+-"
     SIZE 3.5 BY .79.

DEFINE VARIABLE rs-range AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "По фирме", 1,
"Глобально", 2
     SIZE 16.5 BY 2 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-table FOR
      temp_goods SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-table Dialog-Frame _FREEFORM
  QUERY br-table NO-LOCK DISPLAY
      temp_goods.artic format "X(17)" column-label "Артикул"
    temp_goods.gds-name format "X(39)" column-label "Наименование товара"
    temp_goods.unit-base format "X(3)" column-label "ЕИ"

    temp_goods.is-cd format "X(1)" column-label "кас"
    temp_goods.is-menu format "X(1)" column-label "блю"
    temp_goods.is-modificator format "X(1)" column-label "мод"
    temp_goods.is-null-price format "X(1)" column-label "цен"
    temp_goods.is-season format "X(1)" column-label "сез"
    temp_goods.is-semi-finished format "X(1)" column-label "плф"
    temp_goods.fbr-obj-type format "X(3)" column-label "тип"
    temp_goods.fbr-obj-code format ">>>>9" column-label "код кух"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96.88 BY 20.33.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1.63
     b-goods AT ROW 1 COL 11.63
     bt-attr AT ROW 1 COL 25.25
     rs-range AT ROW 1 COL 42.5 NO-LABEL
     b-help AT ROW 1 COL 88.63
     bt-set1 AT ROW 2.21 COL 62.38
     bt-set2 AT ROW 2.21 COL 65.88
     bt-set3 AT ROW 2.21 COL 69.38
     bt-set4 AT ROW 2.21 COL 72.88
     bt-set5 AT ROW 2.21 COL 76.38
     bt-set6 AT ROW 2.21 COL 79.88
     bt-set-obj AT ROW 2.21 COL 83.38
     br-table AT ROW 3 COL 1.63
     SPACE(0.46) SKIP(0.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Атрибуты товаров производства".


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
/* BROWSE-TAB br-table bt-set-obj Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-table
/* Query rebuild information for BROWSE br-table
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp_goods NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* BROWSE br-table */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Атрибуты товаров на объекте */
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


&Scoped-define SELF-NAME b-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-goods Dialog-Frame
ON CHOOSE OF b-goods IN FRAME Dialog-Frame /* Товары */
DO:
/*    run fill-gds-list in this-procedure .*/
    define variable v-gds-list-not-empty    as logical        no-undo.

    define buffer buf_goods         for goods.
    define buffer buf_temp_goods    for temp_goods.
    define buffer buf_fbr-gds-obj   for fbr-gds-obj.

    for each gds-list
    :
        delete gds-list.
    end.
    for each buf_temp_goods
    :
        find first buf_goods no-lock
             where buf_goods.gds-code = buf_temp_goods.gds-code
        .
        create gds-list.
        buffer-copy buf_goods to gds-list.
    end.
    run str/gds-list.w (input parparentproc, input v-cntxt-host-code-obj, input v-cntxt-obj-type, input v-cntxt-obj-code) .

    for each buf_temp_goods
    :
        delete buf_temp_goods.
    end.
    for each gds-list
    :
        run create-temp-goods in this-procedure (
              input gds-list.gds-code
            , input gds-list.artic
            , input gds-list.prod-type
            , input gds-list.prod-code
            , input gds-list.gds-name
            , input gds-list.unit-base
            , output v-gds-list-not-empty
        ).
    end.
    if v-gds-list-not-empty = yes
    then do:
        enable
            bt-attr
            bt-set1
            bt-set2
            bt-set3
            bt-set4
            bt-set5
            bt-set6
            bt-set-obj
        with frame {&frame-name}.
    end.
    else do:
        disable
            bt-attr
            bt-set1
            bt-set2
            bt-set3
            bt-set4
            bt-set5
            bt-set6
            bt-set-obj
        with frame {&frame-name}.
    end.
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-attr Dialog-Frame
ON CHOOSE OF bt-attr IN FRAME Dialog-Frame /* Атрибуты */
DO:
    define variable v-attr-list as character  no-undo.
    define variable v-recid     as recid      no-undo.
    define variable v-updated   as logical    no-undo .

    run ref/fgdsobji.w (
          input parparentproc
        , input 'template':U
        , input ( if available temp_goods then temp_goods.gds-code else 0 )
        , input v-cntxt-obj-type
        , input v-cntxt-obj-code
        , input no /*p-update-instantly в моде template не имеет значения*/
        , input-output v-attr-list
        , output v-updated
        , input-output v-recid
    ).
    if v-attr-list = '':U
    then do:
        undo, return no-apply.
    end.        /* if v-attr-list = '':U */
    else do:
        define variable v-yesno    as logical        no-undo.
        message
            skip "Для всех товаров списка"
            skip "будут установлены атрибуты:"
            skip(1)
            skip "Тип объекта кухни:"                entry( 7, v-attr-list )
            skip "Код объекта кухни:"                entry( 8, v-attr-list )
            skip "Является блюдом:"                  entry( 2, v-attr-list )
            skip "Является полуфабрикатом:"          entry( 6, v-attr-list )
            skip "Применять сезонный коэффициент:"   entry( 5, v-attr-list )
            skip "Модификатор блюда:"                entry( 3, v-attr-list )
            skip "Без цены:"                         entry( 4, v-attr-list )
            skip "Отправлять на кассу ресторана:"    entry( 1, v-attr-list )
            skip(1)
            skip "Назначить атрибуты всем товарам списка?"
        view-as alert-box question
        buttons yes-no
        title "Изменение атрибутов товаров списка"
        update v-yesno.
        if v-yesno = yes
        then do:
            { gbl/working.i }
            run set-attr in this-procedure (
                input v-attr-list
            ) no-error.
            if error-status :error
            then do:
                message
                         vss-workfile vss-revision vss-description
                    skip "Ошибка установки атрибутов на объекте."
                    skip return-value
                    skip trim(error-status :get-message(1))
                         trim(error-status :get-message(2))
                         trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return no-apply .
            end.
            { gbl/stopwork.i }
            {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
        end.
        else do:
            undo, return no-apply.
        end.
    end.        /* NOT ( if v-attr-list = '':U ) */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-set-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-set-obj Dialog-Frame
ON CHOOSE OF bt-set-obj IN FRAME Dialog-Frame /* ... */
DO:
    define variable v-yesno    as logical        no-undo.

    { gbl/working.i }
    run set-one-attr in this-procedure (
          input "object":U
        , input v-yesno
    ) no-error.
    if error-status :error
    then do:
        message
            vss-workfile vss-revision vss-description
            skip "Ошибка установки атрибута."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    run create-temp-obj in this-procedure (
        input rs-range
    ).
    { gbl/stopwork.i }
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-set1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-set1 Dialog-Frame
ON CHOOSE OF bt-set1 IN FRAME Dialog-Frame /* +- */
DO:
    define variable v-yesno    as logical        no-undo.

    message
        skip "Для всех товаров списка"
        skip "будет изменен атрибут:"
        skip(1)
        skip "'Отправлять на кассу ресторана'"
        skip(1)
        skip "Yes - Установить атрибут"
        skip "No  - Снять атрибут"
        skip "Cancel - Не изменять значение атрибута"
        skip(1)
        skip "Назначить атрибут всем товарам списка?"
    view-as alert-box question
    buttons yes-no-cancel
    title "Изменение атрибутов товаров списка"
    update v-yesno.
    if v-yesno = ?
    then do:
        undo, return no-apply.
    end.
    { gbl/working.i }
    run set-one-attr in this-procedure (
          input "is-cd":U
        , input v-yesno
    ) no-error.
    if error-status :error
    then do:
        message
            vss-workfile vss-revision vss-description
            skip "Ошибка установки атрибута."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    run create-temp-obj in this-procedure (
        input rs-range
    ).
    { gbl/stopwork.i }
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-set2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-set2 Dialog-Frame
ON CHOOSE OF bt-set2 IN FRAME Dialog-Frame /* +- */
DO:
    define variable v-yesno    as logical        no-undo.

    message
        skip "Для всех товаров списка"
        skip "будет изменен атрибут:"
        skip(1)
        skip "'Блюдо'"
        skip(1)
        skip "Yes - Установить атрибут"
        skip "No  - Снять атрибут"
        skip "Cancel - Не изменять значение атрибута"
        skip(1)
        skip "Назначить атрибут всем товарам списка?"
    view-as alert-box question
    buttons yes-no-cancel
    title "Изменение атрибутов товаров списка"
    update v-yesno.
    if v-yesno = ?
    then do:
        undo, return no-apply.
    end.
    { gbl/working.i }
    run set-one-attr in this-procedure (
          input "is-menu":U
        , input v-yesno
    ) no-error.
    if error-status :error
    then do:
        message
            vss-workfile vss-revision vss-description
            skip "Ошибка установки атрибута."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    run create-temp-obj in this-procedure (
        input rs-range
    ).
    { gbl/stopwork.i }
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-set3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-set3 Dialog-Frame
ON CHOOSE OF bt-set3 IN FRAME Dialog-Frame /* +- */
DO:
    define variable v-yesno    as logical        no-undo.

    message
        skip "Для всех товаров списка"
        skip "будет изменен атрибут:"
        skip(1)
        skip "'Модификатор'"
        skip(1)
        skip "Yes - Установить атрибут"
        skip "No  - Снять атрибут"
        skip "Cancel - Не изменять значение атрибута"
        skip(1)
        skip "Назначить атрибут всем товарам списка?"
    view-as alert-box question
    buttons yes-no-cancel
    title "Изменение атрибутов товаров списка"
    update v-yesno.
    if v-yesno = ?
    then do:
        undo, return no-apply.
    end.
    { gbl/working.i }
    run set-one-attr in this-procedure (
          input "is-modificator":U
        , input v-yesno
    ) no-error.
    if error-status :error
    then do:
        message
            vss-workfile vss-revision vss-description
            skip "Ошибка установки атрибута."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    run create-temp-obj in this-procedure (
        input rs-range
    ).
    { gbl/stopwork.i }
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-set4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-set4 Dialog-Frame
ON CHOOSE OF bt-set4 IN FRAME Dialog-Frame /* +- */
DO:
    define variable v-yesno    as logical        no-undo.

    message
        skip "Для всех товаров списка"
        skip "будет изменен атрибут:"
        skip(1)
        skip "'Нулевая цена'"
        skip(1)
        skip "Yes - Установить атрибут"
        skip "No  - Снять атрибут"
        skip "Cancel - Не изменять значение атрибута"
        skip(1)
        skip "Назначить атрибут всем товарам списка?"
    view-as alert-box question
    buttons yes-no-cancel
    title "Изменение атрибутов товаров списка"
    update v-yesno.
    if v-yesno = ?
    then do:
        undo, return no-apply.
    end.
    { gbl/working.i }
    run set-one-attr in this-procedure (
          input "is-null-price":U
        , input v-yesno
    ) no-error.
    if error-status :error
    then do:
        message
            vss-workfile vss-revision vss-description
            skip "Ошибка установки атрибута."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    run create-temp-obj in this-procedure (
        input rs-range
    ).
    { gbl/stopwork.i }
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-set5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-set5 Dialog-Frame
ON CHOOSE OF bt-set5 IN FRAME Dialog-Frame /* +- */
DO:
    define variable v-yesno    as logical        no-undo.

    message
        skip "Для всех товаров списка"
        skip "будет изменен атрибут:"
        skip(1)
        skip "'Учитывать сезонный коэффициент'"
        skip(1)
        skip "Yes - Установить атрибут"
        skip "No  - Снять атрибут"
        skip "Cancel - Не изменять значение атрибута"
        skip(1)
        skip "Назначить атрибут всем товарам списка?"
    view-as alert-box question
    buttons yes-no-cancel
    title "Изменение атрибутов товаров списка"
    update v-yesno.
    if v-yesno = ?
    then do:
        undo, return no-apply.
    end.
    { gbl/working.i }
    run set-one-attr in this-procedure (
          input "is-season":U
        , input v-yesno
    ) no-error.
    if error-status :error
    then do:
        message
            vss-workfile vss-revision vss-description
            skip "Ошибка установки атрибута."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    run create-temp-obj in this-procedure (
        input rs-range
    ).
    { gbl/stopwork.i }
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-set6
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-set6 Dialog-Frame
ON CHOOSE OF bt-set6 IN FRAME Dialog-Frame /* +- */
DO:
    define variable v-yesno    as logical        no-undo.

    message
        skip "Для всех товаров списка"
        skip "будет изменен атрибут:"
        skip(1)
        skip "'Полуфабрикат'"
        skip(1)
        skip "Yes - Установить атрибут"
        skip "No  - Снять атрибут"
        skip "Cancel - Не изменять значение атрибута"
        skip(1)
        skip "Назначить атрибут всем товарам списка?"
    view-as alert-box question
    buttons yes-no-cancel
    title "Изменение атрибутов товаров списка"
    update v-yesno.
    if v-yesno = ?
    then do:
        undo, return no-apply.
    end.
    { gbl/working.i }
    run set-one-attr in this-procedure (
          input "is-semi-finished":U
        , input v-yesno
    ) no-error.
    if error-status :error
    then do:
        message
            vss-workfile vss-revision vss-description
            skip "Ошибка установки атрибута."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    run create-temp-obj in this-procedure (
        input rs-range
    ).
    { gbl/stopwork.i }
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-table
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


{ gbl/app_help.i }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   { gbl/getcntxt.i get }
   run init-fields in this-procedure.
   RUN enable_UI.
   disable
        bt-attr
        bt-set1
        bt-set2
        bt-set3
        bt-set4
        bt-set5
        bt-set6
        bt-set-obj
   with frame {&frame-name}.
   apply "entry" to b-goods.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-doc Dialog-Frame
PROCEDURE add-doc :
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE change-doc Dialog-Frame
PROCEDURE change-doc :
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE close-doc Dialog-Frame
PROCEDURE close-doc :
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-temp-goods Dialog-Frame
PROCEDURE create-temp-goods :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-gds-code               as integer          no-undo.
define input parameter p-artic                  as character        no-undo.
define input parameter p-prod-type              as character        no-undo.
define input parameter p-prod-code              as integer          no-undo.
define input parameter p-gds-name               as character        no-undo.
define input parameter p-unit-base              as character        no-undo.
define output parameter p-gds-list-not-empty    as logical          no-undo.

    define buffer buf_temp_goods        for temp_goods.
    define buffer buf_fbr-gds-obj       for fbr-gds-obj.
do
for buf_temp_goods
  , buf_fbr-gds-obj
on error undo, return error
:
        create buf_temp_goods.
        assign
            buf_temp_goods.gds-code           = p-gds-code
            buf_temp_goods.artic              = p-artic
            buf_temp_goods.prod-type          = p-prod-type
            buf_temp_goods.prod-code          = p-prod-code
            buf_temp_goods.gds-name           = p-gds-name
            buf_temp_goods.unit-base          = p-unit-base
            buf_temp_goods.is-cd              = "":U
            buf_temp_goods.is-menu            = "":U
            buf_temp_goods.is-modificator     = "":U
            buf_temp_goods.is-null-price      = "":U
            buf_temp_goods.is-season          = "":U
            buf_temp_goods.is-semi-finished   = "":U
            buf_temp_goods.fbr-obj-type       = "":U
            buf_temp_goods.fbr-obj-code       = -1
            p-gds-list-not-empty              = no
        .
        manufacturing-object:
        for each temp-obj
        on error undo, return error
        :
            find first buf_fbr-gds-obj no-lock
                 where buf_fbr-gds-obj.obj-type = temp-obj.obj-type
                   and buf_fbr-gds-obj.obj-code = temp-obj.obj-code
                   and buf_fbr-gds-obj.gds-code = p-gds-code
            no-error.
            if available buf_fbr-gds-obj
            then do:
                run get-logical-string in this-procedure (
                      input buf_temp_goods.is-cd
                    , input buf_fbr-gds-obj.is-cd
                    , output buf_temp_goods.is-cd
                ).
                run get-logical-string in this-procedure (
                      input buf_temp_goods.is-menu
                    , input buf_fbr-gds-obj.is-menu
                    , output buf_temp_goods.is-menu
                ).
                run get-logical-string in this-procedure (
                      input buf_temp_goods.is-modificator
                    , input buf_fbr-gds-obj.is-modificator
                    , output buf_temp_goods.is-modificator
                ).
                run get-logical-string in this-procedure (
                      input buf_temp_goods.is-null-price
                    , input buf_fbr-gds-obj.is-null-price
                    , output buf_temp_goods.is-null-price
                ).
                run get-logical-string in this-procedure (
                      input buf_temp_goods.is-season
                    , input buf_fbr-gds-obj.is-season
                    , output buf_temp_goods.is-season
                ).
                run get-logical-string in this-procedure (
                      input buf_temp_goods.is-semi-finished
                    , input buf_fbr-gds-obj.is-semi-finished
                    , output buf_temp_goods.is-semi-finished
                ).
                assign
                    buf_temp_goods.fbr-obj-type      = ( if buf_temp_goods.fbr-obj-type = "":U
                                                         or buf_temp_goods.fbr-obj-type = buf_fbr-gds-obj.fbr-obj-type
                                                         then buf_fbr-gds-obj.fbr-obj-type
                                                         else "?" )
                    buf_temp_goods.fbr-obj-code      = ( if buf_temp_goods.fbr-obj-code = -1
                                                         or buf_temp_goods.fbr-obj-code  = buf_fbr-gds-obj.fbr-obj-code
                                                         then buf_fbr-gds-obj.fbr-obj-code
                                                         else 0 )
                .
            end.
            if p-gds-list-not-empty = no
            then do:
                assign
                    p-gds-list-not-empty = yes
                .
            end.
        end.        /* for each temp-obj */
        if buf_temp_goods.fbr-obj-code = -1
        then do:
            assign
                buf_temp_goods.fbr-obj-code = 0
            .
        end.
end.
END PROCEDURE. /* create-temp-goods */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-temp-obj Dialog-Frame
PROCEDURE create-temp-obj :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input parameter p-range  as integer          no-undo.

    define buffer buf_shop      for shop.
do
for buf_shop
on error undo, return error
:
    for each temp-obj
    on error undo, return error
    :
        delete temp-obj.
    end.
    run init-temphost.
    if p-range = 1
    then do:
        for each temp-obj
        where temp-obj.host-code <> v-cntxt-host-code-obj
        on error undo, return error
        :
            delete temp-obj.
        end.
    end.
    for each temp-obj
    on error undo, return error
    :
        if temp-obj.obj-type <> {&shop}
        or temp-obj.db-num   <> v-cntxt-db-num
        then do:
            delete temp-obj.
        end.
        else do:
            find first buf_shop
                 where buf_shop.obj-code = temp-obj.obj-code
            .
            if buf_shop.is-catering = no
            and buf_shop.is-kitchen = no
            then do:
                delete temp-obj.
            end.
        end.
    end.
end.
END PROCEDURE. /* create-temp-obj */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE delete-doc Dialog-Frame
PROCEDURE delete-doc :
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
  DISPLAY rs-range
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-goods bt-attr rs-range b-help bt-set1 bt-set2 bt-set3 bt-set4
         bt-set5 bt-set6 bt-set-obj br-table
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
    assign
        rs-range = 1
    .
    run create-temp-obj in this-procedure (
        input rs-range
    ).
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE open-doc Dialog-Frame
PROCEDURE open-doc :
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-attr Dialog-Frame
PROCEDURE set-attr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-attr-list as character    no-undo.

    define variable v-fbr-gds-obj-recid    as recid      no-undo.

    define buffer buf_fbr-gds-obj   for fbr-gds-obj.
    define buffer buf_temp_goods    for temp_goods.
    define buffer buf_goods         for goods.

do
for buf_fbr-gds-obj
  , buf_temp_goods
  , buf_goods
on error undo, return error
:
    for each buf_temp_goods
    on error undo, return error
    :
        find first buf_goods no-lock
             where buf_goods.gds-code = buf_temp_goods.gds-code
        .
        for each temp-obj
        on error undo, return error
        :
            find first buf_fbr-gds-obj no-lock
                 where buf_fbr-gds-obj.obj-type = temp-obj.obj-type
                   and buf_fbr-gds-obj.obj-code = temp-obj.obj-code
                   and buf_fbr-gds-obj.gds-code = buf_temp_goods.gds-code
            no-error.
            if available buf_fbr-gds-obj
            then do:
                assign
                    v-fbr-gds-obj-recid = recid( buf_fbr-gds-obj )
                .
            end.        /* if available buf_fbr-gds-obj */
            else do:
                assign
                    v-fbr-gds-obj-recid = ?
                .
            end.        /* NOT ( if available buf_fbr-gds-obj ) */
            assign
                buf_temp_goods.is-cd            = ( if entry( 1, p-attr-list ) = "yes" then "+":U else "-":U )
                buf_temp_goods.is-menu          = ( if entry( 2, p-attr-list ) = "yes" then "+":U else "-":U )
                buf_temp_goods.is-modificator   = ( if entry( 3, p-attr-list ) = "yes" then "+":U else "-":U )
                buf_temp_goods.is-null-price    = ( if entry( 4, p-attr-list ) = "yes" then "+":U else "-":U )
                buf_temp_goods.is-season        = ( if entry( 5, p-attr-list ) = "yes" then "+":U else "-":U )
                buf_temp_goods.is-semi-finished = ( if entry( 6, p-attr-list ) = "yes" then "+":U else "-":U )
                buf_temp_goods.fbr-obj-type     = entry( 7, p-attr-list )
                buf_temp_goods.fbr-obj-code     = integer( entry( 8, p-attr-list ) )
            .
            run ref/fgdsobj1.p (
                input-output v-fbr-gds-obj-recid
                , input ( if available buf_fbr-gds-obj
                        then {&update}
                        else {&add-def} )
                , input no /*p-silent*/
                , input buf_temp_goods.gds-code
                , input temp-obj.obj-type
                , input temp-obj.obj-code
                , input ( if available buf_fbr-gds-obj then buf_fbr-gds-obj.fbr-grp-code else 0 )
                , input buf_temp_goods.fbr-obj-type       /* Тип объекта кухни */
                , input buf_temp_goods.fbr-obj-code       /* Код объекта кухни */
                , input ( buf_temp_goods.is-cd            = "+":U ) /* Отправлять на кассу ресторана */
                , input ( buf_temp_goods.is-menu          = "+":U ) /* Является блюдом   */
                , input ( buf_temp_goods.is-modificator   = "+":U ) /* Модификатор блюда */
                , input ( buf_temp_goods.is-null-price    = "+":U ) /* Без цены */
                , input ( buf_temp_goods.is-season        = "+":U ) /* Применять сезонный коэффициент */
                , input ( buf_temp_goods.is-semi-finished = "+":U ) /* Является полуфабрикатом */
            ) no-error.
            if error-status:error
            then do:
                message
                        vss-workfile vss-revision vss-description
                    skip "Ошибка изменения атрибутов товара на объекте"
                    skip return-value
                    skip trim(error-status :get-message(1))
                            trim(error-status :get-message(2))
                            trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return error .
            end.
        end.        /* for each temp-obj */
    end.        /* for each buf_temp_goods */
end.
END PROCEDURE. /* set-attr */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-one-attr Dialog-Frame
PROCEDURE set-one-attr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-attr-name  as character  no-undo.
define input parameter p-attr-value as logical      no-undo.

    define variable v-fbr-gds-obj-recid    as recid      no-undo.

    define buffer buf_fbr-gds-obj   for fbr-gds-obj.
    define buffer buf_temp_goods    for temp_goods.
    define buffer buf_goods         for goods.

do
for buf_fbr-gds-obj
  , buf_temp_goods
  , buf_goods
on error undo, return error
:
    if p-attr-name = 'object':U
    then do:
        define variable v-user-select as logical   no-undo .
        define variable v-obj-type    as character no-undo .
        define variable v-obj-code    as integer   no-undo .
        define variable v-yesno       as logical   no-undo .

        { gbl/uobjsone.i
          parparentproc
          v-cntxt-db-num
          v-cntxt-userid
          v-cntxt-host-code-obj
          v-cntxt-obj-type
          v-cntxt-obj-code
          v-user-select
          v-obj-type
          v-obj-code
        }
        if v-user-select = true
        then do:
            message
                skip "Для всех товаров списка"
                skip "будет изменен атрибут:"
                skip(1)
                skip "'Объект кухня'"
                skip "Новое значение атрибута:" v-obj-type v-obj-code
                skip(1)
                skip "Yes - Установить атрибут"
                skip "No  - Не изменять значение атрибута"
                skip(1)
                skip "Назначить атрибут всем товарам списка?"
            view-as alert-box question
            buttons yes-no
            title "Изменение атрибутов товаров списка"
            update v-yesno.
            if v-yesno = no
            then do:
                undo, return.
            end.
        end.
        else do:
            undo, return.
        end.
    end.
    for each buf_temp_goods
    on error undo, return error
    :
        find first buf_goods no-lock
             where buf_goods.gds-code = buf_temp_goods.gds-code
        .
        for each temp-obj
        on error undo, return error
        :
            find first buf_fbr-gds-obj no-lock
                 where buf_fbr-gds-obj.obj-type = temp-obj.obj-type
                   and buf_fbr-gds-obj.obj-code = temp-obj.obj-code
                   and buf_fbr-gds-obj.gds-code = buf_temp_goods.gds-code
            no-error.
            if available buf_fbr-gds-obj
            then do:
                assign
                    v-fbr-gds-obj-recid = recid( buf_fbr-gds-obj )
                .
            end.        /* if available buf_fbr-gds-obj */
            else do:
                assign
                    v-fbr-gds-obj-recid = ?
                .
            end.        /* NOT ( if available buf_fbr-gds-obj ) */
            case p-attr-name
            :
                when 'is-cd':U
                then do:
                    assign
                        buf_temp_goods.is-cd            = ( if p-attr-value = yes then "+":U else "-":U )
                    .
                end.
                when 'is-menu':U
                then do:
                    assign
                        buf_temp_goods.is-menu         = ( if p-attr-value = yes then "+":U else "-":U )
                    .
                    if p-attr-value = yes
                    and buf_temp_goods.is-semi-finished = "+":U
                    then do:
                        assign
                            buf_temp_goods.is-semi-finished = "-":U
                        .
                    end.
                    if p-attr-value = yes
                    and ( buf_temp_goods.fbr-obj-type = "":U
                    or buf_temp_goods.fbr-obj-type = "?":U
                    or buf_temp_goods.fbr-obj-code = 0 )
                    then do:
                        assign
                            buf_temp_goods.fbr-obj-type = temp-obj.obj-type
                            buf_temp_goods.fbr-obj-code = temp-obj.obj-code
                        .
                    end.
                end.
                when 'is-modificator':U
                then do:
                    assign
                        buf_temp_goods.is-modificator   = ( if p-attr-value = yes then "+":U else "-":U )
                    .
                end.
                when 'is-null-price':U
                then do:
                    assign
                        buf_temp_goods.is-null-price    = ( if p-attr-value = yes then "+":U else "-":U )
                    .
                end.
                when 'is-season':U
                then do:
                    assign
                        buf_temp_goods.is-season        = ( if p-attr-value = yes then "+":U else "-":U )
                    .
                end.
                when 'is-semi-finished':U
                then do:
                    assign
                        buf_temp_goods.is-semi-finished = ( if p-attr-value = yes then "+":U else "-":U )
                    .
                    if p-attr-value = yes
                    and buf_temp_goods.is-menu = "+":U
                    then do:
                        assign
                            buf_temp_goods.is-menu = "-":U
                        .
                    end.
                    if p-attr-value = yes
                    and ( buf_temp_goods.fbr-obj-type = "":U
                    or buf_temp_goods.fbr-obj-type = "?":U
                    or buf_temp_goods.fbr-obj-code = 0 )
                    then do:
                        assign
                            buf_temp_goods.fbr-obj-type = temp-obj.obj-type
                            buf_temp_goods.fbr-obj-code = temp-obj.obj-code
                        .
                    end.
                end.
                when 'object':U
                then do:
                    assign
                        buf_temp_goods.fbr-obj-type = v-obj-type
                        buf_temp_goods.fbr-obj-code = v-obj-code
                    .
                end.        /* when 'object' */
            end case.
            run ref/fgdsobj1.p (
                input-output v-fbr-gds-obj-recid
                , input ( if available buf_fbr-gds-obj
                        then {&update}
                        else {&add-def} )
                , input no /*p-silent*/
                , input buf_temp_goods.gds-code
                , input temp-obj.obj-type
                , input temp-obj.obj-code
                , input ( if available buf_fbr-gds-obj then buf_fbr-gds-obj.fbr-grp-code else 0 )
                , input buf_temp_goods.fbr-obj-type                 /* Тип объекта кухни */
                , input buf_temp_goods.fbr-obj-code                 /* Код объекта кухни */
                , input ( buf_temp_goods.is-cd            = "+":U ) /* Отправлять на кассу ресторана */
                , input ( buf_temp_goods.is-menu          = "+":U ) /* Является блюдом   */
                , input ( buf_temp_goods.is-modificator   = "+":U ) /* Модификатор блюда */
                , input ( buf_temp_goods.is-null-price    = "+":U ) /* Без цены */
                , input ( buf_temp_goods.is-season        = "+":U ) /* Применять сезонный коэффициент */
                , input ( buf_temp_goods.is-semi-finished = "+":U ) /* Является полуфабрикатом */
            ) no-error.
            if error-status:error
            then do:
                message
                        vss-workfile vss-revision vss-description
                    skip "Ошибка изменения атрибутов товара на объекте"
                    skip return-value
                    skip trim(error-status :get-message(1))
                            trim(error-status :get-message(2))
                            trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return error .
            end.
        end.        /* for each temp-obj */

    end.        /* for each buf_temp_goods */
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE view-doc Dialog-Frame
PROCEDURE view-doc :
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-logical-string {&FRAME-NAME}
PROCEDURE get-logical-string :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-current-string-value   as character        no-undo.
define input parameter p-current-logical-value  as logical          no-undo.
define output parameter p-new-string-value      as character        no-undo.
do
on error undo, return error
:
    if p-current-string-value = "?":U
    then do:
        assign
            p-new-string-value = "?":U
        .
        undo, return .
    end.
    if p-current-string-value = "":U
    then do:
        assign
            p-new-string-value = ( if p-current-logical-value = yes then "+":U else "-":U )
        .
    end.
    else do:
        if ( p-current-string-value     = "+":U
            and p-current-logical-value = no )
        or ( p-current-string-value     = "-":U
            and p-current-logical-value = yes )
        then do:
            assign
                p-new-string-value = "?":U
            .
        end.
        else do:
            assign
                p-new-string-value = p-current-string-value
            .
        end.
    end.
end.
END PROCEDURE. /* get-logical-string */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME