block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: e-srvsal.p $
$Archive: rep/e-srvsal.p $

Реализация услуг

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/05
Author: Bakhtadze Natalya
Creation date: 09/07/05

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: e-srvsal.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/e-srvsal.p $":U .
define variable vss-description as character no-undo init "Реализация услуг".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ cmp/r-page1.i  }
{ gbl/waitfram.i }
{ gbl/prn-lib.i }
{ rep/rep-bt.i }


&global-define  no-benefits    "Не было никакой реализации услуг на выбранных объектах ~
в течение заданного Вами периода времени."


define buffer cli-obj for clients .
define variable rec-list as char no-undo .
define variable ii as integer no-undo .

define variable sym1 as char init ":"   no-undo.
define variable sym2 as char init ":"   no-undo.
define variable sym3 as char init ":"   no-undo.
define variable sym4 as char init ":"   no-undo.
define variable sym5 as char init ":"   no-undo.
define variable sym6 as char init ":"   no-undo.
define variable sym7 as char init ":"   no-undo.
define variable sym8 as char init ":"   no-undo.

define variable Line as char no-undo.

define variable pcnt as decimal no-undo .

define variable cas-shft as logical no-undo init no.
define variable cas-num as integer no-undo init 0.
define variable date_string as char no-undo.
define variable found as logical no-undo.

define temp-table temp-serv no-undo
field obj-type  as character
field obj-code  as integer
field fact-date as date
field tot-doc   as decimal
field discnt    as decimal
field num-chk   as integer
field fact-qnty as decimal
field netto     as decimal
index pi as unique primary
fact-date obj-type obj-code
index iobj obj-type obj-code
.


define FRAME GoodsRep
sym1 column-label ":!:" format "X(1)"
temp-serv.fact-date column-label "Дата!реализации" format "99/99/9999"
sym2 column-label ":!:" format "X(1)"
temp-serv.fact-qnty column-label "Количество      !единиц" format "->>>,>>>,>>9.<<<"
sym3 column-label ":!:" format "X(1)"
temp-serv.tot-doc column-label "Сумма продажных цен!(в Б.вал.)"
    format "->>>,>>>,>>>,>>>,>>9.99"
sym4 column-label ":!:" format "X(1)"
temp-serv.discnt column-label "Скидка!(в Б.вал.)" format "->>>,>>>,>>>,>>9.99"
sym8 column-label ":!:" format "X(1)"
pcnt column-label "%!скидки" format "->>9.9%"
sym5 column-label ":!:" format "X(1)"
temp-serv.netto column-label "Итого к оплате!(в Б.вал.)"
    format "->>>,>>>,>>>,>>>,>>9.99"
sym6 column-label ":!:" format "X(1)"
temp-serv.num-chk column-label "Количество!чеков" format "->>>,>>>,>>9"
sym7 column-label ":!:" format "X(1)"
HEADER
cur-time-print() AT 5 format "x(35)"
    string( "( Б.вал. - " + caps( trim( base-type ) ) + " )" ) format "X(20)"
    "Страница " AT 110 PAGE-NUMBER( PrnLibStream ) AT 120 FORMAT ">>9" SKIP
Line format "X(132)" AT 1
with width {&A4_CW} down stream-io use-text NO-BOX.

{ rep/e-nobenq.i }

assign
    date_string = cur-time-print()
    Line = fill( "-", 250 ).


run no-benq-i-office in this-procedure ( output found).


if not found then do:
  run waitfram-hide in this-procedure .
  message {&no-benefits} view-as alert-box information .
  return.
end.

run waitfram-show in this-procedure ({&MyWaitMess} ) .
Run ByTemp in this-procedure .


PROCEDURE ByTemp:
define variable accum-tot-doc as decimal no-undo .
define variable accum-discnt as decimal no-undo .
define variable accum-num-chk as decimal no-undo .
define variable accum-fact-qnty as decimal no-undo .
define variable accum-netto as decimal no-undo .
define variable accum-tot-doc-by-date as decimal no-undo .
define variable accum-discnt-by-date as decimal no-undo .
define variable accum-num-chk-by-date as decimal no-undo .
define variable accum-fact-qnty-by-date as decimal no-undo .
define variable accum-netto-by-date as decimal no-undo .
define variable v-curr-r-b as character no-undo .
define variable accum-count as integer no-undo .
define variable num-objs as integer   no-undo .

define buffer buf_Sale-doc for ub.sale-doc.
define buffer buf_trn-doc for ub.trn-doc.
define buffer obj_temp-serv for temp-serv.
define buffer tot_temp-serv for temp-serv.

{ gbl/curr-r-b.i v-curr-r-b }
v-curr-r-b = {&r-b-base}.

run prn-lib-open-stream  in this-procedure (
                                             input my-handle
                                            ,input {&CS_PS}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

FORM HEADER
Line format "X(231)" AT 1 SKIP
"Продолжение - на следующей странице" AT 90 SKIP
with FRAME NBottomFrame width {&DOS_CW_2}
PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW stream PrnLibStream FRAME NBottomFrame .
PUT stream PrnLibStream SPACE(30)
"РЕАЛИЗАЦИЯ  УСЛУГ  " str1 format "x(110)" SKIP(1).
PUT stream PrnLibStream SPACE(30) "По объектам :"
            format "X(130)" SKIP(1).
FOR EACH obj-list :
        FIND cli-obj WHERE cli-obj.obj-type = obj-list.obj-type AND
                                          cli-obj.obj-code = obj-list.obj-code NO-LOCK .
        PUT stream PrnLibStream SPACE(30) cli-obj.obj-name format "X(100)" SKIP.
END.
PUT stream PrnLibStream " " SKIP(1) .

for each temp-serv:
  delete temp-serv.
end.
FOR EACH obj-list ,
  each buf_Sale-doc no-lock where
     buf_sale-doc.obj-type = obj-list.obj-type
 and buf_sale-doc.obj-code = obj-list.obj-code
 and buf_sale-doc.chr-office = {&gds-office}
 and buf_sale-doc.status_ = {&fact},
  first buf_trn-doc no-lock WHERE
    buf_trn-doc.doc-code = buf_sale-doc.doc-code
    /*
 AND buf_trn-doc.obj-type = obj-list.obj-code
 AND buf_trn-doc.obj-code = obj-list.obj-code
 AND buf_trn-doc.internal = no
 AND buf_trn-doc.doc-type = {&expense}
 AND buf_trn-doc.status_ = {&fact}
 AND buf_trn-doc.fact-date >= X-date-Start
 AND buf_trn-doc.fact-date <= X-date-End
 AND buf_trn-doc.office = yes
 AND buf_trn-doc.discnt-type = {&cash-desk} NO-LOCK ,*/

  BREAK
  BY  buf_trn-doc.obj-type
  BY  buf_trn-doc.obj-code
  BY  buf_trn-doc.status_
  BY  buf_trn-doc.fact-date
   :
    if first-of(buf_trn-doc.fact-date) then do:
      assign
      accum-tot-doc-by-date    = 0
      accum-discnt-by-date     = 0
      accum-num-chk-by-date    = 0
      accum-fact-qnty-by-date  = 0
      accum-netto-by-date      = 0
      .
    end.
    if first-of(buf_trn-doc.obj-code) then do:
      assign
      accum-tot-doc    = 0
      accum-discnt     = 0
      accum-num-chk    = 0
      accum-fact-qnty  = 0
      accum-netto      = 0
      .
    end.
    assign
    accum-netto-by-date = accum-netto-by-date +
                          (if v-curr-r-b = {&r-b-rubl}
                          then buf_trn-doc.tot-sale - buf_trn-doc.discnt-rubl
                          else buf_trn-doc.tot-fact - buf_trn-doc.tot-calc) * buf_sale-doc.dir
    accum-netto  = accum-netto +
                          (if v-curr-r-b = {&r-b-rubl}
                          then buf_trn-doc.tot-sale - buf_trn-doc.discnt-rubl
                          else buf_trn-doc.tot-fact - buf_trn-doc.tot-calc) * buf_sale-doc.dir
    accum-tot-doc-by-date = accum-tot-doc-by-date + buf_trn-doc.tot-doc * buf_sale-doc.dir
    accum-tot-doc = accum-tot-doc + buf_trn-doc.tot-doc
    accum-discnt = accum-tot-doc - accum-netto
    accum-discnt-by-date = accum-tot-doc-by-date - accum-netto-by-date
    accum-num-chk = accum-num-chk + buf_sale-doc.chk-amount
    accum-num-chk-by-date = accum-num-chk-by-date + buf_sale-doc.chk-amount
    accum-fact-qnty = accum-fact-qnty + buf_sale-doc.fact-qnty
    accum-fact-qnty-by-date = accum-fact-qnty-by-date + buf_sale-doc.fact-qnty
    .
    PROCESS EVENTS .
    if last-of( buf_trn-doc.fact-date ) then do:
      accum-count = accum-count + 1.
      if accum-count modulo 2  = 0
      AND accum-count >= 2
      then do:
        run waitfram-show in this-procedure ( substitute("Обработано дней : &1" , accum-count)).
      end.
      find first temp-serv where
                temp-serv.fact-date = buf_trn-doc.fact-date
            and temp-serv.obj-type = ''
            and temp-serv.obj-code = 0 no-error.
      if not available temp-serv then do:
        create temp-serv.
        assign
        temp-serv.obj-type   = ''
        temp-serv.obj-code   = 0
        temp-serv.fact-date = buf_trn-doc.fact-date
        temp-serv.tot-doc = temp-serv.tot-doc + accum-tot-doc-by-date
        temp-serv.discnt = temp-serv.discnt + accum-discnt-by-date
        temp-serv.num-chk = temp-serv.num-chk + accum-num-chk-by-date
        temp-serv.fact-qnty = temp-serv.fact-qnty + accum-fact-qnty-by-date
        temp-serv.netto = temp-serv.netto + accum-netto-by-date
        .
        release temp-serv.
      end.
    end.
    if last-of( buf_trn-doc.obj-code ) then do:
      num-objs = num-objs + 1.
      find first temp-serv where
                temp-serv.fact-date = 01/01/1990
            and temp-serv.obj-type = buf_trn-doc.obj-type
            and temp-serv.obj-code = buf_trn-doc.obj-code no-error.
      if not available temp-serv then do:
        create temp-serv.
        assign
        temp-serv.obj-type   = buf_trn-doc.obj-type
        temp-serv.obj-code   = buf_trn-doc.obj-code
        temp-serv.fact-date = 01/01/1990
        temp-serv.tot-doc = temp-serv.tot-doc + accum-tot-doc
        temp-serv.discnt = temp-serv.discnt + accum-discnt
        temp-serv.num-chk = temp-serv.num-chk + accum-num-chk
        temp-serv.fact-qnty = temp-serv.fact-qnty + accum-fact-qnty
        temp-serv.netto = temp-serv.netto + accum-netto
        .
        release temp-serv.
      end.
      find first temp-serv where
                temp-serv.fact-date = 01/01/1990
            and temp-serv.obj-type = ''
            and temp-serv.obj-code = 0 no-error.
      if not available temp-serv then do:
        create temp-serv.
        assign
        temp-serv.obj-type   = ''
        temp-serv.obj-code   = 0
        temp-serv.fact-date = 01/01/1990
        .
      end.
      assign
      temp-serv.tot-doc = temp-serv.tot-doc + accum-tot-doc
      temp-serv.discnt = temp-serv.discnt + accum-discnt
      temp-serv.num-chk = temp-serv.num-chk + accum-num-chk
      temp-serv.fact-qnty = temp-serv.fact-qnty + accum-fact-qnty
      temp-serv.netto = temp-serv.netto + accum-netto
      .
      release temp-serv.
    end.
  end.
  FOR each temp-serv where
          temp-serv.obj-type = ''
      and temp-serv.obj-code = 0
      and temp-serv.fact-date > 01/01/1990
  break
  by temp-serv.fact-date
  with FRAME GoodsRep
  :
    pcnt = round(  temp-serv.discnt /  temp-serv.tot-doc * 100, 1 ) .
    if pcnt = ? then pcnt = 0.
    DISPLAY stream PrnLibStream
    sym1 temp-serv.fact-date
    sym2
    temp-serv.fact-qnty
    sym3
    temp-serv.tot-doc
    sym4
    temp-serv.discnt
    sym8 pcnt    when pcnt <> 0
    sym5 temp-serv.netto
    sym6
    temp-serv.num-chk
    sym7    /* with FRAME GoodsRep. */
    .
    DOWN stream PrnLibStream 1 /* with FRAME GoodsRep. */ .
    if last( temp-serv.fact-date ) then do:
      if num-objs > 1 then do:
        UNDERLINE stream PrnLibStream
        temp-serv.fact-date
        temp-serv.fact-qnty
        temp-serv.tot-doc
        temp-serv.discnt
        pcnt
        temp-serv.netto
        temp-serv.num-chk
        with FRAME GoodsRep
        .

        for each obj_temp-serv where
                obj_temp-serv.fact-date = 01/01/1990
             and obj_temp-serv.obj-type > ''
        by obj_temp-serv.obj-type
        by obj_temp-serv.obj-code:
          pcnt = round( obj_temp-serv.discnt / obj_temp-serv.tot-doc * 100, 1 ) .
          if pcnt = ? then pcnt = 0.
          DISPLAY stream PrnLibStream
          sym1
          sym2 substitute("маг &1", obj_temp-serv.obj-code) @ temp-serv.fact-date
          sym3 obj_temp-serv.fact-qnty @ temp-serv.fact-qnty
          sym4 obj_temp-serv.tot-doc @ temp-serv.tot-doc
          sym5 obj_temp-serv.discnt @ temp-serv.discnt
          sym6 pcnt    when pcnt <> 0
          sym7 obj_temp-serv.netto @ temp-serv.netto
          sym8 obj_temp-serv.num-chk @ temp-serv.num-chk
          with FRAME GoodsRep
          .
          DOWN stream PrnLibStream 1  with FRAME GoodsRep. .
        end.
        UNDERLINE stream PrnLibStream
        temp-serv.fact-date
        temp-serv.fact-qnty
        temp-serv.tot-doc
        temp-serv.discnt
        pcnt
        temp-serv.netto
        temp-serv.num-chk
        with FRAME GoodsRep
        .
      end.
      else do:
        UNDERLINE stream PrnLibStream
        temp-serv.fact-date
        temp-serv.fact-qnty
        temp-serv.tot-doc
        temp-serv.discnt
        pcnt
        temp-serv.netto
        temp-serv.num-chk
        with FRAME GoodsRep
        .

      end.
      find first tot_temp-serv where
                tot_temp-serv.fact-date = 01/01/1990
           and  tot_temp-serv.obj-type = ''
           and  tot_temp-serv.obj-code = 0.
        pcnt = round( tot_temp-serv.discnt / tot_temp-serv.tot-doc * 100, 1 ) .
        if pcnt = ? then pcnt = 0.
        DISPLAY stream PrnLibStream
        sym1 "ИТОГО" @ temp-serv.fact-date
        sym2 tot_temp-serv.fact-qnty @ temp-serv.fact-qnty
        sym3 tot_temp-serv.tot-doc @ temp-serv.tot-doc
        sym4 tot_temp-serv.discnt @ temp-serv.discnt
        sym5 pcnt    when pcnt <> 0
        sym6 tot_temp-serv.netto @ temp-serv.netto
        sym7 tot_temp-serv.num-chk @ temp-serv.num-chk
        sym8
        with FRAME GoodsRep
        .
      end. /*if last( temp-serv.fact-date ) then do:*/
    END. /*  FOR each temp-serv where*/

    HIDE stream PrnLibStream FRAME NBottomFrame .
    run waitfram-hide in this-procedure .
    output stream PrnLibStream CLOSE .
    /*
    assign
    g#rep-tblname = ""
    g#rep-tblrid = -126
    g#rep-updflds = "Реализация услуг " + string(X-date-Start) + ".." + string( X-date-End ) .
    */
    run prn-lib-prn-file in this-procedure (
                                              input my-handle
                                              ,input 0
                                              ).


END PROCEDURE.