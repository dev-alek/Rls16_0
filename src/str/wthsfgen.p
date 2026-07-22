block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: wthsfgen.p $
$Archive: str/wthsfgen.p $

Процедура генерации номера счета-фактуры для документов МЦ

Автор: Гридчина Полина Дмитриевна
Дата создания: 04/11/08
Author: Polina Gridchina
Creation date: 04/11/08

Input:

Output:

*/
define input parameter parobj-type like ub.wth-doc.obj-type no-undo .
define input parameter parobj-code like ub.wth-doc.obj-code no-undo .
define output parameter par-nsf as char no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wthsfgen.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/wthsfgen.p $":U .
define variable vss-description as character no-undo init "Процедура генерации номера счета-фактуры для документов МЦ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ gbl/thbjattr.i }

define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-param-type as character no-undo .
define variable v-stfactpref as character no-undo .
define variable v-numsfact   as integer no-undo .

define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .

define buffer buf_wth-doc   for ub.wth-doc.
do  transaction
on error undo, return error
:
run adm/shattri.p (
    input "get":U
    ,input  parobj-type
    ,input  parobj-code
    ,input  {&attr-wthdoc_obj}
    ,input  '':U /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
IF not error-status:error  then do:
for each thbjattr_thbj-attr no-lock:
  if thbjattr_thbj-attr.prop-code = {&attr-wthdoc_obj_stfactpref} then v-stfactpref = thbjattr_thbj-attr.property-value-character.
  if thbjattr_thbj-attr.prop-code = {&attr-wthdoc_obj_numsfact} then v-numsfact = thbjattr_thbj-attr.property-value-integer.
end.
end.
 v-numsfact = v-numsfact + 1 no-error.
 if v-numsfact = ? then v-numsfact = 0.
par-nsf = v-stfactpref + string(v-numsfact).

/*Запишем новое значение счетчика в параметры объекта */

RUN thbjattr_write IN THIS-PROCEDURE (
     input parobj-type
    ,input parobj-code
    ,input {&attr-wthdoc_obj}
    ,input {&attr-wthdoc_obj_numsfact}
    ,input '':U
    ,input ?
    ,input 0
    ,input v-numsfact
    ,input no
) NO-ERROR.
IF ERROR-STATUS:error THEN do:
  MESSAGE ERROR-STATUS:get-message(1)  SKIP
  RETURN-VALUE
  VIEW-AS ALERT-BOX.
  UNDO, RETURN ERROR.
END.

end.