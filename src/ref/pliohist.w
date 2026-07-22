&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_c-place-io FOR ub.c-place-io.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список истории мест приемки/отгрузки

Автор: Уханов Дмитрий Юрьевич
Дата создания: 02/18/09
Author: Dmitry Ukhanov
Creation date: 02/18/09

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input        parameter parparentproc   as   widget-handle               no-undo.
define input        parameter p-obj-type      like ub.clients.obj-type         no-undo .
define input        parameter p-obj-code      like ub.clients.obj-code         no-undo .
define input        parameter p-place-io-code like ub.c-place-io.place-io-code no-undo .
define input        parameter bttns           as   character                   no-undo .
define input-output parameter p-rid-list      as   character                   no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u.
define variable vss-author      as character no-undo init "$Author$":u.
define variable vss-date        as character no-undo init "$Date$":u.
define variable vss-workfile    as character no-undo init "$Workfile$":u.
define variable vss-archive     as character no-undo init "$Archive$":u.
define variable vss-description as character no-undo init "Список истории мест приемки/отгрузки":u.
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/flt-def.i }
{ gbl/waitfram.i }
{ gbl/fltfield.i }
{ cmp/library.i  }
{ gbl/usrfulnf.i }
{ gbl/fltopend.i defproc }
{ ref/tmpchgs.i }

define variable filter-point as character no-undo init "Список истории мест приемки/отгрузки" .
define variable filter-point0 as character no-undo init "Список истории мест приемки/отгрузки" .
define variable sort-column-name as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable title0 as character no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-c-place-io

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_c-place-io temp-changes

/* Definitions for BROWSE br-c-place-io                                 */
&Scoped-define FIELDS-IN-QUERY-br-c-place-io ~
mark-string(recid(X_c-place-io), p-rid-list) X_c-place-io.corr-date ~
string(X_c-place-io.corr-time,"HH:MM") ~
usrfulnf(X_c-place-io.corr-user-name) X_c-place-io.place-io-type ~
X_c-place-io.place-io-code X_c-place-io.place-io-name ~
substitute( "&1 &2", X_c-place-io.obj-type, X_c-place-io.obj-code) ~
X_c-place-io.status_ X_c-place-io.PS 
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-c-place-io 
&Scoped-define QUERY-STRING-br-c-place-io FOR EACH X_c-place-io ~
      WHERE X_c-place-io.place-io-code = p-place-io-code and X_c-place-io.obj-type = p-obj-type AND X_c-place-io.obj-code = p-obj-code NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-c-place-io OPEN QUERY br-c-place-io FOR EACH X_c-place-io ~
      WHERE X_c-place-io.place-io-code = p-place-io-code and X_c-place-io.obj-type = p-obj-type AND X_c-place-io.obj-code = p-obj-code NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-c-place-io X_c-place-io
&Scoped-define FIRST-TABLE-IN-QUERY-br-c-place-io X_c-place-io


/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes   
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-c-place-io}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-sel b-sch b-Help br-c-place-io ~
BR-changes mark-num 
&Scoped-Define DISPLAYED-OBJECTS mark-num 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD mark-string Dialog-Frame 
FUNCTION mark-string RETURNS CHARACTER
  ( input par-recid as recid, input mark-list as character)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-Help 
     LABEL "Помо&щь" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-mark 
     LABEL "&*" 
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-GO 
     LABEL "&Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sch 
     LABEL "&Фильтр" 
     SIZE 10 BY 1.

DEFINE BUTTON b-sel AUTO-GO 
     LABEL "Вы&бор" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-c-place-io FOR 
      X_c-place-io SCROLLING.

DEFINE QUERY BR-changes FOR 
      temp-changes SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-c-place-io
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-c-place-io Dialog-Frame _STRUCTURED
  QUERY br-c-place-io NO-LOCK DISPLAY
      mark-string(recid(X_c-place-io), p-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      X_c-place-io.corr-date COLUMN-LABEL "Дата!изменения" FORMAT "99/99/9999":U
      string(X_c-place-io.corr-time,"HH:MM") COLUMN-LABEL "Время!изменения" FORMAT "X(5)":U
            WIDTH 9
      usrfulnf(X_c-place-io.corr-user-name) COLUMN-LABEL "Изменил" FORMAT "X(18)":U
      X_c-place-io.place-io-type COLUMN-LABEL "Место" FORMAT "X(8)":U
      X_c-place-io.place-io-code FORMAT "9999999":U
      X_c-place-io.place-io-name COLUMN-LABEL "Наименование" FORMAT "X(40)":U
      substitute( "&1 &2", X_c-place-io.obj-type, X_c-place-io.obj-code) COLUMN-LABEL "Объект" FORMAT "X(13)":U
      X_c-place-io.status_ FORMAT "X(8)":U
      X_c-place-io.PS FORMAT "X(50)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96 BY 13.71.

DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes Dialog-Frame _FREEFORM
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(35)"
temp-changes.v_old COLUMn-LABEL "Было" format "X(40)"
temp-changes.v_new COLUMn-LABEL "Стало" format "X(40)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 95.88 BY 5.83.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     b-sch AT ROW 1 COL 41
     b-Help AT ROW 1 COL 86.25
     br-c-place-io AT ROW 2 COL 1.38
     BR-changes AT ROW 16.04 COL 1.38
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     SPACE(77.49) SKIP(20.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "История изменения мест прима/отгрузки"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_c-place-io B "?" ? ub c-place-io
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-c-place-io b-Help Dialog-Frame */
/* BROWSE-TAB BR-changes br-c-place-io Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON b-mark IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       br-c-place-io:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 1.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-c-place-io
/* Query rebuild information for BROWSE br-c-place-io
     _TblList          = "X_c-place-io"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "X_c-place-io.place-io-code = p-place-io-code and X_c-place-io.obj-type = p-obj-type AND X_c-place-io.obj-code = p-obj-code"
     _FldNameList[1]   > "_<CALC>"
"mark-string(recid(X_c-place-io), p-rid-list)" "*" "X(1)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > Temp-Tables.X_c-place-io.corr-date
"X_c-place-io.corr-date" "Дата!изменения" ? "date" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > "_<CALC>"
"string(X_c-place-io.corr-time,""HH:MM"")" "Время!изменения" "X(5)" ? ? ? ? ? ? ? no ? no no "9" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > "_<CALC>"
"usrfulnf(X_c-place-io.corr-user-name)" "Изменил" "X(18)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > Temp-Tables.X_c-place-io.place-io-type
"X_c-place-io.place-io-type" "Место" ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   = Temp-Tables.X_c-place-io.place-io-code
     _FldNameList[7]   > Temp-Tables.X_c-place-io.place-io-name
"X_c-place-io.place-io-name" "Наименование" ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[8]   > "_<CALC>"
"substitute( ""&1 &2"", X_c-place-io.obj-type, X_c-place-io.obj-code)" "Объект" "X(13)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[9]   = Temp-Tables.X_c-place-io.status_
     _FldNameList[10]   = Temp-Tables.X_c-place-io.PS
     _Query            is OPENED
*/  /* BROWSE br-c-place-io */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-changes
/* Query rebuild information for BROWSE BR-changes
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-changes */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON ENDKEY OF FRAME Dialog-Frame /* История изменения мест прима/отгрузки */
DO:
    run gbl/markqwa.p ( input b-mark:sensitive, input p-rid-list) no-error.
    if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
define variable loc#log as logical no-undo .
  if available X_c-place-io then do:
      if can-do( p-rid-list, string( recid( X_c-place-io ) ) ) then do:
          p-rid-list = replace( p-rid-list, {&comma-char} + string( recid( X_c-place-io ) ), "") .
          p-rid-list = replace( p-rid-list, string( recid( X_c-place-io ) ) + {&comma-char}, "") .
          p-rid-list = replace( p-rid-list, string( recid( X_c-place-io ) ), "") .
      end.
      else
      p-rid-list = p-rid-list + ( if p-rid-list = "" then "" else {&comma-char} ) + string( recid( X_c-place-io ) ) .
      loc#log = br-c-place-io:refresh() .

      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
          loc#log = br-c-place-io:select-next-row ().
          apply "VALUE-CHANGED" to br-c-place-io in frame {&frame-name}.
      end.
      if num-entries( p-rid-list ) = 0 then hide mark-num in frame {&frame-name}.
      else disp num-entries( p-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-c-place-io in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch Dialog-Frame
ON CHOOSE OF b-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  assign
    tbl = 'c-place-io'
    join-tbl = 'X_c-place-io'
    fld = ""
    lab = ""
    spr = ""
    dim = '0'
  .
  run fltfield-add in this-procedure('obj-code', 'Код объекта', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('obj-type', 'Тип объекта', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('place-io-type', 'Тип места', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('place-io-code', 'Код места', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('place-io-name', 'Название места', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('status_', 'Статус', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('PS', 'Примечание', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

Filter-Block:
  DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
     ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
     ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
    run gbl/filter.w ( INPUT parparentproc, INPUT filter-point, INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
    RUN OpenBr(yes, no, '':U).
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if ( available X_c-place-io ) AND ( p-rid-list = "" ) then  p-rid-list = string( recid( X_c-place-io ) ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-c-place-io
&Scoped-define SELF-NAME br-c-place-io
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-c-place-io Dialog-Frame
ON RETURN OF br-c-place-io IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-c-place-io IN FRAME Dialog-Frame
DO:
  if b-sel:sensitive in frame {&frame-name} then
    if b-mark:sensitive then apply "choose" to b-mark in frame {&frame-name}.
    else                     apply "choose" to b-sel in frame {&frame-name}.
/*  else if b-lookup:sensitive then apply "choose" to b-lookup in frame {&frame-name}.*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-c-place-io Dialog-Frame
ON VALUE-CHANGED OF br-c-place-io IN FRAME Dialog-Frame
DO:

  define variable v-label-param as character no-undo .

  if available X_c-place-io then do:
    assign
      v-label-param =
        "place-io-code" + {&delim-par} + "Номер" + {&delim-par} + "" + {&delim-flf}
      + "place-io-name" + {&delim-par} + "Наименование" + {&delim-par} + "" + {&delim-flf}
      + "place-io-type" + {&delim-par} + "Тип" + {&delim-par} + "" + {&delim-flf}
      + "PS" + {&delim-par} + "Примечание" + {&delim-par} + "" + {&delim-flf}
      + "status_" + {&delim-par} + "Статус" + {&delim-par} + ""
    .
    run proc-full-temp-changes in this-procedure
      ( input (buffer X_c-place-io:handle)
       ,input {&table_place-io}
       ,input "place-io-code,place-io-name,place-io-type,PS,status_":U
       ,input v-label-param
      ) no-error.
  end.
  else do:
    for each temp-changes
    :
      delete temp-changes .
    end.
  end.
  {&OPEN-QUERY-BR-changes}

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
{ gbl/setfltnm.i }

{ gbl/srt-clmd.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "X_c-place-io.place-io-code"
  &open-query     = "run OpenBr(yes, no, no)."
  &open-query-otherwise = "run OpenBr(yes, no, no)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn = "no"
  &mv-brw-default = "no"
}
/*  &sort-clmn_2    = "X_c-place-io.corr-user-name"*/


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  if p-place-io-code <> ?
    and p-place-io-code <> 0
  then do:
    assign
      title0 = substitute("История изменения места приема/отгрузки. Код: &1", p-place-io-code )
    .
  end.
  else do:
    assign
      title0 = substitute("История изменения мест приема/отгрузки." )
    .
  end.

  if p-obj-code <> ?
    and p-obj-code <> 0
    and p-obj-type <> "":U
  then do:
    assign
      title0 = substitute("&1 Объект: &2 &3", title0, p-obj-type, p-obj-code )
    .
  end.


  ENABLE
    b-quit
    b-sel  when lookup( bttns, "b-sel" ) > 0
    b-mark when lookup( bttns, "b-mark" ) > 0
    b-sch
    b-Help
    br-c-place-io
    br-changes
    WITH FRAME Dialog-Frame.

  VIEW FRAME Dialog-Frame.

  assign
    temp-changes.l_name:resizable in browse br-changes = true
    temp-changes.v_old:resizable in browse br-changes = true
    temp-changes.v_new:resizable in browse br-changes = true
    temp-changes.l_name:width in browse br-changes = 33
    temp-changes.v_old:width in browse br-changes = 30
    temp-changes.v_new:width in browse br-changes = 30
  .

  RUn OpenBR(yes, no, '':U).
  HIDE mark-num in frame {&frame-name} .

  if p-rid-list <> "":U then do:
    assign
      v-doc-rec = integer(entry(1, p-rid-list))
    .
  end.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame 
PROCEDURE OpenBr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .

  define variable l-query-was-opened as logical no-undo .
  define variable sort-column-phrase as character no-undo .

  case sort-column-name :
    when "" then assign sort-column-phrase = ""  .
    otherwise    assign sort-column-phrase = "by " + sort-column-name  .
  end case.

  &scop flt-open-query-handle  QUERY br-c-place-io:handle
  &scop flt-open-dyn_open-query  FOR EACH X_c-place-io
  &scop flt-open-open-query OPEN QUERY br-c-place-io FOR EACH X_c-place-io
  &scop flt-open-open-query-tail
  &scop flt-open-query-was-opened  l-query-was-opened
  &scop flt-open-sort-column-phrase sort-column-phrase
  &scop flt-open-call-point filter-point
  &scop flt-open-set-filter-name set-filter-name
  &scop flt-open-indexed-reposition indexed-reposition
  &scop flt-open-query p-open-query
  &scop flt-open-table-name X_c-place-io
  &scop flt-open-search-option no-lock
  &scop flt-open-find-next p-find-next
  &scop flt-open-find-recid v-doc-rec
  &scop flt-open-find-condition p-find-condition
  &scop flt-open-find-buffer-name X_c-place-io

  define variable l-open-query as logical   no-undo .
  filter-point = filter-point0 .

  ASSIGN frame {&frame-name}:TITLE = title0 .
  { gbl/fltopend.i
    &where-cond = " X_c-place-io.obj-type = p-obj-type AND X_c-place-io.obj-code = p-obj-code  AND X_c-place-io.place-io-code  = p-place-io-code "
    &DYN_where-cond = " substitute(' X_c-place-io.obj-type = &4&1&4 AND X_c-place-io.obj-code  = &2 AND X_c-place-io.place-io-code  = &3 ', p-obj-type, p-obj-code, p-place-io-code, ~{&double-quote~}) "
    &use-ind    = "  "
    &by         = "  "
  }

  REPOSITION br-c-place-io to recid v-doc-rec No-ERROR.
  if error-status:error then REPOSITION br-c-place-io to row 1 No-ERROR.
  else  REPOSITION br-c-place-io to row 7 No-ERROR.
/*  br-c-place-io:SET-REPOSITIONED-ROW( 7, "CONDITIONAL") .*/
/*    { gbl/brwrepos.i }*/
/*  end.*/
  {&SetCursorNo}
  apply "value-changed" to br-c-place-io in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION mark-string Dialog-Frame 
FUNCTION mark-string RETURNS CHARACTER
  ( input par-recid as recid, input mark-list as character) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
RETURN ( IF LOOKUP( STRING( par-recid ), mark-list ) > 0 THEN "*" ELSE "":U ).

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

