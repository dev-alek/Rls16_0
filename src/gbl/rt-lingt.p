block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rt-lingt.p $
$Archive: gbl/rt-lingt.p $

Ğàäèîòåğìèíàë. Âåğíóòü äàííûå ïî ñòğîêå äîêóìåíòà

Àâòîğ: Õíûêèí Ïàâåë Àíäğååâè÷
Äàòà ñîçäàíèÿ: 06/17/09
Author: Pavel Khnykin
Creation date: 06/17/09

*/

define input  parameter p-unique-doc-code as character no-undo .
define input  parameter p-b-code          as integer   no-undo .
define output parameter p-qnty            as decimal   no-undo .
define output parameter p-last-date       as date      no-undo .
define output parameter p-price-docf      as decimal   no-undo .
define output parameter p-status          as character no-undo .
define output parameter p-error-message   as character no-undo .

/*define input  parameter p-set-qnty        as decimal   no-undo .*/
/*define input  parameter p-last-date       as date      no-undo .*/
/*define input  parameter p-price-docf      as decimal   no-undo .*/


/*define input  parameter p-action          as character no-undo .*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rt-lingt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/rt-lingt.p $":U .
define variable vss-description as character no-undo init "Ğàäèîòåğìèíàë. Çàğåãèñòğèğîâàòü êîëè÷åñòâî ïî ñòğîêå äîêóìåíòà".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define buffer buf_batchprocess for ub.batchprocess .

do
on error undo, return error return-value
:
  assign
    p-qnty          = 0
    p-last-date     = ?
    p-price-docf    = 0
    p-status        = '0'
    p-error-message = ''
  .

  find first buf_batchprocess exclusive-lock
    where buf_batchprocess.bp_type     = {&btpr-type-rt-line}
      and buf_batchprocess.bp_status   = {&btpr-normal}
      and buf_batchprocess.charkey_one = p-unique-doc-code
      and buf_batchprocess.key#_one    = p-b-code
  no-error .
  if not available buf_batchprocess
  then do:
   return . /* --->>>--- */
  end.

  assign
    p-qnty = decimal(buf_batchprocess.bp_execsystime)
  no-error .
  if error-status :error
  then do:
    assign
      p-status        = "1"
      p-error-message = substitute("gbl/rt-lingt.p: Îøèáêà ïğåîáğàçîâàíèÿ êîë-âà â ñòğîêå äîêóìåíòà &1 | &2. &3"
                                  , p-unique-doc-code
                                  , p-b-code
                                  , error-status :get-message(1)
                                  )
    .
    return . /* --->>>--- */
  end.

  assign
    p-last-date = date(buf_batchprocess.charkey_two)
  no-error .
  if error-status :error = yes
  then do:
    assign
      p-status        = "1"
      p-error-message = substitute("gbl/rt-lingt.p: Îøèáêà ïğåîáğàçîâàíèÿ ñğîêà ãîäíîñòè â ñòğîêå äîêóìåíòà &1 | &2. &3"
                                  , p-unique-doc-code
                                  , p-b-code
                                  , error-status :get-message(1)
                                  )
    .
    return . /* --->>>--- */
  end.

  assign
    p-price-docf = decimal(buf_batchprocess.charkey_three)
  no-error .
  if error-status :error = yes
  then do:
    assign
      p-status        = "1"
      p-error-message = substitute("gbl/rt-lingt.p: Îøèáêà ïğåîáğàçîâàíèÿ öåíû â ñòğîêå äîêóìåíòà &1 | &2. &3"
                                  , p-unique-doc-code
                                  , p-b-code
                                  , error-status :get-message(1)
                                  )
    .
    return . /* --->>>--- */
  end.
end.