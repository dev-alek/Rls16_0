&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME cut-load
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS cut-load
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Программа вызова процедуры "обрезания"

Автор: Уханов Дмитрий Юрьевич
Дата создания: 11/29/01
Author: Dmitry Ukhanov
Creation date: 11/29/01

*/

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "".
/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
{ cmp/trg-def.i new }
{ cmp/showinf.i  }
{ gbl/db-attr.i  }

define variable ret-err              as logical   no-undo .
define variable err-msg              as character no-undo .
define variable sel-rid-list         as character no-undo .
define variable answ-rid-list        as character no-undo .
define variable v-cut-type           as integer   no-undo .
define variable v-cut-run            as logical   no-undo .
define variable v-db-list            as character no-undo .
define variable v-not-answer-db-list as character no-undo .
define variable v-ind                as integer   no-undo .
define variable v-num-entries        as integer   no-undo .

define buffer buf_BatchProcess for ub.BatchProcess .
define buffer buf_db for ub.db .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME DEFAULT-FRAME
&Scoped-define BROWSE-NAME br_db

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.db

/* Definitions for BROWSE br_db                                         */
&Scoped-define FIELDS-IN-QUERY-br_db ~
(if ( lookup( string( recid( ub.db ) ), answ-rid-list ) <> 0 )   then "+":U   else (if ( lookup( string( recid( ub.db ) ), sel-rid-list ) <> 0 )         then "*":U         else "":U ) ) ~
ub.db.db-num ub.db.db-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-br_db
&Scoped-define QUERY-STRING-br_db FOR EACH ub.db NO-LOCK
&Scoped-define OPEN-QUERY-br_db OPEN QUERY br_db FOR EACH ub.db NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br_db ub.db
&Scoped-define FIRST-TABLE-IN-QUERY-br_db ub.db


/* Definitions for FRAME DEFAULT-FRAME                                  */
&Scoped-define OPEN-BROWSERS-IN-QUERY-DEFAULT-FRAME ~
    ~{&OPEN-QUERY-br_db}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 RECT-2 b-exit b-quit type-cut ~
stay-weight-goods b-mark b-refresh not-copy-del-goods br_db ~
stay-recipe-goods date-actual-goods date-actual-docs date-output-zone ~
stay-history log-edit
&Scoped-Define DISPLAYED-OBJECTS type-cut stay-weight-goods ~
not-copy-del-goods stay-recipe-goods date-actual-goods date-actual-docs ~
date-output-zone stay-history log-edit mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR cut-load AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit DEFAULT
     LABEL "&Ввод"
     SIZE 10 BY 1.

DEFINE BUTTON b-mark DEFAULT
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY DEFAULT
     LABEL "&Отмена"
     SIZE 10 BY 1.

DEFINE BUTTON b-refresh DEFAULT
     LABEL "&Обновить"
     SIZE 10 BY 1.

DEFINE VARIABLE type-cut AS CHARACTER FORMAT "X(256)":U INITIAL "Полное"
     LABEL "Тип усечения БД"
     VIEW-AS COMBO-BOX INNER-LINES 2
     LIST-ITEMS "Полное" ,"Усечение документов по БД" 
     DROP-DOWN-LIST
     SIZE 28.38 BY 1 NO-UNDO.

DEFINE VARIABLE log-edit AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL LARGE
     SIZE 96.38 BY 9.88 NO-UNDO.

DEFINE VARIABLE date-actual-docs AS DATE FORMAT "99/99/9999":U
     LABEL "Дата актуальности документов и архивов"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE date-actual-findoc AS DATE FORMAT "99/99/9999":U
     LABEL "Дата актуальности финансовых документов"
     VIEW-AS FILL-IN
     SIZE 11.13 BY .92 NO-UNDO.

DEFINE VARIABLE date-actual-goods AS DATE FORMAT "99/99/9999":U
     LABEL "Дата актуальности товаров"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE date-output-zone AS DATE FORMAT "99/99/9999":U
     LABEL "Дата расходной зоны"
     VIEW-AS FILL-IN
     SIZE 11.13 BY .92 NO-UNDO.

DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 3 BY .67 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 57 BY 9.58.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 40 BY 9.54.

DEFINE VARIABLE not-copy-del-goods AS LOGICAL INITIAL yes
     LABEL "Не копировать удаленные товары с ненулевыми остатками"
     VIEW-AS TOGGLE-BOX
     SIZE 55.75 BY 1 NO-UNDO.

DEFINE VARIABLE stay-history AS LOGICAL INITIAL no 
     LABEL "Переносить историю по всем таблицам"
     VIEW-AS TOGGLE-BOX
     SIZE 38.25 BY 1 NO-UNDO.

DEFINE VARIABLE stay-recipe-goods AS LOGICAL INITIAL yes
     LABEL "Оставить товары для рецептов"
     VIEW-AS TOGGLE-BOX
     SIZE 31.75 BY 1 NO-UNDO.

DEFINE VARIABLE stay-weight-goods AS LOGICAL INITIAL yes
     LABEL "Оставить все весовые товары"
     VIEW-AS TOGGLE-BOX
     SIZE 30.25 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br_db FOR
      ub.db SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br_db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br_db cut-load _STRUCTURED
  QUERY br_db NO-LOCK DISPLAY
      (if ( lookup( string( recid( ub.db ) ), answ-rid-list ) <> 0 )
  then "+":U
  else (if ( lookup( string( recid( ub.db ) ), sel-rid-list ) <> 0 )
        then "*":U
        else "":U )
) COLUMN-LABEL "*" FORMAT "x(1)":U
      ub.db.db-num FORMAT ">>>>9":U
      ub.db.db-name FORMAT "X(40)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 37.75 BY 7.83.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DEFAULT-FRAME
     b-exit AT ROW 1.17 COL 2.5
     b-quit AT ROW 1.17 COL 12.5
     type-cut AT ROW 2.46 COL 19.38 COLON-ALIGNED
     stay-weight-goods AT ROW 3.96 COL 1.75
     b-mark AT ROW 4.04 COL 62.25
     b-refresh AT ROW 4.04 COL 87.5
     not-copy-del-goods AT ROW 5.13 COL 1.75
     br_db AT ROW 5.21 COL 60.25
     stay-recipe-goods AT ROW 6.21 COL 1.75
     date-actual-goods AT ROW 7.42 COL 41.13 COLON-ALIGNED
     date-actual-docs AT ROW 8.54 COL 41.13 COLON-ALIGNED
     date-actual-findoc AT ROW 9.71 COL 41.13 COLON-ALIGNED
     date-output-zone AT ROW 10.83 COL 41.13 COLON-ALIGNED
     stay-history AT ROW 11.88 COL 2.88
     log-edit AT ROW 13.5 COL 2.38 NO-LABEL
     mark-num AT ROW 4.25 COL 64.25 COLON-ALIGNED NO-LABEL
     RECT-1 AT ROW 3.71 COL 1
     RECT-2 AT ROW 3.71 COL 59
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS THREE-D
         AT COL 1 ROW 1
         SIZE 98.88 BY 22.63
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW cut-load ASSIGN
         HIDDEN             = YES
         TITLE              = "'Запуск"
         HEIGHT             = 22.63
         WIDTH              = 98.88
         MAX-HEIGHT         = 23.63
         MAX-WIDTH          = 98.88
         VIRTUAL-HEIGHT     = 23.63
         VIRTUAL-WIDTH      = 98.88
         RESIZE             = no
         SCROLL-BARS        = no
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW cut-load
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME DEFAULT-FRAME
   FRAME-NAME UNDERLINE                                                 */
/* BROWSE-TAB br_db not-copy-del-goods DEFAULT-FRAME */
ASSIGN
       FRAME DEFAULT-FRAME:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN date-actual-findoc IN FRAME DEFAULT-FRAME
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       date-actual-findoc:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

ASSIGN
       log-edit:READ-ONLY IN FRAME DEFAULT-FRAME        = TRUE.

/* SETTINGS FOR FILL-IN mark-num IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(cut-load)
THEN cut-load:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br_db
/* Query rebuild information for BROWSE br_db
     _TblList          = "ub.db"
     _Options          = "NO-LOCK"
     _FldNameList[1]   > "_<CALC>"
"(if ( lookup( string( recid( ub.db ) ), answ-rid-list ) <> 0 )
  then ""+"":U
  else (if ( lookup( string( recid( ub.db ) ), sel-rid-list ) <> 0 )
        then ""*"":U
        else """":U )
)" "*" "x(1)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   = ub.db.db-num
     _FldNameList[3]   = ub.db.db-name
     _Query            is OPENED
*/  /* BROWSE br_db */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME DEFAULT-FRAME
/* Query rebuild information for FRAME DEFAULT-FRAME
     _Query            is NOT OPENED
*/  /* FRAME DEFAULT-FRAME */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME cut-load
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cut-load cut-load
ON END-ERROR OF cut-load /* 'Запуск */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cut-load cut-load
ON WINDOW-CLOSE OF cut-load /* 'Запуск */
DO:
  /* This event will close the window and terminate the procedure.  */

  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit cut-load
ON CHOOSE OF b-exit IN FRAME DEFAULT-FRAME /* Ввод */
DO:
  define variable v-ok               as logical   no-undo .
  define variable v-date             as date      no-undo .
  define variable v-time             as integer   no-undo .
  define variable v-db-send          as character no-undo .
  define variable v-db-num-str       as character no-undo .
  define variable v-deleted          as logical   no-undo .
  define variable v-unload-after-cut as character no-undo .
  define variable v-ready            as logical   no-undo .

  assign frame {&frame-name}
    date-actual-goods
    date-actual-docs
/*    date-actual-findoc*/
    date-output-zone
    stay-recipe-goods
    stay-weight-goods
    stay-history
    not-copy-del-goods
    type-cut
  .
  if date-actual-docs = ? then do:
    assign
      date-actual-docs = TODAY
    .
  end.
  assign
    date-actual-findoc = date-actual-docs
  .

  assign
    v-ok = false
  .
  if ( v-cut-type = 1 and v-cut-run <> true )
     or v-cut-type <> 1
  then do:
    message
      'Вы уверены, что хотите произвести "обрезание" базы данных?' skip
      view-as alert-box question buttons yes-no update v-ok .
    if v-ok <> true then do:
      return no-apply .
    end.
  end.

  if v-cut-type = 1 then do:
    if v-cut-run = true then do:
      run scan-ready in this-procedure
        ( input v-db-list
         ,input date-actual-docs
         ,input date-actual-findoc
         ,output answ-rid-list
         ,output v-not-answer-db-list
        ).
      if v-not-answer-db-list <> "":U then do:
        message
          substitute( "УБД &1 еще не прислали подтверждения о готовности!", v-not-answer-db-list ) skip
          view-as alert-box error
        .
        return no-apply.
      end.
      assign
        v-ok               = true
        not-copy-del-goods = false
        stay-weight-goods  = true
        stay-recipe-goods  = true
        date-actual-goods  = 01/01/1900
        date-output-zone   = 01/01/1900
      .
    end.
    else do:
      do transaction
      on error undo, return no-apply
      :
        assign
          v-num-entries = num-entries( sel-rid-list )
          v-db-list     = "":U
          v-db-send     = "":U
          v-ok          = false
        .
        do v-ind = 1 to v-num-entries
        on error undo, return no-apply
        :
          find first buf_db no-lock
            where recid( buf_db ) = integer( entry( v-ind, sel-rid-list ) )
            .
          assign
            v-db-num-str = string( buf_db.db-num )
            v-db-list    = ( if v-db-list <> "":U then (v-db-list + {&comma-char}) else "":U ) + v-db-num-str
            v-ready      = false
          .
          if buf_db.db-num <> 0 then do:
            assign
              v-unload-after-cut = "no":U
            .
            if trim( buf_db.db-key ) = "":U then do:
              assign
                v-ready = true
              .
            end.
            else do:
              assign
                v-db-send = ( if v-db-send <> "":U then (v-db-send + {&delim-nws}) else "":U ) + v-db-num-str
                v-ready   = false
              .
            end.
          end.
          else do:
            if lookup( "0":U, v-db-list, {&comma-char} ) <> 0 then do:
              assign
                v-unload-after-cut = "yes":U
                v-ready            = true
              .
            end.
            else do:
              assign
                v-unload-after-cut = "":U
                v-ready            = false
              .
            end.
          end.
          if v-unload-after-cut <> "":U then do:
            run db-attr-write
              ( input buf_db.db-num
               ,input {&attr-unload-after-cut}
               ,input v-unload-after-cut
              ) no-error.
            if error-status :error then do:
              message
                vss-workfile vss-revision vss-description skip
                substitute( "Ошибка при записи значения атрибута 'выгрузка после обрезания' для БД &1", buf_db.db-num ) skip
                return-value skip
                error-status :get-message ( error-status :num-messages )
                view-as alert-box error
              .
              return no-apply.
            end.
            if v-ready = true then do:
              run db-attr-write in this-procedure
                ( input buf_db.db-num
                 ,input {&attr-cut-date}
                 ,input string( date-actual-docs, "99/99/9999" )
                ) no-error.
              if error-status :error then do:
                message
                  vss-workfile vss-revision vss-description skip
                  substitute( "Ошибка при записи значения атрибута 'дата обрезания складских документов' для БД &1", buf_db.db-num ) skip
                  return-value skip
                  error-status :get-message ( error-status :num-messages )
                  view-as alert-box error
                .
                undo, return no-apply.
              end.
              run db-attr-write in this-procedure
                ( input buf_db.db-num
                 ,input {&attr-cut-fin-date}
                 ,input string( date-actual-findoc, "99/99/9999" )
                ) no-error.
              if error-status :error then do:
                message
                  vss-workfile vss-revision vss-description skip
                  substitute( "Ошибка при записи значения атрибута 'дата обрезания финансовых документов' для БД &1", buf_db.db-num ) skip
                  return-value skip
                  error-status :get-message ( error-status :num-messages )
                  view-as alert-box error
                .
                undo, return no-apply.
              end.
            end.
          end.
        end.

        assign
          v-date    = TODAY
          v-time    = TIME
          v-cut-run = true
        .

        run db-attr-write in this-procedure
          ( input 0
           ,input {&attr-cut-db-list}
           ,input v-db-list
          ) no-error.
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            substitute( "Ошибка при записи значения атрибута 'Список БД для обрезания' для БД 0" ) skip
            return-value skip
            error-status :get-message ( error-status :num-messages )
            view-as alert-box error
          .
          undo, return no-apply.
        end.
        create buf_BatchProcess.
        assign
          buf_BatchProcess.BatchProcess#     = next-value (s-btpr, {&db-name_schema})
          buf_BatchProcess.BP_Type           = {&btpr-type-cutdbs}
          buf_BatchProcess.CharKey_Two       = string( date-actual-docs, "99/99/9999" )
          buf_BatchProcess.CharKey_Three     = string( date-actual-findoc, "99/99/9999" )
          buf_BatchProcess.User_ID           = "cut-load":U
          buf_BatchProcess.BP_SysDate        = v-date
          buf_BatchProcess.BP_SysTimeInt     = v-time
          buf_BatchProcess.BP_SysTime        = string(v-time, 'HH:MM:SS':U)
          buf_BatchProcess.BP_ExecSysDate    = v-date
          buf_BatchProcess.BP_ExecSysTimeInt = v-time
          buf_BatchProcess.BP_ExecSysTime    = string(v-time, 'HH:MM:SS':U)
        .
        run nws/cr-route.p
          ( input {&send-cmd}
           ,input "command" + {&delim-nws} + "cut-doc" + {&delim-nws} + string( date-actual-docs, "99/99/9999" ) + {&delim-nws} + string( date-actual-findoc, "99/99/9999" )
           ,input ?
           ,input v-db-send
          ).
      end.

      apply "value-changed" to type-cut in frame {&frame-name}.
      message
        "Команда о начале процесса усечения документов отправлена в выбранные БД." skip
        "Обменяйтесь новостями." skip
        "После получения подтверждения запустите процесс усечения документов."
        view-as alert-box information.
    end.
  end.
  else do:
    assign
      v-ok = true
    .
  end.
  if v-ok = true then do:
    run utl/cutld.p
      ( input v-cut-type
       ,input v-db-list
       ,input date-actual-goods
       ,input date-actual-docs
       ,input date-actual-findoc
       ,input date-output-zone
       ,input stay-recipe-goods
       ,input stay-weight-goods
       ,input not-copy-del-goods
       ,input stay-history
       ,input this-procedure :handle
      ) no-error.
    if error-status :error then do:
      assign
        ret-err = TRUE
        err-msg = return-value
      .
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при работе утилит!" ) skip
        return-value skip
        error-status :get-message ( error-status :num-messages )
        view-as alert-box error
      .
    end.
    else do:
      if v-cut-type = 1 then do:
        for each buf_BatchProcess
          where buf_BatchProcess.BP_type = {&btpr-type-cutdbs}
        on error undo, return no-apply
        :
          delete buf_BatchProcess .
        end.
        run db-attr-delete in this-procedure
          ( input 0
           ,input {&attr-cut-db-list}
           ,output v-deleted
          ).
      end.
      message
        substitute( "Усечение завершено." ) skip
        view-as alert-box information
      .
    end.
    apply "close":u to this-procedure.
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark cut-load
ON CHOOSE OF b-mark IN FRAME DEFAULT-FRAME /* * */
OR MOUSE-SELECT-DBLCLICK OF br_db IN FRAME DEFAULT-FRAME /* * */
DO:
  define variable v-log as logical no-undo.

  if available ub.db then do:
    { gbl/markstrn.i ub.db sel-rid-list }
    v-log = br_db:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      v-log = br_db:select-next-row ().
      apply "iteration-changed" to br_db in frame {&frame-name}.
    end.
    if num-entries( sel-rid-list ) = 0 then do:
      hide mark-num in frame {&frame-name}.
    end.
    else do:
      disp num-entries( sel-rid-list ) @ mark-num with frame {&frame-name}.
    end.
  end.
  apply "entry" to br_db in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit cut-load
ON CHOOSE OF b-quit IN FRAME DEFAULT-FRAME /* Отмена */
DO:
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-refresh
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-refresh cut-load
ON CHOOSE OF b-refresh IN FRAME DEFAULT-FRAME /* Обновить */
DO:
  define variable v-log as logical no-undo.
  run scan-ready in this-procedure
    ( input  v-db-list
     ,input  date-actual-docs
     ,input  date-actual-findoc
     ,output answ-rid-list
     ,output v-not-answer-db-list
    ).
  v-log = br_db:refresh() .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME type-cut
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL type-cut cut-load
ON VALUE-CHANGED OF type-cut IN FRAME DEFAULT-FRAME /* Тип усечения БД */
DO:
  assign
    {&SELF-NAME}
  .
  case {&SELF-NAME} :
    when "Полное" then do:
      assign
        v-cut-type = 0
      .
      HIDE
        br_db
        b-mark
        b-refresh
        mark-num
        IN FRAME {&FRAME-NAME} IN WINDOW {&WINDOW-NAME}.
      ENABLE
        stay-weight-goods
        not-copy-del-goods
        stay-recipe-goods
        stay-history
        date-actual-goods
        date-output-zone
        WITH FRAME {&FRAME-NAME} IN WINDOW {&WINDOW-NAME}.
    end.
    when "Усечение документов по БД" then do:
      assign
        v-cut-type = 1
      .
      HIDE
        stay-weight-goods
        not-copy-del-goods
        stay-recipe-goods
        date-actual-goods
        date-output-zone
        IN FRAME {&FRAME-NAME} IN WINDOW {&WINDOW-NAME}.
      ENABLE
        br_db
        b-mark
        b-refresh
        stay-history
        WITH FRAME {&FRAME-NAME} IN WINDOW {&WINDOW-NAME}.
      if v-cut-run = true then do:
        DISABLE
          b-mark
          date-actual-docs
          date-actual-findoc
          type-cut
          WITH FRAME {&FRAME-NAME} .
      end.
      assign
        mark-num = num-entries( sel-rid-list )
      .
      if mark-num <> 0 then do:
        DISPLAY
          mark-num
          WITH FRAME {&FRAME-NAME} IN WINDOW {&WINDOW-NAME}.
      end.
      else do:
        HIDE
          mark-num
          IN FRAME {&FRAME-NAME} IN WINDOW {&WINDOW-NAME}.
      end.
    end.
  end case.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br_db
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK cut-load


/* ***************************  Main Block  *************************** */

/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME}
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
ON CLOSE OF THIS-PROCEDURE
   RUN disable_UI.

/* Best default for GUI applications is...                              */
PAUSE 0 BEFORE-HIDE.

{ gbl/ed_date.i date-actual-goods  }
{ gbl/ed_date.i date-actual-docs   }
{ gbl/ed_date.i date-actual-findoc }
{ gbl/ed_date.i date-output-zone   }
/*
{ gbl/app_help.i &disable_diasize=true }
*/

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  define buffer buf_sys-ctrl     for ub.sys-ctrl .

  define variable v-attr-type as character no-undo .
  define variable v-log       as logical   no-undo .

  find first buf_sys-ctrl no-lock .
  if buf_sys-ctrl.db-num <> 0 then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Данная утилита может запускаться только в ГБД" ) skip
      view-as alert-box error
    .
    return error .
  end.

  find first buf_BatchProcess no-lock
    where buf_BatchProcess.BP_type = {&btpr-type-cutdbs}
    no-error .
  if available buf_BatchProcess then do:

    run db-attr-value in this-procedure
      ( input 0
       ,input {&attr-cut-db-list}
       ,output v-db-list
       ,output v-attr-type
      ) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при чтении значения атрибута 'Список БД для обрезания'" ) skip
        return-value skip
        error-status :get-message ( error-status :num-messages )
        view-as alert-box error
      .
      undo, return error .
    end.
    if v-db-list = "":U then do:
      message
        substitute( "Список БД для обрезания пуст!!!" ) skip
        view-as alert-box error
      .
      undo, return error .
    end.
    assign
      v-cut-run          = true
      type-cut           = "Усечение документов по БД"
      date-actual-docs   = date( buf_BatchProcess.CharKey_Two )
      date-actual-findoc = date( buf_BatchProcess.CharKey_Three )
      v-num-entries      = num-entries( v-db-list )
    .
    do v-ind = 1 to v-num-entries
    on error undo, return error
    :
      find first buf_db no-lock
        where buf_db.db-num = integer( entry( v-ind, v-db-list ) )
        .
      if sel-rid-list = "":U then do:
        assign
          sel-rid-list = string( recid( buf_db ) )
        .
      end.
      else do:
        assign
          sel-rid-list = sel-rid-list + {&comma-char} + string( recid( buf_db ) )
        .
      end.
    end.
  end.

  find first buf_sys-ctrl .
  if trim( buf_sys-ctrl.status_ ) = {&sttsDB-cutld} then do:
    message
      substitute( "Предыдущая попытка запуска усечения не была завершена!" ) skip
      substitute( "Вы желаете повторить усечение?" ) skip
      view-as alert-box question buttons yes-no update v-log.
    if v-log <> true then do:
      do transaction
      on error undo, return error return-value
      on stop  undo, return error return-value
      :
        find first buf_sys-ctrl exclusive-lock .
        assign
          buf_sys-ctrl.status_ = "":U
        .
        release buf_sys-ctrl.
      end.
      QUIT .
    end.
  end.

  run scan-ready in this-procedure
    ( input  v-db-list
     ,input  date-actual-docs
     ,input  date-actual-findoc
     ,output answ-rid-list
     ,output v-not-answer-db-list
    ).

  RUN enable_UI.
  assign
    ret-err = FALSE
  .
  apply "value-changed" to type-cut in frame {&frame-name}.

  create alias src for database ub .
  create alias ubfltsrc for database ub .
  create alias ubfltdst for database dst .

  IF NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE.

  /* завершаем сессию PROGRESS */
  QUIT .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE callback-write-to-log cut-load
PROCEDURE callback-write-to-log :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define input parameter p-msg-str as character no-undo .

  define variable lok as logical   no-undo .

  do with frame {&frame-name}
  on error undo, return error return-value
  :
    assign
      lok = log-edit :move-to-eof( )
      lok = log-edit :insert-string( p-msg-str )
      lok = log-edit :move-to-eof( )
    .
  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI cut-load  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Delete the WINDOW we created */
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(cut-load)
  THEN DELETE WIDGET cut-load.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI cut-load  _DEFAULT-ENABLE
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
  DISPLAY type-cut stay-weight-goods not-copy-del-goods stay-recipe-goods
          date-actual-goods date-actual-docs date-output-zone stay-history
          log-edit mark-num
      WITH FRAME DEFAULT-FRAME IN WINDOW cut-load.
  ENABLE RECT-1 RECT-2 b-exit b-quit type-cut stay-weight-goods b-mark
         b-refresh not-copy-del-goods br_db stay-recipe-goods date-actual-goods
         date-actual-docs date-output-zone stay-history log-edit
      WITH FRAME DEFAULT-FRAME IN WINDOW cut-load.
  VIEW FRAME DEFAULT-FRAME IN WINDOW cut-load.
  {&OPEN-BROWSERS-IN-QUERY-DEFAULT-FRAME}
  VIEW cut-load.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE scan-ready cut-load
PROCEDURE scan-ready :

  define input  parameter p-db-list            as character no-undo.
  define input  parameter p-cut-date           as date      no-undo .
  define input  parameter p-cut-fin-date       as date      no-undo .
  define output parameter p-ready-db-rid-list  as character no-undo .
  define output parameter p-not-answer-db-list as character no-undo .

  define variable v-db-num          as integer   no-undo .
  define variable v-attr-exist      as logical   no-undo .
  define variable v-cut-date        as character no-undo .
  define variable v-attr-fin-exist  as logical   no-undo .
  define variable v-cut-fin-date    as character no-undo .
  define variable v-attr-type       as character no-undo .

  assign
    v-num-entries        = num-entries( p-db-list )
    p-not-answer-db-list = "":U
    p-ready-db-rid-list  = "":U
  .
  do v-ind = 1 to v-num-entries
  on error undo, return no-apply
  :
    assign
      v-db-num = integer( entry( v-ind, p-db-list ) )
    .
    find first buf_db no-lock
      where buf_db.db-num = v-db-num
      .
    run db-attr-exist ( input v-db-num
                       ,input {&attr-cut-date}
                       ,output v-attr-exist
                      ) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при определении наличия атрибута 'дата обрезания' для БД &1", v-db-num ) skip
        return-value skip
        error-status :get-message ( error-status :num-messages )
        view-as alert-box error
      .
      return no-apply.
    end.
    run db-attr-value ( input v-db-num
                       ,input {&attr-cut-date}
                       ,output v-cut-date
                       ,output v-attr-type
                      ) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при чтении значения атрибута 'дата обрезания' для БД &1", v-db-num ) skip
        return-value skip
        error-status :get-message ( error-status :num-messages )
        view-as alert-box error
      .
      return no-apply.
    end.
    run db-attr-exist ( input v-db-num
                       ,input {&attr-cut-fin-date}
                       ,output v-attr-fin-exist
                      ) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при определении наличия атрибута 'дата обрезания фин.документов' для БД &1", v-db-num ) skip
        return-value skip
        error-status :get-message ( error-status :num-messages )
        view-as alert-box error
      .
      return no-apply.
    end.
    run db-attr-value ( input v-db-num
                       ,input {&attr-cut-fin-date}
                       ,output v-cut-fin-date
                       ,output v-attr-type
                      ) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при чтении значения атрибута 'дата обрезания фин.документов' для БД &1", v-db-num ) skip
        return-value skip
        error-status :get-message ( error-status :num-messages )
        view-as alert-box error
      .
      return no-apply.
    end.
    if v-attr-exist <> true
      or date( v-cut-date ) <> p-cut-date
      or v-attr-fin-exist <> true
      or date( v-cut-fin-date ) <> p-cut-fin-date
    then do:
      if p-not-answer-db-list = "":U then do:
        assign
          p-not-answer-db-list = string( v-db-num )
        .
      end.
      else do:
        assign
          p-not-answer-db-list = p-not-answer-db-list + {&comma-char} + string( v-db-num )
        .
      end.
    end.
    else do:
      if p-ready-db-rid-list = "":U then do:
        assign
          p-ready-db-rid-list = string( recid( buf_db ) )
        .
      end.
      else do:
        assign
          p-ready-db-rid-list = p-ready-db-rid-list + {&comma-char} + string( recid( buf_db ) )
        .
      end.
    end.
  end. /* do v-ind = 1 to v-num-entries... */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME