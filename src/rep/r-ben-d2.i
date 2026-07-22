/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет по продажам ниже учетной цены

Автор: Демин Алексей Сергеевич
Дата создания: 03/22/06
Author: Alexey Demin
Creation date: 03/22/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


  define variable numm as integer initial 0  no-undo .
  define variable is-day as logical   no-undo .

  /* Подсчитаем кол-во дней заказов */
  if use-column1[4] = yes then do:
    for each temp-value
      where temp-value.type = 1
      break by temp-value.data
      :
      if first-of(temp-value.data) then do:
        create temp-date .
        assign
          NumZakaz = NumZakaz + 1
          temp-date.type = 1
          temp-date.data = temp-value.data
        .
      end.
    end.
  end.

  /* Подсчитаем кол-во дней приходов */
  if use-column1[6] = yes then do:
    for each temp-value
      where temp-value.type = 2
      break by temp-value.data
      :
      if first-of(temp-value.data) then do:
        create temp-date .
        assign
          NumPrihod = NumPrihod + 1
          temp-date.type = 2
          temp-date.data = temp-value.data
        .
      end.
    end.
  end.
/*message*/
/*  NumZakaz NumPrihod*/
/*  view-as alert-box.*/
  assign
    NumColumn = 3
    TitleStr1 = "№,Артикул,Наименование,"
    sheetf.Sizes    = "6,16,42"
    sheetf.MergeCellsV = "1=1:4/2=1:4/3=1:4"
    NumPrice = 0
    TitleStr2 = ",,,"
    TitleStr3 = ",,,"
    TitleStr4 = ",,,"
  .

  if use-column1[1] = yes or use-column1[2] = yes or use-column1[3] = yes  then do:
    if use-column1[1] = yes then NumPrice = NumPrice + 1 .
    if use-column1[2] = yes then NumPrice = NumPrice + 1 .
    if use-column1[3] = yes then NumPrice = NumPrice + 1 .
    assign
      TitleStr1 = TitleStr1 + "Цена за единицу"
      TitleH1   = TitleH1   + "4:" + string(3 + NumPrice)
      NumColumn = NumColumn + NumPrice
    .
    do ii = 1 to NumPrice:
      assign
        TitleStr1 = TitleStr1 + ","
        TitleStr3 = TitleStr3 + ","
        TitleStr4 = TitleStr4 + ","
        sheetf.Sizes    = sheetf.Sizes    + ",9"
        sheetf.MergeCellsV = sheetf.MergeCellsV + "/" + string( ii + 3 ) + "=2:4"
      .
    end.
    if use-column1[1] = yes then  assign   TitleStr2 = TitleStr2 + "Цена поставщика,"    .
    if use-column1[2] = yes then  assign   TitleStr2 = TitleStr2 + "Розн. базовая цена," .
    if use-column1[3] = yes then  assign   TitleStr2 = TitleStr2 + "Розн. текущая цена," .
  end.

  assign
    NumColumn = NumColumn + 1
  .

  if use-column1[4] = yes or use-column1[5] = yes then do:
    assign
      is-day = no
      numm = 0
    .
    if use-column1[4] = yes then assign numm = NumZakaz .
    if use-column1[5] = yes then assign numm = numm + 1 .
    assign
      TitleH1 = TitleH1 + "," + string(NumColumn) + ":" + string(NumColumn + numm * 2 * NumObj - 1 )
      TitleStr1 = TitleStr1 + "Заказ"
    .
  end.

  /*   З А К А З Ы подробно */
  if use-column1[4] = yes then do:
    assign  igr = igr + NumObj * NumZakaz .
    if igr * 2 > 250 then do:
      message  "Не все колонки отчета помещаются в Excel! Начиная с 'заказ' и далее колонки выводится не будут"   view-as alert-box.
      do  ii = 4 to 18 :  assign use-column1[ii] = no .  end.
      assign  igr = igr - NumObj * NumZakaz .
    end.
    else do:
      for each temp-date
        where temp-date.type = 1
      :
        if b2 = yes then assign TitleH2   = TitleH2 + ","  TitleH3   = TitleH3 + ","  .
        else assign b2 = yes .
        if is-day = no then do:
          assign
            is-day = yes
            TitleStr2 = TitleStr2 + "Базовый заказ от " + String(temp-date.data,"99.99.9999")
          .
        end.
        else assign TitleStr2 = TitleStr2 + "Дозаказ от " + String(temp-date.data,"99.99.9999")  .

        assign
          TitleH2 = TitleH2 + string(NumColumn) + ":" + string(NumColumn + 2 * NumObj - 1 )
          TitleH3 = TitleH3 + string(NumColumn) + ":" + string(NumColumn + 1 )
        .
        { rep/r-ben-d4.i }
      end.
    end.
  end.

  /*   З А К А З Ы */
  if use-column1[5] = yes then do:
    assign  igr = igr + NumObj .
    if igr * 2 > 250 then do:
      message  "Не все колонки отчета помещаются в Excel! Начиная с 'Итого заказ' и далее колонки выводится не будут"   view-as alert-box.
      do  ii = 5 to 18 : assign use-column1[ii] = no .  end.
      assign  igr = igr - NumObj .
    end.
    else do:
      if b2 = yes then assign TitleH2   = TitleH2 + ","  TitleH3   = TitleH3 + ","  .
      else assign b2 = yes .
      assign
        TitleH2 = TitleH2 + string(NumColumn) + ":" + string(NumColumn + 2 * NumObj - 1 )
        TitleH3 = TitleH3 + string(NumColumn) + ":" + string(NumColumn + 1 )
        TitleStr2 = TitleStr2 + "Итого заказ"
      .
      { rep/r-ben-d4.i }
    end.
  end.

  if use-column1[6] = yes or use-column1[7] = yes then do:
    assign numm = 0 .
    if use-column1[6] = yes then assign numm = NumPrihod .
    if use-column1[7] = yes then assign numm = numm + 1 .
    assign
      TitleStr1 = TitleStr1 + "ПРИХОД ВНЕШНИЙ (со склада 'офис')"
      TitleH1 = TitleH1 + "," + string(NumColumn) + ":" + string(NumColumn + numm * 2 * NumObj - 1 )
    .
  end.

  /*   ПРИХОДЫ подробно */
  if use-column1[6] = yes then do:
    assign  igr = igr + NumObj * NumPrihod .
    if igr * 2 > 250 then do:
      message  "Не все колонки отчета помещаются в Excel! Начиная с 'ПРИХОДЫ подробно' и далее колонки выводится не будут"   view-as alert-box.
      do  ii = 6 to 18 :  assign use-column1[ii] = no .  end.
      assign  igr = igr - NumObj * NumPrihod .
    end.
    else do:
      for each temp-date
        where temp-date.type = 2
      :
        if b2 = yes then assign TitleH2   = TitleH2 + ","  TitleH3   = TitleH3 + ","  .
        else assign b2 = yes .

        assign
          TitleStr2 = TitleStr2 + "Приход от " + String(temp-date.data,"99.99.9999")
          TitleH2 = TitleH2 + string(NumColumn) + ":" + string(NumColumn + 2 * NumObj - 1 )
          TitleH3 = TitleH3 + string(NumColumn) + ":" + string(NumColumn + 1 )
        .
        { rep/r-ben-d4.i }
      end.
    end.
  end.

  if use-column1[7] = yes then do:   /* итого приход с офиса */
    assign  igr = igr + NumObj .
    if igr * 2 > 250 then do:
      message  "Не все колонки отчета помещаются в Excel! Начиная с 'Итого ПРИХОД ВНЕШНИЙ' и далее колонки выводится не будут"   view-as alert-box.
      do  ii = 7 to 18 :  assign use-column1[ii] = no .  end.
      assign  igr = igr - NumObj .
    end.
    else do:
      if b2 = yes then assign TitleH2   = TitleH2 + ","  TitleH3   = TitleH3 + ","  .
      else assign b2 = yes .
      assign
        TitleStr2 = TitleStr2 + "Итого ПРИХОД ВНЕШНИЙ"
        TitleH2   = TitleH2 + string(NumColumn) + ":" + string(NumColumn + 2 * NumObj - 1 )
        TitleH3   = TitleH3 + string(NumColumn) + ":" + string(NumColumn + 1 )
      .
      { rep/r-ben-d4.i }
    end.
  end.

  if use-column1[8] = yes then do:   /* остаток в Италии */
    assign  igr = igr + NumObj .
    if igr * 2 > 250 then do:
      message  "Не все колонки отчета помещаются в Excel! Начиная с 'Остаток на складе в Италии' и далее колонки выводится не будут"   view-as alert-box.
      do  ii = 8 to 18 :  assign use-column1[ii] = no .  end.
      assign  igr = igr - NumObj .
    end.
    else do:
      if b2 = yes then assign TitleH2   = TitleH2 + ","  TitleH3   = TitleH3 + ","  .
      else assign b2 = yes .
      assign
        sheetf.MergeCellsV = sheetf.MergeCellsV + "/" + string( NumColumn ) + "=1:2" /* + string( NumColumn + 1 ) + "=1:2"*/
        TitleStr1 = TitleStr1 + "Остаток на складе в Италии"
        TitleH1   = TitleH1 + "," + string(NumColumn) + ":" + string(NumColumn + 2 * NumObj - 1 )
        TitleH2   = TitleH2 + string(NumColumn) + ":" + string(NumColumn + 2 * NumObj - 1 )
        TitleH3   = TitleH3 + string(NumColumn) + ":" + string(NumColumn + 1 )
      .
      { rep/r-ben-d4.i }
    end.
  end.

  if use-column1[9] = yes then do:   /* остаток в Италии */
    assign  igr = igr + NumObj .
    if igr * 2 > 250 then do:
      message  "Не все колонки отчета помещаются в Excel! Начиная с 'Приход внутренний (отложка)' и далее колонки выводится не будут"   view-as alert-box.
      do  ii = 9 to 18 : assign use-column1[ii] = no .  end.
      assign  igr = igr - NumObj .
    end.
    else do:
      if b2 = yes then assign TitleH2   = TitleH2 + ","  TitleH3   = TitleH3 + ","  .
      else assign b2 = yes .
      assign
        sheetf.MergeCellsV = sheetf.MergeCellsV + "/" + string( NumColumn ) + "=1:2" /* + string( NumColumn + 1 ) + "=1:2"*/
        TitleStr1 = TitleStr1 + "Приход внутренний (отложка)"
        TitleH1   = TitleH1 + "," + string(NumColumn) + ":" + string(NumColumn + 2 * NumObj - 1 )
        TitleH2   = TitleH2 + string(NumColumn) + ":" + string(NumColumn + 2 * NumObj - 1 )
        TitleH3   = TitleH3 + string(NumColumn) + ":" + string(NumColumn + 1 )
      .
      { rep/r-ben-d4.i }
    end.
  end.

  if use-column1[10] = yes then do:   /* приход внутренний */
    assign  igr = igr + NumObj .
    if igr * 2 > 250 then do:
      message  "Не все колонки отчета помещаются в Excel! Начиная с 'Приход внутренний (перемещение товара нового сезона с других объектов)' и далее колонки выводится не будут"   view-as alert-box.
      do  ii = 10 to 18 :  assign use-column1[ii] = no .   end.
      assign  igr = igr - NumObj .
    end.
    else do:
      if b2 = yes then assign TitleH2   = TitleH2 + ","  TitleH3   = TitleH3 + ","  .
      else assign b2 = yes .
      assign
        sheetf.MergeCellsV = sheetf.MergeCellsV + "/" + string( NumColumn ) + "=1:2" /* + string( NumColumn + 1 ) + "=1:2" */
        TitleStr1 = TitleStr1 + "Приход внутренний (перемещение товара нового сезона с других объектов)"
        TitleH1   = TitleH1 + "," + string(NumColumn) + ":" + string(NumColumn + 2 * NumObj - 1 )
        TitleH2   = TitleH2 + string(NumColumn) + ":" + string(NumColumn + 2 * NumObj - 1 )
        TitleH3   = TitleH3 + string(NumColumn) + ":" + string(NumColumn + 1 )
      .
      { rep/r-ben-d4.i }
    end.
  end.

    /* НЕТТО-ПРИХОД  */
  if use-column1[11] = yes then do:
    assign  igr = igr + NumObj .
    if igr * 2 > 250 then do:
      message  "Не все колонки отчета помещаются в Excel! Начиная с 'Итого НЕТТО-ПРИХОД' и далее колонки выводится не будут"   view-as alert-box.
      do  ii = 11 to 18 :  assign use-column1[ii] = no .  end.
      assign  igr = igr - NumObj .
    end.
    else do:
      if b2 = yes then assign TitleH2   = TitleH2 + ","  TitleH3   = TitleH3 + ","  .
      else assign b2 = yes .
      assign
        TitleStr1 = TitleStr1 + "Итого НЕТТО-ПРИХОД"
        sheetf.MergeCellsV = sheetf.MergeCellsV + "/" + string( NumColumn ) + "=1:2"/* + string( NumColumn + 1 ) + "=1:2"*/
        TitleH1   = TitleH1 + "," + string(NumColumn) + ":" + string(NumColumn + 2 * NumObj - 1 )
        TitleH2   = TitleH2 + string(NumColumn) + ":" + string(NumColumn + 2 * NumObj - 1 )
        TitleH3   = TitleH3 + string(NumColumn) + ":" + string(NumColumn + 1 )
      .
      { rep/r-ben-d4.i }
    end.
  end.

  if use-column1[12] = yes then do:   /* ОСТАТОК */
    assign  igr = igr + NumObj .
    if igr * 2 > 250 then do:
      message  "Не все колонки отчета помещаются в Excel! Начиная с 'Остаток на складе на...' и далее колонки выводится не будут"   view-as alert-box.
      do  ii = 12 to 18 : assign use-column1[ii] = no .  end.
      assign  igr = igr - NumObj .
    end.
    else do:
      if b2 = yes then assign TitleH2   = TitleH2 + ","  TitleH3   = TitleH3 + ","  .
      else assign b2 = yes .
      assign
        sheetf.MergeCellsV = sheetf.MergeCellsV + "/" + string( NumColumn ) + "=1:2" /*+ string( NumColumn + 1 ) + "=1:2"*/
        TitleStr1 = TitleStr1 + "Остаток на складе на " + String(x-date-end,"99.99.9999")
        TitleH1   = TitleH1 + "," + string(NumColumn) + ":" + string(NumColumn + 2 * NumObj - 1 )
        TitleH2   = TitleH2 + string(NumColumn) + ":" + string(NumColumn + 2 * NumObj - 1 )
        TitleH3   = TitleH3 + string(NumColumn) + ":" + string(NumColumn + 1 )
      .
      { rep/r-ben-d4.i }
    end.
  end.

  if use-column1[13] = yes or use-column1[14] = yes or use-column1[15] = yes then do:
    assign numm = 0  .
    if use-column1[13] = yes then assign numm = numm + 1 .
    if use-column1[14] = yes then assign numm = numm + 1 .
    if use-column1[15] = yes then assign numm = numm + Num-Week .
    assign  numm = NumColumn + (numm * (NumObj * 2)) - 1 .
    if numm > 256 then assign numm = 256 .
    assign
      TitleH1 = TitleH1 + "," + string(NumColumn) + ":" + string(numm)
      TitleStr1 = TitleStr1 + "Реализация-нетто за период"
    .
  end.

  if use-column1[13] = yes then do:   /* Реализация за период отчета */
    assign  igr = igr + NumObj .
    if igr * 2 > 250 then do:
      message  "Не все колонки отчета помещаются в Excel! Начиная с 'Итого за сезон с...' и далее колонки выводится не будут"   view-as alert-box.
      do  ii = 13 to 18 :  assign use-column1[ii] = no .   end.
      assign  igr = igr - NumObj .
    end.
    else do:
      if b2 = yes then assign TitleH2   = TitleH2 + ","  TitleH3   = TitleH3 + ","  .
      else assign b2 = yes .
      assign
        TitleH2 = TitleH2 + string(NumColumn) + ":" + string(NumColumn + 2 * NumObj - 1 )
        TitleH3 = TitleH3 + string(NumColumn) + ":" + string(NumColumn + 1 )
        TitleStr2 = TitleStr2 + "Итого за сезон с " + String(x-date-start,"99.99.9999") + " по " + String(x-date-end,"99.99.9999")
      .
      { rep/r-ben-d4.i }
    end.
  end.

  if use-column1[14] = yes then do:  /* Реализация за период реализации */
    assign  igr = igr + NumObj .
    if igr * 2 > 250 then do:
      message  "Не все колонки отчета помещаются в Excel! Начиная с 'Итого за период с...' и далее колонки выводится не будут"   view-as alert-box.
      do  ii = 14 to 18 : assign use-column1[ii] = no .  end.
      assign  igr = igr - NumObj .
    end.
    else do:
      if b2 = yes then assign TitleH2   = TitleH2 + ","  TitleH3   = TitleH3 + ","  .
      else assign b2 = yes .
      assign
        TitleH2 = TitleH2 + string(NumColumn) + ":" + string(NumColumn + 2 * NumObj - 1 )
        TitleH3 = TitleH3 + string(NumColumn) + ":" + string(NumColumn + 1 )
        TitleStr2 = TitleStr2 + "Итого за период с " + String(x-date-start1,"99.99.9999") + " по " + String(x-date-end1,"99.99.9999")
      .
      { rep/r-ben-d4.i }
    end.
  end.

  if use-column1[15] = yes then do:
BL: for each temp-month :
      assign  igr = igr + NumObj .
      if igr * 2 > 250 then do:
        message  "Не все колонки отчета помещаются в Excel! Начиная с 'реализация - подробно' и далее колонки выводится не будут"   view-as alert-box.
        do  ii = 15 to 18 : assign use-column1[ii] = no .  end.
        assign  igr = igr - NumObj .
        leave BL .
      end.
      else do:
        if b2 = yes then assign TitleH2   = TitleH2 + ","  TitleH3   = TitleH3 + ","  .
        else assign b2 = yes .
        assign
          TitleH2 = TitleH2 + string(NumColumn) + ":" + string(NumColumn + 2 * NumObj - 1 )
          TitleH3 = TitleH3 + string(NumColumn) + ":" + string(NumColumn + 1 )
          TitleStr2 = TitleStr2 + string(temp-month.ind) + " " + NameDate + " с " + String(temp-month.dat-beg,"99.99.9999") + " по " + String(temp-month.dat-end,"99.99.9999")
        .
        { rep/r-ben-d4.i }
      end.
    end.
  end.

  if use-column1[16] = yes then do:  /* среднесуточная Реализация */
    assign  igr = igr + NumObj .
    if igr * 2 > 250 then do:
      message  "Не все колонки отчета помещаются в Excel! Начиная с 'Среднесуточная реализация за период с ...' и далее колонки выводится не будут"   view-as alert-box.
      do  ii = 16 to 18 :  assign use-column1[ii] = no .  end.
      assign  igr = igr - NumObj .
    end.
    else do:
      if b2 = yes then assign TitleH2   = TitleH2 + ","  TitleH3   = TitleH3 + ","  .
      else assign b2 = yes .
      assign
        sheetf.MergeCellsV = sheetf.MergeCellsV + "/" + string( NumColumn ) + "=1:2"/* + string( NumColumn + 1 ) + "=1:2"*/
        TitleStr1 = TitleStr1 + "Среднесуточная реализация за период с " + String(x-date-start2,"99.99.9999") + " по " + String(x-date-end2,"99.99.9999")
        TitleH1   = TitleH1 + "," + string(NumColumn) + ":" + string(NumColumn + 2 * NumObj - 1 )
        TitleH2   = TitleH2 + string(NumColumn) + ":" + string(NumColumn + 2 * NumObj - 1 )
        TitleH3   = TitleH3 + string(NumColumn) + ":" + string(NumColumn + 1 )
      .
      { rep/r-ben-d4.i }
    end.
  end.

  if use-column1[17] = yes then do:  /* расход на магазины */
    assign  igr = igr + NumObj .
    if igr * 2 > 250 then do:
      message  "Не все колонки отчета помещаются в Excel! Начиная с 'Внутреннее перемещение на другой объект' и далее колонки выводится не будут"   view-as alert-box.
      do  ii = 17 to 18 :  assign use-column1[ii] = no .  end.
      assign  igr = igr - NumObj .
    end.
    else do:
      if b2 = yes then assign TitleH2   = TitleH2 + ","  TitleH3   = TitleH3 + ","  .
      else assign b2 = yes .
      assign
        sheetf.MergeCellsV = sheetf.MergeCellsV + "/" + string( NumColumn ) + "=1:2"/* + string( NumColumn + 1 ) + "=1:2"*/
        TitleStr1 = TitleStr1 + "Внутреннее перемещение на другой объект"
        TitleH1   = TitleH1 + "," + string(NumColumn) + ":" + string(NumColumn + 2 * NumObj - 1 )
        TitleH2   = TitleH2 + string(NumColumn) + ":" + string(NumColumn + 2 * NumObj - 1 )
        TitleH3   = TitleH3 + string(NumColumn) + ":" + string(NumColumn + 1 )
      .
      { rep/r-ben-d4.i }
    end.
  end.

  if use-column1[18] = yes then do:  /* инвентаризация */
    assign  igr = igr + NumObj .
    if igr * 2 > 250 then do:
      message  "Не все колонки отчета помещаются в Excel! Начиная с 'Инвентаризация ' и далее колонки выводится не будут"   view-as alert-box.
      assign  igr = igr - NumObj .
    end.
    else do:
      if b2 = yes then assign TitleH2   = TitleH2 + ","  TitleH3   = TitleH3 + ","  .
      else assign b2 = yes .
      assign
        sheetf.MergeCellsV = sheetf.MergeCellsV + "/" + string( NumColumn ) + "=1:2"/* + string( NumColumn + 1 ) + "=1:2"*/
        TitleStr1 = TitleStr1 + "Инвентаризация (+ в приход/ - в расход)"
        TitleH1   = TitleH1 + "," + string(NumColumn) + ":" + string(NumColumn + 2 * NumObj - 1 )
        TitleH2   = TitleH2 + string(NumColumn) + ":" + string(NumColumn + 2 * NumObj - 1 )
        TitleH3   = TitleH3 + string(NumColumn) + ":" + string(NumColumn + 1 )
      .
      { rep/r-ben-d4.i }
    end.
  end.

  assign
    sheetf.Excel-Column-Lable = TitleStr1 + {&new-line} + TitleStr2 + {&new-line} + TitleStr3 + {&new-line} + TitleStr4
    sheetf.MergeCellsH        = TitleH1 + "/" + TitleH2 + "/" + TitleH3
   .
/* output stream SDoc to "111.txt" .*/
/* put stream SDoc unformatted sheetf.Excel-Column-Lable skip .*/
/* put stream SDoc unformatted sheetf.Sizes skip .*/
/* put stream SDoc unformatted sheetf.MergeCellsH skip .*/
/* put stream SDoc unformatted sheetf.MergeCellsV skip .*/
/* output stream SDoc close .*/

sheetf.make-correct =  "".

/* $Workfile$ e n d */