&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список дополнительных расходов

Автор: Чернова Светлана Александровна
Дата создания: 03/19/02
Author: Svetlana Chernova
Creation date: 03/19/02

*/
define input parameter   parParentProc  as widget-handle no-undo.
define input parameter   bttns          as character no-undo .
define output parameter  p-rid-list     as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список дополнительных расходов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ cmp/gds-list.i gds-list def "new shared" }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ str/adddocfn.i }



define variable log-res as log no-undo.
define variable rr as recid no-undo.
define variable v-log as logical   no-undo .

define variable line-mode as character no-undo .
define variable doc-rec as recid no-undo .
define variable gds-rec as recid no-undo .
define variable lns-cnt as integer   no-undo .
define variable g#log as logical   no-undo .
define variable alg as character no-undo .

define temp-table tt-gds-list no-undo like ub.goods
field nn as integer
index by-nn nn
index by_gds-code gds-code
.
define variable varschartic       like ub.goods.artic initial " " no-undo.
define variable ref-list  as character                     no-undo.

define variable sch-field as character no-undo.
define buffer buf_gds-add-charges for ub.gds-add-charges.  /* для поиска по номеру, дате, факт */
define buffer buf_goods      for ub.goods.  /* для поиска по номеру, дате, факт */

&Scoped-define OPEN-QUERY-BROWSE-2-alt OPEN QUERY BROWSE-2 FOR EACH ub.gds-add-charges ~
            NO-LOCK, ~
      EACH ub.goods where ~
      ub.goods.gds-code = ub.gds-add-charges.gds-code and ~
      INDEX(ub.goods.gds-name,s-name-cnt) > 0 ~
      NO-LOCK ~{&SORTBY-PHRASE}.

define variable sort-column-name as character no-undo .
define variable list-option as character no-undo.
define stream sout.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-2

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.gds-add-charges ub.goods

/* Definitions for BROWSE BROWSE-2                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 mark-string(buffer ub.goods , p-rid-list) ub.goods.artic ub.goods.gds-name ub.goods.unit-base alg-name(buffer ub.gds-add-charges) @ alg ub.goods.gds-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2 ub.goods.artic
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-2 ub.goods
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-2 ub.goods
&Scoped-define SELF-NAME BROWSE-2
&Scoped-define QUERY-STRING-BROWSE-2 FOR EACH                           ub.gds-add-charges NO-LOCK, ~
                                 EACH ub.goods WHERE                           ub.goods.gds-code = ub.gds-add-charges.gds-code and                           ub.goods.stts = 0                           NO-LOCK     ~{&SORTBY-PHRASE}
&Scoped-define OPEN-QUERY-BROWSE-2 OPEN QUERY {&SELF-NAME} FOR EACH                           ub.gds-add-charges NO-LOCK, ~
                                 EACH ub.goods WHERE                           ub.goods.gds-code = ub.gds-add-charges.gds-code and                           ub.goods.stts = 0                           NO-LOCK     ~{&SORTBY-PHRASE}.
&Scoped-define TABLES-IN-QUERY-BROWSE-2 ub.gds-add-charges ub.goods
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2 ub.gds-add-charges
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-2 ub.goods


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-2}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-help R-sort s-artic BROWSE-2 ~
FILL-IN-2 mark-num
&Scoped-Define DISPLAYED-OBJECTS R-sort s-name s-name-cnt s-artic FILL-IN-2 ~
mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER
( buffer loc-table for ub.goods, input mark-list as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход ":L
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-print
     LABEL "Пе&чать":L
     SIZE 10 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор ":L
     SIZE 10 BY 1.

DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Поиск по"
      VIEW-AS TEXT
     SIZE 8.88 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 9 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE s-artic AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 30 BY 1
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE s-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 30 BY 1
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE s-name-cnt AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 30 BY 1
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE R-sort AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Артик", 1,
"Нач.назв", 2,
"Нач.слова", 3
     SIZE 34.63 BY .96 TOOLTIP "Поиск по" NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-2 FOR
      ub.gds-add-charges,
      ub.goods SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2 Dialog-Frame _FREEFORM
  QUERY BROWSE-2 NO-LOCK DISPLAY
      mark-string(buffer ub.goods , p-rid-list) FORMAT "X(1)":U COLUMN-LABEL "*"
      ub.goods.artic FORMAT "X(16)":U
      ub.goods.gds-name FORMAT "X(48)":U
      ub.goods.unit-base FORMAT "X(3)":U
      alg-name(buffer ub.gds-add-charges) @ alg FORMAT "X(30)":U COLUMN-LABEL "Алгоритм включения в учетную цену"
      ub.goods.gds-code FORMAT "999999999":U
     ENABLE
          ub.goods.artic
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.5 BY 18.33
         BGCOLOR 15 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-sel AT ROW 1 COL 11
     B-mark AT ROW 1 COL 21
     b-print AT ROW 1 COL 54
     b-help AT ROW 1 COL 78
     R-sort AT ROW 2.04 COL 10.75 NO-LABEL
     s-name AT ROW 2.04 COL 44.13 COLON-ALIGNED NO-LABEL
     s-name-cnt AT ROW 2.04 COL 44.13 COLON-ALIGNED NO-LABEL
     s-artic AT ROW 2.04 COL 44.13 COLON-ALIGNED NO-LABEL
     BROWSE-2 AT ROW 3.71 COL 1
     FILL-IN-2 AT ROW 2.21 COL 1 NO-LABEL
     mark-num AT ROW 2.96 COL 1 NO-LABEL
     SPACE(89.74) SKIP(18.41)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Товары по сезону".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-2 s-artic Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-mark IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-print IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-sel IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-2 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN s-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN s-name-cnt IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-2
/* Query rebuild information for BROWSE BROWSE-2
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH
                          ub.gds-add-charges NO-LOCK,
                          EACH ub.goods WHERE
                          ub.goods.gds-code = ub.gds-add-charges.gds-code and
                          ub.goods.stts = 0
                          NO-LOCK
    ~{&SORTBY-PHRASE}.
     _END_FREEFORM
     _Options          = "NO-LOCK SORTBY-PHRASE"
     _TblOptList       = ","
     _JoinCode[2]      = "goods.gds-code = ub.gds-add-charges.gds-code"
     _Query            is OPENED
*/  /* BROWSE BROWSE-2 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Товары по сезону */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable loc#log as logical no-undo .
  if AVAILABLE {&second-TABLE-IN-QUERY-{&BROWSE-NAME}}  then do:
    { gbl/markstrn.i {&second-TABLE-IN-QUERY-{&BROWSE-NAME}} p-rid-list }
    loc#log = {&BROWSE-NAME}:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = {&BROWSE-NAME}:select-next-row ().
        apply "VALUE-CHANGED" to {&BROWSE-NAME} in frame {&frame-name}.
    end.
    if num-entries( p-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( p-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to {&BROWSE-NAME} in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор  */
DO:
    if ( available ub.goods ) AND ( p-rid-list = "" ) then
        p-rid-list = string( recid( ub.goods ) ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME R-sort
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL R-sort Dialog-Frame
ON VALUE-CHANGED OF R-sort IN FRAME Dialog-Frame
DO:
  Assign frame {&frame-name} r-sort.
  case r-sort :
  when 1 then do:
        if sch-field = "s-name-cnt" then do:
                       assign frame {&frame-name}:title = "Дополнительные расходы".
                      {&OPEN-QUERY-BROWSE-2}
                      end.
        enable s-artic with frame {&frame-name}.
            Hide s-name  s-name-cnt in frame {&frame-name}.
        display s-artic with frame {&frame-name}.
   end.
  when 2 then do:
    if sch-field = "s-name-cnt" then do:
                 assign frame {&frame-name}:title = "Дополнительные расходы ".
                {&OPEN-QUERY-BROWSE-2}
                end.
        enable s-name with frame {&frame-name}.
        hide s-artic  s-name-cnt in frame {&frame-name}.
        display s-name with frame {&frame-name}.
   end.
  when 3 then do:
        enable s-name-cnt with frame {&frame-name}.
        hide s-artic  s-name in frame {&frame-name}.
        display s-name-cnt with frame {&frame-name}.
   end.

  end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME s-artic
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL s-artic Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF s-artic IN FRAME Dialog-Frame
OR  RETURN OF s-artic IN FRAME {&frame-name}
DO:
  if s-artic <> input frame {&frame-name} s-artic or sch-field <> "s-artic" then do:

 sch-field = "s-artic".
 assign s-artic = input frame {&frame-name} s-artic.

 doc-rec = ?.
 for each buf_gds-add-charges no-lock ,
            first buf_goods no-lock where
                  buf_goods.gds-code = buf_gds-add-charges.gds-code and
                  buf_goods.artic begins s-artic :
         doc-rec = recid ( buf_gds-add-charges ) .
         leave.
 end.
  if doc-rec = ? then message "Товар не найден !"  .
  else
      reposition {&browse-name} to recid doc-rec no-error.

return no-apply.
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME s-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL s-name Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF s-name IN FRAME Dialog-Frame
OR  RETURN OF s-name IN FRAME {&frame-name}
DO:
  if s-name <> input frame {&frame-name} s-name or sch-field <> "s-name" then do:

 sch-field = "s-name".
 assign s-name = input frame {&frame-name} s-name.

 doc-rec = ?.
 for each buf_gds-add-charges no-lock ,
            first buf_goods no-lock where
                  buf_goods.gds-code = buf_gds-add-charges.gds-code and
                  buf_goods.gds-name begins s-name
                  :
         doc-rec = recid(buf_gds-add-charges) .
         leave.
 end.
  if doc-rec = ? then message "Товар не найден !"  .
  else
      reposition {&browse-name} to recid doc-rec no-error.

return no-apply.
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME s-name-cnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL s-name-cnt Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF s-name-cnt IN FRAME Dialog-Frame
OR  RETURN OF s-name-cnt IN FRAME {&frame-name}
DO:
  if s-name-cnt <> input frame {&frame-name} s-name-cnt or sch-field <> "s-name-cnt" then do:

 sch-field = "s-name-cnt".
 assign s-name-cnt = input frame {&frame-name} s-name-cnt.

 doc-rec = ?.
 for each buf_gds-add-charges no-lock ,
            first buf_goods no-lock where
                  buf_goods.gds-code = buf_gds-add-charges.gds-code  and
            INDEX (buf_goods.gds-name,s-name-cnt) > 0
            :
         doc-rec = recid(buf_gds-add-charges) .
         leave.
 end.
  if doc-rec = ? then message "Товар не найден !"  .
  else do:
     assign frame {&frame-name}:title = "Дополнительные расходы , содержащие в названии " + s-name-cnt .
      {&OPEN-QUERY-BROWSE-2-alt}
     /* reposition {&browse-name} to recid doc-rec no-error. */
     end.
return no-apply.
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-2
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

assign frame {&frame-name}:title = "Дополнительные расходы".

{ gbl/srt-clmn.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "ub.goods.artic"
  &sort-clmn_2    = "ub.goods.gds-name"
  &sort-clmn_3    = "ub.goods.unit-base"
  &sort-clmn_4    = "alg"
  &open-query     = "run OpenBr."
  &open-query-otherwise = "run OpenBr."
  &sort-column-name     = "sort-column-name"
  &re-move-clmn         = "no"
  &mv-brw-default       = "no" }

 { gbl/f2.i {&browse-name} " " " " parParentProc }
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

ub.goods.artic:READ-ONLY = TRUE.
ub.goods.artic:resizable = true .
ub.goods.gds-name:resizable = true .
  run     enable_ui in this-procedure .
  enable  s-artic
          B-mark when LOOKUP("b-mark":U, bttns) > 0
          B-sel when LOOKUP("b-sel":U, bttns) > 0



      with frame {&frame-name}.
  hide    s-name  s-name-cnt in frame {&frame-name}.
  display s-artic with frame {&frame-name}.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cycle-add Dialog-Frame
PROCEDURE cycle-add :
end procedure.

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
  DISPLAY R-sort s-name s-name-cnt s-artic FILL-IN-2 mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-help R-sort s-artic BROWSE-2 FILL-IN-2 mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define variable t-ret as logical no-undo .
t-ret =  session:SET-WAIT-STATE("GENERAL") .
&scop my-open-query     if r-sort = 3 and sch-field = "s-name-cnt" then do: ~
    assign frame ~{&frame-name}:title = "Дополнительные расходы , содержащие в названии " + s-name-cnt . ~
   ~{&OPEN-QUERY-BROWSE-2-alt}  ~
   end. ~
   else DO: ~
    assign frame ~{&frame-name}:title = "Дополнительные расходы " . ~
   ~{&OPEN-QUERY-BROWSE-2} ~
   end.

case sort-column-name :
  when "" then do:
    &scop SORTBY-PHRASE
    {&my-open-query}
  end.

  when "goods.artic" then do:
    &scop SORTBY-PHRASE by ub.goods.artic
    {&my-open-query}
  end.

  when "goods.gds-name" then do:
    &scop SORTBY-PHRASE by ub.goods.gds-name
    {&my-open-query}
  end.

  when "goods.unit-base" then do:
    &scop SORTBY-PHRASE by ub.goods.unit-base
    {&my-open-query}
  end.

  when "alg" then do:
    &scop SORTBY-PHRASE by ub.gds-add-charges.algoritm
    {&my-open-query}
  end.

  otherwise do:
    &scop SORTBY-PHRASE
    {&my-open-query}
  end.
end case.

t-ret =  session:SET-WAIT-STATE("") .
apply "HOME" to {&browse-name} in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-list Dialog-Frame
PROCEDURE proc-b-list :
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER
( buffer loc-table for ub.goods, input mark-list as character ) :
return ( if lookup( string( recid( loc-table ) ), mark-list ) > 0 then CHR(42) else chr(0) ).
end function.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
