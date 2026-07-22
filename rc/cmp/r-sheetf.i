&if "{1}" = "class"
&then
method public void get-Sheetf (output table Sheetf):
end.
method public void set-Sheetf (input table Sheetf):
end.
&else
define {1} {2} temp-table Sheetf no-undo  /* форматы отдельных листов */
field Excel-Column-Lable as character      /* список названий полей , через запятую - {&new-line} новая строка*/
field Excel-Row-Heder    as integer      /* Количество строк под заголовок */
field Excel-Row-Title    as integer      /* Количество строк под шапку */
field Sizes              as character      /* spisok размеров полей в Excel */
field Make-correct       as character      /* spisok полей "true,false" которые доступны для корректировки названия или возможности печати */
field Rights-column      as character      /* spisok полей "true,false" которые доступны для корректировки названия или возможности печати */
field MergeCellsH        as character      /* spisok правил для объединения ячеек в Excel по горизонт*/
field MergeCellsV        as character      /* spisok правил для объединения ячеек в Excel по вертикали*/
field sheet-num          as integer  /* номер листа*/
field ColFormat          as character /*формат колонок для каждого листа в виде 1=format1;3=format3 и т.д.*/
field Bas-FIle           as character /*имя файла содержащего EXcel макросы */
field Bas-Params         as character /*параметры для вызова главного Excel макроса - он потому вызвать остальные */
field Bas-Param-Add      as logical   /* передавать доп. параметры */
field File-name          as character /* имя файла для сохранения */
field Silent-save        as logical   /* флаг - сохранять без диалогового окна в файл File-name (ИМЯ берется с первого листа!!!)*/
index pi as primary unique
      sheet-num
.
&endif