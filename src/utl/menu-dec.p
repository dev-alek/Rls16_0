block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: menu-dec.p $
$Archive: utl/menu-dec.p $

декодировка меню

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
define variable vss-workfile    as character no-undo init "$Workfile: menu-dec.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/menu-dec.p $":U .
define variable vss-description as character no-undo init "декодировка меню".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }

DEFINE STREAM st-in.
DEFINE STREAM st-out.


DEFINE VARIABLE v-in-string  AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-out-string AS CHARACTER NO-UNDO .

DEFINE VARIABLE v-count      AS INTEGER   NO-UNDO .
DEFINE VARIABLE v-file-name  AS CHARACTER NO-UNDO .


DO
ON ERROR UNDO, RETURN ERROR
:
   run utl/filecryp.p ( INPUT "cmp/menu.enc":U
                      , INPUT "sysadm"
                      , INPUT NO
                      , INPUT "cmp/menu.txt":U
                      ) .

   MESSAGE "Дешифрование окончено"
   VIEW-AS ALERT-BOX.

END.