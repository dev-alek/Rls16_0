&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE NEW SHARED BUFFER buf_abc-analysis FOR ub.abc-analysis.
DEFINE NEW SHARED BUFFER Buf_abc-analysis-goods FOR ub.abc-analysis-goods.
DEFINE NEW SHARED BUFFER Buf_abcxyz-analysis FOR ub.abcxyz-analysis.
DEFINE NEW SHARED BUFFER buf_abcxyz-analysis-goods FOR ub.abcxyz-analysis-goods.
DEFINE BUFFER buf_assortment-matrix FOR ub.assortment-matrix.
DEFINE BUFFER buf_assortment-matrix-goods FOR ub.assortment-matrix-goods.
DEFINE NEW SHARED BUFFER buf_goods FOR ub.goods.
DEFINE NEW SHARED BUFFER Buf_xyz-analysis FOR ub.xyz-analysis.
DEFINE NEW SHARED BUFFER buf_xyz-analysis-goods FOR ub.xyz-analysis-goods.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр результатов АВС + XYZ анализа

Автор: Чернова Светлана Александровна
Дата создания: 04/26/05
Author: Svetlana Chernova
Creation date: 04/26/05

*/
define input  parameter parParentProc AS WIDGET-HANDLE NO-UNDO.
define input  parameter v-id as integer   no-undo .
define input  parameter v-db-num as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр результатов АВС + XYZ анализа".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i   }
{ gbl/waitfram.i }
{ cmp/obj-list.i  new  }
{ cmp/gds-list.i gds-list def "new shared"}
{ cmp/doc-list.i doc-list def "new shared" }
{ gbl/cur-time.i }
{ ref/def-hash.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i  }
{ rep/gn-extp.i  }  /*Процедуры для определения имени расширенного типа документов*/
{ ref/abcxyzi.i abc }
{ ref/abcxyzi.i xyz }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/fltopend.i defproc }
{ cmp/mrk-strf.i }
{ ref/gds-matl.i }
{ str/ascorrm.i  }
{ gbl/assmatat.i }   /* Библиотека для работы с атрибутами АМ */
{ gbl/thbj-def.i }
{ ref/ass-mat.i &DEF_PROC=YES}    /* Процедуры и функции для работы с АМ (по задаче "Процент отклонения матрицы от шаблона") */

define variable filter-point as character no-undo init "Просмотр АВС анализа" .
define variable filter-point0 as character no-undo init "Просмотр_АВС_анализа" .
define variable sort-column-name as character no-undo .
define variable doc-rec as recid no-undo .


define variable v-izt      as character no-undo .
define variable v-Acc-mat  as character no-undo .
define variable v-Amin     as character no-undo .
define variable v-obj-AssMin  as logical   no-undo .
define variable v-obj-igt     as character no-undo .


define variable rid-list   as character no-undo .

/* для F9 */
define variable list-mode as char  no-undo.  /* специально для сохранения list-mode */
define variable doc-mode  as char  no-undo.  /* специально для сохранения doc-mode */
define variable line-rec  as recid no-undo.  /* специально для сохранения line-rec */
define variable gds-rec   as recid no-undo.  /* специально для сохранения gds-rec */
define variable prt-rec   as recid no-undo.  /* специально для сохранения prt-rec */
define variable line-mode as char  no-undo.  /* специально для сохранения line-mode */

&scop col-p1      mark-string(recid( buf_abcxyz-analysis-goods),rid-list)
&scop dyn_col-p1  substitute('dynamic-function(&1mark-string&1, recid(buf_abcxyz-analysis-goods), &1&2&1)', ~{&double-quote~}, rid-list)
&scop col-p2    buf_goods.artic
&scop col-p3    buf_goods.gds-name
&scop col-p4    buf_abcxyz-analysis-goods.abcg-abc
&scop col-p5    Buf_abcxyz-analysis-goods.xyzg-xyz
&scop col-p6    v-izt
&scop col-p7    v-Acc-mat
&scop col-p8    v-Amin
&scop col-p9    Buf_abc-analysis-goods.abcg-temp-sale-goods
&scop col-p10   Buf_abc-analysis-goods.abcg-order-qnty

&scop col-l1  '*! ! '
&scop col-l2  'Артикул! ! '
&scop col-l3  'Название! ! '
&scop col-l4  'A!B!C'
&scop col-l5  'X!Y!Z'
&scop col-l6  'ИЖТ! ! '
&scop col-l7  'Ассорт.!матрица! '
&scop col-l8  'Ассорт.!min! '
&scop col-l9 'Темп!продаж! '
&scop col-l10  'Заказанное!количество!товара'



find first buf_abcxyz-analysis no-lock where
           buf_abcxyz-analysis.abcx-id = v-id and
           buf_abcxyz-analysis.db-num = v-db-num
            no-error .
if not available  buf_abcxyz-analysis then do:
   message vss-workfile vss-revision vss-description skip
          "Не найдена запись buf_abcxyz-analysis " skip
           v-id v-db-num skip
          return-value   skip
          error-status :get-message(1) .
   return.
end.



DEFINE VARIABLE v-ass-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Ассортиментная матрица"
      VIEW-AS TEXT
     SIZE 69.5 BY .67
     NO-UNDO.

define variable g-log as logical   no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-goods

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES Buf_abcxyz-analysis-goods buf_goods

/* Definitions for BROWSE BROWSE-goods                                  */
&Scoped-define FIELDS-IN-QUERY-BROWSE-goods mark-string(recid( buf_abcxyz-analysis-goods), rid-list) buf_goods.artic buf_goods.gds-name Buf_abcxyz-analysis-goods.abcg-abc Buf_abcxyz-analysis-goods.xyzg-xyz v-izt v-Amin v-Acc-mat
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-goods buf_goods.artic
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-goods buf_goods
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-goods buf_goods
&Scoped-define SELF-NAME BROWSE-goods
&Scoped-define QUERY-STRING-BROWSE-goods FOR EACH  Buf_abcxyz-analysis-goods NO-LOCK         WHERE Buf_abcxyz-analysis-goods.abcx-id = v-id and               Buf_abcxyz-analysis-goods.db-num = v-db-num, ~
               EACH  buf_goods of Buf_abcxyz-analysis-goods
&Scoped-define OPEN-QUERY-BROWSE-goods OPEN QUERY {&SELF-NAME}     FOR EACH  Buf_abcxyz-analysis-goods NO-LOCK         WHERE Buf_abcxyz-analysis-goods.abcx-id = v-id and               Buf_abcxyz-analysis-goods.db-num = v-db-num, ~
               EACH  buf_goods of Buf_abcxyz-analysis-goods       .
&Scoped-define TABLES-IN-QUERY-BROWSE-goods Buf_abcxyz-analysis-goods ~
buf_goods
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-goods Buf_abcxyz-analysis-goods
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-goods buf_goods


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-goods}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-cancel B-mark B-chg-izt B-add-AM B-del-AM ~
B-spis-ord B-Help B-add-AMin B-del-AMin B-ord B-print BROWSE-goods

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU POPUP-MENU-B-print
       MENU-ITEM m_goods        LABEL "Матрица"
              DISABLED
       MENU-ITEM m_obj          LABEL "Список"        .


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add-AM
     LABEL "Добавить в АМ"
     SIZE 16.5 BY 1 TOOLTIP "Добавить в ассортиментную матрицу по объекту".

DEFINE BUTTON B-add-AMin
     LABEL "Добавить в АМin"
     SIZE 16.5 BY 1 TOOLTIP "Добавить в ассортиментный минимум по объектам".

DEFINE BUTTON B-cancel AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-chg-izt
     LABEL "Изменить ИЖТ"
     SIZE 12.5 BY 1 TOOLTIP "Изменить ИЖТ".

DEFINE BUTTON B-del-AM
     LABEL "Удалить из АМ"
     SIZE 16 BY 1 TOOLTIP "Удалить из  ассортиментных матриц по объектам".

DEFINE BUTTON B-del-AMin
     LABEL "Удалить из АМin"
     SIZE 16 BY 1 TOOLTIP "Удалить из  ассортиментных минимумов по объектам".

DEFINE BUTTON B-Help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON B-ord
     LABEL "Новый заказ"
     SIZE 13.5 BY 1 TOOLTIP "Сформировать заказ".

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-spis-ord
     LABEL "Заказы"
     SIZE 13.5 BY 1 TOOLTIP "Список открытых заказов по отмеченным товарам".

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE new shared QUERY BROWSE-goods FOR
      Buf_abcxyz-analysis-goods,
      buf_goods SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-goods Dialog-Frame _FREEFORM
  QUERY BROWSE-goods NO-LOCK DISPLAY
      mark-string(recid( buf_abcxyz-analysis-goods), rid-list) COLUMN-LABEL "*! ! " FORMAT "X(1)":U
      buf_goods.artic                     COLUMN-LABEL "Артикул! ! " FORMAT "X(16)":U            WIDTH 10
      buf_goods.gds-name                 COLUMN-LABEL "Название! ! " FORMAT "X(50)":U        WIDTH 20
      Buf_abcxyz-analysis-goods.abcg-abc COLUMN-LABEL "A!B!C" FORMAT "X(1)":U
      Buf_abcxyz-analysis-goods.xyzg-xyz COLUMN-LABEL "X!Y!Z" FORMAT "X(1)":U
      v-izt      COLUMN-LABEL "ИЖТ! ! "           FORMAT "X(20)":U                                                WIDTH 10
      v-Amin     COLUMN-LABEL "Ассорт.!min! "     FORMAT "X(9)":U                                                 wIDTH 9
      v-Acc-mat  COLUMN-LABEL "Ассорт.!матрица! " FORMAT "X(9)":U                                                 WIDTH 9
      enable
          buf_goods.artic
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 20 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-cancel AT ROW 1 COL 1
     B-mark AT ROW 1 COL 15
     B-chg-izt AT ROW 1 COL 18
     B-add-AM AT ROW 1 COL 30.5
     B-del-AM AT ROW 1 COL 47
     B-spis-ord AT ROW 1 COL 63
     B-Help AT ROW 1 COL 88
     B-add-AMin AT ROW 2 COL 30.5
     B-del-AMin AT ROW 2 COL 47
     B-ord AT ROW 2 COL 63
     B-print AT ROW 2 COL 88
     BROWSE-goods AT ROW 3 COL 1
     SPACE(0.12) SKIP(0.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Просмотр результатов АВС + XYZ анализа"
         CANCEL-BUTTON B-cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_abc-analysis B "NEW SHARED" ? ub abc-analysis
      TABLE: Buf_abc-analysis-goods B "NEW SHARED" ? ub abc-analysis-goods
      TABLE: Buf_abcxyz-analysis B "NEW SHARED" ? ub abcxyz-analysis
      TABLE: buf_abcxyz-analysis-goods B "NEW SHARED" ? ub abcxyz-analysis-goods
      TABLE: buf_assortment-matrix B "?" ? ub assortment-matrix
      TABLE: buf_assortment-matrix-goods B "?" ? ub assortment-matrix-goods
      TABLE: buf_goods B "NEW SHARED" ? ub goods
      TABLE: Buf_xyz-analysis B "NEW SHARED" ? ub xyz-analysis
      TABLE: buf_xyz-analysis-goods B "NEW SHARED" ? ub xyz-analysis-goods
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-goods B-print Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU POPUP-MENU-B-print:HANDLE.

ASSIGN
       BROWSE-goods:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 3.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-goods
/* Query rebuild information for BROWSE BROWSE-goods
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
    FOR EACH  Buf_abcxyz-analysis-goods NO-LOCK
        WHERE Buf_abcxyz-analysis-goods.abcx-id = v-id and
              Buf_abcxyz-analysis-goods.db-num = v-db-num,
        EACH  buf_goods of Buf_abcxyz-analysis-goods
      .
     _END_FREEFORM
     _Options          = "NO-LOCK "
     _Where[1]         = "Buf_abc-analysis-goods.abc-id = v-id and Buf_abc-analysis-goods.db-num = v-db-num"
     _Query            is OPENED
*/  /* BROWSE BROWSE-goods */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Просмотр результатов АВС + XYZ анализа */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add-AM
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add-AM Dialog-Frame
ON CHOOSE OF B-add-AM IN FRAME Dialog-Frame /* Добавить в АМ */
DO:
  if num-entries( rid-list ) = 0 then do:
    message "Не выбраны товары !!!" view-as alert-box information .
    return no-apply.
  end.
  run proc-cgh-AM ( input true ) no-error .
  if error-status :error then
      message error-status :get-message(1)
          return-value
          "Ошибка вернулась из proc-cgh-Am"
          view-as alert-box error .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add-AMin
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add-AMin Dialog-Frame
ON CHOOSE OF B-add-AMin IN FRAME Dialog-Frame /* Добавить в АМin */
DO:
  if num-entries( rid-list ) = 0 then do:
    message "Не выбраны товары !!!" view-as alert-box information .
    return no-apply.
  end.
  run proc-cgh-Amin ( input true ) no-error .
  if error-status :error then
      message error-status :get-message(1)
          return-value
          "Ошибка вернулась из proc-cgh-Amin"
          view-as alert-box error .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg-izt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg-izt Dialog-Frame
ON CHOOSE OF B-chg-izt IN FRAME Dialog-Frame /* Изменить ИЖТ */
DO:
  if num-entries( rid-list ) = 0 then do:
    message "Не выбраны товары !!!" view-as alert-box information .
    return no-apply.
  end.
  run proc-chg-igt no-error .
  if error-status :error then
      message error-status :get-message(1)
          return-value
          "Ошибка вернулась из proc-chg-igt"
          view-as alert-box error .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del-AM
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del-AM Dialog-Frame
ON CHOOSE OF B-del-AM IN FRAME Dialog-Frame /* Удалить из АМ */
DO:
  if num-entries( rid-list ) = 0 then do:
    message "Не выбраны товары !!!" view-as alert-box information .
    return no-apply.
  end.
  run proc-cgh-AM ( input false ) no-error .
  if error-status :error then
      message error-status :get-message(1)
          return-value
          "Ошибка вернулась из proc-cgh-Am"
          view-as alert-box error .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del-AMin
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del-AMin Dialog-Frame
ON CHOOSE OF B-del-AMin IN FRAME Dialog-Frame /* Удалить из АМim */
DO:
  if num-entries( rid-list ) = 0 then do:
    message "Не выбраны товары !!!" view-as alert-box information .
    return no-apply.
  end.
  run proc-cgh-Amin ( input false ) no-error .
  if error-status :error then
      message error-status :get-message(1)
          return-value
          "Ошибка вернулась из proc-cgh-Amin"
          view-as alert-box error .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
    if available Buf_abcxyz-analysis-goods then do:
        { gbl/markstrn.i Buf_abcxyz-analysis-goods rid-list }

        g-log = browse-goods:refresh() .
        if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
            g-log = browse-goods:select-next-row ().
            apply "VALUE-CHANGED" to browse-goods in frame {&frame-name}.
        end.
        /*if num-entries( rid-list ) = 0
          then
              hide mark-num in frame {&frame-name}.
          else do:

          mark-num:screen-value in frame {&frame-name}  = string (num-entries( rid-list )) .
          enable mark-num with frame {&frame-name}.

        end.
        */
    end.

    apply "entry" to browse-goods in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-ord
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-ord Dialog-Frame
ON CHOOSE OF B-ord IN FRAME Dialog-Frame /* Новый заказ */
DO:
    /**/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
    run gbl/pop-up.p (self:handle, no) no-error.
    if error-status:error then return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-spis-ord
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-spis-ord Dialog-Frame
ON CHOOSE OF B-spis-ord IN FRAME Dialog-Frame /* Заказы */
DO:
define variable v-recid as character no-undo .
for each doc-list : delete doc-list. end.
  run cus/mdoclist.p ( rid-list ) .
  run cus/dord-doc.w (
  parParentProc
  ,""  /*bttns           */
  ,?   /*p-curr-obj-type */
  ,?   /*p-curr-obj-code */
  ,?   /*p-mode          */
  ,?   /*p-sts           */
  , input-output v-recid   /*p-rid-list      */
  ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-goods
&Scoped-define SELF-NAME BROWSE-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-goods Dialog-Frame
ON ROW-DISPLAY OF BROWSE-goods IN FRAME Dialog-Frame
DO:

find first buf_abc-analysis-goods no-lock where
           buf_abc-analysis-goods.abc-id =   buf_abcxyz-analysis.abc-id and
           buf_abc-analysis-goods.db-num =   buf_abcxyz-analysis.abc-db-num and
           buf_abc-analysis-goods.gds-code = buf_abcxyz-analysis-goods.gds-code no-error .
   if available  buf_abc-analysis-goods then do:
    run prt-goods-abc  in this-procedure
             ( input buf_abcxyz-analysis-goods.gds-code ,
               output v-izt,
               output v-Acc-mat ,
               output v-Amin
             ).
   end.
   else do:
      find first buf_xyz-analysis-goods no-lock where
                buf_xyz-analysis-goods.xyz-id =   buf_abcxyz-analysis.xyz-id and
                buf_xyz-analysis-goods.db-num =   buf_abcxyz-analysis.xyz-db-num and
                buf_xyz-analysis-goods.gds-code = buf_abcxyz-analysis-goods.gds-code no-error .
        if available  buf_xyz-analysis-goods then do:
          run prt-goods-xyz  in this-procedure
             ( input buf_abcxyz-analysis-goods.gds-code ,
               output v-izt,
               output v-Acc-mat ,
               output v-Amin
             ).
        end.
    end.
    if v-Amin = "входит" then  v-Amin:fgcolor  in browse browse-goods  = 4.
    if buf_abcxyz-analysis-goods.abcg-abc = "A" then
       assign
         {&col-p2}:fgcolor  in browse browse-goods  = 12
         {&col-p3}:fgcolor  in browse browse-goods  = 12
       .
    if buf_abcxyz-analysis-goods.abcg-abc = "B" then
       assign
         {&col-p2}:fgcolor  in browse browse-goods  = 9
         {&col-p3}:fgcolor  in browse browse-goods  = 9
       .
    if buf_abcxyz-analysis-goods.abcg-abc = "D" then
       assign
         {&col-p2}:fgcolor  in browse browse-goods  = 3
         {&col-p3}:fgcolor  in browse browse-goods  = 3
       .
    if buf_abcxyz-analysis-goods.abcg-abc = "E" then
       assign
         {&col-p2}:fgcolor  in browse browse-goods  = 5
         {&col-p3}:fgcolor  in browse browse-goods  = 5
       .
    if buf_abcxyz-analysis-goods.abcg-abc = "F" then
       assign
         {&col-p2}:fgcolor  in browse browse-goods  = 7
         {&col-p3}:fgcolor  in browse browse-goods  = 7
       .



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-goods Dialog-Frame
ON VALUE-CHANGED OF BROWSE-goods IN FRAME Dialog-Frame
DO:
  /* */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_goods Dialog-Frame
ON CHOOSE OF MENU-ITEM m_goods /* Матрица */
DO:
  run print-proc ( NO ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_obj Dialog-Frame
ON CHOOSE OF MENU-ITEM m_obj /* Список */
DO:
define buffer b_abc-analysis for ub.abc-analysis.

define variable v-user-name as character no-undo .
  { gbl/usrfulnm.i
    buf_abcxyz-analysis.abcx-who-create
    v-user-name
  }

 find first b_abc-analysis no-lock where
            b_abc-analysis.abc-id =  buf_abcxyz-analysis.abc-id and
            b_abc-analysis.db-num =  buf_abcxyz-analysis.abc-db-num no-error .

define buffer b_xyz-analysis for ub.xyz-analysis.
 find first b_xyz-analysis no-lock where
            b_xyz-analysis.xyz-id =  buf_abcxyz-analysis.xyz-id and
            b_xyz-analysis.db-num =  buf_abcxyz-analysis.xyz-db-num no-error .
if available b_xyz-analysis and
   available b_abc-analysis then
 run ref/prabcxyz.p
 (parParentProc
 ,recid(buf_abcxyz-analysis)
 ,recid(b_abc-analysis)
 ,recid(b_xyz-analysis)
 ,v-user-name).


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/setfltnm.i no-button }
{ gbl/app_help.i &disable_diasize=true }
{ gbl/f2.i browse-goods goods-recid init-gds-rec }
{ gbl/srt-clmd.i
  &browse-name   =  "browse-goods"
  &frame-name    =  "{&frame-name}"
  &table-name    =  "abcxyz-analysis-goods"
  &label-clmn_1  =  "{&col-l1}"
  &label-clmn_2  =  "{&col-l2}"
  &label-clmn_3  =  "{&col-l3}"
  &label-clmn_4  =  "{&col-l4}"
  &label-clmn_5  =  "{&col-l5}"
  &sort-clmn_1   =  "{&col-p1}"
  &dyn_sort-clmn_1   =  "{&dyn_col-p1}"
  &sort-clmn_2   =  "{&col-p2}"
  &sort-clmn_3   =  "{&col-p3}"
  &sort-clmn_4   =  "{&col-p4}"
  &sort-clmn_5   =  "{&col-p5}"
  &open-query    =  "run OpenBr (yes, no, '':U)."
  &open-query-otherwise = "run OpenBr (yes, no, '':U)."
  &sort-column-name     = "sort-column-name"
  &re-move-clmn         = "no"
  &mv-brw-default       = "no"
  }
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

 define variable loc#log as logical   no-undo .
 { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_ABC-XYZ_lookup':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    loc#log
  }
   if not loc#log then return .

   buf_goods.artic:resizable in browse BROWSE-goods = true .
   buf_goods.gds-name:resizable in browse BROWSE-goods = true .
   v-izt:resizable in browse BROWSE-goods = true .
   buf_goods.artic:read-only in browse BROWSE-goods = true .

   ASSIGN b-print:POPUP-MENU IN FRAME {&frame-name} = MENU POPUP-MENU-B-print:HANDLE.
   ASSIGN b-print:MENU-MOUSE = 1.


  RUN my_enable.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-prc Dialog-Frame
PROCEDURE calc-prc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter p-old as character no-undo .
define input  parameter p-new as character no-undo .
define input  parameter p-type as character no-undo .
define input  parameter p-all-sum as decimal   no-undo .
define input  parameter p-all-qnty as decimal   no-undo .
define input-output parameter  abc-prc-qnty  as decimal   no-undo .
define input-output parameter  abc-qnty      as decimal   no-undo .
define input-output parameter  abc-sum-prc   as decimal   no-undo .
define input-output parameter  abc-sum       as decimal   no-undo .
define input  parameter p-sum as decimal   no-undo .

if p-old  <> p-type and p-new <> p-type then return .

if p-old  = p-type then do:
    assign
      abc-qnty        = abc-qnty      - 1
      abc-sum         = abc-sum       - p-sum
      abc-sum-prc     = abc-sum  * 100 / p-all-sum
      abc-prc-qnty    = abc-qnty * 100 / p-all-qnty
    .

end.

if p-new  = p-type then do:
    assign
      abc-qnty        = abc-qnty      + 1
      abc-sum         = abc-sum       + p-sum
      abc-sum-prc     = abc-sum  * 100 / p-all-sum
      abc-prc-qnty    = abc-qnty * 100 / p-all-qnty
    .
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
  ENABLE B-cancel B-mark B-chg-izt B-add-AM B-del-AM B-spis-ord B-Help
         B-add-AMin B-del-AMin B-ord B-print BROWSE-goods
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
gds-rec = recid(buf_goods) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE make-gds-list Dialog-Frame
PROCEDURE make-gds-list :
do
  on error undo, return error return-value
  :
define buffer buf2_goods for ub.goods.
define buffer buf2_abc-analysis-goods for ub.abcxyz-analysis-goods.
define variable v-kol as integer   no-undo .
define variable i as integer   no-undo .

  /* формирование gds-list */
run waitfram-show ( "Подготовка временных таблиц.... ") .
    for each gds-list : delete gds-list. end.
    v-kol = num-entries( rid-list ) .
    repeat i = 1 to v-kol :
      find first buf2_abc-analysis-goods no-lock where recid(buf2_abc-analysis-goods) = integer(entry(i,rid-list)) no-error .
      if available buf2_abc-analysis-goods then do:
          find first buf2_goods no-lock where buf2_goods.gds-code = buf2_abc-analysis-goods.gds-code no-error .
          if available buf2_goods then do:
              create gds-list.
              BUFFER-COPY buf2_goods TO gds-list .

          end.
      end.
    end.
 run waitfram-hide.

  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my_enable Dialog-Frame
PROCEDURE my_enable :
define buffer Buf2_abc-analysis-obj for ub.abc-analysis-obj.

  ENABLE B-Cancel
         B-mark
         B-chg-izt
         B-add-AM
         B-del-AM
         /*B-spis-ord*/
         /*b-ord*/
         B-Help
         B-add-AMin
         B-del-AMin
         B-print
         BROWSE-goods

      WITH FRAME Dialog-Frame.
      hide
      B-spis-ord
      b-ord
      in frame {&frame-name} .


  view frame dialog-frame.
  FOR EACH Buf2_abc-analysis-obj WHERE
           Buf2_abc-analysis-obj.abc-id = Buf_abcxyz-analysis.abc-id AND
           Buf2_abc-analysis-obj.db-num = Buf_abcxyz-analysis.abc-db-num
  no-lock :
    run create_obj-list (Buf2_abc-analysis-obj.obj-type , Buf2_abc-analysis-obj.obj-code ) .
  end.

  frame {&frame-name}:title = buf_abcxyz-analysis.abcx-name .

  run openbr (yes, no, '':u).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OPenbr Dialog-Frame
PROCEDURE OPenbr :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
define buffer buff_contract for contract.
define variable loc_contract-code as character no-undo .

{&SetCursorWait}
define variable sort-column-phrase as character no-undo .

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





&scop flt-open-open-query OPEN QUERY browse-goods FOR EACH  Buf_abcxyz-analysis-goods NO-LOCK

&scop flt-open-dyn_open-query  FOR EACH Buf_abcxyz-analysis-goods

&scop flt-open-query-handle query BROWSE-goods:handle

&scop flt-open-find-buffer-name Buf_abcxyz-analysis-goods



&scop flt-open-open-query-tail , EACH  buf_goods OF Buf_abcxyz-analysis-goods NO-LOCK

&scop flt-open-query-was-opened     l-query-was-opened

&scop flt-open-sort-column-phrase   sort-column-phrase

&scop flt-open-call-point           filter-point

&scop flt-open-set-filter-name      set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-query               p-open-query

&scop flt-open-table-name          Buf_abcxyz-analysis-goods

&scop flt-open-search-option       no-lock

&scop flt-open-find-next           p-find-next

&scop flt-open-find-recid          doc-rec

&scop flt-open-find-condition       p-find-condition

&scop flt-open-find-buffer-def      define buffer Buf_abcxyz-analysis-goods for abcxyz-analysis-goods.

&scop flt-open-debug-file

&scop flt-open-waitfram             true

define variable l-open-query as logical   no-undo .

      { gbl/fltopend.i
        &where-cond = " Buf_abcxyz-analysis-goods.abcx-id = v-id and  Buf_abcxyz-analysis-goods.db-num = v-db-num "
        &dyn_where-cond = "substitute(' Buf_abcxyz-analysis-goods.abcx-id = &1 and  Buf_abcxyz-analysis-goods.db-num = &2 ' ,v-id , v-db-num  ) "
        &use-ind    = " "
        &by         = " " }

if not p-open-query then
REPOSITION browse-goods to recid doc-rec No-ERROR.
/*
APPLY "ENTRY" TO BROWSE-goods in frame {&frame-name}.
APPLY "VALUE-CHANGED" TO BROWSE-goods in frame {&frame-name}.
*/


{&SetCursorNo}
{&OPEN-QUERY-BROWSE-obj}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE print-proc Dialog-Frame
PROCEDURE print-proc :
define input  parameter p-obj as logical   no-undo .

define buffer b_abc-analysis for ub.abc-analysis.
 find first b_abc-analysis no-lock where
            b_abc-analysis.abc-id =  buf_abcxyz-analysis.abc-id and
            b_abc-analysis.db-num =  buf_abcxyz-analysis.abc-db-num no-error .

define buffer b_xyz-analysis for ub.xyz-analysis.
 find first b_xyz-analysis no-lock where
            b_xyz-analysis.xyz-id =  buf_abcxyz-analysis.xyz-id and
            b_xyz-analysis.db-num =  buf_abcxyz-analysis.xyz-db-num no-error .
if available b_xyz-analysis and
   available b_abc-analysis then
 run ref/abcxyzmt.p
 (parParentProc
 ,recid(buf_abcxyz-analysis)
 ).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-cgh-Am Dialog-Frame
PROCEDURE proc-cgh-Am :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
    do
    on error undo, return error return-value
    :

define input  parameter v-new as logical   no-undo .

define buffer buf_matrix                  for  ub.assortment-matrix .
define buffer buf2_assortment-matrix-goods for ub.assortment-matrix-goods .

define buffer buf_gds-obj for ub.gds-obj.
define variable p-doc-rec as recid no-undo .
define variable v-sts as integer   no-undo .
/*  */
DEFINE VARIABLE cError as CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE iDelta as INTEGER   NO-UNDO INITIAL 0.


v-err-ext = false  .
v-longchar = "" .
{ ref/clearlm.i }

 run make-gds-list in this-procedure .
 for each obj-list :
      Label-AM:
      for each  buf_matrix no-lock where
          buf_matrix.asmt-status = 0 and
          buf_matrix.obj-type = obj-list.obj-type and
          buf_matrix.obj-code = obj-list.obj-code :
           if v-new = true then do:
              run waitfram-show in this-procedure  ("Добавление товаров в ассортиментную матрицу  "  +
                                                  buf_matrix.asmt-name +
                                                  "  на объекте " +
                                                  string( obj-list.obj-code )) .
          end.
          else do:
              run waitfram-show in this-procedure  ("Удаление товаров из ассортиментную матрицу  "  +
                                                  buf_matrix.asmt-name +
                                                  "  на объекте " +
                                                  string( obj-list.obj-code )) .
          end.
          /* M - CT  Cюда добавляем проверку на % отклонения матрицы от шаблона !!!  */
          if v-new = true then do:
             /* Параметры снимаем общей процедурой  */
             RUN Get-Gl-Param-Proc-Otkl in THIS-PROCEDURE(
                 buf_matrix.asmt-id,
                 buf_matrix.db-num,
                 OUTPUT cError
                 ).
             if cError <> "" THEN DO:
                v-err-ext = true .
                v-longchar = v-longchar + cError + {&new-line}.
                NEXT Label-AM.
             END.
             /* Подсчет дельты от выбранных товаров  */
             { ref/ass-mat.i
                   &DEF_CALC_DELTA_BUF=YES
                   &BUF_LIST=gds-list
                   &VAR_ASMT-ID=buf_matrix.Asmt-id
                   &VAR_DB-NUM=buf_matrix.db-num
                   &VAR_DELTA=iDelta
             }
             /* Проверка допустимого % отклонения   */
             RUN Cntrl-AM-Add-1 IN THIS-PROCEDURE(
                 iDelta,
                 OUTPUT cError
                 ).
             if cError <> "" THEN DO:
                v-err-ext = true .
                v-longchar = v-longchar + cError + {&new-line}.
                NEXT Label-AM.
             END.
          END.
          /*  */
          for each gds-list :
                if v-new = true then do:
                   find first buf_gds-obj no-lock where
                        buf_gds-obj.obj-type = obj-list.obj-type and
                        buf_gds-obj.obj-code = obj-list.obj-code and
                        buf_gds-obj.gds-code = gds-list.gds-code no-error .
                        if available buf_gds-obj then do:
                            { ref/gds-mat1.i
                              this-procedure
                              p-doc-rec
                              {&add-def}
                              buf_matrix.asmt-id
                              buf_matrix.db-num
                              gds-list.gds-code
                              "''"
                              no-error }
                              if error-status :error then do:
                                v-err-ext = true .
                                v-longchar = v-longchar + return-value + {&new-line}.
                              end.
                        end.
                end.
                else do:
                  find first buf2_assortment-matrix-goods no-lock where
                      buf2_assortment-matrix-goods.asmt-id  = buf_matrix.asmt-id and
                      buf2_assortment-matrix-goods.db-num   = buf_matrix.db-num  and
                      buf2_assortment-matrix-goods.gds-code = gds-list.gds-code  and
                      buf2_assortment-matrix-goods.asmg-status = 0
                      no-error .
                      if available buf2_assortment-matrix-goods then do:
                          v-sts = int({&deleted-status-int}) .
                          { ref/gds-mat2.i
                            this-procedure
                            recid(buf2_assortment-matrix-goods)
                            v-sts
                            no
                            no-error }
                            if error-status :error then do:
                              v-err-ext = true .
                              v-longchar = v-longchar + return-value + {&new-line} .
                            end.
                      end.
                end.
          end.
      end.
 end.
run waitfram-hide in this-procedure .
if v-err-ext = true  then do:
define variable v-ok as logical   no-undo .
  run gbl/d-longchar.w (
        ?,
        'Editor_row=2\':u
      + 'title=При добавлении в Ассортиментные матрицы\':u
      + 'Editor_col=1\':u
      + 'Editor_width=96\':u
      + 'Editor_height=21\':u
      + 'readonly=yes\':u
    ,input-output v-longchar
    ,output v-ok ) no-error .
        v-longchar = "" .
        { ref/clearlm.i }

end.


run OpenBr (yes, no, '':U).
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-cgh-Amin Dialog-Frame
PROCEDURE proc-cgh-Amin :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
    do
    on error undo, return error return-value
    :
define input  parameter v-new as logical   no-undo .
  run make-gds-list in this-procedure .
  run ref/chg-amin.p ( input v-new ) no-error  .
      if error-status :error then
          message vss-workfile vss-revision vss-description skip
          error-status :get-message(1)
          return-value
          .
  run OpenBr (yes, no, '':U).

    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-chg-abc Dialog-Frame
PROCEDURE proc-chg-abc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:   измененме группы и пересчет итоговых количеств в шапке ABC
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-chg-igt Dialog-Frame
PROCEDURE proc-chg-igt :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
    do
    on error undo, return error return-value
    :
define variable  v-old as character no-undo .
define variable  v-new as character no-undo .

  run make-gds-list .
  run ref/graf-igt.w ( output v-old, output v-new ).

  if not(v-old = "" and v-new = "")  then do:
      run ref/chg-igt.p ( input v-old, input v-new , input true ) no-error  .
          if error-status :error then
              message vss-workfile vss-revision vss-description skip
              error-status :get-message(1)
              return-value
              .
  end.
run OpenBr ( yes, no, '':U).

    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-disp-goods Dialog-Frame
PROCEDURE proc-disp-goods :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable   v-old-izt  as character no-undo .
define variable   v-old-amin  as character no-undo .
define variable   v-old-acc-mat  as character no-undo .
define variable vt-Amin as character no-undo .
    assign
    v-old-izt  = ""
    v-izt      = ""
    v-Amin     = ""
    v-old-Amin = ""
    v-acc-mat     =  ""
    v-old-acc-mat = ""
    .




END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE prt-goods Dialog-Frame
PROCEDURE prt-goods :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable   v-old-izt  as character no-undo .
define variable   v-old-amin  as character no-undo .
define variable   v-old-acc-mat  as character no-undo .
define variable vt-Amin as character no-undo .
define variable t-izt as character no-undo .
define variable t-Amin as character no-undo .
define variable t-asm as character no-undo .
define variable            v-gdop-min-stock                as decimal   no-undo .
define variable            v-grop-max-stock                as decimal   no-undo .
define variable            v-grop-level-always-presence    as decimal   no-undo .
define variable            v-grop-min-order                as decimal   no-undo .
    assign
    v-old-izt  = ""
    v-izt      = ""
    v-Amin     = ""
    v-old-Amin = ""
    v-acc-mat     =  ""
    v-old-acc-mat = ""
    .


define buffer buf2_abc-analysis-gds-obj for ub.abc-analysis-gds-obj   .
define buffer buf2_assortment-matrix for ub.assortment-matrix.
define buffer buf2_assortment-matrix-goods for ub.assortment-matrix-goods.
DEFINE BUFFER Buf_abc-analysis-obj FOR ub.abc-analysis-obj.

FOR EACH Buf_abc-analysis-obj WHERE
         Buf_abc-analysis-obj.abc-id = Buf_abcxyz-analysis.abc-id AND
         Buf_abc-analysis-obj.db-num = Buf_abcxyz-analysis.abc-db-num
         NO-LOCK,
        EACH buf2_abc-analysis-gds-obj WHERE
            buf2_abc-analysis-gds-obj.obj-type = Buf_abc-analysis-obj.obj-type AND
            buf2_abc-analysis-gds-obj.obj-code = Buf_abc-analysis-obj.obj-code AND
            buf2_abc-analysis-gds-obj.gds-code = Buf_abc-analysis-goods.gds-code AND
            buf2_abc-analysis-gds-obj.abc-id   = Buf_abcxyz-analysis.abc-id AND
            buf2_abc-analysis-gds-obj.db-num   = Buf_abcxyz-analysis.abc-db-num
            NO-LOCK break
            by Buf2_abc-analysis-gds-obj.gds-code

            :

                find first buf2_assortment-matrix WHERE
                      buf2_assortment-matrix.asmt-status        = 0  AND
                      buf2_assortment-matrix.obj-type =  Buf_abc-analysis-obj.obj-type AND
                      buf2_assortment-matrix.obj-code =  Buf_abc-analysis-obj.obj-code
                      NO-LOCK no-error .
                find first buf2_assortment-matrix-goods WHERE
                      buf2_assortment-matrix-goods.asmg-status        = 0  AND
                      buf2_assortment-matrix-goods.asmt-id  =  buf2_assortment-matrix.asmt-id AND
                      buf2_assortment-matrix-goods.db-num   =  buf2_assortment-matrix.db-num  AND
                      buf2_assortment-matrix-goods.gds-code =  buf2_abc-analysis-gds-obj.gds-code
                      NO-LOCK no-error .

                 { gbl/gdsobjpr.i
                 Buf_abc-analysis-obj.obj-type
                 Buf_abc-analysis-obj.obj-code
                 ?
                 ?
                 ?
                 Buf_abc-analysis-goods.gds-code
                 t-amin
                 t-izt
                  v-gdop-min-stock
                  v-grop-max-stock
                  v-grop-level-always-presence
                  v-grop-min-order

                 }
             if not available buf2_assortment-matrix-goods then t-asm = "0" .
                                                           else t-asm = string(buf2_assortment-matrix-goods.asmt-id).

            if first-of(Buf2_abc-analysis-gds-obj.gds-code) then do:
                  assign
                  v-old-izt  =  t-izt
                  v-izt      =  t-izt
                  v-Amin     =  t-amin
                  v-old-Amin =  t-amin
                  v-acc-mat     =  t-asm
                  v-old-acc-mat =  t-asm
                  .

                  if  v-Amin = 'no'  then v-Amin = "не входит" .
                                     else v-Amin = "входит" .
                  if v-acc-mat = "0" then v-acc-mat = "не входит" .
                                     else v-acc-mat = "входит" .
            end.

        if v-old-izt     <> t-izt            then  v-izt = "разное" .
        if v-old-Amin    <> t-Amin           then  v-Amin = "разное" .
        if v-old-acc-mat <> t-asm            then  v-acc-mat = "разное" .

      assign
        v-old-izt     = t-izt
        v-old-Amin    = t-Amin
        v-old-acc-mat = t-asm
      .

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME