block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-pboul1.p $
$Archive: rep/r-pboul1.p $

Отчет ПБОЮЛ по учету доходов и расходов в момент совершени

Автор: Демин Алексей Сергеевич
Дата создания: 03/27/06
Author: Alexey Demin
Creation date: 03/27/06

*/

do
on error undo, return error
:
  define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
  define variable vss-author      as character no-undo init "$Author: expertek $":U .
  define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
  define variable vss-workfile    as character no-undo init "$Workfile: r-pboul1.p $":U .
  define variable vss-archive     as character no-undo init "$Archive: rep/r-pboul1.p $":U .
  define variable vss-description as character no-undo init "Отчет ПБОЮЛ по учету доходов и расходов в момент совершени".
  { cmp/vssrevis.i }

  { cmp/str-glbl.i }
  { cmp/r-page1.i }
  { rep/r-sym.i }
  { cmp/r-pril.i }
  { rep/r-cost.i }
  { rep/r-sale.i }
  { rep/f-fdec.i }   /* Функции для форматирования полей для передачи в EXcel         */
  { gbl/paramls.i }
  { trg/factord.i }
  { str/lib-trn.i  }

  DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
  ASSIGN parParentProc =  my-handle .

  define variable g#report-num as integer   no-undo .
  run get-report-num  in parParentProc ( output g#report-num ).

  { rep/mcrexcel.i }

  define var    v-fact-order-start     as decimal   no-undo .
  define var    v-fact-order-end       as decimal   no-undo .

  run day-begin-fact-order in this-procedure ( input x-date-start, output v-fact-order-start ). /*Поиск нач fact-order*/
  run day-begin-fact-order in this-procedure ( input ( x-date-end + 1 ),   output v-fact-order-end ). /*Поиск посл fact-order*/

  define temp-table temp-goods no-undo  /* для списка товаров */
    field artic     like goods.artic
    field prod-code like goods.prod-code
    field prod-type like goods.prod-type
    field gds-name  like goods.gds-name
    field grp-name  like goods.grp-name
    field unit-base like goods.unit-base
    field part-code like parts.part-code
    field in-code   like parts.in-code
    field fact-date like trn-doc.fact-date
    field doc-code  like trn-doc.doc-code
    field f-o           as decimal
    field p-val         as decimal
    field p-sum-zak     as decimal
    field p-prod        as decimal
    field p-nds         as decimal
    field p-np          as decimal
    field p-prod-nal    as decimal
    field p-sum-prod    as decimal
    field p-sum-nds     as decimal
    field p-sum-prod-nds as decimal
    field p-sum-np       as decimal
    field p-sum-prod-nal as decimal
    field p-nazen        as decimal
    INDEX pi  IS PRIMARY artic  prod-type  prod-code  in-code part-code
    INDEX pi1   grp-name f-o artic
  .

  define buffer buf_goods    for goods.
  define buffer buf_trn-doc  for trn-doc.
  define buffer buf_doc-line for doc-line.
  define buffer buf_parts    for parts.
  define buffer buf_stk-tot  for stk-tot .

  define variable  Counter1    as integer initial 0  no-undo .
  define variable  ii          as integer   no-undo .
  define variable sum-val      as decimal   no-undo .
  define variable sum-zak      as decimal   no-undo .
  define variable sum-prod     as decimal   no-undo .
  define variable sum-nds      as decimal   no-undo .
  define variable sum-prod-nds as decimal   no-undo .
  define variable sum-np       as decimal   no-undo .
  define variable sum-prod-nal as decimal   no-undo .
  define variable sum-nazen    as decimal   no-undo .

  define variable v-void-output-parameter as decimal   no-undo .
  define variable v-qnty            as decimal   no-undo .
  define variable v-sum-with-taxes  as decimal   no-undo .
  define variable v-sum-vat         as decimal   no-undo .
  define variable v-sum-slt         as decimal   no-undo .

  define variable beg-qnty as decimal initial 0  no-undo .
  define variable end-qnty as decimal initial 0  no-undo .
  define variable beg-sum as decimal  initial 0  no-undo .
  define variable end-sum as decimal  initial 0  no-undo .

  define variable v-row       as integer   no-undo .
  define variable v-col       as integer   no-undo .
  define variable v-ind       as integer   no-undo initial 1 .
  assign
    Counter1 = 0 .
  .

  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 10 } /* Показать окно информации о текущем процессе */

  /* macr_excel - для экселя */
  assign
    make-excel = yes
    v-file-name = string(session :temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt"
  .
  output stream macr_excel to value(v-file-name) .
  assign v-ind = v-ind + 1 .

  { gbl/working.i }

  run PutColumnTitulExcel in this-procedure .

  find first obj-list no-error .

  find last buf_stk-tot no-lock
    where buf_stk-tot.obj-type   = obj-list.obj-type
      and buf_stk-tot.obj-code   = obj-list.obj-code
      and buf_stk-tot.fact-order <= v-fact-order-start
      and buf_stk-tot.sum-type   = {&arh-cost}
      and buf_stk-tot.cat-id     = {&root-cat-id}
  no-error .
  if available buf_stk-tot then do:
    assign
      beg-qnty = beg-qnty + buf_stk-tot.fact-qnty
      beg-sum  = beg-sum  + buf_stk-tot.sum-rubl - buf_stk-tot.VAT-rubl
    .
  end.

  run macr_excel_char("остатки на начало налогового периода", v-row, 5) .
  run macr_excel_sum  ( beg-qnty, v-row, 10,   3) .
  run macr_excel_sum  ( beg-sum,  v-row, 11,  2) .
  assign v-row = v-row + 1 .

  for each buf_trn-doc no-lock
    where buf_trn-doc.obj-type   = obj-list.obj-type
      and buf_trn-doc.obj-code   = obj-list.obj-code
      and buf_trn-doc.status_    = {&fact}
      and buf_trn-doc.fact-order >= v-fact-order-start
      and buf_trn-doc.fact-order <  v-fact-order-end
    :
    if buf_trn-doc.internal = yes or
       buf_trn-doc.ext-doc-type = {&TDEDT_Inv}       or
       buf_trn-doc.ext-doc-type = {&TDEDT_Peresort}  or
       buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} or
       buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh} then next .

    for each buf_doc-line no-lock
      where buf_doc-line.doc-code   = buf_trn-doc.doc-code  :

      find first buf_goods no-lock
        where buf_goods.prod-type   = buf_doc-line.prod-type
          and buf_goods.prod-code   = buf_doc-line.prod-code
          and buf_goods.artic       = buf_doc-line.artic
        no-error .

      run r-sale in this-procedure ( input buf_doc-line.doc-code
                                   , input buf_doc-line.artic
                                   , input buf_doc-line.prod-type
                                   , input buf_doc-line.prod-code
                                   , output v-qnty
                                   , output v-void-output-parameter
                                   , output v-void-output-parameter
                                   , output v-void-output-parameter
                                   , output v-sum-with-taxes
                                   , output v-void-output-parameter
                                   , output v-sum-vat
                                   , output v-void-output-parameter
                                   , output v-sum-slt
                                   , output v-void-output-parameter
                                   , output v-void-output-parameter
                                   , output v-void-output-parameter
                                   , output v-void-output-parameter
                                   , output v-void-output-parameter
                                   , output v-void-output-parameter
                                   , output v-void-output-parameter
                                   , output v-void-output-parameter
                                   ).

      for each buf_parts no-lock
        where buf_parts.out-code  = buf_trn-doc.doc-code
          and buf_parts.obj-type  = buf_doc-line.obj-type
          and buf_parts.obj-code  = buf_doc-line.obj-code
          and buf_parts.artic     = buf_doc-line.artic
          and buf_parts.prod-type = buf_doc-line.prod-type
          and buf_parts.prod-code = buf_doc-line.prod-code
        :
        assign Counter1 = Counter1 + 1.
        { rep/repfrm.i disp Counter1 }

        create temp-goods .
        assign
          temp-goods.artic           = buf_goods.artic
          temp-goods.prod-code       = buf_goods.prod-code
          temp-goods.prod-type       = buf_goods.prod-type
          temp-goods.gds-name        = buf_goods.gds-name
          temp-goods.unit-base       = buf_goods.unit-base
          temp-goods.grp-name        = buf_goods.grp-name
          temp-goods.part-code       = buf_parts.part-code
          temp-goods.in-code         = buf_parts.in-code
          temp-goods.fact-date       = buf_trn-doc.fact-date
          temp-goods.doc-code        = buf_trn-doc.doc-code
          temp-goods.f-o             = buf_trn-doc.fact-order
          temp-goods.p-val           = 0
          temp-goods.p-sum-zak       = 0
          temp-goods.p-prod          = 0
          temp-goods.p-nds           = 0
          temp-goods.p-np            = 0
          temp-goods.p-prod-nal      = 0
          temp-goods.p-sum-prod      = 0
          temp-goods.p-sum-nds       = 0
          temp-goods.p-sum-prod-nds  = 0
          temp-goods.p-sum-np        = 0
          temp-goods.p-sum-prod-nal  = 0
          temp-goods.p-nazen         = 0
        .
        if buf_doc-line.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass} or buf_doc-line.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} or buf_doc-line.ext-doc-type = {&TDEDT_Inv} or buf_doc-line.ext-doc-type = {&TDEDT_Peresort} then do:
          assign
            temp-goods.p-val          = - buf_parts.fact-qnty
            temp-goods.p-sum-zak      = - buf_parts.fact-qnty * buf_parts.price-rubl * 100 / (100 + buf_parts.VAT-pc )
            temp-goods.p-prod-nal     = - v-sum-with-taxes / v-qnty
            temp-goods.p-nds          = - v-sum-vat / v-qnty
            temp-goods.p-np           = - v-sum-slt / v-qnty
            temp-goods.p-prod         =   temp-goods.p-prod-nal - temp-goods.p-nds - temp-goods.p-np
            temp-goods.p-sum-nds      = - temp-goods.p-nds  * temp-goods.p-val
            temp-goods.p-sum-np       = - temp-goods.p-np * temp-goods.p-val
            temp-goods.p-sum-prod-nal = - temp-goods.p-prod-nal * temp-goods.p-val
            temp-goods.p-sum-prod     = - temp-goods.p-prod * temp-goods.p-val
            temp-goods.p-sum-prod-nds = - (temp-goods.p-prod + temp-goods.p-nds) * temp-goods.p-val
            temp-goods.p-nazen        = temp-goods.p-sum-prod - temp-goods.p-sum-zak
          .
        end.
        else do:
          assign
            temp-goods.p-val          = buf_parts.fact-qnty
            temp-goods.p-sum-zak      = buf_parts.fact-qnty * buf_parts.price-rubl * 100 / (100 + buf_parts.VAT-pc )
            temp-goods.p-prod-nal     = v-sum-with-taxes / v-qnty
            temp-goods.p-nds          = v-sum-vat / v-qnty
            temp-goods.p-np           = v-sum-slt / v-qnty
            temp-goods.p-prod         = temp-goods.p-prod-nal - temp-goods.p-nds - temp-goods.p-np
            temp-goods.p-sum-nds      = temp-goods.p-nds  * temp-goods.p-val
            temp-goods.p-sum-np       = temp-goods.p-np * temp-goods.p-val
            temp-goods.p-sum-prod-nal = temp-goods.p-prod-nal * temp-goods.p-val
            temp-goods.p-sum-prod     = temp-goods.p-prod * temp-goods.p-val
            temp-goods.p-sum-prod-nds = (temp-goods.p-prod + temp-goods.p-nds) * temp-goods.p-val
            temp-goods.p-nazen        = temp-goods.p-sum-prod - temp-goods.p-sum-zak
          .
        end.
        assign
          sum-val        = sum-val       + temp-goods.p-val
          sum-zak        = sum-zak       + temp-goods.p-sum-zak
          sum-prod       = sum-prod      + temp-goods.p-sum-prod
          sum-nds        = sum-nds       + temp-goods.p-sum-nds
          sum-prod-nds   = sum-prod-nds  + temp-goods.p-sum-prod-nds
          sum-np         = sum-np        + temp-goods.p-sum-np
          sum-prod-nal   = sum-prod-nal  + temp-goods.p-sum-prod-nal
          sum-nazen      = sum-nazen     + temp-goods.p-nazen
        .
      end.
    end.
  end.

  assign ii = 0 .
  for each temp-goods
    break by temp-goods.grp-name
          by temp-goods.f-o
          by temp-goods.artic
    :
    if  ( v-row ) >= 63000 then do:
      Output stream Macr_Excel  close .
      /*Запишем в файл параметров */
      run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name ) .
      /* создаем временный файл */
      run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
      output stream  Macr_Excel to value(v-file-name) .
      v-ind = v-ind + 1 .
      run PutColumnTitulExcel in this-procedure .
    end.
    if first-of(temp-goods.grp-name ) then do:
      run macr_excel_char( temp-goods.grp-name,  v-row, 5) .
      run macr_cell_format ( 10, yes, no, ?, v-row , 5, v-row, 5) .
      assign v-row = v-row + 1 .
    end.
    run macr_excel_char(String(ii), v-row, 1) .   assign ii = ii + 1 .
    run macr_excel_char(String(temp-goods.fact-date,"99.99.9999"), v-row, 2) .
    run macr_excel_char(temp-goods.doc-code, v-row, 3) .
    run macr_excel_char(temp-goods.artic,  v-row, 4) .
    run macr_excel_char(temp-goods.gds-name,  v-row, 5) .
    run macr_excel_char(temp-goods.unit-base, v-row, 6) .
    run macr_excel_sum (temp-goods.p-val,              v-row, 10,   3) . /* кол-во по партиям */
    run macr_excel_sum ( temp-goods.p-sum-zak,          v-row, 11,  2) . /* сумма закупки */
    run macr_excel_sum ( temp-goods.p-prod,             v-row, 12,  2) . /* цена прод без налогов */
    run macr_excel_sum ( temp-goods.p-nds,              v-row, 13,  2) . /* ндс  */
    run macr_excel_sum ( temp-goods.p-np,               v-row, 14,  2) . /* НП  */
    run macr_excel_sum ( temp-goods.p-prod-nal,         v-row, 15,  2) . /* цена прод c налог */
    run macr_excel_sum ( temp-goods.p-val,              v-row, 16,  3) . /* кол-во по партиям */
    run macr_excel_sum ( temp-goods.p-sum-prod,         v-row, 17,  2) . /* сумма прод без налогов */
    run macr_excel_sum ( temp-goods.p-sum-nds,          v-row, 18,  2) . /* сумма ндс  */
    run macr_excel_sum ( temp-goods.p-sum-prod-nds,     v-row, 19,  2) . /* сумма прод + ндс  */
    run macr_excel_sum ( temp-goods.p-sum-np,           v-row, 20,  2) . /* сумма НП  */
    run macr_excel_sum ( temp-goods.p-sum-prod-nal,     v-row, 21,  2) . /* сумма  прод c налог */
    run macr_excel_sum ( temp-goods.p-nazen,            v-row, 22,  2) . /* результат */

    assign v-row = v-row + 1 .
  end.

  run macr_excel_char( "Итого за интервал:",  v-row, 5) .
  run macr_excel_sum ( sum-val        ,  v-row, 10,   3) . /* кол-во по партиям */
  run macr_excel_sum ( sum-zak        ,  v-row, 11,  2) . /* сумма закупки */
  run macr_excel_sum ( sum-val        ,  v-row, 16,  3) . /* кол-во по партиям */
  run macr_excel_sum ( sum-prod       ,  v-row, 17,  2) . /* сумма прод без налогов */
  run macr_excel_sum ( sum-nds        ,  v-row, 18,  2) . /* сумма ндс  */
  run macr_excel_sum ( sum-prod-nds   ,  v-row, 19,  2) . /* сумма прод + ндс  */
  run macr_excel_sum ( sum-np         ,  v-row, 20,  2) . /* сумма НП  */
  run macr_excel_sum ( sum-prod-nal   ,  v-row, 21,  2) . /* сумма  прод c налог */
  run macr_excel_sum ( sum-nazen      ,  v-row, 22,  2) . /* результат */
  assign v-row = v-row + 1 .

  find last buf_stk-tot no-lock
    where buf_stk-tot.obj-type   = obj-list.obj-type
      and buf_stk-tot.obj-code   = obj-list.obj-code
      and buf_stk-tot.fact-order < v-fact-order-end
      and buf_stk-tot.sum-type   = {&arh-cost}
      and buf_stk-tot.cat-id     = {&root-cat-id}
  no-error .
  if available buf_stk-tot then do:
    assign
      end-qnty = end-qnty + buf_stk-tot.fact-qnty
      end-sum  = end-sum  + buf_stk-tot.sum-rubl - buf_stk-tot.VAT-rubl
    .
  end.

  run macr_excel_char("остатки на конец налогового периода", v-row, 5) .
  run macr_excel_sum  ( end-qnty, v-row, 10,   3) .
  run macr_excel_sum  ( end-sum,  v-row, 11,  2) .

  output stream macr_excel close .
  run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name) .
  run end-proc .

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */

  { gbl/stopwork.i }

  run rep/runexcel.p (v-file-name ).

end.

/* ******************************************************* */

procedure PutColumnTitulExcel : /* заголовки для колонок экселя */
  do
  on error undo, return error return-value
  :
  assign
    v-row = 4
    v-col = 1
  .

  run macr_excel_char ("Учет доходов и расходов по видам товаров (работ, услуг) в момент их совершения", 1, 5) .
  run macr_cell_format( 11, yes, no, ?, 1, 5, 1, 5) .
  run macr_excel_char (String( "Период с " + String(x-Date-Start,"99.99.9999") + " по " + String(x-Date-End,"99.99.9999") ) , 2, 1) .

  run macr_excel_char("Стоимостные показатели материальных ресурсов на выпущенную готовую продукцию, выполненные работы, оказанные услуги", 3, 7) .
  run macr_excel_char("Стоимостные показатели подлежащих реализации товаров, работ, услуг", 3, 10) .
  run macr_excel_char("Стоимостные показатели реализованных товаров, выполненных работ, оказанных услуг по единице ({&abbr_rub}.)", 3, 12) .
  run macr_excel_char("Стоимостные показатели реализованных товаров, выполненных работ, оказанных услуг", 3, 16) .
  run macr_excel_char("Результат от сделки", 3, 22) .  run macr_cell_size (12,?, 3, 22,?,?).

  run macr_excel_char("№ п/п", v-row, v-col) .
  run macr_cell_size (4,?, v-row, v-col,?,?).       assign v-col = v-col + 1 .
  run macr_excel_char("Дата операции", v-row, v-col) .
  run macr_cell_size (10,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Номер документа", v-row, v-col) .
  run macr_cell_size (10,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Артикул", v-row, v-col) .
  run macr_cell_size (10,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Наименование изготовленных товаров, выполненных работ, оказанных услуг", v-row, v-col) .
  run macr_cell_size (40,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Един. изм.", v-row, v-col) .
  run macr_cell_size (4,?, v-row, v-col,?,?).       assign v-col = v-col + 1 .
  run macr_excel_char("Стоимость единицы товара (работы, услуги) ({&abbr_rub}.)", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Количество", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Общая стоимость готовой продукции без НДС и НП из таб.№1-5А ({&abbr_rub}.) ", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Количество", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Общая стоимость", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Рыночная цена без учета НДС и НП", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Сумма НДС", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Сумма НП", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Общая стоимость", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Количество", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Сумма дохода", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Сумма НДС", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Общая сумма с НДС", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Сумма НП", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Общая стоимость со всеми налогами", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).

  run macr_cell_bordur ( v-row - 1, 1, v-row, 22) .
  run macr_cell_format ( 10, yes, no, 35, v-row - 1, 1, v-row, 22) .
  assign
    v-row = v-row + 1
    v-col = 1
  .

  end.
end procedure. /* PutColumnTitulExcel */