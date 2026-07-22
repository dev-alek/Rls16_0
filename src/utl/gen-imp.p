block-level on error undo, throw.
/*

$Revision: b39224d84de3, 3188, rls $
$Author: EShklyar $
$Date: 2022/12/27 12:54:26 $
$Workfile: gen-imp.p $
$Archive: utl/gen-imp.p $

Генерация процедур импорта

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/27/03
Author: Dmitry Ukhanov
Creation date: 01/27/03

при импорте не используется attach-list ( news-list <> news-list + "," + attach-list )

*/
define input         parameter gen-dir       as character no-undo .
define input-output  parameter gen-file-list as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: b39224d84de3, 3188, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2022/12/27 12:54:26 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gen-imp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/gen-imp.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ nws/nws-tabs.i }

&glob std-vss-header-ukh {&start-comment} + {&new-line} + {&new-line} + {&dollar} + 'Revision: ':U + {&dollar} ~
+ {&new-line} + {&dollar} + 'Author: ':U + {&dollar} ~
+ {&new-line} + {&dollar} + 'Date: ':U + {&dollar} ~
+ {&new-line} + {&dollar} + 'Workfile: ':U + {&dollar} ~
+ {&new-line} + {&dollar} + 'Archive: ':U + {&dollar} ~
+ {&new-line} + {&new-line} + 'ФАЙЛ ГЕНЕРИРУЕТСЯ ПРОЦЕДУРОЙ ' + program-name(1) ~
+ {&new-line} + {&new-line} ~
+ {&new-line} + "Автор: Уханов Дмитрий Юрьевич":U ~
+ {&new-line} + "Дата создания: 01/27/03":U ~
+ {&new-line} + "Author: Dmitry Ukhanov":U ~
+ {&new-line} + "Creation date: 01/27/03":U ~
+ {&new-line} + {&new-line} ~
+ {&end-comment} + {&new-line}

define variable v-old-sys-alert-box    as logical   no-undo .

define variable v-lib-handle-name   as character no-undo .
define variable file-name           as character no-undo .
define variable file-name-no-ext    as character no-undo .
define variable temp-file-name      as character no-undo .
define variable tn                  as character no-undo init "".
define variable counter-step        as integer   no-undo .
define variable v-str               as character no-undo .
define variable v-num-tbls          as integer   no-undo .
define variable v-ind-tbl           as integer   no-undo init 0.
define variable v-ind-tbl-ignor     as integer   no-undo init 0.
define variable v-ind-tbl-curr      as integer   no-undo init 0.
define variable v-ind-comp          as integer   no-undo init 0.
define variable v-proc-num          as integer   no-undo init 0.
define variable v-err-num           as integer   no-undo .
define variable v-err-size          as integer   no-undo .
define variable v-skip-proc         as integer   no-undo .
define variable v-skip-proc-max     as integer   no-undo .
define variable v-skip-proc-step    as integer   no-undo .
define variable v-skip-proc-min     as integer   no-undo .
define variable v-compile           as logical   no-undo .
define variable inc-avail           as logical   no-undo init no.
define variable inc-file-name       as character no-undo init "".
define variable def-ins-avail       as logical   no-undo init no.
define variable def-ins-file-name   as character no-undo init "".
define variable def-out-avail       as logical   no-undo init no.
define variable def-out-file-name   as character no-undo init "".

define variable v-err-cmp as character no-undo .
define variable v-tmp-str as character no-undo .

define stream ImpStream .
define stream ImpPckStream .
define stream errstream .

&scop imp-pck1 "nws/imp-pck1.i":U
&scop imp-pck2 "nws/imp-pck2.i":U
&scop imp-pck3 "nws/imp-pck3.i":U


def frame ddd
  file-name format "x(32)" label "Файл" at row 1.5  col 17 colon-aligned
  fl as character format "x(32)" label "Таблица" at row 2.5  col 17 colon-aligned
  v-str format "x(35)" label "Обработано" at row 3.5  col 17 colon-aligned

  with view-as dialog-box side-labels three-d
  title "Генерация файлов " + program-name(1)
.

{ utl/gencredr.i gen-dir nws }

view frame ddd.

assign
  v-skip-proc-max  = 30
  v-skip-proc-step = 2
  v-skip-proc-min  = 2
  v-skip-proc      = v-skip-proc-max
  counter-step     = 0
  file-name        = "nws/load-rec.p":U
  file-name-no-ext = "load-rec":U
  temp-file-name   = substitute( "&1.p0":U, file-name-no-ext )
  gen-file-list    = gen-file-list + "," + {&imp-pck1}
                                   + "," + {&imp-pck2}
                                   + "," + {&imp-pck3}

.

OUTPUT STREAM ImpStream TO value( gen-dir + {&imp-pck1} ) .
PUT STREAM ImpStream UNFORMATTED
  {&std-vss-header-ukh} SKIP(1)
  '~&scoped-define vssseq ~{~&sequence~}             ' SKIP
  'define variable vss-include-info~{~&vssseq~} as character format "x(65)" no-undo initial "@(#)$Workfile: gen-imp.p $ $Revision: b39224d84de3, 3188, rls $".' SKIP(1)
  'define variable v-proc-name  as character no-undo .' SKIP
  'define variable v-proc-avail as logical   no-undo .' SKIP(1)
.
OUTPUT STREAM ImpStream CLOSE.

OUTPUT STREAM ImpStream TO value( gen-dir + {&imp-pck2} ) .
PUT STREAM ImpStream UNFORMATTED
  {&std-vss-header-ukh} SKIP(1)
  '~&scoped-define vssseq ~{~&sequence~}             ' SKIP
  'define variable vss-include-info~{~&vssseq~} as character format "x(65)" no-undo initial "@(#)$Workfile: gen-imp.p $ $Revision: b39224d84de3, 3188, rls $".' SKIP(1)
  'assign                                             ' SKIP
  '  v-proc-name = substitute( "proc-load-&1", ~{1} ) ' SKIP
  '  v-proc-avail = FALSE                             ' SKIP
  '.                                                  ' SKIP
.
OUTPUT STREAM ImpStream CLOSE.

OUTPUT STREAM ImpStream TO value( gen-dir + {&imp-pck3} ) .
PUT STREAM ImpStream UNFORMATTED
  {&std-vss-header-ukh} SKIP(1)
  '~&scoped-define vssseq ~{~&sequence~}             ' SKIP
  'define variable vss-include-info~{~&vssseq~} as character format "x(65)" no-undo initial "@(#)$Workfile: gen-imp.p $ $Revision: b39224d84de3, 3188, rls $".' SKIP(1)
.
OUTPUT STREAM ImpStream CLOSE.

assign
  v-ind-tbl  = 0
  v-proc-num = 0
  v-num-tbls = num-entries( news-list )
.

block_compile:
do while v-ind-tbl < v-num-tbls
:
  assign
    v-lib-handle-name = 'g#' + file-name-no-ext .
  .

  OUTPUT STREAM ImpStream TO value( gen-dir + {&imp-pck1} ) APPEND.
  PUT STREAM ImpStream UNFORMATTED
    SPACE(0) 'define new global shared variable ' v-lib-handle-name '  as handle no-undo .' SKIP(1)
  .
  OUTPUT STREAM ImpStream CLOSE.

  OUTPUT STREAM ImpStream TO value( gen-dir + {&imp-pck2} ) APPEND.
  PUT STREAM ImpStream UNFORMATTED
    SPACE(0) 'if (valid-handle(' v-lib-handle-name ') <> true) then do:                                           ' SKIP
    SPACE(0) '  run ' file-name ' persistent no-error .                                                           ' SKIP
    SPACE(0) '  if error-status :error or (valid-handle(' v-lib-handle-name ') <> true) then do:                  ' SKIP
    SPACE(0) '    message                                                                                         ' SKIP
    SPACE(0) '      "Error starting ' file-name '" skip                                                           ' SKIP
    SPACE(0) '      error-status :get-message(1) skip                                                             ' SKIP
    SPACE(0) '      return-value skip                                                                             ' SKIP
    SPACE(0) '      view-as alert-box error .                                                                     ' SKIP
    SPACE(0) '    stop .                                                                                          ' SKIP
    SPACE(0) '  end.                                                                                              ' SKIP
    SPACE(0) 'end.                                                                                                ' SKIP
    SPACE(0) 'if lookup( v-proc-name, ' v-lib-handle-name ':internal-entries ) > 0 then do:                       ' SKIP
    SPACE(0) '  if v-proc-avail = TRUE then do:                                                                   ' SKIP
    SPACE(0) '    return error substitute( "&1. Рассогласованы библиотеки приема новостей для таблицы &2"         ' SKIP
    SPACE(0) '                             ,vss-workfile                                                          ' SKIP
    SPACE(0) '                             ,~{1~}                                                                 ' SKIP
    SPACE(0) '                           ).                                                                       ' SKIP
    SPACE(0) '  end.                                                                                              ' SKIP
    SPACE(0) '  run value(v-proc-name) in ' v-lib-handle-name '                                                   ' SKIP
    SPACE(0) '      ( input this-procedure                                                                        ' SKIP
    SPACE(0) '       ,input ~{3~}                                                                                 ' SKIP
    SPACE(0) '       ,input ~{4~}                                                                                 ' SKIP
    SPACE(0) '      ).                                                                                            ' SKIP
    SPACE(0) '  assign                                                                                            ' SKIP
    SPACE(0) '    v-proc-avail = TRUE                                                                             ' SKIP
    SPACE(0) '  .                                                                                                 ' SKIP
    SPACE(0) 'end.                                                                                                ' SKIP(1)
  .
  OUTPUT STREAM ImpStream CLOSE.

  assign
    gen-file-list = gen-file-list + "," + file-name
  .
  OUTPUT STREAM ImpPckStream TO value( gen-dir + file-name ).

  PUT STREAM ImpPckStream UNFORMATTED
    {&std-vss-header-ukh} SKIP
    {&start-comment} + ' Импорт строки из файла ' + {&end-comment} SKIP(2)
    'define variable vss-revision    as character no-undo init "$Revision: b39224d84de3, 3188, rls $":U .                    ' SKIP
    'define variable vss-author      as character no-undo init "$Author: EShklyar $":U .                 ' SKIP
    'define variable vss-date        as character no-undo init "$Date: 2022/12/27 12:54:26 $":U .             ' SKIP
    'define variable vss-workfile    as character no-undo init "$Workfile: gen-imp.p $":U .             ' SKIP
    'define variable vss-archive     as character no-undo init "$Archive: utl/gen-imp.p $":U . ' SKIP
    'define variable vss-description as character no-undo init "загрузка в БД строки".                  ' SKIP
    '~{ cmp/vssrevis.i ~}                                                                               ' SKIP
    '~{ cmp/trg-def.i  ~}                                                                               ' SKIP
    '~{ nws/nws-def.i  ~}                                                                               ' SKIP
    '~{ gbl/key-rec.i  ~}                                                                               ' SKIP
    '~{ gbl/attr-lib.i  ~}                                                                              ' SKIP
    '~{ ' {&imp-pck1} ' ~}                                                                              ' SKIP(1)
  .
  OUTPUT STREAM ImpPckStream close.

  os-copy value( gen-dir + file-name ) value( gen-dir + temp-file-name ) .

  assign
    v-compile       = true
    v-ind-comp      = 0
    v-ind-tbl-curr  = 0
    v-ind-tbl-ignor = 0
  .

bl-tn:
  do while v-compile = true
           and v-ind-tbl < v-num-tbls
  :
    assign
      v-ind-tbl = v-ind-tbl + 1
      tn        = entry( v-ind-tbl, news-list )
    .
    display
      file-name
      tn @ fl
      substitute( "&1 из &2", v-ind-tbl, v-num-tbls ) @ v-str
      with frame ddd .
    find {&db-name_schema}._file no-lock
      where {&db-name_schema}._file._file-name = tn  no-error.
      if not available  {&db-name_schema}._file
      then do:
         message "Базе нет таблицы " tn
         view-as alert-box.
         next bl-tn.
      end. 
    assign
      inc-file-name     = "nws/inc/imp/" + {&db-name_schema}._File._Dump-name + ".i"
      inc-avail     = ( if search( inc-file-name ) <> ? then TRUE else FALSE )
      def-ins-file-name = "nws/inc/imp/def-ins/" + {&db-name_schema}._File._Dump-name + ".i"
      def-ins-avail = ( if search( def-ins-file-name ) <> ? then TRUE else FALSE )
      def-out-file-name = "nws/inc/imp/def-out/" + {&db-name_schema}._File._Dump-name + ".i"
      def-out-avail = ( if search( def-out-file-name ) <> ? then TRUE else FALSE )
      .

    if tn = "pck-rcvd":U
      or tn = "pck-sent":U
      or ( inc-avail = false
           and def-ins-avail = false
           and def-out-avail = false
         )
    then do:
      assign
        v-ind-tbl-ignor = v-ind-tbl-ignor + 1
      .
    end.
    else do:

      assign
        v-ind-tbl-curr = v-ind-tbl-curr + 1
        v-proc-num     = v-proc-num + 1
      .

      OUTPUT STREAM ImpPckStream TO value( gen-dir + file-name ) append.

      if v-ind-tbl-curr = 1 then do:
        PUT STREAM ImpPckStream UNFORMATTED
          SPACE(0) 'if valid-handle (' v-lib-handle-name ')                                 ' SKIP
          SPACE(0) 'and ' v-lib-handle-name ' <> this-procedure :handle                     ' SKIP
          SPACE(0) 'and lookup( "proc-load-' tn '":U, ' v-lib-handle-name ':internal-entries ) > 0 ' SKIP
          SPACE(0) 'then do:                                                                ' SKIP
          SPACE(0) '  message                                                               ' SKIP
          SPACE(0) '    vss-workfile vss-revision vss-description skip                      ' SKIP
          SPACE(0) '    "Попытка повторной загрузки библиотеки" skip                        ' SKIP
          SPACE(0) '    ' v-lib-handle-name ' skip                                          ' SKIP
          SPACE(0) '    ' v-lib-handle-name ' :type skip                                    ' SKIP
          SPACE(0) '    ' v-lib-handle-name ' :file-name skip                               ' SKIP
          SPACE(0) '    valid-handle(' v-lib-handle-name ') skip                            ' SKIP
          SPACE(0) '    this-procedure :handle skip                                         ' SKIP
          SPACE(0) '    this-procedure :type skip                                           ' SKIP
          SPACE(0) '    this-procedure :file-name skip                                      ' SKIP
          SPACE(0) '    valid-handle(this-procedure) skip                                   ' SKIP
          SPACE(0) '    view-as alert-box error .                                           ' SKIP
          SPACE(0) '  undo, return error return-value .                                     ' SKIP
          SPACE(0) 'end.                                                                    ' SKIP
          SPACE(0) 'else do:                                                                ' SKIP
          SPACE(0) '  assign                                                                ' SKIP
          SPACE(0) '    ' v-lib-handle-name ' = this-procedure :handle                      ' SKIP
          SPACE(0) '  .                                                                     ' SKIP
          SPACE(0) 'end.                                                                    ' SKIP
          SPACE(0) '                                                                        ' SKIP
          SPACE(0) 'if this-procedure :persistent <> true                                   ' SKIP
          SPACE(0) 'then do:                                                                ' SKIP
          SPACE(0) '  message                                                               ' SKIP
          SPACE(0) '    vss-workfile vss-revision vss-description skip                      ' SKIP
          SPACE(0) '    "Ошибка запуска библиотеки" program-name(1) skip                    ' SKIP
          SPACE(0) '    "Попытка запустить ее как обычную процедуру" skip                   ' SKIP
          SPACE(0) '    view-as alert-box error .                                           ' SKIP
          SPACE(0) 'end.                                                                    ' SKIP
          SPACE(0) '                                                                        ' SKIP
          SPACE(0) 'on delete of this-procedure do:                                         ' SKIP
          SPACE(0) '  assign                                                                ' SKIP
          SPACE(0) '    ' v-lib-handle-name ' = ?                                           ' SKIP
          SPACE(0) '  .                                                                     ' SKIP
          SPACE(0) 'end.                                                                    ' SKIP(1)
          .
      end.

      if def-out-avail then do:
        PUT STREAM ImpPckStream UNFORMATTED
          '~{ ' def-out-file-name ' }' SKIP
          .
      end.
      PUT STREAM ImpPckStream UNFORMATTED
        SPACE(0) 'define temp-table wt-' tn ' no-undo like ub.' tn '. ' SKIP
        SPACE(0) 'PROCEDURE proc-load-' tn ': ' {&start-comment} ' ' v-proc-num ' ' {&end-comment} SKIP
        SPACE(2) 'define input parameter p-imp-handle as handle  no-undo.' SKIP
        SPACE(2) 'define input parameter p-pck-num    as integer no-undo.' SKIP
        SPACE(2) 'define input parameter l-counter    as integer no-undo.' SKIP
        SPACE(2) 'do                                                  ' SKIP
        SPACE(2) 'on error  undo, return error substitute( "$proc-load-' tn '. &1&2&3", return-value, ~{&new-line~}, error-status :get-message ( error-status :num-messages ) ) ' SKIP
        SPACE(2) 'on stop   undo, return error substitute( "$proc-load-' tn '. stop" )   ' SKIP
        SPACE(2) 'on endkey undo, return error substitute( "$proc-load-' tn '. endkey" ) ' SKIP
        SPACE(2) ':                                                   ' SKIP
        SPACE(2) '  define buffer tb-' tn ' for ub.' tn '.            ' SKIP
        SPACE(2) '  define variable compare-log as logical no-undo.   ' SKIP
        .
      if def-ins-avail then do:
        PUT STREAM ImpPckStream UNFORMATTED
          SPACE(2) '  ~{ ' def-ins-file-name ' }' SKIP
          .
      end.
      PUT STREAM ImpPckStream UNFORMATTED
        SPACE(2) '  for each wt-' tn '  ' SKIP
        SPACE(2) '  on error undo, return error substitute( "$proc-load-' tn '(del-wt-). &1&2&3", return-value, ~{&new-line~}, error-status :get-message ( error-status :num-messages ) )  ' SKIP
        SPACE(2) '  :' SKIP
        SPACE(2) '    delete wt-' tn ' . ' SKIP
        SPACE(2) '  end. ' SKIP
        SPACE(2) '  create wt-' tn '.                    ' SKIP
        SPACE(2) '  run nws-impl in p-imp-handle         ' SKIP
        SPACE(2) '    ( input ~{&table_' tn '~}          ' SKIP
        SPACE(2) '     ,input (buffer wt-' tn ':handle)  ' SKIP
        SPACE(2) '    ) no-error.                        ' SKIP
        SPACE(2) '  if error-status :error then do:      ' SKIP
        SPACE(2) '    return error return-value .        ' SKIP
        SPACE(2) '  end.                                 ' SKIP
        SPACE(2) '  find first tb-' tn '                 ' SKIP
        SPACE(2) '    where '
        .
      find {&db-name_schema}._index no-lock
        where recid( {&db-name_schema}._index  ) = {&db-name_schema}._file._prime-index.
      for each {&db-name_schema}._index-field of {&db-name_schema}._index  no-lock ,
          each {&db-name_schema}._field of _index-field no-lock
          break by _index-seq:
        PUT STREAM ImpPckStream UNFORMATTED
          'tb-' tn '.' {&db-name_schema}._field._field-name ' = wt-' tn '.' {&db-name_schema}._field._field-name SKIP.
        if not last( _index-seq ) then do:
          PUT STREAM ImpPckStream UNFORMATTED  SPACE(8) 'and ' .
        end.
      end.

      PUT STREAM ImpPckStream UNFORMATTED
        SPACE(6) 'exclusive-lock no-error.' SKIP
        .
      if not inc-avail then do:
        PUT STREAM ImpPckStream UNFORMATTED
          SPACE(2) '  if l-counter <> 0 then do:                                                                                      ' SKIP
          SPACE(2) '    return error substitute( "&1 &2. Ошибка обработки записи &3", vss-workfile, vss-revision, ~{&table_' tn '~} ) ' SKIP
          SPACE(2) '                 + ~{&new-line~} + "Есть привязанные записи, а обработка идет для одной".                         ' SKIP
          SPACE(2) '  end.                                                                                                            ' SKIP
          SPACE(2) '  if not available tb-' tn ' then do:                                                                             ' SKIP
          SPACE(2) '    create tb-' tn '.                                                                                             ' SKIP
          SPACE(2) '    assign compare-log = no.                                                                                      ' SKIP
          SPACE(2) '  end.                                                                                                            ' SKIP
          SPACE(2) '  else do:                                                                                                        ' SKIP
          SPACE(2) '    buffer-compare tb-' tn ' TO wt-' tn ' case-sensitive save result in compare-log no-error.                     ' SKIP
          SPACE(2) '  end.                                                                                                            ' SKIP
          SPACE(2) '  if not compare-log then do:                                                                                     ' SKIP
          SPACE(2) '    buffer-copy wt-' tn ' TO tb-' tn '.                                                                           ' SKIP
          SPACE(2) '  end.                                                                                                            ' SKIP
          .
      end.
      else do:
        PUT STREAM ImpPckStream UNFORMATTED
          SPACE(2)  '  ~{ ' inc-file-name ' ~} ' SKIP
          .
      end.
      PUT STREAM ImpPckStream UNFORMATTED
        SPACE(2)  '  delete wt-' tn '.                                                                  ' SKIP
        SPACE(2)  'end.                                                                                 ' SKIP
        SPACE(0)  'END PROCEDURE. ' {&start-comment} ' proc-load-' tn ' ' v-proc-num ' ' {&end-comment} '' SKIP(1)
        .

      OUTPUT STREAM ImpPckStream close.

      assign
        v-ind-comp = v-ind-comp + 1
      .
    end.

    if v-ind-tbl = v-num-tbls then do:
      assign
        v-skip-proc = v-ind-comp
      .
    end.

    if v-ind-comp = v-skip-proc then do:
      assign
        v-ind-comp = 0
        v-old-sys-alert-box    = session :system-alert-boxes
        session :system-alert-boxes = false
      .
      output to value( gen-dir + "cmp-err.txt":U) .
      COMPILE value( gen-dir + file-name ) .
      assign
        v-err-num  = error-status :GET-NUMBER(1)
        v-err-size = seek(output)
      .
      output close .
      assign
        session :system-alert-boxes = v-old-sys-alert-box
      .

      if error-status :error
        or compiler :error
      then do:
        input stream errstream from value( gen-dir + "cmp-err.txt":U).
        repeat :
          import stream errstream unformatted v-tmp-str .
          if substring( v-tmp-str, length(v-tmp-str) - 5, 6)  = "(3307)" then do:
            assign
              v-err-num = 3307
            .
          end.
          assign
            v-err-cmp = v-err-cmp + {&new-line} + v-tmp-str
          .
        end.
        input stream errstream close.
        if v-err-num <> 3307 then do:
          message
            vss-workfile vss-revision vss-description skip
            substitute( "Ошибка компиляции файла &1 строка &2", COMPILER:FILENAME, COMPILER:ERROR-ROW ) skip
            v-err-cmp skip
            error-status :get-message(1) skip
            view-as alert-box error .
          return error.
        end.
        else do:
          assign
            v-err-size = 123
          .
        end.
      end.

      if compiler :warning
        or v-err-size <> 0
      then do:
        assign
          v-compile       = false
          v-proc-num      = v-proc-num - v-skip-proc
          v-ind-tbl       = v-ind-tbl - v-skip-proc - v-ind-tbl-ignor
        .
        if v-ind-tbl-curr > v-skip-proc
          or ( v-ind-tbl-curr <= v-skip-proc
               and v-skip-proc > v-skip-proc-min
             )
        then do:
          if v-skip-proc > v-skip-proc-min
            and v-skip-proc > v-skip-proc-step
          then do:
            assign
              v-ind-tbl-curr = v-ind-tbl-curr - v-skip-proc
              v-compile   = true
            .
            if v-skip-proc - v-skip-proc-step >= v-skip-proc-min then do:
              assign
                v-skip-proc = v-skip-proc - v-skip-proc-step
              .
            end.
            else do:
              assign
                v-skip-proc = v-skip-proc-min
              .
            end.
          end.
          else do:
            assign
              v-skip-proc = v-skip-proc-max
            .
          end.
          os-copy value( gen-dir + temp-file-name ) value( gen-dir + file-name ) .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            substitute( "&1 процедуры не помещаются в один генерируемый файл", v-skip-proc ) skip
            view-as alert-box error .
          leave block_compile.
        end.
      end.
      else do:
        os-copy value( gen-dir + file-name ) value( gen-dir + temp-file-name ) .
        if v-skip-proc = v-skip-proc-min then do:
          assign
            v-compile   = false
            v-skip-proc = v-skip-proc-max
          .
        end.
        else do:
          if v-skip-proc < v-skip-proc-max
            and v-skip-proc - v-skip-proc-step >= v-skip-proc-min
          then do:
            assign
              v-skip-proc = v-skip-proc - v-skip-proc-step
            .
          end.
        end.
      end.
      assign
        v-ind-tbl-ignor = 0
      .
    end.

  end.

  os-delete
    value( gen-dir + temp-file-name )
    value( gen-dir + "cmp-err.txt":U)
  .

  if v-ind-tbl < v-num-tbls then do:
    assign
      file-name        = substitute( "nws/l-rec-&1.p":U, string( counter-step + 1, "99" ) )
      file-name-no-ext = substitute( "l-rec-&1":U, string( counter-step + 1, "99" ) )
      temp-file-name   = substitute( "&1.p0":U, file-name-no-ext )
      counter-step     = counter-step + 1
    .
  end.

end.

OUTPUT STREAM ImpStream TO value( gen-dir + {&imp-pck2} ) APPEND.
PUT STREAM ImpStream UNFORMATTED
  'if v-proc-avail = FALSE then do:                                                                    ' SKIP
  '  run proc-load-standart in this-procedure                                                          ' SKIP
  '      ( input ~{1~}                                                                                 ' SKIP
  '       ,input ~{2~}                                                                                 ' SKIP
  '       ,input ?                                                                                     ' SKIP
  '       ,input this-procedure                                                                        ' SKIP
  '       ,input ~{4~}                                                                                 ' SKIP
  '       ,output ~{5~}                                                                                ' SKIP
  '      ) .                                                                                           ' SKIP
  'end.                                                                                                ' SKIP
.
OUTPUT STREAM ImpStream CLOSE.

hide frame ddd no-pause.

RETURN.