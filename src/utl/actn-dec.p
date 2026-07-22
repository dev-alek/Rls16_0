block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: actn-dec.p $
$Archive: utl/actn-dec.p $

дешифрование списка прав

Автор: Белоусов Илья Александрович
Дата создания: 05/16/07
Author: Ilia Belousov
Creation date: 05/16/07

Input:

Output:

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: actn-dec.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/actn-dec.p $":U .
define variable vss-description as character no-undo init "дешифрование списка прав".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }

DO
ON ERROR UNDO, RETURN ERROR
:

   run utl/filecryp.p ( INPUT "cmp/actn.enc":U
                      , INPUT "sysadm"
                      , INPUT NO
                      , INPUT "cmp/actn.txt":U
                      ) .

   MESSAGE "Дешифрование окончено"
   VIEW-AS ALERT-BOX.

END.