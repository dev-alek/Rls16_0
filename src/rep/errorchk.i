define temp-table tt-errorChk no-undo
field attr-code as character
field attr-value as character
field is-true as logical
.
create tt-errorChk .
assign
tt-errorChk.attr-code = "—ум-ош"
tt-errorChk.attr-value = "нулева€ сумма оплат по чеку;"
.
create tt-errorChk .
assign
tt-errorChk.attr-code = " арт-ош"
tt-errorChk.attr-value = "номер дисконтной карты отсутствует в справочнике дис-контных карт;"
.
create tt-errorChk .
assign
tt-errorChk.attr-code = "—ер-ош"
tt-errorChk.attr-value = "серийный товар продан не по бар-коду;"
.
create tt-errorChk .
assign
tt-errorChk.attr-code = "ѕри-ош"
tt-errorChk.attr-value = "товар с непустой шкалой признаков продан по бар-коду артикула;"
.
create tt-errorChk .
assign
tt-errorChk.attr-code = "—мн-ош"
tt-errorChk.attr-value = "ошибка в номере смены;"
.
create tt-errorChk .
assign
tt-errorChk.attr-code = "ќпл-ош"
tt-errorChk.attr-value = "код оплаты не найден в справочнике типов кассового платежа;"
.
create tt-errorChk .
assign
tt-errorChk.attr-code = "—кидка-ош"
tt-errorChk.attr-value = "если скидка на итог чека дана не в последней строке чека;"
.
create tt-errorChk .
assign
tt-errorChk.attr-code = "“ов-ош"
tt-errorChk.attr-value = "товары и услуги внутри одного чека, в чеке топливный то-вар при номере “– =0, в чеке не топливный товар при номере “– <>0;"
.
create tt-errorChk .
assign
tt-errorChk.attr-code = " ол-ош"
tt-errorChk.attr-value = "штучный товар продан дробным количеством;"
.
create tt-errorChk .
assign
tt-errorChk.attr-code = "ѕрт-ош"
tt-errorChk.attr-value = "партионный товар в чеке пробит по бар-коду артикула (при-знака);"
.
create tt-errorChk .
assign
tt-errorChk.attr-code = "0"
tt-errorChk.attr-value = "товар не найден в базе данных. “овар может быть действительно не найден в базе данных или по това-ру не прошел контроль цен чеков, устанавливаемый в пункте меню —ервис/ онтроль цен чеков"
.
create tt-errorChk .
assign
tt-errorChk.attr-code = ""
tt-errorChk.attr-value = "меню —ервис/ онтроль цен чеков;"
.
create tt-errorChk .
assign
tt-errorChk.attr-code = "?"
tt-errorChk.attr-value = "в чеке не заполнены одно или несколько об€зательных полей (то-вар, тип оплат и т.д.), нулевое ко-личество по товарным позици€м;"
.
create tt-errorChk .
assign
tt-errorChk.attr-code = "ѕерс-ош"
tt-errorChk.attr-value = "не указан кассир;"
.
define temp-table tt-Chk no-undo
field attr-code as character
field attr-value as character
field is-true as logical
.
create tt-Chk .
assign
tt-Chk.attr-code = "T"
tt-Chk.attr-value = "товар означает, что чек не имеет ошибок и может быть включен в продажу"
.
create tt-Chk .
assign
tt-Chk.attr-code = "”"
tt-Chk.attr-value = "услуга означает, что чек не имеет ошибок и может быть включен в продажу"
.
