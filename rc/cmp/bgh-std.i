/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Препроцессинги для бухгалтерии

Автор: Булгаков Андрей Николаевич
Дата создания: 10/04/05
Author: Andrew Bulgakoff
Creation date: 10/04/05

*/

/* вид оплаты в настройках на автоматические проводки */
&IF '{&table}' = '' &THEN
  &GLOB table ub.oper-prov
&ENDIF
&IF '{&destination-field}' = '' &THEN
  &GLOB destination-field {&table}.curr-type
&ENDIF
&GLOB bgh-auto-index0      INDEX( {&destination-field}, {&bgh-auto-pay-delim0} )
&GLOB bgh-auto-index1    R-INDEX( {&destination-field}, {&bgh-auto-pay-delim1} )
&GLOB bgh-auto-code-ndx  ( {&bgh-auto-index0} + LENGTH( {&bgh-auto-pay-delim0} ) )
&SCOP bgh-auto-c-length  {&bgh-auto-index1} - ( {&bgh-auto-index0} + LENGTH( {&bgh-auto-pay-delim0} ) )
&SCOP bgh-auto-pay-plus  {&bgh-auto-pay-delim0} + TRIM( STRING( ub.pay-type.obj-code, '->>>>>>>>>9':U ) )
&GLOB bgh-auto-pay-code  INTEGER( SUBSTRING( {&destination-field}, {&bgh-auto-code-ndx}, {&bgh-auto-c-length} ) )
&GLOB bgh-auto-pay-name  ub.pay-type.obj-name + {&bgh-auto-pay-plus} + {&bgh-auto-pay-delim1}
&GLOB bgh-auto-pay-match ( {&destination-field} MATCHES ( CHR( 42 ) + {&bgh-auto-pay-plus} + {&bgh-auto-pay-delim1} ) )

/* $Workfile$   E n d */

