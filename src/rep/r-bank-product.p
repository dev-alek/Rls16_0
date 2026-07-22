block-level on error undo, throw.
/*

$Revision: 8f5f559ebdb3, 2359, rls $
$Author: EShklyar $
$Date: Ср июн 10 21:13:34 2020 +0300 $
$Workfile: r-bank-product.p $
$Archive: rep/r-bank-product.p $

Отчёт по Бонусам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/18/05
Author: Bakhtadze Natalya
Creation date: 10/18/05

*/

define input parameter parparentproc    as handle no-undo.
define input parameter p-rid-list-oss   as character no-undo. 

define variable vss-revision    as character no-undo init "$Revision: 8f5f559ebdb3, 2359, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Ср июн 10 21:13:34 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-bank-product.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-bank-product.p $":U .
define variable vss-description as character no-undo init "Отчёт по Бонусам".
{ cmp/vssrevis.i }

{ rep/html-conv.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/r-page1.i " " cmp }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ cmp/operlist.i }
{ cmp/breakstr.i }
{ cmp/getdpcnt.i }
{ gbl/waitfram.i }
{ ref/grplibfn.i }
{ gbl/getcntxt.i def }
{ str/lib-trn.i  }
{ ref/extclass.i }

define variable v-prod-type as character no-undo.
define variable v-prod-code as integer no-undo.
define variable v-gds-code like ub.goods.gds-code no-undo.
define variable ii as integer no-undo.
define variable v-found as logical no-undo.
define variable v-count as integer no-undo.
define variable v-shift-on as logical no-undo.
define variable v-for-netto as decimal no-undo.
define variable v-id as int64 no-undo.
define variable v-oss-list as character no-undo.
define variable v-rrn as character no-undo .

define variable sym1 as character initial ":" no-undo. 
define variable sym2 as character initial ":" no-undo.
define variable Line as character no-undo.
define variable v-full-path-RepView as character no-undo.   /* Полный путь к файлу Просмотровщика (отчётов) */
define variable v-file-name-rep-htm as character no-undo.   /* Полный путь к файлу отчёта */
define variable g#report-num as integer no-undo.            /* Номер отчёта (получим стандартной процедурой ТН) */
define variable v-report-name as character no-undo.         /* Наименование отчёта */
define variable v-period as character no-undo.              /* Период за который формируется отчёт */
define variable v-msg-noAllChk as character no-undo.        /* Предупреждение, если отчёт будет "(сформирован НЕ ПО ВСЕМ ЧЕКАМ)" */
define variable v-short-obj-list as character no-undo.      /* Сокращённый список выбранных Объектов "в одну строку" */
define variable v-sel-gds-string as character no-undo.      /* Строка отчёта, где указана информация о выбранных товарах ("По сформированному списку товаров (в списке 15 товаров)." */
define variable v-prod-mode-string as character no-undo.    /* Строка отчёта, где указана информация о выбранном режиме "По производителям" (По конкретным производителям(поставщикам)деталльно | По ВСЕМ производителям (одной строкой)) */
define variable v-legacy-string as character no-undo.       /* С учетом перевыпуска карт (приведены номера карт ПОСЛЕДНЕГО ВЫПУСКА) */
define variable v-subsid-string as character no-undo.       /* С учетом дополнительных карт (приведены номера ОСНОВНЫХ карт) */

define variable v-dcard_doc-qnty as decimal no-undo.
define variable v-dcard_sum-withoutdisc as decimal no-undo. /* Сумма без скидок */
define variable v-dcard_sum-withdisc as decimal no-undo.    /* Сумма со скидкой */
define variable v-dcard_discount as decimal no-undo.
/* ********* */
define variable v-obj_doc-qnty as decimal no-undo.
define variable v-obj_sum-withoutdisc as decimal no-undo.   /* Сумма без скидок */
define variable v-obj_sum-withdisc as decimal no-undo.      /* Сумма со скидкой */
define variable v-obj_discount as decimal no-undo.
define variable v-first-of-d-card as logical no-undo.       /* Первое вхождение в ДКарту (к расчёту чеков по ДКарте) */
define variable v-obj-chk-counter as integer no-undo.
define variable v-obj-type as character format "X(3)" no-undo. /* Для управл. условием where в запросе (для одноимённого поля) */
define variable v-obj-code as integer no-undo.              /* Для управл. условием where в запросе (для одноимённого поля) */
define variable v-obj-name as character no-undo.            /* Для управл. условием where в запросе (для одноимённого поля) */

/* ----------------------------------------------------- */

define buffer buf_clients for ub.clients.

/* ----------------------------------------------------- */
function fnc-DD-MM-YYYY returns character 
(input p-dat-date as date) forward.


DEFINE temp-table tt-gds-list no-undo
  field   gds-code    like ub.goods.gds-code
  field   artic       like ub.goods.artic
  field   prod-code   like ub.goods.prod-code
  field   prod-type   like ub.goods.prod-type
  field   gds-name    like ub.goods.gds-name
  field   oss-name    as character
  INDEX   pi          IS PRIMARY UNIQUE
          gds-code
.

define buffer buf_shop for ub.shop.
define buffer buf_store for ub.store.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-gds-attr for ub.chk-gds-attr.
define buffer buf_chk-gds-pay for ub.chk-gds-pay.
define buffer buf_chk-pay-attr  for ub.chk-pay-attr .
define buffer buf_bar-code for ub.bar-code.
define buffer buf_goods for ub.goods.
define buffer buf_goods-attr for ub.goods-attr.
define buffer buf_obj-list for obj-list.
define buffer buf_ext-classif for ub.ext-classif.
define buffer buf_OperServ for ub.OperServ.

define variable Lines_Counter as integer no-undo .
define stream OutStr-html.
define stream MyWatch-strm. /* задать в области определения переменных */

if p-rid-list-oss <> "" and p-rid-list-oss <> ?
then do :
  p-rid-list-oss = trim(p-rid-list-oss, {&delim-cmd}) .
  do ii = 1 to num-entries(p-rid-list-oss) :
    v-id = int64(entry(ii, p-rid-list-oss, {&delim-cmd})) .
    for first buf_OperServ no-lock where buf_OperServ.Id = v-id,
        each buf_goods-attr no-lock where buf_goods-attr.attr-code = {&attr-oper-serv-id}
                                      and buf_goods-attr.attr-value = string(buf_OperServ.id),
        first buf_goods where buf_goods.gds-code = buf_goods-attr.gds-code  :
      find first tt-gds-list where tt-gds-list.gds-code  = buf_goods.gds-code no-error.
      if not available tt-gds-list
      then do :
        create tt-gds-list .
        assign
          tt-gds-list.artic     = buf_goods.artic
          tt-gds-list.gds-code  = buf_goods.gds-code
          tt-gds-list.gds-name  = buf_goods.gds-name
          tt-gds-list.prod-code = buf_goods.prod-code
          tt-gds-list.prod-type = buf_goods.prod-type
          tt-gds-list.oss-name  = buf_OperServ.OsName
        .
      end.
    end.      
  end.
end.
else do :
  for each buf_goods-attr no-lock where buf_goods-attr.attr-code = {&attr-oper-serv-id},
     first buf_goods no-lock where buf_goods.gds-code = buf_goods-attr.gds-code,
     first buf_OperServ no-lock where string(buf_OperServ.id) = buf_goods-attr.attr-value :
    find first tt-gds-list where tt-gds-list.gds-code  = buf_goods.gds-code no-error.
    if not available tt-gds-list
    then do :
      create tt-gds-list .
      assign
        tt-gds-list.artic     = buf_goods.artic
        tt-gds-list.gds-code  = buf_goods.gds-code
        tt-gds-list.gds-name  = buf_goods.gds-name
        tt-gds-list.prod-code = buf_goods.prod-code
        tt-gds-list.prod-type = buf_goods.prod-type
        tt-gds-list.oss-name  = buf_OperServ.OsName
      .
    end.
  end.
end.

run My-Rep.

run waitfram-hide in this-procedure .

/* **********************  Internal Procedures  *********************** */


procedure My-Rep:

  run get-full-path-RepViewer(output v-full-path-RepView).    /* Перед работой с "Просмотровщиком отчёта" (main.exe) - убедимся, что он существует и получим полный путь к нему. */

  run get-report-num in parParentProc(output g#report-num).   /* Получим СТАНДАРТНЫМ МЕТОДОМ ТН номер файла отчёта. */

  run define-full-path-Report(input g#report-num, output v-file-name-rep-htm).   /* Сформируем стандартизованное в ТН имя файла отчёта. */

  run create-file(v-file-name-rep-htm).   /* Создадим на диске пустой файл со сформированным по стандарту именем файла. */


  run waitfram-show in this-procedure ("Подождите ...").
  

  Lines_Counter = 0 .
  

  v-period = "Период: " +
  (if X-TOG-Shift then ("С " + fnc-DD-MM-YYYY(date(string(X-Date-Start,"99/99/9999"))) + ", смена № "  + string(X-Shift-Start) +
                       " по " + fnc-DD-MM-YYYY(date(string(X-Date-End,"99/99/9999"))) + ", смена № " + string(X-Shift-End))
                  else
                       ("C " + fnc-DD-MM-YYYY(date(string(X-Date-Start,"99/99/9999"))) + " по " + fnc-DD-MM-YYYY(date(string(X-Date-End,"99/99/9999"))) )
    ).
    
  v-oss-list = "Платежные агенты: " .  
  if p-rid-list-oss <> "" and p-rid-list-oss <> ?
  then do :
    for each tt-gds-list no-lock :
      v-oss-list = v-oss-list + tt-gds-list.oss-name + ", " .
    end.
    v-oss-list = right-trim(v-oss-list, ", ") .
  end.
  else do :
    v-oss-list = v-oss-list + "Все" .
  end.
    
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
    '<TABLE name="1"  fit_to_page="true" orientation="portrait" CELLSPACING="0" BORDER="0">'skip
    '<thead>' skip
  .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 140px;"></td>' skip
    '<td style="width: 90px;"></td>' skip
    '<td style="width: 90px;"></td>' skip
    '<td style="width: 140px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '</tr>' skip
  .
                        
 
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="8" style="text-align: center; font-weight:bold;">Информация о совершенных действиях</td>' skip
    '</tr>' skip   
    '<tr>' skip
    '<td colspan="8" style="text-align: left; font-weight:bold;">' + v-period + '</td>' skip
    '</tr>' skip  
    '<tr>' skip
    '<td colspan="8" style="text-align: left; font-weight:bold;">' + v-oss-list + '</td>' skip
    '</tr>' skip 
    '<tr>' skip
    '<td colspan="8" style="text-align: left; font-weight:bold;"><br></td>' skip
    '</tr>' skip
    '<tr>' skip
    '<td colspan="8" style="text-align: left; font-weight:bold;"><br></td>' skip
    '</tr>' skip
    '</thead>' skip
  .  
    
  put stream OutStr-html unformatted
      '     <tbody>' skip
      '       <tr>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver; height: 30px">№ АЗС</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Наименование продукта</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Уникальный номер Сертификата</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Дата оплаты</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Время оплаты</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Сумма оплаты</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Тип оплаты</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">RRN операции</th>' skip
      '       </tr>' skip
      '       <tr>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">1</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">2</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">3</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">4</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">5</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">6</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">7</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">8</th>' skip
      '       </tr>' skip
  . /* Точка для закрытия Put */

  obj_:
  for each obj-list /* _obj: for each obj-list: */
  :
    if x-TOG-Shift = yes then
    do:  /* if x-TOG-Shift = yes */
      if can-find(first ub.chk-doc where
                        ub.chk-doc.obj-type = obj-list.obj-type and
                        ub.chk-doc.obj-code = obj-list.obj-code and
                        ub.chk-doc.shift-date >= X-date-Start and
                        ub.chk-doc.shift-date <= X-date-End and
                        ub.chk-doc.out-code > "" )
      then do:
        run rep/rpychk0.p ( input "r-shftc2"
                        ,input obj-list.obj-type
                        ,input obj-list.obj-code
                        ,input ? /*p-date-from*/
                        ,input ? /*p-date-to*/
                        ,input X-date-Start /*p-shift-date-from*/
                        ,input x-Date-End /*p-shift-date-to*/
                        ,input x-Shift-Start /*p-shift-num-start*/
                        ,input x-Shift-End /*p-shift-num-end*/
                        ,input ? /*p-inkas-code*/
                        ).
        for each buf_chk-doc no-lock where
          buf_chk-doc.obj-type = obj-list.obj-type and
          buf_chk-doc.obj-code = obj-list.obj-code and
          (buf_chk-doc.shift-date > X-date-Start or (buf_chk-doc.shift-date = X-date-Start and buf_chk-doc.shift-num >= x-Shift-Start)) and
          (buf_chk-doc.shift-date < X-date-End or (buf_chk-doc.shift-date = X-date-End and buf_chk-doc.shift-num <= x-Shift-End)) and
          buf_chk-doc.out-code <> ?                       /* Номер расходного документа не пустой. Т.е. учтённые Чеки */
          :
            if lookup(string(buf_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next .
            for each buf_chk-gds no-lock where buf_chk-gds.doc-code = buf_chk-doc.doc-code,   /* Смотрим линии выбранного чека */
            first buf_bar-code no-lock where buf_bar-code.b-code = buf_chk-gds.b-code,
            first tt-gds-list no-lock where tt-gds-list.gds-code = buf_bar-code.gds-code:
              find first buf_chk-gds-attr no-lock where buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
/*                                                    and buf_chk-gds-attr.line-num = buf_chk-gds.line-num*/
                                                    and buf_chk-gds-attr.attr-code = "agent-gd-code" no-error.   
              find first buf_chk-gds-pay no-lock where buf_chk-gds-pay.doc-code = buf_chk-gds.doc-code
                                                   and buf_chk-gds-pay.b-code = buf_chk-gds.b-code no-error .
              v-rrn = "" .
              for each buf_chk-pay-attr no-lock
                where  buf_chk-pay-attr.doc-code = buf_chk-doc.doc-code 
                and buf_chk-pay-attr.attr-code = "RRN" :
                v-rrn = buf_chk-pay-attr.attr-value.
                if v-rrn > ""
                then leave .
              end.       
              if v-rrn = "" then 
              for first buf_chk-pay-attr no-lock
                where buf_chk-pay-attr.doc-code = buf_chk-doc.doc-code 
                and buf_chk-pay-attr.attr-code = "cpdoc" :
                v-rrn = buf_chk-pay-attr.attr-value.
                if v-rrn > ""
                then leave .
              end.                                     
              put stream OutStr-html unformatted
                '     <tbody>' skip
                '       <tr>' skip
                '         <th style="text-align: center;">' + obj-list.obj-name + '</th>' skip
                '         <th style="text-align: center;">' + tt-gds-list.gds-name + '</th>' skip
                '         <th style="text-align: center;">' + (if available (buf_chk-gds-attr) then buf_chk-gds-attr.attr-value else "") + '</th>' skip
                '         <th style="text-align: center;">' + (if available (buf_chk-gds-pay) then string(buf_chk-gds-pay.chk-date) else "") + '</th>' skip
                '         <th style="text-align: center;">' + (if available (buf_chk-gds-pay) then string(buf_chk-doc.chk-time,"HH:MM:SS") else "") + '</th>' skip
                '         <th style="text-align: center;">' + (if available (buf_chk-gds-pay) then string(buf_chk-gds-pay.tot-r-b, "->>>>>>>>9.99") else "") + '</th>' skip
                '         <th style="text-align: center;">' + (if available (buf_chk-gds-pay) then (if buf_chk-gds-pay.pay-code <> 1 then "Электронные" else "Наличные") else "") + '</th>' skip
                '         <th style="text-align: center;">' + v-rrn + '</th>' skip
                '       </tr>' skip
              . /* Точка для закрытия Put */
            end.  
        end.    /* FOR EACH buf_chk-doc WHERE ... */
      end.
    end. /* if x-TOG-Shift = yes */
    else
    do:  /* if x-TOG-Shift = no */
      if can-find(first chk-doc where
                        chk-doc.obj-type = obj-list.obj-type and
                        chk-doc.obj-code = obj-list.obj-code and
                        chk-doc.chk-date >= X-date-Start and
                        chk-doc.chk-date <= X-date-End and
                        chk-doc.out-code > "" )
      then do:
        run rep/rpychk0.p ( input "r-autocu"
                        ,input obj-list.obj-type
                        ,input obj-list.obj-code
                        ,input X-date-Start /*p-date-from*/
                        ,input x-Date-End /*p-date-to*/
                        ,input ? /*p-shift-date-from*/
                        ,input ? /*p-shift-date-to*/
                        ,input ? /*p-shift-num-start*/
                        ,input ? /*p-shift-num-end*/
                        ,input ? /*p-inkas-code*/
                        ).
        for each buf_chk-doc no-lock where
          buf_chk-doc.obj-type = obj-list.obj-type and
          buf_chk-doc.obj-code = obj-list.obj-code and
          buf_chk-doc.chk-date >= X-date-Start and
          buf_chk-doc.chk-date <= X-date-End and
          buf_chk-doc.out-code <> ?
          :
            if lookup(string(buf_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next .
            for each buf_chk-gds no-lock where buf_chk-gds.doc-code = buf_chk-doc.doc-code,
            first buf_bar-code no-lock where buf_bar-code.b-code = buf_chk-gds.b-code,
            first tt-gds-list no-lock where tt-gds-list.gds-code = buf_bar-code.gds-code:
              find first buf_chk-gds-attr no-lock where buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
/*                                                    and buf_chk-gds-attr.line-num = buf_chk-gds.line-num*/
                                                    and buf_chk-gds-attr.attr-code = "agent-gd-code" no-error.   
              find first buf_chk-gds-pay no-lock where buf_chk-gds-pay.doc-code = buf_chk-gds.doc-code
                                                   and buf_chk-gds-pay.b-code = buf_chk-gds.b-code no-error .
              v-rrn = "" .
              for each buf_chk-pay-attr no-lock
                where  buf_chk-pay-attr.doc-code = buf_chk-doc.doc-code 
                and buf_chk-pay-attr.attr-code = "RRN" :
                v-rrn = buf_chk-pay-attr.attr-value.
                if v-rrn > ""
                then leave .
              end.       
              if v-rrn = "" then 
              for first buf_chk-pay-attr no-lock
                where buf_chk-pay-attr.doc-code = buf_chk-doc.doc-code 
                and buf_chk-pay-attr.attr-code = "cpdoc" :
                v-rrn = buf_chk-pay-attr.attr-value.
                if v-rrn > ""
                then leave .
              end.                                     
              put stream OutStr-html unformatted
                '     <tbody>' skip
                '       <tr>' skip
                '         <th style="text-align: center;">' + obj-list.obj-name + '</th>' skip
                '         <th style="text-align: center;">' + tt-gds-list.gds-name + '</th>' skip
                '         <th style="text-align: center;">' + (if available (buf_chk-gds-attr) then buf_chk-gds-attr.attr-value else "") + '</th>' skip
                '         <th style="text-align: center;">' + (if available (buf_chk-gds-pay) then string(buf_chk-gds-pay.chk-date) else "") + '</th>' skip
                '         <th style="text-align: center;">' + (if available (buf_chk-gds-pay) then string(buf_chk-doc.chk-time,"HH:MM:SS") else "") + '</th>' skip
                '         <th style="text-align: center;">' + (if available (buf_chk-gds-pay) then string(buf_chk-gds-pay.tot-r-b, "->>>>>>>>9.99") else "") + '</th>' skip
                '         <th style="text-align: center;">' + (if available (buf_chk-gds-pay) then (if buf_chk-gds-pay.pay-code <> 1 then "Электронные" else "Наличные") else "") + '</th>' skip
                '         <th style="text-align: center;">' + v-rrn + '</th>' skip
                '       </tr>' skip
              . /* Точка для закрытия Put */
            end. 
        end.    /* FOR EACH buf_chk-doc WHERE ... */
      end.
    end. /* if x-TOG-Shift = no */
  end.                    /* _obj: for each obj-list: */
  
  put stream OutStr-html unformatted
                '     </tbody>' skip
                '     <tfoot>' skip
                '       <tr>' skip
                '       <td colspan="8" style="text-align: center;"><br></td>' skip
                '       </tr>' skip
                '       <tr>' skip
                '       <td colspan="8" style="text-align: center;"><br></td>' skip
                '       </tr>' skip
                '       <tr>' skip
                '       <td colspan="8" style="text-align: center; font-weight:bold;">ПОДПИСИ СТОРОН</td>' skip
                '       </tr>' skip  
                '       <tr>' skip
                '       <td colspan="8" style="text-align: center;"><br></td>' skip
                '       </tr>' skip
                '       <tr>' skip
                '         <td colspan="3" style="text-align: left;">От имени Банка:</td>' skip
                '         <td style="text-align: center;"></td>' skip
                '         <td colspan="4" style="text-align: left;">От имени Банковского платежного агента:</td>' skip
                '       </tr>' skip
                '       <tr>' skip
                '         <td colspan="3" style="{&css_border_bottom}"><br /></td>' skip
                '         <td style="text-align: center;"></td>' skip
                '         <td colspan="4" style="{&css_border_bottom}"><br /></td>' skip
                '       </tr>' skip
                '       <tr>' skip
                '         <td colspan="2" style="text-align: center; font-style:italic;">(должность)</td>' skip
                '         <td style="text-align: center;"></td>' skip
                '         <td style="text-align: center;"></td>' skip
                '         <td colspan="3" style="text-align: center; font-style:italic;">(должность)</td>' skip
                '         <td style="text-align: center;"></td>' skip
                '       </tr>' skip
                '       <tr>' skip
                '         <td colspan="3" style="{&css_border_bottom}"><br /></td>' skip
                '         <td style="text-align: center;"></td>' skip
                '         <td colspan="4" style="{&css_border_bottom}"><br /></td>' skip
                '       </tr>' skip
                '       <tr>' skip
                '         <td style="text-align: left; font-style:italic;">(Ф.И.О.)</td>' skip
                '         <td style="text-align: center;"></td>' skip
                '         <td style="text-align: center; font-style:italic;">(подпись)</td>' skip
                '         <td style="text-align: center;"></td>' skip
                '         <td style="text-align: left; font-style:italic;">(Ф.И.О.)</td>' skip
                '         <td style="text-align: center;"></td>' skip
                '         <td style="text-align: left; font-style:italic;">(подпись)</td>' skip
                '       </tr>' skip
                '       <tr>' skip
                '         <td colspan="3" ><br></td>' skip
                '         <td style="text-align: center;"><br></td>' skip
                '         <td colspan="3" ><br></td>' skip
                '       </tr>' skip
                '       <tr>' skip
                '         <td colspan="3" style="text-align: left;">м.п (при наличии)</td>' skip
                '         <td style="text-align: center;"></td>' skip
                '         <td colspan="3" style="text-align: left;">м.п (при наличии)</td>' skip
                '       </tr>' skip
                '     </foot>' skip
                '   </table>' skip
                '  </body>' skip
                ' </html>' skip
 . /* Точка для закрытия Put */
  output stream OutStr-html close.
  
  
  run prn-lib-reportviewer-report-name in this-procedure (
  input THIS-PROCEDURE
  ,input v-file-name-rep-htm
  ).


/* **************************************** */

end procedure. /* My-Rep */

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

                                                                                                                                                                                                       

function fnc-DD-MM-YYYY returns character 
(input p-dat-date as date):
/* Преобразование даты в формат: "01.01.2014" */

    define variable result as character no-undo.
    define variable p-str-date as character no-undo.

    p-str-date = replace(string(p-dat-date,'99.99.9999'), "/", ".").

        return p-str-date.

end function.

