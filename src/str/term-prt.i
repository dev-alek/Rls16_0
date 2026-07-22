/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

определение цены на признак и создание записи во временной таблице

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/04/05
Author: Bakhtadze Natalya
Creation date: 11/04/05

для отсылки товаров на кассу

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


/*вызывается для товара из списка {1} = gds-list или товара {1} = ub.goods */
PROCEDURE term-prt.
/*заполняет таблицу cash-gds сканируя бар-коды и ДОПБК*/
&if "{&bbc}" <> '':U &then
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .
&endif
define input parameter c-root like ub.gds-prt.prt-root no-undo.
define input parameter c-node like ub.gds-prt.node-code no-undo.
define buffer b-g-p for ub.gds-prt.
define buffer pr-bc for ub.bar-code .
define buffer b-bc for ub.bar-code .
define buffer p-bar-code for ub.bar-code .
define buffer b-units for ub.units.
define variable pusto as char init "" no-undo.

&if "{&tsd}" <> "" &then
 { str/sgi-tsd.i {1} c-node }
&elseif  "{&bbc}" <> "" &then
 { str/sgi-bbc.i {1} c-node }
&else
 { str/sendgi.i {1} c-node }
&endif


  /* пошкальный цикл по бар-кодам с основным едизмом и пустыми in-code и part-code- */
  _b-g-p:
   FOR EACH ub.bar-code NO-LOCK where
            ub.bar-code.gds-code = {1}.gds-code,
      FIRST b-g-p NO-LOCK WHERE
            b-g-p.node-code = ub.bar-code.node-code
       AND  b-g-p.prt-root = c-root
       AND  b-g-p.is-term = yes
&if "{&called}" = "in-ov" &then
      ,
      FIRST PR-bc NO-LOCK WHERE
            PR-bc.b-code = price-list.b-code
&endif
&if "{&called}" = "pdf" &then
      ,
      FIRST PR-bc NO-LOCK WHERE
            PR-bc.b-code = ub.price-doc-forming-gds.b-code
&endif

     :
     if ub.bar-code.part-code <> ""
     OR ub.bar-code.in-code <> ""
     OR ub.bar-code.unit-cli <> {1}.unit-base then NEXT _b-g-p.
    /*внутри пошкального цикла все остальные*/
    /* если нам нужны не все терм узлы шкалы  имеющие бар-код, а
    все товары проходившие на объекте X - настройка shop.r-obj-type shop.r-obj-code*/
    &if "{&tsd}" <> "" &then
      { str/streetsd.i {1} }
      { str/termprt1.i {1} temp-shop i-obj-type i-obj-code }
    &elseif "{&bbc}" <> ""  &then
      { str/sendtree.i {1} temp-shop p-curr-obj-type p-curr-obj-code}
      { str/termprt1.i {1} temp-shop p-curr-obj-type p-curr-obj-code }
    &else
      { str/sendtree.i {1} ub.shop ~{&shop~} ub.shop.obj-code  }
      { str/termprt1.i {1} ub.shop ~{&shop~} ub.shop.obj-code }
    &endif

  end.  /*FOR each b-g-p*/
END PROCEDURE .

/* $Workfile$ e n d */