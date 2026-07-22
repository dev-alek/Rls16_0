block-level on error undo, throw.
/*

$Revision: 41853a5ca5bc, 1585, rls $
$Author: ASMorozov $
$Date: 2018/11/06 01:41:36 $
$Workfile: lib-rwds.p $
$Archive: str/lib-rwds.p $

Библиотека процедур по работе с информационными таблицами trn-doc-sum doc-line-sum

Автор: Чернова Светлана Александровна
Дата создания: 11/09/06
Author: Svetlana Chernova
Creation date: 11/09/06

CREATE1: Булгаков Андрей Николаевич
Дата создания: 01/30/06

*/

/* ********************************************************************************************************************* *\
 *                                                                                                                       *
 * procedure lib-rwds_crtrnsum - rwdocsum_create-trn                                                                     *
 * procedure lib-rwds_cltrnsum - rwdocsum_clear-trn                                                                      *
 * procedure lib-rwds_crlinsum - rwdocsum_create-line                                                                    *
 * procedure lib-rwds_cllinsum - rwdocsum_clear-line                                                                     *
 * procedure lib-rwds_cctrnsum - rwdocsum-calc                                                                           *
 * procedure lib-rwds_ttdlsdel - rwdocsum-tt_delete                                                                      *
 * procedure lib-rwds_ccwstsum - rwdocsum_clc-wast                                                                       *
 * procedure lib-rwds_updtrsum - rwdocsum_update-doc                                                                     *
 * procedure lib-rwds_rcallfct - rwdocsum_recalc-all-fact                                                                *
 *                                                                                                                       *
\* ********************************************************************************************************************* */

define variable vss-revision    as character no-undo initial "$Revision: 41853a5ca5bc, 1585, rls $":U.
define variable vss-author      as character no-undo initial "$Author: ASMorozov $":U.
define variable vss-date        as character no-undo initial "$Date: 2018/11/06 01:41:36 $":U.
define variable vss-workfile    as character no-undo initial "$Workfile: lib-rwds.p $":U.
define variable vss-archive     as character no-undo initial "$Archive: str/lib-rwds.p $":U.
define variable vss-description as character no-undo initial "Библиотека процедур по работе с информационными таблицами trn-doc-sum doc-line-sum":U.

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ str/lib-rwds.i }
{ str/trdcalib.i }
{ trg/partslib.i }
{ str/clcprtsl.i }
{ gbl/waitfram.i }
{ trg/factord.i  }
{ gbl/getsect.i def }
{ ref/gdsoattr.i }
{ ref/gds-attr.i }

if valid-handle( g#lib-rwds ) and
   g#lib-rwds <> this-procedure :handle and
   g#lib-rwds :get-signature( 'lib-rwds_crtrnsum':U ) <> '' then do:
  message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
          'Попытка повторной загрузки библиотеки по работе с информационными таблицами'    skip( 0 )
          g#lib-rwds                     skip( 0 )
          g#lib-rwds     :type           skip( 0 )
          g#lib-rwds     :file-name      skip( 0 )
          valid-handle( g#lib-rwds     ) skip( 0 )
          this-procedure :handle         skip( 0 )
          this-procedure :type           skip( 0 )
          this-procedure :file-name      skip( 0 )
          valid-handle( this-procedure ) skip( 0 )
  view-as alert-box error.
  undo, return error.
end.
else do:
  assign
    g#lib-rwds = this-procedure :handle
  .
end.

if this-procedure :persistent <> yes then do:
  message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
          'Ошибка запуска библиотеки' program-name( 1 ) skip( 0 )
          'Попытка запустить ее как обычную процедуру.' skip( 1 )
  view-as alert-box error.
end.

on delete of this-procedure do:
  assign
    g#lib-rwds = ?
  .
end.

/* Создание сумм документа */
procedure lib-rwds_crtrnsum :
  define input parameter p-doc-code like ub.trn-doc.doc-code     no-undo.
  define input parameter p-sum-type like ub.trn-doc-sum.sum-type no-undo.
  define buffer bf_trn-doc      for ub.trn-doc.
  define buffer bf_trn-doc-sum  for ub.trn-doc-sum.
  define buffer bf_doc-attr     for ub.doc-attr.

  do on error undo, return error return-value :
    find first bf_trn-doc where
               bf_trn-doc.doc-code = p-doc-code no-error.
    if not available bf_trn-doc then do:
      return error substitute( 'Ошибка в процедуре lib-rwds_crtrnsum. Не найден документ с номером "&1".', p-doc-code ).
    end.
    find first bf_doc-attr where
               bf_doc-attr.doc-code  = bf_trn-doc.doc-code and
               bf_doc-attr.attr-code = {&trdcattr-addsum}  no-error.
    if not available bf_doc-attr then do:
      { str/tdat-wrt.i bf_trn-doc.doc-code
                   {&trdcattr-addsum}
                   p-sum-type          no-error }
    end.
    else do:
      if bf_doc-attr.attr-value = "":U then do:
        { str/tdat-wrt.i bf_trn-doc.doc-code
                     {&trdcattr-addsum}
                     p-sum-type          no-error }
      end.
      else do:
        { str/tdat-wrt.i bf_trn-doc.doc-code
                     {&trdcattr-addsum}
                     "bf_doc-attr.attr-value + ',' + p-sum-type" no-error }
      end.
    end.
    find first bf_trn-doc-sum where
               bf_trn-doc-sum.doc-code = bf_trn-doc.doc-code and
               bf_trn-doc-sum.sum-type = p-sum-type          no-error.
    if available bf_trn-doc-sum then do:
      return error substitute( 'Уже существует сумма типа "&1" по документу "&2".', p-sum-type, bf_trn-doc.doc-code ).
    end.
    create bf_trn-doc-sum.
    assign bf_trn-doc-sum.doc-code     = bf_trn-doc.doc-code
           bf_trn-doc-sum.ext-doc-type = bf_trn-doc.ext-doc-type
           bf_trn-doc-sum.obj-type     = bf_trn-doc.obj-type
           bf_trn-doc-sum.obj-code     = bf_trn-doc.obj-code
           bf_trn-doc-sum.sum-type     = p-sum-type.
  end. /* on error */
end procedure. /* lib-rwds_crtrnsum */

/* Очистка сумм документа */
procedure lib-rwds_cltrnsum :
  define input parameter p-doc-code like ub.trn-doc.doc-code     no-undo.
  define input parameter p-sum-type like ub.trn-doc-sum.sum-type no-undo.
  define buffer bf_trn-doc     for ub.trn-doc.
  define buffer bf_trn-doc-sum for ub.trn-doc-sum.

  do on error undo, return error return-value :
    find first bf_trn-doc where
               bf_trn-doc.doc-code = p-doc-code no-error.
    if not available bf_trn-doc then do:
      return error substitute( 'Ошибка в процедуре lib-rwds_clrtrnsm. Не найден документ с номером "&1".', p-doc-code ).
    end.
    for each bf_trn-doc-sum exclusive-lock where
             bf_trn-doc-sum.doc-code = p-doc-code and
             bf_trn-doc-sum.sum-type = p-sum-type
    on error undo, return error return-value :
      assign bf_trn-doc-sum.fact-qnty           = 0
             bf_trn-doc-sum.sale-sum-base       = 0
             bf_trn-doc-sum.sale-sum-rubl       = 0
             bf_trn-doc-sum.sale-VAT-base       = 0
             bf_trn-doc-sum.sale-VAT-rubl       = 0
             bf_trn-doc-sum.sale-SLT-base       = 0
             bf_trn-doc-sum.sale-SLT-rubl       = 0
             bf_trn-doc-sum.sale-road-tax-base  = 0
             bf_trn-doc-sum.sale-road-tax-rubl  = 0
             bf_trn-doc-sum.sale-excise-base    = 0
             bf_trn-doc-sum.sale-excise-rubl    = 0
             bf_trn-doc-sum.sale-transport-base = 0
             bf_trn-doc-sum.sale-transport-rubl = 0
             bf_trn-doc-sum.sale-other-base     = 0
             bf_trn-doc-sum.sale-other-rubl     = 0
             bf_trn-doc-sum.sale-discnt-base    = 0
             bf_trn-doc-sum.sale-discnt-rubl    = 0
             bf_trn-doc-sum.crsa-sum-base       = 0
             bf_trn-doc-sum.crsa-sum-rubl       = 0
             bf_trn-doc-sum.crsa-VAT-base       = 0
             bf_trn-doc-sum.crsa-VAT-rubl       = 0
             bf_trn-doc-sum.crsa-SLT-base       = 0
             bf_trn-doc-sum.crsa-SLT-rubl       = 0
             bf_trn-doc-sum.crsa-road-tax-base  = 0
             bf_trn-doc-sum.crsa-road-tax-rubl  = 0
             bf_trn-doc-sum.crsa-excise-base    = 0
             bf_trn-doc-sum.crsa-excise-rubl    = 0
             bf_trn-doc-sum.crsa-transport-base = 0
             bf_trn-doc-sum.crsa-transport-rubl = 0
             bf_trn-doc-sum.crsa-other-base     = 0
             bf_trn-doc-sum.crsa-other-rubl     = 0
             bf_trn-doc-sum.crsa-discnt-base    = 0
             bf_trn-doc-sum.crsa-discnt-rubl    = 0
             bf_trn-doc-sum.cost-sum-base       = 0
             bf_trn-doc-sum.cost-sum-rubl       = 0
             bf_trn-doc-sum.cost-VAT-base       = 0
             bf_trn-doc-sum.cost-VAT-rubl       = 0
             bf_trn-doc-sum.cost-SLT-base       = 0
             bf_trn-doc-sum.cost-SLT-rubl       = 0
             bf_trn-doc-sum.cost-road-tax-base  = 0
             bf_trn-doc-sum.cost-road-tax-rubl  = 0
             bf_trn-doc-sum.cost-excise-base    = 0
             bf_trn-doc-sum.cost-excise-rubl    = 0
             bf_trn-doc-sum.cost-transport-base = 0
             bf_trn-doc-sum.cost-transport-rubl = 0
             bf_trn-doc-sum.cost-other-base     = 0
             bf_trn-doc-sum.cost-other-rubl     = 0
             bf_trn-doc-sum.cost-discnt-base    = 0
             bf_trn-doc-sum.cost-discnt-rubl    = 0.
    end. /* for each bf_trn-doc-sum */
  end. /* on error */
end procedure. /* lib-rwds_cltrnsum */

/* создание сумм линии */
procedure lib-rwds_crlinsum :
  define input parameter p-doc-code  like ub.trn-doc.doc-code      no-undo.
  define input parameter p-sum-type  like ub.doc-line-sum.sum-type no-undo.
  define input parameter p-artic     like ub.goods.artic           no-undo.
  define input parameter p-prod-type like ub.goods.prod-type       no-undo.
  define input parameter p-prod-code like ub.goods.prod-code       no-undo.
  define buffer bf_doc-line-sum for ub.doc-line-sum.
  define buffer bf_goods        for ub.goods.
  define buffer bf_trn-doc      for ub.trn-doc.

  do on error undo, return error return-value :
    find first bf_goods no-lock where
               bf_goods.artic     = p-artic     and
               bf_goods.prod-type = p-prod-type and
               bf_goods.prod-code = p-prod-code no-error.
    if not available bf_goods then do:
      return error substitute( 'Ошибка в процедуре lib-rwds_crlinsum. Не найден товар &1 &2 &3.',
                               p-artic, p-prod-type, p-prod-code ).
    end.
    find first bf_trn-doc where
               bf_trn-doc.doc-code = p-doc-code no-error.
    if not available bf_trn-doc then do:
      return error substitute( 'Ошибка в процедуре lib-rwds_crlinsum. Не найден документ с номером "&1".', p-doc-code ).
    end.
    find first bf_doc-line-sum where
               bf_doc-line-sum.doc-code = bf_trn-doc.doc-code and
               bf_doc-line-sum.gds-code = bf_goods.gds-code   and
               bf_doc-line-sum.sum-type = p-sum-type          no-error.
    if available bf_doc-line-sum then do:
      return error substitute( 'Уже есть строка сумм с типом "&1" по документу "&2" товар с внутренним номером &3.',
                               p-sum-type, bf_trn-doc.doc-code, bf_goods.gds-code ).
    end.
    create bf_doc-line-sum.
    assign bf_doc-line-sum.doc-code     = bf_trn-doc.doc-code
           bf_doc-line-sum.ext-doc-type = bf_trn-doc.ext-doc-type
           bf_doc-line-sum.obj-type     = bf_trn-doc.obj-type
           bf_doc-line-sum.obj-code     = bf_trn-doc.obj-code
           bf_doc-line-sum.gds-code     = bf_goods.gds-code
           bf_doc-line-sum.sum-type     = p-sum-type.
  end. /* on error */
end procedure. /* lib-rwds_crlinsum */

/* очистка сумм линии */
procedure lib-rwds_cllinsum :
  define input parameter p-doc-code  like ub.trn-doc.doc-code      no-undo.
  define input parameter p-sum-type  like ub.doc-line-sum.sum-type no-undo.
  define input parameter p-artic     like ub.goods.artic           no-undo.
  define input parameter p-prod-type like ub.goods.prod-type       no-undo.
  define input parameter p-prod-code like ub.goods.prod-code       no-undo.
  define buffer bf_doc-line-sum for ub.doc-line-sum.
  define buffer bf_goods        for ub.goods.

  do on error undo, return error return-value :
    find first bf_goods no-lock where
               bf_goods.artic     = p-artic     and
               bf_goods.prod-type = p-prod-type and
               bf_goods.prod-code = p-prod-code no-error.
    if not available bf_goods then do:
      return error substitute( 'Ошибка в процедуре lib-rwds_cllinsum. Не найден товар &1 &2 &3.',
                               p-artic, p-prod-type, p-prod-code ).
    end.
    find first bf_doc-line-sum exclusive-lock where
               bf_doc-line-sum.doc-code = p-doc-code        and
               bf_doc-line-sum.sum-type = p-sum-type        and
               bf_doc-line-sum.gds-code = bf_goods.gds-code no-error.
    if error-status :error then do:
      return error substitute( 'Ошибка в процедуре lib-rwds_cllinsum. Не найдена запись doc-line-sum по документу "&1" ' +
                               'c типом "&2" по товару &3 &4 &5.',
                               p-doc-code,
                               p-sum-type,
                               bf_goods.artic,
                               bf_goods.prod-type,
                               bf_goods.prod-code ).
    end.
    assign bf_doc-line-sum.fact-qnty           = 0
           bf_doc-line-sum.sale-sum-base       = 0
           bf_doc-line-sum.sale-sum-rubl       = 0
           bf_doc-line-sum.sale-VAT-base       = 0
           bf_doc-line-sum.sale-VAT-rubl       = 0
           bf_doc-line-sum.sale-SLT-base       = 0
           bf_doc-line-sum.sale-SLT-rubl       = 0
           bf_doc-line-sum.sale-road-tax-base  = 0
           bf_doc-line-sum.sale-road-tax-rubl  = 0
           bf_doc-line-sum.sale-excise-base    = 0
           bf_doc-line-sum.sale-excise-rubl    = 0
           bf_doc-line-sum.sale-transport-base = 0
           bf_doc-line-sum.sale-transport-rubl = 0
           bf_doc-line-sum.sale-other-base     = 0
           bf_doc-line-sum.sale-other-rubl     = 0
           bf_doc-line-sum.sale-discnt-base    = 0
           bf_doc-line-sum.sale-discnt-rubl    = 0
           bf_doc-line-sum.crsa-sum-base       = 0
           bf_doc-line-sum.crsa-sum-rubl       = 0
           bf_doc-line-sum.crsa-VAT-base       = 0
           bf_doc-line-sum.crsa-VAT-rubl       = 0
           bf_doc-line-sum.crsa-SLT-base       = 0
           bf_doc-line-sum.crsa-SLT-rubl       = 0
           bf_doc-line-sum.crsa-road-tax-base  = 0
           bf_doc-line-sum.crsa-road-tax-rubl  = 0
           bf_doc-line-sum.crsa-excise-base    = 0
           bf_doc-line-sum.crsa-excise-rubl    = 0
           bf_doc-line-sum.crsa-transport-base = 0
           bf_doc-line-sum.crsa-transport-rubl = 0
           bf_doc-line-sum.crsa-other-base     = 0
           bf_doc-line-sum.crsa-other-rubl     = 0
           bf_doc-line-sum.crsa-discnt-base    = 0
           bf_doc-line-sum.crsa-discnt-rubl    = 0
           bf_doc-line-sum.cost-sum-base       = 0
           bf_doc-line-sum.cost-sum-rubl       = 0
           bf_doc-line-sum.cost-VAT-base       = 0
           bf_doc-line-sum.cost-VAT-rubl       = 0
           bf_doc-line-sum.cost-SLT-base       = 0
           bf_doc-line-sum.cost-SLT-rubl       = 0
           bf_doc-line-sum.cost-road-tax-base  = 0
           bf_doc-line-sum.cost-road-tax-rubl  = 0
           bf_doc-line-sum.cost-excise-base    = 0
           bf_doc-line-sum.cost-excise-rubl    = 0
           bf_doc-line-sum.cost-transport-base = 0
           bf_doc-line-sum.cost-transport-rubl = 0
           bf_doc-line-sum.cost-other-base     = 0
           bf_doc-line-sum.cost-other-rubl     = 0
           bf_doc-line-sum.cost-discnt-base    = 0
           bf_doc-line-sum.cost-discnt-rubl    = 0.
  end. /* on error */
end procedure. /* lib-rwds_cllinsum */

/* Создание основной записи сумм по строке */
procedure lib-rwds_cctrnsum :
  define input        parameter           p-doc-code       like ub.trn-doc.doc-code   no-undo.
  define input        parameter           p-artic          like ub.doc-line.artic     no-undo.
  define input        parameter           p-prod-type      like ub.doc-line.prod-type no-undo.
  define input        parameter           p-prod-code      like ub.doc-line.prod-code no-undo.
  define input        parameter           p-sum-type-list  as   character             no-undo.
  define input-output parameter table for tt-allsum-line.
  define input-output parameter table for tt-doc-line-sum.
  define input-output parameter table for tt-clcparts.
  define input-output parameter table for temp-parts.
  define buffer bf_doc-line             for ub.doc-line.
  define buffer bf_goods                for ub.goods.
  define buffer bf_parts                for ub.parts.
  define buffer bf_gen_doc-line-sum     for ub.doc-line-sum.
  define buffer bf_bef_doc-line-sum     for ub.doc-line-sum.
  define buffer bf_aft_doc-line-sum     for ub.doc-line-sum.
  define buffer bf_gen-cli_doc-line-sum for ub.doc-line-sum.
  define buffer bf_bef-cli_doc-line-sum for ub.doc-line-sum.
  define buffer bf_aft-cli_doc-line-sum for ub.doc-line-sum.
  define buffer bf_tt-allsum-line       for tt-allsum-line.
  define buffer bf_doc-line-sum         for ub.doc-line-sum.
  define buffer bf_trn-doc              for ub.trn-doc.
  define buffer bf_gds-obj              for ub.gds-obj.
  define buffer bf_prt-obj              for ub.prt-obj.
  define buffer bf_bar-code             for ub.bar-code.

  define variable v_curr-r-b              as   character             no-undo.
  define variable v_base-rate             like ub.trn-doc.base-rate  no-undo.
  define variable v_base-scale            like ub.trn-doc.base-scale no-undo.
  define variable d_vat-pc                as   decimal               no-undo.
  define variable d_slt-pc                as   decimal               no-undo.
  define variable d_cons-vat-pc           as   decimal               no-undo.
  define variable d_cur-price-sale        as   decimal               no-undo.
  define variable d_cur-price-road-tax    as   decimal               no-undo.
  define variable d_cur-price-excise      as   decimal               no-undo.
  define variable d_curprt-price-sale     as   decimal               no-undo.
  define variable d_curprt-price-road-tax as   decimal               no-undo.
  define variable d_curprt-price-excise   as   decimal               no-undo.
  define variable d_cur-base              as   decimal               no-undo.
  define variable d_cur-road-tax-base     as   decimal               no-undo.
  define variable d_cur-excise-base       as   decimal               no-undo.
  define variable d_fact-qnty             as   decimal               no-undo.
  define variable j_b-code                like ub.bar-code.b-code    no-undo.
  define variable v_doc-num               like ub.price-doc.doc-num  no-undo.
  define variable l_is-new                as   logical               no-undo.
  define variable l_create-part           as   logical               no-undo.
  define variable l_old-return            as   logical               no-undo.
  define variable v_rsrv-code             as   character             no-undo.
  define variable v_unrv-code             as   character             no-undo.
  define variable l_need-rsrv             as   logical               no-undo.
  define variable l_need-unrv             as   logical               no-undo.
  define variable j_rsrv-sign             as   integer               no-undo.
  define variable j_unrv-sign             as   integer               no-undo.
  define variable v_invclcsp              as   character             no-undo.
  define variable v_data-type             as   character             no-undo.
  define variable varfact-order           like ub.trn-doc.fact-order no-undo.

  do on error undo, return error return-value :
    find first bf_doc-line no-lock where
               bf_doc-line.doc-code  = p-doc-code  and
               bf_doc-line.artic     = p-artic     and
               bf_doc-line.prod-type = p-prod-type and
               bf_doc-line.prod-code = p-prod-code no-error.
    if not available bf_doc-line then do:
      return error substitute( 'Не найдена строка товара &1 &2 &3 в документе "&4".',
                               p-artic, p-prod-type, p-prod-code, p-doc-code ).
    end.
    find first bf_goods no-lock where
               bf_goods.artic     = bf_doc-line.artic     and
               bf_goods.prod-type = bf_doc-line.prod-type and
               bf_goods.prod-code = bf_doc-line.prod-code no-error.
    if not available bf_goods then do:
      return error substitute( 'Не найден товар &1 &2 &3.', p-artic, p-prod-type, p-prod-code ).
    end.
    for each tt-doc-line-sum :
      delete tt-doc-line-sum.
    end.
    find first bf_trn-doc where
               bf_trn-doc.doc-code = bf_doc-line.doc-code.
    if not available bf_trn-doc then do:
      return error substitute( 'Не найден документ "&1".', p-doc-code ).
    end.

    { gbl/getsect.i run bf_trn-doc.obj-type bf_trn-doc.obj-code {&attr-inv-obj} }
    for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = 'invclcsp'  then v_invclcsp = string( thbjattr_thbj-attr.property-value-logical, "yes/no").
    end.
    empty temp-table thbjattr_thbj-attr.
    if lookup( {&sum-before-doc},     p-sum-type-list ) <> 0 or
       lookup( {&sum-before-cli-doc}, p-sum-type-list ) <> 0 then do:
      if bf_trn-doc.status_ = {&fact} then do:
        return error substitute(
          'Документ "&1" находится в статусе "&2". Расчет сумм перед документом должен проводиться специальной утилитой.',
          bf_trn-doc.doc-code, bf_trn-doc.status_ ).
      end.
      if lookup( {&sum-before-doc}, p-sum-type-list ) <> 0 then do:
        find first bf_bef_doc-line-sum where
                   bf_bef_doc-line-sum.doc-code = bf_doc-line.doc-code and
                   bf_bef_doc-line-sum.gds-code = bf_goods.gds-code    and
                   bf_bef_doc-line-sum.sum-type = {&sum-before-doc}    no-error.
        if not available bf_bef_doc-line-sum then do:
          return error substitute(
            'Не найдена запись о дополнительных суммах в документе "&1", товар &2 &3 &4, тип суммы "&4".',
            bf_doc-line.doc-code,
            bf_goods.artic,
            bf_goods.prod-type,
            bf_goods.prod-code,
            {&sum-before-doc} ).
        end. /* if not available bf_bef_doc-line-sum */
      end. /* if lookup( {&sum-before-doc}, p-sum-type-list ) <> 0 */
      if v_invclcsp = "yes" then do:
        if lookup( {&sum-before-cli-doc}, p-sum-type-list ) <> 0 then do:
          find first bf_bef-cli_doc-line-sum where
                     bf_bef-cli_doc-line-sum.doc-code = bf_doc-line.doc-code  and
                     bf_bef-cli_doc-line-sum.gds-code = bf_goods.gds-code     and
                     bf_bef-cli_doc-line-sum.sum-type = {&sum-before-cli-doc} no-error.
          if not available bf_bef_doc-line-sum then do:
            return error substitute(
              'Не найдена запись о дополнительных суммах в документе "&1", товар &2 &3 &4, тип суммы "&4".',
              bf_doc-line.doc-code,
              bf_goods.artic,
              bf_goods.prod-type,
              bf_goods.prod-code,
              {&sum-before-cli-doc} ).
          end. /* if not available bf_bef_doc-line-sum */
        end. /* if lookup( {&sum-before-cli-doc}, p-sum-type-list ) <> 0 */
      end. /* if v_invclcsp = "yes" */
      find first bf_gds-obj no-lock where
                 bf_gds-obj.obj-type  = bf_doc-line.obj-type  and
                 bf_gds-obj.obj-code  = bf_doc-line.obj-code  and
                 bf_gds-obj.artic     = bf_doc-line.artic     and
                 bf_gds-obj.prod-type = bf_doc-line.prod-type and
                 bf_gds-obj.prod-code = bf_doc-line.prod-code no-error.
      if available bf_gds-obj then do:
        /* Считываем свободную зону по товару на текущий момент */
        run partslib-clear-temp-parts in this-procedure no-error.
        if error-status :error then do:
          return error substitute( 'Ошибка при запуске процедуры partslib-clear-temp-parts &1 &2.',
                                   return-value, error-status :get-message( 1 ) ).
        end.
        varfact-order = 0 .
        if bf_trn-doc.fact-date <> ? then do:
           run factord-end-day (bf_trn-doc.fact-date, output varfact-order).
           run partslib-init-temp-parts-by-factord in this-procedure (input bf_gds-obj.obj-type,
                                                                      input bf_gds-obj.obj-code,
                                                                      input bf_gds-obj.artic,
                                                                      input bf_gds-obj.prod-type,
                                                                      input bf_gds-obj.prod-code,
                                                                      input varfact-order,
                                                                      input no
                                                                     ) no-error.

        end.
        else do:
          run partslib-init-temp-parts in this-procedure ( input bf_gds-obj.obj-type
                                                         , input bf_gds-obj.obj-code
                                                         , input bf_gds-obj.artic
                                                         , input bf_gds-obj.prod-type
                                                         , input bf_gds-obj.prod-code ) no-error.
        end.
        if error-status :error then do:
          return error substitute(
            'Ошибка при запуске процедуры partslib-init-temp-parts &1 &2 объект &3 &4 товар &5 &6 &7.',
            return-value,
            error-status :get-message( 1 ),
            bf_gds-obj.obj-type,
            bf_gds-obj.obj-code,
            bf_gds-obj.artic,
            bf_gds-obj.prod-type,
            bf_gds-obj.prod-code ).
        end.
        for each tt-clcparts :
          delete tt-clcparts.
        end.
        for each temp-parts:
          create tt-clcparts.
          buffer-copy temp-parts to tt-clcparts.
        end.

        find first tt-clcparts no-error.
        if available tt-clcparts then do:
          /* Расчитываем среднюю продажную цену и ее налоги */
          { gbl/curr-r-b.i v_curr-r-b no-error }
          if bf_trn-doc.base-rate  = ? or
             bf_trn-doc.base-scale = ? then do:
            return error substitute( 'Не указан курс базовой валюты в документе "&1".', bf_trn-doc.doc-code ).
          end.
          assign v_base-rate  = bf_trn-doc.base-rate
                 v_base-scale = bf_trn-doc.base-scale.
          { gbl/pftxvalg.i bf_goods.gds-code
                       {&vat-tax-code}
                       ?
                       bf_trn-doc.host-code
                       bf_gds-obj.obj-type
                       bf_gds-obj.obj-code
                       d_vat-pc             }
          if d_vat-pc = ? then do:
            undo, return error substitute( 'Не задан НДС товара &1 &2 &3.'
                                         , bf_goods.artic
                                         , bf_goods.prod-type
                                         , bf_goods.prod-code ).
          end.
          { gbl/pftxvalg.i bf_goods.gds-code
                       {&slt-tax-code}
                       ?
                       bf_trn-doc.host-code
                       bf_gds-obj.obj-type
                       bf_gds-obj.obj-code
                       d_slt-pc             }
          if d_slt-pc = ? then do:
            undo, return error substitute( 'Не задан НП товара &1 &2 &3.'
                                         , bf_goods.artic
                                         , bf_goods.prod-type
                                         , bf_goods.prod-code ).
          end.
          { gbl/consvtpc.i bf_trn-doc.host-code d_cons-vat-pc }
          if d_cons-vat-pc = ? then do:
            undo, return error substitute( 'Не задан консигнационный НДС товара &1 &2 &3.'
                                          , bf_goods.artic
                                          , bf_goods.prod-type
                                          , bf_goods.prod-code ).
          end.
          assign d_fact-qnty          = 0
                 d_cur-base           = 0
                 d_cur-road-tax-base  = 0
                 d_cur-excise-base    = 0.
          for each bf_prt-obj where
                   bf_prt-obj.obj-type  = bf_gds-obj.obj-type  and
                   bf_prt-obj.obj-code  = bf_gds-obj.obj-code  and
                   bf_prt-obj.prod-type = bf_gds-obj.prod-type and
                   bf_prt-obj.prod-code = bf_gds-obj.prod-code and
                   bf_prt-obj.artic     = bf_gds-obj.artic
          on error undo, return error return-value :
            { gbl/barcodcr.i bf_goods.gds-code
                         bf_prt-obj.prt-code
                         "''"
                         "''"
                         bf_goods.unit-base
                         1
                         l_is-new
                         bf_bar-code         no-error }
            if error-status :error then do:
               undo, return error "Не могу создать(найти) первичный бар-кода признака "        + {&new-line} +
                                  "Код товара "                + string( bf_goods.gds-code   ) + {&new-line} +
                                  "Код признака "              + string( bf_prt-obj.prt-code ) + {&new-line} +
                                  "Базовая единица измерения " + string( bf_goods.unit-base  ) + {&new-line} +
                                  return-value.
            end.
            assign j_b-code = bf_bar-code.b-code.
            { gbl/bcodeprc.i bf_trn-doc.obj-type
                         bf_trn-doc.obj-code
                         j_b-code
                         0
                         varfact-order
                         v_doc-num
                         d_curprt-price-sale
                         d_curprt-price-road-tax
                         d_curprt-price-excise   }
            assign d_fact-qnty         = d_fact-qnty         + bf_prt-obj.fact-qnty
                   d_cur-base          = d_cur-base          + d_curprt-price-sale     * bf_prt-obj.fact-qnty
                   d_cur-road-tax-base = d_cur-road-tax-base + d_curprt-price-road-tax * bf_prt-obj.fact-qnty
                   d_cur-excise-base   = d_cur-excise-base   + d_curprt-price-excise   * bf_prt-obj.fact-qnty.
          end. /* for each bf_prt-obj */

          if d_fact-qnty <> 0 then do:
            assign d_cur-price-sale     = d_cur-base          / d_fact-qnty
                   d_cur-price-road-tax = d_cur-road-tax-base / d_fact-qnty
                   d_cur-price-excise   = d_cur-excise-base   / d_fact-qnty.
          end.
          else do:
            assign d_cur-price-sale     = 0
                   d_cur-price-road-tax = 0
                   d_cur-price-excise   = 0.
          end.
          if d_cur-price-sale     = ? then do: assign d_cur-price-sale     = 0. end.
          if d_cur-price-road-tax = ? then do: assign d_cur-price-road-tax = 0. end.
          if d_cur-price-excise   = ? then do: assign d_cur-price-excise   = 0. end.

          for each tt-allsum-line :
            delete tt-allsum-line.
          end.
          run clcprtsl_calc-ttable in this-procedure ( input no                   /* p-is-doc         */
                                                     , input yes                  /* p-is-cur         */
                                                     , input ?                    /* p-road-tax       */
                                                     , input ?                    /* p-excise         */
                                                     , input ?                    /* p-vat-pc         */
                                                     , input ?                    /* p-cons-vat-pc    */
                                                     , input ?                    /* p-slt-pc         */
                                                     , input v_base-rate          /* p-base-rate      */
                                                     , input v_base-scale         /* p-base-scale     */
                                                     , input v_curr-r-b           /* p-r-b            */
                                                     , input d_cur-price-sale     /* p-cur-base       */
                                                     , input d_cur-price-road-tax /* p-cur-road-tax   */
                                                     , input d_cur-price-excise   /* p-cur-excise     */
                                                     , input d_vat-pc             /* p-cur-vat-pc     */
                                                     , input d_cons-vat-pc        /* p-curcons-vat-pc */
                                                     , input d_slt-pc             /* p-curslt-pc      */ ) no-error .
          if error-status :error then do:
            undo, return error "Ошибка при расчете учетных цен по партии".
          end.
          find first tt-allsum-line where
                     tt-allsum-line.sum-type = {&sum-general} no-error.
          if error-status :error then do:
            return error substitute( 'Не найдена запись по типу "&1" для товара &2 &3 &4.',
                                     {&sum-general}, bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code ).
          end.
          if lookup( {&sum-before-doc}, p-sum-type-list ) <> 0 then do:
            assign bf_bef_doc-line-sum.fact-qnty             = tt-allsum-line.fact-qnty
                   bf_bef_doc-line-sum.sale-sum-base         = 0
                   bf_bef_doc-line-sum.sale-sum-rubl         = 0
                   bf_bef_doc-line-sum.sale-VAT-base         = 0
                   bf_bef_doc-line-sum.sale-VAT-rubl         = 0
                   bf_bef_doc-line-sum.sale-SLT-base         = 0
                   bf_bef_doc-line-sum.sale-SLT-rubl         = 0
                   bf_bef_doc-line-sum.sale-road-tax-base    = 0
                   bf_bef_doc-line-sum.sale-road-tax-rubl    = 0
                   bf_bef_doc-line-sum.sale-excise-base      = 0
                   bf_bef_doc-line-sum.sale-excise-rubl      = 0
                   bf_bef_doc-line-sum.sale-transport-base   = 0
                   bf_bef_doc-line-sum.sale-transport-rubl   = 0
                   bf_bef_doc-line-sum.sale-other-base       = 0
                   bf_bef_doc-line-sum.sale-other-rubl       = 0
                   bf_bef_doc-line-sum.sale-discnt-base      = 0
                   bf_bef_doc-line-sum.sale-discnt-rubl      = 0
                   bf_bef_doc-line-sum.crsa-sum-base         = tt-allsum-line.sum-dsc-base-cur
                   bf_bef_doc-line-sum.crsa-sum-rubl         = tt-allsum-line.sum-dsc-rubl-cur
                   bf_bef_doc-line-sum.crsa-VAT-base         = tt-allsum-line.vat-base-cur
                   bf_bef_doc-line-sum.crsa-VAT-rubl         = tt-allsum-line.vat-rubl-cur
                   bf_bef_doc-line-sum.crsa-SLT-base         = tt-allsum-line.slt-base-cur
                   bf_bef_doc-line-sum.crsa-SLT-rubl         = tt-allsum-line.slt-rubl-cur
                   bf_bef_doc-line-sum.crsa-road-tax-base    = tt-allsum-line.road-tax-base-cur
                   bf_bef_doc-line-sum.crsa-road-tax-rubl    = tt-allsum-line.road-tax-rubl-cur
                   bf_bef_doc-line-sum.crsa-excise-base      = tt-allsum-line.excise-base-cur
                   bf_bef_doc-line-sum.crsa-excise-rubl      = tt-allsum-line.excise-rubl-cur
                   bf_bef_doc-line-sum.crsa-transport-base   = 0
                   bf_bef_doc-line-sum.crsa-transport-rubl   = 0
                   bf_bef_doc-line-sum.crsa-other-base       = 0
                   bf_bef_doc-line-sum.crsa-other-rubl       = 0
                   bf_bef_doc-line-sum.crsa-discnt-base      = tt-allsum-line.dsc-base-cur
                   bf_bef_doc-line-sum.crsa-discnt-rubl      = tt-allsum-line.dsc-rubl-cur
                   bf_bef_doc-line-sum.cost-sum-base         = tt-allsum-line.sum-dsc-base-acc
                   bf_bef_doc-line-sum.cost-sum-rubl         = tt-allsum-line.sum-dsc-rubl-acc
                   bf_bef_doc-line-sum.cost-VAT-base         = tt-allsum-line.vat-base-acc
                   bf_bef_doc-line-sum.cost-VAT-rubl         = tt-allsum-line.vat-rubl-acc
                   bf_bef_doc-line-sum.cost-SLT-base         = tt-allsum-line.slt-base-acc
                   bf_bef_doc-line-sum.cost-SLT-rubl         = tt-allsum-line.slt-rubl-acc
                   bf_bef_doc-line-sum.cost-road-tax-base    = tt-allsum-line.road-tax-base-acc
                   bf_bef_doc-line-sum.cost-road-tax-rubl    = tt-allsum-line.road-tax-rubl-acc
                   bf_bef_doc-line-sum.cost-excise-base      = tt-allsum-line.excise-base-acc
                   bf_bef_doc-line-sum.cost-excise-rubl      = tt-allsum-line.excise-rubl-acc
                   bf_bef_doc-line-sum.cost-transport-base   = tt-allsum-line.transport-base-acc
                   bf_bef_doc-line-sum.cost-transport-rubl   = tt-allsum-line.transport-rubl-acc
                   bf_bef_doc-line-sum.cost-other-base       = tt-allsum-line.other-base-acc
                   bf_bef_doc-line-sum.cost-other-rubl       = tt-allsum-line.other-rubl-acc
                   bf_bef_doc-line-sum.cost-discnt-base      = 0
                   bf_bef_doc-line-sum.cost-discnt-rubl      = 0.
          end.
          if v_invclcsp = "yes" then do:
            if lookup( {&sum-before-cli-doc}, p-sum-type-list ) <> 0 then do:
              assign bf_bef-cli_doc-line-sum.fact-qnty             = tt-allsum-line.cli-qnty
                     bf_bef-cli_doc-line-sum.sale-sum-base         = 0
                     bf_bef-cli_doc-line-sum.sale-sum-rubl         = 0
                     bf_bef-cli_doc-line-sum.sale-VAT-base         = 0
                     bf_bef-cli_doc-line-sum.sale-VAT-rubl         = 0
                     bf_bef-cli_doc-line-sum.sale-SLT-base         = 0
                     bf_bef-cli_doc-line-sum.sale-SLT-rubl         = 0
                     bf_bef-cli_doc-line-sum.sale-road-tax-base    = 0
                     bf_bef-cli_doc-line-sum.sale-road-tax-rubl    = 0
                     bf_bef-cli_doc-line-sum.sale-excise-base      = 0
                     bf_bef-cli_doc-line-sum.sale-excise-rubl      = 0
                     bf_bef-cli_doc-line-sum.sale-transport-base   = 0
                     bf_bef-cli_doc-line-sum.sale-transport-rubl   = 0
                     bf_bef-cli_doc-line-sum.sale-other-base       = 0
                     bf_bef-cli_doc-line-sum.sale-other-rubl       = 0
                     bf_bef-cli_doc-line-sum.sale-discnt-base      = 0
                     bf_bef-cli_doc-line-sum.sale-discnt-rubl      = 0
                     bf_bef-cli_doc-line-sum.crsa-sum-base         = tt-allsum-line.sum-dsc-base-cur
                     bf_bef-cli_doc-line-sum.crsa-sum-rubl         = tt-allsum-line.sum-dsc-rubl-cur
                     bf_bef-cli_doc-line-sum.crsa-VAT-base         = tt-allsum-line.vat-base-cur
                     bf_bef-cli_doc-line-sum.crsa-VAT-rubl         = tt-allsum-line.vat-rubl-cur
                     bf_bef-cli_doc-line-sum.crsa-SLT-base         = tt-allsum-line.slt-base-cur
                     bf_bef-cli_doc-line-sum.crsa-SLT-rubl         = tt-allsum-line.slt-rubl-cur
                     bf_bef-cli_doc-line-sum.crsa-road-tax-base    = tt-allsum-line.road-tax-base-cur
                     bf_bef-cli_doc-line-sum.crsa-road-tax-rubl    = tt-allsum-line.road-tax-rubl-cur
                     bf_bef-cli_doc-line-sum.crsa-excise-base      = tt-allsum-line.excise-base-cur
                     bf_bef-cli_doc-line-sum.crsa-excise-rubl      = tt-allsum-line.excise-rubl-cur
                     bf_bef-cli_doc-line-sum.crsa-transport-base   = 0
                     bf_bef-cli_doc-line-sum.crsa-transport-rubl   = 0
                     bf_bef-cli_doc-line-sum.crsa-other-base       = 0
                     bf_bef-cli_doc-line-sum.crsa-other-rubl       = 0
                     bf_bef-cli_doc-line-sum.crsa-discnt-base      = tt-allsum-line.dsc-base-cur
                     bf_bef-cli_doc-line-sum.crsa-discnt-rubl      = tt-allsum-line.dsc-rubl-cur
                     bf_bef-cli_doc-line-sum.cost-sum-base         = tt-allsum-line.sum-dsc-base-acc
                     bf_bef-cli_doc-line-sum.cost-sum-rubl         = tt-allsum-line.sum-dsc-rubl-acc
                     bf_bef-cli_doc-line-sum.cost-VAT-base         = tt-allsum-line.vat-base-acc
                     bf_bef-cli_doc-line-sum.cost-VAT-rubl         = tt-allsum-line.vat-rubl-acc
                     bf_bef-cli_doc-line-sum.cost-SLT-base         = tt-allsum-line.slt-base-acc
                     bf_bef-cli_doc-line-sum.cost-SLT-rubl         = tt-allsum-line.slt-rubl-acc
                     bf_bef-cli_doc-line-sum.cost-road-tax-base    = tt-allsum-line.road-tax-base-acc
                     bf_bef-cli_doc-line-sum.cost-road-tax-rubl    = tt-allsum-line.road-tax-rubl-acc
                     bf_bef-cli_doc-line-sum.cost-excise-base      = tt-allsum-line.excise-base-acc
                     bf_bef-cli_doc-line-sum.cost-excise-rubl      = tt-allsum-line.excise-rubl-acc
                     bf_bef-cli_doc-line-sum.cost-transport-base   = tt-allsum-line.transport-base-acc
                     bf_bef-cli_doc-line-sum.cost-transport-rubl   = tt-allsum-line.transport-rubl-acc
                     bf_bef-cli_doc-line-sum.cost-other-base       = tt-allsum-line.other-base-acc
                     bf_bef-cli_doc-line-sum.cost-other-rubl       = tt-allsum-line.other-rubl-acc
                     bf_bef-cli_doc-line-sum.cost-discnt-base      = 0
                     bf_bef-cli_doc-line-sum.cost-discnt-rubl      = 0.
            end. /* if lookup( {&sum-before-cli-doc}, p-sum-type-list ) <> 0 */
          end. /* if v_invclcsp = "yes" */
        end. /* if available tt-clcparts */
        else do: /* if not available tt-clcparts */
          if lookup( {&sum-before-doc}, p-sum-type-list ) <> 0 then do:
            assign bf_bef_doc-line-sum.fact-qnty             = 0
                   bf_bef_doc-line-sum.sale-sum-base         = 0
                   bf_bef_doc-line-sum.sale-sum-rubl         = 0
                   bf_bef_doc-line-sum.sale-VAT-base         = 0
                   bf_bef_doc-line-sum.sale-VAT-rubl         = 0
                   bf_bef_doc-line-sum.sale-SLT-base         = 0
                   bf_bef_doc-line-sum.sale-SLT-rubl         = 0
                   bf_bef_doc-line-sum.sale-road-tax-base    = 0
                   bf_bef_doc-line-sum.sale-road-tax-rubl    = 0
                   bf_bef_doc-line-sum.sale-excise-base      = 0
                   bf_bef_doc-line-sum.sale-excise-rubl      = 0
                   bf_bef_doc-line-sum.sale-transport-base   = 0
                   bf_bef_doc-line-sum.sale-transport-rubl   = 0
                   bf_bef_doc-line-sum.sale-other-base       = 0
                   bf_bef_doc-line-sum.sale-other-rubl       = 0
                   bf_bef_doc-line-sum.sale-discnt-base      = 0
                   bf_bef_doc-line-sum.sale-discnt-rubl      = 0
                   bf_bef_doc-line-sum.crsa-sum-base         = 0
                   bf_bef_doc-line-sum.crsa-sum-rubl         = 0
                   bf_bef_doc-line-sum.crsa-VAT-base         = 0
                   bf_bef_doc-line-sum.crsa-VAT-rubl         = 0
                   bf_bef_doc-line-sum.crsa-SLT-base         = 0
                   bf_bef_doc-line-sum.crsa-SLT-rubl         = 0
                   bf_bef_doc-line-sum.crsa-road-tax-base    = 0
                   bf_bef_doc-line-sum.crsa-road-tax-rubl    = 0
                   bf_bef_doc-line-sum.crsa-excise-base      = 0
                   bf_bef_doc-line-sum.crsa-excise-rubl      = 0
                   bf_bef_doc-line-sum.crsa-transport-base   = 0
                   bf_bef_doc-line-sum.crsa-transport-rubl   = 0
                   bf_bef_doc-line-sum.crsa-other-base       = 0
                   bf_bef_doc-line-sum.crsa-other-rubl       = 0
                   bf_bef_doc-line-sum.crsa-discnt-base      = 0
                   bf_bef_doc-line-sum.crsa-discnt-rubl      = 0
                   bf_bef_doc-line-sum.cost-sum-base         = 0
                   bf_bef_doc-line-sum.cost-sum-rubl         = 0
                   bf_bef_doc-line-sum.cost-VAT-base         = 0
                   bf_bef_doc-line-sum.cost-VAT-rubl         = 0
                   bf_bef_doc-line-sum.cost-SLT-base         = 0
                   bf_bef_doc-line-sum.cost-SLT-rubl         = 0
                   bf_bef_doc-line-sum.cost-road-tax-base    = 0
                   bf_bef_doc-line-sum.cost-road-tax-rubl    = 0
                   bf_bef_doc-line-sum.cost-excise-base      = 0
                   bf_bef_doc-line-sum.cost-excise-rubl      = 0
                   bf_bef_doc-line-sum.cost-transport-base   = 0
                   bf_bef_doc-line-sum.cost-transport-rubl   = 0
                   bf_bef_doc-line-sum.cost-other-base       = 0
                   bf_bef_doc-line-sum.cost-other-rubl       = 0
                   bf_bef_doc-line-sum.cost-discnt-base      = 0
                   bf_bef_doc-line-sum.cost-discnt-rubl      = 0.
          end. /* if lookup( {&sum-before-doc}, p-sum-type-list ) <> 0 */
          if v_invclcsp = "yes" then do:
            if lookup( {&sum-before-cli-doc}, p-sum-type-list ) <> 0 then do:
              assign bf_bef-cli_doc-line-sum.fact-qnty             = 0
                     bf_bef-cli_doc-line-sum.sale-sum-base         = 0
                     bf_bef-cli_doc-line-sum.sale-sum-rubl         = 0
                     bf_bef-cli_doc-line-sum.sale-VAT-base         = 0
                     bf_bef-cli_doc-line-sum.sale-VAT-rubl         = 0
                     bf_bef-cli_doc-line-sum.sale-SLT-base         = 0
                     bf_bef-cli_doc-line-sum.sale-SLT-rubl         = 0
                     bf_bef-cli_doc-line-sum.sale-road-tax-base    = 0
                     bf_bef-cli_doc-line-sum.sale-road-tax-rubl    = 0
                     bf_bef-cli_doc-line-sum.sale-excise-base      = 0
                     bf_bef-cli_doc-line-sum.sale-excise-rubl      = 0
                     bf_bef-cli_doc-line-sum.sale-transport-base   = 0
                     bf_bef-cli_doc-line-sum.sale-transport-rubl   = 0
                     bf_bef-cli_doc-line-sum.sale-other-base       = 0
                     bf_bef-cli_doc-line-sum.sale-other-rubl       = 0
                     bf_bef-cli_doc-line-sum.sale-discnt-base      = 0
                     bf_bef-cli_doc-line-sum.sale-discnt-rubl      = 0
                     bf_bef-cli_doc-line-sum.crsa-sum-base         = 0
                     bf_bef-cli_doc-line-sum.crsa-sum-rubl         = 0
                     bf_bef-cli_doc-line-sum.crsa-VAT-base         = 0
                     bf_bef-cli_doc-line-sum.crsa-VAT-rubl         = 0
                     bf_bef-cli_doc-line-sum.crsa-SLT-base         = 0
                     bf_bef-cli_doc-line-sum.crsa-SLT-rubl         = 0
                     bf_bef-cli_doc-line-sum.crsa-road-tax-base    = 0
                     bf_bef-cli_doc-line-sum.crsa-road-tax-rubl    = 0
                     bf_bef-cli_doc-line-sum.crsa-excise-base      = 0
                     bf_bef-cli_doc-line-sum.crsa-excise-rubl      = 0
                     bf_bef-cli_doc-line-sum.crsa-transport-base   = 0
                     bf_bef-cli_doc-line-sum.crsa-transport-rubl   = 0
                     bf_bef-cli_doc-line-sum.crsa-other-base       = 0
                     bf_bef-cli_doc-line-sum.crsa-other-rubl       = 0
                     bf_bef-cli_doc-line-sum.crsa-discnt-base      = 0
                     bf_bef-cli_doc-line-sum.crsa-discnt-rubl      = 0
                     bf_bef-cli_doc-line-sum.cost-sum-base         = 0
                     bf_bef-cli_doc-line-sum.cost-sum-rubl         = 0
                     bf_bef-cli_doc-line-sum.cost-VAT-base         = 0
                     bf_bef-cli_doc-line-sum.cost-VAT-rubl         = 0
                     bf_bef-cli_doc-line-sum.cost-SLT-base         = 0
                     bf_bef-cli_doc-line-sum.cost-SLT-rubl         = 0
                     bf_bef-cli_doc-line-sum.cost-road-tax-base    = 0
                     bf_bef-cli_doc-line-sum.cost-road-tax-rubl    = 0
                     bf_bef-cli_doc-line-sum.cost-excise-base      = 0
                     bf_bef-cli_doc-line-sum.cost-excise-rubl      = 0
                     bf_bef-cli_doc-line-sum.cost-transport-base   = 0
                     bf_bef-cli_doc-line-sum.cost-transport-rubl   = 0
                     bf_bef-cli_doc-line-sum.cost-other-base       = 0
                     bf_bef-cli_doc-line-sum.cost-other-rubl       = 0
                     bf_bef-cli_doc-line-sum.cost-discnt-base      = 0
                     bf_bef-cli_doc-line-sum.cost-discnt-rubl      = 0.
            end. /* if lookup( {&sum-before-cli-doc}, p-sum-type-list ) <> 0 */
          end. /* if v_invclcsp = "yes" */
        end. /* if not available tt-clcparts */
      end. /* if available bf_gds-obj */
    end. /* if lookup( {&sum-before-doc}, p-sum-type-list ) <> 0 */

    /* Если по документу есть хотя бы одна партия, то считаются суммы по товару. Иначе основные суммы нулевые! */
    find first bf_parts no-lock where
               bf_parts.out-code  = p-doc-code           and
               bf_parts.obj-type  = bf_doc-line.obj-type  and
               bf_parts.obj-code  = bf_doc-line.obj-code  and
               bf_parts.artic     = bf_doc-line.artic     and
               bf_parts.prod-type = bf_doc-line.prod-type and
               bf_parts.prod-code = bf_doc-line.prod-code no-error.
    if available bf_parts then do:
      if lookup( {&sum-general-doc},     p-sum-type-list ) <> 0 or
         lookup( {&sum-general-cli-doc}, p-sum-type-list ) <> 0 then do:
        if lookup( {&sum-general-doc}, p-sum-type-list ) <> 0 then do:
          find first bf_gen_doc-line-sum exclusive-lock where
                     bf_gen_doc-line-sum.doc-code = p-doc-code        and
                     bf_gen_doc-line-sum.gds-code = bf_goods.gds-code  and
                     bf_gen_doc-line-sum.sum-type = {&sum-general-doc} no-error.
          if not available bf_gen_doc-line-sum then do:
            return error substitute( 'Не найдена запись сумм с типом "&1" по товару &2 &3 &4 из документа "&5".'
                                   , {&sum-general-doc}
                                   , bf_goods.artic
                                   , bf_goods.prod-type
                                   , bf_goods.prod-code
                                   , p-doc-code ).
          end.
        end.
        if v_invclcsp = "yes" then do:
          if lookup( {&sum-general-cli-doc}, p-sum-type-list ) <> 0 then do:
            find first bf_gen-cli_doc-line-sum exclusive-lock where
                       bf_gen-cli_doc-line-sum.doc-code = p-doc-code            and
                       bf_gen-cli_doc-line-sum.gds-code = bf_goods.gds-code      and
                       bf_gen-cli_doc-line-sum.sum-type = {&sum-general-cli-doc} no-error.
            if not available bf_gen-cli_doc-line-sum then do:
              return error substitute( 'Не найдена запись сумм с типом "&1" по товару &2 &3 &4 из документа "&5".'
                                     , {&sum-general-cli-doc}
                                     , bf_goods.artic
                                     , bf_goods.prod-type
                                     , bf_goods.prod-code
                                     , p-doc-code ).
            end.
          end.
        end.
        for each bf_tt-allsum-line :
          delete bf_tt-allsum-line.
        end.
        run clcprtsl_calc-line in this-procedure ( input recid( bf_doc-line ) ) no-error.
        if error-status :error then do:
          return error substitute(
            'Ошибка &1 &2 при вызове процедуры clcprtsl_calc-line для строки документа "&3" по товару &4 &5 &6.',
            return-value,
            error-status :get-message( 1 ),
            p-doc-code,
            bf_doc-line.artic,
            bf_doc-line.prod-type,
            bf_doc-line.prod-code ).
        end.

        find first bf_tt-allsum-line where
                   bf_tt-allsum-line.sum-type = {&sum-general} no-error.
        if not available bf_tt-allsum-line then do:
          return error substitute( 'Не найдена запись с типом суммы &1 после запуска clcprtsl_calc-line.',
                                   {&sum-general} ).
        end.
        if lookup( {&sum-general-doc}, p-sum-type-list ) <> 0 then do:
          assign bf_gen_doc-line-sum.fact-qnty             = bf_tt-allsum-line.fact-qnty
                 bf_gen_doc-line-sum.sale-sum-base         = bf_tt-allsum-line.sum-dsc-base-doc
                 bf_gen_doc-line-sum.sale-sum-rubl         = bf_tt-allsum-line.sum-dsc-rubl-doc
                 bf_gen_doc-line-sum.sale-VAT-base         = bf_tt-allsum-line.vat-base-doc
                 bf_gen_doc-line-sum.sale-VAT-rubl         = bf_tt-allsum-line.vat-rubl-doc
                 bf_gen_doc-line-sum.sale-SLT-base         = bf_tt-allsum-line.slt-base-doc
                 bf_gen_doc-line-sum.sale-SLT-rubl         = bf_tt-allsum-line.slt-rubl-doc
                 bf_gen_doc-line-sum.sale-road-tax-base    = bf_tt-allsum-line.road-tax-base-doc
                 bf_gen_doc-line-sum.sale-road-tax-rubl    = bf_tt-allsum-line.road-tax-rubl-doc
                 bf_gen_doc-line-sum.sale-excise-base      = bf_tt-allsum-line.excise-base-doc
                 bf_gen_doc-line-sum.sale-excise-rubl      = bf_tt-allsum-line.excise-rubl-doc
                 bf_gen_doc-line-sum.sale-transport-base   = 0
                 bf_gen_doc-line-sum.sale-transport-rubl   = 0
                 bf_gen_doc-line-sum.sale-other-base       = 0
                 bf_gen_doc-line-sum.sale-other-rubl       = 0
                 bf_gen_doc-line-sum.sale-discnt-base      = bf_tt-allsum-line.dsc-base-doc
                 bf_gen_doc-line-sum.sale-discnt-rubl      = bf_tt-allsum-line.dsc-rubl-doc
                 bf_gen_doc-line-sum.crsa-sum-base         = bf_tt-allsum-line.sum-dsc-base-cur
                 bf_gen_doc-line-sum.crsa-sum-rubl         = bf_tt-allsum-line.sum-dsc-rubl-cur
                 bf_gen_doc-line-sum.crsa-VAT-base         = bf_tt-allsum-line.vat-base-cur
                 bf_gen_doc-line-sum.crsa-VAT-rubl         = bf_tt-allsum-line.vat-rubl-cur
                 bf_gen_doc-line-sum.crsa-SLT-base         = bf_tt-allsum-line.slt-base-cur
                 bf_gen_doc-line-sum.crsa-SLT-rubl         = bf_tt-allsum-line.slt-rubl-cur
                 bf_gen_doc-line-sum.crsa-road-tax-base    = bf_tt-allsum-line.road-tax-base-cur
                 bf_gen_doc-line-sum.crsa-road-tax-rubl    = bf_tt-allsum-line.road-tax-rubl-cur
                 bf_gen_doc-line-sum.crsa-excise-base      = bf_tt-allsum-line.excise-base-cur
                 bf_gen_doc-line-sum.crsa-excise-rubl      = bf_tt-allsum-line.excise-rubl-cur
                 bf_gen_doc-line-sum.crsa-transport-base   = 0
                 bf_gen_doc-line-sum.crsa-transport-rubl   = 0
                 bf_gen_doc-line-sum.crsa-other-base       = 0
                 bf_gen_doc-line-sum.crsa-other-rubl       = 0
                 bf_gen_doc-line-sum.crsa-discnt-base      = bf_tt-allsum-line.dsc-base-cur
                 bf_gen_doc-line-sum.crsa-discnt-rubl      = bf_tt-allsum-line.dsc-rubl-cur
                 bf_gen_doc-line-sum.cost-sum-base         = bf_tt-allsum-line.sum-dsc-base-acc
                 bf_gen_doc-line-sum.cost-sum-rubl         = bf_tt-allsum-line.sum-dsc-rubl-acc
                 bf_gen_doc-line-sum.cost-VAT-base         = bf_tt-allsum-line.vat-base-acc
                 bf_gen_doc-line-sum.cost-VAT-rubl         = bf_tt-allsum-line.vat-rubl-acc
                 bf_gen_doc-line-sum.cost-SLT-base         = bf_tt-allsum-line.slt-base-acc
                 bf_gen_doc-line-sum.cost-SLT-rubl         = bf_tt-allsum-line.slt-rubl-acc
                 bf_gen_doc-line-sum.cost-road-tax-base    = bf_tt-allsum-line.road-tax-base-acc
                 bf_gen_doc-line-sum.cost-road-tax-rubl    = bf_tt-allsum-line.road-tax-rubl-acc
                 bf_gen_doc-line-sum.cost-excise-base      = bf_tt-allsum-line.excise-base-acc
                 bf_gen_doc-line-sum.cost-excise-rubl      = bf_tt-allsum-line.excise-rubl-acc
                 bf_gen_doc-line-sum.cost-transport-base   = bf_tt-allsum-line.transport-base-acc
                 bf_gen_doc-line-sum.cost-transport-rubl   = bf_tt-allsum-line.transport-rubl-acc
                 bf_gen_doc-line-sum.cost-other-base       = bf_tt-allsum-line.other-base-acc
                 bf_gen_doc-line-sum.cost-other-rubl       = bf_tt-allsum-line.other-rubl-acc
                 bf_gen_doc-line-sum.cost-discnt-base      = 0
                 bf_gen_doc-line-sum.cost-discnt-rubl      = 0.
        end.
        if v_invclcsp = "yes" then do:
          if lookup( {&sum-general-cli-doc}, p-sum-type-list ) <> 0 then do:
            assign bf_gen-cli_doc-line-sum.fact-qnty             = bf_tt-allsum-line.cli-qnty
                   bf_gen-cli_doc-line-sum.sale-sum-base         = bf_tt-allsum-line.sum-dsc-base-doc
                   bf_gen-cli_doc-line-sum.sale-sum-rubl         = bf_tt-allsum-line.sum-dsc-rubl-doc
                   bf_gen-cli_doc-line-sum.sale-VAT-base         = bf_tt-allsum-line.vat-base-doc
                   bf_gen-cli_doc-line-sum.sale-VAT-rubl         = bf_tt-allsum-line.vat-rubl-doc
                   bf_gen-cli_doc-line-sum.sale-SLT-base         = bf_tt-allsum-line.slt-base-doc
                   bf_gen-cli_doc-line-sum.sale-SLT-rubl         = bf_tt-allsum-line.slt-rubl-doc
                   bf_gen-cli_doc-line-sum.sale-road-tax-base    = bf_tt-allsum-line.road-tax-base-doc
                   bf_gen-cli_doc-line-sum.sale-road-tax-rubl    = bf_tt-allsum-line.road-tax-rubl-doc
                   bf_gen-cli_doc-line-sum.sale-excise-base      = bf_tt-allsum-line.excise-base-doc
                   bf_gen-cli_doc-line-sum.sale-excise-rubl      = bf_tt-allsum-line.excise-rubl-doc
                   bf_gen-cli_doc-line-sum.sale-transport-base   = 0
                   bf_gen-cli_doc-line-sum.sale-transport-rubl   = 0
                   bf_gen-cli_doc-line-sum.sale-other-base       = 0
                   bf_gen-cli_doc-line-sum.sale-other-rubl       = 0
                   bf_gen-cli_doc-line-sum.sale-discnt-base      = bf_tt-allsum-line.dsc-base-doc
                   bf_gen-cli_doc-line-sum.sale-discnt-rubl      = bf_tt-allsum-line.dsc-rubl-doc
                   bf_gen-cli_doc-line-sum.crsa-sum-base         = bf_tt-allsum-line.sum-dsc-base-cur
                   bf_gen-cli_doc-line-sum.crsa-sum-rubl         = bf_tt-allsum-line.sum-dsc-rubl-cur
                   bf_gen-cli_doc-line-sum.crsa-VAT-base         = bf_tt-allsum-line.vat-base-cur
                   bf_gen-cli_doc-line-sum.crsa-VAT-rubl         = bf_tt-allsum-line.vat-rubl-cur
                   bf_gen-cli_doc-line-sum.crsa-SLT-base         = bf_tt-allsum-line.slt-base-cur
                   bf_gen-cli_doc-line-sum.crsa-SLT-rubl         = bf_tt-allsum-line.slt-rubl-cur
                   bf_gen-cli_doc-line-sum.crsa-road-tax-base    = bf_tt-allsum-line.road-tax-base-cur
                   bf_gen-cli_doc-line-sum.crsa-road-tax-rubl    = bf_tt-allsum-line.road-tax-rubl-cur
                   bf_gen-cli_doc-line-sum.crsa-excise-base      = bf_tt-allsum-line.excise-base-cur
                   bf_gen-cli_doc-line-sum.crsa-excise-rubl      = bf_tt-allsum-line.excise-rubl-cur
                   bf_gen-cli_doc-line-sum.crsa-transport-base   = 0
                   bf_gen-cli_doc-line-sum.crsa-transport-rubl   = 0
                   bf_gen-cli_doc-line-sum.crsa-other-base       = 0
                   bf_gen-cli_doc-line-sum.crsa-other-rubl       = 0
                   bf_gen-cli_doc-line-sum.crsa-discnt-base      = bf_tt-allsum-line.dsc-base-cur
                   bf_gen-cli_doc-line-sum.crsa-discnt-rubl      = bf_tt-allsum-line.dsc-rubl-cur
                   bf_gen-cli_doc-line-sum.cost-sum-base         = bf_tt-allsum-line.sum-dsc-base-acc
                   bf_gen-cli_doc-line-sum.cost-sum-rubl         = bf_tt-allsum-line.sum-dsc-rubl-acc
                   bf_gen-cli_doc-line-sum.cost-VAT-base         = bf_tt-allsum-line.vat-base-acc
                   bf_gen-cli_doc-line-sum.cost-VAT-rubl         = bf_tt-allsum-line.vat-rubl-acc
                   bf_gen-cli_doc-line-sum.cost-SLT-base         = bf_tt-allsum-line.slt-base-acc
                   bf_gen-cli_doc-line-sum.cost-SLT-rubl         = bf_tt-allsum-line.slt-rubl-acc
                   bf_gen-cli_doc-line-sum.cost-road-tax-base    = bf_tt-allsum-line.road-tax-base-acc
                   bf_gen-cli_doc-line-sum.cost-road-tax-rubl    = bf_tt-allsum-line.road-tax-rubl-acc
                   bf_gen-cli_doc-line-sum.cost-excise-base      = bf_tt-allsum-line.excise-base-acc
                   bf_gen-cli_doc-line-sum.cost-excise-rubl      = bf_tt-allsum-line.excise-rubl-acc
                   bf_gen-cli_doc-line-sum.cost-transport-base   = bf_tt-allsum-line.transport-base-acc
                   bf_gen-cli_doc-line-sum.cost-transport-rubl   = bf_tt-allsum-line.transport-rubl-acc
                   bf_gen-cli_doc-line-sum.cost-other-base       = bf_tt-allsum-line.other-base-acc
                   bf_gen-cli_doc-line-sum.cost-other-rubl       = bf_tt-allsum-line.other-rubl-acc
                   bf_gen-cli_doc-line-sum.cost-discnt-base      = 0
                   bf_gen-cli_doc-line-sum.cost-discnt-rubl      = 0.
          end. /* if lookup( {&sum-general-cli-doc}, p-sum-type-list ) <> 0 */
        end. /* if v_invclcsp = "yes" */
      end. /* if lookup( {&sum-general-doc}, p-sum-type-list ) <> 0 */
    end. /* if available bf_parts */
    else do: /* if not available bf_parts */
      if lookup( {&sum-general-doc}, p-sum-type-list ) <> 0 then do:
        run lib-rwds_cllinsum in this-procedure ( input bf_doc-line.doc-code
                                                , input {&sum-general-doc}
                                                , input bf_doc-line.artic
                                                , input bf_doc-line.prod-type
                                                , input bf_doc-line.prod-code ) no-error.
      end.
      if v_invclcsp = "yes" then do:
        if lookup( {&sum-general-cli-doc}, p-sum-type-list ) <> 0 then do:
          run lib-rwds_cllinsum in this-procedure ( input bf_doc-line.doc-code
                                                  , input {&sum-general-doc}
                                                  , input bf_doc-line.artic
                                                  , input bf_doc-line.prod-type
                                                  , input bf_doc-line.prod-code ) no-error.
        end.
      end.
    end. /* if not available bf_parts */
    if lookup( {&sum-after-doc}, p-sum-type-list ) <> 0 then do:
      find first bf_bef_doc-line-sum exclusive-lock where
                 bf_bef_doc-line-sum.doc-code = p-doc-code       and
                 bf_bef_doc-line-sum.gds-code = bf_goods.gds-code and
                 bf_bef_doc-line-sum.sum-type = {&sum-before-doc} no-error.
      if not available bf_bef_doc-line-sum then do:
        return error substitute( 'Не найдена запись сумм с типом "&1" по товару &2 &3 &4 из документа "&5".'
                               , {&sum-before-doc}
                               , bf_goods.artic
                               , bf_goods.prod-type
                               , bf_goods.prod-code
                               , p-doc-code ).
      end.
      find first bf_gen_doc-line-sum exclusive-lock where
                 bf_gen_doc-line-sum.doc-code = p-doc-code        and
                 bf_gen_doc-line-sum.gds-code = bf_goods.gds-code  and
                 bf_gen_doc-line-sum.sum-type = {&sum-general-doc} no-error.
      if not available bf_gen_doc-line-sum then do:
        return error substitute( 'Не найдена запись сумм с типом "&1" по товару &2 &3 &4 из документа "&5".'
                               , {&sum-general-doc}
                               , bf_goods.artic
                               , bf_goods.prod-type
                               , bf_goods.prod-code
                               , p-doc-code ).
      end.
      find first bf_aft_doc-line-sum exclusive-lock where
                 bf_aft_doc-line-sum.doc-code = p-doc-code       and
                 bf_aft_doc-line-sum.gds-code = bf_goods.gds-code and
                 bf_aft_doc-line-sum.sum-type = {&sum-after-doc}  no-error.
      if not available bf_aft_doc-line-sum then do:
        return error substitute( 'Не найдена запись сумм с типом "&1" по товару &2 &3 &4 из документа "&5".'
                               , {&sum-after-doc}
                               , bf_goods.artic
                               , bf_goods.prod-type
                               , bf_goods.prod-code
                               , p-doc-code ).
      end.
      assign bf_aft_doc-line-sum.fact-qnty             = bf_bef_doc-line-sum.fact-qnty            +
                                                         bf_gen_doc-line-sum.fact-qnty
             bf_aft_doc-line-sum.sale-sum-base         = 0
             bf_aft_doc-line-sum.sale-sum-rubl         = 0
             bf_aft_doc-line-sum.sale-VAT-base         = 0
             bf_aft_doc-line-sum.sale-VAT-rubl         = 0
             bf_aft_doc-line-sum.sale-SLT-base         = 0
             bf_aft_doc-line-sum.sale-SLT-rubl         = 0
             bf_aft_doc-line-sum.sale-road-tax-base    = 0
             bf_aft_doc-line-sum.sale-road-tax-rubl    = 0
             bf_aft_doc-line-sum.sale-excise-base      = 0
             bf_aft_doc-line-sum.sale-excise-rubl      = 0
             bf_aft_doc-line-sum.sale-transport-base   = 0
             bf_aft_doc-line-sum.sale-transport-rubl   = 0
             bf_aft_doc-line-sum.sale-other-base       = 0
             bf_aft_doc-line-sum.sale-other-rubl       = 0
             bf_aft_doc-line-sum.sale-discnt-base      = 0
             bf_aft_doc-line-sum.sale-discnt-rubl      = 0
             bf_aft_doc-line-sum.crsa-sum-base         = bf_bef_doc-line-sum.crsa-sum-base        +
                                                         bf_gen_doc-line-sum.crsa-sum-base
             bf_aft_doc-line-sum.crsa-sum-rubl         = bf_bef_doc-line-sum.crsa-sum-rubl        +
                                                         bf_gen_doc-line-sum.crsa-sum-rubl
             bf_aft_doc-line-sum.crsa-VAT-base         = bf_bef_doc-line-sum.crsa-VAT-base        +
                                                         bf_gen_doc-line-sum.crsa-VAT-base
             bf_aft_doc-line-sum.crsa-VAT-rubl         = bf_bef_doc-line-sum.crsa-VAT-rubl        +
                                                         bf_gen_doc-line-sum.crsa-VAT-rubl
             bf_aft_doc-line-sum.crsa-SLT-base         = bf_bef_doc-line-sum.crsa-SLT-base        +
                                                         bf_gen_doc-line-sum.crsa-SLT-base
             bf_aft_doc-line-sum.crsa-SLT-rubl         = bf_bef_doc-line-sum.crsa-SLT-rubl        +
                                                         bf_gen_doc-line-sum.crsa-SLT-rubl
             bf_aft_doc-line-sum.crsa-road-tax-base    = bf_bef_doc-line-sum.crsa-road-tax-base   +
                                                         bf_gen_doc-line-sum.crsa-road-tax-base
             bf_aft_doc-line-sum.crsa-road-tax-rubl    = bf_bef_doc-line-sum.crsa-road-tax-rubl   +
                                                         bf_gen_doc-line-sum.crsa-road-tax-rubl
             bf_aft_doc-line-sum.crsa-excise-base      = bf_bef_doc-line-sum.crsa-excise-base     +
                                                         bf_gen_doc-line-sum.crsa-excise-base
             bf_aft_doc-line-sum.crsa-excise-rubl      = bf_bef_doc-line-sum.crsa-excise-rubl     +
                                                         bf_gen_doc-line-sum.crsa-excise-rubl
             bf_aft_doc-line-sum.crsa-transport-base   = bf_bef_doc-line-sum.crsa-transport-base  +
                                                         bf_gen_doc-line-sum.crsa-transport-base
             bf_aft_doc-line-sum.crsa-transport-rubl   = bf_bef_doc-line-sum.crsa-transport-rubl  +
                                                         bf_gen_doc-line-sum.crsa-transport-rubl
             bf_aft_doc-line-sum.crsa-other-base       = bf_bef_doc-line-sum.crsa-other-base      +
                                                         bf_gen_doc-line-sum.crsa-other-base
             bf_aft_doc-line-sum.crsa-other-rubl       = bf_bef_doc-line-sum.crsa-other-rubl      +
                                                         bf_gen_doc-line-sum.crsa-other-rubl
             bf_aft_doc-line-sum.crsa-discnt-base      = bf_bef_doc-line-sum.crsa-discnt-base     +
                                                         bf_gen_doc-line-sum.crsa-discnt-base
             bf_aft_doc-line-sum.crsa-discnt-rubl      = bf_bef_doc-line-sum.crsa-discnt-rubl     +
                                                         bf_gen_doc-line-sum.crsa-discnt-rubl
             bf_aft_doc-line-sum.cost-sum-base         = bf_bef_doc-line-sum.cost-sum-base        +
                                                         bf_gen_doc-line-sum.cost-sum-base
             bf_aft_doc-line-sum.cost-sum-rubl         = bf_bef_doc-line-sum.cost-sum-rubl        +
                                                         bf_gen_doc-line-sum.cost-sum-rubl
             bf_aft_doc-line-sum.cost-VAT-base         = bf_bef_doc-line-sum.cost-VAT-base        +
                                                         bf_gen_doc-line-sum.cost-VAT-base
             bf_aft_doc-line-sum.cost-VAT-rubl         = bf_bef_doc-line-sum.cost-VAT-rubl        +
                                                         bf_gen_doc-line-sum.cost-VAT-rubl
             bf_aft_doc-line-sum.cost-SLT-base         = bf_bef_doc-line-sum.cost-SLT-base        +
                                                         bf_gen_doc-line-sum.cost-SLT-base
             bf_aft_doc-line-sum.cost-SLT-rubl         = bf_bef_doc-line-sum.cost-SLT-rubl        +
                                                         bf_gen_doc-line-sum.cost-SLT-rubl
             bf_aft_doc-line-sum.cost-road-tax-base    = bf_bef_doc-line-sum.cost-road-tax-base   +
                                                         bf_gen_doc-line-sum.cost-road-tax-base
             bf_aft_doc-line-sum.cost-road-tax-rubl    = bf_bef_doc-line-sum.cost-road-tax-rubl   +
                                                         bf_gen_doc-line-sum.cost-road-tax-rubl
             bf_aft_doc-line-sum.cost-excise-base      = bf_bef_doc-line-sum.cost-excise-base     +
                                                         bf_gen_doc-line-sum.cost-excise-base
             bf_aft_doc-line-sum.cost-excise-rubl      = bf_bef_doc-line-sum.cost-excise-rubl     +
                                                         bf_gen_doc-line-sum.cost-excise-rubl
             bf_aft_doc-line-sum.cost-transport-base   = bf_bef_doc-line-sum.cost-transport-base  +
                                                         bf_gen_doc-line-sum.cost-transport-base
             bf_aft_doc-line-sum.cost-transport-rubl   = bf_bef_doc-line-sum.cost-transport-rubl  +
                                                         bf_gen_doc-line-sum.cost-transport-rubl
             bf_aft_doc-line-sum.cost-other-base       = bf_bef_doc-line-sum.cost-other-base      +
                                                         bf_gen_doc-line-sum.cost-other-base
             bf_aft_doc-line-sum.cost-other-rubl       = bf_bef_doc-line-sum.cost-other-rubl      +
                                                         bf_gen_doc-line-sum.cost-other-rubl
             bf_aft_doc-line-sum.cost-discnt-base      = bf_bef_doc-line-sum.cost-discnt-base     +
                                                         bf_gen_doc-line-sum.cost-discnt-base
             bf_aft_doc-line-sum.cost-discnt-rubl      = bf_bef_doc-line-sum.cost-discnt-rubl     +
                                                         bf_gen_doc-line-sum.cost-discnt-rubl     .
    end. /* if lookup( {&sum-after-doc}, p-sum-type-list ) <> 0 */
    if lookup( {&sum-after-cli-doc}, p-sum-type-list ) <> 0 then do:
      if v_invclcsp = "yes" then do:
        find first bf_bef-cli_doc-line-sum exclusive-lock where
                   bf_bef-cli_doc-line-sum.doc-code = p-doc-code           and
                   bf_bef-cli_doc-line-sum.gds-code = bf_goods.gds-code     and
                   bf_bef-cli_doc-line-sum.sum-type = {&sum-before-cli-doc} no-error.
        if not available bf_bef-cli_doc-line-sum then do:
          return error substitute( 'Не найдена запись сумм с типом "&1" по товару &2 &3 &4 из документа "&5".'
                                 , {&sum-before-cli-doc}
                                 , bf_goods.artic
                                 , bf_goods.prod-type
                                 , bf_goods.prod-code
                                 , p-doc-code ).
        end. /* if not available bf_bef-cli_doc-line-sum */
        find first bf_gen-cli_doc-line-sum exclusive-lock where
                   bf_gen-cli_doc-line-sum.doc-code = p-doc-code            and
                   bf_gen-cli_doc-line-sum.gds-code = bf_goods.gds-code      and
                   bf_gen-cli_doc-line-sum.sum-type = {&sum-general-cli-doc} no-error.
        if not available bf_gen-cli_doc-line-sum then do:
          return error substitute( 'Не найдена запись сумм с типом "&1" по товару &2 &3 &4 из документа "&5".'
                                 , {&sum-general-cli-doc}
                                 , bf_goods.artic
                                 , bf_goods.prod-type
                                 , bf_goods.prod-code
                                 , p-doc-code ).
        end. /* if not available bf_gen-cli_doc-line-sum */
        find first bf_aft-cli_doc-line-sum exclusive-lock where
                   bf_aft-cli_doc-line-sum.doc-code = p-doc-code          and
                   bf_aft-cli_doc-line-sum.gds-code = bf_goods.gds-code    and
                   bf_aft-cli_doc-line-sum.sum-type = {&sum-after-cli-doc} no-error.
        if not available bf_aft-cli_doc-line-sum then do:
          return error substitute( 'Не найдена запись сумм с типом "&1" по товару &2 &3 &4 из документа "&5".'
                                 , {&sum-after-cli-doc}
                                 , bf_goods.artic
                                 , bf_goods.prod-type
                                 , bf_goods.prod-code
                                 , p-doc-code ).
        end. /* if not available bf_aft-cli_doc-line-sum */
        assign bf_aft-cli_doc-line-sum.fact-qnty             = bf_bef-cli_doc-line-sum.fact-qnty            +
                                                               bf_gen-cli_doc-line-sum.fact-qnty
               bf_aft-cli_doc-line-sum.sale-sum-base         = 0
               bf_aft-cli_doc-line-sum.sale-sum-rubl         = 0
               bf_aft-cli_doc-line-sum.sale-VAT-base         = 0
               bf_aft-cli_doc-line-sum.sale-VAT-rubl         = 0
               bf_aft-cli_doc-line-sum.sale-SLT-base         = 0
               bf_aft-cli_doc-line-sum.sale-SLT-rubl         = 0
               bf_aft-cli_doc-line-sum.sale-road-tax-base    = 0
               bf_aft-cli_doc-line-sum.sale-road-tax-rubl    = 0
               bf_aft-cli_doc-line-sum.sale-excise-base      = 0
               bf_aft-cli_doc-line-sum.sale-excise-rubl      = 0
               bf_aft-cli_doc-line-sum.sale-transport-base   = 0
               bf_aft-cli_doc-line-sum.sale-transport-rubl   = 0
               bf_aft-cli_doc-line-sum.sale-other-base       = 0
               bf_aft-cli_doc-line-sum.sale-other-rubl       = 0
               bf_aft-cli_doc-line-sum.sale-discnt-base      = 0
               bf_aft-cli_doc-line-sum.sale-discnt-rubl      = 0
               bf_aft-cli_doc-line-sum.crsa-sum-base         = bf_bef-cli_doc-line-sum.crsa-sum-base        +
                                                               bf_gen-cli_doc-line-sum.crsa-sum-base
               bf_aft-cli_doc-line-sum.crsa-sum-rubl         = bf_bef-cli_doc-line-sum.crsa-sum-rubl        +
                                                               bf_gen-cli_doc-line-sum.crsa-sum-rubl
               bf_aft-cli_doc-line-sum.crsa-VAT-base         = bf_bef-cli_doc-line-sum.crsa-VAT-base        +
                                                               bf_gen-cli_doc-line-sum.crsa-VAT-base
               bf_aft-cli_doc-line-sum.crsa-VAT-rubl         = bf_bef-cli_doc-line-sum.crsa-VAT-rubl        +
                                                               bf_gen-cli_doc-line-sum.crsa-VAT-rubl
               bf_aft-cli_doc-line-sum.crsa-SLT-base         = bf_bef-cli_doc-line-sum.crsa-SLT-base        +
                                                               bf_gen-cli_doc-line-sum.crsa-SLT-base
               bf_aft-cli_doc-line-sum.crsa-SLT-rubl         = bf_bef-cli_doc-line-sum.crsa-SLT-rubl        +
                                                               bf_gen-cli_doc-line-sum.crsa-SLT-rubl
               bf_aft-cli_doc-line-sum.crsa-road-tax-base    = bf_bef-cli_doc-line-sum.crsa-road-tax-base   +
                                                               bf_gen-cli_doc-line-sum.crsa-road-tax-base
               bf_aft-cli_doc-line-sum.crsa-road-tax-rubl    = bf_bef-cli_doc-line-sum.crsa-road-tax-rubl   +
                                                               bf_gen-cli_doc-line-sum.crsa-road-tax-rubl
               bf_aft-cli_doc-line-sum.crsa-excise-base      = bf_bef-cli_doc-line-sum.crsa-excise-base     +
                                                               bf_gen-cli_doc-line-sum.crsa-excise-base
               bf_aft-cli_doc-line-sum.crsa-excise-rubl      = bf_bef-cli_doc-line-sum.crsa-excise-rubl     +
                                                               bf_gen-cli_doc-line-sum.crsa-excise-rubl
               bf_aft-cli_doc-line-sum.crsa-transport-base   = bf_bef-cli_doc-line-sum.crsa-transport-base  +
                                                               bf_gen-cli_doc-line-sum.crsa-transport-base
               bf_aft-cli_doc-line-sum.crsa-transport-rubl   = bf_bef-cli_doc-line-sum.crsa-transport-rubl  +
                                                               bf_gen-cli_doc-line-sum.crsa-transport-rubl
               bf_aft-cli_doc-line-sum.crsa-other-base       = bf_bef-cli_doc-line-sum.crsa-other-base      +
                                                               bf_gen-cli_doc-line-sum.crsa-other-base
               bf_aft-cli_doc-line-sum.crsa-other-rubl       = bf_bef-cli_doc-line-sum.crsa-other-rubl      +
                                                               bf_gen-cli_doc-line-sum.crsa-other-rubl
               bf_aft-cli_doc-line-sum.crsa-discnt-base      = bf_bef-cli_doc-line-sum.crsa-discnt-base     +
                                                               bf_gen-cli_doc-line-sum.crsa-discnt-base
               bf_aft-cli_doc-line-sum.crsa-discnt-rubl      = bf_bef-cli_doc-line-sum.crsa-discnt-rubl     +
                                                               bf_gen-cli_doc-line-sum.crsa-discnt-rubl
               bf_aft-cli_doc-line-sum.cost-sum-base         = bf_bef-cli_doc-line-sum.cost-sum-base        +
                                                               bf_gen-cli_doc-line-sum.cost-sum-base
               bf_aft-cli_doc-line-sum.cost-sum-rubl         = bf_bef-cli_doc-line-sum.cost-sum-rubl        +
                                                               bf_gen-cli_doc-line-sum.cost-sum-rubl
               bf_aft-cli_doc-line-sum.cost-VAT-base         = bf_bef-cli_doc-line-sum.cost-VAT-base        +
                                                               bf_gen-cli_doc-line-sum.cost-VAT-base
               bf_aft-cli_doc-line-sum.cost-VAT-rubl         = bf_bef-cli_doc-line-sum.cost-VAT-rubl        +
                                                               bf_gen-cli_doc-line-sum.cost-VAT-rubl
               bf_aft-cli_doc-line-sum.cost-SLT-base         = bf_bef-cli_doc-line-sum.cost-SLT-base        +
                                                               bf_gen-cli_doc-line-sum.cost-SLT-base
               bf_aft-cli_doc-line-sum.cost-SLT-rubl         = bf_bef-cli_doc-line-sum.cost-SLT-rubl        +
                                                               bf_gen-cli_doc-line-sum.cost-SLT-rubl
               bf_aft-cli_doc-line-sum.cost-road-tax-base    = bf_bef-cli_doc-line-sum.cost-road-tax-base   +
                                                               bf_gen-cli_doc-line-sum.cost-road-tax-base
               bf_aft-cli_doc-line-sum.cost-road-tax-rubl    = bf_bef-cli_doc-line-sum.cost-road-tax-rubl   +
                                                               bf_gen-cli_doc-line-sum.cost-road-tax-rubl
               bf_aft-cli_doc-line-sum.cost-excise-base      = bf_bef-cli_doc-line-sum.cost-excise-base     +
                                                               bf_gen-cli_doc-line-sum.cost-excise-base
               bf_aft-cli_doc-line-sum.cost-excise-rubl      = bf_bef-cli_doc-line-sum.cost-excise-rubl     +
                                                               bf_gen-cli_doc-line-sum.cost-excise-rubl
               bf_aft-cli_doc-line-sum.cost-transport-base   = bf_bef-cli_doc-line-sum.cost-transport-base  +
                                                               bf_gen-cli_doc-line-sum.cost-transport-base
               bf_aft-cli_doc-line-sum.cost-transport-rubl   = bf_bef-cli_doc-line-sum.cost-transport-rubl  +
                                                               bf_gen-cli_doc-line-sum.cost-transport-rubl
               bf_aft-cli_doc-line-sum.cost-other-base       = bf_bef-cli_doc-line-sum.cost-other-base      +
                                                               bf_gen-cli_doc-line-sum.cost-other-base
               bf_aft-cli_doc-line-sum.cost-other-rubl       = bf_bef-cli_doc-line-sum.cost-other-rubl      +
                                                               bf_gen-cli_doc-line-sum.cost-other-rubl
               bf_aft-cli_doc-line-sum.cost-discnt-base      = bf_bef-cli_doc-line-sum.cost-discnt-base     +
                                                               bf_gen-cli_doc-line-sum.cost-discnt-base
               bf_aft-cli_doc-line-sum.cost-discnt-rubl      = bf_bef-cli_doc-line-sum.cost-discnt-rubl     +
                                                               bf_gen-cli_doc-line-sum.cost-discnt-rubl     .
      end. /* if v_invclcsp = "yes" */
    end. /* if lookup( {&sum-after-cli-doc}, p-sum-type-list ) <> 0 */
    for each tt-doc-line-sum :
      delete tt-doc-line-sum.
    end.
    for each bf_doc-line-sum where
             bf_doc-line-sum.doc-code = p-doc-code       and
             bf_doc-line-sum.gds-code = bf_goods.gds-code
    on error undo, return error return-value :
      create tt-doc-line-sum.
      buffer-copy bf_doc-line-sum to tt-doc-line-sum.
    end. /* for each bf_doc-line-sum */
  end. /* on error */
end procedure. /* lib-rwds_cctrnsum */

/* Удаление временной таблицы */
procedure lib-rwds_ttdlsdel :
  define input        parameter           p-doc-code      like ub.trn-doc.doc-code   no-undo.
  define input        parameter           p-artic         like ub.doc-line.artic     no-undo.
  define input        parameter           p-prod-type     like ub.doc-line.prod-type no-undo.
  define input        parameter           p-prod-code     like ub.doc-line.prod-code no-undo.
  define input-output parameter table for tt-doc-line-sum.
  define buffer bf_goods           for ub.goods.
  define buffer bf_tt-doc-line-sum for tt-doc-line-sum.

  do on error undo, return error return-value :
    find first bf_goods no-lock where
               bf_goods.artic     = p-artic     and
               bf_goods.prod-type = p-prod-type and
               bf_goods.prod-code = p-prod-code no-error.
    if not available bf_goods then do:
      return error substitute( 'lib-rwds_ttdlsdel. Не найден товар &1 &2 &3.', p-artic, p-prod-type, p-prod-code ).
    end.
    for each bf_tt-doc-line-sum where
             bf_tt-doc-line-sum.doc-code = p-doc-code       and
             bf_tt-doc-line-sum.gds-code = bf_goods.gds-code
    on error undo, return error return-value :
      delete bf_tt-doc-line-sum.
    end. /* for each bf_tt-doc-line-sum */
  end. /* on error */
end procedure. /* lib-rwds_ttdlsdel */

procedure lib-rwds_ccwstsum :
  define input        parameter           p-doc-code   like trn-doc.doc-code no-undo.
  define input        parameter           p-wasthandle as   handle           no-undo.
  define input-output parameter table for tt-wast-line.
  define buffer wast-cur-trn-doc    for ub.trn-doc.
  define buffer wast-trn-doc        for ub.trn-doc.
  define buffer wast-doc-line       for ub.doc-line.
  define buffer wast-exp-doc        for ub.trn-doc.
  define buffer wast-exp-line       for ub.doc-line.
  define buffer wast-exp-gds-dtl    for ub.gds-dtl.
  define buffer wast-goods          for ub.goods.
  define buffer wast-cur-doc-line   for ub.doc-line.
  define buffer bf_doc-line-sum     for ub.doc-line-sum.
  define buffer bf_cli_doc-line-sum for ub.doc-line-sum.
  define buffer bf_trn-doc-sum      for ub.trn-doc-sum.
  define buffer bf_cli_trn-doc-sum  for ub.trn-doc-sum.
  define buffer wast-cur-inv-doc    for ub.trn-doc.
  define buffer bf_goods            for ub.goods.
  define buffer buf_sale-doc        for ub.sale-doc.

  define variable varwast-sum-sale-base      like ub.doc-line.price-base no-undo.
  define variable varwast-sum-sale-rubl      like ub.doc-line.price-base no-undo.
  define variable varwast-sum-sale-base-line like ub.doc-line.price-base no-undo.
  define variable varwast-sum-sale-rubl-line like ub.doc-line.price-base no-undo.
  define variable varwast-sum-base-line      like ub.doc-line.price-base no-undo.
  define variable varwast-sum-rubl-line      like ub.doc-line.price-base no-undo.
  define variable varwast-fact-qnty-line     like ub.doc-line.fact-qnty  no-undo.
  define variable varwast-cli-qnty-line      like ub.doc-line.cli-qnty   no-undo.
  define variable v_invclcsp              as character no-undo.
  define variable v_data-type             as character no-undo.
  define variable v-is-petrol             as logical   no-undo.
  define variable v-is-pieces             as logical   no-undo.
  define variable NormWast                as class ibs.th.ref.normwastsub no-undo.
  define variable v-normal-wastage        as decimal   no-undo.
  define variable attr-type               as character no-undo.
  define variable v-petrol                as logical   no-undo.
  define variable v-value                 as character no-undo.
  define variable v-type                  as character no-undo.
  define variable v-sign                  as integer   no-undo.

  do on error undo, return error return-value :
    run waitfram-show in p-wasthandle ( input 'Подсчет фондов естественной убыли по товарам в инвентаризации.' ) no-error.
    if not valid-handle( p-wasthandle ) then do:
      assign p-wasthandle = this-procedure :handle.
    end.

    for each tt-wast-line:
      delete tt-wast-line.
    end.
    find first wast-cur-trn-doc where
               wast-cur-trn-doc.doc-code = p-doc-code no-error.
    if not available wast-cur-trn-doc then do:
      return error substitute( 'Не найден документ с номером "&1".', p-doc-code).
    end.

    { gbl/getsect.i run wast-cur-trn-doc.obj-type wast-cur-trn-doc.obj-code {&attr-inv-obj} }
    for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = 'invclcsp'  then v_invclcsp = string( thbjattr_thbj-attr.property-value-logical, "yes/no").
    end.
    empty temp-table thbjattr_thbj-attr.
    find first wast-cur-inv-doc exclusive-lock where
               wast-cur-inv-doc.doc-code = p-doc-code.
    for  each wast-cur-doc-line where
              wast-cur-doc-line.doc-code = p-doc-code
      , first bf_goods  no-lock where
              bf_goods.artic     = wast-cur-doc-line.artic     and
              bf_goods.prod-type = wast-cur-doc-line.prod-type and
              bf_goods.prod-code = wast-cur-doc-line.prod-code
    on error undo, return error return-value :

      { str/is-petrl.i
          bf_goods.artic
          bf_goods.prod-type
          bf_goods.prod-code
          v-is-petrol
          v-is-pieces
      }
      if  v-is-petrol = yes
      and v-is-pieces = no
      then do :
        run gds-attr-value in this-procedure (
                                         input bf_goods.gds-code
                                        ,input {&attr-ptrl-as-good}
                                        ,output v-value
                                        ,output v-type) no-error.
        assign v-petrol = if logical(v-value) then no else yes .
      end.
      if v-petrol then do:
        
        NormWast = new ibs.th.ref.normwastsub ().
        NormWast:ParGdsOAttr:GdsCode = bf_goods.gds-code.
        NormWast:ParGdsOAttr:ObjType = wast-cur-trn-doc.obj-type.
        NormWast:ParGdsOAttr:ObjCode = wast-cur-trn-doc.obj-code.
        NormWast:ParGdsOAttr:OnDate = if wast-cur-trn-doc.fact-date <> ? then wast-cur-trn-doc.fact-date else wast-cur-trn-doc.doc-date.
        
        
      /* у топлива в атрибутах, т.к. до 3-х знаков после запятой */
        run gds-o-normal-wastage-value in this-procedure
                          ( input-output NormWast
                          ) no-error.
        v-normal-wastage = NormWast:NormalWastageDate.
      end.
      else do:
        assign v-normal-wastage = if bf_goods.normal-wastage <> 0 and bf_goods.normal-wastage <> ? then bf_goods.normal-wastage  else 0 .
      end.
      if v-normal-wastage <> 0 and
         v-normal-wastage <> ? then do:
        create tt-wast-line.
        buffer-copy wast-cur-doc-line to tt-wast-line.
      end.
    end. /* for  each wast-cur-doc-line */
    if can-find( first tt-wast-line ) then do:
      /* Ищем последнюю инвентаризацию по каждому товару */
      for each wast-trn-doc no-lock where
               wast-trn-doc.obj-type     = wast-cur-inv-doc.obj-type and
               wast-trn-doc.obj-code     = wast-cur-inv-doc.obj-code and
               wast-trn-doc.status_      = {&fact}                   and
               wast-trn-doc.doc-type     = {&inventory}              and
               wast-trn-doc.internal     = no                        and
               wast-trn-doc.ext-doc-type = {&TDEDT_Inv}              use-index stat-fact
            by wast-trn-doc.fact-order descending
      on error undo, return error return-value :
        if wast-cur-inv-doc.fact-order <> 0 then do:
          if wast-trn-doc.fact-order >= wast-cur-inv-doc.fact-order then do: next. end.
        end.
        for  each tt-wast-line  no-lock where
                  tt-wast-line.prev-inv-fact-order = 0 use-index prev-inv-fact-order
          , first wast-doc-line no-lock where
                  wast-doc-line.doc-code  = wast-trn-doc.doc-code  and
                  wast-doc-line.artic     = tt-wast-line.artic     and
                  wast-doc-line.prod-type = tt-wast-line.prod-type and
                  wast-doc-line.prod-code = tt-wast-line.prod-code
        on error undo, return error return-value :
          assign tt-wast-line.prev-inv-fact-order = wast-doc-line.fact-order.
        end. /* for each tt-wast-line */
        if not can-find( first tt-wast-line where tt-wast-line.prev-inv-fact-order = 0 ) then do: leave. end.
      end. /* for each wast-trn-doc */

      for  each tt-wast-line
        , first wast-goods   no-lock where
                wast-goods.artic     = tt-wast-line.artic     and
                wast-goods.prod-type = tt-wast-line.prod-type and
                wast-goods.prod-code = tt-wast-line.prod-code
      on error undo, return error return-value :
        run waitfram-show in p-wasthandle ( input substitute( 'Подсчет фонда естественной убыли по товару &1 &2 &3.'
                                                            , tt-wast-line.artic
                                                            , tt-wast-line.prod-type
                                                            , tt-wast-line.prod-code ) ) no-error.
      { str/is-petrl.i
          tt-wast-line.artic
          tt-wast-line.prod-type
          tt-wast-line.prod-code
          v-is-petrol
          v-is-pieces
      }
      if  v-is-petrol = yes
      and v-is-pieces = no
      then do :
        run gds-attr-value in this-procedure (
                                         input bf_goods.gds-code
                                        ,input {&attr-ptrl-as-good}
                                        ,output v-value
                                        ,output v-type) no-error.
        assign v-petrol = if logical(v-value) then no else yes .
      end.
      else do:
        assign v-petrol = no .
      end.
      if v-petrol then do:
      /* у топлива в атрибутах, т.к. до 3-х знаков после запятой */
      
        NormWast = new ibs.th.ref.normwastsub ().
        NormWast:ParGdsOAttr:GdsCode = bf_goods.gds-code.
        NormWast:ParGdsOAttr:ObjType = wast-cur-trn-doc.obj-type.
        NormWast:ParGdsOAttr:ObjCode = wast-cur-trn-doc.obj-code.
        NormWast:ParGdsOAttr:OnDate = if wast-cur-trn-doc.fact-date <> ? then wast-cur-trn-doc.fact-date else wast-cur-trn-doc.doc-date.
      
        run gds-o-normal-wastage-value in this-procedure
                          ( input-output NormWast
                          ) no-error.
        v-normal-wastage = NormWast:NormalWastageDate.
        
      end.
      else do:
        assign
          v-normal-wastage = if wast-goods.normal-wastage <> 0 and wast-goods.normal-wastage <> ? then wast-goods.normal-wastage  else 0
        .
      end.
        if tt-wast-line.prev-inv-fact-order = 0 then do:
          if tt-wast-line.fact-order = 0 then do:
            { str/ccl-w.i 0 0 v-petrol }
          end.
          else do:
            { str/ccl-w.i 0 tt-wast-line.fact-order v-petrol }
          end.
        end.
        else do:
          if tt-wast-line.fact-order = 0 then do:
            { str/ccl-w.i tt-wast-line.prev-inv-fact-order 0 v-petrol }
          end.
          else do:
            { str/ccl-w.i tt-wast-line.prev-inv-fact-order tt-wast-line.fact-order v-petrol }
          end.
        end.
        find first bf_doc-line-sum where
                   bf_doc-line-sum.doc-code = wast-cur-inv-doc.doc-code and
                   bf_doc-line-sum.gds-code = wast-goods.gds-code       and
                   bf_doc-line-sum.sum-type = {&sum-wastage-doc}.
        if v_invclcsp = "yes" then do:
          find first bf_cli_doc-line-sum where
                     bf_cli_doc-line-sum.doc-code = wast-cur-inv-doc.doc-code and
                     bf_cli_doc-line-sum.gds-code = wast-goods.gds-code       and
                     bf_cli_doc-line-sum.sum-type = {&sum-wastage-cli-doc}.
        end.
        assign bf_doc-line-sum.fact-qnty           = varwast-fact-qnty-line     * v-normal-wastage * (if v-petrol then 0.001 else 0.01)
               bf_doc-line-sum.sale-sum-base       = varwast-sum-sale-base-line * v-normal-wastage * (if v-petrol then 0.001 else 0.01)
               bf_doc-line-sum.sale-sum-rubl       = varwast-sum-sale-rubl-line * v-normal-wastage * (if v-petrol then 0.001 else 0.01)
               bf_doc-line-sum.sale-VAT-base       = 0
               bf_doc-line-sum.sale-VAT-rubl       = 0
               bf_doc-line-sum.sale-SLT-base       = 0
               bf_doc-line-sum.sale-SLT-rubl       = 0
               bf_doc-line-sum.sale-road-tax-base  = 0
               bf_doc-line-sum.sale-road-tax-rubl  = 0
               bf_doc-line-sum.sale-excise-base    = 0
               bf_doc-line-sum.sale-excise-rubl    = 0
               bf_doc-line-sum.sale-transport-base = 0
               bf_doc-line-sum.sale-transport-rubl = 0
               bf_doc-line-sum.sale-other-base     = 0
               bf_doc-line-sum.sale-other-rubl     = 0
               bf_doc-line-sum.sale-discnt-base    = 0
               bf_doc-line-sum.sale-discnt-rubl    = 0
               bf_doc-line-sum.crsa-sum-base       = 0
               bf_doc-line-sum.crsa-sum-rubl       = 0
               bf_doc-line-sum.crsa-VAT-base       = 0
               bf_doc-line-sum.crsa-VAT-rubl       = 0
               bf_doc-line-sum.crsa-SLT-base       = 0
               bf_doc-line-sum.crsa-SLT-rubl       = 0
               bf_doc-line-sum.crsa-road-tax-base  = 0
               bf_doc-line-sum.crsa-road-tax-rubl  = 0
               bf_doc-line-sum.crsa-excise-base    = 0
               bf_doc-line-sum.crsa-excise-rubl    = 0
               bf_doc-line-sum.crsa-transport-base = 0
               bf_doc-line-sum.crsa-transport-rubl = 0
               bf_doc-line-sum.crsa-other-base     = 0
               bf_doc-line-sum.crsa-other-rubl     = 0
               bf_doc-line-sum.crsa-discnt-base    = 0
               bf_doc-line-sum.crsa-discnt-rubl    = 0
               bf_doc-line-sum.cost-sum-base       = varwast-sum-base-line      * v-normal-wastage * (if v-petrol then 0.001 else 0.01)
               bf_doc-line-sum.cost-sum-rubl       = varwast-sum-rubl-line      * v-normal-wastage * (if v-petrol then 0.001 else 0.01)
               bf_doc-line-sum.cost-VAT-base       = 0
               bf_doc-line-sum.cost-VAT-rubl       = 0
               bf_doc-line-sum.cost-SLT-base       = 0
               bf_doc-line-sum.cost-SLT-rubl       = 0
               bf_doc-line-sum.cost-road-tax-base  = 0
               bf_doc-line-sum.cost-road-tax-rubl  = 0
               bf_doc-line-sum.cost-excise-base    = 0
               bf_doc-line-sum.cost-excise-rubl    = 0
               bf_doc-line-sum.cost-transport-base = 0
               bf_doc-line-sum.cost-transport-rubl = 0
               bf_doc-line-sum.cost-other-base     = 0
               bf_doc-line-sum.cost-other-rubl     = 0
               bf_doc-line-sum.cost-discnt-base    = 0
               bf_doc-line-sum.cost-discnt-rubl    = 0.
        if v_invclcsp = "yes" then do:
          assign bf_cli_doc-line-sum.fact-qnty           = varwast-cli-qnty-line      * v-normal-wastage * (if v-petrol then 0.001 else 0.01)
                 bf_cli_doc-line-sum.sale-sum-base       = varwast-sum-sale-base-line * v-normal-wastage * (if v-petrol then 0.001 else 0.01)
                 bf_cli_doc-line-sum.sale-sum-rubl       = varwast-sum-sale-rubl-line * v-normal-wastage * (if v-petrol then 0.001 else 0.01)
                 bf_cli_doc-line-sum.sale-VAT-base       = 0
                 bf_cli_doc-line-sum.sale-VAT-rubl       = 0
                 bf_cli_doc-line-sum.sale-SLT-base       = 0
                 bf_cli_doc-line-sum.sale-SLT-rubl       = 0
                 bf_cli_doc-line-sum.sale-road-tax-base  = 0
                 bf_cli_doc-line-sum.sale-road-tax-rubl  = 0
                 bf_cli_doc-line-sum.sale-excise-base    = 0
                 bf_cli_doc-line-sum.sale-excise-rubl    = 0
                 bf_cli_doc-line-sum.sale-transport-base = 0
                 bf_cli_doc-line-sum.sale-transport-rubl = 0
                 bf_cli_doc-line-sum.sale-other-base     = 0
                 bf_cli_doc-line-sum.sale-other-rubl     = 0
                 bf_cli_doc-line-sum.sale-discnt-base    = 0
                 bf_cli_doc-line-sum.sale-discnt-rubl    = 0
                 bf_cli_doc-line-sum.crsa-sum-base       = 0
                 bf_cli_doc-line-sum.crsa-sum-rubl       = 0
                 bf_cli_doc-line-sum.crsa-VAT-base       = 0
                 bf_cli_doc-line-sum.crsa-VAT-rubl       = 0
                 bf_cli_doc-line-sum.crsa-SLT-base       = 0
                 bf_cli_doc-line-sum.crsa-SLT-rubl       = 0
                 bf_cli_doc-line-sum.crsa-road-tax-base  = 0
                 bf_cli_doc-line-sum.crsa-road-tax-rubl  = 0
                 bf_cli_doc-line-sum.crsa-excise-base    = 0
                 bf_cli_doc-line-sum.crsa-excise-rubl    = 0
                 bf_cli_doc-line-sum.crsa-transport-base = 0
                 bf_cli_doc-line-sum.crsa-transport-rubl = 0
                 bf_cli_doc-line-sum.crsa-other-base     = 0
                 bf_cli_doc-line-sum.crsa-other-rubl     = 0
                 bf_cli_doc-line-sum.crsa-discnt-base    = 0
                 bf_cli_doc-line-sum.crsa-discnt-rubl    = 0
                 bf_cli_doc-line-sum.cost-sum-base       = varwast-sum-base-line      * v-normal-wastage * (if v-petrol then 0.001 else 0.01)
                 bf_cli_doc-line-sum.cost-sum-rubl       = varwast-sum-rubl-line      * v-normal-wastage * (if v-petrol then 0.001 else 0.01)
                 bf_cli_doc-line-sum.cost-VAT-base       = 0
                 bf_cli_doc-line-sum.cost-VAT-rubl       = 0
                 bf_cli_doc-line-sum.cost-SLT-base       = 0
                 bf_cli_doc-line-sum.cost-SLT-rubl       = 0
                 bf_cli_doc-line-sum.cost-road-tax-base  = 0
                 bf_cli_doc-line-sum.cost-road-tax-rubl  = 0
                 bf_cli_doc-line-sum.cost-excise-base    = 0
                 bf_cli_doc-line-sum.cost-excise-rubl    = 0
                 bf_cli_doc-line-sum.cost-transport-base = 0
                 bf_cli_doc-line-sum.cost-transport-rubl = 0
                 bf_cli_doc-line-sum.cost-other-base     = 0
                 bf_cli_doc-line-sum.cost-other-rubl     = 0
                 bf_cli_doc-line-sum.cost-discnt-base    = 0
                 bf_cli_doc-line-sum.cost-discnt-rubl    = 0.
        end. /* if v_invclcsp = "yes" */
      end. /* for each tt-wast-line */
    end. /* if can-find( first tt-wast-line ) */
    run waitfram-hide in p-wasthandle no-error.
  end. /* on error */
end procedure. /* lib-rwds_ccwstsum */

procedure lib-rwds_updtrsum :
  define input        parameter           p-doc-code         like ub.trn-doc.doc-code   no-undo.
  define input        parameter           p-artic            like ub.doc-line.artic     no-undo.
  define input        parameter           p-prod-type        like ub.doc-line.prod-type no-undo.
  define input        parameter           p-prod-code        like ub.doc-line.prod-code no-undo.
  define input        parameter           p-mode             as   character             no-undo.
  define input-output parameter table for tt-allsum-line.
  define input-output parameter table for tt-doc-line-sum.
  define input-output parameter table for tt-old-doc-line-sum.
  define buffer bf_gen_trn-doc-sum             for ub.trn-doc-sum.
  define buffer bf_aft_trn-doc-sum             for ub.trn-doc-sum.
  define buffer bf_ext_trn-doc-sum             for ub.trn-doc-sum.
  define buffer bf_mis_trn-doc-sum             for ub.trn-doc-sum.
  define buffer bf_gen-cli_trn-doc-sum         for ub.trn-doc-sum.
  define buffer bf_aft-cli_trn-doc-sum         for ub.trn-doc-sum.
  define buffer bf_ext-cli_trn-doc-sum         for ub.trn-doc-sum.
  define buffer bf_mis-cli_trn-doc-sum         for ub.trn-doc-sum.
  define buffer bf_gen_tt-doc-line-sum         for tt-doc-line-sum.
  define buffer bf_aft_tt-doc-line-sum         for tt-doc-line-sum.
  define buffer bf_gen-cli_tt-doc-line-sum     for tt-doc-line-sum.
  define buffer bf_aft-cli_tt-doc-line-sum     for tt-doc-line-sum.
  define buffer bf_gen_tt-old-doc-line-sum     for tt-old-doc-line-sum.
  define buffer bf_aft_tt-old-doc-line-sum     for tt-old-doc-line-sum.
  define buffer bf_gen-cli_tt-old-doc-line-sum for tt-old-doc-line-sum.
  define buffer bf_aft-cli_tt-old-doc-line-sum for tt-old-doc-line-sum.
  define buffer bf_goods                       for ub.goods.
  define buffer bf_doc-line                    for ub.doc-line.
  define buffer bf_trn-doc                     for ub.trn-doc.

  define variable v_invclcsp  as character no-undo.
  define variable v_data-type as character no-undo.

  do on error undo, return error return-value :
    find first bf_trn-doc where
               bf_trn-doc.doc-code = p-doc-code.
    if not available bf_trn-doc then do:
      return error substitute( 'lib-rwds_updtrsum. Не найден документ "&1".', p-doc-code ).
    end.

    { gbl/getsect.i run bf_trn-doc.obj-type bf_trn-doc.obj-code {&attr-inv-obj} }
    for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = 'invclcsp'  then v_invclcsp = string( thbjattr_thbj-attr.property-value-logical, "yes/no").
    end.
     empty temp-table thbjattr_thbj-attr.
    find first bf_doc-line where
               bf_doc-line.doc-code  = p-doc-code  and
               bf_doc-line.artic     = p-artic     and
               bf_doc-line.prod-type = p-prod-type and
               bf_doc-line.prod-code = p-prod-code no-error.
    find first bf_goods no-lock where
               bf_goods.artic     = bf_doc-line.artic     and
               bf_goods.prod-type = bf_doc-line.prod-type and
               bf_goods.prod-code = bf_doc-line.prod-code.
    find first bf_gen_trn-doc-sum exclusive-lock where
               bf_gen_trn-doc-sum.doc-code = bf_doc-line.doc-code and
               bf_gen_trn-doc-sum.sum-type = {&sum-general-doc}   no-error.
    if not available bf_gen_trn-doc-sum then do:
      return error substitute( 'Ошибка при поиске суммы типа "&1" по документу "&2".'
                             , {&sum-general-doc}
                             , bf_doc-line.doc-code ).
    end.
    find first bf_ext_trn-doc-sum exclusive-lock where
               bf_ext_trn-doc-sum.doc-code = bf_doc-line.doc-code and
               bf_ext_trn-doc-sum.sum-type = {&sum-extra-doc}     no-error.
    if not available bf_ext_trn-doc-sum then do:
      return error substitute( 'Ошибка при поиске суммы типа "&1" по документу "&2".'
                             , {&sum-extra-doc}
                             , bf_doc-line.doc-code ).
    end.
    find first bf_mis_trn-doc-sum exclusive-lock where
               bf_mis_trn-doc-sum.doc-code = bf_doc-line.doc-code and
               bf_mis_trn-doc-sum.sum-type = {&sum-miss-doc}      no-error.
    if not available bf_mis_trn-doc-sum then do:
      return error substitute( 'Ошибка при поиске суммы типа "&1" по документу "&2".'
                             , {&sum-miss-doc}
                             , bf_doc-line.doc-code ).
    end.
    if v_invclcsp = "yes" then do:
      find first bf_gen-cli_trn-doc-sum exclusive-lock where
                 bf_gen-cli_trn-doc-sum.doc-code = bf_doc-line.doc-code   and
                 bf_gen-cli_trn-doc-sum.sum-type = {&sum-general-cli-doc} no-error.
      if not available bf_gen-cli_trn-doc-sum then do:
        return error substitute( 'Ошибка при поиске суммы типа "&1" по документу "&2".'
                               , {&sum-general-cli-doc}
                               , bf_doc-line.doc-code ).
      end.
      find first bf_ext-cli_trn-doc-sum exclusive-lock where
                 bf_ext-cli_trn-doc-sum.doc-code = bf_doc-line.doc-code and
                 bf_ext-cli_trn-doc-sum.sum-type = {&sum-extra-cli-doc} no-error.
      if not available bf_ext-cli_trn-doc-sum then do:
        return error substitute( 'Ошибка при поиске суммы типа "&1" по документу "&2".'
                               , {&sum-extra-cli-doc}
                               , bf_doc-line.doc-code ).
      end.
      find first bf_mis-cli_trn-doc-sum exclusive-lock where
                 bf_mis-cli_trn-doc-sum.doc-code = bf_doc-line.doc-code and
                 bf_mis-cli_trn-doc-sum.sum-type = {&sum-miss-cli-doc}  no-error.
      if not available bf_mis-cli_trn-doc-sum then do:
        return error substitute( 'Ошибка при поиске суммы типа "&1" по документу "&2".'
                               , {&sum-miss-cli-doc}
                               , bf_doc-line.doc-code ).
      end.
    end.
    find first bf_gen_tt-old-doc-line-sum where
               bf_gen_tt-old-doc-line-sum.doc-code = bf_doc-line.doc-code and
               bf_gen_tt-old-doc-line-sum.gds-code = bf_goods.gds-code    and
               bf_gen_tt-old-doc-line-sum.sum-type = {&sum-general-doc}   no-error.
    if not available bf_gen_tt-old-doc-line-sum then do:
      return error substitute( 'Не найдена запись по временной таблице старых сумм по типу "&1" для товара &2 &3 &4 ' +
                               'по документу "&5".'
                             , {&sum-general-doc}
                             , bf_goods.artic
                             , bf_goods.prod-type
                             , bf_goods.prod-code
                             , bf_doc-line.doc-code ).
    end.
    if v_invclcsp = "yes" then do:
      find first bf_gen-cli_tt-old-doc-line-sum where
                 bf_gen-cli_tt-old-doc-line-sum.doc-code = bf_doc-line.doc-code   and
                 bf_gen-cli_tt-old-doc-line-sum.gds-code = bf_goods.gds-code      and
                 bf_gen-cli_tt-old-doc-line-sum.sum-type = {&sum-general-cli-doc} no-error.
      if not available bf_gen-cli_tt-old-doc-line-sum then do:
        return error substitute( 'Не найдена запись по временной таблице старых сумм по типу "&1" для товара &2 &3 &4 ' +
                                 'по документу "&5".'
                               , {&sum-general-cli-doc}
                               , bf_goods.artic
                               , bf_goods.prod-type
                               , bf_goods.prod-code
                               , bf_doc-line.doc-code ).
      end.
    end.

    if p-mode = "update":U then do:
      find first bf_gen_tt-doc-line-sum where
                 bf_gen_tt-doc-line-sum.doc-code = bf_doc-line.doc-code and
                 bf_gen_tt-doc-line-sum.gds-code = bf_goods.gds-code    and
                 bf_gen_tt-doc-line-sum.sum-type = {&sum-general-doc}   no-error.
      if not available bf_gen_tt-doc-line-sum then do:
        return error substitute( 'Не найдена запись по временной таблице новых сумм по типу "&1" для товара &2 &3 &4 ' +
                                 'по документу "&5".'
                               , {&sum-general-doc}
                               , bf_goods.artic
                               , bf_goods.prod-type
                               , bf_goods.prod-code
                               , bf_doc-line.doc-code ).
      end.
      if v_invclcsp = "yes" then do:
        find first bf_gen-cli_tt-doc-line-sum where
                   bf_gen-cli_tt-doc-line-sum.doc-code = bf_doc-line.doc-code   and
                   bf_gen-cli_tt-doc-line-sum.gds-code = bf_goods.gds-code      and
                   bf_gen-cli_tt-doc-line-sum.sum-type = {&sum-general-cli-doc} no-error.
        if not available bf_gen-cli_tt-doc-line-sum then do:
          return error substitute( 'Не найдена запись по временной таблице новых сумм по типу "&1" для товара &2 &3 &4 ' +
                                   'по документу "&5".'
                                 , {&sum-general-cli-doc}
                                 , bf_goods.artic
                                 , bf_goods.prod-type
                                 , bf_goods.prod-code
                                 , bf_doc-line.doc-code ).
        end.
      end. /* if v_invclcsp = "yes" */
    end. /* if p-mode = "update" */
    assign bf_gen_trn-doc-sum.fact-qnty           = bf_gen_trn-doc-sum.fact-qnty           +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.fact-qnty           else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.fact-qnty
           bf_gen_trn-doc-sum.sale-sum-base       = bf_gen_trn-doc-sum.sale-sum-base       +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.sale-sum-base       else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.sale-sum-base
           bf_gen_trn-doc-sum.sale-sum-rubl       = bf_gen_trn-doc-sum.sale-sum-rubl       +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.sale-sum-rubl       else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.sale-sum-rubl
           bf_gen_trn-doc-sum.sale-VAT-base       = bf_gen_trn-doc-sum.sale-VAT-base       +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.sale-VAT-base       else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.sale-VAT-base
           bf_gen_trn-doc-sum.sale-VAT-rubl       = bf_gen_trn-doc-sum.sale-VAT-rubl       +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.sale-VAT-rubl       else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.sale-VAT-rubl
           bf_gen_trn-doc-sum.sale-SLT-base       = bf_gen_trn-doc-sum.sale-SLT-base       +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.sale-SLT-base       else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.sale-SLT-base
           bf_gen_trn-doc-sum.sale-SLT-rubl       = bf_gen_trn-doc-sum.sale-SLT-rubl       +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.sale-SLT-rubl       else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.sale-SLT-rubl
           bf_gen_trn-doc-sum.sale-road-tax-base  = bf_gen_trn-doc-sum.sale-road-tax-base  +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.sale-road-tax-base  else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.sale-road-tax-base
           bf_gen_trn-doc-sum.sale-road-tax-rubl  = bf_gen_trn-doc-sum.sale-road-tax-rubl  +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.sale-road-tax-rubl  else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.sale-road-tax-rubl
           bf_gen_trn-doc-sum.sale-excise-base    = bf_gen_trn-doc-sum.sale-excise-base    +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.sale-excise-base    else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.sale-excise-base
           bf_gen_trn-doc-sum.sale-excise-rubl    = bf_gen_trn-doc-sum.sale-excise-rubl    +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.sale-excise-rubl    else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.sale-excise-rubl
           bf_gen_trn-doc-sum.sale-transport-base = bf_gen_trn-doc-sum.sale-transport-base +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.sale-transport-base else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.sale-transport-base
           bf_gen_trn-doc-sum.sale-transport-rubl = bf_gen_trn-doc-sum.sale-transport-rubl +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.sale-transport-rubl else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.sale-transport-rubl
           bf_gen_trn-doc-sum.sale-other-base     = bf_gen_trn-doc-sum.sale-other-base     +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.sale-other-base     else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.sale-other-base
           bf_gen_trn-doc-sum.sale-other-rubl     = bf_gen_trn-doc-sum.sale-other-rubl     +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.sale-other-rubl     else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.sale-other-rubl
           bf_gen_trn-doc-sum.sale-discnt-base    = bf_gen_trn-doc-sum.sale-discnt-base    +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.sale-discnt-base    else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.sale-discnt-base
           bf_gen_trn-doc-sum.sale-discnt-rubl    = bf_gen_trn-doc-sum.sale-discnt-rubl    +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.sale-discnt-rubl    else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.sale-discnt-rubl
    .
    if p-mode = "update":U then do:
      if bf_gen_tt-doc-line-sum.fact-qnty > 0 then do:
        assign bf_ext_trn-doc-sum.fact-qnty = bf_ext_trn-doc-sum.fact-qnty + bf_gen_tt-doc-line-sum.fact-qnty.
      end.
      else do:
        assign bf_mis_trn-doc-sum.fact-qnty = bf_mis_trn-doc-sum.fact-qnty - bf_gen_tt-doc-line-sum.fact-qnty.
      end.
    end.
    if bf_gen_tt-old-doc-line-sum.fact-qnty > 0 then do:
      assign bf_ext_trn-doc-sum.fact-qnty = bf_ext_trn-doc-sum.fact-qnty - bf_gen_tt-old-doc-line-sum.fact-qnty.
    end.
    else do:
      assign bf_mis_trn-doc-sum.fact-qnty = bf_mis_trn-doc-sum.fact-qnty + bf_gen_tt-old-doc-line-sum.fact-qnty.
    end.

    if p-mode = "update":U then do:
      if bf_gen_tt-doc-line-sum.sale-sum-rubl > 0 then do:
        assign bf_ext_trn-doc-sum.sale-sum-base       = bf_ext_trn-doc-sum.sale-sum-base           +
                                                        bf_gen_tt-doc-line-sum.sale-sum-base
               bf_ext_trn-doc-sum.sale-sum-rubl       = bf_ext_trn-doc-sum.sale-sum-rubl           +
                                                        bf_gen_tt-doc-line-sum.sale-sum-rubl
               bf_ext_trn-doc-sum.sale-VAT-base       = bf_ext_trn-doc-sum.sale-VAT-base           +
                                                        bf_gen_tt-doc-line-sum.sale-VAT-base
               bf_ext_trn-doc-sum.sale-VAT-rubl       = bf_ext_trn-doc-sum.sale-VAT-rubl           +
                                                        bf_gen_tt-doc-line-sum.sale-VAT-rubl
               bf_ext_trn-doc-sum.sale-SLT-base       = bf_ext_trn-doc-sum.sale-SLT-base           +
                                                        bf_gen_tt-doc-line-sum.sale-SLT-base
               bf_ext_trn-doc-sum.sale-SLT-rubl       = bf_ext_trn-doc-sum.sale-SLT-rubl           +
                                                        bf_gen_tt-doc-line-sum.sale-SLT-rubl
               bf_ext_trn-doc-sum.sale-road-tax-base  = bf_ext_trn-doc-sum.sale-road-tax-base      +
                                                        bf_gen_tt-doc-line-sum.sale-road-tax-base
               bf_ext_trn-doc-sum.sale-road-tax-rubl  = bf_ext_trn-doc-sum.sale-road-tax-rubl      +
                                                        bf_gen_tt-doc-line-sum.sale-road-tax-rubl
               bf_ext_trn-doc-sum.sale-excise-base    = bf_ext_trn-doc-sum.sale-excise-base        +
                                                        bf_gen_tt-doc-line-sum.sale-excise-base
               bf_ext_trn-doc-sum.sale-excise-rubl    = bf_ext_trn-doc-sum.sale-excise-rubl        +
                                                        bf_gen_tt-doc-line-sum.sale-excise-rubl
               bf_ext_trn-doc-sum.sale-transport-base = bf_ext_trn-doc-sum.sale-transport-base     +
                                                        bf_gen_tt-doc-line-sum.sale-transport-base
               bf_ext_trn-doc-sum.sale-transport-rubl = bf_ext_trn-doc-sum.sale-transport-rubl     +
                                                        bf_gen_tt-doc-line-sum.sale-transport-rubl
               bf_ext_trn-doc-sum.sale-other-base     = bf_ext_trn-doc-sum.sale-other-base         +
                                                        bf_gen_tt-doc-line-sum.sale-other-base
               bf_ext_trn-doc-sum.sale-other-rubl     = bf_ext_trn-doc-sum.sale-other-rubl         +
                                                        bf_gen_tt-doc-line-sum.sale-other-rubl
               bf_ext_trn-doc-sum.sale-discnt-base    = bf_ext_trn-doc-sum.sale-discnt-base        +
                                                        bf_gen_tt-doc-line-sum.sale-discnt-base
               bf_ext_trn-doc-sum.sale-discnt-rubl    = bf_ext_trn-doc-sum.sale-discnt-rubl        +
                                                        bf_gen_tt-doc-line-sum.sale-discnt-rubl
        .
      end.
      else do:
        assign bf_mis_trn-doc-sum.sale-sum-base       = bf_mis_trn-doc-sum.sale-sum-base           -
                                                        bf_gen_tt-doc-line-sum.sale-sum-base
               bf_mis_trn-doc-sum.sale-sum-rubl       = bf_mis_trn-doc-sum.sale-sum-rubl           -
                                                        bf_gen_tt-doc-line-sum.sale-sum-rubl
               bf_mis_trn-doc-sum.sale-VAT-base       = bf_mis_trn-doc-sum.sale-VAT-base           -
                                                        bf_gen_tt-doc-line-sum.sale-VAT-base
               bf_mis_trn-doc-sum.sale-VAT-rubl       = bf_mis_trn-doc-sum.sale-VAT-rubl           -
                                                        bf_gen_tt-doc-line-sum.sale-VAT-rubl
               bf_mis_trn-doc-sum.sale-SLT-base       = bf_mis_trn-doc-sum.sale-SLT-base           -
                                                        bf_gen_tt-doc-line-sum.sale-SLT-base
               bf_mis_trn-doc-sum.sale-SLT-rubl       = bf_mis_trn-doc-sum.sale-SLT-rubl           -
                                                        bf_gen_tt-doc-line-sum.sale-SLT-rubl
               bf_mis_trn-doc-sum.sale-road-tax-base  = bf_mis_trn-doc-sum.sale-road-tax-base      -
                                                        bf_gen_tt-doc-line-sum.sale-road-tax-base
               bf_mis_trn-doc-sum.sale-road-tax-rubl  = bf_mis_trn-doc-sum.sale-road-tax-rubl      -
                                                        bf_gen_tt-doc-line-sum.sale-road-tax-rubl
               bf_mis_trn-doc-sum.sale-excise-base    = bf_mis_trn-doc-sum.sale-excise-base        -
                                                        bf_gen_tt-doc-line-sum.sale-excise-base
               bf_mis_trn-doc-sum.sale-excise-rubl    = bf_mis_trn-doc-sum.sale-excise-rubl        -
                                                        bf_gen_tt-doc-line-sum.sale-excise-rubl
               bf_mis_trn-doc-sum.sale-transport-base = bf_mis_trn-doc-sum.sale-transport-base     -
                                                        bf_gen_tt-doc-line-sum.sale-transport-base
               bf_mis_trn-doc-sum.sale-transport-rubl = bf_mis_trn-doc-sum.sale-transport-rubl     -
                                                        bf_gen_tt-doc-line-sum.sale-transport-rubl
               bf_mis_trn-doc-sum.sale-other-base     = bf_mis_trn-doc-sum.sale-other-base         -
                                                        bf_gen_tt-doc-line-sum.sale-other-base
               bf_mis_trn-doc-sum.sale-other-rubl     = bf_mis_trn-doc-sum.sale-other-rubl         -
                                                        bf_gen_tt-doc-line-sum.sale-other-rubl
               bf_mis_trn-doc-sum.sale-discnt-base    = bf_mis_trn-doc-sum.sale-discnt-base        -
                                                        bf_gen_tt-doc-line-sum.sale-discnt-base
               bf_mis_trn-doc-sum.sale-discnt-rubl    = bf_mis_trn-doc-sum.sale-discnt-rubl        -
                                                        bf_gen_tt-doc-line-sum.sale-discnt-rubl
        .
      end.
    end. /* if p-mode = "update" */

    if bf_gen_tt-old-doc-line-sum.sale-sum-rubl > 0 then do:
      assign bf_ext_trn-doc-sum.sale-sum-base       = bf_ext_trn-doc-sum.sale-sum-base               -
                                                      bf_gen_tt-old-doc-line-sum.sale-sum-base
             bf_ext_trn-doc-sum.sale-sum-rubl       = bf_ext_trn-doc-sum.sale-sum-rubl               -
                                                      bf_gen_tt-old-doc-line-sum.sale-sum-rubl
             bf_ext_trn-doc-sum.sale-VAT-base       = bf_ext_trn-doc-sum.sale-VAT-base               -
                                                      bf_gen_tt-old-doc-line-sum.sale-VAT-base
             bf_ext_trn-doc-sum.sale-VAT-rubl       = bf_ext_trn-doc-sum.sale-VAT-rubl               -
                                                      bf_gen_tt-old-doc-line-sum.sale-VAT-rubl
             bf_ext_trn-doc-sum.sale-SLT-base       = bf_ext_trn-doc-sum.sale-SLT-base               -
                                                      bf_gen_tt-old-doc-line-sum.sale-SLT-base
             bf_ext_trn-doc-sum.sale-SLT-rubl       = bf_ext_trn-doc-sum.sale-SLT-rubl               -
                                                      bf_gen_tt-old-doc-line-sum.sale-SLT-rubl
             bf_ext_trn-doc-sum.sale-road-tax-base  = bf_ext_trn-doc-sum.sale-road-tax-base          -
                                                      bf_gen_tt-old-doc-line-sum.sale-road-tax-base
             bf_ext_trn-doc-sum.sale-road-tax-rubl  = bf_ext_trn-doc-sum.sale-road-tax-rubl          -
                                                      bf_gen_tt-old-doc-line-sum.sale-road-tax-rubl
             bf_ext_trn-doc-sum.sale-excise-base    = bf_ext_trn-doc-sum.sale-excise-base            -
                                                      bf_gen_tt-old-doc-line-sum.sale-excise-base
             bf_ext_trn-doc-sum.sale-excise-rubl    = bf_ext_trn-doc-sum.sale-excise-rubl            -
                                                      bf_gen_tt-old-doc-line-sum.sale-excise-rubl
             bf_ext_trn-doc-sum.sale-transport-base = bf_ext_trn-doc-sum.sale-transport-base         -
                                                      bf_gen_tt-old-doc-line-sum.sale-transport-base
             bf_ext_trn-doc-sum.sale-transport-rubl = bf_ext_trn-doc-sum.sale-transport-rubl         -
                                                      bf_gen_tt-old-doc-line-sum.sale-transport-rubl
             bf_ext_trn-doc-sum.sale-other-base     = bf_ext_trn-doc-sum.sale-other-base             -
                                                      bf_gen_tt-old-doc-line-sum.sale-other-base
             bf_ext_trn-doc-sum.sale-other-rubl     = bf_ext_trn-doc-sum.sale-other-rubl             -
                                                      bf_gen_tt-old-doc-line-sum.sale-other-rubl
             bf_ext_trn-doc-sum.sale-discnt-base    = bf_ext_trn-doc-sum.sale-discnt-base            -
                                                      bf_gen_tt-old-doc-line-sum.sale-discnt-base
             bf_ext_trn-doc-sum.sale-discnt-rubl    = bf_ext_trn-doc-sum.sale-discnt-rubl            -
                                                      bf_gen_tt-old-doc-line-sum.sale-discnt-rubl
      .
    end.
    else do:
      assign bf_mis_trn-doc-sum.sale-sum-base       = bf_mis_trn-doc-sum.sale-sum-base               +
                                                      bf_gen_tt-old-doc-line-sum.sale-sum-base
             bf_mis_trn-doc-sum.sale-sum-rubl       = bf_mis_trn-doc-sum.sale-sum-rubl               +
                                                      bf_gen_tt-old-doc-line-sum.sale-sum-rubl
             bf_mis_trn-doc-sum.sale-VAT-base       = bf_mis_trn-doc-sum.sale-VAT-base               +
                                                      bf_gen_tt-old-doc-line-sum.sale-VAT-base
             bf_mis_trn-doc-sum.sale-VAT-rubl       = bf_mis_trn-doc-sum.sale-VAT-rubl               +
                                                      bf_gen_tt-old-doc-line-sum.sale-VAT-rubl
             bf_mis_trn-doc-sum.sale-SLT-base       = bf_mis_trn-doc-sum.sale-SLT-base               +
                                                      bf_gen_tt-old-doc-line-sum.sale-SLT-base
             bf_mis_trn-doc-sum.sale-SLT-rubl       = bf_mis_trn-doc-sum.sale-SLT-rubl               +
                                                      bf_gen_tt-old-doc-line-sum.sale-SLT-rubl
             bf_mis_trn-doc-sum.sale-road-tax-base  = bf_mis_trn-doc-sum.sale-road-tax-base          +
                                                      bf_gen_tt-old-doc-line-sum.sale-road-tax-base
             bf_mis_trn-doc-sum.sale-road-tax-rubl  = bf_mis_trn-doc-sum.sale-road-tax-rubl          +
                                                      bf_gen_tt-old-doc-line-sum.sale-road-tax-rubl
             bf_mis_trn-doc-sum.sale-excise-base    = bf_mis_trn-doc-sum.sale-excise-base            +
                                                      bf_gen_tt-old-doc-line-sum.sale-excise-base
             bf_mis_trn-doc-sum.sale-excise-rubl    = bf_mis_trn-doc-sum.sale-excise-rubl            +
                                                      bf_gen_tt-old-doc-line-sum.sale-excise-rubl
             bf_mis_trn-doc-sum.sale-transport-base = bf_mis_trn-doc-sum.sale-transport-base         +
                                                      bf_gen_tt-old-doc-line-sum.sale-transport-base
             bf_mis_trn-doc-sum.sale-transport-rubl = bf_mis_trn-doc-sum.sale-transport-rubl         +
                                                      bf_gen_tt-old-doc-line-sum.sale-transport-rubl
             bf_mis_trn-doc-sum.sale-other-base     = bf_mis_trn-doc-sum.sale-other-base             +
                                                      bf_gen_tt-old-doc-line-sum.sale-other-base
             bf_mis_trn-doc-sum.sale-other-rubl     = bf_mis_trn-doc-sum.sale-other-rubl             +
                                                      bf_gen_tt-old-doc-line-sum.sale-other-rubl
             bf_mis_trn-doc-sum.sale-discnt-base    = bf_mis_trn-doc-sum.sale-discnt-base            +
                                                      bf_gen_tt-old-doc-line-sum.sale-discnt-base
             bf_mis_trn-doc-sum.sale-discnt-rubl    = bf_mis_trn-doc-sum.sale-discnt-rubl            +
                                                      bf_gen_tt-old-doc-line-sum.sale-discnt-rubl
      .
    end.

    assign bf_gen_trn-doc-sum.crsa-sum-base       = bf_gen_trn-doc-sum.crsa-sum-base                        +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.crsa-sum-base           else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.crsa-sum-base
           bf_gen_trn-doc-sum.crsa-sum-rubl       = bf_gen_trn-doc-sum.crsa-sum-rubl                        +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.crsa-sum-rubl           else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.crsa-sum-rubl
           bf_gen_trn-doc-sum.crsa-VAT-base       = bf_gen_trn-doc-sum.crsa-VAT-base                       +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.crsa-VAT-base           else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.crsa-VAT-base
           bf_gen_trn-doc-sum.crsa-VAT-rubl       = bf_gen_trn-doc-sum.crsa-VAT-rubl                        +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.crsa-VAT-rubl           else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.crsa-VAT-rubl
           bf_gen_trn-doc-sum.crsa-SLT-base       = bf_gen_trn-doc-sum.crsa-SLT-base                        +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.crsa-SLT-base           else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.crsa-SLT-base
           bf_gen_trn-doc-sum.crsa-SLT-rubl       = bf_gen_trn-doc-sum.crsa-SLT-rubl                        +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.crsa-SLT-rubl           else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.crsa-SLT-rubl
           bf_gen_trn-doc-sum.crsa-road-tax-base  = bf_gen_trn-doc-sum.crsa-road-tax-base                   +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.crsa-road-tax-base      else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.crsa-road-tax-base
           bf_gen_trn-doc-sum.crsa-road-tax-rubl  = bf_gen_trn-doc-sum.crsa-road-tax-rubl                   +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.crsa-road-tax-rubl      else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.crsa-road-tax-rubl
           bf_gen_trn-doc-sum.crsa-excise-base    = bf_gen_trn-doc-sum.crsa-excise-base                     +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.crsa-excise-base        else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.crsa-excise-base
           bf_gen_trn-doc-sum.crsa-excise-rubl    = bf_gen_trn-doc-sum.crsa-excise-rubl                     +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.crsa-excise-rubl        else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.crsa-excise-rubl
           bf_gen_trn-doc-sum.crsa-transport-base = bf_gen_trn-doc-sum.crsa-transport-base                  +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.crsa-transport-base     else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.crsa-transport-base
           bf_gen_trn-doc-sum.crsa-transport-rubl = bf_gen_trn-doc-sum.crsa-transport-rubl                  +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.crsa-transport-rubl     else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.crsa-transport-rubl
           bf_gen_trn-doc-sum.crsa-other-base     = bf_gen_trn-doc-sum.crsa-other-base                  +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.crsa-other-base         else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.crsa-other-base
           bf_gen_trn-doc-sum.crsa-other-rubl     = bf_gen_trn-doc-sum.crsa-other-rubl                      +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.crsa-other-rubl         else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.crsa-other-rubl
           bf_gen_trn-doc-sum.crsa-discnt-base    = bf_gen_trn-doc-sum.crsa-discnt-base                     +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.crsa-discnt-base        else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.crsa-discnt-base
           bf_gen_trn-doc-sum.crsa-discnt-rubl    = bf_gen_trn-doc-sum.crsa-discnt-rubl                     +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.crsa-discnt-rubl        else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.crsa-discnt-rubl
    .
    if p-mode = "update":U then do:
      if bf_gen_tt-doc-line-sum.crsa-sum-rubl > 0 then do:
        assign bf_ext_trn-doc-sum.crsa-sum-base       = bf_ext_trn-doc-sum.crsa-sum-base           +
                                                        bf_gen_tt-doc-line-sum.crsa-sum-base
               bf_ext_trn-doc-sum.crsa-sum-rubl       = bf_ext_trn-doc-sum.crsa-sum-rubl           +
                                                        bf_gen_tt-doc-line-sum.crsa-sum-rubl
               bf_ext_trn-doc-sum.crsa-VAT-base       = bf_ext_trn-doc-sum.crsa-VAT-base           +
                                                        bf_gen_tt-doc-line-sum.crsa-VAT-base
               bf_ext_trn-doc-sum.crsa-VAT-rubl       = bf_ext_trn-doc-sum.crsa-VAT-rubl           +
                                                        bf_gen_tt-doc-line-sum.crsa-VAT-rubl
               bf_ext_trn-doc-sum.crsa-SLT-base       = bf_ext_trn-doc-sum.crsa-SLT-base           +
                                                        bf_gen_tt-doc-line-sum.crsa-SLT-base
               bf_ext_trn-doc-sum.crsa-SLT-rubl       = bf_ext_trn-doc-sum.crsa-SLT-rubl           +
                                                        bf_gen_tt-doc-line-sum.crsa-SLT-rubl
               bf_ext_trn-doc-sum.crsa-road-tax-base  = bf_ext_trn-doc-sum.crsa-road-tax-base      +
                                                        bf_gen_tt-doc-line-sum.crsa-road-tax-base
               bf_ext_trn-doc-sum.crsa-road-tax-rubl  = bf_ext_trn-doc-sum.crsa-road-tax-rubl      +
                                                        bf_gen_tt-doc-line-sum.crsa-road-tax-rubl
               bf_ext_trn-doc-sum.crsa-excise-base    = bf_ext_trn-doc-sum.crsa-excise-base        +
                                                        bf_gen_tt-doc-line-sum.crsa-excise-base
               bf_ext_trn-doc-sum.crsa-excise-rubl    = bf_ext_trn-doc-sum.crsa-excise-rubl        +
                                                        bf_gen_tt-doc-line-sum.crsa-excise-rubl
               bf_ext_trn-doc-sum.crsa-transport-base = bf_ext_trn-doc-sum.crsa-transport-base     +
                                                        bf_gen_tt-doc-line-sum.crsa-transport-base
               bf_ext_trn-doc-sum.crsa-transport-rubl = bf_ext_trn-doc-sum.crsa-transport-rubl     +
                                                        bf_gen_tt-doc-line-sum.crsa-transport-rubl
               bf_ext_trn-doc-sum.crsa-other-base     = bf_ext_trn-doc-sum.crsa-other-base         +
                                                        bf_gen_tt-doc-line-sum.crsa-other-base
               bf_ext_trn-doc-sum.crsa-other-rubl     = bf_ext_trn-doc-sum.crsa-other-rubl         +
                                                        bf_gen_tt-doc-line-sum.crsa-other-rubl
               bf_ext_trn-doc-sum.crsa-discnt-base    = bf_ext_trn-doc-sum.crsa-discnt-base        +
                                                        bf_gen_tt-doc-line-sum.crsa-discnt-base
               bf_ext_trn-doc-sum.crsa-discnt-rubl    = bf_ext_trn-doc-sum.crsa-discnt-rubl        +
                                                        bf_gen_tt-doc-line-sum.crsa-discnt-rubl
        .
      end.
      else do:
        assign bf_mis_trn-doc-sum.crsa-sum-base       = bf_mis_trn-doc-sum.crsa-sum-base           -
                                                        bf_gen_tt-doc-line-sum.crsa-sum-base
               bf_mis_trn-doc-sum.crsa-sum-rubl       = bf_mis_trn-doc-sum.crsa-sum-rubl           -
                                                        bf_gen_tt-doc-line-sum.crsa-sum-rubl
               bf_mis_trn-doc-sum.crsa-VAT-base       = bf_mis_trn-doc-sum.crsa-VAT-base           -
                                                        bf_gen_tt-doc-line-sum.crsa-VAT-base
               bf_mis_trn-doc-sum.crsa-VAT-rubl       = bf_mis_trn-doc-sum.crsa-VAT-rubl           -
                                                        bf_gen_tt-doc-line-sum.crsa-VAT-rubl
               bf_mis_trn-doc-sum.crsa-SLT-base       = bf_mis_trn-doc-sum.crsa-SLT-base           -
                                                        bf_gen_tt-doc-line-sum.crsa-SLT-base
               bf_mis_trn-doc-sum.crsa-SLT-rubl       = bf_mis_trn-doc-sum.crsa-SLT-rubl           -
                                                        bf_gen_tt-doc-line-sum.crsa-SLT-rubl
               bf_mis_trn-doc-sum.crsa-road-tax-base  = bf_mis_trn-doc-sum.crsa-road-tax-base      -
                                                        bf_gen_tt-doc-line-sum.crsa-road-tax-base
               bf_mis_trn-doc-sum.crsa-road-tax-rubl  = bf_mis_trn-doc-sum.crsa-road-tax-rubl      -
                                                        bf_gen_tt-doc-line-sum.crsa-road-tax-rubl
               bf_mis_trn-doc-sum.crsa-excise-base    = bf_mis_trn-doc-sum.crsa-excise-base        -
                                                        bf_gen_tt-doc-line-sum.crsa-excise-base
               bf_mis_trn-doc-sum.crsa-excise-rubl    = bf_mis_trn-doc-sum.crsa-excise-rubl        -
                                                        bf_gen_tt-doc-line-sum.crsa-excise-rubl
               bf_mis_trn-doc-sum.crsa-transport-base = bf_mis_trn-doc-sum.crsa-transport-base     -
                                                        bf_gen_tt-doc-line-sum.crsa-transport-base
               bf_mis_trn-doc-sum.crsa-transport-rubl = bf_mis_trn-doc-sum.crsa-transport-rubl     -
                                                        bf_gen_tt-doc-line-sum.crsa-transport-rubl
               bf_mis_trn-doc-sum.crsa-other-base     = bf_mis_trn-doc-sum.crsa-other-base         -
                                                        bf_gen_tt-doc-line-sum.crsa-other-base
               bf_mis_trn-doc-sum.crsa-other-rubl     = bf_mis_trn-doc-sum.crsa-other-rubl         -
                                                        bf_gen_tt-doc-line-sum.crsa-other-rubl
               bf_mis_trn-doc-sum.crsa-discnt-base    = bf_mis_trn-doc-sum.crsa-discnt-base        -
                                                        bf_gen_tt-doc-line-sum.crsa-discnt-base
               bf_mis_trn-doc-sum.crsa-discnt-rubl    = bf_mis_trn-doc-sum.crsa-discnt-rubl        -
                                                        bf_gen_tt-doc-line-sum.crsa-discnt-rubl
        .
      end.
    end.
    if bf_gen_tt-old-doc-line-sum.crsa-sum-rubl > 0 then do:
      assign bf_ext_trn-doc-sum.crsa-sum-base       = bf_ext_trn-doc-sum.crsa-sum-base               -
                                                      bf_gen_tt-old-doc-line-sum.crsa-sum-base
             bf_ext_trn-doc-sum.crsa-sum-rubl       = bf_ext_trn-doc-sum.crsa-sum-rubl               -
                                                      bf_gen_tt-old-doc-line-sum.crsa-sum-rubl
             bf_ext_trn-doc-sum.crsa-VAT-base       = bf_ext_trn-doc-sum.crsa-VAT-base               -
                                                      bf_gen_tt-old-doc-line-sum.crsa-VAT-base
             bf_ext_trn-doc-sum.crsa-VAT-rubl       = bf_ext_trn-doc-sum.crsa-VAT-rubl               -
                                                      bf_gen_tt-old-doc-line-sum.crsa-VAT-rubl
             bf_ext_trn-doc-sum.crsa-SLT-base       = bf_ext_trn-doc-sum.crsa-SLT-base               -
                                                      bf_gen_tt-old-doc-line-sum.crsa-SLT-base
             bf_ext_trn-doc-sum.crsa-SLT-rubl       = bf_ext_trn-doc-sum.crsa-SLT-rubl               -
                                                      bf_gen_tt-old-doc-line-sum.crsa-SLT-rubl
             bf_ext_trn-doc-sum.crsa-road-tax-base  = bf_ext_trn-doc-sum.crsa-road-tax-base          -
                                                      bf_gen_tt-old-doc-line-sum.crsa-road-tax-base
             bf_ext_trn-doc-sum.crsa-road-tax-rubl  = bf_ext_trn-doc-sum.crsa-road-tax-rubl          -
                                                      bf_gen_tt-old-doc-line-sum.crsa-road-tax-rubl
             bf_ext_trn-doc-sum.crsa-excise-base    = bf_ext_trn-doc-sum.crsa-excise-base            -
                                                      bf_gen_tt-old-doc-line-sum.crsa-excise-base
             bf_ext_trn-doc-sum.crsa-excise-rubl    = bf_ext_trn-doc-sum.crsa-excise-rubl            -
                                                      bf_gen_tt-old-doc-line-sum.crsa-excise-rubl
             bf_ext_trn-doc-sum.crsa-transport-base = bf_ext_trn-doc-sum.crsa-transport-base         -
                                                      bf_gen_tt-old-doc-line-sum.crsa-transport-base
             bf_ext_trn-doc-sum.crsa-transport-rubl = bf_ext_trn-doc-sum.crsa-transport-rubl         -
                                                      bf_gen_tt-old-doc-line-sum.crsa-transport-rubl
             bf_ext_trn-doc-sum.crsa-other-base     = bf_ext_trn-doc-sum.crsa-other-base             -
                                                      bf_gen_tt-old-doc-line-sum.crsa-other-base
             bf_ext_trn-doc-sum.crsa-other-rubl     = bf_ext_trn-doc-sum.crsa-other-rubl             -
                                                      bf_gen_tt-old-doc-line-sum.crsa-other-rubl
             bf_ext_trn-doc-sum.crsa-discnt-base    = bf_ext_trn-doc-sum.crsa-discnt-base            -
                                                      bf_gen_tt-old-doc-line-sum.crsa-discnt-base
             bf_ext_trn-doc-sum.crsa-discnt-rubl    = bf_ext_trn-doc-sum.crsa-discnt-rubl            -
                                                      bf_gen_tt-old-doc-line-sum.crsa-discnt-rubl
      .
    end.
    else do:
      assign bf_mis_trn-doc-sum.crsa-sum-base       = bf_mis_trn-doc-sum.crsa-sum-base               +
                                                      bf_gen_tt-old-doc-line-sum.crsa-sum-base
             bf_mis_trn-doc-sum.crsa-sum-rubl       = bf_mis_trn-doc-sum.crsa-sum-rubl               +
                                                      bf_gen_tt-old-doc-line-sum.crsa-sum-rubl
             bf_mis_trn-doc-sum.crsa-VAT-base       = bf_mis_trn-doc-sum.crsa-VAT-base               +
                                                      bf_gen_tt-old-doc-line-sum.crsa-VAT-base
             bf_mis_trn-doc-sum.crsa-VAT-rubl       = bf_mis_trn-doc-sum.crsa-VAT-rubl               +
                                                      bf_gen_tt-old-doc-line-sum.crsa-VAT-rubl
             bf_mis_trn-doc-sum.crsa-SLT-base       = bf_mis_trn-doc-sum.crsa-SLT-base               +
                                                      bf_gen_tt-old-doc-line-sum.crsa-SLT-base
             bf_mis_trn-doc-sum.crsa-SLT-rubl       = bf_mis_trn-doc-sum.crsa-SLT-rubl               +
                                                      bf_gen_tt-old-doc-line-sum.crsa-SLT-rubl
             bf_mis_trn-doc-sum.crsa-road-tax-base  = bf_mis_trn-doc-sum.crsa-road-tax-base          +
                                                      bf_gen_tt-old-doc-line-sum.crsa-road-tax-base
             bf_mis_trn-doc-sum.crsa-road-tax-rubl  = bf_mis_trn-doc-sum.crsa-road-tax-rubl          +
                                                      bf_gen_tt-old-doc-line-sum.crsa-road-tax-rubl
             bf_mis_trn-doc-sum.crsa-excise-base    = bf_mis_trn-doc-sum.crsa-excise-base            +
                                                      bf_gen_tt-old-doc-line-sum.crsa-excise-base
             bf_mis_trn-doc-sum.crsa-excise-rubl    = bf_mis_trn-doc-sum.crsa-excise-rubl            +
                                                      bf_gen_tt-old-doc-line-sum.crsa-excise-rubl
             bf_mis_trn-doc-sum.crsa-transport-base = bf_mis_trn-doc-sum.crsa-transport-base         +
                                                      bf_gen_tt-old-doc-line-sum.crsa-transport-base
             bf_mis_trn-doc-sum.crsa-transport-rubl = bf_mis_trn-doc-sum.crsa-transport-rubl         +
                                                      bf_gen_tt-old-doc-line-sum.crsa-transport-rubl
             bf_mis_trn-doc-sum.crsa-other-base     = bf_mis_trn-doc-sum.crsa-other-base             +
                                                      bf_gen_tt-old-doc-line-sum.crsa-other-base
             bf_mis_trn-doc-sum.crsa-other-rubl     = bf_mis_trn-doc-sum.crsa-other-rubl             +
                                                      bf_gen_tt-old-doc-line-sum.crsa-other-rubl
             bf_mis_trn-doc-sum.crsa-discnt-base    = bf_mis_trn-doc-sum.crsa-discnt-base            +
                                                      bf_gen_tt-old-doc-line-sum.crsa-discnt-base
             bf_mis_trn-doc-sum.crsa-discnt-rubl    = bf_mis_trn-doc-sum.crsa-discnt-rubl            +
                                                      bf_gen_tt-old-doc-line-sum.crsa-discnt-rubl
      .
    end.
    assign bf_gen_trn-doc-sum.cost-sum-base       = bf_gen_trn-doc-sum.cost-sum-base                        +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.cost-sum-base           else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.cost-sum-base
           bf_gen_trn-doc-sum.cost-sum-rubl       = bf_gen_trn-doc-sum.cost-sum-rubl                        +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.cost-sum-rubl           else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.cost-sum-rubl
           bf_gen_trn-doc-sum.cost-VAT-base       = bf_gen_trn-doc-sum.cost-VAT-base                        +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.cost-VAT-base           else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.cost-VAT-base
           bf_gen_trn-doc-sum.cost-VAT-rubl       = bf_gen_trn-doc-sum.cost-VAT-rubl                        +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.cost-VAT-rubl           else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.cost-VAT-rubl
           bf_gen_trn-doc-sum.cost-SLT-base       = bf_gen_trn-doc-sum.cost-SLT-base                        +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.cost-SLT-base           else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.cost-SLT-base
           bf_gen_trn-doc-sum.cost-SLT-rubl       = bf_gen_trn-doc-sum.cost-SLT-rubl                        +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.cost-SLT-rubl           else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.cost-SLT-rubl
           bf_gen_trn-doc-sum.cost-road-tax-base  = bf_gen_trn-doc-sum.cost-road-tax-base                   +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.cost-road-tax-base      else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.cost-road-tax-base
           bf_gen_trn-doc-sum.cost-road-tax-rubl  = bf_gen_trn-doc-sum.cost-road-tax-rubl                   +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.cost-road-tax-rubl      else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.cost-road-tax-rubl
           bf_gen_trn-doc-sum.cost-excise-base    = bf_gen_trn-doc-sum.cost-excise-base                     +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.cost-excise-base        else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.cost-excise-base
           bf_gen_trn-doc-sum.cost-excise-rubl    = bf_gen_trn-doc-sum.cost-excise-rubl                     +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.cost-excise-rubl        else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.cost-excise-rubl
           bf_gen_trn-doc-sum.cost-transport-base = bf_gen_trn-doc-sum.cost-transport-base                  +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.cost-transport-base     else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.cost-transport-base
           bf_gen_trn-doc-sum.cost-transport-rubl = bf_gen_trn-doc-sum.cost-transport-rubl                  +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.cost-transport-rubl     else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.cost-transport-rubl
           bf_gen_trn-doc-sum.cost-other-base     = bf_gen_trn-doc-sum.cost-other-base                      +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.cost-other-base         else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.cost-other-base
           bf_gen_trn-doc-sum.cost-other-rubl     = bf_gen_trn-doc-sum.cost-other-rubl                      +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.cost-other-rubl         else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.cost-other-rubl
           bf_gen_trn-doc-sum.cost-discnt-base    = bf_gen_trn-doc-sum.cost-discnt-base                     +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.cost-discnt-base        else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.cost-discnt-base
           bf_gen_trn-doc-sum.cost-discnt-rubl    = bf_gen_trn-doc-sum.cost-discnt-rubl                     +
                      ( if p-mode = "update":U then bf_gen_tt-doc-line-sum.cost-discnt-rubl        else 0 ) -
                                                    bf_gen_tt-old-doc-line-sum.cost-discnt-rubl
    .
    if p-mode = "update":U then do:
      if bf_gen_tt-doc-line-sum.cost-sum-rubl > 0 then do:
        assign bf_ext_trn-doc-sum.cost-sum-base       = bf_ext_trn-doc-sum.cost-sum-base           +
                                                        bf_gen_tt-doc-line-sum.cost-sum-base
               bf_ext_trn-doc-sum.cost-sum-rubl       = bf_ext_trn-doc-sum.cost-sum-rubl           +
                                                        bf_gen_tt-doc-line-sum.cost-sum-rubl
               bf_ext_trn-doc-sum.cost-VAT-base       = bf_ext_trn-doc-sum.cost-VAT-base           +
                                                        bf_gen_tt-doc-line-sum.cost-VAT-base
               bf_ext_trn-doc-sum.cost-VAT-rubl       = bf_ext_trn-doc-sum.cost-VAT-rubl           +
                                                        bf_gen_tt-doc-line-sum.cost-VAT-rubl
               bf_ext_trn-doc-sum.cost-SLT-base       = bf_ext_trn-doc-sum.cost-SLT-base           +
                                                        bf_gen_tt-doc-line-sum.cost-SLT-base
               bf_ext_trn-doc-sum.cost-SLT-rubl       = bf_ext_trn-doc-sum.cost-SLT-rubl           +
                                                        bf_gen_tt-doc-line-sum.cost-SLT-rubl
               bf_ext_trn-doc-sum.cost-road-tax-base  = bf_ext_trn-doc-sum.cost-road-tax-base      +
                                                        bf_gen_tt-doc-line-sum.cost-road-tax-base
               bf_ext_trn-doc-sum.cost-road-tax-rubl  = bf_ext_trn-doc-sum.cost-road-tax-rubl      +
                                                        bf_gen_tt-doc-line-sum.cost-road-tax-rubl
               bf_ext_trn-doc-sum.cost-excise-base    = bf_ext_trn-doc-sum.cost-excise-base        +
                                                        bf_gen_tt-doc-line-sum.cost-excise-base
               bf_ext_trn-doc-sum.cost-excise-rubl    = bf_ext_trn-doc-sum.cost-excise-rubl        +
                                                        bf_gen_tt-doc-line-sum.cost-excise-rubl
               bf_ext_trn-doc-sum.cost-transport-base = bf_ext_trn-doc-sum.cost-transport-base     +
                                                        bf_gen_tt-doc-line-sum.cost-transport-base
               bf_ext_trn-doc-sum.cost-transport-rubl = bf_ext_trn-doc-sum.cost-transport-rubl     +
                                                        bf_gen_tt-doc-line-sum.cost-transport-rubl
               bf_ext_trn-doc-sum.cost-other-base     = bf_ext_trn-doc-sum.cost-other-base         +
                                                        bf_gen_tt-doc-line-sum.cost-other-base
               bf_ext_trn-doc-sum.cost-other-rubl     = bf_ext_trn-doc-sum.cost-other-rubl         +
                                                        bf_gen_tt-doc-line-sum.cost-other-rubl
               bf_ext_trn-doc-sum.cost-discnt-base    = bf_ext_trn-doc-sum.cost-discnt-base        +
                                                        bf_gen_tt-doc-line-sum.cost-discnt-base
               bf_ext_trn-doc-sum.cost-discnt-rubl    = bf_ext_trn-doc-sum.cost-discnt-rubl        +
                                                        bf_gen_tt-doc-line-sum.cost-discnt-rubl
        .
      end.
      else do:
        assign bf_mis_trn-doc-sum.cost-sum-base       = bf_mis_trn-doc-sum.cost-sum-base           -
                                                        bf_gen_tt-doc-line-sum.cost-sum-base
               bf_mis_trn-doc-sum.cost-sum-rubl       = bf_mis_trn-doc-sum.cost-sum-rubl           -
                                                        bf_gen_tt-doc-line-sum.cost-sum-rubl
               bf_mis_trn-doc-sum.cost-VAT-base       = bf_mis_trn-doc-sum.cost-VAT-base           -
                                                        bf_gen_tt-doc-line-sum.cost-VAT-base
               bf_mis_trn-doc-sum.cost-VAT-rubl       = bf_mis_trn-doc-sum.cost-VAT-rubl           -
                                                        bf_gen_tt-doc-line-sum.cost-VAT-rubl
               bf_mis_trn-doc-sum.cost-SLT-base       = bf_mis_trn-doc-sum.cost-SLT-base           -
                                                        bf_gen_tt-doc-line-sum.cost-SLT-base
               bf_mis_trn-doc-sum.cost-SLT-rubl       = bf_mis_trn-doc-sum.cost-SLT-rubl           -
                                                        bf_gen_tt-doc-line-sum.cost-SLT-rubl
               bf_mis_trn-doc-sum.cost-road-tax-base  = bf_mis_trn-doc-sum.cost-road-tax-base      -
                                                        bf_gen_tt-doc-line-sum.cost-road-tax-base
               bf_mis_trn-doc-sum.cost-road-tax-rubl  = bf_mis_trn-doc-sum.cost-road-tax-rubl      -
                                                        bf_gen_tt-doc-line-sum.cost-road-tax-rubl
               bf_mis_trn-doc-sum.cost-excise-base    = bf_mis_trn-doc-sum.cost-excise-base        -
                                                        bf_gen_tt-doc-line-sum.cost-excise-base
               bf_mis_trn-doc-sum.cost-excise-rubl    = bf_mis_trn-doc-sum.cost-excise-rubl        -
                                                        bf_gen_tt-doc-line-sum.cost-excise-rubl
               bf_mis_trn-doc-sum.cost-transport-base = bf_mis_trn-doc-sum.cost-transport-base     -
                                                        bf_gen_tt-doc-line-sum.cost-transport-base
               bf_mis_trn-doc-sum.cost-transport-rubl = bf_mis_trn-doc-sum.cost-transport-rubl     -
                                                        bf_gen_tt-doc-line-sum.cost-transport-rubl
               bf_mis_trn-doc-sum.cost-other-base     = bf_mis_trn-doc-sum.cost-other-base         -
                                                        bf_gen_tt-doc-line-sum.cost-other-base
               bf_mis_trn-doc-sum.cost-other-rubl     = bf_mis_trn-doc-sum.cost-other-rubl         -
                                                        bf_gen_tt-doc-line-sum.cost-other-rubl
               bf_mis_trn-doc-sum.cost-discnt-base    = bf_mis_trn-doc-sum.cost-discnt-base        -
                                                        bf_gen_tt-doc-line-sum.cost-discnt-base
               bf_mis_trn-doc-sum.cost-discnt-rubl    = bf_mis_trn-doc-sum.cost-discnt-rubl        -
                                                        bf_gen_tt-doc-line-sum.cost-discnt-rubl
        .
      end.
    end.
    if bf_gen_tt-old-doc-line-sum.cost-sum-rubl > 0 then do:
      assign bf_ext_trn-doc-sum.cost-sum-base       = bf_ext_trn-doc-sum.cost-sum-base               -
                                                      bf_gen_tt-old-doc-line-sum.cost-sum-base
             bf_ext_trn-doc-sum.cost-sum-rubl       = bf_ext_trn-doc-sum.cost-sum-rubl               -
                                                      bf_gen_tt-old-doc-line-sum.cost-sum-rubl
             bf_ext_trn-doc-sum.cost-VAT-base       = bf_ext_trn-doc-sum.cost-VAT-base               -
                                                      bf_gen_tt-old-doc-line-sum.cost-VAT-base
             bf_ext_trn-doc-sum.cost-VAT-rubl       = bf_ext_trn-doc-sum.cost-VAT-rubl               -
                                                      bf_gen_tt-old-doc-line-sum.cost-VAT-rubl
             bf_ext_trn-doc-sum.cost-SLT-base       = bf_ext_trn-doc-sum.cost-SLT-base               -
                                                      bf_gen_tt-old-doc-line-sum.cost-SLT-base
             bf_ext_trn-doc-sum.cost-SLT-rubl       = bf_ext_trn-doc-sum.cost-SLT-rubl               -
                                                      bf_gen_tt-old-doc-line-sum.cost-SLT-rubl
             bf_ext_trn-doc-sum.cost-road-tax-base  = bf_ext_trn-doc-sum.cost-road-tax-base          -
                                                      bf_gen_tt-old-doc-line-sum.cost-road-tax-base
             bf_ext_trn-doc-sum.cost-road-tax-rubl  = bf_ext_trn-doc-sum.cost-road-tax-rubl          -
                                                      bf_gen_tt-old-doc-line-sum.cost-road-tax-rubl
             bf_ext_trn-doc-sum.cost-excise-base    = bf_ext_trn-doc-sum.cost-excise-base            -
                                                      bf_gen_tt-old-doc-line-sum.cost-excise-base
             bf_ext_trn-doc-sum.cost-excise-rubl    = bf_ext_trn-doc-sum.cost-excise-rubl            -
                                                      bf_gen_tt-old-doc-line-sum.cost-excise-rubl
             bf_ext_trn-doc-sum.cost-transport-base = bf_ext_trn-doc-sum.cost-transport-base         -
                                                      bf_gen_tt-old-doc-line-sum.cost-transport-base
             bf_ext_trn-doc-sum.cost-transport-rubl = bf_ext_trn-doc-sum.cost-transport-rubl         -
                                                      bf_gen_tt-old-doc-line-sum.cost-transport-rubl
             bf_ext_trn-doc-sum.cost-other-base     = bf_ext_trn-doc-sum.cost-other-base             -
                                                      bf_gen_tt-old-doc-line-sum.cost-other-base
             bf_ext_trn-doc-sum.cost-other-rubl     = bf_ext_trn-doc-sum.cost-other-rubl             -
                                                      bf_gen_tt-old-doc-line-sum.cost-other-rubl
             bf_ext_trn-doc-sum.cost-discnt-base    = bf_ext_trn-doc-sum.cost-discnt-base            -
                                                      bf_gen_tt-old-doc-line-sum.cost-discnt-base
             bf_ext_trn-doc-sum.cost-discnt-rubl    = bf_ext_trn-doc-sum.cost-discnt-rubl            -
                                                      bf_gen_tt-old-doc-line-sum.cost-discnt-rubl
      .
    end.
    else do:
      assign bf_mis_trn-doc-sum.cost-sum-base       = bf_mis_trn-doc-sum.cost-sum-base               +
                                                      bf_gen_tt-old-doc-line-sum.cost-sum-base
             bf_mis_trn-doc-sum.cost-sum-rubl       = bf_mis_trn-doc-sum.cost-sum-rubl               +
                                                      bf_gen_tt-old-doc-line-sum.cost-sum-rubl
             bf_mis_trn-doc-sum.cost-VAT-base       = bf_mis_trn-doc-sum.cost-VAT-base               +
                                                      bf_gen_tt-old-doc-line-sum.cost-VAT-base
             bf_mis_trn-doc-sum.cost-VAT-rubl       = bf_mis_trn-doc-sum.cost-VAT-rubl               +
                                                      bf_gen_tt-old-doc-line-sum.cost-VAT-rubl
             bf_mis_trn-doc-sum.cost-SLT-base       = bf_mis_trn-doc-sum.cost-SLT-base               +
                                                      bf_gen_tt-old-doc-line-sum.cost-SLT-base
             bf_mis_trn-doc-sum.cost-SLT-rubl       = bf_mis_trn-doc-sum.cost-SLT-rubl               +
                                                      bf_gen_tt-old-doc-line-sum.cost-SLT-rubl
             bf_mis_trn-doc-sum.cost-road-tax-base  = bf_mis_trn-doc-sum.cost-road-tax-base          +
                                                      bf_gen_tt-old-doc-line-sum.cost-road-tax-base
             bf_mis_trn-doc-sum.cost-road-tax-rubl  = bf_mis_trn-doc-sum.cost-road-tax-rubl          +
                                                      bf_gen_tt-old-doc-line-sum.cost-road-tax-rubl
             bf_mis_trn-doc-sum.cost-excise-base    = bf_mis_trn-doc-sum.cost-excise-base            +
                                                      bf_gen_tt-old-doc-line-sum.cost-excise-base
             bf_mis_trn-doc-sum.cost-excise-rubl    = bf_mis_trn-doc-sum.cost-excise-rubl            +
                                                      bf_gen_tt-old-doc-line-sum.cost-excise-rubl
             bf_mis_trn-doc-sum.cost-transport-base = bf_mis_trn-doc-sum.cost-transport-base         +
                                                      bf_gen_tt-old-doc-line-sum.cost-transport-base
             bf_mis_trn-doc-sum.cost-transport-rubl = bf_mis_trn-doc-sum.cost-transport-rubl         +
                                                      bf_gen_tt-old-doc-line-sum.cost-transport-rubl
             bf_mis_trn-doc-sum.cost-other-base     = bf_mis_trn-doc-sum.cost-other-base             +
                                                      bf_gen_tt-old-doc-line-sum.cost-other-base
             bf_mis_trn-doc-sum.cost-other-rubl     = bf_mis_trn-doc-sum.cost-other-rubl             +
                                                      bf_gen_tt-old-doc-line-sum.cost-other-rubl
             bf_mis_trn-doc-sum.cost-discnt-base    = bf_mis_trn-doc-sum.cost-discnt-base            +
                                                      bf_gen_tt-old-doc-line-sum.cost-discnt-base
             bf_mis_trn-doc-sum.cost-discnt-rubl    = bf_mis_trn-doc-sum.cost-discnt-rubl            +
                                                      bf_gen_tt-old-doc-line-sum.cost-discnt-rubl
      .
    end.
    if v_invclcsp = "yes" then do:
      assign bf_gen-cli_trn-doc-sum.fact-qnty           = bf_gen-cli_trn-doc-sum.fact-qnty                            +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.fact-qnty               else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.fact-qnty
             bf_gen-cli_trn-doc-sum.sale-sum-base       = bf_gen-cli_trn-doc-sum.sale-sum-base                        +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.sale-sum-base           else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.sale-sum-base
             bf_gen-cli_trn-doc-sum.sale-sum-rubl       = bf_gen-cli_trn-doc-sum.sale-sum-rubl                        +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.sale-sum-rubl           else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.sale-sum-rubl
             bf_gen-cli_trn-doc-sum.sale-VAT-base       = bf_gen-cli_trn-doc-sum.sale-VAT-base                        +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.sale-VAT-base           else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.sale-VAT-base
             bf_gen-cli_trn-doc-sum.sale-VAT-rubl       = bf_gen-cli_trn-doc-sum.sale-VAT-rubl                        +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.sale-VAT-rubl           else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.sale-VAT-rubl
             bf_gen-cli_trn-doc-sum.sale-SLT-base       = bf_gen-cli_trn-doc-sum.sale-SLT-base                        +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.sale-SLT-base           else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.sale-SLT-base
             bf_gen-cli_trn-doc-sum.sale-SLT-rubl       = bf_gen-cli_trn-doc-sum.sale-SLT-rubl                        +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.sale-SLT-rubl           else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.sale-SLT-rubl
             bf_gen-cli_trn-doc-sum.sale-road-tax-base  = bf_gen-cli_trn-doc-sum.sale-road-tax-base                   +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.sale-road-tax-base      else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.sale-road-tax-base
             bf_gen-cli_trn-doc-sum.sale-road-tax-rubl  = bf_gen-cli_trn-doc-sum.sale-road-tax-rubl                   +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.sale-road-tax-rubl      else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.sale-road-tax-rubl
             bf_gen-cli_trn-doc-sum.sale-excise-base    = bf_gen-cli_trn-doc-sum.sale-excise-base                     +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.sale-excise-base        else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.sale-excise-base
             bf_gen-cli_trn-doc-sum.sale-excise-rubl    = bf_gen-cli_trn-doc-sum.sale-excise-rubl                     +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.sale-excise-rubl        else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.sale-excise-rubl
             bf_gen-cli_trn-doc-sum.sale-transport-base = bf_gen-cli_trn-doc-sum.sale-transport-base                  +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.sale-transport-base     else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.sale-transport-base
             bf_gen-cli_trn-doc-sum.sale-transport-rubl = bf_gen-cli_trn-doc-sum.sale-transport-rubl                  +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.sale-transport-rubl     else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.sale-transport-rubl
             bf_gen-cli_trn-doc-sum.sale-other-base     = bf_gen-cli_trn-doc-sum.sale-other-base                      +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.sale-other-base         else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.sale-other-base
             bf_gen-cli_trn-doc-sum.sale-other-rubl     = bf_gen-cli_trn-doc-sum.sale-other-rubl                      +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.sale-other-rubl         else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.sale-other-rubl
             bf_gen-cli_trn-doc-sum.sale-discnt-base    = bf_gen-cli_trn-doc-sum.sale-discnt-base                     +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.sale-discnt-base        else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.sale-discnt-base
             bf_gen-cli_trn-doc-sum.sale-discnt-rubl    = bf_gen-cli_trn-doc-sum.sale-discnt-rubl                     +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.sale-discnt-rubl        else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.sale-discnt-rubl
      .
      if p-mode = "update":U then do:
        if bf_gen-cli_tt-doc-line-sum.fact-qnty > 0 then do:
          assign bf_ext-cli_trn-doc-sum.fact-qnty = bf_ext-cli_trn-doc-sum.fact-qnty     +
                                                    bf_gen-cli_tt-doc-line-sum.fact-qnty.
        end.
        else do:
          assign bf_mis-cli_trn-doc-sum.fact-qnty = bf_mis-cli_trn-doc-sum.fact-qnty     -
                                                    bf_gen-cli_tt-doc-line-sum.fact-qnty.
        end.
      end.
      if bf_gen-cli_tt-old-doc-line-sum.fact-qnty > 0 then do:
        assign bf_ext-cli_trn-doc-sum.fact-qnty = bf_ext-cli_trn-doc-sum.fact-qnty         -
                                                  bf_gen-cli_tt-old-doc-line-sum.fact-qnty.
      end.
      else do:
        assign bf_mis-cli_trn-doc-sum.fact-qnty = bf_mis-cli_trn-doc-sum.fact-qnty         +
                                                  bf_gen-cli_tt-old-doc-line-sum.fact-qnty.
      end.

      if p-mode = "update":U then do:
        if bf_gen-cli_tt-doc-line-sum.sale-sum-rubl > 0 then do:
          assign bf_ext-cli_trn-doc-sum.sale-sum-base       = bf_ext-cli_trn-doc-sum.sale-sum-base           +
                                                              bf_gen-cli_tt-doc-line-sum.sale-sum-base
                 bf_ext-cli_trn-doc-sum.sale-sum-rubl       = bf_ext-cli_trn-doc-sum.sale-sum-rubl           +
                                                              bf_gen-cli_tt-doc-line-sum.sale-sum-rubl
                 bf_ext-cli_trn-doc-sum.sale-VAT-base       = bf_ext-cli_trn-doc-sum.sale-VAT-base           +
                                                              bf_gen-cli_tt-doc-line-sum.sale-VAT-base
                 bf_ext-cli_trn-doc-sum.sale-VAT-rubl       = bf_ext-cli_trn-doc-sum.sale-VAT-rubl           +
                                                              bf_gen-cli_tt-doc-line-sum.sale-VAT-rubl
                 bf_ext-cli_trn-doc-sum.sale-SLT-base       = bf_ext-cli_trn-doc-sum.sale-SLT-base           +
                                                              bf_gen-cli_tt-doc-line-sum.sale-SLT-base
                 bf_ext-cli_trn-doc-sum.sale-SLT-rubl       = bf_ext-cli_trn-doc-sum.sale-SLT-rubl           +
                                                              bf_gen-cli_tt-doc-line-sum.sale-SLT-rubl
                 bf_ext-cli_trn-doc-sum.sale-road-tax-base  = bf_ext-cli_trn-doc-sum.sale-road-tax-base      +
                                                              bf_gen-cli_tt-doc-line-sum.sale-road-tax-base
                 bf_ext-cli_trn-doc-sum.sale-road-tax-rubl  = bf_ext-cli_trn-doc-sum.sale-road-tax-rubl      +
                                                              bf_gen-cli_tt-doc-line-sum.sale-road-tax-rubl
                 bf_ext-cli_trn-doc-sum.sale-excise-base    = bf_ext-cli_trn-doc-sum.sale-excise-base        +
                                                              bf_gen-cli_tt-doc-line-sum.sale-excise-base
                 bf_ext-cli_trn-doc-sum.sale-excise-rubl    = bf_ext-cli_trn-doc-sum.sale-excise-rubl        +
                                                              bf_gen-cli_tt-doc-line-sum.sale-excise-rubl
                 bf_ext-cli_trn-doc-sum.sale-transport-base = bf_ext-cli_trn-doc-sum.sale-transport-base     +
                                                              bf_gen-cli_tt-doc-line-sum.sale-transport-base
                 bf_ext-cli_trn-doc-sum.sale-transport-rubl = bf_ext-cli_trn-doc-sum.sale-transport-rubl     +
                                                              bf_gen-cli_tt-doc-line-sum.sale-transport-rubl
                 bf_ext-cli_trn-doc-sum.sale-other-base     = bf_ext-cli_trn-doc-sum.sale-other-base         +
                                                              bf_gen-cli_tt-doc-line-sum.sale-other-base
                 bf_ext-cli_trn-doc-sum.sale-other-rubl     = bf_ext-cli_trn-doc-sum.sale-other-rubl         +
                                                              bf_gen-cli_tt-doc-line-sum.sale-other-rubl
                 bf_ext-cli_trn-doc-sum.sale-discnt-base    = bf_ext-cli_trn-doc-sum.sale-discnt-base        +
                                                              bf_gen-cli_tt-doc-line-sum.sale-discnt-base
                 bf_ext-cli_trn-doc-sum.sale-discnt-rubl    = bf_ext-cli_trn-doc-sum.sale-discnt-rubl        +
                                                              bf_gen-cli_tt-doc-line-sum.sale-discnt-rubl
          .
        end.
        else do:
          assign bf_mis-cli_trn-doc-sum.sale-sum-base       = bf_mis-cli_trn-doc-sum.sale-sum-base           -
                                                              bf_gen-cli_tt-doc-line-sum.sale-sum-base
                 bf_mis-cli_trn-doc-sum.sale-sum-rubl       = bf_mis-cli_trn-doc-sum.sale-sum-rubl           -
                                                              bf_gen-cli_tt-doc-line-sum.sale-sum-rubl
                 bf_mis-cli_trn-doc-sum.sale-VAT-base       = bf_mis-cli_trn-doc-sum.sale-VAT-base           -
                                                              bf_gen-cli_tt-doc-line-sum.sale-VAT-base
                 bf_mis-cli_trn-doc-sum.sale-VAT-rubl       = bf_mis-cli_trn-doc-sum.sale-VAT-rubl           -
                                                              bf_gen-cli_tt-doc-line-sum.sale-VAT-rubl
                 bf_mis-cli_trn-doc-sum.sale-SLT-base       = bf_mis-cli_trn-doc-sum.sale-SLT-base           -
                                                              bf_gen-cli_tt-doc-line-sum.sale-SLT-base
                 bf_mis-cli_trn-doc-sum.sale-SLT-rubl       = bf_mis-cli_trn-doc-sum.sale-SLT-rubl           -
                                                              bf_gen-cli_tt-doc-line-sum.sale-SLT-rubl
                 bf_mis-cli_trn-doc-sum.sale-road-tax-base  = bf_mis-cli_trn-doc-sum.sale-road-tax-base      -
                                                              bf_gen-cli_tt-doc-line-sum.sale-road-tax-base
                 bf_mis-cli_trn-doc-sum.sale-road-tax-rubl  = bf_mis-cli_trn-doc-sum.sale-road-tax-rubl      -
                                                              bf_gen-cli_tt-doc-line-sum.sale-road-tax-rubl
                 bf_mis-cli_trn-doc-sum.sale-excise-base    = bf_mis-cli_trn-doc-sum.sale-excise-base        -
                                                              bf_gen-cli_tt-doc-line-sum.sale-excise-base
                 bf_mis-cli_trn-doc-sum.sale-excise-rubl    = bf_mis-cli_trn-doc-sum.sale-excise-rubl        -
                                                              bf_gen-cli_tt-doc-line-sum.sale-excise-rubl
                 bf_mis-cli_trn-doc-sum.sale-transport-base = bf_mis-cli_trn-doc-sum.sale-transport-base     -
                                                              bf_gen-cli_tt-doc-line-sum.sale-transport-base
                 bf_mis-cli_trn-doc-sum.sale-transport-rubl = bf_mis-cli_trn-doc-sum.sale-transport-rubl     -
                                                              bf_gen-cli_tt-doc-line-sum.sale-transport-rubl
                 bf_mis-cli_trn-doc-sum.sale-other-base     = bf_mis-cli_trn-doc-sum.sale-other-base         -
                                                              bf_gen-cli_tt-doc-line-sum.sale-other-base
                 bf_mis-cli_trn-doc-sum.sale-other-rubl     = bf_mis-cli_trn-doc-sum.sale-other-rubl         -
                                                              bf_gen-cli_tt-doc-line-sum.sale-other-rubl
                 bf_mis-cli_trn-doc-sum.sale-discnt-base    = bf_mis-cli_trn-doc-sum.sale-discnt-base        -
                                                              bf_gen-cli_tt-doc-line-sum.sale-discnt-base
                 bf_mis-cli_trn-doc-sum.sale-discnt-rubl    = bf_mis-cli_trn-doc-sum.sale-discnt-rubl        -
                                                              bf_gen-cli_tt-doc-line-sum.sale-discnt-rubl
          .
        end.
      end.
      if bf_gen-cli_tt-old-doc-line-sum.sale-sum-rubl > 0 then do:
        assign bf_ext-cli_trn-doc-sum.sale-sum-base       = bf_ext-cli_trn-doc-sum.sale-sum-base               -
                                                            bf_gen-cli_tt-old-doc-line-sum.sale-sum-base
               bf_ext-cli_trn-doc-sum.sale-sum-rubl       = bf_ext-cli_trn-doc-sum.sale-sum-rubl               -
                                                            bf_gen-cli_tt-old-doc-line-sum.sale-sum-rubl
               bf_ext-cli_trn-doc-sum.sale-VAT-base       = bf_ext-cli_trn-doc-sum.sale-VAT-base               -
                                                            bf_gen-cli_tt-old-doc-line-sum.sale-VAT-base
               bf_ext-cli_trn-doc-sum.sale-VAT-rubl       = bf_ext-cli_trn-doc-sum.sale-VAT-rubl               -
                                                            bf_gen-cli_tt-old-doc-line-sum.sale-VAT-rubl
               bf_ext-cli_trn-doc-sum.sale-SLT-base       = bf_ext-cli_trn-doc-sum.sale-SLT-base               -
                                                            bf_gen-cli_tt-old-doc-line-sum.sale-SLT-base
               bf_ext-cli_trn-doc-sum.sale-SLT-rubl       = bf_ext-cli_trn-doc-sum.sale-SLT-rubl               -
                                                            bf_gen-cli_tt-old-doc-line-sum.sale-SLT-rubl
               bf_ext-cli_trn-doc-sum.sale-road-tax-base  = bf_ext-cli_trn-doc-sum.sale-road-tax-base          -
                                                            bf_gen-cli_tt-old-doc-line-sum.sale-road-tax-base
               bf_ext-cli_trn-doc-sum.sale-road-tax-rubl  = bf_ext-cli_trn-doc-sum.sale-road-tax-rubl          -
                                                            bf_gen-cli_tt-old-doc-line-sum.sale-road-tax-rubl
               bf_ext-cli_trn-doc-sum.sale-excise-base    = bf_ext-cli_trn-doc-sum.sale-excise-base            -
                                                            bf_gen-cli_tt-old-doc-line-sum.sale-excise-base
               bf_ext-cli_trn-doc-sum.sale-excise-rubl    = bf_ext-cli_trn-doc-sum.sale-excise-rubl            -
                                                            bf_gen-cli_tt-old-doc-line-sum.sale-excise-rubl
               bf_ext-cli_trn-doc-sum.sale-transport-base = bf_ext-cli_trn-doc-sum.sale-transport-base         -
                                                            bf_gen-cli_tt-old-doc-line-sum.sale-transport-base
               bf_ext-cli_trn-doc-sum.sale-transport-rubl = bf_ext-cli_trn-doc-sum.sale-transport-rubl         -
                                                            bf_gen-cli_tt-old-doc-line-sum.sale-transport-rubl
               bf_ext-cli_trn-doc-sum.sale-other-base     = bf_ext-cli_trn-doc-sum.sale-other-base             -
                                                            bf_gen-cli_tt-old-doc-line-sum.sale-other-base
               bf_ext-cli_trn-doc-sum.sale-other-rubl     = bf_ext-cli_trn-doc-sum.sale-other-rubl             -
                                                            bf_gen-cli_tt-old-doc-line-sum.sale-other-rubl
               bf_ext-cli_trn-doc-sum.sale-discnt-base    = bf_ext-cli_trn-doc-sum.sale-discnt-base            -
                                                            bf_gen-cli_tt-old-doc-line-sum.sale-discnt-base
               bf_ext-cli_trn-doc-sum.sale-discnt-rubl    = bf_ext-cli_trn-doc-sum.sale-discnt-rubl            -
                                                            bf_gen-cli_tt-old-doc-line-sum.sale-discnt-rubl
        .
      end.
      else do:
        assign bf_mis-cli_trn-doc-sum.sale-sum-base       = bf_mis-cli_trn-doc-sum.sale-sum-base               +
                                                            bf_gen-cli_tt-old-doc-line-sum.sale-sum-base
               bf_mis-cli_trn-doc-sum.sale-sum-rubl       = bf_mis-cli_trn-doc-sum.sale-sum-rubl               +
                                                            bf_gen-cli_tt-old-doc-line-sum.sale-sum-rubl
               bf_mis-cli_trn-doc-sum.sale-VAT-base       = bf_mis-cli_trn-doc-sum.sale-VAT-base               +
                                                            bf_gen-cli_tt-old-doc-line-sum.sale-VAT-base
               bf_mis-cli_trn-doc-sum.sale-VAT-rubl       = bf_mis-cli_trn-doc-sum.sale-VAT-rubl               +
                                                            bf_gen-cli_tt-old-doc-line-sum.sale-VAT-rubl
               bf_mis-cli_trn-doc-sum.sale-SLT-base       = bf_mis-cli_trn-doc-sum.sale-SLT-base               +
                                                            bf_gen-cli_tt-old-doc-line-sum.sale-SLT-base
               bf_mis-cli_trn-doc-sum.sale-SLT-rubl       = bf_mis-cli_trn-doc-sum.sale-SLT-rubl               +
                                                            bf_gen-cli_tt-old-doc-line-sum.sale-SLT-rubl
               bf_mis-cli_trn-doc-sum.sale-road-tax-base  = bf_mis-cli_trn-doc-sum.sale-road-tax-base          +
                                                            bf_gen-cli_tt-old-doc-line-sum.sale-road-tax-base
               bf_mis-cli_trn-doc-sum.sale-road-tax-rubl  = bf_mis-cli_trn-doc-sum.sale-road-tax-rubl          +
                                                            bf_gen-cli_tt-old-doc-line-sum.sale-road-tax-rubl
               bf_mis-cli_trn-doc-sum.sale-excise-base    = bf_mis-cli_trn-doc-sum.sale-excise-base            +
                                                            bf_gen-cli_tt-old-doc-line-sum.sale-excise-base
               bf_mis-cli_trn-doc-sum.sale-excise-rubl    = bf_mis-cli_trn-doc-sum.sale-excise-rubl            +
                                                            bf_gen-cli_tt-old-doc-line-sum.sale-excise-rubl
               bf_mis-cli_trn-doc-sum.sale-transport-base = bf_mis-cli_trn-doc-sum.sale-transport-base         +
                                                            bf_gen-cli_tt-old-doc-line-sum.sale-transport-base
               bf_mis-cli_trn-doc-sum.sale-transport-rubl = bf_mis-cli_trn-doc-sum.sale-transport-rubl         +
                                                            bf_gen-cli_tt-old-doc-line-sum.sale-transport-rubl
               bf_mis-cli_trn-doc-sum.sale-other-base     = bf_mis-cli_trn-doc-sum.sale-other-base             +
                                                            bf_gen-cli_tt-old-doc-line-sum.sale-other-base
               bf_mis-cli_trn-doc-sum.sale-other-rubl     = bf_mis-cli_trn-doc-sum.sale-other-rubl             +
                                                            bf_gen-cli_tt-old-doc-line-sum.sale-other-rubl
               bf_mis-cli_trn-doc-sum.sale-discnt-base    = bf_mis-cli_trn-doc-sum.sale-discnt-base            +
                                                            bf_gen-cli_tt-old-doc-line-sum.sale-discnt-base
               bf_mis-cli_trn-doc-sum.sale-discnt-rubl    = bf_mis-cli_trn-doc-sum.sale-discnt-rubl            +
                                                            bf_gen-cli_tt-old-doc-line-sum.sale-discnt-rubl
        .
      end.

      assign bf_gen-cli_trn-doc-sum.crsa-sum-base       = bf_gen-cli_trn-doc-sum.crsa-sum-base                        +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.crsa-sum-base           else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.crsa-sum-base
             bf_gen-cli_trn-doc-sum.crsa-sum-rubl       = bf_gen-cli_trn-doc-sum.crsa-sum-rubl                        +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.crsa-sum-rubl           else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.crsa-sum-rubl
             bf_gen-cli_trn-doc-sum.crsa-VAT-base       = bf_gen-cli_trn-doc-sum.crsa-VAT-base                        +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.crsa-VAT-base           else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.crsa-VAT-base
             bf_gen-cli_trn-doc-sum.crsa-VAT-rubl       = bf_gen-cli_trn-doc-sum.crsa-VAT-rubl                        +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.crsa-VAT-rubl           else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.crsa-VAT-rubl
             bf_gen-cli_trn-doc-sum.crsa-SLT-base       = bf_gen-cli_trn-doc-sum.crsa-SLT-base                        +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.crsa-SLT-base           else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.crsa-SLT-base
             bf_gen-cli_trn-doc-sum.crsa-SLT-rubl       = bf_gen-cli_trn-doc-sum.crsa-SLT-rubl                        +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.crsa-SLT-rubl           else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.crsa-SLT-rubl
             bf_gen-cli_trn-doc-sum.crsa-road-tax-base  = bf_gen-cli_trn-doc-sum.crsa-road-tax-base                   +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.crsa-road-tax-base      else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.crsa-road-tax-base
             bf_gen-cli_trn-doc-sum.crsa-road-tax-rubl  = bf_gen-cli_trn-doc-sum.crsa-road-tax-rubl                   +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.crsa-road-tax-rubl      else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.crsa-road-tax-rubl
             bf_gen-cli_trn-doc-sum.crsa-excise-base    = bf_gen-cli_trn-doc-sum.crsa-excise-base                     +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.crsa-excise-base        else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.crsa-excise-base
             bf_gen-cli_trn-doc-sum.crsa-excise-rubl    = bf_gen-cli_trn-doc-sum.crsa-excise-rubl                     +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.crsa-excise-rubl        else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.crsa-excise-rubl
             bf_gen-cli_trn-doc-sum.crsa-transport-base = bf_gen-cli_trn-doc-sum.crsa-transport-base                  +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.crsa-transport-base     else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.crsa-transport-base
             bf_gen-cli_trn-doc-sum.crsa-transport-rubl = bf_gen-cli_trn-doc-sum.crsa-transport-rubl                  +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.crsa-transport-rubl     else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.crsa-transport-rubl
             bf_gen-cli_trn-doc-sum.crsa-other-base     = bf_gen-cli_trn-doc-sum.crsa-other-base                      +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.crsa-other-base         else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.crsa-other-base
             bf_gen-cli_trn-doc-sum.crsa-other-rubl     = bf_gen-cli_trn-doc-sum.crsa-other-rubl                      +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.crsa-other-rubl         else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.crsa-other-rubl
             bf_gen-cli_trn-doc-sum.crsa-discnt-base    = bf_gen-cli_trn-doc-sum.crsa-discnt-base                     +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.crsa-discnt-base        else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.crsa-discnt-base
             bf_gen-cli_trn-doc-sum.crsa-discnt-rubl    = bf_gen-cli_trn-doc-sum.crsa-discnt-rubl                     +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.crsa-discnt-rubl        else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.crsa-discnt-rubl
      .
      if p-mode = "update":U then do:
        if bf_gen-cli_tt-doc-line-sum.crsa-sum-rubl > 0 then do:
          assign bf_ext-cli_trn-doc-sum.crsa-sum-base       = bf_ext-cli_trn-doc-sum.crsa-sum-base           +
                                                              bf_gen-cli_tt-doc-line-sum.crsa-sum-base
                 bf_ext-cli_trn-doc-sum.crsa-sum-rubl       = bf_ext-cli_trn-doc-sum.crsa-sum-rubl           +
                                                              bf_gen-cli_tt-doc-line-sum.crsa-sum-rubl
                 bf_ext-cli_trn-doc-sum.crsa-VAT-base       = bf_ext-cli_trn-doc-sum.crsa-VAT-base           +
                                                              bf_gen-cli_tt-doc-line-sum.crsa-VAT-base
                 bf_ext-cli_trn-doc-sum.crsa-VAT-rubl       = bf_ext-cli_trn-doc-sum.crsa-VAT-rubl           +
                                                              bf_gen-cli_tt-doc-line-sum.crsa-VAT-rubl
                 bf_ext-cli_trn-doc-sum.crsa-SLT-base       = bf_ext-cli_trn-doc-sum.crsa-SLT-base           +
                                                              bf_gen-cli_tt-doc-line-sum.crsa-SLT-base
                 bf_ext-cli_trn-doc-sum.crsa-SLT-rubl       = bf_ext-cli_trn-doc-sum.crsa-SLT-rubl           +
                                                              bf_gen-cli_tt-doc-line-sum.crsa-SLT-rubl
                 bf_ext-cli_trn-doc-sum.crsa-road-tax-base  = bf_ext-cli_trn-doc-sum.crsa-road-tax-base      +
                                                              bf_gen-cli_tt-doc-line-sum.crsa-road-tax-base
                 bf_ext-cli_trn-doc-sum.crsa-road-tax-rubl  = bf_ext-cli_trn-doc-sum.crsa-road-tax-rubl      +
                                                              bf_gen-cli_tt-doc-line-sum.crsa-road-tax-rubl
                 bf_ext-cli_trn-doc-sum.crsa-excise-base    = bf_ext-cli_trn-doc-sum.crsa-excise-base        +
                                                              bf_gen-cli_tt-doc-line-sum.crsa-excise-base
                 bf_ext-cli_trn-doc-sum.crsa-excise-rubl    = bf_ext-cli_trn-doc-sum.crsa-excise-rubl        +
                                                              bf_gen-cli_tt-doc-line-sum.crsa-excise-rubl
                 bf_ext-cli_trn-doc-sum.crsa-transport-base = bf_ext-cli_trn-doc-sum.crsa-transport-base     +
                                                              bf_gen-cli_tt-doc-line-sum.crsa-transport-base
                 bf_ext-cli_trn-doc-sum.crsa-transport-rubl = bf_ext-cli_trn-doc-sum.crsa-transport-rubl     +
                                                              bf_gen-cli_tt-doc-line-sum.crsa-transport-rubl
                 bf_ext-cli_trn-doc-sum.crsa-other-base     = bf_ext-cli_trn-doc-sum.crsa-other-base         +
                                                              bf_gen-cli_tt-doc-line-sum.crsa-other-base
                 bf_ext-cli_trn-doc-sum.crsa-other-rubl     = bf_ext-cli_trn-doc-sum.crsa-other-rubl         +
                                                              bf_gen-cli_tt-doc-line-sum.crsa-other-rubl
                 bf_ext-cli_trn-doc-sum.crsa-discnt-base    = bf_ext-cli_trn-doc-sum.crsa-discnt-base        +
                                                              bf_gen-cli_tt-doc-line-sum.crsa-discnt-base
                 bf_ext-cli_trn-doc-sum.crsa-discnt-rubl    = bf_ext-cli_trn-doc-sum.crsa-discnt-rubl        +
                                                              bf_gen-cli_tt-doc-line-sum.crsa-discnt-rubl
          .
        end.
        else do:
          assign bf_mis-cli_trn-doc-sum.crsa-sum-base       = bf_mis-cli_trn-doc-sum.crsa-sum-base           -
                                                              bf_gen-cli_tt-doc-line-sum.crsa-sum-base
                 bf_mis-cli_trn-doc-sum.crsa-sum-rubl       = bf_mis-cli_trn-doc-sum.crsa-sum-rubl           -
                                                              bf_gen-cli_tt-doc-line-sum.crsa-sum-rubl
                 bf_mis-cli_trn-doc-sum.crsa-VAT-base       = bf_mis-cli_trn-doc-sum.crsa-VAT-base           -
                                                              bf_gen-cli_tt-doc-line-sum.crsa-VAT-base
                 bf_mis-cli_trn-doc-sum.crsa-VAT-rubl       = bf_mis-cli_trn-doc-sum.crsa-VAT-rubl           -
                                                              bf_gen-cli_tt-doc-line-sum.crsa-VAT-rubl
                 bf_mis-cli_trn-doc-sum.crsa-SLT-base       = bf_mis-cli_trn-doc-sum.crsa-SLT-base           -
                                                              bf_gen-cli_tt-doc-line-sum.crsa-SLT-base
                 bf_mis-cli_trn-doc-sum.crsa-SLT-rubl       = bf_mis-cli_trn-doc-sum.crsa-SLT-rubl           -
                                                              bf_gen-cli_tt-doc-line-sum.crsa-SLT-rubl
                 bf_mis-cli_trn-doc-sum.crsa-road-tax-base  = bf_mis-cli_trn-doc-sum.crsa-road-tax-base      -
                                                              bf_gen-cli_tt-doc-line-sum.crsa-road-tax-base
                 bf_mis-cli_trn-doc-sum.crsa-road-tax-rubl  = bf_mis-cli_trn-doc-sum.crsa-road-tax-rubl      -
                                                              bf_gen-cli_tt-doc-line-sum.crsa-road-tax-rubl
                 bf_mis-cli_trn-doc-sum.crsa-excise-base    = bf_mis-cli_trn-doc-sum.crsa-excise-base        -
                                                              bf_gen-cli_tt-doc-line-sum.crsa-excise-base
                 bf_mis-cli_trn-doc-sum.crsa-excise-rubl    = bf_mis-cli_trn-doc-sum.crsa-excise-rubl        -
                                                              bf_gen-cli_tt-doc-line-sum.crsa-excise-rubl
                 bf_mis-cli_trn-doc-sum.crsa-transport-base = bf_mis-cli_trn-doc-sum.crsa-transport-base     -
                                                              bf_gen-cli_tt-doc-line-sum.crsa-transport-base
                 bf_mis-cli_trn-doc-sum.crsa-transport-rubl = bf_mis-cli_trn-doc-sum.crsa-transport-rubl     -
                                                              bf_gen-cli_tt-doc-line-sum.crsa-transport-rubl
                 bf_mis-cli_trn-doc-sum.crsa-other-base     = bf_mis-cli_trn-doc-sum.crsa-other-base         -
                                                              bf_gen-cli_tt-doc-line-sum.crsa-other-base
                 bf_mis-cli_trn-doc-sum.crsa-other-rubl     = bf_mis-cli_trn-doc-sum.crsa-other-rubl         -
                                                              bf_gen-cli_tt-doc-line-sum.crsa-other-rubl
                 bf_mis-cli_trn-doc-sum.crsa-discnt-base    = bf_mis-cli_trn-doc-sum.crsa-discnt-base        -
                                                              bf_gen-cli_tt-doc-line-sum.crsa-discnt-base
                 bf_mis-cli_trn-doc-sum.crsa-discnt-rubl    = bf_mis-cli_trn-doc-sum.crsa-discnt-rubl        -
                                                              bf_gen-cli_tt-doc-line-sum.crsa-discnt-rubl
          .
        end.
      end. /* if p-mode = "update" */
      if bf_gen-cli_tt-old-doc-line-sum.crsa-sum-rubl > 0 then do:
        assign bf_ext-cli_trn-doc-sum.crsa-sum-base       = bf_ext-cli_trn-doc-sum.crsa-sum-base               -
                                                            bf_gen-cli_tt-old-doc-line-sum.crsa-sum-base
               bf_ext-cli_trn-doc-sum.crsa-sum-rubl       = bf_ext-cli_trn-doc-sum.crsa-sum-rubl               -
                                                            bf_gen-cli_tt-old-doc-line-sum.crsa-sum-rubl
               bf_ext-cli_trn-doc-sum.crsa-VAT-base       = bf_ext-cli_trn-doc-sum.crsa-VAT-base               -
                                                            bf_gen-cli_tt-old-doc-line-sum.crsa-VAT-base
               bf_ext-cli_trn-doc-sum.crsa-VAT-rubl       = bf_ext-cli_trn-doc-sum.crsa-VAT-rubl               -
                                                            bf_gen-cli_tt-old-doc-line-sum.crsa-VAT-rubl
               bf_ext-cli_trn-doc-sum.crsa-SLT-base       = bf_ext-cli_trn-doc-sum.crsa-SLT-base               -
                                                            bf_gen-cli_tt-old-doc-line-sum.crsa-SLT-base
               bf_ext-cli_trn-doc-sum.crsa-SLT-rubl       = bf_ext-cli_trn-doc-sum.crsa-SLT-rubl               -
                                                            bf_gen-cli_tt-old-doc-line-sum.crsa-SLT-rubl
               bf_ext-cli_trn-doc-sum.crsa-road-tax-base  = bf_ext-cli_trn-doc-sum.crsa-road-tax-base          -
                                                            bf_gen-cli_tt-old-doc-line-sum.crsa-road-tax-base
               bf_ext-cli_trn-doc-sum.crsa-road-tax-rubl  = bf_ext-cli_trn-doc-sum.crsa-road-tax-rubl          -
                                                            bf_gen-cli_tt-old-doc-line-sum.crsa-road-tax-rubl
               bf_ext-cli_trn-doc-sum.crsa-excise-base    = bf_ext-cli_trn-doc-sum.crsa-excise-base            -
                                                            bf_gen-cli_tt-old-doc-line-sum.crsa-excise-base
               bf_ext-cli_trn-doc-sum.crsa-excise-rubl    = bf_ext-cli_trn-doc-sum.crsa-excise-rubl            -
                                                            bf_gen-cli_tt-old-doc-line-sum.crsa-excise-rubl
               bf_ext-cli_trn-doc-sum.crsa-transport-base = bf_ext-cli_trn-doc-sum.crsa-transport-base         -
                                                            bf_gen-cli_tt-old-doc-line-sum.crsa-transport-base
               bf_ext-cli_trn-doc-sum.crsa-transport-rubl = bf_ext-cli_trn-doc-sum.crsa-transport-rubl         -
                                                            bf_gen-cli_tt-old-doc-line-sum.crsa-transport-rubl
               bf_ext-cli_trn-doc-sum.crsa-other-base     = bf_ext-cli_trn-doc-sum.crsa-other-base             -
                                                            bf_gen-cli_tt-old-doc-line-sum.crsa-other-base
               bf_ext-cli_trn-doc-sum.crsa-other-rubl     = bf_ext-cli_trn-doc-sum.crsa-other-rubl             -
                                                            bf_gen-cli_tt-old-doc-line-sum.crsa-other-rubl
               bf_ext-cli_trn-doc-sum.crsa-discnt-base    = bf_ext-cli_trn-doc-sum.crsa-discnt-base            -
                                                            bf_gen-cli_tt-old-doc-line-sum.crsa-discnt-base
               bf_ext-cli_trn-doc-sum.crsa-discnt-rubl    = bf_ext-cli_trn-doc-sum.crsa-discnt-rubl            -
                                                            bf_gen-cli_tt-old-doc-line-sum.crsa-discnt-rubl
        .
      end.
      else do:
        assign bf_mis-cli_trn-doc-sum.crsa-sum-base       = bf_mis-cli_trn-doc-sum.crsa-sum-base               +
                                                            bf_gen-cli_tt-old-doc-line-sum.crsa-sum-base
               bf_mis-cli_trn-doc-sum.crsa-sum-rubl       = bf_mis-cli_trn-doc-sum.crsa-sum-rubl               +
                                                            bf_gen-cli_tt-old-doc-line-sum.crsa-sum-rubl
               bf_mis-cli_trn-doc-sum.crsa-VAT-base       = bf_mis-cli_trn-doc-sum.crsa-VAT-base               +
                                                            bf_gen-cli_tt-old-doc-line-sum.crsa-VAT-base
               bf_mis-cli_trn-doc-sum.crsa-VAT-rubl       = bf_mis-cli_trn-doc-sum.crsa-VAT-rubl               +
                                                            bf_gen-cli_tt-old-doc-line-sum.crsa-VAT-rubl
               bf_mis-cli_trn-doc-sum.crsa-SLT-base       = bf_mis-cli_trn-doc-sum.crsa-SLT-base               +
                                                            bf_gen-cli_tt-old-doc-line-sum.crsa-SLT-base
               bf_mis-cli_trn-doc-sum.crsa-SLT-rubl       = bf_mis-cli_trn-doc-sum.crsa-SLT-rubl               +
                                                            bf_gen-cli_tt-old-doc-line-sum.crsa-SLT-rubl
               bf_mis-cli_trn-doc-sum.crsa-road-tax-base  = bf_mis-cli_trn-doc-sum.crsa-road-tax-base          +
                                                            bf_gen-cli_tt-old-doc-line-sum.crsa-road-tax-base
               bf_mis-cli_trn-doc-sum.crsa-road-tax-rubl  = bf_mis-cli_trn-doc-sum.crsa-road-tax-rubl          +
                                                            bf_gen-cli_tt-old-doc-line-sum.crsa-road-tax-rubl
               bf_mis-cli_trn-doc-sum.crsa-excise-base    = bf_mis-cli_trn-doc-sum.crsa-excise-base            +
                                                            bf_gen-cli_tt-old-doc-line-sum.crsa-excise-base
               bf_mis-cli_trn-doc-sum.crsa-excise-rubl    = bf_mis-cli_trn-doc-sum.crsa-excise-rubl            +
                                                            bf_gen-cli_tt-old-doc-line-sum.crsa-excise-rubl
               bf_mis-cli_trn-doc-sum.crsa-transport-base = bf_mis-cli_trn-doc-sum.crsa-transport-base         +
                                                            bf_gen-cli_tt-old-doc-line-sum.crsa-transport-base
               bf_mis-cli_trn-doc-sum.crsa-transport-rubl = bf_mis-cli_trn-doc-sum.crsa-transport-rubl         +
                                                            bf_gen-cli_tt-old-doc-line-sum.crsa-transport-rubl
               bf_mis-cli_trn-doc-sum.crsa-other-base     = bf_mis-cli_trn-doc-sum.crsa-other-base             +
                                                            bf_gen-cli_tt-old-doc-line-sum.crsa-other-base
               bf_mis-cli_trn-doc-sum.crsa-other-rubl     = bf_mis-cli_trn-doc-sum.crsa-other-rubl             +
                                                            bf_gen-cli_tt-old-doc-line-sum.crsa-other-rubl
               bf_mis-cli_trn-doc-sum.crsa-discnt-base    = bf_mis-cli_trn-doc-sum.crsa-discnt-base            +
                                                            bf_gen-cli_tt-old-doc-line-sum.crsa-discnt-base
               bf_mis-cli_trn-doc-sum.crsa-discnt-rubl    = bf_mis-cli_trn-doc-sum.crsa-discnt-rubl            +
                                                            bf_gen-cli_tt-old-doc-line-sum.crsa-discnt-rubl
        .
      end.

      assign bf_gen-cli_trn-doc-sum.cost-sum-base       = bf_gen-cli_trn-doc-sum.cost-sum-base                        +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.cost-sum-base           else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.cost-sum-base
             bf_gen-cli_trn-doc-sum.cost-sum-rubl       = bf_gen-cli_trn-doc-sum.cost-sum-rubl                        +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.cost-sum-rubl           else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.cost-sum-rubl
             bf_gen-cli_trn-doc-sum.cost-VAT-base       = bf_gen-cli_trn-doc-sum.cost-VAT-base                        +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.cost-VAT-base           else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.cost-VAT-base
             bf_gen-cli_trn-doc-sum.cost-VAT-rubl       = bf_gen-cli_trn-doc-sum.cost-VAT-rubl                        +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.cost-VAT-rubl           else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.cost-VAT-rubl
             bf_gen-cli_trn-doc-sum.cost-SLT-base       = bf_gen-cli_trn-doc-sum.cost-SLT-base                        +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.cost-SLT-base           else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.cost-SLT-base
             bf_gen-cli_trn-doc-sum.cost-SLT-rubl       = bf_gen-cli_trn-doc-sum.cost-SLT-rubl                        +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.cost-SLT-rubl           else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.cost-SLT-rubl
             bf_gen-cli_trn-doc-sum.cost-road-tax-base  = bf_gen-cli_trn-doc-sum.cost-road-tax-base                   +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.cost-road-tax-base      else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.cost-road-tax-base
             bf_gen-cli_trn-doc-sum.cost-road-tax-rubl  = bf_gen-cli_trn-doc-sum.cost-road-tax-rubl                   +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.cost-road-tax-rubl      else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.cost-road-tax-rubl
             bf_gen-cli_trn-doc-sum.cost-excise-base    = bf_gen-cli_trn-doc-sum.cost-excise-base                     +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.cost-excise-base        else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.cost-excise-base
             bf_gen-cli_trn-doc-sum.cost-excise-rubl    = bf_gen-cli_trn-doc-sum.cost-excise-rubl                     +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.cost-excise-rubl        else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.cost-excise-rubl
             bf_gen-cli_trn-doc-sum.cost-transport-base = bf_gen-cli_trn-doc-sum.cost-transport-base                  +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.cost-transport-base     else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.cost-transport-base
             bf_gen-cli_trn-doc-sum.cost-transport-rubl = bf_gen-cli_trn-doc-sum.cost-transport-rubl                  +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.cost-transport-rubl     else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.cost-transport-rubl
             bf_gen-cli_trn-doc-sum.cost-other-base     = bf_gen-cli_trn-doc-sum.cost-other-base                      +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.cost-other-base         else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.cost-other-base
             bf_gen-cli_trn-doc-sum.cost-other-rubl     = bf_gen-cli_trn-doc-sum.cost-other-rubl                      +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.cost-other-rubl         else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.cost-other-rubl
             bf_gen-cli_trn-doc-sum.cost-discnt-base    = bf_gen-cli_trn-doc-sum.cost-discnt-base                     +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.cost-discnt-base        else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.cost-discnt-base
             bf_gen-cli_trn-doc-sum.cost-discnt-rubl    = bf_gen-cli_trn-doc-sum.cost-discnt-rubl                     +
                            ( if p-mode = "update":U then bf_gen-cli_tt-doc-line-sum.cost-discnt-rubl        else 0 ) -
                                                          bf_gen-cli_tt-old-doc-line-sum.cost-discnt-rubl
      .
      if p-mode = "update":U then do:
        if bf_gen-cli_tt-doc-line-sum.cost-sum-rubl > 0 then do:
          assign bf_ext-cli_trn-doc-sum.cost-sum-base       = bf_ext-cli_trn-doc-sum.cost-sum-base           +
                                                              bf_gen-cli_tt-doc-line-sum.cost-sum-base
                 bf_ext-cli_trn-doc-sum.cost-sum-rubl       = bf_ext-cli_trn-doc-sum.cost-sum-rubl           +
                                                              bf_gen-cli_tt-doc-line-sum.cost-sum-rubl
                 bf_ext-cli_trn-doc-sum.cost-VAT-base       = bf_ext-cli_trn-doc-sum.cost-VAT-base           +
                                                              bf_gen-cli_tt-doc-line-sum.cost-VAT-base
                 bf_ext-cli_trn-doc-sum.cost-VAT-rubl       = bf_ext-cli_trn-doc-sum.cost-VAT-rubl           +
                                                              bf_gen-cli_tt-doc-line-sum.cost-VAT-rubl
                 bf_ext-cli_trn-doc-sum.cost-SLT-base       = bf_ext-cli_trn-doc-sum.cost-SLT-base           +
                                                              bf_gen-cli_tt-doc-line-sum.cost-SLT-base
                 bf_ext-cli_trn-doc-sum.cost-SLT-rubl       = bf_ext-cli_trn-doc-sum.cost-SLT-rubl           +
                                                              bf_gen-cli_tt-doc-line-sum.cost-SLT-rubl
                 bf_ext-cli_trn-doc-sum.cost-road-tax-base  = bf_ext-cli_trn-doc-sum.cost-road-tax-base      +
                                                              bf_gen-cli_tt-doc-line-sum.cost-road-tax-base
                 bf_ext-cli_trn-doc-sum.cost-road-tax-rubl  = bf_ext-cli_trn-doc-sum.cost-road-tax-rubl      +
                                                              bf_gen-cli_tt-doc-line-sum.cost-road-tax-rubl
                 bf_ext-cli_trn-doc-sum.cost-excise-base    = bf_ext-cli_trn-doc-sum.cost-excise-base        +
                                                              bf_gen-cli_tt-doc-line-sum.cost-excise-base
                 bf_ext-cli_trn-doc-sum.cost-excise-rubl    = bf_ext-cli_trn-doc-sum.cost-excise-rubl        +
                                                              bf_gen-cli_tt-doc-line-sum.cost-excise-rubl
                 bf_ext-cli_trn-doc-sum.cost-transport-base = bf_ext-cli_trn-doc-sum.cost-transport-base     +
                                                              bf_gen-cli_tt-doc-line-sum.cost-transport-base
                 bf_ext-cli_trn-doc-sum.cost-transport-rubl = bf_ext-cli_trn-doc-sum.cost-transport-rubl     +
                                                              bf_gen-cli_tt-doc-line-sum.cost-transport-rubl
                 bf_ext-cli_trn-doc-sum.cost-other-base     = bf_ext-cli_trn-doc-sum.cost-other-base         +
                                                              bf_gen-cli_tt-doc-line-sum.cost-other-base
                 bf_ext-cli_trn-doc-sum.cost-other-rubl     = bf_ext-cli_trn-doc-sum.cost-other-rubl         +
                                                              bf_gen-cli_tt-doc-line-sum.cost-other-rubl
                 bf_ext-cli_trn-doc-sum.cost-discnt-base    = bf_ext-cli_trn-doc-sum.cost-discnt-base        +
                                                              bf_gen-cli_tt-doc-line-sum.cost-discnt-base
                 bf_ext-cli_trn-doc-sum.cost-discnt-rubl    = bf_ext-cli_trn-doc-sum.cost-discnt-rubl        +
                                                              bf_gen-cli_tt-doc-line-sum.cost-discnt-rubl
          .
        end.
        else do:
          assign bf_mis-cli_trn-doc-sum.cost-sum-base       = bf_mis-cli_trn-doc-sum.cost-sum-base           -
                                                              bf_gen-cli_tt-doc-line-sum.cost-sum-base
                 bf_mis-cli_trn-doc-sum.cost-sum-rubl       = bf_mis-cli_trn-doc-sum.cost-sum-rubl           -
                                                              bf_gen-cli_tt-doc-line-sum.cost-sum-rubl
                 bf_mis-cli_trn-doc-sum.cost-VAT-base       = bf_mis-cli_trn-doc-sum.cost-VAT-base           -
                                                              bf_gen-cli_tt-doc-line-sum.cost-VAT-base
                 bf_mis-cli_trn-doc-sum.cost-VAT-rubl       = bf_mis-cli_trn-doc-sum.cost-VAT-rubl           -
                                                              bf_gen-cli_tt-doc-line-sum.cost-VAT-rubl
                 bf_mis-cli_trn-doc-sum.cost-SLT-base       = bf_mis-cli_trn-doc-sum.cost-SLT-base           -
                                                              bf_gen-cli_tt-doc-line-sum.cost-SLT-base
                 bf_mis-cli_trn-doc-sum.cost-SLT-rubl       = bf_mis-cli_trn-doc-sum.cost-SLT-rubl           -
                                                              bf_gen-cli_tt-doc-line-sum.cost-SLT-rubl
                 bf_mis-cli_trn-doc-sum.cost-road-tax-base  = bf_mis-cli_trn-doc-sum.cost-road-tax-base      -
                                                              bf_gen-cli_tt-doc-line-sum.cost-road-tax-base
                 bf_mis-cli_trn-doc-sum.cost-road-tax-rubl  = bf_mis-cli_trn-doc-sum.cost-road-tax-rubl      -
                                                              bf_gen-cli_tt-doc-line-sum.cost-road-tax-rubl
                 bf_mis-cli_trn-doc-sum.cost-excise-base    = bf_mis-cli_trn-doc-sum.cost-excise-base        -
                                                              bf_gen-cli_tt-doc-line-sum.cost-excise-base
                 bf_mis-cli_trn-doc-sum.cost-excise-rubl    = bf_mis-cli_trn-doc-sum.cost-excise-rubl        -
                                                              bf_gen-cli_tt-doc-line-sum.cost-excise-rubl
                 bf_mis-cli_trn-doc-sum.cost-transport-base = bf_mis-cli_trn-doc-sum.cost-transport-base     -
                                                              bf_gen-cli_tt-doc-line-sum.cost-transport-base
                 bf_mis-cli_trn-doc-sum.cost-transport-rubl = bf_mis-cli_trn-doc-sum.cost-transport-rubl     -
                                                              bf_gen-cli_tt-doc-line-sum.cost-transport-rubl
                 bf_mis-cli_trn-doc-sum.cost-other-base     = bf_mis-cli_trn-doc-sum.cost-other-base         -
                                                              bf_gen-cli_tt-doc-line-sum.cost-other-base
                 bf_mis-cli_trn-doc-sum.cost-other-rubl     = bf_mis-cli_trn-doc-sum.cost-other-rubl         -
                                                              bf_gen-cli_tt-doc-line-sum.cost-other-rubl
                 bf_mis-cli_trn-doc-sum.cost-discnt-base    = bf_mis-cli_trn-doc-sum.cost-discnt-base        -
                                                              bf_gen-cli_tt-doc-line-sum.cost-discnt-base
                 bf_mis-cli_trn-doc-sum.cost-discnt-rubl    = bf_mis-cli_trn-doc-sum.cost-discnt-rubl        -
                                                              bf_gen-cli_tt-doc-line-sum.cost-discnt-rubl
          .
        end.
      end. /* if p-mode = "update" */
      if bf_gen-cli_tt-old-doc-line-sum.cost-sum-rubl > 0 then do:
        assign bf_ext-cli_trn-doc-sum.cost-sum-base       = bf_ext-cli_trn-doc-sum.cost-sum-base               -
                                                            bf_gen-cli_tt-old-doc-line-sum.cost-sum-base
               bf_ext-cli_trn-doc-sum.cost-sum-rubl       = bf_ext-cli_trn-doc-sum.cost-sum-rubl               -
                                                            bf_gen-cli_tt-old-doc-line-sum.cost-sum-rubl
               bf_ext-cli_trn-doc-sum.cost-VAT-base       = bf_ext-cli_trn-doc-sum.cost-VAT-base               -
                                                            bf_gen-cli_tt-old-doc-line-sum.cost-VAT-base
               bf_ext-cli_trn-doc-sum.cost-VAT-rubl       = bf_ext-cli_trn-doc-sum.cost-VAT-rubl               -
                                                            bf_gen-cli_tt-old-doc-line-sum.cost-VAT-rubl
               bf_ext-cli_trn-doc-sum.cost-SLT-base       = bf_ext-cli_trn-doc-sum.cost-SLT-base               -
                                                            bf_gen-cli_tt-old-doc-line-sum.cost-SLT-base
               bf_ext-cli_trn-doc-sum.cost-SLT-rubl       = bf_ext-cli_trn-doc-sum.cost-SLT-rubl               -
                                                            bf_gen-cli_tt-old-doc-line-sum.cost-SLT-rubl
               bf_ext-cli_trn-doc-sum.cost-road-tax-base  = bf_ext-cli_trn-doc-sum.cost-road-tax-base          -
                                                            bf_gen-cli_tt-old-doc-line-sum.cost-road-tax-base
               bf_ext-cli_trn-doc-sum.cost-road-tax-rubl  = bf_ext-cli_trn-doc-sum.cost-road-tax-rubl          -
                                                            bf_gen-cli_tt-old-doc-line-sum.cost-road-tax-rubl
               bf_ext-cli_trn-doc-sum.cost-excise-base    = bf_ext-cli_trn-doc-sum.cost-excise-base            -
                                                            bf_gen-cli_tt-old-doc-line-sum.cost-excise-base
               bf_ext-cli_trn-doc-sum.cost-excise-rubl    = bf_ext-cli_trn-doc-sum.cost-excise-rubl            -
                                                            bf_gen-cli_tt-old-doc-line-sum.cost-excise-rubl
               bf_ext-cli_trn-doc-sum.cost-transport-base = bf_ext-cli_trn-doc-sum.cost-transport-base         -
                                                            bf_gen-cli_tt-old-doc-line-sum.cost-transport-base
               bf_ext-cli_trn-doc-sum.cost-transport-rubl = bf_ext-cli_trn-doc-sum.cost-transport-rubl         -
                                                            bf_gen-cli_tt-old-doc-line-sum.cost-transport-rubl
               bf_ext-cli_trn-doc-sum.cost-other-base     = bf_ext-cli_trn-doc-sum.cost-other-base             -
                                                            bf_gen-cli_tt-old-doc-line-sum.cost-other-base
               bf_ext-cli_trn-doc-sum.cost-other-rubl     = bf_ext-cli_trn-doc-sum.cost-other-rubl             -
                                                            bf_gen-cli_tt-old-doc-line-sum.cost-other-rubl
               bf_ext-cli_trn-doc-sum.cost-discnt-base    = bf_ext-cli_trn-doc-sum.cost-discnt-base            -
                                                            bf_gen-cli_tt-old-doc-line-sum.cost-discnt-base
               bf_ext-cli_trn-doc-sum.cost-discnt-rubl    = bf_ext-cli_trn-doc-sum.cost-discnt-rubl            -
                                                            bf_gen-cli_tt-old-doc-line-sum.cost-discnt-rubl
        .
      end.
      else do:
        assign bf_mis-cli_trn-doc-sum.cost-sum-base       = bf_mis-cli_trn-doc-sum.cost-sum-base               +
                                                            bf_gen-cli_tt-old-doc-line-sum.cost-sum-base
               bf_mis-cli_trn-doc-sum.cost-sum-rubl       = bf_mis-cli_trn-doc-sum.cost-sum-rubl               +
                                                            bf_gen-cli_tt-old-doc-line-sum.cost-sum-rubl
               bf_mis-cli_trn-doc-sum.cost-VAT-base       = bf_mis-cli_trn-doc-sum.cost-VAT-base               +
                                                            bf_gen-cli_tt-old-doc-line-sum.cost-VAT-base
               bf_mis-cli_trn-doc-sum.cost-VAT-rubl       = bf_mis-cli_trn-doc-sum.cost-VAT-rubl               +
                                                            bf_gen-cli_tt-old-doc-line-sum.cost-VAT-rubl
               bf_mis-cli_trn-doc-sum.cost-SLT-base       = bf_mis-cli_trn-doc-sum.cost-SLT-base               +
                                                            bf_gen-cli_tt-old-doc-line-sum.cost-SLT-base
               bf_mis-cli_trn-doc-sum.cost-SLT-rubl       = bf_mis-cli_trn-doc-sum.cost-SLT-rubl               +
                                                            bf_gen-cli_tt-old-doc-line-sum.cost-SLT-rubl
               bf_mis-cli_trn-doc-sum.cost-road-tax-base  = bf_mis-cli_trn-doc-sum.cost-road-tax-base          +
                                                            bf_gen-cli_tt-old-doc-line-sum.cost-road-tax-base
               bf_mis-cli_trn-doc-sum.cost-road-tax-rubl  = bf_mis-cli_trn-doc-sum.cost-road-tax-rubl          +
                                                            bf_gen-cli_tt-old-doc-line-sum.cost-road-tax-rubl
               bf_mis-cli_trn-doc-sum.cost-excise-base    = bf_mis-cli_trn-doc-sum.cost-excise-base            +
                                                            bf_gen-cli_tt-old-doc-line-sum.cost-excise-base
               bf_mis-cli_trn-doc-sum.cost-excise-rubl    = bf_mis-cli_trn-doc-sum.cost-excise-rubl            +
                                                            bf_gen-cli_tt-old-doc-line-sum.cost-excise-rubl
               bf_mis-cli_trn-doc-sum.cost-transport-base = bf_mis-cli_trn-doc-sum.cost-transport-base         +
                                                            bf_gen-cli_tt-old-doc-line-sum.cost-transport-base
               bf_mis-cli_trn-doc-sum.cost-transport-rubl = bf_mis-cli_trn-doc-sum.cost-transport-rubl         +
                                                            bf_gen-cli_tt-old-doc-line-sum.cost-transport-rubl
               bf_mis-cli_trn-doc-sum.cost-other-base     = bf_mis-cli_trn-doc-sum.cost-other-base             +
                                                            bf_gen-cli_tt-old-doc-line-sum.cost-other-base
               bf_mis-cli_trn-doc-sum.cost-other-rubl     = bf_mis-cli_trn-doc-sum.cost-other-rubl             +
                                                            bf_gen-cli_tt-old-doc-line-sum.cost-other-rubl
               bf_mis-cli_trn-doc-sum.cost-discnt-base    = bf_mis-cli_trn-doc-sum.cost-discnt-base            +
                                                            bf_gen-cli_tt-old-doc-line-sum.cost-discnt-base
               bf_mis-cli_trn-doc-sum.cost-discnt-rubl    = bf_mis-cli_trn-doc-sum.cost-discnt-rubl            +
                                                            bf_gen-cli_tt-old-doc-line-sum.cost-discnt-rubl
        .
      end.
    end.

    find first bf_aft_trn-doc-sum exclusive-lock where
               bf_aft_trn-doc-sum.doc-code = bf_doc-line.doc-code and
               bf_aft_trn-doc-sum.sum-type = {&sum-after-doc}     no-error.
    if not available bf_aft_trn-doc-sum then do:
      return error substitute( 'Ошибка при поиске суммы типа "&1" по документу "&2".'
                             , {&sum-after-doc}
                             , bf_doc-line.doc-code ).
    end.
    find first bf_aft_tt-old-doc-line-sum where
               bf_aft_tt-old-doc-line-sum.doc-code = bf_doc-line.doc-code and
               bf_aft_tt-old-doc-line-sum.gds-code = bf_goods.gds-code    and
               bf_aft_tt-old-doc-line-sum.sum-type = {&sum-after-doc}     no-error.
    if not available bf_aft_tt-old-doc-line-sum then do:
      return error substitute( 'Не найдена запись по временной таблице старых сумм по типу "&1" для товара &2 &3 &4 '
                             + 'по документу "&5".'
                             , {&sum-after-doc}
                             , bf_goods.artic
                             , bf_goods.prod-type
                             , bf_goods.prod-code
                             , bf_doc-line.doc-code ).
    end.
    if v_invclcsp = "yes" then do:
      find first bf_aft-cli_trn-doc-sum exclusive-lock where
                 bf_aft-cli_trn-doc-sum.doc-code = bf_doc-line.doc-code and
                 bf_aft-cli_trn-doc-sum.sum-type = {&sum-after-cli-doc} no-error.
      if not available bf_aft-cli_trn-doc-sum then do:
        return error substitute( 'Ошибка при поиске суммы типа "&1" по документу "&2".'
                               , {&sum-after-doc}
                               , bf_doc-line.doc-code ).
      end.
      find first bf_aft-cli_tt-old-doc-line-sum where
                 bf_aft-cli_tt-old-doc-line-sum.doc-code = bf_doc-line.doc-code and
                 bf_aft-cli_tt-old-doc-line-sum.gds-code = bf_goods.gds-code    and
                 bf_aft-cli_tt-old-doc-line-sum.sum-type = {&sum-after-cli-doc} no-error.
      if not available bf_aft-cli_tt-old-doc-line-sum then do:
        return error substitute( 'Не найдена запись по временной таблице старых сумм по типу "&1" для товара &2 &3 &4 '
                               + 'по документу "&5".'
                               , {&sum-after-cli-doc}
                               , bf_goods.artic
                               , bf_goods.prod-type
                               , bf_goods.prod-code
                               , bf_doc-line.doc-code ).
      end.
    end.

    if p-mode = "update":U then do:
      find first bf_aft_tt-doc-line-sum where
                 bf_aft_tt-doc-line-sum.doc-code = bf_doc-line.doc-code and
                 bf_aft_tt-doc-line-sum.gds-code = bf_goods.gds-code    and
                 bf_aft_tt-doc-line-sum.sum-type = {&sum-after-doc}     no-error.
      if not available bf_aft_tt-doc-line-sum then do:
        return error substitute( 'Не найдена запись по временной таблице новых сумм по типу "&1" для товара &2 &3 &4 '
                               + 'по документу &5.'
                               , {&sum-after-doc}
                               , bf_goods.artic
                               , bf_goods.prod-type
                               , bf_goods.prod-code
                               , bf_doc-line.doc-code ).
      end.
      if v_invclcsp = "yes" then do:
        find first bf_aft-cli_tt-doc-line-sum where
                   bf_aft-cli_tt-doc-line-sum.doc-code = bf_doc-line.doc-code and
                   bf_aft-cli_tt-doc-line-sum.gds-code = bf_goods.gds-code    and
                   bf_aft-cli_tt-doc-line-sum.sum-type = {&sum-after-cli-doc} no-error.
        if not available bf_aft-cli_tt-doc-line-sum then do:
          return error substitute( 'Не найдена запись по временной таблице новых сумм по типу "&1" для товара &2 &3 &4 '
                                 + 'по документу "&5".'
                                 , {&sum-after-cli-doc}
                                 , bf_goods.artic
                                 , bf_goods.prod-type
                                 , bf_goods.prod-code
                                 , bf_doc-line.doc-code ).
        end.
      end.
    end. /* if p-mode = "update" */

    assign bf_aft_trn-doc-sum.fact-qnty           = bf_aft_trn-doc-sum.fact-qnty                            +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.fact-qnty               else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.fact-qnty
           bf_aft_trn-doc-sum.sale-sum-base       = bf_aft_trn-doc-sum.sale-sum-base                        +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.sale-sum-base           else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.sale-sum-base
           bf_aft_trn-doc-sum.sale-sum-rubl       = bf_aft_trn-doc-sum.sale-sum-rubl                        +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.sale-sum-rubl           else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.sale-sum-rubl
           bf_aft_trn-doc-sum.sale-VAT-base       = bf_aft_trn-doc-sum.sale-VAT-base                        +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.sale-VAT-base           else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.sale-VAT-base
           bf_aft_trn-doc-sum.sale-VAT-rubl       = bf_aft_trn-doc-sum.sale-VAT-rubl                        +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.sale-VAT-rubl           else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.sale-VAT-rubl
           bf_aft_trn-doc-sum.sale-SLT-base       = bf_aft_trn-doc-sum.sale-SLT-base                        +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.sale-SLT-base           else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.sale-SLT-base
           bf_aft_trn-doc-sum.sale-SLT-rubl       = bf_aft_trn-doc-sum.sale-SLT-rubl                        +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.sale-SLT-rubl           else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.sale-SLT-rubl
           bf_aft_trn-doc-sum.sale-road-tax-base  = bf_aft_trn-doc-sum.sale-road-tax-base                   +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.sale-road-tax-base      else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.sale-road-tax-base
           bf_aft_trn-doc-sum.sale-road-tax-rubl  = bf_aft_trn-doc-sum.sale-road-tax-rubl                   +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.sale-road-tax-rubl      else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.sale-road-tax-rubl
           bf_aft_trn-doc-sum.sale-excise-base    = bf_aft_trn-doc-sum.sale-excise-base                     +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.sale-excise-base        else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.sale-excise-base
           bf_aft_trn-doc-sum.sale-excise-rubl    = bf_aft_trn-doc-sum.sale-excise-rubl                     +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.sale-excise-rubl        else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.sale-excise-rubl
           bf_aft_trn-doc-sum.sale-transport-base = bf_aft_trn-doc-sum.sale-transport-base                  +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.sale-transport-base     else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.sale-transport-base
           bf_aft_trn-doc-sum.sale-transport-rubl = bf_aft_trn-doc-sum.sale-transport-rubl                  +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.sale-transport-rubl     else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.sale-transport-rubl
           bf_aft_trn-doc-sum.sale-other-base     = bf_aft_trn-doc-sum.sale-other-base                      +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.sale-other-base         else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.sale-other-base
           bf_aft_trn-doc-sum.sale-other-rubl     = bf_aft_trn-doc-sum.sale-other-rubl                      +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.sale-other-rubl         else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.sale-other-rubl
           bf_aft_trn-doc-sum.sale-discnt-base    = bf_aft_trn-doc-sum.sale-discnt-base                     +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.sale-discnt-base        else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.sale-discnt-base
           bf_aft_trn-doc-sum.sale-discnt-rubl    = bf_aft_trn-doc-sum.sale-discnt-rubl                     +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.sale-discnt-rubl        else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.sale-discnt-rubl
    .
    assign bf_aft_trn-doc-sum.crsa-sum-base       = bf_aft_trn-doc-sum.crsa-sum-base                        +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.crsa-sum-base           else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.crsa-sum-base
           bf_aft_trn-doc-sum.crsa-sum-rubl       = bf_aft_trn-doc-sum.crsa-sum-rubl                        +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.crsa-sum-rubl           else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.crsa-sum-rubl
           bf_aft_trn-doc-sum.crsa-VAT-base       = bf_aft_trn-doc-sum.crsa-VAT-base                        +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.crsa-VAT-base           else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.crsa-VAT-base
           bf_aft_trn-doc-sum.crsa-VAT-rubl       = bf_aft_trn-doc-sum.crsa-VAT-rubl                        +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.crsa-VAT-rubl           else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.crsa-VAT-rubl
           bf_aft_trn-doc-sum.crsa-SLT-base       = bf_aft_trn-doc-sum.crsa-SLT-base                        +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.crsa-SLT-base           else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.crsa-SLT-base
           bf_aft_trn-doc-sum.crsa-SLT-rubl       = bf_aft_trn-doc-sum.crsa-SLT-rubl                        +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.crsa-SLT-rubl           else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.crsa-SLT-rubl
           bf_aft_trn-doc-sum.crsa-road-tax-base  = bf_aft_trn-doc-sum.crsa-road-tax-base                   +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.crsa-road-tax-base      else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.crsa-road-tax-base
           bf_aft_trn-doc-sum.crsa-road-tax-rubl  = bf_aft_trn-doc-sum.crsa-road-tax-rubl                   +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.crsa-road-tax-rubl      else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.crsa-road-tax-rubl
           bf_aft_trn-doc-sum.crsa-excise-base    = bf_aft_trn-doc-sum.crsa-excise-base                     +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.crsa-excise-base        else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.crsa-excise-base
           bf_aft_trn-doc-sum.crsa-excise-rubl    = bf_aft_trn-doc-sum.crsa-excise-rubl                     +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.crsa-excise-rubl        else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.crsa-excise-rubl
           bf_aft_trn-doc-sum.crsa-transport-base = bf_aft_trn-doc-sum.crsa-transport-base                  +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.crsa-transport-base     else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.crsa-transport-base
           bf_aft_trn-doc-sum.crsa-transport-rubl = bf_aft_trn-doc-sum.crsa-transport-rubl                  +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.crsa-transport-rubl     else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.crsa-transport-rubl
           bf_aft_trn-doc-sum.crsa-other-base     = bf_aft_trn-doc-sum.crsa-other-base                      +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.crsa-other-base         else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.crsa-other-base
           bf_aft_trn-doc-sum.crsa-other-rubl     = bf_aft_trn-doc-sum.crsa-other-rubl                      +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.crsa-other-rubl         else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.crsa-other-rubl
           bf_aft_trn-doc-sum.crsa-discnt-base    = bf_aft_trn-doc-sum.crsa-discnt-base                     +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.crsa-discnt-base        else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.crsa-discnt-base
           bf_aft_trn-doc-sum.crsa-discnt-rubl    = bf_aft_trn-doc-sum.crsa-discnt-rubl                     +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.crsa-discnt-rubl        else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.crsa-discnt-rubl
    .
    assign bf_aft_trn-doc-sum.cost-sum-base       = bf_aft_trn-doc-sum.cost-sum-base                        +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.cost-sum-base           else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.cost-sum-base
           bf_aft_trn-doc-sum.cost-sum-rubl       = bf_aft_trn-doc-sum.cost-sum-rubl                        +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.cost-sum-rubl           else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.cost-sum-rubl
           bf_aft_trn-doc-sum.cost-VAT-base       = bf_aft_trn-doc-sum.cost-VAT-base                        +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.cost-VAT-base           else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.cost-VAT-base
           bf_aft_trn-doc-sum.cost-VAT-rubl       = bf_aft_trn-doc-sum.cost-VAT-rubl                        +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.cost-VAT-rubl           else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.cost-VAT-rubl
           bf_aft_trn-doc-sum.cost-SLT-base       = bf_aft_trn-doc-sum.cost-SLT-base                        +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.cost-SLT-base           else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.cost-SLT-base
           bf_aft_trn-doc-sum.cost-SLT-rubl       = bf_aft_trn-doc-sum.cost-SLT-rubl                        +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.cost-SLT-rubl           else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.cost-SLT-rubl
           bf_aft_trn-doc-sum.cost-road-tax-base  = bf_aft_trn-doc-sum.cost-road-tax-base                   +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.cost-road-tax-base      else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.cost-road-tax-base
           bf_aft_trn-doc-sum.cost-road-tax-rubl  = bf_aft_trn-doc-sum.cost-road-tax-rubl                   +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.cost-road-tax-rubl      else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.cost-road-tax-rubl
           bf_aft_trn-doc-sum.cost-excise-base    = bf_aft_trn-doc-sum.cost-excise-base                     +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.cost-excise-base        else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.cost-excise-base
           bf_aft_trn-doc-sum.cost-excise-rubl    = bf_aft_trn-doc-sum.cost-excise-rubl                     +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.cost-excise-rubl        else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.cost-excise-rubl
           bf_aft_trn-doc-sum.cost-transport-base = bf_aft_trn-doc-sum.cost-transport-base                  +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.cost-transport-base     else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.cost-transport-base
           bf_aft_trn-doc-sum.cost-transport-rubl = bf_aft_trn-doc-sum.cost-transport-rubl                  +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.cost-transport-rubl     else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.cost-transport-rubl
           bf_aft_trn-doc-sum.cost-other-base     = bf_aft_trn-doc-sum.cost-other-base                      +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.cost-other-base         else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.cost-other-base
           bf_aft_trn-doc-sum.cost-other-rubl     = bf_aft_trn-doc-sum.cost-other-rubl                      +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.cost-other-rubl         else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.cost-other-rubl
           bf_aft_trn-doc-sum.cost-discnt-base    = bf_aft_trn-doc-sum.cost-discnt-base                     +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.cost-discnt-base        else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.cost-discnt-base
           bf_aft_trn-doc-sum.cost-discnt-rubl    = bf_aft_trn-doc-sum.cost-discnt-rubl                     +
                      ( if p-mode = "update":U then bf_aft_tt-doc-line-sum.cost-discnt-rubl        else 0 ) -
                                                    bf_aft_tt-old-doc-line-sum.cost-discnt-rubl
    .
    if v_invclcsp = "yes" then do:
      assign bf_aft-cli_trn-doc-sum.fact-qnty           = bf_aft-cli_trn-doc-sum.fact-qnty                            +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.fact-qnty               else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.fact-qnty
             bf_aft-cli_trn-doc-sum.sale-sum-base       = bf_aft-cli_trn-doc-sum.sale-sum-base                        +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.sale-sum-base           else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.sale-sum-base
             bf_aft-cli_trn-doc-sum.sale-sum-rubl       = bf_aft-cli_trn-doc-sum.sale-sum-rubl                        +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.sale-sum-rubl           else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.sale-sum-rubl
             bf_aft-cli_trn-doc-sum.sale-VAT-base       = bf_aft-cli_trn-doc-sum.sale-VAT-base                        +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.sale-VAT-base           else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.sale-VAT-base
             bf_aft-cli_trn-doc-sum.sale-VAT-rubl       = bf_aft-cli_trn-doc-sum.sale-VAT-rubl                        +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.sale-VAT-rubl           else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.sale-VAT-rubl
             bf_aft-cli_trn-doc-sum.sale-SLT-base       = bf_aft-cli_trn-doc-sum.sale-SLT-base                        +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.sale-SLT-base           else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.sale-SLT-base
             bf_aft-cli_trn-doc-sum.sale-SLT-rubl       = bf_aft-cli_trn-doc-sum.sale-SLT-rubl                        +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.sale-SLT-rubl           else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.sale-SLT-rubl
             bf_aft-cli_trn-doc-sum.sale-road-tax-base  = bf_aft-cli_trn-doc-sum.sale-road-tax-base                   +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.sale-road-tax-base      else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.sale-road-tax-base
             bf_aft-cli_trn-doc-sum.sale-road-tax-rubl  = bf_aft-cli_trn-doc-sum.sale-road-tax-rubl                   +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.sale-road-tax-rubl      else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.sale-road-tax-rubl
             bf_aft-cli_trn-doc-sum.sale-excise-base    = bf_aft-cli_trn-doc-sum.sale-excise-base                     +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.sale-excise-base        else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.sale-excise-base
             bf_aft-cli_trn-doc-sum.sale-excise-rubl    = bf_aft-cli_trn-doc-sum.sale-excise-rubl                     +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.sale-excise-rubl        else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.sale-excise-rubl
             bf_aft-cli_trn-doc-sum.sale-transport-base = bf_aft-cli_trn-doc-sum.sale-transport-base                  +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.sale-transport-base     else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.sale-transport-base
             bf_aft-cli_trn-doc-sum.sale-transport-rubl = bf_aft-cli_trn-doc-sum.sale-transport-rubl                  +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.sale-transport-rubl     else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.sale-transport-rubl
             bf_aft-cli_trn-doc-sum.sale-other-base     = bf_aft-cli_trn-doc-sum.sale-other-base                      +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.sale-other-base         else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.sale-other-base
             bf_aft-cli_trn-doc-sum.sale-other-rubl     = bf_aft-cli_trn-doc-sum.sale-other-rubl                      +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.sale-other-rubl         else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.sale-other-rubl
             bf_aft-cli_trn-doc-sum.sale-discnt-base    = bf_aft-cli_trn-doc-sum.sale-discnt-base                     +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.sale-discnt-base        else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.sale-discnt-base
             bf_aft-cli_trn-doc-sum.sale-discnt-rubl    = bf_aft-cli_trn-doc-sum.sale-discnt-rubl                     +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.sale-discnt-rubl        else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.sale-discnt-rubl
      .
      assign bf_aft-cli_trn-doc-sum.crsa-sum-base       = bf_aft-cli_trn-doc-sum.crsa-sum-base                        +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.crsa-sum-base           else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.crsa-sum-base
             bf_aft-cli_trn-doc-sum.crsa-sum-rubl       = bf_aft-cli_trn-doc-sum.crsa-sum-rubl                        +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.crsa-sum-rubl           else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.crsa-sum-rubl
             bf_aft-cli_trn-doc-sum.crsa-VAT-base       = bf_aft-cli_trn-doc-sum.crsa-VAT-base                        +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.crsa-VAT-base           else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.crsa-VAT-base
             bf_aft-cli_trn-doc-sum.crsa-VAT-rubl       = bf_aft-cli_trn-doc-sum.crsa-VAT-rubl                        +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.crsa-VAT-rubl           else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.crsa-VAT-rubl
             bf_aft-cli_trn-doc-sum.crsa-SLT-base       = bf_aft-cli_trn-doc-sum.crsa-SLT-base                        +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.crsa-SLT-base           else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.crsa-SLT-base
             bf_aft-cli_trn-doc-sum.crsa-SLT-rubl       = bf_aft-cli_trn-doc-sum.crsa-SLT-rubl                        +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.crsa-SLT-rubl           else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.crsa-SLT-rubl
             bf_aft-cli_trn-doc-sum.crsa-road-tax-base  = bf_aft-cli_trn-doc-sum.crsa-road-tax-base                   +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.crsa-road-tax-base      else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.crsa-road-tax-base
             bf_aft-cli_trn-doc-sum.crsa-road-tax-rubl  = bf_aft-cli_trn-doc-sum.crsa-road-tax-rubl                   +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.crsa-road-tax-rubl      else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.crsa-road-tax-rubl
             bf_aft-cli_trn-doc-sum.crsa-excise-base    = bf_aft-cli_trn-doc-sum.crsa-excise-base                     +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.crsa-excise-base        else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.crsa-excise-base
             bf_aft-cli_trn-doc-sum.crsa-excise-rubl    = bf_aft-cli_trn-doc-sum.crsa-excise-rubl                     +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.crsa-excise-rubl        else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.crsa-excise-rubl
             bf_aft-cli_trn-doc-sum.crsa-transport-base = bf_aft-cli_trn-doc-sum.crsa-transport-base                  +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.crsa-transport-base     else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.crsa-transport-base
             bf_aft-cli_trn-doc-sum.crsa-transport-rubl = bf_aft-cli_trn-doc-sum.crsa-transport-rubl                  +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.crsa-transport-rubl     else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.crsa-transport-rubl
             bf_aft-cli_trn-doc-sum.crsa-other-base     = bf_aft-cli_trn-doc-sum.crsa-other-base                      +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.crsa-other-base         else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.crsa-other-base
             bf_aft-cli_trn-doc-sum.crsa-other-rubl     = bf_aft-cli_trn-doc-sum.crsa-other-rubl                      +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.crsa-other-rubl         else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.crsa-other-rubl
             bf_aft-cli_trn-doc-sum.crsa-discnt-base    = bf_aft-cli_trn-doc-sum.crsa-discnt-base                     +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.crsa-discnt-base        else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.crsa-discnt-base
             bf_aft-cli_trn-doc-sum.crsa-discnt-rubl    = bf_aft-cli_trn-doc-sum.crsa-discnt-rubl                     +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.crsa-discnt-rubl        else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.crsa-discnt-rubl
      .
      assign bf_aft-cli_trn-doc-sum.cost-sum-base       = bf_aft-cli_trn-doc-sum.cost-sum-base                        +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.cost-sum-base           else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.cost-sum-base
             bf_aft-cli_trn-doc-sum.cost-sum-rubl       = bf_aft-cli_trn-doc-sum.cost-sum-rubl                        +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.cost-sum-rubl           else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.cost-sum-rubl
             bf_aft-cli_trn-doc-sum.cost-VAT-base       = bf_aft-cli_trn-doc-sum.cost-VAT-base                        +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.cost-VAT-base           else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.cost-VAT-base
             bf_aft-cli_trn-doc-sum.cost-VAT-rubl       = bf_aft-cli_trn-doc-sum.cost-VAT-rubl                        +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.cost-VAT-rubl           else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.cost-VAT-rubl
             bf_aft-cli_trn-doc-sum.cost-SLT-base       = bf_aft-cli_trn-doc-sum.cost-SLT-base                        +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.cost-SLT-base           else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.cost-SLT-base
             bf_aft-cli_trn-doc-sum.cost-SLT-rubl       = bf_aft-cli_trn-doc-sum.cost-SLT-rubl                        +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.cost-SLT-rubl           else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.cost-SLT-rubl
             bf_aft-cli_trn-doc-sum.cost-road-tax-base  = bf_aft-cli_trn-doc-sum.cost-road-tax-base                   +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.cost-road-tax-base      else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.cost-road-tax-base
             bf_aft-cli_trn-doc-sum.cost-road-tax-rubl  = bf_aft-cli_trn-doc-sum.cost-road-tax-rubl                   +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.cost-road-tax-rubl      else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.cost-road-tax-rubl
             bf_aft-cli_trn-doc-sum.cost-excise-base    = bf_aft-cli_trn-doc-sum.cost-excise-base                     +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.cost-excise-base        else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.cost-excise-base
             bf_aft-cli_trn-doc-sum.cost-excise-rubl    = bf_aft-cli_trn-doc-sum.cost-excise-rubl                     +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.cost-excise-rubl        else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.cost-excise-rubl
             bf_aft-cli_trn-doc-sum.cost-transport-base = bf_aft-cli_trn-doc-sum.cost-transport-base                  +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.cost-transport-base     else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.cost-transport-base
             bf_aft-cli_trn-doc-sum.cost-transport-rubl = bf_aft-cli_trn-doc-sum.cost-transport-rubl                  +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.cost-transport-rubl     else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.cost-transport-rubl
             bf_aft-cli_trn-doc-sum.cost-other-base     = bf_aft-cli_trn-doc-sum.cost-other-base                      +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.cost-other-base         else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.cost-other-base
             bf_aft-cli_trn-doc-sum.cost-other-rubl     = bf_aft-cli_trn-doc-sum.cost-other-rubl                      +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.cost-other-rubl         else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.cost-other-rubl
             bf_aft-cli_trn-doc-sum.cost-discnt-base    = bf_aft-cli_trn-doc-sum.cost-discnt-base                     +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.cost-discnt-base        else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.cost-discnt-base
             bf_aft-cli_trn-doc-sum.cost-discnt-rubl    = bf_aft-cli_trn-doc-sum.cost-discnt-rubl                     +
                            ( if p-mode = "update":U then bf_aft-cli_tt-doc-line-sum.cost-discnt-rubl        else 0 ) -
                                                          bf_aft-cli_tt-old-doc-line-sum.cost-discnt-rubl
      .
    end. /* if v_invclcsp = "yes" */
  end. /* on error */
end procedure. /* lib-rwds_updtrsum */

/* Пересчет всех сумм на факт, либо по требованию */
procedure lib-rwds_rcallfct :
  define input        parameter           p-doc-code    like ub.trn-doc.doc-code no-undo.
  define input        parameter           p-calc-wast   as   logical             no-undo.
  define input        parameter           p-calc-addsum as   logical             no-undo.
  define input        parameter           p-rwdshandle  as   handle              no-undo.
  define input-output parameter table for tt-wast-line.
  define input-output parameter table for tt-allsum-line.
  define input-output parameter table for tt-doc-line-sum.
  define input-output parameter table for tt-clcparts.
  define input-output parameter table for temp-parts.
  define variable v_attr-value as character no-undo.
  define variable v_type       as character no-undo.
  define variable v_wastage    as character no-undo.
  define variable v_invclcsp   as character no-undo.
  define variable v_data-type  as character no-undo.
  define variable jj_count     as integer   no-undo.
  define variable j#time       as integer   no-undo.
  define variable v_message    as character no-undo.

  define buffer bf_trn-doc      for ub.trn-doc.
  define buffer bf_doc-line     for ub.doc-line.
  define buffer bf_goods        for ub.goods.
  define buffer bf_trn-doc-sum  for ub.trn-doc-sum.
  define buffer bf_doc-line-sum for ub.doc-line-sum.

  do transaction on error undo, return error return-value :
    assign j#time = time.

    if not valid-handle( p-rwdshandle ) then do:
      assign p-rwdshandle = this-procedure :handle.
    end.

    find first bf_trn-doc where
               bf_trn-doc.doc-code = p-doc-code no-error.
    if not available bf_trn-doc then do:
      return error substitute( 'Не найден документ с номером "&1".', p-doc-code ).
    end.
    { gbl/getsect.i run bf_trn-doc.obj-type bf_trn-doc.obj-code {&attr-inv-obj} }
    for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = 'invclcsp'  then v_invclcsp = string( thbjattr_thbj-attr.property-value-logical, "yes/no").
        if thbjattr_thbj-attr.prop-code = 'wastage'   then v_wastage  = string( thbjattr_thbj-attr.property-value-logical, "yes/no").
    end.
    empty temp-table thbjattr_thbj-attr.
    { str/tdat-val.i bf_trn-doc.doc-code
                 {&trdcattr-addsum}
                 v_attr-value
                 v_type              no-error }
    if error-status :error then do:
      return error substitute( 'Ошибка при вызове процедуры tdat-value&3&1&3&2.',
                               return-value, error-status :get-message( 1 ), {&new-line} ).
    end.
    if v_wastage   = "yes" and
       p-calc-wast =  yes  then do:
      if lookup( {&sum-wastage-doc}, v_attr-value ) = 0 then do:
        find first bf_trn-doc-sum where
                   bf_trn-doc-sum.doc-code = bf_trn-doc.doc-code and
                   bf_trn-doc-sum.sum-type = {&sum-wastage-doc}  no-error.
        if not available bf_trn-doc-sum then do:
          run waitfram-show in p-rwdshandle ( input substitute( 'Создаем запись для сумм типа "&1". Время: &2.'
                                                              , {&sum-wastage-doc}
                                                              , string( time - j#time, "hh:mm:ss":U ) ) ) no-error.
          run lib-rwds_crtrnsum in this-procedure ( input bf_trn-doc.doc-code
                                                  , input {&sum-wastage-doc}  ) no-error.
          if error-status :error then do:
            run waitfram-hide in p-rwdshandle no-error.
            undo, return error substitute(
              'Ошибка &1 &2 на вызове программы lib-rwds_crtrnsum при расчете естественной убыли по документу "&3".',
              return-value, error-status :get-message( 1 ), bf_trn-doc.doc-code ).
          end.
          assign jj_count = 0.
          for each bf_doc-line where
                   bf_doc-line.doc-code = bf_trn-doc.doc-code
          on error undo, return error return-value :
            assign jj_count = jj_count + 1.
            run waitfram-join in p-rwdshandle (  input substitute( 'Создаем записи строк сумм типа "&1".'
                                                                 , {&sum-wastage-doc} )
                                              ,  input substitute( 'Обработано строк: &1', jj_count )
                                              ,  input substitute( 'Время &1.', string( time - j#time, "hh:mm:ss":U ) )
                                              , output v_message ).
            run waitfram-show in p-rwdshandle (  input v_message ) no-error.
            run lib-rwds_crlinsum in this-procedure ( input bf_doc-line.doc-code
                                                    , input {&sum-wastage-doc}
                                                    , input bf_doc-line.artic
                                                    , input bf_doc-line.prod-type
                                                    , input bf_doc-line.prod-code ) no-error.
            if error-status :error then do:
              run waitfram-hide in p-rwdshandle no-error.
              undo, return error return-value.
            end.
          end. /* for each bf_doc-line */
        end. /* if not available bf_trn-doc-sum */
        else do: /* if available bf_trn-doc-sum */
          run waitfram-show in p-rwdshandle ( input substitute( 'Очищаем запись для сумм типа "&1". Время &2.'
                                                              , {&sum-wastage-doc}
                                                              , string( time - j#time, "hh:mm:ss":U ) ) ) no-error.
          run lib-rwds_cltrnsum in this-procedure ( input bf_trn-doc.doc-code
                                                  , input {&sum-wastage-doc}  ) no-error.
          if error-status :error then do:
            run waitfram-hide in p-rwdshandle no-error.
            undo, return error substitute(
              'Ошибка &1 &2 на вызове программы lib-rwds_cltrnsum при расчете естественной убыли по документу &3.',
              return-value, error-status :get-message( 1 ), bf_trn-doc.doc-code ).
          end.
          run waitfram-show in p-rwdshandle ( input substitute( 'Запись атрибута для сумм типа "&1". Время &2.'
                                                              , {&sum-wastage-doc}
                                                              , string( time - j#time, "hh:mm:ss":U ) ) ) no-error.
          assign v_attr-value = v_attr-value + min( v_attr-value, ',' ) + {&sum-wastage-doc}.
          { str/tdat-wrt.i bf_trn-doc.doc-code
                       {&trdcattr-addsum}
                       v_attr-value        no-error }
          if error-status :error then do:
            run waitfram-hide in p-rwdshandle no-error.
            undo, return error substitute(
              'Ошибка &1 &2 на вызове программы tdat-wrt при расчете естественной убыли по документу "&3".',
              return-value, error-status :get-message( 1 ), bf_trn-doc.doc-code ).
          end.
        end. /* if available bf_trn-doc-sum */
      end. /* if lookup( {&sum-wastage-doc}, v_attr-value ) = 0 */
      if lookup( {&sum-wastage-cli-doc}, v_attr-value ) = 0 then do:
        if v_invclcsp = "yes" then do:
          find first bf_trn-doc-sum where
                     bf_trn-doc-sum.doc-code = bf_trn-doc.doc-code    and
                     bf_trn-doc-sum.sum-type = {&sum-wastage-cli-doc} no-error.
          if not available bf_trn-doc-sum then do:
            run waitfram-show in p-rwdshandle ( input substitute( 'Создаем запись для сумм типа "&1". Время &2.'
                                                                , {&sum-wastage-cli-doc}
                                                                , string( time - j#time, "hh:mm:ss":U ) ) ) no-error.
            run lib-rwds_crtrnsum in this-procedure ( input bf_trn-doc.doc-code
                                                    , input {&sum-wastage-cli-doc} ) no-error.
            if error-status :error then do:
              run waitfram-hide in p-rwdshandle no-error.
              undo, return error substitute(
                'Ошибка &1 &2 на вызове программы lib-rwds_crtrnsum при расчете естественной убыли по документу "&3".',
                return-value, error-status :get-message( 1 ), bf_trn-doc.doc-code ).
            end.
            assign jj_count = 0.
            for each bf_doc-line where
                     bf_doc-line.doc-code = bf_trn-doc.doc-code
            on error undo, return error return-value :
              assign jj_count = jj_count + 1.
              run waitfram-join in p-rwdshandle (  input substitute( 'Создаем записи строк сумм типа "&1".'
                                                                   , {&sum-wastage-cli-doc} )
                                                ,  input substitute( 'Обработано строк: &1', jj_count)
                                                ,  input substitute( 'Время &1.', string( time - j#time, "hh:mm:ss":U ) )
                                                , output v_message ).
              run waitfram-show in p-rwdshandle (  input v_message ) no-error.
              run lib-rwds_crlinsum in this-procedure ( input bf_doc-line.doc-code
                                                      , input {&sum-wastage-cli-doc}
                                                      , input bf_doc-line.artic
                                                      , input bf_doc-line.prod-type
                                                      , input bf_doc-line.prod-code ) no-error.
              if error-status :error then do:
                run waitfram-hide in p-rwdshandle no-error.
                undo, return error return-value.
              end.
            end. /* for each bf_doc-line */
          end. /* if not available bf_trn-doc-sum */
          else do: /* if available bf_trn-doc-sum */
            run waitfram-show in p-rwdshandle ( input substitute( 'Очищаем запись для сумм типа "&1". Время &2.'
                                                                , {&sum-wastage-cli-doc}
                                                                , string( time - j#time, "hh:mm:ss":U ) ) ) no-error.
            run lib-rwds_cltrnsum in this-procedure ( input bf_trn-doc.doc-code
                                                    , input {&sum-wastage-cli-doc} ) no-error.
            if error-status :error then do:
              run waitfram-hide in p-rwdshandle no-error.
              undo, return error substitute(
                'Ошибка &1 &2 на вызове программы lib-rwds_cltrnsum при расчете естественной убыли по документу "&3".',
                return-value, error-status :get-message( 1 ), bf_trn-doc.doc-code ).
            end.
            run waitfram-show in p-rwdshandle ( input substitute( 'Запись атрибута для сумм типа "&1". Время &2.'
                                                                , {&sum-wastage-cli-doc}
                                                                , string( time - j#time, "hh:mm:ss":U ) ) ) no-error.
            assign v_attr-value = v_attr-value + min( v_attr-value, ',' ) + {&sum-wastage-cli-doc}.
            { str/tdat-wrt.i bf_trn-doc.doc-code
                         {&trdcattr-addsum}
                         v_attr-value        no-error }
            if error-status :error then do:
              run waitfram-hide in p-rwdshandle no-error.
              undo, return error substitute(
                'Ошибка &1 &2 на вызове программы tdat-wrt при расчете естественной убыли по документу "&3".',
                return-value, error-status :get-message( 1 ), bf_trn-doc.doc-code ).
            end.
          end. /* if available bf_trn-doc-sum */
        end. /* if v_invclcsp = "yes" */
      end. /* if lookup( {&sum-wastage-cli-doc}, v_attr-value ) = 0 */
      if lookup( {&sum-wastage-doc},     v_attr-value ) = 0 or
         lookup( {&sum-wastage-cli-doc}, v_attr-value ) = 0 then do:
        run waitfram-show in p-rwdshandle ( input "Расчет сумм естественной убыли." ) no-error.
        run lib-rwds_ccwstsum in this-procedure ( input              bf_trn-doc.doc-code
                                                , input              p-rwdshandle
                                                , input-output table tt-wast-line        ) no-error.
        if error-status :error then do:
          run waitfram-hide in p-rwdshandle no-error.
          undo, return error substitute( 'Ошибка при вызове процедуры lib-rwds_ccwstsum &1 &2',
                                         return-value, error-status :get-message( 1 ) ).
        end.
        run waitfram-show in p-rwdshandle ( input substitute( 'Запись сумм типа "&1". Время &2.'
                                                            , {&sum-wastage-doc}
                                                            , string( time - j#time, "hh:mm:ss":U ) ) ) no-error.
        { str/reclctsl.i bf_trn-doc.doc-code
                     {&sum-wastage-doc}  no-error }
        if error-status :error then do:
          run waitfram-hide in p-rwdshandle no-error.
          undo, return error substitute(
            'Ошибка &1 &2 на вызове программы str/reclctsl.i при расчете естественной убыли по документу "&3".',
            return-value, error-status :get-message( 1 ), bf_trn-doc.doc-code ).
        end.
        if v_invclcsp = "yes" then do:
          run waitfram-show in p-rwdshandle ( input substitute( 'Запись сумм типа "&1". Время &2.'
                                                              , {&sum-wastage-cli-doc}
                                                              , string( time - j#time, "hh:mm:ss":U ) ) ) no-error.
          { str/reclctsl.i bf_trn-doc.doc-code
                       {&sum-wastage-cli-doc} no-error }
          if error-status :error then do:
            run waitfram-hide in p-rwdshandle no-error.
            undo, return error substitute(
              'Ошибка &1 &2 на вызове программы str/reclctsl.i при расчете естественной убыли по документу "&3".',
              return-value, error-status :get-message( 1 ), bf_trn-doc.doc-code ).
          end.
        end. /* if v_invclcsp = "yes" */
      end. /* if lookup( {&sum-wastage-doc}, v_attr-value ) = 0 */
    end. /* if v_wastage = "yes" */

    if p-calc-addsum = yes then do:
      if lookup( {&sum-general-doc}, v_attr-value ) =  0 then do:
        if lookup( {&sum-after-doc}, v_attr-value ) <> 0 then do:
          run waitfram-hide in p-rwdshandle no-error.
          undo, return error substitute(
            'Критическая ошибка в документе "&1". Посчитаны суммы после документа и не посчитаны суммы по документу.',
            bf_trn-doc.doc-code ).
        end.
        find first bf_trn-doc-sum where
                   bf_trn-doc-sum.doc-code = bf_trn-doc.doc-code and
                   bf_trn-doc-sum.sum-type = {&sum-general-doc}  no-error.
        if not available bf_trn-doc-sum then do:
          run waitfram-show in p-rwdshandle ( input substitute( 'Создаем запись для сумм типа "&1". Время &2.'
                                                              , {&sum-general-doc}
                                                              , string( time - j#time, "hh:mm:ss":U ) ) ) no-error.
          run lib-rwds_crtrnsum in this-procedure ( input bf_trn-doc.doc-code
                                                  , input {&sum-general-doc}  ) no-error.
          if error-status :error then do:
            run waitfram-hide in p-rwdshandle no-error.
            undo, return error substitute(
              'Ошибка при вызове процедуры lib-rwds_crtrnsum &1 &2 документ "&3"',
              return-value, error-status :get-message( 1 ), bf_trn-doc.doc-code ).
          end.
          run waitfram-show in p-rwdshandle ( input substitute( 'Создаем запись для сумм типа &1. Время &2.'
                                                              , {&sum-extra-doc}
                                                              , string( time - j#time, "hh:mm:ss":U ) ) ) no-error.
          run lib-rwds_crtrnsum in this-procedure ( input bf_trn-doc.doc-code
                                                  , input {&sum-extra-doc}    ) no-error.
          if error-status :error then do:
            run waitfram-hide in p-rwdshandle no-error.
            undo, return error substitute( 'Ошибка при вызове процедуры lib-rwds_crtrnsum &1 &2 документ "&3"',
                                           return-value, error-status :get-message( 1 ), bf_trn-doc.doc-code ).
          end.
          run waitfram-show in p-rwdshandle ( input substitute( 'Создаем запись для сумм типа "&1". Время &2.'
                                                              , {&sum-miss-doc}
                                                              , string( time - j#time, "hh:mm:ss":U ) ) ) no-error.
          run lib-rwds_crtrnsum in this-procedure ( input bf_trn-doc.doc-code
                                                  , input {&sum-miss-doc}     ) no-error.
          if error-status :error then do:
            run waitfram-hide in p-rwdshandle no-error.
            undo, return error substitute( 'Ошибка при вызове процедуры lib-rwds_crtrnsum &1 &2 документ "&3"',
                                           return-value, error-status :get-message( 1 ), bf_trn-doc.doc-code ).
          end.
        end. /* if not available bf_trn-doc-sum */
        else do: /* if available bf_trn-doc-sum */
          run waitfram-show in p-rwdshandle ( input substitute( 'Очищаем запись для сумм типа "&1". Время &2.'
                                                              , {&sum-general-doc}
                                                              , string( time - j#time, "hh:mm:ss":U ) ) ) no-error.
          run lib-rwds_cltrnsum in this-procedure ( input bf_trn-doc.doc-code
                                                  , input {&sum-general-doc}  ) no-error.
          if error-status :error then do:
            run waitfram-hide in p-rwdshandle no-error.
            undo, return error substitute( 'Ошибка при вызове процедуры lib-rwds_cltrnsum &1 &2 документ "&3"',
                                           return-value, error-status :get-message( 1 ), bf_trn-doc.doc-code ).
          end.
          run waitfram-show in p-rwdshandle ( input substitute( 'Очищаем запись для сумм типа "&1". Время &2.'
                                                              , {&sum-extra-doc}
                                                              , string( time - j#time, "hh:mm:ss":U ) ) ) no-error.
          run lib-rwds_cltrnsum in this-procedure ( input bf_trn-doc.doc-code
                                                  , input {&sum-extra-doc}    ) no-error.
          if error-status :error then do:
            run waitfram-hide in p-rwdshandle no-error.
            undo, return error substitute( 'Ошибка при вызове процедуры lib-rwds_cltrnsum &1 &2 документ "&3"',
                                           return-value, error-status :get-message( 1 ), bf_trn-doc.doc-code ).
          end.
          run waitfram-show in p-rwdshandle ( input substitute( 'Очищаем запись для сумм типа "&1". Время &2.'
                                                              , {&sum-miss-doc}
                                                              , string( time - j#time, "hh:mm:ss":U ) ) ) no-error.
          run lib-rwds_cltrnsum in this-procedure ( input bf_trn-doc.doc-code
                                                  , input {&sum-miss-doc}     ) no-error.
          if error-status :error then do:
            run waitfram-hide in p-rwdshandle no-error.
            undo, return error substitute( 'Ошибка при вызове процедуры lib-rwds_cltrnsum &1 &2 документ "&3"',
                                           return-value, error-status :get-message( 1 ), bf_trn-doc.doc-code ).
          end.
          run waitfram-show in p-rwdshandle ( input substitute( 'Записываем атрибут для сумм типа "&1". Время &2.'
                                                              , {&sum-general-doc}
                                                              , string( time - j#time, "hh:mm:ss":U ) ) ) no-error.
          assign v_attr-value = v_attr-value + min( v_attr-value, ',' ) + {&sum-general-doc} +
                                                                  ','   + {&sum-extra-doc}   +
                                                                  ','   + {&sum-miss-doc}.
          { str/tdat-wrt.i bf_trn-doc.doc-code
                       {&trdcattr-addsum}
                       v_attr-value        no-error }
          if error-status :error then do:
            run waitfram-hide in p-rwdshandle no-error.
            undo, return error substitute(
              'Ошибка &1 &2 на вызове программы tdat-wrt при расчете естественной убыли по документу "&3".',
              return-value, error-status :get-message( 1 ), bf_trn-doc.doc-code ).
          end.
        end. /* if available bf_trn-doc-sum */

        assign jj_count = 0.
        for each bf_doc-line where
                 bf_doc-line.doc-code = bf_trn-doc.doc-code
        on error undo, return error return-value :
          find first bf_goods no-lock where
                     bf_goods.artic     = bf_doc-line.artic     and
                     bf_goods.prod-type = bf_doc-line.prod-type and
                     bf_goods.prod-code = bf_doc-line.prod-code .
          assign jj_count = jj_count + 1.
          find first bf_doc-line-sum where
                     bf_doc-line-sum.doc-code = bf_doc-line.doc-code and
                     bf_doc-line-sum.gds-code = bf_goods.gds-code    and
                     bf_doc-line-sum.sum-type = {&sum-general-doc}   no-error.
          if not available bf_doc-line-sum then do:
            run lib-rwds_crlinsum in this-procedure ( input bf_doc-line.doc-code
                                                    , input {&sum-general-doc}
                                                    , input bf_doc-line.artic
                                                    , input bf_doc-line.prod-type
                                                    , input bf_doc-line.prod-code ) no-error.
            if error-status :error then do:
              run waitfram-hide in p-rwdshandle no-error.
              undo, return error substitute(
                'Ошибка при вызове процедуры lib-rwds_crlinsum &1 &2 документ "&3" товар &4 &5 &6',
                return-value,
                error-status :get-message( 1 ),
                bf_trn-doc.doc-code,
                bf_doc-line.artic,
                bf_doc-line.prod-type,
                bf_doc-line.prod-code ).
            end.
          end.
          run waitfram-join in p-rwdshandle (  input substitute( 'Расчитываем записи строк сумм типа "&1".'
                                                               , {&sum-general-doc} )
                                            ,  input substitute( 'Обработано строк: &1', jj_count )
                                            ,  input substitute( 'Время &1.', string( time - j#time, "hh:mm:ss":U ) )
                                            , output v_message ).
          run waitfram-show in p-rwdshandle (  input v_message ) no-error.
          run lib-rwds_cctrnsum in this-procedure ( input              bf_doc-line.doc-code
                                                  , input              bf_doc-line.artic
                                                  , input              bf_doc-line.prod-type
                                                  , input              bf_doc-line.prod-code
                                                  , input              {&sum-general-doc}
                                                  , input-output table tt-allsum-line
                                                  , input-output table tt-doc-line-sum
                                                  , input-output table tt-clcparts
                                                  , input-output table temp-parts            ) no-error.
          if error-status :error then do:
            run waitfram-hide in p-rwdshandle no-error.
            undo, return error substitute(
              'Ошибка при вызове процедуры lib-rwds_cctrnsum &1 &2 документ "&3" товар &4 &5 &6',
              return-value,
              error-status :get-message( 1 ),
              bf_trn-doc.doc-code,
              bf_doc-line.artic,
              bf_doc-line.prod-type,
              bf_doc-line.prod-code ).
          end.
        end. /* for each bf_doc-line */
        run waitfram-show in p-rwdshandle ( input substitute( 'Запись сумм типа "&1". Время &2.'
                                                            , {&sum-general-doc}
                                                            , string( time - j#time, "hh:mm:ss":U ) ) ) no-error.
        { str/reclctsl.i bf_trn-doc.doc-code
                     {&sum-general-doc}  no-error }
        if error-status :error then do:
          run waitfram-hide in p-rwdshandle no-error.
          undo, return error return-value.
        end.
      end. /* if lookup( {&sum-general-doc}, v_attr-value ) = 0 */

      if v_invclcsp = "yes" then do:
        if lookup( {&sum-general-cli-doc}, v_attr-value ) =  0 then do:
          if lookup( {&sum-after-cli-doc}, v_attr-value ) <> 0 then do:
            return error substitute( 'Критическая ошибка в документе "&1". Посчитаны суммы после документа ' +
                                     'в единицах поставщика и не посчитаны суммы по документу в единицах поставщика.'
                                   , bf_trn-doc.doc-code ).
          end.
          find first bf_trn-doc-sum where
                     bf_trn-doc-sum.doc-code = bf_trn-doc.doc-code    and
                     bf_trn-doc-sum.sum-type = {&sum-general-cli-doc} no-error.
          if not available bf_trn-doc-sum then do:
            run waitfram-show in p-rwdshandle ( input substitute( 'Создаем запись для сумм типа "&1". Время &2.'
                                                                , {&sum-general-cli-doc}
                                                                , string( time - j#time, "hh:mm:ss":U ) ) ) no-error.
            run lib-rwds_crtrnsum in this-procedure ( input bf_trn-doc.doc-code
                                                    , input {&sum-general-cli-doc} ) no-error.
            if error-status :error then do:
              run waitfram-hide in p-rwdshandle no-error.
              undo, return error substitute( 'Ошибка при вызове процедуры lib-rwds_crtrnsum &1 &2 документ "&3".',
                                             return-value, error-status :get-message( 1 ), bf_trn-doc.doc-code ).
            end.
            run waitfram-show in p-rwdshandle ( input substitute( 'Создаем запись для сумм типа "&1". Время &2.'
                                                                , {&sum-extra-cli-doc}
                                                                , string( time - j#time, "hh:mm:ss":U ) ) ) no-error.
            run lib-rwds_crtrnsum in this-procedure ( input bf_trn-doc.doc-code
                                                    , input {&sum-extra-cli-doc} ) no-error.
            if error-status :error then do:
              run waitfram-hide in p-rwdshandle no-error.
              undo, return error substitute( 'Ошибка при вызове процедуры lib-rwds_crtrnsum &1 &2 документ "&3".',
                                             return-value, error-status :get-message( 1 ), bf_trn-doc.doc-code ).
            end.
            run waitfram-show in p-rwdshandle ( input substitute( 'Создаем запись для сумм типа "&1". Время &2.'
                                                                , {&sum-miss-cli-doc}
                                                                , string( time - j#time, "hh:mm:ss":U ) ) ) no-error.
            run lib-rwds_crtrnsum in this-procedure ( input bf_trn-doc.doc-code
                                                    , input {&sum-miss-cli-doc} ) no-error.
            if error-status :error then do:
              run waitfram-hide in p-rwdshandle no-error.
              undo, return error substitute( 'Ошибка при вызове процедуры lib-rwds_crtrnsum &1 &2 документ "&3".',
                                             return-value, error-status :get-message( 1 ), bf_trn-doc.doc-code ).
            end.
          end. /* if not available bf_trn-doc-sum */
          else do: /* if available bf_trn-doc-sum */
            run waitfram-show in p-rwdshandle ( input substitute( 'Очищаем запись для сумм типа "&1". Время &2.'
                                                                , {&sum-general-cli-doc}
                                                                , string( time - j#time, "hh:mm:ss":U ) ) ) no-error.
            run lib-rwds_cltrnsum in this-procedure ( input bf_trn-doc.doc-code
                                                    , input {&sum-general-cli-doc} ) no-error.
            if error-status :error then do:
              run waitfram-hide in p-rwdshandle no-error.
              undo, return error substitute( 'Ошибка при вызове процедуры lib-rwds_cltrnsum &1 &2 документ "&3".',
                                             return-value, error-status :get-message( 1 ), bf_trn-doc.doc-code ).
            end.
            run waitfram-show in p-rwdshandle ( input substitute( 'Очищаем запись для сумм типа "&1". Время &2.'
                                                                , {&sum-extra-cli-doc}
                                                                , string( time - j#time, "hh:mm:ss":U ) ) ) no-error.
            run lib-rwds_cltrnsum in this-procedure ( input bf_trn-doc.doc-code
                                                    , input {&sum-extra-cli-doc} ) no-error.
            if error-status :error then do:
              run waitfram-hide in p-rwdshandle no-error.
              undo, return error substitute( 'Ошибка при вызове процедуры lib-rwds_cltrnsum &1 &2 документ "&3".',
                                             return-value, error-status :get-message( 1 ), bf_trn-doc.doc-code ).
            end.
            run waitfram-show in p-rwdshandle ( input substitute( 'Очищаем запись для сумм типа "&1". Время &2.'
                                                                , {&sum-miss-cli-doc}
                                                                , string( time - j#time, "hh:mm:ss":U ) ) ) no-error.
            run lib-rwds_cltrnsum in this-procedure ( input bf_trn-doc.doc-code
                                                    , input {&sum-miss-cli-doc} ) no-error.
            if error-status :error then do:
              run waitfram-hide in p-rwdshandle no-error.
              undo, return error substitute( 'Ошибка при вызове процедуры lib-rwds_cltrnsum &1 &2 документ "&3".',
                                             return-value, error-status :get-message( 1 ), bf_trn-doc.doc-code ).
            end.
            run waitfram-show in p-rwdshandle ( input substitute( 'Записываем атрибут для сумм типа "&1". Время &2.'
                                                                , {&sum-general-cli-doc}
                                                                , string( time - j#time, "hh:mm:ss":U ) ) ) no-error.
            assign v_attr-value = v_attr-value + min( v_attr-value, ',' ) + {&sum-general-cli-doc} +
                                                                    ','   + {&sum-extra-cli-doc}   +
                                                                    ','   + {&sum-miss-cli-doc}.
            { str/tdat-wrt.i bf_trn-doc.doc-code
                         {&trdcattr-addsum}
                         v_attr-value        no-error }
            if error-status :error then do:
              run waitfram-hide in p-rwdshandle no-error.
              undo, return error substitute(
                'Ошибка &1 &2 на вызове программы tdat-wrt при расчете естественной убыли по документу "&3".',
                return-value, error-status :get-message( 1 ), bf_trn-doc.doc-code ).
            end.
          end. /* if available bf_trn-doc-sum */

          assign jj_count = 0.
          for each bf_doc-line where
                   bf_doc-line.doc-code = bf_trn-doc.doc-code
          on error undo, return error return-value :
            find first bf_goods no-lock where
                       bf_goods.artic     = bf_doc-line.artic     and
                       bf_goods.prod-type = bf_doc-line.prod-type and
                       bf_goods.prod-code = bf_doc-line.prod-code.
            find first bf_doc-line-sum where
                       bf_doc-line-sum.doc-code = bf_doc-line.doc-code   and
                       bf_doc-line-sum.gds-code = bf_goods.gds-code      and
                       bf_doc-line-sum.sum-type = {&sum-general-cli-doc} no-error.
            if not available bf_doc-line-sum then do:
              run lib-rwds_crlinsum in this-procedure ( input bf_doc-line.doc-code
                                                      , input {&sum-general-cli-doc}
                                                      , input bf_doc-line.artic
                                                      , input bf_doc-line.prod-type
                                                      , input bf_doc-line.prod-code  ) no-error.
              if error-status :error then do:
                run waitfram-hide in p-rwdshandle no-error.
                undo, return error substitute(
                  'Ошибка при вызове процедуры lib-rwds_crlinsum &1 &2 документ "&3" товар &4 &5 &6',
                  return-value,
                  error-status :get-message( 1 ),
                  bf_trn-doc.doc-code,
                  bf_doc-line.artic,
                  bf_doc-line.prod-type,
                  bf_doc-line.prod-code ).
              end.
            end. /* if not available bf_doc-line-sum */
            run waitfram-join in p-rwdshandle (  input "Расчитываем записи строк сумм типа {&sum-general-cli-doc}."
                                              ,  input "Обработано строк: " + string( jj_count )
                                              ,  input "Время " + string( time - j#time, "hh:mm:ss":U )
                                              , output v_message ).
            run waitfram-show in p-rwdshandle (  input v_message ) no-error.
            run lib-rwds_cctrnsum in this-procedure ( input              bf_doc-line.doc-code
                                                    , input              bf_doc-line.artic
                                                    , input              bf_doc-line.prod-type
                                                    , input              bf_doc-line.prod-code
                                                    , input              {&sum-general-cli-doc}
                                                    , input-output table tt-allsum-line
                                                    , input-output table tt-doc-line-sum
                                                    , input-output table tt-clcparts
                                                    , input-output table temp-parts             ) no-error.
            if error-status :error then do:
              run waitfram-hide in p-rwdshandle no-error.
              undo, return error substitute(
                'Ошибка при вызове процедуры lib-rwds_cctrnsum &1 &2 документ "&3" товар &4 &5 &6',
                return-value,
                error-status :get-message( 1 ),
                bf_trn-doc.doc-code,
                bf_doc-line.artic,
                bf_doc-line.prod-type,
                bf_doc-line.prod-code ).
            end.
          end. /* for each bf_doc-line */
          run waitfram-show in p-rwdshandle ( input substitute( 'Запись сумм типа "&1". Время &2.'
                                                              , {&sum-general-cli-doc}
                                                              , string( time - j#time, "hh:mm:ss":U ) ) ) no-error.
          { str/reclctsl.i bf_trn-doc.doc-code
                       {&sum-general-cli-doc} no-error }
          if error-status :error then do:
            run waitfram-hide in p-rwdshandle no-error.
            undo, return error return-value.
          end.
        end. /* if lookup( {&sum-general-cli-doc}, v_attr-value ) = 0 */
      end. /* if v_invclcsp = "yes" */

      if lookup( {&sum-after-doc}, v_attr-value ) = 0 then do:
        find first bf_trn-doc-sum where
                   bf_trn-doc-sum.doc-code = bf_trn-doc.doc-code and
                   bf_trn-doc-sum.sum-type = {&sum-after-doc}    no-error.
        if not available bf_trn-doc-sum then do:
          run waitfram-show in p-rwdshandle ( input substitute( 'Создаем запись для сумм типа "&1". Время &2.'
                                                              , {&sum-after-doc}
                                                              , string( time - j#time, "hh:mm:ss":U ) ) ) no-error.
          run lib-rwds_crtrnsum in this-procedure ( input bf_trn-doc.doc-code
                                                  , input {&sum-after-doc}    ) no-error.
          if error-status :error then do:
            run waitfram-hide in p-rwdshandle no-error.
            undo, return error substitute( 'Ошибка при вызове процедуры lib-rwds_crtrnsum &1 &2 документ "&3".',
                                           return-value, error-status :get-message( 1 ), bf_trn-doc.doc-code ).
          end.
        end. /* if not available bf_trn-doc-sum */
        else do: /* if available bf_trn-doc-sum */
          run waitfram-show in p-rwdshandle ( input substitute( 'Очищаем запись для сумм типа "&1". Время &2.'
                                                              , {&sum-after-doc}
                                                              , string( time - j#time, "hh:mm:ss":U ) ) ) no-error.
          run lib-rwds_cltrnsum in this-procedure ( input bf_trn-doc.doc-code
                                                  , input {&sum-after-doc}    ) no-error.
          if error-status :error then do:
            run waitfram-hide in p-rwdshandle no-error.
            undo, return error substitute( 'Ошибка при вызове процедуры lib-rwds_cltrnsum &1 &2 документ "&3".',
                                           return-value, error-status :get-message( 1 ), bf_trn-doc.doc-code ).
          end.
          run waitfram-show in p-rwdshandle ( input substitute( 'Запись атрибута для сумм типа "&1". Время &2.'
                                                              , {&sum-after-doc}
                                                              , string( time - j#time, "hh:mm:ss":U ) ) ) no-error.
          assign v_attr-value = v_attr-value  + min( v_attr-value, ',' ) + {&sum-after-doc}.
          { str/tdat-wrt.i bf_trn-doc.doc-code
                       {&trdcattr-addsum}
                       v_attr-value        no-error }
          if error-status :error then do:
            run waitfram-hide in p-rwdshandle no-error.
            undo, return error substitute(
              'Ошибка &1 &2 на вызове программы tdat-wrt при расчете естественной убыли по документу "&3".',
              return-value, error-status :get-message( 1 ), bf_trn-doc.doc-code ).
          end.
        end. /* if available bf_trn-doc-sum */

        assign jj_count = 0.
        for each bf_doc-line where
                 bf_doc-line.doc-code = bf_trn-doc.doc-code
        on error undo, return error return-value :
          find first bf_goods no-lock where
                     bf_goods.artic     = bf_doc-line.artic     and
                     bf_goods.prod-type = bf_doc-line.prod-type and
                     bf_goods.prod-code = bf_doc-line.prod-code.
          find first bf_doc-line-sum where
                     bf_doc-line-sum.doc-code = bf_doc-line.doc-code and
                     bf_doc-line-sum.gds-code = bf_goods.gds-code    and
                     bf_doc-line-sum.sum-type = {&sum-after-doc}     no-error.
          if not available bf_doc-line-sum then do:
            run lib-rwds_crlinsum in this-procedure ( input bf_doc-line.doc-code
                                                    , input {&sum-after-doc}
                                                    , input bf_doc-line.artic
                                                    , input bf_doc-line.prod-type
                                                    , input bf_doc-line.prod-code ) no-error.
            if error-status :error then do:
              run waitfram-hide in p-rwdshandle no-error.
              undo, return error substitute(
                'Ошибка при вызове процедуры lib-rwds_crlinsum &1 &2 документ "&3" товар &4 &5 &6',
                return-value,
                error-status :get-message( 1 ),
                bf_trn-doc.doc-code,
                bf_doc-line.artic,
                bf_doc-line.prod-type,
                bf_doc-line.prod-code ).
            end.
          end. /* if not available bf_doc-line-sum */
          assign jj_count = jj_count + 1.
          run waitfram-join in p-rwdshandle (  input substitute( 'Расчитываем записи строк сумм типа "&1".'
                                                               , {&sum-after-doc} )
                                            ,  input substitute( 'Обработано строк: &1', jj_count )
                                            ,  input substitute( 'Время &1.', string( time - j#time, "hh:mm:ss":U ) )
                                            , output v_message ).
          run waitfram-show in p-rwdshandle (  input v_message ) no-error.
          run lib-rwds_cctrnsum in this-procedure ( input              bf_doc-line.doc-code
                                                  , input              bf_doc-line.artic
                                                  , input              bf_doc-line.prod-type
                                                  , input              bf_doc-line.prod-code
                                                  , input              {&sum-after-doc}
                                                  , input-output table tt-allsum-line
                                                  , input-output table tt-doc-line-sum
                                                  , input-output table tt-clcparts
                                                  , input-output table temp-parts            ) no-error.
          if error-status :error then do:
            run waitfram-hide in p-rwdshandle no-error.
            undo, return error substitute(
              'Ошибка при вызове процедуры lib-rwds_cctrnsum &1 &2 документ "&3" товар &4 &5 &6',
              return-value,
              error-status :get-message( 1 ),
              bf_trn-doc.doc-code,
              bf_doc-line.artic,
              bf_doc-line.prod-type,
              bf_doc-line.prod-code ).
          end.
        end. /* for each bf_doc-line */
        run waitfram-show in p-rwdshandle ( input substitute( 'Запись сумм типа "&1". Время &2.'
                                                            , {&sum-after-doc}
                                                            , string( time - j#time, "hh:mm:ss":U ) ) ) no-error.
        { str/reclctsl.i bf_trn-doc.doc-code
                     {&sum-after-doc}    no-error }
        if error-status :error then do:
          run waitfram-hide in p-rwdshandle no-error.
          undo, return error return-value.
        end.
      end. /* if lookup( {&sum-after-doc}, v_attr-value ) = 0 */
      if v_invclcsp = "yes" then do:
        if lookup( {&sum-after-cli-doc}, v_attr-value ) = 0 then do:
          find first bf_trn-doc-sum where
                     bf_trn-doc-sum.doc-code = bf_trn-doc.doc-code  and
                     bf_trn-doc-sum.sum-type = {&sum-after-cli-doc} no-error.
          if not available bf_trn-doc-sum then do:
            run waitfram-show in p-rwdshandle ( input substitute( 'Создаем запись для сумм типа "&1". Время &2.'
                                                                , {&sum-after-cli-doc}
                                                                , string( time - j#time, "hh:mm:ss":U ) ) ) no-error.
            run lib-rwds_crtrnsum in this-procedure ( input bf_trn-doc.doc-code
                                                    , input {&sum-after-cli-doc} ) no-error.
            if error-status :error then do:
              run waitfram-hide in p-rwdshandle no-error.
              undo, return error substitute( 'Ошибка при вызове процедуры lib-rwds_crtrnsum &1 &2 документ "&3".',
                                             return-value, error-status :get-message( 1 ), bf_trn-doc.doc-code ).
            end.
          end. /* if not available bf_trn-doc-sum */
          else do: /* if available bf_trn-doc-sum */
            run waitfram-show in p-rwdshandle ( input substitute( 'Очищаем запись для сумм типа "&1". Время &2.'
                                                                , {&sum-after-doc}
                                                                , string( time - j#time, "hh:mm:ss":U ) ) ) no-error.
            run lib-rwds_cltrnsum in this-procedure ( input bf_trn-doc.doc-code
                                                    , input {&sum-after-cli-doc} ) no-error.
            if error-status :error then do:
              run waitfram-hide in p-rwdshandle no-error.
              undo, return error substitute( 'Ошибка при вызове процедуры lib-rwds_cltrnsum &1 &2 документ "&3"',
                                             return-value, error-status :get-message( 1 ), bf_trn-doc.doc-code ).
            end.
            run waitfram-show in p-rwdshandle ( input substitute( 'Запись атрибута для сумм типа "&1". Время &2.'
                                                                , {&sum-after-doc}
                                                                , string( time - j#time, "hh:mm:ss":U ) ) ) no-error.
            assign v_attr-value = v_attr-value + min( v_attr-value, ',' ) + {&sum-after-cli-doc}.
            { str/tdat-wrt.i bf_trn-doc.doc-code
                         {&trdcattr-addsum}
                         v_attr-value        no-error }
            if error-status :error then do:
              run waitfram-hide in p-rwdshandle no-error.
              undo, return error substitute(
                'Ошибка &1 &2 на вызове программы tdat-wrt при расчете естественной убыли по документу "&3".',
                return-value,
                error-status :get-message( 1 ),
                bf_trn-doc.doc-code ).
            end.
          end. /* if available bf_trn-doc-sum */
          assign jj_count = 0.
          for each bf_doc-line where
                   bf_doc-line.doc-code = bf_trn-doc.doc-code
          on error undo, return error return-value :
            find first bf_goods no-lock where
                       bf_goods.artic     = bf_doc-line.artic     and
                       bf_goods.prod-type = bf_doc-line.prod-type and
                       bf_goods.prod-code = bf_doc-line.prod-code.
            find first bf_doc-line-sum where
                       bf_doc-line-sum.doc-code = bf_doc-line.doc-code and
                       bf_doc-line-sum.gds-code = bf_goods.gds-code    and
                       bf_doc-line-sum.sum-type = {&sum-after-cli-doc} no-error.
            if not available bf_doc-line-sum then do:
              run lib-rwds_crlinsum in this-procedure ( input bf_doc-line.doc-code
                                                      , input {&sum-after-cli-doc}
                                                      , input bf_doc-line.artic
                                                      , input bf_doc-line.prod-type
                                                      , input bf_doc-line.prod-code ) no-error.
              if error-status :error then do:
                run waitfram-hide in p-rwdshandle no-error.
                undo, return error substitute(
                  'Ошибка при вызове процедуры lib-rwds_crlinsum &1 &2 документ "&3" товар &4 &5 &6',
                  return-value,
                  error-status :get-message( 1 ),
                  bf_trn-doc.doc-code,
                  bf_doc-line.artic,
                  bf_doc-line.prod-type,
                  bf_doc-line.prod-code ).
              end.
            end.

            assign jj_count = jj_count + 1.
            run waitfram-join in p-rwdshandle (  input substitute( 'Расчитываем записи строк сумм типа "&1".'
                                                                 , {&sum-after-cli-doc} )
                                              ,  input substitute( 'Обработано строк: &1', jj_count )
                                              ,  input substitute( 'Время &1.', string( time - j#time, "hh:mm:ss":U ) )
                                              , output v_message ).
            run waitfram-show in p-rwdshandle (  input v_message ) no-error.
            run lib-rwds_cctrnsum in this-procedure ( input              bf_doc-line.doc-code
                                                    , input              bf_doc-line.artic
                                                    , input              bf_doc-line.prod-type
                                                    , input              bf_doc-line.prod-code
                                                    , input              {&sum-after-cli-doc}
                                                    , input-output table tt-allsum-line
                                                    , input-output table tt-doc-line-sum
                                                    , input-output table tt-clcparts
                                                    , input-output table temp-parts            ) no-error.
            if error-status :error then do:
              run waitfram-hide in p-rwdshandle no-error.
              undo, return error substitute(
                'Ошибка при вызове процедуры lib-rwds_cctrnsum &1 &2 документ "&3" товар &4 &5 &6',
                return-value,
                error-status :get-message( 1 ),
                bf_trn-doc.doc-code,
                bf_doc-line.artic,
                bf_doc-line.prod-type,
                bf_doc-line.prod-code ).
            end.
          end. /* for each bf_doc-line */
          run waitfram-show in p-rwdshandle ( input substitute( 'Запись сумм типа "&1". Время &2.'
                                                              , {&sum-after-cli-doc}
                                                              , string( time - j#time, "hh:mm:ss":U ) ) ) no-error.
          { str/reclctsl.i bf_trn-doc.doc-code
                       {&sum-after-cli-doc} no-error }
          if error-status :error then do:
            run waitfram-hide in p-rwdshandle no-error.
            undo, return error return-value.
          end.
        end. /* нет клиентских сумм после */
      end. /* клиентские суммы */
    end. /* рассчитали суммы */
    run waitfram-hide in p-rwdshandle no-error.
  end. /* transaction */
end procedure. /* lib-rwds_rcallfct */


/* $Workfile: lib-rwds.p $   E n d */