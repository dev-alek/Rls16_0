/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение процедур и функций для заполнения истории механизмов списков

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/27/05
Author: Bakhtadze Natalya
Creation date: 09/27/05

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/key-rec.i }

/*создание и редактирование записи истории создания списка*/
procedure create-{1}-hist :
define input parameter p-mode as character no-undo .
define input-output parameter p-seq as integer no-undo .
define input parameter p-line as integer no-undo .
&if "{2}" = "multitable" &then
define input parameter p-list-table as character no-undo .
&else
define variable p-list-table as character no-undo .
&endif
define input parameter p-hist-mode as character no-undo .
define input parameter p-des as character no-undo .

define input parameter p-num-recs as integer no-undo .
define input parameter p-option as character no-undo .
define input parameter p-status_ as character no-undo .
define input parameter p-item as character no-undo .
define input parameter p-tbl-name as character no-undo .
define input parameter p-bh_tbl-name as handle no-undo .

define variable v-num-add as integer no-undo .
define variable v-num-ignored as integer no-undo .
define buffer buf_{1}-hist for {1}-hist.

  do
  on error undo, return error
  :
    CASE p-mode:
      when 'title' then do:
        find first buf_{1}-hist where
                   buf_{1}-hist.id = 0   no-error.
        if not available buf_{1}-hist then do:
          create buf_{1}-hist.
          assign
          buf_{1}-hist.id = 0
          buf_{1}-hist.line = 0
          buf_{1}-hist.list-table = '':U
          .
        end.
        assign
        buf_{1}-hist.des =  p-des
        buf_{1}-hist.num-recs = p-num-recs
        buf_{1}-hist.option_  = p-option
        buf_{1}-hist.item_ = p-item
        .
      end.
      when {&add-def} then do:
        if p-option begins 'single' then do:
          CASE p-hist-mode:
            when '+':U then do:
              assign
              v-num-add = 1
              v-num-ignored  = 0
              .
            end.
            when '-':U then do:
              assign
              v-num-add = 1
              v-num-ignored  = 0
              .
            end.
            when '*':U then do:
              assign
              v-num-add = p-num-recs - 1
              p-num-recs = 1
              v-num-ignored  = 0
              .
            end.
          END CASE.
        end.
        create buf_{1}-hist.
        assign
        buf_{1}-hist.id = p-seq
        buf_{1}-hist.list-table = p-list-table
         p-seq = (if p-line = 0 then (p-seq + 1) else p-seq)
        buf_{1}-hist.des =  p-des
        buf_{1}-hist.line = p-line
        buf_{1}-hist.num-recs = p-num-recs
        buf_{1}-hist.option_  = p-option
        buf_{1}-hist.item_ = p-item
        buf_{1}-hist.hist-mode =  p-hist-mode
        buf_{1}-hist.status_ =  p-status_
        buf_{1}-hist.num-add = v-num-add
        buf_{1}-hist.num-ignored = v-num-ignored
        .
      end.
      when {&update} + {&delim-par} + 'des' then do:
        find first buf_{1}-hist where
                  buf_{1}-hist.id = p-seq
              and buf_{1}-hist.line = p-line no-error .
        if  available buf_{1}-hist then do:
          assign
          buf_{1}-hist.des =  p-des
          buf_{1}-hist.num-recs = p-num-recs
          buf_{1}-hist.option_  = p-option
          buf_{1}-hist.item_ = p-item
          buf_{1}-hist.list-table = (if p-list-table <> '':U and p-list-table <> ?
                                     then p-list-table
                                     else buf_{1}-hist.list-table)
          .
        end.
      end.
      when {&update} + {&delim-par} + 'mode' then do:
        find first buf_{1}-hist where
                  buf_{1}-hist.id = p-seq
              and buf_{1}-hist.line = p-line  no-error .
        if available buf_{1}-hist then do:
          assign
          buf_{1}-hist.hist-mode =  p-hist-mode
          buf_{1}-hist.num-recs  = (if buf_{1}-hist.line = 0 then p-num-recs else buf_{1}-hist.num-recs)
          buf_{1}-hist.list-table = (if p-list-table <> '':U and p-list-table <> ?
                                     then p-list-table
                                     else buf_{1}-hist.list-table)
          .
        end.
      end.
    END CASE.
    if p-tbl-name <> "":U
    and valid-handle(p-bh_tbl-name)
    then do:
      run gen-key-rec  in this-procedure (
                                            input  p-tbl-name
                                           ,input  p-bh_tbl-name
                                           ,output p-item) no-error .
      if not error-status:error then do:
        assign
        buf_{1}-hist.item_ = p-item
        .
      end.
      else do:
        assign
        buf_{1}-hist.item_ = "!ERROR"
        .
      end.
    end.
  end.

end procedure. /* create-{1}-hist */

FUNCTION get-line-mode returns character(input p-hist-mode as character):
case p-hist-mode:
  when '+':U then
    return  {&add-def}.
  when '-':U then
    return  {&deletion}.
  when '*':U then
    return  {&leave}.
end CASE.
END FUNCTION.


FUNCTION get-hist-mode returns character(input p-line-mode as character):
case p-line-mode:
  when {&add-def} then
    return  "+".
  when {&deletion} then
    return  "-".
  when {&leave} then
    return  "*".
end CASE.
END FUNCTION.

procedure proc-write-filter-expression :
define input parameter p-filter-expression as character no-undo .

define variable v-ii as integer no-undo .
output to value(string(g#report-num) + ".whr").
put .
if num-entries(p-filter-expression) > 0 then do:
   put unformatted 'and ('.
   do v-ii = 1 to num-entries(p-filter-expression):
     put unformatted entry(v-ii, p-filter-expression) skip.
   end.
   put unformatted ')'.
end.
output close.
end procedure.

procedure proc-write-filter-expression-var :
define input parameter p-filter-expression as character no-undo .
define output parameter p-string as character no-undo .

define variable v-ii as integer no-undo .
if num-entries(p-filter-expression) > 0 then do:
   p-string = 'and ('.
   do v-ii = 1 to num-entries(p-filter-expression):
     p-string = p-string + entry(v-ii, p-filter-expression) + {&new-line}.
   end.
   p-string = p-string + ')'.
end.

end procedure.


/* proc-write-filter-expression */



/* $Workfile$ e n d */