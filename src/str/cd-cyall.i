/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

отсылка схемы интеграции ККТ - цикл по всем кассам одного типа

Автор: Шкляр Елена 
Дата создания: 02/14/14
Author: Elena Shklyar
Creation date: 02/14/14

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


define buffer for-cash-desk for ub.cash-desk.
_for:
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
    :
  if LOOKUP(ub.cash-desk.pos-type,
            ({&cd-type-NCR-GM} + {&comma-char} +
             {&cd-type-IBM-XML} + {&comma-char} +
             {&cd-type-MAGIA-XML} + {&comma-char} +
             {&cd-type-NCR-AS-R} + {&comma-char}
               )) > 0
  and for-cash-desk.autonomy = integer({&cd-slave}) then NEXT.
  assign
  v-versiond = decimal(for-cash-desk.version)
  no-error .
  if error-status:error
  or for-cash-desk.pos-type <> {&cd-type-IBM-XML}
  then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "Невозможно передать на кассу &1 &2&3&4" +
                            "Данный функционал доступен только для POS &5"
                          ,  for-cash-desk.cash-num
                          , {&shop}
                          , for-cash-desk.obj-code
                          , {&new-line}
                          , {&cd-type-ibm-XML}
                          )
                                          ).

     next _for.
  end.



  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "Пересылка - касса &1", for-cash-desk.cash-num
                        )
                                        ).
  
  { str/outc-genall.i
  &out-title = i-Title 
  }
  /*сформируем вывод для кассы определенного типа*/
  RUN value ("putc-" + i-type ) in this-procedure
               ( input hSAXWriter
                ,input for-cash-desk.pos-type
                ,input for-cash-desk.version
                ,input for-cash-desk.cash-os
                ,input for-cash-desk.cash-num
                ,input i-value
                ).

  { str/cloc-genall.i
  &out-title= i-Title
  }



END . /*for each for-cash-desk*/
END PROCEDURE.

/* $Workfile$ e n d */