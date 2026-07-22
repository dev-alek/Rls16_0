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
DEFINE BUFFER buf_inkas FOR ub.inkas.
DEFINE BUFFER buf_obj FOR ub.clients.
DEFINE BUFFER c-doc FOR ub.chk-doc.
DEFINE BUFFER chk-gds FOR ub.chk-gds.
DEFINE BUFFER dis-obj FOR ub.dis-obj.
DEFINE BUFFER find_chk-gds FOR ub.chk-gds.
DEFINE BUFFER find_inkas FOR ub.inkas.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список чеков по бар-коду

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/08/05
Author: Bakhtadze Natalya
Creation date: 09/08/05

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter b-c like ub.bar-code.b-code no-undo.
define input parameter bttns  as char   no-undo .
/*кнопки для нажатия*/
define input parameter par-mode  as char   no-undo .
define input parameter pardoc-rec as recid no-undo.
define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.clients.obj-code no-undo.
define input parameter parout-code like ub.chk-doc.out-code no-undo.
define input parameter pard-card like ub.chk-doc.d-card no-undo.

/*типы документов в выборке*/
define output param rid-list    as  char no-undo . /* список recid'ов выбранных chk-gds */

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список чеков по бар-коду":U.
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/library.i }
{ gbl/flt-def.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ gbl/fltfield.i }
{ gbl/waitfram.i }
{ cmp/mrk-strf.i }
{ str/shftnmef.i chk-doc shift-name }
{ gbl/getcntxt.i def }
{ gbl/fltopend.i defproc }


define variable filter-point as character no-undo  .
define variable filter-point0 as character no-undo   .
define variable filter-label as character no-undo init "Список чеков по бар-коду" .
define variable filter-label0 as character no-undo  init "Список чеков по бар-коду" .

assign
filter-point0 = ({&main-barcode} + {&comma-char} + {&receipts})
.
define variable sort-column-name as character no-undo .
define variable print-type as character no-undo.
/*использовать смены на кассе для данного объекта*/
define  variable cas-shft as logical no-undo init no.
DEFINE VARIABLE v-cycle as logical no-undo .
DEFINE VARIABLE v-one-time as logical no-undo .
DEFINE VARIABLE deleted as logical no-undo .
define variable del-type as character no-undo.
define variable v-curr-r-b as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-print-host-code like ub.sysconf.host-code no-undo.
define variable p-chk-type like ub.chk-doc.chk-type no-undo .
define variable v-inkas-host-code as integer no-undo .
define variable v-inkas-obj-type as character no-undo .
define variable v-inkas-obj-code as integer no-undo .

define buffer buf_cli for ub.clients.
define buffer out_inkas for ub.inkas .
define buffer buf_bar-code for ub.bar-code.
define buffer buf_goods for ub.goods.
define buffer buf_gds-prt for ub.gds-prt.


{ cmp/gds-list.i gds-list def "new shared" }

def temp-table gds-bar no-undo
field b-code like ub.bar-code.b-code
field qnty   as decimal
index art is unique b-code .

&GLOBAL-DEFINE wro-code string(chk-gds.write-off-code)

&GLOBAL-DEFINE wro-code string(chk-gds.write-off-code)

&GLOBAL-DEFINE receipt-code string(c-doc.chk-type)
&SCOPED-DEFINE sort-clmn_2 mark-string(recid(chk-gds), rid-list)
&SCOPED-DEFINE dyn_sort-clmn_2 substitute('dynamic-function(&1mark-string&1, recid(chk-gds), &1&2&1)', ~{&double-quote~}, rid-list)
&scoped-define label-clmn_2 '*'
&SCOPED-DEFINE sort-clmn_4 ~{&receipt-name~}
&scoped-define label-clmn_4 'Тип_чека'
&SCOPED-DEFINE sort-clmn_8 (string (c-doc.chk-time, 'HH:MM'))
&scoped-define label-clmn_8 'Время'
&SCOPED-DEFINE sort-clmn_12 (chk-gds.discnt / chk-gds.price-base * 100)
&scoped-define label-clmn_12 '%'
&SCOPED-DEFINE sort-clmn_13 (chk-gds.price-base - chk-gds.discnt)
&scoped-define label-clmn_13 'Нетто цена'
&SCOPED-DEFINE sort-clmn_14 chk-gds.pump
&scoped-define label-clmn_14 'ТРК'
&SCOPED-DEFINE sort-clmn_15 chk-gds.nozzle-code
&scoped-define label-clmn_15 'Пист'
&SCOPED-DEFINE sort-clmn_16 chk-gds.loc1
&scoped-define label-clmn_16 'Рез'
&SCOPED-DEFINE sort-clmn_17 ~{&wro-name~}
&scoped-define label-clmn_17 'Код_спис'
/*&SCOPED-DEFINE sort-clmn_19 shift-name-no-err( buffer c-doc)
&scoped-define label-clmn_19 '№_см.'c  */

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
&Scoped-define INTERNAL-TABLES chk-gds c-doc

/* Definitions for BROWSE BR-docs                                       */
&Scoped-define FIELDS-IN-QUERY-BR-docs c-doc.office {&sort-clmn_2} c-doc.doc-code {&sort-clmn_4} chk-gds.line-num c-doc.chk-num c-doc.chk-date {&sort-clmn_8} chk-gds.doc-qnty chk-gds.price-base chk-gds.discnt {&sort-clmn_12} {&sort-clmn_13} {&sort-clmn_14} {&sort-clmn_15} {&sort-clmn_16} {&sort-clmn_17} c-doc.shift-date shift-name-no-err( buffer c-doc) c-doc.shift-date c-doc.shift-num c-doc.netto c-doc.tot-doc c-doc.discnt c-doc.sub-discnt c-doc.pay-desk c-doc.cashier c-doc.sales-man c-doc.out-code c-doc.d-card c-doc.doc-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-docs c-doc.cashier
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-docs c-doc
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-docs c-doc
&Scoped-define SELF-NAME BR-docs
&Scoped-define QUERY-STRING-BR-docs FOR EACH chk-gds NO-LOCK, ~
             EACH c-doc NO-LOCK
&Scoped-define OPEN-QUERY-BR-docs OPEN QUERY {&SELF-NAME} FOR EACH chk-gds NO-LOCK, ~
             EACH c-doc NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-docs ub.chk-gds c-doc
&Scoped-define FIRST-TABLE-IN-QUERY-BR-docs ub.chk-gds
&Scoped-define SECOND-TABLE-IN-QUERY-BR-docs c-doc


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel b-lkp b-allgood B-del ~
B-sale B-print B-sch B-Help Cb-chk-type RS-sort BR-docs ED-notes sch-code ~
sch-date sch-price mark-num
&Scoped-Define DISPLAYED-OBJECTS Cb-chk-type RS-sort ED-notes sch-code ~
sch-date sch-price mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU m-print
       MENU-ITEM m-gds          LABEL "Список строк чеков"
       RULE
       MENU-ITEM m-one-time     LABEL "Игнорировать повторение строк чеков"
              TOGGLE-BOX
       MENU-ITEM m-list         LABEL "Список чеков"
       RULE
       MENU-ITEM m-one          LABEL "Чек"
       MENU-ITEM m-spcf         LABEL "Спецификация"  .

DEFINE MENU MENU-B-del
       MENU-ITEM m_one          LABEL "Один чек"
       MENU-ITEM m_list         LABEL "Список чеков"  .


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-allgood
     LABEL "Все &БК"
     SIZE 10 BY 1.

DEFINE BUTTON B-del
     LABEL "Искл&ючить"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
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

DEFINE BUTTON B-sale
     LABEL "П&родажа"
     SIZE 10 BY 1.

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE Cb-chk-type AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 10
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 19 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE ED-notes AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE sch-code AS CHARACTER FORMAT "X(20)":U
     LABEL "номеру"
     VIEW-AS FILL-IN
     SIZE 19.1 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-date AS DATE FORMAT "99/99/9999":U
     LABEL "дате"
     VIEW-AS FILL-IN
     SIZE 11.6 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-price AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "цене"
     VIEW-AS FILL-IN
     SIZE 19.1 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE RS-sort AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Без сортировки/по фильтру", "unsort",
"По коду чека в БД", "doc-code"
     SIZE 51.9 BY 1.13 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-docs FOR
                ub.chk-gds,
                ub.c-doc SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-docs Dialog-Frame _FREEFORM
  QUERY BR-docs DISPLAY
      c-doc.office FORMAT "X(7)":U
  {&sort-clmn_2} COLUMN-LABEL {&label-clmn_2} FORMAT "X(1)":U
  c-doc.doc-code COLUMN-LABEL "Номер_чека" FORMAT "X(20)":U
  {&sort-clmn_4} COLUMN-LABEL {&label-clmn_4} FORMAT "X(8)":U
  chk-gds.line-num COLUMN-LABEL "NN" FORMAT "->>9":U
  c-doc.chk-num COLUMN-LABEL "N_по_кассе" FORMAT "->>>>>>>>9":U
  c-doc.chk-date FORMAT "99/99/9999":U
  {&sort-clmn_8} COLUMN-LABEL {&label-clmn_8}
  chk-gds.doc-qnty FORMAT "->>,>>>,>>9.<<<":U
  chk-gds.price-base FORMAT "->>>,>>>,>>9.99":U
  chk-gds.discnt FORMAT "->>>,>>>,>>9.99":U
  {&sort-clmn_12} COLUMN-LABEL {&label-clmn_12} FORMAT "->>9.<%":U
  {&sort-clmn_13} COLUMN-LABEL {&label-clmn_13} FORMAT "->>>,>>>,>>9.99":U
  {&sort-clmn_14} COLUMN-LABEL {&label-clmn_14} FORMAT ">9":U
  {&sort-clmn_15} COLUMN-LABEL {&label-clmn_15} FORMAT ">>9":U
  {&sort-clmn_16} COLUMN-LABEL {&label-clmn_16} FORMAT "X(3)":U
  {&sort-clmn_17} COLUMN-LABEL {&label-clmn_17} FORMAT "X(10)":U
  c-doc.shift-date COLUMN-LABEL "Смена_от" FORMAT "99/99/9999":U
 shift-name-no-err( buffer c-doc) COLUMN-LABEL "№_см." FORMAT "X(6)":U
  c-doc.shift-date COLUMN-LABEL "Смена_от" FORMAT "99/99/9999":U
  c-doc.shift-num COLUMN-LABEL "П" FORMAT ">9":U
  c-doc.netto COLUMN-LABEL "Сумма_оплат" FORMAT "->>>,>>>,>>9.99":U
  c-doc.tot-doc COLUMN-LABEL "Сумма_товарная" FORMAT "->>>,>>>,>>9.99":U
  c-doc.discnt COLUMN-LABEL "Скидка_общая" FORMAT "->>>,>>>,>>9.99":U
  c-doc.sub-discnt COLUMN-LABEL "Списания" FORMAT "->>>,>>>,>>9.99":U
  c-doc.pay-desk FORMAT ">>>9":U
  c-doc.cashier FORMAT "99999":U
  c-doc.sales-man COLUMN-LABEL "Прод-w" FORMAT "99999":U
  c-doc.out-code COLUMN-LABEL "Номер_РН" FORMAT "X(14)":U
  c-doc.d-card COLUMN-LABEL "N_диск._карты" FORMAT "X(19)":U
  c-doc.doc-num COLUMN-LABEL "№_док-та" FORMAT "X(19)":U
  ENABLE
  c-doc.cashier
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 15.03.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     b-lkp AT ROW 1 COL 31
     b-allgood AT ROW 1 COL 41
     B-del AT ROW 1 COL 51
     B-sale AT ROW 1 COL 61
     B-print AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     Cb-chk-type AT ROW 2 COL 1 NO-LABEL
     RS-sort AT ROW 2.03 COL 45 NO-LABEL
     BR-docs AT ROW 3.3 COL 1
     ED-notes AT ROW 18.67 COL 1 NO-LABEL
     sch-code AT ROW 20.8 COL 17.6 COLON-ALIGNED
     sch-date AT ROW 20.83 COL 48.3 COLON-ALIGNED
     sch-price AT ROW 20.83 COL 77.5 COLON-ALIGNED
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     "ПОИСК ПО" VIEW-AS TEXT
          SIZE 9.3 BY 1 AT ROW 20.8 COL 1.5
          FGCOLOR 4
     "Сортировка" VIEW-AS TEXT
          SIZE 12.8 BY .8 AT ROW 2.3 COL 30
          FGCOLOR 4
     SPACE(56.20) SKIP(18.89)
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
      TABLE: buf_inkas B "?" ? ub inkas
      TABLE: buf_obj B "?" ? ub clients
      TABLE: c-doc B "?" ? ub chk-doc
      TABLE: chk-gds B "?" ? ub chk-gds
      TABLE: dis-obj B "?" ? ub dis-obj
      TABLE: find_chk-gds B "?" ? ub chk-gds
      TABLE: find_inkas B "?" ? ub inkas
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-docs RS-sort Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-del:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-del:HANDLE.

ASSIGN
       B-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU m-print:HANDLE.

/* SETTINGS FOR COMBO-BOX Cb-chk-type IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-docs
/* Query rebuild information for BROWSE BR-docs
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH chk-gds NO-LOCK,
      EACH c-doc NO-LOCK.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY BR-docs FOR
                chk-gds,
                c-doc SCROLLING.
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


&Scoped-define SELF-NAME b-allgood
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-allgood Dialog-Frame
ON CHOOSE OF b-allgood IN FRAME Dialog-Frame /* Все БК */
DO:
DEFINE VARIABLE rid-list as character no-undo .
   run ref/gds-chks.w ( input parparentproc
                  ,input recid(buf_goods)
                  ,input bttns
                  ,input "gds-chk":U + {&comma-char} + par-mode
                  ,input ? /*pardoc-rec*/
                  ,input parobj-type
                  ,input parobj-code
                  ,input parout-code
                  ,input pard-card
                  ,output rid-list
                    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Исключить */
DO:
   if not available c-doc then return no-apply.
 if del-type = "" then do:
    run gbl/pop-up.p ( input b-del:handle, input no) no-error.
    if error-status:error then return no-apply.
 end.
 if del-type = "" then return no-apply.
 run proc-b-del in this-procedure ( input del-type) no-error.
  if error-status:error then do:
    del-type = '':U.
    return no-apply.
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
define variable next-prev as character no-undo .
  next-prev = '':U.
  DO WHILE next-prev = '':U:
        if NOT available c-doc then do:
                message "Неправильно выбран чек." view-as alert-box ERROR.
                return no-apply.
        end.
        v-doc-rec = recid (c-doc).
        .
       run str/superchk.w
                      (
                        input parparentproc
                       ,input {&lookup}
                       ,input c-doc.obj-type
                       ,input c-doc.obj-code
                       ,input-output v-doc-rec
                       ,input this-procedure:handle
                       ,input-output next-prev
                                    ).

  END .

  apply "entry" to br-docs in frame {&frame-name}.
  apply "value-changed" to br-docs in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable glog as logical no-undo .
    if available chk-gds then do:
     { gbl/markstrn.i chk-gds rid-list }
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
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
define variable glog as logical no-undo .
define variable v-doc-rec as recid no-undo .
  def buffer s-doc for ub.trn-doc.
  if not avail chk-gds then do:
    print-type = "":U.
    return no-apply.
  end.
   if print-type = "" then do:
     run gbl/pop-up.p ( input self:handle, input no) no-error.
   end.
   if print-type = "list":U or print-type = "gds":U then do:
      if (par-mode = {&g___object} or par-mode = {&all}) and index(frame {&frame-name}:title,"ФИЛЬТР" ) = 0 then do:
        CASE print-type:
          when "list":U then do:
               message "Вы хотите напечатать весь список чеков при невключенном фильтре!" skip
               "Эта процедура может занять долгое время! Продолжать?" view-as alert-box
              WARNING buttons YES-NO update glog.
              if NOT glog then return no-apply.
          end.
          when "gds":U then do:
               message "Вы хотите напечатать все строки чеков при невключенном фильтре!" skip
               "Эта процедура может занять долгое время! Продолжать?" view-as alert-box
              WARNING buttons YES-NO update glog.
              if NOT glog then return no-apply.
          end.
        END CASE.
      end.
      v-doc-rec = recid( chk-gds ).
      DO WHILE available chk-gds :
            GET prev br-docs no-lock.
      END.
      CASE print-type:
        when "list":U then do:
          run PrintProc in this-procedure.
        end.
        when "gds":U then do:
          run PrintProcGds in this-procedure.
        end.
     END CASE.
      print-type = "".
      reposition br-docs to recid v-doc-rec no-error.
      apply "entry" to br-docs in frame {&frame-name}.
    end.
    else do:
        if NOT available c-doc then do:
            message "Неправильно выбран чек." view-as alert-box ERROR.
            return no-apply.
        end.
        CASE print-type:
            when "one":U then do:
                run str/checkp.p ( input parparentproc, input c-doc.doc-code) no-error.
                print-type = "".
            end.
            when "spcf":U then do:
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


&Scoped-define SELF-NAME B-sale
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sale Dialog-Frame
ON CHOOSE OF B-sale IN FRAME Dialog-Frame /* Продажа */
DO:
    if NOT available chk-gds then do:
        message "Неправильно выбран чек." view-as alert-box ERROR.
        return no-apply.
    end.
    FIND find_inkas where
            find_inkas.inkas-code = chk-gds.out-code NO-LOCK no-error.
    if NOT available find_inkas then do:
            message "Для данного чека нет отчета о продаже.".
            return no-apply.
     end.
    run str/ink-lkp.p ( input parparentproc
                  ,input recid(find_inkas) ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if ( available chk-gds ) AND ( rid-list = "" ) then
    rid-list = string( recid( chk-gds ) ) .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON DELETE-CHARACTER OF BR-docs IN FRAME Dialog-Frame
DO:
  if b-mark:sensitive in frame {&frame-name} then
  APPLY "CHOOSE" to b-mark.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
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
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON RETURN OF BR-docs IN FRAME Dialog-Frame
OR MOUSE-SELECT-DBLCLICK OF {&self-name} IN FRAME {&frame-name}
DO:
      if b-sel:sensitive in frame {&frame-name}  = yes then
        apply "choose" to b-sel in frame {&frame-name}.
    else
        apply "choose" to b-lkp in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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
  define buffer ps_chk-doc for ub.chk-doc.
   DO on stop undo, return no-apply:
        FIND PS_chk-doc where recid (ps_chk-doc) = recid(c-doc) exclusive.
        if ps_CHk-doc.PS <> input frame {&frame-name} ed-notes then
        ps_chk-doc.PS = input frame {&frame-name} ed-notes.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-gds Dialog-Frame
ON CHOOSE OF MENU-ITEM m-gds /* Список строк чеков */
DO:
    print-type = "gds":U.
    apply "choose" to b-print in frame {&frame-name}.
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


&Scoped-define SELF-NAME m-one
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-one Dialog-Frame
ON CHOOSE OF MENU-ITEM m-one /* Чек */
DO:
    print-type = "one":U.
    apply "choose" to b-print in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-one-time
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-one-time Dialog-Frame
ON VALUE-CHANGED OF MENU-ITEM m-one-time /* Игнорировать повторение строк чеков */
DO:
  assign
  v-one-time = menu-item m-one-time:checked in menu m-print.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_list Dialog-Frame
ON CHOOSE OF MENU-ITEM m_list /* Список чеков */
DO:
    del-type = "list":U.
    apply "choose" to b-del in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_one
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_one Dialog-Frame
ON CHOOSE OF MENU-ITEM m_one /* Один чек */
DO:
    del-type = "one":U.
    apply "choose" to b-del in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-sort
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-sort Dialog-Frame
ON VALUE-CHANGED OF RS-sort IN FRAME Dialog-Frame
DO:
  assign
  RS-sort.
  Run OpenBr in this-procedure ( input yes, input no, input '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON CTRL-J OF sch-code IN FRAME Dialog-Frame /* номеру */
DO:
  run proc-find-code in this-procedure ( input yes, input frame {&frame-name} sch-code) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON RETURN OF sch-code IN FRAME Dialog-Frame /* номеру */
DO:
  run proc-find-code in this-procedure ( input no, input frame {&frame-name} sch-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-date Dialog-Frame
ON CTRL-J OF sch-date IN FRAME Dialog-Frame /* дате */
DO:
    run proc-find-date in this-procedure ( input yes, input frame {&frame-name} sch-date) no-error.
  if error-status:error then return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-date Dialog-Frame
ON RETURN OF sch-date IN FRAME Dialog-Frame /* дате */
DO:
  run proc-find-date in this-procedure ( input no, input frame {&frame-name} sch-date) no-error.
  if error-status:error then return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-price
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-price Dialog-Frame
ON CTRL-J OF sch-price IN FRAME Dialog-Frame /* цене */
DO:
  run proc-find-price in this-procedure ( input yes, input frame {&frame-name} sch-price) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-price Dialog-Frame
ON RETURN OF sch-price IN FRAME Dialog-Frame /* цене */
DO:
  run proc-find-price in this-procedure ( input no, input frame {&frame-name} sch-price) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/setfltnm.i }

{ gbl/brwrepos.i
  &line-num=5
}

{ gbl/brwrefre.i "v-doc-rec = recid(chk-gds). run OpenBr in this-procedure ( input yes, input no, input '':U). reposition br-docs to recid v-doc-rec no-error. v-doc-rec = ?.
             apply 'value-changed' TO BR-DOCS. " }

{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-sel  }
{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-del  }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
{ gbl/hot-key.i b-print }

{ gbl/srt-clmd.i
&browse-name = {&browse-name}
&frame-name  = {&frame-name}
&table-name = "chk-gds"
&ext-col = 28
&start-column  = 5
&sort-column-name     = "sort-column-name"
&sort-clmn_1   = "c-doc.office"
&label-clmn_2  = "{&label-clmn_2}"
&sort-clmn_2   = "{&sort-clmn_2}"
&dyn_sort-clmn_2  = "{&dyn_sort-clmn_2}"
&sort-clmn_3   = "c-doc.doc-code"
&label-clmn_4  = "{&label-clmn_4}"
&sort-clmn_4   = "{&sort-clmn_4}"
&label-clmn_8  = "{&label-clmn_8}"
&sort-clmn_6   = "c-doc.chk-num"
&sort-clmn_7   = "c-doc.chk-date"
&sort-clmn_8   = "{&sort-clmn_8}"
&sort-clmn_9   = "chk-gds.doc-qnty"
&sort-clmn_10  = "chk-gds.price-base"
&sort-clmn_11  = "chk-gds.discnt"
&label-clmn_12 = "{&label-clmn_12}"
&sort-clmn_12  = "{&sort-clmn_12}"
&label-clmn_13 = "{&label-clmn_13}"
&sort-clmn_13  = "{&sort-clmn_13}"
&Sort-clmn_14  = "{&sort-clmn_14}"
&label-clmn_14 = "{&label-clmn_14}"
&label-clmn_15 = "{&label-clmn_15}"
&sort-clmn_15  = "{&sort-clmn_15}"
&label-clmn_16 = "{&label-clmn_16}"
&sort-clmn_16  = "{&sort-clmn_16}"
&label-clmn_17 = "{&label-clmn_17}"
&sort-clmn_17  = "{&sort-clmn_17}"
&sort-clmn_18  = "c-doc.shift-date"
&sort-clmn_24  = "c-doc.pay-desk"
&sort-clmn_25  = "c-doc.cashier"
&sort-clmn_26  = "c-doc.sales-man"
&sort-clmn_27  = "c-doc.out-code"
&sort-clmn_28  = "c-doc.d-card"
&open-query = "run OpenBr  in this-procedure ( input yes, input no, input '')."
&open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input '')."
&re-move-clmn = "no"
&mv-brw-default = "no"
&sort-column-name     = "sort-column-name"
}

{ gbl/mv-clmn.i
  &browse-name = "br-docs"
  &frame-name = "{&frame-name}"
  &ext-col = 28
  &start-column = 10}

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
{ gbl/getcntxt.i get }
if entry(1, par-mode) = "gds-chks":u then do:
  assign
  v-cycle = yes
  par-mode = substr(par-mode, 10)
  .
end.
{ gbl/curr-r-b.i
  v-curr-r-b
}


  find buf_bar-code where
       buf_bar-code.b-code = b-c no-lock no-error.
  if not available buf_bar-code then do:
    return error.
  end.
  find FIRST buf_goods where
             buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK.

  find FIRST buf_gds-prt where
             buf_gds-prt.node-code = buf_bar-code.node-code no-lock.

CASE par-mode:
    WHEN {&all}        THEN DO:
    END.
    WHEN {&g___object} or when "free":U THEN DO:
      FIND FIRST buf_obj No-LOCK WHERE
                  buf_obj.obj-type = parobj-type and
                  buf_obj.obj-code = parobj-code No-ERROR.
      if not avail buf_obj then do:
        message vss-workfile vss-revision vss-description skip
        "Неверное значение параметров вызова parobj-type и/или parobj-code"
        parobj-type parobj-code
        view-as alert-box ERROR.
        return.
      end.
    END.
    when "d-card":U or when ("d-card" + {&comma-char} + {&sale}) then do:
        FIND FIRST buf_dis-card where
                          buf_dis-card.d-card = pard-card No-LOCK NO-ERROR.
      if not avail buf_dis-card then do:
          message vss-workfile vss-revision vss-description skip
          "Неверное значение параметра вызова pard-card" pard-card
          view-as alert-box ERROR.
          return.
      end.
       FIND FIrst  buf_clients NO-LOCK WHERE
                        buf_clients.obj-type = buf_dis-card.cli-type AND
                        buf_clients.obj-code = buf_dis-card.cli-code No-ERROR.
    end.
    WHEN {&sale}  or when ("d-card" + {&comma-char} + {&sale}) then do:
        FIND buf_inkas where buf_inkas.inkas-code = parout-code NO-LOCK no-error.
      if not avail buf_inkas then do:
          message vss-workfile vss-revision vss-description skip
          "Неверное значение параметра вызова parout-code" parout-code
          view-as alert-box ERROR.
          return.
      end.
      assign
      v-inkas-host-code = buf_inkas.host-code
      v-inkas-obj-type = buf_inkas.obj-type
      v-inkas-obj-code = buf_inkas.obj-code
      .
    end.

    otherwise do:
      message vss-workfile vss-revision vss-description skip
      "Неверный вызов - par-mode=" par-mode
      view-as alert-box ERROR.
      return.
    end.
  end CASE.
    if pardoc-rec <> ? then do:
      FIND FIRST find_chk-gds No-LOCK where
                 recid(find_chk-gds) = pardoc-rec No-ERROR.
      if not avail find_chk-gds then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова pardoc-rec" pardoc-rec
        view-as alert-box error .
        return error.
      end.
      v-doc-rec = pardoc-rec.
    end.
  RUN MyEnable in this-procedure .
  RUn OpenBR  in this-procedure ( input yes, input no, input '':U).
  HIDE mark-num in frame {&frame-name} .
  if pardoc-rec <> ? then
  REPOSITION br-docs to recid v-doc-rec No-ERROR.
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
  DISPLAY Cb-chk-type RS-sort ED-notes sch-code sch-date sch-price mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel b-lkp b-allgood B-del B-sale B-print B-sch B-Help
         Cb-chk-type RS-sort BR-docs ED-notes sch-code sch-date sch-price
         mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-params Dialog-Frame
PROCEDURE get-params :
/*найдем параметр - использовать смены на кассе или нет*/
{ gbl/cas-shft.i parobj-type parobj-code cas-shft }
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
ASSIGN
cb-chk-type:LIST-ITEM-PAIRS  in frame {&frame-name} =  "Все типы чеков" + {&comma-char} + '0':U + {&comma-char} +
                                                       {&receipt-codes-combo-only-gds}
cb-chk-type = string(0)
p-chk-type = integer(cb-chk-type)
br-docs:NUM-LOCKED-COLUMNS IN FRAME {&frame-name} = 6
b-print:MENU-MOUSE = 1
b-del:MENU-MOUSE = 1
c-doc.cashier:READ-ONLY IN BROWSE {&BROWSE-NAME} = YES
RS-Sort = "doc-code":U
.

if lookup ({&sale}, par-mode) > 0 then do:
    assign
    v-doc-rec = ?
    .
end.
DISPLAY
ED-notes
sch-code
sch-date
sch-price
mark-num
Rs-sort
cb-chk-type when par-mode <> {&all}
WITH FRAME {&frame-name} .
ENABLE
b-allgood when v-cycle = no
b-quit
b-lkp
b-sch
b-sale when par-mode <> {&sale}
b-help
br-docs
b-sel  when LOOKUP("b-sel":U, bttns) > 0
b-mark when LOOKUP("b-mark":U, bttns) > 0
b-del WHEN LOOKUP("b-del":U, bttns) > 0 and lookup ({&sale}, par-mode) > 0 AND buf_Inkas.STATUS_ <> {&fact} and buf_inkas.status_ <> {&inquiry}
sch-code
sch-date
sch-price
ed-notes
b-print
Rs-sort
cb-chk-type when par-mode <> {&all}
WITH FRAME {&frame-name}.
/*
if not cas-shft then do:
    g#log = BR-docs:move-column(7,17).
    g#log = BR-docs:move-column(7,17).
end.
*/
IF lookup ({&sale}, par-mode) = 0 THEN DO:
    HIDE
    b-del
    IN FRAME {&FRAME-NAME}.
END.
if par-mode = {&all} then do:
  hide
  cb-chk-type
  in frame {&frame-name} .
end.
VIEW FRAME {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
DEFINE VARIABLE l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
title0 = "Список чеков по бар-коду:" + {&space-char} + string (b-c) + {&space-char} +
         "Артикул:" + {&space-char} + buf_goods.artic + {&space-char} + buf_goods.gds-name + {&space-char} .
run waitfram-show in this-procedure ( input "Ждите...").
DEFINE VARIABLE sort-column-phrase as character no-undo .

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

&scop flt-open-query-handle query br-docs:handle

&scop flt-open-open-query OPEN QUERY br-docs FOR EACH chk-gds

&scop flt-open-dyn_open-query  FOR EACH chk-gds

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name chk-gds

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name chk-gds

&scop flt-open-debug-file

define variable l-open-query as logical   no-undo .
&scop receipt-code string(p-chk-type)
CASE Rs-sort:
  when "unsort":U then do:
      CASE par-mode :
        WHEN {&all}        THEN DO:
 &scop flt-open-open-query-tail  , FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code
        assign
        filter-point = filter-point0 + par-mode
        filter-label = substitute("&1", filter-label0)
        .
        if p-open-query then do:
          ASSIGN frame {&frame-name}:TITLE = substitute("&1", title0).
        end.
        { gbl/fltopend.i
          &where-cond = " chk-gds.b-code = buf_bar-code.b-code "
          &dyn_where-cond = " substitute('chk-gds.b-code = &1', buf_bar-code.b-code) "
          &use-ind    = "  "
          &by =  " "
          }
          v-print-host-code = 0.
        END.
        WHEN {&g___object} THEN DO:
 &scop flt-open-open-query-tail  , FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code ~
                                    AND c-doc.obj-type = parobj-type AND c-doc.obj-code = parobj-code and (p-chk-type = 0 or c-doc.chk-type = p-chk-type)
 &scop flt-open-dyn_open-query-tail  substitute(', FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code ~
                                    AND c-doc.obj-type = "&1" AND c-doc.obj-code = &2 and (&3 = 0 or c-doc.chk-type = &3)' ~
                                    ,parobj-type ~
                                    ,parobj-code ~
                                    ,p-chk-type)


          { gbl/hostcode.i parobj-type parobj-code v-print-host-code }
          assign
          filter-point = filter-point0 + par-mode
          filter-label = substitute("&1 Один объект", filter-label0)
          .
          if p-open-query then do:
            ASSIGN frame {&frame-name}:TITLE = substitute("&1 Объект: &2&3 &4"
                                                        , title0
                                                        , parobj-type
                                                        , parobj-code
                                                        , (if p-chk-type = 0 then '':u else {&receipt-name})
                                                        )
            .
          end.

          { gbl/fltopend.i
            &where-cond = " chk-gds.b-code = buf_bar-code.b-code "
            &dyn_where-cond = " substitute('chk-gds.b-code = &1', buf_bar-code.b-code) "
            &use-ind    = "  "
            &by =  " "
            }

        END.
        WHEN "d-card":U    THEN DO:
 &scop flt-open-open-query-tail  , FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code ~
                                    AND c-doc.d-card = pard-card and (p-chk-type = 0 or c-doc.chk-type = p-chk-type)
 &scop flt-open-dyn_open-query-tail  substitute(', FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code ~
                                    AND c-doc.d-card = "&1" and ( &2 = 0 or c-doc.chk-type = &2)' ~
                                    ,pard-card ~
                                    ,p-chk-type )

          ASSIGN
          filter-point = filter-point0 + "КЛИЕНТ":U
          filter-label = substitute("&1 Один объект, Одна ДК", filter-label0)
          .
          if p-open-query then do:
            assign
            frame {&frame-name}:TITLE = substitute("&1 Чеки по карте № &2 Объект &3&4 &5"
                                                        ,title0
                                                        ,pard-card
                                                        ,parobj-type
                                                        ,parobj-code
                                                        , (if p-chk-type = 0 then '':u else {&receipt-name})
                                                        ) .
          end.
          { gbl/fltopend.i
            &where-cond = " chk-gds.b-code = buf_bar-code.b-code "
            &dyn_where-cond = " substitute('chk-gds.b-code = &1', buf_bar-code.b-code) "
            &use-ind    = "  "
            &by =  " "
            }
        END.
        WHEN ("d-card":U  + {&comma-char} + {&sale})   THEN DO:
 &scop flt-open-open-query-tail  , FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code ~
                                    AND c-doc.d-card = pard-card AND c-doc.obj-code = parobj-code and (p-chk-type = 0 or c-doc.chk-type = p-chk-type)
 &scop flt-open-dyn_open-query-tail  substitute(', FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code ~
                                    AND c-doc.d-card = "&1" AND c-doc.obj-type = "&2" AND c-doc.obj-code = &3 and (&4 = 0 or c-doc.chk-type = &4)' ~
                                    ,pard-card ~
                                    ,parobj-type ~
                                    ,parobj-code ~
                                    ,p-chk-type)


          { gbl/hostcode.i parobj-type parobj-code v-print-host-code }


          ASSIGN
          filter-point = filter-point0 + "КЛИЕНТ":U
          filter-label = substitute("&1 Один объект, Одна ДК, Одна продажа", filter-label0)
          .
          if p-open-query then do:
            assign
            frame {&frame-name}:TITLE = substitute("&1 Чеки по карте № &2 и отчету &3 Объект &4&5 &6"
                                                        ,title0
                                                        ,pard-card
                                                        ,parout-code
                                                        ,parobj-type
                                                        ,parobj-code
                                                        , (if p-chk-type = 0 then '':u else {&receipt-name})
                                                        ) .
          end.
          { gbl/fltopend.i
            &where-cond = " chk-gds.b-code = buf_bar-code.b-code AND chk-gds.out-code = parout-code "
            &dyn_where-cond = " substitute(' chk-gds.b-code = &1 AND chk-gds.out-code = &2&3&2 ', buf_bar-code.b-code, ~{&double-quote~}, parout-code) "
            &use-ind    = "  "
            &by =  " "
            }
        END.
        WHEN {&sale}   THEN DO:
 &scop flt-open-open-query-tail  , FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code and (p-chk-type = 0 or c-doc.chk-type = p-chk-type)
 &scop flt-open-dyn_open-query-tail  substitute(', FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code and (&1 = 0 or c-doc.chk-type = &1)' ~
                                                , p-chk-type)

        define buffer buf_inkas for ub.inkas.
          find first buf_inkas no-lock where buf_inkas.inkas-code = parout-code .
          v-print-host-code = buf_inkas.host-code.
          assign
          filter-point = filter-point0 + par-mode
          filter-label = substitute("&1 Одна продажа", filter-label0)
          .
          if p-open-query then do:
            ASSIGN frame {&frame-name}:TITLE = substitute("&1 Чеки по отчету &2 Объект &3&4 &5"
                                                          ,title0
                                                          ,parout-code
                                                          ,parobj-type
                                                          ,parobj-code
                                                          , (if p-chk-type = 0 then '':u else {&receipt-name})
                                                          )
            .
          end.
          { gbl/fltopend.i
            &where-cond = " chk-gds.b-code = buf_bar-code.b-code AND chk-gds.out-code = parout-code "
            &dyn_where-cond = " substitute(' chk-gds.b-code = &1 AND chk-gds.out-code = &2&3&2 ', buf_bar-code.b-code, ~{&double-quote~}, parout-code) "
            &use-ind    = "  "
            &by =  " "
            }
        END.
        WHEN "free":U    THEN DO:
 &scop flt-open-open-query-tail  , FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code ~
                                    AND c-doc.obj-type = parobj-type AND c-doc.obj-code = parobj-code and (p-chk-type = 0 or c-doc.chk-type = p-chk-type)
 &scop flt-open-dyn_open-query-tail  substitute(', FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code ~
                                    AND c-doc.obj-type = "&1" AND c-doc.obj-code = &2 and (&3 = 0 or c-doc.chk-type = &3)' ~
                                    ,parobj-type ~
                                    ,parobj-code ~
                                    ,p-chk-type)


          { gbl/hostcode.i parobj-type parobj-code v-print-host-code }
          assign
          filter-label = substitute("&1 Свободные чеки", filter-label0)
                                                        .

          filter-point = filter-point0 + "НЕУЧТЕННЫЕ":U.
          if p-open-query then do:
            ASSIGN frame {&frame-name}:TITLE = substitute("&1 НЕ включенные в отчеты чеки Объект &2&3 &4"
                                                          ,title0
                                                          ,parobj-type
                                                          ,parobj-code
                                                          , (if p-chk-type = 0 then '':u else {&receipt-name})
                                                          )
            .
          end.
          { gbl/fltopend.i
            &where-cond = " chk-gds.b-code = buf_bar-code.b-code AND chk-gds.out-code = ? "
            &dyn_where-cond = " substitute('chk-gds.b-code = &1 AND chk-gds.out-code = ? ', buf_bar-code.b-code) "
            &use-ind    = "  "
            &by =  " "
            }
        END.
    END CASE.
  end.
  when "doc-code":U then do:
      CASE par-mode :
        WHEN {&all}        THEN DO:
 &scop flt-open-open-query-tail  , FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code
        assign
        filter-point = filter-point0 + par-mode
        filter-label = substitute("&1", filter-label0)
        .
        { gbl/fltopend.i
            &where-cond = " chk-gds.b-code = buf_bar-code.b-code "
            &dyn_where-cond = " substitute('chk-gds.b-code = &1', buf_bar-code.b-code) "
            &use-ind    = "  "
            &by =  " by chk-gds.doc-code descending "
            }
        END.
        WHEN {&g___object} THEN DO:
 &scop flt-open-open-query-tail  , FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code ~
                                    AND c-doc.obj-type = parobj-type AND c-doc.obj-code = parobj-code and (p-chk-type = 0 or c-doc.chk-type = p-chk-type)
 &scop flt-open-dyn_open-query-tail  substitute(', FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code ~
                                    AND c-doc.obj-type = "&1" AND c-doc.obj-code = &2 and (&3 = 0 or c-doc.chk-type = &3)' ~
                                    ,parobj-type ~
                                    ,parobj-code ~
                                    ,p-chk-type )


          { gbl/hostcode.i parobj-type parobj-code v-print-host-code }
          ASSIGN
          filter-point = filter-point0 + par-mode
          filter-label = substitute("&1 Один чек, Один объект", filter-label0)
          .
          if p-open-query then do:
            assign
            frame {&frame-name}:TITLE = substitute("&1 Объект: &2&3 &4"
                                                          , title0
                                                          , parobj-type
                                                          , parobj-code
                                                          , (if p-chk-type = 0 then '':u else {&receipt-name})
                                                          ).
          end.
          { gbl/fltopend.i
            &where-cond = " chk-gds.b-code = buf_bar-code.b-code "
            &dyn_where-cond = " substitute('chk-gds.b-code = &1', buf_bar-code.b-code) "
            &use-ind    = "  "
            &by =  " by chk-gds.doc-code descending "
            }
        END.
        WHEN "d-card":U    THEN DO:
 &scop flt-open-open-query-tail  , FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code ~
                                    AND c-doc.d-card = pard-card and (p-chk-type = 0 or c-doc.chk-type = p-chk-type)
 &scop flt-open-dyn_open-query-tail  substitute(', FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code ~
                                    AND c-doc.d-card = "&1" and (&2 = 0 or c-doc.chk-type = &2)' ~
                                    ,pard-card ~
                                    ,p-chk-type )

          assign
          filter-point = filter-point0 + "КЛИЕНТ":U
          filter-label = substitute("&1 Один объект, Одна ДК", filter-label0)
          .
          if p-open-query then do:
            ASSIGN frame {&frame-name}:TITLE = substitute("&1 Чеки по карте № &2 Объект &3&4 &5"
                                                          ,title0
                                                          ,pard-card
                                                          ,parobj-type
                                                          ,parobj-code
                                                          , (if p-chk-type = 0 then '':u else {&receipt-name})
                                                          )
                                                                .
          end.
          { gbl/fltopend.i
            &where-cond = " chk-gds.b-code = buf_bar-code.b-code "
            &dyn_where-cond = " substitute('chk-gds.b-code = &1', buf_bar-code.b-code) "
            &use-ind    = "  "
            &by =  " by chk-gds.doc-code descending "
            }
        END.
        WHEN ("d-card":U  + {&comma-char} + {&sale})   THEN DO:
 &scop flt-open-open-query-tail  , FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code ~
                                    AND c-doc.d-card = pard-card AND c-doc.obj-code = parobj-code and (p-chk-type = 0 or c-doc.chk-type = p-chk-type)
 &scop flt-open-dyn_open-query-tail  substitute(', FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code ~
                                    AND c-doc.d-card = "&1" AND c-doc.obj-type = "&2" AND c-doc.obj-code = &3 and (&4 = 0 or c-doc.chk-type = &4)' ~
                                    ,pard-card  ~
                                    ,parobj-type ~
                                    ,parobj-code ~
                                    ,p-chk-type)


          { gbl/hostcode.i parobj-type parobj-code v-print-host-code }
          ASSIGN
          filter-point = filter-point0 + "КЛИЕНТ":U
          filter-label = substitute("&1 Один объект, Один ДК, одна продажа", filter-label0)
          .
          if p-open-query then do:
            assign
            frame {&frame-name}:TITLE = substitute("&1 Чеки по карте № &2 и отчету &3 Объект &4&5 &6"
                                                          ,title0
                                                          ,pard-card
                                                          ,parout-code
                                                          ,parobj-type
                                                          ,parobj-code
                                                          , (if p-chk-type = 0 then '':u else {&receipt-name})
                                                          ) .
          end.

          { gbl/fltopend.i
            &where-cond = " chk-gds.b-code = buf_bar-code.b-code AND chk-gds.out-code = parout-code "
            &dyn_where-cond = " substitute(' chk-gds.b-code = &1 AND chk-gds.out-code = &2&3&2 ', buf_bar-code.b-code, ~{&double-quote~}, parout-code ) "
            &use-ind    = "  "
            &by =  " by chk-gds.doc-code descending "
            }
        END.
        WHEN {&sale}   THEN DO:
 &scop flt-open-open-query-tail  , FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code and (p-chk-type = 0 or c-doc.chk-type = p-chk-type)
 &scop flt-open-dyn_open-query-tail  substitute(', FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code and (&1 = 0 or c-doc.chk-type = &1)' ~
                                                 ,p-chk-type )


          find first buf_inkas no-lock where buf_inkas.inkas-code = parout-code .
          v-print-host-code = buf_inkas.host-code.
          assign
          filter-label = substitute("&1 одна продажа", filter-label0)
          filter-point = filter-point0 + par-mode.
          if p-open-query then do:
            ASSIGN frame {&frame-name}:TITLE = substitute("&1 Чеки по отчету &2 Объект &3&4 &5"
                                                        ,title0
                                                        ,parout-code
                                                        ,parobj-type
                                                        ,parobj-code
                                                        , (if p-chk-type = 0 then '':u else {&receipt-name})
                                                        )
            .
          end.
          { gbl/fltopend.i
            &where-cond = " chk-gds.b-code = buf_bar-code.b-code AND chk-gds.out-code = parout-code "
            &dyn_where-cond = " substitute(' chk-gds.b-code = &1 AND chk-gds.out-code = &2&3&2 ', buf_bar-code.b-code, ~{&double-quote~}, parout-code) "
            &use-ind    = "  "
            &by =  " by chk-gds.doc-code descending "
            }
        END.
        WHEN "free":U    THEN DO:
 &scop flt-open-open-query-tail  , FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code ~
                                    AND c-doc.obj-type = parobj-type AND c-doc.obj-code = parobj-code and (p-chk-type = 0 or c-doc.chk-type = p-chk-type)
 &scop flt-open-dyn_open-query-tail  substitute(', FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code ~
                                    AND c-doc.obj-type = "&1" AND c-doc.obj-code = &2 and (&3 = 0 or c-doc.chk-type = &3)' ~
                                    ,parobj-type ~
                                    ,parobj-code ~
                                    ,p-chk-type)


          { gbl/hostcode.i parobj-type parobj-code v-print-host-code }
          assign
          filter-label = substitute("&1 свободные чеки", filter-label0)
          filter-point = filter-point0 + "НЕУЧТЕННЫЕ":U
          .
          if p-open-query then do:
            ASSIGN frame {&frame-name}:TITLE = substitute("&1 НЕ включенные в отчеты чеки Объект &2&3 &4"
                                                          ,title0
                                                          ,parobj-type
                                                          ,parobj-code
                                                          , (if p-chk-type = 0 then '':u else {&receipt-name})
                                                          )
            .
          end.
          { gbl/fltopend.i
            &where-cond = " chk-gds.b-code = buf_bar-code.b-code AND chk-gds.out-code = ? "
            &dyn_where-cond = " substitute('chk-gds.b-code = &1 AND chk-gds-out-code = ?', buf_bar-code.b-code) "
            &use-ind    = "  "
            &by =  " by chk-gds.doc-code descending "
            }
        END.
    END CASE.
  end.
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
DEFINE VARIABLE date_string     as      char    no-undo.
DEFINE VARIABLE Line                as      char    no-undo.
DEFINE VARIABLE for-time as char.
DEFINE VARIABLE accum-count as integer.
DEFINE VARIABLE accum-tot-doc as decimal.
DEFINE VARIABLE accum-discnt as decima.
DEFINE VARIABLE accum-sub-discnt as decimal.
DEFINE VARIABLE accum-netto as decimal.
define variable v-shift-name-num as character no-undo .
DEFINE VARIABLE v-doc-code like ub.chk-doc.doc-code no-undo .
define variable v-header-base-curr as character no-undo .
define variable v-base-code like ub.sysconf.host-code no-undo .
define variable v-base-type like ub.currency.curr-abbr no-undo .
define variable V-RECEIPT-NAME as character no-undo .

define buffer buf_currency for ub.currency.
if v-curr-r-b = {&r-b-base} then do:
  if v-print-host-code <> ? then do:
    { gbl/basecode.i v-print-host-code v-base-code }
    find first buf_currency where
            buf_currency.curr-code = v-base-code.
    assign
    v-base-type = buf_currency.curr-abbr.
  end.
end.

assign
v-header-base-curr = string( "( Б.Вал. - " + caps( v-base-type ) + " )" )
.



DEFINE FRAME Chk-List
c-doc.office        column-label "Тип"                format "X(8)"
c-doc.doc-code      column-label "Номер_чека/Номер_строки"  format "X(23)"
V-RECEIPT-NAME      COLUMN-LABEL "Тип_чека" format "X(8)"
c-doc.chk-num       column-label "N_касс" format "->>>>>>9"
c-doc.chk-date      column-label "Дата" format "99/99/9999"
for-time            column-label "Время"   format "X(5)"
c-doc.shift-date    column-label "Смена_от" format "99/99/9999"
v-shift-name-num    column-label "№_см." FORMAT "X(6)"
c-doc.tot-doc       column-label "Сумма_товарная"
c-doc.discnt        column-label "Скидка_общая"
c-doc.sub-discnt    column-label "Списания"
c-doc.netto         column-label "Сумма_оплат"
c-doc.pay-desk      column-label "Касса"
c-doc.cashier       column-label "Кассир"       format ">>>>9"
c-doc.sales-man     column-label "Прод-ц"       format ">>>>9"
c-doc.out-code      column-label "Номер_РН"
c-doc.d-card        column-label "Номер_диск.карты" format "X(16)" space(0)
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
v-header-base-curr        format "X(20)"
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
( frame {&frame-name}:title )
format "x({&A4_LS})" SKIP(1) .
FORM HEADER
Line format "X({&A4_LS})" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME Chk-List  .
run waitfram-show in this-procedure ( input "Ждите...").
GET next br-docs no-lock.
assign
v-doc-code = chk-gds.doc-code
.
DO WHILE available chk-gds :
  if v-one-time = no OR v-doc-code <> chk-gds.doc-code then do:
  &scop receipt-code string(c-doc.chk-type)
    Display STREAM PrnLibStream
    c-doc.office
    (if v-one-time
    then c-doc.doc-code
    else (string(c-doc.doc-code, "X(20)") + {&space-char} + string(chk-gds.line-num, "-99"))) @ c-doc.doc-code
    {&receipt-name} @ v-receipt-name
    c-doc.chk-num
    c-doc.chk-date
    string(c-doc.chk-time, "HH:mm") @ for-time
    c-doc.shift-date
    shift-name-no-err(buffer c-doc) @ v-shift-name-num
    c-doc.tot-doc
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
    accum-count = accum-count + 1
    accum-tot-doc = accum-tot-doc + c-doc.tot-doc
    accum-discnt = accum-discnt + c-doc.discnt
    accum-sub-discnt = accum-sub-discnt + c-doc.sub-discnt
    accum-netto = accum-netto + c-doc.netto.
  end.
  assign
  v-doc-code = chk-gds.doc-code
  .
  GET next br-docs no-lock.
END.
if v-one-time then do:
  UNDERLINE  STREAM PrnLibStream
  c-doc.office
  c-doc.doc-code
  v-receipt-name
  c-doc.chk-num
  c-doc.chk-date
  for-time
  c-doc.shift-date
  v-shift-name-num
  c-doc.tot-doc
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
  "_____" @ v-shift-name-num
  accum-tot-doc @ c-doc.tot-doc
  accum-discnt @ c-doc.discnt
  accum-sub-discnt @ c-doc.sub-discnt
  accum-netto @ c-doc.netto
  with frame Chk-List.
end.
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
DEFINE VARIABLE date_string     as      char    no-undo.
DEFINE VARIABLE Line                as      char    no-undo.
DEFINE VARIABLE for-time as char no-undo.
DEFINE VARIABLE accum-count as integer no-undo.
DEFINE VARIABLE accum-qnty as decimal no-undo.
DEFINE VARIABLE accum-tot-doc as decimal no-undo.
DEFINE VARIABLE accum-discnt as decimal no-undo.
DEFINE VARIABLE accum-netto as decimal no-undo.
DEFINE VARIABLE fgds-discnt-pc as decimal no-undo.
DEFINE VARIABLE for-gds-price like ub.chk-gds.price-base no-undo.
DEFINE VARIABLE for-gds-brutto like ub.chk-doc.netto no-undo.
DEFINE VARIABLE for-gds-netto like ub.chk-doc.netto no-undo.
DEFINE VARIABLE for-gds-discnt like ub.chk-doc.netto no-undo.
define variable v-write-off as logical no-undo .
define variable v-header-base-curr as character no-undo .
define variable v-base-code like ub.sysconf.host-code no-undo .
define variable v-base-type like ub.currency.curr-abbr no-undo .

define buffer buf_currency for ub.currency.
if v-curr-r-b = {&r-b-base} then do:
  if v-print-host-code <> ? then do:
    { gbl/basecode.i v-print-host-code v-base-code }
    find first buf_currency where
            buf_currency.curr-code = v-base-code.
    assign
    v-base-type = buf_currency.curr-abbr.
  end.
end.

assign
v-header-base-curr = string( "( Б.Вал. - " + caps( v-base-type ) + " )" )
.

DEFINE FRAME Goods-Frame
chk-gds.doc-code column-label "Номер_чека" FORMAT "X(18)"
chk-gds.line-num column-label "NN" format "-99"
chk-gds.is-error COLUMN-LABEL "Ош" FORMAT "+/ "
chk-gds.src-code Column-label "Код в спул-файле" FORMAT "X(16)"
chk-gds.pump column-label "ТРК"
chk-gds.nozzle-code column-label "Пист"
chk-gds.loc1 column-label "Рез"
chk-gds.doc-qnty
chk-gds.price-base
chk-gds.discnt
fgds-discnt-pc COLUMn-LABEL "% ск."  FORMAT "->9.99%"
for-gds-price COLUMN-LABEL "Цена нетто"
v-write-off COLUMn-LABEL "Сп" FORMAT "+/"
chk-gds.road-tax
for-gds-brutto COLUMN-LABEL "Сумма брутто"
for-gds-discnt COLUMN-LABEL "Сумма скидки"
for-gds-netto COLUMN-LABEL "Сумма нетто"
HEADER  date_string AT 5 format "X(35)"
v-header-base-curr        format "X(20)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
 Line format "X(230)" AT 1
with width {&DOS_CW_2} down stream-io use-text .


Line = fill("-", 183).
date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

PUT  STREAM PrnLibStream
(frame {&frame-name}:title + {&space-char} + "- строки чеков")
format "x(180)" SKIP(1) .
FORM HEADER
Line format "X(230)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME Goods-Frame  .
run waitfram-show in this-procedure ( input "Ждите..." ).
GET next br-docs no-lock.
DO WHILE available chk-gds :
    assign
    fgds-discnt-pc = (chk-gds.discnt / (chk-gds.price-base + chk-gds.price-service) * 100)
    for-gds-brutto = (chk-gds.price-base + chk-gds.price-service) * chk-gds.doc-qnty
    for-gds-discnt = chk-gds.discnt * chk-gds.doc-qnty
    for-gds-netto = (chk-gds.price-base + chk-gds.price-service - chk-gds.discnt) * chk-gds.doc-qnty
    for-gds-price = chk-gds.price-base + chk-gds.price-service - chk-gds.discnt
    .

    DISPLAY Stream PrnLibStream
    chk-gds.doc-code
    chk-gds.line-num
    chk-gds.is-error
    chk-gds.src-code
    chk-gds.pump
    chk-gds.nozzle-code
    chk-gds.loc1
    chk-gds.doc-qnty
    (chk-gds.price-base + chk-gds.price-service) @ chk-gds.price-base
    chk-gds.discnt
    fgds-discnt-pc
    for-gds-price
    (if chk-gds.write-off-code <> ?
    and chk-gds.write-off-code <> 0
    then yes
    else no
    )  @ v-write-off
    chk-gds.road-tax
    for-gds-brutto
    for-gds-discnt
    for-gds-netto
    WITH FRAME Goods-Frame.
    DOWN STREAM PrnLibStream with FRAME Goods-Frame .
    assign
    accum-count = accum-count + 1
    accum-qnty = accum-qnty + chk-gds.doc-qnty
    accum-tot-doc = accum-tot-doc + chk-gds.doc-qnty * (chk-gds.price-base + price-service)
    accum-discnt = accum-discnt + chk-gds.doc-qnty * chk-gds.discnt
    accum-netto = accum-netto + chk-gds.doc-qnty * (chk-gds.price-base + chk-gds.price-service - chk-gds.discnt)
    .
 /* DOWN STREAM PrnLibStream 1 with FRAME Goods-Frame  .*/
  GET next br-docs no-lock.
END.
UNDERLINE  STREAM PrnLibStream
chk-gds.doc-code
chk-gds.line-num
chk-gds.is-error
chk-gds.src-code
chk-gds.pump
chk-gds.nozzle-code
chk-gds.loc1
chk-gds.doc-qnty
chk-gds.price-base
chk-gds.discnt
fgds-discnt-pc
for-gds-price
v-write-off
chk-gds.road-tax
for-gds-brutto
for-gds-discnt
for-gds-netto
with FRAME Goods-Frame .
DISPLAY STREAM PrnLibStream
"ИТОГО"  @ chk-gds.doc-code
"_" @ chk-gds.line-num
"_" @ chk-gds.is-error
string(accum-count) @ chk-gds.src-code
"__" @ chk-gds.pump
"___" @ chk-gds.nozzle-code
"___" @ chk-gds.loc1
"_" @ chk-gds.price-base
"_" @ chk-gds.discnt
"_" @ fgds-discnt-pc
"_" @ for-gds-price
"_" @ v-write-off
"_" @ chk-gds.road-tax
ACCUM-qnty @ chk-gds.doc-qnty
accum-tot-doc @ for-gds-brutto
accum-discnt @ for-gds-discnt
accum-netto @ for-gds-netto
WITH FRAME Goods-Frame.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME Goods-Frame.
output  STREAM PrnLibStream CLOSE.
/*
assign
g#rep-tblname = ""
g#rep-tblrid = -117
g#rep-updflds = string( "Список чеков|" ) .
run waitfram-hide in this-procedure .
*/

run waitfram-hide in this-procedure .

run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame
PROCEDURE proc-b-del :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter del-type as character no-undo.
define variable old-netto as decimal no-undo.
define  variable old-tot-doc as decimal no-undo.
define  variable old-discnt as decimal no-undo.
define variable glog as logical no-undo .
define buffer buf_inkas for ub.inkas .
define buffer del_chk-doc for ub.chk-doc.
define variable v-rec as recid no-undo .

IF par-mode = {&sale} then do:
CASE del-type:
   when "list":U then do:
        if index(frame {&frame-name}:title,"ФИЛЬТР" ) = 0 then do:
       message
       "Вы хотите исключить ВСЕ чеки с товаром, проданным по данному бар-коду из продажи!" skip
       "Эта процедура может занять долгое время! Продолжать?"
       view-as alert-box WARNING buttons YES-NO update glog.
       if NOT glog then return error.
     end.
     ELSE DO:
       message
       "Вы действительно хотите исключить ВСЕ чеки текущему списка с товаром, проданным по данному бар-коду из продажи?!" skip
       view-as alert-box WARNING buttons YES-NO update glog.
       if NOT glog then return error.
     END.
      DO WHILE available c-doc :
            GET prev br-docs no-lock.
      END.
      GET next br-docs.
      _list0:
      DO WHILE available c-doc
      on error undo, next _list0
      on stop undo, next _list0
      :
        v-doc-rec = recid( c-doc ).
        FIND FIRST del_chk-doc where
                          recid (del_chk-doc) = v-doc-rec No-ERROR.
        if not avail del_chk-doc then NEXT _list0.
        if del_chk-doc.out-code <> ? then DO  :
          run waitfram-show in this-procedure ( input "Ждите...").
          FIND FIRST buf_inkas No-LOCK WHERE
                          buf_inkas.inkas-code = del_chk-doc.out-code No-ERROR.
          assign
          old-netto = buf_inkas.netto
          old-tot-doc = buf_inkas.tot-doc
          old-discnt = buf_inkas.discnt.
          run str/excl-chk.p (
                              input parparentproc
                            , input v-curr-r-b
                           , buffer del_chk-doc) no-error.
          if error-status:error OR
          buf_inkas.netto <> old-netto  - del_chk-doc.netto OR
          buf_inkas.tot-doc <> old-tot-doc  - del_chk-doc.tot-doc OR
          buf_inkas.discnt <> old-discnt - del_chk-doc.discnt then do:
            message
            substitute("Исключение чека &1 из продажи &2 не удалось:&3&4 &5"
                     ,del_chk-doc.doc-code
                     ,buf_inkas.inkas-code
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
      RUN OpenBr in this-procedure ( input yes, input no, input '':U).
      APPLY "page-UP"   to br-docs.
      APPLY "page-down"   to br-docs.
      reposition br-docs to row 1 no-error.
      apply "entry" to br-docs in frame {&frame-name}.
   end.
   when "one":U then do:
    if c-doc.out-code <> ? then do:
    v-doc-rec = recid (c-doc).

       get prev br-docs .
       v-rec = ?.
       if not available chk-gds then get first br-docs.
       else do :
        v-rec = recid(chk-gds).
       end.

       FIND FIRST del_chk-doc where
                  recid (del_chk-doc) = v-doc-rec No-ERROR.
       if not avail del_chk-doc then return error.
       FIND FIRST buf_inkas No-LOCK WHERE
                  buf_inkas.inkas-code = del_chk-doc.out-code No-ERROR.
       assign
       old-netto = buf_inkas.netto
       old-tot-doc = buf_inkas.tot-doc
       old-discnt = buf_inkas.discnt.
       del-type = "".
       run str/excl-chk.p (   input parparentproc
                        , input v-curr-r-b
                        , buffer del_chk-doc) no-error.
       if error-status:error  OR
       buf_inkas.netto <> old-netto  - del_chk-doc.netto OR
       buf_inkas.tot-doc <> old-tot-doc  - del_chk-doc.tot-doc OR
       buf_inkas.discnt <> old-discnt - del_chk-doc.discnt then do:
         message
         substitute("Исключение чека &1 из продажи &2 не удалось:&3&4 &5"
                     ,del_chk-doc.doc-code
                     ,buf_inkas.inkas-code
                     , {&new-line}
                     ,error-status:get-message(1)
                     ,return-value
                     )
         view-as alert-box ERROR.
         return error.
       end.
       deleted = yes.

       RUN OpenBr in this-procedure ( input yes, input no, input '':U).

       if v-rec <> ? then reposition br-docs to recid v-rec no-error.
       do with frame dialog-frame:
          apply "entry":u to browse br-docs .
          apply "VALUE-CHANGED":u to browse br-docs .
       end. /* do with frame */
      /* APPLY "page-UP"   to br-docs in frame {&frame-name}.
       APPLY "page-down"   to br-docs in frame {&frame-name}. */
    end. /*c-doc-out-code <> ?*/
  end.
END CASE.
end. /*par-mode = sale*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
  tbl = 'chk-gds'
  join-tbl = 'chk-gds'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('doc-code', 'Номер в базе', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-date', 'Дата чека', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('out-code', 'Номер продажи', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('line-num', 'Номер строки', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('src-code', 'Исходный код', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-qnty', 'Кол-во', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('price-base', 'Цена продажи', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pump', 'N ТРК', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('nozzle-code', 'Пистолет', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('loc1', 'Резервуар', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.




Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                  , INPUT (filter-point + {&delim-par} + filter-label)
                  , INPUT tbl
                  , INPUT join-tbl
                  , INPUT fld
                  , INPUT lab
                  , INPUT spr
                  , INPUT dim ).
  if return-value = {&flt-undo-value} then return error.
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
display
"  /  /":U @ sch-date
0 @ sch-price
with frame {&frame-name}.
assign
pardoc-code = {&double-quote} + pardoc-code + {&double-quote}.
run OpenBr in this-procedure (
     input false /* p-open-query */
    ,input par-next  /* p-find-next  */
    ,input substitute("and chk-gds.doc-code   begins &1 "
      , pardoc-code)
    ).
apply "entry":u to sch-code in frame {&frame-name} .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-date Dialog-Frame
PROCEDURE proc-find-date :
define input parameter par-next as logical no-undo.
define input parameter parchk-date like ub.chk-doc.chk-date no-undo.
define variable varchk-datechr as character no-undo.
display
'':U @ sch-code
0 @ sch-price
with frame {&frame-name}.

assign
varchk-datechr = string(day(parchk-date)) + {&slash-char} +
                 string(month(parchk-date)) + {&slash-char} +
                 string(year(parchk-date)).


run OpenBr in this-procedure (
   input false /* p-open-query */
  ,input true  /* p-find-next  */
  ,input substitute("and chk-gds.chk-date = &1 "
    , varchk-datechr)
  ).
apply "entry":u to sch-date in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-price Dialog-Frame
PROCEDURE proc-find-price :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter par-next as logical no-undo.
define input parameter par-price-base like ub.chk-gds.price-base no-undo.
display
"  /  /":U @ sch-date
"":U @ sch-code
with frame {&frame-name}.
/*assign
par-netto = {&double-quote} + pardoc-code + {&double-quote}.*/
run OpenBr in this-procedure (
     input false /* p-open-query */
    ,input par-next  /* p-find-next  */
    ,input substitute("and chk-gds.price-base = &1 "
      , par-price-base)
    ).
apply "entry":u to sch-price in frame {&frame-name} .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-chk-doc Dialog-Frame
PROCEDURE reposition-chk-doc :
define input  parameter p-direction   as character no-undo .
define output parameter p-chk-doc-recid as recid no-undo .
define variable v-chk-gds-recid  as recid no-undo .

  /* перемещение на первую, последнюю, предыдущую, следующую */
  case p-direction :
    when "first":U
    then do:
      get first br-docs.
    end.
    when "last":U
    then do:
      get last br-docs.
    end.
    when "prev":U
    then do:
      get prev br-docs.
      if not available c-doc then do:
        message
        "Это первый чек списка"
        view-as alert-box.
      end.
    end.
    when "next":U
    then do:
      get next br-docs.
      if not available c-doc then do:
        message
        "Это последний чек списка"
        view-as alert-box.
      end.
    end.
  end case . /* p-direction */
  assign
  p-chk-doc-recid = recid(c-doc)
  v-chk-gds-recid = recid (chk-gds)
  .

  run reposition-query in this-procedure
    (input v-chk-gds-recid
    ).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-query Dialog-Frame
PROCEDURE reposition-query :
define input parameter p-recid as recid no-undo .

  if p-recid <> ?
  then do:
    reposition br-docs to recid p-recid no-error.
  end.

  do with frame {&frame-name}:
    apply "entry":u to browse {&browse-name} .
    apply "VALUE-CHANGED":u to browse {&browse-name} .
  end. /* do with frame */


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
