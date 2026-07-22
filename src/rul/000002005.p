/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 11 набор правил 3

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/30/08
Author: Bakhtadze Natalya
Creation date: 10/30/08


---------------------------&start-codex_id=11;ruleset_id=3;-----------------
Импорт данных по товарам из XML файла

---------------------------&end-codex_id=11;ruleset_id=3;-----------------

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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 11 набор правил 3".
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
{ cmp/gds-list.i gds-list def "SHARED" }
{ bge/tmpcxmlh.i }

// { bge/getoxmlh.i } 23/VIII-2018 xmllib.i и tmpcxmlh.i вставлены напрямую
{ str/xmllib.i }
// { bge/tmpcxmlh.i } 23/VIII-2018 - уже было вставлено

{ gbl/xmlchar.i }
{ gbl/tmpreldf.i }
{ gbl/tmpreld2.i }
{ gbl/thbj-def.i }
{ str/tt-tax.i "new shared" tt-tax full }
{ cmp/t-tnved.i "new"  }
{ ref/gds-attr.i }
{ ref/fbrglib.i }
/*переменные контекста*/
/*это у нас объект 0*/
define variable v-current-gds-code as integer no-undo .
define variable v-current-mode as character no-undo .
define variable v-current-artic as character no-undo .
define variable v-current-prod-type as character no-undo .
define variable v-current-prod-code as integer no-undo .
define variable v-current-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-current-lock as integer no-undo .
define variable v-current-wait as integer no-undo .
define variable v-save as integer no-undo .
define variable log-file-name                as character      no-undo init "process-gds-list.txt".
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
define variable v-last-rec-ord as integer no-undo .
define variable dif-nam1 as logical no-undo init yes.
define variable dif-nam2 as logical no-undo init no.
define variable dif-pdbc as logical no-undo init no.
/*настройка - уникальный цифровой артикул + ДОПБК = артикулу*/
define variable unq-artc as logical no-undo init no.
define variable is-prt  as logical no-undo .
define variable is-jwlr as logical no-undo.
define variable is-bttl as logical no-undo.
define variable is-ptrl as logical no-undo.
define variable custvalue      as character no-undo.

{ rul/seterror.i }
define buffer buf_temp-cmd for temp-cmd.
define shared temp-table tt0-rule-call-param no-undo like ub.rule-call-param.
define temp-table temp-goods_ no-undo like ub.goods
field fbr-grp-name  as character
field prt-root-name as character
field prod-name as character
field vat-pc as decimal
field mode as character
field alc-type-code  like ub.alc-type-gds.alc-type-inner-code.
define temp-table temp-bar-code_ no-undo like ub.bar-code
field node-name as character
.
define temp-table temp-prod-bc_ no-undo like ub.prod-bc.
define temp-table temp-goods-attr no-undo like ub.goods-attr.
define buffer buf_temp-xml-tables for temp-xml-tables.
    /* Переменные для атрибутов для заказа */
define variable v-prop-obj-type              like  ub.gds-obj-prop.obj-type no-undo.
define variable v-prop-obj-code              like  ub.gds-obj-prop.obj-code no-undo.
define variable v-gdop-igt                   like  ub.gds-obj-prop.gdop-igt no-undo.
define variable v-gdop-assort-min            like  ub.gds-obj-prop.gdop-assort-min  no-undo.
define variable v-gdop-min-stock             like  ub.gds-obj-prop.gdop-min-stock   no-undo.
define variable v-grop-level-always-presence like  ub.gds-obj-prop.grop-level-always-presence  no-undo.
define variable v-grop-max-stock             like  ub.gds-obj-prop.grop-max-stock              no-undo.
define variable v-grop-min-order             like  ub.gds-obj-prop.grop-min-order              no-undo.
DEFINE TEMP-TABLE tt0-gds-obj-prop NO-UNDO LIKE ub.gds-obj-prop.
DEFINE TEMP-TABLE tt0-gds-obj-prop-attr NO-UNDO LIKE ub.gds-obj-prop-attr.
define buffer buf_tt0-gds-obj-prop_ for  tt0-gds-obj-prop.
define buffer buf_tt0-gds-obj-prop-attr_ for  tt0-gds-obj-prop-attr.
define variable v-recid as recid no-undo.
{ ref/gds-ind1.i gds-obj-prop-attr }
define buffer bb_alc-type-gds for ub.alc-type-gds.
define buffer buf_goods for ub.goods.
define buffer buf_temp-goods-attr_ for temp-goods-attr.


function 00110003_get-error-message returns character :
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

function 00110003_after-import_f returns logical ( input p-d-card as character):
  run 00110003_after-import in this-procedure ( input p-d-card) no-error.
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
define variable v-rid as recid no-undo .
define variable v-current-tbl-name as character no-undo .
define variable v_qh as handle no-undo .
define variable v_child-qh as handle no-undo .
define variable glog as logical no-undo .
define variable v-ii as integer no-undo .
define variable v-current-b-code as integer no-undo .
define variable v-current-b-str as character no-undo .
define variable v-attr-list as character no-undo .
define variable v-attr-value as character no-undo .
define buffer buf_temp-goods_ for temp-goods_.
define buffer buf_temp-bar-code_ for temp-bar-code_.
define buffer buf_temp-prod-bc_ for temp-prod-bc_.
/*define buffer buf_temp-goods-attr_ for temp-goods-attr.*/
define buffer buf_temp-rel-handle for temp-rel-handle.
/*define buffer buf_goods for ub.goods.*/


_main:
do
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:


/* ------------------------- &start-hn-option& -----------------------------------*/





/* ------------------------- &end-hn-option -----------------------------------*/

v-attr-list = {&attr-alcohol-prod} + {&delim-par} +
              {&attr-fasovka} + {&delim-par} +
              {&attr-15x80} + {&delim-par}  +
              {&attr-8x50} + {&delim-par} +
              {&attr-6x50} .


run write-log  in p-log-handle (
                                 input 0
                               , "&DLine").
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Импорт данных по товарам из файла &1", file-name)).
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
    &scop my-message substitute("Ошибка при попытке получить записи &1&2&3" ~
                              , buf_temp-xml-tables.tbl-name ~
                              , ~{&new-line~} ~
                              , error-status:get-message(1))
    {&display-message}.
    v-view-log = yes.
    undo _main, return error ''.
  end.
  glog = v_qh:query-prepare( substitute( "for each &1 ", buf_temp-xml-tables.tbl-name)) no-error .
  if error-status:error
  or
  not glog then do:
    &scop my-message substitute("Ошибка при попытке получить записи &1&2&3" ~
                              , buf_temp-xml-tables.tbl-name  ~
                              , ~{&new-line~} ~
                              , error-status:get-message(1))
    {&display-message}.
    v-view-log = yes.
    undo _main, return error ''.
  end.
  glog = v_qh:query-open no-error .
  if error-status:error
  or
  not glog then do:
    &scop my-message substitute("Ошибка при попытке получить записи &1&2&3" ~
                                , buf_temp-xml-tables.tbl-name ~
                                , ~{&new-line~} ~
                                , error-status:get-message(1))
    {&display-message}.
    v-view-log = yes.
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
           &scop my-message  substitute("&1&2&3"   ~
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
            when "goods-01"  THEN do:
              empty temp-table buf_temp-goods_.
              empty temp-table buf_temp-bar-code_.
              empty temp-table buf_temp-prod-bc_.
              empty temp-table buf_temp-goods-attr_.
              empty temp-table buf_tt0-gds-obj-prop_.
              empty temp-table buf_tt0-gds-obj-prop-attr_.

              /*то что приняли можем сохранить*/
              v-current-gds-code = ImpData1:route-data_get-field-integer( input "goods-01", input "gds-code") .
              v-current-mode = ImpData1:route-data_get-field-character( input "goods-01", input "mode") .
              v-current-artic = ImpData1:route-data_get-field-character( input "goods-01", input "artic") .
              v-current-prod-type = ImpData1:route-data_get-field-character( input "goods-01", input "prod-type") .
              v-current-prod-code = ImpData1:route-data_get-field-integer( input "goods-01", input "prod-code") .
              find first buf_goods no-lock where
                        buf_goods.gds-code = v-current-gds-code no-error.
              if available buf_goods and v-current-mode = 'add':U then do:
                &scop my-message substitute("Уже есть товар с кодом &1. Пропускаем ...", v-current-gds-code)
                {&display-message}.
                next _stroka.
              end.
              if not available buf_goods then do:
                find first buf_goods no-lock where
                           buf_goods.artic     = v-current-artic     and
                           buf_goods.prod-type = v-current-prod-type and
                           buf_goods.prod-code = v-current-prod-code no-error.
                if not available buf_goods and v-current-mode = 'upd':U then do :
                  &scop my-message substitute("Не найден товар с артикулом &1 для изменения. Пропускаем ...", v-current-artic)
                  {&display-message}.
                  next _stroka.
                end.
                if available buf_goods and v-current-mode = 'add':U then do:
                  &scop my-message substitute("Уже есть товар с артикулом &1 для изменения. Пропускаем ...", v-current-artic)
                  {&display-message}.
                  next _stroka.
                end.
              end.

              find first buf_temp-goods_ where
                        buf_temp-goods_.gds-code = v-current-gds-code no-error.
              if not available buf_temp-goods_ then do:
                find first buf_temp-goods_ where
                         buf_temp-goods_.artic = v-current-artic
                     and buf_temp-goods_.prod-type = v-current-prod-type
                     and buf_temp-goods_.prod-code = v-current-prod-code
                     no-error.
                if not available buf_temp-goods_ then do:
                  create  buf_temp-goods_.
                  assign
                  buf_temp-goods_.gds-code = v-current-gds-code
                  buf_temp-goods_.artic = v-current-artic
                  buf_temp-goods_.prod-type = v-current-prod-type
                  buf_temp-goods_.prod-code = v-current-prod-code
                  .
                end.
              end.
              assign
              glog = buffer buf_temp-goods_:handle:buffer-copy(ImpData1:route-data_get-record("goods-01"), "gds-code,artic,prod-type,prod-code") no-error.
              if not glog
              or error-status:error then do:
                &scop my-message  substitute("Не удалось получить данные записи <goods-01>: &1&2&3" ~
                                                                        , error-status:get-message(1) ~
                                                                        , ~{&new-line~} ~
                                                                        , return-value)
                {&display-message}.
                v-view-log = yes.
                next _stroka.
              end.
              if v-current-mode = 'add' then do :
                if buf_temp-goods_.grp-code = 0 or buf_temp-goods_.grp-code = ? then do :
                  &scop my-message "Не указан код группы. Пропускаем..."
                  {&display-message}.
                  next _stroka.
                end.
                if buf_temp-goods_.alpha1 = ""  or buf_temp-goods_.alpha1 = ?   then do :
                  &scop my-message "Не указан код страны. Пропускаем..."
                  {&display-message}.
                  next _stroka.
                end.
                if buf_temp-goods_.unit-base = "" or buf_temp-goods_.unit-base = ? then do :
                  &scop my-message "Не указана единица измерения. Пропускаем..."
                  {&display-message}.
                  next _stroka.
                end.
                if buf_temp-goods_.prt-root = ? then do :
                  &scop my-message "Не указана шкала. Пропускаем..."
                  {&display-message}.
                  next _stroka.
                end.
                if buf_temp-goods_.gds-name = "" or buf_temp-goods_.gds-name = ? then do :
                  &scop my-message "Не указано название. Пропускаем..."
                  {&display-message}.
                  next _stroka.
                end.
              end.
              do v-ii = 1 to num-entries(v-attr-list, {&delim-par}):
                v-attr-value = ImpData1:route-data_get-field-character( input "goods-01", input ("attr-" + entry(v-ii, v-attr-list, {&delim-par}))) .
                if v-attr-value <> ? then do:
                  create buf_temp-goods-attr_.
                  assign
                  buf_temp-goods-attr_.gds-code = v-current-gds-code
                  buf_temp-goods-attr_.attr-code  = entry(v-ii, v-attr-list, {&delim-par} )
                  buf_temp-goods-attr_.attr-value = v-attr-value
                  .
                end.
              end.
              release buf_temp-goods_ .
              for each buf_temp-rel-handle where
                      buf_temp-rel-handle.parent-buffer_ = v-current-tbl-name:
                run tmpreld2_query in this-procedure ( buffer buf_temp-rel-handle, input-output v_child-qh) no-error.
                if error-status:error then do:
                  &scop my-message substitute("Не удалось получить записи &1 для &2&3&4&3&5" ~
                                              , buf_temp-rel-handle.child-buffer_ ~
                                              , v-current-tbl-name ~
                                              , ~{&new-line~} ~
                                              , error-status:get-message(1)  ~
                                              , return-value )
                  {&display-message}.
                  v-view-log = yes.
                end.
                _child:
                repeat:
                  v_child-qh:get-next().
                  IF v_child-qh:query-off-end then leave _child.
                  _child-stroka:
                  do on error undo _child-stroka, retry _child-stroka:
                    if retry then do:
                      &scop my-message  substitute("&1&2&3"   ~
                                                    , error-status:get-message(1) ~
                                                    , ~{&new-line~} ~
                                                    , return-value)
                        {&display-message}.
                        v-view-log = yes.
                      next _stroka.
                    end.
                    else do:
                      case buf_temp-rel-handle.child-buffer_:
                        when "bar-code-01"
                        THEN do:
                          v-current-b-code = ImpData1:route-data_get-field-integer( buffer buf_temp-rel-handle:handle, input buf_temp-rel-handle.CHILD-BUFFER_, input "b-code") .
                          find first buf_temp-bar-code_ where
                                    buf_temp-bar-code_.b-code = v-current-b-code no-error.
                          if not available buf_temp-bar-code_ then do:
                            create  buf_temp-bar-code_.
                            assign
                            buf_temp-bar-code_.b-code = v-current-b-code
                            .
                          end.
                          assign
                          glog = buffer buf_temp-bar-code_:handle:buffer-copy( buf_temp-rel-handle.child-buffer-handle
                                                                            , "b-code") no-error.
                          if not glog
                          or error-status:error then do:
                            &scop my-message substitute("Не удалось получить данные записи <bar-code-01>: &1&2&3" ~
                                                        , error-status:get-message(1) ~
                                                        , ~{&new-line~} ~
                                                        , return-value)
                            {&display-message}.
                            v-view-log = yes.
                            next _stroka.
                          end.
                          release buf_temp-bar-code_ .
                        end. /*when "bar-code-01"   */
                        when "prod-bc-01"
                        THEN do:
                          v-current-b-code = ImpData1:route-data_get-field-integer( buffer buf_temp-rel-handle:handle, input buf_temp-rel-handle.CHILD-BUFFER_, input "b-code") .
                          v-current-b-str = ImpData1:route-data_get-field-character( buffer buf_temp-rel-handle:handle, input buf_temp-rel-handle.CHILD-BUFFER_, input "b-str") .
                          find first buf_temp-prod-bc_ where
                                    buf_temp-prod-bc_.b-code = v-current-b-code
                                and buf_temp-prod-bc_.b-str = v-current-b-str    no-error.
                          if not available buf_temp-prod-bc_ then do:
                            create  buf_temp-prod-bc_.
                            assign
                            buf_temp-prod-bc_.b-code = v-current-b-code
                            buf_temp-prod-bc_.b-str = v-current-b-str
                            .
                          end.
                          assign
                          glog = buffer buf_temp-prod-bc_:handle:buffer-copy(buf_temp-rel-handle.child-buffer-handle
                                                                          , "b-code,b-str") no-error.
                          if not glog
                          or error-status:error then do:
                            &scop my-message substitute("Не удалось получить данные записи <prod-bc-01>: &1&2&3" ~
                                                        , error-status:get-message(1) ~
                                                        , ~{&new-line~} ~
                                                        , return-value)
                            {&display-message}.
                            v-view-log = yes.
                            next _stroka.
                          end.
                          release buf_temp-prod-bc_ .
                        end. /*when "prod-bc-01"   */
                        when "gds-obj-prop" then do:
                          v-prop-obj-code = ImpData1:route-data_get-field-integer( buffer buf_temp-rel-handle:handle, input buf_temp-rel-handle.CHILD-BUFFER_, input "obj-code") .
                          v-prop-obj-type = ImpData1:route-data_get-field-character( buffer buf_temp-rel-handle:handle, input buf_temp-rel-handle.CHILD-BUFFER_, input "obj-type") .
                          find first  buf_tt0-gds-obj-prop_ where
                                     buf_tt0-gds-obj-prop_.obj-type = v-prop-obj-type
                                and  buf_tt0-gds-obj-prop_.obj-code = v-prop-obj-code    no-error.
                          if not available buf_tt0-gds-obj-prop_ then do:
                            create  buf_tt0-gds-obj-prop_.
                            assign
                            buf_tt0-gds-obj-prop_.obj-type = v-prop-obj-type
                            buf_tt0-gds-obj-prop_.obj-code = v-prop-obj-code
                            buf_tt0-gds-obj-prop_.gds-code = v-current-gds-code
                            .
                          end.
                          assign
                          glog = buffer buf_tt0-gds-obj-prop_:handle:buffer-copy(buf_temp-rel-handle.child-buffer-handle
                                                                          , "gds-code,obj-type,obj-code") no-error.
                          if not glog
                          or error-status:error then do:
                            &scop my-message substitute("Не удалось получить данные записи <gds-obj-prop>: &1&2&3" ~
                                                        , error-status:get-message(1) ~
                                                        , ~{&new-line~} ~
                                                        , return-value)
                            {&display-message}.
                            v-view-log = yes.
                            next _stroka.
                          end.
                          release buf_temp-prod-bc_ .
                        end.  /* when gds-obj-prop */
                      end case. /*                case buf_temp-rel-handle_.child-buffer_:*/
                    end. /*else do: if not retry*/
                  end. /*                  do while true:*/
                end. /*repeat*/
                delete object v_child-qh no-error.
              end. /*              for each buf_temp-rel-handle where*/
              /*блок сохранения в БД*/
              run proc-save in this-procedure no-error.
              if error-status:error then do:
                &scop my-message substitute("Ошибка при  проверке и/или сохранении данных по товару с кодом &1", v-current-gds-code)
                {&display-message}.
                v-view-log = yes.
                next _stroka.
              end.
            end. /*when "goods-01"  THEN do:*/
          end case. /*          case v-current-tbl-name :*/
          if error-status:error then do:
            &scop my-message  substitute("&1&2&3"       ~
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
          &scop my-message  substitute("&1&2&3"       ~
                                      , error-status:get-message(1) ~
                                      , ~{&new-line~} ~
                                      , v-last-error-message)
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
        num-rec-ok = num-rec-ok + 1.
      end.
      run write-counter in p-log-handle ( input substitute("Обработано записей <goods-01> : &1, из них удачно: &2", num-rec, num-rec-ok)).
      process events.
      run get-stop-state in p-log-handle ( output v-stop) no-error .
      if v-stop then do:
        &scop my-message substitute("Процесс импорта прерван пользователем")
        {&display-message}.
        v-view-log = yes.
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
  &scop my-message substitute("Обработано строк: &1, из них удачно: &2", num-rec, num-rec-ok)
  {&display-message}.
end. /*doe _main*/
end procedure. /* proc-main */

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define buffer buf_rule-call-param for tt0-rule-call-param.
do
on error undo, return error
:

run proc-settings in this-procedure (
 input-output unq-artc
,input-output dif-nam1
,input-output dif-nam2
,input-output dif-pdbc
,input-output custvalue
,input-output is-prt
,input-output is-jwlr
,input-output is-bttl
,input-output is-ptrl
) no-error .

if error-status:error then undo, return error return-value .


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
      for each temp-prod-bc_:
        delete temp-prod-bc_.
      end.
      for each temp-bar-code_:
        delete temp-bar-code_.
      end.
      run garbcoll_clear in this-procedure .
  end.

end procedure. /* delete-procedure */

procedure 00110003_after-import :
define input  parameter p-gds-code as integer no-undo .
define buffer buf_gds-list for gds-list.
/*пока пусто*/
find first buf_gds-list where
          buf_gds-list.gds-code = p-gds-code no-error
.
if available buf_gds-list then
delete buf_gds-list.
end procedure.


procedure proc-save :
define variable v-fbr-gds-grp-f-name as character no-undo .
define variable v-gds-rec as recid no-undo .
define variable nbc as integer no-undo .
define variable v-err-mess as character no-undo .
define variable v-rid as integer no-undo .
define variable v-b-str as character no-undo .

define buffer buf_temp-goods_ for temp-goods_.
define buffer buf_temp-bar-code_ for temp-bar-code_.
define buffer buf_temp-prod-bc_ for temp-prod-bc_.
/*define buffer buf_temp-goods-attr_ for temp-goods-attr.*/

define buffer buf_gds-prt for ub.gds-prt.
define buffer bc_gds-prt for ub.gds-prt.
define buffer buf_clients for ub.clients.
define buffer buf_fbr-gds-grp for ub.fbr-gds-grp.
/*define buffer buf_goods for ub.goods.*/

main-block:
do transaction
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
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
    find first buf_temp-goods_.
    /*проверки*/
    find first buf_clients no-lock where
              buf_clients.obj-type = buf_temp-goods_.prod-type
          and buf_clients.obj-code = buf_temp-goods_.prod-code no-error .
    if not available buf_clients
    or buf_clients.obj-name <> buf_temp-goods_.prod-name then do:
      v-err-mess =  substitute("Не найден производитель &1&2 для товара c кодом &3&4или его наименование не совпадает с наименованием производителя в товаре&4(&5)"
                                    , buf_temp-goods_.prod-type
                                    , buf_temp-goods_.prod-code
                                    , buf_temp-goods_.gds-code
                                    ,{&new-line}
                                    , buf_temp-goods_.prod-name).
      undo main-block, retry main-block.
    end.
    find first buf_gds-prt no-lock WHERE
              buf_gds-prt.upper-code = buf_temp-goods_.prt-root no-error.
    if not available buf_gds-prt
    or buf_gds-prt.node-name <> buf_temp-goods_.prt-root-name
    then do:
      v-err-mess = substitute("Не найден корень шкалы  &1 для товара с кодом &2&3или его название не совпадает с названием корня шкалы в товаре (&4)"
                                    , buf_temp-goods_.prt-root
                                    , buf_temp-goods_.gds-code
                                    ,{&new-line}
                                    , buf_temp-goods_.prt-root-name).
      undo main-block, retry main-block.
    end.
    v-fbr-gds-grp-f-name = ''.
    release buf_fbr-gds-grp no-error.
    if buf_temp-goods_.fbr-grp-code <> 0
    and buf_temp-goods_.fbr-grp-code <> ? then do:
      find first buf_fbr-gds-grp no-lock where
                buf_fbr-gds-grp.node-code = buf_temp-goods_.fbr-grp-code no-error.
      if available buf_fbr-gds-grp  then do:
        run fbrglib-get-full-name in this-procedure (
                                                        input ''
                                                      ,input 0
                                                      ,input buf_fbr-gds-grp.node-code
                                                      ,output v-fbr-gds-grp-f-name).

      end.
      if not available buf_fbr-gds-grp
      or v-fbr-gds-grp-f-name <> buf_temp-goods_.fbr-grp-name then do:
        v-err-mess = substitute("Не найдена группа блюд  &1 для товара с кодом &2&3или ее полное название не совпадает с названием группы блюд в товаре (&4)"
                                      , buf_temp-goods_.fbr-grp-code
                                      , buf_temp-goods_.gds-code
                                      ,{&new-line}
                                      , buf_temp-goods_.fbr-grp-name).
        undo main-block, retry main-block.
      end.
    end.
    for each buf_temp-bar-code_:
      /*проверка на code-range*/
      find first bc_gds-prt no-lock where
                bc_gds-prt.node-code = buf_temp-bar-code_.node-code no-error.
      if not available bc_gds-prt
      or buf_temp-bar-code_.node-name <> bc_gds-prt.f-name
      then do:
        v-err-mess = substitute("Не найден узел шкалы  &1 для бар-кода &2 товара с кодом &3&4" +
                                      "или его полное название не совпадает с названием узла шкалы в бар-коде (&5)&4"
                                      , buf_temp-bar-code_.node-code
                                      , buf_temp-bar-code_.b-code
                                      , buf_temp-goods_.gds-code
                                      ,{&new-line}
                                      , buf_temp-bar-code_.node-name).
        undo main-block, retry main-block.
      end.
    end.
    assign
    nbc = 0
  /*  v-gds-rec = ?  */
    .
    v-gds-rec = recid(buf_goods) no-error.
    for each tt-tax:
      delete tt-tax.
    end.
    run ref/dtaxgdss.p (
          input yes /*p-silent*/
        , input /*par-unit-base*/  buf_temp-goods_.unit-base
        , input /*par-node-code*/  buf_temp-goods_.grp-code
        , input ?
        , input ?
        , input /*par-host-code*/  0
        , input /*par-obj-type*/   ''
        , input /*par-obj-code*/  0
          ) no-error.
    if error-status:error then do:
      v-err-mess = substitute("Ошибки при определении налогов на товар:&1&2&1&3"
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value ).
      undo main-block, retry main-block.
    end.
    run ref/goods01.p (
                  input parparentproc
                  ,input if v-current-mode = 'add':U then {&add-def} else {&update}
                  ,input no /*copymode*/
                  ,input 2 /*pmode*/
                  ,input no /*par-manual*/
                  ,input yes /*par-silence*/
                  ,input yes /*import*/
                  ,input yes /*par-file*/
                  ,input no /*one-good*/
                  ,input v-current-host-code
                  ,input v-current-obj-type
                  ,input v-current-obj-code
                  ,input (buf_temp-goods_.gds-type = {&gds-goods})
                  ,input ? /*par-cope-rec*/
                  ,input buf_temp-goods_.gds-code
                  ,input buf_temp-goods_.artic
                  ,input buf_temp-goods_.prod-type
                  ,input buf_temp-goods_.prod-code
                  ,input buf_gds-prt.node-code
                  ,input buf_temp-goods_.grp-code
                  ,input buf_temp-goods_.gds-name
                  ,input '' /*saved-name*/
                  ,input buf_temp-goods_.engl-name
                  ,input buf_temp-goods_.label-name
                  ,input buf_temp-goods_.chk-name
                  ,input buf_temp-goods_.alpha1
                  ,input buf_temp-goods_.unit-base
                  ,input buf_temp-goods_.unit-cli
                  ,INPUT buf_temp-goods_.max-rate
                  ,INPUT buf_temp-goods_.min-rate
                  ,INPUT buf_temp-goods_.cli-base-rate
                  ,input buf_temp-goods_.qnty-cart
                  ,input buf_temp-goods_.ms-base
                  ,input buf_temp-goods_.wt-base
                  ,input buf_temp-goods_.ms-cart
                  ,input buf_temp-goods_.wt-cart
                  ,input buf_temp-goods_.calc-method
                  ,input buf_temp-goods_.increase-pc
                  ,input buf_temp-goods_.Negative-rest
                  ,input 0.0 /*par-obj-price-base*/
                  ,input 0.0 /*par-obj-price-rubl*/
                  ,input buf_temp-goods_.okdp
                  ,input buf_temp-goods_.destin
                  ,input buf_temp-goods_.attrib
                  ,input buf_temp-goods_.user-rule
                  ,input buf_temp-goods_.sert
                  ,input buf_temp-goods_.struct
                  ,input buf_temp-goods_.deadline
                  ,input buf_temp-goods_.cond-keep-code
                  ,input buf_temp-goods_.sort
                  ,input buf_temp-goods_.proof
                  ,input buf_temp-goods_.normal-wastage
                  ,input buf_temp-goods_.normal-waste
                  ,input buf_temp-goods_.tnved
                  ,input buf_temp-goods_.nationality
                  ,input buf_temp-goods_.unit-cst
                  ,input buf_temp-goods_.cst-base-rate
                  ,input (if available buf_fbr-gds-grp then buf_fbr-gds-grp.node-code else ?)
                  ,input buf_temp-goods_.PS
                  ,input unq-artc
                  ,input is-jwlr
                  ,input is-bttl
                  ,input is-ptrl
                  ,input custvalue
                  ,input dif-nam1
                  ,input dif-nam2
                  ,input FALSE /*ArtDis*/
                  ,input if (buf_temp-goods_.gds-code = 0 or buf_temp-goods_.gds-code = ?) then 0    else 2     /*par-BarDis*/
                  ,input-output v-gds-rec
                  ,output nbc
                  ) no-error .
    if error-status:error then do:
      v-err-mess = substitute("Ошибки при сохранении товара c кодом &1:&2&3&2&4"
                              , buf_temp-goods_.gds-code
                              , {&new-line}
                              , error-status:get-message(1)
                              , return-value ).
      undo main-block, retry main-block.
    end.

    find first buf_goods share-lock where
              recid(buf_goods) = v-gds-rec .

    for each buf_temp-goods-attr_ where
            buf_temp-goods-attr_.gds-code = buf_temp-goods_.gds-code
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      run gds-attr-write in this-procedure (
                                             input buf_goods.gds-code   /* buf_temp-goods_.gds-code  */
                                            ,input buf_temp-goods-attr_.attr-code
                                            ,input buf_temp-goods-attr_.attr-value
                                            ) no-error.
      if error-status:error then do:
        v-err-mess = substitute("Ошибки при сохранении атрибута товара:&1&2&1&3"
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value ).
        undo main-block, retry main-block.
      end.
    end.
    find first buf_temp-bar-code_ where
              buf_temp-bar-code_.gds-code = buf_temp-goods_.gds-code
          and buf_temp-bar-code_.unit-cli = buf_temp-goods_.unit-base
          and buf_temp-bar-code_.node-code = buf_gds-prt.node-code
          and buf_temp-bar-code_.in-code = ''
          and buf_temp-bar-code_.part-code = '' no-error.
/*    if not available buf_temp-bar-code_ then do:
      v-err-mess =  substitute("Не найден главный бар-код для импортируемого товара с кодом &1", buf_temp-goods_.gds-code).
      undo main-block, retry main-block.
    end.         */
    for each buf_temp-bar-code_ where
            buf_temp-goods_.gds-code = buf_temp-goods_.gds-code
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      if buf_temp-bar-code_.b-code <> buf_temp-bar-code_.gds-code then do:
        run ref/barcode1.p (
          input ({&add-def} + {&comma-char} + {&add-import})
        ,input yes /*p-silent*/
        ,input buf_temp-bar-code_.b-code
        ,input buf_temp-bar-code_.gds-code
        ,input buf_temp-bar-code_.node-code
        ,input '':U /*p-part-code*/
        ,input '':U /*p-in-code*/
        ,input buf_temp-bar-code_.unit-cli
        ,input buf_temp-bar-code_.cli-base-rate
        ,output v-rid
        )
        no-error.
      end.

      for each buf_temp-prod-bc_ where
              buf_temp-prod-bc_.b-code = buf_temp-bar-code_.b-code
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
      :
          v-b-str = buf_temp-prod-bc_.b-str.
          run trg/prod-bc1.p (
                              input parparentproc
                            ,input yes /*p-silent*/
                            ,input no /*dif-pdbc*/
                            ,input no /*pbc-veto*/
                            ,input no /*send-ref*/
                            ,input '' /*p-cdrg-type*/
                            ,input '' /*ean-type*/
                            ,buffer buf_goods
                            ,input buf_temp-bar-code_.b-code
                            ,input-output v-b-str
                            ,output v-rid
                        ) no-error .
          if error-status :error then do:
            v-err-mess = substitute("Ошибка при сохранении prod-bc &1 (бар-код &2) &3&4&3&5"
                                      , buf_temp-prod-bc_.b-str
                                      , buf_temp-prod-bc_.b-code
                                      , {&new-line}
                                      , error-status:get-message(1)
                                      , return-value
                                      ).
            undo main-block, retry main-block.
          end.
      end.
    end.
      for each buf_tt0-gds-obj-prop_  where
      buf_tt0-gds-obj-prop_.gds-code = buf_temp-goods_.gds-code
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
      :
          run gds-ind1
              (input-output v-recid
              ,buf_tt0-gds-obj-prop_.gds-code
              ,buf_tt0-gds-obj-prop_.obj-type
              ,buf_tt0-gds-obj-prop_.obj-code
              ,buf_tt0-gds-obj-prop_.gdop-igt
              ,buf_tt0-gds-obj-prop_.gdop-assort-min
              ,buf_tt0-gds-obj-prop_.gdop-min-stock
              ,buf_tt0-gds-obj-prop_.grop-level-always-presence
              ,buf_tt0-gds-obj-prop_.grop-max-stock
              ,buf_tt0-gds-obj-prop_.grop-min-order
              ,input table tt0-gds-obj-prop-attr
              ) no-error .
          if error-status :error then  do:
            v-err-mess =  error-status :get-message(1) + return-value .

            undo main-block, retry main-block.

          end.

      end.   /*tt0-gds-obj-prop*/
      if   buf_temp-goods_.alc-type-code > 0 then do:  /* если указан код вида алкогольной продукции, то созлаем связку*/
        if not can-find(first ub.alc-type where ub.alc-type.alc-type-inner-code = buf_temp-goods_.alc-type-code  no-lock) then do:
                    v-err-mess = substitute("Не найден вид алкогольной продукции &1. Товар &2) &3&4&3&5"
                                      , buf_temp-goods_.alc-type-code
                                      , buf_temp-goods_.gds-code
                                      , {&new-line}
                                      , error-status:get-message(1)
                                      , return-value
                                      ).
            undo main-block, retry main-block.

        end.

                find first bb_alc-type-gds no-lock
                     where bb_alc-type-gds.gds-code            = buf_temp-goods_.gds-code
                       and bb_alc-type-gds.alc-type-inner-code = buf_temp-goods_.alc-type-code
                       and bb_alc-type-gds.create-user-db-num  = v-current-db-num no-error.
                if not available bb_alc-type-gds then do :
                  create bb_alc-type-gds.
                  assign
                      bb_alc-type-gds.gds-code            = buf_temp-goods_.gds-code
                      bb_alc-type-gds.alc-type-inner-code = buf_temp-goods_.alc-type-code
                      bb_alc-type-gds.create-user-db-num  = v-current-db-num
                  .
                  release  bb_alc-type-gds no-error.
                  if error-status :error then  do:
                    v-err-mess =  error-status :get-message(1) + return-value .
                    undo main-block, retry main-block.
                  end.
                end.
      end.
      if buf_temp-goods_.alc-type-code = ? then do :
                find first bb_alc-type-gds exclusive-lock
                     where bb_alc-type-gds.gds-code            = buf_temp-goods_.gds-code
                       and bb_alc-type-gds.create-user-db-num  = v-current-db-num no-error.
                if available bb_alc-type-gds then do :
                  delete bb_alc-type-gds no-error.
                  if error-status :error then  do:
                    v-err-mess =  error-status :get-message(1) + return-value .
                    undo main-block, retry main-block.
                  end.
                end.
      end.

  end. /*ne retry*/
end.
end procedure. /* proc-save */


PROCEDURE proc-settings:
define input-output parameter par-unq-artc as logical no-undo.
define input-output parameter par-dif-nam1 as logical no-undo.
define input-output parameter par-dif-nam2 as logical no-undo.
define input-output parameter par-dif-pdbc as logical no-undo .
define input-output parameter par-custvalue as character no-undo .
define input-output parameter par-is-prt  as logical no-undo .
define input-output parameter par-is-jwlr as logical no-undo .
define input-output parameter par-is-bttl as logical no-undo .
define input-output parameter par-is-ptrl as logical no-undo .


define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .


do
on error undo, return error
:

{ gbl/conf-rd.i
"'is-prt'"
0
"''"
0
"''"
"''"
"''"
no
conf-par
par-type
no-error
}

par-is-prt = (IF error-status:error or conf-par <> "yes" then no else yes).

{ gbl/conf-rd.i
"'is-jwlr'"
"''"
"''"
0
"''"
"''"
"''"
no
conf-par
par-type
no-error
}
assign
par-is-jwlr = (conf-par = "yes":U) no-error
.

{ gbl/conf-rd.i
"'is-bttl'"
"''"
"''"
0
"''"
"''"
"''"
no
conf-par
par-type
no-error
}
assign
par-is-bttl = (conf-par = "yes":U) no-error
.
{ gbl/conf-rd.i
"'is-ptrl'"
"''"
"''"
0
"''"
"''"
"''"
no
conf-par
par-type
no-error
}
assign
par-is-ptrl = (conf-par = "yes":U) no-error
.




{ gbl/conf-rd.i
 "'is-custm'"
 "''"
 "''"
 0
 "''"
 "''"
 "''"
 no
 par-custvalue
 par-type
 no-error
 }


for each thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.

run adm/shattri.p (
      input "get":U
    ,input  '':U
    ,input  0
    ,input  {&attr-gds-ref}
    ,input  "":U /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .

IF error-status:error then do:
  delete object v-tth.
  undo, return error
  substitute("Ошибка при получении опций работы со справочником товаров:&1&2 &3"
            , {&new-line}
            , error-status:get-message(1)
            , return-value ).
end.
for each thbjattr_thbj-attr  where
        thbjattr_thbj-attr.obj-type = '':U
    and thbjattr_thbj-attr.obj-code = 0
    and thbjattr_thbj-attr.upper-prop-code = {&attr-gds-ref}
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:
  case thbjattr_thbj-attr.prop-code:
    when {&attr-gds-ref_dif-nam1} then do:
      par-dif-nam1 = thbjattr_thbj-attr.property-value-logical.
    end.
    when {&attr-gds-ref_dif-nam2} then do:
      par-dif-nam2 = thbjattr_thbj-attr.property-value-logical.
    end.
    when {&attr-gds-ref_dif-pdbc} then do:
      par-dif-pdbc = thbjattr_thbj-attr.property-value-logical.
    end.
    when {&attr-gds-ref_unq-artc} then do:
      par-unq-artc = thbjattr_thbj-attr.property-value-logical.
    end.
  end case.
end.
end.

END PROCEDURE.


/*не удалять!!!!*/