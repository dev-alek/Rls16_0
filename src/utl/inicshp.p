block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: inicshp.p $
$Archive: utl/inicshp.p $

Инициализация поля gds-obj.cash-parts

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/12/06
Author: Bakhtadze Natalya
Creation date: 04/12/06

*/

/*DEFINE INPUT PARAMETER install as logical no-undo.
это есть подготовка к автомат upgrade
*/

DEFINE var install as logical no-undo init no.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
define variable vss-author      as character no-undo init "$Author: expertek $":u .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: inicshp.p $":u .
define variable vss-archive     as character no-undo init "$Archive: utl/inicshp.p $":u .
define variable vss-description as character no-undo init "Инициализация поля gds-obj.cash-parts" .
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/gds-list.i gds-list def "new shared" }

define variable i as integer no-undo.
define variable k as integer no-undo.
define variable choice as integer no-undo.
def frame b
i label "Обработано товаров"
with side-labels title "Заполнение поля ПРОДАЖА ПО ПАРТИЯМ для серийных товаров" view-as dialog-box.

    view frame b.
    i = 0.

for each ub.units No-LOCK WHERE lookup({&serial}, ub.units.type) > 0:

    for each ub.goods No-LOCK ON STOP UNDO, NEXT
                            ON ERROR UNDO, NEXT:
        if ub.goods.unit-base = ub.units.unit-name then do:
            FOR EACH ub.gds-obj where ub.gds-obj.artic = ub.goods.artic AND
                                                      ub.gds-obj.prod-type = ub.goods.prod-type AND
                                                      ub.gds-obj.prod-code = ub.goods.prod-code:
                i = i + 1.
                ASSIGN
                ub.gds-obj.cash-parts = yes
                k = k + 1.
            END.
            disp i with frame b.
            process events.
        end.
    end.
end.


if i = k then
message "Заполнение поля ПРОДАЖА ПО ПАРТИЯМ для серийных товаров закончено успешно."
view-as alert-box.
else
message "Из " i " товаров на объекте, выбранных для изменения удалось изменить" k " !" view-as
alert-box WARNING.