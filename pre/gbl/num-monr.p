block-level on error undo, throw.
def     input   parameter   MonthNumber     as  integer.
def     output parameter   MonthName        as  char.
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: num-monr.p $":U .
def var vss-archive     as character no-undo init "$Archive: gbl/num-monr.p $":U .
def var vss-description as character no-undo init "Âîçâğàùàåò èìÿ ìåñÿöà".
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
case MonthNumber :
  when 1 then MonthName = "ßÍÂÀĞß".
  when 2 then MonthName = "ÔÅÂĞÀËß".
  when 3 then MonthName = "ÌÀĞÒÀ".
  when 4 then MonthName = "ÀÏĞÅËß".
  when 5 then MonthName = "ÌÀß".
  when 6 then MonthName = "ÈŞÍß".
  when 7 then MonthName = "ÈŞËß".
  when 8 then MonthName = "ÀÂÃÓÑÒÀ".
  when 9 then MonthName = "ÑÅÍÒßÁĞß".
  when 10 then MonthName = "ÎÊÒßÁĞß".
  when 11 then MonthName = "ÍÎßÁĞß".
  when 12 then MonthName = "ÄÅÊÀÁĞß".
end.
