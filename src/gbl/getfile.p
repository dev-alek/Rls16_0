block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: getfile.p $
$Archive: gbl/getfile.p $

Выбор файла

Автор: Перваков Михаил Сергеевич
Дата создания: 04/11/06
Author: Mikhail Pervakov
Creation date: 04/11/06

*/

define input-output parameter v-file-id        as character no-undo .
define input-output parameter v-file-directory as character no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: getfile.p $":U .
def var vss-archive     as character no-undo init "$Archive: gbl/getfile.p $":U .
def var vss-description as character no-undo init "Выбор файла".
{ cmp/vssrevis.i "substitute('&1|&2':u,v-file-id,v-file-directory)" }

def var lok as logical no-undo .

do
on error undo, return error return-value
:
  SYSTEM-DIALOG GET-FILE v-file-id
    FILTERS 'Все файлы' '*.*':u
      , 'Progress' '*.i, *.p, *.w':u
    INITIAL-DIR v-file-directory MUST-EXIST
    TITLE "Выберите файл"
    UPDATE lok .

end.