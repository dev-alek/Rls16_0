/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 18

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/26/08
Author: Bakhtadze Natalya
Creation date: 05/26/08

---------------------------&start-codex_id=18;ruleset_id=1;-------------------------------
Операции над списком заказов
Экспорт списка заказов в XML файл
---------------------------&end-codex_id=18;ruleset_id=1;-------------------------------

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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 18, набор 1".
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
{ str/ord-list.i ord-list def "shared" }
{ rul/rum-fn.i }
{ rul/context_f.i get-thobj-es }
{ gbl/key-rec.i }
{ bge/esysattr.i }
{ cus/edocsord.i }
{ bge/tmpcxmlh.i }

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

define temp-table order-header no-undo
field ext-obj-code as integer
field doc-code as character
field trn-code as character
field status_ as character
field ship-date as date
field contract-code as character
index pi is unique primary
doc-code trn-code
.
define temp-table order-line no-undo
field doc-code as character
field trn-code as character
field cliart as character
field prod-type as character
field prod-code as integer
field artth as character
field nameth as character
field quantityquant as decimal
field pricequant  as decimal
field status_ as integer
field desstatus as character
index pi is unique primary
doc-code
artth
prod-type
prod-code
cliart
trn-code
.


/*переменные контекста*/
/*это у нас объект 0*/
define variable v-current-doc-code as character no-undo .
define variable v-current-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-current-lock as integer no-undo .
define variable v-current-wait as integer no-undo .
define variable v-save as integer no-undo .
define variable v-esys-cmd-proc-handle as handle no-undo .
define variable v-esys-cmd-code as integer no-undo .
define variable log-file-name                as character      no-undo init "process-edoc.txt".
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
define variable v-oxml-exch-dir as character no-undo .
define variable v-oxml-heap-dir as character no-undo .
define variable v-type as character no-undo .
define variable v-cmd-line as character no-undo .
define variable ftp-prog as character no-undo .
define variable l-res as integer no-undo .
define variable v-es as logical no-undo .
define variable v-esm as character no-undo .
define variable v-rv as character no-undo .


{ str/dia2auto.i }
{ rul/seterror.i }

define buffer buf_temp-cmd for temp-cmd.

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

 { rul/context_f.i  begin-esys-command }
 { rul/context_f.i  send-esys-command }
 { rul/context_f.i  set-custom-esys-pck-name }
 { rul/context_f.i  delete-command }



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
    v-esm = error-status :get-message (1).
    v-es = error-status:error .
    v-rv = return-value .
  end.
      if p-ruleset-id = 1
      or p-ruleset-id = 5 then do:
    { str/cdviewlg.i  "'!!!При экспорте произошли ошибки!!!'"   log-file-name not-delete }
      end.
      if p-ruleset-id = 2
      or p-ruleset-id = 6 then do:
    { str/cdviewlg.i  "'!!!При маршрутизации произошли ошибки!!!'"   log-file-name not-delete }
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

  define variable v-ii as integer no-undo .
  define variable v-loc-file-name as character no-undo .
  define variable v-pck-num-rec as integer no-undo init 1000.
  define variable v-uniq-key-rec as character no-undo .
  define variable v-cli-uniq-key-rec as character no-undo .
  define variable v-ext-obj-code as integer no-undo .
  define variable v-err as logical no-undo .
  define variable v-custom-pack-name as character no-undo .
  define variable v-success as logical   no-undo .
  define variable v-pack-num as integer   no-undo .
  define variable v-heap-dir as character no-undo .
  define variable v-exchange-dir as character no-undo .
  define variable v-temp-dir as character no-undo .
  define variable v-log-file-name as character no-undo .
  define variable v-list-file-name as character no-undo .
  define variable v-custom-pack-flag as logical   no-undo .
  define variable v-parameter as character no-undo .
  DEFINE VARIABLE v-today as date no-undo .
  DEFINE VARIABLE v-time as integer no-undo .
  define variable v-ord-int1 as integer no-undo .
  define variable v-found-rcv as logical no-undo .

  define buffer buf_ext-system for ub.ext-system.
  define buffer buf_ord-doc for ub.ord-doc.
  define buffer buf_ord-line for ub.ord-line.
  define buffer buf_object for ub.clients.
  define buffer buf_clients for ub.clients.
  define buffer buf_ext-classif for ub.ext-classif.
  define buffer esys_ext-classif for ub.ext-classif.
  define buffer buf_goods for ub.goods.
  define buffer buf_esys-pck-sent for ub.esys-pck-sent.
  define buffer buf_ord-doc-rcv for ub.ord-doc-rcv.
  define buffer buf_ord-list for ord-list.
  define buffer buf_contract for ub.contract.

/* ------------------------- &end-hn-option& -----------------------------------*/
  for each order-header:
    delete  order-header.
  end.
  for each order-line:
    delete  order-line.
  end.
  if p-ruleset-id = 1
  or p-ruleset-id = 5
  then do:
    run write-log  in p-log-handle (
                                    input 0
                                  , "&DLine").
    &scop my-message substitute(".............Экспорт заказов в XML для передачи поставщику")
    {&display-message}.
  end.
  if p-ruleset-id = 2
  or p-ruleset-id = 6
  then do:
    run write-log  in p-log-handle (
                                    input 0
                                  , "&DLine").

    &scop my-message substitute(".............Маршрутизация заказов поставщику")
    {&display-message}.
  end.
  for each ord-list:
    if ord-list.is-trn-doc = no
    and ord-list.sel-order = 0
    then do:
      if ord-list.ord-int1 = int({&edoc-pst}) then do:
        if ord-list.trn-doc = '' then do:
          v-found-rcv = no.
          for each  buf_ord-doc-rcv no-lock where
                  buf_ord-doc-rcv.doc-code = ord-list.doc-code
              and buf_ord-doc-rcv.ord-int1 = integer({&edoc-pst}):
            find first buf_ord-list where
                      buf_ord-list.doc-code = ord-list.doc-code
                  and  buf_ord-list.doc-type = ord-list.doc-type
                  and  buf_ord-list.trn-doc = entry(1, buf_ord-doc-rcv.sub-par, {&delim-par}) no-error .
            if not available buf_ord-list then do:
              create buf_ord-list.
              buffer-copy ord-list to buf_ord-list
              assign
              buf_ord-list.trn-doc = entry(1, buf_ord-doc-rcv.sub-par, {&delim-par} )
              buf_ord-list.ord-int1 = integer({&edoc-pst-ok})
              v-found-rcv = yes
              .
              release buf_ord-list.
            end.
          end.
          if v-found-rcv then do:
            delete ord-list.
          end.
          else do:
            assign
            ord-list.ord-int1 = integer({&edoc-pst-ok})
            .
            release ord-list.
          end.
        end.
      end.
    end. /*if ord-list.is-trn-doc = no*/
   end.
  _stroka:
  for each ord-list
  break
  by ord-list.host-code
  by ord-list.cli-type
  by ord-list.cli-code
  by ord-list.obj-type
  by ord-list.obj-code
  by ord-list.doc-code
  by ord-list.trn-doc
  On error undo _stroka, next _stroka
  :
    assign
    v-current-doc-code = ord-list.doc-code
    num-rec = num-rec + 1
    .
    &scop my-message substitute("Обработка заказа &1 &2", ord-list.doc-code , ord-list.trn-doc)
    {&display-message}.
    if v-err then next.
    /* ------------------------- &start-rule& -----------------------------------*/
    IF num-rec = 1
    THEN do:
      IF  ExpData1:route-data_read-xmlschema( INPUT p-xsd-file) = false  THEN do:
        undo _main, return error v-last-error-message .
      end.
    end.
    if first-of(ord-list.cli-code) then do:
      for each order-header:
        delete  order-header.
      end.
      for each order-line:
        delete  order-line.
      end.
      v-err = no.
      find first buf_clients no-lock where
                buf_clients.obj-type = ord-list.cli-type
            and buf_clients.obj-code = ord-list.cli-code no-error.
      if not available buf_clients then do:
        &scop my-message substitute("Не найден контрагент &1&2", ord-list.cli-typ, ord-list.cli-code)
        {&display-message}.
        assign v-view-log = yes.
        v-err = yes.
        next _stroka.
      end.
      if ord-list.is-trn-doc = no
      and ord-list.sel-order = 0
      then do:
        if ord-list.ord-int1 = integer({&edoc-stk-ok})
        or ord-list.ord-int1 = integer({&edoc-acc-ok})
        or ord-list.ord-int1 = integer({&edoc-err})
        then do:
          &scop order-stts-int1 string(ord-list.ord-int1)
          &scop my-message substitute("Нельзя отправить Заказ в статусе <&1>!", {&edoc-stts-name} )
          {&display-message}.
          assign v-view-log = yes.
          v-err = yes.
          next _stroka.
        end.
        if ord-list.doc-type = {&O-P}
        and ord-list.status_  = {&g___new}
        and ord-list.ord-int1 = integer({&edoc-empty}) then do:
          assign
          v-ord-int1 = integer({&edoc-stk}).
        end.
        if (ord-list.ord-int1 = integer({&edoc-rpl-ok})
          or
          ord-list.ord-int1 = int ({&edoc-rpl}))
          and ord-list.doc-type = {&O-P}
          and ord-list.status_  = {&ord-rcv}
          then do:
          assign
          v-ord-int1 = integer({&edoc-acc}).
        end.
        if v-ord-int1 = integer({&edoc-stk}) then do:
          if ord-list.status_ <> {&g___new}
          or ord-list.ord-int1 = int({&edoc-stk})
          then do:
            &scop my-message substitute("Заказ &1 НЕ НОВЫЙ. Отправить можно только НОВЫЙ заказ!", ord-list.doc-code )
            {&display-message}.
            assign v-view-log = yes.
            v-err = yes.
            next _stroka.
          end.
          if ord-list.ord-int1 <> integer({&edoc-empty}) then do:
            &scop my-message substitute("Заказ &1 уже был отправлен. Отправить можно только НОВЫЙ заказ (желтый)!", ord-list.doc-code)
            {&display-message}.
            assign v-view-log = yes.
            v-err = yes.
            next _stroka.
          end.
        end.
        if v-ord-int1 = int({&edoc-acc}) then do:
          if ord-list.status_ <> {&ord-rcv} then do:
            &scop my-message substitute("Нельзя отправить заказ &1, он не в статусе ПОСТАВКА!" , ord-list.doc-code)
            {&display-message}.
            assign v-view-log = yes.
            v-err = yes.
            next _stroka.
          end.
        end.
        if v-ord-int1 = integer({&edoc-acc})
        or v-ord-int1 = integer({&edoc-stk}) then do:
          if not ( ord-list.doc-type = {&O-P} )   then do:
          &scop my-message substitute("Нельзя отправить заказ &1, отправить можно только заказ ОП !", ord-list.doc-code)
          {&display-message}.
          assign v-view-log = yes.
          v-err = yes.
          next _stroka.
          end.
        end.
        if v-ord-int1 = integer({&edoc-acc})
        or v-ord-int1 = integer({&edoc-stk}) then do:
          if not can-find (first ub.ord-line no-lock where ub.ord-line.doc-code =  ord-list.doc-code ) or
          can-find (first ub.ord-line no-lock where  ub.ord-line.doc-code =  ord-list.doc-code and ub.ord-line.qnty = 0 ) or
          can-find (first ub.ord-line no-lock where  ub.ord-line.doc-code =  ord-list.doc-code and ub.ord-line.price-cli = 0 ) or
          can-find (first ub.ord-line no-lock where  ub.ord-line.doc-code =  ord-list.doc-code and ub.ord-line.cli-art = "" )
        then do:
          &scop my-message substitute("Заказ &1 полностью не создан. Проверьте наличие строк, количеств, цены и артикула поставщика !", ord-list.doc-code)
            {&display-message}.
            v-err = yes.
            assign v-view-log = yes.
            next _stroka.
          end.
        end.
        if ord-list.doc-type = {&O-P}
        and ord-list.status_  = {&g___new}
        and ord-list.ord-int1 = integer({&edoc-empty}) then do:
          assign
          ord-list.ord-int1 = integer({&edoc-stk}).
        end.
        if (ord-list.ord-int1 = int ({&edoc-rpl-ok}) or
            ord-list.ord-int1 = int ({&edoc-rpl}))
          and ord-list.doc-type = {&O-P}
          and ord-list.status_  = {&ord-rcv} then do:
          assign
          ord-list.ord-int1 = integer({&edoc-acc}).
        end.
        if ord-list.ord-int1 = int({&edoc-rpl}) then do:
          assign
          ord-list.ord-int1 = integer({&edoc-rpl-ok}).
        end.
      end. /*if ord-list.is-trn-doc = no then do:*/
      if ord-list.is-trn-doc then do:
        ord-list.ord-int1 = integer({&edoc-trn}).
      end.
      run gen-key-rec in this-procedure ( input {&table_clients}
                                         ,input (buffer buf_clients:handle)
                                         ,output v-cli-uniq-key-rec) no-error .
      if error-status:error then do:
        &scop my-message substitute("gen-key-rec: &1&2&3&2(&4&5)" ~
                                  , error-status:get-message(1)   ~
                                  , return-value                   ~
                                  , ~{&new-line~}                  ~
                                  , ord-list.cli-type              ~
                                  , ord-list.cli-code)
        {&display-message}.
        assign v-view-log = yes.
        v-err = yes.
        next _stroka.
      end.
      find first esys_ext-classif no-lock where
          esys_ext-classif.classif-name = {&extclass_clients_edoc-nn}
      and esys_ext-classif.classif-subject = {&table_clients}
      and esys_ext-classif.db-num = -1
      and esys_Ext-classif.uniq-key-rec = v-cli-uniq-key-rec no-error .
      if not available esys_ext-classif then do:
         &scop my-message substitute("Поставщик &1&2 заказа &3 НЕ РАБОТАЕТ ПО СИСТЕМЕ EDOC-NN", ord-list.cli-type, ord-list.cli-code, ord-list.doc-code)
          {&display-message}.
          assign v-view-log = yes.
          v-err = yes.
          next _stroka.
      end.
      for each temp-esys:
        delete temp-esys.
      end.
      /*найдем код объекта ВО ВС*/
      for each esys_ext-classif no-lock where
          esys_ext-classif.classif-name = {&extclass_clients_edoc-nn}
      and esys_ext-classif.classif-subject = {&table_clients}
      and esys_ext-classif.db-num = -1
      and esys_Ext-classif.uniq-key-rec = v-cli-uniq-key-rec,
        first buf_ext-system no-lock where
                  buf_ext-system.esys-id = esys_ext-classif.key#_one
              and buf_ext-system.db-num = 0
              and buf_ext-system.esys-db-num-exp = g#db-num
              and buf_ext-system.esys-have-export = yes
              :
        if buf_ext-system.delivery-method <> integer({&esys-dm-nn}) then do:
          &scop my-message substitute("Неверный метод доставки для ВС &1" ~
                                      , buf_ext-system.esys-id)
          {&display-message}.
          assign v-view-log = yes.
          v-err = yes.
          next _stroka.
        end.
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
        leave.
      end.
      find first temp-esys no-error.
      if not available temp-esys then do:
        &scop my-message substitute("Для поставщика &1&2 не найдена ВС, у которой есть экспорт в текущей БД")
        {&display-message}.
        assign v-view-log = yes.
        v-err = yes.
        next _stroka.
      end.
    end.
    if first-of(ord-list.obj-code) then do:
      find first buf_object no-lock where
                buf_object.obj-type = ord-list.obj-type
            and buf_object.obj-code = ord-list.obj-code no-error.
      if not available buf_object then do:
        &scop my-message substitute("Не найден объект &1&2", ord-list.obj-type, ord-list.obj-code)
        {&display-message}.
        assign v-view-log = yes.
        v-err = yes.
        next _stroka.
      end.
      if buf_object.db-num <> g#db-num then do:
        &scop my-message substitute("Объект &1&2 принадлежит другой БД", ord-list.obj-type, ord-list.obj-code)
        {&display-message}.
        assign v-view-log = yes.
        v-err = yes.
        next _stroka.
      end.
      run gen-key-rec in this-procedure ( input {&table_clients}
                                         ,input (buffer buf_object:handle)
                                         ,output v-uniq-key-rec) no-error .
      if error-status:error then do:
        &scop my-message substitute("gen-key-rec: &1&2&3&2(&4&5)" ~
                                  , error-status:get-message(1)   ~
                                  , return-value                  ~
                                  , ~{&new-line~}                 ~
                                  , buf_object.obj-type           ~
                                  , buf_object.obj-code)
        {&display-message}.
        assign v-view-log = yes.
        v-err = yes.
        next _stroka.
      end.
      /*найдем код объекта ВО ВС*/
      find first buf_ext-classif no-lock where
          buf_ext-classif.classif-name = {&extclass_clients_esys}
      and buf_ext-classif.classif-subject = {&table_clients}
      and buf_ext-classif.db-num = 0
      and buf_Ext-classif.key#_one = temp-esys.esys-id
      and buf_Ext-classif.uniq-key-rec = v-uniq-key-rec no-error .
      if not available buf_ext-classif then do:
        &scop my-message substitute("Не найдено соответствие объекту &1&2 во внешней системе &3" ~
                                    , ord-list.obj-type ~
                                    , ord-list.obj-code ~
                                    , temp-esys.esys-id ~
                                    )
        {&display-message}.
        assign v-view-log = yes.
        v-err = yes.
        next _stroka.
      end.
      else do:
        v-ext-obj-code = buf_Ext-classif.key#_two.
      end.
    end. /*if first-of(ord-list.obj-code) then do:*/
    if p-save >= 0 then do:
      find first buf_ord-doc exclusive-lock where
                buf_ord-doc.doc-code = ord-list.doc-code
             no-error.
    end.
    else do:
      find first buf_ord-doc no-lock where
                buf_ord-doc.doc-code = ord-list.doc-code
             no-error.
    end.
    if not available buf_ord-doc then do:
      &scop my-message substitute("Не найден содержащийся в списке заказ &1", ord-list.doc-code)
      {&display-message}.
      assign v-view-log = yes.
      v-err = yes.
      next _stroka.
    end.
    for each temp-esys:
      if p-ruleset-id = 1
      or p-ruleset-id = 5
      then do:
        do :
          v-success = no.
          find first buf_ext-system no-lock where
                    buf_ext-system.esys-id = temp-esys.esys-id
                and buf_ext-system.db-num = temp-esys.db-num.
          run bge/lockesys.p (
            input buf_ext-system.esys-id
            ,input buf_ext-system.db-num
            ,buffer buf_ext-system
                                          ,output v-success) no-error.
          if error-status :error
          or not v-success then do:
            &scop my-message substitute("Не удалось захватить ВС для экспорта:&1&2&1&3" ~
                                       , ~{&new-line~} ~
                                       , error-status:get-message(1) ~
                                       , return-value ~
                                       )
            {&display-message}.
            assign v-view-log = yes.
            v-err = yes.
            next _stroka.
          end.
        end.
      end.
      if p-ruleset-id = 2
      or p-ruleset-id = 6
      then do:
        IF  context_begin-esys-command( input string(temp-esys.esys-id), input-output v-esys-cmd-proc-handle, output v-esys-cmd-code) = false  THEN do:
          undo _main, return error v-last-error-message .
        end.
      end.

      /*СВЕТА ЗДЕСЬ МЕНЯТЬ НАДО РАСШИРЕНИЕ ФАЙЛА В ЗАВИСИМОТИ ОТ СТАТУСА*/
      if temp-esys.delivery-method = integer({&esys-dm-nnold}) then do:
        &scop order-stts-int1 string(ord-list.ord-int1)
        if ord-list.trn-doc = "" then do:
      v-custom-pack-name = substitute("&1_&2_&3-&4-&5.&6"
                                     , v-ext-obj-code
                                     , buf_ord-doc.doc-code
                                     , string(year(buf_ord-doc.ship-date), "9999")
                                     ,string(month(buf_ord-doc.ship-date), "99")
                                     ,string(day(buf_ord-doc.ship-date), "99")
                                     ,{&edoc-stts-ex}
                                     ).
      end .
      else do:
      v-custom-pack-name = substitute("&1_&2_&7_&3-&4-&5.&6"
                                     ,v-ext-obj-code
                                     ,buf_ord-doc.doc-code
                                     ,string(year(buf_ord-doc.ship-date), "9999")
                                     ,string(month(buf_ord-doc.ship-date), "99")
                                     ,string(day(buf_ord-doc.ship-date), "99")
                                     ,{&edoc-stts-ex}
                                        ,ord-list.trn-doc
                                     ).
       end.
      end.
      if p-ruleset-id = 1
      or p-ruleset-id = 5
      then do:
        if temp-esys.delivery-method = integer({&esys-dm-nn}) then do:
          v-pack-num = -1.
          v-custom-pack-name = ''.
        end.
        run bge/espcknum.p ( input (if temp-esys.delivery-method = integer({&esys-dm-nnold})
                                    then "fput":U
                                    else "put":U)
                      ,input temp-esys.esys-id
                      ,input temp-esys.db-num
                      ,input temp-esys.delivery-method
                      ,input v-oxml-exch-dir
                      ,input v-oxml-heap-dir
                      ,input ""
                      ,input-output v-pack-num
                      ,input-output v-custom-pack-name
                      ,output v-loc-file-name
                      ,output v-heap-dir
                      ,output v-exchange-dir
                      ,output v-temp-dir
                      ,output v-log-file-name
                      ,output v-list-file-name
                      ,output v-custom-pack-flag
                    ) no-error.
        if error-status :error then do:
          &scop my-message substitute("Ошибка при получении директории и имен файла для экспорта&1&2&1&3" ~
                                     , ~{&new-line~} ~
                                     , error-status:get-message(1)  ~
                                     , return-value ~
                                     )
          {&display-message}.
          assign v-view-log = yes.
          v-err = yes.
          next _stroka.
        end.
        if temp-esys.delivery-method = integer({&esys-dm-nn}) then do:
          v-loc-file-name = v-loc-file-name + "xml".
        end.
      end.
      &scop order-stts-int1 string(ord-list.ord-int1)
      create order-header.
      assign
      order-header.doc-code = buf_ord-doc.doc-code
      order-header.ship-date = buf_ord-doc.ship-date
      order-header.status_ = {&edoc-stts-ex}
      order-header.trn-code  =  ord-list.trn-doc
      order-header.ext-obj-code = v-ext-obj-code
      .
      find first buf_contract no-lock
           where buf_contract.host-code     = buf_ord-doc.host-code
             and buf_contract.contract-code = buf_ord-doc.contract-code no-error.
      if available buf_contract then do:
        assign order-header.contract-code = buf_contract.contract-prn-code .
      end.
      ExpData1:route-data_create-record( INPUT "order-header") .
      ExpData1:route-data_copy-record( INPUT "order-header", INPUT  (buffer order-header:handle) ) .
      if p-ruleset-id = 2
      or p-ruleset-id = 6
      then do:
        IF ExpData1:esys-add-dump( INPUT "order-header", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
          undo _main, return error v-last-error-message .
        end.
      end.
      if order-header.trn-code = ""
      or ord-list.ord-int1 = integer({&edoc-pst-ok})
      then do:
        if ord-list.ord-int1 = integer({&edoc-pst-ok}) then do:
          /*отсылаем пустую шапку*/
        end.
        else do:
        /* по строкам заказа */
      for each buf_ord-line no-lock where
                  buf_ord-line.doc-code = ord-list.doc-code
                  by buf_ord-line.line-num
          on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
          on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
          on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
          :
            find first buf_goods no-lock where
                      buf_goods.gds-code = buf_ord-line.gds-code no-error.
            if not available buf_goods then do:
              undo _main, return error v-last-error-message .
            end.
            find first order-line where
                      order-line.doc-code = buf_ord-doc.doc-code
                  and order-line.cliart = buf_ord-line.cli-art no-error .
            if available order-line then do:
              &scop my-message substitute("В заказе &1 две строки с одинаковым артикулом поставщика &2: пропускаем ..." ~
                                          , ord-list.doc-code ~
                                      , buf_ord-line.cli-art ~
                                      )
          {&display-message}.
              assign v-view-log = yes.
            if p-ruleset-id = 2
            or p-ruleset-id = 6
            then do:
            IF  context_delete-command( input v-esys-cmd-proc-handle, input v-esys-cmd-code) = false  THEN do:
              undo _main, return error v-last-error-message .
            end.
          end.
          &scop release_1 clear-data ( )
          ExpData1:Route-data_{&release_1} .
          next _stroka.
        end.
        else do:
          create order-line.
          assign
          order-line.doc-code = buf_ord-doc.doc-code
              order-line.trn-code      = ord-list.trn-doc
          order-line.cliart = buf_ord-line.cli-art
          order-line.status_ = 0 /*мы не корректируем*/
          order-line.desstatus = ""   /*мы не корректуируем*/
          order-line.artth =  buf_ord-line.artic
          order-line.prod-type =  buf_ord-line.prod-type
          order-line.prod-code =  buf_ord-line.prod-code
          order-line.nameth =  buf_goods.gds-name
          order-line.quantityquant =  buf_ord-line.cli-qnty
          order-line.pricequant =  buf_ord-line.price-cli
          .
          ExpData1:route-data_create-record( INPUT "order-line") .
          ExpData1:route-data_copy-record( INPUT "order-line", INPUT  (buffer order-line:handle) ) .
            if p-ruleset-id = 2
            or p-ruleset-id = 6
            then do:
            IF  ExpData1:esys-add-dump( INPUT "order-line", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
              undo _main, return error v-last-error-message .
            end.
          end.
          release order-line.
        end.
      end. /*      for each buf_ord-line no-lock where*/
      end.
      end.
      else do:
        /* по строкам накладной */
        define buffer buf_doc-line for ub.doc-line  .
        for each buf_doc-line no-lock where
                 buf_doc-line.doc-code = ord-list.doc-type
        on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
        on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
        :
          find first buf_goods no-lock where
                    buf_goods.artic     = buf_doc-line.artic     and
                    buf_goods.prod-type = buf_doc-line.prod-type and
                    buf_goods.prod-code = buf_doc-line.prod-code no-error.
          if not available buf_goods then do:
            undo _main, return error v-last-error-message .
          end.
          find first buf_ord-line no-lock where
                    buf_ord-line.doc-code  = ord-list.doc-code      and
                    buf_ord-line.artic     = buf_doc-line.artic     and
                    buf_ord-line.prod-type = buf_doc-line.prod-type and
                    buf_ord-line.prod-code = buf_doc-line.prod-code no-error.
          if not available buf_ord-line then do:
            undo _main, return error v-last-error-message .
          end.

          find first order-line where
                     order-line.doc-code  = ord-list.doc-code
                 and order-line.cliart    = buf_ord-line.cli-art
                 no-error .
          if available order-line then do:
            &scop my-message substitute("В ПН &1 две строки с одинаковым артикулом поставщика &2: пропускаем ..." ~
                                        , ord-list.doc-code ~
                                        , buf_ord-line.cli-art ~
                                        )
            {&display-message}.
            assign v-view-log = yes.
            if p-ruleset-id = 2
            or p-ruleset-id = 6
            then do:
              IF  context_delete-command( input v-esys-cmd-proc-handle, input v-esys-cmd-code) = false  THEN do:
                undo _main, return error v-last-error-message .
              end.
            end.
            &scop release_1 clear-data ( )
            ExpData1:Route-data_{&release_1} .
            next _stroka.
          end.
          else do:
            create order-line.
            assign
            order-line.doc-code      = buf_ord-doc.doc-code
            order-line.trn-code      = ord-list.trn-doc
            order-line.cliart        = buf_ord-line.cli-art
            order-line.status_       = 0 /*мы не корректируем*/
            order-line.desstatus     = ""   /*мы не корректуируем*/
            order-line.artth         =  buf_ord-line.artic
            order-line.prod-type     =  buf_ord-line.prod-type
            order-line.prod-code     =  buf_ord-line.prod-code
            order-line.nameth        =  buf_goods.gds-name
            order-line.quantityquant =  buf_doc-line.fact-qnty / buf_doc-line.cli-base-rate
            order-line.pricequant    =  buf_doc-line.price-cli
            .
            ExpData1:route-data_create-record( INPUT "order-line") .
            ExpData1:route-data_copy-record( INPUT "order-line", INPUT  (buffer order-line:handle) ) .
            if p-ruleset-id = 2
            or p-ruleset-id = 6
            then do:
              IF  ExpData1:esys-add-dump( INPUT "order-line", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
                undo _main, return error v-last-error-message .
              end.
            end.
            release order-line.
          end.
        end. /*      for each buf_ord-line no-lock where*/

      end.
      for each order-line:
        delete order-line.
      end.
      run edocsord_export in this-procedure ( buffer buf_ord-doc
                                             ,input ord-list.trn-doc
                                             ,input ord-list.ord-int1
                                            ) no-error.
      if p-ruleset-id = 2
      or p-ruleset-id = 6
      then do:
        if temp-esys.delivery-method = integer({&esys-dm-nnold}) then do:
        IF  context_set-custom-esys-pck-name(  input v-esys-cmd-proc-handle, input v-esys-cmd-code, input v-custom-pack-name) = false  THEN do:
          undo _main, return error v-last-error-message .
        end.
        end.
        IF  context_send-esys-command( input string(temp-esys.esys-id), input v-esys-cmd-proc-handle, input v-esys-cmd-code, input g#userid) = false  THEN do:
          undo _main, return error v-last-error-message .
        end.
        if ord-list.sel-order = 1 then delete ord-list.
      end.
      if p-ruleset-id = 1
      or p-ruleset-id = 5
      then do:
        if not ExpData1:set-esys( temp-esys.esys-id, temp-esys.esys-name) then do:
          undo _main, return error .
        end.
        if temp-esys.delivery-method = integer({&esys-dm-nn}) then do:
          if not ExpData1:set-pack-num( v-pack-num) then do:
            undo _main, return error .
          end.
        end.
        if not ExpData1:write-xml(v-exchange-dir + {&slash-char} + v-loc-file-name, 1) then do:
          undo _main, return error .
        end.
        assign
        v-parameter = temp-esys.ftp-ip + {&delim-par} +
                      temp-esys.ftp-login + {&delim-par} +
                      temp-esys.ftp-password + {&delim-par} +
                      string(0) /*flags*/ + {&delim-par} +
                      (if temp-esys.ftp-path <> ''
                      then (trim (trim (trim(temp-esys.ftp-path
                                      , {&back-slash-char})
                                 ,{&slash-char})
                            ,{&back-slash-char}) + {&slash-char})
                      else '') +
                      "out" + {&slash-char} + v-loc-file-name  + {&delim-par} +
                      v-exchange-dir + {&slash-char} + v-loc-file-name + {&delim-par} +
                      string(no) + {&delim-par} +
                      "process-edoc.txt"
        .
        run gbl/ftp-put.p ( input parparentproc
                          ,input this-procedure:handle
                          ,input p-log-handle
                          ,input v-parameter ) no-error.
        if error-status:error then do:
           &scop my-message substitute("Ошибка при передаче файла заказа &1 по FTP" ~
                                      , v-loc-file-name  )
           {&display-message}.
           assign v-view-log = yes.
           v-err = yes.
           undo _stroka, next _stroka.
        end.
        else do:
          /*надо создать пакет и пометить как принятый*/
          run cur-time in this-procedure ( output v-today, output v-time).
      &scop pack-num v-pack-num
      &scop cr-db-num g#db-num
      &scop esys-db-num temp-esys.db-num
      &scop esys-id temp-esys.esys-id
      &scop pack-time v-time
      &scop pack-date v-today

          { bge/cre-xpck.i }
          assign
          buf_esys-pck-sent.esps-rcvd = yes
          buf_esys-pck-sent.esps-total-recs = 2
          buf_esys-pck-sent.esps-CreNum         = 1
          buf_esys-pck-sent.esps-SendTxtDate    = {&pack-date}
          buf_esys-pck-sent.esps-SendTxtTimeInt = {&pack-time}
          buf_esys-pck-sent.esps-SendTxtTime    = string( {&pack-time}, "HH:MM:SS" )
          buf_esys-pck-sent.esps-rcvdDate       = {&pack-date}
          buf_esys-pck-sent.esps-RcvdTimeInt    = {&pack-time}
          buf_esys-pck-sent.esps-RcvdTime       = string( {&pack-time}, "HH:MM:SS" )
          .
          run bge/sxg-pack.p (
                         input parparentproc
                        ,input this-procedure:handle  /*p-parent-handle*/ /*место определения write-to-lo и write-to-screen - dia2auto.i*/
                        ,input p-log-handle /*место определения write-log-and-file*/
                        ,input "fput":U
                        ,input false /*p-arch*/
                        ,input v-loc-file-name
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
            v-err = yes.
            next _stroka.
          end.
          run gbl/del-file.p ( input v-temp-dir ) no-error .
          if error-status :error then do:
            &scop my-message substitute("Ошибки при удалении временной директории &1" ~
                                        , v-temp-dir ~
                                        )
            {&display-message}.
            assign v-view-log = yes.
            v-err = yes.
            next _stroka.
          end.
          run gbl/del-file.p ( input v-exchange-dir + {&slash-char} + v-loc-file-name ) no-error .
          if error-status :error then do:
            &scop my-message substitute("Ошибки при удалении файла в директории обмена &1" ~
                                        , v-exchange-dir + {&slash-char} + v-loc-file-name ~
                                        )
            {&display-message}.
            assign v-view-log = yes.
            v-err = yes.
            next _stroka.
          end.
        end.
      end.
      &scop release_1 clear-data ( )
      ExpData1:Route-data_{&release_1} .

    end. /*    for each temp-esys:*/
    /* ------------------------- &end-rule& -------------------------------------*/

    /* ------------------------- &start-release-obj& -----------------------------------*/


    /* ------------------------- &end-release-obj& -------------------------------------*/

    num-rec-ok = num-rec-ok + 1.
    run write-counter in p-log-handle ( input substitute("Обработано заказов списка экспорта: &1, из них удачно: &2", num-rec, num-rec-ok)).
    run get-stop-state in p-log-handle ( output v-stop) no-error .
    if v-stop then do:
        run write-log-and-file in p-log-handle (
                                                input 1
                                              , input log-file-name
                                              , input 1
                                              , input substitute("Процесс прерван пользователем")).
        leave _stroka.
    end.
  end. /*for each ord-list where*/
  ExpData1:route-data_clear-xmlschema ( ).
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Обработано заказов списка экспорта: &1, из них удачно: &2", num-rec, num-rec-ok)).

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


/*---------------------------&end-process-rule-call-param&-------------------------------*/
    case p-ruleset-id:
      when 1
      or
      when 5
      then do:
        assign
        v-sign = 2
        v-current-host-code = p-host-code
        v-current-obj-type = p-obj-type
        v-current-obj-code = p-obj-code
        v-current-db-num = g#db-num
        v-current-lock = (if p-save >= 0 then exclusive-lock else no-lock)
        file-name  = p-process-file-name
        .
        run bge/oxmlinir.p ( output v-oxml-exch-dir
                            ,output v-oxml-heap-dir) .
      end.
      when 2
      or
      when 6
      then do:
        assign
        v-sign = 2
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