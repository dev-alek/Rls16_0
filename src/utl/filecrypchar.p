block-level on error undo, throw.
/*

$Revision: 1eba0946c2d7, 3078, rls $
$Author: DRuban $
$Date: Пт авг 05 19:16:25 2022 +0300 $
$Workfile: filecrypchar.p $
$Archive: utl/filecrypchar.p $

шифрование файла

Автор: Белоусов Илья Александрович
Дата создания: 05/16/07
Author: Ilia Belousov
Creation date: 05/16/07

Input: p-in-file

Output: p-out-file

*/
define input  parameter i-Text  as longchar no-undo.
define input  parameter i-pasword as character no-undo.
define input  parameter i-encrypt as logical   no-undo.
define output parameter o-Text as longchar no-undo.

define variable vss-revision    as character no-undo init "$Revision: 1eba0946c2d7, 3078, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: Пт авг 05 19:16:25 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: filecrypchar.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/filecrypchar.p $":U .
define variable vss-description as character no-undo init "шифрование текста".
{ cmp/vssrevis.i }

{ gbl/pencrypt.i defproc_long  }
{ gbl/pdecrypt.i defproc_long  }

do
on error undo, return error
:
   if i-encrypt = ? then do:
      return error "Не опредлено дейcтвие".
   end.

   security-policy:symmetric-encryption-key = generate-pbe-key(i-pasword).
   if i-encrypt 
   then do:
      { gbl/pencrypt.i i-Text o-Text }
   end.
   else do:
      { gbl/pdecrypt.i i-Text o-Text }
   end.

end.