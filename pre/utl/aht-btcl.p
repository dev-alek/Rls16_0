block-level on error undo, throw.
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer   no-undo .
define input parameter p-cut-date as date      no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: aht-btcl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/aht-btcl.p $":U .
define variable vss-description as character no-undo init "Очистка заданий на расчёт складского архива по типам приобретения с датой более ранней, чем указанная".
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
do
on error undo, return error
:
  define buffer buf_batchprocess for ub.batchprocess .
  define buffer delete_batchprocess for ub.batchprocess .
  define buffer buf_trn-doc for ub.trn-doc .
  define buffer buf_price-doc for ub.price-doc .
  for each buf_batchprocess no-lock
    where buf_batchprocess.bp_type = 'aht':U
  on error undo, return error
  :
    case buf_batchprocess.charkey_two :
      when 'trn-doc':U
      then do:
        find first buf_trn-doc no-lock
          where buf_trn-doc.doc-code = buf_batchprocess.charkey_one
          no-error .
        if (available buf_trn-doc
            and buf_trn-doc.obj-type  = p-obj-type
            and buf_trn-doc.obj-code  = p-obj-code
            and buf_trn-doc.fact-date < p-cut-date
            )
        or not available buf_trn-doc
        then do:
          do transaction
          on error undo, return error
          :
            find delete_batchprocess exclusive-lock
              where recid(delete_batchprocess) = recid(buf_batchprocess)
              no-error .
            delete delete_batchprocess .
          end.
        end.
      end.
      when 'price-doc':U
      then do:
        find first buf_price-doc no-lock
          where buf_price-doc.doc-num = buf_batchprocess.charkey_one
          no-error .
        if (available buf_price-doc
            and buf_price-doc.obj-type = p-obj-type
            and buf_price-doc.obj-code = p-obj-code
            and buf_price-doc.fact-date < p-cut-date
            )
        or not available buf_price-doc
        then do:
          do transaction
          on error undo, return error
          :
            find delete_batchprocess exclusive-lock
              where recid(delete_batchprocess) = recid(buf_batchprocess)
              no-error .
            delete delete_batchprocess .
          end.
        end.
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестный тип таблицы" skip
          "charkey_one"  buf_batchprocess.charkey_one skip
          "charkey_two"  buf_batchprocess.charkey_two skip
          view-as alert-box error .
        undo, return error .
      end.
    end case .
  end.
end.
