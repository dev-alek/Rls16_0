&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI 
&ANALYZE-RESUME 
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision: 4ff7b201ba9b, 3436, rls $
$Author: VSpiridonov $
$Date: 2023/10/16 15:13:32 $
$Workfile: users.w $
$Archive: str/users.w $

Список пользователей системы

Автор: Белоусов Илья Александрович
Дата создания: 07/16/07
Author: Ilia Belousov
Creation date: 07/16/07

Input:

Output:

*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

define temp-table temp_filter-fields no-undo
    field user-id               as character
    field fld-record-visible    as logical
    field flt-record-visible    as logical
    field flt-record-order      as int64

    index pi is primary unique
        user-id
.

define temp-table temp_user-login-obj no-undo
    field db-num    as integer
    field user-id   as character
    field obj-type  as character
    field obj-code  as integer
    field host-code as integer
    field obj-name  as character

    index pi is primary unique
        db-num
        user-id
        obj-type
        obj-code
.

/* Parameters Definitions ---                                           */
define input parameter parparentproc  as widget-handle no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision: 4ff7b201ba9b, 3436, rls $":U .
define variable vss-author      as character no-undo init "$Author: VSpiridonov $":U .
define variable vss-date        as character no-undo init "$Date: 2023/10/16 15:13:32 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: users.w $":U .
define variable vss-archive     as character no-undo init "$Archive: str/users.w $":U .
define variable vss-description as character no-undo init "Список пользователей системы".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/color.i    }
{ gbl/getcntxt.i def }
{ gbl/sys-time.i }
{ cmp/showinf.i  }
{ gbl/usr-flt.i  }
{ gbl/prn-lib.i }
{ cmp/trg-def.i }
{ adm/userpro.i &CheckWorkUser = yes}
&scoped-define current-position-rowid  "users-rowid":U
&scoped-define current-position-focus  "users-focus":U
&scoped-define current-position-db     "users-db":U
&scoped-define current-position-status "users-status":U

define variable v-users-name-filter     as character    no-undo.
define variable v-users-login-filter    as character    no-undo.
define variable v-filter-yes            as logical      no-undo.
define variable v-user-login            as logical      no-undo.
define variable v-users-user-login      as logical      no-undo.
define variable v-users-work-status     as character    no-undo.
define variable v-users-last-cb-db      as integer      no-undo.
define variable v-ok                    as logical      no-undo.
define variable v-users-set-rowid       as logical      no-undo.
define variable v-users-current-rowid   as rowid        no-undo.
define variable v-users-current-focus   as integer      no-undo.
define variable v-only-lookup           as logical      no-undo.
define variable v-rowid-login           as rowid        no-undo. 
define variable mSuperAdm               as logical no-undo.
define buffer buf_init_user-account      for user-account.
define buffer buf_init_user-login        for user-login.

define stream out-stream.
define stream OutStr-html.

define variable p-report-id               as integer              no-undo .
define variable v-report-name-html        as CHARACTER            no-undo .
define variable v-report-name-html-list   as CHARACTER            no-undo .

  define temp-table tt-user-login no-undo
    field users-id   like ub.user-login.user-id
    field nik        like ub.user-account.nik
    field db-num     like ub.user-login.db-num
    field user-login like ub.user-login.user-login
    field last-login-mjd like ub.user-login.last-login-mjd
    field last-name  as character

  .

define buffer buf_global-state      for ub.global-state .
define buffer buf_global-state-attr for ub.global-state-attr .
define variable v-action-gbl    as logical      no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-login

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_init_user-login buf_init_user-account ~
temp_filter-fields

/* Definitions for BROWSE br-login                                      */
&Scoped-define FIELDS-IN-QUERY-br-login buf_init_user-login.db-num buf_init_user-login.user-login buf_init_user-login.max-discnt   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-login   
&Scoped-define SELF-NAME br-login
&Scoped-define OPEN-QUERY-br-login /* OPEN QUERY {&SELF-NAME} FOR EACH buf_init_user-login NO-LOCK INDEXED-REPOSITION. */ run open-query-login in this-procedure.
&Scoped-define TABLES-IN-QUERY-br-login buf_init_user-login
&Scoped-define FIRST-TABLE-IN-QUERY-br-login buf_init_user-login


/* Definitions for BROWSE br-user                                       */
&Scoped-define FIELDS-IN-QUERY-br-user buf_init_user-account.nik buf_init_user-account.last-name buf_init_user-account.first-name get-user-login( buf_init_user-account.user-id ) @ v-users-user-login buf_init_user-account.user-id /* get-work-status(buf_init_user-account.user-id) @ v-users-work-status */ get-person-name( buf_init_user-account.psn-code )   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-user   
&Scoped-define SELF-NAME br-user
&Scoped-define OPEN-QUERY-br-user /* OPEN QUERY {&SELF-NAME} FOR EACH buf_init_user-account NO-LOCK, ~
       first temp_filter-fields INDEXED-REPOSITION. */ run open-query in this-procedure ( input this-procedure ).
&Scoped-define TABLES-IN-QUERY-br-user buf_init_user-account ~
temp_filter-fields
&Scoped-define FIRST-TABLE-IN-QUERY-br-user buf_init_user-account
&Scoped-define SECOND-TABLE-IN-QUERY-br-user temp_filter-fields


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-login}~
    ~{&OPEN-QUERY-br-user}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit cb-db b-filter fi-filter-comment ~
tb-filter b-hist b-print b-help rs-scope b-add b-chg b-dup b-del b-userhist ~
b-hist-user b-add-2 b-chg-2 b-del-2 bt-password br-user br-login bt-object ~
bt-firm bt-role bt-menu ed-login-object ed-user-info 
&Scoped-Define DISPLAYED-OBJECTS cb-db fi-filter-comment tb-filter rs-scope ~
ed-login-object ed-user-info 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-person-name Dialog-Frame 
FUNCTION get-person-name RETURNS CHARACTER
  ( p-psn-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU POPUP-MENU-b-print 
       MENU-ITEM m_b-print-prava LABEL "Список прав пользователей"
       MENU-ITEM m_b-print-user LABEL "Пользователь"  
       MENU-ITEM m_b-print-list LABEL "Список пользователей"
       MENU-ITEM last-pwd LABEL "Отчет о смене паролей "
       MENU-ITEM adm-bd LABEL "Пользователи с правами администраторов БД"
.


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add 
     LABEL "&Добавить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-add-2 
     LABEL "&Добавить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-chg 
     LABEL "&Изменить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-chg-2 
     LABEL "&Изменить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-copy 
     LABEL "&Копировать" 
     SIZE 10.5 BY 1.

DEFINE BUTTON b-del 
     LABEL "&Удалить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-del-2 
     LABEL "&Удалить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-dup 
     LABEL "&Копия" 
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO 
     LABEL "В&ыход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-filter 
     LABEL "Ф&Поиск" 
     SIZE 10 BY 1 TOOLTIP "Поиск с фильтрацией по фамилии, имени пользователя, псевдониму и логину".

DEFINE BUTTON b-help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-hist 
     LABEL "Ис&тория" 
     SIZE 3 BY 1.

DEFINE BUTTON b-hist-user 
     LABEL "Ис&тория" 
     SIZE 3 BY 1.

DEFINE BUTTON b-print 
     LABEL "Печать" 
     SIZE 3 BY 1.

DEFINE BUTTON b-userhist 
     LABEL "&История" 
     SIZE 10 BY 1.

DEFINE BUTTON bt-firm 
     LABEL "Фирмы" 
     SIZE 10 BY 1.

DEFINE BUTTON bt-menu 
     LABEL "Меню" 
     SIZE 10 BY 1.

DEFINE BUTTON bt-object 
     LABEL "Объекты" 
     SIZE 10 BY 1.

DEFINE BUTTON bt-password 
     LABEL "&Пароль" 
     SIZE 10 BY 1.

DEFINE BUTTON bt-role 
     LABEL "Права" 
     SIZE 10 BY 1.

DEFINE VARIABLE cb-db AS INTEGER FORMAT "->>>>9":U INITIAL -1 
     LABEL "БД" 
     VIEW-AS COMBO-BOX INNER-LINES 15
     LIST-ITEM-PAIRS "0",1
     DROP-DOWN-LIST
     SIZE 20 BY 1 TOOLTIP "База данных, в которой у пользователя есть логин" NO-UNDO.

DEFINE VARIABLE ed-login-object AS CHARACTER 
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-VERTICAL
     SIZE 50 BY 12.25
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE ed-user-info AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 56.5 BY 3.5
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-filter-comment AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 24.5 BY 1 NO-UNDO.

DEFINE VARIABLE rs-scope AS INTEGER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Тек", 1,
"Все", 2,
"Удал", 3
     SIZE 18 BY .75
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE tb-filter AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2.63 BY .79 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-login FOR 
      buf_init_user-login SCROLLING.

DEFINE QUERY br-user FOR 
      buf_init_user-account, 
      temp_filter-fields SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-login
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-login Dialog-Frame _FREEFORM
  QUERY br-login NO-LOCK DISPLAY
      buf_init_user-login.db-num FORMAT ">>>>9":U column-label " БД"
      buf_init_user-login.user-login COLUMN-LABEL " Логин" FORMAT "X(12)":U
            WIDTH 19.5
      buf_init_user-login.max-discnt FORMAT ">>9.99":U WIDTH 20.75 column-label "Макс.скидка"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 50 BY 6.75 FIT-LAST-COLUMN.

DEFINE BROWSE br-user
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-user Dialog-Frame _FREEFORM
  QUERY br-user NO-LOCK DISPLAY
      buf_init_user-account.nik COLUMN-LABEL " Псевдоним"  FORMAT "X(10)":U
      buf_init_user-account.last-name COLUMN-LABEL " Фамилия"  FORMAT "X(24)":U
      buf_init_user-account.first-name COLUMN-LABEL " Имя" FORMAT "X(12)":U
      get-user-login( buf_init_user-account.user-id ) @ v-users-user-login COLUMN-LABEL " БД" FORMAT "X(9)":U
      buf_init_user-account.user-id COLUMN-LABEL " ID"  FORMAT "X(8)":U
/*      get-work-status(buf_init_user-account.user-id)  @ v-users-work-status COLUMN-LABEL " В работе" FORMAT "X(1)":U */
      get-person-name( buf_init_user-account.psn-code ) COLUMN-LABEL " Физ. лицо"  FORMAT "X(40)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 56.5 BY 16.75 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1.5
     cb-db AT ROW 1 COL 13.88 COLON-ALIGNED WIDGET-ID 40
     b-filter AT ROW 1 COL 54.63 WIDGET-ID 26
     fi-filter-comment AT ROW 1 COL 63.13 COLON-ALIGNED NO-LABEL WIDGET-ID 20 NO-TAB-STOP 
     tb-filter AT ROW 1 COL 96.38 WIDGET-ID 60
     b-hist AT ROW 1 COL 98.88 WIDGET-ID 64
     b-print AT ROW 1 COL 101.75 WIDGET-ID 62
     b-help AT ROW 1 COL 104.75
     rs-scope AT ROW 1.25 COL 36.5 NO-LABEL WIDGET-ID 42
     b-add AT ROW 2.25 COL 1.5 WIDGET-ID 2
     b-chg AT ROW 2.25 COL 11.5 WIDGET-ID 4
     b-dup AT ROW 2.25 COL 21.5 WIDGET-ID 58
     b-del AT ROW 2.25 COL 31.5 WIDGET-ID 6
     b-userhist AT ROW 2.25 COL 41.5 WIDGET-ID 62
     b-hist-user AT ROW 2.25 COL 51.5 WIDGET-ID 64
     b-add-2 AT ROW 2.25 COL 58.5 WIDGET-ID 28
     b-copy AT ROW 2.25 COL 68.38 WIDGET-ID 66
     b-chg-2 AT ROW 2.25 COL 78.75 WIDGET-ID 30
     b-del-2 AT ROW 2.25 COL 88.63 WIDGET-ID 32
     bt-password AT ROW 2.25 COL 98.5 WIDGET-ID 56
     br-user AT ROW 3.25 COL 1.5 WIDGET-ID 200
     br-login AT ROW 3.25 COL 58.5 WIDGET-ID 300
     bt-object AT ROW 10 COL 58.5 WIDGET-ID 48
     bt-firm AT ROW 10 COL 68.5 WIDGET-ID 52
     bt-role AT ROW 10 COL 78.5 WIDGET-ID 50
     bt-menu AT ROW 10 COL 88.5 WIDGET-ID 54
     ed-login-object AT ROW 11.25 COL 58.5 NO-LABEL WIDGET-ID 36
     ed-user-info AT ROW 20 COL 1.5 NO-LABEL WIDGET-ID 34
     SPACE(50.99) SKIP(0.12)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Пользователи"
         DEFAULT-BUTTON b-exit WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-user bt-password Dialog-Frame */
/* BROWSE-TAB br-login br-user Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON b-copy IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       b-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU POPUP-MENU-b-print:HANDLE.
ASSIGN b-print :MENU-MOUSE = 1.
ASSIGN 
       ed-login-object:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN 
       ed-user-info:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN 
       fi-filter-comment:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-login
/* Query rebuild information for BROWSE br-login
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH buf_init_user-login NO-LOCK INDEXED-REPOSITION. */
run open-query-login in this-procedure.
     _END_FREEFORM
     _Options          = "INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-login */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-user
/* Query rebuild information for BROWSE br-user
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH buf_init_user-account NO-LOCK, first temp_filter-fields INDEXED-REPOSITION. */
run open-query in this-procedure ( input this-procedure ).
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-user */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Пользователи */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
    define variable v-user-id                   as character    no-undo.
    define variable v-last-name                 as character    no-undo.
    define variable v-first-name                as character    no-undo.
    define variable v-second-name               as character    no-undo.
    define variable v-nik                       as character    no-undo.
    define variable v-phone-number              as character    no-undo.
    define variable v-mobile-phone-number       as character    no-undo.
    define variable v-company                   as character    no-undo.
    define variable v-department                as character    no-undo.
    define variable v-position                  as character    no-undo.
    define variable v-room                      as character    no-undo.
    define variable v-e-mail                    as character    no-undo.
    define variable v-internal-phone-number     as character    no-undo.
    define variable v-PS                        as character    no-undo.
    define variable v-accepted                  as logical      no-undo.
    define variable v-created                   as logical      no-undo.
    define variable v-psn-code                  as integer      no-undo.
    define variable v-adm-Ubd                   as logical      no-undo.
    define variable v-adm-gbd                   as logical      no-undo.
    define variable v-superAdm                  as logical      no-undo.
    define variable v-TabUserAdm                as handle       no-undo.

    define buffer buf_user-account      for user-account.
    define buffer buf_user-login        for user-login.
    run getAccountSetting (input  ?,
                              output v-adm-Ubd,
                              output v-adm-gbd,
                              output v-superAdm,
                              input-output table-handle v-TabUserAdm).
         
    run str/user.w (
          input parparentproc
        , input this-procedure
        , input {&add-def}
        , input "< Новый >"
        , input "":U
        , input "":U
        , input "":U
        , input "":U
        , input "":U
        , input "":U
        , input "":U
        , input "":U
        , input "":U
        , input "":U
        , input "":U
        , input "":U
        , input "":U
        , input ?
        , input ? 
        , input no
        , input ?
        , input-output table-handle v-TabUserAdm
        , output v-last-name
        , output v-first-name
        , output v-second-name
        , output v-nik
        , output v-phone-number
        , output v-mobile-phone-number
        , output v-company
        , output v-department
        , output v-position
        , output v-room
        , output v-e-mail
        , output v-internal-phone-number
        , output v-PS
        , output v-psn-code
        , output v-adm-gbd
        , output v-superAdm    
        , output v-adm-Ubd 
        , output v-accepted
    ) no-error.
    if error-status :error
    then do:
        message
                    vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка редактирования пользователя."
            skip return-value
            skip trim( error-status :get-message( 1 ) )
                    trim( error-status :get-message( 2 ) )
                    trim( error-status :get-message( 3 ) )
        view-as alert-box error.
        undo, return no-apply.
    end.
    if v-accepted = yes
    then do:
        run str/usracc01.p (
              input {&add-def}
            , input v-cntxt-db-num
            , input "":U
            , input v-last-name
            , input v-first-name
            , input v-second-name
            , input v-nik
            , input v-phone-number
            , input v-mobile-phone-number
            , input v-company
            , input v-department
            , input v-position
            , input v-room
            , input v-e-mail
            , input v-internal-phone-number
            , input v-PS
            , input v-psn-code
            , input v-superAdm
            , output v-user-id
        ) no-error.
        if error-status :error
        then do:
            message
                        vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка изменения данных пользователя."
                skip return-value
                skip trim( error-status :get-message( 1 ) )
                        trim( error-status :get-message( 2 ) )
                        trim( error-status :get-message( 3 ) )
            view-as alert-box error.
            undo, return no-apply.
        end.
        define variable v-yesno    as logical      no-undo.
        if mSuperadm
        then
           v-yesno = yes.
        else do:
           message
                    "Создать логин для нового пользователя?"
   /*            skip "в текущей базе данных?"*/
           view-as alert-box question
           buttons yes-no
           title "Создание логина"
           update v-yesno .
        end.
        if v-yesno = yes
        then do:
            run procedure-user-login-create in this-procedure (
                  input "{&add-def}" /*  {&add-def} 11  */
                , input if mSuperadm then ? else v-cntxt-db-num
                , input v-user-id
                , input v-adm-gbd
                , input v-adm-Ubd
                , input v-TabUserAdm 
                , output v-created
            ) no-error.
            if error-status :error
            then do:
                message
                        vss-workfile vss-revision vss-description
                    skip(1)
                    skip "Ошибка создания логина пользователя."
                    skip return-value
                    skip trim( error-status :get-message( 1 ) )
                        trim( error-status :get-message( 2 ) )
                        trim( error-status :get-message( 3 ) )
                view-as alert-box error.
                undo, return no-apply.
            end.
/*            if v-created = yes*/
/*            then do:*/
/*                {&OPEN-QUERY-br-login}*/
/*                run manage-fields-login in this-procedure .*/
/*            end.*/
        end.
        else do:
            if v-cntxt-db-num = 0
            then do:
                assign
                    cb-db = -1
                .
                display
                    cb-db
                with frame {&frame-name}.
            end.
        end.
        run assign-field-filter-mark in this-procedure (
              input v-users-name-filter
            , input v-users-login-filter
        ).
        {&OPEN-QUERY-br-user}
        find first buf_user-account no-lock
             where buf_user-account.user-id = v-user-id
        .
/*        reposition br-user to rowid rowid( buf_user-account ) no-error.*/
        run manage-fields in this-procedure.
        if v-created = yes
        then do:
            find first buf_user-login no-lock
                 where buf_user-login.user-id  = v-user-id
/*                   and buf_user-login.db-num   = v-cntxt-db-num*/
            no-error.
            if available buf_user-login
            then
               reposition br-login to rowid rowid( buf_user-login ) no-error.
        end.
        apply "entry":U to br-user.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add-2 Dialog-Frame
ON CHOOSE OF b-add-2 IN FRAME Dialog-Frame /* Добавить */
DO:
    define variable v-created               as logical      no-undo.

    if available buf_init_user-account
    then do:
        run procedure-user-login-create in this-procedure (
              input "add"
            , input v-cntxt-db-num
            , input buf_init_user-account.user-id
            , input ?
            , input ?
            , input ?
            , output v-created
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка создания логина пользователя."
                skip return-value
                skip trim( error-status :get-message( 1 ) )
                     trim( error-status :get-message( 2 ) )
                     trim( error-status :get-message( 3 ) )
            view-as alert-box error.
            undo, return no-apply.
        end.
        if v-created = yes
        then do:
            {&OPEN-QUERY-br-login}
            run manage-fields-login in this-procedure .
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
    define variable v-user-id                   as character    no-undo.
    define variable v-last-name                 as character    no-undo.
    define variable v-first-name                as character    no-undo.
    define variable v-second-name               as character    no-undo.
    define variable v-nik                       as character    no-undo.
    define variable v-phone-number              as character    no-undo.
    define variable v-mobile-phone-number       as character    no-undo.
    define variable v-company                   as character    no-undo.
    define variable v-department                as character    no-undo.
    define variable v-position                  as character    no-undo.
    define variable v-room                      as character    no-undo.
    define variable v-e-mail                    as character    no-undo.
    define variable v-internal-phone-number     as character    no-undo.
    define variable v-PS                        as character    no-undo.
    define variable v-adm-Ubd                   as logical      no-undo init ?.
/*    define variable v-adm-Ubd-int               as integer      no-undo.*/
    define variable v-adm-gbd                   as logical      no-undo init ?.
    define variable v-superAdm                  as logical      no-undo.
    define variable v-TabUserAdm                as handle       no-undo.
    define variable v-accepted                  as logical      no-undo.
    define variable v-psn-code                  as integer    no-undo.
    
    define buffer buf_user-account-attr for ub.user-account-attr .

    if available buf_init_user-account
    then do:
       run getAccountSetting (input  buf_init_user-account.user-id,
                              output v-adm-Ubd,
                              output v-adm-gbd,
                              output v-superAdm,
                              input-output table-handle v-TabUserAdm).

       run str/user.w (
              input parparentproc
            , input this-procedure
            , input {&update}
            , input buf_init_user-account.user-id
            , input buf_init_user-account.last-name
            , input buf_init_user-account.first-name
            , input buf_init_user-account.second-name
            , input buf_init_user-account.nik
            , input buf_init_user-account.phone-number
            , input buf_init_user-account.mobile-phone-number
            , input buf_init_user-account.company
            , input buf_init_user-account.department
            , input buf_init_user-account.position
            , input buf_init_user-account.room
            , input buf_init_user-account.e-mail
            , input buf_init_user-account.internal-phone-number
            , input buf_init_user-account.PS
            , INPUT buf_init_user-account.psn-code
            , input v-adm-gbd
            , input v-superAdm 
            , input v-adm-Ubd
            , input-output table-handle v-TabUserAdm
            , output v-last-name
            , output v-first-name
            , output v-second-name
            , output v-nik
            , output v-phone-number
            , output v-mobile-phone-number
            , output v-company
            , output v-department
            , output v-position
            , output v-room
            , output v-e-mail
            , output v-internal-phone-number
            , output v-PS
            , output v-psn-code
            , output v-adm-gbd
            , output v-superAdm    
            , output v-adm-Ubd 
            , output v-accepted
        ) no-error.
        if error-status :error
        then do:
            message
                        vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка редактирования пользователя."
                skip return-value
                skip trim( error-status :get-message( 1 ) )
                        trim( error-status :get-message( 2 ) )
                        trim( error-status :get-message( 3 ) )
            view-as alert-box error.
            undo, return no-apply.
        end.
        if v-accepted = yes
        then do:
            run str/usracc01.p (
                  input {&update}
                , input v-cntxt-db-num
                , input buf_init_user-account.user-id
                , input v-last-name
                , input v-first-name
                , input v-second-name
                , input v-nik
                , input v-phone-number
                , input v-mobile-phone-number
                , input v-company
                , input v-department
                , input v-position
                , input v-room
                , input v-e-mail
                , input v-internal-phone-number
                , input v-PS
                , input v-psn-code
                , input v-superAdm
                , output v-user-id
            ) no-error.
            if error-status :error
            then do:
                message
                         vss-workfile vss-revision vss-description
                    skip(1)
                    skip "Ошибка изменения данных пользователя."
                    skip return-value
                    skip trim( error-status :get-message( 1 ) )
                         trim( error-status :get-message( 2 ) )
                         trim( error-status :get-message( 3 ) )
                view-as alert-box error.
                undo, return no-apply.
            end.
            define variable v-created as logical no-undo.
            run procedure-user-login-create in this-procedure (
                  input {&update}
                , input v-cntxt-db-num
                , input buf_init_user-account.user-id
                , input v-adm-gbd
                , input v-adm-Ubd
                , input v-TabUserAdm 
                , output v-created
            ) no-error.
            if error-status :error
            then do:
                message
                        vss-workfile vss-revision vss-description
                    skip(1)
                    skip "Ошибка создания логина пользователя."
                    skip return-value
                    skip trim( error-status :get-message( 1 ) )
                        trim( error-status :get-message( 2 ) )
                        trim( error-status :get-message( 3 ) )
                view-as alert-box error.
                undo, return no-apply.
            end.
            run assign-field-filter-mark in this-procedure (
                  input v-users-name-filter
                , input v-users-login-filter
            ).
            run manage-fields in this-procedure .
            br-user :refresh().
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg-2 Dialog-Frame
ON CHOOSE OF b-chg-2 IN FRAME Dialog-Frame /* Изменить */
DO:
    if available buf_init_user-login
    then do:
        run procedure-user-login-edit in this-procedure (
              input buf_init_user-login.db-num
            , input buf_init_user-login.user-id
        ) no-error .
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры редактирования логина пользователя" skip
                error-status :get-message(1) skip
                return-value skip
            view-as alert-box error .
            undo, return no-apply .
        end.
        br-login :refresh().
        run manage-fields-login in this-procedure .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-copy Dialog-Frame
ON CHOOSE OF b-copy IN FRAME Dialog-Frame /* Копировать */
DO:
    if available buf_init_user-login
    then do:
        run procedure-user-login-copy in this-procedure (
              input buf_init_user-login.db-num
            , input buf_init_user-login.user-id
        ) no-error .
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры копирования логина пользователя" skip
                error-status :get-message(1) skip
                return-value skip
            view-as alert-box error .
            undo, return no-apply .
        end.
        br-login :refresh().
        run manage-fields-login in this-procedure .
    end.
    {&OPEN-QUERY-br-login}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
    if available buf_init_user-account
    then do:
        if buf_init_user-account.user-id = v-cntxt-userid
        then do:
            message
                     "Невозможно удалить текущего пользователя"
                skip "Идентификатор пользователя" buf_init_user-account.user-id
                view-as alert-box error .
            undo, return no-apply.
        end.
        if  buf_init_user-account.status_ eq {&bef-user-status-normal}
        then do: 
   
           define variable v-ok as logical   no-undo .
           message
                    "После удаления пользователь"
               skip "не сможет работать в системе"
               skip (1)
               skip "Псевдоним:" buf_init_user-account.nik skip
               skip "Имя:      " buf_init_user-account.last-name buf_init_user-account.first-name buf_init_user-account.second-name
               skip (1)
               skip "Удалить пользователя?"
           view-as alert-box question
           buttons yes-no
           title substitute( "Удаление пользователя '&1'", buf_init_user-account.nik )
           update v-ok.
           if v-ok = yes
           then do:
               run str/usracc03.p (
                     input buf_init_user-account.user-id
                   , input v-cntxt-db-num
               ) no-error .
               if error-status :error
               then do:
                   message
                           vss-workfile vss-revision vss-description
                       skip(1)
                       skip "Ошибка удаления пользователя."
                       skip return-value
                       skip trim( error-status :get-message( 1 ) )
                           trim( error-status :get-message( 2 ) )
                           trim( error-status :get-message( 3 ) )
                   view-as alert-box error.
                   undo, return no-apply.
               end.
               {&OPEN-QUERY-br-user}
               run manage-fields in this-procedure .
           end.
        end.
        else do:
           run str/usracc02.p (
                     input buf_init_user-account.user-id
            ) no-error .
            if error-status :error
            then do:
                message
                        vss-workfile vss-revision vss-description
                    skip(1)
                    skip "Ошибка удаления пользователя."
                    skip return-value
                    skip trim( error-status :get-message( 1 ) )
                        trim( error-status :get-message( 2 ) )
                        trim( error-status :get-message( 3 ) )
                view-as alert-box error.
                undo, return no-apply.
            end.
            {&OPEN-QUERY-br-user}
            run manage-fields in this-procedure .
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del-2 Dialog-Frame
ON CHOOSE OF b-del-2 IN FRAME Dialog-Frame /* Удалить */
DO:
    define variable v-deleted    as logical      no-undo.

    if available buf_init_user-login
    then do:
        if  buf_init_user-login.status_ eq {&bef-user-status-normal}
        then do:
        run procedure-user-login-delete in this-procedure (
              input buf_init_user-login.db-num
            , input buf_init_user-login.user-id
            , output v-deleted
        ) no-error .
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description
                skip "Ошибка при вызове процедуры удаления логина пользователя"
                skip error-status :get-message(1)
                skip return-value
            view-as alert-box error .
            undo, return no-apply .
        end.
        end.
        else do transaction
           on error undo, return:
           define buffer buf_user-login for ub.user-login .

           find first buf_user-login exclusive-lock
                where buf_user-login.db-num  = buf_init_user-login.db-num
                  and buf_user-login.user-id = buf_init_user-login.user-id
           no-error .

           buf_user-login.status_ = {&bef-user-status-normal}.
           v-deleted = yes.
        end.
        if v-deleted = yes
        then do:
            {&OPEN-QUERY-br-login}
            run manage-fields-login in this-procedure .
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-dup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-dup Dialog-Frame
ON CHOOSE OF b-dup IN FRAME Dialog-Frame /* Копия */
DO:
    define variable v-ok        as logical   no-undo .
    define variable v-rowid     as rowid        no-undo.
    define variable v-success   as logical      no-undo.

    if available buf_init_user-account
    then do:
        run duplicate-user in this-procedure (
              input buf_init_user-account.user-id
            , input v-cntxt-db-num
            , output v-rowid
            , output v-success
        ) no-error.
        if error-status :error
        then do:
            message
                        vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка копирования пользователя."
                skip return-value
                skip trim( error-status :get-message( 1 ) )
                        trim( error-status :get-message( 2 ) )
                        trim( error-status :get-message( 3 ) )
            view-as alert-box error.
            undo, return no-apply.
        end.
        if v-success = yes
        then do:
            run assign-field-filter-mark in this-procedure (
                  input v-users-name-filter
                , input v-users-login-filter
            ).
            {&OPEN-QUERY-br-user}
/*            reposition br-user to rowid v-rowid no-error.*/
            run manage-fields in this-procedure .
            apply "entry":U to br-user.
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
DO:
{ gbl/stdbtn.i }

run save-position in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-filter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-filter Dialog-Frame
ON CHOOSE OF b-filter IN FRAME Dialog-Frame /* ФПоиск */
DO:

    define variable v-accepted      as logical      no-undo.

    run str/usersf.w (
          input parparentproc
        , input v-users-name-filter
        , input v-users-login-filter
        , output v-users-name-filter
        , output v-users-login-filter
        , output fi-filter-comment
        , output v-accepted
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка изменения фильтра."
            skip return-value
            skip trim( error-status :get-message( 1 ) )
                 trim( error-status :get-message( 2 ) )
                 trim( error-status :get-message( 3 ) )
        view-as alert-box error.
        undo, return no-apply.
    end.
    
    if v-accepted = yes
    
    then do:
        if fi-filter-comment = "":U
        then do:
            assign
                tb-filter = no
            .
            disable
                tb-filter
            with frame {&frame-name} .
        end.
        else do:
            if available buf_init_user-account
            then do:
                assign
                    v-users-current-rowid = rowid( buf_init_user-account )
                    v-users-current-focus = br-user :focused-row in frame {&FRAME-NAME}
                .
            end.
            assign
                tb-filter = yes
            .
            run assign-filter-mark in this-procedure (
                  input v-users-name-filter
                , input v-users-login-filter
            ).
            enable
                tb-filter
            with frame {&frame-name} .
        end.
        display
            fi-filter-comment
            tb-filter
        with frame {&frame-name}.
        {&OPEN-QUERY-br-user}
        run manage-fields in this-procedure .
        {&OPEN-QUERY-br-login}
        run manage-fields-login in this-procedure .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist Dialog-Frame
ON CHOOSE OF b-hist IN FRAME Dialog-Frame /* История */
DO:
  if available buf_init_user-account
    then do:
run str\usrlg.w (
                input parparentproc,
                input buf_init_user-account.user-id) no-error.
    end.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist-user
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist-user Dialog-Frame
ON CHOOSE OF b-hist-user IN FRAME Dialog-Frame /* История */
DO:
  if available buf_init_user-account
    then do:
run str\cusrhist.w (
                input parparentproc,
                input buf_init_user-account.user-id) no-error.
    end.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:
      run gbl/pop-up.p (self:handle, no) no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON MOUSE-SELECT-CLICK OF b-print IN FRAME Dialog-Frame /* Печать */
DO:
   APPLY "CHOOSE" TO b-print IN FRAME {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-userhist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-userhist Dialog-Frame
ON CHOOSE OF b-userhist IN FRAME Dialog-Frame /* История */
DO:
    if available buf_init_user-account
    then do:
        run str/usrlg.w (
              input parparentproc
            , input buf_init_user-account.user-id
        ) no-error.
        if error-status :error
        then do:
            message
                        vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка просмотра истории действий пользователя."
                skip return-value
                skip trim( error-status :get-message( 1 ) )
                        trim( error-status :get-message( 2 ) )
                        trim( error-status :get-message( 3 ) )
            view-as alert-box error.
            undo, return no-apply.
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-login
&Scoped-define SELF-NAME br-login
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-login Dialog-Frame
ON VALUE-CHANGED OF br-login IN FRAME Dialog-Frame
DO:
    RUN manage-fields-login IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-user
&Scoped-define SELF-NAME br-user
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-user Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF br-user IN FRAME Dialog-Frame
DO:
    define variable v-void-char     as character    no-undo.
    define variable v-void-int      as integer    no-undo.
    define variable v-void-log      as logical      no-undo.
    define variable v-adm-Ubd                   as integer      no-undo.
    define variable v-adm-gbd                   as logical      no-undo.
    define variable v-superAdm                  as logical      no-undo.
    define variable v-TabUserAdm                as handle       no-undo.
    
    
    define buffer buf_user-account-attr for ub.user-account-attr .
    
    if available buf_init_user-account
    then do:
        run getAccountSetting (input  buf_init_user-account.user-id,
                              output v-adm-Ubd,
                              output v-adm-gbd,
                              output v-superAdm,
                              input-output table-handle v-TabUserAdm).
         
        run str/user.w (
              input parparentproc
            , input this-procedure
            , input {&lookup}
            , input buf_init_user-account.user-id
            , input buf_init_user-account.last-name
            , input buf_init_user-account.first-name
            , input buf_init_user-account.second-name
            , input buf_init_user-account.nik
            , input buf_init_user-account.phone-number
            , input buf_init_user-account.mobile-phone-number
            , input buf_init_user-account.company
            , input buf_init_user-account.department
            , input buf_init_user-account.position
            , input buf_init_user-account.room
            , input buf_init_user-account.e-mail
            , input buf_init_user-account.internal-phone-number
            , input buf_init_user-account.PS
            , input buf_init_user-account.psn-code
            , input v-adm-gbd
            , input v-superAdm 
            , input v-adm-Ubd
            , input-output table-handle v-TabUserAdm
            , output v-void-char
            , output v-void-char
            , output v-void-char
            , output v-void-char
            , output v-void-char
            , output v-void-char
            , output v-void-char
            , output v-void-char
            , output v-void-char
            , output v-void-char
            , output v-void-char
            , output v-void-char
            , output v-void-char
            , output v-void-int
            , output v-void-log
            , output v-void-log
            , output v-void-log
            , output v-void-log
        ).
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-login Dialog-Frame
ON ROW-DISPLAY OF br-login IN FRAME Dialog-Frame
DO:
   if avail buf_init_user-login  then do:
     if
    buf_init_user-login.status_ ne {&bef-user-status-normal}
   then assign
      buf_init_user-login.db-num     :fgcolor in browse br-login = gray_color
      buf_init_user-login.user-login :fgcolor in browse br-login = gray_color
      buf_init_user-login.max-discnt :fgcolor in browse br-login = gray_color
   .
   else assign
      buf_init_user-login.db-num     :fgcolor in browse br-login = black_color
      buf_init_user-login.user-login :fgcolor in browse br-login = black_color
      buf_init_user-login.max-discnt :fgcolor in browse br-login = black_color
   .
end.
end.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-user Dialog-Frame
ON ROW-DISPLAY OF br-user IN FRAME Dialog-Frame
DO:
    define variable v-work-status as character no-undo .

    if available buf_init_user-account
    then do:
        if buf_init_user-account.status_ = {&bef-user-status-deleted}
        then do:
            assign
                buf_init_user-account.nik        :bgcolor in browse br-user = gray_color
                buf_init_user-account.last-name  :bgcolor in browse br-user = gray_color
                buf_init_user-account.first-name :bgcolor in browse br-user = gray_color
                v-users-user-login      :bgcolor in browse br-user = gray_color
                buf_init_user-account.user-id    :bgcolor in browse br-user = gray_color
            .
        end.
        else do:
            assign
                buf_init_user-account.nik        :bgcolor in browse br-user = WHITE_COLOR
                buf_init_user-account.last-name  :bgcolor in browse br-user = WHITE_COLOR
                buf_init_user-account.first-name :bgcolor in browse br-user = WHITE_COLOR
                v-users-user-login      :bgcolor in browse br-user = WHITE_COLOR
                buf_init_user-account.user-id    :bgcolor in browse br-user = WHITE_COLOR
            .
        end.
        run procedure-get-work-status in this-procedure (
              input buf_init_user-account.user-id
            , output v-work-status
        ).
        case v-work-status
        :
            when "+":U
            then do:
                assign
                    buf_init_user-account.nik        :fgcolor in browse br-user = CYAN_COLOR
                    buf_init_user-account.last-name  :fgcolor in browse br-user = CYAN_COLOR
                    buf_init_user-account.first-name :fgcolor in browse br-user = CYAN_COLOR
                    v-users-user-login      :fgcolor in browse br-user = CYAN_COLOR
                    buf_init_user-account.user-id    :fgcolor in browse br-user = CYAN_COLOR
                .
            end.        /* when "+":U */
            when "*":U
            then do:
                assign
                    buf_init_user-account.nik        :fgcolor in browse br-user = BLUE_COLOR
                    buf_init_user-account.last-name  :fgcolor in browse br-user = BLUE_COLOR
                    buf_init_user-account.first-name :fgcolor in browse br-user = BLUE_COLOR
                    v-users-user-login      :fgcolor in browse br-user = BLUE_COLOR
                    buf_init_user-account.user-id    :fgcolor in browse br-user = BLUE_COLOR
                .
            end.        /* when "*":U */
            otherwise do:

            end.        /* otherwise */
        end case.       /* case v-work-status */

    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-user Dialog-Frame
ON VALUE-CHANGED OF br-user IN FRAME Dialog-Frame
DO:
    RUN manage-fields IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-firm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-firm Dialog-Frame
ON CHOOSE OF bt-firm IN FRAME Dialog-Frame /* Фирмы */
DO:
    if available buf_init_user-login
    then do:
        run procedure-user-login-user-host in this-procedure (
              input buf_init_user-login.db-num
            , input buf_init_user-login.user-id
        ) no-error .
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове списка фирм, доступных пользователю" skip
                error-status :get-message(1) skip
                return-value skip
            view-as alert-box error .
            undo, return no-apply .
        end.
        run manage-fields-login in this-procedure .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-menu
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-menu Dialog-Frame
ON CHOOSE OF bt-menu IN FRAME Dialog-Frame /* Меню */
DO:
    if available buf_init_user-login
    then do:
        run procedure-user-login-menu-group in this-procedure (
              input buf_init_user-login.db-num
            , input buf_init_user-login.user-id
        ) no-error .
        if error-status :error
        then do:
           message
              vss-workfile vss-revision vss-description skip
              "Ошибка при вызове списка меню, доступных пользователю" skip
              error-status :get-message(1) skip
              return-value skip
           view-as alert-box error .
           undo, return no-apply .
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-object
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-object Dialog-Frame
ON CHOOSE OF bt-object IN FRAME Dialog-Frame /* Объекты */
DO:
    if available buf_init_user-login
    then do:
        run procedure-user-login-user-obj in this-procedure (
              input buf_init_user-login.db-num
            , input buf_init_user-login.user-id
        ) no-error .
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове списка объектов, доступных пользователю" skip
                error-status :get-message(1) skip
                return-value skip
            view-as alert-box error .
            undo, return no-apply .
        end.
        run manage-fields-login in this-procedure .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-password
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-password Dialog-Frame
ON CHOOSE OF bt-password IN FRAME Dialog-Frame /* Пароль */
DO:
    if available buf_init_user-login
    then do:
        run procedure-user-login-change-password in this-procedure (
              input buf_init_user-login.db-num
            , input buf_init_user-login.user-id
            , input yes
        ) no-error .
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры смены пароля" skip
                error-status :get-message(1) skip
                return-value skip
            view-as alert-box error .
            undo, return no-apply .
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-role
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-role Dialog-Frame
ON CHOOSE OF bt-role IN FRAME Dialog-Frame /* Права */
DO:
    if available buf_init_user-login
    then do:
       run procedure-user-login-action-role in this-procedure (
           input buf_init_user-login.db-num
         , input buf_init_user-login.user-id
       ) no-error .
       if error-status :error
       then do:
          message
             vss-workfile vss-revision vss-description skip
             "Ошибка при вызове списка прав пользователя" skip
             error-status :get-message(1) skip
             return-value skip
          view-as alert-box error .
          undo, return no-apply .
       end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cb-db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cb-db Dialog-Frame
ON VALUE-CHANGED OF cb-db IN FRAME Dialog-Frame /* БД */
DO:
    define variable v-user-account-rowid    as rowid        no-undo.
    if available buf_init_user-account
    then do:
        assign
            v-user-account-rowid = rowid( buf_init_user-account )
        .
    end.
    assign
        cb-db
    .
    if rs-scope :screen-value = "1"
    then do:
        assign
            v-users-last-cb-db = cb-db
        .
    end.
    run assign-field-filter-mark in this-procedure (
          input v-users-name-filter
        , input v-users-login-filter
    ).
    {&OPEN-QUERY-br-user}
    run manage-fields in this-procedure.
    if not error-status :error
    then do:
        apply "value-changed":U to br-user.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_b-print-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_b-print-list Dialog-Frame
ON CHOOSE OF MENU-ITEM m_b-print-list /* Список пользователей */
DO:
  if available (buf_init_user-login) then v-rowid-login = rowid (buf_init_user-login) .
        run get-report-num in parParentProc (
            output p-report-id
        ).

  v-report-name-html-list = session:temp-directory + {&DF_Name} + string(p-report-id) + ".html". /*формирование имя файла для часть1*/        
    
    run PROC-print-list in this-procedure.
      /*  {&OPEN-QUERY-br-user}
        run manage-fields in this-procedure .
        {&OPEN-QUERY-br-login}
        run manage-fields-login in this-procedure . */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME last-pwd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL last-pwd Dialog-Frame
ON CHOOSE OF MENU-ITEM last-pwd /* Отчет о смене пароля */
DO:
   if available (buf_init_user-login) 
   then 
      v-rowid-login = rowid (buf_init_user-login) .
   run get-report-num in parParentProc (
            output p-report-id
        ).

   v-report-name-html-list = session:temp-directory + {&DF_Name} + string(p-report-id) + ".html". /*формирование имя файла для часть1*/        
    
   run rep\last-pwd.p(v-report-name-html-list).

   run prn-lib-reportviewer in this-procedure (
             input parParentProc
            ,input v-report-name-html-list
            ,input "" 
            ) no-error.
   if error-status:error 
   then 
      message return-value view-as alert-box.
   
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME adm-bd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL adm-bd Dialog-Frame
ON CHOOSE OF MENU-ITEM adm-bd /* Отчет о админах БД */
DO:
  if available (buf_init_user-login) then v-rowid-login = rowid (buf_init_user-login) .
        run get-report-num in parParentProc (
            output p-report-id
        ).

  v-report-name-html-list = session:temp-directory + {&DF_Name} + string(p-report-id) + ".html". /*формирование имя файла для часть1*/        
    
  run rep\adm_bd.p(v-report-name-html-list).

  run prn-lib-reportviewer in this-procedure (
            input parParentProc
            ,input v-report-name-html-list
            ,input "" 
            ) no-error.
  if error-status:error 
  then
     message return-value view-as alert-box.

END.



/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_b-print-prava
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_b-print-prava Dialog-Frame
ON CHOOSE OF MENU-ITEM m_b-print-prava /* Список прав пользователей */
DO:
  if available (buf_init_user-login) then v-rowid-login = rowid (buf_init_user-login) .
        run get-report-num in parParentProc (
            output p-report-id
        ).

  v-report-name-html = session:temp-directory + {&DF_Name} + string(p-report-id) + ".html". /*формирование имя файла для часть1*/        
    
    run PROC-print-prava in this-procedure.
        {&OPEN-QUERY-br-user}
        run manage-fields in this-procedure .
        {&OPEN-QUERY-br-login}
        run manage-fields-login in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_b-print-user
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_b-print-user Dialog-Frame
ON CHOOSE OF MENU-ITEM m_b-print-user /* Пользователь */
DO:
  if available buf_init_user-login
    then 
  do:
    run adm/usr-prnt.p ( INPUT parparentproc
      , INPUT buf_init_user-login.user-id
      , INPUT buf_init_user-login.db-num
      ) .
  end.
  else do:
    message
         "Пользователь не найден, для которого необходим отчет"
       view-as alert-box information.
       return.
  end.  
        {&OPEN-QUERY-br-user}
        run manage-fields in this-procedure .
        {&OPEN-QUERY-br-login}
        run manage-fields-login in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-scope
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-scope Dialog-Frame
ON VALUE-CHANGED OF rs-scope IN FRAME Dialog-Frame
DO:
    define variable v-user-account-rowid    as rowid        no-undo.
    if available buf_init_user-account
    then do:
        assign
            v-user-account-rowid = rowid( buf_init_user-account )
        .
    end.
    if rs-scope <> 1
    then do:
        if rs-scope :screen-value = "1"
        and v-cntxt-db-num = 0
        then do:
            assign
                cb-db = v-users-last-cb-db
            .
            display
                cb-db
            with frame {&frame-name} .
        end.
    end.
    assign
        rs-scope
    .
    if rs-scope <> 1
    and v-cntxt-db-num = 0
    then do:
        assign
            cb-db = -1
        .
        display
            cb-db
        with frame {&frame-name} .
    end.
    run assign-field-filter-mark in this-procedure (
          input v-users-name-filter
        , input v-users-login-filter
    ).
    {&OPEN-QUERY-br-user}
    run manage-fields in this-procedure.
/*    reposition br-user to rowid v-user-account-rowid no-error.*/
    if not error-status :error
    then do:
        apply "value-changed":U to br-user.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tb-filter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tb-filter Dialog-Frame
ON VALUE-CHANGED OF tb-filter IN FRAME Dialog-Frame
DO:
    assign
        tb-filter
    .
    {&OPEN-QUERY-br-user}
    apply "entry":U to br-user.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-login
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */
    { gbl/getcntxt.i get }

    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      "'actn_users-lookup':U"
      {&cntxt-global}
      0
      '':U
      0
      0
      0
      0
      false
      v-ok
    }
    IF NOT v-ok then do:
       message
         "У вас нет прав на просмотр информации о пользователях"
       view-as alert-box information.
       return.
    end.

{ gbl/app_help.i }

/*{ gbl/brwrefre.i }*/

/*{ gbl/brwrepos.i*/
/*  &line-num=8*/
/*}*/

{ gbl/hot-key.i b-add  }
/*{ gbl/hot-key.i b-chg  }*/
/*{ gbl/hot-key.i b-del  }*/
/*{ gbl/hot-key.i b-mark }*/

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

    run init-fields in this-procedure .

    RUN enable_UI.
/*    br-user :set-repositioned-row( v-users-current-focus, "ALWAYS") in frame {&FRAME-NAME}.*/
/*    reposition br-user to rowid v-users-current-rowid no-error.*/
/*    apply "value-changed" to br-user.*/
    run manage-fields in this-procedure .
    disable
        tb-filter
    with frame {&frame-name}.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE assign-field-filter-mark Dialog-Frame 
PROCEDURE assign-field-filter-mark :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-name-filter    as character        no-undo.
define input parameter p-login-filter    as character        no-undo.

    define buffer buf_user-account          for user-account.
    define buffer buf_user-login            for user-login.
    define buffer buf_temp_filter-fields    for temp_filter-fields.
do
for buf_user-account
  , buf_user-login
  , buf_temp_filter-fields
on error undo, return error
:
    for each buf_user-account no-lock
    :
        find first buf_temp_filter-fields
             where buf_temp_filter-fields.user-id = buf_user-account.user-id
        no-error.
        if not available buf_temp_filter-fields
        then do:
            create buf_temp_filter-fields.
            assign
                buf_temp_filter-fields.user-id              = buf_user-account.user-id
            .
        end.
        assign
            buf_temp_filter-fields.fld-record-visible = yes
        .
        if cb-db >= 0
        then do:
            find first buf_user-login no-lock
                 where buf_user-login.user-id = buf_user-account.user-id
                   and buf_user-login.db-num  = cb-db
            no-error.
            if not available buf_user-login
            then do:
                assign
                    buf_temp_filter-fields.fld-record-visible = no
                .
            end.
        end.
    end.
end.
END PROCEDURE. /* assign-field-filter-mark */

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE duplicate-user Dialog-Frame 
PROCEDURE duplicate-user :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-user-id    as character        no-undo.
define input parameter p-db-num     as integer          no-undo.
define output parameter p-rowid     as rowid            no-undo.
define output parameter p-success   as logical          no-undo.

    define variable v-new-name      as character    no-undo.
    define variable v-new-nick      as character    no-undo.
    define variable v-new-login     as character    no-undo.
    define variable v-success       as logical      no-undo.
    define variable v-user-rowid    as rowid        no-undo.

    define variable v-next-user-id as character no-undo .
    define variable v-user-menu-group-code    as integer      no-undo.
    define variable v-user-login-role-code    as integer      no-undo.

    define buffer buf_user-account              for user-account .
    define buffer buf_user-login                for user-login .

    define buffer buf_user-obj                  for user-obj .
    define buffer buf_user-host                 for user-host .
    define buffer buf_user-menu-group           for user-menu-group .
    define buffer buf_user-login-action-role    for user-login-action-role .

    define buffer new_user-account              for user-account .
    define buffer new_user-login                for user-login .
    define buffer new_user-obj                  for user-obj .
    define buffer new_user-host                 for user-host .
    define buffer new_user-menu-group           for user-menu-group .
    define buffer new_user-login-action-role    for user-login-action-role .
do
for buf_user-account
  , buf_user-login
  , buf_user-obj
  , buf_user-host
  , buf_user-menu-group
  , buf_user-login-action-role
  , new_user-account
  , new_user-login
  , new_user-obj
  , new_user-host
  , new_user-menu-group
  , new_user-login-action-role
on error undo, return error
:
    find first buf_user-account exclusive-lock
         where buf_user-account.user-id = p-user-id
    no-error.
    if not available buf_user-account
    then do:
        message
            "Запись пользователя редактируется администратором."
            skip (1)
            skip "Повторите операцию через некоторое время."
        view-as alert-box warning.
        undo, return error .
    end.
    assign
        v-user-rowid = rowid( buf_user-account )
    .
    find first buf_user-account share-lock
         where buf_user-account.user-id = p-user-id
    .
    run get-new-name in this-procedure (
          input p-user-id
        , input p-db-num
        , output v-new-name
        , output v-new-nick
        , output v-new-login
        , output v-success
    ) no-error.
    if error-status :error
    then do:
        message
                    vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка выбора имени нового"
            skip "пользователя для копирования."
            skip return-value
            skip trim( error-status :get-message( 1 ) )
                    trim( error-status :get-message( 2 ) )
                    trim( error-status :get-message( 3 ) )
        view-as alert-box error.
        undo, return error.
    end.
    if v-success = no
    then do:
        message
            "Не удалось создать копию"
            skip "пользователя и логина"
            skip "в текущей базе данных"
        view-as alert-box warning
        title "Копирование пользователя".
        undo, return .
    end.
    message
                "Текущий пользователь и его логин"
        skip "для текущей базы данных"
        skip "с правами в текущей базе данных"
        skip "будут скопированы как:"
        skip (1)
        skip substitute( "Фамилия:      &1", v-new-name  )
        skip substitute( "Псевдоним:    &1", v-new-nick  )
        skip substitute( "Логин (БД&1): &2", v-cntxt-db-num, v-new-login )
        skip (1)
        skip "Копировать пользователя?"
        view-as alert-box question
        buttons yes-no
        title "Копирование пользователя"
        update v-ok.
    if v-ok = yes
    then do:
        { gbl/working.i }
        assign
                v-next-user-id  = substitute( "&1-&2":U
                                        , p-db-num
                                        , next-value( s-user-id ) )
        .
        find first new_user-account exclusive-lock
             where new_user-account.user-id = v-next-user-id
        no-error.
        if available new_user-account
        then do:
                undo, return error substitute( "Ошибка при создании пользователя (buf_init_user-account).&1Попытка создания записи с существующим кодом.&1.Код записи: &2"
                                                    , {&new-line}
                                                    , v-next-user-id  ).
        end.
        create new_user-account .
        assign
                new_user-account.user-id   = v-next-user-id
                new_user-account.last-name = v-new-name
                new_user-account.nik       = v-new-nick
        .
        buffer-copy buf_user-account
            except user-id last-name nik
                to new_user-account
                .
        if v-new-login <> "":U
        then do:
            find first buf_user-login no-lock
                 where buf_user-login.user-id = p-user-id
                   and buf_user-login.db-num  = p-db-num
            no-error
            .
            if not available buf_user-login
            then do:
                message
                    "Логин пользователя редактируется администратором."
                    skip (1)
                    skip substitute( "Пользователь: &1", buf_user-account.nik )
                    skip substitute( "БД:           &1", p-db-num             )
                    skip (1)
                    skip "Повторите операцию через некоторое время."
                view-as alert-box warning.
                undo, return error .
            end.
            create new_user-login.
            buffer-copy buf_user-login
                except user-id db-num user-login  user-administrator 
                    to new_user-login
            assign
                    new_user-login.user-login       = v-new-login
                    new_user-login.user-id          = v-next-user-id
                    new_user-login.db-num           = p-db-num
            .
            FOR EACH  buf_user-obj no-lock
                where buf_user-obj.db-num  = buf_user-login.db-num
                    and buf_user-obj.user-id = buf_user-login.user-id
            :
                create new_user-obj.
                assign
                    new_user-obj.user-id  = v-next-user-id
                    new_user-obj.db-num   = p-db-num
                    new_user-obj.obj-type = buf_user-obj.obj-type
                    new_user-obj.obj-code = buf_user-obj.obj-code
                .
                buffer-copy buf_user-obj
                except db-num user-id obj-type obj-code
                        to new_user-obj
                        .
            end.
            FOR EACH buf_user-host
               where buf_user-host.db-num  = buf_user-login.db-num
                 and buf_user-host.user-id = buf_user-login.user-id
                no-lock
                :
                    create new_user-host.
                    assign
                        new_user-host.user-id   = v-next-user-id
                        new_user-host.db-num    = p-db-num
                        new_user-host.host-code = buf_user-host.host-code
                    .
                    buffer-copy buf_user-host
                    except db-num user-id host-code
                            to new_user-host
                            .
            end.
            FOR EACH  buf_user-menu-group
                where buf_user-menu-group.db-num  = buf_user-login.db-num
                    and buf_user-menu-group.user-id = buf_user-login.user-id
                no-lock
                :
                    assign
                    v-user-menu-group-code = next-value(s-user-menu-group)
                    .
                    create new_user-menu-group.
                    assign
                        new_user-menu-group.user-id  = v-next-user-id
                        new_user-menu-group.db-num   = p-db-num
                        new_user-menu-group.user-menu-group-code = v-user-menu-group-code
                    .
                    buffer-copy buf_user-menu-group
                        except db-num user-id user-menu-group-code
                            to new_user-menu-group
                            .
            end.
            FOR EACH  buf_user-login-action-role
                where buf_user-login-action-role.db-num  = buf_user-login.db-num
                    and buf_user-login-action-role.user-id = buf_user-login.user-id
                no-lock
                :

                    assign
                    v-user-login-role-code = next-value(s-user-login-action-role)
                    .
                    create new_user-login-action-role.
                    assign
                    new_user-login-action-role.user-id  = v-next-user-id
                    new_user-login-action-role.db-num   = p-db-num
                    new_user-login-action-role.user-login-role-code = v-user-login-role-code
                    .
                    buffer-copy buf_user-login-action-role
                    except db-num user-id user-login-role-code
                            to new_user-login-action-role
                            .
            end.
        end.
        { gbl/stopwork.i }
        assign
            p-rowid     = rowid( new_user-account )
            p-success   = yes
        .
   end.
end.  /* do on error */
END PROCEDURE. /* duplicate-user */

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
  DISPLAY cb-db fi-filter-comment tb-filter rs-scope ed-login-object 
          ed-user-info 
      WITH FRAME Dialog-Frame.
  ENABLE b-exit cb-db b-filter fi-filter-comment tb-filter b-hist b-print b-help 
         rs-scope b-add b-chg b-dup b-del b-userhist b-hist-user b-add-2 
         b-chg-2 b-del-2 bt-password br-user br-login bt-object bt-firm bt-role 
         bt-menu ed-login-object ed-user-info 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-new-name Dialog-Frame 
PROCEDURE get-new-name :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-user-id        as character        no-undo.
define input parameter p-db-num         as integer          no-undo.
define output parameter p-new-name      as character        no-undo.
define output parameter p-new-nick      as character        no-undo.
define output parameter p-new-login     as character        no-undo.
define output parameter p-success       as logical          no-undo.

    define variable v-counter           as integer      no-undo.
    define variable v-ini-login         as character    no-undo.
    define variable v-ini-name          as character    no-undo.
    define variable v-ini-nick          as character    no-undo.

    define buffer buf_user-account      for user-account.
    define buffer buf_nick_user-account for user-account.
    define buffer buf_user-login        for user-login.
do
for buf_user-account
  , buf_nick_user-account
  , buf_user-login
on error undo, return error
:
    find first buf_user-account no-lock
         where buf_user-account.user-id = p-user-id
    .
    assign
        v-ini-name  = buf_user-account.last-name
        v-ini-nick  = buf_user-account.nik
        p-new-name  = substitute( "Копия_&1", buf_user-account.last-name )
        p-new-nick  = substitute( "Копия_&1", buf_user-account.nik       )
    .
    find first buf_user-login no-lock
         where buf_user-login.db-num    = p-db-num
           and buf_user-login.user-id   = buf_user-account.user-id
    no-error.
    if not available buf_user-login
    then do:
        assign
            v-ini-login = "":U
            p-new-login = "":U
        .
    end.
    else do:
        assign
            v-ini-login = buf_user-login.user-login
            p-new-login = substitute( "Копия_&1", buf_user-login.user-login )
        .
    end.
    assign
        v-counter        = 1
    .
    find first buf_user-account no-lock
         where buf_user-account.last-name = p-new-name
    no-error.
    find first buf_nick_user-account no-lock
         where buf_nick_user-account.last-name = p-new-nick
    no-error.
    if p-new-login <> "":U
    then do:
        find first buf_user-login no-lock
             where buf_user-login.user-login  = p-new-login
        no-error.
    end.
    do
    while available buf_user-account
    or available buf_nick_user-account
    or ( p-new-login <> "":U and available buf_user-login )
    :
        assign
            v-counter           = v-counter + 1
            p-new-name     = substitute( "Копия(&1)_&2", v-counter, v-ini-name  )
            p-new-nick     = substitute( "Копия(&1)_&2", v-counter, v-ini-nick  )
            p-new-login    = substitute( "Копия(&1)_&2", v-counter, v-ini-login )
        .
        find first buf_user-account no-lock
             where buf_user-account.last-name = p-new-name
        no-error.
        find first buf_nick_user-account no-lock
             where buf_nick_user-account.last-name = p-new-nick
        no-error.
        if p-new-login <> "":U
        then do:
            find first buf_user-login no-lock
                 where buf_user-login.user-login  = p-new-login
            no-error.
        end.
    end.
    assign
        p-success   = yes
    .
end.
END PROCEDURE. /* get-new-name */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE assign-filter-mark {&FRAME-NAME}
PROCEDURE assign-filter-mark :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-name-filter    as character        no-undo.
define input parameter p-login-filter    as character        no-undo.

    define buffer buf_user-account          for user-account.
    define buffer buf_user-login            for user-login.
    define buffer buf_temp_filter-fields    for temp_filter-fields.
do
for buf_user-account
  , buf_user-login
  , buf_temp_filter-fields
on error undo, return error
:
    for each buf_user-account no-lock
    :
        find first buf_temp_filter-fields
             where buf_temp_filter-fields.user-id = buf_user-account.user-id
        no-error.
        if not available buf_temp_filter-fields
        then do:
            create buf_temp_filter-fields.
            assign
                buf_temp_filter-fields.user-id              = buf_user-account.user-id
                buf_temp_filter-fields.flt-record-visible   = no
            .
        end.
        if ( p-name-filter = "":U and p-login-filter = "":U )
        or index( buf_user-account.last-name,  p-name-filter ) <> 0
        or index( buf_user-account.first-name, p-name-filter ) <> 0
        then do:
            assign
                buf_temp_filter-fields.flt-record-visible = yes
            .
        end.
        else do:
            assign
                buf_temp_filter-fields.flt-record-visible = no
            .
            search-in-login:
            for each buf_user-login no-lock
               where buf_user-login.user-id = buf_user-account.user-id
            :
                if index( buf_user-login.user-login, p-login-filter ) <> 0
                then do:
                    assign
                        buf_temp_filter-fields.flt-record-visible = yes
                    .
                end.
                leave search-in-login.
            end.
        end.
    end.
end.
END PROCEDURE. /* assign-filter-mark */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-saved-position Dialog-Frame 
PROCEDURE get-saved-position :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define variable v-current-rowid-string      as character    no-undo.
    define variable v-current-focus-string      as character    no-undo.
    define variable v-current-db-string         as character    no-undo.
    define variable v-current-status-string     as character    no-undo.
    define variable v-void-logical              as logical      no-undo.
    define variable v-void-character            as character    no-undo.

do
on error undo, return error
:
   run uf-get (
        input {&uf-users-1}
      , input  v-cntxt-userid
      , output v-current-status-string
      , output v-current-db-string
      , output v-void-logical
      , output v-void-logical
      , output v-void-logical
      , output v-void-logical
   ) .
   run uf-get (
           input {&uf-users-2}
         , input  v-cntxt-userid
         , output v-current-focus-string
         , output v-current-rowid-string
         , output v-void-logical
         , output v-void-logical
         , output v-void-logical
         , output v-void-logical
   ) .

   assign
      cb-db                   = IF v-current-db-string <> "":U       THEN integer(  v-current-db-string     ) ELSE cb-db
      rs-scope                = IF v-current-status-string <> "":U   THEN integer(  v-current-status-string ) ELSE rs-scope
      v-users-current-rowid   = IF v-current-rowid-string <> "":U    THEN to-rowid( v-current-rowid-string  ) ELSE v-users-current-rowid
      v-users-current-focus   = IF v-current-focus-string <> "":U    THEN integer(  v-current-focus-string  ) ELSE 1
   .

   IF cb-db = ?
   THEN DO:
      ASSIGN
         cb-db = v-cntxt-db-num
      .
   END.

   IF rs-scope = ?
   THEN DO:
      ASSIGN
         rs-scope    = 1
      .
   END.

end.
END PROCEDURE. /* get-saved-position */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-user-fields Dialog-Frame 
PROCEDURE get-user-fields :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-user-id                as character        no-undo.
define output parameter p-last-name             as character        no-undo.
define output parameter p-first-name            as character        no-undo.
define output parameter p-second-name           as character        no-undo.
define output parameter p-nik                   as character        no-undo.
define output parameter p-phone-number          as character        no-undo.
define output parameter p-mobile-phone-number   as character        no-undo.
define output parameter p-company               as character        no-undo.
define output parameter p-department            as character        no-undo.
define output parameter p-room                  as character        no-undo.
define output parameter p-e-mail                as character        no-undo.
define output parameter p-internal-phone-number as character        no-undo.
define output parameter p-PS                    as character        no-undo.

    define buffer buf_user-account      for user-account.
do
for buf_user-account
on error undo, return error
:
    find first buf_user-account no-lock
         where buf_user-account.user-id = p-user-id
    no-error.
    if available buf_user-account
    then do:
        assign
            p-last-name             = buf_user-account.last-name
            p-first-name            = buf_user-account.first-name
            p-second-name           = buf_user-account.second-name
            p-nik                   = buf_user-account.nik
            p-phone-number          = buf_user-account.phone-number
            p-mobile-phone-number   = buf_user-account.mobile-phone-number
            p-company               = buf_user-account.company
            p-department            = buf_user-account.department
            p-room                  = buf_user-account.room
            p-e-mail                = buf_user-account.e-mail
            p-internal-phone-number = buf_user-account.internal-phone-number
            p-PS                    = buf_user-account.PS
        .
    end.
    else do:
        assign
            p-last-name             = "":U
            p-first-name            = "":U
            p-second-name           = "":U
            p-nik                   = "":U
            p-phone-number          = "":U
            p-mobile-phone-number   = "":U
            p-company               = "":U
            p-department            = "":U
            p-room                  = "":U
            p-e-mail                = "":U
            p-internal-phone-number = "":U
            p-PS                    = "":U
        .
    end.
end.
END PROCEDURE. /* get-user-fields */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-fields Dialog-Frame 
PROCEDURE init-fields :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define buffer buf_db                    for db.
    define buffer buf_user-account          for user-account.
    define buffer buf_temp_filter-fields    for temp_filter-fields.
do
with frame {&frame-name}
on error undo, return error
:
    assign
        cb-db :delimiter        = {&delim-par}
        rs-scope    = 1
        cb-db :list-item-pairs = substitute( "&2&1&3"
                                    , {&delim-par}
                                    , "< Все >"
                                    , -1 )
    .
    if v-cntxt-db-num > 0
    then do:
      for each buf_db
          where buf_db.db-num = v-cntxt-db-num
          no-lock
      on error undo, return error
      :
         assign
               cb-db :list-item-pairs = substitute ( "&2&1&4 &3&1&4"
                                                   , {&delim-par}
                                                   , cb-db :list-item-pairs
                                                   , buf_db.db-name
                                                   , buf_db.db-num
                                                   )
         .
      end.        /* for each buf_db */
    end.
    else do:
      for each buf_db no-lock
      on error undo, return error
      :
         assign
               cb-db :list-item-pairs = substitute ( "&2&1&4 &3&1&4"
                                                   , {&delim-par}
                                                   , cb-db :list-item-pairs
                                                   , buf_db.db-name
                                                   , buf_db.db-num
                                                   )
         .
      end.        /* for each buf_db */
    end.

    assign
       cb-db = v-cntxt-db-num
    .

    assign
        v-users-name-filter = "":U
        v-users-login-filter = "":U
        v-users-set-rowid    = yes
    .
    run get-saved-position in this-procedure.

    run assign-field-filter-mark in this-procedure (
          input v-users-name-filter
        , input v-users-login-filter
    ).
    find first user-account-attr where user-account-attr.user-id    eq g#userid
                                   and user-account-attr.attr-code  eq "superadm"
    no-lock no-error.
    if     available user-account-attr
       and logical(user-account-attr.attr-value) eq yes
    then
       mSuperAdm = yes.  
    
end.
END PROCEDURE. /* init-fields */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE manage-fields Dialog-Frame 
PROCEDURE manage-fields :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer user-login for user-login.
do
with frame {&frame-name}
on error undo, return error
:
    /*
    if v-cntxt-db-num > 0
    then do:
        disable
            cb-db
        with frame {&frame-name}.
    end.
    */
    {&OPEN-QUERY-br-login}
    run manage-fields-login in this-procedure .
    define variable vflag as logical no-undo.
    if   available buf_init_user-account 
      and buf_init_user-account.user-id eq g#userid
       or mSuperAdm
    then
       vflag = yes.
    else do:
       find first user-login where user-login.user-id eq buf_init_user-account.user-id
                               and user-login.status_ eq buf_init_user-account.status_
                               and user-login.user-administrator no-lock no-error.
                              
       vflag = not available user-login. 
    end.
    b-chg:sensitive = vflag.
    b-dup:sensitive = true.
    b-del:sensitive = vflag.                        
    assign
        ed-user-info = "":U
    .
    if available buf_init_user-account
    then do:
        assign
            ed-user-info = trim( substitute( "&1&2&3"
                                , buf_init_user-account.phone-number
                                , ( if buf_init_user-account.phone-number = "":U then "":U else ", " )
                                , buf_init_user-account.mobile-phone-number
                                ), ", " )
        .
        assign
            ed-user-info = trim( substitute( "&1&2&3"
                                , ed-user-info
                                , ( if ed-user-info  = "":U then "":U else ", " )
                                , buf_init_user-account.company
                                ), ", " )
        .
        assign
            ed-user-info = trim( substitute( "&1&2&3"
                                , ed-user-info
                                , ( if ed-user-info  = "":U then "":U else ", " )
                                , buf_init_user-account.department
                                ), ", " )
        .
        assign
            ed-user-info = trim( substitute( "&1&2&3"
                                , ed-user-info
                                , ( if ed-user-info  = "":U then "":U else ", " )
                                , buf_init_user-account.position
                                ), ", " )
        .
        assign
            ed-user-info = trim( substitute( "&1&2&3"
                                , ed-user-info
                                , ( if ed-user-info  = "":U then "":U else ", " )
                                , buf_init_user-account.room
                                ), ", " )
        .
        assign
            ed-user-info = trim( substitute( "&1&2&3"
                                , ed-user-info
                                , ( if ed-user-info  = "":U then "":U else ", " )
                                , buf_init_user-account.e-mail
                                ), ", " )
        .
        assign
            ed-user-info = trim( substitute( "&1&2&3"
                                , ed-user-info
                                , ( if ed-user-info  = "":U then "":U else ", " )
                                , buf_init_user-account.internal-phone-number
                                ), ", " )
        .
        assign
            ed-user-info = trim( substitute( "&1&2&3"
                                , ed-user-info
                                , ( if ed-user-info  = "":U then "":U else ", " )
                                , buf_init_user-account.internal-phone-number
                                ), ", " )
        .
        assign
            ed-user-info = trim( substitute( "&1&2&3"
                                , ed-user-info
                                , ( if ed-user-info  = "":U then "":U else ", " )
                                , buf_init_user-account.PS
                                ), ", " )
        .
        b-del:label = if    not avail buf_init_user-account 
                         or buf_init_user-account.status_ eq {&bef-user-status-normal}
                      then "Удалить"
                      else "Вост.".
    end.
    display
        ed-user-info
    .
end.
END PROCEDURE. /* manage-fields */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE manage-fields-login Dialog-Frame 
PROCEDURE manage-fields-login :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define variable v-host-code    as integer      no-undo.

    define buffer buf_temp_user-login-obj   for temp_user-login-obj.
    define buffer buf_user-obj              for user-obj.
    define buffer buf_user-host             for user-host.
    define buffer buf_clients               for clients.
    define buffer buf_user-login            for user-login.
do
for buf_temp_user-login-obj
  , buf_user-obj
  , buf_user-host
  , buf_clients
  , buf_user-login
with frame {&frame-name}
on error undo, return error
:
    if cb-db > 0
    and available buf_init_user-account
    then do:
        find first buf_init_user-login no-lock
             where buf_init_user-login.db-num  = cb-db
               and buf_init_user-login.user-id = buf_init_user-account.user-id
        no-error.

        if available buf_init_user-login
        then do:
            reposition br-login to rowid rowid( buf_init_user-login ) no-error.
            apply "value-changed" to br-login.
        end.
    end.
    assign
        ed-login-object = "":U
    .
    b-del-2:label = if    not avail buf_init_user-login
                       or buf_init_user-login.status_ eq {&bef-user-status-normal}
                  then "Удалить"
                  else "Вост.".
    empty temp-table buf_temp_user-login-obj.
    if available buf_init_user-login
    then do:
        for each buf_user-obj no-lock
           where buf_user-obj.db-num  = buf_init_user-login.db-num
             and buf_user-obj.user-id = buf_init_user-login.user-id
        :
            find first buf_temp_user-login-obj
                 where buf_temp_user-login-obj.db-num      = buf_init_user-login.db-num
                   and buf_temp_user-login-obj.user-id     = buf_init_user-login.user-id
                   and buf_temp_user-login-obj.obj-type    = buf_user-obj.obj-type
                   and buf_temp_user-login-obj.obj-code    = buf_user-obj.obj-code
            no-error.
            if not available buf_temp_user-login-obj
            then do:
                find first buf_clients no-lock
                     where buf_clients.obj-type = buf_user-obj.obj-type
                       and buf_clients.obj-code = buf_user-obj.obj-code
                .
                create buf_temp_user-login-obj.
                assign
                    buf_temp_user-login-obj.db-num      = buf_init_user-login.db-num
                    buf_temp_user-login-obj.user-id     = buf_init_user-login.user-id
                    buf_temp_user-login-obj.obj-type    = buf_clients.obj-type
                    buf_temp_user-login-obj.obj-code    = buf_clients.obj-code
                    buf_temp_user-login-obj.host-code   = buf_clients.host-code
                    buf_temp_user-login-obj.obj-name    = substitute( "  &1", buf_clients.obj-name )
                .
                assign
                    v-host-code = buf_temp_user-login-obj.host-code
                .
                find first buf_temp_user-login-obj
                     where buf_temp_user-login-obj.db-num      = buf_init_user-login.db-num
                       and buf_temp_user-login-obj.user-id     = buf_init_user-login.user-id
                       and buf_temp_user-login-obj.obj-type    = " ":U
                       and buf_temp_user-login-obj.obj-code    = v-host-code
                no-error.
                if not available buf_temp_user-login-obj
                then do:
                    find first buf_clients no-lock
                         where buf_clients.obj-type = {&cmp}
                           and buf_clients.obj-code = v-host-code
                    .
                    create buf_temp_user-login-obj.
                    assign
                        buf_temp_user-login-obj.db-num      = buf_init_user-login.db-num
                        buf_temp_user-login-obj.user-id     = buf_init_user-login.user-id
                        buf_temp_user-login-obj.obj-type    = " ":U
                        buf_temp_user-login-obj.obj-code    = buf_clients.obj-code
                        buf_temp_user-login-obj.host-code   = buf_clients.obj-code
                        buf_temp_user-login-obj.obj-name    = substitute( "&1", buf_clients.obj-name )
                    .
                end.
            end.
        end.
        for each buf_user-host no-lock
           where buf_user-host.db-num  = buf_init_user-login.db-num
             and buf_user-host.user-id = buf_init_user-login.user-id
        :
            find first buf_temp_user-login-obj
                 where buf_temp_user-login-obj.db-num      = buf_init_user-login.db-num
                   and buf_temp_user-login-obj.user-id     = buf_init_user-login.user-id
                   and buf_temp_user-login-obj.obj-type    = " ":U
                   and buf_temp_user-login-obj.obj-code    = buf_user-host.host-code
            no-error.
            if not available buf_temp_user-login-obj
            then do:
                find first buf_clients no-lock
                     where buf_clients.obj-type = {&cmp}
                       and buf_clients.obj-code = buf_user-host.host-code
                .
                create buf_temp_user-login-obj.
                assign
                    buf_temp_user-login-obj.db-num      = buf_init_user-login.db-num
                    buf_temp_user-login-obj.user-id     = buf_init_user-login.user-id
                    buf_temp_user-login-obj.obj-type    = " ":U
                    buf_temp_user-login-obj.obj-code    = buf_clients.obj-code
                    buf_temp_user-login-obj.host-code   = buf_clients.obj-code
                    buf_temp_user-login-obj.obj-name    = substitute( "&1", buf_clients.obj-name )
                .
            end.
        end.
        for each buf_temp_user-login-obj
           where buf_temp_user-login-obj.db-num      = buf_init_user-login.db-num
             and buf_temp_user-login-obj.user-id     = buf_init_user-login.user-id
        by buf_temp_user-login-obj.host-code
        by buf_temp_user-login-obj.obj-type
        on error undo, return error
        :
            assign
                ed-login-object = substitute( "&1&2&3"
                                        , ed-login-object
                                        , ( if ed-login-object = "":U then "":U else {&new-line} )
                                        , buf_temp_user-login-obj.obj-name )
            .
        end.        /* for each buf_temp_user-login-obj */
        define variable v-have-login    as logical      no-undo.
        assign
            v-have-login = no
        .
        if buf_init_user-login.db-num = v-cntxt-db-num
        then do:
            assign
                v-have-login = yes
            .
        end.
        else do:
            search-cur-db-login:
            for each buf_user-login no-lock
               where buf_user-login.user-id = buf_init_user-login.user-id
            on error undo, return error
            :
                if buf_user-login.db-num = v-cntxt-db-num
                then do:
                    assign
                        v-have-login = yes
                    .
                    undo search-cur-db-login, leave search-cur-db-login.
                end.
            end.        /* for each buf_user-login */
        end.
           FIND FIRST buf_global-state
        NO-LOCK
        .
        FIND FIRST buf_global-state-attr
      WHERE buf_global-state-attr.gls-id = buf_global-state.gls-id
         AND buf_global-state-attr.attr-code = "action-gbl"
      NO-LOCK
      NO-error
      .
   IF AVAILABLE buf_global-state-attr 
   THEN DO:
     if buf_global-state-attr.attr-value = "yes" then v-action-gbl = yes .
   END.
        if v-have-login = yes and v-cntxt-db-num <> 0 
        then do:
            disable
                b-add-2
                b-copy
            .
        end.
        else do:
        if v-action-gbl then do:
            enable
                b-copy
            .
        end.
            enable
                b-add-2
            .
        end.
        if buf_init_user-login.db-num = v-cntxt-db-num or v-cntxt-db-num = 0
        then do:
           define variable vflag as logical no-undo. 
           vflag = mSuperAdm or  not buf_init_user-login.user-administrator or buf_init_user-login.user-id eq g#userid. 
                
                b-chg-2:sensitive = vflag.                
                b-del-2:sensitive = vflag.
                bt-password:sensitive = vflag.
                bt-object:sensitive = vflag.
                bt-firm:sensitive = vflag.
                bt-role:sensitive = vflag.
                bt-menu:sensitive = vflag.
                if v-cntxt-db-num = 0
                then
                   b-copy:sensitive = vflag.
        end.
        else do:
            disable
                b-copy
                b-chg-2
                b-del-2
                bt-password
                bt-object
                bt-firm
                bt-role
                bt-menu
            .
        end.
    end.
    else do:
        if v-action-gbl then do:
            enable
                b-copy
            .
        end.
        enable
            b-add-2
        .
        disable
            b-copy
            b-chg-2
            b-del-2
            bt-password
            bt-object
            bt-firm
            bt-role
            bt-menu
        .
    end.
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      "'actn_users-update':U"
      {&cntxt-global}
      0
      '':U
      0
      0
      0
      0
      FALSE
      v-ok
    }
    if v-ok = FALSE
    then do:
        disable
            b-add
            b-chg
            b-del
            b-add-2
            b-chg-2
            b-del-2
            bt-password
            b-dup
            /*
            bt-object
            bt-firm
            bt-role
            bt-menu
            */

        .
        assign
            v-only-lookup = TRUE
        .
    end.

    display
        ed-login-object
    .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE open-query Dialog-Frame 
PROCEDURE open-query :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input parameter p-proc-handle    as handle           no-undo.
do
with frame {&frame-name}
on error undo, return error
:
    if v-users-set-rowid = no
    and available buf_init_user-account
    then do:
        assign
            v-users-current-rowid = rowid( buf_init_user-account )
            v-users-current-focus = br-user :focused-row in frame {&FRAME-NAME}
        .
    end.
    else do:
        assign
            v-users-set-rowid = no
        .
    end.
    if fi-filter-comment = "":U
    or tb-filter = no
    then do:
        assign
            fi-filter-comment :bgcolor = GREY_COLOR
        .
    end.
    else do:
        assign
            fi-filter-comment :bgcolor = RED_COLOR
        .
    end.
    case rs-scope
    :
        when 1
        then do:
            OPEN QUERY br-user
                FOR EACH buf_init_user-account no-lock
                   where buf_init_user-account.status_ <> {&bef-user-status-deleted}
                 , first temp_filter-fields
                   where temp_filter-fields.user-id   = buf_init_user-account.user-id
                     and temp_filter-fields.fld-record-visible = yes
                     and ( temp_filter-fields.flt-record-visible = yes or tb-filter = no )
                      by buf_init_user-account.last-name
                      by buf_init_user-account.first-name
                      by buf_init_user-account.second-name
            .
        end.        /* when 1 */
        when 2
        then do:
            OPEN QUERY br-user
                FOR EACH buf_init_user-account no-lock
                 , first temp_filter-fields
                   where temp_filter-fields.user-id   = buf_init_user-account.user-id
                     and temp_filter-fields.fld-record-visible = yes
                     and ( temp_filter-fields.flt-record-visible = yes or tb-filter = no )
                      by buf_init_user-account.last-name
                      by buf_init_user-account.first-name
                      by buf_init_user-account.second-name
            .
        end.        /* when 2 */
        when 3
        then do:
            OPEN QUERY br-user
                FOR EACH buf_init_user-account no-lock
                   where buf_init_user-account.status_ = {&bef-user-status-deleted}
                 , first temp_filter-fields
                   where temp_filter-fields.user-id   = buf_init_user-account.user-id
                     and temp_filter-fields.fld-record-visible = yes
                     and ( temp_filter-fields.flt-record-visible = yes or tb-filter = no )
                      by buf_init_user-account.last-name
                      by buf_init_user-account.first-name
                      by buf_init_user-account.second-name
            .
        end.        /* when 3 */
    end case.       /* case rs-scope */
    if v-users-current-focus > 0
    then do:
        br-user :set-repositioned-row( v-users-current-focus, "ALWAYS") in frame {&FRAME-NAME}.
    end.
    reposition br-user to rowid v-users-current-rowid no-error.
    if error-status :error
    then do:
        query br-user :handle :get-first( no-lock ).
        reposition br-user to rowid rowid( buf_init_user-account ) no-error.
    end.
    apply "entry" to br-user.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE open-query-login Dialog-Frame 
PROCEDURE open-query-login :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    if available buf_init_user-account
    then do:
        OPEN QUERY br-login
            FOR EACH buf_init_user-login NO-LOCK
               where buf_init_user-login.user-id = buf_init_user-account.user-id
            by buf_init_user-login.db-num
        INDEXED-REPOSITION.
    end.
    else do:
        OPEN QUERY br-login
            FOR EACH buf_init_user-login NO-LOCK
               where buf_init_user-login.user-id = "":U
            by buf_init_user-login.db-num
        INDEXED-REPOSITION.
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE person-user Dialog-Frame 
PROCEDURE person-user :
/*------------------------------------------------------------------------------
Purpose:
Parameters:  <none>
Notes:
------------------------------------------------------------------------------*/
define input parameter  p-rec-user-account as recid            no-undo.
define output parameter p-ok               as logical          no-undo.

do
on error undo, return error
:
   define buffer buf_user-account      for ub.user-account .
   define buffer buf_clients     for ub.clients .

   define variable recid-person as character no-undo.
   FIND FIRST buf_user-account
        WHERE RECID(buf_user-account) = p-rec-user-account
        NO-LOCK
        .

   IF AVAILABLE buf_user-account
   AND buf_user-account.psn-code <> 0
   AND buf_user-account.psn-code <> ?
   THEN DO:
      FIND FIRST buf_clients
           WHERE buf_clients.obj-code = buf_user-account.psn-code
             and buf_clients.obj-type = {&prs}
           no-lock
           no-error
           .
      IF AVAILABLE buf_clients
      THEN DO:
         ASSIGN
           recid-person = string( recid( buf_clients ) )
         .
      END.
   END.

   run ref/cli-all.w ( input parparentproc
                     , input "b-sel"
                     , input {&prs}
                     , input {&all}
                     , input {&current}
                     , input ?
                     , input ",,,,,,NO,,"
                     , input "lock-cli-type":U
                     , output recid-person
                     ) .
   IF recid-person <> "":U
   THEN DO:
      FIND FIRST buf_clients
           WHERE RECID(buf_clients) = INTEGER(ENTRY(1, recid-person))
           no-lock
           no-error
           .
      IF AVAILABLE buf_clients
      AND buf_user-account.psn-code <> buf_clients.obj-code
      THEN DO TRANSACTION:
         FIND CURRENT buf_user-account
              EXCLUSIVE-LOCK
              .
         ASSIGN
            buf_user-account.psn-code = buf_clients.obj-code
            p-ok = yes
         .
         FIND CURRENT buf_user-account
              NO-LOCK
              .
      END.  /* TRANSACTION */
   END.
   ELSE DO:
      IF buf_user-account.psn-code <> ?
      THEN DO TRANSACTION:
         FIND CURRENT buf_user-account
              EXCLUSIVE-LOCK
              .
         ASSIGN
            buf_user-account.psn-code = ?
            p-ok = yes
         .
         FIND CURRENT buf_user-account
              NO-LOCK
              .
      END. /* TRANSACTION */
   END.
   RELEASE buf_user-account.
end.  /* do on error */
END PROCEDURE. /* person-user */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-print-list Dialog-Frame 
PROCEDURE proc-print-list :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

  define buffer buf_user-login for ub.user-login .
  define buffer buf_user-account for ub.user-account .
  define VARIABLE v-last-name as character no-undo.
  define VARIABLE v-last-name1 as character no-undo.
  define VARIABLE v-last-name2 as character no-undo.
  
  define buffer buf_temp_filter-fields    for temp_filter-fields.
do
on error undo, return error
:
            
  /*вызов процедуры печати шапки отчета*/      
  output stream OutStr-html to value(v-report-name-html-list) convert target 'UTF-8' /*no-convert*/.
  put stream OutStr-html unformatted
    substitute(
    '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       width: 900px; 
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="list-users" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:50px"></td>
                        <td style="width:200px"></td>
                        <td style="width:200px"></td>
                        <td style="width:50px"></td>
                        <td style="width:200px"></td>
                        <td style="width:200px"></td>
                      </tr>
                      <tr>
                        <td colspan="6" style="font-size:16px;font-weight:bold; text-align: center;">Список пользователей</td>
                      </tr>
                    </thead>
                    <tbody> <!-- Здесь начинается таблица отчета -->
                      <tr> <!-- Первые строки – шапка таблицы с тэгами tr -->
                        <th style="text-align: center;">ID</th>
                        <th style="text-align: center;">ФИО</th>
                        <th style="text-align: center;">Псевдоним</th>
                        <th style="text-align: center;">Номер БД</th>
                        <th style="text-align: center;">Логин</th>
                        <th style="text-align: center;">Дата/время последнего входа</th>
                      </tr>'
    , chr(123), chr(125)
    ).

  /*печать тела*/


if cb-db <> -1 then do:
    case rs-scope
        :
        when 1 then do:
            message   temp_filter-fields.user-id view-as alert-box.
            FOR EACH buf_init_user-login where temp_filter-fields.user-id =  buf_init_user-login.user-id
            
             and buf_init_user-account.status_ <> {&bef-user-status-deleted} 
             /*AND buf_init_user-account.user-id = buf_init_user-login.user-id */
             /* and temp_filter-fields.fld-record-visible = yes
             and ( temp_filter-fields.flt-record-visible = yes or tb-filter = no )*/
             NO-LOCK:
              assign 
              v-last-name = buf_init_user-account.last-name + ' ' + buf_init_user-account.first-name + ' ' + buf_init_user-account.second-name .
                create tt-user-login .
                assign
                tt-user-login.db-num         = buf_init_user-login.db-num
                tt-user-login.last-login-mjd = buf_init_user-login.last-login-mjd
                tt-user-login.nik            = buf_init_user-account.nik
                tt-user-login.user-login     = buf_init_user-login.user-login
                tt-user-login.users-id       = buf_init_user-login.user-id
                tt-user-login.last-name      = v-last-name
                .
            END.
        end.    /* when 1 */
        
        when 2 then do:
            FOR EACH buf_init_user-account :
            	FOR EACH  buf_init_user-login where  buf_init_user-account.user-id = buf_init_user-login.user-id
                   AND buf_init_user-login.db-num = cb-db
                   /* and temp_filter-fields.user-id   = buf_init_user-account.user-id */
                   AND temp_filter-fields.fld-record-visible = yes
                   and ( temp_filter-fields.flt-record-visible = yes or tb-filter = no )
	              NO-LOCK :
        	      assign 
	              v-last-name = buf_init_user-account.last-name + ' ' + buf_init_user-account.first-name + ' ' + buf_init_user-account.second-name .
        	      create tt-user-login .
	              assign
        	      tt-user-login.db-num         = buf_init_user-login.db-num
	              tt-user-login.last-login-mjd = buf_init_user-login.last-login-mjd
        	      tt-user-login.nik            = buf_init_user-account.nik
	              tt-user-login.user-login     = buf_init_user-login.user-login
	              tt-user-login.users-id       = buf_init_user-login.user-id
	              tt-user-login.last-name      = v-last-name
	              .
	            END. 
            end.  /*  FOR EACH buf_user-user-account*/
        end.        /* when 2 */
        
        when 3  then do:
            FOR EACH buf_init_user-account WHERE buf_init_user-account.status_ <> {&bef-user-status-deleted} no-lock:
            	FOR EACH  buf_init_user-login where  buf_init_user-account.user-id = buf_init_user-login.user-id
                AND buf_init_user-login.db-num = cb-db
                /* and temp_filter-fields.user-id   = buf_init_user-account.user-id */
                AND temp_filter-fields.fld-record-visible = yes
                and ( temp_filter-fields.flt-record-visible = yes or tb-filter = no )
	            NO-LOCK BY buf_init_user-account.nik :
            	assign 
	            v-last-name = buf_init_user-account.last-name + ' ' + buf_init_user-account.first-name + ' ' + buf_init_user-account.second-name .
        	    create tt-user-login .
	            assign
        	    tt-user-login.db-num         = buf_init_user-login.db-num
	            tt-user-login.last-login-mjd = buf_init_user-login.last-login-mjd
        	    tt-user-login.nik            = buf_init_user-account.nik
	            tt-user-login.user-login     = buf_init_user-login.user-login
	            tt-user-login.users-id       = buf_init_user-login.user-id
	            tt-user-login.last-name      = v-last-name
	            .
	            END. 
            END.    
        end.     /* when 3 */
    end case.        /* case rs-scope */
END.
  

  
  
 if cb-db = -1 then do:
   FOR EACH buf_init_user-account  /*where buf_init_user-account.user-id = temp_filter-fields.user-id*/
      /*and temp_filter-fields.user-id   = buf_init_user-account.user-id*/
      /*and temp_filter-fields.fld-record-visible = yes*/
      /*And ( temp_filter-fields.flt-record-visible = yes or tb-filter = no )*/ 
      no-lock:
      case rs-scope :
        when 1 then do:
            FOR EACH buf_init_user-login where buf_init_user-account.status_ <> {&bef-user-status-deleted} 
            and buf_init_user-account.user-id = buf_init_user-login.user-id
            and temp_filter-fields.user-id   = buf_init_user-account.user-id
            and temp_filter-fields.fld-record-visible = yes
            and ( temp_filter-fields.flt-record-visible = yes or tb-filter = no )
            no-lock:
            assign 
            v-last-name = buf_init_user-account.last-name + ' ' + buf_init_user-account.first-name + ' ' + buf_init_user-account.second-name .
            create tt-user-login .
            assign
            tt-user-login.db-num         = buf_init_user-login.db-num
            tt-user-login.last-login-mjd = buf_init_user-login.last-login-mjd
            tt-user-login.nik            = buf_init_user-account.nik
            tt-user-login.user-login     = buf_init_user-login.user-login
            tt-user-login.users-id       = buf_init_user-login.user-id
            tt-user-login.last-name      = v-last-name
            .
            end.        
        end.  /* when 1 */
        
        when 2 then do:
            FOR EACH buf_init_user-login where buf_init_user-account.user-id = buf_init_user-login.user-id
                /*and temp_filter-fields.user-id   = buf_init_user-account.user-id*/
                and temp_filter-fields.fld-record-visible = yes
                and ( temp_filter-fields.flt-record-visible = yes or tb-filter = no )
                NO-LOCK:
                assign 
                v-last-name = buf_init_user-account.last-name + ' ' + buf_init_user-account.first-name + ' ' + buf_init_user-account.second-name .
                create tt-user-login .
                assign
                tt-user-login.db-num         = buf_init_user-login.db-num
                tt-user-login.last-login-mjd = buf_init_user-login.last-login-mjd
                tt-user-login.nik            = buf_init_user-account.nik
                tt-user-login.user-login     = buf_init_user-login.user-login
                tt-user-login.users-id       = buf_init_user-login.user-id
                tt-user-login.last-name      = v-last-name
                .
            end.
        end.        /* when 2 */
        
        when 3  then do:
        
            FOR EACH buf_init_user-login where buf_init_user-account.status_ = {&bef-user-status-deleted} 
              and buf_init_user-account.user-id = buf_init_user-login.user-id
              and temp_filter-fields.user-id   = buf_init_user-account.user-id
              /*and temp_filter-fields.fld-record-visible = yes
              and ( temp_filter-fields.flt-record-visible = yes or tb-filter = yes)*/
              NO-LOCK:
                 assign 
                 v-last-name = buf_init_user-account.last-name + ' ' + buf_init_user-account.first-name + ' ' + buf_init_user-account.second-name .
                 create tt-user-login .
                 assign
                  tt-user-login.db-num         = buf_init_user-login.db-num
                  tt-user-login.last-login-mjd = buf_init_user-login.last-login-mjd
                  tt-user-login.nik            = buf_init_user-account.nik
                  tt-user-login.user-login     = buf_init_user-login.user-login
                  tt-user-login.users-id       = buf_init_user-login.user-id
                  tt-user-login.last-name      = v-last-name
                 .
            end. 
                  
        end.         /*  when 3 */
        
      end case.      /* case rs-scope */
    end. /*buf_init_user-account*/                               
END.                        
                                       
 
  /*вызов программы печати*/ 
  run prn-lib-reportviewer-report-name in this-procedure (
    input parParentProc
    ,input v-report-name-html-list
    ).

  for each tt-user-login no-lock:
                  put stream OutStr-html unformatted
                  substitute(
                  '<tr>
                            <td>&1</td>
                            <td>&2</td>
                            <td>&3</td>
                            <td>&4</td>
                            <td>&5</td>
                            <td>&6</td>
                   </tr>'
                  ,tt-user-login.users-id
                  ,tt-user-login.last-name
                  ,tt-user-login.nik
                  ,string(tt-user-login.db-num)
                  ,tt-user-login.user-login
                  ,if tt-user-login.last-login-mjd <> 0 then string(sys-time_mjd-to-loc-str-func(tt-user-login.last-login-mjd)) else ""
                  ).
          end.
        
         output stream OutStr-html close.   
END.         
EMPTY TEMP-TABLE tt-user-login .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-print-prava Dialog-Frame 
PROCEDURE proc-print-prava :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

  define buffer buf_user-login-action-role for ub.user-login-action-role .
  define buffer buf_action-role-item       for ub.action-role-item .
  define buffer buf_action-item            for ub.action-item .
  define buffer buf_action-role            for ub.action-role .
  define VARIABLE v-first as LOGICAL no-undo .
  define VARIABLE v-ok2 as LOGICAL no-undo .
  define VARIABLE ii      as integer no-undo .
  define VARIABLE jj      as integer no-undo .
  define VARIABLE v-action-role-context as character no-undo .
  define VARIABLE v-last-name as character no-undo.
  define VARIABLE v-last-name1 as character no-undo.
  define VARIABLE v-last-name2 as character no-undo.
  
do
on error undo, return error
:
            
  /*вызов процедуры печати шапки отчета*/      
  output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' /*no-convert*/.
  put stream OutStr-html unformatted
    substitute(
    '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       width: 850px; 
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="list_users" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:200px"></td>
                        <td style="width:200px"></td>
                        <td style="width:50px"></td>
                        <td style="width:200px"></td>
                        <td style="width:200px"></td>
                      </tr>
                      <tr>
                        <td colspan="5" style="font-size:16px;font-weight:bold; text-align: center;">Список прав пользователей</td>
                      </tr>
                    </thead>
                    <tbody> <!-- Здесь начинается таблица отчета -->
                      <tr> <!-- Первые строки – шапка таблицы с тэгами tr -->
                        <th style="text-align: center;">ФИО</th>
                        <th style="text-align: center;">Псевдоним</th>
                        <th style="text-align: center;">БД</th>
                        <th style="text-align: center;">Привязка</th>
                        <th style="text-align: center;">Группа</th>
                      </tr>'
    , chr(123), chr(125)
    ).

  /*печать тела*/

  get first br-user.
  
  do while available buf_init_user-account:
  assign ii = 0
         jj = 0
         v-first = no.
         v-last-name = buf_init_user-account.last-name + ' ' + buf_init_user-account.first-name + ' ' + buf_init_user-account.second-name .        

      for each buf_init_user-login where buf_init_user-login.user-id = buf_init_user-account.user-id:
          assign v-first = yes 
                 v-ok2 = no.
     
          FOR EACH buf_user-login-action-role
            WHERE buf_user-login-action-role.action-head-code    = {&action-head-code-main}
            AND buf_user-login-action-role.user-id             = buf_init_user-login.user-id
            NO-LOCK:


              if not v-action-gbl and buf_user-login-action-role.db-num              <> buf_init_user-login.db-num then next .
              
              find FIRST buf_action-role
                WHERE buf_action-role.action-head-code    = {&action-head-code-main}
                AND buf_action-role.action-role-code    = buf_user-login-action-role.action-role-code
                AND (buf_action-role.db-num              = buf_init_user-login.db-num OR buf_action-role.db-num = 0)
                AND (buf_init_user-login.db-num          = cb-db or string(cb-db) = '-1')
                NO-LOCK no-error.
                if AVAILABLE buf_action-role then do:
/*                  if not v-action-gbl and buf_action-role.db-num              <> buf_init_user-login.db-num then next .*/
                assign 
                  ii = ii + 1
                  jj = jj + 1 
                  v-ok2 = yes .
                  
                  if buf_user-login-action-role.action-role-context = {&cntxt-global} then do:
                  assign v-action-role-context = "Без привязки". end.
                  if buf_user-login-action-role.action-role-context = {&cntxt-firm} then do:
                  assign v-action-role-context = SUBSTITUTE("Фирма &1", string(buf_user-login-action-role.host-code)). end. 
                  if buf_user-login-action-role.action-role-context = {&cntxt-object} then do:
                  assign v-action-role-context = SUBSTITUTE("&1 &2", buf_user-login-action-role.obj-type, buf_user-login-action-role.obj-code). 
                  end.             
   



                put stream OutStr-html unformatted
                  substitute(
                  '<tr>
                            <td>&1</td>
                            <td>&2</td>
                            <td>&3</td>
                            <td>&4</td>
                            <td>&5</td>
                   </tr>'
                  , 
                  if ii > 1 or jj > 1 then "" else string(v-last-name),
                  if ii > 1 or jj > 1 then "" else string(buf_init_user-account.nik),
                  if ii > 1 or jj > 1 then "" else string(buf_init_user-login.db-num),
                  string(v-action-role-context),
                  string(buf_action-role.action-role-name)                                                              
                  ).
                  end.
                  else 
                  if (buf_init_user-login.db-num          = cb-db or string(cb-db) = '-1') then do:
                  put stream OutStr-html unformatted
                          substitute(
                          '<tr>
                                    <td>&1</td>
                                    <td>&2</td>
                                    <td>&3</td>
                                    <td></td>
                                    <td></td>
                           </tr>'
                          , 
                          if ii > 1 or jj > 1 then "" else string(v-last-name),
                          if ii > 1 or jj > 1 then "" else string(buf_init_user-account.nik),
                          if ii > 1 or jj > 1 then "" else string(buf_init_user-login.db-num)                                                      
                          ).
                  end.

          end. /*FOR EACH buf_user-login-action-role*/
          if v-ok2 = no and (buf_init_user-login.db-num = cb-db or string(cb-db) = '-1') then 
          do:  
            put stream OutStr-html unformatted
              substitute(
              '<tr>
                                            <td>&1</td>
                                            <td>&2</td>
                                            <td>&3</td>
                                            <td></td>
                                            <td></td>
                    </tr>'
              ,
              (v-last-name),
              (buf_init_user-account.nik),
              (buf_init_user-login.db-num)
              ).
    
          end. /*if v-ok2 = no then do*/

      end. /*for each buf_init_user-login where buf_init_user-login.user-id = buf_init_user-account.user-id: */  

      if v-first = no then do:
      put stream OutStr-html unformatted
        substitute(
        '<tr>
              <td>&1</td>
              <td>&2</td>
              <td></td>
              <td></td>
              <td></td>
        </tr>'
        ,
        (v-last-name),
        (buf_init_user-account.nik)
        ).
      end. /*if v-first = no then do:*/

    get next br-user. 
  end.
  
         output stream OutStr-html close.   
 


  /*вызов программы печати*/ 
  run prn-lib-reportviewer-report-name in this-procedure (
    input parParentProc
    ,input v-report-name-html
    ).


end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE procedure-get-person-name Dialog-Frame 
PROCEDURE procedure-get-person-name :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter p-psn-code    as integer   no-undo .
define output parameter p-person-name as character no-undo .

define buffer buf_person      for ub.person .
define buffer buf_clients     for ub.clients .

do
on error undo, return error return-value
:
    assign
        p-person-name = "":U
    .

    IF p-psn-code = ?
    THEN DO:
        assign
            p-person-name = "Нет привязки к физическому лицу"
        .
    END.
    ELSE DO:
      FIND FIRST buf_person
           WHERE buf_person.psn-code = p-psn-code
           no-lock
           no-error
           .
      FIND FIRST buf_clients
           WHERE buf_clients.obj-type = {&prs}
             AND buf_clients.obj-code = p-psn-code
           no-lock
           no-error
           .
      IF AVAILABLE buf_person
      THEN DO:
         assign
               p-person-name = SUBSTITUTE ( "&1 &2&3&4&5"
                                          , buf_clients.obj-name
                                          , IF buf_person.name1 <>"":U THEN SUBSTRING(buf_person.name1, 1, 1) ELSE "":U
                                          , IF buf_person.name1 <>"":U THEN ". " ELSE "":U
                                          , IF buf_person.name2 <>"":U THEN SUBSTRING(buf_person.name2, 1, 1) ELSE "":U
                                          , IF buf_person.name2 <>"":U THEN ". " ELSE "":U
                                          )
         .
      END.
      ELSE DO:
        assign
            p-person-name = SUBSTITUTE("Потеряна привязка к физ. лицу (&1)", p-psn-code)
        .
      END.
    END.
end.
END PROCEDURE.  /* procedure-get-person-name */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE procedure-user-login-action-role Dialog-Frame 
PROCEDURE procedure-user-login-action-role :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-db-num         as integer          no-undo.
define input parameter p-user-id        as character        no-undo.

    define variable v-user-adm as logical   no-undo .
do
on error undo, return error
:
    { gbl/user-adm.i
        p-db-num
        p-user-id
        v-user-adm
    }
    if v-user-adm
    then do:
         message "Пользователь - администратор. Ему доступны ВСЕ права." skip
                 "Добавление новых никак не скажется на его работе. Продолжить?" skip
                 view-as alert-box
                 buttons yes-no
                 update v-yes as logical
                 .
         if v-yes = yes
         then do:
            run str/useractn.w (
                  input parparentproc
                , input buf_init_user-account.user-id
                , input p-db-num
            ).
         end.
    end.
    else do:
        run str/useractn.w (
              input parparentproc
            , input buf_init_user-account.user-id
            , input p-db-num
        ).
    end.
end.
END PROCEDURE. /* procedure-user-login-action-role */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE procedure-user-login-copy Dialog-Frame 
PROCEDURE procedure-user-login-copy :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-db-num         as integer          no-undo.
define input parameter p-user-id        as character        no-undo.

  define variable v-can-edit as logical   no-undo .

  define buffer buf_user-account    for user-account.
  define buffer buf_user-login      for ub.user-login .
do
for buf_user-account
  , buf_user-login
on error undo, return error return-value
:
  find first buf_user-account no-lock
    where buf_user-account.user-id = p-user-id
    no-error.
  if available (buf_user-account) then 
  do:
    if buf_user-account.status_ = {&bef-user-status-deleted} then 
    do:
      message "Пользователь удален. Копирование логина невозможно"
        view-as alert-box.
      return no-apply .
    end.
  end.   
    do transaction
    on error undo, return error return-value
    :       /* блокируем логин пользователя */
        find first buf_user-login exclusive-lock
             where buf_user-login.db-num  = p-db-num
               and buf_user-login.user-id = p-user-id
        no-error no-wait.
        if not available buf_user-login
        then do:
            if locked( buf_user-login )
            then do:
                find first buf_user-login no-lock
                     where buf_user-login.db-num  = p-db-num
                       and buf_user-login.user-id = p-user-id
                .
                find first buf_user-account no-lock
                     where buf_user-account.user-id = p-user-id
                .
                message
                    "Редактирование логина невозможно" skip
                    "Пользователь в данный момент работает в системе" skip
                    "БД" p-db-num skip
                    "Идентификатор" p-user-id skip
                    "Псевдоним"                    buf_user-account.nik skip
                    "Имя пользователя"             buf_user-account.last-name buf_user-account.first-name buf_user-account.second-name skip
                    "Компьютер"                    buf_user-login.last-login-computer-name skip
                    "Пользователь компьютера"      buf_user-login.last-login-computer-user skip
                    "TCP имя компьютера"           buf_user-login.last-login-computer-tcp-name skip
                    "IP адрес компьютера"          buf_user-login.last-login-computer-ip-addr skip
                    "Идентификатор процесса"       buf_user-login.last-login-process-id skip
                    "Номер подключения к БД"       buf_user-login.last-login-connection-id skip
                    "Дата и время входа в систему" sys-time_mjd-to-loc-str-func(buf_user-login.last-login-mjd) skip
                view-as alert-box error .
            end.
            else do:
                message
                    "Редактирование логина невозможно" skip
                    "У пользователя нет логина" skip
                    "БД" p-db-num skip
                    "Идентификатор" buf_init_user-account.user-id skip
                view-as alert-box error .
            end.
            undo, return error return-value .
        end.
    end.

    define variable v-update-data        as logical   no-undo .
    define variable v-user-login         as character no-undo .
    define variable v-user-administrator as logical   no-undo .
    define variable v-max-discnt         as decimal   no-undo .
    define variable v-quest-print        as logical   no-undo .
    define variable v-tmp-dbnum          as integer   no-undo .
    define variable v-list-db            as character no-undo .
    define variable v-success            as logical   no-undo .
    
    /* редактирование логина пользователя */
    v-tmp-dbnum = buf_user-login.db-num.
    run str/usrloged2.w (
          input parparentproc
        , input {&update}
        , input-output v-tmp-dbnum
        , input buf_user-login.user-id
        , input buf_user-login.user-login
        , input buf_user-login.user-administrator
        , input buf_user-login.max-discnt
        , input buf_user-login.quest-print
        , output v-list-db
        , output v-update-data
        , output v-user-login
        , output v-user-administrator
        , output v-max-discnt
        , output v-quest-print
    ) .
    if v-list-db = "" then
       return.

/*копируем логин в выбранные базы*/            
           run str/copy-login.p (
              input buf_user-login.user-id
            , input v-user-login  
            , input p-db-num
            , input v-list-db
            , output v-success
        ) no-error.
        if error-status :error
        then do:
            message
                        vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка копирования логина."
                skip return-value
                skip trim( error-status :get-message( 1 ) )
                        trim( error-status :get-message( 2 ) )
                        trim( error-status :get-message( 3 ) )
            view-as alert-box error.
            undo, return no-apply.
        end.
end.
END PROCEDURE. /* procedure-user-login-copy */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE procedure-user-login-create Dialog-Frame 
PROCEDURE procedure-user-login-create :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input  parameter iMode       as character no-undo.
define input  parameter p-db-num     as integer          no-undo.
define input  parameter p-user-id    as character        no-undo.

define input  parameter i-adm-gbd    as logical no-undo.
define input  parameter i-adm-ubd    as logical no-undo.
define input  parameter i-TabUserAdm as handle no-undo.
define output parameter p-created    as logical          no-undo.


    define variable v-update-data           as logical      no-undo .
    define variable v-user-login            as character    no-undo .
    define variable v-user-administrator    as logical      no-undo .
    define variable v-max-discnt            as decimal      no-undo .
    define variable v-quest-print           as logical      no-undo .
    define variable v-encoded-pass          as character    no-undo .
    define variable v-nextcon               as logical      no-undo init ? .

    define buffer buf_user-account      for user-account.
    define buffer buf_user-login        for user-login  .
    
    if imode eq {&update}
    then do:
       find first buf_user-login where  buf_user-login.user-id            = p-user-id
                                   and  buf_user-login.db-num             = p-db-num
       no-lock no-error.
       if available buf_user-login
       then do:
          assign
             v-user-login         = buf_user-login.user-login
             v-user-administrator = buf_user-login.user-administrator
             v-max-discnt         = buf_user-login.max-discnt
             v-quest-print        = buf_user-login.quest-print
             v-encoded-pass       = buf_user-login.user-password-encoded
          .
          find first user-login-attr where user-login-attr.db-num    = buf_user-login.db-num
                                       and user-login-attr.user-id   = buf_user-login.user-id
                                       and user-login-attr.attr-code = "ChangPwdNextConect"
          no-lock no-error.
          v-nextcon = if available user-login-attr then logical(user-login-attr.attr-value) else ? no-error.             
          p-created            = i-adm-gbd ne ? or i-adm-ubd ne ? or i-TabUserAdm ne ?.
       
       end.
       else do:
          find first buf_user-login where  buf_user-login.user-id            = p-user-id
          no-lock no-error.
          if available buf_user-login
          then do:
             assign
                v-user-login         = buf_user-login.user-login
                v-max-discnt         = buf_user-login.max-discnt
                v-quest-print        = buf_user-login.quest-print
                v-encoded-pass       = buf_user-login.user-password-encoded
             .
             find first user-login-attr where user-login-attr.db-num    = buf_user-login.db-num
                                          and user-login-attr.user-id   = buf_user-login.user-id
                                          and user-login-attr.attr-code = "ChangPwdNextConect"
             no-lock no-error.
             v-nextcon = if available user-login-attr then logical(user-login-attr.attr-value) else ? no-error.             
          
             p-created            = i-adm-gbd ne ? or i-adm-ubd ne ? or i-TabUserAdm ne ?.
         end.
         else do:
            p-db-num = ?.
            run str/usrloged.w (
                   input parparentproc
                 , input {&update}
                 , input-output p-db-num
                 , input p-user-id
                 , input "":U
                 , input false
                 , input 0
                 , input true
                 , output p-created
                 , output v-user-login
                 , output v-user-administrator
                 , output v-max-discnt
                 , output v-quest-print
             ) .
             imode = "{&add-def}". /* Подменим мод так как пользователь редактировался, а логинов нет */
          end.
       end.
    end.
    else
       run str/usrloged.w (
             input parparentproc
           , input {&update}
           , input-output p-db-num
           , input p-user-id
           , input "":U
           , input false
           , input 0
           , input true
           , output p-created
           , output v-user-login
           , output v-user-administrator
           , output v-max-discnt
           , output v-quest-print
       ) .
    if p-created = yes
    then do:        /* сохранение данных в базу отдельной транзакцией */
       if imode ne {&update}
       then do:
          set-correct-password:
          do while yes
          :
             find first buf_user-account no-lock
                  where buf_user-account.user-id = p-user-id
             .
             define variable voneadm as logical no-undo.
             run availOneAdm(input-output table-handle i-TabUserAdm, output voneadm).
             run adm/chg-pswd.w (
                   input parparentproc
                   , input p-db-num
                   , input p-user-id
                   , input v-user-login
                   , input substitute('&1 &2 &3':U,  buf_user-account.last-name
                                                   , buf_user-account.first-name
                                                   , buf_user-account.second-name
                           )
                   , input yes
                   , input yes
                   , input ""
                   , no
                   , i-adm-gbd or i-adm-ubd or voneadm
                   , output v-encoded-pass
                   , output v-nextcon
             ) no-error .
             if error-status :error
             then do:
                message
                   vss-workfile vss-revision vss-description
                       skip(1)
                       skip "Ошибка при назначении пароля"
                       skip return-value
                       skip trim( error-status :get-message( 1 ) )
                           trim( error-status :get-message( 2 ) )
                           trim( error-status :get-message( 3 ) )
                view-as alert-box error.
                undo, return error.
             end.
             if    v-encoded-pass = "":U
                or v-encoded-pass = ?
             then do:
                message
                       "Пароль пользователя не может быть пустым."
                       skip "Введите пароль."
                view-as alert-box warning
                    title "Ввод пароля".
             end.
             else do:
                leave set-correct-password.
             end.
          end.
       end.
       run update-user-login(p-db-num
                            ,p-user-id
                            ,v-user-login
                            ,v-max-discnt
                            ,v-quest-print
                            ,v-encoded-pass
                            ,v-nextcon
                            ,v-user-administrator 
                            ,mSuperAdm and imode ne "add" /* когда добавление одного логина не может быть ручного ввода */
                            ,i-adm-gbd
                            ,i-adm-ubd
                            ,input-output table-handle i-TabUserAdm) no-error.
       if error-status:error
       then do: 
          message return-value
          view-as alert-box.
          return error.
       end.
       
    end.
END PROCEDURE. /* procedure-user-login-create */


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE procedure-user-login-edit Dialog-Frame 
PROCEDURE procedure-user-login-edit :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-db-num         as integer          no-undo.
define input parameter p-user-id        as character        no-undo.

  define variable v-can-edit as logical   no-undo .

  define buffer buf_user-account    for user-account.
  define buffer buf_user-login      for ub.user-login .
do
for buf_user-account
  , buf_user-login
on error undo, return error return-value
:
    run can-edit-login in this-procedure (
          input p-db-num
        , output v-can-edit
    ) .
    if v-can-edit <> true
    then do:
        message
            "Нельзя редактировать логин пользователя для базы" p-db-num
        view-as alert-box error .
        undo, return error return-value .
    end.
    do :       /* блокируем логин пользователя */
        find first buf_user-login exclusive-lock
             where buf_user-login.db-num  = p-db-num
               and buf_user-login.user-id = p-user-id
        no-error no-wait.
        if not available buf_user-login
        then do:
            if locked( buf_user-login )
            then do:
                find first buf_user-login no-lock
                     where buf_user-login.db-num  = p-db-num
                       and buf_user-login.user-id = p-user-id
                .
                find first buf_user-account no-lock
                     where buf_user-account.user-id = p-user-id
                .
                message
                    "Редактирование логина невозможно" skip
                    "Пользователь в данный момент работает в системе" skip
                    "БД" p-db-num skip
                    "Идентификатор" p-user-id skip
                    "Псевдоним"                    buf_user-account.nik skip
                    "Имя пользователя"             buf_user-account.last-name buf_user-account.first-name buf_user-account.second-name skip
                    "Компьютер"                    buf_user-login.last-login-computer-name skip
                    "Пользователь компьютера"      buf_user-login.last-login-computer-user skip
                    "TCP имя компьютера"           buf_user-login.last-login-computer-tcp-name skip
                    "IP адрес компьютера"          buf_user-login.last-login-computer-ip-addr skip
                    "Идентификатор процесса"       buf_user-login.last-login-process-id skip
                    "Номер подключения к БД"       buf_user-login.last-login-connection-id skip
                    "Дата и время входа в систему" sys-time_mjd-to-loc-str-func(buf_user-login.last-login-mjd) skip
                view-as alert-box error .
            end.
            else do:
                message
                    "Редактирование логина невозможно" skip
                    "У пользователя нет логина" skip
                    "БД" p-db-num skip
                    "Идентификатор" buf_init_user-account.user-id skip
                view-as alert-box error .
            end.
            undo, return error return-value .
        end.
    end.
    define variable v-update-data        as logical   no-undo .
    define variable v-user-login         as character no-undo .
    define variable v-user-administrator as logical   no-undo .
    define variable v-max-discnt         as decimal   no-undo .
    define variable v-quest-print        as logical   no-undo .
    define variable v-tmp-dbnum          as integer   no-undo .
    
    /* редактирование логина пользователя */
    /* запись захвачена и не может быть изменена */
    v-tmp-dbnum = buf_user-login.db-num.
    run str/usrloged.w (
          input parparentproc
        , input {&update}
        , input-output v-tmp-dbnum
        , input buf_user-login.user-id
        , input buf_user-login.user-login
        , input buf_user-login.user-administrator
        , input buf_user-login.max-discnt
        , input buf_user-login.quest-print
        , output v-update-data
        , output v-user-login
        , output v-user-administrator
        , output v-max-discnt
        , output v-quest-print
     ) .
    if v-tmp-dbnum = ? then
       return.
    assign
        buf_user-login.db-num = v-tmp-dbnum
        p-db-num = buf_user-login.db-num.
    if v-update-data = true
    then do:        /* сохранение данных в базу отдельной транзакцией */
            /* здесь ошибки быть не может */
            /* запись была найдена и захвачена чуть выше */
            find first buf_user-login exclusive-lock
                 where buf_user-login.db-num  = p-db-num
                   and buf_user-login.user-id = p-user-id
            .
            assign
            buf_user-login.user-login         = v-user-login
            buf_user-login.user-administrator = v-user-administrator
            buf_user-login.max-discnt         = v-max-discnt
            buf_user-login.quest-print        = v-quest-print
            .
        end.
    end.

END PROCEDURE. /* procedure-user-login-edit */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE procedure-user-login-menu-group Dialog-Frame 
PROCEDURE procedure-user-login-menu-group :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-db-num         as integer          no-undo.
define input parameter p-user-id        as character        no-undo.

    define variable v-can-edit as logical   no-undo .
    define variable v-user-adm as logical   no-undo .

    define buffer buf_user-login    for ub.user-login .
    define buffer buf_user-account  for user-account.
do
for buf_user-login
on error undo, return error
:
      { gbl/user-adm.i
        p-db-num
        p-user-id
        v-user-adm
      }
      if v-user-adm = yes
      then do:
         message "Пользователь - администратор. Ему доступны ВСЕ группы меню." skip
                 "Добавление новых никак не скажется на его работе. Продолжить?" skip
                 view-as alert-box
                 buttons yes-no
                 update v-yes as logical
                 .
         if v-yes = no
         then do:
            return.
         end.
      end.
      do transaction
      on error undo, return error return-value
      :
        /* блокируем логин пользователя */
        find first buf_user-login exclusive-lock
             where buf_user-login.db-num  = p-db-num
               and buf_user-login.user-id = p-user-id
        no-error no-wait.
        if not available buf_user-login
        then do:
          if locked( buf_user-login )
          then do:
                find first buf_user-login no-lock
                     where buf_user-login.db-num  = p-db-num
                       and buf_user-login.user-id = p-user-id
                .
                find first buf_user-account no-lock
                     where buf_user-account.user-id = p-user-id
                .
                message
                "Редактирование логина невозможно" skip
                "Пользователь в данный момент работает в системе" skip
                "БД" p-db-num skip
                "Идентификатор"                p-user-id skip
                "Псевдоним"                    buf_user-account.nik skip
                "Имя пользователя"             buf_user-account.last-name buf_user-account.first-name buf_user-account.second-name skip
                "Компьютер"                    buf_user-login.last-login-computer-name skip
                "Пользователь компьютера"      buf_user-login.last-login-computer-user skip
                "TCP имя компьютера"           buf_user-login.last-login-computer-tcp-name skip
                "IP адрес компьютера"          buf_user-login.last-login-computer-ip-addr skip
                "Идентификатор процесса"       buf_user-login.last-login-process-id skip
                "Номер подключения к БД"       buf_user-login.last-login-connection-id skip
                "Дата и время входа в систему" sys-time_mjd-to-loc-str-func( buf_user-login.last-login-mjd ) skip
                view-as alert-box error .
          end.
          else do:
            message
              "Редактирование логина невозможно" skip
              "У пользователя нет логина" skip
              "БД" p-db-num skip
              "Идентификатор" p-user-id skip
              view-as alert-box error .
          end.
          undo, return error return-value .
        end.
      end.

      run str/usrmngr.w (
          input parparentproc
        , input p-db-num
        , input p-user-id
        , input {&menu-code-main}
      ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры" 'str/usrmngr.w':U skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
end.
END PROCEDURE. /* procedure-user-login-menu-group */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE procedure-user-login-user-host Dialog-Frame 
PROCEDURE procedure-user-login-user-host :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-db-num         as integer          no-undo.
define input parameter p-user-id        as character        no-undo.

  define variable v-current-host-code    as integer      no-undo.
  define variable v-user-select      as logical   no-undo .
  /* Для совместимости - список выбранных host-code  */
  DEFINE VARIABLE v-List-select-host-code AS CHARACTER NO-UNDO INITIAL "".

do
on error undo, return error
:
    run gbl/userhsts.w
      (input  parparentproc          /* parparentproc      */
      ,input  this-procedure :handle /* p-callback-handle  */
      ,input  p-db-num               /* p-db-num           */
      ,input  p-user-id              /* p-user-id          */
      ,input  v-cntxt-host-code-obj  /* p-curr-host-code   */
      ,input  IF v-only-lookup THEN "":U ELSE "b-add"                /* b-bttns            */
      ,output v-user-select          /* p-user-select      */
      ,output v-current-host-code    /* p-select-host-code */
      ,OUTPUT v-List-Select-host-code /* v-List-Select-host-code */
      ) .
end.
END PROCEDURE. /* procedure-user-login-user-host */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE procedure-user-login-user-obj Dialog-Frame 
PROCEDURE procedure-user-login-user-obj :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-db-num         as integer          no-undo.
define input parameter p-user-id        as character        no-undo.

    define variable v-user-select        as logical   no-undo .
    define variable v-select-obj-type    as character no-undo .
    define variable v-select-obj-code    as integer   no-undo .
do
on error undo, return error
:
    run gbl/userobjs.w (
          input parparentproc           /* parparentproc        */
        , input this-procedure :handle  /* p-callback-handle    */
        , input p-db-num                /* p-db-num             */
        , input p-user-id               /* p-user-id            */
        , input v-cntxt-host-code-obj   /* p-curr-host-code-obj */
        , input v-cntxt-obj-type        /* p-curr-obj-type      */
        , input v-cntxt-obj-code        /* p-curr-obj-code      */
        , input IF v-only-lookup THEN "":U ELSE "b-add":U               /* p-bttn               */
        , output v-user-select          /* p-user-select        */
        , output v-select-obj-type      /* p-select-obj-type    */
        , output v-select-obj-code      /* p-select-obj-code    */
      ).
end.
END PROCEDURE. /* procedure-user-login-user-obj */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-position Dialog-Frame 
PROCEDURE save-position :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define variable v-current-rowid    as rowid        no-undo.
    define variable v-current-focus    as integer      no-undo.

do
with frame {&frame-name}
on error undo, return error
:
    if available buf_init_user-account
    then do:
        assign
            v-current-rowid = rowid( buf_init_user-account )
            v-current-focus = br-user :focused-row in frame {&FRAME-NAME}
        .
        run uf-set (
              input {&uf-users-1}
            , input v-cntxt-userid
            , input string( rs-scope )
            , input string( cb-db )
            , input no
            , input no
            , input no
            , input no
        ) .
        run uf-set (
              input {&uf-users-2}
            , input v-cntxt-userid
            , input string( v-current-focus )
            , input string( v-current-rowid )
            , input no
            , input no
            , input no
            , input no
        ) .
    end.
end.
END PROCEDURE. /* save-position */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-person-name Dialog-Frame 
FUNCTION get-person-name RETURNS CHARACTER
  ( p-psn-code as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

  define variable v-person-name as character no-undo .

  run procedure-get-person-name in this-procedure (
      input p-psn-code
    , output v-person-name
  ) .
  return v-person-name .

END FUNCTION. /* get-person-name */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

