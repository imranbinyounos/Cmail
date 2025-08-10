import SwiftUI

struct DraftsView: View {
    @EnvironmentObject var draftStore: DraftStore
    @State private var draftContent: String = ""
    @State private var isBold = false
    @State private var isItalic = false
    @State private var isUnderline = false
    @State private var expandedDraftIndex: Int? = nil
    @State private var editingDraftIndex: Int? = nil
    @State private var editingTitleIndex: Int? = nil
    @State private var editingTitle: String = ""
    
    var body: some View {
        #if os(macOS)
        HStack(spacing: 0) {
            // Left: Writing Area (full height)
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Draft Playground")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Text("Write and save drafts. No AI involved. Your writing area is always open.")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 20)
                .background(Color.black)
                // Formatting toolbar (visual only)
                HStack(spacing: 16) {
                    Button(action: { isBold.toggle() }) {
                        Image(systemName: "bold")
                            .foregroundColor(isBold ? .blue : .gray)
                    }.help("Bold (visual only)")
                    Button(action: { isItalic.toggle() }) {
                        Image(systemName: "italic")
                            .foregroundColor(isItalic ? .blue : .gray)
                    }.help("Italic (visual only)")
                    Button(action: { isUnderline.toggle() }) {
                        Image(systemName: "underline")
                            .foregroundColor(isUnderline ? .blue : .gray)
                    }.help("Underline (visual only)")
                    Spacer()
                    Button(editingDraftIndex != nil ? "Update Draft" : "Save Draft") {
                        if let editingIndex = editingDraftIndex {
                            // Update existing draft
                            let updatedDraft = Draft(title: draftStore.drafts[editingIndex].title, content: draftContent)
                            draftStore.updateDraft(updatedDraft, at: editingIndex)
                            editingDraftIndex = nil
                        } else {
                            // Save new draft
                            let draftNumber = draftStore.drafts.count + 1
                            let title = "Draft \(draftNumber)"
                            let newDraft = Draft(title: title, content: draftContent)
                            draftStore.addDraft(newDraft)
                        }
                        draftContent = ""
                    }
                    .font(.system(size: 13, weight: .medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.blue.opacity(0.8))
                    )
                    .foregroundColor(.white)
                    .disabled(draftContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 8)
                // Large, resizable TextEditor
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                    TextEditor(text: $draftContent)
                        .font(.system(size: 16, weight: isBold ? .bold : .regular, design: .default))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.clear)
                        .cornerRadius(8)
                        .modifier(ConditionalItalic(isItalic: isItalic))
                        .modifier(ConditionalUnderline(isUnderline: isUnderline))
                }
                .frame(minHeight: 400, maxHeight: .infinity)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            // Right: List of Drafts as expandable/collapsible tiles
            VStack(alignment: .leading, spacing: 0) {
                Text("Saved Drafts")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 32)
                    .padding(.horizontal, 24)
                if draftStore.drafts.isEmpty {
                    Text("No drafts saved yet.")
                        .foregroundColor(.gray)
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(Array(draftStore.drafts.enumerated()), id: \.offset) { index, draft in
                                VStack(alignment: .leading, spacing: 0) {
                                    // Header (tile)
                                    Button(action: {
                                        if expandedDraftIndex == index {
                                            expandedDraftIndex = nil
                                        } else {
                                            expandedDraftIndex = index
                                        }
                                    }) {
                                        HStack {
                                            Button(action: {
                                                editingTitleIndex = index
                                                editingTitle = draft.title
                                            }) {
                                                Image(systemName: "pencil")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.yellow)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .help("Edit Title")
                                            
                                            if editingTitleIndex == index {
                                                TextField("Title", text: $editingTitle, onCommit: {
                                                    if !editingTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                                        var updatedDraft = draft
                                                        updatedDraft.title = editingTitle
                                                        draftStore.updateDraft(updatedDraft, at: index)
                                                        editingTitleIndex = nil
                                                    }
                                                })
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.white)
                                                .textFieldStyle(PlainTextFieldStyle())
                                                .onSubmit {
                                                    if !editingTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                                        var updatedDraft = draft
                                                        updatedDraft.title = editingTitle
                                                        draftStore.updateDraft(updatedDraft, at: index)
                                                        editingTitleIndex = nil
                                                    }
                                                }
                                            } else {
                                                Text(draft.title)
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundColor(.white)
                                            }
                                            
                                            Spacer()
                                            Image(systemName: expandedDraftIndex == index ? "chevron.up" : "chevron.down")
                                                .font(.system(size: 10))
                                                .foregroundColor(.gray)
                                        }
                                        .padding(16)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    // Content (expandable)
                                    if expandedDraftIndex == index {
                                        VStack(alignment: .leading, spacing: 12) {
                                            // Action buttons directly under the title
                                            HStack {
                                                Button("Edit") {
                                                    editingDraftIndex = index
                                                    draftContent = draft.content
                                                }
                                                .font(.system(size: 12, weight: .medium))
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 6)
                                                        .fill(Color.blue.opacity(0.8))
                                                )
                                                .foregroundColor(.white)
                                                .buttonStyle(PlainButtonStyle())
                                                Button("Copy") {
                                                    NSPasteboard.general.clearContents()
                                                    NSPasteboard.general.setString(draft.content, forType: .string)
                                                }
                                                .font(.system(size: 12, weight: .medium))
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 6)
                                                        .fill(Color.gray.opacity(0.8))
                                                )
                                                .foregroundColor(.white)
                                                .buttonStyle(PlainButtonStyle())
                                                Button("Delete") {
                                                    draftStore.deleteDraft(at: index)
                                                    if expandedDraftIndex == index {
                                                        expandedDraftIndex = nil
                                                    }
                                                    if editingDraftIndex == index {
                                                        editingDraftIndex = nil
                                                        draftContent = ""
                                                    }
                                                }
                                                .font(.system(size: 12, weight: .medium))
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 6)
                                                        .fill(Color.red.opacity(0.8))
                                                )
                                                .foregroundColor(.white)
                                                .buttonStyle(PlainButtonStyle())
                                                Spacer()
                                            }
                                            // Draft content below the buttons
                                            Text(draft.content)
                                                .font(.system(size: 13))
                                                .foregroundColor(.white)
                                                .padding(16)
                                                .background(Color.gray.opacity(0.1))
                                                .cornerRadius(8)
                                                .textSelection(.enabled)
                                        }
                                        .padding(.top, 8)
                                    }
                                }
                                .padding(.horizontal, 8)
                            }
                        }
                        .padding(.vertical, 16)
                    }
                }
                Spacer()
            }
            .frame(width: 400)
            .background(Color.black)
        }
        .background(Color.black)
        #else
        // iOS version (not implemented here, but can be added similarly)
        Text("Drafts section is only implemented for macOS in this version.")
            .foregroundColor(.white)
            .background(Color.black)
        #endif
    }
}

// Helper modifiers for visual-only formatting
struct ConditionalItalic: ViewModifier {
    let isItalic: Bool
    func body(content: Content) -> some View {
        if isItalic {
            content.italic()
        } else {
            content
        }
    }
}

struct ConditionalUnderline: ViewModifier {
    let isUnderline: Bool
    func body(content: Content) -> some View {
        if isUnderline {
            content.underline()
        } else {
            content
        }
    }
}
