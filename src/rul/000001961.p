/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 11

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/06/08
Author: Bakhtadze Natalya
Creation date: 05/06/08

---------------------------&start-codex_id=11;ruleset_id=1;-------------------------------
Операции над списком товаров
Экспорт списка товаров в XML файл
---------------------------&end-codex_id=11;ruleset_id=1;-------------------------------

*/


/*---------------------------&start-using-class&-------------------------------*/
using Ibs.Th.Rul.Route-data_.
block-level on error undo, throw.

/*---------------------------&end-using-class&---------------------------------*/


define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-cont-handle  as handle no-undo .
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-call-id as character no-undo .
define input parameter p-order-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-is-dynamic as logical no-undo .
define input parameter p-doc-type as character no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-doc-code as character no-undo .
define input parameter p-process-file-name as character no-undo .
define input parameter p-save       as integer no-undo .
define input parameter v-curr-r-b   as character no-undo .
define input parameter p-cmd-proc-handle as handle no-undo .
define input parameter p-cmd-code  as integer no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 11".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/garbcoll.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }
&glob cmd-proc-handle p-cmd-proc-handle
&glob cmd-code p-cmd-code
{ nws/temp-cmd.i "SHARED" }
{ rul/cl-hist.i "shared" }
{ gbl/gate-clb.i }
{ cmp/gds-list.i gds-list def "shared" }
{ ref/gds-attr.i }
{ rul/rum-fn.i }
{ ref/fbrglib.i }
{ str/tt-tax.i "new shared" tt-tax full }
{ bge/tmpcxmlh.i }

define temp-table temp-goods-attr no-undo like ub.goods-attr.
define temp-table temp-fbr-gds-grp no-undo like ub.fbr-gds-grp
field f-name as character .

/*переменные контекста*/
/*это у нас объект 0*/
define variable v-current-gds-code as integer no-undo .
define variable v-current-artic as character no-undo .
define variable v-current-prod-type as character no-undo .
define variable v-current-prod-code as integer no-undo .
define variable v-current-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-current-lock as integer no-undo .
define variable v-current-wait as integer no-undo .
define variable v-save as integer no-undo .
define variable v-esys-cmd-proc-handle as handle no-undo .
define variable v-esys-cmd-code as integer no-undo .
define variable log-file-name                as character      no-undo init "process-gds-list.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-current-db-num as integer no-undo .
define variable v-last-error-message as character no-undo .
/*****************************/
define variable file-name as char.
define variable v-sign as integer no-undo .
define variable v-gate-rec as character no-undo .
define variable num-rec as integer no-undo .
define variable num-rec-ok as integer no-undo .



{ rul/seterror.i }

define buffer buf_temp-cmd for temp-cmd.
define shared temp-table tt0-rule-call-param no-undo like ub.rule-call-param.

&scop display-message ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~).            ~
          assign v-view-log = yes



/*---------------------------&start-rule-call-param&-------------------------------*/

 define variable p-xsd-file as character no-undo.
 define variable p-pck-num-rec as integer no-undo .

/*---------------------------&end-rule-call-param&-------------------------------*/


/* ------------------------- &start-i-script& -----------------------------------*/


/* ------------------------- &end-i-script& -----------------------------------*/

on delete of this-procedure do:
  run garbcoll_clear in this-procedure .
end.

run load-ruleset-context in this-procedure ( input p-ruleset-id) no-error.
if error-status:error then do:
  undo, return error return-value .
end.

/* ------------------------- &start-def-vars& -----------------------------------*/

define variable ExpData1 as class Route-data_ no-undo .
&scop constructor_1 ( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle)
ExpData1 = new Route-data_{&constructor_1} .

/* ------------------------- &end-def-vars& -----------------------------------*/

if not this-procedure:persistent then do:
  run proc-main in this-procedure no-error .
  if error-status:error then do:
      for each temp-goods-attr:
        delete temp-goods-attr.
      end.

      run garbcoll_clear in this-procedure .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
  end.
  run garbcoll_clear in this-procedure .
end.

procedure proc-main :

_main:
do
on error undo, return error substitute( "&1&2&3&2&4", return-value, {&new-line}, error-status :get-message (1), v-last-error-message)
:

  define variable v-attr-list as character no-undo .
  define variable v-ii as integer no-undo .
  define variable v-loc-file-name as character no-undo .
  define variable v-is-global as logical no-undo .
  define variable v-is-scaleable as logical no-undo .
  define variable v-is-weight as logical no-undo .
  define variable v-is-petrolium as logical no-undo .
  define buffer buf_goods for ub.goods.
  define buffer buf_bar-code for ub.bar-code.
  define buffer buf_prod-bc for ub.prod-bc.
  define buffer locked_goods-attr for ub.goods-attr.
  define buffer buf_clients for ub.clients.
  define buffer buf_gds-prt for ub.gds-prt.
  define buffer buf_fbr-gds-grp for ub.fbr-gds-grp.
  define buffer buf_temp-fbr-gds-grp for temp-fbr-gds-grp.
  define buffer buf_gds-obj-prop for ub.gds-obj-prop.
  define buffer buf_alc-type-gds for ub.alc-type-gds.

/*надо найти настройки маршрутизации и записи истории для товаров*/

  v-loc-file-name = file-name.

  _stroka:
  for each gds-list
  break
  by gds-list.gds-code
  On error undo _stroka, next _stroka
  :
    assign
    v-current-gds-code = gds-list.gds-code
    v-current-artic = gds-list.artic
    v-current-prod-type = gds-list.prod-type
    v-current-prod-code = gds-list.prod-code
    num-rec = num-rec + 1
    v-is-global = no
    .
    for each temp-goods-attr :
      delete temp-goods-attr.
    end.

    /* ------------------------- &start-rule& -----------------------------------*/
    IF num-rec = 1
    or num-rec modulo p-pck-num-rec = 1
    THEN do:
      IF  ExpData1:route-data_read-xmlschema( INPUT p-xsd-file) = false  THEN do:
        undo _main, return error v-last-error-message .
      end.
    end.
    if p-save >= 0 then do:
      find first buf_goods exclusive-lock where
                buf_goods.gds-code = gds-list.gds-code no-error.
    end.
    else do:
      find first buf_goods no-lock where
                buf_goods.gds-code = gds-list.gds-code no-error.
    end.
    if not available buf_goods then do:
      &scop my-message substitute("Не найден содержащийся в списке товар с кодом &1", gds-list.gds-code)
      {&display-message}.
      next _stroka.
    end.
    find first buf_clients no-lock where
              buf_clients.obj-type = buf_goods.prod-type
          and buf_clients.obj-code = buf_goods.prod-code no-error.
    if not available buf_clients then do:
      &scop my-message substitute("Для товара с кодом &1 не найден производитель &2&3" ~
                                  , gds-list.gds-code ~
                                  , buf_goods.prod-type ~
                                  , buf_goods.prod-code)
      {&display-message}.
      next _stroka.
    end.
    find first buf_gds-prt no-lock WHERE
              buf_gds-prt.upper-code = buf_goods.prt-root NO-error.
    if not available buf_gds-prt then do:
      &scop my-message substitute("Для товара с кодом &1 не найден корень ШКАЛЫ ПРИЗНАКОВ с кодом &2" ~
                                  , gds-list.gds-code ~
                                  , buf_goods.prt-root ~
                                  )
      {&display-message}.
      next _stroka.
    end.
    if buf_goods.fbr-grp-code <> ?
    and buf_goods.fbr-grp-code <> 0 then do:
      find first buf_fbr-gds-grp no-lock where
              buf_fbr-gds-grp.obj-type = "":U
          AND buf_fbr-gds-grp.obj-code = 0
          AND buf_fbr-gds-grp.node-code = buf_goods.fbr-grp-code no-error .
      if not available buf_fbr-gds-grp then do:
        &scop my-message substitute("Для товара с кодом &1 не найдена группа блюд &2" ~
                                    , gds-list.gds-code ~
                                    , buf_goods.fbr-grp-code)
        {&display-message}.
        next _stroka.
      end.
      create buf_temp-fbr-gds-grp.
      buffer-copy buf_fbr-gds-grp to buf_temp-fbr-gds-grp.
      run fbrglib-get-full-name in this-procedure (
                                                     input ''
                                                    ,input 0
                                                    ,input buf_goods.fbr-grp-code
                                                    ,output buf_temp-fbr-gds-grp.f-name).
    end.
    if p-save >= 0 then do:
      Find first locked_goods-attr exclusive-lock  where
              locked_goods-attr.gds-code = v-current-gds-code
          and locked_goods-attr.attr-code = {&attr-gds-attr-lock}
          no-error no-wait.
      if not available locked_goods-attr
      and not locked locked_goods-attr then do:
        create locked_goods-attr.
        assign
        locked_goods-attr.gds-code =  v-current-gds-code
        locked_goods-attr.attr-code = {&attr-gds-attr-lock}
        .
      end.
      if locked locked_goods-attr then do:
        Find first locked_goods-attr exclusive-lock  where
              locked_goods-attr.gds-code = v-current-gds-code
          and locked_goods-attr.attr-code = {&attr-gds-attr-lock}
          no-error .
      end.
    end.
    v-attr-list = {&attr-alcohol-prod} + {&delim-par} +
                  {&attr-fasovka} + {&delim-par} +
                  {&attr-15x80} + {&delim-par}  +
                  {&attr-8x50} + {&delim-par} +
                  {&attr-6x50} .
    do v-ii = 1 to num-entries(v-attr-list, {&delim-par}):
      create temp-goods-attr.
      assign
      temp-goods-attr.gds-code = v-current-gds-code
      temp-goods-attr.attr-code  = entry(v-ii, v-attr-list, {&delim-par})
      .
      run gds-attr-copy-to  in this-procedure (
                                              input  v-current-gds-code
                                              ,input  entry(v-ii, v-attr-list, {&delim-par})
                                              ,input (buffer temp-goods-attr:handle)
                                              ) no-error.
    end.
    empty temp-table tt-tax.
    run ref/dtaxgdss.p (
                  input yes
                 ,input buf_goods.unit-base
                 ,input buf_goods.grp-code
                 ,input recid(buf_goods)
                 ,input recid(buf_goods)
                 ,input 0 /*p-hostcode*/
                 ,input '' /*p-obj-type*/
                 ,input 0 /*p-obj-code*/
                  ) no-error.
    if error-status:error then do:
        &scop my-message return-value
        {&display-message}.
        next _stroka.
    end.

    ExpData1:route-data_create-record( INPUT "goods-01") .
    ExpData1:route-data_copy-record( INPUT "goods-01", INPUT  (buffer buf_goods:handle) ) .
    for each temp-goods-attr:
      ExpData1:route-data_copy-field( INPUT "goods-01"
                                     , INPUT ("attr-" + temp-goods-attr.attr-code)
                                     , INPUT (buffer temp-goods-attr:handle:buffer-field("attr-value")) ) .
    end.
    ExpData1:route-data_copy-field( INPUT "goods-01"
                                    , INPUT "prod-name"
                                    , INPUT (buffer buf_clients:handle:buffer-field("obj-name")) ) .
    ExpData1:route-data_copy-field( INPUT "goods-01"
                                    , INPUT "fbr-grp-name"
                                    , INPUT (buffer buf_temp-fbr-gds-grp:handle:buffer-field("f-name")) ) .
    if available buf_temp-fbr-gds-grp then
    delete buf_temp-fbr-gds-grp.
    ExpData1:route-data_copy-field( INPUT "goods-01"
                                    , INPUT "prt-root-name"
                                    , INPUT (buffer buf_gds-prt:handle:buffer-field("node-name")) ) .
    find first tt-tax no-lock where
              tt-tax.tax-code = integer({&vat-tax-code}).
    ExpData1:route-data_copy-field( INPUT "goods-01"
                                    , INPUT "vat-pc"
                                    , INPUT (buffer tt-tax:buffer-field("rate-value")) ) .
    find first buf_alc-type-gds where buf_alc-type-gds.gds-code = buf_goods.gds-code and
                                      buf_alc-type-gds.create-user-db-num = v-current-db-num no-lock no-error.
    if available buf_alc-type-gds then
    ExpData1:route-data_copy-field( INPUT "goods-01"
                                    , INPUT "alc-type-code"
                                    , INPUT (buffer buf_alc-type-gds:buffer-field("alc-type-inner-code")) ) .

    _bar-code:
    for each buf_bar-code share-lock where
            buf_bar-code.gds-code = v-current-gds-code
    on error  undo _stroka, next _stroka
    on stop   undo _stroka, next _stroka
    on endkey undo _stroka, next _stroka
    :

      if buf_bar-code.in-code <> '':U
      or buf_bar-code.part-code <> '':U then next _bar-code.
      find first buf_gds-prt no-lock where
                buf_gds-prt.node-code = buf_bar-code.node-code no-error.
      if not available buf_gds-prt then do:
        &scop my-message substitute("Для товара с кодом &1 не найден узел ШКАЛЫ ПРИЗНАКОВ с кодом &2" ~
                                    , gds-list.gds-code ~
                                    , buf_bar-code.node-code ~
                                    )
        {&display-message}.
        next _stroka.
      end.
      ExpData1:route-data_create-record( INPUT "bar-code-01") .
      ExpData1:route-data_copy-record( INPUT "bar-code-01", INPUT  (buffer buf_bar-code:handle) ) .
      ExpData1:route-data_copy-field( INPUT "bar-code-01"
                                      , INPUT "node-name"
                                      , INPUT (buffer buf_gds-prt:handle:buffer-field("f-name")) ) .

      _prod-bc:
      for each buf_prod-bc share-lock where
              buf_prod-bc.b-code = buf_bar-code.b-code
      on error  undo _stroka, next _stroka
      on stop   undo _stroka, next _stroka
      on endkey undo _stroka, next _stroka
      :
        /*проверим что это не лок код */
        { gbl/prodbcat.i buf_prod-bc "'global=request':U " v-is-global no-error }
        { gbl/prodbcat.i buf_prod-bc "'weight=request':U " v-is-weight  no-error }
        { gbl/prodbcat.i buf_prod-bc "'petrolium=request':U " v-is-petrolium  no-error }
        { gbl/prodbcat.i buf_prod-bc "'scaleable=request':U " v-is-scaleable  no-error }
        if not v-is-global
        or v-is-scaleable
        or v-is-petrolium
        or v-is-weight
        then next _prod-bc.
        ExpData1:route-data_create-record( INPUT "prod-bc-01") .
        ExpData1:route-data_copy-record( INPUT "prod-bc-01", INPUT  (buffer buf_prod-bc:handle) ) .
      end.
    end.

    _gds-obj-prop:
    for each buf_gds-obj-prop share-lock where
             buf_gds-obj-prop.gds-code = v-current-gds-code
    on error  undo _stroka, next _stroka
    on stop   undo _stroka, next _stroka
    on endkey undo _stroka, next _stroka
    :
        ExpData1:route-data_create-record( INPUT "gds-obj-prop") .
        ExpData1:route-data_copy-record( INPUT "gds-obj-prop", INPUT  (buffer buf_gds-obj-prop:handle) ) .
    end.

    /* ------------------------- &end-rule& -------------------------------------*/

    /* ------------------------- &start-release-obj& -----------------------------------*/

    /* ------------------------- &end-release-obj& -------------------------------------*/

    num-rec-ok = num-rec-ok + 1.
    run write-counter in p-log-handle ( input substitute("Обработано товаров списка: &1, из них удачно: &2", num-rec, num-rec-ok)).
    run get-stop-state in p-log-handle ( output v-stop) no-error .
    if v-stop then do:
        run write-log-and-file in p-log-handle (
                                                input 1
                                              , input log-file-name
                                              , input 1
                                              , input substitute("Процесс прерван пользователем")).
        leave _stroka.
    end.
    if last( gds-list.gds-code)
    or num-rec modulo p-pck-num-rec = 0
    then do:
      /*записать файл*/
      if not ExpData1:write-xml(v-loc-file-name, integer(trunc(num-rec / p-pck-num-rec, 0))) then do:
        undo _main, return error .
      end.
      v-loc-file-name = rum-fn_get-next-file-name ( file-name , integer(trunc(num-rec / p-pck-num-rec, 0))).
      &scop release_1 clear-data ( )
      ExpData1:Route-data_{&release_1} .
    end.
  end. /*for each gds-list where*/
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Обработано товаров списка: &1, из них удачно: &2", num-rec, num-rec-ok)).
  ExpData1:route-data_clear-xmlschema ( ).

end. /*doe _main*/
end procedure. /* proc-main */

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.

  do
  on error undo, return error
  :
/*---------------------------&start-process-rule-call-param&-------------------------------*/
  find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-xsd-file"
 no-error.
if available buf_rule-call-param then do:
assign p-xsd-file = buf_rule-call-param.param-value-character.
end.

 find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-pck-num-rec"
 no-error.
if available buf_rule-call-param then do:
assign p-pck-num-rec = buf_rule-call-param.param-value-integer.
end.



/*---------------------------&end-process-rule-call-param&-------------------------------*/
    case p-ruleset-id:
      when 1 then do:
        assign
        v-sign = 1
        v-current-host-code = p-host-code
        v-current-obj-type = p-obj-type
        v-current-obj-code = p-obj-code
        v-current-db-num = g#db-num
        v-current-lock = (if p-save >= 0 then exclusive-lock else no-lock)
        file-name  = p-process-file-name
        .
      end.
    end case.
  end. /*doe*/

end procedure. /* load-ruleset-context */

/*не удалять!!!!*/