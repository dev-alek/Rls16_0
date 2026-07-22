block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: uaddsum.p $
$Archive: utl/uaddsum.p $

Утилита по расчету дополнительных сумм по документу

Автор: Чернова Светлана Александровна
Дата создания: 09/17/08
Author: Svetlana Chernova
Creation date: 09/17/08

Автор1: Суслов Алексей Юрьевич
Дата создания: 04/03/02
*/

/* ********************************************************************************************************************* *\
 *                                                                                                                       *
 * Расчитываются суммы:                                                                                                  *
 *   {&sum-before-doc}                                                                                                   *
 *   {&sum-before-cli-doc}                                                                                               *
 *   {&sum-wastage-doc}                                                                                                  *
 *   {&sum-wastage-cli-doc}                                                                                              *
 *   {&sum-general-doc}                                                                                                  *
 *   {&sum-general-cli-doc}                                                                                              *
 *   {&sum-extra-doc}                                                                                                    *
 *   {&sum-extra-cli-doc}                                                                                                *
 *   {&sum-miss-doc}                                                                                                     *
 *   {&sum-miss-cli-doc}                                                                                                 *
 *   {&sum-after-doc}                                                                                                    *
 *   {&sum-after-cli-doc}                                                                                                *
 *                                                                                                                       *
\* ********************************************************************************************************************* */

define input parameter pardoc-code               like ub.trn-doc.doc-code no-undo.
define input parameter parcalc-sum-without-param as   logical             no-undo.
define input parameter parcalc-wastage           as   logical             no-undo.
define input parameter parcalc-cli               as   logical             no-undo.

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: uaddsum.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/uaddsum.p $":U .
define variable vss-description as character no-undo initial "Утилита по расчету дополнительных сумм по документу":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/waitfram.i noprocess }
{ cmp/operlist.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ str/trdcalib.i }
{ trg/partslib.i }
{ str/clcprtsl.i }
{ str/lib-rwds.i }
{ trg/factord.i  }
{ gbl/getsect.i def }

define buffer bf_trn-doc              for ub.trn-doc.
define buffer bf_goods                for ub.goods.
define buffer bf_doc-line             for ub.doc-line.
define buffer bf_gds-obj              for ub.gds-obj.
define buffer bf_prt-obj              for ub.prt-obj.
define buffer bf_bar-code             for ub.bar-code.
define buffer bf-del_doc-line-sum     for ub.doc-line-sum.
define buffer bf-del-exc_doc-line-sum for ub.doc-line-sum.
define buffer bf-bef_trn-doc-sum      for ub.trn-doc-sum.
define buffer bf-gen_trn-doc-sum      for ub.trn-doc-sum.
define buffer bf-aft_trn-doc-sum      for ub.trn-doc-sum.
define buffer bf-wst_trn-doc-sum      for ub.trn-doc-sum.
define buffer bf-bef_doc-line-sum     for ub.doc-line-sum.
define buffer bf-gen_doc-line-sum     for ub.doc-line-sum.
define buffer bf-aft_doc-line-sum     for ub.doc-line-sum.
define buffer bf-wst_doc-line-sum     for ub.doc-line-sum.
define buffer bf-bef-cli_trn-doc-sum  for ub.trn-doc-sum.
define buffer bf-gen-cli_trn-doc-sum  for ub.trn-doc-sum.
define buffer bf-aft-cli_trn-doc-sum  for ub.trn-doc-sum.
define buffer bf-wst-cli_trn-doc-sum  for ub.trn-doc-sum.
define buffer bf-bef-cli_doc-line-sum for ub.doc-line-sum.
define buffer bf-gen-cli_doc-line-sum for ub.doc-line-sum.
define buffer bf-aft-cli_doc-line-sum for ub.doc-line-sum.
define buffer bf-wst-cli_doc-line-sum for ub.doc-line-sum.
define buffer bf_tt-allsum-line       for tt-allsum-line.

define variable varexist                 as   logical                no-undo.
define variable varvalue                 like ub.doc-attr.attr-value no-undo.
define variable vartype                  as   character              no-undo.
define variable varcurr-r-b              as   character              no-undo.
define variable varbase-rate             like ub.trn-doc.base-rate   no-undo.
define variable varbase-scale            like ub.trn-doc.base-scale  no-undo.
define variable varvat-pc                like ub.doc-line.vat-pc     no-undo.
define variable varcons-vat-pc           as   decimal                no-undo.
define variable varslt-pc                like ub.doc-line.slt-pc     no-undo.
define variable varcur-price-sale        as   decimal                no-undo.
define variable varcur-price-road-tax    as   decimal                no-undo.
define variable varcur-price-excise      as   decimal                no-undo.
define variable varcurprt-price-sale     as   decimal                no-undo.
define variable varcurprt-price-road-tax as   decimal                no-undo.
define variable varcurprt-price-excise   as   decimal                no-undo.
define variable varcur-base              as   decimal                no-undo.
define variable varcur-road-tax-base     as   decimal                no-undo.
define variable varcur-excise-base       as   decimal                no-undo.
define variable varfact-qnty             as   decimal                no-undo.
define variable varb-code                like ub.bar-code.b-code     no-undo.
define variable vardoc-num               like ub.price-doc.doc-num   no-undo.
define variable varis-new                as   logical                no-undo.
define variable wastagevalue             as   character              no-undo.
define variable wastagetype              as   character              no-undo.
define variable varinvclcspvalue         as   character              no-undo.
define variable varinvclcsptype          as   character              no-undo.
define variable varcount                 as   integer                no-undo.
define variable vartime                  as   integer                no-undo.

do transaction on error undo, return error substitute( "&1 &2", return-value, error-status :get-message( 1 ) ) :
  assign
    vartime = time.
  find first bf_trn-doc no-lock where bf_trn-doc.doc-code = pardoc-code no-error.
  if not available bf_trn-doc then do:
    return error substitute( 'Не найден документ с номером "&1".', pardoc-code ).
  end.
  if bf_trn-doc.doc-type <> {&inventory} then do:
    return error substitute( 'Документ "&1" не является инвентаризацией.', bf_trn-doc.doc-code ).
  end.
  if bf_trn-doc.status_ <> {&fact}      and
     bf_trn-doc.status_ <> {&permitted} then do:
    return error substitute( 'Документ "&1" имеет статус "&2". Утилита работает для документов в статусе "&3" и "&4".'
                           , bf_trn-doc.doc-code
                           , bf_trn-doc.status_
                           , {&fact}
                           , {&permitted} ).
  end.
  { str/tdat-val.i bf_trn-doc.doc-code
               {&trdcattr-addsum}
               varvalue
               vartype             no-error }
  if error-status :error then do:
    return error substitute( "Ошибка при вызове процедуры tdat-val &1 &2."
                           , return-value
                           , error-status :get-message( 1 ) ).
  end.
  if parcalc-sum-without-param <> yes then do:
      { gbl/getsect.i run bf_trn-doc.obj-type bf_trn-doc.obj-code {&attr-inv-obj} }
      for each thbjattr_thbj-attr :
          if thbjattr_thbj-attr.prop-code = 'invclcsp' then varinvclcspvalue = string( thbjattr_thbj-attr.property-value-logical, "yes/no").
          if thbjattr_thbj-attr.prop-code = 'wastage'  then wastagevalue = string( thbjattr_thbj-attr.property-value-logical, "yes/no").
      end.
  end.
  else do:
    if parcalc-wastage = yes then do:
      assign
        wastagevalue = "yes":U.
    end.
    if parcalc-cli = yes then do:
      assign
        varinvclcspvalue = "yes":U.
    end.
  end.
  assign
    varcount = 0.
  for each bf-del_doc-line-sum no-lock where
           bf-del_doc-line-sum.doc-code = bf_trn-doc.doc-code
  on error undo, return error return-value :
    assign
      varcount = varcount + 1.
    run waitfram-show in this-procedure ( input waitfram-join-function ( substitute( "Удаление лишних строк сумм." ),
                                                                         substitute( "Обработано строк: &1", varcount ),
                                                                         substitute( "Время &1."
                                                                                   , string( time - vartime, "hh:mm:ss":U )
                                                                                   )
                                                                       )
                                        ) no-error.

    find first bf_goods    no-lock where
               bf_goods.gds-code = bf-del_doc-line-sum.gds-code.
    find first bf_doc-line no-lock where
               bf_doc-line.doc-code  = bf-del_doc-line-sum.doc-code and
               bf_doc-line.artic     = bf_goods.artic               and
               bf_doc-line.prod-type = bf_goods.prod-type           and
               bf_doc-line.prod-code = bf_goods.prod-code           no-error.
    if not available bf_doc-line then do:
      find first bf-del-exc_doc-line-sum exclusive-lock where
          recid( bf-del-exc_doc-line-sum ) = recid( bf-del_doc-line-sum ).
      delete bf-del-exc_doc-line-sum.
    end.
  end.
  run local-create-sum in this-procedure ( input {&sum-before-doc}  ) no-error.
  if error-status :error then do:
    return error return-value.
  end.
  run local-create-sum in this-procedure ( input {&sum-general-doc} ) no-error.
  if error-status :error then do:
    return error return-value.
  end.
  run local-create-sum in this-procedure ( input {&sum-extra-doc}   ) no-error.
  if error-status :error then do:
    return error return-value.
  end.
  run local-create-sum in this-procedure ( input {&sum-miss-doc}    ) no-error.
  if error-status :error then do:
    return error return-value.
  end.
  run local-create-sum in this-procedure ( input {&sum-after-doc}   ) no-error.
  if error-status :error then do:
    return error return-value.
  end.
  if wastagevalue = "yes" then do:
    run local-create-sum in this-procedure ( input {&sum-wastage-doc} ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
  end.
  if varinvclcspvalue = "yes" then do:
    run local-create-sum in this-procedure ( input {&sum-before-cli-doc}  ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
    run local-create-sum in this-procedure ( input {&sum-general-cli-doc} ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
    run local-create-sum in this-procedure ( input {&sum-extra-cli-doc}   ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
    run local-create-sum in this-procedure ( input {&sum-miss-cli-doc}    ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
    run local-create-sum in this-procedure ( input {&sum-after-cli-doc}   ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
    if wastagevalue = "yes" then do:
      run local-create-sum in this-procedure ( input {&sum-wastage-cli-doc} ) no-error.
      if error-status :error then do:
        return error return-value.
      end.
    end.
  end. /* if varinvclcspvalue = "yes" */
  /* Заполняем строки по естественной убыли */
  if wastagevalue = "yes" then do:
    { str/ccwstsum.i bf_trn-doc.doc-code
                 "this-procedure :handle"
                 tt-wast-line             no-error }
    if error-status :error then do:
      return error substitute( "Ошибка при пересчете естественной убыли: &1 &2."
                             , return-value
                             , error-status :get-message( 1 ) ).
    end.
    { str/reclctsl.i
      bf_trn-doc.doc-code
      {&sum-wastage-doc}
      no-error
    }
    if error-status :error then do:
      return error substitute( "Ошибка при вызове str/reclctsl.i: &1 &2."
                             , return-value
                             , error-status :get-message( 1 ) ).
    end.
    if varinvclcspvalue = "yes" then do:
      { str/reclctsl.i
        bf_trn-doc.doc-code
        {&sum-wastage-cli-doc}
        no-error
      }
      if error-status :error then do:
        return error substitute( "Ошибка при вызове str/reclctsl.i: &1 &2."
                               , return-value
                               , error-status :get-message( 1 ) ).
      end.
    end.
  end.
  assign
    varcount = 0.
  /* Заполняем строки по суммам "перед инвентаризацией" */
  for each bf_doc-line where
           bf_doc-line.doc-code = bf_trn-doc.doc-code
  on error undo, return error return-value :
    assign
      varcount = varcount + 1.
    run waitfram-show in this-procedure (
      input waitfram-join-function ( substitute( "Расчет товарных сумм перед инвентаризацией." ),
                                     substitute( "Обработано строк: &1", varcount ),
                                     substitute( "Время &1.", string( time - vartime, "hh:mm:ss":U ) )
                                   )    ) no-error.

    find first bf_goods no-lock where
               bf_goods.artic     = bf_doc-line.artic     and
               bf_goods.prod-type = bf_doc-line.prod-type and
               bf_goods.prod-code = bf_doc-line.prod-code no-error.
    if not available bf_goods then do:
      return error substitute( "Не найден товар &1 &2 &3."
                             , bf_doc-line.artic
                             , bf_doc-line.prod-type
                             , bf_doc-line.prod-code ).
    end.
    find first bf-bef_doc-line-sum where
               bf-bef_doc-line-sum.doc-code = bf_doc-line.doc-code and
               bf-bef_doc-line-sum.gds-code = bf_goods.gds-code    and
               bf-bef_doc-line-sum.sum-type = {&sum-before-doc}    .
    if varinvclcspvalue = "yes" then do:
      find first bf-bef-cli_doc-line-sum where
                 bf-bef-cli_doc-line-sum.doc-code = bf_doc-line.doc-code  and
                 bf-bef-cli_doc-line-sum.gds-code = bf_goods.gds-code     and
                 bf-bef-cli_doc-line-sum.sum-type = {&sum-before-cli-doc} .
    end.
    find first bf_gds-obj no-lock where
               bf_gds-obj.obj-type  = bf_doc-line.obj-type  and
               bf_gds-obj.obj-code  = bf_doc-line.obj-code  and
               bf_gds-obj.artic     = bf_doc-line.artic     and
               bf_gds-obj.prod-type = bf_doc-line.prod-type and
               bf_gds-obj.prod-code = bf_doc-line.prod-code .
    if available bf_gds-obj then do:
      /* Считываем свободную зону по товару момент инвентаризации */
      run partslib-clear-temp-parts in this-procedure no-error.
      if error-status :error then do:
        return error substitute( "Ошибка при запуске процедуры partslib-clear-temp-parts &1 &2."
                               , return-value
                               , error-status :get-message( 1 ) ).
      end.
      run partslib-init-temp-parts-by-factord in this-procedure
        ( input bf_gds-obj.obj-type,
          input bf_gds-obj.obj-code,
          input bf_gds-obj.artic,
          input bf_gds-obj.prod-type,
          input bf_gds-obj.prod-code,
          input bf_trn-doc.fact-order,
          input yes ) no-error.
      if error-status :error then do:
        return error substitute( "Ошибка при запуске процедуры partslib-init-temp-parts &1 &2 объект &3 &4 товар &5 &6 &7."
                               , return-value
                               , error-status :get-message( 1 )
                               , bf_gds-obj.obj-type
                               , bf_gds-obj.obj-code
                               , bf_gds-obj.artic
                               , bf_gds-obj.prod-type
                               , bf_gds-obj.prod-code ).
      end.
      for each tt-clcparts :
        delete tt-clcparts .
      end.
      for each temp-parts :
        create tt-clcparts.
        buffer-copy temp-parts to tt-clcparts.
      end.
      find first tt-clcparts no-error.
      if available tt-clcparts then do:
        { gbl/curr-r-b.i varcurr-r-b }
        { gbl/baserate.i
          bf_trn-doc.host-code
          bf_trn-doc.fact-date
          varbase-rate
          varbase-scale
          no-error
        }
        { gbl/pftxvalg.i
          bf_goods.gds-code
          {&vat-tax-code}
          bf_trn-doc.fact-date
          bf_trn-doc.host-code
          bf_gds-obj.obj-type
          bf_gds-obj.obj-code
          varvat-pc
        }
        if varvat-pc = ?
        then do:
          undo, return error substitute( "Не задан НДС товара &1 &2 &3."
                                       , bf_goods.artic
                                       , bf_goods.prod-type
                                       , bf_goods.prod-code ).
        end.
        { gbl/pftxvalg.i
          bf_goods.gds-code
          {&slt-tax-code}
          bf_trn-doc.fact-date
          bf_trn-doc.host-code
          bf_gds-obj.obj-type
          bf_gds-obj.obj-code
          varslt-pc
        }
        if varslt-pc = ?
        then do:
          undo, return error substitute( "Не задан НП товара &1 &2 &3."
                                       , bf_goods.artic
                                       , bf_goods.prod-type
                                       , bf_goods.prod-code ).
        end.
        assign
          varcons-vat-pc = bf_doc-line.cons-vat-pc.
        assign
          varfact-qnty          = 0
          varcur-base           = 0
          varcur-road-tax-base  = 0
          varcur-excise-base    = 0
        .
        for each bf_prt-obj where
                 bf_prt-obj.obj-type  = bf_gds-obj.obj-type  and
                 bf_prt-obj.obj-code  = bf_gds-obj.obj-code  and
                 bf_prt-obj.prod-type = bf_gds-obj.prod-type and
                 bf_prt-obj.prod-code = bf_gds-obj.prod-code and
                 bf_prt-obj.artic     = bf_gds-obj.artic
        on error undo, return error return-value :
          { gbl/barcodcr.i
            bf_goods.gds-code
            bf_prt-obj.prt-code
            "''"
            "''"
            bf_goods.unit-base
            1
            varis-new
            bf_bar-code
          }
          assign
            varb-code = bf_bar-code.b-code.
          { gbl/bcodeprc.i
            bf_trn-doc.obj-type
            bf_trn-doc.obj-code
            varb-code
            0
            bf_trn-doc.fact-order
            vardoc-num
            varcurprt-price-sale
            varcurprt-price-road-tax
            varcurprt-price-excise
          }
          assign
            varfact-qnty         = varfact-qnty         + bf_prt-obj.fact-qnty
            varcur-base          = varcur-base          + varcurprt-price-sale     * bf_prt-obj.fact-qnty
            varcur-road-tax-base = varcur-road-tax-base + varcurprt-price-road-tax * bf_prt-obj.fact-qnty
            varcur-excise-base   = varcur-excise-base   + varcurprt-price-excise   * bf_prt-obj.fact-qnty
          .
        end. /* for each bf_prt-obj */

        if varfact-qnty <> 0
        then do:
          assign
            varcur-price-sale     = varcur-base          / varfact-qnty
            varcur-price-road-tax = varcur-road-tax-base / varfact-qnty
            varcur-price-excise   = varcur-excise-base   / varfact-qnty
          .
        end.
        else do:
          assign
            varcur-price-sale     = varcurprt-price-sale
            varcur-price-road-tax = varcurprt-price-road-tax
            varcur-price-excise   = varcurprt-price-excise
          .
        end.
        if varcur-price-sale = ? then do:
          assign
            varcur-price-sale     = 0.
        end.
        if varcur-price-road-tax = ? then do:
          assign
            varcur-price-road-tax = 0.
        end.
        if varcur-price-excise = ? then do:
          assign
            varcur-price-excise = 0.
        end.
        for each bf_tt-allsum-line :
          delete bf_tt-allsum-line.
        end.
        run clcprtsl_calc-ttable in this-procedure
        ( input false                 /* paris-doc         */
        , input true                  /* paris-cur         */
        , input ?                     /* parroad-tax       */
        , input ?                     /* parexcise         */
        , input ?                     /* parvat-pc         */
        , input ?                     /* parcons-vat-pc    */
        , input ?                     /* parslt-pc         */
        , input varbase-rate          /* parbase-rate      */
        , input varbase-scale         /* parbase-scale     */
        , input varcurr-r-b           /* parr-b            */
        , input varcur-price-sale     /* parcur-base       */
        , input varcur-price-road-tax /* parcur-road-tax   */
        , input varcur-price-excise   /* parcur-excise     */
        , input varvat-pc             /* parcur-vat-pc     */
        , input varcons-vat-pc        /* parcurcons-vat-pc */
        , input varslt-pc             /* parcurslt-pc      */
        ) no-error .
        if error-status :error then do:
          undo, return error "Ошибка при расчете учетных цен по партии".
        end.
        find first bf_tt-allsum-line where bf_tt-allsum-line.sum-type = {&sum-general} no-error.
        if error-status :error then do:
          return error substitute( 'Не найдена запись по типу "&1" для товара &2 &3 &4.'
                                 , {&sum-general}
                                 , bf_goods.artic
                                 , bf_goods.prod-type
                                 , bf_goods.prod-code ).
        end.
        assign
          bf-bef_doc-line-sum.fact-qnty             = bf_tt-allsum-line.fact-qnty
          bf-bef_doc-line-sum.sale-sum-base         = bf_tt-allsum-line.sum-dsc-base-cur
          bf-bef_doc-line-sum.sale-sum-rubl         = bf_tt-allsum-line.sum-dsc-rubl-cur
          bf-bef_doc-line-sum.sale-VAT-base         = bf_tt-allsum-line.vat-base-cur
          bf-bef_doc-line-sum.sale-VAT-rubl         = bf_tt-allsum-line.vat-rubl-cur
          bf-bef_doc-line-sum.sale-SLT-base         = bf_tt-allsum-line.slt-base-cur
          bf-bef_doc-line-sum.sale-SLT-rubl         = bf_tt-allsum-line.slt-rubl-cur
          bf-bef_doc-line-sum.sale-road-tax-base    = bf_tt-allsum-line.road-tax-base-cur
          bf-bef_doc-line-sum.sale-road-tax-rubl    = bf_tt-allsum-line.road-tax-rubl-cur
          bf-bef_doc-line-sum.sale-excise-base      = bf_tt-allsum-line.excise-base-cur
          bf-bef_doc-line-sum.sale-excise-rubl      = bf_tt-allsum-line.excise-rubl-cur
          bf-bef_doc-line-sum.sale-transport-base   = 0
          bf-bef_doc-line-sum.sale-transport-rubl   = 0
          bf-bef_doc-line-sum.sale-other-base       = 0
          bf-bef_doc-line-sum.sale-other-rubl       = 0
          bf-bef_doc-line-sum.sale-discnt-base      = bf_tt-allsum-line.dsc-base-cur
          bf-bef_doc-line-sum.sale-discnt-rubl      = bf_tt-allsum-line.dsc-rubl-cur
          bf-bef_doc-line-sum.crsa-sum-base         = bf_tt-allsum-line.sum-dsc-base-cur
          bf-bef_doc-line-sum.crsa-sum-rubl         = bf_tt-allsum-line.sum-dsc-rubl-cur
          bf-bef_doc-line-sum.crsa-VAT-base         = bf_tt-allsum-line.vat-base-cur
          bf-bef_doc-line-sum.crsa-VAT-rubl         = bf_tt-allsum-line.vat-rubl-cur
          bf-bef_doc-line-sum.crsa-SLT-base         = bf_tt-allsum-line.slt-base-cur
          bf-bef_doc-line-sum.crsa-SLT-rubl         = bf_tt-allsum-line.slt-rubl-cur
          bf-bef_doc-line-sum.crsa-road-tax-base    = bf_tt-allsum-line.road-tax-base-cur
          bf-bef_doc-line-sum.crsa-road-tax-rubl    = bf_tt-allsum-line.road-tax-rubl-cur
          bf-bef_doc-line-sum.crsa-excise-base      = bf_tt-allsum-line.excise-base-cur
          bf-bef_doc-line-sum.crsa-excise-rubl      = bf_tt-allsum-line.excise-rubl-cur
          bf-bef_doc-line-sum.crsa-transport-base   = 0
          bf-bef_doc-line-sum.crsa-transport-rubl   = 0
          bf-bef_doc-line-sum.crsa-other-base       = 0
          bf-bef_doc-line-sum.crsa-other-rubl       = 0
          bf-bef_doc-line-sum.crsa-discnt-base      = bf_tt-allsum-line.dsc-base-cur
          bf-bef_doc-line-sum.crsa-discnt-rubl      = bf_tt-allsum-line.dsc-rubl-cur
          bf-bef_doc-line-sum.cost-sum-base         = bf_tt-allsum-line.sum-dsc-base-acc
          bf-bef_doc-line-sum.cost-sum-rubl         = bf_tt-allsum-line.sum-dsc-rubl-acc
          bf-bef_doc-line-sum.cost-VAT-base         = bf_tt-allsum-line.vat-base-acc
          bf-bef_doc-line-sum.cost-VAT-rubl         = bf_tt-allsum-line.vat-rubl-acc
          bf-bef_doc-line-sum.cost-SLT-base         = bf_tt-allsum-line.slt-base-acc
          bf-bef_doc-line-sum.cost-SLT-rubl         = bf_tt-allsum-line.slt-rubl-acc
          bf-bef_doc-line-sum.cost-road-tax-base    = bf_tt-allsum-line.road-tax-base-acc
          bf-bef_doc-line-sum.cost-road-tax-rubl    = bf_tt-allsum-line.road-tax-rubl-acc
          bf-bef_doc-line-sum.cost-excise-base      = bf_tt-allsum-line.excise-base-acc
          bf-bef_doc-line-sum.cost-excise-rubl      = bf_tt-allsum-line.excise-rubl-acc
          bf-bef_doc-line-sum.cost-transport-base   = bf_tt-allsum-line.transport-base-acc
          bf-bef_doc-line-sum.cost-transport-rubl   = bf_tt-allsum-line.transport-rubl-acc
          bf-bef_doc-line-sum.cost-other-base       = bf_tt-allsum-line.other-base-acc
          bf-bef_doc-line-sum.cost-other-rubl       = bf_tt-allsum-line.other-rubl-acc
          bf-bef_doc-line-sum.cost-discnt-base      = 0
          bf-bef_doc-line-sum.cost-discnt-rubl      = 0
        .
        if varinvclcspvalue = "yes" then do:
          assign
            bf-bef-cli_doc-line-sum.fact-qnty             = bf_tt-allsum-line.cli-qnty
            bf-bef-cli_doc-line-sum.sale-sum-base         = bf_tt-allsum-line.sum-dsc-base-cur
            bf-bef-cli_doc-line-sum.sale-sum-rubl         = bf_tt-allsum-line.sum-dsc-rubl-cur
            bf-bef-cli_doc-line-sum.sale-VAT-base         = bf_tt-allsum-line.vat-base-cur
            bf-bef-cli_doc-line-sum.sale-VAT-rubl         = bf_tt-allsum-line.vat-rubl-cur
            bf-bef-cli_doc-line-sum.sale-SLT-base         = bf_tt-allsum-line.slt-base-cur
            bf-bef-cli_doc-line-sum.sale-SLT-rubl         = bf_tt-allsum-line.slt-rubl-cur
            bf-bef-cli_doc-line-sum.sale-road-tax-base    = bf_tt-allsum-line.road-tax-base-cur
            bf-bef-cli_doc-line-sum.sale-road-tax-rubl    = bf_tt-allsum-line.road-tax-rubl-cur
            bf-bef-cli_doc-line-sum.sale-excise-base      = bf_tt-allsum-line.excise-base-cur
            bf-bef-cli_doc-line-sum.sale-excise-rubl      = bf_tt-allsum-line.excise-rubl-cur
            bf-bef-cli_doc-line-sum.sale-transport-base   = 0
            bf-bef-cli_doc-line-sum.sale-transport-rubl   = 0
            bf-bef-cli_doc-line-sum.sale-other-base       = 0
            bf-bef-cli_doc-line-sum.sale-other-rubl       = 0
            bf-bef-cli_doc-line-sum.sale-discnt-base      = bf_tt-allsum-line.dsc-base-cur
            bf-bef-cli_doc-line-sum.sale-discnt-rubl      = bf_tt-allsum-line.dsc-rubl-cur
            bf-bef-cli_doc-line-sum.crsa-sum-base         = bf_tt-allsum-line.sum-dsc-base-cur
            bf-bef-cli_doc-line-sum.crsa-sum-rubl         = bf_tt-allsum-line.sum-dsc-rubl-cur
            bf-bef-cli_doc-line-sum.crsa-VAT-base         = bf_tt-allsum-line.vat-base-cur
            bf-bef-cli_doc-line-sum.crsa-VAT-rubl         = bf_tt-allsum-line.vat-rubl-cur
            bf-bef-cli_doc-line-sum.crsa-SLT-base         = bf_tt-allsum-line.slt-base-cur
            bf-bef-cli_doc-line-sum.crsa-SLT-rubl         = bf_tt-allsum-line.slt-rubl-cur
            bf-bef-cli_doc-line-sum.crsa-road-tax-base    = bf_tt-allsum-line.road-tax-base-cur
            bf-bef-cli_doc-line-sum.crsa-road-tax-rubl    = bf_tt-allsum-line.road-tax-rubl-cur
            bf-bef-cli_doc-line-sum.crsa-excise-base      = bf_tt-allsum-line.excise-base-cur
            bf-bef-cli_doc-line-sum.crsa-excise-rubl      = bf_tt-allsum-line.excise-rubl-cur
            bf-bef-cli_doc-line-sum.crsa-transport-base   = 0
            bf-bef-cli_doc-line-sum.crsa-transport-rubl   = 0
            bf-bef-cli_doc-line-sum.crsa-other-base       = 0
            bf-bef-cli_doc-line-sum.crsa-other-rubl       = 0
            bf-bef-cli_doc-line-sum.crsa-discnt-base      = bf_tt-allsum-line.dsc-base-cur
            bf-bef-cli_doc-line-sum.crsa-discnt-rubl      = bf_tt-allsum-line.dsc-rubl-cur
            bf-bef-cli_doc-line-sum.cost-sum-base         = bf_tt-allsum-line.sum-dsc-base-acc
            bf-bef-cli_doc-line-sum.cost-sum-rubl         = bf_tt-allsum-line.sum-dsc-rubl-acc
            bf-bef-cli_doc-line-sum.cost-VAT-base         = bf_tt-allsum-line.vat-base-acc
            bf-bef-cli_doc-line-sum.cost-VAT-rubl         = bf_tt-allsum-line.vat-rubl-acc
            bf-bef-cli_doc-line-sum.cost-SLT-base         = bf_tt-allsum-line.slt-base-acc
            bf-bef-cli_doc-line-sum.cost-SLT-rubl         = bf_tt-allsum-line.slt-rubl-acc
            bf-bef-cli_doc-line-sum.cost-road-tax-base    = bf_tt-allsum-line.road-tax-base-acc
            bf-bef-cli_doc-line-sum.cost-road-tax-rubl    = bf_tt-allsum-line.road-tax-rubl-acc
            bf-bef-cli_doc-line-sum.cost-excise-base      = bf_tt-allsum-line.excise-base-acc
            bf-bef-cli_doc-line-sum.cost-excise-rubl      = bf_tt-allsum-line.excise-rubl-acc
            bf-bef-cli_doc-line-sum.cost-transport-base   = bf_tt-allsum-line.transport-base-acc
            bf-bef-cli_doc-line-sum.cost-transport-rubl   = bf_tt-allsum-line.transport-rubl-acc
            bf-bef-cli_doc-line-sum.cost-other-base       = bf_tt-allsum-line.other-base-acc
            bf-bef-cli_doc-line-sum.cost-other-rubl       = bf_tt-allsum-line.other-rubl-acc
            bf-bef-cli_doc-line-sum.cost-discnt-base      = 0
            bf-bef-cli_doc-line-sum.cost-discnt-rubl      = 0
          .
        end. /* if varinvclcspvalue = "yes" */
      end. /* if available tt-clcparts */
    end. /* if available bf_gds-obj */
  end. /* for each bf_doc-line */
  { str/reclctsl.i
    bf_trn-doc.doc-code
    {&sum-before-doc}
    no-error
  }
  if error-status :error then do:
    return error substitute( "Ошибка при вызове str/reclctsl.i: &1 &2."
                           , return-value
                           , error-status :get-message( 1 ) ).
  end.
  if varinvclcspvalue = "yes" then do:
    { str/reclctsl.i
      bf_trn-doc.doc-code
      {&sum-before-cli-doc}
      no-error
    }
    if error-status :error then do:
      return error substitute( "Ошибка при вызове str/reclctsl.i: &1 &2."
                             , return-value
                             , error-status :get-message( 1 ) ).
    end.
  end.
  run waitfram-show in this-procedure ( input "Расчет шапки документа." ) no-error.
  run str/calc-hd.p ( input bf_trn-doc.doc-code ) no-error.
  if error-status :error then do:
    return error substitute( "Ошибка при вызове calc-hd.p: &1 &2.", return-value, error-status :get-message( 1 ) ).
  end.
  run waitfram-show in this-procedure ( input "Расчет дополнительных сумм." ) no-error.
  run str/clcsumga.p ( input bf_trn-doc.doc-code ) no-error.
  if error-status :error then do:
    return error substitute( "Ошибка при вызове clcsumga.p: &1 &2.", return-value, error-status :get-message( 1 ) ).
  end.
  run waitfram-hide in this-procedure no-error.
end. /* transaction */

procedure local-create-sum :
  define input parameter parsum-type as character no-undo.

  define buffer bf_trn-doc-sum  for ub.trn-doc-sum.
  define buffer bf_doc-line-sum for ub.doc-line-sum.

  do on error undo, return error return-value :
    find first bf_trn-doc-sum exclusive-lock where
               bf_trn-doc-sum.doc-code = bf_trn-doc.doc-code and
               bf_trn-doc-sum.sum-type = parsum-type         no-error.
    if not available bf_trn-doc-sum then do:
      /* Создаем заголовки и линии */
      { str/crtrnsum.i bf_trn-doc.doc-code
                   parsum-type         no-error }
      if error-status :error then do:
        return error substitute( "Ошибка при вызове процедуры lib-rwds_crtrnsum &1 &2."
                               , return-value
                               , error-status :get-message( 1 ) ).
      end.
    end. /* if not available bf_trn-doc-sum */
    else do: /* if available bf_trn-doc-sum */
      { str/cltrnsum.i bf_trn-doc.doc-code
                   parsum-type         no-error }
      if error-status :error then do:
        return error substitute( "Ошибка при вызове процедуры lib-rwds_cltrnsum &1 &2."
                               , return-value
                               , error-status :get-message( 1 ) ).
      end.
      if lookup( parsum-type, varvalue ) = 0 then do:
        assign
          varvalue = varvalue + min( varvalue, "," ) + parsum-type.
        { str/tdat-wrt.i bf_trn-doc.doc-code
                     {&trdcattr-addsum}
                     varvalue            no-error }
        if error-status :error then do:
          run waitfram-hide in this-procedure no-error.
          undo, return error substitute( 'Ошибка &1 &2 на вызове программы tdat-wrt при расчете естественной убыли '
                                       + 'по документу "&3".'
                                       , return-value
                                       , error-status :get-message( 1 )
                                       , bf_trn-doc.doc-code ).
        end.
      end.
    end. /* if available bf_trn-doc-sum */
    if parsum-type <> {&sum-extra-doc}     and
       parsum-type <> {&sum-extra-cli-doc} and
       parsum-type <> {&sum-miss-doc}      and
       parsum-type <> {&sum-miss-cli-doc}  then do:
      assign
        varcount = 0.
      for each bf_doc-line where
               bf_doc-line.doc-code = bf_trn-doc.doc-code
      on error undo, return error return-value :
        assign
          varcount = varcount + 1.
        run waitfram-show in this-procedure (
          input waitfram-join-function ( substitute( 'Создаем недостающие линии сумм типа "&1".', parsum-type ),
                                         substitute( "Обработано строк: &1", varcount ),
                                         substitute( "Время &1.", string( time - vartime, "hh:mm:ss":U ) )
                                       )    ) no-error.

        find first bf_goods no-lock where
                   bf_goods.artic     = bf_doc-line.artic     and
                   bf_goods.prod-type = bf_doc-line.prod-type and
                   bf_goods.prod-code = bf_doc-line.prod-code.
        find first bf_doc-line-sum exclusive-lock where
                   bf_doc-line-sum.doc-code = bf_doc-line.doc-code and
                   bf_doc-line-sum.gds-code = bf_goods.gds-code    and
                   bf_doc-line-sum.sum-type = parsum-type          no-error.
        if not available bf_doc-line-sum then do:
          { str/crlinsum.i bf_trn-doc.doc-code
                       parsum-type
                       bf_doc-line.artic
                       bf_doc-line.prod-type
                       bf_doc-line.prod-code no-error }
          if error-status :error then do:
            return error substitute( "Ошибка при вызове процедуры lib-rwds_crlinsum &1 &2."
                                   , return-value
                                   , error-status :get-message( 1 ) ).
          end.
        end.
      end. /* for each bf_doc-line */
    end.
  end. /* on error */
end procedure. /* local-create-sum */