/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет по скорости продаж

Автор: Демин Алексей Сергеевич
Дата создания: 03/23/06
Author: Alexey Demin
Creation date: 03/23/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$".

procedure PutColumnTitulExcel : /* заголовки для колонок экселя */
  do
  on error undo, return error return-value
  :
  assign
    v-row = 7
    v-col = 3
  .

  run macr_excel_char (ReportNAme, 1, 3) .
  run macr_cell_format ( 11, yes, no, ?, 1, 3, 1, 3) .
  run macr_excel_char (str1, 2, 1) .
  run macr_excel_char (str2, 3, 1) .
  run macr_excel_char (ReportHeader, 4, 1) .

  run macr_excel_char("Артикул", 5, 1) .
  run macr_cell_size (14,?, 5, 1,?,?).
  run macr_excel_char("Наименование товара", 5, 2) .
  run macr_cell_size (40,?, 5, 2,?,?).
  for each obj-list :
    if p-rashod and p-speed then  run macr_excel_char(obj-list.obj-name + " (" + buf_clients.obj-type + '#' + string(buf_clients.obj-code) + ")", 5, v-col + 2 ) .
    else   run macr_excel_char(obj-list.obj-name + " (" + buf_clients.obj-type + '#' + string(buf_clients.obj-code) + ")", 5, v-col + 1 ) .
    if p-rashod then do:
      run macr_excel_char("внешний расход", 6, v-col) .
      run macr_cell_size   (14,?, 6, v-col, 6, v-col) .
      assign v-col = v-col + 1 .
    end.
    if p-speed then do:
      run macr_excel_char("скорость продаж", 6, v-col) .
      run macr_cell_size   (14,?, 6, v-col, 6, v-col) .
      assign v-col = v-col + 1 .
    end.
    run macr_excel_char("остаток факт", 6, v-col) .
    run macr_cell_size   (14,?, 6, v-col, 6, v-col) .
    assign v-col = v-col + 1 .
    run macr_excel_char("ожидаемое поступление", 6, v-col) .
    run macr_cell_size   (14,?, 6, v-col, 6, v-col) .
    assign v-col = v-col + 1 .
    run macr_excel_char("количество товара в резерве", 6, v-col) .
    run macr_cell_size   (14,?, 6, v-col, 6, v-col) .
    assign v-col = v-col + 1 .
  end.
  run macr_excel_char("Суммарный остаток", 5, v-col) .
  assign v-col = v-col + 1 .
/*  run macr_excel_char("Суммарное ожидаемое поступление", 5, v-col) .*/
/*  assign v-col = v-col + 1 .*/
/*  run macr_excel_char("Суммарное количество товара в резерве", 5, v-col) .*/
/*  assign v-col = v-col + 1 .*/
  run macr_excel_char("Необходимо закупить", 5, v-col) .
  assign v-col = v-col + 1 .
  run macr_excel_char("Поставщики, поставлявшие товар", 5, v-col) .

  run macr_cell_bordur ( 5, 1, 6, v-col) .
  run macr_cell_format ( 10, yes, no, 35, 5, 1, 6, v-col) .
/*  run macr_cell_size   (14,?, 6, 3, 6, v-col) .*/
  run macr_cell_size   (14,?, 5, v-col - 4, 6, v-col) .

  end.
end procedure. /* PutColumnTitulExcel */



procedure PrintLine :
  do
  on error undo, return error return-value
  :
  define variable show as logical initial yes no-undo .
  define variable s-prov as character no-undo .

  if p-null = no then do:
    if temp-goods.sum-reserv = 0 and temp-goods.sum-postup = 0 and temp-goods.sum-ostat = 0 and temp-goods.sum-speed = 0 then do:
      assign show = no .
      for each obj-list :
        find first Temp-obj1
          where Temp-obj1.gds-code = temp-goods.gds-code
            and Temp-obj1.obj-type = obj-list.obj-type
            and Temp-obj1.obj-code = obj-list.obj-code
          no-error .
        if Temp-obj1.rashod <> 0 or Temp-obj1.speed <> 0 or Temp-obj1.ostat <> 0 then do:
          assign show = yes .
          leave.
        end.
      end.
    end.
  end.

  if show = yes then do: /* надо показывать */

    if  ( v-row ) >= 63000 then do:
      Output stream Macr_Excel  close .
      run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name ) .
      run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
      output stream  Macr_Excel to value(v-file-name) .
      v-ind = v-ind + 1 .
      run PutColumnTitulExcel in this-procedure .
    end.

    run macr_excel_char(temp-goods.artic, v-row, 1) .
    run macr_excel_char(temp-goods.gds-name, v-row, 2) .

    assign v-col = 3 .
    for each obj-list :
      find first Temp-obj1
        where Temp-obj1.gds-code = temp-goods.gds-code
          and Temp-obj1.obj-type = obj-list.obj-type
          and Temp-obj1.obj-code = obj-list.obj-code
        no-error .

      if p-rashod = yes then do:
        find first Temp-Sum where Temp-Sum.type = 2 and Temp-Sum.ind  = v-col no-error .
        assign Temp-Sum.sum = Temp-Sum.sum + Temp-obj1.rashod  .
        run macr_excel_sum  ( Temp-obj1.rashod, v-row, v-col,  3) .
        assign v-col = v-col + 1 .
      end.

      if p-speed = yes then do:
        find first Temp-Sum where Temp-Sum.type = 2 and Temp-Sum.ind  = v-col no-error .
/*        assign Temp-Sum.sum = Temp-Sum.sum + Temp-obj1.speed  .*/
        assign Temp-Sum.sum = ? .
        run macr_excel_sum  ( Temp-obj1.speed , v-row, v-col,  3) .
        assign v-col = v-col + 1 .
      end.

      find first Temp-Sum where Temp-Sum.type = 2 and Temp-Sum.ind  = v-col no-error .
      assign Temp-Sum.sum = Temp-Sum.sum + Temp-obj1.ostat .
      run macr_excel_sum  ( Temp-obj1.ostat , v-row, v-col,  3) .
      assign v-col = v-col + 1 .

      find first Temp-Sum where Temp-Sum.type = 2 and Temp-Sum.ind  = v-col no-error .
      assign Temp-Sum.sum = Temp-Sum.sum + Temp-obj1.postup .
      run macr_excel_sum  ( Temp-obj1.postup , v-row, v-col,  3) .
      assign v-col = v-col + 1 .

      find first Temp-Sum where Temp-Sum.type = 2 and Temp-Sum.ind  = v-col no-error .
      assign Temp-Sum.sum = Temp-Sum.sum + Temp-obj1.reserv .
      run macr_excel_sum  ( Temp-obj1.reserv , v-row, v-col,  3) .
      assign v-col = v-col + 1 .
    end.

    find first Temp-Sum where Temp-Sum.type = 2 and Temp-Sum.ind  = v-col no-error .
    assign Temp-Sum.sum = Temp-Sum.sum + temp-goods.sum-ostat .
    run macr_excel_sum  ( temp-goods.sum-ostat , v-row, v-col,  3) .
    assign v-col = v-col + 1 .

/*    find first Temp-Sum where Temp-Sum.type = 2 and Temp-Sum.ind  = v-col no-error .*/
/*    assign Temp-Sum.sum = Temp-Sum.sum + temp-goods.sum-postup .*/
/*    run macr_excel_sum  ( temp-goods.sum-postup , v-row, v-col,  3) .*/
/*    assign v-col = v-col + 1 .*/

/*    find first Temp-Sum where Temp-Sum.type = 2 and Temp-Sum.ind  = v-col no-error .*/
/*    assign Temp-Sum.sum = Temp-Sum.sum + temp-goods.sum-reserv  .*/
/*    run macr_excel_sum  ( temp-goods.sum-reserv , v-row, v-col,  3) .*/
/*    assign v-col = v-col + 1 .*/

    find first Temp-Sum where Temp-Sum.type = 2 and Temp-Sum.ind  = v-col no-error .
    assign Temp-Sum.sum = Temp-Sum.sum + temp-goods.sum-speed * p-day / 30 - temp-goods.sum-ostat - temp-goods.sum-postup + temp-goods.sum-reserv  .
    run macr_excel_sum  ( temp-goods.sum-speed * p-day / 30 - temp-goods.sum-ostat - temp-goods.sum-postup + temp-goods.sum-reserv , v-row, v-col,  3) .
    assign
      v-col = v-col + 1
      s-prov = ""
    .
    for each Temp-cli where Temp-cli.gds-code = temp-goods.gds-code :
       assign s-prov = s-prov + string(Temp-cli.cli-code) + ", " .
    end.
    run macr_excel_char(s-prov, v-row, v-col) .

    assign v-row = v-row + 1 .
  end.

  end.
end procedure. /* PrintLine */


procedure PrintLine1 :
  do
  on error undo, return error return-value
  :
  define variable s-prov as character no-undo .

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

    run macr_excel_char(temp-goods-cli.artic, v-row, 1) .
    run macr_excel_char(temp-goods-cli.gds-name, v-row, 2) .

    assign v-col = 3 .
    for each obj-list :
      find first Temp-obj1
        where Temp-obj1.gds-code = temp-goods-cli.gds-code
          and Temp-obj1.cli-code = temp-goods-cli.cli-code
          and Temp-obj1.cli-type = temp-goods-cli.cli-type
          and Temp-obj1.obj-type = obj-list.obj-type
          and Temp-obj1.obj-code = obj-list.obj-code
        no-error .

      if p-rashod = yes then do:
        find first Temp-Sum where Temp-Sum.type = 2 and Temp-Sum.ind  = v-col no-error .
        assign Temp-Sum.sum = Temp-Sum.sum + Temp-obj1.rashod  .
        run macr_excel_sum  ( Temp-obj1.rashod, v-row, v-col,  3) .
        assign v-col = v-col + 1 .
      end.

      if p-speed = yes then do:
        find first Temp-Sum where Temp-Sum.type = 2 and Temp-Sum.ind  = v-col no-error .
/*        assign Temp-Sum.sum = Temp-Sum.sum + Temp-obj1.speed  .*/
        assign Temp-Sum.sum = ? .
        run macr_excel_sum  ( Temp-obj1.speed , v-row, v-col,  3) .
        assign v-col = v-col + 1 .
      end.

      find first Temp-Sum where Temp-Sum.type = 2 and Temp-Sum.ind  = v-col no-error .
      assign Temp-Sum.sum = Temp-Sum.sum + Temp-obj1.ostat  .
      run macr_excel_sum  ( Temp-obj1.ostat , v-row, v-col,  3) .
      assign v-col = v-col + 1 .

      find first Temp-Sum where Temp-Sum.type = 2 and Temp-Sum.ind  = v-col no-error .
      assign Temp-Sum.sum = Temp-Sum.sum + Temp-obj1.postup  .
      run macr_excel_sum  ( Temp-obj1.postup , v-row, v-col,  3) .
      assign v-col = v-col + 1 .

      find first Temp-Sum where Temp-Sum.type = 2 and Temp-Sum.ind  = v-col no-error .
      assign Temp-Sum.sum = Temp-Sum.sum + Temp-obj1.reserv  .
      run macr_excel_sum  ( Temp-obj1.reserv , v-row, v-col,  3) .
      assign v-col = v-col + 1 .
    end.

    find first Temp-Sum where Temp-Sum.type = 2 and Temp-Sum.ind  = v-col no-error .
    assign Temp-Sum.sum = Temp-Sum.sum + temp-goods-cli.sum-ostat .
    run macr_excel_sum  ( temp-goods-cli.sum-ostat , v-row, v-col,  3) .
    assign v-col = v-col + 1 .

/*    find first Temp-Sum where Temp-Sum.type = 2 and Temp-Sum.ind  = v-col no-error .*/
/*    assign Temp-Sum.sum = Temp-Sum.sum + temp-goods-cli.sum-postup .*/
/*    run macr_excel_sum  ( temp-goods-cli.sum-postup , v-row, v-col,  3) .*/
/*    assign v-col = v-col + 1 .*/

/*    find first Temp-Sum where Temp-Sum.type = 2 and Temp-Sum.ind  = v-col no-error .*/
/*    assign Temp-Sum.sum = Temp-Sum.sum + temp-goods-cli.sum-reserv  .*/
/*    run macr_excel_sum  ( temp-goods-cli.sum-reserv , v-row, v-col,  3) .*/
/*    assign v-col = v-col + 1 .*/

    find first Temp-Sum where Temp-Sum.type = 2 and Temp-Sum.ind  = v-col no-error .
    assign Temp-Sum.sum = Temp-Sum.sum + temp-goods-cli.sum-speed * p-day / 30 - temp-goods-cli.sum-ostat - temp-goods-cli.sum-postup + temp-goods-cli.sum-reserv  .
    run macr_excel_sum  ( temp-goods-cli.sum-speed * p-day / 30 - temp-goods-cli.sum-ostat - temp-goods-cli.sum-postup + temp-goods-cli.sum-reserv , v-row, v-col,  3) .
    assign
      v-col = v-col + 1
      s-prov = ""
    .
    for each Temp-cli where Temp-cli.gds-code = temp-goods-cli.gds-code :
       assign s-prov = s-prov + string(Temp-cli.cli-code) + ", " .
    end.
    run macr_excel_char(s-prov, v-row, v-col) .

    assign v-row = v-row + 1 .

  end.
end procedure. /* PrintLine1 */



procedure PrintItog :

  define input parameter  p-num as integer   no-undo .

  do
  on error undo, return error return-value
  :
    if p-provider = 1 then do: /* нет разбиения по поставщикам, просто справочно */
      if p-num = 2 then do:
        run AddTempSum (3) .
        run macr_excel_char("Итого по группе: " + temp-goods.grp-name, v-row, 2) .
      end.
      else run macr_excel_char("Итого: ", v-row, 2) .
    end.
    else do:
      case p-num :
        when 2 then do:
          run macr_excel_char("Итого по группе: " + temp-goods-cli.grp-name, v-row, 2) .
          run AddTempSum (3) .
        end.
        when 3 then do:
          run macr_excel_char("Итого по поставщику:" + temp-goods-cli.cli, v-row, 2) .
          run AddTempSum (4) .
        end.
        when 4 then run macr_excel_char("Итого:", v-row, 2) .
      end.
    end.

    for each Temp-Sum
      where Temp-Sum.type = p-num
      :
      if Temp-Sum.sum <> ? then run macr_excel_sum  ( Temp-Sum.sum, v-row, Temp-Sum.ind,  3) .
      assign Temp-Sum.sum = 0 .
    end.

    assign v-row = v-row + 1 .
  end.

end procedure. /* PrintItog */