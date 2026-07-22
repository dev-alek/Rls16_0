define input parameter p-mode           as integer          no-undo.
define input parameter p-recipe-code    as character        no-undo.
define input parameter p-userid         as character        no-undo.
define input parameter p-date-1         as date             no-undo.
define input parameter p-date-2         as date             no-undo.
define input parameter p-gds-code       as integer          no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр истории рецепта.".
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
define variable vss-include-info0 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info1 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    define temp-table temp_bufcomp_field-param no-undo
        field fpm-key               as integer
        field table-name          as character
        field field-name           as character
        field field-new-label     as character
        index pi is primary unique
            fpm-key
        index fld
            table-name
            field-name
    .
    define temp-table temp_bufcomp_field-diff no-undo
        field fdd-key       as integer
        field fpm-key-old   as integer
        field fpm-key-new   as integer
        field value-old     as character
        field label-old     as character
        field value-new     as character
        field label-new     as character
        field diff          as character
        index pi is primary unique
            fdd-key
    .
    define variable v-bufcomp-fpm-key       as integer    no-undo.
    define variable v-bufcomp-fdd-key       as integer    no-undo.
PROCEDURE bufcomp-init-field-param :
    define buffer buf_temp_bufcomp_field-param      for temp_bufcomp_field-param.
do
for buf_temp_bufcomp_field-param
on error undo, return error
:
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "recipe-code     ":U )   , input trim( "Рецепт           ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "artic           ":U )   , input trim( "Артикул          ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "prod-type       ":U )   , input trim( "Тип производителя":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "prod-code       ":U )   , input trim( "Код производителя":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "brutto-qnty     ":U )   , input trim( "Брутто           ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "gds-code        ":U )   , input trim( "Код товара       ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "host-code       ":U )   , input trim( "Код фирмы        ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "is-default      ":U )   , input trim( "Основной         ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "obj-code        ":U )   , input trim( "Код объекта      ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "obj-type        ":U )   , input trim( "Тип объекта      ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "portion-qnty    ":U )   , input trim( "Кол.порций       ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "portion-weight  ":U )   , input trim( "Вес порции       ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "qnty            ":U )   , input trim( "Количество       ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "recipe-code     ":U )   , input trim( "Номер рецепта    ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "recipe-design   ":U )   , input trim( "Оформление       ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "recipe-name     ":U )   , input trim( "Назв.рецепта     ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "recipe-order    ":U )   , input trim( "Порядок          ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "recipe-quality  ":U )   , input trim( "Показ.качества   ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "recipe-ref-num  ":U )   , input trim( "Номер по спр.рец.":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "recipe-technique":U )   , input trim( "Технология       ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "recipe-template ":U )   , input trim( "Ссылка на спр.рец":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "recipe-type     ":U )   , input trim( "Тип рецепта      ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "sale-factor     ":U )   , input trim( "Кратность        ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "recipe-code     ":U )   , input trim( "Рецепт           ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "artic           ":U )   , input trim( "Артикул          ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "prod-type       ":U )   , input trim( "Тип производителя":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "prod-code       ":U )   , input trim( "Код производителя":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "brutto-qnty     ":U )   , input trim( "Брутто           ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "gds-code        ":U )   , input trim( "Код товара       ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "host-code       ":U )   , input trim( "Код фирмы        ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "is-default      ":U )   , input trim( "Основной         ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "obj-code        ":U )   , input trim( "Код объекта      ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "obj-type        ":U )   , input trim( "Тип объекта      ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "portion-qnty    ":U )   , input trim( "Кол.порций       ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "portion-weight  ":U )   , input trim( "Вес порции       ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "qnty            ":U )   , input trim( "Количество       ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "recipe-code     ":U )   , input trim( "Номер рецепта    ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "recipe-design   ":U )   , input trim( "Оформление       ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "recipe-name     ":U )   , input trim( "Назв.рецепта     ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "recipe-order    ":U )   , input trim( "Порядок          ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "recipe-quality  ":U )   , input trim( "Показ.качества   ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "recipe-ref-num  ":U )   , input trim( "Номер по спр.рец.":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "recipe-technique":U )   , input trim( "Технология       ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "recipe-template ":U )   , input trim( "Ссылка на спр.рец":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "recipe-type     ":U )   , input trim( "Тип рецепта      ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "sale-factor     ":U )   , input trim( "Кратность        ":U )   ).
end.
END PROCEDURE.
PROCEDURE bufcomp-set-field-param :
define input parameter p-table-name     as character  no-undo.
define input parameter p-field-name     as character  no-undo.
define input parameter p-field-label    as character  no-undo.
    define buffer buf_temp_bufcomp_field-param      for temp_bufcomp_field-param.
do
for buf_temp_bufcomp_field-param
on error undo, return error
:
    assign
        v-bufcomp-fpm-key = v-bufcomp-fpm-key + 1
    .
    create buf_temp_bufcomp_field-param.
    assign
        buf_temp_bufcomp_field-param.fpm-key           = v-bufcomp-fpm-key
        buf_temp_bufcomp_field-param.table-name        = p-table-name
        buf_temp_bufcomp_field-param.field-name        = p-field-name
        buf_temp_bufcomp_field-param.field-new-label   = p-field-label
    .
end.
END PROCEDURE.
PROCEDURE bufcomp-buffer-compare :
define input parameter p-old-buffer-handle  as handle           no-undo.
define input parameter p-new-buffer-handle  as handle           no-undo.
define input parameter p-except-field-list  as character        no-undo.
    define variable v-field-counter    as integer      no-undo.
    define variable v-old-field-handle as handle       no-undo.
    define variable v-new-field-handle as handle       no-undo.
    define buffer buf_old_temp_bufcomp_field-param      for temp_bufcomp_field-param.
    define buffer buf_new_temp_bufcomp_field-param      for temp_bufcomp_field-param.
    define buffer buf_temp_bufcomp_field-diff           for temp_bufcomp_field-diff.
do
for buf_old_temp_bufcomp_field-param
  , buf_new_temp_bufcomp_field-param
  , buf_temp_bufcomp_field-diff
on error undo, return error
:
    process-fields:
    do v-field-counter = 1 TO p-new-buffer-handle :num-fields
    :
        assign
            v-new-field-handle = p-new-buffer-handle :buffer-field( v-field-counter )
            v-old-field-handle = p-old-buffer-handle :buffer-field( v-new-field-handle :name )
        no-error.
        if not valid-handle( v-old-field-handle )
        or not valid-handle( v-new-field-handle )
        then do:
            next process-fields.
        end.
        if lookup( v-new-field-handle :name, p-except-field-list ) <> 0
        then do:
            next process-fields.
        end.
        else do:
            find first buf_old_temp_bufcomp_field-param
                 where buf_old_temp_bufcomp_field-param.table-name  = p-old-buffer-handle :name
                   and buf_old_temp_bufcomp_field-param.field-name  = v-old-field-handle :name
            no-error.
            find first buf_new_temp_bufcomp_field-param
                 where buf_new_temp_bufcomp_field-param.table-name  = p-new-buffer-handle :name
                   and buf_new_temp_bufcomp_field-param.field-name  = v-new-field-handle :name
            no-error.
            if v-new-field-handle :buffer-value <> v-old-field-handle :buffer-value
            then do:
                assign
                    v-bufcomp-fdd-key = v-bufcomp-fdd-key + 1
                .
                create buf_temp_bufcomp_field-diff.
                assign
                    buf_temp_bufcomp_field-diff.fdd-key     = v-bufcomp-fdd-key
                    buf_temp_bufcomp_field-diff.fpm-key-old = ( if available buf_old_temp_bufcomp_field-param then buf_old_temp_bufcomp_field-param.fpm-key else 0 )
                    buf_temp_bufcomp_field-diff.fpm-key-new = ( if available buf_new_temp_bufcomp_field-param then buf_new_temp_bufcomp_field-param.fpm-key else 0 )
                    buf_temp_bufcomp_field-diff.value-old   = string( v-old-field-handle :buffer-value )
                    buf_temp_bufcomp_field-diff.value-new   = string( v-new-field-handle :buffer-value )
                    buf_temp_bufcomp_field-diff.label-old = ( if available buf_old_temp_bufcomp_field-param then buf_old_temp_bufcomp_field-param.field-new-label else v-old-field-handle :label )
                    buf_temp_bufcomp_field-diff.label-new = ( if available buf_new_temp_bufcomp_field-param then buf_new_temp_bufcomp_field-param.field-new-label else v-new-field-handle :label )
                .
                case v-new-field-handle :data-type
                :
                    when "integer":U
                    then do:
                        assign
                            buf_temp_bufcomp_field-diff.diff = string( integer( buf_temp_bufcomp_field-diff.value-new ) - integer( buf_temp_bufcomp_field-diff.value-old ) )
                        .
                    end.
                    when "decimal":U
                    then do:
                        assign
                            buf_temp_bufcomp_field-diff.diff = string( decimal( buf_temp_bufcomp_field-diff.value-new ) - decimal( buf_temp_bufcomp_field-diff.value-old ) )
                        .
                    end.
                    when "character":U
                    then do:
                        assign
                            buf_temp_bufcomp_field-diff.diff = string( v-old-field-handle :buffer-value ) + " | ":U + string( v-new-field-handle :buffer-value )
                        .
                    end.
                    when "logical":U
                    then do:
                        assign
                            buf_temp_bufcomp_field-diff.diff = string( v-old-field-handle :buffer-value ) + " | ":U + string( v-new-field-handle :buffer-value )
                        .
                    end.
                end case.
            end.
        end.
    end.
end.
END PROCEDURE.
define temp-table temp_changes no-undo
    field field-name as character
    field field-label as character
    field value-old as character
    field value-new as character
    index pi is primary unique
            field-name
.
FUNCTION get-recipe-fields RETURNS CHARACTER
  ( p-field-id as integer, p-input-integer as integer, p-input-character as character )  FORWARD.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "В&ыход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON bt-filter
     LABEL "&Фильтр"
     SIZE 10 BY 1.
DEFINE QUERY BR-changes FOR
      temp_bufcomp_field-diff SCROLLING.
DEFINE QUERY br-table FOR
      c-recipe-hist SCROLLING.
DEFINE BROWSE BR-changes
  QUERY BR-changes DISPLAY
      temp_bufcomp_field-diff.label-new column-label "Изменилось" format "X(20)"
temp_bufcomp_field-diff.value-old column-label "Было" format "X(36)"
temp_bufcomp_field-diff.value-new column-label "Стало" format "X(36)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.5 BY 6.
DEFINE BROWSE br-table
  QUERY br-table NO-LOCK DISPLAY
      get-recipe-fields( input 1, input c-recipe-hist.action, input "":U ) COLUMN-LABEL "Действие" FORMAT "X(10)":U
      c-recipe-hist.recipe-type COLUMN-LABEL "Тип" FORMAT "X(1)":U
      get-recipe-fields( input 2, input 0, input c-recipe-hist.subject ) COLUMN-LABEL "Сост/Ингр" FORMAT "X(10)":U
      c-recipe-hist.corr-user-name COLUMN-LABEL "Пользователь" FORMAT "X(14)":U
      c-recipe-hist.corr-date COLUMN-LABEL "Дата" FORMAT "99/99/9999":U
      get-recipe-fields( input 3, input c-recipe-hist.corr-time, input "":U ) COLUMN-LABEL "Время" FORMAT "X(5)":U
      c-recipe-hist.recipe-code COLUMN-LABEL "Рецепт" FORMAT "X(12)":U
      get-recipe-fields( input 4, input c-recipe-hist.gds-code, input "":U ) COLUMN-LABEL "Товар" FORMAT "X(20)":U
      c-recipe-hist.recipe-chip-num
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.5 BY 14.75 EXPANDABLE.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     bt-filter AT ROW 1 COL 11
     b-help AT ROW 1 COL 89.5
     br-table AT ROW 2.5 COL 2
     BR-changes AT ROW 17.5 COL 2
     SPACE(0.37) SKIP(0.12)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "История рецепта"
         DEFAULT-BUTTON b-exit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
END.
ON VALUE-CHANGED OF br-table IN FRAME Dialog-Frame
DO:
    if available c-recipe-hist
    then do:
        run calc-changes in this-procedure (
              input c-recipe-hist.corr-user-db-num
            , input c-recipe-hist.chip-num
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка вычисления изменений по истории."
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return no-apply .
        end.
        OPEN QUERY br-changes FOR EACH temp_bufcomp_field-diff.
    end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  apply "value-changed" to br-table in frame Dialog-Frame .
  apply "entry" to b-exit.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE calc-changes :
define input parameter p-c-recipe-hist-db-num     as integer    no-undo.
define input parameter p-c-recipe-hist-chip-num   as integer    no-undo.
    define variable v-old-recipe-handle     as handle     no-undo.
    define variable v-new-recipe-handle     as handle     no-undo.
    define variable v-find-success          as logical      no-undo.
    define buffer buf_temp_bufcomp_field-diff       for temp_bufcomp_field-diff.
    define variable v-field-list    as character    no-undo.
    define buffer buf_old_c-recipe      for c-recipe.
    define buffer buf_old_c-recipe-gds  for c-recipe-gds.
    define buffer buf_c-recipe-hist     for c-recipe-hist.
do
for buf_c-recipe-hist
  , buf_temp_bufcomp_field-diff
on error undo, return error
:
    for each buf_temp_bufcomp_field-diff
    :
        delete buf_temp_bufcomp_field-diff.
    end.
    find first buf_c-recipe-hist no-lock
         where buf_c-recipe-hist.corr-user-db-num   = p-c-recipe-hist-db-num
           and buf_c-recipe-hist.chip-num = p-c-recipe-hist-chip-num
    .
    if buf_c-recipe-hist.action = integer( '99':U )
    then do:
    end.
    else do:
        create buffer v-old-recipe-handle for table substitute( "c-&1":U, buf_c-recipe-hist.subject ).
        assign
            v-find-success = v-old-recipe-handle :find-first(
                substitute( "where &1 = '&2' and &3 = &4 use-index pi"
                    , "recipe-code":U
                    , buf_c-recipe-hist.recipe-code
                    , "chip-num":U
                    , buf_c-recipe-hist.recipe-chip-num
                ), no-lock )
        no-error.
        if v-find-success = yes
        then do:
            create buffer v-new-recipe-handle for table substitute( "c-&1":U, buf_c-recipe-hist.subject ).
            assign
                v-find-success = v-new-recipe-handle :find-first(
                    substitute( "where &1 = '&2' and &3 > &4 use-index pi"
                        , "recipe-code":U
                        , buf_c-recipe-hist.recipe-code
                        , "chip-num":U
                        , buf_c-recipe-hist.recipe-chip-num
                    ), no-lock )
            no-error.
            if v-find-success = yes
            then do:
                run bufcomp-buffer-compare in this-procedure (
                      input v-old-recipe-handle
                    , input v-new-recipe-handle
                    , input "chip-num,corr-date,corr-time,corr-user-name,v-user-db-num":U
                ).
            end.
            else do:
                create buffer v-new-recipe-handle for table buf_c-recipe-hist.subject.
                assign
                    v-find-success = v-new-recipe-handle :find-first(
                        substitute( "where &1 = '&2' use-index pi"
                            , "recipe-code":U
                            , buf_c-recipe-hist.recipe-code
                        ), no-lock )
                no-error.
                if v-find-success = yes
                then do:
                    run bufcomp-buffer-compare in this-procedure (
                            input v-old-recipe-handle
                        , input v-new-recipe-handle
                        , input "chip-num,corr-date,corr-time,corr-user-name,v-user-db-num":U
                    ).
                end.
            end.
            delete object v-old-recipe-handle.
        end.
        else
        delete object v-old-recipe-handle.
    end.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE b-exit bt-filter b-help br-table BR-changes
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  run open-query in this-procedure.
END PROCEDURE.
PROCEDURE open-query :
    define variable v-date-min      as date       no-undo.
    define variable v-date-max      as date       no-undo.
do
on error undo, return error
:
    assign
        v-date-min = ( if p-date-1 = ? then 01/01/0001 else p-date-1 )
        v-date-max = ( if p-date-2 = ? then 12/31/4999 else p-date-2 )
    .
    case p-mode
    :
        when 1
        then do:
            if p-userid = "":U
            then do:
                open query br-table
                    for each c-recipe-hist no-lock
                       where c-recipe-hist.recipe-code  = p-recipe-code
                         and c-recipe-hist.corr-date       >= v-date-min
                         and c-recipe-hist.corr-date       <= v-date-max
                    by c-recipe-hist.chip-num descending
                indexed-reposition.
            end.
            else do:
                open query br-table
                    for each c-recipe-hist no-lock
                       where c-recipe-hist.recipe-code  = p-recipe-code
                         and c-recipe-hist.corr-user-name  = p-userid
                         and c-recipe-hist.corr-date       >= v-date-min
                         and c-recipe-hist.corr-date       <= v-date-max
                    by c-recipe-hist.chip-num descending
                indexed-reposition.
            end.
        end.
        when 2
        then do:
            if p-recipe-code = "":U
            then do:
                open query br-table
                    for each c-recipe-hist no-lock
                       where c-recipe-hist.corr-user-name  = p-userid
                         and c-recipe-hist.corr-date       >= v-date-min
                         and c-recipe-hist.corr-date       <= v-date-max
                    by c-recipe-hist.corr-time
                indexed-reposition.
            end.
            else do:
                open query br-table
                    for each c-recipe-hist no-lock
                       where c-recipe-hist.corr-user-name  = p-userid
                         and c-recipe-hist.recipe-code  = p-recipe-code
                         and c-recipe-hist.corr-date       >= v-date-min
                         and c-recipe-hist.corr-date       <= v-date-max
                    by c-recipe-hist.corr-time
                indexed-reposition.
            end.
        end.
        when 3
        then do:
            if p-userid = "":U
            then do:
                open query br-table
                    for each c-recipe-hist no-lock
                       where c-recipe-hist.corr-date       >= v-date-min
                         and c-recipe-hist.corr-date       <= v-date-max
                    by c-recipe-hist.corr-user-name
                    by c-recipe-hist.corr-time
                indexed-reposition.
            end.
            else do:
                open query br-table
                    for each c-recipe-hist no-lock
                       where c-recipe-hist.corr-date       >= v-date-min
                         and c-recipe-hist.corr-date       <= v-date-max
                         and c-recipe-hist.corr-user-name  = p-userid
                    by c-recipe-hist.corr-time
                indexed-reposition.
            end.
        end.
        when 4
        then do:
            open query br-table
                for each c-recipe-hist no-lock
                   where c-recipe-hist.gds-code     = p-gds-code
                     and c-recipe-hist.corr-date       >= v-date-min
                     and c-recipe-hist.corr-date       <= v-date-max
                by c-recipe-hist.corr-time
            indexed-reposition.
        end.
    end case.
end.
END PROCEDURE.
FUNCTION get-recipe-fields RETURNS CHARACTER
  ( p-field-id as integer, p-input-integer as integer, p-input-character as character ) :
    case p-field-id
    :
        when 1
        then do:
            case p-input-integer
            :
                when integer( '1':U )
                then do:
                    return 'Создание':U.
                end.
                when integer( '2':U )
                then do:
                    return 'Изменение':U.
                end.
                when integer( '99':U )
                then do:
                    return 'Удаление':U.
                end.
            end case.
        end.
        when 2
        then do:
            case p-input-character
            :
                when 'recipe':U
                then do:
                    return "Составной".
                end.
                when 'recipe-gds':U
                then do:
                    return "Ингредиент".
                end.
            end case.
        end.
        when 3
        then do:
            return string( p-input-integer, "HH:MM":U ).
        end.
        when 4
        then do:
            define variable v-artic     as character  no-undo.
            define variable v-prod-type as character  no-undo.
            define variable v-prod-code as integer    no-undo.
            define variable v-gds-name  as character  no-undo.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run arptpc in g#library
  (input  p-input-integer
  ,output v-artic
  ,output v-prod-type
  ,output v-prod-code
  )  .
            return substitute( "&1 &2", v-artic, v-gds-name ).
        end.
    end case.
    RETURN "".
END FUNCTION.
