block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ini-name.p $
$Archive: utl/ini-name.p $

Инициализация имени контрагентов в документах

Автор: Суслов Алексей Юрьевич
Дата создания: 09/19/05
Author: Alexey Suslov
Creation date: 09/19/05

*/

define input parameter p-install as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ini-name.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ini-name.p $":U .
define variable vss-description as character no-undo init "Инициализация имени контрагентов в документах".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ gbl/cur-time.i }

define variable v-program-name  as character no-undo init "ini-name" .
define variable ind             as integer no-undo init 0 .
define variable v-upd-count     as integer no-undo .
define variable v-err-count     as integer no-undo .

define variable l-ok            as logical no-undo .
define variable v-today         as date    no-undo.
define variable v-time          as integer no-undo.

define temp-table temp-clients no-undo
  field obj-type like ub.clients.obj-type
  field obj-code like ub.clients.obj-code
  field obj-name like ub.clients.obj-name

  index xpk is primary unique obj-type obj-code
.

if p-install = false then do:
  assign
    l-ok = false
  .
  message
    "Инициализация названий контрагентов в складских документах" skip
    "по справочнику клиентов." skip
    "" skip
    "Обрабатываются все документы базы данных." skip
    "Информация по новостям не передается, поэтому, в других базах данных" skip
    "также надо будет запустить данную утилиту." skip
    "Информация об измененных документах регистрируется в файлах" skip
    "журнал изменений" v-program-name + ".txt":u skip
    "журнал ошибок"    v-program-name + ".err":u skip
    "список контрагентов" v-program-name + ".cli":u skip
    "" skip
    "Продолжить?" skip
    view-as alert-box question buttons OK-Cancel update l-ok .
  if l-ok <> true then do:
    return. /* --->>>--- */
  end.

end.

def frame a
  ind label "Обработано документов" skip
  with frame a view-as dialog-box with side-labels three-d
    title "Имена контрагентов в накладных"
  .
view frame a.

on write of ub.trn-doc override do: end.

for each ub.trn-doc
:
  assign
    ind = ind + 1
  .
  if ind mod 10 = 0 then do:
    display
      ind
      with frame a view-as dialog-box.
    process events .
  end.

  find ub.clients no-lock
    where ub.clients.obj-type = ub.trn-doc.cli-type
      and ub.clients.obj-code = ub.trn-doc.cli-code
    no-error .
  if available ub.clients then do:
    if ub.trn-doc.cli-name <> ub.clients.obj-name then do:
      output to value(v-program-name + ".txt" ) append .
      run cur-time in this-procedure ( output v-today
                                     , output v-time
                                     ).
      export
        "update_trn-doc_old-cli-name_new-cli-name"
        ub.trn-doc.obj-type
        ub.trn-doc.obj-code
        ub.trn-doc.doc-code
        ub.trn-doc.cli-type
        ub.trn-doc.cli-code
        ub.trn-doc.cli-name
        ub.clients.obj-name
        string(v-today, '99/99/9999')
        string(v-time, 'HH:MM')
        .
      output close .

      find first temp-clients
        where temp-clients.obj-type = ub.clients.obj-type
          and temp-clients.obj-code = ub.clients.obj-code
        no-error .
      if not available temp-clients then do:
        create temp-clients .
        assign
          temp-clients.obj-type = ub.clients.obj-type
          temp-clients.obj-code = ub.clients.obj-code
          temp-clients.obj-name = ub.clients.obj-name
        .
      end.
      assign
        v-upd-count = v-upd-count + 1
      .

      assign
        ub.trn-doc.cli-name = ub.clients.obj-name
      .
    end.
  end.
  else do:
    output to value(v-program-name + ".err" ) append .
    run cur-time in this-procedure ( output v-today
                                   , output v-time
                                   ).
    export
      "update_trn-doc_error_cli-type_cli-code_cli-name"
      ub.trn-doc.obj-type
      ub.trn-doc.obj-code
      ub.trn-doc.doc-code
      ub.trn-doc.cli-type
      ub.trn-doc.cli-code
      ub.trn-doc.cli-name
      "unknown"
      string(v-today, '99/99/9999')
      string(v-time, 'HH:MM')
      .
    output close .

    assign
      v-err-count = v-err-count + 1
    .
  end.
end.

for each temp-clients
:
  output to value(v-program-name + ".cli":u) append .
  run cur-time in this-procedure ( output v-today
                                 , output v-time
                                 ).
  export
    temp-clients.obj-type
    temp-clients.obj-code
    temp-clients.obj-name
    string(v-today, '99/99/9999')
    string(v-time,  'HH:MM')
    .
  output close .
end.

if p-install = false then do:
  message
    "Инициализация закончена успешно." skip
    "Изменено записей" v-upd-count skip
    "Ошибочных записей" v-err-count skip
    "Информация об измененных и ошибочных записях выводится в файлы" skip
    "журнал изменений" v-program-name + ".txt":u skip
    "журнал ошибок" v-program-name + ".err":u skip
    "список контрагентов" v-program-name + ".cli":u skip
    view-as alert-box information .
end.