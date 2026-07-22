block-level on error undo, throw.
/*

$Revision: 94114751b278, 3560, rls $
$Author: EShklyar $
$Date: 2023/11/27 08:31:19 $
$Workfile: r-orioxl-pokmi.p $
$Archive: rep/r-orioxl-pokmi.p $

Инвентаризационная описись для ПОкМИ

Автор: Шкляр Елена
Дата создания: 10/06/06
Author: Shklyar Elena
Creation date: 10/06/06


*/

define input parameter p-parent-proc as widget-handle no-undo .
define input parameter p-rec-invent  as recid         no-undo .


define variable vss-revision    as character no-undo initial "$Revision: 94114751b278, 3560, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: 2023/11/27 08:31:19 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-orioxl-pokmi.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-orioxl-pokmi.p $":U .
define variable vss-description as character no-undo initial "Инвентаризационная описись СУГ":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-calc.i }
{ str/lib-trn.i  }
{ cmp/r-pril.i   }
{ gbl/waitfram.i }
{ ref/gds-attr.i }
{ gbl/prn-lib.i     }
{ rep/html-conv.i }
{ str/is-sug.i }
{ str/placelib.i }
{ rep/c-temp-place.i }
{ rep/c-place-attr.i }
{ str/trdcalib.i }

define variable g#report-num  as integer no-undo .
define variable g#quest-print as logical no-undo initial yes .
define variable g#log         as logical no-undo .

{ gbl/paramls.i  }

define variable v-host-name   as character no-undo .
define variable p-host-code   as integer   no-undo .
define variable v-doc-num     as character no-undo .
define variable dprice-sale   as decimal   no-undo .
define variable droad-tax     as decimal   no-undo .
define variable dexcise       as decimal   no-undo .
define variable dcurr-price   as decimal   no-undo .
define variable dWaterQnty    as decimal   no-undo .
define variable dWaterCliQnty as decimal   no-undo .
define variable dAddCliQnty   as decimal   no-undo .
define variable dOverCliQnty  as decimal   no-undo .
define variable dOverSum      as decimal   no-undo .
define variable dBookSum      as decimal   no-undo .
define variable dExtraQnty    as decimal   no-undo .
define variable dExtraSum     as decimal   no-undo .
define variable dMissQnty     as decimal   no-undo .
define variable dMissSum      as decimal   no-undo .
define variable t_inv-date    as date      no-undo .
define variable j_LineCount   as integer   no-undo .
define variable v-pl-code     as character no-undo .
define stream Out-Stream.
define stream OutStr-html.
define VARIABLE p-report-id         as character no-undo .
define variable v-file-name-rep-htm as character no-undo .

define variable v-value-character   as character no-undo .
define variable v-CriticalDifInLgas as decimal   no-undo .
define variable v-value-date        as date      no-undo .
define variable v-value-integer     as integer   no-undo .
define variable v-value-logical     as logical   no-undo .
define variable v-param-type        as character no-undo .
define variable v-tth               as handle    no-undo .

define variable delta-mass-qnty     as decimal   no-undo .
define variable CriticalDif         as decimal   no-undo .
define variable v-loc1              as character no-undo .
define variable pl-error-mass       as decimal   no-undo .

define temp-table tt-petrol
  field gds-code   as integer
  field gds-name   as character
  field pl-code    as integer
  field pl-code_   as character
  field pl-type    as character
  field level      as decimal
  field volue      as decimal
  field density    as decimal
  field temp       as decimal
  field qnty       as decimal
  field delta      as decimal
  field density1   as decimal
  field temp1      as decimal
  field qnty1      as decimal
  field delta1     as decimal
  field name-pl    as character
  field volue-pl   as decimal
  field log-pl     as character 
  field place-num  as character
  field place-type as character
  field type_dan   as character
  index pi gds-code pl-code .


define buffer bf_trn-doc         for ub.trn-doc  .
define buffer bf_rvs-doc         for ub.rvs-doc  .
define buffer bf_rvs-line        for ub.rvs-line .
define buffer bf_goods           for ub.goods    .
define buffer bf_object          for ub.clients  .
define buffer bf_place           for ub.place    .
define buffer bf_doc-line        for ub.doc-line.
define buffer bf_c-place-attr    for ub.c-place-attr .
define buffer after_c-place-attr for ub.c-place-attr .
define buffer befor_c-place-attr for ub.c-place-attr .

&scop f-l MonthNameRusCase,Sparse

do
  on error undo, return error return-value
  :
  run WaitFram-Show in this-procedure
    ( input 'Идет формирование отчета, ждите...'
    ) .
  run get-report-num  in p-parent-proc
    (
    output g#report-num
    ) .
  run get-quest-print in p-parent-proc
    (
    output g#quest-print
    ) .
  find first bf_trn-doc no-lock where
    recid( bf_trn-doc ) = p-rec-invent no-error .
  if not available bf_trn-doc
    then 
  do:
    run waitfram-hide in this-procedure .
    message substitute( 'Не найден документ с идентификатором &1.'
      , p-rec-invent
      )
      view-as alert-box error .
    undo, return error .
  end.
  if bf_trn-doc.doc-type     <> {&inventory} or
    bf_trn-doc.ext-doc-type <> {&TDEDT_Inv}
    then 
  do:
    run waitfram-hide in this-procedure .
    message
      'Данная форма только для печати инвентаризации.'
      view-as alert-box error .
    undo, return error .
  end.
  find first bf_rvs-doc no-lock where
    bf_rvs-doc.rvs-code = bf_trn-doc.out-code no-error .
  if not available bf_rvs-doc
    then 
  do:
    run waitfram-hide in this-procedure .
    message substitute( 'Не найдена сверка к документу "&1".'
      , bf_trn-doc.doc-code
      )
      view-as alert-box error .
    undo, return error .
  end.
  if bf_rvs-doc.rvs-type <> {&rvs-control}
    then 
  do:
    run waitfram-hide in this-procedure .
    message substitute( 'Сверка имеет тип "&1", а должен быть "&2".'
      , bf_rvs-doc.rvs-type
      , {&rvs-control}
      )
      view-as alert-box error .
    undo, return error .
  end.
  find first bf_object no-lock where
    bf_object.obj-type = bf_trn-doc.obj-type and
    bf_object.obj-code = bf_trn-doc.obj-code .
  { gbl/hostname.i
      bf_trn-doc.obj-type
      bf_trn-doc.obj-code
      p-host-code
      v-host-name
      no-error
  }
  if error-status :error
    then 
  do:
    run waitfram-hide in this-procedure .
    message
      'Не могу определить текущую фирму.'
      view-as alert-box error .
    undo, return error .
  end.
  if bf_trn-doc.host-code <> p-host-code
    then 
  do:
    run waitfram-hide in this-procedure .
    message
      'Ошибка определения текущей фирмы.'
      view-as alert-box error .
    undo, return error .
  end.
  assign
    t_inv-date = ( if bf_trn-doc.status_ = {&fact} then bf_trn-doc.fact-date else bf_trn-doc.doc-date )
    .

  define variable v-prikaz-num  as character no-undo .
  define variable v-prikaz-date as character no-undo .
  define variable v-doc-date    as character no-undo .
  define variable p-type        as character no-undo .      
  define variable v-pos-agent   as character no-undo .
  define variable v-fio-agent   as character no-undo .
  define variable v-pos-player1 as character no-undo .
  define variable v-fio-player1 as character no-undo .
  define variable v-pos-player2 as character no-undo .
  define variable v-fio-player2 as character no-undo .
  define variable v-pos-player3 as character no-undo .
  define variable v-fio-player3 as character no-undo .
  
  { str/tdatinv-val.i
          bf_trn-doc.doc-code
          {&trdcattr-inv-date}
          v-doc-date
          p-type
          no-error
      }    
  { str/tdatinv-val.i
          bf_trn-doc.doc-code
          {&trdcattr-prikaz-number}
          v-prikaz-num
          p-type
          no-error
      }
  { str/tdatinv-val.i
          bf_trn-doc.doc-code
          {&trdcattr-prikaz-date}
          v-prikaz-date
          p-type
          no-error
      }  

  { str/tdatinv-val.i
          bf_trn-doc.doc-code
          {&trdcattr-fio-agent}
          v-fio-agent
          p-type
          
      }
  { str/tdatinv-val.i
          bf_trn-doc.doc-code
          {&trdcattr-pos-agent}
          v-pos-agent
          p-type
          no-error
      }
  { str/tdatinv-val.i
          bf_trn-doc.doc-code
          {&trdcattr-fio-player1}
          v-fio-player1
          p-type
          no-error
      }
  { str/tdatinv-val.i
          bf_trn-doc.doc-code
          {&trdcattr-pos-player1}
          v-pos-player1
          p-type
          no-error
      }
  { str/tdatinv-val.i
          bf_trn-doc.doc-code
          {&trdcattr-fio-player2}
          v-fio-player2
          p-type
          no-error
      }
  { str/tdatinv-val.i
          bf_trn-doc.doc-code
          {&trdcattr-pos-player2}
          v-pos-player2
          p-type
          no-error
      }
  { str/tdatinv-val.i
          bf_trn-doc.doc-code
          {&trdcattr-fio-player3}
          v-fio-player3
          p-type
          no-error
      }
  { str/tdatinv-val.i
          bf_trn-doc.doc-code
          {&trdcattr-pos-player3}
          v-pos-player3
          p-type
          no-error
      } 
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

  { rep/r-orioxl-pokmi.i }                      
  run shapka-inv .
  run data-print .
  run table-inv .
  run foot-inv .

  put stream OutStr-html unformatted
    '</tfoot>' skip
    '</table>' skip
    '</body>' skip
    '</html>' skip
    .
  output stream OutStr-html close.     
                                                                                                                
  run prn-lib-reportviewer-report-name in this-procedure (
    input this-procedure
    ,input v-file-name-rep-htm
    ) no-error .
  if error-status:error then
  do:
    message return-value view-as alert-box.
    return .
  end.
        
procedure data-print :
  next_:
  for each  bf_rvs-line no-lock where
    bf_rvs-line.rvs-code = bf_rvs-doc.rvs-code  and
    bf_rvs-line.obj-type = bf_rvs-doc.obj-type  and
    bf_rvs-line.obj-code = bf_rvs-doc.obj-code
       
      , first bf_goods    no-lock where
      bf_goods.gds-code = bf_rvs-line.gds-code 
      , first bf_doc-line no-lock where
      bf_trn-doc.doc-code = bf_doc-line.doc-code and
      bf_goods.prod-code = bf_doc-line.prod-code and
      bf_goods.prod-type = bf_doc-line.prod-type and
      bf_goods.artic =  bf_doc-line.artic

      break 
      by bf_rvs-line.gds-code
      by bf_rvs-line.pl-code
      :
      if is-sug(bf_goods.gds-code) then 
      do:          
         next next_ .
      end.
      /* **************************************************************************************** *\
       *                                                                                          *
       * state-measure- (state-measure-qnty, state-measure-cli-qnty) - фактический отстаток;      *
       * system-        (system-qnty,        system-cli-qnty)        - расчетно-книжный остаток; *
       *                                                                                          *
      \* **************************************************************************************** */
      find first bf_place no-lock where
         bf_place.obj-type = bf_rvs-line.obj-type and
         bf_place.obj-code = bf_rvs-line.obj-code and
         bf_place.pl-code  = bf_rvs-line.pl-code  .
      find first tt-petrol where tt-petrol.gds-code = bf_goods.gds-code and tt-petrol.pl-code = bf_rvs-line.pl-code no-error .
      if not available (tt-petrol) then 
      do:
      end.         
      create tt-petrol .
      assign
         tt-petrol.gds-code = bf_goods.gds-code
         tt-petrol.gds-name = bf_goods.gds-name
         tt-petrol.pl-code  = bf_rvs-line.pl-code
/*         tt-petrol.level    = (bf_rvs-line.state-brutto-qnty - bf_rvs-line.state-measure-qnty  + bf_rvs-line.state-measure-qnty) * 0.001*/
         tt-petrol.level    = bf_rvs-line.state-level-total * 10
         tt-petrol.volue    = bf_rvs-line.state-measure-qnty * 0.001 /*Переводим из л в м3 */
         tt-petrol.density  = bf_rvs-line.state-density * 1000 /*Переводим из г/см3 в кг/м3 */
         tt-petrol.temp     = bf_rvs-line.state-temperature
         tt-petrol.qnty     = round(bf_rvs-line.state-measure-cli-qnty,3)
         tt-petrol.volue-pl = bf_rvs-line.add-qnty * 0.001
         tt-petrol.qnty1    = round((tt-petrol.volue-pl * tt-petrol.density),3)
         tt-petrol.pl-type  = "трубопровод"
         .
    find first c-rvs-doc no-lock where c-rvs-doc.rvs-code = bf_rvs-doc.rvs-code and c-rvs-doc.obj-code = bf_rvs-doc.obj-code and
      c-rvs-doc.obj-type = bf_rvs-doc.obj-type and c-rvs-doc.status_ = {&permitted} .

      for each rvs-line-attr no-lock
         where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
         and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
         and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
         and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
         and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
         :
         case rvs-line-attr.attr-code :
            when "delta-mass-qnty" then 
               do :
                  delta-mass-qnty = decimal(rvs-line-attr.attr-value) .
               end.
            when "CriticalDif" then 
               do :
                  CriticalDif = decimal(rvs-line-attr.attr-value) .
               end.
            when {&place-twice-code} then 
               do :
                  v-loc1 = rvs-line-attr.attr-value .
               end.        
         end case.
      end.  
    define variable pl-rvd-dens as logical   no-undo .
    define variable pl-rvd-lvl  as logical   no-undo .
    define variable pl-rvd-temp as logical   no-undo .
      define variable v-value as character no-undo .
      define variable v-ok    as logical   no-undo .
      run placelib_get-attr  ( input {&place-error-mass}
         ,input bf_rvs-line.obj-code
         ,input bf_rvs-line.obj-type
         ,input bf_rvs-line.pl-code
         ,output v-value
         ,output v-ok      ) no-error.
      if not v-ok then pl-error-mass = ?.
      else pl-error-mass = decimal(v-value) .
      tt-petrol.log-pl = if tt-petrol.volue-pl <> 0 then "заполнено" else "не заполнено" .
      tt-petrol.delta = bf_rvs-line.state-measure-cli-qnty * delta-mass-qnty / 100 . /*Погрешность*/
      tt-petrol.delta1 = bf_rvs-line.state-add-qnty * bf_rvs-line.state-density * pl-error-mass / 100 .
      if v-loc1 <> "" then  tt-petrol.pl-code_ = string(bf_place.loc1) + "," + v-loc1 .
      else tt-petrol.pl-code_ = string(bf_place.loc1) .
      
    run placelib_get-attr  ( input {&place-passp-num}
      ,input bf_place.obj-code
      ,input bf_place.obj-type
      ,input bf_place.pl-code
      ,output v-value
      ,output v-ok      ) no-error.
      
    tt-petrol.place-num = v-value .

    run placelib_get-attr  ( input {&place-passp-type}
      ,input bf_place.obj-code
      ,input bf_place.obj-type
      ,input bf_place.pl-code
      ,output v-value
      ,output v-ok      ) no-error.
      
    tt-petrol.place-type = v-value .
    define variable corr-date as date no-undo .
    define variable corr-time as integer no-undo .
    find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = bf_rvs-line.rvs-code and
    ub.inv-doc-attr.attr-code = "create_date" no-error .
    if available (ub.inv-doc-attr) then corr-date = date(ub.inv-doc-attr.attr-value). else corr-date = c-rvs-doc.corr-date .
    find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = bf_rvs-line.rvs-code and
    ub.inv-doc-attr.attr-code = "create_time" no-error .
    if available (ub.inv-doc-attr) then corr-time = integer(ub.inv-doc-attr.attr-value). else corr-time = c-rvs-doc.corr-time . 
    
    if not get_meas(bf_rvs-line.obj-code, bf_rvs-line.obj-type, bf_rvs-line.pl-code,corr-date, corr-time) then
      tt-petrol.type_dan = "PВД" .
    else 
    do:

      run c-place_get-attr (input {&place-rvd-lvl}
        ,input bf_rvs-line.obj-code
        ,input bf_rvs-line.obj-type
        ,input bf_rvs-line.pl-code
        ,input corr-date
        ,input corr-time
        ,output v-value ) no-error .
      
      if v-value = "" then pl-rvd-lvl = false .
      else pl-rvd-lvl = not logical(v-value) .
  
      run c-place_get-attr (input {&place-rvd-tmp}
        ,input bf_rvs-line.obj-code
        ,input bf_rvs-line.obj-type
        ,input bf_rvs-line.pl-code
        ,input corr-date
        ,input corr-time
        ,output v-value ) no-error .
      if v-value = "" then pl-rvd-temp = false .
      else pl-rvd-temp = not logical(v-value) . 
      
      run c-place_get-attr (input {&place-rvd-dnsty}
        ,input bf_rvs-line.obj-code
        ,input bf_rvs-line.obj-type
        ,input bf_rvs-line.pl-code
        ,input corr-date
        ,input corr-time
        ,output v-value ) no-error .
      if v-value = "" then pl-rvd-dens = false .
      else pl-rvd-dens = not logical(v-value) .
            
      if pl-rvd-dens or pl-rvd-lvl or pl-rvd-temp then tt-petrol.type_dan = "PВД" .
      else tt-petrol.type_dan = "AВД" .
    end.

  end. /* for each bf_rvs-line */
end procedure .
  run waitfram-hide  in this-procedure .
end. /* on error */




procedure table-inv:
  put stream OutStr-html unformatted
    '<Thead>' skip
    '<TR><TD colspan="86" style="height: 14px;"></TD></TR>' skip
    '<TR><TD colspan="86">При инвентаризации в резервуарах АЗС/АЗК установлено следующее:</TD></TR>' skip
    '</Thead>' skip
    .  
  put stream OutStr-html unformatted
    '<TR style="height: 55px">' skip
    '<TD text_wrap="true" colspan = "4" rowspan = "2" style="text-align: center; border: 1px solid black;">№</TD>' skip
    '<TD text_wrap="true" colspan = "14" style="text-align: center; border: 1px solid black;">Нефтепродукт</TD>' skip
    '<TD text_wrap="true" colspan = "9" rowspan = "2" style="text-align: center; border: 1px solid black;">Тип, номер резервуара</TD>' skip
    '<TD text_wrap="true" colspan = "6" rowspan = "2" style="text-align: center; border: 1px solid black;">Тип ввода данных</TD>' skip
    '<TD text_wrap="true" colspan = "9" rowspan = "2" style="text-align: center; border: 1px solid black;">Уровень наполнения резервуара, мм</TD>' skip
    '<TD text_wrap="true" colspan = "8" rowspan = "2" style="text-align: center; border: 1px solid black;">Объем нефтепродукта, м3</TD>' skip
    '<TD text_wrap="true" colspan = "9" rowspan = "2" style="text-align: center; border: 1px solid black;">Плотность нефтепродукта, кг/м3</TD>' skip
    '<TD text_wrap="true" colspan = "9" rowspan = "2" style="text-align: center; border: 1px solid black;">Температура нефтепродукта, °С</TD>' skip
    '<TD text_wrap="true" colspan = "9" rowspan = "2" style="text-align: center; border: 1px solid black;">Масса нефтепродукта, кг</TD>' skip
    '<TD text_wrap="true" colspan = "9" rowspan = "2" style="text-align: center; border: 1px solid black;">Погрешность измерения, кг*</TD>' skip
    '</TR>'skip       

    '<TR style="height: 35px">' skip
    '<TD text_wrap="true" colspan = "9" style="text-align: center; border: 1px solid black;">наимен.</TD>' skip
    '<TD text_wrap="true" colspan = "5" style="text-align: center; border: 1px solid black;">код</TD>' skip
    '</TR>'skip                           
    
    '<TR>' skip
    '<TD colspan = "4" style="text-align: center; border: 1px solid black;">1</TD>' skip
    '<TD colspan = "9" style="text-align: center; border: 1px solid black;">2</TD>' skip
    '<TD colspan = "5" style="text-align: center; border: 1px solid black;">3</TD>' skip
    '<TD colspan = "9" style="text-align: center; border: 1px solid black;">4</TD>' skip
    '<TD colspan = "6" style="text-align: center; border: 1px solid black;">5</TD>' skip
    '<TD colspan = "9" style="text-align: center; border: 1px solid black;">6</TD>' skip
    '<TD colspan = "8" style="text-align: center; border: 1px solid black;">7</TD>' skip
    '<TD colspan = "9" style="text-align: center; border: 1px solid black;">8</TD>' skip
    '<TD colspan = "9" style="text-align: center; border: 1px solid black;">9</TD>' skip
    '<TD colspan = "9" style="text-align: center; border: 1px solid black;">10</TD>' skip
    '<TD colspan = "9" style="text-align: center; border: 1px solid black;">11</TD>' skip
    '</TR>'skip     
    .
  assign
    j_LineCount = 0
    .
  for each tt-petrol:
    j_LineCount = j_LineCount + 1 .
    put stream OutStr-html unformatted
      '<TR>' skip
      '<TD colspan = "4" text_wrap="true" style="text-align: center; border: 1px solid black;">' + string(j_LineCount) + '</TD>' skip
      '<TD colspan = "9" text_wrap="true" style="text-align: center; border: 1px solid black;">' + tt-petrol.gds-name + '</TD>' skip
      '<TD colspan = "5" text_wrap="true" style="text-align: center; border: 1px solid black;">' + string(tt-petrol.gds-code) + '</TD>' skip
      '<TD colspan = "9" text_wrap="true" style="text-align: center; border: 1px solid black;">' + string(tt-petrol.place-type) + " " + string(tt-petrol.place-num) + '</TD>' skip
      '<TD colspan = "6" text_wrap="true" style="text-align: center; border: 1px solid black;">' + string(tt-petrol.type_dan) + '</TD>' skip
      '<TD colspan = "9" text_wrap="true" num="0" val="' + fnc-convert-dot-to-colon(tt-petrol.level,"->>>>>>>>>>>9",0) + '" style="text-align: center; border: 1px solid black;">' + fnc-convert-dot-to-colon(tt-petrol.level,"->>>>>>>>>>>9",0) + '</TD>' skip
      '<TD colspan = "8" text_wrap="true" num="0.000" val="' + fnc-convert-dot-to-colon(tt-petrol.volue,"->>>>>>>>>>>9.999",3) + '" style="text-align: center; border: 1px solid black;">' + fnc-convert-dot-to-colon(tt-petrol.volue,"->>>>>>>>>>>9.999",3) + '</TD>' skip
      '<TD colspan = "9" text_wrap="true" num="0.0" val="' + fnc-convert-dot-to-colon(tt-petrol.density,"->>>>>>>>>>>9.9",1) + '" style="text-align: center; border: 1px solid black;">' + fnc-convert-dot-to-colon(tt-petrol.density,"->>>>>>>>>>>9.9",1) + '</TD>' skip
      '<TD colspan = "9" text_wrap="true" num="0.0" val="' + fnc-convert-dot-to-colon(tt-petrol.temp,"->>>>>>>>>>>9.9",1) + '" style="text-align: center; border: 1px solid black;">' + fnc-convert-dot-to-colon(tt-petrol.temp,"->>>>>>>>>>>9.9",1) + '</TD>' skip
      '<TD colspan = "9" text_wrap="true" num="0.000" val="' + fnc-convert-dot-to-colon(tt-petrol.qnty,"->>>>>>>>>>>9.999",3) + '" style="text-align: center; border: 1px solid black;">' + fnc-convert-dot-to-colon(tt-petrol.qnty,"->>>>>>>>>>>9.999",3) + '</TD>' skip
      '<TD colspan = "9" text_wrap="true" num="0.000" val="' + fnc-convert-dot-to-colon(tt-petrol.delta,"->>>>>>>>>>>9.999",3) + '" style="text-align: center; border: 1px solid black;">' + fnc-convert-dot-to-colon(tt-petrol.delta,"->>>>>>>>>>>9.999",3) + '</TD>' skip
      '</TR>'skip     
      .
  end.
  
  put stream OutStr-html unformatted
    '<Thead>' skip
    '<TR><TD colspan="86" style="height: 14px;"></TD></TR>' skip
    '<TR><TD colspan="86">Наличие нефтепродуктов в технологических трубопроводах и оборудовании:</TD></TR>' skip
    '</Thead>' skip
    .

  put stream OutStr-html unformatted
    '<TR style="height: 65px">' skip
    '<TD text_wrap="true" colspan = "4" rowspan = "2" style="text-align: center; border: 1px solid black;">№</TD>' skip
    '<TD text_wrap="true" colspan = "14" style="text-align: center; border: 1px solid black;">Нефтепродукт</TD>' skip
    '<TD text_wrap="true" colspan = "8" rowspan = "2" style="text-align: center; border: 1px solid black;">Наим. участка техн. трубопровода (оборуд)</TD>' skip
    '<TD text_wrap="true" colspan = "10" rowspan = "2" style="text-align: center; border: 1px solid black;">Вместимость (объем) участка трубопровода (оборуд), м3</TD>' skip
    '<TD text_wrap="true" colspan = "10" rowspan = "2" style="text-align: center; border: 1px solid black;">Факт заполнения на момент инвентар (заполнено/ не заполнено)</TD>' skip
    '<TD text_wrap="true" colspan = "10" rowspan = "2" style="text-align: center; border: 1px solid black;">Плотность нефтепродукта, кг/м3</TD>' skip
    '<TD text_wrap="true" colspan = "10" rowspan = "2" style="text-align: center; border: 1px solid black;">Температура нефтепродукта, °С</TD>' skip
    '<TD text_wrap="true" colspan = "10" rowspan = "2" style="text-align: center; border: 1px solid black;">Масса нефтепродукта, кг</TD>' skip
    '<TD text_wrap="true" colspan = "10" rowspan = "2" style="text-align: center; border: 1px solid black;">Погрешность измерения, кг**</TD>' skip
    '</TR>'skip       

    '<TR style="height: 65px">' skip
    '<TD text_wrap="true" colspan = "9" style="text-align: center; border: 1px solid black;">наимен.</TD>' skip
    '<TD text_wrap="true" colspan = "5" style="text-align: center; border: 1px solid black;">код</TD>' skip
    '</TR>'skip                           
    
    '<TR>' skip
    '<TD colspan = "4" style="text-align: center; border: 1px solid black;">1</TD>' skip
    '<TD colspan = "9" style="text-align: center; border: 1px solid black;">2</TD>' skip
    '<TD colspan = "5" style="text-align: center; border: 1px solid black;">3</TD>' skip
    '<TD colspan = "8" style="text-align: center; border: 1px solid black;">4</TD>' skip
    '<TD colspan = "10" style="text-align: center; border: 1px solid black;">5</TD>' skip
    '<TD colspan = "10" style="text-align: center; border: 1px solid black;">6</TD>' skip
    '<TD colspan = "10" style="text-align: center; border: 1px solid black;">7</TD>' skip
    '<TD colspan = "10" style="text-align: center; border: 1px solid black;">8</TD>' skip
    '<TD colspan = "10" style="text-align: center; border: 1px solid black;">9</TD>' skip
    '<TD colspan = "10" style="text-align: center; border: 1px solid black;">10</TD>' skip
    '</TR>'skip     
    .
  assign
    j_LineCount = 0
    .
  for each tt-petrol:
    j_LineCount = j_LineCount + 1 .
    put stream OutStr-html unformatted
      '<TR>' skip
      '<TD colspan = "4" text_wrap="true" style="text-align: center; border: 1px solid black;">' + string(j_LineCount) + '</TD>' skip
      '<TD colspan = "9" text_wrap="true" style="text-align: center; border: 1px solid black;">' + tt-petrol.gds-name + '</TD>' skip
      '<TD colspan = "5" text_wrap="true" style="text-align: center; border: 1px solid black;">' + string(tt-petrol.gds-code) + '</TD>' skip
      '<TD colspan = "8" text_wrap="true" style="text-align: center; border: 1px solid black;">' + string(tt-petrol.pl-type) + '</TD>' skip
      '<TD colspan = "10" text_wrap="true" num="0.000" val="' + fnc-convert-dot-to-colon(tt-petrol.volue-pl,"->>>>>>>>>>>9.999",3) + '" style="text-align: center; border: 1px solid black;">' + fnc-convert-dot-to-colon(tt-petrol.volue-pl,"->>>>>>>>>>>9.999",3) + '</TD>' skip
      '<TD colspan = "10" text_wrap="true" style="text-align: center; border: 1px solid black;">' + string(tt-petrol.log-pl) + '</TD>' skip
      '<TD colspan = "10" text_wrap="true" num="0.0" val="' + fnc-convert-dot-to-colon(tt-petrol.density,"->>>>>>>>>>>9.9",1) + '" style="text-align: center; border: 1px solid black;">' + fnc-convert-dot-to-colon(tt-petrol.density,"->>>>>>>>>>>9.9",1) + '</TD>' skip
      '<TD colspan = "10" text_wrap="true" num="0.0" val="' + fnc-convert-dot-to-colon(tt-petrol.temp,"->>>>>>>>>>>9.9",1) + '" style="text-align: center; border: 1px solid black;">' + fnc-convert-dot-to-colon(tt-petrol.temp,"->>>>>>>>>>>9.9",1) + '</TD>' skip
      '<TD colspan = "10" text_wrap="true" num="0.000" val="' + fnc-convert-dot-to-colon(tt-petrol.qnty1,"->>>>>>>>>>>9.999",3) + '" style="text-align: center; border: 1px solid black;">' + fnc-convert-dot-to-colon(tt-petrol.qnty1,"->>>>>>>>>>>9.999",3) + '</TD>' skip
/*      '<TD colspan = "10" text_wrap="true" style="text-align: center; border: 1px solid black;"></TD>' skip*/
      '<TD colspan = "10" text_wrap="true" num="0.000" val="' + fnc-convert-dot-to-colon(tt-petrol.delta1,"->>>>>>>>>>>9.999",3) + '" style="text-align: center; border: 1px solid black;">' + fnc-convert-dot-to-colon(tt-petrol.delta1,"->>>>>>>>>>>9.999",3) + '</TD>' skip
      '</TR>'skip     
      .
  end.  
end procedure .

PROCEDURE get-report-num :

  define output parameter p-report-num as integer no-undo .

  do
    on error undo, return error return-value
    :
    run gbl/getrpnum.p (output p-report-num).
  end.

END PROCEDURE.
                              