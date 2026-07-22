/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 11, набор 2

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/12/09
Author: Bakhtadze Natalya
Creation date: 10/12/09

---------------------------&start-codex_id=11;ruleset_id=2;-------------------------------
---------------------------&end-codex_id=11;ruleset_id=2;-------------------------------

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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 11, набор 2".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/garbcoll.i }
{ rul/ruleset_.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }
{ gbl/gate-clb.i }
{ gbl/key-rec.i }
{ bge/tmpcxmlh.i }
{ gbl/lib-gate.i }
{ cmp/gds-list.i gds-list def "shared" }
{ ref/extclass.i }
{ rul/dtlpbcod.i }

&scop display-message ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~)


/*переменные контекста*/
/*это у нас объект 0*/
define variable v-current-gds-code  as integer   no-undo .
define variable v-current-artic     as character no-undo .
define variable v-current-prod-type as character no-undo .
define variable v-current-prod-code as integer   no-undo .
define variable v-current-host-code as integer   no-undo .
define variable v-current-obj-type  as character no-undo .
define variable v-current-obj-code  as integer   no-undo .
define variable v-current-doc-code  as character no-undo .
define variable v-esys-cmd-proc-handle as handle no-undo .
define variable v-esys-cmd-code     as integer   no-undo .
define variable log-file-name       as character no-undo init "process-gds.txt".
define variable v-view-log          as logical   no-undo .
define variable v-stop              as logical   no-undo .
define variable v-last-error-message as character no-undo .
/*****************************/
define variable file-name      as character no-undo.
define variable v-sign         as integer   no-undo .
define variable v-gate-rec     as character no-undo .
define variable num-rec        as integer   no-undo .
define variable num-rec-ok     as integer   no-undo .
define variable l-res          as integer   no-undo .
define variable v-es           as logical   no-undo .
define variable v-esm          as character no-undo .
define variable v-rv           as character no-undo .
define variable v-esys-id-list as character no-undo .
define variable v-err-mess     as character no-undo .
define temp-table temp-rule-call-param no-undo like ub.rule-call-param.
define variable v-action       as character no-undo .


{ str/dia2auto.i }
{ rul/seterror.i }

&scop display-message ~
          if valid-handle(p-log-handle) then ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~)




/*---------------------------&start-rule-call-param&-------------------------------*/

  define variable p-xsd-file as character no-undo.

/*---------------------------&end-rule-call-param&-------------------------------*/


/* ------------------------- &start-i-script& -----------------------------------*/

 { rul/context_f.i  begin-esys-command }
 { rul/context_f.i  send-esys-command }
 { rul/context_f.i  delete-command }



/* ------------------------- &end-i-script& -----------------------------------*/

on delete of this-procedure do:
  run garbcoll_clear in this-procedure .
end.
run load-ruleset-context in this-procedure ( input p-ruleset-id) no-error.
if error-status:error then do:
  undo, return error return-value .
end.
if return-value = "return" then return ''.

/* ------------------------- &start-def-vars& -----------------------------------*/

define variable ExpData1 as class Route-data_ no-undo .
{ gbl/gaterout.i
  parparentproc
  p-parent-handle
  p-log-handle
  this-procedure:handle
  ExpData1
}



/* ------------------------- &end-def-vars& -----------------------------------*/

if not this-procedure:persistent then do:
  run proc-main in this-procedure no-error .
  if error-status:error then do:
    v-esm = error-status :get-message (1).
    v-es = error-status:error .
    v-rv = return-value .
  end.
  if v-es then do:
      run garbcoll_clear in this-procedure .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, v-rv, {&new-line}, v-esm).
  end.
  run garbcoll_clear in this-procedure .
end.

procedure proc-main :

_main:
do
on error undo, return error substitute( "&1&2&3&2&4", return-value, {&new-line}, error-status :get-message (1), v-last-error-message)
:

define variable v-err               as logical   no-undo .
define variable v-pck-num-rec       as integer   no-undo init 1000.
define variable v-gds-name          as character no-undo .
define variable v-gds-name-full     as character no-undo .
define variable v-node-name         as character no-undo .
define variable v-unit-cli-name     as character no-undo .
define variable v-main-b-code       as integer   no-undo .
define variable v-empty-scale-node  as integer   no-undo .
define variable v-obj-type-code     as integer   no-undo .
define variable v-price-sale        as decimal   no-undo .
define variable v-doc-num           as character no-undo .
define variable for-road            as decimal   no-undo .
define variable for-excise          as decimal   no-undo .
define variable v-obj-db-num        as integer   no-undo .
define variable v-obj-uniq-key-rec  as character no-undo .
define variable v-goods-dump-ord    as logical   no-undo .
define variable v-barcodes-dump-ord as logical   no-undo .
define variable v-smprices-dump-ord as logical   no-undo .
define variable v-counts-dump-ord   as logical   no-undo .
define variable varscales-pref      as character no-undo .
define variable varpgscales-pref    as character no-undo .
define variable v-ii                as integer   no-undo .
define variable v-b-str-list        as character no-undo .
define variable l-prod-bc-weight    as logical   no-undo .
define variable l-prod-bc-pgweight  as logical   no-undo .
define variable v-need-part-b-code  as logical   no-undo .
define variable v-producer          as character no-undo .


define buffer buf_bar-code      for ub.bar-code.
define buffer buf_gds-prt       for ub.gds-prt.
define buffer buf2_gds-prt      for ub.gds-prt.
define buffer buf_goods         for ub.goods.
define buffer buf_prod-bc       for ub.prod-bc.
define buffer buf_main-bar-code for ub.bar-code.
define buffer buf_clients       for ub.clients.
define buffer buf_ext-classif   for ub.ext-classif.
define buffer buf_gds-obj       for ub.gds-obj.


/* ------------------------- &end-hn-option& -----------------------------------*/
  /* ------------------------- &start-rule& -----------------------------------*/
  IF  ExpData1:route-data_push-xmlschema( INPUT p-xsd-file ) = false  THEN do:
    &scop my-message substitute("Ошибка при создании гейта &1 для маршрутизации:&2&3&2&4" ~
                                , p-xsd-file ~
                                , ~{&new-line~} ~
                                , error-status:get-message(1) ~
                                , v-last-error-message)
    {&display-message}.
    undo _main, return error '' .
  end.
  { str/sclspref.i varscales-pref varpgscales-pref }
  _stroka:
  for each gds-list
  break
  by gds-list.gds-code
  On error undo _stroka, next _stroka
  On stop undo _stroka, next _stroka
  :
    /*Мы посылаем каждый баркод как отдельный товар в силу того что для "расширенной" схемы работы с ценами в ДКLink
    когда можно назначить отдельные цены по каждому объекту
    цена назначается как бы на товар
    сделаем их как бы товар = наш баркод
    */
    assign
    v-current-gds-code = gds-list.gds-code
    v-current-artic = gds-list.artic
    v-current-prod-type = gds-list.prod-type
    v-current-prod-code = gds-list.prod-code
    v-gds-name = gds-list.gds-name
    num-rec = num-rec + 1
    .
    /* ------------------------- &start-rule& -----------------------------------*/
    IF num-rec = 1
    or num-rec modulo v-pck-num-rec = 1
    THEN do:
      IF  context_begin-esys-command( input v-esys-id-list
                                    , input-output v-esys-cmd-proc-handle
                                    , output v-esys-cmd-code) = false  THEN do:
        &scop my-message substitute("Ошибка при инициации маршрутизации через гейт &1&2:&3&2&4" ~
                                     ,p-xsd-file ~
                                     , ~{&new-line~} ~
                                     , error-status:get-message(1)  ~
                                     , v-last-error-message)
        {&display-message}.
        undo _main, return error ''.
      end.
      assign
      v-goods-dump-ord = no
      v-barcodes-dump-ord = no
      v-smprices-dump-ord = no
      v-counts-dump-ord = no
      .
    end.
    find first buf_goods exclusive-lock where
              buf_goods.gds-code = gds-list.gds-code no-error.
    if not available buf_goods then do:
      &scop my-message substitute("Не найден содержащийся в списке товар с кодом &1", gds-list.gds-code)
      {&display-message}.
      next _stroka.
    end.
    { gbl/gdsbcode.i
      v-current-gds-code
      ?
      v-main-b-code
    }

    assign
      v-action = if buf_goods.stts = 0 then {&gen-line-update} else {&gen-line-delete}
    .
    assign
      v-producer = ""
    .
    find first buf_clients no-lock
          where buf_clients.obj-code = buf_goods.prod-code
            and buf_clients.obj-type = buf_goods.prod-type
            and buf_clients.is-prod  = yes
            no-error.
            if available buf_clients then do:
              assign
                v-producer = buf_clients.obj-name
              .
            end.

    ExpData1:route-data_create-record( INPUT "goods") .
    if v-goods-dump-ord =  no then do:
      IF ExpData1:esys-add-dump( INPUT "goods", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '_dump-order=Rec_ID') = false  THEN do:
        &scop my-message substitute("Ошибка при маршрутизации записи по товару с кодом  &1:&2&3" ~
                                , v-current-gds-code ~
                                , ~{&new-line~} ~
                                , v-last-error-message ~
                                )
        {&display-message}.
        undo _main, return error '' .
      end.
      v-goods-dump-ord = yes.
    end.
    ExpData1:route-data_copy-field( INPUT "goods", "ID", INPUT  buffer buf_goods:handle:buffer-field("gds-code") ) .
    ExpData1:route-data_copy-field( INPUT "goods", "Name", INPUT  buffer buf_goods:handle:buffer-field("gds-name")).
    ExpData1:route-data_copy-field( INPUT "goods", "Baseunit", INPUT  buffer buf_goods:handle:buffer-field("unit-base") ) .
    ExpData1:route-data_copy-field( INPUT "goods", "CountryID", INPUT  buffer buf_goods:handle:buffer-field("alpha1") ) .
    ExpData1:route-data_copy-field-decimal( INPUT "goods", "Baseprice", INPUT  0.0 ) .
    ExpData1:route-data_copy-field-character( INPUT "goods", "Action", INPUT  v-action ) .
    ExpData1:route-data_copy-field-character( INPUT "goods", "Producer", INPUT  v-producer ) .
    IF ExpData1:esys-add-dump( INPUT "goods", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
      &scop my-message  substitute("Ошибка при маршрутизации записи товара с кодом &1:&2&3" ~
                              , v-current-gds-code ~
                              , ~{&new-line~} ~
                              , v-last-error-message ~
                              )
      {&display-message}.
      undo _main, return error '' .
    end.
    _bar-code:
    for each buf_bar-code no-lock where
          buf_bar-code.gds-code = v-current-gds-code
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
    :
      find first buf2_gds-prt no-lock where
                buf2_gds-prt.node-code = buf_bar-code.node-code no-error.
      if error-status:error then do:
        &scop my-message substitute("Неизвестный код признака &1 у баркода &1 товар &3" ~
                                , buf_bar-code.node-code ~
                                , buf_bar-code.b-code ~
                                , buf_bar-code.gds-code ~
                                )
        {&display-message}.
        undo _stroka, next _stroka .
      end.
      if not (buf2_gds-prt.root = yes
      or buf2_gds-prt.is-term = yes) then do:
        next _bar-code.
      end.
      assign
      v-node-name = buf2_gds-prt.f-name.

      if buf_bar-code.in-code <> '' then do:
        v-need-part-b-code = no.
        run dtlpbcod_need-part-b-code in this-procedure ( input buf_bar-code.gds-code
                                               , input v-esys-id-list
                                               , output v-need-part-b-code
                                             ) no-error.
        if v-need-part-b-code = no then next _bar-code.
      end.
      ExpData1:route-data_create-record( INPUT "barcodes") .
      if v-barcodes-dump-ord = no then do:
        IF ExpData1:esys-add-dump( INPUT "barcodes", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '_dump-order=Rec_ID') = false  THEN do:
          &scop my-message substitute("Ошибка при маршрутизации записи по товару с кодом  &1, баркод &2:&3&4" ~
                                  , v-current-gds-code ~
                                  , buf_bar-code.b-code ~
                                  , ~{&new-line~} ~
                                  , v-last-error-message ~
                                  )
          {&display-message}.
          undo _main, return error '' .
        end.
        v-barcodes-dump-ord = yes.
      end.
      ExpData1:route-data_copy-field( INPUT "barcodes", "BC", INPUT  buffer buf_bar-code:handle:buffer-field("b-code")) .
      /*у нас один баркод - один товар!!!*/
      ExpData1:route-data_copy-field( INPUT "barcodes", "GoodsID", INPUT  buffer buf_bar-code:handle:buffer-field("gds-code") ) .
      ExpData1:route-data_copy-field-decimal( INPUT "barcodes", "Price", INPUT  0 ) .
      ExpData1:route-data_copy-field( INPUT "barcodes", "Unit", INPUT  buffer buf_bar-code:handle:buffer-field("unit-cli") ) .
      ExpData1:route-data_copy-field( INPUT "barcodes", "CUnit", INPUT buffer  buf_bar-code:handle:buffer-field("cli-base-rate") ) .
      ExpData1:route-data_copy-field-character( INPUT "barcodes", "Action", INPUT  {&gen-line-update} ) .
      ExpData1:route-data_copy-field-character( INPUT "barcodes", "NodeName", INPUT  v-node-name ) .
      IF ExpData1:esys-add-dump( INPUT "barcodes", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
        &scop my-message  substitute("Ошибка при маршрутизации записи баркода/ДопБК с кодом &1:&2&3" ~
                                , buf_bar-code.b-code ~
                                , ~{&new-line~} ~
                                , v-last-error-message ~
                                )
        {&display-message}.
        undo _main, return error '' .
      end.
      _prod-bc:
      for each buf_prod-bc no-lock where
              buf_prod-bc.b-code = buf_bar-code.b-code
      on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
      on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
      :
        if buf_prod-bc.bc-on = no then next.
        assign
        l-prod-bc-weight = no
        l-prod-bc-pgweight = no
        .
        if length(buf_prod-bc.b-str) <= 5 then do: /*облегченная проверка
        только в этом случае будем запускать громоздкую процедуру определения типа кода*/
          v-b-str-list = buf_prod-bc.b-str.
          { gbl/prodbcat.i
            buf_prod-bc
            "'weight=request':u"
            l-prod-bc-weight
            no-error
          }
          if not l-prod-bc-weight then do:
            { gbl/prodbcat.i
              buf_prod-bc
              "'pgweight=request':u"
              l-prod-bc-pgweight
              no-error
            }
          end.
          if l-prod-bc-weight then do:
            do v-ii = 1 to num-entries(varscales-pref):
              assign
              v-b-str-list = v-b-str-list +
                            (if v-b-str-list = '' then '' else {&comma-char}) +
                            entry(v-ii, varscales-pref) + buf_prod-bc.b-str.

            end.
          end.
          if l-prod-bc-pgweight then do:
            /*не могут принять штучные*/
            next _prod-bc.
          end.
        end.
        else do:
          v-b-str-list = buf_prod-bc.b-str.
        end.
        do v-ii = 1 to num-entries (v-b-str-list):
          ExpData1:route-data_create-record( INPUT "barcodes") .
          if v-barcodes-dump-ord = no then do:
            IF ExpData1:esys-add-dump( INPUT "barcodes", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '_dump-order=Rec_ID') = false  THEN do:
              &scop my-message substitute("Ошибка при маршрутизации записи баркода/ДопБК с кодом  &1:&2&3" ~
                                      , buf_bar-code.b-code ~
                                      , ~{&new-line~} ~
                                      , v-last-error-message ~
                                      )
              {&display-message}.
              undo _main, return error '' .
            end.
            v-barcodes-dump-ord = yes.
          end.
          ExpData1:route-data_copy-field-character( INPUT "barcodes", "BC", INPUT  entry(v-ii, v-b-str-list )) .
          /*у нас один баркод - один товар!!!*/
          ExpData1:route-data_copy-field( INPUT "barcodes", "GoodsID", INPUT buffer buf_goods:handle:buffer-field("gds-code") ) .
          ExpData1:route-data_copy-field-decimal( INPUT "barcodes", "Price", INPUT  0 ) .
          ExpData1:route-data_copy-field( INPUT "barcodes", "Unit", INPUT buffer buf_bar-code:handle:buffer-field("unit-cli") ) .
          ExpData1:route-data_copy-field( INPUT "barcodes", "CUnit", INPUT buffer  buf_bar-code:handle:buffer-field("cli-base-rate") ) .
          ExpData1:route-data_copy-field-character( INPUT "barcodes", "Action", INPUT  {&gen-line-update} ) .
          ExpData1:route-data_copy-field-character( INPUT "barcodes", "NodeName", INPUT  v-node-name ) .
          IF ExpData1:esys-add-dump( INPUT "barcodes", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
            &scop my-message substitute("Ошибка при маршрутизации записи баркода/ДопБК с кодом &1:&2&3" ~
                                    , buf_bar-code.b-code ~
                                    , ~{&new-line~} ~
                                    , v-last-error-message ~
                                    )
            {&display-message}.
            undo _main, return error '' .
          end.
        end.
      end. /*for each buf_prod-bc no-lock where*/
      _clients:
      for each buf_clients no-lock where
              buf_clients.db-num = g#db-num
      on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
      on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
      :

        if buf_clients.obj-type = {&shop}
        or buf_clients.obj-type = {&stock} then do:
          run gen-key-rec in this-procedure ( input {&table_clients}
                                            ,input buffer buf_clients:handle
                                            ,output v-obj-uniq-key-rec).
          find first buf_ext-classif no-lock where
              buf_ext-classif.classif-name = {&extclass_clients_esys}
          and buf_ext-classif.classif-subject = {&table_clients}
          and buf_ext-classif.db-num = 0
          and buf_Ext-classif.uniq-key-rec = v-obj-uniq-key-rec
          and lookup(string(buf_ext-classif.key#_one), v-esys-id-list, {&delim-nws}) > 0 no-error.
          if not available buf_ext-classif then next _clients.

          v-obj-type-code = (if buf_clients.obj-type = {&stock} then 100000 else 0) + buf_clients.obj-code.
          v-price-sale = ?.
        { gbl/bcodeprc.i
          buf_clients.obj-type
          buf_clients.obj-code
          buf_bar-code.b-code
          v-main-b-code
          0
          v-doc-num
          v-price-sale
          for-road
          for-excise
          no-error
        }
          if error-status:error
          or v-price-sale = ? then next.
          if buf_bar-code.b-code = v-main-b-code
          or v-need-part-b-code
          then do:
            ExpData1:route-data_create-record( INPUT "smprices") .
            if v-smprices-dump-ord = no then do:
              IF ExpData1:esys-add-dump( INPUT "smprices", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '_dump-order=Rec_ID') = false  THEN do:
                v-err-mess = substitute("Ошибка при маршрутизации цен для кода &1:&2&3"
                                        , buf_bar-code.b-code
                                        , {&new-line}
                                        , v-last-error-message
                                        ).
                undo _main, return error ''.
              end.
              v-smprices-dump-ord = yes.
            end.
            ExpData1:route-data_copy-field-character( INPUT "smprices", "REC_ID", INPUT  string(v-obj-type-code)) .
            ExpData1:route-data_copy-field( INPUT "smprices", "GoodsID", INPUT  buffer buf_goods:buffer-field("gds-code") ) .
            ExpData1:route-data_copy-field-character( INPUT "smprices", "BC", INPUT '') .
            ExpData1:route-data_copy-field-integer( INPUT "smprices", "PriceID", INPUT  v-obj-type-code ) .
            ExpData1:route-data_copy-field-character( INPUT "smprices", "Action", INPUT  {&gen-line-update}) .
            ExpData1:route-data_copy-field-decimal( INPUT "smprices", "Price", INPUT  v-price-sale ) .
            IF ExpData1:esys-add-dump( INPUT "smprices", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
              v-err-mess = substitute("Ошибка при маршрутизации цен для кода &1:&2&3"
                                      , buf_bar-code.b-code
                                      , {&new-line}
                                      , v-last-error-message
                                      ).
              undo _main, return error ''.
            end.
            find first buf_gds-obj no-lock where
                      buf_gds-obj.obj-type =  buf_clients.obj-type
                  and buf_gds-obj.obj-code =  buf_clients.obj-code
                  and buf_gds-obj.gds-code =  buf_bar-code.gds-code no-error.
            ExpData1:route-data_create-record( INPUT "counts") .
            if v-counts-dump-ord = no then do:
              IF ExpData1:esys-add-dump( INPUT "counts", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '_dump-order=Rec_ID') = false  THEN do:
                v-err-mess = substitute("Ошибка при маршрутизации остатков для товара &1:&2&3"
                                        , buf_bar-code.gds-code
                                        , {&new-line}
                                        , v-last-error-message
                                        ).
                undo _main, return error ''.
              end.
              v-counts-dump-ord = yes.
            end.
            ExpData1:route-data_copy-field-character( INPUT "counts", "REC_ID", INPUT  string(v-obj-type-code)) .
            ExpData1:route-data_copy-field( INPUT "counts", "GoodsID", INPUT  buffer buf_goods:buffer-field("gds-code") ) .
            ExpData1:route-data_copy-field-character( INPUT "counts", "Action", INPUT  {&gen-line-update}) .
            ExpData1:route-data_copy-field-integer( INPUT "counts", "storeid", v-obj-type-code) .
            ExpData1:route-data_copy-field-decimal( INPUT "counts", "counts", INPUT  (if available buf_gds-obj then buf_gds-obj.fact-qnty else 0) ) .
            ExpData1:route-data_copy-field-decimal( INPUT "counts", "reserve", INPUT  if available buf_gds-obj then (buf_gds-obj.fact-qnty - buf_gds-obj.free-qnty) else 0) .
            IF ExpData1:esys-add-dump( INPUT "counts", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
              v-err-mess = substitute("Ошибка при маршрутизации остатков для товара &1:&2&3"
                                      , buf_bar-code.gds-code
                                      , {&new-line}
                                      , v-last-error-message
                                      ).
              undo _main, return error ''.
            end.
          end. /*if buf_bar-code.b-code = v-main-b-code then do:*/
          ExpData1:route-data_create-record( INPUT "smprices") .
          if v-smprices-dump-ord = no then do:
            IF ExpData1:esys-add-dump( INPUT "smprices", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '_dump-order=Rec_ID') = false  THEN do:
              v-err-mess = substitute("Ошибка при маршрутизации цен для кода &1:&2&3"
                                      , buf_bar-code.b-code
                                      , {&new-line}
                                      , v-last-error-message
                                      ).
              undo _main, return error ''.
            end.
            v-smprices-dump-ord = yes.
          end.
          ExpData1:route-data_copy-field-character( INPUT "smprices", "REC_ID", INPUT  string(v-obj-type-code)) .
          ExpData1:route-data_copy-field( INPUT "smprices", "GoodsID", INPUT  buffer buf_goods:buffer-field("gds-code") ) .
          ExpData1:route-data_copy-field-character( INPUT "smprices", "BC", INPUT string(buf_bar-code.b-code) ) .
          ExpData1:route-data_copy-field-integer( INPUT "smprices", "PriceID", INPUT  v-obj-type-code ) .
          ExpData1:route-data_copy-field-character( INPUT "smprices", "Action", INPUT  {&gen-line-update}) .
          ExpData1:route-data_copy-field-decimal( INPUT "smprices", "Price", INPUT  v-price-sale ) .
          IF ExpData1:esys-add-dump( INPUT "smprices", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
            v-err-mess = substitute("Ошибка при маршрутизации цен для кода &1:&2&3"
                                    , buf_bar-code.b-code
                                    , {&new-line}
                                    , v-last-error-message
                                    ).
            undo _main, return error ''.
          end.
          _prod-bc:
          for each buf_prod-bc no-lock where
                  buf_prod-bc.b-code = buf_bar-code.b-code
          on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
          on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
          on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
          :
            if buf_prod-bc.bc-on = no then next.
            assign
            l-prod-bc-weight = no
            l-prod-bc-pgweight = no
            .
            if length(buf_prod-bc.b-str) <= 5 then do: /*облегченная проверка
            только в этом случае будем запускать громоздкую процедуру определения типа кода*/
              v-b-str-list = buf_prod-bc.b-str.
              { gbl/prodbcat.i
                buf_prod-bc
                "'weight=request':u"
                l-prod-bc-weight
                no-error
              }
              if not l-prod-bc-weight then do:
                { gbl/prodbcat.i
                  buf_prod-bc
                  "'pgweight=request':u"
                  l-prod-bc-pgweight
                  no-error
                }
              end.
              if l-prod-bc-weight then do:
                do v-ii = 1 to num-entries(varscales-pref):
                  assign
                  v-b-str-list = v-b-str-list +
                                (if v-b-str-list = '' then '' else {&comma-char}) +
                                entry(v-ii, varscales-pref) + buf_prod-bc.b-str.

                end.
              end.
              if l-prod-bc-pgweight then do:
                /*не могут принять штучные*/
                next _prod-bc.
              end.
            end.
            else do:
              v-b-str-list = buf_prod-bc.b-str.
            end.
            do v-ii = 1 to num-entries (v-b-str-list):
              ExpData1:route-data_create-record( INPUT "smprices") .
              if v-smprices-dump-ord = no then do:
                IF ExpData1:esys-add-dump( INPUT "smprices", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '_dump-order=Rec_ID') = false  THEN do:
                  v-err-mess = substitute("Ошибка при маршрутизации цен для кода &1:&2&3"
                                          , buf_bar-code.b-code
                                          , {&new-line}
                                          , v-last-error-message
                                          ).
                  undo _main, return error ''.
                end.
                v-smprices-dump-ord = yes.
              end.
              ExpData1:route-data_copy-field-character( INPUT "smprices", "REC_ID", INPUT  string(v-obj-type-code)) .
              ExpData1:route-data_copy-field( INPUT "smprices", "GoodsID", INPUT  buffer buf_goods:buffer-field("gds-code") ) .
              ExpData1:route-data_copy-field-character( INPUT "smprices", "BC", INPUT  entry(v-ii, v-b-str-list)) .
              ExpData1:route-data_copy-field-integer( INPUT "smprices", "PriceID", INPUT  v-obj-type-code ) .
              ExpData1:route-data_copy-field-character( INPUT "smprices", "Action", INPUT  {&gen-line-update}) .
              ExpData1:route-data_copy-field-decimal( INPUT "smprices", "Price", INPUT  v-price-sale ) .
              IF ExpData1:esys-add-dump( INPUT "smprices", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
                v-err-mess = substitute("Ошибка при маршрутизации цен для кода &1 ДопБК &2:&3&4"
                                        , buf_bar-code.b-code
                                        , buf_prod-bc.b-str
                                        , {&new-line}
                                        , v-last-error-message
                                        ).
                undo _main, return error ''.
              end.
            end. /*            do v-ii = 1 to num-entries (v-b-str-list):*/
          end. /*for each buf_prod-bc no-lock where*/
        end. /*if buf_clients.obj-type = {&shop}*/
      end. /*for each buf_clients*/
    end. /*    for each buf_bar-code no-lock where*/


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
    or num-rec modulo v-pck-num-rec = 0
    then do:
      IF  context_send-esys-command( input v-esys-id-list, input v-esys-cmd-proc-handle, input v-esys-cmd-code, input g#userid) = false  THEN do:
        undo _main, return error v-last-error-message .
      end.
      &scop release_1 clear-data ( )
      ExpData1:Route-data_{&release_1} .
    end.
  end. /*for each gds-list where*/

  /* ------------------------- &end-rule& -------------------------------------*/

  /* ------------------------- &start-release-obj& -----------------------------------*/


  /* ------------------------- &end-release-obj& -------------------------------------*/

  /*нет удаления схемы!!!!!*/
  /*ExpData1:route-data_clear-xmlschema ( ).*/
end. /*doe _main*/
end procedure. /* proc-main */

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define variable v-flag as logical no-undo .
define variable v-ii as integer no-undo .
define variable v-changes-list2 as character no-undo .
define variable v-h as handle no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_ext-system for ub.ext-system.
define buffer buf_temp-rule-call-param for temp-rule-call-param.

do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo , return error substitute( "&1. stop", vss-workfile )
on endkey undo , return error substitute( "&1. endkey", vss-workfile )
:


  { gbl/calltree.i 'cb_rcps-run_fill-rcp-from-tt0' this-procedure:handle p-cont-handle v-h }
  run  cb_rcps-run_fill-rcp-from-tt0 in v-h ( input p-call-id
                                             ,input buffer buf_temp-rule-call-param:handle
                                                          ).

  for each buf_temp-rule-call-param no-lock where
  buf_temp-rule-call-param.codex_id = p-codex-id
  and buf_temp-rule-call-param.ruleset_id = p-ruleset-id
  and buf_temp-rule-call-param.call_id = p-call-id
  and buf_temp-rule-call-param.order_id = p-order-id
  and buf_temp-rule-call-param.rule_id = p-rule-id
  and buf_temp-rule-call-param.param-name = "p-esys-id-list",
    first buf_ext-system no-lock where
          buf_Ext-system.esys-id = buf_temp-rule-call-param.param-value-integer
      and buf_Ext-system.db-num = 0
      and buf_Ext-system.esys-have-export = yes
      and buf_Ext-system.esys-db-num-exp = g#db-num:
    v-esys-id-list = v-esys-id-list + (if v-esys-id-list = '' then '' else {&delim-nws}) + string(buf_ext-system.esys-id).
  end.
  if v-esys-id-list = '' then return "return".

  /*---------------------------&start-process-rule-call-param&-------------------------------*/
  find first buf_temp-rule-call-param no-lock where
buf_temp-rule-call-param.codex_id = p-codex-id
and buf_temp-rule-call-param.ruleset_id = p-ruleset-id
and buf_temp-rule-call-param.call_id = p-call-id
and buf_temp-rule-call-param.order_id = p-order-id
and buf_temp-rule-call-param.rule_id = p-rule-id
and buf_temp-rule-call-param.param-name = "p-xsd-file"
 no-error.
if available buf_temp-rule-call-param then do:
  assign p-xsd-file = buf_temp-rule-call-param.param-value-character.
end.

/*---------------------------&end-process-rule-call-param&-------------------------------*/

    case p-ruleset-id:
      when {&goods-proc_11_batchwork-routing_2} then do:
        assign
        v-current-host-code = p-host-code
        v-current-obj-type = p-obj-type
        v-current-obj-code = p-obj-code
        .
      end.
      otherwise do:
        undo, return error substitute("Неверный вызов &1 для набора правил &2", vss-workfile , p-ruleset-id).
      end.
    end case.

end. /*doe*/

end procedure. /* load-ruleset-context */