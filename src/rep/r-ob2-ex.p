block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-ob2-ex.p $
$Archive: rep/r-ob2-ex.p $

Старая оборотка с признак - экспорт в файл для цума

Автор: Демин Алексей Сергеевич
Дата создания: 09/22/05
Author: Alexey Demin
Creation date: 09/22/05

*/

define input parameter  Tog-obj          as logical   no-undo .
define input parameter  RADIO-AltObj     as integer   no-undo .
define input parameter  is-prt           as logical   no-undo .
define output parameter StrTitul         as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-ob2-ex.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-ob2-ex.p $":U .
define variable vss-description as character no-undo init "Старая оборотка с признак - экспорт в файл для цума".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }

do
on error undo, return error
:

  assign StrTitul = "" .

  if tog-obj = true then do: /* раздельно по объектам */
    assign StrTitul = "тип объекта" + {&tabulation} + "код объекта" + {&tabulation} + "наименование объекта" + {&tabulation} .
  end.
  assign StrTitul = StrTitul + "группа" + {&tabulation}  + "тип произв." + {&tabulation} + "код произв." + {&tabulation} + "наименование произв." + {&tabulation} .

  if use-column[1]  = yes then assign StrTitul = StrTitul + "Код" + {&tabulation} .
  if use-column[2]  = yes then assign StrTitul = StrTitul + "Артикул" + {&tabulation} .
  if use-column[3]  = yes then assign StrTitul = StrTitul + "Название товара" + {&tabulation} .
  if is-prt then assign StrTitul = StrTitul + "признак" + {&tabulation} .
  if use-column[4]  = yes then assign StrTitul = StrTitul + "Ед. изм" + {&tabulation} .
  if use-column[5]  = yes then assign StrTitul = StrTitul + "Учетная цена" + {&tabulation} .
  if use-column[6]  = yes then assign StrTitul = StrTitul + "Цена продажи" + {&tabulation} .
  if use-column[7]  = yes then assign StrTitul = StrTitul + "Наценка на конец периода" + {&tabulation} .
  if use-column[8]  = yes then assign StrTitul = StrTitul + "Дата послед. переоцен."   + {&tabulation} .
  if use-column[9]  = yes then assign StrTitul = StrTitul + "Номер послед. переоцен."  + {&tabulation} .
  if use-column[12] = yes then assign StrTitul = StrTitul + "Остаток на начало (кол-во)" + {&tabulation} .
  if use-column[31] = yes then assign StrTitul = StrTitul + "Остаток на начало (сумма учет. цен)" + {&tabulation} .
  if use-column[50] = yes then assign StrTitul = StrTitul + "Остаток на начало (сумма прод. цен)" + {&tabulation} .
  if use-column[14] = yes then assign StrTitul = StrTitul + "Приход внешний (кол-во)" + {&tabulation} .
  if use-column[33] = yes then assign StrTitul = StrTitul + "Приход внешний (сумма учет. цен)" + {&tabulation} .
  if use-column[15] = yes then assign StrTitul = StrTitul + "Возврат поставщику (кол-во)" + {&tabulation} .
  if use-column[34] = yes then assign StrTitul = StrTitul + "Возврат поставщику (сумма учет. цен)" + {&tabulation} .
  if use-column[16] = yes then assign StrTitul = StrTitul + "Расход внешний (кол-во)" + {&tabulation} .
  if use-column[35] = yes then assign StrTitul = StrTitul + "Расход внешний (сумма учет. цен)" + {&tabulation} .
  if use-column[52] = yes then assign StrTitul = StrTitul + "Расход внешний (сумма прод. цен)"  + {&tabulation} .
  if use-column[68] = yes then assign StrTitul = StrTitul + "Расход внешний (скидка)"           + {&tabulation} .
  if use-column[77] = yes then assign StrTitul = StrTitul + "Расход внешний (% скидки)"         + {&tabulation} .
  if use-column[17] = yes then assign StrTitul = StrTitul + "Возврат внешний (кол-во)"          + {&tabulation} .
  if use-column[36] = yes then assign StrTitul = StrTitul + "Возврат внешний (сумма учет. цен)" + {&tabulation} .
  if use-column[53] = yes then assign StrTitul = StrTitul + "Возврат внешний (сумма прод. цен)" + {&tabulation} .
  if use-column[69] = yes then assign StrTitul = StrTitul + "Возврат внешний (скидка)"          + {&tabulation} .
  if use-column[78] = yes then assign StrTitul = StrTitul + "Возврат внешний (% скидки)"        + {&tabulation} .
  if use-column[18] = yes then assign StrTitul = StrTitul + "Расход-Возврат (кол-во)"           + {&tabulation} .
  if use-column[37] = yes then assign StrTitul = StrTitul + "Расход-Возврат (сумма учет. цен)"  + {&tabulation} .
  if use-column[54] = yes then assign StrTitul = StrTitul + "Расход-Возврат (сумма прод. цен)"  + {&tabulation} .
  if use-column[70] = yes then assign StrTitul = StrTitul + "Расход-Возврат-скидка"             + {&tabulation} .
  if use-column[79] = yes then assign StrTitul = StrTitul + "Расход-Возврат (% скидки)"         + {&tabulation} .
  if use-column[19] = yes then assign StrTitul = StrTitul + "Касса продажа (кол-во)"            + {&tabulation} .
  if use-column[38] = yes then assign StrTitul = StrTitul + "Касса (сумма учет. цен)"           + {&tabulation} .
  if use-column[55] = yes then assign StrTitul = StrTitul + "Касса (сумма прод. цен)"           + {&tabulation} .
  if use-column[71] = yes then assign StrTitul = StrTitul + "Касса (скидка)"                    + {&tabulation} .
  if use-column[80] = yes then assign StrTitul = StrTitul + "Касса (% скидки)"                  + {&tabulation} .
  if use-column[20] = yes then assign StrTitul = StrTitul + "Касса возврат (кол-во)"            + {&tabulation} .
  if use-column[39] = yes then assign StrTitul = StrTitul + "Касса возврат (сумма учет. цен)"             + {&tabulation} .
  if use-column[56] = yes then assign StrTitul = StrTitul + "Касса возврат (сумма прод. цен)"             + {&tabulation} .
  if use-column[72] = yes then assign StrTitul = StrTitul + "Касса возврат (скидка)"                      + {&tabulation} .
  if use-column[81] = yes then assign StrTitul = StrTitul + "Касса возврат (% скидки)"                    + {&tabulation} .
  if use-column[21] = yes then assign StrTitul = StrTitul + "Касса продажа-возврат (кол-во)"              + {&tabulation} .
  if use-column[40] = yes then assign StrTitul = StrTitul + "Касса продажа-возврат (сумма учет. цен)"     + {&tabulation} .
  if use-column[57] = yes then assign StrTitul = StrTitul + "Касса продажа-возврат (сумма прод. цен)"     + {&tabulation} .
  if use-column[73] = yes then assign StrTitul = StrTitul + "Касса продажа-возврат-скидка"                + {&tabulation} .
  if use-column[82] = yes then assign StrTitul = StrTitul + "Касса продажа-возврат (% скидки)"            + {&tabulation} .
  if use-column[22] = yes then assign StrTitul = StrTitul + "Всего расход (кол-во)"                       + {&tabulation} .
  if use-column[41] = yes then assign StrTitul = StrTitul + "Всего расход (сумма учет. цен)"              + {&tabulation} .
  if use-column[58] = yes then assign StrTitul = StrTitul + "Всего расход (сумма прод. цен)"              + {&tabulation} .
  if use-column[74] = yes then assign StrTitul = StrTitul + "Всего расход (скидка)"                       + {&tabulation} .
  if use-column[83] = yes then assign StrTitul = StrTitul + "Всего расход (% скидки)"                     + {&tabulation} .
  if use-column[23] = yes then assign StrTitul = StrTitul + "Всего возврат (кол-во)"                      + {&tabulation} .
  if use-column[42] = yes then assign StrTitul = StrTitul + "Всего возврат (сумма учет. цен)"             + {&tabulation} .
  if use-column[59] = yes then assign StrTitul = StrTitul + "Всего возврат (сумма прод. цен)"             + {&tabulation} .
  if use-column[75] = yes then assign StrTitul = StrTitul + "Всего возврат (скидка)"                      + {&tabulation} .
  if use-column[84] = yes then assign StrTitul = StrTitul + "Всего возврат (% скидки)"                    + {&tabulation} .
  if use-column[24] = yes then assign StrTitul = StrTitul + "Всего расход-возврат (кол-во)"               + {&tabulation} .
  if use-column[43] = yes then assign StrTitul = StrTitul + "Всего расход-возврат (сумма учет. цен)"      + {&tabulation} .
  if use-column[60] = yes then assign StrTitul = StrTitul + "Всего расход-возврат (сумма прод. цен)"      + {&tabulation} .
  if use-column[76] = yes then assign StrTitul = StrTitul + "Всего расход-возврат-скидка"                 + {&tabulation} .
  if use-column[85] = yes then assign StrTitul = StrTitul + "Всего расход-возврат (% скидки)"             + {&tabulation} .
  if use-column[25] = yes then assign StrTitul = StrTitul + "Инвентаризация (кол-во)"                     + {&tabulation} .
  if use-column[44] = yes then assign StrTitul = StrTitul + "Инвентаризация (сумма учет. цен)"            + {&tabulation} .
  if use-column[61] = yes then assign StrTitul = StrTitul + "Инвентаризация (сумма прод. цен)"            + {&tabulation} .
  if use-column[26] = yes then assign StrTitul = StrTitul + "Списание (кол-во)"                           + {&tabulation} .
  if use-column[45] = yes then assign StrTitul = StrTitul + "Списание (сумма учет. цен)"                  + {&tabulation} .
  if use-column[62] = yes then assign StrTitul = StrTitul + "Списание (сумма прод. цен)"                  + {&tabulation} .
  if use-column[27] = yes then assign StrTitul = StrTitul + "Приход перемещение (кол-во)"                 + {&tabulation} .
  if use-column[46] = yes then assign StrTitul = StrTitul + "Приход перемещение (сумма учет. цен)"        + {&tabulation} .
  if use-column[63] = yes then assign StrTitul = StrTitul + "Приход перемещение (сумма прод. цен)"        + {&tabulation} .
  if use-column[28] = yes then assign StrTitul = StrTitul + "Расход перемещение (кол-во)"                 + {&tabulation} .
  if use-column[47] = yes then assign StrTitul = StrTitul + "Расход перемещение (сумма учет. цен)"        + {&tabulation} .
  if use-column[64] = yes then assign StrTitul = StrTitul + "Расход перемещение (сумма прод. цен)"        + {&tabulation} .
  if use-column[29] = yes then assign StrTitul = StrTitul + "Возврат перемещение (кол-во)"                + {&tabulation} .
  if use-column[48] = yes then assign StrTitul = StrTitul + "Возврат перемещение (сумма учет. цен)"       + {&tabulation} .
  if use-column[65] = yes then assign StrTitul = StrTitul + "Возврат перемещение (сумма прод. цен)"       + {&tabulation} .
  if use-column[30] = yes then assign StrTitul = StrTitul + "Приход производство (кол-во)"                + {&tabulation} .
  if use-column[49] = yes then assign StrTitul = StrTitul + "Приход производство (сумма учет. цен)"       + {&tabulation} .
  if use-column[66] = yes then assign StrTitul = StrTitul + "Приход производство (сумма прод. цен)"       + {&tabulation} .
  if use-column[86] = yes then assign StrTitul = StrTitul + "Списание производство (кол-во)"              + {&tabulation} .
  if use-column[87] = yes then assign StrTitul = StrTitul + "Списание производство (сумма учет. цен)"     + {&tabulation} .
  if use-column[88] = yes then assign StrTitul = StrTitul + "Списание производство (сумма прод. цен)"     + {&tabulation} .
  if use-column[67] = yes then assign StrTitul = StrTitul + "Переоценка"                                  + {&tabulation} .
  if use-column[13] = yes then assign StrTitul = StrTitul + "Остаток на конец (кол-во)"                   + {&tabulation} .
  if use-column[32] = yes then assign StrTitul = StrTitul + "Остаток на конец  (сумма учет. цен)"         + {&tabulation} .
  if use-column[51] = yes then assign StrTitul = StrTitul + "Остаток на конец  (сумма прод. цен)"         + {&tabulation} .
  if use-column[10] = yes then assign StrTitul = StrTitul + "Эффективность"                               + {&tabulation} .
  if use-column[11] = yes then assign StrTitul = StrTitul + "Фактический % наценки"                       + {&tabulation} .
  if RADIO-AltObj > 1     then assign StrTitul = StrTitul + "Кол-во на альтерн. объектах"                 + {&tabulation} .
  if use-column[89] = yes then assign StrTitul = StrTitul + "Свободно на конец (кол-во)"                  + {&tabulation} .
  if use-column[90] = yes then assign StrTitul = StrTitul + "Свободно на конец  (сумма учет. цен)"        + {&tabulation} .
  if use-column[91] = yes then assign StrTitul = StrTitul + "Свободно на конец  (сумма прод. цен)"        + {&tabulation} .
  if use-column[92] = yes then assign StrTitul = StrTitul + "Резерв на конец (кол-во)"                    + {&tabulation} .
  if use-column[93] = yes then assign StrTitul = StrTitul + "Резерв на конец (сумма учет. цен)"           + {&tabulation} .
  if use-column[94] = yes then assign StrTitul = StrTitul + "Резерв на конец (сумма прод. цен - скидка)"  + {&tabulation} .
  if use-column[95] = yes then assign StrTitul = StrTitul + "Резерв на конец (скидка)"                    + {&tabulation} .
  if use-column[96] = yes then assign StrTitul = StrTitul + "Резерв на конец (% скидки)"                  + {&tabulation} .
end.