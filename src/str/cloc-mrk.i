/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Доплюнем тех кого надо удалить! и не дулаютс

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/13/05
Author: Bakhtadze Natalya
Creation date: 02/13/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*снова откроем*/
{ str/outc-ibm.i
&cd-buffer={&cd-buffer}
&subject={&subject}
&out-title="{&out-title}"
&data-by="{&data-by}"
}


FOR EACH buf_cd-plu where
       buf_cd-plu.obj-type = {&shop}
   and buf_cd-plu.obj-code = abs(i-obj-code)
   and buf_cd-plu.pos-type = {&cd-type-marketer}
   and buf_cd-plu.plu-type = '':U :
  /*сформируем вывод для кассы MARKETER */
  if buf_cd-plu.to-del = yes then do:
    create temp-cd-plu.
    buffer-copy buf_cd-plu
    to temp-cd-plu
    assign
    buf_cd-plu.charkey_one = "D"
    buf_cd-plu.to-del = yes
    .
    v-plu = TRIM(string( buf_cd-plu.plu-code, "X(40)":U )).
    put stream IBMStream unformatted
    '0 "'
    string("D":U, "x(1)" )
    '" '
    (if buf_cd-plu.b-str = "":U
    then string( buf_cd-plu.b-code, ">>>>>>>>>>>>>>>9" )
    else (string( trim( buf_cd-plu.b-str ) + fill( " ", 16 - length( trim( buf_cd-plu.b-str ) ) ), "9999999999999999" )
          )
    )
    " "
    ({&double-quote} + v-plu  + {&double-quote} )
    {&space-char}
    string(0, ">>9")
    ' "'
    '':U
    '" '
    string( 0 , ">>>>>>>>>9.99" )
    {&space-char}
    string(0, "->9.99")     /* % скидки */
    {&space-char}
    string( 0, ">>9" ) /* статус товара */
    {&space-char}
    "0":U
    /* % НДС */
    {&space-char}
    string( 0, "->>9.99")     /* % ночной скидки */
    " "
    OS2-time
    {&new-line} .
  end.
END . /*for each gds-list*/
{ str/cloc-ibm.i
&cd-buffer={&cd-buffer}
&pos-type=marketer
&subject={&subject}
&out-title-add="{&out-title-add}"
&out-title-del="{&out-title-del}"
}

/* $Workfile$ e n d */