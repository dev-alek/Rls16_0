/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

выгрузка УБД

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/02
Author: Dmitry Ukhanov
Creation date: 03/22/02

*/

&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/* ------------- типы выгрузки УБД --------------- */
&glob unload-online 'unload-online':U
&glob unload-copy 'unload-copy':U
&glob prep-copy 'prop-copy':U


/* $Workfile$ e n d */