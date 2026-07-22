&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE section_thbj-attr NO-UNDO LIKE thbj-attr
       field upper-prop-name as character
       field global_ as logical
       field host_ as logical
       field shop_ as logical
       field store_ as logical
       field db_ as logical
       field region_ as logical
       .
DEFINE TEMP-TABLE X_thbj-attr LIKE thbj-attr
       field ind1 as char
       index pi ind1
       .
DEFINE BUFFER X_thbj-attr_2v FOR thbj-attr.
DEFINE BUFFER X_thbj-attr_v FOR thbj-attr.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

ДЕРЕВО параметров IBS TH


Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/23/09
Author: Bakhtadze Natalya
Creation date: 01/23/09

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER bttns AS character NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "ДЕРЕВО параметров IBS TH".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/trg-def.i }
{ cmp/showinf.i }
{ gbl/thbjattr.i }
{ gbl/get-regf.i }
{ gbl/getcntxt.i def }
{ gbl/db-attr.i }
DEFINE VARIABLE v-value AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-2value AS CHARACTER NO-UNDO.
define variable add-region as character no-undo .

define temp-table ttLoad 
  field fName as character label "Параметр" format "X(50)"
  field fValue as character label "Значение" format "X(420)"
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-2values

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_thbj-attr_2v section_thbj-attr X_thbj-attr ~
X_thbj-attr_v

/* Definitions for BROWSE BR-2values                                    */
&Scoped-define FIELDS-IN-QUERY-BR-2values get-thbjattr-l-and-v( BUFFER X_thbj-attr_2v, OUTPUT v-2value) NO-LABEL v-2value NO-LABEL   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-2values   
&Scoped-define SELF-NAME BR-2values
&Scoped-define QUERY-STRING-BR-2values FOR EACH X_thbj-attr_2v NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-2values OPEN QUERY {&SELF-NAME} FOR EACH X_thbj-attr_2v NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-2values X_thbj-attr_2v
&Scoped-define FIRST-TABLE-IN-QUERY-BR-2values X_thbj-attr_2v


/* Definitions for BROWSE BR-section                                    */
&Scoped-define FIELDS-IN-QUERY-BR-section section_thbj-attr.upper-prop-name SECTION_thbj-attr.GLOBAL_ SECTION_thbj-attr.host_ SECTION_thbj-attr.shop_ SECTION_thbj-attr.store_ SECTION_thbj-attr.db_ SECTION_thbj-attr.region_   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-section   
&Scoped-define SELF-NAME BR-section
&Scoped-define QUERY-STRING-BR-section FOR EACH section_thbj-attr NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-section OPEN QUERY {&SELF-NAME} FOR EACH section_thbj-attr NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-section section_thbj-attr
&Scoped-define FIRST-TABLE-IN-QUERY-BR-section section_thbj-attr


/* Definitions for BROWSE br-tree                                       */
&Scoped-define FIELDS-IN-QUERY-br-tree get-objregion(X_thbj-attr.obj-type, X_thbj-attr.obj-code)   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-tree   
&Scoped-define SELF-NAME br-tree
&Scoped-define QUERY-STRING-br-tree FOR EACH X_thbj-attr NO-LOCK WHERE X_thbj-attr.upper-prop-code = SECTION_thbj-attr.upper-prop-code      INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-tree OPEN QUERY {&SELF-NAME} FOR EACH X_thbj-attr NO-LOCK WHERE X_thbj-attr.upper-prop-code = SECTION_thbj-attr.upper-prop-code      INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-tree X_thbj-attr
&Scoped-define FIRST-TABLE-IN-QUERY-br-tree X_thbj-attr


/* Definitions for BROWSE BR-values                                     */
&Scoped-define FIELDS-IN-QUERY-BR-values get-thbjattr-l-and-v( BUFFER X_thbj-attr_v, OUTPUT v-value) NO-LABEL v-value NO-LABEL   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-values   
&Scoped-define SELF-NAME BR-values
&Scoped-define QUERY-STRING-BR-values FOR EACH X_thbj-attr_v NO-LOCK WHERE X_thbj-attr_v.prop-code > ''      INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-values OPEN QUERY {&SELF-NAME} FOR EACH X_thbj-attr_v NO-LOCK WHERE X_thbj-attr_v.prop-code > ''      INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-values X_thbj-attr_v
&Scoped-define FIRST-TABLE-IN-QUERY-BR-values X_thbj-attr_v


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-section}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-exp B-Help I-tooltip BR-section ~
b-copy b-load B-add B-chg B-del B-lkp B-1 b-hist1 br-tree BR-values BR-2values 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-thbjattr-l-and-v Dialog-Frame 
FUNCTION get-thbjattr-l-and-v RETURNS CHARACTER
  ( BUFFER buf_thbj-attr FOR ub.thbj-attr
   ,OUTPUT p-value AS CHARACTER

    )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-add
       MENU-ITEM m_region       LABEL "Регион" 
       MENU-ITEM m_db           LABEL "БД"            
       MENU-ITEM m_firm         LABEL "Фирма"         
       MENU-ITEM m_shop         LABEL "Магазин"       
       MENU-ITEM m_stock        LABEL "Склад"         .


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-1 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-add 
     LABEL "&Добавить" 
     SIZE 10 BY 1.

DEFINE BUTTON B-chg 
     LABEL "&Изменить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-copy 
     LABEL "&Копия" 
     SIZE 10 BY 1.

DEFINE BUTTON B-del 
     LABEL "&Удалить" 
     SIZE 10 BY 1.

DEFINE BUTTON B-exp 
     LABEL "Экспорт в формате пакета СПН" 
     SIZE 40 BY 1.

DEFINE BUTTON b-load 
     IMAGE-UP FILE "cmp/b-print.bmp":U
     IMAGE-DOWN FILE "cmp/b-print.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/b-print.bmp":U  NO-CONVERT-3D-COLORS
     LABEL "Выгрузить"
     SIZE 3 BY 1 TOOLTIP "Выгрузить значения параметров в Excel".


DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-hist1 
     LABEL "&История" 
     SIZE 4 BY 1.

DEFINE BUTTON B-lkp 
     LABEL "&Просмотр" 
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE IMAGE I-tooltip
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.04.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-2values FOR 
      X_thbj-attr_2v SCROLLING.

DEFINE QUERY BR-section FOR 
      section_thbj-attr SCROLLING.

DEFINE QUERY br-tree FOR 
      X_thbj-attr SCROLLING.

DEFINE QUERY BR-values FOR 
      X_thbj-attr_v SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-2values
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-2values Dialog-Frame _FREEFORM
  QUERY BR-2values NO-LOCK DISPLAY
      get-thbjattr-l-and-v( BUFFER X_thbj-attr_2v, OUTPUT v-2value) FORMAT "X(255)":U WIDTH 60 NO-LABEL
v-2value FORMAT "X(255)" WIDTH 40  NO-LABEL
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 88 BY 6.5 FIT-LAST-COLUMN.

DEFINE BROWSE BR-section
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-section Dialog-Frame _FREEFORM
  QUERY BR-section NO-LOCK DISPLAY
      section_thbj-attr.upper-prop-name FORMAT "X(255)":U WIDTH 97 COLUMN-LABEL "Название секции"
SECTION_thbj-attr.GLOBAL_ FORMAT "+/" COLUMN-LABEL "Глоб"
SECTION_thbj-attr.region_ FORMAT "+/" COLUMN-LABEL "Рег"
SECTION_thbj-attr.host_ FORMAT "+/" COLUMN-LABEL "Фирма"
SECTION_thbj-attr.shop_ FORMAT "+/" COLUMN-LABEL "Маг"
SECTION_thbj-attr.store_ FORMAT "+/" COLUMN-LABEL "Скл"
SECTION_thbj-attr.db_ FORMAT "+/" COLUMN-LABEL "БД"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 123 BY 10.5
         TITLE "Все имеющиеся в системе секции параметров" ROW-HEIGHT-CHARS .63.

DEFINE BROWSE br-tree
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-tree Dialog-Frame _FREEFORM
  QUERY br-tree NO-LOCK DISPLAY
      get-objregion(X_thbj-attr.obj-type, X_thbj-attr.obj-code) FORMAT "X(20)" COLUMN-LABEL "Действует"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 35 BY 14.25 ROW-HEIGHT-CHARS .75 FIT-LAST-COLUMN.

DEFINE BROWSE BR-values
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-values Dialog-Frame _FREEFORM
  QUERY BR-values NO-LOCK DISPLAY
      get-thbjattr-l-and-v( BUFFER X_thbj-attr_v, OUTPUT v-value) FORMAT "X(255)":U WIDTH 60 NO-LABEL
v-value FORMAT "X(255)" WIDTH 40  NO-LABEL
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 88 BY 9
         TITLE "Значения параметров" ROW-HEIGHT-CHARS .58 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-exp AT ROW 1 COL 41 WIDGET-ID 96
     B-Help AT ROW 1 COL 95
     BR-section AT ROW 2 COL 1 WIDGET-ID 200
     b-copy AT ROW 12.75 COL 1 WIDGET-ID 96
     B-add AT ROW 12.75 COL 11 WIDGET-ID 98
     B-chg AT ROW 12.75 COL 21 WIDGET-ID 2
     B-del AT ROW 12.75 COL 31 WIDGET-ID 4
     B-lkp AT ROW 12.75 COL 41 WIDGET-ID 6
     b-load AT ROW 12.75 COL 108 WIDGET-ID 102
     B-1 AT ROW 12.75 COL 114 WIDGET-ID 94
     b-hist1 AT ROW 12.75 COL 120 WIDGET-ID 100
     br-tree AT ROW 14 COL 1 WIDGET-ID 300
     BR-values AT ROW 14 COL 36 WIDGET-ID 400
     BR-2values AT ROW 21.75 COL 36 WIDGET-ID 500
     I-tooltip AT ROW 12.75 COL 111 WIDGET-ID 10
     SPACE(10.37) SKIP(14.62)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE ""
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: section_thbj-attr T "?" NO-UNDO ub thbj-attr
      ADDITIONAL-FIELDS:
          field upper-prop-name as character
          field global_ as logical
          field host_ as logical
          field shop_ as logical
          field store_ as logical
          field db_ as logical
          field region_ as logical
          
      END-FIELDS.
      TABLE: X_thbj-attr T "?" ? ub thbj-attr
      ADDITIONAL-FIELDS:
          field ind1 as char
          index pi ind1
          
      END-FIELDS.
      TABLE: X_thbj-attr_2v B "?" ? ub thbj-attr
      TABLE: X_thbj-attr_v B "?" ? ub thbj-attr
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-section I-tooltip Dialog-Frame */
/* BROWSE-TAB br-tree b-hist1 Dialog-Frame */
/* BROWSE-TAB BR-values br-tree Dialog-Frame */
/* BROWSE-TAB BR-2values BR-values Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = TRUE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       B-add:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-add:HANDLE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-2values
/* Query rebuild information for BROWSE BR-2values
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_thbj-attr_2v NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE BR-2values */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-section
/* Query rebuild information for BROWSE BR-section
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH section_thbj-attr NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BR-section */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-tree
/* Query rebuild information for BROWSE br-tree
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH X_thbj-attr NO-LOCK
WHERE X_thbj-attr.upper-prop-code = SECTION_thbj-attr.upper-prop-code

    INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE br-tree */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-values
/* Query rebuild information for BROWSE BR-values
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_thbj-attr_v NO-LOCK
WHERE X_thbj-attr_v.prop-code > ''

    INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE BR-values */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-1 Dialog-Frame
ON CHOOSE OF B-1 IN FRAME Dialog-Frame
DO:
  IF NOT AVAILABLE X_thbj-attr_v THEN DO:
    bell.

  END.
  run gbl/v-taobj.w
      ( INPUT X_thbj-attr_v.upper-prop-code
       ,INPUT X_thbj-attr_v.prop-code
       ) NO-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
DEFINE VARIABLE v-add-obj-type AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-add-obj-code AS INTEGER NO-UNDO.
DEFINE BUFFER buf_thbj-attr FOR ub.thbj-attr.
IF NOT AVAILABLE section_thbj-attr THEN DO:
add-region = ''.
   RETURN NO-APPLY.
END.
if add-region = '':U then do:
   run gbl/pop-up.p ( input self:handle, input no) no-error.
end.
if add-region = '':U then return no-apply.

RUN proc-add IN THIS-PROCEDURE ( INPUT add-region
                                 ,INPUT section_thbj-attr.upper-prop-code
                                 ,OUTPUT v-add-obj-type
                                 ,OUTPUT v-add-obj-code) NO-ERROR.

 APPLY "VALUE-CHANGED" TO br-section.
 IF v-add-obj-code > 0  THEN DO:
    FIND FIRST buf_thbj-attr NO-LOCK WHERE
              buf_thbj-attr.upper-prop-code = section_thbj-attr.upper-prop-code
         AND  buf_thbj-attr.obj-type = v-add-obj-type
        AND  buf_thbj-attr.obj-code = v-add-obj-code NO-ERROR.
    IF AVAILABLE buf_thbj-attr THEN DO:
       REPOSITION br-tree TO RECID RECID(buf_thbj-attr) NO-ERROR.
       APPLY "entry" TO br-tree.
       APPLY "VALUE-CHANGED" TO br-tree.
    END.
 END.
 ELSE DO:

 END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  define variable var-rec-id as recid no-undo.
  IF AVAILABLE X_thbj-attr THEN do:
     var-rec-id = recid (X_thbj-attr).
     RUN proc-upd-lkp IN THIS-PROCEDURE ( INPUT {&UPDATE}
                                         ,INPUT X_thbj-attr.upper-prop-code
                                         ,INPUT X_thbj-attr.obj-type
                                         ,INPUT X_thbj-attr.obj-code) NO-ERROR.
      APPLY "VALUE-CHANGED" TO br-section.
      REPOSITION br-tree TO RECID var-rec-id NO-ERROR.
      APPLY "entry" TO br-tree.
      APPLY "VALUE-CHANGED" TO br-tree.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-copy Dialog-Frame
ON CHOOSE OF b-copy IN FRAME Dialog-Frame /* Копия */
DO:
if not available X_thbj-attr then return no-apply.
if X_thbj-attr.obj-type = ''
and X_thbj-attr.obj-code = 0 then do:
  message
  substitute("CКОПИРОВАТЬ ПАРАМЕТРЫ МОЖНО ТОЛЬКО С ОБЪЕКТА ТОГО ЖЕ ТИПА!!!&1&1&1" +
             "НЕОТКУДА КОПИРОВАТЬ ГЛОБАЛЬНЫЕ ПАРАМЕТРЫ!!!"
             , {&new-line})
  view-as alert-box error .
  return no-apply.
end.
run proc-b-copy in this-procedure ( input X_thbj-attr.upper-prop-code
                                   ,input X_thbj-attr.obj-type
                                   ,input X_thbj-attr.obj-code ) no-error.
if error-status:error then do:
  apply "ENTRY" to br-tree.
  return no-apply.
end.
APPLY "VALUE-CHANGED" TO br-section.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  IF AVAILABLE X_thbj-attr THEN DO:
   /*проверим что есть вышестоящая*/
   IF X_thbj-attr.obj-type = '' THEN DO:
     MESSAGE
     "НЕЛЬЗЯ УДАЛИТЬ СЕКЦИЮ с областью действия ГЛОБАЛЬНО!"
     VIEW-AS ALERT-BOX ERROR.
     UNDO, RETURN NO-APPLY.
   END.
   MESSAGE
   substitute("Вы действительно хотите удалить ВСЮ СЕКЦИЮ данного параметра с областью действия &1"
               , get-objregion(X_thbj-attr.obj-type, X_thbj-attr.obj-code))
   VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.

   IF NOT glog THEN RETURN NO-APPLY.
   RUN thbjattr_delete-section  IN THIS-PROCEDURE (
                                                    input  X_thbj-attr.obj-type
                                                   ,INPUT X_thbj-attr.obj-code
                                                   ,INPUT X_thbj-attr.upper-prop-code) NO-ERROR.
   APPLY "VALUE-CHANGED" TO br-section.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exp Dialog-Frame
ON CHOOSE OF B-exp IN FRAME Dialog-Frame /* Экспорт в формате пакета СПН */
DO:
  run utl/thbjexp.p ( INPUT parparentproc).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist1 Dialog-Frame
ON CHOOSE OF b-hist1 IN FRAME Dialog-Frame /* История */
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER no-undo.
  IF AVAILABLE X_thbj-attr THEN DO:

    run ref/cthbjatr.w (
                       input parparentproc
                      ,input v-cntxt-host-code-obj
                      ,input v-cntxt-obj-type
                      ,input v-cntxt-obj-code
                      ,input '' /*bttns*/
                      ,input "section" /*p-mode*/
                      ,input X_thbj-attr.obj-type /*p-obj-type*/
                      ,input X_thbj-attr.obj-code /*p-obj-code*/
                      ,input X_thbj-attr.upper-prop-code
                      ,input X_thbj-attr.prop-code
                      ,input ? /* p-corr-user-db-num  */
                      ,input "":U /* p-corr-user-name  */
                      ,input "":U /* p-subject  */
                      ,input v-cntxt-db-num /* p-db-num */
                      ,input-output v-rid-list  ) no-error .
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-load
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-load Dialog-Frame
ON CHOOSE OF b-load IN FRAME Dialog-Frame /* Выгрузка в Excel */
DO:
  define variable vFile      as character  no-undo.
  define variable vCurRow    as integer no-undo.
  define variable vSelectRow as logical no-undo.
  define variable exlim      as class ibs.th.bge.execlimpexp no-undo.
  define variable vExcelApp  as component-handle no-undo.
  
  empty temp-table ttLoad.

  vCurRow = br-values:focused-row.
  
  if vCurRow = ? then
  do:
    message "Нет параметров для выгрузки." view-as alert-box.
    return no-apply.
  end.
  vSelectRow = br-values:select-row(1).
  do while vSelectRow:
    if br-values:get-browse-column(1):screen-value <> "" then 
    do:
      create ttLoad.
      assign
        ttLoad.fName  = br-values:get-browse-column(1):screen-value
        ttLoad.fValue = br-values:get-browse-column(2):screen-value
      .
    end.
    vSelectRow = br-values:select-next-row().
  end.
   
  br-values:select-row(vCurRow). 

  vFile = substitute(
    "sec_&1_&2&3.txt",
    section_thbj-attr.upper-prop-code,
    X_thbj-attr.obj-type,
    X_thbj-attr.obj-code
  ).
  output to value(vFile).
  output close.
  vFile = search(vFile).
  
  exlim = new ibs.th.bge.execlimpexp ().
  exlim:expToExcel(temp-table ttLoad:handle, vFile).
  
  os-delete vFile value(vFile).
  os-delete vFile value(search("last.dir")).

  vFile = replace(vFile, ".txt", ".xlsx").
  if search(vFile) <> ? then do:
    create "Excel.Application":U vExcelApp no-error.
    if error-status :error then do:
      message "Не удалось открыть выгруженный файл" vFile "." view-as alert-box.
    end.    
    else do:
      vExcelApp:Workbooks:Open(vFile).
      vExcelApp:Visible = TRUE.
      release object vExcelApp.
    end.  
  end.  
  else
    message "Неизвестная ошибка при выгрузке." view-as alert-box.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lkp Dialog-Frame
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
    IF AVAILABLE X_thbj-attr THEN do:
     RUN proc-upd-lkp IN THIS-PROCEDURE ( INPUT {&LOOKUP}
                                         ,INPUT X_thbj-attr.upper-prop-code
                                         ,INPUT X_thbj-attr.obj-type
                                         ,INPUT X_thbj-attr.obj-code) NO-ERROR.
  END.
  else do:
     message
     "В БД секция параметров отсутствует!"
     view-as alert-box .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-section
&Scoped-define SELF-NAME BR-section
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-section Dialog-Frame
ON VALUE-CHANGED OF BR-section IN FRAME Dialog-Frame /* Все имеющиеся в системе секции параметров */
DO:
  IF AVAILABLE sectioN_thbj-attr THEN DO:
    RUN  Openbrtree IN THIS-PROCEDURE ( INPUT SECTION_thbj-attr.upper-prop-code).
  END.
  ELSE DO:
    RUN  Openbrtree IN THIS-PROCEDURE ( INPUT '').
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-tree
&Scoped-define SELF-NAME br-tree
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-tree Dialog-Frame
ON VALUE-CHANGED OF br-tree IN FRAME Dialog-Frame
DO:
  IF AVAILABLE X_thbj-attr THEN DO:
   RUN OpenBrValues IN THIS-PROCEDURE (
                                        INPUT X_thbj-attr.upper-prop-code
                                         ,INPUT X_thbj-attr.obj-type
                                         ,INPUT X_thbj-attr.obj-code) NO-ERROR.
  END.
  ELSE DO:
      RUN OpenBrValues IN THIS-PROCEDURE (
                                           INPUT ''
                                           ,INPUT ?
                                           ,INPUT ?) no-error.

  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-values
&Scoped-define SELF-NAME BR-values
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-values Dialog-Frame
ON VALUE-CHANGED OF BR-values IN FRAME Dialog-Frame /* Значения параметров */
DO:
  IF AVAILABLE X_thbj-attr_v
  AND X_thbj-attr_v.prop-value-type = {&abl-datatype-void} THEN DO:
   ASSIGN
   br-values:HEIGHT = 6.87.
   BR-values:SCROLL-TO-CURRENT-ROW().
   br-values:REFRESH().
   RUN OpenBr2Values IN THIS-PROCEDURE (
                                        INPUT X_thbj-attr_v.prop-code
                                         ,INPUT X_thbj-attr_v.obj-type
                                         ,INPUT X_thbj-attr_v.obj-code) NO-ERROR.
      br-2values:VISIBLE = TRUE.
      br-2values:REFRESH().
      br-2values:move-to-top().

  END.
  ELSE DO:
/*      message FRAME {&FRAME-NAME}:HEIGHT-CHARS view-as alert-box.*/
         ASSIGN
         br-values:HEIGHT-CHARS = FRAME {&FRAME-NAME}:HEIGHT-CHARS - 15. 
         br-values:move-to-top().
         br-2values:VISIBLE = FALSE.

         RUN OpenBr2Values IN THIS-PROCEDURE (
                                           INPUT ''
                                           ,INPUT ?
                                           ,INPUT ?) no-error.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-tooltip
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-tooltip Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-tooltip IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-tooltip AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-label AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-tooltip-code AS CHARACTER NO-UNDO.
  IF NOT AVAILABLE X_thbj-attr_v THEN DO:
    BELL.
  END.
  ELSE DO:
run thbjattr_tooltip in this-procedure (
             input   X_thbj-attr_v.upper-prop-code
            ,input  X_thbj-attr_v.prop-code
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
   MESSAGE
   v-tooltip SKIP
   v-tooltip-code
   VIEW-AS ALERT-BOX.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_db Dialog-Frame
ON CHOOSE OF MENU-ITEM m_db /* БД */
DO:
  ASSIGN
  add-region = {&db}.
  APPLY "CHOOSE" to b-add  in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_firm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_firm Dialog-Frame
ON CHOOSE OF MENU-ITEM m_firm /* Фирма */
DO:
  ASSIGN
  add-region = {&cmp}.
  APPLY "CHOOSE" to b-add  in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_shop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_shop Dialog-Frame
ON CHOOSE OF MENU-ITEM m_shop /* Магазин */
DO:
  ASSIGN
  add-region = {&shop}.
  APPLY "CHOOSE" to b-add  in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_stock
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_stock Dialog-Frame
ON CHOOSE OF MENU-ITEM m_stock /* Склад */
DO:
  ASSIGN
  add-region = {&stock}.
  APPLY "CHOOSE" to b-add  in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m_stock
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_region Dialog-Frame
ON CHOOSE OF MENU-ITEM m_region /* Регион */
DO:
  ASSIGN
  add-region = {&region}.
  APPLY "CHOOSE" to b-add  in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-2values
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
&Scoped-define BROWSE-NAME BR-values
{ gbl/app_help.i }
run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse BR-2values :handle
  ) .
run diasize_add_browse in this-procedure
  (input  'height':u
  ,input  browse BR-2values :handle
  ) .
/*run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse BR-section :handle
  ) .

run diasize_add_browse in this-procedure
  (input  'height':u
  ,input  browse br-tree :handle
  ) . */
run diasize_init in this-procedure .
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i GET }
  RUN fill-section IN THIS-PROCEDURE.
  RUN MYENABLE IN THIS-PROCEDURE.
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
  ENABLE b-quit B-exp B-Help I-tooltip BR-section b-copy B-add B-chg B-del 
         B-lkp B-1 b-hist1 br-tree BR-values BR-2values b-load
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-section Dialog-Frame 
PROCEDURE fill-section :
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
define variable v-label as character no-undo .         /*лабел атрибута */
define variable v-user-can-edit as logical no-undo .  /*пользователь может изменять в броусе*/
define variable v-output-display as logical no-undo .  /*виден в броусе*/
define variable v-other as char no-undo .              /*еще чего - нибудь*/
define variable v-host as logical no-undo .
define variable v-shop as logical no-undo .
define variable v-store as logical no-undo .
define variable v-global as logical no-undo .
define variable v-db as logical no-undo .
define variable v-region as logical no-undo .
define variable v-prop-list as character no-undo .
define variable v-prop-type-list as character no-undo .
define variable v-prop-label-list as character no-undo .

DEFINE BUFFER buf_section FOR SECTION_thbj-attr.
FOR EACH buf_SECTION:
  DELETE buf_SECTION.
END.
DO v-ii = 1 TO NUM-ENTRIES({&thbjattr-list-all}):
   RUN thbjattr_code_reg IN THIS-PROCEDURE (
                                         input ENTRY(v-ii, {&thbjattr-list-all}) /*   код секции */
                                        ,input '' /* код атрибута */
                                        ,OUTPUT v-label
                                        ,OUTPUT v-user-can-edit
                                        ,OUTPUT v-output-display
                                        ,OUTPUT v-other
                                        ,OUTPUT v-prop-list
                                        ,OUTPUT v-prop-type-list
                                        ,OUTPUT v-prop-label-list
                                        ,OUTPUT v-global
                                        ,OUTPUT v-host
                                        ,OUTPUT v-shop
                                        ,OUTPUT v-store
                                        ,OUTPUT v-db
                                        ,OUTPUT v-region
                                        ) NO-ERROR.
  IF v-user-can-edit
  and index(v-other, "spr-ext=") > 0 THEN DO:
      CREATE buf_SECTION.
      ASSIGN
      buf_SECTION.upper-prop-code = ENTRY(v-ii, {&thbjattr-list-all})
      buf_SECTION.upper-prop-name = v-label
      buf_SECTION.GLOBAL_ = v-global
      buf_SECTION.host_ = v-host
      buf_SECTION.shop_ = v-shop
      buf_SECTION.store_ = v-store
      buf_SECTION.db_ = v-db
      buf_SECTION.region_ = v-region
      .
  END.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-tt Dialog-Frame 
PROCEDURE init-tt :
DEFINE INPUT PARAMETER p-upper-prop-code AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-host-code AS INTEGER NO-UNDO.
DEFINE VARIABLE v-region-code AS INTEGER NO-UNDO.
DEFINE VARIABLE v-db-attr-type AS CHARACTER NO-UNDO.
define buffer buf_thbj-attr for ub.thbj-attr .
empty TEMP-TABLE  x_thbj-attr .

for each buf_thbj-attr no-lock where
         buf_thbj-attr.upper-prop-code = p-upper-prop-code
     AND (buf_thbj-attr.prop-code       = ''
          OR buf_thbj-attr.prop-value-type = {&abl-datatype-void})
    :
  find first x_thbj-attr where
              x_thbj-attr.obj-type = buf_thbj-attr.obj-type and
              x_thbj-attr.obj-code = buf_thbj-attr.obj-code no-error .

  if not available x_thbj-attr then do:
    create  x_thbj-attr.
    BUFFER-COPY buf_thbj-attr TO X_thbj-attr.

  end.
  if buf_thbj-attr.obj-type  = "" THEN DO:

    assign
    x_thbj-attr.ind1 =  "0" + string( 0,"999999999") + "   " + string( 0 ,"999999999" )
    .
  END.
  else if buf_thbj-attr.obj-type  = {&cmp} THEN DO:
    assign
    x_thbj-attr.ind1 =  "0" + string(buf_thbj-attr.obj-code,"999999999") + "   " + string( 0 ,"999999999" )
    .
  END.
  else if buf_thbj-attr.obj-type  = {&region} THEN DO:     
    assign
    x_thbj-attr.ind1 =  "0" + string(buf_thbj-attr.obj-code,"999999999") + "   " + string( 0 ,"999999999" )
    .
  END.
  ELSE IF buf_thbj-attr.obj-type = {&db} THEN DO:
      run db-attr-value in this-procedure (buf_thbj-attr.obj-code, 
                                           "reg-code", 
                                           output v-region-code,
                                           output v-db-attr-type) no-error.
      if v-region-code = ? then v-region-code = 0.                                     
      x_thbj-attr.ind1 =  "0" + string(v-region-code,"999999999") + "region" + string(buf_thbj-attr.obj-code ,":999999999" ).
     /*X_thbj-attr.ind1 = "0" + string( buf_thbj-attr.obj-code,":999999999") + "   " + string( 0 ,"999999999" ).*/
  END.  
  else do:
    { gbl/hostcode.i
      buf_thbj-attr.obj-type
      buf_thbj-attr.obj-code
      v-host-code
      }
     x_thbj-attr.ind1 =  "0" + string(v-host-code,"999999999") + buf_thbj-attr.obj-type + string(buf_thbj-attr.obj-code ,"999999999" ).
   end.
   
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
assign
b-add:menu-mouse in frame {&frame-name}  = 1
section_thbj-attr.upper-prop-name:RESIZABLE IN BROWSE br-section = YES
    .

DO v-ii = 1 TO BROWSE br-values:NUM-COLUMNS:
  ASSIGN
  BROWSE br-values:GET-BROWSE-COLUMN(v-ii):RESIZABLE = YES.
END.
b-hist1:load-image("cmp/b-hist.bmp":u) .
b-hist1:TOOLTIP = "&История" .
DO v-ii = 1 TO BROWSE br-2values:NUM-COLUMNS:
  ASSIGN
  BROWSE br-2values:GET-BROWSE-COLUMN(v-ii):RESIZABLE = YES.
END.

br-values:height IN FRAME {&FRAME-NAME} = 12.85. 
/*br-values:height IN FRAME {&FRAME-NAME} = 14.25.*/

ENABLE
b-quit
B-Help
BR-section
B-copy WHEN LOOKUP("b-chg", bttns) > 0 AND g#db-num = 0 AND NOT TRANSACTION
B-chg WHEN LOOKUP("b-chg", bttns) > 0 AND g#db-num = 0 AND NOT TRANSACTION
B-del WHEN LOOKUP("b-chg", bttns) > 0 AND g#db-num = 0 AND NOT TRANSACTION
b-add WHEN LOOKUP("b-chg", bttns) > 0 AND g#db-num = 0 AND NOT TRANSACTION
b-exp WHEN g#db-num = 0
b-lkp
b-1
b-hist1
BR-values
br-2values
br-tree
i-tooltip
b-load
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
APPLY "ENTRY" TO br-section.
APPLY "VALUE-CHANGED" TO br-section.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr2values Dialog-Frame 
PROCEDURE Openbr2values :
DEFINE INPUT PARAMETER p-upper-prop-code AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code AS integer NO-UNDO.
IF p-upper-prop-code = '' THEN DO:
    OPEN QUERY br-2values
    FOR EACH X_thbj-attr_2v NO-LOCK WHERE  FALSE INDEXED-REPOSITION.

END.
ELSE DO:
    OPEN QUERY br-2values
    FOR EACH X_thbj-attr_2v NO-LOCK WHERE
           X_thbj-attr_2v.upper-prop-code = p-upper-prop-code
        AND X_thbj-attr_2v.obj-type = p-obj-type
        AND X_thbj-attr_2v.obj-code = p-obj-code
        AND X_thbj-attr_2v.prop-code > ''
        INDEXED-REPOSITION.

END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBrtree Dialog-Frame 
PROCEDURE OpenBrtree :
DEFINE INPUT PARAMETER p-upper-prop-code AS CHARACTER NO-UNDO.
define variable v-label as character no-undo .         /*лабел атрибута */
define variable v-user-can-edit as logical no-undo .   /*пользователь может изменять в броусе*/
define variable v-output-display as logical no-undo .  /*виден в броусе*/
define variable v-other as char no-undo .              /*еще чего - нибудь*/
define variable v-host as logical no-undo .
define variable v-shop as logical no-undo .
define variable v-store as logical no-undo .
define variable v-global as logical no-undo .
define variable v-db as logical no-undo .
define variable v-region as logical no-undo .
define variable v-prop-list as character no-undo .
define variable v-prop-type-list as character no-undo .
define variable v-prop-label-list as character no-undo .
/*найдем какие регионы доступны*/
RUN thbjattr_code_reg IN THIS-PROCEDURE (
                                      input p-upper-prop-code /*   код секции */
                                    ,input '' /* код атрибута */
                                    ,OUTPUT v-label
                                    ,OUTPUT v-user-can-edit
                                    ,OUTPUT v-output-display
                                    ,OUTPUT v-other
                                    ,OUTPUT v-prop-list
                                    ,OUTPUT v-prop-type-list
                                    ,OUTPUT v-prop-label-list
                                    ,OUTPUT v-global
                                    ,OUTPUT v-host
                                    ,OUTPUT v-shop
                                    ,OUTPUT v-store
                                    ,output v-db
                                    ,output v-region
                                    ) NO-ERROR.
                                    
assign
menu-item m_firm:sensitive in menu menu-b-add = v-host
menu-item m_shop:sensitive in menu menu-b-add = v-shop
menu-item m_stock:sensitive in menu menu-b-add = v-store
menu-item m_db:sensitive in menu menu-b-add = v-db
menu-item m_region:sensitive in menu menu-b-add = v-region
.
RUN init-tt IN THIS-PROCEDURE ( INPUT p-upper-prop-code) NO-ERROR.
OPEN QUERY br-tree
FOR EACH X_thbj-attr NO-LOCK
WHERE X_thbj-attr.upper-prop-code = p-upper-prop-code
    AND (X_thbj-attr.prop-code = '' OR X_thbj-attr.prop-value-type = {&abl-datatype-void})
INDEXED-REPOSITION.
APPLY "VALUE-CHANGED" TO br-tree IN FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBrValues Dialog-Frame 
PROCEDURE OpenBrValues :
DEFINE INPUT PARAMETER p-upper-prop-code AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code AS integer NO-UNDO.
IF p-upper-prop-code = '' THEN DO:
    OPEN QUERY br-values
    FOR EACH X_thbj-attr_v NO-LOCK WHERE  FALSE INDEXED-REPOSITION.

END.
ELSE DO:
    OPEN QUERY br-values
    FOR EACH X_thbj-attr_v NO-LOCK WHERE
           X_thbj-attr_v.upper-prop-code = p-upper-prop-code
        AND X_thbj-attr_v.obj-type = p-obj-type
        AND X_thbj-attr_v.obj-code = p-obj-code
        AND X_thbj-attr_v.prop-code > ''
        INDEXED-REPOSITION.

END.
APPLY "VALUE-CHANGED" TO br-values IN FRAME {&FRAME-NAME}.

CLOSE QUERY BR-values.
OPEN QUERY BR-values
FOR EACH X_thbj-attr_v NO-LOCK WHERE
       X_thbj-attr_v.upper-prop-code = p-upper-prop-code
    AND X_thbj-attr_v.obj-type = p-obj-type
    AND X_thbj-attr_v.obj-code = p-obj-code
    AND X_thbj-attr_v.prop-code > ''
    INDEXED-REPOSITION.
APPLY "VALUE-CHANGED" TO br-values IN FRAME {&FRAME-NAME}.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-add Dialog-Frame 
PROCEDURE proc-add :
DEFINE INPUT PARAMETER p-region AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-upper-prop-code AS CHARACTER NO-UNDO.
define output parameter v-add-obj-type as character no-undo .
define output parameter v-add-obj-code as integer no-undo .
define variable v-recids as character no-undo .
define variable v-firm-code as integer no-undo .
define variable v-reg-code as integer no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_db      for ub.db.
define buffer buf_regions for ub.regions.
add-region = ''.
case p-region:
  when {&db} then do:
     run adm\dbs.w(  input parParentProc
                   , input "b-sel":U
                   , output v-recids
          ).
     if v-recids = '' then return.
     find first buf_db no-lock
                       where recid(buf_db) = integer(entry(1, v-recids)).
     if available buf_db then                  
     assign
        v-add-obj-type = {&db}
        v-add-obj-code = buf_db.db-num
     .
  end.
  when {&cmp} then do:
      run adm/sconfs.w (
            input parParentProc
          , input "b-sel":U
          , input no
          , input 0
          , output v-firm-code
          , input-output v-recids
      ) no-error.
    if v-recids = '' then return.
    find first buf_sysconf no-lock
                      where recid(buf_sysconf) = integer(entry(1, v-recids)).
    assign
    v-add-obj-type = {&cmp}
    v-add-obj-code = buf_sysconf.host-code
    .

  end.
  when {&shop} then do:
    run ref/thobjs.w
        ( input parparentproc
        , input this-procedure:handle
        , input "b-sel"
        , input {&all}
        , input {&shop} /*p-obj-type*/
        , input ? /*p-db-num*/
        , input ? /*p-host-code*/
        , input-output v-recids ) no-error .
    if v-recids = '' then return.
    find first buf_clients no-lock
                      where recid(buf_clients) = integer(entry(1, v-recids)).
    assign
    v-add-obj-type = buf_clients.obj-type
    v-add-obj-code = buf_clients.obj-code
    .
  end.
  when {&stock} then do:
    run ref/thobjs.w
        ( input parparentproc
        , input this-procedure:handle
        , input "b-sel"
        , input {&all}
        , input {&stock} /*p-obj-type*/
        , input ? /*p-db-num*/
        , input ? /*p-host-code*/
        , input-output v-recids ) no-error .
    if v-recids = '' then return.
    find first buf_clients no-lock
                      where recid(buf_clients) = integer(entry(1, v-recids)).
    assign
    v-add-obj-type = buf_clients.obj-type
    v-add-obj-code = buf_clients.obj-code
    .
  end.
  when {&region} then do:
     run ref/regions.w ( input  parparentproc
                        , input  {&choose}
                        , output v-reg-code
                        ).
  
     if v-reg-code = ? then return.
     find first buf_regions no-lock
          where buf_regions.reg-code = v-reg-code
     no-error .
     if available buf_regions then
     assign
        v-add-obj-type = {&region}
        v-add-obj-code = buf_regions.reg-code
     .
  end.
end case.
run proc-upd-lkp in this-procedure (
                                     input {&update}
                                    ,input p-upper-prop-code
                                    ,input v-add-obj-type
                                    ,input v-add-obj-code ) no-error.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-copy Dialog-Frame 
PROCEDURE proc-b-copy :
DEFINE INPUT PARAMETER p-upper-prop-code AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code AS INTEGER NO-UNDO.

define variable v-rid-list as character no-undo .
define variable v-firm-code  as integer no-undo .
define variable v-from-obj-code  as integer no-undo .
define variable v-found  as decimal no-undo .

define buffer buf_clients for ub.clients.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_shop for ub.shop.
define buffer buf_store for ub.store.
define buffer buf_db for ub.db.

message
substitute("CКОПИРОВАТЬ ПАРАМЕТРЫ МОЖНО ТОЛЬКО С ОБЪЕКТА ТОГО ЖЕ ТИПА!!!&1&1&1" +
           "Выберите объект, С КОТОРОГО ХОТИТЕ СКОПИРОВАТЬ ПАРАМЕТРЫ В ТЕКУЩИЙ ОБЪЕКТ (&2&3)&1" +
           "Секция:&1&4"
           , {&new-line}
           , p-obj-type
           , p-obj-code
           , section_thbj-attr.upper-prop-name
           )
view-as alert-box.
CASE p-obj-type:
  WHEN {&cmp} THEN DO:
    message
    "Выберите ФИРМУ для копирования ПАРАМЕТРОВ"
    view-as alert-box WARNING.
    run adm/sconfs.w (
          input parParentProc
        , input "b-sel":U
        , input no
        , input 0
        , output v-firm-code
        , input-output v-rid-list
    ) no-error.
    if v-rid-list = "":U then return.
    find first buf_sysconf no-lock
                      where recid(buf_sysconf) = integer(entry(1, v-rid-list)).
    v-from-obj-code = buf_sysconf.host-code.
  END.
  WHEN {&shop} THEN DO:
    message
    "Выберите МАГАЗИН для копирования ПАРАМЕТРОВ"
    view-as alert-box WARNING.
    run adm/shops.w ( input parparentproc
                      ,input "b-sel"
                      ,input-output v-rid-list
                      ,no ).
    if v-rid-list = "":U then return.
    find first buf_shop no-lock where
            recid(buf_shop) = integer(v-rid-list) .
    v-from-obj-code = buf_shop.obj-code.
  END.
  WHEN {&stock} THEN DO:
    message
    "Выберите СКЛАД для копирования ПАРАМЕТРОВ"
    view-as alert-box WARNING.
    run adm/stores.w ( input parparentproc
                      ,input "b-sel"
                      ,input-output v-rid-list
                      ,input no ).
    if v-rid-list = "":U then return.
    find first buf_store no-lock where
            recid(buf_store) = integer(v-rid-list) .
    v-from-obj-code = buf_store.obj-code.
  END.
  when {&db} then do:
    message
    "Выберите БД для копирования ПАРАМЕТРОВ"
    view-as alert-box WARNING.
    run adm/dbs.w ( input parparentproc
                      ,input "b-sel"
                      ,output v-rid-list
                       ).
    if v-rid-list = "":U then return.
    find first buf_db no-lock where
            recid(buf_db) = integer(v-rid-list) .
    v-from-obj-code = buf_db.db-num.
  end.
END CASE.
run waitfram-show in this-procedure ( input "Ждите..." ).
FOR each thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
run thbjattr_get-section  in this-procedure (
   input  p-obj-type
  ,input  v-from-obj-code
  ,input p-upper-prop-code
  ,input '':U /*p-mode*/
  ,input-output table thbjattr_thbj-attr
  ,output v-found
                                      ) no-error .
  if not error-status:error then do:
    run thbjattr_set-section in this-procedure (
                                           input p-obj-type
                                          ,input p-obj-code
                                          ,input p-upper-prop-code
                                          ,input table thbjattr_thbj-attr ) no-error .
    IF ERROR-STATUS:ERROR THEN DO:
      run waitfram-hide in this-procedure .
      MESSAGE
      SUBSTITUTE("Ошибка при записи параметров с объекта-источника:&1&2&1&3"
                  , {&NEW-LINE}
                  ,  ERROR-STATUS:get-message(1)
                  , RETURN-VALUE)
      VIEW-AS ALERT-BOX ERROR.
      undo, RETURN ERROR.
   END.
  end.
  ELSE DO:
     run waitfram-hide in this-procedure .
     MESSAGE
     SUBSTITUTE("Ошибка при чтении параметров с объекта-источника:&1&2&1&3"
                , {&NEW-LINE}
                ,  ERROR-STATUS:get-message(1)
                , RETURN-VALUE)
     VIEW-AS ALERT-BOX ERROR.
     undo, RETURN ERROR.
  END.
run waitfram-hide in this-procedure .
message
substitute("Скопирована секция&6&1&6 с &4&5 на &2&3"
            , section_thbj-attr.upper-prop-name
            , p-obj-type
            , p-obj-code
            , p-obj-type
            , v-from-obj-code
            , {&new-line}
            )
view-as alert-box .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-upd-lkp Dialog-Frame 
PROCEDURE proc-upd-lkp :
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-upper-prop-code AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code AS CHARACTER NO-UNDO.

define variable v-label as character no-undo .         /*лабел атрибута */
define variable v-user-can-edit as logical no-undo .  /*пользователь может изменять в броусе*/
define variable v-output-display as logical no-undo .  /*виден в броусе*/
define variable v-other as char no-undo .              /*еще чего - нибудь*/
define variable v-prop-list as character no-undo .
define variable v-prop-type-list as character no-undo .
define variable v-prop-label-list as character no-undo .
define variable v-global as logical no-undo .
define variable v-host as logical no-undo .
define variable v-shop as logical no-undo .
define variable v-store as logical no-undo .
define variable v-db as logical no-undo .
define variable v-region as logical no-undo .
define variable v-spr as character no-undo .
DEFINE VARIABLE ii AS INTEGER NO-UNDO.


  run thbjattr_code_reg  in this-procedure (
       input p-upper-prop-code
      ,input   '':U
      ,output v-label          /* лабел атрибута */
      ,output v-user-can-edit  /* пользователь может изменять в броусе */
      ,output v-output-display /* виден в броусе */
      ,output v-other          /* еще чего - нибудь */
      ,output v-prop-list
      ,output v-prop-type-list
      ,output v-prop-label-list
      ,output v-global
      ,output v-host
      ,output v-shop
      ,output v-store
      ,output v-db
      ,output v-region
  ).
  do ii = 1 to num-entries(v-other, {&slash-char}):
    if entry(ii, v-other, {&slash-char}) begins "spr-ext=":U then do:
      assign
      v-spr = entry(2, entry(ii, v-other, {&slash-char}), "=").
    end.
  end.

  run value(v-spr) (
                   input parparentproc
                  ,input p-mode
                  ,input p-obj-type
                  ,input p-obj-code
                  ) NO-ERROR.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-thbjattr-l-and-v Dialog-Frame 
FUNCTION get-thbjattr-l-and-v RETURNS CHARACTER
  ( BUFFER buf_thbj-attr FOR ub.thbj-attr
   ,OUTPUT p-value AS CHARACTER

    ) :
define variable v-label as character no-undo .         /*лабел атрибута */
define variable v-user-can-edit as logical no-undo .  /*пользователь может изменять в броусе*/
define variable v-output-display as logical no-undo .  /*виден в броусе*/
define variable v-other as char no-undo .              /*еще чего - нибудь*/
define variable v-host as logical no-undo .
define variable v-shop as logical no-undo .
define variable v-store as logical no-undo .
define variable v-global as logical no-undo .
define variable v-db as logical no-undo .
define variable v-region as logical no-undo .
define variable v-prop-list as character no-undo .
define variable v-prop-type-list as character no-undo .
define variable v-prop-label-list as character no-undo .
RUN thbjattr_code_reg IN THIS-PROCEDURE (
                                    input buf_thbj-attr.upper-prop-code
                                   ,input buf_thbj-attr.prop-code
                                   ,OUTPUT v-label
                                   ,OUTPUT v-user-can-edit
                                   ,OUTPUT v-output-display
                                   ,OUTPUT v-other
                                   ,OUTPUT v-prop-list
                                   ,OUTPUT v-prop-type-list
                                   ,OUTPUT v-prop-label-list
                                   ,OUTPUT v-global
                                   ,OUTPUT v-host
                                   ,OUTPUT v-shop
                                   ,OUTPUT v-store
                                   ,output v-db
                                   ,OUTPUT v-region
                                          ) NO-ERROR.
IF lookup(buf_thbj-attr.prop-code,v-prop-list) > 0 THEN DO:
case entry(lookup(buf_thbj-attr.prop-code,v-prop-list) , v-prop-type-list):
  when {&abl-datatype-character} then do:
    p-value = buf_thbj-attr.property-value-character.
  end.
  when {&abl-datatype-date} then do:
    p-value = string(buf_thbj-attr.property-value-date, "99/99/9999").
  end.
  when {&abl-datatype-decimal} then do:
    p-value = string(buf_thbj-attr.property-value-decimal).
  end.
  when {&abl-datatype-integer} then do:
    p-value = string(buf_thbj-attr.property-value-integer).
  end.
  when {&abl-datatype-logical} then do:
    p-value =  string(buf_thbj-attr.property-value-logical).
  end.
   when {&abl-datatype-void} then do:
    p-value =  "...".
  end.
  OTHERWISE DO:
    p-value = "!!!ОШИБКА-НЕИЗВЕСТНЫЙ ТИП ЗНАЧЕНИЯ".
  END.
  END CASE.
  if buf_thbj-attr.upper-prop-code = "gisMT" and
    (buf_thbj-attr.prop-code = "proxyPswd" or 
     buf_thbj-attr.prop-code = "OflinePswd" or
     buf_thbj-attr.prop-code = "MaxApiToken") and 
     p-value > ""
  then p-value = fill("*",length(p-value)).
  RETURN entry(lookup(buf_thbj-attr.prop-code,v-prop-list),  v-prop-label-list).
END.
ELSE DO:
    p-value = "!!!ОШИБКА-НЕИЗВЕСТНЫЙ ПАРАМЕТР".
    RETURN buf_thbj-attr.prop-code.

END.


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

