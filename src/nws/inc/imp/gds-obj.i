/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обновить учетную цену услуги в новостях

Автор: Перваков Михаил Сергеевич
Дата создания: 04/12/06
Author: Mikhail Pervakov
Creation date: 04/12/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

run update-service-price in this-procedure
  (input wt-gds-obj.obj-type
  ,input wt-gds-obj.obj-code
  ,input wt-gds-obj.artic
  ,input wt-gds-obj.prod-type
  ,input wt-gds-obj.prod-code
  ,input wt-gds-obj.price-base
  ,input wt-gds-obj.price-rubl
  ) .
/* $Workfile$ e n d */