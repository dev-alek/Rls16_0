block-level on error undo, throw.
define input  parameter parParentProc as handle no-undo .
define input  parameter p-doc-code    as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pdfdiscl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/pdfdiscl.p $":U .
define variable vss-description as character no-undo init "Закрытие связных ДНЦ по атрибутам переоценки".
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
define buffer buf_price-doc         for ub.price-doc  .
define buffer buf_price-doc-forming for ub.price-doc-forming  .
define buffer buf_price-doc-attr    for ub.doc-attr  .
define variable v-notall-relation as logical   no-undo .
define variable v-exis            as logical   no-undo .
define variable v-str-err as character no-undo .
define variable v-1 as character no-undo .
define variable v-str as character no-undo .
define variable ii1 as integer   no-undo .
define variable ii2 as integer   no-undo .
define variable ii3 as integer   no-undo .
define variable ii4 as integer   no-undo .
  do
  on error undo, return error return-value
  :
find first buf_price-doc no-lock where
           buf_price-doc.doc-num = p-doc-code no-error .
    if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          ""
          view-as alert-box error
        .
        return error return-value .
    end.
  v-exis  = false .
  for each buf_price-doc-attr no-lock where
           buf_price-doc-attr.attr-code begins 'relprpdf':U + chr(4) and
           buf_price-doc-attr.doc-code  = p-doc-code :
           v-exis  = true  .
  end.
  if v-exis  = false then return .
  v-notall-relation = false .
  v-str-err = "" .
  for each buf_price-doc-attr no-lock where
           buf_price-doc-attr.attr-code begins 'relprpdf':U + chr(4) and
           buf_price-doc-attr.doc-code  = p-doc-code :
           assign
              ii1 =  int(entry(1,buf_price-doc-attr.attr-value))
              ii2 =  int(entry(2,buf_price-doc-attr.attr-value))
              ii3 =  int(entry(3,buf_price-doc-attr.attr-value))
              ii4 =  int(entry(4,buf_price-doc-attr.attr-value))
            no-error .
            if error-status :error then do:
              message "Неверно заведен атрибут переоценки" view-as alert-box error .
              return error "Неверно заведен атрибут переоценки"  .
            end.
      find first buf_price-doc-forming no-lock  where
                 buf_price-doc-forming.plt-id     = int(entry(1,buf_price-doc-attr.attr-value)) and
                 buf_price-doc-forming.plt-db-num = int(entry(2,buf_price-doc-attr.attr-value)) and
                 buf_price-doc-forming.pdf-id     = int(entry(3,buf_price-doc-attr.attr-value)) and
                 buf_price-doc-forming.pdf-db     = int(entry(4,buf_price-doc-attr.attr-value)) no-error .
         if not available buf_price-doc-forming then do:
            v-notall-relation = true  .
            v-str-err = v-str-err  +  substitute(" &1(&2),",
              entry(3,buf_price-doc-attr.attr-value) ,
              entry(4,buf_price-doc-attr.attr-value)).
         end.
  end.
  if v-notall-relation = true  then do:
    v-str = substitute("Не все скидочные ДНЦ доступны для обработки, нет: &1 " , v-str-err )  .
    message v-str  view-as alert-box information .
    return error v-str .
  end.
  for each buf_price-doc-attr no-lock where
           buf_price-doc-attr.attr-code begins 'relprpdf':U + chr(4) and
           buf_price-doc-attr.doc-code  = p-doc-code ,
      first buf_price-doc-forming no-lock  where
            buf_price-doc-forming.plt-id     = int(entry(1,buf_price-doc-attr.attr-value)) and
            buf_price-doc-forming.plt-db-num = int(entry(2,buf_price-doc-attr.attr-value)) and
            buf_price-doc-forming.pdf-id     = int(entry(3,buf_price-doc-attr.attr-value)) and
            buf_price-doc-forming.pdf-db     = int(entry(4,buf_price-doc-attr.attr-value))
            :
              run str/diallog.w
                ( parparentproc
                , this-procedure
                , 'str/pdf-clos.p':U
                , ( string(recid(buf_price-doc-forming)) + chr(4) +
                  'no' + chr(4) +
                  'no' + chr(4) +
                  '?'  + chr(4) +
                  '?'  + chr(4) +
                  string('факт':U) + chr(4) +
                  '?'  + chr(4) +
                  'yes'  )
                , yes
                , '':U
                , 'Закрытие порожденных ДНЦ') no-error .
                if error-status :error then do:
                   v-str = substitute("_Закрытие порожденных ДНЦ ошибка &1 &2" , return-value ,  error-status :get-message(1) ) .
                   return error v-str .
                end.
    end.
 end.
