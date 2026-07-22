block-level on error undo, throw.
/*

$Revision: b2dec4207fce, 1690, rls $
$Author: EShklyar $
$Date: Tue Dec 11 10:07:35 2018 +0300 $
$Workfile: specifNDS.p $
$Archive: utl/specifNDS.p $

Утилита перевода спецификаций на НДС 20%

Автор: Шкляр Елена
Дата создания: 07/23/08
Author: Elena Shklyar
Creation date: 07/23/08

*/
define input parameter parParentProc as handle no-undo .

define variable vss-revision    as character no-undo initial "$Revision: b2dec4207fce, 1690, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: Tue Dec 11 10:07:35 2018 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: specifNDS.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/specifNDS.p $":U .
define variable vss-description as character no-undo initial "Утилита перевода спецификаций на НДС 20%".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/str-glbl.i }

define buffer buf_contract        for ub.contract .
define buffer buf_contract-specif for ub.contract-specif .
    
for each buf_contract exclusive-lock where buf_contract.status_ = {&current-contr} and (buf_contract.contract-date-end > today or buf_contract.contract-date-end = ?),
  each buf_contract-specif exclusive-lock where buf_contract-specif.contract-num = buf_contract.contract-code and buf_contract-specif.VAT-pc = 18:
      buf_contract-specif.VAT-pc = 20.
end.  


MESSAGE "Перевод спецификаций на НДС 20% - завершён"
  VIEW-AS ALERT-BOX.
             