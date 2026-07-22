block-level on error undo, throw.
/*

$Revision: 55cbd55c1b5e, 500, rls $
$Author: EShklyar $
$Date: Sun Feb 28 19:23:25 2016 +0400 $
$Workfile: libtfarh.p $
$Archive: str/libtfarh.p $

Библиотека для работы с финансовыми архивами по складским документам

Автор: Чернова Светлана Александровна
Дата создания: 12/29/06
Author: Svetlana Chernova
Creation date: 12/29/06

create: Суслов Алексей Юрьевич
Дата создания: 12/18/03


*/

define variable vss-revision    as character no-undo initial "$Revision: 55cbd55c1b5e, 500, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: Sun Feb 28 19:23:25 2016 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: libtfarh.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/libtfarh.p $":U .
define variable vss-description as character no-undo initial "Библиотека для работы с финансовыми архивами по складским документам":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/libtfarh.i }
{ str/clcprtsl.i }
{ str/cntparts.i }
{ str/cntparts.i -lk }
{ trg/partslib.i }
{ trg/factord.i  }
{ gbl/getsect.i def }

if valid-handle (g#libtfarh)
and g#libtfarh <> this-procedure :handle
and g#libtfarh :get-signature('libtfarh_finincex':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки для работы с финансовыми архивами по складским документам"  skip
    g#libtfarh skip
    g#libtfarh :type skip
    g#libtfarh :file-name skip
    valid-handle(g#libtfarh) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error .
end.
else do:
  assign
    g#libtfarh = this-procedure :handle
  .
end.

on delete of this-procedure do:
  assign
    g#libtfarh = ?
  .
end.
define stream str-err.

/*Процедура анализа расширенного типа документов с точки зрения финансов*/
procedure libtfarh_finincex:
define input  parameter parext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define output parameter parinc-exp      as   integer                 no-undo.  /* 0 - ни приобретение ни реализация,
                                                                                  1 - приобретение,
                                                                                  2 - реализация,
                                                                                  3 - приобретение и реализаци
                                                                                */
do on error undo, return error return-value :
case parext-doc-type:
  when {&TDEDT_Pri_Vnesh}          or
  when {&TDEDT_Vozvrat_Vnesh}      or
  when {&TDEDT_Vozvrat_Vnesh_Kass} or
  when {&TDEDT_Corr_Acc_Price}     then do:
    assign
      parinc-exp = 1.
  end.
  when {&TDEDT_Ras_Vnesh_VP}       or
  when {&TDEDT_Ras_Vnesh}          or
  when {&TDEDT_Ras_Vnesh_Kass}     or
  when {&TDEDT_Spi_Vnesh}          or
  when {&TDEDT_Ras_Prvo}           or
  when {&TDEDT_Spi_Prvo}           or
  when {&TDEDT_Inv}                or
  when {&TDEDT_Peresort}           or
  when {&TDEDT_Corr_Minus_Parts}   then do:
    assign
      parinc-exp = 2.
  end.
  when {&TDEDT_Pri_Perem}      or
  when {&TDEDT_Ras_Perem}      or
  when {&TDEDT_Pri_Object}     or
  when {&TDEDT_Ras_Object}     or
  when {&TDEDT_Vozvrat_Perem}  or
  when {&TDEDT_Pri_Prvo}       or
  when {&TDEDT_Chg_Purch_code} or
  when {&TDEDT_Overturn}       then do:
    assign
      parinc-exp = 0.
  end.
  otherwise do:
    return error substitute ("Не могу обработать расширенный тип документа &1 для обработки финансов.", parext-doc-type).
  end.
end case.
end.
end procedure.
/*учет документов в расчете финансовых обязательств по типу договоров*/
procedure libtfarh_finincexforgenfo:
define input  parameter parext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define output parameter parinc-exp      as   integer                 no-undo.  /* 0 - ни приобретение ни реализация,
                                                                                  1 - приобретение,
                                                                                  2 - реализация,
                                                                                  3 - приобретение и реализаци
                                                                                */
do on error undo, return error return-value :
case parext-doc-type:
  when {&TDEDT_Pri_Vnesh}          or
  when {&TDEDT_Corr_Acc_Price}     or
  when {&TDEDT_Ras_Vnesh_VP}       then do:
    assign
      parinc-exp = 1.
  end.
  when {&TDEDT_Ras_Vnesh}          or
  when {&TDEDT_Ras_Vnesh_Kass}     or
  when {&TDEDT_Spi_Vnesh}          or
  when {&TDEDT_Ras_Prvo}           or
  when {&TDEDT_Spi_Prvo}           or
  when {&TDEDT_Vozvrat_Vnesh}      or
  when {&TDEDT_Vozvrat_Vnesh_Kass} or
  when {&TDEDT_Chg_Purch_code}     or
  when {&TDEDT_Inv}                or
  when {&TDEDT_Corr_Minus_Parts}   then do:
    assign
      parinc-exp = 2.
  end.
  when {&TDEDT_Peresort}           then do:
    assign
      parinc-exp = 3.

  end.
  when {&TDEDT_Pri_Perem}      or
  when {&TDEDT_Ras_Perem}      or
  when {&TDEDT_Pri_Object}     or
  when {&TDEDT_Ras_Object}     or
  when {&TDEDT_Vozvrat_Perem}  or
  when {&TDEDT_Pri_Prvo}       or
  when {&TDEDT_Overturn}       then do:
    assign
      parinc-exp = 0.
  end.
  otherwise do:
    return error substitute ("Не могу обработать расширенный тип документа &1 для обработки финансов.", parext-doc-type).
  end.
end case.
end.
end procedure.


procedure libtfarh_st-fo:
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define variable varcr-buyfo as logical no-undo.
define variable varcr-expfo as logical no-undo.
define variable varcr-incfo as logical no-undo.
define variable varundef    as logical no-undo.
define variable varundefb   as logical no-undo.
define variable varinc-exp  as integer no-undo.
define buffer buf_trn-doc  for ub.trn-doc.
define buffer buf_parts    for ub.parts.
define buffer buf_contract for ub.contract.
define buffer buf_doc-attr for ub.doc-attr  .
define buffer buf_fin-ob-trn for ub.fin-ob-trn.
define buffer buf_fin-ob     for ub.fin-ob.

do on error undo, return error return-value :
find first buf_trn-doc where buf_trn-doc.doc-code = pardoc-code exclusive-lock.

if buf_trn-doc.status_ = {&fact} then do :

assign
  buf_trn-doc.expfo-date      = 01/01/1990
  buf_trn-doc.incfo-date      = 01/01/1990
  buf_trn-doc.factur-date     = 01/01/1990
  buf_trn-doc.buyer-fo-date   = 01/01/1990
  buf_trn-doc.cr-incfo        = no
  buf_trn-doc.cr-expfo        = no
  buf_trn-doc.cr-incorexpfo   = no
  buf_trn-doc.cr-factur       = no
  buf_trn-doc.cr-fo-buyer     = no
  buf_trn-doc.need-expfo      = 0
  buf_trn-doc.need-incfo      = 0
  buf_trn-doc.need-incorexpfo = 0
  buf_trn-doc.need-factur     = 0
  buf_trn-doc.need-buyer      = 0
.
assign
  varcr-buyfo = no
  varcr-expfo = no
  varcr-incfo = no
  varundefb   = no
  varundef    = no.
run libtfarh_finincexforgenfo in this-procedure (input  buf_trn-doc.ext-doc-type,
                                                 output varinc-exp ) no-error.
if error-status:error then do:
  return error return-value.
end.

/* если есть такой параметр то ФО делать не надо */
find first buf_doc-attr no-lock where
           buf_doc-attr.doc-code  = buf_trn-doc.doc-code and
           buf_doc-attr.attr-code = {&trdcattr-oldsuppcntr}  no-error .
if available buf_doc-attr  then do:
   if buf_doc-attr.attr-value = "yes" then  varinc-exp = 0 .
end.
case varinc-exp:
  when 1 then do:
    parts-cycle:
    for each buf_parts where buf_parts.out-code = buf_trn-doc.doc-code no-lock on error undo, return error return-value :
      if buf_parts.contract-code <> 0 then do:
        find first buf_contract where buf_contract.contract-code = buf_parts.contract-code no-lock no-error.
        if available buf_contract then do:
          if lookup (buf_contract.usl-opl, {&o-postavka}) > 0 then do:
            assign
              varcr-incfo = yes.
            leave parts-cycle.
          end.
          if buf_contract.usl-opl = {&contr-pay-nodef} then do:
            assign
              varundef = yes.
          end.
        end.
      end.
    end.
    if varcr-incfo = yes then do:
      assign
        buf_trn-doc.need-incfo      = 1
        buf_trn-doc.need-incorexpfo = 1.
    end.
    else do:
      if varundef = yes then do:
        assign
          buf_trn-doc.need-incfo      = 2
          buf_trn-doc.need-incorexpfo = 2.
      end.
    end.
  end.
  when 2 then do:
    parts-cycle:
    for each buf_parts where buf_parts.out-code = buf_trn-doc.doc-code no-lock on error undo, return error return-value :
      if buf_parts.contract-code <> 0 then do:
        find first buf_contract where buf_contract.contract-code = buf_parts.contract-code no-lock no-error.
        if available buf_contract then do:
          if lookup (buf_contract.usl-opl, {&o-realiz}) > 0 and
             not (buf_parts.purch-code = integer({&repayment-code}) and buf_contract.contract-type = {&contr-resp-store}) then do:
            assign
              varcr-expfo = yes.
            leave parts-cycle.
          end.
          if buf_contract.usl-opl = {&contr-pay-nodef} then do:
            assign
              varundef = yes.
          end.
        end.
      end.
    end.
    if varcr-expfo = yes then do:
      assign
        buf_trn-doc.need-expfo      = 1
        buf_trn-doc.need-incorexpfo = 1.
    end.
    else do:
      if varundef = yes then do:
        assign
          buf_trn-doc.need-expfo      = 2
          buf_trn-doc.need-incorexpfo = 2.
      end.
    end.
  end.
    when 3 then do:
    parts-cycle:
    for each buf_parts where buf_parts.out-code = buf_trn-doc.doc-code no-lock on error undo, return error return-value :
      if buf_parts.contract-code <> 0  and buf_parts.fact-qnty < 0 then do:
        find first buf_contract where buf_contract.contract-code = buf_parts.contract-code no-lock no-error.
        if available buf_contract then do:
          if lookup (buf_contract.usl-opl, {&o-realiz}) > 0 and
             not (buf_parts.purch-code = integer({&repayment-code}) and buf_contract.contract-type = {&contr-resp-store}) then do:
            assign
              varcr-expfo = yes.
            leave parts-cycle.
          end.
          if buf_contract.usl-opl = {&contr-pay-nodef} then do:
            assign
              varundef = yes.
          end.
        end.
      end.
    end.
    if varcr-expfo = yes then do:
      assign
        buf_trn-doc.need-expfo      = 1
        buf_trn-doc.need-incorexpfo = 1.
    end.
    else do:
      if varundef = yes then do:
        assign
          buf_trn-doc.need-expfo      = 2
          buf_trn-doc.need-incorexpfo = 2.
      end.
    end.
  end.

  when 0 then do:
  end.
  otherwise do:
    return error substitute ("Неизвестный параметр &1 получен от процедуры libtfarh_fin-inc-exp.", varinc-exp).
  end.
end case.

 /* для генерации счетов-фактур */
 if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}  then do:
   find first buf_contract where buf_contract.contract-code = buf_trn-doc.contract-code no-lock no-error.
   if available buf_contract then do:
     if (buf_contract.gen-factur = 1 or buf_contract.gen-factur = 11 or buf_contract.gen-factur = 101 or buf_contract.gen-factur = 111) then do:
       assign  buf_trn-doc.need-factur = 1 .
     end.
   end.
 end.
 if buf_trn-doc.ext-doc-type = {&TDEDT_Chg_Purch_code} then do:
   define buffer bf_trn-doc for ub.trn-doc .
   for each buf_parts no-lock where buf_parts.out-code = buf_trn-doc.doc-code :
     find first bf_trn-doc no-lock where bf_trn-doc.doc-code = buf_parts.in-code no-error .
     if available bf_trn-doc then do:
       find first buf_contract where buf_contract.contract-code = bf_trn-doc.contract-code no-lock no-error.
       if available buf_contract then do:
         if buf_contract.gen-factur = 4 or buf_contract.gen-factur = 14 or buf_contract.gen-factur = 104 or buf_contract.gen-factur = 114 then do:
           assign  buf_trn-doc.need-factur = 1 .
           LEAVE.
         end.
       end.
     end.
   end.
 end.

end.  /*  if buf_trn-doc.status_ = {&fact}  */

/* покупатели, договор с покупателем проставлен в шапке */
if ( buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} or
     buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} ) and
     buf_trn-doc.contract-code <> 0 then
        for first buf_contract where buf_contract.contract-code = buf_trn-doc.contract-code no-lock :
          if buf_contract.doc-type = {&expense} and lookup (buf_contract.usl-opl, {&o-buyer-ord}) > 0 then do :

             define variable v-fo-gen as integer no-undo .
             { gbl/getsect.i run "''" 0  {&attr-fin-global} }
              for each thbjattr_thbj-attr :
                  if thbjattr_thbj-attr.prop-code = {&attr-fin-global_fo-gen}  then v-fo-gen = thbjattr_thbj-attr.property-value-integer .
              end.
              if buf_trn-doc.status_ = {&wayb} and buf_trn-doc.flag_ and (v-fo-gen = 2 or v-fo-gen = 3) then buf_trn-doc.need-buyer = 1.
              if buf_trn-doc.status_ = {&permitted}                  and (v-fo-gen = 4 or v-fo-gen = 5) then buf_trn-doc.need-buyer = 1.
              if buf_trn-doc.status_ = {&fact}                       and (v-fo-gen = 6 or v-fo-gen = 7) then buf_trn-doc.need-buyer = 1.
              if buf_trn-doc.status_ = {&fact} then do :
                for each buf_fin-ob-trn where buf_fin-ob-trn.trn-doc-code = buf_trn-doc.doc-code  and
                                              buf_fin-ob-trn.host-code    = buf_trn-doc.host-code exclusive-lock,
                        each buf_fin-ob where buf_fin-ob.doc-code = buf_fin-ob-trn.doc-code  exclusive-lock
                        :
                           if buf_fin-ob.status_ <> {&fact} then do :
                            undo, return error "Данная накладная не может быть закрыта на факт, т.к. по ней есть незакрытое ФО" .
                           end.
                end.
              end.
          end.
          if buf_trn-doc.status_ = {&fact} and lookup (buf_contract.usl-opl, {&o-buyer-trn}) > 0 then do:
              assign
                buf_trn-doc.need-buyer = 1.
          end.
          if buf_trn-doc.status_ = {&fact} and buf_contract.usl-opl = {&contr-pay-nodef} then do:
            assign
              buf_trn-doc.need-buyer = 2.
          end.
end.

end.
end procedure.

/*перерасчет финансовых архивов по удаляемому складскому документу*/
procedure libtfarh_datrncnt :
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define buffer bf_trn-doc for ub.trn-doc.
define buffer bf_arh-trn-doc-contract        for ub.arh-trn-doc-contract.
define buffer bf-reclc_arh-trn-doc-contract  for ub.arh-trn-doc-contract.
define variable varinc-exp as integer no-undo.
do on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock no-error.
if not available bf_trn-doc then do:
  return error substitute ("Не найден складской документ с номером &1.", pardoc-code).
end.
run libtfarh_finincex in this-procedure (
    input  bf_trn-doc.ext-doc-type,
    output varinc-exp).
if varinc-exp <> 1 and
   varinc-exp <> 2 then do:
  return.
end.
if bf_trn-doc.status_ <> {&fact} then do:
  return error substitute ("Складской документ с номером &1 не в статусе факт. Создание финансовых архивов невозможно.", pardoc-code).
end.
if bf_trn-doc.fact-order =  0 or
   bf_trn-doc.fact-order = ? then do:
  return error substitute ("В складском документе с номером &1 не проставлен fact-order.", bf_trn-doc.doc-code).
end.
/*Захват договоров по всем партиям для исключения мертвых петель.
  Вообще мертвые петли в этой программе исключены, так как tt-cnt-parts идет в одном порядке.*/
run libtfarh_lkcontr (input bf_trn-doc.doc-code).
for each tt-cnt-parts on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
  delete tt-cnt-parts.
end.
run cntparts_calc-table-cnt in this-procedure (input pardoc-code).
/*пересчитываем архивы. Мертвые петли исключены порядком перебора партий.*/
for each tt-cnt-parts on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
  /*Ищем запись архива. Ее может не существовать, т.к. финансовые архивы могут иметь дату начала расчета данных архивов позже даты документа*/
  find first bf_arh-trn-doc-contract where bf_arh-trn-doc-contract.host-code     = tt-cnt-parts.host-code     and
                                           bf_arh-trn-doc-contract.contract-code = tt-cnt-parts.contract-code and
                                           bf_arh-trn-doc-contract.cli-type      = tt-cnt-parts.supp-type     and
                                           bf_arh-trn-doc-contract.cli-code      = tt-cnt-parts.supp-code     and
                                           bf_arh-trn-doc-contract.obj-type      = bf_trn-doc.obj-type        and
                                           bf_arh-trn-doc-contract.obj-code      = bf_trn-doc.obj-code        and
                                           bf_arh-trn-doc-contract.ext-doc-type  = bf_trn-doc.ext-doc-type    and
                                           bf_arh-trn-doc-contract.sum-type      = "":u                       and
                                           bf_arh-trn-doc-contract.fact-order    = bf_trn-doc.fact-order      exclusive-lock no-error.
  if available bf_arh-trn-doc-contract then do:
    delete bf_arh-trn-doc-contract.
  end.
  for each bf-reclc_arh-trn-doc-contract where bf-reclc_arh-trn-doc-contract.host-code     = tt-cnt-parts.host-code     and
                                               bf-reclc_arh-trn-doc-contract.contract-code = tt-cnt-parts.contract-code and
                                               bf-reclc_arh-trn-doc-contract.cli-type      = tt-cnt-parts.supp-type     and
                                               bf-reclc_arh-trn-doc-contract.cli-code      = tt-cnt-parts.supp-code     and
                                               bf-reclc_arh-trn-doc-contract.obj-type      = bf_trn-doc.obj-type        and
                                               bf-reclc_arh-trn-doc-contract.obj-code      = bf_trn-doc.obj-code        and
                                               bf-reclc_arh-trn-doc-contract.ext-doc-type  = bf_trn-doc.ext-doc-type    and
                                               bf-reclc_arh-trn-doc-contract.sum-type      = "":u                       and
                                               bf-reclc_arh-trn-doc-contract.fact-order    > bf_trn-doc.fact-order      use-index pi exclusive-lock on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
    if varinc-exp = 1 then do:
      assign
        bf-reclc_arh-trn-doc-contract.inc-sum-base        = bf-reclc_arh-trn-doc-contract.inc-sum-base        - tt-cnt-parts.sum-dsc-base-acc
        bf-reclc_arh-trn-doc-contract.inc-sum-rubl        = bf-reclc_arh-trn-doc-contract.inc-sum-rubl        - tt-cnt-parts.sum-dsc-rubl-acc
        bf-reclc_arh-trn-doc-contract.inc-sum-vat-base    = bf-reclc_arh-trn-doc-contract.inc-sum-vat-base    - tt-cnt-parts.vat-base-acc
        bf-reclc_arh-trn-doc-contract.inc-sum-vat-rubl    = bf-reclc_arh-trn-doc-contract.inc-sum-vat-rubl    - tt-cnt-parts.vat-rubl-acc
        bf-reclc_arh-trn-doc-contract.inc-sum-slt-base    = bf-reclc_arh-trn-doc-contract.inc-sum-slt-base    - tt-cnt-parts.slt-base-acc
        bf-reclc_arh-trn-doc-contract.inc-sum-slt-rubl    = bf-reclc_arh-trn-doc-contract.inc-sum-slt-rubl    - tt-cnt-parts.slt-rubl-acc
        bf-reclc_arh-trn-doc-contract.inc-sum-rdt-base    = bf-reclc_arh-trn-doc-contract.inc-sum-rdt-base    - tt-cnt-parts.road-tax-base-acc
        bf-reclc_arh-trn-doc-contract.inc-sum-rdt-rubl    = bf-reclc_arh-trn-doc-contract.inc-sum-rdt-rubl    - tt-cnt-parts.road-tax-rubl-acc
        bf-reclc_arh-trn-doc-contract.inc-sum-transp-base = bf-reclc_arh-trn-doc-contract.inc-sum-transp-base - tt-cnt-parts.transport-base-acc
        bf-reclc_arh-trn-doc-contract.inc-sum-transp-rubl = bf-reclc_arh-trn-doc-contract.inc-sum-transp-rubl - tt-cnt-parts.transport-rubl-acc
        bf-reclc_arh-trn-doc-contract.inc-sum-other-base  = bf-reclc_arh-trn-doc-contract.inc-sum-other-base  - tt-cnt-parts.other-base-acc
        bf-reclc_arh-trn-doc-contract.inc-sum-other-rubl  = bf-reclc_arh-trn-doc-contract.inc-sum-other-rubl  - tt-cnt-parts.other-rubl-acc
      .
    end.
    else do:
      assign
        bf-reclc_arh-trn-doc-contract.exp-sum-base        = bf-reclc_arh-trn-doc-contract.exp-sum-base        - tt-cnt-parts.sum-dsc-base-acc
        bf-reclc_arh-trn-doc-contract.exp-sum-rubl        = bf-reclc_arh-trn-doc-contract.exp-sum-rubl        - tt-cnt-parts.sum-dsc-rubl-acc
        bf-reclc_arh-trn-doc-contract.exp-sum-vat-base    = bf-reclc_arh-trn-doc-contract.exp-sum-vat-base    - tt-cnt-parts.vat-base-acc
        bf-reclc_arh-trn-doc-contract.exp-sum-vat-rubl    = bf-reclc_arh-trn-doc-contract.exp-sum-vat-rubl    - tt-cnt-parts.vat-rubl-acc
        bf-reclc_arh-trn-doc-contract.exp-sum-slt-base    = bf-reclc_arh-trn-doc-contract.exp-sum-slt-base    - tt-cnt-parts.slt-base-acc
        bf-reclc_arh-trn-doc-contract.exp-sum-slt-rubl    = bf-reclc_arh-trn-doc-contract.exp-sum-slt-rubl    - tt-cnt-parts.slt-rubl-acc
        bf-reclc_arh-trn-doc-contract.exp-sum-rdt-base    = bf-reclc_arh-trn-doc-contract.exp-sum-rdt-base    - tt-cnt-parts.road-tax-base-acc
        bf-reclc_arh-trn-doc-contract.exp-sum-rdt-rubl    = bf-reclc_arh-trn-doc-contract.exp-sum-rdt-rubl    - tt-cnt-parts.road-tax-rubl-acc
        bf-reclc_arh-trn-doc-contract.exp-sum-transp-base = bf-reclc_arh-trn-doc-contract.exp-sum-transp-base - tt-cnt-parts.transport-base-acc
        bf-reclc_arh-trn-doc-contract.exp-sum-transp-rubl = bf-reclc_arh-trn-doc-contract.exp-sum-transp-rubl - tt-cnt-parts.transport-rubl-acc
        bf-reclc_arh-trn-doc-contract.exp-sum-other-base  = bf-reclc_arh-trn-doc-contract.exp-sum-other-base  - tt-cnt-parts.other-base-acc
        bf-reclc_arh-trn-doc-contract.exp-sum-other-rubl  = bf-reclc_arh-trn-doc-contract.exp-sum-other-rubl  - tt-cnt-parts.other-rubl-acc
      .
    end.
  end.
end.
end.
end procedure.
/*перерасчет финансовых архивов по закрывающемуся складскому документу*/
procedure libtfarh_catrncnt :
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define buffer bf_gds-obj for ub.gds-obj.
define buffer bf_trn-doc for ub.trn-doc.
define buffer bf_arh-trn-doc-contract        for ub.arh-trn-doc-contract.
define buffer bf-prev_arh-trn-doc-contract   for ub.arh-trn-doc-contract.
define buffer bf-p-back_arh-trn-doc-contract for ub.arh-trn-doc-contract.
define buffer bf-reclc_arh-trn-doc-contract  for ub.arh-trn-doc-contract.
define buffer bf-zagl_arh-trn-doc-contract   for ub.arh-trn-doc-contract.
define variable varcalcfree-zone as logical no-undo.
define variable varinc-exp as integer no-undo.
do on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock no-error.
if not available bf_trn-doc then do:
  return error substitute ("Не найден складской документ с номером &1.", pardoc-code).
end.
run libtfarh_finincex in this-procedure (
    input  bf_trn-doc.ext-doc-type,
    output varinc-exp).
if varinc-exp <> 1 and
   varinc-exp <> 2 then do:
  return.
end.
if bf_trn-doc.status_ <> {&fact} then do:
  return error substitute ("Складской документ с номером &1 не в статусе факт. Создание финансовых архивов невозможно.", pardoc-code).
end.
if bf_trn-doc.fact-order = 0 or
   bf_trn-doc.fact-order = ? then do:
  return error substitute ("В складском документе с номером &1 не проставлен fact-order.", bf_trn-doc.doc-code).
end.
/*Захват договоров по всем партиям для исключения мертвых петель*/
run libtfarh_lkcontr (input bf_trn-doc.doc-code).
for each tt-cnt-parts on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
  delete tt-cnt-parts.
end.
run cntparts_calc-table-cnt in this-procedure (input pardoc-code).
for each tt-cnt-parts on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
  /*Ищем последнюю запись.
    Должна существовать обязательно.
    При первой записи при локировании должна была быть создана заглушка с fact-order = 0*/
  find last bf-prev_arh-trn-doc-contract where bf-prev_arh-trn-doc-contract.host-code     = tt-cnt-parts.host-code     and
                                               bf-prev_arh-trn-doc-contract.contract-code = tt-cnt-parts.contract-code and
                                               bf-prev_arh-trn-doc-contract.cli-type      = tt-cnt-parts.supp-type     and
                                               bf-prev_arh-trn-doc-contract.cli-code      = tt-cnt-parts.supp-code     and
                                               bf-prev_arh-trn-doc-contract.obj-type      = bf_trn-doc.obj-type        and
                                               bf-prev_arh-trn-doc-contract.obj-code      = bf_trn-doc.obj-code        and
                                               bf-prev_arh-trn-doc-contract.ext-doc-type  = bf_trn-doc.ext-doc-type    and
                                               bf-prev_arh-trn-doc-contract.sum-type      = "":u                       use-index pi exclusive-lock no-error.
  if not available bf-prev_arh-trn-doc-contract then do:
    return error substitute ("Не найдена запись финансовых архивов по фирме &1, договор &2, клиент &3 &4, объект &5 &6, расширенный тип документа &7, тип суммы &8.",
                             tt-cnt-parts.host-code,
                             tt-cnt-parts.contract-code,
                             tt-cnt-parts.supp-type,
                             tt-cnt-parts.supp-code,
                             bf_trn-doc.obj-type,
                             bf_trn-doc.obj-code,
                             bf_trn-doc.ext-doc-type,
                             "":u).
  end.
  if bf-prev_arh-trn-doc-contract.fact-order < bf_trn-doc.fact-order then do:
    if bf-prev_arh-trn-doc-contract.fact-order = 0 then do:
      /*заполняем заглушку, созданную при локировании*/
      find first bf_arh-trn-doc-contract where recid(bf_arh-trn-doc-contract) = recid(bf-prev_arh-trn-doc-contract) exclusive-lock.
      assign
        bf_arh-trn-doc-contract.fact-order = bf_trn-doc.fact-order
        bf_arh-trn-doc-contract.doc-code   = bf_trn-doc.doc-code
        bf_arh-trn-doc-contract.doc-date   = bf_trn-doc.doc-date
        bf_arh-trn-doc-contract.fact-date  = bf_trn-doc.fact-date
        bf_arh-trn-doc-contract.shift-date = bf_trn-doc.shift-date
        bf_arh-trn-doc-contract.shift-num  = bf_trn-doc.shift-num
        bf_arh-trn-doc-contract.shift-name = bf_trn-doc.shift-name
      .

    end.
    else do:
      create bf_arh-trn-doc-contract.
      assign
        bf_arh-trn-doc-contract.host-code     = tt-cnt-parts.host-code
        bf_arh-trn-doc-contract.contract-code = tt-cnt-parts.contract-code
        bf_arh-trn-doc-contract.cli-type      = tt-cnt-parts.supp-type
        bf_arh-trn-doc-contract.cli-code      = tt-cnt-parts.supp-code
        bf_arh-trn-doc-contract.obj-type      = bf_trn-doc.obj-type
        bf_arh-trn-doc-contract.obj-code      = bf_trn-doc.obj-code
        bf_arh-trn-doc-contract.ext-doc-type  = bf_trn-doc.ext-doc-type
        bf_arh-trn-doc-contract.sum-type      = "":u
        bf_arh-trn-doc-contract.fact-order    = bf_trn-doc.fact-order
        bf_arh-trn-doc-contract.doc-code      = bf_trn-doc.doc-code
        bf_arh-trn-doc-contract.doc-date      = bf_trn-doc.doc-date
        bf_arh-trn-doc-contract.fact-date     = bf_trn-doc.fact-date
        bf_arh-trn-doc-contract.shift-date    = bf_trn-doc.shift-date
        bf_arh-trn-doc-contract.shift-num     = bf_trn-doc.shift-num
        bf_arh-trn-doc-contract.shift-name    = bf_trn-doc.shift-name
      .
    end.
    if varinc-exp = 1 then do:
      assign
        bf_arh-trn-doc-contract.inc-sum-base        = bf-prev_arh-trn-doc-contract.inc-sum-base        + tt-cnt-parts.sum-dsc-base-acc
        bf_arh-trn-doc-contract.inc-sum-rubl        = bf-prev_arh-trn-doc-contract.inc-sum-rubl        + tt-cnt-parts.sum-dsc-rubl-acc
        bf_arh-trn-doc-contract.inc-sum-vat-base    = bf-prev_arh-trn-doc-contract.inc-sum-vat-base    + tt-cnt-parts.vat-base-acc
        bf_arh-trn-doc-contract.inc-sum-vat-rubl    = bf-prev_arh-trn-doc-contract.inc-sum-vat-rubl    + tt-cnt-parts.vat-rubl-acc
        bf_arh-trn-doc-contract.inc-sum-slt-base    = bf-prev_arh-trn-doc-contract.inc-sum-slt-base    + tt-cnt-parts.slt-base-acc
        bf_arh-trn-doc-contract.inc-sum-slt-rubl    = bf-prev_arh-trn-doc-contract.inc-sum-slt-rubl    + tt-cnt-parts.slt-rubl-acc
        bf_arh-trn-doc-contract.inc-sum-rdt-base    = bf-prev_arh-trn-doc-contract.inc-sum-rdt-base    + tt-cnt-parts.road-tax-base-acc
        bf_arh-trn-doc-contract.inc-sum-rdt-rubl    = bf-prev_arh-trn-doc-contract.inc-sum-rdt-rubl    + tt-cnt-parts.road-tax-rubl-acc
        bf_arh-trn-doc-contract.inc-sum-transp-base = bf-prev_arh-trn-doc-contract.inc-sum-transp-base + tt-cnt-parts.transport-base-acc
        bf_arh-trn-doc-contract.inc-sum-transp-rubl = bf-prev_arh-trn-doc-contract.inc-sum-transp-rubl + tt-cnt-parts.transport-rubl-acc
        bf_arh-trn-doc-contract.inc-sum-other-base  = bf-prev_arh-trn-doc-contract.inc-sum-other-base  + tt-cnt-parts.other-base-acc
        bf_arh-trn-doc-contract.inc-sum-other-rubl  = bf-prev_arh-trn-doc-contract.inc-sum-other-rubl  + tt-cnt-parts.other-rubl-acc
      .
    end.
    else do:
      assign
        bf_arh-trn-doc-contract.exp-sum-base        = bf-prev_arh-trn-doc-contract.exp-sum-base        + tt-cnt-parts.sum-dsc-base-acc
        bf_arh-trn-doc-contract.exp-sum-rubl        = bf-prev_arh-trn-doc-contract.exp-sum-rubl        + tt-cnt-parts.sum-dsc-rubl-acc
        bf_arh-trn-doc-contract.exp-sum-vat-base    = bf-prev_arh-trn-doc-contract.exp-sum-vat-base    + tt-cnt-parts.vat-base-acc
        bf_arh-trn-doc-contract.exp-sum-vat-rubl    = bf-prev_arh-trn-doc-contract.exp-sum-vat-rubl    + tt-cnt-parts.vat-rubl-acc
        bf_arh-trn-doc-contract.exp-sum-slt-base    = bf-prev_arh-trn-doc-contract.exp-sum-slt-base    + tt-cnt-parts.slt-base-acc
        bf_arh-trn-doc-contract.exp-sum-slt-rubl    = bf-prev_arh-trn-doc-contract.exp-sum-slt-rubl    + tt-cnt-parts.slt-rubl-acc
        bf_arh-trn-doc-contract.exp-sum-rdt-base    = bf-prev_arh-trn-doc-contract.exp-sum-rdt-base    + tt-cnt-parts.road-tax-base-acc
        bf_arh-trn-doc-contract.exp-sum-rdt-rubl    = bf-prev_arh-trn-doc-contract.exp-sum-rdt-rubl    + tt-cnt-parts.road-tax-rubl-acc
        bf_arh-trn-doc-contract.exp-sum-transp-base = bf-prev_arh-trn-doc-contract.exp-sum-transp-base + tt-cnt-parts.transport-base-acc
        bf_arh-trn-doc-contract.exp-sum-transp-rubl = bf-prev_arh-trn-doc-contract.exp-sum-transp-rubl + tt-cnt-parts.transport-rubl-acc
        bf_arh-trn-doc-contract.exp-sum-other-base  = bf-prev_arh-trn-doc-contract.exp-sum-other-base  + tt-cnt-parts.other-base-acc
        bf_arh-trn-doc-contract.exp-sum-other-rubl  = bf-prev_arh-trn-doc-contract.exp-sum-other-rubl  + tt-cnt-parts.other-rubl-acc
      .
    end.
  end.
  else do:
    find last bf-p-back_arh-trn-doc-contract where bf-p-back_arh-trn-doc-contract.host-code     = tt-cnt-parts.host-code     and
                                                   bf-p-back_arh-trn-doc-contract.contract-code = tt-cnt-parts.contract-code and
                                                   bf-p-back_arh-trn-doc-contract.cli-type      = tt-cnt-parts.supp-type     and
                                                   bf-p-back_arh-trn-doc-contract.cli-code      = tt-cnt-parts.supp-code     and
                                                   bf-p-back_arh-trn-doc-contract.obj-type      = bf_trn-doc.obj-type        and
                                                   bf-p-back_arh-trn-doc-contract.obj-code      = bf_trn-doc.obj-code        and
                                                   bf-p-back_arh-trn-doc-contract.ext-doc-type  = bf_trn-doc.ext-doc-type    and
                                                   bf-p-back_arh-trn-doc-contract.sum-type      = "":u                       and
                                                   bf-p-back_arh-trn-doc-contract.fact-order    < bf_trn-doc.fact-order      use-index pi exclusive-lock no-error.
    if available bf-p-back_arh-trn-doc-contract then do:
      /*первая запись*/
      if bf-p-back_arh-trn-doc-contract.fact-order = 0 then do:
        find first bf_arh-trn-doc-contract where recid(bf_arh-trn-doc-contract) = recid(bf-p-back_arh-trn-doc-contract) exclusive-lock.
        assign
          bf_arh-trn-doc-contract.fact-order = bf_trn-doc.fact-order.
      end.
      /*не первая запись*/
      else do:
        create bf_arh-trn-doc-contract.
        assign
          bf_arh-trn-doc-contract.host-code     = tt-cnt-parts.host-code
          bf_arh-trn-doc-contract.contract-code = tt-cnt-parts.contract-code
          bf_arh-trn-doc-contract.cli-type      = tt-cnt-parts.supp-type
          bf_arh-trn-doc-contract.cli-code      = tt-cnt-parts.supp-code
          bf_arh-trn-doc-contract.obj-type      = bf_trn-doc.obj-type
          bf_arh-trn-doc-contract.obj-code      = bf_trn-doc.obj-code
          bf_arh-trn-doc-contract.ext-doc-type  = bf_trn-doc.ext-doc-type
          bf_arh-trn-doc-contract.sum-type      = "":u
          bf_arh-trn-doc-contract.fact-order    = bf_trn-doc.fact-order
          bf_arh-trn-doc-contract.doc-code      = bf_trn-doc.doc-code
          bf_arh-trn-doc-contract.doc-date      = bf_trn-doc.doc-date
          bf_arh-trn-doc-contract.fact-date     = bf_trn-doc.fact-date
          bf_arh-trn-doc-contract.shift-date    = bf_trn-doc.shift-date
          bf_arh-trn-doc-contract.shift-num     = bf_trn-doc.shift-num
          bf_arh-trn-doc-contract.shift-name    = bf_trn-doc.shift-name
        .
      end.
      if varinc-exp = 1 then do:
        assign
          bf_arh-trn-doc-contract.inc-sum-base        = bf-p-back_arh-trn-doc-contract.inc-sum-base        + tt-cnt-parts.sum-dsc-base-acc
          bf_arh-trn-doc-contract.inc-sum-rubl        = bf-p-back_arh-trn-doc-contract.inc-sum-rubl        + tt-cnt-parts.sum-dsc-rubl-acc
          bf_arh-trn-doc-contract.inc-sum-vat-base    = bf-p-back_arh-trn-doc-contract.inc-sum-vat-base    + tt-cnt-parts.vat-base-acc
          bf_arh-trn-doc-contract.inc-sum-vat-rubl    = bf-p-back_arh-trn-doc-contract.inc-sum-vat-rubl    + tt-cnt-parts.vat-rubl-acc
          bf_arh-trn-doc-contract.inc-sum-slt-base    = bf-p-back_arh-trn-doc-contract.inc-sum-slt-base    + tt-cnt-parts.slt-base-acc
          bf_arh-trn-doc-contract.inc-sum-slt-rubl    = bf-p-back_arh-trn-doc-contract.inc-sum-slt-rubl    + tt-cnt-parts.slt-rubl-acc
          bf_arh-trn-doc-contract.inc-sum-rdt-base    = bf-p-back_arh-trn-doc-contract.inc-sum-rdt-base    + tt-cnt-parts.road-tax-base-acc
          bf_arh-trn-doc-contract.inc-sum-rdt-rubl    = bf-p-back_arh-trn-doc-contract.inc-sum-rdt-rubl    + tt-cnt-parts.road-tax-rubl-acc
          bf_arh-trn-doc-contract.inc-sum-transp-base = bf-p-back_arh-trn-doc-contract.inc-sum-transp-base + tt-cnt-parts.transport-base-acc
          bf_arh-trn-doc-contract.inc-sum-transp-rubl = bf-p-back_arh-trn-doc-contract.inc-sum-transp-rubl + tt-cnt-parts.transport-rubl-acc
          bf_arh-trn-doc-contract.inc-sum-other-base  = bf-p-back_arh-trn-doc-contract.inc-sum-other-base  + tt-cnt-parts.other-base-acc
          bf_arh-trn-doc-contract.inc-sum-other-rubl  = bf-p-back_arh-trn-doc-contract.inc-sum-other-rubl  + tt-cnt-parts.other-rubl-acc
        .
      end.
      else do:
        assign
          bf_arh-trn-doc-contract.exp-sum-base        = bf-p-back_arh-trn-doc-contract.exp-sum-base        + tt-cnt-parts.sum-dsc-base-acc
          bf_arh-trn-doc-contract.exp-sum-rubl        = bf-p-back_arh-trn-doc-contract.exp-sum-rubl        + tt-cnt-parts.sum-dsc-rubl-acc
          bf_arh-trn-doc-contract.exp-sum-vat-base    = bf-p-back_arh-trn-doc-contract.exp-sum-vat-base    + tt-cnt-parts.vat-base-acc
          bf_arh-trn-doc-contract.exp-sum-vat-rubl    = bf-p-back_arh-trn-doc-contract.exp-sum-vat-rubl    + tt-cnt-parts.vat-rubl-acc
          bf_arh-trn-doc-contract.exp-sum-slt-base    = bf-p-back_arh-trn-doc-contract.exp-sum-slt-base    + tt-cnt-parts.slt-base-acc
          bf_arh-trn-doc-contract.exp-sum-slt-rubl    = bf-p-back_arh-trn-doc-contract.exp-sum-slt-rubl    + tt-cnt-parts.slt-rubl-acc
          bf_arh-trn-doc-contract.exp-sum-rdt-base    = bf-p-back_arh-trn-doc-contract.exp-sum-rdt-base    + tt-cnt-parts.road-tax-base-acc
          bf_arh-trn-doc-contract.exp-sum-rdt-rubl    = bf-p-back_arh-trn-doc-contract.exp-sum-rdt-rubl    + tt-cnt-parts.road-tax-rubl-acc
          bf_arh-trn-doc-contract.exp-sum-transp-base = bf-p-back_arh-trn-doc-contract.exp-sum-transp-base + tt-cnt-parts.transport-base-acc
          bf_arh-trn-doc-contract.exp-sum-transp-rubl = bf-p-back_arh-trn-doc-contract.exp-sum-transp-rubl + tt-cnt-parts.transport-rubl-acc
          bf_arh-trn-doc-contract.exp-sum-other-base  = bf-p-back_arh-trn-doc-contract.exp-sum-other-base  + tt-cnt-parts.other-base-acc
          bf_arh-trn-doc-contract.exp-sum-other-rubl  = bf-p-back_arh-trn-doc-contract.exp-sum-other-rubl  + tt-cnt-parts.other-rubl-acc
        .
      end.
    end.
    /*самая ранняя запись*/
    else do:
      find first bf-zagl_arh-trn-doc-contract where bf-zagl_arh-trn-doc-contract.host-code     = bf_arh-trn-doc-contract.host-code     and
                                                    bf-zagl_arh-trn-doc-contract.contract-code = bf_arh-trn-doc-contract.contract-code and
                                                    bf-zagl_arh-trn-doc-contract.cli-type      = bf_arh-trn-doc-contract.cli-type      and
                                                    bf-zagl_arh-trn-doc-contract.cli-code      = bf_arh-trn-doc-contract.cli-code      and
                                                    bf-zagl_arh-trn-doc-contract.obj-type      = bf_arh-trn-doc-contract.obj-type      and
                                                    bf-zagl_arh-trn-doc-contract.obj-code      = bf_arh-trn-doc-contract.obj-code      and
                                                    bf-zagl_arh-trn-doc-contract.ext-doc-type  = bf_arh-trn-doc-contract.ext-doc-type  and
                                                    bf-zagl_arh-trn-doc-contract.sum-type      = bf_arh-trn-doc-contract.sum-type      and
                                                    bf-zagl_arh-trn-doc-contract.fact-order    > bf_arh-trn-doc-contract.fact-order    and
                                                    bf-zagl_arh-trn-doc-contract.doc-code      = "остаток"                             no-error.
      if not available bf-zagl_arh-trn-doc-contract then do:
        create bf_arh-trn-doc-contract.
        assign
          bf_arh-trn-doc-contract.host-code     = tt-cnt-parts.host-code
          bf_arh-trn-doc-contract.contract-code = tt-cnt-parts.contract-code
          bf_arh-trn-doc-contract.cli-type      = tt-cnt-parts.supp-type
          bf_arh-trn-doc-contract.cli-code      = tt-cnt-parts.supp-code
          bf_arh-trn-doc-contract.obj-type      = bf_trn-doc.obj-type
          bf_arh-trn-doc-contract.obj-code      = bf_trn-doc.obj-code
          bf_arh-trn-doc-contract.ext-doc-type  = bf_trn-doc.ext-doc-type
          bf_arh-trn-doc-contract.sum-type      = "":u
          bf_arh-trn-doc-contract.fact-order    = bf_trn-doc.fact-order
          bf_arh-trn-doc-contract.doc-code      = bf_trn-doc.doc-code
          bf_arh-trn-doc-contract.doc-date      = bf_trn-doc.doc-date
          bf_arh-trn-doc-contract.fact-date     = bf_trn-doc.fact-date
          bf_arh-trn-doc-contract.shift-date    = bf_trn-doc.shift-date
          bf_arh-trn-doc-contract.shift-num     = bf_trn-doc.shift-num
          bf_arh-trn-doc-contract.shift-name    = bf_trn-doc.shift-name
        .
        run partslib-clear-temp-parts in this-procedure no-error.
        if error-status:error then do:
          return error substitute ("Ошибка при запуске процедуры partslib-clear-temp-parts &1 &2.", return-value, error-status:get-message(1)).
        end.
        if varcalcfree-zone = no then do:
          /*остаток выставляем по свободной зоне на тот момент времени*/
          for each bf_gds-obj where bf_gds-obj.obj-type = bf_trn-doc.obj-type and
                                    bf_gds-obj.obj-code = bf_trn-doc.obj-code no-lock on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
            run partslib-init-temp-parts-by-factord in this-procedure
               (input bf_gds-obj.obj-type,
                input bf_gds-obj.obj-code,
                input bf_gds-obj.artic,
                input bf_gds-obj.prod-type,
                input bf_gds-obj.prod-code,
                input bf_trn-doc.fact-order,
                input true) no-error.
            if error-status:error then do:
              return error substitute ("Ошибка при запуске процедуры partslib-init-temp-parts-by-factord &1 &2 объект &3 &4 товар &5 &6 &7.", return-value, error-status:get-message(1), bf_gds-obj.obj-type, bf_gds-obj.obj-code, bf_gds-obj.artic, bf_gds-obj.prod-type, bf_gds-obj.prod-code).
            end.
          end.
          assign
            varcalcfree-zone = yes.
        end.
        for each tt-parts-for-cnt-lk on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
          delete tt-parts-for-cnt-lk.
        end.
        for each temp-parts on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
          if temp-parts.contract-code = tt-cnt-parts.contract-code then do:
            create tt-parts-for-cnt-lk.
            buffer-copy temp-parts to tt-parts-for-cnt-lk.
          end.
        end.
        find first tt-parts-for-cnt-lk no-error.
        if available tt-parts-for-cnt-lk then do:
          for each tt-cnt-parts-lk on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
            delete tt-cnt-parts-lk.
          end.
          run cntparts_calc-tt-table-cnt-lk in this-procedure.
          find first tt-cnt-parts-lk where tt-cnt-parts-lk.host-code     = tt-cnt-parts.host-code     and
                                           tt-cnt-parts-lk.contract-code = tt-cnt-parts.contract-code .
          if varinc-exp = 1 then do:
            assign
              bf_arh-trn-doc-contract.inc-sum-base        = tt-cnt-parts.sum-dsc-base-acc   + tt-cnt-parts-lk.sum-dsc-base-acc
              bf_arh-trn-doc-contract.inc-sum-rubl        = tt-cnt-parts.sum-dsc-rubl-acc   + tt-cnt-parts-lk.sum-dsc-rubl-acc
              bf_arh-trn-doc-contract.inc-sum-vat-base    = tt-cnt-parts.vat-base-acc       + tt-cnt-parts-lk.vat-base-acc
              bf_arh-trn-doc-contract.inc-sum-vat-rubl    = tt-cnt-parts.vat-rubl-acc       + tt-cnt-parts-lk.vat-rubl-acc
              bf_arh-trn-doc-contract.inc-sum-slt-base    = tt-cnt-parts.slt-base-acc       + tt-cnt-parts-lk.slt-base-acc
              bf_arh-trn-doc-contract.inc-sum-slt-rubl    = tt-cnt-parts.slt-rubl-acc       + tt-cnt-parts-lk.slt-rubl-acc
              bf_arh-trn-doc-contract.inc-sum-rdt-base    = tt-cnt-parts.road-tax-base-acc  + tt-cnt-parts-lk.road-tax-base-acc
              bf_arh-trn-doc-contract.inc-sum-rdt-rubl    = tt-cnt-parts.road-tax-rubl-acc  + tt-cnt-parts-lk.road-tax-rubl-acc
              bf_arh-trn-doc-contract.inc-sum-transp-base = tt-cnt-parts.transport-base-acc + tt-cnt-parts-lk.transport-base-acc
              bf_arh-trn-doc-contract.inc-sum-transp-rubl = tt-cnt-parts.transport-rubl-acc + tt-cnt-parts-lk.transport-rubl-acc
              bf_arh-trn-doc-contract.inc-sum-other-base  = tt-cnt-parts.other-base-acc     + tt-cnt-parts-lk.other-base-acc
              bf_arh-trn-doc-contract.inc-sum-other-rubl  = tt-cnt-parts.other-rubl-acc     + tt-cnt-parts-lk.other-rubl-acc
            .
          end.
          else do:
            assign
              bf_arh-trn-doc-contract.exp-sum-base        = tt-cnt-parts.sum-dsc-base-acc   - tt-cnt-parts-lk.sum-dsc-base-acc
              bf_arh-trn-doc-contract.exp-sum-rubl        = tt-cnt-parts.sum-dsc-rubl-acc   - tt-cnt-parts-lk.sum-dsc-rubl-acc
              bf_arh-trn-doc-contract.exp-sum-vat-base    = tt-cnt-parts.vat-base-acc       - tt-cnt-parts-lk.vat-base-acc
              bf_arh-trn-doc-contract.exp-sum-vat-rubl    = tt-cnt-parts.vat-rubl-acc       - tt-cnt-parts-lk.vat-rubl-acc
              bf_arh-trn-doc-contract.exp-sum-slt-base    = tt-cnt-parts.slt-base-acc       - tt-cnt-parts-lk.slt-base-acc
              bf_arh-trn-doc-contract.exp-sum-slt-rubl    = tt-cnt-parts.slt-rubl-acc       - tt-cnt-parts-lk.slt-rubl-acc
              bf_arh-trn-doc-contract.exp-sum-rdt-base    = tt-cnt-parts.road-tax-base-acc  - tt-cnt-parts-lk.road-tax-base-acc
              bf_arh-trn-doc-contract.exp-sum-rdt-rubl    = tt-cnt-parts.road-tax-rubl-acc  - tt-cnt-parts-lk.road-tax-rubl-acc
              bf_arh-trn-doc-contract.exp-sum-transp-base = tt-cnt-parts.transport-base-acc - tt-cnt-parts-lk.transport-base-acc
              bf_arh-trn-doc-contract.exp-sum-transp-rubl = tt-cnt-parts.transport-rubl-acc - tt-cnt-parts-lk.transport-rubl-acc
              bf_arh-trn-doc-contract.exp-sum-other-base  = tt-cnt-parts.other-base-acc     - tt-cnt-parts-lk.other-base-acc
              bf_arh-trn-doc-contract.exp-sum-other-rubl  = tt-cnt-parts.other-rubl-acc     - tt-cnt-parts-lk.other-rubl-acc
            .
          end.
        end.
        else do:
          if varinc-exp = 1 then do:
            assign
              bf_arh-trn-doc-contract.inc-sum-base        = tt-cnt-parts.sum-dsc-base-acc
              bf_arh-trn-doc-contract.inc-sum-rubl        = tt-cnt-parts.sum-dsc-rubl-acc
              bf_arh-trn-doc-contract.inc-sum-vat-base    = tt-cnt-parts.vat-base-acc
              bf_arh-trn-doc-contract.inc-sum-vat-rubl    = tt-cnt-parts.vat-rubl-acc
              bf_arh-trn-doc-contract.inc-sum-slt-base    = tt-cnt-parts.slt-base-acc
              bf_arh-trn-doc-contract.inc-sum-slt-rubl    = tt-cnt-parts.slt-rubl-acc
              bf_arh-trn-doc-contract.inc-sum-rdt-base    = tt-cnt-parts.road-tax-base-acc
              bf_arh-trn-doc-contract.inc-sum-rdt-rubl    = tt-cnt-parts.road-tax-rubl-acc
              bf_arh-trn-doc-contract.inc-sum-transp-base = tt-cnt-parts.transport-base-acc
              bf_arh-trn-doc-contract.inc-sum-transp-rubl = tt-cnt-parts.transport-rubl-acc
              bf_arh-trn-doc-contract.inc-sum-other-base  = tt-cnt-parts.other-base-acc
              bf_arh-trn-doc-contract.inc-sum-other-rubl  = tt-cnt-parts.other-rubl-acc
            .
          end.
          else do:
            assign
              bf_arh-trn-doc-contract.exp-sum-base        = tt-cnt-parts.sum-dsc-base-acc
              bf_arh-trn-doc-contract.exp-sum-rubl        = tt-cnt-parts.sum-dsc-rubl-acc
              bf_arh-trn-doc-contract.exp-sum-vat-base    = tt-cnt-parts.vat-base-acc
              bf_arh-trn-doc-contract.exp-sum-vat-rubl    = tt-cnt-parts.vat-rubl-acc
              bf_arh-trn-doc-contract.exp-sum-slt-base    = tt-cnt-parts.slt-base-acc
              bf_arh-trn-doc-contract.exp-sum-slt-rubl    = tt-cnt-parts.slt-rubl-acc
              bf_arh-trn-doc-contract.exp-sum-rdt-base    = tt-cnt-parts.road-tax-base-acc
              bf_arh-trn-doc-contract.exp-sum-rdt-rubl    = tt-cnt-parts.road-tax-rubl-acc
              bf_arh-trn-doc-contract.exp-sum-transp-base = tt-cnt-parts.transport-base-acc
              bf_arh-trn-doc-contract.exp-sum-transp-rubl = tt-cnt-parts.transport-rubl-acc
              bf_arh-trn-doc-contract.exp-sum-other-base  = tt-cnt-parts.other-base-acc
              bf_arh-trn-doc-contract.exp-sum-other-rubl  = tt-cnt-parts.other-rubl-acc
            .
          end.
        end.
      end. /*нет заглушки по остаткам впереди*/
    end. /*самая ранняя запись*/
    for each bf-reclc_arh-trn-doc-contract where bf-reclc_arh-trn-doc-contract.host-code     = tt-cnt-parts.host-code      and
                                                 bf-reclc_arh-trn-doc-contract.contract-code = tt-cnt-parts.contract-code  and
                                                 bf-reclc_arh-trn-doc-contract.cli-type      = tt-cnt-parts.supp-type      and
                                                 bf-reclc_arh-trn-doc-contract.cli-code      = tt-cnt-parts.supp-code      and
                                                 bf-reclc_arh-trn-doc-contract.obj-type      = bf_trn-doc.obj-type         and
                                                 bf-reclc_arh-trn-doc-contract.obj-code      = bf_trn-doc.obj-code         and
                                                 bf-reclc_arh-trn-doc-contract.ext-doc-type  = bf_trn-doc.ext-doc-type     and
                                                 bf-reclc_arh-trn-doc-contract.sum-type      = "":u                        and
                                                 bf-reclc_arh-trn-doc-contract.fact-order    > bf_trn-doc.fact-order       use-index pi exclusive-lock on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
      if varinc-exp = 1 then do:
        assign
          bf-reclc_arh-trn-doc-contract.inc-sum-base        = bf-reclc_arh-trn-doc-contract.inc-sum-base        + tt-cnt-parts.sum-dsc-base-acc
          bf-reclc_arh-trn-doc-contract.inc-sum-rubl        = bf-reclc_arh-trn-doc-contract.inc-sum-rubl        + tt-cnt-parts.sum-dsc-rubl-acc
          bf-reclc_arh-trn-doc-contract.inc-sum-vat-base    = bf-reclc_arh-trn-doc-contract.inc-sum-vat-base    + tt-cnt-parts.vat-base-acc
          bf-reclc_arh-trn-doc-contract.inc-sum-vat-rubl    = bf-reclc_arh-trn-doc-contract.inc-sum-vat-rubl    + tt-cnt-parts.vat-rubl-acc
          bf-reclc_arh-trn-doc-contract.inc-sum-slt-base    = bf-reclc_arh-trn-doc-contract.inc-sum-slt-base    + tt-cnt-parts.slt-base-acc
          bf-reclc_arh-trn-doc-contract.inc-sum-slt-rubl    = bf-reclc_arh-trn-doc-contract.inc-sum-slt-rubl    + tt-cnt-parts.slt-rubl-acc
          bf-reclc_arh-trn-doc-contract.inc-sum-rdt-base    = bf-reclc_arh-trn-doc-contract.inc-sum-rdt-base    + tt-cnt-parts.road-tax-base-acc
          bf-reclc_arh-trn-doc-contract.inc-sum-rdt-rubl    = bf-reclc_arh-trn-doc-contract.inc-sum-rdt-rubl    + tt-cnt-parts.road-tax-rubl-acc
          bf-reclc_arh-trn-doc-contract.inc-sum-transp-base = bf-reclc_arh-trn-doc-contract.inc-sum-transp-base + tt-cnt-parts.transport-base-acc
          bf-reclc_arh-trn-doc-contract.inc-sum-transp-rubl = bf-reclc_arh-trn-doc-contract.inc-sum-transp-rubl + tt-cnt-parts.transport-rubl-acc
          bf-reclc_arh-trn-doc-contract.inc-sum-other-base  = bf-reclc_arh-trn-doc-contract.inc-sum-other-base  + tt-cnt-parts.other-base-acc
          bf-reclc_arh-trn-doc-contract.inc-sum-other-rubl  = bf-reclc_arh-trn-doc-contract.inc-sum-other-rubl  + tt-cnt-parts.other-rubl-acc
        .
      end.
      else do:
        assign
          bf-reclc_arh-trn-doc-contract.exp-sum-base        = bf-reclc_arh-trn-doc-contract.exp-sum-base        + tt-cnt-parts.sum-dsc-base-acc
          bf-reclc_arh-trn-doc-contract.exp-sum-rubl        = bf-reclc_arh-trn-doc-contract.exp-sum-rubl        + tt-cnt-parts.sum-dsc-rubl-acc
          bf-reclc_arh-trn-doc-contract.exp-sum-vat-base    = bf-reclc_arh-trn-doc-contract.exp-sum-vat-base    + tt-cnt-parts.vat-base-acc
          bf-reclc_arh-trn-doc-contract.exp-sum-vat-rubl    = bf-reclc_arh-trn-doc-contract.exp-sum-vat-rubl    + tt-cnt-parts.vat-rubl-acc
          bf-reclc_arh-trn-doc-contract.exp-sum-slt-base    = bf-reclc_arh-trn-doc-contract.exp-sum-slt-base    + tt-cnt-parts.slt-base-acc
          bf-reclc_arh-trn-doc-contract.exp-sum-slt-rubl    = bf-reclc_arh-trn-doc-contract.exp-sum-slt-rubl    + tt-cnt-parts.slt-rubl-acc
          bf-reclc_arh-trn-doc-contract.exp-sum-rdt-base    = bf-reclc_arh-trn-doc-contract.exp-sum-rdt-base    + tt-cnt-parts.road-tax-base-acc
          bf-reclc_arh-trn-doc-contract.exp-sum-rdt-rubl    = bf-reclc_arh-trn-doc-contract.exp-sum-rdt-rubl    + tt-cnt-parts.road-tax-rubl-acc
          bf-reclc_arh-trn-doc-contract.exp-sum-transp-base = bf-reclc_arh-trn-doc-contract.exp-sum-transp-base + tt-cnt-parts.transport-base-acc
          bf-reclc_arh-trn-doc-contract.exp-sum-transp-rubl = bf-reclc_arh-trn-doc-contract.exp-sum-transp-rubl + tt-cnt-parts.transport-rubl-acc
          bf-reclc_arh-trn-doc-contract.exp-sum-other-base  = bf-reclc_arh-trn-doc-contract.exp-sum-other-base  + tt-cnt-parts.other-base-acc
          bf-reclc_arh-trn-doc-contract.exp-sum-other-rubl  = bf-reclc_arh-trn-doc-contract.exp-sum-other-rubl  + tt-cnt-parts.other-rubl-acc
        .
      end.
    end.
  end.
end.
end.
end procedure.

/*локирование всех финансовых архивов, связанных с складским документом*/
define temp-table tt-contract-code no-undo
field host-code     like ub.contract.host-code
field contract-code like ub.contract.contract-code
field cli-type      like ub.clients.obj-type
field cli-code      like ub.clients.obj-code
index pi is unique primary host-code contract-code cli-type cli-code.
procedure libtfarh_latrncnt :
define input parameter pardoc-code    like ub.trn-doc.doc-code no-undo.
define buffer bf_trn-doc  for ub.trn-doc.
define buffer bf_parts    for ub.parts.
define buffer bf_contract for ub.contract.
define variable varinc-exp as integer no-undo.
do on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock no-error.
if not available bf_trn-doc then do:
  return error substitute ("Не найден складской документ с номером &1.", pardoc-code).
end.
run libtfarh_finincex in this-procedure (
    input  bf_trn-doc.ext-doc-type,
    output varinc-exp).
if varinc-exp <> 1 and
   varinc-exp <> 2 then do:
  return.
end.
for each tt-contract-code on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
  delete tt-contract-code.
end.
for each bf_parts where bf_parts.out-code      = bf_trn-doc.doc-code and
                        bf_parts.obj-type      = bf_trn-doc.obj-type and
                        bf_parts.obj-code      = bf_trn-doc.obj-code no-lock on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
  find first tt-contract-code where tt-contract-code.host-code     = bf_parts.host-code     and
                                    tt-contract-code.contract-code = bf_parts.contract-code and
                                    tt-contract-code.cli-type      = bf_parts.supp-type     and
                                    tt-contract-code.cli-code      = bf_parts.supp-code     no-error.
  if not available tt-contract-code then do:
    create tt-contract-code.
    assign
      tt-contract-code.host-code     = bf_parts.host-code
      tt-contract-code.contract-code = bf_parts.contract-code
      tt-contract-code.cli-type      = bf_parts.supp-type
      tt-contract-code.cli-code      = bf_parts.supp-code
    .
  end.
end.
for each tt-contract-code on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
  run libtfarh_lptrncnt in this-procedure
                        (input tt-contract-code.host-code,
                         input tt-contract-code.contract-code,
                         input tt-contract-code.cli-type,
                         input tt-contract-code.cli-code,
                         input bf_trn-doc.obj-type,
                         input bf_trn-doc.obj-code,
                         input bf_trn-doc.ext-doc-type,
                         input "":u).
end.
end.
end procedure.

/*локирование одной записи финансовых архивов по закрывающемуся складскому документу*/
procedure libtfarh_lptrncnt :
define input parameter parhost-code     like ub.trn-doc.host-code      no-undo.
define input parameter parcontract-code like ub.contract.contract-code no-undo.
define input parameter parcli-type      like ub.clients.obj-type       no-undo.
define input parameter parcli-code      like ub.clients.obj-code       no-undo.
define input parameter parobj-type      like ub.trn-doc.obj-type       no-undo.
define input parameter parobj-code      like ub.trn-doc.obj-code       no-undo.
define input parameter parext-doc-type  like ub.trn-doc.ext-doc-type   no-undo.
define input parameter parsum-type      as   character                 no-undo.
define buffer bf_arh-trn-doc-contract for ub.arh-trn-doc-contract.
do on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
/*локируем последнюю запись в разрезе*/
find last bf_arh-trn-doc-contract where bf_arh-trn-doc-contract.host-code      = parhost-code     and
                                        bf_arh-trn-doc-contract.contract-code  = parcontract-code and
                                        bf_arh-trn-doc-contract.cli-type       = parcli-type      and
                                        bf_arh-trn-doc-contract.cli-code       = parcli-code      and
                                        bf_arh-trn-doc-contract.obj-type       = parobj-type      and
                                        bf_arh-trn-doc-contract.obj-code       = parobj-code      and
                                        bf_arh-trn-doc-contract.ext-doc-type   = parext-doc-type  and
                                        bf_arh-trn-doc-contract.sum-type       = parsum-type      exclusive-lock no-error.
if not available bf_arh-trn-doc-contract then do:
  /*создаем запись с fact-order = 0 !!! для того, чтобы если будут инициированы два процесса
    впервые задающие запись в этом разрезе, не были созданы две начальные записи. второй процесс
    при этом отвалится по уникальности индекса. при расчете fact-order будет заменен на реальный.*/
  create bf_arh-trn-doc-contract.
  assign
    bf_arh-trn-doc-contract.host-code      = parhost-code
    bf_arh-trn-doc-contract.contract-code  = parcontract-code
    bf_arh-trn-doc-contract.cli-type       = parcli-type
    bf_arh-trn-doc-contract.cli-code       = parcli-code
    bf_arh-trn-doc-contract.obj-type       = parobj-type
    bf_arh-trn-doc-contract.obj-code       = parobj-code
    bf_arh-trn-doc-contract.ext-doc-type   = parext-doc-type
    bf_arh-trn-doc-contract.sum-type       = parsum-type
    bf_arh-trn-doc-contract.fact-order     = 0.
end.
end.
end procedure.

define temp-table tt-parts-cntr no-undo like ub.parts.
procedure libtfarh_lkcontr:
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define buffer bf_trn-doc  for ub.trn-doc.
define buffer bf_parts    for ub.parts.
define buffer bf_contract for ub.contract.
define buffer bf_host-lk  for ub.host-lk.
do transaction on error undo, return error return-value :
find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code exclusive-lock.
for each tt-parts-cntr on error undo, return error return-value :
  delete tt-parts-cntr.
end.
for each bf_parts where bf_parts.out-code = bf_trn-doc.doc-code on error undo, return error return-value :
  create tt-parts-cntr.
  buffer-copy bf_parts to tt-parts-cntr.
end.
/*Сортировка в порядке договоров*/
for each tt-parts-cntr use-index contr on error undo, return error return-value :
  if tt-parts-cntr.contract-code <> 0 then do:
    find first bf_contract where bf_contract.host-code     = tt-parts-cntr.host-code     and
                                 bf_contract.contract-code = tt-parts-cntr.contract-code exclusive-lock.
  end.
end.
end.
end procedure.