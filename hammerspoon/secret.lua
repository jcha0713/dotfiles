local M = {}

M.init = function(f)
  if hs.fs.attributes(f) then
    hs.settings.set("secret", hs.json.read(f))
  else
    print("You need to create a file at " .. f)
  end
end

return M
