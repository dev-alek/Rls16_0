/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рукавишников Вадим
Дата создания: 27.04.2021
Author: Rukavishnikov Vadim
Creation date: 27.04.2021

*/

using System.Runtime.InteropServices.ComTypes.IMoniker from assembly.
block-level on error undo, throw.
{cmp/str-glbl.i }
{ ibs\th\ref\code\codefrmpar.i }

define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
   define variable v-ok as logical no-undo.
   define buffer b-code for code.
&Scoped-define CODE_PARENT "okei-kkt"

define variable mOkeiKktEdit as class   ibs.th.ref.code.okeikktedit_ no-undo.

mOkeiKktEdit = new ibs.th.ref.code.okeikktedit_(iMode, iCodeTrg).
mOkeiKktEdit:bindcode:Handle = IBuffer .
mOkeiKktEdit:parparentproc = iParparentproc.

wait-for  mOkeiKktEdit:ShowDialog() .
OSave = mOkeiKktEdit:DialogResult = System.Windows.Forms.DialogResult:OK.
if osave
then
   IBuffer::nwsgbd = yes.

finally:
  delete object mOkeiKktEdit.
end finally. 