/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ссылка на библиотеку для работы с атрибутами партии на объекте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/10/10
Author: Bakhtadze Natalya
Creation date: 02/10/10

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&if defined( include_partolib ) = 0 &then

/* Доверенность */
&glob fillin_width-partoatr-parts-end 10
&glob fillin_height-partoatr-parts-end 3
&glob type-partoatr-parts-end {&type-char}
&glob format-partoatr-parts-end "x(10)"
&glob label-partoatr-parts-end "Дата исчерпания своб зоны"
&glob tooltip-partoatr-parts-end "Дата исчерпания своб зоны"
&glob user-can-edit-partoatr-parts-end false
&glob output-display-partoatr-parts-end true
&glob other-partoatr-parts-end '':u
&glob news-partoatr-parts-end true
&glob sort-partoatr-parts-end 45


 define new global shared variable g#partolib as handle no-undo.

  &glob include_partolib yes
  &glob check_partolib ~
    if valid-handle( g#partolib ) <> yes then do: ~
      run str/partolib.p persistent no-error. ~
      if error-status :error or valid-handle( g#partolib ) <> yes then do: ~
        message "Error starting partolib.p"    skip( 0 ) ~
                g#partolib                     skip( 0 ) ~
                g#partolib   :type             skip( 0 ) ~
                g#partolib   :file-name        skip( 0 ) ~
                error-status :get-message( 1 ) skip( 0 ) ~
                return-value                   skip( 0 ) ~
        view-as alert-box error. ~
        stop. ~
      end. /* error */ ~
    end. /* if not valid-handle( g#partolib ) */
  &glob run_proc_partolib ~
    {&check_partolib} ~
    run ~{&proc-name~} in g#partolib
&endif

/* $Workfile$   E n d */