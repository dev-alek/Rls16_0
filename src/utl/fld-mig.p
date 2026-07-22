block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fld-mig.p $
$Archive: utl/fld-mig.p $

Все таблицы с Host-code obj-type obj-code

Автор: Чернова Светлана Александровна
Дата создания: 12/12/08
Author: Svetlana Chernova
Creation date: 12/12/08

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fld-mig.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/fld-mig.p $":U .
define variable vss-description as character no-undo init "Все таблицы с Host-code obj-type obj-code".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
DEFINE STREAM outstrim.
OUTPUT STREAM outstrim TO VALUE("c:\ttable.txt") .
define buffer buf-_Field for ub._Field  .

for each _File no-lock :
   find first _Field no-lock of _File
        where
        _Field._Field-Name = 'obj-type'
        no-error.

    if available _Field then do:
       put stream outstrim "Table "  _File._File-Name skip .

    for each _index of _file no-lock  :
       for each  _index-field of _index  :
           find first buf-_field of _index-field no-error .
           if buf-_Field._Field-Name = 'obj-type' then do:
              put stream outstrim "Index " _index._index-name skip .
              leave.
           end.
           else do:
              leave.
           end.
       end.
    end.

   end.
   end.

OUTPUT STREAM outstrim CLOSE.