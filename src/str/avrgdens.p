block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Расчет средней плотности по топливу за смену на объекте

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/12/99
Author: Dmitry Ukhanov
Creation date: 08/12/99

Автор1: Суслов Алексей Юрьевич
Дата создания: 09/19/05

Учитываются все закрытые сверки текущей смены,
                сверка за смену по прошлой смене,
                и текущая сверка если указан параметр p-rvs-code
Расчет средней плотности производится с условием закрытой сверки по смене
или указанием сверки по которой ведет подсчет (p-rvs-code)

*/

define  input parameter p-obj-type     like ub.clients.obj-type     no-undo .
define  input parameter p-obj-code     like ub.clients.obj-code     no-undo .
define  input parameter p-shift-date   like ub.shift-obj.shift-date no-undo .
define  input parameter p-shift-num    like ub.shift-obj.shift-num  no-undo .
define  input parameter p-gds-code     like ub.goods.gds-code       no-undo .
define  input parameter p-rvs-code     like ub.rvs-doc.rvs-code     no-undo .
define  input parameter p-with-expense as   logical                 no-undo .
define output parameter p-density      as   decimal                 no-undo .

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Расчет средней плотности по топливу за смену на объекте":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }

define variable is_shift-on       as   logical               no-undo .
define variable is-petrol         as   logical               no-undo .
define variable is-pieces         as   logical               no-undo .
define variable d_fact-order      like ub.rvs-doc.fact-order no-undo .
define variable d_fact-order-prev like ub.rvs-doc.fact-order no-undo .
define variable d_density-acc     as   decimal               no-undo .
define variable j_num-place       as   integer               no-undo .
define variable rec-rvs-doc       as   recid                 no-undo .
define variable varshift-name     as   character             no-undo .
define variable varshift-name-num as   character             no-undo .

define buffer bf_rvs-doc  for ub.rvs-doc .
define buffer bf_cur-doc  for ub.rvs-doc .
define buffer bf_cur-line for ub.rvs-line .

do on error undo, return error :
  /* Проверяем, что есть такой клиент */
  find first ub.clients no-lock where
             ub.clients.obj-type = p-obj-type and
             ub.clients.obj-code = p-obj-code no-error .
  if not available ub.clients
  then do:
    return error substitute( "Не найден объект: &1 &2."
                           , p-obj-type
                           , p-obj-code
                           ) .
  end.

  /* Проверяем, что на объекте работают смены */
  { gbl/objat.i
      p-obj-type
      p-obj-code
      "'shift-on=request'"
      is_shift-on
      no-error
  }
  if error-status :error
  then do:
    return error trim( return-value ) +
                 trim( error-status :get-message( 1 ) ) +
                 trim( error-status :get-message( 2 ) ) +
                 trim( error-status :get-message( 3 ) ) +
                 trim( error-status :get-message( 4 ) ) +
                 trim( error-status :get-message( 5 ) ) .
  end.
  if is_shift-on <> yes
  then do:
    return error "На объекте не работают смены." .
  end.
  find first ub.goods no-lock where
             ub.goods.gds-code = p-gds-code no-error .
  if not available ub.goods
  then do:
    return error substitute( "Не найден товар с внутренним кодом &1."
                           , p-gds-code
                           ) .
  end.
  { str/is-petrl.i
      ub.goods.artic
      ub.goods.prod-type
      ub.goods.prod-code
      is-petrol
      is-pieces
      no-error
  }
  if error-status :error
  then do:
    return error "Ошибка при вызове программы lib-trn_is-petrl из avrgdens.p. " + return-value .
  end.
  if is-petrol <> yes or
     is-pieces <> no
  then do:
    return error substitute( "Товар &1 &2 &3 не является весовым топливом."
                           , ub.goods.artic
                           , ub.goods.prod-type
                           , ub.goods.prod-code
                           ) .
  end.
  if p-rvs-code <> ?
  then do:
    find first bf_cur-doc no-lock where
               bf_cur-doc.rvs-code = p-rvs-code no-error .
    if not available bf_cur-doc
    then do:
       return error substitute( "Не найдена сверка с номером &1 ."
                              , p-rvs-code
                              ) .
    end.
    find first bf_cur-line no-lock where
               bf_cur-line.rvs-code = bf_cur-doc.rvs-code and
               bf_cur-line.gds-code = ub.goods.gds-code   no-error .
    if not available bf_cur-line
    then do:
      return error substitute( "Товар &1 &2 &3 не участвует в сверке &4. Плотность не может быть вычислена. "
                             , ub.goods.artic
                             , ub.goods.prod-type
                             , ub.goods.prod-code
                             , bf_cur-doc.rvs-code
                             ) .
    end.
    assign
      d_fact-order = bf_cur-doc.fact-order
    .
  end.
  else do:
    assign
      d_fact-order = ?
    .
    for each ub.rvs-doc no-lock where
             ub.rvs-doc.obj-type   = p-obj-type   and
             ub.rvs-doc.obj-code   = p-obj-code   and
             ub.rvs-doc.shift-date = p-shift-date and
             ub.rvs-doc.shift-num  = p-shift-num  and
             ub.rvs-doc.status_    = {&fact}      and
             ub.rvs-doc.rvs-type  <> {&test-asi}
      , each ub.rvs-line no-lock where
             ub.rvs-line.rvs-code = ub.rvs-doc.rvs-code and
             ub.rvs-line.obj-type = ub.rvs-doc.obj-type and
             ub.rvs-line.obj-code = ub.rvs-doc.obj-code and
             ub.rvs-line.gds-code = ub.goods.gds-code
    :
      assign
        d_fact-order = ub.rvs-doc.fact-order
      .
      leave .
    end. /* for each ub.rvs-doc, each ub.rvs-line */
  end.
  if d_fact-order <> ? then do:
    find last bf_rvs-doc no-lock where
              bf_rvs-doc.obj-type   = p-obj-type   and
              bf_rvs-doc.obj-code   = p-obj-code   and
              bf_rvs-doc.status_    = {&fact}      and
              bf_rvs-doc.fact-order < d_fact-order and
              bf_rvs-doc.rvs-type   = {&rvs-shift} use-index stat-fact no-error .
    /* Для первой смены */
    assign
      d_fact-order-prev = ( if available bf_rvs-doc then bf_rvs-doc.fact-order else 0.00 )
    .
    assign
      j_num-place   = 0
      d_density-acc = 0.00
      p-density     = 0.00
    .
    for each ub.rvs-doc no-lock where
             ub.rvs-doc.obj-type    = p-obj-type        and
             ub.rvs-doc.obj-code    = p-obj-code        and
             ub.rvs-doc.status_     = {&fact}           and
             ub.rvs-doc.fact-order <= d_fact-order      and
             ub.rvs-doc.fact-order >= d_fact-order-prev and 
             ub.rvs-doc.rvs-type   <> {&test-asi}
      , each ub.rvs-line no-lock where
             ub.rvs-line.rvs-code = ub.rvs-doc.rvs-code and
             ub.rvs-line.obj-type = ub.rvs-doc.obj-type and
             ub.rvs-line.obj-code = ub.rvs-doc.obj-code and
             ub.rvs-line.gds-code = p-gds-code
    break by ub.rvs-line.obj-type
          by ub.rvs-line.obj-code
          by ub.rvs-line.pl-code
    on error undo, return error
    :
      assign
        d_density-acc = d_density-acc + ( if ub.rvs-line.state-density <> ? then ub.rvs-line.state-density else 0 )
        j_num-place   = j_num-place   + 1
      .
    end. /* for each ub.rvs-doc */
    if p-with-expense = yes
    then do:
      for each ub.doc-line no-lock where
               ub.doc-line.obj-type      = p-obj-type         and
               ub.doc-line.obj-code      = p-obj-code         and
               ub.doc-line.prod-type     = ub.goods.prod-type and
               ub.doc-line.prod-code     = ub.goods.prod-code and
               ub.doc-line.artic         = ub.goods.artic     and
               ub.doc-line.ext-doc-type  = {&TDEDT_Ras_Vnesh} and
               ub.doc-line.status_       = {&fact}            and
               ub.doc-line.fact-order   <= d_fact-order       and
               ub.doc-line.fact-order   >= d_fact-order-prev
      on error undo, return error
      :
        assign
          d_density-acc = d_density-acc + ( if ub.doc-line.fact-density <> ? then ub.doc-line.fact-density else 0 )
          j_num-place   = j_num-place   + 1
        .
      end. /* for each ub.trn-doc */
    end. /* if p-with-expense */
  end.
  else do:
    find last bf_rvs-doc no-lock where
              bf_rvs-doc.obj-type   = p-obj-type   and
              bf_rvs-doc.obj-code   = p-obj-code   and
              bf_rvs-doc.status_    = {&fact}      and
              bf_rvs-doc.rvs-type   = {&rvs-shift} use-index stat-fact no-error .
    /* Для первой смены */
    assign
      d_fact-order-prev = ( if available bf_rvs-doc then bf_rvs-doc.fact-order else 0.00 )
    .
    assign
      j_num-place   = 0
      d_density-acc = 0.00
      p-density     = 0.00
    .
    for each ub.rvs-doc no-lock where
             ub.rvs-doc.obj-type    = p-obj-type        and
             ub.rvs-doc.obj-code    = p-obj-code        and
             ub.rvs-doc.status_     = {&fact}           and
             ub.rvs-doc.fact-order >= d_fact-order-prev and
             ub.rvs-doc.rvs-type   <> {&test-asi}
      , each ub.rvs-line no-lock where
             ub.rvs-line.rvs-code = ub.rvs-doc.rvs-code and
             ub.rvs-line.obj-type = ub.rvs-doc.obj-type and
             ub.rvs-line.obj-code = ub.rvs-doc.obj-code and
             ub.rvs-line.gds-code = p-gds-code
    break by ub.rvs-line.obj-type
          by ub.rvs-line.obj-code
          by ub.rvs-line.pl-code
    on error undo, return error
    :
      assign
        d_density-acc = d_density-acc + ( if ub.rvs-line.state-density <> ? then ub.rvs-line.state-density else 0 )
        j_num-place   = j_num-place   + 1
      .
    end. /* for each ub.rvs-doc */
    if p-with-expense = yes
    then do:
      for each ub.doc-line no-lock where
               ub.doc-line.obj-type      = p-obj-type         and
               ub.doc-line.obj-code      = p-obj-code         and
               ub.doc-line.prod-type     = ub.goods.prod-type and
               ub.doc-line.prod-code     = ub.goods.prod-code and
               ub.doc-line.artic         = ub.goods.artic     and
               ub.doc-line.ext-doc-type  = {&TDEDT_Ras_Vnesh} and
               ub.doc-line.status_       = {&fact}            and
               ub.doc-line.fact-order   >= d_fact-order-prev
      on error undo, return error
      :
        assign
          d_density-acc = d_density-acc + ( if ub.doc-line.fact-density <> ? then ub.doc-line.fact-density else 0 )
          j_num-place   = j_num-place   + 1
        .
      end. /* for each ub.trn-doc */
    end. /* if p-with-expense */

  end.
  assign
    p-density = d_density-acc / j_num-place
  .
end. /* on error */