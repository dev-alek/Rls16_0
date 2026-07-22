block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ubd-gbd1.p $
$Archive: utl/ubd-gbd1.p $

Трансформация УБД в ГБД

Автор: Чернова Светлана Александровна
Дата создания: 08/27/08
Author: Svetlana Chernova
Creation date: 08/27/08

*/

define input parameter parparentproc    as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter p-parameter      as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ubd-gbd1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ubd-gbd1.p $":U .
define variable vss-description as character no-undo init "Трансформация УБД в ГБД".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/getmcode.i ub  }
{ gbl/cur-time.i }
{ cmp/library.i  }
{ gbl/filelist.i }
{ utl/mig_0040.i "new shared" }

define variable p-db-num        as integer   no-undo .
define variable p-cli-code      as integer   no-undo .
define variable log-file-name   as character  no-undo init "ubd-gbd.txt".
define variable trg-Name as character no-undo .
define variable str as character no-undo .
define variable v-path-ver as character no-undo .

file-info:file-name = "utl/mig_0001.p":U .
v-path-ver = trim (file-info:FULL-PATHNAME, "mig_0001.p" ).
define variable v-dir-name as character no-undo .
v-dir-name = substring(v-path-ver , 1 , length (v-path-ver) - 5 ).

run gbl/d-prompt.w (
    'title=':u + "Введите имя директории" + '\':u
  + 'text1=':u + "Введите имя директории с файлами 'MIG'" + '\':u
  + 'format=x(256)\':u
  + 'type=char\':u
  ,input-output v-dir-name
  ).
if return-value = 'false':u then do:
  return .
end.

assign
  file-info :file-name = v-dir-name
.
if file-info :full-pathname = ""
or file-info :full-pathname = ?  then do:
  message
    vss-workfile vss-revision vss-description skip
    substitute( "Каталог: &1 не найден !!!", v-dir-name ) skip
    return-value skip
    error-status :get-message ( error-status :num-messages )
    view-as alert-box error
  .
  undo, return error .
end.

assign
  v-dir-name = file-info :full-pathname
.

v-path-ver = v-dir-name .




define stream OutStream.

define temp-table temp-proc no-undo
field proc-name as character
index pi proc-name
.


   p-db-num   = int (entry(1,p-parameter,{&delim-par})) .
   p-cli-code = int (entry(2,p-parameter,{&delim-par})) .


MAIN-BLOCK:
do
on error   undo main-block, return error substitute('error main-block,&1', return-value )
on end-key undo main-block, return error substitute('end-key main-block,&1', return-value )
:

if transaction then do:
  message
    vss-workfile vss-revision vss-description skip
    "Недопустимо вызывать процедуру из транзакции!" skip
    view-as alert-box error .
end.

run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Трансформация УБД &1 в ГБД", p-db-num))
    .

find first ub.clients no-lock where
           ub.clients.obj-code = p-cli-code and
           ub.clients.obj-type = {&cmp} no-error .
    if error-status :error then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("err - &1", error-status :get-message(1) )).
        return .
    end.

/* Формирование списка запускаемых процедур */
run filelist-dirlist-subdir-init (input v-path-ver ) .

for each temp-proc :
   delete temp-proc.
end.

for each temp-dirlist :
    run filelist-clear .
    run filelist-init
      ( temp-dirlist.dir-full-name  ,
        true                        ,
        "p"                       ,
        temp-dirlist.dir-short-name )  .

    for each temp-filelist where temp-filelist.file-name-no-ext  begins "mig_" :
        create temp-proc.
        temp-proc.proc-name = temp-filelist.dir-short-name + "\" + temp-filelist.file-name .
    end.

end.


for each temp-proc :
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input temp-proc.proc-name ) .

    run value ( temp-proc.proc-name )
        ( parparentproc
        , p-parent-handle
        , p-log-handle
        , p-parameter
        , p-db-num
        , p-cli-code
        , log-file-name )
        no-error .
    if error-status :error then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("err - &1 &2" , error-status :get-message(1) , return-value  )).
        return .
    end.

end.



run write-log-and-file in p-log-handle (
    input 1
  , input log-file-name
  , input 1
  , input substitute("Восстановление Последовательностей")).

create alias restseq    for database value( ldbname( "ub":U ) ) .
create alias restseqflt for database value( ldbname( "ub":U ) ) .
run adm/restseq.p (input "rest-no-msg", input "":U, input no) no-error .
if error-status :error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute ( "err - &1 &2" , error-status :get-message(1) , return-value  )).
      delete alias restseqflt.
      delete alias restseq.
  return .
end.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input   return-value  ).

delete alias restseqflt.
delete alias restseq.



run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input "Трансформация закончена" ).
end.