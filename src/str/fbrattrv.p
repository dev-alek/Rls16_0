block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fbrattrv.p $
$Archive: str/fbrattrv.p $

Чтение атрибута документа производства

Автор: Белоусов Илья Александрович
Дата создания: 11/17/05
Author: Ilia Belousov
Creation date: 11/17/05

Input:

Output:

*/

define input parameter p-doc-code       as character        no-undo.
define input parameter p-attr-code      as character        no-undo.
define output parameter p-attr-value    as character        no-undo.

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: fbrattrv.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/fbrattrv.p $":U .
define variable vss-description as character no-undo initial "Чтение атрибута документа производства":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/trdcalib.i }
{ str/fbrattr.i  }

    define variable v-attr-type    as character    no-undo.

do
on error undo, return error
:
    run fbrattr-value in this-procedure (
          input {&fbrattr-type-fbr-doc}
        , input p-doc-code
        , input p-attr-code
        , output p-attr-value
    ) no-error.
    if error-status :error
    then do:
        message
            vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка вычисления атрибута документа производства."
            skip(1)
            skip "Номер документа:" p-doc-code
            skip "Код атрибута:" p-attr-code
            skip(1)
            skip return-value
            skip trim( error-status :get-message( 1 ) )
                    trim( error-status :get-message( 2 ) )
                    trim( error-status :get-message( 3 ) )
        view-as alert-box error.
        undo, return error.
    end.
end.

