block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись бар-кода

Автор: Перваков Михаил Сергеевич
Дата создания: 04/11/06
Author: Mikhail Pervakov
Creation date: 04/11/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.bar-code old oldb .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись бар-кода".
{ cmp/vssrevis.i "substitute('&1':u,ub.bar-code.b-code)"}
{ cmp/trg-def.i  }
{ trg/new-bcod.i }
{ gbl/cur-time.i }
{ trg/bar-codh.i trig oldb ub.bar-code }

define variable v-db-num as integer   no-undo . /* номер БД к которой относится бар-код */
define variable v-root-node like ub.gds-prt.node-code no-undo .


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if new(ub.bar-code)
  and ub.bar-code.stts = integer({&hn-delete}) then return.

  /* проверяем ссылку на товар */
  find first ub.goods no-lock
    where ub.goods.gds-code = ub.bar-code.gds-code
    no-error .
  if not available ub.goods then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при создании бар-кода" skip
      "Неправильный код товара" skip
      "Бар-код" ub.bar-code.b-code skip
      "Код товара" ub.bar-code.gds-code skip
      view-as alert-box error .
    undo main-block, return error .
  end.

  /* определяем корневой признак */
  { gbl/rootnode.i
    ub.goods.artic
    ub.goods.prod-type
    ub.goods.prod-code
    v-root-node
    no-error
  }
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определение корневого признака товара" skip
      "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
      "Код товара" ub.goods.gds-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error .
  end.

  if g#news then do:
    assign
      v-db-num = g#news-source-db
    .
  end.
  else do:
    assign
      v-db-num = g#db-num
    .
  end.

  /* проверим наличие обязательных полей */
  if ub.bar-code.b-code = 0
  or ub.bar-code.b-code = ? then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при создании бар-кода" skip
      "Не задан первичный ключ бар-кода" skip
      "ub.bar-code.b-code" ub.bar-code.b-code skip
      view-as alert-box error .
    undo main-block, return error .
  end.

  if new(ub.bar-code) then do:
    /* проверяем ссылку на признак */
    find first ub.gds-prt no-lock
      where ub.gds-prt.node-code = ub.bar-code.node-code
      no-error .
    if not available ub.gds-prt then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при создании бар-кода" skip
        "Неправильная ссылка на признак" skip
        "Бар-код" ub.bar-code.b-code skip
        "Код товара" ub.bar-code.gds-code skip
        "Ссылка на признак" ub.bar-code.node-code skip
        view-as alert-box error .
      undo main-block, return error .
    end.

    /* проверяем что бар-код ссылается на признак */
    /* который принадлежит шкале товара */
    if ub.gds-prt.prt-root <> ub.goods.prt-root then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при создании бар-кода" skip
        "Шкала признака не совпадает со шкалой товара" skip
        "Бар-код" ub.bar-code.b-code skip
        "Код товара" ub.goods.gds-code skip
        "Код шкалы товара" ub.goods.prt-root skip
        "Ссылка на признак" ub.bar-code.node-code skip
        "Код шкалы признака" ub.gds-prt.prt-root skip
        view-as alert-box error .
      undo main-block, return error .
    end.

    /* проверим единицу измерения */
    if ub.bar-code.unit-cli = ?
    or ub.bar-code.unit-cli = "" then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не задана единица измерения для бар-кода" skip
        "Бар-код" ub.bar-code.b-code skip
        "ub.bar-code.unit-cli" ub.bar-code.unit-cli skip
        view-as alert-box error .
      undo main-block, return error .
    end.

    find first ub.units no-lock
      where ub.units.unit-name = ub.bar-code.unit-cli
      no-error .
    if not available ub.units then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена единица измерения основного бар-кода" skip
        "Основной бар-код" ub.bar-code.b-code skip
        "Единица измерения" ub.bar-code.unit-cli skip
        view-as alert-box error .
      undo main-block, return error .
    end.

    if ub.bar-code.node-code <> v-root-node then do:
      /* это бар-код признака */
      /* код партии и код ПН должны быть пустыми */
      if ub.bar-code.part-code <> ""
      or ub.bar-code.in-code   <> "" then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка создания бар-кода признака" skip
          "Код партии и код ПН должны быть пустыми строками" skip
          "Код партии" ub.bar-code.part-code skip
          "Код ПН"     ub.bar-code.in-code   skip
          view-as alert-box error .
        undo main-block, return error .
      end.
    end.
  end.
  else do:
    /* бар-код нельзя перемещать от одного товара к другому */
    if ub.bar-code.gds-code <> oldb.gds-code then do:
      message
        vss-workfile vss-revision vss-description skip
        "Нельзя привязывать бар-код одного товара к другому" skip
        "Бар-код" ub.bar-code.b-code skip
        "Новый код товара" ub.bar-code.gds-code skip
        "Старый код товара" oldb.gds-code skip
        view-as alert-box error .
      undo main-block, return error .
    end.

    /* нельзя менять признак бар-кода */
    if ub.bar-code.node-code <> oldb.node-code then do:
      message
        vss-workfile vss-revision vss-description skip
        "Нельзя менять признак бар-кода" skip
        "Бар-код" ub.bar-code.b-code skip
        "Новый признак" ub.bar-code.node-code skip
        "Старый признак" oldb.node-code skip
        view-as alert-box error .
      undo main-block, return error .
    end.

    /* нельзя менять единицу измерения бар-кода */
    if ub.bar-code.unit-cli <> oldb.unit-cli then do:
      message
        vss-workfile vss-revision vss-description skip
        "Нельзя менять признак бар-кода" skip
        "Бар-код" ub.bar-code.b-code skip
        "Новая единица измерения" ub.bar-code.unit-cli skip
        "Старая единица измерения" oldb.unit-cli skip
        view-as alert-box error .
      undo main-block, return error .
    end.

    /* для бар-кода партии нельзя менять */
    /* номер документа и код партии  */
    /* бар-коды создаются при закрытии документа до статус {&fact} */
    if ub.bar-code.in-code  <> oldb.in-code
    or ub.bar-code.part-code <> oldb.part-code
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Нельзя менять код ПН бар-кода" skip
        "Бар-код" ub.bar-code.b-code skip
        "Новый код ПН" ub.bar-code.in-code skip
        "Старый код ПН" oldb.in-code skip
        "Новый код партии" ub.bar-code.part-code skip
        "Старый код партии" oldb.part-code skip
        view-as alert-box error .
      undo main-block, return error .
    end.
  end.

  /* проверим коэффициент пересчета к базовой единице измерения */
  if ub.bar-code.cli-base-rate = ?
  or ub.bar-code.cli-base-rate = 0 then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не задана коэффициент пересчета единицы измерения для бар-кода" skip
      "Бар-код" ub.bar-code.b-code skip
      "ub.bar-code.cli-base-rate" ub.bar-code.cli-base-rate skip
      view-as alert-box error .
    undo main-block, return error .
  end.

  if new(ub.bar-code) then do:
   /* только для новых записей надо искать диапазон
    старые и так там находятся */
    run gen-new-code-range-if-neces( input v-db-num,
                                     input {&gbl-bc-code},
                                     input ub.bar-code.b-code,
                                     input g#news,
                                     input g#db-num,
                                     input g#news-source-db
                                   ) no-error .
    if error-status:error then do:
      message
      vss-workfile vss-revision vss-description skip
      error-status:get-message(1) skip
      return-value
      view-as alert-box error .
      undo main-block,  return error .
    end.
    if not g#news then do:
      assign
      ub.bar-code.cr-db-num = g#db-num
      .
    end.
  end.
  if  ub.bar-code.node-code = v-root-node
  and ub.bar-code.part-code = ""
  and ub.bar-code.in-code   = ""
  and ub.bar-code.unit-cli  = ub.goods.unit-base
  then do:
    /* если это корневой то не маршрутизируем */
    /* он всегда посылается вместе с товаром */
  end.
  else do:
    define variable v-result as character no-undo .
    if ub.bar-code.stts_ = integer({&hn-delete}) then do:
      buffer-compare
      ub.bar-code to oldb
      case-sensitive
      save result in v-result.
    end.
    if ub.bar-code.stts_ <> integer({&hn-delete})
    or v-result <> "stts_":U then do:
    /*если stts_ = delete - то в делов вступает two-commit*/
      run str/callnews.p
        (input {&table_bar-code}
        ,input (buffer ub.bar-code:handle)
        ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно маршрутизировать bar-code для отправки в новости" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box.
        undo main-block, return error return-value .
      end.
      { gbl/rum-runa.i
        ?
        this-procedure:handle
        ?
        " ( if new(ub.bar-code) then {&goods-proc_addlcode} else {&goods-proc_updatelcode} )"
        " buffer oldb:handle "
        " buffer ub.bar-code:handle "
        ''
        ''
        no-error
       }
      if error-status:error
      then do:
        if not g#news then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры rum-runa.i" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        end.
        undo main-block,  return error return-value .
      end.
    end.
    if not new(ub.bar-code) then do:
      define variable v-l as logical no-undo .
      buffer-compare ub.bar-code to oldb
      case-sensitive
      save result in v-l.
      if v-l then return.
    end.
    run bar-codh_write-bar-code-trigger in this-procedure  (
                                         input new(ub.bar-code)
                                        ,input integer({&hn-update})
                                        ,input (if g#news
                                                then {&hn-source-db}
                                                else (if g#esys
                                                      then {&hn-source-esys}
                                                      else "":U
                                                      )
                                                )
                                        ,input (if g#news
                                                then string(g#news-source-db)
                                                else (if g#esys
                                                      then string(g#esys-source-esys)
                                                      else  "":U)
                                                )
                                      ) .
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_bar-code}
        , input ( buffer ub.bar-code:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.