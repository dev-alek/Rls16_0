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

Привязка товаров к типам алкоголя_

Автор: Белоусов Илья Александрович
Дата создания:
Author: Ilia Belousov
Creation date:

*/
define input parameter parParentProc  as widget-handle no-undo.
define input parameter p-alc-type-inner-code   like ub.alc-type.alc-type-inner-code no-undo.
define input parameter p-db-num like ub.alc-type.create-user-db-num no-undo.
define input parameter p-name   like ub.alc-type.alc-type-name no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Привязка товаров к типам алкоголя".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ cmp/gds-list.i gds-list def "new shared" }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

define variable rid-list    as  character no-undo . /* список recid'ов выбранных аписей */
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
define variable v-brws-mark as character no-undo COLUMN-LABEL "*"        FORMAT "X(1)":U  .
define stream sout.

define temp-table tt-gds-list no-undo like ub.goods
field nn as integer
index by-nn nn
index by_gds-code gds-code
.

define buffer buf_alc-type-gds for ub.alc-type-gds.  /* для поиска по номеру, дате, факт */
define buffer buf_goods        for ub.goods.  /* для поиска по номеру, дате, факт */
define buffer buf_alc-type     for ub.alc-type.

&Scoped-define OPEN-QUERY-BROWSE-2-alt OPEN QUERY BROWSE-2 FOR EACH ub.alc-type-gds ~
      WHERE ub.alc-type-gds.alc-type-inner-code = p-alc-type-inner-code and ~
            ub.alc-type-gds.create-user-db-num   = p-db-num NO-LOCK, ~
      first ub.goods where ~
      ub.goods.gds-code = ub.alc-type-gds.gds-code ~
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
&Scoped-define INTERNAL-TABLES alc-type-gds goods

/* Definitions for BROWSE BROWSE-2                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 (IF ( INDEX (rid-list, string( recid(alc-type-gds) ) ) > 0 ) THEN ("*") ELSE (" ")) @ v-brws-mark goods.artic goods.gds-name ~
goods.gds-code 
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2 
&Scoped-define QUERY-STRING-BROWSE-2 FOR EACH alc-type-gds ~
      WHERE alc-type-gds.alc-type-inner-code = p-alc-type-inner-code  NO-LOCK, ~
      EACH goods WHERE goods.gds-code = alc-type-gds.gds-code NO-LOCK ~
    ~{&SORTBY-PHRASE}
&Scoped-define OPEN-QUERY-BROWSE-2 OPEN QUERY BROWSE-2 FOR EACH alc-type-gds ~
      WHERE alc-type-gds.alc-type-inner-code = p-alc-type-inner-code  NO-LOCK, ~
      EACH goods WHERE goods.gds-code = alc-type-gds.gds-code NO-LOCK ~
    ~{&SORTBY-PHRASE}.
&Scoped-define TABLES-IN-QUERY-BROWSE-2 alc-type-gds goods
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2 alc-type-gds
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-2 goods


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-2}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-add b-del b-help r-sort s-artic ~
s-code BROWSE-2 FILL-IN-2 b-mark
&Scoped-Define DISPLAYED-OBJECTS r-sort s-artic s-name s-name-cnt s-code ~
FILL-IN-2 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */
/* Menu Definitions                                                     */
DEFINE MENU POPUP-MENU-b-mark
       MENU-ITEM m_mark_all     LABEL "Выбрать все"
       MENU-ITEM m_mark_no_one  LABEL "Снять выбор у всех"
       MENU-ITEM m_mark_invert  LABEL "Инвертировать выбор".

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.
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

DEFINE BUTTON b-print 
     LABEL "Пе&чать":L 
     SIZE 10 BY 1.

DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Поиск по" 
      VIEW-AS TEXT 
     SIZE 8.88 BY .67 NO-UNDO.

DEFINE VARIABLE s-artic AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 25 BY 1 NO-UNDO.

DEFINE VARIABLE s-code AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 25 BY 1 NO-UNDO.

DEFINE VARIABLE s-name AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 25 BY 1 NO-UNDO.

DEFINE VARIABLE s-name-cnt AS CHARACTER FORMAT "X(256)":U 
     LABEL "" 
     VIEW-AS FILL-IN 
     SIZE 25 BY 1 NO-UNDO.

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
      alc-type-gds, 
      goods
      SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2 Dialog-Frame _STRUCTURED
  QUERY BROWSE-2 NO-LOCK DISPLAY

      (IF ( INDEX (rid-list, string( recid(alc-type-gds)) ) > 0 ) THEN ("*") ELSE (" ")) @ v-brws-mark                               
      goods.artic FORMAT "X(16)":U
      goods.gds-name FORMAT "X(48)":U
      goods.gds-code FORMAT "999999999":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 87 BY 18.92
         BGCOLOR 15 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-mark AT ROW 1.0 COL 33
     b-exit AT ROW 1 COL 1
     b-add AT ROW 1 COL 12
     b-del AT ROW 1 COL 22
     b-print AT ROW 1 COL 68
     b-help AT ROW 1 COL 78
     r-sort AT ROW 2.04 COL 10.75 NO-LABEL WIDGET-ID 4
     s-artic AT ROW 2.04 COL 49 COLON-ALIGNED NO-LABEL WIDGET-ID 10
     s-name AT ROW 2.04 COL 49 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     s-name-cnt AT ROW 2.04 COL 49 COLON-ALIGNED WIDGET-ID 12
     s-code AT ROW 2.04 COL 49 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     BROWSE-2 AT ROW 3.13 COL 1
     FILL-IN-2 AT ROW 2.21 COL 1 NO-LABEL WIDGET-ID 2
     SPACE(78.12) SKIP(19.17)
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
       ASSIGN
       b-mark:POPUP-MENU IN FRAME Dialog-Frame       = MENU POPUP-MENU-b-mark:HANDLE.

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
     _TblList          = "ub.alc-type-gds,ub.goods WHERE ub.alc-type-gds ..."
     _Options          = "NO-LOCK SORTBY-PHRASE"
     _TblOptList       = ","
     _Where[1]         = "ub.alc-type-gds.alc-type-inner-code = p-alc-type-inner-code "
     _JoinCode[2]      = "ub.goods.gds-code = ub.alc-type-gds.gds-code"
     _FldNameList[1]   = ub.goods.artic
     _FldNameList[2]   = ub.goods.gds-name
     _FldNameList[3]   = ub.goods.gds-code
     _Query            is OPENED
*/  /* BROWSE BROWSE-2 */
&ANALYZE-RESUME

 

/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
or insert-mode of browse-2 IN FRAME Dialog-Frame
  /*or mouse-select-click of browse-2 IN FRAME Dialog-Frame*/
or MOUSE-SELECT-DBLCLICK OF BROWSE-2 IN FRAME Dialog-Frame
DO:
   define variable v-ok as logical no-undo .
          
   { gbl/markstrn.i alc-type-gds rid-list }
                                                         
   v-ok = {&browse-name}:select-next-row () no-error .
   v-ok = {&browse-name}:refresh( )  in frame {&frame-name} no-error .      

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&Scoped-define SELF-NAME m_mark_all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_mark_all Dialog-Frame
ON CHOOSE OF MENU-ITEM m_mark_all                            /* Выбрать все */
or + of browse-2 IN FRAME Dialog-Frame
DO:
   define variable v-ok as logical no-undo .
   assign rid-list = "" .
                                               
     for each alc-type-gds
      WHERE alc-type-gds.alc-type-inner-code = p-alc-type-inner-code  NO-LOCK, 
      EACH goods WHERE goods.gds-code = alc-type-gds.gds-code NO-LOCK 
      :
      rid-list = rid-list + string( recid(alc-type-gds) ) .
       
   
   end .
   v-ok = {&browse-name}:refresh( )  in frame {&frame-name} no-error.    

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
                                                                           
&Scoped-define SELF-NAME m_mark_no_one
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_mark_no_one Dialog-Frame
ON CHOOSE OF MENU-ITEM m_mark_no_one                     /* Снять выбор у всех */
or - of browse-2 IN FRAME Dialog-Frame
DO:

   define variable v-ok as logical no-undo .
                                               
   rid-list =  " " .
   v-ok = {&browse-name}:refresh( )  in frame {&frame-name} no-error.   

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME    

&Scoped-define SELF-NAME m_mark_invert
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_mark_invert Dialog-Frame
ON CHOOSE OF MENU-ITEM m_mark_invert                  /* Инвертировать выбор */
or * of browse-2 IN FRAME Dialog-Frame  
DO:                                                                       

   define variable v-ok as logical no-undo .
                                               
     for each alc-type-gds
      WHERE alc-type-gds.alc-type-inner-code = p-alc-type-inner-code  NO-LOCK, 
      EACH goods WHERE goods.gds-code = alc-type-gds.gds-code NO-LOCK 
      :
    
      { gbl/markstrn.i alc-type-gds rid-list } 
   
   end .
   v-ok = {&browse-name}:refresh( )  in frame {&frame-name} no-error.   

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME                                                                               
    



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
/* !!!
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_alc-type_add-def':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    v-log
  }
 if not v-log then return no-apply .
*/
assign
  line-mode = {&add-def}
.
run str/chsgdsls.w
(   input parParentProc ,
    input "alc-type" ,
    input "Вид акоголя: " + p-name  ,
    input ? ,
    input ? ,
    input v-cntxt-host-code-obj,
    input-output varschartic,
    output ref-list,
    output table tt-gds-list,
    false )
    .
/*run ref/gds-ref.p*/
/*    ( parParentProc*/
/*    ,"b-sel,b-mark"*/
/*    ,{&all}*/
/*    ,{&all}*/
/*    ,{&all}*/
/*    ,?*/
/*    ,?*/
/*    ,?*/
/*    ,?*/
/*    ,v-cntxt-obj-type*/
/*    ,v-cntxt-obj-code*/
/*    ,?*/
/*    ,output ref-list).*/
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
    end.
    {&OPEN-QUERY-{&BROWSE-NAME}} 
    
    for first goods WHERE recid (goods) = integer (entry (1, ref-list)), 
     first alc-type-gds where goods.gds-code = alc-type-gds.gds-code NO-LOCK    
     :
       def var p-rec as recid no-undo .
       p-rec = recid(alc-type-gds) .
          
       REPOSITION {&browse-name} TO RECID p-rec  NO-ERROR. 
    end .      
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
      define buffer del_alc-type-gds for ub.alc-type-gds.
      
      message "Удалить выбранные записи ?" 
      view-as alert-box question
      buttons ok-cancel
      update v-ok as logical
      .
      if v-ok then do:       
      
        if string(rid-list) eq "" then do:
          { gbl/markstrn.i alc-type-gds rid-list }   
           v-ok = {&browse-name}:select-next-row () no-error .    
           if v-ok eq no then v-ok = {&browse-name}:select-prev-row () no-error .
        end .    

       def var p-int as int no-undo . 
       do  p-int = 1 to NUM-ENTRIES(rid-list) :
           
           find first del_alc-type-gds 
            WHERE   ENTRY( p-int , rid-list )  eq string( recid(del_alc-type-gds)) no-error.   
                                            
           delete del_alc-type-gds. 
       end .
 
        assign rid-list = "" .
      end .  

      v-ok = {&browse-name}:select-prev-row () no-error .
      
      if v-ok eq YES then 
       v-ok = {&browse-name}:select-next-row () no-error .
      
      v-ok = {&browse-name}:refresh( )  in frame {&frame-name} no-error. 

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
                       assign frame {&frame-name}:title = "Товары >> Вид алкогольной продукции - " + p-name.
                      {&OPEN-QUERY-BROWSE-2}
                      end.
        enable s-code with frame {&frame-name}.
            Hide s-name  s-name-cnt s-artic in frame {&frame-name}.
        display s-code with frame {&frame-name}.
        apply "entry" to s-code in frame {&frame-name}.
   end.
  when 2 then do:
        if sch-field = "s-name-cnt" then do:
                       assign frame {&frame-name}:title = "Товары >> Вид алкогольной продукции - " + p-name.
                      {&OPEN-QUERY-BROWSE-2}
                      end.
        enable s-artic with frame {&frame-name}.
            Hide s-name  s-name-cnt s-code in frame {&frame-name}.
        display s-artic with frame {&frame-name}.
        apply "entry" to s-artic in frame {&frame-name}.
   end.
  when 3 then do:
    if sch-field = "s-name-cnt" then do:
                 assign frame {&frame-name}:title = "Товары >> Вид алкогольной продукции - " + p-name.
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
 for each buf_alc-type-gds where buf_alc-type-gds.alc-type-inner-code = p-alc-type-inner-code,
            first buf_goods where buf_alc-type-gds.gds-code = buf_goods.gds-code and
                                  buf_goods.artic begins s-artic :
         doc-rec = recid(buf_alc-type-gds) .
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
 for each buf_alc-type-gds where buf_alc-type-gds.alc-type-inner-code = p-alc-type-inner-code,
            first buf_goods where buf_alc-type-gds.gds-code = buf_goods.gds-code and
                                  buf_goods.gds-code = integer(s-code) :
         doc-rec = recid(buf_alc-type-gds) .
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
 for each buf_alc-type-gds where buf_alc-type-gds.alc-type-inner-code = p-alc-type-inner-code,
            first buf_goods where buf_alc-type-gds.gds-code = buf_goods.gds-code and
                                  buf_goods.gds-name begins s-name :
         doc-rec = recid(buf_alc-type-gds) .
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
 for each buf_alc-type-gds where buf_alc-type-gds.alc-type-inner-code = p-alc-type-inner-code,
            first buf_goods where
               buf_alc-type-gds.gds-code = buf_goods.gds-code and
             INDEX(buf_goods.gds-name,s-name-cnt) > 0 :
         doc-rec = recid(buf_alc-type-gds) .
         leave.
 end.
  if doc-rec = ? then message "Товар не найден !"  .
  else do:
     assign frame {&frame-name}:title = "Товары >> виды алкогольной продукции - " + p-name + " , содержащие в названии " + s-name-cnt .
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

assign
   frame {&frame-name}:title = "Товары >> " + p-name
.

{ gbl/srt-clmn.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "ub.goods.artic"
  &sort-clmn_2    = "ub.goods.gds-name"
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

   find first  buf_alc-type no-lock
        where  buf_alc-type.alc-type-inner-code = p-alc-type-inner-code
          and  buf_alc-type.create-user-db-num   = p-db-num
        no-error
        .

   if not available buf_alc-type  then return error .
/*поиск*/
   enable  s-code with frame {&frame-name}.
   Hide      s-name  s-name-cnt s-artic in frame {&frame-name}.
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
   define variable v-count as integer no-undo .
   define variable v-ok    as logical      no-undo.
   define variable v-first as logical      no-undo.
   define variable v-not-list    as character    no-undo.
   define variable v-flag as logical   no-undo init false .

   define buffer bb_alc-type-gds for ub.alc-type-gds .
   define buffer buf_goods       for ub.goods .

   run gbl/d-askw.w
      (input "Вопрос" /* Заголовок окна */
      ,input "Если товар уже прикреплен к виду алкоголя, пропускаем его?"
      ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
      ,input "Не добавлять|Добавлять|Остановка" /* список названий кнопок  */
      ,input "Не добавляем товар к новому виду алкоголя, товар остается со старым видом|" /* список описаний кнопок */
         + "Добавляем товар к новому виду и открепляем от старого|"
         + "Остановить добавление товаров, если встречаются товары прикрепленные к другим видам алкоголя."
      ,input 1 /* значение возвращаемое при нажатии enter */
      ,input 2 /* значение возвращаемое при нажатии escape */
      ,output v-num /* выбор пользователя */
      ).
   assign
      v-first = TRUE
   .
/*   { adm/actgdsrc.i*/
/*     v-cntxt-db-num*/
/*     v-cntxt-userid*/
/*     {&action-head-code-main}*/
/*     'actn_gds-in-doc-update':U*/
/*     v-cntxt-obj-type*/
/*     v-cntxt-obj-code*/
/*     ref-list*/
/*     v-not-list*/
/*     v-ok*/
/*   }*/
/*   define variable v-out    as character FORMAT "x(50)"   no-undo.*/
/*   if not v-ok*/
/*   then do:*/
/*      assign*/
/*         v-out = v-not-list*/
/*      .*/
/*      message*/
/*         v-not-list*/
/*         skip*/
/*      view-as alert-box information.*/
/*   end.*/

    case v-num :
      when 1 then do :
          for each tt-gds-list no-lock  by tt-gds-list.nn :
            lns-cnt  =  lns-cnt + 1 .
            if lns-cnt > 1 then assign line-mode = "ЦИКЛ":U.
              v-flag = false .
              for each bb_alc-type-gds no-lock where
                       bb_alc-type-gds.gds-code = tt-gds-list.gds-code
              :
                v-flag = true.
                leave.
              end.
              if v-flag = false then do :
                find first bb_alc-type-gds no-lock
                     where bb_alc-type-gds.gds-code            = tt-gds-list.gds-code
                       and bb_alc-type-gds.alc-type-inner-code = p-alc-type-inner-code
                       and bb_alc-type-gds.create-user-db-num  = p-db-num no-error.
                if not available bb_alc-type-gds then do :
                  create bb_alc-type-gds.
                  assign
                      bb_alc-type-gds.gds-code            = tt-gds-list.gds-code
                      bb_alc-type-gds.alc-type-inner-code = p-alc-type-inner-code
                      bb_alc-type-gds.create-user-db-num  = p-db-num
                  .
                end.
              end.
          end.
      end.
      when 2 then do :
          for each tt-gds-list no-lock  by tt-gds-list.nn :
            lns-cnt  =  lns-cnt + 1 .
            if lns-cnt > 1 then assign line-mode = "ЦИКЛ":U.
              v-flag = false .
              for each bb_alc-type-gds exclusive-lock where
                       bb_alc-type-gds.gds-code = tt-gds-list.gds-code and
                       bb_alc-type-gds.alc-type-inner-code <> p-alc-type-inner-code
              :
                delete bb_alc-type-gds.
              end.
              find first bb_alc-type-gds no-lock
                    where bb_alc-type-gds.gds-code            = tt-gds-list.gds-code
                      and bb_alc-type-gds.alc-type-inner-code = p-alc-type-inner-code
                      and bb_alc-type-gds.create-user-db-num  = p-db-num no-error.
              if not available bb_alc-type-gds then do :
                create bb_alc-type-gds.
                assign
                    bb_alc-type-gds.gds-code            = tt-gds-list.gds-code
                    bb_alc-type-gds.alc-type-inner-code = p-alc-type-inner-code
                    bb_alc-type-gds.create-user-db-num  = p-db-num
                .
              end.
          end.
      end.
      when 3 then do :
          for each tt-gds-list no-lock  by tt-gds-list.nn :
            lns-cnt  =  lns-cnt + 1 .
            if lns-cnt > 1 then assign line-mode = "ЦИКЛ":U.
              v-flag = false .
              for each bb_alc-type-gds no-lock where
                        bb_alc-type-gds.gds-code = tt-gds-list.gds-code and
                        bb_alc-type-gds.alc-type-inner-code <> p-alc-type-inner-code
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
              find first bb_alc-type-gds no-lock
                    where bb_alc-type-gds.gds-code            = tt-gds-list.gds-code
                      and bb_alc-type-gds.alc-type-inner-code = p-alc-type-inner-code
                      and bb_alc-type-gds.create-user-db-num  = p-db-num no-error.
              if not available bb_alc-type-gds then do :
                create bb_alc-type-gds.
                assign
                    bb_alc-type-gds.gds-code            = tt-gds-list.gds-code
                    bb_alc-type-gds.alc-type-inner-code = p-alc-type-inner-code
                    bb_alc-type-gds.create-user-db-num  = p-db-num
                .
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
  ENABLE b-exit b-add b-del b-help r-sort s-artic s-code BROWSE-2 FILL-IN-2 b-mark
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
message
   "X"
   skip sort-column-name
view-as alert-box information.
case sort-column-name :
  when "ub.goods.artic" then do:
    &scop SORTBY-PHRASE by goods.artic
    {&my-open-query}
  end.

  when "ub.goods.gds-name" then do:
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
   if v-cntxt-db-num <> 0 then do:
      disable
            b-add b-del
      WITH FRAME Dialog-Frame.
   end.
END PROCEDURE. /* post_enable_UI */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-list Dialog-Frame 
PROCEDURE proc-b-list :
/*
define input parameter loc-list-option as character no-undo.

define buffer   loc-alc-type-gds for ub.alc-type-gds.

define variable v-alc-type-inner-code    like ub.alc-type-gds.alc-type-inner-code no-undo.
define variable jj as integer no-undo.
define variable varrid-alc-type-gds as recid no-undo.
define variable f-name as character init "default.cli" no-undo.
define variable imp-type         like ub.goods.prod-type no-undo.
define variable imp-code         like ub.goods.prod-code no-undo.
define variable loc-gds-code     like ub.alc-type-gds.gds-code no-undo.
define variable loc-alc-type-inner-code     like ub.alc-type-gds.alc-type-inner-code no-undo.
define variable loc-db-num       like ub.alc-type-gds.create-user-db-num no-undo.

v-alc-type-inner-code =  p-alc-type-inner-code .
case loc-list-option:
  when "save":U then do:
    g#log = yes.
    message "Сохранить все товары в файле списка"
    view-as alert-box question buttons OK-Cancel update g#log.
    if not g#log then do:
      list-option = "":U.
      return.
    end.
    assign
    f-name = "default.sea"
    g#log = yes
    .
    system-dialog get-file f-name
    filters "Списки товаров  *.sea" "*.sea"
    ask-overwrite
    save-as
    use-filename
    update g#log
    default-extension "sea".
    if not g#log then do:
      list-option = "":U.
      return.
    end.
    g#log =  session:SET-WAIT-STATE("GENERAL") .

    output stream sout to value (f-name).
      for each loc-alc-type-gds No-LOCK WHERE
                 loc-alc-type-gds.alc-type-inner-code = v-alc-type-inner-code and
                 loc-alc-type-gds.create-user-db-num   = p-db-num
                 :
      export stream sout
      loc-alc-type-gds.gds-code
      loc-alc-type-gds.alc-type-inner-code
      loc-alc-type-gds.create-user-db-num
      .
      END.
      output stream sout close.
      g#log =  session:SET-WAIT-STATE("") .
    end.


    when "load":U then do:

      system-dialog get-file f-name
      filters "Списки клиентов *.sea" "*.sea"
      title "Выберите файл списка"
      INITIAL-DIR "."
      return-to-start-dir
      must-exist
      update g#log
      default-extension "sea".
      if not g#log then do:
       list-option = "":U.
       return.
      end.
      g#log =  session:SET-WAIT-STATE("GENERAL") .
      input stream sout from value (f-name).
      _repeat:
      repeat:
        import stream sout
                      loc-gds-code
                      loc-alc-type-inner-code
                      loc-db-num
                      no-error.

       find first loc-alc-type-gds exclusive-LOCK WHERE
            loc-alc-type-gds.gds-code = loc-gds-code  and
            loc-alc-type-gds.alc-type-inner-code = v-alc-type-inner-code and
            loc-alc-type-gds.create-user-db-num   = p-db-num
            no-error.
        if not available loc-alc-type-gds then create loc-alc-type-gds.

        assign
          loc-alc-type-gds.gds-code   = loc-gds-code
          loc-alc-type-gds.alc-type-inner-code   = v-alc-type-inner-code
          loc-alc-type-gds.create-user-db-num     = p-db-num

        .

    end.
    input stream sout close.
    g#log =  session:SET-WAIT-STATE("") .
    {&OPEN-QUERY-BROWSE-2}
   end.
END CASE.
loc-list-option = "":U.
*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

