block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: torg-2.p $
$Archive: rep/torg-2.p $

Печатные формы. Торг-2 для внешнего прихода

Автор: Демин Алексей Сергеевич
Дата создания: 04/13/06
Author: Alexey Demin
Creation date: 04/13/06

*/

define input parameter parParentProc     AS WIDGET-HANDLE NO-UNDO.
define input parameter rec_id       as recid      no-undo.

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: torg-2.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/torg-2.p $":U .
define variable vss-description as character no-undo initial "Печатные формы. Торг-2 для внешнего прихода":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ cmp/r-pril.i   }
{ gbl/cur-time.i }
{ rep/fmtcli.i   }
{ gbl/clntattr.i }
{ str/trdcalib.i }
{ rep/torgconf.i }
{ gbl/paramls.i  }

do
on error undo, return error
:
define buffer t-doc             for trn-doc.
define buffer buf_doc-line      for doc-line.
define buffer buf_goods         for goods.
define buffer buf_clients       for clients .
define buffer buf_firm          for firm.
define buffer buf_sysconf       for sysconf.
define buffer buf_currency      for currency .

define stream out-stream .

  define variable g#report-num as integer   no-undo .
  run get-report-num  in parParentProc ( output g#report-num ).

  define variable g#quest-print as logical   no-undo .
  run get-quest-print in parParentProc ( output g#quest-print ).

  define variable g#log as logical   no-undo .

define shared var PrintScale   as logical                          no-undo.
define shared var CostPrice    as logical                          no-undo.
define shared var sort-name    as logical                          no-undo.
define shared var sort-gr      as logical                          no-undo.

define variable v-par-type                  as character                no-undo.
define variable v-host-code                 as integer                  no-undo.
define variable v-curr-code                 as integer                  no-undo.
define variable v-osnov      as character no-undo .
define variable v-chet-fact  as character no-undo .
define variable v-contract   as character no-undo .
define variable v-attr-value as character no-undo .
define variable v-attr-type  as character no-undo .
define variable v-num-table  as integer   no-undo .
define variable all-doc-qnty as decimal   no-undo .
define variable all-fact-qnty as decimal   no-undo .
define variable qnty-i as decimal   no-undo .
define variable qnty-n as decimal   no-undo .
define variable all-qnty-i as decimal   no-undo .
define variable all-qnty-n as decimal   no-undo .
define variable all-sum-i as decimal   no-undo .
define variable all-sum-n as decimal   no-undo .
define variable all-sum as decimal   no-undo .

define variable v-propis       as char              no-undo.
define variable v-propis-cop       as char              no-undo.
define variable v-itog as decimal no-undo .

define variable v-single-line       as char              no-undo.
define variable v-underline         as char              no-undo.
assign
  v-single-line = fill("-", 230)
  v-underline = fill("_", 230)
.

  find first t-doc no-lock where recid( t-doc ) = rec_id .

  { gbl/hostcode.i  t-doc.obj-type  t-doc.obj-code  v-host-code }

 find first buf_currency no-lock where buf_currency.curr-code = t-doc.exch-code no-error .
 if not available buf_currency then do:
   undo, return error substitute("Не найдена валюта &1", t-doc.exch-code) .
  end.
  define variable str-curr as character no-undo .
  assign str-curr = "Все цены и суммы указаны в " + buf_currency.curr-abbr .

  define variable v-sort-prod             as character            no-undo.
  { gbl/getsect.i run "''" 0 {&attr-prt-glob} }
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'sort-prd' then v-sort-prod = string( thbjattr_thbj-attr.property-value-logical) .
  end.

  run torgconf-read in this-procedure ( input "torg2", input v-host-code, input t-doc.obj-type, input t-doc.obj-code) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description    skip "Ошибка чтения параметров печати формы."
      skip "Форма будет напечатана с параметрами по умолчанию."    skip return-value
      skip trim(error-status :get-message(1))    trim(error-status :get-message(2))    trim(error-status :get-message(3))
    view-as alert-box error.
  end.
  run torgconf-get-self-param in this-procedure ( input t-doc.obj-type, input t-doc.obj-code, input v-curr-code) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description    skip "Ошибка чтения параметров объекта документа."
      skip return-value    skip trim(error-status :get-message(1))
      trim(error-status :get-message(2))     trim(error-status :get-message(3))
    view-as alert-box warning.
  end.
  run torgconf-get-cli-param in this-procedure ( input t-doc.host-code, input t-doc.cli-type, input t-doc.cli-code, input v-curr-code) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description    skip "Ошибка чтения параметров объекта клиента документа."
      skip return-value    skip trim(error-status :get-message(1))    trim(error-status :get-message(2))  trim(error-status :get-message(3))
    view-as alert-box warning.
  end.
  run torgconf-get-form-header in this-procedure (
          input no
        , input t-doc.doc-code
        , input "no"
        , input t-doc.doc-date
        , input t-doc.fact-date
        , input t-doc.doc-type
        , input t-doc.status_
        , input no
        , input no
    ).

  if v-torgconf-outappr = yes  then do:
    put stream out-stream  "Утверждена постановлением Госкомстата России от 25.12.98 N 132" at 87 .
  end.

  { gbl/working.i }
  { cmp/open-out.i stream out-stream " "  }

  define variable v-operation-type    as character    no-undo.
  assign  v-operation-type = " приход" .

  put stream out-stream
        space(5) v-single-line          format  "X(19)"     at 110 skip
        space(5) "| "  at 110    {&g___code}  at 118   "|"  at 128 skip
        space(5) "Форма по ОКУД"   format "X(14)"  at 95 "| " at 110  "0330212"  "|"   at 128 skip
        v-torgconf-organization    format "X(96)" "по ОКПО" format "X(7)" at 102  "| " at 110  v-torgconf-okpo  format "X(16)" "|" at 128 skip
        string( caps( v-torgconf-self-obj-name )  + " (" + string(v-torgconf-self-obj-code) + ")") format "X(104)" "| "  at 110  "|"  at 128 skip
        space(5) "Вид деятельности по ОКДП" format "X(25)"  at 84   "| "  at 110  "|"  at 128 skip
        space(5) string( "Основание для составления акта ______________приказ, распоряжение________ " ) format "X(75)"
                        "номер" format "X(5)" at 104 "| " at 110 v-torgconf-doc-code format "X(16)" "|" at 128 skip
        space(5) "дата" format "X(4)" at 105 "| " at 110 v-torgconf-doc-date format "X(10)" "|" at 128 skip
        space(5) "Вид операции"   format "X(12)"    at 97  "| "  at 110  v-operation-type format "X(16)"  "|" at 128 skip
        space(5) v-single-line format  "X(19)" at 110 skip
    .

  { str/tdat-val.i t-doc.doc-code {&trdcattr-nids} v-attr-value v-attr-type }

  if v-attr-value > "" then assign v-osnov = "накладная " + v-attr-value .
  { str/tdat-val.i t-doc.doc-code {&trdcattr-dids} v-attr-value v-attr-type }
  if v-attr-value > "" then assign v-osnov = v-osnov + " от " + v-attr-value .
  { str/tdat-val.i t-doc.doc-code {&trdcattr-nsf}  v-attr-value v-attr-type }
  assign v-chet-fact = v-attr-value .
  { str/tdat-val.i t-doc.doc-code {&trdcattr-dsf}  v-attr-value v-attr-type }
  assign v-chet-fact = v-chet-fact + " от " + v-attr-value .
  { str/tdat-val.i t-doc.doc-code {&trdcattr-ndog} v-attr-value v-attr-type }
  assign v-contract = v-attr-value .
  { str/tdat-val.i t-doc.doc-code {&trdcattr-ddog} v-attr-value v-attr-type }
  assign v-contract = v-contract + " от " + v-attr-value .

  put stream out-stream
          "УТВЕРЖДАЮ Руководитель" format "X(23)" at 105 skip
        space(50) v-single-line format "X(33)"  space(10)  v-underline format "X(33)" skip
        space(44) string( "А К Т | " + string( v-torgconf-doc-code, "X(16)") + "| "
                                     + string( v-torgconf-doc-date, "X(12)")
                                     + "| " + (if t-doc.status_ <> {&fact} then string( "(" + CAPS(t-doc.status_) + ")" ) else "")
                                    ) format "X(50)"  skip
        space(50) v-single-line format "X(33)"  space(10)  v-underline format "X(15)" space(3)  v-underline format "X(15)"  skip
        space(35) "ОБ УСТАНОВЛЕННОМ РАСХОЖДЕНИИ ПО КОЛИЧЕСТВУ"   skip
        space(25) "И КАЧЕСТВУ ПРИ ПРИЕМКЕ ТОВАРНО-МАТЕРИАЛЬНЫХ ЦЕННОСТЕЙ"   space(15) '"____"'  space(3)  v-underline format "X(15)"  space(3)  v-underline format "X(5)" "г."  skip(2)
        "Место приемки товара " format "X(21)"  v-torgconf-self-obj-addres format "X(110)" skip
        'Настоящий акт составлен комиссией, которая установила:  "____"  ________________________   ________г.' skip
        string("по сопроводительным документам " + v-osnov + " доставлен  товар. Документ о вызове представителя____грузоотправителя,_" ) format "X(130)" skip
        '__поставщика,_производителя:_________телеграмма,_факс,_телефонограмма,_радиограмма__№__________от_"____"___________________г.' format "X(130)" skip
        string( "Грузоотправитель: " + v-torgconf-cargo-to-value )   format "X(130)" skip
        string( "Производитель: " )   format "X(130)" skip
        string( "Поставщик: " + v-torgconf-suppi )   format "X(130)" skip
        string( "Страховая компания: " )   format "X(130)" skip
        string( "Договор (контракт) на поставку товара № " + v-contract )   format "X(130)" skip
        string( "Счет-фактура  № " + v-chet-fact )   format "X(130)" skip
        string( 'Коммерческий акт  №                    _______________ от  "____"______________г. ' )   format "X(130)" skip
        string( 'Ветеринарное свидетельство (справка) № _______________ от  "____"______________г. ' )   format "X(130)" skip
        string( 'Железнодорожная накладная №            _______________ от  "____"______________г. ' )   format "X(130)" skip
        string( "Способ доставки (вид транспортного средства)_____________________________________________________ №_____________" )   format "X(130)" skip
        string( 'Дата отправления товара "____"______________г. ' )   format "X(130)" skip
        "со станции (пристани, порта) отправления"  format "X(42)"  v-underline format "X(88)"  skip
        "или со склада отправителя товара"  format "X(34)"  v-underline format "X(96)" skip
  .

  put stream out-stream
        v-single-line          format  "X(130)"    skip
        "|"  "ДАТА, ВРЕМЯ, ч. мин."  format  "X(20)" at 50       "|" at 130  skip
        v-single-line          format  "X(130)"    skip
        "| прибытия товара | вскрытия вагона, | выдачи      | доставки товара| начала    |                приемки товара                  |"     format  "X(130)"    skip
        "| на станцию      | автофургона, кон-| товара      | на склад       | разгрузки |------------------------------------------------|"     format  "X(130)"    skip
        "| (пристань, порт)| тейнера и других | организацией| организации-   |           |  начало  | приоста-  | возобнов-   | окончание |"     format  "X(130)"    skip
        "|   назначения    | трансп-х средств | транспорта  | получателя     |           |          | новление  |   ление     |           |"     format  "X(130)"    skip
        v-single-line          format  "X(130)"    skip
        string("|                 |                  |             |   " + string(t-doc.fact-date,"99/99/9999")  + "   |           |          |           |             |           |")     format  "X(130)"    skip
        string("|                 |                  |             |      " + string(t-doc.fact-time,"HH:MM")  + "     |           |          |           |             |           |")     format  "X(130)"    skip
        v-single-line          format  "X(130)"    skip
  .
  put stream out-stream
        "    Сведения о состоянии вагонов, автофургонов и т. д. Наличие, описание упаковочных ярлыков, пломб транспорта на отдельных местах"     format  "X(130)"    skip
        "(сертификатов, спецификаций в вагоне, контейнере) и отправительская маркировка____________________________________________________"     format  "X(130)"    skip
        "    По сопроводительным транспортным документам значится:"   format  "X(130)"    skip
  .

  put stream out-stream
        v-single-line          format  "X(130)"    skip
        "| Отметка об оплом- | Количество| Вид | Наименование товара (груза) или       |Един|  Масса брутто по документам  |Особые отметки|"     format  "X(130)"    skip
        "| бировании товара  |   мест    |упак-| номера вагонов (контейнеров,          |изм.|------------------------------| отправителя  |"     format  "X(130)"    skip
        "|(груза), сост.пломб|           |овки | авто фургонов и т.д.)                 |    | отправителя | транспортной   | по накладной |"     format  "X(130)"    skip
        "| и содерж. оттиска |           |     |                                       |    |             | организации    |              |"     format  "X(130)"    skip
        v-single-line          format  "X(130)"    skip
  .

  assign v-num-table = 1 .
  run for-each in this-procedure  .

  if line-counter( out-stream ) + 14 > page-size( out-stream ) then page stream out-stream.

  put stream out-stream
        "    Сведения о состоянии вагонов, автофургонов и т. д. Наличие, описание установленных ярлыков, пломб транспорта на отдельных "     format  "X(130)"    skip
        "местах (сертификатов, спецификаций в вагоне, контейнере) фактически  ____________________________________________________________________"     format  "X(130)"    skip
        v-underline format "X(130)" skip
        v-underline format "X(130)" skip
  .

  put stream out-stream
        v-single-line          format  "X(130)"    skip
        "|   Расхождение по количеству мест и массе в    | Количество|          Масса, кг              | Степень заполнения тарного       |"     format  "X(130)"    skip
        "|   актируемой партии товара, обнаруженные на   |   мест    |---------------------------------| места, вагона, контейнера и т.п. |"     format  "X(130)"    skip
        "|     складе товарополучателя                   |           |  брутто  |   тара   |   нетто   |                                  |"     format  "X(130)"    skip
        v-single-line          format  "X(130)"    skip
        string("| По документам грузоотправителя                |" + string(all-doc-qnty,">>>>>>>>>9.<<<")  + "|          |          |           |                                  |")     format  "X(130)"    skip
        v-single-line          format  "X(130)"    skip
        string("| Фактически поступило                          |" + string(all-fact-qnty,">>>>>>>>>9.<<<")  + "|          |          |           |                                  |")     format  "X(130)"    skip
        v-single-line          format  "X(130)"    skip
        string("| Расхождение (+, -)                            |" + string(all-fact-qnty - all-doc-qnty,"->>>>>>>>9.<<<")  + "|          |          |           |                                  |")     format  "X(130)"    skip
        v-single-line          format  "X(130)"    skip
  .

  if line-counter( out-stream ) + 5 > page-size( out-stream ) then page stream out-stream.
  put stream out-stream
        str-curr               format  "X(130)"    skip
        v-single-line          format  "X(130)"    skip
        "|   Товар (наименование)                 |Номер|Наим|Код |         По документам поставщика значится                             |"     format  "X(130)"    skip
        "|                                        |места|ед. |ед.и|-----------------------------------------------------------------------|"     format  "X(130)"    skip
        "|                                        |     |изм.|ОКЕИ|  артикул    |сорт|кол-во(масса)|     цена       |      сумма          |"     format  "X(130)"    skip
        v-single-line          format  "X(130)"    skip
  .

  assign v-num-table = 2 .
  run for-each in this-procedure  .

  if line-counter( out-stream ) + 4 > page-size( out-stream ) then page stream out-stream.
  put stream out-stream
        "    Условия хранения товара (продукции) до его вскрытия на складе получателя:_____________________________________________________"     format  "X(130)"    skip
        v-underline format "X(130)" skip
        v-underline format "X(130)" skip
        "    Сведения о температуре при разгрузке в вагоне (рефрижераторе и т.д.) в товаре:________________________________________________"     format  "X(130)"    skip
  .
  if line-counter( out-stream ) + 4 > page-size( out-stream ) then page stream out-stream.
  put stream out-stream
        "    Состояние тары и упаковки, маркировка мест, товара и тары в момент внешнего осмотра товара (продукции) _______________________"     format  "X(130)"    skip
        v-underline format "X(130)" skip
        v-underline format "X(130)" skip
        v-underline format "X(130)" skip
  .
  if line-counter( out-stream ) + 4 > page-size( out-stream ) then page stream out-stream.
  put stream out-stream
        "    Содержание наружной маркировки тары и другие данные, на основании которых можно сделать выводы о том, в чьей упаковке "     format  "X(130)"    skip
        "предъявлен товар (производителя или отправителя) _________________________________________________________________________________"     format  "X(130)"    skip
        v-underline format "X(130)" skip
        v-underline format "X(130)" skip
  .
  if line-counter( out-stream ) + 5 > page-size( out-stream ) then page stream out-stream.
  put stream out-stream
        'Дата вскрытия тары  "____" ______________ ______г.' format  "X(130)"    skip
        "    Организация, которая взвесила и опломбировала отгруженный товар, исправность пломб и содержание оттисков, соответствие  "     format  "X(130)"    skip
        "пломб товаросопроводительным документам  _________________________________________________________________________________________"     format  "X(130)"    skip
        v-underline format "X(130)" skip
        v-underline format "X(130)" skip
  .
  if line-counter( out-stream ) + 6 > page-size( out-stream ) then page stream out-stream.
  put stream out-stream
        "    Порядок отбора товара (продукции) для выборочной проверки с указанием ГОСТ, особых условий  поставки по договору (контракту),"     format  "X(130)"    skip
        "основание выборочной проверки:  __________________________________________________________________________________________________"     format  "X(130)"    skip
        v-underline format "X(130)" skip
        v-underline format "X(130)" skip
        v-underline format "X(130)" skip
        v-underline format "X(130)" skip
  .


&scoped-define P1  11
&scoped-define P2  16
&scoped-define P3  26
&scoped-define P4  39
&scoped-define P5  54
&scoped-define P6  60
&scoped-define P7  66
&scoped-define P8  72
&scoped-define P9  78
&scoped-define P10 88
&scoped-define P11 99
&scoped-define P12 110
&scoped-define P13 121

  if line-counter( out-stream ) + 5 > page-size( out-stream ) then page stream out-stream.
  put stream out-stream
      str-curr format  "X(130)"    skip      v-single-line       format  "X(130)"
      skip
        "|"            "Фактически оказалось" at 10  format "X(20)"
        "|" at {&P5}   "Брак"                  format "X(4)"
        "|" at {&P7}   "Бой"                   format "X(4)"
        "|" at {&P9}   "недостача"             format "X(9)"
        "|" at {&P11}  "излишки"               format "X(8)"
        "|" at {&P13}  "Номер"                 format "X(7)"
        "|" at 130
     skip
        v-single-line                          format "X(120)"
        "|" at {&P13}  "паспорта"              format "X(8)"
        "|" at 130
     skip
        "|"            "артикул"               format "X(9)"
        "|" at {&P1}   "сорт"                  format "X(4)"
        "|" at {&P2}   "кол-во"                format "X(6)"
        "|" at {&P3}   "цена"                  format "X(8)"
        "|" at {&P4}   "сумма"                 format "X(9)"
        "|" at {&P5}   "кол-о"                 format "X(5)"
        "|" at {&P6}   "сумма"                 format "X(5)"
        "|" at {&P7}   "кол-о"                 format "X(5)"
        "|" at {&P8}   "сумма"                 format "X(5)"
        "|" at {&P9}   "кол-во"                format "X(6)"
        "|" at {&P10}  "сумма"                 format "X(9)"
        "|" at {&P11}  "кол-во"                format "X(6)"
        "|" at {&P12}  "сумма"                 format "X(9)"
        "|" at {&P13}
        "|" at 130
     skip
         v-single-line                         format  "X(130)"
     skip
 .

  assign v-num-table = 3 .
  run for-each in this-procedure  .

  put stream out-stream
        "|"            "ИТОГО"                                            format "X(9)"
        "|" at {&P1}
        "|" at {&P2}   all-fact-qnty                                      format ">>>>>9.<<"
        "|" at {&P3}
        "|" at {&P4}   all-sum                                            format ">>>>>>>>>>9.99"
        "|" at {&P5}
        "|" at {&P6}
        "|" at {&P7}
        "|" at {&P8}
        "|" at {&P9}   all-qnty-n                                         format ">>>>>9.<<"
        "|" at {&P10}  all-sum-n                                          format ">>>>>>9.99"
        "|" at {&P11}  all-qnty-i                                         format ">>>>>9.<<"
        "|" at {&P12}  all-sum-i                                          format ">>>>>>9.99"
        "|" at {&P13}
        "|" at 130
    skip v-single-line  format  "X(130)"    skip .
  .

  if line-counter( out-stream ) + 3 > page-size( out-stream ) then page stream out-stream.
  put stream out-stream
        "    Определение количества товара (продукции) проводилось ________________________________________________________________________"     format  "X(130)"    skip
        v-underline format "X(130)" skip
        v-underline format "X(130)" skip
  .
  if line-counter( out-stream ) + 4 > page-size( out-stream ) then page stream out-stream.
  put stream out-stream
        "    Взвешивание товаров (продукции) проводилось на исправных весах, проверенных в установленном порядке. Сведение об исправности "     format  "X(130)"    skip
        "весоизмерительных приборов (тип весов, год клеймения)   __________________________________________________________________________"     format  "X(130)"    skip
        v-underline format "X(130)" skip
        v-underline format "X(130)" skip
  .
  if line-counter( out-stream ) + 3 > page-size( out-stream ) then page stream out-stream.
  put stream out-stream
        "    Другие данные ________________________________________________________________________________________________________________"     format  "X(130)"    skip
        v-underline format "X(130)" skip
        v-underline format "X(130)" skip
  .
  if line-counter( out-stream ) + 2 > page-size( out-stream ) then page stream out-stream.
  put stream out-stream
        "    По остальным товарно-материальным ценностям, перечисленным в сопроводительных документах поставщика, расхождений в количестве"     format  "X(130)"    skip
        "и качестве нет."     format  "X(130)"    skip
  .
  if line-counter( out-stream ) + 3 > page-size( out-stream ) then page stream out-stream.
  put stream out-stream
        "    Подробное описание дефектов (характер недостачи, излишков, ненадлежащего качества, брака, боя) и мнение комиссии"     format  "X(130)"    skip
        "о причинах их образования"     format  "X(130)"    skip
        string("Обнаружена недостача товара (" + string(all-qnty-n,">>>>>>>>>>9.<<<")  + "), Обнаружены излишки товара (" + string(all-qnty-i,">>>>>>>>>>9.<<<") + ")") format  "X(130)"    skip(2)
  .
  if line-counter( out-stream ) + 2 > page-size( out-stream ) then page stream out-stream.
  if all-sum-n >= all-sum-i then do:
    assign
      v-osnov = "Уменьшить"
      v-itog  = all-sum-n - all-sum-i
    .
  end.
  else do:
    assign
      v-osnov = "Увеличить"
      v-itog  = all-sum-i - all-sum-n
    .
  end.
  if t-doc.exch-code = 0 then run rep/wp-rub.p ( input v-itog, output v-propis, output v-propis-cop ).
  else assign v-propis = string(v-itog,">>>,>>>,>>>,>>9.99") + " " +  buf_currency.curr-abbr .

  put stream out-stream
        "    Заключение комиссии"       format  "X(130)"    skip
        string( v-osnov + " задолженность поставщику на " + v-propis + " с учетом НДС (сумма прописью)") format  "X(130)"    skip(2)
  .
  if line-counter( out-stream ) + 1 > page-size( out-stream ) then page stream out-stream.
  put stream out-stream
        "    Члены комиссии предупреждены об ответственности за подписание акта, содержащего данные, не соответствующие действительности."       format  "X(130)"    skip
  .
  if line-counter( out-stream ) + 4 > page-size( out-stream ) then page stream out-stream.
  put stream out-stream
        "Председатель комиссии         ___________________________    _____________   _________________________"       format  "X(130)"    skip
        "Члены комиссии                ___________________________    _____________   _________________________"       format  "X(130)"    skip
        "                              ___________________________    _____________   _________________________"       format  "X(130)"    skip
        "                              ___________________________    _____________   _________________________"       format  "X(130)"    skip
  .
  if line-counter( out-stream ) + 7 > page-size( out-stream ) then page stream out-stream.
  put stream out-stream
        "Представитель грузоотправителя (поставщика, производителя)   ___________________________    _____________   ______________________"       format  "X(130)"    skip
        "Документ, удостоверяющий полномочия ______________________________________________________________________________________________"       format  "X(130)"    skip
        '№ ___________________________ выдан "____"   ________________  _________г'       format  "X(130)"    skip
        "Акт с приложением на ___________ листах получил"       format  "X(130)"    skip
        string("Главный (старший) бухгалтер _______________   " + v-torgconf-main-buh )      format  "X(130)"    skip
        "Решение руководителя "       format  "X(130)"    skip
        string( v-osnov + " задолженность поставщику на " + /*string(all-sm-n,">>>,>>>,>>>,>>9.99")*/ v-propis + " с учетом НДС (сумма прописью)") format  "X(130)"    skip(2)
  .

  { gbl/stopwork.i }
  output stream out-stream close.

  { rep/q-print.i 0}

end.



procedure for-each :
  do on error undo, return error return-value :
    if v-sort-prod = "yes" then do:
      if sort-gr = yes then do:
        if sort-name = yes then do:
          for each buf_doc-line no-lock
            where buf_doc-line.doc-code = t-doc.doc-code
            , first buf_goods no-lock
              where buf_goods.artic      = buf_doc-line.artic
                and buf_goods.prod-type  = buf_doc-line.prod-type
                and buf_goods.prod-code  = buf_doc-line.prod-code
            break by buf_doc-line.prod-type by buf_doc-line.prod-code by buf_goods.grp-name  by buf_goods.gds-name
          :
            if  first-of( buf_doc-line.prod-code) then do:
              run print-prod in this-procedure .
            end.
            if  first-of( buf_goods.grp-name) then do:
              run print-grp in this-procedure .
            end.
            run print-line in this-procedure .
          end.
        end.        /* sort-name = yes */
        else do:
          for each buf_doc-line
            where buf_doc-line.doc-code = t-doc.doc-code
            , first buf_goods no-lock
              where buf_goods.artic      = buf_doc-line.artic
                and buf_goods.prod-type  = buf_doc-line.prod-type
                and buf_goods.prod-code  = buf_doc-line.prod-code
            break by buf_doc-line.prod-type by buf_doc-line.prod-code by buf_goods.grp-name  by buf_doc-line.num-place
          :
            if  first-of( buf_doc-line.prod-code) then do:
              run print-prod in this-procedure .
            end.
            if  first-of( buf_goods.grp-name) then do:
              run print-grp in this-procedure .
            end.
            run print-line in this-procedure .
          end.
        end.        /* sort-name <> yes */
      end.        /* sort-gr = yes */
      else do:
        if sort-name = yes then do:
          for each buf_doc-line no-lock
            where buf_doc-line.doc-code = t-doc.doc-code
            , first buf_goods no-lock
            where buf_goods.artic      = buf_doc-line.artic
              and buf_goods.prod-type  = buf_doc-line.prod-type
              and buf_goods.prod-code  = buf_doc-line.prod-code
            break by buf_doc-line.prod-type by buf_doc-line.prod-code by buf_goods.gds-name
          :
            if  first-of( buf_doc-line.prod-code) then do:
              run print-prod in this-procedure .
            end.
            run print-line in this-procedure .
          end.
        end.        /* sort-name = yes */
        else do:
          for each buf_doc-line
            where buf_doc-line.doc-code = t-doc.doc-code
            , first buf_goods no-lock
            where buf_goods.artic      = buf_doc-line.artic
                and buf_goods.prod-type  = buf_doc-line.prod-type
                and buf_goods.prod-code  = buf_doc-line.prod-code
            break by buf_doc-line.prod-type by buf_doc-line.prod-code by buf_doc-line.num-place
          :
            if  first-of( buf_doc-line.prod-code) then do:
              run print-prod in this-procedure .
            end.
            run print-line in this-procedure .
          end.
        end.        /* sort-name <> yes */
      end.        /* sort-gr <> yes */
    end.        /* sort-prod = yes */
    else do:
      if sort-gr = yes then do:
        if sort-name = yes then do:
          for each buf_doc-line no-lock
            where buf_doc-line.doc-code = t-doc.doc-code
            , first buf_goods no-lock
              where buf_goods.artic      = buf_doc-line.artic
                and buf_goods.prod-type  = buf_doc-line.prod-type
                and buf_goods.prod-code  = buf_doc-line.prod-code
            break by buf_goods.grp-name  by buf_goods.gds-name
          :
            if  first-of( buf_goods.grp-name) then do:
              run print-grp in this-procedure .
            end.
            run print-line in this-procedure .
          end.
        end.        /* sort-name = yes */
        else do:
          for each buf_doc-line
            where buf_doc-line.doc-code = t-doc.doc-code
            , first buf_goods no-lock
              where buf_goods.artic      = buf_doc-line.artic
                and buf_goods.prod-type  = buf_doc-line.prod-type
                and buf_goods.prod-code  = buf_doc-line.prod-code
            break by buf_goods.grp-name  by buf_doc-line.num-place
          :
            if  first-of( buf_goods.grp-name) then do:
              run print-grp in this-procedure .
            end.
            run print-line in this-procedure .
          end.
        end.        /* sort-name <> yes */
      end.        /* sort-gr = yes */
      else do:
        if sort-name = yes then do:
          for each buf_doc-line no-lock
            where buf_doc-line.doc-code = t-doc.doc-code
            , first buf_goods no-lock
            where buf_goods.artic      = buf_doc-line.artic
              and buf_goods.prod-type  = buf_doc-line.prod-type
              and buf_goods.prod-code  = buf_doc-line.prod-code
            break by buf_goods.gds-name
          :
            run print-line in this-procedure .
          end.
        end.        /* sort-name = yes */
        else do:
          for each buf_doc-line
            where buf_doc-line.doc-code = t-doc.doc-code
            , first buf_goods no-lock
            where buf_goods.artic      = buf_doc-line.artic
                and buf_goods.prod-type  = buf_doc-line.prod-type
                and buf_goods.prod-code  = buf_doc-line.prod-code
            break by buf_doc-line.num-place
          :
            run print-line in this-procedure .
          end.
        end.        /* sort-name <> yes */
      end.        /* sort-gr <> yes */
    end.        /* sort-prod = yes */
    put stream out-stream   v-single-line  format  "X(130)"    skip .
  end.
end procedure. /* for-each */



procedure Print-prod :
  do on error undo, return error return-value :
    if line-counter( out-stream ) + 2 > page-size( out-stream ) then page stream out-stream.
    find first buf_clients where buf_clients.obj-type = buf_goods.prod-type and buf_clients.obj-code = buf_goods.prod-code no-lock .
    put stream out-stream "| Производитель - " format "X(18)"  buf_clients.obj-name   format  "X(110)"  "|" at 130 skip .
  end.
end procedure. /* Print-prod */



procedure print-grp :
  do on error undo, return error return-value :
    if line-counter( out-stream ) + 2 > page-size( out-stream ) then page stream out-stream.
    put stream out-stream "| Группа - " format "X(11)"  buf_goods.grp-name   format  "X(118)"  "|" at 130 skip .
  end.
end procedure. /* print-grp */



procedure print-line :
  do on error undo, return error return-value :
    if line-counter( out-stream ) + 2 > page-size( out-stream ) then page stream out-stream.
    case v-num-table :
      when 1 then do:
        put stream out-stream "|" "|" at 21 buf_doc-line.doc-qnty format ">>>>>>>>>9.<<<"
               "|" "|" at 39 buf_goods.gds-name format  "X(39)" "|" at 79 buf_goods.unit-base  "|" at 84  "|" at 98  "|" at 115  "|" at 130 skip .
            assign
              all-doc-qnty  = all-doc-qnty  + buf_doc-line.doc-qnty
              all-fact-qnty = all-fact-qnty + buf_doc-line.fact-qnty
            .
      end.
      when 2 then do:
        put stream out-stream
               "|"
               buf_goods.gds-name                                format  "X(40)"                  "|" at 42  "|" at 48
               buf_goods.unit-base                                                                "|" at 53  "|" at 58
               buf_goods.artic                                   format "X(11)"                   "|" at 72
               buf_goods.sort                                    format "X(4)"                    "|" at 77
               buf_doc-line.doc-qnty                             format ">>>>>>>>9.<<<"           "|" at 91
               buf_doc-line.price-cli / buf_doc-line.cli-base-rate                           format ">,>>>,>>>,>>9.99"        "|" at 108
               (buf_doc-line.price-cli * buf_doc-line.doc-qnty / buf_doc-line.cli-base-rate ) format ">>,>>>,>>>,>>>,>>9.99"   "|" at 130 skip .
      end.
      when 3 then do:
        if (buf_doc-line.fact-qnty - buf_doc-line.doc-qnty < 0 ) then
          assign qnty-n = buf_doc-line.doc-qnty - buf_doc-line.fact-qnty   qnty-i = 0 .
        else
          assign qnty-i = buf_doc-line.fact-qnty - buf_doc-line.doc-qnty  qnty-n = 0 .
        assign
          all-qnty-n = all-qnty-n + qnty-n
          all-qnty-i = all-qnty-i + qnty-i
          all-sum-n  = all-sum-n  + buf_doc-line.price-cli * qnty-n / buf_doc-line.cli-base-rate
          all-sum-i  = all-sum-i  + buf_doc-line.price-cli * qnty-i / buf_doc-line.cli-base-rate
          all-sum    = all-sum    + buf_doc-line.price-cli * buf_doc-line.fact-qnty / buf_doc-line.cli-base-rate
        .
        put stream out-stream
              "|"            buf_goods.artic                                    format "X(9)"
              "|" at {&P1}   buf_goods.sort                                     format "X(4)"
              "|" at {&P2}   buf_doc-line.fact-qnty                             format ">>>>>9.<<"
              "|" at {&P3}   buf_doc-line.price-cli / buf_doc-line.cli-base-rate                            format ">>>>>>>>9.99"
              "|" at {&P4}   buf_doc-line.price-cli * buf_doc-line.fact-qnty / buf_doc-line.cli-base-rate   format ">>>>>>>>>>9.99"
              "|" at {&P5}
              "|" at {&P6}
              "|" at {&P7}
              "|" at {&P8}
              "|" at {&P9}   qnty-n                                             format ">>>>>9.<<"
              "|" at {&P10}  buf_doc-line.price-cli * qnty-n / buf_doc-line.cli-base-rate                   format ">>>>>>9.99"
              "|" at {&P11}  qnty-i                                             format ">>>>>9.<<"
              "|" at {&P12}  buf_doc-line.price-cli * qnty-i / buf_doc-line.cli-base-rate                 format ">>>>>>9.99"
              "|" at {&P13}
              "|" at 130
          skip
        .
      end.
    end.
  end.
end procedure. /* print-line */
