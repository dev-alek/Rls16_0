/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Белоусов Илья Александрович
Дата создания: 04/16/09
Author: Ilia Belousov
Creation date: 04/16/09

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

DEFINE temp-table tt-obj no-undo
    field   obj-code    as integer
    field   obj-type    as character
    field   obj-name    as character
    field   host-code   as integer

    INDEX   pi          IS PRIMARY UNIQUE
            obj-type
            obj-code
  .

define temp-table tt-oss-ref like ub.OperServ .



DEFINE temp-table tt-gds-list no-undo
    field   gds-code    like ub.goods.gds-code
    field   artic       like ub.goods.artic
    field   prod-code   like ub.goods.prod-code
    field   prod-type   like ub.goods.prod-type
    field   gds-name    like ub.goods.gds-name

    INDEX   pi          IS PRIMARY UNIQUE
            gds-code
  .


/* $Workfile$ e n d */