block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ththclis.p $
$Archive: cmp/ththclis.p $

Сохранение по клиентам из старой версии системы TH

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/12/08
Author: Bakhtadze Natalya
Creation date: 12/12/08

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ththclis.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cmp/ththclis.p $":U .
define variable vss-description as character no-undo init "Сохранение по клиентам из старой версии системы TH".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ ref/extclass.i }
{ gbl/key-rec.i }
{ ref/cgrplbfn.i }
{ cmp/thth150.i }
{ cmp/thth14.i }

define variable p-from-version as character no-undo .
define variable p-copy-option as character no-undo .
define variable p-obj-type as character no-undo .
define variable p-obj-code as integer no-undo .
define variable p-rid-list as character no-undo .
define variable v-src-full-name as character no-undo .
define variable v-upper-code as integer no-undo .
define variable v-level as integer no-undo .
define variable v-counter as integer no-undo .
define variable v-rec as recid no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-ii as integer no-undo .
define variable v-ii-ok as integer no-undo .
define variable log-file-name as character no-undo .
define variable v-rowid as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-rid as recid no-undo .
define variable v-classif-name as character no-undo .
define variable v-cli-classif-name as character no-undo .
define buffer clients_ext-classif for ub.ext-classif.
define buffer buf_clients for ub.clients.
define buffer buf_cli-grp for ub.cli-grp.

{ cmp/ththclit.i " shared "}


&glob display-message  run write-log-and-file in p-log-handle ( ~
          input 1 ~
        , input log-file-name ~
        , input 1 ~
        , input ~{&my-message~} ~
                                      )

&glob display-count-message  run write-counter in p-log-handle (input ~{&my-count-message~})

&glob hide-count-message  run hide-counter in p-log-handle

if num-entries(p-parameter, {&delim-par}) <> 1 then do:
  message
  substitute("Неверное количество ENTRY в составном параметре - &1, должно быть 1"
             ,num-entries(p-parameter, {&delim-par}))
  view-as alert-box error .
  return.
end.
assign
p-from-version =  entry(1, p-parameter, {&delim-par} )
.

case p-from-version:
  when {&thth150-from-version} then do:
    assign
    v-cli-classif-name = {&extclass_clients_th-th150}
    .
  end.
  when {&thth14-from-version} then do:
    assign
    v-cli-classif-name = {&extclass_clients_th-th14}
    .
  end.
end case.


log-file-name = substitute("&1.txt", entry(1, entry(num-entries(this-procedure:file-name, {&slash-char}), this-procedure:file-name, {&slash-char}), ".")).


&scop my-message substitute("Сохранение данных по клиентам из БД &1 ...", p-from-version)
{&display-message}.

_clients:
for each clients-01:
  v-ii = v-ii + 1.
  if v-ii modulo 10 = 0 then do:
    &scop my-count-message substitute("Сохранение данных по клиентам из БД &3 ...записей &1 удачно &2", v-ii, v-ii-ok, p-from-version)
    {&display-count-message}.
  end.

  /*проверим название группы*/
  define variable v-full-name as character no-undo .
  define variable v-grp-code as integer no-undo .

  /*найдем нужную группу*/
  v-grp-code = -1.
  run cgrplib-get-node-from-full-name ( input clients-01.grp-name
                                      ,output v-grp-code) no-error.

  find first buf_cli-grp no-lock where
        buf_cli-grp.node-code = v-grp-code no-error.
  if not available buf_cli-grp
  or can-find(ub.cli-grp no-lock where ub.cli-grp.upper-code = v-grp-code)
  then do:
    &scop my-message substitute("Не удалось найти запись для группы клиентов &2, которая в БД &3 имеет код &1 или она нетерминальная" ~
                                 , clients-01.grp-name ~
                                 , clients-01.src-grp-code ~
                                 , p-from-version )
    {&display-message}.
    next _clients.
  end.
  assign
  clients-01.grp-code = buf_cli-grp.node-code.


  find first clients_ext-classif share-lock where
            clients_ext-classif.classif-subject  = {&table_clients}
        and  clients_ext-classif.classif-name  = v-cli-classif-name
        and clients_ext-classif.db-num = -1
        and clients_ext-classif.charkey_one = clients-01.src-obj-type
        and clients_ext-classif.key#_one = clients-01.src-obj-code no-error .
  if not available clients_ext-classif then do:
    &scop my-message substitute("Не удалось найти запись соответствия для клиента &1&2 в БД &3", clients-01.src-obj-type, clients-01.src-obj-code, p-from-version)
    {&display-message}.
    next _clients.
  end.
  if clients_ext-classif.uniq-key-rec <> '' then do:
    &scop my-message substitute("УЖЕ ЗАДАНО задано соответствие для клиента &1&2 в БД &3", clients-01.src-obj-type, clients-01.src-obj-code, p-from-version)
    {&display-message}.
    next _clients.
  end.
  case clients-01.src-obj-type:
    when {&cmp} then do:
      v-rid = ?.
      find first firm-01 where
                firm-01.src-firm-code = clients-01.src-obj-code .
      run ref/firm1.p (
            input parparentproc
          ,input-output v-rid
          ,input {&add-def}
          ,input "cli-all":U
          ,input yes /*p-silent*/
          ,input - abs(clients-01.obj-code) /*генерация уникального номера внутри*/
          ,input 0
          ,input clients-01.obj-name
          ,input 0 /*p-lim-kr*/
          ,input substitute("&3 &1&2", clients-01.src-obj-type, clients-01.src-obj-code, p-from-version)
          ,input clients-01.grp-code
          ,input firm-01.addres1
          ,input firm-01.addres2
          ,input firm-01.city
          ,input firm-01.contact-psn
          ,input firm-01.director
          ,input firm-01.e-mail
          ,input firm-01.engl-name
          ,input firm-01.fax
          ,input firm-01.given-by
          ,input firm-01.ind
          ,input firm-01.inn
          ,input yes /*p-no-check-inn*/
          ,input firm-01.is-pboul
          ,input firm-01.kpp
          ,input firm-01.okonh
          ,input firm-01.okpo
          ,input firm-01.passp-num
          ,input firm-01.passp-ser
          ,input firm-01.phone
          ,input firm-01.phone1-note
          ,input firm-01.post-addr1
          ,input firm-01.post-addr2
          ,input '' /*post-city*/
          ,input '' /*post-inn*/
          ,input 0 /*reg-code*/
          ,input firm-01.telex
          ,input firm-01.tobj-code
          ,input no /* p-turnover-buyer     */
          ,input no /*p-turnover-buyer-gds */
          ) no-error .
    end.
    when {&prs} then do:
      find first person-01 where
                person-01.src-psn-code = clients-01.src-obj-code .
      run ref/person1.p (
        input parparentproc
        ,input this-procedure:handle
        ,input-output v-rid
        ,input {&add-def}
        ,input "cli-all":U
        ,input yes  /*p-silent*/
        ,input - abs(clients-01.obj-code)  /*генерация уникального номера внутри!!!*/
        ,input 0 /*stts*/
        ,input clients-01.obj-name
        ,input 0 /*lim-kr*/
        ,input substitute("&3 &1&2", clients-01.src-obj-type, clients-01.src-obj-code, p-from-version)
        ,input clients-01.grp-code
        ,input person-01.address
        ,input person-01.city
        ,input ? /*date-birth*/
        ,input person-01.e-mail
        ,input person-01.fax
        ,input person-01.firm-code
        ,input person-01.firm-name
        ,input ? /*gender*/
        ,input person-01.given-by
        ,input person-01.ind
        ,input person-01.inn
        ,input yes     /*p-no-check-inn*/
        ,input person-01.is-pboul
        ,input person-01.kpp
        ,input person-01.name1
        ,input person-01.name2
        ,input person-01.okonh
        ,input person-01.okpo
        ,input person-01.passp-num
        ,input person-01.passp-ser
        ,input person-01.phone1
        ,input person-01.phone1-note
        ,input person-01.position
        ,input person-01.post-box
        ,input '' /*post-address*/
        ,input '' /*post-city*/
        ,input '' /*post-ind*/
        ,input 0 /*reg-code*/
        ,input no /* p-turnover-buyer     */
        ,input no /*p-turnover-buyer-gds */
        ) no-error .

    end.
  end case.
  if error-status:error then do:
    &scop my-message  substitute("Не удалось сохранить запись о клиенте &1&2 из системы  &6&3&4&3&5" ~
                          ,clients-01.src-obj-type ~
                          ,clients-01.src-obj-code ~
                          ,~{&new-line~} ~
                          , error-status:get-message(1) ~
                          , return-value ~
                          , p-from-version )
    {&display-message}.
  end.
  else do:
    find first buf_clients no-lock where
            recid(buf_clients) = v-rid.
    run gen-key-rec in this-procedure ( input {&table_clients}
                                      ,input (buffer buf_clients:handle)
                                      ,output v-uniq-key-rec).
    v-rec = recid(clients_ext-classif).
    run ref/extclas1.p (
                          input {&update}
                        ,input yes /*p-silent*/
                        ,input-output v-rec
                        ,input {&table_clients} /*p-classif-subject */
                        ,input v-cli-classif-name
                        ,input clients_ext-classif.db-num /*p-db-num*/
                        ,input clients-01.src-obj-code /*p-Key#_One*/
                        ,input clients_ext-classif.key#_two
                        ,input clients_ext-classif.key#_three
                        ,input clients-01.src-obj-type /*p-CharKey_One*/
                        ,input clients_ext-classif.CharKey_Two
                        ,input clients_ext-classif.CharKey_Three
                        ,input clients_ext-classif.nonunique /*p-nonunique*/
                        ,input v-uniq-key-rec /*p-uniq-key-rec*/
                        ) no-error.
    if error-status:error then do:
      &scop my-message substitute('Ошибка при сохранении соответствия по клиенту &6 &1&2:&3&4&3&5' ~
                                    , clients-01.src-obj-type ~
                                    , clients-01.src-obj-code ~
                                    ,~{&new-line~} ~
                                    , error-status:get-message(1) ~
                                    , return-value ~
                                    , p-from-version )
      {&display-message}.
    end.
    else do:
      v-ii-ok = v-ii-ok + 1.
    end.
  end.
end.
{&hide-count-message}.