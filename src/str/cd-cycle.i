/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

отсылка товаров на кассы - цикл по всем кассам одного типа

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/17/05
Author: Bakhtadze Natalya
Creation date: 10/17/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE   for-cash-cycle:
DEFINE VARIABLE fname-list as character no-undo .
DEFINE VARIABLE out-list as character no-undo .
DEFINE VARIABLE var-file-num as integer no-undo .
DEFINE VARIABLE v-dir-remote as character no-undo .
DEFINE VARIABLE v-dir-remote-tmp as character no-undo .
define variable v-plu as character no-undo .
define variable v-pl-code as integer no-undo .
define variable ss  as character no-undo .
define variable ss0  as character no-undo .
define variable v-temp-kat-file as character no-undo .
define variable v-kat-file as character no-undo .
define variable v-kat-file-save as character no-undo .
define variable v-updated-subject-dis-kat as logical no-undo .
define variable v-next as logical no-undo .
define variable v-cd-subject-code as character no-undo .
define variable v-cd-disc-string as character no-undo .
define variable v-versiond as decimal no-undo .
define variable v-maria-discnt-value as character no-undo .
define variable v-ii as integer no-undo .
define variable v-dop as character no-undo .
define variable v-gds-rule-num as integer no-undo .
define variable v-maria-rule-num as integer no-undo .



define buffer for-cash-desk for ub.cash-desk.
define buffer buf_cd-plu for ub.cd-plu.
define buffer buf_cash-ncr-dis-kat for cash-ncr-dis-kat.
define buffer buf_cash-gds for cash-gds.
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_place for ub.place.
define buffer buf_pl-gds for ub.pl-gds.


FOR EACH for-cash-desk NO-LOCK WHERE
        for-cash-desk.db-num = g#db-num AND
        for-cash-desk.pos-type = ub.cash-desk.pos-type AND
        for-cash-desk.obj-code = i-obj-code AND
&if defined(onecash ) ne 0
&then
        for-cash-desk.cash-num eq onecash 
&else      
 for-cash-desk.cash-on  = yes
&endif
    BREAK
    BY for-cash-desk.db-num
    BY for-cash-desk.obj-code
    BY for-cash-desk.pos-type
    BY for-cash-desk.cash-on
    BY for-cash-desk.cash-num
    :
  if LOOKUP(ub.cash-desk.pos-type,
            ({&cd-type-NCR-GM} + {&comma-char} +
             {&cd-type-IBM-XML} + {&comma-char} +
             {&cd-type-MAGIA-XML} + {&comma-char} +
             {&cd-type-NCR-AS-R}  + {&comma-char} +
             {&cd-type-autotank}
               )) > 0
  and for-cash-desk.autonomy = integer({&cd-slave}) then NEXT.
  if LOOKUP(ub.cash-desk.pos-type,
            {&cd-type-maria}
               ) > 0 then do:
    if for-cash-desk.autonomy = integer({&cd-manager}) then do:
      assign
      v-cd-list-update = for-cash-desk.addr-path
      v-cd-list-delete = for-cash-desk.addr-path
      .
      NEXT.
    end.
    else do:
      /*если выключен менедже - то на простую кассу не посылаем*/
      if v-cd-list-update = '':U then nExt.
    end.
  end.
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "Пересылка - касса &1", for-cash-desk.cash-num
                        )
                                        ).
  { str/outc-gen.i
  &cd-buffer=for-cash-desk
  &subject=good
  &out-title="'Пересылка данных по товарам'"
  &data-by=object
  &cdt-ibm=yes
  &cdt-ibm-xml=yes
  &cdt-magia-xml=yes
  &cdt-omron-new=yes
  &cdt-ipc-servispl=yes
  &cdt-ncr-gm=yes
  &cdt-ncr-AS-R=yes
  &cdt-infokiosk=yes
  &cdt-pricecheck-Servispl=yes
  &cdt-maria=yes
  &cdt-autotank=yes
  }
  FOR EACH cash-gds WHERE cash-gds.crf <= cr No-LOCK :
      /*сформируем вывод для кассы определенного типа*/
      RUN putc-gds( buffer for-cash-desk, input for-cash-desk.pos-type, input for-cash-desk.version, input for-cash-desk.cash-os ).
  END . /*for each gds-list*/
  { str/cloc-gen.i
  &cd-buffer=for-cash-desk
  &subject=good
  &out-title-add="'добавление товаров'"
  &out-title-del="'удаление товаров'"
  &data-by=object
  &cdt-ibm=yes
  &cdt-ibm-xml=yes
  &cdt-magia-xml=yes
  &cdt-omron-new=yes
  &cdt-ipc-servispl=yes
  &cdt-ncr-gm=yes
  &cdt-ncr-AS-R=yes
  &cdt-infokiosk=yes
  &cdt-pricecheck-Servispl=yes
  &cdt-maria=yes
  &cdt-autotank=yes
  }
END . /*for each for-cash-desk*/
END PROCEDURE.
/* $Workfile$ e n d */