&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{cmp\r-page-pre.i}
{ref/grplibfn.i {1}}
define  
&if     "{1}" <> "class"
    and "{1}" <> "local"
&then
{1} shared 
&endif
temp-table tmp#grp no-undo

    field node-code like ub.gds-grp.node-code
    field grp-name like ub.gds-grp.node-name
    field lvl-num  like ub.gds-grp.lvl-num
    field is-term  like ub.gds-grp.is-term
    index pi is unique primary grp-name node-code
    index i-node-code    node-code
    index level-num   lvl-num  grp-name
    index is-term is-term  grp-name
    .
&if     "{2}" = "" 
    and "{1}" <> "local"
&then

/* Процедура создания записи в ТТ obj-list */
&if "{1}" = "class"
&then
method public void empty-tmp#grp ():
   for each tmp#grp :
      delete tmp#grp.
   end.
end.
method public void get-glob-tmp#grp ():
end.
method public void set-glob-tmp#grp ():
end.
method public void get-tmp#grp (output table tmp#grp bind):
end.
method public void set-tmp#grp (input table tmp#grp bind):
end.
method public character  create_tmp#grp (gdsgrp_recids as char):
   define variable t-str as character no-undo.
&else
procedure create_tmp#grp :
   define input  parameter gdsgrp_recids as character no-undo.
   define output parameter t-str as character no-undo.
&endif
define variable Grp_Name as character no-undo.
define buffer buf_gds-grp for gds-grp.
   for each  tmp#grp :
     delete tmp#grp.
   end.

   define variable v-ind as integer   no-undo .
   repeat v-ind = 1 to num-entries( gdsgrp_recids ):

      find first buf_gds-grp where recid ( buf_gds-grp ) = integer ( entry(v-ind,gdsgrp_recids )) no-lock.
      &if "{1}" = "class"
      &then
          Grp_Name = grplib-get-full-name (  buf_gds-grp.node-code  ).
      &else
      run grplib-get-full-name in this-procedure( input buf_gds-grp.node-code, output Grp_Name ).
      &endif
      if Grp_Name <> ? then  if length(t-str) <= {&max-len-str} then t-str = t-str + {&new-line} + "     " + Grp_Name .
      create tmp#grp.
      assign tmp#grp.node-code = buf_gds-grp.node-code
             tmp#grp.grp-name = Grp_Name
             tmp#grp.is-term = buf_gds-grp.is-term
             tmp#grp.lvl-num = buf_gds-grp.lvl-num
      .
   end.
   return t-str.
end. /* create_obj-list */
&endif
    