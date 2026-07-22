block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: invdcfrd.p $
$Archive: str/invdcfrd.p $

Считываем все конфигурационные параметры для i n v - d o c . w

Автор: Чернова Светлана Александровна
Дата создания: 09/17/08
Author: Svetlana Chernova
Creation date: 09/17/08

Автор1: Суслов Алексей Юрьевич
Дата создания: 03/24/06


*/
define input  parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define output parameter parinvclcspvalue as character no-undo.
define output parameter parprtvalue      as character no-undo.
define output parameter parr-b           as character no-undo.
define output parameter par-is-cdinv     as character no-undo .

{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getsect.i def }

define variable var-type1 as character no-undo.
define variable var-type2 as character no-undo.
define variable var-type3 as character no-undo.
define variable var-type4 as character no-undo.
define variable var-type5 as character no-undo.

define buffer bf_trn-doc for ub.trn-doc.
find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock.
{ gbl/conf-rd.i "'is-prt'":u   "''"                 "''"                0                   "''" "''" "''" yes parprtvalue      var-type2 no-error }
{ gbl/curr-r-b.i
  parr-b
}

{ gbl/conf-rd.i "'is-cdinv'":u      "''"            "''"                0                   "''" "''" "''" yes par-is-cdinv         var-type5 no-error }
  if error-status :error or
    par-is-cdinv  <> "yes"
  then do:
    assign par-is-cdinv = "no".
  end.

  { gbl/getsect.i run bf_trn-doc.obj-type bf_trn-doc.obj-code {&attr-inv-obj} }
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'invclcsp'  then parinvclcspvalue = string( thbjattr_thbj-attr.property-value-logical, "yes/no").
  end.