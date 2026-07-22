/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ссылка на библиотеку для работы с атрибутами документа МЦ

Автор: Гридчина Полина Дмитриевна
Дата создания: 04/10/08
Author: Polina Gridchina
Creation date: 04/10/08

Input:

Output:

*/


&if defined( include_wthcalib ) = 0 &then

/* Дата счета-фактуры поставщика */
&glob fillin_width-wthcattr-dsf 11
&glob fillin_height-wthcattr-dsf 1
&glob type-wthcattr-dsf {&type-date}
&glob format-wthcattr-dsf "99/99/9999"
&glob label-wthcattr-dsf "Дата счета-фактуры"
&glob tooltip-wthcattr-dsf "Дата счета-фактуры"
&glob user-can-edit-wthcattr-dsf true
&glob output-display-wthcattr-dsf true
&glob other-wthcattr-dsf 'nws':u
&glob news-wthcattr-dsf true

/* Номер счета-фактуры поставщика */
&glob fillin_width-wthcattr-nsf 71
&glob fillin_height-wthcattr-nsf 1
&glob type-wthcattr-nsf {&type-char}
&glob format-wthcattr-nsf "x(70)"
&glob label-wthcattr-nsf "Номер счета-фактуры"
&glob tooltip-wthcattr-nsf "Номер счета-фактуры"
&glob user-can-edit-wthcattr-nsf true
&glob output-display-wthcattr-nsf true
&glob other-wthcattr-nsf 'nws':u
&glob news-wthcattr-nsf true

/* Платежно расчетный документ */
&glob fillin_width-wthcattr-paydoc 71
&glob fillin_height-wthcattr-paydoc 1
&glob type-wthcattr-paydoc {&type-char}
&glob format-wthcattr-paydoc "x(70)"
&glob label-wthcattr-paydoc "Платежно-расчетный документ "
&glob tooltip-wthcattr-paydoc "Платежно-расчетный документ "
&glob user-can-edit-wthcattr-paydoc true
&glob output-display-wthcattr-paydoc true
&glob other-wthcattr-paydoc 'nws':u
&glob news-wthcattr-paydoc true
/*Доверенность*/
&glob fillin_width-wthcattr-proxy 71
&glob fillin_height-wthcattr-proxy 1
&glob type-wthcattr-proxy {&type-char}
&glob format-wthcattr-proxy "x(70)"
&glob label-wthcattr-proxy "Доверенность"
&glob tooltip-wthcattr-proxy "Доверенность"
&glob user-can-edit-wthcattr-proxy true
&glob output-display-wthcattr-proxy true
&glob other-wthcattr-proxy 'nws':u
&glob news-wthcattr-proxy true
/* Получил */
&glob fillin_width-wthcattr-receiver 71
&glob fillin_height-wthcattr-receiver 1
&glob type-wthcattr-receiver {&type-char}
&glob format-wthcattr-receiver "x(70)"
&glob label-wthcattr-receiver "Мат. ответственное лицо контрагента"
&glob tooltip-wthcattr-receiver "Материально ответственное лицо контрагента"
&glob user-can-edit-wthcattr-receiver true
&glob output-display-wthcattr-receiver true
&glob other-wthcattr-receiver 'nws':u
&glob news-wthcattr-receiver true

/* Основание */
&glob fillin_width-wthcattr-reason 71
&glob fillin_height-wthcattr-reason 1
&glob type-wthcattr-reason {&type-char}
&glob format-wthcattr-reason "x(70)"
&glob label-wthcattr-reason "Основание"
&glob tooltip-wthcattr-reason "Основание"
&glob user-can-edit-wthcattr-reason true
&glob output-display-wthcattr-reason true
&glob other-wthcattr-reason 'nws':u
&glob news-wthcattr-reason true

/* Грузополучатель */
&glob fillin_width-wthcattr-consignee 71
&glob fillin_height-wthcattr-consignee 1
&glob type-wthcattr-consignee {&type-char}
&glob format-wthcattr-consignee "x(70)"
&glob label-wthcattr-consignee "Грузополучатель"
&glob tooltip-wthcattr-consignee "Грузополучатель"
&glob user-can-edit-wthcattr-consignee true
&glob output-display-wthcattr-consignee true
&glob other-wthcattr-consignee 'nws/spr=wthcattr-sprcli':u
&glob news-wthcattr-consignee true

/*Вызов справочника клиентов*/
procedure wthcattr-sprcli :
define input parameter parparentproc  as widget-handle no-undo.
define input parameter p-mode  as character no-undo.
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .

  DEFINE VARIABLE v-value as character no-undo .
  define variable v-cli-type as character no-undo .
  define variable v-cli-code as integer no-undo .
  define buffer buf_clients   for ub.clients.
  define variable v_rid as character no-undo.
  define variable ref-rec as recid no-undo .
  do
  on error undo, return error
  :
      v-value = p-value.
   if p-value <> '':U then do:
    assign
    v-cli-type = substring(p-value, 1, 3)
    v-cli-code = integer(substring(p-value, 4))
    no-error.
    if error-status:error then do:
      assign
      v-cli-type = '':U
      v-cli-code = 0
      .
    end.
   end.

   FIND FIRST buf_clients NO-LOCK WHERE
            buf_clients.obj-type = v-cli-type AND
            buf_clients.obj-code = v-cli-code  NO-ERROR.
   IF available(buf_clients) then do:
    run ref/cli-all.w (
                input parparentproc
               ,input if p-mode = {&update} then "b-sel":U else "":U
               ,input v-cli-type
               ,input {&all}
               ,input {&all}
               ,input RECID( buf_clients )
               ,input ",,,,,,NO"
               ,input ?
               ,OUTPUT v_rid ).

  END.
  ELSE if p-mode = {&update} then DO:
    run ref/cli-all.w (
                 input parparentproc
                ,INPUT "b-sel":U
               ,input  v-cli-type
               ,input {&all}
               ,input {&current}
               ,input ?
               ,input ",,,,,,NO"
               ,input ?
               ,OUTPUT v_rid ).
  END.
  else do:
    message
    if p-value = "":U then 'Атрибут не задан!'
    else substitute('Не найден клиент &1',p-value)
    view-as alert-box warning.
  end.
  IF v_rid <> ? AND v_rid <> "":U THEN DO:
    ASSIGN ref-rec = INT( v_rid ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        RETURN NO-APPLY.
    END.
    FIND FIRST buf_clients NO-LOCK WHERE
               RECID( buf_clients ) = ref-rec NO-ERROR.
    IF AVAIL buf_clients THEN DO:
      v-value = buf_clients.obj-type + string(buf_clients.obj-code, ">>>>>>>>9").
    end.
  end.
  if v-value <> p-value then do:
    p-value = v-value.
    p-setted = yes.
  end.

  end.
end procedure.  /* wthcattr-sprcli */



  define new global shared variable g#wthcalib as handle no-undo.

  &glob include_wthcalib yes
  &glob check_wthcalib ~
    if valid-handle( g#wthcalib ) <> yes then do: ~
      run str/wthcalib.p persistent no-error. ~
      if error-status :error or valid-handle( g#wthcalib ) <> yes then do: ~
        message "Error starting wthcalib.p"    skip( 0 ) ~
                g#wthcalib                     skip( 0 ) ~
                g#wthcalib   :type             skip( 0 ) ~
                g#wthcalib   :file-name        skip( 0 ) ~
                error-status :get-message( 1 ) skip( 0 ) ~
                return-value                   skip( 0 ) ~
        view-as alert-box error. ~
        stop. ~
      end. /* error */ ~
    end. /* if not valid-handle( g#wthcalib ) */
  &glob run_proc_wthcalib ~
    {&check_wthcalib} ~
    run ~{&proc-name~} in g#wthcalib
&endif

/* $Workfile$   E n d */