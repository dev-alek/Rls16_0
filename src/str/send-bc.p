block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: send-bc.p $
$Archive: str/send-bc.p $

Отсылка на кассы БК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
/*
p-parameter включает
def input parameter inp-recid as recid no-undo .
def input parameter action as char no-undo init "U".
*/

&SCOPED-DEFINE called send-bc

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: send-bc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/send-bc.p $":U .
define variable vss-description as character no-undo init "Отсылка на кассы БК":U.
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/getcntxt.i def }

define variable  inp-recid as recid no-undo .
define variable  action as char no-undo init "U".

define variable  i-obj-code like ub.clients.obj-code no-undo init 0.
def buffer b-bc for ub.bar-code.

assign
inp-recid = integer(entry(1, p-parameter, {&delim-par}))
action = entry(2, p-parameter, {&delim-par})
no-error
.
if error-status:error then return error.

{ gbl/getcntxt.i get }

{ str/sendgood.i }