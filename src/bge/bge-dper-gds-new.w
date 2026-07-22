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
                                        6 - то же, что и 3, но с выботом типа платежей
    p-init-doc-type-list as character    - список типов документов
Output:
    date_exp_from  as date          - Дата с
    date_exp_to    as date          - Дата по
    p-range        as integer       - Диапазон: 1 - глобально, 2 - по фирме, 3 - список объектов
    p-host-code    as integer       - Код текущей фирмы для p-range = 2
    p-obj-list     as character     - для p-range = 3, список ( "маг,3,скл,20,скл,2" )
    p-pay-type-list AS CHARACTER    - список типов платежей ("[RECID(cash-pay)][,RECID(cash-pay)]...)
    p-doc-type-list as character    - список типов документов
    p-gds-type      as character    - тип товара all/fuel/other
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
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE   NO-UNDO .
DEFINE INPUT PARAMETER p-curr-host-code LIKE ub.sysconf.host-code NO-UNDO .
DEFINE INPUT PARAMETER p-curr-obj-type  LIKE ub.clients.obj-type  NO-UNDO .
DEFINE INPUT PARAMETER p-curr-obj-code  LIKE ub.clients.obj-code  NO-UNDO .
DEFINE INPUT PARAMETER p-mode           AS CHARACTER    NO-UNDO.
DEFINE INPUT PARAMETER p-db-num-char    AS CHARACTER    NO-UNDO.
DEFINE INPUT PARAMETER p-task-type      AS CHARACTER    NO-UNDO.
DEFINE INPUT PARAMETER p-task-num       AS INTEGER      NO-UNDO.
DEFINE INPUT PARAMETER p-action         AS CHARACTER    NO-UNDO.
DEFINE OUTPUT PARAMETER p-cancel        AS LOGICAL      NO-UNDO.
DEFINE OUTPUT PARAMETER p-params        AS CHARACTER    NO-UNDO.

define variable v-dc-num-full    as char      init "" no-undo.
define variable chr-list-chk-type as char no-undo.
define variable v-list-chk-type as character no-undo.
define variable p-rs-2 as char no-undo.
define variable date_exp_from    as date      format "99/99/9999" no-undo.
define variable date_exp_to      as date      format "99/99/9999" no-undo.
define variable p-range          as integer   no-undo.
define variable p-host-code      as integer   no-undo.
define variable p-obj-list       as character no-undo.
define variable p-pay-type-list  as character no-undo . /* список recid'ов выбранных записей cash-pay */
define variable p-gds-type       as character init 'all' no-undo.  /* тип товара all/fuel/other*/
define variable p-doc-type-list  as character no-undo.
define variable p-pay-code       as logical   INIT no no-undo.
define variable p-cst            as logical   INIT no no-undo.
define variable p-parts          as logical   INIT no no-undo.
define variable p-chk-pay-code   as logical   INIT no no-undo.
define variable p-pay-desk       as logical   INIT no no-undo.
define variable p-pay-desk-cards as logical   INIT no no-undo.
define variable p-deleted        as logical   INIT no no-undo.
define variable p-chk            as logical   INIT no no-undo.

define stream StreamLog.

define variable p-output-type        as integer   init 6 no-undo.
define variable p-init-doc-type-list as character init "" no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision         as character no-undo init "$Revision$":U .
define variable vss-author           as character no-undo init "$Author$":U .
define variable vss-date             as character no-undo init "$Date$":U .
define variable vss-workfile         as character no-undo init "$Workfile$":U .
define variable vss-archive          as character no-undo init "$Archive$":U .
define variable vss-description      as character no-undo init "Выбор параметров для выгрузки документов.".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }
{ bge/bge-xml.i  }
{ gbl/usr-flt.i  }
{ ref/shd-attr.i }

{ gbl/twowin.i    }

define variable v-param-list          as character no-undo.
define variable v-param-type          as character no-undo.
define variable v-bge-dper-host-code  as integer   no-undo.
define variable v-bge-dper-store-type as character no-undo.
define variable v-bge-dper-store-code as integer   no-undo.

define variable v-obj-list            as character no-undo.
define variable v-host-name           as character no-undo.
define variable v-today               as date      no-undo.
define variable v-time                as integer   no-undo.

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
&Scoped-Define ENABLED-OBJECTS RECT-2 RECT-1 RECT-3 RECT-5 RECT-6 RECT-7 ~
RECT-8 btn_save Btn_start Btn_Cancel b-help v-per code_pool date_from ~
date_to bt-dc-card rs-1 v-dc-card bt-sel-obj ed-doc-type bt-sel-doc-type ~
tb-inkass-pay-code tb-deleted v-place tb-cst-code tb-exp-checks tb-parts ~
tb-chk-pay-code rs-cash-pay v-directory tb-pay-desk bt-cash-pay ~
v-ftp-address tb-pay-desk-cards v-inf-bonus v-login v-password rs-2 ~
list-chk-type b-chk-type 
&Scoped-Define DISPLAYED-OBJECTS v-per code_pool date_from date_to ~
time-days ed-object rs-1 v-dc-card ed-doc-type ed-doc-type-label ~
tb-inkass-pay-code tb-deleted v-place tb-cst-code tb-exp-checks tb-parts ~
tb-chk-pay-code rs-cash-pay v-directory tb-pay-desk v-ftp-address ~
tb-pay-desk-cards v-inf-bonus v-login v-password ed-doc-type-label-2 rs-2 ~
list-chk-type 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-chk-type 
     LABEL "Выбор" 
     SIZE 15 BY 1.13.

DEFINE BUTTON b-help 
     LABEL "Помо&щь" 
     SIZE 10 BY 1.

DEFINE BUTTON bt-cash-pay 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..." 
     SIZE 3.63 BY 1.04.

DEFINE BUTTON bt-dc-card 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Дисконтные карты" 
     SIZE 3.63 BY 1.04.

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

DEFINE BUTTON btn_save 
     LABEL "Сохранить" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_start 
     LABEL "&Запустить" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE ed-doc-type AS CHARACTER INITIAL "Все" 
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-VERTICAL NO-BOX
     SIZE 35.75 BY 1.79 NO-UNDO.

DEFINE VARIABLE ed-doc-type-label AS CHARACTER INITIAL "Типы документов" 
     VIEW-AS EDITOR NO-BOX
     SIZE 12.63 BY 1.75 NO-UNDO.

DEFINE VARIABLE ed-doc-type-label-2 AS CHARACTER INITIAL "Выборка по товарам:" 
     VIEW-AS EDITOR NO-BOX
     SIZE 36 BY .71 NO-UNDO.

DEFINE VARIABLE ed-object AS CHARACTER 
     VIEW-AS EDITOR NO-BOX
     SIZE 35.63 BY 3.38
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE time-days AS CHARACTER INITIAL "дней" 
     VIEW-AS EDITOR NO-BOX
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE v-dc-card AS CHARACTER 
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 35.5 BY 4.75 NO-UNDO.

DEFINE VARIABLE code_pool AS CHARACTER FORMAT "X(256)":U 
     LABEL "ПНПО" 
     VIEW-AS FILL-IN 
     SIZE 25 BY 1 NO-UNDO.

DEFINE VARIABLE date_from AS DATE FORMAT "99/99/9999":U 
     LABEL "Дата с" 
     VIEW-AS FILL-IN 
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE date_to AS DATE FORMAT "99/99/9999":U 
     LABEL "по" 
     VIEW-AS FILL-IN 
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE fi-pack-lim AS INT64 FORMAT ">,>>9":U 
     LABEL "Макс.размер файла (Мб)" 
     VIEW-AS FILL-IN 
     SIZE 11 BY 1 TOOLTIP "После достижения заданного размера создаётся следующий файл" NO-UNDO.

DEFINE VARIABLE v-directory AS CHARACTER FORMAT "X(256)":U 
     LABEL "Директория" 
     VIEW-AS FILL-IN 
     SIZE 25 BY 1 NO-UNDO.

DEFINE VARIABLE v-ftp-address AS CHARACTER FORMAT "X(256)":U 
     LABEL "FTP" 
     VIEW-AS FILL-IN 
     SIZE 25 BY 1 NO-UNDO.

DEFINE VARIABLE v-login AS CHARACTER FORMAT "X(256)":U 
     LABEL "Логин" 
     VIEW-AS FILL-IN 
     SIZE 25 BY 1 NO-UNDO.

DEFINE VARIABLE v-password AS CHARACTER FORMAT "X(256)":U 
     LABEL "Пароль" 
     VIEW-AS FILL-IN 
     SIZE 25 BY 1 NO-UNDO.

DEFINE VARIABLE v-per AS INTEGER FORMAT "->,>>>,>>9" INITIAL 0 
     LABEL "За последние" 
     VIEW-AS FILL-IN 
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE rs-1 AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "глобально", 1,
"по фирме", 2,
"по объектам", 3
     SIZE 13.75 BY 3.25 NO-UNDO.

DEFINE VARIABLE rs-2 AS CHARACTER INITIAL "all" 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Все", "all",
"Топливо", "fuel",
"Товары/Услуги", "other"
     SIZE 41 BY .96 NO-UNDO.

DEFINE VARIABLE rs-cash-pay AS LOGICAL 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Все", no,
"Выбор", yes
     SIZE 9 BY 1.88 NO-UNDO.

DEFINE VARIABLE v-place AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Локальная директория", 1,
"FTP", 2
     SIZE 34.5 BY 1.75 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 55.38 BY 4.38.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 55.25 BY 2.21.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 55.25 BY 6.58.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 55 BY 2.5.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 39.5 BY 9.25.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 40 BY 6.75.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 55 BY 4.75.

DEFINE VARIABLE list-chk-type AS CHARACTER 
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL 
     SIZE 23.5 BY 3 NO-UNDO.

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
     SIZE 19.38 BY .79 NO-UNDO.

DEFINE VARIABLE tb-exp-checks AS LOGICAL INITIAL no 
     LABEL "Чеки" 
     VIEW-AS TOGGLE-BOX
     SIZE 18.38 BY .79 NO-UNDO.

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

DEFINE VARIABLE v-inf-bonus AS LOGICAL INITIAL no 
     LABEL "Выгружать информацию по бонусам" 
     VIEW-AS TOGGLE-BOX
     SIZE 41 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     btn_save AT ROW 1.25 COL 1.5
     Btn_start AT ROW 1.25 COL 1.63
     Btn_Cancel AT ROW 1.25 COL 11.63
     b-help AT ROW 1.5 COL 86
     v-per AT ROW 3 COL 15 COLON-ALIGNED WIDGET-ID 20
     code_pool AT ROW 3 COL 62 COLON-ALIGNED WIDGET-ID 28
     date_from AT ROW 3.14 COL 8.2 COLON-ALIGNED
     date_to AT ROW 3.14 COL 25.2 COLON-ALIGNED
     time-days AT ROW 3.14 COL 28 NO-LABEL WIDGET-ID 52
     tb-supp AT ROW 4.52 COL 10.4
     bt-dc-card AT ROW 4.76 COL 77.6 WIDGET-ID 42
     ed-object AT ROW 4.95 COL 20.8 NO-LABEL
     rs-1 AT ROW 5.05 COL 3 NO-LABEL
     v-dc-card AT ROW 6.24 COL 58.6 NO-LABEL WIDGET-ID 40
     bt-sel-obj AT ROW 7.19 COL 17
     ed-doc-type AT ROW 9.19 COL 16.8 NO-LABEL
     bt-sel-doc-type AT ROW 9.19 COL 53.2
     ed-doc-type-label AT ROW 9.24 COL 3 NO-LABEL
     tb-inkass-pay-code AT ROW 11.52 COL 2.6
     tb-deleted AT ROW 11.52 COL 36.6
     v-place AT ROW 11.76 COL 59.6 NO-LABEL WIDGET-ID 22
     tb-cst-code AT ROW 12.24 COL 2.6
     tb-exp-checks AT ROW 12.24 COL 36.6 WIDGET-ID 2
     tb-parts AT ROW 13 COL 2.6
     tb-chk-pay-code AT ROW 13.76 COL 2.6
     rs-cash-pay AT ROW 13.81 COL 40.7 NO-LABEL
     v-directory AT ROW 14 COL 69 COLON-ALIGNED WIDGET-ID 54
     tb-pay-desk AT ROW 14.67 COL 5.63
     bt-cash-pay AT ROW 14.71 COL 48
     v-ftp-address AT ROW 15.25 COL 69 COLON-ALIGNED WIDGET-ID 14
     tb-pay-desk-cards AT ROW 15.5 COL 5.63
     v-inf-bonus AT ROW 16.5 COL 2.5 WIDGET-ID 26
     v-login AT ROW 16.5 COL 69 COLON-ALIGNED WIDGET-ID 16
     v-password AT ROW 17.75 COL 69 COLON-ALIGNED WIDGET-ID 18
     ed-doc-type-label-2 AT ROW 18.5 COL 3 NO-LABEL WIDGET-ID 12
     rs-2 AT ROW 19.5 COL 3 NO-LABEL WIDGET-ID 6
     list-chk-type AT ROW 22.25 COL 3 NO-LABEL WIDGET-ID 64
     b-chk-type AT ROW 22.25 COL 27.5 WIDGET-ID 60
     "Типы чеков:" VIEW-AS TEXT
          SIZE 23.5 BY .92 AT ROW 21.25 COL 3 WIDGET-ID 62
     "Дисконтные карты" VIEW-AS TEXT
          SIZE 18.5 BY .75 AT ROW 5 COL 59 WIDGET-ID 44
     RECT-2 AT ROW 9.04 COL 2
     RECT-1 AT ROW 4.42 COL 1.75
     RECT-3 AT ROW 11.42 COL 2
     RECT-5 AT ROW 18.25 COL 2 WIDGET-ID 4
     RECT-6 AT ROW 11.5 COL 58 WIDGET-ID 46
     RECT-7 AT ROW 4.5 COL 57.5 WIDGET-ID 48
     RECT-8 AT ROW 21 COL 2 WIDGET-ID 66
     SPACE(60.37) SKIP(3.62)
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

/* SETTINGS FOR EDITOR ed-doc-type-label-2 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       ed-doc-type-label-2:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR EDITOR ed-object IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       rs-cash-pay:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX tb-supp IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       tb-supp:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR EDITOR time-days IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       time-days:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

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


&Scoped-define SELF-NAME b-chk-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chk-type Dialog-Frame
ON CHOOSE OF b-chk-type IN FRAME Dialog-Frame /* Выбор */
DO:
        run chk-type-choose in this-procedure.
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
            ,input {&all} 
            ,input v-bge-dper-host-code
            ,input v-bge-dper-store-type
            ,input v-bge-dper-store-code
            ,OUTPUT p-pay-type-list
            ).
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-dc-card
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-dc-card Dialog-Frame
ON CHOOSE OF bt-dc-card IN FRAME Dialog-Frame /* Дисконтные карты */
DO:
        define variable i        as integer   init 1 no-undo.
        define variable p-num    as integer   no-undo.
        define variable v-dc-num as char      init "" no-undo.
        define variable v-rid    as character no-undo.
        define buffer buf_dis-card for ub.dis-card .
        run ref/discards.w
            ( parParentProc
            ,input "b-sel,b-mark":U
            , {&all}
            , v-cntxt-host-code-obj
            , v-cntxt-obj-type
            , v-cntxt-obj-code
            , ?
            , ?
            , output v-rid
            ) .


        p-num = num-entries(v-rid).

        if v-rid = ""
            then 
        do:
            RETURN.
        end.
        v-dc-num-full = " ".
        v-dc-card:SCREEN-VALUE  =  " ".
        do while i <> p-num + 1 : 
            find first  buf_dis-card where  recid( buf_dis-card ) = INTEGER(ENTRY(i, v-rid))  no-lock no-error.
            assign
                v-dc-num                = STRING(buf_dis-card.d-card)
                v-dc-num-full           = STRING(buf_dis-card.d-card) + ',' + v-dc-num-full 
                v-dc-card :SCREEN-VALUE = v-dc-num +  {&NEW-LINE} + v-dc-card :SCREEN-VALUE.
         
            .
            i = i + 1.
        end.
        i = 1.
    
    end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-doc-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-doc-type Dialog-Frame
ON CHOOSE OF bt-sel-doc-type IN FRAME Dialog-Frame /* ... */
DO:

        define variable v-cancel as logical no-undo.
        run bge/bgeseltp.w (
            input "trn-doc":U
            , input p-init-doc-type-list
            , output p-doc-type-list
            , output v-cancel
            ) no-error.
        if error-status :error
            then 
        do:
            message
                vss-workfile vss-revision vss-description
                skip 
                "Ошибка выбора типов операций."
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
            then 
        do:
            assign
                p-doc-type-list = p-init-doc-type-list
                .
        end.
        else 
        do:
            assign
                p-init-doc-type-list = p-doc-type-list
                .
            if p-doc-type-list = ''
                then 
            do:
                assign
                    ed-doc-type :screen-value in frame Dialog-Frame = "Все"
                    .
            end.
            else 
            do:
                assign
                    ed-doc-type :screen-value in frame Dialog-Frame = ''
                    .
                for each temp_ext-doc-type
                    :
                    if lookup( temp_ext-doc-type.ext-doc-type, p-init-doc-type-list ) <> 0
                        then 
                    do:
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


&Scoped-define SELF-NAME bt-sel-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-obj Dialog-Frame
ON CHOOSE OF bt-sel-obj IN FRAME Dialog-Frame /* ... */
DO:
        define variable v-host-code like ub.sysconf.host-code no-undo .
        assign
            rs-1 :screen-value = "3"
            .

        define variable v-object-available as logical no-undo .

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
            then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры gbl/usobjava.i" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            undo, return no-apply .
        end.

        if v-object-available = true
            then 
        do:
            { gbl/uobjapnd.i
        v-bge-dper-store-type
        v-bge-dper-store-code
      }
        end.

        define variable v-user-select as logical no-undo .
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
            then 
        do:
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
            assign 
                v-obj-list = v-obj-list + (if v-obj-list <> "" then ", " else "" )
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


&Scoped-define SELF-NAME btn_save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_save Dialog-Frame
ON CHOOSE OF btn_save IN FRAME Dialog-Frame /* Сохранить */
DO:
        DEFINE VARIABLE l-dircrt AS LOGICAL. /* Для ответа на создание директории */
        /*        run check-param no-error.                                                       */

        ASSIGN
            v-directory
            v-ftp-address 
            v-login   
            v-password  
            v-place
            fi-pack-lim = 90
            date_from
            date_to
            tb-inkass-pay-code
            tb-cst-code
            tb-parts
            tb-deleted
            tb-supp
            tb-exp-checks
            rs-1
            rs-2
            tb-chk-pay-code
            tb-pay-desk
            tb-pay-desk-cards
            v-per
            code_pool
            v-inf-bonus.
        date_exp_from = date_from.
        date_exp_to   = date_to.
        /*!!!*/
        .
        assign
            p-chk      = tb-exp-checks
            p-gds-type = rs-2
            .
        if date_from > date_to
            and p-output-type <> 4
            and p-output-type <> 5
            then 
        do:
            message
                "Даты интервала заданы неверно. "
                skip 
                " Нижняя дата интервала должна быть меньше верхней."
                skip(1) "Задайте интервал дат правильно или отмените экспорт."
                view-as alert-box information.
            apply "entry" to date_from.
            undo, return no-apply.
        end.
        if p-output-type = 0
            then 
        do:
            case rs-1 :screen-value
                :
                when "1"
                then 
                    do:
                        assign
                            p-range    = 1
                            p-obj-list = ""
                            .
                    end.
                when "2"
                then 
                    do:
                        assign
                            p-range    = 2
                            p-obj-list = ""
                            .
                    end.
                when "3"
                then 
                    do:
                        assign
                            p-range    = 3
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
            then 
        do:
            assign
                p-cst       = tb-supp
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
            then 
        do:
            if p-output-type = 1
                then 
            do:
                assign
                    p-pay-code       = tb-inkass-pay-code
                    p-cst            = tb-cst-code
                    p-parts          = tb-parts
                    p-deleted        = tb-deleted
                    p-chk-pay-code   = tb-chk-pay-code
                    p-pay-desk       = tb-pay-desk
                    p-pay-desk-cards = tb-pay-desk-cards
                    .
            end.
            case rs-1 :screen-value
                :
                when "1"
                then 
                    do:
                        assign
                            p-range    = 1
                            p-obj-list = ""
                            .
                    end.
                when "2"
                then 
                    do:
                        assign
                            p-range     = 2
                            p-host-code = v-bge-dper-host-code
                            p-obj-list  = ""
                            .
                    end.
                when "3"
                then 
                    do:
                        assign
                            p-range    = 3
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
            
        if v-place = 2 then 
        do:
            IF trim(v-ftp-address) = '':U
                THEN 
            DO:
                message
                    "Не задано FTP адрес"
                    view-as alert-box error .
                return no-apply.
            END.
        end.
                    
        v-directory = right-trim(v-directory,'/\') + '\'.
        if v-place = 1 then 
        do: 
            /* Проверим каталог */
            file-info:file-name = v-directory.
    
            if file-info:file-type = ? then 
            do:
                message substitute("Директории &1 не существует.",v-directory) skip
                    "Создать?" view-as alert-box warning buttons yes-no update l-dircrt.
                if l-dircrt then 
                do:
                    os-create-dir value(v-directory).
                    if os-error <> 0 then 
                    do:
                        message substitute("Невозможно создать директорию &1",v-directory) view-as alert-box error.
                        leave.
                    end. /* if os-error <> 0 */
                end. /* if dir_crt */
                else leave.
            end. /* if file-info:file-type = ? */
    
            else 
            do:
                if not (file-info:file-type begins "D":U) then 
                do:
                    message substitute("&1 не является директорией.",v-directory) view-as alert-box error.
                    leave.
                end. /*if not */
            end. /* else */
        end.
  


  
        if v-place = 1 then   v-param-list =   string(v-place) + {&delim-par} + v-directory + {&delim-par} + string(v-per) +  {&delim-par} + string(p-range)
                +  {&delim-par} + string(p-host-code) +  {&delim-par} + p-obj-list 
                + {&delim-par} + p-pay-type-list +  {&delim-par} + p-gds-type +  {&delim-par} + p-doc-type-list  +
                {&delim-par} + v-dc-num-full + 
                {&delim-par} + string(v-inf-bonus) + {&delim-par} + code_pool + {&delim-par}  +  string(tb-pay-desk-cards)  + {&delim-par} +  string(tb-pay-desk)  + {&delim-par} +  string(tb-parts) + 
                {&delim-par} + string(tb-inkass-pay-code) + {&delim-par} + string(tb-deleted) + {&delim-par} + string(tb-chk-pay-code) + {&delim-par} +  string(tb-cst-code) + {&delim-par} + string(tb-exp-checks) + {&delim-par} + rs-2 + {&delim-par} + chr-list-chk-type
                .

        if v-place = 2 then 
        do:
     
            v-ftp-address = trim(trim(replace(v-ftp-address,'ftp:',""),{&slash-char}),{&back-slash-char}).
            v-param-list = string(v-place) + {&delim-par} +   v-ftp-address + {&delim-par}  + string(v-per) +  {&delim-par} + v-login   + {&delim-par} + v-password  + {&delim-par} + string(p-range)
                +  {&delim-par} + string(p-host-code) +  {&delim-par} + p-obj-list 
                + {&delim-par} + p-pay-type-list +  {&delim-par} + p-gds-type +  {&delim-par} + p-doc-type-list  +
                {&delim-par} + v-dc-num-full + 
                {&delim-par} + string(v-inf-bonus) + {&delim-par} + code_pool + {&delim-par} +  string(tb-pay-desk-cards)  + {&delim-par} +  string(tb-pay-desk)  + {&delim-par} +  string(tb-parts) + 
                {&delim-par} + string(tb-inkass-pay-code) + {&delim-par} + string(tb-deleted)  + {&delim-par} + string(tb-chk-pay-code) + {&delim-par} +  string(tb-cst-code) + {&delim-par} + string(tb-exp-checks)
                + {&delim-par} + rs-2 +  {&delim-par} + chr-list-chk-type
                .
        end.
  
        run attach-attr-to-schedule-line in this-procedure ( INPUT v-param-list ).

        run schedule-attr-write in this-procedure (input p-db-num-char, 
            input p-task-type,
            input p-task-num,
            input {&attr-schedule-obj-list-h},
            input v-obj-list).
   
    

        message "Параметры сохранены!" view-as alert-box information.

        apply "go".
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_start Dialog-Frame
ON CHOOSE OF Btn_start IN FRAME Dialog-Frame /* Запустить */
DO:
        DEFINE VARIABLE l-dircrt  AS LOGICAL       NO-UNDO. /* Для ответа на создание директории */
        define variable h-par     as widget-handle no-undo.
        DEFINE variable loghandle AS HANDLE        no-undo.
        DEFINE VARIABLE v-objects AS CHARACTER     NO-UNDO.
   
  
        ASSIGN
            v-directory
            v-place
            fi-pack-lim = 90
            date_from
            date_to
            tb-inkass-pay-code
            tb-cst-code
            tb-parts
            tb-deleted
            v-ftp-address
            v-login
            v-password
            tb-supp
            tb-exp-checks
            rs-1
            rs-2
            tb-chk-pay-code
            tb-pay-desk
            tb-pay-desk-cards
            v-per
            code_pool
            v-inf-bonus
        .
        assign
        date_exp_from = date_from
        date_exp_to   = date_to
        /*!!!*/
        .
 
        
        case v-place:
            WHEN 2 then do:
                    IF trim(v-ftp-address) > '':U THEN . 
                    ELSE DO:
                        message "Не задан FTP адрес" view-as alert-box error .
                        return no-apply.
                    END.
                end.
            OTHERWISE do:
                v-directory = right-trim(v-directory,'/\').
    
                /* Проверим каталог */
                file-info:file-name = v-directory.
            
                if file-info:file-name = " " then do:
                    MESSAGE "Укажите директорию для выгрузки" VIEW-AS ALERT-BOX ERROR.
                    leave.
                end.         
                IF FILE-INFO:FILE-type = ? THEN DO:
                    MESSAGE SUBSTITUTE("Директории &1 не существует.",v-directory) SKIP
                        "Создать?" VIEW-AS ALERT-BOX WARNING BUTTONS YES-NO UPDATE l-dircrt.
                    IF l-dircrt THEN DO:
                        OS-CREATE-DIR VALUE(v-directory).
                        IF OS-ERROR <> 0 THEN DO:
                            MESSAGE SUBSTITUTE("Невозможно создать директорию &1",v-directory) VIEW-AS ALERT-BOX ERROR.
                            leave.
                        END. /* if os-error <> 0 */
                    END. /* if dir_crt */
                    Else leave .
                END. /* if file-info:file-type = ? */
                ELSE DO:
                    IF NOT (FILE-INFO:file-type BEGINS "D":U) THEN DO:
                        MESSAGE SUBSTITUTE("&1 не является директорией.",v-directory) VIEW-AS ALERT-BOX ERROR.
                        leave.
                    END. /*if not */
                END. /* else */
                ASSIGN
                    v-ftp-address = "":U
                .
            end.
        END CASE. 
        FILE-INFO:FILE-NAME = v-directory.


        assign
            p-chk      = tb-exp-checks
            p-gds-type = rs-2
            .
        if date_from > date_to
            and p-output-type <> 4
            and p-output-type <> 5
            then 
        do:
            message
                "Даты интервала заданы неверно. "
                skip 
                " Нижняя дата интервала должна быть меньше верхней."
                skip(1) "Задайте интервал дат правильно или отмените экспорт."
                view-as alert-box information.
            apply "entry" to date_from.
            undo, return no-apply.
        end.
        if p-output-type = 0 then do:
            case rs-1 :screen-value :
                when "1" then assign
                            p-range    = 1
                            p-obj-list = ""
                            .
                when "2" then assign
                            p-range    = 2
                            p-obj-list = ""
                            .
                when "3" then do:
                        assign
                            p-range    = 3
                            p-obj-list = ""
                            .
                  for each temp_obj-list :
                    p-obj-list = p-obj-list + substitute(",&1,&2", temp_obj-list.obj-type, temp_obj-list.obj-code) .
                  end.
                  p-obj-list = substring(p-obj-list, 2) .
                end.
            end case.
        end.
        if p-output-type = 2 then 
        do:
            assign
                p-cst       = tb-supp
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
            then 
        do:
            if p-output-type = 1
                then 
            do:
                assign
                    p-pay-code       = tb-inkass-pay-code
                    p-cst            = tb-cst-code
                    p-parts          = tb-parts
                    p-deleted        = tb-deleted
                    p-chk-pay-code   = tb-chk-pay-code
                    p-pay-desk       = tb-pay-desk
                    p-pay-desk-cards = tb-pay-desk-cards
                    .
            end.
            case rs-1 :screen-value :
                when "1" then assign
                            p-range    = 1
                            p-obj-list = ""
                            .
                when "2" then assign
                            p-range     = 2
                            p-host-code = v-bge-dper-host-code
                            p-obj-list  = ""
                            .
                when "3" then do:
                        assign
                            p-range    = 3
                            p-obj-list = ""
                            .
                  for each temp_obj-list :
                    p-obj-list = p-obj-list + substitute(",&1,&2", temp_obj-list.obj-type, temp_obj-list.obj-code) .
                  end.
                  p-obj-list = substring(p-obj-list, 2) .
                end.
            end case.
            
            
        end.        /* p-output-type = 1 */

        if v-dc-card:screen-value = "" then v-dc-num-full = "".
            
        if v-place = 1  then  
            run bge\bgecheck-new.p ( this-procedure:handle
                , v-directory
                , v-place 
                , ""
                , "" 
                , fi-pack-lim
                , date_exp_from  
                , date_exp_to
            , p-range 
            , p-host-code
            , p-obj-list  
            , p-pay-type-list 
            , p-gds-type      
            , p-doc-type-list 
            ,  v-dc-num-full  
            , v-per
            , v-inf-bonus
            , code_pool,
            chr-list-chk-type                ) .       
           
        if v-place = 2  then 
            run bge\bgecheck-new.p ( this-procedure:handle
                , v-ftp-address
                , v-place
                , v-login
                , v-password
                , fi-pack-lim
                , date_exp_from  
                , date_exp_to
                , p-range 
                , p-host-code
                , p-obj-list  
                , p-pay-type-list 
                , p-gds-type      
                , p-doc-type-list  
                ,  v-dc-num-full 
                , v-per
                , v-inf-bonus
                , code_pool,
                chr-list-chk-type                   
                ) .
        /*        apply "go".*/
            
            
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
        APPLY "ENTRY" TO btn_start IN FRAME {&FRAME-NAME}.
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
            then 
        do:
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


&Scoped-define SELF-NAME v-place
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-place Dialog-Frame
ON VALUE-CHANGED OF v-place IN FRAME Dialog-Frame
DO:
        ASSIGN
            v-place
            .
        CASE v-place:
            WHEN 2
            THEN 
                DO:
                    DISABLE v-directory WITH FRAME Dialog-Frame.
                    ENABLE
                        v-ftp-address
                        v-login
                        v-password
                        WITH FRAME Dialog-Frame.
                    DISPLAY
                        v-ftp-address
                        v-login
                        v-password
                        WITH FRAME Dialog-Frame.
                END.
            OTHERWISE 
            DO:
                DISABLE
                    v-ftp-address
                    v-login
                    v-password
              
                    WITH FRAME Dialog-Frame.
                enable v-directory WITH FRAME Dialog-Frame.
                display v-directory WITH FRAME Dialog-Frame.
            END.
        END CASE.
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
        then 
    do:
        message
            vss-workfile vss-revision vss-description
            skip 
            "Ошибка при определении имени фирмы"
            skip 
            "Код фирмы:" v-bge-dper-host-code
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
   
    
    assign v-place
        /*        p-range = rs-1 */
        /*        p-host-code    */
        /*        p-obj-list     */
        /*        p-pay-type-list*/
        /*        p-gds-type     */
        /*        p-doc-type-list*/
        /*        v-dc-num-full  */
        /*        v-inf-bonus    */
        .
    if v-place = 1 then 
    do:
        disable v-ftp-address v-login v-password with frame {&FRAME-NAME}.    
                    
    end.
    if v-place = 2 then 
    do:
        disable v-directory with frame {&FRAME-NAME}.
    end.
                   
    
    IF p-output-type = 6
        THEN 
    DO:
        ASSIGN
            bt-cash-pay:SENSITIVE IN FRAME {&frame-name} = FALSE
            rs-cash-pay:SENSITIVE IN FRAME {&frame-name} = FALSE
            .
    END.
    ELSE 
    DO:
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
        then 
    do:
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
            then 
        do:
            hide
                tb-chk-pay-code
                .
        END.

        if p-output-type <> 3
            AND p-output-type <> 6
            then 
        do:
            hide
                RECT-1
                rs-1
                bt-sel-obj
                ed-object
                .
        end.
    end.
    if p-output-type = 2
        then 
    do:
        view tb-supp in frame {&frame-name} .
        enable tb-supp with frame {&frame-name} .
    end.
    if p-output-type = 4
        or p-output-type = 5
        then 
    do:
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
            then 
        do:
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
    assign v-dc-card.
    
    run init-fields in this-procedure .
    run myenable .
    if tb-chk-pay-code then enable rs-cash-pay with frame {&frame-name} .
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
    DEFINE INPUT PARAMETER p-param-list AS CHARACTER NO-UNDO.
    define buffer buf_schedule      for schedule.
    define buffer buf_schedule-attr for schedule-attr.
    define buffer lock-batchprocess for ub.batchprocess.

    /*данная конкретная задача может быть ТОЛЬКО ОДНА в одной БД - отследим*/
    /*заблокируем*/
    run gbl/lock-prc.p
        (input {&lock-prc-schd-free}
        ,input 'exp-bgecheck':U
        ,input 0
        ,input 0
        ,input '':U
        ,input ""
        ,input ""
        ,input (
        "Сохранение параметров выгрузки чеков "
        )
        ,input yes
        ,buffer lock-batchprocess
        ) no-error .

/*    FIND FIRST buf_schedule-attr NO-LOCK WHERE                                                            */
/*        buf_schedule-attr.task-type   = p-task-type                                                       */
/*        and buf_schedule-attr.cre-db-num = INTEGER(p-db-num-char)                                         */
/*        and buf_schedule-attr.attr-code = ({&attr-schd-free-id} + {&delim-par} + 'exp-bgecheck') NO-ERROR.*/
/*    IF AVAILABLE  buf_schedule-attr                                                                       */
/*        AND buf_schedule-attr.task-num <> p-task-num                                                      */
/*        AND buf_schedule-attr.task-num <> - 1                                                             */
/*        and p-task-num <> - 1                                                                             */
/*        THEN                                                                                              */
/*    DO:                                                                                                   */
/*        MESSAGE                                                                                           */
/*            substitute("Уже есть расписание сохранения параметров выгрузки чеков для БД &1&2" +           */
/*            "номер расписания &3"                                                                         */
/*            ,buf_schedule-attr.cre-db-num                                                                 */
/*            ,{&NEW-LINE}                                                                                  */
/*            ,buf_schedule-attr.task-num)                                                                  */
/*            VIEW-AS ALERT-BOX ERROR.                                                                      */
/*        UNDO, RETURN ERROR.                                                                               */
/*    END.                                                                                                  */
    find first buf_schedule no-lock
        where buf_schedule.task-type   = p-task-type
        and buf_schedule.cre-db-num  = INTEGER(p-db-num-char)
        and buf_schedule.task-num    = p-task-num
        no-error.
    if not available buf_schedule
        and (  p-task-type   <> {&btpr-type-autofree}
        or p-db-num-char <> p-db-num-char
        or p-task-num    <> -1 )
        then 
    do:
        message
            vss-workfile vss-revision vss-description
            skip 
            "Не найдена строка расписания."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            view-as alert-box error.
        undo, return error .
    end.
    /*message p-task-type "task" p-task-num "db" p-db-num-char view-as alert-box.*/
    run schedule-attr-write in this-procedure (
        input INTEGER(p-db-num-char)
        , input p-task-type
        , input p-task-num
        , input {&attr-schedule-param-list-h}
        , input p-param-list
        ).

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
  DISPLAY v-per code_pool date_from date_to time-days ed-object rs-1 v-dc-card 
          ed-doc-type ed-doc-type-label tb-inkass-pay-code tb-deleted v-place 
          tb-cst-code tb-exp-checks tb-parts tb-chk-pay-code rs-cash-pay 
          v-directory tb-pay-desk v-ftp-address tb-pay-desk-cards v-inf-bonus 
          v-login v-password ed-doc-type-label-2 rs-2 list-chk-type 
      WITH FRAME Dialog-Frame.
  ENABLE RECT-2 RECT-1 RECT-3 RECT-5 RECT-6 RECT-7 RECT-8 btn_save Btn_start 
         Btn_Cancel b-help v-per code_pool date_from date_to bt-dc-card rs-1 
         v-dc-card bt-sel-obj ed-doc-type bt-sel-doc-type tb-inkass-pay-code 
         tb-deleted v-place tb-cst-code tb-exp-checks tb-parts tb-chk-pay-code 
         rs-cash-pay v-directory tb-pay-desk bt-cash-pay v-ftp-address 
         tb-pay-desk-cards v-inf-bonus v-login v-password rs-2 list-chk-type 
         b-chk-type 
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
    define variable v-obj-range   as integer   no-undo .
    define variable v-obj-list    as character no-undo .
    define variable v-doc-range   as integer   no-undo .
    define variable v-doc-list    as character no-undo .
    define variable v-userid      as character no-undo .
    define variable v-naim        as character no-undo .
    define variable v-list        as character no-undo .
    define variable v-print-graft as logical   no-undo .
    define variable v-sort-gr     as logical   no-undo .
    define variable v-type-price  as logical   no-undo .
    define variable v-type-val    as logical   no-undo .
    define variable v-found       as logical   no-undo .
    define variable v-str         as character no-undo .
    define variable v-obj-tot     as integer   no-undo .
    define variable v-i           as integer   no-undo .
    define variable v-obj-type    as character no-undo .
    define variable v-obj-code    as integer   no-undo .
    define variable i             as integer   no-undo .
    define variable v-dc-help     as char      no-undo .
    define variable n-i           as integer   no-undo .
    
    
    do
    
        on error undo, return error return-value
        :
        run uf-get (
            input   {&uf-bge-dper-new}
            , input   v-cntxt-userid
            , output  v-list
            , output  v-naim
            , output  v-print-graft
            , output  v-sort-gr
            , output  v-type-price
            , output  v-type-val
            ) .
        if num-entries(v-naim) >= 18 then 
        do: 
   
            assign
                date_from = date(    entry( 1, v-naim ) ).
            date_to            = date(    entry( 2, v-naim ) ).
            tb-chk-pay-code    = logical( entry( 3, v-naim ) ).
            tb-cst-code        = logical( entry( 4, v-naim ) ).
            tb-deleted         = logical( entry( 5, v-naim ) ).
            tb-exp-checks      = logical( entry( 6, v-naim ) ).
            tb-inkass-pay-code = logical( entry( 7, v-naim ) ).
            tb-parts           = logical( entry( 8, v-naim ) ).
            tb-pay-desk        = logical( entry( 9, v-naim ) ).
            tb-pay-desk-cards  = logical( entry(10, v-naim ) ).
            tb-supp            = logical( entry(11, v-naim ) ).
            v-directory =  entry(12,v-naim ).
            v-ftp-address = entry(13,v-naim ).
            v-login = entry(14,v-naim ).
            v-password = entry(15,v-naim ).
            code_pool  = entry(16,v-naim ).
            v-inf-bonus =logical(entry(17,v-naim )).

            do while  i <> (num-entries(v-naim) - 18)  : 
                /*                     v-dc-card :SCREEN-VALUE = v-dc-num +  {&NEW-LINE} + v-dc-card :SCREEN-VALUE.*/
                v-dc-help =  entry (18 + i, v-naim ).
                v-dc-num-full = entry (18 + i, v-naim ) + ","  +  v-dc-num-full    .
                v-dc-card:SCREEN-VALUE in frame {&frame-name} = v-dc-help +  {&NEW-LINE} +  v-dc-card :SCREEN-VALUE in frame {&frame-name} .
                i = i + 1 
                    .
            end.
            
            
            
            i = 0.
            v-dc-help = "".

            if tb-chk-pay-code = yes
                then 
            do:
                enable
                    tb-pay-desk
                    tb-pay-desk-cards
                    with frame {&frame-name}.
            end.
        end.
            
        display
            v-directory
            date_from
            date_to
            tb-chk-pay-code
            tb-cst-code
            tb-deleted
            tb-exp-checks
            tb-inkass-pay-code
            tb-parts
            tb-pay-desk
            tb-pay-desk-cards
            /*            tb-supp*/
            v-ftp-address
            v-login
            v-password
            code_pool 
            v-inf-bonus 
            v-dc-card
            when p-output-type = 2
            with frame {&frame-name}.
                
        if num-entries(v-list,';') = 2
            then 
        do:
            assign
                v-str = entry( 1 , v-list, ';')
                .
            if num-entries(v-str,':') = 2
                then 
            do:
                assign
                    rs-1       = integer(entry(1, v-str, ':'))
                    v-obj-list = entry(2, v-str, ':')
                    v-obj-tot  = num-entries(v-obj-list)
                    .
                if rs-1 = 3 and v-obj-tot < 2
                    then 
                do:
                    assign
                        rs-1 = 1
                        .
                end.
                run object-select in this-procedure .
                display
                    rs-1
                    with frame {&frame-name}.
                if rs-1 = 3
                    then 
                do:
                    if v-obj-tot modulo 2 = 0
                        then 
                    do:
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
                                then 
                            do:
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
                then 
            do:
                assign
                    ed-doc-type = "Все":u
                    .
            end.
            else 
            do:
                assign
                    ed-doc-type = ''
                    .
                for each temp_ext-doc-type
                    :
                    if lookup( temp_ext-doc-type.ext-doc-type, v-str ) <> 0
                        then 
                    do:
                        assign
                            ed-doc-type     = ed-doc-type + temp_ext-doc-type.ext-doc-type-label + {&new-line}
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
    define variable v-obj-range   as integer   no-undo .
    define variable v-obj-list    as character no-undo .
    define variable v-doc-range   as integer   no-undo .
    define variable v-doc-list    as character no-undo .
    define variable v-userid      as character no-undo .
    define variable v-naim        as character no-undo .
    define variable v-list        as character no-undo .
    define variable v-print-graft as logical   no-undo .
    define variable v-sort-gr     as logical   no-undo .
    define variable v-type-price  as logical   no-undo .
    define variable v-type-val    as logical   no-undo .
    v-naim ="".
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
            tb-inkass-pay-code
            tb-parts
            tb-pay-desk
            tb-pay-desk-cards
            /*            tb-supp*/
            code_pool
            rs-1
            rs-2
            v-ftp-address 
            v-login 
            v-password 
            code_pool  
            v-inf-bonus
            v-dc-card
            v-directory
            fi-pack-lim = 90
            .


        case rs-1 :screen-value
            :
            when "1"
            then 
                do:
                    assign
                        v-obj-range = 1
                        v-obj-list  = ""
                        .
                end.
            when "2"
            then 
                do:
                    assign
                        v-obj-range = 2
                        v-obj-list  = ""
                        .
                end.
            when "3"
            then 
                do:
                    assign
                        v-obj-range = 3
                        v-obj-list  = ""
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
            v-naim = string(date_from         ) + "," +
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
                   v-directory + "," + 
                   v-ftp-address + "," + 
                   v-login + "," +
                   v-password + "," +     
                   code_pool  + "," + 
                   string( v-inf-bonus ) + "," + 
                   v-dc-num-full .
                   
        v-list = substitute( "&1:&2;&3"
            , v-obj-range
            , v-obj-list
            , p-doc-type-list
            )
            .
        run uf-set ( input {&uf-bge-dper-new}
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

        define buffer buf_clients for ub.clients.

        find first buf_clients no-lock
            where buf_clients.obj-type = {&cmp}
            and buf_clients.obj-code = v-bge-dper-host-code
            no-error.
        if not available buf_clients
            then 
        do:
            message
                vss-workfile vss-revision vss-description
                skip 
                "Не удалось найти текущую фирму"
                skip return-value
                skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
                trim(error-status :get-message(4))
                trim(error-status :get-message(5))
                view-as alert-box error.
            undo, return error .
        end.
        else 
        do:
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
        define variable v-oper-num as integer no-undo.
        run manage-tb-chk-pay-code in this-procedure.
        assign
            p-doc-type-list = p-init-doc-type-list
            .
        assign
            rs-1 :screen-value in frame dialog-frame      = "2"
            ed-object :screen-value in frame Dialog-frame = {&cmp} + string( v-bge-dper-host-code ) + " " + v-host-name
            .
        assign
            rs-1
            .
        if p-init-doc-type-list <> ?
            and p-init-doc-type-list <> ''
            then 
        do:
            for each temp_ext-doc-type
                :
                if lookup( temp_ext-doc-type.ext-doc-type, p-init-doc-type-list ) <> 0
                    then 
                do:
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
        if p-mode <> "shd" then 
        do: 
    
            run flt-load in this-procedure .
        end.
        
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
            then 
        do:
            assign
                tb-pay-desk :sensitive in frame {&frame-name}       = yes
                tb-pay-desk-cards :sensitive in frame {&frame-name} = yes
                .
        end.
        else 
        do:
            assign
                tb-pay-desk :sensitive in frame {&frame-name}       = no
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
            then 
                do:
                    assign
                        ed-object :screen-value = ""
                        .
                end.
            when "2"
            then 
                do:
                    assign
                        ed-object :screen-value = v-host-name
                        .
                end.
            when "3"
            then 
                do:
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

PROCEDURE myenable :
 
    case p-mode:
        when "run" then 
            do:
                hide btn_save in frame {&FRAME-NAME}.
                hide  v-per in frame {&frame-name}.
                hide time-days in frame  {&frame-name}.
            end. /* when "run" */
    
        when "shd" then 
            do:
                
                hide date_from in frame  {&FRAME-NAME}.
                hide date_to in frame {&Frame-name}.
                hide btn_start in frame {&FRAME-NAME}.
                disable  date_to  date_from with  frame  {&FRAME-NAME}.
              
             
                /* Прочитаем атрибуты выгрузки */
                run schedule-attr-value in this-procedure (input p-db-num-char
                    , input p-task-type
                    , input p-task-num
                    , input {&attr-schedule-param-list-h}
                    ,output v-param-list
                    ,output v-param-type).


                /*                 Если у нас уже были атрибуты - отобразим их*/
                if v-param-list <> ""  then
                do:
                    v-place = integer(ENTRY(1, v-param-list, {&delim-par})) no-error.
                    if v-place = 2 then
                    do:
                        assign
                            v-ftp-address      = entry (2, v-param-list, {&delim-par})
                            v-per              = integer(ENTRY(3, v-param-list, {&delim-par}))
                            v-login            = ENTRY(4, v-param-list, {&delim-par})
                            v-password         = ENTRY(5, v-param-list, {&delim-par})
                            /*                            date_exp_from        = date(entry(6,v-param-list,{&delim-par}))  /*Глобально, по фирме, по объекту*/*/
                            /*                            date_exp_to        = date(entry(7,v-param-list,{&delim-par})) /*Все, топливо, услуги*/              */
                            p-range            = integer(entry(6,v-param-list,{&delim-par}))
                            p-host-code        = integer(entry(7,v-param-list,{&delim-par}))
                            p-obj-list         = (entry(8,v-param-list,{&delim-par}))
                            p-pay-type-list    = (entry(9,v-param-list,{&delim-par}))
                            p-gds-type         = (entry(10,v-param-list,{&delim-par}))
                            p-doc-type-list    = (entry(11,v-param-list,{&delim-par}))            
                            v-dc-num-full      = (entry(12,v-param-list,{&delim-par}))
                            v-inf-bonus        = logical(entry(13,v-param-list,{&delim-par}))
                            code_pool          = (entry(14,v-param-list,{&delim-par}))
                            tb-pay-desk-cards  = logical (entry(15,v-param-list,{&delim-par}))
                            tb-pay-desk        = logical(entry(16,v-param-list,{&delim-par}))
                            tb-parts           = logical(entry(17,v-param-list,{&delim-par}))
                            tb-inkass-pay-code = logical(entry(18,v-param-list,{&delim-par}))
                            tb-deleted         = logical(entry(19,v-param-list,{&delim-par}))
                                   tb-chk-pay-code = logical (entry(20,v-param-list,{&delim-par}))
                            tb-cst-code = logical (entry(21,v-param-list,{&delim-par}))
                              tb-exp-checks  =  logical (entry(22,v-param-list,{&delim-par}))
                                               p-rs-2 = entry(23,v-param-list,{&delim-par})
                                               chr-list-chk-type = entry(24,v-param-list,{&delim-par})
                           NO-ERROR.
                        
                        disable v-directory with frame {&FRAME-NAME}.
/*                        display code_pool  v-inf-bonus     v-per v-ftp-address  v-login    tb-chk-pay-code v-password  v-place  tb-deleted  tb-inkass-pay-code  tb-cst-code  tb-parts   tb-pay-desk   tb-pay-desk-cards with frame {&FRAME-NAME} no-error.*/
/*                        v-dc-card :SCREEN-VALUE = v-dc-num-full .                                                                                                                                                                                         */
/*                        rs-1 :screen-value = string(p-range) no-error.                                                                                                                                                                                    */
                            
                      
                    end. 
                           
                    if v-place = 1 then 
                    do :
                        assign
                        v-directory        = entry (2, v-param-list, {&delim-par})
                        v-per              = integer(ENTRY(3, v-param-list, {&delim-par}))
                            /*                            v-login          = ENTRY(4, v-param-list, {&delim-par})*/
                            /*                            v-password       = ENTRY(5, v-param-list, {&delim-par})*/
                            /*                            date_exp_from        = date(entry(3,v-param-list,{&delim-par}))  /*Глобально, по фирме, по объекту*/*/
                            /*                            date_exp_to        = date(entry(4,v-param-list,{&delim-par})) /*Все, топливо, услуги*/              */
                            p-range            = integer(entry(4,v-param-list,{&delim-par})) /*По типу кассовых платежей из чеков*/
                            p-host-code        = integer(entry(5,v-param-list,{&delim-par})) /*ГТД по строке документа*/
                            p-obj-list         = (entry(6,v-param-list,{&delim-par})) /*Удалённые*/
                            p-pay-type-list    = (entry(7,v-param-list,{&delim-par})) /*Чеки*/
                            p-gds-type         = (entry(8,v-param-list,{&delim-par})) /*По виду оплаты*/
                            p-doc-type-list    = (entry(9,v-param-list,{&delim-par})) /*По партиям                */               
                            v-dc-num-full      = (entry(10,v-param-list,{&delim-par})) /*По партиям*/
                            v-inf-bonus        = logical(entry(11,v-param-list,{&delim-par})) /*Выгружать информацию по бонусам*/
                            code_pool          = (entry(12,v-param-list,{&delim-par}))
                            tb-pay-desk-cards  = logical (entry(13,v-param-list,{&delim-par}))
                            tb-pay-desk        = logical(entry(14,v-param-list,{&delim-par}))
                            tb-parts           = logical(entry(15,v-param-list,{&delim-par}))
                            tb-inkass-pay-code = logical(entry(16,v-param-list,{&delim-par}))
                            tb-deleted         = logical(entry(17,v-param-list,{&delim-par}))
                            tb-chk-pay-code = logical (entry(18,v-param-list,{&delim-par}))
                            tb-cst-code = logical (entry(19,v-param-list,{&delim-par}))
                            tb-exp-checks = logical (entry(20,v-param-list,{&delim-par}))
                            p-rs-2 = entry(21,v-param-list,{&delim-par})
                            chr-list-chk-type =  entry(22,v-param-list,{&delim-par})
                               NO-ERROR.
                        disable v-ftp-address v-login v-password with frame {&FRAME-NAME}.
/*                        v-dc-card :SCREEN-VALUE = v-dc-num-full.*/
                         
                         
                    end.  
                end.
                                        display code_pool v-directory v-inf-bonus  v-place v-per   tb-exp-checks  tb-deleted tb-cst-code tb-chk-pay-code  tb-inkass-pay-code  tb-parts   tb-pay-desk   tb-pay-desk-cards with frame {&FRAME-NAME} no-error.
                                        rs-1 :screen-value = string(p-range) no-error.
                                        v-dc-card :SCREEN-VALUE = v-dc-num-full .
                                         rs-2 :screen-value =  p-rs-2 no-error.
             define variable i as integer no-undo.   
             
                                      
             do i = 1 to num-entries(chr-list-chk-type) :
   
            if entry(i,chr-list-chk-type  ) = "1"   then v-list-chk-type = "Продажа,"   no-error.
           if entry(i,chr-list-chk-type  )  = "6"   then v-list-chk-type = v-list-chk-type + "Возврат,"   no-error.
        if entry(i,chr-list-chk-type  )   = "8"  then v-list-chk-type = v-list-chk-type + "Аннуляция,"   no-error.
        if entry(i,chr-list-chk-type  )   = "17"  then v-list-chk-type = v-list-chk-type + "ТехПролив"  no-error.
         end.
                                         
                                         
                                         list-chk-type :list-items  =  v-list-chk-type.
            end.
   
    end case.
end procedure.

procedure chk-type-choose:


 /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    define variable v-counter       as integer   no-undo.
    define variable v-label         as character no-undo.
    define variable v-value         as character no-undo.
    define variable v-list          as character no-undo.
    define variable v-changed       as logical   no-undo.
    define variable v-accepted      as logical   no-undo.
    define variable v-list-edt      as character no-undo.
    define variable v-list-edt-full as character no-undo.
    
    do
        with frame {&frame-name}
        on error undo, return error
        :
            
            
        v-uf-Naim = "".
            
        assign
            v-list-edt = "Продажа" + 
        "," + "Возврат" + 
        "," + "Аннуляция" + 
        "," + "ТехПролив" +
        "," + "Коррекции"
        .
        
        assign
            v-list-edt-full = "Продажа" + 
        "," + "Возврат" + 
        "," + "Аннуляция" + 
        "," + "ТехПролив" +
        "," + "Коррекции"
        .
        
        run twowin_clear in this-procedure.
        do v-counter = 1 to num-entries( v-list-edt-full )
            on error undo, return error
            :
            assign
                v-label = entry( v-counter, v-list-edt-full )
                v-value = entry( v-counter, v-list-edt )
                .
            run twowin_add-item in this-procedure (
                input v-value
                , input v-label
                , input substitute( "Тип чеков: &1", v-value )
                , input ( list-chk-type :lookup( v-value ) <> 0  )
                ).
        end. 
        run gbl/twowin.w (
            input ?
            , input 1
            , input "Выбор типа чека":U
            , input "":U
            , input "&Тест"
            , input table temp_twowin_items
            , output table temp_twowin_itemsSelected
            , output v-changed
            , output v-accepted
            ).
        
        if

            v-changed = yes
            then 
        do:
            assign
               list-chk-type :list-items = "":U
                v-list                  = "":U
                v-counter               = 0
                .

            for each temp_twowin_itemsSelected
                by temp_twowin_itemsSelected.itm-key
                :
                assign
                    v-counter = v-counter + 1
                    v-list    = substitute( "&1&2&3"
                                , v-list
                                , ( if v-list = "":U then "":U else ",":U )
                                , temp_twowin_itemsSelected.itmExtKey
                                )
                    .

                list-chk-type :add-last (
                    entry( lookup( temp_twowin_itemsSelected.itmExtKey, v-list-edt ), v-list-edt-full )
                    , temp_twowin_itemsSelected.itmExtKey
                    ) no-error.
            end.
   
        end.
           
    end.
   
       chr-list-chk-type = "".

    v-list-chk-type = "".
    do v-counter = 1 to list-chk-type :num-items in frame {&frame-name}
        on error undo, return error
        :
        assign
            v-list-chk-type = substitute( "&1&2&3"
                                        , v-list-chk-type
                                        , ( if v-list-chk-type = "":U then "":U else ",":U )
                                        , entry( v-counter , list-chk-type :list-items ) 
                                        )  no-error
            .
       end.
    
      do v-counter = 1 to list-chk-type :num-items in frame {&frame-name}
        on error undo, return error
        :
          if entry(v-counter,v-list-chk-type  ) = "Продажа"   then chr-list-chk-type = "1,"   no-error.
          if entry(v-counter,v-list-chk-type  )  = "Возврат"   then chr-list-chk-type = chr-list-chk-type + "6,"   no-error.
          if entry(v-counter,v-list-chk-type  )   = "Аннуляция"  then chr-list-chk-type = chr-list-chk-type + "8,"   no-error.
          if entry(v-counter,v-list-chk-type  )   = "ТехПролив"  then chr-list-chk-type = chr-list-chk-type + "17,"  no-error.
          if entry(v-counter,v-list-chk-type  )   = "Коррекции"  then chr-list-chk-type = chr-list-chk-type + "43,44"  no-error.
      end. 
/*        message chr-list-chk-type view-as alert-box.*/
    
       /* do */
/*    v-uf-Naim = v-list-chk-type.*/
    
/*    run uf-set in this-procedure*/
/*        ( input {&uf-alc-rees}  */
/*        ,input v-cntxt-userid   */
/*        ,input v-uf-List_       */
/*        ,input v-uf-Naim        */
/*        ,input v-uf-print-graft */
/*        ,input v-uf-sort-gr     */
/*        ,input v-uf-type-price  */
/*        ,input v-uf-type-val    */
/*        ) no-error .            */

end.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE write-log-and-file dialog-frame
PROCEDURE write-log-and-file :
    /*------------------------------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    ------------------------------------------------------------------------------*/
    define input parameter p-tab-position   as integer    no-undo.
    define input parameter p-file-name      as char       no-undo.
    define input parameter p-log-level      as integer    no-undo.
    define input parameter p-log-string     as char       no-undo.

    output stream StreamLog to value(p-file-name) append.
    put stream StreamLog unformatted {&new-line}.

    put stream StreamLog unformatted cur-time-string-sec() " " p-log-string.

    output stream StreamLog close.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

