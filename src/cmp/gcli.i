&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define  
&if     "{1}" <> "class"
    and "{1}" <> "local"
&then
{1} shared 
&endif
temp-table g#cli no-undo

    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.

    .
&if     "{2}" = "" 
    and "{1}" <> "local"
&then

/* Процедура создания записи в ТТ obj-list */
&if "{1}" = "class"
&then
method public void empty-g#cli ():
   for each g#cli :
      delete g#cli.
   end.
end.
method public void get-glob-g#cli ():
end.
method public void set-glob-g#cli ():
end.
method public void get-g#cli (output table tmp#grp bind):
end.
method public void set-g#cli (input table tmp#grp bind):
end.
method public character  create_g#cli (cli-grp_recids as char):

&else
procedure create_g#cli :
   define input  parameter cli-grp_recids as character no-undo.
  
&endif

define buffer cli-prod for  ub.clients .
   for each g#cli :
       delete g#cli .
   end .

   define variable v-ind as integer   no-undo .
   do v-ind = 1 to num-entries( cli-grp_recids )
    :
        find cli-prod where recid( cli-prod ) = int( entry(v-ind, cli-grp_recids ) ) no-lock.
        create g#cli.
        assign
        g#cli.obj-type = cli-prod.obj-type
        g#cli.obj-code = cli-prod.obj-code
        g#cli.obj-name = cli-prod.obj-name.
    end.

end. /* create_obj-list */
&if "{1}" = "class"
&then
   method public character  Get_text_g#cli (output ocount as integer ):
      define variable oText as character no-undo.
&else
procedure Get_text_g#cli:
   define output parameter oText as character no-undo.
   define output parameter ocount as integer no-undo.
&endif
   ocount = 0.
   for each g#cli no-lock:
      if length(oText) <= {&max-len-str} then oText = oText + {&new-line} + "     " + g#cli.obj-name .
      ocount =  ocount + 1 .
   end.
   &if "{1}" = "class"
   &then
   return oText.
   &endif
end.
&endif