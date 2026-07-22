/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

определения признака в пересылке на кассу

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable ff  as  integer no-undo.

        FIND ub.prt-obj WHERE
                           ub.prt-obj.obj-type = {&shop} AND
                           ub.prt-obj.obj-code = ub.shop.obj-code AND
                           ub.prt-obj.prod-type = ub.goods.prod-type AND
                           ub.prt-obj.prod-code = ub.goods.prod-code AND
                           ub.prt-obj.artic = ub.goods.artic AND
                           ub.prt-obj.prt-code = b-g-p.node-code NO-LOCK NO-ERROR .

        def var l-in-ov as logical no-undo .
        { gbl/gdsobjat.i
          {&shop}
          ub.shop.obj-code
          ub.goods.artic
          ub.goods.prod-type
          ub.goods.prod-code
          "'in-ov=request'"
          l-in-ov
          no-error
        }
        if error-status:error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка получения признака товара на объекте" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return no-apply .
        end.

        if (g#in-ov and l-in-ov)
        OR ( ( NOT ub.shop.all-prt ) AND
             ( ub.goods.gds-type = {&gds-goods} ) AND
             ( NOT ( can-find( first ub.gds-dtl where ub.gds-dtl.artic = ub.goods.artic
                                         and ub.gds-dtl.prod-type = ub.goods.prod-type
                                         and ub.gds-dtl.prod-code = ub.goods.prod-code
                                         and ub.gds-dtl.prt-code = b-g-p.node-code
                                         and ub.gds-dtl.obj-type = {&shop}
                                         and ub.gds-dtl.obj-code = ub.shop.obj-code ) OR
                          ( available ub.prt-obj
/*закоментарено в порядке ЭКСПЕРИМЕНТА - ждем отзывов с мест*/
/*                          AND ub.prt-obj.fact-qnty <> 0 */
                          ) ) ) ) then
            return error.


        FIND ub.bar-code WHERE ub.bar-code.node-code = b-g-p.node-code
                   and ub.bar-code.prod-type = ub.goods.prod-type
                   and ub.bar-code.prod-code = ub.goods.prod-code
                   and ub.bar-code.artic     = ub.goods.artic
                   and ub.bar-code.in-code = ""
                   and ub.bar-code.part-code = ""
                   and ub.bar-code.unit-cli = ub.goods.unit-base NO-LOCK .

/* $Workfile$ e n d */