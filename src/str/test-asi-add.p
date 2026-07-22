block-level on error undo, throw.

/*------------------------------------------------------------------------
    File        : test-asi-add.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : SSlivenko
    Created     : Tue Mar 26 17:02:04 MSK 2024
    Notes       :
  ----------------------------------------------------------------------*/
using ibs.th.str.ptrl.forms.* from propath.

/* ***************************  Definitions  ************************** */

define  input parameter parparentproc as handle    no-undo.
define  input parameter pardoc-mode   as character no-undo.
define output parameter parrvs-rec    as recid     no-undo.

/* VSS Variable Definitions ---                                         */
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Добавление документа проверки корректности работы АСИ в резервуаре":U.

/* Common Definitions */
{ cmp/vssrevis.i }

define variable vForm as ibs.th.str.ptrl.forms.TestAsiAdd no-undo .
define variable v-type as character no-undo init "" .
define variable v-full as logical no-undo .

/* ***************************  Main Block  *************************** */

vForm = new ibs.th.str.ptrl.forms.TestAsiAdd() .
wait-for vForm:ShowDialog() .
v-type = vForm:pType .
v-full = vForm:pFull .
vForm:Dispose() .

if not v-type > ""
then return .

run str/test-asi-doc.w
 ( input        parparentproc
  ,input        pardoc-mode
  ,input        v-type
  ,input        v-full
  ,input-output parrvs-rec
 ) no-error.
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при создании документа проверки корректности работы АСИ в резервуаре." skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  return .
end.