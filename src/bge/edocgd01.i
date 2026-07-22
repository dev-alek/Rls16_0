/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

СХема для базовой выгрузки товаров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/25/09
Author: Bakhtadze Natalya
Creation date: 12/25/09

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


DEFINE TEMP-TABLE good NO-UNDO
	FIELD gds-code AS INTEGER
  field deleted as logical
	FIELD artic AS CHARACTER
  FIELD prodtype AS CHARACTER
  FIELD prodcode AS INTEGER
  field units as character
  field type as character
  field okdp as character
  field name as character
	INDEX pi IS UNIQUE PRIMARY
		gds-code.

DEFINE DATASET bge-good-01
  FOR good.


/* $Workfile$ e n d */