/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Общие определения для все файлов отрытия запроса в справочнике findocs.w

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/21/03
Author: Bakhtadze Natalya
Creation date: 11/21/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .

DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-call-handle as handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo.

define input parameter p-mode  as char   no-undo .
define input parameter p-list as character no-undo.
/*может быть {&all} 'cor-acc';U 'an-uchet-code':U 'cel-nazn-code':U  соответствующие    input parameter
должны быть заполнены правильными значениями*/
define input parameter p-host-code like ub.fin-doc.host-code no-undo .
define input parameter p-obj-type  like ub.fin-doc.obj-type no-undo .
define input parameter p-obj-code  like ub.fin-doc.obj-code no-undo .
define input parameter p-status_ like ub.fin-doc.status_ no-undo.
define input parameter p-fin-doc-type like ub.fin-doc.fin-doc-type no-undo.
define input parameter p-fin-ext-doc-type like ub.fin-doc.fin-ext-doc-type no-undo.
define input parameter p-start-date   like ub.fin-doc.doc-date no-undo .
define input parameter p-end-date   like ub.fin-doc.doc-date no-undo .
define input parameter p-trn-doc-code like ub.fin-doc.trn-doc-code no-undo.
define input parameter p-receiver-type like ub.fin-doc.receiver-type no-undo.
define input parameter p-receiver-code like ub.fin-doc.receiver-code no-undo.
define input parameter p-receiver-r-schet like ub.fin-doc.receiver-r-schet no-undo.
define input parameter p-payer-type like ub.fin-doc.payer-type no-undo.
define input parameter p-payer-code like ub.fin-doc.payer-code no-undo.
define input parameter p-payer-r-schet like ub.fin-doc.payer-r-schet no-undo.
define input parameter p-curr-code like ub.fin-doc.curr-code no-undo.
define input parameter p-receiver-code-schet like ub.fin-doc.receiver-code-schet no-undo.
define input parameter p-payer-code-schet like ub.fin-doc.payer-code-schet no-undo.
define input parameter p-contract-code like ub.fin-doc.contract-code no-undo.
define input parameter p-cor-acc like ub.fin-doc.cor-acc no-undo.
define input parameter p-cor-acc1 like ub.fin-doc.cor-acc1 no-undo.
define input parameter p-an-uchet-code like ub.fin-doc.an-uchet-code no-undo.
define input parameter p-cel-nazn-code like ub.fin-doc.cel-nazn-code no-undo.
define input-output param p-rid-list    as  character no-undo .


/*банки в выборке*/
define input parameter filter-point as character no-undo .
define input parameter filter-point0 as character no-undo .
define input parameter sort-column-name as character no-undo .
define output parameter p-filter-name   as character  no-undo .
define input-output parameter v-doc-rec as recid no-undo .

define variable  vss-revision    as character no-undo init "$Revision$":U .
define variable  vss-author      as character no-undo init "$Author$":U .
define variable  vss-date        as character no-undo init "$Date$":U .
define variable  vss-workfile    as character no-undo init "$Workfile$":U .
define variable  vss-archive     as character no-undo init "$Archive$":U .
define variable  vss-description as character no-undo init "Список банков  - открытие запроса".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/waitfram.i }

{ gbl/fltopend.i defproc }


DEFINE SHARED BUFFER X_fin-doc FOR ub.fin-doc.
DEFINE SHARED QUERY br-fin-doc FOR
      X_fin-doc SCROLLING.

define variable v-list-cond as character no-undo.
define variable  l-query-was-opened as logical no-undo .
define variable  sort-column-phrase as character no-undo .
define variable v-start-order as decimal no-undo .
define variable v-end-order as decimal no-undo .
PROCEDURE Set-filter-name :
define input parameter v-filter-name as character no-undo .
  assign
  p-filter-name = v-filter-name
  .
END PROCEDURE.


run proc-main in this-procedure .

procedure proc-main :

  do
  on error undo, return error
  :


case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.

&glob flt-open-open-query OPEN QUERY br-fin-doc FOR EACH X_fin-doc

&glob flt-open-dyn_open-query FOR EACH X_fin-doc

&glob flt-open-query-handle query br-fin-doc:handle

&glob flt-open-open-query-tail

&glob flt-open-query-was-opened  l-query-was-opened

&glob flt-open-sort-column-phrase sort-column-phrase

&glob flt-open-call-point filter-point

&glob flt-open-set-filter-name set-filter-name

&glob flt-open-indexed-reposition indexed-reposition

&glob flt-open-query p-open-query

&glob flt-open-table-name X_fin-doc

&glob flt-open-search-option no-lock

&glob flt-open-find-next p-find-next

&glob flt-open-find-recid v-doc-rec

&glob flt-open-find-condition p-find-condition

&glob flt-open-find-buffer-name X_fin-doc

&glob flt-open-waitfram yes

define variable l-open-query as logical   no-undo .


/* $Workfile$ e n d */