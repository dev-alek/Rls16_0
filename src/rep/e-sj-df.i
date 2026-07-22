/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

определение временной таблицы для журнала продаж

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/03/05
Author: Bakhtadze Natalya
Creation date: 12/03/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define {1} temp-table sj-goods no-undo
field obj-attr     as   char
field b-code like ub.bar-code.b-code format "9999999999999"
field saleman-chr as   character
field artic     like ub.goods.artic
field name   like ub.goods.gds-name format "x(30)"
field grp-code          like ub.goods.grp-code
field grp-name          like ub.goods.grp-code /*это не просто так!!!!*/
field prod-name   like ub.clients.obj-name
field node-code like ub.gds-prt.node-code
field node-name like ub.gds-prt.node-name
field twounit as decimal
field two-type as logical
field alt-type as logical
/*учет в 2-х един измерения может быть
1 - вторая единица измерения штука - 1 штука в одной строке чека
2 - из goods.wt-cart - вес кольца
*/
INDEX p1 IS PRIMARY   obj-attr ASCENDING
INDEX p2              obj-attr artic ASCENDING
INDEX p3              obj-attr prod-name ASCENDING
INDEX p4              obj-attr b-code saleman-chr ASCENDING
INDEX p6              obj-attr grp-name prod-name
INDEX p7              grp-code
.


define {1} temp-table sj-adv no-undo
field obj-attr     as   char
field b-code like ub.bar-code.b-code format "9999999999999"
field saleman-chr as    character
field price    like ub.chk-gds.price-base
field discnt  like ub.chk-gds.discnt
field qnty     like ub.chk-gds.doc-qnty
field qnty-2     like ub.chk-gds.doc-qnty
field qnty-3    like ub.chk-gds.doc-qnty
field dop-rowid as rowid
field brutto-sum   as   decimal
field discnt-sum  like ub.chk-gds.discnt
field netto-sum    as   decimal
field brutto-sum-r   as   decimal
field netto-sum-r    as   decimal
field num-lines as integer
field num-docs as integer
INDEX pi  IS PRIMARY   obj-attr b-code saleman-chr price discnt dop-rowid ASCENDING
.

define {1} temp-table sj-tots no-undo
field obj-attr     as   char
field grp-code          like ub.goods.grp-code
field grp-name          like ub.goods.grp-code /*это не просто так!!!!*/
field prod-name   like ub.clients.obj-name
field saleman-chr as    character
field qnty     like ub.chk-gds.doc-qnty
field qnty-2   like ub.chk-gds.doc-qnty
field qnty-3   like ub.chk-gds.doc-qnty
field brutto-sum   as   decimal
field discnt-sum  like ub.chk-gds.discnt
field netto-sum    as   decimal
field brutto-sum-r   as   decimal
field netto-sum-r    as   decimal
field num-lines as integer
field num-docs as integer
INDEX pi  IS PRIMARY   obj-attr ASCENDING
INDEX p1                        prod-name ASCENDING
INDEX p2                        grp-name  ASCENDING
INDEX p3                        grp-code
.

define {1} temp-table sj-grp no-undo
field grp-code like ub.goods.grp-code
field grp-name like ub.goods.grp-name
field grp-code-alpha like ub.goods.grp-code
INDEX pi grp-code
INDEX iname  grp-name
INDEX grp-code-alpha grp-code-alpha
.

define {1} temp-table sj-salesman no-undo
field seller like ub.person.seller
field psn-code like ub.person.psn-code
field sal-chr as character
index pi is unique primary seller psn-code
index ichr sal-chr
index ipsn psn-code
.

FUNCTION get-grp-name returns character( input p-grp-code-alpha as integer):
define buffer buf_sj-grp for sj-grp.
  find first buf_sj-grp no-lock where
            buf_sj-grp.grp-code-alpha = p-grp-code-alpha no-error.
  if available buf_sj-grp then do:
    return buf_sj-grp.grp-name .
  end.
  return "!!!Неизвестное имя группы!!!".
END FUNCTION.



/* $Workfile$ e n d */