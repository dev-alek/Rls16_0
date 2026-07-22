block-level on error undo, throw.
/*

$Revision: 0ec5d11e52eb, 2015, rls $
$Author: EShklyar $
$Date: Wed Sep 18 21:05:06 2019 +0300 $
$Workfile: r-orioxl.p $
$Archive: rep/r-orioxl.p $

Инвентаризационная описись нефтепродуктов (Орел)

Автор: Уханов Дмитрий Юрьевич
Дата создания: 10/06/06
Author: Dmitry Ukhanov
Creation date: 10/06/06

create: Булгаков Андрей Николаевич
Дата создания: 05/23/06

*/

define input parameter p-parent-proc as widget-handle no-undo .
define input parameter p-rec-invent  as recid         no-undo .


define variable vss-revision    as character no-undo initial "$Revision: 0ec5d11e52eb, 2015, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: Wed Sep 18 21:05:06 2019 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-orioxl.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-orioxl.p $":U .
define variable vss-description as character no-undo initial "Инвентаризационная описись нефтепродуктов (Орел)":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-calc.i }
{ str/lib-trn.i  }
{ cmp/r-pril.i   }
{ gbl/waitfram.i }

define variable g#report-num  as integer no-undo .
define variable g#quest-print as logical no-undo initial yes .
define variable g#log         as logical no-undo .

{ gbl/paramls.i  }
{ rep/r-orioxl.i }

define variable v-host-name   as character no-undo .
define variable p-host-code   as integer   no-undo .
define variable v-doc-num     as character no-undo .
define variable dprice-sale   as decimal   no-undo .
define variable droad-tax     as decimal   no-undo .
define variable dexcise       as decimal   no-undo .
define variable dcurr-price   as decimal   no-undo .
define variable dWaterQnty    as decimal   no-undo .
define variable dWaterCliQnty as decimal   no-undo .
define variable dAddCliQnty   as decimal   no-undo .
define variable dOverCliQnty  as decimal   no-undo .
define variable dOverSum      as decimal   no-undo .
define variable dBookSum      as decimal   no-undo .
define variable dExtraQnty    as decimal   no-undo .
define variable dExtraSum     as decimal   no-undo .
define variable dMissQnty     as decimal   no-undo .
define variable dMissSum      as decimal   no-undo .
define variable t_inv-date    as date      no-undo .
define variable j_LineCount   as integer   no-undo .

define buffer bf_trn-doc  for ub.trn-doc  .
define buffer bf_rvs-doc  for ub.rvs-doc  .
define buffer bf_rvs-line for ub.rvs-line .
define buffer bf_goods    for ub.goods    .
define buffer bf_object   for ub.clients  .
define buffer bf_place    for ub.place    .

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
    ,  input 12
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
    ,  input 8
    ,  input p-hide
    , output v-sum
    ) no-error.
  return ( if error-status :error then '':U else v-sum ) .
end function. /* OutSum */

function OutLvl returns character ( input p-lvl  as decimal
                                  , input p-hide as logical ) :
  define variable v-lvl as character no-undo .

  run get-dec-string in this-procedure
    (  input p-lvl
    ,  input 11
    ,  input p-hide
    , output v-lvl
    ) no-error.
  return ( if error-status :error then '':U else v-lvl ) .
end function. /* OutLvl */

function OutDty returns character ( input p-dnst as decimal
                                  , input p-hide as logical ) :
  define variable v-dnst as character no-undo .

  run get-dec-string in this-procedure
    (  input p-dnst
    ,  input 10
    ,  input p-hide
    , output v-dnst
    ) no-error.
  return ( if error-status :error then '':U else v-dnst ) .
end function. /* OutDty */

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
  assign
    t_inv-date = ( if bf_trn-doc.status_ = {&fact} then bf_trn-doc.fact-date else bf_trn-doc.doc-date )
  .

  { cmp/open-out.i stream s-out " " {&LS_PS_A4} }
  put    stream s-out unformatted
    'Госкомнефтепродукт_________________________________                                                                                                                                                                                                                                                                                Форма № 32-НП' skip
    substring( string( v-host-name + fill( '_', 40 ), "x(40)":U ), 1, 40 ) +
                                            ' управление                                                                                                                                                                                                                                                         Утверждена Госкомнефтепродуктом СССР' skip
    '________________________________________ нефтебаза                                                                                                                                                                                                                                                              15 августа 1985 г. № 06/21-8-446' skip
     substring( trim( string( bf_object.obj-name , "x(40)":U) )  + fill( '_', 32 ), 1, 32 )                                                                                                                                                                                                                                             skip( 2 )
    CenterLine( Sparse( 'ИНВЕНТАРИЗАЦИОННАЯ ОПИСЬ НЕФТИ И НЕФТЕПРОДУКТОВ' ), {&ReportWidth} )                                                                                                                                                                                                                                                          skip
    CenterLine( substitute( '№ &1 от "&2" &3 &4 г.'
                          , trim( bf_trn-doc.doc-code )
                          , day( t_inv-date )
                          , MonthNameRusCase( month( t_inv-date ), 2 )
                          , year( t_inv-date )
                          )
              , {&ReportWidth}
              )                                                                                                                                                                                                                                                                                                                                        skip( 1 )
  .
  put stream s-out unformatted
    'Расписка.'                                                                                                                                                                                                                                                                                                                                        skip
    {&tabulation}
    'К началу проведения инвентаризации все приходные и расходные документы на товарно-материальные ценности включены в отчеты (реестры), сданы в бухгалтерию и все ценности, поступившие на мою (нашу) ответственность, оприходованы, а выбывшие списаны в расход.'                                                                                   skip
    'Остатки на момент инвентаризации по данным моего (нашего) отчета составляют:'                                                                                                                                                                                                                                                                     skip
    'нефти и нефтепродуктов на _______________________________________________________________________________________ {&abbr_rub}. ____________________ {&abbr_kop}.'                                                                                                                                                                                                 skip
    '                              (прописью)'                                                                                                                                                                                                                                                                                                         skip
    'тары на ________________________________________________________________________________________________________ {&abbr_rub}. ____________________ {&abbr_kop}.'                                                                                                                                                                                                  skip
    '            (прописью)'                                                                                                                                                                                                                                                                                                                           skip
    'наличных денег на _______________________________________________________________________________________________ {&abbr_rub}. ____________________ {&abbr_kop}.'                                                                                                                                                                                                 skip
    '                      (прописью)'                                                                                                                                                                                                                                                                                                                 skip
    'отоваренных и погашаенных: единых талонов на _____________________________________________________________________ {&abbr_rub}. ____________________ {&abbr_kop}.'                                                                                                                                                                                                skip
    '                                                 (прописью)'                                                                                                                                                                                                                                                                                      skip
    {&tabulation}
    'талонов рыночного фонда на _________________________________________________________________________________ {&abbr_rub}. ____________________ {&abbr_kop}.'                                                                                                                                                                                                      skip
    {&tabulation}
    '                               (прописью)'                                                                                                                                                                                                                                                                                                        skip
    'нереализованных (неиспользованных) талонов: ______________________________________________________________________ {&abbr_rub}. ____________________ {&abbr_kop}.'                                                                                                                                                                                                skip
    '                                                (прописью)'                                                                                                                                                                                                                                                                                       skip
    {&tabulation}
    'рыночного фонда на _________________________________________________________________________________________ {&abbr_rub}. ____________________ {&abbr_kop}.'                                                                                                                                                                                                      skip
    {&tabulation}
    '                       (прописью)'                                                                                                                                                                                                                                                                                                                skip
    'единых (полученных для "сдачи") на ________________________________________________________________________________ {&abbr_rub}. ____________________ {&abbr_kop}.'                                                                                                                                                                                               skip
    '                                       (прописью)'                                                                                                                                                                                                                                                                                                skip
    'Материально ответственные(ое) лица (лицо) _______________________________________________________________        ___________________________________________________________        ______________________________________________________________________'                                                                                       skip
    '                                           (подпись)                             (фамили, имя, отчество)          (подпись)                         (фамили, имя, отчество)          (подпись)                                    (фамили, имя, отчество)'                                                                                        skip
    'На основании распоряжения от "_____" _______________ 20____ г. № __________ произведено снятие фактических остатков нефтепродуктов, денежных средств, талонов по состоянию на "_____" _______________ 20____ г.'                                                                                                                                  skip
    'Инвентаризация начата "_____" ______________ 20 _____ г. в _____ час. _____ мин. и окончена "_____" ______________ 20 _____ г. в _____ час. _____ мин.'                                                                                                                                                                                           skip
    {&tabulation}
    'При инвентаризации установлено следующее:'                                                                                                                                                                                                                                                                                                        skip
    'нефтепродуктов на _______________________________________________________________________________________ {&abbr_rub}. ____________________ {&abbr_kop}.'                                                                                                                                                                                                         skip
    '                      (прописью)'                                                                                                                                                                                                                                                                                                                 skip
    'тары на ________________________________________________________________________________________________________ {&abbr_rub}. ____________________ {&abbr_kop}.'                                                                                                                                                                                                  skip
    '            (прописью)'                                                                                                                                                                                                                                                                                                                           skip
    'наличных денег на _______________________________________________________________________________________________ {&abbr_rub}. ____________________ {&abbr_kop}.'                                                                                                                                                                                                 skip
    '                      (прописью)'                                                                                                                                                                                                                                                                                                                 skip
    'отоваренных и погашаенных: единых талонов на _____________________________________________________________________ {&abbr_rub}. ____________________ {&abbr_kop}.'                                                                                                                                                                                                skip
    '                                                 (прописью)'                                                                                                                                                                                                                                                                                      skip
    {&tabulation}
    'талонов рыночного фонда на _________________________________________________________________________________ {&abbr_rub}. ____________________ {&abbr_kop}.'                                                                                                                                                                                                      skip
    {&tabulation}
    '                               (прописью)'                                                                                                                                                                                                                                                                                                        skip
    'нереализованных (неиспользованных) талонов: ______________________________________________________________________ {&abbr_rub}. ____________________ {&abbr_kop}.'                                                                                                                                                                                                skip
    '                                                (прописью)'                                                                                                                                                                                                                                                                                       skip
    {&tabulation}
    'рыночного фонда на _________________________________________________________________________________________ {&abbr_rub}. ____________________ {&abbr_kop}.'                                                                                                                                                                                                      skip
    {&tabulation}
    '                       (прописью)'                                                                                                                                                                                                                                                                                                                skip
    'единых (полученных для "сдачи") на ________________________________________________________________________________ {&abbr_rub}. ____________________ {&abbr_kop}.'                                                                                                                                                                                               skip
    '                                       (прописью)'                                                                                                                                                                                                                                                                                                skip( 1 )
  .
  put stream s-out unformatted
    '--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------' skip
    '   :               :           :       : Уровень наполненния,мм:      Объем, куб. мм (л. на АЗС)      : Плотность:Температура:            :            :                      :        : Итого масса:     Кроме того, масса продукта, кг    :                                 :    Остаток по данным  :   Результат, выявленный инвентаризацией   ' skip
    '   :               :           :       :-----------:-----------:------------:------------:------------: продукта :  продукта :            : Поправка на:    Содержание воды   :  Масса :   (нетто)  :------------:------------:-------------:         Всего в наличии         :  бухгалтерского учета :-------------------------------------------' skip
    ' № :  Наименование :  Тип и №  :       :           :подтоварной:  продукта  :            :  продукта  : при изме-:    при    :Масса брутто:    уклон   :                      : понтона: продукта в :            :            :  в неслитых :---------------------------------:-----------------------:       излишки       :      недостачи      ' skip
    'п/п: нефтепродукта :   резер-  :  Код  :           :  воды по  : соответств.: подтоварной:  без воды  :   рении  : измерении :  продукта  :   коррек.  :----------------------:--------: резервуаре :            :            :  цистернах, :  масса, кг  :        :          :            :          :------------:--------:------------:--------' skip
    '   :               :   вуара   :       :   общий   :водоч.ленте:общему уров-:    воды    : (из гр.7 - :  уровня  :   уровня  :(гр.7хгр.10):    днища   :         :            :        : гр.12-гр.13:      в     :            :нефтеналивных:(гр.17+гр.18+:  Цена  :   Сумма  :    Масса   :   Сумма  :    Масса   :  Сумма :    Масса   :  Сумма ' skip
    '   :               :           :       :           :           :ню (из гр.5):  (из гр.6) :     гр.8)  : кг/куб.м :   град.   :            :  (+,-), кг :    %    :     кг     :   кг   :-гр.15-гр.16:трубопроводе:   в таре   : судах, ямах : гр.19+гр.20):        :          :            :          : гр.21>гр.24:        : гр.21<гр.24:        ' skip
    '---:---------------:-----------:-------:-----------:-----------:------------:------------:------------:----------:-----------:------------:------------:---------:------------:--------:------------:------------:------------:-------------:-------------:--------:----------:------------:----------:------------:--------:------------:--------' skip
    ' 1 :       2       :    3      :   4   :     5     :     6     :      7     :      8     :      9     :    10    :     11    :     12     :     13     :    14   :     15     :   16   :     17     :     18     :     19     :      20     :      21     :   22   :    23    :     24     :    25    :     26     :   27   :     28     :   29   ' skip
    '---:---------------:-----------:-------:-----------:-----------:------------:------------:------------:----------:-----------:------------:------------:---------:------------:--------:------------:------------:------------:-------------:-------------:--------:----------:------------:----------:------------:--------:------------:--------' skip
  .

  run r-orioxl-init            in this-procedure .
  /* № ____________ от "____" ___________20__ г. */
  run r-orioxl-write-cell-data in this-procedure
    ( input {&r-orioxl-h_OwnFirm}
    , input substitute( '&1 управление'
                      , trim( v-host-name )
                      )
    ) .
  run r-orioxl-write-cell-data in this-procedure
    ( input {&r-orioxl-h_ObjCode}
    , input substitute( ' &1'
                      , trim( string( bf_object.obj-name, "x(40)":U  ) )
                      )
    ) .
  run r-orioxl-write-cell-data in this-procedure
    ( input {&r-orioxl-h_DocStamp}
    , input substitute( '№ &1 от "&2" &3 &4 г.'
                      , trim( bf_trn-doc.doc-code )
                      , day( t_inv-date )
                      , MonthNameRusCase( month( t_inv-date ), 2 )
                      , year( t_inv-date )
                      )
    ) .

  assign
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
    find first bf_place no-lock where
               bf_place.obj-type = bf_rvs-line.obj-type and
               bf_place.obj-code = bf_rvs-line.obj-code and
               bf_place.pl-code  = bf_rvs-line.pl-code  .
    assign
      dWaterQnty    = bf_rvs-line.state-brutto-qnty        - bf_rvs-line.state-measure-qnty
      dWaterCliQnty = bf_rvs-line.state-brutto-cli-qnty    - bf_rvs-line.state-measure-cli-qnty
      dAddCliQnty   = bf_rvs-line.state-add-qnty           * bf_rvs-line.state-density
      dOverCliQnty  = bf_rvs-line.state-measure-cli-qnty   + dAddCliQnty
      dcurr-price   = dprice-sale                          / bf_rvs-line.state-density
      dOverSum      = dOverCliQnty                         * dcurr-price
      dBookSum      = bf_rvs-line.system-cli-qnty          * dcurr-price
      dExtraQnty    = ( if dOverCliQnty                    > bf_rvs-line.system-cli-qnty
                        then ( dOverCliQnty                - bf_rvs-line.system-cli-qnty )
                        else 0.00 )
      dExtraSum     = dExtraQnty                           * dcurr-price
      dMissQnty     = ( if dOverCliQnty                    < bf_rvs-line.system-cli-qnty
                        then ( bf_rvs-line.system-cli-qnty - dOverCliQnty )
                        else 0.00 )
      dMissSum      = dMissQnty                            * dcurr-price
      j_LineCount   = j_LineCount                          + 1
    .
    put stream s-out unformatted
      string( string( j_LineCount,         ">9":U ),             "x(3)":U  ) + ":":U + /*  1 */
      string( bf_goods.gds-name,                                 "x(15)":U ) + ":":U + /*  2 */
      string( string( bf_rvs-line.pl-code, ">>>>>>>>>>9":U ),      "x(11)":U  ) + ":":U + /*  3 */
      string( bf_goods.artic,                                    "x(7)":U  ) + ":":U + /*  4 */
      string( OutLvl( bf_rvs-line.state-level-total,      no  ), "x(11)":U ) + ":":U + /*  5 */
      string( OutLvl( bf_rvs-line.state-level-water,      no  ), "x(11)":U ) + ":":U + /*  6 */
      string( OutQty( bf_rvs-line.state-brutto-qnty,      no  ), "x(12)":U ) + ":":U + /*  7 */
      string( OutQty( dWaterQnty,                         no  ), "x(12)":U ) + ":":U + /*  8 */
      string( OutQty( bf_rvs-line.state-measure-qnty,     no  ), "x(12)":U ) + ":":U + /*  9 */
      string( OutDty( bf_rvs-line.state-density,          no  ), "x(10)":U ) + ":":U + /* 10 */
      string( OutLvl( bf_rvs-line.state-temperature,      no  ), "x(11)":U ) + ":":U + /* 11 */
      string( OutQty( bf_rvs-line.state-brutto-cli-qnty,  no  ), "x(12)":U ) + ":":U + /* 12 */
      '            :         :':U                                            +         /* 13, 14 */
      string( OutQty( dWaterCliQnty,                      no  ), "x(12)":U ) + ":":U + /* 15 */
      '        :'                                                            +         /* 16 */
      string( OutQty( bf_rvs-line.state-measure-cli-qnty, no  ), "x(12)":U ) + ":":U + /* 17 */
      string( OutQty( dAddCliQnty,                        no  ), "x(12)":U ) + ":":U + /* 18 */
      '            :             : ':U                                       +         /* 19, 20 */
      string( OutQty( dOverCliQnty,                       no  ), "x(12)":U ) + ":":U + /* 21 */
      string( OutSum( dcurr-price,                        no  ), "x(8)":U  ) + ":":U + /* 22 */
      string( string( dOverSum, "->>>>>>9.99":U               ), "x(10)":U ) + ":":U + /* 23 */
      string( OutQty( bf_rvs-line.system-cli-qnty,        no  ), "x(12)":U ) + ":":U + /* 24 */
      string( string( dBookSum, "->>>>>>9.99":U               ), "x(10)":U ) + ":":U + /* 25 */
      string( OutQty( dExtraQnty,                         yes ), "x(12)":U ) + ":":U + /* 26 */
      string( OutSum( dExtraSum,                          yes ), "x(8)":U  ) + ":":U + /* 27 */
      string( OutQty( dMissQnty,                          yes ), "x(12)":U ) + ":":U + /* 28 */
      string( OutSum( dMissSum,                           yes ), "x(8)":U  ) skip    /* 29 */
    .
    run r-orioxl-write-line-data in this-procedure
      (
        input j_LineCount                                           /*  1 */
      , input bf_goods.gds-name                                     /*  2 */
      , input trim( string( bf_rvs-line.pl-code, ">>>>>>>>>>>9":U ) ) /*  3 */
      , input bf_goods.artic                                        /*  4 */
      , input OutDec( bf_rvs-line.state-level-total,      no  )     /*  5 */
      , input OutDec( bf_rvs-line.state-level-water,      no  )     /*  6 */
      , input OutDec( bf_rvs-line.state-brutto-qnty,      no  )     /*  7 */
      , input OutDec( dWaterQnty,                         no  )     /*  8 */
      , input OutDec( bf_rvs-line.state-measure-qnty,     no  )     /*  9 */
      , input OutDec( bf_rvs-line.state-density,          no  )     /* 10 */
      , input OutDec( bf_rvs-line.state-temperature,      no  )     /* 11 */
      , input OutDec( bf_rvs-line.state-brutto-cli-qnty,  no  )     /* 12 */
      , input OutDec( dWaterCliQnty,                      no  )     /* 15 */
      , input OutDec( bf_rvs-line.state-measure-cli-qnty, no  )     /* 17 */
      , input OutDec( dAddCliQnty,                        no  )     /* 18 */
      , input OutDec( dOverCliQnty,                       no  )     /* 21 */
      , input OutDec( dcurr-price,                        no  )     /* 22 */
      , input OutDec( dOverSum,                           no  )     /* 23 */
      , input OutDec( bf_rvs-line.system-cli-qnty,        no  )     /* 24 */
      , input OutDec( dBookSum,                           no  )     /* 25 */
      , input OutDec( dExtraQnty,                         yes )     /* 26 */
      , input OutDec( dExtraSum,                          yes )     /* 27 */
      , input OutDec( dMissQnty,                          yes )     /* 28 */
      , input OutDec( dMissSum,                           yes )     /* 29 */
    ) .
  end. /* for each bf_rvs-line */
  put stream s-out unformatted
    '--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------' skip( 1 )
    '  Итого по описи: а) порядковый номер ____________________________________________'                                                                                                                                                                                                                                                               skip
    '                                                      (прописью)'                                                                                                                                                                                                                                                                                 skip
    '    б) масса (кг) ____________________________________________________'                                                                                                                                                                                                                                                                           skip
    '                                      (прописью)'                                                                                                                                                                                                                                                                                                 skip( 1 )
    '          Председатель комиссии:'                                                                                                                                                                                                                                                                                                                 skip( 1 )
    '          ___________________________________________         ____________________________________________________'                                                                                                                                                                                                                               skip
    '                          (должность)                                       (фамилия, имя, отчество)'                                                                                                                                                                                                                                             skip( 1 )
    '          Члены комиссии:'                                                                                                                                                                                                                                                                                                                        skip( 1 )
    '          ___________________________________________         ____________________________________________________'                                                                                                                                                                                                                               skip
    '                          (должность)                                       (фамилия, имя, отчество)'                                                                                                                                                                                                                                             skip( 1 )
    '          ___________________________________________         ____________________________________________________'                                                                                                                                                                                                                               skip
    '                          (должность)                                       (фамилия, имя, отчество)'                                                                                                                                                                                                                                             skip( 1 )
    '          ___________________________________________         ____________________________________________________'                                                                                                                                                                                                                               skip
    '                          (должность)                                       (фамилия, имя, отчество)'                                                                                                                                                                                                                                             skip( 1 )
    {&tabulation}
    '"Все ценности, поименованные в настоящей инвентаризационной описи, комиссией проверены в натуре в моем (нашем) присутствии м внесены в опись, в связи с чем претензий к инвентаризационной комиссии не имею (не имеем).'                                                                                                                          skip
    'Ценности, перечмсленные в описи, находятся на моем (нашем) отвественном хранении"'                                                                                                                                                                                                                                                                skip( 1 )
    '          Материально ответственное  лицо:      ____________________________________________________________'                                                                                                                                                                                                                                     skip
    '                                                                         (подпись)'                                                                                                                                                                                                                                                               skip
    '                                                ____________________________________________________________'                                                                                                                                                                                                                                     skip
    '                                                                         (подпись)'                                                                                                                                                                                                                                                               skip
    '                                                ____________________________________________________________'                                                                                                                                                                                                                                     skip
    '                                                                         (подпись)'                                                                                                                                                                                                                                                               skip( 1 )
    {&tabulation}
    'Указанные в настоящей инвентаризационной описи данные и подсчеты проверил:'                                                                                                                                                                                                                                                                       skip
    {&tabulation} {&tabulation}
    '___________________________________________         ____________________________________________________'                                                                                                                                                                                                                                         skip
    {&tabulation} {&tabulation}
    '                (должность)                                       (фамилия, имя, отчество)'                                                                                                                                                                                                                                                       skip( 1 )
    {&tabulation}
    '"_____" _______________ 20 _____ г.'                                                                                                                                                                                                                                                                                                              skip
  .
  run waitfram-hide  in this-procedure .
  run r-orioxl-close in this-procedure .
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
  define  input parameter p-len  as integer   no-undo .
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
      case p-len :
        when 12 then do:
          assign
            p-char = trim( string( p-dec, "->>>>>>9.999":U ) )
          .
        end.
        when 8 then do:
          assign
            p-char = trim( string( p-dec, "->>>9.99":U ) )
          .
        end.
        when 11 then do:
          assign
            p-char = trim( string( p-dec, "->>>>>9.<<<":U ) )
          .
        end.
        when 10 then do:
          assign
            p-char = trim( string( p-dec, "->>>9.999<":U ) )
          .
        end.
        otherwise do:
          assign
            p-char = substring( trim( string( p-dec, "->>>>>>>>>>>>>9.<<<<<<<<<<":U ) ) + fill( ' ':U, p-len ), 1, p-len )
          .
        end.
      end case.
      assign
        p-char = fill( ' ':U, p-len - length( trim( p-char ) ) ) + trim( p-char )
      .
    end.
  end. /* on error */
end procedure. /* get-dec-string */