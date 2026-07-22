block-level on error undo, throw.
/*

$Revision: f29df1d5f130, 3104, rls $
$Author: DRuban $
$Date: Вт авг 09 09:15:01 2022 +0300 $
$Workfile: gds-atrw.p $
$Archive: trg/gds-atrw.p $

Триггер на запись goods-attr

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/12/04
Author: Bakhtadze Natalya
Creation date: 04/12/04

*/

TRIGGER PROCEDURE FOR WRITE OF ub.goods-attr OLD old-goods-attr .
 
define variable vss-revision    as character no-undo init "$Revision: f29df1d5f130, 3104, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: Вт авг 09 09:15:01 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gds-atrw.p $":U .
define variable vss-archive     as character no-undo init "$Archive: trg/gds-atrw.p $":U .
define variable vss-description as character no-undo init "Триггер на запись атрибутов товара".
{ cmp/vssrevis.i "substitute('&1|&2', ub.goods-attr.gds-code, ub.goods-attr.attr-code) " }

{ cmp/trg-def.i }
{ ref/gds-attr.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }
{ gbl/getcntxa.i }

define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable p-news as logical no-undo.
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-manual-editing as integer no-undo .
define variable v-type           as character no-undo .
define variable v-format         as character no-undo .
define variable v-label          as character no-undo .
define variable v-user-can-edit  as logical   no-undo .
define variable v-output-display as logical   no-undo .
define variable v-other          as character no-undo .
define variable jj as integer no-undo .
define variable v-dop1 as character no-undo .
define variable v-dop2 as character no-undo .
define variable sendGoods2Kassa as logical no-undo init false.
define variable vError as character no-undo .
define variable vOk    as logical no-undo init false.
define buffer buf_goods for ub.goods.
define buffer buf_gds-obj for ub.gds-obj.
define buffer buf_c-goods-attr for ub.c-goods-attr.
define buffer buf_c-goods-attr-any for ub.c-goods-attr-any.
define buffer buf_c-gds-hist for ub.c-gds-hist.
define buffer locked_goods-attr for ub.goods-attr.

    
{ gbl/objsrv.i }
define variable v-ban-recipes as logical no-undo init false.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if not ub.goods-attr.attr-code = {&attr-gds-attr-lock} then do:

    run gds-attr-manual-edit in this-procedure (
                                                    input ub.goods-attr.attr-code
                                                    ,output v-manual-editing
                                                    ) no-error .
    if not error-status:error
    and v-manual-editing > 0 then do:
       Find first locked_goods-attr exclusive-lock  where
                  locked_goods-attr.gds-code = ub.goods-attr.gds-code
              and locked_goods-attr.attr-code = {&attr-gds-attr-lock}
        no-error no-wait.
        if locked locked_goods-attr then
           undo main-block, return error substitute("&1&2Атрибут товара &3 &4 занят"
                                              , {&attr-gds-attr-lock}
                                              , {&delim-par}
                                              , ub.goods-attr.attr-code
                                              , ub.goods-attr.gds-code
                                                 ).

    end.
    if lookup( ub.goods-attr.attr-code,  {&struct-attr-list}) > 0
    then do:
      find first buf_goods no-lock where buf_goods.gds-code = ub.goods-attr.gds-code no-error.
      if available buf_goods then do:
             { ref/scgdsupd.i buf_goods " " " " ?  ub.goods-attr.attr-code }
      end.
      
    end.
    if g#news then do:
      define variable v-send as integer no-undo .
      v-send = integer({&hn-is-on}).
      { gbl/get-hn.i
      g#db-num
      {&table_goods-attr}
      0
      '':U
      0
      '':U
      '':U
      '':U
      0
      0
      0
      {&nws-to-hist}
      v-send
      no-error
      }
    end.
    if not g#news
    or v-send >= 0 then do:
      run cur-time in this-procedure(output v-date, output v-time).
      create buf_c-goods-attr.
      buffer-copy old-goods-attr to buf_c-goods-attr
      assign
      buf_c-goods-attr.gds-code           = ub.goods-attr.gds-code
      buf_c-goods-attr.chip-num           = next-value (s-gds-chip, {&db-name_schema})
      buf_c-goods-attr.attr-code          = ub.goods-attr.attr-code
      buf_c-goods-attr.corr-time          = v-time
      buf_c-goods-attr.corr-user-db-num   = g#db-num
      buf_c-goods-attr.corr-user-name     = (if g#news
                                      then {&nts-user}
                                      else (if g#esys
                                            then {&esys-user}
                                            else g#userid)
                                      )
      buf_c-goods-attr.corr-date          = v-date 
      .
      create buf_c-gds-hist.
      buffer-copy buf_c-goods-attr to buf_c-gds-hist
      assign
      buf_c-gds-hist.action = (if new ub.goods-attr then integer({&hn-create}) else integer({&hn-update}))
      buf_c-gds-hist.subject = {&table_goods-attr}
      buf_c-gds-hist.is-news = g#news
      buf_c-gds-hist.source-type = (if g#news
                                  then {&hn-source-db}
                                  else (if g#esys
                                        then {&hn-source-esys}
                                        else "":U)
                                  )
      buf_c-gds-hist.source-ref = (if g#news
                                  then string(g#news-source-db)
                                  else (if g#esys
                                        then string(g#esys-source-esys)
                                        else "":U)
                                  )
      .
      if    ub.goods-attr.attr-code eq "operservid"
         or ub.goods-attr.attr-code eq "cashbookid"
      then do:
         if     ub.goods-attr.attr-value ne ""
            and ub.goods-attr.attr-value ne ?
         then do:
            create buf_c-goods-attr-any.
            buffer-copy goods-attr to buf_c-goods-attr-any
            assign
               buf_c-goods-attr-any.gds-code           = ub.goods-attr.gds-code
               buf_c-goods-attr-any.Bush               = if ub.goods-attr.attr-code eq "operservid"
                                                         then
                                                            "operserv"
                                                         else
                                                            "cashbook"
               buf_c-goods-attr-any.chip-num           = if ub.goods-attr.attr-code eq "operservid"
                                                         then
                                                            next-value (s-c-operserv-chip-num, {&db-name_schema})
                                                         else
                                                            next-value (s-c-cashbook-chip-num, {&db-name_schema})   
               buf_c-goods-attr-any.attr-code          = ub.goods-attr.attr-code
               buf_c-goods-attr-any.corr-time          = v-time
               buf_c-goods-attr-any.corr-user-db-num   = g#db-num
               buf_c-goods-attr-any.corr-user-name     = (if g#news
                                                          then {&nts-user}
                                                          else (if g#esys
                                                          then {&esys-user}
                                                          else g#userid)
                                                         )
               buf_c-goods-attr-any.corr-date          = v-date
               buf_c-goods-attr-any.action             = {&bef-hn-create}
            .
            if ub.goods-attr.attr-code eq "cashbookid"
            then do:
               create c-cashbook-head.
               buffer-copy  buf_c-goods-attr-any to c-cashbook-head
               assign
                  c-cashbook-head.subject = "c-goods-attr-any"
                  c-cashbook-head.cashbookid     = int64(buf_c-goods-attr-any.attr-value)
                  c-cashbook-head.is-news = g#news
                  c-cashbook-head.source-type = (if g#news
                                                 then {&hn-source-db}
                                                 else (if g#esys
                                                 then {&hn-source-esys}
                                                 else "":U)
                                                ) 
                  c-cashbook-head.source-ref = (if g#news
                                                then string(g#news-source-db)
                                                else (if g#esys
                                                then string(g#esys-source-esys)
                                                else "":U)
                                               )

               .
            end.
         end.
      end.
      if    ub.old-goods-attr.attr-code eq "operservid"
         or ub.old-goods-attr.attr-code eq "cashbookid"
      then do:
         if     ub.old-goods-attr.attr-value ne ""
            and ub.old-goods-attr.attr-value ne ?
         then do:
            create buf_c-goods-attr-any.
            buffer-copy old-goods-attr to buf_c-goods-attr-any
            assign
               buf_c-goods-attr-any.gds-code           = ub.old-goods-attr.gds-code
               buf_c-goods-attr-any.Bush               = if ub.old-goods-attr.attr-code eq "operservid"
                                                         then
                                                            "operserv"
                                                         else
                                                            "cashbook"
               buf_c-goods-attr-any.chip-num           = if ub.old-goods-attr.attr-code eq "operservid"
                                                         then
                                                            next-value (s-c-operserv-chip-num, {&db-name_schema})
                                                         else
                                                            next-value (s-c-cashbook-chip-num, {&db-name_schema})   
               buf_c-goods-attr-any.attr-code          = ub.old-goods-attr.attr-code
               buf_c-goods-attr-any.corr-time          = v-time
               buf_c-goods-attr-any.corr-user-db-num   = g#db-num
               buf_c-goods-attr-any.corr-user-name     = (if g#news
                                                          then {&nts-user}
                                                          else (if g#esys
                                                  then {&esys-user}
                                                  else g#userid)
                                            )
               buf_c-goods-attr-any.corr-date          = v-date
               buf_c-goods-attr-any.action             = {&bef-hn-delete}
            .
            if ub.goods-attr.attr-code eq "cashbookid"
            then do:
               create c-cashbook-head.
               buffer-copy  buf_c-goods-attr-any to c-cashbook-head
               assign
                  c-cashbook-head.subject = "c-goods-attr-any"
                  c-cashbook-head.cashbookid      = int64(buf_c-goods-attr-any.attr-value)
                  c-cashbook-head.is-news = g#news
                  c-cashbook-head.source-type = (if g#news
                                                 then {&hn-source-db}
                                                 else (if g#esys
                                                 then {&hn-source-esys}
                                                 else "":U)
                                                ) 
                  c-cashbook-head.source-ref = (if g#news
                                                then string(g#news-source-db)
                                                else (if g#esys
                                                then string(g#esys-source-esys)
                                                else "":U)
                                               )

               .
            end.
         end.
      end.
    find first ub.clients no-lock where ub.clients.obj-type = {&shop} and ub.clients.db-num = g#db-num no-error .
    if available (ub.clients) then do:  
    if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(ub.clients.obj-type, ub.clients.obj-code):IsBanRecipes then v-ban-recipes = true .
    end.
    if v-ban-recipes then do:
    if ub.goods-attr.attr-code = {&attr-mark-type} and ub.goods-attr.attr-value <> "not-type" and 
       ub.goods-attr.attr-value <> "" then 
         do:
{ str/promoMark.i }
         end. 
     end.       
    end.
    run gds-attr-news in this-procedure(input ub.goods-attr.attr-code,
                                        output p-news) no-error.
    if p-news then do:
      run str/callnews.p
        ( input {&table_goods-attr}
        ,input (buffer ub.goods-attr:handle )
        ) .
    end.

    if g#oxml = yes
    then do:
      run str/calloxml.p (
            input {&nwsdochs_action_update}
          , input {&table_goods-attr}
          , input ( buffer ub.goods-attr:handle )
      ) no-error.
      if error-status :error
      then do:
          undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                              , {&new-line}
                              , vss-workfile
                              , return-value
                              , error-status :get-message ( 1 ) ).
      end.
    end.
    
    /* При изменении атрибута выполним валидацию и проверим отправку товара на кассу  */
/*    if ub.goods-attr.attr-code = {&attr-type-method-calc} then run gbl/inidebug.p.*/
    if ub.goods-attr.attr-value <> old-goods-attr.attr-value then
    do:
        { ref/send-ref.i conf-par par-type }
        if send-ref /*and (g#esys or g#news)*/ then do:
           run gds-attr-name in this-procedure (
                                                input  ub.goods-attr.attr-code
                                                ,output v-type
                                                ,output v-format
                                                ,output v-label
                                                ,output v-user-can-edit
                                                ,output v-output-display
                                                ,output v-other
            ) .
           _do:
           do jj = 1 to num-entries(v-other, {&slash-char}):
             if entry(jj, v-other, {&slash-char}) = "" then NEXT _do.
             assign
             v-dop1 = entry(1, entry(jj, v-other, {&slash-char}), '=':U)
             v-dop2 = if num-entries(entry(jj, v-other, {&slash-char}), '=':U) > 1 
                      then entry(2, entry(jj, v-other, {&slash-char}), '=':U)
                      else ""
             .
             if v-dop1 = "check":U  then do:
               run value(v-dop2) in this-procedure (
                  ub.goods-attr.gds-code,
                  ub.goods-attr.attr-code,
                  ub.goods-attr.attr-value,
                  if avail old-goods-attr then {&update} else {&add-def},
                  output vOk,
                  output vError
               ) no-error.
               if error-status:error or not vOk then
               do:
                 undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                                     , {&new-line}
                                     , vss-workfile
                                     , vError
                                     , error-status :get-message ( 1 ) ).
               end.
             end.
             if v-dop1 = "cd":U then do:
               run trg/nu_gds.p (
                              input  ub.goods-attr.gds-code
                              ,input  0
                              ,input ""
                              ,input  0
                              ,input  "U":U
                            ).
               sendGoods2Kassa = true.
               NEXT _do.
             end.
           end.
/*           if sendGoods2Kassa then                         */
/*           run str/diallog.w ( this-procedure              */
/*               , this-procedure                            */
/*               , 'str/sendalcd.p':U                        */
/*               , ('yes' + {&delim-par} +                   */
/*                  'no' + {&delim-par} +                    */
/*                  'no' + {&delim-par} +                    */
/*                  'no' + {&delim-par}  +                   */
/*                  'no' + {&delim-par}                      */
/*                  )                                        */
/*               , no /*p-auto-go*/                          */
/*               , 'Прервать':U                              */
/*               , 'Отправка информации на кассу') no-error .*/
        end. /*if send-ref*/
    end.
  end.
end.