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

Выбор параметров для выгрузки документов.

Автор: Гюнтнер Виктор Арнольдович
Дата создания: 04/12/06
Author: Victor Guntner
Creation date: 04/12/06

Input:
    p-output-type    as integer     - Что запрашивать:
                                        0 - только диапазон дат,
                                        1 - все, кроме tb-supp (остатки по поставщикам)
                                        2 - tb-supp (остатки по поставщикам)
                                        3 - все, кроме tb-supp (остатки по поставщикам) и галок.
                                        4 - то же, что и 2, но с выбором объектов и с одной (последней) датой
                                        5 - только выбор объектов
                                        6 - то же, что и 3, но с выбором типа платежей
    p-init-doc-type-list as character    - список типов документов
Output:
    date_exp_from  as date          - Дата с
    date_exp_to    as date          - Дата по
    p-range        as integer       - Диапазон: 1 - глобально, 2 - по фирме, 3 - список объектов
    p-host-code    as integer       - Код текущей фирмы для p-range = 2
    p-obj-list     as character     - для p-range = 3, список ( "маг,3,скл,20,скл,2" )
    p-pay-type-list AS CHARACTER    - список типов платежей ("[RECID(cash-pay)][,RECID(cash-pay)]...)
    p-doc-type-list as character    - список типов документов
    p-pay-code     as logical       - выгружать ли коды оплаты
    p-cst          as logical       - выгружать ли строку ГТД
    p-parts        as logical       - выгружать ли партии
    p-chk-pay-code as logical       - выгружать ли разброску по платежам
    p-pay-desk     as logical       - выгружать ли разброску по кассам
    p-pay-desk-cards as logical       - выгружать ли разброску по префиксам карт
    p-deleted      as logical       - выгружать ли удаленные в заданный период документы
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
define output parameter date_exp_to         as date      INIT ?     no-undo.
define output parameter p-range             as integer              no-undo.
define output parameter p-host-code         as integer              no-undo.
define output parameter p-obj-list          as character            no-undo.
/* !!! */
define output parameter p-pay-type-list     as character            no-undo . /* список recid'ов выбранных записей cash-pay */
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
/*define output parameter p-gds-grp-list      as character            no-undo.*/

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор параметров для выгрузки документов.".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }
{ bge/bge-xml.i  }
{ gbl/usr-flt.i  }
{ ref/grplibfn.i }

define variable v-bge-dper-host-code    as integer      no-undo.
define variable v-bge-dper-store-type   as character    no-undo.
define variable v-bge-dper-store-code   as integer      no-undo.

define variable v-obj-list          as character    no-undo.
define variable v-host-name         as character    no-undo.
define variable v-today             as date         no-undo.
define variable v-time              as integer      no-undo.

define buffer buf_gds-grp for ub.gds-grp.

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

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-2 RECT-1 RECT-3 RECT-gds Btn_OK ~
Btn_Cancel b-help date_from date_to rs-1 bt-sel-obj ed-doc-type ~
bt-sel-doc-type tb-inkass-pay-code tb-deleted tb-cst-code tb-exp-checks tb-exp-doc-rvs ~
tb-parts tb-chk-pay-code rs-cash-pay tb-pay-desk bt-cash-pay ~
tb-pay-desk-cards EDITOR-gds-grp RADIO-SET-gds-grp bt-sel-gds-grp ~
v-text-goods 
&Scoped-Define DISPLAYED-OBJECTS date_from date_to ed-object rs-1 ~
ed-doc-type ed-doc-type-label tb-inkass-pay-code tb-deleted tb-cst-code ~
tb-exp-checks tb-parts tb-chk-pay-code rs-cash-pay tb-pay-desk tb-exp-doc-rvs ~
tb-pay-desk-cards EDITOR-gds-grp RADIO-SET-gds-grp v-text-goods 

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

DEFINE BUTTON bt-cash-pay 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..." 
     SIZE 3.63 BY 1.04.

DEFINE BUTTON bt-sel-doc-type 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..." 
     SIZE 3.63 BY 1.04.

DEFINE BUTTON bt-sel-gds-grp 
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

DEFINE VARIABLE ed-doc-type AS CHARACTER INITIAL "Все" 
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-VERTICAL NO-BOX
     SIZE 35.75 BY 1.79 NO-UNDO.

DEFINE VARIABLE ed-doc-type-label AS CHARACTER INITIAL "Типы документов" 
     VIEW-AS EDITOR NO-BOX
     SIZE 12.63 BY 1.75 NO-UNDO.

DEFINE VARIABLE ed-object AS CHARACTER 
     VIEW-AS EDITOR NO-BOX
     SIZE 35.63 BY 3.38
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE EDITOR-gds-grp AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 38 BY 3.79 NO-UNDO.

DEFINE VARIABLE date_from AS DATE FORMAT "99/99/9999":U 
     LABEL "Дата с" 
     VIEW-AS FILL-IN 
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE date_to AS DATE FORMAT "99/99/9999":U 
     LABEL "по" 
     VIEW-AS FILL-IN 
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE v-text-goods AS CHARACTER FORMAT "X(256)":U INITIAL "Товары" 
      VIEW-AS TEXT 
     SIZE 8 BY .63 NO-UNDO.

DEFINE VARIABLE RADIO-SET-gds-grp AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Все", 1,
"Группы", 2
     SIZE 12 BY 2 NO-UNDO.

DEFINE VARIABLE rs-1 AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "глобально", 1,
"по фирме", 2,
"по объектам", 3
     SIZE 13.75 BY 3.25 NO-UNDO.

DEFINE VARIABLE rs-cash-pay AS LOGICAL 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Все", no,
"Выбор", yes
     SIZE 9 BY 1.88 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 55.38 BY 4.38.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 55.25 BY 2.21.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 55.25 BY 5.08.

DEFINE RECTANGLE RECT-gds
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 55 BY 4.75.

DEFINE VARIABLE tb-chk-pay-code AS LOGICAL INITIAL no 
     LABEL "По типу кассовых платежей из чеков" 
     VIEW-AS TOGGLE-BOX
     SIZE 38 BY .79 NO-UNDO.

DEFINE VARIABLE tb-cst-code AS LOGICAL INITIAL no 
     LABEL "ГТД по строке документа" 
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .79 NO-UNDO.

DEFINE VARIABLE tb-deleted AS LOGICAL INITIAL no 
     LABEL "Удалённые" 
     VIEW-AS TOGGLE-BOX
     SIZE 20.63 BY .79 NO-UNDO.

DEFINE VARIABLE tb-exp-checks AS LOGICAL INITIAL no 
     LABEL "Чеки" 
     VIEW-AS TOGGLE-BOX
     SIZE 20.63 BY .79 NO-UNDO.

DEFINE VARIABLE tb-exp-doc-rvs AS LOGICAL INITIAL no 
     LABEL "Сверки до/после слива" 
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .79 NO-UNDO.
     
DEFINE VARIABLE tb-inkass-pay-code AS LOGICAL INITIAL no 
     LABEL "По виду оплаты" 
     VIEW-AS TOGGLE-BOX
     SIZE 24.38 BY .79 NO-UNDO.

DEFINE VARIABLE tb-parts AS LOGICAL INITIAL no 
     LABEL "По партиям" 
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .79 NO-UNDO.

DEFINE VARIABLE tb-pay-desk AS LOGICAL INITIAL no 
     LABEL "По кассе" 
     VIEW-AS TOGGLE-BOX
     SIZE 12.25 BY .79 NO-UNDO.

DEFINE VARIABLE tb-pay-desk-cards AS LOGICAL INITIAL no 
     LABEL "По префиксам карт" 
     VIEW-AS TOGGLE-BOX
     SIZE 22 BY .79 NO-UNDO.

DEFINE VARIABLE tb-supp AS LOGICAL INITIAL no 
     LABEL "Остатки по поставщикам" 
     VIEW-AS TOGGLE-BOX
     SIZE 26.75 BY .79 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.25 COL 1.63
     Btn_Cancel AT ROW 1.25 COL 11.63
     b-help AT ROW 1.25 COL 47
     date_from AT ROW 3.13 COL 8.25 COLON-ALIGNED
     date_to AT ROW 3.13 COL 25.25 COLON-ALIGNED
     tb-supp AT ROW 4.5 COL 10.38
     ed-object AT ROW 4.96 COL 20.75 NO-LABEL
     rs-1 AT ROW 5.04 COL 3 NO-LABEL
     bt-sel-obj AT ROW 7.21 COL 17
     ed-doc-type AT ROW 9.21 COL 16.75 NO-LABEL
     bt-sel-doc-type AT ROW 9.21 COL 53.25
     ed-doc-type-label AT ROW 9.25 COL 3 NO-LABEL
     tb-inkass-pay-code AT ROW 11.5 COL 2.63
     tb-deleted AT ROW 11.5 COL 36.63
     tb-cst-code AT ROW 12.25 COL 2.63
     tb-exp-checks AT ROW 12.25 COL 36.63 WIDGET-ID 2
     tb-exp-doc-rvs AT ROW 13 COL 36.63
     tb-parts AT ROW 13 COL 2.63
     tb-chk-pay-code AT ROW 13.75 COL 2.63
     rs-cash-pay AT ROW 13.79 COL 40 NO-LABEL
     tb-pay-desk AT ROW 14.67 COL 5.63
     bt-cash-pay AT ROW 14.71 COL 48
     tb-pay-desk-cards AT ROW 15.5 COL 5.63
     EDITOR-gds-grp AT ROW 17.42 COL 18 NO-LABEL WIDGET-ID 12
     RADIO-SET-gds-grp AT ROW 18.13 COL 3 NO-LABEL WIDGET-ID 8
     bt-sel-gds-grp AT ROW 19.08 COL 14 WIDGET-ID 14
     v-text-goods AT ROW 16.71 COL 2 NO-LABEL WIDGET-ID 4
     RECT-2 AT ROW 9.04 COL 2
     RECT-1 AT ROW 4.42 COL 1.75
     RECT-3 AT ROW 11.42 COL 2
     RECT-gds AT ROW 16.96 COL 2 WIDGET-ID 16
     SPACE(0.99) SKIP(0.28)
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
       bt-cash-pay:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN 
       ed-doc-type:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR EDITOR ed-doc-type-label IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       ed-doc-type-label:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR EDITOR ed-object IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       EDITOR-gds-grp:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN 
       rs-cash-pay:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX tb-supp IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       tb-supp:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN v-text-goods IN FRAME Dialog-Frame
   ALIGN-L                                                              */
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


&Scoped-define SELF-NAME bt-cash-pay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-cash-pay Dialog-Frame
ON CHOOSE OF bt-cash-pay IN FRAME Dialog-Frame /* ... */
DO:
    run ref/cashpays.w (
         INPUT parparentproc
        ,INPUT "b-sel,b-mark":U
        ,input v-bge-dper-host-code
        ,input v-bge-dper-store-type
        ,input v-bge-dper-store-code
        ,OUTPUT p-pay-type-list
        ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-doc-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-doc-type Dialog-Frame
ON CHOOSE OF bt-sel-doc-type IN FRAME Dialog-Frame /* ... */
DO:

    define variable v-cancel     as logical           no-undo.
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
        if p-doc-type-list = ''
        then do:
            assign
                ed-doc-type :screen-value in frame Dialog-Frame = "Все"
            .
        end.
        else do:
            assign
                ed-doc-type :screen-value in frame Dialog-Frame = ''
            .
            for each temp_ext-doc-type
            :
                if lookup( temp_ext-doc-type.ext-doc-type, p-init-doc-type-list ) <> 0
                then do:
                    assign
                        ed-doc-type :screen-value in frame Dialog-Frame = ed-doc-type :screen-value in frame Dialog-Frame
                                                    + temp_ext-doc-type.ext-doc-type-label + {&new-line}
                    .
                end.
            end.
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-gds-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-gds-grp Dialog-Frame
ON CHOOSE OF bt-sel-gds-grp IN FRAME Dialog-Frame /* ... */
DO:
    define variable v-ii as integer no-undo.
    define variable v-Grp_Name as character no-undo.
    define variable v-grp-recid-list as character no-undo.
    
    run ref/gds-grp.w (
     input parparentproc
    ,input "b-sel,b-mark"
    ,input v-cntxt-obj-type
    ,input v-cntxt-obj-code
    ,input-output v-grp-recid-list).

    EDITOR-gds-grp:screen-value = "".
    /*p-gds-grp-list = "".*/

    do v-ii = 1 to num-entries(v-grp-recid-list):
        find buf_gds-grp where recid (buf_gds-grp) = integer(entry(v-ii, v-grp-recid-list)) no-lock.
        run grplib-get-full-name in this-procedure( input buf_gds-grp.node-code, output v-Grp_Name).
            EDITOR-gds-grp:screen-value = EDITOR-gds-grp:screen-value + v-Grp_Name + {&new-line}.
      /*  p-gds-grp-list = p-gds-grp-list + string(buf_gds-grp.node-code) + {&delim-par}.*/
    end.
    
    /*p-gds-grp-list = trim(p-gds-grp-list, {&delim-par}).*/
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-obj Dialog-Frame
ON CHOOSE OF bt-sel-obj IN FRAME Dialog-Frame /* ... */
DO:
   define variable v-host-code like ub.sysconf.host-code no-undo .
    assign
        rs-1 :screen-value  = "3"
    .

    define variable v-object-available as logical   no-undo .

    { gbl/uobjclr.i }

    { gbl/usobjava.i
      v-cntxt-db-num
      {&action-head-code-main}
      v-cntxt-userid
      v-bge-dper-store-type
      v-bge-dper-store-code
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
        v-bge-dper-store-type
        v-bge-dper-store-code
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
    for each temp_obj-list:
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
        v-obj-list = ""
    .
    for each temp_obj-list
    :
        assign v-obj-list = v-obj-list + (if v-obj-list <> "" then ", " else "" )
                                    + temp_obj-list.obj-type + string( temp_obj-list.obj-code ).
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
        tb-exp-checks
        tb-exp-doc-rvs
        rs-1
        tb-chk-pay-code
        tb-pay-desk
        tb-pay-desk-cards
        date_exp_from = date_from
        date_exp_to   = date_to
        /*!!!*/
    .
    assign
      p-chk = tb-exp-checks
      p-doc-rvs = tb-exp-doc-rvs
    .
    if date_from > date_to
    and p-output-type <> 4
    and p-output-type <> 5
    then do:
        message
            "Даты интервала заданы неверно. "
            skip " Нижняя дата интервала должна быть меньше верхней."
            skip(1) "Задайте интервал дат правильно или отмените экспорт."
        view-as alert-box information.
        apply "entry" to date_from.
        undo, return no-apply.
    end.
    if p-output-type = 0
    then do:
      case rs-1 :screen-value
      :
      when "1"
      then do:
          assign
              p-range = 1
              p-obj-list = ""
          .
      end.
      when "2"
      then do:
          assign
              p-range = 2
              p-obj-list = ""
          .
      end.
      when "3"
      then do:
          assign
              p-range = 3
          .
          assign
              p-obj-list = ""
          .
          for each temp_obj-list
          :
              assign
                  p-obj-list = p-obj-list
                          + ( if p-obj-list = "" then "" else "," ) + temp_obj-list.obj-type
                          + "," + string( temp_obj-list.obj-code )
              .
          end.
      end.
      end case.
    end.
    if p-output-type = 2
    then do:
        assign
            p-cst = tb-supp
            p-range     = 2
            p-host-code = v-bge-dper-host-code
            p-obj-list  = ""
        .
    end.
    if p-output-type = 1
    or p-output-type = 3
    or p-output-type = 4
    or p-output-type = 5
    or p-output-type = 6
    then do:
        if p-output-type = 1 or p-output-type = 4 
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
                p-obj-list = ""
            .
        end.
        when "2"
        then do:
            assign
                p-range = 2
                p-host-code = v-bge-dper-host-code
                p-obj-list = ""
            .
        end.
        when "3"
        then do:
            assign
                p-range = 3
            .
            assign
                p-obj-list = ""
            .
            for each temp_obj-list
            :
                assign
                    p-obj-list = p-obj-list
                            + ( if p-obj-list = "" then "" else "," ) + temp_obj-list.obj-type
                            + "," + string( temp_obj-list.obj-code )
                .
            end.
        end.
        end case.
    end.        /* p-output-type = 1 */
    run flt-save in this-procedure .
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
ON RETURN OF date_to IN FRAME Dialog-Frame /* по */
DO:
    APPLY "ENTRY" TO btn_OK IN FRAME {&FRAME-NAME}.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-SET-gds-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-SET-gds-grp Dialog-Frame
ON VALUE-CHANGED OF RADIO-SET-gds-grp IN FRAME Dialog-Frame
DO:
  assign RADIO-SET-gds-grp.
  if RADIO-SET-gds-grp = 1 then do:
      bt-sel-gds-grp :visible in frame {&frame-name} = no.
      /*p-gds-grp-list = "".*/
      EDITOR-gds-grp:screen-value = "".
  end.
  else do:
      bt-sel-gds-grp :visible in frame {&frame-name} = yes.
      apply "CHOOSE" to bt-sel-gds-grp.
  end.
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


&Scoped-define SELF-NAME rs-cash-pay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-cash-pay Dialog-Frame
ON VALUE-CHANGED OF rs-cash-pay IN FRAME Dialog-Frame
DO:
  bt-cash-pay :SENSITIVE IN FRAME {&frame-name} = LOGICAL(rs-cash-pay:SCREEN-VALUE IN FRAME {&frame-name}).
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
    rs-cash-pay :SENSITIVE IN FRAME {&frame-name} = tb-chk-pay-code.
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

ASSIGN
    date_from = v-today
    date_to   = v-today
.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    run cur-time in this-procedure (
        output v-today
        , output v-time
    ).
    { gbl/getcntxt.i get }
    assign
        v-bge-dper-host-code  = v-cntxt-host-code-obj
        v-bge-dper-store-type = v-cntxt-obj-type
        v-bge-dper-store-code = v-cntxt-obj-code
    .
    { gbl/hostcode.i
        v-bge-dper-store-type
        v-bge-dper-store-code
        v-bge-dper-host-code
    }
    run get-host-name in this-procedure ( output v-host-name ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка при определении имени фирмы"
          skip "Код фирмы:" v-bge-dper-host-code
          skip "Имя фирмы будет отображаться как '" + {&cmp} + string( v-bge-dper-host-code ) + "'"
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box warning.
        assign
            v-host-name = {&cmp} + string( v-bge-dper-host-code )
        .
    end.
    run bge-xml-init-ext-doc-type in this-procedure .
    RUN enable_UI.

    IF p-output-type = 6
    THEN DO:
       ASSIGN
          bt-cash-pay:SENSITIVE IN FRAME {&frame-name} = FALSE
          rs-cash-pay:SENSITIVE IN FRAME {&frame-name} = FALSE
       .
    END.
    ELSE DO:
       HIDE
          bt-cash-pay
          rs-cash-pay
       .
    END.
    if p-output-type = 0
    or p-output-type = 2
    or p-output-type = 3
    or p-output-type = 5
    or p-output-type = 6
    then do:
        assign
            ed-doc-type :screen-value = {&new-line} + "    Все"
        .
        disable ed-doc-type.
        hide
            bt-sel-doc-type
            tb-inkass-pay-code
            tb-cst-code
            tb-parts
            tb-pay-desk
            tb-pay-desk-cards
            tb-deleted
        .

        if  p-output-type <> 6
        then do:
            hide
            tb-chk-pay-code
            .
        END.

        if p-output-type <> 3
        AND p-output-type <> 6
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
        assign
            ed-doc-type :screen-value = {&new-line} + "    Все"
        .
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
            date_from
            RECT-2
            ed-doc-type
            ed-doc-type-label
        .
        if p-output-type = 5
        then do:
            hide
                date_to
            .
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
    
    if lookup(string(p-output-type), "2,4") = 0
        then do:
            hide
            v-text-goods
            RECT-gds
            EDITOR-gds-grp
            bt-sel-gds-grp
            RADIO-SET-gds-grp
            .
    end.

    run init-fields in this-procedure .

    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

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
          tb-chk-pay-code rs-cash-pay tb-pay-desk tb-pay-desk-cards tb-exp-doc-rvs
          EDITOR-gds-grp RADIO-SET-gds-grp v-text-goods 
      WITH FRAME Dialog-Frame.
  ENABLE RECT-2 RECT-1 RECT-3 RECT-gds Btn_OK Btn_Cancel b-help date_from 
         date_to rs-1 bt-sel-obj ed-doc-type bt-sel-doc-type tb-inkass-pay-code 
         tb-deleted tb-cst-code tb-exp-checks tb-parts tb-chk-pay-code tb-exp-doc-rvs
         rs-cash-pay tb-pay-desk bt-cash-pay tb-pay-desk-cards EDITOR-gds-grp 
         RADIO-SET-gds-grp bt-sel-gds-grp v-text-goods 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE flt-load Dialog-Frame 
PROCEDURE flt-load :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define variable v-obj-range      as integer   no-undo .
  define variable v-obj-list       as character no-undo .
  define variable v-doc-range      as integer   no-undo .
  define variable v-doc-list       as character no-undo .
  define variable v-userid         as character no-undo .
  define variable v-naim           as character no-undo .
  define variable v-list           as character no-undo .
  define variable v-print-graft    as logical   no-undo .
  define variable v-sort-gr        as logical   no-undo .
  define variable v-type-price     as logical   no-undo .
  define variable v-type-val       as logical   no-undo .
  define variable v-found          as logical   no-undo .
  define variable v-str            as character no-undo .
  define variable v-obj-tot        as integer   no-undo .
  define variable v-i              as integer   no-undo .
  define variable v-obj-type       as character no-undo .
  define variable v-obj-code       as integer   no-undo .

do
on error undo, return error return-value
:
  run uf-get (
      input   {&uf-bge-dper}
    , input   v-cntxt-userid
    , output  v-list
    , output  v-naim
    , output  v-print-graft
    , output  v-sort-gr
    , output  v-type-price
    , output  v-type-val
    ) .
  if num-entries(v-naim) = 12
  then do:
    assign
      date_from           = date(    entry( 1, v-naim ) )
      date_to             = date(    entry( 2, v-naim ) )
      tb-chk-pay-code     = logical( entry( 3, v-naim ) )
      tb-cst-code         = logical( entry( 4, v-naim ) )
      tb-deleted          = logical( entry( 5, v-naim ) )
      tb-exp-checks       = logical( entry( 6, v-naim ) )
      tb-inkass-pay-code  = logical( entry( 7, v-naim ) )
      tb-parts            = logical( entry( 8, v-naim ) )
      tb-pay-desk         = logical( entry( 9, v-naim ) )
      tb-pay-desk-cards   = logical( entry(10, v-naim ) )
      tb-supp             = logical( entry(11, v-naim ) )
      tb-exp-doc-rvs      = logical( entry(12, v-naim ) )
    .
    if tb-chk-pay-code = yes
    then do:
      enable
        tb-pay-desk
        tb-pay-desk-cards
      with frame {&frame-name}.
    end.
    display
      date_from    when not( p-output-type = 4 or p-output-type = 5)
      date_to
      tb-chk-pay-code
      tb-cst-code
      tb-deleted
      tb-exp-checks
      tb-exp-doc-rvs
      tb-inkass-pay-code
      tb-parts
      tb-pay-desk
      tb-pay-desk-cards
      tb-supp           when p-output-type = 2
    with frame {&frame-name}.
  end.
  if num-entries(v-list,';') = 2
  then do:
    assign
      v-str = entry( 1 , v-list, ';')
    .
    if num-entries(v-str,':') = 2
    then do:
      assign
        rs-1        = integer(entry(1, v-str, ':'))
        v-obj-list  = entry(2, v-str, ':')
        v-obj-tot   = num-entries(v-obj-list)
      .
      if rs-1 = 3 and v-obj-tot < 2
      then do:
        assign
          rs-1 = 1
        .
      end.
      run object-select in this-procedure .
      if rs-1:visible then
      display
        rs-1
      with frame {&frame-name}.
      if rs-1 = 3
      then do:
        if v-obj-tot modulo 2 = 0
        then do:
          for each temp_obj-list
          :
            delete temp_obj-list.
          end.
          do v-i = 1 to v-obj-tot / 2
          :
            assign
              v-obj-type = entry( v-i * 2 - 1, v-obj-list )
              v-obj-code = integer( entry( v-i * 2, v-obj-list ) )
            .
            find first temp_obj-list no-lock
              where temp_obj-list.obj-type = v-obj-type
                and temp_obj-list.obj-code = v-obj-code
            no-error .
            if not available temp_obj-list
            then do:
              create temp_obj-list.
              assign
                temp_obj-list.obj-type = v-obj-type
                temp_obj-list.obj-code = v-obj-code
              .
            end.
          end. /* do v-i = 1 to v-obj-tot / 2 */
          assign
            ed-object :screen-value in frame {&frame-name} = v-obj-list
          .
        end. /* if v-obj-tot modulo 2 = 0 */
      end. /* if rs-1 = 3 */
    end. /* if num-entries(v-str,':') = 2 */
    assign
      v-str = entry( 2 , v-list, ';')
    .
    if v-str = ''
    then do:
      assign
        ed-doc-type = "Все":u
      .
    end.
    else do:
      assign
        ed-doc-type = ''
      .
      for each temp_ext-doc-type
      :
        if lookup( temp_ext-doc-type.ext-doc-type, v-str ) <> 0
        then do:
          assign
            ed-doc-type = ed-doc-type + temp_ext-doc-type.ext-doc-type-label + {&new-line}
            p-doc-type-list = p-doc-type-list + temp_ext-doc-type.ext-doc-type + ','
          .
        end.
      end. /* for each temp_ext-doc-type */
      assign
        p-doc-type-list = trim(p-doc-type-list , ',')
      .
    end.
    display
      ed-doc-type
    with frame {&frame-name}.
  end. /* if num-entries(v-list,';') = 2 */
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE flt-save Dialog-Frame 
PROCEDURE flt-save :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define variable v-obj-range      as integer   no-undo .
  define variable v-obj-list       as character no-undo .
  define variable v-doc-range      as integer   no-undo .
  define variable v-doc-list       as character no-undo .
  define variable v-userid         as character no-undo .
  define variable v-naim           as character no-undo .
  define variable v-list           as character no-undo .
  define variable v-print-graft    as logical   no-undo .
  define variable v-sort-gr        as logical   no-undo .
  define variable v-type-price     as logical   no-undo .
  define variable v-type-val       as logical   no-undo .

do
on error undo, return error return-value
:
  assign frame {&frame-name}
    date_from
    date_to
    tb-chk-pay-code
    tb-cst-code
    tb-deleted
    tb-exp-checks
    tb-exp-doc-rvs
    tb-inkass-pay-code
    tb-parts
    tb-pay-desk
    tb-pay-desk-cards
    tb-supp
    rs-1
  .

  case rs-1 :screen-value
  :
  when "1"
  then do:
      assign
          v-obj-range = 1
          v-obj-list = ""
      .
  end.
  when "2"
  then do:
      assign
          v-obj-range = 2
          v-obj-list = ""
      .
  end.
  when "3"
  then do:
      assign
          v-obj-range = 3
      .
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
  assign
    v-naim       = string(date_from         ) + "," +
                   string(date_to           ) + "," +
                   string(tb-chk-pay-code   ) + "," +
                   string(tb-cst-code       ) + "," +
                   string(tb-deleted        ) + "," +
                   string(tb-exp-checks     ) + "," +
                   string(tb-inkass-pay-code) + "," +
                   string(tb-parts          ) + "," +
                   string(tb-pay-desk       ) + "," +
                   string(tb-pay-desk-cards ) + "," +
                   string(tb-supp           ) + "," +
                   string(tb-exp-doc-rvs    )
    v-list       = substitute( "&1:&2;&3"
                             , v-obj-range
                             , v-obj-list
                             , p-doc-type-list
                             )
  .
  run uf-set ( input {&uf-bge-dper}
             , input v-cntxt-userid
             , input v-list
             , input v-naim
             , input v-print-graft
             , input v-sort-gr
             , input v-type-price
             , input v-type-val
             ) .

end.
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

define buffer buf_clients   for ub.clients.

    find first buf_clients no-lock
         where buf_clients.obj-type = {&cmp}
           and buf_clients.obj-code = v-bge-dper-host-code
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
    run manage-tb-chk-pay-code in this-procedure.
    assign
        p-doc-type-list = p-init-doc-type-list
    .
    assign
        rs-1 :screen-value in frame dialog-frame = "2"
        ed-object :screen-value in frame Dialog-frame = {&cmp} + string( v-bge-dper-host-code ) + " " + v-host-name
    .
    assign
        rs-1
    .
    if p-init-doc-type-list <> ?
    and p-init-doc-type-list <> ''
    then do:
        for each temp_ext-doc-type
        :
            if lookup( temp_ext-doc-type.ext-doc-type, p-init-doc-type-list ) <> 0
            then do:
                assign
                    ed-doc-type :screen-value in frame Dialog-Frame = ed-doc-type :screen-value in frame Dialog-Frame
                                                + temp_ext-doc-type.ext-doc-type-label + {&new-line}
                .
            end.
        end.
    end.
    assign
      date_to = today
    .
    display
      date_to
    with frame {&frame-name}.
    run flt-load in this-procedure .
end.
END PROCEDURE.

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
do
on error undo, return error
:

case rs-1 :screen-value in frame Dialog-frame
:
    when "1"
    then do:
        assign
            ed-object :screen-value = ""
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
            temp_obj-list.obj-type  = v-bge-dper-store-type
            temp_obj-list.obj-code  = v-bge-dper-store-code
            ed-object :screen-value = v-bge-dper-store-type + string( v-bge-dper-store-code )
        .
    end.
end case.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

