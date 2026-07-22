block-level on error undo, throw.
/*

$Revision: 7872d7f298c6, 1094, rls $
$Author: EShklyar $
$Date: Thu Dec 14 02:13:52 2017 +0300 $
$Workfile: currenc1.p $
$Archive: ref/currenc1.p $

Сохранение изменений в карточке валюты

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/19/04
Author: Bakhtadze Natalya
Creation date: 01/19/04

Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!


*/

define input-output parameter p-rec                 as recid     no-undo.
define input parameter        p-mode                as character no-undo .
define input parameter        p-silent              as logical   no-undo .
define input parameter        p-curr-code           like ub.currency.curr-code            no-undo .
define input parameter        p-curr-abbr           like ub.currency.curr-abbr            no-undo .
define input parameter        p-part-abbr           like ub.currency.part-abbr            no-undo .
define input parameter        p-curr-name           like ub.currency.curr-name            no-undo .
define input parameter        p-curr-name-one       like ub.currency.curr-name-one        no-undo .
define input parameter        p-curr-name-three     like ub.currency.curr-name-three      no-undo .
define input parameter        p-curr-name-five      like ub.currency.curr-name-five       no-undo .
define input parameter        p-curr-eng-name       like ub.currency.curr-eng-name        no-undo .
define input parameter        p-curr-eng-name-one   like ub.currency.curr-eng-name-one    no-undo .
define input parameter        p-curr-eng-name-three like ub.currency.curr-eng-name-three  no-undo .
define input parameter        p-curr-eng-name-five  like ub.currency.curr-eng-name-five   no-undo .
define input parameter        p-part-name           like ub.currency.part-name            no-undo .
define input parameter        p-part-name-one       like ub.currency.part-name-one        no-undo .
define input parameter        p-part-name-three     like ub.currency.part-name-three      no-undo .
define input parameter        p-part-name-five      like ub.currency.part-name-five       no-undo .
define input parameter        p-okv-code            like ub.currency.okv-code             no-undo .
define input parameter        p-okv-code-chr        as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: 7872d7f298c6, 1094, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:52 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: currenc1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/currenc1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке валюты".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }

define variable v-db-num like ub.db.db-num no-undo .

define variable dopi              as integer   no-undo.
define variable v-param-type      as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable v-tth             as handle    no-undo .
define variable v-mess            as character no-undo .
define variable v-value as character no-undo.
define variable v-ttype as character no-undo.

define buffer buf_currency for ub.currency.
define buffer buf_shop for ub.shop.

define temp-table ibmrubc no-undo
  field code as integer
  index pi is unique primary code
  .

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if p-mode <> {&add-def}
  and p-mode <> {&update}
  then do:
    assign
      v-mess = substitute( "&1 (&2). Ошибка задания входных параметров. Неверный параметр p-mode (&3).", vss-workfile, vss-revision, p-mode )
    .
    run err-mess in this-procedure ( input-output v-mess ).
    undo main-block, return error (if p-silent = yes then v-mess else '':U ).
  end.

  { gbl/curdbnum.i v-db-num }
   run gbl/conf-rd.p ("is-erpRN", "", "", 0, "", "", "", no, output v-value, output v-ttype) no-error.
  if v-value = "no"  then do: 
  if v-db-num <> 0
  then do:
    assign
      v-mess = substitute( "Нельзя изменять запись ВАЛЮТЫ в УБД: Номер текущей БД &1.", v-db-num )
    .
    run err-mess in this-procedure ( input-output v-mess ).
    undo main-block, return error (if p-silent = yes then v-mess else '':U ).
  end.
  end.
  for each ibmrubc :
    delete ibmrubc.
  end.
  for each buf_shop no-lock
  on error undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    run adm/shattri.p (
        input "get":U
        ,input  {&shop}
        ,input  buf_shop.obj-code
        ,input  {&attr-cd-type-ibm}
        ,input  {&attr-cd-type-ibm_ibmrubc} /*p-param-code*/
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
    IF error-status:error then do:
      delete object v-tth.
      assign
        v-mess = substitute("&1 (&2). Ошибка при получении настроек кассы &6 по умолчанию НА ОБЪЕКТЕ &3&4:&5&6 &7"
                            , vss-workfile
                            , vss-revision
                            , {&shop}
                            , buf_shop.obj-code
                            , {&new-line}
                            , error-status:get-message(1)
                            , return-value
                            , {&cd-type-ibm}
                            )
        .
      run err-mess in this-procedure ( input-output v-mess ).
      undo main-block, return error (if p-silent = yes then v-mess else '':U ).
    end.
    delete object v-tth.
    FIND FIRST ibmrubc where
                ibmrubc.code = v-value-integer NO-ERROR.
    IF not avail ibmrubc then do:
      create ibmrubc.
      assign
      ibmrubc.code = v-value-integer.
    end.
    run adm/shattri.p (
        input "get":U
        ,input  {&shop}
        ,input  buf_shop.obj-code
        ,input  {&attr-cd-type-ibm-xml}
        ,input  {&attr-cd-type-ibm-xml_ibmrubc} /*p-param-code*/
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
    IF error-status:error then do:
      delete object v-tth.
      assign
        v-mess = substitute("&1 (&2).Ошибка при получении настроек кассы &8 по умолчанию НА ОБЪЕКТЕ &3&4:&5&6 &7"
                            , vss-workfile
                            , vss-revision
                            , {&shop}
                            , buf_shop.obj-code
                            , {&new-line}
                            , error-status:get-message(1)
                            , return-value
                            , {&cd-type-ibm-xml}
                            )
        .
      run err-mess in this-procedure ( input-output v-mess ).
      undo main-block, return error (if p-silent = yes then v-mess else '':U ).
    end.
    delete object v-tth.
    FIND FIRST ibmrubc where
                ibmrubc.code = v-value-integer NO-ERROR.
    IF not avail ibmrubc then do:
      create ibmrubc.
      assign
      ibmrubc.code = v-value-integer.
    end.
  end. /*for each buf_shop*/

  if p-mode =  {&add-def} then do:
    if can-find(first ibmrubc where p-curr-code = ibmrubc.code) then do:
      assign
        v-mess = substitute("Код валюты не может быть равен &1", p-curr-code )
        .
      run err-mess in this-procedure ( input-output v-mess ).
      undo main-block, return error (if p-silent = yes then v-mess else "curr-code":U ).
    end.
    if can-find( first buf_currency where buf_currency.curr-code = p-curr-code ) then do:
      assign
        v-mess = substitute("Уже есть валюта с кодом &1", p-curr-code )
        .
      run err-mess in this-procedure ( input-output v-mess ).
      undo main-block, return error (if p-silent = yes then v-mess else "curr-code":U ).
    end.
    if can-find( first buf_currency where buf_currency.curr-abbr = p-curr-abbr ) then do:
      assign
        v-mess = substitute("Уже есть валюта с аббревиатурой &1", p-curr-abbr )
        .
      run err-mess in this-procedure ( input-output v-mess ).
      undo main-block, return error (if p-silent = yes then v-mess else "curr-abbr":U ).
    end.
  end.

  if p-curr-abbr = "":U then do:
    assign
      v-mess = substitute("Не задана аббревиатура валюты (код &1)", p-curr-code )
      .
    run err-mess in this-procedure ( input-output v-mess ).
    undo main-block, return error (if p-silent = yes then v-mess else "curr-abbr":U ).
  end.
  if p-curr-name = "":U then do:
    assign
      v-mess = substitute("Не задано название валюты (код &1)", p-curr-code )
      .
    run err-mess in this-procedure ( input-output v-mess ).
    undo main-block, return error (if p-silent = yes then v-mess else "curr-name":U ).
  end.

  if p-mode = {&add-def} then do:
    create buf_currency.
    assign
    buf_currency.curr-code = p-curr-code
    buf_currency.curr-abbr = p-curr-abbr
    p-rec = recid(buf_currency)
    .
  end.
  else do:
    FIND FIRST buf_currency where
              recid(buf_currency) = p-rec No-ERROR.
    if not available buf_currency then do:
      assign
        v-mess = substitute("&1 (&2). Не найдена запись валюты p-rec = &3", vss-workfile, vss-revision, p-rec )
        .
      run err-mess in this-procedure ( input-output v-mess ).
      undo main-block, return error (if p-silent = yes then v-mess else "":U ).
    end.
    if buf_currency.curr-abbr <> p-curr-abbr
    or buf_currency.curr-code <> p-curr-code
    then do:
      assign
        v-mess = substitute("Для уже имеющейся записи ВАЛЮТЫ нельзя изменить аббревиатуру и/или код валюты" )
        .
      run err-mess in this-procedure ( input-output v-mess ).
      undo main-block, return error (if p-silent = yes then v-mess else "":U ).
    end.
  end.
  assign
  buf_currency.curr-name           = p-curr-name
  buf_currency.curr-abbr           = p-curr-abbr
  buf_currency.part-abbr           = p-part-abbr
  buf_currency.curr-name           = p-curr-name
  buf_currency.curr-name-one       = p-curr-name-one
  buf_currency.curr-name-three     = p-curr-name-three
  buf_currency.curr-name-five      = p-curr-name-five
  buf_currency.curr-eng-name       = p-curr-eng-name + {&delim-par} + p-okv-code-chr
  buf_currency.curr-eng-name-one   = p-curr-eng-name-one
  buf_currency.curr-eng-name-three = p-curr-eng-name-three
  buf_currency.curr-eng-name-five  = p-curr-eng-name-five
  buf_currency.part-name           = p-part-name
  buf_currency.part-name-one       = p-part-name-one
  buf_currency.part-name-three     = p-part-name-three
  buf_currency.part-name-five      = p-part-name-five
  buf_currency.okv-code            = p-okv-code
  .
  release buf_currency no-error.
  if error-status:error then do:
    assign
      v-mess = substitute("&1 (&2). Ошибка при сохранении записи ВАЛЮТЫ &3: &4: &5", vss-workfile, vss-revision, p-curr-code, error-status:get-message(1), return-value )
      .
    run err-mess in this-procedure ( input-output v-mess ).
    undo main-block, return error (if p-silent = yes then v-mess else "":U ).
 end.

end. /*doe*/

return '':U .


procedure err-mess:
  define input-output parameter p-mess as character no-undo.
    case p-silent:
    when yes then do:
      assign
      p-mess = substitute("Сохранение изменений в карточке ВАЛЮТЫ&1"
                          + "Код валюты &2&1"
                          + "Аббревиатура валюты &3&1"
                          + "Название валюты &4&1"
                          + "&5"
                         , {&new-line}
                         , p-curr-code
                         , p-curr-abbr
                         , p-curr-name
                         , p-mess)
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
end procedure.