/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Функция нахождения короткого номера по ДЛИННОМУ НОМЕРУ карты  с использованием маски

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/11/05
Author: Bakhtadze Natalya
Creation date: 10/11/05

например длинный номер 123457865439 маска 12345DDDDDD9 выведет  786543

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

function card-by-mask returns CHARACTER (
                                             input p-cli-mask  as character
                                            ,input p-cc-run as INTEGER
                                            ,input p-full-number as character
                                            ):
define variable ii as integer no-undo .
define variable v-cli-mask as character no-undo .
define variable v-full-number as character no-undo .
define variable v-short-number as character no-undo .
  if length(p-cli-mask) <> length(p-full-number) then return '':U.
  /*заменим все D на числа из распознаваемого номера*/
  v-cli-mask = p-cli-mask.
  do ii = 1 to length(p-cli-mask):
    if substring(v-cli-mask, ii, 1) = 'D' then do:
      substring(v-cli-mask, ii, 1) = substring(p-full-number, ii, 1).
      assign
      v-short-number = v-short-number  + substring(p-full-number, ii, 1)
      v-full-number = v-full-number + substring(p-full-number, ii, 1)
      .
    end.
    else do:
       if substring(v-cli-mask, ii, 1) = 'C' then do:
         v-full-number = v-full-number + substring(p-full-number, ii, 1).
       end.
       else do:
         v-full-number = v-full-number + substring(p-cli-mask, ii, 1).
       end.
    end.
  END.
  if v-full-number <> p-full-number then return '':U.
  v-full-number = ''.

  /*получилось нечто может быть с буквой C*/
  if index(v-cli-mask, 'C') > 0 then do:
    if p-cc-run = 0 then return '':U.
    /*есть алгоритм*/
    CASE p-cc-run:
      when integer({&dcm-cc-algo-luhn}) then do:
        run gbl/pluhnalg.p ( input v-cli-mask, output v-full-number) no-error .
      end.
      otherwise do:
        error-status:error = yes.
      end.
    end case.
    if error-status:error then do:
      return '':U.
      /*
      undo, return error substitute("Ошибка при определении КЦ в карте &1 по маске &2:&3&4&3&5"
                                    , p-full-number
                                    , p-cli-mask
                                    , {&new-line}
                                    , error-status:get-message(1)
                                    , return-value ).*/
    end.
    if v-full-number <> p-full-number then return '':U.
  end.
  /*дисконтный код уже извелечен*/
  return v-short-number.
end function.

/* $Workfile$ e n d */