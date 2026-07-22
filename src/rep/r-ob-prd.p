block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-ob-prd.p $
$Archive: rep/r-ob-prd.p $

оборотка по производителям

Автор: Демин Алексей Сергеевич
Дата создания: 09/07/05
Author: Alexey Demin
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

define input parameter SortCli           as integer   no-undo .
define input parameter SelectOrg         as integer no-undo .
define input parameter org-list          as character no-undo .
define input parameter SelectMngr        as integer no-undo .
define input parameter mngr-list         as character no-undo .
define input parameter Classify          as character no-undo .
define input parameter SortType          as character no-undo .
define input parameter CloseDoc          as logical   no-undo .
define input parameter OpenDoc           as logical   no-undo .
define input parameter SumsOnly          as logical   no-undo .
define input parameter print-o           as integer   no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-ob-prd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-ob-prd.p $":U .
define variable vss-description as character no-undo init "оборотка по производителям".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ ref/grplibfn.i }
{ gbl/paramls.i  }
{ rep/r-cost.i   }
{ rep/r-sale.i   }
{ cmp/r-pril.i   }
{ rep/f-fdec.i   }   /* Функции для форматирования полей для передачи в EXcel         */
{ trg/prdoclib.i }
{ cmp/library.i  }
{ str/prl-vat.i  }
{ rep/rep-bt.i   }
{ rep/mcrexcel.i }
{ trg/factord.i  }
{ gbl/temphost.i }

do
on error undo, return error
:

  &Scop Sort-pole  if SortType = "sort-code":U   then  gds-prop.b-code Else  gds-prop.artic

  DEFINE temp-table gds-prop no-undo
    field   artic            as  char
    field   prod-type        as  char
    field   prod-code        as  integer
    field   gds-code         as  integer
    field   gds-name         as  char
    field   grp-name         as  char
/*    field   unit-base        as  char*/
    field   b-code           as  char
    field   grp-code         as  integer
    field   cli-type         as  char
    field   cli-code         as  integer
    field   cli-name         as  char
    field   s-ind            as  integer
    field   empty-scale      as logical
    INDEX pi  IS PRIMARY   prod-type prod-code
    INDEX pi1              b-code
    INDEX pi2              cli-type cli-code
    INDEX pi3              artic
    INDEX pi4              grp-code
    INDEX pi5              cli-name
    INDEX pi6              s-ind
  .

  DEFINE temp-table temp-prt no-undo
    field   prt-code         as  integer
    field   gds-code         as  integer
    field   sum              as  decimal
    field   doc-type         as  character
    field   sum-type         as  integer
    field   b-code           as  integer
    field   cli-type         as  char
    field   cli-code         as  integer
    field   s-ind            as  integer
    INDEX pi  IS PRIMARY   gds-code prt-code
    INDEX pi1              doc-type sum-type
    INDEX pi2              cli-type cli-code
    INDEX pi3              s-ind
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

  DEFINE temp-table gds-sel-grp no-undo
    field   artic            as  char
    field   prod-type        as  char
    field   prod-code        as  integer
    INDEX pi  IS PRIMARY unique artic prod-type prod-code
  .

  define buffer buf_goods    for ub.goods.
  define buffer buf_clients  for ub.clients.
  define buffer buf1_clients for ub.clients.
  define buffer buf_gds-obj  for ub.gds-obj.
  define buffer buf_trn-doc  for ub.trn-doc.
  define buffer buf_doc-line for ub.doc-line.
  define buffer buf_gds-dtl  for ub.gds-dtl.
  define buffer buf_pay-type for ub.pay-type.
  define buffer buf_cli-grp  for ub.cli-grp.

  define variable Counter1     as integer initial 0   no-undo .
  define variable ItogStr      as character initial "" no-undo .
  define variable ItogStr1     as character initial "" no-undo .
  define variable Line         as character no-undo .
  define variable CurrGrpName  as character no-undo .
  define variable beg          as integer   no-undo .
  define variable ii           as integer   no-undo .
  define variable jj           as integer   no-undo .
  define variable frmt         as character no-undo .
  define variable edt          as character no-undo .
  define variable tmp-fo  as decimal   no-undo .

  define variable v1-fact-qnty         like ub.ot-line.fact-qnty       no-undo .
  define variable v1-vat-pc            like ub.doc-line.vat-pc         no-undo .
  define variable v1-slt-pc            like ub.doc-line.slt-pc         no-undo .
  define variable v1-sum-base          like ub.ot-line.sum-base        no-undo .
  define variable v1-sum-rubl          like ub.ot-line.sum-rubl        no-undo .
  define variable v1-vat-base          like ub.ot-line.vat-base        no-undo .
  define variable v1-vat-rubl          like ub.ot-line.vat-rubl        no-undo .
  define variable v1-slt-base          like ub.ot-line.slt-base        no-undo .
  define variable v1-slt-rubl          like ub.ot-line.slt-rubl        no-undo .
  define variable v1-road-tax-base     like ub.ot-line.road-tax-base   no-undo .
  define variable v1-road-tax-rubl     like ub.ot-line.road-tax-rubl   no-undo .
  define variable v1-transport-base    like ub.ot-line.transport-base  no-undo .
  define variable v1-transport-rubl    like ub.ot-line.transport-rubl  no-undo .
  define variable v1-other-base        like ub.ot-line.other-base      no-undo .
  define variable v1-other-rubl        like ub.ot-line.other-rubl      no-undo .
  define variable v1-excise-base       like ub.ot-line.excise-base     no-undo .
  define variable v1-excise-rubl       like ub.ot-line.excise-rubl     no-undo .
  define variable v2-fact-qnty         like ub.ot-line.fact-qnty       no-undo .
  define variable v2-vat-pc            like ub.doc-line.vat-pc         no-undo .
  define variable v2-slt-pc            like ub.doc-line.slt-pc         no-undo .
  define variable v2-sum-base          like ub.ot-line.sum-base        no-undo .
  define variable v2-sum-rubl          like ub.ot-line.sum-rubl        no-undo .
  define variable v2-vat-base          like ub.ot-line.vat-base        no-undo .
  define variable v2-vat-rubl          like ub.ot-line.vat-rubl        no-undo .
  define variable v2-slt-base          like ub.ot-line.slt-base        no-undo .
  define variable v2-slt-rubl          like ub.ot-line.slt-rubl        no-undo .
  define variable v2-road-tax-base     like ub.ot-line.road-tax-base   no-undo .
  define variable v2-road-tax-rubl     like ub.ot-line.road-tax-rubl   no-undo .
  define variable v2-transport-base    like ub.ot-line.transport-base  no-undo .
  define variable v2-transport-rubl    like ub.ot-line.transport-rubl  no-undo .
  define variable v2-other-base        like ub.ot-line.other-base      no-undo .
  define variable v2-other-rubl        like ub.ot-line.other-rubl      no-undo .
  define variable v2-excise-base       like ub.ot-line.excise-base     no-undo .
  define variable v2-excise-rubl       like ub.ot-line.excise-rubl     no-undo .

  define variable v-prt-b-code like ub.bar-code.b-code no-undo .
  define variable v-root-node   as integer   no-undo .

  define variable  v-fact-order-start   as decimal   no-undo .
  define variable  v-fact-order-end     as decimal   no-undo .
  run day-begin-fact-order in this-procedure ( input x-date-start, output v-fact-order-start ). /*Поиск нач fact-order*/
  run day-begin-fact-order in this-procedure ( input ( x-date-end + 1 ),   output v-fact-order-end ). /*Поиск посл fact-order*/

  define variable sz-qnty      as integer initial 3  no-undo .
  define variable v-sys-key as char no-undo.                  /* для чтения параметра конфигурации */
  { gbl/currsysk.i
    v-sys-key
    no-error
  }

  if v-sys-key = "BDC" then assign sz-qnty = 0 .

  define variable frm-sum  as character initial "->,>>>,>>9.99" no-undo .
  define variable frm-prc  as character initial "->,>>9.99" no-undo .
  define variable frm-qnty as character no-undo .
  if sz-qnty = 3 then assign frm-qnty = "->>>>,>>9.999" .
  else                       frm-qnty = "->>>>,>>>,>>9" .

  define Stream OutStream.
  define stream macr_excel .

  if use-column[ 25 ] then do: /* цена фирмы-посредника вместо учетной */
    RUN init-temphost.
    find first  ub.sysconf where ub.sysconf.avrg-price = yes no-lock no-error .
    for each temp-obj where temp-obj.host-code <> ub.sysconf.host-code :  delete temp-obj.  end.
  end.

  /* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1 */
  define variable v-row       as integer   no-undo .
  define variable v-col       as integer   no-undo .
  define variable v-ind       as integer   no-undo initial 1 .
/* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1 */

  assign
    frmt = "X(" + string(print-o) + ')'
    Line = fill("-", print-o).
  .

  { rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 10 } /* Показать окно информации о текущем процессе */

  if x-SelectGood = {&g-grp} then do: /* не все группы товаров */
    for each tmp#grp :
      run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output CurrGrpName ) .
      for each obj-list,
          each buf_gds-obj no-lock
        where buf_gds-obj.obj-type = obj-list.obj-type
          and buf_gds-obj.obj-code = obj-list.obj-code
          and buf_gds-obj.grp-name begins CurrGrpName :
        find first gds-sel-grp
          where gds-sel-grp.artic     = buf_gds-obj.artic
            and gds-sel-grp.prod-type = buf_gds-obj.prod-type
            and gds-sel-grp.prod-code = buf_gds-obj.prod-code
          no-error .
        if not available gds-sel-grp then do:
          create gds-sel-grp .
          assign
            gds-sel-grp.artic     = buf_gds-obj.artic
            gds-sel-grp.prod-type = buf_gds-obj.prod-type
            gds-sel-grp.prod-code = buf_gds-obj.prod-code
          .
        end.
      end.
    end.
  end.

  for each obj-list :
    if CloseDoc = yes then do: /* закрытые документы */
      for each buf_trn-doc no-lock
        where buf_trn-doc.obj-type   = obj-list.obj-type
          and buf_trn-doc.obj-code   = obj-list.obj-code
          and buf_trn-doc.status_    =  {&fact}
          and buf_trn-doc.fact-order >= v-fact-order-start
          and buf_trn-doc.fact-order <  v-fact-order-end
      :
        { rep/r-ob-pr1.i }
      end.
    end.
    if OpenDoc = yes then do: /* незакрытые документы */
      for each buf_trn-doc no-lock
        where buf_trn-doc.obj-type  = obj-list.obj-type
          and buf_trn-doc.obj-code  = obj-list.obj-code
          and buf_trn-doc.doc-date >= x-date-start
          and buf_trn-doc.doc-date <= x-date-end
      :
        if buf_trn-doc.status_ = {&fact} then next .
        { rep/r-ob-pr1.i }
      end.
    end.
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
  if print-o < 136 then do:   { cmp/open-out.i stream OutStream " " {&CS_PS} }  end.
  else do:
    if print-o < 198 then do: { cmp/open-out.i stream OutStream " " {&LS_PS_A4} }   end.
    else do:                  { cmp/open-out.i stream OutStream " " {&LS_PS_A4} }   end.
  end.

  run PrintTitul in this-procedure .
  run PutColumnTitulExcel in this-procedure .

  for each temp-sum where temp-sum.level = 1 : assign temp-sum.sum = 0 . end.

  if sumsonly = no and classify = "grp-goods":u then do: /* класс по группам */
    if SortCli = 1 then do: run for-each1 in this-procedure . end.
    else do:                run for-each2 in this-procedure . end.
  end.
  else do:
    if SortCli = 1 then do: run for-each3 in this-procedure . end.
    else do:                run for-each4 in this-procedure . end.
  end.

  assign ItogStr = "Итого по всем " .
  run PutItogSum in this-procedure ( ItogStr, 1) .  /* вывод сумм */

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */

  output stream macr_excel close .
  run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name) .

  HIDE stream OutStream FRAME BottomFrame .
  OUTPUT stream OutStream CLOSE.

  run end-proc .
  { gbl/stopwork.i }

  define variable disop as integer   no-undo .
  if print-o < 136 then assign disop = 0 .
  else do:
    if print-o < 198 then assign disop = 8 .
    else do:
      if print-o > 550 then assign disop = 1 .
      else                 assign disop = 3 .   /* только в файл */
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

/* ************************************************************************* */

procedure GetName :
  do
  on error undo, return error return-value
  :
    define output parameter str as character no-undo .

    case SortCli:
      when 1 then do:
        assign str = gds-prop.cli-name .
      end.
      when 2 or when 3 then do:
        if gds-prop.s-ind = ? then assign str = "?" .
        else do:
          find first buf1_clients no-lock
            where buf1_clients.obj-type = {&prs}
              and buf1_clients.obj-code = gds-prop.s-ind
          .
          assign str = buf1_clients.obj-name .
        end.
      end.
      when 4 then do:
        find first buf_pay-type no-lock where buf_pay-type.obj-code = gds-prop.s-ind .
        assign str = buf_pay-type.obj-name .
      end.
      when 5 then do:
        find first buf_cli-grp no-lock where buf_cli-grp.node-code = gds-prop.s-ind .
        assign str = buf_cli-grp.node-name .
      end.
    end case.

  end.
end procedure. /* GetName */



procedure PutItogSum :
  define input  parameter p-name as character no-undo .
  define input  parameter p-num  as integer   no-undo .

  define buffer buf_temp-sum for temp-sum .
  define buffer buf1_temp-sum for temp-sum .
  define variable smm as decimal   no-undo .

  assign  beg = 1  v-col = 1 .
  put stream outstream  "|" at beg p-name format "X(29)" .  assign beg = beg + 30  .
  run macr_excel_char (p-name, v-row, v-col) .              assign v-col = v-col + 1 .
  if SumsOnly = no then do:
    put stream outstream  "|" at beg .  assign beg = beg + 14 .
    put stream outstream  "|" at beg .  assign beg = beg + 15 .
    put stream outstream  "|" at beg .  assign beg = beg + 30 .
    assign v-col = v-col + 3 .
  end.

  for each  buf_temp-sum where buf_temp-sum.level = p-num :
    if use-column[ buf_temp-sum.num ] = no then next .
    case buf_temp-sum.sum-type :
      when 0 then do:
        put stream outstream  "|" at beg buf_temp-sum.sum format frm-qnty  .
        run macr_excel_sum (buf_temp-sum.sum, v-row, v-col, sz-qnty) .
        assign  beg = beg + 14 .
      end.
      when 1 or when 2 or when 3 then do:
        put stream outstream  "|" at beg buf_temp-sum.sum format frm-sum .
        run macr_excel_sum (buf_temp-sum.sum, v-row, v-col, 2) .
        assign  beg = beg + 14 .
      end.
      when 4 then do:
        if buf_temp-sum.num <> 24 then do:
          find first buf1_temp-sum where buf1_temp-sum.level = p-num and buf1_temp-sum.num = (buf_temp-sum.num - 1) no-error .
          if available buf1_temp-sum then assign smm = buf1_temp-sum.sum .
          find first buf1_temp-sum where buf1_temp-sum.level = p-num and buf1_temp-sum.num = (buf_temp-sum.num - 2) no-error .
          if available buf1_temp-sum then assign smm = smm * 100 / ( smm + buf1_temp-sum.sum ) .
        end.
        else do:
          find first buf1_temp-sum where buf1_temp-sum.level = p-num and buf1_temp-sum.num = 17 no-error .
          if available buf1_temp-sum then assign smm = buf1_temp-sum.sum .
          find first buf1_temp-sum where buf1_temp-sum.level = p-num and buf1_temp-sum.num = 16 no-error .
          if available buf1_temp-sum then assign smm = ( smm - buf1_temp-sum.sum ) * 100 / buf1_temp-sum.sum .
        end.
        if smm = ? then assign smm = 0 .
        put stream outstream  "|" at beg smm format frm-prc .
        run macr_excel_sum (smm, v-row, v-col, 2) .
        assign  beg = beg + 10 .
      end.
    end.
    assign v-col = v-col + 1 .
  end.
  if p-num > 2 then put stream outstream   "|" at print-o skip .
  else              put stream outstream   "|" at print-o skip Line format frmt skip.
  assign v-row = v-row + 1 .

end procedure . /* PutItogSum */


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


procedure Add-gds-prop :
  define input  parameter p-num as integer   no-undo .

  do on error undo, return error return-value :
    if SortCli = 1 then do:
      find first gds-prop
        where gds-prop.artic     = buf_doc-line.artic
          and gds-prop.prod-type = buf_doc-line.prod-type
          and gds-prop.prod-code = buf_doc-line.prod-code
          and gds-prop.cli-type  = buf_trn-doc.cli-type
          and gds-prop.cli-code  = buf_trn-doc.cli-code
      no-error .
    end.
    else do:
      find first gds-prop
        where gds-prop.artic     = buf_doc-line.artic
          and gds-prop.prod-type = buf_doc-line.prod-type
          and gds-prop.prod-code = buf_doc-line.prod-code
          and gds-prop.s-ind     = p-num
      no-error .
    end.

    if not available gds-prop then do:
      create gds-prop .
      find first buf_goods no-lock
        where buf_goods.artic     = buf_doc-line.artic
          and buf_goods.prod-type = buf_doc-line.prod-type
          and buf_goods.prod-code = buf_doc-line.prod-code
      no-error .
      if g#gds-engl then assign gds-prop.gds-name = buf_goods.engl-name.
      else               assign gds-prop.gds-name = buf_goods.gds-name.
      { gbl/rootnode.i   buf_goods.artic   buf_goods.prod-type   buf_goods.prod-code  v-root-node }
      { gbl/prtat.i v-root-node  "'empty-scale=request'"  gds-prop.empty-scale }

      { gbl/gdsbcode.i  buf_goods.gds-code  ?  ii  no-error }
      if error-status :error then do:
        message vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода товара" skip  "Код товара" skip
        view-as alert-box error .
        undo, return error .
       end.

      assign
        gds-prop.artic     = buf_doc-line.artic
        gds-prop.prod-type = buf_doc-line.prod-type
        gds-prop.prod-code = buf_doc-line.prod-code
        gds-prop.gds-code  = buf_goods.gds-code
        gds-prop.grp-name  = buf_goods.grp-name
        gds-prop.b-code    = string(ii,">>>>>>>>>>>>9")
        gds-prop.grp-code  = buf_goods.grp-code
        gds-prop.cli-type  = buf_trn-doc.cli-type
        gds-prop.cli-code  = buf_trn-doc.cli-code
        gds-prop.cli-name  = buf_trn-doc.cli-name
      .
      case SortCli :
        when 3 then assign gds-prop.s-ind = buf_trn-doc.agnt .
        when 2 then assign gds-prop.s-ind = buf_trn-doc.boss .
        when 4 then assign gds-prop.s-ind = buf_trn-doc.pay-code .
        when 5 then assign gds-prop.s-ind = buf1_clients.grp-code .
      end.
    end.

    if gds-prop.empty-scale = no then do: /* это шкальный товар */
      FOR EACH buf_gds-dtl no-lock
        where buf_gds-dtl.artic     = buf_doc-line.artic
          AND buf_gds-dtl.doc-code  = buf_doc-line.doc-code
          AND buf_gds-dtl.prod-code = buf_doc-line.prod-code
          AND buf_gds-dtl.prod-type = buf_doc-line.prod-type
        :
        { gbl/gdsbcode.i gds-prop.gds-code buf_gds-dtl.prt-code v-prt-b-code  no-error  }
        if error-status :error then do:
          message  vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода признака" skip
          "Код товара"   gds-prop.gds-code skip  "Код признака" buf_gds-dtl.prt-code skip error-status :get-message(1) skip
           return-value skip view-as alert-box error .
          undo, return error .
        end.

        run Add-temp-prt ( gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 0, edt, buf_gds-dtl.prt-code, v-prt-b-code, buf_gds-dtl.fact-qnty ) .
        run Add-temp-prt ( gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 1, edt, buf_gds-dtl.prt-code, v-prt-b-code, buf_gds-dtl.fact-qnty * (if var-report-r-b = "rubl" then v1-sum-rubl else v1-sum-base) / v1-fact-qnty ) .
        if buf_trn-doc.ext-doc-type <> {&TDEDT_Pri_Vnesh}         and
           buf_trn-doc.ext-doc-type <> {&TDEDT_Ras_Vnesh_VP}      then do:
          run Add-temp-prt ( gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 2, edt, buf_gds-dtl.prt-code, v-prt-b-code, buf_gds-dtl.fact-qnty * (if var-report-r-b = "rubl" then buf_gds-dtl.price-rubl else buf_gds-dtl.price-base) ) .
          if   buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
            or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}
            or buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}
            or buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
          then do:
            run Add-temp-prt ( gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 3, edt, buf_gds-dtl.prt-code, v-prt-b-code,  buf_gds-dtl.fact-qnty * (if var-report-r-b = "rubl" then buf_gds-dtl.discnt-rubl else buf_gds-dtl.discnt-base) ) .
          end.
        end.
      end.
    end.

    if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}      or
       buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass} or
       buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}   or
       buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem}      or
       buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh}      then
      assign
        v1-sum-rubl   = - v1-sum-rubl
        v1-sum-base   = - v1-sum-base
        v1-fact-qnty  = - v1-fact-qnty
        v2-sum-rubl   = - v2-sum-rubl
        v2-sum-base   = - v2-sum-base
        v2-other-rubl = - v2-other-rubl
        v2-other-base = - v2-other-base
      .

    run Add-temp-prt ( gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 0, edt, -1, gds-prop.b-code, v1-fact-qnty) .
    run Add-temp-prt ( gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 1, edt, -1, gds-prop.b-code, (if var-report-r-b = "rubl" then v1-sum-rubl else v1-sum-base)) .
    if buf_trn-doc.ext-doc-type <> {&TDEDT_Pri_Vnesh} and  buf_trn-doc.ext-doc-type <> {&TDEDT_Ras_Vnesh_VP}  then do:
      if   buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
        or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}
        or buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}
        or buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
      then do:
        run Add-temp-prt ( gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 3, edt, -1, gds-prop.b-code, (if var-report-r-b = "rubl" then v2-other-rubl else v2-other-base)) .
        run Add-temp-prt ( gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 4, edt, -1, gds-prop.b-code, (if var-report-r-b = "rubl" then v2-other-rubl * 100 / ( v2-other-rubl + v2-sum-rubl ) else v2-other-base * 100 / ( v2-other-base + v2-sum-base ) ) ) .
      end.
      run Add-temp-prt ( gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 2, edt, -1, gds-prop.b-code, (if var-report-r-b = "rubl" then v2-sum-rubl else v2-sum-base) ) .
    end.
  end.
end procedure. /* Add-gds-prop */


procedure Add-temp-prt :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-cli-type as character no-undo .
  define input  parameter p-cli-code as integer   no-undo .
  define input  parameter p-s-ind    as integer   no-undo .
  define input  parameter p-num      as integer   no-undo .
  define input  parameter p-type     as character no-undo .
  define input  parameter p-prt-code as integer   no-undo .
  define input  parameter p-b-code   as integer   no-undo .
  define input  parameter p-val      as decimal   no-undo .

  do on error undo, return error return-value :
    if SortCli = 1 then do:
      find first temp-prt
        where temp-prt.gds-code = p-gds-code
          and temp-prt.prt-code = p-prt-code
          and temp-prt.sum-type = p-num
          and temp-prt.doc-type = p-type
          and temp-prt.cli-type = p-cli-type
          and temp-prt.cli-code = p-cli-code
      no-error .
    end.
    else do:
      find first temp-prt
        where temp-prt.gds-code = p-gds-code
          and temp-prt.prt-code = p-prt-code
          and temp-prt.sum-type = p-num
          and temp-prt.doc-type = p-type
          and temp-prt.s-ind    = p-s-ind
      no-error .
    end.

    if not available temp-prt then do:
      create temp-prt .
      ASSIGN
        temp-prt.gds-code = p-gds-code
        temp-prt.prt-code = p-prt-code
        temp-prt.b-code   = p-b-code
        temp-prt.doc-type = p-type
        temp-prt.sum-type = p-num
        temp-prt.cli-type = p-cli-type
        temp-prt.cli-code = p-cli-code
        temp-prt.s-ind    = p-s-ind
      .
    end.
    assign temp-prt.sum = temp-prt.sum + p-val .
  end.
end procedure. /* Add-temp-prt */


procedure Add-temp-sum :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-cli-type as character no-undo .
  define input  parameter p-cli-code as integer   no-undo .
  define input  parameter p-s-ind    as integer   no-undo .
  define input  parameter p-num      as integer   no-undo .
  define input  parameter p-type     as character no-undo .
  define input  parameter p-prt-code as integer   no-undo .
  define input  parameter p-count    as integer   no-undo .

  define buffer buf_temp-prt for temp-prt .
  define variable lvl as integer  no-undo .
  define variable tp-str as character no-undo .
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

    if     p-type <> "rs-vz" and p-type <> "eff-val" and p-type <> "eff-prc" then do:
      if SortCli = 1 then do:
        find first buf_temp-prt
          where buf_temp-prt.gds-code = p-gds-code
            and buf_temp-prt.prt-code = p-prt-code
            and buf_temp-prt.sum-type = p-num
            and buf_temp-prt.doc-type = p-type
            and buf_temp-prt.cli-type = p-cli-type
            and buf_temp-prt.cli-code = p-cli-code
        no-error .
      end.
      else do:
        find first buf_temp-prt
          where buf_temp-prt.gds-code = p-gds-code
            and buf_temp-prt.prt-code = p-prt-code
            and buf_temp-prt.sum-type = p-num
            and buf_temp-prt.doc-type = p-type
            and buf_temp-prt.s-ind    = p-s-ind
        no-error .
      end.
      if available buf_temp-prt then assign temp-sum.sum  = buf_temp-prt.sum  .
    end.
    else do:
      if p-num = 4 and p-type <> "eff-prc" then do:
        define buffer buf1_temp-sum for temp-sum .
        find first buf1_temp-sum where buf1_temp-sum.level = lvl and buf1_temp-sum.sum-type = 2 and buf1_temp-sum.doc-type = p-type no-error .
        if available buf1_temp-sum then assign temp-sum.sum  = buf1_temp-sum.sum.
        find first buf1_temp-sum where buf1_temp-sum.level = lvl and buf1_temp-sum.sum-type = 3 and buf1_temp-sum.doc-type = p-type no-error .
        if available buf1_temp-sum then assign temp-sum.sum  =  buf1_temp-sum.sum * 100 / (temp-sum.sum + buf1_temp-sum.sum) .


      end.
      else do:
        case p-type :
          when "rs-vz" then do:
            do ii = 1 to 4:
              case ii:
                when 1 then assign tp-str = {&TDEDT_Ras_Vnesh} .
                when 2 then assign tp-str = {&TDEDT_Vozvrat_Vnesh} .
                when 3 then assign tp-str = {&TDEDT_Ras_Vnesh_Kass} .
                when 4 then assign tp-str = {&TDEDT_Vozvrat_Vnesh_Kass} .
              end.
              if SortCli = 1 then do:
                find first buf_temp-prt
                  where buf_temp-prt.gds-code = p-gds-code and buf_temp-prt.prt-code = p-prt-code
                    and buf_temp-prt.sum-type = p-num      and buf_temp-prt.doc-type = tp-str
                    and buf_temp-prt.cli-type = p-cli-type and buf_temp-prt.cli-code = p-cli-code
                no-error .

              end.
              else do:
                find first buf_temp-prt
                  where buf_temp-prt.gds-code = p-gds-code and buf_temp-prt.prt-code = p-prt-code
                    and buf_temp-prt.sum-type = p-num      and buf_temp-prt.doc-type = tp-str
                    and buf_temp-prt.s-ind    = p-s-ind
                no-error .
              end.

              if available buf_temp-prt then do:
                if ii = 1 or ii = 3 then assign temp-sum.sum = temp-sum.sum + buf_temp-prt.sum .
                else                     assign temp-sum.sum = temp-sum.sum - buf_temp-prt.sum .
              end.
            end.
          end.
          when "eff-val" or when "eff-prc" then do:
            define variable sm1 as decimal initial 0 no-undo .
            define variable sm2 as decimal initial 0 no-undo .
            do ii = 1 to 4:
              case ii:
                when 1 then assign tp-str = {&TDEDT_Ras_Vnesh} .
                when 2 then assign tp-str = {&TDEDT_Vozvrat_Vnesh} .
                when 3 then assign tp-str = {&TDEDT_Ras_Vnesh_Kass} .
                when 4 then assign tp-str = {&TDEDT_Vozvrat_Vnesh_Kass} .
              end.
              if SortCli = 1 then do:
                find first buf_temp-prt
                  where buf_temp-prt.gds-code = p-gds-code and buf_temp-prt.prt-code = p-prt-code
                    and buf_temp-prt.sum-type = 2          and buf_temp-prt.doc-type = tp-str
                    and buf_temp-prt.cli-type = p-cli-type and buf_temp-prt.cli-code = p-cli-code
                no-error .
              end.
              else do:
                find first buf_temp-prt
                  where buf_temp-prt.gds-code = p-gds-code and buf_temp-prt.prt-code = p-prt-code
                    and buf_temp-prt.sum-type = 2          and buf_temp-prt.doc-type = tp-str
                    and buf_temp-prt.s-ind    = p-s-ind
                no-error .
              end.

              if available buf_temp-prt then do:
                if ii = 1 or ii = 3 then assign sm2 = sm2 + buf_temp-prt.sum .
                else                     assign sm2 = sm2 - buf_temp-prt.sum .
              end.
              if SortCli = 1 then do:
                find first buf_temp-prt
                  where buf_temp-prt.gds-code = p-gds-code and buf_temp-prt.prt-code = p-prt-code
                    and buf_temp-prt.sum-type = 1          and buf_temp-prt.doc-type = tp-str
                    and buf_temp-prt.cli-type = p-cli-type and buf_temp-prt.cli-code = p-cli-code
                no-error .
              end.
              else do:
                find first buf_temp-prt
                  where buf_temp-prt.gds-code = p-gds-code and buf_temp-prt.prt-code = p-prt-code
                    and buf_temp-prt.sum-type = 1          and buf_temp-prt.doc-type = tp-str
                    and buf_temp-prt.s-ind    = p-s-ind
                no-error .
              end.
              if available buf_temp-prt then do:
                if ii = 1 or ii = 3 then assign sm1 = sm1 + buf_temp-prt.sum .
                else                     assign sm1 = sm1 - buf_temp-prt.sum .
              end.
            end.
            if p-type = "eff-prc" then assign temp-sum.sum = (sm2 - sm1) * 100 / sm1 .
            else                       assign temp-sum.sum = sm2 - sm1 .
          end.
        end.
      end.
    end.
    if temp-sum.sum = ? then assign temp-sum.sum = 0 .
  end.
end procedure. /* Get-buf_temp-prt */



procedure PutColumnTitulExcel : /* заголовки для колонок экселя */
  do
  on error undo, return error return-value
  :
  assign
    v-col = 1
    v-row = 1
  .
  run macr_excel_char (ReportNAme, v-row, 2) .
  run macr_cell_format ( 11, yes, no, ?, v-row, 2, v-row, 2) .
  assign v-row = v-row + 1 .

  run macr_excel_char (str1, v-row, v-col) .                          assign v-row = v-row + 1 .
  run macr_excel_char (str2, v-row, v-col) .                          assign v-row = v-row + 1 .
  run macr_excel_char (str3, v-row, v-col) .                          assign v-row = v-row + 1 .
  run macr_excel_char ("Выбранные объекты: " + str4, v-row, v-col) .  assign v-row = v-row + 1 .
  run macr_excel_char (ReportHeader, v-row, v-col) .                  assign v-row = v-row + 1 .

  assign v-col = 1 .
  run macr_excel_char ("Контрагент", v-row, v-col) .        run macr_cell_size (40,?, v-row, v-col,?,?).  assign v-col = v-col + 1 .

  if SumsOnly = no then do:
    run macr_excel_char ("Код", v-row, v-col) .             run macr_cell_size (13,?, v-row, v-col,?,?).  assign v-col = v-col + 1 .
    run macr_excel_char ("Артикул", v-row, v-col) .         run macr_cell_size (16,?, v-row, v-col,?,?).  assign v-col = v-col + 1 .
    run macr_excel_char ("Название товара", v-row, v-col) . run macr_cell_size (40,?, v-row, v-col,?,?).  assign v-col = v-col + 1 .
  end.

  if use-column[1 ] = yes then do: run macr_excel_char ("Приход внешний (кол-во)", v-row, v-col) .   assign v-col = v-col + 1 .                end.
  if use-column[2 ] = yes then do: run macr_excel_char ("Приход внешний (сумма учет. цен)", v-row, v-col) .    assign v-col = v-col + 1 .      end.
  if use-column[3 ] = yes then do: run macr_excel_char ("Возврат поставщику (кол-во)", v-row, v-col) .         assign v-col = v-col + 1 .      end.
  if use-column[4 ] = yes then do: run macr_excel_char ("Возврат поставщику (сумма учет. цен)", v-row, v-col) .    assign v-col = v-col + 1 .  end.
  if use-column[5 ] = yes then do: run macr_excel_char ("Расход внешний (кол-во)", v-row, v-col) .    assign v-col = v-col + 1 .               end.
  if use-column[6 ] = yes then do: run macr_excel_char ("Расход внешний (сумма учет. цен)", v-row, v-col) .    assign v-col = v-col + 1 .      end.
  if use-column[7 ] = yes then do: run macr_excel_char ("Расход внешний (сумма прод. цен)", v-row, v-col) .    assign v-col = v-col + 1 .      end.
  if use-column[8 ] = yes then do: run macr_excel_char ("Расход внешний (скидка)", v-row, v-col) .    assign v-col = v-col + 1 .               end.
  if use-column[9 ] = yes then do: run macr_excel_char ("Расход внешний (% скидки)", v-row, v-col) .    assign v-col = v-col + 1 .             end.
  if use-column[10] = yes then do: run macr_excel_char ("Возврат внешний (кол-во)", v-row, v-col) .    assign v-col = v-col + 1 .              end.
  if use-column[11] = yes then do: run macr_excel_char ("Возврат внешний (сумма учет. цен)", v-row, v-col) .    assign v-col = v-col + 1 .     end.
  if use-column[12] = yes then do: run macr_excel_char ("Возврат внешний (сумма прод. цен)", v-row, v-col) .    assign v-col = v-col + 1 .     end.
  if use-column[13] = yes then do: run macr_excel_char ("Возврат внешний (скидка)", v-row, v-col) .    assign v-col = v-col + 1 .              end.
  if use-column[14] = yes then do: run macr_excel_char ("Возврат внешний (% скидки)", v-row, v-col) .    assign v-col = v-col + 1 .            end.
  if use-column[15] = yes then do: run macr_excel_char ("Расход-Возврат (кол-во)", v-row, v-col) .    assign v-col = v-col + 1 .               end.
  if use-column[16] = yes then do: run macr_excel_char ("Расход-Возврат (сумма учет. цен)", v-row, v-col) .    assign v-col = v-col + 1 .      end.
  if use-column[17] = yes then do: run macr_excel_char ("Расход-Возврат (сумма прод. цен)", v-row, v-col) .    assign v-col = v-col + 1 .      end.
  if use-column[18] = yes then do: run macr_excel_char ("Расход-Возврат-скидка", v-row, v-col) .    assign v-col = v-col + 1 .                 end.
  if use-column[19] = yes then do: run macr_excel_char ("Расход-Возврат (% скидки)", v-row, v-col) .    assign v-col = v-col + 1 .             end.
  if use-column[20] = yes then do: run macr_excel_char ("Списание (кол-во)", v-row, v-col) .          assign v-col = v-col + 1 .               end.
  if use-column[21] = yes then do: run macr_excel_char ("Списание (сумма учет. цен)", v-row, v-col) . assign v-col = v-col + 1 .               end.
  if use-column[22] = yes then do: run macr_excel_char ("Списание (сумма прод. цен)", v-row, v-col) . assign v-col = v-col + 1 .               end.
  if use-column[23] = yes then do: run macr_excel_char ("Эффективность", v-row, v-col) .         assign v-col = v-col + 1 .                    end.
  if use-column[24] = yes then do: run macr_excel_char ("Фактический % наценки", v-row, v-col) . assign v-col = v-col + 1 .                    end.

  run macr_cell_bordur ( v-row, 1, v-row, v-col - 1) .
  run macr_cell_format ( 10, yes, no, 35, v-row, 1, v-row, v-col - 1) .
  run macr_cell_size (12,?, v-row, ii,v-row, v-col - 1) .
  assign v-row = v-row + 1 .

  end.
end procedure. /* PutColumnTitulExcel */



procedure PrintTitul :
  if (PAGE-NUMBER( outstream ) = 1 ) then do:
    PUT stream OutStream SPACE(30) ReportNAme format "X(100)" SKIP
                           str1 format "X(130)" SKIP
                           str2 format "X(130)" SKIP
                           str3 format "X(130)" SKIP
                           ReportHeader format "X(130)" SKIP.
    PUT stream OutStream "Выбранные объекты: " format "X(20)" .
    For each obj-list no-lock:
      PUT stream OutStream string(obj-list.obj-name + " (" + obj-list.obj-type + '#' + string(obj-list.obj-code)  + "), ") at 21 format "X(50)" skip.
    end.
  end.

  put stream outstream  skip
    string( "Дата печати :" ) AT 5 format "x(15)" TODAY format "99.99.9999"
    string( " , " ) format "X(3)" string(TIME, "HH:MM")
    string( "Страница" ) AT 85 PAGE-NUMBER( outstream ) AT 95 FORMAT ">>9" SKIP
    Line format frmt skip .

  assign  beg = 1 .   /* 1 строка заголовка */
  put stream outstream  "|" at beg  " Контрагент" format "X(11)" .        assign beg = beg + 30 .
  if SumsOnly = no then do:
    put stream outstream  "|" at beg  " Код" format "X(6)" .              assign beg = beg + 14 .
    put stream outstream  "|" at beg  " Артикул" format "X(14)" .         assign beg = beg + 15 .
    put stream outstream  "|" at beg  " Название товара" format "X(29)" . assign beg = beg + 30 .
  end.
  if use-column[1]  = yes then do: put stream outstream  "|" at beg  " Приход"  format "X(13)" .      assign beg = beg + 14 .   end.
  if use-column[2]  = yes then do: put stream outstream  "|" at beg  " Приход"  format "X(13)" .      assign beg = beg + 14 .   end.
  if use-column[3]  = yes then do: put stream outstream  "|" at beg  " Возврат пост." format "X(13)" .      assign beg = beg + 14 .   end.
  if use-column[4]  = yes then do: put stream outstream  "|" at beg  " Возврат пост." format "X(13)" .      assign beg = beg + 14 .   end.
  if use-column[5]  = yes then do: put stream outstream  "|" at beg  " Расход"  format "X(13)" .      assign beg = beg + 14 .   end.
  if use-column[6]  = yes then do: put stream outstream  "|" at beg  " Расход"  format "X(13)" .      assign beg = beg + 14 .   end.
  if use-column[7]  = yes then do: put stream outstream  "|" at beg  " Расход"  format "X(13)" .      assign beg = beg + 14 .   end.
  if use-column[8]  = yes then do: put stream outstream  "|" at beg  " Расход"  format "X(13)" .      assign beg = beg + 14 .   end.
  if use-column[9]  = yes then do: put stream outstream  "|" at beg  " Расход"  format "X(9)" .       assign beg = beg + 10 .   end.
  if use-column[10] = yes then do: put stream outstream  "|" at beg  "Возврат"  format "X(13)" .      assign beg = beg + 14 .   end.
  if use-column[11] = yes then do: put stream outstream  "|" at beg  "Возврат"  format "X(13)" .      assign beg = beg + 14 .   end.
  if use-column[12] = yes then do: put stream outstream  "|" at beg  "Возврат"  format "X(13)" .      assign beg = beg + 14 .   end.
  if use-column[13] = yes then do: put stream outstream  "|" at beg  "Возврат"  format "X(13)" .      assign beg = beg + 14 .   end.
  if use-column[14] = yes then do: put stream outstream  "|" at beg  "Возврат"  format "X(9)" .       assign beg = beg + 10 .   end.
  if use-column[15] = yes then do: put stream outstream  "|" at beg  "Расход-возвр." format "X(13)" .  assign beg = beg + 14 . end.
  if use-column[16] = yes then do: put stream outstream  "|" at beg  "Расход-возвр." format "X(13)" .  assign beg = beg + 14 . end.
  if use-column[17] = yes then do: put stream outstream  "|" at beg  "Расход-возвр." format "X(13)" .  assign beg = beg + 14 . end.
  if use-column[18] = yes then do: put stream outstream  "|" at beg  "Расход-возвр." format "X(13)" .  assign beg = beg + 14 . end.
  if use-column[19] = yes then do: put stream outstream  "|" at beg  "Расх-возв" format "X(9)" .        assign beg = beg + 10 . end.
  if use-column[20] = yes then do: put stream outstream  "|" at beg  "Списание" format "X(13)" .        assign beg = beg + 14 . end.
  if use-column[21] = yes then do: put stream outstream  "|" at beg  "Списание" format "X(13)" .        assign beg = beg + 14 . end.
  if use-column[22] = yes then do: put stream outstream  "|" at beg  "Списание" format "X(13)" .        assign beg = beg + 14 . end.
  if use-column[23] = yes then do: put stream outstream  "|" at beg  "Эффективность" format "X(13)".    assign beg = beg + 14 . end.
  if use-column[24] = yes then do: put stream outstream  "|" at beg  "Факт-ий" format "X(9)" .          assign beg = beg + 10 . end.
  put stream outstream  "|" at beg  .

   /* 2 строка заголовка */
  assign  beg = 1 .
  put stream outstream  "|" at beg .    assign beg = beg + 30 .
  if SumsOnly = no then do:
    put stream outstream  "|" at beg .  assign beg = beg + 14 .
    put stream outstream  "|" at beg .  assign beg = beg + 15 .
    put stream outstream  "|" at beg .  assign beg = beg + 30 .
  end.
  if use-column[1]  = yes then do: put stream outstream  "|" at beg  " (кол-во)" format "X(13)" .  assign beg = beg + 14 .  end.
  if use-column[2]  = yes then do: put stream outstream  "|" at beg  " (сумма"   format "X(13)" .  assign beg = beg + 14 .  end.
  if use-column[3]  = yes then do: put stream outstream  "|" at beg  " (кол-во)" format "X(13)" .  assign beg = beg + 14 .  end.
  if use-column[4]  = yes then do: put stream outstream  "|" at beg  " (сумма"   format "X(13)" .  assign beg = beg + 14 .  end.
  if use-column[5]  = yes then do: put stream outstream  "|" at beg  " (кол-во)" format "X(13)" .  assign beg = beg + 14 .  end.
  if use-column[6]  = yes then do: put stream outstream  "|" at beg  " (сумма"   format "X(13)" .  assign beg = beg + 14 .  end.
  if use-column[7]  = yes then do: put stream outstream  "|" at beg  " (сумма"   format "X(13)" .  assign beg = beg + 14 .  end.
  if use-column[8]  = yes then do: put stream outstream  "|" at beg  "(скидка)"  format "X(13)" .  assign beg = beg + 14 .  end.
  if use-column[9]  = yes then do: put stream outstream  "|" at beg  "(% скид.)" format "X(9)" .   assign beg = beg + 10 .  end.
  if use-column[10] = yes then do: put stream outstream  "|" at beg  " (кол-во)" format "X(13)" .  assign beg = beg + 14 .  end.
  if use-column[11] = yes then do: put stream outstream  "|" at beg  "(сумма"    format "X(13)" .  assign beg = beg + 14 .  end.
  if use-column[12] = yes then do: put stream outstream  "|" at beg  "(сумма"    format "X(13)" .  assign beg = beg + 14 .  end.
  if use-column[13] = yes then do: put stream outstream  "|" at beg  "(скидка)"  format "X(13)" .  assign beg = beg + 14 .  end.
  if use-column[14] = yes then do: put stream outstream  "|" at beg  "(% скид.)" format "X(9)" .   assign beg = beg + 10 .  end.
  if use-column[15] = yes then do: put stream outstream  "|" at beg  " (кол-во)" format "X(13)" .  assign beg = beg + 14 .  end.
  if use-column[16] = yes then do: put stream outstream  "|" at beg  "(сумма"    format "X(13)" .  assign beg = beg + 14 .  end.
  if use-column[17] = yes then do: put stream outstream  "|" at beg  "(сумма"    format "X(13)" .  assign beg = beg + 14 .  end.
  if use-column[18] = yes then do: put stream outstream  "|" at beg  "(скидка)"  format "X(13)" .  assign beg = beg + 14 .  end.
  if use-column[19] = yes then do: put stream outstream  "|" at beg  "(% скид.)" format "X(9)" .   assign beg = beg + 10 .  end.
  if use-column[20] = yes then do: put stream outstream  "|" at beg  " (кол-во)" format "X(13)" .  assign beg = beg + 14 .  end.
  if use-column[21] = yes then do: put stream outstream  "|" at beg  "(сумма"    format "X(13)" .  assign beg = beg + 14 .  end.
  if use-column[22] = yes then do: put stream outstream  "|" at beg  "(сумма"    format "X(13)" .  assign beg = beg + 14 .  end.
  if use-column[23] = yes then do: put stream outstream  "|" at beg  . assign  beg = beg + 14 . end.
  if use-column[24] = yes then do: put stream outstream  "|" at beg  "% наценки" format "X(9)" .   assign beg = beg + 10 . end.
  put stream outstream  "|" at beg  .

   /* 3 строка заголовка */
  assign  beg = 1 .
  put stream outstream  "|" at beg .    assign beg = beg + 30 .
  if SumsOnly = no then do:
    put stream outstream  "|" at beg .  assign beg = beg + 14 .
    put stream outstream  "|" at beg .  assign beg = beg + 15 .
    put stream outstream  "|" at beg .  assign beg = beg + 30 .
  end.
  if use-column[1]  = yes then do: put stream outstream  "|" at beg .  assign beg = beg + 14 .  end.
  if use-column[2]  = yes then do: put stream outstream  "|" at beg  "учет. цен)" format "X(13)" .      assign beg = beg + 14 .  end.
  if use-column[3]  = yes then do: put stream outstream  "|" at beg .  assign beg = beg + 14 .  end.
  if use-column[4]  = yes then do: put stream outstream  "|" at beg  "учет. цен)" format "X(13)" .     assign beg = beg + 14 .  end.
  if use-column[5]  = yes then do: put stream outstream  "|" at beg .  assign beg = beg + 14 .  end.
  if use-column[6]  = yes then do: put stream outstream  "|" at beg  "учет. цен)" format "X(13)" .      assign beg = beg + 14 .  end.
  if use-column[7]  = yes then do: put stream outstream  "|" at beg  "прод. цен)" format "X(13)" .      assign beg = beg + 14 .  end.
  if use-column[8]  = yes then do: put stream outstream  "|" at beg .  assign beg = beg + 14 .  end.
  if use-column[9]  = yes then do: put stream outstream  "|" at beg .  assign beg = beg + 10 .  end.
  if use-column[10] = yes then do: put stream outstream  "|" at beg .  assign beg = beg + 14 .  end.
  if use-column[11] = yes then do: put stream outstream  "|" at beg  "учет. цен)" format "X(13)" .      assign beg = beg + 14 .  end.
  if use-column[12] = yes then do: put stream outstream  "|" at beg  "прод. цен)" format "X(13)" .      assign beg = beg + 14 .  end.
  if use-column[13] = yes then do: put stream outstream  "|" at beg .  assign beg = beg + 14 .  end.
  if use-column[14] = yes then do: put stream outstream  "|" at beg .  assign beg = beg + 10 .  end.
  if use-column[15] = yes then do: put stream outstream  "|" at beg .  assign beg = beg + 14 .  end.
  if use-column[16] = yes then do: put stream outstream  "|" at beg  "учет. цен)" format "X(13)" .  assign beg = beg + 14 .  end.
  if use-column[17] = yes then do: put stream outstream  "|" at beg  "прод. цен)" format "X(13)" .  assign beg = beg + 14 .  end.
  if use-column[18] = yes then do: put stream outstream  "|" at beg .  assign beg = beg + 14 .  end.
  if use-column[19] = yes then do: put stream outstream  "|" at beg .  assign beg = beg + 10 .  end.
  if use-column[20] = yes then do: put stream outstream  "|" at beg .  assign beg = beg + 14 .  end.
  if use-column[21] = yes then do: put stream outstream  "|" at beg  "учет. цен)" format "X(13)" .     assign beg = beg + 14 .  end.
  if use-column[22] = yes then do: put stream outstream  "|" at beg  "прод. цен)" format "X(13)" .     assign beg = beg + 14 .  end.
  if use-column[23] = yes then do: put stream outstream  "|" at beg .  assign  beg = beg + 14 . end.
  if use-column[24] = yes then do: put stream outstream  "|" at beg .  assign  beg = beg + 10 . end.
  put stream outstream    "|"  at beg skip  Line format frmt skip .

end.


procedure PrintLine :
  do  on error undo, return error return-value  :
  if line-counter( Outstream ) + 2 > page-size( Outstream ) then do:
    put stream outstream  skip Line format frmt skip "продолжение - на следующей странице" AT 30 SKIP .
    page stream OutStream .
    run PrintTitul in this-procedure .
  end.
  if  ( v-row ) >= 63000 then do:
    Output stream Macr_Excel  close .
    run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name ) .
    run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
    output stream  Macr_Excel to value(v-file-name) .
    v-ind = v-ind + 1 .
    run PutColumnTitulExcel in this-procedure .
  end.

  for each temp-sum where temp-sum.level = -1 :   assign temp-sum.sum = 0  . end.

  assign jj = 1 .
  run Add-temp-sum (  gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 0, {&TDEDT_Pri_Vnesh}, -1, jj ) .     assign jj = jj + 1 .
  run Add-temp-sum (  gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 1, {&TDEDT_Pri_Vnesh}, -1, jj ) .     assign jj = jj + 1 .
  run Add-temp-sum (  gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 0, {&TDEDT_Ras_Vnesh_VP}, -1, jj ) .  assign jj = jj + 1 .
  run Add-temp-sum (  gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 1, {&TDEDT_Ras_Vnesh_VP}, -1, jj ) .  assign jj = jj + 1 .
  run Add-temp-sum (  gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 0, {&TDEDT_Ras_Vnesh}, -1, jj ) .     assign jj = jj + 1 .
  run Add-temp-sum (  gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 1, {&TDEDT_Ras_Vnesh}, -1, jj ) .     assign jj = jj + 1 .
  run Add-temp-sum (  gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 2, {&TDEDT_Ras_Vnesh}, -1, jj ) .     assign jj = jj + 1 .
  run Add-temp-sum (  gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 3, {&TDEDT_Ras_Vnesh}, -1, jj ) .     assign jj = jj + 1 .
  run Add-temp-sum (  gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 4, {&TDEDT_Ras_Vnesh}, -1, jj ) .     assign jj = jj + 1 .
  run Add-temp-sum (  gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 0, {&TDEDT_Vozvrat_Vnesh}, -1, jj ) . assign jj = jj + 1 .
  run Add-temp-sum (  gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 1, {&TDEDT_Vozvrat_Vnesh}, -1, jj ) . assign jj = jj + 1 .
  run Add-temp-sum (  gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 2, {&TDEDT_Vozvrat_Vnesh}, -1, jj ) . assign jj = jj + 1 .
  run Add-temp-sum (  gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 3, {&TDEDT_Vozvrat_Vnesh}, -1, jj ) . assign jj = jj + 1 .
  run Add-temp-sum (  gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 4, {&TDEDT_Vozvrat_Vnesh}, -1, jj ) . assign jj = jj + 1 .
  run Add-temp-sum (  gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 0, "rs-vz", -1, jj ) .                assign jj = jj + 1 .
  run Add-temp-sum (  gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 1, "rs-vz", -1, jj ) .                assign jj = jj + 1 .
  run Add-temp-sum (  gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 2, "rs-vz", -1, jj ) .                assign jj = jj + 1 .
  run Add-temp-sum (  gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 3, "rs-vz", -1, jj ) .                assign jj = jj + 1 .
  run Add-temp-sum (  gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 4, "rs-vz", -1, jj ) .                assign jj = jj + 1 .
  run Add-temp-sum (  gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 0, {&TDEDT_Spi_Vnesh}, -1, jj ) .     assign jj = jj + 1 .
  run Add-temp-sum (  gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 1, {&TDEDT_Spi_Vnesh}, -1, jj ) .     assign jj = jj + 1 .
  run Add-temp-sum (  gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 2, {&TDEDT_Spi_Vnesh}, -1, jj ) .     assign jj = jj + 1 .
  run Add-temp-sum (  gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 2, "eff-val", -1, jj ) .              assign jj = jj + 1 .
  run Add-temp-sum (  gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 4, "eff-prc", -1, jj ) .              assign jj = jj + 1 .

  define variable null-oborot as logical no-undo .
  assign null-oborot = yes .
  for each temp-sum  where temp-sum.level = -1 :
    if temp-sum.sum <> 0 then do:
      assign null-oborot = no .
      leave.
    end.
  end.
  if null-oborot = no and SumsOnly = no  then do:

    assign
      v-col = 1
      beg   = 1
    .
    put stream outstream  "|" at beg  .
    assign v-col = v-col + 1    beg = beg + 30 .
    if SumsOnly = no then do:
      put stream outstream  "|" at beg  gds-prop.b-code   format "X(13)" .
      run macr_excel_char (string(gds-prop.b-code), v-row, v-col) .
      assign v-col = v-col + 1    beg = beg + 14 .
      put stream outstream  "|" at beg  gds-prop.artic    format "X(14)" .
      run macr_excel_char (string(gds-prop.artic), v-row, v-col) .
      assign v-col = v-col + 1    beg = beg + 15 .
      put stream outstream  "|" at beg  gds-prop.gds-name format "X(29)" .
      run macr_excel_char (string(gds-prop.gds-name), v-row, v-col) .
      assign v-col = v-col + 1    beg = beg + 30 .
    end.

    for each temp-sum where temp-sum.level = -1 :
      if use-column[ temp-sum.num ] = no then next .
      case temp-sum.sum-type :
        when 0 then do:
          put stream outstream  "|" at beg temp-sum.sum format frm-qnty  .
          run macr_excel_sum (temp-sum.sum, v-row, v-col, sz-qnty) .
          assign  beg = beg + 14 .
        end.
        when 1 or when 2 or when 3 then do:
          put stream outstream  "|" at beg temp-sum.sum format frm-sum .
          run macr_excel_sum (temp-sum.sum, v-row, v-col, 2) .
          assign  beg = beg + 14 .
        end.
        when 4 then do:
          put stream outstream  "|" at beg temp-sum.sum format frm-prc .
          run macr_excel_sum (temp-sum.sum, v-row, v-col, 2) .
          assign  beg = beg + 10 .
        end.
      end.
      assign v-col = v-col + 1 .
    end.
    put stream outstream   "|"  skip .
    assign v-row = v-row + 1 .
  end.

  do ii = 1 to 5:
    run CalculSum in this-procedure (ii) . /* суммирование по ... */
  end.
  /* ********************************************************************************************* */

  /*  А теперь смотрим шкалу */

  /* ********************************************************************************************* */

  if gds-prop.empty-scale = no and SumsOnly = no then do: /* это шкальный товар */
    run PrintScale .
  end.

  end.
end procedure. /* PrintLine */



procedure PrintScale :
  do
  on error undo, return error return-value
  :
    if line-counter( Outstream ) + 2 > page-size( Outstream ) then do:
      put stream outstream  skip Line format frmt skip "продолжение - на следующей странице" AT 30 SKIP .
      page stream OutStream .
      run PrintTitul in this-procedure .
    end.
    if  ( v-row ) >= 63000 then do:
      Output stream Macr_Excel  close .
      run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name ) .
      run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
      output stream  Macr_Excel to value(v-file-name) .
      v-ind = v-ind + 1 .
      run PutColumnTitulExcel in this-procedure .
    end.


    for each temp-prt
      where temp-prt.gds-code = gds-prop.gds-code and temp-prt.prt-code > - 1
      break by temp-prt.prt-code :

      if first-of ( temp-prt.prt-code ) then do:
        for each temp-sum where temp-sum.level = -2 : assign temp-sum.sum = 0 . end.
        assign jj = 1 .
        run Add-temp-sum ( gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 0, {&TDEDT_Pri_Vnesh},     temp-prt.prt-code, jj ) . assign jj = jj + 1 .
        run Add-temp-sum ( gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 1, {&TDEDT_Pri_Vnesh},     temp-prt.prt-code, jj ) . assign jj = jj + 1 .
        run Add-temp-sum ( gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 0, {&TDEDT_Ras_Vnesh_VP},  temp-prt.prt-code, jj ) . assign jj = jj + 1 .
        run Add-temp-sum ( gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 1, {&TDEDT_Ras_Vnesh_VP},  temp-prt.prt-code, jj ) . assign jj = jj + 1 .
        run Add-temp-sum ( gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 0, {&TDEDT_Ras_Vnesh},     temp-prt.prt-code, jj ) . assign jj = jj + 1 .
        run Add-temp-sum ( gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 1, {&TDEDT_Ras_Vnesh},     temp-prt.prt-code, jj ) . assign jj = jj + 1 .
        run Add-temp-sum ( gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 2, {&TDEDT_Ras_Vnesh},     temp-prt.prt-code, jj ) . assign jj = jj + 1 .
        run Add-temp-sum ( gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 3, {&TDEDT_Ras_Vnesh},     temp-prt.prt-code, jj ) . assign jj = jj + 1 .
        run Add-temp-sum ( gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 4, {&TDEDT_Ras_Vnesh},     temp-prt.prt-code, jj ) . assign jj = jj + 1 .
        run Add-temp-sum ( gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 0, {&TDEDT_Vozvrat_Vnesh}, temp-prt.prt-code, jj ) . assign jj = jj + 1 .
        run Add-temp-sum ( gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 1, {&TDEDT_Vozvrat_Vnesh}, temp-prt.prt-code, jj ) . assign jj = jj + 1 .
        run Add-temp-sum ( gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 2, {&TDEDT_Vozvrat_Vnesh}, temp-prt.prt-code, jj ) . assign jj = jj + 1 .
        run Add-temp-sum ( gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 3, {&TDEDT_Vozvrat_Vnesh}, temp-prt.prt-code, jj ) . assign jj = jj + 1 .
        run Add-temp-sum ( gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 4, {&TDEDT_Vozvrat_Vnesh}, temp-prt.prt-code, jj ) . assign jj = jj + 1 .
        run Add-temp-sum ( gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 0, "rs-vz",                temp-prt.prt-code, jj ) . assign jj = jj + 1 .
        run Add-temp-sum ( gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 1, "rs-vz",                temp-prt.prt-code, jj ) . assign jj = jj + 1 .
        run Add-temp-sum ( gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 2, "rs-vz",                temp-prt.prt-code, jj ) . assign jj = jj + 1 .
        run Add-temp-sum ( gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 3, "rs-vz",                temp-prt.prt-code, jj ) . assign jj = jj + 1 .
        run Add-temp-sum ( gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 4, "rs-vz",                temp-prt.prt-code, jj ) . assign jj = jj + 1 .
        run Add-temp-sum ( gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 0, {&TDEDT_Spi_Vnesh},     temp-prt.prt-code, jj ) . assign jj = jj + 1 .
        run Add-temp-sum ( gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 1, {&TDEDT_Spi_Vnesh},     temp-prt.prt-code, jj ) . assign jj = jj + 1 .
        run Add-temp-sum ( gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 2, {&TDEDT_Spi_Vnesh},     temp-prt.prt-code, jj ) . assign jj = jj + 1 .
        run Add-temp-sum ( gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 2, "eff-val",              temp-prt.prt-code, jj ) . assign jj = jj + 1 .
        run Add-temp-sum ( gds-prop.gds-code, gds-prop.cli-type, gds-prop.cli-code, gds-prop.s-ind, 4, "eff-prc",              temp-prt.prt-code, jj ) . assign jj = jj + 1 .

        define variable  null-oborot1 as logical  no-undo .
        assign null-oborot1 = yes .
        for each temp-sum  where temp-sum.level = -2 :
          if temp-sum.sum <> 0 and temp-sum.sum <> ? then do:
            assign null-oborot1 = no .
            leave.
          end.
        end.
        if null-oborot1 = yes then next .
        assign
          v-col = 2
          beg   = 1
        .
        put stream outstream  "|" at beg .  assign beg = beg + 30 .
        put stream outstream  "|" at beg temp-prt.b-code format ">>>>>>>>>>>>9" .
        run macr_excel_char (string(temp-prt.b-code), v-row, v-col) .
        assign v-col = v-col + 2    beg = beg + 29 .
        FIND FIRST ub.gds-prt WHERE ub.gds-prt.node-code  = temp-prt.prt-code NO-LOCK no-error .
        put stream outstream  "|" at beg '  /'+ ub.gds-prt.f-name format "X(29)" .
        run macr_excel_char ('  /'+ ub.gds-prt.f-name, v-row, v-col) .
        assign v-col = v-col + 1    beg = beg + 30 .

        for each temp-sum where temp-sum.level = -2 :
          if use-column[ temp-sum.num ] = no then next .
          case temp-sum.sum-type :
            when 0 then do:
              put stream outstream  "|" at beg temp-sum.sum format frm-qnty  .
              run macr_excel_sum (temp-sum.sum, v-row, v-col, sz-qnty) .
              assign  beg = beg + 14 .
            end.
            when  2 then do:
              put stream outstream  "|" at beg temp-sum.sum format frm-sum .
              run macr_excel_sum (temp-sum.sum, v-row, v-col, 2) .
              assign  beg = beg + 14 .
            end.
            when 1 or when 3 then do:
              put stream outstream  "|" at beg .
              assign  beg = beg + 14 .
            end.
            when 4 then do:
              put stream outstream  "|" at beg .
              assign  beg = beg + 10 .
            end.
          end.
          assign v-col = v-col + 1 .
        end.
        put stream outstream   "|" at beg skip .
        assign v-row = v-row + 1 .
      end.
    end.
  end.

end procedure. /* PrintScale */




procedure for-each1 :
  do
  on error undo, return error return-value
  :
    for each gds-prop
      break by gds-prop.prod-type
            by gds-prop.prod-code
            by gds-prop.cli-name
            by gds-prop.grp-name
            by {&Sort-pole}
            by gds-prop.gds-code :
      if first-of(gds-prop.prod-code) then do:
        find first buf_clients no-lock where buf_clients.obj-type = gds-prop.prod-type and buf_clients.obj-code = gds-prop.prod-code .
        put stream outstream  "|" string("Производитель " + buf_clients.obj-name) format "X(49)" "|" at print-o skip .
        run macr_excel_char ("Производитель " + buf_clients.obj-name, v-row, 1) .              assign v-row = v-row + 1 .
        for each temp-sum where temp-sum.level = 2 : assign temp-sum.sum = 0 . end.
      End.
      if first-of(gds-prop.cli-name) then do:
        run GetName in this-procedure (output ItogStr1).
        if SumsOnly = no then do:
          put stream outstream  "|" ItogStr1 format "X(49)" "|" at print-o skip .
          run macr_excel_char (ItogStr1, v-row, 1) .          assign v-row = v-row + 1 .
        end.
        for each temp-sum where temp-sum.level = 3 : assign temp-sum.sum = 0 . end.
      End.
      if first-of(gds-prop.grp-name) then do:
        put stream outstream  "|" string("Группа " + gds-prop.grp-name) format "X(59)" "|" at print-o skip .
        run macr_excel_char ("Группа " + gds-prop.grp-name, v-row, 1) .              assign v-row = v-row + 1 .
        for each temp-sum where temp-sum.level = 4 : assign temp-sum.sum = 0 . end.
      End.

      if last-of(gds-prop.gds-code) then do:
        run PrintLine in this-procedure .     /* вывод данных            */
      End.

      if last-of(gds-prop.cli-name) then do:
        run PutItogSum in this-procedure ("Итого по " + ItogStr1, 3) .  /* вывод сумм */
      End.
      if last-of(gds-prop.prod-code) then do:
        assign ItogStr = "Итого по производителю " .
        run PutItogSum in this-procedure ( ItogStr, 2) .  /* вывод сумм */
      End.
    end.
  end.

end procedure. /* for-each1 */


procedure for-each2 :
  do
  on error undo, return error return-value
  :
    for each gds-prop
      break by gds-prop.prod-type
            by gds-prop.prod-code
            by gds-prop.s-ind
            by gds-prop.cli-name
            by gds-prop.grp-name
            by {&Sort-pole}
            by gds-prop.gds-code :
      if first-of(gds-prop.prod-code) then do:
        find first buf_clients no-lock where buf_clients.obj-type = gds-prop.prod-type and buf_clients.obj-code = gds-prop.prod-code .
        put stream outstream  "|" string("Производитель " + buf_clients.obj-name) format "X(49)" "|" at print-o skip .
        run macr_excel_char ("Производитель " + buf_clients.obj-name, v-row, 1) .              assign v-row = v-row + 1 .
        for each temp-sum where temp-sum.level = 2 : assign temp-sum.sum = 0 . end.
      End.
      if first-of(gds-prop.s-ind) then do:
        run GetName in this-procedure (output ItogStr1).
        put stream outstream  "|" ItogStr1 format "X(49)" "|" at print-o skip .
        run macr_excel_char (ItogStr1, v-row, 1) .          assign v-row = v-row + 1 .


        for each temp-sum where temp-sum.level = 3 : assign temp-sum.sum = 0 . end.
      End.
      if first-of(gds-prop.cli-name) then do:
        if SumsOnly = no then do:
          put stream outstream  "|" gds-prop.cli-name format "X(29)" "|" at print-o skip .
          run macr_excel_char (gds-prop.cli-name, v-row, 1) .              assign v-row = v-row + 1 .

        End.
        for each temp-sum where temp-sum.level = 5 : assign temp-sum.sum = 0 . end.
      End.
      if first-of(gds-prop.grp-name) then do:
        put stream outstream  "|" string("Группа " + gds-prop.grp-name) format "X(59)" "|" at print-o skip .
        run macr_excel_char ("Группа " + gds-prop.grp-name, v-row, 1) .              assign v-row = v-row + 1 .
        for each temp-sum where temp-sum.level = 4 : assign temp-sum.sum = 0 . end.
      End.

      if first-of(gds-prop.gds-code) then do:
        run PrintLine in this-procedure .     /* вывод данных            */
      End.

      if last-of(gds-prop.cli-name) then do:
        assign ItogStr = "Итого по " + gds-prop.cli-name .
        run PutItogSum in this-procedure ( ItogStr, 5) .  /* вывод сумм */
      End.

      if last-of(gds-prop.s-ind) then do:
        run PutItogSum in this-procedure ("Итого по " + ItogStr1, 3) .  /* вывод сумм */
      End.

      if last-of(gds-prop.prod-code) then do:
        assign ItogStr = "Итого по производителю " .
        run PutItogSum in this-procedure ( ItogStr, 2) .  /* вывод сумм */
      End.
    end.
  End. /*for each gds-prop */

end procedure. /* for-each2 */



procedure for-each3 :
  do
  on error undo, return error return-value
  :
    for each gds-prop
      break by gds-prop.prod-type
            by gds-prop.prod-code
            by gds-prop.cli-name
            by {&Sort-pole}
            by gds-prop.gds-code :
      if first-of(gds-prop.prod-code) then do:
        find first buf_clients no-lock where buf_clients.obj-type = gds-prop.prod-type and buf_clients.obj-code = gds-prop.prod-code .
        put stream outstream  "|" string("Производитель " + buf_clients.obj-name) format "X(49)" "|" at print-o skip .
        run macr_excel_char ("Производитель " + buf_clients.obj-name, v-row, 1) .              assign v-row = v-row + 1 .
        for each temp-sum where temp-sum.level = 2 : assign temp-sum.sum = 0 . end.
      End.
      if first-of(gds-prop.cli-name) then do:
        run GetName in this-procedure (output ItogStr1).
        if SumsOnly = no then do:
          put stream outstream  "|" ItogStr1 format "X(49)" "|" at print-o skip .
          run macr_excel_char (ItogStr1, v-row, 1) .          assign v-row = v-row + 1 .
        end.
        for each temp-sum where temp-sum.level = 3 : assign temp-sum.sum = 0 . end.
      End.

      if first-of(gds-prop.gds-code) then do:
        run PrintLine in this-procedure .     /* вывод данных            */
      End.

      if last-of(gds-prop.cli-name) then do:
        run PutItogSum in this-procedure ("Итого по " + ItogStr1, 3) .  /* вывод сумм */
      End.
      if last-of(gds-prop.prod-code) then do:
        assign ItogStr = "Итого по производителю " .
        run PutItogSum in this-procedure ( ItogStr, 2) .  /* вывод сумм */
      End.
    end.
  end.

end procedure. /* for-each3 */


procedure for-each4 :
  do
  on error undo, return error return-value
  :
    for each gds-prop
      break by gds-prop.prod-type
            by gds-prop.prod-code
            by gds-prop.s-ind
            by gds-prop.cli-name
            by {&Sort-pole}
            by gds-prop.gds-code :
      if first-of(gds-prop.prod-code) then do:
        find first buf_clients no-lock where buf_clients.obj-type = gds-prop.prod-type and buf_clients.obj-code = gds-prop.prod-code .
        put stream outstream  "|" string("Производитель " + buf_clients.obj-name) format "X(49)" "|" at print-o skip .
        run macr_excel_char ("Производитель " + buf_clients.obj-name, v-row, 1) .              assign v-row = v-row + 1 .
        for each temp-sum where temp-sum.level = 2 : assign temp-sum.sum = 0 . end.
      End.
      if first-of(gds-prop.s-ind) then do:
        run GetName in this-procedure (output ItogStr1).
        put stream outstream  "|" ItogStr1 format "X(49)" "|" at print-o skip .
        run macr_excel_char (ItogStr1, v-row, 1) .          assign v-row = v-row + 1 .


        for each temp-sum where temp-sum.level = 3 : assign temp-sum.sum = 0 . end.
      End.
      if first-of(gds-prop.cli-name) then do:
        if SumsOnly = no then do:
          put stream outstream  "|" gds-prop.cli-name format "X(29)" "|" at print-o skip .
          run macr_excel_char (gds-prop.cli-name, v-row, 1) .              assign v-row = v-row + 1 .

        End.
        for each temp-sum where temp-sum.level = 5 : assign temp-sum.sum = 0 . end.
      End.

      if first-of(gds-prop.gds-code) then do:
        run PrintLine in this-procedure .     /* вывод данных            */
      End.

      if last-of(gds-prop.cli-name) then do:
        assign ItogStr = "Итого по " + gds-prop.cli-name .
        run PutItogSum in this-procedure ( ItogStr, 5) .  /* вывод сумм */
      End.

      if last-of(gds-prop.s-ind) then do:
        if ItogStr1 = ? then run PutItogSum in this-procedure ("Итого по ?", 3) .  /* вывод сумм */
        else run PutItogSum in this-procedure ("Итого по " + ItogStr1, 3) .  /* вывод сумм */
      End.

      if last-of(gds-prop.prod-code) then do:
        assign ItogStr = "Итого по производителю " .
        run PutItogSum in this-procedure ( ItogStr, 2) .  /* вывод сумм */
      End.
    end.
  End. /*for each gds-prop */

end procedure. /* for-each4 */

