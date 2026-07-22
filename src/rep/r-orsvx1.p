block-level on error undo, throw.
/*

$Revision: 0ec5d11e52eb, 2015, rls $
$Author: EShklyar $
$Date: Wed Sep 18 21:05:06 2019 +0300 $
$Workfile: r-orsvx1.p $
$Archive: rep/r-orsvx1.p $

Сличительная ведомость результатов инвентаризации нефтепродуктов (Орел)

Автор: Уханов Дмитрий Юрьевич
Дата создания: 09/28/06
Author: Dmitry Ukhanov
Creation date: 09/28/06

Автор1: Булгаков Андрей Николаевич
Дата создания1: 05/23/06

*/

define input parameter p-parent-proc as widget-handle no-undo .
define input parameter p-rec-invent  as recid         no-undo .

define variable vss-revision    as character no-undo initial "$Revision: 0ec5d11e52eb, 2015, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: Wed Sep 18 21:05:06 2019 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-orsvx1.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-orsvx1.p $":U .
define variable vss-description as character no-undo initial "Сличительная ведомость результатов инвентаризации нефтепродуктов (Орел)":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ cmp/r-pril.i   }
{ gbl/waitfram.i }

define variable g#report-num  as integer no-undo .
define variable g#quest-print as logical no-undo .
define variable g#log         as logical no-undo .

{ gbl/paramls.i  }
{ rep/r-orsvxl.i }
{ gbl/ptrlprop.i  def }

define variable v-host-name      as character no-undo .
define variable p-host-code      as integer   no-undo .
define variable v-unit-name      as character no-undo .
define variable v-doc-num        as character no-undo .
define variable dprice-sale      as decimal   no-undo .
define variable droad-tax        as decimal   no-undo .
define variable dexcise          as decimal   no-undo .
define variable dcurr-price      as decimal   no-undo .
define variable dExtra-qnty      as decimal   no-undo .
define variable dExtra-sum       as decimal   no-undo .
define variable dMiss-qnty       as decimal   no-undo .
define variable dMiss-sum        as decimal   no-undo .
define variable dLoss-curr-qnty  as decimal   no-undo .
define variable dLoss-qnty       as decimal   no-undo .
define variable dLoss-sum        as decimal   no-undo .
define variable dNorm-qnty       as decimal   no-undo .
define variable dNorm-sum        as decimal   no-undo .
define variable dXcalc-qnty      as decimal   no-undo .
define variable dXcalc-sum       as decimal   no-undo .
define variable dLcalc-qnty      as decimal   no-undo .
define variable dLcalc-sum       as decimal   no-undo .
define variable tExtra-qnty      as decimal   no-undo .
define variable tExtra-sum       as decimal   no-undo .
define variable tMiss-qnty       as decimal   no-undo .
define variable tMiss-sum        as decimal   no-undo .
define variable tLoss-qnty       as decimal   no-undo .
define variable tLoss-sum        as decimal   no-undo .
define variable tNorm-qnty       as decimal   no-undo .
define variable tNorm-sum        as decimal   no-undo .
define variable tXcalc-qnty      as decimal   no-undo .
define variable tXcalc-sum       as decimal   no-undo .
define variable tLcalc-qnty      as decimal   no-undo .
define variable tLcalc-sum       as decimal   no-undo .
define variable xExtra-qnty      as decimal   no-undo .
define variable xExtra-sum       as decimal   no-undo .
define variable xMiss-qnty       as decimal   no-undo .
define variable xMiss-sum        as decimal   no-undo .
define variable xLoss-qnty       as decimal   no-undo .
define variable xLoss-sum        as decimal   no-undo .
define variable xNorm-qnty       as decimal   no-undo .
define variable xNorm-sum        as decimal   no-undo .
define variable xXcalc-qnty      as decimal   no-undo .
define variable xXcalc-sum       as decimal   no-undo .
define variable xLcalc-qnty      as decimal   no-undo .
define variable xLcalc-sum       as decimal   no-undo .
define variable d_FactRest       as decimal   no-undo .
define variable d_BookRest       as decimal   no-undo .
define variable invent-fo        as decimal   no-undo .
define variable invent-end       as decimal   no-undo .
define variable t_inv-date       as date      no-undo .
define variable j_LineCount      as integer   no-undo .
define variable prc-density      as decimal   no-undo .
define variable v-qnty-type      as character no-undo .

define buffer bf_trn-doc      for ub.trn-doc  .
define buffer bf_doc-line-sum for ub.doc-line-sum .
define buffer bf_rvs-doc      for ub.rvs-doc  .
define buffer bf_rvs-line     for ub.rvs-line .
define buffer bf_goods        for ub.goods    .
define buffer bf_object       for ub.clients  .
define buffer bf_doc-line     for ub.doc-line .
define buffer bf_doc-pl       for ub.doc-pl .
define buffer bf_inv-line     for ub.inv-line .
define buffer bf_place        for ub.place    .

&scop ReportWidth 338
&scop f-l MonthNameRusCase,Sparse

{ gbl/std-func.i {&f-l} }

function OutDec returns character ( input p-sum  as decimal
                                  , input p-hide as logical ) :
  define variable v-sum as character no-undo .

  run dec2char in this-procedure
    (  input p-sum
    ,  input p-hide
    , output v-sum
    ) no-error.
  return ( if error-status :error then '':U else v-sum ) .
end function. /* OutDec */

function CenterLine returns character ( input p-in-string as character
                                      , input p-rep-width as integer ) :
  define variable v-out-string as character no-undo .

  run get-center-line in this-procedure
    (  input p-in-string
    ,  input p-rep-width
    , output v-out-string
    ) no-error .
  return ( if error-status :error then '':U else v-out-string ) .
end function. /* CenterLine */

function OutQty returns character ( input p-qty  as decimal
                                  , input p-hide as logical ) :
  define variable v-qty as character no-undo .

  run get-dec-string in this-procedure
    (  input p-qty
    ,  input 3
    ,  input p-hide
    , output v-qty
    ) no-error.
  return ( if error-status :error then '':U else v-qty ) .
end function. /* OutQty */

function OutSum returns character ( input p-sum  as decimal
                                  , input p-hide as logical ) :
  define variable v-sum as character no-undo .

  run get-dec-string in this-procedure
    (  input p-sum
    ,  input 2
    ,  input p-hide
    , output v-sum
    ) no-error.
  return ( if error-status :error then '':U else v-sum ) .
end function. /* OutSum */

define stream s-out .

do
on error undo, return error return-value
:
  run WaitFram-Show in this-procedure
    ( input 'Идет формирование отчета, ждите...'
    ) .
  {&SetCursorWait}
  run get-report-num  in p-parent-proc
    (
      output g#report-num
    ) .
  run get-quest-print in p-parent-proc
    (
      output g#quest-print
    ) .
  find first bf_trn-doc no-lock where
      recid( bf_trn-doc ) = p-rec-invent no-error .
  if not available bf_trn-doc
  then do:
    {&SetCursorNo}
    run waitfram-hide in this-procedure .
    message substitute( 'Не найден документ с идентификатором &1.'
                      , p-rec-invent
                      )
    view-as alert-box error .
    undo, return error .
  end.
  if bf_trn-doc.doc-type     <> {&inventory} or
     bf_trn-doc.ext-doc-type <> {&TDEDT_Inv}
  then do:
    {&SetCursorNo}
    run waitfram-hide in this-procedure .
    message
      'Данная форма только для печати инвентаризации.'
    view-as alert-box error .
    undo, return error .
  end.
  /*
  if bf_trn-doc.status_ <> {&fact}
  then do:
    {&SetCursorNo}
    run waitfram-hide in this-procedure .
    message
      'Документ должен быть закрыт на ФАКТ.'
    view-as alert-box error .
    undo, return error .
  end.
  */
  find first bf_rvs-doc no-lock where
             bf_rvs-doc.rvs-code = bf_trn-doc.out-code no-error .
  if not available bf_rvs-doc
  then do:
    {&SetCursorNo}
    run waitfram-hide in this-procedure .
    message substitute( 'Не найдена сверка к документу "&1".'
                      , bf_trn-doc.doc-code
                      )
    view-as alert-box error .
    undo, return error .
  end.
  if bf_rvs-doc.rvs-type <> {&rvs-control}
  then do:
    {&SetCursorNo}
    run waitfram-hide in this-procedure .
    message substitute( 'Сверка имеет тип "&1", а должен быть "&2".'
                      , bf_rvs-doc.rvs-type
                      , {&rvs-control}
                      )
    view-as alert-box error .
    undo, return error .
  end.
  /*
  if bf_rvs-doc.is-full <> yes
  then do:
    {&SetCursorNo}
    run waitfram-hide in this-procedure .
    message
      'Контрольная сверка должна быть ПОЛНОЙ.'
    view-as alert-box error .
    undo, return error .
  end.
  if bf_rvs-doc.status_ <> {&fact}
  then do:
    {&SetCursorNo}
    run waitfram-hide in this-procedure .
    message
      'Документ сверки должен быть закрыт на ФАКТ.'
    view-as alert-box error .
    undo, return error .
  end.
  */
  find first bf_object no-lock where
             bf_object.obj-type = bf_trn-doc.obj-type and
             bf_object.obj-code = bf_trn-doc.obj-code .
  { gbl/hostname.i
      bf_trn-doc.obj-type
      bf_trn-doc.obj-code
      p-host-code
      v-host-name
      no-error
  }
  if error-status :error
  then do:
    {&SetCursorNo}
    run waitfram-hide in this-procedure .
    message
      'Не могу определить текущую фирму.'
    view-as alert-box error .
    undo, return error .
  end.
  if bf_trn-doc.host-code <> p-host-code
  then do:
    {&SetCursorNo}
    run waitfram-hide in this-procedure .
    message
      'Ошибка определения текущей фирмы.'
    view-as alert-box error .
    undo, return error .
  end.

  { gbl/ptrlprop.i
    run
    bf_trn-doc.obj-type
    bf_trn-doc.obj-code
  }

  assign
    t_inv-date = ( if bf_trn-doc.status_ = {&fact} then bf_trn-doc.fact-date else bf_trn-doc.doc-date )
  .

  { cmp/open-out.i stream s-out " " {&LS_PS_A4} }
  put stream s-out unformatted
    'Госкомнефтепродукт_________________________________                                                                                                                                                                                                                                                                             Форма № 33-НП' skip
    substring( string( v-host-name + fill( '_', 40 ), "x(40)":U ), 1, 40 ) +
                                            ' управление                                                                                                                                                                                                                                                      Утверждена Госкомнефтепродуктом СССР' skip
    '________________________________________ нефтебаза                                                                                                                                                                                                                                                          15 августа 1985 г. № 06/21-8  446' skip
    substring( trim( string( bf_object.obj-name , "x(40)":U ) ) + fill( '_', 32 ), 1, 32 )                                                                                                                                                                                                                                         skip( 2 )
    CenterLine( Sparse( 'СЛИЧИТЕЛЬНАЯ ВЕДОМОСТЬ' ), {&ReportWidth} )                                                                                                                                                                                                                                                                                skip
    CenterLine( 'результатов инвентаризации нефтепродуктов', {&ReportWidth} )                                                                                                                                                                                                                                                                       skip
    CenterLine( substitute( 'на "&1" &2 &3 г.'
                          , day( t_inv-date )
                          , MonthNameRusCase( month( t_inv-date ), 2 )
                          , year( t_inv-date )
                          )
              , {&ReportWidth}
              )                                                                                                                                                                                                                                                                                                                                     skip
    CenterLine( 'На основании распоряжения № ___ от "___"______________20__г. проведена инвентаризация фактического наличия,', {&ReportWidth} )                                                                                                                                                                                                     skip
    CenterLine( ' находящихся на ответственном хранении у _______________________________________________________________', {&ReportWidth} )                                                                                                                                                                                                        skip
    CenterLine( '                                          (должность)                                  (фамилия, и.,о.) ', {&ReportWidth} )                                                                                                                                                                                                        skip
    CenterLine( 'Снятие остатков: начато "____"____________20___г. и окончено "___"________20__г. При инвентаризации установлено следущее:', {&ReportWidth} )                                                                                                                                                                                       skip( 1 )
  .
  put stream s-out unformatted
    '--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------' skip
    '   :               :       :           :     :        :         Результаты инвентаризации            :                                      Пересортица                                      :      Отклонение с учетом пересортицы      :                    :     Учитывается     :                                      :                      ' skip
    '   :               :       :  Тип и №  : Ед. :  Цена  :---------------------:------------------------:-------------------------------------------:-------------------------------------------:---------------------:---------------------: Естественная убыль : недостача в пределах:       Приходуются окончательные      :     Окончательные    ' skip
    ' № :  Наименование :  Код  :   резер-  :изме-:   за   :       излишек       :        недостач        :   излишки, зачтенные в покрытии недостач  :      недостачи, покрытытые излишками      :       излишек       :       недостач      :                    :норм погр. изм. массы:                излишки               :       недостачи      ' skip
    'п/п: нефтепродукта :       :   вуара   :рения:  ед-цу :------------:--------:------------:-----------:------------:--------:---------------------:------------:--------:---------------------:------------:--------:------------:--------:------------:-------:------------:--------:------------:---------:---------------:------------:---------' skip
    '   :               :       :           :     :        : количество :  сумма : количество :   сумма   : количество :  сумма :пор.№ зачтен.недостач: количество :  сумма :пор.№ зачтен.недостач: количество :  сумма : количество :  сумма : количество : сумма : количество :  сумма : количество :  сумма  :на баланс счет№: количество :  сумма  ' skip
    '---:---------------:-------:-----------:-----:--------:------------:--------:------------:-----------:------------:--------:---------------------:------------:--------:---------------------:------------:--------:------------:--------:------------:-------:------------:--------:------------:---------:---------------:------------:---------' skip
    ' 1 :       2       :   3   :     4     :  5  :    6   :      7     :    8   :      9     :    10     :     11     :   12   :          13         :     14     :   15   :          16         :     17     :   18   :     19     :   20   :     21     :   22  :     23     :   24   :     25     :    26   :       27      :     28     :    29   ' skip
    '---:---------------:-------:-----------:-----:--------:------------:--------:------------:-----------:------------:--------:---------------------:------------:--------:---------------------:------------:--------:------------:--------:------------:-------:------------:--------:------------:---------:---------------:------------:---------' skip
  .

  run r-orsvxl-init            in this-procedure .
  run r-orsvxl-write-cell-data in this-procedure
    ( input {&r-orsvxl-h_OwnFirm}
    , input ( trim( v-host-name ) + " ":U + "управление" )
    ) .
  run r-orsvxl-write-cell-data in this-procedure
    ( input {&r-orsvxl-h_objcode}
    , input trim( string( bf_object.obj-name, "x(40)":U ) )
    ) .
  run r-orsvxl-write-cell-data in this-procedure
    ( input {&r-orsvxl-h_FactDate}
    , input substitute( 'на "&1" &2 &3 г.'
                      , day( t_inv-date )
                      , MonthNameRusCase( month( t_inv-date ), 2 )
                      , year( t_inv-date )
                      )
    ) .

  assign
    tExtra-qnty = 0.00
    tExtra-sum  = 0.00
    tMiss-qnty  = 0.00
    tMiss-sum   = 0.00
    tLoss-qnty  = 0.00
    tLoss-sum   = 0.00
    tNorm-qnty  = 0.00
    tNorm-sum   = 0.00
    tXcalc-qnty = 0.00
    tXcalc-sum  = 0.00
    tLcalc-qnty = 0.00
    tLcalc-sum  = 0.00
    j_LineCount = 0
  .
  for each  bf_rvs-line no-lock where
            bf_rvs-line.rvs-code = bf_rvs-doc.rvs-code  and
            bf_rvs-line.obj-type = bf_rvs-doc.obj-type  and
            bf_rvs-line.obj-code = bf_rvs-doc.obj-code
    , first bf_goods    no-lock where
            bf_goods.gds-code    = bf_rvs-line.gds-code
   break by bf_rvs-line.gds-code
         by bf_rvs-line.pl-code
  :
    if first-of( bf_rvs-line.gds-code )
    then do:
      { gbl/bcodeprc.i
          bf_rvs-line.obj-type
          bf_rvs-line.obj-code
          bf_rvs-line.gds-code
          0
          bf_trn-doc.fact-order
          v-doc-num
          dprice-sale
          droad-tax
          dexcise
          no-error
      }
      if error-status :error
      then do:
        {&SetCursorNo}
        run waitfram-hide in this-procedure .
        message
          'Не могу определить текущие продажные цены.'
        view-as alert-box error .
        undo, return error .
      end.
    end. /* if first-of( bf_rvs-line.gds-code ) */

    /* **************************************************************************************** *\
     *                                                                                          *
     * state-measure- (state-measure-qnty, state-measure-cli-qnty) - фактический отстаток;      *
     * system-        (system-qnty,        system-cli-qnty)        - расчетно-книжный остаток; *
     *                                                                                          *
    \* **************************************************************************************** */

    if ptrlprop-expptrl = {&calc-petrol-volume} then do:
      assign
        v-qnty-type = "base":U
        v-unit-name = trim( bf_goods.unit-base )
        dcurr-price = dprice-sale
        d_FactRest  = bf_rvs-line.state-measure-qnty + bf_rvs-line.state-add-qnty
        d_BookRest  = bf_rvs-line.system-qnty
      .
    end.
    else do:
      assign
        v-qnty-type = "cli":U
        v-unit-name = trim( bf_goods.unit-cli )
        d_FactRest  = bf_rvs-line.state-measure-cli-qnty + bf_rvs-line.state-add-qnty * bf_rvs-line.state-density
        d_BookRest  = bf_rvs-line.system-cli-qnty
      .
      assign /* суммы рассчитываются исходя из плотности сверки (Булгаков) */
        prc-density = bf_rvs-line.state-density
      .

/*      assign /* суммы рассчитываются исходя из соотношения р-к и ф остатков в кг и л (Суслов) */*/
/*        d_temp      = d_FactRest - d_BookRest*/
/*        d_temp1     = bf_rvs-line.state-measure-qnty     + bf_rvs-line.state-add-qnty - bf_rvs-line.system-qnty*/
/*        prc-density = d_temp / d_temp1*/
/*      .*/

      assign
        dcurr-price = dprice-sale / prc-density
      .
    end.

    assign
      dNorm-qnty = 0.0
      dLoss-qnty = 0.0
    .
    find first bf_doc-line-sum no-lock
      where bf_doc-line-sum.doc-code  = bf_trn-doc.doc-code
        and bf_doc-line-sum.gds-code  = bf_rvs-line.gds-code
        and bf_doc-line-sum.sum-type  = substitute( "&1&2&3&2&4", "mterr":U, {&delim-par}, v-qnty-type, bf_rvs-line.pl-code )
      no-error .
    if available bf_doc-line-sum then do:
      assign
        dNorm-qnty = bf_doc-line-sum.fact-qnty
      .
    end.
    find first bf_doc-line-sum no-lock
      where bf_doc-line-sum.doc-code  = bf_trn-doc.doc-code
        and bf_doc-line-sum.gds-code  = bf_rvs-line.gds-code
        and bf_doc-line-sum.sum-type  = substitute( "&1&2&3&2&4", {&sum-wastage-doc}, {&delim-par}, v-qnty-type, bf_rvs-line.pl-code )
      no-error .
    if available bf_doc-line-sum then do:
      assign
        dLoss-qnty = bf_doc-line-sum.fact-qnty
      .
    end.



    assign
      dExtra-qnty = ( if d_FactRest > d_BookRest then ( d_FactRest - d_BookRest ) else 0.00 )
      dMiss-qnty  = ( if d_FactRest < d_BookRest then ( d_BookRest - d_FactRest ) else 0.00 )
      dXcalc-qnty = ( if dExtra-qnty > dNorm-qnty then dExtra-qnty - dNorm-qnty else 0.00 )
      dLcalc-qnty = ( if dMiss-qnty  > dLoss-qnty + dNorm-qnty then dMiss-qnty - ( dLoss-qnty + dNorm-qnty ) else 0.00 )
    .
    if dLcalc-qnty < 0.001 then assign dNorm-qnty  = dNorm-qnty + dLcalc-qnty
                                       dLcalc-qnty = 0.
    /*Поля обрезаются до 3 знаков после запятой, 
    но при перемножении 2х чисел с 3 знаками после запятой получится число с 6 знаками.
    Поэтому эту малую разницу приплюсовываем как погрешность к Norm-qnty и обнуляем.*/
    
    assign
      dExtra-sum = dExtra-qnty * dcurr-price
      dMiss-sum  = dMiss-qnty  * dcurr-price
      dLoss-sum  = dLoss-qnty  * dcurr-price
      dNorm-sum  = dNorm-qnty  * dcurr-price
      dXcalc-sum = dXcalc-qnty * dcurr-price
      dLcalc-sum = dLcalc-qnty * dcurr-price
    .
    find first bf_place no-lock where
               bf_place.obj-type = bf_rvs-line.obj-type and
               bf_place.obj-code = bf_rvs-line.obj-code and
               bf_place.pl-code  = bf_rvs-line.pl-code  .
    assign
      j_LineCount = j_LineCount + 1
    .
    put stream s-out unformatted
      string( string( j_LineCount,         ">9":U ),        "x(3)":U  ) + ":" + /*  1 */
      string( bf_goods.gds-name,                            "x(15)":U ) + ":" + /*  2 */
      string( bf_goods.artic,                               "x(7)":U  ) + ":" + /*  3 */
      string( string( bf_rvs-line.pl-code, ">>>>>>>>>>9":U ), "x(11)":U  ) + ":" + /*  4 */
      string( ' ':U + v-unit-name + ' ':U,                  "x(5)":U  ) + ":" + /*  5 */
      string( OutSum( dcurr-price, no  ),                   "x(8)":U  ) + ":" + /*  6 */
      string( OutQty( dExtra-qnty, yes ),                   "x(12)":U ) + ":" + /*  7 */
      string( OutSum( dExtra-sum,  yes ),                   "x(8)":U  ) + ":" + /*  8 */
      string( OutQty( dMiss-qnty,  yes ),                   "x(12)":U ) + ":" + /*  9 */
      string( OutSum( dMiss-sum,   yes ),                   "x(11)":U  ) + ":" + /* 10 */
      '            :        :                     :            :        :                     :            :        :            :        :' +
      string( OutQty( dLoss-qnty,  yes ),                   "x(12)":U ) + ":" + /* 21 */
      string( OutSum( dLoss-sum,   yes ),                   "x(7)":U  ) + ":" + /* 22 */
      string( OutQty( dNorm-qnty,  yes ),                   "x(12)":U ) + ":" + /* 23 */
      string( OutSum( dNorm-sum,   yes ),                   "x(8)":U  ) + ":" + /* 24 */
      string( OutQty( dXcalc-qnty, yes ),                   "x(12)":U ) + ":" + /* 25 */
      string( OutSum( dXcalc-sum,  yes ),                   "x(9)":U  ) + ":" + /* 26 */
      '               :' +
      string( OutQty( dLcalc-qnty, yes ),                   "x(12)":U ) + ":" + /* 28 */
      string( OutSum( dLcalc-sum,  yes ),                   "x(9)":U  ) skip    /* 29 */
    .
    run r-orsvxl-write-line-data in this-procedure
      (
        input j_LineCount                                                       /*  1 */
      , input bf_goods.gds-name                                                 /*  2 */
      , input bf_goods.artic                                                    /*  3 */
      , input trim( string( bf_rvs-line.pl-code, ">>>>>>>>>>>9":U ) )             /*  4 */
      , input v-unit-name                                                       /*  5 */
      , input OutDec( dcurr-price, no  )                                        /*  6 */
      , input OutDec( dExtra-qnty, yes )                                        /*  7 */
      , input OutDec( dExtra-sum,  yes )                                        /*  8 */
      , input OutDec( dMiss-qnty,  yes )                                        /*  9 */
      , input OutDec( dMiss-sum,   yes )                                        /* 10 */
      , input OutDec( dLoss-qnty,  yes )                                        /* 21 */
      , input OutDec( dLoss-sum,   yes )                                        /* 22 */
      , input OutDec( dNorm-qnty,  yes )                                        /* 23 */
      , input OutDec( dNorm-sum,   yes )                                        /* 24 */
      , input OutDec( dXcalc-qnty, yes )                                        /* 25 */
      , input OutDec( dXcalc-sum,  yes )                                        /* 26 */
      , input OutDec( dLcalc-qnty, yes )                                        /* 28 */
      , input OutDec( dLcalc-sum,  yes )                                        /* 29 */
    ) .
    assign
      tExtra-qnty = tExtra-qnty + dExtra-qnty
      tExtra-sum  = tExtra-sum  + dExtra-sum
      tMiss-qnty  = tMiss-qnty  + dMiss-qnty
      tMiss-sum   = tMiss-sum   + dMiss-sum
      tLoss-qnty  = tLoss-qnty  + dLoss-qnty
      tLoss-sum   = tLoss-sum   + dLoss-sum
      tNorm-qnty  = tNorm-qnty  + dNorm-qnty
      tNorm-sum   = tNorm-sum   + dNorm-sum
      tXcalc-qnty = tXcalc-qnty + dXcalc-qnty
      tXcalc-sum  = tXcalc-sum  + dXcalc-sum
      tLcalc-qnty = tLcalc-qnty + dLcalc-qnty
      tLcalc-sum  = tLcalc-sum  + dLcalc-sum
    .
    assign
      xExtra-qnty = xExtra-qnty + dExtra-qnty
      xExtra-sum  = xExtra-sum  + dExtra-sum
      xMiss-qnty  = xMiss-qnty  + dMiss-qnty
      xMiss-sum   = xMiss-sum   + dMiss-sum
      xLoss-qnty  = xLoss-qnty  + dLoss-qnty
      xLoss-sum   = xLoss-sum   + dLoss-sum
      xNorm-qnty  = xNorm-qnty  + dNorm-qnty
      xNorm-sum   = xNorm-sum   + dNorm-sum
      xXcalc-qnty = xXcalc-qnty + dXcalc-qnty
      xXcalc-sum  = xXcalc-sum  + dXcalc-sum
      xLcalc-qnty = xLcalc-qnty + dLcalc-qnty
      xLcalc-sum  = xLcalc-sum  + dLcalc-sum
    .
  end. /* for each bf_rvs-line */
  put stream s-out unformatted
    '--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------' skip
    '   : ИТОГО:        :           :       :     :        :' +
    string( OutQty( xExtra-qnty, yes ), "x(12)":U ) + ":" +
    string( OutSum( xExtra-sum,  yes ), "x(8)":U  ) + ":" +
    string( OutQty( xMiss-qnty,  yes ), "x(12)":U ) + ":" +
    string( OutSum( xMiss-sum,   yes ), "x(11)":U  ) + ":" +
    '            :        :                     :            :        :                     :            :        :            :        :' +
    string( OutQty( xLoss-qnty,  yes ), "x(12)":U ) + ":" +
    string( OutSum( xLoss-sum,   yes ), "x(7)":U  ) + ":" +
    string( OutQty( xNorm-qnty,  yes ), "x(12)":U ) + ":" +
    string( OutSum( xNorm-sum,   yes ), "x(8)":U  ) + ":" +
    string( OutQty( xXcalc-qnty, yes ), "x(12)":U ) + ":" +
    string( OutSum( xXcalc-sum,  yes ), "x(9)":U  ) + ":" +
      '               :' +
    string( OutQty( xLcalc-qnty, yes ), "x(12)":U ) + ":" +
    string( OutSum( xLcalc-sum,  yes ), "x(9)":U  )                                                                                                                                                                                                                                                                                                 skip
    '--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------' skip( 2 )
  .
  run r-orsvxl-write-cell-data in this-procedure
    ( input {&r-orsvxl-it_ExtraQnty}
    , input OutDec( tExtra-qnty, yes )
    ) .
  run r-orsvxl-write-cell-data in this-procedure
    ( input {&r-orsvxl-it_ExtraSum}
    , input OutDec( tExtra-sum,  yes )
    ) .
  run r-orsvxl-write-cell-data in this-procedure
    ( input {&r-orsvxl-it_MissQnty}
    , input OutDec( tMiss-qnty,  yes )
    ) .
  run r-orsvxl-write-cell-data in this-procedure
    ( input {&r-orsvxl-it_MissSum}
    , input OutDec( tMiss-sum,   yes )
    ) .
  run r-orsvxl-write-cell-data in this-procedure
    ( input {&r-orsvxl-it_LossQnty}
    , input OutDec( tLoss-qnty,  yes )
    ) .
  run r-orsvxl-write-cell-data in this-procedure
    ( input {&r-orsvxl-it_LossSum}
    , input OutDec( tLoss-sum,   yes )
    ) .
  run r-orsvxl-write-cell-data in this-procedure
    ( input {&r-orsvxl-it_NormQnty}
    , input OutDec( tNorm-qnty,  yes )
    ) .
  run r-orsvxl-write-cell-data in this-procedure
    ( input {&r-orsvxl-it_NormSum}
    , input OutDec( tNorm-sum,   yes )
    ) .
  run r-orsvxl-write-cell-data in this-procedure
    ( input {&r-orsvxl-it_XcalcQnty}
    , input OutDec( tXcalc-qnty, yes )
    ) .
  run r-orsvxl-write-cell-data in this-procedure
    ( input {&r-orsvxl-it_XcalcSum}
    , input OutDec( tXcalc-sum,  yes )
    ) .
  run r-orsvxl-write-cell-data in this-procedure
    ( input {&r-orsvxl-it_LcalcQnty}
    , input OutDec( tLcalc-qnty, yes )
    ) .
  run r-orsvxl-write-cell-data in this-procedure
    ( input {&r-orsvxl-it_LcalcSum}
    , input OutDec( tLcalc-sum,  yes )
    ) .

  put stream s-out unformatted
    '                            '
    'Бухгалтер ______________________________'
    '                                                                                                                   '
    'С результатами сличения ознакомлен ___________________________________________________________' skip
    '                            '
    '           (подпись)                    '
    '                                                                                                                   '
    '                                    (подпись)'                                                  skip
  .
  run waitfram-hide  in this-procedure .
  run r-orsvxl-close in this-procedure .
  output stream s-out close .
  {&SetCursorNo}
  { rep/q-print.i 2 }
end. /* on error */

procedure dec2char :
  define  input parameter p-dec  as decimal   no-undo .
  define  input parameter p-hide as logical   no-undo .
  define output parameter p-char as character no-undo .

  do
  on error undo, return error return-value
  :
    if p-dec  = ?
    then do:
      assign
        p-char = "":U
      .
    end.
    else
    if p-dec  = 0.00 and
       p-hide = yes
    then do:
      assign
        p-char = "":U
      .
    end.
    else do:
      assign
        p-char = trim( string( p-dec,  "->>>>>>>>>>>>>9.9<<<<<<<<<":U ) )
      .
    end.
  end. /* on error */
end procedure. /* dec2char */

procedure get-center-line :
  define  input parameter p-in-string  as character no-undo .
  define  input parameter p-rep-width  as integer   no-undo .
  define output parameter p-out-string as character no-undo .

  do
  on error undo, return error return-value
  :
    if length( p-in-string ) < p-rep-width
    then do:
      assign
        p-out-string = fill( ' ':U, integer( ( p-rep-width - length( p-in-string ) ) * 0.5 ) ) + p-in-string
      .
    end.
    else do:
      assign
        p-out-string = p-in-string
      .
    end.
  end. /* on error */
end procedure. /* get-center-line */

procedure get-dec-string :
  define  input parameter p-dec  as decimal   no-undo .
  define  input parameter p-int  as integer   no-undo .
  define  input parameter p-hide as logical   no-undo .
  define output parameter p-char as character no-undo .

  do
  on error undo, return error return-value
  :
    if p-dec  = ?
    then do:
      assign
        p-char = "":U
      .
    end.
    else
    if p-dec  = 0.00 and
       p-hide = yes
    then do:
      assign
        p-char = "":U
      .
    end.
    else do:
      if p-int = 3
      then do:
        assign
          p-char = trim( string( p-dec, "->>>>>>9.999":U ) )
          p-char = fill( ' ':U, 12 - length( p-char ) ) + p-char
        .
      end.
      else do:
        assign
          p-char = trim( string( p-dec, "->>>>>>9.99":U ) )
          p-char = fill( ' ':U,  8 - length( p-char ) ) + p-char
        .
      end.
    end.
  end. /* on error */
end procedure. /* get-dec-string */