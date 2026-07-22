/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения для начальной выгрузки данных для RCS

Автор: Гюнтнер Виктор Арнольдович
Дата создания: 04/12/06
Author: Victor Guntner
Creation date: 04/12/06

Input:

Output:

*/
&global-define bcodes-filename "bcodes.txt"
&global-define goods-filename  "goods.txt"
&global-define prices-filename "prices.txt"

define stream out-stream.

define temp-table temp_gds-costs no-undo
    field artic     as character
    field prod-type as character
    field prod-code as integer
    field empty     as logical
    field cost      as decimal
index pi is primary unique artic prod-type prod-code
index emp empty
.
define temp-table temp_gds-prices no-undo
    field artic     as character
    field prod-type as character
    field prod-code as integer
    field price     as decimal
index pi is primary unique artic prod-type prod-code
.

/* $Workfile$ e n d */