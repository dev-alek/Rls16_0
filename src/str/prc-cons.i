/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Суслов Алексей Юрьевич
Дата создания: 04/12/06
Author: Alexey Suslov
Creation date: 04/12/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
/*
  Program:  PRC-CONS.I
  Created:  Суслов Алексей Юрьевич  18.01.00
  Description:
  Last change:  Суслов Алексей Юрьевич 18.01.00 13:37
*/
def {1} shared var ov-prch            as decimal decimals 10 no-undo.  /* {&amount} переоценки */
def {1} shared var VAT-prch           as decimal decimals 10 no-undo.  /* НДС */
def {1} shared var SLT-prch           as decimal decimals 10 no-undo.  /* Налог с продаж */
def {1} shared var ov-no-VAT-prch     as decimal decimals 10 no-undo.  /* без НДС */
def {1} shared var ov-no-SLT-prch     as decimal decimals 10 no-undo.  /* без налога с продаж */
def {1} shared var ov-no-SLT-VAT-prch as decimal decimals 10 no-undo.  /* без налога с продаж и НДС*/

/* Консигнация: */
def {1} shared var ov-cons            as decimal decimals 10 no-undo.  /* {&amount} переоценки */
def {1} shared var VAT-cons           as decimal decimals 10 no-undo.  /* НДС */
def {1} shared var SLT-cons           as decimal decimals 10 no-undo.  /* Налог с продаж */
def {1} shared var ov-no-VAT-cons     as decimal decimals 10 no-undo.  /* без НДС */
def {1} shared var ov-no-SLT-cons     as decimal decimals 10 no-undo.  /* без налога с продаж */
def {1} shared var ov-no-SLT-VAT-cons as decimal decimals 10 no-undo.  /* без налога с продаж и НДС*/