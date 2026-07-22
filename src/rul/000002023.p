/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 11 набор правил 4

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/13/09
Author: Bakhtadze Natalya
Creation date: 02/13/09


---------------------------&start-codex_id=11;ruleset_id=4;-----------------
Импорт данных по клиентам из XML файла

---------------------------&end-codex_id=11;ruleset_id=4;-----------------

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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 11 набор правил 4".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/garbcoll.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }
&glob cmd-proc-handle p-cmd-proc-handle
&glob cmd-code p-cmd-code
{ nws/temp-cmd.i "SHARED" }
{ rul/cl-hist.i "shared" }
{ rul/library-cls.i "non-class-part" }
{ gbl/key-rec.i }
{ rul/tempcxml.i "shared" }
{ gbl/gate-clb.i }
{ ref/grplib.i }
{ bge/tmpcxmlh.i }

// { bge/getoxmlh.i } 23/VIII-2018 xmllib.i и tmpcxmlh.i вставлены напрямую
{ str/xmllib.i }
// { bge/tmpcxmlh.i } 23/VIII-2018 - уже было вставлено

{ gbl/xmlchar.i }
{ gbl/tmpreldf.i }
{ gbl/tmpreld2.i }
{ ref/extclass.i }
{ str/tt-tax.i "new SHARED" tt-tax full }
{ gbl/orapreps.i }
{ cmp/t-tnved.i "new"  }
{ nws/db-rec.i }

/*переменные контекста*/
/*это у нас объект 0*/
define variable v-current-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-current-lock as integer no-undo .
define variable v-current-wait as integer no-undo .
define variable v-save as integer no-undo .
define variable log-file-name                as character      no-undo .
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-current-db-num as integer no-undo .
define variable v-current-date as date no-undo .
/*****************************/
define variable v-sign as integer no-undo .
define variable file-name as char.
define variable num-rec as integer no-undo .
define variable num-rec-ok as integer no-undo .
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable v-end-new-line     as logical no-undo .
define variable v-last-error-message as character no-undo .
define variable v-retry-action as integer no-undo .
define variable v_dataseth as handle no-undo .
define variable v-xmlh as handle no-undo .
define variable v_qh as handle no-undo .
define variable glog as logical no-undo .
define variable v-esys-id as integer no-undo .
define variable v-extension as character no-undo .
define variable v-last-rec-ord as integer no-undo .
define variable v-err-type as character no-undo .
define variable v-pck-num as integer no-undo .

{ rul/seterror.i }
define buffer buf_temp-cmd for temp-cmd.
define temp-table temp-goods_ no-undo like ub.goods.
define temp-table temp-bar-code_ no-undo like ub.bar-code
field status_ as character
.
define temp-table temp-prod-bc_ no-undo like ub.prod-bc
field status_ as character
field on-off as logical
field rc as recid
.
define buffer buf_temp-xml-tables for temp-xml-tables.


function 00110004_get-error-message returns character :
define variable v-ii as integer no-undo .
define variable v-mess as character no-undo .
DO v-ii = 1 TO ERROR-STATUS:NUM-MESSAGES:
    v-mess = substitute("&1&2ош &3"
                        ,v-mess
                        ,{&new-line}
                        ,ERROR-STATUS:GET-MESSAGE(v-ii)).
END.
return v-mess.
end function.

function 00110004_after-import_f returns logical ( input p-d-card as character):
  run 00110004_after-import in this-procedure ( input p-d-card) no-error.
  run set-error in this-procedure ( input return-value ).
  return not (error-status:error).
end function.



&scop display-message ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~)



/*---------------------------&start-rule-call-param&-------------------------------*/
define variable p-esys-id as integer no-undo .
define variable p-xsd-file as character no-undo.


/*---------------------------&end-rule-call-param&-------------------------------*/


/* ------------------------- &start-i-script& -----------------------------------*/


/* ------------------------- &end-i-script& -----------------------------------*/

on delete of this-procedure do:
  run delete-procedure in this-procedure .
  run gate-clear in this-procedure ( input v_dataseth, input v-xmlh) no-error.
end.


&scop sign v-sign *

run load-ruleset-context in this-procedure ( input p-ruleset-id) no-error .
if error-status:error
or return-value = "return" then return error.

/* ------------------------- &start-def-vars& -----------------------------------*/
define variable ImpData1 as class Route-data_ no-undo .
&scop constructor_2 ( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle, input v_dataseth, input v-xmlh)
ImpData1 = new Route-data_{&constructor_2} .


/* ------------------------- &end-def-vars& -----------------------------------*/


if not this-procedure:persistent then do:
  run proc-main in this-procedure no-error .
  if error-status:error then do:
      run delete-procedure in this-procedure .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
  end.
  run delete-procedure in this-procedure .
end.

procedure proc-main :
define variable v-mode as character no-undo .
define variable v-line-num as integer no-undo .
define variable v-present as logical no-undo .
define variable v-current-tbl-name as character no-undo .
define variable v-current-gds-code as integer no-undo .
define variable v-line-status_ as character no-undo .
define variable v-group-code as integer no-undo .
define variable v-depart-code as integer no-undo .
define variable v-class-code as integer no-undo .
define variable v-subclass-code as integer no-undo .
define variable v-rowid as rowid no-undo .
define variable v-table-name as character no-undo .
define variable v-vat-rate-code as integer   no-undo .
define variable v-field-list as character no-undo .
define variable v-current-b-code as integer   no-undo .
define variable v-current-b-gds-code as integer no-undo .
define variable v-current-prod-bc-b-str as character no-undo .
define variable v-current-prod-bc-b-code as integer   no-undo .
define variable v-current-prod-bc-bc-on as logical   no-undo .
define variable v-current-prod-bc-status_ as character no-undo .
define variable v-node-code as integer   no-undo .

define variable v_child-qh as handle no-undo .
define variable v_child2-qh as handle no-undo .
define buffer buf_temp-goods_ for temp-goods_.
define buffer buf_temp-bar-code_ for temp-bar-code_.
define buffer buf_temp-prod-bc_ for temp-prod-bc_.
define buffer buf_temp-rel-handle for temp-rel-handle.
define buffer buf2_temp-rel-handle for temp-rel-handle.
define buffer buf_ext-classif for ub.ext-classif.
define buffer buf_gds-grp for ub.gds-grp.
define buffer buf_tax-rate for ub.tax-rate.

define variable v-rid as recid no-undo .

&scop full-trans   transaction
&scop single-trans

_main:
do {&full-trans}
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:


/* ------------------------- &start-hn-option& -----------------------------------*/





/* ------------------------- &end-hn-option -----------------------------------*/


run write-log  in p-log-handle (
                                 input 0
                               , "&DLine").
&scop my-message substitute(".............Импорт данных по товарам из ВС")
  {&display-message}.

run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Импорт данных по товарам из файла &1", file-name)).

{ gbl/emptyscl.i v-node-code }

for each buf_temp-xml-tables where
       buf_temp-xml-tables.order >= 0
   and buf_temp-xml-tables.is-parent = yes
:
  if buf_temp-xml-tables.tbl-name = "Header_" then next.
  /*надо создать динамический query*/
  create query v_qh.
  glog = v_qh:set-buffers( buf_temp-xml-tables.tbl-handle_) no-error.
  if error-status:error
  or
  not glog then do:
    &scop my-message  substitute("Ошибка при попытке получить записи &1&2&3&2&4" ~
                                                            , buf_temp-xml-tables.tbl-name ~
                                                            , ~{&new-line~} ~
                                                            , error-status:get-message(1) ~
                                                            , return-value)
    {&display-message}.
    undo _main, return error ''.
  end.
  glog = v_qh:query-prepare( substitute( "for each &1 by &1.line-num", buf_temp-xml-tables.tbl-name)) no-error .
  if error-status:error
  or
  not glog then do:
    &scop my-message  substitute("Ошибка при попытке получить записи &1&2&3&2&4" ~
                                                            , buf_temp-xml-tables.tbl-name ~
                                                            , ~{&new-line~} ~
                                                            , error-status:get-message(1) ~
                                                            , return-value)
    {&display-message}.
    if valid-handle(v_qh) then do:
      delete object v_qh no-error.
    end.
    undo _main, return error ''.
  end.
  glog = v_qh:query-open no-error .
  if error-status:error
  or not glog then do:
    &scop my-message  substitute("Ошибка при попытке получить записи &1&2&3&2&4"  ~
                                  , buf_temp-xml-tables.tbl-name ~
                                  , ~{&new-line~} ~
                                  , error-status:get-message(1) ~
                                  , return-value)
    {&diplay-message}.
    if valid-handle(v_qh) then do:
      delete object v_qh no-error.
    end.
    undo _main, return error ''.
  end.
    _stroka:
    REPEAT:
      v-retry-action = 0 .
     _release:
      do on error undo, retry:
        if  retry then do:
          v-retry-action = v-retry-action + 1.
          &scop my-message   substitute("Ошибка при импорте записи &5 &1&2&3&2&4" ~
                                                                  , buf_temp-xml-tables.tbl-name ~
                                                                  , num-rec ~
                                                                  , ~{&new-line~} ~
                                                                  , error-status:get-message(1) ~
                                                                  , return-value)
          {&display-message}.
          if valid-handle(v_qh) then do:
            delete object v_qh no-error.
          end.
          undo _main, return error ''.
        end. /*if retry*/
      /* ------------------------- &count-retry-action-start& -----------------------------------*/
      /* ------------------------- &start-release-obj& -----------------------------------*/
        if v-retry-action < 1 then do:
          &scop release_2 dump ( )
          ImpData1:Route-data_{&release_2} .
        end.

      /* ------------------------- &end-release-obj& -------------------------------------*/
      /* ------------------------- &count-retry-action-end& -----------------------------------*/
      end. /*      do on error undo, retry:*/
      _rule:
       do on error undo _rule, retry _rule:
         if retry then do:
           empty temp-table buf_temp-goods_.
           empty temp-table buf_temp-bar-code_.
           empty temp-table buf_temp-prod-bc_.
           if valid-handle(v_qh) then do:
             delete object v_qh no-error.
           end.
           if valid-handle(v_child-qh) then do:
             delete object v_child-qh no-error.
           end.
           if valid-handle(v_child2-qh) then do:
             delete object v_child2-qh no-error.
           end.
           &scop my-message  substitute("&1&2&3" ~
                                      , error-status:get-message(1) ~
                                      , ~{&new-line~} ~
                                      , return-value)
           {&display-message}.
           undo _main, return error ''.
         end.
         else do:
          v_qh:get-next().
          IF v_qh:query-off-end then leave _stroka.

      /* ------------------------- &start-rule& -----------------------------------*/
          assign
          v-current-tbl-name = ''
          v-current-tbl-name = ImpData1:current-tbl-name() no-error.
          case v-current-tbl-name:
            when {&table_goods}  THEN do:
              empty temp-table buf_temp-goods_.
              empty temp-table buf_temp-bar-code_.
              empty temp-table buf_temp-prod-bc_.
              _tr:
              do {&single-trans}
              on error undo _rule, retry _rule
              :
                v-line-num = ImpData1:route-data_get-field-integer( input {&table_goods}, input "line-num") .
                v-present = no.
                &if "{&single-trans}" = "transaction" &then
                run get-xcnf_check-imp-rec in p-cont-handle (
                                                      input "create"
                                                    , input p-esys-id
                                                    , input 0
                                                    , input g#db-num
                                                    , input v-pck-num
                                                    , input string(v-line-num)
                                                    , output v-present
                                                    ) no-error.
                if v-present then do:
                  undo _rule, next _stroka.
                end.
                &endif
                num-rec = num-rec + 1.
                v-current-gds-code  = ImpData1:route-data_get-field-integer( input {&table_goods}, input "gds-code") .
                find first buf_temp-goods_ where
                          buf_temp-goods_.gds-code = v-current-gds-code no-error.
                if not available buf_temp-goods_ then do:
                  create  buf_temp-goods_.
                  assign
                  buf_temp-goods_.gds-code = v-current-gds-code
                  .
                end.
                v-line-status_ = ImpData1:route-data_get-field-character( input {&table_goods}, input "status_") .
                /*v-group-code = ImpData1:route-data_get-field-integer( input {&table_goods}, input "group-code") .*/
                v-depart-code = ImpData1:route-data_get-field-integer( input {&table_goods}, input "depart-code") .
                v-class-code = ImpData1:route-data_get-field-integer( input {&table_goods}, input "class-code") .
                v-subclass-code = ImpData1:route-data_get-field-integer( input {&table_goods}, input "subclass-code") .


                find first buf_ext-classif no-lock where
                          buf_ext-classif.classif-subject = {&table_gds-grp}
                      and buf_ext-classif.classif-name = {&extclass_gds-grp_rpm}
                      AND buf_ext-classif.db-num = - 1
                      /*and buf_ext-classif.charkey_one = string(v-group-code)*/
                      and buf_ext-classif.key#_one = v-depart-code
                      and buf_ext-classif.key#_two = v-class-code
                      and buf_ext-classif.key#_three = v-subclass-code no-error.
                if not available buf_ext-classif then do:
                  &scop my-message substitute("Запись &1: Не найден узел товарного классификатора .../&2/&3/&4" ~
                                              , v-line-num ~
                                              , v-depart-code ~
                                              , v-class-code  ~
                                              ,v-subclass-code )
                  {&display-message}.
                  undo _rule, retry _rule.
                end.
                RUN gen-row-keyr IN THIS-PROCEDURE ( INPUT buf_ext-classif.uniq-key-rec
                                                    ,INPUT ?
                                                    ,INPUT "ub"
                                                    ,INPUT ? /*p-bh-handle*/
                                                    ,INPUT NO-LOCK
                                                    ,OUTPUT v-rowid
                                                    ,OUTPUT v-table-name) .
                find first buf_gds-grp no-lock where
                          rowid(buf_gds-grp) = v-rowid .
                buf_temp-goods_.grp-code = buf_gds-grp.node-code.
                v-vat-rate-code = ImpData1:route-data_get-field-integer( input {&table_goods}, input "rate-code") .
                v-field-list = "artic,prod-type,prod-code,gds-name,engl-name,label-name,chk-name,unit-base" +
                               ",wt-base,ms-base,unit-cli,cli-base-rate,qnty-cart,wt-cart,ms-cart,gds-type,PS,okdp" +
                               ",negative-rest,min-stock,alpha1,grp-code".

                assign
                glog = buffer buf_temp-goods_:handle:buffer-copy(ImpData1:route-data_get-record({&table_goods}), "gds-code") no-error.
                if not glog
                or error-status:error then do:
                  &scop my-message  substitute("Не удалось получить данные записи goods: &1&2&3" ~
                                              , error-status:get-message(1) ~
                                              , ~{&new-line~} ~
                                              , return-value)
                  {&display-message}.
                  undo _rule, retry _rule.
                end.
                assign
                buf_temp-goods_.nationality = "российский"
                .
                _rel:
                for each buf_temp-rel-handle where
                        buf_temp-rel-handle.parent-buffer_ = v-current-tbl-name:
                  run tmpreld2_query in this-procedure ( buffer buf_temp-rel-handle, input-output v_child-qh) no-error .
                  if error-status:error then do:
                    &scop my-message return-value
                    {&display-message}.
                    undo _rule, retry _rule.
                  end.
                  _child:
                  repeat:
                    v_child-qh:get-next().
                    IF v_child-qh:query-off-end then do:
                      delete object v_child-qh no-error.
                      next _rel.
                    end.
                    case buf_temp-rel-handle.child-buffer_:
                      when {&table_bar-code} then do:
                        v-current-b-code = ImpData1:route-data_get-field-integer( buffer buf_temp-rel-handle:handle, input buf_temp-rel-handle.child-buffer_, input "b-code") .
                        v-current-b-gds-code = ImpData1:route-data_get-field-integer( buffer buf_temp-rel-handle:handle, input buf_temp-rel-handle.child-buffer_, input "gds-code") .
                        if v-current-b-gds-code <> v-current-gds-code then do:
                          /*нарушение протокола которое не можем отследить через схему*/
                          &scop my-message substitute("Запись &1: нарушение схемы")
                          {&display-message}.
                          delete object v_child-qh no-error.
                          undo _rule, retry _rule.
                        end.
                        find first buf_temp-bar-code_ where
                                  buf_temp-bar-code_.gds-code = v-current-b-gds-code
                              and buf_temp-bar-code_.b-code = v-current-b-code  no-error.
                        if not available buf_temp-bar-code_ then do:
                          create  buf_temp-bar-code_.
                          assign
                          buf_temp-bar-code_.gds-code = v-current-gds-code
                          buf_temp-bar-code_.b-code = v-current-b-code
                          .
                        end.
                        assign
                        glog = buffer buf_temp-bar-code_:handle:buffer-copy(buf_temp-rel-handle.child-buffer-handle
                                                                            ,"gds-code,b-code") no-error .
                        if not glog
                        or error-status:error then do:
                          &scop my-message substitute("Не удалось получить данные записи <&4>: &1&2&3" ~
                                                      , error-status:get-message(1) ~
                                                      , ~{&new-line~} ~
                                                      , return-value ~
                                                      , ~{&table_bar-code~} )
                          {&display-message}.
                          undo _rule, retry _rule.
                        end.
                        _rel2:
                        for each buf2_temp-rel-handle where
                                buf2_temp-rel-handle.parent-buffer_ = {&table_bar-code}:
                          run tmpreld2_query in this-procedure ( buffer buf2_temp-rel-handle, input-output v_child2-qh) no-error .
                          if error-status:error then do:
                            &scop my-message return-value
                            {&display-message}.
                            undo _rule, retry _rule.
                          end.
                          _child2:
                          repeat:
                            v_child2-qh:get-next().
                            IF v_child2-qh:query-off-end then do:
                              delete object v_child2-qh no-error.
                              next _rel2.
                            end.
                            case buf2_temp-rel-handle.child-buffer_:
                      when {&table_prod-bc}
                      THEN do:
                                v-current-prod-bc-b-str = ImpData1:route-data_get-field-character( buffer buf2_temp-rel-handle:handle, input buf2_temp-rel-handle.child-buffer_, input "b-str") .
                                v-current-prod-bc-b-code = ImpData1:route-data_get-field-integer( buffer buf2_temp-rel-handle:handle, input buf2_temp-rel-handle.child-buffer_, input "b-code") .
                                v-current-prod-bc-bc-on = ImpData1:route-data_get-field-logical( buffer buf2_temp-rel-handle:handle, input buf2_temp-rel-handle.child-buffer_, input "bc-on") .
                                v-current-prod-bc-status_ = ImpData1:route-data_get-field-character( buffer buf2_temp-rel-handle:handle, input buf2_temp-rel-handle.child-buffer_, input "status_") .
                                if v-current-prod-bc-b-code <> v-current-b-code then do:
                                  /*нарушение протокола которое не можем отследить через схему*/
                                  &scop my-message substitute("Запись &1: нарушение схемы")
                                  {&display-message}.
                                  delete object v_child2-qh no-error.
                                  delete object v_child-qh no-error.
                                  undo _rule, retry _rule.
                                end.
                        find first buf_temp-prod-bc_ where
                                  buf_temp-prod-bc_.b-str = v-current-prod-bc-b-str
                              and buf_temp-prod-bc_.b-code = v-current-prod-bc-b-code
                                    no-error.
                        if not available buf_temp-prod-bc_ then do:
                          create  buf_temp-prod-bc_.
                          assign
                          buf_temp-prod-bc_.b-code = v-current-prod-bc-b-code
                          buf_temp-prod-bc_.b-str = v-current-prod-bc-b-str
                          .
                        end.
                        buf_temp-prod-bc_.bc-on = v-current-prod-bc-bc-on.
                                buf_temp-prod-bc_.status_ = v-current-prod-bc-status_.
                        release buf_temp-prod-bc_ .
                      end. /*when {&table_prod-bc} */
                            end case.
                          end. /*repeat*/
                          delete object v_child2-qh no-error.
                        end. /*                        for each buf2_temp-rel-handle where*/
                        release buf_temp-bar-code_ .
                      end. /*when {&table_bar-code} then do:*/
                    end case. /*                case buf_temp-rel-handle_.child-buffer_:*/
                  end. /*repeat*/
                  delete object v_child-qh no-error.
                end. /*              for each buf_temp-rel-handle where*/
            run proc-save in this-procedure ( input v-line-num
                                             ,input v-line-status_
                                             ,input v-vat-rate-code
                                             ,input v-node-code
                                             ,input v-field-list
                                             ,input no /*p-dif-nam1*/
                                             ,input no /*p-dif-nam2*/
                                             ,buffer buf_temp-goods_) no-error.
            if error-status:error then do:
              run set-err-type in p-cont-handle
                ( input {&ora-err-type-processing}
                ) no-error.
              if valid-handle(v_qh) then do:
                delete object v_qh no-error.
              end.
              &scop my-message  substitute("&1&2&3"  ~
                                          , error-status:get-message(1) ~
                                          , ~{&new-line~} ~
                                          , return-value)
              {&display-message}.
              undo _rule, retry _rule .
            end.
              end. /*do transaction*/
            end. /*when {&table_goods}*/
          end case.
      /* ------------------------- &end-rule -------------------------------------*/
        end. /*ne retry*/
      end. /*       do on error undo _rule, retry _rule:*/
      v-retry-action = 0 .
     _release:
      do on error undo, retry:
        if  retry then do:
          v-retry-action = v-retry-action + 1.
          &scop my-message  substitute("&1&2&3" ~
                                      , error-status:get-message(1) ~
                                      , ~{&new-line~} ~
                                      , v-last-error-message )
          {&display-message}.
          undo _main, return error ''.
        end.
      /* ------------------------- &count-retry-action-start& -----------------------------------*/
      /* ------------------------- &start-release-obj& -----------------------------------*/
      if v-retry-action < 1 then do:
        &scop release_2 dump ( )
        ImpData1:Route-data_{&release_2} .
      end.
      /* ------------------------- &end-release-obj& -------------------------------------*/
      /* ------------------------- &count-retry-action-end& -----------------------------------*/
      end.
      if v-retry-action = 0 then do:
        num-rec-ok = num-rec-ok + 1.
      end.
      run write-counter in p-log-handle ( input substitute("Обработано записей: &1, из них удачно: &2", num-rec, num-rec-ok)).
    end. /*stroka*/
    v_qh:query-close().
    if valid-handle(v_qh) then do:
      delete object v_qh.
    end.
  end. /*for each buf_temp-xmp-tables*/
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Обработано записей: &1, из них удачно: &2", num-rec, num-rec-ok)).
end. /*doe _main*/
end procedure. /* proc-main */

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_ext-system for ub.ext-system.
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
and buf_rule-call-param.param-name = "p-esys-id"
 no-error.
if available buf_rule-call-param then do:
assign p-esys-id = buf_rule-call-param.param-value-integer.
end.

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


/*---------------------------&end-process-rule-call-param&-------------------------------*/
    case p-ruleset-id:
      when 4 then do:
        assign
        v-sign = 1
        v-current-host-code = p-host-code
        v-current-obj-type = p-obj-type
        v-current-obj-code = p-obj-code
        v-current-db-num = g#db-num
        v-current-lock = (if p-save >= 0 then exclusive-lock else no-lock)
        file-name  = entry(1, p-process-file-name, {&delim-par})
        v_dataseth = handle(entry(2, p-process-file-name, {&delim-par}))
        v-xmlh = buffer buf_temp-xml-tables:handle
        v-esys-id = integer(p-doc-code)
        v-extension = entry(num-entries(file-name, "."), file-name, ".")
        v-pck-num = integer(entry(3, p-process-file-name, {&delim-par}))
        log-file-name = entry(4, p-process-file-name, {&delim-par})
        no-error
        .
        if error-status:error then do:
          &scop my-message substitute("Ошибки параметров&1&2 ..." ~
                                        , ~{&new-line~} ~
                                        , error-status:get-message(1) )
          {&display-message}.
          undo, return error {&my-message}.
        end.
        find first buf_ext-system no-lock where
                  buf_ext-system.esys-id = v-esys-id
              and buf_ext-system.db-num = 0 no-error .
        if not available buf_ext-system then do:
          &scop my-message substitute("Не найдена ВС &1&2 ..." ~
                                        , v-esys-id ~
                                        , ~{&new-line~} ~
                                        )
          {&display-message}.
          undo, return error {&my-message}.
        end.
        if v-extension = ''
        or lookup(v-extension, "dat") = 0 then do:
          &scop my-message substitute("Файл &1 имеет недопустимое расширение &3&2 ..." ~
                                        ,file-name ~
                                        , ~{&new-line~} ~
                                        , v-extension ~
                                        )
          {&display-message}.
          undo, return error {&my-message}.
        end.
        run tmpreldf_get-relations in this-procedure ( input  v_dataseth).
      end.
      otherwise do:
        undo, return error "Неправильный вызов".
      end.
    end case.
  end. /*doe*/

end procedure. /* load-ruleset-context */



procedure delete-procedure :

  do
  on error undo, return error
  :
      for each temp-goods_:
        delete temp-goods_.
      end.
      for each temp-bar-code_:
        delete temp-bar-code_.
      end.
      for each temp-prod-bc_:
        delete temp-prod-bc_.
      end.

      run garbcoll_clear in this-procedure .
  end.

end procedure. /* delete-procedure */

procedure proc-save :
define input  parameter p-line-num as integer   no-undo .
define input  parameter p-line-status_ as character no-undo .
define input  parameter p-vat-rate-code as integer   no-undo .
define input  parameter p-node-code as integer   no-undo .
define input  parameter p-field-list as character no-undo .
define input  parameter p-dif-nam1 as logical   no-undo .
define input  parameter p-dif-nam2 as logical   no-undo .
define parameter buffer buf_temp-goods_ for temp-goods_.
define buffer buf_temp-bar-code_ for temp-bar-code_.
define buffer buf_temp-prod-bc_ for temp-prod-bc_.
define buffer buf_goods for ub.goods.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_sysconf for ub.sysconf.

define variable v-rid as recid no-undo .
define variable v-gds-mode as character no-undo .
define variable v-bc-mode as character no-undo .
define variable v-pbc-mode as character no-undo .
define variable v-b-str as character no-undo .
define variable v-err-mess as character no-undo .
define variable v-nbc as integer   no-undo .
define variable v-stts as integer no-undo .
define variable v-field-list as character no-undo .
define variable v-ii as integer   no-undo .
define variable v-cmp as logical   no-undo .
define variable v-cmp-tax as logical no-undo init yes.
define variable v-key-rec as character no-undo .
define variable v-param as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-taxvalue as decimal no-undo .


main-block:
do transaction
on error  undo main-block, retry main-block
on stop   undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    empty temp-table buf_temp-goods_.
    empty temp-table buf_temp-bar-code_.
    empty temp-table buf_temp-prod-bc_.
     &scop my-message v-err-mess
     {&display-message}.
     return error ''.
  end.
  else do:
    find first buf_goods share-lock where
            buf_goods.gds-code = buf_temp-goods_.gds-code no-error.
    if not available buf_goods then do:
      v-gds-mode = {&add-def}.
      v-rid = ?.
    end.
    else do:
      if not (buf_temp-goods_.prod-type = buf_goods.prod-type
              and
              buf_temp-goods_.prod-code = buf_goods.prod-code) then do:
        v-err-mess =  substitute("Запись &1: Изменение производителя товара &2 недопустимо!!!"
                                      ,p-line-num
                                      ,buf_temp-goods_.gds-code
                                      ,p-line-status_ ).
        run set-err-type in p-cont-handle
          ( input {&ora-err-type-SYNCHRONIZATION}
          ) no-error.
        undo main-block, retry main-block .
      end.
      v-gds-mode = {&update}.
      v-rid = recid( buf_goods).
      buffer buf_temp-goods_:handle:buffer-copy(buffer buf_goods:handle, p-field-list).
    end.
    if ((v-gds-mode = {&add-def} and not p-line-status_ = {&ora-line-create})
    or (v-gds-mode = {&update} and not (p-line-status_ = {&ora-line-update} or p-line-status_ = {&ora-line-delete}))
        )
    and not (available buf_goods and  buf_goods.stts = integer({&deleted-status-int}) and p-line-status_ = {&ora-line-create})
    then do:
      v-err-mess =  substitute("Запись &1: Неверное действие над товаром &2 (&3)"
                                    ,p-line-num
                                    ,buf_temp-goods_.gds-code
                                    ,p-line-status_ ).

      run set-err-type in p-cont-handle
        ( input {&ora-err-type-SYNCHRONIZATION}
        ) no-error.
      undo main-block, retry main-block .
    end.
    for each tt-tax:
      delete tt-tax.
    end.
    run ref/dtaxgdss.p (
          input yes /*p-silent*/
        , input /*par-unit-base*/  buf_temp-goods_.unit-base
        , input /*par-node-code*/  p-node-code
        , input (if v-gds-mode = {&add-def} THEN ? ELSE v-rid)
        , input (if v-gds-mode = {&add-def} THEN ? ELSE v-rid)
        , input /*par-host-code*/  0
        , input /*par-obj-type*/   ''
        , input /*par-obj-code*/  0
          ) no-error.
    if error-status:error then do:
      v-err-mess = substitute("Запись &1: Ошибки при определении налогов на товар:&2&3&2&4"
                               , p-line-num
                               , {&new-line}
                               , error-status:get-message(1)
                               , return-value ).
      undo main-block, retry main-block.
    end.
    find first tt-tax where
              tt-tax.tax-code = integer({&vat-tax-code}).
    if tt-tax.rate-code <> p-vat-rate-code then do:
      v-cmp-tax = no.
    end.
    run cur-time in this-procedure(output v-today, output v-time).
    { gbl/pftaxval.i ? tt-tax.tax-code tt-tax.rate-code v-today 0 '' 0 v-taxvalue no-error }
    if error-status:error or v-taxvalue = ? then do:
      v-err-mess = substitute("Запись &1: Ошибка при поиске НДС (код ставкм &6) на текущую дату для товара &2&3&4&3&5"
                                , p-line-num
                                , buf_temp-goods_.gds-code
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value
                                , tt-tax.rate-code
                                ).
      undo main-block, retry main-block.
    end.
    if not v-gds-mode = {&add-def} then do:
      tt-tax.fact-date = v-today.
    end.
    assign
    tt-tax.rate-code = p-vat-rate-code
    .
    if buf_temp-goods_.unit-cli = ''
    or buf_temp-goods_.unit-cli = ? then do:
      assign
      buf_temp-goods_.unit-cli = buf_temp-goods_.unit-base
      buf_temp-goods_.cli-base-rate = 1
      .
    end.
    if buf_temp-goods_.cli-base-rate = 0
    or buf_temp-goods_.cli-base-rate = ?
    then do:
      buf_temp-goods_.cli-base-rate = 1.
    end.
    if v-gds-mode = {&update} then do:
      buffer buf_temp-goods_:handle:buffer-copy(buffer buf_goods:handle, p-field-list).
      do v-ii = 1 to num-entries(p-field-list):
        v-field-list = v-field-list + (if v-ii = 1 then "" else {&comma-char}) + entry(v-ii, p-field-list) + {&comma-char} + entry(v-ii, p-field-list).
    end.
      v-cmp = buffer buf_temp-goods_ :handle:buffer-compare(buffer buf_goods:handle, "CASE-SENSITIVE", "", v-field-list).
    end.
    if v-gds-mode = {&add-def}
    or not v-cmp
    or not v-cmp-tax
    then do:
    run ref/goods01.p (
                        input parparentproc
                        , input v-gds-mode
                      , input no /*par-copymode */
                      , input 0 /*par-alt-bc-mode as integer нужно ли вводить ДОП БК вместе с товаром*/
                      , input no /*par-manual as logical мз карточки товара - yes*/
                      , input yes /*par-silence as logical  ругаемся вслух или ?*/
                      , input no /* import */
                      , input no /*par-file as logical идет импоррт из файла - из карточки товара*/
                      , input no /*par-single-record as logical надо сохранить только одну запись - потом выход в справ*/
                      , input 0 /*par-host-code like ub.sysconf.host-code */
                      , input '' /*par-obj-type like ub.clients.obj-type */
                      , input 0 /*par-obj-code like ub.clients.obj-code */
                      , input (if buf_temp-goods_.gds-type = {&gds-goods} then  yes else no)
                      , input ? /*par-copy-rec as recid recid записи с которой копируем*/
                      , input buf_temp-goods_.gds-code
                      , input buf_temp-goods_.artic
                      , input buf_temp-goods_.prod-type
                      , input buf_temp-goods_.prod-code
                      , input p-node-code
                      , input buf_temp-goods_.grp-code
                      , input buf_temp-goods_.gds-name
                      , input "":U /*par-saved-name like ub.buf_goods.gds-name no-undo */
                      , input buf_temp-goods_.engl-name
                      , input buf_temp-goods_.label-name
                      , input buf_temp-goods_.chk-name
                      , input buf_temp-goods_.alpha1
                      , input buf_temp-goods_.unit-base
                      , input buf_temp-goods_.unit-cli
                      , input 0 /*p-max-rate*/
                      , input 0 /*p-min-rate*/
                      , input buf_temp-goods_.cli-base-rate
                      , input buf_temp-goods_.qnty-cart
                      , input buf_temp-goods_.ms-base
                      , input buf_temp-goods_.wt-base
                      , input buf_temp-goods_.ms-cart
                      , input buf_temp-goods_.wt-cart
                      , input {&pr-calc-grp}
                      , input 0 /*increase-pc*/
                      , input buf_temp-goods_.negative-rest
                      , input 0 /*price-base*/
                      , input 0 /*price-rubl*/
                      , input buf_temp-goods_.okdp
                      , input buf_temp-goods_.destin
                      , input buf_temp-goods_.attrib
                      , input buf_temp-goods_.user-rule
                      , input buf_temp-goods_.sert
                      , input buf_temp-goods_.struct
                      , input buf_temp-goods_.deadline
                      , input 0 /*cond-keep-code*/
                      , input buf_temp-goods_.sort
                      , input 0 /*proof*/
                      , input 0 /*normal-wastage*/
                      , input 0 /*normal-waste*/
                      , input '' /*tnved*/
                      , input buf_temp-goods_.nationality
                      , input buf_temp-goods_.unit-cli /*uniq-cst*/
                      , input buf_temp-goods_.cli-base-rate /*cst-base-rate*/
                      , input ? /*fbr-grp-code*/
                      , input buf_temp-goods_.PS
                      , input no /*unq-artc*/
                      , input no /*is-jwlr*/
                      , input no /*is-bttl*/
                      , input no /*is-ptrl*/
                      , input "no" /*custvalue*/
                      , input p-dif-nam1
                      , input p-dif-nam2
                      , input no /*par-ArtDis  */
                      , input 2 /*par-BarDis  */
                      , input-output v-rid
                      , output v-nbc
                    ) no-error .
    if error-status :error then do:
      v-err-mess = substitute("Запись &1: Ошибка при сохранении goods &2&3&4&3&5"
                                , p-line-num
                                , buf_temp-goods_.gds-code
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value ).
      undo main-block, retry main-block.
    end.
    end.
    find first buf_goods share-lock where
              recid(buf_goods) = v-rid .
    if (p-line-status_ = {&ora-line-delete}
    and buf_goods.stts = integer({&current-status-int}))
    or (p-line-status_ <> {&ora-line-delete}
    and buf_goods.stts <> integer({&current-status-int})) then do:
      v-stts = (if p-line-status_ = {&ora-line-delete}
                then integer({&deleted-status-int})
                else integer({&current-status-int})).
      run ref/goods02.p (
                    input recid(buf_goods)
                    ,input yes /*p-silent*/
                    ,input-output v-stts) no-error.
    end.
    if v-gds-mode = {&add-def} then do:
      find first buf_goods where
                recid(buf_goods) = v-rid.
    end.
    for each buf_temp-bar-code_ no-lock where
            buf_temp-bar-code_.gds-code = buf_temp-goods_.gds-code
    on error  undo main-block, retry main-block
    on stop   undo main-block, retry main-block
    on endkey undo main-block, retry main-block
    :
      find first buf_bar-code share-lock where
                buf_bar-code.b-code = buf_temp-bar-code_.b-code no-error.
      if available buf_bar-code then do:
        if buf_bar-code.stts_ = integer({&hn-switch-off})
        and buf_temp-bar-code_.b-code <> buf_temp-goods_.gds-code
        then do:
          v-bc-mode = {&add-def}.
        end.
        else do:
        v-bc-mode = {&update}.
        end.
        v-rid = recid(buf_bar-code).
      end.
      else do:
        v-bc-mode = {&add-def}.
        v-rid = ?.
      end.
      if  buf_temp-bar-code_.b-code = buf_temp-goods_.gds-code
      and v-gds-mode = {&add-def} then do:
        /*не надо проверять*/
      end.
      else do:
        if (v-bc-mode = {&add-def} and not buf_temp-bar-code_.status_ = {&ora-line-create})
        or (v-bc-mode = {&update}
            and not (buf_temp-bar-code_.status_ = {&ora-line-update} or buf_temp-bar-code_.status_ = {&ora-line-delete})
            and buf_temp-bar-code_.b-code <> buf_temp-goods_.gds-code
            )
      then do:
          v-err-mess =  substitute("Запись &1: Неверное действие над бар-кодом &2 (&3) товара &4"
                                      ,p-line-num
                                        ,buf_temp-bar-code_.b-code
                                        ,buf_temp-bar-code_.status_
                                      ,buf_temp-goods_.gds-code
                                        ).

        run set-err-type in p-cont-handle
          ( input {&ora-err-type-SYNCHRONIZATION}
          ) no-error.
        undo main-block, retry main-block .
      end.
        if v-bc-mode = {&add-def}
        and available buf_bar-code
        and buf_bar-code.stts_ = integer({&hn-switch-off}) then do:
          v-bc-mode = {&update}.
        end.
      end.
      if buf_temp-bar-code_.status_ = {&ora-line-delete} then do:
        /*  закоментарено под давлением украинской стороны
        if buf_temp-bar-code_.b-code = buf_temp-goods_.gds-code
        or buf_temp-bar-code_.unit-cli = buf_temp-goods_.unit-base
        then do:
          v-err-mess = substitute("Запись &1: Нельзя удалить основной бар-код &2"
                                  , p-line-num
                                  , buf_temp-bar-code_.b-code).
          undo main-block, retry main-block.
        end.
        */
      end.
      else do:
      if buf_temp-bar-code_.b-code <> buf_temp-goods_.gds-code then do:
      run ref/barcode1.p (
          input (v-bc-mode + {&comma-char} + {&add-import})
      ,input yes /*p-silent*/
      ,input buf_temp-bar-code_.b-code
      ,input buf_temp-bar-code_.gds-code
      ,input p-node-code
      ,input '':U /*p-part-code*/
      ,input '':U /*p-in-code*/
      ,input buf_temp-bar-code_.unit-cli
      ,input buf_temp-bar-code_.cli-base-rate
      ,output v-rid
      )
      no-error.
      if error-status :error then do:
        v-err-mess = substitute("Запись &1: Ошибка при сохранении bar-code  &2&3&4&5&4&6"
                                  , p-line-num
                                  , buf_temp-bar-code_.b-code
                                  , {&new-line}
                                  , error-status:get-message(1)
                                  , return-value
                                  ).
        undo main-block, retry main-block.
      end.
      end.
      end.
      for each buf_temp-prod-bc_ no-lock where
              buf_temp-prod-bc_.b-code = buf_temp-bar-code_.b-code
      on error  undo main-block, retry main-block
      on stop   undo main-block, retry main-block
      on endkey undo main-block, retry main-block
      :
        find first buf_prod-bc share-lock where
                  buf_prod-bc.b-code = buf_temp-prod-bc_.b-code
              and buf_prod-bc.b-str = buf_temp-prod-bc_.b-str no-error.
        if available buf_prod-bc then do:
          v-pbc-mode = {&update}.
          v-rid = recid(buf_prod-bc).
          buf_temp-prod-bc_.rc = recid(buf_prod-bc).
        end.
        else do:
          v-pbc-mode = {&add-def}.
          v-rid = ?.
        end.
        if (v-pbc-mode = {&add-def} and not buf_temp-prod-bc_.status_ = {&ora-line-create})
        or (v-pbc-mode = {&update} and not (buf_temp-prod-bc_.status_ = {&ora-line-update} or buf_temp-prod-bc_.status_ = {&ora-line-delete}))
        then do:
          v-err-mess =  substitute("Запись &1: Неверное действие над ДопБк &2 (&3)"
                                        ,p-line-num
                                        ,buf_temp-prod-bc_.b-str
                                        ,buf_temp-prod-bc_.status_ ).

          run set-err-type in p-cont-handle
            ( input {&ora-err-type-SYNCHRONIZATION}
            ) no-error.
          undo main-block, retry main-block .
        end.
        if buf_temp-prod-bc_.status_ = {&ora-line-delete}
        and not available buf_prod-bc then do:
          v-err-mess =  substitute("Запись &1: Неверное действие над ДопБк &2 (&3)"
                                        ,p-line-num
                                        ,buf_temp-prod-bc_.b-str
                                        ,buf_temp-prod-bc_.status_ ).

          run set-err-type in p-cont-handle
            ( input {&ora-err-type-SYNCHRONIZATION}
            ) no-error.
          undo main-block, retry main-block .
        end.
        if buf_temp-prod-bc_.status_ = {&ora-line-create} then do:
        v-b-str = buf_temp-prod-bc_.b-str.
        run trg/prod-bc1.p (
                            input parparentproc
                           ,input yes /*p-silent*/
                           ,input no /*dif-pdbc*/
                           ,input yes /*pbc-veto*/
                           ,input no /*send-ref*/
                           ,input '' /*p-cdrg-type*/
                           ,input '' /*ean-type*/
                           ,buffer buf_goods
                           ,input buf_temp-bar-code_.b-code
                           ,input-output v-b-str
                           ,output v-rid
                      ) no-error .
          if error-status :error
          or v-rid = ?
          then do:
            v-err-mess = substitute("Запись &1: Ошибка при сохранении ДопБк &2 (бар-код &3) &4&5&4&6"
                                    , p-line-num
                                    , buf_temp-prod-bc_.b-str
                                    , buf_temp-prod-bc_.b-code
                                    , {&new-line}
                                    , error-status:get-message(1)
                                    , return-value
                                    ).
          undo main-block, retry main-block.
        end.
          buf_temp-prod-bc_.rc = v-rid.
      end.
        if buf_temp-prod-bc_.status_ = {&ora-line-update} then do:
          if buf_temp-prod-bc_.bc-on <> buf_prod-bc.bc-on then do:
            buf_temp-prod-bc_.on-off = yes.
            run trg/bc-upd.p (
                          input parparentproc
                        ,input buf_temp-prod-bc_.b-code
                        ,input buf_temp-prod-bc_.b-str
                        ,input buf_temp-prod-bc_.bc-on
                        ,input yes /*p-mute*/
                        ,input no  /*send-ref*/
                        ,input ? /*same-recid*/
                        ,input this-procedure:handle  /*write-proc-handle*/
                        ) no-error  .
            if error-status:error then do:
              v-err-mess = substitute("Запись &1: Ошибки при вкл/выкл ДопБК &2:&3&4&3&5"
                                      , p-line-num
                                      , buf_temp-prod-bc_.b-str
                                      ,{&new-line}
                                      , error-status:get-message(1)
                                      , return-value ).
              undo main-block, retry main-block.
            end.
          end.
        end.
        if buf_temp-prod-bc_.status_ = {&ora-line-delete} then do:
          if buf_prod-bc.bc-on-type <> '' then do:
            v-err-mess = substitute("Запись &1: Нельзя удалить ДопБК типа &2", buf_prod-bc.bc-on-type).
            undo main-block, retry main-block.
          end.
          assign
          buf_prod-bc.bc-on = no
          buf_temp-prod-bc_.bc-on = no
          .
          /*почему-то так принимается по новостям и здесь так напишем*/
          delete buf_prod-bc.
        end.
      end. /*for each buf_temp-prod-bc_ no-lock where*/
      if buf_temp-bar-code_.status_ = {&ora-line-delete}
      and buf_temp-bar-code_.unit-cli <> buf_goods.unit-base
      then do:
        find first buf_prod-bc no-lock where
                  buf_prod-bc.b-code = buf_temp-bar-code_.b-code no-error.
         if available buf_prod-bc then do:
           v-err-mess = substitute("Невозможно удалить(выключить) бар-код &1 - существуют привязанные к нему ДопБК", buf_temp-prod-bc_.b-code).
            run set-err-type in p-cont-handle
              ( input {&ora-err-type-SYNCHRONIZATION}
              ) no-error.
            undo main-block, retry main-block .
         end.
         /*теперь бар-коды физически не удаляются , а удаляются логически*/
          assign
        buf_temp-bar-code_.stts = integer({&hn-switch-off})
        buf_bar-code.stts = integer({&hn-switch-off}).
        release buf_bar-code no-error.
        if error-status:error then do:
          v-err-mess = substitute("Запись &1: Невозможно удалить бар-код &2:&3&4"
                                  , p-line-num
                                  , buf_temp-bar-code_.b-code
                                  , {&new-line}
                                  , return-value
                                  ).
          run set-err-type in p-cont-handle
            ( input {&ora-err-type-SYNCHRONIZATION}
            ) no-error.
          undo main-block, retry main-block .
        end.
      end.
    end. /*    for each buf_temp-bar-code_ no-lock where*/
    run fill-g-list in  p-cont-handle  ( input buf_temp-goods_.gds-code, input '':U, input 0).
    for each buf_temp-bar-code_ :
      if buf_temp-bar-code_.status_ = {&ora-line-delete} then do:
        run fill-bar-code in p-cont-handle (
                                                input  buf_temp-bar-code_.b-code
                                               ,input  buf_temp-bar-code_.gds-code
                                               ,input  (if buf_temp-bar-code_.status_ = {&ora-line-delete}
                                                        then yes
                                                        else no)
                                               ,input  p-node-code
                                               ,input  buf_temp-bar-code_.in-code
                                               ,input  buf_temp-bar-code_.part-code
                                               ,input  buf_temp-bar-code_.cli-base-rate
                                               ,input  buf_temp-bar-code_.unit-cli
                                                ) no-error.
      end.
    end.
    for each buf_temp-prod-bc_,
         first buf_temp-bar-code_ where
             buf_temp-bar-code_.b-code = buf_temp-prod-bc_.b-code
         :
       if buf_temp-prod-bc_.status_ = {&ora-line-delete}
       or buf_temp-prod-bc_.on-off then do:
         run fill-pbc-list in p-cont-handle (
                                                 input buf_temp-prod-bc_.rc
                                               , input buf_temp-goods_.gds-code
                                               , input buf_temp-prod-bc_.b-code
                                               , input buf_temp-prod-bc_.b-str
                                               , input buf_temp-prod-bc_.bc-on
                                               , input (if buf_temp-prod-bc_.status_ = {&ora-line-delete}
                                                        or buf_temp-prod-bc_.bc-on = no
                                                        or buf_temp-bar-code_.status_ = {&ora-line-delete}
                                                        then yes
                                                        else no)
                                               ).
       end.

    end.
  end. /*ne retry*/
end.
end procedure. /* proc-save */

procedure write-file :
define input parameter p-mess as character no-undo .

do
on error undo, return error
:
   &scop my-message  p-mess
   {&display-message}.
end.

end procedure. /* write-file */


/*не удалять!!!!*/