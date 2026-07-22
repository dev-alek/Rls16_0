block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 14 нояб. 2020 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 14 нояб. 2020 г.

*/
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }


define input parameter iGroupObj-Code   as character   no-undo.
define input parameter iForce-assign as logical no-undo.

find first _file where _file._file-name = iGroupObj-Code no-lock no-error.
if not available _file then return.
find first xGroupObj where xGroupObj.GroupObj-Code = iGroupObj-Code no-lock no-error.

for each _field of _file no-lock:
   find first xattr where xattr.GroupObj-Code = iGroupObj-Code 
                      and xattr.xattr-code = _field._field-name 
      exclusive-lock no-wait no-error.
   if not available xattr then
      create xattr.
   if new xattr or iForce-assign then
   do:
      assign
         Xattr.GroupObj-Code     = xGroupObj.GroupObj-Code
         Xattr.Xattr-Code     = _field._field-name
         Xattr.Progress-Field = yes
         Xattr.Name           = _field._label
         Xattr.Description    = _field._help
         Xattr.Data-Type      = _field._data-type
         Xattr.Data-Format    = _field._format
         Xattr.Initial        = _field._initial
         Xattr.Mandatory      = _field._mandatory
         Xattr.sign-inherit   = "б"
         Xattr.order          = _field._order
         Xattr.xattr-label    = _field._label
         Xattr.xattr-clabel   = _field._col-label
         Xattr.Accuracy       = _field._decimals
      .
   end.

end.

for each xattr where xattr.GroupObj-Code = iGroupObj-Code 
                 and xattr.progress-field 
                 and xattr.sign-inherit = "б" exclusive-lock:
   find first _field of _file where xattr.xattr-code = _field._field-name no-lock no-error.
   if not available _field then
   do:
      
      delete xattr.
   end.
end.
/* $LINTFILE='xattr-f.p' */
/* $LINTMODE='1,5,6,3' */
/* $LINTENV ='dvp' */
/* $LINTVSS ='$/ws1-dvp/bq/' */
/* $LINTUSER='soav' */
/* $LINTDATE='08/02/2017 13:17:24.771+03:00' */
/*prosignQt+l143U8FUksdnCsC3S1w*/