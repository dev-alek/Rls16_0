&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-mark
using ibs.th.gbl.sys.objsrv.
using ibs.th.str.marking.sts.*.
using ibs.th.str.marking.handlers.*.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DECLARATIONS d-mark 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка кодов маркировки

Автор: Шкляр Елена
Дата создания: 20/04/95
Author: Shklyar Elena
Creation date: 20/04/95

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка кодов маркировки".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/r-pril.i new }
{ gbl/userobjs.i }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
{ str/trdcalib.i }
{ cmp/mrk-strf.i }
{ gbl/color.i }
{ str/temp_upd.i }
{ gbl/key-rec.i  }
{ utl/gtin.i }
{ gbl/objsrv.i }
{ str/utd-typemark.i }

define input parameter parparentproc as widget-handle no-undo .
define input-output  PARAMETER TABLE FOR tt-marking-lines.
define input parameter p-mode as character no-undo .
define input parameter p-doc as character  no-undo . /*title*/
define input parameter p-type as integer   no-undo . /*тип документа 0 - все документы 1 - УТД со статусом 4 2 - внутренний приход 4 - чеки 5 - ЭДО в статусе новый 6 - серая зона*/ 
define input parameter p-parent_mark as character   no-undo . /*марка родитель*/
/* Local Variable Definitions ---                                       */

define variable EDOParSec  as class ibs.th.gbl.env.prmtrs.edo   no-undo.

define variable log-res     as log       no-undo.
define variable rr          as recid     no-undo.
define variable v_type      as char      no-undo.
define variable v-is-deploy as logical   no-undo .
define variable v-rid-list  as character no-undo .
define variable v-rid-list2 as character no-undo .
define variable v-db-list   as character no-undo .
define variable recid_mark  as integer   no-undo .
define variable title_name  as character no-undo .
define variable iLang       as integer   no-undo.
define variable p-value-logical as logical no-undo.
define variable p-value-character  as character no-undo.
define variable p-value-date       as date no-undo.
define variable p-value-decimal    as decimal no-undo.
define variable p-value-integer    as integer no-undo.
define variable p-param-type       as character no-undo.
define variable v-tth as handle no-undo .
define variable Tree        as class     tree no-undo .
define variable ungroup     as logical   no-undo .
define variable jj          as integer   no-undo .
define variable v-qnty-mark as integer   no-undo .
define variable mark-parent as character no-undo .
define variable v-edoc-type as logical   no-undo .
define variable mIsRasVneshReturn as logical no-undo init false.
/*define variable upd_mark    as logical   no-undo init true.*/
define temp-table tt-gray-marking-lines like tt-marking-lines .

define buffer buf_marking           for ub.marking .
define buffer buf_utd-marking-lines for ub.utd-marking-lines .
define buffer bf_utd-marking-lines  for ub.utd-marking-lines .
define buffer buf_utd-lines         for ub.utd-lines .
define buffer buf_parts             for ub.parts . 
define buffer buf_goods             for ub.goods .
define buffer buf_utd-err           for ub.utd-err .
DEFINE BUFFER X_marking             FOR tt-marking-lines.
DEFINE BUFFER X_marking-line        FOR tt-marking-lines.
define variable typem as character no-undo.
define variable v-scan-str  as character no-undo.
define variable v-manual    as logical   no-undo .
DEFINE VARIABLE v-timedelay as integer   no-undo .
define variable vMarkBrow2 as character no-undo.
define variable vLevel     as integer   no-undo init 1.

define variable varvalue as character no-undo.
define variable vartype  as character no-undo.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* Temp-Table and Buffer definitions                                    */
/*DEFINE NEW SHARED BUFFER X_marking FOR marking.            */
/*DEFINE NEW SHARED BUFFER X_marking-lines FOR marking-lines.*/



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-mark 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 16/02/20 - 12:57 pm

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-mark
&Scoped-define BROWSE-NAME br-mark

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_marking X_marking-line

/* Definitions for BROWSE br-bar-code                                       */
&Scoped-define FIELDS-IN-QUERY-br-bar-code X_marking.gds-code ~
X_marking.mark-parent X_marking.mark X_marking.unit X_marking.sts 
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-bar-code 
&Scoped-define QUERY-STRING-br-bar-code FOR EACH X_marking NO-LOCK where x_marking.doc-level = 1 and if Status_ <> 0 then if Status_ = 7 then x_marking.sts-utd =  else x_marking.sts-utd = 3 or X_marking.sts-utd = Status_ else x_marking.sts-utd <> 99 INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-bar-code OPEN QUERY br-bar-code FOR EACH X_marking NO-LOCK where x_marking.doc-level = 1 and if Status_ <> 0 then if Status_ = 7 then x_marking.sts-utd = Status_ else x_marking.sts-utd = 3 or X_marking.sts-utd = Status_ else x_marking.sts-utd <> 99 INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-bar-code X_marking
&Scoped-define FIRST-TABLE-IN-QUERY-br-bar-code X_marking

/* Definitions for BROWSE br-mark                                       */
&Scoped-define FIELDS-IN-QUERY-br-mark X_marking.gds-code ~
X_marking.mark-parent X_marking.mark X_marking.unit X_marking.sts 
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-mark 
&Scoped-define QUERY-STRING-br-mark if p-parent_mark eq "" ~
then FOR EACH X_marking NO-LOCK where x_marking.doc-level = 1 and if Status_ <> 0 then if Status_ = 7 then x_marking.sts-utd =  else x_marking.sts-utd = 3 or X_marking.sts-utd = Status_ else x_marking.sts-utd <> 99 indexed-reposition. ~
else FOR EACH X_marking NO-LOCK where x_marking.mark-parent = p-parent_mark and if Status_ <> 0 then if Status_ = 7 then x_marking.sts-utd = Status_ else x_marking.sts-utd = 3 or X_marking.sts-utd = Status_ else x_marking.sts-utd <> 99 INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-mark if p-parent_mark eq "" ~
then OPEN QUERY br-mark FOR EACH X_marking NO-LOCK where x_marking.doc-level = 1 and if Status_ <> 0 then if Status_ = 7 then x_marking.sts-utd = Status_ else x_marking.sts-utd = 3 or X_marking.sts-utd = Status_ else x_marking.sts-utd <> 99 INDEXED-REPOSITION. ~
else OPEN QUERY br-mark FOR EACH X_marking NO-LOCK where x_marking.mark-parent = p-parent_mark and if Status_ <> 0 then if Status_ = 7 then x_marking.sts-utd = Status_ else x_marking.sts-utd = 3 or X_marking.sts-utd = Status_ else x_marking.sts-utd <> 99 INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-mark X_marking
&Scoped-define FIRST-TABLE-IN-QUERY-br-mark X_marking


/* Definitions for BROWSE br-mark-item                                  */
&Scoped-define FIELDS-IN-QUERY-br-mark-item X_marking-line.gds-code ~
X_marking-line.mark-parent X_marking-line.mark X_marking-line.unit X_marking-line.sts 
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-mark-item 
&Scoped-define QUERY-STRING-br-mark-item for each X_marking-line no-lock where X_marking-line.mark-parent = vMarkBrow2 and if Status_ <> 0 then if Status_ = 7 then x_marking-line.sts-utd = Status_ else x_marking-line.sts-utd = 3 or X_marking-line.sts-utd = Status_ else x_marking-line.sts <> 99 INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-mark-item OPEN QUERY br-mark-item for each X_marking-line no-lock where X_marking-line.mark-parent = vMarkBrow2   and if Status_ <> 0 then if Status_ = 7 then x_marking-line.sts-utd = Status_ else x_marking-line.sts-utd = 3 or X_marking-line.sts-utd = Status_ else x_marking-line.sts <> 99 INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-mark-item X_marking-line
&Scoped-define FIRST-TABLE-IN-QUERY-br-mark-item X_marking-line


/* Definitions for DIALOG-BOX d-mark                                    */
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-mark ~
    ~{&OPEN-QUERY-br-mark}~
    ~{&OPEN-QUERY-br-mark-item}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b_block b_error v-mark b-hist b-mark ~
b-del c-status b-change Status_ br-mark b-mark-2 c-status-2 b-change-2 ~
br-mark-item 
&Scoped-Define DISPLAYED-OBJECTS v-mark F-text c-status Status_ c-status-2 ~
qnty-mark-2 f-qnty-unit qnty-mark 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD GdsName d-mark 
FUNCTION GdsName RETURNS CHARACTER
    ( input p-gds-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getStatusName d-mark 
FUNCTION getStatusName RETURNS CHARACTER
    ( input p-mark     as character,
      input p-sts-glob as integer,
      input p-sts-loc  as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
def var Marking as class mark no-undo .

/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-change 
     LABEL "&Поменять":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-look 
     LABEL "Просмотр":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-change-2 
     LABEL "Поменять":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-del 
     LABEL "&Удалить":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Выход ":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-hist 
     IMAGE-UP FILE "cmp/b-hist.bmp":U
     IMAGE-DOWN FILE "cmp/b-hist.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/b-hist.bmp":U NO-CONVERT-3D-COLORS
     LABEL "Ис&тория" 
     SIZE 3 BY 1.

DEFINE BUTTON b-mark 
     LABEL "&*" 
     SIZE 3 BY 1.

DEFINE BUTTON b-mark-2 
     LABEL "&*" 
     SIZE 3 BY 1.

DEFINE BUTTON bt-not-sel-all 
     LABEL "+" 
     SIZE 3 BY 1 TOOLTIP "Выбрать все".

DEFINE BUTTON bt-not-sel-all-2 
     LABEL "+" 
     SIZE 3 BY 1 TOOLTIP "Выбрать все".

DEFINE BUTTON bt-not-sel-desel-all 
     LABEL "-" 
     SIZE 3 BY 1 TOOLTIP "Отменить выбор".

DEFINE BUTTON bt-not-sel-desel-all-2 
     LABEL "-" 
     SIZE 3 BY 1 TOOLTIP "Отменить выбор".

DEFINE BUTTON b_block 
     LABEL "Проверка" 
     SIZE 10 BY 1.

DEFINE BUTTON b_error 
     LABEL "Ошибки" 
     SIZE 10 BY 1.

DEFINE VARIABLE c-status AS INTEGER FORMAT "-999":U INITIAL 0 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Все",1,
                     "Получен от поставщика",2,
                     "Требует корректировки",3,
                     "Ожидает поставки",4,
                     "Требует подписания",5
     DROP-DOWN-LIST
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE c-status-2 AS INTEGER FORMAT "-999":U INITIAL 0 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Все",1,
                     "Получен от поставщика",2,
                     "Требует корректировки",3,
                     "Ожидает поставки",4,
                     "Требует подписания",5
     DROP-DOWN-LIST
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE f-qnty-bar-code AS INTEGER FORMAT "->>>,>>>,>>9":U INITIAL 0 
     LABEL "Кол-во штрих-кодов" 
     VIEW-AS FILL-IN 
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-qnty-unit AS INTEGER FORMAT "->>>,>>>,>>9":U INITIAL 0 
     LABEL "Кол-во марок" 
     VIEW-AS FILL-IN 
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE F-text AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 100 BY 1.25
     FGCOLOR 12  NO-UNDO.

/*DEFINE VARIABLE qnty-bar-code AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0*/
/*     LABEL "из"                                                         */
/*     VIEW-AS FILL-IN                                                    */
/*     SIZE 5.5 BY 1 NO-UNDO.                                             */
/*                                                                        */
/*DEFINE VARIABLE qnty-bar-code2 AS INTEGER FORMAT "->,>>>>>9":U INITIAL 0*/
/*     LABEL "Просканировано штрих-кодов"                                 */
/*     VIEW-AS FILL-IN                                                    */
/*     SIZE 5.5 BY 1 NO-UNDO.                                             */

DEFINE VARIABLE qnty-mark AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     LABEL "из" 
     VIEW-AS FILL-IN 
     SIZE 5.5 BY 1 NO-UNDO.

DEFINE VARIABLE qnty-mark-2 AS INTEGER FORMAT "->,>>>>>9":U INITIAL 0 
     LABEL "Просканировано марок" 
     VIEW-AS FILL-IN 
     SIZE 5.5 BY 1 NO-UNDO.

/*DEFINE VARIABLE v-bar-code AS CHARACTER FORMAT "X(255)"*/
/*     LABEL "Штрих-код"                                 */
/*     VIEW-AS FILL-IN                                   */
/*     SIZE 71 BY 1.                                     */

DEFINE VARIABLE v-mark AS CHARACTER FORMAT "X(255)" 
     LABEL "Марка/Штрих-код" 
     VIEW-AS FILL-IN 
     SIZE 74 BY 1.

DEFINE VARIABLE Status_ AS INTEGER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Все", 0,
"Ожидает проверку", 1,
"Проверен", 7
     SIZE 41 BY 1 NO-UNDO.
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD StatusTHName d-utd
FUNCTION StatusTHName RETURNS CHARACTER
  (input p-stsTH as integer)  .
  Return Marking:GetLabel(p-stsTH) .
END FUNCTION .
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-bar-code FOR 
  X_marking SCROLLING.
  
DEFINE QUERY br-mark FOR 
  X_marking SCROLLING.

DEFINE QUERY br-mark-item FOR 
  X_marking-line SCROLLING.
&ANALYZE-RESUME

/*/* Browse definitions                                                   */     */
/*DEFINE BROWSE br-bar-code                                                      */
/*&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-bar-code d-mark _STRUCTURED*/
/*  QUERY br-bar-code NO-LOCK DISPLAY                                            */
/*  X_marking.marking-string column-label "*" format "X(1)":U                    */
/*  X_marking.gds-code COLUMN-LABEL "Код товара" FORMAT "999999999":U            */
/*  X_marking.gds-name COLUMN-LABEL "Наименование" FORMAT "x(210)":U width 55    */
/*  X_marking.mark COLUMN-LABEL "Штрих-код" FORMAT "x(56)":U width 33            */
/*  X_marking.box-qnty column-label "Кол-во" format "->>>>>>9.99":U              */
/*  X_marking.weight COLUMN-LABEL "Вес" FORMAT "x(10)":U width 10           */
/*/*  X_marking.stts COLUMN-LABEL "Текущий статус" FORMAT "X(30)":U width 20*/   */
/*/*  X_marking.stts-utd COLUMN-LABEL "Статус" FORMAT "X(30)":U width 20    */   */
/*/*  X_marking.in-code COLUMN-LABEL "ПН" FORMAT "X(15)":U                  */   */
/*/*  X_marking.out-code COLUMN-LABEL "РН" FORMAT "X(15)":U                 */   */
/*/*  X_marking.site COLUMN-LABEL "" FORMAT "X(1)":U                        */   */
/*/*  X_marking.unit COLUMN-LABEL "Ед.изм." FORMAT "x(8)":U                 */   */
/*/* _UIB-CODE-BLOCK-END */                                                      */
/*&ANALYZE-RESUME                                                                */
/*    WITH NO-ROW-MARKERS SEPARATORS SIZE 123.5 BY 11 FIT-LAST-COLUMN.           */
    
/* Browse definitions                                                   */
DEFINE BROWSE br-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-mark d-mark _STRUCTURED
  QUERY br-mark NO-LOCK DISPLAY
  X_marking.marking-string column-label "*" format "X(1)":U
  X_marking.gds-code COLUMN-LABEL "Код товара" FORMAT "999999999":U
  X_marking.gds-name COLUMN-LABEL "Наименование" FORMAT "x(210)":U width 15
  (if length(X_marking.mark) < 16 then "ШК" 
  else if ismark(X_marking.mark) then "КМ"
  else "АОД") @ typem COLUMN-LABEL "Тип!кода" FORMAT "x(3)":U
  X_marking.mark COLUMN-LABEL "Марка/Штрих-код" FORMAT "x(56)":U width 33
  
  X_marking.box-qnty column-label "Кол-во" format "->>>>>>9.99":U
  if ismark(X_marking.mark) and WeighedProd(X_marking.gds-code) then string(MarkWeight(X_marking.mark),">>>>>9.999") else "" @ X_marking.weight COLUMN-LABEL "Вес" FORMAT "x(10)":U width 10
  if not ismark(X_marking.mark) then "" else getStatusName(X_marking.mark,X_marking.sts,X_marking.sts-utd) @ X_marking.stts COLUMN-LABEL "Текущий статус" FORMAT "X(50)":U width 20 
/*  X_marking.stts-utd COLUMN-LABEL "Статус" FORMAT "X(30)":U width 20*/
/*  X_marking-line.in-code COLUMN-LABEL "ПН" FORMAT "X(15)":U */
/*  X_marking-line.out-code COLUMN-LABEL "РН" FORMAT "X(15)":U*/
  X_marking.site COLUMN-LABEL "" FORMAT "X(1)":U
  if X_marking.unit eq ? or X_marking.unit eq "" then getLevelUTDByLevelMotp( X_marking.unit-ext) else X_marking.unit @ X_marking.unit COLUMN-LABEL "Ед.изм." FORMAT "x(8)":U
/*  X_marking.unit-ext COLUMN-LABEL "Ед.изм." FORMAT "x(8)":U*/
Enable
X_marking.mark  

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 123.5 BY 11 FIT-LAST-COLUMN.

DEFINE BROWSE br-mark-item
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-mark-item d-mark _STRUCTURED
  QUERY br-mark-item NO-LOCK DISPLAY
  X_marking-line.marking-string column-label "*" format "X(1)":U
  X_marking-line.gds-code COLUMN-LABEL "Код товара" FORMAT "999999999":U
  X_marking-line.gds-name COLUMN-LABEL "Наименование" FORMAT "x(210)":U width 15
  if length(X_marking.mark) < 16 then "ШК" 
  else if ismark(X_marking.mark) then "КМ"
  else "АОД" @ typem COLUMN-LABEL "Тип!кода" FORMAT "x(3)":U
  X_marking-line.mark COLUMN-LABEL "Марка" FORMAT "x(56)":U width 33
  X_marking-line.box-qnty column-label "Кол-во" format "->>>>>>9.99":U
  if ismark(X_marking-line.mark) and WeighedProd(X_marking-line.gds-code) then string(MarkWeight(X_marking-line.mark),">>>>>9.999") else "" @ X_marking-line.weight COLUMN-LABEL "Вес" FORMAT "x(10)":U width 10
  getStatusName(X_marking.mark,X_marking-line.sts,X_marking-line.sts-utd) @ X_marking-line.stts COLUMN-LABEL "Текущий статус" FORMAT "X(50)":U width 20
/*  X_marking-line.stts-utd COLUMN-LABEL "Статус" FORMAT "X(30)":U width 20*/
/*  X_marking-line.in-code COLUMN-LABEL "ПН" FORMAT "X(15)":U */
/*  X_marking-line.out-code COLUMN-LABEL "РН" FORMAT "X(15)":U*/
  X_marking-line.unit COLUMN-LABEL "Ед.изм." FORMAT "x(8)":U
Enable
X_marking-line.mark  
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 123.5 BY 11.25 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-mark
     b-exit AT ROW 1 COL 1
     b_block AT ROW 1 COL 101.63 WIDGET-ID 290
     b_error AT ROW 1 COL 111.5 WIDGET-ID 282
     v-mark AT ROW 1.08 COL 38 COLON-ALIGNED WIDGET-ID 34
/*     v-bar-code AT ROW 1.08 COL 21 COLON-ALIGNED WIDGET-ID 292*/
     b-hist AT ROW 1.08 COL 121.88 WIDGET-ID 64
     F-text AT ROW 2.33 COL 23 NO-LABEL WIDGET-ID 224
     bt-not-sel-all AT ROW 3.75 COL 1.63 WIDGET-ID 10 NO-TAB-STOP 
     bt-not-sel-desel-all AT ROW 3.75 COL 4.63 WIDGET-ID 12 NO-TAB-STOP 
     b-mark AT ROW 3.75 COL 7.63 WIDGET-ID 4
     b-del AT ROW 3.75 COL 10.88 WIDGET-ID 66
     c-status AT ROW 3.75 COL 22 COLON-ALIGNED NO-LABEL WIDGET-ID 72
     b-change AT ROW 3.75 COL 53.5 WIDGET-ID 68
     b-look AT ROW 3.75 COL 63.5 WIDGET-ID 68
     Status_ AT ROW 3.75 COL 84 NO-LABEL WIDGET-ID 24
     br-mark AT ROW 4.75 COL 1.5 WIDGET-ID 200
/*     br-bar-code AT ROW 4.75 COL 1.5 WIDGET-ID 400*/
     bt-not-sel-all-2 AT ROW 16 COL 1.5 WIDGET-ID 80 NO-TAB-STOP 
     bt-not-sel-desel-all-2 AT ROW 16 COL 4.5 WIDGET-ID 82 NO-TAB-STOP 
     b-mark-2 AT ROW 16 COL 7.5 WIDGET-ID 78
     c-status-2 AT ROW 16 COL 21.88 COLON-ALIGNED NO-LABEL WIDGET-ID 84
     b-change-2 AT ROW 16 COL 53.38 WIDGET-ID 74
     f-qnty-unit AT ROW 16 COL 123.75 RIGHT-ALIGNED WIDGET-ID 284
     qnty-mark-2 AT ROW 16 COL 107.25 COLON-ALIGNED WIDGET-ID 288
     f-qnty-bar-code AT ROW 16 COL 123.75 RIGHT-ALIGNED WIDGET-ID 294
/*     qnty-bar-code2 AT ROW 16 COL 107.25 COLON-ALIGNED WIDGET-ID 298*/
     qnty-mark AT ROW 16 COL 117.38 COLON-ALIGNED WIDGET-ID 286
/*     qnty-bar-code AT ROW 16 COL 117.38 COLON-ALIGNED WIDGET-ID 296*/
     br-mark-item AT ROW 17 COL 1.5 WIDGET-ID 300
     SPACE(0.99) SKIP(0.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
    SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
    TITLE "Проверка кодов маркировки":L.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Temp-Tables and Buffers:
      TABLE: X_marking B "NEW SHARED" ? ub marking
      TABLE: X_marking-lines B "NEW SHARED" ? ub marking-lines
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-mark
   FRAME-NAME                                                           */
/* BROWSE-TAB br-mark Status_ d-mark */
/* BROWSE-TAB br-mark-item qnty-mark d-mark */
/*ASSIGN                                                           */
/*       br-bar-code:HIDDEN  IN FRAME d-mark                = TRUE.*/
/*       br-bar-code:COLUMN-RESIZABLE IN FRAME d-mark       = TRUE.*/
ASSIGN 
       br-mark:HIDDEN  IN FRAME d-mark                = TRUE
       br-mark:COLUMN-RESIZABLE IN FRAME d-mark       = TRUE.

ASSIGN 
       br-mark-item:HIDDEN  IN FRAME d-mark                = TRUE
       br-mark-item:COLUMN-RESIZABLE IN FRAME d-mark       = TRUE.

assign
/*      v-bar-code:hidden in frame d-mark = true .*/
      v-mark:hidden in frame d-mark = true .
      b-change-2:hidden in frame d-mark = true .
      b-mark-2:hidden in frame d-mark = true .
      b_block:hidden in frame d-mark = true .
      bt-not-sel-all-2:hidden in frame d-mark = true .
      bt-not-sel-desel-all-2:hidden in frame d-mark = true .
      c-status-2:hidden in frame d-mark = true .
      b_error:hidden in frame d-mark = true .

      
/* SETTINGS FOR BUTTON bt-not-sel-all IN FRAME d-mark
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON bt-not-sel-all-2 IN FRAME d-mark
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON bt-not-sel-desel-all IN FRAME d-mark
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON bt-not-sel-desel-all-2 IN FRAME d-mark
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-qnty-unit IN FRAME d-mark
   NO-ENABLE ALIGN-R                                                    */
/* SETTINGS FOR FILL-IN F-text IN FRAME d-mark
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN qnty-mark IN FRAME d-mark
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN qnty-mark-2 IN FRAME d-mark
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */
&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON CTRL-S OF FRAME d-mark
anywhere DO:
  /* показывает глобальный и локольный статусы марок */
  define buffer b_utd-marking-lines for ub.utd-marking-lines.
  define buffer b_marking for ub.marking.
  
  if focus:parent:type = "browse" and
     focus:name = "mark" and
     focus:screen-value <> "" then
  do:
    message 
      "Марка     :" focus:screen-value skip
      "Глобальный:" if focus:parent:name = "br-mark" then X_marking.stts else X_marking-line.stts skip
      "Локальный :" if focus:parent:name = "br-mark" then X_marking.stts-utd else X_marking-line.stts-utd
    view-as alert-box title "Статус марки".
  end.    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-change
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-change d-mark
ON CHOOSE OF b-change IN FRAME d-mark /* Поменять */
    DO:
        define variable ii         as integer no-undo .
        define variable recid_mark as integer no-undo .
        find first tt-marking-lines where tt-marking-lines.marking-string = "*" no-error .
        if available (tt-marking-lines) then 
        do:
            for each X_marking where X_marking.marking-string = "*":
                find first buf_marking exclusive-lock where buf_marking.mark = X_marking.mark no-error .
                if available (buf_marking) 
                    then 
                do: 
                    buf_marking.sts = c-status .
                    validate buf_marking.
                    X_marking.sts = buf_marking.sts .
                    X_marking.stts =  StatusTHName(X_marking.sts).
                end.
                find first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark = X_marking.mark 
                                                                  and buf_utd-marking-lines.db-num = X_marking.db-num 
                                                                  and buf_utd-marking-lines.doc-id = X_marking.doc-id no-error .
                if available (buf_utd-marking-lines) 
                    then 
                do: 
                    buf_utd-marking-lines.sts = c-status .
                    validate buf_utd-marking-lines.
                    X_marking.sts-utd = buf_utd-marking-lines.sts .
                    X_marking.stts-utd =  StatusTHName(X_marking.sts-utd).
                end.
                X_marking.marking-string = "" .
            end.

        end.  
    
        else 
        do:
            recid_mark = recid(X_marking) .
            find first X_marking where recid (X_marking) = recid_mark no-error.
            if available (X_marking) then 
            do:
        
        
                find first buf_marking exclusive-lock where buf_marking.mark = X_marking.mark no-error .
                if available (buf_marking) 
                    then 
                do: 
                    buf_marking.sts = c-status .
                    validate buf_marking.
                    X_marking.sts = buf_marking.sts .
                    X_marking.stts =  StatusTHName(X_marking.sts).
                end.
                find first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark = X_marking.mark and buf_utd-marking-lines.db-num = X_marking.db-num and
                    buf_utd-marking-lines.doc-id = X_marking.doc-id no-error .
                if available (buf_utd-marking-lines) 
                    then 
                do: 
                    buf_utd-marking-lines.sts = c-status .
                    validate buf_utd-marking-lines.
                    X_marking.sts-utd = buf_utd-marking-lines.sts .
                    X_marking.stts-utd =  StatusTHName(X_marking.sts-utd).
                end.
            end.                  
      
        end.  
        {&OPEN-BROWSERS-IN-QUERY-d-mark}
        apply "entry" to {&browse-name} in frame {&frame-name}.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-change-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-change-2 d-mark
ON CHOOSE OF b-change-2 IN FRAME d-mark /* Поменять */
    DO:
        define variable ii         as integer no-undo .
        define variable recid_mark as integer no-undo .
  
        find first tt-marking-lines where tt-marking-lines.marking-string = "*" and tt-marking-lines.doc-level > 1 no-error .
        if available (tt-marking-lines) then 
        do:
            for each X_marking-line where X_marking-line.marking-string = "*" and tt-marking-lines.doc-level > 1:
                X_marking-line.sts-utd = c-status-2 .
                X_marking-line.stts-utd =  StatusTHName(X_marking-line.sts-utd).
                X_marking-line.sts = c-status-2 .
                X_marking-line.stts =  StatusTHName(X_marking-line.sts).
                find first buf_marking exclusive-lock where buf_marking.mark = X_marking-line.mark no-error .
                if available (buf_marking) then buf_marking.sts = X_marking-line.sts .
                find first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark = X_marking-line.mark and buf_utd-marking-lines.db-num = X_marking-line.db-num and
                    buf_utd-marking-lines.doc-id = X_marking-line.doc-id no-error .
                if available (buf_utd-marking-lines) then buf_utd-marking-lines.sts = X_marking-line.sts-utd .
                X_marking-line.marking-string = "" .
            end.
            
        end.  

        else 
        do:
            recid_mark = recid(X_marking-line) .
            find first X_marking-line where recid (X_marking-line) = recid_mark no-error.
            if available (X_marking-line) then 
            do:
                X_marking-line.sts-utd = c-status-2 .
                X_marking-line.stts-utd =  StatusTHName(X_marking-line.sts-utd).
                X_marking-line.sts = c-status-2 .
                X_marking-line.stts =  StatusTHName(X_marking-line.sts).
                find first buf_marking exclusive-lock where buf_marking.mark = X_marking-line.mark no-error .
                if available (buf_marking) then buf_marking.sts = X_marking-line.sts .
                find first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark = X_marking-line.mark and buf_utd-marking-lines.db-num = X_marking-line.db-num and
                    buf_utd-marking-lines.doc-id = X_marking-line.doc-id no-error .
                if available (buf_utd-marking-lines) then buf_utd-marking-lines.sts = X_marking-line.sts-utd .
            end.
        end. 
        {&OPEN-BROWSERS-IN-QUERY-d-mark}
        apply "entry" to {&browse-name} in frame {&frame-name}.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del d-mark
ON CHOOSE OF b-del IN FRAME d-mark /* Удалить */
    DO:
        define variable ii         as integer no-undo .
        define variable recid_mark as integer no-undo .

        if v-rid-list <> "" then 
        do:
            do ii = 1 to num-entries (v-rid-list):
                recid_mark = integer(entry(ii,v-rid-list)) .
                for first X_marking where recid (X_marking) = recid_mark:
                    for first buf_marking exclusive-lock where buf_marking.mark = X_marking.mark:
                        for first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark = X_marking.mark:
                            for first buf_utd-lines exclusive-lock where buf_utd-lines.LineNum = buf_utd-marking-lines.LineNum and buf_utd-lines.db-num = buf_utd-marking-lines.db-num
                                and buf_utd-lines.doc-id = buf_utd-marking-lines.doc-id:
                                buf_utd-lines.Quantity = buf_utd-lines.Quantity - buf_marking.box-qnty .
                                delete X_marking.
                                /*                delete buf_marking .*/
                                delete buf_utd-marking-lines .
                                v-qnty-mark = v-qnty-mark - buf_marking.box-qnty .
                                if buf_utd-lines.Quantity = 0 then 
                                do:
                                    delete buf_utd-lines .
                                end.  
                            end.
                        end.
                    end.
                end.    
            end.  
        end.  
        else 
        do:
            recid_mark = recid(X_marking) .
            for first X_marking where recid (X_marking) = recid_mark:
                for first buf_marking exclusive-lock where buf_marking.mark = X_marking.mark:
                    for first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark = X_marking.mark:
                        for first buf_utd-lines exclusive-lock where buf_utd-lines.LineNum = buf_utd-marking-lines.LineNum and buf_utd-lines.db-num = buf_utd-marking-lines.db-num
                            and buf_utd-lines.doc-id = buf_utd-marking-lines.doc-id:
                            buf_utd-lines.Quantity = buf_utd-lines.Quantity - buf_marking.box-qnty .
                            delete X_marking.
                            /*              delete buf_marking .*/
                            delete buf_utd-marking-lines .
                            v-qnty-mark = v-qnty-mark - buf_marking.box-qnty .
                            if buf_utd-lines.Quantity = 0 then 
                            do:
                                delete buf_utd-lines .
                            end.  
                        end.
                    end.
                end.
            end.                  
        end. 
  
        {&OPEN-BROWSERS-IN-QUERY-d-mark}
        apply "entry" to {&browse-name} in frame {&frame-name}.
        f-qnty-unit = v-qnty-mark .
        f-qnty-bar-code = v-qnty-mark .
        display f-qnty-unit with frame {&frame-name} .
        display f-qnty-bar-code with frame {&frame-name} .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit d-mark
ON choose OF b-exit IN FRAME d-mark /* Выход  */
DO:
    define buffer buf_marking for ub.marking .
    define variable quest-ok as logical no-undo .
    define variable quest-scan as logical no-undo .
    define buffer buf_utd for ub.utd .
    
    if  p-type = 6 then 
    do:
      find first buf_utd no-lock where buf_utd.db-num = X_marking.db-num and buf_utd.doc-id = X_marking.doc-id no-error .
      if X_marking.box-qnty = qnty-mark-2 then 
      do:
        find first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark = X_marking.mark and buf_utd-marking-lines.db-num = X_marking.db-num and
          buf_utd-marking-lines.doc-id = X_marking.doc-id no-error .
        if available (buf_utd-marking-lines) then 
        do:
          buf_utd-marking-lines.sts = Marking:Checked_:KeyIntDB .
          buf_utd-marking-lines.doc-level = 1 .
          X_marking.sts-utd = Marking:Checked_:KeyIntDB .
          X_marking.stts-utd = StatusTHName(X_marking.sts-utd) .
        end.  
        for first buf_marking exclusive-lock where buf_marking.mark = buf_utd-marking-lines.mark :
          buf_marking.sts = Marking:Ungrouped:KeyIntDB .
          X_marking.sts = Marking:Ungrouped:KeyIntDB .
          X_marking.stts = StatusTHName(X_marking.sts) .
        end.
        run save-mark .
            
      end .  
      else 
      do:
        message "Марки просканированы не полностью." skip
          "Должны быть просканированы все марки." skip
          "Продолжить сканирование?" skip
          "Да – возврат к сканированию" skip
          "Нет – сброс введенной информации" 
          view-as alert-box question buttons yes-no update quest-ok.
        if not quest-ok then 
        do:
            for each X_marking-line exclusive-lock where X_marking-line.doc-level > 1:
              find first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark = X_marking-line.mark and buf_utd-marking-lines.db-num = X_marking-line.db-num and
              buf_utd-marking-lines.doc-id = X_marking-line.doc-id no-error .
              if available (buf_utd-marking-lines) then do:
                 if available (buf_utd) and buf_utd.EdocType = objSrv:Env:Utd:EDocType:Introduce:KeyIntDB
                    then 
                 do:
                    buf_utd-marking-lines.sts = Marking:DeliveryControl:KeyIntDB .
                    X_marking-line.sts-utd = Marking:DeliveryControl:KeyIntDB .
                    X_marking-line.stts-utd = StatusTHName(X_marking-line.sts-utd) .
                 end .
                 else 
                 do:
                    buf_utd-marking-lines.sts = Marking:PendingVerification:KeyIntDB .
                    X_marking-line.sts-utd = Marking:PendingVerification:KeyIntDB .
                    X_marking-line.stts-utd = StatusTHName(X_marking-line.sts-utd) .
                 end.                  
              end.
              if X_marking-line.GrayZone = yes then 
              do:
                delete X_marking-line .
              end.  
            end.  

        end.
        else 
        do:
          return no-apply .
        end.  
      end. 
    end.
  
   else if p-type = 7 then 
    do:
      define variable vQnty as integer no-undo.
      
      find first buf_utd no-lock where buf_utd.db-num = X_marking.db-num and buf_utd.doc-id = X_marking.doc-id no-error .
      for each tt-gray-marking-lines where tt-gray-marking-lines.mark-parent eq X_marking.mark
                                       and   tt-gray-marking-lines.sts-utd = Marking:Checked_:KeyIntDB 
                                          or tt-gray-marking-lines.sts-utd = Marking:MarkError:KeyIntDB
      no-lock: 
         vQnty = vqnty + tt-gray-marking-lines.box-qnty.
      end.
      
      if X_marking.box-qnty ne vQnty then 
      do:
         message "Марки просканированы не полностью." skip
          "Не просканированные марки будут не приняты" skip
          "Продолжить сканирование?" skip
          "Да – возврат к сканированию" skip
          "Нет" 
          view-as alert-box question buttons yes-no update quest-ok.
        if not quest-ok then 
        do:
           run save-mark .
        end.    
      end .  
      else 
      do:
         return no-apply .
      end.
    end.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist d-mark
ON choose OF b-hist IN FRAME d-mark /* История */
    DO:
        if available (X_marking) then 
        do:
            run str/mark_hist.w(input parparentproc,
                input X_marking.mark,
                input p-mode).
        end.
        else 
        do:
            if available (X_marking-line) then 
            do:
                run str/mark_hist.w(input parparentproc,
                    input X_marking-line.mark,
                    input p-mode).
            end.  
            else 
            do:
                message "Не выбрана марка"
                    view-as alert-box.
            end.  
        end.   
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark d-mark
ON CHOOSE OF b-mark IN FRAME d-mark /* * */
    DO:
        define variable loc#log     as logical no-undo .
        define variable row-marking as rowid   no-undo .
        if available X_marking 
           and X_marking.isMark
        then 
        do:
            if X_marking.marking-string = "*" then X_marking.marking-string = "" .
            else X_marking.marking-string = "*" . 
            /*      { gbl/markstrn.i X_marking v-rid-list }*/
            row-marking = rowid(X_marking).
            loc#log = br-mark:refresh() .
            reposition br-mark to rowid row-marking.
      
            loc#log = br-mark:refresh() .

            if last-event:function <> "MOUSE-SELECT-DBLCLICK" then 
            do:
                loc#log = br-mark:select-next-row () .
                apply "VALUE-CHANGED" to br-mark in frame {&frame-name} .
            end.
            apply "entry" to br-mark in frame {&frame-name}.
         end.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark-2 d-mark
ON CHOOSE OF b-mark-2 IN FRAME d-mark /* * */
    DO:
        define variable loc#log     as logical no-undo .
        define variable row-marking as rowid   no-undo .
        apply "entry" to {&browse-name} in frame {&frame-name}.
        if     available X_marking-line 
           and X_marking.isMark
        then 
        do:
            if X_marking-line.marking-string = "*" then X_marking-line.marking-string = "" .
            else X_marking-line.marking-string = "*" .
            row-marking = rowid(X_marking-line).
            /*      { gbl/markstrn.i X_marking-line v-rid-list2 }*/
            loc#log = br-mark-item:refresh() .
            reposition br-mark-item to rowid row-marking.  
            if last-event:function <> "MOUSE-SELECT-DBLCLICK" then 
            do:
                loc#log = br-mark-item:select-next-row () .
                apply "VALUE-CHANGED" to br-mark-item in frame {&frame-name}.
            end.
        end.
        apply "entry" to br-mark-item in frame {&frame-name}.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/*&Scoped-define BROWSE-NAME br-bar-code                                                    */
/*&Scoped-define SELF-NAME br-bar-code                                                      */
/*&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-bar-code d-mark                              */
/*ON ROW-DISPLAY OF br-bar-code IN FRAME d-mark                                             */
/*DO:                                                                                       */
/*        if p-type = 1 or p-type = 6 then                                                  */
/*        do:                                                                               */
/*            case X_marking.sts-utd:                                                       */
/*                when Marking:Checked_:KeyIntDB then                                       */
/*                    do:                                                                   */
/*                        X_marking.gds-code:fGCOLOR in browse br-bar-code = CYAN_COLOR.    */
/*                        X_marking.gds-name:fGCOLOR in browse br-bar-code = CYAN_COLOR.    */
/*                        X_marking.mark:fGCOLOR in browse br-bar-code = CYAN_COLOR.        */
/*                        X_marking.box-qnty:fGCOLOR in browse br-bar-code = CYAN_COLOR.    */
/*                        X_marking.weight:fGCOLOR in browse br-bar-code = CYAN_COLOR.      */
/*/*                        X_marking.unit:fGCOLOR in browse br-bar-code = CYAN_COLOR.    */*/
/*/*                        X_marking.stts:fGCOLOR in browse br-bar-code = CYAN_COLOR.    */*/
/*/*                        X_marking.stts-utd:fGCOLOR in browse br-bar-code = CYAN_COLOR.*/*/
/*/*                        X_marking.in-code:fGCOLOR in browse br-bar-code = CYAN_COLOR. */*/
/*/*                        X_marking.out-code:fGCOLOR in browse br-bar-code = CYAN_COLOR.*/*/
/*                    end.                                                                  */
/*                when Marking:MarkError:KeyIntDB then                                      */
/*                    do:                                                                   */
/*                        X_marking.gds-code:fGCOLOR in browse br-bar-code = red_COLOR.     */
/*                        X_marking.gds-name:fGCOLOR in browse br-bar-code = red_COLOR.     */
/*                        X_marking.mark:fGCOLOR in browse br-bar-code = red_COLOR.         */
/*                        X_marking.box-qnty:fGCOLOR in browse br-bar-code = red_COLOR.     */
/*                        X_marking.weigth:fGCOLOR in browse br-bar-code = red_COLOR.       */
/*/*                        X_marking.unit:fGCOLOR in browse br-bar-code = red_COLOR.    */ */
/*/*                        X_marking.stts:fGCOLOR in browse br-bar-code = red_COLOR.    */ */
/*/*                        X_marking.stts-utd:fGCOLOR in browse br-bar-code = red_COLOR.*/ */
/*/*                        X_marking.in-code:fGCOLOR in browse br-bar-code = red_COLOR. */ */
/*/*                        X_marking.out-code:fGCOLOR in browse br-bar-code = red_COLOR.*/ */
/*                    end.                                                                  */
/*            end case.                                                                     */
/*            if X_marking.sts = Marking:MarkError:KeyIntDB then                            */
/*            do:                                                                           */
/*                X_marking.gds-code:fGCOLOR in browse br-bar-code = red_COLOR.             */
/*                X_marking.gds-name:fGCOLOR in browse br-bar-code = red_COLOR.             */
/*                X_marking.mark:fGCOLOR in browse br-bar-code = red_COLOR.                 */
/*                X_marking.box-qnty:fGCOLOR in browse br-bar-code = red_COLOR.             */
/*                X_marking.weight:fGCOLOR in browse br-bar-code = red_COLOR.               */
/*/*                X_marking.unit:fGCOLOR in browse br-bar-code = red_COLOR.    */         */
/*/*                X_marking.stts:fGCOLOR in browse br-bar-code = red_COLOR.    */         */
/*/*                X_marking.stts-utd:fGCOLOR in browse br-bar-code = red_COLOR.*/         */
/*/*                X_marking.in-code:fGCOLOR in browse br-bar-code = red_COLOR. */         */
/*/*                X_marking.out-code:fGCOLOR in browse br-bar-code = red_COLOR.*/         */
/*            end.                                                                          */
/*        end.                                                                              */
/*        else                                                                              */
/*        do:                                                                               */
/*            case X_marking.sts:                                                           */
/*                when Marking:MarkError:KeyIntDB then                                      */
/*                    do:                                                                   */
/*                        X_marking.gds-code:fGCOLOR in browse br-bar-code = red_COLOR.     */
/*                        X_marking.gds-name:fGCOLOR in browse br-bar-code = red_COLOR.     */
/*                        X_marking.mark:fGCOLOR in browse br-bar-code = red_COLOR.         */
/*                        X_marking.box-qnty:fGCOLOR in browse br-bar-code = red_COLOR.     */
/*                        X_marking.weight:fGCOLOR in browse br-bar-code = red_COLOR.       */
/*/*                        X_marking.unit:fGCOLOR in browse br-bar-code = red_COLOR.    */ */
/*/*                        X_marking.stts:fGCOLOR in browse br-bar-code = red_COLOR.    */ */
/*/*                        X_marking.stts-utd:fGCOLOR in browse br-bar-code = red_COLOR.*/ */
/*/*                        X_marking.in-code:fGCOLOR in browse br-bar-code = red_COLOR. */ */
/*/*                        X_marking.out-code:fGCOLOR in browse br-bar-code = red_COLOR.*/ */
/*                    end.                                                                  */
/*            end case.                                                                     */
/*        end.                                                                              */
/*                                                                                          */
/*    END .                                                                                 */
/*                                                                                          */
/*/* _UIB-CODE-BLOCK-END */                                                                 */
/*&ANALYZE-RESUME                                                                           */


/*&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-bar-code d-mark */
/*ON value-changed OF br-bar-code IN FRAME d-mark              */
/*DO:                                                          */
/*        br-bar-code:refresh() no-error .                     */
/*        if p-type = 1 then                                   */
/*        do:                                                  */
/*            if X_marking.sts = Marking:GrayZone:KeyIntDB then*/
/*            do:                                              */
/*                enable                                       */
/*                    b_block                                  */
/*                    with frame {&frame-name} .               */
/*            end.                                             */
/*            else                                             */
/*            do:                                              */
/*                hide b_block in frame {&frame-name} .        */
/*            end.                                             */
/*        end.                                                 */
/*                                                             */
/*    END.                                                     */
/*                                                             */
/*/* _UIB-CODE-BLOCK-END */                                    */
/*&ANALYZE-RESUME                                              */

&Scoped-define SELF-NAME br-mark-item
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-mark-item d-mark
ON value-changed OF br-mark-item IN FRAME d-mark /* Номер документа */
    DO:

        br-mark-item:refresh () no-error .
    
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-mark
&Scoped-define SELF-NAME br-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-mark d-mark
ON ROW-DISPLAY OF br-mark IN FRAME d-mark
    DO:
        if p-type = 1 or p-type = 6 or p-type = 7 then 
        do:
            case X_marking.sts-utd:
                when Marking:Checked_:KeyIntDB then
                    do:
                        X_marking.gds-code:fGCOLOR in browse br-mark = CYAN_COLOR.
                        X_marking.gds-name:fGCOLOR in browse br-mark = CYAN_COLOR.
                        X_marking.mark:fGCOLOR in browse br-mark = CYAN_COLOR.
                        X_marking.box-qnty:fGCOLOR in browse br-mark = CYAN_COLOR.
                        X_marking.weight:fGCOLOR in browse br-mark = CYAN_COLOR.
                        X_marking.unit:fGCOLOR in browse br-mark = CYAN_COLOR.
                        X_marking.stts:fGCOLOR in browse br-mark = CYAN_COLOR.
/*                        X_marking.stts-utd:fGCOLOR in browse br-mark = CYAN_COLOR.*/
                        typem:fGCOLOR in browse br-mark = CYAN_COLOR.
/*                        X_marking.in-code:fGCOLOR in browse br-mark = CYAN_COLOR. */
/*                        X_marking.out-code:fGCOLOR in browse br-mark = CYAN_COLOR.*/
                    end.
                /*        when Marking:PendingVerification:KeyIntDB or                    */
                /*        when Marking:DeliveryControl:KeyIntDB then                      */
                /*          do:                                                           */
                /*            X_marking.gds-code:BGCOLOR in browse br-mark = YELLOW_COLOR.*/
                /*            X_marking.gds-name:BGCOLOR in browse br-mark = YELLOW_COLOR.*/
                /*            X_marking.mark:BGCOLOR in browse br-mark = YELLOW_COLOR.    */
                /*            X_marking.box-qnty:BGCOLOR in browse br-mark = YELLOW_COLOR.*/
                /*            X_marking.weight:BGCOLOR in browse br-mark = YELLOW_COLOR.  */
                /*            X_marking.unit:BGCOLOR in browse br-mark = YELLOW_COLOR.    */
                /*            X_marking.stts:BGCOLOR in browse br-mark = YELLOW_COLOR.    */
                /*            X_marking.stts-utd:BGCOLOR in browse br-mark = YELLOW_COLOR.*/
                /*            X_marking.in-code:BGCOLOR in browse br-mark = YELLOW_COLOR. */
                /*            X_marking.out-code:BGCOLOR in browse br-mark = YELLOW_COLOR.*/
                /*          end.                                                          */
                when Marking:MarkError:KeyIntDB then
                    do:
                        X_marking.gds-code:fGCOLOR in browse br-mark = red_COLOR.
                        X_marking.gds-name:fGCOLOR in browse br-mark = red_COLOR.
                        X_marking.mark:fGCOLOR in browse br-mark = red_COLOR.
                        X_marking.box-qnty:fGCOLOR in browse br-mark = red_COLOR.
                        X_marking.weight:fGCOLOR in browse br-mark = red_COLOR.
                        X_marking.unit:fGCOLOR in browse br-mark = red_COLOR.
                        X_marking.stts:fGCOLOR in browse br-mark = red_COLOR.
/*                        X_marking.stts-utd:fGCOLOR in browse br-mark = red_COLOR.*/
                        typem:fGCOLOR in browse br-mark = red_COLOR.
/*                        X_marking.in-code:fGCOLOR in browse br-mark = red_COLOR. */
/*                        X_marking.out-code:fGCOLOR in browse br-mark = red_COLOR.*/
                    end.    
            end case.
            if X_marking.sts = Marking:MarkError:KeyIntDB then 
            do:
                X_marking.gds-code:fGCOLOR in browse br-mark = red_COLOR.
                X_marking.gds-name:fGCOLOR in browse br-mark = red_COLOR.
                X_marking.mark:fGCOLOR in browse br-mark = red_COLOR.
                X_marking.box-qnty:fGCOLOR in browse br-mark = red_COLOR.
                X_marking.weight:fGCOLOR in browse br-mark = red_COLOR.
                X_marking.unit:fGCOLOR in browse br-mark = red_COLOR.
                X_marking.stts:fGCOLOR in browse br-mark = red_COLOR.
/*                X_marking.stts-utd:fGCOLOR in browse br-mark = red_COLOR.*/
                typem:fGCOLOR in browse br-mark = red_COLOR.
/*                X_marking.in-code:fGCOLOR in browse br-mark = red_COLOR. */
/*                X_marking.out-code:fGCOLOR in browse br-mark = red_COLOR.*/
            end.       
        end.
        else 
        do:
            case X_marking.sts:
                when Marking:MarkError:KeyIntDB then
                    do:
                        X_marking.gds-code:fGCOLOR in browse br-mark = red_COLOR.
                        X_marking.gds-name:fGCOLOR in browse br-mark = red_COLOR.
                        X_marking.mark:fGCOLOR in browse br-mark = red_COLOR.
                        X_marking.box-qnty:fGCOLOR in browse br-mark = red_COLOR.
                        X_marking.weight:fGCOLOR in browse br-mark = red_COLOR.
                        X_marking.unit:fGCOLOR in browse br-mark = red_COLOR.
                        X_marking.stts:fGCOLOR in browse br-mark = red_COLOR.
/*                        X_marking.stts-utd:fGCOLOR in browse br-mark = red_COLOR.*/
                        typem:fGCOLOR in browse br-mark = red_COLOR.
/*                        X_marking.in-code:fGCOLOR in browse br-mark = red_COLOR. */
/*                        X_marking.out-code:fGCOLOR in browse br-mark = red_COLOR.*/
                    end.  
            end case.
        end.
   
    END .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-mark d-mark
ON value-changed OF br-mark IN FRAME d-mark
DO:
        br-mark:refresh() no-error .
        if p-type = 1 then 
        do:
            if X_marking.sts = Marking:GrayZone:KeyIntDB then 
            do:
                enable
                    b_block
                    with frame {&frame-name} .
            end.
            else 
            do:
                disable b_block with frame {&frame-name} .
            end.   
        end.
        vMarkBrow2 = if not available X_marking then ? else X_marking.mark.
        {&OPEN-QUERY-br-mark-item} .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-mark-item
&Scoped-define SELF-NAME br-mark-item
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-mark-item d-mark
ON ROW-DISPLAY OF br-mark-item IN FRAME d-mark
    DO:
        if p-type = 1 or p-type = 6 or p-type = 7  then 
        do:
            case X_marking-line.sts-utd:
                when Marking:Checked_:KeyIntDB then
                    do:
                        X_marking-line.gds-code:fGCOLOR in browse br-mark-item = CYAN_COLOR.
                        X_marking-line.gds-name:fGCOLOR in browse br-mark-item = CYAN_COLOR.
                        X_marking-line.mark:fGCOLOR in browse br-mark-item = CYAN_COLOR.
                        X_marking-line.box-qnty:fGCOLOR in browse br-mark-item = CYAN_COLOR.
                        X_marking-line.weight:fGCOLOR in browse br-mark-item = CYAN_COLOR.
                        X_marking-line.unit:fGCOLOR in browse br-mark-item = CYAN_COLOR.
                        X_marking-line.stts:fGCOLOR in browse br-mark-item = CYAN_COLOR.
/*                        X_marking-line.stts-utd:fGCOLOR in browse br-mark-item = CYAN_COLOR.*/
                        typem:fGCOLOR in browse br-mark-item = CYAN_COLOR.
/*                        X_marking-line.in-code:fGCOLOR in browse br-mark-item = CYAN_COLOR. */
/*                        X_marking-line.out-code:fGCOLOR in browse br-mark-item = CYAN_COLOR.*/
                    end.
                /*        when Marking:PendingVerification:KeyIntDB or                              */
                /*        when Marking:DeliveryControl:KeyIntDB then                                */
                /*          do:                                                                     */
                /*            X_marking-line.gds-code:BGCOLOR in browse br-mark-item = YELLOW_COLOR.*/
                /*            X_marking-line.gds-name:BGCOLOR in browse br-mark-item = YELLOW_COLOR.*/
                /*            X_marking-line.mark:BGCOLOR in browse br-mark-item = YELLOW_COLOR.    */
                /*            X_marking-line.box-qnty:BGCOLOR in browse br-mark-item = YELLOW_COLOR.*/
                /*            X_marking-line.weight:BGCOLOR in browse br-mark-item = YELLOW_COLOR.  */
                /*            X_marking-line.unit:BGCOLOR in browse br-mark-item = YELLOW_COLOR.    */
                /*            X_marking-line.stts:BGCOLOR in browse br-mark-item = YELLOW_COLOR.    */
                /*            X_marking-line.stts-utd:BGCOLOR in browse br-mark-item = YELLOW_COLOR.*/
                /*            X_marking-line.in-code:BGCOLOR in browse br-mark-item = YELLOW_COLOR. */
                /*            X_marking-line.out-code:BGCOLOR in browse br-mark-item = YELLOW_COLOR.*/
                /*          end.                                                                    */
                when Marking:MarkError:KeyIntDB then 
                    do:
                        X_marking-line.gds-code:fGCOLOR in browse br-mark-item = red_COLOR.
                        X_marking-line.gds-name:fGCOLOR in browse br-mark-item = red_COLOR.
                        X_marking-line.mark:fGCOLOR in browse br-mark-item = red_COLOR.
                        X_marking-line.box-qnty:fGCOLOR in browse br-mark-item = red_COLOR.
                        X_marking-line.weight:fGCOLOR in browse br-mark-item = red_COLOR.
                        X_marking-line.unit:fGCOLOR in browse br-mark-item = red_COLOR.
                        X_marking-line.stts:fGCOLOR in browse br-mark-item = red_COLOR.
/*                        X_marking-line.stts-utd:fGCOLOR in browse br-mark-item = red_COLOR.*/
                        typem:fGCOLOR in browse br-mark-item = red_COLOR.
/*                        X_marking-line.in-code:fGCOLOR in browse br-mark-item = red_COLOR. */
/*                        X_marking-line.out-code:fGCOLOR in browse br-mark-item = red_COLOR.*/
                    end. 
            end case.
            if X_marking-line.sts = Marking:MarkError:KeyIntDB then 
            do:
                X_marking-line.gds-code:fGCOLOR in browse br-mark-item = red_COLOR.
                X_marking-line.gds-name:fGCOLOR in browse br-mark-item = red_COLOR.
                X_marking-line.mark:fGCOLOR in browse br-mark-item = red_COLOR.
                X_marking-line.box-qnty:fGCOLOR in browse br-mark-item = red_COLOR.
                X_marking-line.weight:fGCOLOR in browse br-mark-item = red_COLOR.
                X_marking-line.unit:fGCOLOR in browse br-mark-item = red_COLOR.
                X_marking-line.stts:fGCOLOR in browse br-mark-item = red_COLOR.
/*                X_marking-line.stts-utd:fGCOLOR in browse br-mark-item = red_COLOR.*/
                typem:fGCOLOR in browse br-mark-item = red_COLOR.
/*                X_marking-line.in-code:fGCOLOR in browse br-mark-item = red_COLOR. */
/*                X_marking-line.out-code:fGCOLOR in browse br-mark-item = red_COLOR.*/
            end. 

        end.
        else 
        do:
            case X_marking-line.sts:
                when Marking:MarkError:KeyIntDB then 
                    do:
                        X_marking-line.gds-code:fGCOLOR in browse br-mark-item = red_COLOR.
                        X_marking-line.gds-name:fGCOLOR in browse br-mark-item = red_COLOR.
                        X_marking-line.mark:fGCOLOR in browse br-mark-item = red_COLOR.
                        X_marking-line.box-qnty:fGCOLOR in browse br-mark-item = red_COLOR.
                        X_marking-line.weight:fGCOLOR in browse br-mark-item = red_COLOR.
                        X_marking-line.unit:fGCOLOR in browse br-mark-item = red_COLOR.
                        X_marking-line.stts:fGCOLOR in browse br-mark-item = red_COLOR.
/*                        X_marking-line.stts-utd:fGCOLOR in browse br-mark-item = red_COLOR.*/
                        typem:fGCOLOR in browse br-mark-item = red_COLOR.
/*                        X_marking-line.in-code:fGCOLOR in browse br-mark-item = red_COLOR. */
/*                        X_marking-line.out-code:fGCOLOR in browse br-mark-item = red_COLOR.*/
                    end. 
            end case.
        end.  
    
    
    END .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&Scoped-define SELF-NAME bt-not-sel-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-not-sel-all d-mark
ON CHOOSE OF bt-not-sel-all IN FRAME d-mark /* + */
    DO:
        define variable loc#log as logical no-undo .

        if available X_marking 
           and X_marking.isMark
        then 
        do:
            v-rid-list = "" .
            for each X_marking where X_marking.doc-level = vLevel:
                X_marking.marking-string = "*" .
                /*        { gbl/markstrn.i X_marking v-rid-list }*/
/*                if not upd_mark then loc#log = br-bar-code:refresh() no-error.*/
/*                else                                                          */
                loc#log = br-mark:refresh() no-error.
            end.
        end.
/*        if not upd_mark then apply "entry" to br-bar-code in frame {&frame-name}.*/
/*        else                                                                     */
        apply "entry" to br-mark in frame {&frame-name}.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-not-sel-all-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-not-sel-all-2 d-mark
ON CHOOSE OF bt-not-sel-all-2 IN FRAME d-mark /* + */
    DO:
        define variable loc#log as logical no-undo .
        if available (X_marking) then 
        do:
            v-rid-list2 = "" .
            for each X_marking-line where X_marking.mark begins X_marking-line.mark-parent and X_marking-line.doc-level > 1:
                X_marking-line.marking-string = "*" .
                /*        { gbl/markstrn.i X_marking-line v-rid-list2 }*/
                loc#log = br-mark-item:refresh() no-error.
            end.
        end.
        apply "entry" to br-mark-item in frame {&frame-name}.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-not-sel-desel-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-not-sel-desel-all d-mark
ON CHOOSE OF bt-not-sel-desel-all IN FRAME d-mark /* - */
    DO:
        define variable loc#log as logical no-undo .
        v-rid-list = "" .
        For each X_marking where X_marking.marking-string = "*":
            X_marking.marking-string = "" .
        end.    
/*        if not upd_mark then loc#log = br-bar-code:refresh() no-error.*/
/*        else                                                          */
        loc#log = br-mark:refresh() no-error.
        
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-not-sel-desel-all-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-not-sel-desel-all-2 d-mark
ON CHOOSE OF bt-not-sel-desel-all-2 IN FRAME d-mark /* - */
    DO:
        define variable loc#log as logical no-undo .
        v-rid-list2 = "" .
        For each X_marking-line where X_marking-line.marking-string = "*":
            X_marking-line.marking-string = "" .
        end.
        loc#log = br-mark-item:refresh() .

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b_block
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b_block d-mark
ON CHOOSE OF b_block IN FRAME d-mark /* Проверка */
    DO:
        /*вызов серой зоны*/
        define buffer gray_marking                for ub.marking .
        define buffer gray_unit-marking           for ub.marking .
        define buffer gray_utd-marking-lines      for ub.utd-marking-lines .
        define buffer gray_unit_utd-marking-lines for ub.utd-marking-lines .
    
        for first gray_utd-marking-lines no-lock where gray_utd-marking-lines.db-num = X_marking.db-num and 
            gray_utd-marking-lines.doc-id = X_marking.doc-id and 
            gray_utd-marking-lines.LineNum = X_marking.LineNum and 
            gray_utd-marking-lines.mark = X_marking.mark:
            for first gray_marking no-lock where gray_marking.mark = X_marking.mark :
                create tt-gray-marking-lines .
                assign
                    tt-gray-marking-lines.gds-name    = GdsName(gray_utd-marking-lines.gds-code)
                    tt-gray-marking-lines.stts-utd    = StatusTHName(gray_utd-marking-lines.sts)
                    tt-gray-marking-lines.stts        = StatusTHName(gray_marking.sts)
                    tt-gray-marking-lines.mark        = gray_marking.mark
                    tt-gray-marking-lines.mark-parent = gray_marking.mark-parent
                    tt-gray-marking-lines.gds-code    = gray_utd-marking-lines.gds-code
                    tt-gray-marking-lines.sts         = gray_marking.sts
                    tt-gray-marking-lines.sts-utd     = gray_utd-marking-lines.sts
                    tt-gray-marking-lines.unit        = gray_marking.unit
                    tt-gray-marking-lines.box-qnty    = gray_marking.box-qnty
                    tt-gray-marking-lines.LineNum     = gray_utd-marking-lines.LineNum
                    tt-gray-marking-lines.db-num      = gray_utd-marking-lines.db-num
                    tt-gray-marking-lines.doc-id      = gray_utd-marking-lines.doc-id
                    tt-gray-marking-lines.doc-level   = gray_utd-marking-lines.doc-level
                    .
            end.
            for each gray_unit-marking no-lock where gray_unit-marking.mark-parent = gray_utd-marking-lines.mark:
                for first gray_unit_utd-marking-lines no-lock where gray_unit_utd-marking-lines.db-num = X_marking.db-num and gray_unit_utd-marking-lines.doc-id = X_marking.doc-id
                    and gray_unit_utd-marking-lines.LineNum = X_marking.LineNum and gray_unit_utd-marking-lines.mark = gray_unit-marking.mark:
                    create tt-gray-marking-lines .
                    assign
                        tt-gray-marking-lines.gds-name    = GdsName(gray_unit_utd-marking-lines.gds-code)
                        tt-gray-marking-lines.stts-utd    = StatusTHName(gray_unit_utd-marking-lines.sts)
                        tt-gray-marking-lines.stts        = StatusTHName(gray_unit-marking.sts)
                        tt-gray-marking-lines.mark        = gray_unit-marking.mark
                        tt-gray-marking-lines.mark-parent = gray_unit-marking.mark-parent
                        tt-gray-marking-lines.gds-code    = gray_unit_utd-marking-lines.gds-code
                        tt-gray-marking-lines.sts         = gray_unit-marking.sts
                        tt-gray-marking-lines.sts-utd     = gray_unit_utd-marking-lines.sts
                        tt-gray-marking-lines.unit        = gray_unit-marking.unit
                        tt-gray-marking-lines.unit-ext    = gray_unit-marking.unit-ext
                        tt-gray-marking-lines.box-qnty    = gray_unit-marking.box-qnty
                        tt-gray-marking-lines.LineNum     = gray_unit_utd-marking-lines.LineNum
                        tt-gray-marking-lines.db-num      = gray_unit_utd-marking-lines.db-num
                        tt-gray-marking-lines.doc-id      = gray_unit_utd-marking-lines.doc-id
                        tt-gray-marking-lines.doc-level   = gray_unit_utd-marking-lines.doc-level
                        .
                end.
            end.
        end.
        run str/mark_browse.w (input parparentproc,
            input-output table tt-gray-marking-lines by-reference,
            input p-mode,
            input "Марки по товару " + string(X_marking.gds-code) + " " + GdsName(X_marking.gds-code) + " со статусом: " + StatusTHName(Marking:GrayZone:KeyIntDB),
            input 6,
            input "" /*тип продукции*/
            ) no-error .
        for each tt-gray-marking-lines no-lock:
            find first tt-marking-lines exclusive-lock where tt-marking-lines.mark = tt-gray-marking-lines.mark no-error .
            if not available (tt-marking-lines) then 
            do:
                create tt-marking-lines .
                buffer-copy tt-gray-marking-lines to tt-marking-lines .
                v-qnty-mark = v-qnty-mark + 1 .
                f-qnty-unit = v-qnty-mark .
            end.  
            else 
            do:
                assign
                    tt-marking-lines.sts      = tt-gray-marking-lines.sts
                    tt-marking-lines.stts     = tt-gray-marking-lines.stts
                    tt-marking-lines.sts-utd  = tt-gray-marking-lines.sts-utd
                    tt-marking-lines.stts-utd = tt-gray-marking-lines.stts-utd
                    .
            end.  
        end.   
        recid_mark = recid (X_marking) .
        empty temp-table tt-gray-marking-lines .
        browse br-mark :refresh().
        reposition br-mark to recid recid_mark no-error .
        browse br-mark-item:refresh () no-error .
        {&OPEN-BROWSERS-IN-QUERY-d-mark}
        apply "value-changed" to br-mark in frame {&frame-name}.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b_error
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b_error d-mark
ON CHOOSE OF b_error IN FRAME d-mark /* Ошибки */
    DO:
        /*Ошибки по всем маркам документа*/
        define variable v-ok as logical no-undo .
    
        run ref/dialog-error.w (input X_marking.db-num, input X_marking.doc-id, input "utd-marking-lines") .
        if  error-status:error then 
        do: 
            return return-value .
        end.
        run enable_UI in this-procedure .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-look
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-look d-mark
ON CHOOSE OF b-look IN FRAME d-mark /* Ошибки */
    DO:
        /*Ошибки по всем маркам документа*/
        define variable v-ok as logical no-undo .
        define buffer buf-mark for tt-marking-lines.
        find first buf-mark where buf-mark.mark-parent eq X_marking.mark no-lock no-error.
        if available buf-mark
        then do:
           run str/mark_browse.w (input parparentproc,
               input-output table tt-marking-lines by-reference,
               input p-mode,
               input substitute ("&1 по марке &2 уровень &3",p-doc, X_marking.mark ,X_marking.doc-level + 1) ,
               input p-type,
               input X_marking.mark /* марка родитель */
               ) no-error .
           if  error-status:error then 
           do: 
               return return-value .
           end.
           run enable_UI in this-procedure .
       end.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-status
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-status d-mark
ON VALUE-CHANGED OF c-status IN FRAME d-mark
    DO:
        assign c-status .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-status-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-status-2 d-mark
ON VALUE-CHANGED OF c-status-2 IN FRAME d-mark
    DO:
        assign c-status-2 .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Status_
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Status_ d-mark
ON VALUE-CHANGED OF Status_ IN FRAME d-mark
    DO:
        assign status_ .
        run init-temp in this-procedure .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/*&Scoped-define SELF-NAME v-bar-code                           */
/*&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-bar-code d-mark   */
/*ON any-printable OF v-bar-code IN FRAME d-mark /* Штрих-код */*/
/*do:                                                           */
/*        run proc-any-key.                                     */
/*    end.                                                      */
/*                                                              */
/*/* _UIB-CODE-BLOCK-END */                                     */
/*&ANALYZE-RESUME                                               */


/*&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-bar-code d-mark               */
/*ON ENTRY OF v-bar-code IN FRAME d-mark /* Штрих-код */                    */
/*DO:                                                                       */
/*        run LoadKeyboardLayoutA (input v-scan-str, input 0, output iLang).*/
/*        run ActivateKeyboardLayout (input iLang, input 0).                */
/*    END.                                                                  */
/*                                                                          */
/*/* _UIB-CODE-BLOCK-END */                                                 */
/*&ANALYZE-RESUME                                                           */


/*&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-bar-code d-mark*/
/*ON return OF v-bar-code IN FRAME d-mark /* Штрих-код */    */
/*DO:                                                        */
/*        run scan-bar-code .                                */
/*    END.                                                   */
/*                                                           */
/*/* _UIB-CODE-BLOCK-END */                                  */
/*&ANALYZE-RESUME                                            */

&Scoped-define SELF-NAME v-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-mark d-mark
ON any-printable OF v-mark IN FRAME d-mark /* Марка */
do:
        run proc-any-key.
    end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-mark d-mark
ON ENTRY OF v-mark IN FRAME d-mark /* Марка */
DO:
        run LoadKeyboardLayoutA (input v-scan-str, input 0, output iLang).
        run adm/shattri.p (
               input "get":U
               ,input  v-cntxt-obj-type /*p-obj-type*/
               ,input  v-cntxt-obj-code /*p-obj-code*/
               ,input  {&attr-marking}
               ,input  {&attr-marking_rus-key} /*p-param-code*/
               ,output p-value-character
               ,output p-value-date
               ,output p-value-decimal
               ,output p-value-integer
               ,output p-value-logical
               ,output p-param-type
               ,input-output table-handle v-tth
               ) no-error . 
        IF p-value-logical = yes THEN  iLang = 68748313.

        run ActivateKeyboardLayout (input iLang, input 0).
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-mark d-mark
ON return OF v-mark IN FRAME d-mark /* Марка */
DO:
   if v-mark:screen-value in frame {&frame-name} = ""
        then 
    do:
        v-mark:screen-value in frame {&frame-name} = v-scan-str.
    end.
      
    v-scan-str = "". 
    assign 
        v-mark = v-mark:screen-value .
    
   if isMark(v-mark)
   then
   do:
     run scan-mark .
     br-mark:refresh() in frame {&frame-name}.
     {&OPEN-QUERY-br-mark-item}
     if NUM-RESULTS("br-mark-item") > 0 then 
       br-mark-item:refresh() in frame {&frame-name}.
   end.
   else
      run scan-bar-code .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/*&Scoped-define BROWSE-NAME br-bar-code*/
/*&UNDEFINE SELF-NAME                   */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-mark 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
    THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} 
    APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

    { gbl/getcntxt.i get }
    EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code).
    Marking = ObjSrv:Env:Marking:Sts:Mark .
    tree = ObjSrv:Lib:MarkingTree .
    run LoadKeyboardLayoutA (input v-scan-str, input 0, output iLang).
      run adm/shattri.p (
               input "get":U
               ,input  v-cntxt-obj-type /*p-obj-type*/
               ,input  v-cntxt-obj-code /*p-obj-code*/
               ,input  {&attr-marking}
               ,input  {&attr-marking_rus-key} /*p-param-code*/
               ,output p-value-character
               ,output p-value-date
               ,output p-value-decimal
               ,output p-value-integer
               ,output p-value-logical
               ,output p-param-type
               ,input-output table-handle v-tth
               ) no-error . 
      IF p-value-logical = yes THEN  iLang = 68748313.

    run ActivateKeyboardLayout (input iLang, input 0).
/*    output to hhhhhhh.txt.       */
/*    for each tt-marking-lines:   */
/*        export tt-marking-lines .*/
/*    end.                         */
/*    output close.                */
   /*Проверка прав */
    { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_mark_stchange':U
  {&cntxt-firm}
  v-cntxt-host-code-obj
  '':U
  0
  0
  0
  0
  false
  log-res
}
    { gbl/brwrepos.i
  &browse-name = br-mark
  &line-num= 5
}
    { gbl/brwrepos.i
  &browse-name = br-mark-item
  &line-num= 5
}

   find first utd no-lock where utd.doc-id = tt-marking-lines.doc-id and utd.db-num = tt-marking-lines.db-num no-error .
   if available (utd) then do:
      if utd.EDocType = objSrv:Env:Utd:EDocType:Introduce:KeyIntDB then v-edoc-type = yes .
/*      find first ub.utd-attr no-lock where ub.utd-attr.doc-id = utd.doc-id and ub.utd-attr.db-num = utd.db-num and ub.utd-attr.attr-code = "MarkUtd" no-error .*/
/*      if available (ub.utd-attr) then upd_mark = logical(ub.utd-attr.attr-value) .                                                                             */
   end. 

   /* определим, является ли преданные док-т расодом внешним для возврата поставщику */
   if num-entries(p-doc,{&delim-par}) > 1 then
   do:
     { str/tdat-val.i
       trim(entry(2,entry(1,p-doc,{&delim-par}),':'))
       {&trdcattr-is-return}
       varvalue
       vartype
       no-error
     }
     mIsRasVneshReturn = (varvalue = "yes").
   end. 
     
    run init-temp in this-procedure .
    run enable_UI in this-procedure .
    apply "entry" to v-mark in FRAME {&FRAME-NAME}.
    if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):IsManual
        then v-manual = yes .
    else 
    do: 
        v-manual = no .
        v-mark:READ-ONLY IN FRAME {&frame-name}        = TRUE .
/*        v-bar-code:READ-ONLY IN FRAME {&frame-name}        = TRUE .*/
    end.
    X_marking-line.mark:COLUMN-READ-ONLY IN BROWSE br-mark-item = YES.
    X_marking.mark     :COLUMN-READ-ONLY IN BROWSE br-mark      = YES.
    apply "value-changed" to br-mark in FRAME {&FRAME-NAME}.
    WAIT-FOR GO OF FRAME {&FRAME-NAME} focus {&browse-name}.
END.

run disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-mark  _DEFAULT-DISABLE
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
    HIDE FRAME d-mark.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-mark 
PROCEDURE enable_UI :
    /* --------------------------------------------------------------------
                          Purpose:     ENABLE the User Interface
                          Parameters:  <none>
                          Notes:       Here we display/view/enable the widgets in the
                                       user-interface.  In addition, OPEN all queries
                                       associated with each FRAME and BROWSE.
                                       These statements here are based on the "Other
                                       Settings" section of the widget Property Sheets.
                           -------------------------------------------------------------------- */
    frame {&frame-name}:title = entry(1,p-doc,{&delim-par}) + " " + p-mode.
    ENABLE
        b-exit
        b-hist
        b-look
        with frame {&frame-name} .  
/*    if not upd_mark then do:      */
/*    ENABLE                        */
/*        br-bar-code               */
/*        with frame {&frame-name} .*/
/*    hide                          */
/*    br-mark                       */
/*    br-mark-item                  */
/*    Status_                       */
/*    in frame {&frame-name} .      */
/*    end.                          */
/*    else do:                      */
/*    hide                          */
/*        br-bar-code               */
/*        in frame {&frame-name} .  */
    enable
    br-mark
    br-mark-item
    with frame {&frame-name} .          
/*    end.*/
    display f-text with frame {&frame-name} .
      
    if p-mode <> {&lookup} then 
    do:
        if p-type = 5 then 
        do:
            ENABLE
                b-del
                b-mark
                bt-not-sel-all
                bt-not-sel-desel-all
                with frame {&frame-name} .
/*           if not upd_mark then do:                                   */
/*              disable                                                 */
/*                 b-del                                                */
/*                 b-mark                                               */
/*                 bt-not-sel-all                                       */
/*                 bt-not-sel-desel-all                                 */
/*                 b-change                                             */
/*                 with frame {&frame-name} .                           */
/*                 browse br-bar-code:GET-BROWSE-COLUMN(5):VISIBLE = no.*/
/*           end.                                                       */
        end.  
        
/*        if not upd_mark then do:          */
/*                                          */
/*        HIDE                              */
/*            v-mark                        */
/*            in frame {&frame-name} .      */
/*/*        enable                        */*/
/*/*            v-bar-code                */*/
/*/*            with frame {&frame-name} .*/*/
/*        end.                              */
/*        else do:                          */
        ENABLE
            v-mark
            with frame {&frame-name} .
/*        HIDE                        */
/*            v-bar-code              */
/*            in frame {&frame-name} .*/
/*        end.                        */
        /*проверка на права*/
        if log-res then 
        do:  
            enable
                c-status
                b-change
                b-mark
                bt-not-sel-all
                bt-not-sel-desel-all
                 WITH FRAME {&frame-name}.
/*            if upd_mark then do:         */
/*            enable                       */
/*                c-status-2               */
/*                b-change-2               */
/*                b-mark-2                 */
/*                bt-not-sel-all-2         */
/*                bt-not-sel-desel-all-2   */
/*                WITH FRAME {&frame-name}.*/
/*            end.                         */
        end.   
    end.
    else 
    do:
        display
            b-del
            b-mark
            b-mark-2
            bt-not-sel-all
            bt-not-sel-all-2
            bt-not-sel-desel-all
            bt-not-sel-desel-all-2
            c-status
            c-status-2
            b-change
            b-change-2
            c-status-2
            WITH FRAME {&frame-name}.
/*      if not upd_mark then do:         */
/*            hide                       */
/*                c-status-2             */
/*                b-change-2             */
/*                b-mark-2               */
/*                bt-not-sel-all-2       */
/*                bt-not-sel-desel-all-2 */
/*                in FRAME {&frame-name}.*/
/*      end.                             */
    end.  
    if p-type = 1 then 
    do:
        if p-mode <> {&lookup} then 
        do:
/*        if not upd_mark then do:          */
/*        HIDE                              */
/*            Status_                       */
/*            v-mark                        */
/*            in frame {&frame-name} .      */
/*/*        enable                        */*/
/*/*            v-bar-code                */*/
/*/*            with frame {&frame-name} .*/*/
/*        end.                              */
/*        else do:                          */
        ENABLE
            Status_
            v-mark
            with frame {&frame-name} .
/*        HIDE                        */
/*            v-bar-code              */
/*            in frame {&frame-name} .*/
/*        end.                        */
        end.
    end.
    else 
    do:
        hide b_block in frame {&frame-name} .
    end.  
    if p-type = 0 then 
    do:
/*        browse br-bar-code:GET-BROWSE-COLUMN(5):VISIBLE = no.*/
/*        browse br-mark:GET-BROWSE-COLUMN(7):VISIBLE = no.     */
/*        browse br-mark-item:GET-BROWSE-COLUMN(7):VISIBLE = no.*/
        hide 
            Status_
            v-mark
/*            v-bar-code*/
            in frame {&frame-name} .
    end.  
    if p-type <> 2 then 
    do:
        find first buf_utd-err no-lock where buf_utd-err.db-num = tt-marking-lines.db-num and buf_utd-err.doc-id = tt-marking-lines.doc-id and buf_utd-err.reckey begins "utd-marking-lines" no-error .
        if available (buf_utd-err) then 
            enable b_error with frame {&frame-name} .
    end.  
/*    if p-mode = {&lookup} then                            */
/*    do:                                                   */
/*        if not upd_mark then do:                          */
/*        HIDE                                              */
/*            v-mark                                        */
/*            in frame {&frame-name} .                      */
/*        enable                                            */
/*            v-bar-code                                    */
/*            with frame {&frame-name} .                    */
/*        end.                                              */
/*    end.                                                  */
/*if not upd_mark then do:                                  */
/*   hide                                                   */
/*   qnty-mark                                              */
/*   qnty-mark-2                                            */
/*   f-qnty-unit                                            */
/*   in frame {&frame-name} .                               */
/*    if p-type = 6 then                                    */
/*    do:                                                   */
/*        display qnty-bar-code with frame {&frame-name} .  */
/*        display qnty-bar-code2 with frame {&frame-name} . */
/*        hide f-qnty-bar-code in frame {&frame-name} .     */
/*    end.                                                  */
/*    else                                                  */
/*    do:                                                   */
/*        display f-qnty-bar-code with frame {&frame-name} .*/
/*        hide qnty-bar-code   in frame {&frame-name} .     */
/*        hide qnty-bar-code2 in frame {&frame-name} .      */
/*    end.                                                  */
/*end.                                                      */
/*else do:                                                  */
/*   hide qnty-bar-code      */
/*   qnty-bar-code2          */
/*   f-qnty-bar-code         */
/*   in frame {&frame-name} .*/
    if p-type = 6 then 
    do:
        display qnty-mark with frame {&frame-name} .
        display qnty-mark-2 with frame {&frame-name} .
        hide f-qnty-unit in frame {&frame-name} .
        hide f-qnty-bar-code  in frame {&frame-name} .
    end.
    else 
    do:  
        display f-qnty-unit with frame {&frame-name} .
        display f-qnty-bar-code with frame {&frame-name} .
        hide qnty-mark   in frame {&frame-name} .
        hide qnty-mark-2 in frame {&frame-name} .
    end.
/*end.*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-mark d-mark 
PROCEDURE save-mark :
    /* --------------------------------------------------------------------
                          Purpose:     ENABLE the User Interface
                          Parameters:  <none>
                          Notes:       Here we display/view/enable the widgets in the
                                       user-interface.  In addition, OPEN all queries
                                       associated with each FRAME and BROWSE.
                                       These statements here are based on the "Other
                                       Settings" section of the widget Property Sheets.
                           -------------------------------------------------------------------- */
    define variable v-GTIN as character no-undo .

    for each X_marking-line no-lock where X_marking-line.GrayZone = yes:
        create buf_utd-marking-lines .
        assign
            buf_utd-marking-lines.db-num    = X_marking-line.db-num
            buf_utd-marking-lines.doc-id    = X_marking-line.doc-id
            buf_utd-marking-lines.doc-level = X_marking-line.doc-level
            buf_utd-marking-lines.gds-code  = X_marking-line.gds-code
            buf_utd-marking-lines.LineNum   = X_marking-line.LineNum
            buf_utd-marking-lines.mark      = X_marking-line.mark
            buf_utd-marking-lines.sts       = X_marking-line.sts-utd
            .
        find first ub.marking exclusive-lock where ub.marking.mark = X_marking-line.mark no-error . 
        if not available (ub.marking) then 
        do:
            create ub.marking .
            assign
                ub.marking.mark = X_marking-line.mark
                ub.marking.box-qnty    = ?
            .
        end.  
        v-GTIN = getGtinByDM(X_marking-line.mark) .
        assign
            ub.marking.gds-code    = X_marking-line.gds-code
            ub.marking.sts         = X_marking-line.sts
            ub.marking.gds-ext-id  = v-GTIN
            ub.marking.obj-code    = X_marking-line.obj-code
            ub.marking.obj-type    = X_marking-line.obj-type
            ub.marking.mark-parent = mark-parent
        .
        if v-edoc-type then ub.marking.sts = Marking:Checked_:KeyIntDB .
        ub.marking.unit-ext  = getLevelMotpByDM(X_marking-line.mark) .
        ub.marking.box-qnty  = getQntyCodeByGtin(getGtinByDM(X_marking-line.mark)).
    /*          ub.marking.unit = getLevelUTDByDM(v-marking) .*/
 
    end.  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-temp d-mark 
PROCEDURE init-temp :
    /* --------------------------------------------------------------------
                          Purpose:     ENABLE the User Interface
                          Parameters:  <none>
                          Notes:       Here we display/view/enable the widgets in the
                                       user-interface.  In addition, OPEN all queries
                                       associated with each FRAME and BROWSE.
                                       These statements here are based on the "Other
                                       Settings" section of the widget Property Sheets.
                           -------------------------------------------------------------------- */
    /*по товару*/
    define variable ii       as integer   no-undo .
    define variable Status_1 as character no-undo .
  
    Status_1 = "" + {&comma-char} + '0':U .
 
   define variable MarkType as ibs.th.gbl.map.mapstring no-undo.
   define variable objType  as ibs.th.gbl.propmap no-undo.
   define variable Types as ibs.th.str.marking.sts.mark no-undo.
   Types = ObjSrv:Env:Marking:Sts:Mark.
   MarkType = Types:mapType.

    do ii = 1 to MarkType:GetItemByLab(ii):
        objType = Types:CurrProp.
        Status_1 = Status_1 + {&comma-char} + objType:Label_ + {&comma-char} + string(objType:KeyIntDB) .
    end.
    ASSIGN
        c-status:LIST-ITEM-PAIRS  in frame {&frame-name} = Status_1 .
    ASSIGN
        c-status-2:LIST-ITEM-PAIRS  in frame {&frame-name} = Status_1 .

    /* вычислим уровень */
    if p-parent_mark <> "" then
    do:
      for first tt-marking-lines no-lock where tt-marking-lines.mark-parent = p-parent_mark:
        vLevel = tt-marking-lines.doc-level.
      end.        
    end.
/*    if not upd_mark then do:           */
/*    for each tt-marking-lines no-lock: */
/*        v-qnty-mark = v-qnty-mark + 1 .*/
/*    end.                               */
/*    end.                               */
/*    else do:                           */
    for each tt-marking-lines no-lock where tt-marking-lines.unit-ext = "UNIT":
/*        if tt-marking-lines.isMark*/
/*        then                      */
           v-qnty-mark = v-qnty-mark + 1 .
           if tt-marking-lines.sts-utd = Marking:Checked_:KeyIntDB then 
             qnty-mark-2 = qnty-mark-2 + 1.
    end.  
/*    end.*/

    f-qnty-unit = v-qnty-mark .
    f-qnty-bar-code = v-qnty-mark .
    if p-type = 6 then 
    do:
        find first tt-marking-lines no-lock where tt-marking-lines.doc-level = 1 no-error .
        if available (tt-marking-lines) then 
        do:
            qnty-mark = tt-marking-lines.box-qnty .
/*            qnty-bar-code = tt-marking-lines.box-qnty .*/
            mark-parent = tt-marking-lines.mark .
        end.
/*        if not upd_mark then                                                                                    */
/*             f-text = "Упаковка с неполным составом штрих-кодом, необходимо просканировать все марки упаковки" .*/
/*        else                                                                                                    */
        f-text = "Упаковка с неполным составом марок/штрих-кодом, необходимо просканировать все марки упаковки" .
    end.
    {&OPEN-BROWSERS-IN-QUERY-d-mark}
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION GdsName d-mark 
FUNCTION GdsName RETURNS CHARACTER
    ( input p-gds-code as integer ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/
    define buffer buf_goods for ub.goods .
    define variable v-gds-name as character no-undo . 
    find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
    if available (buf_goods) then v-gds-name = buf_goods.gds-name .
    RETURN v-gds-name.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getStatusName d-mark 
FUNCTION getStatusName RETURNS CHARACTER
    ( input p-mark as character,
      input p-sts-glob as integer,
      input p-sts-loc  as integer ):
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/
    define variable vExtDocType as character no-undo.
    define buffer c-marking for ub.c-marking.

    vExtDocType = if num-entries(p-doc,{&delim-par}) > 1 then entry(2,p-doc,{&delim-par}) else ?.
    if p-sts-loc = marking:Reserved:KeyIntDB and 
       (vExtDocType = {&TDEDT_Spi_Vnesh} or vExtDocType = {&TDEDT_Ras_Perem} or mIsRasVneshReturn) then
    do:
      find last c-marking no-lock where
                c-marking.mark = p-mark
           use-index pi-2 no-error.
      if not avail c-marking or
         c-marking.sts = marking:Checked_:KeyIntDB or 
         c-marking.sts = marking:FreeZone:KeyIntDB then 
        return StatusTHName(p-sts-glob).
      else
        return substitute("&1_&2",StatusTHName(p-sts-loc),StatusTHName(c-marking.sts)).
    end.
    else 
      return if p-sts-loc = marking:Checked_:KeyIntDB    and 
                p-sts-glob <> marking:Ungrouped:KeyIntDB and 
                p-sts-glob <> marking:MarkError:KeyIntDB
             then StatusTHName(p-sts-loc) 
             else StatusTHName(p-sts-glob). 

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME v-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-mark d-mark
ON ENTRY OF v-mark IN FRAME d-mark /* Марка */
    DO:
        run LoadKeyboardLayoutA (input v-scan-str, input 0, output iLang).
        run adm/shattri.p (
               input "get":U
               ,input  v-cntxt-obj-type /*p-obj-type*/
               ,input  v-cntxt-obj-code /*p-obj-code*/
               ,input  {&attr-marking}
               ,input  {&attr-marking_rus-key} /*p-param-code*/
               ,output p-value-character
               ,output p-value-date
               ,output p-value-decimal
               ,output p-value-integer
               ,output p-value-logical
               ,output p-param-type
               ,input-output table-handle v-tth
               ) no-error . 
        IF p-value-logical = yes THEN  iLang = 68748313.

        run ActivateKeyboardLayout (input iLang, input 0).
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/*&Scoped-define SELF-NAME v-bar-code                                       */
/*&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-bar-code d-mark               */
/*ON ENTRY OF v-bar-code IN FRAME d-mark /* Штрих-код */                    */
/*    DO:                                                                   */
/*        run LoadKeyboardLayoutA (input v-scan-str, input 0, output iLang).*/
/*        run ActivateKeyboardLayout (input iLang, input 0).                */
/*    END.                                                                  */
/*                                                                          */
/*/* _UIB-CODE-BLOCK-END */                                                 */
/*&ANALYZE-RESUME                                                           */
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE LoadKeyboardLayoutA d-utd
procedure LoadKeyboardLayoutA external "user32" :
    define input  parameter P1 as char.
    define input  parameter P2 as LONG.
    define return parameter pret as LONG.
end procedure.
        
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME 
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ActivateKeyboardLayout d-utd 
procedure ActivateKeyboardLayout external "user32" :
    define input parameter P1 as LONG.
    define input parameter P2 as LONG.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE scan-mark d-mark 
PROCEDURE scan-mark :
    define variable v_list      as character no-undo .
    define variable ii          as integer   no-undo .
    define variable v-marking   as character no-undo .
    define variable recid_mark1 as integer   no-undo .
    define variable v-GTIN      as character no-undo .
    define variable v-gds-code  as integer   no-undo .
    define VARIABLE vRecKeyLine as character no-undo .
    define VARIABLE vMsg        as character no-undo .
    define variable vFlag       as log       no-undo.
    define buffer gray_marking                for ub.marking .
    define buffer gray_unit-marking           for ub.marking .
    define buffer gray_utd-marking-lines      for ub.utd-marking-lines .
    define buffer gray_unit_utd-marking-lines for ub.utd-marking-lines .
    define buffer buf_utd-lines               for ub.utd-lines .
    define buffer buf_utd-marking-lines       for ub.utd-marking-lines .
    define buffer X_utd-lines                 for tt-utd-lines .
    define buffer buf_utd-err                 for ub.utd-err .
    define buffer un_utd-marking-lines        for ub.utd-marking-lines .
    
    if v-mark:screen-value in frame {&frame-name} = ""
        then 
    do:
        v-mark:screen-value in frame {&frame-name} = v-scan-str.
    end.
      
    v-scan-str = "". 
    assign 
        v-mark = v-mark:screen-value in frame {&frame-name}.
    v-marking = GetCodeIdent(v-mark) .
    
    f-text = "" .
    f-text:screen-value = "" .
    /*    if v-marking = "" or v-marking = ? then RETurn no-apply .*/
    ASSIGN 
        v_list = 'Ё,Й,Ц,У,К,Е,Н,Г,Ш,Щ,З,Х,Ъ,Ф,Ы,В,А,П,Р,О,Л,Д,Ж,Э,Я,Ч,С,М,И,Т,Ь,Б,Ю':U .

    /*проверка на русские буквы*/
    do ii = 1 to length (v-mark):
        if LOOKUP( SUBSTRING( v-mark, ii, 1 ), v_list )  > 1 then
        do:
            message "Не корректно считана акцизная марка, перед считыванием переключите клавиатуру на английскую раскладку."
                view-as alert-box.
            v-mark:screen-value = "" .
            v-mark = "" . 
            return .  
        end.
    end.
    v-marking = GetCodeIdent(v-mark) .
    if v-marking = "" or v-marking = ? then 
    do:
        F-text = "            Просканирован штрих код, необходимо просканировать марку" .
        display F-text with frame {&frame-name}.
        v-mark:screen-value = "" .
        v-mark = "" .
        return no-apply.
    end.  

    if p-mode <> {&lookup} then 
    do:
        /*Режим Серая зона*/
        if p-type = 6 then 
        do:
            find first X_marking-line exclusive-lock where X_marking-line.mark begins v-marking no-error .
            if available (X_marking-line) then
            do:
                recid_mark = recid (X_marking-line) .
                if X_marking-line.sts-utd = Marking:Checked_:KeyIntDB then
                do:
                    if qnty-mark = qnty-mark-2 then 
                    do:
                        F-text = "               Упаковка просканирована полностью".
                        display F-text with frame {&frame-name}.
                        v-mark:screen-value = "" .
                        v-mark = "" . 
                        return no-apply.              
                    end.
                    else 
                    do:  
                        F-text = "            Марка уже проверена, просканируйте следующую".
                        display F-text with frame {&frame-name}.
                        v-mark:screen-value = "" .
                        v-mark = "" . 
                        return no-apply.
                    end.  
                end.  
                if X_marking-line.sts = Marking:GrayZone:KeyIntDB and X_marking-line.doc-level = 1 then 
                do:
                    F-text = "      Это марка упаковки, просканируйте марку индивидуальной упаковки".
                    display F-text with frame {&frame-name}.
                    v-mark:screen-value = "" .
                    v-mark = "" . 
                    return no-apply.                  
                end.  
                /*          if X_marking-line.sts > Marking:DemandInfo:KeyIntDB then do:           */
                /*              F-text = "            Марка оприходована, просканируйте следующую".*/
                /*              display F-text with frame {&frame-name}.                           */
                /*              v-mark:screen-value = "" .                                         */
                /*              v-mark = "" .                                                      */
                /*              return no-apply.                                                   */
                /*          end.                                                                   */
                find first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark = X_marking-line.mark and buf_utd-marking-lines.db-num = X_marking-line.db-num and
                    buf_utd-marking-lines.doc-id = X_marking-line.doc-id no-error .
                if available (buf_utd-marking-lines) then buf_utd-marking-lines.sts = Marking:Checked_:KeyIntDB .
                assign
                    X_marking-line.sts-utd = Marking:Checked_:KeyIntDB .
                X_marking-line.stts-utd = StatusTHName(Marking:Checked_:KeyIntDB)
                    .
                qnty-mark-2 = qnty-mark-2 + 1 .
                display qnty-mark-2 with frame {&frame-name} .
                br-mark-item :refresh().
                reposition br-mark-item to recid recid_mark no-error .

                v-mark:screen-value = "" .
                v-mark = "" .

            end.
            else 
            do:
                find first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark begins v-marking and buf_utd-marking-lines.db-num = X_marking-line.db-num and
                    buf_utd-marking-lines.doc-id = X_marking-line.doc-id no-error .
                if qnty-mark = qnty-mark-2 then 
                do:
                    F-text = "               Упаковка просканирована полностью".
                    display F-text with frame {&frame-name}.
                    v-mark:screen-value = "" .
                    v-mark = "" . 
                    return no-apply.              
                end. 
                if v-qnty-mark = qnty-mark then 
                do:
                    F-text = "        Все неизвестные марки добавлены, просканируйте непроверенные марки".
                    display F-text with frame {&frame-name}.
                    v-mark:screen-value = "" .
                    v-mark = "" . 
                    return no-apply.              
                end.  
                if available (buf_utd-marking-lines) then 
                do:
                    f-text = "                    Марка в документе уже есть".
                    display F-text with frame {&frame-name}.
                    v-mark:screen-value = "" .
                    v-mark = "" .
                    leave .
                end.   
                v-GTIN = getGtinByDM(v-marking) .
                v-gds-code = getGdsCodeByGtin(v-GTIN) .
                if v-gds-code <> X_marking.gds-code then 
                do:
                    f-text = "                Марка не может относится к проверяемой упаковке ".
                    display F-text with frame {&frame-name}.
                    v-mark:screen-value = "" .
                    v-mark = "" .
                    leave .
                end.  
                find first ub.marking exclusive-lock where ub.marking.mark begins v-marking no-error .
                if available (ub.marking) then 
                do:
                    /*            if ub.marking.unit-ext <> "UNIT" or (ub.marking.mark-parent <> "" and ub.marking.mark-parent <> X_marking.mark) then*/
                    /*            do:                                                                                                                 */
                    f-text = "              Марка оприходована, просканируйте следующую".
                    display F-text with frame {&frame-name}.
                    v-mark:screen-value = "" .
                    v-mark = "" .
                    leave .
                /*            end.*/
                end.
                if qnty-mark-2 = X_marking.box-qnty then 
                do:
                    f-text = "                  Все неизвестные марки по упаковке добавлены" .
                    display F-text with frame {&frame-name}.
                    v-mark:screen-value = "" .
                    v-mark = "" . 
                    return no-apply.
                end.        
                /*добавляем марку*/
                /*          create buf_utd-marking-lines .                               */
                /*          assign                                                       */
                /*            buf_utd-marking-lines.db-num    = X_marking.db-num         */
                /*            buf_utd-marking-lines.doc-id    = X_marking.doc-id         */
                /*            buf_utd-marking-lines.doc-level = 2                        */
                /*            buf_utd-marking-lines.gds-code  = X_marking.gds-code       */
                /*            buf_utd-marking-lines.LineNum   = X_marking.LineNum        */
                /*            buf_utd-marking-lines.mark      = v-marking                */
                /*            buf_utd-marking-lines.sts       = Marking:Checked_:KeyIntDB*/
                /*            .                                                          */
                /*          if not available (ub.marking) then                           */
                /*          do:                                                          */
                /*            create ub.marking .                                        */
                /*            assign                                                     */
                /*              ub.marking.mark = v-marking                              */
                /*              .                                                        */
                /*          end.                                                         */
                /*          assign                                                       */
                /*            ub.marking.gds-code    = buf_utd-marking-lines.gds-code    */
                /*            ub.marking.sts         = Marking:DeliveryControl:KeyIntDB  */
                /*            ub.marking.gds-ext-id  = v-GTIN                            */
                /*            ub.marking.obj-code    = X_marking.obj-code                */
                /*            ub.marking.obj-type    = X_marking.obj-type                */
                /*            ub.marking.mark-parent = X_marking.mark                    */
                /*            .                                                          */
                /*          ub.marking.unit-ext  = getLevelMotpByDM(v-marking) .         */
                /*          ub.marking.box-qnty  = getQntyUTDByDM(v-marking) .           */
                /*/*          ub.marking.unit = getLevelUTDByDM(v-marking) .*/           */

                create X_marking-line .
                assign
                    X_marking-line.db-num      = X_marking.db-num
                    X_marking-line.doc-id      = X_marking.doc-id
                    X_marking-line.doc-level   = X_marking.doc-level + 1
                    X_marking-line.gds-code    = X_marking.gds-code
                    X_marking-line.LineNum     = X_marking.LineNum
                    X_marking-line.mark        = v-marking 
                    X_marking-line.sts         = Marking:DeliveryControl:KeyIntDB
                    X_marking-line.mark-parent = X_marking.mark
                    X_marking-line.GrayZone    = yes
                    .
                X_marking-line.gds-name    = GdsName(X_marking-line.gds-code) 
                    .
            
                X_marking-line.box-qnty = getQntyCodeByGtin(getGtinByDM(v-marking)) .
                X_marking.unit-ext  = getLevelMotpByDM(v-marking) .
                
                assign
                X_marking-line.sts-utd = Marking:Checked_:KeyIntDB .
                X_marking-line.stts-utd = StatusTHName(Marking:Checked_:KeyIntDB) .
                X_marking-line.stts = StatusTHName(X_marking-line.sts)
                    .
                if v-edoc-type then X_marking-line.stts = StatusTHName(Marking:Checked_:KeyIntDB) .
                qnty-mark-2 = qnty-mark-2 + 1 .
                v-qnty-mark = v-qnty-mark + 1 .
                display qnty-mark-2 with frame {&frame-name} .
                
                /*          find first X_marking-line where X_marking-line.mark = ub.marking.mark no-error .*/
                recid_mark = recid(X_marking-line) .
                {&OPEN-BROWSERS-IN-QUERY-d-mark-item} /*переотрывает запрос*/
                br-mark-item:refresh () no-error . /*обновляет экран*/
                reposition br-mark-item to recid recid_mark no-error . /*позиционирует запись*/

                v-mark:screen-value = "" .
                v-mark = "" .
            end.  
        end.
        else if p-type = 2 then
        do:  /* если это внутренний приход */
            run checkPriPerem in this-procedure (v-marking, output F-text).
            if F-text <> "" then
            do:
               display F-text with frame {&frame-name}.
               v-mark:screen-value = "" .
               v-mark = "" .
               return no-apply.
            end.
            br-mark:refresh().
            reposition br-mark to recid recid_mark no-error .
            br-mark-item:refresh () no-error .
        end.
        else /*не серая зона*/
        do:  
            find first X_marking exclusive-lock where X_marking.mark begins v-marking no-error .
            if v-mark <> v-marking and 
               avail(X_marking) and 
               X_marking.unit-ext = "LEVEL2" then
            do:
            /* BTS-2596 Доп. проверка при обрезании КМ, если найденная марка LEVEL2 */
              v-marking = v-mark.
              find first X_marking exclusive-lock where X_marking.mark begins v-marking no-error .
            end.
            
            if available (X_marking) then
            do:
                run checkEMRC(v-mark, output vFlag).
                if not vFlag
                then do:
                   F-text = "МРЦ на упаковке меньше ЕМЦ. Приемка товара запрещена." .
                   display F-text with frame {&frame-name}.
                   v-mark:screen-value = "" .
                   v-mark = "" .
                   return no-apply.
                end.   
                for first buf_utd-marking-lines no-lock where buf_utd-marking-lines.doc-id = X_marking.doc-id
                    and buf_utd-marking-lines.db-num = X_marking.db-num
                    and buf_utd-marking-lines.mark = X_marking.mark,
                    first buf_utd-lines no-lock where buf_utd-lines.db-num = buf_utd-marking-lines.db-num
                    and buf_utd-lines.doc-id = buf_utd-marking-lines.doc-id
                    and buf_utd-lines.LineNum = buf_utd-marking-lines.LineNum:   
                    run gen-key-rec ("utd-lines", 
                        input  buffer buf_utd-lines:handle, 
                        output vRecKeyLine).

                    find first buf_utd-err no-lock where buf_utd-err.doc-id = buf_utd-lines.doc-id and buf_utd-err.db-num = buf_utd-lines.db-num and buf_utd-err.reckey = vRecKeyLine no-error .
                    if available (buf_utd-err) then 
                    do:
                        F-text = "Товар не подлежит приемке, т.к. не прошел проверку на корректность" .
                        display F-text with frame {&frame-name}.
                        v-mark:screen-value = "" .
                        v-mark = "" .
                        return no-apply.   
                    end. /*if available (buf_utd-err) then */
        
                end. /*for first buf_utd-marking-lines no-lock where buf_utd-marking-lines.doc-id = X_marking.doc-id*/
                recid_mark = recid (X_marking) .
                if X_marking.isWeight then
                do:
                    f-text = "Просканированная марка по товару с переменным весом. Просканируйте марку в основном окне УПД." .
                    display F-text with frame {&frame-name}.
                    v-mark:screen-value = "" .
                    v-mark = "" . 
                    return no-apply.
                end.               
                else if X_marking.sts-utd = Marking:Checked_:KeyIntDB then
                do:
                    f-text = "          Марка уже проверена, просканируйте следующую" .
                    display F-text with frame {&frame-name}.
                    v-mark:screen-value = "" .
                    v-mark = "" . 
                    return no-apply.
                end. /*if X_marking.sts-utd = Marking:Checked_:KeyIntDB then*/
                else if X_marking.sts-utd = Marking:Ungrouped:KeyIntDB then
                do:
                    f-text = substitute(
                      "&1 упаковка разгруппирована, просканируйте марку &2 упаковки.",
                      if X_marking.unit-ext = "LEVEL1" then "Групповая" else "Транспортная",
                      if X_marking.unit-ext = "LEVEL1" then "потребительской" else "групповой"
                    ).
                    display F-text with frame {&frame-name}.
                    v-mark:screen-value = "" .
                    v-mark = "" . 
                    return no-apply.
                end. /*if X_marking.sts-utd = Marking:Checked_:KeyIntDB then*/
                else
                do:
                    if X_marking.sts = Marking:MarkError:KeyIntDB  then 
                    do:
                        F-text = "Товар не подлежит приемке, т.к. не прошел проверку на корректность" .
                        display F-text with frame {&frame-name}.
                        v-mark:screen-value = "" .
                        v-mark = "" .
                        return no-apply.              
                    end. /*if X_marking.sts = Marking:MarkError:KeyIntDB  then do:*/
                    find first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark = X_marking.mark and buf_utd-marking-lines.db-num = X_marking.db-num and
                        buf_utd-marking-lines.doc-id = X_marking.doc-id no-error .
                    if available (buf_utd-marking-lines) then 
                    do:
                        /*просканирована марка с серой зоной*/
                        if can-find (buf_marking where buf_marking.mark = buf_utd-marking-lines.mark and buf_marking.sts = Marking:GrayZone:KeyIntDB)
                            then
                        do:
                            /*                message "Упаковка с неполным составом марок, необходимо просканировать все индивидуальные упаковки" skip*/
                            /*                  view-as alert-box.                                                                                    */
                            v-mark:screen-value = "" .
                            v-mark = "" .
                            for first gray_utd-marking-lines no-lock where gray_utd-marking-lines.db-num = X_marking.db-num and
                                gray_utd-marking-lines.doc-id = X_marking.doc-id and
                                gray_utd-marking-lines.LineNum = X_marking.LineNum and
                                gray_utd-marking-lines.mark = buf_utd-marking-lines.mark:
                                for first gray_marking no-lock where gray_marking.mark = buf_utd-marking-lines.mark :
                                    create tt-gray-marking-lines .
                                    assign
                                        tt-gray-marking-lines.gds-name    = GdsName(gray_utd-marking-lines.gds-code)
                                        tt-gray-marking-lines.stts-utd    = StatusTHName(gray_utd-marking-lines.sts)
                                        tt-gray-marking-lines.stts        = StatusTHName(gray_marking.sts)
                                        tt-gray-marking-lines.mark        = gray_marking.mark
                                        tt-gray-marking-lines.mark-parent = gray_marking.mark-parent
                                        tt-gray-marking-lines.gds-code    = gray_utd-marking-lines.gds-code
                                        tt-gray-marking-lines.sts         = gray_marking.sts
                                        tt-gray-marking-lines.sts-utd     = gray_utd-marking-lines.sts
                                        tt-gray-marking-lines.unit        = gray_marking.unit
                                        tt-gray-marking-lines.box-qnty    = gray_marking.box-qnty
                                        tt-gray-marking-lines.LineNum     = gray_utd-marking-lines.LineNum
                                        tt-gray-marking-lines.db-num      = gray_utd-marking-lines.db-num
                                        tt-gray-marking-lines.doc-id      = gray_utd-marking-lines.doc-id
                                        tt-gray-marking-lines.doc-level   = gray_utd-marking-lines.doc-level
                                        .
                                end.
                                for each gray_unit-marking no-lock where gray_unit-marking.mark-parent = gray_utd-marking-lines.mark:
                                    for first gray_unit_utd-marking-lines no-lock where gray_unit_utd-marking-lines.db-num = X_marking.db-num and gray_unit_utd-marking-lines.doc-id = X_marking.doc-id
                                        and gray_unit_utd-marking-lines.LineNum = X_marking.LineNum and gray_unit_utd-marking-lines.mark = gray_unit-marking.mark:
                                        create tt-gray-marking-lines .
                                        assign
                                            tt-gray-marking-lines.gds-name    = GdsName(gray_unit_utd-marking-lines.gds-code)
                                            tt-gray-marking-lines.stts-utd    = StatusTHName(gray_unit_utd-marking-lines.sts)
                                            tt-gray-marking-lines.stts        = StatusTHName(gray_unit-marking.sts)
                                            tt-gray-marking-lines.mark        = gray_unit-marking.mark
                                            tt-gray-marking-lines.mark-parent = gray_unit-marking.mark-parent
                                            tt-gray-marking-lines.gds-code    = gray_unit_utd-marking-lines.gds-code
                                            tt-gray-marking-lines.sts         = gray_unit-marking.sts
                                            tt-gray-marking-lines.sts-utd     = gray_unit_utd-marking-lines.sts
                                            tt-gray-marking-lines.unit        = gray_unit-marking.unit
                                            tt-gray-marking-lines.unit-ext    = gray_unit-marking.unit-ext
                                            tt-gray-marking-lines.box-qnty    = gray_unit-marking.box-qnty
                                            tt-gray-marking-lines.LineNum     = gray_unit_utd-marking-lines.LineNum
                                            tt-gray-marking-lines.db-num      = gray_unit_utd-marking-lines.db-num
                                            tt-gray-marking-lines.doc-id      = gray_unit_utd-marking-lines.doc-id
                                            tt-gray-marking-lines.doc-level   = gray_unit_utd-marking-lines.doc-level
                                            .
                                    end.
                                end.
                            end.
                            run str/mark_browse.w (input parparentproc,
                                input-output table tt-gray-marking-lines by-reference,
                                input p-mode,
                                input "Марки по товару " + string(X_marking.gds-code) + " " + GdsName(X_marking.gds-code) + " со статусом: " + StatusTHName(Marking:GrayZone:KeyIntDB),
                                input 6,
                                input "" /*тип продукции*/
                                ) no-error .
                            for each tt-gray-marking-lines no-lock:
                                find first tt-marking-lines exclusive-lock where tt-marking-lines.mark = tt-gray-marking-lines.mark no-error .
                                if not available (tt-marking-lines) then 
                                do:
                                    create tt-marking-lines .
                                    buffer-copy tt-gray-marking-lines to tt-marking-lines .
                                    v-qnty-mark = v-qnty-mark + 1 .
                                    f-qnty-unit = v-qnty-mark .
                                end.
                                else 
                                do:
                                    assign
                                        tt-marking-lines.sts      = tt-gray-marking-lines.sts
                                        tt-marking-lines.stts     = tt-gray-marking-lines.stts
                                        tt-marking-lines.sts-utd  = tt-gray-marking-lines.sts-utd
                                        tt-marking-lines.stts-utd = tt-gray-marking-lines.stts-utd
                                        .
                                end.
                            end.
                            empty temp-table tt-gray-marking-lines .
                            br-mark :refresh().
                            reposition br-mark to recid recid_mark no-error .
                            br-mark-item:refresh () no-error .
                            display f-qnty-unit with frame {&frame-name} .
                        end. /*if can-find (buf_marking where buf_marking.mark = buf_utd-marking-lines.mark and buf_marking.sts = Marking:GrayZone:KeyIntDB)*/
                        else 
                        do:
                            /*просканирована марка не с серой зоной*/                  
                            if buf_utd-marking-lines.doc-level > 1 then 
                            do:
                                /*Разгруппировка блока*/
                                find first buf_marking no-lock where buf_marking.mark = buf_utd-marking-lines.mark no-error .
                                if available (buf_marking) then 
                                do:

                                    /*смотрим входит ли марка в состав блока со статусом Серая зона или Разгруппирован*/
                                    find first ub.marking exclusive-lock where ub.marking.mark = buf_marking.mark-parent and ub.marking.sts <> Marking:GrayZone:KeyIntDB and ub.marking.sts <> Marking:Ungrouped:KeyIntDB no-error .
                                    if available (ub.marking) then 
                                    do:
                                        /*Не входит*/
                                        message "Разгруппировать упаковки?"
                                            view-as alert-box question buttons yes-no update ungroup.
                                        if ungroup then 
                                        do:
                                            if tree:UnGroupUTD(buf_utd-marking-lines.mark, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.db-num) then 
                                            do:
                                                message "Упаковка с маркой " + buf_utd-marking-lines.mark + " разгруппирована."
                                                    view-as alert-box.
                                            end.
                                            /* Разгруппируем упаковки в tt-таблице */
                                            run ungroupTT in this-procedure (ub.marking.mark).
                                            /* Проставим статус "Проверен" у просканированной марки */
                                            find first X_marking-line where X_marking-line.mark = buf_marking.mark no-error .
                                            if available (X_marking-line) then 
                                            do:
                                                X_marking-line.stts-utd = StatusTHName(Marking:Checked_:KeyIntDB) .
                                                X_marking-line.sts-utd = Marking:Checked_:KeyIntDB .
                                                buf_utd-marking-lines.sts = Marking:Checked_:KeyIntDB .
                                            end.
                                            br-mark :refresh().
                                            {&OPEN-QUERY-br-mark-item}
                                            br-mark-item:refresh () no-error .
                                        /*              end.*/
                                        end. /*if ungroup then*/ 
                                        else 
                                        do:
                                            F-text = "                            Просканируйте марку" .
                                            display F-text with frame {&frame-name} .
                                            v-mark:screen-value = "" .
                                            v-mark = "" .
                                            return no-apply.
                                        end.
                                    end.
                                    else
                                    do:
                                        /*Блок имеет статус Серая зона или Разгруппирован*/
                                        if can-find (first ub.marking where ub.marking.mark = buf_marking.mark-parent and ub.marking.sts = Marking:GrayZone:KeyIntDB) then 
                                        do:
                                            /*Если серая зона*/
                                            message " Марка входит в состав упаковки c серой зоной, разгруппировать упаковки?"
                                                view-as alert-box question buttons yes-no update ungroup.
                                            if ungroup then 
                                            do:
                                                if tree:UnGroupUTD(buf_utd-marking-lines.mark, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.db-num) then 
                                                do:
                                                    message "Упаковка с маркой " + buf_utd-marking-lines.mark + " разгруппирована."
                                                        view-as alert-box.
                                                end.
  
                                            end.
                                            else 
                                            do:
                                                F-text = "                            Просканируйте марку" .
                                                display F-text with frame {&frame-name} .
                                                v-mark:screen-value = "" .
                                                v-mark = "" .
                                                return no-apply.
                                            end.
                                        end.
                                        else 
                                        do:
                                            /*Если Разгруппирован*/
                                            for first X_marking-line exclusive-lock where X_marking-line.mark begins v-marking:
                                                X_marking-line.sts-utd = Marking:Checked_:KeyIntDB .
                                                X_marking-line.stts-utd = StatusTHName(Marking:Checked_:KeyIntDB) .
                                            end.
                                            find first bf_utd-marking-lines exclusive-lock where bf_utd-marking-lines.mark = buf_utd-marking-lines.mark and bf_utd-marking-lines.db-num = buf_utd-marking-lines.db-num and
                                                bf_utd-marking-lines.doc-id = buf_utd-marking-lines.doc-id no-error .
                                            if available (bf_utd-marking-lines) then 
                                            do:
                                                bf_utd-marking-lines.sts   = X_marking-line.sts-utd .
                                                run setCheckedStatusForParentMarks(X_marking-line.mark-parent, buf_utd-marking-lines.db-num, buf_utd-marking-lines.doc-id).
                                            end.  
                                            {&OPEN-QUERY-br-mark-item}
                                            F-text = "                            Просканируйте марку" .
                                            display F-text with frame {&frame-name} .
                                        end.
                                    end.
                                end.
                            end.        
                            if tree:LevelDownUTD(buf_utd-marking-lines.mark, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.db-num) then 
                            do:
                                tree:StatusDownUTD(buf_utd-marking-lines.mark, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.db-num, Marking:Checked_:KeyIntDB) .
                                for each X_marking-line exclusive-lock,
                                    first bf_utd-marking-lines no-lock where 
                                          bf_utd-marking-lines.db-num = buf_utd-marking-lines.db-num 
                                      and bf_utd-marking-lines.doc-id = buf_utd-marking-lines.doc-id
                                      and bf_utd-marking-lines.mark   = X_marking-line.mark
                                :  /* обновим статусы во временной таблице */
                                    
                                    X_marking-line.sts-utd = bf_utd-marking-lines.sts .
                                    X_marking-line.stts-utd = StatusTHName(X_marking-line.sts-utd) .
                                end.
                            end.
                            else do:
                              assign
                                buf_utd-marking-lines.sts = Marking:Checked_:KeyIntDB
                              .                                
                            end.
                            
                            for each X_marking-line exclusive-lock,
                                first bf_utd-marking-lines no-lock where 
                                      bf_utd-marking-lines.db-num = buf_utd-marking-lines.db-num 
                                  and bf_utd-marking-lines.doc-id = buf_utd-marking-lines.doc-id
                                  and bf_utd-marking-lines.mark   = X_marking-line.mark
                            :  /* обновим статусы во временной таблице */
                              X_marking-line.sts-utd = bf_utd-marking-lines.sts .
                              X_marking-line.stts-utd = StatusTHName(X_marking-line.sts-utd) .
                            end.
 
                            if tree:checkedAllMarksOfUpakUTD(X_marking.mark, buf_utd-marking-lines.db-num, buf_utd-marking-lines.doc-id)
                            then do:
                              /* Проверим, если все марки упаковки, отсканированной марки, проверены, */
                              /* то надо сменить локальный статус упаковки на "Проверен"              */
                              assign
                                X_marking.sts-utd = Marking:Checked_:KeyIntDB .
                                X_marking.stts-utd = StatusTHName(Marking:Checked_:KeyIntDB)
                              .
                            end.

                            for first bf_utd-marking-lines exclusive-lock where bf_utd-marking-lines.mark = buf_utd-marking-lines.mark and 
                                bf_utd-marking-lines.db-num = buf_utd-marking-lines.db-num and 
                                bf_utd-marking-lines.doc-id = buf_utd-marking-lines.doc-id:
                                if bf_utd-marking-lines.doc-level = 1 then bf_utd-marking-lines.sts   = X_marking.sts-utd .
                            end.

                        end.
                        v-mark:screen-value = "" .
                        v-mark = "" . 
                    end.
                end.
                br-mark :refresh().
                reposition br-mark to recid recid_mark no-error .
                /*                {&OPEN-BROWSERS-IN-QUERY-d-mark}*/
                br-mark-item:refresh () no-error .
            /*        reposition br-mark-item to recid recid_mark no-error .*/
            /*        {&OPEN-QUERY-br-mark-item}                            */
            end.
            else 
            do:
                /*По нижнему интерфейсу*/
                find first X_marking-line exclusive-lock where X_marking-line.mark begins v-marking no-error .
                if available (X_marking-line) then
                do:
                    recid_mark = recid (X_marking-line) .
                    if X_marking-line.sts-utd = Marking:Checked_:KeyIntDB then
                    do:
                        F-text = "            Марка уже проверена, просканируйте следующую" .
                        display F-text with frame {&frame-name}.
                        /*            F-text = "            Марка уже проверена, просканируйте следующий" .*/
                        /*            display F-text with frame {&frame-name}.                             */
                        v-mark:screen-value = "" .
                        v-mark = "" . 
                        return no-apply.
                    end.
                    else
                    do:
                        assign
                            X_marking-line.sts-utd  = Marking:Checked_:KeyIntDB
                            X_marking-line.stts-utd = StatusTHName(Marking:Checked_:KeyIntDB)
                            .
                        find first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark = X_marking-line.mark and buf_utd-marking-lines.db-num = X_marking-line.db-num and
                            buf_utd-marking-lines.doc-id = X_marking-line.doc-id no-error .
                        if available (buf_utd-marking-lines) then 
                        do: 
                            if buf_utd-marking-lines.doc-level > 1 then 
                            do:
                                if tree:LevelUpUTD(buf_utd-marking-lines.mark, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.db-num) then 
                                do:
                                    message "Разгруппировать упаковки?"
                                        view-as alert-box question buttons yes-no update ungroup.
                                    if ungroup then 
                                    do:
                                        if tree:UnGroupUTD(buf_utd-marking-lines.mark, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.db-num) then 
                                        do:
                                            message "Упаковка с маркой " + buf_utd-marking-lines.mark + " разгруппирована."
                                                view-as alert-box.
                                        end.
                                    end.  
                                end.  
                            end.        
                            if tree:LevelDownUTD(buf_utd-marking-lines.mark, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.db-num) then 
                            do:
                                tree:StatusDownUTD(buf_utd-marking-lines.mark, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.db-num, Marking:Checked_:KeyIntDB) .
                            end.
                            for first bf_utd-marking-lines exclusive-lock where bf_utd-marking-lines.mark = buf_utd-marking-lines.mark and bf_utd-marking-lines.db-num = buf_utd-marking-lines.db-num and
                                bf_utd-marking-lines.doc-id = buf_utd-marking-lines.doc-id:
                                bf_utd-marking-lines.sts   = X_marking-line.sts-utd .  
                            end.  
 
                        end.           
                        v-mark:screen-value = "" .
                        v-mark = "" . 
                    end.
                    br-mark-item :refresh().
                    reposition br-mark-item to recid recid_mark no-error .
                    v-mark:screen-value = "" .
                    v-mark = "" . 
                end.
                else 
                do:
                    f-text = "              Марка не найдена в документе" .
                    display F-text with frame {&frame-name}.
                    v-mark = "" .
                    v-mark:screen-value = "" .
                    return no-apply .
                end.  
            end.     
        end.
    end.
    else 
    do:
        find first X_marking no-lock where X_marking.mark begins v-marking and X_marking.doc-level = 1 no-error .
        if available (X_marking) then
        do:
            recid_mark = recid (X_marking) .
            reposition br-mark to recid recid_mark no-error .
        end.
        else 
        do:  
            find first X_marking-line exclusive-lock where X_marking-line.mark begins v-marking no-error .
            if available (X_marking-line) then
            do:
                recid_mark1 = recid (X_marking-line) .
                reposition br-mark-item to recid recid_mark1 no-error .
                if error-status:error then 
                do:
                    f-text = "            Марка не отображена в браузере" .
                    display F-text with frame {&frame-name}.
                end.  
            end.
            else 
            do:
                f-text = "              Марка не найдена в документе" .
                display F-text with frame {&frame-name}.
            end. 
        end.
    end.    
    v-mark:screen-value = "" .
    v-mark = "" .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE scan-bar-code d-mark 
PROCEDURE scan-bar-code :
    define variable v_list      as character no-undo .
    define variable ii          as integer   no-undo .
    define variable v-marking   as character no-undo .
    define variable recid_mark1 as integer   no-undo .
    define variable v-GTIN      as character no-undo .
    define variable v-gds-code  as integer   no-undo .
    define VARIABLE vRecKeyLine as character no-undo .
    define buffer gray_marking                for ub.marking .
    define buffer gray_unit-marking           for ub.marking .
    define buffer gray_utd-marking-lines      for ub.utd-marking-lines .
    define buffer gray_unit_utd-marking-lines for ub.utd-marking-lines .
    define buffer buf_utd-lines               for ub.utd-lines .
    define buffer buf_utd-marking-lines       for ub.utd-marking-lines .
    define buffer X_utd-lines                 for tt-utd-lines .
    define buffer buf_utd-err                 for ub.utd-err .
    define buffer un_utd-marking-lines        for ub.utd-marking-lines .
    
    
    f-text = "" .
    f-text:screen-value in frame {&frame-name} = "" .
    /*    if v-marking = "" or v-marking = ? then RETurn no-apply .*/
    ASSIGN 
        v_list = 'Ё,Й,Ц,У,К,Е,Н,Г,Ш,Щ,З,Х,Ъ,Ф,Ы,В,А,П,Р,О,Л,Д,Ж,Э,Я,Ч,С,М,И,Т,Ь,Б,Ю':U .

    /*проверка на русские буквы*/
    do ii = 1 to length (v-mark):
        if LOOKUP( SUBSTRING( v-mark, ii, 1 ), v_list )  > 1 then
        do:
            message "Не корректно считан штрих-код, перед считыванием переключите клавиатуру на английскую раскладку."
                view-as alert-box.
            v-mark:screen-value = "" .
            v-mark = "" . 
            return .  
        end.
    end.
       mMRCCode  = yes.

   v-marking = GetCodeIdent(v-mark) .
   mMRCCode = no.
   if v-marking <> "" and v-marking <> ? then 
   do:
      v-mark = v-marking .
   end.   

/*    if p-mode <> {&lookup} then                                                                                                                                                                 */
/*    do:                                                                                                                                                                                         */
/*            find first X_marking exclusive-lock where X_marking.mark = v-bar-code no-error .                                                                                                    */
/*            if available (X_marking) then                                                                                                                                                       */
/*            do:                                                                                                                                                                                 */
/*                for first buf_utd-marking-lines no-lock where buf_utd-marking-lines.doc-id = X_marking.doc-id                                                                                   */
/*                    and buf_utd-marking-lines.db-num = X_marking.db-num                                                                                                                         */
/*                    and buf_utd-marking-lines.mark = X_marking.mark,                                                                                                                            */
/*                    first buf_utd-lines no-lock where buf_utd-lines.db-num = buf_utd-marking-lines.db-num                                                                                       */
/*                    and buf_utd-lines.doc-id = buf_utd-marking-lines.doc-id                                                                                                                     */
/*                    and buf_utd-lines.LineNum = buf_utd-marking-lines.LineNum:                                                                                                                  */
/*                    run gen-key-rec ("utd-lines",                                                                                                                                               */
/*                        input  buffer buf_utd-lines:handle,                                                                                                                                     */
/*                        output vRecKeyLine).                                                                                                                                                    */
/*                                                                                                                                                                                                */
/*                    find first buf_utd-err no-lock where buf_utd-err.doc-id = buf_utd-lines.doc-id and buf_utd-err.db-num = buf_utd-lines.db-num and buf_utd-err.reckey = vRecKeyLine no-error .*/
/*                    if available (buf_utd-err) then                                                                                                                                             */
/*                    do:                                                                                                                                                                         */
/*                        F-text = "Товар не подлежит приемке, т.к. не прошел проверку на корректность" .                                                                                         */
/*                        display F-text with frame {&frame-name}.                                                                                                                                */
/*                        v-bar-code:screen-value = "" .                                                                                                                                          */
/*                        v-bar-code = "" .                                                                                                                                                       */
/*                        return no-apply.                                                                                                                                                        */
/*                    end. /*if available (buf_utd-err) then */                                                                                                                                   */
/*                                                                                                                                                                                                */
/*                end. /*for first buf_utd-marking-lines no-lock where buf_utd-marking-lines.doc-id = X_marking.doc-id*/                                                                          */
/*                recid_mark = recid (X_marking) .                                                                                                                                                */
/*                if X_marking.sts-utd = Marking:Checked_:KeyIntDB then                                                                                                                           */
/*                do:                                                                                                                                                                             */
/*                    f-text = "          Штрих-код уже проверен, просканируйте следующий" .                                                                                                      */
/*                    display F-text with frame {&frame-name}.                                                                                                                                    */
/*                    v-bar-code:screen-value = "" .                                                                                                                                              */
/*                    v-bar-code = "" .                                                                                                                                                           */
/*                    return no-apply.                                                                                                                                                            */
/*                end. /*if X_marking.sts-utd = Marking:Checked_:KeyIntDB then*/                                                                                                                  */
/*                else                                                                                                                                                                            */
/*                do:                                                                                                                                                                             */
/*                    if X_marking.sts = Marking:MarkError:KeyIntDB  then                                                                                                                         */
/*                    do:                                                                                                                                                                         */
/*                        F-text = "Товар не подлежит приемке, т.к. не прошел проверку на корректность" .                                                                                         */
/*                        display F-text with frame {&frame-name}.                                                                                                                                */
/*                        v-bar-code:screen-value = "" .                                                                                                                                          */
/*                        v-bar-code = "" .                                                                                                                                                       */
/*                        return no-apply.                                                                                                                                                        */
/*                    end. /*if X_marking.sts = Marking:MarkError:KeyIntDB  then do:*/                                                                                                            */
/*                                                                                                                                                                                                */
/*                    find first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark = X_marking.mark and buf_utd-marking-lines.db-num = X_marking.db-num and                   */
/*                        buf_utd-marking-lines.doc-id = X_marking.doc-id no-error .                                                                                                              */
/*                    if available (buf_utd-marking-lines) then                                                                                                                                   */
/*                    do:                                                                                                                                                                         */
/*                                assign                                                                                                                                                          */
/*                                    X_marking.sts-utd = Marking:Checked_:KeyIntDB .                                                                                                             */
/*                                    X_marking.stts-utd = StatusTHName(Marking:Checked_:KeyIntDB)                                                                                                */
/*                                    .                                                                                                                                                           */
/*                            for first bf_utd-marking-lines exclusive-lock where bf_utd-marking-lines.mark = buf_utd-marking-lines.mark and                                                      */
/*                                bf_utd-marking-lines.db-num = buf_utd-marking-lines.db-num and                                                                                                  */
/*                                bf_utd-marking-lines.doc-id = buf_utd-marking-lines.doc-id:                                                                                                     */
/*                                if bf_utd-marking-lines.doc-level = 1 then bf_utd-marking-lines.sts   = X_marking.sts-utd .                                                                     */
/*                            end.                                                                                                                                                                */
/*                                                                                                                                                                                                */
/*                        end.                                                                                                                                                                    */
/*                        v-bar-code:screen-value = "" .                                                                                                                                          */
/*                        v-bar-code = "" .                                                                                                                                                       */
/*                    end.                                                                                                                                                                        */
/*                                                                                                                                                                                                */
/*                br-bar-code :refresh().                                                                                                                                                         */
/*                reposition br-bar-code to recid recid_mark no-error .                                                                                                                           */
/*                                                                                                                                                                                                */
/*            end.                                                                                                                                                                                */
/*    end.                                                                                                                                                                                        */
/*    else                                                                                                                                                                                        */
/*    do:                                                                                                                                                                                         */
        find first X_marking no-lock where X_marking.mark begins v-mark and X_marking.doc-level = 1 no-error .
        if available (X_marking) then
        do:
            recid_mark = recid (X_marking) .
            reposition br-bar-code to recid recid_mark no-error .
        end.
        v-mark:screen-value = "" .
        v-mark = "" .
/*    end.*/
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-any-key Dialog-Frame 
PROCEDURE proc-any-key :
    if not v-manual
        then
        if v-scan-str = ""
            then etime(yes).
        else
            if etime > 700
                then v-scan-str = "".
    v-scan-str = v-scan-str + last-event:label.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE checkPriPerem Dialog-Frame 
PROCEDURE checkPriPerem :
    define input  parameter iMark as character no-undo.
    define output parameter oMsg  as character no-undo.
    
    define buffer buf_trn-doc          for ub.trn-doc. 
    define buffer buf_marking          for ub.marking. 
    define buffer parent_marking       for ub.marking. 
    define buffer buf_marking-lines    for ub.marking-lines. 
    define buffer buf_tt-marking       for tt-marking-lines.
    
/*run gbl/inidebug.p.*/
    find first X_marking exclusive-lock where X_marking.mark begins iMark no-error .
    if available (X_marking) then
    do: 
        if X_marking.sts-utd = Marking:Checked_:KeyIntDB then
        do:
            if x_marking.unit-ext <> "UNIT" then 
            do:
                oMsg = "               Упаковка уже проверена полностью".
                return.              
            end.
            else 
            do:  
                oMsg = "            Марка уже проверена, просканируйте следующую".
                display F-text with frame {&frame-name}.
                return.
            end.  
        end.  
        find first buf_marking exclusive-lock where
                   buf_marking.mark begins iMark
             no-error.
        if buf_marking.sts = Marking:Checked_:KeyIntDB or
           buf_marking.sts = Marking:SaleLock:KeyIntDB or
           buf_marking.sts = Marking:ReturnLock:KeyIntDB then
        do:
            oMsg = "Марка проверена ранее".
            return.
        end.
        if buf_marking.sts = Marking:FreeZone:KeyIntDB then
        do:
          for each buf_marking-lines no-lock where 
                   buf_marking-lines.mark      = X_marking.mark 
               and buf_marking-lines.obj-type  = X_marking.obj-type 
               and buf_marking-lines.obj-code  = X_marking.obj-code 
               and buf_marking-lines.gds-code  = X_marking.gds-code
               and buf_marking-lines.out-code  <> X_marking.out-code,
              first buf_trn-doc no-lock where
                    buf_trn-doc.doc-code = buf_marking-lines.out-code
                and buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem}:
            oMsg = "Марка уже принята ранее по другому документу внутреннего прихода".
            return.
          end.
        end.

        find first buf_marking-lines exclusive-lock where 
                   buf_marking-lines.mark      = X_marking.mark 
               and buf_marking-lines.obj-type  = X_marking.obj-type 
               and buf_marking-lines.obj-code  = X_marking.obj-code 
               and buf_marking-lines.gds-code  = X_marking.gds-code 
               and buf_marking-lines.out-code  = X_marking.out-code no-error .

        if buf_marking-lines.doc-level > 1 and 
           avail buf_marking
        then do:
          /*смотрим входит ли марка в состав блока со статусом Серая зона или Разгруппирован*/
          for first parent_marking no-lock where 
                    parent_marking.mark = buf_marking.mark-parent 
                and parent_marking.sts <> Marking:GrayZone:KeyIntDB 
                and parent_marking.sts <> Marking:Ungrouped:KeyIntDB
          :
            oMsg = "Марка входит в состав упаковки, просканируйте марку упаковки.".
            return.
          end.
        end.
        
        assign
          buf_marking.sts       = Marking:Checked_:KeyIntDB
/*          buf_marking.sts       = Marking:DeliveryControl:KeyIntDB*/
          x_marking.sts         = buf_marking.sts
          x_marking.sts-utd     = buf_marking.sts
          buf_marking-lines.sts = buf_marking.sts
          X_marking.stts-utd    = marking:GetLabel(buf_marking.sts)
          X_marking.stts        = marking:GetLabel(buf_marking.sts)
        .
        run setStatusForChildMarks in this-procedure (buf_marking.mark, buf_marking.sts).
    end.
END.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ungroupTT Dialog-Frame 
PROCEDURE ungroupTT:
    define input parameter iMark as character no-undo.
    
    define buffer buf_tt-marking-lines for tt-marking-lines. 

    for first buf_tt-marking-lines exclusive-lock where 
              buf_tt-marking-lines.mark = iMark
    :
      buf_tt-marking-lines.stts = StatusTHName(Marking:Ungrouped:KeyIntDB) .
      buf_tt-marking-lines.stts-utd = StatusTHName(Marking:Ungrouped:KeyIntDB) .
      buf_tt-marking-lines.sts = Marking:Ungrouped:KeyIntDB .
      buf_tt-marking-lines.sts-utd = Marking:Ungrouped:KeyIntDB .
      run ungroupTT in this-procedure (buf_tt-marking-lines.mark-parent).
    end.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setCheckedStatusForParentMarks Dialog-Frame 
PROCEDURE setCheckedStatusForParentMarks:
  /* Смена статуса родительских маркок по иерархии на проверен, если все ее "дети" проверены */
  /* вынесено из кода для иерархичности */
  define input parameter iMark  as character no-undo.
  define input parameter iDbNum as integer no-undo.
  define input parameter iDocId as integer no-undo.
  
  define buffer parent_utd-marking-lines for ub.utd-marking-lines.

  if iMark = "" then return.
    
  find first parent_utd-marking-lines exclusive-lock where
             parent_utd-marking-lines.db-num = iDbNum
         and parent_utd-marking-lines.doc-id = iDocId 
         and parent_utd-marking-lines.mark = iMark no-error .
  if available (parent_utd-marking-lines) then 
  do:
    find first tt-marking-lines where 
               parent_utd-marking-lines.mark begins tt-marking-lines.mark-parent 
           and tt-marking-lines.mark-parent <> "" 
           and tt-marking-lines.sts-utd = Marking:PendingVerification:KeyIntDB no-error .
    if not available (tt-marking-lines) then 
    do:
        /* Проверим, если все марки упаковки проверены, то надо сменить локальный статус упаковки на "Проверен" */
        if tree:checkedAllMarksOfUpakUTD(parent_utd-marking-lines.mark, iDbNum, iDocId)
        then do:
          parent_utd-marking-lines.sts = Marking:Checked_:KeyIntDB .
          find first X_marking where X_marking.mark = parent_utd-marking-lines.mark no-error .
          if available (X_marking) then 
          do:
            X_marking.sts-utd = Marking:Checked_:KeyIntDB .
            X_marking.stts-utd = StatusTHName(Marking:Checked_:KeyIntDB) .
          end.    
          run setCheckedStatusForParentMarks(X_marking.mark-parent, iDbNum, iDocId).
        end.
    end. 
    else 
    do:
        find first X_marking where X_marking.mark = parent_utd-marking-lines.mark no-error .
        if available (X_marking) then recid_mark = recid(X_marking) .
    end.       
  end.      

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setStatusForChildMarks Dialog-Frame 
PROCEDURE setStatusForChildMarks:
  /* Смена статуса дочерних марок на родительский статус */
  /* вынесено из кода для иерархичности */
  define input parameter iMark  like ub.marking.mark no-undo.
  define input parameter iSts   like ub.marking.sts  no-undo.
  
  define buffer buf_marking-child    for ub.marking. 
  define buffer buf_marking-lines    for ub.marking-lines. 

  for each buf_marking-child where
           buf_marking-child.mark-parent = iMark
    exclusive-lock:
    find first buf_marking-lines exclusive-lock where 
               buf_marking-lines.mark      = buf_marking-child.mark 
           and buf_marking-lines.obj-type  = X_marking.obj-type 
           and buf_marking-lines.obj-code  = X_marking.obj-code 
           and buf_marking-lines.gds-code  = X_marking.gds-code 
           and buf_marking-lines.out-code  = X_marking.out-code no-error .
    find first X_marking-line exclusive-lock where X_marking-line.mark begins buf_marking-child.mark no-error .
    assign
      X_marking-line.sts      = iSts
      X_marking-line.sts-utd  = iSts
      X_marking-line.stts-utd = marking:GetLabel(iSts)
      X_marking-line.stts     = marking:GetLabel(iSts)
      buf_marking-lines.sts   = iSts
      buf_marking-child.sts   = iSts
    .
    run setStatusForChildMarks in this-procedure (buf_marking-child.mark, iSts).
  end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

