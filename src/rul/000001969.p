/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 13 набор правил 3

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/08/06
Author: Bakhtadze Natalya
Creation date: 10/08/06


---------------------------&start-codex_id=13;ruleset_id=3;-----------------
Импорт данных по группам товаров из XML файла

---------------------------&end-codex_id=13;ruleset_id=3;-----------------

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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 13 набор правил 3".
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
{ rul/tempcxml.i "new shared" }
{ gbl/gate-clb.i }
{ ref/grplib.i }
{ ref/ggrplist.i ggrp-list def "SHARED" }
{ bge/tmpcxmlh.i }

// { bge/getoxmlh.i } 23/VIII-2018 xmllib.i и tmpcxmlh.i вставлены напрямую
{ str/xmllib.i }
// { bge/tmpcxmlh.i } 23/VIII-2018 - уже было вставлено

{ gbl/xmlchar.i }


/*переменные контекста*/
/*это у нас объект 0*/
define variable v-current-node-code as integer no-undo .
define variable v-current-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-current-lock as integer no-undo .
define variable v-current-wait as integer no-undo .
define variable v-save as integer no-undo .
define variable log-file-name                as character      no-undo init "process-gds-grp.txt".
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
define variable v-last-rec-ord as integer no-undo .


{ rul/seterror.i }
define buffer buf_temp-cmd for temp-cmd.
define temp-table temp-gds-grp_ no-undo like ub.gds-grp.
define buffer buf_temp-xml-tables for temp-xml-tables.
define shared temp-table tt0-rule-call-param no-undo like ub.rule-call-param.


function 00130003_get-error-message returns character :
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

function 00130003_after-import_f returns logical ( input p-d-card as character):
  run 00130003_after-import in this-procedure ( input p-d-card) no-error.
  run set-error in this-procedure ( input return-value ).
  return not (error-status:error).
end function.



&scop display-message ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~).            ~
          assign v-view-log = yes



/*---------------------------&start-rule-call-param&-------------------------------*/
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
or return-value = "return" then return.

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
define variable v-current-upper-node-code as integer no-undo .
define variable v-current-node-name as character no-undo .
define variable v-calc-method as character no-undo .
define variable v-increase-pc as decimal no-undo .
define variable v-print-code  as character no-undo .
define variable v-round-method as character no-undo .
define variable v-base as decimal no-undo .

define variable v-rid as recid no-undo .

_main:
do
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:


/* ------------------------- &start-hn-option& -----------------------------------*/





/* ------------------------- &end-hn-option -----------------------------------*/


run write-log  in p-log-handle (
                                 input 0
                               , "&DLine").
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Импорт данных по группам товаров из файла &1", file-name)).
for each buf_temp-xml-tables where buf_temp-xml-tables.order >= 0:
  /*надо создать динамический query*/
  if buf_temp-xml-tables.tbl-name = "THheader" then next.
  create query v_qh.
  glog = v_qh:set-buffers( buf_temp-xml-tables.tbl-handle_) no-error.
  if error-status:error
  or
  not glog then do:
    run write-log-and-file in p-log-handle (
                                            input 1
                                          , input log-file-name
                                          , input 1
                                          , input substitute("Ошибка при попытке получить записи &1&2&3&2&4"
                                                            , buf_temp-xml-tables.tbl-name
                                                            , {&new-line}
                                                            , error-status:get-message(1)
                                                            , return-value)).
    undo _main, return error ''.
  end.
  glog = v_qh:query-prepare( substitute( "for each &1 ", buf_temp-xml-tables.tbl-name)) no-error .
  if error-status:error
  or
  not glog then do:
    run write-log-and-file in p-log-handle (
                                            input 1
                                          , input log-file-name
                                          , input 1
                                          , input substitute("Ошибка при попытке получить записи &1&2&3&2&4"
                                                            , buf_temp-xml-tables.tbl-name
                                                            , {&new-line}
                                                            , error-status:get-message(1)
                                                            , return-value)).
    undo _main, return error ''.
  end.
  glog = v_qh:query-open no-error .
  if error-status:error
  or
  not glog then do:
    run write-log-and-file in p-log-handle (
                                            input 1
                                          , input log-file-name
                                          , input 1
                                          , input substitute("Ошибка при попытке получить записи &1&2&3&2&4"
                                                            , buf_temp-xml-tables.tbl-name
                                                            , {&new-line}
                                                            , error-status:get-message(1)
                                                            , return-value)).
    undo _main, return error ''.
  end.
    _stroka:
    REPEAT:
      num-rec = num-rec + 1.
      v-retry-action = 0 .
     _release:
      do on error undo, retry:
        if  retry then do:
          v-retry-action = v-retry-action + 1.
          run write-log-and-file in p-log-handle (
                                                  input 1
                                                , input log-file-name
                                                , input 1
                                                , input substitute("Ошибка при импорте записи &5 &1&2&3&2&4"
                                                                  , buf_temp-xml-tables.tbl-name
                                                                  , num-rec
                                                                  , {&new-line}
                                                                  , error-status:get-message(1)
                                                                  , return-value)).
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
      _rule:
       do on error undo _rule, retry _rule:
         if retry then do:
            run write-log-and-file in p-log-handle (
                                                    input 1
                                                  , input log-file-name
                                                  , input 1
                                                  , input substitute("&1&2&3"
                                                                    , error-status:get-message(1)
                                                                    , {&new-line}
                                                                    , return-value)).
           next _stroka.
         end.
         else do:
          v_qh:get-next().
          IF v_qh:query-off-end then leave _stroka.

      /* ------------------------- &start-rule& -----------------------------------*/
          IF  ImpData1:current-tbl-name( ) = "gds-grp-01"  THEN do:
            v-current-node-code = ImpData1:route-data_get-field-integer( input "gds-grp-01", input "node-code") .
            v-current-upper-node-code = ImpData1:route-data_get-field-integer( input "gds-grp-01", input "upper-code") .
            v-current-node-name = ImpData1:route-data_get-field-character( input "gds-grp-01", input "node-name") .
            v-calc-method = ImpData1:route-data_get-field-character( input "gds-grp-01", input "calc-method") .
            v-round-method = ImpData1:route-data_get-field-character( input "gds-grp-01", input "round-method") .
            v-print-code = ImpData1:route-data_get-field-character( input "gds-grp-01", input "print-code") .
            v-increase-pc = ImpData1:route-data_get-field-decimal( input "gds-grp-01", input "increase-pc") .
            v-base = ImpData1:route-data_get-field-decimal( input "gds-grp-01", input "round-coef") .
            
            run ref/gdsgrp01.p ( input {&add-def}
                                ,input yes /*p-silent*/
                                ,input yes /*p-get-node-code*/
                                ,input yes /*p-fill-tax-from-upper*/
                                ,input-output v-current-node-code
                                ,input-output v-current-upper-node-code
                                ,input v-current-node-name
                                ,input v-calc-method
                                ,input v-increase-pc
                                ,input v-print-code
                                ,input v-round-method
                                ,input v-base
                                ,output v-rid ) no-error.
            if error-status:error then do:
              run write-log-and-file in p-log-handle (
                                                      input 1
                                                    , input log-file-name
                                                    , input 1
                                                    , input substitute("&1&2&3"
                                                                      , error-status:get-message(1)
                                                                      , {&new-line}
                                                                      , return-value)).
              next _stroka.
            end.
          end.

      /* ------------------------- &end-rule -------------------------------------*/
        end.
      end.
      v-retry-action = 0 .
     _release:
      do on error undo, retry:
        if  retry then do:
          v-retry-action = v-retry-action + 1.
          run write-log-and-file in p-log-handle (
                                                  input 1
                                                , input log-file-name
                                                , input 1
                                                , input substitute("&1&2&3"
                                                                  , error-status:get-message(1)
                                                                  , {&new-line}
                                                                  , v-last-error-message )).
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
      run write-counter in p-log-handle ( input substitute("Обработано строк: &1, из них удачно: &2", num-rec, num-rec-ok)).
      process events.
      run get-stop-state in p-log-handle ( output v-stop) no-error .
      if v-stop then do:
          run write-log-and-file in p-log-handle (
                                                  input 1
                                                , input log-file-name
                                                , input 1
                                                , input substitute("Процесс импорта прерван пользователем")).
         leave _stroka.
      end.
    end. /*repeat*/
    if not v-stop then do:
      num-rec = num-rec - 1.
    end.
    v_qh:query-close().
    if valid-handle(v_qh) then do:
      delete object v_qh.
    end.
  end. /*for each buf_temp-xmp-tables*/
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Обработано строк: &1, из них удачно: &2", num-rec, num-rec-ok)).
end. /*doe _main*/
end procedure. /* proc-main */

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define buffer buf_rule-call-param for tt0-rule-call-param.
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

/*---------------------------&end-process-rule-call-param&-------------------------------*/
    case p-ruleset-id:
      when 3 then do:
        assign
        v-sign = 1
        v-current-host-code = p-host-code
        v-current-obj-type = p-obj-type
        v-current-obj-code = p-obj-code
        v-current-db-num = g#db-num
        v-current-lock = (if p-save >= 0 then exclusive-lock else no-lock)
        file-name  = entry(1, p-process-file-name, {&delim-par})
        v-xmlh = buffer buf_temp-xml-tables:handle:table-handle:default-buffer-handle
        .
        run rul/rum-xmli.p  (
                             input parparentproc
                            ,input p-log-handle
                            ,input file-name
                            ,input p-profile-id
                            ,input p-xsd-file
                            ,input 0 /*p-esys-id*/
                            ,input 0 /*p-pack-num*/
                            ,input-output v_dataseth
                            ,input-output v-xmlh

                            ) no-error.
        if error-status:error then do:
          undo, return error substitute("&1&2&3"
                                          , error-status:get-message(1)
                                          , {&new-line}
                                          , return-value ).
        end.
        v-xmlh = buffer buf_temp-xml-tables:handle.
      end.
      otherwise do:
        undo, return error "Неправильный вызов".
      end.
    end case.
  end. /*doe*/

end procedure. /* load-ruleset-context */


procedure create_gds-grp_:
define input parameter p-node-code as integer no-undo .
define buffer buf_temp-gds-grp_ for temp-gds-grp_.
find first buf_temp-gds-grp_ where
          buf_temp-gds-grp_.node-code = p-node-code no-error .
if not available buf_temp-gds-grp_ then do:
  create buf_temp-gds-grp_.
  assign
  buf_temp-gds-grp_.node-code = p-node-code
  .
end.
end procedure.

procedure can-find_gds-grp_  :
define input parameter p-node-code as integer no-undo .
define output parameter p-find as logical no-undo .
find first temp-gds-grp_ where
                     temp-gds-grp_.node-code = p-node-code no-error.
p-find = available temp-gds-grp_.
end procedure.


procedure delete-procedure :

  do
  on error undo, return error
  :
      for each temp-gds-grp_:
        delete temp-gds-grp_.
      end.
      run garbcoll_clear in this-procedure .
  end.

end procedure. /* delete-procedure */

procedure 00130003_after-import :
define input  parameter p-node-code as integer no-undo .
define buffer buf_ggrp-list for ggrp-list.
/*пока пусто*/
find first buf_ggrp-list where buf_ggrp-list.node-code = p-node-code.
delete buf_ggrp-list.
end procedure.

/*не удалять!!!!*/