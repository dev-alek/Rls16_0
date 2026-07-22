/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание чека при импорте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/31/05
Author: Bakhtadze Natalya
Creation date: 10/31/05

*/

    when "{1}" then do:
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

        &if "{1}" = "chk-doc" &then
          assign
          v-import = no
          ii = ii + 1
          .
          if v-inkas-code = "":U then do:
            assign
            v-import = yes
            ii-ok = ii-ok + 1
            .
          end.
          else do:
            if v-inkas-code = ? then do:
              assign
              v-import = no
              .
            end.
            else do:
              find first buf_inkas where
                        buf_inkas.inkas-code = v-inkas-code no-error .
              if available buf_inkas
              and (buf_inkas.status_ = {&fact}
                  or
              buf_inkas.status_ = {&inquiry}  )
              then do:
                find first buf_chk-doc no-lock where
                          buf_chk-doc.doc-code = v-doc-code no-error.
                if not available buf_chk-doc then do:
                  assign
                  v-import = yes
                  ii-ok = ii-ok + 1
                  .
                end.
              end.
            end. /*v-inkas-code есть*/
          end. /*v-inkas-code <> "":U*/
        &endif
        if v-import = yes then do:
          create {1}.
          import stream imp-str {1} no-error .
          if error-status:error then do:
             undo _repeat, next _repeat.
          end.
        end.
        else do:
          import stream imp-str unformatted v-skip.
        end.
    end.


/* $Workfile$ e n d */