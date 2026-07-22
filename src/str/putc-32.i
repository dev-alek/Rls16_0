/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

вывод в поток для разных типов касс - пересылка персонала

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/09/05
Author: Bakhtadze Natalya
Creation date: 11/09/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE putc-staff.
define input parameter pos-type as char no-undo.

CASE pos-type:
  when {&cd-type-MAGIA-XML} then do:
    FOR EACH cash-cash NO-LOCK:
      if cash-cash.psswd <> "":U
      or cash-cash.s-psswd <> "":U
      then do:
        if cash-cash.cash-code > 9999
        or cash-cash.slr-code > 9999 then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( ("Нельзя передать на кассы типа &1 персонал с кодом кассира или с кодом официанта(продавца) > 9999:" +
                                 "&2Код клиента &3&4, код кассира &5, код продавца &6")
                                 ,{&cd-type-Magia-XML}
                                 ,{&new-line}
                                 ,{&prs}
                                 ,cash-cash.psn-code
                                 ,cash-cash.cash-code
                                 ,cash-cash.slr-code
                              )
                                          ).
        end.
        else do:
          if cash-cash.cash-code > 0 then do:
            run bgelib-tag-open in this-procedure ( input 2, input "Staff", input substitute("ctrl='&1' tms='&2' code='&3'", 'ADD', OS2-time, cash-cash.cash-code)).
            run bgelib-tag-put in this-procedure ( input 3, input "StaffName"             , input cash-cash.cash-name, input 1 ).
            run bgelib-tag-put in this-procedure ( input 3, input "StaffCashierPassword"  , input string(cash-cash.psswd, "9999":U), input 1 ).
            run bgelib-tag-put in this-procedure ( input 3, input "StaffSuperviserFLag"   , input string(cash-cash.superviser), input 1 ).
            run bgelib-tag-put in this-procedure ( input 3, input "StaffIdentType"        , input string(cash-cash.ident-type), input 1 ).
            run bgelib-tag-put in this-procedure ( input 3, input "StaffLock"  ,
                                                            input  string(if action = "U":U
                                                                          and cash-cash.stts = integer({&current-status-int})
                                                                          then 0 else 1), input 1 ).
            run bgelib-tag-close in this-procedure ( input 2, input "Staff").
          end.
          if cash-cash.slr-code > 0
          then do:
            run bgelib-tag-open in this-procedure ( input 2, input "Staff", input substitute("ctrl='&1' tms='&2' code='&3'", 'ADD', OS2-time, cash-cash.slr-code + 10000)).
            run bgelib-tag-put in this-procedure ( input 3, input "StaffName"             , input cash-cash.cash-name, input 1 ).
            run bgelib-tag-put in this-procedure ( input 3, input "StaffCashierPassword"  , input string(cash-cash.s-psswd, "9999":U), input 1 ).
            run bgelib-tag-put in this-procedure ( input 3, input "StaffSuperviserFLag"  , input string(cash-cash.superviser), input 1 ).
            run bgelib-tag-put in this-procedure ( input 3, input "StaffIdentType"        , input string(cash-cash.ident-type), input 1 ).
            run bgelib-tag-put in this-procedure ( input 3, input "StaffLock"  ,
                                                            input  string(if action = "U":U
                                                                          and cash-cash.stts = integer({&current-status-int})
                                                                          then 0
                                                                          else 1), input 1 ).
            run bgelib-tag-close in this-procedure ( input 2, input "Staff").
          end.
        end.
      end.
    END.
  end.
END CASE .
END PROCEDURE .

/* $Workfile$ e n d */