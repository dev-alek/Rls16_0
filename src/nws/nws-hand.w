&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME nws-hand


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_db FOR ub.db.
DEFINE BUFFER X_pck-rcvd FOR ub.pck-rcvd.
DEFINE BUFFER X_pck-sent FOR ub.pck-sent.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS nws-hand
/*------------------------------------------------------------------------
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ручной режим работы СПН

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/23/99
Author: Dmitry Ukhanov
Creation date: 03/23/99

------------------------------------------------------------------------*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input  parameter parparentproc   as widget-handle no-undo .
define input  parameter p-user-login    as character     no-undo .
define input  parameter p-user-password as character     no-undo .

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Ручной режим работы СПН".
{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ cmp/trg-def.i  }
{ nws/nws-def.i  }
{ cmp/mrk-strf.i }
{ gbl/color.i   }

define variable log-res as logical no-undo .

define buffer buf_db for ub.db .

define variable v-rid-list     as   character    no-undo .
define variable v-rid-list-new as   character    no-undo .
define variable v-ind          as   integer      no-undo .
define variable v-num-entries  as   integer      no-undo .
define variable v-db-list      as   character    no-undo .
define variable v-db-num       like ub.db.db-num no-undo .
define variable v-one-db       as   logical      no-undo .
define variable v-cur-db-num as integer no-undo .
define variable v-have-rights    as logical        no-undo.


&scop test-db-one ~
  if not available X_db then do: ~
    message ~
      "Не выбрана БД." ~
      view-as alert-box information. ~
    return no-apply. ~
  end. ~
  find first buf_db no-lock ~
    where buf_db.db-num = X_db.db-num ~
    no-error . ~
  if not available buf_db then do: ~
    message ~
      substitute( "БД &1 удалена.", X_db.db-num ) ~
      view-as alert-box information. ~
    run refresh-brws in this-procedure ~
      ( input yes ) . ~
    return no-apply . ~
  end.

&scop test-db ~
  assign ~
    v-one-db = false ~
  . ~
  if trim( v-rid-list ) = "":U ~
    and available X_db ~
  then do: ~
    assign ~
      v-rid-list = string( recid ( X_db ) ) ~
      v-one-db   = true ~
    .  ~
  end. ~
  if trim( v-rid-list ) = "":U then do: ~
    message ~
      "Не выбрана БД." ~
      view-as alert-box information. ~
    return no-apply. ~
  end. ~
  assign ~
    v-num-entries = num-entries( v-rid-list) ~
    v-rid-list-new = "":U ~
    v-db-list = "":U ~
  . ~
  do v-ind = 1 to v-num-entries ~
  : ~
    find first buf_db no-lock ~
      where recid( buf_db ) = integer( entry( v-ind, v-rid-list ) ) ~
      no-error . ~
    if not available buf_db then do: ~
      message ~
        substitute( "БД &1 удалена.", integer( entry( v-ind, v-rid-list ) ) ) ~
        view-as alert-box information. ~
    end. ~
    else do: ~
      if v-one-db <> true then do: ~
        assign ~
          v-rid-list-new = v-rid-list-new + (if v-rid-list-new = "":U then "":U else {&comma-char}) + entry( v-ind, v-rid-list ) ~
        . ~
      end. ~
      assign ~
        v-db-list = v-db-list + (if v-db-list = "":U then "":U else {&comma-char}) + string( buf_db.db-num ) ~
      . ~
    end. ~
  end. ~
  assign ~
    v-rid-list = v-rid-list-new ~
  . ~
  run refresh-brws in this-procedure ~
    ( input yes ) .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME nws-hand
&Scoped-define BROWSE-NAME br-db

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_db X_pck-rcvd X_pck-sent

/* Definitions for BROWSE br-db                                         */
&Scoped-define FIELDS-IN-QUERY-br-db mark-string( input recid(X_db), input v-rid-list) get-turn-on(X_db.db-key) X_db.db-num X_db.db-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-db
&Scoped-define SELF-NAME br-db
&Scoped-define OPEN-QUERY-br-db if g#db-num = 0 then     OPEN QUERY {&SELF-NAME} FOR EACH X_db where X_db.db-num > 0 NO-LOCK INDEXED-REPOSITION. else     OPEN QUERY {&SELF-NAME} FOR EACH X_db where X_db.db-num = 0 NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-db X_db
&Scoped-define FIRST-TABLE-IN-QUERY-br-db X_db


/* Definitions for BROWSE br-pck-rcvd                                   */
&Scoped-define FIELDS-IN-QUERY-br-pck-rcvd X_pck-rcvd.pack-num ~
X_pck-rcvd.rcvd X_pck-rcvd.total-recs
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-pck-rcvd
&Scoped-define QUERY-STRING-br-pck-rcvd FOR EACH X_pck-rcvd ~
      WHERE X_pck-rcvd.db-num = X_db.db-num  NO-LOCK ~
    BY X_pck-rcvd.db-num DESCENDING ~
       BY X_pck-rcvd.pack-num DESCENDING INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-pck-rcvd OPEN QUERY br-pck-rcvd FOR EACH X_pck-rcvd ~
      WHERE X_pck-rcvd.db-num = X_db.db-num  NO-LOCK ~
    BY X_pck-rcvd.db-num DESCENDING ~
       BY X_pck-rcvd.pack-num DESCENDING INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-pck-rcvd X_pck-rcvd
&Scoped-define FIRST-TABLE-IN-QUERY-br-pck-rcvd X_pck-rcvd


/* Definitions for BROWSE br-pck-sent                                   */
&Scoped-define FIELDS-IN-QUERY-br-pck-sent X_pck-sent.pack-num ~
X_pck-sent.rcvd X_pck-sent.total-recs
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-pck-sent
&Scoped-define QUERY-STRING-br-pck-sent FOR EACH X_pck-sent ~
      WHERE X_pck-sent.db-num = X_db.db-num NO-LOCK ~
    BY X_pck-sent.db-num DESCENDING ~
       BY X_pck-sent.pack-num DESCENDING INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-pck-sent OPEN QUERY br-pck-sent FOR EACH X_pck-sent ~
      WHERE X_pck-sent.db-num = X_db.db-num NO-LOCK ~
    BY X_pck-sent.db-num DESCENDING ~
       BY X_pck-sent.pack-num DESCENDING INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-pck-sent X_pck-sent
&Scoped-define FIRST-TABLE-IN-QUERY-br-pck-sent X_pck-sent


/* Definitions for DIALOG-BOX nws-hand                                  */
&Scoped-define OPEN-BROWSERS-IN-QUERY-nws-hand ~
    ~{&OPEN-QUERY-br-db}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-3 b-exit b-get-pck b-create b-sync b-send-new ~
b-info-all b-help b-mark b-get b-proc-pck b-send b-send-all b-unsend br-db ~
br-pck-sent br-pck-rcvd news-log mark-num bt-not-sel-all bt-not-sel-desel-all
&Scoped-Define DISPLAYED-OBJECTS news-log mark-num f-not-rcvd

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-turn-on nws-hand
FUNCTION get-turn-on RETURNS LOGICAL
  ( INPUT v-db-key AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-create DEFAULT
     LABEL "Под&готовить новые"
     SIZE 20 BY 1 TOOLTIP "Подготовка новых пакетов для всех БД"
     BGCOLOR 8 .
     
DEFINE BUTTON b-sync DEFAULT
     LABEL "&Синхронизация"
     SIZE 20 BY 1 TOOLTIP "Синхронизация УБД, восстановленной из бэкапа, с ТБД"
     BGCOLOR 8 .

DEFINE BUTTON b-exit AUTO-GO DEFAULT
     LABEL "Вы&ход "
     SIZE 10 BY 1 TOOLTIP "Выход из новостей"
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

DEFINE BUTTON b-info-all DEFAULT
     LABEL "Информ. о пакетах"
     SIZE 20 BY 1 TOOLTIP "Детальная информация о пакетах по БД"
     BGCOLOR 8 .

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-proc-pck DEFAULT
     LABEL "&Разобрать"
     SIZE 10 BY 1 TOOLTIP "Только разобрать пакет, не принимая новых".

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
     LABEL "&Без подтвержд."
     SIZE 20 BY 1 TOOLTIP "Неотправленнная или неподтвержденая информация".

DEFINE BUTTON bt-not-sel-all
     LABEL "+"
     SIZE 3 BY 1 TOOLTIP "Выбрать все".

DEFINE BUTTON bt-not-sel-desel-all
     LABEL "-"
     SIZE 3 BY 1 TOOLTIP "Отменить выбор".

DEFINE VARIABLE news-log AS CHARACTER INITIAL ?
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL LARGE
     SIZE 97 BY 6.5 TOOLTIP "Просмотр файла с сообщениями о работе новостей" NO-UNDO.

DEFINE VARIABLE f-not-rcvd AS INTEGER FORMAT ">>>>>9":U INITIAL 0
     LABEL "без подтверждения"
      VIEW-AS TEXT
     SIZE 7 BY .67 TOOLTIP "кол-во пакетов без подтверждения" NO-UNDO.

DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 4 BY 1
     FGCOLOR 7  NO-UNDO.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 97 BY 13.5.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-db FOR
      X_db SCROLLING.

DEFINE QUERY br-pck-rcvd FOR
      X_pck-rcvd SCROLLING.

DEFINE QUERY br-pck-sent FOR
      X_pck-sent SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-db nws-hand _FREEFORM
  QUERY br-db DISPLAY
      mark-string( input recid(X_db), input v-rid-list) column-label "*" format "X(1)":U
      get-turn-on(X_db.db-key) FORMAT "+/-":U COLUMN-LABEL "A":U
      X_db.db-num FORMAT ">>>>9":U
      X_db.db-name
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 61.5 BY 13
         TITLE "Список БД" FIT-LAST-COLUMN TOOLTIP "Рабочие БД".

DEFINE BROWSE br-pck-rcvd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-pck-rcvd nws-hand _STRUCTURED
  QUERY br-pck-rcvd NO-LOCK DISPLAY
      X_pck-rcvd.pack-num COLUMN-LABEL "Номер" FORMAT ">>>>>>9":U
      X_pck-rcvd.rcvd COLUMN-LABEL "Подтв." FORMAT "yes/no":U
      X_pck-rcvd.total-recs COLUMN-LABEL "Записей в пакете" FORMAT ">>>>>>>>>9":U
            WIDTH 16.25
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ASSIGN NO-ROW-MARKERS SEPARATORS SIZE 33 BY 6
         TITLE "Полученные пакеты" FIT-LAST-COLUMN TOOLTIP "Полученные пакеты от данной БД".

DEFINE BROWSE br-pck-sent
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-pck-sent nws-hand _STRUCTURED
  QUERY br-pck-sent NO-LOCK DISPLAY
      X_pck-sent.pack-num COLUMN-LABEL "Номер" FORMAT ">>>>>>9":U
      X_pck-sent.rcvd COLUMN-LABEL "Подтв." FORMAT "yes/no":U
      X_pck-sent.total-recs COLUMN-LABEL "Записей в пакете" FORMAT ">>>>>>>>>9":U
            WIDTH 16.25
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ASSIGN NO-ROW-MARKERS SEPARATORS SIZE 33 BY 6
         TITLE "Отправленные пакеты" FIT-LAST-COLUMN TOOLTIP "Отправленные пакеты в данную БД".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME nws-hand
     b-exit AT ROW 1 COL 2
     b-get-pck AT ROW 1 COL 15
     b-create AT ROW 1 COL 35
     b-send-new AT ROW 1 COL 55
     b-info-all AT ROW 1 COL 75 WIDGET-ID 2
     b-help AT ROW 1 COL 95.5
     bt-not-sel-all AT ROW 2 COL 6 WIDGET-ID 10 NO-TAB-STOP
     bt-not-sel-desel-all AT ROW 2 COL 9 WIDGET-ID 12 NO-TAB-STOP
     b-mark AT ROW 2 COL 12 WIDGET-ID 4
     b-get AT ROW 2 COL 15
     b-proc-pck AT ROW 2 COL 25
     b-sync at row 2 col 35
     b-send AT ROW 2 COL 55
     b-send-all AT ROW 2 COL 65
     b-unsend AT ROW 2 COL 75
     br-db AT ROW 3.5 COL 2.5
     br-pck-sent AT ROW 3.5 COL 65
     br-pck-rcvd AT ROW 10.5 COL 65
     news-log AT ROW 17 COL 2 NO-LABEL
     mark-num AT ROW 2 COL 2 NO-LABEL WIDGET-ID 8
     f-not-rcvd AT ROW 9.5 COL 86.5 COLON-ALIGNED
     RECT-3 AT ROW 3.25 COL 2
     SPACE(0.87) SKIP(7.01)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_db B "?" ? ub db
      TABLE: X_pck-rcvd B "?" ? ub pck-rcvd
      TABLE: X_pck-sent B "?" ? ub pck-sent
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX nws-hand
   FRAME-NAME                                                           */
/* BROWSE-TAB br-db b-unsend nws-hand */
/* BROWSE-TAB br-pck-sent br-db nws-hand */
/* BROWSE-TAB br-pck-rcvd br-pck-sent nws-hand */
ASSIGN
       FRAME nws-hand:SCROLLABLE       = FALSE.

/* SETTINGS FOR BUTTON bt-not-sel-all IN FRAME nws-hand
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON bt-not-sel-desel-all IN FRAME nws-hand
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-not-rcvd IN FRAME nws-hand
   NO-ENABLE                                                            */
ASSIGN
       f-not-rcvd:READ-ONLY IN FRAME nws-hand        = TRUE.

/* SETTINGS FOR FILL-IN mark-num IN FRAME nws-hand
   ALIGN-L                                                              */
ASSIGN
       news-log:READ-ONLY IN FRAME nws-hand        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-db
/* Query rebuild information for BROWSE br-db
     _START_FREEFORM
if g#db-num = 0 then
    OPEN QUERY {&SELF-NAME} FOR EACH X_db where X_db.db-num > 0 NO-LOCK INDEXED-REPOSITION.
else
    OPEN QUERY {&SELF-NAME} FOR EACH X_db where X_db.db-num = 0 NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-db */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-pck-rcvd
/* Query rebuild information for BROWSE br-pck-rcvd
     _TblList          = "X_pck-rcvd"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _OrdList          = "X_pck-rcvd.db-num|no,X_pck-rcvd.pack-num|no"
     _Where[1]         = "X_pck-rcvd.db-num = X_db.db-num "
     _FldNameList[1]   > "_<CALC>"
"X_pck-rcvd.pack-num" "Номер" ">>>>>>9" "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > "_<CALC>"
"X_pck-rcvd.rcvd" "Подтв." "yes/no" "logical" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > "_<CALC>"
"X_pck-rcvd.total-recs" "Записей в пакете" ">>>>>>>>>9" "integer" ? ? ? ? ? ? no ? no no "16.25" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is NOT OPENED
*/  /* BROWSE br-pck-rcvd */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-pck-sent
/* Query rebuild information for BROWSE br-pck-sent
     _TblList          = "X_pck-sent"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _OrdList          = "X_pck-sent.db-num|no,X_pck-sent.pack-num|no"
     _Where[1]         = "X_pck-sent.db-num = X_db.db-num"
     _FldNameList[1]   > "_<CALC>"
"X_pck-sent.pack-num" "Номер" ">>>>>>9" "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > "_<CALC>"
"X_pck-sent.rcvd" "Подтв." "yes/no" "logical" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > "_<CALC>"
"X_pck-sent.total-recs" "Записей в пакете" ">>>>>>>>>9" "integer" ? ? ? ? ? ? no ? no no "16.25" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is NOT OPENED
*/  /* BROWSE br-pck-sent */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX nws-hand
/* Query rebuild information for DIALOG-BOX nws-hand
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX nws-hand */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME nws-hand
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL nws-hand nws-hand
ON WINDOW-CLOSE OF FRAME nws-hand
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-create
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-create nws-hand
ON CHOOSE OF b-create IN FRAME nws-hand /* Подготовить новые */
DO:

  define variable v-message  as character no-undo .
  define variable v-err-code as integer   no-undo .

  {&test-db}

  run write-to-log in this-procedure
    ( substitute( "Подготовка новых пакетов." )
    ).

  run nws/cnew-pck.p
    ( input v-db-list
    , output v-err-code
    ) no-error .
  if error-status:error then do:
    run write-to-log( substitute( "&1. ERROR!!! Ошибка при подготовке пакетов новостей &2&3&4"
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
      run write-to-log in this-procedure
        ( substitute( "&1", v-message )
        ).
    end.
    run write-to-log in this-procedure
      ( substitute( "Завершена подготовка новых пакетов." )
      ).
  end.

  run refresh-brws in this-procedure
    ( input yes
    ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-sync
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sync nws-hand
ON CHOOSE OF b-sync IN FRAME nws-hand /* Синхронизация */
DO:
  define variable v-user-id as character no-undo .
  define variable vOk as logical no-undo .
  
  v-user-id = g#auto-user-id + {&delim-par} + 'yes' .
  
  if not available X_db then return no-apply .
  
  { gbl/chk-actg.i
    g#db-num
    v-user-id
    {&action-head-code-main}
    'actn_news-sync':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    no
    v-have-rights
    }
  if not v-have-rights
  then do :
    if v-cur-db-num = 0
    then do :
      message "Недостаточно прав для выполнения Cинхронизации БД " string(x_db.db-num) " с ТБД" view-as alert-box error.
    end .
    else do :
      message "Недостаточно прав для отправки запроса на Синхронизацию УБД с ТБД" view-as alert-box error.
    end .
    return no-apply .
  end.
  if v-cur-db-num = 0
  then do :
    run nws/sync.w (input parparentproc,
                    input X_db.db-num)
                    no-error .
    if error-status:error
    then do :
      run write-to-log( substitute( "&1. ERROR!!! Ошибка при синхронизации пакетов с БД &5&3&2&3&4"
                                    ,vss-workfile
                                    ,error-status:get-message(error-status:num-messages)
                                    ,{&new-line}
                                    ,return-value
                                    ,string(X_db.db-num)
                                  )
                      ) .
    end.
  /*  else do :                                                    */
  /*    run write-to-log in this-procedure                         */
  /*      ("Завершена синхронизация с БД " + string(X_db.db-num) ).*/
  /*  end.                                                         */
  end .
  else do :
    message "Вы уверены что хотите отправить запрос в ТБД на Синхронизацию обмена СПН? Каталоги новостей будут очищены!" view-as alert-box question buttons yes-no update vOk .
    if not vOk
    then
      return no-apply .
    
    run nws/send-sync-request.p (input parparentproc,
                                 input X_db.db-num)
                                 no-error .
    if error-status:error
    then do :
      run write-to-log( substitute( "&1. ERROR!!! Ошибка при отправке запроса на Синхронизацию обмена СПН &3&2&3&4"
                                    ,vss-workfile
                                    ,error-status:get-message(error-status:num-messages)
                                    ,{&new-line}
                                    ,return-value
                                  )
                      ) .
    end.
  end .

  {&OPEN-QUERY-br-pck-rcvd}
  {&OPEN-QUERY-br-pck-sent}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-get
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-get nws-hand
ON CHOOSE OF b-get IN FRAME nws-hand /* Принять */
DO:

    {&test-db}

  assign
    v-num-entries = num-entries( v-db-list )
  .
  do v-ind = 1 to v-num-entries
  :
    assign
      v-db-num = integer( entry( v-ind, v-db-list ) )
    .
    if g#db-num = 0 then do:
      assign
        add-log-file-name = substring( log-file-name, 1, r-index( log-file-name, '.':u) - 1 ) + substitute( "-&1.log", v-db-num )
      .
    end.

    run nws/rcvd-nws.p
      ( input parparentproc
      , input "take":U
      , input v-db-num
      , input ?
      ) no-error.
    if error-status:error then do:
      run write-to-log in this-procedure
        ( vss-workfile + {&space-char}
          + substitute( "ERROR!!! Ошибка при приеме пакетов новостей из БД &1", v-db-num ) + {&new-line}
          + substitute( "&1", error-status:get-message(error-status:num-messages) ) + {&new-line}
          + substitute( "&1", return-value )
        ).
    end.
    assign
      add-log-file-name = ?
    .
  end.

  run refresh-brws in this-procedure
    ( input yes
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-get-pck
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-get-pck nws-hand
ON CHOOSE OF b-get-pck IN FRAME nws-hand /* Принять/Разобрать */
DO:

    {&test-db}

  assign
    v-num-entries = num-entries( v-db-list )
  .
  do v-ind = 1 to v-num-entries
  :
    assign
      v-db-num = integer( entry( v-ind, v-db-list ) )
    .
    if g#db-num = 0 then do:
      assign
        add-log-file-name = substring( log-file-name, 1, r-index( log-file-name, '.':u) - 1 ) + substitute( "-&1.log", v-db-num )
      .
    end.
    run nws/rcvd-nws.p
     ( input parparentproc
     , input "take+analys":U
     , input v-db-num
     , input ?
     ) no-error.
    if error-status:error then do:
      run write-to-log in this-procedure
        ( vss-workfile + {&space-char}
          + substitute( "ERROR!!! Ошибка при приеме и(или) разборе пакетов новостей из БД &1", v-db-num ) + {&new-line}
          + substitute( "&1", error-status:get-message(error-status:num-messages) ) + {&new-line}
          + substitute( "&1", return-value )
        ).
    end.
    assign
      add-log-file-name = ?
    .
  end.
  run refresh-brws in this-procedure
    ( input yes
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-info-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-info-all nws-hand
ON CHOOSE OF b-info-all IN FRAME nws-hand /* Информ. о пакетах */
DO:

  {&test-db-one}

  run nws/packsinf.w
    ( input X_db.db-num
    ).

  run refresh-brws in this-procedure
    ( input yes
    ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark nws-hand
ON CHOOSE OF b-mark IN FRAME nws-hand /* * */
DO:

  define variable loc#log as logical no-undo .

  if available X_db then do:
    { gbl/markstrn.i X_db v-rid-list }
    loc#log = {&browse-name}:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = {&browse-name}:select-next-row ().
        apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0 then do:
      hide mark-num in frame {&frame-name}.
    end.
    else do:
      display
        num-entries( v-rid-list ) @ mark-num
        with frame {&frame-name}.
    end.
  end.
  apply "entry" to {&browse-name} in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-proc-pck
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-proc-pck nws-hand
ON CHOOSE OF b-proc-pck IN FRAME nws-hand /* Разобрать */
DO:

  {&test-db}

  assign
    v-num-entries = num-entries( v-db-list )
  .
  do v-ind = 1 to v-num-entries
  :
    assign
      v-db-num = integer( entry( v-ind, v-db-list ) )
    .
    if g#db-num = 0 then do:
      assign
        add-log-file-name = substring( log-file-name, 1, r-index( log-file-name, '.':u) - 1 ) + substitute( "-&1.log", v-db-num )
      .
    end.
    run nws/rcvd-nws.p
      ( input parparentproc
      , input "analys":U
      , input v-db-num
      , input ?
      ) no-error.
    if error-status:error then do:
      run write-to-log in this-procedure
        ( vss-workfile + {&space-char}
          + substitute( "ERROR!!! Ошибка при разборе пакетов новостей из БД &1", v-db-num ) + {&new-line}
          + substitute( "&1", error-status:get-message(error-status:num-messages) ) + {&new-line}
          + substitute( "&1", return-value )
        ) .
    end.
    assign
      add-log-file-name = ?
    .
  end.
  run refresh-brws in this-procedure
    ( input yes
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-send
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-send nws-hand
ON CHOOSE OF b-send IN FRAME nws-hand /* Отправить */
DO:

    {&test-db-one}

    if not available X_pck-sent THEN do:
        message "Не выбран пакет для отправки." view-as alert-box .
        return no-apply.
    end.

    if X_pck-sent.rcvd = no then do:
      if g#db-num = 0 then do:
        assign
          add-log-file-name = substring( log-file-name, 1, r-index( log-file-name, '.':u) - 1 ) + substitute( "-&1.log", X_db.db-num )
        .
      end.
      run nws/send-nws.p
        ( input parparentproc
        , input "one-pack":U
        , input X_db.db-num
        , input X_pck-sent.pack-num
        ) no-error.
      if error-status:error then do:
        run write-to-log in this-procedure
          ( vss-workfile + {&space-char}
            + substitute( "ERROR!!! Ошибка при отправке одного пакета новостей в БД &1", X_db.db-num ) + {&new-line}
            + substitute( "&1", error-status:get-message(error-status:num-messages) ) + {&new-line}
            + substitute( "&1", return-value )
          ) .
      end.
      assign
        add-log-file-name = ?
      .
      run refresh-brws in this-procedure
        ( input yes
        ).
    end.
    else do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Отправить пакет &1 нельзя.", X_pck-sent.pack-num ) skip
        substitute( "Получено подтверждение о его приеме." )
        view-as alert-box information
      .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-send-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-send-all nws-hand
ON CHOOSE OF b-send-all IN FRAME nws-hand /* Отпр. вcе */
DO:
  {&test-db}

  assign
    v-num-entries = num-entries( v-db-list )
  .
  do v-ind = 1 to v-num-entries
  :
    assign
      v-db-num = integer( entry( v-ind, v-db-list ) )
    .
    if g#db-num = 0 then do:
      assign
        add-log-file-name = substring( log-file-name, 1, r-index( log-file-name, '.':u) - 1 ) + substitute( "-&1.log", v-db-num )
      .
    end.
    run nws/send-nws.p
      ( input parparentproc
      , input "all-unconf":U
      , input v-db-num
      , input ?
      ) no-error.
    if error-status:error then do:
      run write-to-log in this-procedure
        ( vss-workfile + {&space-char}
          + substitute( "ERROR!!! Ошибка при отправке всех неподтвержденных пакетов новостей в БД &1", v-db-num ) + {&new-line}
          + substitute( "&1", error-status:get-message(error-status:num-messages) ) + {&new-line}
          + substitute( "&1", return-value )
        ).
    end.
    assign
      add-log-file-name = ?
    .
  end.

  run refresh-brws in this-procedure
    ( input yes
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-send-new
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-send-new nws-hand
ON CHOOSE OF b-send-new IN FRAME nws-hand /* Отправить новые */
DO:
  {&test-db}

  assign
    v-num-entries = num-entries( v-db-list )
  .
  do v-ind = 1 to v-num-entries
  :
    assign
      v-db-num = integer( entry( v-ind, v-db-list ) )
    .
    if g#db-num = 0 then do:
      assign
        add-log-file-name = substring( log-file-name, 1, r-index( log-file-name, '.':u) - 1 ) + substitute( "-&1.log", v-db-num )
      .
    end.
    run nws/send-nws.p
      ( input parparentproc
      , input "all":U
      , input v-db-num
      , input ?
      ) no-error.
    if error-status:error then do:
      run write-to-log( vss-workfile + {&space-char}
                        + substitute( "ERROR!!! Ошибка при отправке новостей в БД &1", v-db-num )  + {&new-line}
                        + substitute( "&1", error-status:get-message(error-status:num-messages) ) + {&new-line}
                        + substitute( "&1", return-value )
                      ).
    end.
    assign
      add-log-file-name = ?
    .
  end.
  run refresh-brws in this-procedure
    ( input yes
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-unsend
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-unsend nws-hand
ON CHOOSE OF b-unsend IN FRAME nws-hand /* Без подтвержд. */
DO:
  {&test-db-one}

  run nws/v-route.w
    ( input parparentproc
    , input X_db.db-num
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-db
&Scoped-define SELF-NAME br-db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-db nws-hand
ON VALUE-CHANGED OF br-db IN FRAME nws-hand /* Список БД */
DO:
  run refresh-brws in this-procedure
    ( input no
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-not-sel-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-not-sel-all nws-hand
ON CHOOSE OF bt-not-sel-all IN FRAME nws-hand /* + */
DO:
  define variable loc#log as logical no-undo .

  if available X_db then do:
    v-rid-list = "" .
    for each X_db where X_db.db-num <> 0 :
      { gbl/markstrn.i X_db v-rid-list }
      loc#log = {&browse-name}:refresh() .
    end.
  end.
  if num-entries( v-rid-list ) <> 0 then do:
    display
      num-entries( v-rid-list ) @ mark-num
      with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-not-sel-desel-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-not-sel-desel-all nws-hand
ON CHOOSE OF bt-not-sel-desel-all IN FRAME nws-hand /* - */
DO:
  define variable loc#log as logical no-undo .
  v-rid-list = "" .
  loc#log = {&browse-name}:refresh() .
  hide mark-num in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK nws-hand


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
{ gbl/hot-key.i b-mark }

IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

{ gbl/app_help.i &disable_diasize=true }

MAIN-BLOCK:
DO
ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
:

  run gbl/set-gbl.p
    ( input false
     ,input p-user-login
     ,input p-user-password
    ) no-error.
  if error-status:error then do:
    return error substitute( "&1. Ошибка при инициализации переменных g#...&2&3"
                             ,vss-workfile
                             ,{&new-line}
                             ,error-status:get-message(error-status:num-messages)
                           ).
  end.
  assign
    hand-log-msg-h = news-log:handle
    g#news = true
  .
  define variable mDBInfo as character no-undo.
  run adm/db-info.p
    ( output v-cur-db-num
    , output mDBInfo
    ) no-error .

  if error-status:error then do:
    return error substitute( "&1. &2&3&4"
                             ,vss-workfile
                             ,mDBInfo
                             ,{&new-line}
                             ,error-status:get-message(error-status:num-messages)
                            ).
  end.

  assign
    frame {&frame-name}:title = "СПН" + {&space-char} + mDBInfo
    browse br-db :num-locked-columns = 1
  .
  RUN enable_UI.
  run refresh-brws in this-procedure
    ( input no
    ).

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI nws-hand  _DEFAULT-DISABLE
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
  HIDE FRAME nws-hand.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI nws-hand  _DEFAULT-ENABLE
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
  DISPLAY news-log mark-num f-not-rcvd
      WITH FRAME nws-hand.
  ENABLE RECT-3 b-exit b-get-pck b-create b-sync b-send-new b-info-all b-help b-mark
         b-get b-proc-pck b-send b-send-all b-unsend br-db br-pck-sent
         br-pck-rcvd news-log mark-num bt-not-sel-all bt-not-sel-desel-all
      WITH FRAME nws-hand.
  if v-cur-db-num <> 0 then do :
    disable bt-not-sel-all bt-not-sel-desel-all
      WITH FRAME nws-hand.
  end.
  {&OPEN-BROWSERS-IN-QUERY-nws-hand}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE refresh-brws nws-hand
PROCEDURE refresh-brws :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input parameter p-with-db as logical no-undo .

  define variable v-rowid as rowid no-undo .
  define buffer buf_pck-sent for ub.pck-sent .

  assign
    v-rowid = ?
  .

  if p-with-db = true then do:
    if available X_db then do:
      assign
        v-rowid = rowid( X_db )
        log-res = browse br-db :set-repositioned-row( browse br-db :focused-row, 'CONDITIONAL':u)
      .
    end.
    {&OPEN-QUERY-br-db}
    reposition br-db to rowid v-rowid no-error .
  end.

  {&OPEN-QUERY-br-pck-rcvd}
  {&OPEN-QUERY-br-pck-sent}
  if available X_pck-sent then do:
    assign
      log-res = browse br-pck-sent :select-row( 1 )
    .
  end.
  if available X_pck-rcvd then do:
    assign
      log-res = browse br-pck-rcvd :select-row( 1 )
    .
  end.

/*  assign*/
/*    f-not-rcvd = 0*/
/*  .*/
/*  find last buf_pck-sent no-lock*/
/*    where buf_pck-sent.db-num = X_db.db-num*/
/*    use-index pi*/
/*    no-error .*/
/*  if available buf_pck-sent then do:*/
/*    assign*/
/*      f-not-rcvd = buf_pck-sent.pack-num*/
/*    .*/
/*    for first buf_pck-sent no-lock ??????????????? почему-то не ищет как положено!!!!!!!!!!!*/
/*      where buf_pck-sent.db-num   = X_db.db-num*/
/*        and buf_pck-sent.pack-num > 0*/
/*        and buf_pck-sent.rcvd     = true*/
/*      by buf_pck-sent.db-num*/
/*      by buf_pck-sent.pack-num*/
/*    on error undo, return error return-value*/
/*    :*/
/*      assign*/
/*        f-not-rcvd = f-not-rcvd - buf_pck-sent.pack-num*/
/*      .*/
/*      message*/
/*        "X" buf_pck-sent.pack-num*/
/*        view-as alert-box.*/
/*    end.*/
/*  end.*/

/*  assign*/
/*    f-not-rcvd :screen-value in frame {&frame-name} = string( f-not-rcvd, f-not-rcvd :format in frame {&frame-name})*/
/*  .*/

  assign
    f-not-rcvd = 0
  .
  for each buf_pck-sent no-lock
    where buf_pck-sent.db-num = X_db.db-num
      and buf_pck-sent.rcvd   = false
  on error undo, return error
  :
    assign
      f-not-rcvd = f-not-rcvd + 1
      f-not-rcvd :screen-value in frame {&frame-name} = string( f-not-rcvd, f-not-rcvd :format in frame {&frame-name})
    .
  end.

  if f-not-rcvd > 10 then do:
    assign
      f-not-rcvd:fgcolor = RED_COLOR
    .
  end.
  else do:
    assign
      f-not-rcvd:fgcolor = ?
    .
  end.
  display f-not-rcvd with frame {&frame-name}.

  if num-entries( v-rid-list ) = 0 then do:
    hide mark-num in frame {&frame-name}.
  end.
  else do:
    display
      num-entries( v-rid-list ) @ mark-num
      with frame {&frame-name}.
  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-turn-on nws-hand
FUNCTION get-turn-on RETURNS LOGICAL
  ( INPUT v-db-key AS CHARACTER ) :

  RETURN (v-db-key <> "":U AND v-db-key <> ? ).

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME