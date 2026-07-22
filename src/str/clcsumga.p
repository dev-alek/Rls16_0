block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: clcsumga.p $
$Archive: str/clcsumga.p $

Пересчет основных сумм и сумм после документа

Автор: Чернова Светлана Александровна
Дата создания: 10/05/06
Author: Svetlana Chernova
Creation date: 10/05/06


*/

/* ********************************************************************************************************************* *\
 *                                                                                                                       *
 * На 'факт' считается всегда.                                                                                           *
 * На 'разр' - если эти суммы есть в атрибутах документа.                                                               *
 *                                                                                                                       *
\* ********************************************************************************************************************* */

define input parameter v-doc-code like ub.trn-doc.doc-code no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: clcsumga.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/clcsumga.p $":U .
define variable vss-description as character no-undo initial "Пересчет основных сумм":U .

{ cmp/vssrevis.i "substitute('&1':U,v-doc-code)" }
{ gbl/waitfram.i noprocess }
{ cmp/str-glbl.i }
{ cmp/operlist.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ trg/partslib.i }
{ str/clcprtsl.i }
{ str/trdcalib.i }
{ str/lib-rwds.i }
{ gbl/getsect.i def }

define variable varcalcasstring  as character no-undo.
define variable varcalcastype    as character no-undo.
define variable varinvclcspvalue as character no-undo.
define variable varinvclcsptype  as character no-undo.
define variable varneed-calc     as logical   no-undo.
define variable vartime          as integer   no-undo.
define variable varcount         as integer   no-undo.

define buffer bf_goods           for ub.goods.
define buffer bf_tt-doc-line-sum for tt-doc-line-sum.

do transaction on error undo, return error return-value :
  assign
    vartime = time.
  find first ub.trn-doc no-lock where
             ub.trn-doc.doc-code = v-doc-code
  .

{ gbl/getsect.i run ub.trn-doc.obj-type ub.trn-doc.obj-code  {&attr-inv-obj} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'invclcsp'  then varinvclcspvalue = string( thbjattr_thbj-attr.property-value-logical, "yes/no").
end.

  if ub.trn-doc.ext-doc-type <> {&TDEDT_Inv}              and
     ub.trn-doc.ext-doc-type <> {&TDEDT_Peresort}         and
     ub.trn-doc.ext-doc-type <> {&TDEDT_Corr_Minus_Parts} and
     ub.trn-doc.ext-doc-type <> {&TDEDT_Chg_Purch_Code}   and
     ub.trn-doc.ext-doc-type <> {&TDEDT_Corr_Acc_Price}   then do:
    return error substitute( "Документ &1 имеет недопустимый расширенный тип &2 для данной операции."
                           , ub.trn-doc.doc-code
                           , ub.trn-doc.ext-doc-type).
  end.

  if ub.trn-doc.status_ <> {&fact}      and
     ub.trn-doc.status_ <> {&permitted} then do:
    assign
      varneed-calc = no.
  end.
  else do:
    assign
      varneed-calc = yes.
    if trn-doc.status_ = {&permitted} then do:
      { str/tdat-val.i ub.trn-doc.doc-code
                   {&trdcattr-addsum}
                   varcalcasstring
                   varcalcastype       no-error }
      if error-status :error then do:
        return error substitute( 'Ошибка при вызове процедуры tdat-value. Документ "&1". Параметр "&2".'
                               , ub.trn-doc.doc-code
                               , {&trdcattr-clcasol} ).
      end.
      if lookup( {&sum-general-doc}, varcalcasstring ) <> 0 then do:
        if lookup( {&sum-extra-doc}, varcalcasstring ) = 0 then do:
          return error substitute( 'Критическая ошибка. По документу "&1" есть рассчитаная сумма "&2" и нет суммы "&3".'
                                 , ub.trn-doc.doc-code
                                 , {&sum-general-doc}
                                 , {&sum-extra-doc} ).
        end.
        if lookup( {&sum-miss-doc}, varcalcasstring ) = 0 then do:
          return error substitute( 'Критическая ошибка. По документу "&1" есть рассчитаная сумма "&2" и нет суммы "&3".'
                                 , ub.trn-doc.doc-code
                                 , {&sum-general-doc}
                                 , {&sum-miss-doc} ).
        end.
        if lookup( {&sum-after-doc}, varcalcasstring ) = 0 then do:
          return error substitute( 'Критическая ошибка. По документу "&1" есть рассчитаная сумма "&2" и нет суммы "&3".'
                                 , ub.trn-doc.doc-code
                                 , {&sum-general-doc}
                                 , {&sum-after-doc} ).
        end.
        if varinvclcspvalue = "yes" then do:
          if lookup( {&sum-general-cli-doc}, varcalcasstring ) = 0 then do:
            return error substitute( 'Критическая ошибка. По документу "&1" есть рассчитаная сумма "&2" и нет суммы "&3".'
                                   , ub.trn-doc.doc-code
                                   , {&sum-general-doc}
                                   , {&sum-general-cli-doc} ).
          end.
          if lookup( {&sum-extra-cli-doc}, varcalcasstring ) = 0 then do:
            return error substitute( 'Критическая ошибка. По документу "&1" есть рассчитаная сумма "&2" и нет суммы "&3".'
                                   , ub.trn-doc.doc-code
                                   , {&sum-general-doc}
                                   , {&sum-extra-cli-doc} ).
          end.
          if lookup( {&sum-miss-cli-doc}, varcalcasstring ) = 0 then do:
            return error substitute( 'Критическая ошибка. По документу "&1" есть рассчитаная сумма "&2" и нет суммы "&3".'
                                   , ub.trn-doc.doc-code
                                   , {&sum-general-doc}
                                   , {&sum-miss-cli-doc} ).
          end.
          if lookup( {&sum-after-cli-doc}, varcalcasstring ) = 0 then do:
            return error substitute( 'Критическая ошибка. По документу "&1" есть рассчитаная сумма "&2" и нет суммы "&3".'
                                   , ub.trn-doc.doc-code
                                   , {&sum-general-doc}
                                   , {&sum-after-cli-doc} ).
          end.
        end.
      end.
      else do:
        assign
          varneed-calc = no.
      end.
    end.
  end.
  if varneed-calc <> yes then do:
    return.
  end.
  run waitfram-show in this-procedure ( input substitute( 'Очистка сумм документа "&1".', ub.trn-doc.doc-code ) ).
  { str/cltrnsum.i ub.trn-doc.doc-code
               {&sum-general-doc}  no-error }
  if error-status :error then do:
    return error return-value.
  end.
  { str/cltrnsum.i ub.trn-doc.doc-code
               {&sum-extra-doc}    no-error }
  if error-status :error then do:
    return error return-value.
  end.
  { str/cltrnsum.i ub.trn-doc.doc-code
               {&sum-miss-doc}     no-error }
  if error-status :error then do:
    return error return-value.
  end.
  { str/cltrnsum.i ub.trn-doc.doc-code
               {&sum-after-doc}    no-error }
  if error-status :error then do:
    return error return-value.
  end.
  if varinvclcspvalue = "yes" then do:
    { str/cltrnsum.i ub.trn-doc.doc-code
                 {&sum-general-cli-doc} no-error }
    if error-status :error then do:
      return error return-value.
    end.
    { str/cltrnsum.i ub.trn-doc.doc-code
                 {&sum-extra-cli-doc}   no-error }
    if error-status :error then do:
      return error return-value.
    end.
    { str/cltrnsum.i ub.trn-doc.doc-code
                 {&sum-miss-cli-doc}    no-error }
    if error-status :error then do:
      return error return-value.
    end.
    { str/cltrnsum.i ub.trn-doc.doc-code
                 {&sum-after-cli-doc}   no-error }
    if error-status :error then do:
      return error return-value.
    end.
  end.
  assign
    varcount = 0.
  for each ub.doc-line no-lock where
           ub.doc-line.doc-code = ub.trn-doc.doc-code
  on error undo, return error return-value :
    find first bf_goods no-lock where
               bf_goods.artic     = ub.doc-line.artic     and
               bf_goods.prod-type = ub.doc-line.prod-type and
               bf_goods.prod-code = ub.doc-line.prod-code no-error.
    if not available bf_goods then do:
      return error substitute( "Не найден товар &1 &2 &3."
                             , ub.doc-line.artic
                             , ub.doc-line.prod-type
                             , ub.doc-line.prod-code ).
    end.
    assign
      varcount = varcount + 1.
    run waitfram-show in this-procedure (
      input waitfram-join-function ( substitute( "Расчитываем записи строк сумм." ),
                                     substitute( "Обработано строк: &1", varcount ),
                                     substitute( "Время &1.", string( time - vartime, "hh:mm:ss":U ) )
                                   )    ) no-error.

    if varinvclcspvalue = "yes" then do:
      { str/cctrnsum.i ub.doc-line.doc-code
                   ub.doc-line.artic
                   ub.doc-line.prod-type
                   ub.doc-line.prod-code
                   "'{&bef-sum-general-doc},{&bef-sum-general-cli-doc},{&bef-sum-after-doc},{&bef-sum-after-cli-doc}'"
                   tt-allsum-line
                   tt-doc-line-sum
                   tt-clcparts
                   temp-parts no-error }
      if error-status :error then do:
        return error return-value.
      end.
    end.
    else do:
      { str/cctrnsum.i ub.doc-line.doc-code
                   ub.doc-line.artic
                   ub.doc-line.prod-type
                   ub.doc-line.prod-code
                   "'{&bef-sum-general-doc},{&bef-sum-after-doc}'"
                   tt-allsum-line
                   tt-doc-line-sum
                   tt-clcparts
                   temp-parts no-error }
      if error-status :error then do:
        return error return-value.
      end.
    end.
  end. /* for each doc-line */
  run waitfram-show in this-procedure ( input substitute( 'Расчет сумм документа "&1".', ub.trn-doc.doc-code ) ).
  { str/reclctsl.i
    ub.trn-doc.doc-code
    {&sum-general-doc}
    no-error
  }
  if error-status :error then do:
    return error substitute( 'Ошибка при вызове процедуры str/reclctsl.i для документа "&1". Тип суммы "&2".'
                           , ub.trn-doc.doc-code
                           , {&sum-general-doc} ).
  end.
  { str/reclctsl.i
    ub.trn-doc.doc-code
    {&sum-after-doc}
    no-error
  }
  if error-status :error then do:
    return error substitute( 'Ошибка при вызове процедуры str/reclctsl.i для документа "&1". Тип суммы "&2".'
                           , ub.trn-doc.doc-code
                           , {&sum-after-doc} ).
  end.

  if varinvclcspvalue = "yes" then do:
    { str/reclctsl.i
      ub.trn-doc.doc-code
      {&sum-general-cli-doc}
      no-error
    }
    if error-status :error then do:
      return error substitute( 'Ошибка при вызове процедуры str/reclctsl.i для документа "&1". Тип суммы "&2".'
                             , ub.trn-doc.doc-code
                             , {&sum-general-cli-doc} ).
    end.
    { str/reclctsl.i
      ub.trn-doc.doc-code
      {&sum-after-cli-doc}
      no-error
    }
    if error-status :error then do:
      return error substitute( 'Ошибка при вызове процедуры str/reclctsl.i для документа "&1". Тип суммы "&2".'
                             , ub.trn-doc.doc-code
                             , {&sum-after-cli-doc} ).
    end.
  end.
  run waitfram-hide in this-procedure no-error.
end. /* transaction */