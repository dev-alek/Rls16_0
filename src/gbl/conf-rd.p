block-level on error undo, throw.
/*

$Revision: 6b203531fb4a, 3411, rls $
$Author: SSlivenko $
$Date: 2023/08/17 10:18:56 $
$Workfile: conf-rd.p $
$Archive: gbl/conf-rd.p $

Чтение параметров конфигурации для текущей БД

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

define input param  p-code  as character no-undo . /* метка настройки - обязательна */
define input param  h-code  as integer   no-undo . /* код фирмы */
define input param  o-type  as character no-undo . /* тип объекта */
define input param  o-code  as integer   no-undo . /* код объекта */
define input param  g-name  as character no-undo . /* не используется */
define input param  u-name  as character no-undo . /* не используется */
define input param  e-name  as character no-undo . /* не используется */
define input param  msg-on  as logical   no-undo . /* yes - сообщения выдаются */
define output param p-value as character no-undo . /* значение параметра - character */
define output param p-type  as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: 6b203531fb4a, 3411, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: 2023/08/17 10:18:56 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: conf-rd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/conf-rd.p $":U .
define variable vss-description as character no-undo init "Чтение параметров конфигурации для текущей БД".

{ cmp/str-glbl.i }
{ cmp/library.i  }

{ gbl/conf-rd.i
  p-code
  h-code
  o-type
  o-code
  g-name
  u-name
  e-name
  msg-on
  p-value
  p-type
  no-error
}
if error-status :error then do:
  if error-status :get-message(1) <> "" then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры conf-rd" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
  end.
  undo, return error return-value.
end.