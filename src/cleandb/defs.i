/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Инклюд включающийся во все файлы пирога запуска очистки УБД.

Автор: Ростовцев Александр
Дата создания: 12/09/2025
Author: Aleksandr Rotovtsev
Creation date: 09/12/25

*/

define input parameter vardate-actual-docs    as date      no-undo. /*Дата актуальности документов */
define input parameter varcall-back           as handle no-undo.

define variable vDeleted as int64     no-undo.
define variable vResult  as character no-undo.

/*define stream str-gen.                             */
/*output stream str-gen to value(vargen-file) append.*/

define buffer buf_clients for ub.clients.

&scoped-define ResultValue Произведена чистка таблиц: ~
{&Tables} ~
Удалено записей - string(vDeleted)

find ub.sys-ctrl no-lock.
if not available ub.sys-ctrl then do:
   return error "Не найдена уникальная запись sys-ctrl.".
end.
/*if ub.sys-ctrl.db-num = 0 then do:                                          */
/*   return error "Пакет очистки БД работает только в удаленной базе данных.".*/
/*end.                                                                        */

/* $Workfile$ e n d */