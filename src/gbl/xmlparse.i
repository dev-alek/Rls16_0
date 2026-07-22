/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Разбор строки XML

Автор: Хныкин Павел Андреевич
Дата создания: 10/25/05
Author: Pavel Khnykin
Creation date: 10/25/05

Required:


Вызов:
  run xmlparse in this-procedure (
      input p-handle
    , input p-XML-buffer
    , input p-call-mode
  ) .

Параметры:
  p-handle      - handle вызывающей процедуры
  p-XML-buffer  - строка XML
  p-call-mode   - режим вызова callback-процедур:
                    {&xmlparse-call-all}            - вызывать все описанные ниже процедуры
                    {&xmlparse-call-named-only}     - вызывать только процедуры с именем тэга в названии и cb-xmlparse-text
                    {&xmlparse-call-unnamed-only}   - вызывать только процедуру cb-xmlparse-procedure-not-found

В вызывающей программе могут быть определены процедуры:
  cb-xmlparse-error (input char)
    - обработка ошибок
  cb-xmlparse-text (input char)
    - обработка чтения текста
  cb-xmlparse-tag-start-<имя_тэга>  (input char)
    - обработка события "начало тэга" (передается строка параметров)
  cb-xmlparse-tag-end-<имя_тэга>    (input char)
    - обработка события "конец тэга"
  cb-xmlparse-procedure-not-found (input char, input char, input char)
    - вызывается в случае, если не определена ни одна
      из процедур (кроме cb-xmlparse-error)
      первый параметр - тип события, может принимать значения:
          tag-start, tag-end, text
      второй параметр - значение
      третий - при tag-start, строка параметров
  При разборе строки выдается последовательность событий:
    cb-xmlparse-text -> cb-xmlparse-tag-start-... -> cb-xmlparse-tag-end-...
    -> cb-xmlparse-text -> cb-xmlparse-tag-start-... -> cb-xmlparse-tag-end-...
    ..................................................................
    -> cb-xmlparse-text

  Если функция не найдена, вызывается cb-xmlparse-procedure-not-found.
  Если функция cb-xmlparse-procedure-not-found не определена -
    вызывается cb-xmlparse-error.
  Если не определена и функция cb-xmlparse-error  - ошибка игнорируется.

*/
{ gbl/xmlchar.i  }

&global-define xmlparse-call-all "call-all":U
&global-define xmlparse-call-named-only "call-named":U
&global-define xmlparse-call-unnamed-only "call-unnamed":U

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


define temp-table temp_xmlparse-attrs no-undo
field field-name as character
field attr-code as character
field attr-value as character
index pi is unique primary
field-name attr-code
.

/*==========================================================================*/
procedure xmlparse :
define input parameter p-handle         as handle           no-undo.
define input parameter p-XML-buffer     as character        no-undo.
define input parameter p-call-mode      as character        no-undo.

    define variable v-procedure-type        as character    no-undo.
    define variable v-procedure-name        as character    no-undo.
    define variable v-temp-string           as character    no-undo.

    define variable v-current-position      as integer      no-undo.
    define variable v-end-position          as integer      no-undo.
    define variable v-text-position         as integer      no-undo.
    define variable v-input-buffer-length   as integer      no-undo.

    define variable v-handle                as handle       no-undo.
    define variable v-call-mode             as character    no-undo.
    define variable v-proc-type             as character    no-undo.
    define variable v-proc-name             as character    no-undo.
    define variable v-decode-string         as character    no-undo.
do
on error undo, return error
:
    if not valid-handle( p-handle )
    then do:
        return.
    end.
    assign
        v-end-position          = 1
        v-current-position      = 1
        v-input-buffer-length   = length( p-XML-buffer )
    .
    do
    while v-end-position < v-input-buffer-length
    :
        assign
            v-current-position = index( p-XML-buffer, "<":U, v-end-position )
        .
        if v-current-position = 0
        then do:
            /*---S------------- Поиск '<'. Если не найден - вызвать cb-xmlparse-text ---------------------*/
            assign
                v-decode-string = substring( p-XML-buffer, v-end-position )
            .
            run xmlchar-decode in this-procedure (
                  input v-decode-string
                , output v-temp-string
            ).
            assign
                v-handle     = p-handle
                v-call-mode  = p-call-mode
                v-proc-type  = 'text':U
                v-proc-name  = '':U
            .
            run run-callback-procedure in this-procedure (
                  input v-handle
                , input v-call-mode
                , input v-proc-type
                , input v-proc-name
                , input v-temp-string
            ).
            assign
                v-end-position = v-input-buffer-length
            .
            /*---E------------- Поиск '<'. Если не найден - вызвать cb-xmlparse-text ---------------------*/
        end.
        else do:
            /*---S-------- Поиск '<'. Если найден - вызвать callback-start или -end -------------------*/
            if v-current-position > v-end-position
            then do:                          /*Если до знака < был текст, то обработать его*/
                assign
                    v-decode-string = substring( p-XML-buffer, v-end-position, v-current-position - v-end-position )
                .
                run xmlchar-decode in this-procedure (
                      input v-decode-string
                    , output v-temp-string
                ).
                assign
                    v-end-position = v-current-position
                .
                assign
                    v-handle     = p-handle
                    v-call-mode  = p-call-mode
                    v-proc-type  = 'text':U
                    v-proc-name  = '':U
                .
                run run-callback-procedure in this-procedure (
                      input v-handle
                    , input v-call-mode
                    , input v-proc-type
                    , input v-proc-name
                    , input v-temp-string
                ).
            end.
            assign
                v-decode-string = substring( p-XML-buffer, v-end-position + 1, 1 )
            .
            if v-decode-string = "/":U
            then do:
                assign
                    v-procedure-type    = "tag-end":U
                    v-end-position      = v-current-position + 1
                .
            end.
            else do:
                assign
                    v-procedure-type    = "tag-start":U
                    v-end-position      = v-current-position
                .
            end.
            assign
                v-current-position  = index(p-XML-buffer, "/>":U, v-end-position)
            .
            if v-current-position <= v-end-position
            then do:
                assign
                    v-current-position  = index(p-XML-buffer, ">":U, v-end-position)
                .
            end.
            assign
                v-end-position      = v-end-position + 1
            .
            if v-current-position <= v-end-position      /* нет закрывающего знака тэга */
            then do:
                run run-cb-xmlparse-error in this-procedure
                                        (   input p-handle
                                        ,   input 'Ошибка: знак < без завершающего > на той же строке'
                                        ).
                assign
                    v-temp-string   = "<":U + substring(p-XML-buffer, v-end-position)
                    v-end-position  = v-input-buffer-length
                .
                assign
                    v-handle     = p-handle
                    v-call-mode  = p-call-mode
                    v-proc-type  = 'text':U
                    v-proc-name  = '':U
                .
                run run-callback-procedure in this-procedure (
                      input v-handle
                    , input v-call-mode
                    , input v-proc-type
                    , input v-proc-name
                    , input v-temp-string
                ).
            end.
            else do:
                assign
                    v-temp-string   = trim( substring(      p-XML-buffer
                                                        ,   v-end-position
                                                        ,   v-current-position - v-end-position
                                          )          )
                    v-text-position = index( v-temp-string, " ":U )
                .
                if v-text-position <> 0
                then do:
                    assign
                        v-procedure-name    =   trim( substring(      v-temp-string
                                                                    ,   1
                                                                    ,   v-text-position
                                                      )          )
                        v-temp-string       =   trim( substring(    v-temp-string
                                                                ,   v-text-position + 1
                                                    )          )
                    .
                end.
                else do:
                    assign
                        v-procedure-name    =   v-temp-string
                        v-temp-string       =   "":U
                    .
                end.
                assign
                    v-end-position      = v-current-position + 1
                .
                assign
                    v-handle          = p-handle
                    v-call-mode       = p-call-mode
                .
                run run-callback-procedure in this-procedure (
                      input v-handle
                    , input v-call-mode
                    , input v-procedure-type
                    , input v-procedure-name
                    , input v-temp-string
                ).
            end.
            /*---E-------- Поиск '<'. Если найден - вызвать callback-start или -end -------------------*/
        end.
    end.   /*do while...*/
end.
end procedure. /* xmlparse */



/*==========================================================================*/
procedure run-callback-procedure :
define input parameter p-handle             as handle           no-undo.
define input parameter p-call-mode          as character        no-undo.
define input parameter p-procedure-type     as character        no-undo.
define input parameter p-procedure-name     as character        no-undo.
define input parameter p-param-value        as character        no-undo.

    define variable v-data-type         as character            no-undo.
    define variable v-data-value        as character            no-undo.
    define variable v-procedure-name    as character            no-undo.
    define variable v-procedure-exists  as logical      no-undo.
do
on error undo, return error
:
    if p-call-mode = {&xmlparse-call-all}
    or p-call-mode = {&xmlparse-call-named-only}
    then do:
        case p-procedure-type :
            when "text":U
            then do:
                assign
                    v-procedure-name = "cb-xmlparse-text":U
                .
            end.
            when "tag-end":U
            then do:
                assign
                    v-procedure-name = "cb-xmlparse-tag-end-":U + p-procedure-name
                .
            end.
            when "tag-start":U
            then do:
                assign
                    v-procedure-name = "cb-xmlparse-tag-start-":U + p-procedure-name
                .
            end.
            otherwise do:
                assign
                    v-procedure-name = p-procedure-name
                .
            end.
        end case.
        /*if lookup( v-procedure-name, p-handle :internal-entries) > 0*/
        if p-handle :get-signature( v-procedure-name ) = "":U
        then do:
            assign
                v-procedure-exists = no
            .
        end.        /* if p-handle :get-signature( v-procedure-name ) = "":U */
        else do:
            assign
                v-procedure-exists = yes
            .
        end.        /* NOT ( if p-handle :get-signature( v-procedure-name ) = "":U ) */
        if v-procedure-exists = yes
        then do:
            run value(v-procedure-name) in p-handle (input p-param-value) no-error.
            if error-status :error
            then do:
                run run-cb-xmlparse-error in this-procedure (
                    input p-handle
                    , input "Ошибка при вызове программы " + v-procedure-name
                ).
            end.
        end.        /* if v-procedure-exists = yes */
    end.        /* if p-call-mode = {&xmlparse-call-all} */
    if ( p-call-mode = {&xmlparse-call-all}
        and v-procedure-exists <> yes )
    or p-call-mode = {&xmlparse-call-unnamed-only}
    then do:                           /* нет такой процедуры или включен третий метод обработки XML */
        case p-procedure-type :
            when 'text':U
            then do:
                assign
                    v-data-type     = 'text':U
                    v-data-value    = p-param-value
                .
            end.
            when 'tag-end':U
            then do:
                assign
                    v-data-type     = 'tag-end':U
                    v-data-value    = p-procedure-name
                .
            end.
            when 'tag-start':U
            then do:
                assign
                    v-data-type     = 'tag-start':U
                    v-data-value    = p-procedure-name
                .
            end.
            otherwise do:
                assign
                    v-data-type     = 'text':U
                    v-data-value    = p-procedure-name
                .
            end.
        end case.
        run run-cb-xmlparse-procedure-not-found in this-procedure (
              input p-handle
            , input v-data-type
            , input v-data-value
            , input p-param-value
        ).
    end.
end.
end procedure. /* run-callback-procedure */






/*==========================================================================*/
procedure run-cb-xmlparse-error :
do
on error undo, return error
:
    def input parameter p-handle            as handle no-undo.
    def input parameter p-error-message as char no-undo.

    if lookup("cb-xmlparse-error", p-handle :internal-entries) > 0
    then do:
        run cb-xmlparse-error in p-handle  (input p-error-message).
    end.
end.
end procedure. /* run-cb-xmlparse-error */





/*==========================================================================*/
procedure run-cb-xmlparse-procedure-not-found :
do
on error undo, return error
:
    def input parameter p-handle            as handle no-undo.
    def input parameter p-data-type         as char no-undo.
    def input parameter p-data-value        as char no-undo.
    def input parameter p-param-value       as char no-undo.

    if lookup("cb-xmlparse-procedure-not-found", p-handle :internal-entries) > 0
    then do:
        run cb-xmlparse-procedure-not-found in p-handle    (   input p-data-type
                                                          , input p-data-value
                                                          , input p-param-value
                                                        ) no-error.
        if error-status :error
        then do:
            run run-cb-xmlparse-error in this-procedure
                                    (   input p-handle
                                    ,   input "Ошибка при вызове программы cb-xmlparse-procedure-not-found"
                                    ).
        end.
    end.
    else do:
        run run-cb-xmlparse-error in this-procedure
                                (   input p-handle
                                ,   input "Ошибка: Не определена программа cb-xmlparse-procedure-not-found"
                                ).
    end.

end.
end procedure. /* cb-xmlparse-procedure-not-found */

procedure cb-xmlparse-attributes :
define input  parameter p-handle            as handle no-undo.
define input  parameter p-field-name        as character no-undo .
define input  parameter p-field-value       as character no-undo .

define variable ii as integer no-undo init 1.
define variable v-input-buffer-length   as integer no-undo.
define variable v-dc as logical no-undo .
define variable v-sc as logical no-undo .
define variable v-eq as logical no-undo .
define variable v-char as character no-undo .
define variable v-code as character no-undo .
define variable v-value as character no-undo .
define buffer buf_temp_xmlparse-attrs for temp_xmlparse-attrs.

  do
  on error undo, return error
  :
    if index(p-field-value, '>':U) > 0 then do:
      run run-cb-xmlparse-error in this-procedure
                              (   input p-handle
                              ,   input substitute("Ошибка: тэг &1 содержит другие тэги", p-field-name)
                              ).
    end.
    assign
    p-field-value = trim(p-field-value)
    .
    for each buf_temp_xmlparse-attrs where
            buf_temp_xmlparse-attrs.field-name = p-field-name:
      delete buf_temp_xmlparse-attrs.
    end.
    assign
    v-input-buffer-length = length( p-field-value )
    .

    do while ii <= v-input-buffer-length:
      assign
      v-char = substr(p-field-value, ii, 1)
      ii = ii + 1
      .
      CASE v-char:
        when "=":U then do:
          if v-eq
          and not v-dc
          and not v-sc then do:
            return error.
          end.
          assign
          v-eq = yes
          .
        end.
        when {&double-quote} then do:
        if v-eq then
        assign
        v-dc = not(v-dc)
        .
        else return error.
        end.
        when {&single-quote} then do:
        if v-eq then
        assign
        v-sc = not(v-sc)
        .
        else return error.
        end.
        when {&space-char} then do:
          if not v-dc
          and not v-sc
          then do:
            assign
            v-sc = no
            v-dc = no
            v-eq = no
            .
            create buf_temp_xmlparse-attrs.
            assign
            buf_temp_xmlparse-attrs.field-name = p-field-name
            buf_temp_xmlparse-attrs.attr-code  = v-code
            buf_temp_xmlparse-attrs.attr-value = trim(v-value, (if v-value begins {&double-quote} then {&double-quote} else {&single-quote}))
            v-code = "":U
            v-value = "":U
            .
          end.
        end.
      END CASE.
      if not v-eq
      then do:
        if not v-char = {&space-char} then
        assign
        v-code = v-code + v-char
        .
      end.
      else do:
        if v-char <> "=":U
        then
        assign
        v-value = v-value + v-char
        .
      end.
    end.
    if v-code <> "":U then do:
      create buf_temp_xmlparse-attrs.
      assign
      buf_temp_xmlparse-attrs.field-name = p-field-name
      buf_temp_xmlparse-attrs.attr-code  = v-code
      buf_temp_xmlparse-attrs.attr-value = trim(v-value, (if v-value begins {&double-quote} then {&double-quote} else {&single-quote}))
      .
    end.

  end.

end procedure. /* cb-xmlparse-attributes */

FUNCTION cb-xmlparse-get-attr returns character (
      input p-handle        as handle
    , input p-field-name    as character
    , input p-field-value   as character
    , input p-attr-code     as character
    , input p-reparse       as logical
) :
define buffer buf_temp_xmlparse-attrs for temp_xmlparse-attrs.
  do
  on error undo, return error
  :
    if p-reparse then do:
      run cb-xmlparse-attributes in this-procedure (
                                                    input p-handle
                                                  , input p-field-name
                                                  , input p-field-value) no-error .

      if error-status:error then return ? .
    end.
    find first buf_temp_xmlparse-attrs no-lock where
              buf_temp_xmlparse-attrs.field-name = p-field-name
          AND buf_temp_xmlparse-attrs.attr-code   = p-attr-code no-error .
    if not avail buf_temp_xmlparse-attrs then return ?.
    return buf_temp_xmlparse-attrs.attr-value.
  end.

end FUNCTION. /* get-attr-value */

FUNCTION cb-xmlparse-get-date returns date (
                                            input p-string as character):
define variable v-date as date.
if index(p-string, "-":U) = 0
or NOT (length(p-string) = 10
        or
        length(p-string) = 19)
then return error.
assign
v-date =  date(
          int( substr( p-string, 6, 2 ) ) ,
          int( substr( p-string, 9, 2 ) ),
          int( substr( p-string, 1, 4 ) )
            )
no-error .
if error-status:error then return error.
return v-date.
END FUNCTION.

FUNCTION cb-xmlparse-get-time returns integer (input p-string as character):
define variable v-time as integer no-undo .
define variable v-shift as integer no-undo .
if index(p-string, ":":U) = 0
or not (
        length(p-string) = 19
        or
        length(p-string) = 8
        )
then return error.
if length(p-string) = 19 then v-shift = 11.
assign
v-time =  int( substr( p-string, v-shift + 1, 2 ) ) * 3600 +
          int( substr( p-string, v-shift + 4, 2 ) ) * 60  +
          int( substr( p-string, v-shift + 7, 2) )
no-error .
if error-status:error then return error.
return v-time.
END FUNCTION.

/* $Workfile$ e n d */