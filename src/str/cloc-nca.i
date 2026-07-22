/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

«акрытие потока и сопутствующие операции дл€ кассы NCR

јвтор: Ѕахтадзе Ќаталь€ ¬икторовна
ƒата создани€: 12/08/03
Author: Bakhtadze Natalya
Creation date: 12/08/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


&if "{&subject}" = "good" or "{&subject}" = "dis-card" or "{&subject}" = "parameters" &then

output stream IBMStream close.

&endif

&if "{&subject}" = "parameters" &then
  { str/cloc-ncp.i
  &cd-buffer={&cd-buffer}
  &subject={&subject}
  &out-title-add="{&out-title-add}"
  &out-title-del="{&out-title-del}"
  }
&endif

&if "{&subject}" = "good" or "{&subject}" = "gds-obj-attr" or  "{&subject}" = "tot-discnt" or "{&subject}" = "sum-grp" &then
&scop start-file ~
    assign                                                                             ~
    v-temp-kat-file = out + fname + '.' + string(~{&current-dis-kat~})                 ~
    v-kat-file = (if ~{&current-dis-kat~}  > 0                                         ~
                 then (entry(1, out2, ~{&delim-par~})   + 'group_':U  + string(~{&current-dis-kat~}))  ~
                 else (entry(2, out2, ~{&delim-par~})   + 's_plurbt':U ))              ~
                 + '.dat':u                                                            ~
    v-updated-subject-dis-kat = no.                                                    ~
    if ncr-save-param <> 'no' then do:                                                 ~
      v-kat-file-save = if ncr-save-param = 'NCR'                                      ~
                        then replace(v-kat-file, '.dat', '.sav')                        ~
                        else search((if ~{&current-dis-kat~}  > 0                      ~
                                    then ('group_':U  + string(~{&current-dis-kat~}))  ~
                                    else 's_plurbt':U) + '.sav':U).                     ~
    end


&scop end-file  ~
      find first temp-dis-kat-file no-lock where                                       ~
                temp-dis-kat-file.dis-kat = ~{&current-dis-kat~} no-error.             ~
      if not available temp-dis-kat-file then                                          ~
      create temp-dis-kat-file.                                                        ~
      assign                                                                           ~
      temp-dis-kat-file.dis-kat   = ~{&current-dis-kat~}                               ~
      .                                                                                ~
      assign                                                                           ~
      temp-dis-kat-file.temp-file = v-temp-kat-file                                    ~
      temp-dis-kat-file.send-file = v-kat-file                                         ~
      temp-dis-kat-file.to-send   = yes

 /*скачаем файлы неприкосновенных ручных настроек*/
&scop get-sav-param   ~
    if ncr-save-param <> 'no':U then do:                                               ~
      if search(v-kat-file-save) <> ? then do:                                         ~
      input stream bar from value(v-kat-file-save) convert source "ibm866" .           ~
      repeat:                                                                          ~
        import stream bar unformatted ss.                                              ~
        find first cash-ncr-save-param where                                           ~
                 cash-ncr-save-param.dis-kat = ~{&current-dis-kat~}                    ~
             AND cash-ncr-save-param.cd-line = substring(ss, 1, 24) no-error.          ~
        if not available cash-ncr-save-param then do:                                  ~
          create cash-ncr-save-param.                                                  ~
          assign                                                                       ~
          cash-ncr-save-param.dis-kat = ~{&current-dis-kat~}                           ~
          cash-ncr-save-param.cd-line = substring(ss, 1, 24)                           ~
          cash-ncr-save-param.cd-other = substring(ss, 25)                             ~
          .                                                                            ~
        end.                                                                           ~
      end.                                                                             ~
      input stream bar close .                                                         ~
      end.                                                                             ~
      else do:                                                                         ~
      end.                                                                             ~
    end

&if "{&subject}" = "good" or "{&subject}" = "gds-obj-attr" &then
&scoped-define disc-prefix fill(~{&space-char~}, 2 )
&endif
&if "{&subject}" = "tot-discnt" &then
&scoped-define disc-prefix 'SD'
&endif
&if "{&subject}" = "sum-grp" &then
&scoped-define disc-prefix 'DP'
&endif



define variable v-kat-file-number as integer no-undo .

if action = 'D':U then do:
&scop current-dis-kat v-kat-file-number
  do v-kat-file-number = 0 to 99:
    /*на самом деле нам надо 0 и 10-99*/
    if v-kat-file-number > 0
    and v-kat-file-number < 10 then NEXt.
    {&start-file}.
    V-NEXT = NO.
    if search(v-kat-file) = ? then do:
      next .
    end.
    {&get-sav-param}.
    /*считываем имеющийс€ файл*/
    input stream bar from value(v-kat-file) convert source "ibm866" .
    /*открываем на запись новый файл*/
    output stream plucash to value(v-temp-kat-file) convert target "ibm866".
    _rr:
    repeat:
      import stream bar unformatted ss.
      if not ss begins {&disc-prefix}
      or can-find(first cash-ncr-save-param no-lock where
                       cash-ncr-save-param.dis-kat = {&current-dis-kat}
                   AND cash-ncr-save-param.cd-line = substring(ss, 1, 24))
      then do:
        /*это строчка не нашего типа или ее трогать нельз€*/
        /*просто перепишем ее*/
        put stream plucash unformatted
        ss skip.
        next _rr.
      end.
      /*ищем во временной таблице запись скидок*/
      find first buf_cash-ncr-dis-kat no-lock where
                buf_cash-ncr-dis-kat.dis-kat = - 1
            AND buf_cash-ncr-dis-kat.cd-subject-code = substring(ss, 1, 16) no-error.
      if not available buf_cash-ncr-dis-kat then do:
        put stream plucash unformatted
        ss skip.
      end.
      ELSE DO:
        ASSIGN
        V-NEXT = YES.
      END.
    end. /*repeat*/
    input stream bar close.
    output stream plucash close.
    {&end-file}.
  end. /*v-kat-file-number*/
end.
if action = 'U':U then do:
  FOR EACH cash-ncr-dis-kat No-LOCK WHERE
          cash-ncr-dis-kat.crf <= cr-ncr-dis-kat
  break
  by cash-ncr-dis-kat.dis-kat
  :
  &scop current-dis-kat cash-ncr-dis-kat.dis-kat
    if first-of(cash-ncr-dis-kat.dis-kat) then do:
      {&start-file}.
      /*проверим что файл дл€ данной категории скидок существует*/
      /*если нет то создадим пустой*/
      if search(v-kat-file) = ? then do:
        output stream bar to value(v-kat-file) convert target "ibm866" .
        put stream bar unformatted skip.
        output stream bar close.
      end.
      else do:
       {&get-sav-param}.
      end.

&scop put-ncr-dis-cat ~
          put stream plucash unformatted                                                                     ~
          buf_cash-ncr-dis-kat.cd-subject-code                                                               ~
          buf_cash-ncr-dis-kat.cd-disc-string                                                                ~
          buf_cash-ncr-dis-kat.cd-subject-name                                                               ~
          buf_cash-ncr-dis-kat.cd-other                                                                      ~
          skip
/*конец скидок на группу*/
      /*считываем имеющийс€ файл*/
      input stream bar from value(v-kat-file) convert source "ibm866" .
      /*открываем на запись новый файл*/
      assign
      ss0 = ''
      ss = '':U
      v-cd-subject-code = '':U
      v-cd-disc-string  = '':U
      v-next = no
      v-updated-subject-dis-kat = no
      .

      output stream plucash to value(v-temp-kat-file) convert target "ibm866".
      _rr2:
      repeat:
        /*считываем строчку*/

        import stream bar unformatted ss.
        assign
        v-next = no
        v-updated-subject-dis-kat = no
        v-cd-subject-code = substring(ss, 1, 16)
        v-cd-disc-string =  substring(ss, 17, 7)
        .
        if not ss begins {&disc-prefix}
        then do:
          /*это строчка не нашего типа или ее трогать нельз€*/
          if substring(ss0, 1, 3) = substring(v-cd-subject-code, 1, 3) then do:
            put stream plucash unformatted
            ss skip.
            ss0 = v-cd-subject-code.
            NEXT _rr2.
          end.
          v-next = yes.
        end.
        /*дл€ всех записей которые по сортировке по коду товара меньше или равно данному коду товара чем в данной строчке*/
        /*записываем в новый файл*/
        _for_rr2:
        for each  buf_cash-ncr-dis-kat no-lock where
                  buf_cash-ncr-dis-kat.dis-kat = {&current-dis-kat}
              AND buf_cash-ncr-dis-kat.cd-subject-code <= v-cd-subject-code
              AND buf_cash-ncr-dis-kat.cd-subject-code > ss0
              and crf <= cr-ncr-dis-kat
        by buf_cash-ncr-dis-kat.cd-subject-code
        by buf_cash-ncr-dis-kat.cd-disc-string
&if "{&subject}" = "tot-discnt" &then
        descending
&endif
        :
&if "{&subject}" = "tot-discnt" &then
          if buf_cash-ncr-dis-kat.cd-subject-code = v-cd-subject-code
          and SUBSTRING(buf_cash-ncr-dis-kat.cd-disc-string, 1,  7) < v-cd-disc-string then do:
            leave  _for_rr2.
          end.
&else
          if buf_cash-ncr-dis-kat.cd-subject-code = v-cd-subject-code
          and SUBSTRING(buf_cash-ncr-dis-kat.cd-disc-string, 1, 7) > v-cd-disc-string then do:
            leave  _for_rr2.
          end.
&endif
          if buf_cash-ncr-dis-kat.cd-subject-code = v-cd-subject-code then do:
            v-updated-subject-dis-kat = yes.
          end.
          find first  cash-ncr-save-param no-lock where
                          cash-ncr-save-param.dis-kat = {&current-dis-kat}
                      AND cash-ncr-save-param.cd-line = (buf_cash-ncr-dis-kat.cd-subject-code +
                                                        substring(buf_cash-ncr-dis-kat.cd-disc-string , 1, 2)) no-error.
          if available cash-ncr-save-param then do:
            /*эту строчку трогать нельз€*/
            put stream plucash unformatted
            cash-ncr-save-param.cd-line
            cash-ncr-save-param.cd-other
            skip.
            v-cd-disc-string = substring(cash-ncr-save-param.cd-line , 17, 7)
                               .
            NEXT _for_rr2.
          end.
          {&put-ncr-dis-cat}.
        end.
        if v-next then do:
          ss0 = v-cd-subject-code.
          put stream plucash unformatted
          ss skip.
          NEXT _rr2.
        end.
        if not v-updated-subject-dis-kat then do:
          /*а был ли этот subject в этой посылке вообще?*/
          /*если был и здесь не updated значит у него нет этой категории больше */
          find first buf_cash-ncr-dis-kat no-lock where
                    buf_cash-ncr-dis-kat.cd-subject-code = v-cd-subject-code
                AND buf_cash-ncr-dis-kat.crf <= cr-ncr-dis-kat no-error.
          if not available buf_cash-ncr-dis-kat then do:
            /*если такого товара в этой посылке не было - перепишем его в новый файл*/
            put stream plucash unformatted
            ss skip.
          end.
        end.
        ss0 = v-cd-subject-code.
      end. /*repeat*/
      /*остались только сущности у которых код больше чем код в последней строке файла*/
      input stream bar close.
      _for_rr3:
      for each  buf_cash-ncr-dis-kat no-lock where
                buf_cash-ncr-dis-kat.dis-kat = cash-ncr-dis-kat.dis-kat
            AND buf_cash-ncr-dis-kat.cd-subject-code >= v-cd-subject-code
            and crf <= cr-ncr-dis-kat
      by buf_cash-ncr-dis-kat.cd-subject-code
      by buf_cash-ncr-dis-kat.cd-disc-string
&if "{&subject}" = "tot-discnt" &then
      descending
&endif
      :

&if "{&subject}" = "tot-discnt" &then
          if buf_cash-ncr-dis-kat.cd-subject-code = v-cd-subject-code
          and SUBSTRING(buf_cash-ncr-dis-kat.cd-disc-string, 1, 7) >= v-cd-disc-string then do:
            next  _for_rr3.
          end.
&else
          if buf_cash-ncr-dis-kat.cd-subject-code = v-cd-subject-code
          and SUBSTRING(buf_cash-ncr-dis-kat.cd-disc-string, 1, 7) <= v-cd-disc-string then do:
            next  _for_rr3.
          end.
&endif
        find first  cash-ncr-save-param no-lock where
                      cash-ncr-save-param.dis-kat = {&current-dis-kat}
                  AND cash-ncr-save-param.cd-line = (buf_cash-ncr-dis-kat.cd-subject-code +
                                                    substring(buf_cash-ncr-dis-kat.cd-disc-string , 1, 2)) no-error.
        if available cash-ncr-save-param then do:
          /*эту строчку трогать нельз€*/
          put stream plucash unformatted
          cash-ncr-save-param.cd-line
          cash-ncr-save-param.cd-other
          skip.
          v-cd-disc-string = substring(cash-ncr-save-param.cd-line , 17, 7) .

        end.
        else do:
          {&put-ncr-dis-cat}.
        end.
      end.
      output stream plucash close.
      {&end-file}.
    end. /*if first-of cash-ncr-dis-kat*/
  END.  /*for each cash-ncr-dis-kat*/
end. /*if action = u */
&endif

/* $Workfile$ e n d */