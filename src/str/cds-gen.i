/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

завершение работы  для данногь типа кассы для различных видов касс -

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/23/03
Author: Bakhtadze Natalya
Creation date: 06/23/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

case {&cd-buffer}.pos-type:
&if "{&cdt-IBM-XML}" = "yes" &then
&endif
&if "{&cdt-MAGIA-XML}" = "yes" &then
&endif
&if "{&cdt-IBM}" = "yes" &then
&endif
&if "{&cdt-NKT-IBM}" = "yes" &then
&endif
&if "{&cdt-OMRON}" = "yes" &then
&endif
&if "{&cdt-OMRON-NEW}" = "yes" &then
&endif
&if "{&cdt-IPC-SERVISPL}" = "yes" &then
  when {&cd-type-IPC-SERVISPL} then do:
    { str/cds-ipcs.i
    &cd-buffer={&cd-buffer}
    &subject={&subject}
    &out-title="{&out-title}"
    &out-title-add="{&out-title-add}"
    &out-title-del="{&out-title-del}"
    }
  end.
&endif
&if "{&cdt-pricecheck-Servispl}" = "yes" &then
  when  {&cd-type-pricecheck-Servispl} then do:
    { str/cdg-prck.i
    &cd-buffer={&cd-buffer}
    &subject={&subject}
    &out-title={&out-title}
    &out-title-add="{&out-title-add}"
    }
  end.
&endif

&if "{&cdt-NCR-GM}" = "yes" &then
  when {&cd-type-NCR-GM}
  then do:
    { str/cds-ncr.i
    &cd-buffer={&cd-buffer}
    &subject={&subject}
    &out-title="{&out-title}"
    &out-title-add="{&out-title-add}"
    &out-title-del="{&out-title-del}"
    }
  end.
&endif
&if "{&cdt-NCR-AS-R}" = "yes" &then
  when {&cd-type-NCR-AS-R}
  then do:
    { str/cds-ncr.i
    &cd-buffer={&cd-buffer}
    &subject={&subject}
    &out-title="{&out-title}"
    &out-title-add="{&out-title-add}"
    &out-title-del="{&out-title-del}"
    }
  end.
&endif
&if "{&cdt-r-keeper}" = "yes" &then
&endif
&if "{&cdt-maria}" = "yes" &then
&endif
&if "{&cdt-autotank}" = "yes" &then
&endif

END CASE.

/* $Workfile$ e n d */