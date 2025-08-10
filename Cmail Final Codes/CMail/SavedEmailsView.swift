import SwiftUI

struct SavedEmailsView: View {
    @EnvironmentObject var emailStore: EmailStore
    @State private var showingEditSheet = false
    @State private var expandedEmailIndex: Int? = nil
    @State private var email: SavedEmail = SavedEmail(content: "", title: "")
    
    var body: some View {
        #if os(macOS)
        // macOS Layout
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Saved Emails")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Access and manage your previously generated emails")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 20)
            .background(Color.black)
            
            // Content
            if emailStore.savedEmails.isEmpty {
                emptyStateView
            } else {
                savedEmailsList
            }
        }
        .background(Color.black)
        .sheet(isPresented: $showingEditSheet) {
            EditEmailView(email: email) { updatedEmail in
                emailStore.updateEmail(updatedEmail)
                showingEditSheet = false
            }
        }
        #else
        // iOS Layout
        NavigationView {
            VStack(spacing: 24) {
                if emailStore.savedEmails.isEmpty {
                    emptyStateView
                } else {
                    savedEmailsList
                }
            }
            .background(Color.black)
            .navigationTitle("Saved Emails")
            .sheet(isPresented: $showingEditSheet) {
                EditEmailView(email: email) { updatedEmail in
                    emailStore.updateEmail(updatedEmail)
                    showingEditSheet = false
                }
            }
        }
        #endif
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "folder")
                .font(.system(size: 64))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("No Saved Emails")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Generated emails will appear here for easy access and editing. You can save emails from the Generator tab to keep them for future reference.")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .background(Color.black)
    }
    
    private var savedEmailsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(Array(emailStore.savedEmails.enumerated()), id: \.offset) { index, email in
                    savedEmailBox(index: index, email: email)
                }
            }
            .padding(24)
        }
        .background(Color.black)
    }
    
    private func savedEmailBox(index: Int, email: SavedEmail) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Button(action: {
                if expandedEmailIndex == index {
                    expandedEmailIndex = nil
                } else {
                    expandedEmailIndex = index
                }
            }) {
                HStack {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(email.title)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 16) {
                            Text(email.dateCreated, style: .date)
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                            
                            Text(email.dateCreated, style: .time)
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: expandedEmailIndex == index ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
                .padding(16)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Content
            if expandedEmailIndex == index {
                VStack(alignment: .leading, spacing: 12) {
                    #if os(macOS)
                    Text(email.content)
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        .padding(16)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .textSelection(.enabled)
                    #else
                    Text(email.content)
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        .padding(16)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    #endif
                    HStack {
                        Button("Edit") {
                            self.email = email
                            showingEditSheet = true
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
                            emailStore.deleteEmail(at: index)
                            if expandedEmailIndex == index {
                                expandedEmailIndex = nil
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
                    }
                }
                .padding(.top, 8)
            }
        }
    }
}

struct EditEmailView: View {
    let email: SavedEmail
    let onSave: (SavedEmail) -> Void
    @State private var editedTitle: String
    @State private var editedContent: String
    @Environment(\.presentationMode) var presentationMode
    
    init(email: SavedEmail, onSave: @escaping (SavedEmail) -> Void) {
        self.email = email
        self.onSave = onSave
        self._editedTitle = State(initialValue: email.title)
        self._editedContent = State(initialValue: email.content)
    }
    
    var body: some View {
        #if os(macOS)
        // macOS Modal with transparency
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Edit Email")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Make changes to your saved email")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Email Title")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
                
                TextField("Enter email title", text: $editedTitle)
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
                Text("Email Content")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
                
                TextEditor(text: $editedContent)
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
                
                Button("Save Changes") {
                    var updatedEmail = email
                    updatedEmail.title = editedTitle
                    updatedEmail.content = editedContent
                    onSave(updatedEmail)
                    presentationMode.wrappedValue.dismiss()
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
                .disabled(editedContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || editedTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
                    Text("Email Title")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    TextField("Enter email title", text: $editedTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .background(Color(red: 0.15, green: 0.15, blue: 0.15))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email Content")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    TextEditor(text: $editedContent)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(red: 0.15, green: 0.15, blue: 0.15))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            .padding(24)
            .background(Color.black)
            .navigationTitle("Edit Email")
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
                        var updatedEmail = email
                        updatedEmail.title = editedTitle
                        updatedEmail.content = editedContent
                        onSave(updatedEmail)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.blue)
                    .disabled(editedContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || editedTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        #endif
    }
}

#Preview {
    SavedEmailsView()
        .environmentObject(EmailStore())
} 