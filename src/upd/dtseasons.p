block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: DTSeasons.p $
$Archive: utl/DTSeasons.p $

Первоначальная выгрузка ДТ-сезонов 

Автор: Белоусов Илья Александрович
Дата создания: 12/05/08
Author: Ilia Belousov
Creation date: 12/05/08

Input:

Output:

*/
define input  parameter parparentproc as handle no-undo.
define input  parameter iparam        as character no-undo.
define output parameter oOk           as logical no-undo.

{ cmp/str-glbl.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

for each ub.gds-obj-attr no-lock where ub.gds-obj-attr.attr-code = "dt-seasons" and 
  ub.gds-obj-attr.obj-code = v-cntxt-obj-code and
  ub.gds-obj-attr.obj-type = v-cntxt-obj-type:
  find first ub.goods-attr no-lock where ub.goods-attr.gds-code = ub.gds-obj-attr.gds-code and
    ub.goods-attr.attr-code = "fuel-type" and
    ub.goods-attr.attr-value = "diesel" no-error .
  find first ub.code no-lock where ub.code.parent = "DTseasons" and ub.code.code = ub.gds-obj-attr.attr-value no-error .
  if available (ub.goods-attr) and available (ub.code) then 
  do:
    run bge\send1cerp.p (?,
      this-procedure,
      this-procedure,
      "DTSeasons",
      (buffer ub.gds-obj-attr:handle),
      ?,
      ?) no-error.  
    if error-status:error 
      then 
    do:
      message return-value view-as alert-box.
    end.
        
  end.             
end.
oOk = true.