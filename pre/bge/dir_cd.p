block-level on error undo, throw.
def input parameter DirList as char case-sensitive.
def input parameter OpList  as char.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dir_cd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/dir_cd.p $":U .
define variable vss-description as character no-undo init "Создание и удаление каталога (RECURSIVE)".
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
def var DirName         as char case-sensitive NO-UNDO.
def var ParentDir       as char case-sensitive NO-UNDO.
def var DirFound        as log                 NO-UNDO.
def var DelimPos        as int                 NO-UNDO.
def var i               as int                 NO-UNDO.
_Do:
do i = 1 to num-entries(DirList):
   assign
     DirName  = trim(entry(i,DirList))
     DelimPos = 0.
   if DirName = "" then next _Do.
   if index (OpList, "D") > 0 then OS-DELETE value(DirName) RECURSIVE.
   if index (OpList, "C") > 0 then repeat:
      DelimPos = index (DirName, "\", DelimPos + 1).
      ParentDir = (if DelimPos = 0 then DirName
                   else substr (DirName, 1, DelimPos - 1)).
      if ParentDir = "" or ParentDir = "." or ParentDir = ".."
       or (length(ParentDir) = 2 and substr(ParentDir,2,1) = ":")
       then next.
      if SEARCH(ParentDir) <> ? then do:
         message " Не могу создать каталог " + ParentDir
          + " - есть файл с таким именем "
          view-as alert-box title " ОШИБКА ".
         return "ERROR".
      end.
      DirFound = YES.
      if OPSYS = "UNIX" and index(OpList,"A") > 0 then do:
         OS-DELETE ./_tmp.
         OS-COMMAND silent [ -d value(ParentDir) ] echo Y > ./_tmp.
         if SEARCH("./_tmp") = ? then DirFound = NO.
         else OS-DELETE ./_tmp.
      end.
      OS-CREATE-DIR value(ParentDir).
      if OS-ERROR > 0 then do:
         message " Не могу создать каталог " + ParentDir + " "
          view-as alert-box title " ОШИБКА ".
         return "ERROR".
      end.
      if DirFound = NO AND OPSYS = "UNIX" then
         OS-COMMAND silent chmod 777 value(ParentDir) 2>/dev/null.
      else .
      if DelimPos = 0 then leave.
   end.
end.
return "OK".
