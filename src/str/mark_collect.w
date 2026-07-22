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

Сканирование акцизных марок

Автор: Шкляр Елена
Дата создания: 07/09/07
Author: Elena Shklyar
Creation date: 07/09/07

*/
&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DECLARATIONS Procedure
using ibs.th.gbl.sys.objsrv.
using ibs.th.str.marking.sts.*.
using ibs.th.str.marking.handlers.*.
using ibs.th.str.utd.sts.*.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сканирование акцизных марок".
{ gbl/objsrv.i   }
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ str/marks.i    }
{ str/fbrhist.i main }
{ gbl/lineattr.i }
{ gbl/color.i    }
{ str/temp_upd.i }
{ gbl/attr-lib.i }
{ utl/gtin.i     }
{ gbl/waitfram.i noprocess }
{ gbl/getcntxt.i def }
{ ref/gdsoattr.i }


/* Parameters Definitions ---                                           */

define input parameter parparentproc         as handle              no-undo .
define input parameter p-doc-id as integer no-undo .
define input parameter p-db-num as integer   no-undo .
define input parameter p-mode as character no-undo .

define variable iLang           as integer   no-undo.
define variable p-value-logical as logical no-undo.
define variable p-value-character  as character no-undo.
define variable p-value-date       as date no-undo.
define variable p-value-decimal    as decimal no-undo.
define variable p-value-integer    as integer no-undo.
define variable p-param-type       as character no-undo.
define variable v-tth as handle no-undo .

define variable v-comment      as character no-undo .
define variable m-gds-code     as character no-undo label "Товар" view-as fill-in.

define variable gds-rec         as integer   no-undo .
define variable v-proc-name-err as character no-undo initial 'impmark.txt'. /* Имя лога */
define variable l-error         as logical   no-undo. /* Есть ли ошибки */
define variable v-user-action   as character no-undo.
define variable v-printed       as logical   no-undo.
define variable v-mark-short     as character no-undo. 

define buffer X_utd-lines           for tt-utd-lines .
define buffer buf_clients  for ub.clients .
define buffer buf_marking  for ub.marking .
define buffer buf_marking-lines  for ub.marking-lines .
define buffer buf_utd  for ub.utd .
define buffer buf_utd-attr for ub.utd-attr .
define buffer buf_utd-lines  for ub.utd-lines .
define buffer buf_utd-lines-attr  for ub.utd-lines-attr .
define buffer buf_utd-marking-lines  for ub.utd-marking-lines .
define buffer bf_fbr-line  for ub.fbr-line.
define buffer buf_recipe   for ub.recipe .
define buffer bf_bar-code  for ub.bar-code.
define buffer buf_goods for ub.goods .
define buffer buf_gds-obj for ub.gds-obj .

define variable v-timedelay  as integer   no-undo.
define variable v-scan-str as character no-undo.
define variable v-num-str as integer no-undo .
define variable v-manual as logical no-undo .
define variable recid_utd      as integer   no-undo . 
define variable vLineNum as integer no-undo .

define variable marking as class mark no-undo .

define variable v-attr-value like ub.gds-obj-attr.attr-value no-undo .
define variable v-attr-type as character no-undo .
define variable disable-set as logical no-undo init no .

define stream str-err .
define stream in-stream.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-utd-lines

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_utd-lines

/* Definitions for BROWSE br-utd-lines                                  */
&Scoped-define FIELDS-IN-QUERY-br-utd-lines X_utd-lines.LineNum X_utd-lines.gds-code X_utd-lines.GdsName X_utd-lines.Quantity X_utd-lines.UnitCode   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-utd-lines   
&Scoped-define QUERY-STRING-br-utd-lines FOR EACH X_utd-lines NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-utd-lines if r-error = 2 then OPEN QUERY br-utd-lines FOR EACH X_utd-lines NO-LOCK where X_utd-lines.Quantity < X_utd-lines.free-qnty INDEXED-REPOSITION. ~
                                       else OPEN QUERY br-utd-lines FOR EACH X_utd-lines NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-utd-lines X_utd-lines
&Scoped-define FIRST-TABLE-IN-QUERY-br-utd-lines X_utd-lines


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-utd-lines}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS R-TH b-cancel b-exit B_mark c-type ~
f-num-name f-num f-date-name f-date is-initial-set f-obj-type-TH ~
f-obj-code-TH r-obj-TH f-obj-name-TH f-status-TH f-comment f-comment-name ~
v-mark a-n-c br-utd-lines b_prov-finish b_del-line 
&Scoped-Define DISPLAYED-OBJECTS c-type f-num-name f-num f-date-name f-date ~
is-initial-set f-obj-type-TH f-obj-code-TH f-obj-name-TH f-status-TH ~
c-status f-comment f-comment-name v-mark a-n-c ~
a-n-c-name f-msg 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */
DEFINE MENU m_marks 
   MENU-ITEM m_marks-utd    LABEL "Марки по документу"
   MENU-ITEM m_marks-lines  LABEL "Марки по строке".

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b_del-line 
     LABEL "Удалить товар" 
     SIZE 36 BY 1.24.

DEFINE BUTTON B_mark 
     LABEL "Марки" 
     SIZE 10 BY 1.

DEFINE BUTTON b_prov-finish 
     LABEL "Проверка завершена" 
     SIZE 36 BY 1.24.

DEFINE BUTTON r-obj-TH 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE VARIABLE c-status AS INTEGER FORMAT "-999":U INITIAL 0 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Новый",0,
                     "Подтвержден",8
     DROP-DOWN-LIST
     SIZE 55.6 BY 1 NO-UNDO.

DEFINE VARIABLE c-type AS INTEGER FORMAT "-999":U INITIAL 10 
     LABEL "Тип" 
     VIEW-AS COMBO-BOX INNER-LINES 1
     LIST-ITEM-PAIRS "Сбор марок",10
     DROP-DOWN-LIST
     SIZE 42 BY 1 NO-UNDO.

DEFINE VARIABLE f-comment AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 100 BY 3.5 NO-UNDO.

/*DEFINE VARIABLE f-info AS CHARACTER   */
/*     VIEW-AS EDITOR SCROLLBAR-VERTICAL*/
/*     SIZE 100 BY 1.95 NO-UNDO.        */

DEFINE VARIABLE a-n-c-name AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 45 BY 1
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE f-comment-name AS CHARACTER FORMAT "X(256)":U INITIAL "Комментарий:" 
     VIEW-AS FILL-IN 
     SIZE 12.8 BY 1 NO-UNDO.

DEFINE VARIABLE f-date AS DATE FORMAT "99/99/9999":U 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-date-name AS CHARACTER FORMAT "X(256)":U INITIAL "Дата:" 
     VIEW-AS FILL-IN 
     SIZE 6 BY 1 NO-UNDO.

/*DEFINE VARIABLE f-info-name AS CHARACTER FORMAT "X(256)":U INITIAL "Доп.инфо:"*/
/*     VIEW-AS FILL-IN                                                          */
/*     SIZE 9.8 BY 1 NO-UNDO.                                                   */

DEFINE VARIABLE f-msg AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 115 BY 1 NO-UNDO.

DEFINE VARIABLE f-num AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-num-name AS CHARACTER FORMAT "X(256)":U INITIAL "№ документа:" 
     VIEW-AS FILL-IN 
     SIZE 12.6 BY 1 NO-UNDO.

DEFINE VARIABLE f-obj-code-TH AS INTEGER FORMAT "->>>>>>" INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 14.8 BY 1.

DEFINE VARIABLE f-obj-name-TH AS CHARACTER FORMAT "X(100)" 
     VIEW-AS FILL-IN 
     SIZE 48.6 BY 1.

DEFINE VARIABLE f-obj-type-TH AS CHARACTER FORMAT "X(3)" 
     VIEW-AS FILL-IN 
     SIZE 4.2 BY 1.

DEFINE VARIABLE f-status-TH AS CHARACTER FORMAT "X(256)":U INITIAL "Статус ТН:" 
     VIEW-AS FILL-IN 
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE v-mark AS CHARACTER FORMAT "X(256)":U 
     LABEL "Марка" 
     VIEW-AS FILL-IN 
     SIZE 100 BY 1 NO-UNDO.

DEFINE VARIABLE a-n-c AS CHARACTER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Код", "code",
"Нач.назв", "name",
"Нач.слова", "context"
     SIZE 37.6 BY 1 NO-UNDO.

DEFINE VARIABLE R-error       AS INTEGER 
   VIEW-AS RADIO-SET HORIZONTAL
   RADIO-BUTTONS 
   "Все", 1,
   "Ошибки", 2
   SIZE 22 BY 1 NO-UNDO.
   
DEFINE RECTANGLE R-TH
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 73.6 BY 3.1 TOOLTIP "Данные ТН".

DEFINE VARIABLE is-initial-set AS LOGICAL INITIAL no 
     LABEL "Первоначальный сбор марок" 
     VIEW-AS TOGGLE-BOX
     SIZE 33 BY .81 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-utd-lines FOR 
      X_utd-lines SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-utd-lines
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-utd-lines Dialog-Frame _FREEFORM
  QUERY br-utd-lines NO-LOCK DISPLAY
      X_utd-lines.LineNum FORMAT "99999":U label "Номер"
      X_utd-lines.gds-code FORMAT "999999999":U label "Код товара"
      X_utd-lines.GdsName FORMAT "x(128)":U label "Наименование товара" width 40
      X_utd-lines.Quantity FORMAT "->>,>>9.<<<":U label "Просканировано"
      X_utd-lines.free-qnty FORMAT "->>,>>9.<<<":U label "Общий остаток"
      X_utd-lines.UnitCode FORMAT "x(8)":U label "Единица измерения"
/*      X_utd-lines.qnty-mark FORMAT "->>,>>9":U label "Кол-во марок"*/
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 117 BY 8.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-cancel AT ROW 1.24 COL 2
     b-exit AT ROW 1.24 COL 12 WIDGET-ID 380
     B_mark AT ROW 1.24 COL 109 WIDGET-ID 80
     c-type AT ROW 2.43 COL 5.2 COLON-ALIGNED WIDGET-ID 240
     f-num-name AT ROW 2.43 COL 53.8 NO-LABEL WIDGET-ID 328
     f-num AT ROW 2.43 COL 64.6 COLON-ALIGNED NO-LABEL WIDGET-ID 284
     f-date-name AT ROW 2.43 COL 81.2 NO-LABEL WIDGET-ID 330
     f-date AT ROW 2.43 COL 85.2 COLON-ALIGNED NO-LABEL WIDGET-ID 286
     is-initial-set AT ROW 3.86 COL 77 WIDGET-ID 344
     f-obj-type-TH AT ROW 5.05 COL 7 RIGHT-ALIGNED NO-LABEL WIDGET-ID 102
     f-obj-code-TH AT ROW 5.05 COL 22.8 RIGHT-ALIGNED NO-LABEL WIDGET-ID 98
     r-obj-TH AT ROW 5.05 COL 23.6 WIDGET-ID 104
     f-obj-name-TH AT ROW 5.05 COL 74.6 RIGHT-ALIGNED NO-LABEL WIDGET-ID 100
     f-status-TH AT ROW 6.95 COL 6 NO-LABEL WIDGET-ID 336
     c-status AT ROW 6.95 COL 15 COLON-ALIGNED NO-LABEL WIDGET-ID 238
     f-comment AT ROW 8 COL 17 NO-LABEL WIDGET-ID 266
     f-comment-name AT ROW 8.19 COL 4 NO-LABEL WIDGET-ID 340
/*     f-info AT ROW 9.48 COL 17 NO-LABEL WIDGET-ID 268    */
/*     f-info-name AT ROW 9.81 COL 7 NO-LABEL WIDGET-ID 342*/
     v-mark AT ROW 11.48 COL 15 COLON-ALIGNED
     a-n-c AT ROW 12.76 COL 3 NO-LABEL WIDGET-ID 272
     a-n-c-name AT ROW 12.81 COL 40.2 COLON-ALIGNED NO-LABEL WIDGET-ID 278
     R-error AT ROW 12.76 COL 99 NO-LABEL WIDGET-ID 372
     br-utd-lines AT ROW 13.81 COL 3
     f-msg AT ROW 21.95 COL 3 NO-LABEL WIDGET-ID 92
     b_prov-finish AT ROW 23.14 COL 3 WIDGET-ID 70
     b_del-line AT ROW 23.14 COL 39 WIDGET-ID 94
     "Объект:" VIEW-AS TEXT
          SIZE 12 BY .67 AT ROW 4.1 COL 4 WIDGET-ID 182
     "Данные ТН:" VIEW-AS TEXT
          SIZE 11 BY .67 AT ROW 3.62 COL 33.6 WIDGET-ID 180
     R-TH AT ROW 3.76 COL 3 WIDGET-ID 112
     SPACE(2) SKIP(1)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Документ сбора марок"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

{str/mark_collect.i no}

/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-utd-lines a-n-c-name Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
   B_mark:POPUP-MENU IN FRAME Dialog-Frame = MENU m_marks:HANDLE.
   
ASSIGN 
   b_mark:MENU-MOUSE = 1.
/* SETTINGS FOR FILL-IN a-n-c-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR COMBO-BOX c-status IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/*ASSIGN                                                         */
/*       f-comment:READ-ONLY IN FRAME Dialog-Frame        = TRUE.*/

/* SETTINGS FOR FILL-IN f-comment-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-date-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/*ASSIGN                                                      */
/*       f-info:READ-ONLY IN FRAME Dialog-Frame        = TRUE.*/

/* SETTINGS FOR FILL-IN f-info-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-msg IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
ASSIGN 
       f-msg:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN f-num-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-obj-code-TH IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN f-obj-name-TH IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN f-obj-type-TH IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN f-status-TH IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-utd-lines
/* Query rebuild information for BROWSE br-utd-lines
     _TblList          = "ub.utd-lines"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   = ub.utd-lines.LineNum
     _FldNameList[2]   = ub.utd-lines.gds-code
     _FldNameList[3]   = ub.utd-lines.GdsName
     _FldNameList[4]   = ub.utd-lines.Quantity
     _FldNameList[5]   = ub.utd-lines.UnitCode
     _Query            is OPENED
*/  /* BROWSE br-utd-lines */
&ANALYZE-RESUME

 

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION CliName Dialog-Frame 
FUNCTION CliName RETURNS CHARACTER
   (input p-cli-code as integer, input p-cli-type as character) :
   /*------------------------------------------------------------------------------
     Purpose:  
       Notes:  
   ------------------------------------------------------------------------------*/
   define variable v-cli-name as character no-undo .
   find first buf_clients no-lock where buf_clients.obj-code = p-cli-code
      and buf_clients.obj-type = p-cli-type no-error .
   if available (buf_clients) then v-cli-name = buf_clients.obj-name .
   RETURN v-cli-name.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION GdsName Dialog-Frame 
FUNCTION GdsName RETURNS CHARACTER
   ( input p-gds-code as integer) :
   /*------------------------------------------------------------------------------
     Purpose:  
       Notes:  
   ------------------------------------------------------------------------------*/
   define variable v-gds-name as character no-undo .
   define buffer buf_goods for ub.goods .
  
   find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
   if available (buf_goods) then v-gds-name = buf_goods.gds-name .
   RETURN v-gds-name.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD StatusTHName Dialog-Frame
FUNCTION StatusTHName RETURNS CHARACTER
   (input p-stsTH as integer)  .
   Return Marking:GetLabel(p-stsTH) .
END FUNCTION .
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME a-n-c
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL a-n-c Dialog-Frame
ON VALUE-CHANGED OF a-n-c IN FRAME Dialog-Frame
DO:
  assign a-n-c .
  apply "TAB":U to self .
  return no-apply .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME is-initial-set
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL is-initial-set Dialog-Frame
ON VALUE-CHANGED OF is-initial-set IN FRAME Dialog-Frame
DO:
  assign is-initial-set .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME f-comment
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-comment Dialog-Frame
ON VALUE-CHANGED OF f-comment IN FRAME Dialog-Frame
DO:
  assign f-comment .
END.

ON return OF f-comment IN FRAME Dialog-Frame
DO:
  define variable v-cursor as integer no-undo .
  define variable v-lines as integer no-undo .
  assign f-comment .
  v-cursor = f-comment:cursor-offset .
  v-lines = num-entries((substring(f-comment, 1, v-cursor - 1)), {&new-line}) .
  f-comment = substring(f-comment, 1, v-cursor - v-lines) + {&new-line} + substring(f-comment, v-cursor + 1 - v-lines) .
  display f-comment with frame {&frame-name} .
  f-comment:cursor-offset = v-cursor + 2 .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME a-n-c-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL a-n-c-name Dialog-Frame
ON leave, return OF a-n-c-name IN FRAME Dialog-Frame
DO:
  assign a-n-c-name .
  assign a-n-c .
  case a-n-c:
     when "code" then 
        do:
           find first X_utd-lines where X_utd-lines.gds-code = integer(a-n-c-name) no-error .
           if available (X_utd-lines) then 
           do:
              recid_utd = recid (X_utd-lines) .
              br-utd-lines :refresh() no-error.
              reposition br-utd-lines to recid recid_utd no-error .
           end.   
        end.
     when "name" then 
        do:
           find first X_utd-lines where (X_utd-lines.GdsName begins a-n-c-name) no-error .
            
           if available (X_utd-lines) then 
           do:
              recid_utd = recid (X_utd-lines) .
              br-utd-lines :refresh() no-error.
              reposition br-utd-lines to recid recid_utd no-error .
           end.                  
        end.
     when "context" then 
        do:
           find first X_utd-lines where (X_utd-lines.GdsName MATCHES "*" + a-n-c-name + "*") no-error .
           if available (X_utd-lines) then 
           do:
              recid_utd = recid (X_utd-lines) .
              br-utd-lines :refresh() no-error.
              reposition br-utd-lines to recid recid_utd no-error .
           end.  
        end.         
  end case.
    
  apply "TAB":U to self .
  return no-apply .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME R-error
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL R-error Dialog-Frame
ON value-changed OF R-error IN FRAME Dialog-Frame
DO:
  assign R-error .
  {&OPEN-QUERY-br-utd-lines}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME v-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-mark Dialog-Frame
ON ENTRY OF v-mark IN FRAME Dialog-Frame /* Марка */
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

&Scoped-define SELF-NAME m_marks-lines
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_marks-lines m_marks
ON CHOOSE OF menu-item m_marks-lines  /* Марки */
DO:
  apply "entry" to br-utd-lines in frame {&frame-name}.
  if available (X_utd-lines) then 
  do:
     recid_utd = recid(X_utd-lines) .
     run temp-mark (input 1) .  
     if available (tt-marking-lines) then 
     do:
        run str/mark_browse.w (input parparentproc,
           input-output table tt-marking-lines by-reference,
           input p-mode,
           input ("Марки по: Сбор марок " + buf_utd.DocumentNumber + " по товару " + string(X_utd-lines.gds-code) + " " + GdsName(X_utd-lines.gds-code)),
           input "0",
           input "" /*тип продукции*/
           ) no-error .
        { gbl/brwrepos.i
          &line-num= 5
        }
        empty temp-table tt-marking-lines .
     end.
     else 
     do:
        message "Нет марок"
           view-as alert-box.
     end.    
     br-utd-lines :refresh() no-error .
     apply "VALUE-CHANGED" to br-utd-lines in frame {&frame-name}.
     apply "entry" to br-utd-lines in frame {&frame-name}.
   
     reposition br-utd-lines to recid recid_utd no-error .

  end.
  else message "Нет марок"
        view-as alert-box.  
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_marks-utd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_marks-utd m_marks
ON CHOOSE OF menu-item m_marks-utd /* Марки по документу */
DO:
  apply "entry" to br-utd-lines in frame {&frame-name}.
  recid_utd = recid (X_utd-lines) .
  run temp-mark (input 2) .
  if available (tt-marking-lines) then 
  do:
     run str/mark_browse.w (input parparentproc,
        input-output table tt-marking-lines by-reference,
        input p-mode,
        input "Марки по документу: Сбор марок " + buf_utd.DocumentNumber,
        input "0",
        input "" /*тип продукции*/
        ) no-error .
     empty temp-table tt-marking-lines .
     br-utd-lines:refresh () no-error.
     apply "VALUE-CHANGED" to br-utd-lines in frame {&frame-name}.
     apply "entry" to br-utd-lines in frame {&frame-name}.
   
     reposition br-utd-lines to recid recid_utd no-error .
  end.
  else 
  do:
     message "Нет марок по документу"
        view-as alert-box.
  end.    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
do:
  define buffer bf_utd-lines for ub.utd-lines .
  
  assign
    is-initial-set
    f-comment
  .
  find first buf_utd-attr exclusive-lock where buf_utd-attr.db-num = buf_utd.db-num
                                           and buf_utd-attr.doc-id = buf_utd.doc-id
                                           and buf_utd-attr.attr-code = "is-initial-set"
                                           no-error .
  if not available buf_utd-attr
  then do :
    create buf_utd-attr .
    assign
      buf_utd-attr.db-num = buf_utd.db-num
      buf_utd-attr.doc-id = buf_utd.doc-id
      buf_utd-attr.attr-code = "is-initial-set"
    .
  end .
  assign buf_utd-attr.attr-value = string(is-initial-set) .
  assign buf_utd.comment = trim(f-comment) .
  
  find first bf_utd-lines no-lock where bf_utd-lines.db-num = buf_utd.db-num
                                    and bf_utd-lines.doc-id = buf_utd.doc-id
                                    no-error .
  if not available bf_utd-lines
  then do :
    message "Документ пустой. Изменения не будут сохранены" view-as alert-box .
    if p-mode <> {&lookup}
    and available (buf_utd) 
    then do:
      delete buf_utd .
    end .
  end .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b_del-line
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b_del-line Dialog-Frame
ON any-printable OF b_del-line IN FRAME Dialog-Frame /* Удалить товар */
DO:
  run proc-any-key.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b_del-line Dialog-Frame
ON CHOOSE OF b_del-line IN FRAME Dialog-Frame /* Удалить товар */
DO:
  define buffer bf_utd-lines for ub.utd-lines .
  define buffer bf_utd-marking-lines for ub.utd-marking-lines .
  define buffer bf_marking for ub.marking .
  define variable v-auto as logical no-undo .
  
  if available X_utd-lines
  then do :
    for each bf_utd-marking-lines no-lock where bf_utd-marking-lines.db-num = X_utd-lines.db-num
                                            and bf_utd-marking-lines.doc-id = X_utd-lines.doc-id
                                            and bf_utd-marking-lines.LineNum = X_utd-lines.LineNum
                                            and bf_utd-marking-lines.sts = 0
    :
      v-auto = g#auto .
      g#auto = true .
      for each bf_marking exclusive-lock where bf_marking.mark = bf_utd-marking-lines.mark
                                           and bf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB
      :
        delete bf_marking .
      end.
      g#auto = v-auto .
    end.
    find first bf_utd-lines exclusive-lock where bf_utd-lines.db-num = X_utd-lines.db-num
                                             and bf_utd-lines.doc-id = X_utd-lines.doc-id
                                             and bf_utd-lines.LineNum = X_utd-lines.LineNum
                                             no-error .
    if available bf_utd-lines
    then do :
      delete bf_utd-lines .
    end .
    vLineNum = X_utd-lines.LineNum - 1 .
    delete X_utd-lines .
    for each tt-utd-lines where tt-utd-lines.LineNum > vLineNum,
    first bf_utd-lines exclusive-lock where bf_utd-lines.db-num = tt-utd-lines.db-num
                                        and bf_utd-lines.doc-id = tt-utd-lines.doc-id
                                        and bf_utd-lines.LineNum = tt-utd-lines.LineNum
                                        break by tt-utd-lines.LineNum
    :
      for each bf_utd-marking-lines exclusive-lock where bf_utd-marking-lines.db-num = bf_utd-lines.db-num
                                                     and bf_utd-marking-lines.doc-id = bf_utd-lines.doc-id
                                                     and bf_utd-marking-lines.LineNum = bf_utd-lines.LineNum
      :
        bf_utd-marking-lines.LineNum = bf_utd-marking-lines.LineNum - 1 .
      end .
      tt-utd-lines.LineNum = tt-utd-lines.LineNum - 1 .
      bf_utd-lines.LineNum = tt-utd-lines.LineNum .
      if last-of(tt-utd-lines.LineNum)
      then do :
        vLineNum = tt-utd-lines.LineNum .
      end .
    end .
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  end .
  
  if is-initial-set
  and not is-initial-set:sensitive
  then do :
    assign disable-set = no .
    for each X_utd-lines no-lock where X_utd-lines.db-num = buf_utd.db-num
                                   and X_utd-lines.doc-id = buf_utd.doc-id
    :
      run gdsoattr-value in this-procedure (input   {&attr-mark-collect-type},
                                            input   X_utd-lines.gds-code,
                                            input   buf_utd.obj-type,
                                            input   buf_utd.obj-code,
                                            output  v-attr-value,
                                            output  v-attr-type
                                            ) no-error.
      if is-initial-set
      and (v-attr-value = "" or v-attr-value = "0")
      then do :
        assign disable-set = yes .
        leave .
      end .
    end .
    if not disable-set then enable is-initial-set with frame {&frame-name} .
  end .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b_prov-finish
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b_prov-finish Dialog-Frame
ON any-printable OF b_prov-finish IN FRAME Dialog-Frame /* Проверка завершена */
DO:
  run proc-any-key.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b_prov-finish Dialog-Frame
ON CHOOSE OF b_prov-finish IN FRAME Dialog-Frame /* Проверка завершена */
DO:
  define variable v-ok        as logical no-undo .
  define buffer bf_utd-marking-lines for ub.utd-marking-lines .
  define buffer bf2_utd-marking-lines for ub.utd-marking-lines .
  define buffer bf_utd-lines-attr    for ub.utd-lines-attr .
  define buffer bf_utd-lines         for ub.utd-lines .
  define buffer bf_marking           for ub.marking .
  define buffer bf_marking-parent    for ub.marking .
  define variable vPawd as character no-undo.
  
  assign
    is-initial-set
    f-comment  
  .
  
  find first buf_utd-attr exclusive-lock where buf_utd-attr.db-num = buf_utd.db-num
                                           and buf_utd-attr.doc-id = buf_utd.doc-id
                                           and buf_utd-attr.attr-code = "is-initial-set"
                                           no-error .
  if not available buf_utd-attr
  then do :
    create buf_utd-attr .
    assign
      buf_utd-attr.db-num = buf_utd.db-num
      buf_utd-attr.doc-id = buf_utd.doc-id
      buf_utd-attr.attr-code = "is-initial-set"
    .
  end .
  assign buf_utd-attr.attr-value = string(is-initial-set) .
  assign buf_utd.comment = trim(f-comment) .

  find first bf_utd-marking-lines no-lock where bf_utd-marking-lines.db-num = buf_utd.db-num
                                            and bf_utd-marking-lines.doc-id = buf_utd.doc-id
                                            no-error .
  if not available (bf_utd-marking-lines) 
  then do:
    message "Документ пустой. Завершить его обработку невозможно"
      view-as alert-box.
    return no-apply .
  end.  
  
  v-ok = yes .
  for first X_utd-lines where X_utd-lines.Quantity < X_utd-lines.free-qnty:
    v-ok = no .
  end.
  if not v-ok
  then do:  
    message "Документ содержит товары, по которым количество просканированных марок меньше остатков в системе (выделены красным в интерфейсе). Продолжить закрытие документа?"
    view-as alert-box question buttons yes-no update v-ok .
  end . 
  if not v-ok
  then
    return no-apply .
    
  run adm\ask-pswd.w ("Введите пароль пользователя, осуществляющего закрытие сбора марок, с целью подтверждения внесенных фактических остатков марок на АЗК.",output vPawd).
  if  vPawd eq ?
  then
    return no-apply .
 
  If vPawd ne encode(g#passwd)
  then do:
    message "Введен неправильный пароль" view-as alert-box .
    return no-apply .
  end.
  
  run waitfram-show in this-procedure (input "ЖДИТЕ...") .
  
  for each bf_utd-marking-lines no-lock where bf_utd-marking-lines.db-num  = buf_utd.db-num
                                          and bf_utd-marking-lines.doc-id  = buf_utd.doc-id
                                          and bf_utd-marking-lines.site   <> "only-send",
  first bf_marking no-lock where bf_marking.mark = bf_utd-marking-lines.mark
  :
    if bf_marking.mark-parent > ""
    then do :
      for first bf_marking-parent no-lock where bf_marking-parent.mark = bf_marking.mark-parent :
        if bf_marking-parent.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB
        or bf_marking-parent.sts = objSrv:Env:Marking:Sts:Mark:OutOfInventory:KeyIntDB
        then do :
          if not can-find (first bf2_utd-marking-lines where bf2_utd-marking-lines.db-num  = bf_utd-marking-lines.db-num
                                                         and bf2_utd-marking-lines.doc-id  = bf_utd-marking-lines.doc-id
                                                         and bf2_utd-marking-lines.LineNum = bf_utd-marking-lines.LineNum
                                                         and bf2_utd-marking-lines.mark    = bf_marking-parent.mark
                                                         and bf2_utd-marking-lines.site   <> "only-send"
                                                         no-lock)
          then do :
            find current bf_marking-parent exclusive-lock .
            assign bf_marking-parent.sts = objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB .
          end .
        end .
      end .
    end .
  end .
  for each bf_utd-lines no-lock where bf_utd-lines.db-num = buf_utd.db-num
                                  and bf_utd-lines.doc-id = buf_utd.doc-id,
  first buf_goods no-lock where buf_goods.gds-code = bf_utd-lines.gds-code
  :
    for each bf_marking no-lock where bf_marking.gds-code = bf_utd-lines.gds-code :
      if not can-find (first bf_utd-marking-lines where bf_utd-marking-lines.db-num  = bf_utd-lines.db-num
                                                    and bf_utd-marking-lines.doc-id  = bf_utd-lines.doc-id
                                                    and bf_utd-marking-lines.LineNum = bf_utd-lines.LineNum
                                                    and bf_utd-marking-lines.mark    = bf_marking.mark
                                                    and bf_utd-marking-lines.site   <> "only-send"
                                                    no-lock)
      and bf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB
      then do :
        find current bf_marking exclusive-lock .
        assign bf_marking.sts = objSrv:Env:Marking:Sts:Mark:OutOfInventory:KeyIntDB .
        find first bf_utd-marking-lines no-lock where bf_utd-marking-lines.db-num  = bf_utd-lines.db-num
                                                  and bf_utd-marking-lines.doc-id  = bf_utd-lines.doc-id
                                                  and bf_utd-marking-lines.LineNum = bf_utd-lines.LineNum
                                                  and bf_utd-marking-lines.mark    = bf_marking.mark
                                                  no-error .
        if not available bf_utd-marking-lines
        then do :
          create bf_utd-marking-lines .
          assign
            bf_utd-marking-lines.db-num    = bf_utd-lines.db-num
            bf_utd-marking-lines.doc-id    = bf_utd-lines.doc-id
            bf_utd-marking-lines.LineNum   = bf_utd-lines.LineNum
            bf_utd-marking-lines.mark      = bf_marking.mark
            bf_utd-marking-lines.gds-code  = bf_utd-lines.gds-code
            bf_utd-marking-lines.sts       = bf_marking.sts
            bf_utd-marking-lines.doc-level = 1
            bf_utd-marking-lines.site      = "only-send"
          .
        end .
      end .
    end .
    if is-initial-set
    then do :
      run gdsoattr-value in this-procedure (input   {&attr-mark-collect-type},
                                            input   bf_utd-lines.gds-code,
                                            input   buf_utd.obj-type,
                                            input   buf_utd.obj-code,
                                            output  v-attr-value,
                                            output  v-attr-type
                                            ) no-error.
      if v-attr-value = ""
      or v-attr-value = "0"
      then do:
        run gdsoattr-write (input bf_utd-lines.gds-code,
                            input buf_utd.obj-type,
                            input buf_utd.obj-code,
                            input {&attr-mark-collect-type},
                            input "1"
                            ).
      end.
    end .
    else do :
      run gdsoattr-write (input bf_utd-lines.gds-code,
                          input buf_utd.obj-type,
                          input buf_utd.obj-code,
                          input {&attr-mark-collect-type},
                          input "2"
                          ).
    end .
    
    find first buf_gds-obj no-lock where buf_gds-obj.obj-type  = v-cntxt-obj-type
                                     and buf_gds-obj.obj-code  = v-cntxt-obj-code
                                     and buf_gds-obj.artic     = buf_goods.artic
                                     and buf_gds-obj.prod-type = buf_goods.prod-type
                                     and buf_gds-obj.prod-code = buf_goods.prod-code
                                     no-error .
    find first X_utd-lines no-lock where bf_utd-lines.doc-id = X_utd-lines.doc-id
                                     and bf_utd-lines.db-num = X_utd-lines.db-num
                                     and bf_utd-lines.LineNum = X_utd-lines.LineNum
                                     no-error . 
    find first buf_utd-lines-attr exclusive-lock where buf_utd-lines-attr.doc-id = bf_utd-lines.doc-id
                                                   and buf_utd-lines-attr.db-num = bf_utd-lines.db-num
                                                   and buf_utd-lines-attr.LineNum = bf_utd-lines.LineNum 
                                                   and buf_utd-lines-attr.attr-code = "comfimed-free-qnty"
                                                   no-error .
    if not available buf_utd-lines-attr
    then do :
      create buf_utd-lines-attr .
      assign
        buf_utd-lines-attr.doc-id = bf_utd-lines.doc-id   
        buf_utd-lines-attr.db-num = bf_utd-lines.db-num   
        buf_utd-lines-attr.LineNum = bf_utd-lines.LineNum 
        buf_utd-lines-attr.attr-code = "comfimed-free-qnty"
      .
    end .
    if available buf_gds-obj
    then do : 
      assign buf_utd-lines-attr.attr-value = string(buf_gds-obj.free-qnty) .
    end .
    else
    if available X_utd-lines
    then do :
      assign buf_utd-lines-attr.attr-value = string(X_utd-lines.free-qnty) .
    end .
  end .
  
  if is-initial-set
  then do :
    for each bf_utd-marking-lines no-lock where bf_utd-marking-lines.db-num  = buf_utd.db-num
                                            and bf_utd-marking-lines.doc-id  = buf_utd.doc-id
                                            and bf_utd-marking-lines.site   <> "only-send",
    first bf_marking no-lock where bf_marking.mark = bf_utd-marking-lines.mark
    :
      if bf_marking.sts = objSrv:Env:Marking:Sts:Mark:OutOfInventory:KeyIntDB
      then do :
        find current bf_marking exclusive-lock .
        assign bf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB .
      end .
    end .
  end .
  
  assign buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:Confirmed:KeyIntDB .
  validate buf_utd .
  
  run waitfram-hide in this-procedure .  
  apply "choose" to b-exit in frame Dialog-Frame .
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME c-status
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-status Dialog-Frame
ON VALUE-CHANGED OF c-status IN FRAME Dialog-Frame
DO:
  assign c-status .
  if c-type = 0 then 
  do:
    message "Укажите тип документа"
      view-as alert-box.
  end.  
  
  buf_utd.sts = integer(c-status).
  validate buf_utd no-error.
  c-status = buf_utd.sts.
  display c-status with frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-type Dialog-Frame
ON VALUE-CHANGED OF c-type IN FRAME Dialog-Frame /* Тип */
DO:
  assign c-type .
  if available (buf_utd) then buf_utd.EDocType = c-type .
  F-msg = "                            Просканируйте марку" . 
  display F-msg with frame {&frame-name} .
  run enable_UI .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-date Dialog-Frame
ON leave OF f-date IN FRAME Dialog-Frame
DO:
    assign f-date .
    if f-num:SCREEN-VALUE <> "" and f-num:SCREEN-VALUE <> ? then do:
        find first ub.utd no-lock where ub.utd.DocumentNumber = f-num
            and ub.utd.DocumentDate = f-date 
            and (ub.utd.EDocType = objSrv:Env:Utd:EDocType:AKT:KeyIntDB
            or ub.utd.EDocType = objSrv:Env:Utd:EDocType:UTD:KeyIntDB)no-error .
        if AVAILABLE (ub.utd) then 
        do:
            MESSAGE "Документ с № " + ub.utd.DocumentNumber + " от даты: " + string(ub.utd.DocumentDate) + " уже заведен в системе." skip
                VIEW-AS ALERT-BOX.
            return NO-APPLY .
        end.    
    end.      
    display f-date with frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-date Dialog-Frame
ON RETURN OF f-date IN FRAME Dialog-Frame
DO:
  apply "TAB":U to self .
  return no-apply .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-date Dialog-Frame
ON TAB OF f-date IN FRAME Dialog-Frame
DO:
    assign f-date .
    display f-date with frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-num Dialog-Frame
ON leave OF f-num IN FRAME Dialog-Frame
DO:
    assign f-num .
    if f-date:SCREEN-VALUE <> "" and f-num:SCREEN-VALUE <> "" then do:
        find first ub.utd no-lock where ub.utd.DocumentNumber = f-num
            and ub.utd.DocumentDate = f-date 
            and (ub.utd.EDocType = objSrv:Env:Utd:EDocType:AKT:KeyIntDB
            or ub.utd.EDocType = objSrv:Env:Utd:EDocType:UTD:KeyIntDB)no-error .
        if AVAILABLE (ub.utd) then 
        do:
            MESSAGE "Документ с № " + ub.utd.DocumentNumber + " от даты: " + string(ub.utd.DocumentDate) + " уже заведен в системе." skip
                VIEW-AS ALERT-BOX.
            return NO-APPLY .
        end.    
    end.      
    display f-num with frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define BROWSE-NAME br-utd-lines
&Scoped-define SELF-NAME br-utd-lines
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-utd-lines Dialog-Frame
ON ROW-DISPLAY OF br-utd-lines IN FRAME Dialog-Frame
DO:
  if available X_utd-lines
  then do :
    if buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB
    then do :
      find first buf_goods no-lock where buf_goods.gds-code = X_utd-lines.gds-code .
      find first buf_gds-obj no-lock where buf_gds-obj.obj-type  = v-cntxt-obj-type
                                       and buf_gds-obj.obj-code  = v-cntxt-obj-code
                                       and buf_gds-obj.artic     = buf_goods.artic
                                       and buf_gds-obj.prod-type = buf_goods.prod-type
                                       and buf_gds-obj.prod-code = buf_goods.prod-code
                                       no-error .
      if available buf_gds-obj
      then do :
        if buf_gds-obj.free-qnty <> X_utd-lines.free-qnty
        then do :
          assign X_utd-lines.free-qnty = buf_gds-obj.free-qnty .
  /*        br-utd-lines:refresh() .*/
        end .
      end .
    end .
    if X_utd-lines.Quantity < X_utd-lines.free-qnty
    then do :
      assign
        X_utd-lines.LineNum     :fGCOLOR in browse br-utd-lines = red_COLOR
        X_utd-lines.gds-code    :fGCOLOR in browse br-utd-lines = red_COLOR
        X_utd-lines.GdsName     :fGCOLOR in browse br-utd-lines = red_COLOR
        X_utd-lines.UnitCode    :fGCOLOR in browse br-utd-lines = red_COLOR
        X_utd-lines.Quantity    :fGCOLOR in browse br-utd-lines = red_COLOR
        X_utd-lines.free-qnty   :fGCOLOR in browse br-utd-lines = red_COLOR
/*        X_utd-lines.qnty-mark   :fGCOLOR in browse br-utd-lines = red_COLOR*/
      .
    end .   
  end .
END .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-num Dialog-Frame
ON value-changed OF f-num IN FRAME Dialog-Frame
DO:
  assign f-num .
  display f-num with frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-obj-TH
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-obj-TH Dialog-Frame
ON CHOOSE OF r-obj-TH IN FRAME Dialog-Frame
DO:
/*    run ref/cli-all.w (                                                         */
/*      input parparentproc                                                       */
/*      ,input "b-sel"                                                            */
/*      ,input {&shop}                                                            */
/*      ,input {&all}                                                             */
/*      ,input {&current}                                                         */
/*      ,input ?                                                                  */
/*      ,input ",,,,,,NO,,"                                                       */
/*      ,input ""                                                                 */
/*      ,output v-rid-list ) NO-ERROR.                                            */
/*    IF v-rid-list = '':U THEN RETURN NO-APPLY.                                  */
/*    FIND FIRST buf_clients NO-LOCK WHERE                                        */
/*      recid(buf_clients) = INTEGER(v-rid-list) NO-ERROR.                        */
/*    IF NOT AVAILABLE buf_clients THEN RETURN NO-APPLY.                          */
/*    ASSIGN                                                                      */
/*      f-obj-type-TH = buf_clients.obj-type                                      */
/*      f-obj-code-TH = buf_clients.obj-code                                      */
/*      f-obj-name-TH = buf_clients.obj-name                                      */
/*      .                                                                         */
/*    display f-obj-code-TH f-obj-type-TH f-obj-name-TH  with frame {&frame-name}.*/
/*    disable r-obj-TH with frame {&frame-name} .                                 */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-mark Dialog-Frame
ON any-printable OF v-mark IN FRAME Dialog-Frame /* Марка */
do:

  run proc-any-key.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-mark Dialog-Frame
ON ENTRY OF v-mark IN FRAME Dialog-Frame /* Марка */
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-mark Dialog-Frame
ON LEAVE OF v-mark IN FRAME Dialog-Frame /* Марка */
DO:
    assign frame {&frame-name} v-mark .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-mark Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF v-mark IN FRAME Dialog-Frame /* Марка */
DO:
    run save_update .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-mark Dialog-Frame
ON return OF v-mark IN FRAME Dialog-Frame /* Марка */
DO:
    run save_update .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} 
do:
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  if p-mode = {&add-def} and available (buf_utd) then 
  do:
     delete buf_utd .
  end.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define BROWSE-NAME br-utd-lines
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
  THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
/*{ gbl/app_help.i }*/
MAIN-BLOCK:
do trans ON ERROR UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  :
  { gbl/getcntxt.i get }
  assign v-num-str = 0 .
  Marking = ObjSrv:Env:Marking:Sts:Mark .
  
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
  
  if p-mode = {&add-def} then 
  do:
    if not available (buf_utd) then 
    do:
      create buf_utd .
      assign
        buf_utd.DocumentDate = today
        buf_utd.sts          = ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB
        buf_utd.obj-code     = v-cntxt-obj-code
        buf_utd.obj-type     = v-cntxt-obj-type
        buf_utd.host-code    = v-cntxt-host-code-obj
        buf_utd.EDocType     = objSrv:Env:Utd:EDocType:Mark_Collect:KeyIntDB
      .
      validate buf_utd .
      assign buf_utd.DocumentNumber = string(buf_utd.doc-id) + "-" + string(v-cntxt-obj-code) + substring(v-cntxt-obj-type,1,1) .
    end.      
  end.
  else 
  do:
    if p-mode = {&lookup} then find first buf_utd no-lock where buf_utd.doc-id = p-doc-id and buf_utd.db-num = p-db-num no-error .
    if p-mode = {&update} then find first buf_utd exclusive-lock where buf_utd.doc-id = p-doc-id and buf_utd.db-num = p-db-num no-wait no-error .
    if  error-status:error then 
    do: 
      message "Документ занят другим пользователем"
      view-as alert-box.
      p-mode = {&lookup} .
      find first buf_utd no-lock where buf_utd.doc-id = p-doc-id and buf_utd.db-num = p-db-num no-error .
    end.
  end.
  if available (buf_utd) then 
  do:
    assign
      f-num          = buf_utd.DocumentNumber
      f-date         = buf_utd.DocumentDate
      c-status       = buf_utd.sts
      f-obj-code-TH  = buf_utd.obj-code
      f-obj-type-TH  = buf_utd.obj-type
      f-obj-name-TH  = CliName(buf_utd.obj-code, buf_utd.obj-type)
      c-type         = buf_utd.EDocType
      f-comment      = buf_utd.comment
    .
    assign
      frame {&frame-name}:title = "Сбор марок_____№ " + string (buf_utd.DocumentNumber) + "_____" + p-mode
    .
  end .
  
  find first buf_utd-attr no-lock where buf_utd-attr.db-num = buf_utd.db-num
                                    and buf_utd-attr.doc-id = buf_utd.doc-id
                                    and buf_utd-attr.attr-code = "is-initial-set"
                                    no-error .
  if available buf_utd-attr
  then do :
    assign is-initial-set = logical(buf_utd-attr.attr-value) no-error .
  end .
  
  assign vLineNum = 0 .
  for each buf_utd-lines no-lock where buf_utd-lines.doc-id = buf_utd.doc-id
                                   and buf_utd-lines.db-num = buf_utd.db-num,
  first buf_goods no-lock where buf_goods.gds-code = buf_utd-lines.gds-code 
  :
    assign vLineNum = max(vLineNum, buf_utd-lines.LineNum) .
    
    find first X_utd-lines EXCLUSIVE-LOCK where buf_utd-lines.doc-id = X_utd-lines.doc-id
                                            and buf_utd-lines.db-num = X_utd-lines.db-num
                                            and buf_utd-lines.LineNum = X_utd-lines.LineNum
                                            no-error . 
    buffer-copy buf_utd-lines to X_utd-lines .
    assign X_utd-lines.GdsName = buf_goods.gds-name .
    if buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:Confirmed:KeyIntDB
    then do :
      find first buf_utd-lines-attr no-lock where buf_utd-lines-attr.doc-id = buf_utd-lines.doc-id
                                              and buf_utd-lines-attr.db-num = buf_utd-lines.db-num
                                              and buf_utd-lines-attr.LineNum = buf_utd-lines.LineNum 
                                              and buf_utd-lines-attr.attr-code = "comfimed-free-qnty"
                                              no-error .
      if available buf_utd-lines-attr
      then do :
        assign X_utd-lines.free-qnty = decimal(buf_utd-lines-attr.attr-value) .
      end .
    end .
    else do :
      find first buf_gds-obj no-lock where buf_gds-obj.obj-type  = v-cntxt-obj-type
                                       and buf_gds-obj.obj-code  = v-cntxt-obj-code
                                       and buf_gds-obj.artic     = buf_goods.artic
                                       and buf_gds-obj.prod-type = buf_goods.prod-type
                                       and buf_gds-obj.prod-code = buf_goods.prod-code
                                       no-error .
      if available buf_gds-obj
      then do :
        assign X_utd-lines.free-qnty = buf_gds-obj.free-qnty .
      end .
    end .
    
    for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.doc-id   = buf_utd-lines.doc-id
                                             and buf_utd-marking-lines.db-num   = buf_utd-lines.db-num
                                             and buf_utd-marking-lines.LineNum  = buf_utd-lines.LineNum
                                             and buf_utd-marking-lines.doc-level = 1
                                             and buf_utd-marking-lines.site    <> "only-send"
    :
      assign X_utd-lines.qnty-mark = X_utd-lines.qnty-mark + 1 .
    end .
    
    if not disable-set
    then do :
      run gdsoattr-value in this-procedure (input   {&attr-mark-collect-type},
                                            input   buf_goods.gds-code,
                                            input   buf_utd.obj-type,
                                            input   buf_utd.obj-code,
                                            output  v-attr-value,
                                            output  v-attr-type
                                            ) no-error.
      if is-initial-set
      and (v-attr-value = "" or v-attr-value = "0")
      then do :
        assign disable-set = yes .
      end .
    end .
  end .
  
  RUN enable_UI.
  display 
    F-msg
    f-num
    f-date
    c-type
    c-status
    f-obj-code-TH
    f-obj-type-TH
    f-obj-name-TH
    f-comment
    is-initial-set
  with frame {&frame-name}.
  
  apply "entry" to v-mark in FRAME {&FRAME-NAME}.

  enable v-mark with frame {&frame-name}.
  on F9 of frame {&frame-name} anywhere 
  do:
    if not available X_utd-lines then  return no-apply.
    find first goods no-lock where goods.gds-code = X_utd-lines.gds-code .
    gds-rec = recid(goods) .
    run ref/gds-form.w
        (input  parParentProc
        ,input  {&lookup}
        ,input  v-cntxt-obj-type
        ,input  v-cntxt-obj-code
        ,input ? /*p-call-handle*/
        ,input-output gds-rec
        ).

    apply "entry" to br-utd-lines in frame {&frame-name}.
    return no-apply.
  end.
  
  if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):IsManual
  then v-manual = yes.
  else do:
    v-manual = no .
    v-mark:READ-ONLY IN FRAME {&frame-name} = TRUE .
  end.   
  
  if p-mode = {&lookup}
  then do :
    disable v-mark b-exit b_prov-finish b_del-line is-initial-set with frame {&frame-name}.
    f-comment:read-only = yes .
  end .
  
  if disable-set then disable is-initial-set with frame {&frame-name}.

  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus v-mark .
END.
RUN disable_UI.

/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ActivateKeyboardLayout Dialog-Frame 
PROCEDURE ActivateKeyboardLayout external "user32" :
define input parameter P1 as LONG.
   define input parameter P2 as LONG.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CrCheckMark Dialog-Frame 
PROCEDURE CrCheckMark :
  define variable vmes as character no-undo.
  vmes = CrCheckMarkDoc(v-cntxt-obj-type, v-cntxt-obj-code,
                 buf_utd.db-num, buf_utd.doc-id,
                 v-mark:screen-value in frame {&frame-name},
                 is-initial-set).
   if vmes ne ""
   then
      run dispmessage (vmes).              
  end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE temp-mark Dialog-Frame 
PROCEDURE temp-mark :
   /* --------------------------------------------------------------------
                           Purpose:     ENABLE the User Interface
                           Parameters:  <none>
                           Notes:       Here we display/view/enable the widgets in the
                                        user-interface.  In addition, OPEN all queries
                                        associated with each FRAME and BROWSE.
                                        These statements here are based on the "Other
                                        Settings" section of the widget Property Sheets.
                            -------------------------------------------------------------------- */
   define input parameter p-id as integer no-undo .
   define buffer buf_marking for ub.marking .
   empty temp-table tt-marking-lines .
   define variable mQuery as handle    no-undo.
   define variable vqry   as character no-undo.
   define variable vsite  as character no-undo.
   vsite = " and buf_utd-marking-lines.site <> 'only-send'" .
   create query mQuery.
   mQuery:set-buffers(buffer buf_utd-marking-lines:HANDLE).
   vqry = substitute("for each buf_utd-marking-lines no-lock where ~
                               buf_utd-marking-lines.db-num = &1 ~
                           and buf_utd-marking-lines.doc-id = &2 " 
                           ,  buf_utd.db-num, buf_utd.doc-id, vsite).
 
   if p-id = 1 
   then
      vqry = vqry + substitute (" and buf_utd-marking-lines.LineNum = &1",X_utd-lines.LineNum). 
    mQuery:query-prepare(vqry + vsite).
    mQuery:query-open ().
    mQuery:get-first ().
                                                                         
    do while not mQuery:query-off-end:
       create tt-marking-lines .
       assign
          tt-marking-lines.gds-name  = GdsName(buf_utd-marking-lines.gds-code)
          tt-marking-lines.stts-utd  = StatusTHName(buf_utd-marking-lines.sts)
          tt-marking-lines.mark      = buf_utd-marking-lines.mark
          tt-marking-lines.gds-code  = buf_utd-marking-lines.gds-code
          tt-marking-lines.sts-utd   = buf_utd-marking-lines.sts
          tt-marking-lines.LineNum   = buf_utd-marking-lines.LineNum
          tt-marking-lines.db-num    = buf_utd-marking-lines.db-num
          tt-marking-lines.doc-id    = buf_utd-marking-lines.doc-id
          tt-marking-lines.doc-level = buf_utd-marking-lines.doc-level
          tt-marking-lines.site      = buf_utd-marking-lines.site
       .
       tt-marking-lines.isMark    = IsMark(tt-marking-lines.mark).
      
       find first utd-marking-lines-attr where utd-marking-lines-attr.doc-id    eq buf_utd-marking-lines.doc-id  
                                           and utd-marking-lines-attr.db-num    eq buf_utd-marking-lines.db-num
                                           and utd-marking-lines-attr.LineNum   eq buf_utd-marking-lines.LineNum
                                           and utd-marking-lines-attr.mark      eq buf_utd-marking-lines.mark
                                           and utd-marking-lines-attr.attr-code eq "box-qnty"
       no-lock no-error.
       if avail utd-marking-lines-attr
       then
          tt-marking-lines.box-qnty = dec(utd-marking-lines-attr.attr-value).
          
       if tt-marking-lines.isMark then 
       do:
            
          for first buf_marking  where buf_marking.mark begins buf_utd-marking-lines.mark :
             assign
                tt-marking-lines.sts         = buf_marking.sts
                tt-marking-lines.unit        = buf_marking.unit
                tt-marking-lines.unit-ext    = buf_marking.unit-ext
                tt-marking-lines.box-qnty    = buf_marking.box-qnty  when tt-marking-lines.box-qnty eq 0 or tt-marking-lines.box-qnty eq ?
                tt-marking-lines.mark-parent = buf_marking.mark-parent
             .
             tt-marking-lines.stts        = StatusTHName(buf_marking.sts).
          end.
       end.   
       else 
       do:
/*          if X_utd-lines.qnty-scan = X_utd-lines.Quantity then */
          tt-marking-lines.stts-utd = StatusTHName(Marking:Checked_:KeyIntDB) .
/*          tt-marking-lines.box-qnty = X_utd-lines.qnty-scan .*/
       end.
      mQuery:get-next ().
   end.
   delete object mQuery.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE dispmessage Dialog-Frame 
PROCEDURE dispmessage :
define input parameter p-str as character no-undo.
  f-msg:fgcolor in frame {&FRAME-NAME} = 12.
  do:
    display p-str @ f-msg with frame {&frame-name}.
/*    message p-str view-as alert-box information title "Информация".*/
  end.
  
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
  DISPLAY c-type f-num-name f-num f-date-name f-date is-initial-set 
          f-obj-type-TH f-obj-code-TH f-obj-name-TH f-status-TH c-status 
          f-comment f-comment-name v-mark a-n-c a-n-c-name 
          f-msg R-error
      WITH FRAME Dialog-Frame.
  ENABLE b-cancel b-exit B_mark
         is-initial-set R-error
         f-comment v-mark a-n-c a-n-c-name
         br-utd-lines b_prov-finish b_del-line 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE LoadKeyboardLayoutA Dialog-Frame 
PROCEDURE LoadKeyboardLayoutA external "user32" :
define input  parameter P1 as char.
  define input  parameter P2 as LONG.
  define return parameter pret as LONG.
end procedure.

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save_update Dialog-Frame 
PROCEDURE save_update :
define variable v-error      as logical   no-undo init no.
  define variable l-error      as logical   no-undo init no.
  define variable v-error-lang as logical   no-undo init no.
  define variable v_list    as character no-undo .
          
  define variable ii           as integer   no-undo .
  define variable chg-qnty     as integer   no-undo .
  
  do trans:
    f-msg:screen-value in frame {&FRAME-NAME} = "" .
    
    if v-mark:screen-value in frame {&frame-name} = ""
    then do:
      v-mark:screen-value in frame {&frame-name} = v-scan-str.
      v-scan-str = "". 
    end.
    
    assign 
      v-mark = v-mark:screen-value in frame {&frame-name}.
    if v-mark = ""
      then return.
      
    assign v_list = 'Ё,Й,Ц,У,К,Е,Н,Г,Ш,Щ,З,Х,Ъ,Ф,Ы,В,А,П,Р,О,Л,Д,Ж,Э,Я,Ч,С,М,И,Т,Ь,Б,Ю':U .
    
    /*проверка на русские буквы*/
    do ii = 1 to length (v-mark):
      if lookup(substring(v-mark, ii, 1), v_list) > 1
      then do:
        message "Не корректно считана акцизная марка, перед считыванием переключите клавиатуру на английскую раскладку."
        view-as alert-box.
        v-mark:screen-value in frame {&frame-name} = "" .
        v-mark = "" .
        return .  
      end.
    end.
    
    run CrCheckMark.

    {&open-query-br-utd-lines}
    
    v-mark = "".
    v-mark:screen-value in frame {&frame-name} = "".
    v-mark-short = "".
  end.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

