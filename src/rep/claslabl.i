/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сортировки группировки

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 04/07/04 12:13

*/
def var t-class as char no-undo.
def var t-sort as char no-undo.
  case classify:
    when "no-classify":u    then t-class =   "Без классификации" .
    when "prod":u           then t-class =   "Производители"   .
    when "post":u           then t-class =   "Поставщики"   .
    when "grp-goods":u      then t-class =   "Группы товаров"  .
    when "post/grp-goods":u then t-class =   "Поставщики/Группы товаров" .
    when "prod/grp-goods":u then t-class =   "Производители/Группы товаров" .
    when "grp-goods/prod":u then t-class =   "Группы товаров/Производители" .
    when "grp-goods/post":u then t-class =   "Группы товаров/Поставщики" .
    when  "vat-ps":u        then t-class =   "Ставка НДС" .
    when  "sort":u          then t-class =   "Проба(Сорт)" .
    when  "n-level":u       then t-class =   "Группы с уровнем вложенности " .
    when  "t-level":u       then t-class =   "Терминальные группы" .

 end case.

  case sorttype:
    when "sort-pp":u               then t-sort =   "по порядку" .
    when "sort-code":u             then t-sort =   "по коду" .
    when "sort-artic":u            then t-sort =   "по артикулу"  .
    when "sort-qunty":u            then t-sort =   "по реализации".
    when "sort-name":u             then t-sort =   "по наименованию".
    when "sort-type":u             then t-sort =   "по типу ткани".
    when "sort-doc-code":u         then t-sort =   "по номеру документа".
    when "sort-recipe-code":u      then t-sort =   "по номеру рецепта".
 end case.

 /* $workfile: claslabl.i $ e n d */