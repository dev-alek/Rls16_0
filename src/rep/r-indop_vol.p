block-level on error undo, throw.
/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$
ПРИЕМ ТОПЛИВА С ПРЕВЫШЕНИЕМ ПРЕДЕЛЬНО ДОПУСТИМОГО ОБЪЕМА РЕЗЕРВУАРА
Автор: 
Дата создания: 20/12/2014
Creation date: 20/12/2014
*/

define input parameter parparentproc      as widget-handle no-undo .
define input parameter p-pl as character            no-undo .
define input parameter p-pl-name as character no-undo .

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "ПРИЕМ ТОПЛИВА С ПРЕВЫШЕНИЕМ ПРЕДЕЛЬНО ДОПУСТИМОГО ОБЪЕМА РЕЗЕРВУАРА".

{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/library.i     }
{ cmp/r-page1.i     }
{ cmp/r-pril.i new  }
{ gbl/prn-lib.i     }
{ gbl/lastdate.i    }
{ gbl/cur-time.i    }
{ gbl/waitfram.i }
{ gbl/sys-time.i }   
{ str/lib-trn.i }   
{ ref/gds-attr.i }
{ str/is-gas.i }
{ str/trdcalib.i }
{ str/placelib.i }
{ rep/c-temp-place.i }
{ rep/c-place-attr.i }
define variable var-report-num      as character no-undo .
define variable v-file-name-rep-htm as character no-undo .
define variable is-petrol           as logical   no-undo .
define variable is-pieces           as logical   no-undo .
define variable v-value             as character no-undo.
define variable v-ok                as logical   no-undo.
define stream OutStr-html.


define temp-table tt-goods no-undo like ub.goods
   field b-code as integer.

define temp-table tt-report no-undo
   field obj-code             as integer
   field obj-type             as character
   field obj-name             as character
   field user-open            as character
   field user-close           as character
   field gds-name             as character
   field gds-code             as integer
   field loc1                 as character
   field pl-code              as integer
   field is-before            as character init "НЕТ"
   field is-after             as character init "НЕТ"
   field doc-code             as character
   field TTH-doc              as character
   field fact-calc-vol_before as decimal /*Измеренный объем топлива */
   field fact-calc-vol_after  as decimal /*Измеренный объем топлива */
   field doc-qnty             as decimal
   field fact-vol-TTH         as decimal /*Расчитанный объем*/
   field max-vol-pl           as decimal /*Максимальная вместимость резервуара*/
   field proc-vol-pl          as decimal /*Объем, %*/
   index pi obj-type obj-code doc-code gds-code pl-code.
   .
    
run get-report-num in parParentProc (
   output var-report-num
   ).

v-file-name-rep-htm = session:temp-directory + {&DF_Name} + string(var-report-num) + ".html".
/* Создаём временные файлы. */
output to value(v-file-name-rep-htm).
output close.
/* ******************** */
   
/*Шапка*/
def var v-first-time as int  no-undo.
def var v-first-date as date no-undo.
def var v-last-date  as date no-undo.
def var v-last-time  as int  no-undo.   

output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8' /*no-convert*/.


/* procedure create-tt-goods : */
define variable v-gds as character no-undo.
define buffer buf_goods       for ub.goods.
define buffer buf_cli-gds     for ub.cli-gds.
define buffer buf_doc-pl-attr for ub.doc-pl-attr . 
define buffer buf_trn-doc     for ub.trn-doc .
define buffer buf_rvs-line    for ub.rvs-line .
define buffer buf_rvs-doc     for ub.rvs-doc .

define variable v-gds-counter   as integer   no-undo.
define variable v-attr-value    as character no-undo.
define variable v-attr-type     as character no-undo.

define variable v-curr-grp-name as character no-undo .
define variable v-host-code     like ub.clients.host-code no-undo .
define variable v-obj-list      as character no-undo .

define variable curr-date as date no-undo .
define variable curr-time as integer no-undo .
   
do on error undo, return error return-value:

   if   X-SelectObject = {&all} then 
   do: 
      v-obj-list = "Все".
   end.
   else 
   do:
      for each obj-list: 
         v-obj-list = v-obj-list + "," + obj-list.obj-name .
         v-obj-list =     left-trim(v-obj-list, ",").
      end.  
   end.  
   empty temp-table tt-goods.

   case x-SelectGood:
      when {&g-all} then 
         do: /* все товары */
            v-gds = 'Все'.
            for each buf_goods no-lock where
               buf_goods.stts = 0:
               { str/is-petrl.i buf_goods.artic buf_goods.prod-type buf_goods.prod-code is-petrol is-pieces no-error }
               if is-petrol = yes 
                  and not is-gas(buf_goods.gds-code)   then 
               do: 
                  create tt-goods.
                  buffer-copy buf_goods to tt-goods.
                  find first bar-code where bar-code.gds-code eq buf_goods.gds-code no-lock no-error.
                  IF AVAILABLE bar-code THEN  tt-goods.b-code = bar-code.b-code.
                  v-gds-counter = v-gds-counter + 1.

               END.
            end.
         end.
      when {&g-choice} or 
      when {&g-one} then 
         do: /* товары выборочно */
            v-gds = 'Выборочно'.
            for each gds-list:
               find first buf_goods no-lock
                  where buf_goods.gds-code = gds-list.gds-code no-error.
               if available buf_goods then 
               do:
                  { str/is-petrl.i buf_goods.artic buf_goods.prod-type buf_goods.prod-code is-petrol is-pieces no-error }
                  if is-petrol = yes 
                     and not is-gas(buf_goods.gds-code)   then 
                  do:                   
                     create tt-goods.
                     buffer-copy buf_goods to tt-goods.
                     find first bar-code where bar-code.gds-code eq buf_goods.gds-code no-lock no-error.
                     IF AVAILABLE bar-code THEN  tt-goods.b-code = bar-code.b-code.

                     v-gds-counter = v-gds-counter + 1.
                  end.
               end.
            end.
         end.
   end case.
end.
/* end procedure. */ /* create-tt-goods */
run shapka .

FOR EACH obj-list  NO-LOCK:        
    
   if x-tog-shift then 
   do:
      for each buf_trn-doc no-lock where buf_trn-doc.obj-code = obj-list.obj-code and
         buf_trn-doc.obj-type = obj-list.obj-type and
         buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} and
         buf_trn-doc.reason-code <> 98 and
         /*      buf_trn-doc.status_ = {&fact}*/ /*в ТЗ не указано*/
         buf_trn-doc.shift-date >= X-date-Start and
         buf_trn-doc.shift-date <= x-Date-End:
         if buf_trn-doc.shift-date = X-date-Start and buf_trn-doc.shift-num < X-Shift-Start then next .
         if buf_trn-doc.shift-date = X-date-End   and buf_trn-doc.shift-num > X-Shift-End then next .
         FOR EACH buf_doc-pl-attr no-lock where buf_doc-pl-attr.obj-code = buf_trn-doc.obj-code and
            buf_doc-pl-attr.obj-type = buf_trn-doc.obj-type and
            buf_doc-pl-attr.out-code = buf_trn-doc.doc-code and
            (buf_doc-pl-attr.attr-code = "free-vol-exceed" or
            buf_doc-pl-attr.attr-code = "free-vol-exceed-after") and
            buf_doc-pl-attr.attr-value = string(yes): 
            if p-pl <> "" then 
            do:
               find first ub.place no-lock where ub.place.obj-code = buf_doc-pl-attr.obj-code and
                  ub.place.obj-type = buf_doc-pl-attr.obj-type and
                  ub.place.pl-code = buf_doc-pl-attr.pl-code no-error .
               if available (ub.place) then 
                  if lookup(string(recid(ub.place)),p-pl,",") = 0 then next .
            end.
            if not can-find (first tt-goods where tt-goods.gds-code = buf_doc-pl-attr.gds-code) then next . 
            run proc-report .
         end. 
      end.      
   end.
   else 
   do:
      for each buf_trn-doc no-lock where buf_trn-doc.obj-code = obj-list.obj-code and
         buf_trn-doc.obj-type = obj-list.obj-type and
         buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} and
         buf_trn-doc.reason-code <> 98 and
         /*      buf_trn-doc.status_ = {&fact}*/ /*в ТЗ не указано*/
         buf_trn-doc.doc-date >= X-date-Start and
         buf_trn-doc.doc-date <= x-Date-End:
         FOR EACH buf_doc-pl-attr no-lock where buf_doc-pl-attr.obj-code = buf_trn-doc.obj-code and
            buf_doc-pl-attr.obj-type = buf_trn-doc.obj-type and
            buf_doc-pl-attr.out-code = buf_trn-doc.doc-code and
            (buf_doc-pl-attr.attr-code = "free-vol-exceed" or
            buf_doc-pl-attr.attr-code = "free-vol-exceed-after") and
            buf_doc-pl-attr.attr-value = string(yes): 
            if p-pl <> "" then 
            do:
               find first ub.place no-lock where ub.place.obj-code = buf_doc-pl-attr.obj-code and
                  ub.place.obj-type = buf_doc-pl-attr.obj-type and
                  ub.place.pl-code = buf_doc-pl-attr.pl-code no-error .
               if available (ub.place) then 
                  if lookup(string(recid(ub.place)),p-pl,",") = 0 then next .
            end.
            if not can-find (first tt-goods where tt-goods.gds-code = buf_doc-pl-attr.gds-code) then next .
            run proc-report .
         end. 
      end. 
   end.     
  
END.
run print .

procedure shapka:
   define variable v-period as character no-undo .
   
   if x-tog-shift then 
      v-period = "смена с " + string(x-Shift-Start) + " от " + string(x-Date-Start, "99.99.9999") + " по " + string(x-Shift-End) + " от " + string(X-date-End, "99.99.9999") .
   else v-period = " от " + string(x-Date-Start, "99.99.9999") + " по " + string(X-date-End, "99.99.9999") .
   put stream OutStr-html unformatted 
   { rep/htmlhead.i }

      '<body> <table orientation = "landscape" name = "Прием топлива с превышением предельно допустимого объема резервуара" fit_to_page="true">'.

   put stream OutStr-html unformatted
      '<thead>' skip  /* Шапка отчета */
      /* Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px */
      '<tr class="set_columns">' skip
      '<td style="width:100px"></td>' skip
      '<td style="width:150px"></td>' skip
      '<td style="width:150px"></td>' skip
      '<td style="width:100px"></td>' skip
      '<td style="width:100px"></td>' skip
      '<td style="width:80px"></td>' skip
      '<td style="width:80px"></td>' skip
      '<td style="width:80px"></td>' skip
      '<td style="width:80px"></td>' skip
      '<td style="width:100px"></td>' skip
      '<td style="width:100px"></td>' skip
      '<td style="width:100px"></td>' skip
      '<td style="width:100px"></td>' skip
      '<td style="width:100px"></td>' skip
      '<td style="width:100px"></td>' skip
      '</tr>' skip
      '<tr>' skip
      '<td colspan="15" style="text-align: center; text-align: bold;">ПРИЕМ ТОПЛИВА С ПРЕВЫШЕНИЕМ ПРЕДЕЛЬНО ДОПУСТИМОГО ОБЪЕМА РЕЗЕРВУАРА</td>' skip
      '</tr>' skip
      '<tr>' skip
      '<td style="text-align:left; text-align: bold;">Период:</td>' skip
      '<td colspan="14" style="text-align:left;">' + v-period + '</td>' skip
      '</tr>' skip
      '<tr>' skip
      '<td style="text-align:left; text-align: bold;">Объекты:</td>' skip
      '<td colspan="14" style="text-align:left;">' + v-obj-list + '</td>' skip
      '</tr>' skip   
      '<tr>' skip
      '<td style="text-align:left; text-align: bold;">Резервуары:</td>' skip
      '<td colspan="14" style="text-align:left;">' + if p-pl-name <> "" then p-pl-name else "Все" + '</td>' skip
      '</tr>' skip
      '<tr>' skip
      '<td colspan="15" ></td>' skip
      '</tr>' skip

      '</thead>' skip

      '<tbody>' skip  /* Здесь начинается таблица отчета */
      '<tr>' skip /* Первые строки – шапка таблицы с тэгами tr */
      '<th text_wrap="true" rowspan="1" style="text-align: center;">Название АЗС/АЗК</th>' skip
      '<th text_wrap="true" rowspan="1" style="text-align: center;">ФИО работника, осуществляющего приемку</th>' skip
      '<th text_wrap="true" rowspan="1" style="text-align: center;">ФИО сотрудника, закрывшего ПН</th>' skip
      '<th text_wrap="true" rowspan="1" style="text-align: center;">Марка топлива</th>' skip
      '<th text_wrap="true" rowspan="1" style="text-align: center;">№ резервуара</th>' skip
      '<th text_wrap="true" rowspan="1" style="text-align: center;">Наличие предупреждения перед сливом об отсутствии свободного объема в резервуаре</th>' skip
      '<th text_wrap="true" rowspan="1" style="text-align: center;">Превышение допустимого объема резервуара после слива АЦ</th>' skip
      '<th text_wrap="true" rowspan="1" style="text-align: center;">Системный номер документа</th>' skip
      '<th text_wrap="true" rowspan="1" style="text-align: center;">Накладная, номер</th>' skip
      '<th text_wrap="true" rowspan="1" style="text-align: center;">Измер. объем топлива в резервуаре до слива АЦ, л</th>' skip
      '<th text_wrap="true" rowspan="1" style="text-align: center;">Объем по ТТН, л</th>' skip
      '<th text_wrap="true" rowspan="1" style="text-align: center;">Измер. объем топлива в резервуаре после слива АЦ, л</th>' skip
      '<th text_wrap="true" rowspan="1" style="text-align: center;">Рассч. объем топлива в резервуаре после слива АЦ, л</th>' skip
      '<th text_wrap="true" rowspan="1" style="text-align: center;">Объем резервуара 100%, л</th>' skip
      '<th text_wrap="true" rowspan="1" style="text-align: center;">% заполнения резервуара после слива (факт)</th>' skip
      '</tr>' skip 
      '<tr>' skip /* Первые строки – шапка таблицы с тэгами tr */
      '<th text_wrap="true" rowspan="1" style="text-align: center;">1</th>' skip
      '<th text_wrap="true" rowspan="1" style="text-align: center;">2</th>' skip
      '<th text_wrap="true" rowspan="1" style="text-align: center;">3</th>' skip
      '<th text_wrap="true" rowspan="1" style="text-align: center;">4</th>' skip
      '<th text_wrap="true" rowspan="1" style="text-align: center;">5</th>' skip
      '<th text_wrap="true" rowspan="1" style="text-align: center;">6</th>' skip
      '<th text_wrap="true" rowspan="1" style="text-align: center;">7</th>' skip
      '<th text_wrap="true" rowspan="1" style="text-align: center;">8</th>' skip
      '<th text_wrap="true" rowspan="1" style="text-align: center;">9</th>' skip
      '<th text_wrap="true" rowspan="1" style="text-align: center;">10</th>' skip
      '<th text_wrap="true" rowspan="1" style="text-align: center;">11</th>' skip
      '<th text_wrap="true" rowspan="1" style="text-align: center;">12</th>' skip
      '<th text_wrap="true" rowspan="1" style="text-align: center;">13</th>' skip
      '<th text_wrap="true" rowspan="1" style="text-align: center;">14</th>' skip
      '<th text_wrap="true" rowspan="1" style="text-align: center;">15</th>' skip
      '</tr>' skip .
end.
    
procedure proc-report:
   /*сбор данных*/
   find first tt-report where tt-report.obj-code = obj-list.obj-code and
      tt-report.obj-type = obj-list.obj-type and
      tt-report.doc-code = buf_trn-doc.doc-code and
      tt-report.gds-code = buf_doc-pl-attr.gds-code and
      tt-report.pl-code = buf_doc-pl-attr.pl-code no-error .
   if not available (tt-report) then 
   do:
      create tt-report .
      assign
         tt-report.obj-code = obj-list.obj-code
         tt-report.obj-type = obj-list.obj-type
         tt-report.obj-name = obj-list.obj-name
         tt-report.doc-code = buf_trn-doc.doc-code /*Системный номер документа*/
         tt-report.gds-code = buf_doc-pl-attr.gds-code /*Код товара*/
         tt-report.pl-code  = buf_doc-pl-attr.pl-code 
         .
      /*Наименование товара*/
      find first ub.goods no-lock where ub.goods.gds-code = tt-report.gds-code no-error .
      if available (ub.goods) then tt-report.gds-name = ub.goods.gds-name .
  

  /* Объем резервуара история */
  tt-report.max-vol-pl = get_max-qnty(tt-report.obj-code, tt-report.obj-type, tt-report.pl-code, buf_trn-doc.fact-date, buf_trn-doc.fact-time) . /*Объем резервуа-ра 100%, л*/
      find first ub.place no-lock where ub.place.obj-code = tt-report.obj-code and
         ub.place.obj-type = tt-report.obj-type and
         ub.place.pl-code = tt-report.pl-code no-error .
      if available (ub.place) then 
      do:
         run placelib_get-attr in this-procedure  (
            input {&place-twice-code}
            ,input ub.place.obj-code
            ,input ub.place.obj-type
            ,input ub.place.pl-code
            ,output v-value
            ,output v-ok      ) no-error.
         if v-ok and v-value <> "" then tt-report.loc1 = ub.place.loc1 + "(" + v-value + ")".
         else tt-report.loc1       = ub.place.loc1 . /*№ резервуара*/
/*         tt-report.max-vol-pl = ub.place.max-qnty . /*Объем резервуа-ра 100%, л*/*/
            
      end. 
      /*Накладная, номер*/
      /* номер документа из атрибутов */
      { str/tdat-val.i
        buf_trn-doc.doc-code
        {&trdcattr-nids}
        v-attr-value
        v-attr-type
        }
      tt-report.TTH-doc = v-attr-value .
      /*ФИО работника, осуществляющего приемку*/
      find first ub.c-trn-doc no-lock where ub.c-trn-doc.doc-code = buf_trn-doc.doc-code and 
         ub.c-trn-doc.obj-code = buf_trn-doc.obj-code and
         ub.c-trn-doc.obj-type = buf_trn-doc.obj-type and
         ub.c-trn-doc.status_ = {&wayb}  and  
         ub.c-trn-doc.flag_ = false no-error .
      if available (ub.c-trn-doc) then 
      do:
         find first ub.user-account no-lock where ub.user-account.user-id = ub.c-trn-doc.user-name no-error .
         if available(ub.user-account) then tt-report.user-open = ub.user-account.last-name + " " + ub.user-account.first-name + " " + ub.user-account.second-name .
      end.

      /*ФИО сотрудника техподдержки, закрывшего ПН*/
      find first ub.c-trn-doc no-lock where ub.c-trn-doc.doc-code = buf_trn-doc.doc-code and 
         ub.c-trn-doc.obj-code = buf_trn-doc.obj-code and
         ub.c-trn-doc.obj-type = buf_trn-doc.obj-type and
         ub.c-trn-doc.status_ = {&wayb} and
         ub.c-trn-doc.flag_ = true  and
         ub.c-trn-doc.action = "Закрытие документа" no-error .
      if available (ub.c-trn-doc) then 
      do:
         find first ub.user-account no-lock where ub.user-account.user-id = ub.c-trn-doc.corr-user-name no-error .
         if available(ub.user-account) then tt-report.user-close = ub.user-account.last-name + " " + ub.user-account.first-name + " " + ub.user-account.second-name .
      end.
      /*Измер. объем топлива в резер-вуаре после сли-ва АЦ, л*/
      for each buf_rvs-doc no-lock where buf_rvs-doc.obj-code = buf_doc-pl-attr.obj-code and
         buf_rvs-doc.obj-type = buf_doc-pl-attr.obj-type and
         buf_rvs-doc.out-code = buf_trn-doc.doc-code and
         buf_rvs-doc.rvs-type = {&rvs-after-doc},
         first buf_rvs-line no-lock where buf_rvs-line.obj-code = buf_rvs-doc.obj-code and
         buf_rvs-line.obj-type = buf_rvs-doc.obj-type and
         buf_rvs-line.gds-code = buf_doc-pl-attr.gds-code and
         buf_rvs-line.pl-code = buf_doc-pl-attr.pl-code and
         buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
      :
         if buf_rvs-line.state-measure-qnty > tt-report.fact-calc-vol_after
         then do :
           tt-report.fact-calc-vol_after = buf_rvs-line.state-measure-qnty .
           tt-report.fact-calc-vol_before = buf_rvs-line.state-measure-qnty .
         end .
      end.
      /*Измер. объем топлива в резервуаре до слива АЦ, л*/
      for each buf_rvs-doc no-lock where buf_rvs-doc.obj-code = buf_doc-pl-attr.obj-code and
         buf_rvs-doc.obj-type = buf_doc-pl-attr.obj-type and
         buf_rvs-doc.out-code = buf_trn-doc.doc-code and
         buf_rvs-doc.rvs-type = {&rvs-before-doc},
         first buf_rvs-line no-lock where buf_rvs-line.obj-code = buf_rvs-doc.obj-code and
         buf_rvs-line.obj-type = buf_rvs-doc.obj-type and
         buf_rvs-line.gds-code = buf_doc-pl-attr.gds-code and
         buf_rvs-line.pl-code = buf_doc-pl-attr.pl-code and
         buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
      :
         if buf_rvs-line.state-measure-qnty < tt-report.fact-calc-vol_before
         then
           tt-report.fact-calc-vol_before = buf_rvs-line.state-measure-qnty .
      end.
      /*Объем по ТТН, л*/
      find first ub.goods no-lock where ub.goods.gds-code = buf_doc-pl-attr.gds-code no-error .
      if available (ub.goods) then 
      do:
         find first ub.doc-line no-lock where ub.doc-line.doc-code = buf_trn-doc.doc-code and
            ub.doc-line.obj-code = buf_trn-doc.obj-code and
            ub.doc-line.obj-type = buf_trn-doc.obj-type and
            ub.doc-line.artic = ub.goods.artic and
            ub.doc-line.prod-code = ub.goods.prod-code and
            ub.doc-line.prod-type = ub.goods.prod-type no-error .
         if available (ub.doc-line) then tt-report.doc-qnty = ub.doc-line.doc-qnty .    
      end.  
      tt-report.fact-vol-TTH = tt-report.fact-calc-vol_before + tt-report.doc-qnty .
      tt-report.proc-vol-pl = (tt-report.fact-calc-vol_after * 100) / tt-report.max-vol-pl .
   end.
   if buf_doc-pl-attr.attr-code = "free-vol-exceed-after" then 
   do:
      if buf_doc-pl-attr.attr-value = string(yes) then tt-report.is-after = "ДА" .
      else tt-report.is-after = "НЕТ" .
   end.
   if buf_doc-pl-attr.attr-code = "free-vol-exceed" then 
   do:
      if buf_doc-pl-attr.attr-value = string(yes) then tt-report.is-before = "ДА" .
      else tt-report.is-before = "НЕТ" .
   end.
end.

procedure print:
   for each tt-report by tt-report.obj-code by tt-report.pl-code:
      put stream OutStr-html unformatted 
         '<tr>' skip
         '<td text_wrap="true" style="text-align:center;">' tt-report.obj-name '</td>' skip /*Название АЗС/АЗК*/
         '<td text_wrap="true" style="text-align:center;">' tt-report.user-open '</td>' skip  /*ФИО работника, осуществляющего приемку*/
         '<td text_wrap="true" style="text-align:center;">' tt-report.user-close '</td>' skip  /*ФИО сотрудника техподдержки, закрывшего ПН*/
         '<td text_wrap="true" style="text-align:center;">' tt-report.gds-name '</td>' skip  /*Марка топлива*/
         '<td text_wrap="true" style="text-align:center;">' tt-report.loc1 '</td>' skip    /*№ резервуара*/
         '<td text_wrap="true" style="text-align:center;">' string(tt-report.is-before) '</td>' skip    /*Наличие предупреждения перед сливом об отсутствии свободного объема в резервуаре*/
         '<td text_wrap="true" style="text-align:center;">' string(tt-report.is-after) '</td>' skip   /*Превышение допустимого объема резервуара после слива АЦ*/
         '<td text_wrap="true" style="text-align:center;">' string(tt-report.doc-code)   '</td>' skip                              /*Системный номер документа */
         '<td text_wrap="true" style="text-align:center;">' string(tt-report.TTH-doc)   '</td>' skip                                                /* Накладная, номер */        
         '<td text_wrap="true" style="text-align:right;">' if tt-report.fact-calc-vol_before <> ? then string(ABSOLUTE(tt-report.fact-calc-vol_before),"->>>>>>>>>>>>9") else "" '</td>' skip  /*Измер. объем топлива в резервуаре до слива АЦ, л*/
         '<td text_wrap="true" style="text-align:right;">' if tt-report.doc-qnty <> ? then string(ABSOLUTE(tt-report.doc-qnty),"->>>>>>>>>>>>>9") else ""  '</td>' skip  /*Объем по ТТН, л */
         '<td text_wrap="true" style="text-align:right;">' if tt-report.fact-calc-vol_after <> ? then string(ABSOLUTE(tt-report.fact-calc-vol_after),"->>>>>>>>9") else "" '</td>' skip                  /*Измер. объем топлива в резервуаре после слива АЦ, л*/
         '<td text_wrap="true" style="text-align:right;">' if tt-report.fact-vol-TTH <> ? then string(ABSOLUTE(tt-report.fact-vol-TTH),"->>>>>>>>9") else "" '</td>' skip                  /*Рассч. объем топлива в резервуаре после слива АЦ, л*/
         '<td text_wrap="true" style="text-align:right;">' if tt-report.max-vol-pl <> ? then string(ABSOLUTE(tt-report.max-vol-pl),"->>>>>>>>9") else "" '</td>' skip                  /*Объем резервуара 100%, л*/
         '<td text_wrap="true" style="text-align:right;">' if tt-report.proc-vol-pl <> ? then string(ABSOLUTE(tt-report.proc-vol-pl),"->>>>>>>>9.9") else "" '</td>' skip                  /*Объем, %*/
         '</tr>' skip .
   end.
end procedure .

put stream OutStr-html unformatted
   substitute (' </tbody></table> </body> </html>  ').
      
output stream OutStr-html close.   
      
run prn-lib-reportviewer in this-procedure (
   input parparentproc
   ,input v-file-name-rep-htm
   ,input "" 
   ) no-error.
if error-status:error then
do:
   message return-value view-as alert-box.
   return .
end.

