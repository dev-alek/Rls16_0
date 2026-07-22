/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$
 


Автор: Рубан Дмитрий Андреевич
Дата создания: 11/07/18
Author: 
Creation date: 11/07/18

*/
block-level on error undo, throw.

TRIGGER PROCEDURE FOR WRITE OF ub.c-PromoGoods
  NEW BUFFER new-c-PromoGoods
  OLD BUFFER old-c-PromoGoods
.

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo init "Тригер изменение с-PromoGoods". 
{ cmp/vssrevis.i }
