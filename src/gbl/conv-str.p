block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: conv-str.p $
$Archive: gbl/conv-str.p $

Программа перевода из одной кодировки в другую

Автор: Перваков Михаил Сергеевич
Дата создания: 06/01/04
Author: Mikhail Pervakov
Creation date: 06/01/04

Примеры вызова:

define variable v-test-utf as character no-undo .
define variable v-test-win as character no-undo .

define variable v-cp-utf8 as integer no-undo init 65001 .
define variable v-cp-windows1251 as integer no-undo init 1251 .

run gbl/conv-str.p
  (input v-cp-windows1251
  ,input "Russian Русский текст"
  ,input v-cp-utf8
  ,output v-test-utf
  ) .
message
  "UTF-8:" v-test-utf skip
  view-as alert-box .

run gbl/conv-str.p
  (input v-cp-utf8
  ,input v-test-utf
  ,input v-cp-windows1251
  ,output v-test-win
  ) .
message
  "Win-1251:" v-test-win skip
  view-as alert-box .

*/

define input  parameter p-from-encoding as integer   no-undo .
define input  parameter p-from-string   as character no-undo .
define input  parameter p-to-encoding   as integer   no-undo .
define output parameter p-to-string     as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: conv-str.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/conv-str.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
define variable lp-from-string as  memptr  no-undo .
define variable lp-out-string as  memptr  no-undo .
define variable lp-wide-char  as  memptr  no-undo .


/* WideChar (unicode) to MultiByte (Ansi) */
PROCEDURE WideCharToMultiByte   EXTERNAL "KERNEL32.dll"
:
  define input  parameter uCodePage         as long.  /* code page                         */
  define input  parameter dwFlags           as long.  /* performance and mapping flags     */
  define input  parameter lpWideCharStr     as long.  /* address of wide-character string  */
  define input  parameter cbWideChar        as long.  /* number of characters in string, if -1 is calculated on the fly */
  define input  parameter lpMultiByteStr    as long.  /* address of buffer for new string */
  define input  parameter cbMultiByte       as long.  /* size of buffer */
  define input  parameter lpDefaultChar     as long.  /* address of default for unmappable characters */
  define input  parameter lpUsedDefaultChar as long.  /* address of flag set when default char is used */
  define return parameter iRetCode          as long.  /* if successful, number of bytes written to the lpMultiByteStr buffer, else 0 */
END.

/* MultiByte (Ansi) to WideChar (Unicode) */
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

do
on error undo, return error return-value
:
  define variable v-max-length as integer   no-undo .

  assign
    v-max-length = length(p-from-string) * 5
  .

  set-size(lp-out-string) = v-max-length.
  set-size(lp-from-string) = v-max-length.
  set-size(lp-wide-char)  = v-max-length.

  put-string(lp-from-string, 1) = p-from-string .

  define variable v-ret-code as integer   no-undo .

  run MultiByteToWideChar
    (input  p-from-encoding /* code page */
    ,input  0     /* performance and mapping flags */
    ,input  get-pointer-value(lp-from-string) /* address of wide-character string */
    ,input  -1 /* number of characters in string */
    ,input  get-pointer-value(lp-wide-char) /* address of buffer for new string */
    ,input  get-size(lp-wide-char) /* size of buffer */
    ,output v-ret-code /* if successful, number of bytes written to the lpMultiByteStr buffer, else 0 */
    ) .
  if v-ret-code = 0
  then do:
    set-size(lp-out-string)  = 0.
    set-size(lp-from-string) = 0.
    set-size(lp-wide-char)   = 0.
    undo, return error "Ошибка при вызове процедуры MultiByteToWideChar" .
  end.


  run WideCharToMultiByte
    (input p-to-encoding  /* code-page */
    ,input 0     /* flags that specify the handling of unmapped characters */
    ,input get-pointer-value(lp-wide-char) /* pointer to wide-character string (unicode) */
    ,input -1            /* count of bytes of the wide-character string, if -1 calculate on the fly */
    ,input get-pointer-value(lp-out-string) /* address of buffer for new string */
    ,input get-size(lp-out-string)
    ,input 0
    ,input 0
    ,output v-ret-code
    ).
  if v-ret-code = 0
  then do:
    set-size(lp-out-string)  = 0.
    set-size(lp-from-string) = 0.
    set-size(lp-wide-char)   = 0.
    undo, return error "Ошибка при вызове процедуры WideCharToMultiByte" .
  end.

  assign
    p-to-string = get-string(lp-out-string, 1)
  .

  set-size(lp-out-string)  = 0.
  set-size(lp-from-string) = 0.
  set-size(lp-wide-char)   = 0.

end.