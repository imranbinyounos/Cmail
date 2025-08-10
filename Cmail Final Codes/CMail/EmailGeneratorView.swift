import SwiftUI

struct EmailGeneratorView: View {
    @EnvironmentObject var emailStore: EmailStore
    @EnvironmentObject var writingStylesStore: WritingStylesStore
    @StateObject private var geminiService = GeminiService()
    
    @State private var formData = EmailFormData()
    @State private var generatedEmail: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        #if os(macOS)
        // macOS Layout - Split Panel Design
        HStack(spacing: 0) {
            // Left Panel - Form
            VStack(alignment: .leading, spacing: 0) {
                // Header - Fixed alignment
                VStack(alignment: .leading, spacing: 12) {
                    Text("Email Generator")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Create professional emails tailored to your writing style")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 20)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Form Fields
                        VStack(spacing: 20) {
                            // First row - Professor and University
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Professor's Name")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.gray)
                                    TextField("Enter professor's name", text: $formData.professorName)
                                        .textFieldStyle(ModernTextFieldStyle())
                                }
                                .frame(maxWidth: .infinity)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("University Name")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.gray)
                                    TextField("Enter university name", text: $formData.universityName)
                                        .textFieldStyle(ModernTextFieldStyle())
                                }
                                .frame(maxWidth: .infinity)
                            }
                            
                            // Second row - Department and Lab
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Department Name")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.gray)
                                    TextField("Enter department name", text: $formData.departmentName)
                                        .textFieldStyle(ModernTextFieldStyle())
                                }
                                .frame(maxWidth: .infinity)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Laboratory Name")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.gray)
                                    TextField("Enter lab name", text: $formData.labName)
                                        .textFieldStyle(ModernTextFieldStyle())
                                }
                                .frame(maxWidth: .infinity)
                            }
                            
                            // Third row - Research Topic
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Research Topic")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.gray)
                                TextField("e.g., Quantum Computing, AI, Machine Learning", text: $formData.researchTopic)
                                    .textFieldStyle(ModernTextFieldStyle())
                            }
                            
                            // Opportunity Type
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Opportunity Type")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.gray)
                                
                                HStack(spacing: 12) {
                                    ForEach(OpportunityType.allCases, id: \.self) { type in
                                        Button(action: {
                                            formData.opportunityType = type.rawValue
                                        }) {
                                            Text(type.displayName)
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(formData.opportunityType == type.rawValue ? .white : .primary)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 6)
                                                        .fill(formData.opportunityType == type.rawValue ? Color.blue.opacity(0.8) : Color.gray.opacity(0.2))
                                                )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                            
                            // Project Details
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Project Details")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.gray)
                                TextEditor(text: $formData.projectDetails)
                                    .frame(minHeight: 80)
                                    .background(Color.black.opacity(0.7))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                    )
                                    .foregroundColor(.white)
                            }
                            
                            // Additional Context
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Additional Context")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.gray)
                                TextEditor(text: $formData.prompt)
                                    .frame(minHeight: 80)
                                    .background(Color.black.opacity(0.7))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                    )
                                    .foregroundColor(.white)
                            }
                            
                            // Buttons
                            HStack(spacing: 12) {
                                Button(action: generateEmail) {
                                    HStack {
                                        if geminiService.isLoading {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .scaleEffect(0.7)
                                        } else {
                                            Image(systemName: "envelope.fill")
                                        }
                                        Text(geminiService.isLoading ? "Generating..." : "Generate Email")
                                            .font(.system(size: 13, weight: .medium))
                                    }
                                }
                                .buttonStyle(ModernButtonStyle())
                                .disabled(geminiService.isLoading)
                                
                                Button(action: clearForm) {
                                    Text("Clear")
                                        .font(.system(size: 13, weight: .medium))
                                }
                                .buttonStyle(ModernButtonStyle())
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
            .frame(width: 400)
            .background(Color.black)
            .background(Color.black)
            
            // Right Panel - Generated Email
            VStack(alignment: .leading, spacing: 0) {
                if !generatedEmail.isEmpty {
                    // Header with actions
                    HStack {
                        Text("Generated Email")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
                            Button(action: saveEmail) {
                                HStack(spacing: 4) {
                                    Image(systemName: "folder.badge.plus")
                                        .font(.system(size: 12))
                                    Text("Save")
                                        .font(.system(size: 12, weight: .medium))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.blue.opacity(0.8))
                                )
                                .foregroundColor(.white)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: copyEmail) {
                                HStack(spacing: 4) {
                                    Image(systemName: "doc.on.doc")
                                        .font(.system(size: 12))
                                    Text("Copy")
                                        .font(.system(size: 12, weight: .medium))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.gray.opacity(0.3))
                                )
                                .foregroundColor(.white)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(24)
                    .background(Color.black)
                    
                    // Email content
                    ScrollView {
                        Text(generatedEmail)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .padding(24)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.black)
                            .textSelection(.enabled)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Empty state
                    VStack(spacing: 24) {
                        Image(systemName: "envelope")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 8) {
                            Text("Generated Email Will Appear Here")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                            
                            Text("Fill out the form on the left and click 'Generate Email' to create your personalized email.")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                }
                
                // Error message
                if let errorMessage = geminiService.errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text(errorMessage)
                            .font(.system(size: 13))
                            .foregroundColor(.orange)
                    }
                    .padding(16)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
            .background(Color.black)
        }
                    .background(Color.black)
            .navigationTitle("Email Generator")
            .alert("Message", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        #else
        // iOS version - Clean TabView without any macOS influence
        NavigationView {
            VStack(spacing: 24) {
                // Form Section
                VStack(alignment: .leading, spacing: 20) {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Professor's Name")
                                .font(.headline)
                                .foregroundColor(.gray)
                            TextField("Enter professor's name", text: $formData.professorName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .background(Color(red: 0.15, green: 0.15, blue: 0.15))
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("University Name")
                                .font(.headline)
                                .foregroundColor(.gray)
                            TextField("Enter university name", text: $formData.universityName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .background(Color(red: 0.15, green: 0.15, blue: 0.15))
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Department Name")
                                .font(.headline)
                                .foregroundColor(.gray)
                            TextField("Enter department name", text: $formData.departmentName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .background(Color(red: 0.15, green: 0.15, blue: 0.15))
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Laboratory Name")
                                .font(.headline)
                                .foregroundColor(.gray)
                            TextField("Enter lab name", text: $formData.labName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .background(Color(red: 0.15, green: 0.15, blue: 0.15))
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Research Topic")
                                .font(.headline)
                                .foregroundColor(.gray)
                            TextField("e.g., Quantum Computing, AI, Machine Learning", text: $formData.researchTopic)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .background(Color(red: 0.15, green: 0.15, blue: 0.15))
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Opportunity Type")
                                .font(.headline)
                                .foregroundColor(.gray)
                            HStack(spacing: 8) {
                                ForEach(OpportunityType.allCases, id: \.self) { type in
                                    Button(action: {
                                        formData.opportunityType = type.rawValue
                                    }) {
                                        Text(type.displayName)
                                            .font(.system(size: 13, weight: .medium))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(formData.opportunityType == type.rawValue ? Color.blue : Color(red: 0.15, green: 0.15, blue: 0.15))
                                            .foregroundColor(.white)
                                            .cornerRadius(6)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Project Details")
                                .font(.headline)
                                .foregroundColor(.gray)
                            TextEditor(text: $formData.projectDetails)
                                .frame(minHeight: 80)
                                .background(Color(red: 0.15, green: 0.15, blue: 0.15))
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Additional Context")
                                .font(.headline)
                                .foregroundColor(.gray)
                            TextEditor(text: $formData.prompt)
                                .frame(minHeight: 80)
                                .background(Color(red: 0.15, green: 0.15, blue: 0.15))
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        // Buttons
                        HStack(spacing: 16) {
                            Button(action: generateEmail) {
                                HStack {
                                    if geminiService.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.7)
                                    } else {
                                        Image(systemName: "envelope.fill")
                                    }
                                    Text(geminiService.isLoading ? "Generating..." : "Generate Email")
                                        .fontWeight(.medium)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(geminiService.isLoading ? Color.gray : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .disabled(geminiService.isLoading)
                            
                            Button(action: clearForm) {
                                Text("Clear")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color(red: 0.3, green: 0.3, blue: 0.3))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding(32)
                .frame(maxWidth: 800)
                .frame(maxWidth: .infinity)
                
                // Generated Email Section
                generatedEmailSection
            }
                    .background(Color.black)
        .navigationTitle("Email Generator")
        .alert("Message", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
        #endif
    }
    
    #if os(iOS)
    private var generatedEmailSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Generated Email")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                HStack(spacing: 12) {
                    Button(action: saveEmail) {
                        Image(systemName: "folder.badge.plus")
                            .foregroundColor(.blue)
                    }
                    .help("Save to Saved Emails")
                    
                    Button(action: copyEmail) {
                        Image(systemName: "doc.on.doc")
                            .foregroundColor(.blue)
                    }
                    .help("Copy to Clipboard")
                }
            }
            
            ScrollView {
                Text(generatedEmail)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color(red: 0.2, green: 0.2, blue: 0.2))
                    .cornerRadius(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 400)
        }
        .padding(32)
        .frame(maxWidth: 800)
        .frame(maxWidth: .infinity)
        .background(Color.black)
    }
    #endif
    
    private func generateEmail() {
        Task {
            let email = await geminiService.generateEmail(
                formData: formData,
                savedEmails: emailStore.savedEmails,
                writingStyles: writingStylesStore.writingStyles
            )
            
            await MainActor.run {
                if let email = email {
                    generatedEmail = email
                }
            }
        }
    }
    
    private func clearForm() {
        formData = EmailFormData()
        generatedEmail = ""
    }
    
    private func saveEmail() {
        let title = "Email to \(formData.professorName.isEmpty ? "Professor" : formData.professorName) - \(formData.universityName.isEmpty ? "University" : formData.universityName)"
        let savedEmail = SavedEmail(content: generatedEmail, title: title)
        emailStore.addEmail(savedEmail)
        alertMessage = "Email saved successfully!"
        showingAlert = true
    }
    
    private func copyEmail() {
        #if os(iOS)
        UIPasteboard.general.string = generatedEmail
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(generatedEmail, forType: .string)
        #endif
        alertMessage = "Email copied to clipboard!"
        showingAlert = true
    }
}

// Custom text field style for modern look
struct ModernTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(Color.clear)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
            )
            .foregroundColor(.white)
    }
}

// Custom button style for modern blue/black look
struct ModernButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                configuration.isPressed ? Color.blue.opacity(0.7) : Color.blue.opacity(0.9)
            )
            .foregroundColor(.white)
            .cornerRadius(8)
            .shadow(color: Color.blue.opacity(configuration.isPressed ? 0.1 : 0.2), radius: 6, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

#Preview {
    EmailGeneratorView()
        .environmentObject(EmailStore())
        .environmentObject(WritingStylesStore())
} 