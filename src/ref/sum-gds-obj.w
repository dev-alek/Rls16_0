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

Привязка товаров к группам товаров на кассе объектные

Автор: Шкляр Елена Львовна
Дата создания: 15/12/16
Author: Shklyar Elena
Creation date: 15/12/16

*/
define input parameter parParentProc  as widget-handle no-undo.
define input parameter p-attr-code  like ub.gds-obj-attr.attr-code    no-undo.
define input parameter p-attr-value like ub.gds-obj-attr.attr-value   no-undo.
define input parameter p-host-code  like ub.dis-grp-rule.host-code  no-undo .
define input parameter p-obj-type   like ub.dis-grp-rule.obj-type   no-undo.
define input parameter p-obj-code   like ub.dis-grp-rule.obj-code   no-undo.  
define input parameter p-name       like ub.sum-group.name          no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Привязка товаров к группам товаров на кассе объектные".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ cmp/gds-list.i gds-list def "new shared" }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ ref/gdsoattr.i }

define variable rid-list    as  character no-undo . /* список recid'ов выбранных записей */
define variable log-res     as log no-undo.
define variable rr          as recid no-undo.
define variable v-log       as logical   no-undo .
define variable line-mode   as character no-undo .
define variable doc-rec     as recid no-undo .
define variable gds-rec     as recid no-undo .
define variable lns-cnt     as integer   no-undo .
define variable g#log       as logical   no-undo .
define variable varschartic like ub.price-list.artic initial " " no-undo.
define variable ref-list    as character                     no-undo.
define variable sch-field   as character no-undo.
define variable sort-column-name as character no-undo .
define variable list-option as character no-undo.
define variable v-del       as logical no-undo .
define variable v-rid-list  as character no-undo COLUMN-LABEL "*" .

define stream sout.

define temp-table tt-gds-list no-undo like ub.goods
field nn as integer
index by-nn nn
index by_gds-code gds-code
.
define temp-table temp-goods no-undo
  field gds-code as integer

  index xpk is primary unique gds-code
  .


define buffer buf_gds-obj-attr          for ub.gds-obj-attr.  /* для поиска по номеру, дате, факт */
define buffer buf_goods               for ub.goods.  /* для поиска по номеру, дате, факт */
define buffer buf_sum-group-attr      for ub.sum-group-attr.

&Scoped-define OPEN-QUERY-BROWSE-2-goods OPEN QUERY BROWSE-2 FOR EACH gds-obj-attr ~
      WHERE gds-obj-attr.attr-code = p-attr-code and ~
            gds-obj-attr.attr-value = p-attr-value and ~
            gds-obj-attr.obj-code = p-obj-code and ~
            gds-obj-attr.obj-type = p-obj-type ~
            NO-LOCK, ~
      first goods where goods.gds-code = gds-obj-attr.gds-code ~
      NO-LOCK ~{&SORTBY-PHRASE}.

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
&Scoped-define INTERNAL-TABLES gds-obj-attr goods

/* Definitions for BROWSE BROWSE-2                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 mark-string(goods.gds-code) @ v-rid-list goods.artic goods.gds-name goods.gds-code 
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2 
&Scoped-define QUERY-STRING-BROWSE-2 FOR EACH gds-obj-attr ~
      WHERE gds-obj-attr.attr-code = p-attr-code and gds-obj-attr.attr-value = p-attr-value and gds-obj-attr.obj-code = p-obj-code and gds-obj-attr.obj-type = p-obj-type NO-LOCK, ~
      EACH goods WHERE goods.gds-code = gds-obj-attr.gds-code NO-LOCK ~
    ~ {&SORTBY-PHRASE}
&Scoped-define OPEN-QUERY-BROWSE-2 OPEN QUERY BROWSE-2 FOR EACH gds-obj-attr ~
      WHERE gds-obj-attr.attr-code = p-attr-code and gds-obj-attr.attr-value = p-attr-value and gds-obj-attr.obj-code = p-obj-code and gds-obj-attr.obj-type = p-obj-type NO-LOCK, ~
      EACH goods WHERE goods.gds-code = gds-obj-attr.gds-code NO-LOCK ~
    ~{&SORTBY-PHRASE}.
&Scoped-define TABLES-IN-QUERY-BROWSE-2 gds-obj-attr goods
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2 gds-obj-attr
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-2 goods


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-2}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-mark b-add b-del b-help r-sort ~
s-artic s-code BROWSE-2 FILL-IN-2 
&Scoped-Define DISPLAYED-OBJECTS mark-num r-sort s-artic s-name s-name-cnt s-code ~
FILL-IN-2 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD mark-str Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER
  ( p-gds-code as integer)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add 
     LABEL "&Добавить":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-del 
     LABEL "&Удалить":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Выход ":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-help 
     LABEL "Помо&щь":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-mark 
     LABEL "&*":L 
     SIZE 3 BY 1.

DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.

DEFINE BUTTON b-print 
     LABEL "Пе&чать":L 
     SIZE 10 BY 1.

DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Поиск по" 
      VIEW-AS TEXT 
     SIZE 8.88 BY .67 NO-UNDO.

DEFINE VARIABLE s-artic AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 29.88 BY 1 NO-UNDO.

DEFINE VARIABLE s-code AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 29.88 BY 1 NO-UNDO.

DEFINE VARIABLE s-name AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 29.88 BY 1 NO-UNDO.

DEFINE VARIABLE s-name-cnt AS CHARACTER FORMAT "X(256)":U 
     LABEL "" 
     VIEW-AS FILL-IN 
     SIZE 29.88 BY 1 NO-UNDO.

DEFINE VARIABLE r-sort AS INTEGER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Код", 1,
"Артикул", 2,
"Нач.назв", 3
     SIZE 38.75 BY .96 TOOLTIP "Поиск по" NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-2 FOR 
      gds-obj-attr, 
      goods SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2 Dialog-Frame _STRUCTURED
  QUERY BROWSE-2 NO-LOCK DISPLAY
      mark-string(goods.gds-code) @ v-rid-list FORMAT "X(3)":U
      goods.artic FORMAT "X(16)":U
      goods.gds-name FORMAT "X(46)":U
      goods.gds-code FORMAT "999999999":U 
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 79.5 BY 18.92
         BGCOLOR 15 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 11 WIDGET-ID 16
     b-add AT ROW 1 COL 14.13
     b-del AT ROW 1 COL 24.13
     b-print AT ROW 1 COL 60.75
     b-help AT ROW 1 COL 70.75
     r-sort AT ROW 2.04 COL 10.75 NO-LABEL WIDGET-ID 4
     s-artic AT ROW 2.04 COL 49 COLON-ALIGNED NO-LABEL WIDGET-ID 10
     s-name AT ROW 2.04 COL 49 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     s-name-cnt AT ROW 2.04 COL 49 COLON-ALIGNED WIDGET-ID 12
     s-code AT ROW 2.04 COL 49 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     BROWSE-2 AT ROW 3.21 COL 1.5
     FILL-IN-2 AT ROW 2.21 COL 1 NO-LABEL WIDGET-ID 2
     SPACE(72.11) SKIP(20.61)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Товары ".


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
/* BROWSE-TAB BROWSE-2 s-code Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON b-print IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-2 IN FRAME Dialog-Frame
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
     _TblList          = "ub.gds-obj-attr,ub.goods WHERE ub.gds-obj-attr ..."
     _Options          = "NO-LOCK SORTBY-PHRASE"
     _TblOptList       = ","
     _Where[1]         = "goods-attr.attr-code = p-attr-code and goods-attr.attr-value = p-attr-value"
     _JoinCode[2]      = "goods.gds-code = attr-code.gds-code"
     _FldNameList[1]   > "_<CALC>"
"mark-str(buffer buf_goods, v-mark-list)" "*" ? ? ? ? ? ? ? ? no ? no no "1" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   = ub.goods.artic
     _FldNameList[3]   = ub.goods.gds-name
     _FldNameList[4]   > ub.goods.gds-code
"goods.gds-code" ? ? "integer" ? ? ? ? ? ? no ? no no "11.5" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE BROWSE-2 */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Товары  */
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
(   input parParentProc ,
    input "p-attr-code" ,
    input "Группа товаров на кассе: " + p-name  ,
    input ? ,
    input ? ,
    input v-cntxt-host-code-obj,
    input-output varschartic,
    output ref-list,
    output table tt-gds-list,
    false )
    .

    if ref-list <> "" then do:
       run cycle-add in this-procedure no-error.
      if error-status:error then do:
         message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры создания товара" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
         return no-apply.
      end.
       {&OPEN-QUERY-{&BROWSE-NAME}}
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
define variable g-log as logical   no-undo .
define buffer buf_temp-goods for temp-goods .
define variable v-del as logical   no-undo .

if not available gds-obj-attr then  return no-apply.

      message "Удалить запись ? "
      view-as alert-box question
      buttons yes-no
      update g-log.
      if g-log = false then return no-apply.

  define variable v-recid as integer no-undo .
  define variable ii as integer no-undo .
  define variable cur-number as integer no-undo.
 
     for each temp-goods:
        run gdsoattr-delete ( input temp-goods.gds-code
                            ,input p-obj-type
                            ,input p-obj-code
                            ,input p-attr-code
                            ,output v-del
                            ) no-error .

     end.  

      if not v-del then do:
        find current gds-obj-attr exclusive-lock no-error .
        run gdsoattr-delete ( input gds-obj-attr.gds-code
                            ,input p-obj-type
                            ,input p-obj-code
                            ,input p-attr-code
                            ,output v-del
                            ) no-error .
          
      end.
  
  apply "HOME" to {&browse-name} in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
  run choose-mark in this-procedure
    no-error .
  if error-status :error
  then do:
    return no-apply .
  end.
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-sort
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-sort Dialog-Frame
ON VALUE-CHANGED OF r-sort IN FRAME Dialog-Frame
DO:
  Assign frame {&frame-name} r-sort.
  case r-sort :
  when 1 then do:
        if sch-field = "s-name-cnt" then do:
                       assign frame {&frame-name}:title = "Товары >> Группа товаров на кассе - " + p-name.
                      {&OPEN-QUERY-BROWSE-2}
                      end.
        enable s-code with frame {&frame-name}.
            Hide s-name  s-name-cnt s-artic in frame {&frame-name}.
        display s-code with frame {&frame-name}.
        apply "entry" to s-code in frame {&frame-name}.
   end.
  when 2 then do:
        if sch-field = "s-name-cnt" then do:
                       assign frame {&frame-name}:title = "Товары >> Группа товаров на кассе - " + p-name.
                      {&OPEN-QUERY-BROWSE-2}
                      end.
        enable s-artic with frame {&frame-name}.
            Hide s-name  s-name-cnt s-code in frame {&frame-name}.
        display s-artic with frame {&frame-name}.
        apply "entry" to s-artic in frame {&frame-name}.
   end.
  when 3 then do:
    if sch-field = "s-name-cnt" then do:
                 assign frame {&frame-name}:title = "Товары >> Группа товаров на кассе - " + p-name.
                {&OPEN-QUERY-BROWSE-2}
                end.
        enable s-name with frame {&frame-name}.
        hide s-artic  s-name-cnt s-code in frame {&frame-name}.
        display s-name with frame {&frame-name}.
        apply "entry" to s-name in frame {&frame-name}.
   end.
  when 4 then do:
        enable s-name-cnt with frame {&frame-name}.
        hide s-artic  s-name s-code in frame {&frame-name}.
        display s-name-cnt with frame {&frame-name}.
        apply "entry" to s-name-cnt in frame {&frame-name}.
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
 for each buf_gds-obj-attr where buf_gds-obj-attr.attr-code = p-attr-code and buf_gds-obj-attr.obj-code = p-obj-code and buf_gds-obj-attr.obj-type = p-obj-type,
            first buf_goods where buf_gds-obj-attr.gds-code = buf_goods.gds-code and
                                  buf_goods.artic begins s-artic :
         doc-rec = recid(buf_gds-obj-attr) .
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


&Scoped-define SELF-NAME s-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL s-code Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF s-code IN FRAME Dialog-Frame
OR  RETURN OF s-code IN FRAME {&frame-name}
DO:
  if s-code <> input frame {&frame-name} s-code or sch-field <> "s-code" then do:

 sch-field = "s-code".
 assign s-code = input frame {&frame-name} s-code.

 doc-rec = ?.
 for each buf_gds-obj-attr where buf_gds-obj-attr.attr-code = p-attr-code and buf_gds-obj-attr.obj-code = p-obj-code and buf_gds-obj-attr.obj-type = p-obj-type,
            first buf_goods where buf_gds-obj-attr.gds-code = buf_goods.gds-code and
                                  buf_goods.gds-code = integer(s-code) :
         doc-rec = recid(buf_gds-obj-attr) .
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
 for each buf_gds-obj-attr where buf_gds-obj-attr.attr-code = p-attr-code and buf_gds-obj-attr.obj-code = p-obj-code and buf_gds-obj-attr.obj-type = p-obj-type,
            first buf_goods where buf_gds-obj-attr.gds-code = buf_goods.gds-code and
                                  buf_goods.gds-name begins s-name :
         doc-rec = recid(buf_gds-obj-attr) .
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
 for each buf_gds-obj-attr where buf_gds-obj-attr.attr-code = p-attr-code and buf_gds-obj-attr.obj-code = p-obj-code and buf_gds-obj-attr.obj-type = p-obj-type,
            first buf_goods where
               buf_gds-obj-attr.gds-code = buf_goods.gds-code and
             INDEX(buf_goods.gds-name,s-name-cnt) > 0 :
         doc-rec = recid(buf_gds-obj-attr) .
         leave.
 end.
  if doc-rec = ? then message "Товар не найден !"  .
  else do:
     assign frame {&frame-name}:title = "Товары >> Группы товаров на кассе - " + p-name + " , содержащие в названии " + s-name-cnt .
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
{ gbl/hot-key.i b-mark }

assign
   frame {&frame-name}:title = "Товары >> " + p-name
.

{ gbl/srt-clmn.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_2    = "goods.artic"
  &sort-clmn_3    = "goods.gds-name"
  &open-query     = "run OpenBr."
  &open-query-otherwise = "run OpenBr."
  &sort-column-name     = "sort-column-name"
  &re-move-clmn         = "no"
  &mv-brw-default       = "no"
}

{ gbl/f2.i {&browse-name} " " " " parParentProc }
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

   run enable_UI in this-procedure .
   run post_enable_UI in this-procedure .

/*/*   find first  buf_sum-group-attr no-lock                  */*/
/*/*        where  buf_sum-group-attr.attr-code = p-attr-code  */*/
/*/*          and  buf_sum-group-attr.attr-value = p-attr-value*/*/
/*/*          and  buf_sum-group-attr.sgr-db-num   = p-db-num  */*/
/*/*        no-error                                           */*/
/*/*        .                                                  */*/
/*                                                               */
/*   if not available buf_sum-group-attr  then return error .    */
/*поиск*/
   enable  s-code with frame {&frame-name}.
   Hide    s-name  s-name-cnt s-artic in frame {&frame-name}.
   display s-code with frame {&frame-name}.

   WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cycle-add Dialog-Frame 
PROCEDURE cycle-add :
define variable v-num   as integer no-undo .
define variable v-flag as logical   no-undo init false .
define variable v-count as integer no-undo .

   define buffer bb_gds-obj-attr   for ub.gds-obj-attr .
   define buffer buf_goods       for ub.goods .

   run gbl/d-askw.w
      (input "Вопрос" /* Заголовок окна */
      ,input "Если товар уже прикреплен к Группе товаров на кассе, пропускаем его?"
      ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
      ,input "Не добавлять|Добавлять|Остановка" /* список названий кнопок  */
      ,input "Не добавляем товар к новой группе товаров на кассе, товар остается в старой группе товаров|" /* список описаний кнопок */
         + "Добавляем товар к новой группе товаров на кассе и открепляем от старой|"
         + "Остановить добавление товаров, если встречаются товары прикрепленные к другим группам товар на кассе."
      ,input 1 /* значение возвращаемое при нажатии enter */
      ,input 2 /* значение возвращаемое при нажатии escape */
      ,output v-num /* выбор пользователя */
      ).
    case v-num :
      /*Не добавляем товар к новой группе товаров на кассе, товар остается в старой группе товаров*/
      when 1 then do :
          for each tt-gds-list no-lock  by tt-gds-list.nn :
            lns-cnt  =  lns-cnt + 1 .
            if lns-cnt > 1 then assign line-mode = "ЦИКЛ":U.
              v-flag = false .
              for each bb_gds-obj-attr no-lock where
                       bb_gds-obj-attr.gds-code = tt-gds-list.gds-code
              :
                v-flag = true.
                leave.
              end.
              if v-flag = false then do :
                find first bb_gds-obj-attr no-lock
                    where bb_gds-obj-attr.gds-code = tt-gds-list.gds-code
                      and bb_gds-obj-attr.attr-code = p-attr-code
                      and bb_gds-obj-attr.obj-code = p-obj-code
                      and bb_gds-obj-attr.obj-type = p-obj-type
                      no-error.
                if not available bb_gds-obj-attr then do :
                    run gdsoattr-write (input tt-gds-list.gds-code
                                       ,input p-obj-type
                                       ,input p-obj-code 
                                       ,input p-attr-code
                                       ,input p-attr-value
                                        ) no-error.     

                end.
              end.
          end.
      end.
      /*Добавляем товар к новой группе товаров на кассе и открепляем от старой*/
      when 2 then do :
          for each tt-gds-list no-lock  by tt-gds-list.nn :
            lns-cnt  =  lns-cnt + 1 .
            if lns-cnt > 1 then assign line-mode = "ЦИКЛ":U.
              v-flag = false .
              for each bb_gds-obj-attr exclusive-lock 
                    where bb_gds-obj-attr.gds-code = tt-gds-list.gds-code
                      and bb_gds-obj-attr.attr-code = p-attr-code
                      and bb_gds-obj-attr.obj-code = p-obj-code
                      and bb_gds-obj-attr.obj-type = p-obj-type
              :
                run gdsoattr-delete ( input tt-gds-list.gds-code
                                    ,input p-obj-type
                                    ,input p-obj-code
                                    ,input p-attr-code
                                    ,output v-del
                                    ) no-error .
                
              end.
            find first bb_gds-obj-attr no-lock
                 where bb_gds-obj-attr.gds-code = tt-gds-list.gds-code
                   and bb_gds-obj-attr.attr-code = p-attr-code 
                   and bb_gds-obj-attr.obj-code = p-obj-code
                   and bb_gds-obj-attr.obj-type = p-obj-type
                   no-error.
            if not available bb_gds-obj-attr then do :

                    run gdsoattr-write (input tt-gds-list.gds-code
                                       ,input p-obj-type
                                       ,input p-obj-code 
                                       ,input p-attr-code
                                       ,input p-attr-value
                                        ) no-error.   
            end.
          end.
      end.
      /*Остановить добавление товаров, если встречаются товары прикрепленные к другим группам товар на кассе.*/
      when 3 then do :
          for each tt-gds-list no-lock  by tt-gds-list.nn :
            lns-cnt  =  lns-cnt + 1 .
            if lns-cnt > 1 then assign line-mode = "ЦИКЛ":U.
              v-flag = false .
              for each bb_gds-obj-attr no-lock 
                    where bb_gds-obj-attr.gds-code = tt-gds-list.gds-code
                      and bb_gds-obj-attr.attr-code = p-attr-code
                      and bb_gds-obj-attr.obj-code = p-obj-code
                      and bb_gds-obj-attr.obj-type = p-obj-type
              :
                v-flag = true .
                leave.
              end.
            if v-flag = true then do :
              leave.
            end.
          end.
          if v-flag <> true then do :
          for each tt-gds-list no-lock  by tt-gds-list.nn :
            find first bb_gds-obj-attr no-lock
                    where bb_gds-obj-attr.gds-code = tt-gds-list.gds-code
                      and bb_gds-obj-attr.attr-code = p-attr-code
                      and bb_gds-obj-attr.obj-code = p-obj-code
                      and bb_gds-obj-attr.obj-type = p-obj-type
                   no-error.
            if not available bb_gds-obj-attr then do :
                    run gdsoattr-write (input tt-gds-list.gds-code
                                       ,input p-obj-type
                                       ,input p-obj-code 
                                       ,input p-attr-code
                                       ,input p-attr-value
                                        ) no-error.     
            end.
          end.
          end.
      end.
    end case.
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
  DISPLAY r-sort s-artic s-name s-name-cnt s-code FILL-IN-2 
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-mark b-add b-del b-help r-sort s-artic s-code BROWSE-2 
         FILL-IN-2 
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

&scop my-open-query     assign frame ~{&frame-name}:title = "Товары >> " + p-name. ~
   ~{&OPEN-QUERY-BROWSE-2} ~
   .
case sort-column-name :
  when "goods.artic" then do:
    &scop SORTBY-PHRASE by goods.artic
    {&my-open-query}
  end.

  when "goods.gds-name" then do:
    &scop SORTBY-PHRASE by goods.gds-name
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE post_enable_UI Dialog-Frame 
PROCEDURE post_enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
/*   if v-cntxt-db-num <> 0 then do:*/
/*      disable                     */
/*            b-add b-del           */
/*      WITH FRAME Dialog-Frame.    */
/*   end.                           */
END PROCEDURE. /* post_enable_UI */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-mark-string DIALOG-1
PROCEDURE get-mark-string :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-gds-code    as integer   no-undo .
  define output parameter p-mark-string as character no-undo .


  do
  on error undo, return error return-value
  :
    find first temp-goods
      where temp-goods.gds-code = p-gds-code
      no-error .
    if available temp-goods
    then do:
      assign
        p-mark-string = '*':U
      .
    end.
    else do:
      assign
        p-mark-string = '':U
      .
    end.

  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE choose-mark DIALOG-1
PROCEDURE choose-mark :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable v-log as logical no-undo .

  do
  on error undo, return error return-value
  :
    if available goods
    then do:
      find first temp-goods
        where temp-goods.gds-code = goods.gds-code
        no-error .
      if available temp-goods
      then do:
        run goods_delete in this-procedure
          (input  goods.gds-code
          ) .
      end.
      else do:
        run goods_append in this-procedure
          (input  goods.gds-code
          ) .
      end.

      v-log = Browse-2:refresh() in frame {&frame-name}.
      if last-event :function <> "MOUSE-SELECT-DBLCLICK"
      then do:
        v-log = browse-2:select-next-row ().
        apply "iteration-changed" to browse-2 in frame {&frame-name}.
      end.
/*                                                */
/*      run display-select-num in this-procedure .*/

      apply "entry" to browse-2 in frame {&frame-name}.
    end.
  end.

END PROCEDURE.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE goods_append DIALOG-1
PROCEDURE goods_append :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-gds-code as integer no-undo .

  do
  on error undo, return error return-value
  :
    find first temp-goods
      where temp-goods.gds-code = p-gds-code
      no-error .
    if not available temp-goods
    then do:
      create temp-goods .
      assign
        temp-goods.gds-code = p-gds-code
      .
/*      assign                                       */
/*        v-total-select-num = v-total-select-num + 1*/
/*      .                                            */
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE goods_delete DIALOG-1
PROCEDURE goods_delete :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-gds-code as integer   no-undo .

  do
  on error undo, return error return-value
  :
    find first temp-goods
      where temp-goods.gds-code = p-gds-code
        no-error .
    if available temp-goods
    then do:
      delete temp-goods .
/*      assign                                       */
/*        v-total-select-num = v-total-select-num - 1*/
/*      .                                            */
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION mark-string DIALOG-1
FUNCTION mark-string RETURNS CHARACTER
  ( p-gds-code as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
  define variable v-mark-string as character no-undo .

  run get-mark-string in this-procedure
    (input  p-gds-code
    ,output v-mark-string
    ) .
  return v-mark-string .

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME