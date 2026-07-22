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

/*  {1} - предполагается cash-desk*/
/*  вставляется в цикл по кассам */

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

case {&cd-buffer}.pos-type:
&if "{&cdt-IBM-XML}" = "yes" or "{&cdt-infokiosk}" = "yes"  or "{&cdt-autotank}" = "yes"  &then
  &if "{&cdt-IBM-XML}" = "yes"  &then
    when {&cd-type-IBM-XML} or when {&cd-type-autotank}
  &endif
  &if "{&cdt-infokiosk}" = "yes"  &then
    &if "{&cdt-IBM-XML}" = "yes"  &then
      or
    &Endif
     when {&cd-type-infokiosk}
  &endif
  &if "{&cdt-autotank}" = "yes"  &then
    &if "{&cdt-IBM-XML}" = "yes"  &then
      or
    &Endif
     when {&cd-type-autotank}
  &endif
  then do:
    { str/cloc-xml.i
    &cd-buffer={&cd-buffer}
    &subject={&subject}
    &out-title-add="{&out-title-add}"
    &out-title-del="{&out-title-del}"
    }
  end.
&endif
&if "{&cdt-MAGIA-XML}" = "yes" &then
  when {&cd-type-MAGIA-XML} then do:
    { str/cloc-xml.i
    &cd-buffer={&cd-buffer}
    &subject={&subject}
    &out-title-add="{&out-title-add}"
    &out-title-del="{&out-title-del}"
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
    { str/cloc-ibm.i
    &cd-buffer={&cd-buffer}
    &subject={&subject}
    &out-title-add="{&out-title-add}"
    &out-title-del="{&out-title-del}"
    }
  end.
&endif
&if "{&cdt-OMRON}" = "yes" &then
  when {&cd-type-omron} then do:
    { str/cloc-omr.i
    &cd-buffer={&cd-buffer}
    &subject={&subject}
    &out-title-add="{&out-title-add}"
    &out-title-del="{&out-title-del}"
    }
  end.
&endif
&if "{&cdt-OMRON-NEW}" = "yes" &then
  when {&cd-type-omron-new} then do:
    { str/clocomrn.i
    &cd-buffer={&cd-buffer}
    &subject={&subject}
    &out-title-add="{&out-title-add}"
    &out-title-del="{&out-title-del}"
    }
  end.
&endif
&if "{&cdt-IPC-SERVISPL}" = "yes" &then
  when {&cd-type-ipc-servispl} then do:
    { str/clocipcs.i
    &cd-buffer={&cd-buffer}
    &subject={&subject}
    &out-title-add="{&out-title-add}"
    &out-title-del="{&out-title-del}"
    }
  end.
&endif
&if "{&cdt-pricecheck-Servispl}" = "yes" &then
  when {&cd-type-pricecheck-Servispl}
  then do:
      output stream plucash close.
      output stream bar close.
      run str/clo-prcp.p
      ( input out ,
        input var-report-num ) no-error .
  if error-status :error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input return-value ).

  end.
  end.
&endif

&if "{&cdt-NCR-GM}" = "yes" &then
  when {&cd-type-NCR-GM}
  then do:
    { str/cloc-ncr.i
    &cd-buffer={&cd-buffer}
    &subject={&subject}
    &out-title-add="{&out-title-add}"
    &out-title-del="{&out-title-del}"
    }
  end.
&endif
&if "{&cdt-NCR-AS-R}" = "yes" &then
  when {&cd-type-NCR-AS-R}
  then do:
    { str/cloc-nca.i
    &cd-buffer={&cd-buffer}
    &subject={&subject}
    &out-title-add="{&out-title-add}"
    &out-title-del="{&out-title-del}"
    }
  end.
&endif
&if "{&cdt-r-keeper}" = "yes" &then
  when {&cd-type-r-keeper} then do:
    { str/cloc-rkp.i
    &cd-buffer={&cd-buffer}
    &subject={&subject}
    &out-title-add="{&out-title-add}"
    &out-title-del="{&out-title-del}"
    }
  end.
&endif
&if "{&cdt-maria}" = "yes" &then
  when {&cd-type-maria} then do:
    { str/cloc-mar.i
    &cd-buffer={&cd-buffer}
    &subject={&subject}
    &out-title-add="{&out-title-add}"
    &out-title-del="{&out-title-del}"
    }
  &if "{&subject}" = "good" or "{&subject}" = "dis-card" &then
    if
&if "{&subject}" = "good" &then v-del-mrkt-gds &else v-del-mrkt-cli &endif
    then do:
      { str/clocmar2.i
      &cd-buffer={&cd-buffer}
      &subject={&subject}
      &out-title-add="{&out-title-add}"
      &out-title-del="{&out-title-del}"
      }
    end.
  &endif
  end.
&endif



END CASE.

/* $Workfile$ e n d */