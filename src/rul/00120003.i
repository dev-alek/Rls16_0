/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 12

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/26/08
Author: Bakhtadze Natalya
Creation date: 05/26/08

---------------------------&start-codex_id=12;ruleset_id=3;-------------------------------
Импорт данных по клиентам из XML файла
---------------------------&end-codex_id=12;ruleset_id=3;-------------------------------

*/

/*---------------------------&start-using-class&-------------------------------*/


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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 12".
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
{ cmp/cli-list.i cli-list def "new shared" }
{ bge/tmpcxmlh.i }

// { bge/getoxmlh.i } 23/VIII-2018 xmllib.i и tmpcxmlh.i вставлены напрямую
{ str/xmllib.i }
// { bge/tmpcxmlh.i } 23/VIII-2018 - уже было вставлено

{ gbl/xmlchar.i }

/*переменные контекста*/
/*это у нас объект 0*/
define variable v-current-cli-type as character no-undo .
define variable v-current-cli-code as integer no-undo .
define variable v-current-cli-name as integer no-undo .
define variable v-current-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-current-lock as integer no-undo .
define variable v-current-wait as integer no-undo .
define variable v-save as integer no-undo .
define variable log-file-name                as character      no-undo init "process-cli-list.txt".
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
define shared temp-table tt0-rule-call-param no-undo like ub.rule-call-param.
define temp-table temp-clients_ no-undo like ub.clients.
define buffer buf_temp-xml-tables for temp-xml-tables.


function 00120003_get-error-message returns character :
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

function 00120003_after-import_f returns logical ( input p-cli-type as character, input p-cli-code as integer):
  run 00120003_after-import in this-procedure ( input p-cli-type, input p-cli-code) no-error.
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


/*---------------------------&end-rule-call-param&-------------------------------*/


/* ------------------------- &start-i-script& -----------------------------------*/


/* ------------------------- &end-i-script& -----------------------------------*/

on delete of this-procedure do:
  run delete-procedure in this-procedure .
  run gate-clear in this-procedure ( input v_dataseth, input v-xmlh) no-error.
end.

run load-ruleset-context in this-procedure ( input p-ruleset-id) no-error.
if error-status:error
or return-value = "return" then return.

/* ------------------------- &start-def-vars& -----------------------------------*/


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
define variable v-current-cli-code as integer no-undo .
define variable v-current-cli-type as character no-undo .
define variable v-current-cli-name as character no-undo .
define variable v-rid as recid no-undo .


_main:
do
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:

/*надо найти настройки маршрутизации и записи истории для клиентов*/


/* ------------------------- &start-hn-option& -----------------------------------*/





/* ------------------------- &end-hn-option& -----------------------------------*/
run write-log  in p-log-handle (
                                 input 0
                               , "&DLine").
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Импорт данных по клиентам из файла &1", file-name)).

for each buf_temp-xml-tables where
        buf_temp-xml-tables.order >= 0:
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
define buffer buf_rule-call-param for ub.rule-call-param.

  do
  on error undo, return error
  :
/*---------------------------&start-process-rule-call-param&-------------------------------*/


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

procedure create_clients_:
define input parameter p-cli-type as character no-undo .
define input parameter p-cli-code as integer no-undo .
define buffer buf_temp-clients_ for temp-clients_.
find first buf_temp-clients_ where
          buf_temp-clients_.obj-type = p-obj-type
      and buf_temp-clients_.obj-code = p-obj-code  no-error .
if not available buf_temp-clients_ then do:
  create buf_temp-clients_.
  assign
  buf_temp-clients_.obj-type = p-obj-type
  buf_temp-clients_.obj-code = p-obj-code
  .
end.
end procedure.

procedure can-find_clients_  :
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define output parameter p-find as logical no-undo .
find first temp-clinets_ where
          temp-clients_.obj-type = p-obj-type
      and temp-clients_.obj-code = p-obj-code no-error.
p-find = available temp-clients_.
end procedure.


procedure delete-procedure :

  do
  on error undo, return error
  :
      for each temp-clients_:
        delete temp-clients_.
      end.
      run garbcoll_clear in this-procedure .
  end.

end procedure. /* delete-procedure */

procedure 00120003_after-import :
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer no-undo .
define buffer buf_cli-list for cli-list.
/*пока пусто*/
find first buf_cli-list where
          buf_cli-list.obj-type = p-obj-type
     and buf_cli-list.obj-code = p-obj-code
.
delete buf_cli-list.
end procedure.

/*не удалять!!!!*/