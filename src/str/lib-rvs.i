/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ссылка на библиотеку сверок

Автор: Уханов Дмитрий Юрьевич
Дата создания: 12/07/07
Author: Dmitry Ukhanov
Creation date: 12/07/07

Автор1: Булгаков Андрей Николаевич
Дата создания1: 12/23/05

*/

&if defined( include_lib-rvs ) = 0 &then
&glob include_lib-rvs yes

&if "{1}" = "class" &then
&else
  define new global shared variable g#lib-rvs as handle no-undo.
&endif

&if "{1}" = "class" &then

  &glob run_proc_lib-rvs ~
    {&check_lib-rvs} ~
  run ~{&proc-name~} in ibs.th.gbl.gbl-hndllib:g#lib-rvs

&else
  
  &glob check_lib-rvs ~
    if valid-handle( g#lib-rvs ) <> yes then do: ~
      run str/lib-rvs.p persistent no-error. ~
      if error-status :error or valid-handle( g#lib-rvs ) <> yes then do: ~
        message "Error starting lib-rvs.p" skip( 0 ) ~
          g#lib-rvs                        skip( 0 ) ~
          g#lib-rvs    :type               skip( 0 ) ~
          g#lib-rvs    :file-name          skip( 0 ) ~
          error-status :get-message( 1 )   skip( 0 ) ~
          return-value                     skip( 0 ) ~
        view-as alert-box error. ~
        stop. ~
      end. /* error */ ~
    end. /* if not valid-handle( g#lib-rvs ) */
  &glob run_proc_lib-rvs ~
    {&check_lib-rvs} ~
    run ~{&proc-name~} in g#lib-rvs
&endif
&endif
/* $Workfile$   E n d */
