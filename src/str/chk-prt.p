block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: 2014/01/27 14:27:46 $
$Workfile: chk-prt.p $
$Archive: str/chk-prt.p $

Проверка того, что признаки соответствует строке документа

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич
Дата создания: 03/27/06


*/


define input parameter par-line-rec as  recid   no-undo.
define input parameter par-mes      as  logical no-undo.
define parameter buffer t-doc for ub.trn-doc .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: 2014/01/27 14:27:46 $":U .
def var vss-workfile    as character no-undo init "$Workfile: chk-prt.p $":U .
def var vss-archive     as character no-undo init "$Archive: str/chk-prt.p $":U .
def var vss-description as character no-undo init "Проверка того, что признаки соответствует строке документа".
{ cmp/vssrevis.i "substitute('&1|&2':u,par-line-rec,par-mes)" }
{ cmp/str-glbl.i }

/* чтобы не ругалась в статусе факт-, на неразнесенный предварительно товар */
if t-doc.status_ = {&fact} then do:
  return . /* --->>>--- */
end.

find ub.doc-line exclusive-lock
  where recid (ub.doc-line) = par-line-rec
  .

/* проверяем по признакам */
for each ub.gds-dtl
  where ub.gds-dtl.doc-code  = ub.doc-line.doc-code
    and ub.gds-dtl.artic     = ub.doc-line.artic
    and ub.gds-dtl.prod-type = ub.doc-line.prod-type
    and ub.gds-dtl.prod-code = ub.doc-line.prod-code
:

  if  ub.gds-dtl.fact-qnty = 0
  and ub.gds-dtl.doc-qnty  = 0 then do:
    if t-doc.ext-doc-type <> {&TDEDT_Corr_Acc_Price}   and
       t-doc.ext-doc-type <> {&TDEDT_Chg_Purch_Code}   and
       t-doc.ext-doc-type <> {&TDEDT_Corr_Minus_Parts} then do:
      delete ub.gds-dtl.
    end.
  end.

  else do:
    accumulate
      ub.gds-dtl.prt-code (count)
      ub.gds-dtl.doc-qnty (total)
      ub.gds-dtl.fact-qnty (total)
    .
  end.
end.

/* проверяем по признакам */
if ( t-doc.flag_ = false
     and (accum total ub.gds-dtl.doc-qnty) <> ub.doc-line.doc-qnty
   )
or ( t-doc.flag_ = true
     and (accum total ub.gds-dtl.fact-qnty) <> ub.doc-line.fact-qnty
   ) then do:
  if par-mes then do:
    message
      "Количество по шкале (по всем признакам) не совпадает с количеством по артикулу."
      view-as alert-box .
  end.
  assign
    ub.doc-line.prt-ok = false
  .
end.
else do:
  assign
    ub.doc-line.prt-ok = true
  .
end.

/* коррекция в случае нулевого количества по факту */
if  (accum count ub.gds-dtl.prt-code) = 0
and (ub.doc-line.prt-OK = false ) then do:
  assign
    ub.doc-line.prt-OK = ?
  .
end.