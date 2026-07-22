&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_clients FOR ub.clients.
DEFINE BUFFER locked_firm FOR ub.firm.
DEFINE TEMP-TABLE tt-clients NO-UNDO LIKE ub.clients.
DEFINE TEMP-TABLE tt-firm NO-UNDO LIKE ub.firm.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка редактирования фирмы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/16/03
Author: Bakhtadze Natalya
Creation date: 12/16/03

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER         parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter         p-mode        as       character                    no-undo.
/* {&add-def}, {&update}, {&lookup}*/
define input parameter         p-code        like ub.firm.firm-code no-undo .
define input parameter         p-grp-code    like ub.clients.grp-code no-undo.
define input parameter         p-CallPoint   as character  no-undo .
/* cli-all,discards,{&table_sysconf} */
define input-output parameter  p-rid          as      recid   init ?          no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка редактирования фирмы".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/waitfram.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ gbl/clntattr.i }

define variable v-db-num like ub.db.db-num no-undo .
define variable is-fin as logical no-undo .
define variable nocorinn as logical no-undo .

define variable f3 like  ub.firm.addres1 no-undo.
define variable f4 like  ub.firm.addres2 no-undo.
define variable fp3 like ub.firm.post-addr1 no-undo.
define variable fp4 like ub.firm.post-addr1 no-undo.
define variable v-s-deploy as logical no-undo .

define buffer buf_clients for ub.clients.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-firm tt-clients locked_firm

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-firm.firm-code ~
tt-clients.obj-name tt-firm.engl-name tt-firm.inn tt-firm.okpo tt-firm.kpp ~
tt-firm.is-pboul tt-firm.okonh tt-clients.reg-code tt-firm.city ~
tt-firm.post-city tt-firm.ind tt-firm.post-ind tt-firm.director ~
tt-firm.contact-psn tt-firm.phone tt-firm.phone1-note tt-firm.fax ~
tt-firm.telex tt-firm.e-mail tt-firm.passp-ser tt-firm.passp-num ~
tt-firm.given-by tt-firm.tobj-code tt-clients.lim-kr tt-clients.PS ~
tt-clients.turnover-buyer tt-clients.turnover-buyer-gds 
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-firm.firm-code ~
tt-clients.obj-name tt-firm.engl-name tt-firm.inn tt-firm.okpo tt-firm.kpp ~
tt-firm.is-pboul tt-firm.okonh tt-clients.reg-code tt-firm.city ~
tt-firm.post-city tt-firm.ind tt-firm.post-ind tt-firm.director ~
tt-firm.contact-psn tt-firm.phone tt-firm.phone1-note tt-firm.fax ~
tt-firm.telex tt-firm.e-mail tt-firm.passp-ser tt-firm.passp-num ~
tt-firm.given-by tt-clients.lim-kr tt-clients.PS tt-clients.turnover-buyer ~
tt-clients.turnover-buyer-gds 
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-firm tt-clients
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-firm
&Scoped-define SECOND-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-clients
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-firm SHARE-LOCK, ~
      EACH tt-clients WHERE TRUE /* Join to ub.firm incomplete */ SHARE-LOCK, ~
      EACH locked_firm WHERE TRUE /* Join to ub.firm incomplete */ SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-firm SHARE-LOCK, ~
      EACH tt-clients WHERE TRUE /* Join to ub.firm incomplete */ SHARE-LOCK, ~
      EACH locked_firm WHERE TRUE /* Join to ub.firm incomplete */ SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-firm tt-clients locked_firm
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-firm
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame tt-clients
&Scoped-define THIRD-TABLE-IN-QUERY-Dialog-Frame locked_firm


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-firm.firm-code tt-clients.obj-name ~
tt-firm.engl-name tt-firm.is-pboul tt-firm.inn tt-firm.okpo tt-firm.kpp ~
tt-firm.okonh tt-clients.reg-code tt-firm.city tt-firm.post-city ~
tt-firm.ind tt-firm.post-ind tt-firm.director tt-firm.contact-psn ~
tt-firm.phone tt-firm.phone1-note tt-firm.fax tt-firm.telex tt-firm.e-mail ~
tt-firm.passp-ser tt-firm.passp-num tt-firm.given-by tt-clients.lim-kr ~
tt-clients.PS tt-clients.turnover-buyer tt-clients.turnover-buyer-gds 
&Scoped-define ENABLED-TABLES tt-firm tt-clients
&Scoped-define FIRST-ENABLED-TABLE tt-firm
&Scoped-define SECOND-ENABLED-TABLE tt-clients
&Scoped-Define ENABLED-OBJECTS B-exit b-quit b-dc b-bank Docs b-attr ~
b-sysconf b-hist B-Help T-check-inn b-region jj_change-address fcli b-cli
&Scoped-Define DISPLAYED-FIELDS tt-firm.firm-code tt-clients.obj-name ~
tt-firm.engl-name tt-firm.inn tt-firm.okpo tt-firm.kpp tt-firm.is-pboul ~
tt-firm.okonh tt-clients.reg-code tt-firm.city tt-firm.post-city ~
tt-firm.ind tt-firm.post-ind tt-firm.director tt-firm.contact-psn ~
tt-firm.phone tt-firm.phone1-note tt-firm.fax tt-firm.telex tt-firm.e-mail ~
tt-firm.passp-ser tt-firm.passp-num tt-firm.given-by tt-firm.tobj-code ~
tt-clients.lim-kr tt-clients.PS tt-clients.turnover-buyer ~
tt-clients.turnover-buyer-gds 
&Scoped-define DISPLAYED-TABLES tt-firm tt-clients
&Scoped-define FIRST-DISPLAYED-TABLE tt-firm
&Scoped-define SECOND-DISPLAYED-TABLE tt-clients
&Scoped-Define DISPLAYED-OBJECTS T-check-inn jj_change-address fcli

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-firm-code
       MENU-ITEM m-choose       LABEL "Подобрать свободный код".


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-attr
     LABEL "&Атрибуты"
     SIZE 10 BY 1.

DEFINE BUTTON b-bank
     LABEL "&Банки"
     SIZE 10 BY 1.

DEFINE BUTTON b-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY 1.

DEFINE BUTTON b-cli-cl
     IMAGE-UP FILE "btn-up-arrow":U
     IMAGE-DOWN FILE "btn-up-arrow":U
     IMAGE-INSENSITIVE FILE "btn-up-arrow":U
     LABEL "":L
     SIZE 3 BY 1.

DEFINE BUTTON b-dc
     LABEL "&Диск.карты"
     SIZE 12 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-hist
     LABEL "Истори&я":L
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-region
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY 1.

DEFINE BUTTON B-sysconf
     LABEL "Своя фирма"
     SIZE 20 BY 1.

DEFINE BUTTON Docs
     LABEL "&Док-ты"
     SIZE 10 BY 1.

DEFINE VARIABLE f1 AS CHARACTER FORMAT "X(50)":U
     VIEW-AS FILL-IN
     SIZE 52 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE f2 AS CHARACTER FORMAT "X(50)":U
     VIEW-AS FILL-IN
     SIZE 52 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE fcli AS CHARACTER FORMAT "X(256)":U
     LABEL "Торг.предст"
     VIEW-AS FILL-IN
     SIZE 39.8 BY 1 NO-UNDO.

DEFINE VARIABLE fp1 AS CHARACTER FORMAT "X(50)":U
     VIEW-AS FILL-IN
     SIZE 52 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE fp2 AS CHARACTER FORMAT "X(50)":U
     VIEW-AS FILL-IN
     SIZE 52 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE jj_change-address AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "&Юридический", 0,
"Поч&товый", 1
     SIZE 14 BY 2 NO-UNDO.

DEFINE VARIABLE T-check-inn AS LOGICAL INITIAL yes
     LABEL "Проверять"
     VIEW-AS TOGGLE-BOX
     SIZE 18 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-firm,
      tt-clients,
      locked_firm SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-dc AT ROW 1 COL 21
     b-bank AT ROW 1 COL 33
     Docs AT ROW 1 COL 43
     b-attr AT ROW 1 COL 53 WIDGET-ID 2
     B-sysconf AT ROW 1 COL 63 WIDGET-ID 8
     b-hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     tt-firm.firm-code AT ROW 2.43 COL 4.2 COLON-ALIGNED
          LABEL "Код"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
          BGCOLOR 15
     tt-clients.obj-name AT ROW 2.43 COL 25 COLON-ALIGNED
          LABEL "Название" FORMAT "X(130)"
          VIEW-AS FILL-IN
          SIZE 72 BY 1
          BGCOLOR 15
     tt-firm.engl-name AT ROW 3.62 COL 25 COLON-ALIGNED
          LABEL "Англ./второе назв." FORMAT "X(130)"
          VIEW-AS FILL-IN
          SIZE 72 BY 1
          BGCOLOR 15
     tt-firm.is-pboul AT ROW 4.81 COL 87
          LABEL "ПБОЮЛ"
          VIEW-AS TOGGLE-BOX
          SIZE 10 BY 1
     tt-firm.inn AT ROW 4.81 COL 7.8 COLON-ALIGNED
          LABEL "INN"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
          BGCOLOR 15
     T-check-inn AT ROW 4.81 COL 26.4
     tt-firm.okpo AT ROW 4.81 COL 47 COLON-ALIGNED
          LABEL "ОКПО" FORMAT "X(10)"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
          BGCOLOR 15
     tt-firm.kpp AT ROW 4.81 COL 66 COLON-ALIGNED
          LABEL "KPP"
          VIEW-AS FILL-IN
          SIZE 16.8 BY 1
     tt-firm.okonh AT ROW 6 COL 8 COLON-ALIGNED
          LABEL "OKONX"
          VIEW-AS FILL-IN
          SIZE 60 BY 1
          BGCOLOR 15
     tt-clients.reg-code AT ROW 6 COL 76 COLON-ALIGNED
          LABEL "Регион"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     b-region AT ROW 6 COL 82.6
     jj_change-address AT ROW 7.19 COL 2 NO-LABEL
     tt-firm.addres1 AT ROW 7.19 COL 24 COLON-ALIGNED NO-LABEL FORMAT "X(50)"
          VIEW-AS FILL-IN
          SIZE 52 BY 1
          BGCOLOR 15
     tt-firm.post-addr1 AT ROW 7.19 COL 45 COLON-ALIGNED
          LABEL "Адрес" FORMAT "X(50)"
          VIEW-AS FILL-IN
          SIZE 52 BY 1
          BGCOLOR 15
     tt-firm.addres2 AT ROW 8.38 COL 24 COLON-ALIGNED NO-LABEL FORMAT "X(50)"
          VIEW-AS FILL-IN
          SIZE 52 BY 1
          BGCOLOR 15
     tt-firm.post-addr2 AT ROW 8.38 COL 45 COLON-ALIGNED NO-LABEL FORMAT "X(50)"
          VIEW-AS FILL-IN
          SIZE 52 BY 1
          BGCOLOR 15
     f1 AT ROW 9.57 COL 24 COLON-ALIGNED NO-LABEL
     fp1 AT ROW 9.57 COL 45 COLON-ALIGNED NO-LABEL
     f2 AT ROW 10.76 COL 24 COLON-ALIGNED NO-LABEL
     fp2 AT ROW 10.76 COL 45 COLON-ALIGNED NO-LABEL
     tt-firm.city AT ROW 11.95 COL 15 COLON-ALIGNED
          LABEL "Страна, город"
          VIEW-AS FILL-IN
          SIZE 38 BY 1
          BGCOLOR 15
     tt-firm.ind AT ROW 11.95 COL 67.4 COLON-ALIGNED
          LABEL "Индекс"
          VIEW-AS FILL-IN
          SIZE 7 BY 1
          BGCOLOR 15
     tt-firm.post-city AT ROW 11.97 COL 15.6 COLON-ALIGNED WIDGET-ID 4
          LABEL "Страна, город"
          VIEW-AS FILL-IN
          SIZE 38 BY 1
          BGCOLOR 15
     tt-firm.post-ind AT ROW 11.95 COL 67.4 COLON-ALIGNED WIDGET-ID 6
          LABEL "Индекс"
          VIEW-AS FILL-IN
          SIZE 7 BY 1
          BGCOLOR 15
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     tt-firm.director AT ROW 13.14 COL 15 COLON-ALIGNED
          LABEL "Руководитель" FORMAT "X(50)"
          VIEW-AS FILL-IN
          SIZE 82 BY 1
          BGCOLOR 15
     tt-firm.contact-psn AT ROW 14.33 COL 15 COLON-ALIGNED
          LABEL "Контакт. лицо" FORMAT "X(50)"
          VIEW-AS FILL-IN
          SIZE 82 BY 1
          BGCOLOR 15
     tt-firm.phone AT ROW 15.52 COL 8.6 COLON-ALIGNED
          LABEL "Тел."
          VIEW-AS FILL-IN
          SIZE 13.8 BY 1
          BGCOLOR 15
     tt-firm.phone1-note AT ROW 15.52 COL 30.5 COLON-ALIGNED
          LABEL "Прим."
          VIEW-AS FILL-IN
          SIZE 17.4 BY 1
          BGCOLOR 15 FGCOLOR 0
     tt-firm.fax AT ROW 15.52 COL 55.4 COLON-ALIGNED
          LABEL "Факс"
          VIEW-AS FILL-IN
          SIZE 20.5 BY 1
          BGCOLOR 15
     tt-firm.telex AT ROW 16.71 COL 8.6 COLON-ALIGNED
          LABEL "Телекс"
          VIEW-AS FILL-IN
          SIZE 13.8 BY 1
          BGCOLOR 15 FGCOLOR 0
     tt-firm.e-mail AT ROW 16.71 COL 30.8 COLON-ALIGNED
          LABEL "e-mail" FORMAT "X(100)"
          VIEW-AS FILL-IN
          SIZE 66.4 BY 1
          BGCOLOR 15 FGCOLOR 0
     tt-firm.passp-ser AT ROW 17.9 COL 31 COLON-ALIGNED
          LABEL "Паспорт: серия"
          VIEW-AS FILL-IN
          SIZE 16.5 BY 1 TOOLTIP "Для ПБОЮЛ"
          BGCOLOR 15 FGCOLOR 0
     tt-firm.passp-num AT ROW 17.9 COL 55.5 COLON-ALIGNED
          LABEL "номер"
          VIEW-AS FILL-IN
          SIZE 20.4 BY 1 TOOLTIP "Для ПБОЮЛ"
          BGCOLOR 15 FGCOLOR 0
     tt-firm.given-by AT ROW 19.09 COL 15 COLON-ALIGNED
          LABEL "Выдан"
          VIEW-AS FILL-IN
          SIZE 82 BY 1 TOOLTIP "Для ПБОЮЛ"
          BGCOLOR 15 FGCOLOR 0 FORMAT "X(128)"
     fcli AT ROW 20.28 COL 14 COLON-ALIGNED
     b-cli AT ROW 20.28 COL 59
     b-cli-cl AT ROW 20.28 COL 62.5
     tt-firm.tobj-code AT ROW 20.28 COL 69.5 COLON-ALIGNED
          LABEL "Код"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
          BGCOLOR 15
     tt-clients.PS AT ROW 21.47 COL 8.6 NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
          SIZE 54.4 BY 2.67
          FONT 4
     tt-clients.lim-kr AT ROW 21.47 COL 77 COLON-ALIGNED
          LABEL "Лимит кредита"
          VIEW-AS FILL-IN
          SIZE 20 BY 1
          BGCOLOR 15
     tt-clients.turnover-buyer AT ROW 22.66 COL 64.2
          LABEL "Расчитывать обороты по пок-лю"
          VIEW-AS TOGGLE-BOX
          SIZE 36.8 BY .81 TOOLTIP "Рассчитывать обороты по покупателю"
     tt-clients.turnover-buyer-gds AT ROW 23.50 COL 67
          LABEL "в разрезе товаров"
          VIEW-AS TOGGLE-BOX
          SIZE 23.85 BY .81 TOOLTIP "Расcчитывать обороты покупателя в разрезе товаров"
     "Прим.:" VIEW-AS TEXT
          SIZE 6.5 BY .95 AT ROW 21.47 COL 1.5
     SPACE(92) SKIP(2)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "О Р Г А Н И З А Ц И Я"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_clients B "?" ? ub clients
      TABLE: locked_firm B "?" ? ub firm
      TABLE: tt-clients T "?" NO-UNDO ub clients
      TABLE: tt-firm T "?" NO-UNDO ub firm
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

/* SETTINGS FOR FILL-IN tt-firm.addres1 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE EXP-LABEL EXP-FORMAT                            */
ASSIGN
       tt-firm.addres1:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-firm.addres2 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE EXP-LABEL EXP-FORMAT                            */
ASSIGN
       tt-firm.addres2:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON b-cli-cl IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-firm.city IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-firm.contact-psn IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-firm.director IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-firm.e-mail IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-firm.engl-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN f1 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       f1:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN f2 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       f2:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-firm.fax IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-firm.firm-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       tt-firm.firm-code:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-firm-code:HANDLE.

/* SETTINGS FOR FILL-IN fp1 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       fp1:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN fp2 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       fp2:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-firm.given-by IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-firm.ind IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-firm.inn IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-firm.is-pboul IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-firm.kpp IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-clients.lim-kr IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-clients.obj-name IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-firm.okonh IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-firm.okpo IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-firm.passp-num IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-firm.passp-ser IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-firm.phone IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-firm.phone1-note IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-firm.post-addr1 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE EXP-LABEL EXP-FORMAT                            */
ASSIGN
       tt-firm.post-addr1:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-firm.post-addr2 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE EXP-LABEL EXP-FORMAT                            */
ASSIGN
       tt-firm.post-addr2:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-firm.post-city IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-firm.post-ind IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       tt-clients.PS:RETURN-INSERTED IN FRAME Dialog-Frame  = TRUE.

/* SETTINGS FOR FILL-IN tt-clients.reg-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-firm.telex IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-firm.tobj-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR TOGGLE-BOX tt-clients.turnover-buyer IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-clients.turnover-buyer-gds IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-firm,Temp-Tables.tt-clients WHERE ub.firm ...,Temp-Tables.locked_firm WHERE ub.firm ..."
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* О Р Г А Н И З А Ц И Я */
DO:
    run proc-save in this-procedure no-error.
    if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* О Р Г А Н И З А Ц И Я */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-attr Dialog-Frame
ON CHOOSE OF b-attr IN FRAME Dialog-Frame /* Атрибуты */
DO:
 define variable v-updated as logical no-undo .
 define variable v-is-error as logical no-undo .
 run ref/ca-attrr.p (
                    input parparentproc
                   ,input {&lookup}
                   ,input {&cmp}
                   ,input tt-firm.firm-code
                   ,input YES /*p-update-on-exit*/
                   ,output v-updated
                   ,output v-is-error
                   ) no-error.
  if error-status:error
  or v-is-error then do:
    message
    "Ошибка при вызове списка атрибутов клиента" skip
    error-status:get-message(1) skip
    return-value
    view-as alert-box .
    undo, return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-bank
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-bank Dialog-Frame
ON CHOOSE OF b-bank IN FRAME Dialog-Frame /* Банки */
DO:
define variable v-rid-list as character no-undo .
define variable v-rid as recid no-undo .
define variable glog as logical no-undo .
define variable v-status_ like ub.fin-schet.status_ no-undo init {&all}.
define buffer buf_sysconf for ub.sysconf.
if p-mode = {&add-def} then do:
  glog = no.
  message "Вы завершили ввод карточки клиента?"
  view-as alert-box QUESTION buttons YEs-No update glog.
  if not glog then return no-apply.
  if glog then do:
    run proc-save in this-procedure no-error .
    if error-status:error then return no-apply.
    assign
    p-mode = {&update}.
    run fill-table in this-procedure no-error .
    if error-status:error then return no-apply.
    run Myenable in this-procedure .
  END.
end.
  if p-callpoint = {&table_sysconf} then do:
    find first buf_sysconf no-lock where
              buf_sysconf.host-code = tt-firm.firm-code no-error.
    if available buf_sysconf then do:
      run ref/finschts.w (
                        INPUT parParentProc
                        ,input (if v-cntxt-host-code-obj = 0
                                then tt-firm.firm-code
                                else v-cntxt-host-code-obj)
                        ,input (if v-cntxt-host-code-obj > 0
                                then "b-add":U
                                else '')
                        ,input "company-host":U
                        ,input {&cmp}
                        ,input tt-firm.firm-code
                        ,input ?
                        ,input (if v-cntxt-host-code-obj = 0
                               then tt-firm.firm-code
                               else v-cntxt-host-code-obj)
                        ,input 0
                        ,input-output v-status_
                        ,input-output v-rid-list ).
    end.
  end.
  else do:
    if v-cntxt-host-code-obj = 0 then do:
      message
      "Нельзя посмотреть счета, так как в настоящий момент не определена текущая фирма"
      view-as alert-box error.
      undo, return no-apply.
    end.
    else do:
      run ref/finschts.w (
                        INPUT parParentProc
                        ,input v-cntxt-host-code-obj
                        ,input "b-add":U
                        ,input "cmp-host":U
                        ,input {&cmp}
                        ,input tt-firm.firm-code
                        ,input ?
                        ,input v-cntxt-host-code-obj
                        ,input 0
                        ,input-output v-status_
                        ,input-output v-rid-list ).
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cli Dialog-Frame
ON CHOOSE OF b-cli IN FRAME Dialog-Frame
DO:
    define variable ri-str as char init "" no-undo .
    run ref/cli-all.w (
                       input parParentProc
                      ,input "b-sel"
                      ,input {&prs}
                      ,input {&all}
                      ,input ?
                      ,input ?
                      ,input ",,,,,,NO"
                      ,input ?
                      ,output ri-str ) .
    apply "ENTRY" to b-exit.
    if ri-str <> "" then   do:
            find first buf_clients where recid ( buf_clients ) = integer( ri-str ) no-lock.
            if buf_clients.obj-type <> {&prs} then  do:
                    message
                    "Нужно выбрать ЧЕЛОВЕКА (тип чел) !"
                    view-as alert-box WARNING.
                    return no-apply.
                end.
            fcli = buf_clients.obj-name.
            disp
            fcli
            buf_clients.obj-code @ tt-firm.tobj-code with frame {&frame-name}.
        end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cli-cl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cli-cl Dialog-Frame
ON CHOOSE OF b-cli-cl IN FRAME Dialog-Frame
DO:
      assign fcli = "".
      if p-mode <> {&add-def} then do:
        assign
        tt-firm.tobj-code = 0.
        display
        tt-firm.tobj-code
        fcli with frame {&frame-name}.
      end.
      else
      display
      0 @ tt-firm.tobj-code
      fcli with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-dc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-dc Dialog-Frame
ON CHOOSE OF b-dc IN FRAME Dialog-Frame /* Диск.карты */
DO:
define variable rid-list    as  char no-undo .
run ref/discards.w (
                 input parparentproc
                ,input ""
                ,input "client":U
                ,input v-cntxt-host-code-obj
                ,input v-cntxt-obj-type
                ,input v-cntxt-obj-code
                ,input '':U /*p-first-main-card*/
                ,input recid( locked_clients )
                ,output rid-list ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist Dialog-Frame
ON CHOOSE OF b-hist IN FRAME Dialog-Frame /* История */
DO:
define variable v-rid-list as character no-undo .
     run ref/cclihist.w (
                      input parparentproc
                    , input 0 /*p-curr-host-code*/
                    , input "":U  /*p-curr-obj-type*/
                    , input 0  /*p-curr-obj-code*/
                    , input "":U /*bttns*/
                    , input "one":U /*p-mode*/
                    , input {&cmp} /*p-obj-type*/
                    , input tt-firm.firm-code /*p-obj-code*/
                    , input ? /*p-host-code*/
                    , input ? /* p-corr-user-db-num  */
                    , input "":U /* p-corr-user-name  */
                    , input "":U /* p-subject  */
                    , input v-cntxt-db-num /* p-db-num */
                    , input-output v-rid-list  ) no-error .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-region
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-region Dialog-Frame
ON CHOOSE OF b-region IN FRAME Dialog-Frame
DO:
  define buffer buf_regions for ub.regions.

  define variable v-reg-code like ub.regions.reg-code no-undo .

  run ref/regions.w ( input  parParentProc
                    , input  {&choose}
                    , output v-reg-code
                    ).
  /*apply "ENTRY" to b-exit.   А ЭТО ЧТО???*/
  if v-reg-code <> ? then do :
    find first buf_regions no-lock
      where buf_regions.reg-code = v-reg-code
    no-error .
    if not available buf_regions then do:
      message
        "Неверный код региона " v-reg-code
      view-as alert-box error.
      return no-apply.
    end.
    else do:
      assign
        tt-clients.reg-code = buf_regions.reg-code
      .
      display
        tt-clients.reg-code
      with frame {&frame-name}.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sysconf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sysconf Dialog-Frame
ON CHOOSE OF B-sysconf IN FRAME Dialog-Frame /* Своя фирма */
DO:
define variable v-ok as logical no-undo.
      { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      "'actn_host-reference_lookup':U"
      {&cntxt-global}
      0
      '':U
      0
      0
      0
      0
      true
      v-ok
    }
    if v-ok <> true
    then do:
      return no-apply.
    end.
    run adm/config.w
      (input  parParentProc
      ,input  tt-firm.firm-code
      ,input  {&lookup}
      ,input  no /*p-is-deploy*/
      ) no-error.
    if error-status :error
    then do:
      return no-apply.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Docs Dialog-Frame
ON CHOOSE OF Docs IN FRAME Dialog-Frame /* Док-ты */
DO:
DEFINE VARIABLE v-output as character no-undo.
define variable v-input-output as character no-undo .
run str/all-docs.w (
               input parparentproc
              ,input ?
              ,input ?
              ,input ?
              ,input {&client-cmp}
              ,input ? /*parstat*/
              ,input ? /*partype*/
              ,input ? /*parflag*/
              ,input ? /*parinternal*/
              ,input '':U /*bttns*/
              ,input '':U /*parext-doc-type*/
              ,input ? /*paris-hold*/
              ,input recid(locked_clients)
              ,output v-input-output
              ) no-error .
 apply "ENTRY" to b-exit.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-firm.is-pboul
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-firm.is-pboul Dialog-Frame
ON VALUE-CHANGED OF tt-firm.is-pboul IN FRAME Dialog-Frame /* ПБОЮЛ */
DO:
  ASSIGN
  tt-firm.is-pboul.
  CASE tt-firm.is-pboul:
      WHEN NO  THEN DO:
          IF p-mode <> {&LOOKUP} THEN DO:
            ASSIGN
            tt-firm.given-by  = "":U
            tt-firm.passp-num  = "":U
            tt-firm.passp-ser = "":U
            .
             DISPLAY
              tt-firm.given-by
              tt-firm.passp-num
              tt-firm.passp-ser
              WITH FRAME {&FRAME-NAME}.
              disable
              tt-firm.given-by
              tt-firm.passp-num
              tt-firm.passp-ser
              WITH FRAME {&FRAME-NAME}.
         END.
      END.
      WHEN yes  THEN DO:
        IF p-mode <> {&LOOKUP} THEN DO:
          ENABLE
          tt-firm.given-by
          tt-firm.passp-num
          tt-firm.passp-ser
          WITH FRAME {&FRAME-NAME}.
        END.
      END.
END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME jj_change-address
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL jj_change-address Dialog-Frame
ON VALUE-CHANGED OF jj_change-address IN FRAME Dialog-Frame
DO:
ASSIGN jj_change-address.
CASE jj_change-address:
  when 0 THEN DO:
    ASSIGN
    fp3 = input tt-firm.post-addr1
    fp4 = input tt-firm.post-addr2
    fp1
    fp2
    .
    if p-mode = {&update} then do:
      ASSIGN
      tt-firm.post-addr1
      tt-firm.post-addr2
      tt-firm.post-city
      tt-firm.post-ind
      .
    end.
    DISABLE
    tt-firm.post-addr1
    tt-firm.post-addr2
    fp1
    fp2
    tt-firm.post-city
    tt-firm.post-ind
    WITH FRAME {&frame-name}.
    HIDE
    tt-firm.post-addr1
    tt-firm.post-addr2
    fp1
    fp2
    tt-firm.post-city
    tt-firm.post-ind
    IN FRAME {&frame-name}.
    if p-mode = {&add-def} then do:
      DISPLAY
      f3 @ tt-firm.addres1
      f4 @ tt-firm.addres2
      f1
      f2
      tt-firm.city
      tt-firm.ind
      WITH FRAME {&frame-name}.
    end.
    else do:
      DISPLAY
      tt-firm.addres1
      tt-firm.addres2
      f1
      f2
       tt-firm.city
       tt-firm.ind
      WITH FRAME {&frame-name}.
    end.
    if p-mode <> {&lookup} then do:
      ENABLE
      tt-firm.addres1
      tt-firm.addres2
      f1
      f2
      tt-firm.city
      tt-firm.ind
      WITH FRAME {&frame-name}.
    end.
  END.
  when 1 THEN DO:
    ASSIGN
    f3 = input tt-firm.addres1
    f4 = input tt-firm.addres2
    f1
    f2.
    if p-mode = {&update} then
    ASSIGN
    tt-firm.addres1
    tt-firm.addres2
    tt-firm.city
    tt-firm.ind
    .
    DISABLE
    tt-firm.addres1
    tt-firm.addres2
    f1
    f2
    tt-firm.city
    tt-firm.ind
    WITH FRAME {&frame-name}.
    HIDE
    tt-firm.addres1
    tt-firm.addres2
    f1
    f2
    tt-firm.city
    tt-firm.ind
    IN FRAME {&frame-name}.
    if p-mode = {&add-def} then do:
      DISPLAY
      fp3 @ tt-firm.post-addr1
      fp4 @ tt-firm.post-addr2
      fp1
      fp2
      TT-FIRM.post-city
      tt-firm.post-ind
      WITH FRAME {&frame-name}.
    end.
    else do:
      DISPLAY
      tt-firm.post-addr1
      tt-firm.post-addr2
      fp1
      fp2
      tt-firm.post-city
      tt-firm.post-ind
      WITH FRAME {&frame-name}.
    end.
    if p-mode <> {&lookup} then do:
      ENABLE
      tt-firm.post-addr1
      tt-firm.post-addr2
      fp1
      fp2
      tt-firm.post-city
      tt-firm.post-ind
      WITH FRAME {&frame-name}.
    end.
  END.
END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-choose
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-choose Dialog-Frame
ON CHOOSE OF MENU-ITEM m-choose /* Подобрать свободный код */
DO:
  DEFINE VARIABLE v-obj-code LIKE ub.clients.obj-code NO-UNDO.
  run ref/chs-code.w ( input {&cmp}
                      ,input v-cntxt-db-num
                      ,OUTPUT v-obj-code) no-error .
  if not error-status:error
  and v-obj-code <> ? then do:
    display
    v-obj-code @ tt-firm.firm-code
    with frame {&frame-name} .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-firm.passp-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-firm.passp-num Dialog-Frame
ON LEAVE OF tt-firm.passp-num IN FRAME Dialog-Frame /* номер */
DO:
   IF trim(tt-firm.passp-num:SCREEN-VALUE) = "":U THEN
      ASSIGN
      tt-firm.passp-num:SCREEN-VALUE = ?.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-clients.turnover-buyer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-clients.turnover-buyer Dialog-Frame
ON VALUE-CHANGED OF tt-clients.turnover-buyer IN FRAME Dialog-Frame /* Расчитывать обороты по пок-лю */
DO:
  ASSIGN tt-clients.turnover-buyer .
  IF tt-clients.turnover-buyer THEN ENABLE tt-clients.turnover-buyer-gds WITH FRAME {&FRAME-NAME}.
      ELSE DISABLE tt-clients.turnover-buyer-gds WITH FRAME {&FRAME-NAME}.
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
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON STOP UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   :

assign
v-s-deploy = lookup("s-deploy":U, p-mode, ";") > 0
.
assign
p-mode = trim(replace(p-mode, "s-deploy":U, "":U), ";":U)
.
if p-mode  <> {&add-def}
  and p-mode <> {&update}
  and p-mode <> {&lookup}
  then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова p-mode"  p-mode
      view-as alert-box ERROR.
      undo, return error.
  end.

  if p-callpoint  <> "":U
  and p-callpoint <> "discards":U
  and p-callpoint <> "cli-all":U
  and p-callpoint <> {&table_sysconf}
  then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова p-callpoint"  p-callpoint
      view-as alert-box ERROR.
      undo, return error.
  end.

  { gbl/curdbnum.i v-db-num }
  if v-s-deploy then do:
     { gbl/getcntxt.i get }
  end.
  else do:
    { gbl/getcntxt.i get }
  end.
  run fill-table in this-procedure no-error.
  if error-status:error then return error.
  RUN Myenable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI in this-procedure .

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
  DISPLAY T-check-inn jj_change-address fcli
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-clients THEN
    DISPLAY tt-clients.obj-name tt-clients.reg-code tt-clients.PS
          tt-clients.lim-kr tt-clients.turnover-buyer tt-clients.turnover-buyer-gds
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-firm THEN
    DISPLAY tt-firm.firm-code tt-firm.engl-name tt-firm.is-pboul tt-firm.inn
          tt-firm.okpo tt-firm.kpp tt-firm.okonh tt-firm.city tt-firm.ind
          tt-firm.director tt-firm.contact-psn tt-firm.phone1-note tt-firm.phone
          tt-firm.fax tt-firm.telex tt-firm.e-mail tt-firm.passp-ser
          tt-firm.passp-num tt-firm.given-by tt-firm.tobj-code
          tt-firm.post-city
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit b-dc b-bank Docs b-attr B-sysconf b-hist B-Help
         tt-firm.firm-code tt-clients.obj-name tt-firm.engl-name
         tt-firm.is-pboul tt-firm.inn T-check-inn tt-firm.okpo tt-firm.kpp
         tt-firm.okonh tt-clients.reg-code b-region jj_change-address
         tt-firm.city tt-firm.ind tt-firm.director tt-firm.contact-psn
         tt-firm.phone1-note tt-firm.phone tt-firm.fax tt-firm.telex
         tt-firm.e-mail tt-firm.passp-ser tt-firm.passp-num tt-firm.given-by
         fcli b-cli tt-clients.PS tt-clients.lim-kr tt-clients.turnover-buyer
         tt-clients.turnover-buyer-gds tt-firm.post-city  tt-firm.post-ind  
         tt-firm.contact-psn
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-table Dialog-Frame
PROCEDURE fill-table :
define variable v-type as character no-undo .
define variable v-exist as logical no-undo .
  for each tt-clients :
    delete tt-clients.
  end.
  for each tt-firm :
    delete tt-firm.
  end.
  if p-mode = {&update}
  or p-mode = {&lookup} then do:
    if p-mode = {&update} then do:
      find first locked_clients EXclusive-lock where
            recid(locked_clients) = p-rid no-wait no-error.
      if locked locked_clients then do:
        find first locked_clients EXclusive-lock where
              recid(locked_clients) = p-rid no-error.
      end.
    end.
    else do:
      find first locked_clients no-lock where
                       recid(locked_clients) = p-rid no-error .
      if not avail locked_clients then do:
        find first locked_clients where
                  locKed_clients.obj-type = {&cmp}
             AND locKed_clients.obj-code = p-code no-error .
      end.
    end.
    if not available locked_clients then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись КЛИЕНТ"
      view-as alert-box error .
      undo, return error.
    end.
    if p-mode = {&update} then do:
      find first locked_firm EXclusive-lock where
            locked_firm.firm-code = locked_clients.obj-code no-wait no-error.
      if locked locked_firm then do:
        find first locked_firm EXclusive-lock where
              locked_firm.firm-code = locked_clients.obj-code  no-error.
      end.
    end.
    else do:
      find first locked_firm no-lock where
              locked_firm.firm-code = locked_clients.obj-code no-error .
    end.
    if not available locked_firm then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись ОРГАНИЗАЦИЯ"
      view-as alert-box error .
      undo, return error.
    end.
    create tt-clients.
    buffer-copy locked_clients to tt-clients.
    create tt-firm.
    buffer-copy locked_firm to tt-firm.
  end.
  else do:
    create tt-clients.
    create tt-firm.
    assign
    tt-clients.obj-type = {&cmp}
    tt-clients.obj-code = 0
    tt-clients.grp-code = p-grp-code
    tt-firm.firm-code = tt-clients.obj-code
    tt-clients.stts = 0
    .

  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
define variable for-code as integer no-undo .
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .

define buffer last_person for ub.person.

tt-firm.okonh:label in frame {&frame-name} = "{&abbr_okonh_allshift}".
tt-firm.inn:label in frame {&frame-name} = "{&abbr_inn_allshift}".
tt-firm.kpp:label in frame {&frame-name} = "{&abbr_kpp_allshift}".

/*узнаем в каком АРМ находимся*/

VIEW FRAME {&frame-name}.

{ gbl/conf-rd.i
"'is-fin'"
0
"''"
0
"''"
"''"
"''"
no
conf-par
par-type
no-error
}
IF not error-status:error then
assign
is-fin =  (if conf-par = "yes" then yes else no)
.
run adm/shattri.p (
      input "get":U
    ,input  '':U
    ,input  0
    ,input  {&attr-cli-all}
    ,input  {&attr-cli-all_nocorinn} /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output nocorinn
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .

delete object v-tth.

assign
fp1:column IN FRAME {&FRAME-NAME}= f1:column IN FRAME {&FRAME-NAME}
fp2:column = f2:column IN FRAME {&FRAME-NAME}
tt-firm.post-addr1:column = tt-firm.addres1:column
tt-firm.post-addr1:label = tt-firm.addres1:label
tt-firm.post-addr2:column = tt-firm.addres2:column
jj_change-address = 0
f1 = substring( tt-firm.addres1, 51, 50 )
f2 = substring( tt-firm.addres1, 101, 50 )
fp1 = substring( tt-firm.post-addr1, 51, 50 )
fp2 = substring( tt-firm.post-addr1, 101, 50 )
.

IF AVAILABLE tt-clients THEN
  DISPLAY
  tt-clients.obj-name
  tt-clients.lim-kr
  tt-clients.PS
  tt-clients.reg-code
  WITH FRAME Dialog-Frame.
IF AVAILABLE tt-firm THEN
  DISPLAY
  tt-firm.contact-psn
  tt-firm.director
  tt-firm.e-mail
  tt-firm.engl-name
  tt-firm.fax
  tt-firm.firm-code
  tt-firm.given-by
  tt-firm.inn
  t-check-inn when p-mode <> {&lookup}
  tt-firm.is-pboul
  tt-firm.kpp
  tt-firm.okonh
  tt-firm.okpo
  tt-firm.passp-num
  tt-firm.passp-ser
  tt-firm.phone
  tt-firm.phone1-note
  tt-firm.telex
  tt-firm.tobj-code
  tt-clients.turnover-buyer
  tt-clients.turnover-buyer-gds
  WITH FRAME Dialog-Frame.
if tt-firm.tobj-code <> 0 then do:
    find first buf_clients no-lock where buf_clients.obj-code = tt-firm.tobj-code and buf_clients.obj-type = {&prs} no-error .
    if AVAILABLE buf_clients then fcli = buf_clients.obj-name .
    display
    fcli with frame {&frame-name}.
end.    
assign
frame {&frame-name} :title = "О Р Г А Н И З А Ц И Я:" + {&space-char} + p-mode
.
if p-mode <> {&lookup} then do:
  define variable v-enable-lim-kr as logical no-undo .
  { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_client-requisite_add-upd':U
  {&cntxt-global}
  0
  '':U
  0
  0
  0
  0
  false
  v-enable-lim-kr
  }
  ENABLE
  B-exit
  b-quit
  b-dc   when p-mode <> {&add-def} and p-callpoint <> "discards":U
  b-bank when p-mode <> {&add-def}
  Docs   when p-mode <> {&add-def} and v-cntxt-level = {&cntxt-object}
  b-hist when p-mode <> {&add-def}
  b-cli
/*  b-cli-cl*/
  B-Help
  b-region
  b-sysconf
  tt-firm.firm-code  when p-mode = {&add-def}
  tt-clients.obj-name
  tt-firm.contact-psn
  tt-firm.director
  tt-firm.e-mail
  tt-firm.engl-name
  tt-firm.fax
  tt-firm.given-by
  tt-firm.inn
  t-check-inn when nocorinn
  tt-firm.is-pboul
  tt-firm.kpp
  tt-firm.okonh
  tt-firm.okpo
  tt-firm.passp-num
  tt-firm.passp-ser
  tt-firm.phone
  tt-firm.phone1-note
  tt-firm.telex
  tt-firm.tobj-code
  tt-clients.lim-kr when v-enable-lim-kr
  tt-clients.PS
  tt-clients.turnover-buyer when v-cntxt-db-num =0
  tt-clients.turnover-buyer-gds when tt-clients.turnover-buyer = true and v-cntxt-db-num =0
  jj_change-address
  WITH FRAME {&frame-name}.
  tt-clients.PS:read-only = no.
  HIDE
  b-attr IN FRAME {&FRAME-NAME}.
end.
else do: /*lookup*/
  ENABLE
  b-quit
  b-dc   when p-callpoint <> "discards":U and v-cntxt-level = {&cntxt-object}
  b-bank
  Docs when v-cntxt-level = {&cntxt-object}
  b-sysconf
  b-hist
  B-Help
  jj_change-address
  tt-clients.ps
  b-attr
  with frame {&frame-name} .
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1
  tt-clients.PS:read-only = yes
  .
  hide
  b-exit
  t-check-inn
  in frame {&frame-name} .
end.
if p-mode <> {&add-def} then do:
  MENU-ITEM m-choose:SENSITIVE IN MENU MENU-firm-code = NO .
end.
assign
b-sysconf:visible in frame {&frame-name} = (p-mode <> {&add-def} and can-find(first ub.sysconf where ub.sysconf.host-code = tt-clients.obj-code))
.

assign
  b-bank:label = "&Счета".
  define variable v-use-grp-buy           as logical   no-undo .
  define variable v-use-oborot-buy        as logical   no-undo .
  define variable v-use-qnty-group        as logical   no-undo .
  define variable v-use-sum-group         as logical   no-undo .
  define variable v-use-add-code          as logical   no-undo .
  define variable v-use-sys-date-time     as logical   no-undo .
  define variable v-use-shift-date-num    as logical   no-undo .
  define variable v-use-cassa             as logical   no-undo .
  define variable v-use-val               as logical   no-undo .
  define variable v-use-pay-type          as logical   no-undo .
  define variable v-use-cash-pay          as logical   no-undo .
  define variable v-use-child as logical
no-undo.
{ gbl/glstall.i
  v-use-grp-buy
  v-use-oborot-buy
  v-use-qnty-group
  v-use-sum-group
  v-use-add-code
  v-use-sys-date-time
  v-use-shift-date-num
  v-use-cassa
  v-use-val
  v-use-pay-type
  v-use-cash-pay
  v-use-child
  no-error
}

if not (v-use-grp-buy  or  v-use-oborot-buy) then
  do:
    hide
    tt-clients.turnover-buyer
    tt-clients.turnover-buyer-gds
    in frame {&frame-name}.
  end.
VIEW FRAME {&frame-name}.
APPLY "VALUE-CHANGED":U TO jj_change-address IN FRAME {&frame-name}.
APPLY "VALUE-CHANGED":U TO tt-firm.is-pboul IN FRAME {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Proc-save Dialog-Frame
PROCEDURE Proc-save :
define variable v-no-check-inn as logical no-undo .
define variable ii as integer no-undo .
define variable v-return-value as character no-undo .
define variable glog as logical no-undo .

if p-mode = {&add-def} then
assign
frame {&frame-name}
tt-firm.firm-code
.
assign
f3 = input frame {&frame-name} tt-firm.addres1
f4 = input frame {&frame-name} tt-firm.addres2
fp3 = input frame {&frame-name} tt-firm.post-addr1
fp4 = input frame {&frame-name} tt-firm.post-addr2
.

if p-mode <> {&add-def} then do:
  if tt-firm.addres1:visible     in frame {&frame-name}
  then assign tt-firm.addres1.
  if tt-firm.addres2:visible     in frame {&frame-name}
  then assign tt-firm.addres2.
  if tt-firm.post-addr1:visible in frame {&frame-name}
  then assign tt-firm.post-addr1.
  if tt-firm.post-addr2:visible in frame {&frame-name}
  then assign tt-firm.post-addr2.
  if tt-firm.post-city:visible in frame {&frame-name}
  then assign tt-firm.post-city.
  if tt-firm.post-ind:visible in frame {&frame-name}
  then assign tt-firm.post-ind.
  if tt-firm.city:visible in frame {&frame-name}
  then assign tt-firm.city.
  if tt-firm.ind:visible in frame {&frame-name}
  then assign tt-firm.ind.

end.
else do:
  assign
  tt-firm.post-addr1 = string(fp3, "X(50)")
  tt-firm.post-addr2 = string(fp4, "X(50)")
  tt-firm.addres1 = string(f3, "X(50)")
  tt-firm.addres2 = string(f4, "X(50)")
  .
end.
if f1:visible   in frame {&frame-name}
then assign f1.
if f2:visible   in frame {&frame-name}
then assign f2.
if fp1:visible  in frame {&frame-name}
then assign fp1.
if fp2:visible  in frame {&frame-name}
then assign fp2.
IF (tt-firm.addres1 <> ''
or tt-firm.addres2 <> ''
or tt-firm.city <> ''
OR tt-firm.ind <> 0)
AND (tt-firm.post-addr1 = ''
     AND
     tt-firm.post-addr2 = ''
     AND
     tt-firm.post-city = ''
     AND
    tt-firm.post-ind = 0) THEN DO:
  message
  substitute("Вы заполнили (некоторые) поля ЮРИДИЧЕСКОГО адреса,&1" +
             "но не заполнили ни одного поля ПОЧТОВОГО адреса&1" +
             "Скопировать поля ЮРИДИЧЕСКОГО адреса в поля ПОЧТОВОГО адреса?"
             , {&new-line})
  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
  IF glog THEN DO:
    APPLY "VALUE-CHANGED" to jj_change-address.
    ASSIGN
    tt-firm.post-addr1 = tt-firm.addres1
    tt-firm.post-addr2 = tt-firm.addres2
    tt-firm.post-city = tt-firm.city
    tt-firm.post-ind = tt-firm.ind
    fp1 = f1
    fp2 = f2
    .
    DISPLAY
    tt-firm.post-addr1
    tt-firm.post-addr2
    tt-firm.post-city
    tt-firm.post-ind
    fp1
    fp2
    WITH FRAME {&FRAME-NAME}.
  END.
END.

assign
tt-clients.obj-name
tt-clients.PS
tt-clients.lim-kr
tt-firm.contact-psn
tt-firm.director
tt-firm.e-mail
tt-firm.engl-name
tt-firm.fax
tt-firm.given-by
tt-firm.inn
t-check-inn
tt-firm.is-pboul
tt-firm.kpp
tt-firm.okonh
tt-firm.okpo
tt-firm.passp-num = IF tt-firm.passp-num:SCREEN-VALUE = ? THEN "":U ELSE tt-firm.passp-num:SCREEN-VALUE
tt-firm.passp-ser
tt-firm.phone
tt-firm.phone1-note
tt-firm.telex
tt-firm.tobj-code
tt-clients.turnover-buyer
tt-clients.turnover-buyer-gds
substring( tt-firm.addres1, 51, 50 ) = f1
substring( tt-firm.addres1, 101, 50 ) = f2
substring( tt-firm.post-addr1, 51, 50 ) = fp1
substring( tt-firm.post-addr1, 101, 50 ) = fp2
.
_ii:
do ii = 1 to (if nocorinn AND t-check-inn then 2 else 1):
  run ref/firm1.p (
                 input parparentproc
                ,input-output p-rid
                ,input p-mode
                ,input (if p-callpoint = {&table_sysconf} then "cli-all" else p-callpoint)
                ,input no /*p-silent*/
                ,input tt-firm.firm-code
                ,input tt-clients.stts
                ,input tt-clients.obj-name
                ,input tt-clients.lim-kr
                ,input tt-clients.PS
                ,input tt-clients.grp-code
                ,input tt-firm.addres1
                ,input tt-firm.addres2
                ,input tt-firm.city
                ,input tt-firm.contact-psn
                ,input tt-firm.director
                ,input tt-firm.e-mail
                ,input tt-firm.engl-name
                ,input tt-firm.fax
                ,INPUT tt-firm.given-by
                ,input tt-firm.ind
                ,input tt-firm.inn
                ,INPUT (v-no-check-inn OR not t-check-inn)
                ,INPUT tt-firm.is-pboul
                ,input tt-firm.kpp
                ,input tt-firm.okonh
                ,input tt-firm.okpo
                ,INPUT tt-firm.passp-num
                ,INPUT tt-firm.passp-ser
                ,input tt-firm.phone
                ,input tt-firm.phone1-note
                ,input tt-firm.post-addr1
                ,input tt-firm.post-addr2
                ,input tt-firm.post-city
                ,input tt-firm.post-ind
                ,input tt-clients.reg-code
                ,input tt-firm.telex
                ,input tt-firm.tobj-code
                ,input tt-clients.turnover-buyer
                ,input tt-clients.turnover-buyer-gds
  ) no-error .
  if error-status:error then do:
    if return-value = "inn" and nocorinn then do:
      message
      "Введенный {&abbr_inn_allshift} некорректен или не является {&abbr_inn_allshift} для Вашей страны" skip
      "Подтверждаете ввод ТАКОГО {&abbr_inn_allshift}?"
      view-as alert-box question buttons yes-no update v-no-check-inn.
      if not v-no-check-inn then undo, return error .
      next _ii.
    end.
    v-return-value = return-value .
    if v-return-value = 'inn-uniq' then do:
      v-return-value = 'inn'.
    end.
    { gbl/reterhnd.i error " " " " v-return-value }
    undo, return error.
  end.
  else leave _ii.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

