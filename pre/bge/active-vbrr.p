block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $ SShalanin":U .
define variable vss-date        as character no-undo init "$Date: Fri Oct 18 11:02:52 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: active-vbrr.p $ active-vbrr.p ":U .
define variable vss-archive     as character no-undo init "$Archive: bge/active-vbrr.p $ bge/active-vbrr.p ":U .
define variable vss-description as character no-undo init "Процедура выгрузки информации по пополнениям и активации для сверки с ВБРР".
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table temp-host no-undo
  field host-code like ub.store.host-code
  index xpk host-code
.
define  temp-table temp-obj no-undo
  field obj-type  like ub.clients.obj-type
  field obj-code  like ub.clients.obj-code
  field host-code like ub.store.host-code
  field db-num    like ub.clients.db-num
  index xpk  obj-type obj-code
  index xie1 host-code
  index xie2 db-num host-code
.
procedure init-temphost:
  define buffer buf_store   for ub.store .
  define buffer buf_shop    for ub.shop .
  define buffer buf_clients for ub.clients .
  define buffer buf_db for ub.db .
  define buffer buf_temp-host for temp-host .
  define buffer buf_temp-obj for temp-obj .
  do
  on error undo, return error return-value
  :
    for each buf_store
    on error undo, return error
    :
      find first buf_temp-host
        where buf_temp-host.host-code = buf_store.host-code
        no-error .
      if not available buf_temp-host
      then do:
        create buf_temp-host .
        assign
          buf_temp-host.host-code = buf_store.host-code
        .
      end.
      find first buf_clients no-lock
        where buf_clients.obj-type = 'скл':U
          and buf_clients.obj-code = buf_store.obj-code
        no-error .
      if not available buf_clients
      then do:
        message
          "Ошибка при поиске клиента" skip
          "Клиент" 'скл':U buf_store.obj-code skip
          view-as alert-box error .
        undo, return error .
      end.
      create buf_temp-obj .
      assign
        buf_temp-obj.obj-type  = 'скл':U
        buf_temp-obj.obj-code  = buf_store.obj-code
        buf_temp-obj.host-code = buf_store.host-code
        buf_temp-obj.db-num    = buf_clients.db-num
      .
    end.
    for each buf_shop
    on error undo, return error
    :
      find first buf_temp-host
        where buf_temp-host.host-code = buf_shop.host-code
        no-error .
      if not available buf_temp-host
      then do:
        create buf_temp-host .
        assign
          buf_temp-host.host-code = buf_shop.host-code
        .
      end.
      find first buf_clients no-lock
        where buf_clients.obj-type = 'маг':U
          and buf_clients.obj-code = buf_shop.obj-code
        no-error .
      if not available buf_clients then do:
        message
          "Ошибка при поиске клиента" skip
          "Клиент" 'маг':U buf_shop.obj-code skip
          view-as alert-box error .
        undo, return error .
      end.
      create buf_temp-obj .
      assign
        buf_temp-obj.obj-type  = 'маг':U
        buf_temp-obj.obj-code  = buf_shop.obj-code
        buf_temp-obj.host-code = buf_shop.host-code
        buf_temp-obj.db-num    = buf_clients.db-num
      .
    end.
  end.
end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
DEFINE INPUT PARAMETER p-log-handle AS HANDLE NO-UNDO.
define input parameter v-obj-range   as integer   no-undo .
define input parameter v-host-code   like ub.sysconf.host-code no-undo .
define input parameter v-obj-list as character no-undo.
define input parameter date-to as date no-undo.
define input parameter date-from as date no-undo.
define input parameter v-gds-code-inf as integer no-undo.
define input parameter v-gds-code-active as integer no-undo.
define input parameter p-directory as char no-undo.
define input parameter v-code_pnpo as char no-undo.
define input parameter v-active as logical no-undo.
define input parameter v-inf-po as logical no-undo.
define input parameter p-per as integer no-undo.
define variable v-ul-day as integer no-undo.
define stream f2.
define stream f1.
define variable file_name-inf    as char    no-undo.
define variable file_name-active as char    no-undo.
define variable b-code-inf       as integer no-undo.
define variable b-code-active    as integer no-undo.
define variable v-time           as char    no-undo.
define buffer buf_goods for goods.
define variable v-code-get    as integer no-undo.
define variable v-obj-counter as integer no-undo.
define variable v-obj-type    as character no-undo.
define variable v-obj-code    as integer no-undo.
  for each temp-obj :
    delete temp-obj.
  end.
  case v-obj-range:
    when 2 then do:
      run init-temphost.
      for each temp-obj where temp-obj.host-code <> v-host-code :
        delete temp-obj.
      end.
    end.
    when 3 then do:
      do v-obj-counter = 1 to num-entries ( v-obj-list ) / 2 :
        assign
          v-obj-type =          entry( v-obj-counter * 2 - 1, v-obj-list )
          v-obj-code = integer( entry( v-obj-counter * 2    , v-obj-list ) )
        no-error .
        if error-status:error then next.
        find first temp-obj no-lock
             where temp-obj.obj-type = v-obj-type
               and temp-obj.obj-code = v-obj-code no-error .
        if available temp-obj then next.
        create temp-obj.
        assign
          temp-obj.obj-type = v-obj-type
          temp-obj.obj-code = v-obj-code
        .
      end.
    end.
    otherwise do:
    end.
  end case.
v-ul-day = -1 *  (INTERVAL(date( 1 , 1 , YEAR(TODAY)), today , 'days')) + 1  .
if p-per <> 0 then
do:
    assign
        date-from = today - p-per
        date-to   = today.
end.
if v-inf-po = yes then
do:
    for first bar-code no-lock where bar-code.gds-code = v-gds-code-inf :
        b-code-inf = bar-code.b-code.
    end.
end.
if v-active then
do:
    for first bar-code no-lock where bar-code.gds-code = v-gds-code-active :
        b-code-active = bar-code.b-code.
    end.
end.
 for each temp-obj :
        run rep/rpychk0.p (input "r-autocu"
            ,input temp-obj.obj-type
            ,input temp-obj.obj-code
            ,input date-from
            ,input date-to
            ,input  ?
            ,input ?
            ,input ?
            ,input ?
            ,input ?
            ) no-error.
        if error-status:error then
        do:
            return error return-value  +
                error-status:get-message(1) .
        end.
end.
define frame stav-active.
v-time =  substring(string(time,"HH:MM"),1,2)  + substring(string(time,"HH:MM"),4,2).
if v-inf-po = yes then
do:
    file_name-inf = p-directory + "BPAPAY" + v-code_pnpo + "-" + v-time + "." +  string(v-ul-day) .
            output stream f1 to value(file_name-inf)   .
    for each temp-obj :
        for each chk-gds-pay where chk-gds-pay.chk-date >= date-from and chk-gds-pay.chk-date  <= date-to and chk-gds-pay.obj-type = temp-obj.obj-type and chk-gds-pay.obj-code = temp-obj.obj-code and chk-gds-pay.b-code =  b-code-inf no-lock  :
            put stream f1 unformatted
                string(chk-gds-pay.chk-date,"99.99.9999") ";" string(chk-gds-pay.chk-time,"HH:MM:SS") ";" string(integer(chk-gds-pay.tot-r-b * 100)) .
            find first chk-pay  where chk-pay.doc-code = chk-gds-pay.doc-code no-lock no-error.
            find first chk-pay-attr  where attr-code = 'CPDOC' and chk-pay-attr.doc-code = chk-gds-pay.doc-code   no-lock no-error.
            if available chk-pay-attr then
            do:
                put stream f1 unformatted
                    ";" chk-pay-attr.attr-value  ";" skip
                    .
            end.
            else
            do:
                put stream f1 unformatted
                    ";" ";" skip
                    .
            end.
        end.
    end.
    output stream f1 close.
end.
if v-active = yes then
do:
       file_name-active = p-directory + "BPAGSP" + v-code_pnpo +  v-time + "." +  string(v-ul-day) .
        output stream f2 to value(file_name-active).
    for each temp-obj :
        for each chk-gds-pay where chk-gds-pay.chk-date >= date-from and chk-gds-pay.chk-date  <= date-to and chk-gds-pay.obj-type = temp-obj.obj-type and chk-gds-pay.obj-code = temp-obj.obj-code and chk-gds-pay.b-code =  b-code-active no-lock  :
            find first chk-doc where chk-doc.doc-code = chk-gds-pay.doc-code no-lock no-error.
            put stream f2 unformatted
                string(chk-gds-pay.chk-date,"99.99.9999") ";"  v-code_pnpo ";" string(chk-doc.doc-num) ";" "1"   skip
                .
        end.
    end.
    output stream f2 close.
end.
