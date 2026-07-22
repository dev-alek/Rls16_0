/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

для детал. оборотки

Автор: Чернова Светлана Александровна
Дата создания: 02/11/10
Author: Svetlana Chernova
Creation date: 02/11/10

Автор1: Кочетков Михаил Юрьевич
Дата создания: 03/22/06

*/
procedure PutColumnTitulExcel : /* заголовки для колонок экселя */
  do
  on error undo, return error return-value
  :
  assign
    v-col = 1
    v-row = 1
    line1 = ReportNAme
  .
  run macr_excel_char (line1, v-row, 4) .
  run macr_cell_format ( 11, yes, no, ?, v-row, 4, v-row, 4) .
  assign v-row = v-row + 1 .

  if length (str4 ) > 210 then assign str4 = substring (str4, 1, 210) + " ..." .
  run macr_excel_char (str4, v-row, v-col) .
  assign v-row = v-row + 1 .
  { rep/claslabl.i }
  if tog-lavel then do:
    run macr_excel_char ("Классификация : " + t-Class + "    Итоги с уровня  "  + String(var-lavel), v-row, v-col) .
  end.
  else do:
    run macr_excel_char ("Классификация : " + t-Class, v-row, v-col) .
  end.
  assign v-row = v-row + 1 .
  run macr_excel_char ("Выбор цен: " + (if x-SET_val_TYPE = 1 then "{&abbr_rublevye}" else "валютные" ), v-row, v-col) .
  assign v-row = v-row + 1 .
  run macr_excel_char (str1, v-row, v-col) .
  assign v-row = v-row + 1 .
  run macr_excel_char (str2, v-row, v-col) .
  assign v-row = v-row + 1 .

  if RADIO-AltObj > 2 then do:
    run macr_excel_char (str3, v-row, v-col) .
    assign v-row = v-row + 1 .
  end.

  assign v-col = 1 .

  if use-column[1] = yes then do:
    run macr_excel_char ("Код", v-row, v-col) .
    run  macr_cell_size (13,?, v-row, v-col,?,?).
    assign v-col = v-col + 1 .
  end.
  if use-column[2] = yes then do:
    run macr_excel_char ((if sys-key = "parts" then " Артикул/Серия" else " Артикул"), v-row, v-col) .
    run  macr_cell_size (16,?, v-row, v-col,?,?).
    assign v-col = v-col + 1 .
  end.
  if use-column[3] = yes then do:
    run macr_excel_char ((if sys-key = "parts" then " Название товара/Поставщика" else " Название товара"), v-row, v-col) .
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
    run macr_excel_char ("Касса (скидка)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[80] = yes then do:
    run macr_excel_char ("Касса (% скидки)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.

  if use-column[20] = yes then do:
    run macr_excel_char ("Касса возврат (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[39] = yes then do:
    run macr_excel_char ("Касса возврат (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[56] = yes then do:
    run macr_excel_char ("Касса возврат (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[72] = yes then do:
    run macr_excel_char ("Касса возврат (скидка)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[81] = yes then do:
    run macr_excel_char ("Касса возврат (% скидки)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.

  if use-column[21] = yes then do:
    run macr_excel_char ("Касса продажа-возврат (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[40] = yes then do:
    run macr_excel_char ("Касса продажа-возврат (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[57] = yes then do:
    run macr_excel_char ("Касса продажа-возврат (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[73] = yes then do:
    run macr_excel_char ("Касса продажа-возврат-скидка", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[82] = yes then do:
    run macr_excel_char ("Касса продажа-возврат (% скидки)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.

  if use-column[22] = yes then do:
    run macr_excel_char ("Всего расход (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[41] = yes then do:
    run macr_excel_char ("Всего расход (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[58] = yes then do:
    run macr_excel_char ("Всего расход (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[74] = yes then do:
    run macr_excel_char ("Всего расход (скидка)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[83] = yes then do:
    run macr_excel_char ("Всего расход (% скидки)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.

  if use-column[23] = yes then do:
    run macr_excel_char ("Всего возврат (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[42] = yes then do:
    run macr_excel_char ("Всего возврат (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[59] = yes then do:
    run macr_excel_char ("Всего возврат (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[75] = yes then do:
    run macr_excel_char ("Всего возврат (скидка)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[84] = yes then do:
    run macr_excel_char ("Всего возврат (% скидки)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.

  if use-column[24] = yes then do:
    run macr_excel_char ("Всего расход-возврат (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[43] = yes then do:
    run macr_excel_char ("Всего расход-возврат (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[60] = yes then do:
    run macr_excel_char ("Всего расход-возврат (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[76] = yes then do:
    run macr_excel_char ("Всего расход-возврат-скидка", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[85] = yes then do:
    run macr_excel_char ("Всего расход-возврат (% скидки)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.

  if use-column[25] = yes then do:
    run macr_excel_char ("Инвентаризация (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[44] = yes then do:
    run macr_excel_char ("Инвентаризация (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[61] = yes then do:
    run macr_excel_char ("Инвентаризация (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.

  if use-column[26] = yes then do:
    run macr_excel_char ("Списание (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[45] = yes then do:
    run macr_excel_char ("Списание (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[62] = yes then do:
    run macr_excel_char ("Списание (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.

  if use-column[27] = yes then do:
    run macr_excel_char ("Приход перемещение (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[46] = yes then do:
    run macr_excel_char ("Приход перемещение (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[63] = yes then do:
    run macr_excel_char ("Приход перемещение (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.

  if use-column[28] = yes then do:
    run macr_excel_char ("Расход перемещение (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[47] = yes then do:
    run macr_excel_char ("Расход перемещение (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[64] = yes then do:
    run macr_excel_char ("Расход перемещение (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.

  if use-column[29] = yes then do:
    run macr_excel_char ("Возврат перемещение (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[48] = yes then do:
    run macr_excel_char ("Возврат перемещение (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[65] = yes then do:
    run macr_excel_char ("Возврат перемещение (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.

  if use-column[30] = yes then do:
    run macr_excel_char ("Приход производство (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[49] = yes then do:
    run macr_excel_char ("Приход производство (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[66] = yes then do:
    run macr_excel_char ("Приход производство (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.

  if use-column[86] = yes then do:
    run macr_excel_char ("Списание производство (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[87] = yes then do:
    run macr_excel_char ("Списание производство (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[88] = yes then do:
    run macr_excel_char ("Списание производство (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.

  if use-column[67] = yes then do:
    run macr_excel_char ("Переоценка", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.

  if use-column[13] = yes then do:
    run macr_excel_char ("Остаток на конец по партиям (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[32] = yes then do:
    run macr_excel_char ("Остаток на конец по партиям (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[51] = yes then do:
    run macr_excel_char ("Остаток на конец по партиям (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.

  if use-column[10] = yes then do:
    run macr_excel_char ("Эффективность", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[11] = yes then do:
    run macr_excel_char ("Фактический % наценки", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if RADIO-AltObj > 1 then do:
    run macr_excel_char ("Кол-во на альтерн. объектах", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.

  if use-column[89] = yes then do:
    run macr_excel_char ("Свободно (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[90] = yes then do:
    run macr_excel_char ("Свободно (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[91] = yes then do:
    run macr_excel_char ("Свободно  (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[92] = yes then do:
    run macr_excel_char ("Резерв (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[93] = yes then do:
    run macr_excel_char ("Резерв (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[94] = yes then do:
    run macr_excel_char ("Резерв  (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[95] = yes then do:
    run macr_excel_char ("Резерв (скидка)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[96] = yes then do:
    run macr_excel_char ("Резерв (% скидки)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
   if use-column[97] = yes then do: run macr_excel_char  ("Цена производителя без НДС"       , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[98] = yes then do: run macr_excel_char  ("Цена производителя с НДС"         , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[99] = yes then do: run macr_excel_char  ("НДС производителя, сумма"         , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[100] = yes then do: run macr_excel_char ("НДС производителя(%)"             , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[101] = yes then do: run macr_excel_char ("Цена поставщика без НДС"          , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[102] = yes then do: run macr_excel_char ("Цена поставщика с НДС"            , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[103] = yes then do: run macr_excel_char ("НДС поставщика (сумма)"           , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[104] = yes then do: run macr_excel_char ("НДС поставщика (%)"               , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[105] = yes then do: run macr_excel_char ("Размер оптовой надбавки (сумма)"  , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[106] = yes then do: run macr_excel_char ("Размер оптовой надбавки  (%)"     , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[107] = yes then do: run macr_excel_char ("Розничная цена с НДС"             , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[108] = yes then do: run macr_excel_char ("Розничная цена без НДС"           , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[109] = yes then do: run macr_excel_char ("Сумма НДС"                        , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[110] = yes then do: run macr_excel_char ("Ставка НДС (%)"                   , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[111] = yes then do: run macr_excel_char ("Размер розничной надбавки (сумма)", v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[112] = yes then do: run macr_excel_char ("Размер розничной надбавки (%)"    , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[113] = yes then do: run macr_excel_char ("Размер общей надбавки (сумма)"    , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[114] = yes then do: run macr_excel_char ("Размер общей надбавки (%)"        , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[115] = yes then do: run macr_excel_char ("Размер розничной надбавки (от цен с НДС) (сумма)", v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[116] = yes then do: run macr_excel_char ("Размер розничной надбавки (от цен с НДС) (%)"    , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[117] = yes then do: run macr_excel_char ("Размер общей надбавки (от цен с НДС) (сумма)"    , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[118] = yes then do: run macr_excel_char ("Размер общей надбавки (от цен с НДС) (%)"        , v-row, v-col) . assign v-col = v-col + 1 .  end.


  run macr_cell_bordur ( v-row, 1, v-row, v-col - 1) .
  run macr_cell_format ( 10, yes, no, 35, v-row, 1, v-row, v-col - 1) .
  run  macr_cell_size (12,?, v-row, ii,v-row, v-col - 1) .

  assign v-row = v-row + 1 .

  end.
end procedure. /* PutColumnTitulExcel */



procedure PrintTitul :
  define variable ss1 as character no-undo .
  PUT stream OutStream SPACE(30) ReportNAme format "X(100)" SKIP .

  assign  ss1 = 'X(' + string(length (ReportHeader)) + ')' .
  PUT stream OutStream ReportHeader format ss1 SKIP.

  assign
    str4 = "Выбранные объекты: " + str4
    ss1 = 'X(' + string(length (str4)) + ')'
  .
  PUT stream OutStream str4 format ss1 SKIP.
  if RADIO-AltObj > 2 then do:
    assign ss1 = 'X(' + string(length (str3)) + ')' .
    PUT stream OutStream str3 format ss1 SKIP.
  end.

  define variable frm-qnty as character no-undo .
  if sz-qnty = 3 then assign frm-qnty = "->>>>>>>>9.999" .
  else                       frm-qnty = "->>>>>>>>>>>>9" .
  assign
    ii  = 1
    beg = 1
  .

  if use-column[1] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = " Код"
      line-frm.titul1 = ""
      line-frm.titul2 = ""
      line-frm.frm    = ">>>>>>>>>>>>9"
      line-frm.frmt   = "X(6)"
      ii  = ii + 1
      beg = beg + 14
    .
  end.
  if use-column[2] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = if sys-key = "parts" then " Артикул/Серия" else " Артикул"
      line-frm.titul1 = ""
      line-frm.titul2 = ""
      line-frm.frm    = "X(16)"
      line-frm.frmt   = "X(16)"
      ii  = ii + 1
      beg = beg + 17
    .
  end.
  if use-column[3] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = if sys-key = "parts" then " Название товара/Поставщика" else " Название товара"
      line-frm.titul1 = ""
      line-frm.titul2 = ""
      line-frm.frm    = "X(40)"
      line-frm.frmt   = "X(40)"
      ii  = ii + 1
      beg = beg + 41
    .
  end.
  if use-column[4] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Ед."
      line-frm.titul1 = "изм"
      line-frm.titul2 = ""
      line-frm.frm    = "X(4)"
      line-frm.frmt   = "X(3)"
      ii  = ii + 1
      beg = beg + 5
    .
  end.
  if use-column[5] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = " Учетная цена"
      line-frm.titul1 = ""
      line-frm.titul2 = ""
      line-frm.frm    = ">>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[6] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = " Цена продажи"
      line-frm.titul1 = ""
      line-frm.titul2 = ""
      line-frm.frm    = ">>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.

  if use-column[7] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = " Наценка"
      line-frm.titul1 = " на конец"
      line-frm.titul2 = " периода"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[8] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = " Дата"
      line-frm.titul1 = " послед."
      line-frm.titul2 = "переоценки"
      line-frm.frm    = "99/99/9999"
      line-frm.frmt   = "X(10)"
      ii  = ii + 1
      beg = beg + 11
    .
  end.
  if use-column[9] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = " Номер"
      line-frm.titul1 = " послед."
      line-frm.titul2 = "переоценки"
      line-frm.frm    = "X(10)"
      line-frm.frmt   = "X(10)"
      ii  = ii + 1
      beg = beg + 11
    .
  end.

  if use-column[12] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = " Остаток"
      line-frm.titul1 = " на начало"
      line-frm.titul2 = " (кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[31] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Остаток на"
      line-frm.titul1 = "начало (сумма"
      line-frm.titul2 = "учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[50] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Остаток на"
      line-frm.titul1 = "начало (сумма"
      line-frm.titul2 = "прод. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.

  if use-column[14] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = " Приход"
      line-frm.titul1 = " внешний"
      line-frm.titul2 = " (кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[33] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = " Приход"
      line-frm.titul1 = "внешний (сумма"
      line-frm.titul2 = "учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.

  if use-column[15] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = " Возврат"
      line-frm.titul1 = "поставщику"
      line-frm.titul2 = " (кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[34] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = " Возврат"
      line-frm.titul1 = "пост-ку (сумма"
      line-frm.titul2 = "учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.

  if use-column[16] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = " Расход"
      line-frm.titul1 = "внешний"
      line-frm.titul2 = " (кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[35] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = " Расход"
      line-frm.titul1 = "внешний (сумма"
      line-frm.titul2 = "учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[52] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = " Расход"
      line-frm.titul1 = "внешний (сумма"
      line-frm.titul2 = "прод. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[68] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = " Расход"
      line-frm.titul1 = "внешний"
      line-frm.titul2 = "(скидка)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[77] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = " Расход"
      line-frm.titul1 = "внешний"
      line-frm.titul2 = "(% скидки)"
      line-frm.frm    = "->,>>9.99"
      line-frm.frmt   = "X(9)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.

  if use-column[17] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Возврат"
      line-frm.titul1 = "внешний"
      line-frm.titul2 = " (кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[36] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = " Возврат"
      line-frm.titul1 = "внешний (сумма"
      line-frm.titul2 = "учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[53] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = " Возврат"
      line-frm.titul1 = "внешний (сумма"
      line-frm.titul2 = "прод. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[69] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Возврат"
      line-frm.titul1 = "внешний"
      line-frm.titul2 = "(скидка)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[78] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Возврат"
      line-frm.titul1 = "внешний"
      line-frm.titul2 = "(% скидки)"
      line-frm.frm    = "->,>>9.99"
      line-frm.frmt   = "X(9)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.

  if use-column[18] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Расход-"
      line-frm.titul1 = "Возврат"
      line-frm.titul2 = " (кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[37] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Расход-"
      line-frm.titul1 = "Возврат (сумма"
      line-frm.titul2 = "учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[54] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Расход-"
      line-frm.titul1 = "Возврат (сумма"
      line-frm.titul2 = " прод. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[70] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Расход-"
      line-frm.titul1 = "Возврат-"
      line-frm.titul2 = "скидка"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[79] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Расход-"
      line-frm.titul1 = "Возврат"
      line-frm.titul2 = "(% скидки)"
      line-frm.frm    = "->,>>9.99"
      line-frm.frmt   = "X(9)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.

  if use-column[19] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Касса"
      line-frm.titul1 = "продажа"
      line-frm.titul2 = " (кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[38] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Касса"
      line-frm.titul1 = "продажа (сумма"
      line-frm.titul2 = "учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[55] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Касса"
      line-frm.titul1 = "продажа (сумма"
      line-frm.titul2 = "прод. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[71] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Касса"
      line-frm.titul1 = "продажа"
      line-frm.titul2 = "(скидка)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[80] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Касса"
      line-frm.titul1 = "продажа"
      line-frm.titul2 = "(% скидки)"
      line-frm.frm    = "->,>>9.99"
      line-frm.frmt   = "X(9)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.

  if use-column[20] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Касса"
      line-frm.titul1 = "возврат"
      line-frm.titul2 = " (кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[39] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Касса"
      line-frm.titul1 = "возврат (сумма"
      line-frm.titul2 = "учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[56] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Касса"
      line-frm.titul1 = "возврат (сумма"
      line-frm.titul2 = "прод. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[72] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Касса"
      line-frm.titul1 = "возврат"
      line-frm.titul2 = "(скидка)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[81] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Касса"
      line-frm.titul1 = "возврат"
      line-frm.titul2 = "(% скидки)"
      line-frm.frm    = "->,>>9.99"
      line-frm.frmt   = "X(9)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.

  if use-column[21] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Касса продажа"
      line-frm.titul1 = "-возврат"
      line-frm.titul2 = " (кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[40] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Касса продажа-"
      line-frm.titul1 = "возврат (сумма"
      line-frm.titul2 = "учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[57] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Касса продажа-"
      line-frm.titul1 = "возврат (сумма"
      line-frm.titul2 = "прод. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[73] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Касса продажа"
      line-frm.titul1 = "-возврат"
      line-frm.titul2 = "-скидка"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[82] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Касса продажа"
      line-frm.titul1 = "-возврат"
      line-frm.titul2 = "(% скидки)"
      line-frm.frm    = "->,>>9.99"
      line-frm.frmt   = "X(9)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.

  if use-column[22] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Всего"
      line-frm.titul1 = "расход"
      line-frm.titul2 = " (кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[41] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Всего"
      line-frm.titul1 = "расход (сумма"
      line-frm.titul2 = "учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[58] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Всего"
      line-frm.titul1 = "расход (сумма"
      line-frm.titul2 = "прод. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[74] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Всего"
      line-frm.titul1 = "расход"
      line-frm.titul2 = "(скидка)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[83] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Всего"
      line-frm.titul1 = "расход"
      line-frm.titul2 = "(% скидки)"
      line-frm.frm    = "->,>>9.99"
      line-frm.frmt   = "X(9)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.

  if use-column[23] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Всего"
      line-frm.titul1 = "возврат"
      line-frm.titul2 = " (кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[42] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Всего"
      line-frm.titul1 = "возврат (сумма"
      line-frm.titul2 = "учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[59] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Всего"
      line-frm.titul1 = "возврат (сумма"
      line-frm.titul2 = "прод. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[75] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Всего"
      line-frm.titul1 = "возврат"
      line-frm.titul2 = "(скидка)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[84] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Всего"
      line-frm.titul1 = "возврат"
      line-frm.titul2 = "(% скидки)"
      line-frm.frm    = "->,>>9.99"
      line-frm.frmt   = "X(9)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.

  if use-column[24] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Всего расход"
      line-frm.titul1 = "-возврат"
      line-frm.titul2 = " (кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[43] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Всего расход-"
      line-frm.titul1 = "возврат (сумма"
      line-frm.titul2 = "учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[60] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Всего расход-"
      line-frm.titul1 = "возврат (сумма"
      line-frm.titul2 = "прод. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[76] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Всего расход"
      line-frm.titul1 = "-возврат"
      line-frm.titul2 = "-скидка"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[85] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Всего расход"
      line-frm.titul1 = "-возврат"
      line-frm.titul2 = "(% скидки)"
      line-frm.frm    = "->,>>9.99"
      line-frm.frmt   = "X(9)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.

  if use-column[25] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Инвентаризация"
      line-frm.titul1 = "(кол-во)"
      line-frm.titul2 = ""
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[44] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Инвентаризация"
      line-frm.titul1 = "(сумма учет."
      line-frm.titul2 = " цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[61] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Инвентаризация"
      line-frm.titul1 = "(сумма прод."
      line-frm.titul2 = " цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.

  if use-column[26] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Списание"
      line-frm.titul1 = " (кол-во)"
      line-frm.titul2 = ""
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[45] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Списание"
      line-frm.titul1 = "(сумма учет."
      line-frm.titul2 = " цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[62] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Списание"
      line-frm.titul1 = "(сумма прод."
      line-frm.titul2 = " цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.

  if use-column[27] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Приход"
      line-frm.titul1 = "перемещение"
      line-frm.titul2 = " (кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[46] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Приход"
      line-frm.titul1 = "перемещение"
      line-frm.titul2 = "(сумма учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[63] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Приход"
      line-frm.titul1 = "перемещение"
      line-frm.titul2 = "(сумма прод. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.

  if use-column[28] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Расход"
      line-frm.titul1 = "перемещение"
      line-frm.titul2 = " (кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[47] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Расход"
      line-frm.titul1 = "перемещение"
      line-frm.titul2 = "(сумма учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[64] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Расход"
      line-frm.titul1 = "перемещение"
      line-frm.titul2 = "(сумма прод. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.

  if use-column[29] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Возврат"
      line-frm.titul1 = "перемещение"
      line-frm.titul2 = " (кол-во)"
      line-frm.frmt   = "X(14)"
      line-frm.frm    = frm-qnty
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[48] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Возврат"
      line-frm.titul1 = "перемещение"
      line-frm.titul2 = "(сумма учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[65] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Возврат"
      line-frm.titul1 = "перемещение"
      line-frm.titul2 = "(сумма прод. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.

  if use-column[30] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Приход"
      line-frm.titul1 = "производство"
      line-frm.titul2 = " (кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[49] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Приход"
      line-frm.titul1 = "производство"
      line-frm.titul2 = "(сумма учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[66] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Приход"
      line-frm.titul1 = "производство"
      line-frm.titul2 = "(сумма прод. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.

  if use-column[86] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Списание"
      line-frm.titul1 = "производство"
      line-frm.titul2 = " (кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[87] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Списание"
      line-frm.titul1 = "производство"
      line-frm.titul2 = "(сумма учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[88] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Списание"
      line-frm.titul1 = "производство"
      line-frm.titul2 = "(сумма прод. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.

  if use-column[67] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Переоценка"
      line-frm.titul1 = ""
      line-frm.titul2 = ""
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.

  if use-column[13] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Остаток на ко-"
      line-frm.titul1 = "нец по партиям"
      line-frm.titul2 = "(кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[32] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Остаток на ко-"
      line-frm.titul1 = "нец по партиям"
      line-frm.titul2 = "(сум. уч. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[51] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Остаток на ко-"
      line-frm.titul1 = "нец по партиям"
      line-frm.titul2 = "(сум.прод.цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.

  if use-column[10] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Эффективность"
      line-frm.titul1 = ""
      line-frm.titul2 = ""
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[11] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Фактический"
      line-frm.titul1 = "% наценки"
      line-frm.titul2 = ""
      line-frm.frm    = "->,>>9.99"
      line-frm.frmt   = "X(9)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if RADIO-AltObj > 1 then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Кол-во на"
      line-frm.titul1 = "альтерн."
      line-frm.titul2 = "объектах"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.

  if use-column[89] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Свободно"
      line-frm.titul1 = "на конец"
      line-frm.titul2 = "(кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[90] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Свободно на"
      line-frm.titul1 = "конец (сумма"
      line-frm.titul2 = "учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[91] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Свободно на"
      line-frm.titul1 = "конец (сумма"
      line-frm.titul2 = "прод. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[92] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Резерв"
      line-frm.titul1 = "на конец"
      line-frm.titul2 = "(кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[93] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Резерв на"
      line-frm.titul1 = "конец (сумма"
      line-frm.titul2 = "учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[94] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Резерв на"
      line-frm.titul1 = "конец (сумма"
      line-frm.titul2 = "прод. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[95] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Резерв"
      line-frm.titul1 = "(скидка)"
      line-frm.titul2 = ""
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[96] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Резерв"
      line-frm.titul1 = "(% скидки)"
      line-frm.titul2 = ""
      line-frm.frm    = "->,>>9.99"
      line-frm.frmt   = "X(9)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.


  if use-column[97] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Цена без НДС"
      line-frm.titul1 = "производителя"
      line-frm.titul2 = ""
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[98] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "%"
      line-frm.titul  = "Цена c НДС"
      line-frm.titul1 = "производителя"
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.

  if use-column[99] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "НДС"
      line-frm.titul1 = "произв"
      line-frm.titul2 = ""
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.

  if use-column[100] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "%"
      line-frm.titul1 = "НДС"
      line-frm.titul2 = "произв"
      line-frm.frm    = "->,>>9.99"
      line-frm.frmt   = "X(9)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[101] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Цена"
      line-frm.titul1 = "поставщика"
      line-frm.titul2 = "без НДС"
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"

      ii  = ii + 1
      beg = beg + 10
    .
  end.


  if use-column[102] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Цена"
      line-frm.titul1 = "поставщика"
      line-frm.titul2 = "с НДС "
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"

      ii  = ii + 1
      beg = beg + 10
    .
  end.


  if use-column[103] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "НДС"
      line-frm.titul1 = "поставщика"
      line-frm.titul2 = "(сумма) "
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"

      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[104] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "НДС "
      line-frm.titul1 = "поставщика "
      line-frm.titul2 = "(%) "
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"

      ii  = ii + 1
      beg = beg + 10
    .
  end.

  if use-column[105] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Размер оптовой"
      line-frm.titul1 = "надбавки"
      line-frm.titul2 = "(сумма) "
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"

      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[106] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Размер оптовой"
      line-frm.titul1 = "надбавки"
      line-frm.titul2 = "(%) "
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"

      ii  = ii + 1
      beg = beg + 10
    .
  end.

  if use-column[107] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Розничная "
      line-frm.titul1 = "цена партии"
      line-frm.titul2 = "с НДС"
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"

      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[108] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Розничная "
      line-frm.titul1 = "цена партии"
      line-frm.titul2 = "без НДС"
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"

      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[109] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Сумма"
      line-frm.titul1 = "НДС"
      line-frm.titul2 = " "
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"

      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[110] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Ставка"
      line-frm.titul1 = "НДС "
      line-frm.titul2 = "%"
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"

      ii  = ii + 1
      beg = beg + 10
    .
  end.

  if use-column[111] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Размер  "
      line-frm.titul1 = "розничной надбавки"
      line-frm.titul2 = "(сумма) "
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"

      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[112] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Размер  "
      line-frm.titul1 = "розничной надбавки"
      line-frm.titul2 = "(%) "
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"

      ii  = ii + 1
      beg = beg + 10
    .
  end.

  if use-column[113] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Размер "
      line-frm.titul1 = "общей надбавки"
      line-frm.titul2 = "(сумма) "
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"

      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[114] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Размер "
      line-frm.titul1 = "общей надбавки"
      line-frm.titul2 = "(сумма) "
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"

      ii  = ii + 1
      beg = beg + 10
    .
  end.

  if use-column[115] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Размер  "
      line-frm.titul1 = "розничной надбавки"
      line-frm.titul2 = "(с НДС) (сумма) "
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"

      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[116] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Размер  "
      line-frm.titul1 = "розничной надбавки"
      line-frm.titul2 = "(с НДС) (%) "
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"

      ii  = ii + 1
      beg = beg + 10
    .
  end.

  if use-column[117] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Размер "
      line-frm.titul1 = "общей надбавки"
      line-frm.titul2 = "(с НДС) (сумма) "
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"

      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[118] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Размер "
      line-frm.titul1 = "общей надбавки"
      line-frm.titul2 = "(с НДС) (сумма) "
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"

      ii  = ii + 1
      beg = beg + 10
    .
  end.

  assign
    frmt = "X(" + string(beg) + ')'
    Line = fill("-", beg).
  .
end.

/* $Workfile$   E n d */