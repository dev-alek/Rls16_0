/*

$Revision: 4811f69c0ae8, 2733, rls $
$Author: EShklyar $
$Date: Пт янв 22 14:36:30 2021 +0300 $
$Workfile: e-toppay1.p $
$Archive: rep/e-toppay1.p $

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
define variable vss-revision    as character no-undo init "$Revision: 4811f69c0ae8, 2733, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Пт янв 22 14:36:30 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: e-toppay1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/e-toppay1.p $":U .
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
  field qnty        as decimal format "->>>,>>>,>>9.999"
  field pay-code    like ub.cash-pay.cdpay-code
  field curr-code   like ub.cash-pay.curr-code
  field tot-sum     like ub.chk-pay.tot-sum
  field tot-base    like ub.chk-pay.tot-base
  field tot-rubl    like ub.chk-pay.tot-rubl
  field pay-desk    like ub.chk-doc.pay-desk
  field is-real-top as integer
  index pi is primary b-code   pay-code curr-code date_ ascending
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


define frame Benefit-Base
  sym1 column-label ":"format "X(1)"
/*  benefits.date_ column-label "Дата"*/
  benefits.b-code column-label "Код"
  benefits.gds-name column-label "Вид топлива" format "X(30)"
  benefits.pay-code column-label "  " format ">>9"
  benefits.curr-code column-label "Вал" format ">>9"
  for-pay-name column-label "Метод !платежа" format "X(20)"
  sym7 column-label ":" format "X(1)"
  benefits.qnty column-label "Литры"
  benefits.tot-base column-label "Сумма" format "->,>>>,>>>,>>>,>>9.99"
  sym8 column-label ":" format "X(1)"
  header  date_string at 5 format "X(35)"
  v-header-base-curr        format "X(20)" at 42
  "Страница " at 65 page-number( PrnLibStream )  at 75 format ">>9" skip
  Line format "X(114)" at 1
  with width {&DOS_CW_2} 
down stream-io use-text .


define frame Benefit-Tot
  sym1 column-label ":!:" format "X(1)"
/*  benefits.date_ column-label "Дата"*/
  benefits.b-code column-label "Код"
  benefits.gds-name column-label "Вид топлива" format "X(30)"
  benefits.pay-code column-label "  " format ">>9"
  benefits.curr-code column-label "Вал" format ">>9"
  for-pay-name column-label "Метод !платежа" format "X(20)"
  sym4 column-label ":!:" format "X(1)"
  benefits.qnty column-label "Литры"
  benefits.tot-sum column-label "Сумма!в валюте" format "->>>>,>>>,>>>,>>9.99"
  sym6 column-label ":!:" format "X(1)"
  benefits.tot-base column-label "Сумма!в Б.Вал."
  format "->>>>>,>>>,>>9.99"
  sym7 column-label ":!:" format "X(1)"
  benefits.tot-rubl column-label "Сумма!в {&abbr_rublyah}" format "->>>>,>>>,>>>,>>9.99"
  sym8 column-label ":!:" format "X(1)"
  header  date_string at 5 format "X(35)"
  string( "( Б.Вал. - " + caps( trim( base-type ) ) + " )" ) format "X(20)" at 42
  "Страница " at 115 page-number( PrnLibStream ) at 125 format ">>9" skip
  Line format "X(143)" at 1
  with width {&DOS_CW_2} 
down stream-io use-text .

define frame Pay-Base
  sym1 column-label ":"format "X(1)"
  benefits.pay-code column-label "  " format ">>9"
  benefits.curr-code column-label "Вал" format ">>9"
  for-pay-name column-label "Метод !платежа" format "X(20)"
  benefits.b-code column-label "Код"
  benefits.gds-name column-label "Вид топлива" format "X(30)"
  sym7 column-label ":" format "X(1)"
  benefits.qnty column-label "Литры"
  benefits.tot-base column-label "Сумма" format "->,>>>,>>>,>>>,>>9.99"
  sym8 column-label ":" format "X(1)"
  header  date_string at 5 format "X(35)"
  v-header-base-curr        format "X(20)" at 42
  "Страница " at 65 page-number( PrnLibStream )  at 75 format ">>9" skip
  Line format "X(114)" at 1
  with width {&DOS_CW_2} 
down stream-io use-text .


define frame Pay-Tot
  sym1 column-label ":!:" format "X(1)"
  benefits.pay-code column-label "  " format ">>9"
  benefits.curr-code column-label "Вал" format ">>9"
  for-pay-name column-label "Метод !платежа" format "X(20)"
  benefits.b-code column-label "Код"
  benefits.gds-name column-label "Вид топлива" format "X(30)"
  sym4 column-label ":!:" format "X(1)"
  benefits.qnty column-label "Литры"
  benefits.tot-sum column-label "Сумма!в валюте" format "->>>>,>>>,>>>,>>9.99"
  sym6 column-label ":!:" format "X(1)"
  benefits.tot-base column-label "Сумма!в Б.Вал."
  format "->>>>>,>>>,>>9.99"
  sym7 column-label ":!:" format "X(1)"
  benefits.tot-rubl column-label "Сумма!в {&abbr_rublyah}" format "->>>>,>>>,>>>,>>9.99"
  sym8 column-label ":!:" format "X(1)"
  header  date_string at 5 format "X(35)"
  string( "(Б.Вал. - " + caps( trim( base-type ) ) + ")" ) format "X(20)" at 42
  "Страница " at 115 page-number( PrnLibStream ) at 125 format ">>9" skip
  Line format "X(143)" at 1
  with width {&DOS_CW_2} 
down stream-io use-text .

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
  if method = "b-code":U then run Proc-b-code-excel.
  else run Proc-pay-code-excel.

/*run Proc-pay-code-excel.*/


/*
assign
g#rep-tblname = ""
g#rep-tblrid = -101
g#rep-updflds = string( (if method = "b-code":U
                                      then 'Продажи топлива по видам оплаты'
                                      else 'Топливные платежи по видам топлива')
                                      + str1) .
*/

/* ВРЕМЕННО, ПОКА НЕ УДАСТСЯ СДЕЛАТЬ ОТЧЁТ ШТАТНО - комментирую запуск окон печати. Сейчас выводим отчёт напрямую в excel из окна s-object.w ТН-3085 2014г Шутилов. А. */
/*run prn-lib-prn-file in this-procedure (                 */
/*                                          input my-handle*/
/*                                          ,input 0       */
/*                                          ).             */


end procedure.


procedure Proc-b-code:

  run waitfram-hide in this-procedure .
  run prn-lib-open-stream  in this-procedure (
    input my-handle
    ,input {&LS_PS_A4}
    ,input yes /*p-is-stream*/
    ,input no /*p-append*/
    ).


  form header
    Line format "X(114)" at 1 skip
    "Продолжение - на следующей странице" at 30 skip
    with frame BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
  view stream PrnLibStream frame BottomFrame .

  find first ub.clients no-lock where ub.clients.obj-type = v-cntxt-obj-type
    and ub.clients.obj-code = v-cntxt-obj-code no-error.

  put stream PrnLibStream space(5)  "ОТЧЕТ  ПО  ВИДАМ ТОПЛИВА С РАЗБИВКОЙ ПО ТИПАМ ОПЛАТЫ" skip(1).
  put stream PrnLibStream unformatted str4 skip(0).
  put stream PrnLibStream str1  format "X(120)" skip(1)
    space(5) (
    if NotInc then
    "(сформирован по ВСЕМ ЧЕКАМ " + (if cas-num = 0 then "ВСЕХ КАСС" else
    ("КАССЫ " + string(cas-num))) + ", включая невошедшие в отчеты о продажах)"
    else
    "(сформирован по ВСЕМ ЧЕКАМ " + (if cas-num = 0 then "ВСЕХ КАСС" else
    ("КАССЫ " + string(cas-num))) + ")"
    )
    format "x(80)" skip
    .
  case my-set_val_type :
    when {&v-base} then
      form with frame Benefit-Base.
    when {&v-all} then
      form with frame Benefit-Tot.
  end case .
  _benefits:
  for each benefits
    break
    by benefits.b-code
    by benefits.pay-code :
    if benefits.is-real-top <> 0 then 
    do:
      accumulate
        benefits.qnty (total by benefits.b-code)
    benefits.tot-base (total BY benefits.b-code)
    benefits.tot-rubl (total BY benefits.b-code).
      find first ub.cash-pay no-lock where ub.cash-pay.cdpay-code = benefits.pay-code no-error.
      if avail ub.cash-pay
        then 
      do:
        for-pay-name = ub.cash-pay.obj-name.
      end.
      else 
      do:
        if benefits.pay-code = 0 then 
        do:
          for-pay-name = "Нетопливные платежи".
        end.
        else 
        do:
          for-pay-name = "Неопознанный платеж".
        end.
      end.
      find first pays where
        pays.pay-code = benefits.pay-code no-error.
      if not avail pays then 
      do:
        create pays.
        assign
          pays.pay-code = benefits.pay-code
          pays.pay-name = for-pay-name
          .
      end.
      assign
        pays.qnty     = pays.qnty  + benefits.qnty
        pays.tot-rubl = pays.tot-rubl  + benefits.tot-rubl
        pays.tot-base = pays.tot-base  + benefits.tot-base
        .
    end.
    if first-of(benefits.b-code) then 
    do:
      if benefits.is-real-top <> 0 then 
      do:
        case my-set_val_type :
          when {&v-base} then 
            do:
              display stream PrnLibStream
                benefits.b-code
                benefits.gds-name
                benefits.pay-code
                benefits.curr-code
                for-pay-name
                benefits.qnty
                (if v-curr-r-b = {&r-b-base}
                then benefits.tot-base
                else benefits.tot-rubl) @  benefits.tot-base
                sym1
                sym6
                sym7
                with frame Benefit-Base .
              down stream PrnLibStream 1 with frame Benefit-Base .
            end.
          when {&v-all} then 
            do:
              display stream PrnLibStream
                benefits.b-code
                benefits.gds-name
                benefits.pay-code
                benefits.curr-code
                for-pay-name
                benefits.qnty
                benefits.tot-rubl
                benefits.tot-base
                sym1
                sym6
                sym7
                with frame Benefit-Tot .
              down stream PrnLibStream 1 with frame Benefit-Tot .
            end.
        end case .
      end. /*if benefits.is-real-top <> 0 then do:*/
    end.
    else 
    do:
      if benefits.is-real-top <> 0 then 
      do:
        case my-set_val_type :
          when {&v-base} then 
            do:
              display stream PrnLibStream
                " " @ benefits.b-code
                " " @ benefits.gds-name
                benefits.pay-code
                benefits.curr-code
                for-pay-name
                benefits.qnty
                (if v-curr-r-b = {&r-b-base}
                then benefits.tot-base
                else benefits.tot-rubl) @  benefits.tot-base
                sym1
                sym6
                sym7
                with frame Benefit-Base .
              down stream PrnLibStream 1 with frame Benefit-Base .
            end.
          when {&v-all} then 
            do:
              display stream PrnLibStream
                " " @ benefits.b-code
                " " @ benefits.gds-name
                benefits.pay-code
                benefits.curr-code
                for-pay-name
                benefits.qnty
                benefits.tot-rubl
                benefits.tot-base
                sym1
                sym6
                sym7
                with frame Benefit-Tot .
              down stream PrnLibStream 1 with frame Benefit-Tot .
            end.
        end case .
      end. /*if benefits.is-real-top <> 0 then do:*/
    end.
    if last-of(benefits.b-code) then 
    do:
      if benefits.is-real-top <> 0 then 
      do:
        case my-set_val_type :
          when {&v-base} then 
            do:
              display stream PrnLibStream
                " " @ benefits.b-code
                " " @ benefits.gds-name
                " " @ benefits.pay-code
                "   " @ benefits.curr-code
                "            Итого" @ for-pay-name
                accum total by benefits.b-code benefits.qnty @ benefits.qnty
          (if v-curr-r-b = {&r-b-base}
          then  ACCUM total BY benefits.b-code benefits.tot-base
          else  ACCUM total BY benefits.b-code benefits.tot-rubl)  @ benefits.tot-base
          with frame Benefit-Base .
              down stream PrnLibStream 1 with frame Benefit-Base .
              underline stream PrnLibStream
                benefits.b-code
                benefits.gds-name
                benefits.pay-code
                benefits.curr-code
                for-pay-name
                benefits.qnty
                benefits.tot-base
                with frame Benefit-Base .
            end.
          when {&v-all} then 
            do:
              display stream PrnLibStream
                " " @ benefits.b-code
                " " @ benefits.gds-name
                " " @ benefits.pay-code
                "   " @ benefits.curr-code
                "            Итого" @ for-pay-name
                accum total by benefits.b-code benefits.qnty  @ benefits.qnty
                accum total by benefits.b-code benefits.tot-rubl @ benefits.tot-rubl
                accum total by benefits.b-code benefits.tot-base @ benefits.tot-base
                with frame Benefit-Tot .
              down stream PrnLibStream 1 with frame Benefit-Tot .
              underline stream PrnLibStream
                benefits.b-code
                benefits.gds-name
                benefits.pay-code
                benefits.curr-code
                for-pay-name
                benefits.qnty
                benefits.tot-rubl
                benefits.tot-base
                with frame Benefit-Tot .
            end.
        end case .
      end. /*if benefits.is-real-top <> 0 then do:*/
    end.
    if last(benefits.b-code) then 
    do:
      for each pays no-lock
        break
        by PAYS.PAY-CODE:
        case my-set_val_type :
          when {&v-base} then 
            do:
              display stream PrnLibStream
                " " @ benefits.b-code
                if first(pays.pay-code) then "Всего по методам платежа "  else " "
                @ benefits.gds-name
                pays.pay-code @ benefits.pay-code
                pays.curr-code @ benefits.curr-code
                pays.pay-name @ for-pay-name
                pays.qnty @ benefits.qnty
          (if v-curr-r-b = {&r-b-base}
          then pays.tot-base
          else pays.tot-rubl ) @ benefits.tot-base
          with frame Benefit-Base .
              down stream PrnLibStream 1 with frame Benefit-Base .
              if last( pays.pay-code) then
                underline stream PrnLibStream
                  benefits.b-code
                  benefits.gds-name
                  benefits.pay-code
                  benefits.curr-code
                  for-pay-name
                  benefits.qnty
                  benefits.tot-base
                  with frame Benefit-Base .
            end.
          when {&v-all} then 
            do:
              display stream PrnLibStream
                " " @ benefits.b-code
                if first(pays.pay-code) then "Всего по методам платежа "  else " "
                @ benefits.gds-name
                pays.pay-code @ benefits.pay-code
                pays.curr-code @ benefits.curr-code
                pays.pay-name @ for-pay-name
                pays.qnty @ benefits.qnty
                pays.tot-rubl @ benefits.tot-rubl
                pays.tot-base @ benefits.tot-base
                with frame Benefit-Tot .
              down stream PrnLibStream 1 with frame Benefit-Tot .
              if last( pays.pay-code) then
                underline stream PrnLibStream
                  benefits.b-code
                  benefits.gds-name
                  benefits.pay-code
                  benefits.curr-code
                  for-pay-name
                  benefits.qnty
                  benefits.tot-rubl
                  benefits.tot-base
                  with frame Benefit-Tot .
            end.
        end case .
      end.

      case my-set_val_type :
        when {&v-base} then 
          do:
            display stream PrnLibStream
              " " @ benefits.b-code
              "ВСЕГО ПРОДАНО ТОПЛИВА" @ benefits.gds-name
              " "  @ for-pay-name
              accum total benefits.qnty @ benefits.qnty
        (if v-curr-r-b = {&r-b-base}
        then  ACCUM TOTAL benefits.tot-base
        else  ACCUM TOTAL benefits.tot-rubl) @ benefits.tot-base
        with frame Benefit-Base .
            down stream PrnLibStream 1 with frame Benefit-Base .
          end.
        when {&v-all} then 
          do:
            display stream PrnLibStream
              " " @ benefits.b-code
              "ВСЕГО ПРОДАНО ТОПЛИВА" @ benefits.gds-name
              " "  @ for-pay-name
              accum total benefits.qnty @ benefits.qnty
              accum total benefits.tot-rubl @ benefits.tot-rubl
              accum total benefits.tot-base @ benefits.tot-base
              with frame Benefit-Tot .
            down stream PrnLibStream 1 with frame Benefit-Tot .
          end.
      end case .
    end.
  end.

  if  my-set_val_type = {&v-all} then
    put stream PrnLibStream Line format "X(147)" skip(1) .
  else
    put stream PrnLibStream Line format "X(114)" skip(1) .

  if can-find(first bad-chk) then 
  do:
    for each bad-chk no-lock:
      if length(bad-chk-str) + length(bad-chk.doc-code + {&space-char} +
        "погрешн." +  {&space-char} + string(bad-chk.delta) + {&new-line}) > 31900 then 
      do:
        bad-chk-str = bad-chk-str + " .....".
        leave.
      end.
      assign
        bad-chk-str = bad-chk-str + bad-chk.doc-code + {&space-char} +
                  "погрешность" +  {&space-char} + string(bad-chk.delta) + {&new-line}
        .
    end.
    run gbl/d-prompt.w (
      'title="Чеки, в которых топливными платежами оплачены нетопливные товары (в отчет не вошли):"\'
      + 'type=editor\'
      + 'fillin_width=96\'
      + 'fillin_height=15\'
      + 'readonly=yes\'
      , input-output bad-chk-str ).
  /*          if return-value = 'false':u then do:*/
  /*            return error.*/
  /*          end.*/
  end.

  if ( line-counter( PrnLibStream ) + 9 ) > page-size( PrnLibStream ) then  page .

  put stream PrnLibStream
    space(10)
    "Директор _______________" format "X(30)"
    "Старший продавец ______________" format "X(30)" skip(2)
    space(10)
    "Бухгалтер ______________" format "X(30)"
    "Кассир ________________________" format "X(30)" skip .

  hide stream PrnLibStream frame BottomFrame.

  output stream PrnLibStream CLOSE.



end procedure .

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

  Report:worksheet-header("Только итоги").

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
        Report:table-columns("60,125,30,30,120,70,70").    /* Начало таблицы, задаем размеры колонок */
        Report:table-types = "String,String,String,String,String,Qnty,Number".   /* Типы данных в таблице */
        Report:table-header("Код|Вид топлива|Вид опл.|Вал|Метод платежа|Литры|Сумма","40","9").    /* Шапка таблицы */     
      end.
        
    when {&v-all} then 
      do:
        Report:table-columns("60,125,30,30,120,70,70,70,70").    /* Начало таблицы, задаем размеры колонок */
        Report:table-types = "String,String,String,String,String,Qnty,String,Number,Number".   /* Типы данных в таблице */
        Report:table-header("Код|Вид топлива|Вид опл.|Вал|Метод платежа|Литры|Сумма в валюте|Сумма в Баз. валюте|Сумма в рублях","40","9").    /* Шапка таблицы */ 
      end.            
  END CASE .

    output to c:\temp\1.txt.
    for each benefits:
      export benefits.
    end.  
    output close.
  FOR EACH benefits
    BREAk
    BY benefits.b-code
    BY benefits.pay-code  :
    if benefits.is-real-top <> 0 then 
    do:
      ACCUMULATE
        benefits.qnty (total BY benefits.b-code)
    benefits.tot-base (total BY benefits.b-code)
    benefits.tot-rubl (total BY benefits.b-code).
      FIND FIRST ub.cash-pay No-LOCK WHERE ub.cash-pay.cdpay-code = benefits.pay-code No-ERROR.
      IF AVAIL ub.cash-pay
        then 
      do:
        for-pay-name = ub.cash-pay.obj-name.
      end.
      else 
      do:
        if benefits.pay-code = 0 then 
        do:
          for-pay-name = "Нетопливные платежи".
        end.
        else 
        do:
          for-pay-name = "Неопознанный платеж".
        end.
      end.
      FIND FIRST pays WHERE
        pays.pay-code = benefits.pay-code NO-ERROR.
      IF NOT AVAIL pays then 
      do:
        create pays.
        assign
          pays.pay-code = benefits.pay-code
          pays.pay-name = for-pay-name
          .
      end.
      assign
        pays.qnty     = pays.qnty  + benefits.qnty
        pays.tot-rubl = pays.tot-rubl  + benefits.tot-rubl
        pays.tot-base = pays.tot-base  + benefits.tot-base
        .
    end.
    IF FIRST-OF(benefits.b-code) then 
    do:
      if benefits.is-real-top <> 0 then 
      do:
        CASE my-set_val_type :
          when {&v-base} then 
            do:
              Report:table-row(  (if benefits.b-code = ? then "" else string(benefits.b-code, "999999999"))
                + "|" +    (if benefits.gds-name = ? then "" else string(benefits.gds-name))
                + "|" +    (if benefits.pay-code = ? then "" else string(benefits.pay-code))
                + "|" +    (if benefits.curr-code = ? then "" else string(benefits.curr-code))
                + "|" +    (if for-pay-name = ? then "" else string(for-pay-name))
                + "|" +    (if benefits.qnty = ? then "" else string(benefits.qnty))
                + "|" +    (if v-curr-r-b = {&r-b-base}
                then (if benefits.tot-base = ? then "" else string(benefits.tot-base))
                else (if benefits.tot-rubl = ? then "" else string(benefits.tot-rubl)))
                ).
            end.
          when {&v-all} then 
            do:
              Report:table-row(  (if benefits.b-code = ? then "" else string(benefits.b-code, "999999999"))
                + "|" +    (if benefits.gds-name = ? then "" else string(benefits.gds-name))
                + "|" +    (if benefits.pay-code = ? then "" else string(benefits.pay-code))
                + "|" +    (if benefits.curr-code = ? then "" else string(benefits.curr-code))
                + "|" +    (if for-pay-name = ? then "" else string(for-pay-name))
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
              Report:table-row(  ""
                
                + "|" +    ""
                + "|" +    (if benefits.pay-code = ? then "" else string(benefits.pay-code))
                + "|" +    (if benefits.curr-code = ? then "" else string(benefits.curr-code))
                + "|" +    (if for-pay-name = ? then "" else string(for-pay-name))
                + "|" +    (if benefits.qnty = ? then "" else string(benefits.qnty))
                + "|" +    (if v-curr-r-b = {&r-b-base}
                then (if benefits.tot-base = ? then "" else string(benefits.tot-base))
                else (if benefits.tot-rubl = ? then "" else string(benefits.tot-rubl)))
                ).
            end.
          when {&v-all} then 
            do:
              Report:table-row(  ""
                
                + "|" +    ""
                + "|" +    (if benefits.pay-code = ? then "" else string(benefits.pay-code))
                + "|" +    (if benefits.curr-code = ? then "" else string(benefits.curr-code))
                + "|" +    (if for-pay-name = ? then "" else string(for-pay-name))
                + "|" +    (if benefits.qnty = ? then "" else string(benefits.qnty))
                + "|" +    ""
                + "|" +    (if benefits.tot-base = ? then "" else string(benefits.tot-base))
                + "|" +    (if benefits.tot-rubl = ? then "" else string(benefits.tot-rubl))
                ).

            end.
        END CASE .
      end. /*if benefits.is-real-top <> 0 then do:*/
    END. 
  
    IF LAST-OF(benefits.b-code) then 
    do:
      if benefits.is-real-top <> 0 then 
      do:
        CASE my-set_val_type :
          when {&v-base} then 
            do:
        Report:table-subtotal(  ""
                
                + "|" +    ""
                + "|" +    ""
                + "|" +    ""
                + "|" +    "Итого"
                + "|" +    string(ACCUM total BY benefits.b-code benefits.qnty)
                + "|" +    (if v-curr-r-b = {&r-b-base}
                            then (if (ACCUM total BY benefits.b-code benefits.tot-base) = ? then "" else string(ACCUM total BY benefits.b-code benefits.tot-base))
                            else (if (ACCUM total BY benefits.b-code benefits.tot-rubl) = ? then "" else string(ACCUM total BY benefits.b-code benefits.tot-rubl)))
        ).
            end.
          when {&v-all} then 
            do:
        Report:table-subtotal(  ""
                + "|" +    ""
                
                + "|" +    ""
                + "|" +    ""
                + "|" +    "Итого"
                + "|" +    (if (ACCUM total BY benefits.b-code benefits.qnty) = ? then "" else (string(ACCUM total BY benefits.b-code benefits.qnty)))
                + "|" +    ""
                + "|" +    (if (ACCUM total BY benefits.b-code benefits.tot-base) = ? then "" else string(ACCUM total BY benefits.b-code benefits.tot-base))
                + "|" +    (if (ACCUM total BY benefits.b-code benefits.tot-rubl) = ? then "" else string(ACCUM total BY benefits.b-code benefits.tot-rubl))
          ).
            end.
        END CASE .
      end.
    end.

    IF LAST(benefits.b-code) then 
    do:
      FOR EACH pays No-LOCK
        BREAK
        BY PAYS.PAY-CODE:
        CASE my-set_val_type :
          when {&v-base} then 
            do:
              Report:table-row(  ""
                
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
                
                + "|" +    "Всего продано топлива"
                + "|" +    ""
                + "|" +    ""
                + "|" +    ""
                + "|" +    (if (ACCUM TOTAL benefits.qnty) = ? then "" else string(ACCUM TOTAL benefits.qnty))
                + "|" +    (if v-curr-r-b = {&r-b-base}
                            then  string(ACCUM TOTAL benefits.tot-base)
                            else  string(ACCUM TOTAL benefits.tot-rubl))
         ).
            v-mode = "yestotal":U.
          end.
        when {&v-all} then 
          do:
         Report:table-total(  ""
                
                + "|" +    "Всего продано топлива"
                + "|" +    ""
                + "|" +    ""
                + "|" +    ""
                + "|" +    (if (ACCUM TOTAL benefits.qnty) = ? then "" else string(ACCUM TOTAL benefits.qnty))
                + "|" +    ""
                + "|" +    (if (ACCUM TOTAL benefits.tot-base) = ? then "" else string(ACCUM TOTAL benefits.tot-base))
                + "|" +    (if (ACCUM TOTAL benefits.tot-rubl) = ? then "" else string(ACCUM TOTAL benefits.tot-rubl))
         ).
            v-mode = "yestotal":U.
          end.
      END CASE .
    END. 
        
    
  END.

  if v-mode = "nototal":U and my-set_val_type = {&v-base}  then 
  do:
    Report:table-total(  ""
      
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


PROCEDURE Proc-pay-code:

  run waitfram-hide in this-procedure .
  run prn-lib-open-stream  in this-procedure (
    input my-handle
    ,input {&LS_PS_A4}
    ,input yes /*p-is-stream*/
    ,input no /*p-append*/
    ).


  form header
    Line format "X(114)" at 1 skip
    "Продолжение - на следующей странице" at 30 skip
    with frame BottomFrame1 width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
  view stream PrnLibStream frame BottomFrame1 .

  find first ub.clients no-lock where
    ub.clients.obj-type = v-cntxt-obj-type
    and  ub.clients.obj-code = v-cntxt-obj-code no-error.
  put stream PrnLibStream unformatted space(5)
    "ОТЧЕТ  ПО  ТИПАМ ОПЛАТ С РАЗБИВКОЙ ПО ВИДАМ ТОПЛИВА И ТОВАРАМ ТОПЛИВНОГО КОШЕЛЬКА" skip(1).
  put stream PrnLibStream unformatted str4 skip(0).
  put stream PrnLibStream str1  format "X(120)" skip(1)
    space(5) (
    if NotInc then
    "( сформирован по ВСЕМ ЧЕКАМ " + (if cas-num = 0 then "ВСЕХ КАСС" else
    ("КАССЫ " + string(cas-num))) + " , включая невошедшие в отчеты о продажах )"
    else
    "( сформирован по ВСЕМ ЧЕКАМ " + (if cas-num = 0 then "ВСЕХ КАСС" else
    ("КАССЫ " + string(cas-num) ) ) + ")"
    )
    format "x(80)" skip
    .
  case my-set_val_type :
    when {&v-base} then
      form with frame Pay-Base .
    when {&v-all} then
      form with frame Pay-Tot.
  end case .
  for each benefits break by benefits.pay-code by benefits.b-code  :
    accumulate
      benefits.qnty (total by benefits.pay-code)
        benefits.tot-base (total BY benefits.pay-code)
        benefits.tot-rubl (total BY benefits.pay-code).

    find first ub.cash-pay no-lock where ub.cash-pay.cdpay-code = benefits.pay-code no-error.
    if avail ub.cash-pay then for-pay-name = ub.cash-pay.obj-name.
    else if benefits.pay-code = 0
        then
        for-pay-name = "Нетопливные платежи".
      else
        for-pay-name = "Неопознанный платеж".
    find first pays where pays.pay-code = benefits.pay-code no-error.
    if not avail pays then 
    do:
      create b-codes.
      assign 
        b-codes.b-code   = benefits.b-code
        b-codes.gds-name = benefits.gds-name.
    end.
    assign
      b-codes.qnty     = b-codes.qnty  + benefits.qnty
      b-codes.tot-rubl = b-codes.tot-rubl  + benefits.tot-rubl
      b-codes.tot-base = b-codes.tot-base  + benefits.tot-base.

    if first-of(benefits.pay-code) then 
    do:
      case my-set_val_type :
        when {&v-base} then 
          do:
            display stream PrnLibStream
              benefits.b-code
              benefits.gds-name
              benefits.pay-code
              benefits.curr-code
              for-pay-name
              benefits.qnty
              (if v-curr-r-b = {&r-b-base}
              then  benefits.tot-base
              else benefits.tot-rubl
              ) @ benefits.tot-base
              sym1
              sym6
              sym7
              with frame Pay-Base .
            down stream PrnLibStream 1 with frame Pay-Base .
          end.
        when {&v-all} then 
          do:
            display stream PrnLibStream
              benefits.b-code
              benefits.gds-name
              benefits.pay-code
              benefits.curr-code
              for-pay-name
              benefits.qnty
              benefits.tot-rubl
              benefits.tot-base
              sym1
              sym6
              sym7
              with frame Pay-Tot .
            down stream PrnLibStream 1 with frame Pay-Tot .
          end.
      end case .
    end.
    else 
    do:
      case my-set_val_type :
        when {&v-base} then 
          do:
            display stream PrnLibStream
              benefits.b-code
              benefits.gds-name
              " " @ benefits.pay-code
              "   " @ benefits.curr-code
              " " @ for-pay-name
              benefits.qnty
              (if v-curr-r-b = {&r-b-base}
              then  benefits.tot-base
              else benefits.tot-rubl
              ) @ benefits.tot-base
              sym1
              sym6
              sym7
              with frame Pay-Base .
            down stream PrnLibStream 1 with frame Pay-Base .
          end.
        when {&v-all} then 
          do:
            display stream PrnLibStream
              benefits.b-code
              benefits.gds-name
              " " @ benefits.pay-code
              "   " @ benefits.curr-code
              " " @ for-pay-name
              benefits.qnty
              benefits.tot-rubl
              benefits.tot-base
              sym1
              sym6
              sym7
              with frame Pay-Tot .
            down stream PrnLibStream 1 with frame Pay-Tot .
          end.
      end case .
    end.
    if last-of(benefits.pay-code) then 
    do:
      case my-set_val_type :
        when {&v-base} then 
          do:
            display stream PrnLibStream
              " " @ benefits.b-code
              "            Итого" @ benefits.gds-name
              " " @ benefits.pay-code
              "   " @ benefits.curr-code
              " " @ for-pay-name
              accum total by benefits.pay-code benefits.qnty @ benefits.qnty
                        (if v-curr-r-b = {&r-b-base}
                        then ACCUM total BY benefits.pay-code benefits.tot-base
                        else ACCUM total BY benefits.pay-code benefits.tot-rubl) @ benefits.tot-base
                        with frame Pay-Base .
            down stream PrnLibStream 1 with frame Pay-Base .
            underline stream PrnLibStream
              benefits.b-code
              benefits.gds-name
              benefits.pay-code
              benefits.curr-code
              for-pay-name
              benefits.qnty
              benefits.tot-base
              with frame Pay-Base .
          end.
        when {&v-all} then 
          do:
            display stream PrnLibStream
              " " @ benefits.b-code
              "            Итого" @ benefits.gds-name
              " " @ benefits.pay-code
              "   " @ benefits.curr-code
              " " @ for-pay-name
              accum total by benefits.pay-code benefits.qnty  @ benefits.qnty
              accum total by benefits.pay-code benefits.tot-rubl @ benefits.tot-rubl
              accum total by benefits.pay-code benefits.tot-base @ benefits.tot-base
              with frame Pay-Tot .
            down stream PrnLibStream 1 with frame Pay-Tot .
            underline stream PrnLibStream
              benefits.b-code
              benefits.gds-name
              benefits.pay-code
              benefits.curr-code
              for-pay-name
              benefits.qnty
              benefits.tot-rubl
              benefits.tot-base
              with frame Pay-Tot .
          end.
      end case .
    end.
    if last(benefits.b-code) then 
    do:
      for each pays no-lock break by b-codes.b-code:
        case my-set_val_type :
          when {&v-base} then 
            do:
              display stream PrnLibStream
                b-codes.b-code @ benefits.b-code
                if first(b-codes.b-code) then "Всего по видам топлива "  else " "
                @ for-pay-name
                " " @ benefits.pay-code
                "   " @ benefits.curr-code
                b-codes.gds-name @ benefits.gds-name
                b-codes.qnty @ benefits.qnty
                            (if v-curr-r-b = {&r-b-base}
                            then b-codes.tot-base
                            else b-codes.tot-rubl) @ benefits.tot-base
                            with frame Pay-Base .
              down stream PrnLibStream 1 with frame Pay-Base .
              if last( b-codes.b-code) then
                underline stream PrnLibStream
                  benefits.b-code
                  benefits.gds-name
                  benefits.pay-code
                  benefits.curr-code
                  for-pay-name
                  benefits.qnty
                  benefits.tot-base
                  with frame Pay-Base .
            end.
          when {&v-all} then 
            do:
              display stream PrnLibStream
                b-codes.b-code @ benefits.b-code
                if first(b-codes.b-code) then "Всего по видам топлива "  else " "
                @ for-pay-name
                " " @ benefits.pay-code
                "   " @ benefits.curr-code
                b-codes.gds-name @ benefits.gds-name
                b-codes.qnty @ benefits.qnty
                b-codes.tot-rubl @ benefits.tot-rubl
                b-codes.tot-base @ benefits.tot-base
                with frame Pay-Tot .
              down stream PrnLibStream 1 with frame Pay-Tot .
              if last( b-codes.b-code) then
                underline stream PrnLibStream
                  benefits.b-code
                  benefits.gds-name
                  benefits.pay-code
                  benefits.curr-code
                  for-pay-name
                  benefits.qnty
                  benefits.tot-rubl
                  benefits.tot-base
                  with frame Pay-Tot .
            end.
        end case .
      end.

      case my-set_val_type :
        when {&v-base} then 
          do:
            display stream PrnLibStream
              " " @ benefits.b-code
              "ВСЕГО ПРОДАНО ТОПЛИВА" @ benefits.gds-name
              " "  @ for-pay-name
              accum total benefits.qnty @ benefits.qnty
                        (if v-curr-r-b = {&r-b-base}
                        then ACCUM TOTAL benefits.tot-base
                        else ACCUM TOTAL benefits.tot-rubl) @ benefits.tot-base
                        with frame Pay-Base .
            down stream PrnLibStream 1 with frame Pay-Base .
          end.
        when {&v-all} then 
          do:
            display stream PrnLibStream
              " " @ benefits.b-code
              "ВСЕГО ПРОДАНО ТОПЛИВА" @ benefits.gds-name
              " "  @ for-pay-name
              accum total benefits.qnty @ benefits.qnty
              accum total benefits.tot-rubl @ benefits.tot-rubl
              accum total benefits.tot-base @ benefits.tot-base
              with frame Pay-Tot .
            down stream PrnLibStream 1 with frame Pay-Tot .
          end.
      end case .
    end.
  end.


  if my-set_val_type = {&v-all} then
    put stream PrnLibStream Line format "X(147)" skip(1) .
  else
    put stream PrnLibStream Line format "X(114)" skip(1) .
  if can-find(first bad-chk) then 
  do:
    put stream PrnLibStream unformatted
      "Чеки, в которых топливными платежами оплачены нетопливные товары (в отчет не вошли):" skip.
    for each bad-chk no-lock:
      put stream PrnLibStream unformatted
        bad-chk.doc-code " ".
      accumulate bad-chk.doc-code(count).
      if (accum count bad-chk.doc-code) modulo 5 = 0 then
        put stream PrnLibStream skip.
    end.
    put stream PrnLibStream unformatted skip.
    if ( line-counter( PrnLibStream ) + 9  +
      (accum count bad-chk.doc-code) / 5 + (accum count bad-chk.doc-code) modulo 5  + 2
      ) > page-size( PrnLibStream ) then  page .

  end.
  else 
  do:
    if ( line-counter( PrnLibStream ) + 9 ) > page-size( PrnLibStream ) then  page .
  end.
  put stream PrnLibStream space(10) "Директор _______________" format "X(30)"
    "Старший продавец ______________" format "X(30)" skip(2)
    space(10) "Бухгалтер ______________" format "X(30)"
    "Кассир ________________________" format "X(30)" skip .

  hide stream PrnLibStream frame BottomFrame1 .

  output stream PrnLibStream CLOSE.

end procedure .

procedure Proc-pay-code-excel: /* Процедура вывода в Excel rep/g-paytop (Топливные платежи по видам топлива) */
  /* формируем xml */
  xml_tmp = string(session:temp-directory + "report-tmp3.xml"). /* путь к временному xml-файлу */
  Report = new ReportXml(xml_tmp).

  Report:worksheet("Лист 1").
  Report:worksheet-header("start"). /* Начало шапки отчета */
  Report:worksheet-header("     " + "Отчёт по типам оплат с разбивкой по видам топлива и товарам топливного кошелька").
  Report:worksheet-header("").
  Report:worksheet-header(if length(str4) > 100 then substring(str4, 1, 100) + "..." else str4).
  Report:worksheet-header("").
  Report:worksheet-header("     " + str1).
  Report:worksheet-header("     " + if NotInc then "(сформирован по ВСЕМ ЧЕКАМ " + (if cas-num = 0 then "ВСЕХ КАСС" else ("КАССЫ " + string(cas-num))) + ", включая невошедшие в отчеты о продажах)"
  else "(сформирован по ВСЕМ ЧЕКАМ " + (if cas-num = 0 then "ВСЕХ КАСС)" else ("КАССЫ " + string(cas-num)) + ")" )).
  Report:worksheet-header("").
  case my-set_val_type:
    when {&v-base} then
      do:
        Report:worksheet-header("     " + date_string + (if v-header-base-curr <> "" then "," + " " + string(v-header-base-curr) else "")).
      end.
    when {&v-all} then
      do:
        Report:worksheet-header("     " + date_string + "," + " " + string("(Б.Вал. - " + caps(trim(base-type)) + ")")).
      end.
  end case.
  Report:worksheet-header("end").

  /*Конец шапки отчета*/

  case my-set_val_type:
    when {&v-base} then
      do:
        Report:table-columns("40,40,145,80,160,90,104").    /* Начало таблицы, задаем размеры колонок */
        Report:table-types = "String,String,String,String,String,Qnty,Number".   /* Типы данных в таблице */
        Report:table-header("Вид опл.|Вал|Метод платежа|Код|Вид топлива|Литры|Сумма","40","9").    /* Шапка таблицы */
      end.
    when {&v-all} then
      do:
        Report:table-columns("40,40,145,80,160,90,104,104").    /* Начало таблицы, задаем размеры колонок */
        Report:table-types = "String,String,String,String,String,Qnty,Number,Number".   /* Типы данных в таблице */
        Report:table-header("Вид опл.|Вал|Метод платежа|Код|Вид топлива|Литры|Сумма в валюте|Сумма в рублях","50","9").    /* Шапка таблицы */
      end.
  end case.

  for each benefits break by benefits.pay-code by benefits.b-code:
    accumulate
      benefits.qnty (total by benefits.pay-code)
            benefits.tot-base (total by benefits.pay-code)
            benefits.tot-rubl (total by benefits.pay-code)
      .

    find first ub.cash-pay no-lock where ub.cash-pay.cdpay-code = benefits.pay-code no-error.
    if available ub.cash-pay then for-pay-name = ub.cash-pay.obj-name.
    else
    do:
      if benefits.pay-code = 0 then for-pay-name = "Нетопливные платежи".
      else for-pay-name = "Неопознанный платеж".
    end.
                
    find first pays where pays.pay-code = benefits.pay-code no-error.
    if not avail pays then
    do:
      create b-codes.
      assign
        b-codes.b-code   = benefits.b-code
        b-codes.gds-name = benefits.gds-name
        .
    end.
    assign
      b-codes.qnty     = b-codes.qnty + benefits.qnty
      b-codes.tot-rubl = b-codes.tot-rubl + benefits.tot-rubl
      b-codes.tot-base = b-codes.tot-base + benefits.tot-base
      .

    if first-of(benefits.pay-code) then
    do:
      case my-set_val_type:
        when {&v-base} then
          do:
            Report:table-row(
              string(benefits.pay-code)
              + "|" + string(benefits.curr-code)
              + "|" + string(for-pay-name)
              + "|" + string(benefits.b-code, "999999999")
              + "|" + string(benefits.gds-name)
              + "|" + string(benefits.qnty)
              + "|" + (if v-curr-r-b = {&r-b-base} then string(benefits.tot-base) else string(benefits.tot-rubl))
              ).
          end.
        when {&v-all} then
          do:
            Report:table-row(
              string(benefits.pay-code)
              + "|" + string(benefits.curr-code)
              + "|" + string(for-pay-name)
              + "|" + string(benefits.b-code, "999999999")
              + "|" + string(benefits.gds-name)
              + "|" + string(benefits.qnty)
              + "|" + string(benefits.tot-rubl)
              + "|" + string(benefits.tot-base)
              ).
          end.
      end case.
    end.
    else
    do:
      case my-set_val_type :
        when {&v-base} then
          do:
            Report:table-row(
              ""
              + "|" + ""
              + "|" + ""
              + "|" + string(benefits.b-code, "999999999")
              + "|" + string(benefits.gds-name)
              + "|" + string(benefits.qnty)
              + "|" + (if v-curr-r-b = {&r-b-base} then string(benefits.tot-base) else string(benefits.tot-rubl))
              ).
          end.
        when {&v-all} then
          do:
            Report:table-row(
              ""
              + "|" + ""
              + "|" + ""
              + "|" + string(benefits.b-code, "999999999")
              + "|" + string(benefits.gds-name)
              + "|" + string(benefits.qnty)
              + "|" + string(benefits.tot-rubl)
              + "|" + string(benefits.tot-base)
              ).
          end.
      end case.
    end.
                
    if last-of(benefits.pay-code) then
    do:
      case my-set_val_type:
        when {&v-base} then
          do:
            Report:table-subtotal(
              ""
              + "|" + ""
              + "|" + ""
              + "|" + ""
              + "|" + "Итого:"
              + "|" + string(accum total by benefits.pay-code benefits.qnty)
              + "|" + string((if v-curr-r-b = {&r-b-base} then
              accum total by benefits.pay-code benefits.tot-base
              else accum total by benefits.pay-code benefits.tot-rubl))
              ).
          end.
        when {&v-all} then
          do:
            Report:table-subtotal(
              ""
              + "|" + ""
              + "|" + ""
              + "|" + ""
              + "|" + "Итого:"
              + "|" + string(accum total by benefits.pay-code benefits.qnty)
              + "|" + string(accum total by benefits.pay-code benefits.tot-rubl)
              + "|" + string(accum total by benefits.pay-code benefits.tot-base)
              ).
          end.
      end case.
    end.
    if last(benefits.b-code) then
    do:
      for each pays no-lock break by b-codes.b-code:
        case my-set_val_type:
          when {&v-base} then
            do:
              Report:table-row(
                ""
                + "|" + ""
                + "|" + string(if first(b-codes.b-code) then "Всего по видам топлива:" else "")
                + "|" + string(b-codes.b-code, "999999999")
                + "|" + string(b-codes.gds-name)
                + "|" + string(b-codes.qnty)
                + "|" + (if v-curr-r-b = {&r-b-base} then string(b-codes.tot-base)
                else string(b-codes.tot-rubl))
                ).
            end.
          when {&v-all} then
            do:
              Report:table-row(
                ""
                + "|" + ""
                + "|" + if first(b-codes.b-code) then "Всего по видам топлива " else ""
                + "|" + string(b-codes.b-code, "999999999")
                + "|" + string(b-codes.gds-name)
                + "|" + string(b-codes.qnty)
                + "|" + string(b-codes.tot-rubl)
                + "|" + string(b-codes.tot-base)
                ).
            end.
        end case.
      end. /* for each pays no-lock break by b-codes.b-code: */
        
      case my-set_val_type:
        when {&v-base} then
          do:
            Report:table-total(
              ""
              + "|" + ""
              + "|" + ""
              + "|" + ""
              + "|" + "ВСЕГО ПРОДАНО ТОПЛИВА:"
              + "|" + string(accum total benefits.qnty)
              + "|" + if v-curr-r-b = {&r-b-base} then string(accum total benefits.tot-base)
              else string(accum total benefits.tot-rubl)
              ).
            v-mode = "yestotal":U.
          end.
        when {&v-all} then
          do:
            Report:table-total(
              ""
              + "|" + ""
              + "|" + ""
              + "|" + ""
              + "|" + "ВСЕГО ПРОДАНО ТОПЛИВА:"
              + "|" + string(accum total benefits.qnty)
              + "|" + string(accum total benefits.tot-rubl)
              + "|" + string(accum total benefits.tot-base)
              ).
            v-mode = "yestotal":U.
          end.
      end case.
    end. /* if last(benefits.b-code) then */
  end.
            
  if v-mode = "nototal":U and my-set_val_type = {&v-base} then 
  do:
    Report:table-total(
      ""
      + "|" + ""
      + "|" + ""
      + "|" + ""
      + "|" + "ВСЕГО ПРОДАНО ТОПЛИВА:"
      + "|" + ""
      + "|" + ""
      ). 
  end.  
    
  if v-mode = "nototal":U and my-set_val_type = {&v-all} then 
  do:
    Report:table-total(
      ""
      + "|" + ""
      + "|" + ""
      + "|" + ""
      + "|" + "ВСЕГО ПРОДАНО ТОПЛИВА:"
      + "|" + ""
      + "|" + ""
      + "|" + ""
      ).
  end.    
               

  Report:worksheet-footer("start").
  Report:worksheet-footer("").
  Report:worksheet-footer("Директор _______________             Старший продавец ______________").
  Report:worksheet-footer("").
  Report:worksheet-footer("").
  Report:worksheet-footer("Бухгалтер _______________             Кассир _________________________").
  Report:worksheet-footer("end").


  Report:worksheet("end").
  delete object Report.

  do:
    xslt-path = search("exe\template.xsl").
    rep-out-unit = new rep-out ().
    rep-out-unit:office(xml_tmp, xslt-path).
  end.


end procedure. /* Proc-pay-code-excel */

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
    buf_goods.unit-base = units.unit-name  , each bar-code no-lock where bar-code.gds-code  = buf_goods.gds-code
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
   
      if method = "b-code" then 
      do:
          if x-TOG-Shift then do:
      for each buf_chk-gds-pay no-lock where buf_chk-gds-pay.b-code = bar-code.b-code  and
        buf_chk-gds-pay.obj-type = obj-list.obj-type and
        buf_chk-gds-pay.obj-code = obj-list.obj-code and
        (
        buf_chk-gds-pay.shift-date >= x-date-Start and
        buf_chk-gds-pay.shift-date <= x-date-End) :
          if ((buf_chk-gds-pay.shift-date = x-date-Start and buf_chk-gds-pay.shift-num < X-shift-start) or
            (buf_chk-gds-pay.shift-date = x-date-End and  buf_chk-gds-pay.shift-num > X-shift-end) ) then next.

        run  fill-behefit.
      end.
    end.
    else do:
      for each buf_chk-gds-pay no-lock where buf_chk-gds-pay.b-code = bar-code.b-code  and
        buf_chk-gds-pay.obj-type = obj-list.obj-type and
        buf_chk-gds-pay.obj-code = obj-list.obj-code and
        (
        buf_chk-gds-pay.chk-date >= X-date-start and
        buf_chk-gds-pay.chk-date <= X-date-end) :
/*        if X-radio-task = 3 and                                                                              */
/*          ((buf_chk-gds-pay.shift-date = X-date-start and buf_chk-gds-pay.shift-num < X-shift-start) or      */
/*          (buf_chk-gds-pay.shift-date = X-date-end and  buf_chk-gds-pay.shift-num > X-shift-end) ) then next.*/
/*        if X-radio-task = 4 and buf_chk-gds-pay.shift-num <> x-shift-alone then next.                        */

        run  fill-behefit.
      end.
    end.   
      end.  
      else 
      do:
        case (X-radio-task > 1)  :
          when yes then 
            do:
              for each buf_chk-gds-pay no-lock where buf_chk-gds-pay.b-code = bar-code.b-code  and
                buf_chk-gds-pay.obj-type = obj-list.obj-type and
                buf_chk-gds-pay.obj-code = obj-list.obj-code and
                (
                buf_chk-gds-pay.shift-date >= X-date-start and
                buf_chk-gds-pay.shift-date <= X-date-end) :
                if X-radio-task = 3 and
                  ((buf_chk-gds-pay.shift-date = X-date-start and buf_chk-gds-pay.shift-num < X-shift-start) or
                  (buf_chk-gds-pay.shift-date = X-date-end and  buf_chk-gds-pay.shift-num > X-shift-end) ) then next.
                if X-radio-task = 4 and buf_chk-gds-pay.shift-num <> x-shift-alone then next.

                run  fill-behefit.
              end.

            end.
          when no then 
            do:
              for each buf_chk-gds-pay no-lock where buf_chk-gds-pay.b-code = bar-code.b-code  and
                buf_chk-gds-pay.obj-type = obj-list.obj-type and
                buf_chk-gds-pay.obj-code = obj-list.obj-code and
                buf_chk-gds-pay.chk-date >= X-date-start and
                buf_chk-gds-pay.chk-date <= X-date-end :
                run  fill-behefit.
              end.

            end.
        end. /*CASE*/
      end.
    end. /*FOR EACH obj-list*/

  end.
/*
FOR EACH obj-list WHERE obj-list.obj-type = {&shop} NO-LOCK :
ACCUMULATE obj-list.obj-code ( COUNT ) .

CASE (X-radio-task > 1) :
WHEN YES THEN DO:
_chk-doc1:
FOR EACH ub.chk-doc WHERE
       ub.chk-doc.obj-type = obj-list.obj-type AND
     ub.chk-doc.obj-code = obj-list.obj-code AND
       (
       ub.chk-doc.shift-date >= X-date-start AND
       ub.chk-doc.shift-date <= X-date-end)
       AND
     (IF cas-num > 0 then ub.chk-doc.pay-desk = cas-num else TRUE)
     NO-LOCK use-index shift,
 EACH ub.chk-gds NO-LOCK WHERE
       ub.chk-doc.doc-code = ub.chk-gds.doc-code /*AND chk-gds.pump > 0*/
BREAK
BY ub.chk-doc.doc-code
BY ub.chk-gds.b-code:
if lookup(string(ub.chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc1.
IF X-radio-task = 3 AND
   ((chk-doc.shift-date = X-date-start AND chk-doc.shift-num < X-shift-start) OR
     (chk-doc.shift-date = X-date-end AND  chk-doc.shift-num > X-shift-end) ) THEN NEXT.
IF X-radio-task = 4 and chk-doc.shift-num <> x-shift-alone THEN NEXT.
assign
sign = if chk-doc.netto >=0 then 1 else - 1
.
{ rep/e-toppyq.i _chk-doc1}
END. /*FOR EACH chk-doc*/
END. /*WHEN YES*/
WHEN NO THEN DO:
_chk-doc2:
FOR EACH chk-doc WHERE
     chk-doc.obj-type = obj-list.obj-type AND
     chk-doc.obj-code = obj-list.obj-code AND
     chk-doc.chk-date >= X-date-start AND
     chk-doc.chk-date <= X-date-end AND
     (IF cas-num > 0 then chk-doc.pay-desk = cas-num else TRUE)
     NO-LOCK,
 EACH chk-gds NO-LOCK WHERE
       chk-doc.doc-code = chk-gds.doc-code /*AND chk-gds.pump > 0*/
BREAK
BY chk-doc.doc-code
BY chk-gds.b-code:
if lookup(string(chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc2.
assign
sign = if chk-doc.netto >=0 then 1 else - 1
.
{ rep/e-toppyq.i _chk-doc2}
END. /*FOR EACH chk-doc*/
END. /*WHEN NO*/
END. /*CASE*/
END. /*FOR EACH obj-list*/
*/
end procedure.
procedure fill-behefit:
  case entry(1, buf_chk-gds-pay.line-type, {&delim-par}):
    when {&petrolium} then 
      do:

        find first benefits no-lock where
          benefits.b-code = bar-code.b-code
          and benefits.pay-code = buf_chk-gds-pay.pay-code
          and benefits.curr-code = buf_chk-gds-pay.curr-code
          /*                              and benefits.date_ = buf_chk-gds-pay.chk-date*/
          no-error.
        if not avail benefits then 
        do:
          create benefits.
          assign
            /*                          benefits.date_ = buf_chk-gds-pay.chk-date*/
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
      end.
  end.

end procedure.