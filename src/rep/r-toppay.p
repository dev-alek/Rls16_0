/*

$Revision: 3b789addcaba, 2696, rls $
$Author: EShklyar $
$Date: Пт дек 18 18:16:05 2020 +0300 $
$Workfile: r-toppay.p $
$Archive: rep/r-toppay.p $

Продажа топлива по видам платежа

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/05
Author: Bakhtadze Natalya
Creation date: 09/07/05

*/

using Progress.Lang.*.
using Ibs.Th.Gbl.ReportXml.
using Ibs.Th.Gbl.rep-out.
block-level on error undo, throw.

define variable vss-revision    as character no-undo init "$Revision: 3b789addcaba, 2696, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Пт дек 18 18:16:05 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-toppay.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-toppay.p $":U .
define variable vss-description as character no-undo init "Продажи топлива по видам платежа".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ cmp/r-page1.i  }
{ ref/gdsoattr.i }
{ gbl/waitfram.i }
{ rep/rep-bt.i }


&global-define  no-benefits    "Не было никакой выручки  ~
в течение заданного Вами периода времени."

define        variable NotInc          as log       no-undo.

define        variable Line            as char      no-undo.
define        variable date_string     as char      no-undo.

define        var      for-pay-name    like ub.cash-pay.obj-name no-undo.

define        var      cas-num         as integer   no-undo.
define shared var      method          as character no-undo.
define        var      my-set_val_type as integer   no-undo.
def shared    var      cas-shft        as logical   no-undo init no.


define        variable found           as logical   init yes no-undo.
define        variable bad-chk-str     as character no-undo .

define        variable Report          as class     ReportXml no-undo. /* Переменная под класс */
define        variable xml_tmp         as character no-undo. /*путь к временному файлу*/
define        variable xslt-path       as character no-undo. /*путь к шаблону */
define        variable rep-out-unit    as class     rep-out   no-undo. /*экземпляр класса формирования документа отчёта */

define temp-table benefits no-undo
  field date_       as date
  field b-code      like ub.bar-code.b-code
  field gds-name    like ub.goods.gds-name
  field qnty        as decimal   format "->>>,>>>,>>9.999"
  field pay-code    like ub.cash-pay.cdpay-code
  field pay-name    as character
  field curr-code   like ub.cash-pay.curr-code
  field tot-sum     like ub.chk-pay.tot-sum
  field tot-base    like ub.chk-pay.tot-base
  field tot-rubl    like ub.chk-pay.tot-rubl
  field pay-desk    like ub.chk-doc.pay-desk
  field is-real-top as integer
  index pi is primary b-code   pay-code curr-code date_ ascending
  index pc            pay-code b-code   ascending
  .

define temp-table benefits1 no-undo
  field b-code      like ub.bar-code.b-code
  field gds-name    like ub.goods.gds-name
  field qnty        as decimal   format "->>>,>>>,>>9.999"
  field pay-code    like ub.cash-pay.cdpay-code
  field pay-name    as character
  field curr-code   like ub.cash-pay.curr-code
  field tot-sum     like ub.chk-pay.tot-sum
  field tot-base    like ub.chk-pay.tot-base
  field tot-rubl    like ub.chk-pay.tot-rubl
  field pay-desk    like ub.chk-doc.pay-desk
  field is-real-top as integer
  index pi is primary b-code   pay-code curr-code ascending
  index pc            pay-code b-code   ascending
  .

define temp-table pays no-undo
  field qnty      as decimal format "->>>,>>>,>>9.999"
  field pay-code  like ub.cash-pay.cdpay-code
  field curr-code like ub.cash-pay.curr-code
  field pay-name  like ub.cash-pay.obj-name
  field tot-sum   like ub.chk-pay.tot-sum
  field tot-base  like ub.chk-pay.tot-base
  field tot-rubl  like ub.chk-pay.tot-rubl
  field pay-desk  like ub.chk-doc.pay-desk
  index pi is primary pay-code curr-code ascending
  .

define temp-table b-codes no-undo
  field qnty     as decimal format "->>>,>>>,>>9.999"
  field b-code   like ub.bar-code.b-code
  field gds-name like ub.goods.gds-name
  field tot-sum  like ub.chk-pay.tot-sum
  field tot-base like ub.chk-pay.tot-base
  field tot-rubl like ub.chk-pay.tot-rubl
  field pay-desk like ub.chk-doc.pay-desk
  index pi is primary b-code ascending
  .

define temp-table bad-chk no-undo
  field doc-code like ub.chk-doc.doc-code
  field delta    as decimal
  index pi is primary doc-code ascending
  .


define variable sym1        as char    init ":" no-undo.
define variable sym2        as char    init ":" no-undo.
define variable sym3        as char    init ":" no-undo.
define variable sym4        as char    init ":" no-undo.
define variable sym5        as char    init ":" no-undo.
define variable sym6        as char    init ":" no-undo.
define variable sym7        as char    init ":" no-undo.
define variable sym8        as char    init ":" no-undo.
define variable sym9        as char    init ":" no-undo.

define variable FrameType   as char    no-undo.

define variable DatePrinted as logical no-undo.

define buffer benBuffer       for benefits.
define buffer b-inkas         for ub.inkas .
define buffer b-inkas-pay     for ub.inkas-pay .
def    buffer buf_goods       for ub.goods.
def    buffer buf_chk-gds-pay for ub.chk-gds-pay.


define variable sale-price-type    as character.
define variable attr-value         as character no-undo .
define variable attr-type          as character no-undo .
define variable v-header-base-curr as character no-undo .
define variable v-curr-r-b         as character no-undo .
define variable v-mode             as character initial "nototal":U no-undo .
{ gbl/curr-r-b.i
  v-curr-r-b
}
if v-curr-r-b = {&r-b-base} then 
do:
  assign
    v-header-base-curr = string( "(Б.Вал. - " + caps( base-type ) + ")" )
    .
end.

{ rep/e-nobenq.i }

assign
  date_string     = cur-time-print()
  Line            = fill( "-", 142 )
  my-set_val_type = if x-set_Val_Type = 0 then {&v-base} else x-Set_val_type.


run no-benq(output found).

run no-benqi(output NotInc).

if not found then 
do:
  run waitfram-hide in this-procedure .
  message {&no-benefits} view-as alert-box information .
  return.
end.

run waitfram-show in this-procedure ( {&MyWaitMess} ) .
run ByTemp.

procedure ByTemp :
  if v-curr-r-b = {&r-b-base} then 
  do:
    sale-price-type = base-type.
  end.
  else 
  do:
    sale-price-type = "{&abbr_rubley}".
  end.

  run t-beneq.

  /* ВРЕМЕННО, ПОКА НЕ УДАСТСЯ СДЕЛАТЬ ОТЧЁТ ШТАТНО - комментирую запуск окон печати. Сейчас выводим отчёт напрямую в excel из окна s-object.w ТН-3085 2014г Шутилов. А. */
  /*if method = "b-code":U then run Proc-b-code.*/
  /*else run Proc-pay-code.                     */

  /* ВРЕМЕННО, ПОКА НЕ УДАСТСЯ СДЕЛАТЬ ОТЧЁТ ШТАТНО - комментирую запуск окон печати. Сейчас выводим отчёт напрямую в excel из окна s-object.w. ТН-3085 2014г Шутилов. А. */
  run Proc-b-code-excel.

end procedure.

/*Процедура вывода в Excel продажи топлива по типам оплаты*/
procedure Proc-b-code-excel:

  /*формируем xml */
  xml_tmp = string(session:temp-directory + "report-tmp2.xml"). /* путь к временному xml файлу */
  Report = new ReportXml(xml_tmp). 


  Report:worksheet("Лист 1").
  Report:worksheet-header("start").   /* Начало шапки отчета */
  Report:worksheet-header("     " + "Отчёт по видам топлива с разбивкой по типам оплаты").
  Report:worksheet-header("" ).
  case my-set_val_type :
    when {&v-base} then 
      do:
        if length(str4) > 90 
          then
        do:
          Report:worksheet-header(substring(str4, 1, 90)+ "..." ).
        end.
        else
        do:
          Report:worksheet-header(str4).
        end.
        Report:worksheet-header("").
        if length(str1) > 90        
          then
        do:
          Report:worksheet-header("     " + substring(str1, 1, 90)+ "..." ).
        end.
        else
        do:
          Report:worksheet-header("     " + str1 ).
        end.
      end.
    when {&v-all} then 
      do:
        if length(str4) > 115 
          then
        do:
          Report:worksheet-header(substring(str4, 1, 115)+ "..." ).
        end.
        else
        do:
          Report:worksheet-header(str4).
        end.
        Report:worksheet-header("").
        if length(str1) > 115        
          then
        do:
          Report:worksheet-header("     " + substring(str1, 1, 115)+ "..." ).
        end.
        else
        do:
          Report:worksheet-header("     " + str1 ).
        end.
      end.            
  end case.


  if NotInc then
    Report:worksheet-header("     " + "(сформирован по ВСЕМ ЧЕКАМ " + (if cas-num = 0 then "ВСЕХ КАСС" else
      ("КАССЫ: " + string(cas-num))) + ", включая невошедшие в отчеты о продажах)" ).
  else
    Report:worksheet-header("     " + "(сформирован по ВСЕМ ЧЕКАМ " + (if cas-num = 0 then "ВСЕХ КАСС" else
      ("КАССЫ: " + string(cas-num))) + ")").

  Report:worksheet-header("С разбивкой по датам").

  CASE my-set_val_type :
    when {&v-base} then 
      do:
        Report:worksheet-header("     " + date_string + v-header-base-curr).
      end.
    when {&v-all} then 
      do:
        Report:worksheet-header("     " + date_string + string( "  (Б.Вал. - " + caps( trim( base-type ) ) + ")" ) ).
      end.            
  END CASE .


  /*Конец шапки отчета*/ 
  Report:worksheet-header("end").
  
  CASE my-set_val_type :
    when {&v-base} then 
      do:
        Report:table-columns("60,60,150,30,30,120,70,70").    /* Начало таблицы, задаем размеры колонок */
        Report:table-types = "String,String,String,String,String,String,Qnty,Number".   /* Типы данных в таблице */
        Report:table-header("Дата|Код|Вид топлива|Вид опл.|Вал|Метод платежа|Литры|Сумма","40","9").    /* Шапка таблицы */     
      end.
        
    when {&v-all} then 
      do:
        Report:table-columns("60,60,125,30,30,120,70,70,70,70").    /* Начало таблицы, задаем размеры колонок */
        Report:table-types = "String,String,String,String,String,String,Qnty,String,Number,Number".   /* Типы данных в таблице */
        Report:table-header("Дата|Код|Вид топлива|Вид опл.|Вал|Метод платежа|Литры|Сумма в валюте|Сумма в Баз. валюте|Сумма в рублях","40","9").    /* Шапка таблицы */ 
      end.            
  END CASE .
  
  define variable total-qnty1     as decimal no-undo .  
  define variable total-tot-base1 as decimal no-undo .
  define variable total-tot-rubl1 as decimal no-undo .
  assign
    total-qnty1     = 0
    total-tot-base1 = 0
    total-tot-rubl1 = 0
    .
  
  FOR EACH benefits
    BREAk
    BY benefits.date_
    BY benefits.b-code
    BY benefits.pay-code  :
    assign
      total-qnty1     = total-qnty1 + benefits.qnty
      total-tot-base1 = total-tot-base1 + benefits.tot-base
      total-tot-rubl1 = total-tot-rubl1 + benefits.tot-rubl
      .
    IF FIRST-OF(benefits.date_) then 
    do:
      if benefits.is-real-top <> 0 then 
      do:
        CASE my-set_val_type :
          when {&v-base} then 
            do:
              Report:table-row(  (if benefits.date_ = ? then "" else string(benefits.date_, "99.99.9999"))
                + "|" +    (if benefits.b-code = ? then "" else string(benefits.b-code, "999999999"))
                + "|" +    (if benefits.gds-name = ? then "" else string(benefits.gds-name))
                + "|" +    (if benefits.pay-code = ? then "" else string(benefits.pay-code))
                + "|" +    (if benefits.curr-code = ? then "" else string(benefits.curr-code))
                + "|" +    (if benefits.pay-name = ? then "" else string(benefits.pay-name))
                + "|" +    (if benefits.qnty = ? then "" else string(benefits.qnty))
                + "|" +    (if v-curr-r-b = {&r-b-base}
                then (if benefits.tot-base = ? then "" else string(benefits.tot-base))
                else (if benefits.tot-rubl = ? then "" else string(benefits.tot-rubl)))
                ).
            end.
          when {&v-all} then 
            do:
              Report:table-row(  (if benefits.date_ = ? then "" else string(benefits.date_, "99.99.9999"))
                + "|" +    (if benefits.b-code = ? then "" else string(benefits.b-code, "999999999"))
                + "|" +    (if benefits.gds-name = ? then "" else string(benefits.gds-name))
                + "|" +    (if benefits.pay-code = ? then "" else string(benefits.pay-code))
                + "|" +    (if benefits.curr-code = ? then "" else string(benefits.curr-code))
                + "|" +    (if benefits.pay-name = ? then "" else string(benefits.pay-name))
                + "|" +    (if benefits.qnty = ? then "" else string(benefits.qnty))
                + "|" +    ""
                + "|" +    (if benefits.tot-base = ? then "" else string(benefits.tot-base))
                + "|" +    (if benefits.tot-rubl = ? then "" else string(benefits.tot-rubl))
                ).
            end.
        END CASE .
      end. 
    END.
    ELSE 
    do:
      if benefits.is-real-top <> 0 then 
      do:
        CASE my-set_val_type :
          when {&v-base} then 
            do:
              Report:table-row(  (if benefits.date_ = ? then "" else string(benefits.date_, "99.99.9999"))
                + "|" +    (if benefits.b-code = ? then "" else string(benefits.b-code, "999999999"))
                + "|" +    (if benefits.gds-name = ? then "" else string(benefits.gds-name))
                + "|" +    (if benefits.pay-code = ? then "" else string(benefits.pay-code))
                + "|" +    (if benefits.curr-code = ? then "" else string(benefits.curr-code))
                + "|" +    (if benefits.pay-name = ? then "" else string(benefits.pay-name))
                + "|" +    (if benefits.qnty = ? then "" else string(benefits.qnty))
                + "|" +    (if v-curr-r-b = {&r-b-base}
                then (if benefits.tot-base = ? then "" else string(benefits.tot-base))
                else (if benefits.tot-rubl = ? then "" else string(benefits.tot-rubl)))
                ).
            end.
          when {&v-all} then 
            do:
              Report:table-row(  (if benefits.date_ = ? then "" else string(benefits.date_, "99.99.9999"))
                + "|" +    (if benefits.b-code = ? then "" else string(benefits.b-code, "999999999"))
                + "|" +    (if benefits.gds-name = ? then "" else string(benefits.gds-name))
                + "|" +    (if benefits.pay-code = ? then "" else string(benefits.pay-code))
                + "|" +    (if benefits.curr-code = ? then "" else string(benefits.curr-code))
                + "|" +    (if benefits.pay-name = ? then "" else string(benefits.pay-name))
                + "|" +    (if benefits.qnty = ? then "" else string(benefits.qnty))
                + "|" +    ""
                + "|" +    (if benefits.tot-base = ? then "" else string(benefits.tot-base))
                + "|" +    (if benefits.tot-rubl = ? then "" else string(benefits.tot-rubl))
                ).

            end.
        END CASE .
      end. /*if benefits.is-real-top <> 0 then do:*/
    END. 
  END.
  CASE my-set_val_type :
    when {&v-base} then 
      do:
        Report:table-subtotal(  ""
          + "|" +    ""
          + "|" +    "За выбранный период:"
          + "|" +    ""
          + "|" +    ""
          + "|" +    "Итого"
          + "|" +    string(total-qnty1)
          + "|" +    (if v-curr-r-b = {&r-b-base}
          then string(total-tot-base1)
          else string(total-tot-rubl1))
          ).
      end.
    when {&v-all} then 
      do:
        Report:table-subtotal(   ""
          + "|" +    ""
          + "|" +    "За выбранный период:"
          + "|" +    ""
          + "|" +    ""
          + "|" +    "Итого"
          + "|" +    string(total-qnty1)
          + "|" +    ""
          + "|" +    string(total-tot-base1)
          + "|" +    string(total-tot-rubl1)
          ).
      end.
  END CASE .
  define variable total-qnty     as decimal no-undo .  
  define variable total-tot-base as decimal no-undo .
  define variable total-tot-rubl as decimal no-undo .
    
  FOR EACH benefits1
    BREAk
    BY benefits1.b-code
    BY benefits1.pay-code
    :
    IF FIRST-OF(benefits1.b-code) then 
    do:
      assign
        total-qnty     = 0
        total-tot-base = 0
        total-tot-rubl = 0
        .
      assign
        total-qnty     = total-qnty + benefits1.qnty
        total-tot-base = total-tot-base + benefits1.tot-base
        total-tot-rubl = total-tot-rubl + benefits1.tot-rubl
        .
      CASE my-set_val_type :
        when {&v-base} then 
          do:
            Report:table-row(  ""
              + "|" +    (if benefits1.b-code = ? then "" else string(benefits1.b-code, "999999999"))
              + "|" +    (if benefits1.gds-name = ? then "" else string(benefits1.gds-name))
              + "|" +    (if benefits1.pay-code = ? then "" else string(benefits1.pay-code))
              + "|" +    (if benefits1.curr-code = ? then "" else string(benefits1.curr-code))
              + "|" +    (if benefits1.pay-name = ? then "" else string(benefits1.pay-name))
              + "|" +    (if benefits1.qnty = ? then "" else string(benefits1.qnty))
              + "|" +    (if v-curr-r-b = {&r-b-base}
              then (if benefits1.tot-base = ? then "" else string(benefits1.tot-base))
              else (if benefits1.tot-rubl = ? then "" else string(benefits1.tot-rubl)))
              ).
          end.
        when {&v-all} then 
          do:
            Report:table-row(  ""
              + "|" +    (if benefits1.b-code = ? then "" else string(benefits1.b-code, "999999999"))
              + "|" +    (if benefits1.gds-name = ? then "" else string(benefits1.gds-name))
              + "|" +    (if benefits1.pay-code = ? then "" else string(benefits1.pay-code))
              + "|" +    (if benefits1.curr-code = ? then "" else string(benefits1.curr-code))
              + "|" +    (if benefits1.pay-name = ? then "" else string(benefits1.pay-name))
              + "|" +    (if benefits1.qnty = ? then "" else string(benefits1.qnty))
              + "|" +    ""
              + "|" +    (if benefits1.tot-base = ? then "" else string(benefits1.tot-base))
              + "|" +    (if benefits1.tot-rubl = ? then "" else string(benefits1.tot-rubl))
              ).
          end.
      END CASE .
    END.
    ELSE 
    do:
      assign
        total-qnty     = total-qnty + benefits1.qnty
        total-tot-base = total-tot-base + benefits1.tot-base
        total-tot-rubl = total-tot-rubl + benefits1.tot-rubl
        .
      if benefits1.is-real-top <> 0 then 
      do:
        CASE my-set_val_type :
          when {&v-base} then 
            do:
              Report:table-row(  ""
                + "|" +    ""
                + "|" +    ""
                + "|" +    (if benefits1.pay-code = ? then "" else string(benefits1.pay-code))
                + "|" +    (if benefits1.curr-code = ? then "" else string(benefits1.curr-code))
                + "|" +    (if benefits1.pay-name = ? then "" else string(benefits1.pay-name))
                + "|" +    (if benefits1.qnty = ? then "" else string(benefits1.qnty))
                + "|" +    (if v-curr-r-b = {&r-b-base}
                then (if benefits1.tot-base = ? then "" else string(benefits1.tot-base))
                else (if benefits1.tot-rubl = ? then "" else string(benefits1.tot-rubl)))
                ).
            end.
          when {&v-all} then 
            do:
              Report:table-row(  ""
                + "|" +    ""
                + "|" +    ""
                + "|" +    (if benefits1.pay-code = ? then "" else string(benefits1.pay-code))
                + "|" +    (if benefits1.curr-code = ? then "" else string(benefits1.curr-code))
                + "|" +    (if benefits1.pay-name = ? then "" else string(benefits1.pay-name))
                + "|" +    (if benefits1.qnty = ? then "" else string(benefits1.qnty))
                + "|" +    ""
                + "|" +    (if benefits1.tot-base = ? then "" else string(benefits1.tot-base))
                + "|" +    (if benefits1.tot-rubl = ? then "" else string(benefits1.tot-rubl))
                ).

            end.
        END CASE .
      end. /*if benefits.is-real-top <> 0 then do:*/
    END. 
  
    IF LAST-OF(benefits1.b-code) then 
    do:
      if benefits1.is-real-top <> 0 then
      do:
        CASE my-set_val_type :
          when {&v-base} then
            do:
              Report:table-subtotal(  ""
                + "|" +    ""
                + "|" +    ""
                + "|" +    ""
                + "|" +    ""
                + "|" +    "Итого"
                + "|" +    string(total-qnty)
                + "|" +    if v-curr-r-b = {&r-b-base}
                then string(total-tot-base)
                else string(total-tot-rubl)
                ).
            end.
          when {&v-all} then
            do:
              Report:table-subtotal(  ""
                + "|" +    ""
                + "|" +    ""
                + "|" +    ""
                + "|" +    ""
                + "|" +    "Итого"
                + "|" +    if total-qnty = ? then "" else (string(total-qnty))
                + "|" +    ""
                + "|" +    if total-tot-base = ? then "" else string(total-tot-base)
                + "|" +    if total-tot-rubl = ? then "" else string(total-tot-rubl)
                ).
            end.
        END CASE .
      end.
    end.

    IF LAST(benefits1.b-code) then 
    do:
      FOR EACH pays No-LOCK
        BREAK
        BY PAYS.PAY-CODE:
        CASE my-set_val_type :
          when {&v-base} then 
            do:
              Report:table-row(  ""
                + "|" +    ""
                + "|" +    (IF FIRST(pays.pay-code) then "Всего по методам платежа"  else "")
                + "|" +    string(pays.pay-code)
                + "|" +    string(pays.curr-code)
                + "|" +    string(pays.pay-name)
                + "|" +    string(pays.qnty)
                + "|" +   (if v-curr-r-b = {&r-b-base}
                then string(pays.tot-base)
                else string(pays.tot-rubl) )
                ).
            end.
          when {&v-all} then 
            do:
        Report:table-row(  ""
                + "|" +    ""
                + "|" +    (IF FIRST(pays.pay-code) then "Всего по методам платежа "  else " ")
                + "|" +    string(pays.pay-code)
                + "|" +    string(pays.curr-code)
                + "|" +    string(pays.pay-name)
                + "|" +    string(pays.qnty)
                + "|" +    ""
                + "|" +    (if (pays.tot-base) = ? then "" else string(pays.tot-base))
                + "|" +    (if (pays.tot-rubl) = ? then "" else string(pays.tot-rubl))
        ).
            end.
        END CASE .
      END.

      CASE my-set_val_type :
        when {&v-base} then 
          do:
            Report:table-total(    ""
              + "|" +    ""
              + "|" +    "Всего продано топлива"
              + "|" +    ""
              + "|" +    ""
              + "|" +    ""
              + "|" +    string(total-qnty1)
              + "|" +    if v-curr-r-b = {&r-b-base}
              then string(total-tot-base1)
              else string(total-tot-rubl1)
              ).
            v-mode = "yestotal":U.
          end.
        when {&v-all} then 
          do:
            Report:table-total(  ""
              + "|" +    ""
              + "|" +    "Всего продано топлива"
              + "|" +    ""
              + "|" +    ""
              + "|" +    ""
              + "|" +    if total-qnty1 = ? then "" else (string(total-qnty1))
              + "|" +    ""
              + "|" +    if total-tot-base1 = ? then "" else string(total-tot-base1)
              + "|" +    if total-tot-rubl1 = ? then "" else string(total-tot-rubl1)
              ).
            v-mode = "yestotal":U.
          end.
      END CASE .
    END. 
        
    
  END.

  if v-mode = "nototal":U and my-set_val_type = {&v-base}  then 
  do:
    Report:table-total(  ""
      + "|" +    ""
      + "|" +    "Всего продано топлива"
      + "|" +    ""
      + "|" +    ""
      + "|" +    ""
      + "|" +    ""
      + "|" +    ""
      ).
  end.   

  if v-mode = "nototal":U and my-set_val_type = {&v-all}  then 
  do:
    Report:table-total(  ""
      + "|" +    ""
      + "|" +    "Всего продано топлива"
      + "|" +    ""
      + "|" +    ""
      + "|" +    ""
      + "|" +    ""
      + "|" +    ""
      + "|" +    ""
      + "|" +    ""
      ).
  end.   

  Report:worksheet-footer("start").
  Report:worksheet-footer("").
  Report:worksheet-footer("Директор _______________        Старший продавец ______________"  ).
  Report:worksheet-footer("").
  Report:worksheet-footer("").
  Report:worksheet-footer("Бухгалтер ______________         Кассир _________________________  ").
  Report:worksheet-footer("end").
  
  report:worksheet("end").
  delete object Report. 

  xslt-path = search("exe\template.xsl").
  rep-out-unit = new rep-out ().
  rep-out-unit:office(xml_tmp, xslt-path). 
        
END PROCEDURE.

procedure t-beneq.
  define var      sum-list          as character no-undo.
  define var      pay-code-list     as character no-undo.
  define var      curr-code-list    as character no-undo.
  define var      atr64-list        as character no-undo.
  define var      exch-list         as character no-undo.
  define var      for-sum           as decimal   no-undo.
  define var      b-sum             as decimal   no-undo.
  define var      dop-sum           as decimal   no-undo.
  define var      dop-sum2          as decimal   no-undo.
  define var      b-qnty            as decimal   no-undo.
  /*чек включает нетопливный товар*/
  define variable nottopgood        as logical   no-undo.
  define variable is-real-top       as logical   no-undo .
  /*сумма нетопливного товара*/
  define variable nottopsum         as decimal   no-undo.
  /*сумма нетопливных платежей*/
  define variable nottoppaysum      as decimal   no-undo.
  define variable nottoppaysum-rubl as decimal   no-undo.
  define variable nottoppaysum-base as decimal   no-undo.
  define variable nottoppayexch     as decimal   no-undo.
  define variable curr-b-code       like ub.bar-code.b-code no-undo.
  define variable curr-is-real-top  as integer   no-undo .
  define variable b-name            like ub.goods.gds-name no-undo.
  define variable b-price           as decimal   no-undo.
  define variable b-pricen          as decimal   no-undo.
  define variable b-code-list       as char      no-undo.
  define variable b-sum-list        as char      no-undo.
  define variable b-price-list      as char      no-undo.
  define variable b-pricen-list     as char      no-undo.
  define variable b-name-list       as char      no-undo.
  define variable b-qnty-list       as char      no-undo.
  define variable is-real-top-list  as character no-undo .
  define variable entry-num         as integer   no-undo.
  define variable ii                as integer   no-undo.
  define variable sign              as integer   no-undo .

  for each units no-lock where
    lookup( {&petrolium}, units.type) > 0,
    each buf_goods no-lock where
    buf_goods.unit-base = units.unit-name  , each bar-code no-lock where bar-code.gds-code  = buf_goods.gds-code and bar-code.stts_ = 0
    :
    for each obj-list where obj-list.obj-type = {&shop} no-lock :
      accumulate obj-list.obj-code ( count ) .
      /*НАДО УБЕДИТЬСЯ ЧТО ВСЕ РАЗМАЗАНО!!*/
      run rep/rpychk0.p ( input "r-shftc2"
        ,input obj-list.obj-type
        ,input obj-list.obj-code
        ,input ? /*p-date-from*/
        ,input ? /*p-date-to*/
        ,input X-date-start /*p-shift-date-from*/
        ,input X-date-end /*p-shift-date-to*/
        ,input 1 /*p-shift-num-start*/
        ,input 99 /*p-shift-num-end*/
        ,input ? /*p-inkas-code*/
        ) no-error.
      if error-status:error then 
      do:
        message error-status:get-message(1) view-as alert-box.
      end.
      if x-TOG-Shift then 
      do:
        for each buf_chk-gds-pay no-lock where buf_chk-gds-pay.b-code = bar-code.b-code  and
          buf_chk-gds-pay.obj-type = obj-list.obj-type and
          buf_chk-gds-pay.obj-code = obj-list.obj-code and
          (
          buf_chk-gds-pay.shift-date >= X-date-start and
          buf_chk-gds-pay.shift-date <= X-date-end) :
          if ((buf_chk-gds-pay.shift-date = x-date-Start and buf_chk-gds-pay.shift-num < X-shift-start) or
            (buf_chk-gds-pay.shift-date = x-date-End and  buf_chk-gds-pay.shift-num > X-shift-end) ) then next.

          run  fill-behefit.
        end.
      end.
      else 
      do:
        for each buf_chk-gds-pay no-lock where buf_chk-gds-pay.b-code = bar-code.b-code  and
          buf_chk-gds-pay.obj-type = obj-list.obj-type and
          buf_chk-gds-pay.obj-code = obj-list.obj-code and
          (
          buf_chk-gds-pay.chk-date >= X-date-start and
          buf_chk-gds-pay.chk-date <= X-date-end) :

          run  fill-behefit.
        end.
      end.    
      empty temp-table benefits1 .
      empty temp-table pays .
      for each benefits:
        find first benefits1 no-lock where
          benefits1.b-code = benefits.b-code
          and benefits1.pay-code = benefits.pay-code
          and benefits1.curr-code = benefits.curr-code
          no-error.
        if not available (benefits1) then 
        do:
          create benefits1 .
          buffer-copy benefits except benefits.date_ to benefits1 .
        end.
        else 
        do:
          assign
            benefits1.tot-base = benefits1.tot-base + benefits.tot-base
            benefits1.qnty     = benefits1.qnty +  benefits.qnty
            benefits1.tot-rubl = benefits1.tot-base.
          .
        end.   
        if benefits.is-real-top <> 0 then 
        do:
          FIND FIRST pays WHERE
            pays.pay-code = benefits.pay-code NO-ERROR.
          IF NOT AVAIL pays then 
          do:
            create pays.
            assign
              pays.pay-code = benefits.pay-code
              pays.pay-name = benefits.pay-name
              .
          end.
          assign
            pays.qnty     = pays.qnty  + benefits.qnty
            pays.tot-rubl = pays.tot-rubl  + benefits.tot-rubl
            pays.tot-base = pays.tot-base  + benefits.tot-base
            .
        end. 
      end.
    end. /*FOR EACH obj-list*/
  end.

end procedure.
procedure fill-behefit:
  case entry(1, buf_chk-gds-pay.line-type, {&delim-par}):
    when {&petrolium} then 
      do:
        find first benefits no-lock where
          benefits.b-code = bar-code.b-code
          and benefits.pay-code = buf_chk-gds-pay.pay-code
          and benefits.curr-code = buf_chk-gds-pay.curr-code
          and benefits.date_ = buf_chk-gds-pay.chk-date
          no-error.
        if not avail benefits then 
        do:
          create benefits.
          assign
            benefits.date_       = buf_chk-gds-pay.chk-date
            benefits.b-code      = bar-code.b-code
            benefits.pay-code    = buf_chk-gds-pay.pay-code
            benefits.curr-code   = buf_chk-gds-pay.curr-code
            benefits.gds-name    = buf_goods.gds-name
            benefits.tot-sum     = 0
            benefits.tot-base    = 0
            benefits.tot-rubl    = 0
            benefits.is-real-top = 1
            .
        end.

        assign
          benefits.tot-base = benefits.tot-base +
                                                        (if v-curr-r-b = {&r-b-base}

                                                        then buf_chk-gds-pay.tot-r-b
                                                        else (if  buf_chk-gds-pay.tot-r-b = 0
                                                              then 0
                                                              else buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate))
          benefits.qnty     = benefits.qnty +  buf_chk-gds-pay.eff-doc-qnty
          benefits.tot-rubl = benefits.tot-base.
        .
        FIND FIRST ub.cash-pay No-LOCK WHERE ub.cash-pay.cdpay-code = benefits.pay-code No-ERROR.
        IF AVAIL ub.cash-pay
          then 
        do:
          benefits.pay-name = ub.cash-pay.obj-name.
        end.
        else 
        do:
          if benefits.pay-code = 0 then 
          do:
            benefits.pay-name = "Нетопливные платежи".
          end.
          else 
          do:
            benefits.pay-name = "Неопознанный платеж".
          end.
        end.
      end.
  end.
       
end procedure.