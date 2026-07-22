/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автоматизированное формирование списка РАЗНООБРАЗНЕЙШИХ КОДОВ урезанное

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/09/05
Author: Bakhtadze Natalya
Creation date: 02/09/05

no_app_help.i

урезанное нужно чтобы отсеять только те коды которые могут привязывать правила скидок

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input parameter p-caller as character no-undo .

&global-define pbc-option no
&global-define ean-option no
&global-define parts-option no

&global all-options                                 ~
"Текущая строка,single,                           ~
Товары-коды по типам,goods,                       ~
Товар-лок.код,goods-b-code,                       ~
Файл списка товаров,file-gds,                     ~
Все,all,                                          ~
Список товаров,gds-list,                          ~
Мобильн. сканер,scaner"


{ cmp/trg-def.i }
{ str/anyblist.i bb-list }

/* $Workfile$ e n d */