/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Экспорт данных по ДК на IBM-XML

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/14/04
Author: Bakhtadze Natalya
Creation date: 12/14/04

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

run bgelib-tag-open in this-procedure ( input 2, input "Client"
                                      , input substitute("ctrl='&1' tms='&2' code='&3'"
                                      , if cash-cli.cli-code ne ? 
                                        then 'ADD':U  /*всегда ADD клиента а карту ингода DEL!!!*/
                                        else if action = "U"
                                        then 'ADD':U
                                        else "DEL":U 
                                      , OS2-time, if cash-cli.cli-code eq ?
                                                  then "*"
                                                  else string(cash-cli.cli-code + 1000000000 * cash-cli.justface))).

run bgelib-tag-put in this-procedure ( input 3, input "ClientName"       , input entry(1, cash-cli.cli-name, {&delim-par}), input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "ClientCity"       , input cash-cli.cli-city, input 1 ).

run bgelib-tag-put in this-procedure ( input 3, input "ClientAddress"    , input cash-cli.cli-adr, input 1 ).
if cash-cli.cli-type = {&cmp} then
run bgelib-tag-put in this-procedure ( input 3, input "ClientAddress2"   , input cash-cli.post-addr1,  input 1 ).

run bgelib-tag-put in this-procedure ( input 3, input "ClientIndex"      , input string(cash-cli.cli-ind), input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "ClientPhone"      , input cash-cli.cli-phone, input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "ClientINN"        , input cash-cli.cli-inn, input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "ClientKPP"        , input cash-cli.kpp, input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "ClientJustFace"   , input string(cash-cli.justface), input 1 ).

/*
run bgelib-tag-put in this-procedure ( input 3, input "ClientDisCat"     , input string(cash-cli.kat-pcnt), input 0 ).
run bgelib-tag-put in this-procedure ( input 3, input "ClientDisc"       ,
                                      input   string( if cash-cli.d-pcnt-byshop
                                              then (- v-d-pcnt)
                                              else ( - cash-cli.d-pcnt ) , "->>9.99" ) , input 0 ).
run bgelib-tag-put in this-procedure ( input 3, input "ClientSaldo"       , input cash-cli.current-saldo, input 0 ).
run bgelib-tag-put in this-procedure ( input 3, input "ClientLimit"       , input cash-cli.lim-kr, input 0 ).
*/
run bgelib-tag-put in this-procedure ( input 3, input "ClientLock"       ,
                                      input  string(if cash-cli.cli-status_ = 0 then 0 else 1), input 0 ).
run bgelib-tag-close in this-procedure ( input 2, input "Client").


  run bgelib-tag-open in this-procedure ( input 2, input "DiscountCard"
                                        , input substitute("ctrl='&1' tms='&2' code='&3'"
                                                           ,(if g#news or run-from = "O":U or run-from = "E":U
                                                             then
                                                                (if lookup({&current-status}, cash-cli.status_ ) > 0
                                                                 then "ADD":U
                                                                 else "DEL":U
                                                                 )
                                                             else (if action = "U"
                                                                   then (if lookup({&current-status}, cash-cli.status_ ) > 0
                                                                         then "ADD":U
                                                                         else "DEL":U)
                                                                   else "DEL":U
                                                                  )
                                                             )
                                                           , OS2-time 
                                                           , (if cash-cli.d-card eq ? 
                                                              then "*"
                                                              else string(cash-cli.d-card)))).
  run bgelib-tag-put in this-procedure ( input 3, input "DCClient"
                                        , input (cash-cli.cli-code + 1000000000 * cash-cli.justface)
                                        , input 0 ).
  run bgelib-tag-put in this-procedure ( input 3, input "DCSaldo"
                                                 , input  (if cash-cli.property-value-chr[1] <> '':U
                                                            then cash-cli.property-value-chr[1]
                                                            else string(cash-cli.current-saldo)
                                                          )
                                                  , input 0 ).
  run bgelib-tag-put in this-procedure ( input 3, input "DCLimit"     , input cash-cli.lim-kr, input 0 ).
  run bgelib-tag-put in this-procedure ( input 3, input "DCDisCat"     , input string(cash-cli.kat-pcnt), input 0 ).
  run bgelib-tag-put in this-procedure ( input 3, input "DCSaldo"     , input cash-cli.current-saldo, input 0 ).
  run bgelib-tag-put in this-procedure ( input 3, input "DCDisc"       ,
                                        input   string( if cash-cli.d-pcnt-byshop
                                                then (- v-d-pcnt)
                                                else ( - cash-cli.d-pcnt ) , "->>9.99" ) , input 0 ).

  if cash-cli.cli-message <> "":u
  and cash-cli.cli-message <> ?
  then
  run bgelib-tag-put in this-procedure ( input 3, input "DCMessage"     , input string(cash-cli.cli-message), input 1 ).
  if cash-cli.has-attrs = yes
  and v-version-dec >= 1.07
  then do:
    for each cash-cli-attr where
            cash-cli-attr.d-card = cash-cli.d-card:
      run bgelib-tag-open in this-procedure ( input 3
                                            , input "DCRestriction"
                                            , input '':U).
      run bgelib-tag-put in this-procedure ( input 4, input "DCRObjAttr"
                                            ,  input cash-cli-attr.dc-car-reg-number
                                            , input 0 ).
      run bgelib-tag-put in this-procedure ( input 4, input "DCRObjName"
                                            ,  input cash-cli-attr.dc-car-brand
                                            , input 0 ).
      run bgelib-tag-put in this-procedure ( input 4, input "DCRUnitCode"
                                            ,  input (if cash-cli-attr.dc-petrol-code > 0
                                                      then string(cash-cli-attr.dc-petrol-code)
                                                      else '')
                                            , input 0 ).
      run bgelib-tag-put in this-procedure ( input 4, input "DCRLimitType"
                                            ,  input (if cash-cli-attr.dc-limit-type = "sum"
                                                      then 2
                                                      else 1)
                                            , input 0 ).
      if cash-cli-attr.dc-limit-type = "sum" then do:
        run bgelib-tag-put in this-procedure ( input 4, input "DCRLimitValue"
                                              ,  input cash-cli-attr.dc-limit
                                              , input 0 ).

      end.
      else do:
        run bgelib-tag-put in this-procedure ( input 4, input "DCRLimitValue"
                                              ,  input cash-cli-attr.dc-limit-l
                                              , input 0 ).
      end.
      run bgelib-tag-close in this-procedure ( input 3, input "DCRestriction").
    end. /*for each cash-cli-attr where*/
  end.
  run bgelib-tag-close in this-procedure ( input 2, input "DiscountCard").
  if v-version-dec >= 1.11
  and cash-cli.card-media = integer({&dc-cm-ef}) then do:
    run bgelib-tag-open in this-procedure ( input 2
                                          , input "ACWhiteList"
                                          , input substitute("ctrl='&1' tms='&2' code='&3'"
                                                              ,(if action = "U"
                                                                then 'ADD':U
                                                                else "DEL":U
                                                                )
                                                              ,OS2-time
                                                              ,if cash-cli.d-card eq ? 
                                                               then "*"
                                                               else string(cash-cli.d-card)
                                                              )).
    run bgelib-tag-put in this-procedure ( input 3, input "ACWLCardVer"
                                          ,input cash-cli.ef-format
                                          ,input 0 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ACWLCardKey"
                                          ,input string(cash-cli.ef-access-key, "X(8)")
                                          ,input 0 ).
    define buffer buf_stop-list for ub.stop-list.
    define buffer buf_stop-list-line for ub.stop-list-line.
    for last buf_stop-list share-lock where
            buf_stop-list.classif-type = {&table_dis-card}
         and buf_stop-list.status_ = {&fact}
         use-index fact-order
        ,first buf_stop-list-line no-lock where
            buf_stop-list-line.classif-type =  {&table_dis-card}
        and buf_stop-list-line.stop-list-code = buf_stop-list.stop-list-code
        and buf_stop-list-line.charkey_one = cash-cli.d-card
        :
      leave.
    end.
    run bgelib-tag-put in this-procedure ( input 3, input "ACWLCardStop"
                                          ,input (if available buf_stop-list-line then
                                                  string("yes")
                                                  else string("no"))
                                          ,input 0 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ACWLCardAStop"
                                          ,input string("no")
                                          ,input 0 ).
    run bgelib-tag-close in this-procedure ( input 2, input "ACWhiteList").

  end.
if cash-cli.has-attrs-lim = yes
    then 
  do:
  define variable ii        as integer    no-undo .
  define variable v-sum-id  as character  no-undo .
  define variable v-group   as integer    no-undo .
    for each cash-cli-attr where
      cash-cli-attr.d-card = cash-cli.d-card and cash-cli-attr.dc-sum-id <> "" and cash-cli-attr.caller_id <> "":
             ii = 0 .
      run bgelib-tag-open in this-procedure ( input 2, input "CardClass"
                                            , input substitute("ctrl='&1' code='&2' tms='&3'"
                                            ,'ADD', cash-cli-attr.caller_id, OS2-time)
                                            ).
          run bgelib-tag-put in this-procedure ( input 3, input "CCRBegin"
                                                ,  input cash-cli-attr.dc-minnum
                                                , input 0 ).
          run bgelib-tag-put in this-procedure ( input 3, input "CCREnd"
                                                ,  input cash-cli-attr.dc-maxnum
                                                , input 0 ).
          run bgelib-tag-put in this-procedure ( input 3, input "CCNoUse"
                                                ,  input 0
                                                , input 0 ).
          run bgelib-tag-put in this-procedure ( input 3, input "CCClassCode"
                                                ,  input 0
                                                , input 0 ).
          run bgelib-tag-put in this-procedure ( input 3, input "CCClassNum"
                                                ,  input cash-cli-attr.caller_id
                                                , input 0 ).
          run bgelib-tag-put in this-procedure ( input 3, input "CCClassLen"
                                                ,  input 1
                                                , input 0 ).
      run bgelib-tag-close in this-procedure ( input 2, input "CardClass").
  
      run bgelib-tag-open in this-procedure ( input 2, input "ClassApproved"
                                            , input substitute("ctrl='&1' code='&2' tms='&3'"
                                            ,'ADD' , cash-cli-attr.caller_id, OS2-time )).  
                                            
      do ii = 1 to num-entries(cash-cli-attr.dc-sum-id):     
        assign
          v-sum-id = ""
          v-group = 0
          .                                       
          v-sum-id = entry(ii, cash-cli-attr.dc-sum-id) no-error.
          if ii = 1 then do: v-group = integer(entry(2,v-sum-id,"-")) no-error. end. else v-group = integer(v-sum-id). 
          run bgelib-tag-open in this-procedure ( input 3, input "CAGroup", input ""
                                                 ).    
                run bgelib-tag-put in this-procedure ( input 4, input "CAGNumber"
                                                      ,  input v-group
                                                      , input 0 ).    
                                         
          run bgelib-tag-close in this-procedure ( input 3, input "CAGroup").                                           
      end.
      run bgelib-tag-close in this-procedure ( input 2, input "ClassApproved").                                      
    end. /*for each cash-cli-attr where*/
  end.



/* $Workfile$ e n d */