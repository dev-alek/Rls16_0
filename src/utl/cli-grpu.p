block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cli-grpu.p $
$Archive: utl/cli-grpu.p $

Процедура обеспечения уникальности имен одноуровневых узлов классификатора клиентов

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cli-grpu.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/cli-grpu.p $":U .
define variable vss-description as character no-undo init "Процедура обеспечения уникальности имен одноуровневых узлов классификатора клиентов".
{ cmp/vssrevis.i }


{ utl/grp-nmun.i cli-grp }