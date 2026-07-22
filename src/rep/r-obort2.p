block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-obort2.p $
$Archive: rep/r-obort2.p $

Старая оборотка с признак

Автор: Кочетков Михаил Юрьевич
Дата создания: 09/07/05
Author: Michael Kochetkov
Creation date: 09/07/05

список заюзанных файлов:
obr-k2-1.i  - выборка товаров
obr-k2-2.i  - считаем остатки на начало и конец периода (вызов из CalcOstatki)
obr-k2-3.i  - считаем оборот за период (вызов из CalcOborot)
r-obrt21.p -  печать заголовков колонок для excel и принтера (вместо  obr-k2-4.i в вер 11.1 )
    PutColumnTitulExcel  печать заголовков колонок для excel
    PrintTitul           созд temp-table для заголов. принтера
obr-k2-5.i  -  набор используемых процедур
    CalcOstatki остатки на начало и конец периода
    CalcOborot  считаем оборот за период
    PutColumnTitul -печать заголовков для принтера
    PutItogSum      вывод сумм
    CalculSum       расчет сумм
    PrintLine       вывод строки
    PutTitul        печать подразделов
obr-k2-6.i  - вывод строки (вызов из PrintLine)
obr-k2-7.i - перебор данных в цикле в зависим от классиф
*/

define input parameter ShowZero           as logical   no-undo .
define input parameter ShowZero-2         as logical   no-undo .
define input parameter RADIO-Nomenkl      as integer   no-undo .
define input parameter Tog-obj            as logical   no-undo .
define input parameter Classify           as character no-undo .
define input parameter RADIO-AltObj       as integer   no-undo .
define input parameter AltObj-list        as character no-undo .
define input parameter SortType           as character no-undo .
define input parameter prod-zen           as logical   no-undo .
define input parameter print-o            as character no-undo .
define input parameter SumsOnly           as logical   no-undo .
define input parameter tog-lavel          as logical   no-undo .
define input parameter var-lavel          as integer   no-undo .
define input parameter tog-tree           as logical   no-undo .
define input parameter name-tov           as integer   no-undo .
define input parameter start-sum          as integer   no-undo .
define input parameter end-sum            as integer   no-undo .
define input parameter frm-qnty           as character no-undo .
define input parameter sz-qnty            as integer   no-undo .
define input parameter v-fact-order-start as decimal   no-undo .
define input parameter v-fact-order-end   as decimal   no-undo .
define input parameter SumsOnly2          as logical   no-undo .
define input parameter ExportZUM          as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-obort2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-obort2.p $":U .
define variable vss-description as character no-undo init "Старая оборотка с признак".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ ref/grplibfn.i }
{ gbl/paramls.i  }
{ rep/r-cost.i   }
{ rep/r-sale.i   }
{ cmp/r-pril.i   }
/*  { rep/f-fdec.i }   /* Функции для форматирования полей для передачи в EXcel         */*/
{ trg/prdoclib.i }
{ cmp/library.i  }
{ str/prl-vat.i  }
{ rep/rep-bt.i   }

do
on error undo, return error
:
define variable g#host-code as integer   no-undo .
assign g#host-code = v-cntxt-host-code-obj .


&Scop Sort-pole  if SortType = "sort-code":U   then  gds-prop.b-code Else  gds-prop.artic

  DEFINE temp-table gds-prop no-undo
    field   Avrg-Sale-Price  as decimal
    field   Up-Plan          as  decimal
    field   Cost-Price       as  decimal
    field   Last-Sale-Price  as decimal
    field   LastPer-Date     as  date
    field   LastPer-Num      as  char
    field   obj-type         as  char
    field   obj-code         as  integer
    field   obj-name         as  char
    field   prod-type        as  char
    field   prod-code        as  integer
    field   prod-name        as  char
    field   artic            as  char
    field   gds-code         as  integer
    field   gds-name         as  char
    field   gds-name1        as  char
    field   grp-name         as  char
    field   unit-base        as  char
    field   b-code           as  char
    field   empty-scale      as  logical
    field   grp-code         as  integer
    field   vat-pc           as  decimal
    INDEX pi  IS PRIMARY   obj-type obj-code artic  prod-type prod-code
    INDEX pi1              obj-type obj-code b-code prod-type prod-code
    INDEX pi2              obj-type obj-code gds-code
    INDEX pi3              prod-name
    INDEX pi4              grp-code
    INDEX pi5              vat-pc
 .

  DEFINE temp-table temp-prt no-undo
    field   obj-type         as  char
    field   obj-code         as  integer
    field   prt-code         as  integer
    field   gds-code         as  integer
    field   sum              as  decimal
    field   doc-type         as  character
    field   sum-type         as  integer
    field   b-code           as  integer
    INDEX pi  IS PRIMARY   obj-type obj-code gds-code prt-code
    INDEX pi1              doc-type sum-type
  .

  DEFINE temp-table temp-sum no-undo
    field   num              as  integer
    field   sum              as  decimal
    field   doc-type         as  character
    field   sum-type         as  integer
    field   level            as  integer
    INDEX pi  IS PRIMARY   level num
    INDEX pi1              doc-type
  .

  DEFINE temp-table tt-grp-tree no-undo
    field  num          as  integer
    field  full         as character
    field  name         as character
    INDEX pi  IS PRIMARY unique full
    INDEX pi1 num
  .

  define buffer buf_goods    for goods.
  define buffer buf_clients  for clients.
  define buffer buf1_clients for clients.
  define buffer buf2_clients for clients.
  define buffer buf_gds-obj  for gds-obj.
  define buffer buf_doc-line for doc-line.
  define buffer b_obj-list for obj-list.

  define variable Counter1     as integer   no-undo .
  define variable var-client   as character initial "" no-undo .
  define variable var-client1  as character initial "" no-undo .
  define variable Line         as character no-undo .
  define variable ItogStr      as character initial "" no-undo .
  define variable titul        as integer initial 0  no-undo .
  define variable NullStr      as integer initial 0  no-undo .
  define variable CurrGrpName  as character no-undo .
  define variable beg          as integer   no-undo .
  define variable ii           as integer   no-undo .
  define variable jj           as integer   no-undo .
  define variable frmt         as character no-undo .
  define variable LastGroup    as character initial "" no-undo .
  define variable lvel        as integer initial 0 no-undo .
  define variable old-lvel    as integer initial 0 no-undo .
  define variable ind          as integer   no-undo .
  define variable ij           as integer   no-undo .
  define variable line1         as character no-undo .
  define variable v-root-node   as integer   no-undo .
  define variable is-prn-titul  as logical initial no  no-undo .
  define variable p-num       as integer   no-undo .

  define variable start-col as integer initial 0  no-undo .
  define variable frm-sum  as character initial "->>,>>>,>>9.99" no-undo .
  define variable frm-prc  as character initial "->,>>9.99" no-undo .

  define variable par-dec as character no-undo .
  define variable par-tho as character no-undo .
  run gbl/getexdel.p (output par-dec,output par-tho).

  define variable frm-qnty1 as character no-undo .
  define variable frm-sum1  as character no-undo .
  if sz-qnty = 3 then assign frm-qnty1 = "->>>>>>>>9.999" .
  else                       frm-qnty1 = "->>>>>>>>>>>9" .
  assign frm-sum1 = "->>>>>>>>>9.99" .

  def stream txt-file.                             /* файл для экспорта ЦУМ  */
  define new shared Stream OutStream.
  define new shared stream macr_excel .

  /* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1 */
  define variable v-row       as integer   no-undo .
  define variable v-col       as integer   no-undo .
  define variable v-ind       as integer   no-undo initial 1 .
  define variable v-file-name as character no-undo .
/* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1 */


  assign
    frmt = "X(" + string(end-sum) + ')'
    Line = fill("-", end-sum).
  .

  assign
    Counter1 = 0 .
  .
  { rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */

  for each gds-prop :
    delete gds-prop .
  end.
  if x-SelectGood = {&g-all} then do: /* все товары */
    for each obj-list :
      for each buf_gds-obj no-lock
        where buf_gds-obj.obj-type  = obj-list.obj-type
          and buf_gds-obj.obj-code  = obj-list.obj-code
        :
        { rep/obr-k2-1.i } /* проверка, подходит ли товар и заполнение темп-тейбла */
        run CalcOstatki in this-procedure .
        run CalcOborot  in this-procedure .
      end.
    end.
  end.
  else do:
    for each obj-list :                /* встать на объект */
      case x-SelectGood :
        when {&g-all} then do:
        end.
        when {&g-prod} then do:    /* не все производители */
          for each G#cli : /* встать на производителя */
            for each buf_gds-obj  no-lock
              where buf_gds-obj.obj-type  = obj-list.obj-type
                and buf_gds-obj.obj-code  = obj-list.obj-code
                and buf_gds-obj.prod-type = G#cli.obj-type
                and buf_gds-obj.prod-code = G#cli.obj-code
              use-index pi  :

              { rep/obr-k2-1.i } /* проверка, подходит ли товар и заполнение темп-тейбла */
              run CalcOstatki in this-procedure .
              run CalcOborot  in this-procedure .
            end .
          end.                /* do ... по производителям */
        end .
        when {&g-grp} then do:    /* не все группы товаров */
          for each tmp#grp :
            run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output CurrGrpName ) .

            for each buf_gds-obj no-lock
              where buf_gds-obj.obj-type = obj-list.obj-type
                and buf_gds-obj.obj-code = obj-list.obj-code
                and buf_gds-obj.grp-name begins CurrGrpName
              use-index obj-grp :

              { rep/obr-k2-1.i } /* проверка, подходит ли товар и заполнение темп-тейбла */
              run CalcOstatki in this-procedure .
              run CalcOborot  in this-procedure .

            end .
          end.    /* do i = 1 to num-entries ( gdsgrp_recids ) : */
        end.
        otherwise do:  /* список товаров */
          for each gds-list ,
              each buf_gds-obj no-lock
            where buf_gds-obj.obj-type  = obj-list.obj-type
              and buf_gds-obj.obj-code  = obj-list.obj-code
              and buf_gds-obj.artic     = gds-list.artic
              and buf_gds-obj.prod-type = gds-list.prod-type
              and buf_gds-obj.prod-code = gds-list.prod-code
            :
            { rep/obr-k2-1.i } /* проверка, подходит ли товар и заполнение темп-тейбла */
            run CalcOstatki in this-procedure .
            run CalcOborot  in this-procedure .
          end.
        end.
      end case.
    end.                    /* for each ... по объектам */
  end.

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

/*  run PrintTitul in this-procedure .*/
/*  run PutColumnTitulExcel in this-procedure .*/
  run rep/r-obrt21.p (input 2, input RADIO-AltObj, input end-sum, output ii, output ii   ) .
  run rep/r-obrt21.p (input 1, input RADIO-AltObj, input end-sum, output start-col, output v-row) .

  if ExportZUM then do:
    output stream txt-file to value(string(session :temp-directory) + "rpz" + string( g#report-num ) + ".txt").
    run rep/r-ob2-ex.p (input tog-obj,input RADIO-AltObj,input yes, output CurrGrpName) .
    put stream txt-file ReportNAme format "X(80)"  {&new-line} .
    define variable ss1 as character no-undo .
    assign  ss1 = 'X(' + string(length (CurrGrpName)) + ')' .
    put stream txt-file CurrGrpName format ss1 {&new-line} .
  end.

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

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */

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
  run gbl/prnfilen.w
    (input  ""
    ,input  disop
    ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
    ,input 7
    ,output v-user-action
    ,output v-printed
    ) .

end.


 { rep/obr-k2-5.i } /* набор используемых процедур */


PROCEDURE foreach1 :  /*  Без классификации */
  if tog-obj = true then do: /* раздельно по объектам */
    for each obj-list no-lock :
      assign  titul = 0 .
      for each temp-sum where temp-sum.level = 2 : assign temp-sum.sum = 0 . end.
      for each gds-prop where gds-prop.obj-type = obj-list.obj-type and gds-prop.obj-code = obj-list.obj-code by {&Sort-pole} :
        run PrintLine in this-procedure .     /* вывод данных            */
      End. /*for each gds-prop */
      run PutItogSum in this-procedure (2) .  /* вывод сумм */
    end. /* OBJ-LIST */
  end.
  else do:
    for each gds-prop by {&Sort-pole} :
      run PrintLine in this-procedure .     /* вывод данных            */
    End. /*for each gds-prop */
  end.
  run PutItogSum in this-procedure (1) .  /* вывод сумм */
END PROCEDURE.


PROCEDURE foreach2 :  /*  производителю  */
  if tog-obj = true then do: /* раздельно по объектам */
    for each obj-list no-lock :
      assign  titul = 0 .
      for each temp-sum where temp-sum.level = 2 : assign temp-sum.sum = 0 . end.
      for each gds-prop where gds-prop.obj-type = obj-list.obj-type and gds-prop.obj-code = obj-list.obj-code break by gds-prop.prod-name by {&Sort-pole} :
        { rep/obr-k2-7.i fe1 }
      End. /*for each gds-prop */
      run PutItogSum in this-procedure (2).  /* вывод сумм */
    end. /* OBJ-LIST */
  end.
  else do:
    for each gds-prop break by gds-prop.prod-name by {&Sort-pole} :
      { rep/obr-k2-7.i fe1 }
    End. /*for each gds-prop */
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
      for each temp-sum where temp-sum.level = 2 : assign temp-sum.sum = 0 . end.
      for each gds-prop
        where gds-prop.obj-type = obj-list.obj-type
          and gds-prop.obj-code = obj-list.obj-code
        break by gds-prop.grp-name by {&Sort-pole} :
        { rep/obr-k2-7.i fe2 }
      End. /*for each gds-prop */
      if tog-lavel = yes then do:
        if tog-tree = yes then do:
          do ij = old-lvel to ind by -1 : /* удаляем старые заголовки из списка */
/*          do ij = 1 to old-lvel : /* удаляем старые заголовки из списка */*/
            find first tt-grp-tree where tt-grp-tree.num = (ij + 3) .
            assign ItogStr = "" .
            do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
            assign ItogStr = ItogStr + tt-grp-tree.name .
            if ij <= var-lavel then do:
              run PutItogSum in this-procedure (tt-grp-tree.num) .  /* вывод сумм */
            end.
            delete tt-grp-tree .
          end.
          assign old-lvel = 0 .
        end.
        else do:
          if LastGroup <> "" then do:
            assign ItogStr = "Итог по гр. " + LastGroup + ":"   .
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
    for each gds-prop break by gds-prop.grp-name by {&Sort-pole} :
      { rep/obr-k2-7.i fe2 }
    End. /*for each gds-prop */
    if tog-lavel = yes then do:
      if tog-tree = yes then do:
        do ij = old-lvel to ind by -1 : /* удаляем старые заголовки из списка */
/*        do ij = ind to old-lvel : /* удаляем старые заголовки из списка */*/
          find first tt-grp-tree where tt-grp-tree.num = (ij + 3) .
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
          assign ItogStr = "Итог по гр. " + LastGroup + ":"   .
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
      for each temp-sum where temp-sum.level = 2 : assign temp-sum.sum = 0 . end.
      for each gds-prop
        where gds-prop.obj-type = obj-list.obj-type
          and gds-prop.obj-code = obj-list.obj-code
        break by gds-prop.prod-name
              by gds-prop.grp-code
              by {&Sort-pole} :
        { rep/obr-k2-7.i fe3 }
      End. /*for each gds-prop */
      run PutItogSum in this-procedure (2) .  /* вывод сумм */
    end. /* OBJ-LIST */
  end.
  else do:
    for each gds-prop break by gds-prop.prod-name by gds-prop.grp-code by {&Sort-pole} :
      { rep/obr-k2-7.i fe3 }
    End. /*for each gds-prop */
  end.
  run PutItogSum in this-procedure (1) .  /* вывод сумм */
END PROCEDURE.


PROCEDURE foreach5 :  /* по группам и по производителям */
  if tog-obj = true then do: /* раздельно по объектам */
    for each obj-list no-lock :
      assign  titul = 0 .
      for each temp-sum where temp-sum.level = 2 : assign temp-sum.sum = 0 . end.
      for each gds-prop
        where gds-prop.obj-type = obj-list.obj-type
          and gds-prop.obj-code = obj-list.obj-code
        break by gds-prop.grp-code
              by gds-prop.prod-name
              by {&Sort-pole} :
        { rep/obr-k2-7.i fe4 }
      End. /*for each gds-prop */
      run PutItogSum in this-procedure (2) .  /* вывод сумм */
    end. /* OBJ-LIST */
  end.
  else do:
    for each gds-prop break by gds-prop.grp-code by gds-prop.prod-name by {&Sort-pole} :
      { rep/obr-k2-7.i fe4 }
    End. /*for each gds-prop */
  end.
  run PutItogSum in this-procedure (1) .  /* вывод сумм */

END PROCEDURE.


PROCEDURE foreach6 :  /* по НДС */
  if tog-obj = true then do: /* раздельно по объектам */
    for each obj-list no-lock :
      assign  titul = 0 .
      for each temp-sum where temp-sum.level = 2 : assign temp-sum.sum = 0 . end.
      for each gds-prop
        where gds-prop.obj-type = obj-list.obj-type
          and gds-prop.obj-code = obj-list.obj-code
        break by gds-prop.vat-pc
              by {&Sort-pole} :
        { rep/obr-k2-7.i fe5 }
      End. /*for each gds-prop */
      run PutItogSum in this-procedure (2).  /* вывод сумм */
    end. /* OBJ-LIST */
  end.
  else do:
    for each gds-prop break by gds-prop.vat-pc by {&Sort-pole} :
      { rep/obr-k2-7.i fe5 }
    End. /*for each gds-prop */
  end.
  run PutItogSum in this-procedure (1) .  /* вывод сумм */
END PROCEDURE.



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