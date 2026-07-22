/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура отслыки параметров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/05/05
Author: Bakhtadze Natalya
Creation date: 12/05/05

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


procedure putc-par :
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-pos-type like ub.cash-desk.pos-type no-undo .
define input parameter p-version like ub.cash-desk.version no-undo .
define input parameter p-cash-os like ub.cash-desk.cash-os no-undo .
define input parameter p-cash-num like ub.cash-desk.cash-num  no-undo .
define variable v-cda-character as character no-undo .
define variable v-cda-date as date no-undo .
define variable v-cda-decimal as decimal no-undo .
define variable v-cda-integer as integer no-undo .
define variable v-cda-logical as logical no-undo .

define variable v-type as character no-undo .
define variable v-limit as decimal no-undo .
define variable attr-type as character no-undo .          /* тип атрибута      */
define variable attr-format as character no-undo .        /* формат атрибута   */
define variable attr-label as character no-undo .         /* лабел атрибута    */
define variable attr-value as character no-undo .         /* значение атрибута */
define variable attr-user-can-edit as logical no-undo .   /* пользователь может изменять в броусе */
define variable attr-output-display as logical no-undo .  /* виден в броусе    */
define variable attr-other as char no-undo .              /* еще чего - нибудь */
define variable attr-from-gbd as logical no-undo .
define variable attr-from-ubd as logical no-undo .
define variable attr-news as logical no-undo .
define variable v-prop-list as character no-undo .
define variable v-what-send as character no-undo .
define variable v-section as character no-undo .
define variable v-cash-num as integer no-undo init -1.
define variable v-tare-string as character no-undo .
define variable v-tare-weight as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-jj as integer no-undo .


define buffer buf_cash-desk-attr for ub.cash-desk-attr.
define buffer buf2_cash-desk-attr for ub.cash-desk-attr.

  do
  on error undo, return error return-value
  :
    v-what-send = p-what-send.
    v-section = p-section.
    for each buf_cash-desk-attr no-lock where
          buf_cash-desk-attr.db-num = p-db-num
      and buf_cash-desk-attr.obj-code = p-obj-code
      and buf_cash-desk-attr.pos-type = p-pos-type
      and buf_cash-desk-attr.upper-attr-code = v-section
      and ( p-cash-num = ?
           or
           buf_cash-desk-attr.cash-num = p-cash-num)
      and (p-what-send = '':U
           or
           buf_cash-desk-attr.attr-code = p-what-send
          or
           buf_cash-desk-attr.attr-code begins (p-what-send + {&delim-par})
           ):
      run cd-attr-value(
                              input  p-db-num
                            ,input  p-obj-code
                            ,input  p-pos-type
                            ,input  p-cash-num
                            ,input  buf_cash-desk-attr.upper-attr-code
                            ,input  buf_cash-desk-attr.attr-code
                            ,output v-cda-character
                            ,output v-cda-date
                            ,output v-cda-decimal
                            ,output v-cda-integer
                            ,output v-cda-integer
                            ,output v-type) no-error .
      if not error-status:error then do:
        if v-what-send = '':u then p-what-send = buf_cash-desk-attr.attr-code.
        CASE p-what-send:
          when {&cda-ncr-gm_general_message-by-lim-sum-check}
          or
          when {&cda-ncr-as-r_general_message-by-lim-sum-check}
          then do:
            assign
            v-limit = v-cda-decimal
            no-error .
            if not error-status:error then do:
              /*лежит в p_regpar.dat*/
              run create-ncr-par in this-procedure (
                                                        input 'GVCD0'
                                                       ,input string(round(v-limit, 0), "99999") + fill('0', 35) ).
            end.
          end. /* {&attr-cd-message-by-lim-sum-check} */
          when {&cda-ncr-gm_general_tara-ref}
          or
          when {&cda-ncr-as-r_general_tara-ref}
          then do:
            if v-cash-num = buf_cash-desk-attr.cash-num then next.
            /*лежит в p_regpar.dat*/
            do v-ii = 0 to 9:
              v-tare-string = "".
              do v-jj = 0 to 9:
                find first buf2_cash-desk-attr no-lock where
                        buf2_cash-desk-attr.db-num = p-db-num
                    and buf2_cash-desk-attr.obj-code = p-obj-code
                    and buf2_cash-desk-attr.pos-type = p-pos-type
                    and buf2_cash-desk-attr.cash-num = buf_cash-desk-attr.cash-num
                    and buf2_cash-desk-attr.upper-attr-code = buf_cash-desk-attr.upper-attr-code
                    and buf2_cash-desk-attr.attr-code = p-what-send + {&delim-par} + string(v-ii * 10 + v-jj, '99') no-error.
                if available buf2_cash-desk-attr
                and (v-ii * 10 + v-jj) > 0
                then do:
                  assign
                  v-tare-weight = integer(buf2_cash-desk-attr.attr-value-character) no-error.
                  if not error-status:error
                  and v-tare-weight >= 0
                  and v-tare-weight <= 9999 then do:
                      assign
                      v-tare-string = v-tare-string + (string(v-tare-weight, "9999"))
                      .
                  end.
                  else do:
                      assign
                      v-tare-string = v-tare-string + "0000":U
                      .
                  end.
                end. /*if available buf_2_cash-desk  then do:*/
                else do:
                  assign
                  v-tare-string = v-tare-string + "0000":U
                  .
                end.
              end. /*do v-jj = 1 to 9:*/
              run create-ncr-par in this-procedure (
                                                          input ('TARE' + string (v-ii))
                                                          ,input v-tare-string ).
            end. /*do v-ii = 0 to 9:*/
            v-cash-num = buf_cash-desk-attr.cash-num.

          end. /*          when {&cd-attr-tare-ref} */
          /*
          when {&cd-attr-periodic-tasks} then do:
            /*
            метод настройки периодических заданий через OLE сервер юудут реализованы позднее*/
            run maria-task in this-procedure (
                                              buffer buf_Cash-desk
                                            , input fname
                                            , input entry(1, v-cda-character, {&space-char} )
                                            , input entry(2, v-cda-character, {&space-char} )
                                              ) .
            /*пока пишем прямо в файл на диске в директорию addin*/
            /*файл должен называться tasks*/
          end. /* {&cd-attr-periodic-tasks} */
          */
          when {&cda-ibm-xml_general_use-kbo} then do:
            define variable v-cp-is-use as logical no-undo .
            define variable v-kbo-string as character no-undo extent 5.
            define variable v-prev-cdpay-code as integer no-undo .
            define buffer buf_cash-pay for ub.cash-pay.
            for each temp-talon-pay:
              delete temp-talon-pay.
            end.
            if v-cda-logical = yes then do:
              /*здесь должны сформировать строки параметров*/
              if action = 'D':U then do:
                assign
                v-cp-is-use = no.
              end.
              if action <> 'D':U then do:
                run adm/shattri.p (
                    input "get":U
                    ,input  {&shop}
                    ,input  p-obj-code
                    ,input  {&attr-cd-inf-send}
                    ,input  {&attr-cd-inf-send_cp-is-use} /*p-param-code*/
                    ,output v-value-character
                    ,output v-value-date
                    ,output v-value-decimal
                    ,output v-value-integer
                    ,output v-value-logical
                    ,output v-param-type
                    ,INPUT-OUTPUT table-handle v-tth
                    ) no-error .
                IF not error-status:error
                then do:
                  v-cp-is-use = v-value-logical.
                  delete object v-tth.
                end.
                else do:
                  delete object v-tth.
                  return error return-value .
                end.
              end.
              v-ii = 1.
              v-prev-cdpay-code = 0.
              for each buf_cash-pay no-lock where
                      buf_cash-pay.is-kbo > 0
              and buf_cash-pay.curr-code = 0
              break
              by buf_cash-pay.cdpay-code
              by buf_cash-pay.curr-code:

                if cp-isuse ( input  buf_cash-pay.cdpay-code
                              ,input  buf_cash-pay.curr-code
                              ,input  v-host-code
                              ,input {&shop}
                              ,input p-obj-code
                              ,input v-cp-is-use
                              ,input p-cash-num
                              ,input p-pos-type )
                then do:
                  if v-prev-cdpay-code = buf_cash-pay.cdpay-code - 1 then do:
                    find first temp-talon-pay where
                              temp-talon-pay.cdpay-code1 <= v-prev-cdpay-code
                        and  temp-talon-pay.cdpay-code2 = v-prev-cdpay-code  no-error.
                    if not available temp-talon-pay then do:
                      create temp-talon-pay.
                      assign
                      temp-talon-pay.cdpay-code1 = buf_cash-pay.cdpay-code
                      temp-talon-pay.cdpay-code2 = buf_cash-pay.cdpay-code
                      .
                    end.
                    else do:
                      assign
                      temp-talon-pay.cdpay-code2 = buf_cash-pay.cdpay-code
                      .
                    end.
                  end.
                  else do:
                    create temp-talon-pay.
                    assign
                    temp-talon-pay.cdpay-code1 = buf_cash-pay.cdpay-code
                    temp-talon-pay.cdpay-code2 = buf_cash-pay.cdpay-code
                    .
                  end.
                  assign
                  temp-talon-pay.diap = (if temp-talon-pay.cdpay-code1 = temp-talon-pay.cdpay-code2
                                         then string(temp-talon-pay.cdpay-code1)
                                         else substitute('&1-&2'
                                                    , temp-talon-pay.cdpay-code1
                                                    ,temp-talon-pay.cdpay-code2)
                                         )
                  temp-talon-pay.rank = (if temp-talon-pay.cdpay-code1 = temp-talon-pay.cdpay-code2
                                         then 1
                                         else 0)
                  .
                  release temp-talon-pay.
                  v-prev-cdpay-code = buf_cash-pay.cdpay-code.
                end.
              end. /*for each buf_cash-pay no-lock where*/
              v-ii = 1.
              for each temp-talon-pay
              by temp-talon-pay.rank
              by temp-talon-pay.cdpay-code1
              :
                  if length(v-kbo-string[v-ii] + (if v-kbo-string[v-ii] = '':U then '':U else {&comma-char}) + temp-talon-pay.diap) > 39 then do:
                    v-ii = v-ii + 1.
                    if v-ii > 5 then do:
                      if not g#auto
                      and not g#news then do:
                        message
                        "Параметр ИСПОЛЬЗОВАТЬ КБО отошлется на кассу, однако списки ВСЕХ КБО в него не поместились!"
                        view-as alert-box error .
                      end.
                      leave.
                    end.
                  end.
                  assign
                  v-kbo-string[v-ii] = v-kbo-string[v-ii] + (if v-kbo-string[v-ii] = '':U then '':U else {&comma-char}) +
                                      temp-talon-pay.diap.
              end.
            end. /*if v-cda-logical = yes then do:*/
            do v-ii = 1 to 5 :
              run bgelib-tag-open in this-procedure ( input 2, input "Param"
                                                     ,input substitute("ctrl='&1' tms='&2' group='UFO2' key='TalonPay&3'"
                                                                       ,'ADD':u
                                                                       ,OS2-time
                                                                       ,v-ii)).
              run bgelib-tag-put in this-procedure ( input 3, input "ParamValue", v-kbo-string[v-ii] , input 1 ).
              run bgelib-tag-put in this-procedure ( input 3, input "ParamDesc"
                                                   , substitute("Список КБО, строка &1-ПЕРЕДАНО ИЗ IBS TH"
                                                                ,v-ii)
                                                   , input 1 ).
              run bgelib-tag-close in this-procedure ( input 2, input "Param" ).
            end.
          end. /*when {&cd-attr-use-kbo} then do:*/
        END. /*case p-what-send*/
      end. /*      if not error-status:error then do:*/
      else do:
        run cd-attr-code ( input buf_cash-desk-attr.upper-attr-code
                           ,input buf_cash-desk-attr.attr-code
                           ,output attr-type
                           ,output attr-format
                           ,output attr-label
                           ,output attr-user-can-edit
                           ,output attr-output-display
                           ,output attr-other
                           ,output v-prop-list
                            ).
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!Ошибки при чтении атрибута кассы &1 &2 маг&3:&4" +
                                "атрибут &5"
                              , p-pos-type
                              , p-cash-num
                              , p-obj-code
                              , {&new-line}
                              , attr-label) ).
      end.
    end. /*for each buf_cash-desk-attr*/
  end.

end procedure. /* putc-par */

/* $Workfile$ e n d */