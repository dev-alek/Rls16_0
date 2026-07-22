block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-pboul3.p $
$Archive: rep/r-pboul3.p $

Отчет ПБОЮЛ по учету приобретенного и израсходованного сырь

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
  define variable vss-workfile    as character no-undo init "$Workfile: r-pboul3.p $":U .
  define variable vss-archive     as character no-undo init "$Archive: rep/r-pboul3.p $":U .
  define variable vss-description as character no-undo init "Отчет ПБОЮЛ по учету приобретенного и израсходованного сырь ".
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
  { trg/partslib.i }

  DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
  ASSIGN parParentProc =  my-handle .

  define variable g#report-num as integer   no-undo .
  run get-report-num  in parParentProc ( output g#report-num ).

  { rep/mcrexcel.i }

  define var    v-fact-order-start     as decimal   no-undo .
  define var    v-fact-order-end       as decimal   no-undo .

  run day-begin-fact-order in this-procedure ( input x-date-start, output v-fact-order-start ). /*Поиск нач fact-order*/
  run day-begin-fact-order in this-procedure ( input ( x-date-end + 1 ),   output v-fact-order-end ). /*Поиск посл fact-order*/

  define buffer buf_goods    for goods.
  define buffer buf_gds-obj  for gds-obj.
  define buffer buf_trn-doc  for trn-doc.
  define buffer buf_doc-line for doc-line.
  define buffer buf_parts    for parts.
  define buffer buf_stk-tot  for stk-tot .

  define temp-table temp-goods-cli no-undo  /* для списка товаров */
    field f-o       as decimal
    field ind       as integer
    field gds-code  like goods.gds-code
    field artic     like goods.artic
    field prod-code like goods.prod-code
    field prod-type like goods.prod-type
    field gds-name  like goods.gds-name
    field grp-name  like goods.grp-name
    field unit-base like goods.unit-base
    field part-code like parts.part-code
    field in-code   like parts.in-code
    field dte          as date
    field num          as character
    field price        as decimal
    field np           as decimal
    field price-np     as decimal
    field nds          as decimal
    field price-np-nds as decimal
    field in-qnty      as decimal
    field sum-with-np  as decimal
    field sum-nds      as decimal
    field sum-with-np-nds  as decimal
    field out-qnty     as decimal
    field ost-qnty     as decimal
    INDEX pi  IS PRIMARY artic prod-type prod-code in-code part-code
    INDEX pi1 ind
    INDEX pi2 grp-name f-o artic
  .

  define variable  Counter1          as integer initial 0  no-undo .
  define variable  ii                as integer initial 0  no-undo .
  define variable sum-in-qnty        as decimal   no-undo .
  define variable sum-in-with-np     as decimal   no-undo .
  define variable sum-in-nds         as decimal   no-undo .
  define variable sum-in-with-np-nds as decimal   no-undo .
  define variable sum-out-qnty       as decimal   no-undo .
  define variable sum-out-with-np    as decimal   no-undo .
  define variable sum-out-nds        as decimal   no-undo .
  define variable sum-ost-qnty       as decimal   no-undo .
  define variable sum-ost-with-np    as decimal   no-undo .

  define variable v-row       as integer   no-undo .
  define variable v-col       as integer   no-undo .
  define variable v-ind       as integer   no-undo initial 1 .

  assign
    Counter1 = 0 .
  .

  { str/in-vatp.i def }

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

  /* сначала все остатки на начало */
  for each buf_gds-obj no-lock
    where buf_gds-obj.obj-type  = obj-list.obj-type
      and buf_gds-obj.obj-code  = obj-list.obj-code
    :
    find first buf_goods no-lock
      where buf_goods.prod-type   = buf_gds-obj.prod-type
        and buf_goods.prod-code   = buf_gds-obj.prod-code
        and buf_goods.artic       = buf_gds-obj.artic
        no-error .
    run partslib-init-temp-parts-by-factord (input obj-list.obj-type,
                                             input obj-list.obj-code,
                                             input buf_gds-obj.artic,
                                             input buf_gds-obj.prod-type,
                                             input buf_gds-obj.prod-code,
                                             input v-fact-order-start,
                                             false) .
    for each temp-parts :
      if temp-parts.fact-qnty = 0 then next .

      assign
        Counter1 = Counter1 + 1
        ii = ii + 1
      .
      { rep/repfrm.i disp Counter1 }

      /* вычисляем остаток в учетных ценах */
      /* с разбивками по НДС, НП */
      /* с разбивками по виду поставки */
      /* идем по всем партиям свободной зоны */
      /* во временной таблице уже находятся только те партии, которые нужны */
      { str/in-vatp.i calc-parts temp-parts. " " loc}

      create temp-goods-cli .
      assign
        temp-goods-cli.ind             = ii
        temp-goods-cli.gds-code        = buf_goods.gds-code
        temp-goods-cli.artic           = buf_goods.artic
        temp-goods-cli.prod-code       = buf_goods.prod-code
        temp-goods-cli.prod-type       = buf_goods.prod-type
        temp-goods-cli.gds-name        = buf_goods.gds-name
        temp-goods-cli.f-o             = v-fact-order-start
        temp-goods-cli.grp-name        = buf_goods.grp-name
        temp-goods-cli.unit-base       = buf_goods.unit-base
        temp-goods-cli.part-code       = temp-parts.part-code
        temp-goods-cli.in-code         = temp-parts.in-code
        temp-goods-cli.dte             = x-Date-Start
        temp-goods-cli.num             = "остатки"
        temp-goods-cli.price           = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc
        temp-goods-cli.np              = slt-rubl-loc
        temp-goods-cli.price-np        = price-rubl-with-tax-loc - vat-rubl-loc
        temp-goods-cli.nds             = vat-rubl-loc
        temp-goods-cli.price-np-nds    = price-rubl-with-tax-loc
        temp-goods-cli.in-qnty         = temp-parts.fact-qnty
        temp-goods-cli.sum-with-np     = temp-goods-cli.in-qnty * temp-goods-cli.price-np
        temp-goods-cli.sum-nds         = temp-goods-cli.in-qnty * temp-goods-cli.nds
        temp-goods-cli.sum-with-np-nds = temp-goods-cli.in-qnty * temp-goods-cli.price-np-nds
        temp-goods-cli.out-qnty        = 0
        temp-goods-cli.ost-qnty        = 0
      .
    end.
  end.

  for each buf_trn-doc no-lock
    where buf_trn-doc.obj-type   = obj-list.obj-type
      and buf_trn-doc.obj-code   = obj-list.obj-code
      and buf_trn-doc.status_    = {&fact}
      and buf_trn-doc.fact-order >= v-fact-order-start
      and buf_trn-doc.fact-order <  v-fact-order-end
    :
    if ( buf_trn-doc.internal = yes and buf_trn-doc.ext-doc-type <> {&TDEDT_Inv} and buf_trn-doc.ext-doc-type <> {&TDEDT_Peresort} ) then next .

    for each buf_doc-line no-lock
      where buf_doc-line.doc-code   = buf_trn-doc.doc-code  :

      if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} then do:
        find first buf_goods no-lock
          where buf_goods.prod-type   = buf_doc-line.prod-type
            and buf_goods.prod-code   = buf_doc-line.prod-code
            and buf_goods.artic       = buf_doc-line.artic
        no-error .
      end.

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

        if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} then do:
          assign ii = ii + 1  .

          /* вычисляем остаток в учетных ценах */
          /* с разбивками по НДС, НП */
          /* с разбивками по виду поставки */
          /* идем по всем партиям свободной зоны */
          /* во временной таблице уже находятся только те партии, которые нужны */
          { str/in-vatp.i calc-parts buf_parts. " " loc}

          create temp-goods-cli .
          assign
            temp-goods-cli.ind             = ii
            temp-goods-cli.gds-code        = buf_goods.gds-code
            temp-goods-cli.artic           = buf_goods.artic
            temp-goods-cli.prod-code       = buf_goods.prod-code
            temp-goods-cli.prod-type       = buf_goods.prod-type
            temp-goods-cli.gds-name        = buf_goods.gds-name
            temp-goods-cli.f-o             = buf_trn-doc.fact-order
            temp-goods-cli.grp-name        = buf_goods.grp-name
            temp-goods-cli.unit-base       = buf_goods.unit-base
            temp-goods-cli.part-code       = buf_parts.part-code
            temp-goods-cli.in-code         = buf_parts.in-code
            temp-goods-cli.dte             = buf_trn-doc.fact-date
            temp-goods-cli.num             = buf_trn-doc.doc-code
            temp-goods-cli.price           = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc
            temp-goods-cli.np              = slt-rubl-loc
            temp-goods-cli.price-np        = price-rubl-with-tax-loc - vat-rubl-loc
            temp-goods-cli.nds             = vat-rubl-loc
            temp-goods-cli.price-np-nds    = price-rubl-with-tax-loc
            temp-goods-cli.in-qnty         = buf_parts.fact-qnty
            temp-goods-cli.sum-with-np     = temp-goods-cli.in-qnty * temp-goods-cli.price-np
            temp-goods-cli.sum-nds         = temp-goods-cli.in-qnty * temp-goods-cli.nds
            temp-goods-cli.sum-with-np-nds = temp-goods-cli.in-qnty * temp-goods-cli.price-np-nds
            temp-goods-cli.out-qnty        = 0
            temp-goods-cli.ost-qnty        = 0
          .
        end.
        else do: /* это не приход */
          find first temp-goods-cli
            where temp-goods-cli.artic     = buf_parts.artic
              and temp-goods-cli.prod-code = buf_parts.prod-code
              and temp-goods-cli.prod-type = buf_parts.prod-type
              and temp-goods-cli.part-code = buf_parts.part-code
              and temp-goods-cli.in-code   = buf_parts.in-code
            no-error .
          if not available temp-goods-cli then next .

          if buf_doc-line.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass} or buf_doc-line.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} or buf_doc-line.ext-doc-type = {&TDEDT_Inv} or buf_doc-line.ext-doc-type = {&TDEDT_Peresort} then do:
            assign temp-goods-cli.out-qnty = temp-goods-cli.out-qnty - buf_parts.fact-qnty .
          end.
          else do:
            assign temp-goods-cli.out-qnty = temp-goods-cli.out-qnty + buf_parts.fact-qnty .
          end.
        end.
      end.
    end.
  end.

  assign ii = 1  .
  for each temp-goods-cli
    break by temp-goods-cli.grp-name
          by temp-goods-cli.f-o
          by temp-goods-cli.artic
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
    if first-of(temp-goods-cli.grp-name ) then do:
      run macr_excel_char( temp-goods-cli.grp-name,  v-row, 5) .
      run macr_cell_format ( 10, yes, no, ?, v-row , 5, v-row, 5) .
      assign v-row = v-row + 1 .
    end.
    assign
      temp-goods-cli.ost-qnty = temp-goods-cli.in-qnty - temp-goods-cli.out-qnty
      sum-in-qnty        = sum-in-qnty        + temp-goods-cli.in-qnty
      sum-in-with-np     = sum-in-with-np     + temp-goods-cli.sum-with-np
      sum-in-nds         = sum-in-nds         + temp-goods-cli.sum-nds
      sum-in-with-np-nds = sum-in-with-np-nds + temp-goods-cli.sum-with-np-nds
      sum-out-qnty       = sum-out-qnty       + temp-goods-cli.out-qnty
      sum-out-with-np    = sum-out-with-np    + temp-goods-cli.out-qnty * temp-goods-cli.price-np
      sum-out-nds        = sum-out-nds        + temp-goods-cli.out-qnty * temp-goods-cli.nds
      sum-ost-qnty       = sum-ost-qnty       + temp-goods-cli.ost-qnty
      sum-ost-with-np    = sum-ost-with-np    + temp-goods-cli.ost-qnty * temp-goods-cli.price-np
      Counter1 = Counter1 + 1
    .
    { rep/repfrm.i disp Counter1 }

/*    run macr_excel_char(String(temp-goods-cli.ind)                        , v-row, 1) .*/
    run macr_excel_char(String(ii)                                        , v-row, 1) .
    assign ii = ii + 1  .
    run macr_excel_char(String(temp-goods-cli.dte,"99.99.9999")           , v-row, 2) .
    run macr_excel_char( temp-goods-cli.num                               , v-row, 3) .
    run macr_excel_char( temp-goods-cli.artic                             , v-row, 4) .
    run macr_excel_char( temp-goods-cli.gds-name                          , v-row, 5) .
    run macr_excel_char( temp-goods-cli.unit-base                         , v-row, 6) .
    run macr_excel_sum ( temp-goods-cli.price                             , v-row, 7,  2) .
    run macr_excel_sum ( temp-goods-cli.np                                , v-row, 8,  2) .
    run macr_excel_sum ( temp-goods-cli.price-np                          , v-row, 9,  2) .
    run macr_excel_sum ( temp-goods-cli.nds                               , v-row, 10, 2) .
    run macr_excel_sum ( temp-goods-cli.price-np-nds                      , v-row, 11, 2) .
    run macr_excel_sum ( temp-goods-cli.in-qnty                           , v-row, 12, 3) .
    run macr_excel_sum ( temp-goods-cli.sum-with-np                       , v-row, 13, 2) .
    run macr_excel_sum ( temp-goods-cli.sum-nds                           , v-row, 14, 2) .
    run macr_excel_sum ( temp-goods-cli.sum-with-np-nds                   , v-row, 15, 2) .
    run macr_excel_sum ( temp-goods-cli.out-qnty                          , v-row, 16, 3) .
    run macr_excel_sum ( temp-goods-cli.out-qnty * temp-goods-cli.price-np, v-row, 17, 2) .
    run macr_excel_sum ( temp-goods-cli.out-qnty * temp-goods-cli.nds     , v-row, 18, 2) .
    run macr_excel_sum ( temp-goods-cli.ost-qnty                          , v-row, 19, 3) .
    run macr_excel_sum ( temp-goods-cli.ost-qnty * temp-goods-cli.price-np, v-row, 20, 2) .

    assign v-row = v-row + 1 .
  end.

  run macr_excel_char( "Итого за интервал:",  v-row, 5) .
  run macr_excel_sum ( sum-in-qnty         ,  v-row, 12,  3) .
  run macr_excel_sum ( sum-in-with-np      ,  v-row, 13,  2) .
  run macr_excel_sum ( sum-in-nds          ,  v-row, 14,  2) .
  run macr_excel_sum ( sum-in-with-np-nds  ,  v-row, 15,  2) .
  run macr_excel_sum ( sum-out-qnty        ,  v-row, 16,  3) .
  run macr_excel_sum ( sum-out-with-np     ,  v-row, 17,  2) .
  run macr_excel_sum ( sum-out-nds         ,  v-row, 18,  2) .
  run macr_excel_sum ( sum-ost-qnty        ,  v-row, 19,  3) .
  run macr_excel_sum ( sum-ost-with-np     ,  v-row, 20,  2) .
  assign v-row = v-row + 1 .

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

  run macr_excel_char ("Учет приобретенного и израсходованного сырья по видам товаров (работ, услуг)", 1, 4) .
  run macr_cell_format( 11, yes, no, ?, 1, 4, 1, 4) .
  run macr_excel_char (String( "Период с " + String(x-Date-Start,"99.99.9999") + " по " + String(x-Date-End,"99.99.9999") ) , 2, 1) .

  run macr_excel_char("Стоимостные показатели приобретенного сырья (работ, услуг) в пользу индивидуального предпринимателя", 3, 7) .
  run macr_excel_char("Стоимостные показатели израсходованного сырья (работ, услуг)", 3, 16) .
  run macr_excel_char("Стоимостные показатели остатков сырья (работ, услуг)", 3, 19) .

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
  run macr_excel_char("Цена без налогов", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Налог с продаж", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Цена с НП без НДС", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("НДС ({&abbr_rub}.)", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Цена с НП и НДС", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Количество", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Сумма с НП", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Сумма НДС", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Общая стоимость с НП и НДС", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Количество", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Общая стоимость", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Сумма НДС", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Количество", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .
  run macr_excel_char("Сумма с НП", v-row, v-col) .
  run macr_cell_size (12,?, v-row, v-col,?,?).      assign v-col = v-col + 1 .

  run macr_cell_bordur ( v-row - 1, 1, v-row, 20) .
  run macr_cell_format ( 10, yes, no, 35, v-row - 1, 1, v-row, 20) .
  assign
    v-row = v-row + 1
    v-col = 1
  .

  end.
end procedure. /* PutColumnTitulExcel */