/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 12 набор правил 3

Автор: Гридчина Полина Дмитриевна
Дата создания: 12/03/02
Author: Gridchina Polina
Creation date: 12/03/02



---------------------------&start-codex_id=12;ruleset_id=3;-----------------
Импорт рецептов из XML файла

---------------------------&end-codex_id=12;ruleset_id=3;-----------------

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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 12 набор правил 3".
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
{ bge/tmpcxmlh.i }

// { bge/getoxmlh.i } 23/VIII-2018 xmllib.i и tmpcxmlh.i вставлены напрямую
{ str/xmllib.i }
// { bge/tmpcxmlh.i } 23/VIII-2018 - уже было вставлено

{ gbl/xmlchar.i }
{ gbl/tmpreldf.i }
{ gbl/tmpreld2.i }
{ str/fbrlib.i     }
{ str/fbrcode.i    }
/*переменные контекста*/
/*это у нас объект 0*/
define variable v-current-recipe-code like recipe.recipe-code no-undo .
define variable v-current-gds-code  like ub.goods.gds-code no-undo .
define variable v-current-rcp-gds-code like ub.goods.gds-code no-undo .
define variable v-current-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-current-lock as integer no-undo .
define variable v-current-wait as integer no-undo .
define variable v-save as integer no-undo .
define variable log-file-name                as character      no-undo init "process-clients.txt".
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
define variable v-sys-recipe-code like ub.recipe.recipe-code no-undo .


{ rul/seterror.i }
define buffer buf_temp-cmd for temp-cmd.
define shared temp-table tt0-rule-call-param no-undo like ub.rule-call-param.
define temp-table temp-recipe_ no-undo like ub.recipe.
define temp-table temp-recipe-gds_ no-undo like ub.recipe-gds
field rcp-gds-code like recipe-gds.gds-code.
define buffer buf_temp-xml-tables for temp-xml-tables.
define buffer buf_temp-recipe_ for temp-recipe_.
define buffer buf_temp-recipe-gds_ for temp-recipe-gds_.



function 00200003_get-error-message returns character :
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

function 00200003_after-import_f returns logical ( input p-cli-type as character, input p-cli-code as integer):
  run 00200003_after-import in this-procedure ( input p-cli-type, input p-cli-code) no-error.
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
define variable v-rid as recid no-undo .
define variable v-current-tbl-name as character no-undo .
define buffer buf_temp-rel-handle for temp-rel-handle.
define variable glog as logical no-undo .
define variable v_child-qh as handle no-undo .
define variable v-current-firm-code as integer no-undo .



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
&scop my-message substitute("Импорт рецептов из файла &1", file-name)
{&display-message}.
run tmpreldf_get-relations in this-procedure ( input  v_dataseth).
for each buf_temp-xml-tables where
        buf_temp-xml-tables.order >= 0
    and buf_temp-xml-tables.is-parent = yes
        :
  /*надо создать динамический query*/
  if buf_temp-xml-tables.tbl-name = "THheader" then next.
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
    v-view-log = yes.
    undo _main, return error ''.
  end.
  glog = v_qh:query-prepare( substitute( "for each &1 ", buf_temp-xml-tables.tbl-name)) no-error .
  if error-status:error
  or
  not glog then do:
    &scop my-message  substitute("Ошибка при попытке получить записи &1&2&3&2&4" ~
                                , buf_temp-xml-tables.tbl-name ~
                                , ~{&new-line~} ~
                                , error-status:get-message(1) ~
                                , return-value)
    {&display-message}.
    v-view-log = yes.
    undo _main, return error ''.
  end.
  glog = v_qh:query-open no-error .
  if error-status:error
  or
  not glog then do:
    &scop my-message  substitute("Ошибка при попытке получить записи &1&2&3&2&4" ~
                              , buf_temp-xml-tables.tbl-name ~
                              , ~{&new-line~} ~
                              , error-status:get-message(1) ~
                              , return-value)
    {&display-message}.
    v-view-log = yes.
    undo _main, return error ''.
  end.
    _stroka:
    REPEAT:
      if buf_temp-xml-tables.is-parent = yes then do:
        num-rec = num-rec + 1.
      end.
      v-retry-action = 0 .
     _release:
      do on error undo, retry:
        if  retry then do:
          v-retry-action = v-retry-action + 1.
          &scop my-message  substitute("Ошибка при импорте записи &5 &1&2&3&2&4" ~
                                    , buf_temp-xml-tables.tbl-name ~
                                    , num-rec ~
                                    , ~{&new-line~} ~
                                    , error-status:get-message(1) ~
                                    , return-value)
          {&display-message}.
          v-view-log = yes.
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
           &scop my-message substitute("&1&2&3" ~
                                      , error-status:get-message(1) ~
                                      , ~{&new-line~} ~
                                      , return-value)
          {&display-message}.
          v-view-log = yes.
           next _stroka.
         end.
         else do:
          v_qh:get-next().
          IF v_qh:query-off-end then leave _stroka.

      /* ------------------------- &start-rule& -----------------------------------*/
          assign
          v-current-tbl-name = ''
          v-current-tbl-name = ImpData1:current-tbl-name( ) no-error .

          case v-current-tbl-name :
            when "recipe"  THEN do:
              v-current-recipe-code = ImpData1:route-data_get-field-character( input "recipe", input "recipe-code") .
              v-current-gds-code = ImpData1:route-data_get-field-integer( input "recipe", input "gds-code") .
              find first buf_temp-recipe_ where
                        buf_temp-recipe_.recipe-code = v-current-recipe-code
                    and buf_temp-recipe_.gds-code = v-current-gds-code no-error.
              if not available buf_temp-recipe_ then do:
                create  buf_temp-recipe_.
                assign
                buf_temp-recipe_.recipe-code = v-current-recipe-code
                buf_temp-recipe_.gds-code = v-current-gds-code
                .
              end.
              find first ub.goods where ub.goods.gds-code = buf_temp-recipe_.gds-code no-lock no-error.
              if not available ub.goods then do:
                &scop my-message  substitute("Не найден товар : &1&2. Рецепт &3" ~
                                              , buf_temp-recipe_.gds-code ~
                                              , ~{&new-line~} ~
                                              ,v-current-recipe-code )
                {&display-message}.
                next _stroka.
              end.
              assign  buf_temp-recipe_.artic = ub.goods.artic
                      buf_temp-recipe_.prod-type = ub.goods.prod-type
                      buf_temp-recipe_.prod-code = ub.goods.prod-code
              .
              assign
              glog = buffer buf_temp-recipe_:handle:buffer-copy(ImpData1:route-data_get-record("recipe"), "recipe-code,gds-code") no-error.
              if not glog
              or error-status:error then do:
                &scop my-message  substitute("Не удалось получить данные записи <recipe>: &1&2&3" ~
                                              , error-status:get-message(1) ~
                                              , ~{&new-line~} ~
                                              , return-value)
                {&display-message}.
                next _stroka.
              end.
              _rel:
              for each buf_temp-rel-handle where
                      buf_temp-rel-handle.parent-buffer_ = v-current-tbl-name:
                run tmpreld2_query in this-procedure ( buffer buf_temp-rel-handle, input-output v_child-qh) no-error.
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
                    when "recipe-gds"
                    THEN do:
                    v-current-rcp-gds-code = ImpData1:route-data_get-field-integer( buffer buf_temp-rel-handle:handle, input buf_temp-rel-handle.child-buffer_, input "rcp-gds-code") .
                      find first ub.goods where ub.goods.gds-code = v-current-rcp-gds-code no-lock no-error.
                      if not available ub.goods then do:
                        &scop my-message  substitute("Не найден товар : &1&2. Рецепт &3" ~
                                                      , v-current-rcp-gds-code ~
                                                      , ~{&new-line~} ~
                                                      ,v-current-recipe-code )
                        {&display-message}.
                        next _stroka.
                      end.
                      find first buf_temp-recipe-gds_ where
                                buf_temp-recipe-gds_.recipe-code = v-current-recipe-code
                              and  buf_temp-recipe-gds_.gds-code = v-current-gds-code
                              and  buf_temp-recipe-gds_.rcp-gds-code = v-current-rcp-gds-code
                      no-error.
                      if not available buf_temp-recipe-gds_ then do:
                        create  buf_temp-recipe-gds_.
                        assign
                             buf_temp-recipe-gds_.recipe-code = v-current-recipe-code
                             buf_temp-recipe-gds_.gds-code = v-current-gds-code
                             buf_temp-recipe-gds_.rcp-gds-code = v-current-rcp-gds-code
                             buf_temp-recipe-gds_.artic = ub.goods.artic
                             buf_temp-recipe-gds_.prod-type = ub.goods.prod-type
                             buf_temp-recipe-gds_.prod-code = ub.goods.prod-code
                        .
                      end.
                      assign
                      glog = buffer buf_temp-recipe-gds_:handle:buffer-copy(buf_temp-rel-handle.child-buffer-handle
                                                                      ,"recipe-code,gds-code,rcp-gds-code"
                                                                    ) no-error.
                      if not glog
                      or error-status:error then do:
                        &scop my-message substitute("Не удалось получить данные записи <&4>: &1&2&3" ~
                                                    , error-status:get-message(1) ~
                                                    , ~{&new-line~} ~
                                                    , return-value ~
                                                    , buf_temp-rel-handle.child-buffer_)
                        {&display-message}.
                        undo _rule, retry _rule.
                      end.
                      release buf_temp-recipe-gds_.
                    end. /*when "firm-01" */
                  end case. /*                case buf_temp-rel-handle_.child-buffer_:*/
                end. /*                    repeat:*/
                delete object v_child-qh no-error.
              end. /*              for each buf_temp-rel-handle where*/

              run check-recipe(
              buf_temp-recipe_.recipe-code,
              buf_temp-recipe_.recipe-name,
              buf_temp-recipe_.qnty,
              buf_temp-recipe_.portion-qnty,
              buf_temp-recipe_.portion-weight,
              buf_temp-recipe_.recipe-ref-num,
              buf_temp-recipe_.recipe-technique,
              output  glog,
              output  v-last-error-message
              ) no-error.

              if error-status:error  or  glog then do:
                &scop my-message substitute("Ошибка при проверке рецепта &4.&2&1&2&3" ~
                                          , error-status:get-message(1) ~
                                          , ~{&new-line~} ~
                                          , return-value +  v-last-error-message ~
                                          ,buf_temp-recipe_.recipe-code)
                {&display-message}.
                v-view-log = yes.
                next _stroka.
              end. /*if error-status:error then do:*/

              run create-new-recipe(output v-sys-recipe-code) no-error.
              if error-status:error then do:
                &scop my-message substitute("&1&2&3" ~
                                          , error-status:get-message(1) ~
                                          , ~{&new-line~} ~
                                          , return-value)
                {&display-message}.
                v-view-log = yes.
                next _stroka.
              end. /*if error-status:error then do:*/

              for each temp-recipe-gds_ where
              temp-recipe-gds_.recipe-code = v-current-recipe-code
              by temp-recipe-gds_.proc-number :
                run fbrlib-create-or-update-recipe-gds in this-procedure (
                      input v-sys-recipe-code
                    , input temp-recipe-gds_.rcp-gds-code
                    , input temp-recipe-gds_.is-waste
                    , input temp-recipe-gds_.qnty
                    , input temp-recipe-gds_.proc-number
                    , input no
                ) no-error.
                if error-status:error then do:
                  &scop my-message substitute("&1&2&3" ~
                                            , error-status:get-message(1) ~
                                            , ~{&new-line~} ~
                                            , return-value)
                  {&display-message}.
                  v-view-log = yes.
                  next _stroka.
                end. /*if error-status:error then do:*/

              end.
              if available buf_temp-recipe_ then delete buf_temp-recipe_.
              if available buf_temp-recipe-gds_ then empty temp-table buf_temp-recipe-gds_.

            end. /*when "clients-01"  THEN do:*/
          end case. /*          case v-current-tbl-name :*/
          if error-status:error then do:
            &scop my-message substitute("&1&2&3" ~
                                      , error-status:get-message(1) ~
                                      , ~{&new-line~} ~
                                      , return-value)
            {&display-message}.
            v-view-log = yes.
            next _stroka.
          end. /*if error-status:error then do:*/

      /* ------------------------- &end-rule -------------------------------------*/
        end.
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
          v-view-log = yes.
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
        if buf_temp-xml-tables.is-parent = yes then do:
          num-rec-ok = num-rec-ok + 1.
        end.
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
      if buf_temp-xml-tables.is-parent = yes then do:
        num-rec = num-rec - 1.
      end.
    end.
    v_qh:query-close().
    if valid-handle(v_qh) then do:
      delete object v_qh.
    end.
  end. /*for each buf_temp-xmp-tables*/
  &scop my-message  substitute("Обработано строк: &1, из них удачно: &2", num-rec, num-rec-ok)
  {&display-message}.
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



procedure delete-procedure :

  do
  on error undo, return error
  :
      for each temp-recipe_:
        delete temp-recipe_.
      end.
      run garbcoll_clear in this-procedure .
  end.

end procedure. /* delete-procedure */

procedure 00120003_after-import :
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer no-undo .
/*пока пусто*/
end procedure.
PROCEDURE check-recipe :
/*------------------------------------------------------------------------------
  Purpose:     проверка корректности строки или шапки
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-recipe-code        as character    no-undo.
define input parameter p-recipe-name        as character    no-undo.
define input parameter p-recipe-qnty        as decimal      no-undo.
define input parameter p-portion-qnty       as decimal      no-undo.
define input parameter p-portion-weight     as decimal      no-undo.
define input parameter p-recipe-ref-num     as character    no-undo.
define input parameter p-recipe-technique   as character    no-undo.
define output parameter p-bad-data          as logical      no-undo.
define output parameter p-error-text        as character    no-undo.

    define variable v-gds-code              as integer      no-undo.
    define variable v-unit-base             as character    no-undo.
    define variable v-is-goods              as logical      no-undo.
    define variable v-empty-scale           as logical      no-undo.
    define variable v-ingr-count            as integer      no-undo.
    define variable v-waste-count           as integer      no-undo.
    define variable v-sum-gds-qnty          as decimal      no-undo.
    define variable v-sum-gds-brutto-qnty   as decimal      no-undo.


    define buffer buf_units             for units.
    define buffer buf_other_recipe-gds  for recipe-gds.

    .
    { gbl/gdsat.i
        buf_temp-recipe_.artic
        buf_temp-recipe_.prod-type
        buf_temp-recipe_.prod-code
        'empty-scale=request':u
        v-empty-scale
    }
    { gbl/gds-code.i
        buf_temp-recipe_.artic
        buf_temp-recipe_.prod-type
        buf_temp-recipe_.prod-code
        v-gds-code
    }
    { gbl/unitbase.i
        v-gds-code
        v-unit-base
    }
    find first buf_units no-lock
         where buf_units.unit-name = v-unit-base
    .
    if p-portion-qnty < 1
    and buf_temp-recipe_.recipe-type = {&manufacturing}
    then do:
        assign
            p-bad-data   = yes
            p-error-text = "Количество порций не может быть меньше 1."
        .
        undo, return.
    end.

    if lookup( {&pieces}, buf_units.type ) > 0
    and buf_temp-recipe_.recipe-type = {&manufacturing}
    then do:
        if p-portion-qnty <> p-recipe-qnty
        then do:
            assign
                p-bad-data   = yes
                p-error-text = "Для штучного товара количество порций "
                               + {&new-line} + "должно быть равно количеству товара рецепта."
            .
            undo, return.
        end.
    end.
    if p-recipe-name = ?
    or p-recipe-name = ""
    then do:
        assign
            p-bad-data   = yes
            p-error-text = "Название рецепта не может быть пустым."
        .
        undo, return.
    end.
    if v-empty-scale = no
    then do:
        assign
            p-bad-data   = yes
            p-error-text = "В рецепте могут быть только товары без шкал."
        .
        undo, return.
    end.
    if ( buf_temp-recipe_.recipe-type = {&manufacturing}
      or buf_temp-recipe_.recipe-type = {&gathering}
      or buf_temp-recipe_.recipe-type = {&alternative} )
    and ( p-recipe-qnty <= 0
       or p-recipe-qnty = ? )
    then do:
        assign
            p-bad-data   = yes
            p-error-text = "Количество составного товара рецепта должно быть больше 0."
        .
        undo, return.
    end.
    if lookup( {&pieces}, buf_units.type ) > 0
    and ( truncate( p-recipe-qnty, 0 ) - p-recipe-qnty ) <> 0
    and buf_temp-recipe_.recipe-type <> {&alternative}
    then do:        /* при производстве может быть рецепт для вываливания из разных банок, когда эти количества имеют другой смысл - это вес содержимого банки */
        assign
            p-bad-data   = yes
            p-error-text = "Товар рецепта штучный, его количество не может быть дробным."
        .
        undo, return.
    end.
    { gbl/gdsat.i
        buf_temp-recipe_.artic
        buf_temp-recipe_.prod-type
        buf_temp-recipe_.prod-code
        'gds-goods=request':u
        v-is-goods
    }
    if buf_temp-recipe_.recipe-type = {&gathering}
    and lookup( {&pieces}, buf_units.type ) = 0
    and v-is-goods = yes
    then do:
        assign
            p-bad-data   = yes
            p-error-text = "Рецепт на комплектацию может быть составлен только для штучного товара."
        .
        undo, return.
    end.
    if buf_temp-recipe_.recipe-type = {&dressing}
    and lookup( {&weight}, buf_units.type ) = 0
    and v-is-goods = yes
    then do:
        assign
            p-bad-data   = yes
            p-error-text = "Рецепт на разделку может быть составлен только для весового товара."
        .
        undo, return.
    end.
    if lookup( {&serial}, buf_units.type ) > 0
    then do:
        assign
            p-bad-data   = yes
            p-error-text = "Для серийного товара не может быть составлен рецепт."
        .
        undo, return.
    end.
    assign
        v-ingr-count = 0
    .
    for each buf_temp-recipe-gds_
       where buf_temp-recipe-gds_.recipe-code = buf_temp-recipe_.recipe-code
    :
        if buf_temp-recipe-gds_.qnty = 0
        and buf_temp-recipe_.recipe-type <> {&dressing}
        then do:
            assign
                p-bad-data   = yes
                p-error-text = "Нулевое количество товара в строке рецепта."
                                + {&new-line} + "Артикул товара:" + buf_temp-recipe-gds_.artic
            .
            undo, return.
        end.
        if  buf_temp-recipe-gds_.artic     = buf_temp-recipe_.artic
        and buf_temp-recipe-gds_.prod-type = buf_temp-recipe_.prod-type
        and buf_temp-recipe-gds_.prod-code = buf_temp-recipe_.prod-code
        then do:
            assign
                p-bad-data   = yes
                p-error-text = "Строка рецепта не может содержать тот же товар, что и сам рецепт."
            .
            undo, return.
        end.
        { gbl/gds-code.i
            buf_temp-recipe-gds_.artic
            buf_temp-recipe-gds_.prod-type
            buf_temp-recipe-gds_.prod-code
            v-gds-code
        }
        { gbl/unitbase.i
            v-gds-code
            v-unit-base
        }
        find first buf_units no-lock
             where buf_units.unit-name = v-unit-base
        .
        if lookup( {&pieces}, buf_units.type ) > 0
        and ( truncate( buf_temp-recipe-gds_.qnty, 0 ) - buf_temp-recipe-gds_.qnty ) <> 0
        and buf_temp-recipe_.recipe-type <> {&alternative}
        then do:        /* при производстве может быть рецепт для вываливания из разных банок, когда эти количества имеют другой смысл - это вес содержимого банки */
            assign
                p-bad-data   = yes
                p-error-text = "Товар-ингредиент штучный, его количество не может быть дробным."
            .
            undo, return.
        end.
        { gbl/gdsat.i
            buf_temp-recipe-gds_.artic
            buf_temp-recipe-gds_.prod-type
            buf_temp-recipe-gds_.prod-code
            'gds-goods=request':u
            v-is-goods
        }
        if buf_temp-recipe_.recipe-type = {&gathering}
        and lookup( {&pieces}, buf_units.type ) = 0
        and v-is-goods = yes
        then do:
            assign
                p-bad-data   = yes
                p-error-text = "В рецепте на комплектацию должен быть только штучный товар."
            .
            undo, return.
        end.
        if buf_temp-recipe_.recipe-type = {&dressing}
        and lookup( {&weight}, buf_units.type ) = 0
        and v-is-goods = yes
        then do:
            assign
                p-bad-data   = yes
                p-error-text = "В рецепте на разделку должен быть только весовой товар."
            .
            undo, return.
        end.
        if lookup( {&serial}, buf_units.type ) > 0
        then do:
            assign
                p-bad-data   = yes
                p-error-text = "В рецепте не может быть серийного товара."
            .
            undo, return.
        end.
        if lookup( {&petrolium}, buf_units.type ) > 0
        then do:
            find first buf_other_recipe-gds
                 where buf_other_recipe-gds.artic        = buf_temp-recipe-gds_.artic
                   and buf_other_recipe-gds.prod-type    = buf_temp-recipe-gds_.prod-type
                   and buf_other_recipe-gds.prod-code    = buf_temp-recipe-gds_.prod-code
                   and buf_other_recipe-gds.recipe-code  <> buf_temp-recipe-gds_.recipe-code
            no-error.
            if available buf_other_recipe-gds
            then do:
                assign
                    p-bad-data   = yes
                    p-error-text = "Сервисный элемент может входить только в один рецепт."
                .
                undo, return.
            end.
        end.
        if ( buf_temp-recipe_.recipe-type <> {&petrolium-manufacturing}
            and lookup( {&petrolium}, buf_units.type ) > 0 )
        or ( buf_temp-recipe_.recipe-type = {&petrolium-manufacturing}
            and lookup( {&petrolium}, buf_units.type ) = 0 )
        then do:
            assign
                p-bad-data   = yes
                p-error-text = "Топливный товар (услуга) может входить только в топливный рецепт."
            .
            undo, return.
        end.
        assign
            v-ingr-count = v-ingr-count + 1
        .
        if buf_temp-recipe-gds_.is-waste = yes
        then do:
            assign
                v-waste-count = v-waste-count + 1
            .
        end.
        assign
            v-sum-gds-qnty          = v-sum-gds-qnty        + buf_temp-recipe-gds_.qnty
        .
    end.        /* for each buf_temp-recipe-gds_.*/
    if buf_temp-recipe_.recipe-type = {&dressing}
    and v-sum-gds-qnty <> ?
    and v-sum-gds-qnty <> buf_temp-recipe_.qnty
    then do:
        assign
            p-bad-data   = yes
            p-error-text = "В рецепте разделки сумма количеств ингредиентов"
                        + {&new-line} + "не равна количеству составного товара."
        .
        undo, return.
    end.
    if v-ingr-count = 0
    then do:
        assign
            p-bad-data   = yes
            p-error-text = "В рецепте нет ни одной строки."
        .
        undo, return.
    end.
    if buf_temp-recipe_.recipe-type = {&petrolium-manufacturing}
    and v-ingr-count <> 1
    then do:
        assign
            p-bad-data   = yes
            p-error-text = "В топливном рецепте должна быть ровно 1 строка."
        .
        undo, return.
    end.
    if buf_temp-recipe_.recipe-type = {&dressing}
    and v-ingr-count = 1
    then do:
        assign
            p-bad-data   = yes
            p-error-text = "В рецепте разделки не может быть только 1 строка."
        .
        undo, return.
    end.
    if v-ingr-count = v-waste-count
    then do:
        assign
            p-bad-data   = yes
            p-error-text = "Рецепт не может состоять из одних отходов."
        .
        undo, return.
    end.
    if   buf_temp-recipe_.host-code <> 0 then do:
      find first ub.clients where
          ub.clients.obj-type = buf_temp-recipe_.obj-type
          and ub.clients.obj-code = buf_temp-recipe_.obj-code
          and ub.clients.host-code = buf_temp-recipe_.host-code
          no-lock no-error.
      if not available ub.clients then do:
        assign
            p-bad-data   = yes
            p-error-text = substitute("Не найден объект &1&2 для фирмы &3.")
        .
        undo, return.

      end.
    end.
end.
END PROCEDURE.
PROCEDURE create-new-recipe :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-sys-recipe-code like ub.recipe.recipe-code.
do
on error undo, return error
:

find first ub.goods where ub.goods.gds-code = buf_temp-recipe_.gds-code no-lock no-error.
if not available ub.goods then do:
  return error substitute("Не найден товар &1,p-gds-code").
end.
define buffer buf_recipe        for recipe.

    create buf_recipe .
    assign
        buf_recipe.recipe-code   = string( next-value( s-recipe, {&db-name_schema} ) )
        buf_recipe.recipe-type         = buf_temp-recipe_.recipe-type
        buf_recipe.recipe-name         = ub.goods.gds-name
        buf_recipe.qnty                = 1.0
        buf_recipe.portion-qnty        = 1
        buf_recipe.gds-code            = buf_temp-recipe_.gds-code
        buf_recipe.is-default          = buf_temp-recipe_.is-default
        buf_recipe.artic               = ub.goods.artic
        buf_recipe.prod-type           = ub.goods.prod-type
        buf_recipe.prod-code           = ub.goods.prod-code
        buf_recipe.host-code           = buf_temp-recipe_.host-code
        buf_recipe.obj-type            = if buf_temp-recipe_.host-code = 0 then '' else buf_temp-recipe_.obj-type
        buf_recipe.obj-code            = if buf_temp-recipe_.host-code = 0 then 0 else buf_temp-recipe_.obj-code
        buf_recipe.recipe-design       = buf_temp-recipe_.recipe-design
        buf_recipe.recipe-order        = 0
        buf_recipe.recipe-quality      = buf_temp-recipe_.recipe-quality
        buf_recipe.recipe-ref-num      = buf_temp-recipe_.recipe-ref-num
        buf_recipe.recipe-technique    = buf_temp-recipe_.recipe-technique
    .
p-sys-recipe-code = buf_recipe.recipe-code.
end.
END PROCEDURE. /* create-new-recipe */

/*не удалять!!!!*/