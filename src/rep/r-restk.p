block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-restk.p $
$Archive: rep/r-restk.p $

Калькуляционные карточки по ПЛАНУ-МЕНЮ

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 03/31/04 12:18

*/
 def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
 def var vss-author      as character no-undo init "$Author: expertek $":U .
 def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
 def var vss-workfile    as character no-undo init "$Workfile: r-restk.p $":U .
 def var vss-archive     as character no-undo init "$Archive: rep/r-restk.p $":U .
 def var vss-description as character no-undo init "Калькуляционные карточки по ПЛАНУ-МЕНЮ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i   }
{ cmp/r-page1.i  new }
{ cmp/breakstr.i }
{ rep/r-cliprp.i def }
{ trg/partslib.i   }
{ str/fbrlib.i     }

&scop col-col-page 2

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-recid              as recid     no-undo.


define buffer buf_fbr-pln      for fbr-pln.
define buffer buf_fbr-doc      for fbr-doc.
define buffer buf_recipe       for recipe.

find first buf_fbr-pln no-lock
     where recid(buf_fbr-pln) = p-recid
     no-error.

if not available buf_fbr-pln
then do:
    message
      "Напечатать невозможно"
    view-as alert-box.
    return.
end.

for each  buf_fbr-doc no-lock where
          buf_fbr-doc.out-code = buf_fbr-pln.doc-code
    on error undo, return error :
    run fbrlib-put-in-order-recipe (input buf_fbr-doc.doc-code ) .

    for each temp_recipe-order
        on error undo, return error :
        find first buf_recipe no-lock where buf_recipe.recipe-code = temp_recipe-order.recipe-code .

        if buf_recipe.recipe-type = {&manufacturing} then
           run rep/r-tk.p (input p-mainmenu-handle, input recid (buf_recipe) , string(buf_fbr-pln.doc-date , "99/99/9999"  ) ) .

    end. /* for each */
end. /* for each */