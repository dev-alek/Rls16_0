block-level on error undo, throw.
TRIGGER PROCEDURE FOR DELETE OF ub.rvs-doc.
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Триггер на удаление документа сверки ":U.
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
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table x_obj-group no-undo like ub.clients  .
define temp-table x_grp-obj-price no-undo like ub.grp-obj-price .
procedure metod-gop-obj :
  do
  on error undo, return error return-value
  :
define input  parameter p-cntxt-db-num as integer   no-undo .
define input  parameter p-gop-id       as integer   no-undo .
define input  parameter p-gop-db-num   as integer   no-undo .
define buffer buf1_clients for ub.clients  .
define buffer buf_db-grp-obj-price   for ub.db-grp-obj-price  .
define buffer buf_host-grp-obj-price for ub.host-grp-obj-price  .
define buffer buf_obj-grp-obj-price  for ub.obj-grp-obj-price  .
for each  x_obj-group : delete x_obj-group. end.
if p-gop-id = 0 or p-gop-id = ?  then do:
   if p-cntxt-db-num = 0  then do:
        for each buf1_clients no-lock where
                (buf1_clients.obj-type = 'маг':U  or
                 buf1_clients.obj-type = 'скл':U  )
                and
                buf1_clients.db-num >= 0  and
                buf1_clients.stts = 0
                :
          create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
        end.
   end.
   else do:
        for each buf1_clients no-lock where
                (buf1_clients.obj-type = 'маг':U  or
                 buf1_clients.obj-type = 'скл':U  ) and
                 buf1_clients.db-num = p-cntxt-db-num  and
                 buf1_clients.stts = 0
                :
          create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
        end.
   end.
end.
else do:
      for each buf_db-grp-obj-price  where
              buf_db-grp-obj-price.gop-id     = p-gop-id and
              buf_db-grp-obj-price.gop-db-num = p-gop-db-num and
              buf_db-grp-obj-price.stts = 0  no-lock :
        for each buf1_clients no-lock where
               (buf1_clients.obj-type = 'маг':U  or
                buf1_clients.obj-type = 'скл':U  ) and
                buf1_clients.db-num = buf_db-grp-obj-price.dgo-db-num  and
                buf1_clients.stts = 0
                :
          create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
        end.
      end.
    for each buf_host-grp-obj-price where
            buf_host-grp-obj-price.gop-id     = p-gop-id and
            buf_host-grp-obj-price.gop-db-num = p-gop-db-num and
            buf_host-grp-obj-price.stts = 0
            no-lock :
      for each buf1_clients no-lock where
             (buf1_clients.obj-type = 'маг':U  or
              buf1_clients.obj-type = 'скл':U  ) and
              buf1_clients.host-code = buf_host-grp-obj-price.host-code and
              buf1_clients.stts = 0
              :
          find first x_obj-group no-lock  where
                    x_obj-group.obj-code   = buf1_clients.obj-code and
                    x_obj-group.obj-type   = buf1_clients.obj-type no-error .
          if not available  x_obj-group then   create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
      end.
    end.
    for each buf_obj-grp-obj-price where
            buf_obj-grp-obj-price.gop-id     = p-gop-id and
            buf_obj-grp-obj-price.gop-db-num = p-gop-db-num and
            buf_obj-grp-obj-price.stts = 0
            no-lock :
      for each buf1_clients no-lock where
                buf1_clients.obj-type = buf_obj-grp-obj-price.obj-type and
                buf1_clients.obj-code = buf_obj-grp-obj-price.obj-code and
                buf1_clients.stts     = 0
                :
          find first  x_obj-group no-lock  where
                      x_obj-group.obj-code   = buf1_clients.obj-code and
                      x_obj-group.obj-type   = buf1_clients.obj-type no-error .
          if not available  x_obj-group then   create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
      end.
    end.
end.
end.
end procedure.
procedure metod-obj-in-gop :
define input  parameter p-curr-db-num as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define buffer buf_grp-obj-price for ub.grp-obj-price  .
  do
  on error undo, return error return-value
  :
    empty temp-table x_grp-obj-price.
    for each buf_grp-obj-price where
             buf_grp-obj-price.stts = 0
             no-lock :
               run metod-gop-obj (p-curr-db-num , buf_grp-obj-price.gop-id ,buf_grp-obj-price.gop-db-num) .
               for each x_obj-group where
                        x_obj-group.obj-type = p-obj-type and
                        x_obj-group.obj-code = p-obj-code :
                    create  x_grp-obj-price.
                    buffer-copy buf_grp-obj-price to x_grp-obj-price .
               end.
    end.
  end.
end procedure.
procedure metod-delobj-usr :
define input  parameter p-pdf-id  as integer   no-undo .
define input  parameter p-pdf-db  as integer   no-undo .
define input  parameter p-plt-id  as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define buffer buf_price-doc-forming-attr for ub.price-doc-forming-attr  .
  do
  on error undo, return error return-value
  :
for each buf_price-doc-forming-attr no-lock  where
         buf_price-doc-forming-attr.pdf-id =     p-pdf-id and
         buf_price-doc-forming-attr.pdf-db =     p-pdf-db and
         buf_price-doc-forming-attr.plt-id =     p-plt-id and
         buf_price-doc-forming-attr.plt-db-num = p-plt-db-num and
         buf_price-doc-forming-attr.attr-code begins "obj" :
   for each x_obj-group  where
            x_obj-group.obj-type = substring(buf_price-doc-forming-attr.attr-code,4,3) and
            x_obj-group.obj-code = int(substring(buf_price-doc-forming-attr.attr-code,7,20)) :
     delete x_obj-group.
   end.
end.
  if not can-find (first x_obj-group) then do:
     return "nullobj" .
  end.
end.
end procedure.
procedure metod-obj-pdf :
define input  parameter p-cntxt-db-num as integer   no-undo .
define input  parameter p-pdf-id     like ub.price-doc-forming.pdf-id   no-undo .
define input  parameter p-pdf-db-num like ub.price-doc-forming.pdf-db   no-undo .
define input  parameter p-plt-id     like ub.price-doc-forming.plt-id   no-undo .
define input  parameter p-plt-db-num like ub.price-doc-forming.plt-db-num  no-undo .
define buffer buf_price-list-type for ub.price-list-type  .
define buffer buf_price-doc-forming for ub.price-doc-forming  .
  do
  on error undo, return error return-value
  :
 for each  x_obj-group : delete x_obj-group. end.
 find first buf_price-list-type no-lock where
            buf_price-list-type.plt-id = p-plt-id and
            buf_price-list-type.plt-db-num = p-plt-db-num no-error .
if error-status :error then return error return-value .
 find first buf_price-doc-forming no-lock where
            buf_price-doc-forming.plt-id     = p-plt-id and
            buf_price-doc-forming.plt-db-num = p-plt-db-num and
            buf_price-doc-forming.pdf-id     = p-pdf-id and
            buf_price-doc-forming.pdf-db     = p-pdf-db-num
            no-error .
if error-status :error then return error return-value .
  run metod-gop-obj in this-procedure (
      p-cntxt-db-num,
      buf_price-list-type.gop-id ,
      buf_price-list-type.gop-db-num
      ) no-error .
  run metod-delobj-usr in this-procedure (
    buf_price-doc-forming.pdf-id ,
    buf_price-doc-forming.pdf-db ,
    buf_price-doc-forming.plt-id ,
    buf_price-doc-forming.plt-db-num
    ) no-error .
  end.
end procedure.
define variable v-initiator  as character no-undo.
case true:
  when g#auto then v-initiator = "Auto".
  when g#news then v-initiator = "Nws".
  when g#esys then v-initiator = "Esys".
  otherwise v-initiator = "User".
end case.
  define new global shared variable g#lib-rvs as handle no-undo.
define variable v-person as character no-undo.
define variable v-mess as character no-undo .
define variable v-value-character as character no-undo .
define variable v-date-close-period as date      no-undo .
define variable v-value-decimal as decimal   no-undo .
define variable v-value-integer as integer   no-undo .
define variable v-value-logical as logical   no-undo .
define variable v-value-type as character no-undo .
define variable v-vid-action  as integer  no-undo .
define variable v-vid-param   as longchar no-undo .
define variable varshift-date as date     no-undo.
define variable varshift-num  as integer  no-undo.
define variable varshift-name as char     no-undo.
Main-Block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  ub.rvs-doc.obj-type
  ,input  ub.rvs-doc.obj-code
  ,output varshift-date
  ,output varshift-num
  ,output varshift-name
  ) no-error .
  if ( ub.rvs-doc.status_ = 'факт':U
      and ub.rvs-doc.is-del <> true
     )
    or ( g#news = false
         and ub.rvs-doc.status_ <> 'новый':U
         and ub.rvs-doc.status_ <> 'факт':U
        )
  then do:
    assign
      v-mess = substitute( "&1 &2&3"
                           + "Документ сверки может быть удален только в статусе новый или факт&3"
                           + "Сверка &4&3"
                           + "Складской документ &5&3"
                           + "Тип сверки &6&3"
                           + "Статус сверки &7&3"
                           , vss-workfile
                           , vss-revision
                           , chr(10)
                           , ub.rvs-doc.rvs-code
                           , ub.rvs-doc.out-code
                           , ub.rvs-doc.rvs-type
                           , ub.rvs-doc.status_
                         )
    .
    if g#news = false then do:
      message
        v-mess skip
        view-as alert-box error .
    end.
    undo Main-Block, return error v-mess .
  end.
    if  (ub.rvs-doc.status_ = 'факт':U  and ub.rvs-doc.is-del = true)
        then
    do:
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_hstc-rvs in g#lib-rvs
( buffer ub.rvs-doc
 ,input integer('99':U)
 ,input ub.rvs-doc.rvs-code
 ,input dynamic-next-value('s-corr-chip':U,'ub':U)
) no-error.
        if error-status :error then
        do:
            message
                vss-workfile vss-revision vss-description skip
                substitute("Ошибка записи истории удаления документа сверки &1", ub.rvs-doc.rvs-code ) skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            undo main-block, return error .
        end.
    end.
  if ub.rvs-doc.status_ = 'факт':U
  and ub.rvs-doc.rvs-type <> 'проверка':U
  then do:
    run adm/shattri.p (
         input "get":U
        ,input ub.rvs-doc.obj-type
        ,input ub.rvs-doc.obj-code
        ,input 'nakl_par':U
        ,input  "date-close-period"
        ,output v-value-character
        ,output v-date-close-period
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-value-type
        ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
        ) no-error .
    if error-status :error then v-date-close-period = date('').
    if v-date-close-period <> date('') then do:
        if ub.rvs-doc.fact-date < v-date-close-period
        then do:
          message  substitute(
            "Дата закрытия сверки &1 более ранняя, чем дата закрытия периода &2
            Дата закрытия сверки     &3 &2
            Дата закрытия периода    &4 &2
            Объект &5 &6 "
            ,
            ub.rvs-doc.rvs-code  ,
            chr(10)  ,
            string ( ub.rvs-doc.fact-date , "99/99/9999" ) ,
            string ( v-date-close-period,   "99/99/9999") ,
                      x_obj-group.obj-type ,
                      x_obj-group.obj-code  ) view-as alert-box information .
            return.
        end.
    end.
  end.
  for each ub.doc-attr exclusive-lock
    where ub.doc-attr.doc-code = ub.rvs-doc.rvs-code
  on error undo Main-Block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  :
    delete ub.doc-attr.
  end.
  for each ub.rvs-line exclusive-lock
    where ub.rvs-line.rvs-code = ub.rvs-doc.rvs-code
  on error undo Main-Block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  :
    delete ub.rvs-line.
  end.
  for each ub.rvs-line-pump exclusive-lock
    where ub.rvs-line-pump.rvs-code = ub.rvs-doc.rvs-code
  on error undo Main-Block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  :
    delete ub.rvs-line-pump.
  end.
  if ub.rvs-doc.rvs-type <> 'проверка':U
  then do :
    define variable v-result as integer no-undo.
    if v-mess = "" then v-result = 0.
    else v-result = 1 .
    for first  ub.clients where ub.clients.obj-type = 'чел':U and  ub.clients.obj-code = ub.rvs-doc.boss no-lock :
        v-person = clients.obj-name.
    end.
    v-vid-action = 60.
    v-vid-param =
        "Initiator=" + v-initiator + chr(4) +
        "ResponsiblePerson=" + (if v-person <> ?  then v-person else "") + chr(4) +
        "SHOP_NUM=" + string(rvs-doc.obj-code) + chr(4) +
        "DocNum=" + string(rvs-doc.rvs-code) + chr(4) +
        "FactDate=" + (if string(rvs-doc.fact-date) = ? then '' else string(rvs-doc.fact-date)) + chr(4) +
        "DocType=" + string(rvs-doc.rvs-type) + chr(4) +
        "SHIFT_NUM_DOC=" + (if string(rvs-doc.shift-num) = ? then '' else string(rvs-doc.shift-num)) + (if string(rvs-doc.shift-date) = ? then '' else string(rvs-doc.shift-date , "99999999")) + chr(4) +
        "SHIFT_NUM=" + (if string(varshift-num) = ? then '' else string(varshift-num)) + (if string(varshift-date) = ? then '' else string(varshift-date, "99999999")) + chr(4) +
        "Status=" + string(rvs-doc.status_) + chr(4) +
        "RESULT=" + string( v-result ) + chr(4) +
        "Description=" + v-mess no-error.
    run trg/userlog.p (
        input 'delete':U
        , input 'rvs-doc':U
        , input ( buffer rvs-doc  :handle )
        , input v-vid-action
        , input v-vid-param
        ) no-error.
    if error-status :error
        then
    do:
        message substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
            , chr(10)
            , vss-workfile
            , return-value
            , error-status :get-message ( 1 ) )
            view-as alert-box.
        return no-apply.
    end.
  end .
  if g#db-num <> 0 then do:
    run nws/cmd-del.p
      ( input "rvs-doc":U
       ,input (buffer ub.rvs-doc:handle)
       ,input "":U
      ) no-error .
    if error-status :error then do:
      undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, chr(10), return-value, error-status :get-message ( 1 ) ).
    end.
  end.
  if g#oxml = yes then do:
    run str/calloxml.p
      ( input 'delete':U
       ,input 'rvs-doc':U
       ,input ( buffer ub.rvs-doc:handle )
      ) no-error.
    if error-status :error then do:
      undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                                    ,chr(10)
                                    ,vss-workfile
                                    ,return-value
                                    ,error-status :get-message ( 1 )
                                   ).
    end.
  end.
  if ub.rvs-doc.status_ = 'факт':U
  then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input 'event_rvs-doc':U
  ,input  buffer ub.rvs-doc:handle
  ,input ?
  ,input ''
  ,input ''
  ) no-error .
    if error-status :error
      then
    do:
      return error substitute( "&2&1Ошибка маршрутизации записи в машину правил&1&3&1&4"
        , chr(10)
        , vss-workfile
        , return-value
        , error-status :get-message ( 1 ) ).
    end.
  end.
end.
