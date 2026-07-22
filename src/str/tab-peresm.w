&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_clients FOR ub.clients.
DEFINE BUFFER buf_dis-card FOR ub.dis-card.
DEFINE BUFFER buf_icnt-doc FOR ub.icnt-doc.
DEFINE BUFFER buf_inkas    FOR ub.inkas.
DEFINE BUFFER buf_obj      FOR ub.clients.
DEFINE BUFFER buf_shop     FOR ub.shop.
DEFINE BUFFER buf_trn-doc  FOR ub.trn-doc.
DEFINE BUFFER c-doc        FOR ub.chk-doc.
DEFINE BUFFER dis-obj      FOR ub.dis-obj.
DEFINE BUFFER find_chk-doc FOR ub.chk-doc.
DEFINE BUFFER find_inkas   FOR ub.inkas.
DEFINE BUFFER find_trn-doc FOR ub.trn-doc.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Таблица пересменок по кассе

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/08/05
Author: Bakhtadze Natalya
Creation date: 09/08/05

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns  as char   no-undo .
/*кнопки для нажатия*/
define input parameter par-mode  as char   no-undo .
define input parameter pardoc-rec as recid no-undo.
define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.clients.obj-code no-undo.
define input parameter parout-code like ub.chk-doc.out-code no-undo.
define input parameter pard-card like ub.chk-doc.d-card no-undo.
define input parameter p-start-date like ub.chk-doc.chk-date no-undo .
define input parameter p-end-date like ub.chk-doc.chk-date no-undo .
/*типы документов в выборке*/
define output param rid-list    as  char no-undo . /* список recid'ов выбранных chk-title */

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Таблица пересменки по кассе":U.
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }
{ cmp/showinf.i }
{ gbl/flt-def.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ gbl/fltfield.i }
{ gbl/waitfram.i }
{ str/shftnmef.i chk-doc shift-name }
{ cmp/mrk-strf.i }
{ gbl/fltopend.i defproc }
&scop receipt-code string(c-doc.chk-type)
{ gbl/color.i }

define variable filter-label       as character no-undo init "Таблица пересменки по кассе" .
define variable filter-label0      as character no-undo init "Таблица пересменки по кассе" .
define variable filter-point0      as character no-undo init {&receipts} .
define variable filter-point       as character no-undo init {&receipts} .
define variable sort-column-name   as character no-undo .
define variable print-type         as character no-undo.
define variable del-type           as character no-undo.
define variable deleted            as logical   no-undo init no.
DEFINE VARIABLE change-type        as character init "" no-undo .
/*нужно ли печатать приложение к чеку в данном магазине*/
define variable chk-spfc           as logical   init no no-undo.
/*использовать смены на кассе для данного объекта*/
define variable cas-shft           as logical   no-undo init no.
define variable l-shift-on         as logical   no-undo .
define variable v-header-base-curr as character no-undo .
define variable v-curr-r-b         as character no-undo .
define variable v-rep-rec          as recid     no-undo .
define variable v-print-host-code  like ub.sysconf.host-code no-undo.

define buffer buf_cli      for ub.clients.
define buffer out_inkas    for ub.inkas .
define buffer buf_currency for ub.currency.
define variable v-base-code    like ub.currency.curr-code no-undo .
define variable v-base-type    like ub.currency.curr-abbr no-undo .
define variable v-doc-rec      as recid     no-undo .
define variable p-chk-type     like ub.chk-doc.chk-type no-undo .
DEFINE VARIABLE v-chk-autotank AS CHARACTER NO-UNDO .
{ cmp/gds-list.i gds-list def "new shared" }

{ str/paycardv.i }

def temp-table gds-bar no-undo
   field b-code like bar-code.b-code
   field qnty   as decimal
   index art is unique b-code .

define temp-table temp-pay no-undo like ub.chk-pay
   index pi is unique primary pay-code curr-code
   .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-docs

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES c-doc

/* Definitions for BROWSE BR-docs                                       */
&Scoped-define FIELDS-IN-QUERY-BR-docs c-doc.office mark-string(RECID( c-doc), rid-list) c-doc.doc-code {&receipt-name} c-doc.chk-num v-chk-autotank c-doc.chk-date (string (c-doc.chk-time, "HH:MM")) c-doc.shift-date shift-name-no-err(buffer c-doc) c-doc.netto c-doc.tot-doc c-doc.discnt c-doc.sub-discnt  c-doc.pay-desk c-doc.cashier c-doc.sales-man c-doc.out-code c-doc.d-card c-doc.doc-num c-doc.doc-num2
/*&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-docs c-doc.cashier   */
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-docs c-doc
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-docs c-doc
&Scoped-define SELF-NAME BR-docs
&Scoped-define QUERY-STRING-BR-docs FOR EACH c-doc NO-LOCK
&Scoped-define OPEN-QUERY-BR-docs OPEN QUERY {&SELF-NAME} FOR EACH c-doc NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-docs c-doc
&Scoped-define FIRST-TABLE-IN-QUERY-BR-docs c-doc


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel /*B-lookup*/ B-chg /*B-del*/ ~
B-sale B-print B-sch B-Help Cb-chk-type BR-docs ED-notes sch-code sch-date ~
sch-sum mark-num 
&Scoped-Define DISPLAYED-OBJECTS Cb-chk-type ED-notes sch-code sch-date ~
sch-sum mark-num 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU m-print 
   MENU-ITEM m-list         LABEL "Список чеков"  
   .

DEFINE BUTTON B-Help 
   LABEL "Помо&щь" 
   SIZE 3 BY 1
   BGCOLOR 8 .

DEFINE BUTTON B-print 
   LABEL "Пе&чать" 
   SIZE 3 BY 1 TOOLTIP "Печать списка чеков ...".

DEFINE BUTTON b-quit AUTO-END-KEY 
   LABEL "&Выход" 
   SIZE 10 BY 1
   BGCOLOR 8 .

DEFINE BUTTON B-sch 
   LABEL "&Фильтр" 
   SIZE 3 BY 1 TOOLTIP "Установка фильтра на список чеков".

DEFINE BUTTON b-sel AUTO-GO 
   LABEL "Вы&бор" 
   SIZE 10 BY 1
   BGCOLOR 8 . 

DEFINE VARIABLE Cb-chk-type AS CHARACTER FORMAT "X(256)":U 
   VIEW-AS COMBO-BOX INNER-LINES 10
   LIST-ITEM-PAIRS "Все",0,"Закрытие",13,"Открытие",40
   DROP-DOWN-LIST
   SIZE 19 BY 1
   BGCOLOR 15 NO-UNDO.

DEFINE VARIABLE ED-notes    AS CHARACTER 
   VIEW-AS EDITOR SCROLLBAR-VERTICAL
   SIZE 98 BY 2
   BGCOLOR 8 FGCOLOR 4 NO-UNDO.

DEFINE VARIABLE mark-num    AS CHARACTER FORMAT "X(256)":U 
   VIEW-AS TEXT 
   SIZE 6 BY 1
   FGCOLOR 4 NO-UNDO.

DEFINE VARIABLE sch-code    AS CHARACTER FORMAT "X(20)":U 
   LABEL "номер" 
   VIEW-AS FILL-IN 
   SIZE 19.13 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-date    AS DATE      FORMAT "99/99/9999":U 
   LABEL "дата" 
   VIEW-AS FILL-IN 
   SIZE 11.63 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.


/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-docs FOR c-doc SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-docs Dialog-Frame _FREEFORM
   QUERY BR-docs DISPLAY
   c-doc.pay-desk FORMAT ">>>9"  COLUMN-LABEL "Номер!АРМ Кассира":U
   c-doc.obj-code FORMAT ">>>>9" COLUMN-LABEL "Номер!магазина":U
   shift-name-no-err(buffer c-doc) COLUMN-LABEL "№ смены" FORMAT "X(6)":U
   c-doc.chk-date FORMAT "99/99/9999" COLUMN-LABEL "Дата чека на!АРМ Кассира":U               
   (string (c-doc.chk-time, "HH:MM")) COLUMN-LABEL "Время чека на!АРМ Кассира":U 
   c-doc.chk-num FORMAT "->>>>>>>>9" COLUMN-LABEL "№ чека!на АРМ Кассира":U
      {&receipt-name} COLUMN-LABEL "Тип_чека" FORMAT "X(45)":U

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 15.67 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
   b-quit AT ROW 1 COL 1
   /* B-mark AT ROW 1 COL 11 */
   /* b-sel AT ROW 1 COL 21 */
   /* B-lookup AT ROW 1 COL 31 */
   /*B-chg AT ROW 1 COL 41*/
   /* B-del AT ROW 1 COL 51 */
   /* B-sale AT ROW 1 COL 61 */
   B-print AT ROW 1 COL 89
   B-sch AT ROW 1 COL 92
   B-Help AT ROW 1 COL 95
   Cb-chk-type AT ROW 2 COL 1 NO-LABEL
   BR-docs AT ROW 2.67 COL 1
   ED-notes AT ROW 18.67 COL 1 NO-LABEL
   sch-code AT ROW 20.79 COL 17.63 COLON-ALIGNED
   sch-date AT ROW 20.83 COL 48.25 COLON-ALIGNED
   /* sch-sum AT ROW 20.83 COL 77.5 COLON-ALIGNED */
   mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
   "ПОИСК ПО" VIEW-AS TEXT
   SIZE 9.25 BY 1 AT ROW 20.79 COL 1.5
   FGCOLOR 4 
   SPACE(88.62) SKIP(0.20)
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
      TABLE: buf_clients B "?" ? ub clients
      TABLE: buf_dis-card B "?" ? ub dis-card
      TABLE: buf_icnt-doc B "?" ? ub icnt-doc
      TABLE: buf_inkas B "?" ? ub inkas
      TABLE: buf_obj B "?" ? ub clients
      TABLE: buf_shop B "?" ? ub shop
      TABLE: buf_trn-doc B "?" ? ub trn-doc
      TABLE: c-doc B "?" ? ub chk-doc
      TABLE: dis-obj B "?" ? ub dis-obj
      TABLE: find_chk-doc B "?" ? ub chk-doc
      TABLE: find_inkas B "?" ? ub inkas
      TABLE: find_trn-doc B "?" ? ub trn-doc
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-docs Cb-chk-type Dialog-Frame */
ASSIGN 
   FRAME Dialog-Frame:SCROLLABLE = FALSE
   FRAME Dialog-Frame:HIDDEN     = TRUE.

/*ASSIGN 
       B-chg:POPUP-MENU IN FRAME Dialog-Frame       = MENU m-chg:HANDLE.*/

/*ASSIGN 
       B-del:POPUP-MENU IN FRAME Dialog-Frame       = MENU m-del:HANDLE.*/

ASSIGN 
   B-print:POPUP-MENU IN FRAME Dialog-Frame = MENU m-print:HANDLE.

/* SETTINGS FOR COMBO-BOX Cb-chk-type IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-docs
/* Query rebuild information for BROWSE BR-docs
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH c-doc NO-LOCK.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY BR-docs FOR c-doc SCROLLING.
     _END_FREEFORM_DEFINE
     _Query            is NOT OPENED
*/  /* BROWSE BR-docs */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON ENDKEY OF FRAME Dialog-Frame
   DO:
      if deleted then return "deleted".
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame
   DO:
      APPLY "LEAVE" to ED-notes.
      if deleted then return "deleted".
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame
   DO:
      APPLY "END-ERROR":U TO SELF.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/*&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
define variable glog as logical no-undo .
define variable v-host-code as integer no-undo .
  define buffer s-doc for trn-doc.
  if not available c-doc then return no-apply.
  { gbl/hostcode.i c-doc.obj-type c-doc.obj-code v-host-code }
/*  { gbl/chk-actg.i                                            */
/*  v-cntxt-db-num                                              */
/*  v-cntxt-userid                                              */
/*  {&action-head-code-main}                                    */
/*  'actn_receipt_input':U                                      */
/*  {&cntxt-object}                                             */
/*  v-host-code                                                 */
/*  c-doc.obj-type                                              */
/*  c-doc.obj-code                                              */
/*  0                                                           */
/*  0                                                           */
/*  0                                                           */
/*  true                                                        */
/*  glog                                                        */
/*  }                                                           */
/*  if NOT glog then return no-apply.                           */
/*    if change-type = '':U then do:                            */
/*    run gbl/pop-up.p ( input b-chg:handle, input no) no-error.*/
/*  end.                                                        */
  if change-type = '':U then return no-apply.
  run proc-b-chg in this-procedure ( input change-type) no-error.
  assign
  change-type = "":U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME */


/*&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удал */
DO:
 if del-type = "" then do:
    run gbl/pop-up.p ( input b-del:handle, input no) no-error.
 end.
 if del-type = "" then return no-apply.
run proc-b-del in this-procedure ( input del-type) no-error.
if error-status:error then do:
    del-type = '':U.
    return no-apply.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME */


/* &Scoped-define SELF-NAME B-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup Dialog-Frame
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame /* Просмотр */
DO:
define variable next-prev as character no-undo .
define variable v-doc-rec as recid no-undo .
assign
next-prev = '':U
.
DO WHILE next-prev = '':U:
    if NOT available c-doc then do:
            message "Неправильно выбран чек." view-as alert-box ERROR.
            return no-apply.
    end.
    v-doc-rec = recid(c-doc).
    run str/superchk.w
                  (
                     input parparentproc
                    ,input {&lookup}
                    ,input c-doc.obj-type
                    ,input c-doc.obj-code
                    ,input-output v-doc-rec
                    ,input this-procedure:handle
                    ,input-output next-prev
                                )
    .

END .

apply "entry" to br-docs in frame {&frame-name}.
apply "value-changed" to br-docs in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME */


/* &Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable glog as logical no-undo .
  if available c-doc then do:
    { gbl/markstrn.i c-doc rid-list }
    glog = br-docs:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        glog = br-docs:select-next-row ().
        apply "VALUE-CHANGED" to br-docs in frame {&frame-name}.
    end.
    if num-entries( rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-docs in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME */


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
   DO:
      define variable v-doc-rec as recid   no-undo .
      define variable glog      as logical no-undo .
      define buffer s-doc for trn-doc.
      if NOT available c-doc then 
      do:
         return no-apply.
      end.
      if print-type = "" then 
      do:
         run gbl/pop-up.p ( input self:handle, input no) no-error.
      end.
      if print-type = "list":U or print-type = "gds":U or print-type = "pay":U or print-type = "gds-list":U   then 
      do:
         if par-mode = {&g___object} and index(frame {&frame-name}:title,"ФИЛЬТР" ) = 0 then 
         do:
            CASE print-type:
               when "list":U then 
                  do:
                     message "Вы хотите напечатать весь список чеков по объекту при невключенном фильтре!" skip
                        "Эта процедура может занять долгое время! Продолжать?" view-as alert-box
                        WARNING buttons YES-NO update glog.
                     if NOT glog then return no-apply.
                  end.
               when "gds":U then 
                  do:
                     message "Вы хотите напечатать строки всего списка чеков по объекту при невключенном фильтре!" skip
                        "Эта процедура может занять долгое время! Продолжать?" view-as alert-box
                        WARNING buttons YES-NO update glog.
                     if NOT glog then return no-apply.
                  end.
               when "pay":U then 
                  do:
                     message "Вы хотите напечатать оплаты всего списка чеков по объекту при невключенном фильтре!" skip
                        "Эта процедура может занять долгое время! Продолжать?" view-as alert-box
                        WARNING buttons YES-NO update glog.
                     if NOT glog then return no-apply.
                  end.
               when "gds-list":U then 
                  do:
                     message "Вы хотите сохранить товары всего списка чеков по объекту при невключенном фильтре!" skip
                        "Эта процедура может занять долгое время! Продолжать?" view-as alert-box
                        WARNING buttons YES-NO update glog.
                     if NOT glog then return no-apply.
                  end.
               when "akt-spi" then 
                  do: 
                  end.
            END CASE.
         end.
         v-doc-rec = recid( c-doc ).
         DO WHILE available c-doc :
            GET prev br-docs no-lock.
         END.
         CASE print-type:
            when "list":U then 
               do:
                  run PrintProc in this-procedure.
               end.
            when "gds":U then 
               do:
                  run PrintProcGds in this-procedure.
               end.
            when "pay":U then 
               do:
                  run PrintProcPay in this-procedure.
               end.
            when "gds-list":U then 
               do:
                  run PrintProcGds-list in this-procedure.
               end.
 
         END CASE.
         print-type = "".
         reposition br-docs to recid v-doc-rec no-error.
         apply "entry" to br-docs in frame {&frame-name}.
      end.
      else 
      do:
         CASE print-type:
            when "akt-spi" then 
               do: 
                  if c-doc.chk-type <>  integer({&rcpt-tech-refuell}) then 
                  do: 
                
                     message "Акт списания делается только по чекам ТехПролива" view-as alert-box ERROR.
                     return no-apply.
                  end.
                  run rep/r-akt-spis.p (input c-doc.doc-code ).
               end.
            when "one":U then 
               do:
                  run str/checkp.p ( input parparentproc, input c-doc.doc-code) no-error.
                  print-type = "".
               end.
            when "spcf":U then 
               do:
                  if can-do( {&gds-goods}, c-doc.office ) AND ( c-doc.d-card <> "" ) then
                     run rep/r-specsr.p ( input parparentproc, input recid( c-doc ), input {&cash-desk} ) .
                  else
                     message "Чек все еще ошибочный ! " view-as alert-box ERROR.
               end.
         END CASE.
      end.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* &Scoped-define SELF-NAME B-sale
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sale Dialog-Frame
ON CHOOSE OF B-sale IN FRAME Dialog-Frame /* Док-нт */
DO:
 define buffer lkp_trn-doc for ub.trn-doc.
  if NOT available c-doc then do:
      message "Неправильно выбран чек." view-as alert-box ERROR.
      return no-apply.
  end.
  find first lkp_trn-doc no-lock where
            lkp_trn-doc.doc-code = c-doc.out-code no-error.
  if not available lkp_trn-doc then do:
    message
    "Для данного чека нет документа."
    view-as alert-box .
    return no-apply.
  end.
  case lkp_trn-doc.ext-doc-type:
    when {&TDEDT_Ras_Vnesh_Kass} then do:
      FIND find_inkas where
                find_inkas.inkas-code = c-doc.out-code.
      run str/ink-lkp.p ( input parparentproc, input recid(find_inkas) ).
    end.
    when {&TDEDT_Inv} then do:
      run str/showdoc.p (  input parparentproc
                      ,input lkp_trn-doc.doc-code
                      ,input '':U /*p-artic*/
                      ,input '':U /*p-proc-type*/
                      ,input 0 /*p-proc-code*/
                      ,input true).
      end.
  end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME   */


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
   DO:
      Cb-chk-type = "0" .
      sch-code = "" .
      sch-date = ? .
      display 
      Cb-chk-type
      sch-code
      sch-date
      with frame {&frame-name} .       
      run proc-b-sch in this-procedure no-error.
      if error-status:error then return no-apply.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* &Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if ( available c-doc ) AND ( rid-list = "" ) then
    rid-list = string( recid( c-doc ) ) .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME */


&Scoped-define BROWSE-NAME BR-docs
&Scoped-define SELF-NAME BR-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON ANY-PRINTABLE OF BR-docs IN FRAME Dialog-Frame
   DO:
      sch-code:screen-value = sch-code:screen-value + last-event:label.
      apply "entry" to sch-code in frame {&frame-name}.
      apply "end" to sch-code in frame {&frame-name}.

   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* &ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON DELETE-CHARACTER OF BR-docs IN FRAME Dialog-Frame
DO:
  if b-mark:sensitive in frame {&frame-name} then
  APPLY "CHOOSE" to b-mark.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME */


/* &ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON INSERT-MODE OF BR-docs IN FRAME Dialog-Frame
DO:
  if b-mark:sensitive in frame {&frame-name} then
  APPLY "CHOOSE" to b-mark.
    else do:
      if b-sel:sensitive in frame {&frame-name} then
      APPLY "CHOOSE" to b-sel.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME */


/*&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON RETURN OF BR-docs IN FRAME Dialog-Frame
OR MOUSE-SELECT-DBLCLICK OF {&self-name} IN FRAME {&frame-name}
DO:
  { ref/brwsretr.i }
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME */




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON VALUE-CHANGED OF BR-docs IN FRAME Dialog-Frame
   DO:
      DEFINE VARIABLE dops as character no-undo .
      dops = if available c-doc then c-doc.ps else '':U.
      ED-notes:screen-value = dops.

   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Cb-chk-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Cb-chk-type Dialog-Frame
ON VALUE-CHANGED OF Cb-chk-type IN FRAME Dialog-Frame
   DO:

      ASSIGN
         CB-chk-type
         p-chk-type = integer(cb-chk-type)
         .
      RUn OpenBR in this-procedure ( input yes, input no, input '':U).

   END. 

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ED-notes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ED-notes Dialog-Frame
ON LEAVE OF ED-notes IN FRAME Dialog-Frame
   DO:
   /*  define variable is-cre as integer no-undo .                               */
   /*  define buffer ps_chk-doc for chk-doc.                                     */
   /*  if not available chk-doc then return no-apply.                            */
   /*   DO on stop undo, return no-apply:                                        */
   /*        FIND PS_chk-doc where recid (ps_chk-doc) = recid(c-doc) exclusive.  */
   /*        assign                                                              */
   /*        is-cre = index(ps_chk-doc.PS, "!":U)                                */
   /*        .                                                                   */
   /*        if ps_CHk-doc.PS <> input frame {&frame-name} ed-notes then         */
   /*        assign                                                              */
   /*        ps_chk-doc.PS = (if is-cre > 0 then "!":U else "":U) +              */
   /*                        left-trim(input frame {&frame-name} ed-notes, "!":U)*/
   /*        .                                                                   */
   /*    END.                                                                    */
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-list Dialog-Frame
ON CHOOSE OF MENU-ITEM m-list /* Список чеков */
   DO:
      print-type = "list":U.
      apply "choose" to b-print in frame {&frame-name}.

   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* &Scoped-define SELF-NAME m-list-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-list-del Dialog-Frame
ON CHOOSE OF MENU-ITEM m-list-del /* Удалить список чеков */
DO:
   del-type = "list".
    apply "choose" to b-del in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME */


/* &Scoped-define SELF-NAME m-list-shift
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-list-shift Dialog-Frame
ON CHOOSE OF MENU-ITEM m-list-shift /* Изменить дату и/или номер смены для списка чеков */
DO:
   change-type = "list-shift":U.
   apply "choose" to b-chg in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME */


&Scoped-define SELF-NAME sch-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON CTRL-J OF sch-code IN FRAME Dialog-Frame /* номеру */
   DO:
      assign sch-code .
      run proc-find-code in this-procedure ( input yes, input frame {&frame-name} sch-code) no-error.
      if error-status:error then return no-apply.

   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON RETURN OF sch-code IN FRAME Dialog-Frame /* номеру */
   DO:
      assign sch-code .
      RUn OpenBR in this-procedure ( input yes, input no, input '':U).
   /*  run proc-find-code in this-procedure ( input no, input frame {&frame-name} sch-code) no-error.*/
   /*  if error-status:error then return no-apply.                                                   */
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-date Dialog-Frame
ON CTRL-J OF sch-date IN FRAME Dialog-Frame /* дате */
   DO:
      assign sch-date .
      run proc-find-date in this-procedure ( input yes, input frame {&frame-name} sch-date) no-error.
      if error-status:error then return no-apply.


   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-date Dialog-Frame
ON RETURN OF sch-date IN FRAME Dialog-Frame /* дате */
   DO:
      assign sch-date .
      RUn OpenBR in this-procedure ( input yes, input no, input '':U). 
   /*  run proc-find-date in this-procedure ( input no, input frame {&frame-name} sch-date) no-error.*/
   /*  if error-status:error then return no-apply.                                                   */


   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* &Scoped-define SELF-NAME sch-sum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-sum Dialog-Frame
ON CTRL-J OF sch-sum IN FRAME Dialog-Frame /* сумме оплат */
DO:
  run proc-find-sum in this-procedure ( input yes, input frame {&frame-name} sch-sum) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME */


/* &ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-sum Dialog-Frame
ON RETURN OF sch-sum IN FRAME Dialog-Frame /* сумме оплат */
DO:
  run proc-find-sum in this-procedure ( input no, input frame {&frame-name} sch-sum) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME  */


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
   THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

&scop b-lookup ~{&b-lkp~}

/* { gbl/hot-key.i b-mark } */
/* { gbl/hot-key.i b-sel  } */
/* { gbl/hot-key.i b-lookup } */
/* { gbl/hot-key.i b-chg  }*/
/* { gbl/hot-key.i b-del  } */

{ gbl/setfltnm.i }
{ gbl/ed_date.i sch-date }
{ gbl/brwrefre.i " v-rep-rec = ?. if available c-doc then v-rep-rec = recid(c-doc). RUn OpenBR in this-procedure ( input yes, input no, input '':U).  reposition br-docs to recid v-rep-rec no-error. " }

{ gbl/brwrepos.i
  &line-num=5
}

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   { gbl/getcntxt.i get }

   CASE par-mode:
      WHEN  {&all}
      or 
      when  {&g___object}
      or 
      when "free":U
      or 
      when "chk-date":U
      or 
      when {&TDEDT_Inv}
      or 
      when {&table_dis-card}
      THEN 
         DO:
            FIND FIRST buf_obj No-LOCK WHERE
               buf_obj.obj-type = parobj-type and
               buf_obj.obj-code = parobj-code No-ERROR.
            if not avail buf_obj then 
            do:
               message vss-workfile vss-revision vss-description skip
                  "Неверное значение параметров вызова parobj-type и/или parobj-code"
                  parobj-type parobj-code
                  view-as alert-box ERROR.
               return.
            end.
         END.
      when "d-card":U or 
      when ("d-card" + {&comma-char} + {&sale}) then 
         do:
            FIND FIRST buf_dis-card where
               buf_dis-card.d-card = pard-card No-LOCK NO-ERROR.
            if not avail buf_dis-card then 
            do:
               message vss-workfile vss-revision vss-description skip
                  "Неверное значение параметра вызова pard-card" pard-card
                  view-as alert-box ERROR.
               return.
            end.
            FIND FIrst  buf_clients NO-LOCK WHERE
               buf_clients.obj-type = buf_dis-card.cli-type AND
               buf_clients.obj-code = buf_dis-card.cli-code No-ERROR.
         end.
      WHEN {&sale}  or 
      when ("d-card" + {&comma-char} + {&sale}) or 
      when "to-sale":U then 
         do:
            FIND buf_inkas where buf_inkas.inkas-code = parout-code NO-LOCK no-error.
            if not avail buf_inkas then 
            do:
               message vss-workfile vss-revision vss-description skip
                  "Неверное значение параметра вызова parout-code" parout-code
                  view-as alert-box ERROR.
               return.
            end.
         end.
      when "chk-date":U then 
         do:
            if p-start-date > p-end-date
               or p-start-date = ?
               or p-end-date = ?
               then 
            do:
               message vss-workfile vss-revision vss-description skip
                  "Неверное значение параметров p-start-date p-end-date" p-start-date p-end-date
                  view-as alert-box ERROR.
               return.
            end.
         end.
      when "to-inv" then 
         do:
            FIND buf_trn-doc where buf_trn-doc.doc-code = parout-code NO-LOCK no-error.
            if not avail buf_trn-doc then 
            do:
               message vss-workfile vss-revision vss-description skip
                  "Неверное значение параметра вызова parout-code" parout-code
                  view-as alert-box ERROR.
               return.
            end.
         end.
      when "to-" + {&icnt-err}
      or
      when {&icnt-err}
      then 
         do:
            if parout-code <> '':U then 
            do:
               FIND buf_icnt-doc where buf_icnt-doc.doc-code = parout-code NO-LOCK no-error.
               if not avail buf_icnt-doc then 
               do:
                  message vss-workfile vss-revision vss-description skip
                     "Неверное значение параметра вызова parout-code" parout-code
                     view-as alert-box ERROR.
                  return.
               end.
            end.
         end.
      otherwise 
      do:
         message vss-workfile vss-revision vss-description skip
            "Неверный вызов - par-mode=" par-mode
            view-as alert-box ERROR.
         return.
      end.
   end CASE.
   if pardoc-rec <> ? then 
   do:
      FIND FIRST find_chk-doc No-LOCK where
         recid(find_chk-doc) = pardoc-rec No-ERROR.
      if not avail find_chk-doc then 
      do:
         message
            vss-workfile vss-revision vss-description skip
            "Неверное значение параметра вызова pardoc-rec" pardoc-rec
            view-as alert-box error .
         return error.
      end.
   end.
   { gbl/curr-r-b.i
    v-curr-r-b
  }
   if v-curr-r-b = {&r-b-base} then 
   do:
      if v-print-host-code <> 0 then 
      do:
      { gbl/basecode.i v-print-host-code v-base-code }
         find first buf_currency where
            buf_currency.curr-code = v-base-code.
         assign
            v-base-type = buf_currency.curr-abbr.
      end.
      assign
         v-header-base-curr = string( "( Б.Вал. - " + caps( v-base-type ) + " )" )
         .
   end.
   RUN MyEnable in this-procedure .
   RUn OpenBR in this-procedure ( input yes, input no, input '':U).

   HIDE mark-num in frame {&frame-name} .
   if pardoc-rec <> ? then
      REPOSITION br-docs to recid pardoc-rec No-ERROR.
   WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI in this-procedure .

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
   DISPLAY Cb-chk-type ED-notes sch-code sch-date /* sch-sum */  mark-num 
      WITH FRAME Dialog-Frame.
   ENABLE b-quit /*B-mark*/ /*b-sel*/ /*B-lookup*/ /*B-chg*/ /* B-del*/  /* B-sale */  B-print B-sch B-Help 
      Cb-chk-type BR-docs ED-notes sch-code sch-date /* sch-sum */ mark-num 
      WITH FRAME Dialog-Frame.
   VIEW FRAME Dialog-Frame.
   {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-params Dialog-Frame 
PROCEDURE get-params :
   define variable v-param-type      as character no-undo .
   define variable v-value-character as character no-undo .
   define variable v-value-date      as date      no-undo .
   define variable v-value-decimal   as decimal   no-undo .
   define variable v-value-integer   as INTEGER   no-undo .
   define variable v-value-logical   AS LOGICAL   no-undo .
   define variable v-tth             as handle    no-undo .
   run adm/shattri.p (
      input "get":U
      ,input  parobj-type
      ,input  parobj-code
      ,input  {&attr-chk-view}
      ,input  {&attr-chk-view_chk-spfc} /*p-param-code*/
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
   IF not error-status:error then 
   do:
      chk-spfc = v-value-logical.
   end.
   delete object v-tth.
/*найдем параметр - использовать смены на кассе или нет*/
   { gbl/cas-shft.i parobj-type parobj-code cas-shft }
   find first buf_shop no-lock where buf_shop.obj-code = parobj-code.
   { gbl/objat.i
  {&shop}
  parobj-code
  "'shift-on=request'"
  l-shift-on
}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
   DEF VAR v-hdl AS HANDLE NO-UNDO .

   ASSIGN
      /* cb-chk-type:LIST-ITEM-PAIRS  in frame {&frame-name} =  "Все типы чеков" + {&comma-char} + '0':U + {&comma-char} +
                                                             {&receipt-codes-combo} */
      cb-chk-type                                       = string(0)
      p-chk-type                                        = integer(cb-chk-type)
      br-docs:NUM-LOCKED-COLUMNS IN FRAME {&frame-name} = 6
      /* b-chg:MENU-MOUSE = 1 */
      b-print:MENU-MOUSE                                = 1
      /* b-del:MENU-MOUSE = 1 */
      /* c-doc.cashier:READ-ONLY IN BROWSE {&BROWSE-NAME} = YES */
      /* c-doc.office:RESIZABLE IN BROWSE {&BROWSE-NAME} = YES */
      .
   run get-params in this-procedure no-error .
   /* ASSIGN b-del:MENU-MOUSE = 1. */
   /* if lookup(par-mode, {&sale} + {&comma-char} + {&TDEDT_Inv}) > 0 then do:
       assign
       pardoc-rec = ?
       b-del:label = "Искл&ючить"
       menu-item m-list-shift:sensitive in menu m-chg = no
       menu-item m-one-change:sensitive in menu m-chg = no
       .
   end. */
   if par-mode = "to-inv" then 
   do:
      cb-chk-type = {&rcpt-inventory}.
      p-chk-type = integer({&rcpt-inventory}).
   end.
   if par-mode = {&icnt-err}
      or par-mode = "to-" + {&icnt-err}
      then 
   do:
      cb-chk-type = {&rcpt-tech-refuell}.
      p-chk-type = integer({&rcpt-tech-refuell}).
   end.
   DISPLAY
      cb-chk-type 
      when (par-mode = {&sale}
      or par-mode = "free"
      or par-mode = "to-sale"
      or par-mode = "to-inv"
      or par-mode = {&icnt-err}
      or par-mode = "to-" + {&icnt-err}
      )
      ED-notes
      sch-code
      sch-date
      /* sch-sum */
      mark-num
      WITH FRAME {&frame-name} .
   ENABLE
      cb-chk-type 
      when (par-mode = {&sale}
      or par-mode = "free"
      or par-mode = "to-sale"
      or par-mode = {&g___object}
      or par-mode = {&all}
      or par-mode = "chk-date"
      or par-mode = {&table_dis-card}
      or par-mode = "d-card"
      or par-mode = {&sale}
      or par-mode = "out-code"
      )
      b-quit
      /* b-lookup */
      b-sch
      /* b-sale when par-mode <> {&sale} */
      b-help
      br-docs
      /* b-sel  when LOOKUP("b-sel":U, bttns) > 0 */
      /* b-mark when LOOKUP("b-mark":U, bttns) > 0 */
      sch-code
      sch-date
      /* sch-sum */
      ed-notes
      /* b-del when LOOKUP("b-del":U, bttns) > 0 */
      /* b-chg when par-mode <> {&sale} */ 
      b-print
      WITH FRAME {&frame-name}.
   /*
   if not cas-shft then do:
       g#log = BR-docs:move-column(7,17).
       g#log = BR-docs:move-column(7,17).
   end.
   */
   IF NOT CAN-FIND(FIRST cash-desk WHERE cash-desk.db-num >=0 
      AND cash-desk.obj-code = parobj-code
      AND cash-desk.pos-type = {&cd-type-Autotank}) THEN
   DO:
      v-hdl = br-docs:FIRST-COLUMN .
      DO WHILE VALID-HANDLE(v-hdl):
         IF v-hdl:LABEL = "СдНал":U THEN v-hdl:VISIBLE = NO .
      
         v-hdl = v-hdl:NEXT-COLUMN .
      END.

   END.

   /* if par-mode = {&sale} then do:
     IF available buf_inkas and (buf_inkas.status_ = {&fact} or buf_inkas.status_ = {&inquiry})
     then disable b-del  with frame {&frame-name}.
   end. */
   /* if par-mode = {&TDEDT_inv} then do:
     IF available buf_trn-doc and buf_trn-doc.status_ <> {&wayb}
     then disable b-del  with frame {&frame-name}.
   end. */

   assign
      br-docs:height = br-docs:height  - 0.5
      br-docs:row    = br-docs:row + 0.5
      .

   VIEW FRAME {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame 
PROCEDURE OpenBr :
   define input  parameter p-open-query     as logical   no-undo .
   define input  parameter p-find-next      as logical   no-undo .
   define input  parameter p-find-condition as character no-undo .
   define variable l-query-was-opened as logical   no-undo .
   define variable title0             as character no-undo.
   title0 = "Таблица пересменки по кассе" + {&space-char}.
   define variable sort-column-phrase as character no-undo .

/*case sort-column-name :                            */
/*  when "" then do:                                 */
/*    assign                                         */
/*      sort-column-phrase = ""                      */
/*    .                                              */
/*  end.                                             */
/*  otherwise do:                                    */
/*    assign                                         */
/*      sort-column-phrase = "by " + sort-column-name*/
/*    .                                              */
/*  end.                                             */
/*end case.                                          */

&scop flt-open-open-query OPEN QUERY br-docs FOR EACH c-doc

&scop flt-open-dyn_open-query FOR EACH c-doc

&scop flt-open-query-handle QUERY br-docs:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name c-doc

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name c-doc

&Scop flt-open-waitfram yes

   define variable l-open-query       as logical   no-undo .

   CASE par-mode :
      WHEN {&all}        THEN 
         DO:
            assign
               filter-point = filter-point0 + par-mode
               filter-label = substitute("&1", filter-label0)
               .

            if p-open-query then 
            do:
               ASSIGN
                  frame {&frame-name}:TITLE = substitute("&1 ", title0 )
                  .
            end.

            if sch-code <> "" and sch-date <> ? then 
            do:
               case Cb-chk-type:
                  when "0" then 
                     do:
                        { gbl/fltopend.i
        &where-cond = " (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and string(c-doc.chk-num) begins string(sch-code) and c-doc.chk-date = sch-date "
        &dyn_where-cond = " substitute(' (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and string(c-doc.chk-num) begins string(&2) and c-doc.chk-date = &3 ', ~{&double-quote~}, sch-code, sch-date) "
        &use-ind    = " USE-INDEX obj-date "
        &by         = "  " }         
                     end.   
                  when "13" then 
                     do:
                        { gbl/fltopend.i
        &where-cond = "  c-doc.chk-type = 13 and string(c-doc.chk-num) begins string(sch-code) and c-doc.chk-date = sch-date  "
        &dyn_where-cond = " substitute(' c-doc.chk-type = 13 and string(c-doc.chk-num) begins string(&2) and c-doc.chk-date = &3 ', ~{&double-quote~}, sch-code, sch-date) "
        &use-ind    = " USE-INDEX obj-date "
        &by         = "  " }
                     end.
                  when "40" then 
                     do:
                        { gbl/fltopend.i
        &where-cond = " c-doc.chk-type = 40 and string(c-doc.chk-num) begins string(sch-code) and c-doc.chk-date = sch-date  "
        &dyn_where-cond = " substitute(' c-doc.chk-type = 40 and string(c-doc.chk-num) begins string(&2) and c-doc.chk-date = &3 ', ~{&double-quote~}, sch-code, sch-date) "
        &use-ind    = " USE-INDEX obj-date "
        &by         = "  " }
                     end.            
               end case.
            end.  
            else if sch-code = "" and sch-date <> ? then 
               do:
                  case Cb-chk-type:
                     when "0" then 
                        do:
                           { gbl/fltopend.i
        &where-cond = " (c-doc.chk-type = 13 or c-doc.chk-type = 40) and c-doc.chk-date = sch-date "
        &dyn_where-cond = " substitute(' (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and c-doc.chk-date = &3 ', ~{&double-quote~}, sch-code, sch-date) "
        &use-ind    = " USE-INDEX obj-date "
        &by         = "  " }    
                        end.   
                     when "13" then 
                        do:
                           { gbl/fltopend.i
        &where-cond = " c-doc.chk-type = 13 and c-doc.chk-date = sch-date "
        &dyn_where-cond = " substitute(' c-doc.chk-type = 13 and c-doc.chk-date = &3 ', ~{&double-quote~}, sch-code, sch-date) "
        &use-ind    = " USE-INDEX obj-date "
        &by         = "  " } 
                        end.
                     when "40" then 
                        do:
                           { gbl/fltopend.i
        &where-cond = " c-doc.chk-type = 40 and c-doc.chk-date = sch-date "
        &dyn_where-cond = " substitute(' c-doc.chk-type = 40 and c-doc.chk-date = &3 ', ~{&double-quote~}, sch-code, sch-date) "
        &use-ind    = " USE-INDEX obj-date "
        &by         = "  " } 
                        end.            
                  end case.
               end.
               else if sch-code <> "" and sch-date = ? then 
                  do:
                     case Cb-chk-type:
                        when "0" then 
                           do:
                              { gbl/fltopend.i
        &where-cond = " (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and string(c-doc.chk-num) begins string(sch-code) "
        &dyn_where-cond = " substitute(' (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and string(c-doc.chk-num) begins string(&2) ', ~{&double-quote~}, sch-code, sch-date) "
        &use-ind    = " USE-INDEX obj-date "
        &by         = "  " }
                           end.   
                        when "13" then 
                           do:
                              { gbl/fltopend.i
        &where-cond = " c-doc.chk-type = 13 and string(c-doc.chk-num) begins string(sch-code) "
        &dyn_where-cond = " substitute(' c-doc.chk-type = 13 and string(c-doc.chk-num) begins string(&2) ', ~{&double-quote~}, sch-code, sch-date) "              
        &use-ind    = " USE-INDEX obj-date "
        &by         = "  " } 
                           end.
                        when "40" then 
                           do:
                              { gbl/fltopend.i
        &where-cond = " c-doc.chk-type = 40 and string(c-doc.chk-num) begins string(sch-code) "
        &dyn_where-cond = " substitute(' c-doc.chk-type = 40 and string(c-doc.chk-num) begins string(&2) ', ~{&double-quote~}, sch-code, sch-date) "              
        &use-ind    = " USE-INDEX obj-date "
        &by         = "  " } 
                           end.            
                     end case.         
                  end.
                  else 
                  do:
                     case Cb-chk-type:
                        when "0" then 
                           do:
                              { gbl/fltopend.i
        &where-cond = " ~
          (c-doc.chk-type = 13 OR c-doc.chk-type = 40)
    ~
                      "
        &use-ind    = " USE-INDEX obj-date "
        &by         = "  " }
                           end.   
                        when "13" then 
                           do:
                              { gbl/fltopend.i
        &where-cond = " ~
          (c-doc.chk-type = 13)
    ~
                      "
        &use-ind    = " USE-INDEX obj-date "
        &by         = "  " }
                           end.
                        when "40" then 
                           do:
                              { gbl/fltopend.i
        &where-cond = " ~
          (c-doc.chk-type = 40)
    ~
                      "
        &use-ind    = " USE-INDEX obj-date "
        &by         = "  " }
                           end.            
                     end case.               
                  end.
         END.
      WHEN {&g___object} THEN 
         DO:
         { gbl/hostcode.i parobj-type parobj-code v-print-host-code }
            assign
               filter-point = filter-point0 + par-mode
               filter-label = substitute("&1 Один объект", filter-label0)
               .
               
               if p-open-query then 
               do:
                  ASSIGN
                     frame {&frame-name}:TITLE = substitute("&1 Объект: &2&3", title0 , parobj-type , parobj-code)
                     .
               end.
            if sch-code <> "" and sch-date <> ? then 
            do:
               case Cb-chk-type:
                  when "0" then 
                     do:
                        { gbl/fltopend.i
        &where-cond = " (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and string(c-doc.chk-num) begins string(sch-code) and c-doc.chk-date = sch-date "
        &dyn_where-cond = " substitute(' (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and string(c-doc.chk-num) begins string(&2) and c-doc.chk-date = &3 ', ~{&double-quote~}, sch-code, sch-date) "
        &use-ind    = " USE-INDEX obj-date "
        &by         = "  " }         
                     end.   
                  when "13" then 
                     do:
                        { gbl/fltopend.i
        &where-cond = "  c-doc.chk-type = 13 and string(c-doc.chk-num) begins string(sch-code) and c-doc.chk-date = sch-date  "
        &dyn_where-cond = " substitute(' c-doc.chk-type = 13 and string(c-doc.chk-num) begins string(&2) and c-doc.chk-date = &3 ', ~{&double-quote~}, sch-code, sch-date) "
        &use-ind    = " USE-INDEX obj-date "
        &by         = "  " }
                     end.
                  when "40" then 
                     do:
                        { gbl/fltopend.i
        &where-cond = " c-doc.chk-type = 40 and string(c-doc.chk-num) begins string(sch-code) and c-doc.chk-date = sch-date  "
        &dyn_where-cond = " substitute(' c-doc.chk-type = 40 and string(c-doc.chk-num) begins string(&2) and c-doc.chk-date = &3 ', ~{&double-quote~}, sch-code, sch-date) "
        &use-ind    = " USE-INDEX obj-date "
        &by         = "  " }
                     end.            
               end case.
            end.  
            else if sch-code = "" and sch-date <> ? then 
               do:
                  case Cb-chk-type:
                     when "0" then 
                        do:
                           { gbl/fltopend.i
        &where-cond = " (c-doc.chk-type = 13 or c-doc.chk-type = 40) and c-doc.chk-date = sch-date "
        &dyn_where-cond = " substitute(' (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and c-doc.chk-date = &3 ', ~{&double-quote~}, sch-code, sch-date) "
        &use-ind    = " USE-INDEX obj-date "
        &by         = "  " }    
                        end.   
                     when "13" then 
                        do:
                           { gbl/fltopend.i
        &where-cond = " c-doc.chk-type = 13 and c-doc.chk-date = sch-date "
        &dyn_where-cond = " substitute(' c-doc.chk-type = 13 and c-doc.chk-date = &3 ', ~{&double-quote~}, sch-code, sch-date) "
        &use-ind    = " USE-INDEX obj-date "
        &by         = "  " } 
                        end.
                     when "40" then 
                        do:
                           { gbl/fltopend.i
        &where-cond = " c-doc.chk-type = 40 and c-doc.chk-date = sch-date "
        &dyn_where-cond = " substitute(' c-doc.chk-type = 40 and c-doc.chk-date = &3 ', ~{&double-quote~}, sch-code, sch-date) "
        &use-ind    = " USE-INDEX obj-date "
        &by         = "  " } 
                        end.            
                  end case.
               end.
               else if sch-code <> "" and sch-date = ? then 
                  do:
                     case Cb-chk-type:
                        when "0" then 
                           do:
                              { gbl/fltopend.i
        &where-cond = " (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and string(c-doc.chk-num) begins string(sch-code) "
        &dyn_where-cond = " substitute(' (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and string(c-doc.chk-num) begins string(&2) ', ~{&double-quote~}, sch-code, sch-date) "
        &use-ind    = " USE-INDEX obj-date "
        &by         = "  " }
                           end.   
                        when "13" then 
                           do:
                              { gbl/fltopend.i
        &where-cond = " c-doc.chk-type = 13 and string(c-doc.chk-num) begins string(sch-code) "
        &dyn_where-cond = " substitute(' c-doc.chk-type = 13 and string(c-doc.chk-num) begins string(&2) ', ~{&double-quote~}, sch-code, sch-date) "              
        &use-ind    = " USE-INDEX obj-date "
        &by         = "  " } 
                           end.
                        when "40" then 
                           do:
                              { gbl/fltopend.i
        &where-cond = " c-doc.chk-type = 40 and string(c-doc.chk-num) begins string(sch-code) "
        &dyn_where-cond = " substitute(' c-doc.chk-type = 40 and string(c-doc.chk-num) begins string(&2) ', ~{&double-quote~}, sch-code, sch-date) "              
        &use-ind    = " USE-INDEX obj-date "
        &by         = "  " } 
                           end.            
                     end case.         
                  end.
                  else 
                  do:
                     case Cb-chk-type:
                        when "0" then 
                           do:
                              { gbl/fltopend.i
        &where-cond = " (c-doc.chk-type = 13 OR c-doc.chk-type = 40) "
        &use-ind    = " USE-INDEX obj-date "
        &by         = "  " }
                           end.   
                        when "13" then 
                           do:
                              { gbl/fltopend.i
        &where-cond = " ~
          (c-doc.chk-type = 13)
    ~
                      "
        &use-ind    = " USE-INDEX obj-date "
        &by         = "  " }
                           end.
                        when "40" then 
                           do:
                              { gbl/fltopend.i
        &where-cond = " ~
          (c-doc.chk-type = 40)
    ~
                      "
        &use-ind    = " USE-INDEX obj-date "
        &by         = "  " }
                           end.            
                     end case.               
                  end.
         END.

   END CASE.

   if not p-open-query and v-doc-rec <> ? then
      REPOSITION br-docs to recid v-doc-rec No-ERROR.
   if not p-open-query and v-fltopend-rowid[1] <> ? then
      query br-docs:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
   run waitfram-hide in this-procedure .
   APPLY "VALUE-CHANGED" TO br-docs in frame {&frame-name}.
   APPLY "ENTRY" TO br-docs.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PrintProc Dialog-Frame 
PROCEDURE PrintProc :
   /*------------------------------------------------------------------------------
     Purpose:
     Parameters:  <none>
     Notes:
   ------------------------------------------------------------------------------*/
   define variable date_string      as char      no-undo.
   define variable Line             as char      no-undo.
   define variable for-time         as char.
   define variable accum-count      as integer.
   define variable accum-tot-doc    as decimal.
   define variable accum-discnt     as decima.
   define variable accum-sub-discnt as decimal.
   define variable accum-netto      as decimal.
   define variable v-chk-type       as character no-undo .
   define variable v-shift-name-num as character no-undo.



   DEFINE FRAME Chk-List
      c-doc.office        column-label "Тип"                format "X(8)"
      c-doc.doc-code      column-label "Номер_чека"  format "X(17)"
      v-chk-type          column-label "Тип_чека"               format "X(8)"
      c-doc.chk-num       column-label "№/кассе" format "->>>>>>>9"
      c-doc.chk-date      column-label "Дата" format "99/99/9999"
      for-time            column-label "Время"   format "X(5)"
      c-doc.shift-date    column-label "Смена_от" format "99/99/9999"
      v-shift-name-num    column-label "N_см." FORMAT "X(6)"
      /*c-doc.tot-doc       column-label "Сумма_товарная"*/
      c-doc.discnt        column-label "Скидка_общая"
      c-doc.sub-discnt    column-label "Списания"
      c-doc.netto         column-label "Сумма_оплат"
      c-doc.pay-desk      column-label "Касса"
      c-doc.cashier       column-label "Кссир"       format ">>>>9"
      c-doc.sales-man     column-label "Прд-ц"       format ">>>>9"
      c-doc.out-code      column-label "Номер_РН"
      c-doc.d-card        column-label "Номер_диск._карты"              space(0)

      HEADER  date_string AT 5 format "X(35)"
      v-header-base-curr        format "X(20)" AT 42
      string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>>>9" SKIP
      Line format "X({&A4_LS})" AT 1
      with width {&DOS_CW_2} down stream-io use-text    .

   Line = fill("-", {&A4_LS}).
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
      Line format "X(177)" AT 1 SKIP
      "Продолжение - на следующей странице" AT 30 SKIP
      with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
   VIEW  STREAM PrnLibStream FRAME BottomFrame .

   FORM with FRAME Chk-List  .
   run waitfram-show in this-procedure ( input "Ждите...").
   GET next br-docs  no-lock.
   DO WHILE available c-doc :
&scop receipt-code string(c-doc.chk-type)
      v-chk-type = {&receipt-name} .
      Display STREAM PrnLibStream
         c-doc.office
         c-doc.doc-code
         v-chk-type
         c-doc.chk-num
         c-doc.chk-date
         string(c-doc.chk-time, "HH:mm") @ for-time
         c-doc.shift-date
         shift-name-no-err(buffer c-doc) @ v-shift-name-num
         /*c-doc.tot-doc*/
         c-doc.discnt
         c-doc.sub-discnt
         c-doc.netto
         c-doc.pay-desk
         c-doc.cashier
         c-doc.sales-man
         if c-doc.out-code <> ? then c-doc.out-code else "" @ c-doc.out-code
         c-doc.d-card
         with FRAME Chk-List .
      DOWN STREAM PrnLibStream 1 with FRAME CHk-List  .
      assign
         accum-count      = accum-count + 1
         accum-tot-doc    = accum-tot-doc /*+ c-doc.tot-doc*/
         accum-discnt     = accum-discnt + c-doc.discnt
         accum-sub-discnt = accum-sub-discnt + c-doc.sub-discnt
         accum-netto      = accum-netto + c-doc.netto.
      GET next br-docs  no-lock.
   END.
   UNDERLINE  STREAM PrnLibStream
      c-doc.office
      c-doc.doc-code
      v-chk-type
      c-doc.chk-num
      c-doc.chk-date
      for-time
      c-doc.shift-date
      v-shift-name-num
      /*c-doc.tot-doc */
      c-doc.discnt
      c-doc.sub-discnt
      c-doc.netto
      c-doc.pay-desk
      c-doc.cashier
      c-doc.sales-man
      c-doc.out-code
      c-doc.d-card
      with FRAME Chk-List .
   DISPLAY STREAM PrnLibStream
      "ИТОГО"  @ c-doc.doc-code
      accum-count @ c-doc.chk-num
      "_" @ c-doc.chk-date
      "_ " @ for-time
      "_" @ c-doc.shift-date
      "______" @ v-shift-name-num
      accum-tot-doc /*@ c-doc.tot-doc*/
      accum-discnt @ c-doc.discnt
      accum-sub-discnt @ c-doc.sub-discnt
      accum-netto @ c-doc.netto
      with frame Chk-List.
   HIDE  STREAM PrnLibStream FRAME BottomFrame .
   HIDE  STREAM PrnLibStream FRAME CheckList.
   output  STREAM PrnLibStream CLOSE.
   /*
   assign
   g#rep-tblname = ""
   g#rep-tblrid = -117
   g#rep-updflds = string( "Список чеков|" ) .
   */
   run waitfram-hide in this-procedure .
   run prn-lib-prn-file in this-procedure (
      input parParentProc
      ,input 8
      ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PrintProcGds Dialog-Frame 
PROCEDURE PrintProcGds :
   /*------------------------------------------------------------------------------
     Purpose:
     Parameters:  <none>
     Notes:
   ------------------------------------------------------------------------------*/
   define variable date_string    as char      no-undo.
   define variable Line           as char      no-undo.
   define variable for-time       as char      no-undo.
   define variable accum-count    as integer   no-undo.
   define variable accum-qnty     as decimal   no-undo.
   define variable accum-tot-doc  as decimal   no-undo.
   define variable accum-discnt   as decimal   no-undo.
   define variable accum-netto    as decimal   no-undo.
   define variable fgds-discnt-pc as decimal   no-undo.
   define variable for-gds-sum    like chk-doc.netto no-undo.
   define variable for-gds-price  like chk-gds.price-base no-undo.
   define variable v-write-off    as logical   no-undo .
   define variable V-RECEIPT-NAME as character no-undo .



   DEFINE FRAME Goods-Frame
      chk-gds.doc-code column-label "Номер_чека" FORMAT "X(18)"
      v-receipt-name column-labeL "Тип_чека" format "x(8)"
      chk-gds.line-num column-label "NN" FORMAT "-999"
      chk-gds.b-code   column-label "Код"
      goods.artic
      goods.gds-name    FORMAT "X(27)"
      gds-prt.f-name   FORMAT "X(14)"
      chk-gds.is-error COLUMN-LABEL "Ош" FORMAT "+/ "
      chk-gds.src-code Column-label "Код в спул-файле" FORMAT "X(19)"
      chk-gds.pump column-label "ТРК"
      clients.obj-name    COLUMN-LABEL "Производитель" FORMAT "X(20)"
      chk-gds.doc-qnty
      bar-code.unit-cli     COLUMN-LABEL "Изм" FORMAT "X(3)"
      chk-gds.price-base
      chk-gds.discnt
      fgds-discnt-pc COLUMn-LABEL "% ск."  FORMAT "->9.99%"
      for-gds-price COLUMN-LABEL "Цена нетто"
      v-write-off COLUMn-LABEL "Сп" FORMAT "+/"
      HEADER  date_string AT 5 format "X(35)"
      v-header-base-curr        format "X(20)" AT 42
      string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>>>9" SKIP
      Line format "X(230)" AT 1
      with width {&DOS_CW_2} down stream-io use-text .


   Line = fill("-", 230).
   date_string = cur-time-print() .

   run prn-lib-open-stream  in this-procedure (
      input parParentProc
      ,input {&LS_PS_A4}
      ,input yes /*p-is-stream*/
      ,input no /*p-append*/
      ).
   PUT  STREAM PrnLibStream
      SPACE(25) ( frame {&frame-name}:title + ": строки чеков")
      format "x(90)" SKIP(1) .
   FORM HEADER
      Line format "X(230)" AT 1 SKIP
      "Продолжение - на следующей странице" AT 30 SKIP
      with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
   VIEW  STREAM PrnLibStream FRAME BottomFrame .
&SCOP RECEIPT-CODE STRING(C-DOC.CHK-TYPE)
   FORM with FRAME Goods-Frame  .
   run waitfram-show in this-procedure ( input "Ждите...").
   GET next br-docs  no-lock.
   DO WHILE available c-doc :
      FOR EACH chk-gds NO-LOCK Where
         chk-gds.doc-code = c-doc.doc-code by chk-gds.line-num:
         FIND FIRST bar-code No-LOCK WHERE
            bar-code.b-code = chk-gds.b-code NO-ERROR.
         IF AVAIL bar-code then 
         do:
            FIND FIRST goods NO-LOCK WHERE
               goods.gds-code = bar-code.gds-code NO-ERROR.
            FIND FIRST  clients NO-LOCK WHERE
               clients.obj-type = goods.prod-type AND
               clients.obj-code = goods.prod-code NO-ERROR.
            FIND FIRST gds-prt No-LOCK where
               gds-prt.upper-code = goods.prt-root NO-ERROR.
         end.

         assign
            fgds-discnt-pc = (chk-gds.discnt / (chk-gds.price-base + chk-gds.price-service) * 100)
            for-gds-sum    = (chk-gds.price-base + chk-gds.price-service - chk-gds.discnt) * chk-gds.doc-qnty
            for-gds-price  = chk-gds.price-base + chk-gds.price-service - chk-gds.discnt
            .

         DISPLAY Stream PrnLibStream
            chk-gds.doc-code
    {&RECEIPT-NAME} @ V-RECEIPT-NAME
    chk-gds.line-num
    chk-gds.b-code
    if avail bar-code then goods.artic else "" @ goods.artic
    if avail bar-code then goods.gds-name else "" @ goods.gds-name
    IF avail bar-code then (IF ( ub.gds-prt.node-name <> {&empty-scale})  then gds-prt.f-name  else "" ) else "" @ gds-prt.f-name
    chk-gds.is-error
    chk-gds.src-code
    chk-gds.pump
    if avail bar-code then clients.obj-name else "" @ clients.obj-name
    chk-gds.doc-qnty
    if avail bar-code then bar-code.unit-cli else "" @ bar-code.unit-cli
    (chk-gds.price-base + chk-gds.price-service) @ chk-gds.price-base
    chk-gds.discnt
    fgds-discnt-pc
    for-gds-price
    (if chk-gds.write-off-code <> ?
    and chk-gds.write-off-code <> 0
    then yes
    else no
    )  @ v-write-off
    WITH FRAME Goods-Frame.
         DOWN STREAM PrnLibStream with FRAME Goods-Frame .
         assign
            accum-count   = accum-count + 1
            accum-qnty    = accum-qnty + chk-gds.doc-qnty
            accum-tot-doc = accum-tot-doc + chk-gds.doc-qnty * (chk-gds.price-base + price-service)
            accum-discnt  = accum-discnt + chk-gds.doc-qnty * chk-gds.discnt
            accum-netto   = accum-netto + chk-gds.doc-qnty * (chk-gds.price-base + chk-gds.price-service - chk-gds.discnt)
            .
      END.
      /* DOWN STREAM PrnLibStream 1 with FRAME Goods-Frame  .*/
      GET next br-docs  no-lock.
   END.
   UNDERLINE  STREAM PrnLibStream
      chk-gds.doc-code
      chk-gds.line-num
      chk-gds.b-code
      goods.artic
      goods.gds-name
      gds-prt.f-name
      chk-gds.is-error
      chk-gds.src-code
      chk-gds.pump
      clients.obj-name
      chk-gds.doc-qnty
      bar-code.unit-cli
      chk-gds.price-base
      chk-gds.discnt
      fgds-discnt-pc
      for-gds-price
      v-write-off
      with FRAME Goods-Frame .
   DISPLAY STREAM PrnLibStream
      "ИТОГО"  @ chk-gds.doc-code
      "_" @ chk-gds.line-num
      accum-count @ chk-gds.b-code
      "_" @ goods.artic
      "_" @ goods.gds-name
      "_" @ gds-prt.f-name
      "_" @ chk-gds.is-error
      "_" @ chk-gds.src-code
      "_" @ chk-gds.pump
      "_" @ clients.obj-name
      ACCUM-qnty @ chk-gds.doc-qnty
      "_" @ bar-code.unit-cli
      accum-tot-doc @ chk-gds.price-base
(accum-discnt / accum-tot-doc * 100) @ fgds-discnt-pc
accum-discnt @ chk-gds.discnt
accum-netto @ for-gds-price
"_" @ v-write-off
WITH FRAME Goods-Frame.
   HIDE  STREAM PrnLibStream FRAME BottomFrame .
   HIDE  STREAM PrnLibStream FRAME Goods-Frame.
   output  STREAM PrnLibStream CLOSE.
   /*
   assign
   g#rep-tblname = ""
   g#rep-tblrid = -117
   g#rep-updflds = string( "Список чеков|" ) .
   */
   run waitfram-hide in this-procedure .

   run prn-lib-prn-file in this-procedure (
      input parParentProc
      ,input 9
      ).



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PrintprocGds-List Dialog-Frame 
PROCEDURE PrintprocGds-List :
   /*------------------------------------------------------------------------------
     Purpose:
     Parameters:  <none>
     Notes:
   ------------------------------------------------------------------------------*/
   define variable v-num    as integer no-undo.
   define variable f-name   as char    no-undo.
   define variable lns-cnt  as integer no-undo .
   define variable line-rec as recid   no-undo .
   DEFINE VARIABLE ii       as integer no-undo .
   define variable glog     as logical no-undo .
   run waitfram-show in this-procedure ( input "Ждите...").
   FOR EACH gds-list :
      delete gds-list .
   END .
   FOR EACH gds-bar :
      delete gds-bar .
   END .
   GET next br-docs  no-lock.
   ii = 0.
   DO WHILE available c-doc :
      FOR EACH chk-gds NO-LOCK Where
         chk-gds.doc-code = c-doc.doc-code by chk-gds.line-num:
         FIND FIRST bar-code No-LOCK WHERE
            bar-code.b-code = chk-gds.b-code NO-ERROR.
         IF AVAIL bar-code then 
         do:
            FIND FIRST goods NO-LOCK WHERE
               goods.gds-code = bar-code.gds-code NO-ERROR.
            FIND FIRST gds-prt No-LOCK where
               gds-prt.upper-code = goods.prt-root NO-ERROR.

            { cmp/gds-list.i gds-list assign }
            assign
               gds-list.qnty = gds-list.qnty + chk-gds.doc-qnty.
            FIND FIRST gds-bar where gds-bar.b-code = bar-code.b-code No-ERROR.
            if not avail gds-bar then 
            do:
               create gds-bar.
               assign
                  gds-bar.b-code = bar-code.b-code.
            end.
            assign
               gds-bar.qnty = gds-bar.qnty + chk-gds.doc-qnty.
         end.
      END.
      GET next br-docs  no-lock.
   END.
   run waitfram-hide in this-procedure .
   REPEAT while v-num <> 4:
      run gbl/d-askw.w (
         input "Сохранение списка товаров"
         ,input "Выберите формат для сохранения списка товаров"
         ,input "|"
         ,input "Файл списка товаров|Файл мобильного сканера|Таблица EXCEL|Отказ"
         ,input "|||"
         ,input 1 /* значение возвращаемое при нажатии enter */
         ,input 4 /* значение возвращаемое при нажатии escape */
         ,output v-num /* выбор пользователя */).
      if v-num = 4 then return.
      CASE v-num:
         when 1 then 
            do:
               assign
                  f-name = "default.gds"
                  glog   = yes
                  .
               system-dialog get-file f-name
                  filters "Списки товаров *.gds" "*.gds"
                  ask-overwrite
                  save-as
                  use-filename
                  update glog
                  default-extension "gds".
               if not glog then 
               do:
                  return.
               end.
               output to value (f-name).
               for each gds-list:
                  export gds-list.prod-type
                     gds-list.prod-code
                     gds-list.artic
                     gds-list.qnty
                     .
               end.
               output close.
            end.
         when 2 then 
            do:
               assign
                  f-name = "default.inv"
                  glog   = yes
                  .
               system-dialog get-file f-name
                  filters "Инвентаризация касса *.inv" "*.inv"
                  ask-overwrite
                  save-as
                  use-filename
                  update glog
                  default-extension "inv".
               if not glog then 
               do:
                  return .
               end.
               run waitfram-show in this-procedure ( input "Сохранение в формате мобильного сканера.    ЖДИТЕ...").
               output to value (f-name).
               for each gds-bar NO-LOCK:
                  if gds-bar.qnty <> 0 then
                     put unformatted string (gds-bar.b-code) + "," + string (gds-bar.qnty) skip.
               end.
               output close.
               run waitfram-hide in this-procedure .
            end.
         when 3 then 
            do:
               do on stop  undo, return no-apply
                  on error undo, return no-apply
                  on quit  undo, return no-apply
                  :
                  run str/gdsl-xls.p (
                     input parparentproc
                     , input parobj-type
                     , input parobj-code) no-error.
                  run waitfram-hide in this-procedure .
               end.
            end.
      END CASE.
   end. /*repeat*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PrintProcPay Dialog-Frame 
PROCEDURE PrintProcPay :
   /*------------------------------------------------------------------------------
     Purpose:
     Parameters:  <none>
     Notes:
   ------------------------------------------------------------------------------*/
   define variable date_string    as char    no-undo.
   define variable Line           as char    no-undo.
   define variable for-time       as char.
   define variable accum-count    as integer.
   define variable accum-tot-base as decima.
   define variable accum-tot-rubl as decimal.
   define variable pay-card-num   like ub.chk-pay.pay-card no-undo .

   DEFINE FRAME Pay-Frame
      chk-pay.doc-code column-label "Номер_чека" FORMAT "X(20)"
      chk-pay.line-num column-label "NN"
      chk-pay.curr-code column-label "Код. вал"
      currency.curr-name column-label "Валюта" FORMAT "X(15)"
      chk-pay.pay-code Column-label "Код платежа"
      cash-pay.obj-name COLUMn-LABEL "Платеж"
      pay-card-num COLUMN-LABEL "Платежн.карта"
      chk-pay.tot-sum COLUMN-LABEL "Сумма в вал. платежа"
      chk-pay.tot-base COLUMN-LABEL "Сумма в баз.вал"
      chk-pay.tot-rubl  COLUMN-LABEL "Сумма в {&abbr_rublyah}"
      HEADER  date_string AT 5 format "X(35)"
      v-header-base-curr        format "X(20)" AT 42
      string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>>>9" SKIP
      Line format "X(175)" AT 1
      with width {&DOS_CW_2} down stream-io use-text    .

   Line = fill("-", 175).
   date_string = cur-time-print() .

   run prn-lib-open-stream  in this-procedure (
      input parParentProc
      ,input {&LS_PS_A4}
      ,input yes /*p-is-stream*/
      ,input no /*p-append*/
      ).

   PUT  STREAM PrnLibStream
      SPACE(25) ( frame {&frame-name}:title  + ": оплаты")
      format "x(90)" SKIP(1) .
   FORM HEADER
      Line format "X(175)" AT 1 SKIP
      "Продолжение - на следующей странице" AT 30 SKIP
      with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
   VIEW  STREAM PrnLibStream FRAME BottomFrame .

   FORM with FRAME Pay-Frame  .
   run waitfram-show in this-procedure ( input "Ждите...").
   GET next br-docs  no-lock.
   for each temp-pay:
      delete temp-pay.
   end.
   DO WHILE available c-doc :
      FOR EACH chk-pay No-LOCK WHERE chk-pay.doc-code = c-doc.doc-code by chk-pay.line-num:
         FIND FIRST currency No-LOCK WHERE
            currency.curr-code = chk-pay.curr-code NO-ERROR.
         FIND FIRST cash-pay No-LOCK WHERE
            cash-pay.cdpay-code = chk-pay.pay-code AND
            cash-pay.curr-code = chk-pay.curr-code No-ERROR.
         find first temp-pay WHERE
            temp-pay.pay-code = chk-pay.pay-code AND
            temp-pay.curr-code = chk-pay.curr-code NO-ERROR.
         if not avail temp-pay then 
         do:
            create temp-pay.
            buffer-copy chk-pay except tot-base tot-sum tot-rubl line-num to temp-pay
               assign 
               temp-pay.line-num = 0
               .
         end.
         assign
            temp-pay.tot-sum  = temp-pay.tot-sum + chk-pay.tot-sum
            temp-pay.tot-base = temp-pay.tot-base + chk-pay.tot-base
            temp-pay.tot-rubl = temp-pay.tot-rubl + chk-pay.tot-rubl
            temp-pay.line-num = temp-pay.line-num + 1
            .
         DISPLAY STREAM PrnLibStream
            chk-pay.doc-code
            chk-pay.line-num
            chk-pay.curr-code
            if avail currency then currency.curr-name else "НЕОПОЗНАННАЯ ВАЛЮТА" @ currency.curr-name
            chk-pay.pay-code
            if avail cash-pay then cash-pay.obj-name else "НЕОПОЗНАННАЯ ОПЛАТА" @ cash-pay.obj-name
            f-paycardv(chk-pay.pay-card, chk-pay.pay-code, chk-pay.curr-code) @ pay-card-num
            chk-pay.tot-sum
            chk-pay.tot-base
            chk-pay.tot-rubl
            WITH FRAME Pay-Frame.
         DOWN STREAM PrnLibStream  with frame Pay-Frame.
         assign
            accum-count    = accum-count + 1
            accum-tot-rubl = accum-tot-rubl + chk-pay.tot-rubl
            accum-tot-base = accum-tot-base + chk-pay.tot-base
            .
      END.
      GET next br-docs  no-lock.
   END.
   UNDERLINE  STREAM PrnLibStream
      chk-pay.doc-code
      chk-pay.line-num
      chk-pay.curr-code
      currency.curr-name
      chk-pay.pay-code
      cash-pay.obj-name
      pay-card-num
      chk-pay.tot-sum
      chk-pay.tot-base
      chk-pay.tot-rubl
      with FRAME Pay-Frame .
   for each temp-pay No-LOCK
      by temp-pay.pay-code
      by temp-pay.curr-code:
      FIND FIRST currency No-LOCK WHERE
         currency.curr-code = temp-pay.curr-code NO-ERROR.
      FIND FIRST cash-pay No-LOCK WHERE
         cash-pay.cdpay-code = temp-pay.pay-code AND
         cash-pay.curr-code = temp-pay.curr-code No-ERROR.
      DISPLAY STREAM PrnLibStream
         "кол. по типу оплаты:" @ chk-pay.doc-code
    (if temp-pay.line-num < 1000 then temp-pay.line-num else ?) @ chk-pay.line-num
    temp-pay.curr-code @ chk-pay.curr-code
    if avail currency then currency.curr-name else "НЕОПОЗНАННАЯ ВАЛЮТА" @ currency.curr-name
    temp-pay.pay-code @ chk-pay.pay-code
    if avail cash-pay then cash-pay.obj-name else "НЕОПОЗНАННАЯ ОПЛАТА" @ cash-pay.obj-name
    temp-pay.tot-sum @ chk-pay.tot-sum
    temp-pay.tot-base @ chk-pay.tot-base
    temp-pay.tot-rubl @ chk-pay.tot-rubl
    WITH FRAME Pay-Frame.
      DOWN STREAM PrnLibStream  with frame Pay-Frame.
   end.
   UNDERLINE  STREAM PrnLibStream
      chk-pay.doc-code
      chk-pay.line-num
      chk-pay.curr-code
      currency.curr-name
      chk-pay.pay-code
      cash-pay.obj-name
      pay-card-num
      chk-pay.tot-sum
      chk-pay.tot-base
      chk-pay.tot-rubl
      with FRAME Pay-Frame .
   DISPLAY STREAM PrnLibStream
      "ИТОГО"  @ chk-pay.doc-code
(if accum-count < 1000 then accum-count else ? )  @ chk-pay.line-num
"_" @ chk-pay.curr-code
"_" @ chk-pay.pay-code
"_" @ cash-pay.obj-name
string(accum-count) @ currency.curr-name
accum-tot-base @ chk-pay.tot-base
accum-tot-rubl @ chk-pay.tot-rubl
"_" @ chk-pay.tot-sum
with frame Pay-Frame.
   HIDE  STREAM PrnLibStream FRAME BottomFrame .
   HIDE  STREAM PrnLibStream FRAME Pay-Frame.
   output  STREAM PrnLibStream CLOSE.
   /*
   assign
   g#rep-tblname = ""
   g#rep-tblrid = -117
   g#rep-updflds = string( "Список чеков|" ) .
   */
   run waitfram-hide in this-procedure .
   run prn-lib-prn-file in this-procedure (
      input parParentProc
      ,input 8
      ).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-chg Dialog-Frame 
PROCEDURE proc-b-chg :
   /*------------------------------------------------------------------------------
     Purpose:
     Parameters:  <none>
     Notes:
   ------------------------------------------------------------------------------*/
   define input parameter p-change-type as character no-undo .

   DEFINE VARIABLE v-doc-rec              as recid     no-undo.
   DEFINE VARIABLE v-change-fields        as character no-undo .
   define variable v-can-back-shift       as logical   no-undo .
   DEFINE VARIABLE v-shift-date           like ub.chk-doc.shift-date no-undo .
   DEFINE VARIABLE v-shift-num            like ub.chk-doc.shift-num no-undo .
   define variable v-shift-name           like ub.chk-doc.shift-name no-undo .
   define variable v-shift-reservoir-from as int       no-undo.
   define variable v-shift-reservoir-to   as int       no-undo.
   DEFINE VARIABLE v-first-record         as recid     no-undo .
   define variable v-added                as logical   no-undo .
   define variable v-changed              as logical   no-undo.
   define variable v-added-num            as integer   no-undo .
   define variable v-changed-num          as int       no-undo.
   define variable l-shift-on             as logical   no-undo .
   define variable next-prev              as character no-undo .
   define variable glog                   as logical   no-undo .
   define variable v-pump                 like ub.chk-gds.pump no-undo .
   define variable v-b-code               like ub.chk-gds.b-code no-undo .


   do
      on error undo, return error
      on stop undo, return error
      :
      CASE p-change-type:
         when "one-change":U then 
            do:
               if NOT available c-doc then 
               do:
                  message
                     "Неправильно выбран чек."
                     view-as alert-box ERROR.
                  return error.
               end.
               if c-doc.out-code <> ? then 
               do:
                  message
                     "Этот чек включен в отчет о продаже." skip
                     "Изменение невозможно."
                     view-as alert-box INFORMATION .
                  return error.
               end.
               assign
                  v-doc-rec = recid(c-doc).
               run str/superchk.w
                  (
                  input parparentproc
                  ,input {&update}
                  ,input c-doc.obj-type
                  ,input c-doc.obj-code
                  ,input-output v-doc-rec
                  ,input ? /*this-procedure:handle*/
                  ,input-output next-prev
                  )
                  .
               RUN OpenBr in this-procedure ( input yes, input no, input '':U).
               REPOSITION br-docs to recid v-doc-rec no-error .
            end.
         when "list-shift":U then 
            do:
               if p-change-type = "list-shift" then 
               do:
                  message
                     "Вы хотите изменить дату, номер смены или резервуар для чеков?" skip
                     string(if index(frame {&frame-name}:title,"ФИЛЬТР" ) = 0 then
                     "Эта процедура может занять долгое время! Продолжать?"
                     else "":U)
                     view-as alert-box WARNING buttons YES-NO update glog.
                  if NOT glog then return error.
                  run str/chgshift.w (
                     input parparentproc
                     ,input {&table_chk-doc}
                     ,input parobj-type
                     ,input parobj-code
                     ,output v-shift-date
                     ,output v-shift-num
                     ,output v-shift-name
                     ,output v-shift-reservoir-from
                     ,output v-shift-reservoir-to
                     ,output v-change-fields
                     ,output v-can-back-shift
                     ).
                  if v-change-fields = '':U then return error.
               end.
               { gbl/objat.i
        {&shop}
        parobj-code
        "'shift-on=request'"
        l-shift-on
      }
               DO WHILE available c-doc :
                  GET prev br-docs  no-lock.
               END.
               GET next br-docs.
               if p-change-type = "list-shift" then 
               do:
                  _shift:
                  DO WHILE available c-doc
                     on error undo, next _shift
                     on stop undo, next _shift
                     :
                     run waitfram-show in this-procedure ( input "Ждите...").
                     assign
                        v-doc-rec = recid(c-doc)
                        v-added   = no
                        v-changed = no.
                     .
                     run str/chkshift.p (
                        input parparentproc
                        ,input l-shift-on
                        ,input v-doc-rec
                        ,input v-shift-date
                        ,input v-shift-num
                        ,input v-shift-name
                        ,input v-shift-reservoir-from
                        ,input v-shift-reservoir-to
                        ,input v-change-fields
                        ,input v-can-back-shift
                        ,output v-added
                        ,output v-changed
                        ) no-error.
                     if error-status:error then 
                     do:
                        GET next br-docs.
                        NEXT _shift.
                     end.
        
                     if v-changed then 
                        assign
                           v-changed-num = v-changed-num + 1.
                
                     if v-added then
                        assign
                           v-added-num = v-added-num + 1
                           .
                     if v-first-record = ? then v-first-record = v-doc-rec.
                     GET next br-docs.
                  END.
                  run waitfram-hide in this-procedure .
               end.
               change-type = "".
               RUN OpenBr in this-procedure ( input yes, input no, input '':U).
               APPLY "page-UP"   to br-docs.
               APPLY "page-down"   to br-docs.
               reposition br-docs to recid v-first-record no-error.
               apply "entry" to br-docs in frame {&frame-name}.
               if l-shift-on and p-change-type = "list-shift" then 
               do:
                  message
                     substitute("В результате изменения даты/номера смены или резервуара в указанной смене появилось &1 чеков, изменено &2 чеков", v-added-num, v-changed-num)
                     view-as alert-box  .
               end.
               if p-change-type = "list-pump" then 
               do:
                  message
                     substitute("N ТРК изменен для &1 чеков", v-added-num)
                     view-as alert-box .
               end.
            end. /*when */
      END CASE.
   end.
   run trg/userlog.p (
      input {&nwsdochs_action_update}
      , input {&table_chk-doc}
      , input ( buffer c-doc :handle )
      , input ?
      , input ""
      ) no-error.
   if error-status :error
      then 
   do:
      undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
         , {&new-line}
         , vss-workfile
         , return-value
         , error-status :get-message ( 1 ) ).
   end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame 
PROCEDURE proc-b-del :
   define input parameter del-type as character no-undo.
   define variable old-netto      as decimal no-undo.
   define variable old-tot-doc    as decimal no-undo.
   define variable old-discnt     as decimal no-undo.
   DEFINE VARIABLE v-first-record as recid   no-undo .
   define variable glog           as logical no-undo .
   define variable v-doc-rec      as recid   no-undo .
   define variable v-host-code    as integer no-undo .
   define variable varlog         as logical no-undo .
   define buffer del_chk-doc for chk-doc.
   define buffer buf_inkas   for inkas.
   define buffer buf_trn-doc for ub.trn-doc.
/*удаление может быть только на текущем объекте*/
   { gbl/hostcode.i parobj-type parobj-code v-host-code }
   { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_receipts_deletion':U
  {&cntxt-object}
  v-host-code
  c-doc.obj-type
  c-doc.obj-code
  0
  0
  0
  true
  glog
  }
   if NOT glog then return no-apply.
   case del-type:
      when "list":U then 
         do:
            IF par-mode = {&sale} then 
            do:
               if index(frame {&frame-name}:title,"ФИЛЬТР" ) = 0
                  and p-chk-type = 0
                  then 
               do:
                  message
                     "Вы хотите исключить ВСЕ чеки из продажи!" skip
                     "Эта процедура может занять долгое время! Продолжать?"
                     view-as alert-box WARNING buttons YES-NO update glog.
                  if NOT glog then return no-apply.
               end.
               ELSE 
               DO:
                  message
                     "Вы действительно хотите исключить ВСЕ чеки по текущему списку из продажи?!" skip
                     view-as alert-box WARNING buttons YES-NO update glog.
                  if NOT glog then return no-apply.
               END.
            end.
            ELSE 
            DO:
               IF par-mode = {&TDEDT_Inv} then 
               do:
                  message
                     "Вы действительно хотите исключить ВСЕ чеки по текущему списку из инвентаризации?!" skip
                     view-as alert-box WARNING buttons YES-NO update glog.
                  if NOT glog then return no-apply.
               end.
               else 
               do:
                  if index(frame {&frame-name}:title,"ФИЛЬТР" ) = 0
                     and p-chk-type = 0
                     then 
                  do:
                     message
                        "Вы хотите удалить ВСЕ НЕУЧТЕННЫЕ чеки по объекту!" skip
                        "Эта процедура может занять долгое время! Продолжать?" view-as alert-box
                        WARNING buttons YES-NO update glog.
                     if NOT glog then return no-apply.
                  end.
                  ELSE 
                  DO:
                     message
                        "Вы действительно хотите удалить ВСЕ НЕУЧТЕННЫЕ чеки по текущему списку?!" skip
                        view-as alert-box WARNING buttons YES-NO update glog.
                     if NOT glog then return no-apply.
                  END.
               end.
            end. /*not par-mode = {&sale}*/
         end. /*del-type = "list"*/
   END CASE.
   CASE par-mode:
      WHEN {&sale} then 
         do:
            if del-type = "list" then 
            do:
               DO WHILE available c-doc :
                  GET prev br-docs  no-lock.
               END.
               GET NEXT br-docs.
               _list0:
               DO WHILE available c-doc
                  on error undo, next _list0
                  on stop undo, next _list0
                  :
                  FIND FIRST del_chk-doc where
                     recid (del_chk-doc) = recid(c-doc) No-ERROR.
                  if not avail del_chk-doc then NEXT _list0.
                  if del_chk-doc.out-code <> ? then 
                  DO  :
                     run waitfram-show in this-procedure ( input "Ждите...").
                     FIND FIRST buf_inkas No-LOCK WHERE
                        buf_inkas.inkas-code = del_chk-doc.out-code No-ERROR.
                     assign
                        old-netto   = buf_inkas.netto
                        old-tot-doc = buf_inkas.tot-doc
                        old-discnt  = buf_inkas.discnt.
                     run str/excl-chk.p ( input parparentproc,  input v-curr-r-b, buffer del_chk-doc) no-error.
                     if error-status:error OR
                        (del_chk-doc.chk-type <> integer({&income-corr}) and del_chk-doc.chk-type <> integer({&expense-corr})
                        and 
                        (buf_inkas.netto <> old-netto  - del_chk-doc.netto OR
                        buf_inkas.tot-doc <> old-tot-doc  - del_chk-doc.tot-doc OR
                        buf_inkas.discnt <> old-discnt - del_chk-doc.discnt)
                        )
                        then 
                     do:
                        message
                           substitute("Исключение чека &1 из продажи &2 не удалось:&3&4 &5"
                           ,del_chk-doc.doc-code
                           ,del_chk-doc.out-code
                           , {&new-line}
                           ,error-status:get-message(1)
                           ,return-value
                           )
                           view-as alert-box ERROR.
                        undo, NEXT.
                     end.
                     deleted = yes.
                  END. /*transaction*/
                  GET next br-docs.
               END. /*DO WHILE AVAIL C-DOC*/
               run waitfram-hide in this-procedure .
               del-type = "".
               RUN OpenBr in this-procedure  ( input yes, input no, input '':U).
               APPLY "page-UP"   to br-docs.
               APPLY "page-down"   to br-docs.
               reposition br-docs to row 1 no-error.
               apply "entry" to br-docs in frame {&frame-name}.
            end. /*del-type = "list"*/
            if del-type = "one":U then 
            do:
               if available c-doc then 
               do:
                  if c-doc.out-code <> ? then 
                  do:
                     FIND FIRST del_chk-doc where
                        recid (del_chk-doc) = recid(c-doc) No-ERROR.
                     if not avail del_chk-doc then return error.
                     varlog = br-docs:select-next-row().
                     if not varlog then varlog = br-docs:select-prev-row().
                     v-doc-rec = recid(c-doc).
                     FIND FIRST buf_inkas No-LOCK WHERE
                        buf_inkas.inkas-code = del_chk-doc.out-code No-ERROR.
                     assign
                        old-netto   = buf_inkas.netto
                        old-tot-doc = buf_inkas.tot-doc
                        old-discnt  = buf_inkas.discnt.
                     run str/excl-chk.p ( input parparentproc, input v-curr-r-b, buffer del_chk-doc) no-error.
                     if error-status:error  OR
                        buf_inkas.netto <> old-netto  - del_chk-doc.netto OR
                        buf_inkas.tot-doc <> old-tot-doc  - del_chk-doc.tot-doc OR
                        buf_inkas.discnt <> old-discnt - del_chk-doc.discnt then 
                     do:
                        message
                           substitute("Исключение чека &1 из продажи &2 не удалось:&3&4 &5"
                           ,del_chk-doc.doc-code
                           ,del_chk-doc.out-code
                           , {&new-line}
                           ,error-status:get-message(1)
                           ,return-value
                           )
                           view-as alert-box ERROR.
                        undo, return error .
                     end.
                     deleted = yes.
                     RUN OpenBr in this-procedure ( input yes, input no, input '':U).
                     reposition br-docs to recid v-doc-rec no-error.
                     APPLY "ENTRY" to br-docs.
                     APPLY "VALUE-CHANGED" to br-docs.
                     return no-apply.
                  end. /*c-doc-out-code <> ?*/
               end. /*aval c-doc*/
            end. /*del=type = "one"*/
         END. /*&sale*/
      WHEN {&TDEDT_inv} then 
         do:
            if del-type = "list" then 
            do:
               DO WHILE available c-doc :
                  GET prev br-docs no-lock.
               END.
               GET NEXT br-docs.
               _list0:
               DO WHILE available c-doc
                  on error undo, next _list0
                  on stop undo, next _list0
                  :
                  v-doc-rec = recid( c-doc ).
                  FIND FIRST del_chk-doc where
                     recid (del_chk-doc) = v-doc-rec No-ERROR.
                  if not avail del_chk-doc then NEXT _list0.
                  if del_chk-doc.out-code <> ? then 
                  DO  :
                     run waitfram-show in this-procedure ( input "Ждите...").
                     FIND FIRST buf_inkas No-LOCK WHERE
                        buf_inkas.inkas-code = del_chk-doc.out-code No-ERROR.
                     run str/exclichk.p ( input parparentproc,   buffer del_chk-doc) no-error.
                     if error-status:error then 
                     do:
                        message
                           substitute("Исключение чека &1 из инвентаризации &2 не удалось:&3&4 &5"
                           ,del_chk-doc.doc-code
                           ,del_chk-doc.out-code
                           , {&new-line}
                           ,error-status:get-message(1)
                           ,return-value
                           )
                           view-as alert-box ERROR.
                        undo, NEXT.
                     end.
                     deleted = yes.
                  END. /*transaction*/
                  GET next br-docs .
               END. /*DO WHILE AVAIL C-DOC*/
               run waitfram-hide in this-procedure .
               del-type = "".
               RUN OpenBr in this-procedure( input yes,  input no,  input '':U).
               APPLY "page-UP"   to br-docs.
               APPLY "page-down"   to br-docs.
               reposition br-docs to row 1 no-error.
               apply "entry" to br-docs in frame {&frame-name}.
            end. /*del-type = "list"*/
            if del-type = "one":U then 
            do:
               if available c-doc then 
               do:
                  if c-doc.out-code <> ? then 
                  do:
                     v-doc-rec = recid (c-doc).
                     FIND FIRST del_chk-doc where
                        recid (del_chk-doc) = v-doc-rec No-ERROR.
                     if not avail del_chk-doc then return error.
                     varlog = br-docs:select-next-row().
                     if not varlog then varlog = br-docs:select-prev-row().
                     v-doc-rec = recid(c-doc).
                     FIND FIRST buf_trn-doc No-LOCK WHERE
                        buf_trn-doc.doc-code = del_chk-doc.out-code No-ERROR.
                     run str/exclichk.p ( input parparentproc, buffer del_chk-doc) no-error.
                     if error-status:error  then 
                     do:
                        message
                           substitute("Исключение чека &1 из инвентаризации &2 не удалось:&3&4 &5"
                           ,del_chk-doc.doc-code
                           ,del_chk-doc.out-code
                           , {&new-line}
                           ,error-status:get-message(1)
                           ,return-value
                           )
                           view-as alert-box ERROR.
                        undo, return error .
                     end.
                     deleted = yes.
                     RUN OpenBr in this-procedure( input yes,  input no,  input '':U).
                     reposition br-docs to recid v-doc-rec no-error.
                     APPLY "ENTRY" to br-docs.
                     APPLY "VALUE-CHANGED" to br-docs.
                     return no-apply.
                  end. /*c-doc-out-code <> ?*/
               end. /*aval c-doc*/
            end. /*del=type = "one"*/
         END. /*{&TDEDT_Inv}*/
      OTHERWISE 
      DO:
         CASE del-type:
            when "list":U then 
               do:
                  DO WHILE available c-doc :
                     GET prev br-docs  no-lock.
                  END.
                  GET NEXT br-docs.
                  _list1:
                  DO WHILE available c-doc
                     on error undo, next _list1
                     on stop undo, next _list1
                     :
                     run waitfram-show in this-procedure ( input "Ждите...").
                     FIND FIRST del_chk-doc where recid(del_chk-doc) = recid(c-doc) no-error.
                     if not avail del_chk-doc then next _list1.
                     run trg/userlog.p (
                        input {&nwsdochs_action_delete}
                        , input {&table_chk-doc}
                        , input ( buffer del_chk-doc :handle )
                        , input ?
                        , input ""
                        ) no-error.
                     if error-status :error
                        then 
                     do:
                        undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                           , {&new-line}
                           , vss-workfile
                           , return-value
                           , error-status :get-message ( 1 ) ).
                     end.
                     if del_chk-doc.out-code = ? then delete del_chk-doc no-error .
                     if error-status:error then 
                     do:
                        message
                           error-status:get-message(1) skip
                           return-value
                           view-as alert-box .
                     end.
                     GET next br-docs.
                  END.
                  run waitfram-hide in this-procedure .
                  del-type = "".
                  RUN OpenBr in this-procedure ( input yes, input no, input '':U).
                  APPLY "page-UP"   to br-docs.
                  APPLY "page-down"   to br-docs.
                  reposition br-docs to row 1 no-error.
                  apply "entry" to br-docs in frame {&frame-name}.
               end.
            when "one":U then 
               do:
                  if NOT available c-doc then 
                  do:
                     message "Неправильно выбран чек." view-as alert-box ERROR.
                     return no-apply.
                  end.
                  FIND del_chk-doc where recid (del_chk-doc) = recid(c-doc) No-ERROR.
                  if not avail del_chk-doc then return error.
                  varlog = br-docs:select-next-row().
                  if not varlog then varlog = br-docs:select-prev-row().
                  v-doc-rec = recid(c-doc).
                  run trg/userlog.p (
                     input {&nwsdochs_action_delete}
                     , input {&table_chk-doc}
                     , input ( buffer del_chk-doc :handle )
                     , input ?
                     , input ""
                     ) no-error.
                  if error-status :error
                     then 
                  do:
                     undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                        , {&new-line}
                        , vss-workfile
                        , return-value
                        , error-status :get-message ( 1 ) ).
                  end.
                  if del_chk-doc.out-code = ?  then delete del_chk-doc no-error.
                  if error-status:error then 
                  do:
                     message
                        error-status:get-message(1) skip
                        return-value
                        view-as alert-box .
                     del-type = "".
                     return no-apply.
                  end.
                  RUN OpenBr in this-procedure ( input yes, input no, input '':U).
                  reposition br-docs to recid v-doc-rec no-error.
                  APPLY "ENTRY" to br-docs.
                  APPLY "VALUE-CHANGED" to br-docs.
                  return no-apply.

               end. /*when "one":U then do:*/
         END CASE.
      END. /*otherwise*/
   END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame 
PROCEDURE proc-b-sch :
   define variable l-shift-on as logical   no-undo .
   define variable conf-attr  as character no-undo .
   define variable conf-par   as character no-undo .
   define variable par-type   as character no-undo .
   define variable cas-shft   as logical   no-undo .
   assign
      sch-code = ""
      sch-date = ?
      .
   display
      sch-code
      sch-date
      .
   assign
      tbl      = 'chk-doc'
      join-tbl = 'c-doc'
      fld      = ""
      lab      = ""
      spr      = ""
      dim      = '0'
      .
   /*run fltfield-add in this-procedure('doc-code', 'Номер в базе', '',                */
   /*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/
   /*run fltfield-add in this-procedure('chk-time', '', 'time',*/
   /*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/
   /*run fltfield-add in this-procedure('chk-type', 'Тип чека', 'receipt-code',        */
   /*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/
   /*run fltfield-add in this-procedure('office', 'Т или у', 'gds-type',               */
   /*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/
   /*CASE par-mode:                                                                                                  */
   /*  WHEN  {&all}                                                                                                  */
   /*  THEN DO:                                                                                                      */
   /*    run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code{&delim-flt}shift-date{&delim-flt}shift-num'*/
   /*                                      , 'Объект/Дата смены/№ смены'                                             */
   /*                                      , ('sht' + {&delim-par} +                                                 */
   /*                                         '':U + {&delim-par} +                                                  */
   /*                                         string(0) + {&delim-par} +                                             */
   /*                                         'no'),                                                                 */
   /*    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.                          */
   /*  end.                                                                                                          */
   /*  otherwise do:                                                                                                 */
   /*    /*проверим на сменность*/                                                                                   */
   /*      { gbl/objat.i                                                                                             */
   /*        {&shop}                                                                                                 */
   /*        parobj-code                                                                                             */
   /*        "'shift-on=request'"                                                                                    */
   /*        l-shift-on                                                                                              */
   /*      }                                                                                                         */
   /*    if not l-shift-on then do:                                                                                  */
   /*      /*найдем параметр - использовать смены на кассе или нет*/                                                 */
   /*      { gbl/cas-shft.i parobj-type parobj-code  cas-shft }                                                      */
   /*    end.                                                                                                        */
   /*    if l-shift-on                                                                                               */
   /*    or cas-shft then do:                                                                                        */
   /*      run fltfield-add in this-procedure('shift-date{&delim-flt}shift-num'                                      */
   /*                                        , 'Дата смены/№ смены'                                                  */
   /*                                        , ('sht' + {&delim-par} +                                               */
   /*                                          parobj-type + {&delim-par} +                                          */
   /*                                          string(parobj-code) + {&delim-par} +                                  */
   /*                                          'no'),                                                                */
   /*      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.                        */
   /*    end.                                                                                                        */
   /*  END.                                                                                                          */
   /*END CASE.                                                                                                       */
      
   run fltfield-add in this-procedure('chk-date', 'Дата чека на АРМ кассира', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
   /*run fltfield-add in this-procedure('shift-date', 'Дата Смены(учета)', '',         */
   /*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/
   /*run fltfield-add in this-procedure('shift-num', 'Порядок смены', '',              */
   /*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/
   run fltfield-add in this-procedure('shift-name', '№ смены', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
   /*run fltfield-add in this-procedure('chk-num', 'Номер по кассе', '',               */
   /*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/
   run fltfield-add in this-procedure('obj-code', 'Номер магазина', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
   /*run fltfield-add in this-procedure('chk-date', 'Дата чека', '',                   */
   /*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.*/
   run fltfield-add in this-procedure('chk-num', 'Номер чека', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
   run fltfield-add in this-procedure('pay-desk', 'Номер АРМ Кассира', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
   run fltfield-add in this-procedure('chk-time', 'Время чека', 'time',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
   /*run fltfield-add in this-procedure('sales-man', 'Код продавца', '',                                                  */
   /*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.                                   */
   /*run fltfield-add in this-procedure('cashier-psn-code', 'Кассир-код в справочнике клиентов', '',                      */
   /*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.                                   */
   /*run fltfield-add in this-procedure('salesman-psn-code', 'Продавец-код в справочнике клиентов', '',                   */
   /*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.                                   */
   /*run fltfield-add in this-procedure('tot-doc', '', '',                                                                */
   /*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.                                   */
   /*run fltfield-add in this-procedure('discnt', '', '',                                                                 */
   /*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.                                   */
   /*run fltfield-add in this-procedure('sub-discnt', 'Списания', '',                                                     */
   /*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.                                   */
   /*run fltfield-add in this-procedure('netto', 'Нетто сумма (выручка)', '',                                             */
   /*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.                                   */
   /*run fltfield-add in this-procedure('out-code', 'Номер продажи', '',                                                  */
   /*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.                                   */
   /*run fltfield-add in this-procedure('d-card', 'N дис.карты', '',                                                      */
   /*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.                                   */
   /*run fltfield-add in this-procedure('z-number', 'N Z-отчета', '',                                                     */
   /*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.                                   */
   /*run fltfield-add in this-procedure('entry(1 ~~054c-doc.doc-num~~054{&delim-par})', 'N док-та', 'function_character', */
   /*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.                                   */
   /*run fltfield-add in this-procedure('entry(1 ~~054c-doc.doc-num2~~054{&delim-par})', 'N заказа', 'function_character',*/
   /*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.                                   */
   /*run fltfield-add in this-procedure('PS', 'Примечание', '',                                                           */
   /*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.                                   */


   Filter-Block:
   DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
      ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
      ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
      run gbl/filter.w ( input parparentproc
         , INPUT (filter-point + {&delim-par} + filter-label)
         , INPUT tbl
         , INPUT join-tbl
         , INPUT fld
         , INPUT lab
         , INPUT spr
         , INPUT dim ).
      RUN OpenBr in this-procedure ( input yes, input no, input '':U).
   END. /* Filter-Block */
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
   define input parameter pardoc-code like ub.chk-doc.doc-code no-undo.

   /*assign                   */
   /*sch-date = ?             */
   /*.                        */
   /*display                  */
   /*sch-date                 */
   /*/*0 @ sch-sum*/          */
   /*with frame {&frame-name}.*/

   assign
      pardoc-code = {&double-quote} + pardoc-code + {&double-quote}.
   run OpenBr in this-procedure (
      input true /* p-open-query */
      ,input par-next  /* p-find-next  */
      ,input substitute("and c-doc.doc-code   begins &1 "
      , pardoc-code)
      ).
   apply "entry":u to sch-code in frame {&frame-name} .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-date Dialog-Frame 
PROCEDURE proc-find-date :
   /*------------------------------------------------------------------------------
     Purpose:
     Parameters:  <none>
     Notes:
   ------------------------------------------------------------------------------*/
   define input parameter par-next as logical no-undo.
   define input parameter parchk-date like ub.chk-doc.chk-date no-undo.
   define variable varchk-datechr as character no-undo.

   assign
      varchk-datechr = string(day(parchk-date)) + {&slash-char} +
                 string(month(parchk-date)) + {&slash-char} +
                 string(year(parchk-date)).


   run OpenBr in this-procedure (
      input true /* p-open-query */
      ,input true  /* p-find-next  */
      ,input substitute("and c-doc.chk-date = &1 "
      , varchk-datechr)
      ).
   apply "entry":u to sch-date in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-sum Dialog-Frame 
PROCEDURE proc-find-sum :
   /*------------------------------------------------------------------------------
     Purpose:
     Parameters:  <none>
     Notes:
   ------------------------------------------------------------------------------*/
   define input parameter par-next as logical no-undo.
   define input parameter partot-doc like ub.chk-doc.tot-doc no-undo.
   assign
      sch-date = ?
      .

   display
      sch-date
      "":U @ sch-code
      with frame {&frame-name}.
   /*assign
   par-netto = {&double-quote} + pardoc-code + {&double-quote}.*/
   run OpenBr in this-procedure (
      input false /* p-open-query */
      ,input par-next  /* p-find-next  */
      ,input substitute("and c-doc.netto = &1 "
      , partot-doc)
      ).
/* apply "entry":u to sch-sum in frame {&frame-name} . */


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-chk-doc Dialog-Frame 
PROCEDURE reposition-chk-doc :
   define input  parameter p-direction   as character no-undo .
   define output parameter p-chk-doc-recid as recid no-undo .

   /* перемещение на первую, последнюю, предыдущую, следующую */
   case p-direction :
      when "first":U
      then 
         do:
            get first br-docs.
         end.
      when "last":U
      then 
         do:
            get last br-docs.
         end.
      when "prev":U
      then 
         do:
            get prev br-docs.
            if not available c-doc then 
            do:
               message
                  "Это первый чек списка"
                  view-as alert-box.
            end.
         end.
      when "next":U
      then 
         do:
            get next br-docs.
            if not available c-doc then 
            do:
               message
                  "Это последний чек списка"
                  view-as alert-box.
            end.
         end.
   end case . /* p-direction */
   assign
      p-chk-doc-recid = recid(c-doc)
      .
   run reposition-query in this-procedure
      (input p-chk-doc-recid
      ).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-query Dialog-Frame 
PROCEDURE reposition-query :
   define input parameter p-recid as recid no-undo .

   if p-recid <> ?
      then 
   do:
      reposition br-docs to recid p-recid no-error.
   end.

   do with frame {&frame-name}:
      apply "entry":u to browse {&browse-name} .
      apply "VALUE-CHANGED":u to browse {&browse-name} .
   end. /* do with frame */


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
