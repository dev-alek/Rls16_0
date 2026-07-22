block-level on error undo, throw.
define input parameter p-doc-type           as character                no-undo.
define input parameter p-fbr-doc-doc-code   as character                no-undo.
define input parameter p-gds-code           as integer                  no-undo.
define output parameter p-trn-doc-doc-code  as character                no-undo.
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: fbr-trn.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/fbr-trn.p $":U .
define variable vss-description as character no-undo init "Создание, заполнение и резервирование шапки ПН или НС".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure doc-code:
define input  parameter parmode          as   character           no-undo.
define input  parameter parobj-type      like ub.clients.obj-type no-undo.
define input  parameter parobj-code      like ub.clients.obj-code no-undo.
define input  parameter parroot-doc-code like ub.trn-doc.doc-code no-undo.
define output parameter pardoc-code      like ub.trn-doc.doc-code no-undo.
define buffer buf_sys-ctrl for ub.sys-ctrl  .
define variable vardb-remote     as   logical             no-undo.
define variable vartemp-doc-code like ub.trn-doc.doc-code no-undo.
define variable v-delimiter as character no-undo .
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
:
find first buf_sys-ctrl no-lock .
vardb-remote = buf_sys-ctrl.db-num <> 0 .
  CASE parmode:
    when "main":u then do:
      if vardb-remote then do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (parobj-code, ">>>>9")) + substring (parobj-type, (if g#language = "RUS" then 1 else 2), 1).
      end.
      else do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-".
      end.
    end.
    when "trio" then do:
      assign
        pardoc-code = replace (parroot-doc-code, "=", "*").
    end.
    otherwise do:
      assign
      v-delimiter = entry(lookup(entry(1, parmode), "main,chip,pair,flora,trio-m,quadro,stock-up,stock-down,stock-fix," +                          "main_s,chip_s,pair_s,trio-m_s,quadro_s,stock-up_s,stock-down_s,stock-fix_s":U), ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)))
      no-error
      .
      if error-status:error  then do:
        undo, return error substitute("Ошибка при генерации номера документа&1Неверное значение параметра parmode &2"
                                      ,chr(10)
                                      ,parmode
                                      ).
      end.
      if num-entries(parmode) = 1
      and parmode <> "chip":U
      and parmode <> "chip_s":U
      then do:
        assign
        pardoc-code = replace (parroot-doc-code, "-", v-delimiter).
      end.
      else if (lookup("chip":U, parmode) > 0
               or
               lookup("chip_s":U, parmode) > 0) then do:
        assign
          vartemp-doc-code = parroot-doc-code.
        do while true:
          if index (vartemp-doc-code , ".") = 0 then
            vartemp-doc-code  = replace (vartemp-doc-code , v-delimiter, v-delimiter + "1.").
          else
            vartemp-doc-code  =
            substring (vartemp-doc-code , 1, index (vartemp-doc-code, v-delimiter)) +
            string (integer (substring (vartemp-doc-code, index (vartemp-doc-code, v-delimiter) + 1, index (vartemp-doc-code, ".") - index (vartemp-doc-code, v-delimiter) - 1)) + 1) +
            substring (vartemp-doc-code, index (vartemp-doc-code, ".")).
          if not can-find (ub.trn-doc where ub.trn-doc.doc-code = vartemp-doc-code no-lock) then leave.
        end.
        assign
          pardoc-code = vartemp-doc-code.
      end.
    end.
  end CASE.
  if pardoc-code = '':U
  or (parroot-doc-code <> '':U
  and pardoc-code = parroot-doc-code) then do:
    undo, return error substitute("Ошибка при генерации номера документа&1"
                                  ,chr(10)).
  end.
end.
end. // procedure/method
function get-doc-code-int64 returns int64
  ( input p-doc-code as character ) :
  define variable v-ind              as integer   no-undo .
  define variable v-num-entries      as integer   no-undo .
  define variable v-doc-code-int64   as int64     no-undo .
  define variable v-canonic-doc-code as character no-undo .
  assign
    v-num-entries      = num-entries( ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) )
    v-canonic-doc-code = p-doc-code
  .
  do v-ind = 1 to v-num-entries
  :
    assign
      v-canonic-doc-code = entry(1, v-canonic-doc-code, entry( v-ind, ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) ) )
    .
  end.
  assign
    v-doc-code-int64 = int64(v-canonic-doc-code) no-error
  .
  return v-doc-code-int64 .
end. // function/method
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info2 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure fbrattr-write :
  define input parameter p-doc-type       as character        no-undo.
  define input parameter p-doc-code       as character        no-undo.
  define input parameter p-attr-code      as character        no-undo.
  define input parameter p-attr-value     as character        no-undo.
  do
  on error undo, return error
  :
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input substitute('&1-&2',p-doc-type,p-doc-code) ,
                       input p-attr-code ,
                       input p-attr-value )  .
  end.
end procedure.
procedure fbrattr-value :
  define  input parameter p-doc-type      as character        no-undo.
  define  input parameter p-doc-code      as character        no-undo.
  define  input parameter p-attr-code     as character        no-undo.
  define output parameter p-attr-value    as character        no-undo.
  define variable v-par-value     as character    no-undo.
  define variable v-par-type      as character    no-undo.
  define buffer buf_clients       for ub.clients.
  do
  for buf_clients
  on error undo, return error
  :
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input substitute('&1-&2',p-doc-type,p-doc-code) ,
                        input p-attr-code ,
                       output p-attr-value ,
                       output v-par-type )  .
  end.
end procedure.
define variable v-main-trn-doc-code like trn-doc.doc-code   no-undo.
define variable v-trio-trn-doc-code like trn-doc.out-code   no-undo.
define variable v-today             as date                 no-undo.
define variable v-ext-doc-type      as character            no-undo.
define variable v-host-code         as integer              no-undo.
define variable v-host-name         as character            no-undo.
define variable v-pay-code          as integer              no-undo.
define variable v-base-code         as integer              no-undo.
define variable v-rb-is-base        as logical      no-undo.
define variable v-db-num            as integer      no-undo.
define variable v-operator-code     as integer          no-undo.
define buffer buf_out_trn-doc   for trn-doc.
define buffer buf_trn-doc       for trn-doc.
define buffer buf_fbr-doc       for fbr-doc.
define buffer buf_goods         for goods.
rsrv:
do
for buf_out_trn-doc
  , buf_trn-doc
  , buf_fbr-doc
  , buf_goods
on error undo rsrv, return error
:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-rb-is-base
  )  .
    find first buf_fbr-doc no-lock
         where buf_fbr-doc.doc-code = p-fbr-doc-doc-code
    .
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    if p-doc-type = 'при':U
    then do:
        run doc-code in this-procedure (
              input "pair"
            , input buf_fbr-doc.obj-type
            , input buf_fbr-doc.obj-code
            , input buf_fbr-doc.doc-code
            , output v-main-trn-doc-code
        ) no-error.
        if error-status:error
        then do:
            undo, return error substitute ( "Ошибка при генерации номера документа прихода (pair). &1. &2. &3.", return-value, trim( error-status :get-message( 1 ) ), trim( error-status :get-message( 2 ) ) ).
        end.
    end.
    else do:
        if buf_goods.gds-type = 'у':U
        then do:
            run doc-code in this-procedure (
                  input  "trio-m"
                , input  buf_fbr-doc.obj-type
                , input  buf_fbr-doc.obj-code
                , input  buf_fbr-doc.doc-code
                , output v-main-trn-doc-code
            ) no-error.
            if error-status:error
            then do:
                undo, return error substitute ( "Ошибка при генерации номера документа для услуг (trio). &1. &2. &3.", return-value, trim( error-status :get-message( 1 ) ), trim( error-status :get-message( 2 ) ) ).
            end.
            assign
                v-trio-trn-doc-code = buf_fbr-doc.doc-code
            .
        end.
        else do:
            assign
                v-main-trn-doc-code = buf_fbr-doc.doc-code
            .
            run doc-code in this-procedure (
                  input  "trio-m":U
                , input  buf_fbr-doc.obj-type
                , input  buf_fbr-doc.obj-code
                , input  buf_fbr-doc.doc-code
                , output v-trio-trn-doc-code
            ) no-error.
            if error-status:error
            then do:
                undo, return error substitute ( "Ошибка при генерации номера документа (trio). &1. &2. &3.", return-value, trim( error-status :get-message( 1 ) ), trim( error-status :get-message( 2 ) ) ).
            end.
        end.
    end.
    find first buf_trn-doc
         where buf_trn-doc.doc-code = v-main-trn-doc-code
    no-error.
    find first buf_out_trn-doc
         where buf_out_trn-doc.doc-code = v-trio-trn-doc-code
    no-error.
    if not available buf_trn-doc
    then do:
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  buf_fbr-doc.obj-type
  ,input  buf_fbr-doc.obj-code
  ,output v-today
  )  .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  buf_fbr-doc.obj-type
  ,input  buf_fbr-doc.obj-code
  ,output v-host-code
  ,output v-host-name
  )  .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-base-code
  )  .
        find last curr-accnt no-lock
            where curr-accnt.curr-code = v-base-code
              and curr-accnt.exch-date <= v-today
        use-index pi no-error.
        if not available curr-accnt
        then do:
            message
                "На дату" v-today "неизвестен курс базовой валюты."
            view-as alert-box error.
if session :set-wait-state( "" ) then.
            undo rsrv, return error.
        end.
        case p-doc-type:
            when 'при':U
            then do:
                assign
                    v-ext-doc-type = 'im':U
                .
            end.
            when 'спи':U
            then do:
                assign
                    v-ext-doc-type = 'wm':U
                .
            end.
        end case.
        assign
            v-pay-code = buf_fbr-doc.pay-code
        .
        if v-pay-code = ?
        or v-pay-code = 0
        then do:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdnpay in g#library
  (input  buf_fbr-doc.obj-type
  ,input  buf_fbr-doc.obj-code
  ,output v-pay-code
  )  .
        end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crtrndoc in g#lib-trn
(input ?
,input ?
,input (if available buf_out_trn-doc then buf_out_trn-doc.base-rate  else curr-accnt.exch-rate)
,input (if available buf_out_trn-doc then buf_out_trn-doc.base-scale else curr-accnt.exch-scale)
,input v-host-code
,input 'орг':U
,input v-host-name
,input g#db-num
,input g#userid
,input 'прво':U
,input v-main-trn-doc-code
,input buf_fbr-doc.doc-date
,input p-doc-type
,input no
,input buf_fbr-doc.host-code
,input yes
,input buf_fbr-doc.obj-code
,input buf_fbr-doc.obj-type
,input (buf_goods.gds-type = 'у':U)
,input (if available buf_out_trn-doc then buf_out_trn-doc.pay-code else v-pay-code)
,input ' '
,input no
,input 'без':U
,input 'прво':U
,input 'в т. ч.':U
,input v-ext-doc-type
,input 1
) no-error
.
        if error-status:error
        then do:
            message
                "Ошибка при создании складского документа."
            view-as alert-box error.
if session :set-wait-state( "" ) then.
            undo rsrv, return error.
        end.
        find first buf_trn-doc exclusive-lock
             where buf_trn-doc.doc-code = v-main-trn-doc-code
        .
        assign
            buf_trn-doc.out-code    = buf_fbr-doc.doc-code
            buf_trn-doc.print-rubl  = ( if v-rb-is-base = yes then no else yes )
            buf_trn-doc.exch-rate   = 1
            buf_trn-doc.exch-scale  = 1
            buf_trn-doc.exch-code   = 0
        .
        run get-fbroperator in this-procedure (
              input p-fbr-doc-doc-code
            , output buf_trn-doc.agnt
            , output buf_trn-doc.boss
            , output buf_trn-doc.wrkr
        ).
        if available buf_out_trn-doc
        then do:
            assign
                buf_trn-doc.exch-date  = buf_out_trn-doc.exch-date
            .
        end.
        else do:
            assign
                buf_trn-doc.exch-date  = v-today
            .
        end.
    end.
    assign
        p-trn-doc-doc-code = buf_trn-doc.doc-code
    .
end.
procedure get-fbroperator :
define input parameter p-fbr-doc-code   as character        no-undo.
define output parameter p-agnt          as integer          no-undo.
define output parameter p-boss          as integer          no-undo.
define output parameter p-wrkr          as integer          no-undo.
    define variable v-agntbosswrkr      as character    no-undo.
    define variable v-operator-code     as integer      no-undo.
    define variable v-operator-string   as integer      no-undo.
    define buffer buf_clients       for clients.
do
for buf_clients
on error undo, return error
:
    assign
        v-operator-code = 0
    .
    run fbrattr-value in this-procedure (
        input 'fbr-doc':U
        , input p-fbr-doc-code
        , input 'fbroperator':U
        , output v-operator-string
    ) no-error.
    if not error-status :error
    then do:
        assign
            v-operator-code = integer( v-operator-string )
        no-error.
        if error-status :error
        then do:
            assign
                v-operator-code = 0
            .
        end.
        else do:
            find first buf_clients no-lock
                where buf_clients.obj-type = 'чел':U
                and buf_clients.obj-code = v-operator-code
            no-error.
            if not available buf_clients
            then do:
                assign
                    v-operator-code = 0
                .
            end.
        end.
    end.
    if v-operator-code > 0
    then do:
        assign
            p-agnt = v-operator-code
            p-boss = v-operator-code
            p-wrkr = v-operator-code
        .
    end.
end.
end procedure.
