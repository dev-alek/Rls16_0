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

Выбор параметров для OpenXML.

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parparentproc as handle           no-undo.
define input  parameter p-cre-db-num  as integer   no-undo .
define input  parameter p-task-type   as character no-undo .
define input  parameter p-task-num    as integer   no-undo .
define output parameter p-cancel      as logical      no-undo.
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор параметров для экспорта по расписанию.".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ ref/shd-attr.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }

define variable v-obj-list              as character    no-undo.
define variable v-host-name             as character    no-undo.
define variable v-today                 as date         no-undo.
define variable v-time                  as integer      no-undo.
define variable v-init-doc-type-list    as character    no-undo.
define variable v-doc-type-list         as character    no-undo.
define variable v-param-type            as character     no-undo.

define temp-table temp_obj-list no-undo
    field obj-type as character
    field obj-code as integer
    index pi is primary unique obj-type obj-code
.
define temp-table temp_db-num no-undo
    field db-num-key    as integer

    index pi is primary unique
        db-num-key
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rct-dates rct-obj rct-doc-type ~
rct-doc-options RECT-5 Btn_OK Btn_Cancel tb-incr b-help tb-exp-doc ~
tb-exp-ref tb-exp-fo tb-exp-day tb-exp-checks tb-exp-ref-ext tb-exp-fp ~
tb-exp-way tb-exp-stk tb-exp-stk-supp fi-days-amount rs-date fi-days-ago ~
fi-date-from fi-date-to rs-1 bt-sel-obj ed-doc-type bt-sel-doc-type ~
tb-inkass-pay-code tb-cst-code tb-chk-pay-code tb-parts tb-pay-desk ~
tb-not-fact-docs tb-pay-desk-cards
&Scoped-Define DISPLAYED-OBJECTS tb-incr tb-exp-doc tb-exp-ref tb-exp-fo ~
tb-exp-day tb-exp-checks tb-exp-ref-ext tb-exp-fp tb-exp-way tb-exp-stk ~
tb-exp-stk-supp fi-days-amount rs-date fi-days-ago fi-date-from fi-date-to ~
rs-1 ed-object ed-doc-type ed-doc-type-title tb-inkass-pay-code tb-cst-code ~
tb-chk-pay-code tb-parts tb-pay-desk tb-not-fact-docs tb-pay-desk-cards ~
fi-dates-title fi-doc-options

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.

DEFINE BUTTON bt-sel-doc-type
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.63 BY 1.04.

DEFINE BUTTON bt-sel-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.63 BY 1.04.

DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK DEFAULT
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE ed-doc-type AS CHARACTER INITIAL "Все"
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-VERTICAL NO-BOX
     SIZE 40.75 BY 1.83 NO-UNDO.

DEFINE VARIABLE ed-doc-type-title AS CHARACTER INITIAL "Типы документов"
     VIEW-AS EDITOR NO-BOX
     SIZE 13.13 BY 1.71 NO-UNDO.

DEFINE VARIABLE ed-object AS CHARACTER
     VIEW-AS EDITOR NO-BOX
     SIZE 40.75 BY 3.38
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE fi-date-from AS DATE FORMAT "99/99/9999":U
     LABEL "Дата с"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE fi-date-to AS DATE FORMAT "99/99/9999":U
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE fi-dates-title AS CHARACTER FORMAT "X(256)":U INITIAL " Выбор диапазона дат"
      VIEW-AS TEXT
     SIZE 21.63 BY .67 NO-UNDO.

DEFINE VARIABLE fi-days-ago AS INTEGER FORMAT ">>>9":U INITIAL 0
     LABEL "Дней назад"
     VIEW-AS FILL-IN
     SIZE 5.38 BY 1 NO-UNDO.

DEFINE VARIABLE fi-days-amount AS INTEGER FORMAT ">>>9":U INITIAL 0
     LABEL "Количество дней"
     VIEW-AS FILL-IN
     SIZE 5.38 BY 1 NO-UNDO.

DEFINE VARIABLE fi-doc-options AS CHARACTER FORMAT "X(256)":U INITIAL " Выгружать документы:"
      VIEW-AS TEXT
     SIZE 22.63 BY .67 NO-UNDO.

DEFINE VARIABLE rs-1 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "глобально", 1,
"по фирме", 2,
"по объектам", 3
     SIZE 13.75 BY 3.25 NO-UNDO.

DEFINE VARIABLE rs-date AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "за прошлые дни", 0,
"по текущую", 1,
"интервал", 2
     SIZE 19.38 BY 3.25 NO-UNDO.

DEFINE RECTANGLE rct-dates
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 79 BY 4.46.

DEFINE RECTANGLE rct-doc-options
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 79 BY 4.

DEFINE RECTANGLE rct-doc-type
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 79 BY 2.17.

DEFINE RECTANGLE rct-obj
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 79 BY 4.25.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 78.75 BY 4.

DEFINE VARIABLE tb-chk-pay-code AS LOGICAL INITIAL no
     LABEL "По типу кассового платежа"
     VIEW-AS TOGGLE-BOX
     SIZE 27.5 BY .83 NO-UNDO.

DEFINE VARIABLE tb-cst-code AS LOGICAL INITIAL no
     LABEL "ГТД по строкам документов"
     VIEW-AS TOGGLE-BOX
     SIZE 28.38 BY .83 NO-UNDO.

DEFINE VARIABLE tb-exp-checks AS LOGICAL INITIAL no
     LABEL "Чеки"
     VIEW-AS TOGGLE-BOX
     SIZE 22 BY .83 NO-UNDO.

DEFINE VARIABLE tb-exp-day AS LOGICAL INITIAL no
     LABEL "Товары по дням"
     VIEW-AS TOGGLE-BOX
     SIZE 18.88 BY .83 NO-UNDO.

DEFINE VARIABLE tb-exp-doc AS LOGICAL INITIAL no
     LABEL "Документы"
     VIEW-AS TOGGLE-BOX
     SIZE 16.25 BY .83 NO-UNDO.

DEFINE VARIABLE tb-exp-fo AS LOGICAL INITIAL no
     LABEL "Фин.обязательства"
     VIEW-AS TOGGLE-BOX
     SIZE 20.25 BY .83 NO-UNDO.

DEFINE VARIABLE tb-exp-fp AS LOGICAL INITIAL no
     LABEL "Фин.платежи"
     VIEW-AS TOGGLE-BOX
     SIZE 20.25 BY .83 NO-UNDO.

DEFINE VARIABLE tb-exp-ref AS LOGICAL INITIAL no
     LABEL "Справочники"
     VIEW-AS TOGGLE-BOX
     SIZE 16.25 BY .83 NO-UNDO.

DEFINE VARIABLE tb-exp-ref-ext AS LOGICAL INITIAL no
     LABEL "Расширенный экспорт"
     VIEW-AS TOGGLE-BOX
     SIZE 24.38 BY .83 NO-UNDO.

DEFINE VARIABLE tb-exp-stk AS LOGICAL INITIAL no
     LABEL "Товарные остатки"
     VIEW-AS TOGGLE-BOX
     SIZE 22.13 BY .83 NO-UNDO.

DEFINE VARIABLE tb-exp-stk-supp AS LOGICAL INITIAL no
     LABEL "По поставщикам"
     VIEW-AS TOGGLE-BOX
     SIZE 20.25 BY .83 NO-UNDO.

DEFINE VARIABLE tb-exp-way AS LOGICAL INITIAL no
     LABEL "Товары в пути"
     VIEW-AS TOGGLE-BOX
     SIZE 21.5 BY .83 NO-UNDO.

DEFINE VARIABLE tb-incr AS LOGICAL INITIAL no
     LABEL "Инкрементальная выгрузка"
     VIEW-AS TOGGLE-BOX
     SIZE 27.63 BY .83 NO-UNDO.

DEFINE VARIABLE tb-inkass-pay-code AS LOGICAL INITIAL no
     LABEL "По виду оплаты"
     VIEW-AS TOGGLE-BOX
     SIZE 24.38 BY .83 NO-UNDO.

DEFINE VARIABLE tb-not-fact-docs AS LOGICAL INITIAL no
     LABEL "Не закрытые документы"
     VIEW-AS TOGGLE-BOX
     SIZE 26 BY .83 NO-UNDO.

DEFINE VARIABLE tb-parts AS LOGICAL INITIAL no
     LABEL "По партиям"
     VIEW-AS TOGGLE-BOX
     SIZE 26.13 BY .83 NO-UNDO.

DEFINE VARIABLE tb-pay-desk AS LOGICAL INITIAL no
     LABEL "По кассе"
     VIEW-AS TOGGLE-BOX
     SIZE 13 BY .83 NO-UNDO.

DEFINE VARIABLE tb-pay-desk-cards AS LOGICAL INITIAL no
     LABEL "По префиксам карт"
     VIEW-AS TOGGLE-BOX
     SIZE 24.38 BY .83 NO-UNDO.

DEFINE VARIABLE tb-supp AS LOGICAL INITIAL no
     LABEL "Остатки по поставщикам"
     VIEW-AS TOGGLE-BOX
     SIZE 26.88 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.25 COL 1.5
     Btn_Cancel AT ROW 1.25 COL 11.5
     tb-incr AT ROW 1.25 COL 23
     b-help AT ROW 1.25 COL 71
     tb-exp-doc AT ROW 3.5 COL 3.75
     tb-exp-ref AT ROW 3.5 COL 30.25
     tb-exp-fo AT ROW 3.5 COL 59.75
     tb-exp-day AT ROW 4.29 COL 3.75
     tb-exp-checks AT ROW 4.29 COL 6.75
     tb-exp-ref-ext AT ROW 4.29 COL 33.25
     tb-exp-fp AT ROW 4.5 COL 59.75
     tb-exp-way AT ROW 5.08 COL 3.75
     tb-exp-stk AT ROW 5.08 COL 30.25
     tb-exp-stk-supp AT ROW 5.92 COL 33.25
     fi-days-amount AT ROW 7.83 COL 41.75 COLON-ALIGNED
     rs-date AT ROW 8.17 COL 3.5 NO-LABEL
     fi-days-ago AT ROW 9.04 COL 41.75 COLON-ALIGNED
     fi-date-from AT ROW 10.29 COL 30.63 COLON-ALIGNED
     fi-date-to AT ROW 10.33 COL 47.38 COLON-ALIGNED
     tb-supp AT ROW 11.33 COL 27.88
     rs-1 AT ROW 12.5 COL 3.5 NO-LABEL
     ed-object AT ROW 12.5 COL 20.88 NO-LABEL
     bt-sel-obj AT ROW 14.79 COL 17.38
     ed-doc-type AT ROW 16.71 COL 16.88 NO-LABEL
     ed-doc-type-title AT ROW 16.79 COL 3 NO-LABEL
     bt-sel-doc-type AT ROW 17.38 COL 58.13
     tb-inkass-pay-code AT ROW 19.58 COL 3.13
     tb-cst-code AT ROW 19.58 COL 33.13
     tb-chk-pay-code AT ROW 20.42 COL 3.13
     tb-parts AT ROW 20.42 COL 33.13
     tb-pay-desk AT ROW 21.21 COL 6.13
     tb-not-fact-docs AT ROW 21.21 COL 33.13
     tb-pay-desk-cards AT ROW 22 COL 6.13
     fi-dates-title AT ROW 7.08 COL 1 COLON-ALIGNED NO-LABEL
     fi-doc-options AT ROW 18.79 COL 1 COLON-ALIGNED NO-LABEL
     " Список выгрузки:" VIEW-AS TEXT
          SIZE 18.88 BY .79 AT ROW 2.63 COL 4
     rct-dates AT ROW 7.29 COL 2
     rct-obj AT ROW 12 COL 2
     rct-doc-type AT ROW 16.5 COL 2
     rct-doc-options AT ROW 19 COL 2
     RECT-5 AT ROW 3 COL 2.25
     SPACE(0.37) SKIP(16.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры экспорта по расписанию"
         CANCEL-BUTTON Btn_Cancel.


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
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       ed-doc-type:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR EDITOR ed-doc-type-title IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR EDITOR ed-object IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-dates-title IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-doc-options IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX tb-supp IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       tb-supp:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Параметры экспорта по расписанию */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-doc-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-doc-type Dialog-Frame
ON CHOOSE OF bt-sel-doc-type IN FRAME Dialog-Frame /* ... */
DO:

    define variable v-cancel     as logical           no-undo.
    define variable v-oper-num   as integer           no-undo.
    define variable v-doc-type-select as character no-undo .
    assign
    v-doc-type-select = (if input frame {&frame-name} tb-exp-doc then "trn-doc":U else "":U)
    v-doc-type-select = (if input frame {&frame-name} tb-exp-fp
                        then (v-doc-type-select + (if v-doc-type-select = "":U then "":U else {&comma-char}) + "fin-doc":U)
                        else v-doc-type-select)
    .
    run bge/bgeseltp.w (
          input v-doc-type-select
        , input v-init-doc-type-list
        , output v-doc-type-list
        , output v-cancel
    ) no-error.
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка выбора типов операций."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if v-cancel = yes
    then do:
        assign
            v-doc-type-list = v-init-doc-type-list
        .
    end.
    else do:
        assign
            v-init-doc-type-list    = v-doc-type-list
        .
        if v-doc-type-list = ''
        then do:
            assign
                ed-doc-type :screen-value in frame Dialog-Frame = "Все"
            .
        end.
        else do:
            assign
                ed-doc-type :screen-value in frame Dialog-Frame = ''
            .
            do v-oper-num = 1 to num-entries( {&TDEDT_List} )
            :
                if lookup( entry( v-oper-num, {&TDEDT_List} ), v-init-doc-type-list ) <> 0
                then do:
                    assign
                        ed-doc-type :screen-value in frame Dialog-Frame = ed-doc-type :screen-value in frame Dialog-Frame
                                                    + entry( v-oper-num, {&TDEDT_List-full} ) + {&new-line}
                    .
                end.
            end.
            do v-oper-num = 1 to num-entries( {&fin-ext-doc-types} )
            :
                if lookup( entry( v-oper-num, {&fin-ext-doc-types} ), v-init-doc-type-list ) <> 0
                then do:
                    assign
                        ed-doc-type :screen-value in frame Dialog-Frame = ed-doc-type :screen-value in frame Dialog-Frame
                                                    + entry( v-oper-num, {&fin-ext-doc-types-full} ) + {&new-line}
                    .
                end.
            end.
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-obj Dialog-Frame
ON CHOOSE OF bt-sel-obj IN FRAME Dialog-Frame /* ... */
DO:
    define variable v-obj-list           as character no-undo .
    define variable v-exclude-obj-list   as character no-undo .

    define variable v-object-available as logical   no-undo .

    assign
        rs-1 :screen-value  = "3"
    .
    { gbl/uobjclr.i  }

    { gbl/usobjava.i
      v-cntxt-db-num
      {&action-head-code-main}
      v-cntxt-userid
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-object-available
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры gbl/usobjava.i" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return no-apply .
    end.

    if v-object-available = true
    then do:
      { gbl/uobjapnd.i
        v-cntxt-obj-type
        v-cntxt-obj-code
      }
    end.
    define variable v-user-select as logical   no-undo .
    { gbl/uobjsman.i
      parparentproc
      v-cntxt-db-num
      v-cntxt-userid
      v-cntxt-host-code-obj
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-user-select
    }
    if v-user-select <> true
    then do:
      message
        "Объект не выбран"
        view-as alert-box information .
      return no-apply .
    end.

    define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .

    for each buf_userobjs_temp-user-obj
    on error undo, return no-apply
    :
      create temp_obj-list .
      assign
        temp_obj-list.obj-type = buf_userobjs_temp-user-obj.obj-type
        temp_obj-list.obj-code = buf_userobjs_temp-user-obj.obj-code
      .
    end.


    run select-objects-only-this-db in this-procedure
      (output v-obj-list
      ,output v-exclude-obj-list
      ).
    if v-exclude-obj-list <> ""
    then do:
        message
            "Из списка выбранных объектов исключены"
            skip "объекты, не принадлежащие БД, указанной в расписании:"
            skip(1)
            skip v-exclude-obj-list
        view-as alert-box information.
    end.
    assign
        ed-object :screen-value = v-obj-list
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_Cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_Cancel Dialog-Frame
ON CHOOSE OF Btn_Cancel IN FRAME Dialog-Frame /* Отмена */
DO:
    assign
        p-cancel = yes
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Ввод */
DO:
    define variable v-obj-list as character     no-undo.
    ASSIGN
        rs-date
        fi-days-amount
        fi-days-ago
        fi-date-from
        fi-date-to
        rs-1
        tb-supp
        tb-inkass-pay-code
        tb-cst-code
        tb-parts
        tb-chk-pay-code
        tb-pay-desk
        tb-pay-desk-cards
        tb-not-fact-docs
        tb-exp-doc
        tb-exp-ref
        tb-exp-day
        tb-exp-way
        tb-exp-ref-ext
        tb-exp-stk
        tb-exp-stk-supp
        tb-incr
        tb-exp-checks
        tb-exp-fo
        tb-exp-fp
    .
    if tb-exp-doc  = no
    and tb-exp-ref = no
    and tb-exp-fo = no
    and tb-exp-fp = no
    and ( ( tb-exp-day = no
            and tb-exp-way = no
            and tb-exp-stk = no )
       or ( tb-incr = yes ) )
    then do:
        message
            skip "Выберите по крайней мере один тип выгрузки"
            skip "или отмените ввод параметров выгрузки."
        view-as alert-box warning
        buttons ok
        title "Не выбран тип выгрузки".
        undo, return no-apply.
    end.
    case rs-1
    :
    when 1
    then do:
        assign
            v-obj-list = ""
        .
    end.
    when 2
    then do:
        assign
            v-obj-list = ""
        .
    end.
    when 3
    then do:
        assign
            v-obj-list = ""
        .
        for each temp_obj-list
        :
            assign
                v-obj-list = v-obj-list
                        + ( if v-obj-list = "" then "" else "," ) + temp_obj-list.obj-type
                        + "," + string( temp_obj-list.obj-code )
            .
        end.
    end.
    end case.
    find first temp_obj-list no-error.
    if not available temp_obj-list
    and rs-1 = 3
    then do:
        message
            "Не выбраны объекты для выгрузки."
        view-as alert-box warning.
        undo, return no-apply.
    end.
    run attach-attr-to-schedule-line in this-procedure (
          input rs-date
        , input fi-days-amount
        , input fi-days-ago
        , input fi-date-from
        , input fi-date-to
        , input rs-1
        , input v-obj-list
        , input v-doc-type-list
        , input tb-supp
        , input tb-inkass-pay-code
        , input tb-cst-code
        , input tb-parts
        , input tb-chk-pay-code
        , input tb-pay-desk
        , input tb-pay-desk-cards
        , input tb-not-fact-docs
        , input tb-exp-doc
        , input tb-exp-ref
        , input tb-exp-day
        , input tb-exp-way
        , input tb-exp-ref-ext
        , input tb-exp-stk
        , input tb-exp-stk-supp
        , input tb-incr
        , input tb-exp-checks
        , input tb-exp-fo
        , input tb-exp-fp
    ).
    APPLY "GO" TO FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-date-from
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-date-from Dialog-Frame
ON RETURN OF fi-date-from IN FRAME Dialog-Frame /* Дата с */
DO:
    APPLY "ENTRY" TO fi-date-to IN FRAME {&FRAME-NAME}.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-date-to
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-date-to Dialog-Frame
ON RETURN OF fi-date-to IN FRAME Dialog-Frame /* по */
DO:
    APPLY "ENTRY" TO btn_OK IN FRAME {&FRAME-NAME}.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-1 Dialog-Frame
ON VALUE-CHANGED OF rs-1 IN FRAME Dialog-Frame
DO:
    assign
        rs-1
    .
    run object-select in this-procedure (
        input rs-1
    ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-date Dialog-Frame
ON VALUE-CHANGED OF rs-date IN FRAME Dialog-Frame
DO:
assign
    rs-date
.
run date-select in this-procedure (
    input rs-date
) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tb-chk-pay-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tb-chk-pay-code Dialog-Frame
ON VALUE-CHANGED OF tb-chk-pay-code IN FRAME Dialog-Frame /* По типу кассового платежа */
DO:
    assign
        tb-chk-pay-code
    .
    run manage-tb-chk-pay-code in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tb-exp-checks
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tb-exp-checks Dialog-Frame
ON VALUE-CHANGED OF tb-exp-checks IN FRAME Dialog-Frame /* Чеки */
DO:
    assign
        tb-exp-day
    .
    run manage-options in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tb-exp-day
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tb-exp-day Dialog-Frame
ON VALUE-CHANGED OF tb-exp-day IN FRAME Dialog-Frame /* Товары по дням */
DO:
    assign
        tb-exp-day
    .
    run manage-options in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tb-exp-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tb-exp-doc Dialog-Frame
ON VALUE-CHANGED OF tb-exp-doc IN FRAME Dialog-Frame /* Документы */
DO:
    assign
        tb-exp-doc
    .
    run manage-options in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tb-exp-fo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tb-exp-fo Dialog-Frame
ON VALUE-CHANGED OF tb-exp-fo IN FRAME Dialog-Frame /* Фин.обязательства */
DO:
    assign
        tb-exp-fo
    .
    run manage-options in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tb-exp-fp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tb-exp-fp Dialog-Frame
ON VALUE-CHANGED OF tb-exp-fp IN FRAME Dialog-Frame /* Фин.платежи */
DO:
    assign
        tb-exp-fp
    .
    run manage-options in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tb-exp-ref
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tb-exp-ref Dialog-Frame
ON VALUE-CHANGED OF tb-exp-ref IN FRAME Dialog-Frame /* Справочники */
DO:
    assign
        tb-exp-ref
    .
    run manage-tb-exp-ref in this-procedure.
    run manage-options in this-procedure.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tb-exp-stk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tb-exp-stk Dialog-Frame
ON VALUE-CHANGED OF tb-exp-stk IN FRAME Dialog-Frame /* Товарные остатки */
DO:
    assign
        tb-exp-stk
    .
    run manage-tb-exp-stk in this-procedure.
    run manage-options in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tb-exp-way
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tb-exp-way Dialog-Frame
ON VALUE-CHANGED OF tb-exp-way IN FRAME Dialog-Frame /* Товары в пути */
DO:
    assign
        tb-exp-way
    .
    run manage-options in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tb-incr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tb-incr Dialog-Frame
ON VALUE-CHANGED OF tb-incr IN FRAME Dialog-Frame /* Инкрементальная выгрузка */
DO:
    assign
        tb-incr
    .
    run manage-options in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/ed_date.i fi-date-from }
{ gbl/ed_date.i fi-date-to   }

run cur-time in this-procedure ( output v-today
                               , output v-time
                               ).

{ gbl/app_help.i }
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

    define buffer buf_schedule      for ub.schedule.

    assign
        frame {&frame-name} :title = frame {&frame-name} :title
                    + ". " + p-task-type + ": Задача номер " + string( p-task-num )
    .
    { gbl/getcntxt.i get }
    run get-host-name in this-procedure ( output v-host-name ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка при определении имени фирмы"
          skip "Код фирмы:" v-cntxt-host-code-obj
          skip "Имя фирмы будет отображаться как '" + {&cmp} + string( v-cntxt-host-code-obj ) + "'"
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box warning.
        assign
            v-host-name = {&cmp} + string( v-cntxt-host-code-obj )
        .
    end.
    run init-param-values in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , output fi-days-amount
        , output rs-date
        , output fi-days-ago
        , output fi-date-from
        , output fi-date-to
        , output tb-supp
        , output v-obj-list
        , output rs-1
        , output v-init-doc-type-list
        , output tb-inkass-pay-code
        , output tb-cst-code
        , output tb-parts
        , output tb-chk-pay-code
        , output tb-pay-desk
        , output tb-pay-desk-cards
        , output tb-not-fact-docs
        , output tb-exp-doc
        , output tb-exp-ref
        , output tb-exp-day
        , output tb-exp-way
        , output tb-exp-ref-ext
        , output tb-exp-stk
        , output tb-exp-stk-supp
        , output tb-incr
        , output tb-exp-checks
        , output tb-exp-fo
        , output tb-exp-fp
    ).

    find first buf_schedule no-lock
         where buf_schedule.cre-db-num = p-cre-db-num
           and buf_schedule.task-type  = p-task-type
           and buf_schedule.task-num   = p-task-num
    no-error.
    if not available buf_schedule
    and (  p-task-type   <> {&btpr-type-autoexp}
        or p-task-num    <> -1 )
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Не найдена строка расписания."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    run enable_UI.
    if available buf_schedule
    and buf_schedule.db-num-char <> "*"
    then do:
        rs-1 :disable("глобально").
        rs-1 :disable("по фирме").
    end.
    run date-select in this-procedure (
        input rs-date
    ).
    run object-select in this-procedure (
        input rs-1
    ).
    run init-fields in this-procedure .
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE attach-attr-to-schedule-line Dialog-Frame
PROCEDURE attach-attr-to-schedule-line :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    define input parameter p-rs-date            as integer      no-undo.
    define input parameter p-days-amount        as integer      no-undo.
    define input parameter p-days-ago           as integer      no-undo.
    define input parameter p-date-from          as date         no-undo.
    define input parameter p-date-to            as date         no-undo.
    define input parameter p-rs-1               as integer      no-undo.
    define input parameter p-object-list        as character    no-undo.
    define input parameter p-doc-type-list      as character    no-undo.
    define input parameter p-tb-supp            as logical      no-undo.
    define input parameter p-tb-inkass-pay-code as logical      no-undo.
    define input parameter p-tb-cst-code        as logical      no-undo.
    define input parameter p-tb-parts           as logical      no-undo.
    define input parameter p-tb-chk-pay-code    as logical      no-undo.
    define input parameter p-tb-pay-desk        as logical      no-undo.
    define input parameter p-tb-pay-desk-cards  as logical      no-undo.
    define input parameter p-tb-not-fact-docs   as logical      no-undo.
    define input parameter p-tb-exp-doc         as logical      no-undo.
    define input parameter p-tb-exp-ref         as logical      no-undo.
    define input parameter p-tb-exp-day         as logical      no-undo.
    define input parameter p-tb-exp-way         as logical      no-undo.
    define input parameter p-tb-exp-ref-ext     as logical      no-undo.
    define input parameter p-tb-exp-stk         as logical      no-undo.
    define input parameter p-tb-exp-stk-supp    as logical      no-undo.
    define input parameter p-tb-incr            as logical      no-undo.
    define input parameter p-tb-exp-checks      as logical      no-undo.
    define input parameter p-tb-exp-fo          as logical      no-undo.
    define input parameter p-tb-exp-fp          as logical      no-undo.


    define variable v-attr-value as character     no-undo.

    define buffer buf_schedule      for ub.schedule.
    define buffer buf_schedule-attr for ub.schedule-attr.

    find first buf_schedule no-lock
         where buf_schedule.cre-db-num = p-cre-db-num
           and buf_schedule.task-type  = p-task-type
           and buf_schedule.task-num   = p-task-num
    no-error.
    if not available buf_schedule
    and (  p-task-type   <> {&btpr-type-autoexp}
        or p-task-num    <> -1 )
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Не найдена строка расписания."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    assign
        v-attr-value = string( p-rs-1 )
                        + "," + ( if p-tb-inkass-pay-code = yes then "yes" else "no" )
                        + "," + ( if p-tb-cst-code        = yes then "yes" else "no" )
                        + "," + ( if p-tb-not-fact-docs   = yes then "yes" else "no" )
                        + "," + ( if p-tb-supp            = yes then "yes" else "no" )
                        + "," + ( if p-tb-parts           = yes then "yes" else "no" )
                        + "," + ( if p-tb-chk-pay-code    = yes then "yes" else "no" )
                        + "," + ( if p-tb-exp-doc         = yes then "yes" else "no" )
                        + "," + ( if p-tb-exp-ref         = yes then "yes" else "no" )
                        + "," + ( if p-tb-exp-day         = yes then "yes" else "no" )
                        + "," + ( if p-tb-exp-way         = yes then "yes" else "no" )
                        + "," + ( if p-tb-exp-ref-ext     = yes then "yes" else "no" )
                        + "," + ( if p-tb-exp-stk         = yes then "yes" else "no" )
                        + "," + ( if p-tb-exp-stk-supp    = yes then "yes" else "no" )
                        + "," + string( v-cntxt-host-code-obj )
                        + "," + ( if tb-pay-desk          = yes then "yes" else "no" )
                        + "," + ( if tb-incr              = yes then "yes" else "no" )
                        + "," + ( if tb-exp-checks        = yes then "yes" else "no" )
                        + "," + ( if tb-exp-fo            = yes then "yes" else "no" )
                        + "," + ( if tb-exp-fp            = yes then "yes" else "no" )
                        + "," + ( if tb-pay-desk-cards    = yes then "yes" else "no" )
    .
    run schedule-attr-write in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input {&attr-schedule-param-list-h}
        , input v-attr-value
    ).
    run schedule-attr-write in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input {&attr-schedule-obj-list-h}
        , input p-object-list
    ).
    run schedule-attr-write in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input {&attr-schedule-doc-type-list-h}
        , input p-doc-type-list
    ).
    assign
        v-attr-value = string( p-rs-date )
                        + "," + string( p-days-amount )
                        + "," + string( p-days-ago    )
                        + "," + string( p-date-from   )
                        + "," + string( p-date-to     )
    .
    run schedule-attr-write in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input {&attr-schedule-date-list-h}
        , input v-attr-value
    ).
    for each buf_schedule-attr
    on error undo, return error
    :
        if buf_schedule-attr.task-type  <> {&btpr-type-autoexp}
        or buf_schedule-attr.cre-db-num <> p-cre-db-num
        or buf_schedule-attr.task-num   <> -1
        or (
                buf_schedule-attr.attr-code <> {&attr-schedule-date-list-h}
            and buf_schedule-attr.attr-code <> {&attr-schedule-param-list-h}
            and buf_schedule-attr.attr-code <> {&attr-schedule-obj-list-h}
            and buf_schedule-attr.attr-code <> {&attr-schedule-doc-type-list-h}
        )
        then do:
            find first buf_schedule
                 where buf_schedule.cre-db-num = buf_schedule-attr.cre-db-num
                   and buf_schedule.task-type  = buf_schedule-attr.task-type
                   and buf_schedule.task-num   = buf_schedule-attr.task-num
            no-error.
            if not available buf_schedule
            then do:
                delete buf_schedule-attr.
            end.
        end.
    end.        /* for each buf_schedule-attr */
end.
END PROCEDURE. /* attach-attr-to-schedule-line */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE date-select Dialog-Frame
PROCEDURE date-select :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-date-select-value as integer      no-undo.
    case p-date-select-value
    :
        when 0
        then do:
            hide
                fi-date-from in frame {&frame-name}
                fi-date-to
            .
            view
                fi-days-ago
                fi-days-amount
            .
        end.
        when 1
        then do:
            hide
                fi-date-to
                fi-days-ago
                fi-days-amount
            .
            view
                fi-date-from
            .
        end.
        when 2
        then do:
            hide
                fi-days-ago
                fi-days-amount
            .
            view
                fi-date-from
                fi-date-to
            .
        end.
    end case.
end.
END PROCEDURE. /* date-select */

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
  DISPLAY tb-incr tb-exp-doc tb-exp-ref tb-exp-fo tb-exp-day tb-exp-checks
          tb-exp-ref-ext tb-exp-fp tb-exp-way tb-exp-stk tb-exp-stk-supp
          fi-days-amount rs-date fi-days-ago fi-date-from fi-date-to rs-1
          ed-object ed-doc-type ed-doc-type-title tb-inkass-pay-code tb-cst-code
          tb-chk-pay-code tb-parts tb-pay-desk tb-not-fact-docs
          tb-pay-desk-cards fi-dates-title fi-doc-options
      WITH FRAME Dialog-Frame.
  ENABLE rct-dates rct-obj rct-doc-type rct-doc-options RECT-5 Btn_OK
         Btn_Cancel tb-incr b-help tb-exp-doc tb-exp-ref tb-exp-fo tb-exp-day
         tb-exp-checks tb-exp-ref-ext tb-exp-fp tb-exp-way tb-exp-stk
         tb-exp-stk-supp fi-days-amount rs-date fi-days-ago fi-date-from
         fi-date-to rs-1 bt-sel-obj ed-doc-type bt-sel-doc-type
         tb-inkass-pay-code tb-cst-code tb-chk-pay-code tb-parts tb-pay-desk
         tb-not-fact-docs tb-pay-desk-cards
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE extract-parameter Dialog-Frame
PROCEDURE extract-parameter :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:

end.
END PROCEDURE. /* extract-parameter */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-host-name Dialog-Frame
PROCEDURE get-host-name :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define output parameter p-host-name as character    no-undo.

define buffer buf_clients   for ub.clients.

    find first buf_clients no-lock
         where buf_clients.obj-type = {&cmp}
           and buf_clients.obj-code = v-cntxt-host-code-obj
    no-error.
    if not available buf_clients
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Не удалось найти текущую фирму"
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
    else do:
        assign
            p-host-name = buf_clients.obj-name
        .
    end.
end.
END PROCEDURE. /* get-host-name */

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
    define variable v-oper-num     as integer           no-undo.
    run manage-tb-exp-stk       in this-procedure.
    run manage-tb-exp-ref       in this-procedure.
    run manage-options          in this-procedure.
    run manage-tb-chk-pay-code  in this-procedure.
    assign
        v-doc-type-list = v-init-doc-type-list
    .
/*    assign*/
/*        rs-1 :screen-value in frame dialog-frame = "2"*/
/*        ed-object :screen-value in frame Dialog-frame = {&cmp} + string( v-cntxt-host-code-obj ) + " " + v-host-name*/
/*    .*/
/*    assign*/
/*        rs-1*/
/*    .*/
    if v-init-doc-type-list <> ?
    and v-init-doc-type-list <> ''
    then do:
        assign
            ed-doc-type :screen-value in frame Dialog-Frame = ""
        .
        do v-oper-num = 1 to num-entries( {&TDEDT_List} )
        :
            if lookup( entry( v-oper-num, {&TDEDT_List} ), v-init-doc-type-list ) <> 0
            then do:
                assign
                    ed-doc-type :screen-value in frame Dialog-Frame = ed-doc-type :screen-value in frame Dialog-Frame
                                                + entry( v-oper-num, {&TDEDT_List-full} ) + {&new-line}
                .
            end.
        end.
        do v-oper-num = 1 to num-entries( {&fin-ext-doc-types} )
        :
            if lookup( entry( v-oper-num, {&fin-ext-doc-types} ), v-init-doc-type-list ) <> 0
            then do:
                assign
                    ed-doc-type :screen-value in frame Dialog-Frame = ed-doc-type :screen-value in frame Dialog-Frame
                                                + entry( v-oper-num, {&fin-ext-doc-types-full} ) + {&new-line}
                .
            end.
        end.
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-param-values Dialog-Frame
PROCEDURE init-param-values :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input  parameter p-cre-db-num            as integer   no-undo .
define input  parameter p-task-type             as character no-undo .
define input  parameter p-task-num              as integer   no-undo .
define output parameter p-days-amount           as integer      no-undo.
define output parameter p-rs-date               as integer      no-undo.
define output parameter p-days-ago              as integer      no-undo.
define output parameter p-date-from             as date         no-undo.
define output parameter p-date-to               as date         no-undo.
define output parameter p-tb-supp               as logical      no-undo.
define output parameter p-obj-list              as character    no-undo.
define output parameter p-rs-1                  as integer      no-undo.
define output parameter p-doc-type-list         as character    no-undo.
define output parameter p-tb-inkass-pay-code    as logical      no-undo.
define output parameter p-tb-cst-code           as logical      no-undo.
define output parameter p-tb-parts              as logical      no-undo.
define output parameter p-tb-chk-pay-code       as logical      no-undo.
define output parameter p-tb-pay-desk           as logical      no-undo.
define output parameter p-tb-pay-desk-cards     as logical      no-undo.
define output parameter p-tb-not-fact-docs      as logical      no-undo.
define output parameter p-tb-exp-doc            as logical      no-undo.
define output parameter p-tb-exp-ref            as logical      no-undo.
define output parameter p-tb-exp-day            as logical      no-undo.
define output parameter p-tb-exp-way            as logical      no-undo.
define output parameter p-tb-exp-ref-ext        as logical      no-undo.
define output parameter p-tb-exp-stk            as logical      no-undo.
define output parameter p-tb-exp-stk-supp       as logical      no-undo.
define output parameter p-tb-incr               as logical      no-undo.
define output parameter p-tb-exp-checks         as logical      no-undo.
define output parameter p-tb-exp-fo             as logical      no-undo.
define output parameter p-tb-exp-fp             as logical      no-undo.

    define variable v-counter       as integer       no-undo.
    define variable v-param-list    as character     no-undo.

    run schedule-attr-value in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input {&attr-schedule-doc-type-list-h}
        , output p-doc-type-list
        , output v-param-type
    ) .
    run schedule-attr-value in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input {&attr-schedule-obj-list-h}
        , output p-obj-list
        , output v-param-type
    ) .
    for each temp_obj-list
    :
        delete temp_obj-list.
    end.
    do v-counter = 1 to num-entries( p-obj-list ) / 2
    :
        create temp_obj-list.
        assign
            temp_obj-list.obj-type = entry( 2 * v-counter - 1,  p-obj-list )
            temp_obj-list.obj-code = integer( entry( 2 * v-counter,      p-obj-list ) )
        .
    end.
    run schedule-attr-value in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input {&attr-schedule-param-list-h}
        , output v-param-list
        , output v-param-type
    ) .
    if v-param-list = ""
    then do:
        assign
            p-rs-1                  = 0
            p-tb-inkass-pay-code    = no
            p-tb-cst-code           = no
            p-tb-not-fact-docs      = no
            p-tb-supp               = no
            p-tb-parts              = no
            p-tb-chk-pay-code       = no
            p-tb-pay-desk           = no
            p-tb-pay-desk-cards     = no
            p-tb-exp-doc            = no
            p-tb-exp-ref            = no
            p-tb-exp-day            = no
            p-tb-exp-way            = no
            p-tb-exp-ref-ext        = no
            p-tb-exp-stk            = no
            p-tb-exp-stk-supp       = no
            p-tb-incr               = no
            p-tb-exp-checks         = no
            p-tb-exp-fo             = no
            p-tb-exp-fp             = no
        .
    end.
    else do:
        assign
            p-rs-1 = integer( entry( 1, v-param-list ) )
        .
        run schedule-attr-extract-logical in this-procedure (
              input 2
            , input v-param-list
            , output p-tb-inkass-pay-code
        ).
        run schedule-attr-extract-logical in this-procedure (
              input 3
            , input v-param-list
            , output p-tb-cst-code
        ).
        run schedule-attr-extract-logical in this-procedure (
              input 4
            , input v-param-list
            , output p-tb-not-fact-docs
        ).
        run schedule-attr-extract-logical in this-procedure (
              input 5
            , input v-param-list
            , output p-tb-supp
        ).
        run schedule-attr-extract-logical in this-procedure (
              input 6
            , input v-param-list
            , output p-tb-parts
        ).
        run schedule-attr-extract-logical in this-procedure (
              input 7
            , input v-param-list
            , output p-tb-chk-pay-code
        ).
        run schedule-attr-extract-logical in this-procedure (
              input 8
            , input v-param-list
            , output p-tb-exp-doc
        ).
        run schedule-attr-extract-logical in this-procedure (
              input 9
            , input v-param-list
            , output p-tb-exp-ref
        ).
        run schedule-attr-extract-logical in this-procedure (
              input 10
            , input v-param-list
            , output p-tb-exp-day
        ).
        run schedule-attr-extract-logical in this-procedure (
              input 11
            , input v-param-list
            , output p-tb-exp-way
        ).
        run schedule-attr-extract-logical in this-procedure (
              input 12
            , input v-param-list
            , output p-tb-exp-ref-ext
        ).
        run schedule-attr-extract-logical in this-procedure (
              input 13
            , input v-param-list
            , output p-tb-exp-stk
        ).
        run schedule-attr-extract-logical in this-procedure (
              input 14
            , input v-param-list
            , output p-tb-exp-stk-supp
        ).
        run schedule-attr-extract-logical in this-procedure (
              input 16
            , input v-param-list
            , output p-tb-pay-desk
        ).
        run schedule-attr-extract-logical in this-procedure (
              input 17
            , input v-param-list
            , output p-tb-incr
        ).
        run schedule-attr-extract-logical in this-procedure (
              input 18
            , input v-param-list
            , output p-tb-exp-checks
        ).
        run schedule-attr-extract-logical in this-procedure (
              input 19
            , input v-param-list
            , output p-tb-exp-fo
        ).
        run schedule-attr-extract-logical in this-procedure (
              input 20
            , input v-param-list
            , output p-tb-exp-fp
        ).
        run schedule-attr-extract-logical in this-procedure (
              input 21
            , input v-param-list
            , output p-tb-pay-desk-cards
        ).

    end.
    run schedule-attr-value in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input {&attr-schedule-date-list-h}
        , output v-param-list
        , output v-param-type
    ) .
    if v-param-list = ""
    then do:
        define variable v-today as date      no-undo.
        define variable v-time  as integer   no-undo.

        run cur-time in this-procedure ( output v-today
                                       , output v-time
                                       ).
        assign
            p-rs-date       = 0
            p-days-amount   = 1
            p-days-ago      = 0
            p-date-from     = v-today - 1
            p-date-to       = v-today - 1
        .
    end.
    else do:
        assign
            p-rs-date       = integer( entry( 1, v-param-list ) )
            p-days-amount   = integer( entry( 2, v-param-list ) )
            p-days-ago      = integer( entry( 3, v-param-list ) )
            p-date-from     = date( entry( 4, v-param-list ) )
            p-date-to       = date( entry( 5, v-param-list ) )
        .
    end.
end.
END PROCEDURE. /* init-param-values */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE manage-options Dialog-Frame
PROCEDURE manage-options :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    assign
        rct-doc-options     :visible in frame {&frame-name} = no
        fi-doc-options      :visible in frame {&frame-name} = no
        tb-inkass-pay-code  :visible in frame {&frame-name} = no
        tb-chk-pay-code     :visible in frame {&frame-name} = no
        tb-pay-desk         :visible in frame {&frame-name} = no
        tb-pay-desk-cards   :visible in frame {&frame-name} = no
        tb-cst-code         :visible in frame {&frame-name} = no
        tb-parts            :visible in frame {&frame-name} = no
        tb-not-fact-docs    :visible in frame {&frame-name} = no
        rct-doc-type        :visible in frame {&frame-name} = no
        ed-doc-type-title   :visible in frame {&frame-name} = no
        ed-doc-type         :visible in frame {&frame-name} = no
        bt-sel-doc-type     :visible in frame {&frame-name} = no
        rct-dates           :visible in frame {&frame-name} = no
        fi-dates-title      :visible in frame {&frame-name} = no
        rs-date             :visible in frame {&frame-name} = no
        fi-days-amount      :visible in frame {&frame-name} = no
        fi-days-ago         :visible in frame {&frame-name} = no
        fi-date-from        :visible in frame {&frame-name} = no
        fi-date-to          :visible in frame {&frame-name} = no
    .
    if tb-incr = yes
    then do:
        assign
            tb-exp-day          :visible in frame {&frame-name} = no
            tb-exp-way          :visible in frame {&frame-name} = no
            tb-exp-stk          :visible in frame {&frame-name} = no
            tb-exp-stk-supp     :visible in frame {&frame-name} = no
            tb-exp-ref-ext      :visible in frame {&frame-name} = no
            tb-exp-checks       :visible in frame {&frame-name} = yes
            rct-obj             :visible in frame {&frame-name} = yes
            rs-1                :visible in frame {&frame-name} = yes
            bt-sel-obj          :visible in frame {&frame-name} = yes
            ed-object           :visible in frame {&frame-name} = yes
        .
        run object-select in this-procedure (
            input rs-1
        ).
        if tb-exp-doc = yes
        then do:
            enable
                tb-exp-checks
            with frame {&frame-name} .
        end.        /* if tb-exp-doc = yes  */
        else do:
            disable
                tb-exp-checks
            with frame {&frame-name} .
        end.        /* NOT ( if tb-exp-doc = yes  ) */
    end.        /* if tb-incr = yes  */
    else do:
        assign
            tb-exp-day          :visible in frame {&frame-name} = yes
            tb-exp-way          :visible in frame {&frame-name} = yes
            tb-exp-stk          :visible in frame {&frame-name} = yes
            tb-exp-stk-supp     :visible in frame {&frame-name} = yes
            tb-exp-ref-ext      :visible in frame {&frame-name} = yes
            tb-exp-checks       :visible in frame {&frame-name} = no
            rct-obj             :visible in frame {&frame-name} = no
            rs-1                :visible in frame {&frame-name} = no
            bt-sel-obj          :visible in frame {&frame-name} = no
            ed-object           :visible in frame {&frame-name} = no
        .
        run object-select in this-procedure (
            input rs-1
        ).
        if tb-exp-doc = yes
        then do:
            assign
                rct-doc-options     :visible in frame {&frame-name} = yes
                fi-doc-options      :visible in frame {&frame-name} = yes
                tb-inkass-pay-code  :visible in frame {&frame-name} = yes
                tb-chk-pay-code     :visible in frame {&frame-name} = yes
                tb-pay-desk         :visible in frame {&frame-name} = yes
                tb-pay-desk-cards   :visible in frame {&frame-name} = yes
                tb-cst-code         :visible in frame {&frame-name} = yes
                tb-parts            :visible in frame {&frame-name} = yes
                tb-not-fact-docs    :visible in frame {&frame-name} = yes
            .
        end.
        if tb-exp-doc = yes
        or tb-exp-fp = yes
        or tb-exp-fo = yes
        then do:
            assign
                rct-doc-type        :visible in frame {&frame-name} = yes
                ed-doc-type-title   :visible in frame {&frame-name} = yes
                ed-doc-type         :visible in frame {&frame-name} = yes
                bt-sel-doc-type     :visible in frame {&frame-name} = yes
            .
        end.
        if tb-exp-doc = yes
        or tb-exp-ref = yes
        or tb-exp-day = yes
        or tb-exp-way = yes
        or tb-exp-stk = yes
        or tb-exp-fo = yes
        or tb-exp-fp = yes
        then do:
            assign
                rct-obj             :visible in frame {&frame-name} = yes
                rs-1                :visible in frame {&frame-name} = yes
                bt-sel-obj          :visible in frame {&frame-name} = yes
                ed-object           :visible in frame {&frame-name} = yes
            .
        end.
        if tb-exp-doc = yes
        or tb-exp-day = yes
        or tb-exp-stk = yes
        or tb-exp-ref = yes
        or tb-exp-fo = yes
        or tb-exp-fp = yes
        then do:
            assign
                rct-dates           :visible in frame {&frame-name} = yes
                fi-dates-title      :visible in frame {&frame-name} = yes
                rs-date             :visible in frame {&frame-name} = yes
                fi-days-amount      :visible in frame {&frame-name} = yes
                fi-days-ago         :visible in frame {&frame-name} = yes
                fi-date-from        :visible in frame {&frame-name} = yes
                fi-date-to          :visible in frame {&frame-name} = yes
            .
            run date-select in this-procedure (
                input rs-date
            ).
        end.
    end.        /* NOT ( if tb-incr = yes  ) */
end.
END PROCEDURE. /* manage-options */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE manage-tb-chk-pay-code Dialog-Frame
PROCEDURE manage-tb-chk-pay-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    if tb-chk-pay-code = yes
    then do:
        assign
            tb-pay-desk :sensitive in frame {&frame-name} = yes
            tb-pay-desk-cards :sensitive in frame {&frame-name} = yes
        .
    end.
    else do:
        assign
            tb-pay-desk :sensitive in frame {&frame-name} = no
            tb-pay-desk-cards :sensitive in frame {&frame-name} = no
        .
    end.
end.
END PROCEDURE. /* manage-tb-exp-ref */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE manage-tb-exp-ref Dialog-Frame
PROCEDURE manage-tb-exp-ref :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    if tb-exp-ref = yes
    then do:
        assign
            tb-exp-ref-ext :sensitive in frame {&frame-name} = yes
        .
    end.
    else do:
        assign
            tb-exp-ref-ext :sensitive in frame {&frame-name} = no
        .
    end.
end.
END PROCEDURE. /* manage-tb-exp-ref */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE manage-tb-exp-stk Dialog-Frame
PROCEDURE manage-tb-exp-stk :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    if tb-exp-stk = yes
    then do:
        assign
            tb-exp-stk-supp :sensitive in frame {&frame-name} = yes
        .
    end.
    else do:
        assign
            tb-exp-stk-supp :sensitive in frame {&frame-name} = no
        .
    end.
end.
END PROCEDURE. /* manage-tb-exp-stk */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE object-select Dialog-Frame
PROCEDURE object-select :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-rs-1   as integer      no-undo.

case p-rs-1
:
    when 1
    then do:
        assign
            ed-object :screen-value in frame Dialog-frame = ""
        .
    end.
    when 2
    then do:
        assign
            ed-object :screen-value = v-host-name
        .
    end.
    when 3
    then do:
        assign
            ed-object :screen-value = ""
        .
        for each temp_obj-list
        :
            assign
                ed-object :screen-value = ed-object :screen-value
                    + ( if ed-object :screen-value = "" then "" else ", " )
                    + temp_obj-list.obj-type + string( temp_obj-list.obj-code )
            .
        end.
    end.
end case.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-objects-only-this-db Dialog-Frame
PROCEDURE select-objects-only-this-db :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-only-this-db-obj-list as character    no-undo.
define output parameter p-exclude-obj-list      as character    no-undo.

    define variable v-db-num                as integer       no-undo.
    define variable v-obj-type              as character     no-undo.
    define variable v-obj-code              as integer       no-undo.

    define buffer buf_clients       for ub.clients.
    define buffer buf_temp_obj-list for temp_obj-list.
    define buffer buf_temp_db-num   for temp_db-num.
    define buffer buf_schedule      for ub.schedule.
do
for buf_clients
  , buf_temp_obj-list
  , buf_temp_db-num
  , buf_schedule
on error undo, return error
:
    find first buf_schedule no-lock
         where buf_schedule.cre-db-num  = p-cre-db-num
           and buf_schedule.task-type   = p-task-type
           and buf_schedule.task-num    = p-task-num
    no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Не найдена строка расписания для определения параметров."
            skip return-value
            skip trim( error-status :get-message( 1 ) )
                 trim( error-status :get-message( 2 ) )
                 trim( error-status :get-message( 3 ) )
        view-as alert-box error.
        undo, return error.
    end.
    assign
        p-only-this-db-obj-list = "":U
        p-exclude-obj-list      = "":U
    .
    if buf_schedule.db-num-char <> "*":U
    then do:
        run gbl/prcs-lst.p (
              input buf_schedule.db-num-char
            , input 0
            , input 99999  /* (максимальное значение db.db-num) */
            , input no
            , input ( buffer buf_temp_db-num :handle )
            , input "db-num-key":U
        ) no-error .
        if error-status :error
        then do:
            message
                    vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка разбора списка баз данных."
                skip return-value
                skip trim( error-status :get-message( 1 ) )
                    trim( error-status :get-message( 2 ) )
                    trim( error-status :get-message( 3 ) )
            view-as alert-box error.
            undo, return error.
        end.
    end.
    for each buf_temp_obj-list
    :
        find first buf_clients no-lock
             where buf_clients.obj-type = buf_temp_obj-list.obj-type
               and buf_clients.obj-code = buf_temp_obj-list.obj-code
        .
        if buf_schedule.db-num-char = "*":U
        then do:
            assign
                p-only-this-db-obj-list = p-only-this-db-obj-list
                                        + ( if p-only-this-db-obj-list <> "" then ", " else "" )
                                        + buf_temp_obj-list.obj-type + string( buf_temp_obj-list.obj-code )
            .
        end.
        else do:
            find first buf_temp_db-num
                 where buf_temp_db-num.db-num-key = buf_clients.db-num
            no-error.
            if available buf_temp_db-num
            then do:
                assign
                    p-only-this-db-obj-list = p-only-this-db-obj-list
                                            + ( if p-only-this-db-obj-list <> "" then ", " else "" )
                                            + buf_temp_obj-list.obj-type + string( buf_temp_obj-list.obj-code )
                .
            end.
            else do:
                assign
                    p-exclude-obj-list = p-exclude-obj-list
                                            + ( if p-exclude-obj-list <> "" then ", " else "" )
                                            + buf_temp_obj-list.obj-type + string( buf_temp_obj-list.obj-code )
                .
                delete buf_temp_obj-list.
            end.
        end.
    end.
end.
END PROCEDURE. /* select-objects-only-this-db */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME