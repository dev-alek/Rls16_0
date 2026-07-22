block-level on error undo, throw.
/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$
*/

{ utl/tt301.i    }

define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-log-handle  as class ibs.th.utl.method-for-draw-utility no-undo .
define input  parameter TABLE for  temp-price-doc bind.
define input  parameter TABLE for  temp-price-list bind.
define output parameter p-ok-doc as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Импорт ДНЦ из временной таблицы".
{ cmp/vssrevis.i }

run utl/ora-i301.p (parparentproc,
                this-procedure,
                input table temp-price-doc ,
                input table temp-price-list ,
                output p-ok-doc).
                
procedure pcall-log-file:
   define input  parameter iText as character  no-undo .
   p-log-handle:put-log(iText).            
end procedure .               

procedure write-log-and-file:
   define input  parameter iText as character  no-undo .
   p-log-handle:put-log(iText).            
end procedure .               
