block-level on error undo, throw.
/*

$Revision: 3a62839ff969, 963, rls $
$Author: EShklyar $
$Date: Thu Feb 16 15:20:37 2017 +0300 $
$Workfile: r-obort1.p $
$Archive: rep/r-obort1.p $

Старая оборотная ведомость

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/27/06
Author: Michael Kochetkov
Creation date: 03/27/06

obr-defv.i - описания используемых temp-table
obr-k-1.i  - выборка товаров
obr-k-2.i  - считаем остатки на начало и конец периода (вызов из CalcOstatki)
obr-k-3.i  - считаем оборот за период (вызов из CalcOborot)
obr-k-4.i  -  печать заголовков колонок для excel и созд temp-table для заголов. принтера
    PutColumnTitulExcel  печать заголовков колонок для excel
    PrintTitul           созд temp-table для заголов. принтера
obr-k-5.i  -  набор используемых процедур
    CalcOstatki остатки на начало и конец периода
    CalcOborot  считаем оборот за период
    CheckNullOborot - проверка на 0
    PutColumnTitul -печать заголовков для принтера
    PutItogSum      вывод сумм
    CalculSum       расчет сумм
    Create-gds-sum  создание-обнуление temp-table для сумм
    PrintLine       вывод строки
    PutTitul        печать подразделов
obr-k-6.i  - вывод строки (вызов из PrintLine)
obr-k-7.i  - создание-обнуление temp-table для сумм (вызов из Create-gds-sum)
obr-k-8.i  - вывод итоговых сумм (вызов из PutItogSum)
obr-k-9.i  - расчет итоговых сумм (вызов из CalculSum)
obr-k-10.i - перебор данных в цикле в зависим от классиф
obr-k-11.i - расчет таблички с партиями
obr-k-12.i - печать строки таблички с партиями
obr-k-13.i - расчет таблички с партиями (новая запись)

*/

define input parameter ShowZero          as logical   no-undo .
define input parameter ShowZero-2        as logical   no-undo .
define input parameter RADIO-Nomenkl     as integer   no-undo .
define input parameter Tog-obj           as logical   no-undo .
define input parameter Classify          as character no-undo .
define input parameter RADIO-AltObj      as integer   no-undo .
define input parameter AltObj-list       as character no-undo .
define input parameter SortType          as character no-undo .
define input parameter prod-zen          as logical   no-undo .
define input parameter print-o           as character no-undo .
define input parameter SumsOnly          as logical   no-undo .
define input parameter tog-lavel         as logical   no-undo .
define input parameter var-lavel         as integer   no-undo .
define input parameter tog-tree          as logical   no-undo .
define input parameter name-tov          as integer   no-undo .
define input parameter no-nds            as logical   no-undo .
define input parameter ExportZUM         as logical   no-undo .
define input parameter sz-qnty           as integer   no-undo .
define input parameter sys-key           as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: 3a62839ff969, 963, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Thu Feb 16 15:20:37 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-obort1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-obort1.p $":U .
define variable vss-description as character no-undo init "Старая оборотная ведомость".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ ref/grplib.i   }
{ cmp/r-pril.i   }
{ rep/f-fdec.i   }
{ gbl/paramls.i  }
{ rep/obr-defv.i }
{ rep/rep-bt.i   }
{ str/clcprtsl.i }
define variable g#host-code as integer   no-undo .
assign g#host-code = v-cntxt-host-code-obj .


do
on error undo, return error
:

define variable var-client   as character initial "" no-undo .
define variable var-client1  as character initial "" no-undo .
define variable Line         as character no-undo .
define variable line1        as character no-undo .
define variable ItogStr      as character initial "" no-undo .
define variable titul        as integer initial 0  no-undo .
define variable NullStr      as integer initial 0  no-undo .
define variable CurrGrpName  as character no-undo .
define variable beg          as integer   no-undo .
define variable ii           as integer   no-undo .
define variable jj           as integer   no-undo .
define variable v-NameString as character no-undo .
define variable frmt         as character no-undo .
define variable LastGroup    as character initial "" no-undo .
define variable lvel         as integer initial 0 no-undo .
define variable old-lvel     as integer initial 0 no-undo .
define variable ind          as integer   no-undo .
define variable ij           as integer   no-undo .
define variable ObS          as integer initial 1  no-undo .
define variable vvv1         as decimal   no-undo .
define variable vvv2         as decimal   no-undo .
define variable v-qntyp      as decimal   no-undo .

  define variable frm-qnty1 as character no-undo .
  define variable frm-sum1  as character no-undo .
  if sz-qnty = 3 then assign frm-qnty1 = "->>>>>>>>9.999" .
  else                       frm-qnty1 = "->>>>>>>>>>>9" .
  assign frm-sum1 = "->>>>>>>>>9.99" .
  define Stream OutStream.
  def stream txt-file.                             /* файл для экспорта ЦУМ  */

  /* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1 */
  define stream macr_excel .
  define variable v-row       as integer   no-undo .
  define variable v-col       as integer   no-undo .
  define variable v-ind       as integer   no-undo initial 1 .
  define variable v-file-name as character no-undo .
  /* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1 */

  run rep/r-obrt11.p
                 ( input RADIO-Nomenkl
                 , input Tog-obj
                 , input name-tov
                 , input no-nds
                 , input RADIO-AltObj
                 , input AltObj-list
                 , input sys-key
                 , input prod-zen
                 , input ShowZero
                 , input ShowZero-2
                 , input-output table gds-prop
                 , input-output table o_temp-parts) .

  { gbl/working.i }
  /* macr_excel - для экселя */
  assign
    make-excel = yes
    v-file-name = string(session :temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt"
  .
  output stream macr_excel to value(v-file-name) .
  assign v-ind = v-ind + 1 .
  /* все остальное */
  case print-o :
    when "A3-lansc":U then { cmp/open-out.i stream OutStream " " {&CS_PS} }
    when "A4-lansc":U then { cmp/open-out.i stream OutStream " " {&LS_PS_A4} }
    when "A4-port":U  then { cmp/open-out.i stream OutStream " " {&CS_PS} }
    when "to-file":U  then { cmp/open-out.i stream OutStream " " {&CS_PS} }
  end case .

  /* *******************************************************  */
  run PrintTitul in this-procedure . /* проверка колонок и заполнение шапок */
  /* *******************************************************  */

  run PutColumnTitul in this-procedure .
  run PutColumnTitulExcel in this-procedure .

  if ExportZUM then do:
    output stream txt-file to value(string(session :temp-directory) + "rpz" + string( g#report-num ) + ".txt").
    run rep/r-ob2-ex.p (input tog-obj,input RADIO-AltObj,input no, output CurrGrpName) .
    put stream txt-file ReportNAme format "X(80)"  {&new-line} .
    define variable ss1 as character no-undo .
    assign  ss1 = 'X(' + string(length (CurrGrpName)) + ')' .
    put stream txt-file CurrGrpName format ss1 {&new-line} .
  end.

  for each gds-sum :
    delete gds-sum .
  end.
  create gds-sum .
  assign gds-sum.num = 1 . /* это будет сумма итогоЭ */

  case classify:
    when "no-classify":u    then do:
      run foreach1 in this-procedure.    /* Без классификации */
    end.
    when "prod":u then do:
      Run Foreach2 in this-procedure.    /* По производителю */
    end.
    when "grp-goods":u then do:
      Run Foreach3 in this-procedure.    /* по группам */
    end.
    when "prod/grp-goods":u then do:
      Run Foreach4 in this-procedure.    /* Производители/Группы товаров */
    end.
    when "grp-goods/prod":u then do:
      Run Foreach5 in this-procedure.    /* Группы товаров/Производители */
    end.
    when "vat-ps":u then do:
      Run Foreach6 in this-procedure.    /* Ставка НДС */
    end.
  end case.

  if ExportZUM then do:
    output stream txt-file close.
  end.

  output stream macr_excel close .
  run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name) .

  HIDE stream OutStream FRAME BottomFrame .
  OUTPUT stream OutStream CLOSE.

  run end-proc .
  { gbl/stopwork.i }
  define variable disop as integer   no-undo .
  case print-o :
    when "A3-lansc":U then assign disop = 8.
    when "A4-lansc":U then assign disop = 8.
    when "A4-port":U then  assign disop = 0.
    when "to-file":U then do:
      if beg > 550 then assign disop = 3. /* только в файл */
      else              assign disop = 1.
    end.
  end.
  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .
  if sys-key = "parts" then do:
     run rep/runexcel.p (string( session:temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt").
  end.
  else do:
    run gbl/prnfilen.w
      (input  ""
      ,input  disop
      ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
      ,input 7
      ,output v-user-action
      ,output v-printed
      ) .
  end.
end.

procedure end-proc :
 do
 on error undo, return error return-value
 :

  v-file-name = ( string( session:temp-directory + {&DF_Name} + string( g#report-num ) ) + ".t-t").

  OUTPUT to VALUE (v-file-name) .
  for each temp-param :
    export  temp-param  .
  end.

 end. /* do */
end procedure. /* end-proc */


 { rep/obr-k-4.i } /* печать заголовков колонок */

 { rep/obr-k-5.i } /* набор используемых процедур */


PROCEDURE foreach1 :  /*  Без классификации */
  if tog-obj = true then do: /* раздельно по объектам */
    for each obj-list no-lock :
      assign  titul = 0 .

      run Create-gds-sum in this-procedure (2) .

      if SortType = "sort-code":U then do:
        for each gds-prop
          where gds-prop.obj-type = obj-list.obj-type
            and gds-prop.obj-code = obj-list.obj-code
             by gds-prop.b-code :

          run CheckNullOborot in this-procedure .
          if NullStr < 1 then do:    /* проверка на не 0        */
              run PutTitul in this-procedure .  /* вывод шапок */
              run PrintLine in this-procedure .     /* вывод данных            */
            run CalculSum in this-procedure (2) . /* суммирование по объекту */
            run CalculSum in this-procedure (1) . /* суммирование всего      */
          end.
        End. /*for each gds-prop */

                run PutItogSum in this-procedure (2) .  /* вывод сумм */

      end.
      else do:
        for each gds-prop
          where gds-prop.obj-type = obj-list.obj-type
            and gds-prop.obj-code = obj-list.obj-code
             by gds-prop.artic :
          run CheckNullOborot in this-procedure .
          if NullStr < 1 then do:    /* проверка на не 0        */

              run PutTitul in this-procedure .  /* вывод шапок */
              run PrintLine in this-procedure .     /* вывод данных            */

            run CalculSum in this-procedure (2) . /* суммирование по объекту */
            run CalculSum in this-procedure (1) . /* суммирование всего */
          end.
        End. /*for each gds-prop */

        run PutItogSum in this-procedure (2) .  /* вывод сумм */
      end.
      end. /* OBJ-LIST */
  end.
  else do:
    if SortType = "sort-code":U then do:
      for each gds-prop
        by gds-prop.b-code :
        run CheckNullOborot in this-procedure .
        if NullStr < 1 then do:    /* проверка на не 0        */
          run PrintLine in this-procedure .     /* вывод данных            */
          run CalculSum in this-procedure (1) . /* суммирование всего      */
        end.
      End. /*for each gds-prop */
    end.
    else do:
      for each gds-prop
           by gds-prop.artic :
        run CheckNullOborot in this-procedure .
        if NullStr < 1 then do:    /* проверка на не 0        */
          run PrintLine in this-procedure .     /* вывод данных            */
          run CalculSum in this-procedure (1) . /* суммирование всего */
        end.
      End. /*for each gds-prop */
    end.
  end.
  run PutItogSum in this-procedure (1) .  /* вывод сумм */
END PROCEDURE.


PROCEDURE foreach2 :  /*  производителю  */
  if tog-obj = true then do: /* раздельно по объектам */
    for each obj-list no-lock :
      assign  titul = 0 .

      run Create-gds-sum in this-procedure (2) .

      if SortType = "sort-code":U then do:
        for each gds-prop
          where gds-prop.obj-type = obj-list.obj-type
            and gds-prop.obj-code = obj-list.obj-code
          break by gds-prop.prod-name
                by gds-prop.b-code :
          { rep/obr-k-10.i fe1 }
        End. /*for each gds-prop */
        run PutItogSum in this-procedure (2).  /* вывод сумм */
      end.
      else do:
        for each gds-prop
          where gds-prop.obj-type = obj-list.obj-type
            and gds-prop.obj-code = obj-list.obj-code
       break by gds-prop.prod-name
             by gds-prop.artic :
          { rep/obr-k-10.i fe1 }
        End. /*for each gds-prop */
        run PutItogSum in this-procedure (2) .  /* вывод сумм */
      end.
    end. /* OBJ-LIST */
  end.
  else do:
    if SortType = "sort-code":U then do:
      for each gds-prop
        break by gds-prop.prod-name
              by gds-prop.b-code :
        { rep/obr-k-10.i fe1 }
      End. /*for each gds-prop */
    end.
    else do:
      for each gds-prop
     break by gds-prop.prod-name
           by gds-prop.artic :
        { rep/obr-k-10.i fe1 }
      End. /*for each gds-prop */
    end.
  end.

  run PutItogSum in this-procedure (1) .  /* вывод сумм */

END PROCEDURE.


PROCEDURE foreach3 :  /*  по группам  */
  if tog-obj = true then do: /* раздельно по объектам */
    for each obj-list no-lock :
      assign
        LastGroup   = ""
        CurrGrpName = ""
        titul       = 0
      .
      run Create-gds-sum in this-procedure (2) .
      if SortType = "sort-code":U then do:
        for each gds-prop
          where gds-prop.obj-type = obj-list.obj-type
            and gds-prop.obj-code = obj-list.obj-code
          break by gds-prop.grp-name
                by gds-prop.b-code :
          { rep/obr-k-10.i fe2 }
        End. /*for each gds-prop */
      end.
      else do:
        for each gds-prop
          where gds-prop.obj-type = obj-list.obj-type
            and gds-prop.obj-code = obj-list.obj-code
          break by gds-prop.grp-name
                by gds-prop.artic :
          { rep/obr-k-10.i fe2 }
        End. /*for each gds-prop */
      end.
      if tog-lavel = yes then do:
        if tog-tree = yes then do:
          do ij = old-lvel to ind by -1 : /* удаляем старые заголовки из списка */
/*          do ij = 1 to old-lvel : /* удаляем старые заголовки из списка */*/
            find first tt-grp-tree
              where tt-grp-tree.num = (ij + 3) .
            assign ItogStr = "" .
            do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
            assign ItogStr = ItogStr + tt-grp-tree.name .
            if ij <= var-lavel then do:
              run PutItogSum in this-procedure (tt-grp-tree.num) .  /* вывод сумм */
            end.
            delete tt-grp-tree .
          end.
          assign
            old-lvel = 0
          .
        end.
        else do:
          if LastGroup <> "" then do:
            assign ItogStr = "Итого по " + LastGroup + ":"   .
            run PutItogSum in this-procedure (3) .  /* вывод сумм */
          end.
        end.
      end.
      run PutItogSum in this-procedure (2) .  /* вывод сумм */
    end. /* OBJ-LIST */
  end.
  else do:
    assign
      LastGroup   = ""
      CurrGrpName = ""
      titul       = 0
    .
    if SortType = "sort-code":U then do:
      for each gds-prop
        break by gds-prop.grp-name
              by gds-prop.b-code :
        { rep/obr-k-10.i fe2 }
      End. /*for each gds-prop */
    end.
    else do:
      for each gds-prop
        break by gds-prop.grp-name
              by gds-prop.artic :
        { rep/obr-k-10.i fe2 }
      End. /*for each gds-prop */
    end.
    if tog-lavel = yes then do:
      if tog-tree = yes then do:
          do ij = old-lvel to ind by -1 : /* удаляем старые заголовки из списка */
/*          do ij = ind to old-lvel : /* удаляем старые заголовки из списка */*/
            find first tt-grp-tree
              where tt-grp-tree.num = (ij + 3) .
            assign ItogStr = "" .
            do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
            assign ItogStr = ItogStr + tt-grp-tree.name .
            if ij <= var-lavel then do:
              run PutItogSum in this-procedure (tt-grp-tree.num) .  /* вывод сумм */
            end.
            delete tt-grp-tree .
          end.
      end.
      else do:
        if LastGroup <> "" then do:
          assign ItogStr = "Итого по " + LastGroup + ":"   .
          run PutItogSum in this-procedure (3) .  /* вывод сумм */
        end.
      end.
    end.
  end.
  run PutItogSum in this-procedure (1) .  /* вывод сумм */

END PROCEDURE.


PROCEDURE foreach4 :  /*  по производителям и по группам  */
  if tog-obj = true then do: /* раздельно по объектам */
    for each obj-list no-lock :
      assign  titul = 0 .
      run Create-gds-sum in this-procedure (2) .
      if SortType = "sort-code":U then do:
        for each gds-prop
          where gds-prop.obj-type = obj-list.obj-type
            and gds-prop.obj-code = obj-list.obj-code
          break by gds-prop.prod-name
                by gds-prop.grp-code
                by gds-prop.b-code :
          { rep/obr-k-10.i fe3 }
        End. /*for each gds-prop */

        run PutItogSum in this-procedure (2) .  /* вывод сумм */
      end.
      else do:
        for each gds-prop
          where gds-prop.obj-type = obj-list.obj-type
            and gds-prop.obj-code = obj-list.obj-code
          break by gds-prop.prod-name
                by gds-prop.grp-code
                by gds-prop.artic :
          { rep/obr-k-10.i fe3 }
        End. /*for each gds-prop */
        run PutItogSum in this-procedure (2) .  /* вывод сумм */
      end.
    end. /* OBJ-LIST */
  end.
  else do:
    if SortType = "sort-code":U then do:
      for each gds-prop
        break by gds-prop.prod-name
              by gds-prop.grp-code
              by gds-prop.b-code :
        { rep/obr-k-10.i fe3 }
      End. /*for each gds-prop */
    end.
    else do:
      for each gds-prop
        break by gds-prop.prod-name
              by gds-prop.grp-code
              by gds-prop.artic :
        { rep/obr-k-10.i fe3 }
      End. /*for each gds-prop */
    end.
  end.
  run PutItogSum in this-procedure (1) .  /* вывод сумм */

END PROCEDURE.


PROCEDURE foreach5 :  /* по группам и по производителям */
  if tog-obj = true then do: /* раздельно по объектам */
    for each obj-list no-lock :
      assign  titul = 0 .
      run Create-gds-sum in this-procedure (2) .
      if SortType = "sort-code":U then do:
        for each gds-prop
          where gds-prop.obj-type = obj-list.obj-type
            and gds-prop.obj-code = obj-list.obj-code
          break by gds-prop.grp-code
                by gds-prop.prod-name
                by gds-prop.b-code :
          { rep/obr-k-10.i fe4 }
        End. /*for each gds-prop */
        run PutItogSum in this-procedure (2) .  /* вывод сумм */
      end.
      else do:
        for each gds-prop
          where gds-prop.obj-type = obj-list.obj-type
            and gds-prop.obj-code = obj-list.obj-code
          break by gds-prop.grp-code
                by gds-prop.prod-name
                by gds-prop.artic :
          { rep/obr-k-10.i fe4 }
        End. /*for each gds-prop */
        run PutItogSum in this-procedure (2) .  /* вывод сумм */
      end.
    end. /* OBJ-LIST */
  end.
  else do:
    if SortType = "sort-code":U then do:
      for each gds-prop
        break by gds-prop.grp-code
              by gds-prop.prod-name
              by gds-prop.b-code :
        { rep/obr-k-10.i fe4 }
      End. /*for each gds-prop */
    end.
    else do:
      for each gds-prop
        break by gds-prop.grp-code
              by gds-prop.prod-name
              by gds-prop.artic :
        { rep/obr-k-10.i fe4 }
      End. /*for each gds-prop */
    end.
  end.
  run PutItogSum in this-procedure (1) .  /* вывод сумм */

END PROCEDURE.


PROCEDURE foreach6 :  /* по НДС */
  if tog-obj = true then do: /* раздельно по объектам */
    for each obj-list no-lock :
      assign  titul = 0 .
      run Create-gds-sum in this-procedure (2) .

      if SortType = "sort-code":U then do:
        for each gds-prop
          where gds-prop.obj-type = obj-list.obj-type
            and gds-prop.obj-code = obj-list.obj-code
          break by gds-prop.vat-pc
                by gds-prop.b-code :
          { rep/obr-k-10.i fe5 }
        End. /*for each gds-prop */
        run PutItogSum in this-procedure (2).  /* вывод сумм */
      end.
      else do:
        for each gds-prop
          where gds-prop.obj-type = obj-list.obj-type
            and gds-prop.obj-code = obj-list.obj-code
          break by gds-prop.vat-pc
                by gds-prop.artic :
          { rep/obr-k-10.i fe5 }
        End. /*for each gds-prop */
        run PutItogSum in this-procedure (2) .  /* вывод сумм */
      end.
    end. /* OBJ-LIST */
  end.
  else do:
    if SortType = "sort-code":U then do:
      for each gds-prop
        break by gds-prop.vat-pc
              by gds-prop.b-code :
        { rep/obr-k-10.i fe5 }
      End. /*for each gds-prop */
    end.
    else do:
      for each gds-prop
        break by gds-prop.vat-pc
              by gds-prop.artic :
        { rep/obr-k-10.i fe5 }
      End. /*for each gds-prop */
    end.
  end.
  run PutItogSum in this-procedure (1) .  /* вывод сумм */
END PROCEDURE.

procedure PrintParts :
define input  parameter p-artic     as character no-undo .
define input  parameter p-prod-type as character no-undo .
define input  parameter p-prod-code as integer   no-undo .
define input  parameter p-obj-type  as character no-undo .
define input  parameter p-obj-code  as integer   no-undo .
  do
  on error undo, return error return-value
  :
  for each o_temp-parts where
           o_temp-parts.artic     = p-artic        and
           o_temp-parts.prod-type = p-prod-type    and
           o_temp-parts.prod-code = p-prod-code    and
           o_temp-parts.obj-type  = p-obj-type     and
           o_temp-parts.obj-code  = p-obj-code      by o_temp-parts.fact-date by  o_temp-parts.b-code :
       { rep/obr-k-12.i }

  end.
  end.
end procedure. /* PrintParts */