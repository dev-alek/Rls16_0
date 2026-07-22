/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

вывод в поток информации для кассы IBM - товары

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/09/06
Author: Bakhtadze Natalya
Creation date: 02/09/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

if pos-type = {&cd-type-maria}  then do:
assign
IBM-good-code = "":U
.
run ibm-gdsc in this-procedure (input (pos-type = {&cd-type-maria} ) /*p-zeros*/
                              , output IBM-good-code
                              , output IBM-good-code-2
                              , output IBM2-short
                              ) no-error .
end.
else do:
  assign
  IBM-good-code = cash-gds.ean-lz
  IBM-good-code-2 = cash-gds.ean-rz
  IBM2-short = cash-gds.code-short
  .
end.
if IBM-good-code = "":U then
assign
IBM-good-code= IBM-good-code-2
.

&if "{1}" = "XML" &then
  if IBM-good-code <> "":U
&if "{&called}" <> "send-bc" and "{&called}" <> "send-bcn" and "{&called}" <> "s-prodbc" and "{&called}" <> "s-prodbcn" &then
  and ((cash-gds.b-str = "":U and cash-gds.b-code = cash-gds.main-prt-b-code)
       or
        LOOKUP( {&weight}, cash-gds.unit-cli-type ) > 0
       or
       (LOOKUP( {&divisional}, cash-gds.unit-cli-type ) > 0
        and
        LOOKUP( {&petrolium}, cash-gds.unit-cli-type ) > 0
       )
       or not can-find(first bcash-gds where
                             bcash-gds.main-prt-b-code = cash-gds.main-prt-b-code
                         and bcash-gds.obj-type = {&shop}
                         and bcash-gds.obj-code = abs(i-obj-code)
                         and bcash-gds.crf < cash-gds.crf)
       )
&endif
  then do:
  { str/xml-gds.i }
  end.
&else
do1:
do while IBm-good-code <> "":U:
    if pos-type = {&cd-type-maria}
    then do:
      v-b-code-to-find = no.
      v-what-find = (if cash-gds.b-str <> "":U
                    then cash-gds.b-str
                    else (if IBM-good-code <> IBM-good-code-2
                              then IBM2-short
                              else "":U)
                    ).

      if v-what-find = "":U then do:
        if pos-type = {&cd-type-maria} then do:
          v-b-code-to-find = yes.
          find first buf_cd-plu EXCLUSIVE-LOCK where
                    buf_cd-plu.obj-type = {&shop}
                and buf_cd-plu.obj-code = abs(i-obj-code)
                and buf_cd-plu.pos-type = {&cd-type-maria}
                and buf_cd-plu.plu-type = '':U
                AND buf_cd-plu.b-code = cash-gds.b-code
                AND buf_cd-plu.b-str  = '':U  NO-ERROR.
        end.
        if not v-b-code-to-find then do:
          if IBM-good-code = IBM-good-code-2 then do:
            leave do1.
          end.
          assign
          IBM-good-code = IBM-good-code-2
          .
          next do1.
        end.
      end. /*v-what-find = "":U*/
      if not v-b-code-to-find = yes then do:
        find first buf_cd-plu EXCLUSIVE-LOCK where
                    buf_cd-plu.obj-type = {&shop}
                and buf_cd-plu.obj-code = abs(i-obj-code)
                and buf_cd-plu.pos-type = {&cd-type-maria}
                and buf_cd-plu.plu-type = '':U
              AND buf_cd-plu.b-code = cash-gds.b-code
              AND buf_cd-plu.b-str  = v-what-find  NO-ERROR.
      end.
      if not available buf_cd-plu then do:
        if v-del-mrkt-gds = no then do:
          /*если посылка идет из справочника товаров на MARKETER то не ругаемся!!!*/
          if v-what-find <> "":U then
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name

              , input 1
              , input substitute("!!!Бар-код &1 ДопБК/лок.EAN &2 не включен в число ТОВАРОВ НА КАССЕ &3 &4&5&6" +
                                  "пропускается...."
                                  , cash-gds.b-code
                                  , v-what-find
                                  , pos-type
                                  , {&shop}
                                  , i-obj-code
                                  , {&new-line}
                                  )
                                    ).
        end.
        if IBM-good-code = IBM-good-code-2 then do:
          leave do1.
        end.
        assign
        IBM-good-code = IBM-good-code-2
        .
        next do1.
      end.
      assign
      v-plu = TRIM(string( buf_cd-plu.plu-code), "X(40)":U ).
    end. /*if pos-type = {&cd-type-maria}*/
    if pos-type = {&cd-type-maria} then do:
      { str/mariagds.i
      &cd-buffer=buf_cash-desk
      }
    end. /*cd-type-maria*/
    else do:
      put stream IBMStream unformatted
      '0 "'
      string(  action, "x(1)" )
      '" '
      IBM-good-code
      " "
      second-name      {&space-char}
      string(cash-gds.grp-code, ">>9")
      ' "'
      chk_name
      '" '
      string( cash-gds.price-sale , ">>>>>>>>>9.99" )
      {&space-char}
      string(std-disc-dec, "->9.99")     /* % скидки */
      {&space-char}
      string( cash-gds.gds-stat, ">>9" ) /* статус товара */
      {&space-char}
      (
      if p-cash-os = "LINUX":U or cd-vat = 0
      then string(cash-gds.vat-pc, ">9.99")
      else "0":U
      )
      /* % НДС */
      {&space-char}
      string( temp-disc-dec, "->>9.99")     /* % ночной скидки */
      " "
      OS2-time
      {&new-line} .
      if tax-cass AND action = "U" then do:
          PUT stream IBMstream unformatted
          '14 "'
          string( action, "x(1)" )
          '" '
          IBM-good-code
          ' '
          cash-gds.tax-string
          {&new-line}.
      end.
      { str/putc-7-0.i " string(action, 'x(1)')  "  1 }
  end. /*ne maria*/
  if IBM-good-code = IBM-good-code-2 then leave do1.
  assign
  IBM-good-code = IBM-good-code-2
  .
end. /* do */
&endif

 /* $Workfile$ e n d */