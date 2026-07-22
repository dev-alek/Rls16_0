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


&if defined( include_sb-lib ) = 0 &then
&glob include_sb-lib yes
define new global shared variable g#sb-lib as handle no-undo.

  &glob check_sb-lib ~
    if valid-handle( g#sb-lib ) <> TRUE then do: ~
      run gbl/sb-lib.p persistent no-error. ~
      if error-status :error or valid-handle( g#sb-lib ) <> TRUE then do: ~
        message "Error starting sb-lib.p" skip( 0 ) ~
          g#sb-lib                        skip( 0 ) ~
          g#sb-lib    :type               skip( 0 ) ~
          g#sb-lib    :file-name          skip( 0 ) ~
          error-status :get-message( 1 )  skip( 0 ) ~
          return-value                    skip( 0 ) ~
        view-as alert-box error. ~
        stop. ~
      end. /* error */ ~
    end. /* if not valid-handle( g#sb-lib ) */
  &glob run_proc_sb-lib ~
    {&check_sb-lib} ~
    run ~{&proc-name~} in g#sb-lib
&endif

/* $Workfile$ e n d */