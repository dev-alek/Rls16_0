block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: uchclic.p $
$Archive: utl/uchclic.p $

Утилита проверки целостности сооответствия таблиц clients и firm/person/store/shops

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: uchclic.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/uchclic.p $":U .
define variable vss-description as character no-undo init "утилита проверки целостности сооответствия таблиц clients и firm/person/store/shops".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ gbl/waitfram.i }

DEFINE var rs as logical init no no-undo.
DEFINE stream ff.
output stream ff to uchclic.txt.

run waitfram-show in this-procedure ("Ждите ...").
put stream ff unformatted
"Проверка соответствия таблиц ФИРМЫ, ПЕРСОНЫ, МАГАЗИНЫ, СКЛАДЫ" skip
string( "таблице КЛИЕНТОВ - " + cur-time-string() ) skip.
FOR EACH ub.CLIENTS No-LOCK :
        CASE ub.clients.obj-type:
            WHEN {&shop} then do:
                FIND FIRST ub.shop No-LOCK WHERE ub.shop.obj-code = ub.clients.obj-code No-ERROR.
                IF NOT avail ub.shop then do:
                    PUT stream ff unformatted
                    ub.clients.obj-type SPACE(1) ub.clients.obj-code SKIP.
                    rs = yes.
                end.
            END.
            WHEN {&shop} then do:
                FIND FIRST ub.store No-LOCK WHERE ub.store.obj-code = ub.clients.obj-code No-ERROR.
                IF NOT avail store then do:
                    PUT stream ff unformatted
                    ub.clients.obj-type SPACE(1) ub.clients.obj-code SKIP.
                    rs = yes.
                end.
            END.
            WHEN {&cmp} then do:
                FIND FIRST ub.firm No-LOCK WHERE ub.firm.firm-code = ub.clients.obj-code No-ERROR.
                IF NOT avail ub.firm then do:
                    PUT stream ff unformatted
                    ub.clients.obj-type SPACE(1) ub.clients.obj-code SKIP.
                    rs = yes.
                end.
            END.
            WHEN {&prs} then do:
                FIND FIRST ub.person No-LOCK WHERE ub.person.psn-code = ub.clients.obj-code No-ERROR.
                IF NOT avail ub.person then do:
                    PUT stream ff unformatted
                    ub.clients.obj-type SPACE(1) ub.clients.obj-code SKIP.
                    rs = yes.
                end.
            END.
        END CASE.
END.

output stream ff CLOSE.
run waitfram-hide in this-procedure .
if NOT rs then
OS-DELETE uchclic.txt.
message "Проверка соответствия таблиц ФИРМЫ, ПЕРСОНЫ, МАГАЗИНЫ, СКЛАДЫ" skip
                "                                   таблице КЛИЕНТОВ закончена!"
                skip
                string(if rs then
                "                              Результаты выведены в файл uchclic.txt" else
                "                                         Ошибок НЕ НАЙДЕНО!")
                view-as alert-box.