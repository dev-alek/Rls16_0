/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/14/10
Author: Bakhtadze Natalya
Creation date: 01/14/10

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DEFINE TEMP-TABLE firm NO-UNDO
  FIELD referenceNo AS CHARACTER
  FIELD name AS CHARACTER
  field orgtype  as character
  field selfHost as logical
  field stts as integer
  field comment as character
  field inn as character
  field kpp as character
  field okonh as character
  field okpo as character
	INDEX pi IS UNIQUE PRIMARY
    referenceNo.


DEFINE DATASET bge-client-01
  FOR firm.


/* $Workfile$ e n d */