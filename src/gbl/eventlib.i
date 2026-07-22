/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ссылка на библиотеку логирования событий на кассе

Автор: Белоусов Илья Александрович
Дата создания: 12/03/08
Author: Ilia Belousov
Creation date: 12/03/08

Input:

Output:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


&if defined( include_eventlib ) = 0 &then
&glob include_eventlib yes
define new global shared variable g#eventlib as handle no-undo.

  &glob check_eventlib ~
    if valid-handle( g#eventlib ) <> TRUE then do: ~
      run gbl/eventlib.p persistent no-error. ~
      if error-status :error or valid-handle( g#eventlib ) <> TRUE then do: ~
        message "Error starting eventlib.p" skip( 0 ) ~
          g#eventlib                        skip( 0 ) ~
          g#eventlib    :type               skip( 0 ) ~
          g#eventlib    :file-name          skip( 0 ) ~
          error-status :get-message( 1 )  skip( 0 ) ~
          return-value                    skip( 0 ) ~
        view-as alert-box error. ~
        stop. ~
      end. /* error */ ~
    end. /* if not valid-handle( g#eventlib ) */
  &glob run_proc_eventlib ~
    {&check_eventlib} ~
    run ~{&proc-name~} in g#eventlib
&endif

/* $Workfile$ e n d */