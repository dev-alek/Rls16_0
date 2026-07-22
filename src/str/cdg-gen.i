/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

получение путей из INi и т.д. для различных видов касс -

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/23/03
Author: Bakhtadze Natalya
Creation date: 06/23/03

Для различных subject

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable dflt-cd{&vssseq} as character no-undo .
{ gbl/dflt-cd.i ~{&shop~} {&cd-buffer}.obj-code dflt-cd{&vssseq} no-error }

case {&cd-buffer}.pos-type:
&if "{&cdt-IBM-XML}" = "yes"  or "{&cdt-MAGIA-XML}" = "yes" or "{&cdt-infokiosk}" = "yes" or "{&cdt-autotank}" = "yes"  &then
  &if "{&cdt-IBM-XML}" = "yes"  &then
    when {&cd-type-IBM-XML} or when {&cd-type-autotank}
  &endif
  &if "{&cdt-MAGIA-XML}" = "yes" &then
    &if "{&cdt-IBM-XML}" = "yes" &then
      or
    &endif
    when {&cd-type-MAGIA-XML}
  &endif
  &if "{&cdt-infokiosk}" = "yes" &then
    &if "{&cdt-IBM-XML}" = "yes" or "{&cdt-MAGIA-XML}" = "yes"   &then
      or
    &endif
    when {&cd-type-infokiosk}
    /*tit unfokiosk*/
  &endif
  &if "{&cdt-autotank}" = "yes" &then
    &if "{&cdt-IBM-XML}" = "yes" or "{&cdt-magia-xml}" = "yes"   &then
      or
    &endif
    when {&cd-type-autotank}
    /*tit unfokiosk*/
  &endif
  then do:
    { str/cdg-xml.i
    &cd-buffer={&cd-buffer}
    &subject={&subject}
    &out-title={&out-title}
    }
  end.
&endif
&if "{&cdt-IBM}" = "yes" &then
  when {&cd-type-IBM}
&if "{&cdt-NKT-IBM}" = "yes" &then
  or
  when {&cd-type-nkt-IBM}
&endif
  then do:
    { str/cdg-ibm.i
    &cd-buffer={&cd-buffer}
    &subject={&subject}
    }
  end.
&endif
&if "{&cdt-OMRON}" = "yes" &then
  when {&cd-type-omron} then do:
    { str/cdg-omr.i
    &cd-buffer={&cd-buffer}
    &subject={&subject}
    }
  end.
&endif
&if "{&cdt-OMRON-NEW}" = "yes" &then
  when {&cd-type-omron-new} then do:
    { str/cdg-omrn.i
    &cd-buffer={&cd-buffer}
    &subject={&subject}
    }
  end.
&endif
&if "{&cdt-IPC-SERVISPL}" = "yes" &then
  when {&cd-type-ipc-servispl} then do:
    { str/cdg-ipcs.i
    &cd-buffer={&cd-buffer}
    &subject={&subject}
    }
  end.
&endif
&if "{&cdt-pricecheck-Servispl}" = "yes" &then
  when  {&cd-type-pricecheck-Servispl} then do:
    { str/cdg-prck.i
    &cd-buffer={&cd-buffer}
    &subject={&subject}
    &out-title={&out-title}
    }
  end.
&endif
&if "{&cdt-NCR-GM}" = "yes" &then
  when {&cd-type-NCR-GM} then do:
    { str/cdg-ncr.i
    &cd-buffer={&cd-buffer}
    &subject={&subject}
    }
  end.
&endif
&if "{&cdt-NCR-AS-R}" = "yes" &then
  when {&cd-type-NCR-AS-R} then do:
    { str/cdg-ncr.i
    &cd-buffer={&cd-buffer}
    &subject={&subject}
    }
  end.
&endif
&if "{&cdt-r-keeper}" = "yes" &then
  when {&cd-type-r-keeper} then do:
    { str/cdg-rkp.i
    &cd-buffer={&cd-buffer}
    &subject={&subject}
    }
  end.
&endif
&if "{&cdt-maria}" = "yes" &then
  when {&cd-type-maria} then do:
    { str/cdg-mar.i
    &cd-buffer={&cd-buffer}
    &subject={&subject}
    }
  end.
&endif


END CASE.

/* $Workfile$ e n d */