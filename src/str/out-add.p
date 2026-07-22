block-level on error undo, throw.

/*

$Revision: 91c8196f6fee, 3209, rls $
$Author: SSlivenko $
$Date: 2022/12/27 12:54:28 $
$Workfile: out-add.p $
$Archive: str/out-add.p $

Добавление строк в РН, СН, ВН при заданном товаре
Узел для развязки ветвей создания и изменения компонентов документов а-ля расходная накладна

Автор: Чернова Светлана Александровна
Дата создания: 11/20/06
Author: Svetlana Chernova
Creation date: 11/20/06

create: Суслов Алексей Юрьевич
Creation date: 09/13/05


*/

&scop calc-doc t-doc

define input parameter ParParentProc as handle    no-undo .
define input parameter pardoc-rec    as recid     no-undo .
define input parameter parline-rec   as recid     no-undo .
define input parameter parprt-rec    as recid     no-undo .
define input parameter pargds-rec    as recid     no-undo .
define input parameter work-mode     as character no-undo format "x(30)":U .
define input parameter parvalue      as character no-undo .

define variable vss-revision    as character no-undo initial "$Revision: 91c8196f6fee, 3209, rls $":U .
define variable vss-author      as character no-undo initial "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo initial "$Date: 2022/12/27 12:54:28 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: out-add.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/out-add.p $":U .
define variable vss-description as character no-undo initial "Добавление строк в РН, СН, ВН при заданном товаре":U .

{ cmp/vssrevis.i "substitute('&1|&2':u,work-mode,parvalue)" }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/get-pr.i   def }
{ str/tt-tax.i   new }
{ str/lib-trn.i  }
{ str/lib-calc.i }
{ str/libbcrcn.i }
{ cmp/croslist.i }
{ gbl/lineattr.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ str/getctxtp.i def }
{ str/getctxtp.i get }
{ gbl/getsect.i  def }
{ ref/gds-attr.i    }
{ utl/gtin.i }

define buffer t-doc      for ub.trn-doc .
define buffer p-doc-line for ub.doc-line .
define buffer p-goods    for ub.goods .
define buffer bf_gds-obj for ub.gds-obj .
define buffer bf-parts   for ub.parts .
define buffer bf_doc-pl  for ub.doc-pl .
define buffer bf_parts   for ub.parts.
define buffer bf_marking-lines for ub.marking-lines .
define buffer in_parts   for ub.parts.

define variable part-list                                 as   character initial ""       no-undo. /* список бар-кодов партий для привязки места       */
define variable add-sens                                  as   logical                    no-undo. /* активна ли кнопка добавить в документе : yes / no - вызов из документа*/
define variable g-type                                    as   character initial ?        no-undo. /* тип строк документа - товар / услуга */
define variable qnty-str                                  as   character                  no-undo. /* строка количества по данному бар-коду со сканера */
define variable rate                                      as   decimal                    no-undo. /* коэффициент для единиц из бар-кода        */
define variable is-all                                    as   logical                    no-undo.
define variable b-c                                       as   integer                    no-undo. /* обрабатываемый бар-код                           */
define variable line-mode                                 as   character                  no-undo.

define variable v-is-return                               as   logical                    no-undo. /* для оформления возврата через расход */
{ str/bc-res.i "processing" "mes" }

define variable o-total-doc-line_tot-ovnew                like ub.trn-doc.tot-ov          no-undo.
define variable o-total-doc-line_fact-rublnew             like ub.trn-doc.fact-rubl       no-undo.
define variable o-total-doc-line_fact-basenew             like ub.trn-doc.fact-base       no-undo.
define variable o-total-doc-line_fact-qntynew             like ub.trn-doc.fact-qnty       no-undo.
define variable o-total-doc-line_doc-qntynew              like ub.trn-doc.doc-qnty        no-undo.
define variable o-total-doc-line_cli-qntynew              like ub.trn-doc.cli-qnty        no-undo.
define variable o-total-doc-line_tot-ovold                like ub.trn-doc.tot-ov          no-undo.
define variable o-total-doc-line_fact-rublold             like ub.trn-doc.fact-rubl       no-undo.
define variable o-total-doc-line_fact-baseold             like ub.trn-doc.fact-base       no-undo.
define variable o-total-doc-line_fact-qntyold             like ub.trn-doc.fact-qnty       no-undo.
define variable o-total-doc-line_doc-qntyold              like ub.trn-doc.doc-qnty        no-undo.
define variable o-total-doc-line_cli-qntyold              like ub.trn-doc.cli-qnty        no-undo.

define variable varagsum-base-docnew                      like ub.gds-dtl.price-base      no-undo.
define variable varagsum-rubl-docnew                      like ub.gds-dtl.price-rubl      no-undo.
define variable varagsum-base-factnew                     like ub.gds-dtl.price-base      no-undo.
define variable varagsum-rubl-factnew                     like ub.gds-dtl.price-rubl      no-undo.
define variable varagsum-doc-qntynew                      like ub.gds-dtl.doc-qnty        no-undo.
define variable varagsum-fact-qntynew                     like ub.gds-dtl.fact-qnty       no-undo.
define variable varagcountnew                             as   integer                    no-undo.
define variable varagsum-base-docold                      like ub.gds-dtl.price-base      no-undo.
define variable varagsum-rubl-docold                      like ub.gds-dtl.price-rubl      no-undo.
define variable varagsum-base-factold                     like ub.gds-dtl.price-base      no-undo.
define variable varagsum-rubl-factold                     like ub.gds-dtl.price-rubl      no-undo.
define variable varagsum-doc-qntyold                      like ub.gds-dtl.doc-qnty        no-undo.
define variable varagsum-fact-qntyold                     like ub.gds-dtl.fact-qnty       no-undo.
define variable varagcountold                             as   integer                    no-undo.

define variable varroad-tax-fact-baseold                  like ub.gds-dtl.price-base      no-undo.
define variable varexcise-fact-baseold                    like ub.gds-dtl.price-base      no-undo.
define variable varslt-fact-baseold                       like ub.gds-dtl.price-base      no-undo.
define variable varvat-fact-baseold                       like ub.gds-dtl.price-base      no-undo.
define variable varslt-doc-baseold                        like ub.gds-dtl.price-base      no-undo.
define variable varvat-doc-baseold                        like ub.gds-dtl.price-base      no-undo.
define variable varsum-fact-out-dsv-baseold               like ub.gds-dtl.price-base      no-undo.
define variable varroad-tax-fact-rublold                  like ub.gds-dtl.price-base      no-undo.
define variable varexcise-fact-rublold                    like ub.gds-dtl.price-base      no-undo.
define variable varslt-fact-rublold                       like ub.gds-dtl.price-base      no-undo.
define variable varvat-fact-rublold                       like ub.gds-dtl.price-base      no-undo.
define variable varslt-doc-rublold                        like ub.gds-dtl.price-base      no-undo.
define variable varvat-doc-rublold                        like ub.gds-dtl.price-base      no-undo.
define variable varsum-fact-out-dsv-rublold               like ub.gds-dtl.price-base      no-undo.
define variable varsum-fact-out-dsc-baseold               like ub.gds-dtl.price-base      no-undo.
define variable varsum-fact-out-dsc-rublold               like ub.gds-dtl.price-base      no-undo.
define variable varsum-fact-curold                        like ub.gds-dtl.price-base      no-undo.
define variable varov-fact-baseold                        like ub.gds-dtl.price-base      no-undo.
define variable varov-vat-fact-baseold                    like ub.gds-dtl.price-base      no-undo.
define variable varsum-doc-curold                         like ub.gds-dtl.price-base      no-undo.
define variable varov-doc-baseold                         like ub.gds-dtl.price-base      no-undo.
define variable varov-vat-doc-baseold                     like ub.gds-dtl.price-base      no-undo.
define variable varsum-doc-baseold                        like ub.gds-dtl.price-base      no-undo.
define variable varsum-doc-rublold                        like ub.gds-dtl.price-base      no-undo.
define variable varroad-tax-factold                       like ub.gds-dtl.price-base      no-undo.
define variable varexcise-factold                         like ub.gds-dtl.price-base      no-undo.
define variable varroad-tax-docold                        like ub.gds-dtl.price-base      no-undo.
define variable varexcise-docold                          like ub.gds-dtl.price-base      no-undo.
define variable vardiscnt-base-docold                     like ub.gds-dtl.price-base      no-undo.
define variable vardiscnt-rubl-docold                     like ub.gds-dtl.price-base      no-undo.
define variable vardiscnt-base-factold                    like ub.gds-dtl.price-base      no-undo.
define variable vardiscnt-rubl-factold                    like ub.gds-dtl.price-base      no-undo.

define variable varroad-tax-fact-basenew                  like ub.gds-dtl.price-base      no-undo.
define variable varexcise-fact-basenew                    like ub.gds-dtl.price-base      no-undo.
define variable varslt-fact-basenew                       like ub.gds-dtl.price-base      no-undo.
define variable varvat-fact-basenew                       like ub.gds-dtl.price-base      no-undo.
define variable varslt-doc-basenew                        like ub.gds-dtl.price-base      no-undo.
define variable varvat-doc-basenew                        like ub.gds-dtl.price-base      no-undo.
define variable varsum-fact-out-dsv-basenew               like ub.gds-dtl.price-base      no-undo.
define variable varroad-tax-fact-rublnew                  like ub.gds-dtl.price-base      no-undo.
define variable varexcise-fact-rublnew                    like ub.gds-dtl.price-base      no-undo.
define variable varslt-fact-rublnew                       like ub.gds-dtl.price-base      no-undo.
define variable varvat-fact-rublnew                       like ub.gds-dtl.price-base      no-undo.
define variable varslt-doc-rublnew                        like ub.gds-dtl.price-base      no-undo.
define variable varvat-doc-rublnew                        like ub.gds-dtl.price-base      no-undo.
define variable varsum-fact-out-dsv-rublnew               like ub.gds-dtl.price-base      no-undo.
define variable varsum-fact-out-dsc-basenew               like ub.gds-dtl.price-base      no-undo.
define variable varsum-fact-out-dsc-rublnew               like ub.gds-dtl.price-base      no-undo.
define variable varsum-fact-curnew                        like ub.gds-dtl.price-base      no-undo.
define variable varov-fact-basenew                        like ub.gds-dtl.price-base      no-undo.
define variable varov-vat-fact-basenew                    like ub.gds-dtl.price-base      no-undo.
define variable varsum-doc-curnew                         like ub.gds-dtl.price-base      no-undo.
define variable varov-doc-basenew                         like ub.gds-dtl.price-base      no-undo.
define variable varov-vat-doc-basenew                     like ub.gds-dtl.price-base      no-undo.
define variable varsum-doc-basenew                        like ub.gds-dtl.price-base      no-undo.
define variable varsum-doc-rublnew                        like ub.gds-dtl.price-base      no-undo.
define variable varroad-tax-factnew                       like ub.gds-dtl.price-base      no-undo.
define variable varexcise-factnew                         like ub.gds-dtl.price-base      no-undo.
define variable varroad-tax-docnew                        like ub.gds-dtl.price-base      no-undo.
define variable varexcise-docnew                          like ub.gds-dtl.price-base      no-undo.
define variable vardiscnt-base-docnew                     like ub.gds-dtl.price-base      no-undo.
define variable vardiscnt-rubl-docnew                     like ub.gds-dtl.price-base      no-undo.
define variable vardiscnt-base-factnew                    like ub.gds-dtl.price-base      no-undo.
define variable vardiscnt-rubl-factnew                    like ub.gds-dtl.price-base      no-undo.

define variable vartotal-road-tax-fact-base               like ub.gds-dtl.price-base      no-undo.
define variable vartotal-excise-fact-base                 like ub.gds-dtl.price-base      no-undo.
define variable vartotal-slt-fact-base                    like ub.gds-dtl.price-base      no-undo.
define variable vartotal-vat-fact-base                    like ub.gds-dtl.price-base      no-undo.
define variable vartotal-slt-doc-base                     like ub.gds-dtl.price-base      no-undo.
define variable vartotal-vat-doc-base                     like ub.gds-dtl.price-base      no-undo.
define variable vartotal-sum-fact-out-dsv-base            like ub.gds-dtl.price-base      no-undo.
define variable vartotal-road-tax-fact-rubl               like ub.gds-dtl.price-base      no-undo.
define variable vartotal-excise-fact-rubl                 like ub.gds-dtl.price-base      no-undo.
define variable vartotal-slt-fact-rubl                    like ub.gds-dtl.price-base      no-undo.
define variable vartotal-vat-fact-rubl                    like ub.gds-dtl.price-base      no-undo.
define variable vartotal-slt-doc-rubl                     like ub.gds-dtl.price-base      no-undo.
define variable vartotal-vat-doc-rubl                     like ub.gds-dtl.price-base      no-undo.
define variable vartotal-sum-fact-out-dsv-rubl            like ub.gds-dtl.price-base      no-undo.
define variable vartotal-sum-fact-out-dsc-base            like ub.gds-dtl.price-base      no-undo.
define variable vartotal-sum-fact-out-dsc-rubl            like ub.gds-dtl.price-base      no-undo.
define variable vartotal-sum-fact-cur                     like ub.gds-dtl.price-base      no-undo.
define variable vartotal-ov-fact-base                     like ub.gds-dtl.price-base      no-undo.
define variable vartotal-ov-vat-fact-base                 like ub.gds-dtl.price-base      no-undo.
define variable vartotal-sum-doc-cur                      like ub.gds-dtl.price-base      no-undo.
define variable vartotal-ov-doc-base                      like ub.gds-dtl.price-base      no-undo.
define variable vartotal-ov-vat-doc-base                  like ub.gds-dtl.price-base      no-undo.
define variable vartotal-sum-doc-base                     like ub.gds-dtl.price-base      no-undo.
define variable vartotal-sum-doc-rubl                     like ub.gds-dtl.price-base      no-undo.
define variable vartotal-road-tax-fact                    like ub.gds-dtl.price-base      no-undo.
define variable vartotal-excise-fact                      like ub.gds-dtl.price-base      no-undo.
define variable vartotal-road-tax-doc                     like ub.gds-dtl.price-base      no-undo.
define variable vartotal-excise-doc                       like ub.gds-dtl.price-base      no-undo.
define variable vartotal-discnt-base-doc                  like ub.gds-dtl.price-base      no-undo.
define variable vartotal-discnt-rubl-doc                  like ub.gds-dtl.price-base      no-undo.
define variable vartotal-discnt-base-fact                 like ub.gds-dtl.price-base      no-undo.
define variable vartotal-discnt-rubl-fact                 like ub.gds-dtl.price-base      no-undo.
define variable flag-incr-disc-vat                        as   logical initial no         no-undo.
define variable flag-update                               as   logical initial no         no-undo.
define variable chg-qnty                                  like ub.gds-dtl.doc-qnty        no-undo initial ?.
define variable no-end-all-operation                      as   logical   initial yes      no-undo.
define variable varrep                                    as   logical   initial no       no-undo.
define variable unrv-qnty                                 like ub.gds-dtl.doc-qnty        no-undo.
define variable vartwo-value                              as   logical                    no-undo. /*товар с двумя единицами измерения*/
define variable v-vat-pc                                  like ub.doc-line.vat-pc         no-undo.
define variable v-slt-pc                                  like ub.doc-line.slt-pc         no-undo.
define variable v-host-code                               like sysconf.host-code          no-undo.
define variable v-tax-date                                as   date                       no-undo.
define variable is-petrol                                 as   logical                    no-undo.
define variable is-pieces                                 as   logical                    no-undo.
define variable doc-qnty-lt                               as   decimal                    no-undo.
define variable doc-qnty-kg                               as   decimal                    no-undo.
define variable fact-qnty-lt                              as   decimal                    no-undo.
define variable fact-qnty-kg                              as   decimal                    no-undo.
define variable varlog                                    as   logical                    no-undo.
define variable varpart-rec                               as   recid                      no-undo.
define variable varinv-rec                                as   recid                      no-undo.
define variable prt-mode                                  as   character                  no-undo.
define variable vardoc-qnty-doc-pl                        as   decimal                    no-undo.
define variable varfact-qnty-doc-pl                       as   decimal                    no-undo.
define variable varcli-doc-qnty-doc-pl                    as   decimal                    no-undo.
define variable varcli-fact-qnty-doc-pl                   as   decimal                    no-undo.
define variable v-round-vat-sum                           as   logical                    no-undo.
define variable v-sum-vat                                 as   decimal                    no-undo.
define variable v-node-type                               as   character                  no-undo.
define variable varvalue        as character no-undo .
define variable vartype         as character no-undo .
define variable v-message       as character no-undo .
define variable mark            as character no-undo .
define variable v-stop          as logical   no-undo init no .

{ gbl/objsrv.i }
define variable EDOParSec       as class     ibs.th.gbl.env.prmtrs.edo .


{ str/sclspref.i }

define temp-table old-gds-dtl no-undo like ub.gds-dtl.
do
on error undo, return error return-value
:


  find first t-doc where recid(t-doc) = pardoc-rec exclusive-lock.
   { gbl/getsect.i run t-doc.obj-type t-doc.obj-code {&attr-nakl_par} }
    for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = 'round-vat-sum' then v-round-vat-sum = thbjattr_thbj-attr.property-value-logical .
    end.

  /* Преценденты были */
  assign
    work-mode = trim(work-mode)
    v-is-return = false
  .
  
  if num-entries(work-mode, {&delim-par}) = 2
  then do :
    if entry(2, work-mode, {&delim-par}) begins "return"
    then do :
      v-is-return = true .
      varpart-rec = integer(trim(entry(2, work-mode, {&delim-par}), "return=")) no-error .
    end .
    work-mode = entry(1, work-mode, {&delim-par}) .
  end.

  do while no-end-all-operation
  :
    assign
      no-end-all-operation = no
    .
    /*----------------------------------------------------------------------*/
    /* Если скидка в накладной была правильно установлена                   */
    /* и изменение данной строки не влечет за собой пересчет скидок по всем */
    /* признакам накладной, то можно накатить на шапку накладной инкремент  */
    /* по НДС и скидкам                                                     */
    /*----------------------------------------------------------------------*/
    if can-do ({&d-type-list}, t-doc.discnt-type) and
        not
        (t-doc.discnt-type = {&amount} and
        not t-doc.flag_             and
        t-doc.status_ <> {&permitted}    )
    then do:
       assign
         flag-incr-disc-vat = yes
       .
    end.
    /*Разберем бар-код при заведении по бар-коду*/
    if work-mode = "b-c"
    then do:
      assign
        b-c      = int(entry(1, parvalue))
        rate     = dec(entry(2, parvalue))
        add-sens = (if entry(4, parvalue) = "yes" then yes else no)
        qnty-str = (if entry(5, parvalue) = "yes" then "1" else "0")
      .
      find ub.bar-code where ub.bar-code.b-code = b-c no-lock.
      find p-goods where p-goods.gds-code  = ub.bar-code.gds-code no-lock.
      assign
        pargds-rec = recid(p-goods)
      .
      find first ub.gds-dtl where
                ub.gds-dtl.doc-code  = t-doc.doc-code     and
                ub.gds-dtl.artic     = p-goods.artic        and
                ub.gds-dtl.prod-type = p-goods.prod-type    and
                ub.gds-dtl.prod-code = p-goods.prod-code    and
                ub.gds-dtl.prt-code  = ub.bar-code.node-code no-lock no-error.
      /*Если признак уже присутствуест в накладной до либо добавляем в него кол-во со сканера,
        либо редактируем его*/
      if available ub.gds-dtl
      then do:
        if not varrep
        then do:
          varlog = no.
          message "Такой признак уже есть в этой накладной. Вы хотите изменить его ?"
          view-as alert-box question buttons yes-no update varlog.
          if not varlog
          then do:
            return .
          end.
        end.

        assign
          parprt-rec = recid(ub.gds-dtl)
        .
        find first p-doc-line no-lock
          where p-doc-line.doc-code = t-doc.doc-code
            and ub.gds-dtl.artic     = p-doc-line.artic
            and ub.gds-dtl.prod-type = p-doc-line.prod-type
            and ub.gds-dtl.prod-code = p-doc-line.prod-code
          .
        assign
          parline-rec = recid(p-doc-line)
        .
        if entry(5, parvalue) = "no"
        then do:
          assign
            work-mode = {&update}
          .
        end.
      end.
      else do:
        assign
          parprt-rec = ?
        .
      end.
    end.
    if work-mode = {&add-def}
    or work-mode = "ЦИКЛ"
    or work-mode = "b-c"
    then do:
        find p-goods no-lock
          where recid(p-goods) = pargds-rec
          .
        { str/goods-tr.i
          recid(t-doc)
          recid(p-goods)
          no-error
        }
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры goods-tr"
            error-status :get-message(1) skip
            return-value
            view-as alert-box.
          return error.
        end.
        find p-doc-line exclusive-lock
          where p-doc-line.prod-code = p-goods.prod-code
            and p-doc-line.prod-type = p-goods.prod-type
            and p-doc-line.artic     = p-goods.artic
            and p-doc-line.doc-code  = t-doc.doc-code
          no-error .
        if available p-doc-line
        then do:
          if work-mode <> "b-c"
          then do:
            varlog = no.
            message "Такой товар уже есть в этой накладной. Вы хотите изменить его ?"
                            view-as alert-box question buttons yes-no update varlog.
            if not varlog then do:
              return error.
            end.
          end.
          assign
            parline-rec = recid(p-doc-line)
          .
        end.
        find ub.gds-prt where ub.gds-prt.upper-code = p-goods.prt-root no-lock.
    end.
    else do:
      if work-mode = {&lookup}
      or work-mode = "lookup-scale"
      or work-mode = "lookup-parts"
      then do:
        find p-doc-line no-lock
          where recid(p-doc-line) = parline-rec
          .
        find ub.gds-dtl no-lock
          where recid(ub.gds-dtl) = parprt-rec
          .
      end.
      else do:
        find p-doc-line exclusive-lock
          where recid(p-doc-line) = parline-rec
          .
        find ub.gds-dtl exclusive-lock
          where recid(ub.gds-dtl) = parprt-rec
          .
      end.

      find p-goods no-lock
        where recid(p-goods) = pargds-rec
        .
      find ub.gds-prt no-lock
        where ub.gds-prt.node-code = ub.gds-dtl.prt-code
        .
    end.

    find first units no-lock
      where units.unit-name = p-goods.unit-base
      .
    if lookup({&twounit}, units.type) > 0
    then do:
      assign
        vartwo-value = yes
      .
    end.
    else do:
      assign
        vartwo-value  = no
      .
    end.
    if available p-doc-line
    then do:
      if  work-mode <> {&lookup}
      and work-mode <> "lookup-scale"
      and work-mode <> "lookup-parts"
      then do:
        /*------------------------------------------------------------------*/
        /*             Запоминаем старые значения в учетных ценах           */
        /*------------------------------------------------------------------*/
        { str/acc-cost.i
          p-doc-line.obj-type
          p-doc-line.obj-code
          p-doc-line.doc-code
          p-doc-line.artic
          p-doc-line.prod-type
          p-doc-line.prod-code
          p-doc-line.cli-qnty
          p-doc-line.doc-qnty
          p-doc-line.fact-qnty
          p-doc-line.price-base
          p-doc-line.price-rubl
          "'old'"
          o-total-doc-line_tot-ovold
          o-total-doc-line_fact-rublold
          o-total-doc-line_fact-baseold
          o-total-doc-line_fact-qntyold
          o-total-doc-line_doc-qntyold
          o-total-doc-line_cli-qntyold
          no-error
        }
        if error-status :error
        then do:
          return error return-value.
        end.
        /*------------------------------------------------------------------*/
        /* Запомним старые значения накладной для инкремента                */
        /* по позициям не касающимся налогов и НДС не пересчитывая цены - no*/
        /*------------------------------------------------------------------*/
        { str/accgdspr.i
          recid(p-doc-line)
          no
          varagsum-base-docold
          varagsum-rubl-docold
          varagsum-base-factold
          varagsum-rubl-factold
          varagcountold
          no-error
        }
        if error-status :error
        then do:
          undo, return error return-value.
        end.
        /*------------------------------------------------------------------*/
        /* Запоминаем старые значения скидок и НДС-ов                       */
        /*------------------------------------------------------------------*/
        if flag-incr-disc-vat
        then do:
          { str/acsupacc.i
            recid(p-doc-line)
            varroad-tax-fact-baseold
            varexcise-fact-baseold
            varslt-fact-baseold
            varvat-fact-baseold
            varslt-doc-baseold
            varvat-doc-baseold
            varsum-fact-out-dsv-baseold
            varroad-tax-fact-rublold
            varexcise-fact-rublold
            varslt-fact-rublold
            varvat-fact-rublold
            varslt-doc-rublold
            varvat-doc-rublold
            varsum-fact-out-dsv-rublold
            varsum-fact-out-dsc-baseold
            varsum-fact-out-dsc-rublold
            varsum-fact-curold
            varov-fact-baseold
            varov-vat-fact-baseold
            varsum-doc-curold
            varov-doc-baseold
            varov-vat-doc-baseold
            varsum-doc-baseold
            varsum-doc-rublold
            varroad-tax-factold
            varexcise-factold
            varroad-tax-docold
            varexcise-docold
            vardiscnt-base-docold
            vardiscnt-rubl-docold
            vardiscnt-base-factold
            vardiscnt-rubl-factold
            no-error
          }
          if error-status :error
          then do:
            return error return-value.
          end.
        end.

        /*Перечитаем признак после for each ub.gds-dtl*/
        if parprt-rec <> ?
        then do:
          find ub.gds-dtl exclusive-lock
            where recid(ub.gds-dtl) = parprt-rec
            .
        end.
      end.
      /*
        Это уже не добавление, а редактирование, но режим не переставляем, т.к.
        зашли не по признаку.
        */
      assign
        flag-update = yes
      .
      assign
        parline-rec = recid(p-doc-line)
      .
    end.
    else do:
      if work-mode <> "b-c"
      then do:
        { gbl/hostcode.i
          t-doc.obj-type
          t-doc.obj-code
          v-host-code
        }
        if /*not t-doc.internal              and
              t-doc.doc-type  = {&return} and*/
              t-doc.fact-date <> ?
        then do:
          assign
            v-tax-date = t-doc.fact-date
          .
        end.
        else do:
          assign
            v-tax-date = ?
          .
        end.
        { gbl/pftxvalg.i
          p-goods.gds-code
          {&vat-tax-code}
          v-tax-date
          v-host-code
          t-doc.obj-type
          t-doc.obj-code
          v-vat-pc
          no-error
        }
        find first sysconf where sysconf.host-code = t-doc.host-code.
        { str/st-sltpc.i
          recid(p-goods)
          recid(t-doc)
          sysconf.cash-pay
          v-slt-pc
        }

        if sysconf.cons-vat-pc = ?
        then do:
          message "У Вас не установлен НДС для консигнационного товара по фирме."
          view-as alert-box error.
          return error.
        end.
        { str/crdoclin.i
          t-doc.doc-code
          p-goods.artic
          p-goods.prod-type
          p-goods.prod-code
          t-doc.obj-type
          t-doc.obj-code
          t-doc.status_
          t-doc.ext-doc-type
          p-goods.prt-root
          v-vat-pc
          v-slt-pc
          sysconf.cons-vat-pc
          no-error
        }
        if error-status :error
        then do:
          message "Ошибка при создании линии товара " p-goods.artic " "  p-goods.prod-type " " p-goods.prod-code skip
                  return-value skip
                  error-status:get-message(1)
          view-as alert-box error.
          return error.
        end.

        find first p-doc-line exclusive-lock
          where p-doc-line.doc-code  = t-doc.doc-code
            and p-doc-line.artic     = p-goods.artic
            and p-doc-line.prod-type = p-goods.prod-type
            and p-doc-line.prod-code = p-goods.prod-code
          .
        assign
          p-doc-line.doc-qnty       = 0               /* init ? */
          p-doc-line.unit-cli       = p-goods.unit-cli
          p-doc-line.cli-base-rate  = p-goods.cli-base-rate
          parline-rec                = recid(p-doc-line)
        .
        if v-is-return
        and t-doc.reason-code = 25
        and varpart-rec > 0
        then do :
          find first in_parts no-lock where recid(in_parts) = varpart-rec no-error .
          if available in_parts
          then do :
            assign
              p-doc-line.VAT-pc = in_parts.VAT-pc
              p-doc-line.SLT-pc = in_parts.SLT-pc
            .
          end .
        end .
        
        { str/is-petrl.i
          p-doc-line.artic
          p-doc-line.prod-type
          p-doc-line.prod-code
          is-petrol
          is-pieces
        }

      end.
      assign
        flag-update = no
      .

    end.

    case work-mode
    :
      when {&add-def}       or
      when "ЦИКЛ":u         or
      when {&update}        or
      when {&lookup}        or
      when "update-scale":u or
      when "lookup-scale":u or
      when "update-parts":u or
      when "lookup-parts":u
      then do:
        if      t-doc.ext-doc-type eq {&TDEDT_Ras_Vnesh_VP}
            and parvalue begins 'scan-marks'
        then do: 
           Find first marking where marking.mark begins entry(2,parvalue,{&delim-key})
           no-lock no-error.
        end.
           
        if (
            /* возврат поставщику,
               конкретная работа по партиям,
               товар с двумя единицами измерени
             */
                t-doc.ext-doc-type eq {&TDEDT_Ras_Vnesh_VP}
            and not avail Marking
            and t-doc.status_ <> {&inquiry}
            and work-mode <> "update-scale":u
            and work-mode <> "lookup-scale":u
           )
        or work-mode    =  "lookup-parts":u
        or work-mode    =  "update-parts":u
        or vartwo-value =  yes
        then do:
          if  ub.gds-prt.node-name <> {&empty-scale}
          and v-cntxp-doc-prt
          and work-mode <> "lookup-parts":u
          and work-mode <> "update-parts":u
          then do:
            define variable v-prt-doc-mode as character no-undo .
            define variable v-update-doc   as logical   no-undo .
            define variable v-node-code    as integer   no-undo .
            define buffer buf_reposition_gds-dtl for ub.gds-dtl .

            if work-mode <> {&lookup}
            then do:
              assign
                v-prt-doc-mode = {&prt-def}
              .
            end.
            else do:
              assign
                v-prt-doc-mode = {&lookup}
              .
            end.

            /* возврат товара через признаки */
            if  t-doc.flag_   <> true
            and t-doc.status_ <> {&permitted}
            and t-doc.status_ <> {&fact}
            then do:
              assign
                v-update-doc = true
              .
            end.
            else do:
              assign
                v-update-doc = false
              .
            end.

            find first buf_reposition_gds-dtl no-lock
              where recid(buf_reposition_gds-dtl) = parprt-rec
              no-error .
            if available buf_reposition_gds-dtl
            then do:
              assign
                v-node-code = buf_reposition_gds-dtl.prt-code
              .
            end.
            else do:
              assign
                v-node-code = ?
              .
            end.

            run str/prt-doc.w
              (input  ParParentProc     /* ParParentProc */
              ,input  t-doc.doc-code    /* p-doc-code    */
              ,input  p-goods.gds-code  /* p-gds-code    */
              ,input  v-node-code       /* p-node-code   */
              ,input  v-prt-doc-mode    /* p-mode        */
              ,input  v-update-doc      /* p-update-doc  */
              ) .
          end.
          else do:
            run str/parts-l.w
              (input ParParentProc
              ,input t-doc.obj-type            /* v-obj-type   */
              ,input t-doc.obj-code            /* v-obj-code   */
              ,input p-goods.gds-code          /* p-gds-code   */
              ,input t-doc.doc-code            /* p-doc-code   */
              ,input (if v-is-return then "vsd" else if work-mode = {&lookup} or  work-mode = "lookup-parts" then {&lookup} else {&update}) /* p-edit-mode  */
              ,input {&parts-l_parts-document} /* p-r-parts    */
              ,input {&parts-l_object-current} /* p-one-all    */
              ,input {&parts-l_call-document}  /* p-call-point */
              ,output varpart-rec              /* part-recid   */
              ) no-error .
          end.
          if work-mode = "lookup-parts":u
          or v-is-return
          then do:
            assign
              work-mode = {&lookup}
            .
          end.
          if work-mode = "update-parts":u
          then do:
            assign
              work-mode = {&update}
            .
          end.
          if work-mode = "ЦИКЛ":u
          then do:
            assign
              work-mode = {&add-def}
            .
          end.
          if work-mode <> {&lookup} then do:
            assign
              line-mode = {&update}.
          end.
          else do:
            assign
              line-mode = {&update}.
          end.

          /*
            В случае возврата поставщику проставляем НДС из партий и не разрешаем
            ничего делать, если в партиях разные значения НДС
           */
          if  ( t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
                and t-doc.status_ <> {&inquiry}
              )
          and work-mode <> "update-scale":u
          and work-mode <> "lookup-scale":u
          and work-mode <> {&lookup}
          then do:
            find first parts no-lock
              where parts.obj-type  = t-doc.obj-type
                and parts.obj-code  = t-doc.obj-code
                and parts.artic     = p-doc-line.artic
                and parts.prod-type = p-doc-line.prod-type
                and parts.prod-code = p-doc-line.prod-code
                and parts.out-code  = t-doc.doc-code
              no-error .
            if available parts then do:
              find first bf-parts no-lock
                where bf-parts.obj-type  = parts.obj-type
                  and bf-parts.obj-code  = parts.obj-code
                  and bf-parts.out-code  = parts.out-code
                  and bf-parts.artic     = p-doc-line.artic
                  and bf-parts.prod-type = p-doc-line.prod-type
                  and bf-parts.prod-code = p-doc-line.prod-code
                  and bf-parts.vat-pc    <> parts.vat-pc
                no-error .
              if available bf-parts
              then do:
                message "При возврате нельзя выбирать партии с разными НДС, следует сделать разные документы возврата."
                  view-as alert-box error buttons ok.
                undo, return error.
              end.
              find first bf-parts no-lock
                where bf-parts.obj-type  = parts.obj-type
                  and bf-parts.obj-code  = parts.obj-code
                  and bf-parts.out-code  = parts.out-code
                  and bf-parts.artic     = p-doc-line.artic
                  and bf-parts.prod-type = p-doc-line.prod-type
                  and bf-parts.prod-code = p-doc-line.prod-code
                  and bf-parts.slt-pc    <> parts.slt-pc
                no-error.
              if available bf-parts then do:
                message "При возврате нельзя выбирать партии, которые мы приняли с разными налогами с продаж, следует сделать разные документы возврата."
                  view-as alert-box error buttons ok.
                undo, return error.
              end.
              assign
                p-doc-line.vat-pc = parts.vat-pc
                p-doc-line.slt-pc = parts.slt-pc
              .
            end. /* if available parts */
          end. /* возврат поставщику */
        end. /* возврат поставщику, работа по партиям */
        else do:
          if ub.gds-prt.node-name <> {&empty-scale} and v-cntxp-doc-prt
          then do:
            if  work-mode <> {&lookup}
            and work-mode <> "lookup-scale":u
            then do:
              assign
                v-prt-doc-mode = {&prt-def}
              .
            end.
            else do:
              assign
                v-prt-doc-mode = {&lookup}
              .
            end.

            /* движение товара мб только по признакам */
            if work-mode = {&add-def}
            or work-mode = "ЦИКЛ":u
            or work-mode = "update-scale":u
            or work-mode = "lookup-scale":u
            then do:
              if  t-doc.flag_   <> true
              and t-doc.status_ <> {&permitted}
              and t-doc.status_ <> {&fact}
              then do:
                assign
                  v-update-doc = true
                .
              end.
              else do:
                assign
                  v-update-doc = false
                .
              end.

              find first buf_reposition_gds-dtl no-lock
                where recid(buf_reposition_gds-dtl) = parprt-rec
                no-error .
              if available buf_reposition_gds-dtl
              then do:
                assign
                  v-node-code = buf_reposition_gds-dtl.prt-code
                .
              end.
              else do:
                assign
                  v-node-code = ?
                .
              end.

              run str/prt-doc.w
                (input  ParParentProc /* ParParentProc */
                ,input  t-doc.doc-code    /* p-doc-code    */
                ,input  p-goods.gds-code    /* p-gds-code    */
                ,input  v-node-code       /* p-node-code   */
                ,input  v-prt-doc-mode    /* p-mode        */
                ,input  v-update-doc      /* p-update-doc  */
                ) .
            end.
            else do:
              if work-mode = {&update}
              or work-mode = {&lookup}
              then do:
                if parvalue begins 'scan-marks' then v-node-type = parvalue. else v-node-type = {&g#term}. 
                run str/out-prt.w (
                  ParParentProc ,
                  pardoc-rec    ,
                  parline-rec   ,
                  pargds-rec       ,
                  (if work-mode = {&update} then {&prt-def} else {&lookup}) + (if v-is-return then ({&delim-par} + "return") else "") ,
                  recid(ub.gds-prt),
                  v-node-type) no-error.
              end.
            end.
          end.
          else do:
            /* движение товара мб только без признаков */
            if parvalue begins 'scan-marks' then v-node-type = parvalue. else v-node-type = {&g#root}.
            if parvalue = "Transitional" then v-node-type = parvalue.
            find first bf_gds-obj no-lock where bf_gds-obj.obj-type  = t-doc.obj-type
                                            and bf_gds-obj.obj-code  = t-doc.obj-code
                                            and bf_gds-obj.artic     = p-goods.artic
                                            and bf_gds-obj.prod-type = p-goods.prod-type
                                            and bf_gds-obj.prod-code = p-goods.prod-code
                                            no-error .
            if error-status :error
            then do:
                  return error return-value.
            end.
            run str/out-prt.w (
              ParParentProc ,
              pardoc-rec    ,
              parline-rec   ,
              pargds-rec       ,
              (if work-mode <> {&lookup} then {&inv-def} else {&lookup}) + (if v-is-return then ({&delim-par} + "return=" + string(varpart-rec)) else "") ,
              recid(ub.gds-prt),
              v-node-type) no-error.
            if error-status :error
            then do:
                  return error return-value.
            end.
            if (return-value = "no-add-marks" and parvalue begins 'scan-marks')
            or bf_gds-obj.free-qnty < 0
            then do :
              v-stop = yes .
            end .
            if v-is-return
            and parvalue begins 'scan-marks'
            and not v-stop
            then do :
              EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(t-doc.obj-type, t-doc.obj-code).
              RUN gds-attr-value (
              INPUT p-goods.gds-code,
              INPUT {&attr-mark-type},
              OUTPUT varvalue,
              OUTPUT vartype
              ).
              if EDOParSec:GetIsEDOForType(varvalue)
              or EDOParSec:GetIsArticForType(varvalue)
              or EDOParSec:GetIsMarkingForType(varvalue)
              then do :
                EACH_PARTS:
                for each bf_parts no-lock where bf_parts.obj-type  = t-doc.obj-type
                                             and bf_parts.obj-code  = t-doc.obj-code
                                             and bf_parts.artic     = p-goods.artic
                                             and bf_parts.prod-type = p-goods.prod-type
                                             and bf_parts.prod-code = p-goods.prod-code
                                             and bf_parts.out-code  = t-doc.doc-code
                  , first bf_marking-lines no-lock where bf_marking-lines.obj-type = bf_parts.obj-type
                                                          and bf_marking-lines.obj-code = bf_parts.obj-code
                                                          and bf_marking-lines.gds-code = p-goods.gds-code
                                                          and bf_marking-lines.in-code  = bf_parts.in-code
                                                          and bf_marking-lines.out-code = bf_parts.out-code
                                                          and bf_marking-lines.part-code = bf_parts.part-code
                                                          and bf_marking-lines.mark begins entry(2,parvalue,{&delim-key})
                  :
                  leave EACH_PARTS.
                end .
                if not available bf_marking-lines
                then do :
                  create bf_marking-lines .
                  assign
                    bf_marking-lines.obj-type = t-doc.obj-type            
                    bf_marking-lines.obj-code = t-doc.obj-code  
                    bf_marking-lines.gds-code = p-goods.gds-code    
                    bf_marking-lines.in-code  = bf_parts.in-code     
                    bf_marking-lines.out-code = t-doc.doc-code   
                    bf_marking-lines.part-code = bf_parts.part-code    
                    bf_marking-lines.prt-code = bf_parts.prt-code
                    bf_marking-lines.doc-level = 1
                    bf_marking-lines.mark = entry(2,parvalue,{&delim-key})
                  .
                  validate bf_marking-lines .
                end .
              end .
            end .
            if bf_gds-obj.free-qnty <= 0
            then do :
              v-stop = yes .
            end .
          end.
        end.
        if parvalue begins 'scan-marks' or parvalue = "Transitional" then. else do:
        if parvalue <> ? then do:
           if num-entries(parvalue) = 1 then
                run str/florline.p (
                    input ParParentProc ,
                    input work-mode ,
                    input v-node-code ,
                    input t-doc.doc-code ,
                    input p-goods.gds-code ,
                    input integer(parvalue)  ) .
        end.
        end.

      end.
      when "ch-doc-qnty"
      then do:
          find first doc-line exclusive-lock where
                     recid(doc-line)  = parline-rec no-error .
         if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              error-status :get-message(1) skip
              return-value skip
              ""
              view-as alert-box error
            .
         end.
        { str/rsrv-out.i "doc" dec(parvalue)}
      end.
      when "ch-fact-qnty"
      then do:
          find first doc-line exclusive-lock where
                     recid(doc-line)  = parline-rec no-error .
         if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              error-status :get-message(1) skip
              return-value skip
              ""
              view-as alert-box error
            .
         end.

        { str/rsrv-out.i "fact" dec(parvalue)}
      end.
      when "update-sale-price"
      then do:
        if t-doc.print-rubl
        then do:
          assign
            ub.gds-dtl.price-rubl = decimal(parvalue)
            ub.gds-dtl.price-base = ub.gds-dtl.price-rubl / t-doc.base-rate * t-doc.base-scale
          .
        end.
        else do:
          assign
            ub.gds-dtl.price-base = decimal(parvalue)
            ub.gds-dtl.price-rubl = ub.gds-dtl.price-base * t-doc.base-rate / t-doc.base-scale
          .
        end.
        assign
          ub.gds-dtl.ov = yes
        .
      end.
      when "delete"
      then do:
        /* снятие резерва по признакам - поскольку input-output, инвертируем инкремент */
        assign
          unrv-qnty = - ub.gds-dtl.doc-qnty
        .
        if is-petrol = yes and
           is-pieces = no
        then do:
          define variable d_unrv-qty as decimal no-undo .

          for each bf_doc-pl exclusive-lock
            where bf_doc-pl.obj-type = ub.gds-dtl.obj-type
              and bf_doc-pl.obj-code = ub.gds-dtl.obj-code
              and bf_doc-pl.out-code = ub.gds-dtl.doc-code
              and bf_doc-pl.gds-code = p-goods.gds-code
          on error undo, return error return-value
          :
            assign
              d_unrv-qty = ( - bf_doc-pl.doc-qnty )
            .
            run trg/rsrv-dtl.p
              ( input        ParParentProc
              , input        {&rsrv-dtl_action_reserv} + ',' + {&rsrv-dtl_pl-code} + '=' + string( bf_doc-pl.pl-code )
              , buffer       ub.gds-dtl
              , input-output d_unrv-qty
              , input-output p-doc-line.price-base
              , input-output p-doc-line.price-rubl
              , input        -1
              , input       if parvalue begins 'scan-mark' then entry(2,parvalue,{&delim-key}) else ""
              ) no-error .
            if error-status :error
            then do:
              undo, return error .
            end.
            if d_unrv-qty <> - bf_doc-pl.doc-qnty then do:
              message
                "Не удается разрезервировать все количество по резервуару" bf_doc-pl.pl-code
                "для удаления строки" p-goods.artic p-goods.prod-type p-goods.prod-code "."
                view-as alert-box error .
              undo, return error .
            end. /* if d_total-qty <> p-qnty */
          end. /* for each bf_doc-pl */
        end. /* petrol */
        else do:
          run trg/rsrv-dtl.p
            ( input        ParParentProc
            , input        {&rsrv-dtl_action_reserv}
            , buffer       ub.gds-dtl
            , input-output unrv-qnty
            , input-output p-doc-line.price-base
            , input-output p-doc-line.price-rubl
            , input        -1
            , input        if parvalue begins 'scan-mark' then entry(2,parvalue,{&delim-key}) else ""
            ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              error-status :get-message(1) skip
              return-value skip
              "trg/rsrv-dtl.p"
              view-as alert-box error
            .
            undo, return error .
          end.
          if unrv-qnty <> - ub.gds-dtl.doc-qnty
          then do:
            message "Не удается разрезервировать все кол-во по признаку для удаления строки."
              view-as alert-box error buttons ok .
              undo, return error .
          end.
        end.
        /* при этом уменьшается количество в p-doc-line */
        assign
          p-doc-line.doc-qnty  = p-doc-line.doc-qnty + unrv-qnty
          p-doc-line.fact-qnty = p-doc-line.doc-qnty
        .
        /*------------------------------------------------------------------*/
        /*  Запомним старые значения и удалим, чтобы размазывать скидку без */
        /*  учета этой записи                                               */
        /*------------------------------------------------------------------*/
        for each old-gds-dtl
        on error undo, return error return-value
        :
          delete old-gds-dtl .
        end.

        create old-gds-dtl .
        buffer-copy ub.gds-dtl to old-gds-dtl .
        run lineattr-delete-flora-all (
              ub.gds-dtl.doc-code ,
              p-goods.gds-code     ,
              ub.gds-dtl.prt-code   ).

        delete ub.gds-dtl .

      end.
      when "b-c"
      then do:
        assign
          line-mode = "b-c"
        .
        find first goods where recid(goods) = recid(p-goods).
        run proc-code in this-procedure
          (input ?
          ,input entry(3,parvalue)
          ,input varscales-pref
          ,input varpgscales-pref
          ) no-error .
        if error-status :error
        then do:
          return error return-value.
        end.
        /*При создании болванки parline-rec создается внутри процедуры proc-code*/
        find p-doc-line exclusive-lock
          where p-doc-line.prod-code = p-goods.prod-code
            and p-doc-line.prod-type = p-goods.prod-type
            and p-doc-line.artic     = p-goods.artic
            and p-doc-line.doc-code  = t-doc.doc-code
          .
        assign
          parline-rec = recid(p-doc-line)
        .
        /*Если создали пустую болванку с ценами, то повторим цикл для ее редактирования*/
        if entry(5, parvalue) = "no"
        then do:
          assign
            varrep = yes
            no-end-all-operation = yes
          .
        end.
      end.
    end case.

    find p-doc-line
      where recid(p-doc-line) = parline-rec
      .
    find p-goods no-lock
      where p-doc-line.prod-code = p-goods.prod-code
        and p-doc-line.prod-type = p-goods.prod-type
        and p-doc-line.artic     = p-goods.artic
      .

    if v-round-vat-sum then do:
        if (
            /* возврат поставщику,
               конкретная работа по партиям,
               товар с двумя единицами измерени
             */
            t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
            and t-doc.status_ <> {&inquiry}
            and work-mode <> "update-scale":u
            and work-mode <> "lookup-scale":u
           )
        or work-mode    =  "lookup-parts":u
        or work-mode    =  "update-parts":u
        or vartwo-value =  yes
        then do:

        end.
        else do:
          find first ub.gds-dtl no-lock
               where ub.gds-dtl.artic     = p-doc-line.artic
                 and ub.gds-dtl.prod-type = p-doc-line.prod-type
                 and ub.gds-dtl.prod-code = p-doc-line.prod-code
                 and ub.gds-dtl.doc-code  = p-doc-line.doc-code
                no-error.
          if available ub.gds-dtl then do:
            assign v-sum-vat = round(((ub.gds-dtl.price-rubl - ub.gds-dtl.price-rubl * p-doc-line.slt-pc / (100 + p-doc-line.slt-pc) ) * p-doc-line.vat-pc / (100 + p-doc-line.vat-pc) ) * p-doc-line.cli-qnty, 2 ) .
            if v-sum-vat <> 0 and v-sum-vat <> ?
            then  
              assign p-doc-line.vat-pc = (v-sum-vat / ( p-doc-line.cli-qnty * ub.gds-dtl.price-rubl
                    * ( 1 - (p-doc-line.slt-pc / (100 + p-doc-line.slt-pc)))
                    - v-sum-vat )) * 100.
          end.
        end.
    end.


    /*------------------------------------------------------------------*/
    /*  Приводим режимы работы к стандартным, т.к. далее нет            */
    /*   функциональных  различий                                       */
    /*------------------------------------------------------------------*/
    if work-mode = "lookup-scale":u
    or work-mode = "lookup-parts":u
    then do:
      assign
        work-mode = {&lookup}
      .
    end.

    if  work-mode <> "delete":u
    and work-mode <> {&add-def}
    and work-mode <> "ЦИКЛ":u
    and work-mode <> {&lookup}
    and work-mode <> "b-c":u
    then do:
      assign
        work-mode = {&update}
      .
    end.
    /*------------------------------------------------------------------*/
    /* Это может быть не добавление а редактирование                    */
    /* Также следует привести к стандартному режим bar-code(b-c)        */
    /*------------------------------------------------------------------*/
    if (work-mode = {&add-def} or
        work-mode = "ЦИКЛ":u       )
    and flag-update = yes
    then do:
      assign
        work-mode = {&update}
      .
    end.

    /*------------------------------------------------------------------*/
    /*            Накат инкремента на шапку накладной                   */
    /*------------------------------------------------------------------*/
    if work-mode <> {&lookup}
    then do:
      /*------------------------------------------------------------------*/
      /*  Пересчитаем строку проставив цены в признаках из price-listа    */
      /*------------------------------------------------------------------*/
      { str/accgdspr.i
        recid(p-doc-line)
        yes
        varagsum-base-docnew
        varagsum-rubl-docnew
        varagsum-base-factnew
        varagsum-rubl-factnew
        varagcountnew
        no-error
      }
      if error-status :error
      then do:
        undo, return error return-value.
      end.

      /*------------------------------------------------------------------*/
      /*      Запишем в переменные новые значения в учетных ценах         */
      /*------------------------------------------------------------------*/
      { str/acc-cost.i
        p-doc-line.obj-type
        p-doc-line.obj-code
        p-doc-line.doc-code
        p-doc-line.artic
        p-doc-line.prod-type
        p-doc-line.prod-code
        p-doc-line.cli-qnty
        p-doc-line.doc-qnty
        p-doc-line.fact-qnty
        p-doc-line.price-base
        p-doc-line.price-rubl
        "'new'"
        o-total-doc-line_tot-ovnew
        o-total-doc-line_fact-rublnew
        o-total-doc-line_fact-basenew
        o-total-doc-line_fact-qntynew
        o-total-doc-line_doc-qntynew
        o-total-doc-line_cli-qntynew
        no-error
      }
      if error-status :error
      then do:
        return error return-value.
      end.
      /*------------------------------------------------------------------*/
      /*  Накатим инкремент по ценам и переустановим скидку если нужно    */
      /*------------------------------------------------------------------*/
      case work-mode:
        when {&update}
        then do:
          { str/clcdocpr.i
            recid(t-doc)
            varagsum-base-docnew
            varagsum-rubl-docnew
            varagsum-base-factnew
            varagsum-rubl-factnew
            varagcountnew
            varagsum-base-docold
            varagsum-rubl-docold
            varagsum-base-factold
            varagsum-rubl-factold
            varagcountold
            no-error
          }
        end.
        when "delete"
        then do:
          { str/clcdocpr.i
            recid(t-doc)
            varagsum-base-docnew
            varagsum-rubl-docnew
            varagsum-base-factnew
            varagsum-rubl-factnew
            varagcountnew
            varagsum-base-docold
            varagsum-rubl-docold
            varagsum-base-factold
            varagsum-rubl-factold
            varagcountold
            no-error
          }
        end.
        when {&add-def} or
        when "ЦИКЛ"
        then do:
          { str/clcdocpr.i
            recid(t-doc)
            varagsum-base-docnew
            varagsum-rubl-docnew
            varagsum-base-factnew
            varagsum-rubl-factnew
            varagcountnew
            0
            0
            0
            0
            0
            no-error
          }
        end.
        when "b-c"
        then do:
          if flag-update = yes
          then do:
            { str/clcdocpr.i
              recid(t-doc)
              varagsum-base-docnew
              varagsum-rubl-docnew
              varagsum-base-factnew
              varagsum-rubl-factnew
              varagcountnew
              varagsum-base-docold
              varagsum-rubl-docold
              varagsum-base-factold
              varagsum-rubl-factold
              varagcountold
              no-error
            }
          end.
          else do:
            { str/clcdocpr.i
              recid(t-doc)
              varagsum-base-docnew
              varagsum-rubl-docnew
              varagsum-base-factnew
              varagsum-rubl-factnew
              varagcountnew
              0
              0
              0
              0
              0
              no-error
            }
          end.
        end.
        otherwise do:
          /* Проверяю сам себя */
          message
            "Неизвестный режим:" work-mode skip
            view-as alert-box error buttons ok.
          return error.
        end.
      end case.

      { str/ass-cost.i
        recid(t-doc)
        o-total-doc-line_tot-ovnew
        o-total-doc-line_fact-rublnew
        o-total-doc-line_fact-basenew
        o-total-doc-line_fact-qntynew
        o-total-doc-line_doc-qntynew
        o-total-doc-line_cli-qntynew
        o-total-doc-line_tot-ovold
        o-total-doc-line_fact-rublold
        o-total-doc-line_fact-baseold
        o-total-doc-line_fact-qntyold
        o-total-doc-line_doc-qntyold
        o-total-doc-line_cli-qntyold
        no-error
      }
      if error-status :error
      then do:
        undo, return error .
      end.

      /*------------------------------------------------------------------*/
      /*  Если инкремент по скидкам и налогам не возможен делаем проход   */
      /*  по всем линиям накладной, иначе инкремент                       */
      /*------------------------------------------------------------------*/
      if not flag-incr-disc-vat
      then do:
        for each p-doc-line exclusive-lock
          where p-doc-line.doc-code = t-doc.doc-code
        on error undo, return error return-value
        :
          { str/reclcdsc.i
            recid(p-doc-line)
            no-error
          }
          if error-status :error
          then do:
            return error return-value .
          end.
        end.

        for each p-doc-line exclusive-lock
          where p-doc-line.doc-code = t-doc.doc-code
        on error undo, return error return-value
        :
          { str/acsupacc.i
            recid(p-doc-line)
            varroad-tax-fact-basenew
            varexcise-fact-basenew
            varslt-fact-basenew
            varvat-fact-basenew
            varslt-doc-basenew
            varvat-doc-basenew
            varsum-fact-out-dsv-basenew
            varroad-tax-fact-rublnew
            varexcise-fact-rublnew
            varslt-fact-rublnew
            varvat-fact-rublnew
            varslt-doc-rublnew
            varvat-doc-rublnew
            varsum-fact-out-dsv-rublnew
            varsum-fact-out-dsc-basenew
            varsum-fact-out-dsc-rublnew
            varsum-fact-curnew
            varov-fact-basenew
            varov-vat-fact-basenew
            varsum-doc-curnew
            varov-doc-basenew
            varov-vat-doc-basenew
            varsum-doc-basenew
            varsum-doc-rublnew
            varroad-tax-factnew
            varexcise-factnew
            varroad-tax-docnew
            varexcise-docnew
            vardiscnt-base-docnew
            vardiscnt-rubl-docnew
            vardiscnt-base-factnew
            vardiscnt-rubl-factnew
            no-error
          }
        end.

        assign
          vartotal-road-tax-fact-base    = vartotal-road-tax-fact-base    + varroad-tax-fact-basenew
          vartotal-excise-fact-base      = vartotal-excise-fact-base      + varexcise-fact-basenew
          vartotal-slt-fact-base         = vartotal-slt-fact-base         + varslt-fact-basenew
          vartotal-vat-fact-base         = vartotal-vat-fact-base         + varvat-fact-basenew
          vartotal-slt-doc-base          = vartotal-slt-doc-base          + varslt-doc-basenew
          vartotal-vat-doc-base          = vartotal-vat-doc-base          + varvat-doc-basenew
          vartotal-sum-fact-out-dsv-base = vartotal-sum-fact-out-dsv-base + varsum-fact-out-dsv-basenew
          vartotal-road-tax-fact-rubl    = vartotal-road-tax-fact-rubl    + varroad-tax-fact-rublnew
          vartotal-excise-fact-rubl      = vartotal-excise-fact-rubl      + varexcise-fact-rublnew
          vartotal-slt-fact-rubl         = vartotal-slt-fact-rubl         + varslt-fact-rublnew
          vartotal-vat-fact-rubl         = vartotal-vat-fact-rubl         + varvat-fact-rublnew
          vartotal-slt-doc-rubl          = vartotal-slt-doc-rubl          + varslt-doc-rublnew
          vartotal-vat-doc-rubl          = vartotal-vat-doc-rubl          + varvat-doc-rublnew
          vartotal-sum-fact-out-dsv-rubl = vartotal-sum-fact-out-dsv-rubl + varsum-fact-out-dsv-rublnew
          vartotal-sum-fact-out-dsc-base = vartotal-sum-fact-out-dsc-base + varsum-fact-out-dsc-basenew
          vartotal-sum-fact-out-dsc-rubl = vartotal-sum-fact-out-dsc-rubl + varsum-fact-out-dsc-rublnew
          vartotal-sum-fact-cur          = vartotal-sum-fact-cur          + varsum-fact-curnew
          vartotal-ov-fact-base          = vartotal-ov-fact-base          + varov-fact-basenew
          vartotal-ov-vat-fact-base      = vartotal-ov-vat-fact-base      + varov-vat-fact-basenew
          vartotal-sum-doc-cur           = vartotal-sum-doc-cur           + varsum-doc-curnew
          vartotal-ov-doc-base           = vartotal-ov-doc-base           + varov-doc-basenew
          vartotal-ov-vat-doc-base       = vartotal-ov-vat-doc-base       + varov-vat-doc-basenew
          vartotal-sum-doc-base          = vartotal-sum-doc-base          + varsum-doc-basenew
          vartotal-sum-doc-rubl          = vartotal-sum-doc-rubl          + varsum-doc-rublnew
          vartotal-road-tax-fact         = vartotal-road-tax-fact         + varroad-tax-factnew
          vartotal-excise-fact           = vartotal-excise-fact           + varexcise-factnew
          vartotal-road-tax-doc          = vartotal-road-tax-doc          + varroad-tax-docnew
          vartotal-excise-doc            = vartotal-excise-doc            + varexcise-docnew
          vartotal-discnt-base-doc       = vartotal-discnt-base-doc       + vardiscnt-base-docnew
          vartotal-discnt-rubl-doc       = vartotal-discnt-rubl-doc       + vardiscnt-rubl-docnew
          vartotal-discnt-base-fact      = vartotal-discnt-base-fact      + vardiscnt-base-factnew
          vartotal-discnt-rubl-fact      = vartotal-discnt-rubl-fact      + vardiscnt-rubl-factnew
        .

        /*Окончательный пересчет шапки накладной после пересчета скидок, налога и НДС*/
        { str/clcpttrn.i
          recid(t-doc)
          vartotal-discnt-base-fact
          vartotal-discnt-rubl-fact
          vartotal-road-tax-fact
          vartotal-excise-fact
          vartotal-slt-fact-base
          vartotal-vat-fact-base
          vartotal-slt-fact-rubl
          vartotal-vat-fact-rubl
          0
          0
          0
          0
          0
          0
          0
          0
          no-error
        }
        if error-status :error
        then do:
          return error return-value.
        end.
      end.
      else do:
        { str/reclcdsc.i
          recid(p-doc-line)
          no-error
        }
        if error-status :error
        then do:
          return error return-value.
        end.
        { str/acsupacc.i
          recid(p-doc-line)
          varroad-tax-fact-basenew
          varexcise-fact-basenew
          varslt-fact-basenew
          varvat-fact-basenew
          varslt-doc-basenew
          varvat-doc-basenew
          varsum-fact-out-dsv-basenew
          varroad-tax-fact-rublnew
          varexcise-fact-rublnew
          varslt-fact-rublnew
          varvat-fact-rublnew
          varslt-doc-rublnew
          varvat-doc-rublnew
          varsum-fact-out-dsv-rublnew
          varsum-fact-out-dsc-basenew
          varsum-fact-out-dsc-rublnew
          varsum-fact-curnew
          varov-fact-basenew
          varov-vat-fact-basenew
          varsum-doc-curnew
          varov-doc-basenew
          varov-vat-doc-basenew
          varsum-doc-basenew
          varsum-doc-rublnew
          varroad-tax-factnew
          varexcise-factnew
          varroad-tax-docnew
          varexcise-docnew
          vardiscnt-base-docnew
          vardiscnt-rubl-docnew
          vardiscnt-base-factnew
          vardiscnt-rubl-factnew
          no-error
        }
        case work-mode:
          when {&update}
          then do:
            { str/clcpttrn.i
              recid(t-doc)
              vardiscnt-base-factnew
              vardiscnt-rubl-factnew
              varroad-tax-factnew
              varexcise-factnew
              varslt-fact-basenew
              varvat-fact-basenew
              varslt-fact-rublnew
              varvat-fact-rublnew
              vardiscnt-base-factold
              vardiscnt-rubl-factold
              varroad-tax-factold
              varexcise-factold
              varslt-fact-baseold
              varvat-fact-baseold
              varslt-fact-rublold
              varvat-fact-rublold
              no-error
            }
            if error-status :error
            then do:
              return error return-value.
            end.
          end.
          when "delete"
          then do:
            { str/clcpttrn.i
              recid(t-doc)
              vardiscnt-base-factnew
              vardiscnt-rubl-factnew
              varroad-tax-factnew
              varexcise-factnew
              varslt-fact-basenew
              varvat-fact-basenew
              varslt-fact-rublnew
              varvat-fact-rublnew
              vardiscnt-base-factold
              vardiscnt-rubl-factold
              varroad-tax-factold
              varexcise-factold
              varslt-fact-baseold
              varvat-fact-baseold
              varslt-fact-rublold
              varvat-fact-rublold
              no-error
            }
            if error-status :error
            then do:
              return error return-value.
            end.
          end.
          when {&add-def} or
          when "ЦИКЛ"
          then do:
            { str/clcpttrn.i
              recid(t-doc)
              vardiscnt-base-factnew
              vardiscnt-rubl-factnew
              varroad-tax-factnew
              varexcise-factnew
              varslt-fact-basenew
              varvat-fact-basenew
              varslt-fact-rublnew
              varvat-fact-rublnew
              0
              0
              0
              0
              0
              0
              0
              0
              no-error
            }
            if error-status :error
            then do:
              return error return-value.
            end.
          end.
          when "b-c"
          then do:
            if flag-update = yes
            then do:
              { str/clcpttrn.i
                recid(t-doc)
                vardiscnt-base-factnew
                vardiscnt-rubl-factnew
                varroad-tax-factnew
                varexcise-factnew
                varslt-fact-basenew
                varvat-fact-basenew
                varslt-fact-rublnew
                varvat-fact-rublnew
                vardiscnt-base-factold
                vardiscnt-rubl-factold
                varroad-tax-factold
                varexcise-factold
                varslt-fact-baseold
                varvat-fact-baseold
                varslt-fact-rublold
                varvat-fact-rublold
                no-error
              }
              if error-status :error
              then do:
                return error return-value.
              end.
            end.
            else do:
              { str/clcpttrn.i
                recid(t-doc)
                vardiscnt-base-factnew
                vardiscnt-rubl-factnew
                varroad-tax-factnew
                varexcise-factnew
                varslt-fact-basenew
                varvat-fact-basenew
                varslt-fact-rublnew
                varvat-fact-rublnew
                0
                0
                0
                0
                0
                0
                0
                0
                no-error
              }
              if error-status :error
              then do:
                return error return-value.
              end.
            end.
          end.
          otherwise do:
            message
              "Неизвестный режим:" work-mode skip
              view-as alert-box error buttons ok.
            return error.
          end.
        end case.
      end.
    end.
  end. /*while no-end-all-operation*/

  if  work-mode <> {&lookup}
  and available p-doc-line
  and p-doc-line.doc-qnty = 0
  and p-doc-line.fact-qnty = 0
  then do:
    delete p-doc-line.
  end.
  
  if v-stop
  then do :
    return "stop-add-marks" .
  end .
end.