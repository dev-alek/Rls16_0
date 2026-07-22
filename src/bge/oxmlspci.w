&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_ext-system FOR ext-system.
DEFINE TEMP-TABLE tt-ext-system NO-UNDO LIKE ext-system.
DEFINE TEMP-TABLE tt-ext-system-attr NO-UNDO LIKE ext-system-attr.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Open XML. Редактирование записи внешней подсистемы с типом специальна

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/19/08
Author: Bakhtadze Natalya
Creation date: 02/19/08


Input:

Output:

@NOTE  расширения для имён файлов с цифровой подписью:
  // https://docs.microsoft.com/ru-ru/dotnet/api/system.security.cryptography.pkcs.signedcms?view=netframework-4.7.2
  // envelopedData   application/pkcs7-mime        .p7m
  // signedData      application/pkcs7-signature   .p7s.p7c    

*/
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc        as handle           no-undo.
define input parameter p-mode               as character        no-undo.
define input-output parameter p-esys-id     as integer          no-undo.
define input parameter p-db-num             as integer          no-undo.
define output parameter p-success           as logical          no-undo.

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Open XML. Редактирование записи внешней подсистемы с типом специальна ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ bge/oxmlext.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/key-rec.i }
{ bge/esysattr.i }
define variable v-oxmlextd-can-change-imp       as logical      no-undo init yes.
define variable v-oxmlextd-can-change-exp       as logical      no-undo init yes.
define variable v-oxmlextd-can-change-db-exp    as logical no-undo .
define variable v-oxmlextd-can-change-db-imp    as logical no-undo .
define variable link-option as character no-undo .

define variable v-ii as integer no-undo.
define variable v-type as character no-undo.
define variable v-attr-code as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-ext-system

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-ext-system.esys-id ~
tt-ext-system.esys-des tt-ext-system.esys-type tt-ext-system.esys-name ~
tt-ext-system.delivery-method tt-ext-system.esys-have-export ~
tt-ext-system.esys-db-num-exp tt-ext-system.save-days-pck-num ~
tt-ext-system.esys-send-news-exp tt-ext-system.esys-have-import ~
tt-ext-system.esys-num-days-keep-exp tt-ext-system.esys-max-p-size ~
tt-ext-system.esys-db-num-imp tt-ext-system.esys-send-news-imp ~
tt-ext-system.max-p-queue tt-ext-system.max-p-time 
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-ext-system.esys-id ~
tt-ext-system.esys-des tt-ext-system.esys-type tt-ext-system.esys-name ~
tt-ext-system.delivery-method tt-ext-system.esys-have-export ~
tt-ext-system.save-days-pck-num tt-ext-system.esys-have-import ~
tt-ext-system.esys-num-days-keep-exp tt-ext-system.esys-max-p-size ~
tt-ext-system.max-p-queue tt-ext-system.max-p-time 
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-ext-system
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-ext-system
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-ext-system SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-ext-system SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-ext-system
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-ext-system


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-ext-system.esys-id tt-ext-system.esys-des ~
tt-ext-system.esys-type tt-ext-system.esys-name ~
tt-ext-system.delivery-method tt-ext-system.esys-have-export ~
tt-ext-system.save-days-pck-num tt-ext-system.esys-have-import ~
tt-ext-system.esys-num-days-keep-exp tt-ext-system.esys-max-p-size ~
tt-ext-system.max-p-queue tt-ext-system.max-p-time 
&Scoped-define ENABLED-TABLES tt-ext-system
&Scoped-define FIRST-ENABLED-TABLE tt-ext-system
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-links b-help RECT-1 RECT-2 ~
RECT-3 RECT-4 f-ftp-ip f-login FI-delivery-method f-password f-ftp-path ~
f-ftp-path-in f-ftp-path-out b-db-export f-exp-db-name t-delete-pck-on ~
T-exp-conf-wait b-db-import f-imp-db-name T-imp-conf-send tg-cert-sign ~
fi-cert-sign-subject fi-cert-sign-issuer cb-cert-file-ext cb-cert-repository l-save-oxml-pck ~
FILL-IN-4 
&Scoped-Define DISPLAYED-FIELDS tt-ext-system.esys-id ~
tt-ext-system.esys-des tt-ext-system.esys-type tt-ext-system.esys-name ~
tt-ext-system.delivery-method tt-ext-system.esys-have-export ~
tt-ext-system.esys-db-num-exp tt-ext-system.save-days-pck-num ~
tt-ext-system.esys-send-news-exp tt-ext-system.esys-have-import ~
tt-ext-system.esys-num-days-keep-exp tt-ext-system.esys-max-p-size ~
tt-ext-system.esys-db-num-imp tt-ext-system.esys-send-news-imp ~
tt-ext-system.max-p-queue tt-ext-system.max-p-time 
&Scoped-define DISPLAYED-TABLES tt-ext-system
&Scoped-define FIRST-DISPLAYED-TABLE tt-ext-system
&Scoped-Define DISPLAYED-OBJECTS fi-des-label f-ftp-ip f-login ~
FI-delivery-method f-password fi-screen-pass f-ftp-path f-ftp-path-in ~
f-ftp-path-out f-exp-db-name t-delete-pck-on T-exp-conf-wait f-imp-db-name ~
T-imp-conf-send tg-cert-sign fi-cert-sign-subject fi-cert-sign-issuer ~
cb-cert-file-ext cb-cert-repository l-save-oxml-pck FILL-IN-4 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-links 
       MENU-ITEM m_thobj        LABEL "Соответствие объектов ВС объектам IBS TH"
       MENU-ITEM m_edoc-nn      LABEL "Контрагенты для обмена данными (по EDOC-NN)"
       MENU-ITEM m_exite-edi    LABEL "Контрагенты для обмена данными (по EDI)"
       MENU-ITEM m_locks        LABEL "Блокирующие связи".


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-db-export 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1" 
     SIZE 3 BY 1.

DEFINE BUTTON b-db-import 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1" 
     SIZE 3 BY 1.

DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-links 
     LABEL "Связи" 
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE cb-cert-file-ext AS CHARACTER FORMAT "X(4)" 
     LABEL "Расширение в имени файла с ЭЦП" 
     VIEW-AS COMBO-BOX INNER-LINES 2
     LIST-ITEMS "p7s","p7c" 
     DROP-DOWN-LIST
     SIZE 14 BY 1 NO-UNDO.
     
DEFINE VARIABLE cb-cert-repository AS integer FORMAT ">>9" 
     LABEL "Хранилище сертификатов" 
     VIEW-AS COMBO-BOX INNER-LINES 2
     list-item-pairs
      "Личное хранилище пользователя",0,
      "Локальный компьютер",1
     DROP-DOWN-LIST
     SIZE 35 BY 1 no-undo init 0.

DEFINE VARIABLE f-exp-db-name AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 32 BY 1 NO-UNDO.

DEFINE VARIABLE f-ftp-ip AS CHARACTER FORMAT "X(256)":U 
     LABEL "FTP" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 24 BY 1 NO-UNDO.

DEFINE VARIABLE f-ftp-path AS CHARACTER FORMAT "X(256)":U 
     LABEL "Путь" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 24 BY 1 TOOLTIP "Путь (от HOME-директории)" NO-UNDO.

DEFINE VARIABLE f-ftp-path-in AS CHARACTER FORMAT "X(256)":U 
     LABEL "Вход." 
     VIEW-AS FILL-IN NATIVE 
     SIZE 24 BY 1 TOOLTIP "Папка для входящих сообщений" NO-UNDO.

DEFINE VARIABLE f-ftp-path-out AS CHARACTER FORMAT "X(256)":U 
     LABEL "Исход." 
     VIEW-AS FILL-IN NATIVE 
     SIZE 24 BY 1 TOOLTIP "Папка для исходящих сообщений" NO-UNDO.

DEFINE VARIABLE f-imp-db-name AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 32 BY 1 NO-UNDO.

DEFINE VARIABLE f-login AS CHARACTER FORMAT "X(256)":U 
     LABEL "Логин" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 24 BY 1 NO-UNDO.

DEFINE VARIABLE f-password AS CHARACTER FORMAT "X(24)":U 
     LABEL "Пароль" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 24 BY 1 NO-UNDO.

DEFINE VARIABLE fi-cert-sign-issuer AS CHARACTER FORMAT "X(256)":U 
     LABEL "Издатель сертификата" 
     VIEW-AS FILL-IN 
     SIZE 40 BY 1 NO-UNDO.

DEFINE VARIABLE fi-cert-sign-subject AS CHARACTER FORMAT "X(256)":U 
     LABEL "Владелец сертификата (~"Субъект~")" 
     VIEW-AS FILL-IN 
     SIZE 40 BY 1 NO-UNDO.

DEFINE VARIABLE FI-delivery-method AS CHARACTER FORMAT "X(256)":U INITIAL "Метод доставки:" 
     VIEW-AS FILL-IN 
     SIZE 15.6 BY 1 NO-UNDO.

DEFINE VARIABLE fi-des-label AS CHARACTER FORMAT "X(256)":U INITIAL "Описание:" 
     VIEW-AS FILL-IN 
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE fi-screen-pass AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 24 BY .67
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-4 AS CHARACTER FORMAT "X(256)":U INITIAL "Условия переформирования пакетов:" 
      VIEW-AS TEXT 
     SIZE 36 BY .67 NO-UNDO.

DEFINE VARIABLE l-save-oxml-pck AS CHARACTER FORMAT "X(256)":U INITIAL "дн." 
      VIEW-AS TEXT 
     SIZE 5 BY .67 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 47.6 BY 11.48.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 12.6 BY 1.24
     BGCOLOR 8 FGCOLOR 8 .

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 48 BY 6.48.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 12.6 BY 1.24
     BGCOLOR 8 FGCOLOR 8 .

DEFINE VARIABLE t-delete-pck-on AS LOGICAL INITIAL no 
     LABEL "Удал. ф-лы из HEAP" 
     VIEW-AS TOGGLE-BOX
     SIZE 22 BY 1.1 NO-UNDO.

DEFINE VARIABLE T-exp-conf-wait AS LOGICAL INITIAL no 
     LABEL "Ждет подтв. после экспорта" 
     VIEW-AS TOGGLE-BOX
     SIZE 31.6 BY 1.1 NO-UNDO.

DEFINE VARIABLE T-imp-conf-send AS LOGICAL INITIAL no 
     LABEL "Посылает подтв. после импорта" 
     VIEW-AS TOGGLE-BOX
     SIZE 33 BY 1.1 NO-UNDO.

DEFINE VARIABLE tg-cert-sign AS LOGICAL INITIAL no 
     LABEL "Использовать электронную подпись" 
     VIEW-AS TOGGLE-BOX
     SIZE 46 BY .81 NO-UNDO.
DEFINE VARIABLE f-proxy-addres AS CHARACTER FORMAT "X(256)":U 
     LABEL "Адрес прокси-сервера" 
     VIEW-AS FILL-IN 
     SIZE 52 BY 1 TOOLTIP "Адрес прокси-сервера в формате <IP>:<Port>" NO-UNDO.

DEFINE VARIABLE f-proxy-login AS CHARACTER FORMAT "X(256)":U 
     LABEL "Логин" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 24 BY 1 NO-UNDO.

DEFINE VARIABLE f-proxy-password AS CHARACTER FORMAT "X(256)":U 
     LABEL "Пароль" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 24 BY 1 NO-UNDO.
     
DEFINE VARIABLE f-proxy-password-screen AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 24 BY 1
     BGCOLOR 15  NO-UNDO.
  
     
DEFINE VARIABLE f-diadoc-user AS CHARACTER FORMAT "X(256)":U 
     LABEL "Логин Диадок" 
     VIEW-AS FILL-IN  
     SIZE 24 BY 1 NO-UNDO.

DEFINE VARIABLE f-diadoc-pwd AS CHARACTER FORMAT "X(256)":U 
     LABEL "Пароль Диадок" 
     VIEW-AS FILL-IN  
     SIZE 24 BY 1 NO-UNDO.
     
DEFINE VARIABLE f-diadoc-pwd-screen AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 24 BY 1
     BGCOLOR 15  NO-UNDO.
     
DEFINE VARIABLE f-diadoc-addres AS CHARACTER FORMAT "X(256)":U 
     LABEL "Адрес Диадок" 
     VIEW-AS FILL-IN  
     SIZE 52 BY 1 NO-UNDO.

DEFINE VARIABLE f-diadoc-key AS CHARACTER FORMAT "X(256)":U 
     LABEL "Ключ разработчика" 
     VIEW-AS FILL-IN  
     SIZE 52 BY 1 NO-UNDO.     

DEFINE VARIABLE f-diadoc-lastload AS date FORMAT "99/99/9999":U 
     LABEL "Последнего загруженного документа" 
     VIEW-AS FILL-IN  
     SIZE 11 BY 1 NO-UNDO.     
          
DEFINE VARIABLE t-diadoc-ssl AS LOGICAL 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.     

DEFINE VARIABLE t-proxy-ssl AS LOGICAL 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.     
     
DEFINE VARIABLE f-host-code AS integer FORMAT ">>>>>>>>9":U 
     LABEL "Фирма" 
     VIEW-AS FILL-IN  
     SIZE 11 BY 1 NO-UNDO.     
     
DEFINE BUTTON b-host-code 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY 1.     
     
DEFINE VARIABLE f-server-addres AS CHARACTER FORMAT "X(256)":U 
     LABEL "URL" 
     VIEW-AS FILL-IN 
     SIZE 52 BY 1 TOOLTIP "Адрес точки подключения к ИС МОТП" NO-UNDO. 
     
DEFINE VARIABLE f-obj AS character FORMAT "X(15)":U 
     LABEL "Объект" 
     VIEW-AS FILL-IN  
     SIZE 15 BY 1 NO-UNDO.   
     
define variable e-mail-list as character format "X(1000)":U
     label "Список eMail"
     view-as editor
     size 50 by 3 no-undo .
     
DEFINE BUTTON b-obj 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY 1. 
     
             

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR 
      tt-ext-system SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-links AT ROW 1 COL 26 WIDGET-ID 24
     b-help AT ROW 1 COL 95
     tt-ext-system.esys-id AT ROW 2.24 COL 11 COLON-ALIGNED WIDGET-ID 26
          LABEL "Код"
          VIEW-AS FILL-IN 
          SIZE 10 BY 1
     fi-des-label AT ROW 2.24 COL 51 NO-LABEL
     tt-ext-system.esys-des AT ROW 2.24 COL 61.6 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 34.6 BY 2
     tt-ext-system.esys-type AT ROW 3.57 COL 11 COLON-ALIGNED WIDGET-ID 64
          LABEL "Тип ВС" FORMAT "->,>>>,>>9"
          VIEW-AS COMBO-BOX INNER-LINES 10
          LIST-ITEM-PAIRS "Item 1",0
          DROP-DOWN-LIST
          SIZE 34.6 BY 1
     tt-ext-system.esys-name AT ROW 4.91 COL 3
          LABEL "Название" FORMAT "X(30)"
          VIEW-AS FILL-IN 
          SIZE 34.6 BY 1
     f-ftp-ip AT ROW 5 COL 59.6 COLON-ALIGNED WIDGET-ID 48
     f-login AT ROW 6 COL 59.6 COLON-ALIGNED WIDGET-ID 50
     FI-delivery-method AT ROW 6.33 COL 2.8 NO-LABEL WIDGET-ID 42
     tt-ext-system.delivery-method AT ROW 6.33 COL 16.6 COLON-ALIGNED NO-LABEL WIDGET-ID 28
          VIEW-AS COMBO-BOX 
          LIST-ITEM-PAIRS "Item 1",1,
                     "Item 2",2
          DROP-DOWN-LIST
          SIZE 29 BY 1
     f-password AT ROW 7 COL 59.6 COLON-ALIGNED WIDGET-ID 52 BLANK 
     fi-screen-pass AT ROW 7.24 COL 59.6 COLON-ALIGNED NO-LABEL WIDGET-ID 54
     f-ftp-path AT ROW 8 COL 59.6 COLON-ALIGNED WIDGET-ID 56
     f-ftp-path-in AT ROW 9 COL 59.6 COLON-ALIGNED WIDGET-ID 66
     tt-ext-system.esys-have-export AT ROW 9.19 COL 3.6
          LABEL "Экспорт"
          VIEW-AS TOGGLE-BOX
          SIZE 10.6 BY .81
     f-ftp-path-out AT ROW 10 COL 59.6 COLON-ALIGNED WIDGET-ID 68
     tt-ext-system.esys-db-num-exp AT ROW 10.52 COL 4.6 COLON-ALIGNED
          LABEL "БД" FORMAT ">>>>9"
          VIEW-AS FILL-IN 
          SIZE 5.6 BY 1
     b-db-export AT ROW 10.52 COL 12 WIDGET-ID 16
     f-exp-db-name AT ROW 10.52 COL 14 COLON-ALIGNED NO-LABEL WIDGET-ID 20
     t-delete-pck-on AT ROW 12 COL 55 WIDGET-ID 62
     tt-ext-system.save-days-pck-num AT ROW 12 COL 82.6 COLON-ALIGNED WIDGET-ID 58
          LABEL "через"
          VIEW-AS FILL-IN 
          SIZE 5.6 BY 1.1
     tt-ext-system.esys-send-news-exp AT ROW 12.24 COL 6.6
          LABEL "Отправлять в новости"
          VIEW-AS TOGGLE-BOX
          SIZE 24 BY .81
     T-exp-conf-wait AT ROW 13.24 COL 6.6 WIDGET-ID 30
     tt-ext-system.esys-have-import AT ROW 14 COL 52 WIDGET-ID 6
          LABEL "Импорт"
          VIEW-AS TOGGLE-BOX
          SIZE 10.6 BY .81
     tt-ext-system.esys-num-days-keep-exp AT ROW 14.52 COL 37 COLON-ALIGNED
          LABEL "Дней хранения пакетов" FORMAT ">,>>>,>>9"
          VIEW-AS FILL-IN 
          SIZE 9 BY 1
     tt-ext-system.esys-max-p-size AT ROW 15.76 COL 37 COLON-ALIGNED WIDGET-ID 40
          LABEL "Макс. размер пакета" FORMAT ">,>>>,>>9"
          VIEW-AS FILL-IN 
          SIZE 9 BY 1
     tt-ext-system.esys-db-num-imp AT ROW 16 COL 53 COLON-ALIGNED WIDGET-ID 10
          LABEL "БД" FORMAT ">>>>9"
          VIEW-AS FILL-IN 
          SIZE 5.6 BY 1
     b-db-import AT ROW 16 COL 60.6 WIDGET-ID 18
     f-imp-db-name AT ROW 16.1 COL 62.6 COLON-ALIGNED NO-LABEL WIDGET-ID 22
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     tt-ext-system.esys-send-news-imp AT ROW 17.52 COL 55 WIDGET-ID 12
          LABEL "Отправлять в новости"
          VIEW-AS TOGGLE-BOX
          SIZE 24 BY .81
     tt-ext-system.max-p-queue AT ROW 18.24 COL 37 COLON-ALIGNED WIDGET-ID 34
          LABEL "Кол-во неподтв. пакетов" FORMAT ">>>9"
          VIEW-AS FILL-IN 
          SIZE 9 BY 1
     T-imp-conf-send AT ROW 18.52 COL 55 WIDGET-ID 32
     tt-ext-system.max-p-time AT ROW 19.52 COL 40.2 COLON-ALIGNED WIDGET-ID 36
          LABEL "Время ожидания потверждения > (мин)"
          VIEW-AS FILL-IN 
          SIZE 9 BY 1 TOOLTIP "max время, черепз котор. должен отправляться очередной пакет"
     tg-cert-sign AT ROW 21.24 COL 4 WIDGET-ID 70
     fi-cert-sign-issuer AT ROW 22.19 COL 38 COLON-ALIGNED WIDGET-ID 72
     fi-cert-sign-subject AT ROW 23.38 COL 38 COLON-ALIGNED WIDGET-ID 74
     cb-cert-file-ext AT ROW 24.57 COL 38 COLON-ALIGNED WIDGET-ID 76
     cb-cert-repository AT ROW 25.7 COL 38 COLON-ALIGNED WIDGET-ID 86
     l-save-oxml-pck AT ROW 12.24 COL 91 COLON-ALIGNED NO-LABEL WIDGET-ID 60
     FILL-IN-4 AT ROW 17.24 COL 2.4 COLON-ALIGNED NO-LABEL WIDGET-ID 38
     RECT-1 AT ROW 9.52 COL 1.6
     RECT-2 AT ROW 9 COL 2.6
     RECT-3 AT ROW 14.52 COL 50 WIDGET-ID 8
     RECT-4 AT ROW 13.76 COL 51.6 WIDGET-ID 14
     SPACE(34.39) SKIP(10.99)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Внешняя подсистема Open XML"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.


define frame motp-frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     tt-ext-system.esys-id AT ROW 2 COL 11 COLON-ALIGNED WIDGET-ID 26
          LABEL "Код"
          VIEW-AS FILL-IN 
          SIZE 10 BY 1
     tt-ext-system.esys-type AT ROW 2.08 COL 58.63 COLON-ALIGNED WIDGET-ID 58
          LABEL "Тип ВС" FORMAT "->,>>>,>>9"
          VIEW-AS COMBO-BOX INNER-LINES 11
          LIST-ITEM-PAIRS "Item 1",0
          DROP-DOWN-LIST
          SIZE 35.63 BY 1
     tt-ext-system.esys-name AT ROW 3.5 COL 3
          LABEL "Название" FORMAT "X(30)"
          VIEW-AS FILL-IN 
          SIZE 29 BY 1
     f-host-code at row 5 col 3
     b-host-code at row 5 col 23
     f-server-addres at row 6 col 3
     f-obj at row 7 col 3
     b-obj at row 7 col 30   
     e-mail-list at row 8 col 3
     f-proxy-addres at row 12 col 3
     f-proxy-login at row 13 col 3
     f-proxy-password at row 14 col 3 blank
     f-proxy-password-screen at row 14 col 3  no-label
     t-proxy-ssl at row 15.1 col 14 no-label
     "SSL прокси:" at row 15 col 3 view-as text size 11 by 1   
     SPACE(83.11) SKIP(5.12)  
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.
         
define frame diadoc-frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     tt-ext-system.esys-id AT ROW 2 COL 11 COLON-ALIGNED WIDGET-ID 26
          LABEL "Код"
          VIEW-AS FILL-IN 
          SIZE 10 BY 1
     tt-ext-system.esys-type AT ROW 2.08 COL 58.63 COLON-ALIGNED WIDGET-ID 58
          LABEL "Тип ВС" FORMAT "->,>>>,>>9"
          VIEW-AS COMBO-BOX INNER-LINES 11
          LIST-ITEM-PAIRS "Item 1",0
          DROP-DOWN-LIST
          SIZE 35.63 BY 1
     tt-ext-system.esys-name AT ROW 3.5 COL 14
          LABEL "Название" FORMAT "X(30)"
          VIEW-AS FILL-IN 
          SIZE 29 BY 1
     f-host-code at row 5 col 17
     b-host-code at row 5 col 40
     f-obj at row 6.5 col 16
     b-obj at row 6.5 col 40   
     
     f-diadoc-addres at row 8 col 10
     
     f-diadoc-user at row 9.5 col 10
     f-diadoc-pwd at row 11 col 9  blank
     f-diadoc-pwd-screen at row 10.9 col 9.4  no-label
     f-diadoc-key at row 12.5 col 5
     
     f-proxy-addres at row 14 col 2
     f-proxy-login at row 15.5 col 17
     f-proxy-password at row 17 col 16  blank
     f-proxy-password-screen at row 16.9 col 16.4  no-label
     f-diadoc-lastload at row 18.5 col 10
     t-diadoc-ssl at row 20.1 col 28 no-label
     "Без проверки шифрования:" at row 20 col 3 view-as text size 24 by 1
     SPACE(83.11) SKIP(5.12)  
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.

/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_ext-system B "?" ? ub ext-system
      TABLE: tt-ext-system T "?" NO-UNDO ub ext-system
      TABLE: tt-ext-system-attr T "?" NO-UNDO ub ext-system-attr
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

ASSIGN 
       b-links:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-links:HANDLE.

/* SETTINGS FOR FILL-IN tt-ext-system.esys-db-num-exp IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
/* SETTINGS FOR FILL-IN tt-ext-system.esys-db-num-imp IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
/* SETTINGS FOR TOGGLE-BOX tt-ext-system.esys-have-export IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-ext-system.esys-have-import IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-ext-system.esys-id IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-ext-system.esys-max-p-size IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-ext-system.esys-name IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT                                         */
/* SETTINGS FOR FILL-IN tt-ext-system.esys-num-days-keep-exp IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR TOGGLE-BOX tt-ext-system.esys-send-news-exp IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR TOGGLE-BOX tt-ext-system.esys-send-news-imp IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR COMBO-BOX tt-ext-system.esys-type IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
ASSIGN 
       f-exp-db-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN 
       f-imp-db-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN FI-delivery-method IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-des-label IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fi-screen-pass IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-ext-system.max-p-queue IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-ext-system.max-p-time IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-ext-system.save-days-pck-num IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-ext-system"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Внешняя подсистема Open XML */
DO:
/* Действия после нажатия кнопки Ввод */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Внешняя подсистема Open XML */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME f-diadoc-pwd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-diadoc-pwd Dialog-Frame
ON ANY-KEY OF f-diadoc-pwd IN FRAME diadoc-Frame /* Пароль */
DO:
    assign
    f-diadoc-pwd-screen :screen-value = fill('*':u, length(f-diadoc-pwd :screen-value )).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-diadoc-pwd Dialog-Frame
ON VALUE-CHANGED OF f-diadoc-pwd IN FRAME diadoc-Frame /* Пароль */
DO:
  assign
    f-diadoc-pwd-screen :screen-value = fill('*':u, length(f-diadoc-pwd :screen-value )).
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME f-proxy-password
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-proxy-passwordDialog-Frame
ON ANY-KEY OF f-proxy-password IN FRAME diadoc-Frame /* Пароль */
DO:
    assign
    f-proxy-password-screen :screen-value = fill('*':u, length(f-proxy-password :screen-value )).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-proxy-password Dialog-Frame
ON VALUE-CHANGED OF f-proxy-password IN FRAME diadoc-Frame /* Пароль */
DO:
  assign
    f-proxy-password-screen :screen-value = fill('*':u, length(f-proxy-password :screen-value )).
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME f-proxy-password
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-proxy-password Dialog-Frame
ON ANY-KEY OF f-proxy-password IN FRAME motp-frame /* Пароль */
DO:
    assign
      f-proxy-password-screen :screen-value = fill('*':u, length(f-proxy-password :screen-value ))
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-proxy-password Dialog-Frame
ON VALUE-CHANGED OF f-proxy-password IN FRAME motp-frame /* Пароль */
DO:
  assign
    f-proxy-password-screen :screen-value = fill('*':u, length(f-proxy-password :screen-value ))
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-db-export
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-db-export Dialog-Frame
ON CHOOSE OF b-db-export IN FRAME Dialog-Frame /* Btn 1 */
DO:
define variable v-rid as recid no-undo.
define buffer buf_db for ub.db.
   run adm/dbs.w ( INPUT parparentproc
                  ,INPUT {&LOOKUP}
                  ,OUTPUT v-rid) NO-ERROR.
   IF ERROR-STATUS:ERROR THEN return no-apply.
    FIND FIRST buf_db NO-LOCK WHERE
           recid(buf_db) = v-rid no-error.
   if available buf_db then do:
      assign
      tt-ext-system.esys-db-num-exp = buf_db.db-num
      f-exp-db-name = buf_db.db-name.
      display
      tt-ext-system.esys-db-num-exp
      f-exp-db-name
      with frame {&frame-name}.
   end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-db-import
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-db-import Dialog-Frame
ON CHOOSE OF b-db-import IN FRAME Dialog-Frame /* Btn 1 */
DO:
  define variable v-rid as recid no-undo.
define buffer buf_db for ub.db.
   run adm/dbs.w ( INPUT parparentproc
                  ,INPUT {&LOOKUP}
                  ,OUTPUT v-rid) NO-ERROR.
   IF ERROR-STATUS:ERROR THEN RETURN no-apply.
    FIND FIRST buf_db NO-LOCK WHERE
           recid(buf_db) = v-rid no-error.
   if available buf_db then do:
      assign
      tt-ext-system.esys-db-num-imp = buf_db.db-num
      f-imp-db-name = buf_db.db-name
      .
      display
      tt-ext-system.esys-db-num-imp
      f-imp-db-name
      with frame {&frame-name}.
   end.



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:

   run proc-save in this-procedure no-error.
   if error-status:error then return no-apply.
   assign
   p-success = yes.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit motp-Frame
ON CHOOSE OF b-exit IN FRAME motp-Frame /* Ввод */
DO:

   run proc-save-motp in this-procedure no-error.
   if error-status:error then return no-apply.
   assign
   p-success = yes.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit diadoc-Frame
ON CHOOSE OF b-exit IN FRAME diadoc-Frame /* Ввод */
DO:

   run proc-save-diadoc in this-procedure no-error.
   if error-status:error then return no-apply.
   assign
   p-success = yes.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-links
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-links Dialog-Frame
ON CHOOSE OF b-links IN FRAME Dialog-Frame /* Связи */
DO:
IF link-option = '':U THEN DO:
   run gbl/pop-up.p ( INPUT SELF:handle, input no ) no-error.
   if error-status :error then do: return no-apply. end.
end.
if link-option = "":U then do:
      return no-apply.
end.
run proc-b-link IN THIS-PROCEDURE ( INPUT link-option) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
    link-option = '':U.
    RETURN NO-APPLY.
END.
link-option = '':U.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

on choose of b-host-code in frame motp-frame
do :
  run proc-b-host IN THIS-PROCEDURE NO-ERROR.
  
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  DISPLAY
    f-host-code
  WITH FRAME motp-frame.
end .

on choose of b-host-code in frame diadoc-frame
do :
  run proc-b-host IN THIS-PROCEDURE NO-ERROR.
  
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  DISPLAY
    f-host-code
  WITH FRAME diadoc-frame.
end .

on choose of b-obj in frame motp-frame
do :
  define variable v-rid-list as character no-undo .
  define variable v-rid-rec  as recid no-undo .
  define buffer buf_shop for ub.shop .
  
  v-rid-list = "" .
  run adm/shops.w ( input parparentproc
                   ,input "b-sel"
                   ,input-output v-rid-list
                   ,no ).
  if v-rid-list = "":U then return.
  v-rid-rec = integer(v-rid-list) no-error .
  find first buf_shop no-lock where recid(buf_shop) = v-rid-rec no-error .
  if available buf_shop then f-obj:screen-value = {&shop} + string(buf_shop.obj-code) .
  assign f-obj .
end .

on value-changed of f-obj in frame motp-frame
do :
  assign f-obj .
end .

on choose of b-obj in frame diadoc-frame
do :
  define variable v-rid-list as character no-undo .
  define variable v-rid-rec  as recid no-undo .
  define buffer buf_shop for ub.shop .
  
  v-rid-list = "" .
  run adm/shops.w ( input parparentproc
                   ,input "b-sel"
                   ,input-output v-rid-list
                   ,no ).
  if v-rid-list = "":U then return.
  v-rid-rec = integer(v-rid-list) no-error .
  find first buf_shop no-lock where recid(buf_shop) = v-rid-rec no-error .
  if available buf_shop then f-obj:screen-value = {&shop} + string(buf_shop.obj-code) .
  assign f-obj .
end .

on value-changed of f-obj in frame diadoc-frame
do :
  assign f-obj .
end .

&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
DO:
{ gbl/stdbtn.i }
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-ext-system.delivery-method
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-ext-system.delivery-method Dialog-Frame
ON VALUE-CHANGED OF tt-ext-system.delivery-method IN FRAME Dialog-Frame /* delivery-method */
DO:
  ASSIGN
  tt-ext-system.delivery-method.
  run proc-value-change-method in this-procedure ( input tt-ext-system.delivery-method) no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit motp-Frame
ON CHOOSE OF b-quit IN FRAME motp-Frame /* Отмена */
DO:
{ gbl/stdbtn.i }
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit diadoc-Frame
ON CHOOSE OF b-quit IN FRAME diadoc-Frame /* Отмена */
DO:
{ gbl/stdbtn.i }
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-ext-system.esys-have-export
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-ext-system.esys-have-export Dialog-Frame
ON VALUE-CHANGED OF tt-ext-system.esys-have-export IN FRAME Dialog-Frame /* Экспорт */
DO:
    assign
        tt-ext-system.esys-have-export
    .
    run manage-export in this-procedure (
        input tt-ext-system.esys-have-export
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-ext-system.esys-have-import
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-ext-system.esys-have-import Dialog-Frame
ON VALUE-CHANGED OF tt-ext-system.esys-have-import IN FRAME Dialog-Frame /* Импорт */
DO:
    assign
        tt-ext-system.esys-have-import
    .
    run manage-import in this-procedure (
        input tt-ext-system.esys-have-import
    ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME tt-ext-system.esys-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-ext-system.esys-name Dialog-Frame
ON VALUE-CHANGED OF tt-ext-system.esys-name IN FRAME Dialog-Frame /* Название */
DO:
    ASSIGN
  tt-ext-system.esys-name.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME tt-ext-system.esys-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-ext-system.esys-type Dialog-Frame
ON VALUE-CHANGED OF tt-ext-system.esys-type IN FRAME Dialog-Frame /* Тип ВС */
DO:
    ASSIGN
  tt-ext-system.esys-type.
  RUN proc-value-changed-esys-type IN THIS-PROCEDURE ( input tt-ext-system.esys-type) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME tt-ext-system.esys-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-ext-system.esys-type motp-Frame
ON VALUE-CHANGED OF tt-ext-system.esys-type IN FRAME motp-Frame
DO:
  ASSIGN
    tt-ext-system.esys-type 
  .
  RUN proc-value-changed-esys-type IN THIS-PROCEDURE ( input tt-ext-system.esys-type) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME tt-ext-system.esys-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-ext-system.esys-type diadoc-Frame
ON VALUE-CHANGED OF tt-ext-system.esys-type IN FRAME diadoc-Frame
DO:
  ASSIGN
    tt-ext-system.esys-type 
  .
  RUN proc-value-changed-esys-type IN THIS-PROCEDURE ( input tt-ext-system.esys-type) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME f-password
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-password Dialog-Frame
ON ANY-KEY OF f-password IN FRAME Dialog-Frame /* Пароль */
DO:
    assign
    fi-screen-pass :screen-value = fill('*':u, length(f-password :screen-value )).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-password Dialog-Frame
ON VALUE-CHANGED OF f-password IN FRAME Dialog-Frame /* Пароль */
DO:
  assign
    fi-screen-pass :screen-value = fill('*':u, length(f-password :screen-value )).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_edoc-nn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_edoc-nn Dialog-Frame
ON CHOOSE OF MENU-ITEM m_edoc-nn /* Контрагенты для обмена данными (по EDOC-NN) */
DO:
    ASSIGN
  link-option = "edoc-nn".
  RUN proc-b-link IN THIS-PROCEDURE ( INPUT link-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      link-option = '':U.
      RETURN NO-APPLY.
  END.
  link-option = '':U.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_exite-edi
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_exite-edi Dialog-Frame
ON CHOOSE OF MENU-ITEM m_exite-edi /* Контрагенты для обмена данными (по EDI) */
DO:
  ASSIGN
  link-option = "exite-edi".
  RUN proc-b-link IN THIS-PROCEDURE ( INPUT link-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      link-option = '':U.
      RETURN NO-APPLY.
  END.
  link-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_locks
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_locks Dialog-Frame
ON CHOOSE OF MENU-ITEM m_locks /* Блокирующие связи */
DO:
      ASSIGN
  link-option = "locks".
  RUN proc-b-link IN THIS-PROCEDURE ( INPUT link-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      link-option = '':U.
      RETURN NO-APPLY.
  END.
  link-option = '':U.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_thobj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_thobj Dialog-Frame
ON CHOOSE OF MENU-ITEM m_thobj /* Соответствие объектов ВС объектам IBS TH */
DO:
    ASSIGN
  link-option = "thobjs".
  RUN proc-b-link IN THIS-PROCEDURE ( INPUT link-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      link-option = '':U.
      RETURN NO-APPLY.
  END.
  link-option = '':U.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-delete-pck-on
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-delete-pck-on Dialog-Frame
ON VALUE-CHANGED OF t-delete-pck-on IN FRAME Dialog-Frame /* Удал. ф-лы из HEAP */
DO:
  ASSIGN
  t-delete-pck-on.
  RUN manage-t-delete-pck-on ( t-delete-pck-on) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tg-cert-sign
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tg-cert-sign Dialog-Frame
ON VALUE-CHANGED OF tg-cert-sign IN FRAME Dialog-Frame /* Использовать электронную подпись */
DO:
  assign tg-cert-sign .
  run proc-value-changed-cert-sign in this-procedure (input tg-cert-sign) no-error .
  if error-status:error then return no-apply .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */
{ gbl/hot-key.i b-exit  }


/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON stop UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
{ gbl/getcntxt.i get }

   if not (p-mode = {&add-def}
           or p-mode = {&lookup}
           or p-mode = {&update}) then do:
      message
      substitute("Неправильное значение параметра p-mode = &1", p-mode)
      view-as alert-box error.
      undo, return error.
   end.
// if p-mode <> {&lookup} and v-cntxt-db-num > 0 then do: - 29/VIII-2018 заменено на ibs.th.gbl.gbl-var:g#db-num
   if p-mode <> {&lookup} and ibs.th.gbl.gbl-var:g#db-num > 0 then do:
      message
      substitute("Нельзя редактировать или добавлять специальную внешнюю систему в УБД")
      view-as alert-box error.
      undo, return error.

   end.
   case p-mode:
    when {&lookup} then do:
      find first locked_ext-system no-lock where
             locked_ext-system.esys-id = p-esys-id
       and locked_ext-system.db-num = p-db-num no-error.
    end.
    when {&update} then do:
         do transaction:
        find first locked_ext-system exclusive-lock where
           locked_ext-system.esys-id = p-esys-id
      and locked_ext-system.db-num = p-db-num no-error.
      end.
     end.
   end case.
    create tt-ext-system.
    if p-mode = {&add-def} then do:
      assign
      tt-ext-system.db-num = 0
      tt-ext-system.esys-send-news-exp = yes
      tt-ext-system.esys-send-news-imp = yes
      tt-ext-system.esys-num-days-keep-imp = 0
      tt-ext-system.esys-db-num-exp = 0
      tt-ext-system.esys-db-num-imp = 0
      tt-ext-system.esys-name = "<Новая внешняя система>"
      tt-ext-system.esys-max-p-size = 1000
      .
    end.
    else do:
       buffer-copy  locked_ext-system to tt-ext-system.
       for each tt-ext-system-attr:
         delete tt-ext-system-attr.
       end.
       do v-ii = 1 to num-entries({&form-esys-attr}):
         v-attr-code = entry(v-ii, {&form-esys-attr}) .
         create tt-ext-system-attr.
         assign
         tt-ext-system-attr.esys-id = tt-ext-system.esys-id
         tt-ext-system-attr.db-num = tt-ext-system.db-num
         tt-ext-system-attr.esya-attr-code = v-attr-code
          .
         run ext-system-attr-value (
                                      input  tt-ext-system.esys-id
                                     ,input  tt-ext-system.db-num
                                     ,input  v-attr-code
                                     ,output tt-ext-system-attr.esya-attr-value
                                     ,output v-type) .
          release tt-ext-system-attr.
       end.
    end.
  if tt-ext-system.esys-type = integer({&openxml-type-is_motp})
  then do :
    run motp-enable in this-procedure .
     
  end .  
  else do :
     if tt-ext-system.esys-type = integer({&openxml-type-is_diadoc})
     then do :
        run diadoc-enable in this-procedure .
     end .  
     else do : 
        run myenable in this-procedure .
     end.
  end .
  
  WAIT-FOR GO OF FRAME dialog-frame or go OF FRAME motp-frame or go OF FRAME diadoc-frame.
 
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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY fi-des-label f-ftp-ip f-login FI-delivery-method f-password 
          fi-screen-pass f-ftp-path f-ftp-path-in f-ftp-path-out f-exp-db-name 
          t-delete-pck-on T-exp-conf-wait f-imp-db-name T-imp-conf-send 
          tg-cert-sign fi-cert-sign-subject fi-cert-sign-issuer cb-cert-file-ext 
          cb-cert-repository l-save-oxml-pck FILL-IN-4 
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-ext-system THEN 
    DISPLAY tt-ext-system.esys-id tt-ext-system.esys-des tt-ext-system.esys-type 
          tt-ext-system.esys-name tt-ext-system.delivery-method 
          tt-ext-system.esys-have-export tt-ext-system.esys-db-num-exp 
          tt-ext-system.save-days-pck-num tt-ext-system.esys-send-news-exp 
          tt-ext-system.esys-have-import tt-ext-system.esys-num-days-keep-exp 
          tt-ext-system.esys-max-p-size tt-ext-system.esys-db-num-imp 
          tt-ext-system.esys-send-news-imp tt-ext-system.max-p-queue 
          tt-ext-system.max-p-time 
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-links b-help RECT-1 RECT-2 RECT-3 RECT-4 
         tt-ext-system.esys-id tt-ext-system.esys-des tt-ext-system.esys-type 
         tt-ext-system.esys-name f-ftp-ip f-login FI-delivery-method 
         tt-ext-system.delivery-method f-password f-ftp-path f-ftp-path-in 
         tt-ext-system.esys-have-export f-ftp-path-out b-db-export 
         f-exp-db-name t-delete-pck-on tt-ext-system.save-days-pck-num 
         T-exp-conf-wait tt-ext-system.esys-have-import 
         tt-ext-system.esys-num-days-keep-exp tt-ext-system.esys-max-p-size 
         b-db-import f-imp-db-name tt-ext-system.max-p-queue T-imp-conf-send 
         tt-ext-system.max-p-time tg-cert-sign fi-cert-sign-subject 
         fi-cert-sign-issuer cb-cert-file-ext l-save-oxml-pck FILL-IN-4 
         cb-cert-repository
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE manage-delete-pck-on Dialog-Frame 
PROCEDURE manage-delete-pck-on :
DEFINE INPUT PARAMETER t-delete-pck-on AS LOGICAL NO-UNDO.
CASE t-delete-pck-on:
    WHEN YES THEN DO:
      IF p-mode <> {&LOOKUP} THEN
      ENABLE
      tt-ext-system.save-days-pck-num
      WITH FRAME {&FRAME-NAME}.
      if tt-ext-system.save-days-pck-num < 20 then tt-ext-system.save-days-pck-num = 20.
      DISPLAY
      tt-ext-system.save-days-pck-num
      l-save-oxml-pck
      WITH FRAME {&FRAME-NAME}.

    END.
    WHEN NO THEN DO:
        DISABLE
        tt-ext-system.save-days-pck-num
        WITH FRAME {&FRAME-NAME}.
        HIDE
        tt-ext-system.save-days-pck-num
        l-save-oxml-pck
        IN FRAME {&FRAME-NAME}.
    END.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE manage-exp-conf-wait Dialog-Frame 
PROCEDURE manage-exp-conf-wait :
DEFINE input parameter p-exp-conf-wait    as integer          no-undo.
do
with frame {&frame-name}
on error undo, return error
:
    if p-exp-conf-wait = integer({&openxml-exp-conf-wait})
    then do:
        enable
        tt-ext-system.max-p-queue
        tt-ext-system.max-p-time
        .
    end.
    else do:
        disable
        tt-ext-system.max-p-queue
        tt-ext-system.max-p-time
        .
        assign
        tt-ext-system.max-p-time = 0
        tt-ext-system.max-p-queue = 1000

        .

    end.
    display
    tt-ext-system.max-p-queue
    tt-ext-system.max-p-time
    .


end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE manage-export Dialog-Frame 
PROCEDURE manage-export :
define input parameter p-have-export    as logical          no-undo.
do
with frame {&frame-name}
on error undo, return error
:
    if p-have-export = yes
    then do:
      enable
      tt-ext-system.esys-num-days-keep-exp
      t-exp-conf-wait when tt-ext-system.delivery-method <> integer({&esys-dm-erp-1C-RN})
      tt-ext-system.esys-max-p-size
      b-db-export
      .
      assign
      tt-ext-system.esys-send-news-exp = yes
      .
    end.
    else do:
        disable
        b-db-export
        tt-ext-system.esys-num-days-keep-exp
        tt-ext-system.esys-max-p-size
        t-exp-conf-wait
       .
        assign
        tt-ext-system.esys-send-news-exp = no
        tt-ext-system.esys-max-p-size = (if tt-ext-system.esys-max-p-size = 0
                                         then 1000
                                         else tt-ext-system.esys-max-p-size)
        t-exp-conf-wait = no
        .

    end.
    display
    tt-ext-system.esys-send-news-exp
    tt-ext-system.esys-max-p-size
    .
    tt-ext-system.exp-conf-wait = (if t-exp-conf-wait
                                   then integer({&openxml-exp-conf-wait})
                                   else integer({&openxml-exp-conf-no-wait})
                                   ).
    run manage-exp-conf-wait in this-procedure ( input tt-ext-system.exp-conf-wait).
end.
END PROCEDURE. /* manage-export */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE manage-import Dialog-Frame 
PROCEDURE manage-import :
define input parameter p-have-import    as logical          no-undo.
do
with frame {&frame-name}
on error undo, return error
:
    if p-have-import = yes
    then do:
        enable
        b-db-import
        t-imp-conf-send when tt-ext-system.delivery-method <> integer({&esys-dm-erp-1C-RN})
        .
        assign
        tt-ext-system.esys-send-news-imp = yes
        .
    end.
    else do:
        disable
        b-db-import
        t-imp-conf-send
        .
        assign
        tt-ext-system.esys-send-news-imp = no
        t-imp-conf-send = no
        .

    end.
    display
    tt-ext-system.esys-send-news-imp.
    tt-ext-system.imp-conf-send = (if t-imp-conf-send
                                   then integer({&openxml-imp-conf-send})
                                   else integer({&openxml-imp-conf-no-send})
                                   ).
end.
END PROCEDURE. /* manage-import */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE manage-t-delete-pck-on Dialog-Frame 
PROCEDURE manage-t-delete-pck-on :
DEFINE INPUT PARAMETER t-save-oxml-pck AS LOGICAL NO-UNDO.
CASE t-save-oxml-pck:
    WHEN YES THEN DO:
      IF p-mode <> {&LOOKUP} THEN
      ENABLE
      tt-ext-system.save-days-pck-num
      WITH FRAME {&FRAME-NAME}.
      if tt-ext-system.save-days-pck-num < 20 then tt-ext-system.save-days-pck-num = 20.
      DISPLAY
      tt-ext-system.save-days-pck-num
      WITH FRAME {&FRAME-NAME}.

    END.
    WHEN NO THEN DO:
        DISABLE
        tt-ext-system.save-days-pck-num
        WITH FRAME {&FRAME-NAME}.
        HIDE
        tt-ext-system.save-days-pck-num
        IN FRAME {&FRAME-NAME}.
    END.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


procedure MOTP-Enable :
  DEFINE VARIABLE v-list-items AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-ii AS integer NO-UNDO.
  define buffer buf_db for ub.db.
  do v-ii = 1 to num-entries({&openxml-special-type-list}):
  &scop openxml-type-code string(v-ii)
    assign
    tt-ext-system.esys-type:list-item-pairs in frame Motp-frame =
    (if v-ii = 1
    then ({&openxml-type-name}  + {&comma-char} +  entry(v-ii, {&openxml-special-type-list}))
    else (tt-ext-system.esys-type:list-item-pairs + {&comma-char} +
           {&openxml-type-name}  + {&comma-char} +  entry(v-ii, {&openxml-special-type-list}))
  
    )
    .
  end.
  for each tt-ext-system-attr:
    case tt-ext-system-attr.esya-attr-code:
      when {&attr-esys-host-code} then do:
        assign f-host-code = integer(tt-ext-system-attr.esya-attr-value) .
      end.
      when {&attr-esys-obj} then do:
        assign f-obj = tt-ext-system-attr.esya-attr-value .
      end.
      when {&attr-esys-server-addr} then do:
        assign f-server-addres = tt-ext-system-attr.esya-attr-value.
      end.
      when {&attr-esys-proxy-addr} then do:
        assign f-proxy-addres = tt-ext-system-attr.esya-attr-value .
      end.
      when {&attr-esys-proxy-login} then do:
        assign f-proxy-login = tt-ext-system-attr.esya-attr-value .
      end.
      when {&attr-esys-proxy-pswd} then do:
        assign f-proxy-password = tt-ext-system-attr.esya-attr-value .
      end.
      when {&attr-esys-proxy-ssl} then do:
        assign t-proxy-ssl = logical(tt-ext-system-attr.esya-attr-value) .
      end.
      when {&attr-esys-mail-list} then do:
        assign e-mail-list = tt-ext-system-attr.esya-attr-value .
      end.
    end case.
  end.
  
  ASSIGN
   f-proxy-password-screen:WIDTH-CHARS IN FRAME motp-frame  = f-proxy-password:WIDTH-CHARS IN FRAME motp-frame  - 0.5
   f-proxy-password-screen:HEIGHT-CHARS IN FRAME motp-frame  = f-proxy-password:HEIGHT-CHARS IN FRAME motp-frame  - 0.6
   f-proxy-password-screen:row IN FRAME motp-frame  = f-proxy-password:row IN FRAME motp-frame  + 0.2
   f-proxy-password-screen:COL IN FRAME motp-frame  = f-proxy-password:col IN FRAME motp-frame  + 0.2
  .
  f-proxy-password-screen  = fill('*':u, length(f-proxy-password )).
  
  DISPLAY
    tt-ext-system.esys-id
    tt-ext-system.esys-name
    tt-ext-system.esys-type
    f-host-code
    f-server-addres
    f-obj
    f-proxy-addres
    f-proxy-login
    f-proxy-password
    f-proxy-password-screen
    t-proxy-ssl
    e-mail-list
  WITH FRAME MOTP-frame .
  ENABLE
    b-exit when p-mode <> {&lookup}
    b-quit
    b-host-code when p-mode <> {&lookup}
    f-obj when p-mode <> {&lookup}
    b-obj when p-mode <> {&lookup}
    tt-ext-system.esys-name when p-mode <> {&lookup}
    tt-ext-system.esys-type when p-mode <> {&lookup}
    f-server-addres when p-mode <> {&lookup}
    f-proxy-addres when p-mode <> {&lookup}
    f-proxy-login when p-mode <> {&lookup}
    f-proxy-password when p-mode <> {&lookup}
    f-proxy-password-screen when p-mode <> {&lookup}
    t-proxy-ssl when p-mode <> {&lookup}
    e-mail-list when p-mode <> {&lookup}
  WITH FRAME Motp-frame .
  view frame Motp-frame .
end procedure .

procedure Diadoc-Enable :
  DEFINE VARIABLE v-list-items AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-ii AS integer NO-UNDO.
  define buffer buf_db for ub.db.
  do v-ii = 1 to num-entries({&openxml-special-type-list}):
  &scop openxml-type-code string(v-ii)
    assign
    tt-ext-system.esys-type:list-item-pairs in frame diadoc-frame =
    (if v-ii = 1
    then ({&openxml-type-name}  + {&comma-char} +  entry(v-ii, {&openxml-special-type-list}))
    else (tt-ext-system.esys-type:list-item-pairs + {&comma-char} +
           {&openxml-type-name}  + {&comma-char} +  entry(v-ii, {&openxml-special-type-list}))
  
    )
    .
  end.
  for each tt-ext-system-attr:
    case tt-ext-system-attr.esya-attr-code:
      when {&attr-esys-obj} then do:
        assign f-obj = tt-ext-system-attr.esya-attr-value .
      end.
      when {&attr-esys-host-code} then do:
        assign f-host-code = integer(tt-ext-system-attr.esya-attr-value) .
      end.
      when {&attr-esys-diadoc-user} then do:
        assign f-diadoc-user = tt-ext-system-attr.esya-attr-value .
      end.
      when {&attr-esys-diadoc-pwd} then do:
        assign f-diadoc-pwd= tt-ext-system-attr.esya-attr-value .
      end.
      when {&attr-esys-server-addr} then do:
        assign f-diadoc-addres = tt-ext-system-attr.esya-attr-value.
      end.
      when {&attr-esys-diadoc-key} then do:
        assign f-diadoc-key = tt-ext-system-attr.esya-attr-value .
      end.
      when {&attr-esys-diadoc-lastload} then do:
        assign f-diadoc-lastload = date(tt-ext-system-attr.esya-attr-value) .
      end.
      when {&attr-esys-diadoc-ssl} then do:
        assign t-diadoc-ssl = logical(tt-ext-system-attr.esya-attr-value) .
      end.
      
      when {&attr-esys-proxy-addr} then do:
        assign f-proxy-addres = tt-ext-system-attr.esya-attr-value .
      end.
      when {&attr-esys-proxy-login} then do:
        assign f-proxy-login = tt-ext-system-attr.esya-attr-value .
      end.
      when {&attr-esys-proxy-pswd} then do:
        assign f-proxy-password = tt-ext-system-attr.esya-attr-value .
      end.
      
    end case.
  end.
  ASSIGN
 f-diadoc-pwd-screen:WIDTH-CHARS IN FRAME diadoc-frame  = f-diadoc-pwd:WIDTH-CHARS IN FRAME diadoc-frame  - 0.5
 f-diadoc-pwd-screen:HEIGHT-CHARS IN FRAME diadoc-frame  = f-diadoc-pwd:HEIGHT-CHARS IN FRAME diadoc-frame  - 0.6
 f-diadoc-pwd-screen:row IN FRAME diadoc-frame  = f-diadoc-pwd:row IN FRAME diadoc-frame  + 0.2
 f-diadoc-pwd-screen:COL IN FRAME diadoc-frame  = f-diadoc-pwd:col IN FRAME diadoc-frame  + 0.2
 .
 ASSIGN
 f-proxy-password-screen:WIDTH-CHARS IN FRAME diadoc-frame  = f-proxy-password:WIDTH-CHARS IN FRAME diadoc-frame  - 0.5
 f-proxy-password-screen:HEIGHT-CHARS IN FRAME diadoc-frame  = f-proxy-password:HEIGHT-CHARS IN FRAME diadoc-frame  - 0.6
 f-proxy-password-screen:row IN FRAME diadoc-frame  = f-proxy-password:row IN FRAME diadoc-frame  + 0.2
 f-proxy-password-screen:COL IN FRAME diadoc-frame  = f-proxy-password:col IN FRAME diadoc-frame  + 0.2
 .
 f-diadoc-pwd-screen      = fill('*':u, length(f-diadoc-pwd )).
 f-proxy-password-screen  = fill('*':u, length(f-proxy-password )).
  DISPLAY
    tt-ext-system.esys-id
    tt-ext-system.esys-name
    tt-ext-system.esys-type
    f-diadoc-user
    f-diadoc-pwd
    f-host-code
    f-obj 
    f-diadoc-addres
    f-diadoc-key
    f-proxy-addres
    f-proxy-login
    f-proxy-password
    f-proxy-password-screen
    f-diadoc-pwd-screen
    f-diadoc-lastload
    t-diadoc-ssl
    
  WITH FRAME diadoc-frame .
  ENABLE
    b-exit when p-mode <> {&lookup}
    b-quit
    tt-ext-system.esys-name when p-mode <> {&lookup}
    tt-ext-system.esys-type when p-mode <> {&lookup}
    f-diadoc-user           when p-mode <> {&lookup}
    f-diadoc-pwd            when p-mode <> {&lookup}
    f-diadoc-addres         when p-mode <> {&lookup}
    f-diadoc-key            when p-mode <> {&lookup}
    t-diadoc-ssl    when p-mode <> {&lookup}
    f-proxy-addres          when p-mode <> {&lookup}
    f-proxy-login           when p-mode <> {&lookup}
    f-proxy-password        when p-mode <> {&lookup}
    f-proxy-password-screen when p-mode <> {&lookup}
    f-diadoc-pwd-screen     when p-mode <> {&lookup}
    f-diadoc-lastload       when p-mode <> {&lookup}
    f-host-code             when p-mode <> {&lookup}
    b-host-code             when p-mode <> {&lookup}
    f-obj                   when p-mode <> {&lookup}
    b-obj                   when p-mode <> {&lookup}
  WITH FRAME diadoc-frame .
  view frame diadoc-frame .
end procedure .


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
define variable v-list-item-pairs as character no-undo .
DEFINE VARIABLE v-list-items AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ii AS integer NO-UNDO.
define buffer buf_db for ub.db.

  v-list-item-pairs = "" .
do v-ii = 1 to num-entries({&openxml-special-type-list}):
&scop openxml-type-code string(v-ii)
  v-list-item-pairs = 
  (if v-ii = 1
  then ({&openxml-type-name}  + {&comma-char} +  entry(v-ii, {&openxml-special-type-list}))
  else (v-list-item-pairs + {&comma-char} +
         {&openxml-type-name}  + {&comma-char} +  entry(v-ii, {&openxml-special-type-list}))

  )
  .
end.
  tt-ext-system.esys-type:list-item-pairs in frame {&frame-name} = v-list-item-pairs .
ASSIGN
 fi-screen-pass:WIDTH-CHARS IN FRAME {&frame-name} = f-password:WIDTH-CHARS IN FRAME {&frame-name} - 0.5
 fi-screen-pass:HEIGHT-CHARS IN FRAME {&frame-name} = f-password:HEIGHT-CHARS IN FRAME {&frame-name} - 0.6
 fi-screen-pass:row IN FRAME {&frame-name} = f-password:row IN FRAME {&frame-name} + 0.20
 fi-screen-pass:COL IN FRAME {&frame-name} = f-password:col IN FRAME {&frame-name} + 0.25
 .
for each tt-ext-system-attr:
  case tt-ext-system-attr.esya-attr-code:
     when {&attr-esys-ftp-ip}       then f-ftp-ip       = tt-ext-system-attr.esya-attr-value.
     when {&attr-esys-ftp-login}    then f-login        = tt-ext-system-attr.esya-attr-value.
     when {&attr-esys-ftp-password} then f-password     = tt-ext-system-attr.esya-attr-value.
     when {&attr-esys-ftp-path}     then f-ftp-path     = tt-ext-system-attr.esya-attr-value.
     when {&attr-esys-ftp-path-in}  then f-ftp-path-in  = tt-ext-system-attr.esya-attr-value.
     when {&attr-esys-ftp-path-out} then f-ftp-path-out = tt-ext-system-attr.esya-attr-value.
     when {&attr-esys-cert-sign}         then tg-cert-sign = logical(tt-ext-system-attr.esya-attr-value) .
     when {&attr-esys-cert-sign-subject} then fi-cert-sign-subject = tt-ext-system-attr.esya-attr-value.
     when {&attr-esys-cert-sign-issuer}  then fi-cert-sign-issuer  = tt-ext-system-attr.esya-attr-value.
     when {&attr-esys-cert-file-ext}     then cb-cert-file-ext     = tt-ext-system-attr.esya-attr-value.
     when {&attr-esys-cert-repository}   then cb-cert-repository   = integer(tt-ext-system-attr.esya-attr-value).
  end case.
end.
&SCOPED-DEFINE esys-dm-code ENTRY(v-ii, {&esys-dm-list})
DO v-ii = 1 TO NUM-ENTRIES({&esys-dm-list}):
    ASSIGN
    v-list-items = v-list-items + (IF v-ii = 1 THEN '' ELSE {&comma-char}) +
                {&esys-dm-name} + {&comma-char} + {&esys-dm-code}
    .
END.
ASSIGN
tt-ext-system.delivery-method:list-item-pairs IN FRAME {&FRAME-NAME} = v-list-items.
DISPLAY
fi-des-label
fi-delivery-method
WITH FRAME {&frame-name}.
if tt-ext-system.esys-db-num-exp >= 0 then do:
  find first buf_db no-lock where
            buf_db.db-num = tt-ext-system.esys-db-num-exp no-error.
  if available buf_db then do:
    f-exp-db-name = buf_db.db-name.
  end.
  else do:
    f-exp-db-name = {&question-mark}.
  end.

end.
if tt-ext-system.esys-db-num-imp >= 0 then do:
  find first buf_db no-lock where
            buf_db.db-num = tt-ext-system.esys-db-num-imp no-error.
  if available buf_db then do:
    f-imp-db-name = buf_db.db-name.
  end.
  else do:
    f-imp-db-name = {&question-mark}.
  end.

end.
assign
b-links:menu-mouse in frame {&frame-name} = 1
t-exp-conf-wait = (tt-ext-system.exp-conf-wait = INTEGER({&openxml-exp-conf-wait}))
t-imp-conf-send = (tt-ext-system.imp-conf-send = INTEGER({&openxml-imp-conf-send}))
t-delete-pck-on = (tt-ext-system.delete-pck-on = 1)
.
IF AVAILABLE tt-ext-system THEN
DISPLAY
tt-ext-system.esys-id
tt-ext-system.esys-name
tt-ext-system.esys-des
tt-ext-system.esys-have-export
tt-ext-system.esys-db-num-exp
tt-ext-system.esys-send-news-exp
tt-ext-system.esys-num-days-keep-exp
tt-ext-system.esys-have-import
tt-ext-system.esys-send-news-imp
tt-ext-system.esys-db-num-imp
tt-ext-system.max-p-queue
tt-ext-system.max-p-time
tt-ext-system.esys-max-p-size
tt-ext-system.esys-type
f-exp-db-name
f-imp-db-name
t-exp-conf-wait
t-imp-conf-send
tt-ext-system.delivery-method
t-delete-pck-on
tg-cert-sign
WITH FRAME {&frame-name}.
ENABLE
b-exit when p-mode <> {&lookup}
b-quit
b-help
tt-ext-system.esys-name when p-mode <> {&lookup}
tt-ext-system.esys-des  when p-mode <> {&lookup}
tt-ext-system.esys-have-export  when p-mode <> {&lookup}
tt-ext-system.esys-have-import  when p-mode <> {&lookup}
tt-ext-system.delivery-method when p-mode <> {&lookup}
tt-ext-system.esys-type when p-mode <> {&lookup}
b-links when p-mode <> {&add-def}
t-delete-pck-on when p-mode <> {&lookup}
t-exp-conf-wait
t-imp-conf-send
tg-cert-sign when p-mode <> {&lookup}
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.

if p-mode = {&lookup} then do:
  hide
  b-exit in frame {&frame-name} .
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1
  .
end.
else do:
  run manage-export in this-procedure ( input tt-ext-system.esys-have-export).
  run manage-import in this-procedure ( input tt-ext-system.esys-have-import).
  run manage-exp-conf-wait in this-procedure ( input tt-ext-system.exp-conf-wait).
  run manage-t-delete-pck-on in this-procedure ( input t-delete-pck-on).
end.
run proc-value-change-method in this-procedure (input tt-ext-system.delivery-method) no-error.
run proc-value-changed-cert-sign in this-procedure (input tg-cert-sign) no-error .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-link Dialog-Frame 
PROCEDURE proc-b-link :
define input parameter p-link-option as character no-undo.
define variable v-rid-list as character no-undo.
define variable v-resource-id as character no-undo.

case p-link-option:
   when "thobjs" then do:
        run ref/esysclis.w ( input parparentproc
                            ,input ""
                            ,input "one"
                            ,input locked_ext-system.esys-id
                            ,input-output v-rid-list) no-error.

   end.
   when "edoc-nn" then do:
      run cus/edoc-cli.w ( input parparentproc
                          ,input ""
                          ,input "esys-id"
                          ,input string(locked_ext-system.esys-id)
                          ,input-output v-rid-list) no-error.
   end.
   when "exite-edi" then do:
      run cus/exiteedi.w ( input parparentproc
                          ,input ""
                          ,input "esys-id"
                          ,input string(locked_ext-system.esys-id)
                          ,input-output v-rid-list) no-error.
   end.
   when "locks" then do:
     run gen-key-rec in this-procedure ( input {&table_ext-system}
                                        ,input (buffer locked_ext-system:handle)
                                        ,output v-resource-id).
      run gbl/some-lks.w ( input parparentproc
                            ,input '':U /*bttns*/
                            ,input "resource-id"
                            ,input v-resource-id
                            ,input "":U /*lk-type*/
                            ,input-output v-rid-list) no-error.

   end.
end case.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-host Dialog-Frame 
PROCEDURE proc-b-host :
define variable ref-list as char no-undo.
DEFINE VARIABLE new-host-code AS INTEGE no-undo.
DEFINE BUFFER buf_sysclients FOR ub.clients.
  run adm/sconfs.w (
                 input parParentProc
                ,input "b-sel":U
                ,input no
                ,input v-cntxt-host-code-obj
                ,output new-host-code
                ,input-output ref-list ) .
  .
if new-host-code = ?
or new-host-code = 0
then do:
   ASSIGN
   f-host-code = ?
   .
END.
ELSE DO:

  find first buf_sysclients where
            buf_sysclients.obj-type = {&cmp}
        and buf_sysclients.obj-code = new-host-code no-lock.
    ASSIGN
    f-host-code = buf_sysclients.obj-code
    .
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
define variable v-rec as recid no-undo .
define variable psw-buf as character no-undo .
define variable v-attr-code as character no-undo .
define buffer buf_ext-system for ub.ext-system.
if p-mode = {&lookup} then return.

assign
frame {&frame-name}
tt-ext-system.esys-name
tt-ext-system.esys-des
tt-ext-system.esys-have-export
tt-ext-system.esys-db-num-exp
tt-ext-system.esys-send-news-exp
tt-ext-system.esys-num-days-keep-exp
tt-ext-system.esys-have-import
tt-ext-system.esys-send-news-imp
tt-ext-system.esys-db-num-imp
tt-ext-system.max-p-queue
tt-ext-system.max-p-time
tt-ext-system.esys-max-p-size
t-exp-conf-wait
t-imp-conf-send
tt-ext-system.delivery-method
t-delete-pck-on
tt-ext-system.delete-pck-on = (IF t-delete-pck-on THEN 1 ELSE 0)
tt-ext-system.save-days-pck-num
tt-ext-system.esys-type
tg-cert-sign
.
if tt-ext-system.delivery-method = integer({&esys-dm-nn})
or tt-ext-system.delivery-method = integer({&esys-dm-nnold})
or tt-ext-system.delivery-method = integer({&esys-dm-exite-edi})
or tt-ext-system.delivery-method = integer({&esys-dm-contour-edi})
then do:
   assign
   f-ftp-ip
   f-ftp-path
   f-login.
end.
if tt-ext-system.delivery-method = integer({&esys-dm-exite-edi})
or tt-ext-system.delivery-method = integer({&esys-dm-contour-edi})
then do:
   assign
   f-ftp-path-in
   f-ftp-path-out
   .
end.
if tg-cert-sign then assign
  fi-cert-sign-subject
  fi-cert-sign-issuer
  cb-cert-file-ext
  cb-cert-repository
.
else assign
  fi-cert-sign-subject = ""
  fi-cert-sign-issuer  = ""
  cb-cert-file-ext     = ""
  cb-cert-repository   = ?
.  

if p-mode = {&update} then do:
   v-rec = recid(locked_ext-system).
end.
IF f-password:VISIBLE IN FRAME {&FRAME-NAME} THEN DO:
    ASSIGN
    f-password.
    if f-password <> '':U
    then do:
      run ref/per-pswd.w ( output psw-buf ) .
      if f-password <> psw-buf then do:
        message
        "Пароль не подтвержден"
        view-as alert-box ERROR .
        apply "ENTRY":U to f-password IN frame {&frame-name}.
        return error.
      end.
   end.
END.

if p-mode = {&add-def} then do:
  if tt-ext-system.esys-type = integer({&openxml-type-mercury})
  then do :
    find first ext-system no-lock where ext-system.esys-type = integer({&openxml-type-mercury}) no-error .
    if available ext-system
    then do :
      MESSAGE
      "В системе уже есть ВС с типом 'Меркурий'. Код ВС: " string(ext-system.esys-id)
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
    end.  
  end.
  do v-ii = 1 to num-entries({&form-esys-attr}):
    v-attr-code = entry(v-ii, {&form-esys-attr}) .
    find first tt-ext-system-attr where
            tt-ext-system-attr.esya-attr-code = v-attr-code no-error.
    if not available tt-ext-system-attr then do:
      create tt-ext-system-attr.
      assign
      tt-ext-system-attr.esys-id = 0
      tt-ext-system-attr.db-num = 0
      tt-ext-system-attr.esya-attr-code = v-attr-code
      .
      release tt-ext-system-attr.
    end.
  end.
end.

for each tt-ext-system-attr:
  case tt-ext-system-attr.esya-attr-code:
     when {&attr-esys-ftp-ip}       then tt-ext-system-attr.esya-attr-value = f-ftp-ip.
     when {&attr-esys-ftp-login}    then tt-ext-system-attr.esya-attr-value = f-login.
     when {&attr-esys-ftp-password} then tt-ext-system-attr.esya-attr-value = f-password.
     when {&attr-esys-ftp-path}     then tt-ext-system-attr.esya-attr-value = f-ftp-path.
     when {&attr-esys-ftp-path-in}  then tt-ext-system-attr.esya-attr-value = f-ftp-path-in.
     when {&attr-esys-ftp-path-out} then tt-ext-system-attr.esya-attr-value = f-ftp-path-out.
     when {&attr-esys-cert-sign}         then tt-ext-system-attr.esya-attr-value = string(tg-cert-sign).
     when {&attr-esys-cert-sign-subject} then tt-ext-system-attr.esya-attr-value = fi-cert-sign-subject.
     when {&attr-esys-cert-sign-issuer}  then tt-ext-system-attr.esya-attr-value = fi-cert-sign-issuer.
     when {&attr-esys-cert-file-ext}     then tt-ext-system-attr.esya-attr-value = cb-cert-file-ext.
     when {&attr-esys-cert-repository}   then tt-ext-system-attr.esya-attr-value = string(cb-cert-repository).
  end case.
end.


run bge/extsyss1.p ( input p-mode
                    ,input no /*p-silent*/
                    ,input-output v-rec
                    ,input tt-ext-system.esys-id
                    ,input 0 /*p-db-num*/
                    ,input tt-ext-system.esys-name
                    ,input tt-ext-system.esys-des
                    ,input tt-ext-system.esys-have-export
                    ,input tt-ext-system.esys-db-num-exp
                    ,input tt-ext-system.esys-send-news-exp
                    ,input tt-ext-system.esys-num-days-keep-exp
                    ,INPUT tt-ext-system.esys-max-p-size
                    ,input (IF t-exp-conf-wait
                            THEN integer({&openxml-exp-conf-wait})
                            ELSE integer({&openxml-exp-conf-no-wait}))
                    ,INPUT (IF t-exp-conf-wait
                            THEN tt-ext-system.max-p-queue
                            ELSE 1000)
                    ,INPUT (IF t-exp-conf-wait
                            THEN tt-ext-system.max-p-time
                            ELSE 0)
                    ,input tt-ext-system.esys-have-import
                    ,input tt-ext-system.esys-db-num-imp
                    ,input tt-ext-system.esys-send-news-imp
                    ,input tt-ext-system.esys-num-days-keep-imp
                    ,input (IF t-imp-conf-send
                            THEN integer({&openxml-imp-conf-send})
                            ELSE integer({&openxml-imp-conf-no-send}))
                    ,input tt-ext-system.esys-type
                    ,input tt-ext-system.delivery-method
                    ,INPUT tt-ext-system.delete-pck-on
                    ,INPUT tt-ext-system.save-days-pck-num
                    ,input table tt-ext-system-attr
                                        ) no-error.
if error-status:error then do:
  undo, return error.
end.
else do:
  find first buf_ext-system no-lock where
          recid(buf_ext-system) = v-rec no-error.
  if available buf_ext-system then do:
    assign
    p-esys-id = buf_ext-system.esys-id.
  end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save-motp :
define variable v-rec as recid no-undo .
define variable psw-buf as character no-undo .
define buffer buf_ext-system for ub.ext-system.
if p-mode = {&lookup} then return.
assign
frame motp-frame
tt-ext-system.esys-name
tt-ext-system.esys-type
f-host-code
f-obj
f-server-addres
f-proxy-addres
f-proxy-login
f-proxy-password
t-proxy-ssl
e-mail-list
.
if tt-ext-system.esys-type = 0 then do:
    MESSAGE
    "Задайте тип ВС"
    VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN ERROR.
end.
if p-mode = {&update} then do:
   v-rec = recid(locked_ext-system).
end.
/*
IF f-proxy-password:VISIBLE IN FRAME motp-frame THEN DO:
    ASSIGN
    f-proxy-password.
    if f-proxy-password <> '':U
    then do:
      run ref/per-pswd.w ( output psw-buf ) .
      if f-proxy-password <> psw-buf then do:
        message
        "Пароль не подтвержден"
        view-as alert-box ERROR .
        apply "ENTRY":U to f-proxy-password IN frame motp-frame.
        return error.
      end.
   end.
END.
*/
if p-mode = {&add-def} then do:
  do v-ii = 1 to num-entries({&form-esys-attr}):
    find first tt-ext-system-attr where
            tt-ext-system-attr.esya-attr-code = entry(v-ii, {&form-esys-attr}) no-error.
    if not available tt-ext-system-attr then do:
      create tt-ext-system-attr.
      assign
      tt-ext-system-attr.esys-id = 0
      tt-ext-system-attr.db-num = 0
      tt-ext-system-attr.esya-attr-code = entry(v-ii, {&form-esys-attr})
      .
      release tt-ext-system-attr.
    end.
  end.
end.

for each tt-ext-system-attr:
  case tt-ext-system-attr.esya-attr-code:
     when {&attr-esys-host-code} then do:
        assign
        tt-ext-system-attr.esya-attr-value = string(f-host-code).
     end.
     when {&attr-esys-obj} then do:
        assign
        tt-ext-system-attr.esya-attr-value = f-obj .
     end.
/*     when {&attr-esys-user-id} then do:                 */
/*        assign                                          */
/*        tt-ext-system-attr.esya-attr-value =  v-user-id.*/
/*     end.                                               */
     when {&attr-esys-server-addr} then do:
        assign
        tt-ext-system-attr.esya-attr-value = f-server-addres.
     end.
     when {&attr-esys-proxy-addr} then do:
        assign
        tt-ext-system-attr.esya-attr-value = f-proxy-addres.
     end.
     when {&attr-esys-proxy-login} then do:
        assign
        tt-ext-system-attr.esya-attr-value = f-proxy-login.
     end.
     when {&attr-esys-proxy-pswd} then do:
        assign
        tt-ext-system-attr.esya-attr-value = f-proxy-password.
     end.
     when {&attr-esys-proxy-ssl} then do:
        assign
        tt-ext-system-attr.esya-attr-value = string(t-proxy-ssl).
     end.
     when {&attr-esys-mail-list} then do:
        assign
        tt-ext-system-attr.esya-attr-value = trim(e-mail-list).
     end.
  end case.
end.

run bge/extsyss1.p ( input p-mode
                    ,input no /*p-silent*/
                    ,input-output v-rec
                    ,input tt-ext-system.esys-id
                    ,input 0 /*p-db-num*/
                    ,input tt-ext-system.esys-name
                    ,input tt-ext-system.esys-des
                    ,input tt-ext-system.esys-have-export
                    ,input tt-ext-system.esys-db-num-exp
                    ,input tt-ext-system.esys-send-news-exp
                    ,input tt-ext-system.esys-num-days-keep-exp
                    ,INPUT tt-ext-system.esys-max-p-size
                    ,input (IF t-exp-conf-wait
                            THEN integer({&openxml-exp-conf-wait})
                            ELSE integer({&openxml-exp-conf-no-wait}))
                    ,INPUT (IF t-exp-conf-wait
                            THEN tt-ext-system.max-p-queue
                            ELSE 1000)
                    ,INPUT (IF t-exp-conf-wait
                            THEN tt-ext-system.max-p-time
                            ELSE 0)
                    ,input tt-ext-system.esys-have-import
                    ,input tt-ext-system.esys-db-num-imp
                    ,input tt-ext-system.esys-send-news-imp
                    ,input tt-ext-system.esys-num-days-keep-imp
                    ,input (IF t-imp-conf-send
                            THEN integer({&openxml-imp-conf-send})
                            ELSE integer({&openxml-imp-conf-no-send}))
                    ,input tt-ext-system.esys-type
                    ,input tt-ext-system.delivery-method
                    ,INPUT tt-ext-system.delete-pck-on
                    ,INPUT tt-ext-system.save-days-pck-num
                    ,input table tt-ext-system-attr
                                        ) no-error.
if error-status:error then do:
  undo, return error.
end.
else do:
  find first buf_ext-system no-lock where
          recid(buf_ext-system) = v-rec no-error.
  if available buf_ext-system then do:
    assign
    p-esys-id = buf_ext-system.esys-id.
  end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save-diadoc Dialog-Frame 
PROCEDURE proc-save-diadoc :
   define variable v-rec as recid no-undo .
   define variable psw-buf as character no-undo .
   define buffer buf_ext-system for ub.ext-system.
   if p-mode = {&lookup} then return.
   assign
   frame diadoc-frame
   tt-ext-system.esys-name
   tt-ext-system.esys-type
   f-diadoc-user
   f-diadoc-pwd 
   f-diadoc-addres
   f-diadoc-key
   f-diadoc-lastload 
   f-proxy-addres
   f-proxy-login
   f-proxy-password
   f-host-code
   f-obj
   t-diadoc-ssl
   .
   if tt-ext-system.esys-type = 0 then do:
       MESSAGE
       "Задайте тип ВС"
       VIEW-AS ALERT-BOX ERROR.
       UNDO, RETURN ERROR.
   end.
   if p-mode = {&update} then do:
      v-rec = recid(locked_ext-system).
   end.
   /*IF f-proxy-password:VISIBLE IN FRAME diadoc-frame THEN DO:
       ASSIGN
       f-proxy-password.
       if f-proxy-password <> '':U
       then do:
         run ref/per-pswd.w ( output psw-buf ) .
         if f-proxy-password <> psw-buf then do:
           message
           "Пароль не подтвержден"
           view-as alert-box ERROR .
           apply "ENTRY":U to f-proxy-password IN frame diadoc-frame.
           return error.
         end.
      end.
   END.*/
   if p-mode = {&add-def} then do:
     do v-ii = 1 to num-entries({&form-esys-attr}):
       find first tt-ext-system-attr where
               tt-ext-system-attr.esya-attr-code = entry(v-ii, {&form-esys-attr}) no-error.
       if not available tt-ext-system-attr then do:
         create tt-ext-system-attr.
         assign
         tt-ext-system-attr.esys-id = 0
         tt-ext-system-attr.db-num = 0
         tt-ext-system-attr.esya-attr-code = entry(v-ii, {&form-esys-attr})
         .
         release tt-ext-system-attr.
       end.
     end.
   end.

   for each tt-ext-system-attr:
     case tt-ext-system-attr.esya-attr-code:
        when {&attr-esys-obj} then do:
            assign
            tt-ext-system-attr.esya-attr-value = f-obj .
        end.
        when {&attr-esys-host-code} then do:
           assign
              tt-ext-system-attr.esya-attr-value = string(f-host-code).
        end.
        when {&attr-esys-diadoc-user} then do:
           assign
           tt-ext-system-attr.esya-attr-value = f-diadoc-user.
        end.
        when {&attr-esys-server-addr} then do:
           assign
           tt-ext-system-attr.esya-attr-value =  f-diadoc-addres.
        end.
        when {&attr-esys-diadoc-pwd} then do:
           assign
           tt-ext-system-attr.esya-attr-value = f-diadoc-pwd.
        end.
        when {&attr-esys-diadoc-key} then do:
           assign
           tt-ext-system-attr.esya-attr-value = f-diadoc-key.
        end.
        when {&attr-esys-diadoc-lastload} then do:
           assign
           tt-ext-system-attr.esya-attr-value = string(f-diadoc-lastload).
        end.
        when {&attr-esys-diadoc-ssl} then do:
           assign
           tt-ext-system-attr.esya-attr-value = string(t-diadoc-ssl).
        end.
        when {&attr-esys-proxy-addr} then do:
           assign
           tt-ext-system-attr.esya-attr-value = f-proxy-addres.
        end.
        when {&attr-esys-proxy-login} then do:
           assign
           tt-ext-system-attr.esya-attr-value = f-proxy-login.
        end.
        when {&attr-esys-proxy-pswd} then do:
           assign
           tt-ext-system-attr.esya-attr-value = f-proxy-password.
        end.
        
     end case.
   end.


run bge/extsyss1.p ( input p-mode
                    ,input no /*p-silent*/
                    ,input-output v-rec
                    ,input tt-ext-system.esys-id
                    ,input 0 /*p-db-num*/
                    ,input tt-ext-system.esys-name
                    ,input tt-ext-system.esys-des
                    ,input tt-ext-system.esys-have-export
                    ,input tt-ext-system.esys-db-num-exp
                    ,input tt-ext-system.esys-send-news-exp
                    ,input tt-ext-system.esys-num-days-keep-exp
                    ,INPUT tt-ext-system.esys-max-p-size
                    ,input (IF t-exp-conf-wait
                            THEN integer({&openxml-exp-conf-wait})
                            ELSE integer({&openxml-exp-conf-no-wait}))
                    ,INPUT (IF t-exp-conf-wait
                            THEN tt-ext-system.max-p-queue
                            ELSE 1000)
                    ,INPUT (IF t-exp-conf-wait
                            THEN tt-ext-system.max-p-time
                            ELSE 0)
                    ,input tt-ext-system.esys-have-import
                    ,input tt-ext-system.esys-db-num-imp
                    ,input tt-ext-system.esys-send-news-imp
                    ,input tt-ext-system.esys-num-days-keep-imp
                    ,input (IF t-imp-conf-send
                            THEN integer({&openxml-imp-conf-send})
                            ELSE integer({&openxml-imp-conf-no-send}))
                    ,input tt-ext-system.esys-type
                    ,input tt-ext-system.delivery-method
                    ,INPUT tt-ext-system.delete-pck-on
                    ,INPUT tt-ext-system.save-days-pck-num
                    ,input table tt-ext-system-attr
                                        ) no-error.
if error-status:error then do:
  undo, return error.
end.
else do:
  find first buf_ext-system no-lock where
          recid(buf_ext-system) = v-rec no-error.
  if available buf_ext-system then do:
    assign
    p-esys-id = buf_ext-system.esys-id.
  end.
end.

END PROCEDURE.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-value-change-method Dialog-Frame 
PROCEDURE proc-value-change-method :
define input parameter p-delivery-method as integer no-undo.

t-delete-pck-on:label in frame {&frame-name} = "Удал. ф-лы из HEAP" .
      
hide
f-ftp-ip in frame {&frame-name}
f-login
f-ftp-path-in
f-ftp-path-out
f-ftp-path
fi-screen-pass
f-password in frame {&frame-name}.
case p-delivery-method:
   when integer({&esys-dm-nn})
   or
   when integer({&esys-dm-nnold})
   then do:
     display
     f-ftp-ip
     f-ftp-path
     f-login
     f-password
     with frame {&frame-name}.
     if p-mode <> {&lookup} then do:
        enable
        f-ftp-ip
        f-ftp-path
        f-login
        f-password
        with frame {&frame-name}.

     END.
   END.
  when integer({&esys-dm-exite-edi})
  or 
  when integer({&esys-dm-contour-edi})
  then do:
    display
    f-ftp-ip
    f-ftp-path
    f-ftp-path-in
    f-ftp-path-out
    f-login
    f-password
    with frame {&frame-name}.
    if p-mode <> {&lookup} then do:
      enable
      f-ftp-ip
      f-ftp-path
      f-ftp-path-in
      f-ftp-path-out
      f-login
      f-password
      with frame {&frame-name}.
    end.
  end.
  when integer({&esys-dm-egais})
  then do:
    t-delete-pck-on:label in frame {&frame-name} = 'Удал. записи с УТМ'.
  end.
  when integer({&esys-dm-erp-1C-RN})
  then do:
      disable
      T-exp-conf-wait
      T-imp-conf-send
      with frame {&frame-name}.
  end.
  otherwise do:
  end.   
 END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-value-changed-cert-sign Dialog-Frame 
PROCEDURE proc-value-changed-cert-sign PRIVATE :
/*------------------------------------------------------------------------------
 Purpose: включаеи-выключает блок параметров использования цифровой подписи
 Notes:
------------------------------------------------------------------------------*/
define input parameter p-is-sign-checked as logical no-undo .

  if p-is-sign-checked then do :
    display
      fi-cert-sign-subject
      fi-cert-sign-issuer
      cb-cert-file-ext
      cb-cert-repository
    with frame {&frame-name} .
    if p-mode <> {&lookup} then do:
        enable
      fi-cert-sign-subject
      fi-cert-sign-issuer
      cb-cert-file-ext
      cb-cert-repository
        with frame {&frame-name}.
    end .
  end .
  else do :
    hide
      fi-cert-sign-subject in frame {&frame-name}
      fi-cert-sign-issuer  in frame {&frame-name}
      cb-cert-file-ext     in frame {&frame-name}
      cb-cert-repository   in frame {&frame-name}
    .
  end .
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-value-changed-esys-type Dialog-Frame 
PROCEDURE proc-value-changed-esys-type :
DEFINE INPUT PARAMETER p-esys-type AS INTEGER NO-UNDO.
define variable v-dm-method as integer   no-undo .
if p-esys-type = integer({&openxml-type-is_motp})
then do :
  hide frame Dialog-Frame .
  hide frame diadoc-frame .
  run Motp-Enable .
end .
else if p-esys-type = {&bef-openxml-type-is_diadoc}
then do :
  hide frame Dialog-Frame .
  hide frame motp-frame .
  run diadoc-Enable .
end .
else do :
  hide frame motp-frame .
  hide frame diadoc-frame .
  run myenable .
  case p-esys-type:
     when integer({&openxml-type-oracle-retail}) then do:
       v-dm-method = integer({&esys-dm-oracle-retail}).
    end.
    when integer({&openxml-type-edoc-nn}) then do:
       v-dm-method = integer({&esys-dm-nn}).
    end.
    when integer({&openxml-type-com-dashboard})
    or
    when integer({&openxml-type-dklink}) then do:
      v-dm-method = integer({&esys-dm-cdash}).
    end.
    when integer({&openxml-type-exite-edi}) then do:
      v-dm-method = integer({&esys-dm-exite-edi}).
    end.
    otherwise do:
      v-dm-method = integer({&esys-dm-ordinal}).
    end.
  end case.
  assign
  tt-ext-system.delivery-method = v-dm-method.
  display
  tt-ext-system.delivery-method
  with frame {&frame-name} .
  run proc-value-change-method in this-procedure ( input  v-dm-method).
end .  

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

