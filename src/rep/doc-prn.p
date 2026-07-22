block-level on error undo, throw.
/*

$Revision: 51d0b788d6e0, 3546, rls $
$Author: DRuban $
$Date: 2023/11/27 08:31:17 $
$Workfile: doc-prn.p $
$Archive: rep/doc-prn.p $

Печать складского документа

Автор: Гюнтнер Виктор Арнольдович
Дата создания: 03/20/06
Author: Victor Guntner
Creation date: 03/20/06

Input:

Output:

*/
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-alldocs-handle     as handle           no-undo.
define input parameter v-trn-doc-recid      as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: 51d0b788d6e0, 3546, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2023/11/27 08:31:17 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: doc-prn.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/doc-prn.p $":U .
define variable vss-description as character no-undo init "Печать складского документа.".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }


    define temp-table temp_trn-doc-code no-undo
        field doc-code as character
        index pi is primary unique doc-code
    .
    define variable lok as logical no-undo .

define buffer buf_trn-doc               for trn-doc.
define buffer buf_temp_trn-doc-code     for temp_trn-doc-code.

define variable i as integer   no-undo .
define variable v-kol as integer   no-undo .

do
on error undo, return error
:
assign
  i = 0
  v-kol = num-entries (v-trn-doc-recid) .
.
    repeat i = 1 to v-kol :
      find first  buf_trn-doc no-lock
          where recid( buf_trn-doc ) = int64(entry(i,v-trn-doc-recid)) no-error
      .
      if available  buf_trn-doc then do:
      create buf_temp_trn-doc-code .
      assign
          buf_temp_trn-doc-code.doc-code = buf_trn-doc.doc-code
      .
      end.
    end.

    run rep/d-docm.w (
          input p-mainmenu-handle
        , input p-alldocs-handle
        , input table buf_temp_trn-doc-code
    ) no-error.
    if error-status :error
    then do:
        message
            skip "Ошибка печати документа."
            skip (1)
            skip return-value
            skip trim( error-status :get-message( 1 ) )
        view-as alert-box error.
        undo, return error.
    end.
end.