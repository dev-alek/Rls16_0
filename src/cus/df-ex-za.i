/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение временной таблички для редима ЭКСПОРТ РАСЧЕТА ЗАКАЗА

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 08/01/03 4:52

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&glob def-tt-export-ras define ~{&def-tt-option-export-ras~} temp-table export-ras no-undo ~
like ub.ord-line ~
field sum       as decimal   ~
field all-day   as integer   ~
field qnty-sale as decimal   ~
field negative-rest as logical    ~
field gds-name  as character ~
field unit-base as character ~
field unit-type as character ~
field unit-cli-type as character ~
field min-order     as decimal   ~
field service-order as decimal ~
field max-stock     as decimal   ~
field local-mark    as character ~
field ostatok-today as decimal    ~
field gds-way-all as decimal ~
index pi1 is unique primary ~
      artic                 ~
      prod-type             ~
      prod-code             ~
      obj-type              ~
      obj-code              ~
      ascending             ~
.


&glob def-tt-option-export-ras
{&def-tt-export-ras}

/* $Workfile$ e n d */