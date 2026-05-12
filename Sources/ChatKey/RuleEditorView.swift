import SwiftUI

struct RuleEditorView: View {
    @ObservedObject var settingsStore: SettingsStore
    @ObservedObject var ruleStore: RuleStore

    let ruleID: UUID

    private var language: AppLanguage {
        settingsStore.settings.language
    }

    private var rule: AppRule? {
        ruleStore.rules.first(where: { $0.id == ruleID })
    }

    var body: some View {
        if let rule {
            VStack(alignment: .leading, spacing: SettingsMetrics.pageSpacing) {
                editorPanel(rule: rule)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            GlassSurface(padding: 24) {
                ContentUnavailableView(
                    AppStrings.text(.noRuleSelected, language: language),
                    systemImage: "keyboard"
                )
                .frame(maxWidth: .infinity, minHeight: 280)
            }
        }
    }

    private func editorPanel(rule: AppRule) -> some View {
        LiquidPanel {
            VStack(alignment: .leading, spacing: 14) {
                appIdentityHeader(rule: rule)
                notesGroup(rule: rule)
                mappingsGroup(rule: rule)
                deleteRuleRow
            }
        }
    }

    private func appIdentityHeader(rule: AppRule) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "keyboard")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.accentColor)
                .frame(width: 42, height: 42)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(rule.appName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.primary)

                Text(rule.bundleId)
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            Toggle("", isOn: Binding(
                get: { rule.isEnabled },
                set: { ruleStore.updateRuleEnabled($0, ruleID: ruleID) }
            ))
            .labelsHidden()
            .toggleStyle(.switch)
        }
        .padding(.horizontal, 2)
    }

    private func notesGroup(rule: AppRule) -> some View {
        SettingsGroup {
            SettingsGroupRow(
                title: AppStrings.text(.notes, language: language),
                alignment: .top
            ) {
                TextField(
                    AppStrings.text(.notes, language: language),
                    text: Binding(
                        get: { rule.notes },
                        set: { ruleStore.updateRuleNotes($0, ruleID: ruleID) }
                    ),
                    axis: .vertical
                )
                .lineLimit(1...3)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 420)
            }
        }
    }

    private func mappingsGroup(rule: AppRule) -> some View {
        SettingsGroup {
            SettingsGroupRow(
                title: AppStrings.text(.mappings, language: language),
                subtitle: AppStrings.text(.ruleMappingsSubtitle, language: language),
                alignment: .top
            ) {
                Button {
                    ruleStore.addMapping(to: ruleID)
                } label: {
                    Label(AppStrings.text(.addMapping, language: language), systemImage: "plus")
                }
                .buttonStyle(LiquidButtonStyle(kind: .primary))
            }

            if !rule.mappings.isEmpty {
                SettingsDivider()
            }

            ForEach(Array(rule.mappings.enumerated()), id: \.element.id) { index, mapping in
                if index > 0 {
                    SettingsDivider()
                }
                mappingRow(mapping, ruleID: ruleID)
            }
        }
    }

    private var deleteRuleRow: some View {
        HStack {
            Spacer(minLength: 0)
            Button(role: .destructive) {
                ruleStore.deleteRule(ruleID: ruleID)
            } label: {
                Label(AppStrings.text(.deleteRule, language: language), systemImage: "trash")
            }
            .buttonStyle(LiquidButtonStyle(kind: .destructive))
        }
    }

    @ViewBuilder
    private func mappingRow(_ mapping: KeyMapping, ruleID: UUID) -> some View {
        HStack(alignment: .center, spacing: 10) {
            mappingPicker(
                title: AppStrings.text(.triggerPlaceholder, language: language),
                selection: Binding(
                    get: { mapping.trigger },
                    set: { ruleStore.updateMappingTrigger(ruleID: ruleID, mappingID: mapping.id, trigger: $0) }
                ),
                values: TriggerKey.allCases,
                label: { AppStrings.trigger($0, language: language) }
            )

            Image(systemName: "arrow.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.tertiary)

            mappingPicker(
                title: AppStrings.text(.outputPlaceholder, language: language),
                selection: Binding(
                    get: { mapping.output },
                    set: { ruleStore.updateMappingOutput(ruleID: ruleID, mappingID: mapping.id, output: $0) }
                ),
                values: OutputAction.allCases,
                label: { AppStrings.output($0, language: language) }
            )

            Spacer(minLength: 8)

            Button(role: .destructive) {
                ruleStore.removeMapping(ruleID: ruleID, mappingID: mapping.id)
            } label: {
                Image(systemName: "trash")
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.borderless)
        }
        .padding(.horizontal, SettingsMetrics.rowPadding)
        .padding(.vertical, 9)
        .frame(minHeight: 50)
        .contentShape(Rectangle())
    }

    private func mappingPicker<Value: Hashable & Identifiable>(
        title: String,
        selection: Binding<Value>,
        values: [Value],
        label: @escaping (Value) -> String
    ) -> some View {
        Picker(title, selection: selection) {
            ForEach(values) { value in
                Text(label(value)).tag(value)
            }
        }
        .pickerStyle(.menu)
        .labelsHidden()
        .frame(minWidth: 132)
        .background(.thinMaterial, in: Capsule(style: .continuous))
        .overlay(
            Capsule(style: .continuous)
                .strokeBorder(Color.primary.opacity(0.07), lineWidth: 1)
        )
    }
}
