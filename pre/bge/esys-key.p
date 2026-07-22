block-level on error undo, throw.
define input parameter p-db-num as integer no-undo .
define input parameter p-silence as logical no-undo .
define output parameter p-ok as logical no-undo .
define output parameter p-err-mess as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: esys-key.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/esys-key.p $":U .
define variable vss-description as character no-undo init "Проверка корректности типов имеющихся ВС значениям выданных ключей".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable v-esys-by-type-found as integer extent 12 no-undo .
define variable v-esys-by-type-key  as integer extent 12.
define variable v-esys-by-type-key-chr  as character extent 12.
define variable v-esys-type-num as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-code as character no-undo .
define variable v-type as character no-undo .
define buffer buf_ext-system  for ub.ext-system.
main-block:
for each buf_ext-system no-lock where
       ((buf_ext-system.esys-have-export = yes
         and
         buf_ext-system.esys-db-num-exp = p-db-num)
         or
         (buf_ext-system.esys-have-import = yes
         and
         buf_ext-system.esys-db-num-imp = p-db-num)
        )
      and buf_ext-system.esys-type > integer('1':U)
by buf_ext-system.esys-type
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  v-esys-type-num = buf_ext-system.esys-type.
  assign
  v-esys-by-type-found[v-esys-type-num] = v-esys-by-type-found[v-esys-type-num]  + 1
  .
end.
do v-ii = 2 to 12:
  v-code = substitute("esys-&1", string(v-ii, "999")).
  if v-esys-by-type-found[v-ii]  > 0
  and lookup(string(v-ii), '7,9':U) > 0
  then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run confrddb in g#library
  (input  v-code
  ,input  p-db-num
  ,input  0
  ,input  ''
  ,input  0
  ,input  p-silence
  ,output v-esys-by-type-key-chr[v-ii]
  ,output v-type
  ) no-error .
    assign
    v-esys-by-type-key[v-ii] = integer(v-esys-by-type-key-chr[v-ii])
    no-error
    .
    if v-esys-by-type-key[v-ii] < v-esys-by-type-found[v-ii] then do:
            p-err-mess = substitute("&1Количество разрешенных согласно параметру <esys-&7>  ВС с типом &2 (&3) =  &4, а реально &5"
                              , chr(10)
                              , v-ii
                              , entry (lookup (string(v-ii), '0,1,2,3,4,5,6,7,8,9,10,11,12':U), 'НЕспециальная,Специальная,IBS TH,Oracle Retail,Lantab,EDOC-НН,Панель Руководителя,ДатаКрат DKLink,1C,EDI,Меркурий,ИС МОТП,ИС Диадок':U)
                              , v-esys-by-type-key[v-ii]
                              , v-esys-by-type-found[v-ii]
                              , string(v-ii, "999")
                              ).
    end.
  end.
end.
if p-err-mess = '' then do:
  p-ok = yes.
end.
