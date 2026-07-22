block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dir_cd.p $
$Archive: bge/dir_cd.p $

Создание и удаление каталога (RECURSIVE)

Автор: Хныкин Павел Андреевич
Дата создания: 04/05/06
Author: Pavel Khnykin
Creation date: 04/05/06

Input:

Output:

*/

&if OPSYS = "UNIX" &then
&SCOP Slash /
&else
&SCOP Slash ~\
&endif


def input parameter DirList as char case-sensitive.
def input parameter OpList  as char.
/* "D" - удалить, "C" - создать, "A" - при создании установить права a+rwx */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dir_cd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/dir_cd.p $":U .
define variable vss-description as character no-undo init "Создание и удаление каталога (RECURSIVE)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

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
      DelimPos = index (DirName, "{&Slash}", DelimPos + 1).
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
         OS-COMMAND silent [ -d value(ParentDir) ] && echo Y > ./_tmp.
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
      else . /* Для DOS & WIN нет обработки */

      if DelimPos = 0 then leave.
   end.
end.

return "OK".