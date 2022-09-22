local ModListModify = class("ModListModify")
local Locale = require("Locale")

function ModListModify:__init(uiWindow)
    self.uiWindow = uiWindow
    ---@type UINode
    self.root = self.uiWindow.root
    self.manager = self.uiWindow.manager
end

function ModListModify:initContent()
    self.root:getChild("layer.btn_mod_sources"):addTouchUpListener({
        self._onSourceBtnClicked, self }
    )
end

function ModListModify:_onSourceBtnClicked()
    if not App.isPC then
        require("tc.ui.InfoPopupUI").new(Locale.MOD_SOURCES_UNSUPPORTED)
        return
    end
    self.uiWindow:closeWindow()
    self.manager:playClickSound()
    require("SourcesManageUI").new()
end

return ModListModify