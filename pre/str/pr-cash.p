block-level on error undo, throw.
define input parameter parparentproc           as   widget-handle no-undo .
define input parameter p-new-price-doc-status_ like ub.price-doc.status_ no-undo .
define input parameter p-doc-num               like ub.price-doc.doc-num no-undo .
define input parameter p-obj-type              like ub.price-doc.obj-type no-undo .
define input parameter p-obj-code              like ub.price-doc.obj-code no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pr-cash.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/pr-cash.p $":U .
define variable vss-description as character no-undo init "Проверки и взаимодействие с кассой при закрытии переоценки".
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
    assign
      p-vss-parameters = substitute('&1|&2',p-new-price-doc-status_,p-doc-num)
    .
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
define variable v-mes as character no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
if p-obj-type <> 'маг':U then do:
  return .
end.
run adm/shattri.p (
     input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'autosale':U
    ,input  'prcl-spl':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
if error-status:error then do:
  delete object v-tth.
  return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
end.
delete object v-tth.
if v-value-logical <> yes then do:
  return.
end.
run str/diallog.w (  input parparentproc
              , input this-procedure
              , input ('str/get-chkf.p':U + chr(4) + string(0) + chr(4) + string(1) + chr(4) + string(1))
              , input (p-obj-type + chr(4) + string(p-obj-code) + chr(4) + string(0))
              , input yes
              , input '':U
              , input 'Прием чеков с касс') no-error .
if error-status:error then return error.
find ub.price-doc no-lock
  where ub.price-doc.doc-num = p-doc-num
  .
define buffer buf_bar-code for ub.bar-code .
for each ub.price-list no-lock
  where ub.price-list.doc-num = ub.price-doc.doc-num
,first buf_bar-code no-lock
  where buf_bar-code.b-code = ub.price-list.b-code
:
   if not ub.price-list.main-price then NEXT.
  _chk-doc:
  FOR EACH ub.chk-doc No-lock
    where ub.chk-doc.obj-type = ub.price-list.obj-type
      AND ub.chk-doc.obj-code = ub.price-list.obj-code
      AND ub.chk-doc.out-code = ?,
          EACH  ub.chk-gds where
                ub.chk-gds.doc-code = ub.chk-doc.doc-code,
          FIRST ub.bar-code where
                ub.bar-code.b-code = ub.chk-gds.b-code no-lock :
    if lookup(string(ub.chk-doc.chk-type), '14,15,16,36,8,101,106,108,11,12,13,40,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) > 0
    or lookup(string(ub.chk-doc.chk-type), '11,111,201,206':U) > 0
    then next _chk-doc.
    if ub.bar-code.gds-code = buf_bar-code.gds-code then do:
      assign
      v-mes = substitute("Найден неучтенный чек №  &1 от &2,&3"  +
                          "содержащий переоцениваемый товар: &4 бар-код: &5&3&3" +
                          "В соответствии с настройкой  <Значение цены в продаже брать из прайс-листа>&3" +
                          "требуется закрыть продажу с этим чеком до переоценки."
                          ,ub.chk-doc.doc-code
                          ,ub.chk-doc.chk-date
                          ,chr(10)
                          , substitute("&1 &2 &3"
                                      , ub.price-list.artic
                                      , ub.price-list.prod-type
                                      , ub.price-list.prod-code)
                          , ub.chk-gds.b-code ).
      if not g#auto then do:
        message v-mes
        view-as alert-box.
        return error .
      end.
      else do:
        return error v-mes.
      end.
    end.
  END.
  for each ub.inkas where ub.inkas.obj-type = p-obj-type and
                         ub.inkas.obj-code = p-obj-code and
                         ub.inkas.status_ = 'новый':U,
      EACH ub.chk-gds  NO-LOCK where
             ub.chk-gds.out-code = ub.inkas.inkas-code,
        FIRST ub.bar-code No-LOCK where
              ub.bar-code.b-code = ub.chk-gds.b-code:
      IF ub.bar-code.gds-code = buf_bar-code.gds-code then do:
        find ub.chk-doc where ub.chk-doc.doc-code = ub.chk-gds.doc-code no-lock.
        v-mes = substitute("Найден чек № &1, входящий в продажу № &2,&3"  +
                           "содержащий переоцениваемый товар: &4 бар-код:&3&3" +
                           "В соответствии с настройкой  <Значение цены в продаже брать из прайс-листа>&3" +
                           "требуется закрыть продажу с этим чеком до переоценки."
                           ,ub.chk-doc.doc-code
                            ,ub.inkas.inkas-code
                            , chr(10)
                            ,substitute("&1 &2 &3"
                                        ,ub.price-list.artic
                                        ,ub.price-list.prod-type
                                        ,ub.price-list.prod-code)
                            ,ub.chk-gds.b-code).
        if not g#auto then do:
          message v-mes
          view-as alert-box .
          return error .
        end.
        else do:
          return error v-mes.
         end.
      end.
  end.
end.
