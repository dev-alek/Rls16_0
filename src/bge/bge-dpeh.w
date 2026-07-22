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

Выбор параметров для выгрузки документов по сменам.

Автор: Хныкин Павел Андреевич
Дата создания: 05/12/06
Author: Pavel Khnykin
Creation date: 05/12/06

Input:
    p-output-type    as integer     - Что запрашивать:
                                        0 - только диапазон дат,
                                        1 - всё, кроме tb-supp (остатки по поставщикам)
                                        2 - tb-supp (остатки по поставщикам)
                                        3 - все, кроме tb-supp (остатки по поставщикам) и галок.
                                        4 - то же, что и 2, но с выбором объектов и с одной (последней) датой
                                        5 - только выбор объектов
    p-init-doc-type-list as character    - список типов документов
Output:
    date_exp_from  as date          - Дата с
    p-shift-num-from as integer     - Номер смены с
    date_exp_to    as date          - Дата по
    p-shift-num-to as integer       - Номер смены по
    p-shift-on     as logical       - Выгрузка по сменным объектам
    p-range        as integer       - Диапазон: 1 - глобально, 2 - по фирме, 3 - список объектов
    p-host-code    as integer       - Код текущей фирмы для p-range = 2
    p-obj-list     as character     - для p-range = 3, список ( "маг,3,скл,20,скл,2" )
    p-doc-type-list as character    - список типов документов
    p-pay-code     as logical       - выгружать ли коды оплаты
    p-cst          as logical       - выгружать ли строку ГТД
    p-parts        as logical       - выгружать ли партии
    p-chk-pay-code as logical       - выгружать ли разброску по платежам
    p-pay-desk     as logical       - выгружать ли разброску по кассам
    p-pay-desk-cards as logical       - выгружать ли разброску по префиксам карт
    p-deleted      as logical       - выгружать ли удаленные в заданный период документы
    p-chk          as logical       - выгружать ли чеки
    p-doc-rvs      as logical       - выгружать ли сверки до/после слива по документам прихода
    p-cancel       as logical       - была нажата кнопка Отменить

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc        as handle               no-undo.
define input parameter p-output-type        as integer              no-undo.
define input parameter p-init-doc-type-list as character            no-undo.
define output parameter date_exp_from       as date      INIT ?     no-undo.
define output parameter p-shift-num-from    as integer              no-undo.
define output parameter date_exp_to         as date      INIT ?     no-undo.
define output parameter p-shift-num-to      as integer              no-undo.
define output parameter p-shift-on          as logical              no-undo.
define output parameter p-range             as integer              no-undo.
define output parameter p-host-code         as integer              no-undo.
define output parameter p-obj-list          as character            no-undo.
define output parameter p-doc-type-list     as character            no-undo.
define output parameter p-pay-code          as logical   INIT no    no-undo.
define output parameter p-cst               as logical   INIT no    no-undo.
define output parameter p-parts             as logical   INIT no    no-undo.
define output parameter p-chk-pay-code      as logical   INIT no    no-undo.
define output parameter p-pay-desk          as logical   INIT no    no-undo.
define output parameter p-pay-desk-cards    as logical   INIT no    no-undo.
define output parameter p-deleted           as logical   INIT no    no-undo.
define output parameter p-chk               as logical   INIT no    no-undo.
define output parameter p-doc-rvs           as logical   INIT no    no-undo.
define output parameter p-cancel            as logical   INIT no    no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор параметров для выгрузки документов по сменам.".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ gbl/temphost.i }
{ gbl/getcntxt.i def }
{ cmp/showinf.i  }
{ gbl/userobjs.i }

define variable v-obj-list          as character    no-undo.
define variable v-obj-full-list     as character    no-undo.
define variable v-host-name         as character    no-undo.

define temp-table temp_obj-list no-undo
    field obj-type as character
    field obj-code as integer
    index pi is primary unique obj-type obj-code
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
&Scoped-Define ENABLED-OBJECTS RECT-2 RECT-1 Btn_OK Btn_Cancel b-help ~
date_from date_to fi-shift-num-from fi-shift-num-to rs-1 bt-sel-obj ~
ed-doc-type bt-sel-doc-type tb-inkass-pay-code tb-deleted tb-cst-code ~
tb-exp-checks tb-parts tb-chk-pay-code tb-pay-desk tb-pay-desk-cards tb-exp-doc-rvs
&Scoped-Define DISPLAYED-OBJECTS date_from date_to ed-object rs-1 ~
ed-doc-type ed-doc-type-label tb-inkass-pay-code tb-deleted tb-cst-code ~
tb-exp-checks tb-parts tb-chk-pay-code tb-pay-desk tb-pay-desk-cards tb-exp-doc-rvs

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

DEFINE BUTTON Btn_Cancel
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK DEFAULT
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE ed-doc-type AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-VERTICAL NO-BOX
     SIZE 35.75 BY 1.83 NO-UNDO.

DEFINE VARIABLE ed-doc-type-label AS CHARACTER INITIAL "Типы документов"
     VIEW-AS EDITOR NO-BOX
     SIZE 12.5 BY 1.75 NO-UNDO.

DEFINE VARIABLE ed-object AS CHARACTER
     VIEW-AS EDITOR NO-BOX
     SIZE 35.63 BY 3.38
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE date_from AS DATE FORMAT "99/99/9999":U
     LABEL "Дата с"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE date_to AS DATE FORMAT "99/99/9999":U
     LABEL "---    Дата по"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE fi-shift-num-from AS INTEGER FORMAT ">9":U INITIAL 0
     LABEL "Порядок с"
     VIEW-AS FILL-IN
     SIZE 3.5 BY 1 NO-UNDO.

DEFINE VARIABLE fi-shift-num-to AS INTEGER FORMAT ">9":U INITIAL 0
     LABEL "Порядок по"
     VIEW-AS FILL-IN
     SIZE 3.5 BY 1 NO-UNDO.

DEFINE VARIABLE rs-1 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "глобально", 1,
"по фирме", 2,
"по объектам", 3
     SIZE 13.75 BY 3.25 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 55.38 BY 4.38.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 55.25 BY 2.17.

DEFINE VARIABLE tb-chk-pay-code AS LOGICAL INITIAL no
     LABEL "По типу кассовых платежей из чеков"
     VIEW-AS TOGGLE-BOX
     SIZE 38 BY .83 NO-UNDO.

DEFINE VARIABLE tb-cst-code AS LOGICAL INITIAL no
     LABEL "ГТД по строке документа"
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .83 NO-UNDO.

DEFINE VARIABLE tb-deleted AS LOGICAL INITIAL no
     LABEL "удалённые"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY .83 NO-UNDO.

DEFINE VARIABLE tb-exp-checks AS LOGICAL INITIAL no
     LABEL "Чеки"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY .83 NO-UNDO.
     
DEFINE VARIABLE tb-exp-doc-rvs AS LOGICAL INITIAL no
     LABEL "Сверки до/после слива"
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .83 NO-UNDO.     

DEFINE VARIABLE tb-inkass-pay-code AS LOGICAL INITIAL no
     LABEL "По виду оплаты"
     VIEW-AS TOGGLE-BOX
     SIZE 24.38 BY .83 NO-UNDO.

DEFINE VARIABLE tb-parts AS LOGICAL INITIAL no
     LABEL "По партиям"
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .83 NO-UNDO.

DEFINE VARIABLE tb-pay-desk AS LOGICAL INITIAL no
     LABEL "По кассе"
     VIEW-AS TOGGLE-BOX
     SIZE 12.25 BY .83 NO-UNDO.

DEFINE VARIABLE tb-pay-desk-cards AS LOGICAL INITIAL no
     LABEL "По префиксам карт"
     VIEW-AS TOGGLE-BOX
     SIZE 22 BY .83 NO-UNDO.

DEFINE VARIABLE tb-supp AS LOGICAL INITIAL no
     LABEL "Остатки по поставщикам"
     VIEW-AS TOGGLE-BOX
     SIZE 26.88 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.25 COL 1.5
     Btn_Cancel AT ROW 1.25 COL 11.5
     b-help AT ROW 1.25 COL 47
     date_from AT ROW 3 COL 9.5 COLON-ALIGNED
     date_to AT ROW 3 COL 42.5 COLON-ALIGNED
     fi-shift-num-from AT ROW 4.25 COL 18 COLON-ALIGNED
     fi-shift-num-to AT ROW 4.25 COL 51 COLON-ALIGNED
     tb-supp AT ROW 6.63 COL 10
     ed-object AT ROW 7.04 COL 20.38 NO-LABEL
     rs-1 AT ROW 7.13 COL 2.63 NO-LABEL
     bt-sel-obj AT ROW 9.29 COL 16.63
     ed-doc-type AT ROW 11.25 COL 16.38 NO-LABEL
     bt-sel-doc-type AT ROW 11.29 COL 52.88
     ed-doc-type-label AT ROW 11.33 COL 2.63 NO-LABEL
     tb-inkass-pay-code AT ROW 13.54 COL 2.13
     tb-deleted AT ROW 13.58 COL 36.13
     tb-cst-code AT ROW 14.33 COL 2.13
     tb-exp-checks AT ROW 14.33 COL 36.13 WIDGET-ID 2
     tb-exp-doc-rvs AT ROW 15.08 COL 36.13
     tb-parts AT ROW 15.08 COL 2.13
     tb-chk-pay-code AT ROW 15.83 COL 2.13
     tb-pay-desk AT ROW 16.75 COL 5.13
     tb-pay-desk-cards AT ROW 17.58 COL 5.13
     RECT-2 AT ROW 11.13 COL 1.63
     RECT-1 AT ROW 6.5 COL 1.5
     SPACE(1.36) SKIP(7.78)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Диапазон дат для экспорта".


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
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       ed-doc-type:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR EDITOR ed-doc-type-label IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       ed-doc-type-label:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR EDITOR ed-object IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-shift-num-from IN FRAME Dialog-Frame
   NO-DISPLAY                                                           */
/* SETTINGS FOR FILL-IN fi-shift-num-to IN FRAME Dialog-Frame
   NO-DISPLAY                                                           */
/* SETTINGS FOR TOGGLE-BOX tb-supp IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       tb-supp:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Диапазон дат для экспорта */
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
    run bge/bgeseltp.w (
          input "trn-doc":U
        , input p-init-doc-type-list
        , output p-doc-type-list
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
            p-doc-type-list = p-init-doc-type-list
        .
    end.
    else do:
        assign
            p-init-doc-type-list    = p-doc-type-list
        .
        if p-doc-type-list = "":U
        then do:
            assign
                ed-doc-type :screen-value in frame Dialog-Frame = "Все"
            .
        end.
        else do:
            assign
                ed-doc-type :screen-value in frame Dialog-Frame = "":U
            .
            do v-oper-num = 1 to num-entries( {&TDEDT_List} )
            :
                if lookup( entry( v-oper-num, {&TDEDT_List} ), p-init-doc-type-list ) <> 0
                then do:
                    assign
                        ed-doc-type :screen-value in frame Dialog-Frame = ed-doc-type :screen-value in frame Dialog-Frame
                                                    + entry( v-oper-num, {&TDEDT_List-full} ) + {&new-line}
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
    define variable v-shift-on    as logical      no-undo.

    define variable v-object-available as logical   no-undo .

    assign
        rs-1 :screen-value  = "3"
    .

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
    for each  temp_obj-list.
      delete temp_obj-list.
    end.
    for each buf_userobjs_temp-user-obj
    on error undo, return no-apply
    :
      create temp_obj-list.
      assign
        temp_obj-list.obj-type = buf_userobjs_temp-user-obj.obj-type
        temp_obj-list.obj-code = buf_userobjs_temp-user-obj.obj-code
      .
    end.
    assign
        v-obj-list      = "":U
        v-obj-full-list = "":U
    .
    for each temp_obj-list
    :
        assign
            v-obj-list      = v-obj-list
                            + ( if v-obj-list <> "":U then ", " else "":U )
                            + substitute( "&1&2", temp_obj-list.obj-type, temp_obj-list.obj-code )
            v-obj-full-list = v-obj-full-list
                            + ( if v-obj-full-list <> "":U then ", " else "":U )
                            + substitute( "&1,&2", temp_obj-list.obj-type, temp_obj-list.obj-code )
        .
    end.
    assign
        ed-object :screen-value = v-obj-list
    .
    run get-shift-on in this-procedure (
          input 3
        , input v-obj-full-list
        , output v-shift-on
    ).
    if v-shift-on = ?
    then do:
        message
                 "Неверно выбраны объекты. Все выбранные объекты"
            skip "должны быть либо сменными, либо не сменными."
        view-as alert-box information.
        assign
            date_from :label = "Дата с"
        .
        hide
            fi-shift-num-from
            fi-shift-num-to
        .
    end.
    else do:
        if v-shift-on = yes
        then do:
            assign
                date_from :label = "Смена с"
            .
            view
                fi-shift-num-from
                fi-shift-num-to
            .
        end.
        else do:
            assign
                date_from :label = "Дата с"
            .
            hide
                fi-shift-num-from
                fi-shift-num-to
            .
        end.
    end.
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
    apply "window-close" to frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Ввод */
DO:
    ASSIGN
        date_from
        date_to
        tb-inkass-pay-code
        tb-cst-code
        tb-parts
        tb-deleted
        tb-supp
        rs-1
        tb-chk-pay-code
        tb-pay-desk
        tb-pay-desk-cards
        tb-exp-checks
        tb-exp-doc-rvs
        fi-shift-num-from
        fi-shift-num-to
    .
    assign
        date_exp_from       = date_from
        date_exp_to         = date_to
        p-shift-num-from    = fi-shift-num-from
        p-shift-num-to      = fi-shift-num-to
        p-chk               = tb-exp-checks
        p-doc-rvs           = tb-exp-doc-rvs
    .
    if p-output-type = 0
    then do:
      case rs-1 :screen-value
      :
      when "1"
      then do:
          assign
              p-range = 1
              p-obj-list = "":U
          .
      end.
      when "2"
      then do:
          assign
              p-range = 2
              p-obj-list = "":U
          .
      end.
      when "3"
      then do:
          assign
              p-range = 3
          .
          assign
              p-obj-list = "":U
          .
          for each temp_obj-list
          :
              assign
                  p-obj-list = p-obj-list
                          + ( if p-obj-list = "":U then "":U else ",":U ) + temp_obj-list.obj-type
                          + ",":U + string( temp_obj-list.obj-code )
              .
          end.
      end.
      end case.
    end.
    if p-output-type = 2
    then do:
        assign
            p-cst = tb-supp
        .
    end.
    if p-output-type = 1
    or p-output-type = 3
    or p-output-type = 4
    or p-output-type = 5
    then do:
        if p-output-type = 1
        then do:
            assign
                p-pay-code     = tb-inkass-pay-code
                p-cst          = tb-cst-code
                p-parts        = tb-parts
                p-deleted      = tb-deleted
                p-chk-pay-code = tb-chk-pay-code
                p-pay-desk     = tb-pay-desk
                p-pay-desk-cards = tb-pay-desk-cards
            .
        end.
        case rs-1 :screen-value
        :
        when "1"
        then do:
            assign
                p-range = 1
                p-obj-list = "":U
            .
        end.
        when "2"
        then do:
            assign
                p-range = 2
                p-host-code = v-cntxt-host-code-obj
                p-obj-list = "":U
            .
        end.
        when "3"
        then do:
            assign
                p-range = 3
            .
            assign
                p-obj-list = "":U
            .
            for each temp_obj-list
            :
                assign
                    p-obj-list = p-obj-list
                            + ( if p-obj-list = "":U then "":U else ",":U )
                            + substitute( "&1,&2", temp_obj-list.obj-type, temp_obj-list.obj-code )
                .
            end.
        end.
        end case.
    end.        /* p-output-type = 1 */
    define variable v-data-are-valid        as logical      no-undo.
    define variable v-reason                as character    no-undo.
    define variable v-err-widget-handle     as handle       no-undo.
    run check-data in this-procedure (
          input date_exp_from
        , input date_exp_to
        , input p-shift-num-from
        , input p-shift-num-to
        , input tb-inkass-pay-code
        , input tb-cst-code
        , input tb-parts
        , input tb-deleted
        , input tb-supp
        , input tb-chk-pay-code
        , input tb-pay-desk
        , input tb-pay-desk-cards
        , input p-range
        , input p-obj-list
        , output v-data-are-valid
        , output v-reason
        , output v-err-widget-handle
        , output p-shift-on
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка проверки данных."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if v-data-are-valid = no
    then do:
        message
            "Выгрузка по введённым данным невозможна."
            skip v-reason
            skip (1)
            skip "Исправьте данные и повторите ввод."
        view-as alert-box error
        title "Ошибка введённых данных".
        if valid-handle( v-err-widget-handle )
        then do:
            apply "entry" to v-err-widget-handle.
        end.
        undo, return no-apply.
    end.
    run write-parameters in this-procedure (
          input date_from
        , input date_to
        , input fi-shift-num-from
        , input fi-shift-num-to
        , input rs-1
        , input p-host-code
        , input p-obj-list
        , input p-init-doc-type-list
        , input p-pay-code
        , input p-cst
        , input p-parts
        , input p-chk-pay-code
        , input p-pay-desk
        , input p-pay-desk-cards
        , input p-deleted
        , input p-chk
        , input p-doc-rvs
    ).
    APPLY "GO" TO FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME date_from
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL date_from Dialog-Frame
ON RETURN OF date_from IN FRAME Dialog-Frame /* Дата с */
DO:
    APPLY "ENTRY" TO date_to IN FRAME {&FRAME-NAME}.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME date_to
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL date_to Dialog-Frame
ON RETURN OF date_to IN FRAME Dialog-Frame /* ---    Дата по */
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
run object-select in this-procedure no-error .
if error-status :error
then do:
    undo, return no-apply.
end.
assign
    rs-1
.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tb-chk-pay-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tb-chk-pay-code Dialog-Frame
ON VALUE-CHANGED OF tb-chk-pay-code IN FRAME Dialog-Frame /* По типу кассовых платежей из чеков */
DO:
    assign
        tb-chk-pay-code
    .
    run manage-tb-chk-pay-code in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }
{ gbl/ed_date.i date_from }
{ gbl/ed_date.i date_to   }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    { gbl/getcntxt.i get }
    run init-fields in this-procedure .
    RUN enable_UI.
    run init-manage-fields in this-procedure .
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE assign-date Dialog-Frame
PROCEDURE assign-date :
define input parameter p-parameter-number   as integer          no-undo.
define input parameter p-parameter-list     as character        no-undo.
define input parameter p-default-value      as date             no-undo.
define output parameter p-parameter-value   as date             no-undo.
do
on error undo, return error
:
    if num-entries( p-parameter-list ) >= p-parameter-number
    then do:
        assign
            p-parameter-value   = date( entry( p-parameter-number, p-parameter-list ) )
        no-error.
        if error-status :error
        then do:
            assign
                p-parameter-value = p-default-value
            .
        end.
    end.
    else do:
        assign
            p-parameter-value = p-default-value
        .
    end.
end.
END PROCEDURE. /* assign-date */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE assign-integer Dialog-Frame
PROCEDURE assign-integer :
define input parameter p-parameter-number   as integer          no-undo.
define input parameter p-parameter-list     as character        no-undo.
define input parameter p-default-value      as integer          no-undo.
define output parameter p-parameter-value   as integer          no-undo.
do
on error undo, return error
:
    if num-entries( p-parameter-list ) >= p-parameter-number
    then do:
        assign
            p-parameter-value   = integer( entry( p-parameter-number, p-parameter-list ) )
        no-error.
        if error-status :error
        then do:
            assign
                p-parameter-value = p-default-value
            .
        end.
    end.
    else do:
        assign
            p-parameter-value = p-default-value
        .
    end.
end.
END PROCEDURE. /* assign-integer */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE assign-logical Dialog-Frame
PROCEDURE assign-logical :
define input parameter p-parameter-number   as integer          no-undo.
define input parameter p-parameter-list     as character        no-undo.
define input parameter p-default-value      as logical          no-undo.
define output parameter p-parameter-value   as logical          no-undo.
do
on error undo, return error
:
    if num-entries( p-parameter-list ) >= p-parameter-number
    then do:
        assign
            p-parameter-value   = ( entry( p-parameter-number, p-parameter-list ) = "yes" )
        .
    end.
    else do:
        assign
            p-parameter-value = p-default-value
        .
    end.
end.
END PROCEDURE. /* assign-logical */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-data Dialog-Frame
PROCEDURE check-data :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-date_from          as date             no-undo.
define input parameter p-date_to            as date             no-undo.
define input parameter p-shift-num-from     as integer          no-undo.
define input parameter p-shift-num-to       as integer          no-undo.
define input parameter p-tb-inkass-pay-code as logical          no-undo.
define input parameter p-tb-cst-code        as logical          no-undo.
define input parameter p-tb-parts           as logical          no-undo.
define input parameter p-tb-deleted         as logical          no-undo.
define input parameter p-tb-supp            as logical          no-undo.
define input parameter p-tb-chk-pay-code    as logical          no-undo.
define input parameter p-tb-pay-desk        as logical          no-undo.
define input parameter p-tb-pay-desk-cards  as logical          no-undo.
define input parameter p-range              as integer          no-undo.
define input parameter p-obj-list           as character        no-undo.
define output parameter p-data-are-valid    as logical          no-undo.
define output parameter p-reason            as character        no-undo.
define output parameter p-err-widget-handle as handle           no-undo.
define output parameter p-shift-on          as logical          no-undo.

    define variable v-shift-on    as logical      no-undo.
do
with frame {&frame-name}
on error undo, return error
:
    assign
        p-data-are-valid = yes
    .
    if p-date_from > p-date_to
    and p-output-type <> 4
    then do:
        assign
            p-data-are-valid = no
            p-reason         = substitute( "&2&1&3":U
                                    , {&new-line}
                                    , "Даты интервала заданы неверно. "
                                    , "Нижняя дата интервала должна быть меньше верхней."
                                    )
            p-err-widget-handle = date_from :handle
        .
        undo, return no-apply.
    end.
    if p-range < 1
    or p-range > 3
    then do:
        assign
            p-data-are-valid = no
            p-reason         = substitute( "&2&1&3":U
                                    , {&new-line}
                                    , p-reason
                                    , "Неверно выбраны объекты для выгрузки."
                                    )
            p-err-widget-handle = rs-1 :handle
        .
        undo, return no-apply.
    end.
    run get-shift-on in this-procedure (
          input p-range
        , input p-obj-list
        , output v-shift-on
    ).
    if v-shift-on = ?
    then do:
        assign
            p-data-are-valid = no
            p-reason         = substitute( "&2&1&3&1&4":U
                                    , {&new-line}
                                    , p-reason
                                    , "Неверно выбраны объекты. Все выбранные объекты"
                                    , "должны быть либо сменными, либо не сменными."
                                    )
            p-err-widget-handle = rs-1 :handle
        .
    end.
    else do:
        assign
            p-shift-on = v-shift-on
        .
    end.
    if p-shift-on = yes
    and p-shift-num-from = 0
    then do:
        assign
            p-data-are-valid = no
            p-reason         = substitute( "&2&1&3&1&4":U
                                    , {&new-line}
                                    , p-reason
                                    , "Введите номер смены с..."
                                    )
            p-err-widget-handle = fi-shift-num-from :handle
        .
    end.
    if p-shift-on = yes
    and p-shift-num-to = 0
    then do:
        assign
            p-data-are-valid = no
            p-reason         = substitute( "&2&1&3&1&4":U
                                    , {&new-line}
                                    , p-reason
                                    , "Введите номер смены по..."
                                    )
            p-err-widget-handle = fi-shift-num-to :handle
        .
    end.
    if p-shift-on = yes
    and p-date_from = p-date_to
    and p-shift-num-from > p-shift-num-to
    then do:
        assign
            p-data-are-valid = no
            p-reason         = substitute( "&2&1&3&1&4":U
                                    , {&new-line}
                                    , p-reason
                                    , "Неверно введены номера смен."
                                    )
            p-err-widget-handle = fi-shift-num-from :handle
        .
    end.
end.
END PROCEDURE. /* check-data */

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
  DISPLAY date_from date_to ed-object rs-1 ed-doc-type ed-doc-type-label
          tb-inkass-pay-code tb-deleted tb-cst-code tb-exp-checks tb-parts
          tb-chk-pay-code tb-pay-desk tb-pay-desk-cards tb-exp-doc-rvs
      WITH FRAME Dialog-Frame.
  ENABLE RECT-2 RECT-1 Btn_OK Btn_Cancel b-help date_from date_to
         fi-shift-num-from fi-shift-num-to rs-1 bt-sel-obj ed-doc-type
         bt-sel-doc-type tb-inkass-pay-code tb-deleted tb-cst-code
         tb-exp-checks tb-parts tb-chk-pay-code tb-pay-desk tb-pay-desk-cards
         tb-exp-doc-rvs
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

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

define buffer buf_clients   for clients.

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-shift-on Dialog-Frame
PROCEDURE get-shift-on :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-range          as integer          no-undo.
define input parameter p-obj-list       as character        no-undo.
define output parameter p-shift-on      as logical          no-undo.

    define variable v-shift-obj-on      as logical      no-undo.
    define variable v-obj-counter       as integer      no-undo.
    define variable v-obj-type          as character    no-undo.
    define variable v-obj-code          as integer      no-undo.
do
on error undo, return error
:
    assign
        p-shift-on = ?
    .
    case p-range
    :
        when 1
        then do:
            run init-temphost.
            check-shift-on-all-obj:
            for each temp-obj
            :
                { gbl/objat.i
                    temp-obj.obj-type
                    temp-obj.obj-code
                    "'shift-on=request'"
                    v-shift-obj-on
                    no-error
                }
                if error-status :error
                then do:
                    message
                        vss-workfile vss-revision vss-description
                        skip "Ошибка при определении типа сменный/не-сменный для объекта"
                        skip "Объект" temp-obj.obj-type temp-obj.obj-code
                        skip "Атрибут" 'shift-on=request':U
                        skip error-status :get-message(1)
                        skip return-value
                    view-as alert-box error .
                    undo, return error .
                end.
                if p-shift-on = ?
                then do:
                    assign
                        p-shift-on = v-shift-obj-on
                    .
                end.
                else do:
                    if p-shift-on <> v-shift-obj-on
                    then do:
                        assign
                            p-shift-on = ?
                        .
                        leave check-shift-on-all-obj.
                    end.
                end.
            end.
        end.        /* when 1 */
        when 2
        then do:
            run init-temphost.
            check-shift-on-all-obj:
            for each temp-obj
            where temp-obj.host-code = v-cntxt-host-code-obj
            :
                { gbl/objat.i
                    temp-obj.obj-type
                    temp-obj.obj-code
                    "'shift-on=request'"
                    v-shift-obj-on
                    no-error
                }
                if error-status :error
                then do:
                    message
                        vss-workfile vss-revision vss-description
                        skip "Ошибка при определении типа сменный/не-сменный для объекта"
                        skip "Объект" temp-obj.obj-type temp-obj.obj-code
                        skip "Атрибут" 'shift-on=request':U
                        skip error-status :get-message(1)
                        skip return-value
                    view-as alert-box error .
                    undo, return error .
                end.
                if p-shift-on = ?
                then do:
                    assign
                        p-shift-on = v-shift-obj-on
                    .
                end.
                else do:
                    if p-shift-on <> v-shift-obj-on
                    then do:
                        assign
                            p-shift-on = ?
                        .
                        leave check-shift-on-all-obj.
                    end.
                end.
            end.
        end.        /* when 2 */
        when 3
        then do:
            check-shift-on-all-obj:
            do
            v-obj-counter = 1 to num-entries( p-obj-list ) / 2
            on error undo, return error
            :
                assign
                    v-obj-type = trim( entry( v-obj-counter * 2 - 1, p-obj-list ) )
                    v-obj-code = integer( entry( v-obj-counter * 2    , p-obj-list ) )
                .
                { gbl/objat.i
                    v-obj-type
                    v-obj-code
                    "'shift-on=request'"
                    v-shift-obj-on
                    no-error
                }
                if error-status :error
                then do:
                    message
                        vss-workfile vss-revision vss-description
                        skip "Ошибка при определении типа сменный/не-сменный для объекта"
                        skip "Объект" v-obj-type v-obj-code
                        skip "Атрибут" 'shift-on=request':U
                        skip error-status :get-message(1)
                        skip return-value
                    view-as alert-box error .
                    undo, return error .
                end.
                if p-shift-on = ?
                then do:
                    assign
                        p-shift-on = v-shift-obj-on
                    .
                end.
                else do:
                    if p-shift-on <> v-shift-obj-on
                    then do:
                        assign
                            p-shift-on = ?
                        .
                        leave check-shift-on-all-obj.
                    end.
                end.
            end.
        end.        /* when 3 */
    end case.       /* case p-range */
end.
END PROCEDURE. /* get-shift-on */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-fields Dialog-Frame
PROCEDURE init-fields :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define variable v-today         as date         no-undo.
    define variable v-time          as integer      no-undo.
    define variable v-obj-counter   as integer      no-undo.
    define variable v-doc-type-list as character    no-undo.
do
with frame {&frame-name}
on error undo, return error
:
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
    run read-parameters in this-procedure (
          input v-today
        , input v-cntxt-host-code-obj
        , output date_from
        , output date_to
        , output fi-shift-num-from
        , output fi-shift-num-to
        , output rs-1
        , output p-host-code
        , output p-obj-list
        , output v-doc-type-list
        , output tb-inkass-pay-code
        , output tb-cst-code
        , output tb-parts
        , output tb-chk-pay-code
        , output tb-pay-desk
        , output tb-pay-desk-cards
        , output tb-deleted
        , output tb-exp-checks
        , output tb-exp-doc-rvs
    ).
    if p-init-doc-type-list = "":U
    then do:
        assign
            p-init-doc-type-list = v-doc-type-list
        .
    end.
    case rs-1
    :
        when 1
        then do:
            assign
                ed-object = "":U
            .
        end.
        when 2
        then do:
            assign
                ed-object = string( p-host-code )
            .
        end.
        when 3
        then do:
            assign
                ed-object = "":U
            .
            do
            v-obj-counter = 1 to num-entries( p-obj-list ) / 2
            :
                create temp_obj-list.
                assign
                    temp_obj-list.obj-type = entry( v-obj-counter * 2 - 1, p-obj-list )
                    temp_obj-list.obj-code = integer( entry( v-obj-counter * 2    , p-obj-list ) )
                    ed-object              = substitute( "&1&2&3&4"
                                                , ed-object
                                                , ( if ed-object = "":U then "":U else ",":U )
                                                , temp_obj-list.obj-type
                                                , temp_obj-list.obj-code  )
                .
            end.
        end.
    end case.       /* case rs-1 */
    run get-host-name in this-procedure (
        output v-host-name
    ) no-error .
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
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-manage-fields Dialog-Frame
PROCEDURE init-manage-fields :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define variable v-shift-on    as logical      no-undo.
    define variable v-oper-num     as integer           no-undo.
do
with frame {&frame-name}
on error undo, return error
:
    if p-output-type = 0
    or p-output-type = 2
    or p-output-type = 3
    or p-output-type = 5
    then do:
/*        assign*/
/*            ed-doc-type :screen-value = {&new-line} + "    Все"*/
/*        .*/
        disable ed-doc-type.
        hide
            bt-sel-doc-type
            tb-inkass-pay-code
            tb-cst-code
            tb-parts
            tb-chk-pay-code
            tb-pay-desk
            tb-pay-desk-cards
            tb-deleted
        .
        if p-output-type <> 3
        then do:
            hide
                RECT-1
                rs-1
                bt-sel-obj
                ed-object
            .
        end.
    end.
    if p-output-type = 2
    then do:
        view tb-supp in frame {&frame-name} .
        enable tb-supp with frame {&frame-name} .
    end.
    if p-output-type = 4
    or p-output-type = 5
    then do:
/*        assign*/
/*            ed-doc-type :screen-value = {&new-line} + "    Все"*/
/*        .*/
        hide
            tb-supp
            bt-sel-doc-type
            tb-inkass-pay-code
            tb-cst-code
            tb-parts
            tb-chk-pay-code
            tb-pay-desk
            tb-pay-desk-cards
            tb-deleted
            RECT-2
            ed-doc-type
            ed-doc-type-label
        .
        if p-output-type = 4
        then do:
            hide
                date_to
            .
        end.
        if p-output-type = 5
        then do:
            view
                RECT-1
                rs-1
                bt-sel-obj
                ed-object
            .
            assign
                frame {&frame-name} :title = "Выбор объектов для экспорта"
            .
        end.
    end.
    run manage-tb-chk-pay-code in this-procedure.
    assign
        p-doc-type-list = p-init-doc-type-list
    .
/*    assign*/
/*        rs-1 :screen-value = "2"*/
/*        ed-object :screen-value = {&cmp} + string( v-cntxt-host-code-obj ) + " " + v-host-name*/
/*    .*/
/*    assign*/
/*        rs-1*/
/*    .*/
    if p-init-doc-type-list <> ?
    and p-init-doc-type-list <> "":U
    then do:
        do v-oper-num = 1 to num-entries( {&TDEDT_List} )
        :
            if lookup( entry( v-oper-num, {&TDEDT_List} ), p-init-doc-type-list ) <> 0
            then do:
                assign
                    ed-doc-type :screen-value in frame Dialog-Frame = ed-doc-type :screen-value in frame Dialog-Frame
                                                + entry( v-oper-num, {&TDEDT_List-full} ) + {&new-line}
                .
            end.
        end.
    end.
    else do:
        assign
            ed-doc-type :screen-value = {&new-line} + "    Все"
        .
    end.
    define variable v-obj-list    as character    no-undo.

    for each temp_obj-list
    :
        assign
            v-obj-list = substitute( "&1&2&3,&4"
                                        , v-obj-list
                                        , ( if v-obj-list = "":U then "":U else "," )
                                        , temp_obj-list.obj-type
                                        , temp_obj-list.obj-code
                                    )
        .
    end.
    run get-shift-on in this-procedure (
          input rs-1
        , input v-obj-list
        , output v-shift-on
    ).
    if v-shift-on = ?
    then do:
        message
                 "Неверно выбраны объекты. Все выбранные объекты"
            skip "должны быть либо сменными, либо не сменными."
        view-as alert-box information.
        hide
            fi-shift-num-from
            fi-shift-num-to
        .
    end.
    else do:
        if v-shift-on = yes
        then do:
            assign
                date_from :label = "Смена с"
            .
            view
                fi-shift-num-from
                fi-shift-num-to
            .
            display
                fi-shift-num-from
                fi-shift-num-to
            .
        end.
        else do:
            assign
                date_from :label = "Дата с"
            .
            hide
                fi-shift-num-from
                fi-shift-num-to
            .
        end.
    end.
end.
END PROCEDURE. /* init-manage-fields */

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
END PROCEDURE. /* manage-tb-chk-pay-code */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE object-select Dialog-Frame
PROCEDURE object-select :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define variable v-shift-on    as logical      no-undo.
    define variable v-obj-list    as character    no-undo.
do
with frame {&frame-name}
on error undo, return error
:
    case rs-1 :screen-value in frame Dialog-frame
    :
        when "1"
        then do:
            assign
                ed-object :screen-value = "":U
            .
        end.
        when "2"
        then do:
            assign
                ed-object :screen-value = v-host-name
            .
        end.
        when "3"
        then do:
            for each temp_obj-list
            :
                delete temp_obj-list.
            end.
            create temp_obj-list.
            assign
                temp_obj-list.obj-type = v-cntxt-obj-type
                temp_obj-list.obj-code = v-cntxt-obj-code
                ed-object :screen-value = substitute( "&1&2", v-cntxt-obj-type, v-cntxt-obj-code )
                v-obj-list = substitute( "&1,&2", v-cntxt-obj-type, v-cntxt-obj-code )
            .
        end.
    end case.
    run get-shift-on in this-procedure (
          input integer( rs-1 :screen-value )
        , input v-obj-list
        , output v-shift-on
    ).
    if v-shift-on = ?
    then do:
        message
                 "Неверно выбраны объекты. Все выбранные объекты"
            skip "должны быть либо сменными, либо не сменными."
        view-as alert-box information.
        hide
            fi-shift-num-from
            fi-shift-num-to
        .
    end.
    else do:
        if v-shift-on = yes
        then do:
            assign
                date_from :label = "Смена с"
            .
            view
                fi-shift-num-from
                fi-shift-num-to
            .
            display
                fi-shift-num-from
                fi-shift-num-to
            .
        end.
        else do:
            assign
                date_from :label = "Дата с"
            .
            hide
                fi-shift-num-from
                fi-shift-num-to
            .
        end.
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE read-parameters Dialog-Frame
PROCEDURE read-parameters :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-cur-date           as date             no-undo.
define input parameter p-default-host-code  as integer          no-undo.
define output parameter p-date-from         as date             no-undo.
define output parameter p-date-to           as date             no-undo.
define output parameter p-shift-num-from    as integer          no-undo.
define output parameter p-shift-num-to      as integer          no-undo.
define output parameter p-range             as integer          no-undo.
define output parameter p-host-code         as integer          no-undo.
define output parameter p-obj-list          as character        no-undo.
define output parameter p-doc-type-list     as character        no-undo.
define output parameter p-pay-code          as logical          no-undo.
define output parameter p-cst               as logical          no-undo.
define output parameter p-parts             as logical          no-undo.
define output parameter p-chk-pay-code      as logical          no-undo.
define output parameter p-pay-desk          as logical          no-undo.
define output parameter p-pay-desk-cards    as logical          no-undo.
define output parameter p-deleted           as logical          no-undo.
define output parameter p-chk               as logical          no-undo.
define output parameter p-doc-rvs           as logical          no-undo.

    define variable v-parameters-string as character    no-undo.
    define variable v-temp-date         as date         no-undo.
    define variable v-temp-integer      as integer      no-undo.
    define variable v-temp-logical      as logical      no-undo.

    define buffer buf_usr-flt       for ubflt.usr-flt.
do
for buf_usr-flt
on error undo, return error
:
    assign
        p-date-from         = p-cur-date
        p-date-to           = p-cur-date
        p-shift-num-from    = 1
        p-shift-num-to      = 1
        p-range             = 2
        p-host-code         = p-default-host-code
        p-pay-code          = no
        p-cst               = no
        p-parts             = no
        p-chk-pay-code      = no
        p-pay-desk          = no
        p-pay-desk-cards    = no
        p-deleted           = no
        p-chk               = no
        p-doc-rvs           = no
    .
    assign
        p-obj-list          = "":U
        p-doc-type-list     = "":U
    .
    find first buf_usr-flt no-lock
         where buf_usr-flt.user-name  = v-cntxt-userid
           and buf_usr-flt.call-point = "bge-input-dialog-parameters":U
    no-error.
    if available buf_usr-flt
    then do:
        assign
            v-parameters-string = buf_usr-flt.Naim
        .
        run assign-date    in this-procedure ( input 1 , input v-parameters-string, input p-cur-date            , output p-date-from        ).
        run assign-date    in this-procedure ( input 2 , input v-parameters-string, input p-cur-date            , output p-date-to          ).
        run assign-integer in this-procedure ( input 3 , input v-parameters-string, input 1                     , output p-shift-num-from   ).
        run assign-integer in this-procedure ( input 4 , input v-parameters-string, input 1                     , output p-shift-num-to     ).
        run assign-integer in this-procedure ( input 5 , input v-parameters-string, input 2                     , output p-range            ).
        run assign-integer in this-procedure ( input 6 , input v-parameters-string, input p-default-host-code   , output p-host-code        ).
        run assign-logical in this-procedure ( input 7 , input v-parameters-string, input no                    , output p-pay-code         ).
        run assign-logical in this-procedure ( input 8 , input v-parameters-string, input no                    , output p-cst              ).
        run assign-logical in this-procedure ( input 9 , input v-parameters-string, input no                    , output p-parts            ).
        run assign-logical in this-procedure ( input 10, input v-parameters-string, input no                    , output p-chk-pay-code     ).
        run assign-logical in this-procedure ( input 11, input v-parameters-string, input no                    , output p-pay-desk         ).
        run assign-logical in this-procedure ( input 12, input v-parameters-string, input no                    , output p-pay-desk-cards   ).
        run assign-logical in this-procedure ( input 13, input v-parameters-string, input no                    , output p-deleted          ).
        run assign-logical in this-procedure ( input 14, input v-parameters-string, input no                    , output p-chk              ).
        run assign-logical in this-procedure ( input 15, input v-parameters-string, input no                    , output p-doc-rvs          ).
    end.        /* if available buf_usr-flt */
    find first buf_usr-flt no-lock
         where buf_usr-flt.user-name  = v-cntxt-userid
           and buf_usr-flt.call-point = "bge-input-dialog-obj-list":U
    no-error.
    if available buf_usr-flt
    then do:
        assign
            p-obj-list = buf_usr-flt.Naim
        .
    end.
    find first buf_usr-flt no-lock
         where buf_usr-flt.user-name  = v-cntxt-userid
           and buf_usr-flt.call-point = "bge-input-dialog-doc-type-list":U
    no-error.
    if available buf_usr-flt
    then do:
        assign
            p-doc-type-list = buf_usr-flt.Naim
        .
    end.

end.
END PROCEDURE. /* read-parameters */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE write-parameters Dialog-Frame
PROCEDURE write-parameters :
define input parameter p-date-from         as date             no-undo.
define input parameter p-date-to           as date             no-undo.
define input parameter p-shift-num-from    as integer          no-undo.
define input parameter p-shift-num-to      as integer          no-undo.
define input parameter p-range             as integer          no-undo.
define input parameter p-host-code         as integer          no-undo.
define input parameter p-obj-list          as character        no-undo.
define input parameter p-doc-type-list     as character        no-undo.
define input parameter p-pay-code          as logical          no-undo.
define input parameter p-cst               as logical          no-undo.
define input parameter p-parts             as logical          no-undo.
define input parameter p-chk-pay-code      as logical          no-undo.
define input parameter p-pay-desk          as logical          no-undo.
define input parameter p-pay-desk-cards    as logical          no-undo.
define input parameter p-deleted           as logical          no-undo.
define input parameter p-chk               as logical          no-undo.
define input parameter p-doc-rvs           as logical          no-undo.

    define variable v-parameters-string as character    no-undo.

    define buffer buf_usr-flt       for ubflt.usr-flt.
do
for buf_usr-flt
on error undo, return error
:
    assign
        v-parameters-string = substitute( "&1,&2,&3,&4,&5,&6,&7,&8"
                                        , p-date-from
                                        , p-date-to
                                        , p-shift-num-from
                                        , p-shift-num-to
                                        , p-range
                                        , p-host-code
                                        , p-pay-code
                                        , p-cst )
    .
    assign
        v-parameters-string = substitute( "&1,&2,&3,&4,&5,&6,&7,&8"
                                        , v-parameters-string
                                        , p-parts
                                        , p-chk-pay-code
                                        , p-pay-desk
                                        , p-pay-desk-cards
                                        , p-deleted 
                                        , p-chk 
                                        , p-doc-rvs     )
    .
    find first buf_usr-flt exclusive-lock
         where buf_usr-flt.user-name  = v-cntxt-userid
           and buf_usr-flt.call-point = "bge-input-dialog-parameters":U
    no-error.
    if not available buf_usr-flt
    then do:
        create buf_usr-flt.
        assign
            buf_usr-flt.user-name  = v-cntxt-userid
            buf_usr-flt.call-point = "bge-input-dialog-parameters":U
        .
    end.        /* if available buf_usr-flt */
    assign
        buf_usr-flt.Naim = v-parameters-string
    .
    find first buf_usr-flt exclusive-lock
         where buf_usr-flt.user-name  = v-cntxt-userid
           and buf_usr-flt.call-point = "bge-input-dialog-obj-list":U
    no-error.
    if not available buf_usr-flt
    then do:
        create buf_usr-flt.
        assign
            buf_usr-flt.user-name  = v-cntxt-userid
            buf_usr-flt.call-point = "bge-input-dialog-obj-list":U
        .
    end.        /* if available buf_usr-flt */
    assign
        buf_usr-flt.Naim = p-obj-list
    .
    find first buf_usr-flt exclusive-lock
         where buf_usr-flt.user-name  = v-cntxt-userid
           and buf_usr-flt.call-point = "bge-input-dialog-doc-type-list":U
    no-error.
    if not available buf_usr-flt
    then do:
        create buf_usr-flt.
        assign
            buf_usr-flt.user-name  = v-cntxt-userid
            buf_usr-flt.call-point = "bge-input-dialog-doc-type-list":U
        .
    end.        /* if available buf_usr-flt */
    assign
        buf_usr-flt.Naim = p-doc-type-list
    .
end.
END PROCEDURE. /* write-parameters */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
