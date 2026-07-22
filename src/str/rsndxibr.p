block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rsndxibr.p $
$Archive: str/rsndxibr.p $

Утилита досылки недошедших файлов на кассу IBM-XML - запуск

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/30/05
Author: Bakhtadze Natalya
Creation date: 10/30/05

*/

define input  parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rsndxibr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/rsndxibr.p $":U .
define variable vss-description as character no-undo init "Утилита досылки недошедших файлов на кассу IBM-XML - запуск".
{ cmp/vssrevis.i }

define variable v-dir-name as character no-undo .
define variable v-dir-type as character no-undo .
define variable v-can-write as logical   no-undo .

message
"Выберите каталог, в котором лежат файлы подлежащие пересылке на кассы IBM-XML"
view-as alert-box .
run gbl/dir-sel.p (
              output v-dir-name
             ,output v-dir-type
             ,output v-can-write ) no-error .
if error-status :error
or v-dir-name = '':u then return.



run str/diallog.w (
              input parparentproc
            , input this-procedure
            , input 'str/rsndxibm.p':U
            , input v-dir-name
            , input no
            , input 'Прервать'
            , input 'Досылка сформированных файлов на кассы IBM-XML') no-error .