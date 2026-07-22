block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-obfin.p $
$Archive: rep/r-obfin.p $

Оборот финансов с разбивкой по основаниям

Автор: Демин Алексей Сергеевич
Дата создания: 09/14/05
Author: Alexey Demin
Creation date: 09/14/05

*/

define input parameter p-radio-schet as integer   no-undo .
define input parameter p-curr-code   as integer   no-undo .
define input parameter p-type        as integer   no-undo .
define input parameter p-nal         as logical   no-undo .
define input parameter p-akt         as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-obfin.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-obfin.p $":U .
define variable vss-description as character no-undo init "Оборот финансов с разбивкой по основаниям за период".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ trg/factord.i  }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
/*{ gbl/paramls.i }*/
/*{ rep/mcrexcel.i }*/
{ gbl/cur-time.i }

define Stream OutStream.

do
on error undo, return error
:

DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
ASSIGN parParentProc =  my-handle .
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/prn-lib.i }
{ cmp/library.i }

define variable v-curr-r-b as integer   no-undo .
{ gbl/basecode.i v-cntxt-host-code-obj v-curr-r-b }


/*define variable make-excel as logical   no-undo .*/

  &scop L1    1
  &scop L2    42
  &scop D1    24
  &scop F1    "X(40)"
  &scop F2    "->>>,>>>,>>>,>>>,>>9.99"

  define variable ii as integer initial 0  no-undo .
/*  define variable str as character no-undo .*/
/*  assign str = '"X(' + string(ii) + ")" .*/
/*  &scop FL    str*/

  DEFINE temp-table temp-schet no-undo
    field   r-schet      as character
    field   bank         as character
    field   code         as integer
    field   curr         as integer
    field   s-curr       as character
    field   sum1         as decimal
    field   sum2         as decimal
    INDEX pi  IS PRIMARY   code
  .

  DEFINE temp-table temp-code no-undo
    field   num          as character
    field   name         as character
    field   code         as integer
    field   lavel1       as integer
    field   lavel2       as integer
    field   lavel3       as integer
    INDEX pi  IS PRIMARY   num
    INDEX pi1              code
    INDEX pi2              lavel1
    INDEX pi3              lavel2
    INDEX pi4              lavel3
  .

  DEFINE temp-table temp-sum no-undo
    field   sum-in       as decimal
    field   sum-out      as decimal
    field   sum-in-rubl  as decimal
    field   sum-in-base  as decimal
    field   sum-out-rubl as decimal
    field   sum-out-base as decimal
    field   code-fin     as integer
    field   code-schet   as integer
    INDEX pi  IS PRIMARY   code-fin
    INDEX pi1              code-schet
  .


  define variable  v-fact-order-start     as decimal   no-undo .
  define variable  v-fact-order-end       as decimal   no-undo .
  run day-begin-fact-order in this-procedure ( input x-date-start,        output v-fact-order-start ). /*Поиск нач fact-order*/
  run day-begin-fact-order in this-procedure ( input ( x-date-end + 1 ),  output v-fact-order-end ). /*Поиск посл fact-order*/

  define variable v-ind             as integer   no-undo .
  define variable Counter1               as integer   no-undo .
  define variable Line                   as character no-undo .
  define variable jj as integer initial 0 no-undo .
  define variable is-null as logical   no-undo .

  define variable s-val as character no-undo .
/*  if x-SET_val_TYPE = 1 then assign s-val = "{&abbr_rubl}." .*/
/*  else                       assign s-val = "б.вал." .*/

   define variable ost-beg-rubl    as decimal no-undo .
   define variable ost-beg-base    as decimal no-undo .
   define variable ost-end-rubl    as decimal no-undo .
   define variable ost-end-base    as decimal no-undo .
   define variable sum1            as decimal no-undo .
   define variable sum2            as decimal no-undo .
   define variable sum-rubl     as decimal no-undo .
   define variable sum-base     as decimal no-undo .

  assign  Counter1 = 0 .
  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 10 } /* Показать окно информации о текущем процессе */

  define buffer buf_arh-fin-doc-schet   for arh-fin-doc-schet .
  define buffer buf_arh-fin-doc-an      for arh-fin-doc-an .
  define buffer buf_arh-fin-doc-an-nal  for arh-fin-doc-an-nal .
  define buffer buf_fin-schet           for fin-schet .
  define buffer buf_fin-bank            for fin-bank .
  define buffer buf_currency            for currency .
  define buffer b_fin-code-cor-acc for fin-code-cor-acc .

  if p-radio-schet <> 7 then assign p-curr-code = 0 .
  case p-radio-schet :
    when 7 or when 5 then do: /* выбраная валюта */
      for each buf_fin-schet no-lock
        where buf_fin-schet.host-code = v-cntxt-host-code-obj
          and buf_fin-schet.cli-code  = v-cntxt-host-code-obj
          and buf_fin-schet.cli-type  = {&cmp}
          and buf_fin-schet.curr-code = p-curr-code :
        { rep/r-obfin1.i } /* смотрим и кладем в темп-тейбл  */
      end.
    end.
    when 3 or when 4 then do:  /* список счетов */
      do ii = 1 to num-entries ( fin-schet-recid ) :
        find first buf_fin-schet no-lock where recid(buf_fin-schet) = int(entry(ii,fin-schet-recid)) .
        { rep/r-obfin1.i } /* смотрим и кладем в темп-тейбл  */
      end.
    end.
  end.


  create temp-code .
    assign
      temp-code.num    = ""
      temp-code.name   = "Без основания"
      temp-code.code   = 0
      temp-code.lavel1 = 0
      temp-code.lavel2 = 0
      temp-code.lavel3 = 0
    .

  case p-type : /*список возможных оснований */
    when 1 then do: /* Корреспондирующий счет */
      for each fin-code-cor-acc no-lock where fin-code-cor-acc.host-code = v-cntxt-host-code-obj :
        find first buf_arh-fin-doc-an no-lock
          where buf_arh-fin-doc-an.host-code         = v-cntxt-host-code-obj
            and buf_arh-fin-doc-an.fin-code-cor-acc  = fin-code-cor-acc.fin-code
            and buf_arh-fin-doc-an.fact-order       >= v-fact-order-start
            and buf_arh-fin-doc-an.fact-order       <= v-fact-order-end
        no-error .
        if not available buf_arh-fin-doc-an then do:
          if (p-nal or p-akt) then do:
            find first buf_arh-fin-doc-an-nal no-lock
              where buf_arh-fin-doc-an-nal.host-code         = v-cntxt-host-code-obj
                and buf_arh-fin-doc-an-nal.fin-code-cor-acc  = fin-code-cor-acc.fin-code
                and buf_arh-fin-doc-an-nal.fact-order       >= v-fact-order-start
                and buf_arh-fin-doc-an-nal.fact-order       <= v-fact-order-end
              no-error .
            if not available buf_arh-fin-doc-an-nal then next .
          end.
          else next .
        end.
        find first temp-code where temp-code.code = fin-code-cor-acc.fin-code no-error .
        if not available temp-code then do:
          create temp-code .
          assign
            temp-code.num    = fin-code-cor-acc.code-value
            temp-code.name   = fin-code-cor-acc.descr
            temp-code.code   = fin-code-cor-acc.fin-code
            temp-code.lavel1 = fin-code-cor-acc.level-1
            temp-code.lavel2 = fin-code-cor-acc.level-2
            temp-code.lavel3 = fin-code-cor-acc.level-3
          .
        end.
      end.
    end.
    when 2 then do: /* Код аналитического учета */
      for each fin-code-an-uchet no-lock where fin-code-an-uchet.host-code = v-cntxt-host-code-obj :
        find first buf_arh-fin-doc-an no-lock
          where buf_arh-fin-doc-an.host-code         = v-cntxt-host-code-obj
            and buf_arh-fin-doc-an.fin-code-an-uchet = fin-code-an-uchet.fin-code
            and buf_arh-fin-doc-an.fact-order       >= v-fact-order-start
            and buf_arh-fin-doc-an.fact-order       <= v-fact-order-end
        no-error .
        if not available buf_arh-fin-doc-an then do:
          if (p-nal or p-akt) then do:
            find first buf_arh-fin-doc-an-nal no-lock
              where buf_arh-fin-doc-an-nal.host-code         = v-cntxt-host-code-obj
                and buf_arh-fin-doc-an-nal.fin-code-an-uchet  = fin-code-an-uchet.fin-code
                and buf_arh-fin-doc-an-nal.fact-order       >= v-fact-order-start
                and buf_arh-fin-doc-an-nal.fact-order       <= v-fact-order-end
              no-error .
            if not available buf_arh-fin-doc-an-nal then next .
          end.
          else next .
        end.
        find first temp-code where temp-code.code = fin-code-an-uchet.fin-code no-error .
        if not available temp-code then do:
          create temp-code .
          assign
            temp-code.num    = fin-code-an-uchet.code-value
            temp-code.name   = fin-code-an-uchet.descr
            temp-code.code   = fin-code-an-uchet.fin-code
            temp-code.lavel1 = fin-code-an-uchet.level-1
            temp-code.lavel2 = fin-code-an-uchet.level-2
            temp-code.lavel3 = fin-code-an-uchet.level-3
          .
        end.
      end.
    end.
    when 3 then do: /* Код целевого назначени  */
      for each fin-code-cel-nazn no-lock where fin-code-cel-nazn.host-code = v-cntxt-host-code-obj :
        find first buf_arh-fin-doc-an no-lock
          where buf_arh-fin-doc-an.host-code         = v-cntxt-host-code-obj
            and buf_arh-fin-doc-an.fin-code-cel-nazn = fin-code-cel-nazn.fin-code
            and buf_arh-fin-doc-an.fact-order       >= v-fact-order-start
            and buf_arh-fin-doc-an.fact-order       <= v-fact-order-end
        no-error .
        if not available buf_arh-fin-doc-an then do:
          if (p-nal or p-akt) then do:
            find first buf_arh-fin-doc-an-nal no-lock
              where buf_arh-fin-doc-an-nal.host-code         = v-cntxt-host-code-obj
                and buf_arh-fin-doc-an-nal.fin-code-cel-nazn  = fin-code-cel-nazn.fin-code
                and buf_arh-fin-doc-an-nal.fact-order       >= v-fact-order-start
                and buf_arh-fin-doc-an-nal.fact-order       <= v-fact-order-end
            no-error .
            if not available buf_arh-fin-doc-an-nal then next .
          end.
          else next .
        end.
        find first temp-code where temp-code.code = fin-code-cel-nazn.fin-code no-error .
        if not available temp-code then do:
          create temp-code .
          assign
            temp-code.num    = fin-code-cel-nazn.code-value
            temp-code.name   = fin-code-cel-nazn.descr
            temp-code.code   = fin-code-cel-nazn.fin-code
            temp-code.lavel1 = fin-code-cel-nazn.level-1
            temp-code.lavel2 = fin-code-cel-nazn.level-2
            temp-code.lavel3 = fin-code-cel-nazn.level-3
          .
        end.
      end.
    end.
  end.


  if p-nal then do: /* учитаваем наличные */
    find first buf_currency no-lock where buf_currency.curr-code = p-curr-code .

    create temp-schet .
    assign
      temp-schet.r-schet = "Наличные"
      temp-schet.code    = 0
      temp-schet.curr    = p-curr-code
      temp-schet.s-curr  = buf_currency.curr-abbr
      temp-schet.bank    = ""
      jj = jj + 1
    .
    /* считаем остаток на начало */
    /* приходы */
    run CalcOst1 (input {&income-cash}, input p-curr-code, input 0, input v-fact-order-start, output sum1) .
    assign temp-schet.sum1 = sum1 .  /* в валюте счета */
    if p-curr-code = 0 then  assign ost-beg-rubl = ost-beg-rubl + sum1 .
    else do:
      run CalcOst1 (input {&income-cash}, input 0, input 0, input v-fact-order-start, output sum1) .
      assign  ost-beg-rubl = ost-beg-rubl + sum1 .  /* в   р у б л я х  */
    end.
    run CalcOst1 (input {&income-cash}, input v-curr-r-b, input 0, input v-fact-order-start, output sum1) .
    assign  ost-beg-base = ost-beg-base + sum1 .  /* в Б вал  */

    /* расходы */
    run CalcOst1 (input {&expense-cash}, input p-curr-code, input 0, input v-fact-order-start, output sum1) .
    assign temp-schet.sum1 = temp-schet.sum1 - sum1 .  /* в валюте счета */
    if p-curr-code = 0 then assign ost-beg-rubl = ost-beg-rubl - sum1 .
    else do:
      run CalcOst1 (input {&expense-cash}, input 0, input 0, input v-fact-order-start, output sum1) .
      assign  ost-beg-rubl = ost-beg-rubl - sum1 .  /* в   р у б л я х  */
    end.
    run CalcOst1 (input {&expense-cash}, input v-curr-r-b, input 0, input v-fact-order-start, output sum1) .
    assign  ost-beg-base = ost-beg-base - sum1 .  /* в Б вал  */

    /* считаем остаток на конец */
    /* приходы */
    run CalcOst1 (input {&income-cash}, input p-curr-code, input 0, input v-fact-order-end, output sum1) .
    assign temp-schet.sum2 = sum1 .  /* в валюте счета */
    if p-curr-code = 0 then assign ost-end-rubl = ost-end-rubl + sum1 .
    else do:
      run CalcOst1 (input {&income-cash}, input 0, input 0, input v-fact-order-end, output sum1) .
      assign  ost-end-rubl = ost-end-rubl + sum1 .  /* в   р у б л я х  */
    end.
    run CalcOst1 (input {&income-cash}, input v-curr-r-b, input 0, input v-fact-order-end, output sum1) .
    assign  ost-end-base = ost-end-base + sum1 .  /* в Б вал  */

    /* расходы */
    run CalcOst1 (input {&expense-cash}, input p-curr-code, input 0, input v-fact-order-end, output sum1) .
    assign temp-schet.sum2 = temp-schet.sum2 - sum1 .  /* в валюте счета */
    if p-curr-code = 0 then  assign ost-end-rubl = ost-end-rubl - sum1 .
    else do:
      run CalcOst1 (input {&expense-cash}, input 0, input 0, input v-fact-order-end, output sum1) .
      assign  ost-end-rubl = ost-end-rubl - sum1 .  /* в   р у б л я х  */
    end.
    run CalcOst1 (input {&expense-cash}, input v-curr-r-b, input 0, input v-fact-order-end, output sum1) .
    assign  ost-end-base = ost-end-base - sum1 .  /* в Б вал  */
  end.

  if p-akt then do: /* учитаваем АПЗ */
    find first buf_currency no-lock where buf_currency.curr-code = p-curr-code .

    create temp-schet .
    assign
      temp-schet.r-schet = "АПЗ"
      temp-schet.code    = - 1
      temp-schet.curr    = p-curr-code
      temp-schet.s-curr  = buf_currency.curr-abbr
      temp-schet.bank    = ""
      jj = jj + 1
    .

    assign Counter1 = Counter1 + 1.
    { rep/repfrm.i disp Counter1 }

    /* считаем остаток на начало */
    /* приходы */
    run CalcOst1 (input {&income-payoff}, input p-curr-code, input 0, input v-fact-order-start, output sum1) .
    assign temp-schet.sum1 = sum1 .  /* в валюте счета */
    if p-curr-code = 0 then  assign ost-beg-rubl = ost-beg-rubl + sum1 .
    else do:
      run CalcOst1 (input {&income-payoff}, input 0, input 0, input v-fact-order-start, output sum1) .
      assign  ost-beg-rubl = ost-beg-rubl + sum1 .  /* в   р у б л я х  */
    end.
    run CalcOst1 (input {&income-payoff}, input v-curr-r-b, input 0, input v-fact-order-start, output sum1) .
    assign  ost-beg-base = ost-beg-base + sum1 .  /* в Б вал  */

    /* расходы */
    run CalcOst1 (input {&expense-payoff}, input p-curr-code, input 0, input v-fact-order-start, output sum1) .
    assign temp-schet.sum1 = temp-schet.sum1 - sum1 .  /* в валюте счета */
    if p-curr-code = 0 then  assign ost-beg-rubl = ost-beg-rubl - sum1 .
    else do:
      run CalcOst1 (input {&expense-payoff}, input 0, input 0, input v-fact-order-start, output sum1) .
      assign  ost-beg-rubl = ost-beg-rubl - sum1 .  /* в   р у б л я х  */
    end.
    run CalcOst1 (input {&expense-payoff}, input v-curr-r-b, input 0, input v-fact-order-start, output sum1) .
    assign  ost-beg-base = ost-beg-base - sum1 .  /* в Б вал  */

    /* считаем остаток на конец */
    /* приходы */
    run CalcOst1 (input {&income-payoff}, input p-curr-code, input 0, input v-fact-order-end, output sum1) .
    assign temp-schet.sum2 = sum1 .  /* в валюте счета */
    if p-curr-code = 0 then  assign ost-end-rubl = ost-end-rubl + sum1 .
    else do:
      run CalcOst1 (input {&income-payoff}, input 0, input 0, input v-fact-order-end, output sum1) .
      assign  ost-end-rubl = ost-end-rubl + sum1 .  /* в   р у б л я х  */
    end.
    run CalcOst1 (input {&income-payoff}, input v-curr-r-b, input 0, input v-fact-order-end, output sum1) .
    assign  ost-end-base = ost-end-base + sum1 .  /* в Б вал  */

    /* расходы */
    run CalcOst1 (input {&expense-payoff}, input p-curr-code, input 0, input v-fact-order-end, output sum1) .
    assign temp-schet.sum2 = temp-schet.sum2 - sum1 .  /* в валюте счета */
    if p-curr-code = 0 then  assign ost-end-rubl = ost-end-rubl - sum1 .
    else do:
      run CalcOst1 (input {&expense-payoff}, input 0, input 0, input v-fact-order-end, output sum1) .
      assign  ost-end-rubl = ost-end-rubl - sum1 .  /* в   р у б л я х  */
    end.
    run CalcOst1 (input {&expense-payoff}, input v-curr-r-b, input 0, input v-fact-order-end, output sum1) .
    assign  ost-end-base = ost-end-base - sum1 .  /* в Б вал  */
  end.


  define variable str as character no-undo .
  define variable len as integer   no-undo .
  assign len = {&L2} + (jj + 2) * {&D1} - 1 .
  assign str = '"X(' + string( len ) + ")" .
  &scop FL    str


  /* теперь ищем приходы и расходы */
  for each temp-code :
    for each temp-schet :
      create temp-sum .
      assign
        temp-sum.sum-in       = 0
        temp-sum.sum-out      = 0
        temp-sum.sum-in-rubl  = 0
        temp-sum.sum-out-base = 0
        temp-sum.sum-in-rubl  = 0
        temp-sum.sum-out-base = 0
        temp-sum.code-fin     = temp-code.code
        temp-sum.code-schet   = temp-schet.code
      .
      assign Counter1 = Counter1 + 1.
      { rep/repfrm.i disp Counter1 }

      if temp-schet.code > 0 then do:
        run CalcOborot (input {&income-cashless}, input temp-schet.curr, input v-fact-order-end, output sum1) .
        assign temp-sum.sum-in = sum1 . /* на конец */
        run CalcOborot (input {&income-cashless}, input temp-schet.curr, input v-fact-order-start, output sum1) .
        assign temp-sum.sum-in = temp-sum.sum-in - sum1 . /* на начало */

        run CalcOborot (input {&income-cashless}, input 0, input v-fact-order-end, output sum1) .
        assign temp-sum.sum-in-rubl = sum1 . /* на конец */
        run CalcOborot (input {&income-cashless}, input 0, input v-fact-order-start, output sum1) .
        assign temp-sum.sum-in-rubl = temp-sum.sum-in-rubl - sum1 . /* на конец */

        run CalcOborot (input {&income-cashless}, input v-curr-r-b, input v-fact-order-end, output sum1) .
        assign temp-sum.sum-in-base = sum1 . /* на начало */
        run CalcOborot (input {&income-cashless}, input v-curr-r-b, input v-fact-order-start, output sum1) .
        assign temp-sum.sum-in-base = temp-sum.sum-in-base - sum1 . /* на конец */

        run CalcOborot (input {&expense-cashless}, input temp-schet.curr, input v-fact-order-end, output sum1) .
        assign temp-sum.sum-out = sum1 . /* на конец */
        run CalcOborot (input {&expense-cashless}, input temp-schet.curr, input v-fact-order-start, output sum1) .
        assign temp-sum.sum-out = temp-sum.sum-out - sum1 . /* на начало */

        run CalcOborot (input {&expense-cashless}, input 0, input v-fact-order-end, output sum1) .
        assign temp-sum.sum-out-rubl = sum1 . /* на конец */
        run CalcOborot (input {&expense-cashless}, input 0, input v-fact-order-start, output sum1) .
        assign temp-sum.sum-out-rubl = temp-sum.sum-out-rubl - sum1 . /* на конец */

        run CalcOborot (input {&expense-cashless}, input v-curr-r-b, input v-fact-order-end, output sum1) .
        assign temp-sum.sum-out-base = sum1 . /* на начало */
        run CalcOborot (input {&expense-cashless}, input v-curr-r-b, input v-fact-order-start, output sum1) .
        assign temp-sum.sum-out-base = temp-sum.sum-out-base - sum1 . /* на конец */
      end.
      else do:
        if temp-schet.code = 0 then do:
          if p-nal then do: /* учитаваем наличные */
            run CalcOborot1 (input {&income-cash}, input 0, input temp-schet.curr, input v-fact-order-end,input "sum-rubl-", output sum1) .
            assign temp-sum.sum-in = sum1 . /* на конец */
            run CalcOborot1 (input {&income-cash}, input 0, input temp-schet.curr, input v-fact-order-start,input "sum-rubl-", output sum1) .
            assign temp-sum.sum-in = temp-sum.sum-in - sum1 . /* на начало */

            if p-curr-code = 0 then assign temp-sum.sum-in-rubl = temp-sum.sum-in .
            else do:
              run CalcOborot1 (input {&income-cash}, input 0, input 0, input v-fact-order-end,input "sum-", output sum1) .
              assign temp-sum.sum-in-rubl = sum1 . /* на конец */
              run CalcOborot1 (input {&income-cash}, input 0, input 0, input v-fact-order-start,input "sum-", output sum1) .
              assign temp-sum.sum-in-rubl = temp-sum.sum-in-rubl - sum1 . /* на конец */
            end.

            run CalcOborot1 (input {&income-cash}, input v-curr-r-b, input v-curr-r-b, input v-fact-order-end,input "sum-base-", output sum1) .
            assign temp-sum.sum-in-base = sum1 . /* на начало */
            run CalcOborot1 (input {&income-cash}, input v-curr-r-b, input v-curr-r-b, input v-fact-order-start,input "sum-base-", output sum1) .
            assign temp-sum.sum-in-base = temp-sum.sum-in-base - sum1 . /* на конец */

            run CalcOborot1 (input {&expense-cash}, input 0, input temp-schet.curr, input v-fact-order-end,input "sum-rubl-", output sum1) .
            assign temp-sum.sum-out = sum1 . /* на конец */
            run CalcOborot1 (input {&expense-cash}, input 0, input temp-schet.curr, input v-fact-order-start,input "sum-rubl-", output sum1) .
            assign temp-sum.sum-out = temp-sum.sum-out - sum1 . /* на начало */

            if p-curr-code = 0 then assign temp-sum.sum-out-rubl = temp-sum.sum-out .
            else do:
              run CalcOborot1 (input {&expense-cash}, input 0, input 0, input v-fact-order-end,input "sum-", output sum1) .
              assign temp-sum.sum-out-rubl = sum1 . /* на конец */
              run CalcOborot1 (input {&expense-cash}, input 0, input 0, input v-fact-order-start,input "sum-", output sum1) .
              assign temp-sum.sum-out-rubl = temp-sum.sum-out-rubl - sum1 . /* на конец */
            end.

            run CalcOborot1 (input {&expense-cash}, input v-curr-r-b, input v-curr-r-b, input v-fact-order-end,input "sum-base-", output sum1) .
            assign temp-sum.sum-out-base = sum1 . /* на начало */
            run CalcOborot1 (input {&expense-cash}, input v-curr-r-b, input v-curr-r-b, input v-fact-order-start,input "sum-base-", output sum1) .
            assign temp-sum.sum-out-base = temp-sum.sum-out-base - sum1 . /* на конец */
          end.
        end.
        else do:
          if p-akt then do: /* учитаваем АПЗ */
            run CalcOborot1 (input {&income-payoff}, input temp-schet.curr, input temp-schet.curr, input v-fact-order-end,input "sum-rubl-", output sum1) .
            assign temp-sum.sum-in = sum1 . /* на конец */
            run CalcOborot1 (input {&income-payoff}, input temp-schet.curr, input temp-schet.curr, input v-fact-order-start,input "sum-rubl-", output sum1) .
            assign temp-sum.sum-in = temp-sum.sum-in - sum1 . /* на начало */

            if p-curr-code = 0 then assign temp-sum.sum-in-rubl = temp-sum.sum-in .
            else do:
              run CalcOborot1 (input {&income-payoff}, input 0, input 0, input v-fact-order-end,input "sum-rubl-", output sum1) .
              assign temp-sum.sum-in-rubl = sum1 . /* на конец */
              run CalcOborot1 (input {&income-payoff}, input 0, input 0, input v-fact-order-start,input "sum-rubl-", output sum1) .
              assign temp-sum.sum-in-rubl = temp-sum.sum-in-rubl - sum1 . /* на конец */
            end.

            run CalcOborot1 (input {&income-payoff}, input v-curr-r-b, input v-curr-r-b, input v-fact-order-end,input "sum-base-", output sum1) .
            assign temp-sum.sum-in-base = sum1 . /* на начало */
            run CalcOborot1 (input {&income-payoff}, input v-curr-r-b, input v-curr-r-b, input v-fact-order-start,input "sum-base-", output sum1) .
            assign temp-sum.sum-in-base = temp-sum.sum-in-base - sum1 . /* на конец */

            run CalcOborot1 (input {&expense-payoff}, input temp-schet.curr, input temp-schet.curr, input v-fact-order-end,input "sum-rubl-", output sum1) .
            assign temp-sum.sum-out = sum1 . /* на конец */
            run CalcOborot1 (input {&expense-payoff}, input temp-schet.curr, input temp-schet.curr, input v-fact-order-start,input "sum-rubl-", output sum1) .
            assign temp-sum.sum-out = temp-sum.sum-out - sum1 . /* на начало */

            if p-curr-code = 0 then  assign temp-sum.sum-out-rubl = temp-sum.sum-out .
            else do:
              run CalcOborot1 (input {&expense-payoff}, input 0, input 0, input v-fact-order-end,input "sum-", output sum1) .
              assign temp-sum.sum-out-rubl = sum1 . /* на конец */
              run CalcOborot1 (input {&expense-payoff}, input 0, input 0, input v-fact-order-start,input "sum-", output sum1) .
              assign temp-sum.sum-out-rubl = temp-sum.sum-out-rubl - sum1 . /* на конец */
            end.

            run CalcOborot1 (input {&expense-payoff}, input v-curr-r-b, input v-curr-r-b, input v-fact-order-end,input "sum-base-", output sum1) .
            assign temp-sum.sum-out-base = sum1 . /* на начало */
            run CalcOborot1 (input {&expense-payoff}, input v-curr-r-b, input v-curr-r-b, input v-fact-order-start,input "sum-base-", output sum1) .
            assign temp-sum.sum-out-base = temp-sum.sum-out-base - sum1 . /* на конец */
          end.
        end.
      end.
    end.
  end.

  { gbl/working.i }

  Line = fill("-", 250).

/*  assign*/
/*    make-excel = yes*/
/*    v-file-name = string(session :temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt"*/
/*  .*/
/*  output stream macr_excel to value(v-file-name) .*/
/*  assign v-ind = v-ind + 1 .*/
  if len < 136 then run prn-lib-open-stream  in this-procedure (input parParentProc,input {&CS_PS},input yes,input no).
  else              run prn-lib-open-stream  in this-procedure (input parParentProc,input {&LS_PS_A4},input yes,input no).

  FORM with FRAME f-doc .

  run PrintTitul in this-procedure .
/*  run PutColumnTitulExcel in this-procedure .*/

  /* остаток на начало */
  put stream PrnLibStream  "|"  "Остаток на начало"  format {&F1} "|" at {&L2} .
  assign jj = 1 .
  for each temp-schet :
    put stream PrnLibStream  temp-schet.sum1 format  {&F2}  "|" at ( {&L2} + {&D1} * jj ) .
    assign jj = jj + 1 .
  end.
  put stream PrnLibStream  ost-beg-rubl format {&F2} "|" at ( {&L2} + {&D1} * jj ) .
  assign jj = jj + 1 .
  put stream PrnLibStream  ost-beg-base format {&F2} "|" at ( {&L2} + {&D1} * jj ) skip .

  /* Поступления */
  put stream PrnLibStream  Line format {&FL}  skip  "Поступления" format {&F1}  skip .
  for each temp-code break by temp-code.code by temp-code.lavel1 by temp-code.lavel2 by temp-code.lavel3 :
    assign is-null = yes .
    for each temp-sum where temp-sum.code-fin = temp-code.code :
      if temp-sum.sum-in <> 0 or temp-sum.sum-in-rubl <> 0 or temp-sum.sum-in-base <> 0 then do:
        assign is-null = no .
        leave .
      end.
    end.
    if is-null = yes then next .
/*    if first-of(temp-doc.cli-code) and itog-comp = no then do:*/
/*      PUT STREAM PrnLibStream string("| Контрагент: " + temp-doc.cli-name) format "X(89)" "|" at {&L6} skip .*/
/*      assign v-sum = 0 .*/
/*    end.*/
    run prn-line in this-procedure (yes) .
/*      if last-of(temp-doc.contr)  then do:*/
/*        PUT STREAM PrnLibStream string("| Всего по договору: " + temp-doc.contr-name) format "X(64)" "|" at {&L5} v-sum1 format {&F4} "|" at {&L6} skip .*/
/*      end.*/
  end.

  /* Выбытия */
  put stream PrnLibStream  Line format {&FL}  skip  "Выбытия" format {&F1}  skip .
  for each temp-code break by temp-code.code by temp-code.lavel1 by temp-code.lavel2 by temp-code.lavel3 :
    assign is-null = yes .
    for each temp-sum where temp-sum.code-fin = temp-code.code :
      if temp-sum.sum-out <> 0 or temp-sum.sum-out-rubl <> 0 or temp-sum.sum-out-base <> 0 then do:
        assign is-null = no .
        leave .
      end.
    end.
    if is-null = yes then next .
    run prn-line in this-procedure (no) .
  end.

  /* остаток на конец */
  put stream PrnLibStream  Line format {&FL}  skip  "|"  "Остаток на конец"  format {&F1} "|" at {&L2} .
  assign jj = 1 .
  for each temp-schet :
    put stream PrnLibStream  temp-schet.sum2 format  {&F2}  "|" at ( {&L2} + {&D1} * jj ) .
    assign jj = jj + 1 .
  end.
  put stream PrnLibStream  ost-end-rubl format {&F2} "|" at ( {&L2} + {&D1} * jj ) .
  assign jj = jj + 1 .
  put stream PrnLibStream  ost-end-base format {&F2} "|" at ( {&L2} + {&D1} * jj ) skip Line format {&FL}  skip .

  HIDE stream PrnLibStream FRAME BottomFrame .
  OUTPUT stream PrnLibStream CLOSE.

/*  output stream macr_excel close .*/
/*  run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name) .*/
/*  run end-proc .*/

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */
  { gbl/stopwork.i }

  if len < 136 then run prn-lib-prn-file in this-procedure (input parParentProc,input 0).
  else              run prn-lib-prn-file in this-procedure (input parParentProc,input 8).
end.


procedure prn-line :
  do on error undo, return error return-value :
    define input  parameter p-is-in as logical   no-undo .

    run is-page in this-procedure .

    put stream PrnLibStream   "|" string( (if temp-code.lavel2 <> 0 then " " else "" ) + (if temp-code.lavel3 <> 0 then " " else "" ) + temp-code.num + " " + temp-code.name)   format {&F1} "|" at {&L2} .
    assign
      sum-rubl = 0
      sum-base = 0
      jj = 1
    .
    for each temp-schet :
      find first  temp-sum where temp-sum.code-fin = temp-code.code and temp-sum.code-schet = temp-schet.code .
      put stream PrnLibStream  (if p-is-in then temp-sum.sum-in else temp-sum.sum-out) format {&F2} "|" at ( {&L2} + {&D1} * jj ) .
      assign
        jj = jj + 1
        sum-rubl = sum-rubl + (if p-is-in then temp-sum.sum-in-rubl else temp-sum.sum-out-rubl)
        sum-base = sum-base + (if p-is-in then temp-sum.sum-in-base else temp-sum.sum-out-base)
      .
    end.
    put stream PrnLibStream sum-rubl format {&F2} "|" at ( {&L2} + {&D1} * jj ) .
    assign jj = jj + 1 .
    put stream PrnLibStream sum-base format {&F2} "|" at ( {&L2} + {&D1} * jj ) skip .

  end.
end procedure. /* prn-line */


procedure PutColumnTitulExcel : /* заголовки для колонок экселя */
  do
  on error undo, return error return-value
  :
/*    assign  v-row = 4 .*/
/*    run macr_excel_char ("Cостояние финансов на " + string(x-date,"99/99/9999") + "г.", 1, 2) .*/
/*    run macr_cell_format ( 11, yes, no, ?, 1, 2, 1, 2) .*/
/*    run macr_excel_char (v-NameString, 2, 1) .*/
/*    run macr_excel_char("Наименование счета", 3, 1) .*/
/*    run macr_cell_size (40,?, 3, 1,?,?).*/
/*    run macr_excel_char("Вал", 3, 2) .*/
/*    run macr_cell_size (4,?, 3, 2,?,?).*/
/*    run macr_excel_char("в валюте счета", 3, 3) .*/
/*    run macr_excel_char("в {&abbr_rublyah}", 3, 4) .*/
/*    run macr_excel_char("в Б.валюте", 3, 5) .*/

/*    run macr_cell_bordur ( 3, 1, 3, 5) .*/
/*    run macr_cell_format ( 10, yes, no, 35, 3, 1, 3, 5) .*/
/*    run macr_cell_size (12,?, 3, 3, 3, 5) .*/
   end.
end procedure. /* PutColumnTitulExcel */


procedure is-page :
  do
  on error undo, return error return-value
  :
    if line-counter( PrnLibStream ) + 2 > page-size( PrnLibStream ) then do:
      put stream PrnLibStream  skip Line format {&FL} skip "продолжение - на следующей странице" AT 30 SKIP .
      page stream PrnLibStream .
      run PrintTitul .
    end.
/*    if  ( v-row ) >= 63000 then do:*/
/*      Output stream Macr_Excel  close .*/
/*      run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name ) .*/
/*      run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .*/
/*      output stream  Macr_Excel to value(v-file-name) .*/
/*      assign*/
/*        v-ind = v-ind + 1*/
/*        v-row = 2*/
/*      .*/
/*      run PutColumnTitulExcel in this-procedure .*/
/*    end.*/
  end.
end procedure. /* is-page */


procedure PrintTitul :
  do
  on error undo, return error return-value
  :
    PUT stream PrnLibStream SPACE(10) ReportNAme format "X(100)" SKIP .
    PUT stream PrnLibStream str1 format "X(100)" SKIP .

    put stream PrnLibStream  skip cur-time-print() format "x(35)" string( "Страница" ) AT 45 PAGE-NUMBER( PrnLibStream ) AT 55 FORMAT ">>9" SKIP .

    put stream PrnLibStream  skip  Line format {&FL}  skip   "|"  "Основание"  format "X(10)" "|" at {&L2} .

    assign jj = 1 .
    for each temp-schet :
      put stream PrnLibStream  temp-schet.r-schet format "X(20)" "|" at ( {&L2} + {&D1} * jj ) .
      assign jj = jj + 1 .
    end.
    put stream PrnLibStream  "Итого в {&abbr_rub}." format "X(20)" "|" at ( {&L2} + {&D1} * jj ) .
    assign jj = jj + 1 .
    put stream PrnLibStream  "Итого в б.вал." format "X(20)" "|" at ( {&L2} + {&D1} * jj ) skip Line format {&FL}  skip .
  end.
end procedure. /* PrintTitul */


procedure CalcOst :
  do  on error undo, return error return-value  :
    define input  parameter p-typ as character no-undo .
    define input  parameter p-cur as integer   no-undo .
    define input  parameter p-fo  as decimal   no-undo .
    define output parameter sm    as decimal   no-undo .

    assign sm = 0 .
    assign Counter1 = Counter1 + 1.
    { rep/repfrm.i disp Counter1 }

    find last buf_arh-fin-doc-schet no-lock
      where buf_arh-fin-doc-schet.host-code        = buf_fin-schet.host-code
        and buf_arh-fin-doc-schet.code-schet       = buf_fin-schet.code-schet
        and buf_arh-fin-doc-schet.cli-code         = buf_fin-schet.host-code
        and buf_arh-fin-doc-schet.cli-type         = {&cmp}
        and buf_arh-fin-doc-schet.fin-ext-doc-type = p-typ
        and buf_arh-fin-doc-schet.calc-curr-code   = p-cur
        and buf_arh-fin-doc-schet.sum-type         = ""
        and buf_arh-fin-doc-schet.fact-order      <= p-fo
     no-error .
    if available buf_arh-fin-doc-schet then do:
      if p-typ = {&income-cashless} then assign sm = buf_arh-fin-doc-schet.income .
      else                               assign sm = buf_arh-fin-doc-schet.expense .
    end.
  end.
end procedure. /* CalcOst */


procedure CalcOborot :
  do on error undo, return error return-value :
    define input  parameter p-typ as character no-undo .
    define input  parameter p-cur as integer   no-undo .
    define input  parameter p-fo  as decimal   no-undo .
    define output parameter sm    as decimal   no-undo .

    assign sm = 0 .
    assign Counter1 = Counter1 + 1.
    { rep/repfrm.i disp Counter1 }

    case p-type :
      when 1 then do:
          find last buf_arh-fin-doc-an no-lock
            where buf_arh-fin-doc-an.host-code         = v-cntxt-host-code-obj
              and buf_arh-fin-doc-an.code-schet        = temp-schet.code
              and buf_arh-fin-doc-an.cli-code          = v-cntxt-host-code-obj
              and buf_arh-fin-doc-an.cli-type          = {&cmp}
              and buf_arh-fin-doc-an.fin-ext-doc-type  = p-typ
              and buf_arh-fin-doc-an.calc-curr-code    = p-cur
              and buf_arh-fin-doc-an.fact-order       <= p-fo
              and buf_arh-fin-doc-an.fin-code-cor-acc  = temp-code.code
              and buf_arh-fin-doc-an.sum-type          = "sum-schet-cor-acc"
              and buf_arh-fin-doc-an.fin-code-an-uchet = 0
              and buf_arh-fin-doc-an.fin-code-cel-nazn = 0
          no-error .
      end.
      when 2 then do:
/*        for each fin-code-cor-acc no-lock where fin-code-cor-acc.host-code = v-cntxt-host-code-obj  ,*/
/*          each fin-code-cel-nazn no-lock  where fin-code-cel-nazn.host-code = v-cntxt-host-code-obj :*/
          find last buf_arh-fin-doc-an no-lock
            where buf_arh-fin-doc-an.host-code         = v-cntxt-host-code-obj
              and buf_arh-fin-doc-an.code-schet        = temp-schet.code
              and buf_arh-fin-doc-an.cli-code          = v-cntxt-host-code-obj
              and buf_arh-fin-doc-an.cli-type          = {&cmp}
              and buf_arh-fin-doc-an.fin-ext-doc-type  = p-typ
              and buf_arh-fin-doc-an.calc-curr-code    = p-cur
              and buf_arh-fin-doc-an.fact-order       <= p-fo
              and buf_arh-fin-doc-an.fin-code-an-uchet = temp-code.code
              and buf_arh-fin-doc-an.sum-type          = "sum-schet-uchet"
              and buf_arh-fin-doc-an.fin-code-cor-acc  = 0
              and buf_arh-fin-doc-an.fin-code-cel-nazn = 0
           no-error .
/*        end.*/
      end.
      when 3 then do:
/*        for each fin-code-cor-acc no-lock where fin-code-cor-acc.host-code = v-cntxt-host-code-obj   ,*/
/*          each fin-code-an-uchet no-lock  where fin-code-an-uchet.host-code = v-cntxt-host-code-obj :*/
          find last buf_arh-fin-doc-an no-lock
            where buf_arh-fin-doc-an.host-code         = v-cntxt-host-code-obj
              and buf_arh-fin-doc-an.code-schet        = temp-schet.code
              and buf_arh-fin-doc-an.cli-code          = v-cntxt-host-code-obj
              and buf_arh-fin-doc-an.cli-type          = {&cmp}
              and buf_arh-fin-doc-an.fin-ext-doc-type  = p-typ
              and buf_arh-fin-doc-an.calc-curr-code    = p-cur
              and buf_arh-fin-doc-an.fact-order       <= p-fo
              and buf_arh-fin-doc-an.fin-code-cel-nazn = temp-code.code
              and buf_arh-fin-doc-an.sum-type          = "sum-schet-cel-nazn"
              and buf_arh-fin-doc-an.fin-code-cor-acc  = 0
              and buf_arh-fin-doc-an.fin-code-an-uchet = 0
          no-error .
/*        end.*/
      end.
    end.
    if available buf_arh-fin-doc-an then do:
      if p-typ = {&income-cashless} then assign sm = sm + buf_arh-fin-doc-an.income .
      else                               assign sm = sm + buf_arh-fin-doc-an.expense .
    end.
  end.
end procedure. /* CalcOborot */



procedure CalcOst1 :
  do on error undo, return error return-value :
    define input  parameter p-typ as character no-undo .
    define input  parameter p-calc as integer   no-undo .
    define input  parameter p-cur as integer   no-undo .
    define input  parameter p-fo  as decimal   no-undo .
    define output parameter sm    as decimal   no-undo .

    assign sm = 0 .

    assign Counter1 = Counter1 + 1.
    { rep/repfrm.i disp Counter1 }

    find last buf_arh-fin-doc-an-nal no-lock
      where buf_arh-fin-doc-an-nal.host-code         = v-cntxt-host-code-obj
        and buf_arh-fin-doc-an-nal.fin-ext-doc-type  = p-typ
        and buf_arh-fin-doc-an-nal.cli-code          = v-cntxt-host-code-obj
        and buf_arh-fin-doc-an-nal.cli-type          = {&cmp}
        and buf_arh-fin-doc-an-nal.curr-code         = p-cur
        and buf_arh-fin-doc-an-nal.calc-curr-code    = p-calc
        and buf_arh-fin-doc-an-nal.sum-type          = "sum-without-schet-code"
        and buf_arh-fin-doc-an-nal.fact-order       <= p-fo
        and buf_arh-fin-doc-an-nal.fin-code-cor-acc  = 0
        and buf_arh-fin-doc-an-nal.fin-code-acc      = 0
        and buf_arh-fin-doc-an-nal.fin-code-an-uchet = 0
        and buf_arh-fin-doc-an-nal.fin-code-cel-nazn = 0
    no-error .
    if available buf_arh-fin-doc-an-nal then do:
      if p-typ = {&income-cash} or p-typ = {&income-payoff} then assign sm = sm + buf_arh-fin-doc-an-nal.income .
      else                                                       assign sm = sm + buf_arh-fin-doc-an-nal.expense .
    end.
  end.
end procedure. /* CalcOst1 */



procedure CalcOborot1 :
  do on error undo, return error return-value :
    define input  parameter p-typ as character no-undo .
    define input  parameter p-calc as integer   no-undo .
    define input  parameter p-cur as integer   no-undo .
    define input  parameter p-fo  as decimal   no-undo .
    define input  parameter p-sum-type as character no-undo .
    define output parameter sm    as decimal   no-undo .

    assign sm = 0 .

    assign Counter1 = Counter1 + 1.
    { rep/repfrm.i disp Counter1 }

      case p-type :
        when 1 then do:
          assign p-sum-type = p-sum-type + "cor-acc" .
          find last buf_arh-fin-doc-an-nal no-lock
            where buf_arh-fin-doc-an-nal.host-code         = v-cntxt-host-code-obj
              and buf_arh-fin-doc-an-nal.cli-code          = v-cntxt-host-code-obj
              and buf_arh-fin-doc-an-nal.cli-type          = {&cmp}
              and buf_arh-fin-doc-an-nal.fin-ext-doc-type  = p-typ
              and buf_arh-fin-doc-an-nal.curr-code         = p-cur
              and buf_arh-fin-doc-an-nal.calc-curr-code    = p-calc
              and buf_arh-fin-doc-an-nal.sum-type          = p-sum-type
              and buf_arh-fin-doc-an-nal.fact-order       <= p-fo
              and buf_arh-fin-doc-an-nal.fin-code-cor-acc  = temp-code.code
              and buf_arh-fin-doc-an-nal.fin-code-acc      = 0
              and buf_arh-fin-doc-an-nal.fin-code-an-uchet = 0
              and buf_arh-fin-doc-an-nal.fin-code-cel-nazn = 0
          no-error .
        end.
        when 2 then do:
          assign p-sum-type = p-sum-type + "uchet" .
          find last buf_arh-fin-doc-an-nal no-lock
            where buf_arh-fin-doc-an-nal.host-code         = v-cntxt-host-code-obj
              and buf_arh-fin-doc-an-nal.cli-code          = v-cntxt-host-code-obj
              and buf_arh-fin-doc-an-nal.cli-type          = {&cmp}
              and buf_arh-fin-doc-an-nal.fin-ext-doc-type  = p-typ
              and buf_arh-fin-doc-an-nal.curr-code         = p-cur
              and buf_arh-fin-doc-an-nal.calc-curr-code    = p-calc
              and buf_arh-fin-doc-an-nal.sum-type          = p-sum-type
              and buf_arh-fin-doc-an-nal.fact-order       <= p-fo
              and buf_arh-fin-doc-an-nal.fin-code-cor-acc  = 0
              and buf_arh-fin-doc-an-nal.fin-code-acc      = 0
              and buf_arh-fin-doc-an-nal.fin-code-an-uchet = temp-code.code
              and buf_arh-fin-doc-an-nal.fin-code-cel-nazn = 0
          no-error .
        end.
        when 3 then do:
          assign p-sum-type = p-sum-type + "cel-nazn" .
          find last buf_arh-fin-doc-an-nal no-lock
            where buf_arh-fin-doc-an-nal.host-code         = v-cntxt-host-code-obj
              and buf_arh-fin-doc-an-nal.cli-code          = v-cntxt-host-code-obj
              and buf_arh-fin-doc-an-nal.cli-type          = {&cmp}
              and buf_arh-fin-doc-an-nal.fin-ext-doc-type  = p-typ
              and buf_arh-fin-doc-an-nal.curr-code         = p-cur
              and buf_arh-fin-doc-an-nal.calc-curr-code    = p-calc
              and buf_arh-fin-doc-an-nal.sum-type          = p-sum-type
              and buf_arh-fin-doc-an-nal.fact-order       <= p-fo
              and buf_arh-fin-doc-an-nal.fin-code-cor-acc  = 0
              and buf_arh-fin-doc-an-nal.fin-code-acc      = 0
              and buf_arh-fin-doc-an-nal.fin-code-an-uchet = 0
              and buf_arh-fin-doc-an-nal.fin-code-cel-nazn = temp-code.code
          no-error .
        end.
      end.
    if available buf_arh-fin-doc-an-nal then do:
      if p-typ = {&income-cash} or p-typ = {&income-payoff}  then assign sm = sm + buf_arh-fin-doc-an-nal.income .
      else                                                        assign sm = sm + buf_arh-fin-doc-an-nal.expense .
    end.
  end.
end procedure. /* CalcOborot1 */