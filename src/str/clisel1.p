block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: clisel1.p $
$Archive: str/clisel1.p $

Выбор клиента

Автор: Шальнев Иван Сергеевич
Дата создания: 26/08/11
Author: Shalnev Ivan
Creation date: 26/08/11

*/
define input parameter parparentproc as widget-handle no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-code as character no-undo.
define input-output parameter p-value as character no-undo.

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: clisel1.p $":U .
def var vss-archive     as character no-undo init "$Archive: str/clisel1.p $":U .
def var vss-description as character no-undo init "Выбор клиента".
{ cmp/vssrevis.i }

/*  c-types = {&cmp}.  */

def var ref-list as character no-undo .
def var ii as integer no-undo.
def var v-value as character no-undo initial "".

run ref/cli-all.w
  ( parparentproc
    , input  "b-sel,b-mark"
    , ?
    , ?
    , ?
    , ?
    , ?
    , p-code + "=" + p-value
  ,output ref-list
  ).
if ref-list <> "" then do:
   p-value = "".
   do ii = 1 to num-entries(ref-list):
     find first ub.clients no-lock
          where recid(ub.clients) = integer(entry(ii,ref-list)) no-error.
     if available ub.clients then do :
       if lookup((ub.clients.obj-type + string(ub.clients.obj-code)),p-value) = 0 then do :
         if p-value = "" then do :
           p-value = ub.clients.obj-type + string(ub.clients.obj-code) .
         end.
         else do :
           p-value = p-value + "," + ub.clients.obj-type + string(ub.clients.obj-code) .
         end.
       end.
     end.
   end.
   p-value = right-trim (p-value,",").
   return .
end.

return error .