import SwiftUI

struct WritingStylesView: View {
    @EnvironmentObject var writingStylesStore: WritingStylesStore
    
    @State private var editingStyle: WritingStyle?
    @State private var expandedStyleIndices: Set<Int> = []
    @State private var showingAddStyle = false
    
    var body: some View {
        #if os(macOS)
        // macOS Layout
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Writing Styles")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Add examples of your writing to help the AI learn your style")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 20)
            .background(Color.black)
            
            // Add Button
            HStack {
                Button(action: {
                    editingStyle = nil
                    showingAddStyle = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 12))
                        Text("Add Writing Style")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.blue.opacity(0.8))
                    )
                    .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(writingStylesStore.writingStyles.count >= 30)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
            .background(Color.black)
            
            // Content
            if writingStylesStore.writingStyles.isEmpty {
                emptyStateView
            } else {
                writingStylesList
            }
        }
        .background(Color.black)
        .sheet(isPresented: $showingAddStyle) {
            AddStyleView(editingStyle: editingStyle) { title, style in
                if let editingStyle = editingStyle {
                    // Editing existing style
                    if let index = writingStylesStore.writingStyles.firstIndex(where: { $0.id == editingStyle.id }) {
                        writingStylesStore.updateStyle(at: index, with: style, title: title)
                    }
                } else {
                    // Adding new style
                    writingStylesStore.addStyle(style, title: title)
                }
                editingStyle = nil
            }
        }
        #else
        // iOS Layout
        NavigationView {
            VStack(spacing: 24) {
                if writingStylesStore.writingStyles.isEmpty {
                    emptyStateView
                } else {
                    writingStylesList
                }
            }
            .background(Color.black)
            .navigationTitle("Writing Styles")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        editingStyle = nil
                        showingAddStyle = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.blue)
                    }
                    .disabled(writingStylesStore.writingStyles.count >= 30)
                }
            }
            .sheet(isPresented: $showingAddStyle) {
                AddStyleView(editingStyle: editingStyle) { title, style in
                    if let editingStyle = editingStyle {
                        // Editing existing style
                        if let index = writingStylesStore.writingStyles.firstIndex(where: { $0.id == editingStyle.id }) {
                            writingStylesStore.updateStyle(at: index, with: style, title: title)
                        }
                    } else {
                        // Adding new style
                        writingStylesStore.addStyle(style, title: title)
                    }
                    editingStyle = nil
                }
            }
        }
        #endif
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "book.closed")
                .font(.system(size: 64))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("No Writing Styles Yet")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Add examples of your own emails to help the AI learn your writing style and generate emails that match your tone and voice.")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: { showingAddStyle = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 12))
                    Text("Add First Writing Style")
                        .font(.system(size: 13, weight: .medium))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.blue.opacity(0.8))
                )
                .foregroundColor(.white)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .background(Color.black)
    }
    
    private var writingStylesList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(Array(writingStylesStore.writingStyles.enumerated()), id: \.offset) { index, style in
                    writingStyleBox(index: index, style: style)
                }
            }
            .padding(24)
        }
        .background(Color.black)
    }
    
    private func writingStyleBox(index: Int, style: WritingStyle) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Button(action: {
                if expandedStyleIndices.contains(index) {
                    expandedStyleIndices.remove(index)
                } else {
                    expandedStyleIndices.insert(index)
                }
            }) {
                HStack {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow)
                    
                    Text(style.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: expandedStyleIndices.contains(index) ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
                .padding(16)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Content
            if expandedStyleIndices.contains(index) {
                VStack(alignment: .leading, spacing: 12) {
                    #if os(macOS)
                    Text(style.content)
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        .padding(16)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .textSelection(.enabled)
                    #else
                    Text(style.content)
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        .padding(16)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    #endif
                    HStack {
                        Button("Edit") {
                            editingStyle = style
                            showingAddStyle = true
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
                        
                        Spacer()
                        
                        Button("Delete") {
                            writingStylesStore.deleteStyle(at: index)
                            expandedStyleIndices.remove(index)
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
                    }
                }
                .padding(.top, 8)
            }
        }
    }
}

struct AddStyleView: View {
    let editingStyle: WritingStyle?
    let onSave: (String, String) -> Void
    @State private var styleTitle: String
    @State private var styleText: String
    @Environment(\.presentationMode) var presentationMode
    
    init(editingStyle: WritingStyle? = nil, onSave: @escaping (String, String) -> Void) {
        self.editingStyle = editingStyle
        self.onSave = onSave
        self._styleTitle = State(initialValue: editingStyle?.title ?? "")
        self._styleText = State(initialValue: editingStyle?.content ?? "")
    }
    
    var body: some View {
        #if os(macOS)
        // macOS Modal with transparency
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text(editingStyle != nil ? "Edit Writing Style" : "Add Writing Style Example")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Paste an example of your own email writing to help the AI understand your style, tone, and writing patterns.")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Style Title")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
                
                TextField("Enter a title for this style", text: $styleTitle)
                    .padding(12)
                    .background(Color.clear)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Your Email Example")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
                
                TextEditor(text: $styleText)
                    .frame(minHeight: 200)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
            
            HStack(spacing: 12) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .font(.system(size: 13, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.3))
                )
                .foregroundColor(.white)
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Button("Save") {
                    if !styleText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        onSave(styleTitle, styleText)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .font(.system(size: 13, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.blue.opacity(0.8))
                )
                .foregroundColor(.white)
                .buttonStyle(PlainButtonStyle())
                .disabled(styleText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(32)
        .frame(width: 500, height: 500)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
        #else
        // iOS Modal
        NavigationView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Style Title")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    TextField("Enter a title for this style", text: $styleTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .background(Color(red: 0.15, green: 0.15, blue: 0.15))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Email Example")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    TextEditor(text: $styleText)
                        .frame(minHeight: 200)
                        .background(Color(red: 0.15, green: 0.15, blue: 0.15))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                
                Spacer()
            }
            .padding(24)
            .background(Color.black)
            .navigationTitle(editingStyle != nil ? "Edit Writing Style" : "Add Writing Style Example")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.gray)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if !styleText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            onSave(styleTitle, styleText)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .foregroundColor(.blue)
                    .disabled(styleText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        #endif
    }
}

#Preview {
    WritingStylesView()
        .environmentObject(WritingStylesStore())
} 