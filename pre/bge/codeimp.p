using ibs.th.bge.xmlimpexp.
define variable vss-revision    as character no-undo init "нету ее":U .
define variable vss-author      as character no-undo init "Рубан Дмитрий Андреевич":U .
define variable vss-date        as character no-undo init "16 марта 2025 г":U .
define variable vss-workfile    as character no-undo init "bge/codeimp.p":U .
define variable vss-archive     as character no-undo init "codeimp.p":U .
define variable vss-description as character no-undo init "Импорт файлов".
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
function objExists return character
(input  ifolder as character,
 input  iType   as character  ):
    define variable vFileType as character no-undo init "D,F".
    define variable vi        as integer no-undo.
    define variable vtype as character no-undo.
    if iType ne ?
    then
       vFileType = iType.
    do vi = 1 to num-entries(vFileType):
       file-information:file-name = ".\" + right-trim(replace(ifolder,"/","\"),"\").
       vtype = file-information:file-type.
       if entry(num-entries(file-information:file-name, "\"), file-information:file-name, "\")
          = entry(num-entries(file-information:full-pathname, "\"), file-information:full-pathname ,"\") and
          index(vtype , entry(vi,vFileType )) > 0
       then return file-information:full-pathname .
       file-information:file-name = right-trim(replace(ifolder,"/","\"),"\").
       vtype = file-information:file-type.
       if file-information:file-name <> "" and
          entry(num-entries(file-information:file-name, "\"), file-information:file-name, "\")
          = entry(num-entries(file-information:full-pathname, "\"), file-information:full-pathname ,"\") and
          index( vtype, entry(vi,vFileType )) > 0
       then return file-information:full-pathname .
    end.
    return ? .
end.
function SearchFile return character
(input  ifile as character):
   return objExists(ifile,?).
end.
function SearchPFile return character
(input inFile as char):
     define variable oFile       as character no-undo.
     define variable vFileSearch as character no-undo.
     define variable vNumEntry   as integer no-undo.
     if inFile = "" then return ?.
     vNumEntry = num-entries(inFile,".").
     vFileSearch = inFile.
     if    vNumEntry > 0
        and (   entry(vNumEntry,inFile,".") eq "p"
             or entry(vNumEntry,inFile,".") eq "w")
     then do:
        entry(vNumEntry,vFileSearch, ".") = "r".
        oFile = search(vFileSearch ).
        if oFile eq ?
        then
           oFile = search(inFile).
     end.
     else
        oFile = search(vFileSearch).
     return oFile.
  end.
define variable varlog          as logical         no-undo.
define variable mFileName       as character       no-undo.
define variable mfile           as character       no-undo.
define variable mfilemd5        as character       no-undo.
define variable mtxt            as character       no-undo.
define variable v-md5-signature as character       no-undo.
define variable vimport         as class xmlimpexp no-undo.
define stream md5in.
define variable vErrMes as character no-undo.
system-dialog get-file mFileName title "Выберите файл для загрузки"
    filters "Файлы (*.xml)" "*.xml,",
            "Все файлы" "*.*"
    initial-filter 1
    must-exist
    update varlog.
if not varlog then return error "Отказ от импорта" .
mfile    = search(mFileName).
entry(num-entries(mFileName,"."),mFileName,".")= "md5".
mfilemd5 = search(mFileName).
if    mfile    eq ?
   or mfilemd5 eq ?
then
   return error "файл не найден".
input  stream md5in from value (mfilemd5).
import stream md5in mtxt no-error.
input  stream md5in close.
run gbl/md5.p (
       input  mfile
      ,output v-md5-signature
      ) .
if mtxt eq encode(v-md5-signature + "sysadm" ) + string(index(encode(string(v-md5-signature)), "k"))
then do:
   vimport = new xmlimpexp().
   vimport:xmldom-load-ver  ( mfile,? ) no-error.
   if error-status:error
   then
      return error return-value.
   UPD_TBL:
   do transaction on error undo UPD_TBL, leave UPD_TBL:
       vimport:updatetablefordb(this-procedure) no-error.
       if error-status:error
       then return error return-value.
   end.
   return-value = "".
   vimport:xmldom-clear().
   message "Загрузка успешно завершена."
   view-as alert-box.
end.
else do:
   vErrMes = substitute("Файл &1 имеет не правильную сигнатуру md5.", mfile).
   return error vErrMes.
 end.
finally:
   if valid-object (vimport)
   then
      delete object vimport.
end.
