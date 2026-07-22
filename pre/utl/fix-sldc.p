block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-read-only as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fix-sldc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/fix-sldc.p $":U .
define variable vss-description as character no-undo init "Корректировка расхождения между полученными trn-doc/inkas и командой на расчет ДК по этим документам".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable cre-pay as integer no-undo .
define buffer buf_doc-attr for ub.doc-attr.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_sysconf for ub.sysconf.
define buffer locked_doc-attr for ub.doc-attr.
if not (g#db-num > 0
and not g#news) then do:
  return.
end.
main-block:
for each buf_doc-attr no-lock where
        buf_doc-attr.attr-code = 'need-saledc':U
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  find first locked_doc-attr exclusive-lock where
            recid(locked_doc-attr) = recid(buf_doc-attr).
  if p-read-only then do:
    return error substitute("&1 &2 &3&4До начала работы с данной БД (режим RO) необходимо произвести вход в ОСНОВНУЮ БД!!!"
                            ,vss-workfile
                            ,vss-revision
                            ,vss-description
                            ,chr(10)).
  end.
  find first buf_trn-doc exclusive-lock where
            buf_trn-doc.doc-code = locked_doc-attr.doc-code no-error.
  if not available buf_trn-doc then do:
    undo main-block, return error substitute("&1 &2&3Не найден документ &4 для атрибута <Требуется расчет данных по ДК>"
                                             , vss-workfile
                                             , vss-description
                                             , chr(10)
                                             , buf_trn-doc.doc-code).
  end.
  if buf_trn-doc.status_ <> 'факт':U then do:
    undo main-block, return error substitute("&1 &2&3Документ &4 для атрибута <Требуется расчет данных по ДК> находится в статусе  &5"
                                          , vss-workfile
                                          , vss-description
                                          , chr(10)
                                           , buf_trn-doc.doc-code
                                           , buf_trn-doc.status_
                                           ).
  end.
  case buf_trn-doc.ext-doc-type:
    when 'es':U then do:
      find first buf_sysconf where
              buf_sysconf.host-code = buf_trn-doc.host-code no-lock.
      find first buf_Cash-pay no-lock where
                buf_cash-pay.cdpay-code = buf_sysconf.credit-pay no-error.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'iscredit'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output conf-par
  ,output par-type
  ) no-error .
      if error-status:error
      or not available buf_cash-pay
      or buf_cash-pay.is-credit = no
      or conf-par <> "yes"
      then do:
          assign
          cre-pay = 0
          .
      end.
      else do:
        assign
        cre-pay = buf_sysconf.credit-pay
        .
      end.
      run str/diallog.w ( input parparentproc
                  , input this-procedure
                  , input ('fix-sldc_diallog':U + chr(4) +
                          "1" + chr(4) +
                          "0" + chr(4) +
                          "1" + chr(4) +
                          "1" + chr(4) +
                          "yes")
                  , input ''
                  , input yes
                  , input 'Прервать'
                  , input substitute('Досчет ДК по недовыгруженной продаже &1 ', buf_trn-doc.doc-code)) no-error .
    end.
    otherwise do:
      if  (buf_trn-doc.ext-doc-type = 're':U OR
        buf_trn-doc.ext-doc-type = 'ee':U)
        and buf_trn-doc.d-card       <> ""
        and buf_trn-doc.d-card       <> ?
      then do:
        run str/saledc.p ( INPUT parparentproc
                    ,input ?
                    ,input ?
                    ,input 'trn-doc-close':U
                    ,input ?
                    ,input ""
                    ,input 0
                    ,input 0
                    ,input 0
                    ,INPUT g#db-num
                    ,INPUT buf_trn-doc.doc-code
                    ,input buf_trn-doc.doc-date
                    ,input buf_trn-doc.fact-date
                    ,input ?
                    ,input (if locked_doc-attr.attr-value = string(1)
                           then 1
                           else -1)
                    ,input (if buf_trn-doc.ext-doc-type = 're':U
                            then -1
                            else 1)
                    ,input yes
                    ) no-error .
      end.
    end.
  end case.
  if error-status :error
  then do:
    undo main-block, return error substitute("&1 &2&3Ошибка при проведении досчета ДК по недовыгруженной продаже/накладной &4.&3&5&3&6"
                                  , vss-workfile
                                  , vss-description
                                  , chr(10)
                                  , buf_trn-doc.doc-code
                                  , error-status:get-message(1)
                                  , return-value
                                  ).
  end.
  define variable v-deleted as logical no-undo .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-del in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'need-saledc':U ,
                       output v-deleted ) no-error .
  if error-status:error then do:
    undo main-block, return error substitute("&1 &2&3Ошибка при удалении атрибута <Требуется расчет данных по ДК> после проведения досчета ДК по недовыгруженной продаже/накладной &4.&3&5&3&6"
                                  , vss-workfile
                                  , vss-description
                                  , chr(10)
                                  , buf_trn-doc.doc-code
                                  , error-status:get-message(1)
                                  , return-value
                                  ).
  end.
end.
procedure fix-sldc_diallog :
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
    run str/saledc.p
      (
      input parparentproc
      ,input p-parent-handle
      ,input p-log-handle
      ,input 'sale-close':U
      ,input ?
      ,input ""
      ,input 0
      ,input 0
      ,input 0
      ,input g#db-num
      ,input buf_trn-doc.doc-code
      ,input buf_trn-doc.doc-date
      ,input buf_trn-doc.fact-date
      ,input cre-pay
      ,input (if locked_doc-attr.attr-value = string(1)
              then 1
              else -1 )
      ,input ?
      ,input yes
      ) no-error .
    if error-status:error then do:
      undo main-block, return error return-value .
    end.
end.
end procedure.
