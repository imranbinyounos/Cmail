import SwiftUI

struct ExpandableBox<Content: View>: View {
    let title: String
    let icon: String
    let isExpanded: Bool
    let onToggle: () -> Void
    let content: Content
    
    init(title: String, icon: String, isExpanded: Bool, onToggle: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.isExpanded = isExpanded
        self.onToggle = onToggle
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onToggle) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(.blue)
                        .font(.title2)
                    
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                .padding()
                .background(Color(red: 0.2, green: 0.2, blue: 0.2))
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                content
                    .padding()
                    .background(Color(red: 0.15, green: 0.15, blue: 0.15))
                    .cornerRadius(8)
                    .padding(.top, 4)
            }
        }
    }
}

#Preview {
    VStack {
        ExpandableBox(
            title: "Test Box",
            icon: "star.fill",
            isExpanded: true,
            onToggle: {}
        ) {
            Text("This is the expanded content")
                .foregroundColor(.white)
        }
    }
    .padding()
    .background(Color.black)
} 