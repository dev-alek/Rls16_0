/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Функции работы с масками клиента и дис карты

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/17/04
Author: Bakhtadze Natalya
Creation date: 05/17/04

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure check-mask-card :
define input parameter p-mask like ub.dis-card.d-card no-undo .
define input parameter p-silence as logical no-undo .
define output parameter p-ok as logical no-undo .
define output parameter p-descr as character no-undo .

define variable v-dec as decimal no-undo.

&scop mes-err if not p-silence then do: ~
 message p-descr view-as alert-box error . ~
end. ~

  do
  on error undo, return error
  :

    /*длина не может быть больше 19*/
    if length(p-mask) > 19 then do:
      assign
      p-descr = substitute("Маска &1 имеет длину более 19 символов", p-mask)
      .
      {&mes-err}
      return.
    end.
    /*если все символы циры - это уже не маска*/
    assign
    v-dec = decimal(p-mask)
    no-error .
    if not error-status:error and round(v-dec, 0) = v-dec and v-dec >= 0 then do:
      assign
      p-descr = substitute("Маска &1 не может быть числом", p-mask)
      .
      {&mes-err}
      return.
    end.
    /*проверим что звездочек не больше одной - для жтого обрежем до места где звездочка и посмотрим есть ли еще * */
    if index(p-mask, "*":U) > 0
    and index(substring(p-mask, index(p-mask, "*") + 1), "*") > 0 then do:
      assign
      p-descr = substitute("Маска &1 не может содержать более одного символа *", p-mask)
      .
      {&mes-err}
      return.
    end.
    if index(p-mask, "*":U) > 0
    and index(p-mask, "*":U) <>  Length(p-mask)
    then do:
      assign
      p-descr = substitute("Символ * в маска &1 может стоять только в конце", p-mask)
      .
      {&mes-err}
      return.
    end.
    /*заменим допустимые символы ? и * на цифрц 0 и преобразуем в децимал - если децимал целый и больше 0 то это прав маска*/
    assign
    v-dec = decimal(replace(replace(p-mask, {&question-mark}, "0":U), "*":U, "0":U))
    no-error .
    if not error-status:error
    and round(v-dec, 0) = v-dec and v-dec >= 0 then do:
      assign
      p-ok = yes.
      return.
    end.
    else do:
      assign
      p-descr = substitute("Маска &1 содержит недопустимые символы - разрешенные символы: 1,2,3,4,5,6,7,8,9,0, * и ?", p-mask)
      .
      {&mes-err}
      return.
    end.


  end.

end procedure. /* check-mask-card */

procedure check-cli-mask :
define input parameter p-mask like ub.dis-card-mask.mask no-undo .
define input parameter p-silence as logical no-undo .
define input parameter p-addvalidchars as character no-undo .
define input parameter p-mask-type as character no-undo .
define input parameter p-cc-run as integer no-undo .
define output parameter p-ok as logical no-undo .
define output parameter p-descr as character no-undo .

define variable v-dec as decimal no-undo.
define variable v-dec-dop as character no-undo .
define variable v-old-dop as character no-undo .
define variable ii as integer no-undo .

&scop mes-err if not p-silence then do: ~
 message p-descr view-as alert-box error . ~
end. ~

  do
  on error undo, return error
  :

    /*длина не может быть больше 19*/
    if length(p-mask) > 19 then do:
      assign
      p-descr = substitute("Маска &1 имеет длину более 19 символов", p-mask)
      .
      {&mes-err}
      return.
    end.
    /*если все символы циры - это уже не маска*/
    assign
    v-dec = decimal(p-mask)
    no-error .
    if not error-status:error and round(v-dec, 0) = v-dec and v-dec >= 0 then do:
      assign
      p-descr = substitute("Маска &1 не может быть числом", p-mask)
      .
      {&mes-err}
      return.
    end.
    /*проверим что звездочек не больше одной - для жтого обрежем до места где звездочка и посмотрим есть ли еще * */
    if index(p-mask, "*":U) > 0
    and index(p-addvalidchars, "*") > 0
    and index(substring(p-mask, index(p-mask, "*") + 1), "*") > 0 then do:
      assign
      p-descr = substitute("Маска &1 не может содержать более одного символа *", p-mask)
      .
      {&mes-err}
      return.
    end.
    if index(p-addvalidchars, "*") > 0
    and index(p-mask, "*":U) > 0
    and index(p-mask, "*":U) <>  Length(p-mask)
    then do:
      assign
      p-descr = substitute("Символ * в маске &1 может стоять только в конце", p-mask)
      .
      {&mes-err}
      return.
    end.
    /*заменим допустимые символы ? и * на цифрц 0 и преобразуем в децимал - если децимал целый и больше 0 то это прав маска*/
    assign
    v-dec-dop = replace(replace(p-mask, {&question-mark}, "0":U), "*":U, "0":U)
    .
    do ii = 1 to num-entries(p-addvalidchars):
      assign
      v-old-dop = v-dec-dop
      v-dec-dop = replace(v-dec-dop, entry(ii, p-addvalidchars), "0":U)
      .
      if p-mask-type = entry(ii, p-addvalidchars)
      and (entry(ii, p-addvalidchars) <> 'C':U or p-cc-run > 0)
      and v-dec-dop = v-old-dop then do:
        assign
        p-descr = substitute("Маска &1 должна содержать хотя бы один символ &2", p-mask, p-mask-type)
        .
        {&mes-err}
        return.

      end.
    end.
    assign
    v-dec = decimal(v-dec-dop)
    no-error .
    if not error-status:error
    and round(v-dec, 0) = v-dec and v-dec >= 0 then do:
      assign
      p-ok = yes.
      return.
    end.
    else do:
      assign
      p-descr = substitute("Маска &1 содержит недопустимые символы - разрешенные символы: 1,2,3,4,5,6,7,8,9,0,?&2"
                          , p-mask
                          , (if p-addvalidchars = "":u then "":U else ({&comma-char} + p-addvalidchars))
                          )
      .
      {&mes-err}
      return.
    end.


  end.

end procedure. /* check-mask-card */


/* $Workfile$ e n d */