/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

вывод в поток для разных типов касс - пересылка последовательнсости расчета налогов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE putc-15.
define input parameter pos-type as char no-undo.
define input parameter p-cash-os like ub.cash-desk.cash-os no-undo .

CASE pos-type:
  when {&cd-type-IBM-XML} then do:
    run bgelib-tag-open in this-procedure ( input 2, input "TaxSequence"
                                          , input substitute("ctrl='&1' tms='&2' code='&3'"
                                                          , (IF action = "U":U
                                                                  then "ADD":U
                                                                  else "DEL":U)
                                                           ,OS2-time
                                                           ,1)
                                          ).
    run bgelib-tag-put in this-procedure ( input 3, input "TaxSeq1"
                                          , input trim({&road-tax-code}), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "TaxSeq2"
                                          , input trim({&slt-tax-code}), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "TaxSeq3"
                                          , input trim({&vat-tax-code}), input 1 ).
    run bgelib-tag-close in this-procedure ( input 2, input "TaxSequence" ).


  end.
END CASE .
END PROCEDURE .
/* $Workfile$ e n d */