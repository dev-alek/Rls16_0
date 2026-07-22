&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_clients FOR ub.clients.
DEFINE BUFFER locked_person FOR ub.person.
DEFINE TEMP-TABLE tt-clients NO-UNDO LIKE ub.clients.
DEFINE TEMP-TABLE tt-person NO-UNDO LIKE ub.person.
DEFINE TEMP-TABLE tt-staff NO-UNDO LIKE ub.staff.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка редактирования человека

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/10/03
Author: Bakhtadze Natalya
Creation date: 12/10/03

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER         parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter         p-mode        as       character                    no-undo.
/* {&add-def}, {&update}, {&lookup}*/
define input parameter         p-code        like ub.person.psn-code no-undo .
define input parameter         p-grp-code    like ub.clients.grp-code no-undo.
define input parameter         p-CallPoint   as character  no-undo .
/* cli-all {&role-cashier} {&role-seller} discards */
define input-output parameter  p-rid          as      recid   init ?          no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка редактирования человека".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/waitfram.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ gbl/clntattr.i }
{ gbl/gbclcode.i }
{ gbl/cur-time.i } /* 21/I-2019 - cur-time.i убрано из gbclcode.i */
{ trg/person1s.i tt-staff }
define variable v-db-num like ub.db.db-num no-undo .
define variable is-fin as logical no-undo .
define variable is-magia as logical no-undo .
define variable nocorinn as logical no-undo .
DEFINE VARIABLE add-option AS CHARACTER NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-staff

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-staff ub.person ub.clients locked_person ~
tt-person tt-clients

/* Definitions for BROWSE BR-staff                                      */
&Scoped-define FIELDS-IN-QUERY-BR-staff &SCOPED-DEFINE role-code tt-staff.role {&role-name} tt-staff.staff-code tt-staff.db-num tt-staff.date-start tt-staff.date-end
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-staff
&Scoped-define SELF-NAME BR-staff
&Scoped-define QUERY-STRING-BR-staff FOR  EACH tt-staff INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-staff OPEN QUERY br-staff FOR  EACH tt-staff INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-staff tt-staff
&Scoped-define FIRST-TABLE-IN-QUERY-BR-staff tt-staff


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-person.psn-code ~
tt-clients.obj-name tt-person.date-birth tt-person.name1 tt-person.name2 ~
tt-clients.turnover-buyer tt-person.firm-name tt-clients.turnover-buyer-gds ~
tt-person.position tt-person.is-pboul tt-person.inn tt-person.kpp ~
tt-person.phone1 tt-person.phone1-note tt-person.fax tt-person.e-mail ~
tt-person.city tt-person.post-city tt-person.post-ind tt-person.ind ~
tt-person.post-address tt-person.address tt-person.passp-ser ~
tt-person.passp-num tt-person.post-box tt-clients.reg-code ~
tt-person.given-by tt-clients.lim-kr tt-clients.PS
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-person.psn-code ~
tt-clients.obj-name tt-person.date-birth tt-person.name1 tt-person.name2 ~
tt-clients.turnover-buyer tt-person.firm-name tt-clients.turnover-buyer-gds ~
tt-person.position tt-person.is-pboul tt-person.inn tt-person.kpp ~
tt-person.phone1 tt-person.phone1-note tt-person.fax tt-person.e-mail ~
tt-person.city tt-person.post-city tt-person.post-ind tt-person.ind ~
tt-person.post-address tt-person.address tt-person.passp-ser ~
tt-person.passp-num tt-person.post-box tt-clients.reg-code ~
tt-person.given-by tt-clients.lim-kr tt-clients.PS
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-person tt-clients
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-person
&Scoped-define SECOND-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-clients
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-staff}
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH ub.person SHARE-LOCK, ~
      EACH ub.clients WHERE TRUE /* Join to ub.person incomplete */ SHARE-LOCK, ~
      EACH locked_person WHERE TRUE /* Join to ub.person incomplete */ SHARE-LOCK, ~
      EACH tt-person WHERE TRUE /* Join to ub.person incomplete */ SHARE-LOCK, ~
      EACH tt-clients WHERE TRUE /* Join to ub.person incomplete */ SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH ub.person SHARE-LOCK, ~
      EACH ub.clients WHERE TRUE /* Join to ub.person incomplete */ SHARE-LOCK, ~
      EACH locked_person WHERE TRUE /* Join to ub.person incomplete */ SHARE-LOCK, ~
      EACH tt-person WHERE TRUE /* Join to ub.person incomplete */ SHARE-LOCK, ~
      EACH tt-clients WHERE TRUE /* Join to ub.person incomplete */ SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame ub.person ub.clients ~
locked_person tt-person tt-clients
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame ub.person
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame ub.clients
&Scoped-define THIRD-TABLE-IN-QUERY-Dialog-Frame locked_person
&Scoped-define FOURTH-TABLE-IN-QUERY-Dialog-Frame tt-person
&Scoped-define FIFTH-TABLE-IN-QUERY-Dialog-Frame tt-clients


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-person.psn-code tt-clients.obj-name ~
tt-person.date-birth tt-person.name1 tt-person.name2 ~
tt-clients.turnover-buyer tt-person.firm-name tt-clients.turnover-buyer-gds ~
tt-person.position tt-person.is-pboul tt-person.inn tt-person.kpp ~
tt-person.phone1 tt-person.phone1-note tt-person.fax tt-person.e-mail ~
tt-person.city tt-person.post-city tt-person.post-ind tt-person.ind ~
tt-person.post-address tt-person.address tt-person.passp-ser ~
tt-person.passp-num tt-person.post-box tt-clients.reg-code ~
tt-person.given-by tt-clients.lim-kr tt-clients.PS
&Scoped-define ENABLED-TABLES tt-person tt-clients
&Scoped-define FIRST-ENABLED-TABLE tt-person
&Scoped-define SECOND-ENABLED-TABLE tt-clients
&Scoped-Define ENABLED-OBJECTS B-exit b-quit b-dc b-bank Docs b-org b-attr ~
b-hist B-Help Rs-gender T-check-inn jj_change-address b-region B-add B-del ~
BR-staff
&Scoped-Define DISPLAYED-FIELDS tt-person.psn-code tt-clients.obj-name ~
tt-person.date-birth tt-person.name1 tt-person.name2 ~
tt-clients.turnover-buyer tt-person.firm-name tt-clients.turnover-buyer-gds ~
tt-person.position tt-person.is-pboul tt-person.inn tt-person.kpp ~
tt-person.phone1 tt-person.phone1-note tt-person.fax tt-person.e-mail ~
tt-person.city tt-person.post-city tt-person.post-ind tt-person.ind ~
tt-person.post-address tt-person.address tt-person.passp-ser ~
tt-person.passp-num tt-person.post-box tt-clients.reg-code ~
tt-person.given-by tt-clients.lim-kr tt-clients.PS
&Scoped-define DISPLAYED-TABLES tt-person tt-clients
&Scoped-define FIRST-DISPLAYED-TABLE tt-person
&Scoped-define SECOND-DISPLAYED-TABLE tt-clients
&Scoped-Define DISPLAYED-OBJECTS Rs-gender T-check-inn jj_change-address

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-add
       MENU-ITEM m_cashier      LABEL "Кассир"
       MENU-ITEM m_seller       LABEL "Продавец"      .

DEFINE MENU MENU-psn-code
       MENU-ITEM m-choose       LABEL "Подобрать свободный код".


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-attr
     LABEL "&Атрибуты"
     SIZE 10 BY 1.

DEFINE BUTTON b-bank
     LABEL "&Банки"
     SIZE 10 BY 1.

DEFINE BUTTON b-dc
     LABEL "Диск.&карты"
     SIZE 12 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.

DEFINE BUTTON b-org
     LABEL "&Список орг."
     SIZE 12 BY 1.

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

DEFINE BUTTON Docs
     LABEL "&Док-ты"
     SIZE 10 BY 1.

DEFINE VARIABLE jj_change-address AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "&Регистрации", 0,
"Поч&товый", 1
     SIZE 13.9 BY 2 NO-UNDO.

DEFINE VARIABLE Rs-gender AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "Yes"
     SIZE 27.5 BY 1 NO-UNDO.

DEFINE VARIABLE T-check-inn AS LOGICAL INITIAL yes
     LABEL "Проверять"
     VIEW-AS TOGGLE-BOX
     SIZE 12 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-staff FOR
      tt-staff SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      ub.person,
      ub.clients,
      locked_person,
      tt-person,
      tt-clients SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-staff
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-staff Dialog-Frame _FREEFORM
  QUERY BR-staff NO-LOCK DISPLAY
      &SCOPED-DEFINE role-code tt-staff.role
{&role-name}  COLUMN-LABEL "Роль" FORMAT "X(10)":U
tt-staff.staff-code  COLUMN-LABEL "Код" FORMAT ">>>>9":U
tt-staff.db-num COLUMN-LABEL "№ БД" FORMAT ">>>>9":U
tt-staff.date-start COLUMN-LABEL "С" FORMAT "99/99/9999":U
tt-staff.date-end COLUMN-LABEL "По" FORMAT "99/99/9999":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 48.5 BY 5
         TITLE "Роли" FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-dc AT ROW 1 COL 21
     b-bank AT ROW 1 COL 33
     Docs AT ROW 1 COL 43
     b-org AT ROW 1 COL 53
     b-attr AT ROW 1 COL 65 WIDGET-ID 6
     b-hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     tt-person.psn-code AT ROW 3.03 COL 5.8 COLON-ALIGNED
          LABEL "Код"
          VIEW-AS FILL-IN
          SIZE 10.1 BY 1
          BGCOLOR 15
     tt-clients.obj-name AT ROW 3.03 COL 27.3 COLON-ALIGNED
          LABEL "Фамилия"
          VIEW-AS FILL-IN
          SIZE 41 BY 1
          BGCOLOR 15
     Rs-gender AT ROW 3.03 COL 70.5 NO-LABEL
     tt-person.date-birth AT ROW 4 COL 84.5 COLON-ALIGNED
          LABEL "Д.Р."
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-person.name1 AT ROW 4.13 COL 23.1 COLON-ALIGNED
          LABEL "Имя"
          VIEW-AS FILL-IN
          SIZE 20.1 BY 1
          BGCOLOR 15
     tt-person.name2 AT ROW 4.13 COL 54.5 COLON-ALIGNED
          LABEL "Отчество"
          VIEW-AS FILL-IN
          SIZE 21.8 BY 1
          BGCOLOR 15
     tt-clients.turnover-buyer AT ROW 5.27 COL 65
          LABEL "Расчитывать обороты по пок-лю"
          VIEW-AS TOGGLE-BOX
          SIZE 33 BY .83 TOOLTIP "Рассчитывать обороты по покупателю"
     tt-person.firm-name AT ROW 5.3 COL 10 COLON-ALIGNED
          LABEL "Орга-ция"
          VIEW-AS FILL-IN
          SIZE 52.5 BY 1
          BGCOLOR 15
     tt-clients.turnover-buyer-gds AT ROW 6 COL 68
          LABEL "в разрезе товаров"
          VIEW-AS TOGGLE-BOX
          SIZE 19.5 BY .83 TOOLTIP "Расcчитывать обороты покупателя в разрезе товаров"
     tt-person.position AT ROW 6.3 COL 10 COLON-ALIGNED
          LABEL "Должность"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          BGCOLOR 15
     tt-person.is-pboul AT ROW 7.5 COL 84
          LABEL "ПБОЮЛ"
          VIEW-AS TOGGLE-BOX
          SIZE 12 BY 1
     tt-person.inn AT ROW 7.63 COL 10 COLON-ALIGNED
          LABEL "inn"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          BGCOLOR 15
     tt-person.kpp AT ROW 7.63 COL 50 COLON-ALIGNED
          LABEL "kpp"
          VIEW-AS FILL-IN
          SIZE 23.3 BY 1.03
     T-check-inn AT ROW 7.77 COL 34
     tt-person.phone1 AT ROW 8.97 COL 10 COLON-ALIGNED
          LABEL "Телефон"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          BGCOLOR 15
     tt-person.phone1-note AT ROW 8.97 COL 41.8 COLON-ALIGNED
          LABEL "Прим."
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          BGCOLOR 15
     tt-person.fax AT ROW 10.17 COL 10 COLON-ALIGNED
          LABEL "Факс"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          BGCOLOR 15
     tt-person.e-mail AT ROW 10.17 COL 41.6 COLON-ALIGNED
          LABEL "E-mail" FORMAT "X(100)"
          VIEW-AS FILL-IN
          SIZE 49.4 BY 1
          BGCOLOR 15
     jj_change-address AT ROW 11.4 COL 1 NO-LABEL WIDGET-ID 8
     tt-person.city AT ROW 11.4 COL 21 COLON-ALIGNED
          LABEL "Город"
          VIEW-AS FILL-IN
          SIZE 31.9 BY 1
          BGCOLOR 15 FGCOLOR 0
     tt-person.post-city AT ROW 11.4 COL 21 COLON-ALIGNED WIDGET-ID 12
          LABEL "Город"
          VIEW-AS FILL-IN
          SIZE 31.9 BY 1
          BGCOLOR 15
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     tt-person.post-ind AT ROW 11.4 COL 72.1 COLON-ALIGNED WIDGET-ID 16
          LABEL "Индекс"
          VIEW-AS FILL-IN
          SIZE 7.8 BY 1
          BGCOLOR 15 FGCOLOR 0
     tt-person.ind AT ROW 11.4 COL 72.1 COLON-ALIGNED
          LABEL "Индекс"
          VIEW-AS FILL-IN
          SIZE 7.8 BY 1
          BGCOLOR 15 FGCOLOR 0
     tt-person.post-address AT ROW 12.57 COL 21 COLON-ALIGNED WIDGET-ID 14
          LABEL "Адрес"
          VIEW-AS FILL-IN
          SIZE 43.1 BY 1
          BGCOLOR 15
     tt-person.address AT ROW 12.57 COL 21 COLON-ALIGNED
          LABEL "Адрес"
          VIEW-AS FILL-IN
          SIZE 43.1 BY 1
          BGCOLOR 15
     tt-person.passp-ser AT ROW 13.77 COL 20.5 COLON-ALIGNED
          LABEL "Паспорт серия"
          VIEW-AS FILL-IN
          SIZE 13.5 BY 1
          BGCOLOR 15
     tt-person.passp-num AT ROW 13.77 COL 45.6 COLON-ALIGNED
          LABEL "номер" FORMAT "X(18)"
          VIEW-AS FILL-IN
          SIZE 19 BY 1
          BGCOLOR 15
     tt-person.post-box AT ROW 13.8 COL 69 COLON-ALIGNED
          LABEL "а/я"
          VIEW-AS FILL-IN
          SIZE 8.1 BY 1
          BGCOLOR 15
     tt-clients.reg-code AT ROW 13.8 COL 85.5 COLON-ALIGNED WIDGET-ID 4
          LABEL "Регион"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     b-region AT ROW 13.8 COL 91.5 WIDGET-ID 2
     tt-person.given-by AT ROW 14.97 COL 12.8 COLON-ALIGNED
          LABEL "Выдан"
          VIEW-AS FILL-IN
          SIZE 82 BY 1
          BGCOLOR 15 FORMAT "X(128)"
     B-add AT ROW 16 COL 49
     B-del AT ROW 16 COL 59
     tt-clients.lim-kr AT ROW 16.13 COL 1.1
          LABEL "Лимит кредита"
          VIEW-AS FILL-IN
          SIZE 19.9 BY 1
          BGCOLOR 15
     BR-staff AT ROW 17 COL 49
     tt-clients.PS AT ROW 18.5 COL 1.5 NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
          SIZE 47 BY 3.5
          FONT 4
     "Примеч.:" VIEW-AS TEXT
          SIZE 12 BY 1 AT ROW 17.27 COL 2
     SPACE(84.00) SKIP(3.76)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Ч Е Л О В Е К (физич. лицо)"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_clients B "?" ? ub clients
      TABLE: locked_person B "?" ? ub person
      TABLE: tt-clients T "?" NO-UNDO ub clients
      TABLE: tt-person T "?" NO-UNDO ub person
      TABLE: tt-staff T "?" NO-UNDO ub staff
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-staff lim-kr Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tt-person.address IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       B-add:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-add:HANDLE.

/* SETTINGS FOR FILL-IN tt-person.city IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-person.date-birth IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-person.e-mail IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-person.fax IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-person.firm-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-person.given-by IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-person.ind IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-person.inn IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-person.is-pboul IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-person.kpp IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-clients.lim-kr IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN tt-person.name1 IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-person.name2 IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-clients.obj-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-person.passp-num IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-person.passp-ser IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-person.phone1 IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-person.phone1-note IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-person.position IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-person.post-address IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-person.post-box IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-person.post-city IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-person.post-ind IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       tt-clients.PS:RETURN-INSERTED IN FRAME Dialog-Frame  = TRUE.

/* SETTINGS FOR FILL-IN tt-person.psn-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       tt-person.psn-code:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-psn-code:HANDLE.

/* SETTINGS FOR FILL-IN tt-clients.reg-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-clients.turnover-buyer IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-clients.turnover-buyer-gds IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-staff
/* Query rebuild information for BROWSE BR-staff
     _START_FREEFORM
OPEN QUERY br-staff FOR  EACH tt-staff INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BR-staff */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "ub.person,ub.clients WHERE ub.person ...,Temp-Tables.locked_person WHERE ub.person ...,Temp-Tables.tt-person WHERE ub.person ...,Temp-Tables.tt-clients WHERE ub.person ..."
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Ч Е Л О В Е К (физич. лицо) */
DO:
  run proc-save in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Ч Е Л О В Е К (физич. лицо) */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  DEFINE VARIABLE v-option AS CHARACTER NO-UNDO.
IF add-option = '':U THEN DO:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
   if error-status :error then do: return no-apply. end.
END.
if add-option = '':U then return no-apply.
v-option = add-option.
add-option = '':U.
run proc-b-add-staff in this-procedure ( input v-option) no-error.
if error-status:error then do:
   return no-apply.
end.

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
                   ,input {&prs}
                   ,input tt-person.psn-code
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
if p-mode = {&add-def}  then do:
  glog = no.
  message "Вы завершили ввод карточки клиента?"
  view-as alert-box QUESTION buttons YEs-No update glog.
  if not glog then return no-apply.
  if glog then do:
    run proc-save in this-procedure no-error .
    if error-status:error then undo, return no-apply.
    assign
    p-mode = {&update}.
    run fill-table in this-procedure no-error .
    if error-status:error then do:
      undo, return no-apply .
    end.
    run Myenable in this-procedure .
  END.
end.
    run ref/finschts.w (
                      INPUT parParentProc
                     ,input v-cntxt-host-code-obj
                     ,input "b-add":U
                     ,input "cmp-host":U
                     ,input {&prs}
                     ,input tt-person.psn-code
                     ,input ?
                     ,input v-cntxt-host-code-obj
                     ,input 0
                     ,input-output v-status_
                     ,input-output v-rid-list ).
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
               ,input '':U
               ,recid( locked_clients )
               ,output rid-list ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
  IF NOT AVAILABLE tt-staff THEN RETURN NO-APPLY.
  DELETE tt-staff.
  {&OPEN-QUERY-br-staff}
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
                    , input {&prs} /*p-obj-type*/
                    , input tt-person.psn-code /*p-obj-code*/
                    , input ? /*p-host-code*/
                    , input ? /* p-corr-user-db-num  */
                    , input "":U /* p-corr-user-name  */
                    , input "":U /* p-subject  */
                    , input v-cntxt-db-num /* p-db-num */
                    , input-output v-rid-list  ) no-error .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-org
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-org Dialog-Frame
ON CHOOSE OF b-org IN FRAME Dialog-Frame /* Список орг. */
DO:
  /*обрезан функционал отчета по торговому представителю поскольку он использует бухгалтерские таблицы*/
  run ref/rpsn-org.w ( INPUT parParentProc, INPUT tt-person.psn-code ).
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
  /*apply "ENTRY" to b-exit.  АНАЛОГИЧНО*/
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


&Scoped-define SELF-NAME Docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Docs Dialog-Frame
ON CHOOSE OF Docs IN FRAME Dialog-Frame /* Док-ты */
DO:
DEFINE VARIABLE v-output as character no-undo.
define variable v-input-output as character no-undo .
run str/all-docs.w (
                    input parparentproc
                    ,input ? /*host-code*/
                    ,input ? /*obj-type*/
                    ,input ? /*obj-code*/
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


&Scoped-define SELF-NAME tt-person.inn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-person.inn Dialog-Frame
ON LEAVE OF tt-person.inn IN FRAME Dialog-Frame /* inn */
DO:
define variable v-correct-inn as logical no-undo .
/*
if input frame {&frame-name} tt-person.inn <> "":U then do:
  run gbl/keyinn.p ( input frame {&frame-name} tt-person.inn, {&prs}, 0, input frame {&frame-name} tt-person.is-pboul, output v-correct-inn) no-error .
  if error-status:error or not v-correct-inn then do:
    if return-value <> "":U then
    message return-value
    view-as alert-box  error .
    return no-apply.
  end.
end.
*/
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
    if p-mode = {&update} then do:
      ASSIGN
      tt-person.post-address
      tt-person.post-city
      tt-person.post-ind
      .
    end.
    DISABLE
    tt-person.post-address
    tt-person.post-city
    tt-person.post-ind
    WITH FRAME {&frame-name}.
    HIDE
    tt-person.post-address
    tt-person.post-city
    tt-person.post-ind
    IN FRAME {&frame-name}.
    if p-mode = {&add-def} then do:
      DISPLAY
      tt-person.address
      tt-person.city
      tt-person.ind
      WITH FRAME {&frame-name}.
    end.
    else do:
      DISPLAY
      tt-person.address
      tt-person.city
      tt-person.ind
      WITH FRAME {&frame-name}.
    end.
    if p-mode <> {&lookup} then do:
      ENABLE
      tt-person.address
      tt-person.city
      tt-person.ind
      WITH FRAME {&frame-name}.
    end.
  END.
  when 1 THEN DO:
    if p-mode = {&update} then
    ASSIGN
    tt-person.address
    tt-person.city
    tt-person.ind
    .
    DISABLE
    tt-person.address
    tt-person.city
    tt-person.ind
    WITH FRAME {&frame-name}.
    HIDE
    tt-person.address
    tt-person.city
    tt-person.ind
    IN FRAME {&frame-name}.
    if p-mode = {&add-def} then do:
      DISPLAY
      tt-person.post-address
      tt-person.post-city
      tt-person.post-ind
      WITH FRAME {&frame-name}.
    end.
    else do:
      DISPLAY
      tt-person.post-address
      tt-person.post-city
      tt-person.post-ind
      WITH FRAME {&frame-name}.
    end.
    if p-mode <> {&lookup} then do:
      ENABLE
      tt-person.post-address
      tt-person.post-city
      tt-person.post-ind
      WITH FRAME {&frame-name}.
    end.
  END.
END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-person.kpp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-person.kpp Dialog-Frame
ON LEAVE OF tt-person.kpp IN FRAME Dialog-Frame /* kpp */
DO:
define variable checked as decimal.
/*проверим числовой ли код*/
assign
checked = decimal(input frame {&frame-name} tt-person.kpp) No-error.
if error-status:error or NOT (checked = truncate(checked,0)) then do:
    message "Нечисловой или неправильный {&abbr_kpp_allshift}!" view-as alert-box.
    return no-apply.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-choose
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-choose Dialog-Frame
ON CHOOSE OF MENU-ITEM m-choose /* Подобрать свободный код */
DO:
   DEFINE VARIABLE v-obj-code LIKE ub.clients.obj-code NO-UNDO.
  run ref/chs-code.w (
                   input {&prs}
                 , input v-cntxt-db-num
                 , OUTPUT v-obj-code) no-error .
  if not error-status:error
  and v-obj-code <> ? then do:
    display
    v-obj-code @ tt-person.psn-code
    with frame {&frame-name} .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_cashier
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_cashier Dialog-Frame
ON CHOOSE OF MENU-ITEM m_cashier /* Кассир */
DO:
  ASSIGN
  add-option = {&role-cashier}.
  APPLY "CHOOSE" TO b-add IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_seller
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_seller Dialog-Frame
ON CHOOSE OF MENU-ITEM m_seller /* Продавец */
DO:

    ASSIGN
    add-option = {&role-seller}.
    APPLY "CHOOSE" TO b-add IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-person.passp-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-person.passp-num Dialog-Frame
ON LEAVE OF tt-person.passp-num IN FRAME Dialog-Frame /* номер */
DO:
  IF trim(tt-person.passp-num:SCREEN-VALUE) = "":U THEN
      ASSIGN
      tt-person.passp-num:SCREEN-VALUE = ?.

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


&Scoped-define BROWSE-NAME BR-staff
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

  assign
    tt-person.inn :label in frame {&frame-name} = "{&abbr_inn_allshift}"
    tt-person.kpp :label in frame {&frame-name} = "{&abbr_kpp_allshift}"
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
  if p-callpoint  <> {&role-cashier}
  and p-callpoint <> {&role-seller}
  and p-callpoint <> "discards":U
  and p-callpoint <> "cli-all":U
  then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова p-callpoint"  p-callpoint
      view-as alert-box ERROR.
      undo, return error.
  end.

  { gbl/curdbnum.i v-db-num }
  { gbl/getcntxt.i get }
  run fill-table in this-procedure no-error.
  if error-status:error then return error.
  run Myenable in this-procedure .

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
  DISPLAY Rs-gender T-check-inn jj_change-address
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-clients THEN
    DISPLAY tt-clients.obj-name tt-clients.turnover-buyer
          tt-clients.turnover-buyer-gds tt-clients.reg-code tt-clients.lim-kr
          tt-clients.PS
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-person THEN
    DISPLAY tt-person.psn-code tt-person.date-birth tt-person.name1
          tt-person.name2 tt-person.firm-name tt-person.position
          tt-person.is-pboul tt-person.inn tt-person.kpp tt-person.phone1
          tt-person.phone1-note tt-person.fax tt-person.e-mail tt-person.city
          tt-person.post-city tt-person.post-ind tt-person.ind
          tt-person.post-address tt-person.address tt-person.passp-ser
          tt-person.passp-num tt-person.post-box tt-person.given-by
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit b-dc b-bank Docs b-org b-attr b-hist B-Help
         tt-person.psn-code tt-clients.obj-name Rs-gender tt-person.date-birth
         tt-person.name1 tt-person.name2 tt-clients.turnover-buyer
         tt-person.firm-name tt-clients.turnover-buyer-gds tt-person.position
         tt-person.is-pboul tt-person.inn tt-person.kpp T-check-inn
         tt-person.phone1 tt-person.phone1-note tt-person.fax tt-person.e-mail
         jj_change-address tt-person.city tt-person.post-city
         tt-person.post-ind tt-person.ind tt-person.post-address
         tt-person.address tt-person.passp-ser tt-person.passp-num
         tt-person.post-box tt-clients.reg-code b-region tt-person.given-by
         B-add B-del tt-clients.lim-kr BR-staff tt-clients.PS
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
DEFINE BUFFER buf_tt-staff FOR tt-staff.
DEFINE BUFFER buf_staff FOR ub.staff.
 for each tt-clients :
    delete tt-clients.
  end.
  for each tt-person :
    delete tt-person.
  end.
  FOR EACH buf_tt-staff:
      DELETE buf_tt-staff.
  END.
  if p-mode = {&update}
  or p-mode = {&lookup} then do:
   if p-mode = {&update} then do:
      main-block:
      do
      on error  undo main-block, return error substitute( "&1 &2. &3&4&3&5"
                                                        , vss-workfile
                                                        , "Блокирование клиентма для редактирования"
                                                        , return-value
                                                        , {&new-line}
                                                        , error-status :get-message (1)
                                                        )
      on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
      :
        find first locked_clients EXclusive-lock where
              recid(locked_clients) = p-rid .
                find first locked_person EXclusive-lock where
              locked_person.psn-code = locked_clients.obj-code .
      end.
    end.  /*on error undo, return error*/
    else do:
      find first locked_clients no-lock where
                       recid(locked_clients) = p-rid no-error .
      if not avail locked_clients then do:
        find first locked_clients where
                  locKed_clients.obj-type = {&prs}
             AND locKed_clients.obj-code = p-code no-error .
      end.
      if not available locked_clients then do:
        message
        vss-workfile vss-revision vss-description skip
        "Не найдена запись КЛИЕНТ"
        view-as alert-box error .
        undo, return error.
      end.
      find first locked_person no-lock where
              locked_person.psn-code = locked_clients.obj-code no-error .
      if not available locked_person then do:
        message
        vss-workfile vss-revision vss-description skip
        "Не найдена запись ФИз.Лица"
        view-as alert-box error .
        undo, return error.
      end.
    end.
    create tt-clients.
    buffer-copy locked_clients to tt-clients.
    create tt-person.
    buffer-copy locked_person to tt-person.
  end.
  else do:
    create tt-clients.
    create tt-person.
    assign
    tt-clients.obj-type = {&cmp}
    tt-clients.obj-code = 0
    tt-clients.grp-code = p-grp-code
    tt-person.psn-code = tt-clients.obj-code
    tt-clients.stts = 0
    .
 end.
 if p-mode <> {&add-def}  then do:
  FOR EACH buf_staff NO-LOCK WHERE
          buf_staff.psn-code = tt-person.psn-code :
    CREATE buf_tt-staff.
    BUFFER-COPY buf_staff TO buf_tt-staff.
  END.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Myenable Dialog-Frame
PROCEDURE Myenable :
define variable log-res as logical no-undo .
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
log-res
}

ASSIGN
rs-gender:RADIO-BUTTONS IN FRAME {&FRAME-NAME} =  "Муж" + {&comma-char} + STRING(NO) + {&comma-char} +
                           "Жен" + {&comma-char} + STRING(yes) + {&comma-char} +
                           "?" + {&comma-char} + {&Question-mark}
.


/*узнаем в каком АРМ находимся*/


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

if can-find(first ub.cash-desk no-lock where
                ub.cash-desk.db-num = v-cntxt-db-num
             and ub.cash-desk.pos-type = {&cd-type-magia-XML}) then do:
  assign
  is-magia = yes
  .
end.
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

rs-gender = string(tt-person.gender).

b-add:MENU-MOUSE in frame {&frame-name}  = 1.
assign
tt-person.post-address:column = tt-person.address:column
tt-person.post-address:label = tt-person.address:label
tt-person.post-city:column = tt-person.city:column
tt-person.post-city:label = tt-person.city:label
tt-person.post-ind:column = tt-person.ind:column
tt-person.post-ind:label = tt-person.ind:label
jj_change-address = 0
.



IF AVAILABLE tt-clients THEN
  DISPLAY
  tt-clients.obj-name
  tt-clients.lim-kr
  tt-clients.PS
  tt-clients.turnover-buyer
  tt-clients.turnover-buyer-gds
  tt-clients.reg-code
  WITH FRAME Dialog-Frame.
IF AVAILABLE tt-person THEN
  DISPLAY
  tt-person.psn-code
  tt-person.date-birth
  rs-gender
  tt-person.name2
  tt-person.name1
  tt-person.firm-name
  tt-person.position
  tt-person.inn
  t-check-inn when p-mode <> {&lookup}
  tt-person.is-pboul
  tt-person.kpp
  tt-person.phone1
  tt-person.phone1-note
  tt-person.fax
  tt-person.e-mail
  tt-person.city
  tt-person.ind
  tt-person.address
  tt-person.post-box
  tt-person.passp-ser
  tt-person.passp-num
  tt-person.given-by
  WITH FRAME Dialog-Frame.
assign
frame {&frame-name} :title = "Ч Е Л О В Е К:физич. лицо" + {&space-char} + p-mode
.
if p-mode <> {&lookup} then do:
  ENABLE
  B-exit
  b-quit
  b-dc   when p-mode <> {&add-def} and p-callpoint <> "discards":U
  b-bank
  Docs   when p-mode <> {&add-def} and v-cntxt-level = {&cntxt-object}
  b-org  when p-mode <> {&add-def} and v-cntxt-level = {&cntxt-object}
  b-add when p-mode = {&add-def} and lookup(p-callpoint, {&role-list}) > 0
  b-del when p-mode = {&add-def} and lookup(p-callpoint, {&role-list}) > 0
  b-hist when p-mode <> {&add-def}
  B-Help
  b-region when p-mode <> {&lookup}
  tt-person.psn-code  when p-mode = {&add-def}
  tt-person.date-birth
  RS-gender
  tt-clients.obj-name
  tt-person.name2
  tt-person.name1
  tt-person.firm-name
  tt-person.position
  tt-person.inn
  t-check-inn when nocorinn
  tt-person.kpp
  tt-person.phone1
  tt-person.phone1-note
  tt-person.fax
  tt-person.e-mail
  tt-person.is-pboul
  tt-person.post-box
  tt-person.passp-ser
  tt-person.passp-num
  tt-person.given-by
  tt-clients.lim-kr when log-res
  tt-clients.PS
  br-staff
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
  b-dc   when p-callpoint <> "discards":U and  v-cntxt-level = {&cntxt-object}
  b-bank
  Docs when  v-cntxt-level = {&cntxt-object}
  b-org WHEN  v-cntxt-level = {&cntxt-object}
  b-hist
  B-Help
  br-staff
  tt-clients.PS
  b-attr
  jj_change-address
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
MENU-ITEM m-choose:SENSITIVE IN MENU MENU-psn-code = (p-mode = {&add-def}) .
if p-mode <> {&add-def} then DO:
  menu-item m_cashier:sensitive in menu menu-b-add = no.
  menu-item m_seller:sensitive in menu menu-b-add = no.
  HIDE
  b-add
  b-del
  IN FRAME {&FRAME-NAME}.
END.
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
  define variable v-use-child as logical   no-undo .
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
  if not ( v-use-grp-buy or v-use-oborot-buy ) then
   hide tt-clients.turnover-buyer tt-clients.turnover-buyer-gds in frame {&frame-name}.
OPEN QUERY br-staff FOR  EACH tt-staff INDEXED-REPOSITION.
VIEW FRAME {&frame-name}.
APPLY "VALUE-CHANGED":U TO jj_change-address IN FRAME {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add-staff Dialog-Frame
PROCEDURE proc-b-add-staff :
DEFINE INPUT PARAMETER p-role AS CHARACTER NO-UNDO.
run ref/rolei.p (
                input parparentproc
               ,input (IF p-mode = {&add-def}
                       THEN ({&add-def} + {&comma-char} + 'temp':U)
                       ELSE p-mode)
               ,INPUT tt-clients.obj-code
               ,INPut p-role
               ,input {&role-level-db} /*p-role-level*/
               ,INPUT-OUTPUT p-rid
               ,input-output table tt-staff
               ) no-error.

IF error-status:ERROR  THEN do:
   message error-status:get-message(1) return-value
   view-as alert-box error .
   UNDO, RETURN .
 end.
{&OPEN-QUERY-br-staff}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Proc-save Dialog-Frame
PROCEDURE Proc-save :
define variable int-buf as integer no-undo .
define variable psw-buf as integer no-undo .
define variable glog as logical no-undo .
define variable v-no-check-inn as logical no-undo .
define variable ii as integer no-undo .
define variable v-return-value as character no-undo .
define variable v-staff-input as logical no-undo .
define buffer buf_tt-staff for tt-staff.
if p-mode = {&add-def}  then
assign
frame {&frame-name}
tt-person.psn-code
.
if p-mode = {&add-def}
and lookup( p-callpoint, {&role-list})  > 0
then do:
  for each buf_tt-staff :
    if buf_tt-staff.role = p-callpoint then do:
      v-staff-input = yes.
      leave.
    end.
  end.
  if v-staff-input = no then do:

&scop role-code p-callpoint
    message
    substitute("Вы находитесь в режиме ввода физических лиц <&2>&1" +
              "однако Вы пытаетесь ввести данные по физ. лицу, не вводя данные для роли <&2>"
              , {&new-line}
              , {&role-name}

              )
    view-as alert-box error .
    undo, return error .

  end.
end.
IF tt-person.address:VISIBLE IN FRAME {&frame-name} then
ASSIGN tt-person.address.
IF tt-person.city:VISIBLE IN FRAME {&frame-name} then
ASSIGN tt-person.city.
IF tt-person.ind:VISIBLE IN FRAME {&frame-name} then
ASSIGN tt-person.ind.
IF tt-person.post-address:VISIBLE IN FRAME {&frame-name} then
ASSIGN tt-person.post-address.
IF tt-person.post-city:VISIBLE IN FRAME {&frame-name} then
ASSIGN tt-person.post-city.
IF tt-person.post-ind:VISIBLE IN FRAME {&frame-name} then
ASSIGN tt-person.post-ind.

IF (tt-person.address <> ''
or tt-person.city <> ''
OR tt-person.ind <> 0)
AND (tt-person.post-city = ''
     AND
     tt-person.post-address = ''
     AND
    tt-person.post-ind = 0) THEN DO:
  message
  substitute("Вы заполнили (некоторые) поля адреса РЕГИСТРАЦИИ,&1" +
             "но не заполнили ни одного поля ПОЧТОВОГО адреса&1" +
             "Скопировать поля адреса РЕГИСТРАЦИИ в поля ПОЧТОВОГО адреса?"
             , {&new-line})
  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
  IF glog THEN DO:
      ASSIGN
      tt-person.post-address = tt-person.address
      tt-person.post-city = tt-person.city
      tt-person.post-ind = tt-person.ind
      .
      DISPLAY
      tt-person.post-address
      tt-person.post-city
      tt-person.post-ind
      WITH FRAME {&FRAME-NAME}.
  END.

END.
assign
tt-person.firm-name
rs-gender
tt-person.gender = IF rs-gender = {&question-mark} THEN ? ELSE LOGICAL(rs-gender)
tt-person.date-birth
tt-person.position
tt-person.phone1
tt-person.phone1-note
tt-person.e-mail
tt-person.fax
tt-person.post-box
tt-person.is-pboul
tt-person.given-by
tt-person.passp-num = IF tt-person.passp-num:SCREEN-VALUE = ? THEN "":U ELSE tt-person.passp-num:SCREEN-VALUE
tt-person.passp-num = trim(tt-person.passp-num)
tt-person.passp-ser
tt-clients.obj-name
tt-clients.PS
tt-clients.lim-kr
tt-person.inn
t-check-inn
tt-person.kpp
tt-person.name1
tt-person.name2
.
_ii:
do ii = 1 to (if nocorinn AND T-check-inn then 2 else 1):
  run ref/person1.p (
                input parparentproc
               ,input this-procedure:handle
              ,input-output p-rid
              ,input p-mode
              ,input p-callpoint
              ,input no /*p-silent*/
              ,input tt-person.psn-code
              ,input tt-clients.stts
              ,input tt-clients.obj-name
              ,input tt-clients.lim-kr
              ,input tt-clients.PS
              ,input tt-clients.grp-code
              ,input tt-person.address
              ,input tt-person.city
              ,input tt-person.date-birth
              ,input tt-person.e-mail
              ,input tt-person.fax
              ,input tt-person.firm-code
              ,input tt-person.firm-name
              ,input tt-person.gender
              ,input tt-person.given-by
              ,input tt-person.ind
              ,input tt-person.inn
              ,input (v-no-check-inn OR NOT t-check-inn)
              ,input tt-person.is-pboul
              ,input tt-person.kpp
              ,input tt-person.name1
              ,input tt-person.name2
              ,input tt-person.okonh
              ,input tt-person.okpo
              ,input tt-person.passp-num
              ,input tt-person.passp-ser
              ,input tt-person.phone1
              ,input tt-person.phone1-note
              ,input tt-person.position
              ,input tt-person.post-box
              ,input tt-person.post-address
              ,input tt-person.post-city
              ,input tt-person.post-ind
              ,input tt-clients.reg-code
              ,input tt-clients.turnover-buyer
              ,input tt-clients.turnover-buyer-gds
  ) no-error .
  if error-status:error then do:
    v-return-value = return-value.
    if v-return-value = "inn" and nocorinn then do:
      message
      "Введенный {&abbr_inn_allshift} некорректен или не является {&abbr_inn_allshift} для Вашей страны" skip
      "Подтверждаете ввод ТАКОГО {&abbr_inn_allshift}?"
      view-as alert-box question buttons yes-no update v-no-check-inn.
      if not v-no-check-inn then undo, return error .
      next _ii.
    end.
    if v-return-value = 'inn-uniq' then do:
      v-return-value = 'inn'.
    end.
    { gbl/reterhnd.i error " " " " v-return-value }
    message
    v-return-value view-as alert-box error .
    undo, return error.
  end.
  ELSE LEAVE _ii.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME