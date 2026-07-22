block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись описаний полей таблиц для типов данных.

Автор: Белоусов Илья Александрович
Дата создания: 02/21/07
Author: Ilia Belousov
Creation date: 02/21/07

Input:

Output:

*/

TRIGGER PROCEDURE FOR WRITE OF ub.datatype-table-field .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись описаний полей таблиц для типов данных.".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/str-glbl.i }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  define buffer buf_datatype-table-field for ub.datatype-table-field .

  if trim( ub.datatype-table-field.dtt-name ) = "":U
    or ub.datatype-table-field.dtt-name = ?
  then do:
    return error substitute( "&1. Название таблицы не может иметь неопределенное значение!!!", vss-workfile ) .
  end.

  if trim( ub.datatype-table-field.dtf-name ) = "":U
    or ub.datatype-table-field.dtf-name = ?
  then do:
    return error substitute( "&1. Название поля таблицы не может иметь неопределенное значение!!!", vss-workfile ) .
  end.

  if trim( ub.datatype-table-field.dtf-xml-tag ) = "":U
    or ub.datatype-table-field.dtf-xml-tag = ?
  then do:
    return error substitute( "&1. XML тэг поля таблицы не может иметь неопределенное значение!!!", vss-workfile ) .
  end.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_datatype-table-field}
        , input ( buffer ub.datatype-table-field:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.