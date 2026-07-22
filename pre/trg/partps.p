block-level on error undo, throw.
define input parameter p-gds-code                  as integer                             no-undo .
define input parameter p-in-code                   as character                           no-undo .
define input parameter p-out-code                  as character                           no-undo .
define input parameter p-part-code                 as character                           no-undo .
define input parameter p-mark-db-num               like ub.parts.mark-db-num              no-undo .
define input parameter p-mark-code                 like ub.parts.mark-code                no-undo .
define input parameter p-alc-bottling-date         like ub.parts.alc-bottling-date        no-undo .
define input parameter p-alc-ref-ab-path           like ub.parts.alc-ref-ab-path          no-undo .
define input parameter p-alc-quality-certif-path   like ub.parts.alc-quality-certif-path  no-undo .
define input parameter p-alc-certif-path           like ub.parts.alc-certif-path          no-undo .
define input parameter p-alc-imp-type              like ub.parts.alc-imp-type             no-undo .
define input parameter p-alc-imp-code              like ub.parts.alc-imp-code             no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Изменение описания для партии приходной накладной и для всех партий, которые были получены из этой партии".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
procedure check-avail-artic:
  define input parameter chg-artic     like ub.goods.artic     no-undo.
  define input parameter chg-prod-type like ub.goods.prod-type no-undo.
  define input parameter chg-prod-code like ub.goods.prod-code no-undo.
  do
  on error  undo, return error
  on stop   undo, return error
  on endkey undo, return error :
    define buffer buf_goods for ub.goods .
    if not can-find( buf_goods where buf_goods.artic     = chg-artic
                                 and buf_goods.prod-type = chg-prod-type
                                 and buf_goods.prod-code = chg-prod-code
                               no-lock )
    then do:
      return error.
    end.
  end.
  return.
end procedure.
procedure check-avail-gds-code:
  define input-output parameter chg-gds-code like ub.goods.gds-code no-undo.
  do
  on error  undo, return error
  on stop   undo, return error
  on endkey undo, return error :
    define buffer buf_goods for ub.goods .
    define buffer buf_route for ub.route .
    find buf_goods where buf_goods.gds-code = chg-gds-code
                  no-lock no-error.
    if not available buf_goods then do:
      do-sch:
      for each buf_route no-lock
        where buf_route.name-rec begins ("command" + chr(1)
                                         + "goods" + chr(1)
                                         + "ren-gds-code" + chr(1)
                                         + string(chg-gds-code)
                                        )
      on error  undo, return error
      :
        assign
          chg-gds-code = int(entry(5,buf_route.name-rec,chr(1)))
          .
        leave do-sch.
      end.
    end.
  end.
  return.
end procedure.
PROCEDURE check-avail-b-code :
  define input-output parameter loc-b-code like ub.bar-code.b-code no-undo.
  do
  on error  undo, return error
  on endkey undo, return error
  on stop   undo, return error :
    define variable sought-b-code  like ub.bar-code.b-code no-undo.
    define variable bar_code      like ub.prod-bc.b-str   no-undo .
    define buffer buf_bar-code for ub.bar-code .
    define buffer buf_prod-bc  for ub.prod-bc .
    assign sought-b-code = loc-b-code .
    find buf_bar-code where buf_bar-code.b-code = sought-b-code no-lock no-error.
    if available buf_bar-code then do:
      assign loc-b-code = buf_bar-code.b-code.
    end.
    else do :
      run gen-bc( input sought-b-code, output bar_code ).
      find first buf_prod-bc where buf_prod-bc.b-str = bar_code no-lock no-error.
      if available buf_prod-bc then do:
        assign loc-b-code = buf_prod-bc.b-code .
        find next buf_prod-bc where buf_prod-bc.b-str = bar_code no-lock no-error.
        if available buf_prod-bc then do:
          assign loc-b-code = ? .
          return error.
        end.
      end.
      else do:
        assign loc-b-code = ?.
        return error.
      end.
    end.
  end.
END PROCEDURE.
define variable v-gds-code       as integer   no-undo .
define variable v-artic          as character no-undo .
define variable v-prod-type      as character no-undo .
define variable v-prod-code      as integer   no-undo .
define variable iCounter         as integer   no-undo .
define variable v-send-db-list   as character no-undo .
define variable v-remote-db-list as character no-undo .
define variable v-cmd            as character no-undo .
define variable v-msg-text       as character no-undo .
define buffer buf_goods      for ub.goods .
define buffer buf_gds-obj    for ub.gds-obj .
define buffer buf_parts      for ub.parts .
define buffer buf_parts-attr for ub.parts-attr .
define buffer buf_db         for ub.db .
main-block:
do transaction
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, "~n", error-status :get-message ( error-status :num-messages ) )
on stop   undo main-block, return error substitute( "&1. stop"  , vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  assign
    v-gds-code = p-gds-code
  .
  if p-alc-imp-code = ?
  then do:
    assign
      p-alc-imp-code = 0
      p-mark-code = 0
    .
  end.
  if p-out-code = ?
  then do:
    p-out-code = "".
  end.
  find first buf_goods no-lock
    where buf_goods.gds-code = v-gds-code no-error.
  if not available buf_goods then do:
    if g#news then do:
      run check-avail-gds-code in this-procedure (input-output v-gds-code).
      find first buf_goods no-lock
        where buf_goods.gds-code = v-gds-code no-error.
      if not available buf_goods then do:
        assign
          v-msg-text = substitute("&1. Не найден товар с кодом &2.", vss-workfile, v-gds-code)
                     + chr(10)
                     + substitute("Первоначальный поиск производился для товара с кодом &1", p-gds-code)
        .
        return error v-msg-text.
      end.
    end.
    else do:
      assign
        v-msg-text = substitute("Не найден товар с кодом &1", v-gds-code)
      .
      return error v-msg-text.
    end.
  end.
  for each ub.gds-obj share-lock
    where ub.gds-obj.gds-code = v-gds-code
  on error undo main-block, return error
  :
    find first buf_gds-obj exclusive-lock
      where recid(buf_gds-obj) = recid(ub.gds-obj)
      .
  end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run arptpc in g#library
  (input  v-gds-code
  ,output v-artic
  ,output v-prod-type
  ,output v-prod-code
  )  .
  find first buf_parts-attr exclusive-lock
    where buf_parts-attr.in-code   = p-in-code
      and buf_parts-attr.gds-code  = v-gds-code
      and buf_parts-attr.part-code = p-part-code
    no-error .
  if available buf_parts-attr
  then do:
    assign
      buf_parts-attr.alc-bottling-date        = p-alc-bottling-date
      buf_parts-attr.alc-certif-path          = p-alc-certif-path
      buf_parts-attr.alc-imp-type             = p-alc-imp-type
      buf_parts-attr.alc-imp-code             = p-alc-imp-code
      buf_parts-attr.alc-quality-certif-path  = p-alc-quality-certif-path
      buf_parts-attr.alc-ref-ab-path          = p-alc-ref-ab-path
      buf_parts-attr.mark-code                = p-mark-code
      buf_parts-attr.mark-db-num              = p-mark-db-num
    .
  end.
  for each ub.parts share-lock
    where ub.parts.in-code   = p-in-code
      and ub.parts.artic     = v-artic
      and ub.parts.prod-type = v-prod-type
      and ub.parts.prod-code = v-prod-code
      and ub.parts.part-code = p-part-code
      and (p-out-code = "" or ub.parts.out-code = p-out-code)
  on error undo main-block, return error
  :
    if ( ub.parts.alc-bottling-date       <> p-alc-bottling-date       )  or
       ( ub.parts.alc-certif-path         <> p-alc-certif-path         )  or
       ( ub.parts.alc-imp-type            <> p-alc-imp-type            )  or
       ( ub.parts.alc-imp-code            <> p-alc-imp-code            )  or
       ( ub.parts.alc-quality-certif-path <> p-alc-quality-certif-path )  or
       ( ub.parts.alc-ref-ab-path         <> p-alc-ref-ab-path         )  or
       ( ub.parts.mark-code               <> p-mark-code               )  or
       ( ub.parts.mark-db-num             <> p-mark-db-num             )
    then do:
      find first buf_parts exclusive-lock
        where recid(buf_parts) = recid(ub.parts)
        .
      assign
        buf_parts.alc-bottling-date        = p-alc-bottling-date
        buf_parts.alc-certif-path          = p-alc-certif-path
        buf_parts.alc-imp-type             = p-alc-imp-type
        buf_parts.alc-imp-code             = p-alc-imp-code
        buf_parts.alc-quality-certif-path  = p-alc-quality-certif-path
        buf_parts.alc-ref-ab-path          = p-alc-ref-ab-path
        buf_parts.mark-code                = p-mark-code
        buf_parts.mark-db-num              = p-mark-db-num
        iCounter                           = iCounter + 1
      .
    end.
  end.
  if iCounter > 0 then do:
    v-remote-db-list = "":U .
    for each buf_db where buf_db.db-num > 0 no-lock :
      assign
        v-remote-db-list = (if v-remote-db-list <> "":U then v-remote-db-list + chr(1)
                                                        else ""
                           ) + string(buf_db.db-num)
      .
    end.
    if g#db-num = 0 then do:
      assign
        v-send-db-list = v-remote-db-list
      .
    end.
    if g#db-num <> 0 and not g#news then do:
      assign
        v-send-db-list = "0":U
      .
    end.
    if v-send-db-list <> "":U then do:
      assign
        v-cmd = "command":U                 + chr(1)
              + "parts":U                   + chr(1)
              + "alc-attr":U                + chr(1)
              + string(v-gds-code)          + chr(1)
              + p-in-code                   + chr(1)
              + p-part-code                 + chr(1)
              + string(p-mark-db-num)       + chr(1)
              + (if p-mark-code = ? then "0" else string(p-mark-code)) + chr(1)
              + (if p-alc-bottling-date = ? then "?" else string(p-alc-bottling-date)) + chr(1)
              + p-alc-ref-ab-path           + chr(1)
              + p-alc-quality-certif-path   + chr(1)
              + p-alc-certif-path           + chr(1)
              + p-alc-imp-type              + chr(1)
              + (if p-alc-imp-code = ? then "0" else STRING(p-alc-imp-code)) + chr(1)
              + p-out-code
      .
      if v-cmd = ?
      then do:
        message substitute ('Ошибка генерации комманды - "&1"', ('command|parts|alc-attr'
          + "|" + string(v-gds-code) + "|" + p-in-code + "|" + p-part-code))
        view-as alert-box.
        return error substitute ('Ошибка генерации комманды - "&1"', ('command|parts|alc-attr'
          + "|" + string(v-gds-code) + "|" + p-in-code + "|" + p-part-code)).
      end.
      run nws/cr-route.p
        (input  'send-cmd':U
        ,input  v-cmd
        ,input  ?
        ,input  v-send-db-list
        ).
    end.
  end.
end.
