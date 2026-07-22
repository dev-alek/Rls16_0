block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Запись истории документа план-меню

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

*/
define parameter buffer oldb for ub.fbr-pln.
define parameter buffer newb for ub.fbr-pln.
do
on error undo, return error
:
/* TODO */
end.