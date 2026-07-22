block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Расчет межфирменного архива по одному документу

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/11/06

*/

define input  parameter p-cat-code       like ub.hold-time.cat-code no-undo .
define input  parameter p-lock-code      as character no-undo .
define input  parameter p-btpr-type-code as character no-undo .
define input  parameter p-doc-code       like ub.trn-doc.doc-code no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Расчет межфирменного архива по одному документу".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4':u,p-cat-code,p-lock-code,p-btpr-type-code,p-doc-code)"}
{ cmp/trg-def.i  }
{ gbl/lastdate.i }
{ trg/harhcrht.i }
{ str/trdcalib.i }
{ trg/holdprts.i }

define variable v-start-date as date      no-undo .
define variable v-end-date   as date      no-undo .
define variable v-is-purch   as logical   no-undo .
define variable v-is-sale    as logical   no-undo .

define buffer buf_trn-doc      for ub.trn-doc .
define buffer locked_hold-time for ub.hold-time .
define buffer last_hold-time   for ub.hold-time .
define buffer locked_hold-trn  for ub.hold-trn .

do
on error undo, return error
:

  find first buf_trn-doc share-lock
    where buf_trn-doc.doc-code = p-doc-code
    no-error .
  if not available buf_trn-doc
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден документ" skip
      "Документ" p-doc-code
      view-as alert-box error .
    return error .
  end.
  if buf_trn-doc.status_ <> {&fact}
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка расчета межфирменного архива" skip
      "Документ не в статусе" {&fact}
      "Документ" p-doc-code
      view-as alert-box error .
    return error .
  end.

  /*найдем время*/
  run lastdate in this-procedure
    (input buf_trn-doc.fact-date
    ,output v-end-date)
    no-error .
  if error-status :error
  then do:
    message
    vss-workfile vss-revision vss-description skip
    "Ошибка поиска последней даты месяца закрытия документа на факт"
    "Документ" p-doc-code skip
    "Факт дата" buf_trn-doc.fact-date
    view-as alert-box error .
    return error.
  end.
  assign
    v-start-date = date(month(buf_trn-doc.fact-date), 1, year(buf_trn-doc.fact-date))
  .

  find first locked_hold-time exclusive-lock
    where locked_hold-time.cat-code = p-cat-code
      and locked_hold-time.time-type = {&harh-type-month}
      and locked_hold-time.start-date = v-start-date
    no-error .
  if not available locked_hold-time
  then do:
    run create-hold-time in this-procedure
      (input p-cat-code
      ,input v-start-date
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при создании записи межфирменного архива" skip
        "Документ" buf_trn-doc.doc-code skip
        "cat-code" p-cat-code
        "time-type" {&harh-type-month}
        "start-date" v-start-date
        view-as alert-box error .
      undo, return error .
    end.
    find first locked_hold-time exclusive-lock where
              locked_hold-time.cat-code = p-cat-code AND
              locked_hold-time.time-type = {&harh-type-month} AND
              locked_hold-time.start-date = v-start-date .
  end.

  find first locked_hold-trn exclusive-lock
    where locked_hold-trn.cat-code = p-cat-code
      and locked_hold-trn.doc-code = p-doc-code
      and locked_hold-trn.time-code = locked_hold-time.time-code
    no-error .
  if not available locked_hold-trn
  then do:
    create locked_hold-trn .
    assign
      locked_hold-trn.cat-code = p-cat-code
      locked_hold-trn.doc-code = p-doc-code
      locked_hold-trn.time-code = locked_hold-time.time-code
      locked_hold-trn.is-purch = ?
      locked_hold-trn.is-sale = ?
    .
  end.
  else do:
    undo, return error vss-workfile + vss-revision + {&new-line}
      + "Попытка повторного расчета документа" + {&new-line}
      + substitute("Категория &1", p-cat-code) + {&new-line}
      + substitute("Документ &1", p-doc-code) + {&new-line}
      .
  end.

  /* определяем атрибуты документа v-is-purch v-is-sale */
  run holdprts-doc-type in this-procedure
    (input  p-cat-code           /* p-cat-code */
    ,input  buf_trn-doc.doc-code /* p-doc-code */
    ,output v-is-sale            /* p-is-sale  */
    ,output v-is-purch           /* p-is-purch */
    ) .

  if v-is-purch
  then do:
    run harh-calc-trn-purch in this-procedure
      (input p-cat-code
      ,input locked_hold-time.time-code
      ,input buf_trn-doc.doc-code
      ,input buf_trn-doc.cli-type
      ,input buf_trn-doc.cli-code
      ) no-error .
    if error-status :error
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Ошибка расчета межфирменного архива"
      "Документ закупки" buf_trn-doc.doc-code
      view-as alert-box error .
      undo, return error .
    end.

  end.
  if v-is-sale
  then do:
    run harh-calc-trn-sale in this-procedure
      (input p-cat-code
      ,input locked_hold-time.time-code
      ,input buf_trn-doc.doc-code
      ) no-error .
    if error-status :error
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Ошибка расчета межфирменного архива"
      "Документ продажи" buf_trn-doc.doc-code
      view-as alert-box error .
      undo, return error .
    end.

  end.
  assign
    locked_hold-trn.is-purch = v-is-purch
    locked_hold-trn.is-sale = v-is-sale
  .

end.



procedure harh-calc-trn-purch :
define input parameter p-cat-code like ub.hold-time.cat-code no-undo .
define input parameter p-time-code like ub.hold-time.time-code no-undo .
define input parameter p-doc-code like ub.trn-doc.doc-code no-undo .
define input parameter p-cli-type like ub.trn-doc.cli-type no-undo .
define input parameter p-cli-code like ub.trn-doc.cli-code no-undo .

DEFINE VARIABLE   v-fact-qnty             like ub.hold-purch.fact-qnty            no-undo .
DEFINE VARIABLE   v-purch-sum-base        like ub.hold-purch.purch-sum-base       no-undo .
DEFINE VARIABLE   v-purch-sum-rubl        like ub.hold-purch.purch-sum-rubl       no-undo .
DEFINE VARIABLE   v-purch-VAT-base        like ub.hold-purch.purch-VAT-base       no-undo .
DEFINE VARIABLE   v-purch-VAT-rubl        like ub.hold-purch.purch-VAT-rubl       no-undo .
DEFINE VARIABLE   v-purch-SLT-base        like ub.hold-purch.purch-SLT-base       no-undo .
DEFINE VARIABLE   v-purch-SLT-rubl        like ub.hold-purch.purch-SLT-rubl       no-undo .
DEFINE VARIABLE   v-purch-road-tax-base   like ub.hold-purch.purch-road-tax-base  no-undo .
DEFINE VARIABLE   v-purch-road-tax-rubl   like ub.hold-purch.purch-road-tax-rubl  no-undo .
DEFINE VARIABLE   v-purch-excise-base     like ub.hold-purch.purch-excise-base    no-undo .
DEFINE VARIABLE   v-purch-excise-rubl     like ub.hold-purch.purch-excise-rubl    no-undo .
DEFINE VARIABLE   v-purch-transport-base  like ub.hold-purch.purch-transport-base no-undo .
DEFINE VARIABLE   v-purch-transport-rubl  like ub.hold-purch.purch-transport-rubl no-undo .
DEFINE VARIABLE   v-purch-other-base      like ub.hold-purch.purch-other-base     no-undo .
DEFINE VARIABLE   v-purch-other-rubl      like ub.hold-purch.purch-other-rubl     no-undo .
DEFINE VARIABLE   v-purch-discnt-base     like ub.hold-purch.purch-discnt-base    no-undo .
DEFINE VARIABLE   v-purch-discnt-rubl     like ub.hold-purch.purch-discnt-rubl    no-undo .
DEFINE VARIABLE   v-node-code like ub.hold-purch-grp.node-code no-undo .

define buffer buf_doc-line for ub.doc-line .
define buffer buf_goods for ub.goods .
define buffer buf_hold-purch for ub.hold-purch.
define buffer buf_hold-purch-grp for ub.hold-purch-grp.
define buffer buf_hold-purch-supp for ub.hold-purch-supp.
define buffer buf_hold-purch-supp-gds for ub.hold-purch-supp-gds.

  do
  on error undo, return error
  :
    for each buf_doc-line no-lock
      where buf_doc-line.doc-code = p-doc-code
    on error undo, return error
    :

      /* найдем данные по закупке для закладки в архив */
      run holdprts-purch-values in this-procedure
        (input  p-doc-code
        ,input  buf_doc-line.artic
        ,input  buf_doc-line.prod-type
        ,input  buf_doc-line.prod-code
        ,output v-fact-qnty
        ,output v-purch-sum-base
        ,output v-purch-sum-rubl
        ,output v-purch-VAT-base
        ,output v-purch-VAT-rubl
        ,output v-purch-SLT-base
        ,output v-purch-SLT-rubl
        ,output v-purch-road-tax-base
        ,output v-purch-road-tax-rubl
        ,output v-purch-excise-base
        ,output v-purch-excise-rubl
        ,output v-purch-transport-base
        ,output v-purch-transport-rubl
        ,output v-purch-other-base
        ,output v-purch-other-rubl
        ,output v-purch-discnt-base
        ,output v-purch-discnt-rubl
        ) .

      /* поиск товара */
      find first buf_goods no-lock
        where buf_goods.artic = buf_doc-line.artic
          and buf_goods.prod-type = buf_doc-line.prod-type
          and buf_goods.prod-code = buf_doc-line.prod-code
        no-error .
      if not available buf_goods
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при заполнении межфирменного архива по строке документа закупки" skip
          "Документ" p-doc-code skip
          "cat-code" p-cat-code skip
          "time-code" p-time-code skip
          "Товар" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code
          view-as alert-box error .
        return error .
      end.

      /* регистрация товара */
      run harh-set-good in this-procedure
        (input p-cat-code
        ,input p-time-code
        ,input buf_goods.gds-code
        ,input buf_goods.grp-name
        ,output v-node-code
        ) no-error .
      if error-status :error
      then do:
        message
        vss-workfile vss-revision vss-description skip
        "Ошибка при регистрации товара в межфирменном архиве" skip
        "Товар" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code SKIP
        "cat-code" p-cat-code SKIP
        "time-code" p-time-code
        view-as alert-box error .
        return error .
      end.

      /*обновление записей hold-purch*/
      find first buf_hold-purch exclusive-lock where
                 buf_hold-purch.cat-code = p-cat-code AND
                 buf_hold-purch.time-code = p-time-code AND
                 buf_hold-purch.gds-code = buf_goods.gds-code no-error.
      if not available buf_hold-purch
      then do:
        create buf_hold-purch .
        assign
          buf_hold-purch.cat-code = p-cat-code
          buf_hold-purch.time-code = p-time-code
          buf_hold-purch.gds-code = buf_goods.gds-code
        .
      end.
      assign
        buf_hold-purch.fact-qnty             =  buf_hold-purch.fact-qnty            +  v-fact-qnty
        buf_hold-purch.purch-sum-base        =  buf_hold-purch.purch-sum-base       +  v-purch-sum-base
        buf_hold-purch.purch-sum-rubl        =  buf_hold-purch.purch-sum-rubl       +  v-purch-sum-rubl
        buf_hold-purch.purch-VAT-base        =  buf_hold-purch.purch-VAT-base       +  v-purch-VAT-base
        buf_hold-purch.purch-VAT-rubl        =  buf_hold-purch.purch-VAT-rubl       +  v-purch-VAT-rubl
        buf_hold-purch.purch-SLT-base        =  buf_hold-purch.purch-SLT-base       +  v-purch-SLT-base
        buf_hold-purch.purch-SLT-rubl        =  buf_hold-purch.purch-SLT-rubl       +  v-purch-SLT-rubl
        buf_hold-purch.purch-road-tax-base   =  buf_hold-purch.purch-road-tax-base  +  v-purch-road-tax-base
        buf_hold-purch.purch-road-tax-rubl   =  buf_hold-purch.purch-road-tax-rubl  +  v-purch-road-tax-rubl
        buf_hold-purch.purch-excise-base     =  buf_hold-purch.purch-excise-base    +  v-purch-excise-base
        buf_hold-purch.purch-excise-rubl     =  buf_hold-purch.purch-excise-rubl    +  v-purch-excise-rubl
        buf_hold-purch.purch-transport-base  =  buf_hold-purch.purch-transport-base +  v-purch-transport-base
        buf_hold-purch.purch-transport-rubl  =  buf_hold-purch.purch-transport-rubl +  v-purch-transport-rubl
        buf_hold-purch.purch-other-base      =  buf_hold-purch.purch-other-base     +  v-purch-other-base
        buf_hold-purch.purch-other-rubl      =  buf_hold-purch.purch-other-rubl     +  v-purch-other-rubl
        buf_hold-purch.purch-discnt-base     =  buf_hold-purch.purch-discnt-base    +  v-purch-discnt-base
        buf_hold-purch.purch-discnt-rubl     =  buf_hold-purch.purch-discnt-rubl    +  v-purch-discnt-rubl
      .

      /*обновление записи hold-purch-grp*/

      /*обновление записей hold-purch*/
      find first buf_hold-purch-grp exclusive-lock where
                 buf_hold-purch-grp.cat-code = p-cat-code AND
                 buf_hold-purch-grp.time-code = p-time-code AND
                 buf_hold-purch-grp.node-code = v-node-code no-error.
      if not available buf_hold-purch-grp
      then do:
        create buf_hold-purch-grp .
        assign
          buf_hold-purch-grp.cat-code = p-cat-code
          buf_hold-purch-grp.time-code = p-time-code
          buf_hold-purch-grp.node-code = v-node-code
        .
      end.
      assign
        buf_hold-purch-grp.fact-qnty             =  buf_hold-purch-grp.fact-qnty            +  v-fact-qnty
        buf_hold-purch-grp.purch-sum-base        =  buf_hold-purch-grp.purch-sum-base       +  v-purch-sum-base
        buf_hold-purch-grp.purch-sum-rubl        =  buf_hold-purch-grp.purch-sum-rubl       +  v-purch-sum-rubl
        buf_hold-purch-grp.purch-VAT-base        =  buf_hold-purch-grp.purch-VAT-base       +  v-purch-VAT-base
        buf_hold-purch-grp.purch-VAT-rubl        =  buf_hold-purch-grp.purch-VAT-rubl       +  v-purch-VAT-rubl
        buf_hold-purch-grp.purch-SLT-base        =  buf_hold-purch-grp.purch-SLT-base       +  v-purch-SLT-base
        buf_hold-purch-grp.purch-SLT-rubl        =  buf_hold-purch-grp.purch-SLT-rubl       +  v-purch-SLT-rubl
        buf_hold-purch-grp.purch-road-tax-base   =  buf_hold-purch-grp.purch-road-tax-base  +  v-purch-road-tax-base
        buf_hold-purch-grp.purch-road-tax-rubl   =  buf_hold-purch-grp.purch-road-tax-rubl  +  v-purch-road-tax-rubl
        buf_hold-purch-grp.purch-excise-base     =  buf_hold-purch-grp.purch-excise-base    +  v-purch-excise-base
        buf_hold-purch-grp.purch-excise-rubl     =  buf_hold-purch-grp.purch-excise-rubl    +  v-purch-excise-rubl
        buf_hold-purch-grp.purch-transport-base  =  buf_hold-purch-grp.purch-transport-base +  v-purch-transport-base
        buf_hold-purch-grp.purch-transport-rubl  =  buf_hold-purch-grp.purch-transport-rubl +  v-purch-transport-rubl
        buf_hold-purch-grp.purch-other-base      =  buf_hold-purch-grp.purch-other-base     +  v-purch-other-base
        buf_hold-purch-grp.purch-other-rubl      =  buf_hold-purch-grp.purch-other-rubl     +  v-purch-other-rubl
        buf_hold-purch-grp.purch-discnt-base     =  buf_hold-purch-grp.purch-discnt-base    +  v-purch-discnt-base
        buf_hold-purch-grp.purch-discnt-rubl     =  buf_hold-purch-grp.purch-discnt-rubl    +  v-purch-discnt-rubl
      .



      /*обновление записи hold-purch-supp*/
      find first buf_hold-purch-supp exclusive-lock where
                 buf_hold-purch-supp.cat-code = p-cat-code AND
                 buf_hold-purch-supp.time-code = p-time-code AND
                 buf_hold-purch-supp.cli-type = p-cli-type AND
                 buf_hold-purch-supp.cli-code = p-cli-code
                 no-error.
      if not available buf_hold-purch-supp
      then do:
        create buf_hold-purch-supp .
        assign
          buf_hold-purch-supp.cat-code = p-cat-code
          buf_hold-purch-supp.time-code = p-time-code
          buf_hold-purch-supp.cli-type = p-cli-type
          buf_hold-purch-supp.cli-code = p-cli-code
        .
      end.
      assign
        buf_hold-purch-supp.fact-qnty             =  buf_hold-purch-supp.fact-qnty            +  v-fact-qnty
        buf_hold-purch-supp.purch-sum-base        =  buf_hold-purch-supp.purch-sum-base       +  v-purch-sum-base
        buf_hold-purch-supp.purch-sum-rubl        =  buf_hold-purch-supp.purch-sum-rubl       +  v-purch-sum-rubl
        buf_hold-purch-supp.purch-VAT-base        =  buf_hold-purch-supp.purch-VAT-base       +  v-purch-VAT-base
        buf_hold-purch-supp.purch-VAT-rubl        =  buf_hold-purch-supp.purch-VAT-rubl       +  v-purch-VAT-rubl
        buf_hold-purch-supp.purch-SLT-base        =  buf_hold-purch-supp.purch-SLT-base       +  v-purch-SLT-base
        buf_hold-purch-supp.purch-SLT-rubl        =  buf_hold-purch-supp.purch-SLT-rubl       +  v-purch-SLT-rubl
        buf_hold-purch-supp.purch-road-tax-base   =  buf_hold-purch-supp.purch-road-tax-base  +  v-purch-road-tax-base
        buf_hold-purch-supp.purch-road-tax-rubl   =  buf_hold-purch-supp.purch-road-tax-rubl  +  v-purch-road-tax-rubl
        buf_hold-purch-supp.purch-excise-base     =  buf_hold-purch-supp.purch-excise-base    +  v-purch-excise-base
        buf_hold-purch-supp.purch-excise-rubl     =  buf_hold-purch-supp.purch-excise-rubl    +  v-purch-excise-rubl
        buf_hold-purch-supp.purch-transport-base  =  buf_hold-purch-supp.purch-transport-base +  v-purch-transport-base
        buf_hold-purch-supp.purch-transport-rubl  =  buf_hold-purch-supp.purch-transport-rubl +  v-purch-transport-rubl
        buf_hold-purch-supp.purch-other-base      =  buf_hold-purch-supp.purch-other-base     +  v-purch-other-base
        buf_hold-purch-supp.purch-other-rubl      =  buf_hold-purch-supp.purch-other-rubl     +  v-purch-other-rubl
        buf_hold-purch-supp.purch-discnt-base     =  buf_hold-purch-supp.purch-discnt-base    +  v-purch-discnt-base
        buf_hold-purch-supp.purch-discnt-rubl     =  buf_hold-purch-supp.purch-discnt-rubl    +  v-purch-discnt-rubl
      .

      /*обноление записи hold-purch-supp-gds*/

      find first buf_hold-purch-supp-gds exclusive-lock where
                 buf_hold-purch-supp-gds.cat-code = p-cat-code AND
                 buf_hold-purch-supp-gds.time-code = p-time-code AND
                 buf_hold-purch-supp-gds.gds-code = buf_goods.gds-code AND
                 buf_hold-purch-supp-gds.cli-type = p-cli-type AND
                 buf_hold-purch-supp-gds.cli-code = p-cli-code
                 no-error.
      if not available buf_hold-purch-supp-gds
      then do:
        create buf_hold-purch-supp-gds .
        assign
          buf_hold-purch-supp-gds.cat-code = p-cat-code
          buf_hold-purch-supp-gds.time-code = p-time-code
          buf_hold-purch-supp-gds.cli-type = p-cli-type
          buf_hold-purch-supp-gds.cli-code = p-cli-code
          buf_hold-purch-supp-gds.gds-code = buf_goods.gds-code
        .
      end.
      assign
        buf_hold-purch-supp-gds.fact-qnty             =  buf_hold-purch-supp-gds.fact-qnty            +  v-fact-qnty
        buf_hold-purch-supp-gds.purch-sum-base        =  buf_hold-purch-supp-gds.purch-sum-base       +  v-purch-sum-base
        buf_hold-purch-supp-gds.purch-sum-rubl        =  buf_hold-purch-supp-gds.purch-sum-rubl       +  v-purch-sum-rubl
        buf_hold-purch-supp-gds.purch-VAT-base        =  buf_hold-purch-supp-gds.purch-VAT-base       +  v-purch-VAT-base
        buf_hold-purch-supp-gds.purch-VAT-rubl        =  buf_hold-purch-supp-gds.purch-VAT-rubl       +  v-purch-VAT-rubl
        buf_hold-purch-supp-gds.purch-SLT-base        =  buf_hold-purch-supp-gds.purch-SLT-base       +  v-purch-SLT-base
        buf_hold-purch-supp-gds.purch-SLT-rubl        =  buf_hold-purch-supp-gds.purch-SLT-rubl       +  v-purch-SLT-rubl
        buf_hold-purch-supp-gds.purch-road-tax-base   =  buf_hold-purch-supp-gds.purch-road-tax-base  +  v-purch-road-tax-base
        buf_hold-purch-supp-gds.purch-road-tax-rubl   =  buf_hold-purch-supp-gds.purch-road-tax-rubl  +  v-purch-road-tax-rubl
        buf_hold-purch-supp-gds.purch-excise-base     =  buf_hold-purch-supp-gds.purch-excise-base    +  v-purch-excise-base
        buf_hold-purch-supp-gds.purch-excise-rubl     =  buf_hold-purch-supp-gds.purch-excise-rubl    +  v-purch-excise-rubl
        buf_hold-purch-supp-gds.purch-transport-base  =  buf_hold-purch-supp-gds.purch-transport-base +  v-purch-transport-base
        buf_hold-purch-supp-gds.purch-transport-rubl  =  buf_hold-purch-supp-gds.purch-transport-rubl +  v-purch-transport-rubl
        buf_hold-purch-supp-gds.purch-other-base      =  buf_hold-purch-supp-gds.purch-other-base     +  v-purch-other-base
        buf_hold-purch-supp-gds.purch-other-rubl      =  buf_hold-purch-supp-gds.purch-other-rubl     +  v-purch-other-rubl
        buf_hold-purch-supp-gds.purch-discnt-base     =  buf_hold-purch-supp-gds.purch-discnt-base    +  v-purch-discnt-base
        buf_hold-purch-supp-gds.purch-discnt-rubl     =  buf_hold-purch-supp-gds.purch-discnt-rubl    +  v-purch-discnt-rubl
      .

    end.
  end.

end procedure. /* harh-calc-trn-purch */



procedure harh-calc-trn-sale :

  define input parameter p-cat-code like ub.hold-time.cat-code no-undo .
  define input parameter p-time-code like ub.hold-time.time-code no-undo .
  define input parameter p-doc-code like ub.trn-doc.doc-code no-undo .

  define variable   v-fact-qnty             like ub.hold-sale.fact-qnty            no-undo .
  define variable   v-sale-sum-base         like ub.hold-sale.purch-sum-base       no-undo .
  define variable   v-sale-sum-rubl         like ub.hold-sale.sale-sum-rubl        no-undo .
  define variable   v-sale-vat-base         like ub.hold-sale.sale-vat-base        no-undo .
  define variable   v-sale-vat-rubl         like ub.hold-sale.sale-vat-rubl        no-undo .
  define variable   v-sale-slt-base         like ub.hold-sale.sale-slt-base        no-undo .
  define variable   v-sale-slt-rubl         like ub.hold-sale.sale-slt-rubl        no-undo .
  define variable   v-sale-road-tax-base    like ub.hold-sale.sale-road-tax-base   no-undo .
  define variable   v-sale-road-tax-rubl    like ub.hold-sale.sale-road-tax-rubl   no-undo .
  define variable   v-sale-excise-base      like ub.hold-sale.sale-excise-base     no-undo .
  define variable   v-sale-excise-rubl      like ub.hold-sale.sale-excise-rubl     no-undo .
  define variable   v-sale-transport-base   like ub.hold-sale.sale-transport-base  no-undo .
  define variable   v-sale-transport-rubl   like ub.hold-sale.sale-transport-rubl  no-undo .
  define variable   v-sale-other-base       like ub.hold-sale.sale-other-base      no-undo .
  define variable   v-sale-other-rubl       like ub.hold-sale.sale-other-rubl      no-undo .
  define variable   v-sale-discnt-base      like ub.hold-sale.sale-discnt-base     no-undo .
  define variable   v-sale-discnt-rubl      like ub.hold-sale.sale-discnt-rubl     no-undo .
  define variable   v-purch-sum-base        like ub.hold-sale.purch-sum-base       no-undo .
  define variable   v-purch-sum-rubl        like ub.hold-sale.purch-sum-rubl       no-undo .
  define variable   v-purch-vat-base        like ub.hold-sale.purch-vat-base       no-undo .
  define variable   v-purch-vat-rubl        like ub.hold-sale.purch-vat-rubl       no-undo .
  define variable   v-purch-slt-base        like ub.hold-sale.purch-slt-base       no-undo .
  define variable   v-purch-slt-rubl        like ub.hold-sale.purch-slt-rubl       no-undo .
  define variable   v-purch-road-tax-base   like ub.hold-sale.purch-road-tax-base  no-undo .
  define variable   v-purch-road-tax-rubl   like ub.hold-sale.purch-road-tax-rubl  no-undo .
  define variable   v-purch-excise-base     like ub.hold-sale.purch-excise-base    no-undo .
  define variable   v-purch-excise-rubl     like ub.hold-sale.purch-excise-rubl    no-undo .
  define variable   v-purch-transport-base  like ub.hold-sale.purch-transport-base no-undo .
  define variable   v-purch-transport-rubl  like ub.hold-sale.purch-transport-rubl no-undo .
  define variable   v-purch-other-base      like ub.hold-sale.purch-other-base     no-undo .
  define variable   v-purch-other-rubl      like ub.hold-sale.purch-other-rubl     no-undo .
  define variable   v-purch-discnt-base     like ub.hold-sale.purch-discnt-base    no-undo .
  define variable   v-purch-discnt-rubl     like ub.hold-sale.purch-discnt-rubl    no-undo .
  define variable   v-profit-base           like ub.hold-sale.profit-base          no-undo .
  define variable   v-profit-rubl           like ub.hold-sale.profit-rubl          no-undo .
  define variable   v-node-code like ub.hold-purch-grp.node-code no-undo .

  define buffer buf_goods for ub.goods .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_hold-sale for ub.hold-sale .
  define buffer buf_hold-sale-grp for ub.hold-sale-grp .

  do
  on error undo, return error
  :

    for each buf_doc-line no-lock
      where buf_doc-line.doc-code = p-doc-code
    on error undo, return error
    :
      /*найдем все данные для закладки в архив*/
      run holdprts-purch-values in this-procedure
        (input  p-doc-code
        ,input  buf_doc-line.artic
        ,input  buf_doc-line.prod-type
        ,input  buf_doc-line.prod-code
        ,output v-fact-qnty
        ,output v-purch-sum-base
        ,output v-purch-sum-rubl
        ,output v-purch-VAT-base
        ,output v-purch-VAT-rubl
        ,output v-purch-SLT-base
        ,output v-purch-SLT-rubl
        ,output v-purch-road-tax-base
        ,output v-purch-road-tax-rubl
        ,output v-purch-excise-base
        ,output v-purch-excise-rubl
        ,output v-purch-transport-base
        ,output v-purch-transport-rubl
        ,output v-purch-other-base
        ,output v-purch-other-rubl
        ,output v-purch-discnt-base
        ,output v-purch-discnt-rubl
        ) .

      run holdprts-sale-values in this-procedure
        (input  p-doc-code
        ,input  buf_doc-line.artic
        ,input  buf_doc-line.prod-type
        ,input  buf_doc-line.prod-code
        ,output v-fact-qnty
        ,output v-sale-sum-base
        ,output v-sale-sum-rubl
        ,output v-sale-VAT-base
        ,output v-sale-VAT-rubl
        ,output v-sale-SLT-base
        ,output v-sale-SLT-rubl
        ,output v-sale-road-tax-base
        ,output v-sale-road-tax-rubl
        ,output v-sale-excise-base
        ,output v-sale-excise-rubl
        ,output v-sale-transport-base
        ,output v-sale-transport-rubl
        ,output v-sale-other-base
        ,output v-sale-other-rubl
        ,output v-sale-discnt-base
        ,output v-sale-discnt-rubl
        ) .

      /* поиск товара */
      find first buf_goods no-lock
        where buf_goods.artic = buf_doc-line.artic
          and buf_goods.prod-type = buf_doc-line.prod-type
          and buf_goods.prod-code = buf_doc-line.prod-code
        no-error .
      if not available buf_goods
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при заполнении межфирменного архива по строке документа продажи" skip
          "Документ" p-doc-code skip
          "cat-code" p-cat-code skip
          "time-code" p-time-code skip
          "Товар" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code
          view-as alert-box error .
        return error .
      end.

      /* регистрация товара */
      run harh-set-good in this-procedure
        (input p-cat-code
        ,input p-time-code
        ,input buf_goods.gds-code
        ,input buf_goods.grp-name
        ,output v-node-code
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при регистрации товара в межфирменном архиве" skip
          "Товар" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code SKIP
          "cat-code" p-cat-code SKIP
          "time-code" p-time-code
          view-as alert-box error .
        return error .
      end.

      /* обновление записей hold-sale */
      find first buf_hold-sale exclusive-lock
        where buf_hold-sale.cat-code  = p-cat-code
          and buf_hold-sale.time-code = p-time-code
          and buf_hold-sale.gds-code  = buf_goods.gds-code
        no-error .
      if not available buf_hold-sale
      then do:
        create buf_hold-sale .
        assign
          buf_hold-sale.cat-code  = p-cat-code
          buf_hold-sale.time-code = p-time-code
          buf_hold-sale.gds-code  = buf_goods.gds-code
        .
      end.

      assign
        buf_hold-sale.fact-qnty            = buf_hold-sale.fact-qnty            + v-fact-qnty
        buf_hold-sale.purch-sum-base       = buf_hold-sale.purch-sum-base       + v-purch-sum-base
        buf_hold-sale.purch-sum-rubl       = buf_hold-sale.purch-sum-rubl       + v-purch-sum-rubl
        buf_hold-sale.purch-VAT-base       = buf_hold-sale.purch-VAT-base       + v-purch-VAT-base
        buf_hold-sale.purch-VAT-rubl       = buf_hold-sale.purch-VAT-rubl       + v-purch-VAT-rubl
        buf_hold-sale.purch-SLT-base       = buf_hold-sale.purch-SLT-base       + v-purch-SLT-base
        buf_hold-sale.purch-SLT-rubl       = buf_hold-sale.purch-SLT-rubl       + v-purch-SLT-rubl
        buf_hold-sale.purch-road-tax-base  = buf_hold-sale.purch-road-tax-base  + v-purch-road-tax-base
        buf_hold-sale.purch-road-tax-rubl  = buf_hold-sale.purch-road-tax-rubl  + v-purch-road-tax-rubl
        buf_hold-sale.purch-excise-base    = buf_hold-sale.purch-excise-base    + v-purch-excise-base
        buf_hold-sale.purch-excise-rubl    = buf_hold-sale.purch-excise-rubl    + v-purch-excise-rubl
        buf_hold-sale.purch-transport-base = buf_hold-sale.purch-transport-base + v-purch-transport-base
        buf_hold-sale.purch-transport-rubl = buf_hold-sale.purch-transport-rubl + v-purch-transport-rubl
        buf_hold-sale.purch-other-base     = buf_hold-sale.purch-other-base     + v-purch-other-base
        buf_hold-sale.purch-other-rubl     = buf_hold-sale.purch-other-rubl     + v-purch-other-rubl
        buf_hold-sale.purch-discnt-base    = buf_hold-sale.purch-discnt-base    + v-purch-discnt-base
        buf_hold-sale.purch-discnt-rubl    = buf_hold-sale.purch-discnt-rubl    + v-purch-discnt-rubl
        buf_hold-sale.sale-sum-base        = buf_hold-sale.sale-sum-base        + v-sale-sum-base
        buf_hold-sale.sale-sum-rubl        = buf_hold-sale.sale-sum-rubl        + v-sale-sum-rubl
        buf_hold-sale.sale-VAT-base        = buf_hold-sale.sale-VAT-base        + v-sale-VAT-base
        buf_hold-sale.sale-VAT-rubl        = buf_hold-sale.sale-VAT-rubl        + v-sale-VAT-rubl
        buf_hold-sale.sale-SLT-base        = buf_hold-sale.sale-SLT-base        + v-sale-SLT-base
        buf_hold-sale.sale-SLT-rubl        = buf_hold-sale.sale-SLT-rubl        + v-sale-SLT-rubl
        buf_hold-sale.sale-road-tax-base   = buf_hold-sale.sale-road-tax-base   + v-sale-road-tax-base
        buf_hold-sale.sale-road-tax-rubl   = buf_hold-sale.sale-road-tax-rubl   + v-sale-road-tax-rubl
        buf_hold-sale.sale-excise-base     = buf_hold-sale.sale-excise-base     + v-sale-excise-base
        buf_hold-sale.sale-excise-rubl     = buf_hold-sale.sale-excise-rubl     + v-sale-excise-rubl
        buf_hold-sale.sale-transport-base  = buf_hold-sale.sale-transport-base  + v-sale-transport-base
        buf_hold-sale.sale-transport-rubl  = buf_hold-sale.sale-transport-rubl  + v-sale-transport-rubl
        buf_hold-sale.sale-other-base      = buf_hold-sale.sale-other-base      + v-sale-other-base
        buf_hold-sale.sale-other-rubl      = buf_hold-sale.sale-other-rubl      + v-sale-other-rubl
        buf_hold-sale.sale-discnt-base     = buf_hold-sale.sale-discnt-base     + v-sale-discnt-base
        buf_hold-sale.sale-discnt-rubl     = buf_hold-sale.sale-discnt-rubl     + v-sale-discnt-rubl
        buf_hold-sale.profit-base          = buf_hold-sale.profit-base          + v-profit-base
        buf_hold-sale.profit-rubl          = buf_hold-sale.profit-rubl          + v-profit-rubl
      .

      /*обновление записей hold-sale-grp*/
      find first buf_hold-sale-grp exclusive-lock where
                 buf_hold-sale-grp.cat-code = p-cat-code AND
                 buf_hold-sale-grp.time-code = p-time-code AND
                 buf_hold-sale-grp.node-code = v-node-code no-error.
      if not available buf_hold-sale-grp
      then do:
        create buf_hold-sale-grp .
        assign
          buf_hold-sale-grp.cat-code = p-cat-code
          buf_hold-sale-grp.time-code = p-time-code
          buf_hold-sale-grp.node-code = v-node-code
        .
      end.
      assign
        buf_hold-sale-grp.fact-qnty             =  buf_hold-sale-grp.fact-qnty            +  v-fact-qnty
        buf_hold-sale-grp.purch-sum-base        =  buf_hold-sale-grp.purch-sum-base       +  v-purch-sum-base
        buf_hold-sale-grp.purch-sum-rubl        =  buf_hold-sale-grp.purch-sum-rubl       +  v-purch-sum-rubl
        buf_hold-sale-grp.purch-VAT-base        =  buf_hold-sale-grp.purch-VAT-base       +  v-purch-VAT-base
        buf_hold-sale-grp.purch-VAT-rubl        =  buf_hold-sale-grp.purch-VAT-rubl       +  v-purch-VAT-rubl
        buf_hold-sale-grp.purch-SLT-base        =  buf_hold-sale-grp.purch-SLT-base       +  v-purch-SLT-base
        buf_hold-sale-grp.purch-SLT-rubl        =  buf_hold-sale-grp.purch-SLT-rubl       +  v-purch-SLT-rubl
        buf_hold-sale-grp.purch-road-tax-base   =  buf_hold-sale-grp.purch-road-tax-base  +  v-purch-road-tax-base
        buf_hold-sale-grp.purch-road-tax-rubl   =  buf_hold-sale-grp.purch-road-tax-rubl  +  v-purch-road-tax-rubl
        buf_hold-sale-grp.purch-excise-base     =  buf_hold-sale-grp.purch-excise-base    +  v-purch-excise-base
        buf_hold-sale-grp.purch-excise-rubl     =  buf_hold-sale-grp.purch-excise-rubl    +  v-purch-excise-rubl
        buf_hold-sale-grp.purch-transport-base  =  buf_hold-sale-grp.purch-transport-base +  v-purch-transport-base
        buf_hold-sale-grp.purch-transport-rubl  =  buf_hold-sale-grp.purch-transport-rubl +  v-purch-transport-rubl
        buf_hold-sale-grp.purch-other-base      =  buf_hold-sale-grp.purch-other-base     +  v-purch-other-base
        buf_hold-sale-grp.purch-other-rubl      =  buf_hold-sale-grp.purch-other-rubl     +  v-purch-other-rubl
        buf_hold-sale-grp.purch-discnt-base     =  buf_hold-sale-grp.purch-discnt-base    +  v-purch-discnt-base
        buf_hold-sale-grp.purch-discnt-rubl     =  buf_hold-sale-grp.purch-discnt-rubl    +  v-purch-discnt-rubl
        buf_hold-sale-grp.sale-sum-base         =  buf_hold-sale-grp.sale-sum-base        +  v-sale-sum-base
        buf_hold-sale-grp.sale-sum-rubl         =  buf_hold-sale-grp.sale-sum-rubl        +  v-sale-sum-rubl
        buf_hold-sale-grp.sale-VAT-base         =  buf_hold-sale-grp.sale-VAT-base        +  v-sale-VAT-base
        buf_hold-sale-grp.sale-VAT-rubl         =  buf_hold-sale-grp.sale-VAT-rubl        +  v-sale-VAT-rubl
        buf_hold-sale-grp.sale-SLT-base         =  buf_hold-sale-grp.sale-SLT-base        +  v-sale-SLT-base
        buf_hold-sale-grp.sale-SLT-rubl         =  buf_hold-sale-grp.sale-SLT-rubl        +  v-sale-SLT-rubl
        buf_hold-sale-grp.sale-road-tax-base    =  buf_hold-sale-grp.sale-road-tax-base   +  v-sale-road-tax-base
        buf_hold-sale-grp.sale-road-tax-rubl    =  buf_hold-sale-grp.sale-road-tax-rubl   +  v-sale-road-tax-rubl
        buf_hold-sale-grp.sale-excise-base      =  buf_hold-sale-grp.sale-excise-base     +  v-sale-excise-base
        buf_hold-sale-grp.sale-excise-rubl      =  buf_hold-sale-grp.sale-excise-rubl     +  v-sale-excise-rubl
        buf_hold-sale-grp.sale-transport-base   =  buf_hold-sale-grp.sale-transport-base  +  v-sale-transport-base
        buf_hold-sale-grp.sale-transport-rubl   =  buf_hold-sale-grp.sale-transport-rubl  +  v-sale-transport-rubl
        buf_hold-sale-grp.sale-other-base       =  buf_hold-sale-grp.sale-other-base      +  v-sale-other-base
        buf_hold-sale-grp.sale-other-rubl       =  buf_hold-sale-grp.sale-other-rubl      +  v-sale-other-rubl
        buf_hold-sale-grp.sale-discnt-base      =  buf_hold-sale-grp.sale-discnt-base     +  v-sale-discnt-base
        buf_hold-sale-grp.sale-discnt-rubl      =  buf_hold-sale-grp.sale-discnt-rubl     +  v-sale-discnt-rubl
        buf_hold-sale-grp.profit-base           =  buf_hold-sale-grp.profit-base          +  v-profit-base
        buf_hold-sale-grp.profit-rubl           =  buf_hold-sale-grp.profit-rubl          +  v-profit-rubl
      .

    end.
  end.

end procedure. /* harh-calc-trn-sale */


procedure harh-set-good :

  define input  parameter p-cat-code  like ub.hold-time.cat-code no-undo .
  define input  parameter p-time-code like ub.hold-time.time-code no-undo .
  define input  parameter p-gds-code  like ub.goods.gds-code no-undo .
  define input  parameter p-grp-name  like ub.goods.grp-name no-undo .
  define output parameter p-node-code like ub.hold-gds-grp.node-code no-undo .

  define variable v-grp-name like ub.hold-gds-grp.grp-name no-undo .
  define variable v-node-name like ub.hold-gds-grp.node-name no-undo .
  define variable v-upper-code like ub.hold-gds-grp.upper-code no-undo .
  define variable v-node-code like ub.hold-gds-grp.node-code no-undo .
  define variable v-ii as integer no-undo .
  define variable v-is-term like ub.hold-gds-grp.is-term no-undo .
  define variable v-num-entries as integer no-undo .

  define buffer locked_hold-goods for ub.hold-goods .
  define buffer locked_hold-gds-grp for ub.hold-gds-grp .

  do
  on error undo, return error
  :

    find first locked_hold-goods exclusive-lock
      where locked_hold-goods.cat-code = p-cat-code
        and locked_hold-goods.time-code = p-time-code
        and locked_hold-goods.gds-code = p-gds-code
      no-error .
    if available locked_hold-goods
    then do:
      /* товар уже добавлен в архив */
      /* ничего не делаем */
    end.
    else do:
      create locked_hold-goods .
      assign
        locked_hold-goods.cat-code = p-cat-code
        locked_hold-goods.time-code = p-time-code
        locked_hold-goods.gds-code = p-gds-code
        locked_hold-goods.grp-name = p-grp-name
      .
    end.

    /*регистрация в группе */
    /*этот код будет работать и для старого и для нового типа имени full-grp-name*/
    assign
      v-num-entries = num-entries(right-trim(p-grp-name, {&delim-grp}), {&delim-grp})
    .
    do v-ii = 1 to v-num-entries
    on error undo, return error
    :
      assign
        v-node-name = entry(v-ii, p-grp-name, {&delim-grp})
        v-grp-name = v-grp-name + (if v-grp-name = "":U
                                  then "":U
                                  else {&delim-grp}) +
                    entry(v-ii, p-grp-name, {&delim-grp})
        v-is-term = (if v-ii = v-num-entries
                    then yes
                    else no)
      .
      run harh-create-grp-node in this-procedure
        (input p-cat-code
        ,input p-time-code
        ,input v-node-name
        ,input v-grp-name
        ,input v-upper-code
        ,input-output v-node-code
        ,input v-is-term
        ) no-error.
      if error-status :error
      then do:
        message
        vss-workfile vss-revision vss-description skip
        "Ошибка при заполнении межфирменных архивов" SKIP
        "Группа товаров" p-grp-name
        view-as alert-box error .
        return error .
      end.
      /*спускаемся вниз*/
      assign
        v-upper-code = v-node-code
      .
    end. /*do v-ii*/

    /*товару присваиваем номер узла - самого нижнего*/
    assign
      locked_hold-goods.node-code = v-node-code
      p-node-code                 = v-node-code
    .
  end.

end procedure. /* harh-set-good */


procedure harh-create-grp-node :

  define input parameter p-cat-code like ub.hold-time.cat-code no-undo .
  define input parameter p-time-code like ub.hold-time.time-code no-undo .
  define input parameter p-node-name like ub.hold-gds-grp.node-name no-undo .
  define input parameter p-grp-name like ub.hold-gds-grp.grp-name no-undo .
  define input parameter p-upper-code like ub.hold-gds-grp.upper-code no-undo .
  define input-output parameter p-node-code like ub.hold-gds-grp.node-code no-undo .
  define input parameter p-is-term like ub.hold-gds-grp.is-term no-undo .

  define buffer locked_hold-gds-grp for ub.hold-gds-grp .
  define buffer last_hold-gds-grp for ub.hold-gds-grp.

  do
  on error undo, return error
  :
    /*ищем группу группу */
    find first locked_hold-gds-grp exclusive-lock
      where locked_hold-gds-grp.cat-code = p-cat-code
        and locked_hold-gds-grp.time-code = p-time-code
        and locked_hold-gds-grp.node-name = p-node-name
        and locked_hold-gds-grp.upper-code = p-upper-code
      no-error .
    if available locked_hold-gds-grp
    then do:
      assign
        p-node-code = locked_hold-gds-grp.node-code
      .
      return.
    end.
    else do:
      /*ищем послед*/
      find last last_hold-gds-grp no-lock
        where last_hold-gds-grp.cat-code = p-cat-code
          and last_hold-gds-grp.time-code = p-time-code
        use-index pi
        no-error .

      /*создаем*/
      create locked_hold-gds-grp .
      assign
        locked_hold-gds-grp.cat-code = p-cat-code
        locked_hold-gds-grp.time-code = p-time-code
        locked_hold-gds-grp.node-name = p-node-name
        locked_hold-gds-grp.grp-name = right-trim(p-grp-name, {&delim-grp}) + {&delim-grp}
        locked_hold-gds-grp.upper-code = p-upper-code
        locked_hold-gds-grp.node-code = (if available last_hold-gds-grp
                                          then (last_hold-gds-grp.node-code + 1)
                                          else 1
                                          )
        locked_hold-gds-grp.is-term = p-is-term
        p-node-code = locked_hold-gds-grp.node-code
      .
    end.
  end.

end procedure. /* harh-create-grp-node */

