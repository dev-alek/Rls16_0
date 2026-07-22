block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gds-ind1.p $
$Archive: ref/gds-ind1.p $

Сохранение изменений в gds-obj-prop

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 03/23/05
*/

define temp-table tt0-gds-obj-prop-attr no-undo like  ub.gds-obj-prop-attr.

define input-output parameter p-doc-rec  as recid no-undo.
define input  parameter p-gds-code                   like  ub.gds-obj-prop.gds-code no-undo.
define input  parameter p-obj-type                   like  ub.gds-obj-prop.obj-type no-undo.
define input  parameter p-obj-code                   like  ub.gds-obj-prop.obj-code no-undo.
define input  parameter p-gdop-igt                   like  ub.gds-obj-prop.gdop-igt no-undo.
define input  parameter p-gdop-assort-min            like  ub.gds-obj-prop.gdop-assort-min  no-undo.
define input  parameter p-gdop-min-stock             like  ub.gds-obj-prop.gdop-min-stock   no-undo.
define input  parameter p-grop-level-always-presence like  ub.gds-obj-prop.grop-level-always-presence  no-undo.
define input  parameter p-grop-max-stock             like  ub.gds-obj-prop.grop-max-stock              no-undo.
define input  parameter p-grop-min-order             like  ub.gds-obj-prop.grop-min-order              no-undo.
define input  parameter table for tt0-gds-obj-prop-attr  .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gds-ind1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/gds-ind1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в gds-obj-prop".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ ref/gds-ind1.i gds-obj-prop-attr }

_MAIN:
DO ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:

    run gds-ind1
        (input-output p-doc-rec
        ,p-gds-code
        ,p-obj-type
        ,p-obj-code
        ,p-gdop-igt
        ,p-gdop-assort-min
        ,p-gdop-min-stock
        ,p-grop-level-always-presence
        ,p-grop-max-stock
        ,p-grop-min-order
        ,input table tt0-gds-obj-prop-attr
        ) no-error .
        if error-status :error then
        message vss-workfile vss-revision vss-description skip
                return-value skip
                error-status :get-message(1)
                view-as alert-box error
        .


end.