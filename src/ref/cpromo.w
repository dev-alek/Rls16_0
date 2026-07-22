&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_c-PromoAction FOR c-PromoAction.
DEFINE BUFFER X_PromoAction FOR PromoAction.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список истории промо-акций

Автор: Бахтадзе Наталья Викторовна
Дата создания: 14/08/18
Author: Bakhtadze Natalya
Creation date: 14/08/18

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/
/* Как отображается история изменений
1. Создалась новая запись.
   Верхний список содержит одну запись с изменениями.
   В верхнем списке "старая" запись, до изменений.
   Заполнены поля первичного индекса (ид. и номер БД), пользователь, дата и время создания.
   Наименование и остальные поля, вводимые пользователем, пустые, т.е. заполнены значениями по умолчанию.
   Нижний список содержит перечень полей, кроме полей первичного индекса,
   значения которых стали отличаться от значений по умолчанию.
   Значения этих полей либо введены пользователем, либо автоматически заполнены формой ввода.
   В графе "Было" указаны значения, с которыми запись создалась,
   т.е. значения по-умолчанию, присваиваемые полям при создании пустой записи в БД.
   В графе "Стало" значения этих же полей из основной таблицы, т.е. те, которые записались в БД в результате внесения изменений.
2. Отредактирована ранее созданная запись
   Верхний список содержит две записи с изменениями.
   Первая - как описано в п.1 по созданию новой записи, вторая - запись сразу после сохранения при создании.
   Вторая запись отражает состояние до изменений, сделанных редактированием.
   Там могут быть заполнены поля, вводимые пользователем, как они были до редактирования.
   Нижний список содержит перечень полей, кроме полей первичного индекса,
   значения которых стали отличаться от значений до редактирования.
   Чаще всего это поля, значения которых пользователь изменил в форме ввода.
   Реже к ним могут добавляться связанные поля, автоматически пересчитанные в соответствии с введёнными пользователем значениями.
   В графе "Было" указаны значения из таблицы истории, в графе "Стало" - значения из основной таблицы.
*/
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter bttns         as character no-undo . /*кнопки для нажатия*/
define input parameter p-mode        as character no-undo . /*one*/
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.
define input parameter p-actionId like ub.PromoAction.id no-undo .
define input-output param p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список истории промо-акций":U.
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/r-pril.i new }
{ gbl/waitfram.i }
{ gbl/prn-lib.i }
{ gbl/cur-time.i }
{ cmp/mrk-strf.i }
{ gbl/usrfulnf.i }
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable sort-column-name as character no-undo .
define variable v-db-num LIKE ub.db.db-num no-undo.


{ ref/tmpchgs.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-changes

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-changes X_c-PromoAction

/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes   
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for BROWSE br-wp                                         */
&Scoped-define FIELDS-IN-QUERY-br-wp mark-string(recid(X_c-PromoAction), p-rid-list) usrfulnf(X_c-PromoAction.corr-user-name) X_c-PromoAction.corr-date string(X_c-PromoAction.corr-time, "HH:MM") X_c-PromoAction.id X_c-PromoAction.nameAction   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-wp   
&Scoped-define SELF-NAME br-wp
&Scoped-define QUERY-STRING-br-wp FOR EACH X_c-PromoAction NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-wp OPEN QUERY {&SELF-NAME} FOR EACH X_c-PromoAction NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-wp X_c-PromoAction
&Scoped-define FIRST-TABLE-IN-QUERY-br-wp X_c-PromoAction


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-wp}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel B-Help br-wp BR-changes ~
mark-num 
&Scoped-Define DISPLAYED-OBJECTS mark-num 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-mark 
     LABEL "&*" 
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sel AUTO-GO 
     LABEL "Вы&бор" 
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-changes FOR 
      temp-changes SCROLLING.

DEFINE QUERY br-wp FOR 
      X_c-PromoAction SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes Dialog-Frame _FREEFORM
  QUERY BR-changes DISPLAY
temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(120)"
temp-changes.v_old COLUMn-LABEL "Было" format "X(70)"
temp-changes.v_new COLUMn-LABEL "Стало" format "X(70)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 9.05.

DEFINE BROWSE br-wp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-wp Dialog-Frame _FREEFORM
  QUERY br-wp NO-LOCK DISPLAY
      mark-string(recid(X_c-PromoAction), p-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      usrfulnf(X_c-PromoAction.corr-user-name) COLUMN-LABEL "Изменил" FORMAT "X(18)":U
      X_c-PromoAction.corr-date COLUMN-LABEL "Дата!измен" FORMAT "99/99/9999":U
      string(X_c-PromoAction.corr-time, "HH:MM") COLUMN-LABEL "Время!измен" FORMAT "X(5)":U
      X_c-PromoAction.id COLUMN-LABEL "ид.!акции" FORMAT ">>>,>>9":U
      X_c-PromoAction.nameAction COLUMN-LABEL "Наименование акции" FORMAT "x(40)":U
      X_c-PromoAction.TypeDiscont
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 9.24 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 21
     B-Help AT ROW 1 COL 95
     br-wp AT ROW 3 COL 1
     BR-changes AT ROW 13 COL 1
     mark-num AT ROW 1 COL 12.6 COLON-ALIGNED NO-LABEL
     SPACE(78.52) SKIP(20.05)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "История промо-акций"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_c-PromoAction B "?" ? ub c-PromoAction
      TABLE: X_PromoAction B "?" ? ub PromoAction
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-wp B-Help Dialog-Frame */
/* BROWSE-TAB BR-changes br-wp Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN 
       br-wp:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 1
       br-wp:COLUMN-RESIZABLE IN FRAME Dialog-Frame       = TRUE
       br-wp:COLUMN-MOVABLE IN FRAME Dialog-Frame         = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-changes
/* Query rebuild information for BROWSE BR-changes
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-changes */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-wp
/* Query rebuild information for BROWSE br-wp
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_c-PromoAction NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-wp */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* История промо-акций */
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
  if available X_c-PromoAction then do:
    { gbl/markstrn.i X_c-PromoAction p-rid-list }
    loc#log = br-wp:refresh() .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-wp:select-next-row ().
        apply "VALUE-CHANGED" to br-wp in frame {&frame-name}.
    end.
    if num-entries( p-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( p-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-wp in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if ( available X_c-PromoAction ) then do:
    if  ( p-rid-list = "" ) or b-mark:sensitive = no
    then
    p-rid-list = string( recid( X_c-PromoAction ) ) .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-wp
/* 14/VIII-2018 - не применяется
&Scoped-define SELF-NAME br-wp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-wp Dialog-Frame
ON RETURN OF br-wp IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-wp IN FRAME Dialog-Frame
    DO:
    run proc-br-wp no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
*/

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-wp Dialog-Frame
ON VALUE-CHANGED OF br-wp IN FRAME Dialog-Frame
DO:
  run proc-view-changes in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-changes
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i &disable_diasize_init=true &browse-name="br-wp" }
{ gbl/brwrefre.i "
    v-doc-rec = recid(X_c-PromoAction).
    run openbr in this-procedure.
    reposition br-wp to recid v-doc-rec no-error.
    apply 'value-changed' to br-wp.
" }
{ gbl/srt-clmn.i
  &browse-name    = "br-wp"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "X_c-PromoAction.nameAction"
  &sort-clmn_2    = "X_c-PromoAction.corr-date"
  &open-query     = "run OpenBr."
  &open-query-otherwise = "run OpenBr."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}
{ gbl/brwrepos.i
  &line-num=5
}

{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 if LOOKUP(p-mode, 'one':U, {&delim-par}) = 0 then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"
    p-mode
    view-as alert-box ERROR.
    return error .
 end.
  if p-mode = "one":U then do:
   find first X_c-PromoAction no-lock
        where X_c-PromoAction.id = p-ActionId no-error.
    if not available X_c-PromoAction then do:
        message
        vss-workfile vss-revision vss-description skip
        substitute("Отсутствует история промо-акции с ид. &1", p-ActionId)
        view-as alert-box ERROR.
        // 14/VIII-2018 - продолжаем выполнение, чтобы посмотреть как отображается список return.
    end.
  end.

  RUN MyEnable.
  RUn OpenBR.
  HIDE mark-num in frame {&frame-name} .
  if v-doc-rec <> ? then
  REPOSITION br-wp to recid v-doc-rec No-ERROR.
 run diasize_add_browse in this-procedure
    (input  'width':u
    ,input  browse br-changes :handle
    ) .
 run diasize_init in this-procedure .
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
  DISPLAY mark-num 
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel B-Help br-wp BR-changes mark-num 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
assign
temp-changes.l_name:resizable in browse br-changes = true
temp-changes.v_old:resizable in browse br-changes = true
temp-changes.v_new:resizable in browse br-changes = true
temp-changes.l_name:width in browse br-changes = 30
temp-changes.v_old:width in browse br-changes = 40
temp-changes.v_new:width in browse br-changes = 40
.
DISPLAY mark-num
WITH FRAME {&frame-name}.
ENABLE
b-quit
B-mark when LOOKUP("b-mark":U, bttns) > 0
B-sel when LOOKUP("b-sel":U, bttns) > 0
B-Help
br-wp mark-num
br-changes
with FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame 
PROCEDURE OpenBr :
define variable v-host-code as integer no-undo .
OPEN QUERY br-wp FOR EACH X_c-PromoAction NO-LOCK
                    where X_c-PromoAction.id = p-ActionId
                              INDEXED-REPOSITION.
APPLY "VALUE-CHANGED" TO br-wp in frame {&frame-name}.
APPLY "ENTRY" TO br-wp.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* 14/VIII-2018 не применяется
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-wp Dialog-Frame 
PROCEDURE proc-br-wp :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
*/


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-view-changes Dialog-Frame 
PROCEDURE proc-view-changes :
/* 17/IV-2018 - то же самое выполняется внутри proc-full-temp-changes()
for each temp-changes:
    delete temp-changes.
END.
if not available X_c-sr-izmerenia then do:
  Open QUery br-changes for each temp-changes.
  return.
end.
*/
&scop fields-name-list "id,beg-date,end-date,nameAction,TypeDiscont,methodCalc,typecond,promosched-id,Status_,priority,comment,description,paymenttype,changeDate,ext-code,db-num"
define variable v-label-param as character no-undo .

v-label-param =   "id" + {&delim-par} + "Ид.промо-акции" + {&delim-par} + ""
 + {&delim-flf} + "beg-date"  + {&delim-par} + "Дата начала" + {&delim-par} + ""
 + {&delim-flf} + "end-date"  + {&delim-par} + "Дата окончания" + {&delim-par} + ""
 + {&delim-flf} + "nameAction"  + {&delim-par} + "Наименование" + {&delim-par} + ""
 + {&delim-flf} + "TypeDiscont"  + {&delim-par} + "Тип скидки" + {&delim-par} + ""
 + {&delim-flf} + "methodCalc"  + {&delim-par} + "Метод расчёта" + {&delim-par} + ""
 + {&delim-flf} + "typecond"  + {&delim-par} + "Вид условия" + {&delim-par} + ""
 + {&delim-flf} + "promosched-id"  + {&delim-par} + "Ид.расписания" + {&delim-par} + ""
 + {&delim-flf} + "Status_"  + {&delim-par} + "Статус" + {&delim-par} + ""
 + {&delim-flf} + "priority"  + {&delim-par} + "Приоритет" + {&delim-par} + ""
 + {&delim-flf} + "comment"  + {&delim-par} + "Комментарий" + {&delim-par} + ""
 + {&delim-flf} + "description"  + {&delim-par} + "Описание" + {&delim-par} + ""
 + {&delim-flf} + "paymenttype"  + {&delim-par} + "Коды типов платежей" + {&delim-par} + ""
 + {&delim-flf} + "changeDate"  + {&delim-par} + "Дата досрочного завершения" + {&delim-par} + ""
 + {&delim-flf} + "ext-code"  + {&delim-par} + "Код промо-акции во внешней системе" + {&delim-par} + ""
 + {&delim-flf} + "db-num"  + {&delim-par} + "Номер БД" + {&delim-par} + ""
.
 run proc-full-temp-changes in this-procedure (
                                             input  buffer X_c-PromoAction:handle
                                            ,input  {&table_PromoAction}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).

Open QUery br-changes for each temp-changes.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

