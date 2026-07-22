block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fbrplnop.p $
$Archive: str/fbrplnop.p $

Открытие документа план-меню

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

*/

define input parameter p-doc-code   as character    no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fbrplnop.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/fbrplnop.p $":U .
define variable vss-description as character no-undo init "Открытие документа план-меню".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

    define temp-table temp_fbr-objects no-undo
        field obj-type  as character
        field obj-code  as integer

        index pi is primary unique obj-type obj-code
    .
    define buffer buf_fbr-pln               for fbr-pln.
    define buffer buf_fbr-pln-line          for fbr-pln-line.
    define buffer buf_fbr-doc               for fbr-doc.
    define buffer buf_trn-doc               for trn-doc.
    define buffer buf_doc-line              for doc-line.
    define buffer buf_del_fbr-line          for fbr-line.
    define buffer buf_del_fbr-doc           for fbr-doc.
    define buffer buf_del_fbr-recipe        for fbr-recipe.
    define buffer buf_del_fbr-recipe-gds    for fbr-recipe-gds.
    define buffer buf_fbr-recipe            for fbr-recipe.
    define buffer buf_fbr-recipe-gds        for fbr-recipe-gds.
do
for buf_fbr-pln
  , buf_fbr-pln-line
  , buf_fbr-doc
  , buf_trn-doc
  , buf_doc-line
  , buf_del_fbr-line
  , buf_del_fbr-doc
  , buf_del_fbr-recipe
  , buf_del_fbr-recipe-gds
  , buf_fbr-recipe
  , buf_fbr-recipe-gds
on error undo, return error
:
    { gbl/working.i }

    for each temp_fbr-objects
    on error undo, return error
    :
        delete temp_fbr-objects.
    end.        /* for each temp_fbr-objects */
    for each buf_fbr-pln-line no-lock
       where buf_fbr-pln-line.doc-code     = p-doc-code
    on error undo, return error
    :
        find first temp_fbr-objects
             where temp_fbr-objects.obj-type = buf_fbr-pln-line.fbr-obj-type
               and temp_fbr-objects.obj-code = buf_fbr-pln-line.fbr-obj-code
        no-error.
        if not available temp_fbr-objects
        then do:
            create temp_fbr-objects.
            assign
                temp_fbr-objects.obj-type = buf_fbr-pln-line.fbr-obj-type
                temp_fbr-objects.obj-code = buf_fbr-pln-line.fbr-obj-code
            .
        end.
    end.        /* for each buf_fbr-pln-line */
    do transaction
    on error undo, return error
    :
        find first buf_fbr-pln exclusive-lock
             where buf_fbr-pln.doc-code = p-doc-code
        .
        if buf_fbr-pln.status_ <> {&permitted}
        then do:
            message
                "Можно открыть документ только в статусе разр."
            view-as alert-box error.
            undo, return error .
        end.
        for each temp_fbr-objects
        on error undo, return error
        :
            for each buf_fbr-doc no-lock
               where buf_fbr-doc.out-code = p-doc-code
            on error undo, return error
            :
                for each buf_trn-doc exclusive-lock
                    where buf_trn-doc.out-code = buf_fbr-doc.doc-code
                :
                    if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem}
                    and buf_trn-doc.status_     = {&inquiry}
                    then do:        /* Удалить ненужный запрос */
                        for each buf_doc-line exclusive-lock
                           where buf_doc-line.doc-code = buf_trn-doc.doc-code
                        :
                            delete buf_doc-line.
                        end.
                        delete buf_trn-doc.
                    end.
                end.
                for each buf_fbr-recipe-gds no-lock
                   where buf_fbr-recipe-gds.doc-code      = buf_fbr-doc.doc-code
                :
                    find first buf_del_fbr-recipe-gds exclusive-lock
                         where recid( buf_del_fbr-recipe-gds ) = recid( buf_fbr-recipe-gds )
                    .
                    delete buf_del_fbr-recipe-gds.
                end.
                for each buf_fbr-recipe no-lock
                   where buf_fbr-recipe.doc-code      = buf_fbr-doc.doc-code
                :
                    find first buf_del_fbr-recipe exclusive-lock
                         where recid( buf_del_fbr-recipe ) = recid( buf_fbr-recipe )
                    .
                    delete buf_del_fbr-recipe.
                end.
                for each fbr-line no-lock
                   where fbr-line.doc-code = buf_fbr-doc.doc-code
                :
                    find first buf_del_fbr-line exclusive-lock
                         where recid( buf_del_fbr-line ) = recid( fbr-line )
                    .
                    delete buf_del_fbr-line.
                end.
                find first buf_del_fbr-doc exclusive-lock
                     where recid( buf_del_fbr-doc ) = recid( buf_fbr-doc )
                .
                delete buf_del_fbr-doc.
            end.        /* for each buf_fbr-doc */
        end.        /* for each temp_fbr-objects */
        assign
            buf_fbr-pln.status_ = {&g___new}
        .
    end.        /* do transaction */
    { gbl/stopwork.i }
end.