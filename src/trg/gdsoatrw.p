block-level on error undo, throw.
/*

$Revision: e455fc319afd, 3602, rls $
$Author: ARostovtsev $
$Date: 2023/12/28 12:56:37 $
$Workfile: gdsoatrw.p $
$Archive: trg/gdsoatrw.p $

Триггер на запись gds-obj-attr

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/10/05
Author: Bakhtadze Natalya
Creation date: 10/10/05

*/

TRIGGER PROCEDURE FOR WRITE OF ub.gds-obj-attr OLD oldgds-obj-attr.

define variable vss-revision    as character no-undo init "$Revision: e455fc319afd, 3602, rls $":U .
define variable vss-author      as character no-undo init "$Author: ARostovtsev $":U .
define variable vss-date        as character no-undo init "$Date: 2023/12/28 12:56:37 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gdsoatrw.p $":U .
define variable vss-archive     as character no-undo init "$Archive: trg/gdsoatrw.p $":U .
define variable vss-description as character no-undo init "Триггер на запись gds-obj-attr".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ ref/gdsoattr.i trigger }
{ gbl/cur-time.i }
{ nws/lib-nws.i }
{ gbl/getcntxa.i }

define variable p-news as logical no-undo.
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable v-type           as character no-undo .
define variable v-format         as character no-undo .
define variable v-label          as character no-undo .
define variable v-user-can-edit  as logical   no-undo .
define variable v-output-display as logical   no-undo .
define variable v-other          as character no-undo .
define variable jj as integer no-undo .
define variable v-dop1 as character no-undo .
define variable v-dop2 as character no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-manual-editing as integer no-undo .
define variable dbNum as integer no-undo .
define variable listPromoIds as character no-undo .
define variable sendGoods2Kassa as logical no-undo init false.
define buffer buf_c-gds-obj-attr for ub.c-gds-obj-attr.
define buffer buf_c-gds-hist for ub.c-gds-hist.
define buffer buf_gds-obj for ub.gds-obj.
define buffer locked_gds-obj-attr for ub.gds-obj-attr.
define buffer PromoGoods  for ub.PromoGoods.
define buffer PromoAction for ub.PromoAction.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not ub.gds-obj-attr.attr-code = {&attr-gds-obj-attr-lock-o} then do:
    run gdsoattr-manual-edit in this-procedure (
                                                    input ub.gds-obj-attr.attr-code
                                                    ,output v-manual-editing
                                                    ) no-error .
     if not error-status:error
     and v-manual-editing > 0 then do:
      Find first locked_gds-obj-attr exclusive-lock  where
              locked_gds-obj-attr.gds-code = ub.gds-obj-attr.gds-code
          AND locked_gds-obj-attr.obj-type = ub.gds-obj-attr.obj-type
          AND locked_gds-obj-attr.obj-code = ub.gds-obj-attr.obj-code
          and locked_gds-obj-attr.attr-code = {&attr-gds-obj-attr-lock-o}
          no-error no-wait.
      if locked locked_gds-obj-attr then
      undo main-block, return error substitute("&1&2Атрибут товара на объекте &3 товар &4 &5&6 занят"
                                               , {&attr-gds-obj-attr-lock-o}
                                               , {&delim-par}
                                               , ub.gds-obj-attr.attr-code
                                               , ub.gds-obj-attr.gds-code
                                               , ub.gds-obj-attr.obj-type
                                               , ub.gds-obj-attr.obj-code).


     end.

     { ref/send-ref.i conf-par par-type }
     if send-ref and not g#news then do:
       run gdsoattr-name in this-procedure (
                                            input  ub.gds-obj-attr.attr-code
                                            ,output v-type
                                            ,output v-format
                                            ,output v-label
                                            ,output v-user-can-edit
                                            ,output v-output-display
                                            ,output v-other
        ) .
       _do:
       do jj = 1 to num-entries(v-other, {&slash-char}):
         assign
         v-dop1 = entry(1, entry(jj, v-other, {&slash-char}), '=':U)
         v-dop2 = entry(2, entry(jj, v-other, {&slash-char}), '=':U)
         .
         if v-dop1 = "cd":U then do:
           find first buf_gds-obj no-lock where
                  buf_gds-obj.gds-code = ub.gds-obj-attr.gds-code
              AND buf_gds-obj.obj-type = ub.gds-obj-attr.obj-type
              AND buf_gds-obj.obj-code = ub.gds-obj-attr.obj-code no-error .
          if available buf_gds-obj
          and buf_gds-obj.price-sale <> ?
          and buf_gds-obj.price-sale <> 0
          then do:
            run trg/nu_gds.p (
                          input  ub.gds-obj-attr.gds-code
                          ,input  0
                          ,input  ub.gds-obj-attr.obj-type
                          ,input  ub.gds-obj-attr.obj-code
                          ,input  "U":U
                        ).
            sendGoods2Kassa = true.
          end.
          NEXT _do.
         end.
         { trg/gdsoatr_send2kassa.i "getPromoIds"}
       end.
    end. /*if send-ref*/
    if g#news then do:
      define variable v-send as integer no-undo .
      v-send = integer({&hn-is-on}).
      { gbl/get-hn.i
      g#db-num
      ~{&table_gds-obj-attr~}
      0
      '':U
      0
      '':U
      '':U
      '':U
      0
      0
      0
      ~{&nws-to-hist~}
      v-send
      no-error
      }
    end.
    if not g#news
    or v-send >= 0 then do:
      run cur-time in this-procedure(output v-date, output v-time).
      create buf_c-gds-obj-attr.
      buffer-copy oldgds-obj-attr to buf_c-gds-obj-attr
      assign
      buf_c-gds-obj-attr.gds-code           = ub.gds-obj-attr.gds-code
      buf_c-gds-obj-attr.obj-type           = ub.gds-obj-attr.obj-type
      buf_c-gds-obj-attr.obj-code           = ub.gds-obj-attr.obj-code
      buf_c-gds-obj-attr.attr-code          = ub.gds-obj-attr.attr-code
      buf_c-gds-obj-attr.chip-num           = next-value (s-gds-chip, {&db-name_schema})
      buf_c-gds-obj-attr.corr-time          = v-time
      buf_c-gds-obj-attr.corr-user-db-num   = g#db-num
      buf_c-gds-obj-attr.corr-user-name     = (if g#news
                                        then {&nts-user}
                                        else (if g#esys
                                              then {&esys-user}
                                              else g#userid)
                                        )
      buf_c-gds-obj-attr.corr-date          = v-date
      .
      { gbl/hostcode.i ub.gds-obj-attr.obj-type ub.gds-obj-attr.obj-code v-host-code }
      create buf_c-gds-hist.
      buffer-copy buf_c-gds-obj-attr to buf_c-gds-hist
      assign
      buf_c-gds-hist.action = (if new ub.gds-obj-attr then integer({&hn-create}) else integer({&hn-update}))
      buf_c-gds-hist.subject = {&table_gds-obj-attr}
      buf_c-gds-hist.host-code = v-host-code
      buf_c-gds-hist.is-news  = g#news
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
    end.
    if ub.gds-obj-attr.attr-code = {&attr-scales-code-o}
    and g#news
    and g#db-num = 0 then do:
    end.
    else do:
      if not g#news
      or g#db-num > 0 then do:
        run str/callnews.p
          ( input {&table_gds-obj-attr}
            ,input (buffer ub.gds-obj-attr:handle )
            ) .
      end.
    end.
    { trg/gdsoatr_send2kassa.i "send2Kassa"}
  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_gds-obj-attr}
        , input ( buffer ub.gds-obj-attr:handle )
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
  if available (ub.gds-obj-attr) and ub.gds-obj-attr.attr-code = "dt-seasons" then 
  do:
    run bge\send1cerp.p (?,
      this-procedure,
      this-procedure,
      "DTSeasons",
      (buffer ub.gds-obj-attr:handle),
      ?,
      ?) no-error.  
    if error-status:error 
      then 
    do:
      message return-value view-as alert-box.
    end.
  end.  
end.
