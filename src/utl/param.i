   {utl\search.i {1}}
   &GLOBAL-DEFINE PARAM-BEG-TAG SUBSTITUTE("<PARAM name='&1'>", iName)
   &GLOBAL-DEFINE PARAM-END-TAG SUBSTITUTE("</PARAM name='&1'>", iName)
   
   &if "{1}" = "class" &then
   method public  void SavePARAM      ( input iName as character, input iValue as character ):
   &else
   function SavePARAM returns logical ( input iName as character, input iValue as character ):
   &endif
      put unformatted {&PARAM-BEG-TAG}.
      put unformatted iValue.
      put unformatted {&PARAM-END-TAG} skip.
   end .

   &if "{1}" = "class" &then
   method public character GetPARAM          ( input iFile as character, input iName as character ):
   &else
   function GetPARAM returns character  ( input iFile as character, input iName as character ):
   &endif
      define variable vLob  as longchar no-undo.
      define variable vFrom as int64    no-undo.
      define variable vTo   as int64    no-undo.
      iFile = SearchFile (iFile).
      if iFile eq ? then return ?.
      copy-lob file iFile to vLob no-error.
      vFrom = index(vLob, {&PARAM-BEG-TAG}).
      if vFrom <= 0 then return ?.
      assign
         vTo = index(vLob, {&PARAM-END-TAG})
         vFrom = vFrom + LENGTH({&PARAM-BEG-TAG}). 
      if vTo < vFrom then return ?.
      return string(substring(vLob, vFrom, vTo - vFrom)).
   end.
