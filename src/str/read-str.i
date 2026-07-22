/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

разделение строки файла на код, количество и код места; подготовка кода к распознаванию

Автор: Чернова Светлана Александровна
Дата создания: 03/24/08
Author: Svetlana Chernova
Creation date: 03/24/08

Автор1: Суслов Алексей Юрьевич
Дата создания: 04/12/06

*/

procedure read-str.
/* -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   разделение строки файла на код, количество и код места; подготовка кода к распознаванию
   -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- */
  bar-str = trim (bar-str).
  if bar-str = "" then return error.
  if substr (bar-str, 1, 1) < "0" or substr (bar-str, 1, 1) > "9" then
    if substr (bar-str, 1, 4) = "data" then bar-str = entry (2, bar-str, ":").
    else return error "Cтрока начинается не с цифры и не со слова date.".
  if num-entries (bar-str) > 1 then qnty-str = trim (entry (2, bar-str)).
  else qnty-str = "1".
  if num-entries (bar-str) > 2 then pl-str = trim (entry (3, bar-str)).
  else pl-str = "".
  bar-str = trim (entry (1, bar-str)).
end procedure.
