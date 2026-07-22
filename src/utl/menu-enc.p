block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: menu-enc.p $
$Archive: utl/menu-enc.p $



Автор: Белоусов Илья Александрович
Дата создания: 05/15/07
Author: Ilia Belousov
Creation date: 05/15/07

Input:

Output:

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: menu-enc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/menu-enc.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }

DEFINE STREAM st-in.
DEFINE STREAM st-out.


DEFINE VARIABLE v-in-string  AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-out-string AS CHARACTER NO-UNDO .

define variable v-count      as integer      no-undo.
DEFINE VARIABLE v-file-name   AS CHARACTER    NO-UNDO.

DO
ON ERROR UNDO, RETURN ERROR
:

   run utl/filecryp.p ( INPUT "cmp/menu.txt":U
                      , INPUT "sysadm"
                      , INPUT YES
                      , INPUT "cmp/menu.enc":U
                      ) .

   MESSAGE "Шифрование окончено"
   VIEW-AS ALERT-BOX.

END.