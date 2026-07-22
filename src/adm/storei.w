&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_clients FOR clients.
DEFINE BUFFER locked_store FOR store.
DEFINE TEMP-TABLE tt-clients NO-UNDO LIKE clients.
DEFINE TEMP-TABLE tt-store NO-UNDO LIKE store.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Форма просмотра и изменения склада

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/12/06
Author: Bakhtadze Natalya
Creation date: 04/12/06

Author:  Андрей Исаков
Created: 22.03.95

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT        PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input        parameter p-host-code    like ub.sysconf.host-code no-undo.
define input        parameter p-obj-code     like ub.store.obj-code no-undo.
define input        parameter p-mode         as character no-undo .   /* {&add-def}, {&update}, {&lookup} */
define input-output parameter p-rid          as recid     no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Редактирование и просмотр записи таблицы склад" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ gbl/clntattr.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ gbl/thbjattr.i }
{ adm/shattrg.i  }
{ gbl/waitfram.i }

define buffer buf_cli-grp for ub.cli-grp .
define buffer buf_cli-host for ub.clients .

define variable v-db-num like ub.db.db-num no-undo .
define variable ref-list as character no-undo .
define variable new-host-code as integer no-undo .
DEFINE VARIABLE v-envd AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-pharm AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-type AS CHARACTER NO-UNDO.
define variable v-storei-have-holdfirm    as logical      no-undo.
DEFINE VARIABLE v-kpp AS CHARACTER NO-UNDO.
&scoped-define purch-like-firm "по настройкам фирмы"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-clients.db-num tt-store.obj-code ~
tt-clients.obj-name tt-store.store-man tt-store.store-boss tt-store.addres1 ~
tt-store.phone tt-store.addres2 tt-store.fax tt-store.work-hours ~
tt-store.holidays tt-store.load-time tt-store.rsrv-time tt-store.in-pay ~
tt-store.doc-prt tt-store.out-pay tt-store.price-calc tt-store.no-eq ~
tt-store.ret-pay tt-store.unit-cli-perm tt-store.ret-sup-pay ~
tt-store.out-line-discnt tt-store.down-pay tt-store.out-rate tt-store.in-ov ~
tt-store.inv-pay tt-store.inout-price tt-store.fbr-pay tt-store.shift-on ~
tt-clients.PS 
&Scoped-define ENABLED-TABLES tt-clients tt-store
&Scoped-define FIRST-ENABLED-TABLE tt-clients
&Scoped-define SECOND-ENABLED-TABLE tt-store
&Scoped-Define ENABLED-OBJECTS B-exit b-quit b-reset b-host b-db B-hist ~
B-Help RECT-10 B-attr Btn_trn-reason KPP b-inpay b-outpay b-retpay b-suppay ~
b-spipay b-invpay b-fbrpay varpharm varenvd b-holdfirm  
&Scoped-Define DISPLAYED-FIELDS tt-clients.db-num tt-store.obj-code ~
tt-clients.obj-name tt-store.store-man tt-store.store-boss tt-store.addres1 ~
tt-store.phone tt-store.addres2 tt-store.fax tt-store.work-hours ~
tt-store.holidays tt-store.load-time tt-store.rsrv-time tt-store.in-pay ~
tt-store.doc-prt tt-store.out-pay tt-store.price-calc tt-store.no-eq ~
tt-store.ret-pay tt-store.unit-cli-perm tt-store.ret-sup-pay ~
tt-store.out-line-discnt tt-store.down-pay tt-store.out-rate tt-store.in-ov ~
tt-store.inv-pay tt-store.inout-price tt-store.fbr-pay tt-store.shift-on ~
tt-clients.PS 
&Scoped-define DISPLAYED-TABLES tt-clients tt-store
&Scoped-define FIRST-DISPLAYED-TABLE tt-clients
&Scoped-define SECOND-DISPLAYED-TABLE tt-store
&Scoped-Define DISPLAYED-OBJECTS KPP varpharm varenvd varpurch-code-name ~
EDITOR-1 fi-holdfirm-code fi-holdfirm-name 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-obj-code 
       MENU-ITEM m-choose       LABEL "Подобрать свободный код".


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-attr 
     LABEL "&Параметры" 
     SIZE 10 BY 1.

DEFINE BUTTON b-db 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-db" 
     SIZE 3 BY .86.

DEFINE BUTTON B-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-fbrpay 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L 
     SIZE 3 BY .91.

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist 
     LABEL "Ис&тория" 
     SIZE 3 BY 1.

DEFINE BUTTON b-holdfirm 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-db" 
     SIZE 3 BY .86.

DEFINE BUTTON b-host 
     LABEL "&Фирма" 
     SIZE 10 BY 1.

DEFINE BUTTON b-inpay 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L 
     SIZE 3 BY .91.

DEFINE BUTTON b-invpay 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L 
     SIZE 3 BY .91.

DEFINE BUTTON b-outpay 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L 
     SIZE 3 BY .91.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-reset 
     LABEL "&Уст.Сист.":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-retpay 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L 
     SIZE 3 BY .91.

DEFINE BUTTON b-spipay 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L 
     SIZE 3 BY .91.

DEFINE BUTTON b-suppay 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L 
     SIZE 3 BY .91.

DEFINE BUTTON Btn_trn-reason 
     LABEL "Коды оснований" 
     SIZE 20 BY 1 TOOLTIP "Код оснований (причин) создания документов по умолчанию на складе".

DEFINE VARIABLE varpurch-code-name AS CHARACTER FORMAT "X(256)":U 
     LABEL "Тип приобретения" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1" 
     DROP-DOWN-LIST
     SIZE 26 BY 1 NO-UNDO.

DEFINE VARIABLE EDITOR-1 AS CHARACTER INITIAL "Система налогообложения для выгрузки в XML:" 
     VIEW-AS EDITOR NO-BOX
     SIZE 24.6 BY 1.52 NO-UNDO.

DEFINE VARIABLE fi-holdfirm-code AS INTEGER FORMAT ">>>>>>9":U INITIAL 0 
     LABEL "Фирма для накладных" 
      VIEW-AS TEXT 
     SIZE 6.6 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-holdfirm-name AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 29.6 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE KPP AS CHARACTER FORMAT "X(25)":U 
     LABEL "КПП" 
     VIEW-AS FILL-IN 
     SIZE 21 BY .95 NO-UNDO.

DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 31.2 BY 7.91
     BGCOLOR 8 .

DEFINE VARIABLE varenvd AS LOGICAL INITIAL no 
     LABEL "Без НДС" 
     VIEW-AS TOGGLE-BOX
     SIZE 11.2 BY .81 NO-UNDO.

DEFINE VARIABLE varpharm AS LOGICAL INITIAL no 
     LABEL "Аптека" 
     VIEW-AS TOGGLE-BOX
     SIZE 11.2 BY .81 TOOLTIP "Объект работает как АПТЕКА" NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-reset AT ROW 1 COL 31
     b-host AT ROW 1 COL 41
     tt-clients.db-num AT ROW 1 COL 80 COLON-ALIGNED
          LABEL "Номер БД" FORMAT ">>>>9"
          VIEW-AS FILL-IN 
          SIZE 6 BY 1
     b-db AT ROW 1 COL 88.6
     B-hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     tt-store.obj-code AT ROW 2 COL 5.2 COLON-ALIGNED
          LABEL "Код"
          VIEW-AS FILL-IN 
          SIZE 6 BY 1
     B-attr AT ROW 2 COL 71 WIDGET-ID 2
     tt-clients.obj-name AT ROW 2.1 COL 22.6 COLON-ALIGNED
          LABEL "Название"
          VIEW-AS FILL-IN 
          SIZE 46.6 BY 1
          BGCOLOR 15 
     Btn_trn-reason AT ROW 2.1 COL 81.6
     tt-store.store-man AT ROW 3.38 COL 53 COLON-ALIGNED
          LABEL "Кладовщик"
          VIEW-AS FILL-IN 
          SIZE 19 BY 1
          BGCOLOR 15 
     KPP AT ROW 3.38 COL 78 COLON-ALIGNED WIDGET-ID 12
     tt-store.store-boss AT ROW 3.52 COL 14 COLON-ALIGNED
          LABEL "Зав. складом"
          VIEW-AS FILL-IN 
          SIZE 26 BY 1
          BGCOLOR 15 
     tt-store.addres1 AT ROW 4.76 COL 7 COLON-ALIGNED
          LABEL "Адрес" FORMAT "X(80)"
          VIEW-AS FILL-IN 
          SIZE 63 BY 1
          BGCOLOR 15 
     tt-store.phone AT ROW 4.76 COL 78 COLON-ALIGNED
          LABEL "Тел-н"
          VIEW-AS FILL-IN 
          SIZE 21 BY 1
          BGCOLOR 15 
     tt-store.addres2 AT ROW 6 COL 7 COLON-ALIGNED NO-LABEL FORMAT "X(80)"
          VIEW-AS FILL-IN 
          SIZE 63 BY 1
          BGCOLOR 15 
     tt-store.fax AT ROW 6 COL 78 COLON-ALIGNED
          LABEL "Факс"
          VIEW-AS FILL-IN 
          SIZE 21 BY 1
          BGCOLOR 15 
     tt-store.work-hours AT ROW 7.24 COL 13.8 COLON-ALIGNED
          LABEL "Часы работы"
          VIEW-AS FILL-IN 
          SIZE 14.6 BY 1
          BGCOLOR 15 
     tt-store.holidays AT ROW 7.24 COL 39 COLON-ALIGNED
          LABEL "Выходные"
          VIEW-AS FILL-IN 
          SIZE 11.6 BY 1
          BGCOLOR 15 
     tt-store.load-time AT ROW 7.24 COL 73 COLON-ALIGNED
          LABEL "Срок отгрузки (дней)"
          VIEW-AS FILL-IN 
          SIZE 4 BY 1
     tt-store.rsrv-time AT ROW 8.43 COL 73.2 COLON-ALIGNED
          LABEL "Период резервирования (дней)"
          VIEW-AS FILL-IN 
          SIZE 4 BY 1
     tt-store.in-pay AT ROW 9.14 COL 18.4 COLON-ALIGNED
          LABEL "п&рихода"
          VIEW-AS FILL-IN 
          SIZE 6 BY .91
          BGCOLOR 15 
     b-inpay AT ROW 9.14 COL 27.8
     tt-store.doc-prt AT ROW 9.52 COL 51.4
          LABEL "Учет по шкалам"
          VIEW-AS TOGGLE-BOX
          SIZE 34.6 BY .81
     tt-store.out-pay AT ROW 10.14 COL 18.4 COLON-ALIGNED
          LABEL "рас&хода"
          VIEW-AS FILL-IN 
          SIZE 6 BY .91
          BGCOLOR 15 
     b-outpay AT ROW 10.14 COL 27.8
     tt-store.price-calc AT ROW 10.24 COL 51.4
          LABEL "Запрещен приход при неравенстве цен"
          VIEW-AS TOGGLE-BOX
          SIZE 37.6 BY .81
     tt-store.no-eq AT ROW 11 COL 51.4
          LABEL "Запрещен приход при отсутствии цен"
          VIEW-AS TOGGLE-BOX
          SIZE 37.6 BY .81
     tt-store.ret-pay AT ROW 11.14 COL 18.4 COLON-ALIGNED
          LABEL "во&зврата"
          VIEW-AS FILL-IN 
          SIZE 6 BY .91
          BGCOLOR 15 
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     b-retpay AT ROW 11.14 COL 27.8
     tt-store.unit-cli-perm AT ROW 11.76 COL 51.4
          LABEL "Изменение ед. изм. поставщика"
          VIEW-AS TOGGLE-BOX
          SIZE 32.6 BY .81
     tt-store.ret-sup-pay AT ROW 12.14 COL 18.4 COLON-ALIGNED
          LABEL "возвра&та пост."
          VIEW-AS FILL-IN 
          SIZE 6 BY .91
          BGCOLOR 15 
     b-suppay AT ROW 12.14 COL 27.8
     tt-store.out-line-discnt AT ROW 12.52 COL 51.4
          LABEL "Скидка по строке РН"
          VIEW-AS TOGGLE-BOX
          SIZE 22 BY .81
     tt-store.down-pay AT ROW 13.14 COL 18.4 COLON-ALIGNED
          LABEL "списани&я"
          VIEW-AS FILL-IN 
          SIZE 6 BY .91
          BGCOLOR 15 
     b-spipay AT ROW 13.14 COL 27.8
     tt-store.out-rate AT ROW 13.19 COL 51.4
          LABEL "Изменение курса РН"
          VIEW-AS TOGGLE-BOX
          SIZE 22 BY .81
     tt-store.in-ov AT ROW 13.95 COL 51.4
          LABEL "Запрещено движение без переоценки после ПН"
          VIEW-AS TOGGLE-BOX
          SIZE 47.2 BY .81
     tt-store.inv-pay AT ROW 14.14 COL 18.4 COLON-ALIGNED
          LABEL "и&нвентаризации"
          VIEW-AS FILL-IN 
          SIZE 6 BY .91
          BGCOLOR 15 
     b-invpay AT ROW 14.14 COL 27.8
     tt-store.inout-price AT ROW 14.71 COL 51.4
          LABEL "Изменение налогов поставщика в ПН"
          VIEW-AS TOGGLE-BOX
          SIZE 36.2 BY .81
     tt-store.fbr-pay AT ROW 15.14 COL 18.4 COLON-ALIGNED
          LABEL "производства"
          VIEW-AS FILL-IN 
          SIZE 6 BY .91
     b-fbrpay AT ROW 15.14 COL 27.8
     tt-store.shift-on AT ROW 15.48 COL 51.4
          LABEL "Включены смены"
          VIEW-AS TOGGLE-BOX
          SIZE 35 BY .81
     varpharm AT ROW 16.24 COL 66 WIDGET-ID 4
     varenvd AT ROW 16.29 COL 51.4
     varpurch-code-name AT ROW 17 COL 18.8 COLON-ALIGNED
     tt-store.in-perm AT ROW 17 COL 51.4
          LABEL "Добавление ПН на пассивном складе"
          VIEW-AS TOGGLE-BOX
          SIZE 37.6 BY .81
     b-holdfirm AT ROW 18.52 COL 67
     tt-clients.PS AT ROW 20 COL 2 NO-LABEL
          VIEW-AS EDITOR
          SIZE 46 BY 2.52
     EDITOR-1 AT ROW 20 COL 60 NO-LABEL
     fi-holdfirm-code AT ROW 18.52 COL 58 COLON-ALIGNED
     fi-holdfirm-name AT ROW 18.52 COL 68 COLON-ALIGNED NO-LABEL
     "Оплаты :" VIEW-AS TEXT
          SIZE 8.6 BY .91 AT ROW 8.95 COL 2.6
          FGCOLOR 4 
     "Примечания" VIEW-AS TEXT
          SIZE 18.2 BY .86 AT ROW 19 COL 2.6
     RECT-10 AT ROW 8.62 COL 1.6
     SPACE(69.15) SKIP(6.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Склад"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_clients B "?" ? ub clients
      TABLE: locked_store B "?" ? ub store
      TABLE: tt-clients T "?" NO-UNDO ub clients
      TABLE: tt-store T "?" NO-UNDO ub store
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tt-store.addres1 IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-store.addres2 IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-clients.db-num IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR TOGGLE-BOX tt-store.doc-prt IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-store.down-pay IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR EDITOR EDITOR-1 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       EDITOR-1:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN tt-store.fax IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-store.fbr-pay IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN fi-holdfirm-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-holdfirm-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-store.holidays IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-store.in-ov IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-store.in-pay IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-store.in-perm IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE EXP-LABEL                                       */
ASSIGN 
       tt-store.in-perm:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX tt-store.inout-price IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-store.inv-pay IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-store.load-time IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-store.no-eq IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-store.obj-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN 
       tt-store.obj-code:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-obj-code:HANDLE.

/* SETTINGS FOR FILL-IN tt-clients.obj-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-store.out-line-discnt IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-store.out-pay IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-store.out-rate IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-store.phone IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-store.price-calc IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-store.ret-pay IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-store.ret-sup-pay IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-store.rsrv-time IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-store.shift-on IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-store.store-boss IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-store.store-man IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-store.unit-cli-perm IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR COMBO-BOX varpurch-code-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-store.work-hours IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Склад */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr Dialog-Frame
ON CHOOSE OF B-attr IN FRAME Dialog-Frame /* Параметры */
DO:
  RUN proc-b-attr IN THIS-PROCEDURE ({&lookup}, {&stock}, locked_store.obj-code) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-db Dialog-Frame
ON CHOOSE OF b-db IN FRAME Dialog-Frame /* b-db */
DO:
  define variable ri as recid no-undo.
define buffer buf_db for ub.db.
  run adm/dbs.w (
                input parparentproc
               ,input {&lookup}
               ,output ri).

  if ri <> ?
  then do:
    find buf_db where recid (buf_db) = ri .
    display
    buf_db.db-num @ tt-clients.db-num
    with frame {&frame-name}.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
    run proc-save in this-procedure no-error.
    if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-fbrpay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-fbrpay Dialog-Frame
ON CHOOSE OF b-fbrpay IN FRAME Dialog-Frame
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.

    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = "" then  return no-apply.
    else do:
      FIND buf_pay-type WHERE
             recid( buf_pay-type ) = int(ref-rec) NO-LOCK .
      assign
      tt-store.fbr-pay = buf_pay-type.obj-code .
      display
        tt-store.fbr-pay with frame {&frame-name}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
   define variable v-rid-list as character no-undo .
     run ref/cclihist.w (
                      input parparentproc
                    , input 0 /*p-curr-host-code*/
                    , input "":U  /*p-curr-obj-type*/
                    , input 0  /*p-curr-obj-code*/
                    , input "":U /*bttns*/
                    , "one":U /*p-mode*/
                    , input {&stock} /*p-obj-type*/
                    , input tt-store.obj-code /*p-obj-code*/
                    , input ? /*p-host-code*/
                    , input ? /* p-corr-user-db-num  */
                    , input "":U /* p-corr-user-name  */
                    , input "":U /* p-subject  */
                    , input v-cntxt-db-num /* p-db-num */
                    , input-output v-rid-list  ) no-error .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-holdfirm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-holdfirm Dialog-Frame
ON CHOOSE OF b-holdfirm IN FRAME Dialog-Frame /* b-db */
DO:
    define variable v-ref-list  as character    no-undo.
    define variable v-firm-code as integer    no-undo.

    assign
        fi-holdfirm-code
    .
    run adm/sconfs.w (
          input parParentProc
        , input "b-sel":U
        , input no
        , input fi-holdfirm-code
        , output v-firm-code
        , input-output ref-list
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка выбора фирмы."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if v-firm-code = ?
    or v-firm-code = 0
    then do:
        message "Фирма не выбрана."
        view-as alert-box warning.
        return no-apply.
    end.
    else do:
        define buffer buf_clients for ub.clients.
        find first buf_clients no-lock
             where buf_clients.obj-type = {&cmp}
               and buf_clients.obj-code = v-firm-code
        no-error.
        if available buf_clients
        then do:
            assign
                fi-holdfirm-code = v-firm-code
                fi-holdfirm-name = buf_clients.obj-name
            .
        end.
        else do:
            assign
                fi-holdfirm-code = 0
                fi-holdfirm-name = "":U
            .
        end.
        display
            fi-holdfirm-code
            fi-holdfirm-name
        with frame {&frame-name}.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-host
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-host Dialog-Frame
ON CHOOSE OF b-host IN FRAME Dialog-Frame /* Фирма */
DO:
define variable ref-list as char no-undo.
define variable glog as logical no-undo .
IF p-mode = {&add-def}  THEN DO:
  run adm/sconfs.w (
                 input parParentProc
                ,input "b-sel":U
                ,input no
                ,input p-host-code
                ,output new-host-code
                ,input-output ref-list ) .
   .

  if new-host-code = ?
  or new-host-code = 0
  then do:
    message "Фирма не выбрана."
            view-as alert-box error.
    return no-apply.
  end.
  if tt-store.host-code <> 0 then do:
    /*если не принудительный выбор при входе*/
    message
    "Проставить коды оплат для типов документов и др. согласно настройкам выбранной фирмы?"
    view-as alert-box question buttons yes-no update glog.
  end.
  else do:
    glog = yes.
  end.
  tt-store.host-code = new-host-code.
  find first buf_cli-host where
            buf_cli-host.obj-type = {&cmp}
        and buf_cli-host.obj-code = tt-store.host-code no-lock.
  CASE p-mode:
    when {&lookup} then
    frame {&frame-name}:title = "СКЛАД  фирмы : " + buf_cli-host.obj-name + "               " + "ПРОСМОТР".
    when {&add-def} then
    frame {&frame-name}:title = "СКЛАД  фирмы : " + buf_cli-host.obj-name + "               " + "ДОБАВЛЕНИЕ".
    when {&update} then
    frame {&frame-name}:title = "СКЛАД  фирмы : " + buf_cli-host.obj-name + "               " + "ИЗМЕНЕНИЕ".
  END CASE.
  if glog then do:
    run reset-from-sysconf in this-procedure ( input yes
                                            , input tt-store.host-code
                                                    ).
  end.
END.
ELSE DO:
    run adm/config.w (
                          input parparentproc /*parparentproc*/
                         ,input tt-store.host-code
                         ,input  {&lookup}
                         ,input no /*p-is-deploy*/
                         ) no-error.
    if error-status:error then return no-apply.
END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-inpay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-inpay Dialog-Frame
ON CHOOSE OF b-inpay IN FRAME Dialog-Frame
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.
    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = "" then return no-apply.
    else do:
        find buf_pay-type where recid( buf_pay-type ) = int(ref-rec) no-lock .
        assign
          tt-store.in-pay = buf_pay-type.obj-code .
        display tt-store.in-pay with frame {&frame-name}.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-invpay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-invpay Dialog-Frame
ON CHOOSE OF b-invpay IN FRAME Dialog-Frame
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.

    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = "" then  return no-apply.
    else do:
      FIND buf_pay-type WHERE
             recid( buf_pay-type ) = int(ref-rec) NO-LOCK .
      assign
      tt-store.inv-pay = buf_pay-type.obj-code .
      display
        tt-store.inv-pay with frame {&frame-name}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-outpay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-outpay Dialog-Frame
ON CHOOSE OF b-outpay IN FRAME Dialog-Frame
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.
    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = "" then return no-apply.
    else do:
      find buf_pay-type where
              recid( buf_pay-type ) = int(ref-rec) no-lock .
      assign
      tt-store.out-pay = buf_pay-type.obj-code .
      display
      tt-store.out-pay
      with frame {&frame-name}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-reset
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-reset Dialog-Frame
ON CHOOSE OF b-reset IN FRAME Dialog-Frame /* Уст.Сист. */
DO:
if p-mode = {&add-def} and tt-store.host-code = 0 then do:
    message
    "Фирма для скалада еще не определена" skip
    "Скопировать настройки с настроек по умолчанию невозможно"
    view-as alert-box error .
    return no-apply.
  end.
  message
  "Скопировать настройки для данного склада" skip
  "из аналогичных настроек для фирмы?" view-as alert-box question
  buttons yes-no set OK as log .
  if OK then do:
    run reset-from-sysconf in this-procedure ( input yes, input tt-store.host-code ).
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-retpay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-retpay Dialog-Frame
ON CHOOSE OF b-retpay IN FRAME Dialog-Frame
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.
    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = "" then return no-apply.
    else do:
        FIND buf_pay-type WHERE
                 recid( buf_pay-type ) = int(ref-rec) NO-LOCK .
        assign
        tt-store.ret-pay = buf_pay-type.obj-code .
        display
        tt-store.ret-pay
        with frame {&frame-name}.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-spipay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-spipay Dialog-Frame
ON CHOOSE OF b-spipay IN FRAME Dialog-Frame
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.
    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = "" then return no-apply.
    else do:
        FIND buf_pay-type WHERE
                 recid( buf_pay-type ) = int(ref-rec) NO-LOCK .
        assign
        tt-store.down-pay = buf_pay-type.obj-code .
        display
        tt-store.down-pay
        with frame {&frame-name}.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-suppay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-suppay Dialog-Frame
ON CHOOSE OF b-suppay IN FRAME Dialog-Frame
DO:
    define variable ref-rec as character no-undo .
    define buffer buf_pay-type for ub.pay-type.
    run ref/paytype.w (input parparentproc, "b-sel", output ref-rec ).
    apply "ENTRY" to self .
    if ref-rec = "" then return no-apply.
    else do:
        FIND buf_pay-type WHERE
                recid( buf_pay-type ) = int(ref-rec) NO-LOCK .
        assign
        tt-store.ret-sup-pay = buf_pay-type.obj-code .
        display
               tt-store.ret-sup-pay with frame {&frame-name}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_trn-reason
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_trn-reason Dialog-Frame
ON CHOOSE OF Btn_trn-reason IN FRAME Dialog-Frame /* Коды оснований */
DO:
  run str/obj-rsn.w ( input parparentproc
                , input {&stock}
                , input p-obj-code
                , input ( if p-mode = {&lookup} then {&lookup} else {&work} )
                ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-clients.db-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-clients.db-num Dialog-Frame
ON CTRL-enter OF tt-clients.db-num IN FRAME Dialog-Frame /* Номер БД */
DO:
    define variable  ri as recid no-undo.
  define buffer buf_db for ub.db .
  run adm/dbs.w (
                input parparentproc
               ,input {&lookup}
               ,output ri).

  if ri <> ? then  do:
    FIND first buf_db where recid( ub.db ) = ri .
    display
    buf_db.db-num @ tt-clients.db-num
    with frame {&frame-name}.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-clients.db-num Dialog-Frame
ON RETURN OF tt-clients.db-num IN FRAME Dialog-Frame /* Номер БД */
DO:
   RUN chk-db no-error.
  if error-status:error  THEN do:
    apply "ctrl-enter":U to self.
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-store.doc-prt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-store.doc-prt Dialog-Frame
ON VALUE-CHANGED OF tt-store.doc-prt IN FRAME Dialog-Frame /* Учет по шкалам */
DO:
  define variable glog as logical no-undo .
  if p-mode <> {&add-def} then do:
    if (tt-store.doc-prt:checked ) <> tt-store.doc-prt
    then do:
      run trg/objatchk.p
        (input {&stock}          /* p-obj-type  */
        ,input tt-store.obj-code /* p-obj-code  */
        ,input "doc-prt":u       /* p-action    */
        ,input tt-store.doc-prt :checked in frame {&frame-name}  /* p-new-value */
        ) no-error .
      if error-status :error then do:
        assign
        tt-store.doc-prt :checked in frame {&frame-name} = tt-store.doc-prt
        .
        return no-apply .
      end.
    end.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-choose
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-choose Dialog-Frame
ON CHOOSE OF MENU-ITEM m-choose /* Подобрать свободный код */
DO:
   DEFINE VARIABLE v-obj-code LIKE ub.clients.obj-code NO-UNDO.
  run ref/chs-code.w ({&stock}, v-cntxt-db-num, OUTPUT v-obj-code) no-error .
  if not error-status:error
  and v-obj-code <> ? then do:
    display
    v-obj-code @ tt-store.obj-code
    with frame {&frame-name} .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-store.shift-on
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-store.shift-on Dialog-Frame
ON VALUE-CHANGED OF tt-store.shift-on IN FRAME Dialog-Frame /* Включены смены */
DO:
    if p-mode <> {&add-def} then do:
    if tt-store.shift-on :checked in frame {&frame-name} <> tt-store.shift-on
    then do:
      run trg/objatchk.p
        (input {&stock}          /* p-obj-type  */
        ,input tt-store.obj-code /* p-obj-code  */
        ,input "shift-on":u       /* p-action    */
        ,input tt-store.shift-on :checked in frame {&frame-name}  /* p-new-value */
        ) no-error .
      if error-status :error
      then do:
        assign
        tt-store.shift-on :checked in frame {&frame-name} = tt-store.shift-on
        .
        return no-apply .
      end.
    end.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varenvd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varenvd Dialog-Frame
ON VALUE-CHANGED OF varenvd IN FRAME Dialog-Frame /* ЕНВД */
DO:
  ASSIGN FRAME
    {&FRAME-NAME} {&self-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varpharm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varpharm Dialog-Frame
ON VALUE-CHANGED OF varpharm IN FRAME Dialog-Frame /* Аптека */
DO:
  ASSIGN FRAME
    {&FRAME-NAME} {&self-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varpurch-code-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varpurch-code-name Dialog-Frame
ON VALUE-CHANGED OF varpurch-code-name IN FRAME Dialog-Frame /* Тип приобретения */
DO:
  ASSIGN FRAME {&FRAME-NAME}
    varpurch-code-name.

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

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
   if p-mode <> {&add-def} and
      p-mode <> {&update}  and
      p-mode <> {&lookup}
 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"  p-mode
    view-as alert-box ERROR.
    undo, return error.
 end.
 { gbl/curdbnum.i v-db-num }
if p-mode <> {&lookup} then do:
  if v-db-num <> 0 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode - нельзя изменять/добавлять записи СКЛАД в УБД"
    view-as alert-box ERROR.
    undo, return error.
  end.
end.
for each tt-store:
  delete tt-store.
end.
for each tt-clients:
  delete tt-clients.
end.

if p-mode = {&add-def}  then do:
    message
    "Вам следует выбрать группу," skip
    "к которой будет относиться склад."
    view-as alert-box.
    ref-list = "".
    run ref/cli-grps.w ( input parparentproc, "b-sel", input-output ref-list ) .
    if ref-list <> "" then  do:
      FIND buf_cli-grp where
          recid( buf_cli-grp ) = integer( ref-list ) .
      if can-find( FIRST ub.cli-grp where ub.cli-grp.upper-code = buf_cli-grp.node-code )
      then do:
        message
        "Добавлять можно только в группы," skip
        "у которых нет подгрупп." skip
        "Выбирайте другую группу !".
        return .
      end.
    end.
    else return .
    create tt-clients.
    create tt-store.
    assign
    tt-clients.grp-code = buf_cli-grp.node-code
    tt-clients.obj-type = {&stock}
    tt-store.doc-prt = false
    tt-store.work-hours = if tt-store.work-hours <> "" then tt-store.work-hours else "08.00,20.00"
    .
  end.
  else do: /*no add-def*/
    if p-mode = {&update} then do:
      do transaction
      ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
      ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
        FIND first locked_clients exclusive-lock where
                recid( locked_clients ) = p-rid no-error .
        if not available locked_clients then do:
          FIND first locked_clients exclusive-lock where
                  locked_clients.obj-type = {&stock}
                AND locked_clients.obj-code = p-obj-code no-wait no-error .
        if locked locked_clients then do:
          message
          vss-workfile vss-revision vss-description skip
          "Запись КЛИЕНТ для СКЛАДА" p-obj-code "занята"
          view-as alert-box error .
          undo, return error.
        end.
        end.
        FIND first locked_store exclusive-lock where
                  locked_store.obj-code = locked_clients.obj-code .
      end.
    end.
    if p-mode = {&lookup} then do:
      FIND first locked_clients no-lock where
              recid( locked_clients ) = p-rid.
      FIND first locked_store no-lock where
                locked_store.obj-code = locked_clients.obj-code .
    end.
    create tt-clients.
    create tt-store.
    buffer-copy locked_clients to tt-clients.
    buffer-copy locked_store to tt-store.
    FIND FIRST buf_cli-host NO-LOCK WHERE
               buf_cli-host.obj-code = locked_store.host-code AND
               buf_cli-host.obj-type = {&cmp} NO-ERROR.
      if avail buf_cli-host then do:
        assign
        frame {&frame-name}:title =
        "Настройки склада фирмы ~"" + buf_cli-host.obj-name +
        "~" ("   + string( tt-store.host-code )   + ").".
      end.
    end.
    assign
    tt-store.work-hours = if tt-store.work-hours <> "" then tt-store.work-hours else "08.00,20.00"
    .
  ASSIGN
    varpurch-code-name:LIST-ITEMS = {&purch-like-firm} + "," + {&purchase-codes-full}.
  IF tt-store.purch-code = ? THEN DO:
    ASSIGN
      varpurch-code-name = {&purch-like-firm}.
  END.
  ELSE DO:
    &scop purchase-code string(tt-store.purch-code)
    assign
      varpurch-code-name = {&purchase-codes-name}.
  END.
    RUN clntattr-value IN THIS-PROCEDURE
    (INPUT {&stock},
     INPUT tt-store.obj-code,
     INPUT {&attr-envd},
     OUTPUT v-envd,
     OUTPUT v-type).
  IF v-envd = "yes":u THEN DO:
    ASSIGN
      varenvd = YES.
  END.
  ELSE DO:
    ASSIGN
      varenvd = NO.
  END.
  
  /* КПП */
  RUN clntattr-value IN THIS-PROCEDURE
    (INPUT {&stock},
     INPUT tt-store.obj-code,
     input {&attr-kpp},
     OUTPUT v-kpp,
     OUTPUT v-type).
   kpp:screen-value = v-kpp.
     
    RUN clntattr-value IN THIS-PROCEDURE
    (INPUT {&stock},
     INPUT tt-store.obj-code,
     INPUT {&attr-pharm},
     OUTPUT v-pharm,
     OUTPUT v-type).
  IF v-pharm = "yes":u THEN DO:
    ASSIGN
      varpharm = YES.
  END.
  ELSE DO:
    ASSIGN
      varpharm = NO.
  END.

  run init-firmhold in this-procedure.


  RUN Myenable.
  if p-mode = {&add-def} then
      WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS tt-store.obj-code.
  else
      WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS tt-clients.obj-name .

END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-db Dialog-Frame 
PROCEDURE chk-db :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
   if ( not can-find( ub.db where ub.db.db-num = input FRAME {&frame-name} tt-clients.db-num ))
  then do:
      message "Неверный номер. Номер может быть:" skip
                      "    0, 1, ... -- номер существующей БД" skip
                    /*  "    ?  -- объект не принадлежит ни какой БД"  skip*/
                    /* "    - 1 -- объект принадлежит всем БД." skip( 2 )*/
                      " CTRL-ENTER  -- вызов справочника."  view-as alert-box.
      apply "ENTRY":U  to tt-clients.db-num IN FRAME {&frame-name}.
      return error.
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
  DISPLAY KPP varpharm varenvd varpurch-code-name EDITOR-1  
          fi-holdfirm-code fi-holdfirm-name 
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-clients THEN 
    DISPLAY tt-clients.db-num tt-clients.obj-name tt-clients.PS 
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-store THEN 
    DISPLAY tt-store.obj-code tt-store.store-man tt-store.store-boss 
          tt-store.addres1 tt-store.phone tt-store.addres2 tt-store.fax 
          tt-store.work-hours tt-store.holidays tt-store.load-time 
          tt-store.rsrv-time tt-store.in-pay tt-store.doc-prt tt-store.out-pay 
          tt-store.price-calc tt-store.no-eq tt-store.ret-pay 
          tt-store.unit-cli-perm tt-store.ret-sup-pay tt-store.out-line-discnt 
          tt-store.down-pay tt-store.out-rate tt-store.in-ov tt-store.inv-pay 
          tt-store.inout-price tt-store.fbr-pay tt-store.shift-on 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit b-reset b-host tt-clients.db-num b-db B-hist B-Help 
         RECT-10 tt-store.obj-code B-attr tt-clients.obj-name Btn_trn-reason 
         tt-store.store-man KPP tt-store.store-boss tt-store.addres1 
         tt-store.phone tt-store.addres2 tt-store.fax tt-store.work-hours 
         tt-store.holidays tt-store.load-time tt-store.rsrv-time 
         tt-store.in-pay b-inpay tt-store.doc-prt tt-store.out-pay b-outpay 
         tt-store.price-calc tt-store.no-eq tt-store.ret-pay b-retpay 
         tt-store.unit-cli-perm tt-store.ret-sup-pay b-suppay 
         tt-store.out-line-discnt tt-store.down-pay b-spipay tt-store.out-rate 
         tt-store.in-ov tt-store.inv-pay b-invpay tt-store.inout-price 
         tt-store.fbr-pay b-fbrpay tt-store.shift-on varpharm varenvd 
         b-holdfirm tt-clients.PS  
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-firmhold Dialog-Frame 
PROCEDURE init-firmhold :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define variable v-outhold       as character    no-undo.
    define variable v-par-type      as character    no-undo.
    define variable v-firm-code-str as character    no-undo.
    define variable v-firm-code     as integer      no-undo.

    define buffer buf_clients   for ub.clients.
    define buffer buf_store     for ub.store.
do
for buf_clients
  , buf_store
on error undo, return error
:
    if available tt-store
    and tt-store.host-code <> 0
    then do:
        find first buf_store no-lock
             where buf_store.obj-code = tt-store.obj-code
        no-error.
        if available buf_store
        then do:
            run gbl/conf-rd.p (
                input "outhold":U
                , input tt-store.host-code
                , input {&stock}            /*p-obj-type*/
                , input tt-store.obj-code   /*p-obj-code*/
                , input "":U
                , input "":U
                , input "":U
                , input no
                , output v-outhold
                , output v-par-type
            ) no-error.
            if error-status :error
            then do:
                assign
                    v-outhold            = ""
                .
            end.
            if v-outhold <> "":U
            then do:
                assign
                    v-storei-have-holdfirm                              = yes
                .
                run clntattr-value in this-procedure (
                    input {&stock}
                    , input tt-store.obj-code
                    , input {&attr-holdfirm-code}
                    , output v-firm-code-str
                    , output v-par-type
                ).
                assign
                    v-firm-code = integer( v-firm-code-str )
                no-error.
                if error-status :error
                then do:
                    assign
                        v-firm-code = 0
                    .
                end.
                else do:
                    if v-firm-code = 0
                    then do:
                        assign
                            fi-holdfirm-code = 0
                            fi-holdfirm-name = "":U
                        .
                    end.
                    else do:
                        find first buf_clients no-lock
                            where buf_clients.obj-type = {&cmp}
                            and buf_clients.obj-code = v-firm-code
                        no-error.
                        if available buf_clients
                        then do:
                            assign
                                fi-holdfirm-code = v-firm-code
                                fi-holdfirm-name = buf_clients.obj-name
                            .
                        end.
                        else do:
                            assign
                                fi-holdfirm-code = 0
                                fi-holdfirm-name = "":U
                            .
                        end.
                    end.
                end.
            end.
            else do:
                assign
                    v-storei-have-holdfirm                              = no
                .
            end.
        end.        /* if available buf_store */
    end.        /* if available tt-store */
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyENable Dialog-Frame 
PROCEDURE MyENable :
IF AVAILABLE tt-clients THEN
    DISPLAY
    tt-clients.obj-name
    tt-clients.db-num
    tt-clients.PS
    WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-store THEN
    DISPLAY
    tt-store.obj-code
    tt-store.store-boss
    tt-store.store-man
    tt-store.addres1
    tt-store.phone
    tt-store.addres2
    tt-store.fax
    tt-store.work-hours
    tt-store.holidays
    tt-store.load-time
    tt-store.rsrv-time
    tt-store.in-pay
    tt-store.doc-prt
    tt-store.out-pay
    tt-store.price-calc
    tt-store.no-eq
    tt-store.ret-pay
    tt-store.unit-cli-perm
    tt-store.ret-sup-pay
    tt-store.fbr-pay
    /*
    tt-store.in-perm
    */
    tt-store.down-pay
    tt-store.out-line-discnt
    tt-store.inv-pay
    tt-store.out-rate
    tt-store.in-ov
    tt-store.inout-price
    tt-store.shift-on
    varpurch-code-name
    varenvd
    varpharm
   WITH FRAME Dialog-Frame.
  ENABLE
  RECT-10
  b-quit
  B-Help
  b-hist WHEN p-mode <> {&add-def}
  b-host
  b-attr WHEN p-mode <> {&add-def}
  Btn_trn-reason WHEN p-mode <> {&add-def}
  KPP
  WITH FRAME Dialog-Frame.
  if p-mode = {&lookup} then do:
    assign
    b-quit:label = "&Выход".
    hide
    b-exit in frame {&frame-name}.
  end.
  else do:
    ENABLE
    B-exit
    b-reset
    tt-store.obj-code    when p-mode = {&add-def}
    tt-store.store-boss
    tt-store.store-man
    tt-store.work-hours
    tt-store.holidays
    tt-clients.obj-name
    tt-clients.PS
    tt-store.phone
    tt-store.addres1
    tt-store.addres2
    tt-store.fax
    tt-store.rsrv-time
    tt-store.load-time
    tt-store.doc-prt
    tt-store.price-calc
    tt-store.in-pay
    b-inpay
    tt-store.no-eq
    tt-store.out-pay
    b-outpay
    tt-store.unit-cli-perm
    /*
    tt-store.in-perm
    */
    tt-store.ret-pay
    b-retpay
    tt-store.out-rate
    tt-store.ret-sup-pay
    tt-store.fbr-pay
    tt-store.no-eq
    tt-store.out-rate
    tt-store.price-calc
    b-suppay
    tt-store.out-line-discnt
    tt-store.down-pay
    b-spipay
    tt-store.in-ov
    tt-store.inv-pay
    b-invpay
    tt-store.inout-price
    tt-clients.db-num when p-mode = {&add-def}
    b-db when p-mode = {&add-def}
    tt-store.shift-on
    varpurch-code-name
    varenvd
    varpharm
    WITH FRAME Dialog-Frame.
  end.
  if p-mode <> {&add-def} then do:
     run reset-from-sysconf in this-procedure ( input no, input tt-store.host-code ).
     MENU-ITEM m-choose:SENSITIVE IN MENU MENU-obj-code = NO.
  end.
  VIEW FRAME {&frame-name}.
    if v-storei-have-holdfirm = yes
    then do:
        assign
            fi-holdfirm-code :visible   in frame {&frame-name}    = yes
            fi-holdfirm-name :visible   in frame {&frame-name}    = yes
            b-holdfirm       :visible   in frame {&frame-name}    = yes
            fi-holdfirm-code :sensitive in frame {&frame-name}    = no
            fi-holdfirm-name :sensitive in frame {&frame-name}    = no
        .
        if p-mode = {&lookup}
        then do:
            assign
                b-holdfirm       :sensitive in frame {&frame-name}    = no
            .
        end.
        else do:
            assign
                b-holdfirm       :sensitive in frame {&frame-name}    = yes
            .
        end.
        display
            fi-holdfirm-code
            fi-holdfirm-name
        with frame {&frame-name}.
    end.
    else do:
        assign
            fi-holdfirm-code :visible in frame {&frame-name}    = no
            fi-holdfirm-name :visible in frame {&frame-name}    = no
            b-holdfirm       :visible in frame {&frame-name}    = no
        .
    end.
  if p-mode = {&add-def} then do:
    message
    "Вам следует выбрать фирму," skip
    "к которой будет относиться склад"
    view-as alert-box .
    apply "CHOOSE" to b-host in frame {&frame-name} .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define buffer buf_clients       for ub.clients.
do
for buf_clients
on error undo, return error
:
if p-mode = {&add-def} then do:
  if new-host-code = ?
  or new-host-code = 0
  then do:
    message
    "Фирма не выбрана."
    view-as alert-box error.
    return error .
  end.
end.
assign
tt-store.obj-code            frame {&frame-name}
tt-clients.db-num
tt-clients.obj-name
tt-clients.PS
tt-store.addres1
tt-store.addres2
/*tt-store.chk-pay*/
tt-store.doc-prt
tt-store.down-pay
/*tt-store.dst-price*/
tt-store.fax
tt-store.holidays
tt-store.host-code           =  if  tt-store.host-code = 0
                               or tt-store.host-code = ?
                               then p-host-code
                               else tt-store.host-code
tt-store.in-ov
tt-store.in-pay
tt-store.in-perm
tt-store.inout-price
tt-store.inv-pay
tt-store.load-time
tt-store.no-eq
tt-store.out-line-discnt
tt-store.out-pay
tt-store.out-rate
tt-store.phone
tt-store.price-calc
tt-store.ret-pay
tt-store.ret-sup-pay
tt-store.fbr-pay
tt-store.rsrv-time
tt-store.shift-on
tt-store.store-boss
tt-store.store-man
tt-store.unit-cli-perm
tt-store.work-hours
.
assign
frame {&frame-name}
    kpp
.
if varpharm = true and  tt-store.doc-prt = true  then do:
   message "Нельзя на объекте вести сразу учет по шкалам и по партиям. Если Вы уверены что нужно использовать режим АПТЕКА, не используйте шкальный товар !"
   view-as alert-box information .
end.

run adm/store01.p (
              input-output p-rid
             ,input        p-mode
             ,input    tt-store.obj-code
             ,input    tt-clients.db-num
             ,input    tt-store.host-code
             ,input    tt-clients.grp-code
             ,input    tt-clients.obj-name
             ,input    tt-clients.PS
             ,input    yes
             ,input    tt-store.addres1
             ,input    tt-store.addres2
             /*,input    tt-store.chk-pay*/
             ,input    tt-store.doc-prt
             ,input    tt-store.down-pay
             /*,input    tt-store.dst-price              */
             ,input    tt-store.fax
             ,input    tt-store.holidays
             ,input    tt-store.in-ov
             ,input    tt-store.in-pay
             ,input    tt-store.in-perm
             ,input    tt-store.inout-price
             ,input    tt-store.inv-pay
             ,input    tt-store.load-time
             ,input    tt-store.no-eq
             ,input    tt-store.out-line-discnt
             ,input    tt-store.out-pay
             ,input    tt-store.out-rate
             ,input    tt-store.phone
             ,input    tt-store.price-calc
             ,input    tt-store.ret-pay
             ,input    tt-store.ret-sup-pay
             ,input    tt-store.fbr-pay
             ,input    tt-store.rsrv-time
             ,input    tt-store.shift-on
             ,input    tt-store.store-boss
             ,input    tt-store.store-man
             ,input    tt-store.unit-cli-perm
             ,input    tt-store.work-hours
             ,input    (if varpurch-code-name = {&purch-like-firm} then ? else lookup (varpurch-code-name, {&purchase-codes-full}))
             ,INPUT    varenvd
             ,INPUT    varpharm
             ,INPUT    KPP
            )
             no-error .
if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.
    assign
        fi-holdfirm-code
    .
    find first buf_clients no-lock
         where buf_clients.obj-type = {&cmp}
           and buf_clients.obj-code = fi-holdfirm-code
    no-error.
    if available buf_clients
    then do:
        run clntattr-write in this-procedure (
              input {&stock}
            , input tt-store.obj-code
            , input {&attr-holdfirm-code}
            , input string( fi-holdfirm-code )
        ).
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reset-from-sysconf Dialog-Frame 
PROCEDURE reset-from-sysconf :
define  input parameter p-reset as logical no-undo.
define input parameter p-host-code as integer no-undo .
define buffer buf_sysconf for ub.sysconf.
if p-reset then   do:
    FIND first buf_sysconf where
            buf_sysconf.host-code = p-host-code.
    assign
    tt-store.unit-cli-perm = buf_sysconf.unit-cli-perm
    tt-store.in-ov = buf_sysconf.in-ov
    tt-store.in-perm = buf_sysconf.in-perm
    tt-store.inout-price = buf_sysconf.inout-price
    tt-store.no-eq = buf_sysconf.no-eq
    tt-store.out-line-discnt = buf_sysconf.out-line-discnt
    tt-store.out-rate = buf_sysconf.out-rate
    tt-store.price-calc = buf_sysconf.price-calc
    tt-store.chk-pay = buf_sysconf.chk-pay
    tt-store.down-pay = buf_sysconf.down-pay
    tt-store.in-pay  = buf_sysconf.in-pay
    tt-store.inv-pay  = buf_sysconf.inv-pay
    tt-store.out-pay  = buf_sysconf.out-pay
    tt-store.ret-pay = buf_sysconf.ret-pay
    tt-store.ret-sup-pay = buf_sysconf.ret-sup-pay
    tt-store.fbr-pay = buf_sysconf.fbr-pay
    tt-store.rsrv-time  = buf_sysconf.rsrv-time
    tt-store.load-time  = buf_sysconf.load-time
    tt-store.holidays  = buf_sysconf.holidays
        .
end.
display
tt-store.unit-cli-perm
tt-store.in-ov
/*
tt-store.in-perm
*/
tt-store.inout-price
tt-store.no-eq
tt-store.out-line-discnt
tt-store.out-rate
tt-store.price-calc

/*tt-store.chk-pay*/
tt-store.down-pay
tt-store.in-pay
tt-store.out-pay
tt-store.inv-pay
tt-store.ret-pay
tt-store.ret-sup-pay
tt-store.fbr-pay
tt-store.rsrv-time
tt-store.load-time
tt-store.holidays

with frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

