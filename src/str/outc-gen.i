/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

открытие потока и сопутствующие операции для различных видов касс -

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/23/03
Author: Bakhtadze Natalya
Creation date: 06/23/03


Для различных subject

*/

/*  вставляется в цикл по кассам */

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

case {&cd-buffer}.pos-type:
&if "{&cdt-IBM-XML}" = "yes" or "{&cdt-infokiosk}" = "yes"  or "{&cdt-autotank}" = "yes" &then
  &if "{&cdt-IBM-XML}" = "yes" &then
    when {&cd-type-IBM-XML} or when {&cd-type-autotank} 
  &endif
  &if  "{&cdt-infokiosk}" = "yes" &then
    &if "{&cdt-IBM-XML}" = "yes"  &then
      or
    &endif
    when {&cd-type-infokiosk}
  &endif
  &if  "{&cdt-autotank}" = "yes" &then
    &if "{&cdt-IBM-XML}" = "yes"  &then
      or
    &endif
    when {&cd-type-autotank}
  &endif
  then do:
    { str/outc-xml.i
    &cd-buffer={&cd-buffer}
    &subject={&subject}
    &out-title="{&out-title}"
    &data-by="{&data-by}"
    }
  end.
&endif
&if "{&cdt-MAGIA-XML}" = "yes" &then
  when {&cd-type-MAGIA-XML} then do:
    { str/outc-xml.i
    &cd-buffer={&cd-buffer}
    &subject={&subject}
    &out-title="{&out-title}"
    &data-by="{&data-by}"
    }
  end.
&endif
&if "{&cdt-IBM}" = "yes" &then
  when {&cd-type-IBM}
&if "{&cdt-NKT-IBM}" = "yes" &then
  or
  when {&cd-type-NKT-IBM}
&endif
  then do:
    { str/outc-ibm.i
    &cd-buffer={&cd-buffer}
    &subject={&subject}
    &out-title="{&out-title}"
    }
  end.
&endif
&if "{&cdt-OMRON}" = "yes" &then
  when {&cd-type-omron} then do:
    { str/outc-omr.i
    &cd-buffer={&cd-buffer}
    &subject={&subject}
    &out-title="{&out-title}"
    }
  end.
&endif
&if "{&cdt-OMRON-NEW}" = "yes" &then
  when {&cd-type-omron-new} then do:
    { str/outcomrn.i
    &cd-buffer={&cd-buffer}
    &subject={&subject}
    &out-title="{&out-title}"
    }
  end.
&endif
&if "{&cdt-IPC-SERVISPL}" = "yes" &then
  when {&cd-type-ipc-servispl} then do:
    { str/outcipcs.i
    &cd-buffer={&cd-buffer}
    &subject={&subject}
    &out-title="{&out-title}"
    }
  end.
&endif
&if "{&cdt-pricecheck-Servispl}" = "yes" &then
  when {&cd-type-pricecheck-Servispl} then do:
    { str/out-prck.i
    &cd-buffer={&cd-buffer}
    &subject={&subject}
    &out-title="{&out-title}"
    }
  end.
&endif
&if "{&cdt-NCR-GM}" = "yes" &then
  when {&cd-type-NCR-GM} then do:
    { str/outc-ncr.i
    &cd-buffer={&cd-buffer}
    &subject={&subject}
    &out-title="{&out-title}"
    }
  end.
&endif
&if "{&cdt-NCR-AS-R}" = "yes" &then
  when {&cd-type-NCR-AS-R} then do:
    { str/outc-ncr.i
    &cd-buffer={&cd-buffer}
    &subject={&subject}
    &out-title="{&out-title}"
    }
  end.
&endif
&if "{&cdt-r-keeper}" = "yes" &then
  when {&cd-type-r-keeper} then do:
    { str/outc-rkp.i
    &cd-buffer={&cd-buffer}
    &subject={&subject}
    &out-title="{&out-title}"
    }
  end.
&endif
&if "{&cdt-maria}" = "yes" &then
  when {&cd-type-maria} then do:
    { str/outc-mar.i
    &cd-buffer={&cd-buffer}
    &subject={&subject}
    &out-title="{&out-title}"
    }
  end.
&endif
END CASE.

/* $Workfile$ e n d */