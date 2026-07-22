block-level on error undo, throw.
define input parameter p-doc-code   as character    no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fbrplnop.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/fbrplnop.p $":U .
define variable vss-description as character no-undo init "ќткрытие документа план-меню".
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
    define temp-table temp_fbr-objects no-undo
        field obj-type  as character
        field obj-code  as integer
        index pi is primary unique obj-type obj-code
    .
    define buffer buf_fbr-pln               for fbr-pln.
    define buffer buf_fbr-pln-line          for fbr-pln-line.
    define buffer buf_fbr-doc               for fbr-doc.
    define buffer buf_trn-doc               for trn-doc.
    define buffer buf_doc-line              for doc-line.
    define buffer buf_del_fbr-line          for fbr-line.
    define buffer buf_del_fbr-doc           for fbr-doc.
    define buffer buf_del_fbr-recipe        for fbr-recipe.
    define buffer buf_del_fbr-recipe-gds    for fbr-recipe-gds.
    define buffer buf_fbr-recipe            for fbr-recipe.
    define buffer buf_fbr-recipe-gds        for fbr-recipe-gds.
do
for buf_fbr-pln
  , buf_fbr-pln-line
  , buf_fbr-doc
  , buf_trn-doc
  , buf_doc-line
  , buf_del_fbr-line
  , buf_del_fbr-doc
  , buf_del_fbr-recipe
  , buf_del_fbr-recipe-gds
  , buf_fbr-recipe
  , buf_fbr-recipe-gds
on error undo, return error
:
if session :set-wait-state( "compiler" ) then.
    for each temp_fbr-objects
    on error undo, return error
    :
        delete temp_fbr-objects.
    end.
    for each buf_fbr-pln-line no-lock
       where buf_fbr-pln-line.doc-code     = p-doc-code
    on error undo, return error
    :
        find first temp_fbr-objects
             where temp_fbr-objects.obj-type = buf_fbr-pln-line.fbr-obj-type
               and temp_fbr-objects.obj-code = buf_fbr-pln-line.fbr-obj-code
        no-error.
        if not available temp_fbr-objects
        then do:
            create temp_fbr-objects.
            assign
                temp_fbr-objects.obj-type = buf_fbr-pln-line.fbr-obj-type
                temp_fbr-objects.obj-code = buf_fbr-pln-line.fbr-obj-code
            .
        end.
    end.
    do transaction
    on error undo, return error
    :
        find first buf_fbr-pln exclusive-lock
             where buf_fbr-pln.doc-code = p-doc-code
        .
        if buf_fbr-pln.status_ <> 'разрешен':U
        then do:
            message
                "ћожно открыть документ только в статусе разр."
            view-as alert-box error.
            undo, return error .
        end.
        for each temp_fbr-objects
        on error undo, return error
        :
            for each buf_fbr-doc no-lock
               where buf_fbr-doc.out-code = p-doc-code
            on error undo, return error
            :
                for each buf_trn-doc exclusive-lock
                    where buf_trn-doc.out-code = buf_fbr-doc.doc-code
                :
                    if buf_trn-doc.ext-doc-type = 'ev':U
                    and buf_trn-doc.status_     = 'запрос':U
                    then do:
                        for each buf_doc-line exclusive-lock
                           where buf_doc-line.doc-code = buf_trn-doc.doc-code
                        :
                            delete buf_doc-line.
                        end.
                        delete buf_trn-doc.
                    end.
                end.
                for each buf_fbr-recipe-gds no-lock
                   where buf_fbr-recipe-gds.doc-code      = buf_fbr-doc.doc-code
                :
                    find first buf_del_fbr-recipe-gds exclusive-lock
                         where recid( buf_del_fbr-recipe-gds ) = recid( buf_fbr-recipe-gds )
                    .
                    delete buf_del_fbr-recipe-gds.
                end.
                for each buf_fbr-recipe no-lock
                   where buf_fbr-recipe.doc-code      = buf_fbr-doc.doc-code
                :
                    find first buf_del_fbr-recipe exclusive-lock
                         where recid( buf_del_fbr-recipe ) = recid( buf_fbr-recipe )
                    .
                    delete buf_del_fbr-recipe.
                end.
                for each fbr-line no-lock
                   where fbr-line.doc-code = buf_fbr-doc.doc-code
                :
                    find first buf_del_fbr-line exclusive-lock
                         where recid( buf_del_fbr-line ) = recid( fbr-line )
                    .
                    delete buf_del_fbr-line.
                end.
                find first buf_del_fbr-doc exclusive-lock
                     where recid( buf_del_fbr-doc ) = recid( buf_fbr-doc )
                .
                delete buf_del_fbr-doc.
            end.
        end.
        assign
            buf_fbr-pln.status_ = 'новый':U
        .
    end.
if session :set-wait-state( "" ) then.
end.
