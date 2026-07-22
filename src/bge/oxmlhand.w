&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME oxmlhand


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_esys-pck-rcvd FOR esys-pck-rcvd.
DEFINE BUFFER X_esys-pck-sent FOR esys-pck-sent.
DEFINE BUFFER X_ext-system FOR ext-system.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS oxmlhand 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ручной режим работы OpenXML

Автор: Хныкин Павел Андреевич
Дата создания: 11/29/06
Author: Pavel Khnykin
Creation date: 11/29/06

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parparentproc as widget-handle  no-undo.
define input  parameter p-log-handle as handle  no-undo.
define input  parameter p-user-login    as character no-undo .
define input  parameter p-user-password as character no-undo .

/* Local Variable Definitions ---                                       */


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Ручной режим работы OpenXML".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/showinf.i  }
&global-define tab-shift 2
{ bge/oxml-def.i }


define variable log-res as logical no-undo .
define variable v-db-num as integer no-undo .
define variable v-key-passed-date as date no-undo .
define variable v-imp-err as character no-undo .
define buffer buf_db for ub.db .
define buffer buf_ext-system for ub.ext-system .
define buffer buf_sys-ctrl for ub.sys-ctrl.

&scop test-esys if not available X_ext-system then do: ~
                message ~
                  "Не выбрана ВС." ~
                  view-as alert-box information. ~
                return no-apply. ~
              end. ~
              find first buf_ext-system no-lock ~
                where buf_ext-system.esys-id = X_ext-system.esys-id ~
                   and  buf_ext-system.db-num = X_ext-system.db-num ~
                no-error . ~
              if not available buf_ext-system then do: ~
                message ~
                  substitute( "ВС &1 удалена.", X_ext-system.esys-id ) ~
                  view-as alert-box information. ~
                run refresh-brws ~
                  ( input yes ) . ~
                return no-apply. ~
              end. ~

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME oxmlhand
&Scoped-define BROWSE-NAME br-esys

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_ext-system X_esys-pck-rcvd X_esys-pck-sent

/* Definitions for BROWSE br-esys                                       */
&Scoped-define FIELDS-IN-QUERY-br-esys X_ext-system.esys-id (X_ext-system.esys-type > integer({&openxml-type-ordinal})) (X_ext-system.esys-have-export and X_ext-system.esys-db-num-exp = v-db-num) (X_ext-system.esys-have-import and X_ext-system.esys-db-num-imp = v-db-num) X_ext-system.esys-name /*X_ext-system.db-num*/   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-esys   
&Scoped-define SELF-NAME br-esys
&Scoped-define QUERY-STRING-br-esys FOR EACH X_ext-system NO-LOCK by X_ext-system.esys-id    INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-esys OPEN QUERY br-esys FOR EACH X_ext-system NO-LOCK by X_ext-system.esys-id    INDEXED-REPOSITION .
&Scoped-define TABLES-IN-QUERY-br-esys X_ext-system
&Scoped-define FIRST-TABLE-IN-QUERY-br-esys X_ext-system


/* Definitions for BROWSE pck-rcvd                                      */
&Scoped-define FIELDS-IN-QUERY-pck-rcvd X_esys-pck-rcvd.espr-pack-num X_esys-pck-rcvd.espr-rcvd v-imp-err X_esys-pck-rcvd.espr-total-recs X_esys-pck-rcvd.custom-pack-name   
&Scoped-define ENABLED-FIELDS-IN-QUERY-pck-rcvd   
&Scoped-define SELF-NAME pck-rcvd
&Scoped-define QUERY-STRING-pck-rcvd FOR EACH X_esys-pck-rcvd       WHERE X_esys-pck-rcvd.esys-id = X_ext-system.esys-id       and X_esys-pck-rcvd.db-num = X_ext-system.db-num  NO-LOCK     BY X_esys-pck-rcvd.esys-id DESCENDING     BY X_esys-pck-rcvd.db-num DESCENDING     BY X_esys-pck-rcvd.espr-cr-db-num DESCENDING     BY X_esys-pck-rcvd.espr-pack-num DESCENDING INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-pck-rcvd OPEN QUERY {&SELF-NAME} FOR EACH X_esys-pck-rcvd       WHERE X_esys-pck-rcvd.esys-id = X_ext-system.esys-id       and X_esys-pck-rcvd.db-num = X_ext-system.db-num  NO-LOCK     BY X_esys-pck-rcvd.esys-id DESCENDING     BY X_esys-pck-rcvd.db-num DESCENDING     BY X_esys-pck-rcvd.espr-cr-db-num DESCENDING     BY X_esys-pck-rcvd.espr-pack-num DESCENDING INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-pck-rcvd X_esys-pck-rcvd
&Scoped-define FIRST-TABLE-IN-QUERY-pck-rcvd X_esys-pck-rcvd


/* Definitions for BROWSE pck-sent                                      */
&Scoped-define FIELDS-IN-QUERY-pck-sent X_esys-pck-sent.esps-pack-num X_esys-pck-sent.esps-rcvd X_esys-pck-sent.esps-total-recs X_esys-pck-sent.custom-pack-name   
&Scoped-define ENABLED-FIELDS-IN-QUERY-pck-sent   
&Scoped-define SELF-NAME pck-sent
&Scoped-define QUERY-STRING-pck-sent FOR EACH X_esys-pck-sent
&Scoped-define OPEN-QUERY-pck-sent OPEN QUERY pck-sent FOR EACH X_esys-pck-sent.
&Scoped-define TABLES-IN-QUERY-pck-sent X_esys-pck-sent
&Scoped-define FIRST-TABLE-IN-QUERY-pck-sent X_esys-pck-sent


/* Definitions for DIALOG-BOX oxmlhand                                  */
&Scoped-define OPEN-BROWSERS-IN-QUERY-oxmlhand ~
    ~{&OPEN-QUERY-br-esys}~
    ~{&OPEN-QUERY-pck-sent}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-create b-packlist b-help br-esys ~
pck-sent b-send b-send-all b-conf-pck b-info pck-rcvd b-imp-err b-get-pck ~
b-send-new b-unsend b-get b-proc-pck b-other oxml-log 
&Scoped-Define DISPLAYED-OBJECTS oxml-log 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-other 
       MENU-ITEM m_send-ora-rcpt LABEL "Квитанц. для ВС типа Oracle Retail".


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-conf-pck DEFAULT 
     LABEL "Под&тверд." 
     SIZE 10 BY 1 TOOLTIP "Подтвердить пакет".

DEFINE BUTTON b-create DEFAULT 
     LABEL "Под&готовить новые" 
     SIZE 20 BY 1 TOOLTIP "Подготовка новых пакетов для всех ВС"
     BGCOLOR 8 .

DEFINE BUTTON b-get DEFAULT 
     LABEL "При&нять" 
     SIZE 10 BY 1 TOOLTIP "Принять почту не разбирая пакет".

DEFINE BUTTON b-get-pck DEFAULT 
     LABEL "&Принять/Разобрать" 
     SIZE 20 BY 1 TOOLTIP "Принять и затем разобрать пришедшую почту".

DEFINE BUTTON b-help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-imp-err DEFAULT 
     LABEL "&Ошибки" 
     SIZE 10 BY 1 TOOLTIP "Ошибки импорта по пакету".

DEFINE BUTTON b-info DEFAULT 
     LABEL "&Доп.инфо" 
     SIZE 10 BY 1 TOOLTIP "Дополнительная информация о пакете".

DEFINE BUTTON b-other DEFAULT 
     LABEL "&Другое" 
     SIZE 10 BY 1 TOOLTIP "Другие действия".

DEFINE BUTTON b-packlist DEFAULT 
     LABEL "&Сообщения" 
     SIZE 16 BY 1 TOOLTIP "Список соббщений в отправленном пакете".

DEFINE BUTTON b-proc-pck DEFAULT 
     LABEL "&Разобрать" 
     SIZE 10 BY 1 TOOLTIP "Только разобрать пакет, не принимая новых".

DEFINE BUTTON b-quit AUTO-GO DEFAULT 
     LABEL "Вы&ход " 
     SIZE 10 BY 1 TOOLTIP "Выход из новостей"
     BGCOLOR 8 .

DEFINE BUTTON b-send DEFAULT 
     LABEL "&Отправить" 
     SIZE 10 BY 1 TOOLTIP "Отправить конкретный пакет с его переформированием".

DEFINE BUTTON b-send-all DEFAULT 
     LABEL "Отпр. в&cе" 
     SIZE 10 BY 1 TOOLTIP "Отправить все неподтвержденные пакеты с их переформированием".

DEFINE BUTTON b-send-new DEFAULT 
     LABEL "Отпр&авить новые" 
     SIZE 20 BY 1 TOOLTIP "Отправка новых и некоторых неподтвержденных пакетов"
     BGCOLOR 8 .

DEFINE BUTTON b-unsend DEFAULT 
     LABEL "&Данные" 
     SIZE 10 BY 1 TOOLTIP "Неотправленнная или неподтвержденая информация".

DEFINE VARIABLE oxml-log AS CHARACTER INITIAL ? 
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL LARGE
     SIZE 98 BY 6 TOOLTIP "Просмотр файла с сообщениями о работе OpenXML"
     FONT 4 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-esys FOR 
      X_ext-system SCROLLING.

DEFINE QUERY pck-rcvd FOR 
      X_esys-pck-rcvd SCROLLING.

DEFINE QUERY pck-sent FOR 
      X_esys-pck-sent SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-esys
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-esys oxmlhand _FREEFORM
  QUERY br-esys DISPLAY
      X_ext-system.esys-id column-label "ВС"
(X_ext-system.esys-type > integer({&openxml-type-ordinal})) column-label "Спец" format "+/"
(X_ext-system.esys-have-export and X_ext-system.esys-db-num-exp = v-db-num)  column-label "Экспорт!в тек.БД" format "+/"
(X_ext-system.esys-have-import and X_ext-system.esys-db-num-imp = v-db-num)  column-label "Импорт!в тек.БД" format "+/"
X_ext-system.esys-name
/*X_ext-system.db-num*/
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 50 BY 14.52 FIT-LAST-COLUMN TOOLTIP "Рабочие ВС".

DEFINE BROWSE pck-rcvd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS pck-rcvd oxmlhand _FREEFORM
  QUERY pck-rcvd NO-LOCK DISPLAY
      X_esys-pck-rcvd.espr-pack-num COLUMN-LABEL "Номер" FORMAT ">>>>>>9":U
      X_esys-pck-rcvd.espr-rcvd COLUMN-LABEL "Подтв." FORMAT "yes/no":U
      v-imp-err COLUMN-LABEL "Ош." FORMAT "X(1)":U
      X_esys-pck-rcvd.espr-total-recs COLUMN-LABEL "Записей в пакете" FORMAT ">>>>>>>>>9":U
  X_esys-pck-rcvd.custom-pack-name COLUMN-LABEL "Имя пакета в ВС" FORMAT "X(255)":U WIDTH 30
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ASSIGN NO-ROW-MARKERS SEPARATORS SIZE 46.6 BY 6.52
         FONT 4
         TITLE "Полученные пакеты" FIT-LAST-COLUMN TOOLTIP "Полученные пакеты от данной ВС".

DEFINE BROWSE pck-sent
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS pck-sent oxmlhand _FREEFORM
  QUERY pck-sent NO-LOCK DISPLAY
      X_esys-pck-sent.esps-pack-num COLUMN-LABEL "Номер" FORMAT ">>>>>>9":U
      X_esys-pck-sent.esps-rcvd COLUMN-LABEL "Подтв." FORMAT "yes/no":U
      X_esys-pck-sent.esps-total-recs COLUMN-LABEL "Записей в пакете" FORMAT ">>>>>>>>>9":U
      X_esys-pck-sent.custom-pack-name COLUMN-LABEL "Имя пакета в ВС" FORMAT "X(255)":U WIDTH 30
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ASSIGN NO-ROW-MARKERS SEPARATORS SIZE 46.6 BY 7
         FONT 4
         TITLE "Отправленные пакеты" FIT-LAST-COLUMN TOOLTIP "Отправленные пакеты в данную ВС".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME oxmlhand
     b-quit AT ROW 1 COL 1
     b-create AT ROW 1 COL 11
     b-packlist AT ROW 1 COL 77 WIDGET-ID 6
     b-help AT ROW 1 COL 95
     br-esys AT ROW 2 COL 1
     pck-sent AT ROW 2 COL 52
     b-send AT ROW 9 COL 52
     b-send-all AT ROW 9 COL 62
     b-conf-pck AT ROW 9 COL 72 WIDGET-ID 2
     b-info AT ROW 9 COL 86.8
     pck-rcvd AT ROW 10 COL 52 WIDGET-ID 100
     b-imp-err AT ROW 16.48 COL 87 WIDGET-ID 8
     b-get-pck AT ROW 16.52 COL 1
     b-send-new AT ROW 16.52 COL 21
     b-unsend AT ROW 16.52 COL 41
     b-get AT ROW 16.52 COL 52
     b-proc-pck AT ROW 16.52 COL 62
     b-other AT ROW 16.52 COL 72 WIDGET-ID 4
     oxml-log AT ROW 17.52 COL 1 NO-LABEL
     SPACE(0.29) SKIP(0.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_esys-pck-rcvd B "?" ? ub esys-pck-rcvd
      TABLE: X_esys-pck-sent B "?" ? ub esys-pck-sent
      TABLE: X_ext-system B "?" ? ub ext-system
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX oxmlhand
   FRAME-NAME                                                           */
/* BROWSE-TAB br-esys b-help oxmlhand */
/* BROWSE-TAB pck-sent br-esys oxmlhand */
/* BROWSE-TAB pck-rcvd b-info oxmlhand */
ASSIGN 
       FRAME oxmlhand:SCROLLABLE       = FALSE.

ASSIGN 
       b-other:POPUP-MENU IN FRAME oxmlhand       = MENU MENU-b-other:HANDLE.

ASSIGN 
       oxml-log:READ-ONLY IN FRAME oxmlhand        = TRUE.

ASSIGN 
       pck-rcvd:HIDDEN  IN FRAME oxmlhand                = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-esys
/* Query rebuild information for BROWSE br-esys
     _START_FREEFORM
OPEN QUERY br-esys FOR EACH X_ext-system NO-LOCK by X_ext-system.esys-id    INDEXED-REPOSITION .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-esys */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX oxmlhand
/* Query rebuild information for DIALOG-BOX oxmlhand
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX oxmlhand */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE pck-rcvd
/* Query rebuild information for BROWSE pck-rcvd
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_esys-pck-rcvd
      WHERE X_esys-pck-rcvd.esys-id = X_ext-system.esys-id
      and X_esys-pck-rcvd.db-num = X_ext-system.db-num  NO-LOCK
    BY X_esys-pck-rcvd.esys-id DESCENDING
    BY X_esys-pck-rcvd.db-num DESCENDING
    BY X_esys-pck-rcvd.espr-cr-db-num DESCENDING
    BY X_esys-pck-rcvd.espr-pack-num DESCENDING INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _OrdList          = "ub.pck-rcvd.db-num|no,ub.pck-rcvd.pack-num|no"
     _Where[1]         = "ub.pck-rcvd.db-num = ub.db.db-num "
     _Query            is NOT OPENED
*/  /* BROWSE pck-rcvd */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE pck-sent
/* Query rebuild information for BROWSE pck-sent
     _START_FREEFORM
OPEN QUERY pck-sent FOR EACH X_esys-pck-sent
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _OrdList          = "ub.pck-sent.db-num|no,ub.pck-sent.pack-num|no"
     _Where[1]         = "pck-sent.db-num = ub.db.db-num"
     _Query            is OPENED
*/  /* BROWSE pck-sent */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME oxmlhand
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL oxmlhand oxmlhand
ON WINDOW-CLOSE OF FRAME oxmlhand
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-conf-pck
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-conf-pck oxmlhand
ON CHOOSE OF b-conf-pck IN FRAME oxmlhand /* Подтверд. */
DO:
    {&test-esys}

    if not available X_esys-pck-sent THEN do:
        message "Нет готовых пакетов." view-as alert-box .
        return no-apply.
    end.

   run bge/confepck.p (  INPUT parparentproc
                        ,INPUT p-log-handle
                        ,input log-file-name
                        ,INPUT NO /*p-silent*/
                        ,INPUT X_esys-pck-sent.esys-id
                        ,INPUT X_esys-pck-sent.db-num
                        ,INPUT X_esys-pck-sent.esps-cr-db-num
                        ,INPUT X_esys-pck-sent.esps-pack-num) NO-ERROR.
   IF ERROR-STATUS:ERROR THEN DO:
      MESSAGE
      ERROR-STATUS:get-message(1) SKIP
      RETURN-VALUE
      VIEW-AS ALERT-BOX.

   END.
   run refresh-brws in this-procedure ( input yes ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-create
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-create oxmlhand
ON CHOOSE OF b-create IN FRAME oxmlhand /* Подготовить новые */
DO:

  define variable v-message  as character no-undo .
  define variable v-err-code as integer   no-undo .

  run write-to-log ( substitute( "Подготовка новых пакетов." ) ).

  run bge/cnewxpck.p (
                     input substitute("&1,&2"
                                     ,X_ext-system.esys-id
                                     ,X_ext-system.db-num)
                   , output v-err-code
  ) no-error .
  if error-status:error
  then do:
    run write-to-log( substitute( "&1. ERROR!!! Ошибка при подготовке пакетов OpenXML &2&3&4"
                                  ,vss-workfile
                                  ,error-status:get-message(error-status:num-messages)
                                  ,{&new-line}
                                  ,return-value
                                )
                    ) .
  end.
  else do:
    assign
      v-message = return-value
    .
    if v-message <> "":U then do:
      run write-to-log ( substitute( "&1", v-message ) ).
    end.
    run write-to-log ( substitute( "Завершена подготовка новых пакетов." ) ).
  end.

  run refresh-brws in this-procedure  ( input yes ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-get
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-get oxmlhand
ON CHOOSE OF b-get IN FRAME oxmlhand /* Принять */
DO:
  run esys-key in this-procedure ( input-output v-key-passed-date ) no-error.
  if error-status:error then return no-apply.
    {&test-esys}
    assign
    add-log-file-name = substring( log-file-name, 1, r-index( log-file-name, '.':u) - 1 ) + substitute( "-&1.log", X_ext-system.esys-id )
    .
    run bge/oxmlinx.p ( input parparentproc
                       ,input this-procedure:handle
                       ,input p-log-handle
                       ,input substitute("take,&1,&2,&3"
                                      ,v-db-num
                                      ,X_ext-system.esys-id
                                      ,X_ext-system.db-num

                                      )
                  ) no-error.
    if error-status:error then do:
      run write-to-log( vss-workfile + {&space-char}
                        + substitute( "ERROR!!! Ошибка при приеме пакета данных из ВС &1"
                        ,X_ext-system.esys-id ) + {&new-line}
                        + substitute( "&1", error-status:get-message(error-status:num-messages) ) + {&new-line}
                        + substitute( "&1", return-value )
                      ) .
    end.
    assign
    add-log-file-name = ?
    .
    run refresh-brws in this-procedure ( input yes ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-get-pck
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-get-pck oxmlhand
ON CHOOSE OF b-get-pck IN FRAME oxmlhand /* Принять/Разобрать */
DO:
  run esys-key in this-procedure ( input-output v-key-passed-date ) no-error.
  if error-status:error then return no-apply.
 {&test-esys}
    assign
    add-log-file-name = substring( log-file-name, 1, r-index( log-file-name, '.':u) - 1 ) + substitute( "-&1.log", X_ext-system.esys-id )
    .
    run bge/oxmlinx.p ( input parparentproc
                       ,input this-procedure:handle
                       ,input p-log-handle
                       ,input substitute("take+analys,&1,&2,&3"
                                      ,v-db-num
                                      ,X_ext-system.esys-id
                                      ,X_ext-system.db-num)
                  ) no-error.
    if error-status:error then do:
      run write-to-log( vss-workfile + {&space-char}
                        + substitute( "ERROR!!! Ошибка при приеме пакетов данных из ВС &1", X_ext-system.esys-id ) + {&new-line}
                        + substitute( "&1", error-status:get-message(error-status:num-messages) ) + {&new-line}
                        + substitute( "&1", return-value )
                      ) .
    end.
    assign
    add-log-file-name = ?
    .
    run refresh-brws in this-procedure ( input yes ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-imp-err
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-imp-err oxmlhand
ON CHOOSE OF b-imp-err IN FRAME oxmlhand /* Ошибки */
DO:
  run bge/pack-err.w ( input X_esys-pck-rcvd.esys-id
                      ,input X_esys-pck-rcvd.db-num
                      ,input X_esys-pck-rcvd.espr-cr-db-num
                      ,input X_esys-pck-rcvd.espr-pack-num
                ) no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-info
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-info oxmlhand
ON CHOOSE OF b-info IN FRAME oxmlhand /* Доп.инфо */
DO:
  {&test-esys}
  run bge/packxinf.w ( input X_esys-pck-sent.esys-id
                      ,input X_esys-pck-sent.db-num
                      ,input X_esys-pck-sent.esps-cr-db-num
                      ,input X_esys-pck-sent.esps-pack-num
                ) no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-packlist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-packlist oxmlhand
ON CHOOSE OF b-packlist IN FRAME oxmlhand /* Сообщения */
DO:
    if not available X_esys-pck-sent THEN do:
        message "Не выбран пакет для просмотра." view-as alert-box .
        return no-apply.
    end.

    run bge/viewpack.w ( X_ext-system.esys-id
                        ,X_ext-system.db-num
                        ,X_esys-pck-sent.esps-cr-db-num
                        ,X_esys-pck-sent.esps-pack-num
                        ) no-error.
    run refresh-brws
      ( input yes )
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-proc-pck
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-proc-pck oxmlhand
ON CHOOSE OF b-proc-pck IN FRAME oxmlhand /* Разобрать */
DO:
   {&test-esys}
 /*
  if not available X_esys-pck-rcvd then do:
    message
    "Отстутствует пакет для разбора"
    view-as alert-box .
    undo, return no-apply.
  end.
  */

  if not available X_esys-pck-rcvd then do:
    message
    "Отстутствует пакет для разбора"
    view-as alert-box .
    undo, return no-apply.
  end.
  assign
  add-log-file-name = substring( log-file-name, 1, r-index( log-file-name, '.':u) - 1 ) + substitute( "-&1.log", X_ext-system.esys-id )
  .
  run bge/oxmlinx.p ( input parparentproc
                      ,input this-procedure:handle
                      ,input p-log-handle
                      ,input substitute("analys,&1,&2,&3,&4,&5"
                                    ,v-db-num
                                    ,X_ext-system.esys-id
                                    ,X_ext-system.db-num
                                    ,X_esys-pck-rcvd.espr-cr-db-num
                                    ,X_esys-pck-rcvd.espr-pack-num

                                    )
                ) no-error.
  if error-status:error then do:
    run write-to-log( vss-workfile + {&space-char}
                      + substitute( "ERROR!!! Ошибка при приеме пакета данных из ВС &1"
                      ,X_ext-system.esys-id ) + {&new-line}
                      + substitute( "&1", error-status:get-message(error-status:num-messages) ) + {&new-line}
                      + substitute( "&1", return-value )
                    ) .
  end.
  assign
  add-log-file-name = ?
  .
  run refresh-brws in this-procedure ( input yes ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-send
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-send oxmlhand
ON CHOOSE OF b-send IN FRAME oxmlhand /* Отправить */
DO:
  run esys-key in this-procedure ( input-output v-key-passed-date ) no-error.
  if error-status:error then return no-apply.
    {&test-esys}

    if not available X_esys-pck-sent THEN do:
        message "Не выбран пакет для отправки." view-as alert-box .
        return no-apply.
    end.

    if X_esys-pck-sent.esps-rcvd = no
    or can-find(first ub.esys-route no-lock where
                     ub.esys-route.esys-id = X_esys-pck-sent.esys-id
                  and ub.esys-route.db-num = X_esys-pck-sent.db-num
                  and ub.esys-route.esr-cr-db-num = g#db-num
                  and ub.esys-route.esr-last-pack = X_esys-pck-sent.esps-pack-num
                  )
    then do:
      assign
      add-log-file-name = substring( log-file-name, 1, r-index( log-file-name, '.':u) - 1 ) + substitute( "-&1.log", X_ext-system.esys-id )
      .
      run bge/oxmloutx.p ( input parparentproc
                          ,input this-procedure:handle
                          ,input p-log-handle
                          ,input substitute("one-pack,&1,&2,&3,&4,&5"
                                      ,v-db-num
                                      ,X_ext-system.esys-id
                                      ,X_ext-system.db-num
                                      ,X_esys-pck-sent.esps-cr-db-num
                                      ,X_esys-pck-sent.esps-pack-num)

                    ) no-error.
      if error-status:error then do:
        run write-to-log( vss-workfile + {&space-char}
                          + substitute( "ERROR!!! Ошибка при отправке одного пакета данных в ВС &1", X_ext-system.esys-id ) + {&new-line}
                          + substitute( "&1", error-status:get-message(error-status:num-messages) ) + {&new-line}
                          + substitute( "&1", return-value )
                        ) .
      end.
      assign
      add-log-file-name = ?
      .
      run refresh-brws
        ( input yes )
      .
    end.
    else do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Отправить пакет &1 нельзя.", X_esys-pck-sent.esps-pack-num ) skip
        substitute( "Получено подтверждение о его приеме и данные уже удалены." )
        view-as alert-box information
      .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-send-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-send-all oxmlhand
ON CHOOSE OF b-send-all IN FRAME oxmlhand /* Отпр. вcе */
DO:
  run esys-key in this-procedure ( input-output v-key-passed-date ) no-error.
  if error-status:error then return no-apply.



    {&test-esys}

    if not available X_esys-pck-sent THEN do:
        message "Нет готовых пакетов." view-as alert-box .
        return no-apply.
    end.
    assign
    add-log-file-name = substring( log-file-name, 1, r-index( log-file-name, '.':u) - 1 ) + substitute( "-&1.log", X_ext-system.esys-id )
    .
     run bge/oxmloutx.p ( input parparentproc
                          ,input this-procedure:handle
                          ,input p-log-handle
                          ,input substitute("one-esys-unconf,&1,&2,&3,-1,-1"
                                      ,v-db-num
                                      ,X_ext-system.esys-id
                                      ,X_ext-system.db-num
                                        )

                    ) no-error.
      if error-status:error then do:
        run write-to-log( vss-workfile + {&space-char}
                      + substitute( "ERROR!!! Ошибка при отправке всех неподтвержденных пакетов данных в ВС &1", X_ext-system.esys-id ) + {&new-line}
                      + substitute( "&1", error-status:get-message(error-status:num-messages) ) + {&new-line}
                      + substitute( "&1", return-value )
                    ) .

      end.
   assign
   add-log-file-name = ?
   .
      run refresh-brws in this-procedure ( input yes ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-send-new
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-send-new oxmlhand
ON CHOOSE OF b-send-new IN FRAME oxmlhand /* Отправить новые */
DO:
  run esys-key in this-procedure ( input-output v-key-passed-date ) no-error.
  if error-status:error then return no-apply.
    {&test-esys}
    assign
    add-log-file-name = substring( log-file-name, 1, r-index( log-file-name, '.':u) - 1 ) + substitute( "-&1.log", X_ext-system.esys-id )
    .
    run bge/oxmloutx.p ( input parparentproc
                          ,input this-procedure:handle
                          ,input p-log-handle
                          ,input substitute("one-esys,&1,&2,&3"
                                      ,v-db-num
                                      ,X_ext-system.esys-id
                                      ,X_ext-system.db-num
                                        )

                    ) no-error.

    if error-status:error then do:
      run write-to-log( vss-workfile + {&space-char}
                        + substitute( "ERROR!!! Ошибка при отправке Данных в ВС &1", X_ext-system.esys-id)  + {&new-line}
                        + substitute( "&1", error-status:get-message(error-status:num-messages) ) + {&new-line}
                        + substitute( "&1", return-value )
                      ) .
    end.
    assign
    add-log-file-name = ?
    .
    run refresh-brws in this-procedure ( input yes ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-unsend
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-unsend oxmlhand
ON CHOOSE OF b-unsend IN FRAME oxmlhand /* Данные */
DO:
  {&test-esys}
  run bge/vxroute.w ( input X_ext-system.esys-id, input X_ext-system.db-num ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-esys
&Scoped-define SELF-NAME br-esys
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-esys oxmlhand
ON VALUE-CHANGED OF br-esys IN FRAME oxmlhand
DO:
  run refresh-brws in this-procedure  ( input no )  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_send-ora-rcpt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_send-ora-rcpt oxmlhand
ON CHOOSE OF MENU-ITEM m_send-ora-rcpt /* Квитанц. для ВС типа Oracle Retail */
DO:
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
MESSAGE
"ВЫ действительно хотите сформировать подтверждение для пакета ?" SKIP
"(Скорее всего оно уже было сформировано)" SKIP
VIEW-AS ALERT-BOX QUESTION buttons YES-NO UPDATE glog.

IF NOT glog THEN RETURN NO-APPLY.
  run bge/rorarcpt.p ( INPUT parparentproc
                      ,INPUT p-log-handle
                      ,input no /*p-silent*/
                      ,INPUT X_ext-system.esys-id
                      ,INPUT X_ext-system.db-num
                      ,INPUT X_esys-pck-rcvd.espr-pack-num) NO-ERROR.
if error-status:error then do:
  message error-status:get-message(1)
  return-value
  view-as alert-box error .
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME pck-rcvd
&Scoped-define SELF-NAME pck-rcvd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL pck-rcvd oxmlhand
ON ROW-DISPLAY OF pck-rcvd IN FRAME oxmlhand /* Полученные пакеты */
DO:
  define buffer esys-pck-rcvd-err for ub.esys-pck-rcvd-err.

  v-imp-err = if can-find(first esys-pck-rcvd-err where
                                esys-pck-rcvd-err.esys-id        = X_esys-pck-rcvd.esys-id
                            AND esys-pck-rcvd-err.db-num         = X_esys-pck-rcvd.db-num
                            AND esys-pck-rcvd-err.espr-cr-db-num = X_esys-pck-rcvd.espr-cr-db-num
                            AND esys-pck-rcvd-err.espr-pack-num  = X_esys-pck-rcvd.espr-pack-num)
              then "+" else "".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL pck-rcvd oxmlhand
ON VALUE-CHANGED OF pck-rcvd IN FRAME oxmlhand /* Полученные пакеты */
DO:
  define buffer esys-pck-rcvd-err for ub.esys-pck-rcvd-err.
    ASSIGN
    MENU-ITEM m_send-ora-rcpt:SENSITIVE IN MENU MENU-b-other = NO.

  IF NOT AVAILABLE X_ext-system  THEN DO:
  END.
  ELSE DO:
     IF AVAILABLE X_esys-pck-rcvd THEN DO:

        CASE X_ext-system.delivery-method:
          WHEN INTEGER({&esys-dm-oracle-retail}) THEN DO:
              ASSIGN
              MENU-ITEM m_send-ora-rcpt:SENSITIVE IN MENU MENU-b-other = YES.

          END.
          OTHERWISE DO:

          END.

        END CASE.
      END.    /*IF AVAILABLE X_esys-pck-rcvd.db-num THEN DO:*/
      ELSE DO:

      END. /*/*IF AVAILABLE X_esys-pck-rcvd.db-num THEN DO:*/*/
      if can-find(first esys-pck-rcvd-err where
                        esys-pck-rcvd-err.esys-id        = X_esys-pck-rcvd.esys-id
                    AND esys-pck-rcvd-err.db-num         = X_esys-pck-rcvd.db-num
                    AND esys-pck-rcvd-err.espr-cr-db-num = X_esys-pck-rcvd.espr-cr-db-num
                    AND esys-pck-rcvd-err.espr-pack-num  = X_esys-pck-rcvd.espr-pack-num) 
        then enable b-imp-err with frame {&frame-name}.
        else disable b-imp-err with frame {&frame-name}.
  END. /*else if IF NOT AVAILABLE X_ext-system  THEN DO:*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-esys
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK oxmlhand 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


{ gbl/brwrefre.i " run refresh-brws in this-procedure  ( input yes)." }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

MAIN-BLOCK:
DO
ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
:


  find first buf_sys-ctrl no-lock.
  run gbl/set-gbl.p
    (input false
    ,input p-user-login
    ,input p-user-password
    ) no-error.
  if error-status:error then do:
    run write-to-log( substitute( "&1. Ошибка при инициализации переменных g#...&2&3"
                                  ,vss-workfile
                                  ,{&new-line}
                                  ,error-status:get-message(error-status:num-messages)
                                )
                    ) .
    return error.
  end.

  { gbl/app_help.i }

  assign
    hand-log-msg-h = oxml-log:handle
  g#esys = true
  .
  define variable mDBInfo as character no-undo.
  run adm/db-info.p ( output v-db-num, output mDBInfo ) no-error .

  if error-status:error then do:
    run write-to-log( substitute( "&1. &2&3&4"
                                  ,vss-workfile
                                  ,mDBInfo
                                  ,{&new-line}
                                  ,error-status:get-message(error-status:num-messages)
                                )
                    ) .
    return error.
  end.

  assign
   frame {&frame-name}:title = substitute("OpenXML &1", mDBInfo)
   br-esys:num-locked-columns IN FRAME {&frame-name} = 1
  .
  RUN Myenable in this-procedure.
  do
  on ERROR  undo, leave
  on ENDKEY undo, leave
  on STOP   undo, retry
  :
    wait-for go of frame {&frame-name}.
  end.

END.

RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI oxmlhand  _DEFAULT-DISABLE
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
  HIDE FRAME oxmlhand.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI oxmlhand  _DEFAULT-ENABLE
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
  DISPLAY oxml-log 
      WITH FRAME oxmlhand.
  ENABLE b-quit b-create b-packlist b-help br-esys pck-sent b-send b-send-all 
         b-conf-pck b-info pck-rcvd b-imp-err b-get-pck b-send-new b-unsend 
         b-get b-proc-pck b-other oxml-log 
      WITH FRAME oxmlhand.
  {&OPEN-BROWSERS-IN-QUERY-oxmlhand}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE esys-key oxmlhand 
PROCEDURE esys-key :
define input-output parameter p-key-passed-date as date no-undo .
define variable v-key-ok as logical no-undo .
define variable v-mess as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
run cur-time in this-procedure ( output v-today, output v-time).
if p-key-passed-date = ?
or p-key-passed-date < v-today then do:
  run bge/esys-key.p ( input g#db-num
                      ,input no /*p-silent*/
                      ,output v-key-ok
                      ,output v-mess) no-error.
  if error-status:error then do:
    message
    substitute( "&2&1Ошибка при выполнении проверки конф. параметров по типам ВС&1&3&1&4"
                                      , {&new-line}
                                      , vss-workfile
                                      , return-value
                                      , error-status :get-message( error-status :num-messages )
                                                    )
    view-as alert-box error.
    return error.
  end.
  if not v-key-ok then do:
    message
    substitute( "При проверке конфигурационных параметров по типам ВС обнаружено несоответствие&1&2&1Продолжение работы невозможно&1"
                                      , {&new-line}
                                      , v-mess       )
    view-as alert-box error .
    return error.
  end.
  assign
  p-key-passed-date = v-today.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable oxmlhand 
PROCEDURE MyEnable :
b-other:MENU-MOUSE IN FRAME {&FRAME-NAME} = 1.
DISPLAY oxml-log
WITH FRAME {&frame-name}.
ENABLE
b-quit b-create b-help
br-esys
pck-sent
b-send
b-packlist
b-send-all
b-conf-pck
b-info
pck-rcvd
b-get-pck
b-send-new
b-other
b-unsend
b-get
b-proc-pck
oxml-log
WITH FRAME {&frame-name}.
run Openbr-esys in this-procedure .
apply "VALUE-CHANGED" to br-esys.
apply "VALUE-CHANGED" to pck-rcvd.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr-esys oxmlhand 
PROCEDURE Openbr-esys :
OPEN QUERY br-esys FOR EACH X_ext-system NO-LOCK where
(X_ext-system.esys-have-export and
    X_ext-system.esys-db-num-exp = buf_sys-ctrl.db-num)
    or
(X_ext-system.esys-have-import and
    X_ext-system.esys-db-num-imp = buf_sys-ctrl.db-num
    )
by X_ext-system.esys-id
    INDEXED-REPOSITION.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr-pck-rcvd oxmlhand 
PROCEDURE Openbr-pck-rcvd :
OPEN QUERY pck-rcvd FOR EACH X_esys-pck-rcvd
      WHERE X_esys-pck-rcvd.esys-id = X_ext-system.esys-id
      and X_esys-pck-rcvd.db-num = X_ext-system.db-num
      and X_esys-pck-rcvd.espr-cr-db-num = buf_sys-ctrl.db-num

      NO-LOCK
    BY X_esys-pck-rcvd.esys-id DESCENDING
    BY X_esys-pck-rcvd.db-num DESCENDING
    BY X_esys-pck-rcvd.espr-cr-db-num DESCENDING
    BY X_esys-pck-rcvd.espr-pack-num DESCENDING INDEXED-REPOSITION.

 END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr-pck-sent oxmlhand 
PROCEDURE Openbr-pck-sent :
OPEN QUERY pck-sent FOR EACH X_esys-pck-sent
      WHERE X_esys-pck-sent.esys-id = X_ext-system.esys-id
      and X_esys-pck-sent.db-num = X_ext-system.db-num
      and X_esys-pck-sent.esps-cr-db-num = buf_sys-ctrl.db-num
      NO-LOCK
    BY X_esys-pck-sent.esys-id DESCENDING
    BY X_esys-pck-sent.db-num DESCENDING
    BY X_esys-pck-sent.esps-cr-db-num DESCENDING
    BY X_esys-pck-sent.esps-pack-num DESCENDING INDEXED-REPOSITION.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE refresh-brws oxmlhand 
PROCEDURE refresh-brws :
define input parameter p-with-esys as logical no-undo .

  define variable v-rowid as rowid no-undo .

  if p-with-esys = true then do:
    assign
      log-res = browse br-esys:set-repositioned-row( browse br-esys :focused-row, 'CONDITIONAL':u)
      v-rowid = rowid( X_ext-system )
    .
    run Openbr-esys in this-procedure.
    reposition br-esys to rowid v-rowid no-error .
  end.
  run Openbr-pck-rcvd in this-procedure.
  run Openbr-pck-sent in this-procedure.
 if available X_esys-pck-sent then do:
    assign
      log-res = pck-sent:select-row( 1 ) IN FRAME {&frame-name}
    .
  end.
  if available X_esys-pck-rcvd then do:
    assign
      log-res = pck-rcvd:select-row( 1 ) IN FRAME {&frame-name}
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

