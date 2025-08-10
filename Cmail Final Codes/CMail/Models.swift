import Foundation

struct SavedEmail: Identifiable, Codable {
    var id = UUID()
    var title: String
    var content: String
    let dateCreated: Date
    
    init(content: String, title: String = "") {
        self.content = content
        self.title = title.isEmpty ? "Generated Email \(Date().formatted(date: .abbreviated, time: .shortened))" : title
        self.dateCreated = Date()
    }
}

struct EmailFormData {
    var professorName: String = ""
    var universityName: String = ""
    var departmentName: String = ""
    var labName: String = ""
    var researchTopic: String = ""
    var opportunityType: String = ""
    var projectDetails: String = ""
    var prompt: String = ""
}

enum OpportunityType: String, CaseIterable {
    case msc = "MSc"
    case phd = "PhD"
    case both = "Both MSc/PhD"
    
    var displayName: String {
        return self.rawValue
    }
} 
