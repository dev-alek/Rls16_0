block-level on error undo, throw.
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: wthcalib.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/wthcalib.p $":U .
define variable vss-description as character no-undo initial "Библиотека процедур для работы с атрибутами документа МЦ":U.
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
procedure wthcattr-sprcli :
define input parameter parparentproc  as widget-handle no-undo.
define input parameter p-mode  as character no-undo.
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
  DEFINE VARIABLE v-value as character no-undo .
  define variable v-cli-type as character no-undo .
  define variable v-cli-code as integer no-undo .
  define buffer buf_clients   for ub.clients.
  define variable v_rid as character no-undo.
  define variable ref-rec as recid no-undo .
  do
  on error undo, return error
  :
      v-value = p-value.
   if p-value <> '':U then do:
    assign
    v-cli-type = substring(p-value, 1, 3)
    v-cli-code = integer(substring(p-value, 4))
    no-error.
    if error-status:error then do:
      assign
      v-cli-type = '':U
      v-cli-code = 0
      .
    end.
   end.
   FIND FIRST buf_clients NO-LOCK WHERE
            buf_clients.obj-type = v-cli-type AND
            buf_clients.obj-code = v-cli-code  NO-ERROR.
   IF available(buf_clients) then do:
    run ref/cli-all.w (
                input parparentproc
               ,input if p-mode = 'ИЗМЕНЕНИЕ':U then "b-sel":U else "":U
               ,input v-cli-type
               ,input 'все':U
               ,input 'все':U
               ,input RECID( buf_clients )
               ,input ",,,,,,NO"
               ,input ?
               ,OUTPUT v_rid ).
  END.
  ELSE if p-mode = 'ИЗМЕНЕНИЕ':U then DO:
    run ref/cli-all.w (
                 input parparentproc
                ,INPUT "b-sel":U
               ,input  v-cli-type
               ,input 'все':U
               ,input 'текущие':U
               ,input ?
               ,input ",,,,,,NO"
               ,input ?
               ,OUTPUT v_rid ).
  END.
  else do:
    message
    if p-value = "":U then 'Атрибут не задан!'
    else substitute('Не найден клиент &1',p-value)
    view-as alert-box warning.
  end.
  IF v_rid <> ? AND v_rid <> "":U THEN DO:
    ASSIGN ref-rec = INT( v_rid ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        RETURN NO-APPLY.
    END.
    FIND FIRST buf_clients NO-LOCK WHERE
               RECID( buf_clients ) = ref-rec NO-ERROR.
    IF AVAIL buf_clients THEN DO:
      v-value = buf_clients.obj-type + string(buf_clients.obj-code, ">>>>>>>>9").
    end.
  end.
  if v-value <> p-value then do:
    p-value = v-value.
    p-setted = yes.
  end.
  end.
end procedure.
  define new global shared variable g#wthcalib as handle no-undo.
if valid-handle( g#wthcalib ) and g#wthcalib <> this-procedure :handle then do:
  message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 0 ) vss-description skip( 1 )
          "wthcalib.p: попытка повторной загрузки библиотеки" skip( 1 )
          g#wthcalib                     skip( 0 )
          g#wthcalib     :type           skip( 0 )
          g#wthcalib     :file-name      skip( 0 )
          valid-handle( g#wthcalib     ) skip( 0 )
          this-procedure :handle         skip( 0 )
          this-procedure :type           skip( 0 )
          this-procedure :file-name      skip( 0 )
          valid-handle( this-procedure ) skip( 0 )
  view-as alert-box error title " О Ш И Б К А  ! ! ! ".
  undo, return error "wthcalib.p: попытка повторной загрузки библиотеки".
end.
else do:
  assign
    g#wthcalib = this-procedure :handle
  .
end.
on delete of this-procedure do:
  assign
    g#wthcalib = ?
  .
end.
procedure wthcalib_wthat-val :
  define  input parameter p-doc-code like ub.wth-doc-attr.doc-code   no-undo.
  define  input parameter p-code     like ub.wth-doc-attr.attr-code  no-undo.
  define output parameter p-value    like ub.wth-doc-attr.attr-value no-undo.
  define output parameter p-type     as   character              no-undo.
  define buffer buf_wth-doc-attr for ub.wth-doc-attr.
  define variable v-format         as character no-undo.
  define variable v-fillin_width   as integer   no-undo.
  define variable v-fillin_height  as integer   no-undo.
  define variable v-label          as character no-undo.
  define variable v-user-can-edit  as logical   no-undo.
  define variable v-output-display as logical   no-undo.
  define variable v-other          as character no-undo.
  do on error undo, return error return-value :
if valid-handle( g#wthcalib ) <> yes then do:       run str/wthcalib.p persistent no-error.       if error-status :error or valid-handle( g#wthcalib ) <> yes then do:         message "Error starting wthcalib.p"    skip( 0 )                 g#wthcalib                     skip( 0 )                 g#wthcalib   :type             skip( 0 )                 g#wthcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run wthcalib_wthat-cod in g#wthcalib (  input p-code ,
                       output p-type ,
                       output v-format ,
                       output v-fillin_width ,
                       output v-fillin_height ,
                       output v-label ,
                       output v-user-can-edit ,
                       output v-output-display ,
                       output v-other ) no-error .
    if error-status :error then do: undo, return error return-value. end.
    find first buf_wth-doc-attr no-lock where
               buf_wth-doc-attr.doc-code  = p-doc-code and
               buf_wth-doc-attr.attr-code = p-code     no-error.
    assign p-value = ( if available buf_wth-doc-attr then buf_wth-doc-attr.attr-value else
                     ( if p-type = 'L':U then "no":U else "":U ) ).
  end.
end procedure.
procedure wthcalib_wthat-wrt :
  define input parameter p-doc-code like ub.wth-doc-attr.doc-code   no-undo.
  define input parameter p-code     like ub.wth-doc-attr.attr-code  no-undo.
  define input parameter p-value    like ub.wth-doc-attr.attr-value no-undo.
  define buffer buf_wth-doc-attr for ub.wth-doc-attr.
  define variable v-type           as character no-undo.
  define variable v-format         as character no-undo.
  define variable v-fillin_width   as integer   no-undo.
  define variable v-fillin_height  as integer   no-undo.
  define variable v-label          as character no-undo.
  define variable v-user-can-edit  as logical   no-undo.
  define variable v-output-display as logical   no-undo.
  define variable v-other          as character no-undo.
  do on error undo, return error return-value :
if valid-handle( g#wthcalib ) <> yes then do:       run str/wthcalib.p persistent no-error.       if error-status :error or valid-handle( g#wthcalib ) <> yes then do:         message "Error starting wthcalib.p"    skip( 0 )                 g#wthcalib                     skip( 0 )                 g#wthcalib   :type             skip( 0 )                 g#wthcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run wthcalib_wthat-cod in g#wthcalib (  input p-code ,
                       output v-type ,
                       output v-format ,
                       output v-fillin_width ,
                       output v-fillin_height ,
                       output v-label ,
                       output v-user-can-edit ,
                       output v-output-display ,
                       output v-other ) no-error .
    if error-status :error then do: undo, return error return-value. end.
    find first buf_wth-doc-attr exclusive-lock where
               buf_wth-doc-attr.doc-code  = p-doc-code and
               buf_wth-doc-attr.attr-code = p-code     no-error.
    if not available buf_wth-doc-attr then do:
      create buf_wth-doc-attr.
      assign buf_wth-doc-attr.doc-code  = p-doc-code
             buf_wth-doc-attr.attr-code = p-code.
    end.
    assign buf_wth-doc-attr.attr-value = p-value.
  end.
end procedure.
procedure wthcalib_wthat-xst :
  define  input parameter p-doc-code like ub.wth-doc-attr.doc-code  no-undo.
  define  input parameter p-code     like ub.wth-doc-attr.attr-code no-undo.
  define output parameter p-exist    as   logical               no-undo.
  define buffer buf_wth-doc-attr for ub.wth-doc-attr.
  define variable v-type           as character no-undo.
  define variable v-format         as character no-undo.
  define variable v-fillin_width   as integer   no-undo.
  define variable v-fillin_height  as integer   no-undo.
  define variable v-label          as character no-undo.
  define variable v-user-can-edit  as logical   no-undo.
  define variable v-output-display as logical   no-undo.
  define variable v-other          as character no-undo.
  do on error undo, return error return-value :
if valid-handle( g#wthcalib ) <> yes then do:       run str/wthcalib.p persistent no-error.       if error-status :error or valid-handle( g#wthcalib ) <> yes then do:         message "Error starting wthcalib.p"    skip( 0 )                 g#wthcalib                     skip( 0 )                 g#wthcalib   :type             skip( 0 )                 g#wthcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run wthcalib_wthat-cod in g#wthcalib (  input p-code ,
                       output v-type ,
                       output v-format ,
                       output v-fillin_width ,
                       output v-fillin_height ,
                       output v-label ,
                       output v-user-can-edit ,
                       output v-output-display ,
                       output v-other ) no-error .
    if error-status :error then do: undo, return error return-value. end.
    find first buf_wth-doc-attr no-lock where
               buf_wth-doc-attr.doc-code  = p-doc-code and
               buf_wth-doc-attr.attr-code = p-code     no-error.
    if available buf_wth-doc-attr then do: p-exist = yes. end.
  end.
end procedure.
procedure wthcalib_wthat-del:
  define  input parameter p-doc-code like ub.wth-doc-attr.doc-code  no-undo.
  define  input parameter p-code     like ub.wth-doc-attr.attr-code no-undo.
  define output parameter p-deleted  as   logical               no-undo.
  define buffer buf_wth-doc-attr for ub.wth-doc-attr.
  define variable v-type           as character no-undo.
  define variable v-format         as character no-undo.
  define variable v-fillin_width   as integer   no-undo.
  define variable v-fillin_height  as integer   no-undo.
  define variable v-label          as character no-undo.
  define variable v-user-can-edit  as logical   no-undo.
  define variable v-output-display as logical   no-undo.
  define variable v-other          as character no-undo.
  do on error undo, return error return-value :
if valid-handle( g#wthcalib ) <> yes then do:       run str/wthcalib.p persistent no-error.       if error-status :error or valid-handle( g#wthcalib ) <> yes then do:         message "Error starting wthcalib.p"    skip( 0 )                 g#wthcalib                     skip( 0 )                 g#wthcalib   :type             skip( 0 )                 g#wthcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run wthcalib_wthat-cod in g#wthcalib (  input p-code ,
                       output v-type ,
                       output v-format ,
                       output v-fillin_width ,
                       output v-fillin_height ,
                       output v-label ,
                       output v-user-can-edit ,
                       output v-output-display ,
                       output v-other ) no-error .
    if error-status :error then do: undo, return error return-value. end.
    find first buf_wth-doc-attr exclusive-lock where
               buf_wth-doc-attr.doc-code  = p-doc-code and
               buf_wth-doc-attr.attr-code = p-code     no-error no-wait.
    if not available buf_wth-doc-attr then do:
      assign p-deleted = no.
    end.
    else do:
      assign buf_wth-doc-attr.attr-value = '':U.
           assign p-deleted = yes.
    end.
  end.
end procedure.
procedure wthcalib_wthat-cod :
  define  input parameter p-code           as character no-undo.
  define output parameter p-type           as character no-undo.
  define output parameter p-format         as character no-undo.
  define output parameter p-fillin_width   as integer   no-undo.
  define output parameter p-fillin_height  as integer   no-undo.
  define output parameter p-label          as character no-undo.
  define output parameter p-user-can-edit  as logical   no-undo.
  define output parameter p-output-display as logical   no-undo.
  define output parameter p-other          as character no-undo.
  do on error undo, return error return-value :
    case p-code :
            when 'wthdsf':U then do:     assign p-label          = "Дата счета-фактуры"            p-type           = 'T':U            p-format         = "99/99/9999"            p-fillin_width   = 11            p-fillin_height  = 1            p-label          = "Дата счета-фактуры"            p-user-can-edit  = true            p-output-display = true            p-other          = 'nws':u .   end.
            when 'wthnsf':U then do:     assign p-label          = "Номер счета-фактуры"            p-type           = 'C':U            p-format         = "x(70)"            p-fillin_width   = 71            p-fillin_height  = 1            p-label          = "Номер счета-фактуры"            p-user-can-edit  = true            p-output-display = true            p-other          = 'nws':u .   end.
            when 'wthproxy':U then do:     assign p-label          = "Доверенность"            p-type           = 'C':U            p-format         = "x(70)"            p-fillin_width   = 71            p-fillin_height  = 1            p-label          = "Доверенность"            p-user-can-edit  = true            p-output-display = true            p-other          = 'nws':u .   end.
            when 'wthpaydoc':U then do:     assign p-label          = "Платежно-расчетный документ "            p-type           = 'C':U            p-format         = "x(70)"            p-fillin_width   = 71            p-fillin_height  = 1            p-label          = "Платежно-расчетный документ "            p-user-can-edit  = true            p-output-display = true            p-other          = 'nws':u .   end.
            when 'wthreceiver':U then do:     assign p-label          = "Мат. ответственное лицо контрагента"            p-type           = 'C':U            p-format         = "x(70)"            p-fillin_width   = 71            p-fillin_height  = 1            p-label          = "Мат. ответственное лицо контрагента"            p-user-can-edit  = true            p-output-display = true            p-other          = 'nws':u .   end.
            when 'wthreason':U then do:     assign p-label          = "Основание"            p-type           = 'C':U            p-format         = "x(70)"            p-fillin_width   = 71            p-fillin_height  = 1            p-label          = "Основание"            p-user-can-edit  = true            p-output-display = true            p-other          = 'nws':u .   end.
            when 'wthconsignee':U then do:     assign p-label          = "Грузополучатель"            p-type           = 'C':U            p-format         = "x(70)"            p-fillin_width   = 71            p-fillin_height  = 1            p-label          = "Грузополучатель"            p-user-can-edit  = true            p-output-display = true            p-other          = 'nws/spr=wthcattr-sprcli':u .   end.
      otherwise do:
        undo, return error substitute( 'неизвестный атрибут документа "&1"', p-code ).
      end.
    end case.
  end.
end procedure.
procedure wthcalib_wthat-oth :
  define input parameter p-doc-code as character no-undo.
  define input parameter p-code     as character no-undo.
  define input parameter p-value    as character no-undo.
  define variable v-type           as character no-undo.
  define variable v-format         as character no-undo.
  define variable v-fillin_width   as integer   no-undo.
  define variable v-fillin_height  as integer   no-undo.
  define variable v-label          as character no-undo.
  define variable v-user-can-edit  as logical   no-undo.
  define variable v-output-display as logical   no-undo.
  define variable v-other          as character no-undo.
  define buffer buf_wth-doc-attr for ub.wth-doc-attr.
  define buffer bf_wth-doc   for ub.wth-doc.
  do on error undo, return error return-value :
if valid-handle( g#wthcalib ) <> yes then do:       run str/wthcalib.p persistent no-error.       if error-status :error or valid-handle( g#wthcalib ) <> yes then do:         message "Error starting wthcalib.p"    skip( 0 )                 g#wthcalib                     skip( 0 )                 g#wthcalib   :type             skip( 0 )                 g#wthcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run wthcalib_wthat-cod in g#wthcalib (  input p-code ,
                       output v-type ,
                       output v-format ,
                       output v-fillin_width ,
                       output v-fillin_height ,
                       output v-label ,
                       output v-user-can-edit ,
                       output v-output-display ,
                       output v-other )  .
    if lookup( "nws":U, v-other,chr(47) ) > 0 then do:
      find first bf_wth-doc no-lock where
                 bf_wth-doc.doc-code = p-doc-code  no-error.
      if available bf_wth-doc and bf_wth-doc.status_ = 'факт':U then do:
        find first buf_wth-doc-attr no-lock where
                   buf_wth-doc-attr.doc-code  = p-doc-code and
                   buf_wth-doc-attr.attr-code = p-code     no-error.
        run str/callnews.p ( input "wth-doc-attr", input ( buffer buf_wth-doc-attr :handle ) ) no-error.
        if error-status :error then do:
          message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
                  "Невозможно маршрутизировать wth-doc-attr для отправки в новости" skip( 0 )
                  "Документ:" '"' + bf_wth-doc.doc-code    + '"' skip( 0 )
                  "Атрибут:"  '"' + buf_wth-doc-attr.attr-code + '"' skip( 0 )
                  error-status :get-message( 1 ) skip( 0 )
                  error-status :get-message( 2 ) skip( 0 )
                  error-status :get-message( 3 ) skip( 0 )
                  "return-value = " return-value skip( 0 )
          view-as alert-box error.
          undo, return error return-value.
        end.
      end.
    end.
  end.
end procedure.
