block-level on error undo, throw.
/*

$Revision: e5665df1db10, 792, rls $
$Author: EShklyar $
$Date: Fri Sep 16 16:22:48 2016 +0300 $
$Workfile: r-p-pp.p $
$Archive: rep/r-p-pp.p $

Отчет Сравнительный анализ цен поставщиков

Автор: Чернова Светлана Александровна
Дата создания: 04/26/05
Author: Svetlana Chernova
Creation date: 04/26/05

*/

define variable vss-revision    as character no-undo init "$Revision: e5665df1db10, 792, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Fri Sep 16 16:22:48 2016 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-p-pp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-p-pp.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i   }
{ cmp/r-page1.i  }
{ cmp/breakstr.i }
{ rep/r-cliprp.i def }
{ gbl/paramls.i  }
{ rep/f-fdec.i   }
{ rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
{ rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */
{ ref/grpobj.i  }
{ trg/factord.i }
{ rep/rep-bt.i  }
{ gbl/prn-lib.i "new shared" }
{ trg/factord.i  }
{ rep/html-conv.i }

define input  parameter par-crsa    as logical   no-undo .
define input  parameter par-all     as integer   no-undo .
define input  parameter par-nacenka as logical   no-undo .
define input  parameter par-det-obj as logical   no-undo .

define variable parhost-code as integer no-undo .
parhost-code = v-cntxt-host-code-obj.
define variable kol-post     as integer   no-undo .

define variable v-goods-type as character no-undo .
define variable v-grp        as character no-undo .
define variable v-obj        as character no-undo .
define variable v-num-date   as integer   no-undo .
define variable v-start-date as date      no-undo .
define variable ii           as integer   no-undo .
define variable v-price      as decimal   no-undo .
define variable v-obj-code   as integer   no-undo .
define variable v-obj-type   as character no-undo . 
define variable v-yes        as logical   no-undo .
define variable v-yes-only   as logical   no-undo .  
define variable gg           as integer   no-undo .
define variable v-old-price  as decimal   no-undo .
define variable v-povtor     as logical   no-undo .
define variable v-fact-order-start as decimal no-undo .
define variable v-fact-order-end   as decimal no-undo .

define buffer bf_cli-gds  for ub.cli-gds .
define buffer bf_doc-line for ub.doc-line.
define buffer buf_clients for ub.clients .
define buffer buf_goods   for ub.goods .
define buffer buf_trn-doc for ub.trn-doc .

define variable v-price-rubl as decimal decimals 2 no-undo .
define variable v-price-cli  as decimal no-undo .
define variable v-goods      as logical no-undo .

define temp-table tt-temp no-undo
  field gds-code   as integer 
  field gds-name   as char
  field obj-type   as char
  field obj-code   as int
  field obj-name   as char
  field cli-code   as int
  field cli-type   as char
  field cli-name   as char
  field fact-date  as date
  field price-rubl as decimal
  field price-cli  as decimal
  field price-prod as decimal
  field nacenka    as character
  field trn-date   as date
  field fact-qty   as decimal
  field resul      as logical
  index pi  gds-code  obj-type obj-code fact-date
  index pi2 fact-date desc
  .

define temp-table tt-goods no-undo
  field gds-code as integer
  field obj-type as char
  field obj-code as int
  field five     as int
  index pi gds-code obj-type obj-code
  .

define buffer buf_tt for tt-temp .
define variable jj                 as integer no-undo .
define variable v-fact-order-alone as decimal no-undo .
define variable v-custom           as logical no-undo .

define stream Out-Stream.
define stream OutStr-html.
define variable v-report-name-html as character no-undo .
define variable v-report-id        as character no-undo .

if can-find (first g#customer) then v-custom = yes .   /*Выборочно по контрагентам*/
run day-begin-fact-order in this-procedure ( input ( x-Date-Start + 1 ),   output v-fact-order-start ).
run day-begin-fact-order in this-procedure ( input ( x-Date-End + 1 ),     output v-fact-order-end   ).
for each obj-list no-lock :
  if v-obj= "" then v-obj = obj-list.obj-name .
  else  v-obj = v-obj + ", " + obj-list.obj-name .
  case x-SelectGood:
    when {&g-all} then 
      do:
        /*по всем товарам*/
        v-goods-type = "Все товары" .
        _DL :
        for each buf_trn-doc no-lock where
          buf_trn-doc.fact-date >= x-Date-Start and
          buf_trn-doc.fact-date <= x-Date-End and
          buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} and
          buf_trn-doc.status_ = {&fact} and
          buf_trn-doc.obj-code = obj-list.obj-code and
          buf_trn-doc.obj-type = obj-list.obj-type,
          each bf_doc-line no-lock where
          bf_doc-line.doc-code = buf_trn-doc.doc-code,
          first buf_goods where buf_goods.artic = bf_doc-line.artic 
          and buf_goods.prod-code = bf_doc-line.prod-code 
          and buf_goods.prod-type = bf_doc-line.prod-type no-lock :
    
          if v-custom and not can-find (first g#customer where g#customer.obj-code = buf_trn-doc.cli-code 
            and g#customer.obj-type = buf_trn-doc.cli-type no-lock) then NEXT _DL.
          if bf_doc-line.fact-qnty = 0 then NEXT _DL .
          run proc-temp-table .
                             
        end.
      end.
    when {&g-choice} then 
      do:
        v-goods-type = "Выборочно" .
    
        for each gds-list no-lock, each buf_goods no-lock where buf_goods.gds-code = gds-list.gds-code:  
          _DL :
          for each bf_doc-line no-lock where
            bf_doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh} and
            bf_doc-line.status_ = {&fact} and
            bf_doc-line.obj-code = obj-list.obj-code and
            bf_doc-line.obj-type = obj-list.obj-type and
            bf_doc-line.artic = gds-list.artic and
            bf_doc-line.prod-code = gds-list.prod-code and
            bf_doc-line.prod-type = gds-list.prod-type and
            bf_doc-line.fact-order >= v-fact-order-start - 1 and
            bf_doc-line.fact-order <= v-fact-order-end + 1,
        
            first buf_trn-doc where buf_trn-doc.doc-code = bf_doc-line.doc-code and 
            buf_trn-doc.fact-date >= x-Date-Start and
            buf_trn-doc.fact-date <= x-Date-End no-lock :
     
            if v-custom and not can-find (first g#customer where g#customer.obj-code = buf_trn-doc.cli-code 
              and g#customer.obj-type = buf_trn-doc.cli-type no-lock) then NEXT _DL.
                                
            run proc-temp-table  .

          end. /*for each bf_doc-line no-lock where*/                          
        end. /*_DL :*/
      end.  /**/
    when {&g-grp} then 
      do:
        v-goods-type = "По группам" .
        for each tmp#grp no-lock:
_DL :
                         
          for each buf_goods no-lock where buf_goods.grp-name begins tmp#grp.grp-name :  
      
            for each bf_doc-line no-lock where
              bf_doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh} and
              bf_doc-line.status_ = {&fact} and
              bf_doc-line.obj-code = obj-list.obj-code and
              bf_doc-line.obj-type = obj-list.obj-type and
              bf_doc-line.artic = buf_goods.artic and
              bf_doc-line.prod-code = buf_goods.prod-code and
              bf_doc-line.prod-type = buf_goods.prod-type and
              bf_doc-line.fact-order >= v-fact-order-start - 1 and
              bf_doc-line.fact-order <= v-fact-order-end + 1,
        
              first buf_trn-doc where buf_trn-doc.doc-code = bf_doc-line.doc-code and 
              buf_trn-doc.fact-date >= x-Date-Start and
              buf_trn-doc.fact-date <= x-Date-End no-lock :
     
              if v-custom and not can-find (first g#customer where g#customer.obj-code = buf_trn-doc.cli-code 
                and g#customer.obj-type = buf_trn-doc.cli-type no-lock) then NEXT _DL.
                                
              run proc-temp-table  .

            end. /*for each bf_doc-line no-lock where*/                          
          end. /*_DL :*/
        end.  /*else*/
        end.
      end case.
  end.  /*for each obj-list no-lock :*/

/*создание отчета*/
 
run get-report-num in my-handle (
  output v-report-id
  ).
v-report-name-html = session:temp-directory  + string(v-report-id) + ".html". /*формирование имя файла*/        

output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' /*no-convert*/.
put stream OutStr-html unformatted
  '<!doctype html>' skip
  '  <html> ' skip
  '   <head> ' skip
  '    <meta charset="UTF-8"> ' skip
  '        <!-- Стили документа --> 'skip
  '    <style> ' skip
  '         table ~{ ' skip
  '             border-collapse: collapse; ' skip
  '             width: 1400px;  ' skip
  '         ~} ' skip
  '         .class1 ~{ ' skip
  '             border-collapse: collapse; ' skip
  '        ~} ' skip
  '         tbody td, th ~{ ' skip
  '             border: 1px solid black; ' skip
  '             border-collapse: collapse; ' skip
  '       height: 14px; ' skip
  '         ~} ' skip
          
  '    </style> ' skip
  '    </head> ' skip
  '      <body> ' skip
  '        <table orientation="landscape" name="Цены" fit_to_page="true">  <!-- таблица, в которой содержится шапка отчета --> ' skip
  '          <thead>  <!-- Шапка отчета --> ' skip
  '          <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px--> ' skip
  '            <tr class="set_columns"> ' skip
  '              <td style="width:170px"></td> ' skip
  '              <td style="width:70px"></td> ' skip
  '              <td style="width:250px"></td> ' skip
  '            </tr> ' skip
  '          <tr> ' skip
  '            <td colspan="3">За период с ' + string(x-Date-Start) + ' по ' + string(x-Date-End) + ' </td> ' skip
  '          </tr> ' skip
  '          <tr> ' skip
  '            <td colspan="3">Выбор товара: ' + v-goods-type + '</td> ' skip
  '          </tr> ' skip
  '          <tr> ' skip
  '            <td colspan="3">' + v-grp + '</td> ' skip
  '          </tr> ' skip
  '          <tr> ' skip
  '            <td colspan="3">Выбор объекта: ' + v-obj + '</td> ' skip
  '          </tr> ' skip
  '          </thead>' skip
          
  .
    
/*создание самого отчета*/
    
v-num-date = x-Date-End - x-Date-Start + 1 .
    
/*шапка отчета*/
    
put stream OutStr-html unformatted
  '<tbody>' skip
  '<tr>' skip
  '<th rowspan="2">Наименование поставщика</th>' skip
  '<th rowspan="2">Код</th>' skip
  '<th rowspan="2">Название товара</th>' skip
  .
if par-det-obj then 
do: /*детализация по объектам*/
  put stream OutStr-html unformatted
    '<th rowspan="2">Объект</th>' skip
    .
end.
put stream OutStr-html unformatted
  '<th colspan="' + string(v-num-date) + '">Стоимость в учетных ценах за ед.</th>' skip
  .
if par-crsa then 
do: /*детализация по объектам*/
  put stream OutStr-html unformatted
    '<th rowspan="2">Продажная цена</th>' skip
    .
end.
if par-nacenka then 
do: /*детализация по объектам*/
  put stream OutStr-html unformatted
    '<th rowspan="2">Наценка %</th>' skip
    .
end.
put stream OutStr-html unformatted
  '</tr>' skip
  '<tr>' skip
  .
      
/*заполняем шапку таблицы датами*/
do v-start-date=x-Date-Start to x-Date-End :
    
  put stream OutStr-html unformatted
    '<th>' + string(v-start-date) + '</th>' skip
    .
end.
   
put stream OutStr-html unformatted
  '</tr>' skip
  '<tr>' skip
  .
define variable v-det-obj as integer no-undo .

v-det-obj = 3 .
if par-det-obj then v-det-obj = v-det-obj + 1.    
if par-crsa then v-det-obj = v-det-obj + 1.
if par-nacenka then v-det-obj = v-det-obj + 1.
    
do v-start-date=(x-Date-Start - v-det-obj) to x-Date-End :
  ii = ii + 1 .
  put stream OutStr-html unformatted
    '<th>' + string(ii) + '</th>' skip
    .
end.
    
put stream OutStr-html unformatted
  '</tr>' skip
  .
    
if par-all = 1 then do:
              v-yes = no .
              v-yes-only = yes .
end.               
else v-yes = yes .
/*Заполнение строк*/

for each tt-temp where tt-temp.resul = no no-lock:
  v-yes-only = no .
  if v-yes then 
  do:
    gg = 0.
    ch-yes:
    for each buf_tt where buf_tt.gds-code = tt-temp.gds-code and
        buf_tt.cli-code = tt-temp.cli-code and
        buf_tt.cli-type = tt-temp.cli-type 
/*        and                                   */
/*        buf_tt.obj-code = tt-temp.obj-code and*/
/*        buf_tt.obj-type = tt-temp.obj-type    */
        no-lock : 
        gg = gg + 1.
        if gg = 1 then v-old-price = buf_tt.price-rubl / buf_tt.fact-qty .
            if v-old-price <> buf_tt.price-rubl / buf_tt.fact-qty  then do:
              v-yes-only = yes.
              leave ch-yes.
             end. 
         v-old-price = buf_tt.price-rubl / buf_tt.fact-qty.    
            
      end. 
    end.
    if v-yes-only or v-yes = no then do:

    put stream OutStr-html unformatted
      '<tr>' skip
      '<td>' + string(tt-temp.cli-name) + '</td>' skip
      '<td style="text-align: center;">' + string(tt-temp.gds-code) + '</td>' skip
      '<td>' + string(tt-temp.gds-name) + '</td>' skip
      .
    if par-det-obj then 
    do:
      put stream OutStr-html unformatted
        '<td>' + string(tt-temp.obj-name) + '</td>' skip
        .
    end.
    
    /*заполняем цены*/
    do v-start-date = x-Date-Start to x-Date-End :
     
      find first buf_tt no-lock where buf_tt.gds-code = tt-temp.gds-code and
        buf_tt.cli-code = tt-temp.cli-code and
        buf_tt.cli-type = tt-temp.cli-type and
        buf_tt.obj-code = tt-temp.obj-code and
        buf_tt.obj-type = tt-temp.obj-type and
        buf_tt.trn-date = v-start-date no-error .   
      if available buf_tt then 
      do:
        buf_tt.resul = yes .
          put stream OutStr-html unformatted
            '<td num="0.00" val="' + fnc-convert-dot-to-colon((buf_tt.price-rubl / buf_tt.fact-qty),"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon((buf_tt.price-rubl / buf_tt.fact-qty),"->>>>>>>>>>>9.99",2) + '</td>' skip
            .
        end.  
      else 
      do:
        put stream OutStr-html unformatted
          '<td num="0.00" val="' + fnc-convert-dot-to-colon(0.00,"->>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(0.00,"->>>>>>>>>>>9.99",2) + '</td>' skip
          .
      end.
    end.
    
    if par-crsa then 
    do:
      put stream OutStr-html unformatted
      '<TD num="0.000" val="' + fnc-convert-dot-to-colon(tt-temp.price-prod,"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if tt-temp.price-prod <> ? then fnc-convert-dot-to-colon(tt-temp.price-prod,"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
        .
    end.
    if par-nacenka then 
    do:
      put stream OutStr-html unformatted
      '<TD num="0.000" val="' + fnc-convert-dot-to-colon(decimal (tt-temp.nacenka),"->>>>>>>>>>>9.99",2) + '" style="text-align: right"> ' + if tt-temp.nacenka <> ? then fnc-convert-dot-to-colon(decimal (tt-temp.nacenka),"->>>>>>>>>>>9.99",2) + '</TD>' else "" + '</td>' skip
        .
    end.    
    put stream OutStr-html unformatted
      '</tr>' skip
      .    
  end.
end.    
    
/*концовка*/
put stream OutStr-html unformatted
  '  </tbody>' skip
  '  </body>' skip
  '  </html> ' skip
  .
output stream OutStr-html close.        

run prn-lib-reportviewer-report-name in this-procedure (
  input this-procedure
  ,input v-report-name-html
  ).

procedure proc-temp-table :
  /*Заполнение temp таблицы*/

  find first tt-temp where tt-temp.gds-code = buf_goods.gds-code and
    tt-temp.trn-date = buf_trn-doc.fact-date and
    tt-temp.cli-code = buf_trn-doc.cli-code and
    tt-temp.cli-type = buf_trn-doc.cli-type and
    tt-temp.obj-code = (if par-det-obj then bf_doc-line.obj-code else 0) and
    tt-temp.obj-type = (if par-det-obj then bf_doc-line.obj-type else '') no-error .
   
  if not available tt-temp then 
  do:
    create tt-temp .
    assign
      tt-temp.gds-code   = buf_goods.gds-code
      tt-temp.gds-name   = buf_goods.gds-name
      tt-temp.trn-date   = buf_trn-doc.fact-date
      tt-temp.cli-code   = buf_trn-doc.cli-code
      tt-temp.cli-type   = buf_trn-doc.cli-type
      tt-temp.obj-code   = if par-det-obj then bf_doc-line.obj-code else 0
      tt-temp.obj-type   = if par-det-obj then bf_doc-line.obj-type else ''
    
      .
    if par-crsa then 
    do:
      find first gds-obj no-lock where                                                 
        gds-obj.gds-code = buf_goods.gds-code and                                    
        gds-obj.obj-code = obj-list.obj-code and                                     
        gds-obj.obj-type = obj-list.obj-type no-error.
      if available gds-obj then tt-temp.price-prod = gds-obj.price-sale .
    end.
          
    find first ub.clients where ub.clients.obj-code = tt-temp.cli-code and ub.clients.obj-type = tt-temp.cli-type no-lock no-error . 
    if available ub.clients then tt-temp.cli-name = ub.clients.obj-name .
    find first ub.clients where ub.clients.obj-code = tt-temp.obj-code and ub.clients.obj-type = tt-temp.obj-type no-lock no-error . 
    if available ub.clients then tt-temp.obj-name = ub.clients.obj-name .
    if par-nacenka then 
    do:
      define variable v-margins-range   as integer   no-undo.
      define variable v-margins-exists  as logical   no-undo.
      define variable v-increase-range  as integer   no-undo.
      define variable v-increase-exists as logical   no-undo.
      define variable v-min-marg        as decimal   no-undo.
      define variable v-max-marg        as decimal   no-undo.
      define variable v-increase-pc     as decimal   no-undo.
      define variable v-round-method    as character no-undo.
      define variable v-base            as decimal   no-undo .
      define variable v-rmethod-range   as integer   no-undo.
      define variable v-rmethod-exists  as logical   no-undo.
          
          
      run grp-obj-margin-value in this-procedure
        (        input gds-list.grp-code
        , input obj-list.obj-type
        , input obj-list.obj-code
        , output v-min-marg
        , output v-max-marg
        , output v-increase-pc
        , output v-round-method
        , output v-base
        , output v-margins-range
        , output v-margins-exists
        , output v-increase-range
        , output v-increase-exists
        , output v-rmethod-range
        , output v-rmethod-exists
          
        ) no-error .
      if v-increase-exists then 
      do:
        assign
          tt-temp.nacenka = string( v-increase-pc )
          .
      end.

          
    end.  
    
           
  end.  /*if not available tt-temp then do:*/                           
  tt-temp.price-rubl = tt-temp.price-rubl + (bf_doc-line.price-rubl * bf_doc-line.fact-qnty).
  tt-temp.fact-qty = tt-temp.fact-qty + bf_doc-line.fact-qnty .      

end procedure.
                  
