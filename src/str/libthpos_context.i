/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Контекст разбора и создания чеков

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/25/08
Author: Bakhtadze Natalya
Creation date: 07/25/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define {2} temp-table {1}  no-undo
field parparentproc as widget-handle
field obj-type as character init {&shop}
field db-num as integer
field obj-code  as integer
field pos-type as character
field cash-num as integer

/*общие*/
field r-b as character
field host-code as integer
field base-code as integer
field cre-pay as integer
field is-catering as logical
field is-cdinv as logical
field is-ptrl as logical
field is-wth as logical
field dc-mask as logical
field card-by-mask as logical
field sclspref as character
field scpgpref as character
field doc-prt as logical
field shift-on as logical
field cas-shft as logical
field t-shft as integer
field v-shft as integer

/*нудны только для разбора чеков*/
field ibmgroup as logical
field hnum as logical
field is-100-discnt as integer
field zero-cashier as integer

/*нужны только для кассы IBS*/
field nam-2str as logical
field nam-artc  as logical
field cod-pcod as logical
field name-2cd as character
field nalc as integer
field serial-code as character
field cas-curs as logical
field sales-man as integer
field salesman-psn-code as integer


index pi is unique primary
db-num
obj-code
pos-type
cash-num
.

/* $Workfile$ e n d */