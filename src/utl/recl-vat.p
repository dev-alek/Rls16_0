block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: recl-vat.p $
$Archive: utl/recl-vat.p $

Расчет внешних расходных документов с определенной даты

Автор: Суслов Алексей Юрьевич
Дата создания: 04/12/06
Author: Alexey Suslov
Creation date: 04/12/06

*/

define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: recl-vat.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/recl-vat.p $":U .
define variable vss-description as character no-undo init "Расчет внешних расходных документов с определенной даты".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i  }
{ cmp/library.i }
{ gbl/cur-time.i }
{ gbl/waitfram.i }

DEFINE STREAM str-log.
define variable data-x as date initial "01/01/2000" no-undo.
update data-x label "Дата, начиная с которой, будем пересчитывать расходные документы"
       validate (data-x >= 01/01/2000, "дата должна быть больше 31.12.1999")
       with frame aaa VIEW-AS DIALOG-BOX SIDE-LABELS THREE-D SCROLLABLE KEEP-TAB-ORDER.
run waitfram-show in this-procedure ("Пересчет документов c " + string(data-x) +
               ". Дождитесь сообщения: <<Все расходные документы пересчитаны>>." ).
OUTPUT STREAM str-log TO "vat.log".
if session:set-wait-state ("COMPILER")  then .
for each clients,
    each trn-doc where trn-doc.obj-type = clients.obj-type and
                       trn-doc.obj-code = clients.obj-code and
                       trn-doc.doc-type =  {&expense}           and
                       trn-doc.internal =  no              and
                       trn-doc.doc-date >= data-x:
    run gbl/calc-trn.p (input parparentproc , input recid(trn-doc)).
    PUT STREAM str-log trn-doc.doc-code.
end.
PUT STREAM str-log "ВСЕ РАСХОДНЫЕ ДОКУМЕНТЫ ПЕРЕСЧИТАНЫ "  cur-time-string-sec().
OUTPUT STREAM str-log CLOSE.
IF SESSION:SET-WAIT-STATE("") THEN.
run waitfram-hide in this-procedure .