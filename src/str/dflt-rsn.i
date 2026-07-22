/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Коды оснований (причин) создания документа по умолчанию по фирме или по объекту: считывание, обработка, запись

Автор: Чернова Светлана Александровна
Дата создания: 11/30/06
Author: Svetlana Chernova
Creation date: 11/30/06

create: Булгаков Андрей Николаевич

*/



&scop buffer ub.trn-reason-{1}
&scop field  rsn-{&bef-{3}}{4}
&scop button b-{&bef-{3}}{4}

&if     "{2}" = "read"    &then
  find first {&buffer} no-lock where
  &if     "{1}" = "host" &then
             {&buffer}.host-code    = p-host-code and
  &elseif "{1}" = "obj"  &then
             {&buffer}.obj-type     = p-obj-type  and
             {&buffer}.obj-code     = p-obj-code  and
  &endif
             {&buffer}.ext-doc-type = {&{3}}      and
  &if "{4}" = "h" &then
             {&buffer}.hold-doc     = yes
  &else
           ( {&buffer}.hold-doc     = no          or
             {&buffer}.hold-doc     = ? )
  &endif
             no-error.
  assign {&field} = ( if available {&buffer} then {&buffer}.reason-code else ? ).
&elseif "{2}" = "write"   &then
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = {&field} no-error.
    find first {&buffer} exclusive-lock where
    &if     "{1}" = "host" &then
               {&buffer}.host-code    = p-host-code and
    &elseif "{1}" = "obj"  &then
               {&buffer}.obj-type     = p-obj-type  and
               {&buffer}.obj-code     = p-obj-code  and
    &endif
               {&buffer}.ext-doc-type = {&{3}}      and
    &if "{4}" = "h" &then
               {&buffer}.hold-doc     = yes
    &else
             ( {&buffer}.hold-doc     = no          or
               {&buffer}.hold-doc     = ? )
    &endif
               no-error.
  if available ub.trn-reason then do:
    if available {&buffer} then do:
      assign ref-rec = recid( {&buffer} ).
      find first {&buffer} exclusive-lock where
          recid( {&buffer} ) = ref-rec.
    end. /* if available {&buffer} */
    else do: /* if not available {&buffer} */
      create {&buffer}.
      assign
        &if     "{1}" = "host" &then
             {&buffer}.host-code    = p-host-code
        &elseif "{1}" = "obj"  &then
             {&buffer}.obj-type     = p-obj-type
             {&buffer}.obj-code     = p-obj-code
        &endif
             {&buffer}.ext-doc-type = {&{3}}
        &if "{4}" = "h" &then
             {&buffer}.hold-doc     = yes
        &else
             {&buffer}.hold-doc     = no
        &endif
      .
    end. /* if not available {&buffer} */
    assign {&buffer}.reason-code = {&field}.
  end. /* if available ub.trn-reason */
  else do:
    if available {&buffer}
     and {&field} = ? then do:
       delete {&buffer} .
     end.
  end.
&elseif "{2}" = "trigger" &then
  on choose of {&button} in frame {&FRAME-NAME} do:
    assign j_rsn-code = ( input frame {&FRAME-NAME} {&field} ).
    run str/trn-reas.w ( input parparentproc
                       , input {&choose}
                       , input-output j_rsn-code
                       ) .
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = j_rsn-code no-error.
    if available ub.trn-reason then do:
      assign  {&field} = j_rsn-code.
      display {&field} with frame {&FRAME-NAME}.
    end.
  end.

  on return of {&field} in frame {&FRAME-NAME} do:
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = ( input frame {&FRAME-NAME} {&field} ) no-error.
    if available ub.trn-reason then do: assign {&field}. end.
    run Apply-Next in this-procedure ( input "{&bef-{3}}{4}" ).
    return no-apply.
  end.
&elseif "{2}" = "proc"    &then
  procedure Apply-Next :
    define input parameter p-name as character no-undo.

    case p-name :
      when      {&TDEDT_Pri_Vnesh}          then do: apply "ENTRY":U  to rsn-{&bef-TDEDT_Ras_Vnesh}          in frame {&FRAME-NAME}. end.
      when      {&TDEDT_Ras_Vnesh}          then do: apply "ENTRY":U  to rsn-{&bef-TDEDT_Ras_Vnesh_VP}       in frame {&FRAME-NAME}. end.
      when      {&TDEDT_Ras_Vnesh_VP}       then do: apply "ENTRY":U  to rsn-{&bef-TDEDT_Ras_Vnesh_Kass}     in frame {&FRAME-NAME}. end.
      when      {&TDEDT_Ras_Vnesh_Kass}     then do: apply "ENTRY":U  to rsn-{&bef-TDEDT_Vozvrat_Vnesh}      in frame {&FRAME-NAME}. end.
      when      {&TDEDT_Vozvrat_Vnesh}      then do: apply "ENTRY":U  to rsn-{&bef-TDEDT_Vozvrat_Vnesh_Kass} in frame {&FRAME-NAME}. end.
      when      {&TDEDT_Vozvrat_Vnesh_Kass} then do: apply "ENTRY":U  to rsn-{&bef-TDEDT_Spi_Vnesh}          in frame {&FRAME-NAME}. end.
      when      {&TDEDT_Spi_Vnesh}          then do: apply "ENTRY":U  to rsn-{&bef-TDEDT_Inv}                in frame {&FRAME-NAME}. end.
      when      {&TDEDT_Inv}                then do: apply "ENTRY":U  to rsn-{&bef-TDEDT_Peresort}           in frame {&FRAME-NAME}. end.
      when      {&TDEDT_Peresort}           then do: apply "ENTRY":U  to rsn-{&bef-TDEDT_Pri_Perem}          in frame {&FRAME-NAME}. end.
      when      {&TDEDT_Pri_Perem}          then do: apply "ENTRY":U  to rsn-{&bef-TDEDT_Ras_Perem}          in frame {&FRAME-NAME}. end.
      when      {&TDEDT_Ras_Perem}          then do: apply "ENTRY":U  to rsn-{&bef-TDEDT_Vozvrat_Perem}      in frame {&FRAME-NAME}. end.
      when      {&TDEDT_Vozvrat_Perem}      then do: apply "ENTRY":U  to rsn-{&bef-TDEDT_Ras_Prvo}           in frame {&FRAME-NAME}. end.
      when      {&TDEDT_Ras_Prvo}           then do: apply "ENTRY":U  to rsn-{&bef-TDEDT_Spi_Prvo}           in frame {&FRAME-NAME}. end.
      when      {&TDEDT_Spi_Prvo}           then do: apply "ENTRY":U  to rsn-{&bef-TDEDT_Pri_Prvo}           in frame {&FRAME-NAME}. end.
      when      {&TDEDT_Pri_Prvo}           then do: apply "ENTRY":U  to rsn-{&bef-TDEDT_Corr_Acc_Price}           in frame {&FRAME-NAME}. end.
      when      {&TDEDT_Corr_Acc_Price}     then do: apply "ENTRY":U  to rsn-{&bef-TDEDT_Chg_Purch_Code}     in frame {&FRAME-NAME}. end.
      when      {&TDEDT_Chg_Purch_Code}     then do: apply "ENTRY":U  to rsn-{&bef-TDEDT_Corr_Minus_Parts}   in frame {&FRAME-NAME}. end.
      when      {&TDEDT_Corr_Minus_Parts}   then do: apply "ENTRY":U  to rsn-{&bef-TDEDT_Pri_Vnesh}h         in frame {&FRAME-NAME}. end.
      when '{&bef-TDEDT_Pri_Vnesh}h':U      then do: apply "ENTRY":U  to rsn-{&bef-TDEDT_Ras_Vnesh}h         in frame {&FRAME-NAME}. end.
      when '{&bef-TDEDT_Ras_Vnesh}h':U      then do: apply "ENTRY":U  to rsn-{&bef-TDEDT_Ras_Vnesh_VP}h      in frame {&FRAME-NAME}. end.
      when '{&bef-TDEDT_Ras_Vnesh_VP}h':U   then do: apply "ENTRY":U  to rsn-{&bef-TDEDT_Vozvrat_Vnesh}h     in frame {&FRAME-NAME}. end.
      when '{&bef-TDEDT_Vozvrat_Vnesh}h':U  then do: apply "CHOOSE":U to b-OK                              in frame {&FRAME-NAME}. end.
    end case. /* p-name */
  end procedure. /* Apply-Next */
&endif

/* $Workfile$   E n d */