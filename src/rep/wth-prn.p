block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: wth-prn.p $
$Archive: rep/wth-prn.p $

Печать складского документа

Автор: Демин Алексей Сергеевич
Дата создания: 03/20/06
Author: Alexey Demin
Creation date: 03/20/06

Input:

Output:

*/
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter v-wth-doc-doc-code   as character        no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wth-prn.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/wth-prn.p $":U .
define variable vss-description as character no-undo init "Печать складского документа.".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

    define temp-table temp_wth-doc-code no-undo
        field doc-code as character

        index pi is primary unique
            doc-code
    .
    define variable lok as logical no-undo .

    define buffer buf_wth-doc               for wth-doc.
    define buffer buf_temp_wth-doc-code     for temp_wth-doc-code.
do
for buf_wth-doc
  , buf_temp_wth-doc-code
on error undo, return error
:
    find first buf_wth-doc no-lock
         where buf_wth-doc.doc-code = v-wth-doc-doc-code
    .
    create buf_temp_wth-doc-code.
    assign
        buf_temp_wth-doc-code.doc-code = buf_wth-doc.doc-code
    .
    run rep/wthprn.w (
          input p-mainmenu-handle
        , input table buf_temp_wth-doc-code
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка печати документа материальных ценностей."
            skip(1)
            skip "Номер документа:" v-wth-doc-doc-code
            skip(1)
            skip return-value
            skip trim( error-status :get-message( 1 ) )
                 trim( error-status :get-message( 2 ) )
                 trim( error-status :get-message( 3 ) )
        view-as alert-box error.
        undo, return error.
    end.
end.