/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/05/05
Author: Bakhtadze Natalya
Creation date: 12/05/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop start-file                                                             ~
  assign                                                                     ~
  v-temp-kat-file = out + fname + '.dat'                                     ~
  v-kat-file = entry(3, out2, ~{&delim-par~}) + 'p_regpar.dat':U             ~
  v-updated-subject-dis-kat = no.                                            ~
  if ncr-save-param <> 'no' then do:                                         ~
    v-kat-file-save = if ncr-save-param = 'NCR'                              ~
                      then replace(v-kat-file, '.dat', '.sav')               ~
                      else search(replace('p_regpar.dat', '.dat', '.sav')).  ~
  end

&scop get-sav-param ~                                                        ~
    if ncr-save-param <> 'no':U then do:                                     ~
      if search(v-kat-file-save) <> ? then do:                               ~
      input stream bar from value(v-kat-file-save) convert source "ibm866" . ~
      repeat:                                                                ~
        import stream bar unformatted ss.                                    ~
        find first cash-ncr-save-param where                                 ~
                 cash-ncr-save-param.dis-kat = 0                             ~
             AND cash-ncr-save-param.cd-line = substring(ss, 1, 5) no-error. ~
        if not available cash-ncr-save-param then do:                        ~
          create cash-ncr-save-param.                                        ~
          assign                                                             ~
          cash-ncr-save-param.dis-kat = 0                                    ~
          cash-ncr-save-param.cd-line = substring(ss, 1, 5)                  ~
          cash-ncr-save-param.cd-other = substring(ss, 6)                    ~
          .                                                                  ~
        end.                                                                 ~
      end.                                                                   ~
      input stream bar close .                                               ~
      end.                                                                   ~
      else do:                                                               ~
      end.                                                                   ~
    end

&scop end-file                                                                         ~
      find first temp-dis-kat-file no-lock where                                       ~
                temp-dis-kat-file.dis-kat = 0 no-error.                                ~
      if not available temp-dis-kat-file then                                          ~
      create temp-dis-kat-file.                                                        ~
      assign                                                                           ~
      temp-dis-kat-file.dis-kat   = 0                                                  ~
      .                                                                                ~
      assign                                                                           ~
      temp-dis-kat-file.temp-file = v-temp-kat-file                                    ~
      temp-dis-kat-file.send-file = v-kat-file                                         ~
      temp-dis-kat-file.to-send   = yes


if action = 'D':U then do:
  {&start-file}.
  V-NEXT = NO.
  if search(v-kat-file) <> ? then do:
    {&get-sav-param}.
  end.
  /*считываем имеющийся файл*/
  input stream bar from value(v-kat-file) convert source "ibm866" .
  /*открываем на запись новый файл*/
  output stream plucash to value(v-temp-kat-file) convert target "ibm866".
  _rr:
  repeat:
    import stream bar unformatted ss.
    ss0 = substring(ss, 1, 5).

    if not can-find(first cash-ncr-dis-kat where cash-ncr-dis-kat.cd-subject-code <= substring(ss, 1, 5))
    or can-find(first cash-ncr-save-param no-lock where
                      cash-ncr-save-param.dis-kat = 0
                  AND cash-ncr-save-param.cd-line = substring(ss, 1, 5))
    then do:
      /*это строчка не нашего типа или ее трогать нельзя*/
      /*просто перепишем ее*/
      put stream plucash unformatted
      ss skip.
      next _rr.
    end.

    /*ищем во временной таблице запись параметров*/
    find first buf_cash-ncr-dis-kat no-lock where
            buf_cash-ncr-dis-kat.cd-subject-code = substring(ss, 1, 5) no-error.
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
  IF V-NEXT THEN DO:
    {&end-file} .
  END.
end.
if action = 'U':U then do:
  {&start-file}.
  /*проверим что файл для данной категории скидок существует*/
  /*если нет то создадим пустой*/
  if search(v-kat-file) = ? then do:
    output stream bar to value(v-kat-file) convert target "ibm866" .
    put stream bar unformatted skip.
    output stream bar close.
  end.
  else do:
    {&get-sav-param}.
  end.
&scop put-ncr-par ~
      put stream plucash unformatted                                                                     ~
      buf_cash-ncr-dis-kat.cd-subject-code ':'                                                           ~
      buf_cash-ncr-dis-kat.cd-subject-name                                                               ~
      skip

  /*считываем имеющийся файл*/
  input stream bar from value(v-kat-file) convert source "ibm866" .
  /*открываем на запись новый файл*/
  assign
  ss0 = ''
  ss = '':U
  v-cd-subject-code = '':U
  v-next = no
  v-updated-subject-dis-kat = no
  .

  output stream plucash to value(v-temp-kat-file) convert target "ibm866".
  _rr2:
  repeat:
    /*считываем строчку*/
    import stream bar unformatted ss.
    if ss = '':U then next _rr2.
    assign
    v-next = no
    v-updated-subject-dis-kat = no
    v-cd-subject-code = substring(ss, 1, 5)
    .

    find first cash-ncr-dis-kat where
              cash-ncr-dis-kat.dis-kat = 0
          and  cash-ncr-dis-kat.cd-subject-code = v-cd-subject-code no-error .
    if not available cash-ncr-dis-kat
    then do:
      v-next = yes.
    end.
    _for_rr2:
    for each  buf_cash-ncr-dis-kat no-lock where
              buf_cash-ncr-dis-kat.dis-kat = 0
          AND buf_cash-ncr-dis-kat.cd-subject-code <= v-cd-subject-code
          AND buf_cash-ncr-dis-kat.cd-subject-code > ss0
          and crf <= cr-ncr-dis-kat
    by buf_cash-ncr-dis-kat.cd-subject-code
    by buf_cash-ncr-dis-kat.cd-disc-string
    :
      if buf_cash-ncr-dis-kat.cd-subject-code = v-cd-subject-code then do:
        v-updated-subject-dis-kat = yes.
      end.
      find first  cash-ncr-save-param no-lock where
                      cash-ncr-save-param.dis-kat = 0
                  AND cash-ncr-save-param.cd-line = buf_cash-ncr-dis-kat.cd-subject-code  no-error.
      if available cash-ncr-save-param then do:
        /*эту строчку трогать нельзя*/
        put stream plucash unformatted
        cash-ncr-save-param.cd-line
        cash-ncr-save-param.cd-other
        skip.
        NEXT _for_rr2.
      end.
      {&put-ncr-par}.
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
        /*если такого subejct в этой посылке не было - перепишем его в новый файл*/
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
            buf_cash-ncr-dis-kat.dis-kat = (if available cash-ncr-dis-kat then cash-ncr-dis-kat.dis-kat else 0)
        AND buf_cash-ncr-dis-kat.cd-subject-code > v-cd-subject-code
        and crf <= cr-ncr-dis-kat
  by buf_cash-ncr-dis-kat.cd-subject-code
  by buf_cash-ncr-dis-kat.cd-disc-string
  :
    find first  cash-ncr-save-param no-lock where
                  cash-ncr-save-param.dis-kat = 0
              AND cash-ncr-save-param.cd-line = buf_cash-ncr-dis-kat.cd-subject-code  no-error.
    if available cash-ncr-save-param then do:
      /*эту строчку трогать нельзя*/
      put stream plucash unformatted
      cash-ncr-save-param.cd-line
      cash-ncr-save-param.cd-other
      skip.
    end.
    else do:
      {&put-ncr-par}.
    end.
  end.
  output stream plucash close.
  {&end-file}.
end. /*if action = u */

/* $Workfile$ e n d */