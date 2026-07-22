/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

вывод в поток для разных типов касс - пересылка скидки на итог

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE putc-9.
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-cash-num like ub.cash-desk.cash-num no-undo .
define input parameter p-pos-type as char no-undo.
define variable ii  as  integer     no-undo.
define variable v-version as decimal no-undo .
define variable v-maria-discnt-value as character no-undo .
define variable v-maria-rule-num as integer no-undo .
define variable v-dop as character no-undo .
define variable v-date-from as date no-undo .
define variable v-date-to as date no-undo .
define variable v-time-rule-num as integer no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_cash-dis-rule for cash-dis-rule.

CASE p-pos-type:
  when {&cd-type-ibm}
  then do:
    if v-upper-rule-num-tot-discnt > 0 then do:
      find first cash-dis-rule no-lock where
           cash-dis-rule.upper-rule-num = v-upper-rule-num-tot-discnt no-error.
      if cash-dis-rule.templ-rl-root = 20 then do:
        /*пытаемся очистить!!!*/
        PUT stream IBMstream unformatted
        '9 "'
        string( "D", "x(1)" )
        '" '.
        PUT stream IBMstream unformatted
        {&new-line}.


      PUT stream IBMstream unformatted
      '9 "'
      string( action, "x(1)" )
      '" '.
      if action = 'U':U then do:
        for each cash-dis-rule no-lock where
                cash-dis-rule.upper-rule-num = v-upper-rule-num-tot-discnt
                  :
            PUT stream IBMstream unformatted
            cash-dis-rule.tot-sum {&space-char} (- cash-dis-rule.discnt-value) {&space-char}
            .
        end.
      end.
      PUT stream IBMstream unformatted
      {&new-line}.
    end.
    end.
    if p-pos-type = {&cd-type-ibm}
    and v-upper-rule-num-tot-discnt-kat > 0 then do:
      find first cash-dis-rule no-lock where
           cash-dis-rule.upper-rule-num = v-upper-rule-num-tot-discnt-kat  no-error.
      assign
      v-version = 0
      v-version = decimal(buf_cash-desk.version)
      no-error.
      if v-version < 4.53 then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "Невозможно передать на кассу &1 &2&3&4" +
                                "Данный функционал доступен только для POS &5 с версии ПО кассы 4.53"
                              ,  buf_cash-desk.cash-num
                              , {&shop}
                              , buf_cash-desk.obj-code
                              , {&new-line}
                              , {&cd-type-ibm}
                              )
                                              ).
      end.
      if v-version >= 4.53
      and cash-dis-rule.templ-rl-root = 53 then do:
        /*пытаемся очистить!!!*/
        PUT stream IBMstream unformatted
        '24 "'
        string( "D", "x(1)" )
        '" '.
        PUT stream IBMstream unformatted
        {&new-line}.

      PUT stream IBMstream unformatted
      '24 "'
      string( action, "x(1)" )
      '" '.
      if action = 'U':U then do:
        for each cash-dis-rule no-lock where
                cash-dis-rule.upper-rule-num = v-upper-rule-num-tot-discnt-kat
                  :
            PUT stream IBMstream unformatted
            cash-dis-rule.tot-sum {&space-char} (- cash-dis-rule.discnt-value) {&space-char}
            (if cash-dis-rule.dis-kat >= 0
            then (string(cash-dis-rule.dis-kat) + {&space-char})
            else '':U)
            .
        end.
      end.
      PUT stream IBMstream unformatted
      {&new-line}.
    end.
  end.
  end.
  when {&cd-type-ibm-xml} then do:
    if (v-upper-rule-num-tot-discnt > 0
        or
        v-upper-rule-num-tot-discnt-kat > 0)
    and action = 'U':U
    then do:
      run bgelib-tag-open in this-procedure ( input 2, input "TotalDisc"
                                            , input substitute("code='*' ctrl='&1' tms='&2' "
                                                            , "DEL":U
                                                            , integer(OS2-time) - 1)).
      run bgelib-tag-close in this-procedure ( input 2, input "TotalDisc").
      _ii:
      do ii = 1 to 2:
        if ii = 1 and v-upper-rule-num-tot-discnt = 0 then next _ii.
        if ii = 2 and v-upper-rule-num-tot-discnt-kat = 0 then next _ii.
        for each buf_cash-dis-rule no-lock where
                (ii = 1
                 and v-upper-rule-num-tot-discnt <= {&max-num-dr-template}
                 and buf_cash-dis-rule.upper-rule-num = v-upper-rule-num-tot-discnt
                )
                or
                (ii = 1
                 and v-upper-rule-num-tot-discnt > {&max-num-dr-template}
                 and buf_cash-dis-rule.rule-num = v-upper-rule-num-tot-discnt
                )
                or
                (ii = 2
                 and v-upper-rule-num-tot-discnt-kat <= {&max-num-dr-template}
                 and buf_cash-dis-rule.upper-rule-num = v-upper-rule-num-tot-discnt-kat)
                 or
                (ii = 2
                 and v-upper-rule-num-tot-discnt-kat > {&max-num-dr-template}
                 and buf_cash-dis-rule.rule-num = v-upper-rule-num-tot-discnt-kat
                )
                ,
          each cash-dis-rule no-lock where
              (buf_cash-dis-rule.is-term and cash-dis-rule.rule-num = buf_cash-dis-rule.rule-num)
               or
               (not buf_cash-dis-rule.is-term and cash-dis-rule.upper-rule-num = buf_cash-dis-rule.rule-num):
          if buf_cash-dis-rule.time-rule-num > 0 then do:
            v-time-rule-num = buf_cash-dis-rule.time-rule-num.
          end.
          if cash-dis-rule.time-rule-num > 0  then do:
            v-time-rule-num = cash-dis-rule.time-rule-num.
          end.
          if v-time-rule-num > 0  then do:
            find first cash-dis-time-rule where
                    cash-dis-time-rule.time-rule-num = v-time-rule-num no-error.
            if available cash-dis-time-rule then do:
              assign
              v-date-from = cash-dis-time-rule.date-from
              v-date-to = cash-dis-time-rule.date-to
              .
            end.
            else do:
              assign
              v-date-from = today
              v-date-to = 12/31/9999
              .
            end.
          end.
          else do:
            assign
            v-date-from = today
            v-date-to = 12/31/9999
            .
          end.
          run bgelib-tag-open in this-procedure ( input 2, input "TotalDisc"
                                                , input substitute("code='&1' ctrl='&2' tms='&3' "
                                                                , cash-dis-rule.rule-num
                                                                , (if action = "U"
                                                                    then "ADD":U
                                                                    else "DEL":U)
                                                                  , OS2-time)).

          run bgelib-tag-put in this-procedure ( input 3, input "TotalSum":U
                                                , input string(cash-dis-rule.tot-sum), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "TotalPercent":U
                                                , input string(- cash-dis-rule.discnt-value), input 1 ).
          define variable v-dis-kat as integer no-undo .
          if cash-dis-rule.is-term = yes
          and cash-dis-rule.dis-kat <= 0
          and buf_cash-dis-rule.rule-num >  {&max-num-dr-template}
          and buf_cash-dis-rule.dis-kat > 0  then do:
            v-dis-kat = buf_cash-dis-rule.dis-kat.
          end.
          else do:
            v-dis-kat = cash-dis-rule.dis-kat.
          end.
          run bgelib-tag-put in this-procedure ( input 3, input "TotalCat":U
                                                , input string(if v-dis-kat < 0 then 0 else v-dis-kat), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "TotalDateBegin":U
                                                , input Xml-CD-DatetoString(v-date-from), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "TotalDateEnd":U
                                                , input Xml-CD-DatetoString (v-date-to), input 1 ).
          run bgelib-tag-close in this-procedure ( input 2, input "TotalDisc").
        end.
      end.
    end.
    else do:
        run bgelib-tag-open in this-procedure ( input 2, input "TotalDisc"
                                              , input substitute("code='*' ctrl='&1' tms='&2' "
                                                                ,"DEL":U
                                                                , OS2-time)).
        run bgelib-tag-close in this-procedure ( input 2, input "TotalDisc").
    end.
  end.
  when {&cd-type-ncr-as-r} then do:
   if action = 'U':U then do:
     if v-upper-rule-num-tot-discnt > 0 then do:
        find first cash-dis-rule where
                  cash-dis-rule.rule-num = v-upper-rule-num-tot-discnt.
        run create-ncr-kat-discnt in this-procedure (
                                                    input string(0)
                                                    ,input ('SD' + fill( {&space-char} , 10) + "****")
                                                    ,input cash-dis-rule.des
                                                    ,input cash-dis-rule.rule-num
                                                    ,input 20
                                                    ,input 'tot-sum':U
                                                    ,input ?
                                                    ) no-error .
     end.
     if v-upper-rule-num-tot-discnt-kat > 0 then do:
     for each cash-dis-rule no-lock where
              /*cash-dis-rule.upper-rule-num = v-upper-rule-num-tot-discnt-kat*/
              cash-dis-rule.templ-rl-root = 35
          and cash-dis-rule.dis-kat < 0
          :
        run create-ncr-kat-discnt in this-procedure (
                                                    input string(0)
                                                    ,input ('SD' + fill( {&space-char} , 10) + "****")
                                                    ,input cash-dis-rule.des
                                                    ,input cash-dis-rule.rule-num
                                                    ,input 35
                                                    ,input 'tot-sum':U
                                                    ,input ?
                                                    ) no-error .
        if error-status:error then do:
        end.
      end.
     end. /*if v-upper-rule-num-tot-discnt-kat > 0*/
   end. /*if action = 'U'*/
    if action = "D":U then do:
      run create-ncr-kat-discnt in this-procedure (
                                                  input string(0)
                                                  ,input ('SD' + fill( {&space-char} , 10) + "****")
                                                  ,input '':U
                                                  ,input 0
                                                  ,input 0
                                                  ,input 'tot-sum':U
                                                  ,input ?
                                                  ) no-error .
    end. /*D*/
  end.
  when {&cd-type-maria} then do:
    v-maria-discnt-value = string(0, '999').
    if action <> 'D':U  then do:
      find first cash-dis-rule no-lock where
        cash-dis-rule.obj-type = {&shop}
            AND cash-dis-rule.obj-code = i-obj-code
            AND cash-dis-rule.rule-num = v-upper-rule-num-tot-discnt
            AND cash-dis-rule.sts = integer({&current-status-int}) no-error .
      if  available cash-dis-rule then do:
        /*найдем код правила на кассе МАРИЯ*/
        if index(dr-list, string(cash-dis-rule.rule-num) + '-') > 0 then do:
          assign
          v-dop = substring(dr-list, index(dr-list, string(cash-dis-rule.rule-num) + '-':U))
          v-dop = substring(v-dop, 1, index(v-dop, {&comma-char}) - 1)
          v-maria-rule-num = integer(entry(2, v-dop, '-':U)) - 1
          v-maria-discnt-value = string(v-maria-rule-num * 8 + 2, '999')
          .
        end.
      end.
    end. /*не D*/
    entry(1, v-record, {&delim-par}) = v-maria-discnt-value.
  end.
END CASE .
END PROCEDURE .

/* $Workfile$ e n d */