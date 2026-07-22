/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Разбивка складского документа по договорам поставки

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич

*/
define temp-table tt-parts-for-cnt{1} no-undo like ub.parts.

define temp-table tt-cnt-parts{1} no-undo
field host-code          like ub.contract.host-code
field contract-code      like ub.contract.contract-code
field sum-dsc-base-acc   like ub.doc-line.price-base
field sum-dsc-rubl-acc   like ub.doc-line.price-base
field vat-base-acc       like ub.doc-line.price-base
field vat-rubl-acc       like ub.doc-line.price-base
field slt-base-acc       like ub.doc-line.price-base
field slt-rubl-acc       like ub.doc-line.price-base
field road-tax-base-acc  like ub.doc-line.price-base
field road-tax-rubl-acc  like ub.doc-line.price-base
field excise-base-acc    like ub.doc-line.price-base
field excise-rubl-acc    like ub.doc-line.price-base
field transport-base-acc like ub.doc-line.price-base
field transport-rubl-acc like ub.doc-line.price-base
field other-base-acc     like ub.doc-line.price-base
field other-rubl-acc     like ub.doc-line.price-base
field contract-prn-code  like ub.contract.contract-prn-code
field supp-type          like ub.parts.supp-type
field supp-code          like ub.parts.supp-code
field supp-name          like ub.clients.obj-name
index pi is unique primary host-code contract-code supp-type supp-code.

/*обсчет  складских документов в разбивке по договорам поставщика*/
procedure cntparts_calc-table-cnt{1} :
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define buffer bf_trn-doc  for ub.trn-doc.
define buffer bf_parts    for ub.parts.
do on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2) ) :
find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock no-error.
if not available bf_trn-doc then do:
  return error substitute("Не найден документ с номером &1.", pardoc-code).
end.
for each tt-parts-for-cnt{1} on error undo, return error return-value :
  delete tt-parts-for-cnt{1}.
end.
for each bf_parts where bf_parts.out-code = bf_trn-doc.doc-code no-lock on error undo, return error return-value :
  create tt-parts-for-cnt{1}.
  buffer-copy bf_parts to tt-parts-for-cnt{1}.
end.
run cntparts_calc-tt-table-cnt{1} in this-procedure.
end.
end procedure.

procedure cntparts_calc-tt-table-cnt{1}:
define buffer bf_contract for ub.contract.
define buffer bf_clients  for ub.clients.
do on error undo, return error return-value :
for each tt-cnt-parts{1} on error undo, return error return-value :
  delete tt-cnt-parts{1}.
end.
for each tt-parts-for-cnt{1} on error undo, return error return-value :
  for each tt-allsum on error undo, return error return-value :
    delete tt-allsum.
  end.
  for each tt-clcparts on error undo, return error return-value :
    delete tt-clcparts.
  end.
  create tt-clcparts.
  buffer-copy tt-parts-for-cnt{1} to tt-clcparts.
  run clcprtsl_calc-parts (
      input recid(tt-clcparts),
      input no,
      input no,
      input 0,
      input 0,
      input 0,
      input 0,
      input 0,
      input 0,
      input 0,
      input 0,
      input 0,
      input 0,
      input 0,
      input 0,
      input 0,
      input 0) no-error.
  if error-status:error then do:
    return error substitute ("Ошибка при вызове процедуры clcprtsl_calc-parts &1 &2 &3.", return-value, error-status:get-message(1), error-status:get-message(2)).
  end.
  find first tt-allsum where tt-allsum.sum-type = {&sum-general}.
  find first tt-cnt-parts{1} where tt-cnt-parts{1}.host-code     = tt-parts-for-cnt{1}.host-code     and
                                   tt-cnt-parts{1}.contract-code = tt-parts-for-cnt{1}.contract-code and
                                   tt-cnt-parts{1}.supp-type     = tt-parts-for-cnt{1}.supp-type     and
                                   tt-cnt-parts{1}.supp-code     = tt-parts-for-cnt{1}.supp-code     no-error.
  if not available tt-cnt-parts{1} then do:
    create tt-cnt-parts{1}.
    assign
      tt-cnt-parts{1}.host-code     = tt-parts-for-cnt{1}.host-code
      tt-cnt-parts{1}.contract-code = tt-parts-for-cnt{1}.contract-code.
    if tt-parts-for-cnt{1}.contract-code <> 0 then do:
      find first bf_contract where bf_contract.host-code     = tt-parts-for-cnt{1}.host-code     and
                                   bf_contract.contract-code = tt-parts-for-cnt{1}.contract-code no-lock no-error.
      if not available bf_contract then do:
        return error substitute ("Не найден договор по фирме &1 с внутренним кодом &2.", tt-parts-for-cnt{1}.host-code, tt-parts-for-cnt{1}.contract-code).
      end.
      assign
        tt-cnt-parts{1}.contract-prn-code = bf_contract.contract-prn-code.
    end.
    else do:
      assign
        tt-cnt-parts{1}.contract-prn-code = "без договора".
    end.
    find first bf_clients where bf_clients.obj-type = tt-parts-for-cnt{1}.supp-type and
                                bf_clients.obj-code = tt-parts-for-cnt{1}.supp-code no-lock no-error.
    if not available bf_clients then do:
      return error substitute ("Не найден поставщик &1 &2.", tt-parts-for-cnt{1}.supp-type, tt-parts-for-cnt{1}.supp-code).
    end.
    assign
      tt-cnt-parts{1}.supp-type = bf_clients.obj-type
      tt-cnt-parts{1}.supp-code = bf_clients.obj-code
      tt-cnt-parts{1}.supp-name = bf_clients.obj-name.
  end.
  assign
    tt-cnt-parts{1}.sum-dsc-base-acc   = tt-cnt-parts{1}.sum-dsc-base-acc   + tt-allsum.sum-dsc-base-acc
    tt-cnt-parts{1}.sum-dsc-rubl-acc   = tt-cnt-parts{1}.sum-dsc-rubl-acc   + tt-allsum.sum-dsc-rubl-acc
    tt-cnt-parts{1}.vat-base-acc       = tt-cnt-parts{1}.vat-base-acc       + tt-allsum.vat-base-acc
    tt-cnt-parts{1}.vat-rubl-acc       = tt-cnt-parts{1}.vat-rubl-acc       + tt-allsum.vat-rubl-acc
    tt-cnt-parts{1}.slt-base-acc       = tt-cnt-parts{1}.slt-base-acc       + tt-allsum.slt-base-acc
    tt-cnt-parts{1}.slt-rubl-acc       = tt-cnt-parts{1}.slt-rubl-acc       + tt-allsum.slt-rubl-acc
    tt-cnt-parts{1}.road-tax-base-acc  = tt-cnt-parts{1}.road-tax-base-acc  + tt-allsum.road-tax-base-acc
    tt-cnt-parts{1}.road-tax-rubl-acc  = tt-cnt-parts{1}.road-tax-rubl-acc  + tt-allsum.road-tax-rubl-acc
    tt-cnt-parts{1}.excise-base-acc    = tt-cnt-parts{1}.excise-base-acc    + tt-allsum.excise-base-acc
    tt-cnt-parts{1}.excise-rubl-acc    = tt-cnt-parts{1}.excise-rubl-acc    + tt-allsum.excise-rubl-acc
    tt-cnt-parts{1}.transport-base-acc = tt-cnt-parts{1}.transport-base-acc + tt-allsum.transport-base-acc
    tt-cnt-parts{1}.transport-rubl-acc = tt-cnt-parts{1}.transport-rubl-acc + tt-allsum.transport-rubl-acc
    tt-cnt-parts{1}.other-base-acc     = tt-cnt-parts{1}.other-base-acc     + tt-allsum.other-base-acc
    tt-cnt-parts{1}.other-rubl-acc     = tt-cnt-parts{1}.other-rubl-acc     + tt-allsum.other-rubl-acc
  .
end.
end.
end procedure.


/*обсчет удаленных складских документов в разбивке по договорам поставщика*/
procedure cntparts_calc-c-table-cnt{1} :
define input parameter pardoc-code like ub.c-trn-doc.doc-code no-undo.
define input parameter parchip-num like ub.c-trn-doc.chip-num no-undo.
define buffer bf_c-trn-doc for ub.c-trn-doc.
define buffer bf_c-parts   for ub.c-parts.
define buffer bf_contract for ub.contract.
define buffer bf_clients  for ub.clients.
do on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2) ) :
find first bf_c-trn-doc where bf_c-trn-doc.doc-code = pardoc-code and
                              bf_c-trn-doc.chip-num = parchip-num no-lock no-error.
if not available bf_c-trn-doc then do:
  return error substitute("Не найден удаленный документ с номером &1.", pardoc-code).
end.
for each bf_c-parts where bf_c-parts.out-code = bf_c-trn-doc.doc-code and
                          bf_c-parts.chip-num = bf_c-trn-doc.chip-num no-lock on error undo, return error return-value :
  for each tt-allsum on error undo, return error return-value :
    delete tt-allsum.
  end.
  for each tt-clcparts on error undo, return error return-value :
    delete tt-clcparts.
  end.
  create tt-clcparts.
  buffer-copy bf_c-parts to tt-clcparts.
  run clcprtsl_calc-parts (
      input recid(tt-clcparts),
      input no,
      input no,
      input 0,
      input 0,
      input 0,
      input 0,
      input 0,
      input 0,
      input 0,
      input 0,
      input 0,
      input 0,
      input 0,
      input 0,
      input 0,
      input 0) no-error.
  if error-status:error then do:
    return error substitute ("Ошибка при вызове процедуры clcprtsl_calc-parts &1 &2 &3.", return-value, error-status:get-message(1), error-status:get-message(2)).
  end.
  find first tt-allsum where tt-allsum.sum-type = {&sum-general}.
  find first tt-cnt-parts{1} where tt-cnt-parts{1}.host-code     = bf_c-parts.host-code     and
                                   tt-cnt-parts{1}.contract-code = bf_c-parts.contract-code and
                                   tt-cnt-parts{1}.supp-type     = bf_c-parts.supp-type     and
                                   tt-cnt-parts{1}.supp-code     = bf_c-parts.supp-code     no-error.
  if not available tt-cnt-parts{1} then do:
    create tt-cnt-parts{1}.
    assign
      tt-cnt-parts{1}.host-code     = bf_c-parts.host-code
      tt-cnt-parts{1}.contract-code = bf_c-parts.contract-code.
    if bf_c-parts.contract-code <> 0 then do:
      find first bf_contract where bf_contract.host-code     = bf_c-parts.host-code     and
                                   bf_contract.contract-code = bf_c-parts.contract-code no-lock no-error.
      if not available bf_contract then do:
        return error substitute ("Не найден договор по фирме &1 с внутренним кодом &2.", bf_c-parts.host-code, bf_c-parts.contract-code).
      end.
      assign
        tt-cnt-parts{1}.contract-prn-code = bf_contract.contract-prn-code.
    end.
    else do:
      assign
        tt-cnt-parts{1}.contract-prn-code = "без договора".
    end.
    find first bf_clients where bf_clients.obj-type = bf_c-parts.supp-type and
                                bf_clients.obj-code = bf_c-parts.supp-code no-lock no-error.
    if not available bf_clients then do:
      return error substitute ("Не найден поставщик &1 &2.", bf_c-parts.supp-type, bf_c-parts.supp-code).
    end.
    assign
      tt-cnt-parts{1}.supp-type = bf_clients.obj-type
      tt-cnt-parts{1}.supp-code = bf_clients.obj-code
      tt-cnt-parts{1}.supp-name = bf_clients.obj-name.
  end.
  assign
    tt-cnt-parts{1}.sum-dsc-base-acc   = tt-cnt-parts{1}.sum-dsc-base-acc   + tt-allsum.sum-dsc-base-acc
    tt-cnt-parts{1}.sum-dsc-rubl-acc   = tt-cnt-parts{1}.sum-dsc-rubl-acc   + tt-allsum.sum-dsc-rubl-acc
    tt-cnt-parts{1}.vat-base-acc       = tt-cnt-parts{1}.vat-base-acc       + tt-allsum.vat-base-acc
    tt-cnt-parts{1}.vat-rubl-acc       = tt-cnt-parts{1}.vat-rubl-acc       + tt-allsum.vat-rubl-acc
    tt-cnt-parts{1}.slt-base-acc       = tt-cnt-parts{1}.slt-base-acc       + tt-allsum.slt-base-acc
    tt-cnt-parts{1}.slt-rubl-acc       = tt-cnt-parts{1}.slt-rubl-acc       + tt-allsum.slt-rubl-acc
    tt-cnt-parts{1}.road-tax-base-acc  = tt-cnt-parts{1}.road-tax-base-acc  + tt-allsum.road-tax-base-acc
    tt-cnt-parts{1}.road-tax-rubl-acc  = tt-cnt-parts{1}.road-tax-rubl-acc  + tt-allsum.road-tax-rubl-acc
    tt-cnt-parts{1}.excise-base-acc    = tt-cnt-parts{1}.excise-base-acc    + tt-allsum.excise-base-acc
    tt-cnt-parts{1}.excise-rubl-acc    = tt-cnt-parts{1}.excise-rubl-acc    + tt-allsum.excise-rubl-acc
    tt-cnt-parts{1}.transport-base-acc = tt-cnt-parts{1}.transport-base-acc + tt-allsum.transport-base-acc
    tt-cnt-parts{1}.transport-rubl-acc = tt-cnt-parts{1}.transport-rubl-acc + tt-allsum.transport-rubl-acc
    tt-cnt-parts{1}.other-base-acc     = tt-cnt-parts{1}.other-base-acc     + tt-allsum.other-base-acc
    tt-cnt-parts{1}.other-rubl-acc     = tt-cnt-parts{1}.other-rubl-acc     + tt-allsum.other-rubl-acc
  .
end.
end.
end procedure.
