block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: df_price.p $
$Archive: utl/df_price.p $

Процедура поиска всех полей, которые хранят денежные суммы.

Автор: Чернова Светлана Александровна
Дата создания: 02/27/08
Author: Svetlana Chernova
Creation date: 02/27/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 02/06/00

Признаком денежной суммы является наличие первого знака $ в описании поля.
Генерируется *.df файл, который можно использовать для закачивания в базу данных,
для деноминации форматов.

Формальные критерии выбираемых полей:
  Поле имеет тип decimals
  Более одного знака после запятой
  Первый символ описания знак доллара "$"

Примеры из сгенерированного *.df файла:

UPDATE FIELD "credit-base" OF "an-c-month"
# DESCRIPTION "$Обороты по кредиту в базовой валюте"
# DECIMALS 2
# FORMAT "->>,>>>,>>>,>>>,>>9.99"
  FORMAT "->,>>>,>>>,>>>,>>>,>>9"

UPDATE FIELD "credit-curr" OF "an-c-month"
# DESCRIPTION "$Обороты по кредиту в валюте"
# DECIMALS 2
# FORMAT "->>,>>>,>>>,>>>,>>9.99"
  FORMAT "->,>>>,>>>,>>>,>>>,>>9"

UPDATE FIELD "credit-rubl" OF "an-dpt-mnth"
# DESCRIPTION "$"
# DECIMALS 2
# FORMAT "->,>>>,>>>,>>>,>>9.99"
  FORMAT "-,>>>,>>>,>>>,>>>,>>9"

UPDATE FIELD "debet-base" OF "an-dpt-mnth"
# DESCRIPTION "$"
# DECIMALS 2
# FORMAT "->>>,>>>,>>9.99"
  FORMAT "->>,>>>,>>>,>>9"

UPDATE FIELD "debet-rubl" OF "an-dpt-mnth"
# DESCRIPTION "$"
# DECIMALS 2
# FORMAT "->,>>>,>>>,>>>,>>9.99"
  FORMAT "->>>>,>>>,>>>,>>>,>>9"

*/

{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ gbl/waitfram.i }

define variable v-new-format as character no-undo .
define variable l-ok  as logical no-undo .
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.

message
  "Вы хотите сгенерировать файл изменения форматов БД" skip
  "для деноминации сумм." skip
  view-as alert-box question buttons yes-no update l-ok .
if l-ok <> true then do:
  return . /* --->>>--- */
end.

output to price.df .
run cur-time in this-procedure ( output v-today
                               , output v-time
                               ).
put unformatted
  '# Файл деноминации полей, хранящих денежные суммы' + {&new-line}
  '# !!!! Внимание !!!!' + {&new-line}
  '# Данный файл сгенерирован автоматически при помощи программы df_price.p' + {&new-line}
  '# Дата  ' + string(v-today, "99/99/9999") + {&new-line}
  '# Время ' + string(v-time, "hh:mm") + {&new-line}
  + {&new-line}
.
output close .

run waitfram-show in this-procedure
  (input "Анализ структуры БД"
  ) .

for each _File no-lock
  where not _File._Hidden
:

  run waitfram-show in this-procedure
    (input "Анализ таблицы " + string(_File._File-Name, "x(40)") + "."
    ).

  /* Рассматриваем только поля у которые имеют тип decimals,
     более одного знака после запятой
     и первый символ описания знак доллара "$"
     */
  field-block:
  for each _Field of _File no-lock
    where _Field._Decimals > 0
      and substring(_Field._Desc, 1, 1) = "$"
  :
    define variable ind as integer no-undo .

    run process-format
      (input _Field._Format
      ,output v-new-format
      ).

    output to price.df append .
    put unformatted
      'UPDATE FIELD "' + _Field._Field-Name + '" OF "' + _File._File-Name + '"' + {&new-line}
      '# DESCRIPTION "' + _Field._Desc + '"' + {&new-line}
      '# DECIMALS ' + STRING(_Field._Decimals) + {&new-line}
      '# FORMAT "' + _Field._Format + '"' + {&new-line}
      '  FORMAT "' + v-new-format + '"' + {&new-line}
      + {&new-line}
    .
    output close .
  end.
end.

run waitfram-hide in this-procedure .


procedure process-format :
  define input  parameter p-format as character no-undo .
  define output parameter p-new-format as character no-undo .

  define variable l-minus-sign as logical no-undo .
  define variable v-length as integer no-undo .

  if substring(p-format, 1, 1 ) = '-' then do:
    assign
      l-minus-sign = true
      v-length     = length(p-format) - 1
    .
  end.
  else do:
    assign
      l-minus-sign = false
      v-length     = length(p-format)
    .
  end.

  define variable v-base-format as character no-undo .

  assign
    v-base-format = fill(">>>,", 20) + ">>9"
  .

  assign
    p-new-format = substring( v-base-format, length(v-base-format) - v-length + 1, v-length )
  .

  if substring(p-new-format, 1, 1 ) = "," then do:
    assign
      overlay(p-new-format, 1, 1) = ">"
    .
  end.

  assign
    p-new-format = (if l-minus-sign then "-" else "" ) + p-new-format
  .

  if length (p-new-format) <> length(p-format) then do:
    message
      "Warning different formats" skip
      "p-format"      p-format     skip
      "p-new-format"  p-new-format skip
      view-as alert-box .
  end.

end procedure. /* process-format */

message
  "Создание файла для деноминации форматов завершено" skip
  "Файл price.df." skip
  view-as alert-box information .