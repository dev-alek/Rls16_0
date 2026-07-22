block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 17 авг. 2021 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 17 авг. 2021 г.

*/
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "Обновление болванки".
{ cmp/vssrevis.i }
{cmp/str-glbl.i}
{utl/search.i}
define variable masynchelper as class ibs.th.file.asynchelperTh no-undo.
mAsyncHelper = new ibs.th.file.AsyncHelperth().
mAsyncHelper:mProcPublish = this-procedure.    /* хандел для публикации событий */
mAsyncHelper:conpar = "".                      /* уберем подключение */
mAsyncHelper:MyBachMode = session:batch-mode.  /* установка батч режима */
mAsyncHelper:DbConnect = no.
if session:system-alert-boxes
then
   mAsyncHelper:SaveFile = yes.                   /* Резульятат сохранить в архиве */ 
    
mAsyncHelper:AsyncProc("utl/proc-ubexeupd", "",1).
run ibs\th\file\waithelper.p (mAsyncHelper,?, 1,"Обновление болванки.").
    
define variable mlogfile as character no-undo. 
define stream  sReadfile.
define variable mText as character no-undo.
define variable mError as logical no-undo.  
mlogfile = mAsyncHelper:getLog("proc-ubexeupd").
if SearchFile(mlogfile) ne ?
then do:
   input stream sReadfile FROM  VALUE(SearchFile(mlogfile)).
   output to "ubblack.txt".
   repeat:
      import stream sReadfile unformatted mText.
      put unformatted mText skip.
          if mtext begins "error" then mError = yes.
   end.
   output close.
   input stream sReadfile close  .
   os-delete value(SearchFile(mlogfile)).
   
   if mError
   then
      message "Произошла ошибка при обновление БД":U
      view-as alert-box. 
end.
if session:system-alert-boxes
then
   message "Результаты выполнения находятся в " mAsyncHelper:SaveArh() skip
           "Лог выполнения сохранен в " SearchFile("ubblack.txt")
      view-as alert-box.
else
   message "Лог выполнения сохранен в " SearchFile("ubblack.txt")
   view-as alert-box.
   
delete object mAsyncHelper.
