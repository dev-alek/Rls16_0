define input parameter p-form-name                  as character        no-undo.
define input parameter p-parameters-string-old      as character        no-undo.
define input parameter p-parameters-enabled-string  as character        no-undo.
define output parameter p-parameters-string-new     as character        no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Параметры печати формы для материальных ценностей".
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
define variable vss-include-info0 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    define temp-table Tmp#List no-undo like ub.ord-blank
        field id                        as integer
        field proc-name                 as character
        field proc-param                as character
        field print-options             as character
        field orient                    as character
        field orient-orientation        as character
        field orient-font-num           as integer
        field font-num                  as character
        field filtr                     as character
        field view_                     as integer  init 1
        field sys-key                   as character
        field sys-key-black             as character
        field type-parts                as character
        field type-parts-enabled        as logical
        field type-price                as character
        field type-price-enabled        as logical
        field type-scale                as character
        field type-scale-enabled        as logical
        field type-val                  as character
        field type-val-enabled          as logical
        field sort-name                 as character
        field sort-name-enabled         as logical
        field sort-gr                   as character
        field sort-gr-enabled           as logical
        field print-graft               as character
        field print-graft-enabled       as logical
        field no-vat                    as character
        field no-vat-enabled            as logical
        index pi is primary unique id
        index in-name
           blank-name
        index lu
            last-use
    .
    define temp-table temp_form-list no-undo
        field doc-code  as character
        field id        as integer
        field doc-type  as character
        field status_   as character
        field internal  as character
        field flag      as character
        index pi is primary unique
            doc-code
            id
        index idx
            id
    .
    define temp-table temp_menu-doc_disabled-doc-list no-undo
        field doc-code      as character
        field blank-name    as character
        field reason        as character
        index pi is primary unique
                doc-code
                blank-name
    .
    define variable v-menu-doc-sys-key              as character    no-undo.
    define variable v-menu-doc-doc-code             as character    no-undo.
    define variable v-menu-doc-doc-type             as character    no-undo.
    define variable v-menu-doc-ext-doc-type         as character    no-undo.
    define variable v-menu-doc-status_              as character    no-undo.
    define variable v-menu-doc-internal             as character    no-undo.
    define variable v-menu-doc-flag                 as character    no-undo.
    define variable v-menu-doc-item-counter         as integer      no-undo.
    define variable v-menu-doc-item-disabled        as logical      no-undo.
define variable vss-include-info1 as character format "X(65)":U no-undo initial "@(#)$Workfile$ $Revision$".
function check-entry-with-mask returns logical ( input p-element as character, input p-list as character, input p-delimiter as character ) :
  define variable p-entry   as logical   no-undo .
  define variable v-ind as integer   no-undo .
  if p-delimiter = "*":U then do:
    message
      vss-workfile "(check-entry-with-mask)" vss-revision vss-description skip
      substitute('Разделитель не может быть равный "&1"', p-delimiter ) skip
      view-as alert-box error .
    return ? .
  end.
  assign
    p-entry = true
  .
  if lookup( p-element, p-list, p-delimiter ) = 0 then do:
    assign
      p-entry = false
    .
    if num-entries( p-list, "*":U ) > 1 then do:
      block_check-list:
      do v-ind = 1 to num-entries( p-list, p-delimiter )
      :
        if p-element matches entry( v-ind, p-list, p-delimiter ) then do:
          assign
            p-entry = true
          .
          leave block_check-list .
        end.
      end.
    end.
  end.
  return p-entry .
end function .
    procedure menu-doc-create-menu-item
    :
    define input parameter p-type   as   character no-undo.
    define input parameter p-stat   as   character no-undo.
    define input parameter p-intr   as   character no-undo.
    define input parameter p-flag   as   character no-undo.
    define input parameter param-1  as   character no-undo.
    define input parameter param-2  as   character no-undo.
    define input parameter param-3  as   character no-undo.
    define input parameter param-4  as   character no-undo.
    define input parameter param-5  as   character no-undo.
    define input parameter param-6  as   character no-undo.
    define input parameter param-7  as   character no-undo.
    define input parameter param-8  as   character no-undo.
    define input parameter param-9  as   character no-undo.
    define input parameter param-10 as   character no-undo.
    define input parameter param-11 as   character no-undo.
    define input parameter param-12 as   character no-undo.
    do
    on error undo, return error
    :
        assign
            v-menu-doc-item-disabled = yes
        .
        if v-menu-doc-sys-key <> 'ExpertekIBS':U
        and ( ( param-10 <> "":U
                and check-entry-with-mask( v-menu-doc-sys-key, param-10, chr(44) ) = false
              )
              or ( param-12 <> "":U
                   and check-entry-with-mask( v-menu-doc-sys-key, param-12, chr(44) ) = true )
                 )
        then do:
            undo, return .
        end.
        if param-7 = "":U
        then do:
            undo, return .
        end.
        if param-1 = '*':U
        or lookup( p-type, param-1 ) > 0
        then do:
            if param-2 = '*':U
            or lookup( p-stat, param-2 ) > 0
            then do:
                if param-3 = '*':U
                or lookup( p-intr, param-3 ) > 0
                then do:
                    if param-4 = '*':U
                    or lookup( p-flag, param-4 ) > 0
                    then do:
                        assign
                            v-menu-doc-item-disabled = no
                        .
                        find first tmp#list
                             where tmp#list.blank-name     = param-5
                               and tmp#list.filtr          = param-6
                               and tmp#list.proc-name      = param-7
                               and tmp#list.proc-param     = param-8
                               and tmp#list.print-options  = param-9
                               and tmp#list.sys-key        = param-10
                               and tmp#list.orient         = param-11
                               and tmp#list.sys-key-black  = param-12
                        no-error.
                        if not available tmp#list
                        then do:
                            assign
                                v-menu-doc-item-counter = v-menu-doc-item-counter + 1
                            .
                            create tmp#list.
                            assign
                                tmp#list.id             = v-menu-doc-item-counter
                                tmp#list.cli-code       = v-menu-doc-item-counter
                                tmp#list.blank-name     = param-5
                                tmp#list.filtr          = param-6
                                tmp#list.proc-name      = param-7
                                tmp#list.proc-param     = param-8
                                tmp#list.print-options  = param-9
                                tmp#list.sys-key        = param-10
                                tmp#list.orient         = param-11
                                tmp#list.sys-key-black  = param-12
                            .
                            assign
                                tmp#list.orient-orientation     = entry( 1, tmp#list.orient )
                                tmp#list.orient-font-num        = 7
                            .
                            assign
                                tmp#list.orient-font-num      = ( if num-entries( tmp#list.orient ) > 1
                                                                  then integer( entry( 2, tmp#list.orient ) )
                                                                  else 7 )
                            no-error.
                            if error-status :error
                            then do:
                                assign
                                    tmp#list.orient-font-num = 7
                                .
                            end.
                            run menu-doc-set-visible-options in this-procedure (
                                  input tmp#list.print-options
                                , output tmp#list.type-parts-enabled
                                , output tmp#list.type-price-enabled
                                , output tmp#list.type-scale-enabled
                                , output tmp#list.type-val-enabled
                                , output tmp#list.sort-name-enabled
                                , output tmp#list.sort-gr-enabled
                                , output tmp#list.print-graft-enabled
                                , output tmp#list.no-vat-enabled
                            ).
                        end.
                    end.
                end.
            end.
        end.
        if v-menu-doc-item-disabled = yes
        then do:
            find first tmp#list
                 where tmp#list.blank-name     = param-5
                   and tmp#list.filtr          = param-6
                   and tmp#list.proc-name      = param-7
                   and tmp#list.proc-param     = param-8
                   and tmp#list.print-options  = param-9
                   and tmp#list.sys-key        = param-10
                   and tmp#list.orient         = param-11
                   and tmp#list.sys-key-black  = param-12
            no-error.
            if available tmp#list
            then do:
                find first temp_menu-doc_disabled-doc-list
                     where temp_menu-doc_disabled-doc-list.doc-code     = v-menu-doc-doc-code
                       and temp_menu-doc_disabled-doc-list.blank-name   = param-5
                no-error.
                if not available temp_menu-doc_disabled-doc-list
                then do:
                    create temp_menu-doc_disabled-doc-list.
                    assign
                        temp_menu-doc_disabled-doc-list.doc-code    = v-menu-doc-doc-code
                        temp_menu-doc_disabled-doc-list.blank-name  = param-5
                    .
                end.
                if param-1 <> '*':U
                and lookup( p-type, param-1 ) > 0
                then do:
                    assign
                        temp_menu-doc_disabled-doc-list.reason   = "type":U
                    .
                end.
                assign
                    temp_menu-doc_disabled-doc-list.reason = temp_menu-doc_disabled-doc-list.reason + ",":U
                .
                if param-2 <> '*':U
                and lookup( p-stat, param-2 ) > 0
                then do:
                    assign
                        temp_menu-doc_disabled-doc-list.reason = temp_menu-doc_disabled-doc-list.reason + "stat":U
                    .
                end.
                assign
                    temp_menu-doc_disabled-doc-list.reason = temp_menu-doc_disabled-doc-list.reason + ",":U
                .
                if param-3 <> '*':U
                and lookup( p-intr, param-3 ) > 0
                then do:
                    assign
                        temp_menu-doc_disabled-doc-list.reason = temp_menu-doc_disabled-doc-list.reason + "intr":U
                    .
                end.
                assign
                    temp_menu-doc_disabled-doc-list.reason = temp_menu-doc_disabled-doc-list.reason + ",":U
                .
                if param-4 <> '*':U
                and lookup( p-flag, param-4 ) > 0
                then do:
                    assign
                        temp_menu-doc_disabled-doc-list.reason = temp_menu-doc_disabled-doc-list.reason + "flag":U
                    .
                end.
                if v-menu-doc-sys-key = 'ExpertekIBS':U
                then do:
                    run menu-doc-extend-blank-name-for-IBS in this-procedure (
                          input tmp#list.blank-name
                        , input tmp#list.sys-key
                        , input Tmp#List.sys-key-black
                        , output tmp#list.blank-name
                    ).
                end.
            end.
            else do:
                assign
                    v-menu-doc-item-disabled = no
                .
            end.
        end.
        if v-menu-doc-item-disabled = no
        then do:
            find first tmp#list
                 where tmp#list.blank-name     = param-5
                   and tmp#list.filtr          = param-6
                   and tmp#list.proc-name      = param-7
                   and tmp#list.proc-param     = param-8
                   and tmp#list.print-options  = param-9
                   and tmp#list.sys-key        = param-10
                   and tmp#list.orient         = param-11
                   and tmp#list.sys-key-black  = param-12
            no-error.
            if available tmp#list
            then do:
                find first temp_form-list
                     where temp_form-list.doc-code  = v-menu-doc-doc-code
                       and temp_form-list.id        = tmp#list.id
                no-error.
                if not available temp_form-list
                then do:
                    create temp_form-list.
                    assign
                        temp_form-list.doc-code  = v-menu-doc-doc-code
                        temp_form-list.id        = tmp#list.id
                        temp_form-list.doc-type  = v-menu-doc-doc-type
                        temp_form-list.status_   = v-menu-doc-status_
                        temp_form-list.internal  = v-menu-doc-internal
                        temp_form-list.flag      = v-menu-doc-flag
                    .
                end.
                if v-menu-doc-sys-key = 'ExpertekIBS':U
                then do:
                    run menu-doc-extend-blank-name-for-IBS in this-procedure (
                          input tmp#list.blank-name
                        , input tmp#list.sys-key
                        , input Tmp#List.sys-key-black
                        , output tmp#list.blank-name
                    ).
                end.
            end.
        end.
    end.
    end procedure.
    procedure menu-doc-set-visible-options :
    define input parameter p-print-options          as character        no-undo.
    define output parameter p-type-parts-enabled    as logical          no-undo.
    define output parameter p-type-price-enabled    as logical          no-undo.
    define output parameter p-type-scale-enabled    as logical          no-undo.
    define output parameter p-type-val-enabled      as logical          no-undo.
    define output parameter p-sort-name-enabled     as logical          no-undo.
    define output parameter p-sort-gr-enabled       as logical          no-undo.
    define output parameter p-print-graft-enabled   as logical          no-undo.
    define output parameter p-no-vat-enabled        as logical          no-undo.
    do
    on error undo, return error
    :
        assign
            p-type-parts-enabled    = ( if substring( p-print-options, 1, 1 ) = "+" then yes else no )
            p-type-price-enabled    = ( if substring( p-print-options, 2, 1 ) = "+" then yes else no )
            p-type-scale-enabled    = ( if substring( p-print-options, 3, 1 ) = "+" then yes else no )
            p-type-val-enabled      = ( if substring( p-print-options, 4, 1 ) = "+" then yes else no )
            p-sort-name-enabled     = ( if substring( p-print-options, 5, 1 ) = "+" then yes else no )
            p-sort-gr-enabled       = ( if substring( p-print-options, 6, 1 ) = "+" then yes else no )
            p-print-graft-enabled   = ( if substring( p-print-options, 7, 1 ) = "+" then yes else no )
            p-no-vat-enabled        = ( if substring( p-print-options, 8, 1 ) = "+" then yes else no )
        .
    end.
    end procedure.
    procedure menu-doc-create-options-string :
    define input parameter p-tmp-list-id        as integer          no-undo.
    define output parameter p-options-string    as character        no-undo.
        define buffer buf_tmp#list      for tmp#list.
    do
    for buf_tmp#list
    on error undo, return error
    :
        find first buf_tmp#list
             where buf_tmp#list.id = p-tmp-list-id
        .
        assign
            p-options-string =  ( if trim( buf_tmp#list.type-parts  ) = "+":U then "+":U else "-":U )
                              + ( if trim( buf_tmp#list.type-price  ) = "+":U then "+":U else "-":U )
                              + ( if trim( buf_tmp#list.type-scale  ) = "+":U then "+":U else "-":U )
                              + ( if trim( buf_tmp#list.type-val    ) = "+":U then "+":U else "-":U )
                              + ( if trim( buf_tmp#list.sort-name   ) = "+":U then "+":U else "-":U )
                              + ( if trim( buf_tmp#list.sort-gr     ) = "+":U then "+":U else "-":U )
                              + ( if trim( buf_tmp#list.print-graft ) = "+":U then "+":U else "-":U )
                              + ( if trim( buf_tmp#list.no-vat      ) = "+":U then "+":U else "-":U )
        .
    end.
    end procedure.
    procedure menu-doc-set-options-string :
    define input parameter p-tmp-list-id            as integer          no-undo.
    define input parameter p-options-string         as character        no-undo.
        define buffer buf_tmp#list      for tmp#list.
    do
    for buf_tmp#list
    on error undo, return error
    :
        find first buf_tmp#list
             where buf_tmp#list.id = p-tmp-list-id
        .
        assign
            buf_tmp#list.type-parts  = ( if buf_tmp#list.type-parts-enabled     = yes then substitute( "  &1", substring( p-options-string, 1, 1 ) ) else " ":U )
            buf_tmp#list.type-price  = ( if buf_tmp#list.type-price-enabled     = yes then substitute( "  &1", substring( p-options-string, 2, 1 ) ) else " ":U )
            buf_tmp#list.type-scale  = ( if buf_tmp#list.type-scale-enabled     = yes then substitute( "  &1", substring( p-options-string, 3, 1 ) ) else " ":U )
            buf_tmp#list.type-val    = ( if buf_tmp#list.type-val-enabled       = yes then substitute( "  &1", substring( p-options-string, 4, 1 ) ) else " ":U )
            buf_tmp#list.sort-name   = ( if buf_tmp#list.sort-name-enabled      = yes then substitute( "  &1", substring( p-options-string, 5, 1 ) ) else " ":U )
            buf_tmp#list.sort-gr     = ( if buf_tmp#list.sort-gr-enabled        = yes then substitute( "  &1", substring( p-options-string, 6, 1 ) ) else " ":U )
            buf_tmp#list.print-graft = ( if buf_tmp#list.print-graft-enabled    = yes then substitute( "  &1", substring( p-options-string, 7, 1 ) ) else " ":U )
            buf_tmp#list.no-vat      = ( if buf_tmp#list.no-vat-enabled         = yes then substitute( "  &1", substring( p-options-string, 8, 1 ) ) else " ":U )
        .
    end.
    end procedure.
    procedure menu-doc-create-options-enabled-string :
    define input parameter p-tmp-list-id                as integer          no-undo.
    define output parameter p-options-enabled-string    as character        no-undo.
        define buffer buf_tmp#list      for tmp#list.
    do
    for buf_tmp#list
    on error undo, return error
    :
        find first buf_tmp#list
             where buf_tmp#list.id = p-tmp-list-id
        .
        assign
            p-options-enabled-string =  ( if buf_tmp#list.type-parts-enabled  = yes then "+":U else "-":U )
                                      + ( if buf_tmp#list.type-price-enabled  = yes then "+":U else "-":U )
                                      + ( if buf_tmp#list.type-scale-enabled  = yes then "+":U else "-":U )
                                      + ( if buf_tmp#list.type-val-enabled    = yes then "+":U else "-":U )
                                      + ( if buf_tmp#list.sort-name-enabled   = yes then "+":U else "-":U )
                                      + ( if buf_tmp#list.sort-gr-enabled     = yes then "+":U else "-":U )
                                      + ( if buf_tmp#list.print-graft-enabled = yes then "+":U else "-":U )
                                      + ( if buf_tmp#list.no-vat-enabled      = yes then "+":U else "-":U )
        .
    end.
    end procedure.
    procedure menu-doc-extend-blank-name-for-IBS :
    define input parameter p-in-blank-name      as character        no-undo.
    define input parameter p-sys-key            as character        no-undo.
    define input parameter p-sys-key-black      as character        no-undo.
    define output parameter p-out-blank-name    as character        no-undo.
    do
    on error undo, return error
    :
        assign
            p-out-blank-name = p-in-blank-name
        .
        if p-sys-key <> "":U
        then do:
            assign
                p-out-blank-name = substring( p-in-blank-name + " '" + p-sys-key + "'" , 1, 120 )
            .
        end.
        if p-sys-key-black <> ""
        then do:
            assign
                p-out-blank-name = substring( p-in-blank-name + " no-'" + p-sys-key-black + "'", 1, 120 )
            .
        end.
    end.
    end procedure.
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-exit AUTO-GO
     LABEL "В&вод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE ed-form-name AS CHARACTER
     VIEW-AS EDITOR NO-BOX
     SIZE 43 BY 2.75
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE tg-print-graft AS LOGICAL INITIAL no
     LABEL "Сортировка по артикулу"
     VIEW-AS TOGGLE-BOX
     SIZE 41 BY .83 NO-UNDO.
DEFINE VARIABLE tg-sort-gr AS LOGICAL INITIAL no
     LABEL "Сортировка по группе"
     VIEW-AS TOGGLE-BOX
     SIZE 41 BY .83 NO-UNDO.
DEFINE VARIABLE tg-sort-name AS LOGICAL INITIAL no
     LABEL "Сортировка по имени"
     VIEW-AS TOGGLE-BOX
     SIZE 41 BY .83 NO-UNDO.
DEFINE VARIABLE tg-type-price AS LOGICAL INITIAL no
     LABEL "Печать в ценах документа"
     VIEW-AS TOGGLE-BOX
     SIZE 41 BY .83 NO-UNDO.
DEFINE VARIABLE tg-type-scale AS LOGICAL INITIAL no
     LABEL "Печать по шкалам"
     VIEW-AS TOGGLE-BOX
     SIZE 41 BY .83 NO-UNDO.
DEFINE VARIABLE tg-type-val AS LOGICAL INITIAL no
     LABEL "Печать в рублях"
     VIEW-AS TOGGLE-BOX
     SIZE 41 BY .83 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-help AT ROW 1 COL 24.5
     b-cancel AT ROW 1 COL 34.5
     ed-form-name AT ROW 2.25 COL 1.5 NO-LABEL
     tg-type-price AT ROW 5.75 COL 3
     tg-type-scale AT ROW 6.75 COL 3
     tg-type-val AT ROW 7.75 COL 3
     tg-sort-name AT ROW 8.75 COL 3
     tg-sort-gr AT ROW 9.75 COL 3
     tg-print-graft AT ROW 10.75 COL 3
     SPACE(0.87) SKIP(0.70)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры печати формы"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       ed-form-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
    assign
        tg-type-price
        tg-type-scale
        tg-type-val
        tg-sort-name
        tg-sort-gr
        tg-print-graft
    .
    assign
        p-parameters-string-new =   ( if tg-type-price    = yes then "+":U else "-":U )
                                  + ( if tg-type-scale    = yes then "+":U else "-":U )
                                  + ( if tg-type-val      = yes then "+":U else "-":U )
                                  + ( if tg-sort-name     = yes then "+":U else "-":U )
                                  + ( if tg-sort-gr       = yes then "+":U else "-":U )
                                  + ( if tg-print-graft   = yes then "+":U else "-":U )
    .
END.
ON CHOOSE OF b-help IN FRAME Dialog-Frame
OR HELP OF FRAME Dialog-Frame
DO:
END.
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-exit :sensitive then DO: apply "CHOOSE":U to b-exit in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F1 of frame Dialog-Frame anywhere do:
  if b-help :sensitive then DO: apply "CHOOSE":U to b-help in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   run init-fields in this-procedure .
  RUN enable_UI.
  run disable-fields in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable-fields :
do
with frame Dialog-Frame
on error undo, return error
:
    if substring( p-parameters-enabled-string, 1, 1 ) <> "+":U
    then do:
        disable
            tg-type-price
        .
    end.
    if substring( p-parameters-enabled-string, 2, 1 ) <> "+":U
    then do:
        disable
            tg-type-scale
        .
    end.
    if substring( p-parameters-enabled-string, 3, 1 ) <> "+":U
    then do:
        disable
            tg-type-val
        .
    end.
    if substring( p-parameters-enabled-string, 4, 1 ) <> "+":U
    then do:
        disable
            tg-sort-name
        .
    end.
    if substring( p-parameters-enabled-string, 5, 1 ) <> "+":U
    then do:
        disable
            tg-sort-gr
        .
    end.
    if substring( p-parameters-enabled-string, 6, 1 ) <> "+":U
    then do:
        disable
            tg-print-graft
        .
    end.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY ed-form-name tg-type-price tg-type-scale tg-type-val tg-sort-name
          tg-sort-gr tg-print-graft
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-help b-cancel ed-form-name tg-type-price tg-type-scale
         tg-type-val tg-sort-name tg-sort-gr tg-print-graft
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE init-fields :
    define variable v-void-logical      as logical      no-undo.
do
with frame Dialog-Frame
on error undo, return error
:
    assign
        ed-form-name :screen-value = p-form-name
    .
    run menu-doc-set-visible-options in this-procedure (
          input p-parameters-string-old
        , output tg-type-price
        , output tg-type-scale
        , output tg-type-val
        , output tg-sort-name
        , output tg-sort-gr
        , output tg-print-graft
        , output v-void-logical
    ).
    assign
        p-parameters-string-new = p-parameters-string-old
    .
end.
END PROCEDURE.
