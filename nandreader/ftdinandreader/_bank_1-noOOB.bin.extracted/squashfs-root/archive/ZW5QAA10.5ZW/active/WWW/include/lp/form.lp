<%
-- filename:       form.lp
-- description:    supply useful api for generate HTML element by lua 
-- project:        BT2.0 GUI

-- name:           createSelect 
-- description:    create select HTML element  
-- parameter:      start: the string of <select ...> , you can define the className, id, onclick, onchange.... 
--                 last: the last option, sometimes user will define the last option,  if nil, don't print
--                 optTable: the table include the option text and value 
--                 opt: the element in table present option text
--                 value: the element in table present option value 
-- return value    null, directly print in HTML codes. 
-- author:         Zhu Hong Lei (hong-lei.zhu@thomson.net)

function createSelect(start,last,optTable,opt,value)
  print(start)
  if #optTable > 0 then
    for i=1,#optTable do
      print('<option value="', optTable[i][value], '">', optTable[i][opt], '</option>')
    end
  end
  if last~=nil then
  print(last)
  end
  print("</select>")
end
%>
