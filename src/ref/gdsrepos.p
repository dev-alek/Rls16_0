block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gdsrepos.p $
$Archive: ref/gdsrepos.p $

mess для Справочник товаров.

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

DEFINE INPUT PARAMETER pcase as integer no-undo.
DEFINE INPUT PARAMETER g-cond as char no-undo.
DEFINE INPUT PARAMETER g-list as char no-undo.
DEFINE INPUT PARAMETER g-stat as char no-undo.
DEFINE INPUT PARAMETER flt-rec as recid no-undo.
DEFINE OUTPUT PARAMETER loc#log as logical no-undo.
DEFINE OUTPUT PARAMETER loc-contin as logical no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gdsrepos.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/gdsrepos.p $":U .
define variable vss-description as character no-undo init "mess для Справочник товаров.".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

DEFINE VARIABLE choice as integer no-undo.

CASE pcase:
  WHEN 1 then do:
    loc#log = yes.
    if flt-rec <> ? then do:
      loc#log = no.
      message "Поиск ПО ВСЕМ товарам." skip(1)
      "ТОВАР НАЙДЕН." skip (2)
      "Но фильтр по кнопке <<ФИЛЬТР>> : включен"
      " - поэтому найденный товар не виден." skip (2)
      "Выключите фильтр"
      view-as alert-box Warning.
    end.
    else do:
      message "Поиск ПО ВСЕМ товарам." skip(1)
      "ТОВАР НАЙДЕН." skip (2)
      "Но сейчас включено : " skip
      "Справочник : " g-list skip
      "Статус : " g-stat skip
      "Фильтр Все/Объект/Факт/Свободно: " g-cond skip
      " - поэтому найденный товар не виден." skip (2)
      "Переключить" skip
      "Справочник, Статус и Фильтр в положение 'Все' ?"
      view-as alert-box question buttons OK-Cancel update loc#log.
    end.
  END. /*when 1*/
  WHEN 2 then do:
    loc-contin = yes.
    if flt-rec <> ? then do:
      loc-contin = no.
      message "Поиск ПО ВСЕМ товарам." skip(1)
      "ТОВАР НАЙДЕН." skip (2)
      "Но фильтр по кнопке <<ФИЛЬТР>> : включен" skip
      " - поэтому найденный товар не виден." skip (2)
      "Выключите фильтр"
      view-as alert-box Warning.
      loc-contin = ?.
    end.
    else do:
      run gbl/d-askw.w (input "Поиск ПО ВСЕМ товарам",
                   input ("ТОВАР НАЙДЕН ." + {&new-line} + {&new-line} + "Но сейчас включено :" + {&new-line} +
                          "Справочник : " + g-list + {&new-line} + "Статус : " + g-stat +
                          {&new-line} + "Фильтр : " + g-cond + {&new-line} + " - поэтому найденный товар не виден."
                          ),
                   input "|",
                   input ("Продолжать искать|Переключить Справочник, Статус и Фильтр в положение ВСЕ|Отменить"),
                   Input "||",
                   input 2,
                   input 3,
                   output choice).
      if choice = 1 then loc-contin = yes.
      else if choice = 2 then loc-contin = no.
      else loc-contin = ?.
    end.

  END.
END CASE.



















