&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME v-route
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS v-route
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр маршрутизации по заданой ВС

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/17/08
Author: Bakhtadze Natalya
Creation date: 02/17/08

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter p-esys-id like ub.ext-system.esys-id no-undo.
define input parameter p-db-num like ub.ext-system.db-num no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр маршрутизации по заданой ВС".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ gbl/waitfram.i }
{ gbl/gate-clb.i }

define temp-table tt-esys-route no-undo
  field esr-name-rec     like ub.esys-route.esr-name-rec
  field esr-uniq-key-rec like ub.esys-route.esr-uniq-key-rec
  field uniq-gate-rec like ub.esys-route.uniq-gate-rec
  field ord-num      like ub.esys-route.esr-tbl-ord
  field esr-pack-num     like ub.esys-route.esr-last-pack    column-label "Пакет"
  field esys-id      like ub.esys-route.esys-id
  field db-num       like ub.esys-route.db-num
  field esr-CreUserName  like ub.esys-route.esr-CreUserName
  field esr-CreDate      like ub.esys-route.esr-CreDate
  field esr-CreTime      like ub.esys-route.esr-CreTime
  field descr        as character               column-label "Информация"
  field rec-rowid    as rowid
  index pi  is primary unique esys-id db-num ord-num
  index pii  ord-num
  index piii rec-rowid
  .

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
&Scoped-define INTERNAL-TABLES tt-esys-route

/* Definitions for BROWSE br-route                                      */
&Scoped-define FIELDS-IN-QUERY-br-route tt-esys-route.esr-pack-num tt-esys-route.descr tt-esys-route.esr-name-rec tt-esys-route.esr-uniq-key-rec tt-esys-route.esr-CreUserName tt-esys-route.esr-CreDate tt-esys-route.esr-CreTime tt-esys-route.uniq-gate-rec get-gate-file-name-f(tt-esys-route.uniq-gate-rec)
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-route
&Scoped-define SELF-NAME br-route
&Scoped-define QUERY-STRING-br-route for each tt-esys-route no-lock   by tt-esys-route.ord-num
&Scoped-define OPEN-QUERY-br-route OPEN QUERY br-route for each tt-esys-route no-lock   by tt-esys-route.ord-num .
&Scoped-define TABLES-IN-QUERY-br-route tt-esys-route
&Scoped-define FIRST-TABLE-IN-QUERY-br-route tt-esys-route


/* Definitions for DIALOG-BOX v-route                                   */
&Scoped-define OPEN-BROWSERS-IN-QUERY-v-route ~
    ~{&OPEN-QUERY-br-route}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-help t-all br-route
&Scoped-Define DISPLAYED-OBJECTS t-all

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-gate-file-name-f v-route
FUNCTION get-gate-file-name-f RETURNS CHARACTER
  ( input p-gate-rec as character )  FORWARD.

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

DEFINE VARIABLE t-all AS LOGICAL INITIAL no
     LABEL "Показать все (без расшифровки)"
     VIEW-AS TOGGLE-BOX
     SIZE 33.38 BY .79 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-route FOR
      tt-esys-route SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-route
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-route v-route _FREEFORM
  QUERY br-route NO-LOCK DISPLAY
      tt-esys-route.esr-pack-num format "-999999999"
tt-esys-route.descr format "X(255)"
tt-esys-route.esr-name-rec format "X(255)"
tt-esys-route.esr-uniq-key-rec format "X(255)"
tt-esys-route.esr-CreUserName format "X(18)"
tt-esys-route.esr-CreDate
tt-esys-route.esr-CreTime
tt-esys-route.uniq-gate-rec column-label "Гейт" format "X(255)"
get-gate-file-name-f(tt-esys-route.uniq-gate-rec) column-label "Имя Гейта" format "X(32)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 18.79.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME v-route
     b-quit AT ROW 1 COL 1
     b-help AT ROW 1 COL 95
     t-all AT ROW 2.54 COL 2.13
     br-route AT ROW 3.46 COL 1
     SPACE(0.12) SKIP(0.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "просмотр маршрутизации"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX v-route
   FRAME-NAME                                                           */
/* BROWSE-TAB br-route t-all v-route */
ASSIGN
       FRAME v-route:SCROLLABLE       = FALSE
       FRAME v-route:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-route
/* Query rebuild information for BROWSE br-route
     _START_FREEFORM
for each tt-esys-route no-lock
  by tt-esys-route.ord-num
.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Where[1]         = "esys-pck-sent.db-num = ub.db.db-num
 AND esys-pck-sent.rcvd = FALSE"
     _Query            is OPENED
*/  /* BROWSE br-route */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME v-route
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-route v-route
ON WINDOW-CLOSE OF FRAME v-route /* просмотр маршрутизации */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-route
&Scoped-define SELF-NAME br-route
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-route v-route
ON VALUE-CHANGED OF br-route IN FRAME v-route
DO:
/*
  if available tt-esys-route then do:
    display
      tt-esys-route.descr        @ f-descr
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


&Scoped-define SELF-NAME t-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-all v-route
ON VALUE-CHANGED OF t-all IN FRAME v-route /* Показать все (без расшифровки) */
DO:
  define variable v-log   as logical   no-undo .
  define variable v-rowid as rowid     no-undo .
  if available tt-esys-route then do:
    assign
      v-rowid = tt-esys-route.rec-rowid
    .
  end.
  else do:
    assign
      v-rowid = ?
    .
  end.
  assign
    t-all
  .
  run full-fill in this-procedure .

  {&OPEN-BROWSERS-IN-QUERY-v-route}

  apply "entry" to br-route in frame {&frame-name}.

  if v-rowid <> ? then do:
    find first tt-esys-route no-lock
      where tt-esys-route.rec-rowid = v-rowid
      no-error .
    if available tt-esys-route then do:
      reposition br-route to rowid rowid( tt-esys-route ) no-error .
    end.
  end.

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

  run full-fill in this-procedure .
  RUN MYenable.
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
  DISPLAY t-all
      WITH FRAME v-route.
  ENABLE b-quit b-help t-all br-route
      WITH FRAME v-route.
  VIEW FRAME v-route.
  {&OPEN-BROWSERS-IN-QUERY-v-route}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tt v-route
PROCEDURE fill-tt :
define input parameter p1-esys-id  like ub.esys-route.esys-id    no-undo .
  define input parameter p1-db-num   like ub.esys-route.db-num    no-undo .
  define input parameter p1-pack-num like ub.esys-route.esr-last-pack no-undo .
  do
  on error undo, return error
  :
    define buffer buf_esys-route for ub.esys-route .

    define variable v-key-rec     like ub.esys-route.esr-uniq-key-rec no-undo .
    define variable v-delim-key   as   character             no-undo .
    define variable v-route-descr as   character             no-undo .

    for each buf_esys-route no-lock
      where buf_esys-route.esys-id   = p1-esys-id
        and buf_esys-route.db-num    = p1-db-num
        and buf_esys-route.esr-last-pack = p1-pack-num
    on error undo, return error
    :
      case entry( 1, buf_esys-route.esr-name-rec, {&delim-nws} ):
        when "delete":U then do:
          assign
            v-route-descr = "(удаление)" + {&space-char}
            v-delim-key   = {&delim-nws}
            v-key-rec     = substring( buf_esys-route.esr-name-rec, index( buf_esys-route.esr-name-rec, {&delim-nws} ) + 1 )
          .
        end.
        when "command":U then do:
          case entry( 2, buf_esys-route.esr-name-rec, {&delim-nws} ):
            when "delete":U then do:
              assign
                v-route-descr = "(удаление)" + {&space-char}
                v-delim-key   = {&delim-key}
                v-key-rec     = entry( 3, buf_esys-route.esr-name-rec, {&delim-nws} )
              .
            end.
            otherwise do:
              assign
                v-route-descr = "команда" + {&space-char}
                v-delim-key   = {&delim-nws}
                v-key-rec     = "":U
              .
            end.
          end.
        end.
        otherwise do:
          assign
            v-route-descr = "":U
            v-delim-key   = {&delim-key}
            v-key-rec     = buf_esys-route.esr-uniq-key-rec
          .
        end.
      end case.

      if v-key-rec <> "":U then do:
        case entry( 1, v-key-rec, v-delim-key ) :
          when {&table_trn-doc} then do:
            assign
              v-route-descr = v-route-descr
                              + "складской документ N" + {&space-char} + entry( 2, v-key-rec, v-delim-key )
            .
          end.
          when {&table_price-doc} then do:
            assign
              v-route-descr = v-route-descr
                              + "переоценка N" + {&space-char} + entry( 2, v-key-rec, v-delim-key )
            .
          end.
          when {&table_fbr-doc} then do:
            assign
              v-route-descr = v-route-descr
                              + "документ производства N" + {&space-char} + entry( 2, v-key-rec, v-delim-key )
            .
          end.
          when {&table_rvs-doc} then do:
            assign
              v-route-descr = v-route-descr
                              + "сверка N" + {&space-char} + entry( 2, v-key-rec, v-delim-key )
            .
          end.
          when {&table_inkas} then do:
            assign
              v-route-descr = v-route-descr
                              + "продажа N" + {&space-char} + entry( 2, v-key-rec, v-delim-key )
            .
          end.
          when {&table_shift-obj} then do:
            assign
              v-route-descr = v-route-descr
                              + "смена N" + {&space-char} + entry( 5, v-key-rec, v-delim-key ) + {&space-char}
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
            if t-all = true then do:
              assign
                v-route-descr = "Без расшифровки --->"
              .
            end.
            else do:
              assign
                v-route-descr = "":U
              .
            end.
          end.
        end case.
      end.
      else do:
        case entry( 2, buf_esys-route.esr-name-rec, v-delim-key ) :
          when "goods":U then do:
            if entry( 3, buf_esys-route.esr-name-rec, v-delim-key ) = "ren-art":U then do:
              assign
                v-route-descr = v-route-descr
                                + "переименование товара" + {&space-char}
                                + entry( 4, buf_esys-route.esr-name-rec, v-delim-key ) + {&space-char}
                                + "ст. арт." + {&space-char} + entry( 5, buf_esys-route.esr-name-rec, v-delim-key ) + {&space-char}
                                + "ст. тип пр." + {&space-char} + entry( 6, buf_esys-route.esr-name-rec, v-delim-key ) + {&space-char}
                                + "ст. код пр." + {&space-char} + entry( 7, buf_esys-route.esr-name-rec, v-delim-key ) + {&space-char}
                                + "н. арт." + {&space-char} + entry( 8, buf_esys-route.esr-name-rec, v-delim-key ) + {&space-char}
                                + "н. тип пр." + {&space-char} + entry( 9, buf_esys-route.esr-name-rec, v-delim-key ) + {&space-char}
                                + "н. код пр." + {&space-char} + entry( 10, buf_esys-route.esr-name-rec, v-delim-key )
              .
            end.
          end.
          otherwise do:
            if t-all = true then do:
              assign
                v-route-descr = "Без расшифровки --->"
              .
            end.
            else do:
              assign
                v-route-descr = "":U
              .
            end.
          end.
        end case.

      end.

      if v-route-descr <> "":U then do:
        create tt-esys-route .
        assign
          tt-esys-route.descr        = v-route-descr
          tt-esys-route.esr-name-rec     = buf_esys-route.esr-name-rec
          tt-esys-route.esr-uniq-key-rec = buf_esys-route.esr-uniq-key-rec
          tt-esys-route.uniq-gate-rec = buf_esys-route.uniq-gate-rec
          tt-esys-route.ord-num      = buf_esys-route.esr-tbl-ord
          tt-esys-route.esys-id      = buf_esys-route.esys-id
          tt-esys-route.db-num       = buf_esys-route.db-num
          tt-esys-route.esr-pack-num     = buf_esys-route.esr-last-pack
          tt-esys-route.esr-CreUserName  = buf_esys-route.esr-CreUserName
          tt-esys-route.esr-CreDate      = buf_esys-route.esr-CreDate
          tt-esys-route.esr-CreTime      = buf_esys-route.esr-CreTime
          tt-esys-route.rec-rowid    = rowid( buf_esys-route )
        .
      end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE full-fill v-route
PROCEDURE full-fill :
define buffer buf_ext-system       for ub.ext-system.
  define buffer buf_esys-pck-sent for ub.esys-pck-sent .

  find first buf_ext-system no-lock
    where buf_ext-system.esys-id = p-esys-id
       and buf_ext-system.db-num = p-db-num
    no-error
  .
  if not available buf_ext-system then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "ВС &1 не найдена", p-esys-id )
      view-as alert-box error
    .
    return error .
  end.

  run waitfram-show in this-procedure
    (input "Подождите идет сбор информации..."
    ).

  for each tt-esys-route
  on error undo, return error
  :
    delete tt-esys-route.
  end.

  for each buf_esys-pck-sent no-lock
      where buf_esys-pck-sent.esys-id = buf_ext-system.esys-id
        and buf_esys-pck-sent.db-num = buf_ext-system.db-num
        and buf_esys-pck-sent.esps-rcvd   = FALSE
  on error undo, return error
  :
    run fill-tt in this-procedure
      ( input buf_ext-system.esys-id
       ,input buf_ext-system.db-num
       ,input buf_esys-pck-sent.esps-pack-num
      ) .
  end.
  run fill-tt in this-procedure
    ( input buf_ext-system.esys-id
     ,input buf_ext-system.db-num
     ,input -1
    ) .
  run waitfram-hide in this-procedure .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable v-route
PROCEDURE MyEnable :
assign
tt-esys-route.descr:resizable in browse br-route = yes
tt-esys-route.descr:width = 70
tt-esys-route.esr-name-rec:resizable in browse br-route = yes
tt-esys-route.esr-name-rec:width = 30
tt-esys-route.esr-uniq-key-rec:resizable in browse br-route = yes
tt-esys-route.esr-uniq-key-rec:width = 70
tt-esys-route.uniq-gate-rec:resizable in browse br-route = yes
tt-esys-route.uniq-gate-rec:width = 40
.
assign
frame {&frame-name}:title = substitute("Недошедшая информация для ВС &1",   p-esys-id )
.

DISPLAY t-all
WITH FRAME {&frame-name}.
ENABLE
b-quit
b-help
t-all
br-route
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
{&OPEN-BROWSERS-IN-QUERY-v-route}
apply "value-changed" to br-route in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-gate-file-name-f v-route
FUNCTION get-gate-file-name-f RETURNS CHARACTER
  ( input p-gate-rec as character ) :
define variable v-gate-file-name as character no-undo.
if p-gate-rec > '':U then do:
  run get-gate-file-name in this-procedure ( input p-gate-rec
                                           ,output v-gate-file-name) no-error.
  if error-status:error then do:
    v-gate-file-name = "!!!Гейт не найден".
  end.
end.
return v-gate-file-name.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
