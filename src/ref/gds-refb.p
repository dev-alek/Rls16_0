block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gds-refb.p $
$Archive: ref/gds-refb.p $

Открытие запроса в справочнике товаров - товары на объекте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .


define input  parameter a-n-c       as character no-undo .
define input  parameter NameContext as character no-undo .
define input  parameter rs-sort     as character no-undo .
define input  parameter g-cond      as character no-undo .
define input  parameter g-list      as character no-undo .
define input  parameter g-stat      as character no-undo .
define input  parameter g-grp       like ub.goods.grp-name no-undo.
define input  parameter pobj-type   like ub.clients.obj-type no-undo.
define input  parameter pobj-code   like ub.clients.obj-code no-undo.
define parameter buffer g-producer for ub.clients.
define parameter buffer cur-obj for ub.clients.
define output parameter for-title as character no-undo .

define input  parameter filter-point as character no-undo .
define input  parameter filter-point0 as character no-undo .
define input  parameter sort-column-name as character no-undo .
define output parameter p-filter-name   as character  no-undo .
define input-output parameter v-doc-rec as recid no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gds-refb.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/gds-refb.p $":U .
define variable vss-description as character no-undo init "Открытие запроса в справочнике товаров".
{ cmp/vssrevis.i "substitute('&1|&2':u,substitute('&1|&2|&3|&4|&5':u,a-n-c,NameContext,rs-sort,g-cond,g-list),substitute('&1|&2|&3|&4':u,g-stat,g-grp,pobj-type,pobj-code))" }
{ cmp/str-glbl.i }

DEFINE SHARED buffer gob-doc FOR ub.gds-obj.
DEFINE SHARED buffer goo-doc FOR ub.goods.


{ ref/gds-refq.i gob-doc }