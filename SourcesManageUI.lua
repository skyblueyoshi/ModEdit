---@class ModEdit.SourcesManagerUI:TC.UIWindow
local SourcesManagerUI = class("SourcesManagerUI", require("tc.ui.UIWindow"))
---@type TC.Util
local UIUtil = require("tc.ui.UIUtil")
local Locale = require("Locale")
local TCLocale = require("tc.languages.Locale")
local UIDefault = require("tc.ui.UIDefault")

function SourcesManagerUI.createRoot()
    local UI_SIZE = Size.new(800, 450)
    local root = UIUtil.createBlackFullScreenLayer("sources_manage_ui")
    local panel = UIUtil.createWindowPattern(root, UI_SIZE, nil)
    panel:addChild(UIUtil.createLabelNoPos("lb_title", Locale.MOD_SOURCES_TITLE,
            TextAlignment.HCenter, TextAlignment.VCenter, {
                positionY = 12,
                marginsLR = { 0, 0 },
                fontSize = UIDefault.FontSize + 8
            }))
    local panelList = UIUtil.createScrollViewNoPos("panel_list", {
        margins = { 16, 64, 16, 140 },
        sprite = {
            name = "tc:round_rect_white",
            color = Color.new(30, 30, 45)
        }
    })
    panel:addChild(panelList)
    local panelItem = UIPanel.new("panel_item", 0, 0, panelList.size.width, 64)
    panelList:addChild(panelItem)
    panelItem:addChild(UIUtil.createImageNoPos("img_selected", {
        margins = { 0, 0, 0, 0 },
        touchable = false,
        visible = false,
        sprite = {
            name = "tc:round_rect_white",
            color = Color.new(60, 60, 80, 222)
        }
    }))
    panelItem:addChild(UIUtil.createImage("img_line", 0, 64, 100, 2, {
        marginsLR = { 16, 16 },
        sprite = {
            name = "tc:white",
            color = Color.new(60, 60, 80, 100)
        }
    }))
    panelItem:addChild(UIUtil.createLabel("lb_name", "Test Name <c=#888888FF>(mod_id)</c>",
            16, 16, 128, 24,
            TextAlignment.Left, TextAlignment.VCenter, {
                isRichText = true,
            }))

    panel:addChild(UIUtil.createButton("btn_folder", Locale.OPEN_SOURCES_FOLDER, 0, 200, 220, UIDefault.ButtonHeight, {
        anchorPoint = { 0.5, 0 },
        margins = { 0, nil, UI_SIZE.width * 0.66, 72, false, false },
        targetSprite = { color = Color.new(110, 108, 132, 255) },
    }))
    panelItem:addChild(UIUtil.createButton("btn_publish", Locale.PUBLISH, 0, 0, 130, UIDefault.ButtonHeight, {
        anchorPoint = { 0.5, 0 },
        margins = { nil, 0, 160, 0, false, false },
        targetSprite = { color = Color.new(110, 108, 132, 255) },
    }))
    panelItem:addChild(UIUtil.createButton("btn_edit", Locale.MOD_EDITING, 0, 0, 130, UIDefault.ButtonHeight, {
        anchorPoint = { 0.5, 0 },
        margins = { nil, 0, 20, 0, false, false },
        targetSprite = { color = Color.new(110, 108, 132, 255) },
    }))
    panel:addChild(UIUtil.createButton("btn_publish_all", Locale.PUBLISH_ALL, 0, 200, 220, UIDefault.ButtonHeight, {
        anchorPoint = { 0.5, 0 },
        margins = { 0, nil, 0, 72, false, false },
        targetSprite = { color = Color.new(110, 108, 132, 255) },
    }))
    panel:addChild(UIUtil.createButton("btn_back", TCLocale.BACK, 0, 200, 220, UIDefault.ButtonHeight, {
        anchorPoint = { 0.5, 0 },
        margins = { 0, nil, 0, 16, false, false },
        targetSprite = { color = Color.new(110, 108, 132, 255) },
    }))
    panel:addChild(UIUtil.createButton("btn_create", Locale.CREATE_MOD, 0, 200, 220, UIDefault.ButtonHeight, {
        anchorPoint = { 0.5, 0 },
        margins = { UI_SIZE.width * 0.66, nil, 0, 72, false, false },
        targetSprite = { color = Color.new(110, 108, 132, 255) },
    }))
    return root
end

function SourcesManagerUI:__init()
    SourcesManagerUI.super.__init(self, SourcesManagerUI.createRoot())
    self._indexSelected = 0
    self._dataList = {}
    self._itemNodes = {}

    self:initContent()
end

function SourcesManagerUI:initContent()
    self:_initData()
    local panelList = self.root:getChild("layer.panel_list")
    local panelItem = panelList:getChild("panel_item")
    self.itemSize = Size.new(panelItem.width / 1, panelItem.height)
    UIUtil.setTable(panelList, self, true, 1)

    self.root:getChild("layer.btn_back"):addTouchUpListener({
        function(self)
            local ModListUI = require("tc.ui.ModListUI")
            self.manager:playClickSound()
            self:closeWindow()
            ModListUI.new()
        end, self }
    )

    self.root:getChild("layer.btn_create"):addTouchUpListener({
        function(self)
            local NewModUI = require("NewModUI")
            self.manager:playClickSound()
            self:closeWindow()
            NewModUI.new()
        end, self }
    )

    self.root:getChild("layer.btn_publish_all"):addTouchUpListener({ self.publishAll, self })
    self.root:getChild("layer.btn_folder"):addTouchUpListener({ self.openSourceFolder, self })

    self:updateSelection()
end

function SourcesManagerUI._getAllPackagePath()
    local res = {}

    local function _innerGetPath(baseFolderPath)
        if not File.isPathExist(baseFolderPath) then
            return
        end
        local folderNames = File.getAllSubFolders(baseFolderPath, false)
        for _, fn in ipairs(folderNames) do
            local fp = Path.join(baseFolderPath, fn)
            local packagePath = Path.join(fp, "package.json")
            if File.isPathExist(packagePath) then
                table.insert(res, { baseFolderPath, fn, packagePath })
            end
        end
    end

    _innerGetPath("devmods")
    _innerGetPath(Path.join(App.persistentDataPath, "devmods"))

    return res
end

function SourcesManagerUI:_initData()
    local packagePaths = SourcesManagerUI._getAllPackagePath()
    for _, pathData in ipairs(packagePaths) do
        local baseFolderPath = pathData[1]
        local folderName = pathData[2]
        local path = pathData[3]
        local jsonStr = File.readAsString(path)
        local json = JsonUtil.fromJson(jsonStr)
        json._baseFolderPath = baseFolderPath
        json._folderName = folderName
        table.insert(self._dataList, json)
    end
end

function SourcesManagerUI:_getTableElementCount()
    return #self._dataList
end

function SourcesManagerUI:_getTableElementSize()
    return self.itemSize
end

---_setTableElement
---@param node UINode
---@param index number
function SourcesManagerUI:_setTableElement(node, index)
    node.tag = index

    local data = self._dataList[index]
    local lbName = UIText.cast(node:getChild("lb_name"))
    local name = ""

    if data.displayName then
        name = data.displayName
    end
    if data.id then
        name = name .. string.format(" <c=#888888FF>(%s)</c>", data.id)
    end
    if data.version then
        name = name .. string.format(" <c=#888888FF>(ver:%s)</c>", data.version)
    end
    lbName.text = name

    node:addTouchUpListener({ self._onElementClicked, self })
    node:getChild("btn_publish"):addTouchUpListener({ self._onPublishClicked, self, index })
    node:getChild("btn_edit"):addTouchUpListener({ self._onEditClicked, self, index })
    table.insert(self._itemNodes, node)
end

---_onElementClicked
---@param node UINode
---@param _ Touch
function SourcesManagerUI:_onElementClicked(node)
    local index = node.tag
    if self._indexSelected ~= index then
        self.manager:playClickSound()
        self._indexSelected = index
        self:updateSelection()
    end
end

function SourcesManagerUI:updateSelection()
    ---@param node UINode
    for _, node in pairs(self._itemNodes) do
        local show = false
        if node.tag == self._indexSelected then
            show = true
        end
        node:getChild("img_selected").visible = show
        node:getChild("btn_publish").visible = show
        node:getChild("btn_edit").visible = show
    end
end

function SourcesManagerUI:publish(index)
    local data = self._dataList[index]
    if data.id == nil then
        return ""
    end
    local res = AssetManager.genPackFromSource(data._baseFolderPath, data._folderName, "mods")
    if res then
        return string.format(Locale.MOD_PUBLISH_AT, data.id, Path.getFileName(res))
    end
    return ""
end

function SourcesManagerUI:openSourceFolder()
    self.manager:playClickSound()
    if App.isPC then
        File.openFolderWindow(Path.join(App.persistentDataPath, "devmods"))
    end
end

function SourcesManagerUI:_onPublishClicked(index)
    self.manager:playClickSound()
    local res = self:publish(index)
    if not res then
        res = Locale.MOD_PUBLISH_FAILED
    else
        res = res .. "\n" .. Locale.MOD_PUBLISH_NEED_RESTART
    end
    self:showPublishResult(res)
end

function SourcesManagerUI:_onEditClicked(index)
    require("tc.ui.InfoPopupUI").new(Locale.MOD_EDIT_DEV)
end

function SourcesManagerUI:publishAll()
    self.manager:playClickSound()
    local cnt = #self._dataList
    local allRes = ""
    local okCnt = 0
    for i = 1, cnt do
        local res = self:publish(i)
        if res then
            if allRes then
                allRes = allRes .. "\n"
            end
            allRes = allRes .. res
            okCnt = okCnt + 1
        end
    end
    if okCnt > 0 then
        allRes = allRes .. "\n" .. string.format(Locale.MOD_PUBLISH_SUCCESS, okCnt)
        allRes = allRes .. "\n" .. Locale.MOD_PUBLISH_NEED_RESTART
    else
        allRes = Locale.MOD_PUBLISH_FAILED
    end
    self:showPublishResult(allRes)
end

function SourcesManagerUI:showPublishResult(resString)
    require("tc.ui.InfoPopupUI").new(resString, nil, nil, true)
end

function SourcesManagerUI:closeWindow()
    SourcesManagerUI.super.closeWindow(self)
end

return SourcesManagerUI