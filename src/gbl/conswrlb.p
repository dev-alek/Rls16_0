block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: conswrlb.p $
$Archive: gbl/conswrlb.p $

Библиотека процедур

Автор: Перваков Михаил Сергеевич
Дата создания: 08/17/00
Author: Mikhail Pervakov
Creation date: 08/17/00

*/

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: conswrlb.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: gbl/conswrlb.p $":U .
define variable vss-description as character no-undo initial "Библиотека  процедур".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/conswrlb.i }

if valid-handle (g#conswrlb)
and g#conswrlb <> this-procedure :handle
and g#conswrlb :get-signature('conswrlb_testproc':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки" skip
    g#conswrlb skip
    g#conswrlb :type skip
    g#conswrlb :file-name skip
    valid-handle(g#conswrlb) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error .
end.
else do:
  assign
    g#conswrlb = this-procedure :handle
  .
end.

if this-procedure :persistent <> true
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка запуска библиотеки" program-name(1) skip
    "Попытка запустить ее как обычную процедуру" skip
    view-as alert-box error .
end.

on delete of this-procedure
do:
  assign
    g#conswrlb = ?
  .
end.

procedure conswrlb_testproc :

end.

&scoped-define STD_OUTPUT_HANDLE -11
&scoped-define INVALID_HANDLE_VALUE -1

procedure conswr :

  define input  parameter p-console-message as character no-undo .

  do
  on error undo, return error return-value
  :
    define variable v-window-handle        as integer   no-undo .
    define variable v-menu-handle          as integer   no-undo .
    define variable v-result               as integer   no-undo .
    define variable v-stdout               as integer   no-undo .
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
        run GetConsoleWindow
          (output v-window-handle
          ) .

        /* получаем меню консоли */
        run GetSystemMenu
          (input  v-window-handle
          ,input  0
          ,output v-menu-handle
          ) .

&scoped-define SC_CLOSE 61536
&scoped-define MF_BYCOMMAND 0
&scoped-define MF_GRAYED 1
&scoped-define MF_ENABLED 0

        /* удаляем пункт меню закрыть */
        run DeleteMenu
          (input  v-menu-handle
          ,input  {&SC_CLOSE}
          ,input  {&MF_BYCOMMAND}
          ,output v-result
          ) .

        /* запрещение пункта меню почему-то не работает */
/*        run EnableMenuItem*/
/*          (input v-menu-handle*/
/*          ,input {&SC_CLOSE}*/
/*          ,input {&MF_GRAYED}*/
/*          ,output v-result*/
/*          ) .*/
      end.

      run GetStdHandle in this-procedure
        (input  {&STD_OUTPUT_HANDLE}
        ,output v-stdout
        ) .

      assign
        v-write-string                  = p-console-message
        v-write-string-length           = length(v-write-string)
        set-size(v-memptr-write-string) = (v-write-string-length + 1) * 3 + 4
        put-string(v-memptr-write-string, 5) = v-write-string
      .

      run MultiByteToWideChar
        (input  1251
        ,input  0
        ,input  get-pointer-value(v-memptr-write-string) + 4
        ,input  v-write-string-length
        ,input  get-pointer-value(v-memptr-write-string) + 4 + (v-write-string-length + 1)
        ,input  (v-write-string-length + 1) * 2
        ,output v-result
        ) .

      if v-result = v-write-string-length
      then do:
        run WriteConsoleW
          (input  v-stdout
          ,input  get-pointer-value(v-memptr-write-string) + 4 + (v-write-string-length + 1)
          ,input  v-write-string-length
          ,input  get-pointer-value(v-memptr-write-string)
          ,input  0
          ,output v-result
          ) .
      end.

      assign
        set-size(v-memptr-write-string) = 0
      .
    end.
  end.

end procedure. /* conswr */




PROCEDURE AllocConsole EXTERNAL "kernel32.dll"
:
   DEFINE RETURN PARAMETER RetParam  AS LONG .
END PROCEDURE .

PROCEDURE GetConsoleWindow EXTERNAL "kernel32.dll"
:
   DEFINE RETURN PARAMETER RetParam  AS LONG .
END PROCEDURE .

PROCEDURE GetStdHandle EXTERNAL "kernel32.dll"
:
   DEFINE INPUT  PARAMETER nStdHandle AS LONG .
   DEFINE RETURN PARAMETER RetParam   AS LONG .
END PROCEDURE .

PROCEDURE WriteConsoleW EXTERNAL "kernel32.dll"
:
   DEFINE INPUT  PARAMETER hConsoleOutput         AS LONG .
   DEFINE INPUT  PARAMETER lpBuffer               AS LONG .
   DEFINE INPUT  PARAMETER nNumberOfCharsToWrite  AS LONG .
   DEFINE INPUT  PARAMETER lpNumberOfCharsWritten AS LONG .
   DEFINE INPUT  PARAMETER lpReserved             AS LONG .
   DEFINE RETURN PARAMETER RetParam               AS LONG .
END PROCEDURE .

PROCEDURE MultiByteToWideChar EXTERNAL "kernel32.dll"
:
  define input  parameter uCodePage      as long. /* code page */
  define input  parameter dwFlags        as long. /* performance and mapping flags */
  define input  parameter lpMultiByteStr as long. /* address of wide-character string */
  define input  parameter cbMubtiByte    as long. /* number of characters in string */
  define input  parameter lpWideCharStr  as long. /* address of buffer for new string */
  define input  parameter cbMultiByte    as long. /* size of buffer */
  define return parameter iRetCode       as long. /* if successful, number of bytes written to the lpMultiByteStr buffer, else 0 */
END.


PROCEDURE GetSystemMenu EXTERNAL "user32.dll"
:
  define input  parameter hWnd      as long. /* Handle to the window that will own a copy of the window menu. */
  define input  parameter bRevert   as long. /* Specifies the action to be taken. */
                                             /* If this parameter is FALSE, GetSystemMenu returns */
                                             /* a handle to the copy of the window menu currently */
                                             /* in use. The copy is initially identical to the window */
                                             /* menu, but it can be modified. If this parameter is */
                                             /* TRUE, GetSystemMenu resets the window menu back to */
                                             /* the default state. The previous window menu, if any, */
                                             /* is destroyed. */
  define return parameter hMenu     as long. /* If the bRevert parameter is FALSE, the return value */
                                             /* is a handle to a copy of the window menu. If the */
                                             /* bRevert parameter is TRUE, the return value is NULL. */
END.

PROCEDURE EnableMenuItem EXTERNAL "user32.dll"
:
  define input  parameter hMenu         as long.
  define input  parameter uIDEnableItem as long.
  define input  parameter uEnable       as long.
  define return parameter iRetCode      as long.
END.

PROCEDURE DeleteMenu EXTERNAL "user32.dll"
:
  define input  parameter hMenu         as long.
  define input  parameter uIDEnableItem as long.
  define input  parameter uEnable       as long.
  define return parameter iRetCode      as long.
END.