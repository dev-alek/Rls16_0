/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Доплюнем тех кого надо удалить! и не дулаютс

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/08/06
Author: Bakhtadze Natalya
Creation date: 02/08/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*снова откроем*/
{ str/outc-mar.i
&cd-buffer={&cd-buffer}
&subject={&subject}
&out-title="{&out-title}"
&data-by="{&data-by}"
}

define variable v-marketer-action as character no-undo .

&if "{&subject}" = "good" &then
FOR EACH buf_cd-plu where
        buf_cd-plu.obj-type = {&shop}
    and buf_cd-plu.obj-code = abs(i-obj-code)
    and buf_cd-plu.pos-type = {&cd-type-maria}
    and buf_cd-plu.plu-type = '':U :
  /*сформируем вывод для кассы MARIA */
  if buf_cd-plu.to-del then do:
    create temp-cd-plu.
    buffer-copy buf_cd-plu
    to temp-cd-plu
    .
    assign
    v-plu = TRIM(string( buf_cd-plu.plu-code, "X(40)":U ))
    v-marketer-action = 'd'
    .
    { str/mariagds.i
    &cd-buffer={&cd-buffer}
    }

  end.
END . /*for each buf_cd-plu*/
FOR EACH buf_cd-plu where
        buf_cd-plu.obj-type = {&shop}
    and buf_cd-plu.obj-code = abs(i-obj-code)
    and buf_cd-plu.pos-type = {&cd-type-maria}
    and buf_cd-plu.plu-type = {&petrolium}:
  /*сформируем вывод для кассы MARIA */
  if buf_cd-plu.to-del then do:
    create temp-cd-plu.
    buffer-copy buf_cd-plu
    to temp-cd-plu
    .
    assign
    v-plu = TRIM(string( buf_cd-plu.plu-code, "X(40)":U ))
    v-marketer-action = 'd'
    .
    { str/mariagds.i
    &cd-buffer={&cd-buffer}
    }

  end.
END . /*for each buf_cd-plu*/

&endif

&if "{&subject}" = "dis-card" &then
FOR EACH buf_cd-clu where
        buf_cd-clu.obj-type = {&shop}
    and buf_cd-clu.obj-code = abs(i-obj-code)
    and buf_cd-clu.pos-type = {&cd-type-maria}
    and buf_cd-clu.clu-type = '':U
        :
  /*сформируем вывод для кассы MARIA */
  if buf_cd-clu.to-del then do:
    create temp-cd-clu.
    buffer-copy buf_cd-clu
    to temp-cd-clu
    .
    assign
    v-marketer-action = 'd'
    .
    run maria-put in this-procedure (
                                    buffer buf_cash-desk
                                  , input out
                                  , input fname
                                  , input yes
                                  , input 0
                                  , input no
                                  , input {&tekka-obj-clients}
                                  , input 200
                                  , input buf_cd-clu.clu-code
                                  , input '':U).

  end.
END . /*for each buf_cd-clu*/
&endif

{ str/cloc-mar.i
&cd-buffer={&cd-buffer}
&pos-type=maria
&subject={&subject}
&out-title-add="{&out-title-add}"
&out-title-del="{&out-title-del}"
}
/* $Workfile$ e n d */