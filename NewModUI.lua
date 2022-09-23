---@class ModEdit.NewModUI:TC.UIWindow
local NewModUI = class("NewModUI", require("tc.ui.UIWindow"))
---@type TC.Util
local UIUtil = require("tc.ui.UIUtil")
local Locale = require("Locale")
local TCLocale = require("tc.languages.Locale")
local UIDefault = require("tc.ui.UIDefault")

function NewModUI.createRoot()
    local UI_SIZE = Size.new(600, 400)
    local root = UIUtil.createBlackFullScreenLayer("sources_manage_ui")
    local panel = UIUtil.createWindowPattern(root, UI_SIZE, nil)
    panel:addChild(UIUtil.createLabelNoPos("lb_title", Locale.CREATE_MOD_TITLE,
            TextAlignment.HCenter, TextAlignment.VCenter, {
                positionY = 12,
                marginsLR = { 0, 0 },
                fontSize = UIDefault.FontSize + 8
            }))

    local inputs = {
        { "id", Locale.MOD_ID, "my_first_mod" },
        { "display_name", Locale.MOD_DISPLAY_NAME, "My First Mod" },
        { "folder", Locale.MOD_FOLDER, "MyFirstMod" },
        { "author", Locale.MOD_AUTHOR, "" },
    }
    local inputY = 60

    for _, input in ipairs(inputs) do
        panel:addChild(UIUtil.createLabel("lb_" .. input[1], input[2],
            0, inputY, 180, 48,
            TextAlignment.HCenter, TextAlignment.VCenter, {}))
        local panelInput = UIUtil.createPanel("input_panel_" .. input[1], 0, inputY, 200, 48, {
            marginsLR = { 180, 16 },
            sprite = {
                name = "tc:round_rect_white",
                color = Color.new(60, 60, 85)
            }
        })
        panel:addChild(panelInput)
        panelInput:addChild(UIUtil.createPanelNoPos("bg", {
            margins = { 2, 2, 2, 2 },
            sprite = {
                name = "tc:round_rect_white",
                color = Color.new(30, 30, 45)
            }
        }))
        local editBox = UIInputField.new("edit")
        UIUtil.setMargins(editBox, 8, 8, 8, 8)
        panelInput:addChild(editBox)

        if input[3] then
            editBox.text = input[3]
        end

        inputY = inputY + 64
    end

    panel:addChild(UIUtil.createButton("btn_back", TCLocale.BACK, 0, 200, 280, UIDefault.ButtonHeight, {
        anchorPoint = { 0.5, 0 },
        margins = { 16, nil, nil, 16, false, false },
        targetSprite = { color = Color.new(110, 108, 132, 255) },
    }))
    panel:addChild(UIUtil.createButton("btn_create", Locale.CREATE_MOD_TITLE, 0, 200, 280, UIDefault.ButtonHeight, {
        anchorPoint = { 0.5, 0 },
        margins = { nil, nil, 16, 16, false, false },
        targetSprite = { color = Color.new(110, 108, 132, 255) },
    }))
    return root
end

function NewModUI:__init()
    NewModUI.super.__init(self, NewModUI.createRoot())

    self:initContent()
end

function NewModUI:initContent()
    self.root:getChild("layer.btn_back"):addTouchUpListener({
        function(self)
            local SourcesManageUI = require("SourcesManageUI")
            self.manager:playClickSound()
            self:closeWindow()
            SourcesManageUI.new()
        end, self }
    )
    self.root:getChild("layer.btn_create"):addTouchUpListener({ self._onOkClicked, self })
end

function NewModUI:_onOkClicked()
    self.manager:playClickSound()
    self:peekData()
end

function NewModUI:peekData()
    local id = UIInputField.cast(self.root:getChild("layer.input_panel_id.edit")).text
    local display_name = UIInputField.cast(self.root:getChild("layer.input_panel_display_name.edit")).text
    local folder = UIInputField.cast(self.root:getChild("layer.input_panel_folder.edit")).text
    local author = UIInputField.cast(self.root:getChild("layer.input_panel_author.edit")).text

    self:testString(id)
    self:testString(display_name)
    self:testString(folder)
    self:testString(author)

    local baseDevPath = Path.join(App.persistentDataPath, "devmods")
    local basePath = Path.join(baseDevPath, folder)

    File.makeFolder(basePath)

    local package = {
        id = id,
        displayName = display_name,
        version = "1.0.0",
        gameVersion = "Obsidian Edition 1.0",
        authors = { author }
    }
    File.saveString(Path.join(basePath, "package.json"), JsonUtil.toJson(package))

    local initLua = [[
local ModProxy = class("ModProxy")

function ModProxy:__init()
    self.m_proxy = nil
    if NetMode.current == NetMode.Server then
        self.m_proxy = require("Server").new()
    else
        self.m_proxy = require("Client").new()
    end
    self.m_proxy:registerProxy()
end

function ModProxy:init()
    self.m_proxy:init()
end

function ModProxy:start()
    self.m_proxy:start()
end

function ModProxy:preUpdate()
    self.m_proxy:preUpdate()
end

function ModProxy:update()
    self.m_proxy:update()
end

function ModProxy:postUpdate()
    self.m_proxy:postUpdate()
end

function ModProxy:render()
    if NetMode.current == NetMode.Client then
        self.m_proxy:render()
    end
end

function ModProxy:exit()
    self.m_proxy:exit()
end

return ModProxy]]
    File.saveString(Path.join(basePath, "init.lua"), initLua)

    local serverLua = [[
local ServerProxy = class("ServerProxy", require("CommonProxy"))

function ServerProxy:__init()
    ServerProxy.super.__init(self)
    -- TODO
end

function ServerProxy:registerProxy()
    ServerProxy.super.registerProxy(self)
    -- TODO
end

function ServerProxy:init()
    ServerProxy.super.init(self)
    -- TODO
end

function ServerProxy:start()
    ServerProxy.super.start(self)
    -- TODO
end

function ServerProxy:preUpdate()
    ServerProxy.super.preUpdate(self)
    -- TODO
end

function ServerProxy:update()
    ServerProxy.super.update(self)
    -- TODO
end

function ServerProxy:postUpdate()
    ServerProxy.super.postUpdate(self)
    -- TODO
end

function ServerProxy:exit()
    ServerProxy.super.exit(self)
    -- TODO
end

return ServerProxy]]
    File.saveString(Path.join(basePath, "Server.lua"), serverLua)

    local clientLua = [[
local ClientProxy = class("ClientProxy", require("CommonProxy"))

function ClientProxy:__init()
    ClientProxy.super.__init(self)
    -- TODO
end

function ClientProxy:registerProxy()
    ClientProxy.super.registerProxy(self)
    -- TODO
end

function ClientProxy:init()
    ClientProxy.super.init(self)
    -- TODO
end

function ClientProxy:start()
    ClientProxy.super.start(self)
    -- TODO
end

function ClientProxy:preUpdate()
    ClientProxy.super.preUpdate(self)
    -- TODO
end

function ClientProxy:update()
    ClientProxy.super.update(self)
    -- TODO
end

function ClientProxy:postUpdate()
    ClientProxy.super.postUpdate(self)
    -- TODO
end

function ClientProxy:render()
    -- TODO
end

function ClientProxy:exit()
    ClientProxy.super.exit(self)
    -- TODO
end

return ClientProxy]]
    File.saveString(Path.join(basePath, "Client.lua"), clientLua)

    local commonProxyLua = [[
local CommonProxy = class("CommonProxy")
function CommonProxy:__init()
    -- TODO
end

function CommonProxy:registerProxy()
    -- TODO
end

function CommonProxy:init()
    -- TODO
end

function CommonProxy:start()
    -- TODO
end

function CommonProxy:preUpdate()
    -- TODO
end

function CommonProxy:update()
    -- TODO
end

function CommonProxy:postUpdate()
    -- TODO
end

function CommonProxy:exit()
    -- TODO
end

return CommonProxy]]
    File.saveString(Path.join(basePath, "CommonProxy.lua"), commonProxyLua)

    self:closeWindow()
    local SourcesManageUI = require("SourcesManageUI")
    SourcesManageUI.new()
end

function NewModUI:testString(value)
    print(value)
    if value:match("%W_") then
        print(value)
        return true
    end
    return false
end

function NewModUI:closeWindow()
    NewModUI.super.closeWindow(self)
end

return NewModUI