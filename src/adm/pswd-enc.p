block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: pswd-enc.p $
$Archive: adm/pswd-enc.p $

Кодировка парол

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/27/06
Author: Dmitry Ukhanov
Creation date: 03/27/06

*/

define input parameter  pswd     as character no-undo .
define output parameter enc-pswd as character no-undo .

do
on error undo, return error return-value
:
  run pswd-enc-procedure in this-procedure
    (input  pswd
    ,output enc-pswd
    ) .
end.

{ adm/pswd-enc.i
  &proc-name=pswd-enc-procedure
}