/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры для прогр r-ost-bd.p

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/23/06
Author: Michael Kochetkov
Creation date: 03/23/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

procedure Ostatok :
  do
  on error undo, return error return-value
  :
  for each temp-goods :
    assign is-null = yes .
    for each temp-obj :
      assign Counter1 = Counter1 + 1.
      { rep/repfrm.i disp Counter1 }

      create temp-goods-obj .
      assign
        temp-goods-obj.gds-code = temp-goods.gds-code
        temp-goods-obj.obj-code = temp-obj.obj-code
        temp-goods-obj.obj-type = temp-obj.obj-type
        temp-goods-obj.obj-name = temp-obj.obj-name
        temp-goods-obj.db-num   = temp-obj.db-num
        temp-goods-obj.qnty     = 0
        temp-goods-obj.sum-zak  = 0
        temp-goods-obj.sum-prod = 0
      .

      /* считаем остатки */
      find last buf_stk-line no-lock        /* закупка */
        where buf_stk-line.obj-type  = temp-obj.obj-type
          and buf_stk-line.obj-code  = temp-obj.obj-code
          and buf_stk-line.artic     = temp-goods.artic
          and buf_stk-line.prod-type = temp-goods.prod-type
          and buf_stk-line.prod-code = temp-goods.prod-code
          and buf_stk-line.sum-type  = {&arh-cost}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= v-fact-order-start
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          temp-goods-obj.qnty = buf_stk-line.fact-qnty
          temp-goods-obj.sum-zak = buf_stk-line.sum-rubl
        .
      end.
      find last buf_stk-line no-lock        /* продажа */
        where buf_stk-line.obj-type  = temp-obj.obj-type
          and buf_stk-line.obj-code  = temp-obj.obj-code
          and buf_stk-line.artic     = temp-goods.artic
          and buf_stk-line.prod-type = temp-goods.prod-type
          and buf_stk-line.prod-code = temp-goods.prod-code
          and buf_stk-line.sum-type  = {&arh-crsa}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= v-fact-order-start
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          temp-goods-obj.sum-prod = buf_stk-line.sum-rubl
        .
      end.
      if temp-goods-obj.qnty <> 0 then assign is-null = no .
    end.
    /* удаляем все, если везде 0 */
    if is-null = yes then do:
      for each temp-goods-obj
        where temp-goods-obj.gds-code = temp-goods.gds-code :
        delete temp-goods-obj .
      end.
      delete temp-goods .
    end.
  end.

  end.
end procedure. /* Ostatok */


procedure PutColumnTitulExcel : /* заголовки для колонок экселя */
  do
  on error undo, return error return-value
  :
  assign
    v-row = 2
    v-col = 3
  .

  run macr_excel_char (str1, 1, 3) .
  run macr_cell_format ( 11, yes, no, ?, 1, 3, 1, 3) .
/*  run macr_excel_char (str1, 2, 1) .*/

  run macr_excel_char("Артикул", v-row, 1) .
  run macr_cell_size (14,?, v-row, 1,?,?).
  run macr_excel_char("Наименование товара", v-row, 2) .
  run macr_cell_size (40,?, v-row, 2,?,?).
  for each temp-db :
    run macr_excel_char( temp-db.db-name,   v-row, v-col + 1) .
    run macr_excel_char( "кол-во", v-row + 1, v-col) .                assign v-col = v-col + 1 .
    run macr_excel_char( "сумма учетных цен", v-row + 1, v-col) .     assign v-col = v-col + 1 .
    run macr_excel_char( "сумма продажных цен", v-row + 1, v-col) .   assign v-col = v-col + 1 .
    for each temp-obj
      where temp-obj.db-num = temp-db.db-num
        and temp-obj.typ    = 1
      :
      run macr_excel_char(temp-obj.obj-name + " (" + temp-obj.obj-type + '#' + string(temp-obj.obj-code) + ")", v-row, v-col + 1) .
      run macr_excel_char( "кол-во", v-row + 1, v-col) .              assign v-col = v-col + 1 .
      run macr_excel_char( "сумма учетных цен", v-row + 1, v-col) .   assign v-col = v-col + 1 .
      run macr_excel_char( "сумма продажных цен", v-row + 1, v-col) . assign v-col = v-col + 1 .
    end.
  end.
  find first  temp-obj where temp-obj.typ = 2  no-error .
  if available temp-obj then do:
    run macr_excel_char( "Исключенные объекты", v-row, v-col + 1) .
    run macr_excel_char( "кол-во", v-row + 1, v-col) .               assign v-col = v-col + 1 .
    run macr_excel_char( "сумма учетных цен", v-row + 1, v-col) .    assign v-col = v-col + 1 .
    run macr_excel_char( "сумма продажных цен", v-row + 1, v-col) .
  end.
  else assign v-col = v-col - 1 .

  run macr_cell_bordur ( v-row, 1, v-row + 1, v-col) .
  run macr_cell_format ( 10, yes, no, 35, v-row, 1, v-row + 1, v-col) .
/*  run macr_cell_size   (14,?, 6, 3, 6, v-col) .*/
  run macr_cell_size   (14,?, v-row, 3, v-row + 1, v-col) .
  assign  v-row = v-row + 2 .
  end.
end procedure. /* PutColumnTitulExcel */


procedure PrintLine :
  do
  on error undo, return error return-value
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

    assign
      v-col = 3
      ii = 3
    .
    for each Temp-Sum where Temp-Sum.num = -2 : assign Temp-Sum.sum = 0 . end.

    for each temp-db :
      for each temp-obj
        where temp-obj.db-num = temp-db.db-num
          and temp-obj.typ    = 0
      :
        find first temp-goods-obj
          where temp-goods-obj.obj-type = temp-obj.obj-type
            and temp-goods-obj.obj-code = temp-obj.obj-code
            and temp-goods-obj.gds-code = temp-goods.gds-code
        no-error .
        if available temp-goods-obj then do:
          find first Temp-Sum where Temp-Sum.num = -2 and Temp-Sum.ind  = ii .
          assign Temp-Sum.sum = Temp-Sum.sum + temp-goods-obj.qnty .
          find first Temp-Sum where Temp-Sum.num = -2 and Temp-Sum.ind  = ii + 1 .
          assign Temp-Sum.sum = Temp-Sum.sum + temp-goods-obj.sum-zak .
          find first Temp-Sum where Temp-Sum.num = -2 and Temp-Sum.ind  = ii + 2 .
          assign Temp-Sum.sum = Temp-Sum.sum + temp-goods-obj.sum-prod .
        end .
      end .
      assign ii = ii + 3 .
      for each temp-obj
        where temp-obj.db-num = temp-db.db-num
          and temp-obj.typ    = 1
      :
        find first temp-goods-obj
          where temp-goods-obj.obj-type = temp-obj.obj-type
            and temp-goods-obj.obj-code = temp-obj.obj-code
            and temp-goods-obj.gds-code = temp-goods.gds-code
        no-error .
        find first Temp-Sum where Temp-Sum.num = -2 and Temp-Sum.ind  = ii .
        if available temp-goods-obj then assign Temp-Sum.sum = Temp-Sum.sum + temp-goods-obj.qnty .
        assign ii = ii + 1 .
        find first Temp-Sum where Temp-Sum.num = -2 and Temp-Sum.ind  = ii .
        if available temp-goods-obj then assign Temp-Sum.sum = Temp-Sum.sum + temp-goods-obj.sum-zak .
        assign ii = ii + 1 .
        find first Temp-Sum where Temp-Sum.num = -2 and Temp-Sum.ind  = ii .
        if available temp-goods-obj then assign Temp-Sum.sum = Temp-Sum.sum + temp-goods-obj.sum-prod .
        assign ii = ii + 1 .
      end .
    end .
    for each temp-obj where temp-obj.typ = 2 :
      find first temp-goods-obj
        where temp-goods-obj.obj-type = temp-obj.obj-type
          and temp-goods-obj.obj-code = temp-obj.obj-code
          and temp-goods-obj.gds-code = temp-goods.gds-code
      no-error .
      find first Temp-Sum where Temp-Sum.num = -2 and Temp-Sum.ind  = ii .
      if available temp-goods-obj then assign Temp-Sum.sum = Temp-Sum.sum + temp-goods-obj.qnty .
      find first Temp-Sum where Temp-Sum.num = -2 and Temp-Sum.ind  = ii + 1 .
      if available temp-goods-obj then assign Temp-Sum.sum = Temp-Sum.sum + temp-goods-obj.sum-zak .
      find first Temp-Sum where Temp-Sum.num = -2 and Temp-Sum.ind  = ii + 2 .
      if available temp-goods-obj then assign Temp-Sum.sum = Temp-Sum.sum + temp-goods-obj.sum-prod .
    end .

    if x-itog = no then do: /* надо показывать */
      run macr_excel_char(temp-goods.artic, v-row, 1) .
      run macr_excel_char(temp-goods.gds-name, v-row, 2) .
      for each Temp-Sum where Temp-Sum.num = -2 :
        if TRUNCATE( Temp-Sum.ind / 3,0) = Temp-Sum.ind / 3 then run macr_excel_sum  ( Temp-Sum.sum, v-row, Temp-Sum.ind, 3) .
        else                                                     run macr_excel_sum  ( Temp-Sum.sum, v-row, Temp-Sum.ind, 2) .
      end.
      assign v-row = v-row + 1 .
    end.

    define buffer buf_Temp-Sum for Temp-Sum .

    for each Temp-Sum where Temp-Sum.num = -2 :
      find first buf_Temp-Sum where buf_Temp-Sum.num  = v-level and buf_Temp-Sum.ind  = Temp-Sum.ind  no-error .
      assign buf_Temp-Sum.sum = buf_Temp-Sum.sum + Temp-Sum.sum  .
    end.

  end.
end procedure. /* PrintLine */


procedure GrpSumTree :
  v-level      = num-entries( right-trim(temp-goods.full-grp-name, {&delim-grp}), {&delim-grp} ).

  assign CurrGrpName = "" .
  do ind = 1 to v-level :
    if ind = 1 then assign CurrGrpName = entry ( ind, temp-goods.full-grp-name, {&delim-grp} ) + {&delim-grp} .
    else assign CurrGrpName = CurrGrpName + entry ( ind, temp-goods.full-grp-name, {&delim-grp} )  + {&delim-grp}.
    find first temp-sum  where temp-sum.full_grp = CurrGrpName no-error .
    if not available temp-sum then LEAVE.
  end.

  do ii = v-old-level to ind by -1 : /* удаляем старые заголовки из списка */
    find first temp-sum where temp-sum.num = ii .
    if x-itog = no then do:
      run macr_excel_char("Итого по группе " + temp-sum.grp + ":", v-row, 2) .
      run macr_cell_format ( 10, yes, no, ?, v-row , 2, v-row, 2) .
      for each Temp-Sum where Temp-Sum.num = ii :
        if TRUNCATE( Temp-Sum.ind / 3,0) = Temp-Sum.ind / 3 then run macr_excel_sum  ( Temp-Sum.sum, v-row, Temp-Sum.ind, 3) .
        else                                                     run macr_excel_sum  ( Temp-Sum.sum, v-row, Temp-Sum.ind, 2) .
      end.
      assign  v-row = v-row + 1 .
    end.
    else do:
      if x-lavel = -1 or ii <= x-lavel then do:
        run macr_excel_char(temp-sum.full_grp, v-row, 2) .
        run macr_cell_format ( 10, yes, no, ?, v-row , 2, v-row, 2) .
        for each Temp-Sum where Temp-Sum.num = ii :
          if TRUNCATE( Temp-Sum.ind / 3,0) = Temp-Sum.ind / 3 then run macr_excel_sum  ( Temp-Sum.sum, v-row, Temp-Sum.ind, 3) .
          else                                                     run macr_excel_sum  ( Temp-Sum.sum, v-row, Temp-Sum.ind, 2) .
        end.
        assign  v-row = v-row + 1 .
      end.
    end.
    for each temp-sum where temp-sum.num = ii : delete temp-sum . end.
  end.

  assign v-old-level = v-level .
  /* надо вставлять заголовки для всех нижестоящих и вставить их в список */
  do ii = ind to v-level :
    run InitTempSum in this-procedure (ii) .
    find first temp-sum where temp-sum.num = ii .
    if ii > ind then do:
      assign CurrGrpName = CurrGrpName + {&delim-grp} + entry ( ii, temp-goods.full-grp-name, {&delim-grp} ) .
    end.
    assign
      temp-sum.full_grp = CurrGrpName
      temp-sum.grp = entry ( ii, temp-goods.full-grp-name, {&delim-grp} )
    .
    if x-itog = no then do:
      run macr_excel_char("Группа " + temp-sum.grp + ":", v-row, 2) .
      run macr_cell_format ( 10, yes, no, ?, v-row , 2, v-row, 2) .
      assign  v-row = v-row + 1 .
    end.
  end.

end procedure.




/* $Workfile$ e n d */