import Foundation
import SwiftUI

class EmailStore: ObservableObject {
    @Published var savedEmails: [SavedEmail] = []
    
    init() {
        loadSavedEmails()
    }
    
    func addEmail(_ email: SavedEmail) {
        savedEmails.insert(email, at: 0)
        saveSavedEmails()
    }
    
    func deleteEmail(_ email: SavedEmail) {
        savedEmails.removeAll { $0.id == email.id }
        saveSavedEmails()
    }
    
    func deleteEmail(at index: Int) {
        if index < savedEmails.count {
            savedEmails.remove(at: index)
            saveSavedEmails()
        }
    }
    
    func updateEmail(_ email: SavedEmail) {
        if let index = savedEmails.firstIndex(where: { $0.id == email.id }) {
            savedEmails[index] = email
            saveSavedEmails()
        }
    }
    
    private func saveSavedEmails() {
        if let encoded = try? JSONEncoder().encode(savedEmails) {
            UserDefaults.standard.set(encoded, forKey: "SavedEmails")
        }
    }
    
    private func loadSavedEmails() {
        if let data = UserDefaults.standard.data(forKey: "SavedEmails"),
           let decoded = try? JSONDecoder().decode([SavedEmail].self, from: data) {
            savedEmails = decoded
        }
    }
}

struct WritingStyle: Identifiable, Codable {
    var id = UUID()
    var title: String
    var content: String
    let dateCreated: Date
    
    init(title: String, content: String) {
        self.title = title.isEmpty ? "Writing Style \(Date().formatted(date: .abbreviated, time: .shortened))" : title
        self.content = content
        self.dateCreated = Date()
    }
}

class WritingStylesStore: ObservableObject {
    @Published var writingStyles: [WritingStyle] = []
    
    init() {
        loadWritingStyles()
    }
    
    func addStyle(_ content: String, title: String = "") {
        let style = WritingStyle(title: title, content: content)
        writingStyles.append(style)
        saveWritingStyles()
    }
    
    func updateStyle(at index: Int, with content: String, title: String = "") {
        if index < writingStyles.count {
            writingStyles[index].content = content
            writingStyles[index].title = title.isEmpty ? writingStyles[index].title : title
            saveWritingStyles()
        }
    }
    
    func deleteStyle(at index: Int) {
        if index < writingStyles.count {
            writingStyles.remove(at: index)
            saveWritingStyles()
        }
    }
    
    func getTitle(for content: String) -> String? {
        return writingStyles.first { $0.content == content }?.title
    }
    
    // Legacy support for string-based styles
    var styleStrings: [String] {
        return writingStyles.map { $0.content }
    }
    
    private func saveWritingStyles() {
        if let encoded = try? JSONEncoder().encode(writingStyles) {
            UserDefaults.standard.set(encoded, forKey: "WritingStyles")
        }
    }
    
    private func loadWritingStyles() {
        if let data = UserDefaults.standard.data(forKey: "WritingStyles"),
           let decoded = try? JSONDecoder().decode([WritingStyle].self, from: data) {
            writingStyles = decoded
        } else {
            // Legacy loading for old string-based styles
            if let styles = UserDefaults.standard.stringArray(forKey: "WritingStyles") {
                writingStyles = styles.map { WritingStyle(title: "", content: $0) }
            }
        }
    }
}

struct Draft: Identifiable, Codable {
    var id = UUID()
    var title: String
    var content: String
    let dateCreated: Date
    
    init(title: String, content: String) {
        self.title = title.isEmpty ? "Draft \(Date().formatted(date: .abbreviated, time: .shortened))" : title
        self.content = content
        self.dateCreated = Date()
    }
}

class DraftStore: ObservableObject {
    @Published var drafts: [Draft] = []
    
    init() {
        loadDrafts()
    }
    
    func addDraft(_ draft: Draft) {
        drafts.insert(draft, at: 0)
        saveDrafts()
    }
    
    func updateDraft(_ draft: Draft, at index: Int) {
        if index < drafts.count {
            drafts[index] = draft
            saveDrafts()
        }
    }
    
    func deleteDraft(at index: Int) {
        if index < drafts.count {
            drafts.remove(at: index)
            saveDrafts()
        }
    }
    
    private func saveDrafts() {
        if let encoded = try? JSONEncoder().encode(drafts) {
            UserDefaults.standard.set(encoded, forKey: "Drafts")
        }
    }
    
    private func loadDrafts() {
        if let data = UserDefaults.standard.data(forKey: "Drafts"),
           let decoded = try? JSONDecoder().decode([Draft].self, from: data) {
            drafts = decoded
        }
    }
} 