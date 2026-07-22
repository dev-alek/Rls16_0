block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-hold6.p $
$Archive: rep/r-hold6.p $

Отчет по межфирменным операциям - Рейтинг поставщиков

Автор: Демин Алексей Сергеевич
Дата создания: 03/27/06
Author: Alexey Demin
Creation date: 03/27/06

*/

do
on error undo, return error
:
/*define input parameter x-date   as integer   no-undo .*/
/*define input parameter x-mon    as integer   no-undo .*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-hold6.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-hold6.p $":U .
define variable vss-description as character no-undo init "Отчет по межфирменным операциям - Рейтинг поставщиков".

{ cmp/vssrevis.i }

  { cmp/str-glbl.i }
  { cmp/r-page1.i }
  { rep/r-sym.i }
  { cmp/r-pril.i }
  { rep/f-fdec.i }
  { rep/r-sale.i }
  { rep/r-cost.i }
  { trg/factord.i }
  { gbl/paramls.i }

  DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
  ASSIGN parParentProc =  my-handle .

  define variable g#report-num as integer   no-undo .
  run get-report-num  in parParentProc ( output g#report-num ).

  define variable g#gds-engl as logical   no-undo .
  run get-gds-engl  in parParentProc ( output g#gds-engl ).

  { rep/mcrexcel.i }

  define Stream OutStream.

  define buffer buf_goods    for goods.
  define buffer buf_hold-time  for hold-time.
  define buffer buf_hold-sale  for hold-sale.
  define buffer buf_trn-doc    for trn-doc.
  define buffer buf_doc-line   for doc-line.

  DEFINE temp-table temp-hold6 no-undo
    field   artic            as char
    field   prod-code        as integer
    field   prod-type        as char
    field   grp-name         as char
    field   gds-name         as char
    field   gds-unit         as char
    field   gds-code         as integer
    field   qnty             as decimal
    field   sum-zak          as decimal
    field   sum-prod         as decimal
    INDEX pi  IS PRIMARY     gds-code
    INDEX pi2                grp-name
  .

  DEFINE temp-table temp-doc no-undo
    field   gds-code         as integer
    field   num              as char
    field   dat              as date
    field   cli              as char
    field   qnty             as decimal
    field   zak              as decimal
    field   prod             as decimal
    INDEX pi  IS PRIMARY     gds-code
  .

  define var    v-fact-order-start     as decimal   no-undo .
  define var    v-fact-order-end       as decimal   no-undo .

  run day-begin-fact-order in this-procedure ( input x-date-start, output v-fact-order-start ). /*Поиск нач fact-order*/
  run day-begin-fact-order in this-procedure ( input ( x-date-end + 1 ),   output v-fact-order-end ). /*Поиск посл fact-order*/

/*  define variable  date-start  as date  no-undo .*/
/*  define variable  date-end    as date  no-undo .*/
  define variable  Counter1    as integer   no-undo .
  define variable  ii          as integer no-undo .
  define variable  Line        as character no-undo .
  define variable  Line1       as character no-undo .

/*  define variable   all-qnty             as decimal no-undo .*/
  define variable   all-sum-zak          as decimal initial 0 no-undo .
  define variable   all-sum-prod         as decimal initial 0 no-undo .
  define variable   grp-qnty             as decimal initial 0 no-undo .
  define variable   grp-sum-zak          as decimal initial 0 no-undo .
  define variable   grp-sum-prod         as decimal initial 0 no-undo .

  define variable  v-s-prod                as char                     no-undo.
  define variable  v-goods-name          as char                     no-undo.
  define variable  v-goods-unit          as char                     no-undo.
  define variable  v-num                 as char                     no-undo.
  define variable  v-date                as char                     no-undo.
  define variable  v-cli                 as char                     no-undo.
  define variable  v-value               as decimal                  no-undo.
  define variable  v-prod                as decimal                  no-undo.
  define variable  v-zak                 as decimal                  no-undo.
  define variable  v-sum-zak             as decimal                  no-undo.
  define variable  v-prib                as decimal                  no-undo.
  define variable  v-sum-prod            as decimal                  no-undo.
  define variable  v-rent                as decimal                  no-undo.

  define variable v-row       as integer   no-undo .
  define variable v-col       as integer   no-undo .
  define variable v-ind       as integer   no-undo initial 1 .

  define variable p-fact-qnty     as decimal   no-undo .
/*  define variable p-cost-rubl     as decimal   no-undo .*/
/*  define variable p-sale-rubl     as decimal   no-undo .*/
  define variable t-dec           as decimal   no-undo .

  assign
    Counter1 = 0 .
  .
  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */

/*        run gbl/inidebug.p .*/

  for each db no-lock,
      each clients no-lock
    where clients.db-num = db.db-num
    :
    for each buf_trn-doc no-lock
      where buf_trn-doc.obj-type   = clients.obj-type
        and buf_trn-doc.obj-code   = clients.obj-code
        and buf_trn-doc.status_    = {&fact}
        and buf_trn-doc.fact-order >= v-fact-order-start
        and buf_trn-doc.fact-order <  v-fact-order-end
      :
      if buf_trn-doc.hold-doc-code-child > "" or buf_trn-doc.hold-doc-code-parent > "" then next.
      if (  buf_trn-doc.ext-doc-type <> {&TDEDT_Ras_Vnesh_Kass}
        and buf_trn-doc.ext-doc-type <> {&TDEDT_Vozvrat_Vnesh_Kass}
        and buf_trn-doc.ext-doc-type <> {&TDEDT_Ras_Vnesh}
        and buf_trn-doc.ext-doc-type <> {&TDEDT_Vozvrat_Vnesh} )  then next.
      for each buf_doc-line no-lock
        where buf_doc-line.doc-code = buf_trn-doc.doc-code
        :
        find first buf_goods no-lock
          where buf_goods.artic     = buf_doc-line.artic
            and buf_goods.prod-type = buf_doc-line.prod-type
            and buf_goods.prod-code = buf_doc-line.prod-code
        .

        case x-SelectGood :
          when {&g-all} then do:
          end.
          when {&g-prod} then do:    /* не все производители */
            find first  G#cli no-lock
              where G#cli.obj-type = buf_goods.prod-type
                and G#cli.obj-code = buf_goods.prod-code
              no-error .
            if not available G#cli then next.
          end .
          when {&g-grp} then do:    /* не все группы товаров */
            define variable is-find     as logical   no-undo .
            assign is-find = no .
            for each tmp#grp :
              if buf_goods.grp-name begins tmp#grp.grp-name then do:  assign is-find = yes .   leave .   end.
            end.
            if not is-find then next.
          end.
          otherwise do:
            find first gds-list no-lock
            where gds-list.artic     = buf_goods.artic
              and gds-list.prod-type = buf_goods.prod-type
              and gds-list.prod-code = buf_goods.prod-code
            no-error .
            if not available gds-list then next.
          end.
        end case.

        find first temp-hold6
          where temp-hold6.gds-code = buf_goods.gds-code
        no-error .
        if not available temp-hold6 then do:
          create temp-hold6 .
          if g#gds-engl then assign temp-hold6.gds-name = buf_goods.engl-name.
          else               assign temp-hold6.gds-name = buf_goods.gds-name.
          assign
            temp-hold6.artic     = buf_goods.artic
            temp-hold6.prod-type = buf_goods.prod-type
            temp-hold6.prod-code = buf_goods.prod-code
            temp-hold6.grp-name = buf_goods.grp-name
            temp-hold6.gds-unit = buf_goods.unit-base
            temp-hold6.gds-code = buf_goods.gds-code
            temp-hold6.qnty     = 0
            temp-hold6.sum-zak  = 0
            temp-hold6.sum-prod = 0
          .
        end.
        create temp-doc .
        assign
          temp-doc.gds-code = buf_goods.gds-code
          temp-doc.num      = buf_trn-doc.doc-code
          temp-doc.dat      = buf_trn-doc.doc-date
          temp-doc.cli      = buf_trn-doc.cli-name
          temp-doc.qnty     = buf_doc-line.fact-qnty
        .
        if x-SET_val_TYPE = 1 then do:
          run r-cost in this-procedure ( input buf_doc-line.doc-code, input buf_doc-line.artic, input buf_doc-line.prod-type, input buf_doc-line.prod-code,
               output p-fact-qnty, output t-dec, output t-dec,output t-dec, output temp-doc.zak, output t-dec, output t-dec, output t-dec
              ,output t-dec, output t-dec, output t-dec, output t-dec, output t-dec, output t-dec, output t-dec, output t-dec, output t-dec ) no-error .
          run r-sale in this-procedure ( input buf_doc-line.doc-code, input buf_doc-line.artic, input buf_doc-line.prod-type, input buf_doc-line.prod-code,
               output p-fact-qnty, output t-dec, output t-dec,output t-dec, output temp-doc.prod, output t-dec, output t-dec, output t-dec
              ,output t-dec, output t-dec, output t-dec, output t-dec, output t-dec, output t-dec, output t-dec, output t-dec, output t-dec ) no-error .
        end.
        else do:
          run r-cost in this-procedure ( input buf_doc-line.doc-code, input buf_doc-line.artic, input buf_doc-line.prod-type, input buf_doc-line.prod-code,
               output p-fact-qnty, output t-dec, output t-dec, output temp-doc.zak,output t-dec, output t-dec, output t-dec, output t-dec
              ,output t-dec, output t-dec, output t-dec, output t-dec, output t-dec, output t-dec, output t-dec, output t-dec, output t-dec ) no-error .
          run r-sale in this-procedure ( input buf_doc-line.doc-code, input buf_doc-line.artic, input buf_doc-line.prod-type, input buf_doc-line.prod-code,
               output p-fact-qnty, output t-dec, output t-dec, output temp-doc.prod, output t-dec, output t-dec, output t-dec, output t-dec
              ,output t-dec, output t-dec, output t-dec, output t-dec, output t-dec, output t-dec, output t-dec, output t-dec, output t-dec ) no-error .
        end.
        if (buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass} or buf_trn-doc.ext-doc-type <> {&TDEDT_Vozvrat_Vnesh})  then
          assign
/*            temp-doc.qnty = - temp-doc.qnty*/
            temp-doc.zak  = - temp-doc.zak
            temp-doc.prod = - temp-doc.prod
          .
        assign
          temp-hold6.qnty     = temp-hold6.qnty     + temp-doc.qnty
          temp-hold6.sum-zak  = temp-hold6.sum-zak  + temp-doc.qnty * temp-doc.zak
          temp-hold6.sum-prod = temp-hold6.sum-prod + temp-doc.qnty * temp-doc.prod
          all-sum-prod        = all-sum-prod + temp-hold6.sum-prod
          all-sum-zak         = all-sum-zak  + temp-hold6.sum-zak
        .
      end.
    end.
  end.

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */

  /* macr_excel - для экселя */
  assign
    make-excel = yes
    v-file-name = string(session :temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt"
  .
  output stream macr_excel to value(v-file-name) .
  assign v-ind = v-ind + 1 .


  { gbl/working.i }

  Line = fill("-", 250).

  DEFINE frame f-doc
        sym19  temp-hold6.artic  column-label " Артикул! " format "X(12)"         space(0)
        sym20  v-s-prod        column-label " Произ-! водитель" format "X(12)"         space(0)
        sym1  v-goods-name column-label " Наименование товара! " format "X(40)"          space(0)
/*        sym2  v-num        column-label "Ед.!изм"                format "X(14)"          space(0)*/
        sym2  v-num        column-label " № накл.! "             format "X(14)"          space(0)
        sym3  v-date       column-label " дата! "                format "X(10)"     space(0)
        sym4  v-cli        column-label " Покупатель! "          format "X(40)"          space(0)
        sym5  v-value      column-label " Кол-во!реал-ции"       format "->,>>>,>>9.999" space(0)
        sym6  v-prod       column-label "Цена!продажи"           format "->>,>>>,>>9.99" space(0)
        sym7  v-zak        column-label "Цена ТД!(закупки)"      format "->>,>>>,>>9.99" space(0)
        sym8  v-sum-zak    column-label "Сумма в ценах!ТД (закупки)"  format "->>,>>>,>>9.99" space(0)
        sym9  v-prib       column-label "Сумма !наценки"         format "->>,>>>,>>9.99" space(0)
        sym10 v-sum-prod   column-label "ИТОГО!товарооборот"     format "->>,>>>,>>9.99" space(0)
        sym11 v-rent       column-label "%  !рентаб."            format "->>>9.99"       space(0)
        sym12
  HEADER
        string( "Дата печати : " + string(TODAY , "99.99.9999") + " , " + string(TIME, "HH:MM") ) AT 5 format "X(100)"
        string( "Страница " + string( PAGE-NUMBER( OutStream )  , ">>9") ) AT 150 format "X(15)" SKIP
        Line format "X(247)" AT 1
  with width 250 /* {&DOS_CW}*/ down stream-io.

  DEFINE frame f-doc1
        sym1  v-goods-name column-label " Ассортимент! "         format "X(40)"          space(0)
        sym2  v-value      column-label "Итого !кол-во"          format "->,>>>,>>9.999" space(0)
        sym3  v-sum-zak    column-label "Сумма в! ценах ТД"      format "->>,>>>,>>9.99" space(0)
        sym4  v-prib       column-label "Сумма !наценки"         format "->>,>>>,>>9.99" space(0)
        sym5  v-sum-prod   column-label "ИТОГО!товарооборот"     format "->>,>>>,>>9.99" space(0)
        sym6  v-rent       column-label "%  !рентаб."            format "->>>9.99"       space(0)
        sym7
  HEADER
        Line format "X(117)" AT 1
  with width {&DOS_CW} down stream-io.

  { cmp/open-out.i stream OutStream " " {&LS_PS_A4} }

  FORM with FRAME f-doc .
  PUT stream OutStream  SPACE(30) String("Отчет по реализации с " + string(x-date-start,"99.99.9999") + " по " + string(x-date-end,"99.99.9999"))   format "X(130)"  SKIP .

  run PutColumnTitulExcel in this-procedure .

  for each temp-hold6 no-lock
     by temp-hold6.grp-name
     by temp-hold6.gds-code
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
    run PrintLine in this-procedure .
  end. /* for each temp-hold6  */
  run PrintItog in this-procedure .

  PUT STREAM OutStream Line format "X(247)" skip.
  PUT stream OutStream skip "Итоги по ассортиментам" format "X(130)"  SKIP .

  run PutColumnTitulExcel1 in this-procedure .

  for each temp-hold6 no-lock
     break by temp-hold6.grp-name
     by temp-hold6.gds-code
    :
    if  ( v-row ) >= 63000 then do:
      Output stream Macr_Excel  close .
      /*Запишем в файл параметров */
      run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name ) .
      /* создаем временный файл */
      run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
      output stream  Macr_Excel to value(v-file-name) .
      v-ind = v-ind + 1 .
      run PutColumnTitulExcel1 in this-procedure .
    end.
    if first-of(temp-hold6.grp-name ) then do:
      run macr_excel_char("Группа: " + temp-hold6.grp-name, v-row, 1) .
      assign
        v-row = v-row + 1
        v-goods-name = "Группа: " + temp-hold6.grp-name
        grp-qnty     = 0
        grp-sum-zak  = 0
        grp-sum-prod = 0
      .
      display stream outstream sym1 v-goods-name sym2 sym3 sym4 sym5 sym6 sym7  with frame f-doc1.
      down stream outstream with frame f-doc1 .
    end.
    run PrintLine1 in this-procedure .
    if last-of(temp-hold6.grp-name ) then run PrintItog1 in this-procedure .
  end. /* for each temp-hold6  */
  run PrintItog2 in this-procedure .

  PUT STREAM OutStream Line format "X(117)" skip.


  HIDE stream OutStream FRAME BottomFrame .
  OUTPUT stream OutStream CLOSE.

  output stream macr_excel close .
  run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name) .
  run end-proc .

  { gbl/stopwork.i }

  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .
  run gbl/prnfilen.w
    (input  ""
    ,input  1
    ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
    ,input  7
    ,output v-user-action
    ,output v-printed
    ) .

end.


procedure PutColumnTitulExcel : /* заголовки для колонок экселя */
  do
  on error undo, return error return-value
  :
  assign
    v-row = 2
    v-col = 1
  .
  run macr_excel_char (String("Отчет по реализации с " + string(x-date-start,"99.99.9999") + " по " + string(x-date-end,"99.99.9999")), 1, 1) .
  run macr_cell_format ( 11, yes, no, ?, 1, 1, 1, 1) .

  run macr_excel_char("Артикул", v-row, v-col) .             assign v-col = v-col + 1 .
  run macr_excel_char("Производитель", v-row, v-col) .             assign v-col = v-col + 1 .
  run macr_excel_char("Наименование товара", v-row, v-col) .
  run macr_cell_size (40,?, v-row, v-col,?,?).                       assign v-col = v-col + 1 .
  run macr_excel_char("№ накл.", v-row, v-col) .
  run macr_cell_size (14,?, v-row, v-col,?,?).                       assign v-col = v-col + 1 .
  run macr_excel_char("дата", v-row, v-col) .
  run macr_cell_size (10,?, v-row, v-col,?,?).                       assign v-col = v-col + 1 .
  run macr_excel_char("Покупатель", v-row, v-col) .
  run macr_cell_size (40,?, v-row, v-col,?,?).                       assign v-col = v-col + 1 .
  run macr_excel_char("Кол-во реал-ции", v-row, v-col) .             assign v-col = v-col + 1 .
  run macr_excel_char("Цена продажи", v-row, v-col) .                assign v-col = v-col + 1 .
  run macr_excel_char("Цена ТД (закупки)", v-row, v-col) .           assign v-col = v-col + 1 .
  run macr_excel_char("Сумма в ценах ТД (закупки)", v-row, v-col) .  assign v-col = v-col + 1 .
  run macr_excel_char("Сумма наценки", v-row, v-col) .               assign v-col = v-col + 1 .
  run macr_excel_char("ИТОГО товарооборот", v-row, v-col) .          assign v-col = v-col + 1 .
  run macr_excel_char("% рентабельности", v-row, v-col) .            assign v-col = v-col + 1 .

  run macr_cell_bordur ( v-row, 1, v-row, 11) .
  run macr_cell_format ( 10, yes, no, 35, v-row, 1, v-row, 11) .
  run macr_cell_size (14,?, v-row, 5, v-row, 12) .
  assign v-row = v-row + 1 .
  end.
end procedure. /* PutColumnTitulExcel */


procedure PutColumnTitulExcel1 : /* заголовки для колонок экселя */
  do
  on error undo, return error return-value
  :
  assign v-col = 1 .
  run macr_excel_char ("Итоги по ассортиментам", v-row, v-col) .
  run macr_cell_format ( 11, yes, no, ?, v-row, v-col, v-row, v-col) .   assign v-col = v-col + 1 .

  run macr_excel_char("Ассортимент", v-row, v-col) .
/*  run macr_cell_size (40,?, v-row, v-col,?,?).                       assign v-col = v-col + 1 .*/
  run macr_excel_char("Итого кол-во", v-row, v-col) .                assign v-col = v-col + 1 .
  run macr_excel_char("Сумма в ценах ТД", v-row, v-col) .            assign v-col = v-col + 1 .
  run macr_excel_char("Сумма наценки", v-row, v-col) .               assign v-col = v-col + 1 .
  run macr_excel_char("ИТОГО товарооборот", v-row, v-col) .          assign v-col = v-col + 1 .
  run macr_excel_char("% рентабельности", v-row, v-col) .

  run macr_cell_bordur ( v-row, 1, v-row, v-col) .
  run macr_cell_format ( 10, yes, no, 35, v-row, 1, v-row, v-col) .
/*  run macr_cell_size (14,?, v-row, 2, v-row, v-col) .*/
  assign v-row = v-row + 1 .
  end.
end procedure. /* PutColumnTitulExcel1 */


procedure PrintLine :
  do
  on error undo, return error return-value
  :
    define variable stat as logical initial no no-undo .

    for each temp-doc
      where temp-doc.gds-code = temp-hold6.gds-code
      :
      if stat = no then do:
        assign
          stat         = yes
          v-s-prod       = temp-hold6.prod-type + " " + string(temp-hold6.prod-code)
          v-goods-name = temp-hold6.gds-name
          v-num        = temp-doc.num
          v-date       = String(temp-doc.dat,"99.99.9999")
          v-cli        = temp-doc.cli
          v-value      = temp-doc.qnty
          v-prod       = temp-doc.zak
          v-zak        = temp-doc.prod
          v-sum-zak    = temp-doc.zak * temp-doc.qnty
          v-prib       = (temp-doc.prod - temp-doc.zak) * temp-doc.qnty
          v-sum-prod   = temp-doc.prod * temp-doc.qnty
          v-rent       = v-prib * 100 / v-sum-zak
        .
        run macr_excel_char(temp-hold6.artic, v-row, 1) .
        run macr_excel_char(v-s-prod, v-row, 2) .
      end.
      else do:
        assign
          v-goods-name = ""
          v-s-prod       = ""
          v-num        = temp-doc.num
          v-date       = String(temp-doc.dat,"99.99.9999")
          v-cli        = temp-doc.cli
          v-value      = temp-doc.qnty
          v-prod       = temp-doc.zak
          v-zak        = temp-doc.prod
          v-sum-zak    = temp-doc.zak * temp-doc.qnty
          v-prib       = (temp-doc.prod - temp-doc.zak) * temp-doc.qnty
          v-sum-prod   = temp-doc.prod * temp-doc.qnty
          v-rent       = v-prib * 100 / v-sum-zak
        .
      end.
      if v-rent = ? then assign v-rent = 0 .

      display stream outstream sym1 temp-hold6.artic v-s-prod  v-goods-name sym2 v-num sym3 v-date sym4 v-cli sym5 v-value sym6 v-prod sym7 v-zak
                               sym8 v-sum-zak sym9 v-prib sym10 v-sum-prod sym11 v-rent sym12  sym19  sym20  with frame f-doc.
      down stream outstream with frame f-doc .

      run macr_excel_char(v-goods-name , v-row, 3) .
      run macr_excel_char(v-num        , v-row, 4) .
      run macr_excel_char(v-date       , v-row, 5) .
      run macr_excel_char(v-cli        , v-row, 6) .
      run macr_excel_sum (v-value      , v-row, 7,  3) .
      run macr_excel_sum (v-prod       , v-row, 8,  2) .
      run macr_excel_sum (v-zak        , v-row, 9,  2) .
      run macr_excel_sum (v-sum-zak    , v-row, 10,  2) .
      run macr_excel_sum (v-prib       , v-row, 11,  2) .
      run macr_excel_sum (v-sum-prod   , v-row, 12, 2) .
      run macr_excel_sum (v-rent       , v-row, 13, 2) .
      assign v-row = v-row + 1 .

    end.

    assign
      v-goods-name = "Итого по товару"
      v-value      = temp-hold6.qnty
      v-sum-zak    = temp-hold6.sum-zak
      v-prib       = temp-hold6.sum-prod - temp-hold6.sum-zak
      v-sum-prod   = temp-hold6.sum-prod
      v-rent       = (temp-hold6.sum-prod - temp-hold6.sum-zak) * 100 / temp-hold6.sum-zak
    .
    if v-rent = ? then assign v-rent = 0 .

    display stream outstream sym1 v-goods-name sym2 sym3 sym4 sym5 v-value sym6 sym7 sym8 v-sum-zak sym9 v-prib sym10 v-sum-prod sym11 v-rent sym12  sym19  sym20  with frame f-doc.
    down stream outstream with frame f-doc .

    run macr_excel_char(v-goods-name , v-row, 3) .
    run macr_excel_sum (v-value      , v-row, 7,  3) .
    run macr_excel_sum (v-sum-zak    , v-row, 10,  2) .
    run macr_excel_sum (v-prib       , v-row, 11,  2) .
    run macr_excel_sum (v-sum-prod   , v-row, 12, 2) .
    run macr_excel_sum (v-rent       , v-row, 13, 2) .
    assign v-row = v-row + 1 .

  end.
end procedure. /* PrintLine */


procedure PrintLine1 :
  do
  on error undo, return error return-value
  :
    assign
      v-goods-name = "  " + temp-hold6.gds-name
      v-value      = temp-hold6.qnty
      v-sum-zak    = temp-hold6.sum-zak
      v-prib       = temp-hold6.sum-prod - temp-hold6.sum-zak
      v-sum-prod   = temp-hold6.sum-prod
      v-rent       = (temp-hold6.sum-prod - temp-hold6.sum-zak) * 100 / temp-hold6.sum-zak
      grp-qnty     = grp-qnty     + temp-hold6.qnty
      grp-sum-zak  = grp-sum-zak  + temp-hold6.sum-zak
      grp-sum-prod = grp-sum-prod + temp-hold6.sum-prod
    .
    if v-rent = ? then assign v-rent = 0 .
/*    message*/
/*      temp-hold6.gds-name temp-hold6.sum-zak grp-sum-zak*/
/*      view-as alert-box.*/

    display stream outstream sym1 v-goods-name sym2 v-value sym3 v-sum-zak sym4 v-prib sym5 v-sum-prod sym6 v-rent sym7 with frame f-doc1.
    down stream outstream with frame f-doc1 .

    run macr_excel_char(v-goods-name , v-row, 1) .
    run macr_excel_sum (v-value      , v-row, 2, 3) .
    run macr_excel_sum (v-sum-zak    , v-row, 3, 2) .
    run macr_excel_sum (v-prib       , v-row, 4, 2) .
    run macr_excel_sum (v-sum-prod   , v-row, 5, 2) .
    run macr_excel_sum (v-rent       , v-row, 6, 2) .
    assign v-row = v-row + 1 .
  end.
end procedure. /* PrintLine1 */


procedure PrintItog :
  do
  on error undo, return error return-value
  :
    assign
      v-goods-name = "ИТОГО: "
      v-sum-zak    = all-sum-zak
      v-prib       = all-sum-prod - all-sum-zak
      v-sum-prod   = all-sum-prod
      v-rent       = (all-sum-prod - all-sum-zak) * 100 / all-sum-zak
    .
    if v-rent = ? then assign v-rent = 0 .

    display stream outstream sym1 v-goods-name sym2 sym3 sym4 sym5 sym6 sym7 sym8 v-sum-zak sym9 v-prib sym10 v-sum-prod sym11 v-rent sym12  sym19  sym20  with frame f-doc.
    down stream outstream with frame f-doc .

    run macr_excel_char(v-goods-name , v-row, 3) .
    run macr_excel_sum (v-sum-zak    , v-row, 10,  2) .
    run macr_excel_sum (v-prib       , v-row, 11,  2) .
    run macr_excel_sum (v-sum-prod   , v-row, 12, 2) .
    run macr_excel_sum (v-rent       , v-row, 13, 2) .
    assign v-row = v-row + 1 .

  end.
end procedure. /* PrintItog */


procedure PrintItog1 :
  do
  on error undo, return error return-value
  :
    assign
      v-goods-name = "Итого по " + temp-hold6.grp-name
      v-value      = grp-qnty
      v-sum-zak    = grp-sum-zak
      v-prib       = grp-sum-prod - grp-sum-zak
      v-sum-prod   = grp-sum-prod
      v-rent       = (grp-sum-prod - grp-sum-zak) * 100 / grp-sum-zak
    .
    if v-rent = ? then assign v-rent = 0 .
    display stream outstream sym1 v-goods-name sym2 v-value sym3 v-sum-zak sym4 v-prib sym5 v-sum-prod sym6 v-rent sym7 with frame f-doc1.
    down stream outstream with frame f-doc1 .

    run macr_excel_char(v-goods-name , v-row, 1) .
    run macr_excel_sum (v-value      , v-row, 2,  2) .
    run macr_excel_sum (v-sum-zak    , v-row, 3,  2) .
    run macr_excel_sum (v-prib       , v-row, 4,  2) .
    run macr_excel_sum (v-sum-prod   , v-row, 5, 2) .
    run macr_excel_sum (v-rent       , v-row, 6, 2) .
    assign v-row = v-row + 1 .
  end.
end procedure. /* PrintItog1 */


procedure PrintItog2 :
  do
  on error undo, return error return-value
  :
  assign
    v-goods-name = "ИТОГО:"
    v-sum-zak    = all-sum-zak
    v-prib       = all-sum-prod - all-sum-zak
    v-sum-prod   = all-sum-prod
    v-rent       = (all-sum-prod - all-sum-zak) * 100 / all-sum-zak
  .
  if v-rent = ? then assign v-rent = 0 .

    display stream outstream sym1 v-goods-name sym2 sym3 v-sum-zak sym4 v-prib sym5 v-sum-prod sym6 v-rent sym7 with frame f-doc1.
    down stream outstream with frame f-doc1 .

    run macr_excel_char(v-goods-name , v-row, 1) .
    run macr_excel_sum (v-sum-zak    , v-row, 3,  2) .
    run macr_excel_sum (v-prib       , v-row, 4,  2) .
    run macr_excel_sum (v-sum-prod   , v-row, 5, 2) .
    run macr_excel_sum (v-rent       , v-row, 6, 2) .
    assign v-row = v-row + 1 .
  end.
end procedure. /* PrintItog1 */