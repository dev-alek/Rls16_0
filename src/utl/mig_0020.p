block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: mig_0020.p $
$Archive: utl/mig_0020.p $

Модификация тфблиц  раздела Бар-коды

Автор: Чернова Светлана Александровна
Дата создания: 12/08/08
Author: Svetlana Chernova
Creation date: 12/08/08

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mig_0020.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/mig_0020.p $":U .
define variable vss-description as character no-undo init "Модификация тфблиц раздела Бар-коды".
{ cmp/vssrevis.i }
{ utl/mig_0001.i }

run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Бар-коды") ).

on write of ub.bar-code   override do: end .
on write of ub.prod-bc    override do: end .
on write of ub.prod-bc-db override do: end .
on delete of ub.prod-bc-db override do: end .
on write of ub.prod-bc-db-attr override do: end .
on delete of ub.prod-bc-db-attr override do: end .

  do
  on error undo, return error return-value
  :

define variable v-ind1 as integer   no-undo .

  run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("-> bar-code")).


    for each ub.bar-code exclusive-lock
    on error undo, return error
    :
       ub.bar-code.cr-db-num = 0 .
    end.


  run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("-> prod-bc")).

    for each ub.prod-bc exclusive-lock where
             ub.prod-bc.cr-db-num > 0
    on error undo, return error
    :
       ub.prod-bc.cr-db-num = 0 .
    end.

  run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("-> prod-bc-db")).


    for each ub.prod-bc-db exclusive-lock where
             ub.prod-bc-db.db-num <> p-db-num
    on error undo, return error
    :
       for each ub.prod-bc-db-attr exclusive-lock
       where
           ub.prod-bc-db-attr.b-code  =  ub.prod-bc-db.b-code and
           ub.prod-bc-db-attr.b-str   =  ub.prod-bc-db.b-str  and
           ub.prod-bc-db-attr.db-num  =  ub.prod-bc-db.db-num
       :
          delete ub.prod-bc-db-attr .
       end.
       delete ub.prod-bc-db .
    end.


    for each ub.prod-bc-db exclusive-lock
    on error undo, return error
    :

       ub.prod-bc-db.db-num = 0 .
    end.

       for each ub.prod-bc-db-attr exclusive-lock
       :
          ub.prod-bc-db-attr.db-num = 0 .
       end.

end.