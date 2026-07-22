block-level on error undo, throw.
/*

$Revision: 01d4914e5615, 377, rls $
$Author: EShklyar $
$Date: Mon Dec 28 19:14:54 2015 +0300 $
$Workfile: r-obsal2.p $
$Archive: rep/r-obsal2.p $

Оборотно-сальдовая ведомость по покупателям

Автор: Демин Алексей Сергеевич
Дата создания: 09/13/05
Author: Alexey Demin
Creation date: 09/13/05

*/

define input parameter itog-only     as logical   no-undo .
define input parameter itog-contract as logical   no-undo .
define input parameter p-contr-code  as integer   no-undo .
define input parameter is-date       as logical   no-undo .
define input parameter is-fin        as logical   no-undo .
define input parameter is-fo         as logical   no-undo .
define input parameter is-real       as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: 01d4914e5615, 377, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Mon Dec 28 19:14:54 2015 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-obsal2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-obsal2.p $":U .
define variable vss-description as character no-undo init "Оборотно-сальдовая ведомость по покупателям".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ trg/factord.i  }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ gbl/cur-time.i }
{ cmp/library.i  }
{ gbl/clntattr.i }
{ str/farh-def.i }

define Stream OutStream.

do
on error undo, return error
:

DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
ASSIGN parParentProc =  my-handle .
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/prn-lib.i }

define variable g#report-num as integer no-undo .
run get-report-num  in parparentproc (output g#report-num).
  { rep/f-fdec.i }   /* Функции для форматирования полей для передачи в EXcel         */
  { gbl/paramls.i }
  { rep/mcrexcel.i }

/*define variable make-excel as logical   no-undo .*/
  define variable  v-fact-order-start     as decimal   no-undo .
  define variable  v-fact-order-end       as decimal   no-undo .

  define variable v-ind                  as integer   no-undo .
  define variable ind                    as integer   no-undo .
  define variable ind1                   as integer   no-undo .
  define variable ii                     as integer initial 0  no-undo .
  define variable jj                     as integer initial 0  no-undo .
  define variable kk                     as integer initial 0  no-undo .
  define variable Counter1               as integer   no-undo .
  define variable Line                   as character no-undo .
  define variable v-contract-code        as integer   no-undo .

  define variable s-val as character no-undo .
  if x-SET_val_TYPE = 1 then assign s-val = "{&abbr_rubl}." .
  else                       assign s-val = "б.вал." .

  define variable v-contr         as integer   no-undo .
  define variable v-sm1-contr     as decimal   no-undo .
  define variable v-sm2-contr     as decimal   no-undo .
  define variable v-sm3-contr     as decimal   no-undo .
  define variable v-sm4-contr     as decimal   no-undo .
  define variable v-sm1-cli       as decimal   no-undo .
  define variable v-sm2-cli       as decimal   no-undo .
  define variable v-sm3-cli       as decimal   no-undo .
  define variable v-sm4-cli       as decimal   no-undo .
  define variable v-sum-e       as decimal   no-undo .
  define variable v-sum-i       as decimal   no-undo .
  define variable v-row as integer   no-undo .

  define variable v-str  as CHAR  no-undo .
  define variable par-type  as CHAR  no-undo .

  define variable num-col as integer initial 0  no-undo .
  if is-real then assign num-col = num-col + 1 .
  if is-fo   then assign num-col = num-col + 1 .
  if is-fin  then assign num-col = num-col + 1 .

  &scop L1    1
  &scop L2    10
  &scop L3    22
  &scop L4    26
  &scop L5    46
  &scop L6    num-col * 45 + 1
  &scop L7    num-col * 45 + 18
  &scop F1    "99/99/99"
  &scop F2    "X(10)"
  &scop F3    "X(3)"
  &scop F4    "->>>,>>>,>>>,>>9.99"
  &scop F5    "->>>,>>>,>>9.99"
  &scop FL    string("X(" + string( {&L7}) + ")")
  &scop FL1   string("X(" + string( {&L6}) + ")")


  DEFINE temp-table temp-doc no-undo
/*    field   sum1          as decimal*/
    field   sum2          as decimal
    field   sum3          as decimal
    field   sum4          as decimal
/*    field   num1          as integer*/
    field   num2          as integer
    field   num3          as integer
    field   num4          as integer
    field   contr         as integer
    field   contr-name    as character
    field   cli-type      as character
    field   cli-code      as integer
    INDEX pi  IS PRIMARY   cli-type cli-code contr
  .

  DEFINE temp-table temp-sum no-undo
    field   sum          as decimal
    field   contr        as integer
    field   dat          as date
    field   num          as character
    field   styp         as character
    field   type         as integer
    field   ind          as integer
    field   cli-type      as character
    field   cli-code      as integer
    field   fact-order    as decimal
    INDEX pi  IS PRIMARY   cli-type cli-code contr  dat ind type
    INDEX pi1 cli-type cli-code contr fact-order ind type
  .

  DEFINE temp-table temp-date no-undo
    field   cli-type      as character
    field   cli-code      as integer
    field   contr         as integer
    field   dat           as date
    field   num1          as integer
    field   num2          as integer
    field   num3          as integer
    field   num4          as integer
    INDEX pi  IS PRIMARY  dat
  .

  DEFINE temp-table temp-cli no-undo
/*    field   sum1          as decimal*/
    field   sum2          as decimal
    field   sum3          as decimal
    field   sum4          as decimal
    field   obj-type      as character
    field   obj-code      as integer
    field   obj-name      as character
    INDEX pi  IS PRIMARY   obj-type obj-code
  .

  /* Список объектов фирмы */
  define temp-table temp-obj-firm no-undo
    field obj-code      as integer
    field obj-type      as char
    field err           as logical
    index pi is primary unique obj-code obj-type
  .
  define buffer buf_shop for shop .
  define buffer buf_store for store .
  define buffer buf_trn-doc for trn-doc .
  for each buf_shop no-lock where buf_shop.host-code = v-cntxt-host-code-obj :
    run clntattr-value in this-procedure  (input {&shop},input buf_shop.obj-code, input  {&attr-arh-trn-doc-contract}, output v-str, output par-type) no-error .
    if v-str = "yes" then do:
      message "Неправильные архивы arh-trn-doc-contract по магазину " string(buf_shop.obj-code) " . Отчет по этому магазину не будет выведен."  view-as alert-box.
      next.
    end.
    create temp-obj-firm.
    assign
      temp-obj-firm.obj-code = buf_shop.obj-code
      temp-obj-firm.obj-type = {&shop}
    .
  end.
  for each buf_store no-lock where buf_store.host-code = v-cntxt-host-code-obj :
    run clntattr-value in this-procedure  (input {&stock},input buf_store.obj-code, input  {&attr-arh-trn-doc-contract}, output v-str, output par-type) no-error .
    if v-str = "yes" then do:
      message "Неправильные архивы arh-trn-doc-contract по складу " string(buf_store.obj-code) " . Отчет по этому складу не будет выведен."  view-as alert-box.
      next.
    end.
    create temp-obj-firm.
    assign
      temp-obj-firm.obj-code = buf_store.obj-code
      temp-obj-firm.obj-type = {&stock}
    .
  end.

  define variable v-curr-r-b as integer   no-undo .
  if x-SET_val_TYPE = 1  then assign v-curr-r-b = 0 .
  else do:   { gbl/r-b-curr.i v-cntxt-host-code-obj v-curr-r-b } end.

  assign  Counter1 = 0 .
  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 50 } /* Показать окно информации о текущем процессе */

  define buffer buf_contract for contract .
  define buffer buf_clients  for clients .
  define buffer buf_fin-ob   for fin-ob .
  define buffer buf_fin-doc  for fin-doc .
  define buffer buf_arh-trn-doc-contract  for arh-trn-doc-contract .
  define buffer prev_arh-trn-doc-contract for arh-trn-doc-contract .
  define buffer buf_arh-fin-ob-contr for arh-fin-ob-contr .
  define buffer buf_arh-fin-doc-contr-schet for arh-fin-doc-contr-schet .
  define buffer buf_arh-fin-doc-contr-schet-nal for arh-fin-doc-contr-schet-nal .
  if p-contr-code > 0 then do:  /* только 1 договор */
    if itog-contract then do: /* ищем нач. дату по договору  */
      define variable dd as date  no-undo .
      assign dd = 1/1/1900 .
      find first fin-ob no-lock
        where fin-ob.host-code     = v-cntxt-host-code-obj
          and fin-ob.contract-code = p-contr-code
          and fin-ob.status_       = {&fact}
      no-error .
      if available fin-ob then  if fin-ob.fact-date < dd then assign dd = fin-ob.fact-date .
      find first fin-doc no-lock
        where fin-doc.host-code     = v-cntxt-host-code-obj
          and fin-doc.contract-code = p-contr-code
          and fin-doc.status_       = {&fin-fact}
      no-error .
      if available fin-doc then  if fin-doc.fact-date < dd then assign dd = fin-doc.fact-date .

      run day-begin-fact-order in this-procedure ( input dd,        output v-fact-order-start ). /*Поиск нач fact-order*/

      assign dd = today .
      find last fin-ob no-lock
        where fin-ob.host-code     = v-cntxt-host-code-obj
          and fin-ob.contract-code = p-contr-code
          and fin-ob.status_       = {&fact}
      no-error .
      if available fin-ob then  if fin-ob.fact-date > dd then assign dd = fin-ob.fact-date .
      find last fin-doc no-lock
        where fin-doc.host-code     = v-cntxt-host-code-obj
          and fin-doc.contract-code = p-contr-code
          and fin-doc.status_       = {&fin-fact}
      no-error .
      if available fin-doc then  if fin-doc.fact-date > dd then assign dd = fin-doc.fact-date .

      run day-begin-fact-order in this-procedure ( input ( dd + 1 ),  output v-fact-order-end ). /*Поиск посл fact-order*/
    end.
    else do:
      run day-begin-fact-order in this-procedure ( input x-date-start,        output v-fact-order-start ). /*Поиск нач fact-order*/
      run day-begin-fact-order in this-procedure ( input ( x-date-end + 1 ),  output v-fact-order-end ). /*Поиск посл fact-order*/
    end.
    find first buf_contract no-lock where buf_contract.host-code = v-cntxt-host-code-obj and buf_contract.contract-code = p-contr-code .
    assign v-contract-code = buf_contract.contract-code .
    create temp-cli .
    assign
      temp-cli.obj-type = buf_contract.cli-type
      temp-cli.obj-code = buf_contract.cli-code
    .
/*run inidebug.p .*/
    { rep/r-ob-sl2.i } /* смотрим и кладем в темп-тейбл  */
  end.
  else do:
    run day-begin-fact-order in this-procedure ( input x-date-start,        output v-fact-order-start ). /*Поиск нач fact-order*/
    run day-begin-fact-order in this-procedure ( input ( x-date-end + 1 ),  output v-fact-order-end ). /*Поиск посл fact-order*/

    find first G#CUSTOMER no-error .
    if not available G#CUSTOMER then do: /* все поставщики  */
      for each buf_clients no-lock :
        if buf_clients.sup-gds = no and buf_clients.sup-cons = no and buf_clients.sup-serv = no then next .
        create temp-cli .
        assign
          temp-cli.obj-type = buf_clients.obj-type
          temp-cli.obj-code = buf_clients.obj-code
          temp-cli.obj-name = buf_clients.obj-name
        .
        /* сначала без договора */
        assign v-contract-code = 0 .
        { rep/r-ob-sl2.i } /* смотрим и кладем в темп-тейбл  */
        /* по договорам */
        for each buf_contract no-lock
          where buf_contract.host-code = v-cntxt-host-code-obj
            and buf_contract.cli-type  = buf_clients.obj-type
            and buf_contract.cli-code  = buf_clients.obj-code
            and buf_contract.doc-type  = {&expense}
          :
          assign v-contract-code = buf_contract.contract-code .
          { rep/r-ob-sl2.i } /* смотрим и кладем в темп-тейбл  */
        end.
      end.
    end.
    else do:  /* список поставщиков */
      for each G#CUSTOMER :
        find first buf_clients no-lock where buf_clients.obj-type = G#CUSTOMER.obj-type and buf_clients.obj-code = G#CUSTOMER.obj-code .
        create temp-cli .
        assign
          temp-cli.obj-type = buf_clients.obj-type
          temp-cli.obj-code = buf_clients.obj-code
          temp-cli.obj-name = buf_clients.obj-name
        .
        /* сначала без договора */
        assign v-contract-code = 0 .
        { rep/r-ob-sl2.i } /* смотрим и кладем в темп-тейбл  */
        /* по договорам */
        for each buf_contract no-lock
          where buf_contract.host-code = v-cntxt-host-code-obj
            and buf_contract.cli-type  = buf_clients.obj-type
            and buf_contract.cli-code  = buf_clients.obj-code
            and buf_contract.doc-type  = {&expense}
          :
          assign v-contract-code = buf_contract.contract-code .
          { rep/r-ob-sl2.i } /* смотрим и кладем в темп-тейбл  */
        end.
      end.
    end.
  end.

  { gbl/working.i }

  Line = fill("-", 250).

  assign
    make-excel = yes
    v-file-name = string(session :temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt"
  .
  output stream macr_excel to value(v-file-name) .
  assign v-ind = v-ind + 1 .

  if num-col > 2 then run prn-lib-open-stream  in this-procedure (input parParentProc,input {&LS_PS_A4},input yes,input no).
  else                run prn-lib-open-stream  in this-procedure (input parParentProc,input {&CP_PS},input yes,input no).

  FORM with FRAME f-doc .

  run PrintTitul in this-procedure .
  run PutColumnTitulExcel in this-procedure .
  for each temp-cli :
    find first temp-doc where temp-doc.cli-type = temp-cli.obj-type and temp-doc.cli-code = temp-cli.obj-code no-error .
    if not available temp-doc then delete temp-cli .
  end.

  if p-contr-code > 0 then do:  /* только 1 договор */
    for each temp-doc break by temp-doc.contr:
      if first-of(temp-doc.contr) then do:
        assign
          v-sm1-contr = 0
          v-sm2-contr = 0
          v-sm3-contr = 0
          v-sm4-contr = 0
        .
        run is-page in this-procedure .
        PUT STREAM PrnLibStream  "|" at {&L1}  temp-doc.contr-name  format {&FL1} "|" at {&L7} skip .
        run macr_excel_char(temp-doc.contr-name, v-row, 1) .
        assign v-row = v-row  + 1 .
        put stream PrnLibStream  "|" at {&L1}  "Остаток на начало:" format "X(20)" .
        run macr_excel_char("Остаток на начало:"  , v-row, 1) .
        run PrnSumCli in this-procedure ( temp-doc.sum2, temp-doc.sum3, temp-doc.sum4) .
      end.

      run prn-line in this-procedure .

      if last-of(temp-doc.contr) then do:
        put stream PrnLibStream  "|" at {&L1} "Итого оборот:" format "X(20)" .
        run macr_excel_char("Итого оборот:"  , v-row, 1) .
        run PrnSumCli in this-procedure ( v-sm2-contr, v-sm3-contr, v-sm4-contr) .

        put stream PrnLibStream  "|" at {&L1} "Остаток по договору:" format "X(22)" .
        run macr_excel_char("Остаток по договору:"  , v-row, 1) .
        run PrnSumCli in this-procedure ( temp-doc.sum2 + v-sm2-contr, temp-doc.sum3 + v-sm3-contr, temp-doc.sum4 + v-sm4-contr) .
        put stream PrnLibStream  Line format {&FL}  skip .
      end.
    end.
  end.
  else do:
    for each temp-cli : /* поставщики */
      assign
        v-sm1-cli = 0
        v-sm2-cli = 0
        v-sm3-cli = 0
        v-sm4-cli = 0
      .
      PUT STREAM PrnLibStream string("| Поставщик: " + temp-cli.obj-name + " (" + temp-cli.obj-type + "#" + string(temp-cli.obj-code) + ")" ) format {&FL1} "|" at {&L7} skip .
      run macr_excel_char(string("| Поставщик: " + temp-cli.obj-name + " (" + temp-cli.obj-type + "#" + string(temp-cli.obj-code) + ")" ), v-row, 1) .
      assign v-row = v-row  + 1 .
      put stream PrnLibStream  "|" at {&L1} "Остаток на начало:" format "X(20)" .
      run macr_excel_char("Остаток на начало:" , v-row, 1) .
      run PrnSumCli in this-procedure (temp-cli.sum2, temp-cli.sum3, temp-cli.sum4) .

      for each temp-doc where temp-doc.cli-type = temp-cli.obj-type and temp-doc.cli-code = temp-cli.obj-code break by temp-doc.contr:
        if first-of(temp-doc.contr) then do:
          assign
            v-sm1-contr = 0
            v-sm2-contr = 0
            v-sm3-contr = 0
            v-sm4-contr = 0
          .
          PUT STREAM PrnLibStream  "|" at {&L1}  temp-doc.contr-name  format {&FL1} "|" at {&L7} skip .
          run macr_excel_char(temp-doc.contr-name, v-row, 1) .
          assign v-row = v-row  + 1 .
          put stream PrnLibStream  "|" at {&L1}  "Остаток на начало:" format "X(20)" .
          run macr_excel_char("Остаток на начало:" , v-row, 1) .
          run PrnSumCli in this-procedure ( temp-doc.sum2, temp-doc.sum3, temp-doc.sum4) .
        end.

        run prn-line in this-procedure .

        if last-of(temp-doc.contr) then do:
          put stream PrnLibStream  "|" at {&L1} "Итого оборот:" format "X(20)" .
          run macr_excel_char("Итого оборот:"  , v-row, 1) .
          run PrnSumCli in this-procedure ( v-sm2-contr, v-sm3-contr, v-sm4-contr) .

          put stream PrnLibStream  "|" at {&L1} "Остаток по договору:" format "X(22)" .
          run macr_excel_char("Остаток по договору:"  , v-row, 1) .
          run PrnSumCli in this-procedure ( temp-doc.sum2 + v-sm2-contr, temp-doc.sum3 + v-sm3-contr, temp-doc.sum4 + v-sm4-contr) .
          put stream PrnLibStream  Line format {&FL}  skip .
          assign
            v-sm1-cli = v-sm1-cli + v-sm1-contr
            v-sm2-cli = v-sm2-cli + v-sm2-contr
            v-sm3-cli = v-sm3-cli + v-sm3-contr
            v-sm4-cli = v-sm4-cli + v-sm4-contr
          .
        end.
      end.

      put stream PrnLibStream  "|" at {&L1} "Итого оборот:" format "X(20)" .
      run macr_excel_char("Итого оборот:"  , v-row, 1) .
      run PrnSumCli in this-procedure ( v-sm2-cli, v-sm3-cli, v-sm4-cli) .

      put stream PrnLibStream  "|" at {&L1} string("Остаток по пост." + temp-cli.obj-type + "#" + string(temp-cli.obj-code)) format "X(22)" .
      run macr_excel_char(string("Ост. по пост." + temp-cli.obj-type + "#" + string(temp-cli.obj-code)) , v-row, 1) .
      run PrnSumCli in this-procedure ( temp-cli.sum2 + v-sm2-cli, temp-cli.sum3 + v-sm3-cli, temp-cli.sum4 + v-sm4-cli) .
      put stream PrnLibStream  Line format {&FL}  skip .
    end.
  end.

  HIDE stream PrnLibStream FRAME BottomFrame .
  OUTPUT stream PrnLibStream CLOSE.

  output stream macr_excel close .
  run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name) .
  run end-proc .

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */
  { gbl/stopwork.i }

  if num-col > 2 then run prn-lib-prn-file in this-procedure (input parParentProc,input 8).
  else                run prn-lib-prn-file in this-procedure (input parParentProc,input 0).
end.


procedure prn-line :
  do on error undo, return error return-value :
   if is-date then do:
     for each temp-date
       where temp-date.cli-type = temp-doc.cli-type
         and temp-date.cli-code = temp-doc.cli-code
         and temp-date.contr    = temp-doc.contr
       :
       do ind = 0 to maximum( temp-date.num2, temp-date.num3, temp-date.num4) - 1 :
         assign kk = 0  .
         do jj = 2 to 4:
           if jj = 2 and not is-real then next.
           if jj = 3 and not is-fo   then next.
           if jj = 4 and not is-fin  then next.

           find first temp-sum
             where temp-sum.cli-type = temp-doc.cli-type
               and temp-sum.cli-code = temp-doc.cli-code
               and temp-sum.contr    = temp-doc.contr
               and temp-sum.dat      = temp-date.dat
               and temp-sum.ind      = ind
               and temp-sum.type     = jj
           no-error .
           if available temp-sum then do:
             if not itog-only then do:
               run is-page in this-procedure .
               put stream PrnLibStream
                 "|" at ({&L1} + kk * 45)  temp-sum.dat    format {&F1}
                 "|" at ({&L2} + kk * 45)  temp-sum.num    format {&F2}
                 "|" at ({&L3} + kk * 45)  temp-sum.styp   format {&F3}
                 "|" at ({&L4} + kk * 45)  temp-sum.sum    format {&F4}
               .
               run macr_excel_char(string(temp-sum.dat,"99/99/9999")  , v-row, kk * 4 + 1 ) .
               run macr_excel_char(temp-sum.num  , v-row, kk * 4 + 2) .
               run macr_excel_char(temp-sum.styp , v-row, kk * 4 + 3 ) .
               run macr_excel_sum (temp-sum.sum  , v-row, kk * 4 + 4 , 2) .
             end.
             case jj :
               when 1 then assign v-sm1-contr = v-sm1-contr + temp-sum.sum .
               when 2 then assign v-sm2-contr = v-sm2-contr + temp-sum.sum .
               when 3 then assign v-sm3-contr = v-sm3-contr + temp-sum.sum .
               when 4 then assign v-sm4-contr = v-sm4-contr + temp-sum.sum .
             end.
           end.
           else do:
             if not itog-only then do:
               run is-page in this-procedure .
               put stream PrnLibStream
                 "|" at ({&L1} + kk * 45)
                 "|" at ({&L2} + kk * 45)
                 "|" at ({&L3} + kk * 45)
                 "|" at ({&L4} + kk * 45)
               .
             end.
           end.
           assign kk = kk + 1 .
         end.
         if not itog-only then do:
           put stream PrnLibStream "|" at {&L6}  "|" at {&L7}   skip .
           assign v-row = v-row + 1 .
         end.
       end.
     end.
   end.
   else do:
     do ind = 0 to maximum(temp-doc.num2, temp-doc.num3, temp-doc.num4) - 1 :
       assign kk = 0  .
       do jj = 2 to 4:
         if jj = 2 and not is-real then next.
         if jj = 3 and not is-fo   then next.
         if jj = 4 and not is-fin  then next.
         find first temp-sum
           where temp-sum.cli-type = temp-doc.cli-type
             and temp-sum.cli-code = temp-doc.cli-code
             and temp-sum.contr    = temp-doc.contr
             and temp-sum.ind      = ind
             and temp-sum.type     = jj
         no-error .
         if available temp-sum then do:
           if not itog-only then do:
             run is-page in this-procedure .
             put stream PrnLibStream
               "|" at ({&L1} + kk * 45)  temp-sum.dat    format {&F1}
               "|" at ({&L2} + kk * 45)  temp-sum.num    format {&F2}
               "|" at ({&L3} + kk * 45)  temp-sum.styp   format {&F3}
               "|" at ({&L4} + kk * 45)  temp-sum.sum    format {&F4}
             .
             run macr_excel_char(string(temp-sum.dat,"99/99/9999")  , v-row, kk * 4 + 1 ) .
             run macr_excel_char(temp-sum.num  , v-row, kk * 4 + 2) .
             run macr_excel_char(temp-sum.styp , v-row, kk * 4 + 3 ) .
             run macr_excel_sum (temp-sum.sum  , v-row, kk * 4 + 4 , 2) .
           end.
           case jj :
             when 1 then assign v-sm1-contr = v-sm1-contr + temp-sum.sum .
             when 2 then assign v-sm2-contr = v-sm2-contr + temp-sum.sum .
             when 3 then assign v-sm3-contr = v-sm3-contr + temp-sum.sum .
             when 4 then assign v-sm4-contr = v-sm4-contr + temp-sum.sum .
           end.
         end.
         else do:
           if not itog-only then do:
             run is-page in this-procedure .
             put stream PrnLibStream
               "|" at ({&L1} + kk * 45)
               "|" at ({&L2} + kk * 45)
               "|" at ({&L3} + kk * 45)
               "|" at ({&L4} + kk * 45)
             .
           end.
         end.
         assign kk = kk + 1 .
       end.
       if not itog-only then do:
         put stream PrnLibStream "|" at {&L6}  "|" at {&L7}   skip .
         assign v-row = v-row + 1 .
       end.
     end.
   end.
  end.
end procedure. /* prn-line */



procedure PutColumnTitulExcel : /* заголовки для колонок экселя */
  do
  on error undo, return error return-value
  :
    assign  v-row = 5 .
    run macr_excel_char (ReportNAme, 1, 2) .
    run macr_cell_format ( 11, yes, no, ?, 1, 2, 1, 2) .
    run macr_excel_char (str1, 2, 1) .

    assign ii = 1 .

    if is-real then do:
      run macr_excel_char("Реализация", 3, ii + 1) .
      run macr_excel_char("Дата факт", 4, ii) .
      run macr_cell_size (10,?, 4, ii,?,?).
      run macr_excel_char("№ док-та", 4, ii + 1) .
      run macr_cell_size (10,?, 4, ii + 1,?,?).
      run macr_excel_char("тип", 4, ii + 2) .
      run macr_cell_size (4,?, 4, ii + 2,?,?).
      run macr_excel_char(string(" Сумма (" + s-val + ")"), 4, ii + 3) .
      run macr_cell_size (16,?, 4, ii + 3,?,?).
      assign ii = ii + 4  .
    end.
    if is-fo then do:
      run macr_excel_char("Фин. обязательства", 3, ii + 1) .
      run macr_excel_char("Дата факт", 4, ii) .
      run macr_cell_size (10,?, 4, ii,?,?).
      run macr_excel_char("№ док-та", 4, ii + 1) .
      run macr_cell_size (10,?, 4, ii + 1,?,?).
      run macr_excel_char("тип", 4, ii + 2) .
      run macr_cell_size (4,?, 4, ii + 2,?,?).
      run macr_excel_char(string(" Сумма (" + s-val + ")"), 4, ii + 3) .
      run macr_cell_size (16,?, 4, ii + 3,?,?).
      assign ii = ii + 4  .
    end.
    if is-fin then do:
      run macr_excel_char("Платежи", 3, ii + 1) .
      run macr_excel_char("Дата факт", 4, ii) .
      run macr_cell_size (10,?, 4, ii,?,?).
      run macr_excel_char("№ док-та", 4, ii + 1) .
      run macr_cell_size (10,?, 4, ii + 1,?,?).
      run macr_excel_char("тип", 4, ii + 2) .
      run macr_cell_size (4,?, 4, ii + 2,?,?).
      run macr_excel_char(string(" Сумма (" + s-val + ")"), 4, ii + 3) .
      run macr_cell_size (16,?, 4, ii + 3,?,?).
      assign ii = ii + 4  .
    end.
    run macr_excel_char("Сумма долга", 3, ii) .
    run macr_cell_size (14,?, 3, ii,?,?).

    run macr_cell_bordur ( 3, 1, 4, ii) .
    run macr_cell_format ( 10, yes, no, 35, 3, 1, 4, ii) .

    put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , 3 , ii    , 3 , ii ) skip .
    put  stream macr_excel unformatted 'BORDER( 0, 1, 1, 1, 0, ,0,0,0,0,0) '  skip .
    put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , 4 , ii    , 4 , ii ) skip .
    put  stream macr_excel unformatted 'BORDER( 0, 1, 1, 0, 1, ,0,0,0,0,0) '  skip .

    assign ii = 1 .
    if is-real then do:
      put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , 3 , ii    , 3 , ii ) skip .
      put  stream macr_excel unformatted 'BORDER( 0, 1, 0, 1, 1, ,0,0,0,0,0) '  skip .
      put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , 3 , ii + 1, 3 , ii + 2 ) skip .
      put  stream macr_excel unformatted 'BORDER( 0, 0, 0, 1, 1, ,0,0,0,0,0) '  skip .
      put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , 3 , ii + 3, 3 , ii + 3 ) skip .
      put  stream macr_excel unformatted 'BORDER( 0, 0, 1, 1, 1, ,0,0,0,0,0) '  skip .
      assign ii = ii + 4  .
    end.
    if is-fo then do:
      put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , 3 , ii    , 3 , ii ) skip .
      put  stream macr_excel unformatted 'BORDER( 0, 1, 0, 1, 1, ,0,0,0,0,0) '  skip .
      put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , 3 , ii + 1, 3 , ii + 2 ) skip .
      put  stream macr_excel unformatted 'BORDER( 0, 0, 0, 1, 1, ,0,0,0,0,0) '  skip .
      put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , 3 , ii + 3, 3 , ii + 3 ) skip .
      put  stream macr_excel unformatted 'BORDER( 0, 0, 1, 1, 1, ,0,0,0,0,0) '  skip .
      assign ii = ii + 4  .
    end.
    if is-fin then do:
      put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , 3 , ii    , 3 , ii ) skip .
      put  stream macr_excel unformatted 'BORDER( 0, 1, 0, 1, 1, ,0,0,0,0,0) '  skip .
      put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , 3 , ii + 1, 3 , ii + 2 ) skip .
      put  stream macr_excel unformatted 'BORDER( 0, 0, 0, 1, 1, ,0,0,0,0,0) '  skip .
      put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , 3 , ii + 3, 3 , ii + 3 ) skip .
      put  stream macr_excel unformatted 'BORDER( 0, 0, 1, 1, 1, ,0,0,0,0,0) '  skip .
      assign ii = ii + 4  .
    end.

   end.
end procedure. /* PutColumnTitulExcel */


procedure is-page :
  do
  on error undo, return error return-value
  :
    if line-counter( PrnLibStream ) + 3 > page-size( PrnLibStream ) then do:
      put stream PrnLibStream  skip Line format {&FL} skip "продолжение - на следующей странице" AT 30 SKIP .
      page stream PrnLibStream .
      run PrintTitul .
    end.
    if  ( v-row ) >= 63000 then do:
      Output stream Macr_Excel  close .
      run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name ) .
      run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
      output stream  Macr_Excel to value(v-file-name) .
      assign
        v-ind = v-ind + 1
        v-row = 2
      .
      run PutColumnTitulExcel in this-procedure .
    end.
  end.
end procedure. /* is-page */


procedure PrintTitul :
  do
  on error undo, return error return-value
  :
    PUT stream PrnLibStream SPACE(10) ReportNAme format "X(100)" SKIP .
    PUT stream PrnLibStream str1 format "X(100)" SKIP .

    put stream PrnLibStream  skip cur-time-print() format "x(35)" string( "Страница" ) AT 45 PAGE-NUMBER( PrnLibStream ) AT 55 FORMAT ">>>>>9" SKIP .

    put stream PrnLibStream  skip  Line format {&FL}  skip .
    assign ii = 0 .
    if is-real then do:
      put stream PrnLibStream  "|" at ({&L1} + ii * 45) "Реализация"  at ({&L3} + ii * 45)   format "X(20)" .
      assign ii = ii + 1 .
    end.
    if is-fo then do:
      put stream PrnLibStream  "|" at ({&L1} + ii * 45) "Фин. обязательства"  at ({&L3} + ii * 45)   format "X(20)" .
      assign ii = ii + 1 .
    end.
    if is-fin then do:
      put stream PrnLibStream  "|" at ({&L1} + ii * 45) "Платежи"  at ({&L3} + ii * 45)   format "X(20)" .
      assign ii = ii + 1 .
    end.

    put stream PrnLibStream
      "|" at {&L6} string("Сумма долга") format "X(14)"
      "|" at {&L7}
      skip  Line format {&FL1}  "|" at {&L7} skip .

    do ii = 0 to num-col - 1 :
      put stream PrnLibStream
        "|" at ({&L1} + ii * 45)  "Дата ф."                         format "X(8)"
        "|" at ({&L2} + ii * 45)  "№ док-та"                        format "X(10)"
        "|" at ({&L3} + ii * 45)  "Тип"                             format "X(3)"
        "|" at ({&L4} + ii * 45)  string(" Сумма (" + s-val + ")")  format "X(18)"
      .
    end.
    put stream PrnLibStream  "|" at {&L6} string("("+ s-val + ")") format "X(10)" "|" at {&L7}  skip  Line format {&FL}  skip .
  end.
end procedure. /* PrintTitul */


/*procedure CalcOstatTov:*/
/*  do on error undo, return error return-value :*/
/*    define input  parameter p-type     as character no-undo .*/
/*    define output parameter p-sum-exp  as decimal   no-undo .*/
/*    define output parameter p-sum-inc  as decimal   no-undo .*/

/*    find last buf_arh-trn-doc-contract no-lock*/
/*      where buf_arh-trn-doc-contract.host-code      = v-cntxt-host-code-obj*/
/*        and buf_arh-trn-doc-contract.contract-code  = v-contract-code*/
/*        and buf_arh-trn-doc-contract.cli-type       = temp-cli.obj-type*/
/*        and buf_arh-trn-doc-contract.cli-code       = temp-cli.obj-code*/
/*        and buf_arh-trn-doc-contract.obj-type       = temp-obj-firm.obj-type*/
/*        and buf_arh-trn-doc-contract.obj-code       = temp-obj-firm.obj-code*/
/*        and buf_arh-trn-doc-contract.ext-doc-type   = p-type*/
/*        and buf_arh-trn-doc-contract.sum-type       = ""*/
/*        and buf_arh-trn-doc-contract.fact-order     <= v-fact-order-start*/
/*    no-error .*/
/*    if available buf_arh-trn-doc-contract then do:*/
/*      if x-SET_val_TYPE = 1  then*/
/*        assign*/
/*          p-sum-exp = buf_arh-trn-doc-contract.exp-sum-rubl*/
/*          p-sum-inc = buf_arh-trn-doc-contract.inc-sum-rubl*/
/*        .*/
/*      else*/
/*        assign*/
/*          p-sum-exp = buf_arh-trn-doc-contract.exp-sum-base*/
/*          p-sum-inc = buf_arh-trn-doc-contract.inc-sum-base*/
/*        .*/
/*    end.*/
/*  end.*/
/*end procedure. /* CalcOstatTov */*/


procedure CalcOstatFin:
  do on error undo, return error return-value :
    define input  parameter p-type     as character no-undo .
    define output parameter p-sum-exp  as decimal   no-undo .
    define output parameter p-sum-inc  as decimal   no-undo .

    find last buf_arh-fin-doc-contr-schet no-lock
      where buf_arh-fin-doc-contr-schet.host-code        = v-cntxt-host-code-obj
        and buf_arh-fin-doc-contr-schet.contract-code    = v-contract-code
        and buf_arh-fin-doc-contr-schet.code-schet       = 0
        and buf_arh-fin-doc-contr-schet.cli-code         = temp-cli.obj-code
        and buf_arh-fin-doc-contr-schet.cli-type         = temp-cli.obj-type
        and buf_arh-fin-doc-contr-schet.fin-ext-doc-type = p-type
        and buf_arh-fin-doc-contr-schet.calc-curr-code   = v-curr-r-b
        and buf_arh-fin-doc-contr-schet.sum-type         = {&arh-fin-doc-contr-schet-sum-contract}
        and buf_arh-fin-doc-contr-schet.fact-order      < v-fact-order-start
    no-error .
    if available buf_arh-fin-doc-contr-schet then
      assign
        p-sum-exp = buf_arh-fin-doc-contr-schet.expense
        p-sum-inc = buf_arh-fin-doc-contr-schet.income
      .
  end.
end procedure. /* CalcOstatFin */

procedure CalcOstatFinNal:
  do on error undo, return error return-value :
    define input  parameter p-type     as character no-undo .
    define output parameter p-sum-exp  as decimal   no-undo .
    define output parameter p-sum-inc  as decimal   no-undo .

    find last buf_arh-fin-doc-contr-schet-nal no-lock
      where buf_arh-fin-doc-contr-schet-nal.host-code        = v-cntxt-host-code-obj
        and buf_arh-fin-doc-contr-schet-nal.contract-code    = v-contract-code
        and buf_arh-fin-doc-contr-schet-nal.cli-code         = temp-cli.obj-code
        and buf_arh-fin-doc-contr-schet-nal.cli-type         = temp-cli.obj-type
        and buf_arh-fin-doc-contr-schet-nal.fin-code-acc     = 0
        and buf_arh-fin-doc-contr-schet-nal.fin-ext-doc-type = p-type
        and buf_arh-fin-doc-contr-schet-nal.curr-code        = v-curr-r-b
        and buf_arh-fin-doc-contr-schet-nal.calc-curr-code   = v-curr-r-b
        and buf_arh-fin-doc-contr-schet-nal.sum-type         = {&arh-fin-doc-contr-schet-nal-sum-contract}
        and buf_arh-fin-doc-contr-schet-nal.fact-order      < v-fact-order-start
    no-error .
    if available buf_arh-fin-doc-contr-schet-nal then
      assign
        p-sum-exp = buf_arh-fin-doc-contr-schet-nal.expense
        p-sum-inc = buf_arh-fin-doc-contr-schet-nal.income
      .
  end.
end procedure. /* CalcOstatFinNal */


procedure PrnSumCli :
  do on error undo, return error return-value :
    define input  parameter p-sm2 as decimal   no-undo .
    define input  parameter p-sm3 as decimal   no-undo .
    define input  parameter p-sm4 as decimal   no-undo .

    assign ii = 0 .
    if is-real then do:
      put stream PrnLibStream "|" at ({&L4} + ii * 45)  p-sm2   format {&F4}  "|" at ({&L5} + ii * 45) .
      run macr_excel_sum (p-sm2, v-row, ii * 4 + 4 , 2) .
      assign ii = ii + 1 .
    end.
    if is-fo then do:
      put stream PrnLibStream "|" at ({&L4} + ii * 45)  p-sm3   format {&F4}  "|" at ({&L5} + ii * 45) .
      run macr_excel_sum (p-sm3, v-row, ii * 4 + 4 , 2) .
      assign ii = ii + 1 .
    end.
    if is-fin then do:
      put stream PrnLibStream "|" at ({&L4} + ii * 45)  p-sm4   format {&F4}  "|" at ({&L5} + ii * 45) .
      run macr_excel_sum (p-sm4, v-row, ii * 4 + 4 , 2) .
      assign ii = ii + 1 .
    end.
    if is-fin and is-fo then do:
      put stream PrnLibStream   (p-sm3 - p-sm4)  format {&F5}   "|" at {&L7} skip .
      run macr_excel_sum ((p-sm3 - p-sm4), v-row, ii * 4 + 1 , 2) .
    end.
    else  put stream PrnLibStream    "|" at {&L7} skip .

    assign v-row = v-row + 1 .
    run is-page in this-procedure .

  end.
end procedure. /* PrnSumCli */


procedure new-date :
  do on error undo, return error return-value :
    find first temp-date
      where temp-date.dat      = temp-sum.dat
        and temp-date.cli-type = temp-sum.cli-type
        and temp-date.cli-code = temp-sum.cli-code
        and temp-date.contr    = temp-sum.contr
    no-error .
    if not available temp-date then do:
      create temp-date .
      assign
        temp-date.dat      = temp-sum.dat
        temp-date.cli-type = temp-sum.cli-type
        temp-date.cli-code = temp-sum.cli-code
        temp-date.contr    = temp-sum.contr
      .
    end.
    case temp-sum.type :
      when 1 then assign  temp-sum.ind = temp-date.num1   temp-date.num1 = temp-date.num1 + 1 .
      when 2 then assign  temp-sum.ind = temp-date.num2   temp-date.num2 = temp-date.num2 + 1 .
      when 3 then assign  temp-sum.ind = temp-date.num3   temp-date.num3 = temp-date.num3 + 1 .
      when 4 then assign  temp-sum.ind = temp-date.num4   temp-date.num4 = temp-date.num4 + 1 .
    end.
  end.
end procedure. /* new-date */