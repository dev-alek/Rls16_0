/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

для детал. оборотки с признаками

Автор: Демин Алексей Сергеевич
Дата создания: 03/22/06
Author: Alexey Demin
Creation date: 03/22/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


PROCEDURE CalcOstatki :
/* -----------------------------------------------------------
  Purpose:     остатки на начало и конец периода
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define buffer buf_stk-line for stk-line.
  define buffer buf_temp-prt-obj for temp-prt-obj .
  { rep/obr-k2-2.i } /* считаем остатки на начало и конец периода */

END PROCEDURE.

PROCEDURE CalcOborot :
/* -----------------------------------------------------------
  Purpose:     остатки на начало и конец периода
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  { rep/obr-k2-3.i }  /* считаем оборот за период */
END PROCEDURE.


procedure CalculSum :
  define input  parameter p-num as integer   no-undo .
  define buffer buf_temp-sum for temp-sum .

  for each temp-sum where temp-sum.level = -1 :
    find first buf_temp-sum
      where buf_temp-sum.level    = p-num
        and buf_temp-sum.num      = temp-sum.num
        and buf_temp-sum.doc-type = temp-sum.doc-type
        and buf_temp-sum.sum-type = temp-sum.sum-type
    no-error .
    if not available buf_temp-sum then do:
      create buf_temp-sum .
      assign
        buf_temp-sum.level    = p-num
        buf_temp-sum.num      = temp-sum.num
        buf_temp-sum.doc-type = temp-sum.doc-type
        buf_temp-sum.sum-type = temp-sum.sum-type
        buf_temp-sum.sum      = temp-sum.sum
      .
    end.
    else assign buf_temp-sum.sum = buf_temp-sum.sum + temp-sum.sum .
  end.
end procedure. /* CalculSum */


procedure PrintLine :
    { rep/obr-k2-6.i } /* вывод строки */
end procedure. /* PrintLine */


procedure PutItogSum :
  define input  parameter p-num as integer   no-undo .
  define buffer buf_temp-sum for temp-sum .

  if p-num = 2 then do:
    assign ItogStr = "Итого по объекту " + obj-list.obj-name + " (" + obj-list.obj-type + '#' + string(obj-list.obj-code) + ") :" .
  end.
  else do:
    if p-num = 1 then assign  ItogStr = "ИТОГО: " .
    else do:
/*      define variable p-is-null as logical   no-undo .*/
      for each  buf_temp-sum where buf_temp-sum.level = p-num :
        if buf_temp-sum.sum <> 0 then assign is-prn-titul = yes .
      end.
      run PutTitul in this-procedure .
    end.
  end.

  if p-num < 2 or ( p-num < 4 and var-client = "" ) or var-client1 = "" then do:
    assign v-col = 1 .

    if line-counter( Outstream ) + 5 > page-size( Outstream ) then do:
      put stream outstream  skip Line format frmt skip "продолжение - на следующей странице" AT 30 SKIP .
      page stream OutStream .
      run rep/r-obrt21.p (input 2, input RADIO-AltObj, input end-sum, output ii, output ii   ) .
    end.

    run macr_excel_char (ItogStr, v-row, v-col) .
    put stream outstream "| " ItogStr format "X(60)" .

    assign
      beg = start-sum
      v-col = start-col
    .
    for each  buf_temp-sum where buf_temp-sum.level = p-num :
      case buf_temp-sum.sum-type :
        when 0 then do:
          put stream outstream  "|" at beg buf_temp-sum.sum format frm-qnty  .
          run macr_excel_sum (buf_temp-sum.sum, v-row, v-col, sz-qnty) .
          assign  beg = beg + 15 .
        end.
        when 1 or when 2 or when 3 then do:
          put stream outstream  "|" at beg buf_temp-sum.sum format frm-sum .
          run macr_excel_sum (buf_temp-sum.sum, v-row, v-col, 2) .
          assign  beg = beg + 15 .
        end.
        when 4 then do:
          put stream outstream  "|" at beg .
/*          put stream outstream  "|" at beg buf_temp-sum.sum format frm-prc .*/
/*          run macr_excel_sum (buf_temp-sum.sum, v-row, v-col, 2) .*/
          assign  beg = beg + 10 .
        end.
      end.
      assign v-col = v-col + 1 .
    end.
    put stream outstream   "|"  skip Line format frmt skip.
    assign v-row = v-row + 1 .
  end.

end procedure. /* PutItogSum */


procedure PutTitul :
  if titul = 0 and tog-obj = true  then do:   /* заголовок объекта */
    define variable line1 as character no-undo .
    assign
      line1 = ""
      titul = 1
    .
    assign  line1 = "По объекту: " + obj-list.obj-name + " (" + obj-list.obj-type + '#' + string(obj-list.obj-code) + ")" .
    run macr_excel_char (line1, v-row, 1) .
    assign v-row = v-row + 1 .
    put stream outstream   Line format frmt skip .
    PUT stream OutStream "| " line1 format "X(60)" "|" at beg  SKIP .
  end.
  if SumsOnly = no and is-prn-titul then do:
    assign is-prn-titul = no .
    if var-client <> "" then do:
      run macr_excel_char (var-client, v-row, 1) .
      assign v-row = v-row + 1 .
      PUT stream OutStream "| " var-client format "X(60)" "|" at beg  SKIP .
      assign  var-client = "" .
    end.
    if var-client1 <> "" then do:
      run macr_excel_char (var-client1, v-row, 1) .
      assign v-row = v-row + 1 .
      PUT stream OutStream "| " var-client1 format "X(60)" "|" at beg  SKIP .
      assign  var-client1 = "" .
    end.
  end.
end procedure. /* PutItogSum */



procedure Add-temp-prt :
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-num      as integer   no-undo .
  define input  parameter p-type     as character no-undo .
  define input  parameter p-prt-code as integer   no-undo .
  define input  parameter p-b-code   as integer   no-undo .
  define input  parameter p-val      as decimal   no-undo .

  do on error undo, return error return-value :
    find first temp-prt
      where temp-prt.obj-type = p-obj-type
        and temp-prt.obj-code = p-obj-code
        and temp-prt.gds-code = p-gds-code
        and temp-prt.prt-code = p-prt-code
        and temp-prt.sum-type = p-num
        and temp-prt.doc-type = p-type
    no-error .
    if not available temp-prt then do:
      create temp-prt .
      ASSIGN
        temp-prt.obj-type = p-obj-type
        temp-prt.obj-code = p-obj-code
        temp-prt.gds-code = p-gds-code
        temp-prt.prt-code = p-prt-code
        temp-prt.b-code   = p-b-code
        temp-prt.doc-type = p-type
        temp-prt.sum-type = p-num
      .
    end.
    assign temp-prt.sum = temp-prt.sum + p-val .
  end.
end procedure. /* Add-temp-prt */


procedure Add-temp-sum :
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-num      as integer   no-undo .
  define input  parameter p-type     as character no-undo .
  define input  parameter p-prt-code as integer   no-undo .
  define input  parameter p-count    as integer   no-undo .

  define buffer buf_temp-prt for temp-prt .
  define variable lvl as integer  no-undo .
  if p-prt-code <> -1 then  assign lvl = - 2 .
  else                      assign lvl = - 1 .

  do on error undo, return error return-value :
    find first temp-sum
      where temp-sum.level    = lvl
        and temp-sum.num      = p-count
        and temp-sum.doc-type = p-type
        and temp-sum.sum-type = p-num
    no-error  .
    if not available temp-sum then do:
      create temp-sum .
      assign
        temp-sum.doc-type = p-type
        temp-sum.num      = p-count
        temp-sum.level    = lvl
        temp-sum.sum-type = p-num
        temp-sum.sum      = 0
      .
    end.

    if     p-type <> "rs-vz"     and p-type <> "rs-vz-k" and p-type <> "rs-all"  and p-type <> "vz-all"
       and p-type <> "rs-vz-all" and p-type <> "eff-val" and p-type <> "eff-prc" then do:
      find first buf_temp-prt
        where buf_temp-prt.obj-type = p-obj-type          and buf_temp-prt.obj-code = p-obj-code
          and buf_temp-prt.gds-code = p-gds-code          and buf_temp-prt.prt-code = p-prt-code
          and buf_temp-prt.sum-type = p-num               and buf_temp-prt.doc-type = p-type
      no-error .
      if available buf_temp-prt then assign temp-sum.sum  = buf_temp-prt.sum  .
    end.
    else do:
      if p-num = 4 and p-type <> "eff-prc" then do:
        define buffer buf1_temp-sum for temp-sum .
        find first buf1_temp-sum where buf1_temp-sum.level = lvl and buf1_temp-sum.sum-type = 3 and buf1_temp-sum.doc-type = p-type no-error .
        if available buf1_temp-sum then assign temp-sum.sum  = buf1_temp-sum.sum * 100 .
        find first buf1_temp-sum where buf1_temp-sum.level = lvl and buf1_temp-sum.sum-type = 4 and buf1_temp-sum.doc-type = p-type no-error .
        if available buf1_temp-sum then assign temp-sum.sum  = temp-sum.sum / buf1_temp-sum.sum .
      end.
      else do:
        case p-type :
          when "rs-vz" then do:
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = p-num            and buf_temp-prt.doc-type = {&TDEDT_Ras_Vnesh}
            no-error .
            if available buf_temp-prt then assign temp-sum.sum = buf_temp-prt.sum .
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = p-num            and buf_temp-prt.doc-type = {&TDEDT_Vozvrat_Vnesh}
            no-error .
            if available buf_temp-prt then assign temp-sum.sum = temp-sum.sum - buf_temp-prt.sum .
            if p-num = 2 then do:
              find first buf_temp-prt
                where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                  and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                  and buf_temp-prt.sum-type = 3            and buf_temp-prt.doc-type = {&TDEDT_Ras_Vnesh}
              no-error .
              if available buf_temp-prt then assign temp-sum.sum = temp-sum.sum - buf_temp-prt.sum .
              find first buf_temp-prt
                where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                  and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                  and buf_temp-prt.sum-type = 3            and buf_temp-prt.doc-type = {&TDEDT_Vozvrat_Vnesh}
              no-error .
              if available buf_temp-prt then assign temp-sum.sum = temp-sum.sum + buf_temp-prt.sum .
            end.
          end.
          when "rs-vz-k" then do:
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = p-num            and buf_temp-prt.doc-type = {&TDEDT_Ras_Vnesh_Kass}
            no-error .
            if available buf_temp-prt then assign temp-sum.sum = buf_temp-prt.sum .
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = p-num            and buf_temp-prt.doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
            no-error .
            if available buf_temp-prt then assign temp-sum.sum = temp-sum.sum - buf_temp-prt.sum .
            if p-num = 2 then do:
              find first buf_temp-prt
                where buf_temp-prt.obj-type = p-obj-type   and buf_temp-prt.obj-code = p-obj-code
                  and buf_temp-prt.gds-code = p-gds-code   and buf_temp-prt.prt-code = p-prt-code
                  and buf_temp-prt.sum-type = 3            and buf_temp-prt.doc-type = {&TDEDT_Ras_Vnesh_Kass}
              no-error .
              if available buf_temp-prt then assign temp-sum.sum = temp-sum.sum - buf_temp-prt.sum .
              find first buf_temp-prt
                where buf_temp-prt.obj-type = p-obj-type   and buf_temp-prt.obj-code = p-obj-code
                  and buf_temp-prt.gds-code = p-gds-code   and buf_temp-prt.prt-code = p-prt-code
                  and buf_temp-prt.sum-type = 3            and buf_temp-prt.doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
              no-error .
              if available buf_temp-prt then assign temp-sum.sum = temp-sum.sum + buf_temp-prt.sum .
            end.
          end.
          when "rs-all" then do:
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = p-num            and buf_temp-prt.doc-type = {&TDEDT_Ras_Vnesh}
            no-error .
            if available buf_temp-prt then assign temp-sum.sum = buf_temp-prt.sum .
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = p-num            and buf_temp-prt.doc-type = {&TDEDT_Ras_Vnesh_Kass}
            no-error .
            if available buf_temp-prt then assign temp-sum.sum = temp-sum.sum + buf_temp-prt.sum .
          end.
          when "vz-all" then do:
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = p-num            and buf_temp-prt.doc-type = {&TDEDT_Vozvrat_Vnesh}
            no-error .
            if available buf_temp-prt then assign temp-sum.sum = buf_temp-prt.sum .
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = p-num            and buf_temp-prt.doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
            no-error .
            if available buf_temp-prt then assign temp-sum.sum = temp-sum.sum + buf_temp-prt.sum .
            if p-num = 2 then do:
              find first buf_temp-prt
                where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                  and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                  and buf_temp-prt.sum-type = 3            and buf_temp-prt.doc-type = {&TDEDT_Ras_Vnesh}
              no-error .
              if available buf_temp-prt then assign temp-sum.sum = temp-sum.sum - buf_temp-prt.sum .
              find first buf_temp-prt
                where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                  and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                  and buf_temp-prt.sum-type = 3            and buf_temp-prt.doc-type = {&TDEDT_Vozvrat_Vnesh}
              no-error .
              if available buf_temp-prt then assign temp-sum.sum = temp-sum.sum + buf_temp-prt.sum .
              find first buf_temp-prt
                where buf_temp-prt.obj-type = p-obj-type   and buf_temp-prt.obj-code = p-obj-code
                  and buf_temp-prt.gds-code = p-gds-code   and buf_temp-prt.prt-code = p-prt-code
                  and buf_temp-prt.sum-type = 3            and buf_temp-prt.doc-type = {&TDEDT_Ras_Vnesh_Kass}
              no-error .
              if available buf_temp-prt then assign temp-sum.sum = temp-sum.sum - buf_temp-prt.sum .
              find first buf_temp-prt
                where buf_temp-prt.obj-type = p-obj-type   and buf_temp-prt.obj-code = p-obj-code
                  and buf_temp-prt.gds-code = p-gds-code   and buf_temp-prt.prt-code = p-prt-code
                  and buf_temp-prt.sum-type = 3            and buf_temp-prt.doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
              no-error .
              if available buf_temp-prt then assign temp-sum.sum = temp-sum.sum + buf_temp-prt.sum .
            end.
          end.
          when "rs-vz-all" then do:
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = p-num            and buf_temp-prt.doc-type = {&TDEDT_Ras_Vnesh}
            no-error .
            if available buf_temp-prt then assign temp-sum.sum = buf_temp-prt.sum .
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = p-num            and buf_temp-prt.doc-type = {&TDEDT_Ras_Vnesh_Kass}
            no-error .
            if available buf_temp-prt then assign temp-sum.sum = temp-sum.sum + buf_temp-prt.sum .
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = p-num            and buf_temp-prt.doc-type = {&TDEDT_Vozvrat_Vnesh}
            no-error .
            if available buf_temp-prt then assign temp-sum.sum = temp-sum.sum - buf_temp-prt.sum .
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = p-num            and buf_temp-prt.doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
            no-error .
            if available buf_temp-prt then assign temp-sum.sum = temp-sum.sum - buf_temp-prt.sum .
          end.
          when "eff-val" or when "eff-prc" then do:
            define variable sm1 as decimal initial 0 no-undo .
            define variable sm2 as decimal initial 0 no-undo .
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = 5               and buf_temp-prt.doc-type = {&TDEDT_Ras_Vnesh}
            no-error .
            if available buf_temp-prt then assign sm2 = buf_temp-prt.sum .
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type   and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code   and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = 5            and buf_temp-prt.doc-type = {&TDEDT_Ras_Vnesh_Kass}
            no-error .
            if available buf_temp-prt then assign sm2 = sm2 + buf_temp-prt.sum .
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type   and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code   and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = 5            and buf_temp-prt.doc-type = {&TDEDT_Vozvrat_Vnesh}
            no-error .
            if available buf_temp-prt then assign sm2 = sm2 - buf_temp-prt.sum .
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type   and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code   and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = 5            and buf_temp-prt.doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
            no-error .
            if available buf_temp-prt then assign sm2 = sm2 - buf_temp-prt.sum .
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type   and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code   and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = 1            and buf_temp-prt.doc-type = {&TDEDT_Ras_Vnesh}
            no-error .
            if available buf_temp-prt then assign sm1 = buf_temp-prt.sum .
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = 1            and buf_temp-prt.doc-type = {&TDEDT_Ras_Vnesh_Kass}
            no-error .
            if available buf_temp-prt then assign sm1 = sm1 + buf_temp-prt.sum .
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = 1            and buf_temp-prt.doc-type = {&TDEDT_Vozvrat_Vnesh}
            no-error .
            if available buf_temp-prt then assign sm1 = sm1 - buf_temp-prt.sum .
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = 1            and buf_temp-prt.doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
            no-error .
            if available buf_temp-prt then assign sm1 = sm1 - buf_temp-prt.sum .
            if p-type = "eff-prc" then assign temp-sum.sum = (sm2 - sm1) * 100 / sm1 .
            else                       assign temp-sum.sum = sm2 - sm1 .
          end.
        end.
      end.
    end.
    if temp-sum.sum = ? then assign temp-sum.sum = 0 .
  end.
end procedure. /* Get-buf_temp-prt */




procedure PrintScale :
  do
  on error undo, return error return-value
  :
    if line-counter( Outstream ) + 2 > page-size( Outstream ) then do:
      put stream outstream  skip Line format frmt skip "продолжение - на следующей странице" AT 30 SKIP .
      page stream OutStream .
      run rep/r-obrt21.p (input 2, input RADIO-AltObj, input end-sum, output ii, output ii) .
    end.
    if  ( v-row ) >= 63000 then do:
      Output stream Macr_Excel  close .
      run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name ) .
      run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
      output stream  Macr_Excel to value(v-file-name) .
      v-ind = v-ind + 1 .
      run rep/r-obrt21.p (input 1, input RADIO-AltObj, input end-sum, output start-col, output v-row) .
    end.
    define variable  null-ostat1  as logical initial yes no-undo .
    define variable  null-oborot1 as logical initial yes no-undo .
    define variable  NullStr1     as integer initial 0   no-undo .

    for each temp-prt
      where temp-prt.obj-type = gds-prop.obj-type
        and temp-prt.obj-code = gds-prop.obj-code
        and temp-prt.gds-code = gds-prop.gds-code
        and temp-prt.prt-code > - 1
        break by temp-prt.prt-code
      :
      if first-of ( temp-prt.prt-code ) then do:
        for each temp-sum where temp-sum.level = -2 : assign temp-sum.sum = 0 . end.
        assign jj = 1 .
        do ii = 1 to 9 :
          if use-column[ii]  = yes then assign jj = jj + 1 .
        end.
        if use-column[12] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "ost-beg",                   temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[31] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "ost-beg",                   temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[50] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "ost-beg",                   temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[14] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, {&TDEDT_Pri_Vnesh},          temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[33] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, {&TDEDT_Pri_Vnesh},          temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[15] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, {&TDEDT_Ras_Vnesh_VP},       temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[34] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, {&TDEDT_Ras_Vnesh_VP},       temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[16] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, {&TDEDT_Ras_Vnesh},          temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[35] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, {&TDEDT_Ras_Vnesh},          temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[52] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, {&TDEDT_Ras_Vnesh},          temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[68] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, {&TDEDT_Ras_Vnesh},          temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[77] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, {&TDEDT_Ras_Vnesh},          temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[17] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, {&TDEDT_Vozvrat_Vnesh},      temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[36] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, {&TDEDT_Vozvrat_Vnesh},      temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[53] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, {&TDEDT_Vozvrat_Vnesh},      temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[69] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, {&TDEDT_Vozvrat_Vnesh},      temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[78] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, {&TDEDT_Vozvrat_Vnesh},      temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[18] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "rs-vz",                     temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[37] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "rs-vz",                     temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[54] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "rs-vz",                     temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[70] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, "rs-vz",                     temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[79] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, "rs-vz",                     temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[19] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, {&TDEDT_Ras_Vnesh_Kass},     temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[38] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, {&TDEDT_Ras_Vnesh_Kass},     temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[55] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, {&TDEDT_Ras_Vnesh_Kass},     temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[71] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, {&TDEDT_Ras_Vnesh_Kass},     temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[80] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, {&TDEDT_Ras_Vnesh_Kass},     temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[20] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, {&TDEDT_Vozvrat_Vnesh_Kass}, temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[39] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, {&TDEDT_Vozvrat_Vnesh_Kass}, temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[56] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, {&TDEDT_Vozvrat_Vnesh_Kass}, temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[72] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, {&TDEDT_Vozvrat_Vnesh_Kass}, temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[81] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, {&TDEDT_Vozvrat_Vnesh_Kass}, temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[21] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "rs-vz-k",                   temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[40] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "rs-vz-k",                   temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[57] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "rs-vz-k",                   temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[73] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, "rs-vz-k",                   temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[82] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, "rs-vz-k",                   temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[22] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "rs-all",                    temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[41] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "rs-all",                    temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[58] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "rs-all",                    temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[74] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, "rs-all",                    temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[83] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, "rs-all",                    temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[23] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "vz-all",                    temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[42] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "vz-all",                    temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[59] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "vz-all",                    temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[75] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, "vz-all",                    temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[84] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, "vz-all",                    temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[24] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "rs-vz-all",                 temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[43] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "rs-vz-all",                 temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[60] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "rs-vz-all",                 temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[76] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, "rs-vz-all",                 temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[85] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, "rs-vz-all",                 temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[25] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, {&TDEDT_Inv},                temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[44] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, {&TDEDT_Inv},                temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[61] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, {&TDEDT_Inv},                temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[26] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, {&TDEDT_Spi_Vnesh},          temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[45] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, {&TDEDT_Spi_Vnesh},          temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[62] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, {&TDEDT_Spi_Vnesh},          temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[27] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, {&TDEDT_Pri_Perem},          temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[46] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, {&TDEDT_Pri_Perem},          temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[63] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, {&TDEDT_Pri_Perem},          temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[28] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, {&TDEDT_Ras_Perem},          temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[47] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, {&TDEDT_Ras_Perem},          temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[64] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, {&TDEDT_Ras_Perem},          temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[29] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, {&TDEDT_Vozvrat_Perem},      temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[48] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, {&TDEDT_Vozvrat_Perem},      temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[65] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, {&TDEDT_Vozvrat_Perem},      temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[30] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, {&TDEDT_Pri_Prvo},           temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[49] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, {&TDEDT_Pri_Prvo},           temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[66] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, {&TDEDT_Pri_Prvo},           temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[86] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, {&TDEDT_Spi_Prvo},           temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[87] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, {&TDEDT_Spi_Prvo},           temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[88] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, {&TDEDT_Spi_Prvo},           temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[67] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, {&TDEDT_Overturn},           temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[13] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "ost-end",                   temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[32] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "ost-end",                   temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[51] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "ost-end",                   temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
/*        if use-column[10] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "eff-val",                   temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.*/
/*        if use-column[11] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, "eff-prc",                   temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.*/
  /*      if RADIO-AltObj > 1     then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "alt-ost"                  , temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.*/

        assign
          null-ostat1  = yes
          null-oborot1 = yes
          NullStr1     = 0
        .

        for each temp-sum where temp-sum.level = -2 and ( temp-sum.doc-type = "ost-beg" or temp-sum.doc-type = "ost-end" ) :
          if temp-sum.sum <> 0 then do:
            assign null-ostat1 = no .
            leave.
          end.
        end.
        for each temp-sum  where temp-sum.level = -2 and temp-sum.doc-type <> "ost-beg"  and temp-sum.doc-type <> "ost-end" :
          if temp-sum.sum <> 0 then do:
            assign null-oborot1 = no .
            leave.
          end.
        end.

/*        if null-oborot1 = yes then do:*/
/*          if null-ostat1 = yes then do:*/
/*            if ShowZero-2 = no then NullStr1 = 1 . /* остатки не 0, а оборот 0, суммируем, но не показываем если "ненулевый остатки" */*/
/*          end.*/
/*          else do:*/
/*            NullStr1 = 2 . /* все 0  */*/
/*          end.*/
/*        end.*/

        if ShowZero = no and ShowZero-2 = no then do: /* ненулевые остатки и обороты */
          if null-oborot1 = yes then do:
            if null-ostat1 = yes then NullStr1 = 2 .
            else                      NullStr1 = 1 .
          end.
          else NullStr1 = 0 .
        end.
        if ShowZero = yes and ShowZero-2 = no then do: /* нулевые остатки и ненулевые обороты */
          if null-oborot1 = yes then do:
            if null-ostat1 = yes then NullStr1 = 2 .
            else                      NullStr1 = 1 .
          end.
          else do:
            if null-ostat1 = yes then NullStr1 = 2 .
            else                      NullStr1 = 0 .
          end.
        end.
        if ShowZero = no and ShowZero-2 = yes then do: /* ненулевые остатки и нулевые обороты */
          if null-oborot1 = yes then do:
            if null-ostat1 = yes then NullStr1 = 2 .
            else                      NullStr1 = 0 .
          end.
          else NullStr1 = 0 .
        end.
        if NullStr1 > 0 then next .
        assign
          v-col = 1
          beg   = 1
        .
        if ExportZUM then do:
          if tog-obj = true then do: /* раздельно по объектам */
            put stream txt-file
              gds-prop.obj-type format "X(5)"   {&tabulation}
              gds-prop.obj-code format ">>>>>>>9" {&tabulation}
              gds-prop.obj-name format "X(50)"   {&tabulation}
            .
          end.
          put stream txt-file
            gds-prop.grp-name format "X(70)"  {&tabulation}
            gds-prop.prod-type format "X(5)"   {&tabulation}
            gds-prop.prod-code format ">>>>>>>>>>>9" {&tabulation}
            gds-prop.prod-name format "X(50)"  {&tabulation}
          .
        end.

        if use-column[1]  = yes then do:
          put stream outstream  "|" at beg temp-prt.b-code format ">>>>>>>>>>>>9" .
          if ExportZUM then put stream txt-file  temp-prt.b-code format ">>>>>>>>>>>>9" {&tabulation} .
          run macr_excel_char (string(temp-prt.b-code), v-row, v-col) .
          assign v-col = v-col + 1    beg = beg + 14 .
        end.
        if use-column[2]  = yes then do:
           if ExportZUM then put stream txt-file gds-prop.artic format "X(16)" {&tabulation} .
           assign v-col = v-col + 1    beg = beg + 17 .
        end.
        FIND FIRST gds-prt WHERE gds-prt.node-code  = temp-prt.prt-code NO-LOCK no-error .
        if use-column[3]  = yes then do:

          put stream outstream  "|" at beg '  /'+ gds-prt.f-name format "X(40)" .
          run macr_excel_char ('  /'+ gds-prt.f-name, v-row, v-col) .
          if ExportZUM then put stream txt-file  gds-prop.gds-name format "X(40)" {&tabulation} .
          assign v-col = v-col + 1    beg = beg + 41 .
        end.
        if ExportZUM then put stream txt-file  ' /'+ gds-prt.f-name format "X(60)" {&tabulation} .
        if use-column[4]  = yes then do:
          put stream outstream  "|" at beg gds-prop.unit-base format "X(4)" .
          if ExportZUM then put stream txt-file  gds-prop.unit-base format "X(4)" {&tabulation} .
          run macr_excel_char (gds-prop.unit-base, v-row, v-col) .
          assign v-col = v-col + 1    beg = beg + 5 .
        end.
        if use-column[5]  = yes then do:
          if ExportZUM then put stream txt-file UNFORMATTED  replace(string(gds-prop.Cost-Price,frm-sum1),".",",")  {&tabulation} .
  /*      put stream outstream  "|" at beg gds-prop.Cost-Price format ">>>,>>>,>>9.99" .*/
  /*      run macr_excel_sum  ( gds-prop.Cost-Price, v-row, v-col, 2) .*/
          assign v-col = v-col + 1    beg = beg + 15 .
        end.
        if use-column[6]  = yes then do:
          if prod-zen = yes then do:
            if ExportZUM then put stream txt-file UNFORMATTED  replace(string(gds-prop.Avrg-Sale-Price,frm-sum1),".",",")  {&tabulation} .
          end.
          else do:
            if ExportZUM then put stream txt-file UNFORMATTED  replace(string(gds-prop.Last-Sale-Price,frm-sum1),".",",")  {&tabulation} .
          end.
  /*      if prod-zen = yes then do:*/
  /*        put stream outstream  "|" at beg gds-prop.Avrg-Sale-Price format ">>>,>>>,>>9.99" .*/
  /*        run macr_excel_sum  ( gds-prop.Avrg-Sale-Price, v-row, v-col, 2) .*/
  /*      end.*/
  /*      else do:*/
  /*        put stream outstream  "|" at beg gds-prop.Last-Sale-Price format ">>>,>>>,>>9.99" .*/
  /*        run macr_excel_sum  ( gds-prop.Last-Sale-Price, v-row, v-col, 2) .*/
  /*      end.*/
          assign v-col = v-col + 1    beg = beg + 15 .
        end.
        if use-column[7]  = yes then do:
          if ExportZUM then put stream txt-file UNFORMATTED  replace(string(gds-prop.Up-Plan,frm-sum1),".",",")  {&tabulation} .
/*      put stream outstream  "|" at beg gds-prop.Up-Plan format "->>,>>>,>>9.99" .*/
/*      run macr_excel_sum  ( gds-prop.Up-Plan, v-row, v-col, 2) .*/
          assign v-col = v-col + 1    beg = beg + 15 .
        end.
        if use-column[8]  = yes then do:
          if ExportZUM then put stream txt-file gds-prop.LastPer-Date format "99/99/9999"   {&tabulation} .
  /*      if gds-prop.LastPer-Date <> ? then do:*/
  /*        put stream outstream  "|" at beg gds-prop.LastPer-Date format "99/99/9999" .*/
  /*        run macr_excel_char (string(gds-prop.LastPer-Date,"99.99.9999"), v-row, v-col) .*/
  /*      end.*/
          assign v-col = v-col + 1    beg = beg + 11 .
        end.
        if use-column[9]  = yes then do:
          if ExportZUM then put stream txt-file gds-prop.LastPer-Num format "X(10)" {&tabulation} .
  /*      put stream outstream  "|" at beg gds-prop.LastPer-Num format "X(10)" .*/
  /*      run macr_excel_char (gds-prop.LastPer-Num, v-row, v-col) .*/
          assign v-col = v-col + 1    beg = beg + 11 .
        end.

        for each temp-sum where temp-sum.level = -2 :
          case temp-sum.sum-type :
            when 0 then do:
              put stream outstream  "|" at beg temp-sum.sum format frm-qnty  .
              if ExportZUM then put stream txt-file UNFORMATTED  replace(string(temp-sum.sum,frm-qnty1),".",",") {&tabulation} .
              run macr_excel_sum (temp-sum.sum, v-row, v-col, sz-qnty) .
              assign  beg = beg + 15 .
            end.
            when  2 then do:
              put stream outstream  "|" at beg temp-sum.sum format frm-sum .
              if ExportZUM then put stream txt-file UNFORMATTED  replace(string(temp-sum.sum,frm-sum1),".",",")  {&tabulation} .
              run macr_excel_sum (temp-sum.sum, v-row, v-col, 2) .
              assign  beg = beg + 15 .
            end.
            when 1 or when 3 then do:
              if ExportZUM then put stream txt-file  {&tabulation} .
              put stream outstream  "|" at beg .
              assign  beg = beg + 15 .
            end.
            when 4 then do:
              if ExportZUM then put stream txt-file  {&tabulation} .
              put stream outstream  "|" at beg .
              assign  beg = beg + 10 .
            end.
  /*          when 4 then do:*/
  /*            put stream outstream  "|" at beg temp-sum.sum format frm-prc .*/
  /*            run macr_excel_sum (temp-sum.sum, v-row, v-col, 2) .*/
  /*            assign  beg = beg + 10 .*/
  /*          end.*/
          end.
          assign v-col = v-col + 1 .
        end.
        put stream outstream   "|"  skip .
        if ExportZUM then put stream txt-file  {&new-line} .
        assign v-row = v-row + 1 .

      end.
    end.
  end.

end procedure. /* PrintScale */


procedure GetBegSum :
  do on error undo, return error return-value :
    define input  parameter p-find as character no-undo .
    define output parameter p-sum as decimal   no-undo .
    define buffer buf_stk-line for stk-line.

    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.sum-type  = p-find
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .
    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then assign p-sum = buf_stk-line.sum-rubl .
      else                        assign p-sum = buf_stk-line.sum-base .
    end.
  end.
end procedure. /* GetBegSum */

procedure GetEndSum :
  do on error undo, return error return-value :
    define input  parameter p-find as character no-undo .
    define output parameter p-sum as decimal   no-undo .
    define buffer buf_stk-line for stk-line.

    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.sum-type  = p-find
        and buf_stk-line.fact-order < v-fact-order-end
      use-index category no-error .
    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then assign p-sum = buf_stk-line.sum-rubl .
      else                        assign p-sum = buf_stk-line.sum-base .
    end.
  end.
end procedure. /* GetBegSum */

/* $Workfile$   E n d */