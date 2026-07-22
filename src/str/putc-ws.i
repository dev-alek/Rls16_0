/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

вывод в поток для разных типов касс - пересылка масок МЦ

Автор: Гридчина Полина Дмитриевна
Дата создания: 08/09/07
Author: Polina Gridchina
Creation date: 08/09/07


*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE putc-ws.
define input parameter pos-type   as character no-undo.
define input parameter p-version  as character no-undo .
/*define input parameter p-full-stop-list-code as character no-undo .*/

define variable v-version-dec as decimal no-undo .
define variable v-ii as integer no-undo .

CASE pos-type:
  when {&cd-type-ibm-xml}  then do:
    assign
    v-version-dec = decimal(p-version) no-error .
    if v-version-dec >= 1.05 then do:
      run bgelib-tag-open in this-procedure ( input 2, input "MaskPayMeans"
                                            , input substitute("ctrl='&1' tms='&2' code='&3'"
                                                              ,(if action = "U"
                                                                then "ADD":U
                                                                else "DEL":U)                                                              , OS2-time
                                                              , buf_wth-ser.db-num * 10000000 + buf_wth-ser.ser-code       /* создаем long int для того чтобы положить наш иденнтификатор в один  int*/
                                                              )).
      run bgelib-tag-put in this-procedure ( input 3, input "MPCoup"  , input buf_wth-ser.maska , input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "MPMName"  , input string(buf_wth-ser.series,"x(20)":U) , input 1 ).
      run bgelib-tag-open in this-procedure ( input 3
                                              , input "MPProp"
                                              , input '':U      ).
      run bgelib-tag-put in this-procedure ( input 4, input "MPAuthorize"  , input buf_wth-ser.authr , input 1 ).
      run bgelib-tag-close in this-procedure ( input 3, input "MPProp").
/*      if  buf_wth-ser.authr = 0 then do:
      end.  */
      run bgelib-tag-open in this-procedure ( input 3
                                              , input "MPMark"
                                              , input '':U      ).
      run bgelib-tag-put in this-procedure ( input 4, input "MPMCode"  , input v-prod-bc , input 1 ).
      run bgelib-tag-close in this-procedure ( input 3, input "MPMark").
      run bgelib-tag-put in this-procedure ( input 3, input "MPCoupType"  , input 0 , input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "MPCoupValue"  , input buf_snd-wth-par.par-val , input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "MPPayCode"  , input buf_snd-cash-pay.cdpay-code , input 1 ).
      if buf_wth-ser.chk-bdt = 2 then do:
        run bgelib-tag-put in this-procedure ( input 3, input "MPDateStartYY"  , input substring(string(year(buf_wth-ser.beg-dt)),3,2) , input 0 ).
        run bgelib-tag-put in this-procedure ( input 3, input "MPDateStartMM"  , input string(month(buf_wth-ser.beg-dt)) , input 0 ).
        run bgelib-tag-put in this-procedure ( input 3, input "MPDateStartDD"  , input string(day(buf_wth-ser.beg-dt)) , input 0 ).
      end.
      if buf_wth-ser.chk-edt = 2 then do:
        run bgelib-tag-put in this-procedure ( input 3, input "MPDateEndYY"  , input substring(string(year(buf_wth-ser.end-dt)),3,2) , input 0 ).
        run bgelib-tag-put in this-procedure ( input 3, input "MPDateEndMM"  , input string(month(buf_wth-ser.end-dt)) , input 0 ).
        run bgelib-tag-put in this-procedure ( input 3, input "MPDateEndDD"  , input string(day(buf_wth-ser.end-dt)) , input 0 ).
      end.
      run bgelib-tag-put in this-procedure ( input 3, input "MPLock"  , if buf_wth-ser.stts = 0 then 0 else 1 , input 1 ).
      run bgelib-tag-close in this-procedure ( input 2, input "MaskPayMeans").

   end.
  end.
END CASE .
END PROCEDURE .


/* $Workfile$ e n d */