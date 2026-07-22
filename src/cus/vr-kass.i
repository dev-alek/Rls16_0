/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Для подсчета количества для кассы (Внешний возврат на контрагента Реализация)

Автор: Чернова Светлана Александровна
Дата создания: 09/08/05
Author: Svetlana Chernova
Creation date: 09/08/05

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&IF "{1}" = "def" &THEN
define variable x-sale-code like ub.clients.obj-code   no-undo.
define variable x-sale-type like ub.clients.obj-type   no-undo.
define variable doc-code    like ub.trn-doc.doc-code   no-undo.

     Find first ub.sysconf where ub.sysconf.host-code =  v-cntxt-host-code-obj no-lock no-error.
        If available  ub.sysconf then   Assign x-sale-code = ub.sysconf.sale-code
                                            x-sale-type = ub.sysconf.sale-type.


&ELSE
      if NOT can-find (first ub.trn-doc where ub.trn-doc.doc-code = {2}doc-code
        and ub.trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
        And ub.trn-doc.discnt-type <> {&cash-desk}
        And ub.trn-doc.doc-type = {&return} no-lock) THEN

&ENDIF

/* $Workfile$ e n d */