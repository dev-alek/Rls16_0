block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dirwatch.p $
$Archive: gbl/dirwatch.p $

Программа ожидания файла

Автор: Перваков Михаил Сергеевич
Дата создания: 08/18/05
Author: Mikhail Pervakov
Creation date: 08/18/05

Основная цель данной программы по возможности минимизировать
время реакции системы на появление необходимого файла.

Общая схема

  Включение механизма оповещения об изменениях в директории

  Вызов колбека анализа содержимого директории
    В случае возврата TRUE - освободить ресурсы и завершить программу

  Бесконечный цикл
  |    Ожидание изменений в директории в течение указанного количестве миллисекунд
  |
  |    Вызов колбека анализа содержимого директории
   \__ В случае возврата TRUE - освободить ресурсы и завершить программу

На вызывающую программу ложится ответственность прекращения работы
программы по таймауту.

*/

define input  parameter p-callback-handle    as handle    no-undo .
define input  parameter p-callback-procedure as character no-undo .
define input  parameter p-directory-name     as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dirwatch.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/dirwatch.p $":U .
define variable vss-description as character no-undo init "Программа ожидания файла".
{ cmp/vssrevis.i }

define variable v-proc-signature  as character no-undo .
define variable v-directory-name  as character no-undo .
define variable v-change-handle   as integer   no-undo .
define variable v-result          as integer   no-undo .
define variable v-memptr-dir-name as memptr    no-undo .
define variable v-ret-param       as integer   no-undo .
define variable v-terminate-watch as logical   no-undo .

do
on error undo, return error return-value
:

  if valid-handle(p-callback-handle) <> true
  then do:
    undo, return error substitute("Ошибка задания параметров. Неправильно задан указатель на процедуру &1", p-callback-handle) .
  end.

  assign
    v-proc-signature = p-callback-handle :get-signature(p-callback-procedure)
  .

  if v-proc-signature = ""
  or v-proc-signature = ?
  then do:
    undo, return error substitute("Ошибка задания параметров. Неправильно задано имя процедуры &1", p-callback-procedure) .
  end.

  assign
    file-info :file-name = p-directory-name
    v-directory-name     = file-info :full-pathname
  .

  if v-directory-name = ?
  or v-directory-name = ""
  then do:
    undo, return error substitute("Ошибка задания параметров. Неправильно задано имя директории &1.", p-directory-name) .
  end.

  if index(file-info :file-type, "D") = 0
  then do:
    undo, return error substitute("Ошибка задания параметров. Неправильно задано имя директории &1.", p-directory-name) .
  end.

  assign
    set-size(v-memptr-dir-name) = length(v-directory-name) + 1
  .
  assign
    put-string(v-memptr-dir-name, 1) = v-directory-name
  .

/*#define FILE_NOTIFY_CHANGE_FILE_NAME    0x00000001*/
/*#define FILE_NOTIFY_CHANGE_DIR_NAME     0x00000002*/
/*#define FILE_NOTIFY_CHANGE_NAME         0x00000003*/
/*#define FILE_NOTIFY_CHANGE_ATTRIBUTES   0x00000004*/
/*#define FILE_NOTIFY_CHANGE_SIZE         0x00000008*/
/*#define FILE_NOTIFY_CHANGE_LAST_WRITE   0x00000010*/
/*#define FILE_NOTIFY_CHANGE_LAST_ACCESS  0x00000020*/
/*#define FILE_NOTIFY_CHANGE_CREATION     0x00000040*/
/*#define FILE_NOTIFY_CHANGE_EA           0x00000080*/
/*#define FILE_NOTIFY_CHANGE_SECURITY     0x00000100*/
/*#define FILE_NOTIFY_CHANGE_STREAM_NAME  0x00000200*/
/*#define FILE_NOTIFY_CHANGE_STREAM_SIZE  0x00000400*/
/*#define FILE_NOTIFY_CHANGE_STREAM_WRITE 0x00000800*/
/*#define FILE_NOTIFY_VALID_MASK          0x00000fff*/

  run FindFirstChangeNotificationA
    (input v-memptr-dir-name
    ,input 0
    ,input 1   /* FILE_NOTIFY_CHANGE_FILE_NAME */
    ,output v-change-handle
    ) .
  if v-change-handle = -1
  then do:
    undo, return error "Ошибка при вызове функции FindFirstChangeNotificationA" .
  end.

  run value(p-callback-procedure) in p-callback-handle
    (output v-terminate-watch
    ) .

/*WAIT_ABANDONED 0x00000080L The specified object is a mutex object that */
/*                           was not released by the thread that owned */
/*                           the mutex object before the owning thread terminated. */
/*                           Ownership of the mutex object is granted to */
/*                           the calling thread, and the mutex is set */
/*                           to nonsignaled.*/
/*                           If the mutex was protecting persistent state */
/*                           information, you should check it for consistency.*/
/*WAIT_OBJECT_0 0x00000000L  The state of the specified object is signaled.*/
/*WAIT_TIMEOUT  0x00000102L  The time-out interval elapsed, and the object's */
/*                           state is nonsignaled. */

  if v-terminate-watch <> true
  then do:
    watch_cycle:
    do while true
    :
      run WaitForSingleObject
        (input  v-change-handle
        ,input  1000
        ,output v-result
        ) .
      if v-result = 0
      then do:
        run FindNextChangeNotification
          (input  v-change-handle
          ,output v-result
          ) .
        if v-result = 0
        then do:
          run FindCloseChangeNotification
            (input  v-change-handle
            ,output v-result
            ) .
          undo, return error "Ошибка при вызове функции FindNextChangeNotification" .
        end.
      end.

      run value(p-callback-procedure) in p-callback-handle
        (output v-terminate-watch
        ) .
      if v-terminate-watch = true
      then do:
        leave watch_cycle . /* --->>>--- */
      end.
    end.
  end.

  run FindCloseChangeNotification
    (input  v-change-handle
    ,output v-result
    ) .
end.


PROCEDURE FindFirstChangeNotificationA EXTERNAL "kernel32.dll"
:
    DEFINE INPUT        PARAMETER lpPathName       AS MEMPTR . /*  */
    DEFINE INPUT        PARAMETER bWatchSubtree    AS LONG   . /*  */
    DEFINE INPUT        PARAMETER dwNotifyFilter   AS LONG   . /*  */
    DEFINE RETURN       PARAMETER RetParam         AS LONG   .
END PROCEDURE. /* FindFirstChangeNotificationA */

PROCEDURE FindNextChangeNotification EXTERNAL "kernel32.dll"
:
    DEFINE INPUT        PARAMETER hChangeHandle    AS LONG   . /*  */
    DEFINE RETURN       PARAMETER RetParam         AS LONG   .
END PROCEDURE. /* FindNextChangeNotificationA */

PROCEDURE FindCloseChangeNotification EXTERNAL "kernel32.dll"
:
    DEFINE INPUT        PARAMETER hChangeHandle    AS LONG. /*  */
    DEFINE RETURN       PARAMETER RetParam         AS LONG.
END PROCEDURE. /* FindCloseChangeNotification */


PROCEDURE WaitForSingleObject EXTERNAL "kernel32.dll"
:
    DEFINE INPUT        PARAMETER hChangeHandle  AS LONG. /*  */
    DEFINE INPUT        PARAMETER dwMilliseconds AS LONG. /*  */
    DEFINE RETURN       PARAMETER RetParam       AS LONG.
END PROCEDURE. /* WaitForSingleObject */