block-level on error undo, throw.
define input parameter p-sources-full-path as character no-undo .
define output parameter p-correct as logical no-undo .
define output parameter p-message as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fixvalid.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/fixvalid.p $":U .
define variable vss-description as character no-undo init "".
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
define stream instream.
define variable v-txt-file-list as character no-undo init "~
cmp/fixattrp.txt~
,cmp/fixdr.txt~
,cmp/fixrum.txt~
,cmp/fixcstml.txt~
,cmp/fix-gate.txt~
,cmp/fix-lay.txt~
".
define variable v-ver-file-list as character no-undo init "~
gbl/attrprps.i~
,gbl/disrules.i~
,gbl/rumconf.i~
,gbl/cstmlabs.i~
,gbl/gateconf.i~
,gbl/layconf.i~
".
define variable v-ver-var-list as character no-undo init "~
ap-revision~
,rule-revision~
,rum-revision~
,cl-revision~
,gate-revision~
,layout-revision~
".
define variable v-ver-record-num-list as character no-undo init "~
first~
,first~
,last~
,first~
,last~
,last~
".
define variable v-ver-record-field-list as character no-undo init "~
property-value~
,des~
,documentation~
,custom-tooltip~
,descr~
,layout-name~
".
define variable v-description-list as character no-undo init "~
ÊÎÍÔÈÃÓĞÀÖÈß ÀÒĞÈÁÓÒÎÂ~
,ÊÎÍÔÈÃÓĞÀÖÈß ÏĞÀÂÈË ÑÊÈÄÎÊ È ĞÀÑÏÈÑÀÍÈÉ~
,ÊÎÍÔÈÃÓĞÀÖÈß ÌÀØÈÍÛ ÏĞÀÂÈË (RUM)~
,ÊÎÍÔÈÃÓĞÀÖÈß ÍÀÑÒĞÀÈÂÀÅÌÛÕ ÏÎËÅÉ~
,ÊÎÍÔÈÃÓĞÀÖÈß ÃÅÉÒÎÂ~
,ÊÎÍÔÈÃÓĞÀÖÈß ĞÀÑÊËÀÄÎÊ~
".
define variable ss as character no-undo .
define variable ss1 as character no-undo .
define variable rev-string as character no-undo .
define variable v-ii as integer no-undo .
define variable v-num-rec as integer no-undo .
define variable v-index as integer no-undo .
define variable v-txt-revis as character no-undo .
define variable v-gbl-revis as character no-undo .
define variable v-path-txt as character no-undo .
define variable v-path-gbl as character no-undo .
do v-ii = 1 to num-entries(v-txt-file-list):
  rev-string = ''.
  v-num-rec = 0.
  v-path-txt = p-sources-full-path  + entry(v-ii, v-txt-file-list).
  if search(v-path-txt) = ? then do:
    return error substitute("Â èñõîäíèêàõ íå íàéäåí ôàéë &1", entry(v-ii, v-txt-file-list)).
  end.
  v-path-gbl = p-sources-full-path + entry(v-ii, v-ver-file-list).
  if search(v-path-gbl) = ? then do:
    return error substitute("Â èñõîäíèêàõ íå íàéäåí ôàéë &1", entry(v-ii, v-ver-file-list)).
  end.
  input stream instream from value(search(v-path-txt)).
  _repeat1:
  repeat:
    import stream instream unformatted ss.
    v-num-rec = v-num-rec + 1.
    if ss <> '"**END OF PACKET**"' then do:
      ss1 = ss.
    end.
    if entry(v-ii, v-ver-record-num-list) = "first" then do:
      if v-num-rec = 2 then leave _repeat1.
    end.
  end.
  input stream instream close.
  case entry(v-ii, v-ver-record-num-list):
    when "first" then do:
      rev-string = ss.
    end.
    when "last" then do:
      rev-string = ss1.
    end.
  end case.
  v-index = index(rev-string, substitute("&2<&3>&2&1"
                                        ,chr(32)
                                         ,chr(34)
                                         ,entry(v-ii, v-ver-record-field-list))).
  rev-string = substring(rev-string, v-index).
  rev-string = substring(rev-string,
                                    length(substitute("&2<&3>&2&1"
                                        ,chr(32)
                                         ,chr(34)
                                         ,entry(v-ii, v-ver-record-field-list))) + 1).
  v-txt-revis = entry(2, rev-string, chr(34)).
  input stream instream from value(search(v-path-gbl)).
  _repeat2:
  repeat:
    import stream instream unformatted ss.
    if index(ss, substitute("&1&2", chr(32), entry(v-ii, v-ver-var-list))) > 0 then do:
      v-gbl-revis = trim(trim(trim(entry( num-entries(ss, chr(32)), ss, chr(32)), chr(39)), chr(34)), chr(39)).
      leave _repeat2.
    end.
  end.
  input stream instream close.
  if v-txt-revis <> v-gbl-revis then do:
    p-message = p-message + chr(10) +
                substitute("Íå ñîâïàäàşò âåğñèè äëÿ &1 â ôàéëå &2 è ôàéëå &3&4ÑÂÅĞÜÒÅ ÂÅĞÑÈÈ Ñ VSS!!!!!"
                           ,entry(v-ii, v-description-list)
                           ,entry(v-ii, v-txt-file-list)
                           ,entry(v-ii, v-ver-file-list)
                           ,chr(10)).
  end.
end.
if trim(p-message, chr(10)) = '':U then do:
  p-correct = yes.
end.
