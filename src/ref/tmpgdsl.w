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

Товары с темпами

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 03/19/02 9:08

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Товары с темпами    ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/gds-list.i gds-list def "new shared" }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }


define input  parameter parParentProc  as widget-handle no-undo.
define input  param t-code like ub.tmp-sale.tmp-code no-undo.
define input  param t-name like ub.tmp-sale.desc_ no-undo.

{ gbl/getcntxt.i get }

define variable  line-mode      as character no-undo .
define variable doc-rec as recid no-undo .
define variable gds-rec as recid no-undo .




define variable v-log as logical   no-undo .
define variable rid-list    as  char no-undo . /* список recid'ов выбранных аписей */
define variable log-res as log no-undo.
define variable rr as recid no-undo.

define temp-table tt-gds-list no-undo like ub.goods
field nn as integer
index by-nn nn
index by_gds-code gds-code
.
define variable varschartic       like ub.price-list.artic initial " " no-undo.
define variable ref-list  as char                     no-undo.

define variable sch-field as char no-undo.
def buffer t-s for ub.tmp-sale-gds.  /* для поиска по номеру, дате, факт */
def buffer t-g for ub.goods.  /* для поиска по номеру, дате, факт */

&Scoped-define OPEN-QUERY-BROWSE-2-alt OPEN QUERY BROWSE-2 FOR EACH ub.tmp-sale-gds ~
      WHERE ub.tmp-sale-gds.tmp-code = t-code NO-LOCK, ~
      EACH ub.goods where ~
      ub.goods.artic = ub.tmp-sale-gds.artic and ~
      ub.goods.prod-type = ub.tmp-sale-gds.prod-type and ~
      ub.goods.prod-code = ub.tmp-sale-gds.prod-code and ~
      INDEX(ub.goods.gds-name,s-name-cnt) > 0 ~
      NO-LOCK ~{&SORTBY-PHRASE}.

define variable sort-column-name as character no-undo .
define variable list-option as char no-undo.
define stream sout.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-2

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.tmp-sale-gds ub.goods

/* Definitions for BROWSE BROWSE-2                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 ub.goods.artic ub.goods.gds-name ~
goods.unit-base ub.tmp-sale-gds.tmp-value
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2 ub.tmp-sale-gds.tmp-value
&Scoped-define FIELD-PAIRS-IN-QUERY-BROWSE-2~
 ~{&FP1}tmp-value ~{&FP2}tmp-value ~{&FP3}
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-2 ub.tmp-sale-gds
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-2 ub.tmp-sale-gds
&Scoped-define OPEN-QUERY-BROWSE-2 OPEN QUERY BROWSE-2 FOR EACH ub.tmp-sale-gds ~
      WHERE ub.tmp-sale-gds.tmp-code = t-code NO-LOCK, ~
      EACH ub.goods WHERE ub.goods.artic = ub.tmp-sale-gds.artic ~
  AND  ub.goods.prod-code = ub.tmp-sale-gds.prod-code ~
  AND ub.goods.prod-type = ub.tmp-sale-gds.prod-type NO-LOCK ~
    ~{&SORTBY-PHRASE}.
&Scoped-define TABLES-IN-QUERY-BROWSE-2 ub.tmp-sale-gds ub.goods
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2 ub.tmp-sale-gds


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-2}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-add b-list b-help R-sort s-artic ~
BROWSE-2 FILL-IN-2 mark-num
&Scoped-Define DISPLAYED-OBJECTS R-sort s-name-cnt s-name s-artic FILL-IN-2 ~
mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU POPUP-MENU-b-list
       MENU-ITEM m_item1        LABEL "Сохранить"
       MENU-ITEM m_item2        LABEL "Загрузить"     .


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход ":L
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 10 BY 1.

DEFINE BUTTON b-list
     LABEL "Список":L
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-print
     LABEL "Пе&чать":L
     SIZE 10 BY 1.

DEFINE BUTTON b-prt
     LABEL "&Шкала":L
     SIZE 10 BY 1 TOOLTIP "Признаки товара".

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор ":L
     SIZE 10 BY 1.

DEFINE BUTTON b-upd
     LABEL "&Изменить":L
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
     SIZE 35.25 BY .96 TOOLTIP "Поиск по" NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-2 FOR
      ub.tmp-sale-gds,
      ub.goods SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2 Dialog-Frame _STRUCTURED
  QUERY BROWSE-2 NO-LOCK DISPLAY
      ub.goods.artic
      ub.goods.gds-name FORMAT "X(35)"
      ub.goods.unit-base
      ub.tmp-sale-gds.tmp-value    format ">>>>>>>>>>9.999"
  ENABLE
      ub.tmp-sale-gds.tmp-value
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 87.75 BY 18.75
         BGCOLOR 15 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-sel AT ROW 1 COL 11
     B-mark AT ROW 1 COL 21
     b-add AT ROW 1 COL 24
     b-upd AT ROW 1 COL 34
     b-prt AT ROW 1 COL 44
     b-print AT ROW 1 COL 54
     b-list AT ROW 1 COL 64
     b-help AT ROW 1 COL 79.25
     R-sort AT ROW 2.13 COL 10.63 NO-LABEL
     s-name-cnt AT ROW 2.13 COL 44 COLON-ALIGNED NO-LABEL
     s-name AT ROW 2.13 COL 44 COLON-ALIGNED NO-LABEL
     s-artic AT ROW 2.13 COL 44 COLON-ALIGNED NO-LABEL
     BROWSE-2 AT ROW 3.25 COL 1.5
     FILL-IN-2 AT ROW 2.21 COL 1 NO-LABEL
     mark-num AT ROW 2.33 COL 76.75 NO-LABEL
     SPACE(3.99) SKIP(19.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Товары".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BROWSE-2 s-artic Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-list:POPUP-MENU IN FRAME Dialog-Frame       = MENU POPUP-MENU-b-list:HANDLE.

/* SETTINGS FOR BUTTON B-mark IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-print IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-prt IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-sel IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-upd IN FRAME Dialog-Frame
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
     _TblList          = "ub.tmp-sale-gds,ub.goods WHERE ub.tmp-sale-gds ..."
     _Options          = "NO-LOCK SORTBY-PHRASE"
     _TblOptList       = ","
     _Where[1]         = "tmp-sale-gds.tmp-code = t-code"
     _JoinCode[2]      = "goods.artic = ub.tmp-sale-gds.artic
  AND  ub.goods.prod-code = ub.tmp-sale-gds.prod-code
  AND ub.goods.prod-type = ub.tmp-sale-gds.prod-type"
     _FldNameList[1]   = ub.goods.artic
     _FldNameList[2]   > ub.goods.gds-name
"goods.gds-name" ? "X(35)" "character" ? ? ? ? ? ? no ?
     _FldNameList[3]   = ub.goods.unit-base
     _FldNameList[4]   > ub.tmp-sale-gds.tmp-value
"tmp-sale-gds.tmp-value" ? ? "decimal" ? ? ? ? ? ? yes ?
     _Query            is OPENED
*/  /* BROWSE BROWSE-2 */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Товары */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
assign
  line-mode = {&add-def}
.
run str/chsgdsls.w
(   parParentProc ,
    input "temp" ,
    input "Темп продаж " + t-name  , ? , ? ,
    input v-cntxt-host-code-obj,
    input-output varschartic,
    output ref-list,
    output table tt-gds-list,
    false )
    /* no-error */.

    run cycle-add in this-procedure .
    {&OPEN-QUERY-{&BROWSE-NAME}}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-list Dialog-Frame
ON CHOOSE OF b-list IN FRAME Dialog-Frame /* Список */
DO:
    if list-option = "" then do:
    run gbl/pop-up.p (self:handle, no) no-error.
    if error-status:error then return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор  */
DO:
    if ( available ub.tmp-sale ) AND ( rid-list = "" ) then
        rid-list = string( recid( ub.tmp-sale ) ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-upd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-upd Dialog-Frame
ON CHOOSE OF b-upd IN FRAME Dialog-Frame /* Изменить */
DO:
    if not available ub.tmp-sale THEN
        return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_item1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_item1 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_item1 /* Сохранить */
DO:
   list-option = "save":U.
  run proc-b-list in this-procedure (input list-option) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_item2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_item2 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_item2 /* Загрузить */
DO:
     list-option = "load":U.
  run proc-b-list in this-procedure (input list-option) no-error.
  if error-status:error then return no-apply.


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
                       assign frame {&frame-name}:title = "Товары >> Темп продаж- " + t-name.
                      {&OPEN-QUERY-BROWSE-2}
                      end.
        enable s-artic with frame {&frame-name}.
            Hide s-name  s-name-cnt in frame {&frame-name}.
        display s-artic with frame {&frame-name}.
   end.
  when 2 then do:
    if sch-field = "s-name-cnt" then do:
                 assign frame {&frame-name}:title = "Товары >> Темп продаж- " + t-name.
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
 for each t-s where t-s.tmp-code = t-code,
     first t-g where t-s.artic = t-g.artic and
                     t-s.prod-type = t-g.prod-type and
                     t-s.prod-code = t-g.prod-code and
                     t-g.artic begins s-artic :
         doc-rec = recid(t-s) .
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
 for each t-s where t-s.tmp-code = t-code,
            first t-g where t-s.artic = t-g.artic and
                            t-s.prod-type = t-g.prod-type and
                            t-s.prod-code = t-g.prod-code and
                            t-g.gds-name begins s-name :
         doc-rec = recid(t-s) .
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
 for each t-s where t-s.tmp-code = t-code,
            first t-g where t-s.artic = t-g.artic and
                            t-s.prod-type = t-g.prod-type and
                            t-s.prod-code = t-g.prod-code and
                            INDEX(t-g.gds-name,s-name-cnt) > 0 :
         doc-rec = recid(t-s) .
         leave.
 end.
  if doc-rec = ? then message "Товар не найден !"  .
  else do:
     assign frame {&frame-name}:title = "Товары >> Темп продаж- " + t-name + " , содержащие в названии " + s-name-cnt .
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

assign frame {&frame-name}:title = "Товары >> Темп продаж- " + t-name.
 ASSIGN b-list:POPUP-MENU IN FRAME {&frame-name}   = MENU POPUP-MENU-b-list:HANDLE.
 ASSIGN b-list:MENU-MOUSE   = 1.


{ gbl/srt-clmn.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "ub.goods.artic"
  &sort-clmn_2    = "ub.goods.gds-name"
  &sort-clmn_3    = "ub.goods.unit-base"
  &sort-clmn_4    = "ub.tmp-sale-gds.tmp-value"
  &open-query     = "run OpenBr."
  &open-query-otherwise = "run OpenBr."
  &sort-column-name     = "sort-column-name"
  &re-move-clmn         = "no"
  &mv-brw-default       = "no" }

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run enable_UI in this-procedure .

  enable  s-artic with frame {&frame-name}.
  Hide      s-name  s-name-cnt in frame {&frame-name}.
  display s-artic with frame {&frame-name}.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI in this-procedure .

{ gbl/f2.i {&browse-name} " "  " "  parParentProc }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cycle-add Dialog-Frame
PROCEDURE cycle-add :
define variable lns-cnt as integer   no-undo .
define variable stp-cycl as logical no-undo .
stp-cycl = false .
for each tt-gds-list no-lock  by tt-gds-list.nn :
  lns-cnt  =  lns-cnt + 1 .
  if lns-cnt > 1 then assign line-mode = "ЦИКЛ":U.
        if not can-find (first ub.tmp-sale-gds where
                ub.tmp-sale-gds.artic     = tt-gds-list.artic and
                ub.tmp-sale-gds.prod-type = tt-gds-list.prod-type and
                ub.tmp-sale-gds.prod-code = tt-gds-list.prod-code and
                ub.tmp-sale-gds.tmp-code = t-code no-lock ) then do:
            create ub.tmp-sale-gds.
            assign
                ub.tmp-sale-gds.artic     = tt-gds-list.artic
                ub.tmp-sale-gds.prod-type = tt-gds-list.prod-type
                ub.tmp-sale-gds.prod-code = tt-gds-list.prod-code
                ub.tmp-sale-gds.tmp-code  = t-code
                ub.tmp-sale-gds.tmp-value = 0
            .
        end.
  if  stp-cycl = true then leave.
  end.
  ASSIGN lns-cnt = lns-cnt + 1 .

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame _DEFAULT-DISABLE
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame _DEFAULT-ENABLE
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
  DISPLAY R-sort s-name-cnt s-name s-artic FILL-IN-2 mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-add b-list b-help R-sort s-artic BROWSE-2 FILL-IN-2 mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE openBr Dialog-Frame
PROCEDURE openBr :
define variable t-ret as logical no-undo .
t-ret =  session:SET-WAIT-STATE("GENERAL") .
&scop my-open-query     if r-sort = 3 and sch-field = "s-name-cnt" then do: ~
    assign frame ~{&frame-name}:title = "Товары >> Темп продаж- " + t-name + " , содержащие в названии " + s-name-cnt . ~
   ~{&OPEN-QUERY-BROWSE-2-alt}  ~
   end. ~
   else DO: ~
    assign frame ~{&frame-name}:title = "Товары >> Темп продаж- " + t-name. ~
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

  when "tmp-sale-gds.tmp-value" then do:
    &scop SORTBY-PHRASE by ub.tmp-sale-gds.tmp-value
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
do
 on error undo, return error return-value
 :

define variable v-tmp-code like ub.tmp-sale-gds.tmp-code no-undo.
define input parameter loc-list-option as character no-undo.
define variable jj as integer no-undo.
define variable varrid-tmp-sale-gds as recid no-undo.
define buffer loc-tmp-sale-gds for ub.tmp-sale-gds.
define variable f-name as char init "default.cli" no-undo.
define variable imp-type like ub.goods.prod-type no-undo.
define variable imp-code like ub.goods.prod-code no-undo.
define variable       loc-gds-code  like ub.goods.gds-code no-undo.
define variable       loc-min-stock like ub.tmp-sale-gds.tmp-value no-undo.
define variable       loc-tmp-code  like ub.tmp-sale-gds.tmp-code no-undo.

v-tmp-code =  t-code .
case loc-list-option:
  when "save":U then do:
    v-log = yes.
    message "Сохранить все товары в файле списка"
    view-as alert-box question buttons OK-Cancel update v-log.
    if not v-log then do:
      list-option = "":U.
      return.
    end.
    assign
    f-name = "default.tmg"
    v-log = yes
    .
    system-dialog get-file f-name
    filters "Списки товаров  *.tmg" "*.tmg"
    ask-overwrite
    save-as
    use-filename
    update v-log
    default-extension "tmg".
    if not v-log then do:
      list-option = "":U.
      return.
    end.
    v-log =  session:SET-WAIT-STATE("GENERAL") .

    output stream sout to value (f-name).
      for each loc-tmp-sale-gds No-LOCK WHERE
                 loc-tmp-sale-gds.tmp-code = v-tmp-code :
      find first ub.goods where
                        ub.goods.artic =   loc-tmp-sale-gds.artic and
                        ub.goods.prod-type =   loc-tmp-sale-gds.prod-type and
                        ub.goods.prod-code =   loc-tmp-sale-gds.prod-code no-lock .
      export stream sout
      ub.goods.gds-code
      loc-tmp-sale-gds.tmp-value
      loc-tmp-sale-gds.tmp-code
      .
      END.
      output stream sout close.
      v-log =  session:SET-WAIT-STATE("") .
    end.


    when "load":U then do:

      system-dialog get-file f-name
      filters "Списки клиентов *.tmg" "*.tmg"
      title "Выберите файл списка"
      INITIAL-DIR "."
      return-to-start-dir
      must-exist
      /* use-filename */
      update v-log
      default-extension "tmg".
      if not v-log then do:
       list-option = "":U.
       return.
      end.
      v-log =  session:SET-WAIT-STATE("GENERAL") .
      input stream sout from value (f-name).
      _repeat:
      repeat:
        import stream sout
                      loc-gds-code
                      loc-min-stock
                      loc-tmp-code    no-error.
      find first ub.goods where   ub.goods.gds-code =   loc-gds-code no-lock no-error .
      if error-status :error then do:
         message "Не существует товара с кодом " loc-gds-code view-as alert-box error .
         undo, return error.
         end.
       find first loc-tmp-sale-gds exclusive-LOCK WHERE
            loc-tmp-sale-gds.artic        = ub.goods.artic     and
            loc-tmp-sale-gds.prod-type    = ub.goods.prod-type and
            loc-tmp-sale-gds.prod-code    = ub.goods.prod-code and
            loc-tmp-sale-gds.tmp-code     = v-tmp-code      no-error.
        if not available loc-tmp-sale-gds then create loc-tmp-sale-gds.

        assign
          loc-tmp-sale-gds.artic        = ub.goods.artic
          loc-tmp-sale-gds.prod-type    = ub.goods.prod-type
          loc-tmp-sale-gds.prod-code    = ub.goods.prod-code
          loc-tmp-sale-gds.tmp-value    = loc-min-stock
          loc-tmp-sale-gds.tmp-code     = v-tmp-code
        .

    end.
    input stream sout close.
    v-log =  session:SET-WAIT-STATE("") .
    {&OPEN-QUERY-BROWSE-2}
   end.
END CASE.
loc-list-option = "":U.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME