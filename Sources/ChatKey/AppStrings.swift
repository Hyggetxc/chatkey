import Foundation

enum StringKey {
    case appTitle
    case enabled
    case paused
    case currentApp
    case noCurrentApp
    case openSettings
    case quit
    case permissions
    case permissionsGranted
    case permissionsMissing
    case requestPermission
    case rules
    case noRuleSelected
    case general
    case language
    case followSystem
    case simplifiedChinese
    case english
    case autoCheckUpdates
    case checkForUpdates
    case updates
    case openReleasesPage
    case updateAvailable
    case upToDate
    case updateRepositoryNotConfigured
    case updateCheckFailed
    case ruleEnabled
    case appWideToggle
    case currentVersion
    case latestStatus
    case triggerPlaceholder
    case outputPlaceholder
    case none
    case diagnostics
    case listener
    case listenerActive
    case permissionRequired
    case lastError
    case refreshStatus
    case permissionGrantHelp
    case installedApplications
    case appSearchPlaceholder
    case refreshInstalledApps
    case noInstalledAppsFound
    case createRuleForSelectedApp
    case openSelectedAppRule
    case configuredTag
    case noConfiguredRules
    case selectedAppNeedsRule
    case settingsWindowTitle
    case statusOverview
    case preferences
    case chatKeyStatus
    case systemAccessibilityStatus
    case checkingUpdates
    case rulesPageDescription
    case appName
    case bundleIdentifier
    case notes
    case mappings
    case trigger
    case output
    case addMapping
    case deleteRule
    case menuPopoverSubtitle
    case menuToggleHint
    case openSystemSettings
    case statusPermissionMissingTitle
    case statusPermissionMissingMessage
    case statusPausedTitle
    case statusPausedMessage
    case statusReadyTitle
    case statusReadyMessage
    case generalPreferencesSubtitle
    case generalUpdatesSubtitle
    case generalDiagnosticsSubtitle
    case generalNoDiagnosticsMessage
    case ruleMappingsSubtitle
    case resultsSuffix
    case rulesSuffix
}

enum AppStrings {
    static func text(_ key: StringKey, language: AppLanguage) -> String {
        switch language.resolvedLanguage {
        case .zhHans:
            return chinese(key)
        case .en, .system:
            return english(key)
        }
    }

    static func trigger(_ key: TriggerKey, language: AppLanguage) -> String {
        switch key {
        case .return:
            return language.resolvedLanguage == .zhHans ? "Return" : "Return"
        case .shiftReturn:
            return language.resolvedLanguage == .zhHans ? "Shift + Return" : "Shift + Return"
        case .commandReturn:
            return language.resolvedLanguage == .zhHans ? "Command + Return" : "Command + Return"
        case .optionReturn:
            return language.resolvedLanguage == .zhHans ? "Option + Return" : "Option + Return"
        case .controlReturn:
            return language.resolvedLanguage == .zhHans ? "Control + Return" : "Control + Return"
        }
    }

    static func output(_ action: OutputAction, language: AppLanguage) -> String {
        switch action {
        case .none:
            return text(.none, language: language)
        case .return:
            return trigger(.return, language: language)
        case .shiftReturn:
            return trigger(.shiftReturn, language: language)
        case .commandReturn:
            return trigger(.commandReturn, language: language)
        case .optionReturn:
            return trigger(.optionReturn, language: language)
        case .controlReturn:
            return trigger(.controlReturn, language: language)
        }
    }

    private static func chinese(_ key: StringKey) -> String {
        switch key {
        case .appTitle: "ChatKey"
        case .enabled: "已启用"
        case .paused: "已暂停"
        case .currentApp: "当前应用"
        case .noCurrentApp: "未识别到前台应用"
        case .openSettings: "打开设置"
        case .quit: "退出"
        case .permissions: "辅助功能权限"
        case .permissionsGranted: "已授权"
        case .permissionsMissing: "未授权"
        case .requestPermission: "请求授权"
        case .rules: "规则"
        case .noRuleSelected: "请选择一条规则开始编辑"
        case .appName: "应用名称"
        case .bundleIdentifier: "Bundle ID"
        case .notes: "备注"
        case .mappings: "映射"
        case .trigger: "触发键"
        case .output: "目标动作"
        case .addMapping: "新增映射"
        case .deleteRule: "删除规则"
        case .menuPopoverSubtitle: "菜单栏弹层"
        case .menuToggleHint: "点击即可即时切换键盘映射。"
        case .openSystemSettings: "打开系统设置"
        case .statusPermissionMissingTitle: "未授权系统设置"
        case .statusPermissionMissingMessage: "需要先在系统设置里授予辅助功能权限。"
        case .statusPausedTitle: "已授权未开启"
        case .statusPausedMessage: "权限已授予，功能处于暂停状态。"
        case .statusReadyTitle: "已授权已开启"
        case .statusReadyMessage: "当前正在工作，输入映射会按规则生效。"
        case .generalPreferencesSubtitle: "控制启用状态和界面语言。"
        case .generalUpdatesSubtitle: "保留手动检查，也可以自动同步新版本。"
        case .generalDiagnosticsSubtitle: "最近一次错误会显示在这里。"
        case .generalNoDiagnosticsMessage: "当前没有错误。若监听器异常或更新失败，这里会显示最近一次信息。"
        case .ruleMappingsSubtitle: "一条规则可以包含多组触发键和目标动作。"
        case .resultsSuffix: "个结果"
        case .rulesSuffix: "条规则"
        case .general: "通用"
        case .language: "界面语言"
        case .followSystem: "跟随系统"
        case .simplifiedChinese: "简体中文"
        case .english: "English"
        case .autoCheckUpdates: "自动检查更新"
        case .checkForUpdates: "检测更新"
        case .updates: "更新"
        case .openReleasesPage: "前往 GitHub 下载"
        case .updateAvailable: "发现新版本"
        case .upToDate: "当前已是最新版本"
        case .updateRepositoryNotConfigured: "尚未配置 GitHub Releases 仓库"
        case .updateCheckFailed: "检测更新失败"
        case .ruleEnabled: "规则启用"
        case .appWideToggle: "启用 ChatKey"
        case .currentVersion: "当前版本"
        case .latestStatus: "最新状态"
        case .triggerPlaceholder: "选择触发键"
        case .outputPlaceholder: "选择目标动作"
        case .none: "不处理"
        case .diagnostics: "诊断"
        case .listener: "监听器"
        case .listenerActive: "运行中"
        case .permissionRequired: "需要权限"
        case .lastError: "最近错误"
        case .refreshStatus: "刷新状态"
        case .permissionGrantHelp: "请在系统设置中授予辅助功能权限，返回后状态会自动刷新。"
        case .installedApplications: "本机应用"
        case .appSearchPlaceholder: "搜索应用名称或 Bundle ID"
        case .refreshInstalledApps: "刷新应用列表"
        case .noInstalledAppsFound: "没有找到匹配的本机应用"
        case .createRuleForSelectedApp: "为所选应用创建规则"
        case .openSelectedAppRule: "打开所选应用规则"
        case .configuredTag: "已配置"
        case .noConfiguredRules: "还没有配置任何规则"
        case .selectedAppNeedsRule: "当前应用还没有规则，点击下方按钮即可开始配置映射。"
        case .settingsWindowTitle: "设置"
        case .statusOverview: "状态"
        case .preferences: "偏好设置"
        case .chatKeyStatus: "ChatKey"
        case .systemAccessibilityStatus: "系统辅助权限"
        case .checkingUpdates: "检查中..."
        case .rulesPageDescription: "从本机应用列表中选择一个应用，然后创建或打开对应规则。"
        }
    }

    private static func english(_ key: StringKey) -> String {
        switch key {
        case .appTitle: "ChatKey"
        case .enabled: "Enabled"
        case .paused: "Paused"
        case .currentApp: "Current App"
        case .noCurrentApp: "No frontmost app detected"
        case .openSettings: "Open Settings"
        case .quit: "Quit"
        case .permissions: "Accessibility Permission"
        case .permissionsGranted: "Granted"
        case .permissionsMissing: "Not Granted"
        case .requestPermission: "Request Permission"
        case .rules: "Rules"
        case .noRuleSelected: "Select a rule to start editing"
        case .appName: "App Name"
        case .bundleIdentifier: "Bundle ID"
        case .notes: "Notes"
        case .mappings: "Mappings"
        case .trigger: "Trigger"
        case .output: "Output"
        case .addMapping: "Add Mapping"
        case .deleteRule: "Delete Rule"
        case .menuPopoverSubtitle: "Menu Bar Popover"
        case .menuToggleHint: "Toggle keyboard remapping immediately."
        case .openSystemSettings: "Open System Settings"
        case .statusPermissionMissingTitle: "System Permission Required"
        case .statusPermissionMissingMessage: "Grant Accessibility permission in System Settings first."
        case .statusPausedTitle: "Granted but Paused"
        case .statusPausedMessage: "Permission is granted, but feature is paused."
        case .statusReadyTitle: "Granted and Enabled"
        case .statusReadyMessage: "ChatKey is running and mappings are active."
        case .generalPreferencesSubtitle: "Control enable state and language."
        case .generalUpdatesSubtitle: "Keep manual checks and optionally sync updates automatically."
        case .generalDiagnosticsSubtitle: "The most recent error appears here."
        case .generalNoDiagnosticsMessage: "No errors right now. If listener or update fails, the latest error is shown here."
        case .ruleMappingsSubtitle: "A rule can include multiple trigger/output mappings."
        case .resultsSuffix: "results"
        case .rulesSuffix: "rules"
        case .general: "General"
        case .language: "Language"
        case .followSystem: "Follow System"
        case .simplifiedChinese: "Simplified Chinese"
        case .english: "English"
        case .autoCheckUpdates: "Automatically Check for Updates"
        case .checkForUpdates: "Check for Updates"
        case .updates: "Updates"
        case .openReleasesPage: "Open GitHub Releases"
        case .updateAvailable: "A new version is available"
        case .upToDate: "You're up to date"
        case .updateRepositoryNotConfigured: "GitHub Releases repository is not configured yet"
        case .updateCheckFailed: "Failed to check for updates"
        case .ruleEnabled: "Rule Enabled"
        case .appWideToggle: "Enable ChatKey"
        case .currentVersion: "Current Version"
        case .latestStatus: "Latest Status"
        case .triggerPlaceholder: "Choose a trigger"
        case .outputPlaceholder: "Choose an output"
        case .none: "Do Nothing"
        case .diagnostics: "Diagnostics"
        case .listener: "Listener"
        case .listenerActive: "Active"
        case .permissionRequired: "Permission Required"
        case .lastError: "Last Error"
        case .refreshStatus: "Refresh Status"
        case .permissionGrantHelp: "Grant Accessibility in System Settings, then return here. Status will refresh automatically."
        case .installedApplications: "Installed Apps"
        case .appSearchPlaceholder: "Search by app name or bundle ID"
        case .refreshInstalledApps: "Refresh App List"
        case .noInstalledAppsFound: "No installed apps matched your search"
        case .createRuleForSelectedApp: "Create Rule for Selected App"
        case .openSelectedAppRule: "Open Rule for Selected App"
        case .configuredTag: "Configured"
        case .noConfiguredRules: "No rules configured yet"
        case .selectedAppNeedsRule: "This app does not have a rule yet. Click the button below to start configuring mappings."
        case .settingsWindowTitle: "Settings"
        case .statusOverview: "Status"
        case .preferences: "Preferences"
        case .chatKeyStatus: "ChatKey"
        case .systemAccessibilityStatus: "System Accessibility"
        case .checkingUpdates: "Checking..."
        case .rulesPageDescription: "Choose an installed app, then create or open its rule."
        }
    }
}
