/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для просмотра выгруженных файлов XML - документы

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Required:
    { bge/xmlview.i }

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


define stream xmlvdoc-in.

define variable v-xmlvdoc-current-file-row  as integer      no-undo.

define variable v-xmlvdoc-current-rowid     as rowid        no-undo.
define variable v-xmlvdoc-current-id        as integer      no-undo.
define variable v-xmlvdoc-current-tag-path  as character    no-undo.

&scoped-define max-xml-depth 3

define variable v-xmlvdoc-tag-list          as character extent 3 init[ "operation":U, "":U, "":U ]  no-undo.
define variable v-xmlvdoc-current-tag       as integer              no-undo.
define variable v-xmlvdoc-current-filename  as character    no-undo.

/*==========================================================================*/
procedure xmlvdoc-parse-file :
define input parameter p-filename       as character        no-undo.
define input parameter p-full-filename  as character        no-undo.

    define variable v-buffer-string    as character    no-undo.
do
on error undo, return error
:
    assign
        v-xmlvdoc-current-filename  = p-filename
        v-xmlview-export-type       = 'DOC':U
    .
    input stream xmlvdoc-in from value( p-full-filename ).
    repeat
    :
        import stream xmlvdoc-in unformatted
            v-buffer-string
        .
        assign
            v-xmlvdoc-current-file-row = v-xmlvdoc-current-file-row + 1
        .
        run xmlparse in this-procedure (
              input this-procedure
            , input v-buffer-string
            , input {&xmlparse-call-named-only}
        ).
    end.
end.
end procedure. /* parse-file */


/*==========================================================================*/
procedure cb-xmlparse-tag-start-doc :
define input parameter p-parameters-string  as character        no-undo.

    define buffer buf_temp_xmlview      for temp_xmlview.
do
for buf_temp_xmlview
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
        end.        /* when 'tree':U */
        when 'flat':U
        then do:        /* в плоском формате такого тэга нет */
            create buf_temp_xmlview.
            assign
                v-xmlvdoc-current-id        = v-xmlvdoc-current-id + 1
                buf_temp_xmlview.record-id  = v-xmlvdoc-current-id
                v-xmlvdoc-current-tag       = 1
                buf_temp_xmlview.filename   = v-xmlvdoc-current-filename
            .
        end.        /* when 'flat':U */
    end case.       /* case v-xmlview-format-type */
end.
end procedure. /* cb-tag-start-doc */

/*==========================================================================*/
procedure cb-xmlparse-tag-end-doc :
define input parameter p-parameters-string  as character        no-undo.

do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:        /* в деревянном формате такого тэга нет */
        end.        /* when 'tree':U */
        when 'flat':U
        then do:
            assign
                v-xmlvdoc-current-tag = 0
            .
        end.        /* when 'flat':U */
    end case.       /* case v-xmlview-format-type */
end.
end procedure. /* cb-tag-end-doc */


/*==========================================================================*/
procedure cb-xmlparse-tag-start-operation :
define input parameter p-parameters-string  as character        no-undo.

    define buffer buf_temp_xmlview      for temp_xmlview.
do
for buf_temp_xmlview
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
            create buf_temp_xmlview.
            assign
                v-xmlvdoc-current-id        = v-xmlvdoc-current-id + 1
                buf_temp_xmlview.record-id  = v-xmlvdoc-current-id
                v-xmlvdoc-current-tag       = 1
                buf_temp_xmlview.filename   = v-xmlvdoc-current-filename
            .
        end.        /* when 'tree':U */
        when 'flat':U
        then do:        /* в плоском формате такого тэга нет */

        end.        /* when 'flat':U */
    end case.       /* case v-xmlview-format-type */
end.
end procedure. /* cb-tag-start-operation */

/*==========================================================================*/
procedure cb-xmlparse-tag-end-operation :
define input parameter p-parameters-string  as character        no-undo.

do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
            assign
                v-xmlvdoc-current-tag = 0
            .
            if v-xmlvdoc-tag-list[ 2 ] <> "":U
            or v-xmlvdoc-tag-list[ 3 ] <> "":U
            then do:
                run xmlvdoc-error in this-procedure (
                    input substitute( "&2&1&3&1    &4,&1    &5,&1    &6"
                                        , {&new-line}
                                        , "При закрытии тэга операции"
                                        , "не был закрыт тэг предыдущего уровня. Список открытых тэгов:"
                                        , v-xmlvdoc-tag-list[ 1 ]
                                        , v-xmlvdoc-tag-list[ 2 ]
                                        , v-xmlvdoc-tag-list[ 3 ]
                                    )
                ).
            end.
        end.        /* when 'tree':U */
        when 'flat':U
        then do:        /* в плоском формате такого тэга нет */

        end.        /* when 'flat':U */
    end case.       /* case v-xmlview-format-type */
end.
end procedure. /* cb-tag-start-operation */

/*==========================================================================*/
procedure cb-xmlparse-tag-start-docID :
define input parameter p-parameters-string  as character        no-undo.

do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:        /* в деревянном формате такого тэга нет */

        end.        /* when 'tree':U */
        when 'flat':U
        then do:
            if v-xmlvdoc-current-tag = 1
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "docID":U
                    v-xmlvdoc-current-tag   = 2
                .
            end.
        end.        /* when 'flat':U */
    end case.       /* case v-xmlview-format-type */
end.
end procedure. /* cb-tag-start-docID */

/*==========================================================================*/
procedure cb-xmlparse-tag-end-docID :
define input parameter p-parameters-string  as character        no-undo.

do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:        /* в деревянном формате такого тэга нет */

        end.        /* when 'tree':U */
        when 'flat':U
        then do:
            if v-xmlvdoc-tag-list[ 2 ] = "docID":U
            and v-xmlvdoc-current-tag   = 2
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "":U
                    v-xmlvdoc-current-tag   = 1
                .
            end.
        end.        /* when 'flat':U */
    end case.       /* case v-xmlview-format-type */
end.
end procedure. /* cb-tag-end-docID */

/*==========================================================================*/
procedure cb-xmlparse-tag-start-referenceNo :
define input parameter p-parameters-string  as character        no-undo.

do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
            if v-xmlvdoc-current-tag = 1
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "referenceNo":U
                    v-xmlvdoc-current-tag   = 2
                .
            end.
        end.        /* when 'tree':U */
        when 'flat':U
        then do:        /* в плоском формате такого тэга нет */

        end.        /* when 'flat':U */
    end case.       /* case v-xmlview-format-type */
end.
end procedure. /* cb-tag-start-operation */

/*==========================================================================*/
procedure cb-xmlparse-tag-end-referenceNo :
define input parameter p-parameters-string  as character        no-undo.

do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
            if v-xmlvdoc-tag-list[ 3 ] <> "":U
            then do:
                run xmlvdoc-error in this-procedure (
                    input substitute( "&2&1&3&1    &4,&1    &5,&1    &6"
                                        , {&new-line}
                                        , "При закрытии тэга номера документа"
                                        , "не был закрыт тэг предыдущего уровня. Список открытых тэгов:"
                                        , v-xmlvdoc-tag-list[ 1 ]
                                        , v-xmlvdoc-tag-list[ 2 ]
                                        , v-xmlvdoc-tag-list[ 3 ]
                                    )
                ).
            end.
            if v-xmlvdoc-tag-list[ 2 ] = "referenceNo":U
            and v-xmlvdoc-current-tag   = 2
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "":U
                    v-xmlvdoc-current-tag   = 1
                .
            end.
        end.        /* when 'tree':U */
        when 'flat':U
        then do:        /* в плоском формате такого тэга нет */

        end.        /* when 'flat':U */
    end case.       /* case v-xmlview-format-type */
end.
end procedure. /* cb-tag-start-operation */

/*==========================================================================*/
procedure cb-xmlparse-tag-start-codeOperation :
define input parameter p-parameters-string  as character        no-undo.

do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
            if v-xmlvdoc-current-tag = 1
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "codeOperation":U
                    v-xmlvdoc-current-tag   = 2
                .
            end.
        end.        /* when 'tree':U */
        when 'flat':U
        then do:
            if v-xmlvdoc-current-tag = 1
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "codeOperation":U
                    v-xmlvdoc-current-tag   = 2
                .
            end.
        end.        /* when 'flat':U */
    end case.       /* case v-xmlview-format-type */
end.
end procedure. /* cb-tag-start-codeOperation */

/*==========================================================================*/
procedure cb-xmlparse-tag-end-codeOperation :
define input parameter p-parameters-string  as character        no-undo.

do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
            if v-xmlvdoc-tag-list[ 3 ] <> "":U
            then do:
                run xmlvdoc-error in this-procedure (
                    input substitute( "&2&1&3&1    &4,&1    &5,&1    &6"
                                        , {&new-line}
                                        , "При закрытии тэга кода операции"
                                        , "не был закрыт тэг предыдущего уровня. Список открытых тэгов:"
                                        , v-xmlvdoc-tag-list[ 1 ]
                                        , v-xmlvdoc-tag-list[ 2 ]
                                        , v-xmlvdoc-tag-list[ 3 ]
                                    )
                ).
            end.
            if v-xmlvdoc-tag-list[ 2 ] = "codeOperation":U
            and v-xmlvdoc-current-tag   = 2
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "":U
                    v-xmlvdoc-current-tag   = 1
                .
            end.
        end.        /* when 'tree':U */
        when 'flat':U
        then do:
            if v-xmlvdoc-tag-list[ 2 ] = "codeOperation":U
            and v-xmlvdoc-current-tag   = 2
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "":U
                    v-xmlvdoc-current-tag   = 1
                .
            end.
        end.        /* when 'flat':U */
    end case.       /* case v-xmlview-format-type */
end.
end procedure. /* cb-tag-end-codeOperation */


/*==========================================================================*/
procedure cb-xmlparse-tag-start-dateFact :
define input parameter p-parameters-string  as character        no-undo.

do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
            if v-xmlvdoc-current-tag = 1
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "dateFact":U
                    v-xmlvdoc-current-tag   = 2
                .
            end.
        end.        /* when 'tree':U */
        when 'flat':U
        then do:        /* в плоском формате такого тэга нет */
            if v-xmlvdoc-current-tag = 1
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "dateFact":U
                    v-xmlvdoc-current-tag   = 2
                .
            end.
        end.        /* when 'flat':U */
    end case.       /* case v-xmlview-format-type */
end.
end procedure. /* cb-tag-start-operation */

/*==========================================================================*/
procedure cb-xmlparse-tag-end-dateFact :
define input parameter p-parameters-string  as character        no-undo.

do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
            if v-xmlvdoc-tag-list[ 3 ] <> "":U
            then do:
                run xmlvdoc-error in this-procedure (
                    input substitute( "&2&1&3&1    &4,&1    &5,&1    &6"
                                        , {&new-line}
                                        , "При закрытии тэга фактической даты"
                                        , "не был закрыт тэг предыдущего уровня. Список открытых тэгов:"
                                        , v-xmlvdoc-tag-list[ 1 ]
                                        , v-xmlvdoc-tag-list[ 2 ]
                                        , v-xmlvdoc-tag-list[ 3 ]
                                    )
                ).
            end.
            if v-xmlvdoc-tag-list[ 2 ] = "dateFact":U
            and v-xmlvdoc-current-tag   = 2
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "":U
                    v-xmlvdoc-current-tag   = 1
                .
            end.
        end.        /* when 'tree':U */
        when 'flat':U
        then do:        /* в плоском формате такого тэга нет */
            if v-xmlvdoc-tag-list[ 2 ] = "dateFact":U
            and v-xmlvdoc-current-tag   = 2
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "":U
                    v-xmlvdoc-current-tag   = 1
                .
            end.
        end.        /* when 'flat':U */
    end case.       /* case v-xmlview-format-type */
end.
end procedure. /* cb-tag-start-operation */

/*==========================================================================*/
procedure cb-xmlparse-tag-start-dateDoc :
define input parameter p-parameters-string  as character        no-undo.

do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
            if v-xmlvdoc-current-tag = 1
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "dateDoc":U
                    v-xmlvdoc-current-tag   = 2
                .
            end.
        end.        /* when 'tree':U */
        when 'flat':U
        then do:        /* в плоском формате такого тэга нет */
            if v-xmlvdoc-current-tag = 1
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "dateDoc":U
                    v-xmlvdoc-current-tag   = 2
                .
            end.
        end.        /* when 'flat':U */
    end case.       /* case v-xmlview-format-type */
end.
end procedure. /* cb-tag-start-dateDoc */

/*==========================================================================*/
procedure cb-xmlparse-tag-end-dateDoc :
define input parameter p-parameters-string  as character        no-undo.

do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
            if v-xmlvdoc-tag-list[ 3 ] <> "":U
            then do:
                run xmlvdoc-error in this-procedure (
                    input substitute( "&2&1&3&1    &4,&1    &5,&1    &6"
                                        , {&new-line}
                                        , "При закрытии тэга даты документа"
                                        , "не был закрыт тэг предыдущего уровня. Список открытых тэгов:"
                                        , v-xmlvdoc-tag-list[ 1 ]
                                        , v-xmlvdoc-tag-list[ 2 ]
                                        , v-xmlvdoc-tag-list[ 3 ]
                                    )
                ).
            end.
            if v-xmlvdoc-tag-list[ 2 ] = "dateDoc":U
            and v-xmlvdoc-current-tag   = 2
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "":U
                    v-xmlvdoc-current-tag   = 1
                .
            end.
        end.        /* when 'tree':U */
        when 'flat':U
        then do:        /* в плоском формате такого тэга нет */
            if v-xmlvdoc-tag-list[ 2 ] = "dateDoc":U
            and v-xmlvdoc-current-tag   = 2
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "":U
                    v-xmlvdoc-current-tag   = 1
                .
            end.
        end.        /* when 'flat':U */
    end case.       /* case v-xmlview-format-type */
end.
end procedure. /* cb-tag-end-dateDoc */

/*==========================================================================*/
procedure cb-xmlparse-tag-start-docSum :
define input parameter p-parameters-string  as character        no-undo.

do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
            if v-xmlvdoc-current-tag = 1
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "docSum":U
                    v-xmlvdoc-current-tag   = 2
                .
            end.
        end.        /* when 'tree':U */
        when 'flat':U
        then do:        /* в плоском формате такой тэг на первом уровне */
            if v-xmlvdoc-current-tag = 0
            then do:
                assign
                    v-xmlvdoc-tag-list[ 1 ] = "docSum":U
                    v-xmlvdoc-current-tag   = 1
                .
            end.
        end.        /* when 'flat':U */
    end case.       /* case v-xmlview-format-type */
end.
end procedure. /* cb-tag-start-docSum */

/*==========================================================================*/
procedure cb-xmlparse-tag-end-docSum :
define input parameter p-parameters-string  as character        no-undo.

do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
            if v-xmlvdoc-tag-list[ 3 ] <> "":U
            then do:
                run xmlvdoc-error in this-procedure (
                    input substitute( "&2&1&3&1    &4,&1    &5,&1    &6"
                                        , {&new-line}
                                        , "При закрытии тэга суммы документа"
                                        , "не был закрыт тэг предыдущего уровня. Список открытых тэгов:"
                                        , v-xmlvdoc-tag-list[ 1 ]
                                        , v-xmlvdoc-tag-list[ 2 ]
                                        , v-xmlvdoc-tag-list[ 3 ]
                                    )
                ).
            end.
            if v-xmlvdoc-tag-list[ 2 ] = "docSum":U
            and v-xmlvdoc-current-tag   = 2
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "":U
                    v-xmlvdoc-current-tag   = 1
                .
            end.
        end.        /* when 'tree':U */
        when 'flat':U
        then do:        /* в плоском формате такой тэг на первом уровне */
            if v-xmlvdoc-tag-list[ 1 ] = "docSum":U
            and v-xmlvdoc-current-tag   = 1
            then do:
                assign
                    v-xmlvdoc-tag-list[ 1 ] = "":U
                    v-xmlvdoc-current-tag   = 0
                .
            end.
        end.        /* when 'flat':U */
    end case.       /* case v-xmlview-format-type */
end.
end procedure. /* cb-tag-end-docSum */

/*==========================================================================*/
procedure cb-xmlparse-tag-start-sumr :
define input parameter p-parameters-string  as character        no-undo.

do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
            if v-xmlvdoc-current-tag = 2
            and v-xmlvdoc-tag-list[ 2 ] = "docSum":U
            then do:
                assign
                    v-xmlvdoc-tag-list[ 3 ] = "sumr":U
                    v-xmlvdoc-current-tag   = 3
                .
            end.
        end.        /* when 'tree':U */
        when 'flat':U
        then do:
            if v-xmlvdoc-current-tag = 1
            and v-xmlvdoc-tag-list[ 1 ] = "docSum":U
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "sumr":U
                    v-xmlvdoc-current-tag   = 2
                .
            end.
        end.        /* when 'flat':U */
    end case.       /* case v-xmlview-format-type */
end.
end procedure. /* cb-tag-start-sumr */

/*==========================================================================*/
procedure cb-xmlparse-tag-end-sumr :
define input parameter p-parameters-string  as character        no-undo.

do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
            if v-xmlvdoc-tag-list[ 3 ] = "sumr":U
            and v-xmlvdoc-current-tag   = 3
            and v-xmlvdoc-tag-list[ 2 ] = "docSum":U
            then do:
                assign
                    v-xmlvdoc-tag-list[ 3 ] = "":U
                    v-xmlvdoc-current-tag   = 2
                .
            end.
        end.        /* when 'tree':U */
        when 'flat':U
        then do:
            if v-xmlvdoc-tag-list[ 2 ] = "sumr":U
            and v-xmlvdoc-current-tag   = 2
            and v-xmlvdoc-tag-list[ 1 ] = "docSum":U
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "":U
                    v-xmlvdoc-current-tag   = 1
                .
            end.
        end.        /* when 'flat':U */
    end case.       /* case v-xmlview-format-type */
end.
end procedure. /* cb-tag-end-sumr */

/*==========================================================================*/
procedure cb-xmlparse-tag-start-comment :
define input parameter p-parameters-string  as character        no-undo.

do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
            if v-xmlvdoc-current-tag = 1
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "comment":U
                    v-xmlvdoc-current-tag   = 2
                .
            end.
        end.        /* when 'tree':U */
        when 'flat':U
        then do:
            if v-xmlvdoc-current-tag = 1
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "comment":U
                    v-xmlvdoc-current-tag   = 2
                .
            end.
        end.        /* when 'flat':U */
    end case.       /* case v-xmlview-format-type */
end.
end procedure. /* cb-tag-start-comment */

/*==========================================================================*/
procedure cb-xmlparse-tag-end-comment :
define input parameter p-parameters-string  as character        no-undo.

do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
            if v-xmlvdoc-tag-list[ 3 ] <> "":U
            then do:
                run xmlvdoc-error in this-procedure (
                    input substitute( "&2&1&3&1    &4,&1    &5,&1    &6"
                                        , {&new-line}
                                        , "При закрытии тэга комментария"
                                        , "не был закрыт тэг предыдущего уровня. Список открытых тэгов:"
                                        , v-xmlvdoc-tag-list[ 1 ]
                                        , v-xmlvdoc-tag-list[ 2 ]
                                        , v-xmlvdoc-tag-list[ 3 ]
                                    )
                ).
            end.
            if v-xmlvdoc-current-tag   = 2
            and v-xmlvdoc-tag-list[ 2 ] = "comment":U
            then do:
/*                message*/
/*                    "X" v-xmlvdoc-current-tag*/
/*                    skip v-xmlvdoc-tag-list[ 1 ]*/
/*                    skip v-xmlvdoc-tag-list[ 2 ]*/
/*                    skip v-xmlvdoc-tag-list[ 3 ]*/
/*                view-as alert-box information.*/
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "":U
                    v-xmlvdoc-current-tag   = 1
                .
            end.
        end.        /* when 'tree':U */
        when 'flat':U
        then do:        /* в плоском формате такого тэга нет */

        end.        /* when 'flat':U */
    end case.       /* case v-xmlview-format-type */
end.
end procedure. /* cb-tag-end-comment */

/*==========================================================================*/
procedure cb-xmlparse-text :
define input parameter p-input-string  as character        no-undo.

    define variable v-success    as logical      no-undo.

    define buffer buf_temp_xmlview      for temp_xmlview.
do
for buf_temp_xmlview
on error undo, return error
:
    if v-xmlvdoc-current-tag > 0
    then do:
        case v-xmlvdoc-tag-list[ v-xmlvdoc-current-tag ]
        :
            when "docID":U
            then do:
                find first buf_temp_xmlview
                     where buf_temp_xmlview.record-id = v-xmlvdoc-current-id
                no-error.
                if available buf_temp_xmlview
                then do:
                    assign
                        buf_temp_xmlview.doc-code = p-input-string
                    .
                end.
            end.        /* when "docID":U */
            when "dateDoc":U
            then do:
                find first buf_temp_xmlview
                    where buf_temp_xmlview.record-id = v-xmlvdoc-current-id
                no-error.
                if available buf_temp_xmlview
                then do:
                    run xmlvdoc-assign-date in this-procedure (
                        input p-input-string
                        , output buf_temp_xmlview.doc-date
                        , output v-success
                    ).
                end.
            end.        /* when "dateDoc":U */
            when "dateFact":U
            then do:
                find first buf_temp_xmlview
                     where buf_temp_xmlview.record-id = v-xmlvdoc-current-id
                no-error.
                if available buf_temp_xmlview
                then do:
                    run xmlvdoc-assign-date in this-procedure (
                          input p-input-string
                        , output buf_temp_xmlview.fact-date
                        , output v-success
                    ).
                end.
            end.        /* when "dateFact":U */
            when "codeOperation":U
            then do:
                find first buf_temp_xmlview
                    where buf_temp_xmlview.record-id = v-xmlvdoc-current-id
                no-error.
                if available buf_temp_xmlview
                then do:
                    assign
                        buf_temp_xmlview.ext-doc-type = p-input-string
                    .
                end.
            end.        /* when "codeOperation":U */
            when "referenceNo":U
            then do:
                find first buf_temp_xmlview
                    where buf_temp_xmlview.record-id = v-xmlvdoc-current-id
                no-error.
                if available buf_temp_xmlview
                then do:
                    assign
                        buf_temp_xmlview.doc-code = p-input-string
                    .
                end.
            end.        /* when "referenceNo":U */
            when "sumr":U
            then do:
                find first buf_temp_xmlview
                     where buf_temp_xmlview.record-id = v-xmlvdoc-current-id
                no-error.
                if available buf_temp_xmlview
                then do:
/*                    message*/
/*                        "X" p-input-string*/
/*                        skip v-xmlvdoc-current-id*/
/*                        skip v-xmlvdoc-current-tag*/
/*                        skip v-xmlvdoc-tag-list[ 1 ]*/
/*                        skip v-xmlvdoc-tag-list[ 2 ]*/
/*                        skip v-xmlvdoc-tag-list[ 3 ]*/
/*                    view-as alert-box information.*/
                    run xmlvdoc-assign-decimal in this-procedure (
                          input p-input-string
                        , output buf_temp_xmlview.doc-sum
                        , output v-success
                    ).
                end.
            end.        /* when "sumr":U */
            when "comment":U
            then do:
                find first buf_temp_xmlview
                     where buf_temp_xmlview.record-id = v-xmlvdoc-current-id
                no-error.
                if available buf_temp_xmlview
                then do:
                    assign
                        buf_temp_xmlview.ps = buf_temp_xmlview.ps + p-input-string
                    .
                end.
            end.        /* when "comment":U */
        end case.       /* case v-xmlvdoc-current-tag */
    end.        /* if v-xmlvdoc-current-tag > 0  */
end.
end procedure. /* cb-xmlparse-tag-text */

/*==========================================================================*/
procedure xmlvdoc-assign-decimal :
define input parameter p-input-string       as character        no-undo.
define output parameter p-output-decimal    as decimal          no-undo.
define output parameter p-success           as logical          no-undo.

do
on error undo, return error
:
    assign
        p-output-decimal = decimal( p-input-string )
    no-error.
    if error-status :error
    then do:
        assign
            p-success           = no
            p-output-decimal    = 0.0
        .
    end.
    else do:
        assign
            p-success           = yes
        .
    end.
end.
end procedure. /* xmlvdoc-assign-decimal */

/*==========================================================================*/
procedure xmlvdoc-assign-date :
define input parameter p-input-string       as character        no-undo.
define output parameter p-output-date       as date             no-undo.
define output parameter p-success           as logical          no-undo.

do
on error undo, return error
:
    assign
        p-success       = no
        p-output-date   = ?
    .
    if num-entries( p-input-string, ".":U ) = 3
    then do:
        assign
            p-output-date = date(
                      integer( entry( 2, p-input-string, ".":U ) )
                    , integer( entry( 1, p-input-string, ".":U ) )
                    , integer( entry( 3, p-input-string, ".":U ) ) )
        no-error.
        if error-status :error <> yes
        then do:
            assign
                p-success           = yes
            .
        end.
    end.        /* if num-entries( p-input-string, ".":U ) = 3 */
end.
end procedure. /* xmlvdoc-assign-decimal */

/*==========================================================================*/
procedure cb-xmlparse-tag-start-linedoc :
define input parameter p-parameters-string  as character        no-undo.

do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
            if v-xmlvdoc-current-tag = 1
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "linedoc":U
                    v-xmlvdoc-current-tag   = 2
                .
            end.
        end.        /* when 'tree':U */
        when 'flat':U
        then do:        /* в плоском формате нет такого тэга */
        end.        /* when 'flat':U */
    end case.       /* case v-xmlview-format-type */
end.
end procedure. /* cb-tag-start-linedoc */

/*==========================================================================*/
procedure cb-xmlparse-tag-end-linedoc :
define input parameter p-parameters-string  as character        no-undo.

do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
            if v-xmlvdoc-tag-list[ 3 ] <> "":U
            then do:
                run xmlvdoc-error in this-procedure (
                    input substitute( "&2&1&3&1    &4,&1    &5,&1    &6"
                                        , {&new-line}
                                        , "При закрытии тэга строки документа"
                                        , "не был закрыт тэг предыдущего уровня. Список открытых тэгов:"
                                        , v-xmlvdoc-tag-list[ 1 ]
                                        , v-xmlvdoc-tag-list[ 2 ]
                                        , v-xmlvdoc-tag-list[ 3 ]
                                    )
                ).
            end.
            if v-xmlvdoc-tag-list[ 2 ] = "linedoc":U
            and v-xmlvdoc-current-tag   = 2
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "":U
                    v-xmlvdoc-current-tag   = 1
                .
            end.
        end.        /* when 'tree':U */
        when 'flat':U
        then do:        /* в плоском формате нет такого тэга */
        end.        /* when 'flat':U */
    end case.       /* case v-xmlview-format-type */
end.
end procedure. /* cb-tag-end-linedoc */

/*==========================================================================*/
procedure xmlvdoc-error :
define input parameter p-error-text     as character        no-undo.

    define buffer buf_temp_xmlview      for temp_xmlview.
do
for buf_temp_xmlview
on error undo, return error
:
    output to value( v-xmlvdoc-current-tag-path + "\xmlvdoc.log" ) append.
        find first buf_temp_xmlview
             where buf_temp_xmlview.record-id = v-xmlvdoc-current-id
        no-error.
        if available buf_temp_xmlview
        then do:
            put unformatted
                substitute( "Запись номер &1. Номер документа &2"
                            , buf_temp_xmlview.record-id
                            , buf_temp_xmlview.doc-code
                          )
            .
            put skip.
        end.
        put unformatted p-error-text.
        put skip.
    output close.
end.
end procedure. /* xmlvdoc-error */










/* $Workfile$ e n d */