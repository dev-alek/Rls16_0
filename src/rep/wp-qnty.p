block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: wp-qnty.p $
$Archive: rep/wp-qnty.p $

Печать числа словами

Автор: Демин Алексей Сергеевич
Дата создания: 04/12/06
Author: Alexey Demin
Creation date: 04/12/06

Input:

Output:

*/

define input  parameter p-in-sum as decimal    no-undo.
define output parameter p-out-sum  as character  no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wp-qnty.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/wp-qnty.p $":U .
define variable vss-description as character no-undo init "Печать числа словами".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

do
on error undo, return error
:
    assign
        p-out-sum = "":U
    .
    run gbl/num-rus.p (
          input absolute( p-in-sum )
        , output p-out-sum
    ).
    assign
        p-out-sum = trim( caps( substring( p-out-sum, 1, 1 ) ) ) + substring( p-out-sum, 2 )
    .
    assign
        p-out-sum = ( if p-in-sum < 0 then "- ":U else "":U )
                    + trim( p-out-sum )
                    + ( if substring( string( absolute( p-in-sum ), "999999999999999.999":U ), 17, 3 )  <> "000":U
                        then ( " целых "
                                + substring( string( absolute( p-in-sum ), "999999999999999.999":U ), 17, 3 )
                                + " тысячных" )
                        else "":U  )
    .
end.