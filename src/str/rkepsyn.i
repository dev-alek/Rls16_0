/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обший блок получения товара из связки R=-keeper TH для синхронизации

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/17/05
Author: Bakhtadze Natalya
Creation date: 02/17/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

   FIND FIRST buf_cd-plu Exclusive-lock WHERE
            RECID(buf_cd-plu) = INTEGER(ENTRY(ii, p-rid-list)) NO-ERROR.
   IF not AVAILABLE  buf_cd-plu  THEN do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Не найдена или занята запись товара на кассе R-keeper c recid &1", INTEGER(ENTRY(ii, p-rid-list)))).
      assign
      v-view-log = yes.
      next _ii.
   end.
   if buf_cd-plu.b-code = 0 then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Блюдо меню/модификатор на кассе R-KEEPER с id &1 код в меню &2 <&3>&4 - не сопоставлен товар в системе IBS TH"
                              , buf_cd-plu.plu-code
                              , buf_cd-plu.key#_one
                              , buf_cd-plu.charkey_one
                              , {&new-line}
                            )).
      assign
      v-view-log = yes.
      next _ii.
   end.
   /*найдем а какой же товар будем синхронизировать*/
   find first buf_bar-code no-lock where
            buf_bar-code.b-code =  buf_cd-plu.b-code no-error.
   if not available buf_bar-code then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Блюдо меню/модификатор на кассе R-KEEPER с id &1 код в меню &2 <&3>&4 - не найден товар с бар-кодом &5 в системе IBS TH"
                              , buf_cd-plu.plu-code
                              , buf_cd-plu.key#_one
                              , buf_cd-plu.charkey_one
                              , {&new-line}
                              , buf_cd-plu.b-code
                            )).
      assign
      v-view-log = yes.
      next _ii.
   end.
   find first buf_goods {&goods-lock} where
            buf_goods.gds-code = buf_bar-code.gds-code  no-error no-wait.
   if not available buf_goods and not locked buf_goods then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Блюдо меню/модификатор на кассе R-KEEPER с id &1 код в меню &2 <&3>&4 - не найден товар с кодом &5 для бар-кода &6 в системе IBS TH"
                              , buf_cd-plu.plu-code
                              , buf_cd-plu.key#_one
                              , buf_cd-plu.charkey_one
                              , {&new-line}
                              , buf_cd-plu.b-code
                              , buf_bar-code.gds-code
                            )).
      assign
      v-view-log = yes.
      next _ii.
   end.

/* $Workfile$ e n d */