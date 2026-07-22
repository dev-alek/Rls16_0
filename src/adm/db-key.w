&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-db
/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник использованых ключей баз данных

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/02
Author: Dmitry Ukhanov
Creation date: 03/22/02

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input parameter p-ParentProc as handle no-undo.

define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Справочник использованых ключей баз данных" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/trg-def.i  }
{ adm/db-key.i   }
{ cmp/r-pril.i   }
{ gbl/prn-lib.i  }
{ gbl/cur-time.i }
/* Local Variable Definitions ---                                       */

define variable log-res       as logical   no-undo .
define variable v-rowid       as rowid     no-undo .
define variable v-type-unload as character no-undo .

define temp-table tt_key no-undo
  field num-pp as integer
  field db-key as character
  index pi as unique primary num-pp
  index pii as unique db-key
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME d-db
&Scoped-define BROWSE-NAME br-curr-db

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.db tt_key

/* Definitions for BROWSE br-curr-db                                    */
&Scoped-define FIELDS-IN-QUERY-br-curr-db ub.db.db-num ub.db.db-key ~
ub.db.db-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-curr-db
&Scoped-define QUERY-STRING-br-curr-db FOR EACH ub.db NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-curr-db OPEN QUERY br-curr-db FOR EACH ub.db NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-curr-db ub.db
&Scoped-define FIRST-TABLE-IN-QUERY-br-curr-db ub.db


/* Definitions for BROWSE br-last-key                                   */
&Scoped-define FIELDS-IN-QUERY-br-last-key tt_key.db-key
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-last-key
&Scoped-define SELF-NAME br-last-key
&Scoped-define QUERY-STRING-br-last-key FOR EACH tt_key
&Scoped-define OPEN-QUERY-br-last-key OPEN QUERY {&SELF-NAME} FOR EACH tt_key.
&Scoped-define TABLES-IN-QUERY-br-last-key tt_key
&Scoped-define FIRST-TABLE-IN-QUERY-br-last-key tt_key


/* Definitions for DIALOG-BOX d-db                                      */
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-db ~
    ~{&OPEN-QUERY-br-curr-db}~
    ~{&OPEN-QUERY-br-last-key}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-exp b-help br-curr-db br-last-key

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exp DEFAULT
     LABEL "&Экспорт":L
     SIZE 10 BY 1.

DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь":L
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY DEFAULT
     LABEL "&Выход ":L
     SIZE 10 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-curr-db FOR
      ub.db SCROLLING.

DEFINE QUERY br-last-key FOR
      tt_key SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-curr-db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-curr-db d-db _STRUCTURED
  QUERY br-curr-db NO-LOCK DISPLAY
      ub.db.db-num FORMAT ">>>>9":U
      ub.db.db-key COLUMN-LABEL "Ключ БД" FORMAT "X(12)":U WIDTH 11.75
      ub.db.db-name COLUMN-LABEL "Название БД" FORMAT "X(40)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 57.5 BY 18.

DEFINE BROWSE br-last-key
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-last-key d-db _FREEFORM
  QUERY br-last-key DISPLAY
      tt_key.db-key FORMAT "X(12)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 14.75 BY 18 ROW-HEIGHT-CHARS .67.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-db
     b-quit AT ROW 1.21 COL 2
     b-exp AT ROW 1.21 COL 12
     b-help AT ROW 1.21 COL 65
     br-curr-db AT ROW 4 COL 2
     br-last-key AT ROW 4 COL 61
     "Использованые" VIEW-AS TEXT
          SIZE 13.5 BY .75 AT ROW 2.5 COL 61
     "ключи БД" VIEW-AS TEXT
          SIZE 9 BY .67 AT ROW 3.25 COL 64
     "Текущие ключи БД" VIEW-AS TEXT
          SIZE 18.5 BY .67 AT ROW 2.75 COL 17
     SPACE(41.24) SKIP(18.99)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Ключи БД":L.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-db
                                                                        */
/* BROWSE-TAB br-curr-db b-help d-db */
/* BROWSE-TAB br-last-key br-curr-db d-db */
ASSIGN
       FRAME d-db:SCROLLABLE       = FALSE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-curr-db
/* Query rebuild information for BROWSE br-curr-db
     _TblList          = "ub.db"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   = ub.db.db-num
     _FldNameList[2]   > ub.db.db-key
"db-key" "Ключ БД" "X(12)" "character" ? ? ? ? ? ? no ? no no "11.75" yes no no "U" "" ""
     _FldNameList[3]   > ub.db.db-name
"db-name" "Название БД" ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _Query            is OPENED
*/  /* BROWSE br-curr-db */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-last-key
/* Query rebuild information for BROWSE br-last-key
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt_key.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-last-key */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-exp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exp d-db
ON CHOOSE OF b-exp IN FRAME d-db /* Экспорт */
DO:
  define variable v-single-line as character no-undo .
  define variable sym1 as character init ":" no-undo .
  define variable sym2 as character init ":" no-undo .
  define variable sym3 as character init ":" no-undo .
  define variable sym4 as character init ":" no-undo .

  define buffer buf-prn_db for ub.db .

  define frame f-db-key
      sym1 column-label ":" format "X(1)"
      buf-prn_db.db-num COLUMN-LABEL "БД" format ">>>9"
      sym2 column-label ":" format "X(1)"
      buf-prn_db.db-key COLUMN-LABEL "Ключ БД" format "X(12)"
      sym3 column-label ":" format "X(1)"
      buf-prn_db.db-name COLUMN-LABEL "Наименование БД" format "X(112)"
      sym4 column-label ":" format "X(1)" space(0)
    header
      substitute( "Текущие значения ключей БД (&1)", cur-time-print() ) format "X(62)"
      substitute( "Страница &1", PAGE-NUMBER( PrnLibStream ) ) at 110 format "X(13)" SKIP
      v-single-line format "X(136)" at 1
    with width {&DOS_CW} down stream-io.

  define frame f-old-db-key
      sym1 column-label ":" format "X(1)"
      tt_key.num-pp COLUMN-LABEL "N п/п" format ">>>,>>>,>>9"
      sym2 column-label ":" format "X(1)"
      tt_key.db-key COLUMN-LABEL "Ключ БД" format "X(12)"
      sym3 column-label ":" format "X(1)" space(0)
    header
      "Использованные ключи БД" SKIP
      cur-time-print() format "X(40)" SKIP
      substitute( "Страница &1", PAGE-NUMBER( PrnLibStream ) ) format "X(13)" SKIP
      v-single-line format "X(30)" at 1
    with width {&DOS_CW} down stream-io.


  run prn-lib-open-stream  in this-procedure
    ( input p-ParentProc
     ,input {&CS_PS}
     ,input yes /*p-is-stream*/
     ,input no /*p-append*/
    ).

  form with frame f-db-key .
  assign
    v-single-line = fill("-", 136)
  .

  form header
      v-single-line format "x(136)" at 1 skip
      "Продолжение - на следующей странице" at 30 skip
      with frame bottomframe width {&a4_cw} page-bottom no-labels no-box .

  view stream PrnLibStream frame bottomframe .

  run fill-tt_key in this-procedure.

  for each buf-prn_db no-lock
  on error undo, return no-apply
  :
    display stream PrnLibStream
      sym1
      buf-prn_db.db-num
      sym2
      buf-prn_db.db-key
      sym3
      buf-prn_db.db-name
      sym4
    with frame f-db-key .
    down stream PrnLibStream 1 with frame f-db-key .
  end.
  put stream PrnLibStream
    v-single-line format "x(136)" skip(2)
  .

  form with frame f-old-db-key .
  assign
    v-single-line = fill("-", 30)
  .

  for each tt_key
  on error undo, return no-apply
  :
    display stream PrnLibStream
      sym1
      tt_key.num-pp
      sym2
      tt_key.db-key
      sym3
    with frame f-old-db-key .
    down stream PrnLibStream 1 with frame f-old-db-key .
  end.

  hide stream PrnLibStream frame BottomFrame .

  put stream PrnLibStream
    v-single-line format "x(30)" skip
  .

  output stream PrnLibStream close.

  run prn-lib-prn-file in this-procedure
    ( input p-ParentProc
     ,input 0
    ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-curr-db
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-db


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON STOP    UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/app_help.i }

  session:data-entry-return = yes .

  run fill-tt_key in this-procedure.

  RUN enable_UI.

  {&OPEN-BROWSERS-IN-QUERY-d-db}
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.

END.

for each tt_key :
  delete tt_key.
end.

RUN disable_UI.
session:data-entry-return = no .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-db  _DEFAULT-DISABLE
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
  HIDE FRAME d-db.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-db  _DEFAULT-ENABLE
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
  ENABLE b-quit b-exp b-help br-curr-db br-last-key
      WITH FRAME d-db.
  {&OPEN-BROWSERS-IN-QUERY-d-db}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tt_key d-db
PROCEDURE fill-tt_key :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define buffer buf_rep for ub.rep .

  define variable v-num-entries as integer no-undo .
  define variable v-ind         as integer no-undo .

  for each tt_key
  on error undo, return error
  :
    delete tt_key.
  end.

  find first buf_rep
    where buf_rep.rep-num = 1996011200
    no-error
  .
  if available buf_rep then do:
    assign
      v-num-entries = num-entries( buf_rep.name1 )
    .
    do v-ind = 1 to v-num-entries
    on error undo, return error
    :
      if trim( entry( v-ind, buf_rep.name1 ) ) <> "":U then do:
        create tt_key.
        assign
          tt_key.num-pp = v-ind
          tt_key.db-key = entry( v-ind, buf_rep.name1 )
        .
      end.
    end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
