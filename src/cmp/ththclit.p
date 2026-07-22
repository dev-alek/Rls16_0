block-level on error undo, throw.
/*

$Revision: 1f78fe327cdf, 1091, rls $
$Author: ASMorozov $
$Date: Thu Dec 14 02:13:52 2017 +0300 $
$Workfile: ththclit.p $
$Archive: cmp/ththclit.p $

Получение данных по клиентам из v15.0 системы TH во временную таблицу

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/12/08
Author: Bakhtadze Natalya
Creation date: 12/12/08

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: 1f78fe327cdf, 1091, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:52 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ththclit.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cmp/ththclit.p $":U .
define variable vss-description as character no-undo init "Получение данных по клиентам из старой системы TH во временную таблицу".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ ref/extclass.i }
{ gbl/key-rec.i }
{ cmp/thth150.i }
{ cmp/thth14.i }


define variable p-copy-option as character no-undo .
define variable p-obj-type as character no-undo .
define variable p-obj-code as integer no-undo .
define variable p-rid-list as character no-undo .
define variable p-from-version as character no-undo .
define variable v-src-full-name as character no-undo .
define variable v-upper-code as integer no-undo .
define variable v-level as integer no-undo .
define variable v-counter as integer no-undo .
define variable v-rec as recid no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-ii as integer no-undo .
define variable v-ii-ok as integer no-undo .
define variable log-file-name as character no-undo .
define variable v-cli-classif-name as character no-undo .

{ cmp/ththclit.i " shared "}

DEFINE BUFFER buf_ext-classif FOR ub.ext-classif.

&glob display-message  run write-log-and-file in p-log-handle ( ~
          input 1 ~
        , input log-file-name ~
        , input 1 ~
        , input ~{&my-message~} ~
                                      )

&glob display-count-message  run write-counter in p-log-handle (input ~{&my-count-message~})

&glob hide-count-message  run hide-counter in p-log-handle

log-file-name = substitute("&1.txt", entry(1, entry(num-entries(this-procedure:file-name, {&slash-char}), this-procedure:file-name, {&slash-char}), ".")).

if num-entries(p-parameter, {&delim-par}) <> 5 then do:
  message
  substitute("Неверное количество ENTRY в составном параметре - &1, должно быть 5"
             ,num-entries(p-parameter, {&delim-par}))
  view-as alert-box error .
  return.
end.
assign
p-copy-option = entry(1, p-parameter, {&delim-par} )
p-obj-type = entry(2, p-parameter, {&delim-par} )
p-obj-code = integer(entry(3, p-parameter, {&delim-par} ))
p-rid-list =  entry(4, p-parameter, {&delim-par} )
p-from-version =  entry(5, p-parameter, {&delim-par} )
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

&scop my-message substitute("Копирование данных по клиентам из БД &1 во временную таблицу...", p-from-version)
{&display-message}.

for each clients-01:
  delete clients-01.
end.
for each firm-01:
  delete firm-01.
end.
for each person-01:
  delete person-01.
end.

case p-copy-option:
  when 'one' then do:
    find first buf_ext-classif share-lock where
          buf_ext-classif.classif-subject = {&table_clients}
      and buf_ext-classif.classif-name = v-cli-classif-name
      and buf_ext-classif.db-num = - 1
      and buf_ext-classif.charkey_one = p-obj-type
      and buf_ext-classif.key#_one = p-obj-code no-error.
    if not available buf_ext-classif then do:
      &scop my-message substitute("Не удалось определить текущую запись соответствия (&1&2 в БД &3)", p-obj-type, p-obj-code, p-from-version)
      {&display-message}.
      return.
    end.
    if buf_ext-classif.uniq-key-rec <> '' then do:
      &scop my-message substitute("УЖЕ ЕСТЬ соответствие для &1&2 БД &3 в БД v16.0 - импортировать невозможно", p-obj-type, p-obj-code, p-from-version)
      {&display-message}.
      return.
    end.
    run fill-container in this-procedure ( input buf_ext-classif.charkey_one
                                          ,input buf_ext-classif.key#_one) no-error.
    if error-status:error then do:
      &scop my-message substitute("!!!Ошибка при копировании данных по клиенту &1&2 из БД &6 во временную таблицу&3&4&3&5" ~
                                      , buf_ext-classif.charkey_one ~
                                      , buf_ext-classif.key#_one ~
                                      , ~{&new-line~} ~
                                      , error-status:get-message(1) ~
                                      , return-value  ~
                                      , p-from-version )
      {&display-message}.
    end.
  end. /*when 'one'*/
  when 'list' then do:
    _ii:
    do v-ii = 1 to num-entries(p-rid-list):
      if v-ii modulo 10 = 0 then do:
        &scop my-count-message substitute("Копирование данных по клиентам из БД &3 во временную таблицу ... записей &1 удачно &2", v-ii, v-ii-ok, p-from-version)
        {&display-count-message}.
      end.
      find first buf_ext-classif share-lock where
               recid(buf_ext-classif) = integer(entry(v-ii, p-rid-list)) no-error.
      if not available buf_ext-classif then do:
        &scop my-message substitute("Не удалось определить текущую запись соответствия (recid &1)", integer(entry(v-ii, p-rid-list)))
        {&display-message}.
        next _ii.
      end.
      if buf_ext-classif.uniq-key-rec <> '' then do:
        &scop my-message substitute("УЖЕ ЕСТЬ соответствие для &1&2 БД &3 в БД v16.0 - импортировать невозможно", buf_ext-classif.charkey_one, buf_ext-classif.key#_one, p-from-version)
        {&display-message}.
        next _ii.
      end.
      run fill-container in this-procedure ( input buf_ext-classif.charkey_one
                                            ,input buf_ext-classif.key#_one) no-error.
      if error-status:error then do:
        &scop my-message substitute("!!!Ошибка при копировании данных по клиенту& 1&2 из БД &6 во временную таблицу&3&4&3&5" ~
                                        , buf_ext-classif.charkey_one ~
                                        , buf_ext-classif.key#_one ~
                                        , ~{&new-line~} ~
                                        , error-status:get-message(1) ~
                                        , return-value  ~
                                        , p-from-version )
        {&display-message}.
      end.
      else do:
        v-ii-ok = v-ii-ok + 1.
      end.
    end.
  end. /*when 'list'*/
  when 'all' then do:
    for each buf_ext-classif share-lock where
            buf_ext-classif.classif-subject = {&table_clients}
        and buf_ext-classif.classif-name = v-cli-classif-name
        and buf_ext-classif.db-num = - 1
        and buf_ext-classif.uniq-key-rec = ''
        and buf_ext-classif.key#_three = 0
    on error  undo , next
    on stop  undo , next
    on endkey undo , next
    :
      if buf_ext-classif.charkey_one = {&shop}
      or buf_ext-classif.charkey_one = {&stock} then next.
      v-ii = v-ii + 1.
      if v-ii modulo 10 = 0 then do:
        &scop my-count-message substitute("Копирование данных по клиентам из БД &3 во временную таблицу ... записей &1 удачно &2", v-ii, v-ii-ok, p-from-version)
        {&display-count-message}.
      end.
      run fill-container in this-procedure ( input buf_ext-classif.charkey_one
                                            ,input buf_ext-classif.key#_one) no-error.
      if error-status:error then do:
        &scop my-message substitute("!!!Ошибка при копировании данных по клиенту& 1&2 из БД &6 во временную таблицу&3&4&3&5" ~
                                        , buf_ext-classif.charkey_one ~
                                        , buf_ext-classif.key#_one ~
                                        , ~{&new-line~} ~
                                        , error-status:get-message(1) ~
                                        , return-value  ~
                                        , p-from-version )
        {&display-message}.
      end.
      else do:
        v-ii-ok = v-ii-ok + 1.
      end.
    end.
  end. /*when 'all'*/
end case.
{&hide-count-message}.

procedure fill-container :
define input parameter p-src-obj-type as character no-undo .
define input parameter p-src-obj-code as integer no-undo .

define buffer src_clients for src.clients.
define buffer src_firm for src.firm.
define buffer src_person for src.person.
define buffer src_clients-attr for src.clients-attr.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  find first src_clients share-lock  where
            src_clients.obj-type = p-src-obj-type
        and src_clients.obj-code = p-src-obj-code no-error.
  if not available src_clients then do:
    undo, return error substitute("В БД &3 не найден клиент &1&2", p-src-obj-type, p-src-obj-code, p-from-version).
  end.
  case src_clients.obj-type:
    when {&cmp} then do:
      find first src_firm no-lock where
                src_firm.firm-code = p-src-obj-code no-error.
      if not available src_firm then do:
        undo, return error substitute("В БД &2 не найдена организация с кодом &1", p-src-obj-code, p-from-version).
      end.
    end.
    when {&prs} then do:
      find first src_person no-lock where
                src_person.psn-code = p-src-obj-code no-error.
      if not available src_person then do:
        undo, return error substitute("В БД &2 не найдено физ.лицо с кодом &1", p-src-obj-code, p-from-version).
      end.
    end.
  end case.
  find first clients-01 where
            clients-01.src-obj-type = src_clients.obj-type
        and clients-01.src-obj-code = src_clients.obj-code no-error.
  if available clients-01 then return.
  create clients-01.
  buffer-copy src_clients
  except obj-code grp-code
  to clients-01
  assign
  clients-01.src-obj-type = src_clients.obj-type
  clients-01.src-obj-code = src_clients.obj-code
  clients-01.src-grp-code = src_clients.grp-code
  .
  case src_clients.obj-type:
    when {&cmp} then do:
      create firm-01.
      buffer-copy src_firm
      except firm-code
      to firm-01
      assign
      firm-01.src-firm-code = src_firm.firm-code
      .

      release firm-01.
    end.
    when {&prs} then do:
      create person-01.
      buffer-copy src_person
      except psn-code
      to person-01
      assign
      person-01.src-psn-code = src_person.psn-code
      .
      release person-01.
    end.
  end case.
  release clients-01.
end.

end procedure. /* fill-container */