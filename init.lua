local ModProxy = class("ModProxy")

function ModProxy:__init()
    print("ModProxy:__init()")
end

function ModProxy:init()
    require("tc.languages.LocaleHelper").reload(require("Locale"))
    print("ModProxy:init()")
    local api = require("tc.api")
    api.ModifyUI("ModListUI", require("ModListModify"))
end

function ModProxy:start()

end

function ModProxy:preUpdate()

end

function ModProxy:update()

end

function ModProxy:postUpdate()

end

function ModProxy:render()

end

function ModProxy:exit()

end

return ModProxy