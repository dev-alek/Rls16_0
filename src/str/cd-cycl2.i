/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

отсылка дис карт - цикл по всем кассам одного типа

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/28/05
Author: Bakhtadze Natalya
Creation date: 09/28/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE   for-cash-cycle:
DEFINE VARIABLE fname-list as character no-undo .
DEFINE VARIABLE out-list as character no-undo .
DEFINE VARIABLE var-file-num as integer no-undo .
DEFINE VARIABLE v-dir-remote as character no-undo .
DEFINE VARIABLE v-dir-remote-tmp as character no-undo .
define variable v-versiond as decimal no-undo .
define variable v-clu as character no-undo .

define variable v-dc-host-code like ub.sysconf.host-code no-undo .
define variable v-type              as character no-undo .


define buffer for-cash-desk for ub.cash-desk.
define buffer buf_cd-clu for ub.cd-clu.

FOR EACH for-cash-desk NO-LOCK WHERE
        for-cash-desk.db-num = g#db-num AND
        for-cash-desk.pos-type = ub.cash-desk.pos-type AND
        for-cash-desk.obj-code = i-obj-code AND
        for-cash-desk.cash-on  = yes
BREAK
BY for-cash-desk.db-num
BY for-cash-desk.obj-code
BY for-cash-desk.pos-type
BY for-cash-desk.cash-on
BY for-cash-desk.cash-num:
   IF (LOOKUP(ub.cash-desk.pos-type,
              ({&cd-type-NCR-GM} + {&comma-char} +
               {&cd-type-IBM-XML} + {&comma-char} +
               {&cd-type-MAGIA-XML} + {&comma-char} +
               {&cd-type-NCR-AS-R} )) > 0
     and for-cash-desk.autonomy = integer({&cd-slave})) then NEXT.
  if run-from = "E":U then NEXT.
  if LOOKUP(ub.cash-desk.pos-type,
            {&cd-type-maria}
               ) > 0 then do:
    if for-cash-desk.autonomy = integer({&cd-manager}) then do:
      /*отсылаем только из интерфейса КЛИЕНТЫ НА КАССЕ*/
      if v-del-mrkt-cli = no then next.
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
  /*открываем поток*/
  { str/outc-gen.i
  &cd-buffer=for-cash-desk
  &subject=dis-card
  &out-title="'Пересылка дисконтных карт/клиентов)'"
  &cdt-ibm=yes
  &cdt-omron-new=yes
  &cdt-ipc-servispl=yes
  &cdt-ncr-gm=yes
  &cdt-magia-xml=yes
  &cdt-ibm-xml=yes
  &cdt-ncr-as-r=yes
  &cdt-r-keeper=yes
  &cdt-nkt-ibm=yes
  &cdt-maria=yes
  &data-by=object
  }
  /*сформируем вывод для кассы определенного типа*/
  _cash-cli:
  FOR EACH cash-cli
  where ((NOT (g#news or g#esys OR run-from = "S":U or run-from = "O":U))  OR (cash-cli.crf <= cr))
  NO-LOCK
  BREAK
  by cash-cli.cli-type
  by cash-cli.cli-code
  :
    if cash-cli.cli-code eq ?
    then do: 
    end.
    else if for-cash-desk.pos-type = {&cd-type-maria} then do:
    end.
    else do:
      FIND FIRST ub.dis-card-type No-LOCK WHERE
                  ub.dis-card-type.type = cash-cli.type and
                  ub.dis-card-type.emitent-host-code = cash-cli.emitent-host-code AND
                  ub.dis-card-type.host-code = 0 AND
                  ub.dis-card-type.obj-type = "":U AND
                  ub.dis-card-type.obj-code = 0 NO-ERROR.
      if not avail ub.dis-card-type then NEXT _cash-cli.
      if LOOKUP(string(i-obj-code), ub.dis-card-type.dcbyshop) > 0 AND (cash-cli.issue-code <> i-obj-code) then
      NEXT _cash-cli.
    end. /*if not maria*/
    if first-of(for-cash-desk.obj-code) then do:
      glog = dct-algo-get_dcproperty-value-chr (
                                      input cash-cli.d-card
                                    , input cash-cli.emitent-host-code
                                    , input cash-cli.type
                                    , input 0 /*host-code*/
                                    , input '':U /*p-obj-type*/
                                    , input 0 /*p-obj-code*/
                                    , output v-property-value-chr
                                      ).
      do v-ii = 1 to min(num-entries(v-property-value-chr), 4):
        if entry(v-ii, v-property-value-chr)  <> {&question-mark} then do:
          assign
          cash-cli.property-value-chr[v-ii] = v-property-value-chr
          .
        end.
        else do:
          assign
          cash-cli.property-value-chr[v-ii] = '':U
          .
        end.
      end.
    end.
    RUN putc-2 in this-procedure (
                 buffer for-cash-desk
                ,input for-cash-desk.pos-type
                ,input for-cash-desk.version
                ,input first-of(cash-cli.cli-code) ) no-error .
    if error-status:error then do:
      assign
      v-view-log = yes.
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input "!Ошибка при пересылке на кассу: " + (if return-value <> "":U then return-value else "":U)
                                            ).
    end.
  end.
  
  RUN putc-dis-card-mask ( buffer for-cash-desk
                          ,input for-cash-desk.pos-type
                          ,input for-cash-desk.version ).
  /*закрываем поток*/
  { str/cloc-gen.i
  &cd-buffer=for-cash-desk
  &subject=dis-card
  &out-title="'Пересылка дисконтных карт/клиентов'"
  &out-title-add="'добавление дисконтных карт/клиентов'"
  &out-title-del="'удаление дисконтных карт/клиентов'"
  &cdt-ibm=yes
  &cdt-omron-new=yes
  &cdt-ipc-servispl=yes
  &cdt-ncr-gm=yes
  &cdt-magia-xml=yes
  &cdt-ibm-xml=yes
  &cdt-ncr-as-r=yes
  &cdt-r-keeper=yes
  &cdt-nkt-ibm=yes
  &cdt-maria=yes
  }
END . /*for each for-cash-desk*/
END PROCEDURE.

/* $Workfile$ e n d */