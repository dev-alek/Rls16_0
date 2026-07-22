block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: scales1.p $
$Archive: ref/scales1.p $

Сохранение изменений в карточке весов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/30/05
Author: Bakhtadze Natalya
Creation date: 11/30/05

Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!


*/

define input-output parameter p-doc-rec as recid no-undo.
define input parameter p-mode         as character no-undo .
define input parameter p-silent       as logical no-undo .
define input parameter p-db-num       like ub.scales.db-num       no-undo .
define input parameter p-scales-num   like ub.scales.scales-num     no-undo .
define input parameter p-address      like ub.scales.address      no-undo .
define input parameter p-master       like ub.scales.master       no-undo .
define input parameter p-max-gds      like ub.scales.max-gds      no-undo .
define input parameter p-scales-name  like ub.scales.scales-name  no-undo .
define input parameter p-scales-type  like ub.scales.scales-type  no-undo .
define input parameter p-remote       like ub.scales.remote       no-undo .
define input parameter p-sts          like ub.scales.sts          no-undo .
define input parameter p-unit-base    like ub.scales.unit-base    no-undo .
define input parameter p-wt-cart      like ub.scales.wt-cart      no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: scales1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/scales1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке весов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/clntattr.i }
{ gbl/check-ip.i }

define variable v-err-mess as character no-undo .
define variable v-db-num like ub.db.db-num no-undo .
define variable choice as logical no-undo .
define variable v-ok as logical no-undo .
define variable v-mess as character no-undo .
define variable v-address as character no-undo .
define variable v-dopi as integer no-undo .

define buffer buf_db for ub.db.
define buffer buf_scales for ub.scales.
define buffer b-scales for ub.scales.
define buffer dupl_scales for ub.scales.
&scop shtrih-m-format-mess           ~
        substitute("Формат адреса весов данного типа:&1" + ~
                   "nnn.nnn.nnn.nnn:port - для весов, работающих по TCP-IP&1" + ~
                   "COMn:timeout - для весов, работающих по RS232" ~
                   , ~{&new-line~} ~
                   )

&scop cas_cl5000j-format-mess           ~
        substitute("Формат адреса весов данного типа:&1" + ~
                   "nnn.nnn.nnn.nnn:port,№ - для весов, работающих по TCP-IP&1"  ~
                   , ~{&new-line~} ~
                   )

&scop DIGI_AW-4600_FX-format-mess        ~
        substitute("Формат адреса весов данного типа:&1" + ~
                   "nnn.nnn.nnn.nnn:port&1"  ~
                   , ~{&new-line~} ~
                   )


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status:get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if p-mode <> {&add-def}
  AND p-mode <> {&update} then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверный параметр p-mode" p-mode
    view-as alert-box error .
    undo main-block, return error '':u.
  end.

  { gbl/curdbnum.i v-db-num }
  if LOOKUP(p-scales-type, {&scales-type}) = 0 then do:
    assign
    v-err-mess = substitute("Неверный тип весов &1", p-scales-type).
    run err-mess(input-output v-err-mess).
    undo main-block, return error (if p-silent then v-err-mess else "s-type":U).
  end.

  find first buf_db no-lock where
            buf_db.db-num = p-db-num no-error .
  if not avail buf_db then dO:
    assign
    v-err-mess = substitute("Не найдена БД &1", p-db-num).
    run err-mess(input-output v-err-mess).
    undo main-block, return error (if p-silent then v-err-mess else '':U).
  end.
  if p-db-num <> v-db-num
  then do:
    v-err-mess = substitute("Нельзя изменять запись ВЕСОВ в чужой БД&1" +
                            "Номер текущей БД  - &2, номер БД весов - &3"
                            ,{&new-line}
                            ,v-db-num
                            ,p-db-num).
    run err-mess(input-output v-err-mess).
    undo main-block, return error (if p-silent then v-err-mess else "":U).
  end.

  if p-scales-num = 0 then do:
    assign
    v-err-mess = substitute("Не указан номер весов !") .
    run err-mess(input-output v-err-mess).
    undo main-block, return error (if p-silent then v-err-mess else "scales-num":U).
  end.
  if p-scales-type = "TIGER-SPCT2"
  and p-scales-num > 99 then do:
    assign
    v-err-mess = substitute("Для весов типа &1 номер весов не может быть > 99!", p-scales-num)
    .
    run err-mess(input-output v-err-mess).
    undo main-block, return error (if p-silent then v-err-mess else "scales-num":U).
  end.
  if p-scales-name = "" then do:
    assign
    v-err-mess = substitute("Не указано название весов !")
    .
    run err-mess(input-output v-err-mess).
    undo main-block, return error (if p-silent then v-err-mess else "scales-name":U).
  end.
  if p-address = "" then do:
    assign
    v-err-mess = substitute("Не задан адрес для весов!").
    run err-mess(input-output v-err-mess).
    undo main-block, return error (if p-silent then v-err-mess else "address":U).
  end.
  if p-scales-type = 'DIGI-SM' then do:
    v-ok = check-ip ( input p-address, output v-mess).
    if not v-ok then do:
      assign
      v-err-mess = v-mess.
      run err-mess(input-output v-err-mess).
      undo main-block, return error (if p-silent then v-err-mess else "address":U).
    end.
  end.
  if p-scales-type = 'SHTRIH-M'
  then do:
    if num-entries(p-address, ":") <> 2 then do:
      assign
      v-err-mess = {&shtrih-m-format-mess}.
      run err-mess(input-output v-err-mess).
      undo main-block, return error (if p-silent then v-err-mess else "address":U).
      .
    end.
    assign
    v-ok = (integer( entry(2, p-address, ":")) > 0)
    no-error.
    if not v-ok
    or trim(entry(2, p-address, ":"), "1234567890") <> "" then do:
      assign
      v-err-mess = {&shtrih-m-format-mess}.
      run err-mess(input-output v-err-mess).
      undo main-block, return error (if p-silent then v-err-mess else "address":U).
      .
    end.
    if  entry(1, p-address, ":") begins "COM" then do:
      assign
      v-ok = (integer( entry(1, p-address, ":")) > 0)
      no-error.
      if not v-ok
      or trim(entry(2, p-address, ":"), "1234567890") <> "" then do:
        assign
        v-err-mess = {&shtrih-m-format-mess}.
        run err-mess(input-output v-err-mess).
        undo main-block, return error (if p-silent then v-err-mess else "address":U).
        .
      end.
    end.
    else do:
      v-ok = check-ip ( input entry(1, p-address, ":"), output v-mess).
      if not v-ok then do:
        assign
        v-err-mess = v-mess + {&new-line} + {&shtrih-m-format-mess}.
        run err-mess(input-output v-err-mess).
        undo main-block, return error (if p-silent then v-err-mess else "address":U).
      end.
    end.
  end. /*if p-scales-type = 'SHTRIH-M' then do:*/
  if p-scales-type = 'CAS_CL5000J'
  or p-scales-type = 'CAS_CL5000'
  then do:
    if num-entries(p-address) <> 2 then do:
      assign
      v-err-mess = {&cas_cl5000j-format-mess}.
      run err-mess(input-output v-err-mess).
      undo main-block, return error (if p-silent then v-err-mess else "address":U).
      .
    end.
    if entry(2, p-address) <> string(p-scales-num) then do:
      assign
      v-err-mess = {&cas_cl5000j-format-mess}.
      run err-mess(input-output v-err-mess).
      undo main-block, return error (if p-silent then v-err-mess else "address":U).
      .
    end.
    if num-entries(p-address, ":") <> 2 then do:
      assign
      v-err-mess = {&cas_cl5000j-format-mess}.
      run err-mess(input-output v-err-mess).
      undo main-block, return error (if p-silent then v-err-mess else "address":U).
      .
    end.
    v-address = entry(1, p-address).

    assign
    v-ok = (integer( entry(2, v-address, ":")) > 0)
    no-error.
    if not v-ok
    or trim(entry(2, v-address, ":"), "1234567890") <> "" then do:
      assign
      v-err-mess = {&cas_cl5000j-format-mess}.
      run err-mess(input-output v-err-mess).
      undo main-block, return error (if p-silent then v-err-mess else "address":U).
      .
    end.
    v-ok = check-ip ( input entry(1, v-address, ":"), output v-mess).
    if not v-ok then do:
      assign
      v-err-mess = v-mess + {&new-line} + {&cas_cl5000j-format-mess}.
      run err-mess(input-output v-err-mess).
      undo main-block, return error (if p-silent then v-err-mess else "address":U).
    end.
  end.
  if p-scales-type = "" then do:
    v-ok = check-ip ( input entry(1, p-address, ":"), output v-mess).
    if not v-ok then do:
      assign
      v-err-mess = v-mess + {&new-line} + {&DIGI_AW-4600_FX-format-mess}.
      run err-mess(input-output v-err-mess).
      undo main-block, return error (if p-silent then v-err-mess else "address":U).
    end.
    if num-entries(p-address, ":") <> 2 then do:
      assign
      v-err-mess = {&DIGI_AW-4600_FX-format-mess}.
      run err-mess(input-output v-err-mess).
      undo main-block, return error (if p-silent then v-err-mess else "address":U).
      .
    end.
    assign
    v-dopi = integer(entry(2, p-address, ":"))
    no-error.
    if entry(2, p-address, ":") <> string(v-dopi, ">>>>9") then do:
      assign
      v-err-mess = {&DIGI_AW-4600_FX-format-mess}.
      run err-mess(input-output v-err-mess).
      undo main-block, return error (if p-silent then v-err-mess else "address":U).
      .
    end.
  end.
  if p-unit-base = "" then do:
    assign
    v-err-mess = substitute("Не задана единица измерения весов !").
    run err-mess(input-output v-err-mess).
    undo main-block, return error (if p-silent then v-err-mess else "unit-base":U).
  end.
  if NOT can-find( first ub.units where
                        ub.units.unit-name = p-unit-base ) then do:
    assign
    v-err-mess = substitute("Введенная Вами единица измерения &1&2" +
                            "ОТСУТСТВУЕТ в справочнике единиц измерений !"
                          , p-unit-base).
    run err-mess(input-output v-err-mess).
    undo main-block, return error (if p-silent then v-err-mess else "unit-base":U).
  end.
  if p-max-gds = 0 then do:
    assign
    v-err-mess = substitute("Не указана номенклатура (максимальное количество товаров на весах)!")
    .
    run err-mess(input-output v-err-mess).
    undo main-block, return error (if p-silent then v-err-mess else "max-gds":U).
  end.
  if p-master > 0 then do:
    FIND FIRST b-scales where
              b-scales.db-num = p-db-num
        AND b-scales.scales-num = p-master
    No-ERROR.
    if not avail b-scales then do:
        v-err-mess = substitute("Не найдены главные весы № &1 в БД &2&3," +
                              "подчиненными которым будут весы &4!"
                              , p-master
                              , p-db-num
                              , {&new-line}
                              , p-scales-num).
      run err-mess(input-output v-err-mess).
      undo main-block, return error (if p-silent then v-err-mess else "":U).
    end.
    if p-master = p-scales-num then do:
      v-err-mess = substitute("Весы не могут быть главными сами для себя!").
      run err-mess(input-output v-err-mess).
      undo main-block, return error (if p-silent then v-err-mess else "":U).
    end.
    if b-scales.scales-type <> p-scales-type
    OR b-scales.max-gds <> p-max-gds
    OR b-scales.unit-base <> p-unit-base then do:
      v-err-mess = substitute("Главные весы имеют отличный от данных весов ТИП или&1"  +
                              "НОМЕНКЛАТУРУ или ЕДИНИЦУ ИЗМЕРЕНИЯ!"
                              , {&new-line}).
      run err-mess(input-output v-err-mess).
    end.
    if b-scales.master > 0 then do:
      v-err-mess =  substitute("Главные-весы &1 в БД &2 сами по себе являются подчиненными для других весов!"
                              ,  b-scales.scales-num
                              , b-scales.db-num).
      run err-mess(input-output v-err-mess).
      undo main-block, return error (if p-silent then v-err-mess else "":U).
    end.
  end. /*if p-master > 0*/
  find first  dupl_scales no-lock where
              dupl_scales.db-num = p-db-num
          AND dupl_scales.address = p-address
          and dupl_scales.scales-num <> p-scales-num
          no-error .
  if available dupl_scales
  then do:
    assign
    v-err-mess = substitute("Весы с адресом уже &1 есть в БД &2&3- весы № &4 &5!"
                            ,p-address
                            ,p-db-num
                            , {&new-line}
                            ,dupl_scales.scales-num
                            ,dupl_scales.scales-name).
    if p-silent then do:
      run err-mess(input-output v-err-mess).
      undo main-block, return error v-err-mess.
    end.
    else do:
      message
      v-err-mess skip
      "Вас это устраивает ?"
      view-as alert-box WARNING buttons YES-NO update choice .
      if NOT choice then undo main-block, return error '':U.
    end.
  end. /*if available b-scales*/
  if p-mode = {&add-def} then do:
    if can-find (ub.scales where
                  ub.scales.db-num  = p-db-num
              AND ub.scales.scales-num = p-scales-num )  then do:
      assign
      v-err-mess = substitute("В БД &1 Весы с таким номером уже есть!", p-db-num)
      .
      run err-mess(input-output v-err-mess).
      undo main-block, return error (if p-silent then v-err-mess else "":U).
    end.
    create buf_scales.
    assign
    buf_scales.scales-num   = p-scales-num
    buf_scales.scales-name  = p-scales-name
    buf_scales.max-gds      = p-max-gds
    buf_scales.address      = p-address
    buf_scales.unit-base    = p-unit-base
    buf_scales.master       = p-master
    buf_scales.db-num = p-db-num
    buf_scales.scales-type = p-scales-type
    buf_scales.tot-gds = (if buf_scales.master > 0
                          then b-scales.tot-gds else buf_scales.tot-gds)
    buf_scales.to-send = (if buf_scales.master > 0
                          then b-scales.to-send
                          else buf_scales.to-send)
    p-doc-rec = recid(buf_scales)
    .
  end.
  else do:
    FIND FIRST buf_scales where
              recid(buf_scales) = p-doc-rec No-ERROR.
    if not available buf_scales then do:
      v-err-mess = substitute("&1 &2 &3&4" +
                              "Не найдена запись ВЕСЫ - p-doc-rec &5"
                              ,vss-workfile
                              ,vss-revision
                              ,vss-description
                              ,{&new-line}
                              , p-doc-rec ).
      run err-mess(input-output v-err-mess).
      undo main-block, return error (if p-silent then v-err-mess else "":U).
    end.
    if buf_scales.db-num <> p-db-num
    OR buf_scales.scales-num <> p-scales-num
    then do:
      v-err-mess = substitute("&1 &2 &3&4" +
                             "Для уже имеющейся записи нельзя изменить&4" +
                             "номер БД и номер весов"
                              ,vss-workfile
                              ,vss-revision
                              ,vss-description
                              ,{&new-line}).
      run err-mess(input-output v-err-mess).
      undo main-block, return error (if p-silent then v-err-mess else "":U).
    end.
    if p-max-gds < buf_scales.max-gds
    AND ( can-find( FIRST ub.scales-gds WHERE
                        ub.scales-gds.db-num = p-db-num
                    AND ub.scales-gds.scales-num = p-scales-num ) ) then do:
      v-err-mess = substitute("Есть товары на весах &1 БД &2&3" +
                              "Уменьшение номенклатуры невозможно!"
                            , p-scales-num
                            , p-db-num
                            , {&new-line}).
      run err-mess(input-output v-err-mess).
      undo main-block, return error (if p-silent then v-err-mess else "":U).
    end.
    if p-scales-type <> buf_scales.scales-type
    and buf_scales.tot-gds <> 0
    then do:
      assign
      v-err-mess = substitute("Для уже имеющихся весов, к которым привязаны товары,&1" +
                              "изменение типа весов может нарушить работу весов"
                              , {&new-line})
      .
      if p-silent then do:
        run err-mess(input-output v-err-mess).
        undo main-block, return error v-err-mess.
      end.
      else do:
        message
        v-err-mess skip
        "Все равно изменить тип весов?"
        view-as alert-box WARNING buttons YES-NO update choice .
        if NOT choice then undo main-block, return error '':U.
      end.
    end.
    assign
    buf_scales.scales-name = p-scales-name
    buf_scales.max-gds     = p-max-gds
    buf_scales.address     = p-address
    buf_scales.unit-base   = p-unit-base
    buf_scales.master      = p-master
    buf_scales.scales-type = p-scales-type
    .
  end.
  release buf_Scales no-error.
  if error-status:error then do:
    v-err-mess = substitute("&1 &2 &3&4" +
                            "Ошибка при сохранении записи ВЕСЫ&4" +
                            "&5&4&6&4"
                            ,vss-workfile
                            ,vss-revision
                            ,vss-description
                            ,{&new-line}
                            , error-status:get-message(1)
                            , return-value ).
    run err-mess(input-output v-err-mess).
    undo main-block, return error (if p-silent then v-err-mess else "":U).
  end.
end. /*doe*/

PROCEDURE err-mess:
DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
p-mess = substitute("Ошибка при сохранении/изменении ВЕСОВ № &1 БД &2&3&4"
                  , p-scales-num
                  , p-db-num
                  , {&new-line}
                  , p-mess) .
if not p-silent then
message
p-mess
view-as alert-box error .
END PROCEDURE.