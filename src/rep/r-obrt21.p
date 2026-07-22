block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-obrt21.p $
$Archive: rep/r-obrt21.p $

Это часть старой оборотки с признак
-  печать заголовков колонок для excel и принтера (вместо  obr-k2-4.i в вер 11.1 )
    PutColumnTitulExcel  печать заголовков колонок для excel
    PrintTitul           заголов. принтера

Автор: Демин Алексей Сергеевич
Дата создания: 09/07/05
Author: Alexey Demin
Creation date: 09/07/05

*/

define input parameter typ        as integer   no-undo .
define input parameter RADIO-AltObj      as integer   no-undo .
define input parameter end-sum           as integer   no-undo .
define output parameter start-col as integer   no-undo .
define output parameter end-row   as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-obrt21.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-obrt21.p $":U .
define variable vss-description as character no-undo init "Старая оборотка с признак".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }

do
on error undo, return error
:

  define shared Stream OutStream.
  define shared stream macr_excel .
  define variable ii   as integer   no-undo .
  define variable Line as character no-undo .
  define variable frmt as character no-undo .
  define variable beg  as integer   no-undo .

  assign
    frmt = "X(" + string(end-sum) + ')'
    Line = fill("-", end-sum).
  .

  if typ = 1 then run PutColumnTitulExcel .
  else run            PrintTitul .

end.

procedure PutColumnTitulExcel : /* заголовки для колонок экселя */
  do
  on error undo, return error return-value
  :
  define variable v-col as integer   no-undo .
  define variable v-row as integer   no-undo .
  assign
    v-col = 1
    v-row = 1
  .
  run macr_excel_char (ReportNAme, v-row, 4) .
  run macr_cell_format ( 11, yes, no, ?, v-row, 4, v-row, 4) .
  assign v-row = v-row + 1 .

  run macr_excel_char ("Выбранные объекты: " + str4, v-row, v-col) .
  assign v-row = v-row + 1 .
  run macr_excel_char (ReportHeader, v-row, v-col) .
  assign v-row = v-row + 1 .
/*  run macr_excel_char ("Выбор цен: " + (if x-SET_val_TYPE = 1 then "{&abbr_rublevye}" else "валютные" ), v-row, v-col) .*/
/*  assign v-row = v-row + 1 .*/
  run macr_excel_char (str1, v-row, v-col) .
  assign v-row = v-row + 1 .
  run macr_excel_char (str2, v-row, v-col) .
  assign v-row = v-row + 1 .
  run macr_excel_char (str3, v-row, v-col) .
  assign v-row = v-row + 1 .

  assign v-col = 1 .

  if use-column[1] = yes then do:
    run macr_excel_char ("Код", v-row, v-col) .
    run  macr_cell_size (13,?, v-row, v-col,?,?).
    assign v-col = v-col + 1 .
  end.
  if use-column[2] = yes then do:
    run macr_excel_char ("Артикул", v-row, v-col) .
    run  macr_cell_size (16,?, v-row, v-col,?,?).
    assign v-col = v-col + 1 .
  end.
  if use-column[3] = yes then do:
    run macr_excel_char ("Название товара", v-row, v-col) .
    run  macr_cell_size (40,?, v-row, v-col,?,?) .
    assign v-col = v-col + 1 .
  end.
  if use-column[4] = yes then do:
    run macr_excel_char ("Ед. изм", v-row, v-col) .
    run  macr_cell_size (5,?, v-row, v-col,?,?) .
    assign v-col = v-col + 1 .
  end.
  assign ii = v-col .
  if use-column[5] = yes then do:
    run macr_excel_char ("Учетная цена", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[6] = yes then do:
    run macr_excel_char ("Цена продажи", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[7] = yes then do:
    run macr_excel_char ("Наценка на конец периода", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[8] = yes then do:
    run macr_excel_char ("Дата послед. переоцен.", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[9] = yes then do:
    run macr_excel_char ("Номер послед. переоцен.", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.

  assign  start-col = v-col .

  if use-column[12] = yes then do:
    run macr_excel_char ("Остаток на начало (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[31] = yes then do:
    run macr_excel_char ("Остаток на начало (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[50] = yes then do:
    run macr_excel_char ("Остаток на начало (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.

  if use-column[14] = yes then do:
    run macr_excel_char ("Приход внешний (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[33] = yes then do:
    run macr_excel_char ("Приход внешний (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.

  if use-column[15] = yes then do:
    run macr_excel_char ("Возврат поставщику (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[34] = yes then do:
    run macr_excel_char ("Возврат поставщику (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.

  if use-column[16] = yes then do:
    run macr_excel_char ("Расход внешний (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[35] = yes then do:
    run macr_excel_char ("Расход внешний (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[52] = yes then do:
    run macr_excel_char ("Расход внешний (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[68] = yes then do:
    run macr_excel_char ("Расход внешний (скидка)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[77] = yes then do:
    run macr_excel_char ("Расход внешний (% скидки)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.

  if use-column[17] = yes then do:
    run macr_excel_char ("Возврат внешний (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[36] = yes then do:
    run macr_excel_char ("Возврат внешний (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[53] = yes then do:
    run macr_excel_char ("Возврат внешний (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[69] = yes then do:
    run macr_excel_char ("Возврат внешний (скидка)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[78] = yes then do:
    run macr_excel_char ("Возврат внешний (% скидки)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.

  if use-column[18] = yes then do:
    run macr_excel_char ("Расход-Возврат (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[37] = yes then do:
    run macr_excel_char ("Расход-Возврат (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[54] = yes then do:
    run macr_excel_char ("Расход-Возврат (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[70] = yes then do:
    run macr_excel_char ("Расход-Возврат-скидка", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[79] = yes then do:
    run macr_excel_char ("Расход-Возврат (% скидки)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.

  if use-column[19] = yes then do:
    run macr_excel_char ("Касса продажа (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[38] = yes then do:
    run macr_excel_char ("Касса (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[55] = yes then do:
    run macr_excel_char ("Касса (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[71] = yes then do:
    run macr_excel_char ("Касса (скидка)", v-row, v-col) .    assign v-col = v-col + 1 .
  end.
  if use-column[80] = yes then do:
    run macr_excel_char ("Касса (% скидки)", v-row, v-col) .    assign v-col = v-col + 1 .
  end.

  if use-column[20] = yes then do:
    run macr_excel_char ("Касса возврат (кол-во)", v-row, v-col) .    assign v-col = v-col + 1 .
  end.
  if use-column[39] = yes then do:
    run macr_excel_char ("Касса возврат (сумма учет. цен)", v-row, v-col) .    assign v-col = v-col + 1 .
  end.
  if use-column[56] = yes then do:
    run macr_excel_char ("Касса возврат (сумма прод. цен)", v-row, v-col) .    assign v-col = v-col + 1 .
  end.
  if use-column[72] = yes then do:
    run macr_excel_char ("Касса возврат (скидка)", v-row, v-col) .             assign v-col = v-col + 1 .
  end.
  if use-column[81] = yes then do:
    run macr_excel_char ("Касса возврат (% скидки)", v-row, v-col) .           assign v-col = v-col + 1 .
  end.

  if use-column[21] = yes then do:
    run macr_excel_char ("Касса продажа-возврат (кол-во)", v-row, v-col) .     assign v-col = v-col + 1 .
  end.
  if use-column[40] = yes then do:
    run macr_excel_char ("Касса продажа-возврат (сумма учет. цен)", v-row, v-col) .    assign v-col = v-col + 1 .
  end.
  if use-column[57] = yes then do:
    run macr_excel_char ("Касса продажа-возврат (сумма прод. цен)", v-row, v-col) .    assign v-col = v-col + 1 .
  end.
  if use-column[73] = yes then do:
    run macr_excel_char ("Касса продажа-возврат-скидка", v-row, v-col) .               assign v-col = v-col + 1 .
  end.
  if use-column[82] = yes then do:
    run macr_excel_char ("Касса продажа-возврат (% скидки)", v-row, v-col) .           assign v-col = v-col + 1 .
  end.

  if use-column[22] = yes then do:
    run macr_excel_char ("Всего расход (кол-во)", v-row, v-col) .                      assign v-col = v-col + 1 .
  end.
  if use-column[41] = yes then do:
    run macr_excel_char ("Всего расход (сумма учет. цен)", v-row, v-col) .             assign v-col = v-col + 1 .
  end.
  if use-column[58] = yes then do:
    run macr_excel_char ("Всего расход (сумма прод. цен)", v-row, v-col) .             assign v-col = v-col + 1 .
  end.
  if use-column[74] = yes then do:
    run macr_excel_char ("Всего расход (скидка)", v-row, v-col) .                      assign v-col = v-col + 1 .
  end.
  if use-column[83] = yes then do:
    run macr_excel_char ("Всего расход (% скидки)", v-row, v-col) .                    assign v-col = v-col + 1 .
  end.

  if use-column[23] = yes then do:
    run macr_excel_char ("Всего возврат (кол-во)", v-row, v-col) .    assign v-col = v-col + 1 .
  end.
  if use-column[42] = yes then do:
    run macr_excel_char ("Всего возврат (сумма учет. цен)", v-row, v-col) .    assign v-col = v-col + 1 .
  end.
  if use-column[59] = yes then do:
    run macr_excel_char ("Всего возврат (сумма прод. цен)", v-row, v-col) .    assign v-col = v-col + 1 .
  end.
  if use-column[75] = yes then do:
    run macr_excel_char ("Всего возврат (скидка)", v-row, v-col) .             assign v-col = v-col + 1 .
  end.
  if use-column[84] = yes then do:
    run macr_excel_char ("Всего возврат (% скидки)", v-row, v-col) .           assign v-col = v-col + 1 .
  end.

  if use-column[24] = yes then do:
    run macr_excel_char ("Всего расход-возврат (кол-во)", v-row, v-col) .      assign v-col = v-col + 1 .
  end.
  if use-column[43] = yes then do:
    run macr_excel_char ("Всего расход-возврат (сумма учет. цен)", v-row, v-col) .    assign v-col = v-col + 1 .
  end.
  if use-column[60] = yes then do:
    run macr_excel_char ("Всего расход-возврат (сумма прод. цен)", v-row, v-col) .    assign v-col = v-col + 1 .
  end.
  if use-column[76] = yes then do:
    run macr_excel_char ("Всего расход-возврат-скидка", v-row, v-col) .               assign v-col = v-col + 1 .
  end.
  if use-column[85] = yes then do:
    run macr_excel_char ("Всего расход-возврат (% скидки)", v-row, v-col) .           assign v-col = v-col + 1 .
  end.

  if use-column[25] = yes then do:
    run macr_excel_char ("Инвентаризация (кол-во)", v-row, v-col) .                   assign v-col = v-col + 1 .
  end.
  if use-column[44] = yes then do:
    run macr_excel_char ("Инвентаризация (сумма учет. цен)", v-row, v-col) .          assign v-col = v-col + 1 .
  end.
  if use-column[61] = yes then do:
    run macr_excel_char ("Инвентаризация (сумма прод. цен)", v-row, v-col) .          assign v-col = v-col + 1 .
  end.

  if use-column[26] = yes then do:
    run macr_excel_char ("Списание (кол-во)", v-row, v-col) .                         assign v-col = v-col + 1 .
  end.
  if use-column[45] = yes then do:
    run macr_excel_char ("Списание (сумма учет. цен)", v-row, v-col) .                assign v-col = v-col + 1 .
  end.
  if use-column[62] = yes then do:
    run macr_excel_char ("Списание (сумма прод. цен)", v-row, v-col) .                assign v-col = v-col + 1 .
  end.

  if use-column[27] = yes then do:
    run macr_excel_char ("Приход перемещение (кол-во)", v-row, v-col) .               assign v-col = v-col + 1 .
  end.
  if use-column[46] = yes then do:
    run macr_excel_char ("Приход перемещение (сумма учет. цен)", v-row, v-col) .      assign v-col = v-col + 1 .
  end.
  if use-column[63] = yes then do:
    run macr_excel_char ("Приход перемещение (сумма прод. цен)", v-row, v-col) .      assign v-col = v-col + 1 .
  end.

  if use-column[28] = yes then do:
    run macr_excel_char ("Расход перемещение (кол-во)", v-row, v-col) .               assign v-col = v-col + 1 .
  end.
  if use-column[47] = yes then do:
    run macr_excel_char ("Расход перемещение (сумма учет. цен)", v-row, v-col) .      assign v-col = v-col + 1 .
  end.
  if use-column[64] = yes then do:
    run macr_excel_char ("Расход перемещение (сумма прод. цен)", v-row, v-col) .      assign v-col = v-col + 1 .
  end.

  if use-column[29] = yes then do:
    run macr_excel_char ("Возврат перемещение (кол-во)", v-row, v-col) .              assign v-col = v-col + 1 .
  end.
  if use-column[48] = yes then do:
    run macr_excel_char ("Возврат перемещение (сумма учет. цен)", v-row, v-col) .     assign v-col = v-col + 1 .
  end.
  if use-column[65] = yes then do:
    run macr_excel_char ("Возврат перемещение (сумма прод. цен)", v-row, v-col) .     assign v-col = v-col + 1 .
  end.

  if use-column[30] = yes then do:
    run macr_excel_char ("Приход производство (кол-во)", v-row, v-col) .              assign v-col = v-col + 1 .
  end.
  if use-column[49] = yes then do:
    run macr_excel_char ("Приход производство (сумма учет. цен)", v-row, v-col) .     assign v-col = v-col + 1 .
  end.
  if use-column[66] = yes then do:
    run macr_excel_char ("Приход производство (сумма прод. цен)", v-row, v-col) .     assign v-col = v-col + 1 .
  end.

  if use-column[86] = yes then do:
    run macr_excel_char ("Списание производство (кол-во)", v-row, v-col) .            assign v-col = v-col + 1 .
  end.
  if use-column[87] = yes then do:
    run macr_excel_char ("Списание производство (сумма учет. цен)", v-row, v-col) .    assign v-col = v-col + 1 .
  end.
  if use-column[88] = yes then do:
    run macr_excel_char ("Списание производство (сумма прод. цен)", v-row, v-col) .    assign v-col = v-col + 1 .
  end.

  if use-column[67] = yes then do:
    run macr_excel_char ("Переоценка", v-row, v-col) .                                 assign v-col = v-col + 1 .
  end.

  if use-column[13] = yes then do:
    run macr_excel_char ("Остаток на конец (кол-во)", v-row, v-col) .                  assign v-col = v-col + 1 .
  end.
  if use-column[32] = yes then do:
    run macr_excel_char ("Остаток на конец  (сумма учет. цен)", v-row, v-col) .        assign v-col = v-col + 1 .
  end.
  if use-column[51] = yes then do:
    run macr_excel_char ("Остаток на конец  (сумма прод. цен)", v-row, v-col) .        assign v-col = v-col + 1 .
  end.

  if use-column[10] = yes then do:
    run macr_excel_char ("Эффективность", v-row, v-col) .                              assign v-col = v-col + 1 .
  end.
  if use-column[11] = yes then do:
    run macr_excel_char ("Фактический % наценки", v-row, v-col) .                      assign v-col = v-col + 1 .
  end.
  if RADIO-AltObj > 1 then do:
    run macr_excel_char ("Кол-во на альтерн. объектах", v-row, v-col) .                assign v-col = v-col + 1 .
  end.

  run macr_cell_bordur ( v-row, 1, v-row, v-col - 1) .
  run macr_cell_format ( 10, yes, no, 35, v-row, 1, v-row, v-col - 1) .
  run  macr_cell_size (12,?, v-row, ii,v-row, v-col - 1) .

  assign end-row = v-row + 1 .

  end.
end procedure. /* PutColumnTitulExcel */



procedure PrintTitul :

  if (PAGE-NUMBER( outstream ) = 1 ) then do:
    PUT stream OutStream SPACE(30) ReportNAme format "X(85)" SKIP .

    define variable ss1 as character no-undo .
    assign  ss1 = 'X(' + string(length (ReportHeader)) + ')' .
    PUT stream OutStream ReportHeader format ss1 SKIP.

    assign
      str4 = "Выбранные объекты: " + str4
      ss1 = 'X(' + string(length (str4)) + ')'
    .
    PUT stream OutStream str4 format ss1 SKIP.
/*  if RADIO-AltObj > 2 then do:*/
/*    assign ss1 = 'X(' + string(length (str3)) + ')' .*/
/*    PUT stream OutStream str3 format ss1 SKIP.*/
/*  end.*/
  end.

  put stream outstream  skip
    string( "Дата печати :" ) AT 5 format "x(15)" TODAY format "99.99.9999"
    string( " , " ) format "X(3)" string(TIME, "HH:MM")
    string( "Страница" ) AT 45 PAGE-NUMBER( outstream ) AT 55 FORMAT ">>>>9" SKIP
    Line format frmt skip .

  assign  beg = 1 .   /* 1 строка заголовка */
  if use-column[1] = yes then do:  put stream outstream  "|" at beg  " Код" format "X(6)" .              assign beg = beg + 14 . end.
  if use-column[2] = yes then do:  put stream outstream  "|" at beg  " Артикул" format "X(16)" .         assign beg = beg + 17 . end.
  if use-column[3] = yes then do:  put stream outstream  "|" at beg  " Название товара" format "X(40)" . assign beg = beg + 41 . end.
  if use-column[4] = yes then do:  put stream outstream  "|" at beg  "Ед." format "X(3)" .               assign beg = beg + 5 .  end.
  if use-column[5] = yes then do:  put stream outstream  "|" at beg  " Учетная цена" format "X(14)" .    assign beg = beg + 15 . end.
  if use-column[6] = yes then do:  put stream outstream  "|" at beg  " Цена продажи" format "X(14)" .    assign beg = beg + 15 . end.
  if use-column[7] = yes then do:  put stream outstream  "|" at beg  " Наценка" format "X(14)" .         assign beg = beg + 15 . end.
  if use-column[8] = yes then do:  put stream outstream  "|" at beg  " Дата" format "X(10)" .            assign beg = beg + 11 . end.
  if use-column[9] = yes then do:  put stream outstream  "|" at beg  " Номер" format "X(10)" .           assign beg = beg + 11 . end.
  if use-column[12] = yes then do: put stream outstream  "|" at beg  " Остаток" format "X(14)" .         assign beg = beg + 15 . end.
  if use-column[31] = yes then do: put stream outstream  "|" at beg  " Остаток на" format "X(14)" .      assign beg = beg + 15 . end.
  if use-column[50] = yes then do: put stream outstream  "|" at beg  " Остаток на" format "X(14)" .      assign beg = beg + 15 .  end.
  if use-column[14] = yes then do: put stream outstream  "|" at beg  " Приход" format "X(14)" .          assign beg = beg + 15 .  end.
  if use-column[33] = yes then do: put stream outstream  "|" at beg  " Приход" format "X(14)" .          assign beg = beg + 15 .  end.
  if use-column[15] = yes then do: put stream outstream  "|" at beg  " Возврат" format "X(14)" .         assign beg = beg + 15 .  end.
  if use-column[34] = yes then do: put stream outstream  "|" at beg  " Возврат" format "X(14)" .         assign beg = beg + 15 .  end.
  if use-column[16] = yes then do: put stream outstream  "|" at beg  " Расход" format "X(14)" .          assign beg = beg + 15 .  end.
  if use-column[35] = yes then do: put stream outstream  "|" at beg  " Расход" format "X(14)" .          assign beg = beg + 15 .  end.
  if use-column[52] = yes then do: put stream outstream  "|" at beg  " Расход" format "X(14)" .          assign beg = beg + 15 .  end.
  if use-column[68] = yes then do: put stream outstream  "|" at beg  " Расход" format "X(14)" .          assign beg = beg + 15 .  end.
  if use-column[77] = yes then do: put stream outstream  "|" at beg  " Расход" format "X(9)" .           assign beg = beg + 10 .  end.
  if use-column[17] = yes then do: put stream outstream  "|" at beg  "Возврат" format "X(14)" .          assign beg = beg + 15 .  end.
  if use-column[36] = yes then do: put stream outstream  "|" at beg  "Возврат" format "X(14)" .          assign beg = beg + 15 .  end.
  if use-column[53] = yes then do: put stream outstream  "|" at beg  "Возврат" format "X(14)" .          assign beg = beg + 15 .  end.
  if use-column[69] = yes then do: put stream outstream  "|" at beg  "Возврат" format "X(14)" .          assign beg = beg + 15 .  end.
  if use-column[78] = yes then do: put stream outstream  "|" at beg  "Возврат" format "X(9)" .           assign beg = beg + 10 .  end.
  if use-column[18] = yes then do: put stream outstream  "|" at beg  "Расход-" format "X(14)" .          assign beg = beg + 15 .  end.
  if use-column[37] = yes then do: put stream outstream  "|" at beg  "Расход-" format "X(14)" .          assign beg = beg + 15 .  end.
  if use-column[54] = yes then do: put stream outstream  "|" at beg  "Расход-" format "X(14)" .          assign beg = beg + 15 .  end.
  if use-column[70] = yes then do: put stream outstream  "|" at beg  "Расход-" format "X(14)" .          assign beg = beg + 15 .  end.
  if use-column[79] = yes then do: put stream outstream  "|" at beg  "Расход-" format "X(9)" .           assign beg = beg + 10 .  end.
  if use-column[19] = yes then do: put stream outstream  "|" at beg  "Касса" format "X(14)" .            assign beg = beg + 15 .  end.
  if use-column[38] = yes then do: put stream outstream  "|" at beg  "Касса" format "X(14)" .            assign beg = beg + 15 .  end.
  if use-column[55] = yes then do: put stream outstream  "|" at beg  "Касса" format "X(14)" .            assign beg = beg + 15 .  end.
  if use-column[71] = yes then do: put stream outstream  "|" at beg  "Касса" format "X(14)" .            assign beg = beg + 15 .  end.
  if use-column[80] = yes then do: put stream outstream  "|" at beg  "Касса" format "X(9)" .             assign beg = beg + 10 .  end.
  if use-column[20] = yes then do: put stream outstream  "|" at beg  "Касса" format "X(14)" .            assign beg = beg + 15 .  end.
  if use-column[39] = yes then do: put stream outstream  "|" at beg  "Касса" format "X(14)" .            assign beg = beg + 15 .  end.
  if use-column[56] = yes then do: put stream outstream  "|" at beg  "Касса" format "X(14)" .            assign beg = beg + 15 .  end.
  if use-column[72] = yes then do: put stream outstream  "|" at beg  "Касса" format "X(14)" .            assign beg = beg + 15 .  end.
  if use-column[81] = yes then do: put stream outstream  "|" at beg  "Касса" format "X(9)" .             assign beg = beg + 10 .  end.
  if use-column[21] = yes then do: put stream outstream  "|" at beg  "Касса продажа" format "X(14)" .    assign beg = beg + 15 .  end.
  if use-column[40] = yes then do: put stream outstream  "|" at beg  "Касса продажа-" format "X(14)" .   assign beg = beg + 15 .  end.
  if use-column[57] = yes then do: put stream outstream  "|" at beg  "Касса продажа-" format "X(14)" .   assign beg = beg + 15 .  end.
  if use-column[73] = yes then do: put stream outstream  "|" at beg  "Касса продажа" format "X(14)" .    assign beg = beg + 15 .  end.
  if use-column[82] = yes then do: put stream outstream  "|" at beg  "Касса " format "X(9)" .            assign beg = beg + 10 .  end.
  if use-column[22] = yes then do: put stream outstream  "|" at beg  "Всего" format "X(14)" .            assign beg = beg + 15 .  end.
  if use-column[41] = yes then do: put stream outstream  "|" at beg  "Всего" format "X(14)" .            assign beg = beg + 15 .  end.
  if use-column[58] = yes then do: put stream outstream  "|" at beg  "Всего" format "X(14)" .            assign beg = beg + 15 .  end.
  if use-column[74] = yes then do: put stream outstream  "|" at beg  "Всего" format "X(14)" .            assign beg = beg + 15 .  end.
  if use-column[83] = yes then do: put stream outstream  "|" at beg  "Всего" format "X(9)" .             assign beg = beg + 10 .  end.
  if use-column[23] = yes then do: put stream outstream  "|" at beg  "Всего" format "X(14)" .            assign beg = beg + 15 .  end.
  if use-column[42] = yes then do: put stream outstream  "|" at beg  "Всего" format "X(14)" .            assign beg = beg + 15 .  end.
  if use-column[59] = yes then do: put stream outstream  "|" at beg  "Всего" format "X(14)" .            assign beg = beg + 15 .  end.
  if use-column[75] = yes then do: put stream outstream  "|" at beg  "Всего" format "X(14)" .            assign beg = beg + 15 .  end.
  if use-column[84] = yes then do: put stream outstream  "|" at beg  "Всего" format "X(9)" .             assign beg = beg + 10 .  end.
  if use-column[24] = yes then do: put stream outstream  "|" at beg  "Всего расход" format "X(14)" .     assign beg = beg + 15 .  end.
  if use-column[43] = yes then do: put stream outstream  "|" at beg  "Всего расход-" format "X(14)" .    assign beg = beg + 15 .  end.
  if use-column[60] = yes then do: put stream outstream  "|" at beg  "Всего расход-" format "X(14)" .    assign beg = beg + 15 .  end.
  if use-column[76] = yes then do: put stream outstream  "|" at beg  "Всего расход" format "X(14)" .     assign beg = beg + 15 .  end.
  if use-column[85] = yes then do: put stream outstream  "|" at beg  "Всего " format "X(9)" .            assign beg = beg + 10 .  end.
  if use-column[25] = yes then do: put stream outstream  "|" at beg  "Инвентаризация" format "X(14)" .   assign beg = beg + 15 .  end.
  if use-column[44] = yes then do: put stream outstream  "|" at beg  "Инвентаризация" format "X(14)" .   assign beg = beg + 15 .  end.
  if use-column[61] = yes then do: put stream outstream  "|" at beg  "Инвентаризация" format "X(14)" .   assign beg = beg + 15 .  end.
  if use-column[26] = yes then do: put stream outstream  "|" at beg  "Списание" format "X(14)" .         assign beg = beg + 15 .  end.
  if use-column[45] = yes then do: put stream outstream  "|" at beg  "Списание" format "X(14)" .         assign beg = beg + 15 .  end.
  if use-column[62] = yes then do: put stream outstream  "|" at beg  "Списание" format "X(14)" .         assign beg = beg + 15 .  end.
  if use-column[27] = yes then do: put stream outstream  "|" at beg  "Приход" format "X(14)" .           assign beg = beg + 15 .  end.
  if use-column[46] = yes then do: put stream outstream  "|" at beg  "Приход" format "X(14)" .           assign beg = beg + 15 .  end.
  if use-column[63] = yes then do: put stream outstream  "|" at beg  "Приход" format "X(14)" .           assign beg = beg + 15 .  end.
  if use-column[28] = yes then do: put stream outstream  "|" at beg  "Расход" format "X(14)" .           assign beg = beg + 15 .  end.
  if use-column[47] = yes then do: put stream outstream  "|" at beg  "Расход" format "X(14)" .           assign beg = beg + 15 .  end.
  if use-column[64] = yes then do: put stream outstream  "|" at beg  "Расход" format "X(14)" .           assign beg = beg + 15 .  end.
  if use-column[29] = yes then do: put stream outstream  "|" at beg  "Возврат" format "X(14)" .          assign beg = beg + 15 .  end.
  if use-column[48] = yes then do: put stream outstream  "|" at beg  "Возврат" format "X(14)" .          assign beg = beg + 15 .  end.
  if use-column[65] = yes then do: put stream outstream  "|" at beg  "Возврат" format "X(14)" .     assign beg = beg + 15 . end.
  if use-column[30] = yes then do: put stream outstream  "|" at beg  "Приход" format "X(14)" .      assign beg = beg + 15 .  end.
  if use-column[49] = yes then do: put stream outstream  "|" at beg  "Приход" format "X(14)" .      assign beg = beg + 15 . end.
  if use-column[66] = yes then do: put stream outstream  "|" at beg  "Приход" format "X(14)" .      assign beg = beg + 15 . end.
  if use-column[86] = yes then do: put stream outstream  "|" at beg  "Списание" format "X(14)" .    assign beg = beg + 15 . end.
  if use-column[87] = yes then do: put stream outstream  "|" at beg  "Списание" format "X(14)" .    assign beg = beg + 15 . end.
  if use-column[88] = yes then do: put stream outstream  "|" at beg  "Списание" format "X(14)" .    assign beg = beg + 15 . end.
  if use-column[67] = yes then do: put stream outstream  "|" at beg  "Переоценка" format "X(14)" .  assign  beg = beg + 15 . end.
  if use-column[13] = yes then do: put stream outstream  "|" at beg  "Остаток" format "X(14)" .     assign beg = beg + 15 . end.
  if use-column[32] = yes then do: put stream outstream  "|" at beg  "Остаток на" format "X(14)" .  assign beg = beg + 15 . end.
  if use-column[51] = yes then do: put stream outstream  "|" at beg  "Остаток на" format "X(14)" .  assign beg = beg + 15 . end.
  if use-column[10] = yes then do: put stream outstream  "|" at beg  "Эффективность" format "X(14)" . assign  beg = beg + 15 . end.
  if use-column[11] = yes then do: put stream outstream  "|" at beg  "Факт-ий" format "X(9)" .     assign  beg = beg + 10 . end.
  if RADIO-AltObj > 1 then do:     put stream outstream  "|" at beg  "Кол-во на" format "X(14)" .   assign beg = beg + 15 . end.

  assign  beg = 1 .  /* 2 строка заголовка */
  if use-column[1] = yes then   assign  beg = beg + 14  .
  if use-column[2] = yes then   assign  beg = beg + 17 .
  if use-column[3] = yes then   assign  beg = beg + 41 .
  if use-column[4] = yes then do:  put stream outstream  "|" at beg  "изм" format "X(3)" .  assign  beg = beg + 5 .  end.
  if use-column[5] = yes then  assign beg = beg + 15 .
  if use-column[6] = yes then  assign beg = beg + 15 .
  if use-column[7] = yes then do:  put stream outstream  "|" at beg  " на конец" format "X(14)" .  assign beg = beg + 15 . end.
  if use-column[8] = yes then do:  put stream outstream  "|" at beg  " послед." format "X(10)" .   assign  beg = beg + 11 .  end.
  if use-column[9] = yes then do:  put stream outstream  "|" at beg  " послед." format "X(10)" .   assign  beg = beg + 11 .  end.
  if use-column[12] = yes then do: put stream outstream  "|" at beg  " на начало" format "X(14)" . assign  beg = beg + 15 .  end.
  if use-column[31] = yes then do: put stream outstream  "|" at beg  "начало (сумма" format "X(14)" .   assign  beg = beg + 15 .  end.
  if use-column[50] = yes then do: put stream outstream  "|" at beg  "начало (сумма" format "X(14)" .   assign  beg = beg + 15 .  end.
  if use-column[14] = yes then do: put stream outstream  "|" at beg  " внешний" format "X(14)" .        assign  beg = beg + 15 .  end.
  if use-column[33] = yes then do: put stream outstream  "|" at beg  "внешний (сумма" format "X(14)" .  assign  beg = beg + 15 .  end.
  if use-column[15] = yes then do: put stream outstream  "|" at beg  "поставщику" format "X(14)" .      assign  beg = beg + 15 .  end.
  if use-column[34] = yes then do: put stream outstream  "|" at beg  "пост-ку (сумма" format "X(14)" .  assign  beg = beg + 15 .  end.
  if use-column[16] = yes then do: put stream outstream  "|" at beg  "внешний" format "X(14)" .         assign  beg = beg + 15 .  end.
  if use-column[35] = yes then do: put stream outstream  "|" at beg  "внешний (сумма" format "X(14)" .  assign  beg = beg + 15 .  end.
  if use-column[52] = yes then do: put stream outstream  "|" at beg  "внешний (сумма" format "X(14)" .  assign  beg = beg + 15 .  end.
  if use-column[68] = yes then do: put stream outstream  "|" at beg  "внешний" format "X(14)" .         assign  beg = beg + 15 .  end.
  if use-column[77] = yes then do: put stream outstream  "|" at beg  "внешний" format "X(9)" .          assign  beg = beg + 10 .  end.
  if use-column[17] = yes then do: put stream outstream  "|" at beg  "внешний" format "X(14)" .         assign  beg = beg + 15 .  end.
  if use-column[36] = yes then do: put stream outstream  "|" at beg  "внешний (сумма" format "X(14)" .  assign  beg = beg + 15 .  end.
  if use-column[53] = yes then do: put stream outstream  "|" at beg  "внешний (сумма" format "X(14)" .  assign  beg = beg + 15 .  end.
  if use-column[69] = yes then do: put stream outstream  "|" at beg  "внешний" format "X(14)" .         assign  beg = beg + 15 .  end.
  if use-column[78] = yes then do: put stream outstream  "|" at beg  "внешний" format "X(9)" .          assign  beg = beg + 10 .  end.
  if use-column[18] = yes then do: put stream outstream  "|" at beg  "Возврат" format "X(14)" .         assign  beg = beg + 15 .  end.
  if use-column[37] = yes then do: put stream outstream  "|" at beg  "Возврат (сумма" format "X(14)" .  assign  beg = beg + 15 .  end.
  if use-column[54] = yes then do: put stream outstream  "|" at beg  "Возврат (сумма" format "X(14)" .  assign  beg = beg + 15 .  end.
  if use-column[70] = yes then do: put stream outstream  "|" at beg  "Возврат-" format "X(14)" .    assign  beg = beg + 15 .  end.
  if use-column[79] = yes then do: put stream outstream  "|" at beg  "Возврат" format "X(9)" .      assign  beg = beg + 10 .  end.
  if use-column[19] = yes then do: put stream outstream  "|" at beg  "продажа" format "X(14)" .     assign  beg = beg + 15 .  end.
  if use-column[38] = yes then do: put stream outstream  "|" at beg  "продажа (сумма" format "X(14)" .   assign  beg = beg + 15 .  end.
  if use-column[55] = yes then do: put stream outstream  "|" at beg  "продажа (сумма" format "X(14)" .   assign  beg = beg + 15 .  end.
  if use-column[71] = yes then do: put stream outstream  "|" at beg  "продажа" format "X(14)" .    assign  beg = beg + 15    .  end.
  if use-column[80] = yes then do: put stream outstream  "|" at beg  "продажа" format "X(14)" .    assign  beg = beg + 10    .  end.
  if use-column[20] = yes then do: put stream outstream  "|" at beg  "возврат" format "X(14)" .    assign  beg = beg + 15    .  end.
  if use-column[39] = yes then do: put stream outstream  "|" at beg  "возврат (сумма" format "X(14)" .    assign  beg = beg + 15   .  end.
  if use-column[56] = yes then do: put stream outstream  "|" at beg  "возврат (сумма" format "X(14)" .    assign  beg = beg + 15   .  end.
  if use-column[72] = yes then do: put stream outstream  "|" at beg  "возврат" format "X(14)" .    assign  beg = beg + 15  .  end.
  if use-column[81] = yes then do: put stream outstream  "|" at beg  "возврат" format "X(9)" .     assign  beg = beg + 10  .  end.
  if use-column[21] = yes then do: put stream outstream  "|" at beg  "-возврат" format "X(14)" .   assign  beg = beg + 15  .  end.
  if use-column[40] = yes then do: put stream outstream  "|" at beg  "возврат (сумма" format "X(14)" .   assign  beg = beg + 15 .  end.
  if use-column[57] = yes then do: put stream outstream  "|" at beg  "возврат (сумма" format "X(14)" .   assign  beg = beg + 15 .  end.
  if use-column[73] = yes then do: put stream outstream  "|" at beg  "-возврат" format "X(14)" .    assign  beg = beg + 15 .  end.
  if use-column[82] = yes then do: put stream outstream  "|" at beg  "прод-возв" format "X(9)" .    assign  beg = beg + 10 .  end.
  if use-column[22] = yes then do: put stream outstream  "|" at beg  "расход" format "X(14)" .      assign  beg = beg + 15 .  end.
  if use-column[41] = yes then do: put stream outstream  "|" at beg  "расход (сумма" format "X(14)" .   assign  beg = beg + 15 . end.
  if use-column[58] = yes then do: put stream outstream  "|" at beg  "расход (сумма" format "X(14)" .   assign  beg = beg + 15 . end.
  if use-column[74] = yes then do: put stream outstream  "|" at beg  "расход" format "X(14)" .   assign  beg = beg + 15 . end.
  if use-column[83] = yes then do: put stream outstream  "|" at beg  "расход" format "X(9)" .    assign  beg = beg + 10 . end.
  if use-column[23] = yes then do: put stream outstream  "|" at beg  "возврат" format "X(14)" .  assign  beg = beg + 15 . end.
  if use-column[42] = yes then do: put stream outstream  "|" at beg  "возврат (сумма" format "X(14)" .  assign  beg = beg + 15 . end.
  if use-column[59] = yes then do: put stream outstream  "|" at beg  "возврат (сумма" format "X(14)" .  assign  beg = beg + 15 . end.
  if use-column[75] = yes then do: put stream outstream  "|" at beg  "возврат" format "X(14)" .   assign  beg = beg + 15 . end.
  if use-column[84] = yes then do: put stream outstream  "|" at beg  "возврат" format "X(9)" .    assign  beg = beg + 10 . end.
  if use-column[24] = yes then do: put stream outstream  "|" at beg  "-возврат" format "X(14)" .  assign  beg = beg + 15 . end.
  if use-column[43] = yes then do: put stream outstream  "|" at beg  "возврат (сумма" format "X(14)" .  assign  beg = beg + 15  .  end.
  if use-column[60] = yes then do: put stream outstream  "|" at beg  "возврат (сумма" format "X(14)" .  assign  beg = beg + 15  .  end.
  if use-column[76] = yes then do: put stream outstream  "|" at beg  "-возврат" format "X(14)" .   assign  beg = beg + 15  .  end.
  if use-column[85] = yes then do: put stream outstream  "|" at beg  "расх-возв" format "X(9)" .   assign  beg = beg + 10  .  end.
  if use-column[25] = yes then do: put stream outstream  "|" at beg  "(кол-во)" format "X(14)" .  assign  beg = beg + 15 .  end.
  if use-column[44] = yes then do: put stream outstream  "|" at beg  "(сумма учет." format "X(14)" . assign  beg = beg + 15 .  end.
  if use-column[61] = yes then do: put stream outstream  "|" at beg  "(сумма прод." format "X(14)" . assign  beg = beg + 15 .  end.
  if use-column[26] = yes then do: put stream outstream  "|" at beg  " (кол-во)" format "X(14)" .  assign beg = beg + 15 .  end.
  if use-column[45] = yes then do: put stream outstream  "|" at beg  "(сумма учет." format "X(14)" .  assign  beg = beg + 15  .  end.
  if use-column[62] = yes then do: put stream outstream  "|" at beg  "(сумма прод." format "X(14)" .  assign  beg = beg + 15  .  end.
  if use-column[27] = yes then do: put stream outstream  "|" at beg  "перемещение" format "X(14)" .   assign  beg = beg + 15  .  end.
  if use-column[46] = yes then do: put stream outstream  "|" at beg  "перемещение" format "X(14)" .   assign  beg = beg + 15  .  end.
  if use-column[63] = yes then do: put stream outstream  "|" at beg  "перемещение" format "X(14)" .   assign  beg = beg + 15  .  end.
  if use-column[28] = yes then do: put stream outstream  "|" at beg  "перемещение" format "X(14)" .   assign  beg = beg + 15  .  end.
  if use-column[47] = yes then do: put stream outstream  "|" at beg  "перемещение" format "X(14)" .   assign  beg = beg + 15  .  end.
  if use-column[64] = yes then do: put stream outstream  "|" at beg  "перемещение" format "X(14)" . assign beg = beg + 15 .  end.
  if use-column[29] = yes then do: put stream outstream  "|" at beg  "перемещение" format "X(14)" . assign beg = beg + 15 .  end.
  if use-column[48] = yes then do: put stream outstream  "|" at beg  "перемещение" format "X(14)" . assign beg = beg + 15 .  end.
  if use-column[65] = yes then do: put stream outstream  "|" at beg  "перемещение" format "X(14)" . assign beg = beg + 15 .  end.
  if use-column[30] = yes then do: put stream outstream  "|" at beg  "производство" format "X(14)" . assign beg = beg + 15 . end.
  if use-column[49] = yes then do: put stream outstream  "|" at beg  "производство" format "X(14)" . assign beg = beg + 15 . end.
  if use-column[66] = yes then do: put stream outstream  "|" at beg  "производство" format "X(14)" . assign beg = beg + 15 . end.
  if use-column[86] = yes then do: put stream outstream  "|" at beg  "производство" format "X(14)" . assign beg = beg + 15 . end.
  if use-column[87] = yes then do: put stream outstream  "|" at beg  "производство" format "X(14)" . assign beg = beg + 15 . end.
  if use-column[88] = yes then do: put stream outstream  "|" at beg  "производство" format "X(14)" . assign beg = beg + 15 . end.
  if use-column[67] = yes then  assign  beg = beg + 15 .
  if use-column[13] = yes then do: put stream outstream  "|" at beg  "на конец" format "X(14)" . assign beg = beg + 15 . end.
  if use-column[32] = yes then do: put stream outstream  "|" at beg  "конец (сумма" format "X(14)" . assign beg = beg + 15 . end.
  if use-column[51] = yes then do: put stream outstream  "|" at beg  "конец (сумма" format "X(14)" . assign beg = beg + 15 . end.
  if use-column[10] = yes then  assign  beg = beg + 15 .
  if use-column[11] = yes then do: put stream outstream  "|" at beg  "% наценки" format "X(9)" .  assign beg = beg + 10 .  end.
  if RADIO-AltObj > 1 then do:     put stream outstream  "|" at beg  "альтерн." format "X(14)" .   assign beg = beg + 15 .  end.


  assign  beg = 1 .  /* 3 строка заголовка */
  if use-column[1] = yes then   assign  beg = beg + 14  .
  if use-column[2] = yes then   assign  beg = beg + 17 .
  if use-column[3] = yes then   assign  beg = beg + 41 .
  if use-column[4] = yes then   assign  beg = beg + 5 .
  if use-column[5] = yes then   assign beg = beg + 15 .
  if use-column[6] = yes then   assign beg = beg + 15 .
  if use-column[7] = yes then do:  put stream outstream  "|" at beg  " периода" format "X(14)" .    assign  beg = beg + 15 .  end.
  if use-column[8] = yes then do:  put stream outstream  "|" at beg  "переоценки" format "X(10)" .  assign  beg = beg + 11 .  end.
  if use-column[9] = yes then do:  put stream outstream  "|" at beg  "переоценки" format "X(10)" .  assign  beg = beg + 11 .  end.
  if use-column[12] = yes then do: put stream outstream  "|" at beg  " (кол-во)" format "X(14)" .   assign  beg = beg + 15 .  end.
  if use-column[31] = yes then do: put stream outstream  "|" at beg  "учет. цен)" format "X(14)" .  assign  beg = beg + 15 .  end.
  if use-column[50] = yes then do: put stream outstream  "|" at beg  "прод. цен)" format "X(14)" .  assign  beg = beg + 15 .  end.
  if use-column[14] = yes then do: put stream outstream  "|" at beg  " (кол-во)" format "X(14)" .   assign  beg = beg + 15 .  end.
  if use-column[33] = yes then do: put stream outstream  "|" at beg  "учет. цен)" format "X(14)" .  assign  beg = beg + 15 .  end.
  if use-column[15] = yes then do: put stream outstream  "|" at beg  " (кол-во)" format "X(14)" .   assign  beg = beg + 15 .  end.
  if use-column[34] = yes then do: put stream outstream  "|" at beg  "учет. цен)" format "X(14)" .  assign  beg = beg + 15 .  end.
  if use-column[16] = yes then do: put stream outstream  "|" at beg  " (кол-во)" format "X(14)" .   assign  beg = beg + 15 .  end.
  if use-column[35] = yes then do: put stream outstream  "|" at beg  "учет. цен)" format "X(14)" .  assign  beg = beg + 15 .  end.
  if use-column[52] = yes then do: put stream outstream  "|" at beg  "прод. цен)" format "X(14)" .  assign  beg = beg + 15 .  end.
  if use-column[68] = yes then do: put stream outstream  "|" at beg  "(скидка)" format "X(14)" .    assign  beg = beg + 15 .  end.
  if use-column[77] = yes then do: put stream outstream  "|" at beg  "(% скид.)" format "X(9)" .    assign  beg = beg + 10 .  end.
  if use-column[17] = yes then do: put stream outstream  "|" at beg  " (кол-во)" format "X(14)" .   assign  beg = beg + 15 .  end.
  if use-column[36] = yes then do: put stream outstream  "|" at beg  "учет. цен)" format "X(14)" .  assign  beg = beg + 15 .  end.
  if use-column[53] = yes then do: put stream outstream  "|" at beg  "прод. цен)" format "X(14)" .  assign  beg = beg + 15 .  end.
  if use-column[69] = yes then do: put stream outstream  "|" at beg  "(скидка)" format "X(14)" .    assign  beg = beg + 15 .  end.
  if use-column[78] = yes then do: put stream outstream  "|" at beg  "(% скид.)" format "X(9)" .    assign  beg = beg + 10 .  end.
  if use-column[18] = yes then do: put stream outstream  "|" at beg  " (кол-во)" format "X(14)" .   assign  beg = beg + 15 .  end.
  if use-column[37] = yes then do: put stream outstream  "|" at beg  "учет. цен)" format "X(14)" .  assign  beg = beg + 15 .  end.
  if use-column[54] = yes then do: put stream outstream  "|" at beg  "прод. цен)" format "X(14)" .  assign  beg = beg + 15 .  end.
  if use-column[70] = yes then do: put stream outstream  "|" at beg  "(скидка)" format "X(14)" .    assign  beg = beg + 15 .  end.
  if use-column[79] = yes then do: put stream outstream  "|" at beg  "(% скид.)" format "X(9)" .    assign  beg = beg + 10 .  end.
  if use-column[19] = yes then do: put stream outstream  "|" at beg  " (кол-во)" format "X(14)" .   assign  beg = beg + 15 .  end.
  if use-column[38] = yes then do: put stream outstream  "|" at beg  "учет. цен)" format "X(14)" .  assign  beg = beg + 15 .  end.
  if use-column[55] = yes then do: put stream outstream  "|" at beg  "прод. цен)" format "X(14)" .  assign  beg = beg + 15 .  end.
  if use-column[71] = yes then do: put stream outstream  "|" at beg  "(скидка)" format "X(14)" .    assign  beg = beg + 15 .  end.
  if use-column[80] = yes then do: put stream outstream  "|" at beg  "(% скид.)" format "X(9)" .    assign  beg = beg + 10 .  end.
  if use-column[20] = yes then do: put stream outstream  "|" at beg  " (кол-во)" format "X(14)" .   assign  beg = beg + 15 .  end.
  if use-column[39] = yes then do: put stream outstream  "|" at beg  "учет. цен)" format "X(14)" .  assign  beg = beg + 15 .  end.
  if use-column[56] = yes then do: put stream outstream  "|" at beg  "прод. цен)" format "X(14)" .  assign  beg = beg + 15 .  end.
  if use-column[72] = yes then do: put stream outstream  "|" at beg  "(скидка)" format "X(14)" .    assign  beg = beg + 15 .  end.
  if use-column[81] = yes then do: put stream outstream  "|" at beg  "(% скид.)" format "X(9)" .    assign  beg = beg + 10 .  end.
  if use-column[21] = yes then do: put stream outstream  "|" at beg  " (кол-во)" format "X(14)" .   assign  beg = beg + 15 .  end.
  if use-column[40] = yes then do: put stream outstream  "|" at beg  "учет. цен)" format "X(14)" .  assign  beg = beg + 15 .  end.
  if use-column[57] = yes then do: put stream outstream  "|" at beg  "прод. цен)" format "X(14)" .  assign  beg = beg + 15 .  end.
  if use-column[73] = yes then do: put stream outstream  "|" at beg  "-скидка" format "X(14)" .    assign  beg = beg + 15 .  end.
  if use-column[82] = yes then do: put stream outstream  "|" at beg  "(% скид.)" format "X(9)" .    assign  beg = beg + 10 .  end.
  if use-column[22] = yes then do: put stream outstream  "|" at beg  " (кол-во)" format "X(14)" .   assign  beg = beg + 15 .  end.
  if use-column[41] = yes then do: put stream outstream  "|" at beg  "учет. цен)" format "X(14)" .  assign  beg = beg + 15 .  end.
  if use-column[58] = yes then do: put stream outstream  "|" at beg  "прод. цен)" format "X(14)" .  assign  beg = beg + 15 .  end.
  if use-column[74] = yes then do: put stream outstream  "|" at beg  "(скидка)" format "X(14)" .    assign  beg = beg + 15 .  end.
  if use-column[83] = yes then do: put stream outstream  "|" at beg  "(% скид.)" format "X(9)" .    assign  beg = beg + 10 .  end.
  if use-column[23] = yes then do: put stream outstream  "|" at beg  " (кол-во)" format "X(14)" .   assign  beg = beg + 15 .  end.
  if use-column[42] = yes then do: put stream outstream  "|" at beg  "учет. цен)" format "X(14)" .  assign  beg = beg + 15 .  end.
  if use-column[59] = yes then do: put stream outstream  "|" at beg  "прод. цен)" format "X(14)" .  assign  beg = beg + 15 .  end.
  if use-column[75] = yes then do: put stream outstream  "|" at beg  "(скидка)" format "X(14)" .    assign  beg = beg + 15 .  end.
  if use-column[84] = yes then do: put stream outstream  "|" at beg  "(% скид.)" format "X(9)" .    assign  beg = beg + 10 .  end.
  if use-column[24] = yes then do: put stream outstream  "|" at beg  " (кол-во)" format "X(14)" .   assign  beg = beg + 15 .  end.
  if use-column[43] = yes then do: put stream outstream  "|" at beg  "учет. цен)" format "X(14)" .  assign  beg = beg + 15 .  end.
  if use-column[60] = yes then do: put stream outstream  "|" at beg  "прод. цен)" format "X(14)" .  assign  beg = beg + 15 .  end.
  if use-column[76] = yes then do: put stream outstream  "|" at beg  "-скидка" format "X(14)" .     assign  beg = beg + 15 .  end.
  if use-column[85] = yes then do: put stream outstream  "|" at beg  "(% скид.)" format "X(9)" .    assign  beg = beg + 10 .  end.
  if use-column[25] = yes then do: put stream outstream  "|" at beg  "(кол-во)" format "X(14)" .    assign  beg = beg + 15 .  end.
  if use-column[44] = yes then do: put stream outstream  "|" at beg  " цен)" format "X(14)" .       assign  beg = beg + 15 .  end.
  if use-column[61] = yes then do: put stream outstream  "|" at beg  " цен)" format "X(14)" .       assign  beg = beg + 15 .  end.
  if use-column[26] = yes then do: put stream outstream  "|" at beg  " (кол-во)" format "X(14)" .  assign beg = beg + 15 .  end.
  if use-column[45] = yes then do: put stream outstream  "|" at beg  " цен)" format "X(14)" .       assign  beg = beg + 15 .  end.
  if use-column[62] = yes then do: put stream outstream  "|" at beg  " цен)" format "X(14)" .       assign  beg = beg + 15 .  end.
  if use-column[27] = yes then do: put stream outstream  "|" at beg  " (кол-во)" format "X(14)" .   assign  beg = beg + 15 . end.
  if use-column[46] = yes then do: put stream outstream  "|" at beg  "(сумма учет. цен)" format "X(14)" .  assign  beg = beg + 15 . end.
  if use-column[63] = yes then do: put stream outstream  "|" at beg  "(сумма прод. цен)" format "X(14)" .  assign  beg = beg + 15 . end.
  if use-column[28] = yes then do: put stream outstream  "|" at beg  " (кол-во)" format "X(14)" .   assign  beg = beg + 15 . end.
  if use-column[47] = yes then do: put stream outstream  "|" at beg  "(сумма учет. цен)" format "X(14)" .  assign  beg = beg + 15 . end.
  if use-column[64] = yes then do: put stream outstream  "|" at beg  "(сумма прод. цен)" format "X(14)" .  assign  beg = beg + 15 . end.
  if use-column[29] = yes then do: put stream outstream  "|" at beg  " (кол-во)" format "X(14)" .   assign  beg = beg + 15 . end.
  if use-column[48] = yes then do: put stream outstream  "|" at beg  "(сумма учет. цен)" format "X(14)" .  assign  beg = beg + 15 . end.
  if use-column[65] = yes then do: put stream outstream  "|" at beg  "(сумма прод. цен)" format "X(14)" .  assign  beg = beg + 15 . end.
  if use-column[30] = yes then do: put stream outstream  "|" at beg  " (кол-во)" format "X(14)" .   assign  beg = beg + 15 . end.
  if use-column[49] = yes then do: put stream outstream  "|" at beg  "(сумма учет. цен)" format "X(14)" .  assign  beg = beg + 15 . end.
  if use-column[66] = yes then do: put stream outstream  "|" at beg  "(сумма прод. цен)" format "X(14)" .  assign  beg = beg + 15 . end.
  if use-column[86] = yes then do: put stream outstream  "|" at beg  " (кол-во)" format "X(14)" .   assign  beg = beg + 15 . end.
  if use-column[87] = yes then do: put stream outstream  "|" at beg  "(сумма учет. цен)" format "X(14)" .  assign  beg = beg + 15 . end.
  if use-column[88] = yes then do: put stream outstream  "|" at beg  "(сумма прод. цен)" format "X(14)" .  assign  beg = beg + 15 . end.
  if use-column[67] = yes then  assign  beg = beg + 15 .
  if use-column[13] = yes then do: put stream outstream  "|" at beg  "(кол-во)" format "X(14)" .   assign beg = beg + 15 . end.
  if use-column[32] = yes then do: put stream outstream  "|" at beg  "учет. цен)" format "X(14)" . assign beg = beg + 15 . end.
  if use-column[51] = yes then do: put stream outstream  "|" at beg  "прод. цен)" format "X(14)" . assign beg = beg + 15 . end.
  if use-column[10] = yes then  assign  beg = beg + 15 .
  if use-column[11] = yes then do: put stream outstream  "|" at beg  "" format "X(9)" .  assign beg = beg + 10 .  end.
  if RADIO-AltObj > 1 then do:     put stream outstream  "|" at beg  "объектах" format "X(14)" .   assign beg = beg + 15 .  end.

  put stream outstream    "|"  skip  Line format frmt skip .

end.

/* *********************************************************************** */
FUNCTION format-excel-text-macr RETURNS CHAR ( INPUT Start-Text AS CHAR ) :
def var  i    AS INT NO-UNDO.
def var  ch   AS CHAR NO-UNDO.
def var  N    AS INT NO-UNDO.
def var  iPos AS INT NO-UNDO.

  N = NUM-ENTRIES(TRIM(Start-Text), CHR(10)) - 1 .
  DO i = 1 TO N :
    iPos = INDEX( Start-Text, CHR(10)).
    IF iPos > 0 THEN
      SUBSTRing( Start-Text, iPos , 1 ) = ' '.
  END.

  N = NUM-ENTRIES(TRIM(Start-Text), CHR(13)) - 1 .
  DO i = 1 TO N :
    iPos = INDEX( Start-Text, CHR(13)).
    IF iPos > 0 THEN
      SUBSTRing( Start-Text, iPos, 1 ) = ' '.
  END.

  IF INDEX( Start-Text, '"' ) = 0 THEN
    Start-Text =  '"'   + TRIM( Start-Text) + '"'   .
    ELSE DO:
      N = NUM-ENTRIES(TRIM(Start-Text), '"') - 1.
      DO i = 1 TO N :
        ch = ch + ENTRY(i,TRIM(Start-Text), '"' ) + '""'.
      END.
      ch = ch + ENTRY(NUM-ENTRIES(TRIM(Start-Text), '"'),TRIM(Start-Text), '"' ).
      Start-Text = '"'  + ch  + '"' .
    END.

  N = NUM-ENTRIES(TRIM(Start-Text), CHR(10)) - 1 .
  DO i = 1 TO N :
    iPos = INDEX( Start-Text, CHR(10)).
    IF iPos > 0 THEN
      SUBSTRing( Start-Text, iPos , 1 ) = ' '.
  END.


    if NUM-ENTRIES(TRIM(Start-Text), CHR(10)) > 1 then  message NUM-ENTRIES(TRIM(Start-Text), CHR(10)) Start-Text.
  RETURN Start-Text.
END.




procedure macr_excel_char :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val as character no-undo .
 define input parameter  p-row as integer no-undo .
 define input parameter  p-col as integer no-undo .

      put  stream macr_excel unformatted
        substitute('formula(&3,"r&1c&2")', p-row , p-col , format-excel-text-macr ( p-val) ) skip  .

 end. /* do */
end procedure. /* macr_exel_char */



procedure macr_excel_sum :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val as decimal   no-undo .
 define input parameter  p-row as integer   no-undo .
 define input parameter  p-col as integer   no-undo .
 define input parameter  p-typ as integer   no-undo .

 if p-val = ? then assign p-val = 0 .
 define variable ss as character no-undo .
 assign ss = string( Round( p-val, p-typ) ) .
 put  stream macr_excel unformatted substitute('formula(&3,"r&1c&2")', p-row , p-col , ss ) skip  .
 end. /* do */
END procedure.

procedure macr_cell_format :
 do
 on error undo, return error return-value
 :
 define input parameter  p-size   as integer   no-undo .
 define input parameter  p-bold   as logical   no-undo .
 define input parameter  p-italic as logical   no-undo .
 define input parameter  p-color  as integer   no-undo .
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .
 define input parameter  p-row-2  as integer   no-undo .
 define input parameter  p-col-2  as integer   no-undo .

  if p-size = ? then p-size = 10 .
  if p-bold = ? then p-bold = false .
  if p-italic = ? then p-italic = false .
  if p-row-2 = ? then p-row-2 = p-row .
  if p-col-2 = ? then p-col-2 = p-col .
  put  stream macr_excel unformatted
   substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 ) skip .

  if p-color <> ? then do:
     put  stream macr_excel unformatted
       substitute('patterns(1,,&1,true)', p-color )  skip  .
  end.
  put  stream macr_excel unformatted
       substitute('format.font(,&1,&2,&3)' , p-size,
                                        string ( p-bold  , "true/false" ) ,
                                        string ( p-italic , "true/false" )
                                        ) skip .
 end. /* do */
end procedure. /* macr_pattern */


procedure macr_cell_bordur :
 do
 on error undo, return error return-value
 :
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .
 define input parameter  p-row-2  as integer   no-undo .
 define input parameter  p-col-2  as integer   no-undo .

  if p-row-2 = ? then p-row-2 = p-row .
  if p-col-2 = ? then p-col-2 = p-col .
  put  stream macr_excel unformatted
   substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 ) skip .

  put  stream macr_excel unformatted
       'BORDER( 2 , 2 , 2 , 2 , 2 , ,0,0,0,0,0) '  skip
       'ALIGNMENT(3 , , 4 , 4 ,)'   skip
       .
 end. /* do */
end procedure. /* macr_cell_bordur */

procedure macr_cell_size :
 do
 on error undo, return error return-value
 :
 define input parameter  p-w   as integer   no-undo . /* ширина*/
 define input parameter  p-l   as integer   no-undo . /* длина */
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .
 define input parameter  p-row-2  as integer   no-undo .
 define input parameter  p-col-2  as integer   no-undo .

  if p-row-2 = ? then p-row-2 = p-row .
  if p-col-2 = ? then p-col-2 = p-col .
  if p-w = ? then    p-w = 0 .
  if p-l = ? then    p-l = 0 .

 define variable s-w as character no-undo .
 define variable s-l as character no-undo .

 if p-w = 0 then s-w = "" .
            else s-w = string(p-w)  .
 if p-l = 0 then s-l = "" .
            else s-l = string(p-l)  .

put  stream macr_excel unformatted     substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 )  skip .
put  stream macr_excel unformatted     substitute('COLUMN.WIDTH(&1,,,,)' , s-w  )  skip.
put  stream macr_excel unformatted     'FORMAT.TEXT(2,2,0,,,,,)'  skip.

 end. /* do */

end procedure. /* macr_pattern */