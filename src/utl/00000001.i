/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Инклюд включающийся во все файлы пирога запуска обрезания.

Автор: Уханов Дмитрий Юрьевич
Дата создания: 11/29/01
Author: Dmitry Ukhanov
Creation date: 11/29/01

*/

define input parameter vartype-cut            as integer   no-undo. /*Тип обрезания 0 - полное, 1 - усечение документов в ГБД */
define input parameter varlist-db             as character no-undo. /*Список БД по которым производится усечение документов в ГБД. заполнено при vartype-cut = 1 */
define input parameter vardate-actual-goods   as date      no-undo. /*Дата актуальности товаров,  если ? - то нет актуальных товаров */
define input parameter vardate-actual-docs    as date      no-undo. /*Дата актуальности документов и архивов, если ? - то нет актуальных документов.
                                                                      Должна быть >= даты актуальности клиентов и даты актуальности товаров*/
define input parameter vardate-actual-findoc  as date      no-undo. /*Дата актуальности финансовых документов*/
define input parameter vardate-output-zone    as date      no-undo. /*Дата расходной зоны*/
define input parameter varstay-recipe-goods   as logical   no-undo. /*Оставляем все товары для рецептов*/
define input parameter varstay-weight-goods   as logical   no-undo. /*Оставляем все весовые товары*/
define input parameter varnot-copy-del-goods  as logical   no-undo. /*Не копировать удаленные товары с ненулевыми остатками*/
define input parameter varstay-history        as logical   no-undo. /*переносить историю */

define input parameter vargen-file            as character no-undo.
define stream str-gen.
output stream str-gen to vargen-file append.
if not connected("src") then do:
   return error "Нет коннекта с базой 'src'.".
end.
if not connected("dst") then do:
   return error "Нет коннекта с базой 'dst'.".
end.
/*Проверяем то, что мы в главной базе*/
find src.sys-ctrl no-lock.
if not available src.sys-ctrl then do:
   return error "В базе данных src не найдена уникальная запись sys-ctrl.".
end.
if src.sys-ctrl.db-num <> 0 then do:
   return error "Пакет обрезания работает только в главной базе данных. В данной версии удаленные БД создаются выгрузкой из главных.".
end.
/*Проверка дат актуальности*/
if vardate-actual-docs <> ? and
   (vardate-actual-goods   > vardate-actual-docs or
    vardate-actual-goods   = ? )   then do:
      return error SUBSTITUTE("Ошибка при задании дат актуальности." +
                              "Дата актуальности товаров &1."        +
                              "Дата актуальности документов &2."     +
                              "Дата актуальности документов должна быть больше или равна дат актуальностей товаров.",
                              vardate-actual-goods,
                              vardate-actual-docs).
end.
/* $Workfile$ e n d */