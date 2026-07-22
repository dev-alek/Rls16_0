block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка документов сверки

Автор: Уханов Дмитрий Юрьевич
Дата создания: 09/05/07
Author: Dmitry Ukhanov
Creation date: 09/05/07

*/

{ cmp/str-glbl.i }
{ ref/gds-attr.i }
{ str/is-gas.i }
{ str/placelib.i }

define input parameter parrecid as recid no-undo.

define buffer aft-rvs-doc       for ub.rvs-doc.
define buffer bef-rvs-doc       for ub.rvs-doc.
define buffer broser-rvs-doc    for ub.rvs-doc.
define buffer shift_rvs-doc     for ub.rvs-doc.
define buffer open_rvs-doc      for ub.rvs-doc.
define buffer rvs-shift-rvs-doc for ub.rvs-doc.

define variable varis-back-date as logical initial "no" no-undo.

tr:
do transaction
on error   undo tr, return error
on end-key undo tr, return error
on stop    undo tr, return error
:
  find ub.rvs-doc exclusive-lock
    where recid( ub.rvs-doc ) = parrecid
    no-error.
  if not available ub.rvs-doc then do:
    undo tr, return error "Ошибка при поиске документа сверки (файл chk-rvs.p)".
  end.
  find first ub.trn-doc
    where ub.trn-doc.doc-code = ub.rvs-doc.out-code
    no-error.
  if available ub.trn-doc
    and ub.trn-doc.is-back-date = yes
  then do:
    assign
      varis-back-date = yes
    .
  end.
  if varis-back-date <> yes
    and not ( ub.rvs-doc.status_ = {&fact} and ub.rvs-doc.is-corr = yes )
  then do:
    /* Проверка того, что нет сверок со следующей сменой */
    find first aft-rvs-doc no-lock
      where aft-rvs-doc.obj-type    = ub.rvs-doc.obj-type
        and aft-rvs-doc.obj-code    = ub.rvs-doc.obj-code
        and ( aft-rvs-doc.shift-date >  ub.rvs-doc.shift-date
              or ( aft-rvs-doc.shift-date  = ub.rvs-doc.shift-date
                   and aft-rvs-doc.shift-num  >  ub.rvs-doc.shift-num
                 )
            )
        and aft-rvs-doc.status_     = {&fact}
      no-error.

    if available aft-rvs-doc then do:
      undo tr, return error substitute( "Уже имеется более поздняя сверка: &1 Смена: &2 &3",
                                        aft-rvs-doc.rvs-code, aft-rvs-doc.shift-date, (if aft-rvs-doc.shift-name = string(aft-rvs-doc.shift-num) then aft-rvs-doc.shift-name else aft-rvs-doc.shift-name + "(" + string(aft-rvs-doc.shift-num) + ")")).
    end.
    /* Проверка того, что нет уже закрытой сверки по смене */
    find first rvs-shift-rvs-doc no-lock
      where rvs-shift-rvs-doc.obj-type    = ub.rvs-doc.obj-type
        and rvs-shift-rvs-doc.obj-code    = ub.rvs-doc.obj-code
        and rvs-shift-rvs-doc.shift-date  = ub.rvs-doc.shift-date
        and rvs-shift-rvs-doc.shift-num   = ub.rvs-doc.shift-num
        and rvs-shift-rvs-doc.status_     = {&fact}
        and rvs-shift-rvs-doc.rvs-type    = {&rvs-shift}
        and recid( rvs-shift-rvs-doc )   <> recid( ub.rvs-doc )
      no-error.
    if available rvs-shift-rvs-doc then do:
      undo tr, return error substitute( "Уже есть сверка по смене: &1 Смена: &2 &3 Формирование иных сверок невозможно.",
                                        rvs-shift-rvs-doc.rvs-code,
                                        rvs-shift-rvs-doc.shift-date,
                                        (if rvs-shift-rvs-doc.shift-name = string(rvs-shift-rvs-doc.shift-num) then rvs-shift-rvs-doc.shift-name else rvs-shift-rvs-doc.shift-name + "(" + string(rvs-shift-rvs-doc.shift-num) + ")") ).
    end.
  end.
  /* Не может существовать двух документов сверки, в одной смене и с одним типом */
  /*                    по одному складскому документу                           */
  /*             Уже может... Посекционные сверки для комиссионного прихода      
  if ub.rvs-doc.rvs-type = {&rvs-before-doc}
    or ub.rvs-doc.rvs-type = {&rvs-after-doc}
  then do:
    find first aft-rvs-doc no-lock
      where aft-rvs-doc.out-code   = ub.rvs-doc.out-code
        and aft-rvs-doc.rvs-type   = ub.rvs-doc.rvs-type
        and aft-rvs-doc.obj-type   = ub.rvs-doc.obj-type
        and aft-rvs-doc.obj-code   = ub.rvs-doc.obj-code
        and aft-rvs-doc.shift-date = ub.rvs-doc.shift-date
        and aft-rvs-doc.shift-num  = ub.rvs-doc.shift-num
        and aft-rvs-doc.status_    = {&fact}
        and recid( aft-rvs-doc )   <> recid( ub.rvs-doc )
      no-error.
  end.
  if available aft-rvs-doc then do:
    undo tr, return error substitute( "Есть аналогичный закрытый документ: &1 Смена: &2 &3",
                                      aft-rvs-doc.rvs-code, aft-rvs-doc.shift-date, (if aft-rvs-doc.shift-name = string(aft-rvs-doc.shift-num) then aft-rvs-doc.shift-name else aft-rvs-doc.shift-name + "(" + string(aft-rvs-doc.shift-num) + ")") ).
  end.
  */
  /* Если есть сверка "до" по документы, то должна существовать сверка "после" */
  if ub.rvs-doc.status_ <> {&g___new} then do:
    if ub.rvs-doc.rvs-type = {&rvs-after-doc} then do:
      find first broser-rvs-doc no-lock where
           broser-rvs-doc.out-code = ub.rvs-doc.out-code and
           broser-rvs-doc.rvs-type = {&rvs-before-doc}   no-error.
      if not available broser-rvs-doc then do:
        undo tr, return error "Для сверки " + {&rvs-after-doc} + " должна существовать сверка " + {&rvs-before-doc}.
      end.
    end.
  end.
  if ub.rvs-doc.status_ = {&fact} then do:
    /* Проверка того что заданы значения по установленому количеству во всех сверках */
    for each ub.rvs-line no-lock where ub.rvs-line.rvs-code = ub.rvs-doc.rvs-code :
      
      if is-gas(ub.rvs-line.gds-code) then next.
      
      define variable is-vir as logical no-undo.
      define variable v-value as character no-undo.
      define variable v-ok as logical no-undo.

      run placelib_get-attr(input {&place-virtual}
                           ,input rvs-line.obj-code
                           ,input rvs-line.obj-type
                           ,input rvs-line.pl-code
                           ,output v-value
                           ,output v-ok) no-error.

      is-vir = if (v-ok and logical(v-value)) then true else false.
      
      if is-vir then next.
      
      if ub.rvs-line.state-measure-qnty = ? or
         ub.rvs-line.state-density      = ? or
         ub.rvs-line.state-density      = 0 then do:
                  
         find ub.goods no-lock where ub.goods.gds-code = ub.rvs-line.gds-code.
         undo tr, return error
           substitute( "Вы не сделали сверку товара(не установлено кол-во или плотность): &1 &2 &3 &4 по месту хранения: &5",
                       ub.goods.artic, ub.goods.prod-type, ub.goods.prod-code, ub.goods.gds-name, ub.rvs-line.pl-code ).
      end.
/*      if ub.rvs-line.state-measure-qnty > ub.rvs-line.state-brutto-qnty then do:                                        */
/*         find ub.goods no-lock where ub.goods.gds-code = ub.rvs-line.gds-code.                                          */
/*         undo tr, return error                                                                                          */
/*           substitute( "Кол-во топлива больше кол-ва брутто по товару: &1 &2 &3 &4 по месту хранения: &5",              */
/*                       ub.goods.artic, ub.goods.prod-type, ub.goods.prod-code, ub.goods.gds-name, ub.rvs-line.pl-code ).*/
/*      end.                                                                                                              */
/*      if ub.rvs-line.state-measure-cli-qnty > ub.rvs-line.state-brutto-cli-qnty then do:                                */
/*         find ub.goods where ub.goods.gds-code = ub.rvs-line.gds-code no-lock.                                          */
/*         undo tr, return error                                                                                          */
/*           substitute( "Вес топлива больше веса брутто по товару: &1 &2 &3 &4 по месту хранения: &5",                   */
/*                       ub.goods.artic, ub.goods.prod-type, ub.goods.prod-code, ub.goods.gds-name, ub.rvs-line.pl-code ).*/
/*      end.                                                                                                              */
/*      if ub.rvs-line.state-level-petrol > ub.rvs-line.state-level-total then do:                                        */
/*         find ub.goods where ub.goods.gds-code = ub.rvs-line.gds-code no-lock.                                          */
/*         undo tr, return error                                                                                          */
/*           substitute( "Уровень топлива больше общего уровня по товару: &1 &2 &3 &4 по месту хранения: &5",             */
/*                       ub.goods.artic, ub.goods.prod-type, ub.goods.prod-code, ub.goods.gds-name, ub.rvs-line.pl-code ).*/
/*      end.                                                                                                              */
    end. /* for each ub.rvs-line */
    /* Проверка того, что заданы нараст. итоги по всем механическим счетчикам и кол-во с начала смены */
    for each ub.rvs-line-pump no-lock where ub.rvs-line-pump.rvs-code = ub.rvs-doc.rvs-code :
      if ub.rvs-line-pump.state-el-cnt  = ? or
         ub.rvs-line-pump.state-mh-cnt  = ? then do:
        undo tr, return error substitute( "Вы не сделали сверку по ТРК &1 пистолету &2",
                                          ub.rvs-line-pump.pump-code, ub.rvs-line-pump.nozzle-code ).
      end.
    end. /* for each ub.rvs-line-pump */

    /* Проверка даты */
    run gbl/chk-date.p
      ( input ub.rvs-doc.obj-type
      , input ub.rvs-doc.obj-code
      , input ub.rvs-doc.fact-date
      , input ub.rvs-doc.fact-time
      , input ub.rvs-doc.shift-date
      , input ub.rvs-doc.shift-num
      , input yes
      ) no-error.
    if error-status :error then do:
      undo tr, return error
        substitute( "Неверная дата и время в документе сверки  fact-date &1 fact-time &2 shift-date &3 shift-num &4 ",
                    ub.rvs-doc.fact-date, ub.rvs-doc.fact-time, ub.rvs-doc.shift-date, ub.rvs-doc.shift-num ).
    end.
  end. /* ub.rvs-doc.status_ = {&fact} */

  /* Проверка на то, что можно делать сверку по смене */
  if ub.rvs-doc.rvs-type = {&rvs-shift} then do:
    find first ub.icnt-doc no-lock where
               ub.icnt-doc.obj-type = ub.rvs-doc.obj-type and
               ub.icnt-doc.obj-code = ub.rvs-doc.obj-code and
               ub.icnt-doc.status_  > {&fact}             no-error.
    if available ub.icnt-doc then do:
      undo tr, return error
        substitute( 'Есть открытый документ инвентаризации счетчиков ТРК "&1". Создание сверки по смене недопустимо.',
                    ub.icnt-doc.doc-code ).
    end.
    find first ub.icnt-doc no-lock where
               ub.icnt-doc.obj-type = ub.rvs-doc.obj-type and
               ub.icnt-doc.obj-code = ub.rvs-doc.obj-code and
               ub.icnt-doc.status_  < {&fact}             no-error.
    if available ub.icnt-doc then do:
      undo tr, return error
        substitute( 'Есть открытый документ инвентаризации счетчиков ТРК "&1". Создание сверки по смене недопустимо.',
                    ub.icnt-doc.doc-code ).
    end.
    find first ub.wth-doc no-lock where
               ub.wth-doc.obj-type = ub.rvs-doc.obj-type and
               ub.wth-doc.obj-code = ub.rvs-doc.obj-code and
               ub.wth-doc.status_  > {&fact}             no-error.
    if available ub.wth-doc then do:
      undo tr, return error
        substitute( 'Есть открытый документ мат. ценностей "&1". Создание сверки по смене недопустимо.',
                    ub.wth-doc.doc-code ).
    end.
    find first ub.wth-doc no-lock where
               ub.wth-doc.obj-type = ub.rvs-doc.obj-type and
               ub.wth-doc.obj-code = ub.rvs-doc.obj-code and
               ub.wth-doc.status_  < {&fact}             no-error.
    if available ub.wth-doc then do:
      undo tr, return error
        substitute( 'Есть открытый документ мат. ценностей "&1". Создание сверки по смене недопустимо.',
                    ub.wth-doc.doc-code ).
    end.
    find first open_rvs-doc no-lock where
               open_rvs-doc.obj-type  = ub.rvs-doc.obj-type and
               open_rvs-doc.obj-code  = ub.rvs-doc.obj-code and
               open_rvs-doc.status_   > {&fact}             and
               recid( open_rvs-doc ) <> recid( ub.rvs-doc ) and
               open_rvs-doc.rvs-type <> {&test-asi}         no-error.
    if available open_rvs-doc then do:
      undo tr, return error
        substitute( 'Есть открытый документ сверки "&1". Создание сверки по смене недопустимо.', open_rvs-doc.rvs-code ).
    end.
    find first open_rvs-doc no-lock where
               open_rvs-doc.obj-type =  ub.rvs-doc.obj-type and
               open_rvs-doc.obj-code =  ub.rvs-doc.obj-code and
               open_rvs-doc.status_  <  {&fact}             and
               recid( open_rvs-doc ) <> recid( ub.rvs-doc ) and
               open_rvs-doc.rvs-type <> {&test-asi}         no-error.
    if available open_rvs-doc then do:
      undo tr, return error
        substitute( 'Есть открытый документ сверки "&1". Создание сверки по смене недопустимо.', open_rvs-doc.rvs-code ).
    end.
    find first ub.inkas no-lock where
               ub.inkas.obj-type = ub.rvs-doc.obj-type and
               ub.inkas.obj-code = ub.rvs-doc.obj-code and
               ub.inkas.status_  > {&fact}             no-error.
    if available ub.inkas then do:
      undo tr, return error
        substitute( 'Есть незакрытая продажа "&1". Создание сверки по смене недопустимо.', ub.inkas.inkas-code ).
    end.
    find first ub.inkas no-lock where
               ub.inkas.obj-type = ub.rvs-doc.obj-type and
               ub.inkas.obj-code = ub.rvs-doc.obj-code and
               ub.inkas.status_  < {&fact}             no-error.
    if available ub.inkas then do:
      undo tr, return error
        substitute( 'Есть незакрытая продажа "&1". Создание сверки по смене недопустимо.', ub.inkas.inkas-code ).
    end.
  end. /* if ub.rvs-doc.rvs-type = {&rvs-shift} */
end. /* transaction */