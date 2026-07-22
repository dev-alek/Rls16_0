block-level on error undo, throw.
/*

$Revision: 099a383cf864, 290, rls $
$Author: PGridchina $
$Date: Tue Dec 01 19:11:24 2015 +0300 $
$Workfile: sib-actp.p $
$Archive: rep/sib-actp.p $

Акт приема нефтепродуктов по количеству

Автор: Хныкин Павел Андреевич
Дата создания: 07/24/07
Author: Pavel Khnykin
Creation date: 07/24/07

*/
define input parameter parparentproc   as handle    no-undo.
define input parameter p-trn-recid     as recid     no-undo.

define variable vss-revision    as character no-undo init "$Revision: 099a383cf864, 290, rls $":U .
define variable vss-author      as character no-undo init "$Author: PGridchina $":U .
define variable vss-date        as character no-undo init "$Date: Tue Dec 01 19:11:24 2015 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sib-actp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/sib-actp.p $":U .
define variable vss-description as character no-undo init "Акт приема нефтепродуктов по количеству".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ gbl/prn-lib.i  }
{ cmp/r-pril.i   }
{ rep/p-fmt.i    }
{ rep/r-sym.i    }
{ rep/fmtcli.i   }
{ gbl/attr-lib.i }
{ rep/torgconf.i }
{ gbl/paramls.i  }

  define variable g#report-num    as integer      no-undo.
  define variable g#quest-print   as logical      no-undo.
  define variable g#log           as logical      no-undo.
  run get-report-num in parparentproc ( output g#report-num ).
  run get-quest-print in parparentproc ( output g#quest-print ).

{ rep/sibactxl.i }


define temp-table tt-report no-undo
  field line-num like ub.doc-line.line-num
  field gds-code like ub.goods.gds-code
  field col-1    as character
  field col-2    as character
  field col-3    as character
  field col-4    as character
  field col-5    as character
  field col-6    as character
  field col-7    as character
  field col-8    as character
  field col-9    as character
  field col-10   as character
  field col-11   as character
  field col-12   as character
  field col-13   as character
  field col-14   as character
  field col-15   as character
  field col-16   as character
  field col-17   as character
index pi is primary unique
    line-num
    gds-code
.


define stream out-stream.

define buffer buf_trn-doc   for ub.trn-doc.
define buffer buf_doc-line  for ub.doc-line.
define buffer buf_goods     for ub.goods.
define buffer buf_doc-attr  for ub.doc-attr.

define variable v-head-time-pour        as character             initial ?        no-undo .
define variable v-head-time-income      as character             initial ?        no-undo .
define variable v-head-azk-num          like ub.trn-doc.obj-code format ">>>>>9"  no-undo .
define variable v-head-azk-num-length   as integer     no-undo .
define variable v-head-doc-date         as date        no-undo .
define variable v-cli-name              as character   no-undo .
define variable v-head-autoent-obj-name as character   no-undo .
define variable v-address               as character   no-undo .
define variable v-trn-doc-code          like ub.trn-doc.doc-code no-undo .
define variable v-driver-fio            as character   no-undo .
define variable v-car-num               as character   no-undo .
define variable v-host-code             as integer     no-undo .
define variable v-curr-code             as integer     no-undo .

&scop frame-width 199
&scop col-1-width 20
&scop col-fmt-1 "X(20)"
&scop col-fmt-2 "X(10)"
&scop col-fmt-3 "X(20)"
&scop col-fmt-4 "->>>>>9.99"
&scop col-fmt-5 "->>>>>9.99"
&scop col-fmt-6 "->>9.99"
&scop col-fmt-7 "->>>>>9.99"
&scop col-fmt-8 "->>>>>9.99"
&scop col-fmt-9 "->>>>>9.99"
&scop col-fmt-10 ">>9.999999"
&scop col-fmt-11 "->9.9"
&scop col-fmt-12 "->>>>>9.99"
&scop col-fmt-13 "->>>>>9.99"
&scop col-fmt-14 "->>>>>9.99"
&scop col-fmt-15 "->>>>>9.99"
&scop col-fmt-16 "->>>>>9.99"
&scop col-fmt-17 "->>>>>9.99"

&scop col-fmtl-1 "X(20)"
&scop col-fmtl-2 "X(10)"
&scop col-fmtl-3 "X(20)"
&scop col-fmtl-4 "X(10)"
&scop col-fmtl-5 "X(10)"
&scop col-fmtl-6 "X(6)"
&scop col-fmtl-7 "X(10)"
&scop col-fmtl-8 "X(10)"
&scop col-fmtl-9 "X(10)"
&scop col-fmtl-10 "X(10)"
&scop col-fmtl-11 "X(5)"
&scop col-fmtl-12 "X(10)"
&scop col-fmtl-13 "X(10)"
&scop col-fmtl-14 "X(10)"
&scop col-fmtl-15 "X(10)"
&scop col-fmtl-16 "X(10)"
&scop col-fmtl-17 "X(10)"

define frame sib-act
  sym1                        no-label format "X(1)"                          space(0)
  tt-report.col-1             no-label format {&col-fmtl-1}                   space(0)
  sym2                        no-label format "X(1)"                          space(0)
  tt-report.col-2             no-label format {&col-fmtl-2}                   space(0)
  sym3                        no-label format "X(1)"                          space(0)
  tt-report.col-3             no-label format {&col-fmtl-3}                   space(0)
  sym4                        no-label format "X(1)"                          space(0)
  tt-report.col-4             no-label format {&col-fmtl-4}                   space(0)
  sym5                        no-label format "X(1)"                          space(0)
  tt-report.col-5             no-label format {&col-fmtl-5}                   space(0)
  sym6                        no-label format "X(1)"                          space(0)
  tt-report.col-6             no-label format {&col-fmtl-6}                   space(0)
  sym7                        no-label format "X(1)"                          space(0)
  tt-report.col-7             no-label format {&col-fmtl-7}                   space(0)
  sym8                        no-label format "X(1)"                          space(0)
  tt-report.col-8             no-label format {&col-fmtl-8}                   space(0)
  sym9                        no-label format "X(1)"                          space(0)
  tt-report.col-9             no-label format {&col-fmtl-9}                   space(0)
  sym10                       no-label format "X(1)"                          space(0)
  tt-report.col-10            no-label format {&col-fmtl-10}                  space(0)
  sym11                       no-label format "X(1)"                          space(0)
  tt-report.col-11            no-label format {&col-fmtl-11}                  space(0)
  sym12                       no-label format "X(1)"                          space(0)
  tt-report.col-12            no-label format {&col-fmtl-12}                  space(0)
  sym13                       no-label format "X(1)"                          space(0)
  tt-report.col-13            no-label format {&col-fmtl-13}                  space(0)
  sym14                       no-label format "X(1)"                          space(0)
  tt-report.col-14            no-label format {&col-fmtl-14}                  space(0)
  sym15                       no-label format "X(1)"                          space(0)
  tt-report.col-15            no-label format {&col-fmtl-15}                  space(0)
  sym16                       no-label format "X(1)"                          space(0)
  tt-report.col-16            no-label format {&col-fmtl-16}                  space(0)
  sym17                       no-label format "X(1)"                          space(0)
  tt-report.col-17            no-label format {&col-fmtl-17}                  space(0)
  sym18                       no-label format "X(1)"                          space(0)
header
    "-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" skip
    ":                    :          :                    :   Числится по ТТН   :                           Фактически                              :  Предел  :             Недостача          :  Принято :" skip
    ":     Дата и №       : Г.Н.З.,  :     Марка н/п,     :---------------------:-------------------------------------------------------------------:допустимой:--------------------------------:  на учет :" skip
    ":  ТТН, ФИО водителя : АЦ,      :     № секции       :  Вмест,  :  Масса   : Выше :  Объем   :   Объем  :  Вмест.  :  Плотн.  : Темп:   Масса  :  относи- :     %,   :    кг    :     л    :    АЗС,  :" skip
    ":                    : прицепа  :                    :          :  (вес),  : (+)  : перелива :  секции  :          :          :     :          :  тельной :          :          :          :          :" skip
    ":                    :          :                    :          :          : Ниже : (недол.) :    АЦ    :          :          :     :          : погрешно-:          :          :          :          :" skip
    ":                    :          :                    :          :          : (-)  :  тарир.  :   ( по   :          :          :     :          : сти, 0,4%:          :          :          :          :" skip
    ":                    :          :                    :          :          :тарир.:  планки  :  Свид.   :          :          :     :          :          :          :          :          :          :" skip
    ":                    :          :                    :          :          :планки: ( по     :     о    :          :          :     :   кг     :          :          :          :          :     л    :" skip
    ":                    :          :                    :          :          :      : Градуир. : поверке) :          :          :     :          :          :          :          :          :          :" skip
    ":                    :          :                    :          :          :      : таблице  :          :          :          :     :          :          :          :          :          :          :" skip
    ":                    :          :                    :          :          :      : горлов. ):          :          :          :     :          :          : (гр.5 -  :          :          :          :" skip
    ":                    :          :                    :          :          :      :          :          :          :          :     : (гр.9x   :          : гр.12) / : (гр.5 -  : гр.15 /  : (гр.4 -  :" skip
    ":                    :          :                    :     л    :     кг   :  см  :     л    :     л    :     л    :   кг/л   :  С  :  гр.10)  :          :гр.5 x 100:  гр.12)  : гр.10    :  гр.16)  :" skip
    ":--------------------:----------:--------------------:----------:----------:------:----------:----------:----------:----------:-----:----------:----------:----------:----------:----------:----------:" skip
    ":         1          :     2    :          3         :     4    :     5    :   6  :     7    :     8    :     9    :     10   :  11 :     12   :     13   :     14   :     15   :     16   :     17   :" skip
    /*":--------------------:----------:--------------------:----------:----------:------:----------:----------:----------:----------:-----:----------:----------:----------:----------:----------:----------:"*/
with width {&frame-width} down stream-io no-label no-box.

form header
        fill( "-" , {&frame-width} ) format "X({&frame-width})" at 1 SKIP
        "Продолжение - на следующей странице" at 1 SKIP
with frame BottomPriFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .


do on error undo, return error return-value :
  { gbl/working.i  }
  find first buf_trn-doc no-lock where recid(buf_trn-doc) = p-trn-recid no-error .
  if not available buf_trn-doc then do:
    message
      "Не найдена ТТН с recid = " p-trn-recid " для печати формы."
    view-as alert-box error.
    undo, return error.
  end.
  { cmp/open-out.i stream out-stream " " {&CS_PS} }
  run sibactxl-init in this-procedure .
  assign
    v-head-azk-num        = buf_trn-doc.obj-code
    v-head-azk-num-length = length(string(v-head-azk-num))
    v-head-doc-date       = if buf_trn-doc.status_ = {&fact}
                            then buf_trn-doc.fact-date
                            else buf_trn-doc.doc-date
  .

  { gbl/hostcode.i buf_trn-doc.obj-type buf_trn-doc.obj-code v-host-code no-error }
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description   skip "Ошибка чтения параметров объекта документа."  skip return-value
      skip trim(error-status :get-message(1))   trim(error-status :get-message(2))  trim(error-status :get-message(3))
    view-as alert-box warning.
  end.
  { gbl/basecode.i v-host-code v-curr-code no-error }
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description   skip "Ошибка чтения параметров объекта документа."  skip return-value
      skip trim(error-status :get-message(1))   trim(error-status :get-message(2))  trim(error-status :get-message(3))
    view-as alert-box warning.
  end.
  run fill-tt-report in this-procedure .

  view frame BottomPriFrame.
  run print-header in this-procedure .
  for each tt-report:
    run print-line in this-procedure .
  end.
  run print-footer in this-procedure .
  output stream out-stream close.
  run sibactxl-close in this-procedure .
  { gbl/stopwork.i }
  { rep/q-print.i 8 }
end.



/* ================================================================================================================== */
procedure print-header :

&scop line-1 "Приложение №4":U
&scop line-2 "к Регламенту по приему светлых нефтепродуктов":U
&scop line-3 '                "Утверждаю"                  ':U
&scop podpis "                  (подпись)         (фио)    ":U
define buffer buf_doc-line-attr for ub.doc-line-attr.

define variable v-director  as character no-undo .
define variable v-consignee as character no-undo .
define variable v-doc-date  as character no-undo .

do
on error undo, return error return-value
:
  run torgconf-get-self-param in this-procedure (
        input buf_trn-doc.obj-type
      , input buf_trn-doc.obj-code
      , input v-curr-code
  ) no-error.
  if error-status :error
  then do:
      message
      vss-workfile vss-revision vss-description
      skip "Ошибка чтения параметров объекта документа."
      skip return-value
      skip trim(error-status :get-message(1))
          trim(error-status :get-message(2))
          trim(error-status :get-message(3))
      view-as alert-box warning.
  end.
  run torgconf-get-cli-param in this-procedure (
        input buf_trn-doc.host-code
      , input buf_trn-doc.cli-type
      , input buf_trn-doc.cli-code
      , input v-curr-code
  ) no-error.
  if error-status :error
  then do:
      message
      vss-workfile vss-revision vss-description
      skip "Ошибка чтения параметров объекта клиента документа."
      skip return-value
      skip trim(error-status :get-message(1))
          trim(error-status :get-message(2))
          trim(error-status :get-message(3))
      view-as alert-box warning.
  end.

  assign
    v-director  = substitute("Директор АЗС № &1 ___________  _______________" , v-head-azk-num )
    v-consignee = substitute('Грузополучатель: ООО "Сибнефть-АЗС Сервис", АЗС № &1':U , v-head-azk-num )
    v-doc-date  = string( v-head-doc-date , "99.99.9999" )
  .
  put stream out-stream
    {&line-1} at right-field( {&frame-width} , length({&line-1}) ) skip
    {&line-2} at right-field( {&frame-width} , length({&line-2}) ) skip
    {&line-3} at right-field( {&frame-width} , length({&line-3}) ) skip
  .
  put stream out-stream
    "Время убытия с пункта налива: ":U v-head-time-pour v-director format "X(60)" at right-field({&frame-width},length(v-director)) skip
    "Время приема груза на АЗС: ":U v-head-time-income {&podpis} at right-field({&frame-width},length({&podpis})) skip(2)
    v-doc-date format "X(12)" at right-field( {&frame-width} , length(v-doc-date) ) skip
    "Грузоотправитель: ":U v-torgconf-cli-name format "X(180)" skip
    "Автопредприятие: ":U v-head-autoent-obj-name format "X(190)" skip
    v-consignee format "X(190)" skip
    'адрес:':U v-torgconf-self-obj-addres format "X(180)" skip(1)
  .
  put stream out-stream
    "АКТ":U at center-field(1, {&frame-width} , 3 ) skip
    "приема нефтепродуктов по количеству":U at center-field(1, {&frame-width} , 35 ) skip
  .
    run sibactxl-write-cell-data in this-procedure (
          input {&sibactxl-h_timePour}
        , input v-head-time-pour
    ).
    run sibactxl-write-cell-data in this-procedure (
          input {&sibactxl-h_timeIncome}
        , input v-head-time-income
    ).
    run sibactxl-write-cell-data in this-procedure (
          input {&sibactxl-h_cargoFrom}
        , input v-torgconf-cli-name
    ).
    run sibactxl-write-cell-data in this-procedure (
          input {&sibactxl-h_cargoTo}
        , input v-consignee
    ).
    run sibactxl-write-cell-data in this-procedure (
          input {&sibactxl-h_autoent}
        , input v-head-autoent-obj-name
    ).
    run sibactxl-write-cell-data in this-procedure (
          input {&sibactxl-h_address}
        , input v-torgconf-self-obj-addres
    ).
    run sibactxl-write-cell-data in this-procedure (
          input {&sibactxl-h_dirAzk}
        , input substitute("Директор АЗС № &1" , v-head-azk-num )
    ).
    run sibactxl-write-cell-data in this-procedure (
          input {&sibactxl-h_docDate}
        , input v-doc-date
    ).


end.

end procedure. /* print-header */


/* ================================================================================================================== */
procedure print-footer :

define variable v-star-op       as character no-undo .
define variable v-op            as character no-undo .
define variable v-azk-ex        as character no-undo .

do
on error undo, return error return-value
:
  put stream out-stream
    'Все лица, участвующие в приемке предупреждены о том, что они несут ответственность за достоверность данных, указанных в настоящем акте.':U skip
    'Представители грузополучателя (ООО "Сибнефть-АЗС Сервис"):':U skip
  .
  assign
    v-star-op = substitute( 'Старший оператор АЗС № &1:                                                             ', v-head-azk-num )
    v-op      = substitute( 'Оператор АЗС № &1:                                                                     ', v-head-azk-num )
    v-azk-ex  = substitute( '3 экз. –  АЗС № &1                            ', v-head-azk-num )
  .
  put stream out-stream
    v-star-op format "X(84)" '_____________________                                                                                                                ':U skip
    v-op format "X(84)" '_____________________                       ':U skip

    'Представители автопредприятия (Перевозчика):':U skip
    'Водитель-экспедитор                                                                 _____________________      Особые отметки водителя-экспедитора ____________________________________________________':U skip
    'Исп. В 4-х экз.:':U skip
    '1 экз. - Бухгалтерия ООО "Сибнефть-АЗС Сервис"               ' v-azk-ex format "X(44)" '______________________________________________________________________________________________':U skip
    '2 экз. - ОЛП  ООО "Сибнефть-АЗС Сервис"                      4 экз. - Перевозчику                        ______________________________________________________________________________________________':U skip
    '                                                                                                         подпись _____________________ Ф.И.О._________________':U
  .
    run sibactxl-write-cell-data in this-procedure (
          input {&sibactxl-f_stOp}
        , input substitute( 'Старший оператор АЗС № &1:', v-head-azk-num )
    ).
    run sibactxl-write-cell-data in this-procedure (
          input {&sibactxl-f_op}
        , input substitute( 'Оператор АЗС № &1:', v-head-azk-num )
    ).
    run sibactxl-write-cell-data in this-procedure (
          input {&sibactxl-f_3Ex}
        , input substitute( '3 экз. –  АЗС № &1', v-head-azk-num )
    ).

end.

end procedure. /* print-footer */


/* ================================================================================================================== */
procedure print-line :

define variable v-str-col1 as character no-undo .
define variable v-i        as integer   no-undo .

do
on error undo, return error return-value
:
    assign
      v-i = index( tt-report.col-1 , ',' )
    .
    if v-i > 0 then do:
      display stream out-stream
        sym1
        substring(tt-report.col-1, 1, v-i + 1) @ tt-report.col-1
        sym2
        tt-report.col-2
        sym3
        tt-report.col-3
        sym4
        tt-report.col-4
        sym5
        tt-report.col-5
        sym6
        tt-report.col-6
        sym7
        tt-report.col-7
        sym8
        tt-report.col-8
        sym9
        tt-report.col-9
        sym10
        tt-report.col-10
        sym11
        tt-report.col-11
        sym12
        tt-report.col-12
        sym13
        tt-report.col-13
        sym14
        tt-report.col-14
        sym15
        tt-report.col-15
        sym16
        tt-report.col-16
        sym17
        tt-report.col-17
        sym18
      with frame sib-act .
      down stream out-stream with frame sib-act.
      display stream out-stream
        sym1
        substring(tt-report.col-1, v-i + 1 ) @ tt-report.col-1
        sym2
        sym3
        sym4
        sym5
        sym6
        sym7
        sym8
        sym9
        sym10
        sym11
        sym12
        sym13
        sym14
        sym15
        sym16
        sym17
        sym18
      with frame sib-act .
    end.
    else do:
      display stream out-stream
        sym1
        tt-report.col-1
        sym2
        tt-report.col-2
        sym3
        tt-report.col-3
        sym4
        tt-report.col-4
        sym5
        tt-report.col-5
        sym6
        tt-report.col-6
        sym7
        tt-report.col-7
        sym8
        tt-report.col-8
        sym9
        tt-report.col-9
        sym10
        tt-report.col-10
        sym11
        tt-report.col-11
        sym12
        tt-report.col-12
        sym13
        tt-report.col-13
        sym14
        tt-report.col-14
        sym15
        tt-report.col-15
        sym16
        tt-report.col-16
        sym17
        tt-report.col-17
        sym18
      with frame sib-act .
      down stream out-stream with frame sib-act.
    end.
    run hor-line in this-procedure .
    run sibactxl-write-line-data in this-procedure ( input tt-report.col-1
                                                   , input tt-report.col-2
                                                   , input tt-report.col-3
                                                   , input tt-report.col-4
                                                   , input tt-report.col-5
                                                   , input tt-report.col-6
                                                   , input tt-report.col-7
                                                   , input tt-report.col-8
                                                   , input tt-report.col-9
                                                   , input tt-report.col-10
                                                   , input tt-report.col-11
                                                   , input tt-report.col-12
                                                   , input tt-report.col-13
                                                   , input tt-report.col-14
                                                   , input tt-report.col-15
                                                   , input tt-report.col-16
                                                   , input tt-report.col-17
                                                   ) .
end.

end procedure. /* print-line */


/* ================================================================================================================== */
procedure fill-tt-report :

define buffer buf_doc-line-attr for ub.doc-line-attr.
define buffer buf_clients       for ub.clients.

define variable is-petrolium           as logical   no-undo .
define variable is-pieces              as logical   no-undo .
define variable v-autoent-obj-code     as character no-undo .
define variable v-autoent-obj-type     as character no-undo .
define variable v-car-num              as character no-undo .
define variable v-car-vol              as character no-undo .
define variable v-tank-density         as character no-undo .
define variable v-tank-temp            as character no-undo .
define variable v-tank-vol             as character no-undo .
define variable v-time-pour            as character no-undo .
define variable v-time-income          as character no-undo .
define variable v-time-start           as character no-undo .
define variable v-time-end             as character no-undo .
define variable v-fio                  as character no-undo .
define variable v-mouth                as character no-undo .
define variable v-a-b-tarir            as character no-undo .

define variable v-car-vol-dec          as decimal   no-undo .
define variable v-tank-density-dec     as decimal   no-undo .
define variable v-tank-temp-dec        as decimal   no-undo .
define variable v-tank-vol-dec         as decimal   no-undo .
define variable v-mouth-dec            as decimal   no-undo .
define variable v-a-b-tarir-dec        as decimal   no-undo .

define variable v-time-pour-int        as integer   no-undo .
define variable v-time-income-int      as integer   no-undo .
define variable v-item-pour            as character no-undo .
define variable v-head-time-pour-int   as integer initial ?  no-undo .
define variable v-head-time-income-int as integer initial ?  no-undo .
define variable v-autoent-obj-code-int as integer   no-undo .
define variable v-tmp-dec              as decimal   no-undo .

do
on error undo, return error return-value
:
  _doc-line:
  for each buf_doc-line no-lock
    where buf_doc-line.doc-code = buf_trn-doc.doc-code
  :
      { str/is-petrl.i
          buf_doc-line.artic
          buf_doc-line.prod-type
          buf_doc-line.prod-code
          is-petrolium
          is-pieces
          no-error
      }
      if error-status :error or is-petrolium <> yes or is-pieces <> no then do: next _doc-line. end.
      find first buf_goods no-lock
        where buf_goods.artic     = buf_doc-line.artic
          and buf_goods.prod-type = buf_doc-line.prod-type
          and buf_goods.prod-code = buf_doc-line.prod-code
      no-error .
      if not available buf_goods then do:
        next _doc-line.
      end.
    for each buf_doc-line-attr no-lock
       where buf_doc-line-attr.doc-code = buf_trn-doc.doc-code
         and buf_doc-line-attr.gds-code = buf_goods.gds-code
    :
        case buf_doc-line-attr.attr-code:
          { rep/akt-topl.i when car-vol      }
          { rep/akt-topl.i when tank-density }
          { rep/akt-topl.i when tank-temp    }
          { rep/akt-topl.i when tank-vol     }
          { rep/akt-topl.i when time-pour    }
          { rep/akt-topl.i when mouth        }
          { rep/akt-topl.i when a-b-tarir    }
        end case.
    end. /* for each buf_doc-line-attr no-lock */
    
    for each buf_doc-attr no-lock where
             buf_doc-attr.doc-code = buf_trn-doc.doc-code:
      case buf_doc-attr.attr-code :
        { rep/akt-topl.i when-doc-attr trdcattr-autoent }
        { rep/akt-topl.i when-doc-attr trdcattr-car-num }
        { rep/akt-topl.i when-doc-attr trdcattr-time-income }
        { rep/akt-topl.i when-doc-attr trdcattr-ptb-item-pour }
        { rep/akt-topl.i when-doc-attr trdcattr-fio-driver }
      end case. /* buf_doc-attr.attr-code */
    end. /* for each buf_doc-attr */
    
    if v-time-pour <> "" then do:
      assign
        v-time-pour-int = integer(substring(v-time-pour, 1, 2)) * 3600 + integer(substring(v-time-pour, 4, 2)) * 60
      no-error .
      if error-status :error then do:
        assign
          v-time-pour-int = ?
        .
      end.
      assign
        v-head-time-pour-int  = if v-head-time-pour-int <> ? and v-time-pour-int <> ?
                                then minimum( v-head-time-pour-int , v-time-pour-int )
                                else v-time-pour-int
      .
    end.
    if v-time-income <> "" then do:
      assign
        v-time-income-int = integer(substring(v-time-income, 1, 2)) * 3600 + integer(substring(v-time-income, 4, 2)) * 60
      no-error .
      if error-status :error then do:
        assign
          v-time-income-int = ?
        .
      end.
      assign
        v-head-time-income-int =  if v-head-time-income-int <> ? and v-time-income-int <> ?
                                  then minimum( v-head-time-income-int , v-time-income-int )
                                  else v-time-income-int
      .
    end.
    if v-autoent-obj-type <> "" and v-autoent-obj-code <> "" then do:
      assign
        v-autoent-obj-code-int = integer( v-autoent-obj-code )
      .
      find first buf_clients no-lock
        where buf_clients.obj-type = v-autoent-obj-type
          and buf_clients.obj-code = v-autoent-obj-code-int
      no-error .
      if available buf_clients then do :
        assign
          v-head-autoent-obj-name = buf_clients.obj-name
        .
      end.
    end.

    &scop assign-attr assign ~
          v-~{&attr-name}~-dec = decimal(v-~{&attr-name}~) ~
        no-error. ~
        if error-status:error then do : ~
          assign ~
            v-~{&attr-name}~-dec = ? ~
          . ~
        end .

    &scop attr-name car-vol
    {&assign-attr}
    &scop attr-name tank-density
    {&assign-attr}
    &scop attr-name tank-temp
    {&assign-attr}
    &scop attr-name tank-vol
    {&assign-attr}
    &scop attr-name mouth
    {&assign-attr}
    &scop attr-name a-b-tarir
    {&assign-attr}

    create tt-report.
    assign
      tt-report.line-num  = buf_doc-line.line-num
      tt-report.gds-code  = buf_goods.gds-code
      tt-report.col-1     = string( v-head-doc-date ) + " " + buf_trn-doc.doc-code +
                            ( if v-fio <> "" then ", " + v-fio else "" )
      tt-report.col-2     = v-car-num
      tt-report.col-3     = buf_goods.gds-name
      tt-report.col-4     = string( buf_doc-line.doc-qnty , {&col-fmt-4} )
      tt-report.col-5     = string( buf_doc-line.cli-qnty , {&col-fmt-5} )

      tt-report.col-6     = if v-a-b-tarir-dec <> ?
                            then string( v-a-b-tarir-dec , {&col-fmt-6} )
                            else ""

      tt-report.col-7     = if v-mouth-dec <> ?
                            then string( v-mouth-dec , {&col-fmt-7} )
                            else ""
      tt-report.col-8     = if v-car-vol-dec  <> ?
                            then string( v-car-vol-dec , {&col-fmt-8} )
                            else ""
      tt-report.col-9     = if v-tank-vol-dec <> ?
                            then string( v-tank-vol-dec , {&col-fmt-9} )
                            else ""
      tt-report.col-10    = if v-tank-density-dec <> ?
                            then string( v-tank-density-dec , {&col-fmt-10} )
                            else ""
      tt-report.col-11    = if v-tank-temp-dec <> ?
                            then string( v-tank-temp-dec , {&col-fmt-11} )
                            else ""

      v-tmp-dec           = v-tank-vol-dec * v-tank-density-dec
      tt-report.col-12    = if v-tmp-dec <> ? then string( v-tmp-dec , {&col-fmt-12} ) else ""
      tt-report.col-13    = if v-tmp-dec <> ? then string( ( v-tmp-dec * 0.4 ) / 100 , {&col-fmt-13}) else ""

      v-tmp-dec           = ( ( buf_doc-line.cli-qnty - v-tmp-dec ) / buf_doc-line.cli-qnty ) * 100
      tt-report.col-14    = if v-tmp-dec <> ? then string( v-tmp-dec , {&col-fmt-14} ) else ""

      v-tmp-dec           = buf_doc-line.cli-qnty - v-tank-vol-dec * v-tank-density-dec
      tt-report.col-15    = if v-tmp-dec <> ? then string( v-tmp-dec , {&col-fmt-15} ) else ""

      v-tmp-dec           = v-tmp-dec / v-tank-density-dec
      tt-report.col-16    = if v-tmp-dec <> ? then string( v-tmp-dec , {&col-fmt-16} ) else ""

      v-tmp-dec           = buf_doc-line.doc-qnty - v-tmp-dec
      tt-report.col-17    = if v-tmp-dec <> ? then string( v-tmp-dec , {&col-fmt-17} ) else ""
    .
  end. /* _doc-line: */
  assign
    v-head-time-pour    = if v-head-time-income-int <> ? then string( v-head-time-income-int , "HH:MM" ) else ""
    v-head-time-income  = if v-head-time-pour-int   <> ? then string( v-head-time-pour-int   , "HH:MM" ) else ""
  .
end.

end procedure. /* fill-tt-report */

procedure hor-line :

do
on error undo, return error return-value
:
  put stream out-stream fill('-' , {&frame-width}) format "X({&frame-width})" skip.
end.

end procedure. /* hor-line */