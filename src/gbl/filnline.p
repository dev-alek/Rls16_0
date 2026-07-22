block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: filnline.p $
$Archive: gbl/filnline.p $

Ïğîâåğèòü, ÷òî ôàéë çàêàí÷èâàåòñÿ ñèìâîëîì íîâàÿ ñòğîêà

Àâòîğ: Ïåğâàêîâ Ìèõàèë Ñåğãååâè÷
Äàòà ñîçäàíèÿ: 06/06/03
Author: Mikhail Pervakov
Creation date: 06/06/03

*/

define input  parameter p-file-name    as character no-undo .
define output parameter p-end-new-line as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: filnline.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/filnline.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }

define stream sinp .

do
on error undo, return error return-value
:
  assign
    p-end-new-line = false
  .

  define variable v-full-path-name as character no-undo .
  assign
    v-full-path-name = search(p-file-name)
  .

  if v-full-path-name = ?
  or v-full-path-name = ""
  then do:
    return "Ôàéë íå íàéäåí" . /* --->>>--- */
  end.

  input stream sinp from value(v-full-path-name) no-echo no-map .
  seek stream sinp to end.

  define variable v-file-position as integer   no-undo .
  assign
    v-file-position = seek(sinp)
  .

  if v-file-position = 0
  then do:
    return "Ğàçìåğ ôàéëà 0" . /* --->>>--- */
  end.


  seek stream sinp to v-file-position - 1 .
  readkey stream sinp pause 0.

  define variable v-last-key as integer   no-undo .

  assign
    v-last-key = lastkey
  .

  if v-last-key = 13
  then do:
    assign
      p-end-new-line = true
    .
    return . /* --->>>--- */
  end.
  else do:
    return "Ïîñëåäíèé ñèìâîë îòëè÷åí îò êîíöà ñòğîêè" . /* --->>>--- */
  end.
end.