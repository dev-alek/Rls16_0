/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Работа с gate-xsd лежащими в CLOB

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/13/08
Author: Bakhtadze Natalya
Creation date: 01/13/08

*/

/*

НЕ ЗАБЫТЬ УДАЛИТЬ ДИНАМИЧЕСКИЕ ОБЪЕКТЫ p-dsh и временные таблицы!!!
*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ rul/tempcxml.i }
{ gbl/key-rec.i }

procedure get-gate-file-name :
define input parameter p-gate-rec as character no-undo .
define output  parameter p-gate-file-name as character no-undo .
define buffer buf_clob-data for ub.clob-data.
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
run gen-row-keyr in this-procedure ( input p-gate-rec
                                    ,input ?
                                    ,input "ub"
                                    ,input ?
                                    ,input no-lock
                                    ,output v-tbl-row
                                    ,output v-tbl-name) no-error.
if error-status:error then undo, return error substitute("&1 (get-gate-name) Несуществующий gate &2"
                                                        ,vss-include-info{&vssseq}
                                                        ,p-gate-rec).

find first buf_clob-data no-lock where
          rowid(buf_clob-data) = v-tbl-row no-error.
if not available buf_clob-data then do:
  if error-status:error then undo, return error substitute("&1 (get-gate-name) Несуществующий gate &2"
                                                          ,vss-include-info{&vssseq}
                                                          ,p-gate-rec).
end.
p-gate-file-name = buf_clob-data.file-name.
end procedure.



procedure get-gate-rec :
define input  parameter p-gate-name as character no-undo .
define output parameter p-gate-rec as character no-undo .
define buffer buf_clob-bind for ub.clob-bind.
define buffer buf_clob-data for ub.clob-data.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:


    find first buf_clob-bind no-lock where
              buf_clob-bind.uniq-key-rec = p-gate-name
          and buf_clob-bind.field-name = '':U
          and buf_clob-bind.part-num = 1
          and buf_clob-bind.resource-type = {&lob-res-gate}
          no-error.
    if not available buf_clob-bind then do:
      undo, return error substitute("Неверная ссылка на XSD -файл &1 для gate"
                                      , p-gate-name
                                      ).

    end.
    find first buf_clob-data no-lock where
              buf_clob-data.db-num = buf_clob-bind.db-num
          and buf_clob-data.int64-i= buf_clob-bind.int64-id no-error.
    if not available buf_clob-data then do:
      undo, return error substitute("Не найден CLOB c ДБ &1 id &2 - файл &3"
                                      , buf_clob-bind.db-num
                                      , buf_clob-bind.int64-id
                                      , p-gate-name
                                      ).

    end.
    run gen-key-rec in this-procedure ( input {&table_clob-data}
                              ,input buffer buf_clob-data:handle
                              ,output p-gate-rec).


end.
end procedure.

procedure get-gate-by-name :
define input  parameter p-gate-name as character no-undo .
define output parameter p-gate-rec as character no-undo .
define output parameter p-dsh as handle no-undo .
define input-output  parameter p-xmlh as handle no-undo .

define variable v-ii as integer   no-undo .
define variable glog as logical   no-undo .
define variable v-longchar as longchar no-undo .
define variable v-txmlh as handle no-undo .
define variable v-db-num as integer no-undo .
define variable v-int64-id as int64 no-undo .

define buffer buf_clob-bind for ub.clob-bind.
define buffer buf_clob-data for ub.clob-data.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:

&if "{1}" = "lib-gate" &then
  define buffer buf_temp-gate for temp-gate.
  define variable v-field-list as character no-undo .
  define variable v-value-list as character no-undo .
  find first buf_temp-gate where
            buf_temp-gate.schema-name = p-gate-name no-error.
  if available buf_temp-gate then do:
    /*надо проверить что схема не устарела*/
    run gen-key-fv in this-procedure ( input buf_temp-gate.uniq-gate-rec
                                     ,output v-field-list
                                     ,output v-value-list).
    assign
    v-db-num = integer(entry(lookup("db-num":U
                                      , v-field-list
                                      , {&delim-key})
                                , v-value-list, {&delim-key}))
    v-int64-id = int64(entry(lookup("int64-id":U
                                      , v-field-list
                                      , {&delim-key})
                                , v-value-list, {&delim-key}))
    no-error .
    find first buf_clob-bind no-lock where
              buf_clob-bind.uniq-key-rec = p-gate-name
          and buf_clob-bind.field-name = '':U
          and buf_clob-bind.part-num = 1
          and buf_clob-bind.resource-type = {&lob-res-gate}
          and buf_clob-bind.db-num = v-db-num
          and buf_clob-bind.int64-id = v-int64-id
          no-error.
   if available buf_clob-bind then do:
      p-gate-rec = buf_temp-gate.uniq-gate-rec.
      p-dsh = buf_temp-gate.gate-handle_.
      p-xmlh = (if not valid-handle(p-xmlh)
                then buffer temp-xml-tables:handle
                else p-xmlh).
      return.
    end.
  end.
&endif


    find first buf_clob-bind no-lock where
              buf_clob-bind.uniq-key-rec = p-gate-name
          and buf_clob-bind.field-name = '':U
          and buf_clob-bind.part-num = 1
          and buf_clob-bind.resource-type = {&lob-res-gate}
          no-error.
    if not available buf_clob-bind then do:
      undo, return error substitute("Неверная ссылка на XSD -файл &1 для gate"
                                      , p-gate-name
                                      ).

    end.
    find first buf_clob-data no-lock where
              buf_clob-data.db-num = buf_clob-bind.db-num
          and buf_clob-data.int64-i= buf_clob-bind.int64-id no-error.
    if not available buf_clob-data then do:
      undo, return error substitute("Не найден CLOB c ДБ &1 id &2 - файл &3"
                                      , buf_clob-bind.db-num
                                      , buf_clob-bind.int64-id
                                      , p-gate-name
                                      ).

    end.
    assign
    v-longchar = buf_clob-data.cdata
    .
    run fix-schemalocation in this-procedure ( input-output v-longchar) no-error.
    if error-status :error then do:
      undo, return error substitute("Не удалось определить расположение составных частей схемы &1 (&2) из БД&3&4&3&5", p-gate-rec, buf_clob-data.file-name_, {&new-line}, error-status:get-message(1) , return-value ).
    end.

    create dataset p-dsh .
    glog = p-dsh:READ-XMLSCHEMA( "LONGCHAR" /*cSourceType*/
                                  , v-longchar
                                  , ? /*lOverrideDefaultMapping*/
                                  , ? /*cFieldTypeMapping*/
                                  , ? /*cVerifySchemaMode*/
                                  ) no-error.
    v-longchar = '':U.
    if error-status :error
    or not glog
    then do:
      undo, return error substitute("Не удалось прочитать XML-схему &1 из БД:&2&3", p-gate-name, {&new-line}, error-status:get-message(1) ).
    end.
    if not valid-handle(p-xmlh)
    or not valid-handle(p-xmlh:buffer-field("tbl-name")) then do:
      create temp-table v-txmlh.
      v-txmlh:create-like(buffer temp-xml-tables:handle).
      v-txmlh:temp-table-prepare("temp-xml-tables").
      p-xmlh = v-txmlh:default-buffer-handle.
    end.
    run gen-key-rec in this-procedure ( input {&table_clob-data}
                              ,input buffer buf_clob-data:handle
                              ,output p-gate-rec).

    do v-ii = 1 to p-dsh:num-buffers:
      p-xmlh:find-first(substitute(' where tbl-name = "&1"', p-dsh:get-buffer-handle(v-ii):name)) no-error.
      if not p-xmlh:available then do:
        p-xmlh:buffer-create().
        assign
        p-xmlh::tbl-name = p-dsh:get-buffer-handle(v-ii):name
        p-xmlh::tbl-handle_ = p-dsh:get-buffer-handle(v-ii)
        p-xmlh::table-handle_ = p-dsh:get-buffer-handle(v-ii):table-handle
        p-xmlh::gate-handle_ = p-dsh
        p-xmlh::uniq-gate-rec = p-gate-rec
        p-xmlh::gate-name = p-dsh:name
        p-xmlh::is-parent = not valid-handle(p-dsh:get-buffer-handle(v-ii):parent-relation)
        .
        if lookup(p-xmlh::tbl-name, "thheader,header_") > 0 then do:
          assign
          p-xmlh::order = -3.
        end.
      end.
    end.
    &if "{1}" = "lib-gate" &then
      create buf_temp-gate.
      assign
      buf_temp-gate.gate-handle_ = p-dsh
      buf_temp-gate.uniq-gate-rec = p-gate-rec
      buf_temp-gate.schema-name = p-gate-name
      .
    &endif
end.

end procedure. /* get-gate-by-name */

procedure get-gate-by-rec :
define input  parameter p-gate-rec as character no-undo .
define output parameter p-dsh as handle no-undo .
define input-output  parameter p-xmlh as handle no-undo .
define input-output parameter p-longchar  as longchar no-undo .

define variable v-ii as integer   no-undo .
define variable glog as logical   no-undo .
define variable v-rowid as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-longchar as longchar no-undo .
define variable v-txmlh as handle no-undo .

define buffer buf_clob-data for ub.clob-data.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:

&if "{1}" = "lib-gate" &then
  define buffer buf_temp-gate for temp-gate.
  find first buf_temp-gate where
            buf_temp-gate.uniq-gate-rec = p-gate-rec no-error.
  if available buf_temp-gate then do:
      p-gate-rec = buf_temp-gate.uniq-gate-rec.
      p-dsh = buf_temp-gate.gate-handle_.
      p-xmlh = (if not valid-handle(p-xmlh)
                then buffer temp-xml-tables:handle
                else p-xmlh).
      return.
  end.
&endif


  run gen-row-keyr in this-procedure (
                                        input  p-gate-rec
                                        ,input  ?
                                        ,input  "ub"
                                        ,input  ?
                                        ,input  NO-LOCK
                                        ,output v-rowid
                                        ,output v-tbl-name   ) no-error.
    find first buf_clob-data no-lock where
              rowid(buf_clob-data) = v-rowid  no-error.
    if not available buf_clob-data then do:
      undo, return error substitute("Не найден CLOB  &1"
                                      , p-gate-rec
                                      ).

    end.
    assign
    v-longchar = buf_clob-data.cdata
    .
    run fix-schemalocation in this-procedure ( input-output v-longchar) no-error.
    if error-status :error then do:
      undo, return error substitute("Не удалось определить расположение составных частей схемы &1 (&2) из БД&3&4&3&5", p-gate-rec, buf_clob-data.file-name_, {&new-line}, error-status:get-message(1) , return-value ).
    end.

    create dataset p-dsh .
    glog = p-dsh:READ-XMLSCHEMA( "LONGCHAR" /*cSourceType*/
                                  , v-longchar
                                  , ? /*lOverrideDefaultMapping*/
                                  , ? /*cFieldTypeMapping*/
                                  , ? /*cVerifySchemaMode*/
                                  ) no-error.
    define variable v-esm as character no-undo .
    v-esm = error-status:get-message(1) .
    if p-longchar <> ? then do:
      p-longchar = v-longchar.
    end.
    v-longchar = '':U.
    if error-status :error
    or not glog
    then do:
      undo, return error substitute("Не удалось прочитать XML-схему &1 (&2) из БД&3&4"
                                   , p-gate-rec
                                   , p-gate-rec
                                   , v-esm
                                   ).
    end.
    p-dsh:private-data = buf_clob-data.file-name_ + {&delim-par} + p-gate-rec.
    if not valid-handle(p-xmlh)
    or not valid-handle(p-xmlh:buffer-field("tbl-name")) then do:
      create temp-table v-txmlh.
      v-txmlh:create-like(buffer temp-xml-tables:handle).
      v-txmlh:temp-table-prepare("temp-xml-tables").
      p-xmlh = v-txmlh:default-buffer-handle.
    end.
    do v-ii = 1 to p-dsh:num-buffers:
      p-xmlh:find-first(substitute(' where tbl-name = "&1"', p-dsh:get-buffer-handle(v-ii):name)) no-error.
      if not p-xmlh:available then do:
        p-xmlh:buffer-create().
        assign
        p-xmlh::tbl-name = p-dsh:get-buffer-handle(v-ii):name
        p-xmlh::tbl-handle_ = p-dsh:get-buffer-handle(v-ii)
        p-xmlh::table-handle_ = p-dsh:get-buffer-handle(v-ii):table-handle
        p-xmlh::gate-handle_ = p-dsh
        p-xmlh::uniq-gate-rec = p-gate-rec
        p-xmlh::gate-name = p-dsh:name
        p-xmlh::is-parent = not valid-handle(p-dsh:get-buffer-handle(v-ii):parent-relation)
        .
        if lookup(p-xmlh::tbl-name, "thheader,header_") > 0 then do:
          assign
          p-xmlh::order = -3.
        end.

        p-xmlh:buffer-release().
      end.
    end.
    /*
    &if "{1}" = "lib-gate" &then
      create buf_temp-gate.
      assign
      buf_temp-gate.gate-handle_ = p-dsh
      buf_temp-gate.uniq-gate-rec = p-gate-rec
      buf_temp-gate.gate-name = p-dsh:name
      buf_temp-gate.schema-name = p-dsh:name
      .
    &endif
    */
end.

end procedure. /* get-gate-by-rec */

procedure get-gate-by-file :
define input  parameter p-schema-file-name as character no-undo .
define input  parameter p-gate-rec as character no-undo .
define output parameter p-dsh as handle no-undo .
define input-output  parameter p-xmlh as handle no-undo .

define variable v-ii as integer   no-undo .
define variable glog as logical   no-undo .
define variable v-rowid as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-longchar as longchar no-undo .
define variable v-txmlh as handle no-undo .


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:
    COPY-LOB
    FROM  FILE p-schema-file-name
    TO  OBJECT v-longchar
    no-convert
    NO-ERROR .
    if error-status :error then do:
        undo, return error substitute("Не удалось считать файл схемы &1 в память&2&3"
                                  , p-schema-file-name
                              , {&new-line}
                              , error-status:get-message(1) ).
    end.

    run fix-schemalocation in this-procedure ( input-output v-longchar) no-error.
    if error-status :error then do:
      undo, return error substitute("Не удалось определить расположение составных частей схемы &1 (&2) из БД&3&4&3&5", p-gate-rec, p-schema-file-name, {&new-line}, error-status:get-message(1) , return-value ).
    end.


    create dataset p-dsh .
    glog = p-dsh:READ-XMLSCHEMA( "longchar" /*cSourceType*/
                                  , v-longchar
                                  , ? /*lOverrideDefaultMapping*/
                                  , ? /*cFieldTypeMapping*/
                                  , ? /*cVerifySchemaMode*/
                                  ) no-error.
    v-longchar = ''.
    if error-status :error
    or not glog
    then do:

      undo, return error substitute("Не удалось прочитать XML-схему из файла &1&2&3"
                                   , p-schema-file-name
                                   ,{&new-line}
                                   , error-status:get-message(1)
                                   ).
    end.
    if not valid-handle(p-xmlh)
    or not valid-handle(p-xmlh:buffer-field("tbl-name")) then do:
      create temp-table v-txmlh.
      v-txmlh:create-like(buffer temp-xml-tables:handle).
      v-txmlh:temp-table-prepare("temp-xml-tables").
      p-xmlh = v-txmlh:default-buffer-handle.
    end.
    do v-ii = 1 to p-dsh:num-buffers:
      p-xmlh:find-first(substitute(' where tbl-name = "&1" and  uniq-gate-rec = "&2" '
                                   ,p-dsh:get-buffer-handle(v-ii):name
                                   ,p-gate-rec
                                   )) no-error.
      if not p-xmlh:available then do:
        p-xmlh:buffer-create().
        assign
        p-xmlh::tbl-name = p-dsh:get-buffer-handle(v-ii):table
        p-xmlh::uniq-gate-rec = p-gate-rec
        p-xmlh::tbl-handle_ = p-dsh:get-buffer-handle(v-ii)
        p-xmlh::table-handle_ = p-dsh:get-buffer-handle(v-ii):table-handle
        p-xmlh::gate-handle_ = p-dsh
        p-xmlh::gate-name = p-dsh:name
        p-xmlh::is-parent = not valid-handle(p-dsh:get-buffer-handle(v-ii):parent-relation)
        .
        if lookup(p-xmlh::tbl-name, "thheader,header_") > 0 then do:
          assign
          p-xmlh::order = -3.
        end.
        p-xmlh:buffer-release().
      end.
    end.
end.

end procedure. /* get-gate-by-file */


procedure gate-clear :
define input  parameter p-dsh as handle no-undo .
define input  parameter p-xmlh as handle no-undo .

define variable v-dsh as handle no-undo .
define variable v-th as handle no-undo .

  do
  on error undo, return error return-value
  :
    if valid-handle(p-dsh) then do:
      delete object p-dsh.
      v-dsh = p-dsh.
      p-dsh = ?.
    end.
    repeat while true:
      p-xmlh:find-first( substitute( " where gate-handle_ = &1 ", v-dsh)
                         , share-lock) no-error.
      if p-xmlh:available then do:
        assign
        v-th = p-xmlh:buffer-field("table-handle_"):buffer-value.
        if valid-handle(p-xmlh:buffer-field("table-handle_"))
        and valid-handle(v-th)
        and v-th:dynamic = yes
        then do:
          delete object p-xmlh:buffer-field("table-handle_"):buffer-value.
          p-xmlh:buffer-field("table-handle_"):buffer-value = ?.
        end.
        p-xmlh:buffer-delete().
      end.
      else do:
        leave.
      end.
    end.
    if p-xmlh:dynamic = yes
    and valid-handle(p-xmlh)
    then do:
      delete object p-xmlh:table-handle.
      p-xmlh = ?.
    end.
    v-dsh = ?.
  end.

end procedure. /* gate-clear */

procedure all-gates-clear :
define parameter buffer buf_temp-xml-tables for temp-xml-tables.

do
on error undo, return error
:
  for each buf_temp-xml-tables
  break
  by buf_temp-xml-tables.uniq-gate-rec
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
  :
      if first-of(buf_temp-xml-tables.uniq-gate-rec) then do:
        delete object buf_temp-xml-tables.gate-handle_.
        buf_temp-xml-tables.gate-handle_ = ?.
      end.
      if valid-handle(buf_temp-xml-tables.table-handle_)
      and buf_temp-xml-tables.table-handle_:dynamic = no
      then do:
        delete object buf_temp-xml-tables.table-handle_.
        buf_temp-xml-tables.table-handle_ = ?.
      end.
      delete buf_temp-xml-tables.
  end.
end.
end procedure. /* all-gates-clear */


procedure fix-schemalocation :
define input-output  parameter p-longchar as longchar no-undo .
DEFINE VARIABLE hdoc AS HANDLE.
DEFINE VARIABLE hroot AS HANDLE.
DEFINE VARIABLE hnode-child AS HANDLE.
DEFINE VARIABLE hnode-attr AS HANDLE.
define variable v-jj as integer   no-undo .
define variable ok as logical   no-undo .
define variable v-path1                    as character                no-undo .
DEFINE VARIABLE v-full-path1               as character                no-undo .
DEFINE VARIABLE v-file-name1               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext1        as character                no-undo .
DEFINE VARIABLE v-file-name-ext1           as character                no-undo .
define variable v-schema-location          as character                no-undo .


do
on error undo, return error return-value
:


  CREATE X-DOCUMENT hdoc.
  CREATE X-noderef hroot.
  CREATE X-noderef hnode-child.
  CREATE X-noderef hnode-attr.

  hdoc:load("longchar", p-longchar, no) no-error.
  iF ERROR-STATUS:GET-MESSAGE(1) <> '' THEN message ERROR-STATUS:GET-MESSAGE(1) view-as alert-box .
  hdoc:get-document-element(hroot).
  _repeat:
  REPEAT v-jj = 1 TO hroot:NUM-CHILDREN:
    ok = hroot:GET-CHILD(hNode-Child, v-jj).
    if not ok then next.
    if hNode-Child:local-name = "include"
    then do:
      ok = hNode-Child:GET-ATTRIBUTE-NODE( hnode-attr, "schemaLocation" ).
        v-schema-location = hnode-attr:node-value.

        run gbl/filename.p (
                        input "exe/" + hnode-attr:node-value
                      ,output v-full-path1
                      ,output v-path1
                      ,output v-file-name1
                      ,output v-file-name-no-ext1
                      ,output v-file-name-ext1
                      ) no-error .
        if error-status :error then do:
          delete object hnode-attr.
          delete object hnode-child.
          delete object hroot.
          delete object hdoc.
          undo, return error substitute("Не удалось определить расположение схемы &1", v-schema-location).
        end.
      ok = hNode-Child:sET-ATTRIBUTE(  "schemaLocation", v-full-path1 ).
      leave  _repeat.
    end.
  END.

  hdoc:save("longchar", p-longchar).

  delete object hnode-attr.
  delete object hnode-child.
  delete object hroot.
  delete object hdoc.

end.

end procedure. /* fix-schemalocation */

procedure gate-clb_fill-xml-tables :
define input parameter p-dsh as handle no-undo .
define input-output parameter p-xmlh as handle no-undo .
define variable v-ii as integer no-undo .

  do
  on error undo, return error
  :
    do v-ii = 1 to p-dsh:num-buffers:
      p-xmlh:find-first(substitute(' where tbl-name = "&1"', p-dsh:get-buffer-handle(v-ii):name)) no-error.
      if not p-xmlh:available then do:
        p-xmlh:buffer-create().
        assign
        p-xmlh::tbl-name = p-dsh:get-buffer-handle(v-ii):name
        p-xmlh::tbl-handle_ = p-dsh:get-buffer-handle(v-ii)
        p-xmlh::table-handle_ = p-dsh:get-buffer-handle(v-ii):table-handle
        p-xmlh::gate-handle_ = p-dsh
        p-xmlh::uniq-gate-rec = entry(2, p-dsh:private-data, {&delim-par})
        p-xmlh::gate-name = p-dsh:name
        p-xmlh::is-parent = not valid-handle(p-dsh:get-buffer-handle(v-ii):parent-relation)
        .
        if lookup(p-xmlh::tbl-name, "thheader,header_") > 0 then do:
          assign
          p-xmlh::order = -3.
        end.

        p-xmlh:buffer-release().
      end.
    end.
  end.

end procedure. /* gate-clb_fill-xml-tables */

procedure all-gates-empty :
define buffer buf_temp-xml-tables for temp-xml-tables.

do
on error undo, return error
:
  for each buf_temp-xml-tables
  break
  by buf_temp-xml-tables.uniq-gate-rec
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
  :
    if valid-handle(buf_temp-xml-tables.tbl-handle_) then do:
      buf_temp-xml-tables.tbl-handle_:empty-temp-table().
    end.
  end.
end.
end procedure. /* all-gates-clear */


/* $Workfile$ e n d */