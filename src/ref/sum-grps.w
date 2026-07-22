&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-sum-grp


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_sum-grp FOR ub.sum-grp.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-sum-grp
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник групп товаров на кассах

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns  as char   no-undo .
define input-output parameter p-rid-list    as  char no-undo . /* список recid'ов выбранных записей */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Справочник групп товаров на кассах" .
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/obj-list.i new }
{ cmp/r-pril.i new}
{ gbl/prn-lib.i }
{ gbl/cur-time.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ ref/gds-attr.i }

define variable log-res as log no-undo.
define variable rr as recid no-undo.
define variable dops as character no-undo.
define variable dopst as character no-undo.
define variable glog as logical no-undo .
DEFINE VARIABLE dgrpr-option AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define buffer b_sum-grp for ub.sum-grp.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-sum-grp
&Scoped-define BROWSE-NAME br-sumgrps

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_sum-grp

/* Definitions for BROWSE br-sumgrps                                    */
&Scoped-define FIELDS-IN-QUERY-br-sumgrps if lookup(string(recid(X_sum-grp)), v-rid-list) > 0 then "*" else "":U X_sum-grp.grp-code X_sum-grp.grp-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-sumgrps
&Scoped-define SELF-NAME br-sumgrps
&Scoped-define QUERY-STRING-br-sumgrps FOR EACH X_sum-grp NO-LOCK     BY X_sum-grp.grp-code INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-sumgrps OPEN QUERY {&SELF-NAME} FOR EACH X_sum-grp NO-LOCK     BY X_sum-grp.grp-code INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-sumgrps X_sum-grp
&Scoped-define FIRST-TABLE-IN-QUERY-br-sumgrps X_sum-grp


/* Definitions for DIALOG-BOX d-sum-grp                                 */
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-sum-grp ~
    ~{&OPEN-QUERY-br-sumgrps}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-mark b-sel b-add b-chg b-del b-disc ~
b-goods b-hist b-print b-help mark-num br-sumgrps 
&Scoped-Define DISPLAYED-OBJECTS mark-num 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-disc
       MENU-ITEM m_lookup-disc  LABEL "Просмотр"
       MENU-ITEM m_update-disc  LABEL "Изменение"     .

DEFINE MENU MENU-b-goods 
       MENU-ITEM m_lookup-goods  LABEL "Глобальные"      
       MENU-ITEM m_update-goods  LABEL "По объекту"     .
/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add 
     LABEL "&Добавить":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-chg 
     LABEL "&Изменить":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-del 
     LABEL "&Удалить":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-disc 
     LABEL "&Скидки" 
     SIZE 10 BY 1.

DEFINE BUTTON b-goods 
     LABEL "&Товары" 
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "&Помощь":L
     SIZE 3 BY 1.

DEFINE BUTTON b-hist
     LABEL "Истори&я"
     SIZE 3 BY 1.

DEFINE BUTTON b-mark
     LABEL "&*":L
     SIZE 3 BY 1.

DEFINE BUTTON b-print
     LABEL "П&ечать":L
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход ":L
     SIZE 10 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор ":L
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 6.25 BY 1
     FGCOLOR 10  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-sumgrps FOR
      X_sum-grp SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-sumgrps
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-sumgrps d-sum-grp _FREEFORM
  QUERY br-sumgrps NO-LOCK DISPLAY
      if lookup(string(recid(X_sum-grp)), v-rid-list) > 0 then "*" else "":U FORMAT "X(1)":U
  X_sum-grp.grp-code FORMAT "999":U width 10
  X_sum-grp.grp-name COLUMN-LABEL "Наименование группы" FORMAT "X(65)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 87 BY 18.83
         BGCOLOR 15 FGCOLOR 0 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-sum-grp
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 15
     b-sel AT ROW 1 COL 18
     b-add AT ROW 1 COL 28
     b-chg AT ROW 1 COL 38
     b-del AT ROW 1 COL 48
     b-disc AT ROW 1 COL 58 WIDGET-ID 2
     b-goods AT ROW 1 COL 68 
     b-hist AT ROW 1 COL 80.13
     b-print AT ROW 1 COL 83.13
     b-help AT ROW 1 COL 86.13
     mark-num AT ROW 1.04 COL 9.13 COLON-ALIGNED NO-LABEL
     br-sumgrps AT ROW 2.92 COL 2.5
     SPACE(1.37) SKIP(0.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "ГРУППЫ ТОВАРОВ НА КАССАХ":L.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Temp-Tables and Buffers:
      TABLE: X_sum-grp B "?" ? ub sum-grp
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-sum-grp
   FRAME-NAME                                                           */
/* BROWSE-TAB br-sumgrps mark-num d-sum-grp */
ASSIGN
       FRAME d-sum-grp:SCROLLABLE       = FALSE.

ASSIGN
       b-disc:POPUP-MENU IN FRAME d-sum-grp       = MENU MENU-b-disc:HANDLE.

ASSIGN 
       b-goods:POPUP-MENU IN FRAME d-sum-grp       = MENU MENU-b-goods:HANDLE.
       
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-sumgrps
/* Query rebuild information for BROWSE br-sumgrps
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_sum-grp NO-LOCK
    BY X_sum-grp.grp-code INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _OrdList          = "ub.sum-grp.grp-code|yes"
     _Query            is OPENED
*/  /* BROWSE br-sumgrps */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-sum-grp
/* Query rebuild information for DIALOG-BOX d-sum-grp
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-sum-grp */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-sum-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-sum-grp d-sum-grp
ON END-ERROR OF FRAME d-sum-grp /* ГРУППЫ ТОВАРОВ НА КАССАХ */
OR ENDKEY OF FRAME {&frame-name} DO:
   run gbl/markqwa.p (
                           input b-mark:sensitive
                          , input v-rid-list) no-error.
    if error-status:error then return no-apply.
  run proc-send in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-sum-grp d-sum-grp
ON GO OF FRAME d-sum-grp /* ГРУППЫ ТОВАРОВ НА КАССАХ */
DO:
  p-rid-list = v-rid-list.
  run proc-send in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add d-sum-grp
ON CHOOSE OF b-add IN FRAME d-sum-grp /* Добавить */
DO:
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_group-goods-cash-desk_add-def':U
{&cntxt-global}
0
'':U
0
0
0
0
true
glog
}
if NOT glog then return no-apply .
run ref/sum-grpi.w (  input parparentproc
                    , input {&add-def}
                    , input-output rr ).
if rr <> ? then  do:
  FIND b_sum-grp WHERE recid( b_sum-grp ) = rr NO-LOCK .
  rr = recid( b_sum-grp ) .
  run grp-sending in this-procedure ("U":U) no-error .
  if error-status:error then return no-apply.
  {&open-query-br-sumgrps}
  reposition br-sumgrps to recid rr.
  log-res  = br-sumgrps:select-focused-row( ).
  apply "ENTRY":U to br-sumgrps.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg d-sum-grp
ON CHOOSE OF b-chg IN FRAME d-sum-grp /* Изменить */
DO:
DEFINE VARIABLE V-OLD-NAME LIKE UB.SUM-GRP.GRP-NAME NO-UNDO.
if not available X_sum-grp THEN    return no-apply.
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_group-goods-cash-desk_update':U
{&cntxt-global}
0
'':U
0
0
0
0
true
glog
}
if NOT glog then  return no-apply .
rr = recid( X_sum-grp ).
find first b_sum-grp where
            recid(b_sum-grp) = RR NO-ERROR.
IF NOT AVAIL B_SUM-GRP THEN RETURN NO-APPLY.
ASSIGN
V-OLD-NAME = B_SUM-GRP.GRP-NAME
.
run ref/sum-grpi.w ( input parparentproc
                     ,input {&update}
                     ,input-output rr ).
find first b_sum-grp where
            recid(b_sum-grp) = RR NO-ERROR.

if B_SUM-GRP.GRP-NAME <> V-OLD-NAME then do:
    run GRP-sending IN THIS-PROCEDURE ("U":U) no-error .
    if error-status:error then return no-apply.
  end.
{&open-query-br-sumgrps}
reposition br-sumgrps to recid rr .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del d-sum-grp
ON CHOOSE OF b-del IN FRAME d-sum-grp /* Удалить */
DO:
DEFINE VARIABLE V-OLD-NAME LIKE UB.SUM-GRP.GRP-NAME NO-UNDO.
if not available X_sum-grp THEN  return no-apply.
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_group-goods-cash-desk_update':U
{&cntxt-global}
0
'':U
0
0
0
0
true
glog
}
if NOT glog then  return no-apply .
rr = recid( X_sum-grp ).
find first b_sum-grp where
            recid(b_sum-grp) = RR NO-ERROR.
IF NOT AVAIL B_SUM-GRP THEN RETURN NO-APPLY.
run grp-sending in this-procedure ("D":U) no-error .
if error-status:error then return no-apply.
delete b_sum-grp.
{&open-query-br-sumgrps}
reposition br-sumgrps to row 1 no-error  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-disc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-disc d-sum-grp
ON CHOOSE OF b-disc IN FRAME d-sum-grp /* Скидки */
DO:
 if not available X_sum-grp THEN return no-apply.
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  if dgrpr-option = "":U then do:
    run gbl/pop-up.p ( input self :handle
                     , input no ) no-error.
    if error-status :error then do:
        return no-apply.
    end.
  end.
  if dgrpr-option = "":U then do:
      return no-apply.
  end.
  run ref/disgrpui.w ( input parparentproc
                ,input dgrpr-option
                ,input {&TABLE_sum-grp}
                ,input v-cntxt-host-code-obj
                ,input v-cntxt-obj-type
                ,input v-cntxt-obj-code
                ,input X_sum-grp.grp-code
               ) NO-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-goods d-sum-grp
ON CHOOSE OF b-goods IN FRAME d-sum-grp /* Товары */
DO:
 if not available X_sum-grp THEN return no-apply.
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  if dgrpr-option = "":U then do:
    run gbl/pop-up.p ( input self :handle
                     , input no ) no-error.
    if error-status :error then do:
        return no-apply.
    end.
  end.
  if dgrpr-option = "":U then do:
      return no-apply.
  end.
  if dgrpr-option = {&attr-sum-grp-gl} then do:
  run ref/sum-gds.w (input parparentproc 
                     ,input dgrpr-option
                     ,input X_sum-grp.grp-code
                     ,input v-cntxt-host-code-obj
                     ,input v-cntxt-obj-type
                     ,input v-cntxt-obj-code
                     ,input X_sum-grp.grp-name
               ) NO-ERROR.
  end.
  if dgrpr-option = {&attr-sum-grp-o} then do:
  run ref/sum-gds-obj.w (input parparentproc 
                        ,input dgrpr-option
                        ,input string (X_sum-grp.grp-code, "999")
                        ,input v-cntxt-host-code-obj
                        ,input v-cntxt-obj-type
                        ,input v-cntxt-obj-code
                        ,input X_sum-grp.grp-name
               ) NO-ERROR.
  end.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist d-sum-grp
ON CHOOSE OF b-hist IN FRAME d-sum-grp /* История */
DO:
    DEFINE VARIABLE v-loc-rid-list AS CHARACTER NO-UNDO.
    IF AVAILABLE X_sum-grp THEN DO:
      run ref/csumgrps.w (
                     INPUT parparentproc
                    ,INPUT '':U /*bttns*/
                    ,INPUT 'one':U
                    ,INPUT X_sum-grp.grp-code
                    ,input '':U
                    ,INPUT-OUTPUT v-loc-rid-list) NO-ERROR.

    END.
    apply "entry" to br-sumgrps.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark d-sum-grp
ON CHOOSE OF b-mark IN FRAME d-sum-grp /* * */
DO:
  if available X_sum-grp then do:
    { gbl/markstrn.i X_sum-grp v-rid-list }
    glog = br-sumgrps:refresh() .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
            glog = br-sumgrps:select-next-row ().
            apply "iteration-changed" to br-sumgrps in frame {&frame-name}.
      end.
    if num-entries( v-rid-list ) = 0 then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-sumgrps in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print d-sum-grp
ON CHOOSE OF b-print IN FRAME d-sum-grp /* Печать */
DO:
  define variable sym1 as char init ":"   no-undo.
  define variable sym2 as char init ":"   no-undo.
  define variable sym3 as char init ":"   no-undo.

  define variable Line                    as char         no-undo.

  define variable ii      as integer   no-undo.
  define variable StartRecid      as integer   no-undo.

  DEFINE FRAME List
      sym1 column-label ":" format "x(1)"
      X_sum-grp.grp-code column-label {&g___code} format ">>9"
      sym2 column-label ":" format "x(1)"
      X_sum-grp.grp-name column-label {&name} format "x(50)"
      sym3 column-label ":" format "x(1)"
      HEADER
      cur-time-print() AT 5 format "X(35)"
      string( "Страница " + string( PAGE-NUMBER( PrnLibStream ) , ">>9") )
      AT 43 format "X(15)" SKIP
      line format "x(60)" AT 1
      with width {&A4_CW} down use-text stream-io no-box .

  if num-results( "br-sumgrps" ) = 0 then  do:
    message
    "Список  П У С Т !"
    skip
    view-as alert-box information .
    return no-apply .
  end.

  if session:set-wait-state( "compiler" ) then .
  Line = fill( "-" , 100 ) .
/*
  Это из-за того, что в QUERY br-sumgrps используется index reposition и,
  как следствие, не работает GET first br-sumgrps  ( ошибка 3157 )
*/
  StartRecid = recid( X_sum-grp ) .
  DO WHILE available X_sum-grp :
      GET prev br-sumgrps NO-LOCK .
  END.
  GET next br-sumgrps NO-LOCK .
  ii = 1 .

  run prn-lib-open-stream  in this-procedure (
                                              input parParentProc
                                              ,input {&CS_PS}
                                              ,input yes /*p-is-stream*/
                                              ,input no /*p-append*/
                                              ).

  FORM HEADER
  Line format "X(130)" SKIP
  "Продолжение - на следующей странице" AT 30 SKIP
  with FRAME CliBottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS no-box.
  VIEW stream PrnLibStream FRAME CliBottomFrame .
  PUT stream PrnLibStream space(10)
  "СПИСОК  ГРУПП  ТОВАРОВ  НА  КАССАХ" format "X(50)" SKIP(2) .
  FORM with frame List .
  DO WHILE available X_sum-grp :
      DISPLAY stream PrnLibStream
      sym1 X_sum-grp.grp-code
      sym2 X_sum-grp.grp-name
      sym3
      with frame List .
      DOWN stream PrnLibStream 1 with frame List .
      ii =  ii + 1 .
      if ( ( ii modulo 10 ) = 0 ) AND ( ii >= 10 ) then
      run waitfram-show in this-procedure ( "Просмотрено строк : " + string( ii ) ) .
      GET next br-sumgrps .
  END.
  PUT stream PrnLibStream Line format "X(60)" SKIP.
  HIDE stream PrnLibStream FRAME CliBottomFrame .
  output stream PrnLibStream close .
  run waitfram-hide in this-procedure .

  run prn-lib-prn-file in this-procedure (
                                        input parParentProc
                                        ,input 0
                                        ).

  reposition br-sumgrps to recid StartRecid NO-ERROR .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel d-sum-grp
ON CHOOSE OF b-sel IN FRAME d-sum-grp /* Выбор  */
DO:
    if ( available X_sum-grp ) AND (( v-rid-list = "" ) or b-mark:sensitive = no) then
        v-rid-list = string( recid( X_sum-grp ) ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-sumgrps
&Scoped-define SELF-NAME br-sumgrps
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-sumgrps d-sum-grp
ON DEFAULT-ACTION OF br-sumgrps IN FRAME d-sum-grp
DO:
  case yes:
      when  b-chg:sensitive THEN apply "CHOOSE":U to b-chg.
  end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-sumgrps d-sum-grp
ON INSERT-MODE OF br-sumgrps IN FRAME d-sum-grp
OR MOUSE-SELECT-DBLCLICK OF br-sumgrps
DO:
    if can-do(bttns, "b-mark") then
    apply "choose" to b-mark in frame {&frame-name} .
    else if can-do( bttns, "b-sel" ) then
        apply "choose" to b-sel in frame {&frame-name} .
    else dO:
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-sumgrps d-sum-grp
ON MOUSE-SELECT-DBLCLICK OF br-sumgrps IN FRAME d-sum-grp
DO:
  if can-do( bttns, "b-sel" ) then do:
    apply "choose" to b-sel in frame {&frame-name} .
    return no-apply .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-sumgrps d-sum-grp
ON RETURN OF br-sumgrps IN FRAME d-sum-grp
DO:
    if can-do( bttns, "b-sel" ) then
        apply "choose" to b-sel in frame {&frame-name} .
    else
         apply "DEFAULT-ACTION":U to self.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_lookup-disc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_lookup-disc d-sum-grp
ON CHOOSE OF MENU-ITEM m_lookup-disc /* Просмотр */
DO:
  assign
  dgrpr-option = {&lookup}
  .
  APPLY "CHOOSE" TO b-disc IN FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_update-disc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_update-disc d-sum-grp
ON CHOOSE OF MENU-ITEM m_update-disc /* Изменение */
DO:
    assign
   dgrpr-option = {&UPDATE}
   .
   APPLY "CHOOSE" TO b-disc IN FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_lookup-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_lookup-goods d-sum-grp
ON CHOOSE OF MENU-ITEM m_lookup-goods /* Глобальные */
DO:
  assign
  dgrpr-option = {&attr-sum-grp-gl}
  .
  APPLY "CHOOSE" TO b-goods IN FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m_update-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_update-goods d-sum-grp
ON CHOOSE OF MENU-ITEM m_update-goods /* По объекту */
DO:
    assign
   dgrpr-option = {&attr-sum-grp-o}
   .
   APPLY "CHOOSE" TO b-goods IN FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-sum-grp


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }
{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-del }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
{ gbl/hot-key.i b-print }


/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   { gbl/getcntxt.i get }
   if v-cntxt-db-num > 0 and lookup("b-add":U, bttns) > 0 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра bttns" bttns skip
    "Нельзя добавлять записи в удаленной БД"
    view-as alert-box  error.
    return error.
   end.
  { ref/send-ref.i dops dopst }
   v-rid-list = p-rid-list.
   RUN enable_UI.
   HIDE mark-num in frame {&frame-name}.
   if v-rid-list <> "":U then do:
    assign
    rr = integer(v-rid-list) no-error .
    .
    if not error-status:error then do:
      reposition br-sumgrps to recid rr no-error .
    end.
    APPLY "ENTRY" to br-sumgrps.
   end.
   WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-sum-grp  _DEFAULT-DISABLE
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
  HIDE FRAME d-sum-grp.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-sum-grp
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
assign
b-disc:menu-mouse in frame {&frame-name} = 1
menu-item m_update-disc:sensitive in menu menu-b-disc = lookup("b-add", bttns) > 0 AND v-cntxt-db-num = 0
b-goods:menu-mouse in frame {&frame-name} = 1
.
ENABLE br-sumgrps b-quit
b-add WHEN lookup("b-add", bttns) > 0 AND v-cntxt-db-num = 0 and not transaction
b-del WHEN lookup("b-add", bttns) > 0 AND v-cntxt-db-num = 0 and not transaction
b-sel WHEN lookup("b-sel", bttns) > 0
b-chg WHEN lookup("b-add", bttns) > 0 AND v-cntxt-db-num = 0 and not transaction
b-disc
b-goods
b-mark when lookup("b-mark", bttns) > 0
b-hist
b-print
b-help
WITH FRAME {&FRAME-NAME}.
{&OPEN-BROWSERS-IN-QUERY-d-sum-grp}
APPLY "ENTRY" to br-sumgrps.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE grp-sending d-sum-grp
PROCEDURE grp-sending :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-action as character no-undo .
if NOT send-ref  then return.
define variable p-var as integer no-undo .
FIND FIRST obj-list WHERE
           obj-list.obj-code = b_sum-grp.grp-code No-ERROR.
IF NOT avail obj-list then do:
  find last obj-list  use-index pi no-error .
   if available obj-list then p-var = obj-list.obj-id + 1.
                         else p-var = 1.

  create obj-list.
  assign
   obj-list.obj-code = b_sum-grp.GRP-code
   obj-list.obj-name = (if p-action = "D":U then "D":U else obj-list.obj-name)
   obj-list.obj-id   = p-var
  .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-send d-sum-grp
PROCEDURE proc-send :
define variable glog as logical no-undo .
if can-find(first ub.cash-desk where ub.cash-desk.pos-type = {&cd-type-ibm}) AND
       can-find(first obj-list) then do:
  message
  "Переслать изменения справочника на кассы?"
  view-as alert-box question buttons YES-NO update glog.
  if  glog then do:
    run str/diallog.w (
            input parparentproc
          , input this-procedure
          , input "str/snd-grup.p":U
          , input string(v-cntxt-db-num) /*(string(cli-shops.obj-code) + {&delim-par} + "R":U)*/
          , input no /*p-auto-go*/
          , input "":U
          , input substitute("Отсылка групп товаров на кассы БД &1", v-cntxt-db-num )
      ) no-error.
  end.
end.
for each obj-list:
  delete obj-list.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME