/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Описания параметров для файлов работающих с таблицей fin-doc

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/17/03
Author: Bakhtadze Natalya
Creation date: 11/17/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&glob all-fin-doc-params-doc-status-define ~
define input parameter p-host-code           like ub.fin-doc.host-code            no-undo . ~
define input parameter p-fin-doc-code        like ub.fin-doc.fin-doc-code         no-undo . ~
define input parameter p-an-uchet-code       like ub.fin-doc.an-uchet-code        no-undo . ~
define input parameter p-an-uchet-value      like ub.fin-doc.an-uchet-value       no-undo . ~
define input parameter p-base-rate           like ub.fin-doc.base-rate            no-undo . ~
define input parameter p-base-scale          like ub.fin-doc.base-scale           no-undo . ~
define input parameter p-cel-nazn-code       like ub.fin-doc.cel-nazn-code        no-undo . ~
define input parameter p-cel-nazn-value      like ub.fin-doc.cel-nazn-value       no-undo . ~
define input parameter p-contract-code       like ub.fin-doc.contract-code        no-undo . ~
define input parameter p-contract-curr       like ub.fin-doc.contract-curr        no-undo . ~
define input parameter p-contract-rate       like ub.fin-doc.contract-rate        no-undo . ~
define input parameter p-contract-scale      like ub.fin-doc.contract-scale       no-undo . ~
define input parameter p-cor-acc             like ub.fin-doc.cor-acc              no-undo . ~
define input parameter p-cor-acc-value       like ub.fin-doc.cor-acc-value        no-undo . ~
define input parameter p-cor-acc1            like ub.fin-doc.cor-acc1             no-undo . ~
define input parameter p-cor-acc1-value      like ub.fin-doc.cor-acc1-value       no-undo . ~
define input parameter p-curr-code           like ub.fin-doc.curr-code            no-undo . ~
define input parameter p-doc-date            like ub.fin-doc.doc-date             no-undo . ~
define input parameter p-shift-date          like ub.fin-doc.shift-dat            no-undo . ~
define input parameter p-shift-num           like ub.fin-doc.shift-num            no-undo . ~
define input parameter p-shift-name          like ub.fin-doc.shift-name           no-undo . ~
define input parameter p-enclosure           like ub.fin-doc.enclosure            no-undo . ~
define input parameter p-exch-rate           like ub.fin-doc.exch-rate            no-undo . ~
define input parameter p-exch-scale          like ub.fin-doc.exch-scale           no-undo . ~
define input parameter p-f104                like ub.fin-doc.f104                 no-undo . ~
define input parameter p-f105                like ub.fin-doc.f105                 no-undo . ~
define input parameter p-f106                like ub.fin-doc.f106                 no-undo . ~
define input parameter p-f107                like ub.fin-doc.f107                 no-undo . ~
define input parameter p-f108                like ub.fin-doc.f108                 no-undo . ~
define input parameter p-f109                like ub.fin-doc.f109                 no-undo . ~
define input parameter p-f110                like ub.fin-doc.f110                 no-undo . ~
define input parameter p-f22                 like ub.fin-doc.f22                  no-undo . ~
define input parameter p-f23                 like ub.fin-doc.f23                  no-undo . ~
define input parameter p-fact-date           like ub.fin-doc.fact-date            no-undo . ~
define input parameter p-fin-doc-type        like ub.fin-doc.fin-doc-type         no-undo . ~
define input parameter p-fin-ext-doc-type    like ub.fin-doc.fin-ext-doc-type     no-undo . ~
define input parameter p-in-doc-code         like ub.fin-doc.in-doc-code          no-undo . ~
define input parameter p-in-host-code        like ub.fin-doc.in-host-code         no-undo . ~
define input parameter p-including           like ub.fin-doc.including            no-undo . ~
define input parameter p-nazn-pl             like ub.fin-doc.nazn-pl              no-undo . ~
define input parameter p-naznach-plat        like ub.fin-doc.naznach-plat         no-undo . ~
define input parameter p-ocher-pl            like ub.fin-doc.ocher-pl             no-undo . ~
define input parameter p-out-doc-code        like ub.fin-doc.out-doc-code         no-undo . ~
define input parameter p-out-host-code       like ub.fin-doc.out-host-code        no-undo . ~
define input parameter p-pay-date            like ub.fin-doc.pay-date             no-undo . ~
define input parameter p-payer-bank-name     like ub.fin-doc.payer-bank-name      no-undo . ~
define input parameter p-payer-bank-city     like ub.fin-doc.payer-bank-city      no-undo . ~
define input parameter p-payer-bik           like ub.fin-doc.payer-bik            no-undo . ~
define input parameter p-payer-c-schet       like ub.fin-doc.payer-c-schet        no-undo . ~
define input parameter p-payer-code          like ub.fin-doc.payer-code           no-undo . ~
define input parameter p-payer-code-schet    like ub.fin-doc.payer-code-schet     no-undo . ~
define input parameter p-payer-dop1          like ub.fin-doc.payer-dop1           no-undo . ~
define input parameter p-payer-dop2          like ub.fin-doc.payer-dop2           no-undo . ~
define input parameter p-payer-inn           like ub.fin-doc.payer-inn            no-undo . ~
define input parameter p-payer-kpp           like ub.fin-doc.payer-kpp            no-undo . ~
define input parameter p-payer-name          like ub.fin-doc.payer-name           no-undo . ~
define input parameter p-payer-okpo          like ub.fin-doc.payer-okpo           no-undo . ~
define input parameter p-payer-passport      like ub.fin-doc.payer-passport       no-undo . ~
define input parameter p-payer-r-schet       like ub.fin-doc.payer-r-schet        no-undo . ~
define input parameter p-payer-type          like ub.fin-doc.payer-type           no-undo . ~
define input parameter p-perm-date           like ub.fin-doc.perm-date            no-undo . ~
define input parameter p-prn-doc-code        like ub.fin-doc.prn-doc-code         no-undo . ~
define input parameter p-PS                  like ub.fin-doc.PS                   no-undo . ~
define input parameter p-receiver-bank-name  like ub.fin-doc.receiver-bank-name   no-undo . ~
define input parameter p-receiver-bank-city  like ub.fin-doc.receiver-bank-city   no-undo . ~
define input parameter p-receiver-bik        like ub.fin-doc.receiver-bik         no-undo . ~
define input parameter p-receiver-c-schet    like ub.fin-doc.receiver-c-schet     no-undo . ~
define input parameter p-receiver-code       like ub.fin-doc.receiver-code        no-undo . ~
define input parameter p-receiver-code-schet like ub.fin-doc.receiver-code-schet  no-undo . ~
define input parameter p-receiver-dop1       like ub.fin-doc.receiver-dop1        no-undo . ~
define input parameter p-receiver-dop2       like ub.fin-doc.receiver-dop2        no-undo . ~
define input parameter p-receiver-inn        like ub.fin-doc.receiver-inn         no-undo . ~
define input parameter p-receiver-kpp        like ub.fin-doc.receiver-kpp         no-undo . ~
define input parameter p-receiver-name       like ub.fin-doc.receiver-name        no-undo . ~
define input parameter p-receiver-okpo       like ub.fin-doc.receiver-okpo        no-undo . ~
define input parameter p-receiver-passport   like ub.fin-doc.receiver-passport    no-undo . ~
define input parameter p-receiver-r-schet    like ub.fin-doc.receiver-r-schet     no-undo . ~
define input parameter p-receiver-type       like ub.fin-doc.receiver-type        no-undo . ~
define input parameter p-srok-pl             like ub.fin-doc.srok-pl              no-undo . ~
define input parameter p-stat-pl             like ub.fin-doc.stat-pl              no-undo . ~
define input parameter p-str-podr-code       like ub.fin-doc.str-podr-code        no-undo . ~
define input parameter p-str-podr-type       like ub.fin-doc.str-podr-type        no-undo . ~
define input parameter p-str-podr-name       like ub.fin-doc.str-podr-name        no-undo . ~
define input parameter p-sum-base            like ub.fin-doc.sum-base             no-undo . ~
define input parameter p-sum-doc             like ub.fin-doc.sum-doc              no-undo . ~
define input parameter p-sum-rubl            like ub.fin-doc.sum-rubl             no-undo . ~
define input parameter p-sum-contr           like ub.fin-doc.sum-contr            no-undo . ~
define input parameter p-trn-doc-code        like ub.fin-doc.trn-doc-code         no-undo . ~
define input parameter p-vid-opl             like ub.fin-doc.vid-opl              no-undo . ~
define input parameter p-vid-plat            like ub.fin-doc.vid-plat             no-undo .

&glob all-fin-doc-params-doc-status-define-2 ~
define input parameter p-con-sum-rubl        like ub.fin-doc.con-sum-rubl         no-undo . ~
define input parameter p-con-sum-base        like ub.fin-doc.con-sum-base         no-undo . ~
define input parameter p-con-sum-doc         like ub.fin-doc.con-sum-doc          no-undo . ~
define input parameter p-con-sum-contr       like ub.fin-doc.con-sum-contr        no-undo . ~
define input parameter p-con-stat            like ub.fin-doc.con-stat             no-undo . ~
define input parameter p-payer-sign1               like ub.fin-doc.payer-sign1                no-undo . ~
define input parameter p-payer-sign2               like ub.fin-doc.payer-sign2                no-undo . ~
define input parameter p-payer-sign3               like ub.fin-doc.payer-sign3                no-undo . ~
define input parameter p-payer-sign4               like ub.fin-doc.payer-sign4                no-undo . ~
define input parameter p-receiver-sign1               like ub.fin-doc.receiver-sign1                no-undo . ~
define input parameter p-receiver-sign2               like ub.fin-doc.receiver-sign2                no-undo . ~
define input parameter p-receiver-sign3               like ub.fin-doc.receiver-sign3                no-undo . ~
define input parameter p-receiver-sign4               like ub.fin-doc.receiver-sign4                no-undo . ~
define input parameter p-obj-type                  like ub.fin-doc.obj-type                  no-undo . ~
define input parameter p-obj-code                  like ub.fin-doc.obj-code                  no-undo . ~
define input parameter p-doc-author                like ub.fin-doc.doc-author                no-undo . ~
define input parameter p-fact-author               like ub.fin-doc.fact-author               no-undo . ~
define input parameter p-cashbookid               like ub.fin-doc.CashBookId                no-undo .


&glob all-fin-doc-params-doc-status-transfer ~
,input ~{&prfx~}host-code            ~
,input ~{&prfx~}fin-doc-code         ~
,input ~{&prfx~}an-uchet-code        ~
,input ~{&prfx~}an-uchet-value       ~
,input ~{&prfx~}base-rate            ~
,input ~{&prfx~}base-scale           ~
,input ~{&prfx~}cel-nazn-code        ~
,input ~{&prfx~}cel-nazn-value       ~
,input ~{&prfx~}contract-code        ~
,input ~{&prfx~}contract-curr        ~
,input ~{&prfx~}contract-rate        ~
,input ~{&prfx~}contract-scale       ~
,input ~{&prfx~}cor-acc              ~
,input ~{&prfx~}cor-acc-value        ~
,input ~{&prfx~}cor-acc1             ~
,input ~{&prfx~}cor-acc1-value       ~
,input ~{&prfx~}curr-code            ~
,input ~{&prfx~}doc-date             ~
,input ~{&prfx~}shift-date           ~
,input ~{&prfx~}shift-num            ~
,input ~{&prfx~}shift-name           ~
,input ~{&prfx~}enclosure            ~
,input ~{&prfx~}exch-rate            ~
,input ~{&prfx~}exch-scale           ~
,input ~{&prfx~}f104                 ~
,input ~{&prfx~}f105                 ~
,input ~{&prfx~}f106                 ~
,input ~{&prfx~}f107                 ~
,input ~{&prfx~}f108                 ~
,input ~{&prfx~}f109                 ~
,input ~{&prfx~}f110                 ~
,input ~{&prfx~}f22                  ~
,input ~{&prfx~}f23                  ~
,input ~{&prfx~}fact-date            ~
,input ~{&prfx~}fin-doc-type         ~
,input ~{&prfx~}fin-ext-doc-type     ~
,input ~{&prfx~}in-doc-code          ~
,input ~{&prfx~}in-host-code         ~
,input ~{&prfx~}including            ~
,input ~{&prfx~}nazn-pl              ~
,input ~{&prfx~}naznach-plat         ~
,input ~{&prfx~}ocher-pl             ~
,input ~{&prfx~}out-doc-code         ~
,input ~{&prfx~}out-host-code        ~
,input ~{&prfx~}pay-date             ~
,input ~{&prfx~}payer-bank-name      ~
,input ~{&prfx~}payer-bank-city      ~
,input ~{&prfx~}payer-bik            ~
,input ~{&prfx~}payer-c-schet        ~
,input ~{&prfx~}payer-code           ~
,input ~{&prfx~}payer-code-schet     ~
,input ~{&prfx~}payer-dop1           ~
,input ~{&prfx~}payer-dop2           ~
,input ~{&prfx~}payer-inn            ~
,input ~{&prfx~}payer-kpp            ~
,input ~{&prfx~}payer-name           ~
,input ~{&prfx~}payer-okpo           ~
,input ~{&prfx~}payer-passport      ~
,input ~{&prfx~}payer-r-schet        ~
,input ~{&prfx~}payer-type           ~
,input ~{&prfx~}perm-date            ~
,input ~{&prfx~}prn-doc-code         ~
,input ~{&prfx~}PS                   ~
,input ~{&prfx~}receiver-bank-name   ~
,input ~{&prfx~}receiver-bank-city   ~
,input ~{&prfx~}receiver-bik         ~
,input ~{&prfx~}receiver-c-schet     ~
,input ~{&prfx~}receiver-code        ~
,input ~{&prfx~}receiver-code-schet  ~
,input ~{&prfx~}receiver-dop1        ~
,input ~{&prfx~}receiver-dop2        ~
,input ~{&prfx~}receiver-inn         ~
,input ~{&prfx~}receiver-kpp         ~
,input ~{&prfx~}receiver-name        ~
,input ~{&prfx~}receiver-okpo        ~
,input ~{&prfx~}receiver-passport    ~
,input ~{&prfx~}receiver-r-schet     ~
,input ~{&prfx~}receiver-type        ~
,input ~{&prfx~}srok-pl              ~
,input ~{&prfx~}stat-pl              ~
,input ~{&prfx~}str-podr-code        ~
,input ~{&prfx~}str-podr-type        ~
,input ~{&prfx~}str-podr-name        ~
,input ~{&prfx~}sum-base             ~
,input ~{&prfx~}sum-doc              ~
,input ~{&prfx~}sum-rubl             ~
,input ~{&prfx~}sum-contr            ~
,input ~{&prfx~}trn-doc-code         ~
,input ~{&prfx~}vid-opl              ~
,input ~{&prfx~}vid-plat


&glob all-fin-doc-params-doc-status-transfer-2 ~
,input ~{&prfx~}con-sum-rubl         ~
,input ~{&prfx~}con-sum-base         ~
,input ~{&prfx~}con-sum-doc          ~
,input ~{&prfx~}con-sum-contr        ~
,input ~{&prfx~}con-stat             ~
,input ~{&prfx~}payer-sign1                ~
,input ~{&prfx~}payer-sign2                ~
,input ~{&prfx~}payer-sign3                ~
,input ~{&prfx~}payer-sign4                ~
,input ~{&prfx~}receiver-sign1                ~
,input ~{&prfx~}receiver-sign2                ~
,input ~{&prfx~}receiver-sign3                ~
,input ~{&prfx~}receiver-sign4                ~
,input ~{&prfx~}obj-type                   ~
,input ~{&prfx~}obj-code                   ~
,input ~{&prfx~}doc-author                 ~
,input ~{&prfx~}fact-author                ~
,input ~{&prfx~}CashBookId


/* $Workfile$ e n d */