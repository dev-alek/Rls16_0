/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Временная таблица с информацией о признаках товара

Автор: Чернова Светлана Александровна
Дата создания: 02/27/07
Author: Svetlana Chernova
Creation date: 02/27/07

create: Перваков Михаил Сергеевич
Дата создания: 09/05/03

*/


define temp-table temp-gds-prt no-undo
  field b-code        as integer   format '9999999999':u       label "Осн. код"
  field sort-code     as character                             label "Код сортировки по признакам"
  field node-code     as integer
  field upper-code    as integer
  field prt-name      as character format 'x(35)':u            label "Признак"
  field node-name     as character format 'x(16)':u            label "Признак"
  field doc-qnty      as decimal   format '->>>,>>>,>>9.999':u label "По документу"
  field fact-qnty     as decimal   format '->>>,>>>,>>9.999':u label "Факт"
  field prt-free-qnty as decimal   format '->>>,>>>,>>9.999':u label "Свободно"
  field prt-fact-qnty as decimal   format '->>>,>>>,>>9.999':u label "Факт остаток"
  field price-base    as decimal   format '>>>,>>>,>>9.99':u   label "Цена документа (вал.)"
  field price-rubl    as decimal   format '>>>,>>>,>>9.99':u   label "Цена документа ({&abbr_rub}.)"
  field price-sale    as decimal   format '>>>,>>>,>>9.99':u   label "Текущая цена"
  field prt-level     as integer                               label "Уровень"
  field show-list     as logical                               label "Структура"
  field show-prt      as logical                               label "Движение на объекте"
  field show-rest     as logical                               label "Есть остатки"
  field show-doc      as logical                               label "Документ"

  index xpk is primary unique node-code
  index xie1 sort-code
  index xie2 show-rest
  index xie3 show-prt
  index xie4 show-list
.


/* $Workfile$ */