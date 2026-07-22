block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$
 


Автор: Рубан Дмитрий Андреевич
Дата создания: 17/02/19
Author: Ruban Dmitriy
Creation date: 17/02/19 

*/


&scoped-define main-tbl code
trigger procedure for delete of ub.{&main-tbl}.

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo init "Тригер удаления {&main-tbl}". 

{ trg/trghistnws.i 
  &hist = yes 
  &seqnamehist = "s-c-code"
  &del  = yes
  
}


if    (    g#db-num eq 0 
       and {&main-tbl}.nwsgbd )
   or (    g#db-num ne 0 
       and {&main-tbl}.nwsubd )
then do:
   { trg/trghistnws.i 
     &nws  = yes
     &del  = yes
   }
end.

define buffer buf_code for code.
define var vparent as char no-undo.
vparent = (if code.parent = "" then "" else ( code.parent  +  {&delim-par}) )  + code.code.
for each buf_code where buf_code.parent begins vparent
exclusive-lock:
   delete buf_code.
end.

