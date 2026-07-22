/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение и заполнение списка товаров с опцией объекта

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/20/06
Author: Bakhtadze Natalya
Creation date: 03/20/06

Параметры:

  {1} - имя таблицы.

  {2} - def      - если необходимо определение таблицы
                   с индексами: art  (artic, prod-type, prod-code)
                                code (gds-code)
        assign   - поиск и присвоение полей таблицы

  {3} - необязательный параметр
        параметры определения.
*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{2}" = "def" &then

&if defined(gdsolist_i_def) = 0 &then

&glob gdsolist_i_def


define {3} temp-table {1} no-undo like ub.goods
field qnty   as decimal
field to-del as logical
field order-num as integer
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index art  is primary unique artic prod-type prod-code obj-type obj-code
index code is         unique gds-code obj-type obj-code
index oi order-num
index iobj obj-type obj-code gds-code
.
&else

&endif

&endif

/* $Workfile$ e n d */