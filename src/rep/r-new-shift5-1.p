block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

печать сменного отчета лист 5

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/06/07
Author: Dmitry Ukhanov
Creation date: 08/06/07

Автор: Булгаков Андрей Николаевич
Дата создания: 04/12/06
Author: Andrew Bulgakoff
Creation date: 04/12/06

*/

define input parameter parparentproc as   widget-handle       no-undo .
define input parameter p-parent-handle            as handle    no-undo .
define input parameter p-log-handle               as handle    no-undo .
define input parameter p-cont-handle              as handle    no-undo .
define input parameter p-rebh                     as handle    no-undo .
define input parameter p-rdbh                     as handle    no-undo . /*destination*/
define input parameter v-report-name-html         as character no-undo .
define input parameter p-log-file-name            as character no-undo .
define input parameter p-batch                    as integer   no-undo .
define input parameter p-codex-id                 as integer   no-undo .
define input parameter p-ruleset-id               as integer   no-undo .
define input parameter p-obj-type    like ub.clients.obj-type no-undo .
define input parameter p-obj-code    like ub.clients.obj-code no-undo .

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "печать сменного отчета (лист 5)":U .

{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ cmp/r-pril.i new }
{ rep/r-sym.i    }

{ trg/factord.i  }

{ gbl/paramls.i  }
{ rep/ostatok.i  }
{ rep/fostatok.i  &arh-name = "arh-fin-doc-schet-nal-obj" }
{ rep/ost-line.i }
{ str/farh-def.i }
{ cmp/trg-def.i }

define NEW SHARED variable is-rosneft as logical no-undo init NO.

{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
define variable v-cntxt-obj-name      as character no-undo .

/*переменные для вывода отчета в HTML*/
define stream Out-Stream.
define stream OutStr-html.


&scop display-message ~
   if p-batch > 0 then do: ~
     run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input p-log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~). ~
   end. ~
   else do: ~
      run write-to-log in p-log-handle ( input ~{&my-message~}). ~
   end


&scop All-sym6 sym1 sym2 sym3 sym4 sym5 sym6

define temp-table temp-fin-doc no-undo
FIELD sheet-num        as integer
FIELD host-code        as integer
FIELD obj-code         as integer
FIELD obj-type         as character
FIELD obj-name         as character
FIELD ost-begin        as decimal
FIELD income-realiz    as decimal
FIELD income-other     as decimal
FIELD expense-bank     as decimal
FIELD expense-other    as decimal
FIELD ost-end          as decimal
FIELD staff-curr1      as character
FIELD staff-curr2      as character
FIELD staff-curr3      as character
FIELD staff-curr4      as character
FIELD staff-curr5      as character
FIELD staff-next1      as character
FIELD staff-next2      as character
FIELD staff-next3      as character
FIELD staff-next4      as character
FIELD staff-next5      as character
field cashbook         as character 
field cashbookid       as integer

INDEX pi is primary unique sheet-num host-code obj-code obj-type cashbookid
.

define buffer buf_clients                   for ub.clients .
define buffer buf_fin-doc                   for ub.fin-doc .
define buffer buf_arh-fin-doc-schet-nal-obj for ub.arh-fin-doc-schet-nal-obj .
define buffer buf_clients-attr              for ub.clients-attr .
define buffer buf_shift-staff               for ub.shift-staff .
define buffer buf_sysconf                   for ub.sysconf .
define buffer buf_cashbook                  for ub.CashBook .

define variable v-count        as integer   no-undo .
define variable v-str          as integer   no-undo .
define variable v-firm         as character no-undo .
define variable v-object       as character no-undo .
define variable v-host-code    as integer   no-undo .
define variable v-sum-begin    as decimal   no-undo .
define variable sum1           as decimal   no-undo .

define variable f-ost-begin     as character no-undo .
define variable f-cashf-begin   as character no-undo .
define variable f-income-realiz as character no-undo .
define variable f-income-other  as character no-undo .
define variable f-expense-bank  as character no-undo .
define variable f-expense-other as character no-undo .
define variable f-ost-end       as character no-undo .
define variable f-cashf-end     as character no-undo .

define variable v-ost-begin     as decimal   no-undo .
define variable v-income-realiz as decimal   no-undo .
define variable v-income-other  as decimal   no-undo .
define variable v-expense-bank  as decimal   no-undo .
define variable v-expense-other as decimal   no-undo .
define variable v-ost-end       as decimal   no-undo .
define variable v-sheet         as integer   no-undo .
define variable v-obj-name      as character no-undo .
define variable v-obj-type1     as character no-undo .
define variable v-obj-code1     as integer   no-undo .
define variable v-num-obj       as integer   no-undo .

define variable v-col1  as decimal no-undo .
define variable v-col3  as decimal no-undo .
define variable v-col31 as decimal no-undo .
define variable v-col41 as decimal no-undo .
define variable v-col45 as decimal no-undo .
define variable v-col4  as decimal no-undo .
define variable v-col5  as decimal no-undo .
define variable v-col6  as decimal no-undo .

define variable v-col1-propis  as character no-undo .
define variable v-col3-propis  as character no-undo .
define variable v-col45-propis as character no-undo .
define variable v-col4-propis  as character no-undo .
define variable v-col5-propis  as character no-undo .
define variable v-col6-propis  as character no-undo .
define variable abbr           as character no-undo .

define variable v-ost-begin-all     as decimal no-undo .
define variable v-income-realiz-all as decimal no-undo .
define variable v-income-other-all  as decimal no-undo .
define variable v-expense-bank-all  as decimal no-undo .
define variable v-expense-other-all as decimal no-undo .
define variable v-ost-end-all       as decimal no-undo .

define variable x-store-code    like ub.clients.obj-code   no-undo .
define variable x-store-type    like ub.clients.obj-type   no-undo .

define variable Fact-order-1    like ub.stk-tot.Fact-order no-undo .
define variable Fact-order-2    like ub.stk-tot.Fact-order no-undo .

define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo init -1.

define variable Counter1          as integer   no-undo .
define variable v-date-name       as character no-undo .
define variable v-shift-on        as logical   no-undo .
define variable v-sheet-num       as integer   no-undo .

define variable v-user-action     as character no-undo .
define variable v-printed         as logical   no-undo .
define variable disabledoptions   as integer   no-undo .
define variable v-orient-page     as character no-undo .
define variable v-file-name       as character no-undo .
define variable v-file-name-ind   as integer   no-undo .
define variable v-line            as character no-undo .
define variable v-underline       as character no-undo .
define variable v-fio-sign        as character no-undo .
define variable v-par-type        as character no-undo .
define variable v-cashbook        as character no-undo .
define variable v-cashbookid      as integer   no-undo .

  { gbl/working.i }

    assign  Counter1 = 0 .
    { rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
    { rep/repfrm.i on 1 } /* Показать окно информации о текущем процессе */

/* собирание данных */

    find first buf_clients
          where buf_clients.obj-type = {&cmp}
          and   buf_clients.obj-code = v-cntxt-host-code-obj
          no-lock
          .
    assign v-firm = buf_clients.obj-name  .

        for each   temp-fin-doc :
            delete temp-fin-doc .
        end .

        assign
          v-ost-begin = 0
        .
        run report-exec in this-procedure .


/*Определение фирмы*/
    find first buf_clients
          where buf_clients.obj-type = {&cmp}
          and   buf_clients.obj-code = v-cntxt-host-code-obj
          no-lock
          .
    assign v-firm = buf_clients.obj-name  .

        for each   temp-fin-doc :
            delete temp-fin-doc .
        end .

        assign
          v-ost-begin = 0
        .
        run report-exec in this-procedure .

        if is-rosneft then do:
            assign
                temp-fin-doc.income-realiZ = temp-fin-doc.income-realiZ + temp-fin-doc.income-other
                temp-fin-doc.income-other = 0
                . 
        end.
/*шапка таблицы HTML*/
         
output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
put stream OutStr-html unformatted
  substitute (
  '<tbody> <!-- Здесь начинается таблица отчета -->
            <tr> <!-- Первые строки – шапка таблицы с тэгами tr -->
                <th colspan="9" style="text-align: center;">Движение денежных средств</th>
            </tr>
            <tr>
                <th rowspan="2" style="text-align: center;">Кассовая книга</th>
                <th rowspan="2" style="text-align: center;">Остаток денежных средств на начало смены</th>
                <th rowspan="2" style="text-align: center;">в т.ч. кассовый фонд</th>
                <th colspan="2" style="text-align: center;">Приход</th>
                <th colspan="2" style="text-align: center;">Расход</th>
                <th rowspan="2" style="text-align: center;">Остаток денежных средств на конец смены</th>
                <th rowspan="2" style="text-align: center;">в т.ч. кассовый фонд</th>
            </tr>
            <tr>
                <th style="text-align: center;">Реализация</th>
                <th style="text-align: center;">Прочее</th>
                <th style="text-align: center;">Инкассация в банк</th>
                <th style="text-align: center;">Прочее</th>
            </tr>
            <tr>
                <th style="text-align: center;">5.1</th>
                <th style="text-align: center;">5.2</th>
                <th style="text-align: center;">5.3</th>
                <th style="text-align: center;">5.4</th>
                <th style="text-align: center;">5.5</th>
                <th style="text-align: center;">5.6</th>
                <th style="text-align: center;">5.7</th>
                <th style="text-align: center;">5.8</th>
                <th style="text-align: center;">5.9</th>      
            </tr>
            '
  , chr(123), chr(125)
  ).

   for each temp-fin-doc:
    put stream OutStr-html unformatted
      substitute (
      '<tr>
                <td num="#0.00" style="text-align: right;">&1</td>
                <td num="#0.00" style="text-align: right;">&2</td>
                <td num="#0.00" style="text-align: right;"></td>
                <td num="#0.00" style="text-align: right;">&3</td>
                <td num="#0.00" style="text-align: right;">&4</td>
                <td num="#0.00" style="text-align: right;">&5</td>
                <td num="#0.00" style="text-align: right;">&6</td>
                <td num="#0.00" style="text-align: right;">&7</td>
                <td num="#0.00" style="text-align: right;"></td>
            </tr>    
                '
           ,
            temp-fin-doc.cashbook,
            temp-fin-doc.ost-begin,
            temp-fin-doc.income-realiZ,
            temp-fin-doc.income-other,
            temp-fin-doc.expense-bank,
            temp-fin-doc.expense-other,
            temp-fin-doc.ost-end
      ).
      
      ASSIGN
      v-col1 = v-col1 + temp-fin-doc.ost-begin 
      v-col3 = v-col3 + (temp-fin-doc.income-realiZ + temp-fin-doc.income-other) 
      v-col45 = v-col45 + (temp-fin-doc.expense-bank + temp-fin-doc.expense-other) 
      v-col4 = v-col4 + temp-fin-doc.expense-bank
      v-col5 = v-col5 + temp-fin-doc.expense-other
      v-col6 = v-col6 + temp-fin-doc.ost-end
      v-col31 = v-col31 + temp-fin-doc.income-realiz
      v-col41 = v-col41 + temp-fin-doc.income-other
      .
      
    end.
        put stream OutStr-html unformatted
      substitute (
      '<tr>
                <td num="#0.00" style="text-align: right;">Итого:</td>
                <td num="#0.00" style="text-align: right;">&1</td>
                <td num="#0.00" style="text-align: right;"></td>
                <td num="#0.00" style="text-align: right;">&2</td>
                <td num="#0.00" style="text-align: right;">&3</td>
                <td num="#0.00" style="text-align: right;">&4</td>
                <td num="#0.00" style="text-align: right;">&5</td>
                <td num="#0.00" style="text-align: right;">&6</td>
                <td num="#0.00" style="text-align: right;"></td>
            </tr>    
                '
           ,
            v-col1,
            v-col31,
            v-col41,
            v-col4,
            v-col5,
            v-col6
      ).
      
        run rep/wp-rub.p ( input (v-col1), output v-col1-propis,  output abbr ).
        run rep/wp-rub.p ( input (v-col3), output v-col3-propis,  output abbr ).
        run rep/wp-rub.p ( input (v-col45), output v-col45-propis, output abbr ).
        run rep/wp-rub.p ( input (v-col4), output v-col4-propis,  output abbr ).
        run rep/wp-rub.p ( input (v-col5), output v-col5-propis,  output abbr ).
        run rep/wp-rub.p ( input (v-col6), output v-col6-propis,  output abbr ).


      if is-rosneft then do:
      put stream OutStr-html unformatted
      substitute (
      '<tfoot>
       <tr style="height:30px;">
                <td colspan="9"></td>
       </tr>
       <tr>
                <td colspan="3" style="text-align: left;">Принято по смене</td>
                <td style="text-align: right;"></td>
                <td colspan="5" style="text-align: left;">&1</td>
       </tr>               
       <tr>
                <td colspan="4" style="text-align: left;"></td>
                <td style="text-align: right;"></td>
                <td colspan="5" style="text-align: center; border-top: 1px solid black;">(прописью)</td>
       </tr>     
       <tr>
                <td colspan="3" style="text-align: left;">Выручка за смену</td>
                <td style="text-align: right;"></td>
                <td colspan="6" style="text-align: left;">&2</td>
       </tr>  
       <tr>
                <td colspan="4" style="text-align: left;"></td>
                <td style="text-align: right;"></td>
                <td colspan="5" style="text-align: center; border-top: 1px solid black;">(прописью)</td>
       </tr>     
       <tr>
                <td colspan="3" style="text-align: left;">Сдано: в банк</td>
                <td style="text-align: right;"></td>
                <td colspan="6" style="text-align: left;">&3</td>
       </tr>  
       <tr>
                <td colspan="4" style="text-align: left;"></td>
                <td style="text-align: right;"></td>
                <td colspan="5" style="text-align: center; border-top: 1px solid black;">(прописью)</td>
       </tr>     
       <tr>
                <td colspan="3" style="text-align: left;">Сдано: в офис</td>
                <td style="text-align: right;"></td>
                <td colspan="5" style="text-align: left;">&4</td>
       </tr>  
       <tr>
                <td colspan="4" style="text-align: left;"></td>
                <td style="text-align: right;"></td>
                <td colspan="5" style="text-align: center; border-top: 1px solid black;">(прописью)</td>
       </tr>     
       <tr>
                <td colspan="3" style="text-align: left;">Итого инкассировано</td>
                <td style="text-align: right;"></td>
                <td colspan="5" style="text-align: left;">&5</td>
       </tr>                                
       <tr>
                <td colspan="4" style="text-align: left;"></td>
                <td style="text-align: right;"></td>
                <td colspan="5" style="text-align: center; border-top: 1px solid black;">(прописью)</td>
       </tr>     
       <tr>
                <td colspan="3" style="text-align: left;">Передано по смене: наличных денег</td>
                <td style="text-align: right;"></td>
                <td colspan="5" style="text-align: left;">&6</td>
       </tr>     
       <tr>
                <td colspan="4" style="text-align: left;"></td>
                <td style="text-align: right;"></td>
                <td colspan="5" style="text-align: center; border-top: 1px solid black;">(прописью)</td>
       </tr>     
           
       '
           ,
            v-col1-propis,
            v-col3-propis,
            v-col45-propis,
            v-col4-propis,
            v-col5-propis,
            v-col6-propis
      ).
     end.
     else do:
      put stream OutStr-html unformatted
      substitute (
      '<tfoot>
       <tr style="height:30px;">
                <td colspan="9"></td>
       </tr>
       <tr>
                <td colspan="4" style="text-align: left;">Принято по смене</td>
                <td style="text-align: right;"></td>
                <td colspan="4" style="text-align: left;">&1</td>
       </tr>  
       <tr>
                <td colspan="4" style="text-align: left;"></td>
                <td style="text-align: right;"></td>
                <td colspan="4" style="text-align: center; border-top: 1px solid black;">(прописью)</td>
       </tr>                    
       <tr>
                <td colspan="4" style="text-align: left;">Передано по смене: наличных денег</td>
                <td style="text-align: right;"></td>
                <td colspan="4" style="text-align: left;">&2</td>
       </tr>
       <tr>
                <td colspan="4" style="text-align: left;"></td>
                <td style="text-align: right;"></td>
                <td colspan="4" style="text-align: center; border-top: 1px solid black;">(прописью)</td>
       </tr>     
       
                
       '
           ,
            v-col1-propis,
            v-col6-propis
      ).

     end.    
     output stream OutStr-html close.
     output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
     put stream OutStr-html unformatted                                                                     
        substitute (
        '
        </tbody>
        
        '                                                                                      
            , chr(123), chr(125)                                                                                                 
       ).                                                                                                    
      output stream OutStr-html close.
      
procedure report-exec :
  { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
  find first ub.cashbook no-lock where ub.cashbook.Status_ = 0 no-error .
  if not available (ub.cashbook) then do:
  assign
    v-ost-begin         = 0
    v-ost-begin-all     = 0
    v-income-realiZ-all = 0
    v-income-other-all  = 0
    v-expense-bank-all  = 0
    v-expense-other-all = 0
    v-ost-end-all       = 0
  .
    assign
      fact-order-1     = 0
      fact-order-2     = 0
      v-ost-begin      = 0
      v-income-realiZ  = 0
      v-income-other   = 0
      v-expense-bank   = 0
      v-expense-other  = 0
      v-ost-end        = 0
    .
  
    run fostatok in this-procedure (
         input   v-host-code
        ,input   p-obj-code
        ,input   p-obj-type
        ,input   x-tog-shift
        ,input   x-date-start - 1
        ,input   date('')
        ,input   x-shift-start
        ,input   X-shift-end
        ,input   yes /*xTog-obj*/
        ,input   0 /*p-curr-code*/
        ,input   0
        ,output  v-sum-begin
        ,output  Fact-order-1)
        no-error .

    run fostatok in this-procedure (
         input   v-host-code
        ,input   p-obj-code
        ,input   p-obj-type
        ,input   x-tog-shift
        ,input   x-date-end
        ,input   x-date-end
        ,input   X-shift-end
        ,input   X-shift-end
        ,input   yes /*xTog-obj*/
        ,input   0 /*p-curr-code*/
        ,input   0
        ,output  sum1
        ,output  Fact-order-2)
        no-error .

 for each buf_arh-fin-doc-schet-nal-obj no-lock
    where buf_arh-fin-doc-schet-nal-obj.host-code         = v-host-code
      and buf_arh-fin-doc-schet-nal-obj.obj-type          = p-obj-type
      and buf_arh-fin-doc-schet-nal-obj.obj-code          = p-obj-code
      and buf_arh-fin-doc-schet-nal-obj.cli-type          = {&cmp}
      and buf_arh-fin-doc-schet-nal-obj.cli-code          = v-host-code
      and buf_arh-fin-doc-schet-nal-obj.fin-code-acc      = 0
      and buf_arh-fin-doc-schet-nal-obj.cashbookid        = 0
      and buf_arh-fin-doc-schet-nal-obj.curr-code         = 0
      and buf_arh-fin-doc-schet-nal-obj.fin-ext-doc-type  = "":U
      and buf_arh-fin-doc-schet-nal-obj.calc-curr-code    = 0
      and buf_arh-fin-doc-schet-nal-obj.sum-type          = (if x-tog-shift then {&arh-fin-doc-schet-nal-obj-shift-obj} else {&arh-fin-doc-schet-nal-obj-obj} )
      and buf_arh-fin-doc-schet-nal-obj.fact-order       > fact-order-1
      and buf_arh-fin-doc-schet-nal-obj.fact-order       <= fact-order-2
        :
     find first buf_fin-doc
          where buf_fin-doc.host-code         = v-host-code
            and buf_fin-doc.fin-doc-code      = buf_arh-fin-doc-schet-nal-obj.fin-doc-code
            and buf_fin-doc.CashBookId        = buf_arh-fin-doc-schet-nal-obj.cashbookid
            and buf_fin-doc.obj-type          = p-obj-type
            and buf_fin-doc.obj-code          = p-obj-code
            and buf_fin-doc.status_           = {&fact}
            and (buf_fin-doc.fin-ext-doc-type = {&income-cash}
            or buf_fin-doc.fin-ext-doc-type   = {&expense-cash} )
          no-error.
          if available buf_fin-doc then do :
             &scop fin-doc-obj-type buf_fin-doc.obj-type
             &scop fin-doc-obj-code buf_fin-doc.obj-code
             if buf_fin-doc.trn-doc-code = {&fin-doc-cash-book-name} then do:
                assign Counter1 = Counter1 + 1.
                { rep/repfrm.i disp Counter1 }
                if buf_fin-doc.fin-ext-doc-type = {&income-cash} then do :
                      find first buf_sysconf no-lock
                           where buf_sysconf.host-code = v-host-code
                           no-error.
                      if available buf_sysconf
                      and buf_fin-doc.payer-type = buf_sysconf.sale-type
                      and buf_fin-doc.payer-code = buf_sysconf.sale-code
                      then do:   /*контрагент-реализация*/
                        assign
                          v-income-realiZ = v-income-realiZ + buf_fin-doc.sum-doc
                        .
                      end.
                      else do:
                        find first ub.CashBook no-lock where ub.CashBook.cli-code = buf_fin-doc.payer-code
                        and ub.CashBook.cli-type = buf_fin-doc.payer-type no-error .
                        if available (ub.CashBook) then do:
                        assign
                          v-income-realiZ = v-income-realiZ + buf_fin-doc.sum-doc
                        .
                        end.
                        else do:  
                        assign
                          v-income-other = v-income-other + buf_fin-doc.sum-doc
                        .
                        end.
                      end.
                end.
                else do :
                    find first buf_clients-attr
                    where buf_clients-attr.obj-type  = buf_fin-doc.receiver-type
                      and buf_clients-attr.obj-code  = buf_fin-doc.receiver-code
                      and buf_clients-attr.attr-code = {&attr-is-inkassator}
                      use-index pi no-error.
                      if available buf_clients-attr then do :
                        assign
                          v-expense-bank = v-expense-bank + buf_fin-doc.sum-doc
                        .
                      end.
                      else do :
                        assign
                          v-expense-other = v-expense-other + buf_fin-doc.sum-doc
                        .
                      end.
                end.
             end.
          end.
    end.
    assign
      v-ost-begin = v-ost-begin + v-sum-begin
    .

          create temp-fin-doc.
          assign
                temp-fin-doc.cashbookid     = 0
                temp-fin-doc.cashbook       = "Основная деятельность"
                temp-fin-doc.ost-begin      = v-ost-begin
                temp-fin-doc.income-realiZ  = v-income-realiZ
                temp-fin-doc.income-other   = v-income-other
                temp-fin-doc.expense-bank   = v-expense-bank
                temp-fin-doc.expense-other  = v-expense-other
                temp-fin-doc.ost-end        = v-ost-begin + ( v-income-realiZ + v-income-other ) - ( v-expense-bank + v-expense-other )
        .
end.
else do:
for each buf_cashbook no-lock where buf_cashbook.Status_ = 0:
  
    assign
    v-ost-begin         = 0
    v-ost-begin-all     = 0
    v-income-realiZ-all = 0
    v-income-other-all  = 0
    v-expense-bank-all  = 0
    v-expense-other-all = 0
    v-ost-end-all       = 0
  .
    assign
      fact-order-1     = 0
      fact-order-2     = 0
      v-ost-begin      = 0
      v-income-realiZ  = 0
      v-income-other   = 0
      v-expense-bank   = 0
      v-expense-other  = 0
      v-ost-end        = 0
    .
  
    run fostatok in this-procedure (
         input   v-host-code
        ,input   p-obj-code
        ,input   p-obj-type
        ,input   x-tog-shift
        ,input   x-date-start - 1
        ,input   date('')
        ,input   x-shift-start
        ,input   X-shift-end
        ,input   yes /*xTog-obj*/
        ,input   0 /*p-curr-code*/
        ,input   buf_cashbook.id
        ,output  v-sum-begin
        ,output  Fact-order-1)
        no-error .

    run fostatok in this-procedure (
         input   v-host-code
        ,input   p-obj-code
        ,input   p-obj-type
        ,input   x-tog-shift
        ,input   x-date-end
        ,input   x-date-end
        ,input   X-shift-end
        ,input   X-shift-end
        ,input   yes /*xTog-obj*/
        ,input   0 /*p-curr-code*/
        ,input   buf_cashbook.id
        ,output  sum1
        ,output  Fact-order-2)
        no-error .


 for each buf_arh-fin-doc-schet-nal-obj no-lock
    where buf_arh-fin-doc-schet-nal-obj.host-code         = v-host-code
      and buf_arh-fin-doc-schet-nal-obj.obj-type          = p-obj-type
      and buf_arh-fin-doc-schet-nal-obj.obj-code          = p-obj-code
      and buf_arh-fin-doc-schet-nal-obj.cli-type          = {&cmp}
      and buf_arh-fin-doc-schet-nal-obj.cli-code          = v-host-code
      and buf_arh-fin-doc-schet-nal-obj.fin-code-acc      = 0
      and buf_arh-fin-doc-schet-nal-obj.cashbookid        = buf_cashbook.id
      and buf_arh-fin-doc-schet-nal-obj.curr-code         = 0
      and buf_arh-fin-doc-schet-nal-obj.fin-ext-doc-type  = "":U
      and buf_arh-fin-doc-schet-nal-obj.calc-curr-code    = 0
      and buf_arh-fin-doc-schet-nal-obj.sum-type          = (if x-tog-shift then {&arh-fin-doc-schet-nal-obj-shift-obj} else {&arh-fin-doc-schet-nal-obj-obj} )
      and buf_arh-fin-doc-schet-nal-obj.fact-order       > fact-order-1
      and buf_arh-fin-doc-schet-nal-obj.fact-order       <= fact-order-2
        :
     find first buf_fin-doc
          where buf_fin-doc.host-code         = v-host-code
            and buf_fin-doc.fin-doc-code      = buf_arh-fin-doc-schet-nal-obj.fin-doc-code
            and buf_fin-doc.CashBookId        = buf_arh-fin-doc-schet-nal-obj.cashbookid
            and buf_fin-doc.obj-type          = p-obj-type
            and buf_fin-doc.obj-code          = p-obj-code
            and buf_fin-doc.status_           = {&fact}
            and (buf_fin-doc.fin-ext-doc-type = {&income-cash}
            or buf_fin-doc.fin-ext-doc-type   = {&expense-cash} )
          no-error.
          if available buf_fin-doc then do :
             &scop fin-doc-obj-type buf_fin-doc.obj-type
             &scop fin-doc-obj-code buf_fin-doc.obj-code
             if buf_fin-doc.trn-doc-code = {&fin-doc-cash-book-name} then do:
                assign Counter1 = Counter1 + 1.
                { rep/repfrm.i disp Counter1 }
                if buf_fin-doc.fin-ext-doc-type = {&income-cash} then do :
                      find first buf_sysconf no-lock
                           where buf_sysconf.host-code = v-host-code
                           no-error.
                      if available buf_sysconf
                      and buf_fin-doc.payer-type = buf_sysconf.sale-type
                      and buf_fin-doc.payer-code = buf_sysconf.sale-code
                      then do:   /*контрагент-реализация*/
                        assign
                          v-income-realiZ = v-income-realiZ + buf_fin-doc.sum-doc
                        .
                      end.
                      else do:
                        find first ub.CashBook no-lock where ub.CashBook.cli-code = buf_fin-doc.payer-code
                        and ub.CashBook.cli-type = buf_fin-doc.payer-type no-error .
                        if available (ub.CashBook) then do:
                        assign
                          v-income-realiZ = v-income-realiZ + buf_fin-doc.sum-doc
                        .
                        end.
                        else do:  
                        find first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = buf_fin-doc.CashBookId and
                        ub.CashBookRule.Code = "Avanscli-code" and ub.CashBookRule.RuleValue = string(buf_fin-doc.payer-code) no-error .
                        if available (ub.CashBookRule) and buf_fin-doc.payer-type = {&cmp} then do:
                        assign
                          v-income-realiZ = v-income-realiZ + buf_fin-doc.sum-doc
                        .
                        end.
                        else do:                         
                        assign
                          v-income-other = v-income-other + buf_fin-doc.sum-doc
                        .
                        end.
                        end.
                      end.

                end.
                else do :
                    find first buf_clients-attr
                    where buf_clients-attr.obj-type  = buf_fin-doc.receiver-type
                      and buf_clients-attr.obj-code  = buf_fin-doc.receiver-code
                      and buf_clients-attr.attr-code = {&attr-is-inkassator}
                      use-index pi no-error.
                      if available buf_clients-attr then do :
                        assign
                          v-expense-bank = v-expense-bank + buf_fin-doc.sum-doc
                        .
                      end.
                      else do :
                        assign
                          v-expense-other = v-expense-other + buf_fin-doc.sum-doc
                        .
                      end.
                end.
             end.
          end.
    end.
    assign
      v-ost-begin = v-ost-begin + v-sum-begin
    .
          create temp-fin-doc.
          assign
                temp-fin-doc.cashbookid     = buf_cashbook.id
                temp-fin-doc.ost-begin      = v-ost-begin
                temp-fin-doc.income-realiZ  = v-income-realiZ
                temp-fin-doc.income-other   = v-income-other
                temp-fin-doc.expense-bank   = v-expense-bank
                temp-fin-doc.expense-other  = v-expense-other
                temp-fin-doc.ost-end        = v-ost-begin + ( v-income-realiZ + v-income-other ) - ( v-expense-bank + v-expense-other )
        .
        if buf_cashbook.id = 0 then temp-fin-doc.cashbook       = "Основная деятельность" . else temp-fin-doc.cashbook = buf_cashbook.CashBookName .        
end. 
end. 

end procedure . /*report-exec*/      