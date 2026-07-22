block-level on error undo, throw.

/*------------------------------------------------------------------------
$Revision: a8e2cf75ddf6, 2506, rls $
$Author: EShklyar $
$Date: Ср июл 08 17:09:06 2020 +0300 $
$Workfile: p-licsu.p $
$Archive: ref/p-licsu.p $

Печать Лицензии на поставку алкогольной продукции

Автор: Шутилов Арнольд Валерьевич
Дата создания: 20/04/15
Author: Shutilov Arnold
Creation date: 20/04/15
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
define input parameter parparentproc    as widget-handle no-undo.
define input parameter p-cli-type       like ub.alc-supp-lic.cli-type no-undo.
define input parameter p-cli-code       like ub.alc-supp-lic.cli-code no-undo.

define variable vss-revision    as character no-undo init "$Revision: a8e2cf75ddf6, 2506, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Ср июл 08 17:09:06 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: p-licsu.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/p-licsu.p $":U .
define variable vss-description as character no-undo init "Печать Лицензии на поставку алкогольной продукции".
{ cmp/vssrevis.i }
{ cmp/r-pril.i new }

define variable v-full-path-RepView as character no-undo.   /* Полный путь к файлу Просмотровщика (отчётов) */
define variable v-file-name-rep-htm as character no-undo.   /* Полный путь к файлу отчёта */
define variable g#report-num as integer no-undo.            /* Номер отчёта (получим стандартной процедурой ТН) */

define buffer buf_alc-supp-lic for alc-supp-lic.
define buffer br_clients for clients.

define stream OutStr-html.
/* ******************************************************************** */
/* ************************  Function Implementations  **************** */
function fnc-DD-MM-YYYY returns character 
(input p-dat-date as date) forward.

function fnc-convert-dot-to-colon returns character 
(input p-data as decimal, p-accur as character) forward.
/* ***************************************  Function Implementations  * */
/* ********************  Preprocessor Definitions  ******************** */
/* ***************************************  Preprocessor Definitions  * */
/* ***************************  Main Block  *************************** */

    run get-full-path-RepViewer(output v-full-path-RepView).    /* Перед работой с "Просмотровщиком отчёта" (main.exe) - убедимся, что он существует и получим полный путь к нему. */

    run get-report-num in parParentProc(output g#report-num).   /* Получим СТАНДАРТНЫМ МЕТОДОМ ТН номер файла отчёта. */

    run define-full-path-Report(input g#report-num, output v-file-name-rep-htm).   /* Сформируем стандартизованное в ТН имя файла отчёта. */

    run create-file(v-file-name-rep-htm).   /* Создадим на диске пустой файл со сформированным по стандарту именем файла. */

    run proc-create-HTML(input v-file-name-rep-htm, input p-cli-type, input p-cli-code).

    run Report-Viewer(input v-full-path-RepView, input v-file-name-rep-htm). /* Запуск просмотровщика отчёта RepViewer */

/* *****************************************************  Main Block  * */
/* ********************  Procedures and Functions  ******************** */
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

os-command no-wait value(p-full-path-RepView + " true " + search(p-file-name-rep-htm)).

end procedure.

procedure create-file:
/* Создание пустого файла (во входном параметре: полный путь и имя файла) */
    define input parameter p-file-name as character no-undo.
    output to value(string(p-file-name)).
    output close.

end procedure.

procedure proc-create-HTML:
/* Вывод отчёта в файл html и через ReportView в Excel */

    define input parameter p-file-name-rep-htm as character no-undo.
    define input parameter p-cli-type like ub.alc-supp-lic.cli-type no-undo.
    define input parameter p-cli-code like ub.alc-supp-lic.cli-code no-undo.

    /* Системная шапка HTML */
    do:  /* Системная шапка HTML */
        output stream OutStr-html to value(p-file-name-rep-htm) append convert target 'UTF-8'.
            put stream OutStr-html unformatted
                "<!DOCTYPE HTML>" skip
                ' <html>' skip
                '  <head>' skip
                '   <meta charset="utf-8">' skip
                '    <style type="text/css">' skip
                '      table ' + chr(123) + ' border-collapse: collapse; font-size: 9pt; table-layout: fixed; width: 1157px; padding: 14px; ' + chr(125) skip
                '      td ' + chr(123) ' border: 1px black ridge; word-wrap:break-word; ' + chr(125) skip
                '      htm' skip
                '      .rotate ' + chr(123) skip
                '        -webkit-transform: rotate(-90deg);' skip
                '        -moz-transform: rotate(-90deg);' skip
                '        -ms-transform: rotate(-90deg);' skip
                '        -o-transform: rotate(-90deg);' skip
                '        transform: rotate(-90deg);' skip

                /* also accepts left, right, top, bottom coordinates; not required, but a good idea for styling */
                '        -webkit-transform-origin: 50% 50%;' skip
                '        -moz-transform-origin: 50% 50%;' skip
                '        -ms-transform-origin: 50% 50%;' skip
                '        -o-transform-origin: 50% 50%;' skip
                '        transform-origin: 50% 50%;' skip

                /* Should be unset in IE9+ I think.*/
                '        filter: progid:DXImageTransform.Microsoft.BasicImage(rotation=3);' skip
                '          ' + chr(125) skip
                '            th' + ' ' + chr(123) skip
                '            border: 1px black solid;' skip
                '            word-wrap: break-word;' skip
                '          ' + chr(125) skip
                '   </style>' skip
                '  </head>' skip
            . /* Точка для закрытия Put */
    end. /* Системная шапка HTML */

    /* Установка системных параметров "глобальной" таблицы всего отчёта (кол-во и размерность колонок) */
    do:  /* Параметры "глобальной" таблицы отчёта */
            put stream OutStr-html unformatted
                ' <body>' skip
                '   <table name="Лист1" outline_below="false">' skip
                '     <thead>' skip
                '       <tr class="set_columns">' skip                          /* Ниже - условная привязка-ориентир - разграфлённая таблице. */
                '         <td style="width: 150px; border: none;"></td>' skip   /* 1. "Поставщик" */
                '         <td style="width: 70px; border: none;"></td>' skip   /* 2. "с" */
                '         <td style="width: 70px; border: none;"></td>' skip    /* 3. "по" */
                '         <td style="width: 70px; border: none;"></td>' skip    /* 4. "Номер" */
                '         <td style="width: 70px; border: none;"></td>' skip    /* 5. "Серия" */
                '         <td style="width: 70px; border: none;"></td>' skip    /* 6. "Дата выдачи" */
                '         <td style="width: 80px; border: none;"></td>' skip    /* 7. "Кем выдана" */
                '         <td style="width: 43px; border: none;"></td>' skip    /* 8. "На все типы" */
                '       </tr>' skip
            . /* Точка для закрытия Put */
    end. /* Параметры "глобальной" таблицы отчёта */

    /* Заполнение "глобальной" таблицы - блок шапки отчёта (часть отчёта, видимая как "не таблица") */
    do:  /* Шапка отчёта (видимого, как не таблица) */
            put stream OutStr-html unformatted
                '       <tr>' skip /* Строчный пункт-1. Пустая строка */
                '         <td style="border: none; height: 14px"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '       </tr>' skip
                '       <tr>' skip /* Строчный пункт-2. Наименование отчёта */
                '         <td colspan="8" style="border: none; height: 14px; font-weight: bold; text-align: center">' + "Справочник Лицензий на поставку алкогольной продукции" + '</td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '       </tr>' skip
                '       <tr>' skip /* Строчный пункт-4. Пустая строка */
                '         <td style="border: none; height: 14px; font-weight: bold"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '       </tr>' skip
            .
    end. /* Шапка отчёта (видимого, как не таблица) */

    /* Заполнение "глобальной" таблицы - блок Шапки таблицы отчёта (часть отчёта, видимая как "шапка таблицы") */
    do:  /* Шапка таблицы отчёта (видимой, как таблица) */
        put stream OutStr-html unformatted
                '     <tbody>' skip
                '       <tr>' skip
                '         <th style="text-align: center; height: 30px">Поставщик</th>' skip
                '         <th style="text-align: center;">с</th>' skip
                '         <th style="text-align: center;">по</th>' skip
                '         <th style="text-align: center;">Номер</th>' skip
                '         <th style="text-align: center;">Серия</th>' skip
                '         <th style="text-align: center;">Дата выдачи</th>' skip
                '         <th style="text-align: center;">Кем выдана</th>' skip
                '         <th style="text-align: center;">На все типы</th>' skip
                '       </tr>' skip
                '       <tr>' skip
                '         <th num="" style="text-align: center">1</th>' skip
                '         <th num="" style="text-align: center">2</th>' skip
                '         <th num="" style="text-align: center">3</th>' skip
                '         <th num="" style="text-align: center">4</th>' skip
                '         <th num="" style="text-align: center">5</th>' skip
                '         <th num="" style="text-align: center">6</th>' skip
                '         <th num="" style="text-align: center">7</th>' skip
                '         <th num="" style="text-align: center">8</th>' skip
                '       </tr>' skip
        .
        output stream OutStr-html close.
    end. /* Шапка таблицы отчёта (видимой, как таблица) */

    /* Заполнение тела таблицы отчёта */
    do:  /* b5 */
        output stream OutStr-html to value(p-file-name-rep-htm) append convert target 'UTF-8'.
        if p-cli-type = ? or p-cli-code = ? then
        do:  /* Лицензии на поставку алкоголя по всем клиентам */
            for each buf_alc-supp-lic no-lock
            ,
                first br_clients where
                      br_clients.obj-type = buf_alc-supp-lic.cli-type and
                      br_clients.obj-code = buf_alc-supp-lic.cli-code
                no-lock.

                do:
                    put stream OutStr-html unformatted
                        '       <tr>' skip
                        '         <td style="display: yes; text-align: left; height: 20px; font-weight: normal">' + (if br_clients.obj-name = ? then "" else br_clients.obj-name) + '</td>' skip
                        '         <td style="display: yes; text-align: center; font-weight: normal">' + (if buf_alc-supp-lic.date-from <> ? then fnc-DD-MM-YYYY(buf_alc-supp-lic.date-from) else "?") + '</td>' skip
                        '         <td style="display: yes; text-align: center; font-weight: normal">' + (if buf_alc-supp-lic.date-to <> ? then fnc-DD-MM-YYYY(buf_alc-supp-lic.date-to) else "?") + '</td>' skip
                        '         <td style="display: yes; text-align: left; font-weight: normal">' + (if buf_alc-supp-lic.number <> ? then buf_alc-supp-lic.number else "?") + '</td>' skip
                        '         <td style="display: yes; text-align: left; font-weight: normal">' + (if buf_alc-supp-lic.seria <> ? then buf_alc-supp-lic.seria else "?") + '</td>' skip
                        '         <td style="display: yes; text-align: center; font-weight: normal">' + (if buf_alc-supp-lic.date-get <> ? then fnc-DD-MM-YYYY(buf_alc-supp-lic.date-get) else "?") + '</td>' skip
                        '         <td style="display: yes; text-align: left; font-weight: normal">' + (if buf_alc-supp-lic.who-are-got <> ? then buf_alc-supp-lic.who-are-got else "?") + '</td>' skip
                        '         <td style="display: yes; text-align: center; font-weight: normal">' +
                                    (if buf_alc-supp-lic.all-type <> ? then (if buf_alc-supp-lic.all-type > 0 then "+" else "-") else "?") + '</td>' skip
                        '       </tr>' skip
                    .
                end.
            end. /* for each buf_alc-supp-lic */
        end. /* Лицензии на поставку алкоголя по всем клиентам */
        else
        do:  /* Лицензии на поставку алкоголя по заданным пользователем клиентам */
            for each buf_alc-supp-lic where
                     buf_alc-supp-lic.cli-type = p-cli-type and
                     buf_alc-supp-lic.cli-code = p-cli-code no-lock
            ,
                first br_clients where
                      br_clients.obj-type = p-cli-type and
                      br_clients.obj-code = p-cli-code
                no-lock.
                    put stream OutStr-html unformatted
                        '       <tr>' skip
                        '         <td style="display: yes; text-align: left; height: 20px; font-weight: normal">' + (if br_clients.obj-name = ? then "" else br_clients.obj-name) + '</td>' skip
                        '         <td style="display: yes; text-align: center; font-weight: normal">' + (if buf_alc-supp-lic.date-from <> ? then fnc-DD-MM-YYYY(buf_alc-supp-lic.date-from) else "?") + '</td>' skip
                        '         <td style="display: yes; text-align: center; font-weight: normal">' + (if buf_alc-supp-lic.date-to <> ? then fnc-DD-MM-YYYY(buf_alc-supp-lic.date-to) else "?") + '</td>' skip
                        '         <td style="display: yes; text-align: left; font-weight: normal">' + (if buf_alc-supp-lic.number <> ? then buf_alc-supp-lic.number else "?") + '</td>' skip
                        '         <td style="display: yes; text-align: left; font-weight: normal">' + (if buf_alc-supp-lic.seria <> ? then buf_alc-supp-lic.seria else "?") + '</td>' skip
                        '         <td style="display: yes; text-align: center; font-weight: normal">' + (if buf_alc-supp-lic.date-get <> ? then fnc-DD-MM-YYYY(buf_alc-supp-lic.date-get) else "?") + '</td>' skip
                        '         <td style="display: yes; text-align: left; font-weight: normal">' + (if buf_alc-supp-lic.who-are-got <> ? then buf_alc-supp-lic.who-are-got else "?") + '</td>' skip
                        '         <td style="display: yes; text-align: right; font-weight: normal">' +
                                    (if buf_alc-supp-lic.all-type <> ? then (if buf_alc-supp-lic.all-type > 0 then "+" else "-") else "?") + '</td>' skip
                        '       </tr>' skip
                    .
            end. /* for each buf_alc-supp-lic */
        end. /* Лицензии на поставку алкоголя по заданным пользователем клиентам */
    end. /* b5 */

    /* Заполнение подвала отчёта */
    do:  /* b6 */
                put stream OutStr-html unformatted
                '     </tbody>' skip
                '   </table>' skip
                '  </body>' skip
                ' </html>' skip
                . /* Точка для закрытия Put */
        output stream OutStr-html close.
    end. /* b6 */
end procedure. /* proc-create-HTML */

function fnc-convert-dot-to-colon returns character 
(input p-data as decimal, input p-accur as character):
/* Конвертация десятичной точки в запятую с передачей параметра форматирования числа (accuracy - точность) */

    define variable result as character no-undo.
    define variable v-str-result as character no-undo.
/*message "dbg-p-data = " p-data skip "p-accur = " p-accur view-as alert-box.*/
    p-data = round(p-data, 2). /* Чтобы не выйти случайно за рамки формата числа при выводе (несоотвесвие формата результата и формата отображения - приводит к ош) */
    v-str-result = trim(replace(string(p-data, p-accur), ".", ",")).

    return v-str-result.

end function.

function fnc-DD-MM-YYYY returns character 
(input p-dat-date as date):
/* Преобразование даты в формат: "01.01.2014" */

    define variable result as character no-undo.
    define variable p-str-date as character no-undo.

    p-str-date = replace(string(p-dat-date,'99.99.9999'), "/", ".").

        return p-str-date.

end function.
/* ***************************************  Procedures and Functions  * */
