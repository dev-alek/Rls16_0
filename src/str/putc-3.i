/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

вывод в поток для разных типов касс - пересылка продавцов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE putc-3.
def input param pos-type as char no-undo.
def var ii  as  int     no-undo.
&scop  validate-cash-cash if cash-cash.slr-code > ~{&max-slr-code~} then do:                        ~
    run write-log-and-file in p-log-handle (                                           ~
          input 1                                                                      ~
        , input log-file-name                                                          ~
        , input 1                                                                      ~
        , input substitute("!!!Ошибка: код продавца больше &1: продавец &2 код &3"     ~
                           , ~{&max-slr-code~}                                         ~
                           , cash-cash.slr-code                                        ~
                           , cash-cash.cash-name)                                      ~
                                            ).                                         ~
    assign                                                                             ~
    v-view-log = yes                                                                   ~
    .                                                                                  ~
    NEXT.                                                                              ~
  end
CASE pos-type:
  when {&cd-type-IBM} then do:
    FOR EACH cash-cash NO-LOCK use-index islr:
&scop max-slr-code 999
      {&validate-cash-cash}.
        PUT stream IBMstream unformatted
        '3 "'
        if cash-cash.stts = 1 then string( "D", "x(1)" ) else string( action, "x(1)" )
        '" '
        cash-cash.slr-code format ">>9"
        ' "'
        cash-cash.cash-name format "X(20)"
        '" '
        " "
        OS2-time
        {&new-line}.
    END.
  end.
  when {&cd-type-IBM-XML} then do:
    FOR EACH cash-cash NO-LOCK use-index islr:
&scop max-slr-code 999999999
      {&validate-cash-cash}.
      run bgelib-tag-open in this-procedure ( input 2, input "Saleman", input substitute("ctrl='&1' tms='&2' code='&3'"
                                                                                          , (if action = "U":U
                                                                                             then "ADD":U
                                                                                             else "DEL":U)
                                                                                          , OS2-time
                                                                                          , cash-cash.slr-code)).
      run bgelib-tag-put in this-procedure ( input 3, input "SalemanName"         , input cash-cash.cash-name, input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "SalemanLock"         , input cash-cash.stts, input 1 ).
      run bgelib-tag-close in this-procedure ( input 2, input "Saleman").
    END.
  end.
  when {&cd-type-ipc-servispl} then  do:
    FOR EACH cash-cash NO-LOCK use-index islr:
      PUT stream IBMstream UNFORMATTED
      cash-cash.slr-code
      {&comma-char}
      cash-cash.cash-name format "X(40)"
      SKIP.
    end.
  end.  /*ipc-servis+*/
END CASE .
END PROCEDURE .

/* $Workfile$ e n d */