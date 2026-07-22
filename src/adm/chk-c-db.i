/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

проверка корректности копии БД и ее подготовка

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/02
Author: Dmitry Ukhanov
Creation date: 03/22/02

*/

&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$".

create alias db-orig for database {3} no-error.
create alias db-copy for database {4} no-error.

if pdbname( {3} ) = pdbname( {4} )
  or pdbname( {4} ) = "ub":U
then do:
  delete alias db-orig .
  delete alias db-copy .
  message
    vss-workfile vss-revision vss-description skip
    substitute( "Копии БД должна иметь ФИЗИЧЕСКОЕ ИМЯ отличное от имени исходной БД и от ub." ) skip
    substitute( "Физическое имя исходной БД: &1", pdbname( {3} ) ) skip
    substitute( "Физическое имя копии БД: &1", pdbname( {4} ) ) skip
    view-as alert-box error
  .
  return {5}.
end.
run adm/chk-c-db.p ( input {1}
               ,input {2}
              ) no-error .
if error-status :error then do:
  delete alias db-orig .
  delete alias db-copy .
  message
    vss-workfile vss-revision vss-description skip
    substitute( "Ошибка при проверке корректности и подготовке копии БД." ) skip
    error-status :get-message ( error-status :num-messages ) skip
    return-value
    view-as alert-box error
  .
  return {5}.
end.

delete alias db-orig .
delete alias db-copy .



/* $Workfile$ e n d */