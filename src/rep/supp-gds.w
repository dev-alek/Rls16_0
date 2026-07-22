/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Текущие остатки товаров по партиям по поставщику

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

Created:  30.10.98 by Андрей Исаков

*/

&scop FRAME-NAME   dialog-frame
&scop browse-name br-parts
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input param p-r-parts as character      no-undo.  /* все, свободно, остатки (факт) */
define input param p-one-all as character      no-undo.  /* текущий объект, все */
define input param p-supp-type as character    no-undo.  /* тип поставщика */
define input param p-supp-code as integer      no-undo.  /* код поставщика */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Текущие остатки товаров по партиям по поставщику".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ str/libbcrcn.i }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/alc-lib.i  }
{ trg/partsfnc.i }
{ gbl/waitfram.i }
{ gbl/fltopend.i defproc }

define variable filter-point as character no-undo init "supp-gds" .
define variable filter-point0 as character no-undo init "supp-gds" .
define variable filter-label0 as character no-undo init "Поставщик-партии-остатки" .
define variable filter-label as character no-undo init "Поставщик-партии-остатки" .
define variable sort-column-name as character no-undo .

define new shared buffer s-parts for ub.parts.         /* разделяемый буфер и query нужны для печати */
define new shared buffer s-goods for ub.goods.         /* разделяемый буфер и query нужны для печати */
define variable conf-par as char             no-undo.    /* для чтения параметра конфигурации */
define variable par-type as char             no-undo.    /* тип параметра конфигурации */
define variable v-doc-rec as recid no-undo .
define variable v-prt-rec as recid no-undo .
define variable p-curr-host-code like ub.sysconf.host-code no-undo .
define buffer supp_clients for ub.clients.
define buffer supp_currency for ub.currency.
define buffer buf_bar-code for ub.bar-code .
define buffer supp_pay-type for ub.pay-type.


/* ***********************  Control Definitions  ********************** */

def BUTTON b-doc
     LABEL "Д&окум"
     size 10 BY 1.

def BUTTON b-exit AUTO-GO
     LABEL "&Выход "
     size 10 BY 1.

def BUTTON b-sch
     LABEL "&Фильтр"
     size 10 BY 1.

def BUTTON b-gds
     LABEL "&Товар"
     size 10 BY 1.

def BUTTON b-print
     LABEL "Пе&чать"
     size 10 BY 1.

def BUTTON b-help
     LABEL "Помо&щь"
     size 10 BY 1.

def BUTTON b-in
     LABEL "П&Н"
     size 10 BY 1.

def BUTTON b-alt
     LABEL "Доп.&БК"
     size 10 BY 1.

def BUTTON b-pl
     LABEL "&Место"
     size 10 BY 1.

DEFINE VARIABLE rs-one-all AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Текущий объект", "current",
          "Все объекты фирмы",    "all"
     SIZE 40 BY .83
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE rs-parts AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
         "Приходы",      "input",
         "Все партии",   "all",
         "Факт остатки", "stock",
         "Свободно",     "free"
     SIZE 55.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE sh-code AS INTEGER FORMAT "999999999":U INITIAL 0
     LABEL "Поиск"
     VIEW-AS FILL-IN
     SIZE 10 BY .79 NO-UNDO.

DEFINE VARIABLE fi-b-code AS INTEGER FORMAT "999999999":U INITIAL 0
     LABEL "Бар-код"
     VIEW-AS FILL-IN
     SIZE 10 BY .79
     FGCOLOR 4  NO-UNDO.



def buffer p-b for ub.parts.

define variable ed-notes AS CHARACTER
     VIEW-AS EDITOR
     SIZE 49.5 BY 2.5 NO-UNDO.

DEF RECTANGLE rect-in EDGE-PIXELS 1 GRAPHIC-EDGE SIZE 77.5 BY 3.5  BGCOLOR 8.

def new shared QUERY br-parts FOR s-parts, s-goods SCROLLING.

define BROWSE br-parts QUERY br-parts NO-LOCK DISPLAY
      s-parts.artic     COLUMN-LABEL "Артикул"
      s-goods.gds-name  COLUMN-LABEL "Название"    FORMAT "x(30)"
      s-parts.fact-qnty COLUMN-LABEL "Факт"        FORMAT "->>>,>>9.<<<"
      s-parts.price-base
      (s-parts.price-base * s-parts.fact-qnty)
                        column-label "Сумма (вал)" format "->,>>>,>>>,>>9.99"
      s-parts.price-rubl
      (s-parts.price-rubl * s-parts.fact-qnty)
                        column-label "Сумма ({&abbr_rub})" format "->,>>>,>>>,>>9.99"
      get-parts-out-code (buffer s-parts)  COLUMN-LABEL {&status}     FORMAT "x(16)"
      (if s-parts.part-code = "" then
         "------"
       else
         s-parts.part-code)
                        COLUMN-LABEL "Партия"      FORMAT "x(14)"
      (s-parts.obj-type + " " + STRING (s-parts.obj-code))
                        COLUMN-LABEL "Объект"      FORMAT "x(13)"
    WITH SIZE 98 BY 9.5 SEPARATORS.


/* ************************  Frame Definitions  *********************** */

def FRAME {&frame-name}
     b-exit             AT ROW 1  COL 1
     b-gds              AT ROW 1  COL 19
     b-in               AT ROW 1  COL 29
     b-doc              AT ROW 1  COL 39
     b-sch              AT ROW 1  COL 49
     b-alt              AT ROW 1  COL 59
     b-pl               AT ROW 1  COL 69
     b-print            AT ROW 1  COL 79
     b-help             AT ROW 1  COL 89
     rs-parts           AT ROW 2  COL 1                  NO-LABEL
     rs-one-all         AT ROW 3 COL 11.5 NO-LABEL
     sh-code            AT ROW 4 COL 10 COLON-ALIGNED HELP   "Поиск по бар-коду"
     fi-b-code          AT ROW 4 COL 31 COLON-ALIGNED
     br-parts           AT ROW 5   COL 1.5
     rect-in            at row 15.2  col 1.5
     "  Информация из ПН" VIEW-AS TEXT SIZE 18 BY 0.7
                        AT ROW 14.5  COL 30
     s-parts.in-code    AT ROW 15.5  COL 8    COLON-ALIGNED LABEL "Номер"        VIEW-AS FILL-IN SIZE 15    BY 1 FGCOLOR 4
     s-parts.fact-date  AT ROW 15.5  COL 28   COLON-ALIGNED LABEL "Дата"         VIEW-AS FILL-IN SIZE 10    BY 1 FGCOLOR 4
     supp_clients.obj-name   AT ROW 15.5  COL 48   COLON-ALIGNED LABEL "Пост-к"       VIEW-AS FILL-IN SIZE 25    BY 1 FGCOLOR 4
     supp_pay-type.obj-name  AT ROW 16.5  COL 9   COLON-ALIGNED LABEL "Оплата"       VIEW-AS FILL-IN SIZE 29.25 BY 1 FGCOLOR 4
     s-parts.vat-type   AT ROW 16.5  COL 48   COLON-ALIGNED LABEL "НДС"          VIEW-AS FILL-IN SIZE 10    BY 1 FGCOLOR 4
     s-parts.vat-pc     AT ROW 16.5  COL 68   COLON-ALIGNED LABEL "% НДС"        VIEW-AS FILL-IN SIZE 8     BY 1 FGCOLOR 4
     s-parts.price-cli  AT ROW 17.5  COL 28   COLON-ALIGNED LABEL "Цена пост-ка" VIEW-AS FILL-IN SIZE 29.25 BY 1 FGCOLOR 4
     supp_currency.curr-abbr AT ROW 17.5  COL 48   COLON-ALIGNED no-LABEL             VIEW-AS FILL-IN SIZE 10    BY 1 FGCOLOR 4
     ed-notes           AT ROW 19    COL 29.5               no-label                                             bgcolor 8 fgcolor 4
     SPACE(0.49) SKIP(0.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
         TITLE "Партии".

/* ***************  Runtime Attributes and UIB Settings  ************** */

ASSIGN
       FRAME {&frame-name}:SCROLLABLE       = FALSE.

/* ************************  Control Triggers  ************************ */

on choose of b-print in frame {&frame-name} do:
apply "entry" to br-parts in frame {&frame-name}.
run rep/r-supgds.p (input parparentproc, input p-curr-obj-type, input p-curr-obj-code,  frame {&frame-name}:title).
end.

ON entry OF ed-notes IN FRAME {&frame-name} DO:
if not available s-parts then do:
  message
    "Неправильный выбор партии."
    view-as alert-box.
  return no-apply.
end.
v-prt-rec = recid (s-parts).
END.

ON leave OF ed-notes IN FRAME {&frame-name} DO:
do on stop undo, return no-apply:
  find p-b where recid (p-b) = v-prt-rec exclusive.
  p-b.PS = input frame {&frame-name} ed-notes.
end.
END.

ON RETURN, MOUSE-SELECT-DBLCLICK OF ed-notes IN FRAME {&frame-name} DO:
apply "entry" to br-parts in frame {&frame-name}.
return no-apply.
END.

ON RETURN, MOUSE-SELECT-DBLCLICK OF br-parts IN FRAME {&frame-name} DO:
END.

on value-changed of br-parts do:
define buffer s-prt for ub.gds-prt.
  if available s-parts then do:
    v-doc-rec = recid(s-parts).
    find first s-prt no-lock where
               s-prt.upper-code = s-goods.prt-root.
    find  first buf_bar-code no-lock where
          buf_bar-code.gds-code  = s-goods.gds-code
      and buf_bar-code.node-code = s-prt.node-code
     and buf_bar-code.in-code   = s-parts.in-code
     and buf_bar-code.part-code = s-parts.part-code
     and buf_bar-code.unit-cli  = s-goods.unit-base no-error.
    if available buf_bar-code then do:
      fi-b-code = buf_bar-code.b-code.
      display
      fi-b-code with frame {&frame-name}.
    end.
    else
      display
      ? @ fi-b-code with frame {&frame-name}.
    find first supp_pay-type no-lock where
         supp_pay-type.obj-code = s-parts.pay-code no-error.
    if available supp_pay-type then
      display
      supp_pay-type.obj-name
      with frame {&frame-name}.
    else
      display
      ? @ supp_pay-type.obj-name with frame {&frame-name}.
    find first supp_currency no-lock where
         supp_currency.curr-code = s-parts.exch-code no-error.
    if available supp_currency then do:
      display
      supp_currency.curr-abbr with frame {&frame-name}.
    end.
    else do:
      display
      ? @ supp_currency.curr-abbr
      with frame {&frame-name}.
    end.
    ed-notes = s-parts.PS.
    display
    s-parts.vat-pc
    s-parts.vat-type
    s-parts.price-cli
    s-parts.in-code
    s-parts.fact-date
    supp_clients.obj-name
    ed-notes with frame {&frame-name}.
  end.
  else do:
    V-DOC-REC = ?.
  END.
end.

ON CTRL-J OF sh-code IN FRAME Dialog-Frame /* Корр.счету */
DO:
  run proc-find-sh-code in this-procedure(yes, input frame {&frame-name} sh-code) no-error.
  if error-status:error then return no-apply.

END.

ON RETURN OF sh-code IN FRAME Dialog-Frame /* Корр.счету */
DO:
  run proc-find-sh-code in this-procedure(no, input frame {&frame-name} sh-code) no-error.
  if error-status:error then return no-apply.
END.

ON VALUE-CHANGED OF rs-parts IN FRAME {&frame-name}
DO:
define variable v-prt-rec as recid no-undo .
if available s-parts then v-prt-rec = recid (s-parts).
assign rs-parts.
run OpenBr in this-procedure ( input yes, input no, input '':U).
apply "entry" to br-parts.
reposition br-parts to recid v-prt-rec no-error.
return no-apply.
END.

ON VALUE-CHANGED OF rs-one-all IN FRAME {&frame-name}
DO:
define variable v-prt-rec as recid no-undo .
if available s-parts then v-prt-rec = recid (s-parts).
assign rs-one-all.
run OpenBr in this-procedure ( input yes, input no, input '':U).
apply "entry" to br-parts.
reposition br-parts to recid v-prt-rec no-error.
return no-apply.
END.

on choose of b-sch in frame {&frame-name} do:
  run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.
end.

on choose of b-gds in frame {&frame-name} do:
if not available s-parts then do:
  message "Неправильный выбор партии.".
  return no-apply.
end.
find s-goods where s-goods.artic = s-parts.artic
                      and s-goods.prod-type = s-parts.prod-type
                      and s-goods.prod-code = s-parts.prod-code no-lock.
run str/showgds.p ( input parparentproc
                   ,input ? /*p-call-handle*/
                   ,input s-goods.gds-code
                   ,input {&lookup}).
apply "entry" to br-parts in frame {&frame-name}.
end.

on choose of b-doc in frame {&frame-name} do:
if not available s-parts then do:
  message "Неправильный выбор партии.".
  return no-apply.
end.
find ub.trn-doc where ub.trn-doc.doc-code = s-parts.out-code no-lock no-error.
if not available trn-doc then do:
  message "Документ не найден.".
  return no-apply.
end.
find ub.doc-line where ub.doc-line.doc-code = ub.trn-doc.doc-code
                        and ub.doc-line.artic = s-parts.artic
                        and ub.doc-line.prod-type = s-parts.prod-type
                        and ub.doc-line.prod-code = s-parts.prod-code no-lock.
run str/trn-lkp.p (parparentproc, recid (ub.trn-doc), recid(ub.doc-line)).
apply "entry" to br-parts in frame {&frame-name}.
end.

on choose of b-in in frame {&frame-name} do:
if not available s-parts then do:
  message "Неправильный выбор партии.".
  return no-apply.
end.
find ub.trn-doc where ub.trn-doc.doc-code = s-parts.in-code no-lock no-error.
if not available ub.trn-doc then do:
  message "Документ не найден.".
  return no-apply.
end.
find ub.doc-line where ub.doc-line.doc-code = ub.trn-doc.doc-code
                        and ub.doc-line.artic = s-parts.artic
                        and ub.doc-line.prod-type = s-parts.prod-type
                        and ub.doc-line.prod-code = s-parts.prod-code no-lock.
run str/trn-lkp.p (parparentproc, recid (ub.trn-doc), recid(ub.doc-line)).
apply "entry" to br-parts in frame {&frame-name}.
end.

ON CHOOSE OF b-alt IN FRAME {&frame-name} /* Доп.БК */ DO:
def buffer s-code for ub.bar-code.
def buffer s-prt  for ub.gds-prt.
if not available s-parts then do:
  message "Неправильный выбор партии.".
  return no-apply.
end.
find s-goods no-lock where
     s-goods.artic = s-parts.artic and
     s-goods.prod-type = s-parts.prod-type and
     s-goods.prod-code = s-parts.prod-code.
find first s-prt no-lock where
           s-prt.upper-code = s-goods.prt-root.
find s-code no-lock where
     s-code.gds-code  = s-goods.gds-code and
     s-code.node-code = s-prt.node-code and
     s-code.in-code   = s-parts.in-code and
     s-code.part-code = s-parts.part-code and
     s-code.unit-cli  = s-goods.unit-base no-error.
if available s-code then
  run ref/alt-bc.w (parparentproc, p-curr-obj-type, p-curr-obj-code, s-code.b-code).
END.

ON CHOOSE OF b-pl IN FRAME {&frame-name} /* Место */ DO:
if not available s-parts then do:
  message "Неправильный выбор партии.".
  return no-apply.
end.

run str/pl-lkp.w
  (
    input parparentproc
   ,input recid(s-parts)
  ).

END.

/* ***************************  Main Block  *************************** */

IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

{ gbl/app_help.i }
{ gbl/setfltnm.i }
{ gbl/brwrepos.i
  &line-num=3
}


MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 { gbl/hostcode.i p-curr-obj-type p-curr-obj-code  p-curr-host-code }
  assign
  rs-parts = p-r-parts
  rs-one-all = p-one-all
  .
  find first supp_clients where
             supp_clients.obj-type = p-supp-type
         and supp_clients.obj-code = p-supp-code no-lock.
  dispLAY
  rs-parts
  rs-one-all
  with frame {&frame-name}.
  ENABLE
  b-exit
  b-gds
  b-alt
  b-pl
  b-help
  b-print
  sh-code
  br-parts
  b-in
  b-doc
  b-sch
  rs-parts
  ed-notes
  rs-one-all
  WITH FRAME {&frame-name}.
  v-doc-rec = ?.
  run OpenBr in this-procedure ( input yes, input no, input no).
  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus br-parts.
END.
RUN disable_UI.

/* **********************  Internal Procedures  *********************** */

PROCEDURE disable_UI :
  HIDE FRAME {&frame-name}.
END PROCEDURE.

PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
title0 = "Поставщик-партии-остатки" + {&space-char}.
run waitfram-show in this-procedure ("Ждите...").
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

&scop flt-open-open-query OPEN QUERY br-parts FOR EACH s-parts

&scop flt-open-dyn_open-query FOR EACH s-parts

&scop flt-open-query-handle QUERY br-parts:handle

&scop flt-open-open-query-tail , first s-goods no-lock where s-goods.artic = s-parts.artic ~
                                 and s-goods.prod-type = s-parts.prod-type ~
                                 and s-goods.prod-code = s-parts.prod-code


&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name s-parts

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name s-parts

&scop flt-open-waitfram yes

define variable l-open-query as logical   no-undo .


CASE rs-one-all :
  WHEN "all"        THEN DO:
    disable sh-code with frame {&frame-name}.
    case rs-parts :
      when "input" then do:
        ASSIGN
        filter-point = filter-point0 + rs-one-all + rs-parts
        filter-label = substitute("&1 Приходы по фирме", filter-label0)
        .
        if p-open-query then do:
        frame {&frame-name}:title = substitute("Поставщик: &1&2 &3 ПРИХОДЫ по фирме &4"
                                              , supp_clients.obj-type
                                              , supp_clients.obj-code
                                              , string(supp_clients.obj-name, "X(45)")
                                              , p-curr-host-code).
        end.

        { gbl/fltopend.i
          &where-cond = " s-parts.supp-type = p-supp-type ~
                      and s-parts.supp-code = p-supp-code ~
                      and s-parts.host-code = p-curr-host-code ~
                      and s-parts.status_ = yes ~
                      and s-parts.in-code = s-parts.out-code "
          &dyn_where-cond = " substitute('s-parts.supp-type = &1&2&1 ~
                      and s-parts.supp-code = &3 ~
                      and s-parts.host-code = &4 ~
                      and s-parts.status_ = yes ~
                      and s-parts.in-code = &1&5&1 ', ~{&double-quote~}, p-supp-type, p-supp-code, p-curr-host-code, s-parts.out-code)"

          &use-ind    = "  "
          &by         = "  " }
      end.
      when "all":U then do:
        if p-open-query then do:
        frame {&frame-name}:title = substitute("Поставщик: &1&2 &3 ВСЕ ПАРТИИ по фирме &4"
                                                , supp_clients.obj-type
                                                , supp_clients.obj-code
                                                , string(supp_clients.obj-name, "X(45)")
                                                , p-curr-host-code).
        end.
        assign
        filter-point = filter-point0 + rs-one-all + rs-parts
        filter-label = substitute("&1 Партии по фирме", filter-label0).

        { gbl/fltopend.i
          &where-cond = " s-parts.supp-type = p-supp-type ~
                      and s-parts.supp-code = p-supp-code ~
                      and s-parts.host-code = p-curr-host-code ~
                      and s-parts.status_ = no "
          &dyn_where-cond = " substitute('s-parts.supp-type = &1&2&1 ~
                      and s-parts.supp-code = &3 ~
                      and s-parts.host-code = &4 ~
                      and s-parts.status_ = no ', ~{&double-quote~}, p-supp-type, p-supp-code, p-curr-host-code)"

          &use-ind    = "  "
          &by         = "  " }
      end. /*when all*/
      when "stock" then do:
        if p-open-query then do:
          frame {&frame-name}:title = substitute("Поставщик : &1&2 &3 ФАКТ ОСТАТКИ по фирме &4"
                                                , supp_clients.obj-type
                                                , supp_clients.obj-code
                                                , string(supp_clients.obj-name, "X(45)")
                                                , p-curr-host-code ).
        end.
        assign
        filter-point = filter-point0 + rs-one-all + rs-parts
        filter-label = substitute("&1 остатки по фирме", filter-label0).
        { gbl/fltopend.i
          &where-cond = " s-parts.supp-type = p-supp-type ~
                        and s-parts.supp-code = p-supp-code ~
                        and s-parts.host-code = p-curr-host-code ~
                        and s-parts.status_ = no ~
                        and s-parts.rsrv-free = yes "
          &dyn_where-cond = " substitute('s-parts.supp-type = &1&2&1 ~
                        and s-parts.supp-code = &3 ~
                        and s-parts.host-code = &4 ~
                        and s-parts.status_ = no ~
                        and s-parts.rsrv-free = yes ', ~{&double-quote~}, p-supp-type, p-supp-code, p-curr-host-code)"

          &use-ind    = "  "
          &by         = "  " }
      end. /*"stock"*/
      when "free" then do:
        if p-open-query then do:
          assign
          frame {&frame-name}:title = substitute("Поставщик : &1&2 &3 СВОБОДНО по фирме &4"
                                                , supp_clients.obj-type
                                                , supp_clients.obj-code
                                                , string(supp_clients.obj-name, "X(45)")
                                                , p-curr-host-code ).
        end.
        assign
        filter-point = filter-point0 + rs-one-all + rs-parts
        filter-label = substitute("&1 свободно по фирме", filter-label0).
        { gbl/fltopend.i
          &where-cond = " s-parts.supp-type = p-supp-type ~
                        and s-parts.supp-code = p-supp-code ~
                        and s-parts.host-code = p-curr-host-code ~
                        and s-parts.status_ = no ~
                        and s-parts.out-code = {&free-code} "
          &dyn_where-cond = " substitute('s-parts.supp-type = &1&2&1 ~
                        and s-parts.supp-code = &3 ~
                        and s-parts.host-code = &4 ~
                        and s-parts.status_ = no ~
                        and s-parts.out-code = &1&5&1 ', ~{&double-quote~}, p-supp-type, p-supp-code, p-curr-host-code, {&free-code})"

          &use-ind    = "  "
          &by         = "  " }
      end. /*when free*/
    END CASE. /*CASE rs-parts`*/
  end. /*when all*/
  when "current" then do:
    enable sh-code with frame {&frame-name}.
    case rs-parts :
       when "input" then do:
         if p-open-query then do:
          frame {&frame-name}:title = substitute("Поставщик: &1&2 &3 Объект: &4&5 Приходы"
                                                , supp_clients.obj-type
                                                , supp_clients.obj-code
                                                , string(supp_clients.obj-name, "X(45)")
                                                , p-curr-obj-type
                                                , p-curr-obj-code).
        end.
        assign
        filter-point = filter-point0 + rs-one-all + rs-parts
        filter-label = substitute("&1 Приходы", filter-label0).
        { gbl/fltopend.i
          &where-cond = " s-parts.supp-type = p-supp-type ~
                        and s-parts.supp-code = p-supp-code ~
                        and s-parts.host-code = p-curr-host-code ~
                        and s-parts.status_ = yes ~
                        and s-parts.in-code = s-parts.out-code ~
                        and s-parts.obj-type = p-curr-obj-type ~
                        and s-parts.obj-code = p-curr-obj-code "
          &dyn_where-cond = " substitute('s-parts.supp-type = &1&2&1 ~
                        and s-parts.supp-code = &3 ~
                        and s-parts.host-code = &4 ~
                        and s-parts.status_ = yes ~
                        and s-parts.in-code = &1&5&1 ~
                        and s-parts.obj-type = &1&6&1 ~
                        and s-parts.obj-code = &7 ', ~{&double-quote~}, p-supp-type, p-supp-code, p-curr-host-code, s-parts.out-code, p-curr-obj-type, p-curr-obj-code)"

          &use-ind    = "  "
          &by         = "  " }
       end. /*when input*/
       when  "all":U then do:
         if p-open-query then do:
          frame {&frame-name}:title = substitute("Поставщик : &1&2 &3 Объект &4&5 ВСЕ ПАРТИИ"
                                                ,supp_clients.obj-type
                                                ,supp_clients.obj-code
                                                ,string(supp_clients.obj-name, "X(45)")
                                                ,p-curr-obj-type
                                                ,p-curr-obj-code).
        end.
        assign
        filter-point = filter-point0 + rs-one-all + rs-parts
        .

        { gbl/fltopend.i
          &where-cond = " s-parts.supp-type = p-supp-type ~
                        and s-parts.supp-code = p-supp-code ~
                        and s-parts.host-code = p-curr-host-code ~
                        and s-parts.status_ = no ~
                        and s-parts.obj-type = p-curr-obj-type ~
                        and s-parts.obj-code = p-curr-obj-code "
          &dyn_where-cond = " substitute('s-parts.supp-type = &1&2&1 ~
                        and s-parts.supp-code = &3 ~
                        and s-parts.host-code = &4 ~
                        and s-parts.status_ = no ~
                        and s-parts.obj-type = &1&5&1 ~
                        and s-parts.obj-code = &6 ', ~{&double-quote~}, p-supp-type, p-supp-code, p-curr-host-code, p-curr-obj-type, p-curr-obj-code)"

          &use-ind    = "  "
          &by         = "  " }
       end. /*when all*/
       when "stock" then do:
         if p-open-query then do:
          frame {&frame-name}:title = substitute("Поставщик : &1&2 &3 Объект &4&5 ФАКТ ОСТАТКИ"
                                                ,supp_clients.obj-type
                                                ,supp_clients.obj-code
                                                ,string(supp_clients.obj-name, "X(45)")
                                                ,p-curr-obj-type
                                                ,p-curr-obj-code).
         end.
         assign
         filter-point = filter-point0 + rs-one-all + rs-parts
         filter-label = substitute("&1 остатки по объекту", filter-label0).


        { gbl/fltopend.i
          &where-cond = " s-parts.supp-type = p-supp-type ~
                        and s-parts.supp-code = p-supp-code ~
                        and s-parts.host-code = p-curr-host-code ~
                        and s-parts.status_ = no ~
                        and s-parts.obj-type = p-curr-obj-type ~
                        and s-parts.obj-code = p-curr-obj-code ~
                        and s-parts.rsrv-free = yes "
          &dyn_where-cond = " substitute('s-parts.supp-type = &1&2&1 ~
                        and s-parts.supp-code = &3 ~
                        and s-parts.host-code = &4 ~
                        and s-parts.status_ = no ~
                        and s-parts.obj-type = &1&5&1 ~
                        and s-parts.obj-code = &6 ~
                        and s-parts.rsrv-free = yes ', ~{&double-quote~}, p-supp-type, p-supp-code, p-curr-host-code, p-curr-obj-type, p-curr-obj-code)"

          &use-ind    = "  "
          &by         = "  " }
      end. /*when stock*/
      when "free" then do:
        if p-open-query then do:
          frame {&frame-name}:title = substitute("Поставщик : &1&2 &3 Объект &4&5 СВОБОДНО"
                                                , supp_clients.obj-type
                                                , supp_clients.obj-code
                                                , string(supp_clients.obj-name, "X(45)")
                                                , p-curr-obj-type
                                                , p-curr-obj-code).
         end.
         assign
         filter-point = filter-point0 + rs-one-all + rs-parts
         filter-label = substitute("&1 свободно по объекту", filter-label0).
        { gbl/fltopend.i
          &where-cond = " s-parts.supp-type = p-supp-type ~
                        and s-parts.supp-code = p-supp-code ~
                        and s-parts.host-code = p-curr-host-code ~
                        and s-parts.status_ = no ~
                        and s-parts.obj-type = p-curr-obj-type ~
                        and s-parts.obj-code = p-curr-obj-code ~
                        and s-parts.out-code = {&free-code} "
          &dyn_where-cond = " substitute('s-parts.supp-type = &1&2&1 ~
                        and s-parts.supp-code = &3 ~
                        and s-parts.host-code = &4 ~
                        and s-parts.status_ = no ~
                        and s-parts.obj-type = &1&5&1 ~
                        and s-parts.obj-code = &6 ~
                        and s-parts.out-code = &1&7&1 ', ~{&double-quote~}, p-supp-type, p-supp-code, p-curr-host-code, p-curr-obj-type, p-curr-obj-code, {&free-code})"

          &use-ind    = "  "
          &by         = "  " }
      end. /*when free*/
    END CASE. /* case rs-parts*/
  end. /*when "current" then do:*/
END CASE. /*rs-one-all*/

if v-doc-rec <> ? then
REPOSITION br-parts to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-parts:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
if error-status:error
or (v-doc-rec = ? and v-fltopend-rowid[1] = ?)
then do:
  reposition br-parts to row 1 no-error.
end.
run waitfram-hide in this-procedure .
APPLY "ENTRY" TO br-parts.
APPLY "VALUE-CHANGED" TO br-parts in frame {&frame-name}.
END PROCEDURE.

procedure proc-find-sh-code :
define input parameter p-next as logical no-undo.
define input parameter p-sh-code as character no-undo .

define variable v-search-code as char no-undo.
define variable varresult   as character                no-undo.
define variable vartype-bc  as character                no-undo.
define variable varweight   as decimal                  no-undo.
define buffer search-goods for ub.goods.
do
on error undo, return error
:

  { str/sclspref.i }

  assign
  v-search-code = string(p-sh-code).
  { str/bc-rcnz.i
    parparentproc
    v-search-code
    ?
    p-curr-obj-type
    p-curr-obj-code
    yes
    no
    varscales-pref
    varpgscales-pref
    varresult
    vartype-bc
    varweight
    ub.bar-code
    ub.prod-bc
    ub.place
    no-error
  }
  if available bar-code then do:
    find search-goods no-lock where
        search-goods.gds-code = bar-code.gds-code no-error.
  end.
  else do:
    message
    "Бар-код не найден!"
    view-as alert-box.
    apply "entry" to sh-code in frame {&frame-name} .
    undo, return error .
  end.
  run OpenBr in this-procedure
      (input false /* p-open-query */
      ,input p-next  /* p-find-next  */
      ,input substitute("and s-parts.artic = &1 and s-parts.prod-type = &2 and s-parts.prod-code = &3 " +
                        "and s-parts.in-code = &4 and s-parts.part-code = &5 "
        , search-goods.artic
        , search-goods.prod-type
        , search-goods.prod-code
        , bar-code.in-code
        , bar-code.part-code
        )
      ).
  apply "entry":u to sh-code in frame {&frame-name} .
end.
end procedure. /* proc-find-sh-code */

procedure proc-b-sch :

  do
  on error undo, return error
  :
    assign
    tbl = 'parts'
    join-tbl = 's-parts'
    fld = ""
    lab = ""
    spr = ""
    dim = '0'
    .
    run fltfield-add in this-procedure('artic', 'Артикул', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('prod-type{&delim-flt}prod-code', 'Производитель', 'cli',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('price-base', 'Цена-бв', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('price-rubl', 'Цена-', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('in-code', 'Номер ПН', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('out-code', 'Статус', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Объект', 'cli',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('part-code', 'Номер-партии', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('status_', 'Закр', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('qnty', 'Кол.док.', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('fact-qnty', 'Факт.кол.', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('doc-type', 'Тип-док', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('fact-date', 'Дата-факт', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('pay-code', 'Код-оплаты', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('pl-code', 'Код-места', '',
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
      RUN OpenBr in this-procedure ( input yes, input no, input '':U).
    END. /* Filter-Block */
  end.
end procedure. /* proc-b-sch */
&UNdef FRAME-NAME