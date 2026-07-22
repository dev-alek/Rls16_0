block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cmdnw2es.p $
$Archive: nws/cmdnw2es.p $

Обработка команды отсылки настроек машины правил (для объекта TH)

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/20/08
Author: Bakhtadze Natalya
Creation date: 05/20/08

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle as handle no-undo .
define input parameter p-imp-handle as handle    no-undo .
define input parameter p-esys-id as integer   no-undo .
define input parameter p-db-num-exp as integer   no-undo .
define input parameter p-uniq-gate-rec as character no-undo . /*gate ьаршрутизации в СПН*/
define input parameter p-esys-uniq-gate-rec as character no-undo . /*gate ьаршрутизации в esys*/
define input parameter p-counter  as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cmdnw2es.p $":U .
define variable vss-archive     as character no-undo init "$Archive: nws/cmdnw2es.p $":U .
define variable vss-description as character no-undo init "Обработка команды отсылки настроек машины правил (для объекта TH)".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/key-rec.i }
{ gbl/waitfram.i }
{ cmp/strcodec.i }
{ gbl/gate-clb.i }
{ rul/tempcxml.i }

&glob add-dump ~
run add-dump in v-cmd-proc-handle                                                                            ~
  (input v-cmd-code                                                                                          ~
  ,input ~{&table__~}                                                                                        ~
  ,input ~{&action__~}                                                                                       ~
  ,input ~{&buffer-handle~}                                                                                  ~
  ,input ~{&uniq-gate-rec-dump~}                                                                             ~
  ,output v-rec-ord                                                                                          ~
  ) no-error .                                                                                               ~
if error-status :error                                                                                       ~
then do:                                                                                                     ~
delete procedure v-cmd-proc-handle .                                                                         ~
  undo main-block, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4" ~
                                      ,vss-workfile                                                          ~
                                      ,vss-revision                                                          ~
                                      ,vss-description                                                       ~
                                      ,~{&new-line~}                                                         ~
                                      ,~{&table__~}                                                          ~
                                      ,v-cmd-code                                                            ~
                                      ,error-status:get-message(1)                                           ~
                                      ,return-value                                                          ~
                                      ) .                                                                    ~
end



define variable counter    as integer   no-undo .
define variable rec-full   as character no-undo .
define variable v-rec-name as character no-undo .
define variable log-file-name as character no-undo .
define variable v-action as character no-undo .
define variable v-curr-rowid as rowid no-undo .
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-dst-list     as character no-undo .
define variable v-command     as character no-undo .
define variable v-cmd-code    as integer no-undo .
define variable v-cmd-proc-handle as handle no-undo .
define variable v-rec-ord as recid no-undo .
define variable v-ignore as logical   no-undo .
define variable v-xmlh as handle no-undo .
define variable v-dataseth as handle no-undo .
define variable v-longchar as longchar no-undo .
define variable v-dmp-ord as int64 no-undo .
define variable v-uniq-gate-rec-dump as character no-undo .
define buffer buf_temp-xml-tables for temp-xml-tables.
define buffer buf_ext-system for ub.ext-system.
v-xmlh = buffer buf_temp-xml-tables:handle.
&scop cmd-proc-handle v-cmd-proc-handle
&scop cmd-code v-cmd-code



main-block:
do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  _counter:
  do counter = 1 to p-counter
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    run waitfram-show in this-procedure
      (input substitute("Получение команды на маршрутизацию во внешнюю систему &1. Получено записей: &2"
                        , p-esys-id
                        , counter)
      ) .
    /*заблокируем основную запись*/
    if counter = 1 then do:
      find first buf_ext-system no-lock where
                buf_ext-system.esys-id = p-esys-id
            and buf_ext-system.db-num = 0 no-error.
      if not available buf_ext-system then do:
        undo main-block, return error substitute("&1. &2&3&4Нет ВС &5"
                                                 , vss-workfile
                                                 , return-value
                                                 , {&new-line}
                                                 , error-status :get-message ( error-status :num-messages )
                                                 , p-esys-id).
      end. /*      if not available buf_ext-system then do:*/
      if not buf_ext-system.esys-have-export then do:
        run waitfram-show in this-procedure
          (input substitute("Нет экспорта в ВС &1. Игнорируем команду"
                            , p-esys-id
                            )
          ) .
        v-ignore = yes.
      end. /*if not buf_ext-system.esys-have-export then do:*/
      if not v-ignore then do:
        if buf_ext-system.esys-db-num-exp <> p-db-num-exp then do:
          p-db-num-exp = buf_ext-system.esys-db-num-exp.
        end.
        if not valid-handle(v-cmd-proc-handle ) then do:
          /* инициализируем библиотеку формирования команды */
          run nws/cmd-bush.p persistent set v-cmd-proc-handle no-error .
          if error-status:error then do:
            delete procedure v-cmd-proc-handle.
            undo main-block, return error substitute("&1 &2 &3&4Ошибка при запуске процедуры cmd-bush.p&4" +
                                                "&5&4&6"
                                                ,vss-workfile
                                                ,vss-revision
                                                ,vss-description
                                                ,{&new-line}
                                                ,error-status:get-message(1)
                                                ,return-value ).
          end. /*if error-status:error then do:*/
        end. /*if not valid-handle(v-cmd-proc-handle ) then dO:*/
        if p-db-num-exp = g#db-num then do:
          v-command = {&cmd-esys-general}.
          v-dst-list = string(p-esys-id).
        end. /*if p-db-num-exp = g#db-num then do:*/
        else do:
          assign
          v-command = substitute("&2&1&3&1&4&1&5"
                                      ,{&delim-cmd}
                                      ,{&cmd-nws2esys-general}
                                      ,p-esys-id
                                      ,p-db-num-exp
                                      ,str-encode( p-uniq-gate-rec
                                              , "" /*p-encode-char*/
                                              , {&delim-key})
                                      ).
        end. /*esle /*if p-db-num-exp = g#db-num then do:*/*/
        run begin-create-command in v-cmd-proc-handle
          (input  v-command /* p-command-name */
          ,INPUT  v-dst-list
          ,output v-cmd-code                 /* p-command-code */
          ) no-error.
        if error-status:error then do:
          delete procedure v-cmd-proc-handle .
          run  gate-clear in this-procedure (
                                              input v-dataseth
                                              ,input v-xmlh) no-error.
          undo main-block, return error substitute("&1 &2 &3&4Ошибка при создании команды &5&4" +
                                              "&6&4&7"
                                              ,vss-workfile
                                              ,vss-revision
                                              ,vss-description
                                              ,{&new-line}
                                              ,{&cmd-nws2esys-general}
                                              ,error-status:get-message(1)
                                              ,return-value ).
        end. /*if error-status :error*/
        v-longchar = ?.
        /*разбора присланного*/
        run get-gate-by-rec in this-procedure ( input p-uniq-gate-rec
                                              ,output v-dataseth
                                              ,input-output v-xmlh
                                              ,input-output v-longchar) no-error.

      end. /*if not v-ignore*/
    end. /*if v-counter = 1*/
    run nws-imps in p-imp-handle
      ( input-output counter
       ,output       rec-full
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    assign
      v-rec-name = entry( 1, rec-full, {&delim-nws} )
      v-action = entry(2, rec-full, {&delim-nws})
      v-uniq-gate-rec-dump = entry(4, rec-full, {&delim-nws})
    .
    if v-ignore then next _counter.
    find first buf_temp-xml-tables no-lock where
              buf_temp-xml-tables.tbl-name = v-rec-name no-error.
    if available buf_temp-xml-tables then do:
      run proc-load-standart in p-imp-handle
        ( input v-rec-name
          ,input v-uniq-gate-rec-dump
          ,input buf_temp-xml-tables.tbl-handle
          ,input p-imp-handle
          ,input 0
          ,output v-curr-rowid
        ) no-error.
      if error-status :error then do:
        return error return-value .
      end.
      buf_temp-xml-tables.tbl-handle:find-by-rowid( v-curr-rowid) no-error.
      if error-status:error then do:
        delete procedure v-cmd-proc-handle .
        run  gate-clear in this-procedure (
                                            input v-dataseth
                                            ,input v-xmlh) no-error.
        undo main-block, return error substitute("&1 &2 &3&4Ошибка при чтении записи № &8 команды &5&4" +
                                            "&6&4&7"
                                            ,vss-workfile
                                            ,vss-revision
                                            ,vss-description
                                            ,{&new-line}
                                            ,{&cmd-nws2esys-general}
                                            ,error-status:get-message(1)
                                            ,return-value
                                            ,counter
                                            ).

      end.
      &scop table__ v-rec-name
      &scop action__ v-action
      &scop buffer-handle buf_temp-xml-tables.tbl-handle
      &scop uniq-gate-rec-dump v-uniq-gate-rec-dump
      {&add-dump}.
   end.
   else do:
      run waitfram-hide in this-procedure .
      message
        vss-workfile vss-revision vss-description skip
        "Не предусмотрен прием таблицы " v-rec-name skip
        "в составе команды" {&cmd-dct-send} skip
        view-as alert-box error .
      if not v-ignore then do:
        delete procedure v-cmd-proc-handle .
        run  gate-clear in this-procedure (
                                            input v-dataseth
                                          ,input v-xmlh) no-error.
      end.
      return error .
   end.
  end. /*do counter*/
  if not v-ignore then do:
    if v-command begins {&cmd-nws2esys-general} then do:
      run send-command in v-cmd-proc-handle
        ( input v-cmd-code  /* p-command-code */
          ,input v-dst-list
          ) no-error .
    end.
    else do:
      run send-command-esys in v-cmd-proc-handle
        ( input v-cmd-code  /* p-command-code */
          ,input v-dst-list
          ,input g#userid
          ,output v-dmp-ord
          ) no-error .
    end.
    if error-status:error then do:
      delete procedure v-cmd-proc-handle .
      run  gate-clear in this-procedure (
                                          input v-dataseth
                                        ,input v-xmlh) no-error.
      message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при отсылке команды &1", {&cmd-rum-send} ) skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
      undo main-block, return error .
    end.
    delete procedure v-cmd-proc-handle .
  end.
  run  gate-clear in this-procedure (
                                      input v-dataseth
                                     ,input v-xmlh) no-error.
  run waitfram-hide in this-procedure .
  return ''.
end. /*doe*/

procedure write-to-log : /*не удалять!!!*/
define input parameter p-mess as character no-undo .

  do
  on error undo, return error
  :

  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input p-mess).
  end.

end procedure. /* write-to-log */