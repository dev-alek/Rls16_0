/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения временных таблиц для отчета по выручке

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define {1} temp-table benefits no-undo
field obj-type  like    clients.obj-type
field obj-code  like    clients.obj-code
field date_      like    chk-pay.chk-date
field pay-code   like    cash-pay.cdpay-code
field pay-name   like    cash-pay.obj-name
field curr-code  like    currency.curr-code
field curr-name  like    currency.curr-name
field tot-sum    like    chk-pay.tot-sum
field tot-base   like    chk-pay.tot-base
field tot-rubl   like    chk-pay.tot-rubl
field tot-r-b     like    chk-pay.tot-rubl
field pcnt          as      decimal
field pay-desk like chk-doc.pay-desk
INDEX pi IS PRIMARY     obj-type obj-code date_  pay-desk ASCENDING
INDEX pc                         pay-code curr-code
.

define {1} temp-table inkas-num no-undo
field inkas-code like inkas.inkas-code
field counted as logical
INDEX pi IS PRIMARY inkas-code.

define {1} temp-table day_sum no-undo
field obj-type   like    clients.obj-type
field obj-code   like    clients.obj-code
field date_      like   chk-pay.chk-date
field tot-base   like   chk-pay.tot-base
field tot-rubl   like   chk-pay.tot-rubl
field tot-r-b    like   chk-pay.tot-rubl
field chk-cnt-all as integer /* иногда - чеков всего, иногда - только фискальных */
field chk-cnt-nf  as integer /* чеков нефискальных */
field pay-desk   like chk-doc.pay-desk
INDEX pi IS PRIMARY     obj-type obj-code date_ pay-desk ASCENDING .

define {1} temp-table all-days_sum no-undo
field obj-type   like    clients.obj-type
field obj-code   like    clients.obj-code
field tot-base   like   chk-pay.tot-base
field tot-rubl   like   chk-pay.tot-rubl
field tot-r-b    like   chk-pay.tot-rubl
field chk-cnt-all as integer /* чеков всего */
field chk-cnt-nf  as integer /* чеков нефискальных */
field pay-desk   like chk-doc.pay-desk
INDEX pi IS PRIMARY     obj-type obj-code ASCENDING .

/* количество чеков по_дням/по_кассам/товарам по видам платежа по валютам:
     каждый чек под своим doc-code;
     сколько doc-code'ов в требуемом разрезе - столько и чеков */
define {1} temp-table ben-chk-count no-undo
  field doc-code  like chk-doc.doc-code
  field obj-type  like clients.obj-type
  field obj-code  like clients.obj-code
  field date_     like chk-doc.chk-date
  field pay-desk  like chk-doc.pay-desk
  field b-code    like bar-code.b-code 
  field pay-code  like cash-pay.cdpay-code
  field curr-code like currency.curr-code
  index dc doc-code
  index dt date_ pay-code obj-code  
  index dp pay-code  
.

/* количество чеков по группам товаров: в скольки чеках присутствовали товары группы */
define {1} temp-table help-chk no-undo
  field doc-code  as character
  field group-chk as integer
  field obj-code  like clients.obj-code
  field pay-code  like cash-pay.cdpay-code
  field curr-code like currency.curr-code
  index pi is primary unique doc-code group-chk obj-code pay-code curr-code
.

/* суммы оплат побаркодно по видам платежа по валютам */ 
define {1} temp-table tt-gds-sum no-undo
  field obj-type  like clients.obj-type
  field obj-code  like clients.obj-code
  field pay-code  like cash-pay.cdpay-code
  field curr-code like currency.curr-code
  field b-code    like bar-code.b-code
  field gds-code  like bar-code.gds-code 
  field tot-r-b   like chk-gds-pay.tot-r-b
  INDEX pi IS PRIMARY b-code obj-type obj-code pay-code curr-code ASCENDING
.

/* суммы оплат потоварно, с группами, по видам платежа по валютам */ 
define {1} temp-table tt-grp-sum no-undo
  field obj-type  like clients.obj-type
  field obj-code  like clients.obj-code
  field obj-name  like clients.obj-name
  field pay-code  like cash-pay.cdpay-code
  field pay-name  like cash-pay.obj-name
  field curr-code like currency.curr-code
  field curr-name like currency.curr-name

  field is-group  as logical /* true - группы товаров, false - товары */
  field upper-code as integer   /* gds-grp.upper-code */
  field grp-lvl   as integer   /* товар = 0; терминальная группа = 1, вышестоящая группа = 2, и т.д. */
  field def-code  as integer   /* goods.gds-code, gds-grp.node-code */
  field def-name  as character /* goods.gds-name, gds-grp.node-name */
  field def-level as integer   /* уровень вложенности; начинается с 1 */

  field tot-r-b   like chk-gds-pay.tot-r-b
  field chk-cnt-all as integer /* чеков всего */
  field chk-cnt-nf  as integer /* чеков нефискальных */
  
  INDEX dc obj-code pay-code curr-code upper-code def-code
.

/* $Workfile$ e n d */