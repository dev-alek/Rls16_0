/*
$Revision: $
$Author: EShklyar $
$Date: Ср июл 08 17:09:06 2020 +0300 $
$Workfile: r-xldln2.p $
$Archive: rep/r-xldln2.p $

r-Отчет по типам скидки (карты ЛНР).

Автор: Шутилов Арнольд Валерьевич
Дата создания: 02/12/14
Author: Shutilov Arnold
Creation date: 02/12/14
*/

/* ***************************  Definitions  ************************** */
using Progress.Lang.*.
using Ibs.Th.Gbl.ReportXml.
using Ibs.Th.Gbl.rep-out.
block-level on error undo, throw.
define input parameter parParentProc as handle no-undo.
define input parameter p-cb-disType as character no-undo.

def var vss-revision    as character no-undo init "$Revision: a8e2cf75ddf6, 2506, rls $":U .
def var vss-author      as character no-undo init "$Author: EShklyar $":U .
def var vss-date        as character no-undo init "$Date: Ср июл 08 17:09:06 2020 +0300 $":U .
def var vss-workfile    as character no-undo init "$Workfile: r-xldln2.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/r-xldln2.p $":U .
def var vss-description as character no-undo init "r-Отчет по типам скидки (карты ЛНР)".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i }
{ cmp/r-pril.i new } /* ТН-3320. 2014г. Арн. Здесь берём {&DF_Name}*/

define variable xml_tmp as character no-undo. /* путь к временному файлу */
define variable Report as class ReportXml no-undo. /* Переменная под класс */
define variable gds-str as character no-undo init "".
define variable xslt-path as character no-undo. /* путь к шаблону */
define variable rep-out-unit as class rep-out no-undo. /* экземпляр класса формирования документа отчёта */
define variable v-total-qnty as decimal no-undo.
define variable v-total-sum1 as decimal no-undo.
define variable v-total-sum2 as decimal no-undo.

define variable v-cnt as integer no-undo.
define variable v-cnt2 as integer no-undo.
define variable g#report-num as integer no-undo.
define variable v-full-path-RepView as character no-undo. /* Полный путь к файлу Просмотровщика (отчётов) */
define variable v-file-name-rep-htm as character no-undo. /* Полный путь к файлу отчёта */
define variable v-choice-gds as character no-undo. /* Список выбранных товаров. Вывод - в шапке отчёта */
define variable v-type-discount as character no-undo. /* Выбранный пользователем параметр "Тип скидки" (в окне параметров). Вывод в шапке отчёта */
define variable v-choice-obj as character no-undo. /* Выбранный пользователем параметр "Выбор объекта" (в окне параметров). Вывод в шапке отчёта */

define temp-table tt-line no-undo
    field chk-date as date          /*Дата чека*/
    field chk-time as integer       /*Время*/
    field d-card as character       /*Номер карты*/
    field pay-desk as integer       /*№ кассы*/

    field obj-name as character     /*Объект. Имя*/
    field obj-type as character     /*Объект. Тип*/
    field obj-code as integer       /*Объект. Код*/

    field b-code like chk-gds-pay.b-code /* Баркод (номер) */
    field grp-code like ub.goods.grp-code /* Группа родителя (применительно к Группе товаров) */
    field grp-lvl as integer        /* Уровень группы относительный. */
    field upper-code like gds-grp.upper-code /* Группа родительская(применительно к Группе товаров) */
    field gds-name as character     /*Товар*/
    field eff-doc-qnty as decimal   /*Количество*/
    field object-sum as decimal     /*Сумма без скидки*/
    field discount as decimal       /*Скидка*/
    field tot-r-b as decimal        /*Сумма со скидкой*/
    field line-type as character
    field doc-code as character
    field type-line as character

    index pi is primary obj-type obj-code 
    index bcode b-code
    index grp_lvl       grp-lvl
    index upper_code    upper-code
.

define stream OutStr-html.

/* ************************  Function Implementations ***************** */

function fnc-DD-MM-YYYY returns character 
(input p-dat-date as date) forward.

function fnc-convert-dot-to-colon returns character 
(input p-data as decimal, p-accur as character) forward.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
    run my-report.


/* **********************  Internal Procedures  *********************** */

procedure create-file:
/* Создание пустого файла (во входном параметре: полный путь и имя файла) */
    define input parameter p-file-name as character no-undo.
    output to value(string(p-file-name)).
    output close.

end procedure.

procedure define-full-path-Report:
/* Получение полного пути к */
    define input parameter p-rep-num as integer no-undo.
    define output parameter p-file-name-rep-htm as character no-undo.

    p-file-name-rep-htm = session:temp-directory + {&DF_Name} + string(p-rep-num) + ".html".

end procedure.

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


procedure my-report:
/*******************/

    run get-full-path-RepViewer(output v-full-path-RepView).    /* Перед работой с "Просмотровщиком отчёта" (main.exe) - убедимся, что он существует и получим полный путь к нему. */

    run get-report-num in parParentProc(output g#report-num).   /* Получим стандартным методом ТН номер файла отчёта. */

    run define-full-path-Report(input g#report-num, output v-file-name-rep-htm).   /* Сформируем стандартизованное в ТН имя файла отчёта. */

    run create-file(v-file-name-rep-htm).   /* Создадим на диске пустой файл со сформированным по стандарту именем файла. */

    define variable v-type as integer no-undo.
    v-type = if p-cb-disType = '1' then integer({&discnt-t-cashLoyal}) else integer({&discnt-t-bonusCard}).

    for each tt-line no-lock:
        delete tt-line.
    end.

    for each obj-list no-lock:

        /*НАДО УБЕДИТЬСЯ ЧТО ВСЕ РАЗМАЗАНО!!*/
         run rep/rpychk0.p (input "r-shftc2"
                        ,input obj-list.obj-type
                        ,input obj-list.obj-code
                        ,input ?                    /*p-date-from*/
                        ,input ?                    /*p-date-to*/
                        ,input X-date-start         /*p-shift-date-from*/
                        ,input X-date-end           /*p-shift-date-to*/
                        ,input 1                    /*p-shift-num-start*/
                        ,input 99                   /*p-shift-num-end*/
                        ,input ?                    /*p-inkas-code*/
                        ) no-error.

         if error-status:error then
         do:
             message error-status:get-message(1) view-as alert-box.
         end.

/* **************************************************************** */
         if x-TOG-Shift = yes then
         do:
             /* Выбрана галка СМЕНЫ в интерфейсе */
            for each ub.chk-doc no-lock
                where ub.chk-doc.obj-type = obj-list.obj-type
                and ub.chk-doc.obj-code = obj-list.obj-code
                and (ub.chk-doc.shift-date > x-Date-Start or
                    (ub.chk-doc.shift-date = x-Date-Start and ub.chk-doc.shift-num >= x-Shift-Start))
                and (ub.chk-doc.shift-date < x-Date-End or
                    (ub.chk-doc.shift-date = x-Date-End and ub.chk-doc.shift-num <= x-Shift-End))
                and  ub.chk-doc.out-code > "",
            first ub.chk-discnt no-lock
                where ub.chk-discnt.doc-code = ub.chk-doc.doc-code
                and ub.chk-discnt.discnt-type = v-type
            :
                for each chk-gds no-lock
                where ub.chk-gds.doc-code = ub.chk-doc.doc-code
                :
                    for each ub.chk-gds-pay no-lock
                    where ub.chk-gds-pay.doc-code = ub.chk-doc.doc-code
                    and ub.chk-gds-pay.b-code = chk-gds.b-code
                    and ub.chk-gds-pay.line-num = chk-gds.line-num
                    :
                        run proc-tt. /* Процедура для заполнения временной таблицы tt-line */
                    end.
                end.
             end.
         end.
         else
         do:
            /* Не выбрана галка СМЕНЫ в интерфейсе */
            for each ub.chk-doc no-lock
                where ub.chk-doc.obj-type = obj-list.obj-type
                and ub.chk-doc.obj-code = obj-list.obj-code
                and ub.chk-doc.chk-date >= x-Date-Start
                and ub.chk-doc.chk-date <= x-Date-End
                and  ub.chk-doc.out-code > "",
            first ub.chk-discnt no-lock
                where ub.chk-discnt.doc-code = ub.chk-doc.doc-code
                and ub.chk-discnt.discnt-type = v-type
            :
                for each chk-gds no-lock
                where ub.chk-gds.doc-code = ub.chk-doc.doc-code
                :
                    for each ub.chk-gds-pay no-lock
                    where ub.chk-gds-pay.doc-code = ub.chk-doc.doc-code
                    and ub.chk-gds-pay.b-code = chk-gds.b-code
                    and ub.chk-gds-pay.line-num = chk-gds.line-num
                    :
                        run proc-tt.  /* Процедура для заполнения временной таблицы tt-line */
                    end.
                end.
             end.
         end.

         run transform-tt-level. /* Преобразование созданной выше tt-list в таблицу с уровнями и итогами по каждому уровню. */

    end. /* for each obj-list */

    str1 = (if X-TOG-Shift then "С " + fnc-DD-MM-YYYY(date(string(X-Date-Start,"99/99/9999"))) + ", смена № "  + string(X-Shift-Start) +
                                " по " + fnc-DD-MM-YYYY(date(string(X-Date-End,"99/99/9999"))) + ", смена № " + string(X-Shift-End)
                           else
                                "За период с " + fnc-DD-MM-YYYY(date(string(X-Date-Start,"99/99/9999"))) + " по " + fnc-DD-MM-YYYY(date(string(X-Date-End,"99/99/9999")))
    ).

    if X-selectGood = {&g-choice} then
    do:
        v-choice-gds = "По списку товаров: ".

        for each gds-list no-lock:
            gds-str = gds-str + gds-list.gds-name + ", ".
        end.
        gds-str = right-trim( gds-str, " " ).
        gds-str = right-trim( gds-str, "," ).
        if length(gds-str) > 115 then
        do:
            v-choice-gds = (substring(gds-str, 1, 115) + "..." ).
        end.
        else
        do:
            v-choice-gds = gds-str.
        end.
/*        gds-str = "".*/
    end.

    if length(str2) > 115 then
    do:
        v-choice-gds = substring(str2, 1, 115) + "...".
    end.
    else
    do:
        v-choice-gds = str2.
    end.

    str4 = replace(str4, chr(10), " "). /* Очищаем текст от служ. символов "Новая линия", пока просмотровщик RepView - не умеет передавать его в Excel */
    str4 = replace(str4, chr(13), " "). /* Очищаем текст от служ. символов "Перевод каретки". */
    str4 = replace(str4, chr(9), " "). /* Очищаем текст от служ. символов "Табуляция" */
    str4 = trim(str4, " "). /* Экран от незначащих пробелов по краям названия. */
    if length(str4) > 115 then
    do:
        v-choice-obj = substring(str4, 1, 115) + "...".
    end.
    else
    do:
        v-choice-obj = str4.
    end.

    if p-cb-disType = "1" then
    do:
        v-type-discount = "Тип скидки: ЛНР.".
    end.
    else
    do:
        v-type-discount = "Тип скидки: бонусы.".
    end.


    run proc-create-HTML(input v-file-name-rep-htm, input str1, input v-choice-gds, input v-choice-obj, input v-type-discount). /* Формирование HTML-страницы отчёта */

    run search-full-path-Report(input v-file-name-rep-htm). /* Проверка на наличие файла-отчёта, перед использованием его в RepViewer */

    run Report-Viewer(input v-full-path-RepView, input v-file-name-rep-htm). /* Запуск просмотровщика отчёта RepViewer */

end procedure.


procedure proc-create-HTML:
/** Создание кода страницы HTML (А4, Альбомное расположение, max ширина = 1157px) **/
    define input parameter p-file-name-rep-htm as character no-undo.
    define input parameter p-period-date as character no-undo.
    define input parameter p-choice-gds as character no-undo.
    define input parameter p-choice-obj as character no-undo.
    define input parameter p-type-discount as character no-undo.
    define buffer buf2_tt-line for tt-line.

    /* Системная шапка HTML */
    do: /* b1 */
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
    end. /* b1 */

    /* Установка системных параметров "глобальной" таблицы всего отчёта (кол-во и размерность колонок) */
    do: /* b2 */
            put stream OutStr-html unformatted
                ' <body>' skip
                '   <table name="Лист1" outline_below="false">' skip
                '     <thead>' skip
                '       <tr class="set_columns">' skip
                '         <td style="width: 252px; border: none;"></td>' skip
                '         <td style="width: 252px; border: none;"></td>' skip
                '         <td style="width: 123px; border: none;"></td>' skip
                '         <td style="width: 123px; border: none;"></td>' skip
                '         <td style="width: 123px; border: none;"></td>' skip
                '         <td style="width: 123px; border: none;"></td>' skip
                '       </tr>' skip
            . /* Точка для закрытия Put */
    end. /* b2 */

    /* Заполнение "глобальной" таблицы - блок шапки отчёта (часть отчёта, видимая как "не таблица") */
    do: /* b3 */
            put stream OutStr-html unformatted
                '       <tr>' skip
                '         <td style="border: none; height: 14px"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '       </tr>' skip
                '       <tr>' skip
                '         <td colspan="6" style="border: none; height: 14px; font-weight: bold">Отчёт по типам скидки</td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '       </tr>' skip
                '       <tr>' skip
                '         <td colspan="6" style="border: none; height: 14px; font-weight: bold">' + p-period-date + '</td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '       </tr>' skip
                '       <tr>' skip
                '         <td colspan="6" style="border: none; height: 14px; font-weight: bold">' + p-choice-gds + '</td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '       </tr>' skip
                '       <tr>' skip
                '         <td colspan="6" style="border: none; height: 14px; font-weight: bold">' + p-choice-obj + '</td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '       </tr>' skip
                '       <tr>' skip
                '         <td colspan="6" style="border: none; height: 14px; font-weight: bold">' + p-type-discount + '</td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '       </tr>' skip
                '       <tr>' skip
                '         <td style="border: none; height: 14px"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '       </tr>' skip
                '     </thead>' skip
            . /* Точка для закрытия Put */
    end. /* b3 */

    /* Заполнение "глобальной" таблицы - блок Шапки таблицы отчёта (часть отчёта, видимая как "шапка таблицы") */
    do: /* b4 */
            put stream OutStr-html unformatted
                '     <tbody>' skip
                '       <tr>' skip
                '         <th style="text-align: center; height: 30px">Объект</th>' skip
                '         <th style="text-align: center;">Товар</th>' skip
                '         <th style="text-align: center;">Количество</th>' skip
                '         <th style="text-align: center;">Сумма без скидки</th>' skip
                '         <th style="text-align: center;">Скидка</th>' skip
                '         <th style="text-align: center;">Сумма со скидкой</th>' skip
                '       </tr>' skip
                '       <tr>' skip
                '         <th num="" style="text-align: center;">1</th>' skip
                '         <th num="" style="text-align: center;">2</th>' skip
                '         <th num="" style="text-align: center;">3</th>' skip
                '         <th num="" style="text-align: center;">4</th>' skip
                '         <th num="" style="text-align: center;">5</th>' skip
                '         <th num="" style="text-align: center;">6</th>' skip
                '       </tr>' skip
            . /* Точка для закрытия Put */
        output stream OutStr-html close.
    end. /* b4 */

    /* Заполнение тела таблицы отчёта */
    do: /* b5 */
        output stream OutStr-html to value(p-file-name-rep-htm) append convert target 'UTF-8'.

        find first buf2_tt-line no-lock no-error.
        if not error-status:error and available buf2_tt-line then
        do:
            for each buf2_tt-line where
            buf2_tt-line.grp-code = 0 no-lock
            by buf2_tt-line.obj-type by buf2_tt-line.obj-code
            :

            /*  вывод головной (жирным шрифтом) строки по объекту с итогами по объекту */
                put stream OutStr-html unformatted
                '       <tr level="1">' skip
                '         <td style="text-align: left; height: 30px; font-weight: bold">' + buf2_tt-line.obj-name + '</td>' skip
                '         <td style="text-align: left; font-weight: bold">' + buf2_tt-line.gds-name + '</td>' skip
                '         <td num="0.00" style="text-align: right; font-weight: bold">' + if buf2_tt-line.eff-doc-qnty <> ? then fnc-convert-dot-to-colon(buf2_tt-line.eff-doc-qnty, ">>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                '         <td num="0.00" style="text-align: right; font-weight: bold">' + if buf2_tt-line.object-sum <> ? then fnc-convert-dot-to-colon(buf2_tt-line.object-sum, ">>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                '         <td num="0.00" style="text-align: right; font-weight: bold">' + if buf2_tt-line.discount <> ? then fnc-convert-dot-to-colon(buf2_tt-line.discount, ">>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                '         <td num="0.00" style="text-align: right; font-weight: bold">' + if buf2_tt-line.tot-r-b <> ? then fnc-convert-dot-to-colon(buf2_tt-line.tot-r-b, ">>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                '       </tr>' skip
            . /* Точка для закрытия Put */

            run tt-print-line (input buf2_tt-line.obj-type, input buf2_tt-line.obj-code, input 1, input 2). /* Доформирование групп */

            end.
        end.
        else /* Если отчёт пустой - выводим строку-пустышку */
        do:
                put stream OutStr-html unformatted
                '       <tr>' skip
                '         <td style="text-align: left; height: 14px"></td>' skip
                '         <td style="text-align: left;"></td>' skip
                '         <td num="0.00" style="text-align: right;">0,00</td>' skip
                '         <td num="0.00" style="text-align: right;">0,00</td>' skip
                '         <td num="0.00" style="text-align: right;">0,00</td>' skip
                '         <td num="0.00" style="text-align: right;">0,00</td>' skip
                '       </tr>' skip
                '       <tr>' skip
                '         <td num="0.00" style="text-align: left; height: 14px; font-weight: bold">Итого:</td>' skip
                '         <td num="0.00" style="text-align: left; font-weight: bold"></td>' skip
                '         <td num="0.00" style="text-align: right; font-weight: bold">0,00</td>' skip
                '         <td num="0.00" style="text-align: right; font-weight: bold">0,00</td>' skip
                '         <td num="0.00" style="text-align: right; font-weight: bold">0,00</td>' skip
                '         <td num="0.00" style="text-align: right; font-weight: bold">0,00</td>' skip
                '       </tr>' skip
                . /* Точка для закрытия Put */
        end.
    end. /* b5 */

    /* Заполнение подвала отчёта */
    do: /* b6 */
                put stream OutStr-html unformatted
                '     </tbody>' skip
                '   </table>' skip
                '  </body>' skip
                ' </html>' skip
                . /* Точка для закрытия Put */
        output stream OutStr-html close.
    end. /* b6 */

end procedure.

procedure proc-tt:
/*****************/

    for first ub.bar-code no-lock where ub.bar-code.b-code = chk-gds-pay.b-code
    :
        if (x-SelectGood = {&g-all}) or (can-find(first gds-list no-lock where gds-list.gds-code = ub.bar-code.gds-code)) then
        do:
            find first tt-line where
            tt-line.obj-code = obj-list.obj-code and /*Объект (код)*/
            tt-line.obj-type = obj-list.obj-type and /*Объект (тип)*/
            tt-line.b-code = chk-gds-pay.b-code no-error.

            if not available tt-line then
            do:
                create tt-line.
                tt-line.b-code = chk-gds-pay.b-code.
                tt-line.obj-name = obj-list.obj-name. /*Объект (имя)*/
                tt-line.obj-code = obj-list.obj-code. /*Объект (код)*/
                tt-line.obj-type = obj-list.obj-type. /*Объект (тип)*/

                for first ub.goods fields(gds-name grp-code) where
                ub.goods.gds-code = ub.bar-code.gds-code
                no-lock:
                    tt-line.gds-name = ub.goods.gds-name.
                    tt-line.grp-code = ub.goods.grp-code.
                end.
            end. /* not available tt-line */

            tt-line.eff-doc-qnty = tt-line.eff-doc-qnty + ub.chk-gds-pay.eff-doc-qnty. /*Количество*/
            tt-line.object-sum = tt-line.object-sum + (if chk-gds.doc-qnty <> 0 then (chk-gds.src-sum * (chk-gds-pay.eff-doc-qnty / chk-gds.doc-qnty))
                                                       else 0) no-error. /*Сумма без скидки*/
            tt-line.tot-r-b = tt-line.tot-r-b + ub.chk-gds-pay.tot-r-b. /*Сумма со скидкой*/
            tt-line.discount = tt-line.discount + (if tt-line.object-sum <> 0 then (((tt-line.object-sum - tt-line.tot-r-b) * 100) / tt-line.object-sum)
                                                   else 0) no-error. /*Скидка%*/
        end.
    end.
v-cnt = v-cnt + 1.

end procedure.

procedure Report-Viewer:
/* Запуск программы "Просмотровщик Отчётов" - ReportViewer. */
    define input parameter p-full-path-RepView as character no-undo.
    define input parameter p-file-name-rep-htm as character no-undo.

os-command no-wait value(p-full-path-RepView + " true " + search(p-file-name-rep-htm)).

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

procedure transform-tt-level:
/* Трансформация плоской таблицы в таблицу с уровнями */
/* и итогами для каждого уровня. */
/******************************************************/
    define variable v-eff-doc-qnty as decimal no-undo.
    define variable v-object-sum as decimal no-undo.
    define variable v-tot-r-b as decimal no-undo.
    define variable v-discount as decimal no-undo.
    define variable v-ii as integer no-undo.
    define variable v-gds-name as character no-undo.
    define variable v-cur-lvl as integer no-undo.
    define variable v-upper-code as integer initial ? no-undo.
    define buffer buf_tt-line for tt-line.
    define buffer buf2_goods for ub.goods.
    define buffer bufobj_tt-line for tt-line.

    create bufobj_tt-line.
    assign
        bufobj_tt-line.grp-code = 0
        bufobj_tt-line.obj-type = obj-list.obj-type
        bufobj_tt-line.obj-code = obj-list.obj-code
        bufobj_tt-line.obj-name = obj-list.obj-name
    .

    do while v-upper-code <> 0:

        v-upper-code = 0.

        for each tt-line where tt-line.grp-lvl = v-cur-lvl
        and tt-line.obj-type = obj-list.obj-type
        and tt-line.obj-code = obj-list.obj-code
        break by tt-line.grp-code 
        :

            v-ii = v-ii + 1.

            if first-of (tt-line.grp-code) then
            do:
                assign
                    v-eff-doc-qnty = 0  /* Количество */
                    v-object-sum = 0    /* Сумма без скидки */
                    v-tot-r-b = 0       /* Сумма со скидкой */
                    v-discount = 0      /* Скидка */
                .
                find first ub.gds-grp where
                ub.gds-grp.node-code = tt-line.grp-code no-lock.
                if available ub.gds-grp then
                do:
                    assign
                        v-upper-code = ub.gds-grp.upper-code
                        v-gds-name = ub.gds-grp.node-name
                    .
                end.
            end.

            tt-line.upper-code = if  tt-line.grp-lvl = 0 then tt-line.grp-code else v-upper-code.

            assign
                v-eff-doc-qnty = v-eff-doc-qnty + tt-line.eff-doc-qnty  /* Количество */
                v-object-sum = v-object-sum + tt-line.object-sum        /* Сумма без скидки */
                v-tot-r-b = v-tot-r-b + tt-line.tot-r-b                 /* Сумма со скидкой */
                v-discount = v-discount + tt-line.discount              /* Скидка */
            .

            if tt-line.grp-lvl = 0 then
                assign
                    bufobj_tt-line.eff-doc-qnty = bufobj_tt-line.eff-doc-qnty + tt-line.eff-doc-qnty  /* Количество */
                    bufobj_tt-line.object-sum = bufobj_tt-line.object-sum + tt-line.object-sum        /* Сумма без скидки */
                    bufobj_tt-line.tot-r-b = bufobj_tt-line.tot-r-b +  tt-line.tot-r-b                /* Сумма со скидкой */
                    bufobj_tt-line.discount = bufobj_tt-line.discount + tt-line.discount              /* Скидка */
                .

            if last-of (tt-line.grp-code) then
            do:
                create buf_tt-line.

                assign
                    buf_tt-line.grp-code =
                        (if tt-line.grp-lvl = 0 then tt-line.grp-code
                         else v-upper-code)                             /* Группа товара (как-бы заголовок для группы) */
                    buf_tt-line.eff-doc-qnty = v-eff-doc-qnty           /* Количество */
                    buf_tt-line.object-sum = v-object-sum               /* Сумма без скидки */
                    buf_tt-line.tot-r-b = v-tot-r-b                     /* Сумма со скидкой */
                    buf_tt-line.discount = v-discount                   /* Скидка */
                    buf_tt-line.grp-lvl = buf_tt-line.grp-lvl + 1       /* Уровень группы (относительный, как порядок следования групп: 1, 2, ...) */
                    buf_tt-line.gds-name = v-gds-name                   /* Наименование руппы товаров */
                    buf_tt-line.obj-type = obj-list.obj-type
                    buf_tt-line.obj-code = obj-list.obj-code
                .

            end.
        end. /* b10 */

        v-cur-lvl = v-cur-lvl + 1.

end. /* do while */

end procedure.

procedure tt-print-line:
/* Вывод линий таблицы с группировкой: 1) по имени группы товаров; 2) по уровню внутри группыю */
    define input parameter v-obj-type as character no-undo.
    define input parameter v-obj-code as integer no-undo.
    define input parameter v-upper-code like ub.gds-grp.upper-code no-undo.
    define input parameter v-print-lvl as integer no-undo.

    define buffer buf3_tt-line for tt-line.

    for each buf3_tt-line where
    buf3_tt-line.upper-code = v-upper-code and
    buf3_tt-line.obj-type = v-obj-type and
    buf3_tt-line.obj-code = v-obj-code
    no-lock:

        if v-print-lvl < 3 then /* Выводим в HTML основыные уровни(v-print-lvl) - 1-й и 2-й */
        do:
            put stream OutStr-html unformatted
                '       <tr level="' + string(v-print-lvl) + '">' skip
                '         <td style="text-align: left; height: 30px">' + '</td>' skip
                '         <td style="text-align: left; padding-left: ' + string((v-print-lvl - 1) * 10) + 'px">'
                            + string(fill(" ", ((v-print-lvl - 2) * 4))) + buf3_tt-line.gds-name
                            + '</td>' skip
                '         <td num="0.00" style="text-align: right">' + if buf3_tt-line.eff-doc-qnty <> ? then fnc-convert-dot-to-colon(buf3_tt-line.eff-doc-qnty, ">>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                '         <td num="0.00" style="text-align: right">' + if buf3_tt-line.object-sum <> ? then fnc-convert-dot-to-colon(buf3_tt-line.object-sum, ">>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                '         <td num="0.00" style="text-align: right">' + if buf3_tt-line.discount <> ? then fnc-convert-dot-to-colon(buf3_tt-line.discount, ">>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                '         <td num="0.00" style="text-align: right">' + if buf3_tt-line.tot-r-b <> ? then fnc-convert-dot-to-colon(buf3_tt-line.tot-r-b, ">>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                '       </tr>' skip
            . /* Точка для закрытия Put */
        end.
        else /* иначе - если более детальные уровни (v-print-lvl с 3-го и более), то формируем строки с такими уровнями в HTML, но на экран не выводим! */
        do:
            put stream OutStr-html unformatted
                '       <tr level="' + string(v-print-lvl) + '">' skip
                '         <td style="text-align: left; height: 30px; display: none">' + '</td>' skip
                '         <td style="text-align: left; padding-left: ' + string((v-print-lvl - 1) * 10) + 'px; display: none">'
                            + string(fill(" ", ((v-print-lvl - 2) * 4))) + buf3_tt-line.gds-name
                            + '</td>' skip
                '         <td num="0.00" style="text-align: right; display: none">' + if buf3_tt-line.eff-doc-qnty <> ? then fnc-convert-dot-to-colon(buf3_tt-line.eff-doc-qnty, ">>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                '         <td num="0.00" style="text-align: right; display: none">' + if buf3_tt-line.object-sum <> ? then fnc-convert-dot-to-colon(buf3_tt-line.object-sum, ">>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                '         <td num="0.00" style="text-align: right; display: none">' + if buf3_tt-line.discount <> ? then fnc-convert-dot-to-colon(buf3_tt-line.discount, ">>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                '         <td num="0.00" style="text-align: right; display: none">' + if buf3_tt-line.tot-r-b <> ? then fnc-convert-dot-to-colon(buf3_tt-line.tot-r-b, ">>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                '       </tr>' skip
            . /* Точка для закрытия Put */
        end.

        if buf3_tt-line.grp-lvl <> 0 then run tt-print-line (input v-obj-type, input v-obj-code, input buf3_tt-line.grp-code, input v-print-lvl + 1).
    end.

end procedure.

function fnc-convert-dot-to-colon returns character 
(input p-data as decimal, input p-accur as character):
/* Конвертация десятичной точки в запятую с передачей параметра форматирования числа */

	define variable result as character no-undo.
    define variable v-str-result as character no-undo.

    p-data = round(p-data, 4). /* Чтобы не выйти случайно за рамки формата числа при выводе (несоотвесвие формата результата и формата отображения - приводит к ош) */
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
