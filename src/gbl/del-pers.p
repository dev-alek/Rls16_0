block-level on error undo, throw.
/*

$Revision: 579765cb4320, 2677, rls $
$Author: DRuban $
$Date: Вт ноя 17 10:53:21 2020 +0300 $
$Workfile: del-pers.p $
$Archive: gbl/del-pers.p $

Удаление всех persistent процедур

Автор: Перваков Михаил Сергеевич
Дата создания: 09/20/02
Author: Mikhail Pervakov
Creation date: 09/20/02

*/

define variable vss-revision    as character no-undo init "$Revision: 579765cb4320, 2677, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: Вт ноя 17 10:53:21 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: del-pers.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/del-pers.p $":U .
define variable vss-description as character no-undo init "Удаление всех persistent процедур".
{ cmp/vssrevis.i }
define stream LogStream.
output stream LogStream to "memdump.log".
output stream LogStream close.
/* run utl/ttp.p ( input "utl/del-pers.p").
   21/I-2019 - попробуем обойтись без подсчёта удаляемых persistent-procedure
   На очереди - избавиться от utl/ttq.p и от utl/tto.p
*/

   DEFINE VARIABLE hProc AS HANDLE     NO-UNDO.
   DEFINE VARIABLE iCounter AS INTEGER    NO-UNDO.
   define variable v-procedure-handle as handle    no-undo .

  hProc = session:first-procedure .
  iCounter = 0 .
  if valid-handle(hProc) then do :
    OUTPUT stream LogStream TO "memdump.log" APPEND.
    do while valid-handle(hProc) 
    on error undo, return error :
      iCounter = iCounter + 1.
      v-procedure-handle = hProc .
      hProc = hProc:next-sibling .
      
      put stream LogStream unformatted
            "Procedure No.:~t" iCounter "~t"
            "Procedure:~t" v-procedure-handle:file-name
      skip.
      
      apply 'delete':u to v-procedure-handle .
      delete procedure v-procedure-handle .
    end.
    output stream LogStream close.
  end .
run utl/ttq.p ( input "utl/del-pers.p").
run utl/tto.p ( input "utl/del-pers.p").