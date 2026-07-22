/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ссылка на библиотеку фискального регистратора

Автор: Белоусов Илья Александрович
Дата создания: 07/14/08
Author: Ilia Belousov
Creation date: 07/14/08

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


&if defined( include_fr-lib ) = 0 &then
&glob include_fr-lib yes
define new global shared variable g#fr-lib as handle no-undo.

  &glob check_fr-lib ~
    if valid-handle( g#fr-lib ) <> TRUE then do: ~
      run gbl/fr-lib.p persistent no-error. ~
      if error-status :error or valid-handle( g#fr-lib ) <> TRUE then do: ~
        message "Error starting fr-lib.p" skip( 0 ) ~
          g#fr-lib                        skip( 0 ) ~
          g#fr-lib    :type               skip( 0 ) ~
          g#fr-lib    :file-name          skip( 0 ) ~
          error-status :get-message( 1 )  skip( 0 ) ~
          return-value                    skip( 0 ) ~
        view-as alert-box error. ~
        stop. ~
      end. /* error */ ~
    end. /* if not valid-handle( g#fr-lib ) */
  &glob run_proc_fr-lib ~
    {&check_fr-lib} ~
    run ~{&proc-name~} in g#fr-lib
&endif

/* $Workfile$ e n d */