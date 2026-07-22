block-level on error undo, throw.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure get-ro_get-read-only :
  define output parameter p-ro-set as logical   no-undo .
  do
  on error  undo, return error substitute( "&1(get-ro_get-read-only). &2&3&4", vss-include-info0, return-value, error-status :get-message( 1 ) )
  on stop   undo, return error substitute( "&1(get-ro_get-read-only). stop", vss-include-info0 )
  on endkey undo, return error substitute( "&1(get-ro_get-read-only). endkey", vss-include-info0 )
  :
    if lookup( 'READ-ONLY':U, DBRESTRICTIONS('ub':U) ) > 0
    then do:
      assign
        p-ro-set = true
      .
    end.
    else do:
      assign
        p-ro-set = false
      .
    end.
  end.
end procedure.
define buffer buf_sys-ctrl for ub.sys-ctrl .
define buffer buf_db for ub.db .
    define variable v-version-developer-list    as character    no-undo.
    define variable v-version           as character no-undo .
    define variable v-locale            as character no-undo .
    define variable v-SVNRev            as integer   no-undo .
    define variable v-compilerVersion   as character no-undo .
    define variable v-compile-date      as date      no-undo .
    define variable v-time              as integer   no-undo .
    define variable v-comment           as character no-undo .
    define variable v-file-date         as date      no-undo .
    define variable v-file-time         as integer   no-undo .
    define variable v-releace           as integer   no-undo.
    define variable v-patch             as integer   no-undo.
    define variable v-branch            as integer   no-undo.
    define variable v-program-tag       as character    no-undo .
    define variable v-read-only         as logical      no-undo .
do
on error undo, return error return-value
:
    run gbl/vertag.p (
          output v-version
        , output v-locale
        , output v-SVNRev
        , output v-compilerVersion
        , output v-compile-date
        , output v-time
        , output v-comment
        , output v-file-date
        , output v-file-time
        , output v-releace
        , output v-patch
        , output v-branch
    ) .
    case v-locale
    :
        when "rus":U
        then do:
            assign
                v-locale = "Россия"
            .
        end.
        when "kaz":U
        then do:
            assign
                v-locale = "Казахстан"
            .
        end.
        otherwise do:
        end.
    end case.
    assign
        v-version = substitute( "&1 (&2)"
                                , v-version
                                , v-locale
                              )
    .
  run gbl/verinfo.p.
  run get-ro_get-read-only
    (output v-read-only
    ) .
  find first buf_sys-ctrl no-lock .
  find buf_db no-lock
    where buf_db.db-num = buf_sys-ctrl.db-num
    .
  message
         "Автоматизированная система управления"
    skip "торговым предприятием"
    skip "IBS Trade House"
    skip(1)
         "Версия:"  v-version
    skip "Дата компиляции:"  v-compile-date
    skip "Тэг:"  v-SVNRev
    skip "О версии:"  v-comment
    skip (1)
         "Версия Progress:" proversion
    skip "Комплектация Progress:" progress
    skip "Версия СУБД Progress:" dbversion("ub")
    skip(1)
         "БД:"  buf_db.db-name
    skip "Номер БД:"  buf_db.db-num
    skip "" (if v-read-only then "Режим только чтение" else '':U)
    view-as alert-box information .
end.
procedure add-developer :
define input parameter p-name       as character        no-undo.
    define variable v-last-string   as character    no-undo.
    define variable v-new-line      as logical      no-undo.
do
on error undo, return error
:
    assign
        v-new-line = no
    .
    if v-version-developer-list <> "":U
    then do:
        assign
            v-last-string = entry( num-entries( v-version-developer-list, chr(10) ), v-version-developer-list, chr(10) )
        .
        if length( v-last-string ) > 40
        then do:
            assign
                v-version-developer-list = v-version-developer-list + ",        " + chr(10)
                v-new-line               = yes
            .
        end.
    end.
    assign
        v-version-developer-list = substitute( "&1&2&3":U
                                    , v-version-developer-list
                                    , ( if v-version-developer-list = "":U
                                        or v-new-line = yes
                                        then "":U
                                        else ", ":U )
                                    , p-name
                                     )
    .
end.
end procedure.
