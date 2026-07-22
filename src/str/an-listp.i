/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры и триггера обшие для всех механизмов список

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/15/03
Author: Bakhtadze Natalya
Creation date: 12/15/03

*/


&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/key-rec.i }

&if defined(ui-on) = 0 &then
&glob ui-on ui-on
&endif
define variable v-no-context as logical no-undo .
define variable v-user-obj-type as character no-undo .
define variable v-user-obj-code as integer no-undo .

FUNCTION prepare-rowid returns character ( input p-uniq-key-rec as character
                                         , input p-no-context as logical ):
define variable v-uniq-key-rec as character no-undo .
if p-no-context and p-uniq-key-rec begins {&table_user-obj} then do:
  v-uniq-key-rec = {&table_clients} + {&delim-key} +
                  entry(4, p-uniq-key-rec, {&delim-key}) + {&delim-key} +
                  entry(5, p-uniq-key-rec, {&delim-key}).
end.
else do:
  v-uniq-key-rec = p-uniq-key-rec.
  case entry(1, p-uniq-key-rec, {&delim-key}):
     when {&table_user-obj} then do:
       entry(lookup("user-id", buffer ub.user-obj:handle:keys) + 1, v-uniq-key-rec, {&delim-key}) = v-cntxt-userid.
       entry(lookup("db-num", buffer ub.user-obj:handle:keys) + 1, v-uniq-key-rec, {&delim-key}) = string(v-cntxt-db-num).
     end.
  end case.
end.
return v-uniq-key-rec.
end function.

&glob get-rowid  run gen-row-keyr  in this-procedure (  input prepare-rowid( buf_{1}-hist.item_, v-no-context) ~
                                                       ,input ?                   ~
                                                       ,input 'ub'                ~
                                                       ,input ?                   ~
                                                       ,input no-lock             ~
                                                       ,output v-rowid           ~
                                                       ,output v-tbl-name) no-error . ~
                 if error-status:error then


procedure find-user-obj-rowid :
define input parameter p-rowid as rowid no-undo .
define input parameter p-no-context as logical no-undo .
define output parameter p-user-obj-type as character no-undo .
define output parameter p-user-obj-code as integer no-undo .
define buffer user-obj_clients for ub.clients.
define buffer user-obj_user-obj for ub.user-obj .
if p-no-context then do:
  find first user-obj_clients no-lock where rowid(user-obj_clients) = p-rowid.
  assign
  p-user-obj-type = user-obj_clients.obj-type
  p-user-obj-code = user-obj_clients.obj-code.
end.
else do:
  find first user-obj_user-obj no-lock where rowid(user-obj_user-obj) = p-rowid no-error.
  if not available user-obj_user-obj then do:
    undo, return error substitute("Не удалось выполнить в данной БД записанные действия пользователя").
  end.
  assign
  p-user-obj-type = user-obj_user-obj.obj-type
  p-user-obj-code = user-obj_user-obj.obj-code.
end.
end procedure. /* find-user-obj-rowid */


&glob assign-nums assign                                         ~
                  buf_{1}-hist.num-add  = lns-cnt - v-num-add     ~
                  buf_{1}-hist.num-recs = (if line-mode = {&leave} ~
                                           then (tot-lns + buf_{1}-hist.num-add) ~
                                           else (tot-lns + (if line-mode = {&add-def} then 1 else - 1) * lns-cnt)) ~
                  tot-lns               = (if line-mode = {&leave} then lns-cnt else tot-lns)   ~
                  buf_{1}-hist.num-ignored = lns-ignore  - v-num-ignored  ~
                  v-num-add             = lns-cnt                 ~
                  v-num-ignored         = lns-ignore

define variable an-listp-start-macro-id as integer no-undo init ?.
define variable an-listp-end-macro-id as integer no-undo  init ?.
define variable an-listp-macros-label-id as integer   no-undo .
define variable v-macro-is-running as logical no-undo .
define variable v-current-step as integer no-undo .
define variable v-expand as logical no-undo .
define variable v-downed as character no-undo .
&if "{4}" <> "pre-macro" and "{4}" <> "managed"
&then
define variable p-title as character no-undo .
define variable bttns as character no-undo .
define variable p-keep-query as logical no-undo .
&endif

{ cmp/listhist.i keep-macro-list " " }

procedure assign-nums :
define input-output parameter p-num-add as integer no-undo .
define input-output parameter p-num-rec as integer no-undo .
define input-output parameter p-num-ignored as integer no-undo .
define input parameter p-line-mode as character no-undo .
assign
p-num-add  = lns-cnt - v-num-add
p-num-rec = (if line-mode = {&leave}
                          then (tot-lns + p-num-add)
                          else (tot-lns + (if line-mode = {&add-def} then 1 else - 1) * lns-cnt))
tot-lns               = (if line-mode = {&leave} then lns-cnt else tot-lns)
p-num-ignored = lns-ignore  - v-num-ignored
v-num-add             = lns-cnt
v-num-ignored         = lns-ignore
.
END PROCEDURE.

ON CHOOSE OF B-add IN FRAME {&frame-name} /* Добавить */
or INSERT-MODE of br-list
DO:
define variable glog as logical no-undo .
define buffer buf-{1}-hist for {1}-hist.
define buffer buf_macro-list-hist for macro-list-hist.
define buffer buf_keep-macro-list-hist for keep-macro-list-hist.
 if p-keep-query then do:
    glog = no.
    message "Реинициализация списка. Вы уверены ?"
            view-as alert-box question buttons OK-Cancel update glog.
    if not glog then return no-apply.
    if session:set-wait-state( "COMPILER" )  then .
    for each {1}:
      delete {1}.
    end.
    if session:set-wait-state( "" )  then .
    tot-lns = 0.
    v-seq = 1.
    for each buf-{1}-hist:
      delete buf-{1}-hist.
    end.
   for each buf_keep-macro-list-hist:
     create buf_macro-list-hist.
   end.
   run proc-macro-play in this-procedure ( input 0, input yes, input 0).
   run create-{1}-hist in this-procedure (
                                          input {&add-def}
                                        , input-output v-seq
                                        , input 0
&if "{2}" = "doc-list" &then
                                        , input '':U
&endif
                                        , input '0':U
                                        , input "# Реинициализация списка."
                                        , input 0
                                        , input "init"
                                        , input '':U
                                        , input '':U
                                        , input '':U
                                        , input ?
                                        ).
    display
    tot-lns @ f-tot-lns
&if "{2}" = "gds-list" or "{2}" = "scns-list" &then
    ? @ ub.clients.obj-name
    ? @ ub.gds-prt.node-name
    ? @ ub.bar-code.b-code
&endif
    with frame {&frame-name}.
    run {&UI-on} in this-procedure .
 end.
 else do:
   assign rs-list-method = "single".
   run proc-b-add in this-procedure(input no
                                  ,input ?
                                  ,input rs-list-method
&if "{2}" = "doc-list" &then
                                  ,input  ? /*не из макроса неважно*/
&endif
                                  ,input rs-status)  no-error .
  if error-status:error then return no-apply.
end.
END.

ON CHOOSE OF B-del IN FRAME {&frame-name} /* Удалить */
or DELETE-CHARACTER of br-list
DO:
  if not available {1} then return no-apply.
  assign rs-list-method = "single".
&if "{2}" = "bb-list" &then
  run proc-b-del in this-procedure(no, ?, (rs-list-method + {&delim-par} +
                                           (if {1}.b-str <> '':U and not {1}.loc-ean
                                           then {&table_prod-bc}
                                           else (if {1}.loc-ean
                                                 then 'loc-ean':U
                                                 else {&table_bar-code})
                                           )
                                           )
  , rs-status) no-error.
&else
    run proc-b-del in this-procedure(
                                               input no
                                              ,input ?
                                              ,input rs-list-method
&if "{2}" = "doc-list" &then
                                              ,input ? /*не из макроса неважно*/
&endif
                                              ,input rs-status) no-error .

&endif
  if error-status:error then return no-apply.
END.

ON CHOOSE OF B-rest IN FRAME {&frame-name} /* Оставить */
DO:
if not available {1} then return no-apply.
  assign rs-list-method = "single".
&if "{2}" = "bb-list" &then
  run proc-b-rest in this-procedure(no, ?, (rs-list-method + {&delim-par} +
                                           (if {1}.b-str <> '':U and not {1}.loc-ean
                                           then {&table_prod-bc}
                                           else (if {1}.loc-ean
                                                 then 'loc-ean':U
                                                 else {&table_bar-code})
                                           )
                                           )
  , rs-status) no-error.
&else
 run proc-b-rest in this-procedure(
                                                input no
                                               ,input ?
                                               ,input rs-list-method
&if "{2}" = "doc-list" &then
                                               ,input  ? /*не из макроса неважно*/
&endif
                                               ,input rs-status) no-error .

&endif
  if error-status:error then return no-apply.
END.

&if "{2}" = "gds-list"
or  "{2}" = "dc-list"
or  "{2}" = "cli-list"
&then

on choose of MENU-ITEM m-macro-file in menu m-play DO:
  assign
  macro-play-option = 'file':U.
  APPLY "CHOOSE" to b-macro in frame {&frame-name}.
end.

on choose of MENU-ITEM m-macro-lob in menu m-play DO:
  assign
  macro-play-option = 'lob':U.
  APPLY "CHOOSE" to b-macro in frame {&frame-name}.
end.



ON CHOOSE OF B-macro IN FRAME {&frame-name} /* Macro */
DO:
if macro-play-option = '':U then do:
      run gbl/pop-up.p ( input self:handle, input no) no-error.
end.
if macro-play-option = '':U then return no-apply.
run proc-b-macro in this-procedure ( input macro-play-option) no-error .
if error-status:error then return no-apply.
END.

&endif


&if "{2}" = "bb-list"
or  "{2}" = "chk-list"
or  "{2}" = "doc-list"
&then
ON CHOOSE OF B-macro IN FRAME {&frame-name} /* Macro */
DO:

run proc-b-macro in this-procedure ( input 'file') no-error .
if error-status:error then return no-apply.
END.

&endif

&if "{2}" = "gds-list"
or  "{2}" = "bb-list"
or  "{2}" = "dc-list"
or  "{2}" = "cli-list"
or  "{2}" = "chk-list"
or  "{2}" = "doc-list"
&then


ON CHOOSE OF B-record IN FRAME {&frame-name} /* запись */
DO:
define variable glog as logical no-undo .
message
"Начать запись макроса формирования списка?"
view-as alert-box QUESTION buttons yes-no update glog.
if not glog then return no-apply.
assign
an-listp-start-macro-id = v-seq
an-listp-end-macro-id = ?
.
&if "{2}" = "gds-list"
or  "{2}" = "dc-list"
or  "{2}" = "cli-list"
&then
  menu-item m-macro-file:label in menu m-play = "Ранее записанный макрос формирования списка товаров".
  menu-item m-macro-lob:sensitive in menu m-play = no.
&endif
disable
b-record with frame {&frame-name} .
hide
b-record
b-macro
in frame {&frame-name} .
enable
b-stop with frame {&frame-name} .
run create-{1}-hist in this-procedure(input {&add-def}
                                    , input-output v-seq
                                    , input 0
&if "{2}" = "doc-list" &then
                                    , input '':U
&endif
                                    , input 'o':U
                                    , input "Начата запись макроса формирования списка"
                                    , input tot-lns
                                    , input 'macro':U
                                    , input '':U /*stts*/
                                    , input '':U
                                    , input '':U
                                    , input ?
                                    ).
END.

ON CHOOSE OF B-stop IN FRAME {&frame-name} /* Macro */
DO:
define variable glog as logical no-undo .
define variable v-id as integer no-undo .
define buffer buf_{1}-hist for {1}-hist.
message
"Закончить запись макроса формирования списка?"
view-as alert-box QUESTION buttons yes-no update glog.
if not glog then return no-apply.
assign
an-listp-end-macro-id = v-seq.
disable
b-stop with frame {&frame-name} .
hide
b-stop in frame {&frame-name} .
enable
b-record
b-macro
with frame {&frame-name} .
run create-{1}-hist in this-procedure(input {&add-def}
                                    , input-output v-seq
                                    , input 0
&if "{2}" = "doc-list" &then
                                    , input '':U
&endif
                                    , input '[]':U
                                    , input "Закончена запись макроса формирования списка"
                                    , input tot-lns
                                    , input 'macro':U
                                    , input '':U /*stts*/
                                    , input '':U
                                    , input '':U
                                    , input ?
                                    ).
/*запишем во временную таблицу*/
for each macro-list-hist:
  delete macro-list-hist.
end.
for each buf_{1}-hist where
        buf_{1}-hist.id >=  an-listp-start-macro-id
  and  buf_{1}-hist.id <=  an-listp-end-macro-id:
  create macro-list-hist.
  buffer-copy buf_{1}-hist
  except id num-recs num-add num-ignored
  to macro-list-hist
  assign
  macro-list-hist.id = (if macro-list-hist.line = 0 then v-id + 1 else v-id)
  v-id = (if macro-list-hist.line = 0 then v-id + 1 else v-id)
  .
end.
END.

ON CHOOSE OF b-clear-macro IN FRAME {&frame-name} /* Macro */
DO:
disable
b-clear-macro with frame {&frame-name} .
assign
an-listp-start-macro-id = ?
an-listp-end-macro-id = ?
an-listp-macros-label-id = 0
.
&if "{2}" = "gds-list"
or  "{2}" = "dc-list"
or  "{2}" = "cli-list"
&then
menu-item m-macro-lob:sensitive in menu m-play = yes.
&endif
for each macro-list-hist:
  delete macro-list-hist.
end.
hide
b-clear-macro in frame {&frame-name} .
enable
b-record
b-macro
with frame {&frame-name} .
END.


&endif

ON VALUE-CHANGED OF br-option IN FRAME {&frame-name} /* Browse 2 */
DO:
  assign
  Rs-list-method = temp-list.fvalue
  .
  &if "{2}" = "bb-list" &then
  run proc-cd2 in this-procedure.
  &endif

  run proc-vc-rs-list-method in this-procedure no-error .
  if error-status:error then return no-apply.

END.


PROCEDURE get-operation :
define input parameter p-message as character no-undo .
define output parameter p-operation as integer no-undo .

  do
  on error undo, return error
  :
    run gbl/d-askw.w (
                  input "Выбор операции над заданным списком"
                 ,input (p-message + {&new-line} +
                         "Выберите операцию, которую Вы хотите применить к полученному списку" +  {&new-line} )
                 ,input "|"
                ,input  ("Добавить" + (if p-keep-query then "^disable" else '':U) + "|" +
                         "Удалить" + "|" +
                         "Оставить" + "|" +
                         "Отказ")
                 ,input ("Добавить полученный список к уже имеющемуся" + "|" +
                        "Удалить полученный список из уже имеющегося" + "|" +
                        "Оставить в уже имеющемся списке только элементы полученного списка" +  "|" +
                        "Ничего не делать")
                 ,input  (if p-keep-query then {&del-operation} else {&add-operation})
                 ,input  {&cancel-operation}
                 ,output p-operation).
   if p-operation = {&cancel-operation} then do:
      return error .
   end.
  end. /*doe*/
END PROCEDURE.


PROCEDURE proc-fill-temp-list :

  define variable v-index               as integer   no-undo .
  define variable v-num-entries-options as integer   no-undo .

  do
  on error undo, return error
  :
    assign
      v-num-entries-options = num-entries({&all-options})
    .

    do v-index = 1 to v-num-entries-options by 2
    :
      create temp-list.
      assign
        temp-list.fname  = trim(entry(v-index
                                     ,{&all-options}
                                     )
                               ,{&space-char}
                               )
        temp-list.fvalue = trim(entry(v-index + 1
                                     ,{&all-options}
                                     )
                               ,{&space-char}
                               )
        temp-list.id     = v-index
      .
    end.
  end.
END PROCEDURE.

&if "{2}" = "gds-list"
or "{2}" = "bb-list"
or  "{2}" = "dc-list"
or  "{2}" = "cli-list"
or  "{2}" = "chk-list"
or  "{2}" = "doc-list"
&then
procedure proc-b-macro :
define input parameter p-option as character no-undo .
define variable glog as logical no-undo .
define variable v-id as integer no-undo .
define variable v-result as character no-undo .
define variable v-des as character no-undo .
define variable v-hist-mode as character no-undo .
define variable v-file as logical no-undo .
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable v-rid-list as character no-undo .
define variable v-ok as logical no-undo .

define buffer buf_{1}-hist for {1}-hist.
define buffer buf_clob-bind for ub.clob-bind.
define buffer buf_clob-data for ub.clob-data.

do
on error undo, return error
:
  if v-macro-is-running then do:
  end.
  else do:
    glog = yes.
    if an-listp-start-macro-id >= 1 then do:
      case p-option:
        when "file" then do:
      message
      "Согласно командам формирования списка из записанного макроса"
      view-as alert-box question buttons OK-Cancel update glog.
        end.
        when "lob" then do:
          message
          "Нелья!"
          view-as alert-box question buttons OK-Cancel update glog.
          run {&ui-on} in this-procedure .
          return error.
        end.
      end case.
      if not glog then do:
        run {&ui-on} in this-procedure .
        return error.
      end.
      if an-listp-end-macro-id = ? then do:
        assign
        an-listp-end-macro-id  = v-seq.
        for each macro-list-hist:
          delete macro-list-hist.
        end.
        for each buf_{1}-hist where
                buf_{1}-hist.id >=  an-listp-start-macro-id
          and  buf_{1}-hist.id <=  an-listp-end-macro-id:
          create macro-list-hist.
          buffer-copy buf_{1}-hist
          except id num-recs num-add num-ignored
          to macro-list-hist
          assign
          macro-list-hist.id = (if macro-list-hist.line = 0 then v-id + 1 else v-id)
          v-id = (if macro-list-hist.line = 0 then v-id + 1 else v-id)
          macro-list-hist.done = no
          .
        end.
      end.
      else do:
        find last macro-list-hist no-error.
        if available macro-list-hist then do:
          v-id = macro-list-hist.id.
        end.
      end.
    end. /*if an-listp-start-macro-id >= 1 then do:*/
    else do:
      case p-option:
        when "file" then do:
      message
      "Согласно командам формирования списка из ранее сохраненного в файле макроса"
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run {&UI-on} in this-procedure .
        return error.
      end.
      system-dialog get-file f-name
        filters "Макрос формирования списка *.{3}" "*.{3}"
        title "Выберите файл макроса"
        INITIAL-DIR "."
        return-to-start-dir
        must-exist
        /* use-filename */
        update glog
        default-extension "{3}".
      if not glog then do:
        run {&UI-on} in this-procedure .
        return error.
      end.
        end.
        when "lob" then do:
          message
          "Согласно командам формирования списка из макроса, сохраненного в БД"
          view-as alert-box question buttons OK-Cancel update glog.
          if not glog then do:
            run {&UI-on} in this-procedure .
            return error.
          end.
          run ref/clobbnds.w ( input parparentproc
                              ,input this-procedure:handle
                              ,input 'b-sel' /*bttns*/
                              ,input "uniq-key-rec" /*p-list-mode*/
                              ,input "" /*p-mode*/
                              ,input {&lob-res-list-macro}
                              ,input '{2}' /*p-unique-key-rec*/
                              ,input -1 /*p-db-num*/
                              ,input-output v-rid-list) no-error.
          if v-rid-list = '' then do:
            run {&UI-on} in this-procedure.
            return error.
          end.
          find first buf_clob-bind no-lock where
                    recid(buf_clob-bind) = integer(v-rid-list) no-error.
          if not available buf_clob-bind then do:
            message
            "Не найдена ссылка на макрос, сохраненный в БД!"
            view-as alert-box error .
            run {&UI-on} in this-procedure .
            return error.
          end.
          find first buf_clob-data no-lock where
                    buf_clob-data.db-num = buf_clob-bind.db-num
                and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.
          if not available buf_clob-data then do:
            message
            "Не найдена ссылка на макрос, сохраненный в БД!"
            view-as alert-box error .
            run {&UI-on} in this-procedure .
            return error.
          end.
          if buf_clob-data.db-num <> v-cntxt-db-num then do:
            message
            substitute("Возможно, не все действия пользователя БД &1 удастся воспроизвести!&2Продолжить?"
                      , buf_clob-data.db-num
                      , {&new-line})
           view-as alert-box question buttons yes-no update v-ok.
           if not v-ok then do:
              run {&UI-on} in this-procedure .
              return error.
           end.
          end.
          run gbl/_tmpfile.p ( input ""
                        ,input "tmp"
                        ,output v-file-name) .
          copy-lob from object buf_clob-data.cdata
          to file f-name.
          run gbl/filename.p
            (input  v-file-name
            ,output f-name              /* p-full-path        */
            ,output v-path      /* p-path             */
            ,output v-file-name         /* p-file-name        */
            ,output v-file-name-no-ext  /* p-file-name-no-ext */
            ,output v-file-name-ext     /* p-file-name-ext    */
            ) no-error .
          if error-status:error then do:
          end.
        end.
      end case.
      for each macro-list-hist:
        delete macro-list-hist.
      end.
      input stream sout from value (f-name).
      _macro:
      repeat:
        create macro-list-hist.
        import stream sout macro-list-hist no-error.
        if error-status:error then do:
            undo _macro, next _macro.
        end.
        assign
        macro-list-hist.num-rec = 0
        macro-list-hist.num-add = 0
        macro-list-hist.num-ignored = 0
        v-id = (if macro-list-hist.line = 0 then v-id + 1 else v-id)
        macro-list-hist.done = no
        .
      end. /*repeat*/
      find first macro-list-hist where
              macro-list-hist.id = 0.
      delete macro-list-hist.
      input stream sout close.
      If p-option = "lob" then do:
       os-delete value(f-name).
      end.
      v-file = yes.
    end. /*из файла*/
    /*считывание закончено*/
    an-listp-macros-label-id = v-seq.
    run create-{1}-hist in this-procedure(input {&add-def}
                                        , input-output v-seq
                                        , input 0
&if "{2}" = "doc-list" &then
                                    , input '':U
&endif
                                        , input '>':U
                                        , input (if v-file
                                                then substitute("Файл макроса : &1", f-name)
                                                else substitute("Записанный макрос")
                                                )
                                        , input tot-lns
                                        , input 'macro':U
                                        , input '':U /*stts*/
                                        , input (if v-file then f-name else '':U)
                                        , input '':U
                                        , input ?
                                        ).
  end.
  disable
  b-record
  b-macro
  with frame {&frame-name} .
  hide
  b-record in frame {&frame-name} .
  enable
  b-clear-macro with frame {&frame-name} .
  v-macro-is-running = yes.
  run str/listmcro.w (input parparentproc
                ,input this-procedure:handle

&if "{2}" = "gds-list" &then
                ,input "Макрос формирования списка товаров" + {&delim-par} + "gdm"
&endif
&if "{2}" = "bb-list" &then
               ,input "Макрос формирования списка кодов" + {&delim-par} + "bbm"
&endif
&if  "{2}" = "dc-list"  &then
               ,input "Макрос формирования списка карт" + {&delim-par} + "dcm"
&endif
&if  "{2}" = "cli-list"  &then
               ,input "Макрос формирования списка клиентов" + {&delim-par} + "clm"
&endif
&if  "{2}" = "chk-list"  &then
               ,input "Макрос формирования списка чеков" + {&delim-par} + "chm"
&endif
&if  "{2}" = "doc-list"  &then
               ,input "Макрос формирования списка документов" + {&delim-par} + "trm"
&endif
                ,input "b-play,b-step"
                ,input-output v-current-step
                ,input v-id /*сколько всего*/
                ,output v-result) no-error .
  if error-status:error
  or v-result = "b-stop"
  or v-result = 'end':U
  then do:
    for each macro-list-hist:
      delete macro-list-hist.
    end.
    assign
    an-listp-start-macro-id = ?
    an-listp-end-macro-id = ?
    an-listp-macros-label-id = 0
    .
&if "{2}" = "gds-list"
or  "{2}" = "dc-list"
or  "{2}" = "cli-list"
&then
    menu-item m-macro-file:label in menu m-play = "Сохраненный в файле макрос формирования списка товаров".
    menu-item m-macro-lob:sensitive in menu m-play = yes.
&endif

    if v-result = 'b-stop' then do:
      assign
      v-hist-mode = '[]':U
      v-des = "Выполнение макроса прекращено пользователем"
      .
      hide
      b-clear-macro
      b-stop
      in frame {&frame-name} .
      enable
      b-record
      with frame {&frame-name} .
    end.
    if v-result = 'end' then do:
      assign
      v-hist-mode = '<':U
      v-des = "Выполнение макроса завершено"
      .
      hide
      b-clear-macro
      b-stop
      in frame {&frame-name} .
      enable
      b-record
      with frame {&frame-name} .
    end.
    if error-status:error then do:
      assign
      v-hist-mode = 'E':U
      v-des = "Выполнение макроса прекращено из-за ошибки"
      .
    end.
    run create-{1}-hist in this-procedure(input {&add-def}
                                        , input-output v-seq
                                        , input 0
&if "{2}" = "doc-list" &then
                                        , input '':U
&endif
                                        , input v-hist-mode
                                        , input v-des
                                        , input tot-lns
                                        , input 'macro':U
                                        , input '':U /*stts*/
                                        , input f-name
                                        , input '':U
                                        , input ?
                                        ) no-error .
    assign
    v-macro-is-running = no
    v-current-step = 0
    .
  end.
  enable
  b-macro
  with frame {&frame-name} .
end. /*doe*/
end procedure. /* proc-b-macro */


procedure proc-create-macro-list-hist :
define input parameter p-list-table as character no-undo .
define input parameter p-id as integer           no-undo .
define input parameter p-line as integer         no-undo .
define input parameter p-hist-mode as character  no-undo .
define input parameter p-des as character        no-undo .
define input parameter p-option_ as character    no-undo .
define input parameter p-item_ as character      no-undo .
define input parameter p-status_ as character    no-undo .

define buffer buf_macro-list-hist for macro-list-hist.
define buffer buf_keep-macro-list-hist for keep-macro-list-hist.

  do
  on error undo, return error return-value
  :
    create buf_macro-list-hist.
    assign
    buf_macro-list-hist.list-table = p-list-table
    buf_macro-list-hist.id         = p-id
    buf_macro-list-hist.line       = p-line
    buf_macro-list-hist.hist-mode  = p-hist-mode
    buf_macro-list-hist.des        = p-des
    buf_macro-list-hist.option_    = p-option_
    buf_macro-list-hist.item_      = p-item_
    buf_macro-list-hist.status_    = p-status_
    .
    if p-keep-query then do:
      create buf_keep-macro-list-hist.
      buffer-copy buf_macro-list-hist to buf_keep-macro-list-hist.
    end.
  end.

end procedure. /* proc-create-macro-list-hist */

procedure proc-macro-play :
define input parameter p-id as integer no-undo .
define input parameter p-step as logical no-undo .
define input parameter p-max-id as integer no-undo .
define variable v-id as integer no-undo .
define variable v-rowid   as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-old-seq as integer no-undo .
define variable v-current-id as integer no-undo .
define variable v-temp-seq as integer no-undo .
define variable v-rs-do-error as logical no-undo .
define  buffer buf_macro-list-hist for macro-list-hist.
define  buffer buf_{1}-hist for {1}-hist.
do
on error undo, return error return-value
:
  /*начинаем обработку*/
  for each macro-list-hist where (p-id = 0 or macro-list-hist.id = p-id):
    assign
    v-current-id = v-current-id + 1
    v-id = macro-list-hist.id.
    CASE entry(1, macro-list-hist.option_, {&delim-par}):
      when 'macro':U
      or
      when 'title':U
      or
      when 'start':U
      then do:
        /*пропускаем*/

      end.
      when 'clear':U then do:
        for each {1}:
          delete {1}.
        end.
        for each {1}-hist where {1}-hist.id > an-listp-macros-label-id:
          delete {1}-hist.
        end.
        tot-lns = 0.
        v-seq = an-listp-macros-label-id + 1.
        v-no-hist = 0.
        create buf_{1}-hist.
        buffer-copy macro-list-hist
        to buf_{1}-hist
        assign buf_{1}-hist.id = v-seq
        v-temp-seq = v-seq
        v-seq = v-seq + 1
        v-no-hist = v-no-hist + 1
        .
        run {&ui-on} in this-procedure .
      end.
      when 'single' then do:
         run gen-row-keyr  in this-procedure (  input  macro-list-hist.item_
                                              ,input ?
                                              ,input 'ub'
                                              ,input ?
                                              ,input no-lock
                                              ,output v-rowid
                                              ,output v-tbl-name) no-error .

        if not error-status:error then do:
          CASE macro-list-hist.hist-mode:
            when '+':U then do:
              run proc-b-add in this-procedure(input yes
                                              ,input v-rowid
                                              ,input macro-list-hist.option_
&if "{2}" = "doc-list" &then
                                              ,input macro-list-hist.list-table
&endif
                                              ,input macro-list-hist.status_) no-error .
            end.
            when '-':U then do:
              run proc-b-del in this-procedure(input yes
                                              ,input v-rowid
                                              ,input macro-list-hist.option_
&if "{2}" = "doc-list" &then
                                              ,input macro-list-hist.list-table
&endif
                                              ,input macro-list-hist.status_) no-error .
            end.
            when '*':U then do:
              run proc-b-rest in this-procedure(input yes
                                               ,input v-rowid
                                               ,input macro-list-hist.option_
&if "{2}" = "doc-list" &then
                                               ,input macro-list-hist.list-table
&endif
                                               ,input macro-list-hist.status_) no-error .
            end.
          END.
          if error-status:error then do:
              return ("error" + {&delim-par} + return-value) .
          end.
          find first  buf_{1}-hist where
                  buf_{1}-hist.id = v-seq - 1 no-error .
          if available buf_{1}-hist then
          assign
          macro-list-hist.num-recs = buf_{1}-hist.num-recs
          macro-list-hist.num-add = buf_{1}-hist.num-add
          macro-list-hist.num-ignored = buf_{1}-hist.num-ignored
          .

        end.
        else do:
          return ("error" + {&delim-par} + return-value).
        end.
      end.
      otherwise do:
        if can-find(first temp-list where temp-list.fvalue = macro-list-hist.option_)
        or lookup(macro-list-hist.option_, {&no-browser-option}) > 0
        then do:
          /*valid- ная опция*/
          if macro-list-hist.line = 0 then do:
            /*обработаем дерево*/
            v-no-hist = 0.
            for each buf_macro-list-hist where
                    buf_macro-list-hist.id = v-id:
              create buf_{1}-hist.
              buffer-copy buf_macro-list-hist
              except id  num-recs num-add num-ignored done
              to buf_{1}-hist
              assign
              buf_{1}-hist.id = (if buf_macro-list-hist.line =0 then v-seq else v-temp-seq)
              v-temp-seq = (if buf_macro-list-hist.line = 0 then v-seq else v-temp-seq )
              v-seq = (if buf_macro-list-hist.line = 0
                      then (v-seq + 1)
                      else v-seq)
              v-no-hist = v-no-hist + 1
              .
            end. /* for each buf_macro-list-hist  */
            if v-no-hist = 1 then v-no-hist = 0.
            run rs-do in this-procedure (input yes
                                      , input p-step
                                      , input macro-list-hist.option_
&if "{2}" = "doc-list" &then
                                      , input macro-list-hist.list-table
&endif
                                      , input macro-list-hist.status_
                                      , input get-line-mode(macro-list-hist.hist-mode)
                                      , input v-temp-seq
                                      ) no-error .
            if error-status:error then do:
              assign
              v-rs-do-error = yes.
            end.
            if get-line-mode(macro-list-hist.hist-mode) = {&leave} then do:
              run proc-b-rest-2 in this-procedure .
              run {&ui-on} in this-procedure .
            end.
            for each buf_{1}-hist where
                    buf_{1}-hist.id = v-temp-seq,
               first buf_macro-list-hist where
                    buf_macro-list-hist.id = v-id
                AND buf_macro-list-hist.line = buf_{1}-hist.line:
               assign
               buf_macro-list-hist.num-recs = buf_{1}-hist.num-recs
               buf_macro-list-hist.num-add = buf_{1}-hist.num-add
               buf_macro-list-hist.num-ignored = buf_{1}-hist.num-ignored
               .
            end.
            if v-rs-do-error then do:
              run {&UI-on} in this-procedure .
              return ("error" + {&delim-par} + return-value).
            end.
            v-id = macro-list-hist.id.
          end. /*главная запись*/
        end. /*if can-find(first temp-list where temp-list.fvalue = macro-list-hist.option) then do:*/
      end. /*otherwise*/
    END CASE.
  end. /*for each macri-{1}-hist*/
end. /*doe*/
end procedure. /* proc-macro-play */
&endif

procedure proc-b-rest-2 :
/*удаление помеченных к удалению в mode {&leave}*/
  do
  on error undo, return error
  :
    for each {1}:
      if {1}.to-del = ? then do:
        assign
        {1}.to-del = no
        .
      end.
      else do:
        delete {1}.
      end.
    end.
    tot-lns = lns-cnt.
  end.

end procedure. /* proc-b-rest-2 */

PROCEDURE proc-expand :
define input parameter p-shift as integer no-undo .
define input parameter p-from as integer no-undo .
define input parameter p-to as integer no-undo .
define input parameter p-forcer-name as character no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable lh as widget-handle no-undo .
define variable ii as INTEGER no-undo .
ASSIGN
fh = frame {&frame-name}:first-child
hh = fh:first-child
.
CASE v-expand:
  WHEN YES THEN DO:
    ASSIGN
    v-expand = NO.
    DO ii = 1 TO NUM-ENTRIES(v-downed):
      ASSIGN
      hh              = WIDGET-HANDLE(ENTRY(ii, v-downed))
      hh:ROW          = (hh:ROW - p-shift).
      hh:height-chars = (if hh:type = "browse" then (hh:height-chars + p-shift) else hh:height-chars).
    END.
  END. /*  WHEN YES THEN DO:*/
  WHEN NO THEN DO:
    v-expand = YES.
    v-downed = ''.
    _do:
    do while valid-handle(hh):
      IF lookup(hh:type, "radio-set,browse,button,fill-in,literal,text,rectangle") > 0
       AND hh:ROW >= p-from
       AND hh:ROW <= p-to
       and lookup(hh:name, p-forcer-name) = 0
       THEN DO:
        hh:height-chars = (if hh:type = "browse" then (hh:height-chars - p-shift) else hh:height-chars).
        hh:ROW          = (hh:ROW + p-shift).
        ASSIGN
        v-downed = v-downed + {&comma-char} + STRING(hh).
        IF hh:TYPE = "fill-in"
        AND valid-handle(hh:side-label-handle) THEN dO:
          assign
          lh = hh:SIDE-LABEL-HANDLE
          lh:ROW = lh:ROW + p-shift
          v-downed = v-downed + {&comma-char} + STRING(lh)
          .
         END. /*IF hh:TYPE = "fill-in"*/
       END. /*IF lookup(hh:type, "button,fill-in,literal,text,rectangle") > 0*/
       hh = hh:next-sibling.
    END. /*    do while valid-handle(hh):*/
    v-downed = trim(v-downed, {&comma-char}).
  END. /*when no*/
END CASE.
END PROCEDURE.

&if "{2}" = "gds-list" &then

ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable glog as logical no-undo .
define buffer buf_{1} for {1}.
if available {1} then   do:
  find first buf_{1} where
           recid(buf_{1}) = recid({1}).
  assign
  buf_{1}.to-sel = not (buf_{1}.to-sel).
  glog = br-list:refresh().
  if LOOKUP(last-event:function,  "MOUSE-SELECT-DBLCLICK,RETURN":U) = 0  then  do:
      {&select-next-row}
     glog = br-list:select-next-row ().
     APPLY "VALUE-CHANGED" to br-list.
  end.
end.
APPLY "ENTRY" to br-list in frame {&frame-name} .
END.

ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
define buffer buf_{1} for {1}.
if not available {1} then return no-apply.

find first buf_{1} where
          recid(buf_{1}) = recid({1}).
assign
buf_{1}.to-sel = not (buf_{1}.to-sel)
.
APPLY "CHOOSE" to b-exit.
END.
&endif



/* $Workfile$ e n d */