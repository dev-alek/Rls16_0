/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 18 набор правил 4

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/08/06
Author: Bakhtadze Natalya
Creation date: 10/08/06


---------------------------&start-codex_id=18;ruleset_id=4;-----------------
Импорт данных по заказам

---------------------------&end-codex_id=18;ruleset_id=4;-----------------

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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 18 набор правил 4".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/garbcoll.i }
{ gbl/cur-time.i }
{ str/ord-list.i ord-list def "shared" }
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
{ cus/edocsord.i }
{ gbl/filelist.i }
{ gbl/ftp-fl.i }
{ bge/esysattr.i }
{ cus/cr-edist.i }
&undefine cr-edist_i
{ cus/cr-edist.i  tt }


/*переменные контекста*/
/*это у нас объект 0*/

define variable v-current-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-current-doc-code as character no-undo .
define variable v-current-doc-date as date no-undo .
define variable v-current-doc-type as character no-undo .
define variable v-current-doc-time as integer no-undo .
define variable v-current-lock as integer no-undo .
define variable v-current-wait as integer no-undo .
define variable v-save as integer no-undo .
define variable v-current-db-num as integer no-undo .
define variable v-current-date as date no-undo .
/*****************************/
define variable v-sign as integer no-undo .
define variable file-name as char.
define variable num-rec as integer no-undo .
define variable num-rec-ok as integer no-undo .
define variable num-rec-ok2 as integer no-undo .
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
define variable v-ds-read-order as character no-undo .
define variable v-esys-id as integer no-undo .
define variable v-oxml-exch-dir as character no-undo .
define variable v-oxml-heap-dir as character no-undo .
define variable v-es as logical no-undo .
define variable v-esm as character no-undo .
define variable v-rv as character no-undo .
define variable v-exchange-dir as character no-undo .

define stream Instream.

define temp-table temp-esys no-undo
field esys-id as integer
field db-num as integer
field esys-name as character
field delivery-method as integer
field rowid_ as rowid
field ftp-ip as character
field ftp-login as character
field ftp-password as character
field ftp-path as character
index pi is unique primary
esys-id
.

define variable log-file-name                as character      no-undo init "process-edoc.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .

{ str/dia2auto.i }
{ rul/seterror.i }
define buffer buf_temp-cmd for temp-cmd.
define buffer buf_temp-xml-tables for temp-xml-tables.




function 00180004_get-error-message returns character :
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

 { rul/context_f.i  get-thobj-es }











/* ------------------------- &end-i-script& -----------------------------------*/

on delete of this-procedure do:
  run delete-procedure in this-procedure .
  run gate-clear in this-procedure ( input v_dataseth, input v-xmlh) no-error .
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
  run proc-main in this-procedure  no-error .
  if error-status:error then do:
    v-esm = error-status :get-message (1).
    v-es = error-status:error .
    v-rv = return-value .
  end.
  { str/cdviewlg.i  "'!!!При импорте произошли ошибки!!!'"   log-file-name not-delete }
  if v-es then do:
      run delete-procedure in this-procedure .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, v-rv, {&new-line}, v-esm).
  end.
  run delete-procedure in this-procedure .
end.

procedure proc-main :
define variable v-ii as integer   no-undo .
define variable v-trn-doc as character no-undo .
define variable v-ext-obj-code as integer   no-undo .
define variable v-ship-date as date no-undo .
define variable v-status_ as character no-undo .
define variable v-desstatus as character no-undo .
define variable v-artic as character no-undo .
define variable v-cli-art as character no-undo .
define variable v-price as decimal no-undo .
define variable v-qnty as decimal no-undo .
define variable v-line-status_ as integer no-undo .
define variable v-nameth as character no-undo .
define variable v-hdesstatus as character no-undo .
define variable v-loc-file-name as character no-undo .
define variable v-custom-pack-name as character no-undo .
define variable v-success as logical   no-undo .
define variable v-pack-num as integer   no-undo .
define variable v-heap-dir as character no-undo .
define variable v-temp-dir as character no-undo .
define variable v-log-file-name as character no-undo .
define variable v-list-file-name as character no-undo .
define variable v-custom-pack-flag as logical   no-undo .
define variable v-short-file-name as character no-undo .
define variable v-filetype as character no-undo .
define variable v-extension as character no-undo .
define variable v-type as character no-undo .
define variable v-parameter as character no-undo .
define variable v-cli-uniq-key-rec as character no-undo .
define variable v-code39 as character no-undo .

define buffer buf_ext-system for ub.ext-system.
define buffer buf_ord-doc for ub.ord-doc.
define buffer buf_ord-line for ub.ord-line.
define buffer buf_temp-filelist for temp-filelist.
define buffer buf_esys-pck-rcvd for ub.esys-pck-rcvd.
define buffer buf_clients for ub.clients.
define buffer esys_ext-classif for ub.ext-classif.


_main:
do
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:

/*надо найти настройки маршрутизации и записи истории для данного типа ДК для всех объектов*/

/* ------------------------- &start-hn-option& -----------------------------------*/





/* ------------------------- &end-hn-option -----------------------------------*/


  run write-log  in p-log-handle (
                                  input 0
                                , "&DLine").
  &scop my-message substitute(".............Импорт данных по заказам из XML-файлов")
  {&display-message}.

  for each temp-esys:
    delete temp-esys.
  end.

    for each buf_ext-system no-lock where
              buf_ext-system.esys-have-import
          and buf_ext-system.esys-db-num-imp = g#db-num
          and buf_ext-system.db-num = 0
          and buf_ext-system.esys-type = integer({&openxml-type-edoc-nn}):
      create temp-esys.
      assign
      temp-esys.esys-id = buf_ext-system.esys-id
      temp-esys.db-num  = buf_ext-system.db-num
      temp-esys.esys-name  = buf_ext-system.esys-name
      temp-esys.delivery-method  = buf_ext-system.delivery-method
      temp-esys.rowid_  = rowid(buf_ext-system)
      .
    run ext-system-attr-value in this-procedure ( input buf_ext-system.esys-id
                                                  ,input buf_ext-system.db-num
                                                  ,input {&attr-esys-ftp-ip}
                                                  ,output temp-esys.ftp-ip
                                                  ,output v-type) no-error.
    run ext-system-attr-value in this-procedure ( input buf_ext-system.esys-id
                                                  ,input buf_ext-system.db-num
                                                  ,input {&attr-esys-ftp-login}
                                                  ,output temp-esys.ftp-login
                                                  ,output v-type) no-error.
    run ext-system-attr-value in this-procedure ( input buf_ext-system.esys-id
                                                  ,input buf_ext-system.db-num
                                                  ,input {&attr-esys-ftp-password}
                                                  ,output temp-esys.ftp-password
                                                  ,output v-type) no-error.
    run ext-system-attr-value in this-procedure ( input buf_ext-system.esys-id
                                                  ,input buf_ext-system.db-num
                                                  ,input {&attr-esys-ftp-path}
                                                  ,output temp-esys.ftp-path
                                                  ,output v-type) no-error.

      release temp-esys.
    end.
  _esys:
  for each temp-esys:
    if temp-esys.delivery-method = integer({&esys-dm-nnold}) then do:
      v-pack-num = 0.
    end.
    else do:
      v-pack-num = -1.
    end.
      v-custom-pack-name = ''. /*просто хотим получить директории*/
    run bge/espcknum.p (
                   input (if temp-esys.delivery-method = integer({&esys-dm-nnold})
                          then "fget":U
                          else "get":U)
                    ,input temp-esys.esys-id
                    ,input temp-esys.db-num
                  ,input temp-esys.delivery-method
                    ,input v-oxml-exch-dir
                    ,input v-oxml-heap-dir
                    ,input ""
                    ,input-output v-pack-num
                    ,input-output v-custom-pack-name
                    ,output v-loc-file-name
                    ,output v-exchange-dir
                    ,output v-heap-dir
                    ,output v-temp-dir
                    ,output v-log-file-name
                    ,output v-list-file-name
                    ,output v-custom-pack-flag
                  ) no-error.
      if error-status:error then do:
      end.
    if temp-esys.delivery-method <> integer({&esys-dm-nnold}) then do:
      v-loc-file-name  = v-loc-file-name + "xml".
    end.
    if temp-esys.delivery-method = integer({&esys-dm-nn})
    or temp-esys.delivery-method = integer({&esys-dm-nnold})
    then do:
     /*теперь получим список файлов*/
      assign
      v-parameter = temp-esys.ftp-ip + {&delim-par} +
                    temp-esys.ftp-login + {&delim-par} +
                    temp-esys.ftp-password + {&delim-par} +
                    string(0) + {&delim-par} + /*flags*/
                    (if temp-esys.ftp-path <> ''
                    then (trim (trim (trim(temp-esys.ftp-path
                                    , {&back-slash-char})
                                ,{&slash-char})
                          ,{&back-slash-char}) + {&slash-char})
                    else '') +
                    "in" + {&delim-par} +
                    "ftp-fl_CreateFileList" + {&delim-par} +
                    "process-edoc.txt"
      .
      for each buf_temp-filelist :
        delete buf_temp-filelist.
      end.
      run gbl/ftp-ls.p ( input parparentproc
                        ,input this-procedure:handle
                        ,input p-log-handle
                        ,input v-parameter ) no-error.
      if error-status:error then do:
        &scop my-message substitute("Ошибка при чтении списка файлов на FTP &1", temp-esys.ftp-ip)
        {&display-message}.
        assign v-view-log = yes.
        next _esys.
      end.
      if not can-find (first buf_temp-filelist) then do:
        &scop my-message substitute("Нет новых файлов на FTP &1", temp-esys.ftp-ip)
        {&display-message}.
      end.
      else do:
        assign
        v-parameter = temp-esys.ftp-ip + {&delim-par} +
                      temp-esys.ftp-login + {&delim-par} +
                      temp-esys.ftp-password + {&delim-par} +
                      string(0) + {&delim-par} + /*flags*/
                      '' + {&delim-par} +
                      '' + {&delim-par} +
                      string(yes) + {&delim-par} +
                      "cb_getnextfilename" + {&delim-par} +
                      "process-edoc.txt"
        .
        run gbl/ftp-get.p ( input parparentproc
                          ,input this-procedure:handle
                          ,input p-log-handle
                          ,input v-parameter ) no-error.
        if error-status:error then do:

        end.
      end.
    end.
    &scop my-message substitute("Просматриваем директорию обмена &1 ... ", v-exchange-dir)
    {&display-message}.
    if temp-esys.delivery-method = integer({&esys-dm-nnold}) then do:
      input stream instream from os-dir ( v-exchange-dir ) .
    end.
    _repeat:
    repeat
    on error undo, return error
    :
      if temp-esys.delivery-method = integer({&esys-dm-nnold}) then do:
        import stream Instream v-short-file-name file-name v-filetype.
        if not (v-filetype begins "F"
        and num-entries( v-short-file-name, "." ) > 1)
        then do:
        next _repeat.
      end.
      assign
      v-extension = ''
      v-extension = entry(num-entries(v-short-file-name, "."), v-short-file-name, ".")
      no-error
      .
      if v-extension = ''
        or lookup(v-extension, "stk-ok,rpl,pst,acc-ok") = 0
        then do:
        &scop my-message substitute("В директории обмена находится файл &1&2 с недопустимым расширением &3&2пропускаем ..." ~
                                      ,v-short-file-name ~
                                      , ~{&new-line~} ~
                                      , v-extension ~
                                      )
        {&display-message}.
          assign v-view-log = yes.
        next _repeat.
        end.
      end.
      else do:
        v-pack-num = -1.
        v-custom-pack-name = ''.
        run bge/espcknum.p (
                      input "get"
                      ,input temp-esys.esys-id
                      ,input temp-esys.db-num
                      ,input temp-esys.delivery-method
                      ,input v-oxml-exch-dir
                      ,input v-oxml-heap-dir
                      ,input ""
                      ,input-output v-pack-num
                      ,input-output v-custom-pack-name
                      ,output v-loc-file-name
                      ,output v-exchange-dir
                      ,output v-heap-dir
                      ,output v-temp-dir
                      ,output v-log-file-name
                      ,output v-list-file-name
                      ,output v-custom-pack-flag
                    ) no-error.
        if error-status:error then do:
        end.
        v-loc-file-name  = v-loc-file-name + "xml".
        file-name = v-exchange-dir + {&slash-char} + v-loc-file-name.
        v-short-file-name = v-loc-file-name.
        if search(file-name) = ? then do:
          &scop my-message substitute("В директории обмена больше нет файлов для приема&2ждем файла &1" ~
                                        ,file-name ~
                                        , ~{&new-line~} ~
                                        )
          {&display-message}.
          leave _repeat.
        end.
      end.
        run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
        empty temp-table temp-xml-tables.
        run rul/rum-xmli.p  (
                            input parparentproc
                            ,input p-log-handle
                            ,input file-name
                            ,input p-profile-id
                            ,input p-xsd-file
                          ,input temp-esys.esys-id
                          ,input v-pack-num
                            ,input-output v_dataseth
                            ,input-output v-xmlh
                            ) no-error.
        if error-status:error then do:
        &scop my-message substitute("Ошибка при верификации файла :&1&2&1&3" ~
                                    , ~{&new-line~}  ~
                                    , error-status:get-message(1) ~
                                    , return-value )
        {&display-message}.
        assign v-view-log = yes.
        run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
        empty temp-table temp-xml-tables.
        leave _repeat.
        end.
      &scop my-message  substitute("Импорт данных по заказам из файла &1...", file-name)
      {&display-message}.

      _xml-tables:
      for each buf_temp-xml-tables where buf_temp-xml-tables.order >= 0:
      /*надо создать динамический query*/
      if buf_temp-xml-tables.tbl-name = "THheader" then next _xml-tables.
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
        assign v-view-log = yes.
        if valid-handle(v_qh) then do:
          delete object v_qh no-error.
        end.
        run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
        empty temp-table temp-xml-tables.
        leave _repeat.
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
        assign v-view-log = yes.
        if valid-handle(v_qh) then do:
          delete object v_qh no-error.
        end.
        run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
        empty temp-table temp-xml-tables.
        leave _repeat.
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
        assign v-view-log = yes.
        if valid-handle(v_qh) then do:
          delete object v_qh no-error.
        end.
        run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
        empty temp-table temp-xml-tables.
        leave _repeat.
      end.
      _stroka:
      REPEAT:
        if buf_temp-xml-tables.is-parent then do:
        num-rec = num-rec + 1.
        end.
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
            assign v-view-log = yes.
            if valid-handle(v_qh) then do:
              delete object v_qh no-error.
            end.
            run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
            empty temp-table temp-xml-tables.
            leave _repeat.
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
              if valid-handle(v_qh) then do:
                delete object v_qh no-error.
              end.
              run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
              empty temp-table temp-xml-tables.
              leave _repeat.
            end.
            else do:
            v_qh:get-next().
            IF v_qh:query-off-end then leave _stroka.
          /* ------------------------- &start-rule& -----------------------------------*/
              /* Импорт  данных по продаже по ДК из внешней системы
              Импортируемые данные должны удовлетворять схеме exe/edoc-nn-order-01-ds.xsd */

              IF  ImpData1:current-tbl-name( ) = "order-header"  THEN do:
                v-current-doc-code = ImpData1:route-data_get-field-character( input "order-header", input "doc-code") .
                v-trn-doc = ImpData1:route-data_get-field-character( input "order-header", input "trn-code") .
                v-ship-date = ImpData1:route-data_get-field-date( input "order-header", input "ship-date") .
                v-status_ = ImpData1:route-data_get-field-character( input "order-header", input "status_") .
                v-hdesstatus = ImpData1:route-data_get-field-character( input "order-header", input "desstatus") .
                if v-status_ <> v-extension
                and temp-esys.delivery-method = integer({&esys-dm-nnold})
                then do:
                &scop my-message substitute("Нарушение протокола обмена:&1Статус заказа &2 не равен расширению файла &3" ~
                                            , ~{&new-line~} ~
                                            , v-status_ ~
                                            , v-extension)
                 {&display-message}.
                 assign v-view-log = yes.
                  if valid-handle(v_qh) then do:
                    delete object v_qh no-error.
                  end.
                  if temp-esys.delivery-method = integer({&esys-dm-nnold}) then do:
                  next _repeat.
                end.
                  else do:
                    leave _repeat.
                  end.
                end.
                if v-trn-doc = ''
                and v-status_ = {&edoc-ext-pst} then do:
                  &scop my-message substitute("Нарушение протокола обмена:&1В статусе заказа &2 не заполнен номер поставки <trn-code>" ~
                                              , ~{&new-line~} ~
                                              , v-status_)
                  {&display-message}.
                 assign v-view-log = yes.
                  if valid-handle(v_qh) then do:
                    delete object v_qh no-error.
                  end.
                  if temp-esys.delivery-method = integer({&esys-dm-nnold}) then do:
                    next _repeat.
                  end.
                  else do:
                    leave _repeat.
                  end.
                end.
                find first buf_ord-doc no-lock where
                          buf_ord-doc.doc-code = v-current-doc-code no-error.
                if not available buf_ord-doc then do:
                  run write-log-and-file in p-log-handle (
                              input 1
                            , input log-file-name
                            , input 1
                            , input substitute("Не найден заказ поставщику с номером &1")
                            ).
                  assign v-view-log = yes.
                  if valid-handle(v_qh) then do:
                    delete object v_qh no-error.
                  end.
                  if temp-esys.delivery-method = integer({&esys-dm-nnold}) then do:
                  next _repeat .
                end.
                  else do:
                    leave _repeat.
                  end.

                end.
                v-ext-obj-code = ImpData1:route-data_get-field-integer( input "order-header", input "ext-obj-code").
                IF  context_get-thobj-es( input temp-esys.esys-id
                                        , input ''
                                        , input v-ext-obj-code
                                        , output v-current-obj-type
                                        , output v-current-obj-code) = false  THEN do:

                  &scop my-message  substitute("Не найдено соответствие объекта &1 внешней системы &2 и объекта TH", v-ext-obj-code, temp-esys.esys-id)
                  {&display-message}.
                  assign v-view-log = yes.
                  assign v-view-log = yes.
                  if valid-handle(v_qh) then do:
                    delete object v_qh no-error.
                  end.
                  if temp-esys.delivery-method = integer({&esys-dm-nnold}) then do:
                  next _repeat .
                end.
                  else do:
                    leave _repeat.
                  end.

                end.
                if not (buf_ord-doc.obj-code = v-current-obj-code) then do:
                  &scop my-message  substitute("Неверный код объекта TH = &1 для заказа &2 - в IBS TH указан объект &3" ~
                                              , v-current-obj-code ~
                                              , buf_ord-doc.doc-code  ~
                                              , buf_ord-doc.obj-code)
                  {&display-message}.
                  assign v-view-log = yes.
                  if valid-handle(v_qh) then do:
                    delete object v_qh no-error.
                  end.
                  if temp-esys.delivery-method = integer({&esys-dm-nnold}) then do:
                  next _repeat .
                end.
                  else do:
                    leave _repeat.
                  end.

                end.
                find first ord-list where
                          ord-list.doc-code = buf_ord-doc.doc-code
                      and ord-list.trn-doc = v-trn-doc no-error.
                if not available ord-list then do:
                create ord-list.
                end.
                buffer-copy
                buf_ord-doc to ord-list
                assign
                ord-list.trn-doc = v-trn-doc
                ord-list.ps = substitute("&1 &2", ord-list.ps, v-hdesstatus)
                .
                assign
                ord-list.ord-int1 = integer(entry (lookup (v-status_, {&edoc-spis-ex}) , {&edoc-spis})) no-error .
                release ord-list.
              end. /*IF  ImpData1:current-tbl-name( ) = "order-header"  THEN do:*/

              IF  ImpData1:current-tbl-name( ) = "order-line"  THEN do:
                v-artic = ImpData1:route-data_get-field-character( input "order-line", input "artth") .
                v-cli-art = ImpData1:route-data_get-field-character( input "order-line", input "cliart") .
                v-price = ImpData1:route-data_get-field-decimal( input "order-line", input "pricequant") .
                v-qnty = ImpData1:route-data_get-field-decimal( input "order-line", input "quantityquant") .
                v-line-status_ = ImpData1:route-data_get-field-integer( input "order-line", input "status_") .
                v-nameth = ImpData1:route-data_get-field-character( input "order-line", input "nameth") .
                v-desstatus = ImpData1:route-data_get-field-character( input "order-line", input "desstatus") .
                /*v-code39    = ImpData1:route-data_get-field-character( input "order-line", input "code39") .*/

                find first temp-ord-line where
                          temp-ord-line.doc-code  = v-current-doc-code
                     and  temp-ord-line.cliart  = v-cli-art
                     and  temp-ord-line.trn-doc = v-trn-doc no-error.
                if not available temp-ord-line then do:
                create temp-ord-line.
                assign
                temp-ord-line.doc-code      =  v-current-doc-code
                temp-ord-line.cliart        =  v-cli-art
                  temp-ord-line.trn-doc = v-trn-doc
                  .
                end.
                assign
                temp-ord-line.artth         =  v-artic
                temp-ord-line.nameth        =  v-nameth
                temp-ord-line.quantityquant =  v-qnty
                temp-ord-line.pricequant    =  v-price
                temp-ord-line.status_       =  string(v-line-status_)
                temp-ord-line.desstatus     =  v-desstatus
                temp-ord-line.code39        =  v-code39
                .
                release temp-ord-line.
              end. /*IF  ImpData1:current-tbl-name( ) = "order-line"  THEN do:*/
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
            run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
            empty temp-table temp-xml-tables.
            leave _repeat.
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
          if v-retry-action = 0
          and buf_temp-xml-tables.is-parent
          then do:
            num-rec-ok = num-rec-ok + 1.
          end.
          run write-counter in p-log-handle ( input substitute("Прочитано записей при импорте: &1, из них удачно: &2", num-rec, num-rec-ok)).
        end. /*repeat*/
        if not v-stop
        and buf_temp-xml-tables.is-parent
        then do:
          num-rec = num-rec - 1.
        end.
        v_qh:query-close().
        if valid-handle(v_qh) then do:
          delete object v_qh.
        end.
      end. /*for each buf_temp-xmp-tables*/
      run bge/sxg-pack.p (
                     input parparentproc
                    ,input this-procedure:handle /*p-parent-handle*/ /*место определения write-to-lo и write-to-screen - dia2auto.i*/
                    ,input p-log-handle /*место определения write-log-and-file*/
                    ,input "fget":U
                    ,input false /*p-arch*/
                    ,input v-short-file-name
                    ,input v-exchange-dir /*p-source-dir*/
                    ,input v-heap-dir /*p-target-dir*/
                    ,input v-temp-dir
                    ,input 0 /*p-pack-num*/
                    ,input temp-esys.esys-id
                    ,input temp-esys.db-num
                    ,input g#db-num
                    ,input temp-esys.delivery-method
                    ) no-error.
      if error-status :error then do:
        &scop my-message substitute("Ошибки при перемещении файла заказа &1 из директории обмена &2 в архивную директорию &3" ~
                                    , v-loc-file-name ~
                                    , v-exchange-dir ~
                                    , v-heap-dir ~
                                    )
        {&display-message}.
        assign v-view-log = yes.
      end.
      run gbl/del-file.p ( input v-temp-dir ) no-error .
      if error-status :error then do:
        &scop my-message substitute("Ошибки при удалении временной директории &1" ~
                                    , v-temp-dir ~
                                    )
        {&display-message}.
         assign v-view-log = yes.
      end.
      run all-gates-clear in this-procedure ( buffer buf_temp-xml-tables).
      _ord-list:
      for each ord-list where ord-list.sel-order = 0
  on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
  on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
  :
      find first buf_ord-doc exclusive-lock where
                buf_ord-doc.doc-code = ord-list.doc-code no-error.
      if not available buf_ord-doc then do:
  &scop my-message substitute("Из ВС &1 получены данные по несуществующему заказу &2" ~
                            , temp-esys.esys-id ~
                            , ord-list.doc-code )

      {&display-message}.
          assign v-view-log = yes.
      run delete-ord-list in this-procedure ( input ord-list.doc-code
                                             ,input ord-list.trn-doc
                                             ).
          next _ord-list.
      end.
        /*найдем temp-esys*/
        find first buf_clients no-lock where
                    buf_clients.obj-type = buf_ord-doc.cli-type
                and buf_clients.obj-code = buf_ord-doc.cli-code no-error.
        run gen-key-rec in this-procedure ( input {&table_clients}
                                            ,input (buffer buf_clients:handle)
                                            ,output v-cli-uniq-key-rec) .
        /*найдем код объекта ВО ВС*/
        find first esys_ext-classif no-lock where
            esys_ext-classif.classif-name = {&extclass_clients_edoc-nn}
        and esys_ext-classif.classif-subject = {&table_clients}
        and esys_ext-classif.db-num = -1
        and esys_Ext-classif.uniq-key-rec = v-cli-uniq-key-rec
        and esys_ext-classif.key#_one = temp-esys.esys-id no-error .
        if not available esys_ext-classif then next _ord-list.
    &scop order-stts-int1 string(ord-list.ord-int1)
      run edocsord_import in this-procedure (
                                              buffer buf_ord-doc
                                          ,input {&edoc-stts-ex}
                                          ,input ord-list.trn-doc
                                              ,input ord-list.ps
                                            ) no-error.
      if error-status:error then do:
          if return-value <> '' then do:
            &scop my-message substitute("Ошибка при изменении статуса заказа при приеме данных:&1&2", {&new-line}, return-value )
            {&display-message}.
            assign v-view-log = yes.
          end.
      run delete-ord-list in this-procedure ( input ord-list.doc-code
                                             ,input ord-list.trn-doc
                                             ).
          next _ord-list.
      end.
      else do:
          &scop esys-id temp-esys.esys-id
          &scop esys-db-num temp-esys.db-num
          &scop cr-db-num g#db-num
          &scop pack-num v-pack-num

          { bge/crexrpck.i }
          assign
          buf_esys-pck-rcvd.espr-rcvd-recs  = 1
          buf_esys-pck-rcvd.espr-total-recs = 2
          buf_esys-pck-rcvd.espr-CRC-pack   = ''
          buf_esys-pck-rcvd.custom-pack-name = v-short-file-name
          buf_esys-pck-rcvd.espr-rcvd = yes
          .
        num-rec-ok2 = num-rec-ok2 + 1.
      end.
  END.
      process events.
      run get-stop-state in p-log-handle ( output v-stop) no-error .
      if v-stop then do:
          run write-log-and-file in p-log-handle (
                                                  input 1
                                                , input log-file-name
                                                , input 1
                                                , input substitute("Процесс импорта прерван пользователем")).
        run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
        empty temp-table temp-xml-tables.
        leave _repeat.
      end.
    end. /*repeat*/
    if temp-esys.delivery-method = integer({&esys-dm-nnold}) then do:
      input stream instream close.
    end.
  end. /*  for each temp-esys:*/
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Прочитано записей при импорте: &1, из них удачно обработано: &2", num-rec, num-rec-ok2)).

end. /*doe _main*/
end procedure. /* proc-main */

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.
define variable v-itop as integer   no-undo .
define variable v-ichild as integer   no-undo .
define variable v-pck-num as integer no-undo .
define buffer buf_esys-pck-keys for ub.esys-pck-keys.

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
        IF FILE-NAME = '' THEN DO:
          run bge/oxmlinir.p ( output v-oxml-exch-dir
                              ,output v-oxml-heap-dir) .
        end.
        else do:
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
      run garbcoll_clear in this-procedure .

  end.

end procedure. /* delete-procedure */

procedure delete-ord-list :
define input parameter p-doc-code as character no-undo .
define input parameter p-trn-doc as character no-undo .
define buffer buf_ord-list for ord-list.

for each temp-ord-line where
        temp-ord-line.doc-code = p-doc-code
    and temp-ord-line.trn-doc = p-trn-doc
        :
  delete temp-ord-line.
end.

find first buf_ord-list where
          buf_ord-list.doc-code = p-doc-code
      and buf_ord-list.trn-doc = p-trn-doc no-error .
if available buf_ord-list then delete buf_ord-list.

end procedure. /* delete-ord-list */


procedure cb_getnextfilename :
define input-output parameter p-rfile-name as character no-undo .
define input-output parameter p-lfile-name as character no-undo .

define buffer buf_temp-filelist for temp-filelist.

do
on error undo, return error
:
  find first buf_temp-filelist where
            buf_temp-filelist.full-name > p-rfile-name no-error .
  if available buf_temp-filelist then do:
    assign
    p-rfile-name = buf_temp-filelist.full-name
    p-lfile-name =  v-exchange-dir + {&slash-char} + buf_temp-filelist.file-name
    .
  end.
  else do:
    assign
    p-rfile-name = ''
    p-lfile-name = ''
    .
  end.
end.

end procedure. /* cb_getnextfilename */