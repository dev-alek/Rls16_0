/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

ссылка на библиотеку процедур по работе с информационными таблицами trn-doc-sum doc-line-sum (вместо  r w d o c s u m . i)

Автор: Чернова Светлана Александровна
Дата создания: 11/02/06
Author: Svetlana Chernova
Creation date: 11/02/06

create: Булгаков Андрей Николаевич

*/

&if defined( include_lib-rwds ) = 0 &then
  { str/rwds-def.i }

  define new global shared variable g#lib-rwds as handle no-undo.

  &glob include_lib-rwds yes
  &glob check_lib-rwds ~
    if valid-handle( g#lib-rwds ) <> yes then do: ~
      run str/lib-rwds.p persistent no-error. ~
      if error-status :error or valid-handle( g#lib-rwds ) <> yes then do: ~
        message "Error starting lib-rwds.p" skip( 0 ) ~
          g#lib-rwds                        skip( 0 ) ~
          g#lib-rwds   :type                skip( 0 ) ~
          g#lib-rwds   :file-name           skip( 0 ) ~
          error-status :get-message( 1 )    skip( 0 ) ~
          return-value                      skip( 0 ) ~
        view-as alert-box error. ~
        stop. ~
      end. /* error */ ~
    end. /* if not valid-handle( g#lib-rwds ) */
  &glob run_proc_lib-rwds ~
    {&check_lib-rwds} ~
    run ~{&proc-name~} in g#lib-rwds
&endif

/* $Workfile$   E n d */
