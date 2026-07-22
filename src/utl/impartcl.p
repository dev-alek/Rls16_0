block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: impartcl.p $
$Archive: utl/impartcl.p $

Описание программы
Импорт  артикул поставщика из файла
Автор: Румянцев Юрий Александрович
Дата создания: 03/17/08
Author: Yuri Rumyantsev
Creation date: 03/17/08

*/
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: impartcl.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/impartcl.p $":U .
define variable vss-description as character no-undo initial "Импорт  артикул поставщика из файла":U .
{ cmp/vssrevis.i " " }

define buffer buf_cli-gds for ub.cli-gds.

def var file-name as char no-undo.
def var i1        as int no-undo.
def var i2        as int no-undo.
def var s         as char no-undo.

def var r-cli-type  like ub.cli-gds.cli-type   no-undo.
def var r-cli-code  like ub.cli-gds.cli-code   no-undo.
def var r-host-code like ub.cli-gds.host-code  no-undo.
def var r-article   like ub.cli-gds.artic      no-undo.
def var r-prod-type like ub.cli-gds.prod-type  no-undo.
def var r-prod-code like ub.cli-gds.prod-code  no-undo.
def var r-cli-art   like ub.cli-gds.cli-art    no-undo.

def stream err.

message " Будем импортировать из текстового файла артикулы поставщика ? "
view-as alert-box Warning buttons yes-no UPDATE choice AS LOGICAL.

if choice = false then return.

def var g#log as log no-undo.
system-dialog get-file file-name
  title "Выберите файл с артикулами поставщика"
  filters "Текстовый файл (*.txt)"   "*.txt",
            "Все файлы" "*.*"
update g#log.

input FROM value (File-Name) convert source "1251".

i1 = 0.
i2 = 0.

repeat:
     import unformatted s.
     s = trim (s).
     if s = "" then next.

     i1 = i1 + 1.
     disp i1 label "Прочитано" with frame a view-as dialog-box. PAUSE 0.

     if NUm-ENTRIES(s, ";") <> 7 then do:
           next.
     end.

     r-cli-type  = entry (1, s, ";") no-error.
     r-cli-code  = int(entry (2, s, ";")) no-error.
     r-host-code = int(entry (3, s, ";")) no-error.
     r-article   = entry (4, s, ";") no-error.
     r-prod-type = entry (5, s, ";") no-error.
     r-prod-code = int(entry (6, s, ";")) no-error.
     r-cli-art   = entry (7, s, ";") no-error.




     find buf_cli-gds where
         buf_cli-gds.cli-type   = r-cli-type and
         buf_cli-gds.cli-code   = r-cli-code  and
         buf_cli-gds.host-code  = r-host-code and
         buf_cli-gds.artic      = r-article   and
         buf_cli-gds.prod-type  = r-prod-type  and
         buf_cli-gds.prod-code  = r-prod-code
     no-error.
     if available buf_cli-gds then do:
        if trim(buf_cli-gds.cli-art) <> "" then next.
        buf_cli-gds.cli-art = r-cli-art.
     end.
     else do:
         create buf_cli-gds.
         assign
             buf_cli-gds.cli-type   = r-cli-type
             buf_cli-gds.cli-code   = r-cli-code
             buf_cli-gds.host-code  = r-host-code
             buf_cli-gds.artic      = r-article
             buf_cli-gds.prod-type  = r-prod-type
             buf_cli-gds.prod-code  = r-prod-code
             buf_cli-gds.cli-art    = r-cli-art
         .
     end.

end.

input close.

message " Импорт закончен "
view-as alert-box information buttons ok.
