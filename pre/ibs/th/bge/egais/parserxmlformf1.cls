using Progress.Lang.*.
using ibs.th.bge.egais.*.
using ibs.th.gbl.*.
block-level on error undo, throw.
class ibs.th.bge.egais.ParserXMLFormF1 inherits EGAISUTM:
  define         variable v-FS-RAR     as character no-undo .
  define private variable listManagObj as class     listmanager.
  define variable extFormF1ValueObj as class   ExtFormF1Value no-undo.
  define temp-table tt-gds-EG no-undo
    field formF1code as character label "Код справки 1"
    field extFormF1ValueObj as class Progress.Lang.Object
    index pi as primary
    formF1code
    .
  define variable hDoc        as handle    no-undo.
  define variable hRoot       as handle    no-undo.
  define variable good        as logical   no-undo.
  define variable v-save-info as character no-undo .
  define variable v-OrgCli    as logical .
  constructor public ParserXMLFormF1 (inOjType as char, inObjCode as int):
    super (inOjType, inObjCode).
    listManagObj = new listmanager ().
  end constructor.
  method override handle ParseResponse(inFileName as char):
    for each tt-gds-EG:
      if valid-object (tt-gds-EG.extFormF1ValueObj)
        then delete object tt-gds-EG.extFormF1ValueObj.
    end.
    empty temp-table tt-gds-EG .
    create x-document hDoc.
    create x-noderef hRoot.
    hDoc:load("file",inFileName,false).
    hDoc:get-document-element(hRoot).
    GetChildren(hRoot, 1).
    delete object hDoc.
    delete object hRoot.
    return buffer tt-gds-EG:handle.
  end.
  method private void GetChildren(hParent as handle, level as integer):
    define variable i                 as integer no-undo.
    define variable hNoderef          as handle  no-undo.
    define variable hText             as handle  no-undo.
    create x-noderef hNoderef.
    create x-noderef hText .
    repeat i = 1 to hParent:num-children:
      good = hParent:get-child(hNoderef,i).
      if not good then
        leave.
      if hNoderef:subtype <> "element" then
        next.
      hNoderef:get-child(hText, 1) no-error .
      if hNoderef:name = "ns:FSRAR_ID" then
        assign v-FS-RAR = hText:node-value .
      if hNoderef:name = "rfa:InformF1RegId" then
      do:
        create tt-gds-EG .
        extFormF1ValueObj = new ExtFormF1Value().
        tt-gds-EG.extFormF1ValueObj = cast (extFormF1ValueObj, Progress.Lang.Object).
        extFormF1ValueObj:FormF1Code = htext:node-value.
        tt-gds-EG.formF1code = htext:node-value.
      end.
      if hNoderef:name = "rfa:Product" then
      do:
        v-OrgCli = false.
      end.
      if hNoderef:name = "rfa:OriginalClient" then
      do:
        v-OrgCli = true.
      end.
      if v-OrgCli then
      do:
        if hNoderef:name = "oref:UL"
          or hNoderef:name = "oref:FL"
          or hNoderef:name = "oref:FO"
          or hNoderef:name = "oref:TS"
          then
        do :
         extFormF1ValueObj:CliEgaisTypeOrigCli = entry(2, hNoderef:name, ":") .
        end.
        if hnoderef:name = "oref:ClientRegId" then extFormF1ValueObj:CliRegIdOrigCli = htext:node-value.
        if hnoderef:name = "oref:INN" then extFormF1ValueObj:INNOrigCli = htext:node-value.
        if hnoderef:name = "oref:KPP" then extFormF1ValueObj:KPPOrigCli = htext:node-value.
        if hnoderef:name = "oref:FullName" then extFormF1ValueObj:FullNameOrigCli = htext:node-value.
        if hnoderef:name = "oref:Country" then extFormF1ValueObj:CountryOrigCli = htext:node-value.
        if hnoderef:name = "oref:RegionCode" then extFormF1ValueObj:RegionOrigCli = htext:node-value.
        if hnoderef:name = "oref:description" then extFormF1ValueObj:DescrOrigCli = htext:node-value.
      end.
      if hnoderef:name = "rfa:BottlingDate" then extFormF1ValueObj:BottlingDate = htext:node-value.
      GetChildren(hNoderef, (level + 1)).
    end.
    delete object hNoderef.
    delete object hText.
  end.
  destructor public ParserXMLFormF1 ( ):
    if valid-object (listManagObj)
      then delete object listManagObj.
    for each tt-gds-EG:
      if valid-object (tt-gds-EG.extFormF1ValueObj)
        then delete object tt-gds-EG.extFormF1ValueObj.
    end.
  end destructor.
end class.
