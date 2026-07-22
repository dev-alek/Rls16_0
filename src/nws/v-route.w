&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME v-route


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_route FOR ub.route.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS v-route
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр маршрутизации по заданой БД

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/23/01
Author: Dmitry Ukhanov
Creation date: 03/23/01

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as   widget-handle no-undo .
define input parameter p-db-num      like ub.db.db-num  no-undo.

/* Local Variable Definitions ---                                       */
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Просмотр маршрутизации по заданой БД".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ gbl/waitfram.i }
{ gbl/gate-clb.i }
{ cmp/library.i  }
{ gbl/usrfulnf.i }

{ gbl/flt-def.i }
{ gbl/fltfield.i }
{ gbl/fltopend.i defproc }

define variable v-recid            as recid     no-undo .
define variable v-title0           as character no-undo .
define variable v-sort-column-name as character no-undo .
define variable v-filter-pointr    as character no-undo init "Маршрутизация СПН" .
define variable v-filter-point0    as character no-undo init "v-route" .
define variable v-filter-point     as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME v-route
&Scoped-define BROWSE-NAME br-route

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_route

/* Definitions for BROWSE br-route                                      */
&Scoped-define FIELDS-IN-QUERY-br-route conv-pck-num( X_route.last-pack ) get-descr-route( X_route.name-rec, X_route.uniq-key-rec ) X_route.name-rec X_route.uniq-key-rec X_route.CreUserName usrfulnf(X_route.CreUserName) X_route.CreDate X_route.CreTime X_route.uniq-gate-rec get-gate-file-name-f(X_route.uniq-gate-rec) X_route.dump-ord
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-route
&Scoped-define SELF-NAME br-route
&Scoped-define QUERY-STRING-br-route for each X_route no-lock   WHERE X_route.db-num = p-db-num   by X_route.tbl-ord
&Scoped-define OPEN-QUERY-br-route OPEN QUERY br-route for each X_route no-lock   WHERE X_route.db-num = p-db-num   by X_route.tbl-ord .
&Scoped-define TABLES-IN-QUERY-br-route X_route
&Scoped-define FIRST-TABLE-IN-QUERY-br-route X_route


/* Definitions for DIALOG-BOX v-route                                   */
&Scoped-define OPEN-BROWSERS-IN-QUERY-v-route ~
    ~{&OPEN-QUERY-br-route}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-sch b-help br-route

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD conv-pck-num v-route
FUNCTION conv-pck-num returns character
  ( input p-pack-num as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-descr-route v-route
FUNCTION get-descr-route returns character
  ( input p-name-rec as character, input p-uniq-key-rec as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-gate-file-name-f v-route
FUNCTION get-gate-file-name-f returns character
  ( p-gate-rec as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY DEFAULT
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-route FOR
      X_route SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-route
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-route v-route _FREEFORM
  QUERY br-route NO-LOCK DISPLAY
      conv-pck-num( X_route.last-pack ) FORMAT "X(10)" column-label "Пакет"
get-descr-route( X_route.name-rec, X_route.uniq-key-rec ) WIDTH 70 format "X(255)" column-label "Описание"
X_route.name-rec format "X(255)"
X_route.uniq-key-rec format "X(255)"
X_route.CreUserName column-label "Создал" format "X(255)"
usrfulnf(X_route.CreUserName) column-label "Создал" FORMAT "x(18)":U
X_route.CreDate
X_route.CreTime
X_route.uniq-gate-rec format "X(255)" column-label "Гейт"
get-gate-file-name-f(X_route.uniq-gate-rec) format "X(32)" column-label "Имя Гейта"
X_route.dump-ord
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 19.75.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME v-route
     b-quit AT ROW 1 COL 1
     b-sch AT ROW 1 COL 92.5 WIDGET-ID 2
     b-help AT ROW 1 COL 95.5
     br-route AT ROW 2.25 COL 1
     SPACE(0.12) SKIP(0.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Просмотр маршрутизации"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_route B "?" ? ub route
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX v-route
   FRAME-NAME                                                           */
/* BROWSE-TAB br-route b-help v-route */
ASSIGN
       FRAME v-route:SCROLLABLE       = FALSE
       FRAME v-route:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-route
/* Query rebuild information for BROWSE br-route
     _START_FREEFORM
for each X_route no-lock
  WHERE X_route.db-num = p-db-num
  by X_route.tbl-ord
.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Where[1]         = "pck-sent.db-num = ub.db.db-num
 AND pck-sent.rcvd = FALSE"
     _Query            is OPENED
*/  /* BROWSE br-route */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME v-route
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-route v-route
ON WINDOW-CLOSE OF FRAME v-route /* Просмотр маршрутизации */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch v-route
ON CHOOSE OF b-sch IN FRAME v-route /* Фильтр */
DO:
  RUN proc-b-sch IN this-procedure NO-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-route
&Scoped-define SELF-NAME br-route
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-route v-route
ON VALUE-CHANGED OF br-route IN FRAME v-route
DO:
/*
  if available tt-route then do:
    display
      tt-route.descr        @ f-descr
      with frame {&frame-name}
    .
  end.
  else do:
    display
      "":U @ f-descr
      with frame {&frame-name}
    .
  end.
*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK v-route


/* ***************************  Main Block  *************************** */

{ gbl/app_help.i }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/brwrefre.i "run reopen-query in this-procedure ( input true, input false, input '' ) ." }
  { gbl/setfltnm.i }

  assign
    v-title0 = substitute("Недошедшая информация для БД &1", p-db-num )
  .

  RUN Myenable .

  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus br-route.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI v-route  _DEFAULT-DISABLE
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
  HIDE FRAME v-route.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI v-route  _DEFAULT-ENABLE
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
  ENABLE b-quit b-sch b-help br-route
      WITH FRAME v-route.
  VIEW FRAME v-route.
  {&OPEN-BROWSERS-IN-QUERY-v-route}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable v-route
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  assign
/*    descr-route:resizable in browse br-route = yes*/
/*    descr-route:width = 70*/
    X_route.name-rec:resizable in browse br-route = yes
    X_route.name-rec:width = 30
    X_route.uniq-key-rec:resizable in browse br-route = yes
    X_route.uniq-key-rec:width = 70
    X_route.uniq-gate-rec:resizable in browse br-route = yes
    X_route.uniq-gate-rec:width = 40
    X_route.CreUserName:resizable in browse br-route = yes
    X_route.CreUserName:width = 19
  .

  ENABLE
    b-quit
    b-help
    b-sch
    br-route
    WITH FRAME {&frame-name}.
  VIEW FRAME {&frame-name}.

  run reopen-query in this-procedure
    ( input true
    , input false
    , input '':U
    ) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch v-route
PROCEDURE proc-b-sch :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  assign
    tbl = 'route'
    join-tbl = 'X_route'
    fld = ""
    lab = ""
    spr = ""
    dim = '0'
    .
  run fltfield-add in this-procedure('name-rec', 'Таблица/команда', '',
                                      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('CreDate', 'Дата создания', '',
                                      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('CreUserName', 'Создал', 'usr',
                                      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('last-pack', 'Пакет', '',
                                      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('CreTimeInt', 'Время создания', 'time',
                                      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('Dump-ord', 'Dump-ord', '',
                                      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

  Filter-Block:
  DO
  ON STOP    UNDO Filter-Block, LEAVE Filter-Block
  ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
  ON END-KEY UNDO Filter-Block, LEAVE Filter-Block
  :
    run gbl/filter.w ( INPUT parparentproc, INPUT v-filter-point, INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
    run reopen-query in this-procedure
      ( input true
      , input false
      , input '':U
      ).
  END. /* Filter-Block */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reopen-query v-route
PROCEDURE reopen-query :
/*------------------------------------------------------------------------------
  purpose:
  parameters:  <none>
  notes:
------------------------------------------------------------------------------*/
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .

  define variable l-query-was-opened   as logical   no-undo .
  define variable v-sort-column-phrase as character no-undo .

  run waitfram-show in this-procedure ( input "Ждите...").

  case v-sort-column-name :
    when "" then do:
      assign
        v-sort-column-phrase = "":u
      .
    end.
    otherwise do:
      assign
        v-sort-column-phrase = substitute( "by &1", v-sort-column-name )
      .
    end.
  end case.

&scop flt-open-open-query open query br-route for each x_route
&scop flt-open-dyn_open-query  for each x_route
&scop flt-open-query-handle query br-route :handle
&scop flt-open-query-was-opened  l-query-was-opened
&scop flt-open-sort-column-phrase v-sort-column-phrase
&scop flt-open-call-point v-filter-point
&scop flt-open-set-filter-name set-filter-name
&scop flt-open-indexed-reposition indexed-reposition
&scop flt-open-query p-open-query
&scop flt-open-table-name x_route
&scop flt-open-search-option no-lock
&scop flt-open-find-next p-find-next
&scop flt-open-find-recid v-recid
&scop flt-open-find-condition p-find-condition
&scop flt-open-find-buffer-name x_route
&scop flt-open-waitfram false

  assign
    v-filter-point = v-filter-point0 + {&delim-par} + v-filter-pointr
    frame {&frame-name}:title = substitute( "&1", v-title0 )
  .

    { gbl/fltopend.i
      &where-cond     = "x_route.db-num = p-db-num ~
                        "
      &dyn_where-cond = "substitute( 'x_route.db-num = &2 ~
                                      ' ~
                                      ,~{&double-quote~} ~
                                      ,p-db-num ~
                                    ) ~
                        "
      &use-ind        = " "
      &by             = "by x_route.tbl-ord"
    }

  if p-open-query = false then do:
    if v-recid <> ? then do:
      reposition {&browse-name} to recid v-recid no-error .
    end.
    else do:
      message
        substitute("!") skip
        view-as alert-box information .
    end.
    if v-fltopend-rowid[1] <> ? then do:
      query br-route:handle:reposition-to-rowid(v-fltopend-rowid) no-error.
    end.
  end.

  apply "value-changed" to {&browse-name} in frame {&frame-name}.
  apply "entry" to {&browse-name} in frame {&frame-name}.

  run waitfram-hide in this-procedure .

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION conv-pck-num v-route
FUNCTION conv-pck-num returns character
  ( input p-pack-num as integer ) :
/*------------------------------------------------------------------------------
  purpose:
    notes:
------------------------------------------------------------------------------*/
  define variable p-ret-val as character no-undo.

  if p-pack-num = -1 then do:
    assign
      p-ret-val = "Нет номера"
    .
  end.
  else do:
    assign
      p-ret-val = substitute( "&1", p-pack-num )
    .
  end.

  return p-ret-val.   /* function return value. */

end function.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-descr-route v-route
FUNCTION get-descr-route returns character
  ( input p-name-rec as character, input p-uniq-key-rec as character ) :
/*------------------------------------------------------------------------------
  purpose:
    notes:
------------------------------------------------------------------------------*/
  define variable v-key-rec     like ub.route.uniq-key-rec no-undo .
  define variable v-delim-key   as   character             no-undo .
  define variable v-route-descr as   character             no-undo .

  case entry( 1, p-name-rec, {&delim-nws} ):
    when "delete":u then do:
      assign
        v-route-descr = "(удаление)" + {&space-char}
        v-delim-key   = {&delim-nws}
        v-key-rec     = substring( p-name-rec, index( p-name-rec, {&delim-nws} ) + 1 )
      .
    end.
    when "command":u then do:
      case entry( 2, p-name-rec, {&delim-nws} ):
        when "delete":u then do:
          assign
            v-route-descr = "(удаление)" + {&space-char}
            v-delim-key   = {&delim-key}
            v-key-rec     = entry( 3, p-name-rec, {&delim-nws} )
          .
        end.
        otherwise do:
          assign
            v-route-descr = "команда" + {&space-char}
            v-delim-key   = {&delim-nws}
            v-key-rec     = "":u
          .
        end.
      end.
    end.
    otherwise do:
      assign
        v-route-descr = "":u
        v-delim-key   = {&delim-key}
        v-key-rec     = p-uniq-key-rec
      .
    end.
  end case.

  if v-key-rec <> "":u then do:
    case entry( 1, v-key-rec, v-delim-key ) :
      when {&table_trn-doc} then do:
        assign
          v-route-descr = v-route-descr
                          + "складской документ n" + {&space-char} + entry( 2, v-key-rec, v-delim-key )
        .
      end.
      when {&table_price-doc} then do:
        assign
          v-route-descr = v-route-descr
                          + "переоценка n" + {&space-char} + entry( 2, v-key-rec, v-delim-key )
        .
      end.
      when {&table_fbr-doc} then do:
        assign
          v-route-descr = v-route-descr
                          + "документ производства n" + {&space-char} + entry( 2, v-key-rec, v-delim-key )
        .
      end.
      when {&table_rvs-doc} then do:
        assign
          v-route-descr = v-route-descr
                          + "сверка n" + {&space-char} + entry( 2, v-key-rec, v-delim-key )
        .
      end.
      when {&table_inkas} then do:
        assign
          v-route-descr = v-route-descr
                          + "продажа n" + {&space-char} + entry( 2, v-key-rec, v-delim-key )
        .
      end.
      when {&table_shift-obj} then do:
        assign
          v-route-descr = v-route-descr
                          + "смена n" + {&space-char} + entry( 5, v-key-rec, v-delim-key ) + {&space-char}
                          + "от" + {&space-char} + entry( 4, v-key-rec, v-delim-key ) + {&space-char}
                          + "на объекте тип:" + {&space-char} + entry( 2, v-key-rec, v-delim-key ) + {&space-char}
                          + "код:" + {&space-char} + entry( 3, v-key-rec, v-delim-key )
        .
      end.
      when {&table_clients} then do:
        assign
          v-route-descr = v-route-descr
                          + "контрагент" + {&space-char}
                          + "тип:" + {&space-char} + entry( 2, v-key-rec, v-delim-key ) + {&space-char}
                          + "код:" + {&space-char} + entry( 3, v-key-rec, v-delim-key )
        .
      end.
      when {&table_goods} then do:
        assign
          v-route-descr = v-route-descr
                          + "товар код:" + {&space-char} + entry( 2, v-key-rec, v-delim-key )
        .
      end.
      when {&table_bar-code} then do:
        assign
          v-route-descr = v-route-descr
                          + "бар-код" + {&space-char} + entry( 2, v-key-rec, v-delim-key )
        .
      end.
      when {&table_prod-bc} then do:
        assign
          v-route-descr = v-route-descr
                          + "доп. код" + {&space-char} + entry( 3, v-key-rec, v-delim-key ) + {&space-char}
                          + "для бар-кода" + {&space-char} + entry( 2, v-key-rec, v-delim-key )
        .
      end.
      when {&table_gds-grp} then do:
        assign
          v-route-descr = v-route-descr
                          + "группа товаров код:" + {&space-char} + entry( 2, v-key-rec, v-delim-key )
        .
      end.
      when {&table_cli-grp} then do:
        assign
          v-route-descr = v-route-descr
                          + "группа клиентов код:" + {&space-char} + entry( 2, v-key-rec, v-delim-key )
        .
      end.
      when {&table_db} then do:
        assign
          v-route-descr = v-route-descr
                          + "УБД" + {&space-char} + entry( 2, v-key-rec, v-delim-key )
        .
      end.
      when {&table_recipe} then do:
        assign
          v-route-descr = v-route-descr
                          + "рецепт" + {&space-char} + entry( 2, v-key-rec, v-delim-key )
        .
      end.
      when {&table_config} then do:
        assign
          v-route-descr = v-route-descr
                          + "настроечный параметр" + {&space-char} + entry( 2, v-key-rec, v-delim-key )
        .
      end.
      otherwise do:
        assign
          v-route-descr = "Без расшифровки --->"
        .
      end.
    end case.
  end.
  else do:
    case entry( 2, p-name-rec, v-delim-key ) :
      when "goods":u then do:
        if entry( 3, p-name-rec, v-delim-key ) = "ren-art":u then do:
          assign
            v-route-descr = v-route-descr
                            + "переименование товара" + {&space-char}
                            + entry( 4, p-name-rec, v-delim-key ) + {&space-char}
                            + "ст. арт." + {&space-char} + entry( 5, p-name-rec, v-delim-key ) + {&space-char}
                            + "ст. тип пр." + {&space-char} + entry( 6, p-name-rec, v-delim-key ) + {&space-char}
                            + "ст. код пр." + {&space-char} + entry( 7, p-name-rec, v-delim-key ) + {&space-char}
                            + "н. арт." + {&space-char} + entry( 8, p-name-rec, v-delim-key ) + {&space-char}
                            + "н. тип пр." + {&space-char} + entry( 9, p-name-rec, v-delim-key ) + {&space-char}
                            + "н. код пр." + {&space-char} + entry( 10, p-name-rec, v-delim-key )
          .
        end.
      end.
      otherwise do:
        assign
          v-route-descr = "Без расшифровки --->"
        .
      end.
    end case.
  end.

  return v-route-descr .

end function.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-gate-file-name-f v-route 
FUNCTION get-gate-file-name-f returns character
  ( p-gate-rec as character ) :

  define variable v-gate-file-name as character no-undo.

  if p-gate-rec > '':u then do:
    run get-gate-file-name in this-procedure ( input p-gate-rec
                                            ,output v-gate-file-name) no-error.
    if error-status:error then do:
      v-gate-file-name = "!!!???? ?? ??????".
    end.
  end.
  return v-gate-file-name.

end function.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

