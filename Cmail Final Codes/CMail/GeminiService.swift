import Foundation

class GeminiService: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiKey = "AIzaSyC22BwxkjtNnTqjD4P79XIADPn5KkG13EY"
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"
    
    func generateEmail(formData: EmailFormData, savedEmails: [SavedEmail], writingStyles: [WritingStyle]) async -> String? {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let systemInstruction = buildSystemInstruction(savedEmails: savedEmails, writingStyles: writingStyles)
        let userPrompt = buildUserPrompt(formData: formData)
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": systemInstruction + "\n\n" + userPrompt]
                    ]
                ]
            ],
            "generationConfig": [
                "maxOutputTokens": 800,
                "temperature": 0.7,
                "topP": 0.8,
                "topK": 40
            ]
        ]
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
                await MainActor.run {
                    errorMessage = "Invalid URL"
                    isLoading = false
                }
                return nil
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("CMail/1.0", forHTTPHeaderField: "User-Agent")
            request.timeoutInterval = 60.0
            
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            request.httpBody = jsonData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                await MainActor.run {
                    errorMessage = "Invalid response"
                    isLoading = false
                }
                return nil
            }
            
            if httpResponse.statusCode != 200 {
                let errorString = String(data: data, encoding: .utf8) ?? "Unknown error"
                await MainActor.run {
                    errorMessage = "Server error \(httpResponse.statusCode): \(errorString)"
                    isLoading = false
                }
                return nil
            }
            
            let responseString = String(data: data, encoding: .utf8) ?? ""
            
            // Parse the response to extract the generated text
            if let generatedText = extractGeneratedText(from: responseString) {
                await MainActor.run {
                    isLoading = false
                }
                return generatedText
            } else {
                await MainActor.run {
                    errorMessage = "Failed to parse response: \(responseString)"
                    isLoading = false
                }
                return nil
            }
            
        } catch let error as URLError {
            await MainActor.run {
                switch error.code {
                case .cannotFindHost:
                    errorMessage = "Cannot connect to server. Please check your internet connection."
                case .timedOut:
                    errorMessage = "Request timed out. Please try again."
                case .notConnectedToInternet:
                    errorMessage = "No internet connection. Please check your network."
                default:
                    errorMessage = "Network error: \(error.localizedDescription)"
                }
                isLoading = false
            }
            return nil
        } catch {
            await MainActor.run {
                errorMessage = "Error: \(error.localizedDescription)"
                isLoading = false
            }
            return nil
        }
    }
    
    private func buildSystemInstruction(savedEmails: [SavedEmail], writingStyles: [WritingStyle]) -> String {
        // Prioritize writing styles over saved emails
        let writingStyleExamples = writingStyles
            .filter { !$0.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .map { $0.content }
        
        let savedEmailExamples = savedEmails
            .filter { !$0.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .map { $0.content }
        
        let primaryExamples = writingStyleExamples.isEmpty ? savedEmailExamples : writingStyleExamples
        let secondaryExamples = writingStyleExamples.isEmpty ? [] : savedEmailExamples
        
        let examplesText = primaryExamples.isEmpty ? "" : """
        
        WRITING STYLE EXAMPLES (CRITICAL - FOLLOW THESE EXACTLY):
        \(primaryExamples.enumerated().map { index, example in
            "Example \(index + 1):\n\(example)"
        }.joined(separator: "\n\n"))
        """
        
        let secondaryText = secondaryExamples.isEmpty ? "" : """
        
        ADDITIONAL REFERENCE EXAMPLES:
        \(secondaryExamples.enumerated().map { index, example in
            "Reference \(index + 1):\n\(example)"
        }.joined(separator: "\n\n"))
        """
        
        return """
        You are an expert assistant at crafting professional academic cold emails to university professors.

        CRITICAL INSTRUCTION: Your primary and most important goal is to generate an email that STRICTLY adheres to the writing style, tone, and structure of the WRITING STYLE EXAMPLES provided below. These writing style examples represent the user's actual writing style and should be your primary reference.
        
        REQUIREMENTS:
        1. **Style Matching**: The generated email MUST match the tone, vocabulary, sentence structure, and writing patterns from the provided examples.
        2. **Professional Academic Tone**: Maintain a formal, respectful, and scholarly tone appropriate for academic communication.
        3. **Logical Structure**: Follow a clear, logical flow: introduction, background, specific request, and conclusion.
        4. **Personalization**: Incorporate specific details about the professor's research, university, and department.
        5. **Conciseness**: Keep the email concise but comprehensive (typically 150-250 words).
        6. **Grammar and Formatting**: Ensure perfect grammar, spelling, and professional formatting.
        
        FORMAT REQUIREMENTS:
        - Start with a proper greeting: "Dear Professor [Last Name],"
        - Use formal academic language throughout
        - Include specific references to the professor's work when possible
        - End with a professional closing: "Best regards," or "Sincerely,"
        - Include your name at the end
        
        \(examplesText)\(secondaryText)
        
        IMPORTANT: If writing style examples are provided, you MUST follow their exact tone, structure, and writing patterns. If no examples are provided, create a professional academic email following standard conventions.
        """
    }
    
    private func buildUserPrompt(formData: EmailFormData) -> String {
        var prompt = "Please generate a professional cold email with the following details:\n\n"
        
        if !formData.professorName.isEmpty {
            prompt += "Professor's Name: \(formData.professorName)\n"
        }
        
        if !formData.universityName.isEmpty {
            prompt += "University: \(formData.universityName)\n"
        }
        
        if !formData.departmentName.isEmpty {
            prompt += "Department: \(formData.departmentName)\n"
        }
        
        if !formData.labName.isEmpty {
            prompt += "Laboratory/Research Group: \(formData.labName)\n"
        }
        
        if !formData.researchTopic.isEmpty {
            prompt += "Research Topic of Interest: \(formData.researchTopic)\n"
        }
        
        if !formData.opportunityType.isEmpty {
            prompt += "Opportunity Type: \(formData.opportunityType)\n"
        }
        
        if !formData.projectDetails.isEmpty {
            prompt += "Project Details: \(formData.projectDetails)\n"
        }
        
        if !formData.prompt.isEmpty {
            prompt += "Additional Context: \(formData.prompt)\n"
        }
        
        prompt += "\nGenerate a professional, personalized email that incorporates all relevant information and follows the writing style examples provided."
        
        return prompt
    }
    
    private func extractGeneratedText(from responseString: String) -> String? {
        // Parse the JSON response to extract the generated text
        guard let data = responseString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            return nil
        }
        
        return text
    }
} 
