block-level on error undo, throw.
/*

$Revision: 8f5f559ebdb3, 2359, rls $
$Author: EShklyar $
$Date: Ср июн 10 21:13:34 2020 +0300 $
$Workfile: errors-inv.p $
$Archive: rep/errors-inv.p $

Не все товары загружены в документ инвентаризации
Автор: Шкляр Елена
Дата создания: 10/18/05
Author: Shklyar Elena
Creation date: 10/18/05

*/
define temp-table tt-gds-line-err no-undo 
    field artic       as character
    field gds-name    as character
    field prod-code   as integer
    field prod-type   as character
    field date-report as date
    field time-report as INTEGER
    field qnty-tsd    as decimal
    index pi artic prod-code prod-type.

define input parameter parparentproc    as handle no-undo .
define input parameter table for tt-gds-line-err .


define variable vss-revision    as character no-undo init "$Revision: 8f5f559ebdb3, 2359, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Ср июн 10 21:13:34 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: errors-inv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/errors-inv.p $":U .
define variable vss-description as character no-undo init "Не все товары загружены в документ инвентаризации".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ rep/html-conv.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }


define variable v-full-path-RepView as character no-undo.   /* Полный путь к файлу Просмотровщика (отчётов) */
define variable v-file-name-rep-htm as character no-undo.   /* Полный путь к файлу отчёта */
define variable g#report-num        as integer   no-undo.            /* Номер отчёта (получим стандартной процедурой ТН) */
define variable v-report-name       as character no-undo.         /* Наименование отчёта */
define variable v-period            as character no-undo.              /* Период за который формируется отчёт */
define stream OutStr-html.

run get-full-path-RepViewer(output v-full-path-RepView).    /* Перед работой с "Просмотровщиком отчёта" (main.exe) - убедимся, что он существует и получим полный путь к нему. */

run get-report-num in parParentProc(output g#report-num).   /* Получим СТАНДАРТНЫМ МЕТОДОМ ТН номер файла отчёта. */

run define-full-path-Report(input g#report-num, output v-file-name-rep-htm).   /* Сформируем стандартизованное в ТН имя файла отчёта. */

run create-file(v-file-name-rep-htm).   /* Создадим на диске пустой файл со сформированным по стандарту именем файла. */


run waitfram-show in this-procedure ("Подождите ...").

&scoped-define css_page1tit      text-align:center; font-weight:bold;
&scoped-define css_align_righit  text-align:right; padding-right:4px;
&scoped-define css_align_center  text-align:center;
&scoped-define css_table_border  border-style:solid; border-width:thin;
&scoped-define css_cell_border   border: 1px solid black;
&scoped-define css_border_bottom border-bottom: 1px solid black;

output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8' .


/* Системная шапка HTML */
put stream OutStr-html unformatted
    "<!DOCTYPE HTML>" skip
    ' <html>' skip
    '  <head>' skip
    '   <meta charset="utf-8">' skip
    '    <style type="text/css">' skip
    '      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
    '      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
    '      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black; height: 14px;' + chr(125) skip
    '   </style>' skip
    '  </head>' skip
    .

put stream OutStr-html unformatted
    '<body>' skip
    '<TABLE name="zakaz"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
    '<thead>' skip
    .
put stream OutStr-html unformatted
    '<tr class="set_columns">' skip
    '<td style="width: 500px;"></td>' skip
    '</tr>' skip
    .
for each tt-gds-line-err:
    put stream OutStr-html unformatted
        '<tr>' skip
        '<td style="text-align: left;">' + string (tt-gds-line-err.date-report,"99/99/9999") + " " + string (tt-gds-line-err.time-report,"HH:MM:SS") + ' Ошибка при загрузке в инвентаризацию товара: ' + string (tt-gds-line-err.gds-name) + ' Артикул: ' + string (tt-gds-line-err.artic) + ' кол-во: ' + string (tt-gds-line-err.qnty-tsd) + '</td>' skip
        '</tr>' skip
        .
end.
put stream OutStr-html unformatted 
    '</thead>' skip
    '</table>' skip
    '</body>' skip
    '</html>' skip
    .


run prn-lib-reportviewer-report-name in this-procedure (
    input THIS-PROCEDURE
    ,input v-file-name-rep-htm
    ).

procedure get-full-path-RepViewer:
    /* Получение полного пути к exe-файлу просмотровщика отчётов */
    define output parameter p-fill-path-RepView as character no-undo.

    if search("exe\ReportViewer\reportviewer.exe") <> ? then
    do:
        p-fill-path-RepView = search("exe\ReportViewer\reportviewer.exe").
    end.
    else
    do:
        message "Не найдена программа просмотра отчёта!" view-as alert-box error.
    end.
end procedure.

procedure define-full-path-Report:
    /* Получение полного пути к отчёту html */
    define input parameter p-rep-num as integer no-undo.
    define output parameter p-file-name-rep-htm as character no-undo.

    p-file-name-rep-htm = session:temp-directory + {&DF_Name} + string(p-rep-num) + ".html".

end procedure.

procedure search-full-path-Report:
    /* Поиск файла */
    define input parameter p-file-name as character no-undo.

    if search(p-file-name) = ? then
    do:
        message "Не найден файл отчёта: " p-file-name view-as alert-box error.
    end.
    else
    do:
        p-file-name = search(p-file-name).
    end.

end procedure.

procedure Report-Viewer:
    /* Запуск программы "Просмотровщик Отчётов" - ReportViewer. */
    define input parameter p-full-path-RepView as character no-undo.
    define input parameter p-file-name-rep-htm as character no-undo.

    os-command no-wait value(p-full-path-RepView + " " + search(p-file-name-rep-htm)).

end procedure.

procedure create-file:
    /* Создание пустого файла (во входном параметре: полный путь и имя файла) */
    define input parameter p-file-name as character no-undo.
    output to value(string(p-file-name)).
    output close.

end procedure.

