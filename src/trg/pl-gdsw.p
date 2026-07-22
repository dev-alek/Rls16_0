block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись pl-gds

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/16/07
Author: Dmitry Ukhanov
Creation date: 08/16/07


*/

TRIGGER PROCEDURE FOR WRITE OF ub.pl-gds NEW BUFFER new_pl-gds OLD BUFFER old_pl-gds.

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Триггер на запись pl-gds":U.
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'
                         , new_pl-gds.obj-type
                         , new_pl-gds.obj-code
                         , new_pl-gds.pl-code
                         , new_pl-gds.gds-code
                         ) " }

{ cmp/trg-def.i  }
{ gbl/cur-time.i }

main-block:
do
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :

  define variable v-l-ref     as logical no-undo.
  define variable v-l-rest    as logical no-undo.
  define variable v-db-num    like ub.db.db-num no-undo.
  define variable v-today     as date    no-undo .
  define variable v-time      as integer no-undo .
  define variable v-host-code like ub.sysconf.host-code no-undo .
  define variable v-cli-qnty  as decimal no-undo .
  define variable v-sign      as decimal no-undo .

  define buffer buf_goods        for ub.goods .
  define buffer buf_doc-line     for ub.doc-line .
  define buffer buf_doc-pl       for ub.doc-pl .
  define buffer buf_c-pl-gds     for ub.c-pl-gds.
  define buffer buf_c-gds-hist   for ub.c-gds-hist.
  define buffer buf_c-plc-hist   for ub.c-plc-hist.
  define buffer buf_c-table-bind for ub.c-table-bind.

  buffer-compare new_pl-gds
    using PS
    gds-code
    max-qnty
    obj-code
    obj-type
    pl-code
    status_
    tolerance
    to old_pl-gds
    case-sensitive
    save result in v-l-ref.
  buffer-compare new_pl-gds
    using cli-qnty
    fact-qnty
    free-qnty
    cli-fact-qnty
    cli-free-qnty
    to old_pl-gds
    case-sensitive
    save result in v-l-rest.

  { gbl/objdbnum.i new_pl-gds.obj-type new_pl-gds.obj-code v-db-num no-error }
  if error-status :error then 
  do:
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
      "Ошибка при определении БД объекта товара на складском месте" skip
      "объект" new_pl-gds.obj-type new_pl-gds.obj-code skip
      view-as alert-box error.
    undo main-block, return error.
  end.

  find first buf_goods no-lock
    where buf_goods.gds-code = new_pl-gds.gds-code
    .


  /* если только справочные поля изменились то надо передавать но новостям */
  /* а если нет эти таблицы обновляются из триггера trn-docw.p */
  if v-l-ref <> true then 
  do:
    if g#db-num <> v-db-num
      and g#news <> yes
      then 
    do:
      message
        vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
        "Нельзя изменять запись ТОВАРА НА СКЛАДСКОМ МЕСТЕ в БД, отличной от БД объекта" skip
        "Номер текущей БД " g#db-num skip
        "Номер БД объекта " v-db-num
        view-as alert-box error.
      undo, return error.
    end.
    run str/callnews.p
      ( input {&table_pl-gds}
      ,input ( buffer new_pl-gds :handle )
      ).
  end.

  if v-l-rest <> true then 
  do:
    if old_pl-gds.cli-free-qnty <> ?
      and new_pl-gds.cli-free-qnty = ?
      then 
    do:
      undo, return error substitute( 'Ошибка в свободном количестве на месте хранения&1'
        + 'Товар &2&1'
        + 'Место хранения: &3 (&4 &5)&1'
        + 'Свободное кол-во: &7 (&6)&1'
        + 'Фактическое кол-во: &8 (&6)&1'
        ,{&new-line}
        ,buf_goods.gds-code
        ,new_pl-gds.pl-code
        ,new_pl-gds.obj-type
        ,new_pl-gds.obj-code
        ,buf_goods.unit-cli
        ,new_pl-gds.cli-free-qnty
        ,new_pl-gds.cli-fact-qnty
        ).
    end.

&glob TDEDT_list_not-rsrv '{&bef-TDEDT_Pri_Vnesh},~
{&bef-TDEDT_Pri_Perem},~
{&bef-TDEDT_Pri_Prvo},~
{&bef-TDEDT_Vozvrat_Vnesh},~
{&bef-TDEDT_Vozvrat_Vnesh_Kass},~
{&bef-TDEDT_Vozvrat_Perem},~
{&bef-TDEDT_Inv}':U

    if new_pl-gds.free-qnty = new_pl-gds.fact-qnty
      and new_pl-gds.cli-free-qnty <> new_pl-gds.cli-fact-qnty
      then 
    do:
      assign
        v-cli-qnty = 0.0
        .
      for each buf_doc-line no-lock
        where buf_doc-line.obj-type  = new_pl-gds.obj-type
        and buf_doc-line.obj-code  = new_pl-gds.obj-code
        and buf_doc-line.prod-type = buf_goods.prod-type
        and buf_doc-line.prod-code = buf_goods.prod-code
        and buf_doc-line.artic     = buf_goods.artic
        and buf_doc-line.status_   <> {&fact}
        ,first buf_doc-pl no-lock
        where buf_doc-pl.obj-type = buf_doc-line.obj-type
        and buf_doc-pl.obj-code = buf_doc-line.obj-code
        and buf_doc-pl.pl-code  = new_pl-gds.pl-code
        and buf_doc-pl.out-code = buf_doc-line.doc-code
        and buf_doc-pl.gds-code = buf_goods.gds-code
        on error undo, return error return-value
        :
        if lookup( buf_doc-line.ext-doc-type, {&TDEDT_list_not-rsrv} ) > 0 then 
        do:
          next.
        end.
        if lookup( buf_doc-line.ext-doc-type, {&TDEDT_out_list} ) > 0 then 
        do:
          assign
            v-sign = -1.0
            .
        end.
        else 
        do:
          /* оставляем все как есть */
          assign
            v-sign = 1.0
            .
          if lookup( buf_doc-line.ext-doc-type, {&TDEDT_in_list} ) = 0 then 
          do:
            undo, return error substitute( '&1. Тип "&2" не внесен в списки документов уменьшающих(увеличивающих) остатки!', vss-workfile, buf_doc-line.ext-doc-type).
          end.
        end.
        if buf_doc-pl.doc-qnty = 0.0
          and buf_doc-pl.cli-doc-qnty <> 0.0
          then 
        do:
          assign
            v-cli-qnty = v-cli-qnty + v-sign * buf_doc-pl.cli-doc-qnty
            .
        end.
      end.
      if new_pl-gds.cli-free-qnty <> new_pl-gds.cli-fact-qnty - v-cli-qnty then 
      do:
        undo, return error substitute( 'Ошибка в свободном количестве на месте хранения&1'
          + 'Товар &2&1'
          + 'Место хранения: &3 (&4 &5)&1'
          + 'После документа: &7 (&6)&1'
          + 'Должно быть: &8 (&6)'
          ,{&new-line}
          ,buf_goods.gds-code
          ,new_pl-gds.pl-code
          ,new_pl-gds.obj-type
          ,new_pl-gds.obj-code
          ,buf_goods.unit-cli
          ,new_pl-gds.cli-free-qnty
          ,new_pl-gds.cli-fact-qnty - v-cli-qnty
          ).
      end.
    end.
  end.

  if g#news <> true
    and v-l-ref <> true
    then 
  do:
    /*ЗДЕСЬ в историю пишется только нерасчетная часть*/
    /*нам надо бы прикрепить историю и к place и к goods*/
    /*но так мы сделать не можем так ка не может быть chip-num быть привязан и к c-gds-hist
    придется писать два раза в историю
    в ветку c-gds-hist
    и в ветку c-plc-hist
    */
    /*дату время читаем один раз*/
    run cur-time in this-procedure(output v-today, output v-time).
    /*сначала создаем куст для c-plc-hist*/
    create buf_c-pl-gds.
    buffer-copy old_pl-gds
      except
      obj-type
      obj-code
      gds-code
      pl-code
      to buf_c-pl-gds
      assign
      buf_c-pl-gds.gds-code           = new_pl-gds.gds-code
      buf_c-pl-gds.obj-type           = new_pl-gds.obj-type
      buf_c-pl-gds.obj-code           = new_pl-gds.obj-code
      buf_c-pl-gds.pl-code            = new_pl-gds.pl-code
      buf_c-pl-gds.chip-num           = next-value (s-plc-chip, {&db-name_schema})
      buf_c-pl-gds.corr-time          = v-time
      buf_c-pl-gds.corr-user-db-num   = g#db-num
      buf_c-pl-gds.corr-user-name     = g#userid
      buf_c-pl-gds.corr-date          = v-today
      .
    create buf_c-plc-hist.
    buffer-copy buf_c-pl-gds to buf_c-plc-hist
      assign
      buf_c-plc-hist.action = (if new new_pl-gds then integer({&hn-create}) else integer({&hn-update}))
      buf_c-plc-hist.subject = {&table_pl-gds}
      buf_c-plc-hist.is-news = g#news
      .
    { gbl/hostcode.i new_pl-gds.obj-type new_pl-gds.obj-code v-host-code }

    create buf_c-gds-hist.
    buffer-copy buf_c-pl-gds
      except chip-num
      to buf_c-gds-hist
      assign
      buf_c-gds-hist.action = (if new new_pl-gds then integer({&hn-create}) else integer({&hn-update}))
      buf_c-gds-hist.subject = {&table_pl-gds}
      buf_c-gds-hist.host-code = v-host-code
      buf_c-gds-hist.is-news = g#news
      buf_c-gds-hist.chip-num =   next-value (s-gds-chip, {&db-name_schema})
      buf_c-gds-hist.source-type = (if g#news then {&hn-source-db} else "":U)
      buf_c-gds-hist.source-ref = (if g#news then string(g#news-source-db) else "":U)
      .
    create buf_c-table-bind.
    assign
      buf_c-table-bind.chip-num-rec     = buf_c-gds-hist.chip-num
      buf_c-table-bind.chip-num-src     = buf_c-pl-gds.chip-num
      buf_c-table-bind.corr-user-db-num = buf_c-pl-gds.corr-user-db-num
      buf_c-table-bind.tbl-name-rec     = {&table_c-gds-hist}
      buf_c-table-bind.tbl-name-src     = {&table_c-plc-hist}
      buf_c-table-bind.is-news          = g#news
      buf_c-table-bind.corr-user-name   = g#userid
      buf_c-table-bind.subject          = {&table_pl-gds}

      .
  /*в новости пустим c-pl-gds из УБД в ГБД*/
  /*в новости пустим эту c-pl-gds также как и c-place*/
  end. /* if not g#news */
  

  if g#oxml = yes then 
  do:
    run str/calloxml.p
      ( input {&nwsdochs_action_update}
      ,input {&table_pl-gds}
      ,input ( buffer ub.pl-gds:handle )
      ) no-error.
    if error-status :error then 
    do:
      undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
        , {&new-line}
        , vss-workfile
        , return-value
        , error-status :get-message ( 1 ) ).
    end.
  end.
  
  define variable v-is as logical no-undo .
  buffer-compare old_pl-gds to new_pl-gds
    case-sensitive save result in v-is .
  if  new new_pl-gds then v-is = yes .      
  if v-is then 
  do:

  
  { gbl/rum-runa.i
    ?
    this-procedure:handle
    ?
    {&thref-proc_ref-event}
    " buffer old_pl-gds:handle "
    " buffer new_pl-gds:handle "
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
end.