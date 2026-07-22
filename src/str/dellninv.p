block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dellninv.p $
$Archive: str/dellninv.p $

Удаление строки инвентаризации

Автор: Чернова Светлана Александровна
Дата создания: 03/24/08
Author: Svetlana Chernova
Creation date: 03/24/08

Автор1: Суслов Алексей Юрьевич
Дата создания: 03/24/06


*/

define parameter buffer doc-line for ub.doc-line.

{ cmp/str-glbl.i }
{ str/lib-trn.i  }
{ str/trdcalib.i }

define variable varinvclcspvalue                    as   character no-undo.
define variable varinvclcsptype                     as   character no-undo.
define variable varinvclcwtol                       as   logical   no-undo.
define variable prtvalue   as character no-undo.
define variable partsvalue as character initial ?   no-undo.
define variable varr-b     as character no-undo.
define variable is-cdinv   as character no-undo .
define variable p-value as character no-undo.
define variable p-type  as character no-undo.

find first trn-doc where trn-doc.doc-code = doc-line.doc-code.
assign
  varinvclcspvalue = "no".
run str/invdcfrd.p (input  trn-doc.doc-code,
                output varinvclcspvalue,
                output prtvalue,
                output varr-b,
                output is-cdinv ).
{ str/tdat-val.i
    trn-doc.doc-code
    {&trdcattr-clcaswt}
    p-value
    p-type
}
assign
  varinvclcwtol = (if p-value = "yes" then yes else no).
run trg/rsrv-del.p
  (input doc-line.doc-code
  ,input doc-line.artic
  ,input doc-line.prod-type
  ,input doc-line.prod-code
  ) .
for each gds-dtl where gds-dtl.doc-code  = doc-line.doc-code  and
                       gds-dtl.artic     = doc-line.artic     and
                       gds-dtl.prod-type = doc-line.prod-type and
                       gds-dtl.prod-code = doc-line.prod-code on error undo, return error return-value :
  delete gds-dtl.
end.
delete doc-line.
if trn-doc.status_ = {&permitted} and
   trn-doc.flag_   = no           then do:
  { str/reclctsl.i
    trn-doc.doc-code
    {&sum-before-doc}
  }
  if varinvclcwtol then do:
    { str/reclctsl.i
      trn-doc.doc-code
      {&sum-wastage-doc}
    }
  end.
  if varinvclcspvalue = "yes" then do:
    { str/reclctsl.i
      trn-doc.doc-code
      {&sum-before-cli-doc}
    }
    if varinvclcwtol then do:
      { str/reclctsl.i
        trn-doc.doc-code
        {&sum-wastage-cli-doc}
      }
    end.
  end.
end.