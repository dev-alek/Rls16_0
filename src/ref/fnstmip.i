/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Îïğåäåëåíèå ïàğàìåòğîâ äëÿ ğàáîòû ñ âûïèñêîé

Àâòîğ: Áàõòàäçå Íàòàëüÿ Âèêòîğîâíà
Äàòà ñîçäàíèÿ: 08/29/05
Author: Bakhtadze Natalya
Creation date: 08/29/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&glob all-fin-statement-params-doc-status-define ~
define input parameter p-host-code           like ub.fin-statement.host-code            no-undo . ~
define input parameter p-sttm-code           like ub.fin-statement.sttm-code            no-undo . ~
define input parameter p-curr-code           like ub.fin-statement.curr-code            no-undo . ~
define input parameter p-doc-date            like ub.fin-statement.doc-date             no-undo . ~
define input parameter p-bank-date           like ub.fin-statement.doc-date             no-undo . ~
define input parameter p-fact-date           like ub.fin-statement.fact-date            no-undo . ~
define input parameter p-fins-doc-type       like ub.fin-statement.fins-doc-type        no-undo . ~
define input parameter p-fins-ext-doc-type   like ub.fin-statement.fins-ext-doc-type    no-undo . ~
define input parameter p-code-bank           like ub.fin-statement.code-bank            no-undo . ~
define input parameter p-bank-name           like ub.fin-statement.bank-name            no-undo . ~
define input parameter p-bank-city           like ub.fin-statement.bank-city            no-undo . ~
define input parameter p-bik                 like ub.fin-statement.bik                  no-undo . ~
define input parameter p-code-schet          like ub.fin-statement.code-schet           no-undo . ~
define input parameter p-r-schet             like ub.fin-statement.r-schet              no-undo . ~
define input parameter p-c-schet             like ub.fin-statement.c-schet              no-undo . ~
define input parameter p-cli-name            like ub.fin-statement.cli-name             no-undo . ~
define input parameter p-prn-doc-code        like ub.fin-statement.prn-doc-code         no-undo . ~
define input parameter p-PS                  like ub.fin-statement.PS                   no-undo . ~
define input parameter p-sum-doc             like ub.fin-statement.sum-doc              no-undo . ~
define input parameter p-start-sum-doc-th    like ub.fin-statement.start-sum-doc-th     no-undo . ~
define input parameter p-start-sum-doc       like ub.fin-statement.start-sum-doc        no-undo . ~
define input parameter p-in-sum-doc          like ub.fin-statement.in-sum-doc           no-undo . ~
define input parameter p-out-sum-doc         like ub.fin-statement.out-sum-doc          no-undo . ~
define input parameter p-end-sum-doc         like ub.fin-statement.end-sum-doc          no-undo . ~
define input parameter p-num-docs            like ub.fin-statement.num-docs             no-undo . ~
define input parameter p-start-date          like ub.fin-statement.start-date           no-undo . ~
define input parameter p-end-date            like ub.fin-statement.end-date             no-undo . ~


/*
sum-th ÁÓÄÌ Ñ×ÈÒÀÒÜ ÂÑÅÃÄÀ
num-doc-th
*/

&glob all-fin-statement-params-doc-status-transfer ~
,input ~{&prfx~}host-code            ~
,input ~{&prfx~}sttm-code            ~
,input ~{&prfx~}curr-code            ~
,input ~{&prfx~}doc-date             ~
,input ~{&prfx~}bank-date            ~
,input ~{&prfx~}fact-date            ~
,input ~{&prfx~}fins-doc-type        ~
,input ~{&prfx~}fins-ext-doc-type    ~
,input ~{&prfx~}code-bank            ~
,input ~{&prfx~}bank-name            ~
,input ~{&prfx~}bank-city            ~
,input ~{&prfx~}bik                  ~
,input ~{&prfx~}code-schet           ~
,input ~{&prfx~}r-schet              ~
,input ~{&prfx~}c-schet              ~
,input ~{&prfx~}cli-name             ~
,input ~{&prfx~}prn-doc-code         ~
,input ~{&prfx~}PS                   ~
,input ~{&prfx~}sum-doc              ~
,input ~{&prfx~}start-sum-doc-th     ~
,input ~{&prfx~}start-sum-doc        ~
,input ~{&prfx~}in-sum-doc           ~
,input ~{&prfx~}out-sum-doc          ~
,input ~{&prfx~}end-sum-doc          ~
,input ~{&prfx~}num-docs             ~
,input ~{&prfx~}start-date           ~
,input ~{&prfx~}end-date



/*
sum-th ÁÓÄÌ Ñ×ÈÒÀÒÜ ÂÑÅÃÄÀ
*/


/* $Workfile$ e n d */