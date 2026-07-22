block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 9 марта 2020 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 9 марта 2020 г.

*/
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
define variable mError as logical no-undo.
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ utl/proc-async.i proc_def}
{ adm/auto-def.i}
{ cmp/trg-def.i }
{ str/auto2dia.i &highest-window-handle = this-procedure}
{ utl/cashparamHash.i }
if g#db-num ne 0
then
   run saveCashParHash(g#db-num).
define variable mSocetLog as character no-undo.
mSocetLog = GetParamAsunc(1).
for each shop no-lock,
each clients where clients.db-num   eq g#db-num
               and clients.obj-type eq {&shop}
               and clients.obj-code eq shop.obj-code
               and clients.stts     eq 0
no-lock:
   run str/send-all.p(?,
                      this-procedure,
                      this-procedure,
                      substitute ("&2&1&3&1&4&1&5&1&6&1cash-send=all,&7",
                                   {&delim-par},
                                   clients.obj-type,
                                   clients.obj-code,
                                   'U':U,
                                   "cashp1,cashp2",
                                   'Получение параметров кассы':U,
                                   "SocetLog=" + mSocetLog
                                   )
                      )
   .
   run bge\send1cerp.p (?,
                      this-procedure,
                      this-procedure,
                      "CashParamControl",
                      ?,
                      ?,
                      ?).
   run bge\send1cerp.p (?,
                      this-procedure,
                      this-procedure,
                      "CashParamHist",
                      ?,
                      ?,
                      ?).
end.
{ utl/proc-async.i proc_end}
