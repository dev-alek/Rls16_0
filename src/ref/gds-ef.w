&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE NEW SHARED BUFFER Buf_ext-classif FOR ub.ext-classif.
DEFINE NEW SHARED BUFFER Buf_goods FOR ub.goods.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Типы топлива для внешней системы EASYFUEL

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/27/08
Author: Bakhtadze Natalya
Creation date: 05/27/08

*/


/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
define input  parameter parParentProc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER bttns AS character NO-UNDO.
define input  parameter p-list-mode  as character no-undo .
define output parameter p-rid-list as character no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Типы топлива для внешней системы EASYFUEL".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ cmp/r-pril.i new }
{ gbl/waitfram.i }
{ gbl/prn-lib.i  }
{ gbl/cur-time.i }
{ str/lib-trn.i  }
{ gbl/getcntxt.i def    }
{ gbl/getcntxt.i get    }
{ ref/extclass.i }
{ gbl/key-rec.i  }
{ gbl/fltopend.i defproc }

define variable p-sts   as integer   no-undo .
define variable v-log as logical   no-undo .
define variable v-key-rec as character no-undo .
define variable mark-str  as character no-undo.
define variable v-doc-rec as recid no-undo.
define variable filter-point as character no-undo init "Типы топлива для внешней системы EASYFUEL" .
define variable filter-point0 as character no-undo init "Типы топлива для внешней системы EASYFUEL" .
define variable sort-column-name as character no-undo .
define variable v-db-num LIKE ub.db.db-num no-undo.
define variable v-type as character no-undo .
define variable p-mark as character no-undo .
define variable gds-rec as recid no-undo .

define variable varschartic like ub.price-list.artic initial " " no-undo.
define variable v-rid-list    as character no-undo.


&scop cop-l1       mark-string(recid( buf_ext-classif) , p-rid-list)
&scop dyn_cop-l1   substitute('dynamic-function(&1mark-string&1, recid(buf_ext-classif), &1&2&1)', ~{&double-quote~}, p-rid-list)
&scop cop-l2       Buf_goods.artic
&scop cop-l3       Buf_goods.gds-code
&scop cop-l4       Buf_goods.gds-name
&scop cop-l5       Buf_ext-classif.Key#_One

&scop col-l1       '*'
&scop col-l2       'Артикул'
&scop col-l3       'Код'
&scop col-l4       'Название'
&scop col-l5       'Код EASYFUEL'

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-ext-goods

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES Buf_ext-classif Buf_goods

/* Definitions for BROWSE BROWSE-ext-goods                              */
&Scoped-define FIELDS-IN-QUERY-BROWSE-ext-goods mark-string(buffer buf_ext-classif , p-rid-list) @ p-mark Buf_goods.artic Buf_goods.gds-code Buf_goods.gds-name Buf_ext-classif.Key#_One
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-ext-goods
&Scoped-define SELF-NAME BROWSE-ext-goods
&Scoped-define QUERY-STRING-BROWSE-ext-goods FOR EACH Buf_ext-classif       WHERE Buf_ext-classif.classif-subject = {&extclass_goods}         AND Buf_ext-classif.classif-name = {&extclass_goods_easyfuel} NO-LOCK, ~
              first Buf_goods where              Buf_goods.gds-code = int(entry(2, ~
      ub.Buf_ext-classif.uniq-key-rec, ~
       {&delim-key})) NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-ext-goods OPEN QUERY {&SELF-NAME} FOR EACH Buf_ext-classif       WHERE Buf_ext-classif.classif-subject = {&extclass_goods}         AND Buf_ext-classif.classif-name = {&extclass_goods_easyfuel} NO-LOCK, ~
              first Buf_goods where              Buf_goods.gds-code = int(entry(2, ~
      ub.Buf_ext-classif.uniq-key-rec, ~
       {&delim-key})) NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-ext-goods Buf_ext-classif Buf_goods
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-ext-goods Buf_ext-classif
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-ext-goods Buf_goods


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-ext-goods}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel B-add B-del B-print ~
B-Help a-n-c sch-artic BROWSE-ext-goods mark-num FILL-IN-7
&Scoped-Define DISPLAYED-OBJECTS a-n-c sch-artic mark-num FILL-IN-7

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER
( BUFFER loc-table FOR ub.ext-classif, input mark-list as CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-lookup  NO-CONVERT-3D-COLORS
     LABEL ""
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.

DEFINE VARIABLE FILL-IN-7 AS CHARACTER FORMAT "X(256)":U INITIAL "Поиск:"
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 2.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE sch-artic AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 14 BY 1 TOOLTIP "Поиск по артиклу" NO-UNDO.

DEFINE VARIABLE sch-code AS INTEGER FORMAT ">>>>>>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 10.5 BY 1 TOOLTIP "Поиск по коду" NO-UNDO.

DEFINE VARIABLE sch-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 37.5 BY 1 TOOLTIP "Поиск по началу Наименования" NO-UNDO.

DEFINE VARIABLE a-n-c AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "А", 1,
"Н", 2,
"К", 3
     SIZE 12 BY 1 TOOLTIP "Поиск товара по Артиклу, Названию , Коду" NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-ext-goods FOR
      Buf_ext-classif,
      Buf_goods SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-ext-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-ext-goods Dialog-Frame _FREEFORM
  QUERY BROWSE-ext-goods NO-LOCK DISPLAY
      mark-string(buffer buf_ext-classif , p-rid-list) @ p-mark COLUMN-LABEL "*" FORMAT "x(1)":U
      Buf_goods.artic FORMAT "X(16)":U
      Buf_goods.gds-code FORMAT ">>>>>>>>>9":U COLUMN-LABEL "Код"
      Buf_goods.gds-name FORMAT "X(40)":U
      Buf_ext-classif.Key#_One COLUMN-LABEL "Код EASYFUEL" FORMAT ">>>>>>>>9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 17.5 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 17.3
     B-add AT ROW 1 COL 27.3
     B-del AT ROW 1 COL 37.4
     B-lookup AT ROW 1 COL 47.5 WIDGET-ID 2
     B-print AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     a-n-c AT ROW 3 COL 9.5 NO-LABEL
     sch-artic AT ROW 3 COL 20.5 COLON-ALIGNED NO-LABEL
     sch-code AT ROW 3 COL 20.5 COLON-ALIGNED NO-LABEL
     sch-name AT ROW 3 COL 20.5 COLON-ALIGNED NO-LABEL
     BROWSE-ext-goods AT ROW 4 COL 1
     mark-num AT ROW 1 COL 12 COLON-ALIGNED NO-LABEL
     FILL-IN-7 AT ROW 2.97 COL 2.5 NO-LABEL
     SPACE(90.59) SKIP(17.82)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Типы топлива для EasyFuel".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: Buf_ext-classif B "NEW SHARED" ? ub.ext-classif
      TABLE: Buf_goods B "NEW SHARED" ? ub goods
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-ext-goods sch-name Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-lookup IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       B-lookup:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       BROWSE-ext-goods:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 1.

/* SETTINGS FOR FILL-IN FILL-IN-7 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN sch-code IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       sch-code:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN sch-name IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       sch-name:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-ext-goods
/* Query rebuild information for BROWSE BROWSE-ext-goods
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH Buf_ext-classif
      WHERE Buf_ext-classif.classif-subject = {&extclass_goods}
        AND Buf_ext-classif.classif-name = {&extclass_goods_easyfuel} NO-LOCK,
       first Buf_goods where
             Buf_goods.gds-code = int(entry(2,ub.Buf_ext-classif.uniq-key-rec, {&delim-key})) NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "Buf_ext-classif.classif-subject = {&extclass_goods}
 AND Buf_ext-classif.classif-name = {&extclass_goods_easyfuel}"
     _Query            is OPENED
*/  /* BROWSE BROWSE-ext-goods */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Типы топлива для EasyFuel */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Типы топлива для EasyFuel */
OR ENDKEY OF FRAME Dialog-Frame DO:
    run gbl/markqwa.p
       ( input b-mark:sensitive
       , input p-rid-list ) no-error.
    if error-status:error then return no-apply.

    APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME a-n-c
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL a-n-c Dialog-Frame
ON VALUE-CHANGED OF a-n-c IN FRAME Dialog-Frame
DO:
  ASSIGN a-n-c .
  case a-n-c  :
  when 1 then do:
    enable sch-artic with frame {&frame-name} .
    hide sch-name sch-code in frame {&frame-name} .
  end.
  when 2 then do:
    enable sch-name with frame {&frame-name} .
    hide sch-artic sch-code in frame {&frame-name} .

  end.
  when 3  then do:
    enable sch-code with frame {&frame-name} .
    hide sch-name sch-artic in frame {&frame-name} .
  end.

  end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  define variable loc#log as logical no-undo.
  define variable loc-doc-rec as recid no-undo .
  run proc-add (output loc-doc-rec) .
  if loc-doc-rec <> ? THEN DO:
      run openbr in this-procedure .
  END.

  apply "value-changed" to {&BROWSE-NAME} in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
define variable is-many as logical   no-undo .
is-many = false .

if num-entries(p-rid-list) > 0 then do:
   message "Удалять выделенные записи ?"
   view-as alert-box question
   Buttons yes-no update v-logq as log.
   if v-logq = false then return .
   is-many = true .
end.
  run proc-b-del in this-procedure ( p-rid-list , is-many ) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup Dialog-Frame
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame
DO:
if not available buf_goods then return no-apply.
run str/showgds.p ( input parparentproc
                   ,input ? /*p-call-handle*/
                   ,input buf_goods.gds-code
                   ,input {&lookup}) no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable loc#log as logical no-undo .
  if AVAILABLE {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}  then do:
    { gbl/markstrn.i {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}} p-rid-list }
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
  apply "display" to {&BROWSE-NAME} in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  run proc-b-print in this-procedure no-error.
  if error-status:error then do:
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
   IF  v-rid-list = ""
   or b-mark:sensitive in frame {&frame-name} = no
   THEN DO:
      IF AVAILABLE buf_ext-classif THEN v-rid-list = string(RECID(buf_ext-classif)).
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-artic
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-artic Dialog-Frame
ON CTRL-J OF sch-artic IN FRAME Dialog-Frame
DO:
  run proc-find-artic in this-procedure ( yes, input frame {&frame-name} sch-artic) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-artic Dialog-Frame
ON RETURN OF sch-artic IN FRAME Dialog-Frame
DO:
  run proc-find-artic in this-procedure ( no , input frame {&frame-name} sch-artic ) no-error.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON CTRL-J OF sch-code IN FRAME Dialog-Frame
DO:
  run proc-find-code in this-procedure ( yes, input frame {&frame-name} sch-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON RETURN OF sch-code IN FRAME Dialog-Frame
DO:
  run proc-find-code in this-procedure ( no, input frame {&frame-name} sch-code) no-error.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-name Dialog-Frame
ON CTRL-J OF sch-name IN FRAME Dialog-Frame
DO:
  run proc-find-name in this-procedure ( yes, input frame {&frame-name} sch-name) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-name Dialog-Frame
ON RETURN OF sch-name IN FRAME Dialog-Frame
DO:
  run proc-find-name in this-procedure ( no, input frame {&frame-name} sch-name ) no-error.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-ext-goods
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/srt-clmd.i
  &browse-name    = {&browse-name}
  &frame-name     = {&frame-name}
  &table-name     = "buf_ext-classif"
  &ext-col        = 5
  &start-column   = 2
  &label-clmn_1     =   "{&col-l1}"
  &label-clmn_2     =   "{&col-l2}"
  &label-clmn_3     =   "{&col-l3}"
  &label-clmn_4     =   "{&col-l4}"
  &label-clmn_5     =   "{&col-l5}"
  &sort-clmn_1      =   "{&cop-l1}"
  &dyn_sort-clmn_1  =   "{&dyn_cop-l1}"
  &sort-clmn_2    =   "{&cop-l2}"
  &sort-clmn_3    =   "{&cop-l3}"
  &sort-clmn_4    =   "{&cop-l4}"
  &sort-clmn_5    =   "{&cop-l5}"
  &open-query     = "run OpenBr."
  &open-query-otherwise = "run OpenBr."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "no"
  &mv-brw-default = "no"
}

{ gbl/brwrepos.i
  &line-num=5
}

{ gbl/f2.i {&BROWSE-name} goods-recid init-gds-rec parParentProc }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/curdbnum.i v-db-num }
  run myenable in this-procedure .
  hide mark-num in frame {&frame-name} .
  if v-doc-rec <> ? then
  reposition {&browse-name} to recid v-doc-rec no-error.
  apply "row-display" to {&browse-name} in frame {&frame-name}.
  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus {&browse-name}.

END.
run disable_ui in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-str Dialog-Frame 
PROCEDURE add-str :
define input-output parameter p-doc-rec   as recid no-undo.
define input parameter p-mode             as character no-undo .
define parameter buffer buf_goods for ub.goods.
define input parameter p-accor-code         as integer   no-undo .

do
on error undo, return error return-value
:
  run gen-key-rec in this-procedure (
      input  {&extclass_goods}
      ,input  buffer buf_goods:handle
      ,output v-key-rec ).

  if p-mode = {&add-def} then do:
    run ref/extclas1.p ( INPUT {&add-def}
                        ,INPUT NO /*p-silent*/
                        ,INPUT-OUTPUT p-doc-rec
                        ,INPUT {&table_goods} /*p-classif-subject*/
                        ,INPUT {&extclass_goods_easyfuel} /*p-classif-name*/
                        ,input (-1) /*p-db-num*/
                        ,input p-accor-code /*p-key#_one*/
                        ,input 0 /*p-Key#_Two*/
                        ,input 0 /*p-key#_Three*/
                        ,input '':U /*p-CharKey_One */
                        ,input '':U /*p-CharKey_two */
                        ,input '':U /*p-CharKey_three */
                        ,input 0 /*p-nonunique */
                        ,input v-key-rec ) no-error.
    if error-status:error then do:
      undo, return error .
    end.
  end.
end.
END PROCEDURE.

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
  DISPLAY a-n-c sch-artic mark-num FILL-IN-7 
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel B-add B-del B-print B-Help a-n-c sch-artic 
         BROWSE-ext-goods mark-num FILL-IN-7 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-gds-rec Dialog-Frame 
PROCEDURE init-gds-rec :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
if available buf_goods then do:
   gds-rec = recid (buf_goods) .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE myenable Dialog-Frame 
PROCEDURE myenable :
define variable v-db-num like ub.db.db-num no-undo .
{ gbl/curdbnum.i v-db-num }

DISPLAY mark-num
WITH FRAME {&frame-name}.

ENABLE
b-quit
B-mark when transaction = false
B-sel when LOOKUP("b-sel":U, bttns) > 0
B-add when LOOKUP("b-add":U, bttns) > 0 and v-cntxt-db-num = 0 and transaction = false
B-del when LOOKUP("b-add":U, bttns) > 0 and v-cntxt-db-num = 0 and transaction = false
B-print
B-Help
{&browse-name}
mark-num
a-n-c
sch-artic
with FRAME {&frame-name}.
VIEW FRAME {&frame-name}.

run openbr in this-procedure no-error.
IF ERROR-STATUS:ERROR  THEN RETURN error.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE openBr Dialog-Frame 
PROCEDURE openBr :
define variable p-open-query     as logical   no-undo init true .
def var l-query-was-opened as logical no-undo .
define variable doc-rec  as recid     no-undo .
define variable  p-find-next      as logical   no-undo .
define variable  p-find-condition as character no-undo .


def var sort-column-phrase as character no-undo .

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.

define variable title0 as character no-undo init "Типы топлива для внешней системы EASYFUEL" .

&scop flt-open-open-query OPEN QUERY BROWSE-ext-goods FOR EACH Buf_ext-classif

&scop flt-open-dyn_open-query  FOR EACH Buf_ext-classif

&scop flt-open-query-handle query BROWSE-ext-goods:handle

&scop flt-open-find-buffer-name Buf_ext-classif

&scop flt-open-open-query-tail   , first buf_goods no-lock where ~
                                   buf_goods.gds-code = integer(entry(2,buf_ext-classif.uniq-key-rec, {&delim-key}))

&scop flt-open-dyn_open-query-tail   substitute( ', first buf_goods no-lock where ~
                                     buf_goods.gds-code = integer(entry(2,buf_ext-classif.uniq-key-rec,&1&2&1 )) ' ~
                                    , ~{&double-quote~}, ~{&delim-key~} )


&scop flt-open-query-was-opened     l-query-was-opened

&scop flt-open-sort-column-phrase   sort-column-phrase

&scop flt-open-call-point           filter-point

&scop flt-open-set-filter-name

&scop flt-open-indexed-reposition  indexed-reposition

&scop flt-open-query               p-open-query

&scop flt-open-table-name          buf_ext-classif

&scop flt-open-search-option       no-lock

&scop flt-open-find-next           p-find-next

&scop flt-open-find-recid          doc-rec

&scop flt-open-find-condition       p-find-condition

&scop flt-open-find-buffer-def      define buffer buf_ext-classif for ub.ext-classif.

&scop flt-open-debug-file

&scop flt-open-waitfram             true

    if p-open-query then do:
      frame {&frame-name}:TITLE = title0  .
    end.
    { gbl/fltopend.i
    &where-cond = "  Buf_ext-classif.classif-subject = {&extclass_goods}  AND ~
                     Buf_ext-classif.classif-name = {&extclass_goods_easyfuel}  "
    &dyn_where-cond = "substitute(' Buf_ext-classif.classif-subject = &1&2&1  AND ~
                 Buf_ext-classif.classif-name = &1&2&1 '  , ~{&double-quote~}, ~{&extclass_goods~} ,  ~{&extclass_goods_easyfuel~})"

    &where-cond = "  "
    &use-ind    = " "
    &by         = " "  }

APPLY "VALUE-CHANGED" TO {&BROWSE-NAME} in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-add Dialog-Frame 
PROCEDURE proc-add :
define output parameter p-doc-rec as recid no-undo .
define variable v-rid-list as character no-undo .
define variable v-value-integer as integer no-undo .
define variable v-ok as logical no-undo .
run ref/petrlref.p ( input parparentproc
                ,input "b-sel"
                ,output v-rid-list) no-error.
if error-status :error then do:
message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  view-as alert-box error
  .

end.
if v-rid-list = '':u then return.
run waitfram-show in this-procedure  ("Добавление товаров  ... " ) .
find first buf_goods no-lock where
        recid(buf_goods) = integer(v-rid-list) no-error.
if available buf_goods then do:
  run gbl/d-integer.w (
       input ?
      ,input (
      'title=':u + substitute("Добавление кода топлива для товара &1 &2&3"
                              ,buf_goods.artic
                              ,buf_goods.prod-type
                              ,buf_goods.prod-code
                              ) + '\':u
    + 'text1=':u + "Код топлива EasyFuel" + '\':u
    + 'format=' + ">>>>>>>>9" + '\':u
    + 'fillin_row=2\':u
    + 'fillin_col=30\':u
    + 'fillin_width=10\':u
    + 'fillin_height=1\':u
    + 'max-chars=60\':u     /*- максимальное количество символов для редактора*/
    + 'readonly=no' + '\':u)
    , input-output v-value-integer
    , output v-ok
        ).
  if not v-ok then return error.
  run add-str in this-procedure
  (   input-output p-doc-rec
    ,input {&add-def}
    ,buffer buf_goods
    ,input v-value-integer
  ).
end.

run waitfram-hide in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame 
PROCEDURE proc-b-del :
define input  parameter p-recid as character no-undo .
define input  parameter p-model as logical   no-undo .

define variable loc#log as logical no-undo.
define variable v-log as logical   no-undo .
define variable loc-doc-rec as recid no-undo.
define variable ii as integer   no-undo .

if not available buf_ext-classif then return error.

do
on error undo, return error
on stop undo, return error

:
  assign
    loc-doc-rec = RECID(buf_ext-classif)
  .
  if p-model = false then do:
    run ref/extclas3.p ( input no /*p-silent*/
                        ,input loc-doc-rec) .
  end.
  else do:
    _trans:
    do transaction:
      repeat ii = 1 to num-entries(p-recid) :
        run ref/extclas3.p ( input yes /*p-silent*/
                            ,input integer(entry(ii, p-recid))) no-error .

        if error-status:error then do:
          message
          error-status:get-message(1) skip
          return-value
          view-as alert-box error .
          undo _trans, return error .
        end.
      end.
    end.
    p-recid = "" .
    p-rid-list = "" .
  end.
  run openbr in this-procedure .
  REPOSITION {&browse-name} to recid loc-doc-rec No-error.
  if available buf_ext-classif then do:
    loc#log = {&browse-name}:select-focused-row( ) IN FRAME {&FRAME-NAME}.
    loc#log = {&BROWSE-NAME}:refresh() .
  end.
  APPLY "display" TO {&BROWSE-NAME}.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame 
PROCEDURE proc-b-print :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

define variable v-doc-rec as recid no-undo .
define variable accum-count as integer.
define variable date_string     as      character    no-undo.
define variable Line            as      character    no-undo.
define variable v-time-cr as character no-undo .
define variable v-time-up as character no-undo .
define variable v-st      as character no-undo .

DEFINE FRAME ext-list
      Buf_goods.artic FORMAT "X(16)":U
      Buf_goods.gds-code COLUMN-LABEL "Код" FORMAT ">>>>>>>>>9":U
      Buf_goods.gds-name FORMAT "X(30)":U
      Buf_ext-classif.Key#_One COLUMN-LABEL "Код EASYFUEL" FORMAT ">>>>>>>>9":U

HEADER  date_string AT 5 format "X(35)"
 string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(195)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 195).
date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).


PUT  STREAM PrnLibStream
SPACE(25) ( frame {&frame-name}:title )
format "x(90)" SKIP(1) .
FORM HEADER
Line format "X(195)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME ext-list  .
run waitfram-show in this-procedure ("Ждите...").
v-doc-rec = recid(buf_ext-classif).
DO WHILE available buf_ext-classif :
  GET prev {&browse-name}.
END.
GET next {&browse-name}.
DO WHILE available buf_ext-classif :
  Display STREAM PrnLibStream
            Buf_goods.artic
            Buf_goods.gds-code
            Buf_goods.gds-name
            Buf_ext-classif.Key#_One
 with FRAME ext-list .
  DOWN STREAM PrnLibStream 1
  with FRAME ext-list  .
  assign
  accum-count = accum-count + 1
  .
  GET next {&browse-name}.
END.
UNDERLINE  STREAM PrnLibStream
    Buf_goods.artic
    Buf_goods.gds-code
    Buf_goods.gds-name
    Buf_ext-classif.Key#_One
with FRAME ext-list .

DISPLAY STREAM PrnLibStream
"ИТОГО"     @ Buf_goods.artic
accum-count @ Buf_goods.gds-name
with frame ext-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME ext-list.
output  STREAM PrnLibStream CLOSE.
REPOSITION {&browse-name} to recid v-doc-rec no-error.
APPLY "display" to {&browse-name}.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br Dialog-Frame 
PROCEDURE proc-br :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
{ ref/brwsretr.i }

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-artic Dialog-Frame 
PROCEDURE proc-find-artic :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as character no-undo.

define buffer buff_ext-classif for ub.ext-classif.
define variable doc-rec as recid no-undo.
  doc-rec = ? .
  find first  Buff_ext-classif no-lock where
              Buff_ext-classif.db-num = -1
          and Buff_ext-classif.classif-subject   = {&extclass_goods}
          AND Buff_ext-classif.classif-name  = {&extclass_goods_easyfuel}
          and can-find(first  buf_goods no-lock where
                              buf_goods.gds-code =  int(entry(2,Buff_ext-classif.uniq-key-rec, {&delim-key})) and
                              buf_goods.artic = pardoc-code
                              )
          no-error  .

  if available Buff_ext-classif then
  doc-rec = recid (Buff_ext-classif) .

  reposition {&browse-name} to recid doc-rec no-error .
  if not error-status :error then do:
     apply "VALUE-CHANGED" to  {&browse-name}  in frame {&frame-name}.
  end.
  else do:
       message " Запись не найдена " view-as alert-box information .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-code Dialog-Frame 
PROCEDURE proc-find-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as INTEGER no-undo.

define buffer buff_ext-classif for ub.ext-classif.
define variable doc-rec as recid no-undo.
  doc-rec = ? .
  find first  Buff_ext-classif no-lock where
              Buff_ext-classif.db-num = -1
          and Buff_ext-classif.nonunique   = pardoc-code
          and Buff_ext-classif.classif-subject   = {&extclass_goods}
          AND Buff_ext-classif.classif-name  = {&extclass_goods_easyfuel}
          and can-find(first  buf_goods no-lock where
                              buf_goods.gds-code =  int(entry(2,Buff_ext-classif.uniq-key-rec, {&delim-key})) and
                              buf_goods.gds-code = pardoc-code
                              )
          no-error  .

  if available Buff_ext-classif then
  doc-rec = recid (Buff_ext-classif) .

  reposition {&browse-name} to recid doc-rec no-error .
  if not error-status :error then do:
     apply "VALUE-CHANGED" to  {&browse-name}  in frame {&frame-name}.
  end.
  else do:
       message " Запись не найдена " view-as alert-box information .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-name Dialog-Frame 
PROCEDURE proc-find-name :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as character no-undo .

define buffer buff_ext-classif for ub.ext-classif.
define variable doc-rec as recid no-undo.
  doc-rec = ? .
  find first  Buff_ext-classif no-lock where
              Buff_ext-classif.db-num = -1
          and Buff_ext-classif.classif-subject   = {&extclass_goods}
          AND Buff_ext-classif.classif-name  = {&extclass_goods_easyfuel}
          and can-find(first  buf_goods no-lock where
                              buf_goods.gds-code = int (entry(2,Buff_ext-classif.uniq-key-rec, {&delim-key})) and
                              buf_goods.gds-name begins pardoc-code
                              )
          no-error  .

  if available Buff_ext-classif then
  doc-rec = recid (Buff_ext-classif) .

  reposition {&browse-name} to recid doc-rec no-error .
  if not error-status :error then do:
     apply "VALUE-CHANGED" to  {&browse-name}  in frame {&frame-name}.
  end.
  else do:
       message " Запись не найдена " view-as alert-box information .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION mark-string Dialog-Frame 
FUNCTION mark-string RETURNS CHARACTER
( BUFFER loc-table FOR ub.ext-classif, input mark-list as CHARACTER ) :
RETURN ( IF LOOKUP( STRING( RECID( loc-table ) ), mark-list ) > 0 THEN "*" ELSE "":U ).
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

