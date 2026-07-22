

&if "{3}" eq ""
&then
{1} = new {2} ().
&elseif "{4}" eq ""
&then
{1} = new {2} ({3}).
&elseif "{5}" eq ""
&then
{1} = new {2} ({3},{4}).
&elseif "{6}" eq "" &then 
{1} = new {2} ({3},{4},{5}).
&elseif "{7}" eq "" &then
{1} = new {2} ({3},{4},{5},{6}).
&elseif "{8}" eq "" &then
{1} = new {2} ({3},{4},{5},{6},{7}).
&elseif "{9}" eq "" &then
{1} = new {2} ({3},{4},{5},{6},{7},{8}).
&elseif "{10}" eq "" &then
{1} = new {2} ({3},{4},{5},{6},{7},{8},{9}).
&else 
{1} = new {2} ({3},{4},{5},{6},{7},{8},{9},{10}).
&endif
&if defined(GlobObjSrvClass) eq 0
&then
ObjSrv:Regobj(this-object,{1},
&if defined (propNameReg) ne 0
&then
 {&propNameReg}
&else
"{1}"
&endif
) .
&else
    Regobj({1},&if defined (propNameReg) ne 0
&then
 {&propNameReg}
&else
"{1}"
&endif).
&endif