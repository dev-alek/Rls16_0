/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура инициализации указателей на библиотеки в классах

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/14/07
Author: Bakhtadze Natalya
Creation date: 06/14/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "non-class-part" &then

/*эта часть помещается в НЕ-CLASS файл*/

procedure library-cls_get-handle :
define input parameter p-library-name as character no-undo .
define output parameter p-library-handle as handle no-undo .

  do
  on error undo, return error
  :
    CASE p-library-name:
      when "library" then do:
        {&check_library}
        p-library-handle = g#library.
      end.
      when "library2" then do:
        {&check_library}
        p-library-handle = g#library2.
      end.
      /*
      when "attr-lib" then do:
        {&check_library}
        p-library-handle = g#attr-lib.
      end.
      */
    end case.
  end.
end procedure. /* library-cls_get-handle */
&Endif

&if "{1}" = "class-part" &then
&if defined (include_library) = 0 &then
/*эта часть помещается в CLASS файл*/
&glob include_library yes
define protected variable g#library  as handle no-undo .
define protected variable g#library2 as handle no-undo .
define protected variable g#attr-lib as handle no-undo .

&glob check_library if (valid-handle(g#library) <> true) then do: ~
  run library-cls_get-handle in v_gc ( input "library", output g#library) no-error. ~
  if error-status :error or (valid-handle(g#library) <> true) then do: ~
    message ~
      "Error starting library.p" skip ~
      g#library skip ~
      g#library :type skip ~
      g#library :file-name skip ~
      error-status :get-message(1) skip ~
      return-value skip ~
      view-as alert-box error . ~
    stop . ~
  end. ~
end.

&glob run_proc_library {&check_library} ~
run ~{&proc-name~} in g#library

&glob check_library2 if (valid-handle(g#library2) <> true) then do: ~
  run library-cls_get-handle in v_gc ( input "library2", output g#library2) no-error. ~
  if error-status :error or (valid-handle(g#library2) <> true) then do: ~
    message ~
      "Error starting library2.p" skip ~
      g#library2 skip ~
      g#library2 :type skip ~
      g#library2 :file-name skip ~
      error-status :get-message(1) skip ~
      return-value skip ~
      view-as alert-box error . ~
    stop . ~
  end. ~
end.

&glob run_proc_library2 {&check_library2} ~
run ~{&proc-name~} in g#library2

&glob check_attr-lib if (valid-handle(g#attr-lib) <> true) then do: ~
  run library-cls_get-handle in v_gc ( input "attr-lib", output g#attr-lib) no-error. ~
  if error-status :error or (valid-handle(g#attr-lib) <> true) then do: ~
    message ~
      "Error starting attr-lib.p" skip ~
      g#attr-lib skip ~
      g#attr-lib :type skip ~
      g#attr-lib :file-name skip ~
      error-status :get-message(1) skip ~
      return-value skip ~
      view-as alert-box error . ~
    stop . ~
  end. ~
end.

&glob run_proc_attr-lib {&check_attr-lib} ~
run ~{&proc-name~} in g#attr-lib


&endif



&endif

/* $Workfile$ e n d */