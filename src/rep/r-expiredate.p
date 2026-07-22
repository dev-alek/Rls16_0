block-level on error undo, throw.
/*

$Revision: 8f5f559ebdb3, 2359, rls $
$Author: EShklyar $
$Date: Ср июн 10 21:13:34 2020 +0300 $
$Workfile: r-expireDate.p $
$Archive: rep/r-expireDate.p $

Отчёт по срокам годности маркированного товара

Автор: Шкляр Елена Львовна
Дата создания: 10/18/05
Author: Shklyar Elena
Creation date: 10/18/05

*/
define input parameter parparentproc    as handle no-undo .
define input parameter p-SelectGood as integer no-undo .
define input parameter p-period-control as integer no-undo .
define input parameter p-expired-goods as logical no-undo .

define variable vss-revision        as character no-undo init "$Revision: 8f5f559ebdb3, 2359, rls $":U .
define variable vss-author          as character no-undo init "$Author: EShklyar $":U .
define variable vss-date            as character no-undo init "$Date: Ср июн 10 21:13:34 2020 +0300 $":U .
define variable vss-workfile        as character no-undo init "$Workfile: r-rsrv-plan.p $":U .
define variable vss-archive         as character no-undo init "$Archive: rep/r-rsrv-plan.p $":U .
define variable vss-description     as character no-undo init "Отчет по планированию заказов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i     }
{ gbl/waitfram.i     }
{ cmp/r-page1.i    }
{ ref/grplibfn.i }
{ cmp/cli-list.i cli-list def "new shared" }
{ rep/html-conv.i }

{ gbl/prn-lib.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

    { gbl/objsrv.i }
define variable ii                  as integer   no-undo .
define variable kk                  as integer   no-undo .
define variable v-full-path-RepView as character no-undo.   /* Полный путь к файлу Просмотровщика (отчётов) */
define variable v-file-name-rep-htm as character no-undo.   /* Полный путь к файлу отчёта */
define variable v-report-name       as character no-undo.   /* Наименование отчёта */
define variable v-period            as character no-undo.   /* Период за который формируется отчёт */
define variable Counter1            as integer   init 0 no-undo .
define variable v-gds-counter       as integer   no-undo .
define variable vExpireDateOther    as character no-undo init "-".
define variable vExpDate            as character no-undo .
define variable vExpireDate         as character no-undo .

define stream OutStr-html.
define variable g#report-num        as integer   no-undo.   /* Номер отчёта (получим стандартной процедурой ТН) */

define temp-table tt-exp no-undo 
    field mark            as character 
    field gds-code        as integer
    field gds-name        as character
    field expireDate      as date
    field expireDateOther as character init "-"
    field fact-qnty       as integer
    field qntyDay         as integer
    index pi gds-code expireDate.

define temp-table tt-date no-undo
field date as date .
    
define buffer buf_goods        for ub.goods .
define buffer buf_goods-attr   for ub.goods-attr .
define buffer buf_marking-attr for ub.marking-attr .
define buffer buf_marking      for ub.marking .
define buffer buf_gds-obj      for ub.gds-obj .
define buffer bf_clients       for ub.clients .
define buffer bf_marking-attr for ub.marking-attr .
define buffer buf_exp for tt-exp .

define temp-table tt-goods no-undo like ub.goods
field expDate as date
field expDateOther as character.



define buffer buf_cli-gds for ub.cli-gds.


define variable v-curr-grp-name as character no-undo .
define variable v-host-code     like ub.clients.host-code no-undo .
do
    on error undo, return error return-value
    :
    run waitfram-show in this-procedure ( "Формирование списка товаров..." ) .
    empty temp-table tt-goods.

    case p-SelectGood :
        when {&g-all} then 
            do: /* все товары */
                for each buf_goods no-lock
                    where buf_goods.stts = 0,
                    first buf_goods-attr no-lock 
                    where buf_goods-attr.gds-code = buf_goods.gds-code
                    and buf_goods-attr.attr-code = {&attr-mark-type}
                    :
                    create tt-goods.
                    buffer-copy buf_goods to tt-goods.
                    assign
                        v-gds-counter = v-gds-counter + 1
                        .
                end.
            end.
        when {&g-grp} then 
            do: /* товары по группам  */
                for each tmp#grp no-lock
                    :
                    run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output v-curr-grp-name ) .
                    for each buf_goods no-lock
                        where buf_goods.grp-name begins v-curr-grp-name,
                        first buf_goods-attr no-lock 
                        where buf_goods-attr.gds-code = buf_goods.gds-code
                        and buf_goods-attr.attr-code = {&attr-mark-type}              
                        :
                        find first tt-goods no-lock
                            where tt-goods.artic     = buf_goods.artic
                            and tt-goods.prod-type = buf_goods.prod-type
                            and tt-goods.prod-code = buf_goods.prod-code
                            no-error .
                        if not available tt-goods then 
                        do:
                            create tt-goods.
                            buffer-copy buf_goods to tt-goods.
                            assign
                                v-gds-counter = v-gds-counter + 1
                                .
                        end.
                    end.
                end.
            end.
        when {&g-prod} then 
            do: /* товары по производителю */
                for each buf_goods no-lock
                    where buf_goods.stts = 0 ,
                    each buf_cli-gds no-lock
                    where buf_cli-gds.prod-type = buf_goods.prod-type
                    and buf_cli-gds.prod-code = buf_goods.prod-code
                    and buf_cli-gds.artic     = buf_goods.artic ,
                    first g#cli
                    where g#cli.obj-type = buf_cli-gds.prod-type
                    and g#cli.obj-code = buf_cli-gds.prod-code,
                    first buf_goods-attr no-lock 
                    where buf_goods-attr.gds-code = buf_goods.gds-code
                    and buf_goods-attr.attr-code = {&attr-mark-type}
                    :
                    find first tt-goods no-lock
                        where tt-goods.prod-type = buf_goods.prod-type
                        and tt-goods.prod-code = buf_goods.prod-code
                        and tt-goods.artic     = buf_goods.artic
                        no-error.
                    if not available tt-goods then 
                    do:
                        create tt-goods.
                        buffer-copy buf_goods to tt-goods no-error.
                        assign
                            v-gds-counter = v-gds-counter + 1
                            .
                    end.
                end.
            end.
        when {&g-choice} or 
        when {&g-one} then 
            do: /* товары выборочно */
                for each gds-list :
                    for first buf_goods no-lock
                        where buf_goods.gds-code = gds-list.gds-code,
                        first buf_goods-attr no-lock 
                        where buf_goods-attr.gds-code = buf_goods.gds-code
                        and buf_goods-attr.attr-code = {&attr-mark-type}:
                        create tt-goods.
                        buffer-copy buf_goods to tt-goods.
                        assign
                            v-gds-counter = v-gds-counter + 1
                            .
                    end.
                end.
            end.
        when {&g-grp-prod} then 
            do: /* группа и производитель */
                for each tmp#grp no-lock
                    :
                    run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output v-curr-grp-name ) .
                    for each buf_goods no-lock
                        where buf_goods.grp-name begins v-curr-grp-name,
                        first buf_goods-attr no-lock 
                        where buf_goods-attr.gds-code = buf_goods.gds-code
                        and buf_goods-attr.attr-code = {&attr-mark-type}
                        :
                        find first tt-goods no-lock
                            where tt-goods.artic     = buf_goods.artic
                            and tt-goods.prod-type = buf_goods.prod-type
                            and tt-goods.prod-code = buf_goods.prod-code
                            no-error .
                        if not available tt-goods then 
                        do:
                            create tt-goods.
                            buffer-copy buf_goods to tt-goods no-error.
                            assign
                                v-gds-counter = v-gds-counter + 1
                                .
                        end.
                    end.
                end.
                for each buf_goods no-lock
                    where buf_goods.stts = 0 ,
                    each buf_cli-gds no-lock
                    where buf_cli-gds.prod-type = buf_goods.prod-type
                    and buf_cli-gds.prod-code = buf_goods.prod-code
                    and buf_cli-gds.artic     = buf_goods.artic ,
                    first g#cli
                    where g#cli.obj-type = buf_cli-gds.prod-type
                    and g#cli.obj-code = buf_cli-gds.prod-code,
                    first buf_goods-attr no-lock 
                    where buf_goods-attr.gds-code = buf_goods.gds-code
                    and buf_goods-attr.attr-code = {&attr-mark-type}
                    :
                    find first tt-goods no-lock
                        where tt-goods.prod-type = buf_goods.prod-type
                        and tt-goods.prod-code = buf_goods.prod-code
                        and tt-goods.artic     = buf_goods.artic
                        no-error.
                    if not available tt-goods then 
                    do:
                        create tt-goods.
                        buffer-copy buf_goods to tt-goods no-error.
                        assign
                            v-gds-counter = v-gds-counter + 1
                            .
                    end.
                end.
            end.
    end case.
    run waitfram-hide in this-procedure .
end.

/*Заполнение таблицы*/
for each tt-goods:
    for each buf_marking no-lock where buf_marking.gds-code = tt-goods.gds-code and 
        buf_marking.box-qnty = 1 
        and (buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB or
        buf_marking.sts = objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB)
            :
        if buf_marking.expDate <> ? and buf_marking.expDate <> "" then do:
            vExpireDateOther = "-" .
            if buf_marking.expDateOther <> ? and buf_marking.expDateOther <> "" then 
            do:
/*                empty temp-table tt-date .*/
                vExpireDateOther = "" .
                do ii = 1 to num-entries (buf_marking.expDateOther):
                    if vExpireDateOther = "" then vExpireDateOther = string(date(entry(ii,buf_marking.expDateOther)),"99.99.9999") .
                    else vExpireDateOther = vExpireDateOther + ", " + string(date(entry(ii,buf_marking.expDateOther)),"99.99.9999") .
                end.
              end.              
            find first buf_exp where buf_exp.gds-code = tt-goods.gds-code and 
            buf_exp.expireDate = date(buf_marking.expDate) and buf_exp.expireDateOther = vExpireDateOther no-error .
            if not available (buf_exp) then do:
                create buf_exp .
                assign
                buf_exp.gds-code   = tt-goods.gds-code
                buf_exp.gds-name   = tt-goods.gds-name
                buf_exp.expireDate = date(buf_marking.expDate)
                buf_exp.qntyDay    = integer(date(buf_marking.expDate) - today) 
                .
                if vExpireDateOther <> "" then buf_exp.expireDateOther = vExpireDateOther .
            end.

        buf_exp.fact-qnty = buf_exp.fact-qnty + 1 .          
        end.
    end.
end.


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
    '</tr>' skip
    .

find first bf_clients no-lock where bf_clients.obj-code = v-cntxt-obj-code and
    bf_clients.obj-type = v-cntxt-obj-type no-error .

put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="7" style="text-align: left; font-weight:bold;">Отчёт по срокам годности маркированного товара</td>' skip
    '</tr>' skip
    '<tr>' skip
    '<td colspan="7" text_wrap="true" style="text-align: left;">на ' + string(today,"99.99.9999") + '</td>' skip
     '</tr>' skip
    '<tr>' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;">объект: ' + bf_clients.obj-name + '</td>' skip
    '</tr>' skip
    '<tr height = "15px">' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;"></td>' skip
    '</tr>' skip   
    '<tr>' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;">Условия формирования:</td>' skip
    '</tr>' skip     
    '<tr>' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;">Период контроля: ' + string(p-period-control) + ' дней</td>' skip
    '</tr>' skip    
    '<tr>' skip
    '<td colspan="5" text_wrap="true" style="text-align: left;">Показать просроченные товары: ' + if p-expired-goods then "Да"  + '</td>' else "Нет" + '</td>' skip
    '</tr>' skip   
    .

put stream OutStr-html unformatted   
    '<tr>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-weight:bold;"><br></td>' skip
    '</tr>' skip
    '<tr>' skip
    '<td colspan="8" text_wrap="true" style="text-align: left; font-weight:bold;"><br></td>' skip
    '</tr>' skip
    '</thead>' skip
    .

put stream OutStr-html unformatted
    '     <tbody>' skip
    '       <tr>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">№ п/п</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Код товара</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Наименование ТН</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Дата истечения срока годности</th>' skip
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Дней до истечения срока годности</th>' skip 
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Годен до (иные условия хранения)</th>' skip  
    '         <th text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Факт. кол-во</th>' skip
    '       </tr>' skip
    . 
ii = 0 .
for each tt-exp no-lock where tt-exp.qntyDay <= p-period-control break by tt-exp.gds-name by tt-exp.expireDate:
    if not p-expired-goods then do:
      if tt-exp.qntyDay < 0 then next .
    end. 
    ii = ii + 1 .
    put stream OutStr-html unformatted
        '       <tr>' skip
        '         <td text_wrap="true" style="text-align: center;">' + string(ii) + '</td>' skip
        '         <td text_wrap="true" style="text-align: center;">' + string(tt-exp.gds-code) + '</td>' skip
        '         <td text_wrap="true" style="text-align: center;">' + string(tt-exp.gds-name) + '</td>' skip
        '         <td text_wrap="true" style="text-align: center;">' + string(tt-exp.expireDate,"99.99.9999") + '</td>' skip    
        '         <td text_wrap="true" style="text-align: center;">' + string(tt-exp.qntyDay) + '</td>' skip
        '         <td text_wrap="true" style="text-align: center;">' + string(tt-exp.expireDateOther) + '</td>' skip
        '         <td text_wrap="true" style="text-align: center;">' + string(tt-exp.fact-qnty) + '</td>' skip
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


