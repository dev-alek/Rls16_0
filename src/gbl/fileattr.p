block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fileattr.p $
$Archive: gbl/fileattr.p $

Изменить атрибуты файла

Автор: Перваков Михаил Сергеевич
Дата создания: 12/13/05
Author: Mikhail Pervakov
Creation date: 12/13/05

*/

define input  parameter p-file-name     as character no-undo .
define input  parameter p-attrib-action as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fileattr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/fileattr.p $":U .
define variable vss-description as character no-undo init "Изменить атрибуты файла".
{ cmp/vssrevis.i }

do
on error undo, return error return-value
:

  define variable v-memptr-file-name as memptr    no-undo .
  define variable v-file-attributes  as integer   no-undo .

  assign
    set-size(v-memptr-file-name) = length(p-file-name) + 1
  .
  assign
    put-string(v-memptr-file-name, 1) = p-file-name
  .

  run GetFileAttributesA
    (input  get-pointer-value(v-memptr-file-name)
    ,output v-file-attributes
    ) .

  if v-file-attributes = -1
  then do:
    assign
      set-size(v-memptr-file-name) = 0
    .
    undo, return error "Ошибка чтения атрибутов" .
  end.

  define variable v-index   as integer   no-undo .
  define variable v-bits    as logical   no-undo extent 32 .
  define variable v-big-num as int64     no-undo .

  do v-index = 1 to 32
  :
    assign
      v-bits[v-index] = false
    .
  end.
  if v-file-attributes < 0
  then do:
    assign
      v-bits[1] = true
    .
  end.

  assign
    v-big-num = 256 * 256 * 256 * 64
  .
  do v-index = 2 to 32
  :
    if v-file-attributes < v-big-num
    then do:
      assign
        v-bits[v-index] = false
      .
    end.
    else do:
      assign
        v-bits[v-index] = true
      .
      assign
        v-file-attributes = v-file-attributes - v-big-num
      .
    end.
    assign
      v-big-num = v-big-num / 2
    .
  end.

  case p-attrib-action
  :
    when 'readonly-clear':u
    then do:
      assign
        v-bits[32] = false
      .
    end.
    when 'readonly-set':u
    then do:
      assign
        v-bits[32] = true
      .
    end.
    otherwise do:
      assign
        set-size(v-memptr-file-name) = 0
      .
      undo, return error "Неизвестное значение параметра" .
    end.
  end case .

  assign
    v-big-num         = 1
    v-file-attributes = 0
  .
  do v-index = 32 to 1 by -1
  :
    if v-bits[v-index] = true
    then do:
      assign
        v-file-attributes = v-file-attributes + v-big-num
      .
    end.
    assign
      v-big-num = v-big-num * 2
    .
  end.

  define variable v-ret-val as integer   no-undo .
  run SetFileAttributesA
    (input  get-pointer-value(v-memptr-file-name)
    ,input  v-file-attributes
    ,output v-ret-val
    ) .

  assign
    set-size(v-memptr-file-name) = 0
  .

  if v-ret-val = 0
  then do:
    run GetLastError
      (output v-ret-val
      ) .
    undo, return error substitute("Ошибка при установке атрибута &1"
                                  ,v-ret-val
                                  )
      .
  end.
end.

/* DWORD GetFileAttributes( */
/*   LPCTSTR lpFileName */
/* ); */

/* BOOL SetFileAttributes( */
/*   LPCTSTR lpFileName, */
/*   DWORD dwFileAttributes */
/* ); */

PROCEDURE GetFileAttributesA EXTERNAL "kernel32.dll"
:
    DEFINE INPUT        PARAMETER lpFileName AS LONG .
    DEFINE RETURN       PARAMETER RetParam   AS LONG .
END PROCEDURE.

PROCEDURE SetFileAttributesA EXTERNAL "kernel32.dll"
:
    DEFINE INPUT  PARAMETER lpFileName       AS LONG .
    DEFINE INPUT  PARAMETER dwFileAttributes AS LONG .
    DEFINE RETURN PARAMETER RetParam         AS LONG .
END PROCEDURE.

/* DWORD GetLastError(void); */
PROCEDURE GetLastError EXTERNAL "kernel32.dll"
:
    DEFINE RETURN       PARAMETER RetParam  AS LONG .
END PROCEDURE. /* GetLastError */
