block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Шкляр Елена 
Дата создания: 30 сент. 2019 г.
Author:  Shklyar Elena
Creation date: 30 сент. 2019 г.

*/
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }

{ str/defc-ext-classif.i "shared" } /*не должен использоваться в load-rec.p*/
define input  parameter table    for ext-classif-list .
define input  parameter table    for c-ext-classif-list .