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
                infoPanel(rule: rule)
                mappingsPanel(rule: rule)
                deletePanel
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            CardSurface(padding: 24) {
                ContentUnavailableView(
                    AppStrings.text(.noRuleSelected, language: language),
                    systemImage: "keyboard"
                )
                .frame(maxWidth: .infinity, minHeight: 280)
            }
        }
    }

    private func infoPanel(rule: AppRule) -> some View {
        CardSurface {
            VStack(alignment: .leading, spacing: SettingsMetrics.sectionSpacing) {
                SectionHeaderView(
                    title: rule.appName,
                    subtitle: AppStrings.text(.ruleDetailsSubtitle, language: language),
                    systemImage: "keyboard"
                )

                SettingsFieldRow(title: AppStrings.text(.ruleEnabled, language: language)) {
                    Toggle("", isOn: Binding(
                        get: { rule.isEnabled },
                        set: { ruleStore.updateRuleEnabled($0, ruleID: ruleID) }
                    ))
                    .labelsHidden()
                }

                SettingsFieldRow(title: AppStrings.text(.appName, language: language)) {
                    Text(rule.appName)
                        .font(.system(size: 14, weight: .semibold))
                }

                SettingsFieldRow(title: AppStrings.text(.bundleIdentifier, language: language), alignment: .top) {
                    Text(rule.bundleId)
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.medium)
                        .frame(maxWidth: 360, alignment: .trailing)
                        .multilineTextAlignment(.trailing)
                }

                SettingsFieldRow(
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
                    .lineLimit(2...3)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 320)
                }
            }
        }
    }

    private func mappingsPanel(rule: AppRule) -> some View {
        CardSurface {
            VStack(alignment: .leading, spacing: SettingsMetrics.sectionSpacing) {
                HStack(alignment: .firstTextBaseline) {
                    SectionHeaderView(
                        title: AppStrings.text(.mappings, language: language),
                        subtitle: AppStrings.text(.ruleMappingsSubtitle, language: language)
                    )

                    Spacer(minLength: 0)

                    Button(AppStrings.text(.addMapping, language: language)) {
                        ruleStore.addMapping(to: ruleID)
                    }
                    .buttonStyle(.borderedProminent)
                }

                VStack(spacing: 10) {
                    ForEach(rule.mappings) { mapping in
                        mappingRow(mapping, ruleID: ruleID)
                    }
                }
            }
        }
    }

    private var deletePanel: some View {
        HStack {
            Spacer(minLength: 0)
            Button(role: .destructive) {
                ruleStore.deleteRule(ruleID: ruleID)
            } label: {
                Label(AppStrings.text(.deleteRule, language: language), systemImage: "trash")
            }
            .buttonStyle(.bordered)
        }
    }

    @ViewBuilder
    private func mappingRow(_ mapping: KeyMapping, ruleID: UUID) -> some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(AppStrings.text(.trigger, language: language))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)

                Picker(
                    AppStrings.text(.triggerPlaceholder, language: language),
                    selection: Binding(
                        get: { mapping.trigger },
                        set: { ruleStore.updateMappingTrigger(ruleID: ruleID, mappingID: mapping.id, trigger: $0) }
                    )
                ) {
                    ForEach(TriggerKey.allCases) { trigger in
                        Text(AppStrings.trigger(trigger, language: language)).tag(trigger)
                    }
                }
                .pickerStyle(.menu)
                .frame(minWidth: 170)
            }

            Image(systemName: "arrow.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.top, 18)

            VStack(alignment: .leading, spacing: 6) {
                Text(AppStrings.text(.output, language: language))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)

                Picker(
                    AppStrings.text(.outputPlaceholder, language: language),
                    selection: Binding(
                        get: { mapping.output },
                        set: { ruleStore.updateMappingOutput(ruleID: ruleID, mappingID: mapping.id, output: $0) }
                    )
                ) {
                    ForEach(OutputAction.allCases) { output in
                        Text(AppStrings.output(output, language: language)).tag(output)
                    }
                }
                .pickerStyle(.menu)
                .frame(minWidth: 170)
            }

            Spacer(minLength: 0)

            Button(role: .destructive) {
                ruleStore.removeMapping(ruleID: ruleID, mappingID: mapping.id)
            } label: {
                Image(systemName: "trash")
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.borderless)
            .padding(.top, 18)
        }
        .padding(SettingsMetrics.rowPadding)
        .background(
            RoundedRectangle(cornerRadius: SettingsMetrics.innerCornerRadius, style: .continuous)
                .fill(Color(nsColor: .windowBackgroundColor).opacity(0.55))
                .overlay(
                    RoundedRectangle(cornerRadius: SettingsMetrics.innerCornerRadius, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
                )
        )
    }
}
