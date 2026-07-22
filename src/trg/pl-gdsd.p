block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление pl-gds

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/24/08
Author: Dmitry Ukhanov
Creation date: 03/24/08


*/

TRIGGER PROCEDURE FOR DELETE OF ub.pl-gds.

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Триггер на удаление pl-gds":U.

{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'
                         , ub.pl-gds.obj-type
                         , ub.pl-gds.obj-code
                         , ub.pl-gds.pl-code
                         , ub.pl-gds.gds-code
                         ) " }


{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define variable v-log      as   logical      no-undo.
define variable v-db-num   like ub.db.db-num no-undo.
define variable str1       as   character    no-undo.
define variable jj         as   integer      no-undo.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .

define buffer buf_goods   for ub.goods.
define buffer buf_units   for ub.units.
define buffer buf_place   for ub.place.
define buffer buf_c-gds-hist for ub.c-gds-hist.
define buffer buf_c-pl-gds  for ub.c-pl-gds.
define buffer buf_c-plc-hist  for ub.c-plc-hist.
define buffer buf_c-table-bind for ub.c-table-bind.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile ):

  { gbl/objdbnum.i ub.pl-gds.obj-type ub.pl-gds.obj-code v-db-num }
  if g#db-num <> v-db-num
  and g#news <> yes
  then do:
      message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
              "Нельзя удалять запись ТОВАРА НА СКЛАДСКОМ МЕСТЕ в БД, отличной от БД объекта." skip
              "Номер текущей БД:" g#db-num skip "Номер БД объекта:" v-db-num
      view-as alert-box error.
      undo main-block, return error.
  end.
  if ub.pl-gds.fact-qnty <> 0 or
     ub.pl-gds.free-qnty <> 0 or 
     ub.pl-gds.cli-free-qnty <> 0 or 
     ub.pl-gds.cli-fact-qnty <> 0
      then do:
      message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
              "Количество по товару не равно 0!" skip
              "Код товара" pl-gds.gds-code skip
              "Код резервуара" pl-gds.pl-code skip             
              "Факт кол-во (е.п.)" pl-gds.cli-fact-qnty skip
              "Свободно кол-во (е.п.)" pl-gds.cli-free-qnty skip
              "Факт (кол-во)" pl-gds.fact-qnty skip
              "Свободно (кол-во)" pl-gds.free-qnty skip
              "Удаление невозможно!"
      view-as alert-box error.
      undo main-block, return error.
  end.
  find first buf_goods no-lock where
             buf_goods.gds-code = ub.pl-gds.gds-code no-error.
  if not available buf_goods then do:
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "Не найден товар с кодом " ub.pl-gds.gds-code
    view-as alert-box error.
    undo main-block, return error.
  end.
  find first buf_units no-lock where
             buf_units.unit-name = buf_goods.unit-base no-error.
  if not available buf_goods then do:
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "Не найдена единица измерения " buf_goods.unit-base
    view-as alert-box error.
    undo main-block, return error.
  end.

  if lookup( {&petrolium},  buf_units.type ) > 0 or
     lookup( {&divisional}, buf_units.type ) > 0 then do:
    /* процедура проверки возможности удаления связки топливо-резервуар */
    assign
      v-log = no
    .
    run trg/pl-gdsdv.p (  input ub.pl-gds.obj-type,
                      input ub.pl-gds.obj-code,
                      input ub.pl-gds.pl-code,
                      input ub.pl-gds.gds-code,
                     output v-log               ) no-error.
    if error-status :error then do:
        message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
                "Ошибка при вызове процедуры (триггера)" skip
                "объект" ub.pl-gds.obj-type ub.pl-gds.obj-code skip
                "скл.место" ub.pl-gds.pl-code skip
                "товар" ub.pl-gds.gds-code skip
                error-status :get-message( 1 ) skip
                return-value
        view-as alert-box error.
        undo main-block, return error.
    end.
    if v-log <> yes then do:
        message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
                "Не удалось удалить запись." skip
                return-value
        view-as alert-box information.
        undo main-block, return error.
    end.
  end.

                            /* не надо передавать но новостям */
  /* эти таблицы обновляются из триггера trn-docw.p НО НЕ ВСЕ ПОЛЯ!!!*/
  if not g#news then do:

    run nws/cmd-del.p ( input {&table_pl-gds}
                    ,input ( buffer ub.pl-gds :handle )
                    ,input "":U                          ) no-error.
    if error-status :error then do:
      assign str1 = {&new-line}.
      do jj = 1 to error-status :num-messages :
        assign str1 = str1 + {&new-line} + error-status :get-message ( jj ).
      end.
      undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&4",
                                    vss-workfile, {&new-line}, return-value, str1 ).
    end.
  end.
  if g#news <> yes then do:
    /*ЗДЕСЬ в историю пишется только при изменении нерасчетной части*/
    /*нам надо бы прикрепить историю и к place и к goods*/
    /*но так мы сделать не можем так ка не может быть chip-num быть привязан и к c-gds-hist
    придется писать два раза в историю
    в ветку c-gds-hist
    и в ветку c-plc-hist
    */
    /*дату время читаем один раз*/
    run cur-time in this-procedure(output v-today, output v-time).

    /*пишем куст для c-place-hist*/

    create buf_c-pl-gds.
    buffer-copy ub.pl-gds to buf_c-pl-gds
    assign
    buf_c-pl-gds.chip-num           = next-value (s-plc-chip, {&db-name_schema})
    buf_c-pl-gds.corr-time          = v-time
    buf_c-pl-gds.corr-user-db-num   = g#db-num
    buf_c-pl-gds.corr-user-name     = g#userid
    buf_c-pl-gds.corr-date          = v-today
    .
    create buf_c-plc-hist.
    buffer-copy buf_c-pl-gds to buf_c-plc-hist
    assign
    buf_c-plc-hist.action = integer({&hn-delete})
    buf_c-plc-hist.subject = {&table_pl-gds}
    buf_c-plc-hist.is-news = g#news
    .

    /*создаем куст для c-gds-hist*/
    { gbl/hostcode.i ub.pl-gds.obj-type ub.pl-gds.obj-code v-host-code }

    create buf_c-gds-hist.
    buffer-copy buf_c-pl-gds
    except chip-num
    to buf_c-gds-hist
    assign
    buf_c-gds-hist.action = integer({&hn-delete})
    buf_c-gds-hist.subject = {&table_pl-gds}
    buf_c-gds-hist.host-code = v-host-code
    buf_c-gds-hist.is-news = g#news
    buf_c-gds-hist.chip-num = next-value (s-gds-chip, {&db-name_schema})
    buf_c-gds-hist.source-type = (if g#news then {&hn-source-db} else "":U)
    buf_c-gds-hist.source-ref = (if g#news then string(g#news-source-db) else "":U)
    .
    create buf_c-table-bind.
    assign
    buf_c-table-bind.chip-num-rec   = buf_c-gds-hist.chip-num
    buf_c-table-bind.chip-num-src   = buf_c-pl-gds.chip-num
    buf_c-table-bind.corr-user-db-num     = buf_c-pl-gds.corr-user-db-num
    buf_c-table-bind.tbl-name-rec   = {&table_c-gds-hist}
    buf_c-table-bind.tbl-name-src   = {&table_c-plc-hist}
    buf_c-table-bind.is-news         = g#news
    buf_c-table-bind.corr-user-name  = g#userid
    buf_c-table-bind.subject        = {&table_pl-gds}
    .
    /*в новости пустим c-pl-gds из УБД в ГБД*/
    /*в новости пустим эту c-pl-gds также как и c-place*/
  end. /* if not g#news */

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_pl-gds}
        , input ( buffer ub.pl-gds:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
    run trg/userlog.p (
        input {&nwsdochs_action_delete}
        , input {&table_pl-gds}
        , input ( buffer ub.pl-gds :handle )
        , input ?
        , input ""
        ) no-error.
    if error-status :error
        then
    do:
        undo, return substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
            , {&new-line}
            , vss-workfile
            , return-value
            , error-status :get-message ( 1 ) ).
    end.
      { gbl/rum-runa.i
    ?
    this-procedure:handle
    ?
    {&thref-proc_ref-event}
    " buffer ub.pl-gds:handle "
    ''
    ''
    ''
    no-error
  }
  if error-status :error
  then
  do:
      return error substitute( "&2&1Ошибка маршрутизации записи в машину правил&1&3&1&4"
          , {&new-line}
          , vss-workfile
          , return-value
          , error-status :get-message ( 1 ) ).
end.
end.