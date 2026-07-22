

&Scoped-define WINDOW-NAME    d-out-prt
&Scoped-define FRAME-NAME     d-out-prt
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Задание факт. количества и цены по признаку или артикулу в поставках


Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 11/22/01 4:41

*/
/* ***************************  Definitions  ************************** */
define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter doc-rec       as recid no-undo .
define input  parameter line-rec       as recid no-undo .
define input  parameter gds-rec        as recid no-undo .
define input  parameter prt-mode       as character no-undo .
define input  parameter cur-rec  as recid no-undo.
define input  parameter node-type as char no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init " Задание факт. количества и цены по признаку в поставках".
{ cmp/vssrevis.i     }
{ cmp/trg-def.i      }
{ cmp/showinf.i      }
{ gbl/getcntxt.i def }
{ gbl/tax-name.i     }
{ str/lib-trn.i      }
{ cus/ord-lib.i def  }
{ cus/ord-lib.i last-price }
define variable g#host-name  as character no-undo .
define variable g#host-code    as integer   no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable g#log      as logical   no-undo .
define variable g#report-num as integer   no-undo .
define variable base-code as integer   no-undo .
define variable g#type as character no-undo .
define variable prt-rec as recid no-undo .
define variable loc-cli-base-rate as decimal no-undo.
{ gbl/getcntxt.i get }
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
.
{ gbl/hostname.i store-type store-code  g#host-code g#host-name }
run get-report-num in parParentProc ( output g#report-num ).
{ gbl/basecode.i g#host-code base-code }
 define variable g#ret-sup-pay as integer   no-undo .
 define buffer buf_sysconf for ub.sysconf.
 find first buf_sysconf no-lock where buf_sysconf.host-code = g#host-code no-error .
 g#ret-sup-pay = buf_sysconf.ret-sup-pay .

&glob  start-proc  do on stop undo : ~
  if error-status :error or return-value <> "" then ~
  message SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) view-as alert-box Title "start-proc".

&glob t-order order
{ cus/df-zakaz.i }


def buffer g-d-b-ord-dtl for ub.ord-dtl-rcv .
define variable chg-qnty         like ub.gds-dtl.doc-qnty init ? no-undo.

define variable kk as decimal no-undo .

DEF buffer b-c-b        for ub.bar-code.
def buffer out-dtl      for ub.ord-dtl-rcv .


define buffer b-ord-line     for  ub.ord-line-rcv .
define buffer b-ord-gds-dtl  for  ub.ord-dtl-rcv .

DEFINE QUERY br-dtl FOR b-ord-gds-dtl, ub.gds-prt, ub.goods, ub.bar-code SCROLLING.

/* ***********************  Control Definitions  ********************** */
/*

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход ":L
     SIZE 7.5 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 7.5 BY 1.

DEFINE VARIABLE base-curr AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 5 BY 1
     NO-UNDO.

DEFINE RECTANGLE RECT-tot
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 75.5 BY 7.5
     BGCOLOR 8 .

DEFINE RECTANGLE RECT-gds
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 63 BY 3
     BGCOLOR 8 .

DEFINE RECTANGLE RECT-discnt
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 75.5 BY 4.5
     BGCOLOR 8 .

DEFINE RECTANGLE RECT-qnty
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 24.5 BY 3.4
     BGCOLOR 8 .

DEFINE VARIABLE tot-base AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
     VIEW-AS TEXT
     SIZE 19.25 BY 1 NO-UNDO.

DEFINE VARIABLE tot-cli AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
     VIEW-AS TEXT
     SIZE 19.25 BY 1 NO-UNDO.

DEFINE VARIABLE tot-rubl AS DECIMAL FORMAT "->>,>>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма"
     VIEW-AS TEXT
     SIZE 23.25 BY 1 NO-UNDO.

DEFINE VARIABLE cli-curr AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.

  */


define variable varis-new     as logical             no-undo.

define buffer bf_goods          for ub.goods.
define buffer bf_units          for ub.units.
define buffer rt_tax            for ub.tax.

/* ************************  Frame Definitions  *********************** */

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход ":L
     SIZE 7.5 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 7.5 BY 1.

DEFINE VARIABLE base-curr AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE cli-curr AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 4 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE tot-base AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 19.25 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE tot-cli AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 18.13 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE tot-rubl AS DECIMAL FORMAT "->>,>>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма"
      VIEW-AS TEXT
     SIZE 23.25 BY .6
     FGCOLOR 4  NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 97.88 BY 4.17.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 19.75 BY 4.04
     BGCOLOR 3 FGCOLOR 15 .

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 27 BY 1.25
     BGCOLOR 3 FGCOLOR 15 .

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 89.13 BY 3.08.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 97.75 BY 4.33.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-out-prt
     b-exit AT ROW 1.29 COL 2
     b-help AT ROW 2.29 COL 2
     b-ord-gds-dtl.qnty AT ROW 9.21 COL 82.88 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN NATIVE
          SIZE 13 BY 1
          FGCOLOR 4
     b-ord-gds-dtl.price-rubl AT ROW 9.29 COL 6.63 COLON-ALIGNED
          LABEL "Цена"
          VIEW-AS FILL-IN NATIVE
          SIZE 17 BY 1
          FGCOLOR 4
     b-ord-gds-dtl.price-base AT ROW 9.29 COL 30.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN  NATIVE
          SIZE 17 BY 1
          FGCOLOR 4
     b-ord-gds-dtl.price-cli AT ROW 9.29 COL 50.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN  NATIVE
          SIZE 18.13 BY 1
          BGCOLOR 15 FGCOLOR 4
     b-ord-gds-dtl.cli-qnty AT ROW 10.38 COL 82.88 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN  NATIVE
          SIZE 13 BY 1
          FGCOLOR 4
     b-ord-gds-dtl.artic AT ROW 1.67 COL 9.38 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 16.5 BY 1
     ub.goods.gds-name AT ROW 1.67 COL 26.5 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 68.88 BY 1
          FGCOLOR 4
     b-ord-gds-dtl.prod-code AT ROW 3 COL 9.25 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 12.63 BY 1
     b-ord-gds-dtl.prod-type AT ROW 3 COL 22.13 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 16.63 BY 1
     ub.clients.obj-name AT ROW 3 COL 39 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 56.25 BY 1
          FGCOLOR 4
     ub.bar-code.b-code AT ROW 4.79 COL 17 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 10 BY .58
          FGCOLOR 4
     ub.gds-prt.f-name AT ROW 4.79 COL 27.88 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 39.75 BY .58
          FGCOLOR 4
     ub.prt-obj.free-qnty AT ROW 4.79 COL 78.88 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 16.25 BY .58
          FGCOLOR 4
     ub.price-list.doc-num AT ROW 5.63 COL 16.88 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 16 BY .58
     ub.goods.unit-base AT ROW 9.29 COL 77.75 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 4 BY 1
          FGCOLOR 4
     ub.goods.unit-cli AT ROW 10.38 COL 77.63 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 4 BY 1
          BGCOLOR 3 FGCOLOR 15
     tot-base AT ROW 10.46 COL 30.5 COLON-ALIGNED NO-LABEL
     tot-cli AT ROW 10.46 COL 50.5 COLON-ALIGNED NO-LABEL
     tot-rubl AT ROW 10.71 COL 6.38 COLON-ALIGNED
     ub.goods.qnty-cart AT ROW 11.58 COL 96.88 RIGHT-ALIGNED
          LABEL "Кол.в упак."
           VIEW-AS TEXT
          SIZE 13 BY .6
          FGCOLOR 4
     cli-curr AT ROW 11.75 COL 50.75 COLON-ALIGNED NO-LABEL
     base-curr AT ROW 11.83 COL 30.5 COLON-ALIGNED NO-LABEL
     RECT-5 AT ROW 4.42 COL 1.13
     RECT-4 AT ROW 1.25 COL 9.75
     RECT-3 AT ROW 10.29 COL 71.88
     RECT-1 AT ROW 8.79 COL 1
     "{&abbr_rub_allshift}" VIEW-AS TEXT
          SIZE 4 BY 1 AT ROW 11.83 COL 8.63
          FGCOLOR 4
     RECT-2 AT ROW 8.92 COL 51.75
     SPACE(27.49) SKIP(0.16)
    WITH VIEW-AS DIALOG-BOX
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         DEFAULT-BUTTON b-exit.



/* ***************  Runtime Attributes and UIB Settings  ************** */

ASSIGN
       FRAME {&frame-name}:SCROLLABLE       = FALSE.

/* ************************  Control Triggers  ************************ */
find b-ord-line where
                          b-ord-line.doc-code   = b-ord-gds-dtl.doc-code
                      and b-ord-line.rcv-code   = b-ord-gds-dtl.rcv-code
                      and b-ord-line.prod-code  = b-ord-gds-dtl.prod-code
                      and b-ord-line.prod-type  = b-ord-gds-dtl.prod-type
                      and b-ord-line.artic      = b-ord-gds-dtl.artic
                      no-lock.
assign
  loc-cli-base-rate = b-ord-line.cli-base-rate.
{ cus/ord-lib.i leave-qnty b-ord-gds-dtl }

ON CHOOSE OF b-exit IN FRAME {&frame-name} /* Выход */
DO:
assign
  prt-rec = recid (b-ord-gds-dtl)
  cur-rec = recid (ub.gds-prt)
  gds-rec = recid (ub.goods).
find b-ord-line where
                          b-ord-line.doc-code   = b-ord-gds-dtl.doc-code
                      and b-ord-line.rcv-code   = b-ord-gds-dtl.rcv-code
                      and b-ord-line.prod-code  = b-ord-gds-dtl.prod-code
                      and b-ord-line.prod-type  = b-ord-gds-dtl.prod-type
                      and b-ord-line.artic      = b-ord-gds-dtl.artic
                      no-lock.
line-rec = recid (b-ord-line).

assign
  b-ord-gds-dtl.sum-cli = b-ord-gds-dtl.cli-qnty * b-ord-gds-dtl.price-cli
  b-ord-gds-dtl.sum-base = b-ord-gds-dtl.qnty * b-ord-gds-dtl.price-base
  b-ord-gds-dtl.sum-rubl = b-ord-gds-dtl.qnty * b-ord-gds-dtl.price-rubl
  .

END.



on end-error, stop of frame {&frame-name} do:
  apply "choose" to b-exit in frame {&frame-name}.
  return no-apply.
end.

ON RETURN OF b-ord-gds-dtl.cli-qnty IN FRAME {&frame-name} /* По док */
DO:
 run apply-focus-next-entry in this-procedure  (input  b-ord-gds-dtl.cli-qnty:handle ) .
 return no-apply .
END.

ON RETURN OF b-ord-gds-dtl.qnty IN FRAME {&frame-name} /* {&fact} */
DO:
apply "choose" to b-exit in frame {&frame-name}.
END.

ON RETURN OF b-ord-gds-dtl.price-rubl IN FRAME {&frame-name} /* {&fact} */
DO:
apply "choose" to b-exit in frame {&frame-name}.
END.

ON RETURN OF b-ord-gds-dtl.price-base IN FRAME {&frame-name} /* {&fact} */
DO:
apply "choose" to b-exit in frame {&frame-name}.
END.


/* ***************************  Main Block  *************************** */

IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

{ gbl/app_help.i }

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
g#type = loc-doc-type.
find ub.gds-prt where recid (ub.gds-prt) = cur-rec no-lock.
if prt-mode = {&prt-def} and node-type <> {&g#term} then do:
  message "В режиме ШКАЛА можно указывать количества только по самым подробным признакам.".
  undo, return error.
end.
find ub.goods where recid (ub.goods) = gds-rec no-lock.
find ub.clients where ub.clients.obj-code = ub.goods.prod-code
               and ub.clients.obj-type = ub.goods.prod-type no-lock.

find ub.prt-obj where ub.prt-obj.prt-code = ub.gds-prt.node-code
                    and ub.prt-obj.prod-code = ub.goods.prod-code
                    and ub.prt-obj.prod-type = ub.goods.prod-type
                    and ub.prt-obj.artic     = ub.goods.artic
                    and ub.prt-obj.obj-code  = store-code
                    and ub.prt-obj.obj-type  = store-type
                    no-lock no-error.

  find b-ord-line where recid (b-ord-line) = line-rec.

  find b-ord-gds-dtl where b-ord-gds-dtl.node-code = ub.gds-prt.node-code
                      and b-ord-gds-dtl.prod-code = b-ord-line.prod-code
                      and b-ord-gds-dtl.prod-type = b-ord-line.prod-type
                      and b-ord-gds-dtl.artic     = b-ord-line.artic
                      and b-ord-gds-dtl.doc-code  = b-ord-line.doc-code
                      and b-ord-gds-dtl.rcv-code  = b-ord-line.rcv-code
                       exclusive-lock   no-error.

if not available b-ord-gds-dtl then do:
  if ub.gds-prt.upper-code = ub.goods.prt-root /* выключены шкалы на тек. объекте */
     or prt-mode = {&lookup} then do:
    /* 1. с объекта без признаков
       2. просмотр */
    message "Товара с таким признаком нет в данном заказе.".
    undo, return error.
  end.

  run create_gds-dtl in this-procedure (b-ord-line.rcv-code,
                      b-ord-line.doc-code,
                      ub.gds-prt.f-name,
                      b-ord-line.artic,
                      b-ord-line.prod-code,
                      b-ord-line.prod-type,
                      ub.gds-prt.node-code
                     ) no-error.

  if error-status:error then do:
     message "Ошибка при создании признака." skip
             return-value error-status:error
     view-as alert-box error.
      undo , return error.
  end.
 find first b-ord-gds-dtl where
                          b-ord-gds-dtl.doc-code  = b-ord-line.doc-code     and
                          b-ord-gds-dtl.rcv-code  = b-ord-line.rcv-code     and
                          b-ord-gds-dtl.artic     = b-ord-line.artic     and
                          b-ord-gds-dtl.prod-code = b-ord-line.prod-code and
                          b-ord-gds-dtl.prod-type = b-ord-line.prod-type and
                          b-ord-gds-dtl.node-code = ub.gds-prt.node-code  exclusive-lock  .
 run last-price in this-procedure  (
      input  g#host-code ,
      input  b-ord-gds-dtl.artic ,
      input  b-ord-gds-dtl.prod-type ,
      input  b-ord-gds-dtl.prod-code ,
      input  loc-cli-code  ,
      input  loc-cli-type  ,
      input  b-ord-line.cli-base-rate ,
      input  LOC-EXCH-CODE ,
      output b-ord-gds-dtl.price-base ,
      output b-ord-gds-dtl.price-rubl ,
      output b-ord-gds-dtl.price-cli )
      no-error  .
      if error-status :error then message  error-status :get-message(1) .
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

  if prt-mode = {&prt-def} then do:
    /* последующие признаки */
    find first g-d-b-ord-dtl where g-d-b-ord-dtl.prod-type = b-ord-line.prod-type
                       and g-d-b-ord-dtl.prod-code = b-ord-line.prod-code
                       and g-d-b-ord-dtl.artic     = b-ord-line.artic
                       and g-d-b-ord-dtl.doc-code  = b-ord-line.doc-code
                       and g-d-b-ord-dtl.rcv-code  = b-ord-line.rcv-code
                       and g-d-b-ord-dtl.node-code  <> ub.gds-prt.node-code no-lock no-error.
    if AVAILABLE g-d-b-ord-dtl then
    assign
      b-ord-gds-dtl.cli-qnty   = g-d-b-ord-dtl.cli-qnty
      b-ord-gds-dtl.qnty       = g-d-b-ord-dtl.qnty
      .
  end.
  /*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
end.  /* not available b-ord-gds-dtl */

frame {&frame-name}:title = "Заказ №  " + loc-ord-num + "    " +  {&row} + "     " + prt-mode.

cli-curr  = "" .
base-curr = "".
find first ub.currency where ub.currency.curr-code = base-code no-lock no-error.
  if available ub.currency then base-curr = ub.currency.curr-abbr .

find first ub.currency where ub.currency.curr-code = LOC-EXCH-CODE no-lock no-error.
  if available ub.currency then cli-curr = ub.currency.curr-abbr .
  disp cli-curr base-curr with frame {&frame-name} .

run UI-on in this-procedure .

if prt-mode = {&lookup} then WAIT-FOR GO OF FRAME {&FRAME-NAME} focus b-exit.
else  DO:
    WAIT-FOR GO OF FRAME {&FRAME-NAME} focus b-ord-gds-dtl.cli-qnty.
      chg-qnty = input frame {&frame-name} b-ord-gds-dtl.qnty - b-ord-gds-dtl.qnty.
      b-ord-line.qnty   = b-ord-line.qnty + chg-qnty  .
      b-ord-gds-dtl.qnty  = b-ord-gds-dtl.qnty + chg-qnty .

      chg-qnty = input frame {&frame-name} b-ord-gds-dtl.cli-qnty - b-ord-gds-dtl.cli-qnty.
      b-ord-line.cli-qnty   = b-ord-line.cli-qnty + chg-qnty  .
      b-ord-gds-dtl.cli-qnty  = b-ord-gds-dtl.cli-qnty + chg-qnty .


      b-ord-gds-dtl.price-rubl  = input frame {&frame-name} b-ord-gds-dtl.price-rubl .
      b-ord-gds-dtl.price-base  = input frame {&frame-name} b-ord-gds-dtl.price-base .

End.

prt-rec = recid (b-ord-gds-dtl).


if prt-mode <> {&lookup} then do:
  if b-ord-gds-dtl.cli-qnty = 0 and b-ord-gds-dtl.qnty = 0 then do:
    message "Удаляем строку, т.к. количество = 0.".
    delete b-ord-gds-dtl.
    prt-rec = ?.
  end.
end.
END.
run disable_UI in this-procedure .

/* **********************  Internal Procedures  *********************** */

PROCEDURE disable_UI :
  HIDE FRAME {&frame-name}.
END PROCEDURE.

PROCEDURE UI-on :
disable all with frame {&frame-name}.
enable
      b-exit
      b-help
/*    b-ord-gds-dtl.price-rubl
      b-ord-gds-dtl.price-base */
      b-ord-gds-dtl.price-cli
/*    b-ord-gds-dtl.qnty       */
      b-ord-gds-dtl.cli-qnty
      with frame {&frame-name}.

 run tax-name in this-procedure ( input {&road-tax}, output varroad-tax-label) no-error.

IF AVAILABLE ub.prt-obj    THEN DISPLAY ub.prt-obj.free-qnty   WITH FRAME {&frame-name}.
IF AVAILABLE ub.price-list THEN DISPLAY ub.price-list.doc-num  WITH FRAME {&frame-name}.

g#log = true .
if g#log and paytype <> g#ret-sup-pay or
    (paytype = g#ret-sup-pay) then
    if prt-mode = {&lookup} then hide ub.prt-obj.free-qnty ub.price-list.doc-num in frame {&frame-name}.

assign
  tot-rubl = b-ord-gds-dtl.qnty     * b-ord-gds-dtl.price-rubl
  tot-base = b-ord-gds-dtl.qnty     * b-ord-gds-dtl.price-base
  tot-cli  = b-ord-gds-dtl.cli-qnty * b-ord-gds-dtl.price-cli
  .
{ gbl/barcodcr.i
  ub.goods.gds-code
  b-ord-gds-dtl.node-code
  "''"
  "''"
  ub.goods.unit-base
  1
  varis-new
  b-c-b
  }
display b-c-b.b-code @ ub.bar-code.b-code with frame {&frame-name}.
disp tot-rubl
     tot-base
     tot-cli
     base-curr
     cli-curr
     ub.clients.obj-name
     ub.gds-prt.f-name
     b-ord-gds-dtl.artic
     b-ord-gds-dtl.prod-code
     b-ord-gds-dtl.prod-type
     b-ord-gds-dtl.price-rubl
     b-ord-gds-dtl.price-base
     b-ord-gds-dtl.price-cli
     b-ord-gds-dtl.cli-qnty
     b-ord-gds-dtl.qnty
     ub.goods.gds-name
     ub.goods.unit-base
     ub.goods.qnty-cart
     ub.goods.unit-cli
     with frame {&frame-name}.

if ub.gds-prt.upper-code = ub.goods.prt-root then hide ub.gds-prt.f-name in frame {&frame-name}.
END PROCEDURE.

procedure create_gds-dtl :
define input parameter p-rcv-code  like ub.ord-doc-rcv.rcv-code  no-undo.
define input parameter p-doc-code  like ub.ord-doc-rcv.doc-code  no-undo.
define input parameter parname    as character no-undo .
define input parameter parartic     like ub.goods.artic       no-undo.
define input parameter parprod-code like ub.goods.prod-code   no-undo.
define input parameter parprod-type like ub.goods.prod-type   no-undo.
define input parameter parprt-code  like ub.gds-dtl.prt-code  no-undo.
define buffer bf_gds-dtl for ub.ord-dtl-rcv.
define buffer bf_clients for ub.clients.
define buffer bf_goods   for ub.goods.


error-status:error = false .
find first bf_gds-dtl where bf_gds-dtl.artic      = parartic
                        and bf_gds-dtl.prod-code  = parprod-code
                        and bf_gds-dtl.prod-type  = parprod-type
                        and bf_gds-dtl.rcv-code   = p-rcv-code
                        and bf_gds-dtl.doc-code   = p-doc-code
                        and bf_gds-dtl.node-code  = parprt-code   no-error.
if not available bf_gds-dtl then do:

   find first bf_goods where bf_goods.artic     = parartic     and
                             bf_goods.prod-type = parprod-type and
                             bf_goods.prod-code = parprod-code no-lock no-error.
   if not available bf_goods then do:
      return error subst("Создание признака невозможно. Не найден товар &1 &2 &3.", parartic, parprod-code, parprod-code).
   end.
  { gbl/barcodcr.i
   bf_goods.gds-code
   parprt-code
   ''
   ''
   bf_goods.unit-base
   ?
   varis-new
   ub.bar-code
   no-error
   }

  create bf_gds-dtl.
    assign
      bf_gds-dtl.rcv-code       = p-rcv-code
      bf_gds-dtl.doc-code       = p-doc-code
      bf_gds-dtl.artic          = parartic
      bf_gds-dtl.prod-code      = parprod-code
      bf_gds-dtl.prod-type      = parprod-type
      bf_gds-dtl.node-code      = parprt-code
    .
end. /*not available*/
else do:
    assign
      bf_gds-dtl.rcv-code      = p-rcv-code
      bf_gds-dtl.doc-code      = p-doc-code
      bf_gds-dtl.artic         = parartic
      bf_gds-dtl.prod-code     = parprod-code
      bf_gds-dtl.prod-type     = parprod-type
      bf_gds-dtl.node-code     = parprt-code
   .
end.
end procedure.


&UNDEFINE FRAME-NAME
&UNDEFINE WINDOW-NAME