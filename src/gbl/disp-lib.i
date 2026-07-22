/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ссылка на библиотеку Сбербанка

Автор: Белоусов Илья Александрович
Дата создания: 09/24/08
Author: Ilia Belousov
Creation date: 09/24/08

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


&if defined( include_disp-lib ) = 0 &then
&glob include_disp-lib yes
define new global shared variable g#disp-lib as handle no-undo.

  &glob check_disp-lib ~
    if valid-handle( g#disp-lib ) <> TRUE then do: ~
      run gbl/disp-lib.p persistent no-error. ~
      if error-status :error or valid-handle( g#disp-lib ) <> TRUE then do: ~
        message "Error starting disp-lib.p" skip( 0 ) ~
          g#disp-lib                        skip( 0 ) ~
          g#disp-lib    :type               skip( 0 ) ~
          g#disp-lib    :file-name          skip( 0 ) ~
          error-status :get-message( 1 )  skip( 0 ) ~
          return-value                    skip( 0 ) ~
        view-as alert-box error. ~
        stop. ~
      end. /* error */ ~
    end. /* if not valid-handle( g#disp-lib ) */
  &glob run_proc_disp-lib ~
    {&check_disp-lib} ~
    run ~{&proc-name~} in g#disp-lib
&endif

/* $Workfile$ e n d */