
/*------------------------------------------------------------------------
    File        : calibrationbelt.i
    Purpose     : Библиотека по работе с поясной вместиостью

    Syntax      :

    Description : 

    Author(s)   : Ростовцев А.М.
    Created     : Feb 15 2024
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

&if "{1}" = "class"
&then
method public character getCalibrationBelt
&else
function getCalibrationBelt returns character 
&endif 
  (
  input iObjType as character, 
  input iObjCode as integer, 
  input iPlCode  as integer,
  input iLevelNP as decimal,
  input iLevelWater as decimal 
  ) 
:
  define variable vCalibBelt      as  character         no-undo.
  define buffer   buf_pl-level-mm for ub.pl-level-mm.

  for each buf_pl-level-mm where
           buf_pl-level-mm.obj-type = iObjType
       and buf_pl-level-mm.obj-code = iObjCode
       and buf_pl-level-mm.pl-code  = iPlCode
       and ((buf_pl-level-mm.min-level <= iLevelNP and buf_pl-level-mm.max-level >= iLevelNP) or
            (buf_pl-level-mm.min-level <= iLevelWater and buf_pl-level-mm.max-level >= iLevelWater))
      no-lock
      break by buf_pl-level-mm.zone by buf_pl-level-mm.level:
    if first-of(buf_pl-level-mm.zone) then do:
      vCalibBelt = substitute("&1&2;&3=",vCalibBelt, buf_pl-level-mm.min-level,buf_pl-level-mm.max-level).  
    end.      
    vCalibBelt = substitute("&1&2&3",vCalibBelt, if buf_pl-level-mm.level = 1 then "" else ";", trim(string(buf_pl-level-mm.capacity / 1000, ">>>>>9.999"))).
    if last-of(buf_pl-level-mm.zone) and not last(buf_pl-level-mm.zone) then
      vCalibBelt = substitute("&1&2",vCalibBelt, {&new-line}).
    
  end.
  return vCalibBelt.
end.