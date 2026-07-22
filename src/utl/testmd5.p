block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: testmd5.p $
$Archive: utl/testmd5.p $

Программа проверки работы модуля md5.p

Автор: Перваков Михаил Сергеевич
Дата создания: 01/16/04
Author: Mikhail Pervakov
Creation date: 01/16/04

MD5 test suite:
MD5 ("") = D41D8CD98F00B204E9800998ECF8427E
MD5 ("a") = 0CC175B9C0F1B6A831C399E269772661
MD5 ("abc") = 900150983CD24FB0D6963F7D28E17F72
MD5 ("message digest") = F96B697D7CB7938D525A2F31AAF161D0
MD5 ("abcdefghijklmnopqrstuvwxyz") = C3FCD3D76192E4007DFB496CCA67E13B
MD5 ("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789") =
D174AB98D277D9F5A5611C2C9F419D9F
MD5 ("123456789012345678901234567890123456789012345678901234567890123456
78901234567890") = 57EDF4A22BE3C955AC49DA2E2107B67A

*/

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: testmd5.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/testmd5.p $":U .
define variable vss-description as character no-undo initial "Программа проверки работы модуля md5.p".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define stream slog .

do
on error undo, return error return-value
:
  run validate-md5 in this-procedure
    (input ''
    ,input 'D41D8CD98F00B204E9800998ECF8427E'
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.

  run validate-md5 in this-procedure
    (input 'a'
    ,input '0CC175B9C0F1B6A831C399E269772661'
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.

  run validate-md5 in this-procedure
    (input 'abc'
    ,input '900150983CD24FB0D6963F7D28E17F72'
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.

  run validate-md5 in this-procedure
    (input 'message digest'
    ,input 'F96B697D7CB7938D525A2F31AAF161D0'
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.

  run validate-md5 in this-procedure
    (input 'abcdefghijklmnopqrstuvwxyz'
    ,input 'C3FCD3D76192E4007DFB496CCA67E13B'
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.

  run validate-md5 in this-procedure
    (input 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
    ,input 'D174AB98D277D9F5A5611C2C9F419D9F'
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.

  run validate-md5 in this-procedure
    (input '12345678901234567890123456789012345678901234567890123456789012345678901234567890'
    ,input '57EDF4A22BE3C955AC49DA2E2107B67A'
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.


procedure validate-md5 :

  define input parameter p-string          as character no-undo .
  define input parameter p-check-signature as character no-undo .

  do
  on error undo, return error return-value
  :
    define variable v-test-file-name as character no-undo .

    assign
      v-test-file-name = 'testmd5.txt':u
    .

    output stream slog to value(v-test-file-name) .
    put stream slog unformatted p-string .
    output stream slog close .

    define variable v-signature as character no-undo .

    run gbl/md5.p
      (input  v-test-file-name /* p-file-name     */
      ,output v-signature      /* p-md5-signature */
      ) no-error .
    if  error-status :error
    then do:
      undo, return error return-value .
    end.

    if v-signature <> p-check-signature
    then do:
      undo, return error vss-workfile + {&new-line}
        + "Ошибка при определении контрольной суммы" + {&new-line}
        + substitute("Строка &1", p-string) + {&new-line}
        + substitute("Контрольная сумма &1", v-signature) + {&new-line}
        + substitute("Должна быть сумма &1", p-check-signature) + {&new-line}
        .
    end.

    os-delete value(v-test-file-name) .
  end.

end procedure .