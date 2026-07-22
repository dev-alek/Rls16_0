block-level on error undo, throw.
/*

$Revision: 8f5f559ebdb3, 2359, rls $
$Author: EShklyar $
$Date: Ср июн 10 21:13:34 2020 +0300 $
$Workfile: r-order.p $
$Archive: rep/r-order.p $

Отчет по планированию заказов по заказу

Автор: Шкляр Елена Львовна
Дата создания: 10/18/05
Author: Shklyar Elena
Creation date: 10/18/05

*/
{ rep/tt-date.i }

define input parameter parparentproc    as handle no-undo .
define input parameter p-docCode as integer no-undo .
define input parameter p-dbNum as integer no-undo .
define input parameter p-param as character no-undo .



define variable vss-revision    as character no-undo init "$Revision: 8f5f559ebdb3, 2359, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Ср июн 10 21:13:34 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-order.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-order.p $":U .
define variable vss-description as character no-undo init "Отчет по планированию заказов".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ rep/html-conv.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ gbl/prn-lib.i }

{ rep/tt-zakaz.i new }


define buffer buf_order-doc  for ub.order-doc .
define buffer buf_order-line for ub.order-line .

define variable v-full-path-RepView as character no-undo.   /* Полный путь к файлу Просмотровщика (отчётов) */
define variable v-file-name-rep-htm as character no-undo.   /* Полный путь к файлу отчёта */
define variable g#report-num        as integer   no-undo.            /* Номер отчёта (получим стандартной процедурой ТН) */
define variable v-report-name       as character no-undo.         /* Наименование отчёта */
define variable v-period            as character no-undo.              /* Период за который формируется отчёт */
define variable vDaySale            as character no-undo .
define variable vGarantDay          as character no-undo .
define variable vDelDayGoods        as logical   no-undo .
define variable periodDay           as character no-undo .
define variable vDateOrder          as date      no-undo .
define stream OutStr-html.

define buffer buf_goods   for ub.goods .
define buffer buf_clients for ub.clients .
define buffer bf_clients  for ub.clients .




find first buf_order-doc no-lock where buf_order-doc.doc-code = p-docCode and
    buf_order-doc.db-num = p-dbNum no-error .


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
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 200px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '</tr>' skip
    .

find first bf_clients no-lock where bf_clients.obj-code = buf_order-doc.obj-code and
    bf_clients.obj-type = buf_order-doc.obj-type no-error .

find first buf_clients no-lock where buf_clients.obj-code = buf_order-doc.cli-code and
    buf_clients.obj-type = buf_order-doc.cli-type no-error .
vDateOrder = date(entry(1,p-param,{&delim-par})) no-error .  
vDaySale = entry(3,p-param,{&delim-par}) no-error .  
vGarantDay = entry(4,p-param,{&delim-par}) no-error .
periodDay = entry(8,p-param,{&delim-par}) no-error.
v-period = entry(9,p-param,{&delim-par}) no-error.
vDelDayGoods = logical(entry(5,p-param,{&delim-par})) no-error.

put stream OutStr-html unformatted
    '<tr style="font-size:11px;">' skip
    '<td colspan="13" style="text-align: left; font-weight:bold;">Отчет по планированию заказа товаров Магазина и готовой продукции Кафе</td>' skip
    '</tr>' skip
    '<tr style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;">на ' + string(vDateOrder,"99/99/9999") + '</td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;"><b>Остаток товара, шт (О)</b> Количество товара на остатке в штуках на текущий момент (4).</td>' skip
    '</tr>' skip
    '<tr style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;">объект: ' + bf_clients.obj-name + '</td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;"><b>Продажи за период, шт (Vпр)</b> Количество продаж товара (с учетом возвратов) за выбранный период (5).</td>' skip
    '</tr>' skip
    '<tr style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;">контрагент: ' + buf_clients.obj-name + '</td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;"><b>Среднесуточные продажи за период, шт (Тпр)</b> Среднесуточное количество проданного товара за выбранный период времени Тпр = Vпр / P, где Р – период продаж в днях (6).</td>' skip
    '</tr>' skip
    .

put stream OutStr-html unformatted
    '<tr style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;">заказ формируется на : ' + string(vDaySale) + ' дней(дня), с учетом гарантийного запаса на ' + string(vGarantDay) + ' дней(дня)</td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;"><b>Рекомендованный объем заказа с учетом минимального и гарантийного запасов, шт (Vзг)</b> Vзг = Vз + М + G  (7).</td>' skip
    '</tr>' skip .



put stream OutStr-html unformatted   
    '<tr style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;">период анализа : ' + string(periodDay) + ' дней(дня) ' + v-period + '</td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;"><b>Запас товара, в днях (Од)</b> Количество дней, на которое должно хватить остатков товара на текущий момент с учетом среднесуточных продаж за период Од = О / Тпр (8).</td>' skip
    '</tr>' skip 
    '<tr style="font-size:11px;">' skip
    .
  
if vDelDayGoods then 
do:
    put stream OutStr-html unformatted   
        '<td colspan="5" text_wrap="true" style="text-align: left;">исключены дни, когда товара не было на остатках</td>' skip
        .
end.  
else 
do:
    put stream OutStr-html unformatted   
        '<td colspan="5" style="text-align: left;"></td>' skip
        .
end.
put stream OutStr-html unformatted   
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;"><b>Расчетный объем заказа с учетом темпа продаж, шт (Vз)</b> Vз = Тпр * Q - Ост, где Q – период, на который формируется заказ в днях,</td>' skip
    '</tr>' skip 
    '<tr style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;"></td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;">если Ост < 0, то при расчете Ост не учитывается. Ост – Остаток товара на день заказа: Ост = О - (Dз-D) * Тпр, где Dз – дата заказа, D – текущая дата (9).</td>' skip
    '</tr>' skip
    '<tr style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;"></td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;"><strong>Расчетный объем заказа с учетом минимального запаса,шт (Vзм)</strong> Vзм = Vз + М  (10).</td>' skip
    '</tr>' skip
    '<tr style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;"></td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;"><b>Минимальный запас, шт (М)</b> Количество товара, необходимое для выкладки (11). </td>' skip
    '</tr>' skip
    '<tr style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;"></td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;"><b>Гарантийный запас, шт (G)</b> G = S * Тпр, где   S – гарантийный запас в днях (12).</td>' skip
    '</tr>' skip
    '<tr style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;"></td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;"><b>Товар участвует в промоакции</b> Участие товара в промоакции в статусе «Активная» в ТН на момент формирования отчета. </td>' skip
    '</tr>' skip
    '<tr style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;"></td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;">Информация справочная, необходимо учитывать при подтверждении заказа (13).</td>' skip
    '</tr>' skip
    '<tr height:15px;  style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;"></td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left;"></td>' skip
    '</tr>' skip
    '<tr style="font-size:11px;">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;"></td>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-style: italic;"><b>* При расчете не учитываются сроки годности и движение рецептурных товаров</b></td>' skip
    '</tr>' skip
    .  
put stream OutStr-html unformatted   
    '<tr>' skip
    '<td colspan="10" text_wrap="true" style="text-align: left; font-weight:bold;"><br></td>' skip
    '</tr>' skip
    '<tr>' skip
    '<td colspan="10" text_wrap="true" style="text-align: left; font-weight:bold;"><br></td>' skip
    '</tr>' skip
    '</thead>' skip
    .

put stream OutStr-html unformatted
    '     <tbody>' skip
    '       <tr style="font-size:11px;">' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver; height: 30px">Код ТН</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Артикул ТН</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Наименование товара</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Остаток товара, шт.<br>(О)</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Продажи за период, шт.<br>(Vпр)</th>' skip 
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Среднесуточные продажи за период, шт.<br>(Тпр)</th>' skip  
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; font-size:12px; background-color: silver;">Рекомендованный объем заказа с учетом минимального и гарантийного запасов, шт.<br>(Vзг)</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Запас товара, в днях<br>(Од)</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Расчетный объем заказа с учетом темпа продаж, шт.<br>(Vз)</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Расчетный объем заказа с учетом минимального запаса, шт.<br>(Vзм)</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Минимальный запас, шт.<br>(М)</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Гарантийный запас, шт.<br>(G)</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Товар участвует в промоакции</th>' skip
    '       </tr>' skip
    '       <tr style="font-size:11px;">' skip
    '         <th style="text-align: center;  font-weight:bold; background-color: silver;"></th>' skip
    '         <th style="text-align: center;  font-weight:bold; background-color: silver;"></th>' skip
    '         <th style="text-align: center;  font-weight:bold; background-color: silver;"></th>' skip
    '         <th colspan="3" style="text-align: center;  font-weight:bold; background-color: silver;">ФАКТИЧЕСКИЕ ДАННЫЕ</th>' skip
    '         <th style="text-align: center;  font-weight:bold; background-color: silver;">ЗАКАЗ</th>' skip
    '         <th colspan="6" style="text-align: center;  font-weight:bold; background-color: silver;">СПРАВОЧНАЯ ИНФОРМАЦИЯ</th>' skip
    '       </tr>' skip
    '       <tr style="font-size:11px;">' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">1</th>' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">2</th>' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">3</th>' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">4</th>' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">5</th>' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">6</th>' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">7</th>' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">8</th>' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">9</th>' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">10</th>' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">11</th>' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">12</th>' skip
    '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">13</th>' skip
    '       </tr>' skip
    . 


put stream OutStr-html unformatted
    '     <tbody>' skip
    .

put stream OutStr-html unformatted
    '<tr style="font-size:11px;">' skip
    '<td colspan="13" style="text-align: left; font-weight:bold;"><br>' + if buf_order-doc.contract-prn-code = "" then '   БЕЗ ДОГОВОРА</td>' else '   ' + buf_order-doc.contract-prn-code + '<br></td>' skip
    '</tr>' skip      
    .
                
for each buf_order-line no-lock where buf_order-line.doc-code = buf_order-doc.doc-code and
    buf_order-line.db-num = buf_order-line.db-num:
    find first tt-zakaz no-lock where tt-zakaz.gds-code = buf_order-line.gds-code no-error .
    if available (tt-zakaz) then next .
    find first buf_goods no-lock where buf_goods.gds-code = buf_order-line.gds-code no-error .



    put stream OutStr-html unformatted
        '       <tr style="font-size:11px;">' skip
        '         <td text_wrap="true" style="text-align: center;">' + string(buf_order-line.gds-code) + '</td>' skip
        '         <td text_wrap="true" style="text-align: center;">' + string(buf_order-line.artic) + '</td>' skip
        '         <td text_wrap="true" style="text-align: center;">' + string(buf_goods.gds-name) + '</td>' skip
        '         <td text_wrap="true" num="0" val="' + fnc-convert-dot-to-colon(buf_order-line.rest,"->>>>>>>>>>>>>9",0) + '"  style="text-align: center;">' + fnc-convert-dot-to-colon(buf_order-line.rest,"->>>>>>>>>>>9",0) + '</td>' skip
        '         <td text_wrap="true" num="0" val="' + fnc-convert-dot-to-colon(buf_order-line.sales,"->>>>>>>>>>>>>9.",0) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(buf_order-line.sales,"->>>>>>>>>>>>>9",0) + '</td>' skip
        '         <td text_wrap="true" num="0.0" val="' + fnc-convert-dot-to-colon(buf_order-line.average-sales,"->>>>>>>>>>>>>9.9",1) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(buf_order-line.average-sales,"->>>>>>>>>>>>>9.9",1) + '</TD>' skip
        '         <td text_wrap="true" style="text-align: center; font-weight:bold; font-size:12px;">' + string(buf_order-line.order-qnty) + '</td>' skip   
        '         <td text_wrap="true" style="text-align: center;">' + string(buf_order-line.stock-goods) + '</td>' skip    
        '         <td text_wrap="true" style="text-align: center;">' + string(buf_order-line.volume-goods) + '</td>' skip
        '         <td text_wrap="true" style="text-align: center;">' + string(buf_order-line.volume-stock) + '</td>' skip
        '         <td text_wrap="true" style="text-align: center;">' + string(buf_order-line.min-stock) + '</td>' skip
        '         <td text_wrap="true" style="text-align: center;">' + string(buf_order-line.garant-stock) + '</td>' skip
        '         <td text_wrap="true" style="text-align: center;">' + (if buf_order-line.promo then "да" else "нет") + '</td>' skip
        '       </tr>' skip
        . 
end.

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

