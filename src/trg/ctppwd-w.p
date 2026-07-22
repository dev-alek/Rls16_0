block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление записей из истории таблицы журнала технологических проливов

Автор: Палагин Сергей Евгеньевич
Дата создания: 20.10.2018
Author: Palagins
Creation date: 20.10.2018

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-tech-prol-pwd NEW BUFFER Buf_New OLD BUFFER Buf_Old.
