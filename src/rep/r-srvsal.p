block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-srvsal.p $
$Archive: rep/r-srvsal.p $

Реализация услуг - выполнение отчета

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/05
Author: Bakhtadze Natalya
Creation date: 09/07/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-date-start as date no-undo .
define input parameter p-date-end as date no-undo .
define input parameter p-select-good as integer no-undo .
define input parameter p-rs-by as integer no-undo .
define input parameter p-tot-objects as logical no-undo .
define input parameter p-report-header as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-srvsal.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-srvsal.p $":U .
define variable vss-description as character no-undo init "Реализация услуг - выполнение отчета".
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


define buffer cli-obj for ub.clients .
define variable rec-list as character no-undo .
define variable ii as integer no-undo .

define variable sym1 as character init ":"   no-undo.
define variable sym2 as character init ":"   no-undo.
define variable sym3 as character init ":"   no-undo.
define variable sym4 as character init ":"   no-undo.
define variable sym5 as character init ":"   no-undo.
define variable sym6 as character init ":"   no-undo.
define variable sym7 as character init ":"   no-undo.
define variable sym8 as character init ":"   no-undo.
define variable sym9 as character init ":"   no-undo.
define variable sym10 as character init ":"   no-undo.
define variable sym11 as character init ":"   no-undo.

define variable Line as character no-undo.

define variable pcnt as decimal no-undo .

define variable cas-shft as logical no-undo init no.
define variable cas-num as integer no-undo init 0.
define variable date_string as character no-undo.
define variable found as logical no-undo.
define variable v-curr-r-b as character no-undo .
define variable accum-count as integer no-undo .
define variable num-objs as integer   no-undo .
define variable v-gds-name as character no-undo .


define temp-table temp-serv no-undo
field gds-code  as integer
field obj-type  as character
field obj-code  as integer
field fact-date as date
field tot-doc   as decimal
field discnt    as decimal
field num-chk   as integer
field fact-qnty as decimal
field netto     as decimal
index pi as unique primary
gds-code fact-date obj-type obj-code
index iobj obj-type obj-code
index idate  fact-date gds-code obj-type obj-code
.
define buffer buf_goods for ub.goods.
define buffer buf_Sale-doc for ub.sale-doc.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer gds_temp-serv for temp-serv.
define buffer gdsobj_temp-serv for temp-serv.
define buffer gdstot_temp-serv for temp-serv.
define buffer obj_temp-serv for temp-serv.
define buffer tot_temp-serv for temp-serv.
define buffer date_temp-serv for temp-serv.
define buffer dateobj_temp-serv for temp-serv.


define FRAME temprep
sym1 column-label ":!:" format "X(1)"
temp-serv.fact-date column-label "Дата!(факт)" format "99/99/9999"
sym11 column-label ":!:" format "X(1)"
temp-serv.obj-code column-label "Маг-н" format ">>>>9"
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
Line format "X(140)" AT 1
with width {&A4_LS} down stream-io use-text NO-BOX.

define FRAME goodsrep
sym1 column-label ":!:" format "X(1)"
temp-serv.gds-code column-label "Код тов." format ">>>>>>>>9"
sym11 column-label ":!:" format "X(1)"
temp-serv.obj-code column-label "Маг-н" format ">>>>9"
sym9 column-label ":!:" format "X(1)"
v-gds-name column-label "Наименование" format "X(43)"
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
Line format "X(190)" AT 1
with width {&A4_LS} down stream-io use-text NO-BOX.

define FRAME goodsdaterep
sym1 column-label ":!:" format "X(1)"
temp-serv.fact-date column-label "Дата!(факт)" format "99/99/9999"
sym11 column-label ":!:" format "X(1)"
temp-serv.obj-code column-label "Маг-н" format ">>>>9"
sym10 column-label ":!:" format "X(1)"
temp-serv.gds-code column-label "Код тов." format ">>>>>>>>9"
sym9 column-label ":!:" format "X(1)"
v-gds-name column-label "Код наименование" format "X(43)"
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
Line format "X(190)" AT 1
with width {&A4_LS} down stream-io use-text NO-BOX.

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
{ gbl/curr-r-b.i v-curr-r-b }
v-curr-r-b = {&r-b-base}.

for each temp-serv:
  delete temp-serv.
end.
create tot_temp-serv.
assign
tot_temp-serv.gds-code = 0
tot_temp-serv.fact-date = 01/01/1990
tot_temp-serv.obj-type  = ''
tot_temp-serv.obj-code  = 0
.
FOR EACH obj-list ,
  each buf_Sale-doc no-lock where
     buf_sale-doc.obj-type = obj-list.obj-type
 and buf_sale-doc.obj-code = obj-list.obj-code
 and buf_sale-doc.chr-office = {&gds-office}
 and buf_sale-doc.status_ = {&fact}
 and buf_sale-doc.doc-date >= X-date-start
 and buf_sale-doc.doc-date <= X-date-end
 ,
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
    if p-tot-objects
    and (p-rs-by = 0 or p-rs-by = 2)
    then do:
      find first dateobj_temp-serv where
                dateobj_temp-serv.gds-code = 0
            and dateobj_temp-serv.fact-date = buf_trn-doc.fact-date
            and dateobj_temp-serv.obj-type  = buf_trn-doc.obj-type
            and dateobj_temp-serv.obj-code  = buf_trn-doc.obj-code no-error.
      if not available dateobj_temp-serv then do:
        create dateobj_temp-serv.
        assign
        dateobj_temp-serv.gds-code = 0
        dateobj_temp-serv.fact-date = buf_trn-doc.fact-date
        dateobj_temp-serv.obj-type  = buf_trn-doc.obj-type
        dateobj_temp-serv.obj-code  = buf_trn-doc.obj-code
        .
      end.
    end.
    if not p-tot-objects
    and (p-rs-by = 0 or p-rs-by = 2)
    then do:
      find first date_temp-serv where
                date_temp-serv.gds-code = 0
            and date_temp-serv.fact-date = buf_trn-doc.fact-date
            and date_temp-serv.obj-type  = ''
            and date_temp-serv.obj-code  = 0 no-error.
      if not available date_temp-serv then do:
        create date_temp-serv.
        assign
        date_temp-serv.gds-code = 0
        date_temp-serv.fact-date = buf_trn-doc.fact-date
        date_temp-serv.obj-type  = ''
        date_temp-serv.obj-code  = 0
        .
      end.
    end.
  end.
  if first-of(buf_trn-doc.obj-code) then do:
    find first obj_temp-serv where
              obj_temp-serv.gds-code = 0
          and obj_temp-serv.fact-date = 01/01/1990
          and obj_temp-serv.obj-type  = buf_trn-doc.obj-type
          and obj_temp-serv.obj-code  = buf_trn-doc.obj-code no-error.
    if not available obj_temp-serv then do:
      create obj_temp-serv.
      assign
      obj_temp-serv.gds-code = 0
      obj_temp-serv.fact-date = 01/01/1990
      obj_temp-serv.obj-type  = buf_trn-doc.obj-type
      obj_temp-serv.obj-code  = buf_trn-doc.obj-code
      .
    end.
  end.
  if p-tot-objects
  and (p-rs-by = 0 or p-rs-by = 2)
  then do:
    assign
    dateobj_temp-serv.tot-doc   = dateobj_temp-serv.tot-doc + buf_trn-doc.tot-doc * buf_sale-doc.dir
    dateobj_temp-serv.netto     = dateobj_temp-serv.netto   +
                          (if v-curr-r-b = {&r-b-rubl}
                          then buf_trn-doc.tot-sale - buf_trn-doc.discnt-rubl
                          else buf_trn-doc.tot-fact - buf_trn-doc.tot-calc) * buf_sale-doc.dir
    dateobj_temp-serv.discnt    = dateobj_temp-serv.tot-doc - dateobj_temp-serv.netto
    dateobj_temp-serv.num-chk   = dateobj_temp-serv.num-chk + buf_sale-doc.chk-amount
    dateobj_temp-serv.fact-qnty = dateobj_temp-serv.fact-qnty + buf_sale-doc.fact-qnty
    .
  end.
  if not p-tot-objects
  and (p-rs-by = 0 or p-rs-by = 2)
  then do:
    assign
    date_temp-serv.tot-doc   = date_temp-serv.tot-doc + buf_trn-doc.tot-doc * buf_sale-doc.dir
    date_temp-serv.netto     = date_temp-serv.netto   +
                          (if v-curr-r-b = {&r-b-rubl}
                          then buf_trn-doc.tot-sale - buf_trn-doc.discnt-rubl
                          else buf_trn-doc.tot-fact - buf_trn-doc.tot-calc) * buf_sale-doc.dir
    date_temp-serv.discnt    = date_temp-serv.tot-doc - date_temp-serv.netto
    date_temp-serv.num-chk   = date_temp-serv.num-chk + buf_sale-doc.chk-amount
    date_temp-serv.fact-qnty = date_temp-serv.fact-qnty + buf_sale-doc.fact-qnty
    .
  end.
  assign
  obj_temp-serv.tot-doc   = obj_temp-serv.tot-doc + buf_trn-doc.tot-doc * buf_sale-doc.dir
  obj_temp-serv.netto     = obj_temp-serv.netto   +
                        (if v-curr-r-b = {&r-b-rubl}
                        then buf_trn-doc.tot-sale - buf_trn-doc.discnt-rubl
                        else buf_trn-doc.tot-fact - buf_trn-doc.tot-calc) * buf_sale-doc.dir
  obj_temp-serv.discnt    = obj_temp-serv.tot-doc - obj_temp-serv.netto
  obj_temp-serv.num-chk   = obj_temp-serv.num-chk + buf_sale-doc.chk-amount
  obj_temp-serv.fact-qnty = obj_temp-serv.fact-qnty + buf_sale-doc.fact-qnty
  tot_temp-serv.tot-doc   = tot_temp-serv.tot-doc + buf_trn-doc.tot-doc * buf_sale-doc.dir
  tot_temp-serv.netto     = tot_temp-serv.netto   +
                        (if v-curr-r-b = {&r-b-rubl}
                        then buf_trn-doc.tot-sale - buf_trn-doc.discnt-rubl
                        else buf_trn-doc.tot-fact - buf_trn-doc.tot-calc) * buf_sale-doc.dir
  tot_temp-serv.discnt    = tot_temp-serv.tot-doc - tot_temp-serv.netto
  tot_temp-serv.num-chk   = tot_temp-serv.num-chk + buf_sale-doc.chk-amount
  tot_temp-serv.fact-qnty = tot_temp-serv.fact-qnty + buf_sale-doc.fact-qnty
  .
  PROCESS EVENTS .
  if p-rs-by > 0 then do:
    /*нужны товары*/
    _goods:
    for each buf_gds-dtl no-lock where
            buf_gds-dtl.doc-code = buf_trn-doc.doc-code,
        first buf_goods no-lock where
              buf_goods.artic = buf_gds-dtl.artic
          and buf_goods.prod-type = buf_gds-dtl.prod-type
          and buf_goods.prod-code = buf_gds-dtl.prod-code:
      case p-select-good :
        when {&g-prod} then do:
          FIND FIRST g#cli WHERE
                      g#cli.obj-type = buf_goods.prod-type
                  AND g#cli.obj-code = buf_goods.prod-code NO-LOCK NO-ERROR.
          if not available g#cli then do:
            next _goods.
          end.
        end.
        when  {&g-choice} then do:
          find first gds-list where
                    gds-list.gds-code = buf_goods.gds-code no-error.
          if not available gds-list then do:
            next _goods.
          end.
        end.
        when {&g-all} then do:
          /*ничего не надо*/
        end.
      end case.
      if not p-tot-objects
      then do:
        if p-rs-by = 2 then do:
          find first gds_temp-serv where
                    gds_temp-serv.gds-code = buf_goods.gds-code
                and gds_temp-serv.fact-date = buf_trn-doc.fact-date
                and gds_temp-serv.obj-type  = ""
                and gds_temp-serv.obj-code  = 0 no-error.
          if not available gds_temp-serv then do:
            create gds_temp-serv.
            assign
            gds_temp-serv.gds-code = buf_goods.gds-code
            gds_temp-serv.fact-date = buf_trn-doc.fact-date
            gds_temp-serv.obj-type  = ""
            gds_temp-serv.obj-code  = 0
            .
          end.
          assign
          gds_temp-serv.tot-doc   = gds_temp-serv.tot-doc + (if v-curr-r-b = {&r-b-base}
                                                            then buf_gds-dtl.price-base
                                                            else buf_gds-dtl.price-rubl)
                                                            * buf_gds-dtl.fact-qnty * buf_sale-doc.dir
          gds_temp-serv.netto     = gds_temp-serv.netto   + (if v-curr-r-b = {&r-b-base}
                                                            then (buf_gds-dtl.price-base - buf_gds-dtl.discnt-base)
                                                            else (buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl)
                                                            )
                                                            * buf_gds-dtl.fact-qnty * buf_sale-doc.dir
          gds_temp-serv.discnt    = gds_temp-serv.tot-doc - gds_temp-serv.netto
          gds_temp-serv.fact-qnty = gds_temp-serv.fact-qnty + buf_gds-dtl.fact-qnty
          .
        end.
      end.
      else do:
        if p-rs-by = 1 then do:
          find first gdsobj_temp-serv where
                    gdsobj_temp-serv.gds-code = buf_goods.gds-code
                and gdsobj_temp-serv.fact-date = 01/01/1990
                and gdsobj_temp-serv.obj-type  = buf_trn-doc.obj-type
                and gdsobj_temp-serv.obj-code  = buf_trn-doc.obj-code no-error.
          if not available gdsobj_temp-serv then do:
            create gdsobj_temp-serv.
            assign
            gdsobj_temp-serv.gds-code = buf_goods.gds-code
            gdsobj_temp-serv.fact-date = 01/01/1990
            gdsobj_temp-serv.obj-type  = buf_trn-doc.obj-type
            gdsobj_temp-serv.obj-code  = buf_trn-doc.obj-code
            .
          end.
          assign
          gdsobj_temp-serv.tot-doc   = gdsobj_temp-serv.tot-doc + (if v-curr-r-b = {&r-b-base}
                                                            then buf_gds-dtl.price-base
                                                            else buf_gds-dtl.price-rubl)
                                                            * buf_gds-dtl.fact-qnty * buf_sale-doc.dir
          gdsobj_temp-serv.netto     = gdsobj_temp-serv.netto   + (if v-curr-r-b = {&r-b-base}
                                                            then (buf_gds-dtl.price-base - buf_gds-dtl.discnt-base)
                                                            else (buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl)
                                                            )
                                                            * buf_gds-dtl.fact-qnty * buf_sale-doc.dir
          gdsobj_temp-serv.discnt    = gdsobj_temp-serv.tot-doc - gdsobj_temp-serv.netto
          gdsobj_temp-serv.fact-qnty = gdsobj_temp-serv.fact-qnty + buf_gds-dtl.fact-qnty
          .
        end.
      end.
      find first gdstot_temp-serv where
                gdstot_temp-serv.gds-code = buf_goods.gds-code
            and gdstot_temp-serv.fact-date = 01/01/1990
            and gdstot_temp-serv.obj-type  = ""
            and gdstot_temp-serv.obj-code  = 0 no-error.
      if not available gdstot_temp-serv then do:
        create gdstot_temp-serv.
        assign
        gdstot_temp-serv.gds-code = buf_goods.gds-code
        gdstot_temp-serv.fact-date = 01/01/1990
        gdstot_temp-serv.obj-type  = ""
        gdstot_temp-serv.obj-code  = 0
        .
      end.
      assign
      gdstot_temp-serv.tot-doc   = gdstot_temp-serv.tot-doc + (if v-curr-r-b = {&r-b-base}
                                                        then buf_gds-dtl.price-base
                                                        else buf_gds-dtl.price-rubl)
                                                        * buf_gds-dtl.fact-qnty * buf_sale-doc.dir
      gdstot_temp-serv.netto     = gdstot_temp-serv.netto   + (if v-curr-r-b = {&r-b-base}
                                                        then (buf_gds-dtl.price-base - buf_gds-dtl.discnt-base)
                                                        else (buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl)
                                                        )
                                                        * buf_gds-dtl.fact-qnty * buf_sale-doc.dir
      gdstot_temp-serv.discnt    = gdstot_temp-serv.tot-doc - gdstot_temp-serv.netto
      gdstot_temp-serv.fact-qnty = gdstot_temp-serv.fact-qnty + buf_gds-dtl.fact-qnty
      .
    end. /*    for each buf_gds-dtl no-lock where*/
  end. /*if p-rs-by > 0 then do:*/
  if last-of( buf_trn-doc.fact-date ) then do:
    accum-count = accum-count + 1.
    if accum-count modulo 2  = 0
    AND accum-count >= 2
    then do:
      run waitfram-show in this-procedure ( substitute("Обработано дней : &1" , accum-count)).
    end.
  end.
  if last-of( buf_trn-doc.obj-code ) then do:
    num-objs = num-objs + 1.
  end.
end.

if p-rs-by = 0 then do:
  /*по датам*/
  if p-tot-objects then do:
    Run ByTempObj in this-procedure .
  end.
  else do:
    Run ByTemp in this-procedure .
  end.
end.
if p-rs-by = 1 then do:
  /*по товарам*/
  if p-tot-objects then do:
    Run ByGoodsObj in this-procedure .
  end.
  else do:
    Run ByGoods in this-procedure .
  end.
end.
if p-rs-by = 2 then do:
  /*по датам и товарам*/
  if p-tot-objects then do:
    Run ByGoodsDateObj in this-procedure .
  end.
  else do:
    Run ByGoodsDate in this-procedure .
  end.

end.


PROCEDURE ByTemp:
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
put stream prnlibstream unformatted str2 skip(0).
PUT stream PrnLibStream SPACE(30) "По объектам :"
            format "X(130)" SKIP(1).
FOR EACH obj-list :
        FIND cli-obj WHERE cli-obj.obj-type = obj-list.obj-type AND
                                          cli-obj.obj-code = obj-list.obj-code NO-LOCK .
        PUT stream PrnLibStream SPACE(30) cli-obj.obj-name format "X(100)" SKIP.
END.
Put stream Prnlibstream unformatted p-report-header skip.
PUT stream PrnLibStream " " SKIP(1) .

FOR each date_temp-serv where
        date_temp-serv.gds-code = 0
    and date_temp-serv.obj-type = ''
    and date_temp-serv.obj-code = 0
    and date_temp-serv.fact-date > 01/01/1990
break
by date_temp-serv.fact-date
with FRAME temprep
:
  pcnt = round(  date_temp-serv.discnt /  date_temp-serv.tot-doc * 100, 1 ) .
  if pcnt = ? then pcnt = 0.
  DISPLAY stream PrnLibStream
  sym1 date_temp-serv.fact-date @ temp-serv.fact-date
  sym11
  sym2
  date_temp-serv.fact-qnty @ temp-serv.fact-qnty
  sym3
  date_temp-serv.tot-doc @ temp-serv.tot-doc
  sym4
  date_temp-serv.discnt @ temp-serv.discnt
  sym8 pcnt    when pcnt <> 0
  sym5 date_temp-serv.netto @ temp-serv.netto
  sym6
  date_temp-serv.num-chk @ temp-serv.num-chk
  sym7     with FRAME temprep.
  .
  DOWN stream PrnLibStream 1  with FRAME temprep.
  if last( date_temp-serv.fact-date ) then do:
    if num-objs > 1 then do:
      UNDERLINE stream PrnLibStream
      temp-serv.obj-code
      temp-serv.fact-date
      temp-serv.fact-qnty
      temp-serv.tot-doc
      temp-serv.discnt
      pcnt
      temp-serv.netto
      temp-serv.num-chk
      with FRAME temprep
      .

      for each obj_temp-serv where
              obj_temp-serv.fact-date = 01/01/1990
            and obj_temp-serv.obj-type > ''
            and obj_temp-serv.gds-code = 0
      by obj_temp-serv.obj-type
      by obj_temp-serv.obj-code:
        pcnt = round( obj_temp-serv.discnt / obj_temp-serv.tot-doc * 100, 1 ) .
        if pcnt = ? then pcnt = 0.
        DISPLAY stream PrnLibStream
        sym1  "по маг" @ temp-serv.fact-date
        sym11 obj_temp-serv.obj-code @ temp-serv.obj-code
        sym2
        sym3 obj_temp-serv.fact-qnty @ temp-serv.fact-qnty
        sym4 obj_temp-serv.tot-doc @ temp-serv.tot-doc
        sym5 obj_temp-serv.discnt @ temp-serv.discnt
        sym6 pcnt    when pcnt <> 0
        sym7 obj_temp-serv.netto @ temp-serv.netto
        sym8 obj_temp-serv.num-chk @ temp-serv.num-chk
        with FRAME temprep
        .
        DOWN stream PrnLibStream 1  with FRAME temprep. .
      end.
    end.
    UNDERLINE stream PrnLibStream
    temp-serv.obj-code
    temp-serv.fact-date
    temp-serv.fact-qnty
    temp-serv.tot-doc
    temp-serv.discnt
    pcnt
    temp-serv.netto
    temp-serv.num-chk
    with FRAME temprep
    .
    find first tot_temp-serv where
              tot_temp-serv.fact-date = 01/01/1990
          and  tot_temp-serv.obj-type = ''
          and  tot_temp-serv.obj-code = 0
          and  tot_temp-serv.gds-code = 0
          .
    pcnt = round( tot_temp-serv.discnt / tot_temp-serv.tot-doc * 100, 1 ) .
    if pcnt = ? then pcnt = 0.
    DISPLAY stream PrnLibStream
    sym1 "ИТОГО" @ temp-serv.fact-date
    sym11
    sym2 tot_temp-serv.fact-qnty @ temp-serv.fact-qnty
    sym3 tot_temp-serv.tot-doc @ temp-serv.tot-doc
    sym4 tot_temp-serv.discnt @ temp-serv.discnt
    sym5 pcnt    when pcnt <> 0
    sym6 tot_temp-serv.netto @ temp-serv.netto
    sym7 tot_temp-serv.num-chk @ temp-serv.num-chk
    sym8
    with FRAME temprep
    .
  end. /*if last( temp-serv.fact-date ) then do:*/
END. /*  FOR each temp-serv where*/

HIDE stream PrnLibStream FRAME NBottomFrame .
run waitfram-hide in this-procedure .
output stream PrnLibStream CLOSE .
run prn-lib-prn-file in this-procedure (
                                          input my-handle
                                          ,input 0
                                          ).


END PROCEDURE. /*PROCEDURE ByTemp:*/

PROCEDURE ByTempObj:
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
put stream prnlibstream unformatted str2 skip(0).
PUT stream PrnLibStream SPACE(30) "По объектам :"
            format "X(130)" SKIP(1).
FOR EACH obj-list :
        FIND cli-obj WHERE cli-obj.obj-type = obj-list.obj-type AND
                                          cli-obj.obj-code = obj-list.obj-code NO-LOCK .
        PUT stream PrnLibStream SPACE(30) cli-obj.obj-name format "X(100)" SKIP.
END.
Put stream Prnlibstream unformatted p-report-header skip.
PUT stream PrnLibStream " " SKIP(1) .

FOR EACH obj-list :
  FOR each dateobj_temp-serv where
          dateobj_temp-serv.gds-code = 0
      and dateobj_temp-serv.obj-type = obj-list.obj-type
      and dateobj_temp-serv.obj-code = obj-list.obj-code
      and dateobj_temp-serv.fact-date > 01/01/1990
  break
  by dateobj_temp-serv.fact-date
  with FRAME temprep
  :
    pcnt = round(  dateobj_temp-serv.discnt /  dateobj_temp-serv.tot-doc * 100, 1 ) .
    if pcnt = ? then pcnt = 0.
    DISPLAY stream PrnLibStream
    sym1 dateobj_temp-serv.fact-date @ temp-serv.fact-date
    sym11 dateobj_temp-serv.obj-code @ temp-serv.obj-code
    sym2
    dateobj_temp-serv.fact-qnty @ temp-serv.fact-qnty
    sym3
    dateobj_temp-serv.tot-doc @ temp-serv.tot-doc
    sym4
    dateobj_temp-serv.discnt @ temp-serv.discnt
    sym8 pcnt    when pcnt <> 0
    sym5 dateobj_temp-serv.netto @ temp-serv.netto
    sym6
    dateobj_temp-serv.num-chk @ temp-serv.num-chk
    sym7     with FRAME temprep.
    .
    DOWN stream PrnLibStream 1 with FRAME temprep.
    if last(dateobj_temp-serv.fact-date) then do:
      UNDERLINE stream PrnLibStream
      temp-serv.obj-code
      temp-serv.fact-date
      temp-serv.fact-qnty
      temp-serv.tot-doc
      temp-serv.discnt
      pcnt
      temp-serv.netto
      temp-serv.num-chk
      with FRAME temprep
      .
    end.
  end. /*FOR each dateobj_temp-serv where*/
  find first obj_temp-serv where
          obj_temp-serv.gds-code = 0
        and obj_temp-serv.fact-date = 01/01/1990
        and obj_temp-serv.obj-type = obj-list.obj-type
        and obj_temp-serv.obj-code = obj-list.obj-code no-error.
  if not available obj_temp-serv then do:
   create obj_temp-serv.
   assign
   obj_temp-serv.gds-code = 0
   obj_temp-serv.fact-date = 01/01/1990
   obj_temp-serv.obj-type = obj-list.obj-type
   obj_temp-serv.obj-code = obj-list.obj-code
   .
  end.
  pcnt = round( obj_temp-serv.discnt / obj_temp-serv.tot-doc * 100, 1 ) .
  if pcnt = ? then pcnt = 0.
  DISPLAY stream PrnLibStream
  sym1 "по маг" @ temp-serv.fact-date
  sym11 obj_temp-serv.obj-code @ temp-serv.obj-code
  sym2
  sym3 obj_temp-serv.fact-qnty @ temp-serv.fact-qnty
  sym4 obj_temp-serv.tot-doc @ temp-serv.tot-doc
  sym5 obj_temp-serv.discnt @ temp-serv.discnt
  sym6 pcnt    when pcnt <> 0
  sym7 obj_temp-serv.netto @ temp-serv.netto
  sym8 obj_temp-serv.num-chk @ temp-serv.num-chk
  with FRAME temprep
  .
  DOWN stream PrnLibStream 1  with FRAME temprep. .

  UNDERLINE stream PrnLibStream
  temp-serv.obj-code
  temp-serv.fact-date
  temp-serv.fact-qnty
  temp-serv.tot-doc
  temp-serv.discnt
  pcnt
  temp-serv.netto
  temp-serv.num-chk
  with FRAME temprep
  .
END. /*  FOR each obj-list*/
find first tot_temp-serv where
          tot_temp-serv.fact-date = 01/01/1990
      and  tot_temp-serv.obj-type = ''
      and  tot_temp-serv.obj-code = 0
      and  tot_temp-serv.gds-code = 0
      .
pcnt = round( tot_temp-serv.discnt / tot_temp-serv.tot-doc * 100, 1 ) .
if pcnt = ? then pcnt = 0.
DISPLAY stream PrnLibStream
sym1 "ИТОГО" @ temp-serv.fact-date
sym11
sym2 tot_temp-serv.fact-qnty @ temp-serv.fact-qnty
sym3 tot_temp-serv.tot-doc @ temp-serv.tot-doc
sym4 tot_temp-serv.discnt @ temp-serv.discnt
sym5 pcnt    when pcnt <> 0
sym6 tot_temp-serv.netto @ temp-serv.netto
sym7 tot_temp-serv.num-chk @ temp-serv.num-chk
sym8
with FRAME temprep
.
HIDE stream PrnLibStream FRAME NBottomFrame .
run waitfram-hide in this-procedure .
output stream PrnLibStream CLOSE .
run prn-lib-prn-file in this-procedure (
                                          input my-handle
                                          ,input 0
                                          ).


END PROCEDURE. /*PROCEDURE ByTempObj:*/


PROCEDURE ByGoods:
run prn-lib-open-stream  in this-procedure (
                                             input my-handle
                                            ,input {&LS_PS_A4}
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
put stream prnlibstream unformatted str2 skip(0).
PUT stream PrnLibStream SPACE(30) "По объектам :"
            format "X(198)" SKIP(1).
FOR EACH obj-list :
        FIND cli-obj WHERE cli-obj.obj-type = obj-list.obj-type AND
                                          cli-obj.obj-code = obj-list.obj-code NO-LOCK .
        PUT stream PrnLibStream SPACE(30) cli-obj.obj-name format "X(100)" SKIP.
END.
Put stream Prnlibstream unformatted p-report-header skip.
PUT stream PrnLibStream " " SKIP(1) .

FOR each gdstot_temp-serv where
        gdstot_temp-serv.fact-date = 01/01/1990
    and gdstot_temp-serv.obj-type = ''
    and gdstot_temp-serv.obj-code = 0
    and gdstot_temp-serv.gds-code > 0
break
by gdstot_temp-serv.gds-code
with FRAME GoodsRep
:
  pcnt = round(  gdstot_temp-serv.discnt /  gdstot_temp-serv.tot-doc * 100, 1 ) .
  if pcnt = ? then pcnt = 0.
  find first buf_goods no-lock where
            buf_goods.gds-code = gdstot_temp-serv.gds-code no-error.
  DISPLAY stream PrnLibStream
  sym1 gdstot_temp-serv.gds-code @ temp-serv.gds-code
  sym11
  sym2
  (if available buf_goods then buf_goods.gds-name else '') @ v-gds-name
  sym9
  gdstot_temp-serv.fact-qnty @ temp-serv.fact-qnty
  sym3
  gdstot_temp-serv.tot-doc @ temp-serv.tot-doc
  sym4
  gdstot_temp-serv.discnt @ temp-serv.discnt
  sym8 pcnt    when pcnt <> 0
  sym5 gdstot_temp-serv.netto @ temp-serv.netto
  sym6
  sym8
  sym7     with FRAME GoodsRep.
  .
  DOWN stream PrnLibStream 1  with FRAME GoodsRep.
  if last( gdstot_temp-serv.gds-code ) then do:
    if num-objs > 1 then do:
      UNDERLINE stream PrnLibStream
      temp-serv.obj-code
      temp-serv.gds-code
      v-gds-name
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
            and obj_temp-serv.gds-code = 0
      by obj_temp-serv.obj-type
      by obj_temp-serv.obj-code:
        pcnt = round( obj_temp-serv.discnt / obj_temp-serv.tot-doc * 100, 1 ) .
        if pcnt = ? then pcnt = 0.
        DISPLAY stream PrnLibStream
        sym1 "по маг" @ temp-serv.gds-code
        sym11 obj_temp-serv.obj-code @ temp-serv.obj-code
        sym2
        sym9
        sym3 obj_temp-serv.fact-qnty @ temp-serv.fact-qnty
        sym4 obj_temp-serv.tot-doc @ temp-serv.tot-doc
        sym5 obj_temp-serv.discnt @ temp-serv.discnt
        sym6 pcnt    when pcnt <> 0
        sym7 obj_temp-serv.netto @ temp-serv.netto
        sym8 obj_temp-serv.num-chk @ temp-serv.num-chk
        with FRAME GoodsRep
        .
        DOWN stream PrnLibStream 1  with FRAME GoodsRep.
      end.
    end.
    UNDERLINE stream PrnLibStream
    temp-serv.obj-code
    temp-serv.gds-code
    v-gds-name
    temp-serv.fact-qnty
    temp-serv.tot-doc
    temp-serv.discnt
    pcnt
    temp-serv.netto
    temp-serv.num-chk
    with FRAME GoodsRep
    .
    find first tot_temp-serv where
              tot_temp-serv.fact-date = 01/01/1990
          and  tot_temp-serv.obj-type = ''
          and  tot_temp-serv.obj-code = 0
          and  tot_temp-serv.gds-code = 0
          .
    pcnt = round( tot_temp-serv.discnt / tot_temp-serv.tot-doc * 100, 1 ) .
    if pcnt = ? then pcnt = 0.
    DISPLAY stream PrnLibStream
    sym1  "ИТОГО" @ temp-serv.gds-code
    sym11
    sym9
    sym2 tot_temp-serv.fact-qnty @ temp-serv.fact-qnty
    sym3 tot_temp-serv.tot-doc @ temp-serv.tot-doc
    sym4 tot_temp-serv.discnt @ temp-serv.discnt
    sym5 pcnt    when pcnt <> 0
    sym6 tot_temp-serv.netto @ temp-serv.netto
    sym7 tot_temp-serv.num-chk @ temp-serv.num-chk
    sym8
    with FRAME GoodsRep
    .
  end. /*if last( gdstot_temp-serv.gds-code ) then do:*/
END. /*  FOR each gdstot_temp-serv where*/

HIDE stream PrnLibStream FRAME NBottomFrame .
run waitfram-hide in this-procedure .
output stream PrnLibStream CLOSE .
run prn-lib-prn-file in this-procedure (
                                          input my-handle
                                          ,input 0
                                          ).


END PROCEDURE. /**PROCEDURE ByGoods:*/

PROCEDURE ByGoodsObj:
run prn-lib-open-stream  in this-procedure (
                                             input my-handle
                                            ,input {&LS_PS_A4}
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
put stream prnlibstream unformatted str2 skip(0).
PUT stream PrnLibStream SPACE(30) "По объектам :"
            format "X(198)" SKIP(1).
FOR EACH obj-list :
        FIND cli-obj WHERE cli-obj.obj-type = obj-list.obj-type AND
                                          cli-obj.obj-code = obj-list.obj-code NO-LOCK .
        PUT stream PrnLibStream SPACE(30) cli-obj.obj-name format "X(100)" SKIP.
END.
Put stream Prnlibstream unformatted p-report-header skip.
PUT stream PrnLibStream " " SKIP(1) .

for each obj-list :
  FOR each gdsobj_temp-serv where
          gdsobj_temp-serv.fact-date = 01/01/1990
      and gdsobj_temp-serv.obj-type = obj-list.obj-type
      and gdsobj_temp-serv.obj-code = obj-list.obj-code
      and gdsobj_temp-serv.gds-code > 0
  break
  by gdsobj_temp-serv.gds-code
  with FRAME GoodsRep
  :
    pcnt = round(  gdsobj_temp-serv.discnt /  gdsobj_temp-serv.tot-doc * 100, 1 ) .
    if pcnt = ? then pcnt = 0.
    find first buf_goods no-lock where
              buf_goods.gds-code = gdsobj_temp-serv.gds-code no-error.
    DISPLAY stream PrnLibStream
    sym1 gdsobj_temp-serv.gds-code @ temp-serv.gds-code
    sym11 gdsobj_temp-serv.obj-code @ temp-serv.obj-code
    sym2
    (if available buf_goods then buf_goods.gds-name else '') @ v-gds-name
    sym9
    gdsobj_temp-serv.fact-qnty @ temp-serv.fact-qnty
    sym3
    gdsobj_temp-serv.tot-doc @ temp-serv.tot-doc
    sym4
    gdsobj_temp-serv.discnt @ temp-serv.discnt
    sym8 pcnt    when pcnt <> 0
    sym5 gdsobj_temp-serv.netto @ temp-serv.netto
    sym6
    sym7    /* with FRAME GoodsRep. */
    .
    DOWN stream PrnLibStream 1 /* with FRAME GoodsRep. */ .
  end. /*  FOR each gds_temp-serv where*/
  UNDERLINE stream PrnLibStream
  temp-serv.obj-code
  temp-serv.gds-code
  v-gds-name
  temp-serv.fact-qnty
  temp-serv.tot-doc
  temp-serv.discnt
  pcnt
  temp-serv.netto
  temp-serv.num-chk
  with FRAME GoodsRep
  .
  find first obj_temp-serv where
          obj_temp-serv.fact-date = 01/01/1990
        and obj_temp-serv.obj-type = obj-list.obj-type
        and obj_temp-serv.obj-code = obj-list.obj-code
        and obj_temp-serv.gds-code = 0 no-error.
  if not available obj_temp-serv then do:
    create obj_temp-serv.
    assign
    obj_temp-serv.fact-date = 01/01/1990
    obj_temp-serv.obj-type = obj-list.obj-type
    obj_temp-serv.obj-code = obj-list.obj-code
    obj_temp-serv.gds-code = 0
    .
  end.
  pcnt = round( obj_temp-serv.discnt / obj_temp-serv.tot-doc * 100, 1 ) .
  if pcnt = ? then pcnt = 0.
  DISPLAY stream PrnLibStream
  sym1 "по маг" @ temp-serv.gds-code
  sym11 obj_temp-serv.obj-code @ temp-serv.obj-code
  sym2
  sym9
  sym3 obj_temp-serv.fact-qnty @ temp-serv.fact-qnty
  sym4 obj_temp-serv.tot-doc @ temp-serv.tot-doc
  sym5 obj_temp-serv.discnt @ temp-serv.discnt
  sym6 pcnt    when pcnt <> 0
  sym7 obj_temp-serv.netto @ temp-serv.netto
  sym8 obj_temp-serv.num-chk @ temp-serv.num-chk
  with FRAME GoodsRep
  .
  DOWN stream PrnLibStream 1  with FRAME GoodsRep. .
  UNDERLINE stream PrnLibStream
  temp-serv.obj-code
  temp-serv.gds-code
  v-gds-name
  temp-serv.fact-qnty
  temp-serv.tot-doc
  temp-serv.discnt
  pcnt
  temp-serv.netto
  temp-serv.num-chk
  with FRAME GoodsRep
  .
end. /*for eac obj-list*/
/*итоги по наименованиям*/
for each gdstot_temp-serv where
        gdstot_temp-serv.fact-date = 01/01/1990
    and gdstot_temp-serv.obj-type = ''
    and gdstot_temp-serv.obj-code = 0
    and gdstot_temp-serv.gds-code > 0 :
  pcnt = round( gdstot_temp-serv.discnt / gdstot_temp-serv.tot-doc * 100, 1 ) .
  if pcnt = ? then pcnt = 0.
  find first buf_goods no-lock where
            buf_goods.gds-code = gdstot_temp-serv.gds-code no-error.
  DISPLAY stream PrnLibStream
  sym1 gdstot_temp-serv.gds-code @ temp-serv.gds-code
  sym11
  sym2
  sym9 (if available buf_goods then buf_goods.gds-name else '') @ v-gds-name
  sym3 gdstot_temp-serv.fact-qnty @ temp-serv.fact-qnty
  sym4 gdstot_temp-serv.tot-doc @ temp-serv.tot-doc
  sym5 gdstot_temp-serv.discnt @ temp-serv.discnt
  sym6 pcnt    when pcnt <> 0
  sym7 gdstot_temp-serv.netto @ temp-serv.netto
  sym8
  with FRAME GoodsRep
  .
  DOWN stream PrnLibStream 1  with FRAME GoodsRep. .
end.
UNDERLINE stream PrnLibStream
temp-serv.obj-code
temp-serv.gds-code
v-gds-name
temp-serv.fact-qnty
temp-serv.tot-doc
temp-serv.discnt
pcnt
temp-serv.netto
temp-serv.num-chk
with FRAME GoodsRep
.
find first tot_temp-serv where
          tot_temp-serv.fact-date = 01/01/1990
      and  tot_temp-serv.obj-type = ''
      and  tot_temp-serv.obj-code = 0
      and  tot_temp-serv.gds-code = 0
      .
pcnt = round( tot_temp-serv.discnt / tot_temp-serv.tot-doc * 100, 1 ) .
if pcnt = ? then pcnt = 0.
DISPLAY stream PrnLibStream
sym1  "ИТОГО" @ temp-serv.gds-code
sym11
sym9
sym2 tot_temp-serv.fact-qnty @ temp-serv.fact-qnty
sym3 tot_temp-serv.tot-doc @ temp-serv.tot-doc
sym4 tot_temp-serv.discnt @ temp-serv.discnt
sym5 pcnt    when pcnt <> 0
sym6 tot_temp-serv.netto @ temp-serv.netto
sym7 tot_temp-serv.num-chk @ temp-serv.num-chk
sym8
with FRAME GoodsRep
.


HIDE stream PrnLibStream FRAME NBottomFrame .
run waitfram-hide in this-procedure .
output stream PrnLibStream CLOSE .
run prn-lib-prn-file in this-procedure (
                                          input my-handle
                                          ,input 0
                                          ).


END PROCEDURE. /*PROCEDURE ByGoodsObj:*/

PROCEDURE ByGoodsDate:
run prn-lib-open-stream  in this-procedure (
                                             input my-handle
                                            ,input {&LS_PS_A4}
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
put stream prnlibstream unformatted str2 skip(0).
PUT stream PrnLibStream SPACE(30) "По объектам :"
            format "X(198)" SKIP(1).
FOR EACH obj-list :
        FIND cli-obj WHERE cli-obj.obj-type = obj-list.obj-type AND
                                          cli-obj.obj-code = obj-list.obj-code NO-LOCK .
        PUT stream PrnLibStream SPACE(30) cli-obj.obj-name format "X(100)" SKIP.
END.
Put stream Prnlibstream unformatted p-report-header skip.
PUT stream PrnLibStream " " SKIP(1) .

FOR each date_temp-serv where
        date_temp-serv.gds-code = 0
    and date_temp-serv.obj-type = ''
    and date_temp-serv.obj-code = 0
    and date_temp-serv.fact-date > 01/01/1990
break
by date_temp-serv.fact-date
with FRAME goodsdaterep
:
  pcnt = round(  date_temp-serv.discnt /  date_temp-serv.tot-doc * 100, 1 ) .
  if pcnt = ? then pcnt = 0.
  DISPLAY stream PrnLibStream
  sym1 date_temp-serv.fact-date @ temp-serv.fact-date
  sym11
  sym9
  sym10
  sym2
  date_temp-serv.fact-qnty @ temp-serv.fact-qnty
  sym3
  date_temp-serv.tot-doc @ temp-serv.tot-doc
  sym4
  date_temp-serv.discnt @ temp-serv.discnt
  sym8 pcnt    when pcnt <> 0
  sym5 date_temp-serv.netto @ temp-serv.netto
  sym6
  date_temp-serv.num-chk @ temp-serv.num-chk
  sym7    with FRAME goodsdaterep.
  .
  DOWN stream PrnLibStream 1  with FRAME goodsdaterep.
  if can-find(first gds_temp-serv where
                    gds_temp-serv.fact-date = date_temp-serv.fact-date
                and gds_temp-serv.obj-type = ''
                and gds_temp-serv.obj-code = 0
                and gds_temp-serv.gds-code > 0) then do:
    for each gds_temp-serv where
            gds_temp-serv.fact-date = date_temp-serv.fact-date
        and gds_temp-serv.obj-type = ''
        and gds_temp-serv.obj-code = 0
        and gds_temp-serv.gds-code > 0:
      find first buf_goods no-lock where
                buf_goods.gds-code = gds_temp-serv.gds-code no-error.
      DISPLAY stream PrnLibStream
      sym1
      sym11
      sym2
      sym9 gds_temp-serv.gds-code @ temp-serv.gds-code
      sym10 (if available buf_goods then buf_goods.gds-name else '') @ v-gds-name
      gds_temp-serv.fact-qnty @ temp-serv.fact-qnty
      sym3
      gds_temp-serv.tot-doc @ temp-serv.tot-doc
      sym4
      gds_temp-serv.discnt @ temp-serv.discnt
      sym8 pcnt    when pcnt <> 0
      sym5 gds_temp-serv.netto @ temp-serv.netto
      sym6
      sym7    with FRAME goodsdaterep.
      .
      DOWN stream PrnLibStream 1  with FRAME goodsdaterep.
    end.
    UNDERLINE stream PrnLibStream
    temp-serv.fact-date
    temp-serv.obj-code
    temp-serv.gds-code
    v-gds-name
    temp-serv.fact-qnty
    temp-serv.tot-doc
    temp-serv.discnt
    pcnt
    temp-serv.netto
    temp-serv.num-chk
    with FRAME GoodsdateRep
    .
  end.

  if last( date_temp-serv.fact-date ) then do:
    /*итоги по наименованиям*/
    if can-find(first gdstot_temp-serv where
                      gdstot_temp-serv.fact-date = 01/01/1990
                  and gdstot_temp-serv.obj-type = ''
                  and gdstot_temp-serv.obj-code = 0
                  and gdstot_temp-serv.gds-code > 0) then do:
      for each gdstot_temp-serv where
              gdstot_temp-serv.fact-date = 01/01/1990
          and gdstot_temp-serv.obj-type = ''
          and gdstot_temp-serv.obj-code = 0
          and gdstot_temp-serv.gds-code > 0 :
        pcnt = round( gdstot_temp-serv.discnt / gdstot_temp-serv.tot-doc * 100, 1 ) .
        if pcnt = ? then pcnt = 0.
        find first buf_goods no-lock where
                  buf_goods.gds-code = gdstot_temp-serv.gds-code no-error.
        DISPLAY stream PrnLibStream
        sym1 "по услуге" @ temp-serv.fact-date
        sym11
        sym2
        sym10 gdstot_temp-serv.gds-code @ temp-serv.gds-code
        sym9 (if available buf_goods then buf_goods.gds-name else '') @ v-gds-name
        sym3 gdstot_temp-serv.fact-qnty @ temp-serv.fact-qnty
        sym4 gdstot_temp-serv.tot-doc @ temp-serv.tot-doc
        sym5 gdstot_temp-serv.discnt @ temp-serv.discnt
        sym6 pcnt    when pcnt <> 0
        sym7 gdstot_temp-serv.netto @ temp-serv.netto
        sym8
        with FRAME GoodsDateRep
        .
        DOWN stream PrnLibStream 1  with FRAME GoodsdateRep.
      end.
      UNDERLINE stream PrnLibStream
      temp-serv.fact-date
      temp-serv.obj-code
      temp-serv.gds-code
      v-gds-name
      temp-serv.fact-qnty
      temp-serv.tot-doc
      temp-serv.discnt
      pcnt
      temp-serv.netto
      temp-serv.num-chk
      with FRAME GoodsdateRep
      .
    end.
    if num-objs > 1 then do:
      UNDERLINE stream PrnLibStream
      temp-serv.obj-code
      temp-serv.fact-date
      temp-serv.gds-code
      v-gds-name
      temp-serv.fact-qnty
      temp-serv.tot-doc
      temp-serv.discnt
      pcnt
      temp-serv.netto
      temp-serv.num-chk
      with FRAME goodsdaterep
      .

      for each obj_temp-serv where
              obj_temp-serv.fact-date = 01/01/1990
            and obj_temp-serv.obj-type > ''
            and obj_temp-serv.gds-code = 0
      by obj_temp-serv.obj-type
      by obj_temp-serv.obj-code:
        pcnt = round( obj_temp-serv.discnt / obj_temp-serv.tot-doc * 100, 1 ) .
        if pcnt = ? then pcnt = 0.
        DISPLAY stream PrnLibStream
        sym1  "по маг" @ temp-serv.fact-date
        sym9
        sym10
        sym11 obj_temp-serv.obj-code @ temp-serv.obj-code
        sym2
        sym3 obj_temp-serv.fact-qnty @ temp-serv.fact-qnty
        sym4 obj_temp-serv.tot-doc @ temp-serv.tot-doc
        sym5 obj_temp-serv.discnt @ temp-serv.discnt
        sym6 pcnt    when pcnt <> 0
        sym7 obj_temp-serv.netto @ temp-serv.netto
        sym8 obj_temp-serv.num-chk @ temp-serv.num-chk
        with FRAME goodsdaterep
        .
        DOWN stream PrnLibStream 1  with FRAME goodsdaterep. .
      end.
    end.
    UNDERLINE stream PrnLibStream
    temp-serv.obj-code
    temp-serv.fact-date
    temp-serv.gds-code
    v-gds-name
    temp-serv.fact-qnty
    temp-serv.tot-doc
    temp-serv.discnt
    pcnt
    temp-serv.netto
    temp-serv.num-chk
    with FRAME goodsdaterep
    .
    find first tot_temp-serv where
              tot_temp-serv.fact-date = 01/01/1990
          and  tot_temp-serv.obj-type = ''
          and  tot_temp-serv.obj-code = 0
          and  tot_temp-serv.gds-code = 0
          .
    pcnt = round( tot_temp-serv.discnt / tot_temp-serv.tot-doc * 100, 1 ) .
    if pcnt = ? then pcnt = 0.
    DISPLAY stream PrnLibStream
    sym1 "ИТОГО" @ temp-serv.fact-date
    sym9
    sym10
    sym11
    sym2 tot_temp-serv.fact-qnty @ temp-serv.fact-qnty
    sym3 tot_temp-serv.tot-doc @ temp-serv.tot-doc
    sym4 tot_temp-serv.discnt @ temp-serv.discnt
    sym5 pcnt    when pcnt <> 0
    sym6 tot_temp-serv.netto @ temp-serv.netto
    sym7 tot_temp-serv.num-chk @ temp-serv.num-chk
    sym8
    with FRAME goodsdaterep
    .
  end. /*if last( temp-serv.fact-date ) then do:*/
END. /*  FOR each temp-serv where*/

HIDE stream PrnLibStream FRAME NBottomFrame .
run waitfram-hide in this-procedure .
output stream PrnLibStream CLOSE .
run prn-lib-prn-file in this-procedure (
                                          input my-handle
                                          ,input 0
                                          ).


END PROCEDURE. /*ByGoodsDAte*/

PROCEDURE ByGoodsDateObj:
run prn-lib-open-stream  in this-procedure (
                                             input my-handle
                                            ,input {&LS_PS_A4}
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
put stream prnlibstream unformatted str2 skip(0).
PUT stream PrnLibStream SPACE(30) "По объектам :"
            format "X(198)" SKIP(1).
FOR EACH obj-list :
        FIND cli-obj WHERE cli-obj.obj-type = obj-list.obj-type AND
                                          cli-obj.obj-code = obj-list.obj-code NO-LOCK .
        PUT stream PrnLibStream SPACE(30) cli-obj.obj-name format "X(100)" SKIP.
END.
Put stream Prnlibstream unformatted p-report-header skip.
PUT stream PrnLibStream " " SKIP(1) .

FOR EACH obj-list :
  FOR each dateobj_temp-serv where
          dateobj_temp-serv.gds-code = 0
      and dateobj_temp-serv.obj-type = obj-list.obj-type
      and dateobj_temp-serv.obj-code = obj-list.obj-code
      and dateobj_temp-serv.fact-date > 01/01/1990
  break
  by dateobj_temp-serv.fact-date
  with FRAME goodsdaterep
  :
    pcnt = round(  dateobj_temp-serv.discnt /  dateobj_temp-serv.tot-doc * 100, 1 ) .
    if pcnt = ? then pcnt = 0.
    DISPLAY stream PrnLibStream
    sym1 dateobj_temp-serv.fact-date @ temp-serv.fact-date
    sym11 dateobj_temp-serv.obj-code @ temp-serv.obj-code
    sym2
    dateobj_temp-serv.fact-qnty @ temp-serv.fact-qnty
    sym3
    dateobj_temp-serv.tot-doc @ temp-serv.tot-doc
    sym4
    dateobj_temp-serv.discnt @ temp-serv.discnt
    sym8 pcnt    when pcnt <> 0
    sym5 dateobj_temp-serv.netto @ temp-serv.netto
    sym6
    dateobj_temp-serv.num-chk @ temp-serv.num-chk
    sym7    /* with FRAME goodsdaterep. */
    .
    DOWN stream PrnLibStream 1 /* with FRAME goodsdaterep. */ .
    if can-find(first gdsobj_temp-serv where
                      gdsobj_temp-serv.fact-date = dateobj_temp-serv.fact-date
                  and gdsobj_temp-serv.obj-type = dateobj_temp-serv.obj-type
                  and gdsobj_temp-serv.obj-code = dateobj_temp-serv.obj-code
                  and gdsobj_temp-serv.gds-code > 0) then do:
      for each gdsobj_temp-serv where
              gdsobj_temp-serv.fact-date = dateobj_temp-serv.fact-date
          and gdsobj_temp-serv.obj-type = dateobj_temp-serv.obj-type
          and gdsobj_temp-serv.obj-code = dateobj_temp-serv.obj-code
          and gdsobj_temp-serv.gds-code > 0:
        find first buf_goods no-lock where
                  buf_goods.gds-code = gdsobj_temp-serv.gds-code no-error.
        DISPLAY stream PrnLibStream
        sym1 gdsobj_temp-serv.fact-date @ temp-serv.fact-date
        sym11 gdsobj_temp-serv.obj-code @ temp-serv.obj-code
        sym2
        sym9 gdsobj_temp-serv.gds-code @ temp-serv.gds-code
        sym10 (if available buf_goods then buf_goods.gds-name else '') @ v-gds-name
        gdsobj_temp-serv.fact-qnty @ temp-serv.fact-qnty
        sym3
        gdsobj_temp-serv.tot-doc @ temp-serv.tot-doc
        sym4
        gdsobj_temp-serv.discnt @ temp-serv.discnt
        sym8 pcnt    when pcnt <> 0
        sym5 gdsobj_temp-serv.netto @ temp-serv.netto
        sym6
        sym7    with FRAME goodsdaterep.
        .
        DOWN stream PrnLibStream 1  with FRAME goodsdaterep.
      end.
      UNDERLINE stream PrnLibStream
      temp-serv.obj-code
      temp-serv.gds-code
      v-gds-name
      temp-serv.fact-date
      temp-serv.fact-qnty
      temp-serv.tot-doc
      temp-serv.discnt
      pcnt
      temp-serv.netto
      temp-serv.num-chk
      with FRAME goodsdaterep
      .

    end.
  end. /*FOR each dateobj_temp-serv where*/
  UNDERLINE stream PrnLibStream
  temp-serv.obj-code
  temp-serv.gds-code
  v-gds-name
  temp-serv.fact-date
  temp-serv.fact-qnty
  temp-serv.tot-doc
  temp-serv.discnt
  pcnt
  temp-serv.netto
  temp-serv.num-chk
  with FRAME goodsdaterep
  .
  find first obj_temp-serv where
          obj_temp-serv.gds-code = 0
        and obj_temp-serv.fact-date = 01/01/1990
        and obj_temp-serv.obj-type = obj-list.obj-type
        and obj_temp-serv.obj-code = obj-list.obj-code no-error.
  if not available obj_temp-serv then do:
   create obj_temp-serv.
   assign
   obj_temp-serv.gds-code = 0
   obj_temp-serv.fact-date = 01/01/1990
   obj_temp-serv.obj-type = obj-list.obj-type
   obj_temp-serv.obj-code = obj-list.obj-code
   .
  end.
  pcnt = round( obj_temp-serv.discnt / obj_temp-serv.tot-doc * 100, 1 ) .
  if pcnt = ? then pcnt = 0.
  DISPLAY stream PrnLibStream
  sym1
  sym9
  sym10
  sym11 obj_temp-serv.obj-code @ temp-serv.obj-code
  sym2
  sym3 obj_temp-serv.fact-qnty @ temp-serv.fact-qnty
  sym4 obj_temp-serv.tot-doc @ temp-serv.tot-doc
  sym5 obj_temp-serv.discnt @ temp-serv.discnt
  sym6 pcnt    when pcnt <> 0
  sym7 obj_temp-serv.netto @ temp-serv.netto
  sym8 obj_temp-serv.num-chk @ temp-serv.num-chk
  with FRAME goodsdaterep
  .
  DOWN stream PrnLibStream 1  with FRAME goodsdaterep. .

  UNDERLINE stream PrnLibStream
  temp-serv.obj-code
  temp-serv.gds-code
  v-gds-name
  temp-serv.fact-date
  temp-serv.fact-qnty
  temp-serv.tot-doc
  temp-serv.discnt
  pcnt
  temp-serv.netto
  temp-serv.num-chk
  with FRAME goodsdaterep
  .
END. /*  FOR each obj-list*/
/*итоги по наименованиям*/
if can-find(first gdstot_temp-serv where
                  gdstot_temp-serv.fact-date = 01/01/1990
              and gdstot_temp-serv.obj-type = ''
              and gdstot_temp-serv.obj-code = 0
              and gdstot_temp-serv.gds-code > 0) then do:
  for each gdstot_temp-serv where
          gdstot_temp-serv.fact-date = 01/01/1990
      and gdstot_temp-serv.obj-type = ''
      and gdstot_temp-serv.obj-code = 0
      and gdstot_temp-serv.gds-code > 0 :
    pcnt = round( gdstot_temp-serv.discnt / gdstot_temp-serv.tot-doc * 100, 1 ) .
    if pcnt = ? then pcnt = 0.
    find first buf_goods no-lock where
              buf_goods.gds-code = gdstot_temp-serv.gds-code no-error.
    DISPLAY stream PrnLibStream
    sym1 "по услуге" @ temp-serv.fact-date
    sym9
    sym10
    sym11
    sym2
    sym10 gdstot_temp-serv.gds-code @ temp-serv.gds-code
    sym9 (if available buf_goods then buf_goods.gds-name else '') @ v-gds-name
    sym3 gdstot_temp-serv.fact-qnty @ temp-serv.fact-qnty
    sym4 gdstot_temp-serv.tot-doc @ temp-serv.tot-doc
    sym5 gdstot_temp-serv.discnt @ temp-serv.discnt
    sym6 pcnt    when pcnt <> 0
    sym7 gdstot_temp-serv.netto @ temp-serv.netto
    sym8
    with FRAME GoodsdateRep
    .
    DOWN stream PrnLibStream 1  with FRAME GoodsdateRep.
  end.
  UNDERLINE stream PrnLibStream
  temp-serv.fact-date
  temp-serv.obj-code
  temp-serv.gds-code
  v-gds-name
  temp-serv.fact-qnty
  temp-serv.tot-doc
  temp-serv.discnt
  pcnt
  temp-serv.netto
  temp-serv.num-chk
  with FRAME GoodsdateRep
  .
end.
find first tot_temp-serv where
          tot_temp-serv.fact-date = 01/01/1990
      and  tot_temp-serv.obj-type = ''
      and  tot_temp-serv.obj-code = 0
      and  tot_temp-serv.gds-code = 0
      .
pcnt = round( tot_temp-serv.discnt / tot_temp-serv.tot-doc * 100, 1 ) .
if pcnt = ? then pcnt = 0.
DISPLAY stream PrnLibStream
sym1 "ИТОГО" @ temp-serv.fact-date
sym11
sym9
sym10
sym2 tot_temp-serv.fact-qnty @ temp-serv.fact-qnty
sym3 tot_temp-serv.tot-doc @ temp-serv.tot-doc
sym4 tot_temp-serv.discnt @ temp-serv.discnt
sym5 pcnt    when pcnt <> 0
sym6 tot_temp-serv.netto @ temp-serv.netto
sym7 tot_temp-serv.num-chk @ temp-serv.num-chk
sym8
with FRAME goodsdaterep
.
HIDE stream PrnLibStream FRAME NBottomFrame .
run waitfram-hide in this-procedure .
output stream PrnLibStream CLOSE .
run prn-lib-prn-file in this-procedure (
                                          input my-handle
                                          ,input 0
                                          ).


END PROCEDURE. /*PROCEDURE ByGoodsDateObj:*/



