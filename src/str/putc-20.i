/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

вывод в поток информации о типах диск карт - масках

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/04/03
Author: Bakhtadze Natalya
Creation date: 12/04/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE putc-dis-card-mask.
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-pos-type as character no-undo.
define input parameter p-version as character no-undo .

define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-version-dec as decimal no-undo .
define variable v-reg-cahs  as integer  no-undo .
&if "{1}" eq ""
&then
define buffer buf_dis-card-mask for ub.dis-card-mask.
define buffer buf_dis-card-mask-attr  for ub.dis-card-mask-attr.
define buffer buf_dis-card-type for ub.dis-card-type.
define buffer bf_dis-card-type for ub.dis-card-type.
&else
define buffer dis-card for dc-list.
define buffer buf_dis-card-mask for {1}-mask.
define buffer buf_dis-card-mask-attr  for {1}-mask-attr.
define buffer buf_dis-card-type for ub.dis-card-type.
define buffer bf_dis-card-type for ub.dis-card-type.
&endif
{ gbl/hostcode.i p-obj-type i-obj-code v-host-code }
assign
v-version-dec = decimal(p-version) no-error .
&if "{1}" eq ""
&then
    if     choice     eq 4
       and p-pos-type eq {&cd-type-IBM-XML} 
    then do:
        run bgelib-tag-open in this-procedure ( input 2, input "MaskCard"
            , input substitute("code='&1' ctrl='&2' tms='&3'", "*"
            ,(if action = "U":U then 'ADD':U else 'DEL')
            ,OS2-time)).
        run bgelib-tag-close in this-procedure ( input 2, input "MaskCard").
    end.
else
&endif
_mask:
for each buf_dis-card-mask no-lock where
      buf_dis-card-mask.host-code = 0
    OR (buf_dis-card-mask.host-code = v-host-code
        AND buf_dis-card-mask.obj-code = 0)
    or (buf_dis-card-mask.obj-type = p-obj-type
        AND
        buf_dis-card-mask.obj-code = i-obj-code)
&if "{1}" eq ""
&then  
        ,
   first buf_dis-card-type no-lock where
         buf_dis-card-type.emitent-host-code = buf_dis-card-mask.emitent-host-code
     AND buf_dis-card-type.type              = buf_dis-card-mask.type    :
  if choice = 2 then do:
    find first temp-dis-card-mask no-lock where
              temp-dis-card-mask.mask-num = buf_dis-card-mask.mask-num no-error .
    if not available temp-dis-card-mask then next _mask.
  end.
&else
  :
&endif
  if buf_dis-card-mask.use-on = integer({&dcm-only-th}) then next.
  find first buf_dis-card-mask-attr no-lock where buf_dis-card-mask-attr.attr-code = "reg-cash" and buf_dis-card-mask-attr.mask-num = buf_dis-card-mask.mask-num no-error .
  if available (buf_dis-card-mask-attr) then do:
   if buf_dis-card-mask-attr.attr-value = "yes" then v-reg-cahs = 1 .
   else v-reg-cahs = 0 .
  end.
  else do: 
  
  &if "{1}" eq ""
  &then  
  v-reg-cahs = 0 .
  &else
  
  find first dis-card-mask-attr no-lock where dis-card-mask-attr.attr-code = "reg-cash" and dis-card-mask-attr.mask-num = buf_dis-card-mask.mask-num no-error .
  if available (dis-card-mask-attr) then do:
   if dis-card-mask-attr.attr-value = "yes" then v-reg-cahs = 1 .
   else v-reg-cahs = 0 .
  end.
  else v-reg-cahs = 0 .
  &endif
  end.
   
    
  find first dis-card no-lock where
             dis-card.d-card = buf_dis-card-mask.mask no-error .
  if available dis-card and
  buf_dis-card-mask.cli-code <> 0 then do:
    find first ub.clients no-lock where
              ub.clients.obj-type = buf_dis-card-mask.cli-type
        AND  ub.clients.obj-code = buf_dis-card-mask.cli-code no-error .
    if not available ub.clients then next _mask.
    find first ub.dis-card-type no-lock where
              ub.dis-card-type.type = buf_dis-card-mask.type
          AND ub.dis-card-type.emitent-host-code = buf_dis-card-mask.emitent-host-code
                no-error .
     &if "{1}" eq ""
     &then              
    { str/cash-c-i.i "mask" }
     &endif
    if buf_dis-card-mask.cli-code  = 0 then do:
      find first cash-cli no-lock where
                cash-cli.cli-type = buf_dis-card-mask.cli-type
            AND cash-cli.cli-code = buf_dis-card-mask.cli-code no-error .
    end.
    else do:
      find first cash-cli no-lock where
                cash-cli.d-card = buf_dis-card-mask.mask
             no-error .
    end.
     &if "{1}" eq ""
     &then              

    if available cash-cli then do:
 
        RUN putc-2 in this-procedure ( buffer buf_cash-desk
                                      ,input p-pos-type
                                      ,input p-version
                                      ,input yes  ) no-error .
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
    &endif
  end.
  
  { gbl/objdpcnt.i
    buf_dis-card-mask.type
    buf_dis-card-mask.emitent-host-code
    0
    '':U
    0
    {&ddctr-def-pcnt}
    v-d-pcnt0
  }
  { gbl/objdpcnt.i
    buf_dis-card-mask.type
    buf_dis-card-mask.emitent-host-code
    0
    '':U
    0
    {&ddctr-def-pcnt}
    v-cash-d-pcnt0
  }
  { gbl/objdpcnt.i
    buf_dis-card-mask.type
    buf_dis-card-mask.emitent-host-code
    0
    '':U
    0
    {&ddctr-def-categ}
    v-categ0
  }
  if v-d-pcnt0 = ? then do:
    v-d-pcnt0 = 0.
  end.
  if v-cash-d-pcnt0 = ? then do:
    v-cash-d-pcnt0 = 0.
  end.
  if v-categ0 = ? then do:
    v-categ0 = 0.
  end.
&if "{1}" eq ""
  &then  
  if available cash-cli and cash-cli.d-pcnt-byshop then do:
    v-d-pcnt = decimal(trim(get-dpcn ( input cash-cli.d-card
                      , input cash-cli.emitent-host-code
                      , input cash-cli.type
                      , input ub.sysconf.host-code
                      , input {&shop}
                      , input (if g#news
                                or g#esys
                                then buf_cash-desk.obj-code
                                else i-obj-code)
                      , input {&dc_prop_discount_d-pcnt}
                      , input cash-cli.d-pcnt
                      , input cash-cli.cash-d-pcnt
                      , input cash-cli.kat-pcnt), "%()i ")).
    v-cash-d-pcnt = decimal(trim(get-dpcn ( input cash-cli.d-card
                      , input cash-cli.emitent-host-code
                      , input cash-cli.type
                      , input ub.sysconf.host-code
                      , input {&shop}
                      , input (if g#news
                                or g#esys
                                then buf_cash-desk.obj-code
                                else i-obj-code)
                      , input {&dc_prop_discount_d-pcnt}
                      , input cash-cli.d-pcnt
                      , input cash-cli.cash-d-pcnt
                      , input cash-cli.kat-pcnt), "%()i ")).
    v-categ = integer(trim(get-dpcn ( input cash-cli.d-card
                      , input cash-cli.emitent-host-code
                      , input cash-cli.type
                      , input ub.sysconf.host-code
                      , input {&shop}
                      , input (if g#news
                                or g#esys
                                then buf_cash-desk.obj-code
                                else i-obj-code)
                      , input {&dc_prop_discount_d-pcnt}
                      , input cash-cli.d-pcnt
                      , input cash-cli.cash-d-pcnt
                      , input cash-cli.kat-pcnt), "%()i ")).
  end.
  &endif
  CASE p-pos-type:
    when {&cd-type-ibm} then do:
      /*предварительно уже послали САМОГО КЛИЕНТА для карты*/
      put stream IBMStream unformatted
      '20' {&space-char}
      {&double-quote} string( action, "x(1)" ) {&double-quote} {&space-char}
      string(buf_Dis-card-mask.rank) {&space-char}
      /*сама маска*/
      {&double-quote}
      string( fill( {&space-char} , 19 - length(trim(string(BUF_DIS-CARD-MASK.mask)))
                  ) + buf_dis-card-mask.mask
            )
      {&double-quote} {&space-char}
      /*тип маски*/
      (if v-version-dec >= 4.54
      then 5
      else (if buf_dis-card-mask.cli-code <> 0
            then 2
            else 1)
      ) {&space-char}
      /*правило поиска дисконтного кода, кода клиента категориии % скидки*/
      {&double-quote}
      (if buf_dis-card-mask.cli-mask <> '':U
      then replace(buf_dis-card-mask.cli-mask, 'C', {&question-mark})
      else string(fill( {&space-char}, 19)))  {&double-quote}  {&space-char}

      /*код клиента */
      {&double-quote}
      (if buf_dis-card-mask.cli-code <> 0
      then string( fill( {&space-char} , 16 - length( trim(string((if BUF_DIS-CARD-MASK.cli-type = {&cmp} then 1 else 0) * 1000000000 + BUF_DIS-CARD-MASK.cli-code ) ) ) )
            + string((if BUF_DIS-CARD-MASK.cli-type = {&cmp} then 1 else 0) * 1000000000 + BUF_DIS-CARD-MASK.cli-code)
            )
      else string(fill( {&space-char}, 15) + "0":U)
      )  {&double-quote}  {&space-char}

      /*скидка в %*/
      (if available cash-cli
      then string( if cash-cli.d-pcnt-byshop and avail bf_dis-card-type
              then (- v-d-pcnt)
              else ( - cash-cli.d-pcnt ) , "->>9.99" )
      else string(- v-d-pcnt0, "->>9.99")
      )  {&space-char}

      /*категория скидки*/
      (if available cash-cli
      then  string( cash-cli.kat-pcnt, ">>>9" )
      else  string(v-categ)
      )  {&space-char}

      Os2-time
      {&new-line}.
    end.
    when {&cd-type-IBM-XML} then do:
      run bgelib-tag-open in this-procedure ( input 2, input "MaskCard"
                                            , input substitute("code='&1' ctrl='&2' tms='&3'", buf_dis-card-mask.rank
                                            ,(if action = "U":U then if buf_dis-card-mask.stts eq {&bef-current-status-int}
                                                                     then 'ADD'
                                                                     else 'DEL' 
                                              else 'DEL')
                                            ,OS2-time)).
      run bgelib-tag-put in this-procedure ( input 3, input "MCCard", input buf_dis-card-mask.mask, input 1 ).
      if v-version-dec >= 1.05 then do:
        run bgelib-tag-put in this-procedure ( input 3, input "MCType", input string(5), input 1 ).
      end.
      else do:
        if buf_dis-card-mask.cli-code  = 0
        then
        run bgelib-tag-put in this-procedure ( input 3, input "MCType", input string(1), input 1 ).
        else
        run bgelib-tag-put in this-procedure ( input 3, input "MCType", input string(2), input 1 ).
      end.
      if buf_dis-card-mask.cli-mask <> '':U
      then
      run bgelib-tag-put in this-procedure ( input 3, input "MCRule"
                                            , input  replace(buf_dis-card-mask.cli-mask, 'C', {&question-mark})
                                            , input 1 ).
      if buf_dis-card-mask.cli-code <> 0
      then
      run bgelib-tag-put in this-procedure ( input 3, input "MCClient"
                                            , input  string((if buf_dis-card-mask.cli-type = {&cmp} then 1 else 0) * 1000000000 + buf_dis-card-mask.cli-code)
                                            , input 1 ).
      if available cash-cli
      then
      run bgelib-tag-put in this-procedure ( input 3, input "MCValue"
                                           , input  string( if cash-cli.d-pcnt-byshop and avail bf_dis-card-type
                                                            then (- v-d-pcnt)
                                                            else ( - cash-cli.d-pcnt ) , "->>9.99" )
                                           , input 1 ).

      else
      run bgelib-tag-put in this-procedure ( input 3, input "MCValue", input string(- v-d-pcnt0, "->>9.99"), input 1 ).

      if available cash-cli
      then
      run bgelib-tag-put in this-procedure ( input 3, input "MCCat", input string( cash-cli.kat-pcnt, ">>>9" ), input 1 ).

      else
      run bgelib-tag-put in this-procedure ( input 3, input "MCCat", input string(v-categ0), input 1 ).

      run bgelib-tag-put in this-procedure ( input 3, input "MCLock"
                                          , input string(0), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "MCBarRead", input string(v-reg-cahs), input 1 ).                                          
      run bgelib-tag-close in this-procedure ( input 2, input "MaskCard").
    end.

  END CASE .
END.
END PROCEDURE .


/* $Workfile$ e n d */