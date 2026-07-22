block-level on error undo, throw.
/*

$Revision: 27edb21b3adc, 2237, rls $
$Author: EShklyar $
$Date: Wed Dec 25 15:24:00 2019 +0300 $
$Workfile: r-ext_dif-price.p $
$Archive: rep/r-ext_dif-price.p $

Отчет по изменению учетных цен

Автор: Шкляр Елена 
Дата создания: 08/07/14
Author: Elena Shklyar
Creation date: 08/07/14

*/

define variable vss-revision    as character no-undo init "$Revision: 27edb21b3adc, 2237, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Wed Dec 25 15:24:00 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-ext_dif-price.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-ext_dif-price.p $":U .
define variable vss-description as character no-undo init "Отчет по изменению учетных цен".
{ cmp/vssrevis.i }

/*define variable parparentproc           as handle           no-undo.*/
/*parparentproc = my-handle .*/
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-page1.i      }
{ cmp/r-pril.i   }
{ ref/cp-attr.i }
{ str/lib-trn.i  }
{ str/trdcalib.i }
{ rep/w-rep.i    }
{ rep/fmtcli.i   }
{ rep/torgconf.i }

{ str/getctxtp.i def }

{ gbl/paramls.i  }
{ ref/gds-attr.i }
{ gbl/prn-lib.i     }
{ rep/html-conv.i }
{ gbl/thbjattr.i     }

/* Temp-Table and Buffer definitions                                    */
/*{ gbl/getcntxt.i def }*/
/*{ gbl/getcntxt.i get }*/
                  
define stream Out-Stream.
define stream OutStr-html.

define VARIABLE p-report-id          as character no-undo .
define variable v-file-name-rep-htm  as character no-undo .
define VARIABLE v-attr-value         as character no-undo .
define variable v-obj-type           as character no-undo .
define variable v-obj-code           as integer   no-undo .
define variable v-obj-name           as character no-undo .
define variable v-period             as character no-undo .
define variable v-list-obj           as character no-undo .
define variable v-print-date         as character no-undo .
define variable v-reasons-for-return as character no-undo .
define variable v-itog               as decimal   no-undo .
define variable v-sum-itog           as decimal   no-undo .
define variable v-name-ext-doc-type  as character no-undo .

define temp-table tt-doc-line
  field obj-code     as integer
  field obj-type     as character
  field obj-name     as character
  field shift-date   as date
  field shift-num    as character
  field doc-date     as date
  field ext-doc-type as character
  field doc-code     as character
  field gds-code     as integer
  field gds-name     as character
  field qnty         as decimal
  field sum_doc      as decimal
  field sum_base     as decimal
  field sum_dif      as decimal
  index pi gds-code doc-code .



define buffer buf_clients     for ub.clients .
define buffer buf_chk-disnt   for ub.chk-discnt .
define buffer buf_chk-gds     for ub.chk-gds .
define buffer buf_bar-code    for ub.bar-code .
define buffer buf_goods       for ub.goods .
define buffer buf_trn-doc     for ub.trn-doc .
define buffer buf_doc-line    for ub.doc-line .
define buffer buf_tt-doc-line for tt-doc-line .

do
  on error undo, return error return-value
  :

  find first obj-list no-error .
  if not available obj-list then 
  do:
    message
      "Не указан объект для формирования отчета!"
      view-as alert-box error.
    undo, return error.
  end.
  
  /*Данные для шапки*/
  /*Период*/
  if x-TOG-Shift then 
  do:
    v-period = "Смены с " + string (x-Shift-Start) + " по " + string (x-Shift-End) + " За период с " + string (x-Date-Start,"99.99.9999") + " по " + string (x-Date-End,"99.99.9999") .
  end.
  else 
  do:
    v-period = "За период с " + string (x-Date-Start,"99.99.9999") + " по " + string (x-Date-End,"99.99.9999") .
  end.      

  /*Название объекта*/
  run clients-write(INPUT v-cntxp-curr-host-code, INPUT {&cmp}, OUTPUT v-obj-name) no-error .    
  /*Дата и время печати*/
  DEFINE VARIABLE v-today as date    no-undo .
  DEFINE VARIABLE v-time  as integer no-undo .
  run cur-time in this-procedure (
    output v-today
    , output v-time
    ).
  v-print-date = "Дата печати: " + string (v-today,"99.99.9999") + ", время: " + string(truncate (v-time / 3600, 0)) + ":" + string((v-time modulo 3600) / 60,"99")  + ":" + string((v-time modulo 3600) / 360,"99").     

  for each obj-list no-lock:
    if v-list-obj = "" then v-list-obj = string(obj-list.obj-code).
    else v-list-obj = v-list-obj + ", " + string(obj-list.obj-code).

    { gbl/getsect.i run obj-list.obj-type obj-list.obj-code {&attr-nakl_par} }
    for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = {&attr-nakl_par_reasons-for-return}  then v-reasons-for-return = v-reasons-for-return + {&comma-char} + thbjattr_thbj-attr.property-value-character .
    end.
    v-reasons-for-return = trim (v-reasons-for-return,{&comma-char}).  
    if x-TOG-Shift then 
    do:
      for each buf_trn-doc no-lock 
        where buf_trn-doc.obj-code = obj-list.obj-code 
        and buf_trn-doc.obj-type = obj-list.obj-type
        and buf_trn-doc.shift-date >= x-Date-Start 
        and buf_trn-doc.shift-date <= x-Date-End
        and buf_trn-doc.doc-type = {&expense}
        and buf_trn-doc.status_ = {&fact}
        and lookup (string(buf_trn-doc.reason-code),v-reasons-for-return,{&comma-char}) > 0:

        if (buf_trn-doc.shift-date = X-date-Start)
          and (buf_trn-doc.shift-num < x-Shift-Start) then next. 
        if (buf_trn-doc.shift-date = X-date-End)
          and (buf_trn-doc.shift-num > x-Shift-End) then next.
        run report .
      end.
    end.
    else 
    do:
      for each buf_trn-doc no-lock 
        where buf_trn-doc.obj-code = obj-list.obj-code 
        and buf_trn-doc.obj-type = obj-list.obj-type
        and buf_trn-doc.doc-date >= x-Date-Start 
        and buf_trn-doc.doc-date <= x-Date-End
        and buf_trn-doc.doc-type = {&expense}
        and buf_trn-doc.status_ = {&fact}
        and lookup (string(buf_trn-doc.reason-code),v-reasons-for-return,{&comma-char}) > 0:
          
        run report .
      end.  
    end.  
  end.

/*Общие данные*/

procedure report:
  for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code,
    first gds-dtl no-lock where gds-dtl.doc-code = buf_doc-line.doc-code and gds-dtl.artic = buf_doc-line.artic and gds-dtl.prod-code = buf_doc-line.prod-code
    and gds-dtl.prod-type = buf_doc-line.prod-type, 
    /*    each ub.parts no-lock where ub.parts.out-code = buf_doc-line.doc-code and ub.parts.obj-code = buf_doc-line.obj-code                    */
    /*      and ub.parts.obj-type = buf_doc-line.obj-type and ub.parts.artic = buf_doc-line.artic and ub.parts.prod-code = buf_doc-line.prod-code*/
    /*        and ub.parts.prod-type = buf_doc-line.prod-type,                                                                                   */
    first buf_goods no-lock where buf_goods.artic = buf_doc-line.artic and buf_goods.prod-code = buf_doc-line.prod-code
    and buf_goods.prod-type = buf_doc-line.prod-type:
    create tt-doc-line .
    assign
      tt-doc-line.obj-code     = buf_trn-doc.obj-code
      tt-doc-line.obj-type     = buf_trn-doc.obj-type
      tt-doc-line.obj-name     = obj-list.obj-name
      tt-doc-line.shift-date   = buf_trn-doc.shift-date
      tt-doc-line.shift-num    = buf_trn-doc.shift-name
      tt-doc-line.doc-date     = buf_trn-doc.doc-date
      tt-doc-line.ext-doc-type = buf_trn-doc.ext-doc-type
      tt-doc-line.doc-code     = buf_trn-doc.doc-code
      tt-doc-line.gds-code     = buf_goods.gds-code
      tt-doc-line.gds-name     = buf_goods.gds-name
      tt-doc-line.qnty         = gds-dtl.fact-qnty
      tt-doc-line.sum_doc      = (gds-dtl.price-rubl * 100 / (buf_doc-line.VAT-pc + 100)) * tt-doc-line.qnty
      tt-doc-line.sum_base     = (buf_doc-line.price-rubl * 100 / (buf_doc-line.VAT-pc + 100)) * tt-doc-line.qnty
      tt-doc-line.sum_dif      = tt-doc-line.sum_doc - tt-doc-line.sum_base      .      
  end.
end procedure.      
   
  /*печать*/

  run get-report-num (output p-report-id).
    
  v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".   
                        
  output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8'.
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
    /*Первая таблица*/
    '<TABLE name="1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
    '<thead>' skip
    .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td style="width: 160px;"></td>' skip
    '<td style="width: 160px;"></td>' skip
    '<td style="width: 160px;"></td>' skip
    '<td style="width: 160px;"></td>' skip
    '<td style="width: 160px;"></td>' skip
    '<td style="width: 160px;"></td>' skip
    '<td style="width: 160px;"></td>' skip
    '<td style="width: 160px;"></td>' skip
    '<td style="width: 160px;"></td>' skip
    '<td style="width: 160px;"></td>' skip
    '<td style="width: 160px;"></td>' skip
    '<td style="width: 160px;"></td>' skip
    '</tr>' skip
    .
                        
 
  put stream OutStr-html unformatted
    '<TR><TD colspan="12"></TD></TR>' skip
    '<TR>' skip
    '<TD colspan="12" style="font-weight: bold;">Отчет по изменению учетных цен</TD>' skip
    '</TR>'skip
                                
    '<TR>' skip
    '<TD colspan="12">' + v-period + '</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="12">' + v-obj-name + '</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="12">Выбор объекта:</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="12">' + "АЗК №" + v-list-obj + " маг" + '</TD>' skip
    '</TR>'skip

    /*    '<TR>' skip                                      */
    /*    '<TD colspan="12">' + v-print-date + '</TD>' skip*/
    /*    '</TR>'skip                                      */

    '</thead>' skip
    '<tbody>' skip
    .
  put stream OutStr-html unformatted
    '<TR>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold;">№АЗК</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold;">Дата смены</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold;">№ смены</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold;">Дата документа</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold;">Тип документа</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold;">Номер документа</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold;">Внутренний код товара</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold;">Название товара</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold;">Кол-во по документу</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold;">Сумма в ценах документа руб. (без НДС)</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold;">Сумма в учетных ценах в БД руб. (без НДС)</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight: bold;">Разница между суммой учетных цен БД и суммой цен документа руб. (без НДС)</TD>' skip
    '</TR>'skip       
                    
    .
    
    
  for each obj-list:
    v-itog = 0 .
    for each buf_tt-doc-line no-lock where buf_tt-doc-line.obj-code = obj-list.obj-code:
      run ConvertStr-ext-doc-type (input buf_tt-doc-line.ext-doc-type, output v-name-ext-doc-type).
      put stream OutStr-html unformatted
        '<TR>' skip
        '<TD text_wrap="true">' + string(buf_tt-doc-line.obj-name) + '</TD>' skip
        '<TD text_wrap="true">' + if buf_tt-doc-line.shift-date <> ? then string(buf_tt-doc-line.shift-date) + '</TD>' else "" + '</TD>' skip
        '<TD text_wrap="true">' + if buf_tt-doc-line.shift-num <> ? then string(buf_tt-doc-line.shift-num) + '</TD>' else "" + '</td>'skip
        '<TD text_wrap="true">' + string(buf_tt-doc-line.doc-date) + '</TD>' skip
        '<TD text_wrap="true">' + string(v-name-ext-doc-type) + '</TD>' skip
        '<TD text_wrap="true">' + string(buf_tt-doc-line.doc-code) + '</TD>' skip
        '<TD text_wrap="true">' + string(buf_tt-doc-line.gds-code) + '</TD>' skip
        '<TD text_wrap="true">' + string(buf_tt-doc-line.gds-name) + '</TD>' skip
        '<TD text_wrap="true">' + string(buf_tt-doc-line.qnty) + '</TD>' skip
        '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_tt-doc-line.sum_doc,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(buf_tt-doc-line.sum_doc,"->>>>>>>>>>>9.99",2) + '</TD>' skip
        '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_tt-doc-line.sum_base,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(buf_tt-doc-line.sum_base,"->>>>>>>>>>>9.99",2) + '</TD>' skip
        '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_tt-doc-line.sum_dif,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(buf_tt-doc-line.sum_dif,"->>>>>>>>>>>9.99",2) + '</TD>' skip
        '</TR>'skip     
        .
      v-itog = v-itog + buf_tt-doc-line.sum_dif .
    end.
    put stream OutStr-html unformatted
      '<TR>' skip
      '<TD text_wrap="true" style="font-weight: bold;">' + string(obj-list.obj-name + " Итог: ") + '</TD>' skip
      '<TD text_wrap="true"></TD>' skip
      '<TD text_wrap="true"></TD>' skip
      '<TD text_wrap="true"></TD>' skip
      '<TD text_wrap="true"></TD>' skip
      '<TD text_wrap="true"></TD>' skip
      '<TD text_wrap="true"></TD>' skip
      '<TD text_wrap="true"></TD>' skip
      '<TD text_wrap="true"></TD>' skip
      '<TD text_wrap="true"></TD>' skip
      '<TD text_wrap="true"></TD>' skip
      '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(v-itog,"->>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: bold;">' + fnc-convert-dot-to-colon(v-itog,"->>>>>>>>>>>9.99",2) + '</TD>' skip
      '</TR>'skip     
      .
    v-sum-itog = v-sum-itog + v-itog .
  end.
  put stream OutStr-html unformatted
    '<TR>' skip
    '<TD text_wrap="true" style="font-weight: bold;">Итог общий:</TD>' skip
    '<TD text_wrap="true"></TD>' skip
    '<TD text_wrap="true"></TD>' skip
    '<TD text_wrap="true"></TD>' skip
    '<TD text_wrap="true"></TD>' skip
    '<TD text_wrap="true"></TD>' skip
    '<TD text_wrap="true"></TD>' skip
    '<TD text_wrap="true"></TD>' skip
    '<TD text_wrap="true"></TD>' skip
    '<TD text_wrap="true"></TD>' skip
    '<TD text_wrap="true"></TD>' skip
    '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(v-sum-itog,"->>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: bold;">' + fnc-convert-dot-to-colon(v-sum-itog,"->>>>>>>>>>>9.99",2) + '</TD>' skip
    '</TR>'skip     
    .
  put stream OutStr-html unformatted

    '</table>' skip
    '</body>' skip
    '</html>' skip
    .
                            
  output stream OutStr-html close.     
                                                                                                                
  run prn-lib-reportviewer-report-name in this-procedure (
    input THIS-PROCEDURE
    ,input v-file-name-rep-htm
    ).


PROCEDURE get-report-num :

  define output parameter p-report-num as integer no-undo .

  do
    on error undo, return error return-value
    :
    run gbl/getrpnum.p (output p-report-num).
  end.

END PROCEDURE.


procedure clients-write:
    
  DEFINE input PARAMETER   p-obj-code      as integer      no-undo .
  DEFINE INPUT PARAMETER   p-obj-type      as character    no-undo .
  DEFINE OUTPUT PARAMETER  p-obj-name      as character    no-undo .
        
  find first buf_clients no-lock where buf_clients.obj-code = p-obj-code
    and buf_clients.obj-type = p-obj-type no-error .
  if AVAILABLE buf_clients then 
  do:
    p-obj-name = buf_clients.obj-name .
  end.     
end.                                            
end. 

procedure ConvertStr-ext-doc-type: /* Получение наименования код_вида_расходов по полученному элементу из списка наименований */
  /********************************/
  define input parameter p-ext-doc-type as character no-undo.
  define output parameter p-name-ext-doc-type as character no-undo.
  define variable v-num-element as integer no-undo.

  /* Код_вида_расходов. Получение номера элемента в списке кодов */
  v-num-element = lookup(p-ext-doc-type, {&TDEDT_List}).

  /* Получение наименования код_вида_расходов по полученному элементу из списка наименований */
  p-name-ext-doc-type = entry(v-num-element, {&TDEDT_List-full}).
  if p-ext-doc-type <> "" and v-num-element = 0 then
  do:
    message "Ошибка 115." view-as alert-box.
    return.
  end.

end procedure.

