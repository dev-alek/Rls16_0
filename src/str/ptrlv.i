/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Верификации, необходимые для верификаций конфигурации АЗС

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/15/07
Author: Dmitry Ukhanov
Creation date: 08/15/07

Автор1: Суслов Алексей Юрьевич
Дата создания1: 03/27/06

*/
&IF "{1}" <> "def"        AND
    "{1}" <> "undef"      AND
    "{1}" <> "ov+"        AND
    "{1}" <> "ppv+"       AND
    "{1}" <> "plv+"       AND
    "{1}" <> "nv+"        AND
    "{1}" <> "sch-cls"    AND
    "{1}" <> "plppv+"     AND
    "{1}" <> "ppnv+"      AND
    "{1}" <> "lps"        AND
    "{1}" <> "cadd"       AND
    "{1}" <> "refpump"    AND
    "{1}" <> "refnozzle"  AND
    "{1}" <> "rc"         AND
    "{1}" <> "rvs-doc-"   AND
    "{1}" <> "icnt-doc-"
    &THEN
    &MESSAGE "Неверный параметр " {1} " при передаче в файл ptrlv.i "
&ELSEIF "{1}" = "def" &THEN
&glob str-obj + SUBSTITUTE(" на объекте &1 &2 .", parobj-type, parobj-code)
define variable varmes-log as logical no-undo.

&if defined (defined_parparentproc) = 0 &then
&GLOBal-define defined_parparentproc
define variable parparentproc as widget-handle no-undo .
&endif

define variable varobj-type like ub.clients.obj-type no-undo.
define variable varobj-code like ub.clients.obj-code no-undo.
define variable varbuttons  as   character        no-undo.
define variable varps-upd   as   logical          no-undo.
&ELSEIF "{1}" = "ov+" &THEN
/*Проверяем объект на правильность*/
find first bf_clients where bf_clients.obj-type = parobj-type and
                            bf_clients.obj-code = parobj-code no-lock no-error.
if not available bf_clients then
   return error SUBSTITUTE("Нет такого объекта &1 &2 .", parobj-type, parobj-code).
&ELSEIF "{1}" = "plv+" &THEN
/*Проверяем то, что есть резервуар в журнале складских мест*/
find first bf_place where bf_place.obj-type = parobj-type and
                          bf_place.obj-code = parobj-code and
                          bf_place.pl-code  = parpl-code  no-lock no-error.
if not available bf_place then return error SUBSTITUTE("Нет такого складского места &1", parpl-code) {&str-obj}.
&ELSEIF "{1}" = "ppv+" &THEN
/*Проверяем, то что есть ТРК в журнале ТРК*/
find first bf_pump where bf_pump.obj-type  = parobj-type  and
                         bf_pump.obj-code  = parobj-code  and
                         bf_pump.pump-code = parpump-code no-lock no-error.
if not available bf_pump then
   return error SUBSTITUTE("Нет ТРК с номером &1", parpump-code) {&str-obj}.
&ELSEIF "{1}" = "nv+" &THEN
/*Проверяем то, что есть пистолет в журнале пистолетов ТРК*/
find first bf_nozzle where bf_nozzle.obj-type    = parobj-type    and
                           bf_nozzle.obj-code    = parobj-code    and
                           bf_nozzle.nozzle-code = parnozzle-code no-lock no-error.
if not available bf_nozzle then
   return error SUBSTITUTE("Нет пистолета ТРК с номером &1", parnozzle-code) {&str-obj}.
&ELSEIF "{1}" = "plppv+" &THEN
find first bf_pl-pump where bf_pl-pump.obj-type  = parobj-type  and
                            bf_pl-pump.obj-code  = parobj-code  and
                            bf_pl-pump.pl-code   = parpl-code   and
                            bf_pl-pump.pump-code = parpump-code no-lock no-error.
if not available bf_pl-pump then
   return error SUBSTITUTE("Нет записи резервуар-ТРК с номером резервуара &1 и номером ТРК &2",
                           parpl-code, parpump-code) {&str-obj}.

&ELSEIF "{1}" = "ppnv+"  &THEN
find first bf_pump-nozzle where bf_pump-nozzle.obj-type    = parobj-type    and
                                bf_pump-nozzle.obj-code    = parobj-code    and
                                bf_pump-nozzle.pump-code   = parpump-code   and
                                bf_pump-nozzle.nozzle-code = parnozzle-code no-lock no-error.
if not available bf_pump-nozzle then
   return error SUBSTITUTE("Нет записи ТРК-пистолет с номером ТРК &1 и номером пистолета &2",
                                                        parpump-code,
                                                        parnozzle-code) {&str-obj}.

&ELSEIF "{1}" = "sch-cls" &THEN
/*Проверяем, что смена закрыта или есть закрытый документ сверки типа "смена"*/

run chkcsptr (input parobj-type,
              input parobj-code) no-error.
if error-status:error then return error trim(return-value) +
                                        trim(error-status:get-message(1)) +
                                        trim(error-status:get-message(2)) +
                                        trim(error-status:get-message(3)) +
                                        trim(error-status:get-message(4)) +
                                        trim(error-status:get-message(5)).

&ELSEIF "{1}" = "refpump" &THEN
  define variable varrec-id_pump as recid initial ? no-undo.
  define buffer bf_pump for ub.pump.
  run str/pumprf.w
    ( input parparentproc
     ,input  parobj-type
     ,input  parobj-code
     ,output varrec-id_pump
    ).
  if varrec-id_pump <> ? then do:
     find first bf_pump where recid(bf_pump) = varrec-id_pump no-lock no-error.
     if available bf_pump then do:
        display bf_pump.pump-code @ varpump-code with frame {&frame-name}.
     end.
  end.
&ELSEIF "{1}" = "refnozzle" &THEN
  define variable varrec-id_nozzle as recid initial ? no-undo.
  define buffer bf_nozzle for ub.nozzle.
  run str/nozzlerf.w
    ( input  parparentproc
     ,input  parobj-type
     ,input  parobj-code
     ,output varrec-id_nozzle
    ).
  if varrec-id_nozzle <> ? then do:
     find first bf_nozzle where recid(bf_nozzle) = varrec-id_nozzle no-lock no-error.
     if available bf_nozzle then do:
        display bf_nozzle.nozzle-code @ varnozzle-code with frame {&frame-name}.
     end.
  end.
&ELSEIF "{1}" = "lps" &THEN
  define buffer bf_{2} for ub.{2}.
  if available ub.{2} then do:
    if ub.{2}.ps <> input frame {4} varps then do:
      if varps-upd = no then do:
          message
            "Вы не можете изменять примечание!"
            view-as alert-box.
          display
            ub.{2}.ps @ varps
            with frame {&frame-name}
          .
      end.
      else do:
        assign
          varmes-log = yes
        .
        message
          "Вы хотите изменить примечание к " "{3}"
          view-as alert-box question buttons yes-no update varmes-log.
        if varmes-log = true then do:
          do transaction
          on error  undo, retry
          on stop   undo, retry
          on endkey undo, retry
          :
            if retry then do:
              message
                vss-workfile vss-revision vss-description skip(1)
                "Ошибка при сохранении PS!!!" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              return no-apply.
            end.

            find first bf_{2} exclusive-lock
              where recid(bf_{2}) = recid(ub.{2})
            .
            assign
              frame {4} varps
            .
            assign
              bf_{2}.ps = varps
            .
          end.
        end.
        else do:
          assign
            varps = ub.{2}.ps
          .
          display
            varps
            with frame {4}
          .
        end.
      end.
    end.
  end.
&ELSEIF "{1}" = "cadd" &THEN
define variable varrec-id as recid no-undo.
  CASE "{2}"
  :
   WHEN "nozzle" THEN DO:
     run str/d-nozzle.w (input  varobj-type,
                     input  varobj-code,
                     output varrec-id) no-error.
   END.
   WHEN "plpmnz" THEN DO:
     run str/d-plpmnz.w
      ( input parparentproc
       ,input varobj-type
       ,input varobj-code
       ,output varrec-id
      ) no-error.
   END.
   WHEN "plpump" THEN DO:
     run str/d-plpump.w
      ( input parparentproc
       ,input varobj-type
       ,input varobj-code
       ,output varrec-id
      ) no-error.
   END.
   WHEN "pump" THEN DO:
     run str/d-pump.w
      ( input parparentproc
       ,input varobj-type
       ,input  varobj-code
       ,output varrec-id
      ) no-error.
   END.
   WHEN "pumpnz" THEN DO:
     run str/d-pumpnz.w
      ( input parparentproc
       ,input varobj-type
       ,input varobj-code
       ,output varrec-id
      ) no-error.
   END.
   OTHERWISE DO:
     { str/errmes.i "Неверное имя файла d-{2}.w."}
     return no-apply.
   END.
  END CASE.
  if error-status:error then do:
     { str/errmes.i "Ошибка при вызове файла d-{2}.w."}
     return no-apply.
  end.

  if varrec-id <> ? then do:
     RUN dispatch IN THIS-PROCEDURE ('open-query':U).
     REPOSITION {3} to recid varrec-id.
  end.

&ELSEIF "{1}" = "rc" &THEN
&scop is-error-get  if return-value = "" or return-value = ? or return-value = "?" then do: ~
                       message "Нет атрибута: " + "~{&prep-attr}" + " для получения данных." view-as alert-box error. return error.~
                    end.
RUN request-attribute IN adm-broker-hdl
    (INPUT THIS-PROCEDURE,               /* Object handle */
     INPUT 'Container-Source':U,         /* SmartLink     */
     INPUT 'parparentproc':U) NO-ERROR.   /* Attribute     */
&scop prep-attr parparentproc
{&is-error-get}
assign parparentproc = widget-handle(return-value).
RUN request-attribute IN adm-broker-hdl
    (INPUT THIS-PROCEDURE,               /* Object handle */
     INPUT 'Container-Source':U,         /* SmartLink     */
     INPUT 'obj-type':U) NO-ERROR.   /* Attribute     */
&scop prep-attr obj-type
{&is-error-get}
assign varobj-type = return-value.
RUN request-attribute IN adm-broker-hdl
    (INPUT THIS-PROCEDURE,               /* Object handle */
     INPUT 'Container-Source':U,         /* SmartLink     */
     INPUT 'obj-code':U) NO-ERROR.   /* Attribute     */
&scop prep-attr obj-code
{&is-error-get}
assign varobj-code = integer(return-value).
RUN request-attribute IN adm-broker-hdl
    (INPUT THIS-PROCEDURE,               /* Object handle */
     INPUT 'Container-Source':U,         /* SmartLink     */
     INPUT 'buttons':U) NO-ERROR.   /* Attribute     */
&scop prep-attr buttons
{&is-error-get}
assign varbuttons = return-value.
assign varbuttons = replace (varbuttons, "|", ",").
if lookup('b-add', varbuttons) = 0 then do:
  assign
    b-add:sensitive in frame {2} = no
    b-add:visible   in frame {2} = no
    varps:read-only in frame {2} = yes
    varps-upd                    = no
  .
end.
else do:
  assign
    varps-upd = yes
  .
end.
if lookup('b-del', varbuttons) = 0 then
   assign b-del:sensitive in frame {2} = no
          b-del:visible   in frame {2} = no.

&ENDIF
&IF "{1}" = "rvs-doc-" &THEN
 find first bf_rvs-doc where bf_rvs-doc.obj-type =  parobj-type       and
                             bf_rvs-doc.obj-code =  parobj-code       and
                             bf_rvs-doc.status_  <> {&fact}           and
                             bf_rvs-doc.rvs-type <> {&rvs-before-doc} and
                             bf_rvs-doc.rvs-type <> {&rvs-after-doc}  and
                             bf_rvs-doc.rvs-type <> {&test-asi}       no-lock no-error.
if available bf_rvs-doc then do:
   return error SUBSTITUTE("На объекте есть открытый документ сверки &1 .", bf_rvs-doc.rvs-code).
end.
&ELSEIF "{1}" = "icnt-doc-" &THEN
find first bf_icnt-doc where bf_icnt-doc.obj-type  =  parobj-type and
                             bf_icnt-doc.obj-code  =  parobj-code and
                             bf_icnt-doc.status_   <> {&fact}     no-lock no-error.
if available bf_icnt-doc then do:
   return error SUBSTITUTE("На объекте есть открытый документ инвентаризации счетчиков ТРК &1 .", bf_icnt-doc.doc-code).
end.
&ELSEIF "{1}" = "undef" &THEN
&undef str-obj
&ENDIF
/* $Workfile$ e n d */