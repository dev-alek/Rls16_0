/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Демин Алексей Сергеевич
Дата создания: 12/01/08
Author: Alexey Demin
Creation date: 12/01/08

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


define temp-table temp_twowin_itemsSelected_col no-undo
    field its-key   as integer
    field itm-key   as integer
    field itmExtKey as character

    index pi is primary unique
      its-key
    index im
      itm-key
.
define temp-table g#post-f NO-UNDO
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    field grp-code like ub.clients.grp-code
    field grp-name like ub.clients.grp-name
    field lvl-num like  ub.cli-grp.lvl-num
    INDEX pi IS UNIQUE PRIMARY obj-type obj-code
    INDEX p1  obj-name
    .
&glob N-doc-print    "Номер документа для печати"
&glob N-doc-post     "Номер документа поставщика"
&glob d-doc-post     "Дата документа поставщика"
&glob N-sf           "Номер счет-фактуры"
&glob d-sf           "Дата счет-фактуры"
&glob qnty           "Количество"
&glob sum-vat        "Суммы с НДС"
&glob vat            "Суммы НДС"
&glob sum-no-vat     "Суммы без НДС"
&glob sum-discount   "Сумма скидки"
&glob mark-up        "Наценка с НДС"
&glob mark-up-noNDS  "Наценка без НДС"
&glob reason         "Основание"
&glob sum-auto-mrgn  "Сумма авт. переоценки"





/* $Workfile$ e n d */