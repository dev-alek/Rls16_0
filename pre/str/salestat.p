block-level on error undo, throw.
define input parameter parparentproc    as widget-handle no-undo .
define input parameter p-inkas-code     like ub.inkas.inkas-code no-undo .
define input parameter p-close-mode     as character no-undo .
define input parameter p-status_        as character no-undo .
define input parameter p-flag_          as logical no-undo .
define input parameter p-silent                       as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: salestat.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/salestat.p $":U .
define variable vss-description as character no-undo init "Перевод статусов для продажи".
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
define variable v-pre-status_ as character no-undo .
define variable v-pre-flag_   as logical no-undo .
define variable v-status_ as character no-undo .
define variable v-flag_   as logical   no-undo .
define variable v-ask-message as character no-undo .
define variable v-correct as logical no-undo .
define variable v-mess as character no-undo .
define buffer buf_inkas for ub.inkas.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_sale-doc for ub.sale-doc.
_main:
do
on error undo, return error return-value
on stop undo, return error return-value
:
  find first buf_inkas exclusive-lock where
            buf_inkas.inkas-code = p-inkas-code .
  find first buf_trn-doc exclusive-lock where
              buf_trn-doc.doc-code = p-inkas-code  .
  run str/salegraf.p (
                   input  buf_inkas.inkas-code
                  ,input  p-close-mode
                  ,input  buf_inkas.status_
                  ,input  buf_trn-doc.flag_
                  ,output v-status_
                  ,output v-flag_
                  ,output v-ask-message
                  ) no-error.
  if error-status:error
  then do:
    run err-mess ( substitute("Ошибка при проверке возможности открытия/закрытия:&1&2 &3"
                  ,  chr(10)
                  , error-status:get-message(1)
                  , return-value
                  )
                  , output v-mess).
    undo _main, return error v-mess.
  end.
  if v-status_ <> p-status_
  or v-flag_ <> p-flag_
  then do:
    run err-mess ( substitute("Невозможно открыть/закрыть продажу до запрашиваемого статуса &1&2&3&4"
                  , p-status_
                  , string(p-flag_, "+/-")
                  ,  chr(10)
                  , return-value
                  )
                  , output v-mess).
    undo _main, return error v-mess.
  end.
  if p-status_ = 'факт':U then do:
    run err-mess ( substitute( "Неверный вызов процедуры - для статуса &1",   p-status_), output v-mess).
    undo _main, return error v-mess.
  end.
  if p-close-mode <> '<закрытие документа на факт>':U then do:
    assign
    v-pre-status_ = buf_inkas.status_
    v-pre-flag_   = buf_inkas.flag_
    .
    assign
    buf_inkas.status_ = p-status_
    buf_inkas.flag_ = p-flag_
    .
    for each buf_sale-doc where
            buf_sale-doc.inkas-code = p-inkas-code
        and buf_sale-doc.order > 0,
    first buf_trn-doc exclusive-lock where
        buf_trn-doc.doc-code = buf_sale-doc.doc-code
    by buf_sale-doc.order
    on error undo _main, return  error return-value
    on stop undo _main, return  error return-value :
      assign
      buf_trn-doc.flag_ = p-flag_
      .
      release buf_trn-doc no-error .
      if error-status:error then do:
        run err-mess (substitute("Ошибка при смене статуса на &1&2&3&4 &5"
                                , p-status_
                                , p-flag_
                                , chr(10)
                                , error-status:get-message(1)
                                , return-value
                                ), output v-mess).
        undo _main, return error v-mess.
      end.
    end.
    release buf_inkas no-error .
    if error-status:error then do:
      run err-mess (substitute("Ошибка при смене статуса на &1&2&3&4 &5"
                              , p-status_
                              , p-flag_
                              , chr(10)
                              , error-status:get-message(1)
                              , return-value
                              ), output v-mess).
      undo _main, return error v-mess.
    end.
  end.
  else do:
  end.
end.
PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
  define output parameter p-mess2 as character no-undo .
  assign
  p-mess2 = substitute("ПРОДАЖА &1: &2&3&4&5"
                      , buf_inkas.inkas-code
                      , buf_inkas.obj-type
                      , buf_inkas.obj-code
                      , chr(10)
                      , p-mess
                      ).
 if not p-silent then do:
    message
    p-mess2
    view-as alert-box error .
 end.
END PROCEDURE.
