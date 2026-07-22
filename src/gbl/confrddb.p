block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: confrddb.p $
$Archive: gbl/confrddb.p $

Чтение параметров конфигурации для заданной БД

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/00
Author: Dmitry Ukhanov
Creation date: 03/22/00

*/

/*
Возвращаемые значения:
  p-value: значение параметра
  p-type:  тип параметра
    {&type-char}
    {&type-log}
    {&type-dec}
    {&type-int}
    {&type-date}

Сначала ищется запись config с указанным параметрами,
если запись не найдена, то производится поиск записи config
только по параметру p-code (общесистемной настройки).

Для config, привязанных к объекту,
производится поиск настройки по объекту,
Если отсутствует настройка по объекту, то производится поиск настройки по фирме
Если отсутствует настройка по объекту, то производится поиск глобальной настройки

*/

define input  parameter p-code   as character no-undo . /* метка настройки - обязательна */
define input  parameter p-db-num as integer   no-undo . /* номер БД */
define input  parameter h-code   as integer   no-undo . /* код фирмы */
define input  parameter o-type   as character no-undo . /* тип объекта */
define input  parameter o-code   as integer   no-undo . /* код объекта */
define input  parameter msg-on   as logical   no-undo . /* yes - сообщения выдаются */
define output parameter p-value  as character no-undo . /* значение параметра - character */
define output parameter p-type   as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: confrddb.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/confrddb.p $":U .
define variable vss-description as character no-undo init "Чтение параметров конфигурации для заданной БД".

{ cmp/str-glbl.i }
{ cmp/library.i  }

{ gbl/confrddb.i
  p-code
  p-db-num
  h-code
  o-type
  o-code
  msg-on
  p-value
  p-type
  no-error
}
if error-status :error then do:
  if error-status :get-message(1) <> "" then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры confrddb" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
  end.
  undo, return error return-value.
end.