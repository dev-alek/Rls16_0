/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

макрокоманда для включения одной горячей клавиши

Автор: Белоусов Илья Александрович
Дата создания: 07/16/07
Author: Ilia Belousov
Creation date: 07/16/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/11/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&IF '{2}' = '' &THEN
  &SCOP proc_frame {&FRAME-NAME}
&ELSE
  &SCOP proc_frame {2}
&ENDIF

on {&{1}} of frame {&proc_frame} anywhere do:
  if {1} :sensitive then DO: apply "CHOOSE":U to {1} in frame {&proc_frame}. END.
  return no-apply.
end.
/* $Workfile$ e n d */