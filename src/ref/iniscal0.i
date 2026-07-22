/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение переменных для работы с весами

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/20/05
Author: Bakhtadze Natalya
Creation date: 09/20/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ cmp/gds-list.i gds-list def "new shared" }
{ cmp/gdsolist.i gdsolist def "new shared" }

define variable out-dir         as character no-undo.
define variable digi-out-dir   as character no-undo .
define variable tiger-out-dir   as character no-undo .
define variable tiger-spct2-out-dir   as character no-undo .
define variable tiger-spct1-out-dir   as character no-undo .
define variable tiger-spct2-install-dir  as character no-undo .
define variable tiger-spct1-install-dir  as character no-undo .
define variable scale-prog  as character no-undo.
define variable conf-attr as character no-undo.                  /* для чтения параметра конфигурации */
define variable conf-par as character no-undo.                  /* для чтения параметра конфигурации */
define variable par-type as character no-undo.
define variable ini-types as character no-undo.
define variable ini-progs as character no-undo.
/*точность представления - кол-во знаков после зап*/
define variable rnd-znak as integer no-undo init 2.
define variable obj-list as logical no-undo.
define buffer b-scales for ub.scales .
define variable goods-lst as character no-undo .
define variable jj as integer no-undo .
define variable gds-amount as integer no-undo .
define variable varscales-pref as character no-undo .
define variable varpgscales-pref as character no-undo .
define variable varscales-pref-type as character no-undo.



/* $Workfile$ e n d */