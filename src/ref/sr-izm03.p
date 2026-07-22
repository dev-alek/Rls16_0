/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Удаление средств измерения из базы данных

Автор: Молотков Сергей
Дата создания: 05/12/17
Author: Molotkov Sergey
Creation date: 05/12/17

Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/
BLOCK-LEVEL ON ERROR UNDO, THROW.

define input parameter p-node-code             as integer no-undo . /* like ub.sr-izmerenia.node-code */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Удаление средств измерения из базы данных".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ str/placelib.i }
&scoped-define buf-name buf_sr-izmerenia

define variable v-s-node as character no-undo .
define buffer buf_place-attr    for ub.place-attr .
define buffer buf_doc-line-attr for ub.doc-line-attr .
define buffer buf_sr-izmerenia  for ub.sr-izmerenia .


  v-s-node = string(p-node-code) .
  find first buf_place-attr no-lock
       where buf_place-attr.attr-code  = {&place-SI}
         and buf_place-attr.attr-value = v-s-node no-error .
  if available buf_place-attr then do:
    undo, throw new Progress.Lang.AppError(
      substitute("&1 &2 &3&4Ошибка удаления. Средство измерения с ид.[&5] используется в резервуаре [&6] на объекте [&7 &8]"
                , vss-workfile, vss-revision, vss-description, {&new-line}
                , v-s-node, buf_place-attr.pl-code, buf_place-attr.obj-type, buf_place-attr.obj-code
                )
    ) .
  end.

  find first buf_doc-line-attr no-lock
       where buf_doc-line-attr.attr-code  = {&place-SI}
         and buf_doc-line-attr.attr-value = v-s-node no-error .
  if available buf_doc-line-attr then do:
    undo, throw new Progress.Lang.AppError(
      substitute("&1 &2 &3&4Ошибка удаления. Средство измерения с ид.[&5] у товара [&6] в документе [&7]"
                , vss-workfile, vss-revision, vss-description, {&new-line}
                , v-s-node, buf_doc-line-attr.gds-code, buf_doc-line-attr.doc-code
                )
    ) .
  end.
  
           
  find first {&buf-name} exclusive-lock where {&buf-name}.node-code = p-node-code no-error no-wait .
  if locked({&buf-name}) then do:
    undo, throw new Progress.Lang.AppError(
      substitute("&1 &2 &3&4Запись о средстве измерения с кодом [&5] занята другим пользователем",
                   vss-workfile, vss-revision, vss-description, {&new-line}, 
                   p-node-code )
    ) .
  end . 
  if not available {&buf-name} then do:
    undo, throw new Progress.Lang.AppError(
        substitute("&1 &2 &3&4Запись о средстве измерения с кодом [&5] отсутствует",
                   vss-workfile, vss-revision, vss-description, {&new-line}, 
                   p-node-code )
    ) .
  end .

  delete {&buf-name} .
