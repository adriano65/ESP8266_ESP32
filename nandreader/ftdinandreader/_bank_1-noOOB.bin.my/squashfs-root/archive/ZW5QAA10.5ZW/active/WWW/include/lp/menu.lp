<%

function printLeftBlock(url, image, description)
  cgilua.print("<tr><td style='background-color:#e9eef2'><table border='0' cellspacing='0' cellpadding='0'><tr><td class='icon iconpadcell' align='left' valign='top' width='60'><a href=" .. url .. "><img border='0' src='/images/" .. image .. "' alt='" .. description .. "'></a></td><td class='blocktitle' valign='top'><a class='titlelink' href=" .. url .. " >" .. description .. "</a><br></td></tr></table></td>")
end

function printRightBlock(url, image, description)
  cgilua.print("<td class='width50'>&nbsp;</td><td  style='background-color:#e9eef2'><table border='0' cellspacing='0' cellpadding='0'><tr><td class='icon iconpadcell' align='left' valign='top' width='60'><a href=" .. url .. "><img border='0' src='/images/" .. image .. "' alt='" .. description .. "'></a><br></td><td class='blocktitle' valign='top'><a class='titlelink' href=" .. url .. ">" .. description .. "</a></td></tr></table></td></tr><tr><td colspan='3'>&nbsp;</td></tr>")
end

%>
