/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

вывод в поток для разных типов касс - пересылка кассиров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/28/05
Author: Bakhtadze Natalya
Creation date: 11/28/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define stream finp.
PROCEDURE putc-6.
def input param pos-type as char no-undo.
def var ii  as  int     no-undo.
&scop validate-cash-cash  if cash-cash.cash-code > ~{&max-cash-code~} then do:                      ~
    run write-log-and-file in p-log-handle (                                         ~
          input 1                                                                    ~
        , input log-file-name                                                        ~
        , input 1                                                                    ~
        , input substitute("!!!Ошибка: код кассира больше &1: кассир &2 код &3"      ~
                           , ~{&max-cash-code~}                                      ~
                           , cash-cash.cash-code                                     ~
                           , cash-cash.cash-name)                                    ~
                                            ).                                       ~
    assign                                                                           ~
    v-view-log = yes                                                                 ~
    .                                                                                ~
    NEXT.                                                                            ~
  end

define VARIABLE name-cash as character no-undo.
define VARIABLE name-cash1 as character no-undo.
define VARIABLE name-cash2 as character no-undo.
define variable ufo-passwd as character no-undo.
define variable ufo-enc20  as character format "x(20)" no-undo.
define variable enc-passwd as character no-undo.
/* 23/V-2018 на время input throught ... появляется консольное окно;
             вместо этого делаем os-command no-console ... с выводом в файл */
define variable v-shadow-fname as character no-undo .

CASE pos-type:
  when {&cd-type-ibm} then do:
    FOR EACH cash-cash NO-LOCK use-index icash:
&scop max-cash-code 999
      {&validate-cash-cash}.
      PUT stream IBMstream unformatted
      '6 "'
      if cash-cash.stts = 1 then string( "D", "x(1)" ) else string( action, "x(1)" )
      '" '
      cash-cash.cash-code format ">>9"
      ' "'
      cash-cash.cash-name format "X(19)"
      ' "'
      " "
      string( cash-cash.psswd, "9999" )
      " "
      OS2-time
      SKIP.
    END.
  end.
  when {&cd-type-ibm-xml} then do:
    v-shadow-fname = substitute( "pass&1.dat" , string(random(1, 80000), "99999") ) .
    FOR EACH cash-cash NO-LOCK use-index icash:
      find first ub.person where ub.person.psn-code = cash-cash.psn-code no-error.
&scop max-cash-code 999
      {&validate-cash-cash}.
      run bgelib-tag-open in this-procedure ( input 2, input "Cashier", input substitute("ctrl='&1' tms='&2' code='&3'"
                                                                                          , (if action = "U":U
                                                                                             then "ADD":U
                                                                                             else "DEL":U)
                                                                                          , OS2-time
                                                                                          , if cash-cash.cash-code eq ? then "*" else string(cash-cash.cash-code))).
if available ub.person
then do:                                                                                         
name-cash1 = if ub.person.name1 <> "" then (substring(ub.person.name1,1,1) + '.') else ''.
name-cash2 = if ub.person.name2 <> "" then (substring(ub.person.name2,1,1) + '.') else ''.
name-cash = cash-cash.cash-name + ' ' + name-cash1 + ' ' + name-cash2 .
end.
else
assign
name-cash1 = ""
name-cash2 = ""
name-cash = cash-cash.cash-name + ' ' + name-cash1 + ' ' + name-cash2 .

/*
 Имя: ufo_passwd <пароль> [<шифрованный>]
 Если задан только один аргумент - шифрование пароля.
 Программа шифрует его и выдает зашифрованный вариант в стандартный вывод.
 Зашифрованный пароль - строка из 20 шестнадцатиричных цифр.
*/
enc-passwd = "".
ufo-passwd = search('exe/ufo_passwd.exe':u).
if ufo-passwd > "" then do:
  os-command silent value(ufo-passwd) value(cash-cash.psswd) > value(v-shadow-fname) .
  input stream finp from value(v-shadow-fname) .
  repeat:
    import stream finp unformatted ufo-enc20 no-error.
    enc-passwd = enc-passwd + ufo-enc20.
  end.
  input stream finp close.
  os-delete value(v-shadow-fname).
end.

      run bgelib-tag-put in this-procedure ( input 3, input "CashierName"         , input name-cash, input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "CashierParol"        , input cash-cash.psswd, input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "CashierLock"         , input cash-cash.stts, input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "CashierINN"          , input if available person then string(person.inn) else "", input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "CashierShadow"       , input enc-passwd, input 1 ).

          for first ub.staff no-lock where ub.staff.psn-code = ub.person.psn-code
          and ub.staff.role = {&role-cashier} 
          and (ub.staff.date-end > today or ub.staff.date-end = ?),
          first ub.staff-attr no-lock where ub.staff-attr.attr-code = "CashierQRCode"
          and ub.staff-attr.role = ub.staff.role
          and ub.staff-attr.role-level = ub.staff.role-level
          and ub.staff-attr.staff-code = ub.staff.staff-code:
             run bgelib-tag-put in this-procedure ( input 3, input "CashierQRCode"       , input ub.staff-attr.attr-value, input 1 ).
          end.

      run bgelib-tag-close in this-procedure ( input 2, input "Cashier").
    END.
  end.
  when {&cd-type-Autotank} then do:
    v-shadow-fname = substitute( "pass&1.dat" , string(random(1, 80000), "99999") ) .
    FOR EACH cash-cash NO-LOCK use-index icash:
      find first ub.person where ub.person.psn-code = cash-cash.psn-code no-error.
&scop max-cash-code 999
      {&validate-cash-cash}.
      run bgelib-tag-open in this-procedure ( input 2, input "Cashier", input substitute("ctrl='&1' tms='&2' code='&3'"
                                                                                          , (if action = "U":U
                                                                                             then "ADD":U
                                                                                             else "DEL":U)
                                                                                          , OS2-time
                                                                                          , cash-cash.cash-code)). 

name-cash1 = if ub.person.name1 <> "" then (substring(ub.person.name1,1,1) + '.') else ''.
name-cash2 = if ub.person.name2 <> "" then (substring(ub.person.name2,1,1) + '.') else ''.
name-cash = cash-cash.cash-name + ' ' + name-cash1 + ' ' + name-cash2 .

/*
 Имя: ufo_passwd <пароль> [<шифрованный>]
 Если задан только один аргумент - шифрование пароля.
 Программа шифрует его и выдает зашифрованный вариант в стандартный вывод.
 Зашифрованный пароль - строка из 20 шестнадцатиричных цифр.
*/
enc-passwd = "".
ufo-passwd = search('exe/ufo_passwd.exe':u).
if ufo-passwd > "" then do:
  os-command silent value(ufo-passwd) value(cash-cash.psswd) > value(v-shadow-fname) .
  input stream finp from value(v-shadow-fname) .
  repeat:
    import stream finp unformatted ufo-enc20 no-error.
    enc-passwd = enc-passwd + ufo-enc20.
  end.
  input stream finp close.
  os-delete value(v-shadow-fname).
end.

      run bgelib-tag-put in this-procedure ( input 3, input "CashierName"         , input name-cash, input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "CashierParol"        , input cash-cash.psswd, input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "CashierLock"         , input cash-cash.stts, input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "CashierINN"          , input (person.inn), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "CashierShadow"       , input enc-passwd, input 1 ).
      run bgelib-tag-close in this-procedure ( input 2, input "Cashier").
    END.
  end.
END CASE .
END PROCEDURE .

/* $Workfile$ e n d */