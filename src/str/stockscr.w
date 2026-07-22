&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
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

Экран продавца

Автор: Суслов Алексей Юрьевич
Дата создания: 09/20/05
Author: Alexey Suslov
Creation date: 09/20/05

*/

/* Parameters Definitions ---                                           */
define input parameter paruser-name as character no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Экран продавца".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ str/stockscr.i }
{ str/libbcrcn.i }
{ cmp/library.i  }
{ gbl/waitfram.i }

&scop length-name 20
&SCOP label-clmn_1-br-dtl   "Артикул"
&SCOP sort-clmn_1-br-dtl    tt-goods.artic
&SCOP label-clmn_2-br-dtl   "Название товара"
&SCOP sort-clmn_2-br-dtl    tt-goods.gds-name
&SCOP label-clmn_3-br-dtl   "Признак"
&SCOP sort-clmn_3-br-dtl    tt-goods.prt-name
&SCOP label-clmn_4-br-dtl   "Изм"
&SCOP sort-clmn_4-br-dtl    tt-goods.unit-base
&SCOP label-clmn_5-br-dtl   "Факт"
&SCOP sort-clmn_5-br-dtl    tt-goods.fact-qnty
&SCOP label-clmn_6-br-dtl   "Свободно"
&SCOP sort-clmn_6-br-dtl    tt-goods.free-qnty
&SCOP label-clmn_7-br-dtl   "Производитель"
&SCOP sort-clmn_7-br-dtl    tt-goods.prod-name
&SCOP label-clmn_8-br-dtl   "Группа"
&SCOP sort-clmn_8-br-dtl    tt-goods.grp-name

/* Local Variable Definitions ---                                       */

define temp-table tt-goods no-undo
field artic     like ub.goods.artic
field prod-type like ub.goods.prod-type
field prod-code like ub.goods.prod-code
field prt-code  like ub.prt-obj.prt-code
field ford-num  as   character
field gds-name  like ub.goods.gds-name
field prt-name  like ub.gds-prt.f-name
field prod-name like ub.clients.obj-name
field grp-name  like ub.gds-grp.node-name
field unit-base like ub.goods.unit-base
field fact-qnty like ub.prt-obj.fact-qnty
field free-qnty like ub.prt-obj.free-qnty
field ford-num-0 like ub.gds-prt.prt-num
field ford-num-1 like ub.gds-prt.prt-num
field ford-num-2 like ub.gds-prt.prt-num
field prt-root like ub.gds-prt.prt-root
index pi is unique primary  artic prod-type prod-code prt-code
index ford-num artic prod-type prod-code ford-num-0 ford-num-1 ford-num-2 prt-code
index gds-name gds-name
index prt-name prt-root prt-name
index artic artic.
define temp-table tt-cont-goods no-undo like ub.goods.

define temp-table tt-stock no-undo
field obj-type   like ub.clients.obj-type
field obj-code   like ub.clients.obj-code
field host-code  like ub.clients.obj-code
field host-name  like ub.clients.obj-name
field artic      like ub.goods.artic
field prod-type  like ub.goods.prod-type
field prod-code  like ub.goods.prod-code
field prt-code   like ub.prt-obj.prt-code
field fact-qnty  like ub.prt-obj.fact-qnty
field free-qnty  like ub.prt-obj.free-qnty
field data-date  as   date
field data-time  as   integer
field price-sale like ub.price-list.price-sale
field level as integer
index pi is unique primary obj-type obj-code artic prod-type prod-code prt-code
index level level
index goods artic prod-type prod-code prt-code.

define variable varchg as logical no-undo.
define variable is-slscrvalue as character no-undo.
define variable is-slscrtype  as character no-undo.
define variable numslscrvalue as character no-undo.
define variable numslscrtype  as character no-undo.
define variable numslscrvalue_int as integer no-undo.
define buffer buf_batchprocess for ub.batchprocess.
function string-time returns character (input parint-time as integer) :
 return string(parint-time, "hh:mm:ss").
end.
procedure full-grp:
def input param n-code like ub.gds-grp.node-code no-undo.
def input-output param name like ub.goods.grp-name no-undo.

def var uc like ub.gds-grp.upper-code no-undo.

/* собираем полное имя, игнорируя корневой узел */
name = ''.
find ub.gds-grp where ub.gds-grp.node-code = n-code.
do while ub.gds-grp.upper-code <> 0:
  assign
    name = if name = '' then ub.gds-grp.node-name
                 else ub.gds-grp.node-name + '/' + name
    uc = ub.gds-grp.upper-code.
  find ub.gds-grp where ub.gds-grp.node-code = uc.
end.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME b-goods

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-goods tt-cont-goods tt-stock

/* Definitions for BROWSE b-goods                                       */
&Scoped-define FIELDS-IN-QUERY-b-goods {&sort-clmn_1-br-dtl} {&sort-clmn_2-br-dtl} {&sort-clmn_3-br-dtl} {&sort-clmn_4-br-dtl} {&sort-clmn_5-br-dtl} {&sort-clmn_6-br-dtl} {&sort-clmn_7-br-dtl} {&sort-clmn_8-br-dtl}
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-goods {&sort-clmn_8-br-dtl}
&Scoped-define SELF-NAME b-goods
&Scoped-define QUERY-STRING-b-goods FOR EACH tt-goods use-index ford-num, ~
       FIRST tt-cont-goods OUTER-JOIN WHERE TRUE
&Scoped-define OPEN-QUERY-b-goods OPEN QUERY {&SELF-NAME} FOR EACH tt-goods use-index ford-num, ~
       FIRST tt-cont-goods OUTER-JOIN WHERE TRUE.
&Scoped-define TABLES-IN-QUERY-b-goods tt-goods tt-cont-goods
&Scoped-define FIRST-TABLE-IN-QUERY-b-goods tt-goods
&Scoped-define SECOND-TABLE-IN-QUERY-b-goods tt-cont-goods


/* Definitions for BROWSE b-stock                                       */
&Scoped-define FIELDS-IN-QUERY-b-stock tt-stock.obj-code tt-stock.obj-type tt-stock.fact-qnty tt-stock.free-qnty tt-stock.price-sale tt-stock.data-date string-time(tt-stock.data-time)
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-stock
&Scoped-define SELF-NAME b-stock
&Scoped-define QUERY-STRING-b-stock FOR EACH tt-stock where tt-stock.artic     = tt-goods.artic         and                                                 tt-stock.prod-type = tt-goods.prod-type and                                                 tt-stock.prod-code = tt-goods.prod-code and                                                 tt-stock.prt-code  = tt-goods.prt-code  use-index level indexed-reposition
&Scoped-define OPEN-QUERY-b-stock OPEN QUERY {&SELF-NAME} FOR EACH tt-stock where tt-stock.artic     = tt-goods.artic         and                                                 tt-stock.prod-type = tt-goods.prod-type and                                                 tt-stock.prod-code = tt-goods.prod-code and                                                 tt-stock.prt-code  = tt-goods.prt-code  use-index level indexed-reposition.
&Scoped-define TABLES-IN-QUERY-b-stock tt-stock
&Scoped-define FIRST-TABLE-IN-QUERY-b-stock tt-stock


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-b-goods}~
    ~{&OPEN-QUERY-b-stock}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-goods b-exit b-requery b-requery-prt ~
b-admin b-help vargds-name varb-c b-stock vargds-cnt
&Scoped-Define DISPLAYED-OBJECTS varartic vargds-name varb-c vargds-cnt

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-admin
     LABEL "Настройка"
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-requery
     LABEL "Обновить все"
     SIZE 13.5 BY 1.

DEFINE BUTTON b-requery-prt
     LABEL "Обновить признак"
     SIZE 17 BY 1.

DEFINE VARIABLE varartic AS CHARACTER FORMAT "X(19)":U
     LABEL "Артикул"
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE varb-c AS CHARACTER FORMAT "X(256)":U
     LABEL "Бар-код"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE vargds-cnt AS CHARACTER FORMAT "X(256)":U
     LABEL "Начало слова"
     VIEW-AS FILL-IN
     SIZE 27.63 BY 1 NO-UNDO.

DEFINE VARIABLE vargds-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Начало названия"
     VIEW-AS FILL-IN
     SIZE 27.63 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY b-goods FOR
      tt-goods,
      tt-cont-goods SCROLLING.

DEFINE QUERY b-stock FOR
      tt-stock SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE b-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-goods Dialog-Frame _FREEFORM
  QUERY b-goods DISPLAY
      {&sort-clmn_1-br-dtl}                              column-label {&label-clmn_1-br-dtl}
  {&sort-clmn_2-br-dtl}  format "x({&length-name})"  column-label {&label-clmn_2-br-dtl}
  {&sort-clmn_3-br-dtl}  format "x({&length-name})"  column-label {&label-clmn_3-br-dtl}
  {&sort-clmn_4-br-dtl}  format "x(3)"               column-label {&label-clmn_4-br-dtl}
  {&sort-clmn_5-br-dtl}                              column-label {&label-clmn_5-br-dtl}
  {&sort-clmn_6-br-dtl}                              column-label {&label-clmn_6-br-dtl}
  {&sort-clmn_7-br-dtl}  format "x(50)"              column-label {&label-clmn_7-br-dtl}
  {&sort-clmn_8-br-dtl}  format "x(50)"              column-label {&label-clmn_8-br-dtl}
enable {&sort-clmn_8-br-dtl}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.75 BY 10.63.

DEFINE BROWSE b-stock
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-stock Dialog-Frame _FREEFORM
  QUERY b-stock DISPLAY
      tt-stock.obj-code
tt-stock.obj-type
tt-stock.fact-qnty
tt-stock.free-qnty
tt-stock.price-sale
tt-stock.data-date column-label "Дата актуальности"
string-time(tt-stock.data-time) column-label "Время         "
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.75 BY 7.38.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-goods AT ROW 5.5 COL 1.5
     b-exit AT ROW 1 COL 1
     b-requery AT ROW 1 COL 11
     b-requery-prt AT ROW 1 COL 24.5
     b-admin AT ROW 1 COL 41.5
     b-help AT ROW 1 COL 51.5
     varartic AT ROW 2.5 COL 16 COLON-ALIGNED
     vargds-name AT ROW 4 COL 16 COLON-ALIGNED
     varb-c AT ROW 2.5 COL 63.5 COLON-ALIGNED
     b-stock AT ROW 16.25 COL 1.5
     vargds-cnt AT ROW 4 COL 63.5 COLON-ALIGNED
     SPACE(6.12) SKIP(18.63)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Остатки товаров"
         DEFAULT-BUTTON b-exit.


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
   FRAME-NAME Custom                                                    */
/* BROWSE-TAB b-goods 1 Dialog-Frame */
/* BROWSE-TAB b-stock varb-c Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN varartic IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-goods
/* Query rebuild information for BROWSE b-goods
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-goods, FIRST tt-cont-goods OUTER-JOIN WHERE TRUE use-index ford-num indexed-reposition.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE b-goods */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-stock
/* Query rebuild information for BROWSE b-stock
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-stock where tt-stock.artic     = tt-goods.artic         and
                                                tt-stock.prod-type = tt-goods.prod-type and
                                                tt-stock.prod-code = tt-goods.prod-code and
                                                tt-stock.prt-code  = tt-goods.prt-code  use-index level indexed-reposition.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE b-stock */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON END-ERROR OF FRAME Dialog-Frame /* Остатки товаров */
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON return OF FRAME Dialog-Frame /* Остатки товаров */
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Остатки товаров */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-admin
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-admin Dialog-Frame
ON CHOOSE OF b-admin IN FRAME Dialog-Frame /* Настройка */
DO:
define variable varlog as logical no-undo.
  run str/stkscrad.w (input paruser-name, output varchg) no-error.
  if error-status:error then do:
      message "Ошибка при настройке объектов." view-as alert-box.
      return no-apply.
    end.
    if varchg = yes then do:
      for each tt-usrstko :
        delete tt-usrstko.
      end.
      run loadusr-tt in this-procedure (input paruser-name) no-error.
      if error-status:error then do:
        message "Ошибка при работе с объектами пользователя." view-as alert-box.
        return no-apply.
      end.
      message "Набор объектов был изменен."
      "Будем обновлять данные?" view-as alert-box question buttons yes-no update varlog.
      if varlog = yes then do:
        run change-brw in this-procedure no-error.
        if error-status:error then do:
          message "Ошибка при обновлении информации." view-as alert-box error.
          return no-apply.
        end.
      end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b-goods
&Scoped-define SELF-NAME b-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-goods Dialog-Frame
ON ANY-PRINTABLE OF b-goods IN FRAME Dialog-Frame
DO:
    apply "any-printable" to varartic in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-goods Dialog-Frame
ON BACKSPACE OF b-goods IN FRAME Dialog-Frame
DO:
  apply "any-printable" to varartic in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-goods Dialog-Frame
ON GO OF b-goods IN FRAME Dialog-Frame
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-goods Dialog-Frame
ON return OF b-goods IN FRAME Dialog-Frame
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-goods Dialog-Frame
ON VALUE-CHANGED OF b-goods IN FRAME Dialog-Frame
DO:
  {&open-query-b-stock}
  assign
     varartic    = ""
     varb-c      = ""
     vargds-name = ""
     .
     display varartic varb-c vargds-name with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-requery
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-requery Dialog-Frame
ON CHOOSE OF b-requery IN FRAME Dialog-Frame /* Обновить все */
DO:
  run change-brw in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-requery-prt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-requery-prt Dialog-Frame
ON CHOOSE OF b-requery-prt IN FRAME Dialog-Frame /* Обновить признак */
DO:
define variable varobj-type like ub.clients.obj-type no-undo.
define variable varobj-code like ub.clients.obj-code no-undo.
define variable varrec-id as recid no-undo.
define variable parfact-qnty like ub.prt-obj.fact-qnty no-undo.
define variable parfree-qnty like ub.prt-obj.free-qnty no-undo.
define variable varartic like tt-goods.artic no-undo.
define variable varprod-type like tt-goods.prod-type no-undo.
define variable varprod-code like tt-goods.prod-code no-undo.
define variable varprt-code like tt-goods.prt-code no-undo.
define variable varprt-root like tt-goods.prt-root no-undo.
define variable varprt-name like tt-goods.prt-name no-undo.

define buffer bf_tt-goods for tt-goods.
define buffer bf_prt-obj  for ub.prt-obj.
define buffer bf_gds-prt  for ub.gds-prt.
define variable parrec-id as recid no-undo.
if available tt-goods then do:
 assign
    varartic     = tt-goods.artic
    varprod-type = tt-goods.prod-type
    varprod-code = tt-goods.prod-code
    varprt-code  = tt-goods.prt-code
    varprt-root  = tt-goods.prt-root
    varprt-name  = tt-goods.prt-name.
 if available tt-stock then do:
  assign
   varobj-type = tt-stock.obj-type
   varobj-code = tt-stock.obj-code.
 end.
 run waitfram-show in this-procedure
   (input "Подготовка остатков товаров для просмотра"
   ).
 for each bf_tt-goods where bf_tt-goods.artic     = tt-goods.artic     and
                            bf_tt-goods.prod-type = tt-goods.prod-type and
                            bf_tt-goods.prod-code = tt-goods.prod-code and
                            bf_tt-goods.prt-root  = tt-goods.prt-root  and
                            bf_tt-goods.prt-name  begins tt-goods.prt-name :

   for each tt-stock where tt-stock.artic     = bf_tt-goods.artic and
                           tt-stock.prod-type = bf_tt-goods.prod-type and
                           tt-stock.prod-code = bf_tt-goods.prod-code and
                           tt-stock.prt-code  = bf_tt-goods.prt-code :
      delete tt-stock.
   end.
   delete bf_tt-goods.
end.

 for each tt-usrstko no-lock,
   each bf_prt-obj where bf_prt-obj.obj-type  = tt-usrstko.obj-type and
                         bf_prt-obj.obj-code  = tt-usrstko.obj-code and
                         bf_prt-obj.artic     = varartic and
                         bf_prt-obj.prod-type = varprod-type and
                         bf_prt-obj.prod-code = varprod-code no-lock,
       first bf_gds-prt where  bf_gds-prt.node-code = bf_prt-obj.prt-code and
                               bf_gds-prt.prt-root = varprt-root and
                               bf_gds-prt.f-name begins varprt-name no-lock

                      :

   if bf_prt-obj.fact-qnty = 0 and
      bf_prt-obj.free-qnty = 0 then next.
   run create-tt-goods (input bf_prt-obj.artic,
                       input bf_prt-obj.prod-type,
                       input bf_prt-obj.prod-code,
                       input bf_prt-obj.prt-code,
                       output parrec-id) no-error.
   if error-status:error then do:
     message "Ошибка при создании товарной записи." view-as alert-box.
     return no-apply.
   end.
   find first bf_tt-goods where recid(bf_tt-goods) = parrec-id.
   assign
     bf_tt-goods.fact-qnty = bf_tt-goods.fact-qnty + bf_prt-obj.fact-qnty
     bf_tt-goods.free-qnty = bf_tt-goods.free-qnty + bf_prt-obj.free-qnty.
   run calc-stock in this-procedure
      (input tt-usrstko.obj-type,
       input tt-usrstko.obj-code,
       input tt-usrstko.db-num,
       input tt-usrstko.main-obj-type,
       input tt-usrstko.main-obj-code,
       input tt-usrstko.host-code,
       input tt-usrstko.host-name,
       input tt-usrstko.level,
       input bf_tt-goods.artic,
       input bf_tt-goods.prod-type,
       input bf_tt-goods.prod-code,
       input bf_tt-goods.prt-code,
       input bf_prt-obj.price-sale,
       input bf_prt-obj.fact-qnty,
       input bf_prt-obj.free-qnty) no-error.
     if error-status:error then do:
        message "Ошибка при подсчете остатков." view-as alert-box error.
        return no-apply.
     end.
 end.
 {&open-query-b-goods}
 find first tt-goods where tt-goods.artic = varartic and
                                      tt-goods.prod-type = varprod-type and
                                      tt-goods.prod-code = varprod-code and
                                      tt-goods.prt-code = varprt-code  no-error.
 if available tt-goods then do:
   reposition b-goods to recid recid(tt-goods) no-error.
 end.
 else do:
   message "Данного признака(товара) больше нет в наличии." view-as alert-box.
 end.
 {&open-query-b-stock}
 find first   tt-stock where tt-stock.obj-type   = varobj-type        and
                             tt-stock.obj-code   = varobj-code        and
                             tt-stock.artic      = tt-goods.artic     and
                             tt-stock.prod-type  = tt-goods.prod-type and
                             tt-stock.prod-code  = tt-goods.prod-code and
                             tt-stock.prt-code   = tt-goods.prt-code  no-error.
 if available tt-stock then do:
   reposition b-stock to recid recid(tt-stock) no-error.
 end.
 run waitfram-hide in this-procedure .

end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b-stock
&Scoped-define SELF-NAME b-stock
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-stock Dialog-Frame
ON GO OF b-stock IN FRAME Dialog-Frame
DO:
    return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-stock Dialog-Frame
ON return OF b-stock IN FRAME Dialog-Frame
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varartic
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varartic Dialog-Frame
ON ANY-PRINTABLE OF varartic IN FRAME Dialog-Frame /* Артикул */
DO:
  define variable varrec-id as recid no-undo.
  display "" @ vargds-name "" @ varb-c with frame {&frame-name}.
  assign frame {&frame-name} varartic.
  if last-event:label = "backspace" then do:
      assign varartic = substring (varartic, 1, length(varartic) - 1).
    end.
    else do:
    if last-event:label <> "enter" then do:
      assign varartic = varartic + last-event:label.
    end.
  end.
  display varartic with frame {&frame-name}.
  find first tt-goods where tt-goods.artic begins varartic no-error.
  if available tt-goods then do:
    assign
      varrec-id = recid(tt-goods).
      reposition b-goods to recid varrec-id no-error.
    {&open-query-b-stock}
    find first   tt-stock where tt-stock.artic      = tt-goods.artic     and
                                tt-stock.prod-type  = tt-goods.prod-type and
                                tt-stock.prod-code  = tt-goods.prod-code and
                                tt-stock.prt-code   = tt-goods.prt-code  no-error.
    if available tt-stock then do:
      varrec-id = recid(tt-stock).
      reposition b-stock to recid varrec-id no-error.
    end.
  end.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varartic Dialog-Frame
ON return OF varartic IN FRAME Dialog-Frame /* Артикул */
DO:
  apply "any-printable" to varartic in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varb-c
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varb-c Dialog-Frame
ON GO OF varb-c IN FRAME Dialog-Frame /* Бар-код */
DO:
    return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varb-c Dialog-Frame
ON return OF varb-c IN FRAME Dialog-Frame /* Бар-код */
DO:
define buffer bf_bar-code for ub.bar-code.
define buffer bf_prod-bc  for ub.prod-bc.
define buffer bf_place    for ub.place.
define buffer bf_goods    for ub.goods.
define buffer bf_tt-goods for tt-goods.
define variable par-type as character no-undo.
define variable varresult  as character no-undo.
define variable vartype-bc as character no-undo.
define variable varweigth  as decimal   no-undo.
assign frame {&frame-name} varb-c.
display "" @ vargds-name "" @ varartic with frame {&frame-name}.
{ str/sclspref.i }
{ str/bc-rcnz.i
  ?
  varb-c
  ?
  ?
  ?
  no
  no
  varscales-pref
  varpgscales-pref
  varresult
  vartype-bc
  varweigth
  bf_bar-code
  bf_prod-bc
  bf_place
}

if available bf_bar-code then do:
  find first bf_goods where bf_goods.gds-code = bf_bar-code.gds-code no-lock.
  find first bf_tt-goods where bf_tt-goods.artic     = bf_goods.artic        and
                               bf_tt-goods.prod-type = bf_goods.prod-type    and
                               bf_tt-goods.prod-code = bf_goods.prod-code    and
                               bf_tt-goods.prt-code  = bf_bar-code.node-code no-error.
  reposition b-goods to recid recid(bf_tt-goods) no-error.
  {&open-query-b-stock}
  find first   tt-stock where tt-stock.artic      = bf_tt-goods.artic     and
                              tt-stock.prod-type  = bf_tt-goods.prod-type and
                              tt-stock.prod-code  = bf_tt-goods.prod-code and
                              tt-stock.prt-code   = bf_tt-goods.prt-code  no-error.
  if available tt-stock then do:
    reposition b-stock to recid recid(tt-stock) no-error.
  end.
end.
return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME vargds-cnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL vargds-cnt Dialog-Frame
ON GO OF vargds-cnt IN FRAME Dialog-Frame /* Начало слова */
DO:
    return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL vargds-cnt Dialog-Frame
ON return OF vargds-cnt IN FRAME Dialog-Frame /* Начало слова */
DO:
  define buffer bf_goods for ub.goods.
  assign frame {&frame-name} vargds-cnt.
  if vargds-cnt <> "":u then do:
    display "" @ varartic "" @ varb-c "" @ vargds-name with frame {&frame-name}.
    for each tt-cont-goods :
      delete tt-cont-goods.
    end.
    for each bf_goods where bf_goods.gds-name contains vargds-cnt no-lock:
      create tt-cont-goods.
      buffer-copy bf_goods to tt-cont-goods.
    end.
    OPEN QUERY b-goods FOR EACH tt-goods, FIRST tt-cont-goods where tt-cont-goods.artic     = tt-goods.artic     AND
                                                                    tt-cont-goods.prod-type = tt-goods.prod-type AND
                                                                    tt-cont-goods.prod-code = tt-goods.prod-code.
    GET FIRST b-goods.
    IF not available tt-goods THEN DO:
     FIND first tt-cont-goods NO-ERROR.
     IF AVAILABLE tt-cont-goods THEN DO:
       MESSAGE "Товары имеющие в начале слова <" vargds-cnt "> есть в базе данных. Но по ним нет остатка товара."
       VIEW-AS ALERT-BOX.
     END.
    END.
    {&open-query-b-stock}
  end.
  else do:
    {&open-query-b-goods}
    {&open-query-b-stock}
  end.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME vargds-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL vargds-name Dialog-Frame
ON CTRL-J OF vargds-name IN FRAME Dialog-Frame /* Начало названия */
DO:
  define variable varrec-id as recid no-undo.
  display "" @ varartic "" @ varb-c with frame {&frame-name}.
  assign frame {&frame-name} vargds-name.
  find next tt-goods where tt-goods.gds-name begins vargds-name use-index gds-name no-error.
   if available tt-goods then do:
      assign
         varrec-id = recid(tt-goods).
      reposition b-goods to recid varrec-id no-error.
      {&open-query-b-stock}
      find first tt-stock where   tt-stock.artic      = tt-goods.artic     and
                                  tt-stock.prod-type  = tt-goods.prod-type and
                                  tt-stock.prod-code  = tt-goods.prod-code and
                                  tt-stock.prt-code   = tt-goods.prt-code  no-error.
      if available tt-stock then do:
        varrec-id = recid(tt-stock).
        reposition b-stock to recid varrec-id no-error.
      end.
   end.
return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL vargds-name Dialog-Frame
ON GO OF vargds-name IN FRAME Dialog-Frame /* Начало названия */
DO:
    return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL vargds-name Dialog-Frame
ON return OF vargds-name IN FRAME Dialog-Frame /* Начало названия */
DO:
  define variable varrec-id as recid no-undo.
  display "" @ varartic "" @ varb-c with frame {&frame-name}.
  assign frame {&frame-name} vargds-name.
  find first tt-goods where tt-goods.gds-name begins vargds-name no-error.

   if available tt-goods then do:
      assign
         varrec-id = recid(tt-goods).
      reposition b-goods to recid varrec-id no-error.
      {&open-query-b-stock}
      find first tt-stock where   tt-stock.artic      = tt-goods.artic     and
                                  tt-stock.prod-type  = tt-goods.prod-type and
                                  tt-stock.prod-code  = tt-goods.prod-code and
                                  tt-stock.prt-code   = tt-goods.prt-code  no-error.
      if available tt-stock then do:
        varrec-id = recid(tt-stock).
        reposition b-stock to recid varrec-id no-error.
      end.
   end.
return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b-goods
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i &disable_diasize_init=true }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   run gbl/conf-rd.p ("is-slscr", ?, "", 0, "", "", "", no,  output is-slscrvalue, output is-slscrtype) no-error.
   if is-slscrvalue <> "yes" then do:
     message "У Вас нет лицензии на работу с АРМом <Экран продавца>"
     view-as alert-box.
     return error.
   end.
   run gbl/conf-rd.p ("numslscr", ?, "", 0, "", "", "", no,  output numslscrvalue, output numslscrtype) no-error.
   if numslscrvalue = "" then do:
     assign
       numslscrvalue_int = 0.
   end.
   else do:
     assign
       numslscrvalue_int = integer (numslscrvalue).
   end.
   run gbl/lock-usr.p
    (input "test"   /* код пользователя */
    ,input "sal"    /* код ресурса */
    ,input true     /* показывать сообщение об ошибке */
    ,input "Достигнуто максимальное количество пользователей &1"   /* сообщение об ошибке */
    ,input numslscrvalue_int        /* максимальное количество пользователей */
    ,buffer buf_batchprocess
    ) no-error.
  if error-status:error then do:
    return error.
  end.
  find first ubflt.usr-flt where ubflt.usr-flt.user-name  = paruser-name and
                           ubflt.usr-flt.call-point begins "stockscr"   no-lock no-error.
   if not available ubflt.usr-flt then do:
    message "У Вас нет ни одного настроенного объекта для получения остатков."
    view-as alert-box.
    run str/stkscrad.w (input paruser-name, output varchg) no-error.
  end.
  run loadusr-tt (input paruser-name) no-error.
  if error-status :error then do:
    message "Ошибка при чтении настроек пользователя." view-as alert-box error.
    return error.
  end.
  run load-tt no-error.
  if error-status:error then do:
    message "Ошибка при чтении остатков из БД." view-as alert-box error.
    return error.
  end.
  RUN enable_UI.
  assign {&sort-clmn_8-br-dtl}:read-only in browse {&browse-name} = yes.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-stock Dialog-Frame
PROCEDURE calc-stock :
define input parameter parobj-type      like tt-usrstko.obj-type      no-undo.
define input parameter parobj-code      like tt-usrstko.obj-code      no-undo.
define input parameter pardb-num        like tt-usrstko.db-num        no-undo.
define input parameter parmain-obj-type like tt-usrstko.main-obj-type no-undo.
define input parameter parmain-obj-code like tt-usrstko.main-obj-code no-undo.
define input parameter parhost-code     like tt-usrstko.host-code     no-undo.
define input parameter parhost-name     like tt-usrstko.host-name     no-undo.
define input parameter parlevel         like tt-usrstko.level         no-undo.
define input parameter parartic         like tt-goods.artic           no-undo.
define input parameter parprod-type     like tt-goods.prod-type       no-undo.
define input parameter parprod-code     like tt-goods.prod-code       no-undo.
define input parameter parprt-code      like tt-goods.prt-code        no-undo.
define input parameter parprice-sale    like ub.prt-obj.price-sale    no-undo.
define input parameter parfact-qnty     like ub.prt-obj.fact-qnty     no-undo.
define input parameter parfree-qnty     like ub.prt-obj.free-qnty     no-undo.
define buffer bf_db-status    for ub.db-status.
define buffer bf_tt-usrstko   for tt-usrstko.
define buffer bf_sys-ctrl     for ub.sys-ctrl.

  find first bf_db-status where bf_db-status.db-num = pardb-num no-lock no-error.
  find first bf_sys-ctrl no-lock.
  if parmain-obj-code <> ? then do:
    find first tt-stock where tt-stock.obj-type  = parmain-obj-type and
                              tt-stock.obj-code  = parmain-obj-code and
                              tt-stock.artic     = parartic         and
                              tt-stock.prod-type = parprod-type     and
                              tt-stock.prod-code = parprod-code     and
                              tt-stock.prt-code  = parprt-code      no-error.
    if not available tt-stock then do:
      find first bf_tt-usrstko where bf_tt-usrstko.user-name = paruser-name     and
                                     bf_tt-usrstko.main-obj-type  = parmain-obj-type and
                                     bf_tt-usrstko.main-obj-code  = parmain-obj-code no-error.
      create tt-stock.
      assign
        tt-stock.obj-type   = parmain-obj-type
        tt-stock.obj-code   = parmain-obj-code
        tt-stock.host-code  = bf_tt-usrstko.host-code
        tt-stock.host-name  = bf_tt-usrstko.host-name
        tt-stock.artic      = parartic
        tt-stock.prod-type  = parprod-type
        tt-stock.prod-code  = parprod-code
        tt-stock.prt-code   = parprt-code.
      assign
        tt-stock.data-date  = (if available bf_db-status then (if bf_sys-ctrl.db-num = bf_db-status.db-num then today else bf_db-status.stock-date) else ?)
        tt-stock.data-time  = (if available bf_db-status then (if bf_sys-ctrl.db-num = bf_db-status.db-num then time  else bf_db-status.stock-time) else ?)
        tt-stock.price-sale = ?
        tt-stock.level      = bf_tt-usrstko.level.
      assign
        tt-stock.fact-qnty  = parfact-qnty
        tt-stock.free-qnty  = parfree-qnty.
    end.
    else do:
      assign
        tt-stock.price-sale = parprice-sale
        tt-stock.fact-qnty  = tt-stock.fact-qnty + parfact-qnty
        tt-stock.free-qnty  = tt-stock.free-qnty + parfree-qnty.
      if not available bf_db-status or
         tt-stock.data-date = ? then do:
        assign
          tt-stock.data-date = ?
          tt-stock.data-time = ?.
      end.
      else do:
         if bf_sys-ctrl.db-num <> bf_db-status.db-num then do:
           if integer(bf_db-status.stock-date) * 86400 + bf_db-status.stock-time <
              integer(tt-stock.data-date) * 86400 + tt-stock.data-time then do:
              assign
                tt-stock.data-date = bf_db-status.stock-date
                tt-stock.data-time = bf_db-status.stock-time.
            end.
         end.
      end.
    end.
  end.
  else do:
    find first tt-stock where tt-stock.obj-type   = parobj-type  and
                              tt-stock.obj-code   = parobj-code  and
                              tt-stock.artic      = parartic     and
                              tt-stock.prod-type  = parprod-type and
                              tt-stock.prod-code  = parprod-code and
                              tt-stock.prt-code   = parprt-code  no-error.
    if not available tt-stock then do:
      create tt-stock.
      assign
        tt-stock.obj-type   = parobj-type
        tt-stock.obj-code   = parobj-code
        tt-stock.host-code  = parhost-code
        tt-stock.host-name  = parhost-name
        tt-stock.artic      = parartic
        tt-stock.prod-type  = parprod-type
        tt-stock.prod-code  = parprod-code
        tt-stock.prt-code   = parprt-code
        tt-stock.level      = parlevel.
      assign
        tt-stock.data-date  = (if available bf_db-status then (if bf_sys-ctrl.db-num = bf_db-status.db-num then today else bf_db-status.stock-date) else ?)
        tt-stock.data-time  = (if available bf_db-status then (if bf_sys-ctrl.db-num = bf_db-status.db-num then time  else bf_db-status.stock-time) else ?)
        tt-stock.price-sale = parprice-sale.
    end.
    else do:
      if bf_sys-ctrl.db-num <> bf_db-status.db-num then do:
        if integer(bf_db-status.stock-date) * 86400 + bf_db-status.stock-time <
           integer(tt-stock.data-date) * 86400 + tt-stock.data-time then do:
           assign
             tt-stock.data-date = bf_db-status.stock-date
             tt-stock.data-time = bf_db-status.stock-time.
         end.
      end.
    end.
    assign
      tt-stock.fact-qnty  = tt-stock.fact-qnty + parfact-qnty
      tt-stock.free-qnty  = tt-stock.free-qnty + parfree-qnty.
  end.

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE change-brw Dialog-Frame
PROCEDURE change-brw :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable varartic     like ub.goods.artic no-undo.
define variable varprod-type like ub.goods.prod-type no-undo.
define variable varprod-code like ub.goods.prod-code no-undo.
define variable varprt-code  like ub.prt-obj.prt-code no-undo.
define variable varobj-type  like ub.clients.obj-type no-undo.
define variable varobj-code  like ub.clients.obj-code no-undo.
define variable varrec-id as recid no-undo.
if available tt-goods then do:
  assign
    varartic = tt-goods.artic
    varprod-type = tt-goods.prod-type
    varprod-code = tt-goods.prod-code
    varprt-code = tt-goods.prt-code.
  if available tt-stock then do:
    assign
      varobj-type = tt-stock.obj-type
      varobj-code = tt-stock.obj-code.
  end.
end.
run clear-tt in this-procedure no-error.
if error-status:error then do:
  message "Ошибка при очистке временных таблиц." view-as alert-box error.
  return no-apply.
end.
run load-tt in this-procedure no-error.
if error-status:error then do:
  message "Ошибка при создании временных таблиц." view-as alert-box error.
  return no-apply.
end.
{&open-query-b-goods}
{&open-query-b-stock}
find first tt-goods where tt-goods.artic     = varartic     and
                          tt-goods.prod-type = varprod-type and
                          tt-goods.prod-code = varprod-code and
                          tt-goods.prt-code  = varprt-code  no-error.
if available tt-goods then do:
  assign
    varrec-id = recid(tt-goods).
  reposition {&browse-name} to recid varrec-id no-error.
  apply "value-changed" to browse {&browse-name}.
  find first tt-stock where tt-stock.obj-type  = varobj-type  and
                            tt-stock.obj-code  = varobj-code  and
                            tt-stock.artic     = varartic     and
                            tt-stock.prod-type = varprod-type and
                            tt-stock.prod-code = varprod-code and
                            tt-stock.prt-code  = varprt-code  no-error.
  if available tt-stock then do:
    assign
      varrec-id = recid(tt-stock).
    reposition b-stock to recid varrec-id no-error.
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE clear-tt Dialog-Frame
PROCEDURE clear-tt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
for each tt-goods:
  delete tt-goods.
end.
for each tt-stock:
  delete tt-stock.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-tt-goods Dialog-Frame
PROCEDURE create-tt-goods :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter parartic like  ub.prt-obj.artic  no-undo.
define input parameter parprod-type like ub.prt-obj.prod-type no-undo.
define input parameter parprod-code like ub.prt-obj.prod-code no-undo.
define input parameter parprt-code  like ub.prt-obj.prt-code no-undo.
define output parameter parrec-id as recid no-undo.
define buffer bf_client       for ub.clients.
define buffer bf_gds-grp      for ub.gds-grp.
define buffer bf_gds-prt      for ub.gds-prt.
define buffer bf_goods        for ub.goods.
define buffer bf_prod-clients for ub.clients.
define variable varupper-code like ub.gds-prt.node-code no-undo.
define variable vargrp-name as   character           no-undo.


find first tt-goods where tt-goods.artic     = parartic     and
                          tt-goods.prod-type = parprod-type and
                          tt-goods.prod-code = parprod-code and
                          tt-goods.prt-code  = parprt-code  no-error.
if not available tt-goods then do:
  create tt-goods.
  assign
  tt-goods.artic     = parartic
  tt-goods.prod-type = parprod-type
  tt-goods.prod-code = parprod-code
  tt-goods.prt-code  = parprt-code .
  find first bf_goods where bf_goods.artic     = tt-goods.artic     and
                            bf_goods.prod-type = tt-goods.prod-type and
                            bf_goods.prod-code = tt-goods.prod-code no-lock.
  find first bf_gds-prt where bf_gds-prt.node-code = parprt-code no-lock.
  assign
     tt-goods.gds-name  = bf_goods.gds-name
     tt-goods.prt-name  = bf_gds-prt.f-name
     tt-goods.unit-base = bf_goods.unit-base
     tt-goods.unit-base = bf_goods.unit-base.
  find first bf_prod-clients where bf_prod-clients.obj-type = bf_goods.prod-type and
                                   bf_prod-clients.obj-code = bf_goods.prod-code no-lock.
  assign
    tt-goods.prod-name = bf_prod-clients.obj-name.
  if bf_gds-prt.node-name <> {&empty-scale} then do:
    assign
      tt-goods.prt-name = bf_gds-prt.f-name.
    if length(tt-goods.prt-name) > {&length-name} then do:
      assign tt-goods.prt-name = "..." + substring(tt-goods.prt-name, 4 + (length(tt-goods.prt-name) - {&length-name})).
    end.
  end.
  assign
    tt-goods.prt-root = bf_gds-prt.prt-root.
  repeat :
    case bf_gds-prt.lvl-num:
      when 0 then do:
        assign tt-goods.ford-num-0 = bf_gds-prt.prt-num.
      end.
      when 1 then do:
        assign tt-goods.ford-num-1 = bf_gds-prt.prt-num.
      end.
      when 2 then do:
        assign tt-goods.ford-num-2 = bf_gds-prt.prt-num.
      end.
    end.
    if bf_gds-prt.lvl-num = 0 then do:
      leave.
    end.
    else do:
      assign varupper-code = bf_gds-prt.upper-code.
      find first bf_gds-prt where bf_gds-prt.node-code  = varupper-code.
    end.
  end.

  find first bf_gds-grp where bf_gds-grp.node-code = bf_goods.grp-code no-lock.
  run full-grp in this-procedure (input bf_gds-grp.node-code, input-output vargrp-name) no-error.
  if error-status :error then do:
    assign
      tt-goods.grp-name = "Ошибка!!!.".
  end.
  assign
    tt-goods.grp-name = vargrp-name.
end.
assign
  parrec-id = recid(tt-goods).

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
  DISPLAY varartic vargds-name varb-c vargds-cnt
      WITH FRAME Dialog-Frame.
  ENABLE b-goods b-exit b-requery b-requery-prt b-admin b-help vargds-name
         varb-c b-stock vargds-cnt
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE load-tt Dialog-Frame
PROCEDURE load-tt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable varobj-type like ub.clients.obj-type no-undo.
define variable varobj-code like ub.clients.obj-code no-undo.
define variable parrec-id as recid no-undo.
define buffer bf_prt-obj      for ub.prt-obj.

run waitfram-show in this-procedure
  (input "Подготовка остатков товаров для просмотра"
  ).
for each tt-usrstko no-lock,
   each bf_prt-obj where bf_prt-obj.obj-type = tt-usrstko.obj-type and
                         bf_prt-obj.obj-code = tt-usrstko.obj-code no-lock :

   if bf_prt-obj.fact-qnty = 0 and
      bf_prt-obj.free-qnty = 0 then next.
  run create-tt-goods (input bf_prt-obj.artic,
                                  input bf_prt-obj.prod-type,
                                  input bf_prt-obj.prod-code,
                                  input bf_prt-obj.prt-code,
                                  output parrec-id) no-error.
    if error-status:error then do:
      message "Ошибка при создании товарной записи." view-as alert-box.
      return no-apply.
    end.
  find first tt-goods where recid(tt-goods) = parrec-id.
   assign
     tt-goods.fact-qnty = tt-goods.fact-qnty + bf_prt-obj.fact-qnty
     tt-goods.free-qnty = tt-goods.free-qnty + bf_prt-obj.free-qnty.
  run calc-stock in this-procedure
  (input tt-usrstko.obj-type,
   input tt-usrstko.obj-code,
   input tt-usrstko.db-num,
   input tt-usrstko.main-obj-type,
   input tt-usrstko.main-obj-code,
   input tt-usrstko.host-code,
   input tt-usrstko.host-name,
   input tt-usrstko.level,
   input tt-goods.artic,
   input tt-goods.prod-type,
   input tt-goods.prod-code,
   input tt-goods.prt-code,
   input bf_prt-obj.price-sale,
   input bf_prt-obj.fact-qnty,
   input bf_prt-obj.free-qnty) no-error.
  if error-status:error then do:
    message "Ошибка при подсчете остатков." view-as alert-box error.
    return error.
  end.
end.
run waitfram-hide in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME