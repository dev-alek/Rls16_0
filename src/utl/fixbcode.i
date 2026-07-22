/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Установка sequence {1} внутрь активного диапазона

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/23/01
Author: Dmitry Ukhanov
Creation date: 03/23/01

*/

assign
  v-old-value = current-value({1}, {&db-name_schema})
  v-new-value = max(buf_code-range.first-code, v-b-code)
.

if v-new-value = v-old-value then do:
  message
    "Значение sequence {1} находится внутри активного диапазона" skip
    "и не требует коррекции" skip
    "Текущее значение" v-old-value skip
    "Новое значение" v-new-value skip
    view-as alert-box information .

end.
else do:
  message
    "Вы хотите откорректировать значение sequence {1}?" skip
    "Текущее значение" v-old-value skip
    "Новое значение" v-new-value skip
    view-as alert-box question buttons yes-no update lok .
  if lok = true then do:
    assign
      current-value({1}, {&db-name_schema}) = v-new-value
    .
  end.
end.

/* $Workfile$ e n d */