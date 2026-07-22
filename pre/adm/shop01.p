block-level on error undo, throw.
define input-output parameter p-rec as recid no-undo.
define input parameter        p-mode                as character no-undo .
define input parameter        p-obj-code            like ub.shop.obj-code                 no-undo .
define input parameter        p-db-num              like ub.clients.db-num                no-undo .
define input parameter        p-host-code           like ub.shop.host-code                no-undo .
define input parameter        p-grp-code            like ub.clients.grp-code              no-undo .
define input parameter        p-obj-name            like ub.clients.obj-name              no-undo .
define input parameter        p-PS                  like ub.clients.PS                    no-undo .
define input parameter        p-acct                like ub.shop.acct                     no-undo .
define input parameter        p-addres1             like ub.shop.addres1                  no-undo .
define input parameter        p-addres2             like ub.shop.addres2                  no-undo .
define input parameter        p-all-prt             like ub.shop.all-prt                  no-undo .
define input parameter        p-buy-goods           like ub.shop.buy-goods                no-undo .
define input parameter        p-cd-bc-alt           like ub.shop.cd-bc-alt                no-undo .
define input parameter        p-cd-bc-base          like ub.shop.cd-bc-base               no-undo .
define input parameter        p-cd-loc-alt          like ub.shop.cd-loc-alt               no-undo .
define input parameter        p-cd-loc-base         like ub.shop.cd-loc-base              no-undo .
define input parameter        p-cd-parts-all        like ub.shop.cd-parts-all             no-undo .
define input parameter        p-cd-parts-not-blank  like ub.shop.cd-parts-not-blank       no-undo .
define input parameter        p-cd-parts-ser        like ub.shop.cd-parts-ser             no-undo .
define input parameter        p-cd-pb-alt           like ub.shop.cd-pb-alt                no-undo .
define input parameter        p-cd-pb-base          like ub.shop.cd-pb-base               no-undo .
define input parameter        p-cd-sc-base          like ub.shop.cd-sc-base               no-undo .
define input parameter        p-chk-pay             like ub.shop.chk-pay                  no-undo .
define input parameter        p-day-only            like ub.shop.day-only                 no-undo .
define input parameter        p-director            like ub.shop.director                 no-undo .
define input parameter        p-discaloc            like ub.shop.discaloc                 no-undo .
define input parameter        p-doc-prt             like ub.shop.doc-prt                  no-undo .
define input parameter        p-down-pay            like ub.shop.down-pay                 no-undo .
define input parameter        p-fax                 like ub.shop.fax                      no-undo .
define input parameter        p-goods-man           like ub.shop.goods-man                no-undo .
define input parameter        p-in-ov               like ub.shop.in-ov                    no-undo .
define input parameter        p-in-pay              like ub.shop.in-pay                   no-undo .
define input parameter        p-in-perm             like ub.shop.in-perm                  no-undo .
define input parameter        p-inout-price         like ub.shop.inout-price              no-undo .
define input parameter        p-inv-pay             like ub.shop.inv-pay                  no-undo .
define input parameter        p-is-catering         like ub.shop.is-catering              no-undo .
define input parameter        p-is-kitchen          like ub.shop.is-kitchen               no-undo .
define input parameter        p-is-kitchen-store    like ub.shop.is-kitchen-store         no-undo .
define input parameter        p-kitchen-store-code  like ub.shop.kitchen-store-code       no-undo .
define input parameter        p-kitchen-store-type  like ub.shop.kitchen-store-type       no-undo .
define input parameter        p-no-eq               like ub.shop.no-eq                    no-undo .
define input parameter        p-out-line-discnt     like ub.shop.out-line-discnt          no-undo .
define input parameter        p-out-pay             like ub.shop.out-pay                  no-undo .
define input parameter        p-out-rate            like ub.shop.out-rate                 no-undo .
define input parameter        p-phone               like ub.shop.phone                    no-undo .
define input parameter        p-pr-cash             like ub.shop.pr-cash                  no-undo .
define input parameter        p-price-calc          like ub.shop.price-calc               no-undo .
define input parameter        p-ret-pay             like ub.shop.ret-pay                  no-undo .
define input parameter        p-ret-sup-pay         like ub.shop.ret-sup-pay              no-undo .
define input parameter        p-fbr-pay             like ub.shop.fbr-pay                  no-undo .
define input parameter        p-rsrv-time           like ub.shop.rsrv-time                no-undo .
define input parameter        p-shift-on            like ub.shop.shift-on                 no-undo .
define input parameter        p-store-boss          like ub.shop.store-boss               no-undo .
define input parameter        p-store-man           like ub.shop.store-man                no-undo .
define input parameter        p-sub-store-on        like ub.shop.sub-store-on             no-undo .
define input parameter        p-sub-store-code      like ub.shop.sub-store-code           no-undo .
define input parameter        p-sub-store-type      like ub.shop.sub-store-type           no-undo .
define input parameter        p-unit-cli-perm       like ub.shop.unit-cli-perm            no-undo .
define input parameter        p-with-serv           like ub.shop.with-serv                no-undo .
define input parameter        p-work-hours          like ub.shop.work-hours               no-undo .
define input parameter        p-purch-code          as   integer                          no-undo .
define input parameter        p-envd                as   logical                          no-undo .
define input parameter        p-pharm               as   logical                          no-undo .
define input parameter        p-KPP                 as   character                        no-undo .
define variable vss-revision    as character no-undo init "$Revision: 8c1a0fd433e1, 1120, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:53 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: shop01.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/shop01.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке магазина".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
def var vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure clntattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-value :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-value    like ub.clients-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-value in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-write :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.clients-attr.attr-value no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-write in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-exist :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-exist in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-delete :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-delete in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-copy-to :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-copy-to in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-auto-author-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-auto-author-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-by-type :
  define input  parameter p-archive-type      as character no-undo .
  define output parameter p-archive-attr-list as character no-undo .
  define variable vss-description as character no-undo initial "clntattr-get-archive-by-type-01: возвращает список атрибутов для складского архива".
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-by-type in g#attr-lib
      (input  p-archive-type
      ,output p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-vat-register :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-vat-register in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-requisite-alc-decl :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-requisite-alc-decl in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable v-db-num like ub.db.db-num no-undo .
define variable v-curr-r-b as character no-undo .
define variable par-type as character no-undo .
define variable var-deleted as logical no-undo .
define variable v-envd      as character no-undo.
define variable v-kpp       as character no-undo.
define variable v-pharm     as character no-undo.
define variable v-delete    as logical no-undo.
define variable v-pay-type-list as character no-undo .
define variable v-pay-type-str  as character no-undo .
define buffer buf_sysconf for ub.sysconf.
define buffer buf_clients for ub.clients.
define buffer buf_pay-type for ub.pay-type .
define buffer buf_other_shop for ub.shop.
define buffer buf_cash-desk for ub.cash-desk.
define buffer buf_dis-card-type for ub.dis-card-type.
if p-mode <> 'ДОБАВЛЕНИЕ':U
AND p-mode <> 'ИЗМЕНЕНИЕ':U then do:
  undo, return error
    substitute('&5&1 &2 &3&4Неверный параметр p-mode [&6]':u,
               vss-workfile, vss-revision, vss-description, chr(10), chr(4), p-mode).
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
if v-db-num <> 0
then do:
  undo, return error
    substitute("&2Нельзя изменять запись МАГАЗИНА в УБД: Номер текущей БД &1 ", v-db-num, chr(4)).
end.
run chk-code in this-procedure (p-obj-code, p-mode) no-error .
if error-status:error then
  undo, return error substitute("&1&3&2":U, "obj-code":U, return-value, chr(4)) .
if p-obj-name = "":U then
  undo, return error substitute("&1&3Введите название магазина &2", "obj-name":U, p-obj-code, chr(4)) .
if not can-find ( ub.db where ub.db.db-num = p-db-num ) then
  undo, return error substitute("&1&3Неверный номер БД. Нет БД с номером &2", "db-num":U, p-db-num, chr(4)) .
find first buf_sysconf no-lock where buf_sysconf.host-code = p-host-code no-error .
if not available buf_sysconf then
  undo, return error substitute("&3Не найдена фирма с кодом &1 для магазина &2", p-host-code, p-obj-code, chr(4)) .
if buf_sysconf.firm-db-num <> 0
AND p-db-num <> buf_sysconf.firm-db-num
then do:
  undo, return error substitute(
    "&1&6Главная БД фирмы &2 не совпадает с БД, к которой относится магазин &3: главная БД фирмы - &4, а магазин относится к БД &5",
    "db-num":U, p-host-code, p-obj-code, buf_sysconf.firm-db-num, p-db-num, chr(4)
  ) .
end.
IF p-sub-store-on = yes then do:
  find first buf_clients no-lock
    where buf_clients.obj-type = p-sub-store-type
      and buf_clients.obj-code = p-sub-store-code  no-error.
  if not available buf_clients then
    undo, return error substitute("&1&5Не найден объект &2&3, выбранный в качестве склада-подсобки для магазина &4",
      "sub-store-code":U, p-sub-store-type, p-sub-store-code, p-obj-code, chr(4)) .
  if buf_clients.db-num <> p-db-num then
    undo, return error substitute("&1&5Нельзя в качестве склада-подсобки указать объект другой БД: магазин &2 принадлежит БД &3, а склад-подсобка БД &4",
      "sub-store-code":U, p-obj-code, buf_clients.db-num, p-db-num, chr(4)) .
end.
IF p-is-kitchen then do:
  if p-kitchen-store-type <> 'маг':U then
    undo, return error substitute(
      "&1&5В качестве СКЛАДА КУХНИ для магазина (кухни) &2 указан объект с типом &3. Допустимо указывать объект только с типом &4",
      "kitchen-store-type":U, p-obj-code, p-kitchen-store-type, 'маг':U, chr(4)) .
  find first buf_clients no-lock
    where buf_clients.obj-type = p-kitchen-store-type
      and buf_clients.obj-code = p-kitchen-store-code
    no-error.
  if not available buf_clients then
    undo, return error substitute("&1&5Не найден объект &2&3, выбранный в качестве СКЛАДА для магазина (кухни) &4",
      "kitchen-store-code":U, p-kitchen-store-type, p-kitchen-store-code, p-obj-code, chr(4)) .
  if buf_clients.db-num <> p-db-num then
    undo, return error substitute("&1&5Нельзя в качестве СКЛАДА КУХНИ указать объект другой БД: магазин (кухня) &2 принадлежит БД &3, а СКЛАД - БД &4",
      "kitchen-store-code":U, p-obj-code, buf_clients.db-num, p-db-num, chr(4)) .
  find first buf_other_shop no-lock
       where buf_other_shop.obj-code = buf_clients.obj-code no-error .
  if not available buf_other_shop then
    undo, return error substitute("&1&4Не найден магазин &2, указанный в качестве СКЛАДА КУХНИ для магазина (кухни) &3",
      "kitchen-store-code":U, buf_clients.obj-type, p-obj-code, chr(4)) .
  if buf_other_shop.host-code <> p-host-code then
    undo, return error substitute("&1&5Нельзя в качестве СКЛАДА КУХНИ указать объект другой ФИРМЫ: магазин(кухня) &2 принадлежит фирме &3, а СКЛАД - фирме &4",
      "kitchen-store-code":U, p-obj-code, p-host-code, buf_other_shop.host-code, chr(4)) .
end.
if (p-is-kitchen or p-is-kitchen-store) and not p-is-catering then do:
    find first buf_cash-desk no-lock
         where buf_cash-desk.obj-code = p-obj-code no-error .
    if available buf_cash-desk and
                buf_cash-desk.cash-on then do:
      undo, return error substitute(
        "&1&6Магазин не можeт иметь признак КУХНЯ и/или СКЛАД КУХНИ и не быть РЕСТОРАНОМ, если у него есть ВКЛЮЧЕННЫЕ КАССЫ: магазин &2, касса: БД&3 тип кассы &4 номер кассы &5",
        "kitchen-store-code":U, p-obj-code, buf_cash-desk.db-num, buf_cash-desk.pos-type, buf_cash-desk.cash-num, chr(4)) .
    end.
end.
v-pay-type-list = "":U .
if p-chk-pay <> 0 then do:
  v-pay-type-str = string(p-chk-pay) .
  if not can-find (first buf_pay-type where buf_pay-type.obj-code = p-chk-pay) then
    undo, return error substitute("&1&4Неверный код оплаты реализации (продажи) для магазина &2: код оплаты &3",
                                  "chk-pay":U, p-obj-code, v-pay-type-str, chr(4)) .
  v-pay-type-list = v-pay-type-str .
end.
if p-down-pay <> 0 then do:
  v-pay-type-str = string(p-down-pay) .
  if not can-do (v-pay-type-list, v-pay-type-str) then do:
    if not can-find (first buf_pay-type where buf_pay-type.obj-code = p-down-pay) then
    undo, return error substitute("&1&4Неверный код оплаты списания для магазина &2: код оплаты &3",
                                  "down-pay":U, p-obj-code, v-pay-type-str, chr(4)) .
    v-pay-type-list = substitute("&1,&2", v-pay-type-list, v-pay-type-str) .
  end.
end.
if p-in-pay <> 0 then do:
  v-pay-type-str = string(p-in-pay) .
  if not can-do (v-pay-type-list, v-pay-type-str) then do:
    if not can-find (first buf_pay-type where buf_pay-type.obj-code = p-in-pay) then
    undo, return error substitute("&1&4Неверный код оплаты прихода для магазина &2: код оплаты &3",
                                  "in-pay":U, p-obj-code, v-pay-type-str, chr(4)) .
    v-pay-type-list = substitute("&1,&2", v-pay-type-list, v-pay-type-str) .
  end.
end.
if p-inv-pay <> 0 then do:
  v-pay-type-str = string(p-inv-pay) .
  if not can-do (v-pay-type-list, v-pay-type-str) then do:
    if not can-find (first buf_pay-type where buf_pay-type.obj-code = p-inv-pay) then
    undo, return error substitute("&1&4Неверный код оплаты инвентаризации для магазина &2: код оплаты &3",
                                  "inv-pay":U, p-obj-code, p-inv-pay, chr(4)) .
    v-pay-type-list = substitute("&1,&2", v-pay-type-list, v-pay-type-str) .
  end.
end.
if p-out-pay <> 0 then do:
  v-pay-type-str = string(p-out-pay) .
  if not can-do (v-pay-type-list, v-pay-type-str) then do:
    if not can-find (first buf_pay-type where buf_pay-type.obj-code = p-out-pay) then
    undo, return error substitute("&1&4Неверный код оплаты расхода для магазина &2: код оплаты &3",
                                   "out-pay":U, p-obj-code, p-out-pay, chr(4)) .
    v-pay-type-list = substitute("&1,&2", v-pay-type-list, v-pay-type-str) .
  end.
end.
if p-ret-pay <> 0 then do:
  v-pay-type-str = string(p-ret-pay) .
  if not can-do (v-pay-type-list, v-pay-type-str) then do:
    if not can-find (first buf_pay-type where buf_pay-type.obj-code = p-ret-pay) then
    undo, return error substitute("&1&4Неверный код оплаты возврата от покупателя для магазина &2: код оплаты &3",
                                  "ret-pay":U, p-obj-code, p-ret-pay, chr(4)) .
    v-pay-type-list = substitute("&1,&2", v-pay-type-list, v-pay-type-str) .
  end.
end.
if p-ret-sup-pay <> 0 then do:
  v-pay-type-str = string(p-ret-sup-pay) .
  if not can-do (v-pay-type-list, v-pay-type-str) then do:
    if not can-find (first buf_pay-type where buf_pay-type.obj-code = p-ret-sup-pay) then
    undo, return error substitute("&1&4Неверный код оплаты возврата поставщику для магазина &2: код оплаты &3",
                                  "ret-sup-pay":U, p-obj-code, p-ret-sup-pay, chr(4)) .
    v-pay-type-list = substitute("&1,&2", v-pay-type-list, v-pay-type-str) .
  end.
end.
if p-fbr-pay <> 0 then do:
  v-pay-type-str = string(p-fbr-pay) .
  if not can-do (v-pay-type-list, v-pay-type-str) then do:
    if not can-find (first buf_pay-type where buf_pay-type.obj-code = p-fbr-pay) then
    undo, return error substitute("&1&4Неверный код оплаты производства для магазина &2: код оплаты &3",
                                  "fbr-pay":U, p-obj-code, p-fbr-pay, chr(4)) .
  end.
end.
_MAIN:
DO ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    create ub.shop.
    create ub.clients.
    assign
    ub.clients.obj-code = p-obj-code
    ub.clients.obj-type = 'маг':U
    ub.clients.db-num   = p-db-num
    ub.clients.grp-code = p-grp-code
    ub.clients.host-code = p-host-code
    ub.shop.obj-code = p-obj-code
    ub.shop.host-code   = p-host-code
    p-rec = recid(ub.clients).
  end.
  else do:
    FIND FIRST ub.clients where
              recid(ub.clients) = p-rec No-ERROR.
    if not available ub.clients then
      undo, return error substitute('&5&1 &2 &3&4Не найдена запись КЛИЕНТ для записи МАГАЗИН - p-rec [&6]':u,
                                     vss-workfile, vss-revision, vss-description, chr(10), chr(4), p-rec).
    find first ub.shop where
              ub.shop.obj-code = p-obj-code no-error .
    if not available ub.shop then
      undo, return error substitute('&5&1 &2 &3&4Не найдена запись МАГАЗИН с кодом [&6]':u,
                                     vss-workfile, vss-revision, vss-description, chr(10), chr(4), p-obj-code).
    if ub.shop.obj-code <> p-obj-code
    or ub.shop.host-code <> p-host-code
    or ub.clients.db-num    <> p-db-num
    then
      undo, return error substitute('&5&1 &2 &3&4Для уже имеющегося МАГАЗИНА нельзя изменить номер магазина, номер БД и код фирмы':u,
                                     vss-workfile, vss-revision, vss-description, chr(10), chr(4)).
  end.
  assign
  ub.clients.obj-name         =  p-obj-name
  ub.clients.PS               =  p-PS
  ub.shop.acct                =  p-acct
  ub.shop.addres1             =  p-addres1
  ub.shop.addres2             =  p-addres2
  ub.shop.all-prt             =  p-all-prt
  ub.shop.buy-goods           =  p-buy-goods
  ub.shop.cd-bc-alt           =  p-cd-bc-alt
  ub.shop.cd-bc-base          =  p-cd-bc-base
  ub.shop.cd-loc-alt          =  p-cd-loc-alt
  ub.shop.cd-loc-base         =  p-cd-loc-base
  ub.shop.cd-parts-all        =  p-cd-parts-all
  ub.shop.cd-parts-not-blank  =  p-cd-parts-not-blank
  ub.shop.cd-parts-ser        =  p-cd-parts-ser
  ub.shop.cd-pb-alt           =  p-cd-pb-alt
  ub.shop.cd-pb-base          =  p-cd-pb-base
  ub.shop.cd-sc-base          =  p-cd-sc-base
  ub.shop.chk-pay             =  p-chk-pay
  ub.shop.day-only            =  p-day-only
  ub.shop.director            =  p-director
  ub.shop.discaloc            =  p-discaloc
  ub.shop.doc-prt             =  p-doc-prt
  ub.shop.down-pay            =  p-down-pay
  ub.shop.fax                 =  p-fax
  ub.shop.goods-man           =  p-goods-man
  ub.shop.in-ov               =  p-in-ov
  ub.shop.in-pay              =  p-in-pay
  ub.shop.in-perm             =  p-in-perm
  ub.shop.inout-price         =  p-inout-price
  ub.shop.inv-pay             =  p-inv-pay
  ub.shop.is-catering         =  p-is-catering
  ub.shop.is-kitchen          =  p-is-kitchen
  ub.shop.is-kitchen-store    =  p-is-kitchen-store
  ub.shop.kitchen-store-code  =  if p-is-kitchen
                                  then p-kitchen-store-code
                                  else 0
  ub.shop.kitchen-store-type  =  if p-is-kitchen
                                  then p-kitchen-store-type
                                  else "":U
  ub.shop.no-eq               =  p-no-eq
  ub.shop.out-line-discnt     =  p-out-line-discnt
  ub.shop.out-pay             =  p-out-pay
  ub.shop.out-rate            =  p-out-rate
  ub.shop.phone               =  p-phone
  ub.shop.pr-cash             =  p-pr-cash
  ub.shop.price-calc          =  p-price-calc
  ub.shop.ret-pay             =  p-ret-pay
  ub.shop.ret-sup-pay         =  p-ret-sup-pay
  ub.shop.fbr-pay             =  p-fbr-pay
  ub.shop.rsrv-time           =  p-rsrv-time
  ub.shop.shift-on            =  p-shift-on
  ub.shop.store-boss          =  p-store-boss
  ub.shop.store-man           =  p-store-man
  ub.shop.sub-store-on        =  p-sub-store-on
  ub.shop.sub-store-code      =  if p-sub-store-on
                                  then p-sub-store-code
                                  else 0
  ub.shop.sub-store-type      =  if p-sub-store-on
                                  then p-sub-store-type
                                  else "":U
  ub.shop.unit-cli-perm       =  p-unit-cli-perm
  ub.shop.with-serv           =  p-with-serv
  ub.shop.work-hours          =  p-work-hours
  ub.shop.purch-code          =  p-purch-code
  p-rec = recid(ub.clients )
  .
 release ub.clients no-error.
 if error-status:error then do:
    undo, return error substitute(
      "&5Ошибка при сохранении записи КЛИЕНТ для МАГАЗИНА &1:&2&3&2&4"
    , p-obj-code
    , chr(10)
    , ERROR-STATUS:GET-message(1)
    , return-value
    , chr(4)
    ) .
 end.
 p-obj-code = ub.shop.obj-code.
 release ub.shop no-error.
 if error-status:error then do:
    undo, return error substitute(
      "&5Ошибка при сохранении записи МАГАЗИН &1:&2&3&2&4"
    , p-obj-code
    , chr(10)
    , ERROR-STATUS:GET-message(1)
    , return-value
    , chr(4)
    ) .
 end.
 run clntattr-value in this-procedure
      (input 'маг':U,
      input  p-obj-code,
      input  'pharm':U,
      output v-pharm,
      output par-type).
  if v-pharm = "yes":u then do:
    if p-pharm = no then do:
      run clntattr-delete in this-procedure
       (input 'маг':U,
        input  p-obj-code,
        input  'pharm':U,
        output v-delete).
    end.
  end.
  else do:
    if p-pharm = yes then do:
      run clntattr-write in this-procedure
       (input  'маг':U,
        input  p-obj-code,
        input  'pharm':U,
        input  "yes":u).
    end.
  end.
 run clntattr-value in this-procedure
      (input 'маг':U,
      input  p-obj-code,
      input  'kpp':U,
      output v-kpp,
      output par-type).
  if v-kpp <> "":u and v-kpp <> ? then do:
    if p-kpp = "" or p-kpp = ? then do:
      run clntattr-delete in this-procedure
       (input 'маг':U,
        input  p-obj-code,
        input  'kpp':U,
        output v-delete).
    end.
    else do:
      if p-kpp <> "" and p-kpp <> ? then do:
       run clntattr-write in this-procedure
       (input  'маг':U,
        input  p-obj-code,
        input  'kpp':U,
        input  p-kpp).
    end.
    end.
  end.
    else do:
    if p-kpp <> "" and p-kpp <> ? then do:
      run clntattr-write in this-procedure
       (input  'маг':U,
        input  p-obj-code,
        input  'kpp':U,
        input  p-kpp).
    end.
  end.
 run clntattr-value in this-procedure
      (input 'маг':U,
      input  p-obj-code,
      input  'envd':U,
      output v-envd,
      output par-type).
  if v-envd = "yes":u then do:
    if p-envd = no then do:
      run clntattr-delete in this-procedure
       (input 'маг':U,
        input  p-obj-code,
        input  'envd':U,
        output v-delete).
    end.
  end.
  else do:
    if p-envd = yes then do:
      run clntattr-write in this-procedure
       (input  'маг':U,
        input  p-obj-code,
        input  'envd':U,
        input  "yes":u).
    end.
  end.
 if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    run trg/curr-shc.p (p-obj-code) no-error .
    if error-status:error then
      undo, return error substitute("&3Ошибка при создании записи курса базовой валюты при создании МАГАЗИНА &1: &2",
                                    p-obj-code, ERROR-STATUS:GET-message(1), chr(4)) .
 end.
end.
PROCEDURE chk-code :
define input parameter p-obj-code like ub.shop.obj-code no-undo .
define input parameter p-mode     as character no-undo .
define variable hnum as logical no-undo init no.
define variable  par-type as character no-undo.
define variable  dopi as integer no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
if p-obj-code = 0 then
  return error "Код магазина должен быть больше 0 ".
if  p-mode = 'ДОБАВЛЕНИЕ':U
and can-find( ub.shop where ub.shop.obj-code = p-obj-code ) then
  return error substitute("Магазин с кодом &1 уже есть, измените код", p-obj-code ).
if p-obj-code > 999 and  p-mode = 'ДОБАВЛЕНИЕ':U  then do:
  run adm/shattri.p (
      input "get":U
      ,input  'орг':U
      ,input  p-host-code
      ,input  'get-chk':U
      ,input  'hnum':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output par-type
      ,INPUT-OUTPUT TABLE-handle v-tth
      ) no-error .
  if valid-handle(v-tth) then do:
    delete object v-tth.
  end.
  IF not error-status:error then do:
    assign
    hnum = v-value-logical.
  end.
  if hnum then do:
    return error substitute(
      "Вы не можете присвоить магазину номер > 999 (&1)&3" +
      "пока настроечный параметр <НОМЕР МАГАЗИНА ПРИ ЧТЕНИИ ДАННЫХ С КАССЫ БРАТЬ ИЗ СПУЛА>&3" +
      "для фирмы &2 равен ДА; измените код"
    , p-obj-code
    , p-host-code
    , chr(10)
    ) .
  end.
end.
return.
END PROCEDURE.
