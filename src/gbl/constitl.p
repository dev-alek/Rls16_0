block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: constitl.p $
$Archive: gbl/constitl.p $

Запись информации в консоль

Автор: Перваков Михаил Сергеевич
Дата создания: 02/02/06
Author: Mikhail Pervakov
Creation date: 02/02/06

При необходимости консоль автоматически создаетс

p-title - строка в кодировке Windows 1251

*/

define input  parameter p-title           as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: constitl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/constitl.p $":U .
define variable vss-description as character no-undo init "Запись информации в консоль".
{ cmp/vssrevis.i }

&scoped-define STD_OUTPUT_HANDLE -11
&scoped-define INVALID_HANDLE_VALUE -1

define variable v-window-handle        as integer   no-undo .
define variable v-result               as integer   no-undo .
define variable v-stdout               as integer   no-undo .
define variable v-title                as character no-undo .
define variable v-title-length         as integer   no-undo .
define variable v-memptr-console-title as memptr    no-undo .
define variable v-write-string         as character no-undo .
define variable v-write-string-length  as integer   no-undo .
define variable v-memptr-write-string  as memptr    no-undo .

do
on error undo, return error return-value
:

  run GetConsoleWindow
    (output v-window-handle
    ) .
  if v-window-handle = 0
  then do:
    run AllocConsole
      (output v-result
      ) .
  end.

  assign
    v-title        = p-title
    v-title-length = length(v-title)
  .
  assign
    set-size(v-memptr-console-title) = (v-title-length + 1) * 3
  .
  assign
    put-string(v-memptr-console-title, 1) = v-title
  .

  run MultiByteToWideChar
    (input  1251
    ,input  0
    ,input  get-pointer-value(v-memptr-console-title)
    ,input  v-title-length
    ,input  get-pointer-value(v-memptr-console-title) + (v-title-length + 1)
    ,input  (v-title-length + 1) * 2
    ,output v-result
    ) .

  run SetConsoleTitleW
    (input  get-pointer-value(v-memptr-console-title) + (v-title-length + 1)
    ,output v-result
    ) .

  assign
    set-size(v-memptr-console-title) = 0
  .
end.

PROCEDURE AllocConsole EXTERNAL "kernel32.dll"
:
   DEFINE RETURN PARAMETER RetParam  AS LONG .
END PROCEDURE .

PROCEDURE GetConsoleWindow EXTERNAL "kernel32.dll"
:
   DEFINE RETURN PARAMETER RetParam  AS LONG .
END PROCEDURE .

PROCEDURE SetConsoleTitleW EXTERNAL "kernel32.dll"
:
   DEFINE INPUT  PARAMETER lpConsoleTitle AS LONG .
   DEFINE RETURN PARAMETER RetParam       AS LONG .
END PROCEDURE .

PROCEDURE MultiByteToWideChar EXTERNAL "KERNEL32.dll"
:
  define input  parameter uCodePage      as long. /* code page */
  define input  parameter dwFlags        as long. /* performance and mapping flags */
  define input  parameter lpMultiByteStr as long. /* address of wide-character string */
  define input  parameter cbMubtiByte    as long. /* number of characters in string */
  define input  parameter lpWideCharStr  as long. /* address of buffer for new string */
  define input  parameter cbMultiByte    as long. /* size of buffer */
  define return parameter iRetCode       as long. /* if successful, number of bytes written to the lpMultiByteStr buffer, else 0 */
END.